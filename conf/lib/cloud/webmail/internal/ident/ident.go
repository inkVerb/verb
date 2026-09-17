package ident

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Passkey struct {
	ID           string `json:"id"`
	CredentialID string `json:"credential_id"`
	PublicKey    string `json:"public_key"`
	Name         string `json:"name"`
	CreatedAt    string `json:"created_at"`
	SignCount    int    `json:"sign_count"`
}

type OAuth struct {
	Provider string `json:"provider"`
	Subject  string `json:"subject"`
	Email    string `json:"email"`
}

type Device struct {
	Selector  string `json:"selector"`
	TokenHash string `json:"token_hash"`
	ExpiresAt string `json:"expires_at"`
}

type Admin struct {
	Username    string    `json:"username"`
	Name        string    `json:"name"`
	Email       string    `json:"email"`
	Pass        string    `json:"pass"`
	PassLogin   bool      `json:"pass_login"`
	TotpSecret  string    `json:"totp_secret"`
	TotpEnabled bool      `json:"totp_enabled"`
	Theme       string    `json:"theme"`
	OAuth       []OAuth   `json:"oauth"`
	Passkeys    []Passkey `json:"passkeys"`
	TotpDevices []Device  `json:"totp_devices"`
}

type Store struct {
	mu   sync.Mutex
	path string
	a    Admin
}

func Open(path string) (*Store, error) {
	s := &Store{path: path}
	b, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			s.a = Admin{Username: "admin", PassLogin: true, Theme: "theme-dusk-desk"}
			_ = s.saveLocked()
			return s, nil
		}
		return nil, err
	}
	if len(b) > 0 {
		_ = json.Unmarshal(b, &s.a)
		if !strings.Contains(string(b), `"pass_login"`) {
			s.a.PassLogin = true
		}
	}
	if s.a.Username == "" {
		s.a.Username = "admin"
	}
	if s.a.Theme == "" {
		s.a.Theme = "theme-dusk-desk"
	}
	return s, nil
}

func (s *Store) Get() Admin {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.a
}

func (s *Store) Update(fn func(*Admin)) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	fn(&s.a)
	return s.saveLocked()
}

func (s *Store) saveLocked() error {
	_ = os.MkdirAll(filepath.Dir(s.path), 0750)
	b, err := json.MarshalIndent(s.a, "", "  ")
	if err != nil {
		return err
	}
	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, b, 0600); err != nil {
		return err
	}
	return os.Rename(tmp, s.path)
}

func (s *Store) HasPassword() bool {
	return s.Get().Pass != ""
}

func (s *Store) PasswordOn() bool {
	a := s.Get()
	return a.Pass != "" && a.PassLogin
}

func (s *Store) CanDisablePass() bool {
	a := s.Get()
	return len(a.Passkeys) > 0 && len(a.OAuth) > 0
}

func HashPass(plain string) string {
	salt := make([]byte, 16)
	_, _ = rand.Read(salt)
	dk := pbkdf2(plain, salt, 100000, 32)
	return "pbkdf2$100000$" + hex.EncodeToString(salt) + "$" + hex.EncodeToString(dk)
}

func CheckPass(hash, plain string) bool {
	parts := strings.Split(hash, "$")
	if len(parts) != 4 || parts[0] != "pbkdf2" {
		return false
	}
	iter, _ := strconv.Atoi(parts[1])
	if iter < 1 {
		iter = 100000
	}
	salt, err := hex.DecodeString(parts[2])
	if err != nil {
		return false
	}
	want, err := hex.DecodeString(parts[3])
	if err != nil {
		return false
	}
	got := pbkdf2(plain, salt, iter, len(want))
	return hmac.Equal(want, got)
}

func pbkdf2(pw string, salt []byte, iter, keyLen int) []byte {
	hLen := sha256.Size
	n := (keyLen + hLen - 1) / hLen
	out := make([]byte, 0, n*hLen)
	pwb := []byte(pw)
	for i := 1; i <= n; i++ {
		var ib [4]byte
		ib[0] = byte(i >> 24)
		ib[1] = byte(i >> 16)
		ib[2] = byte(i >> 8)
		ib[3] = byte(i)
		mac := hmac.New(sha256.New, pwb)
		mac.Write(salt)
		mac.Write(ib[:])
		u := mac.Sum(nil)
		t := append([]byte{}, u...)
		for j := 1; j < iter; j++ {
			mac = hmac.New(sha256.New, pwb)
			mac.Write(u)
			u = mac.Sum(nil)
			for k := range t {
				t[k] ^= u[k]
			}
		}
		out = append(out, t...)
	}
	return out[:keyLen]
}

type Session struct {
	User       string `json:"u"`
	Exp        int64  `json:"e"`
	CSRF       string `json:"c"`
	Pending    bool   `json:"p,omitempty"`
	Via        string `json:"v,omitempty"`
	TotpPend   string `json:"t,omitempty"`
	OAuthState string `json:"os,omitempty"`
	OAuthProv  string `json:"op,omitempty"`
	OAuthLink  bool   `json:"ol,omitempty"`
	OAuthPop   bool   `json:"opp,omitempty"`
	WAChal     string `json:"w,omitempty"`
}

func SignSess(secret string, s Session) string {
	b, _ := json.Marshal(s)
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(b)
	return hex.EncodeToString(b) + "." + hex.EncodeToString(mac.Sum(nil))
}

func ReadSess(secret, tok string) (Session, bool) {
	var z Session
	parts := strings.Split(tok, ".")
	if len(parts) != 2 {
		return z, false
	}
	raw, err := hex.DecodeString(parts[0])
	if err != nil {
		return z, false
	}
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(raw)
	want := hex.EncodeToString(mac.Sum(nil))
	if !hmac.Equal([]byte(want), []byte(parts[1])) {
		return z, false
	}
	if json.Unmarshal(raw, &z) != nil {
		return z, false
	}
	if z.Exp > 0 && time.Now().Unix() > z.Exp {
		return z, false
	}
	return z, true
}

func NewCSRF() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

func RandHex(n int) string {
	b := make([]byte, n)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

func NewID() string {
	return fmt.Sprintf("%d", time.Now().UnixNano())
}
