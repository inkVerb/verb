package main

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"crypto/sha256"
	"encoding/base32"
	"encoding/binary"
	"encoding/hex"
	"flag"
	"fmt"
	"html"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"sync"
	"time"
)

// modernc.org/sqlite needs a module. To stay stdlib-only we exec sqlite3 instead.

func main() {
	cfgp := flag.String("config", "/opt/verb/conf/verbadmin.conf", "config")
	flag.Parse()
	c := load(*cfgp)
	s := &srv{c: c, sess: map[string]*session{}}
	mux := http.NewServeMux()
	mux.HandleFunc("/pen-logo.svg", s.logo)
	mux.HandleFunc("/login", s.login)
	mux.HandleFunc("/logout", s.logout)
	mux.HandleFunc("/gate", s.gate)
	mux.HandleFunc("/oauth/", s.oauth)
	mux.HandleFunc("/", s.home)
	mux.HandleFunc("/serf", s.serf)
	mux.HandleFunc("/inkmail", s.inkmail)
	mux.HandleFunc("/vapps", s.vapps)
	mux.HandleFunc("/vapp", s.vapp)
	addr := c["listen"]
	if addr == "" {
		addr = "127.0.0.1:8098"
	}
	log.Printf("verbadmin on %s", addr)
	log.Fatal(http.ListenAndServe(addr, mux))
}

type srv struct {
	c    map[string]string
	mu   sync.Mutex
	sess map[string]*session
}
type session struct {
	User       string
	Type       string // admin | supervisor
	Stage      string // password|changepw|email|2fa|ok
	Until      time.Time
	ConfigAuth map[string]time.Time // vapp file basename -> double-auth until
}

func load(path string) map[string]string {
	m := map[string]string{}
	b, err := os.ReadFile(path)
	if err != nil {
		return m
	}
	for _, line := range strings.Split(string(b), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		k, v, ok := strings.Cut(line, "=")
		if ok {
			m[strings.TrimSpace(k)] = strings.TrimSpace(v)
		}
	}
	return m
}

func (s *srv) logo(w http.ResponseWriter, r *http.Request) {
	for _, p := range []string{"web/static/pen-logo.svg", "/opt/verb/conf/lib/logo/pen-logo.svg"} {
		b, err := os.ReadFile(p)
		if err == nil {
			w.Header().Set("Content-Type", "image/svg+xml")
			w.Write(b)
			return
		}
	}
	http.NotFound(w, r)
}

func (s *srv) get(r *http.Request) *session {
	c, err := r.Cookie("verbadmin")
	if err != nil {
		return nil
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	ss := s.sess[c.Value]
	if ss == nil || time.Now().After(ss.Until) {
		return nil
	}
	return ss
}

func (s *srv) put(w http.ResponseWriter, ss *session) {
	tok := randTok()
	ss.Until = time.Now().Add(12 * time.Hour)
	s.mu.Lock()
	s.sess[tok] = ss
	s.mu.Unlock()
	http.SetCookie(w, &http.Cookie{Name: "verbadmin", Value: tok, Path: "/", HttpOnly: true, SameSite: http.SameSiteLaxMode, Secure: true})
}

func randTok() string {
	var b [16]byte
	_, _ = rand.Read(b[:])
	return hex.EncodeToString(b[:])
}

func pamOK(user, pass string) bool {
	cmd := exec.Command("/opt/verb/conf/lib/cloud/pam-auth")
	cmd.Stdin = strings.NewReader(user + "\n" + pass + "\n")
	return cmd.Run() == nil
}

func groupsOf(user string) []string {
	out, err := exec.Command("id", "-nG", user).Output()
	if err != nil {
		return nil
	}
	return strings.Fields(string(out))
}

func hasAll(have []string, want ...string) bool {
	set := map[string]bool{}
	for _, h := range have {
		set[h] = true
	}
	for _, w := range want {
		if !set[w] {
			return false
		}
	}
	return true
}

func typeFromGroups(have []string) string {
	if hasAll(have, "verb", "admin") {
		return "admin"
	}
	if hasAll(have, "verb", "supervisor") {
		return "supervisor"
	}
	return ""
}

func sqlUser(db, user string) (email, atype string, pwChanged, emailOK, totpOK, pkOK bool, totp string) {
	out, err := exec.Command("sqlite3", "-separator", "|", db,
		"SELECT email,account_type,password_changed,email_confirmed,totp_confirmed,passkey_confirmed,IFNULL(totp_secret,'') FROM users WHERE username='"+escape(user)+"';").Output()
	if err != nil {
		return
	}
	p := strings.Split(strings.TrimSpace(string(out)), "|")
	if len(p) < 7 {
		return
	}
	email, atype, totp = p[0], p[1], p[6]
	pwChanged, emailOK, totpOK, pkOK = p[2] == "1", p[3] == "1", p[4] == "1", p[5] == "1"
	return
}

func escape(s string) string { return strings.ReplaceAll(s, "'", "''") }

func sqlExec(db, q string) { _ = exec.Command("sqlite3", db, q).Run() }

func (s *srv) login(w http.ResponseWriter, r *http.Request) {
	msg := ""
	if r.Method == "POST" {
		u := strings.TrimSpace(r.FormValue("username"))
		pw := r.FormValue("password")
		if !pamOK(u, pw) {
			msg = `<p class="flash">Login failed.</p>`
		} else {
			g := groupsOf(u)
			t := typeFromGroups(g)
			if t == "" {
				msg = `<p class="flash">Not a verb web UI user (need groups verb + admin|supervisor).</p>`
			} else {
				db := s.c["db"]
				email, st, pwCh, emOK, totpOK, pkOK, _ := sqlUser(db, u)
				if st == "" || st != t {
					msg = `<p class="flash">SQL account type does not match PAM groups. Denied.</p>`
				} else {
					ss := &session{User: u, Type: t, Stage: "ok", ConfigAuth: map[string]time.Time{}}
					if !pwCh {
						ss.Stage = "changepw"
					} else if !emOK {
						ss.Stage = "email"
						s.issueEmail(db, u, email)
					} else if !totpOK && !pkOK {
						ss.Stage = "2fa"
					}
					s.put(w, ss)
					_ = email
					http.Redirect(w, r, "/gate", http.StatusSeeOther)
					return
				}
			}
		}
	}
	fmt.Fprint(w, page("Verb admin", "", msg+`<div class="card login"><h1>Sign in</h1>
<p class="muted">PAM user with groups <code>verb</code> and <code>admin</code> or <code>supervisor</code>. No Linux permissions.</p>
<form method="post"><label>Username</label><input name="username" autofocus required>
<label>Password</label><input type="password" name="password" required>
<p><button>Continue</button></p></form>
<p class="muted">Also: email code, Authenticator, Passkey, and linked Apple / Google / Facebook / LinkedIn / GitHub / X once enrolled.</p>
</div>`))
}

func (s *srv) issueEmail(db, user, email string) {
	code := fmt.Sprintf("%06d", time.Now().UnixNano()%1000000)
	sqlExec(db, fmt.Sprintf("DELETE FROM email_codes WHERE username='%s'; INSERT INTO email_codes(username,code,purpose,expires_at) VALUES('%s','%s','confirm',%d);",
		escape(user), escape(user), escape(code), time.Now().Add(20*time.Minute).Unix()))
	_ = exec.Command("/usr/bin/mail", "-s", "Confirm your admin email", email).Run()
	// Best-effort: also write the code next to the one-time password for the first login
	_ = os.WriteFile("/opt/verb/conf/webadmin/ot/"+user+".emailcode", []byte(code+"\n"), 0600)
}

func (s *srv) logout(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, &http.Cookie{Name: "verbadmin", Value: "", Path: "/", MaxAge: -1})
	http.Redirect(w, r, "/login", http.StatusSeeOther)
}

func (s *srv) gate(w http.ResponseWriter, r *http.Request) {
	ss := s.get(r)
	if ss == nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}
	db := s.c["db"]
	if r.Method == "POST" {
		switch r.FormValue("act") {
		case "changepw":
			np := r.FormValue("password")
			if len(np) >= 10 {
				cmd := exec.Command("/usr/sbin/chpasswd")
				cmd.Stdin = strings.NewReader(ss.User + ":" + np + "\n")
				if cmd.Run() == nil {
					sqlExec(db, "UPDATE users SET password_changed=1 WHERE username='"+escape(ss.User)+"';")
					_ = os.Remove("/opt/verb/conf/webadmin/ot/" + ss.User)
					ss.Stage = "email"
					_, email, _, _, _, _, _ := sqlPick(db, ss.User)
					s.issueEmail(db, ss.User, email)
				}
			}
		case "email":
			code := strings.TrimSpace(r.FormValue("code"))
			out, _ := exec.Command("sqlite3", db, "SELECT code FROM email_codes WHERE username='"+escape(ss.User)+"' AND expires_at>"+fmt.Sprint(time.Now().Unix())+";").Output()
			if strings.TrimSpace(string(out)) == code && code != "" {
				sqlExec(db, "UPDATE users SET email_confirmed=1 WHERE username='"+escape(ss.User)+"';")
				ss.Stage = "2fa"
			}
		case "totp_start":
			sec := totpSecret()
			sqlExec(db, "UPDATE users SET totp_secret='"+sec+"' WHERE username='"+escape(ss.User)+"';")
		case "totp_confirm":
			_, _, _, _, _, _, secret := sqlUser(db, ss.User)
			if totpOK(secret, r.FormValue("code")) {
				sqlExec(db, "UPDATE users SET totp_confirmed=1 WHERE username='"+escape(ss.User)+"';")
				ss.Stage = "ok"
			}
		}
	}
	_, _, pwCh, emOK, totpOK, pkOK, secret := sqlUser(db, ss.User)
	if pwCh && emOK && (totpOK || pkOK) {
		ss.Stage = "ok"
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}
	body := `<div class="card"><h1>Finish enrolling</h1><p class="muted">The UI stays locked until the password is changed, email is confirmed, and Authenticator or Passkey is added.</p>`
	if !pwCh {
		body += `<h2>Change password</h2><form method="post"><input type="hidden" name="act" value="changepw"><label>New password (10+)</label><input type="password" name="password" required minlength="10"><p><button>Save</button></p></form>`
	} else if !emOK {
		body += `<h2>Confirm email</h2><p class="muted">A code was written to <code>/opt/verb/conf/webadmin/ot/` + html.EscapeString(ss.User) + `.emailcode</code> and mailed if <code>mail</code> is configured.</p>
<form method="post"><input type="hidden" name="act" value="email"><label>Code</label><input name="code" required><p><button>Confirm</button></p></form>`
	} else {
		body += `<h2>Authenticator</h2>`
		if secret == "" {
			body += `<form method="post"><input type="hidden" name="act" value="totp_start"><button>Generate secret</button></form>`
		} else {
			body += `<p>Secret: <code>` + html.EscapeString(secret) + `</code></p>
<form method="post"><input type="hidden" name="act" value="totp_confirm"><label>Code</label><input name="code" inputmode="numeric" required><p><button>Confirm Authenticator</button></p></form>`
		}
		body += `<h2>Passkey</h2><p class="muted">Use an https host. Platform or hardware key. Enrollment stores the credential against this PAM user.</p>`
	}
	body += `</div>`
	fmt.Fprint(w, page("Verb admin", ss.User, body))
}

func sqlPick(db, user string) (username, email string, pw, em, totp, pk bool, secret string) {
	email, _, pw, em, totp, pk, secret = sqlUser(db, user)
	return user, email, pw, em, totp, pk, secret
}

func totpSecret() string {
	var b [10]byte
	_, _ = rand.Read(b[:])
	return strings.TrimRight(base32.StdEncoding.EncodeToString(b[:]), "=")
}

func totpOK(secret, code string) bool {
	if secret == "" || len(code) < 6 {
		return false
	}
	sec := secret
	if n := len(sec) % 8; n != 0 {
		sec += strings.Repeat("=", 8-n)
	}
	key, err := base32.StdEncoding.DecodeString(strings.ToUpper(sec))
	if err != nil {
		return false
	}
	now := time.Now().Unix() / 30
	for _, w := range []int64{now - 1, now, now + 1} {
		if fmt.Sprintf("%06d", hotp(key, uint64(w))) == code {
			return true
		}
	}
	return false
}

func hotp(key []byte, counter uint64) uint32 {
	var buf [8]byte
	binary.BigEndian.PutUint64(buf[:], counter)
	mac := hmac.New(sha1.New, key)
	mac.Write(buf[:])
	sum := mac.Sum(nil)
	o := sum[len(sum)-1] & 0x0f
	n := binary.BigEndian.Uint32(sum[o:o+4]) & 0x7fffffff
	return n % 1000000
}

func (s *srv) home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	ss := s.ready(w, r)
	if ss == nil {
		return
	}
	info, _ := exec.Command("/opt/verb/serfs/showverber").CombinedOutput()
	fmt.Fprint(w, page("Verb admin", ss.User+" · "+ss.Type, `<div class="card"><h1>Server</h1><pre>`+html.EscapeString(string(info))+`</pre></div>
<div class="card"><h2>Commands</h2>
<p class="muted">All serfs and felt headers. IP addresses are rink-only and are not editable here.</p>
<form method="post" action="/serf"><label>Serf name</label><input name="serf" required placeholder="showdns">
<label>Arguments</label><input name="args">
<p><button>Run</button></p></form>
<p><a href="/vapps">Vapp configs</a></p>
<p><a href="/inkmail">Open inkMail (SSO)</a></p>
</div>`))
}

func (s *srv) ready(w http.ResponseWriter, r *http.Request) *session {
	ss := s.get(r)
	if ss == nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return nil
	}
	if ss.Stage != "ok" {
		http.Redirect(w, r, "/gate", http.StatusSeeOther)
		return nil
	}
	return ss
}

func (s *srv) serf(w http.ResponseWriter, r *http.Request) {
	ss := s.ready(w, r)
	if ss == nil {
		return
	}
	if r.Method != "POST" {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}
	name := strings.TrimSpace(r.FormValue("serf"))
	if strings.ContainsAny(name, "./ ") || name == "" {
		http.Error(w, "bad serf", 400)
		return
	}
	// Block rink-only IP conf from this UI
	switch name {
	case "setipv4", "setipv6", "setipv4update", "setipv6update":
		fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><p class="flash">IP configuration is rink-only.</p></div>`))
		return
	}
	args := strings.Fields(r.FormValue("args"))
	cmd := exec.Command(append([]string{"/opt/verb/serfs/" + name}, args...)...)
	out, err := cmd.CombinedOutput()
	msg := html.EscapeString(string(out))
	if err != nil {
		msg += "\n" + html.EscapeString(err.Error())
	}
	fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><h2>`+html.EscapeString(name)+`</h2><pre>`+msg+`</pre><p><a href="/">Back</a></p></div>`))
}

func (s *srv) inkmail(w http.ResponseWriter, r *http.Request) {
	ss := s.ready(w, r)
	if ss == nil {
		return
	}
	sec := s.c["sso_secret"]
	exp := fmt.Sprintf("%d", time.Now().Add(time.Hour).Unix())
	msg := ss.User + "." + exp
	mac := hmac.New(sha256.New, []byte(sec))
	mac.Write([]byte(msg))
	tok := msg + "." + hex.EncodeToString(mac.Sum(nil))
	url := s.c["inkmail_url"]
	if url == "" {
		url = "/sso"
	}
	http.Redirect(w, r, strings.TrimRight(url, "/")+"/sso?t="+tok, http.StatusSeeOther)
}

func mailSkip(name string) bool {
	n := strings.ToLower(name)
	for _, p := range []string{"roundcube", "inkmail", "postfixadmin", "pfa", "maddy", "inkemail"} {
		if strings.Contains(n, p) {
			return true
		}
	}
	return false
}

func parseAppConfig(vfile string) string {
	b, err := os.ReadFile(vfile)
	if err != nil {
		return ""
	}
	for _, line := range strings.Split(string(b), "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "appConfig=") {
			return strings.Trim(strings.TrimSpace(strings.TrimPrefix(line, "appConfig=")), `"'`)
		}
	}
	return ""
}

func allowedConfig(p string) bool {
	if p == "" || !strings.HasPrefix(p, "/") || strings.Contains(p, "..") {
		return false
	}
	for _, prefix := range []string{
		"/srv/www/vapps/",
		"/opt/verb/conf/vapps/",
		"/etc/pdt/",
		"/etc/badad/",
		"/srv/cloud/",
		"/srv/ghost/",
		"/etc/coolwsd/",
		"/etc/loolwsd/",
		"/srv/www/html/",
	} {
		if strings.HasPrefix(p, prefix) {
			if strings.Contains(p, "/orig/") {
				return false
			}
			return true
		}
	}
	return false
}

func (s *srv) cfgOK(ss *session, name string) bool {
	if ss.ConfigAuth == nil {
		return false
	}
	t, ok := ss.ConfigAuth[name]
	return ok && time.Now().Before(t)
}

func (s *srv) vapps(w http.ResponseWriter, r *http.Request) {
	ss := s.ready(w, r)
	if ss == nil {
		return
	}
	ents, _ := os.ReadDir("/opt/verb/conf/vapps")
	var b strings.Builder
	b.WriteString(`<div class="card"><h1>Vapp configs</h1>
<p class="muted">Only the essential config for each installed vapp. No filesystem browser. Mail panels (Roundcube, inkMail, PFA) are not listed.</p>
<p class="muted">Opening a config requires your password and a second factor again. An email warning is sent on each access. Reset restores the copy the install serf saved.</p><ul>`)
	n := 0
	for _, e := range ents {
		name := e.Name()
		if !strings.HasPrefix(name, "vapp.") || mailSkip(name) {
			continue
		}
		cfg := parseAppConfig("/opt/verb/conf/vapps/" + name)
		if cfg == "" {
			continue
		}
		n++
		fmt.Fprintf(&b, `<li><a href="/vapp?name=%s">%s</a> <span class="muted"><code>%s</code></span></li>`, html.EscapeString(name), html.EscapeString(name), html.EscapeString(cfg))
	}
	if n == 0 {
		b.WriteString(`<li class="muted">No vapps with an appConfig= line yet. Re-run the install serf or <code>updateverber</code>.</li>`)
	}
	b.WriteString(`</ul></div>`)
	fmt.Fprint(w, page("Verb admin", ss.User, b.String()))
}

func (s *srv) vapp(w http.ResponseWriter, r *http.Request) {
	ss := s.ready(w, r)
	if ss == nil {
		return
	}
	name := strings.TrimSpace(r.URL.Query().Get("name"))
	if name == "" {
		name = strings.TrimSpace(r.FormValue("name"))
	}
	if name == "" || strings.ContainsAny(name, "/\\") || mailSkip(name) || !strings.HasPrefix(name, "vapp.") {
		http.Error(w, "bad vapp", 400)
		return
	}
	vfile := "/opt/verb/conf/vapps/" + name
	cfg := parseAppConfig(vfile)
	if !allowedConfig(cfg) {
		fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><p class="flash">No editable config path on this vapp.</p></div>`))
		return
	}
	if r.Method == "POST" && r.FormValue("act") == "unlock" {
		pw := r.FormValue("password")
		code := strings.TrimSpace(r.FormValue("code"))
		if !pamOK(ss.User, pw) {
			fmt.Fprint(w, page("Verb admin", ss.User, s.unlockForm(name, cfg, "Password failed.")))
			return
		}
		db := s.c["db"]
		_, _, _, _, totpOn, _, secret := sqlUser(db, ss.User)
		if !totpOn {
			fmt.Fprint(w, page("Verb admin", ss.User, s.unlockForm(name, cfg, "Enroll Authenticator before editing configs.")))
			return
		}
		if !totpOK(secret, code) {
			fmt.Fprint(w, page("Verb admin", ss.User, s.unlockForm(name, cfg, "Authenticator code failed.")))
			return
		}
		if ss.ConfigAuth == nil {
			ss.ConfigAuth = map[string]time.Time{}
		}
		ss.ConfigAuth[name] = time.Now().Add(10 * time.Minute)
		s.warnConfigMail(ss, name, cfg)
		orig := "/opt/verb/conf/vapps/orig/" + name
		if _, err := os.Stat(orig); err != nil {
			if b, err := os.ReadFile(cfg); err == nil {
				_ = os.MkdirAll("/opt/verb/conf/vapps/orig", 0750)
				_ = os.WriteFile(orig, b, 0640)
			}
		}
		http.Redirect(w, r, "/vapp?name="+name, http.StatusSeeOther)
		return
	}
	if !s.cfgOK(ss, name) {
		fmt.Fprint(w, page("Verb admin", ss.User, s.unlockForm(name, cfg, "")))
		return
	}
	if r.Method == "POST" && r.FormValue("act") == "save" {
		body := r.FormValue("body")
		if len(body) > 1<<20 {
			fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><p class="flash">Config too large.</p></div>`))
			return
		}
		st, err := os.Stat(cfg)
		mode := os.FileMode(0640)
		if err == nil {
			mode = st.Mode()
		}
		if err := os.WriteFile(cfg, []byte(body), mode); err != nil {
			fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><p class="flash">`+html.EscapeString(err.Error())+`</p></div>`))
			return
		}
		http.Redirect(w, r, "/vapp?name="+name, http.StatusSeeOther)
		return
	}
	if r.Method == "POST" && r.FormValue("act") == "reset" {
		orig := "/opt/verb/conf/vapps/orig/" + name
		b, err := os.ReadFile(orig)
		if err != nil {
			fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><p class="flash">No install-time backup yet.</p></div>`))
			return
		}
		st, _ := os.Stat(cfg)
		mode := os.FileMode(0640)
		if st != nil {
			mode = st.Mode()
		}
		if err := os.WriteFile(cfg, b, mode); err != nil {
			fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><p class="flash">`+html.EscapeString(err.Error())+`</p></div>`))
			return
		}
		http.Redirect(w, r, "/vapp?name="+name, http.StatusSeeOther)
		return
	}
	raw, err := os.ReadFile(cfg)
	if err != nil {
		raw = []byte("/* file not created yet — save will create it */\n")
	}
	hasOrig := "no install-time copy yet"
	if _, err := os.Stat("/opt/verb/conf/vapps/orig/" + name); err == nil {
		hasOrig = "install-time copy available"
	}
	fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><h1>`+html.EscapeString(name)+`</h1>
<p class="muted"><code>`+html.EscapeString(cfg)+`</code> — `+hasOrig+`. Access expires in a few minutes.</p>
<form method="post" action="/vapp?name=`+html.EscapeString(name)+`"><input type="hidden" name="act" value="save">
<textarea name="body" rows="28" style="width:100%;font-family:monospace">`+html.EscapeString(string(raw))+`</textarea>
<p><button>Save</button></p></form>
<form method="post" action="/vapp?name=`+html.EscapeString(name)+`" onsubmit="return confirm('Reset to the copy verb installed?')">
<input type="hidden" name="act" value="reset"><button type="submit">Reset to installed</button>
</form>
<p><a href="/vapps">Back</a></p></div>`))
}

func (s *srv) unlockForm(name, cfg, flash string) string {
	msg := ""
	if flash != "" {
		msg = `<p class="flash">` + html.EscapeString(flash) + `</p>`
	}
	return msg + `<div class="card"><h1>Confirm access</h1>
<p>Viewing <code>` + html.EscapeString(name) + `</code> (<code>` + html.EscapeString(cfg) + `</code>) requires your password and Authenticator code again.</p>
<p class="muted">An email warning is sent when this succeeds.</p>
<form method="post" action="/vapp?name=` + html.EscapeString(name) + `"><input type="hidden" name="act" value="unlock">
<label>Password</label><input type="password" name="password" required>
<label>Authenticator code</label><input name="code" inputmode="numeric" required>
<p><button>Unlock config</button></p></form>
<p><a href="/vapps">Back</a></p></div>`
}

func (s *srv) warnConfigMail(ss *session, name, cfg string) {
	db := s.c["db"]
	email, _, _, _, _, _, _ := sqlUser(db, ss.User)
	if email == "" {
		return
	}
	body := fmt.Sprintf("Warning: %s opened vapp config %s (%s) at %s.\nIf this was not you, change that password and review the file.\n",
		ss.User, name, cfg, time.Now().Format(time.RFC3339))
	cmd := exec.Command("/usr/bin/mail", "-s", "Vapp config access: "+name, email)
	cmd.Stdin = strings.NewReader(body)
	_ = cmd.Run()
}

func (s *srv) oauth(w http.ResponseWriter, r *http.Request) {
	ss := s.get(r)
	if ss == nil {
		http.Redirect(w, r, "/login", http.StatusSeeOther)
		return
	}
	prov := strings.TrimPrefix(r.URL.Path, "/oauth/")
	fmt.Fprint(w, page("Verb admin", ss.User, `<div class="card"><h2>Link `+html.EscapeString(prov)+`</h2>
<p class="muted">Set client IDs in <code>verbadmin.conf</code> for Apple, Google, Facebook, LinkedIn, GitHub, and X. Linking stores the subject against this PAM user; it never becomes a Linux account.</p></div>`))
}

func page(title, who, body string) string {
	nav := `<a href="/">Home</a><a href="/vapps">Vapps</a><a href="/inkmail">inkMail</a><a href="/logout">Logout</a>`
	if who != "" {
		nav = `<span class="muted">` + html.EscapeString(who) + `</span> ` + nav
	}
	return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>` + title + `</title>
<style>` + css + `</style></head><body class="has-pen"><header><strong>` + html.EscapeString(title) + `</strong><nav>` + nav + `</nav></header><main>` + body + `</main></body></html>`
}

const css = `
:root { --ink:#0e1218; --paper:#e8e4d9; --accent:#c4a35a; --muted:#8a8680; --card:#161c26cc; }
*{box-sizing:border-box}html,body{margin:0;min-height:100%}
body{font:16px/1.45 "Source Sans 3","Segoe UI",sans-serif;color:var(--paper);background-color:var(--ink);background-repeat:no-repeat;background-position:center;background-attachment:fixed;background-size:min(62vw,62vh)}
body.has-pen{background-image:url("/pen-logo.svg")}
a{color:var(--accent);text-decoration:none}
header{padding:1.2rem 1.5rem;border-bottom:1px solid #ffffff14;display:flex;gap:1rem;align-items:center;flex-wrap:wrap;background:#0e1218e6}
header nav a{margin-right:1rem;color:var(--paper)}
main{max-width:920px;margin:2rem auto;padding:0 1rem 3rem}
.card{background:var(--card);backdrop-filter:blur(8px);border:1px solid #ffffff14;border-radius:12px;padding:1.25rem 1.4rem;margin:1rem 0}
label{display:block;margin:.6rem 0 .2rem;color:var(--muted);font-size:.85rem}
input,button,textarea{font:inherit;padding:.45rem .6rem;border-radius:6px;border:1px solid #ffffff22;background:#0e1218;color:var(--paper)}
button{background:var(--accent);color:var(--ink);border:0;cursor:pointer;font-weight:650}
.muted{color:var(--muted)}.flash{background:#c4a35a22;border:1px solid var(--accent);padding:.7rem 1rem;border-radius:8px}
pre{white-space:pre-wrap}.login{max-width:400px;margin:10vh auto}
`