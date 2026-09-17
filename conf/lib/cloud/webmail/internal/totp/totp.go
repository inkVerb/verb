package totp

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"encoding/binary"
	"fmt"
	"net/url"
	"strings"
	"time"
)

const alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

func Secret() string {
	b := make([]byte, 20)
	_, _ = rand.Read(b)
	return b32(b)
}

func URI(secret, account, issuer string) string {
	label := url.PathEscape(issuer + ":" + account)
	q := url.Values{}
	q.Set("secret", secret)
	q.Set("issuer", issuer)
	return "otpauth://totp/" + label + "?" + q.Encode()
}

func Verify(secret, code string) bool {
	code = strings.Join(strings.Fields(code), "")
	if len(code) != 6 {
		return false
	}
	t := time.Now().Unix() / 30
	for i := int64(-1); i <= 1; i++ {
		if hmac.Equal([]byte(at(secret, t+i)), []byte(code)) {
			return true
		}
	}
	return false
}

func at(secret string, counter int64) string {
	key := unb32(secret)
	var buf [8]byte
	binary.BigEndian.PutUint64(buf[:], uint64(counter))
	mac := hmac.New(sha1.New, key)
	mac.Write(buf[:])
	h := mac.Sum(nil)
	off := h[19] & 0x0f
	trunc := binary.BigEndian.Uint32(h[off:off+4]) & 0x7fffffff
	return fmt.Sprintf("%06d", trunc%1000000)
}

func b32(data []byte) string {
	var bits strings.Builder
	for _, c := range data {
		bits.WriteString(fmt.Sprintf("%08b", c))
	}
	s := bits.String()
	var out strings.Builder
	for i := 0; i < len(s); i += 5 {
		chunk := s[i:]
		if len(chunk) < 5 {
			chunk += "00000"
			chunk = chunk[:5]
		} else {
			chunk = chunk[:5]
		}
		n := 0
		for _, c := range chunk {
			n = n*2 + int(c-'0')
		}
		out.WriteByte(alpha[n])
	}
	return out.String()
}

func unb32(b32s string) []byte {
	b32s = strings.ToUpper(b32s)
	var bits strings.Builder
	for _, c := range b32s {
		idx := strings.IndexRune(alpha, c)
		if idx < 0 {
			continue
		}
		bits.WriteString(fmt.Sprintf("%05b", idx))
	}
	s := bits.String()
	out := make([]byte, 0, len(s)/8)
	for i := 0; i+8 <= len(s); i += 8 {
		n := 0
		for _, c := range s[i : i+8] {
			n = n*2 + int(c-'0')
		}
		out = append(out, byte(n))
	}
	return out
}
