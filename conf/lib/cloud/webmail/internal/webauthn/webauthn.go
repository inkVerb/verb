package webauthn

import (
	"crypto"
	"crypto/ecdsa"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"strings"
)

func B64u(bin []byte) string {
	return strings.TrimRight(base64.RawURLEncoding.EncodeToString(bin), "=")
}

func B64d(s string) []byte {
	s = strings.ReplaceAll(strings.ReplaceAll(s, "-", "+"), "_", "/")
	switch len(s) % 4 {
	case 2:
		s += "=="
	case 3:
		s += "="
	}
	b, _ := base64.StdEncoding.DecodeString(s)
	return b
}

func OptionsCreate(rpID, rpName, userName, display string, userID, chal []byte) map[string]any {
	return map[string]any{
		"challenge": B64u(chal),
		"rp":        map[string]string{"name": rpName, "id": rpID},
		"user": map[string]string{
			"id": B64u(userID), "name": userName, "displayName": display,
		},
		"pubKeyCredParams": []map[string]any{
			{"type": "public-key", "alg": -7},
			{"type": "public-key", "alg": -257},
		},
		"authenticatorSelection": map[string]string{
			"residentKey": "preferred", "userVerification": "preferred",
		},
		"timeout":     60000,
		"attestation": "none",
	}
}

func OptionsGet(rpID string, chal []byte, credIDs []string) map[string]any {
	opt := map[string]any{
		"challenge":        B64u(chal),
		"rpId":             rpID,
		"timeout":          60000,
		"userVerification": "preferred",
	}
	if len(credIDs) > 0 {
		allow := make([]map[string]any, 0, len(credIDs))
		for _, id := range credIDs {
			allow = append(allow, map[string]any{"type": "public-key", "id": B64u(B64d(id))})
		}
		opt["allowCredentials"] = allow
	}
	return opt
}

func Assert(credID, clientB64, authB64, sigB64, wantChal, pemOrSPKI string) bool {
	client := B64d(clientB64)
	auth := B64d(authB64)
	sig := B64d(sigB64)
	var data map[string]any
	if json.Unmarshal(client, &data) != nil {
		return false
	}
	if data["type"] != "webauthn.get" {
		return false
	}
	got, _ := data["challenge"].(string)
	got = strings.TrimRight(strings.ReplaceAll(strings.ReplaceAll(got, "-", "+"), "_", "/"), "=")
	want := strings.TrimRight(strings.ReplaceAll(strings.ReplaceAll(wantChal, "-", "+"), "_", "/"), "=")
	if want == "" || got != want {
		return false
	}
	sum := sha256.Sum256(client)
	signed := append(append([]byte{}, auth...), sum[:]...)
	pub := parseKey(pemOrSPKI)
	if pub == nil {
		return false
	}
	h := sha256.Sum256(signed)
	if len(sig) == 64 {
		sig = ecdsaDer(sig)
	}
	switch k := pub.(type) {
	case *ecdsa.PublicKey:
		return ecdsa.VerifyASN1(k, h[:], sig)
	case *rsa.PublicKey:
		return rsa.VerifyPKCS1v15(k, crypto.SHA256, h[:], sig) == nil
	}
	return false
}

func parseKey(s string) any {
	raw := []byte(s)
	if strings.Contains(s, "BEGIN") {
		block := pemBytes(s)
		if k, err := x509.ParsePKIXPublicKey(block); err == nil {
			return k
		}
		return nil
	}
	der := B64d(s)
	if k, err := x509.ParsePKIXPublicKey(der); err == nil {
		return k
	}
	if k, err := x509.ParsePKIXPublicKey(raw); err == nil {
		return k
	}
	return nil
}

func pemBytes(s string) []byte {
	s = strings.ReplaceAll(s, "-----BEGIN PUBLIC KEY-----", "")
	s = strings.ReplaceAll(s, "-----END PUBLIC KEY-----", "")
	s = strings.ReplaceAll(s, "\n", "")
	s = strings.TrimSpace(s)
	b, _ := base64.StdEncoding.DecodeString(s)
	return b
}

func SPKIToPEM(spki []byte) string {
	b64 := base64.StdEncoding.EncodeToString(spki)
	var b strings.Builder
	b.WriteString("-----BEGIN PUBLIC KEY-----\n")
	for i := 0; i < len(b64); i += 64 {
		end := i + 64
		if end > len(b64) {
			end = len(b64)
		}
		b.WriteString(b64[i:end])
		b.WriteByte('\n')
	}
	b.WriteString("-----END PUBLIC KEY-----\n")
	return b.String()
}

func ecdsaDer(raw []byte) []byte {
	h := len(raw) / 2
	return derSeq(append(derInt(raw[:h]), derInt(raw[h:])...))
}

func derInt(n []byte) []byte {
	n = bytesTrimLeftZero(n)
	if len(n) == 0 || n[0]&0x80 != 0 {
		n = append([]byte{0}, n...)
	}
	return append([]byte{0x02, byte(len(n))}, n...)
}

func derSeq(inner []byte) []byte {
	if len(inner) < 128 {
		return append([]byte{0x30, byte(len(inner))}, inner...)
	}
	return append([]byte{0x30, 0x81, byte(len(inner))}, inner...)
}

func bytesTrimLeftZero(n []byte) []byte {
	i := 0
	for i < len(n)-1 && n[i] == 0 {
		i++
	}
	return n[i:]
}
