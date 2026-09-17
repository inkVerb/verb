package main

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"html"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"inkverb/inkmail/internal/form"
	"inkverb/inkmail/internal/ident"
	"inkverb/inkmail/internal/oauth"
	"inkverb/inkmail/internal/ui"
)

func main() {
	cfg := flag.String("config", os.Getenv("INKMAIL_CONFIG"), "inkmail config")
	flag.Parse()
	path := *cfg
	if path == "" {
		path = "/etc/inkmail/conf"
	}
	c := load(path)
	idPath := c["admin_json"]
	if idPath == "" {
		idPath = "/etc/inkmail/admin.json"
	}
	st, err := ident.Open(idPath)
	if err != nil {
		log.Fatal(err)
	}
	s := &srv{c: c, id: st}
	mux := http.NewServeMux()
	mux.HandleFunc("/", s.root)
	mux.HandleFunc("/login", s.login)
	mux.HandleFunc("/logout", s.logout)
	mux.HandleFunc("/locker", s.locker)
	mux.HandleFunc("/security", s.security)
	mux.HandleFunc("/password", s.password)
	mux.HandleFunc("/oauth", s.oauth)
	mux.HandleFunc("/passkey-options", s.pkOptions)
	mux.HandleFunc("/passkey-create", s.pkCreate)
	mux.HandleFunc("/ajax/save-oauth", s.ajaxOauth)
	mux.HandleFunc("/ajax/save-pass-login", s.ajaxPassLogin)
	mux.HandleFunc("/pen-logo.svg", s.logo)
	mux.HandleFunc("/static/", s.static)
	mux.HandleFunc("/domains", s.domains)
	mux.HandleFunc("/boxes", s.boxes)
	mux.HandleFunc("/aliases", s.aliases)
	mux.HandleFunc("/bimi", s.bimi)
	mux.HandleFunc("/sso", s.sso)
	addr := c["listen"]
	if addr == "" {
		addr = "127.0.0.1:8099"
	}
	log.Printf("inkMail on %s", addr)
	log.Fatal(http.ListenAndServe(addr, mux))
}

type srv struct {
	c  map[string]string
	id *ident.Store
}

func (s *srv) secret() string {
	if v := s.c["sess_secret"]; v != "" {
		return v
	}
	return s.c["sso_secret"]
}

func (s *srv) basePath() string {
	p := s.c["path"]
	if p == "" {
		return "/"
	}
	if !strings.HasSuffix(p, "/") {
		p += "/"
	}
	return p
}

func (s *srv) origin(r *http.Request) string {
	scheme := r.Header.Get("X-Forwarded-Proto")
	if scheme == "" {
		if r.TLS != nil {
			scheme = "https"
		} else {
			scheme = "http"
		}
	}
	host := r.Header.Get("X-Forwarded-Host")
	if host == "" {
		host = r.Host
	}
	return scheme + "://" + host
}

func (s *srv) oauthCfg(r *http.Request) oauth.Cfg {
	return oauth.Cfg{
		GoogleID: s.c["oauth_google_id"], GoogleSecret: s.c["oauth_google_secret"],
		GitHubID: s.c["oauth_github_id"], GitHubSecret: s.c["oauth_github_secret"],
		Callback: s.origin(r) + s.basePath() + "oauth",
	}
}

func (s *srv) host(r *http.Request) string {
	h := r.Header.Get("X-Forwarded-Host")
	if h == "" {
		h = r.Host
	}
	if i := strings.Index(h, ":"); i > 0 {
		h = h[:i]
	}
	return h
}

func (s *srv) readSess(r *http.Request) (ident.Session, bool) {
	c, err := r.Cookie("inkmail")
	if err != nil || c.Value == "" {
		return ident.Session{}, false
	}
	return ident.ReadSess(s.secret(), c.Value)
}

func (s *srv) putSess(w http.ResponseWriter, se ident.Session) {
	if se.Exp == 0 {
		se.Exp = time.Now().Add(12 * time.Hour).Unix()
	}
	if se.CSRF == "" {
		se.CSRF = ident.NewCSRF()
	}
	http.SetCookie(w, &http.Cookie{
		Name: "inkmail", Value: ident.SignSess(s.secret(), se),
		Path: "/", HttpOnly: true, SameSite: http.SameSiteLaxMode,
	})
}

func (s *srv) clearSess(w http.ResponseWriter) {
	http.SetCookie(w, &http.Cookie{Name: "inkmail", Value: "", Path: "/", MaxAge: -1})
}

func (s *srv) csrfOK(r *http.Request, se ident.Session) bool {
	got := r.FormValue("_csrf")
	if got == "" {
		got = r.Header.Get("X-CSRF")
	}
	return se.CSRF != "" && hmac.Equal([]byte(se.CSRF), []byte(got))
}

func (s *srv) csrfField(se ident.Session) string {
	return `<input type="hidden" name="_csrf" value="` + html.EscapeString(se.CSRF) + `">`
}

func (s *srv) authed(se ident.Session) bool {
	return se.User != "" && !se.Pending
}

func (s *srv) nav(se ident.Session) string {
	if !s.authed(se) {
		return `<a href="login">Login</a>`
	}
	return `<a href="./">Home</a><a href="domains">Domains</a><a href="boxes">Boxes</a><a href="aliases">Aliases</a><a href="bimi">BIMI</a><a href="locker">Locker</a><a href="security">Security</a><a href="password">Password</a><a href="logout">Logout</a>`
}

func (s *srv) page(title, body string, se ident.Session, extra string) string {
	theme := ""
	if s.authed(se) {
		theme = s.id.Get().Theme
		if theme == "" {
			theme = "theme-dusk-desk"
		}
	}
	if extra == "" {
		extra = `<script src="static/app.js"></script>`
	} else {
		extra = `<script src="static/app.js"></script>` + extra
	}
	return ui.Page(title, s.nav(se), body, s.basePath(), theme, extra, true)
}

func (s *srv) need(w http.ResponseWriter, r *http.Request) (ident.Session, bool) {
	se, ok := s.readSess(r)
	if ok && s.authed(se) {
		return se, true
	}
	if c, err := r.Cookie("inkmail_sso"); err == nil && s.checkSSO(c.Value) {
		se = ident.Session{User: "admin", CSRF: ident.NewCSRF(), Exp: time.Now().Add(12 * time.Hour).Unix()}
		s.putSess(w, se)
		return se, true
	}
	http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
	return se, false
}

func (s *srv) root(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	a := s.id.Get()
	name := a.Name
	if name == "" {
		name = a.Username
	}
	which, _ := ink("which")
	lock := s.lock()
	note := ""
	if lock != "" {
		note = "<p>Domain lock: <code>" + html.EscapeString(lock) + "</code></p>"
	}
	fmt.Fprint(w, s.page("inkMail", `<div class="card"><h1>inkMail</h1><p class="sans">Hi, `+html.EscapeString(name)+`.</p>`+note+
		`<p>Stack: <code>`+html.EscapeString(strings.TrimSpace(which))+`</code></p>
<ul>
<li><a href="domains">Domains</a></li>
<li><a href="boxes">Mailboxes</a></li>
<li><a href="aliases">Aliases</a></li>
<li><a href="bimi">BIMI (bimi.svg)</a></li>
</ul>
<p><a class="lt_button" href="locker">Locker</a> <a class="set_gray" href="security">Security</a> <a class="set_gray" href="password">Password</a></p>
<p class="muted">Roundcube is webmail. This is the control plane.</p></div>`, se, ""))
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

func (s *srv) static(w http.ResponseWriter, r *http.Request) {
	rel := strings.TrimPrefix(r.URL.Path, "/static/")
	rel = filepath.Clean(rel)
	if strings.HasPrefix(rel, "..") {
		http.NotFound(w, r)
		return
	}
	p := filepath.Join("web/static", rel)
	http.ServeFile(w, r, p)
}

func load(path string) map[string]string {
	m := map[string]string{}
	if path == "" {
		return m
	}
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

func (s *srv) lock() string { return s.c["domain_lock"] }

func (s *srv) allow(domain string) bool {
	lock := s.lock()
	if lock == "" {
		return true
	}
	domain = strings.ToLower(domain)
	return domain == lock || strings.HasSuffix(domain, "."+lock)
}

func ink(args ...string) (string, error) {
	cmd := exec.Command("/opt/verb/serfs/inkmail", args...)
	out, err := cmd.CombinedOutput()
	return string(out), err
}

func (s *srv) checkSSO(tok string) bool {
	sec := s.c["sso_secret"]
	if sec == "" || tok == "" {
		return false
	}
	parts := strings.Split(tok, ".")
	if len(parts) != 3 {
		return false
	}
	msg := parts[0] + "." + parts[1]
	mac := hmac.New(sha256.New, []byte(sec))
	mac.Write([]byte(msg))
	want := hex.EncodeToString(mac.Sum(nil))
	return hmac.Equal([]byte(want), []byte(parts[2]))
}

func (s *srv) sso(w http.ResponseWriter, r *http.Request) {
	tok := r.URL.Query().Get("t")
	if !s.checkSSO(tok) {
		http.Error(w, "sso failed", 401)
		return
	}
	http.SetCookie(w, &http.Cookie{Name: "inkmail_sso", Value: tok, Path: "/", HttpOnly: true, SameSite: http.SameSiteLaxMode})
	se := ident.Session{User: "admin", CSRF: ident.NewCSRF(), Exp: time.Now().Add(12 * time.Hour).Unix()}
	s.putSess(w, se)
	http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
}

func (s *srv) domains(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	flash := ""
	f := form.New()
	if r.Method == "POST" {
		if !s.csrfOK(r, se) {
			flash = `<p class="flash noticered">Bad request.</p>`
		} else {
			f.Grab(r, "domain")
			d := strings.ToLower(f.Get("domain"))
			f.Put("domain", d)
			if d == "" {
				f.Fail("domain", "Domain is required.")
			} else if !s.allow(d) {
				f.Fail("domain", "Domain is outside the lock.")
			}
			if f.OK() {
				if r.FormValue("act") == "add" {
					out, err := ink("domain", d)
					flash = pre(out, err)
				} else if r.FormValue("act") == "del" {
					out, err := ink("deldomain", d)
					flash = pre(out, err)
				}
				f = form.New()
			}
		}
	}
	out, err := ink("showdomains")
	fmt.Fprint(w, s.page("inkMail", flash+`<div class="card"><h2>Domains</h2>
<form method="post">`+s.csrfField(se)+`<input type="hidden" name="act" value="add">
<label>Domain</label>`+f.Input("domain", "text", "required")+`
<button class="lt_button">Add</button></form>
<form method="post" style="margin-top:1rem">`+s.csrfField(se)+`<input type="hidden" name="act" value="del">
<label>Remove</label><input name="domain" required>
<button class="set_gray">Delete</button></form></div>`+listOrPre(out, err), se, ""))
}

func (s *srv) boxes(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	flash := ""
	f := form.New()
	if r.Method == "POST" {
		if !s.csrfOK(r, se) {
			flash = `<p class="flash noticered">Bad request.</p>`
		} else {
			f.Grab(r, "user", "domain")
			u := f.Get("user")
			d := strings.ToLower(f.Get("domain"))
			f.Put("domain", d)
			if u == "" {
				f.Fail("user", "User is required.")
			}
			if d == "" {
				f.Fail("domain", "Domain is required.")
			} else if !s.allow(d) {
				f.Fail("domain", "Domain is outside the lock.")
			}
			if f.OK() {
				if r.FormValue("act") == "add" {
					out, err := ink("box", u, d)
					flash = pre(out, err)
				} else if r.FormValue("act") == "del" {
					out, err := ink("delbox", u, d)
					flash = pre(out, err)
				}
				f = form.New()
			}
		}
	}
	out, err := ink("showboxes")
	fmt.Fprint(w, s.page("inkMail", flash+`<div class="card"><h2>Mailboxes</h2>
<form method="post">`+s.csrfField(se)+`<input type="hidden" name="act" value="add">
<label>User</label>`+f.Input("user", "text", "required")+`
<label>Domain</label>`+f.Input("domain", "text", "required")+`
<button class="lt_button">Create box</button></form>
<form method="post">`+s.csrfField(se)+`<input type="hidden" name="act" value="del">
<label>User</label><input name="user" required>
<label>Domain</label><input name="domain" required>
<button class="set_gray">Delete box</button></form></div>`+listOrPre(out, err), se, ""))
}

func (s *srv) aliases(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	flash := ""
	f := form.New()
	if r.Method == "POST" {
		if !s.csrfOK(r, se) {
			flash = `<p class="flash noticered">Bad request.</p>`
		} else {
			f.Grab(r, "user", "domain", "dest")
			u := f.Get("user")
			d := strings.ToLower(f.Get("domain"))
			e := f.Get("dest")
			f.Put("domain", d)
			if u == "" {
				f.Fail("user", "Local part is required.")
			}
			if d == "" {
				f.Fail("domain", "Domain is required.")
			} else if !s.allow(d) {
				f.Fail("domain", "Domain is outside the lock.")
			}
			if r.FormValue("act") == "add" && e == "" {
				f.Fail("dest", "Forward-to is required.")
			}
			if f.OK() {
				if r.FormValue("act") == "add" {
					out, err := ink("alias", u, d, e)
					flash = pre(out, err)
				} else if r.FormValue("act") == "del" {
					out, err := ink("delalias", u, d)
					flash = pre(out, err)
				}
				f = form.New()
			}
		}
	}
	fmt.Fprint(w, s.page("inkMail", flash+`<div class="card"><h2>Aliases</h2>
<form method="post">`+s.csrfField(se)+`<input type="hidden" name="act" value="add">
<label>Local part</label>`+f.Input("user", "text", "required")+`
<label>Domain</label>`+f.Input("domain", "text", "required")+`
<label>Forward to</label>`+f.Input("dest", "text", "required")+`
<button class="lt_button">Add alias</button></form>
<form method="post">`+s.csrfField(se)+`<input type="hidden" name="act" value="del">
<label>Local part</label><input name="user" required>
<label>Domain</label><input name="domain" required>
<button class="set_gray">Delete alias</button></form></div>`, se, ""))
}

func (s *srv) bimi(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	flash := ""
	f := form.New()
	if r.Method == "POST" {
		if !s.csrfOK(r, se) {
			flash = `<p class="flash noticered">Bad request.</p>`
		} else {
			f.Grab(r, "domain")
			d := strings.ToLower(f.Get("domain"))
			f.Put("domain", d)
			if d == "" {
				f.Fail("domain", "Domain is required.")
			} else if !s.allow(d) {
				f.Fail("domain", "Domain is outside the lock.")
			}
			if f.OK() {
				file, hdr, err := r.FormFile("svg")
				if err != nil {
					flash = `<p class="flash">No SVG uploaded.</p>`
				} else {
					defer file.Close()
					raw, _ := io.ReadAll(file)
					if !strings.Contains(strings.ToLower(string(raw)), "<svg") {
						flash = `<p class="flash">Not an SVG.</p>`
					} else {
						drop := s.c["vip_drop"]
						if drop == "" {
							drop = "/srv/vip/files"
						}
						_ = os.MkdirAll(drop, 0750)
						name := filepath.Join(drop, d+".svg")
						if err := os.WriteFile(name, raw, 0644); err != nil {
							flash = `<p class="flash">` + html.EscapeString(err.Error()) + `</p>`
						} else {
							_ = hdr
							cmd := exec.Command("/opt/verb/serfs/setbimi", d, "vip")
							out, err := cmd.CombinedOutput()
							flash = pre(string(out), err)
							f = form.New()
						}
					}
				}
			}
		}
	}
	fmt.Fprint(w, s.page("inkMail", flash+`<div class="card"><h2>BIMI</h2>
<p class="muted">SVG Tiny PS served at <code>/domain.tld/bimi.svg</code> on the email TLD host. TXT is <code>default._bimi</code>.</p>
<form method="post" enctype="multipart/form-data">`+s.csrfField(se)+`
<label>Domain</label>`+f.Input("domain", "text", "required")+`
<label>bimi.svg</label><input type="file" name="svg" accept="image/svg+xml,.svg" required>
<p><button class="lt_button">Install BIMI</button></p></form></div>`, se, ""))
}

func pre(out string, err error) string {
	txt := html.EscapeString(strings.TrimSpace(out))
	if err != nil {
		return `<p class="flash"><pre>` + txt + "\n" + html.EscapeString(err.Error()) + `</pre></p>`
	}
	if txt == "" {
		return ui.EmptyList()
	}
	return `<div class="card"><pre>` + txt + `</pre></div>`
}

func listOrPre(out string, err error) string {
	if err == nil && strings.TrimSpace(out) == "" {
		return ui.EmptyList()
	}
	return pre(out, err)
}

func jsonWrite(w http.ResponseWriter, data any, code int) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(data)
}

func randBytes(n int) []byte {
	b := make([]byte, n)
	_, _ = rand.Read(b)
	return b
}
