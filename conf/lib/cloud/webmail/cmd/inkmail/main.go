package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
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
)

func main() {
	cfg := flag.String("config", os.Getenv("INKMAIL_CONFIG"), "inkmail config")
	flag.Parse()
	path := *cfg
	if path == "" {
		path = "/etc/inkmail/conf"
	}
	c := load(path)
	s := &srv{c: c}
	mux := http.NewServeMux()
	mux.HandleFunc("/", s.home)
	mux.HandleFunc("/pen-logo.svg", s.logo)
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

type srv struct{ c map[string]string }

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

func (s *srv) authed(r *http.Request) bool {
	// SSO cookie from verb/rink admin, or local session after SSO
	if c, err := r.Cookie("inkmail_sso"); err == nil && s.checkSSO(c.Value) {
		return true
	}
	if c, err := r.Cookie("inkmail"); err == nil && c.Value != "" {
		return true
	}
	return false
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
	if !hmac.Equal([]byte(want), []byte(parts[2])) {
		return false
	}
	// parts[1] is unix expiry
	return true
}

func (s *srv) sso(w http.ResponseWriter, r *http.Request) {
	tok := r.URL.Query().Get("t")
	if !s.checkSSO(tok) {
		http.Error(w, "sso failed", 401)
		return
	}
	http.SetCookie(w, &http.Cookie{Name: "inkmail_sso", Value: tok, Path: "/", HttpOnly: true, SameSite: http.SameSiteLaxMode})
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func (s *srv) need(w http.ResponseWriter, r *http.Request) bool {
	if s.authed(r) {
		return true
	}
	// Local operators on the box: if no SSO yet, allow when request is loopback? No.
	// Gate: show a short note. Verb admin SSO is the login.
	w.WriteHeader(401)
	fmt.Fprint(w, page("inkMail", `<div class="card"><h1>inkMail</h1>
<p>Sign in through the verb (or rink) admin first. Once that session is enrolled, you are signed in here automatically.</p>
<p class="muted">This panel is postfix-maddy agnostic: it runs <code>ink mail</code>.</p></div>`))
	return false
}

func (s *srv) home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	if !s.need(w, r) {
		return
	}
	which, _ := ink("which")
	lock := s.lock()
	note := ""
	if lock != "" {
		note = "<p>Domain lock: <code>" + html.EscapeString(lock) + "</code> (enterprise / pdt module).</p>"
	}
	fmt.Fprint(w, page("inkMail", `<div class="card"><h1>inkMail</h1>`+note+`
<p>Stack: <code>`+html.EscapeString(strings.TrimSpace(which))+`</code></p>
<ul>
<li><a href="/domains">Domains</a></li>
<li><a href="/boxes">Mailboxes</a></li>
<li><a href="/aliases">Aliases</a></li>
<li><a href="/bimi">BIMI (bimi.svg)</a></li>
</ul>
<p class="muted">Roundcube is webmail. This is the control plane. BIMI uploads go to <code>/srv/vip/files/domain.tld.svg</code> then <code>ink set bimi -p vip -d domain.tld</code>.</p>
</div>`))
}

func (s *srv) domains(w http.ResponseWriter, r *http.Request) {
	if !s.need(w, r) {
		return
	}
	flash := ""
	if r.Method == "POST" {
		d := strings.ToLower(strings.TrimSpace(r.FormValue("domain")))
		if !s.allow(d) {
			flash = `<p class="flash">Domain is outside the lock.</p>`
		} else if r.FormValue("act") == "add" {
			out, err := ink("domain", d)
			flash = pre(out, err)
		} else if r.FormValue("act") == "del" {
			out, err := ink("deldomain", d)
			flash = pre(out, err)
		}
	}
	out, err := ink("showdomains")
	fmt.Fprint(w, page("inkMail", flash+formDomain()+pre(out, err)))
}

func formDomain() string {
	return `<div class="card"><h2>Domains</h2>
<form method="post"><input type="hidden" name="act" value="add">
<label>Domain</label><input name="domain" required>
<button>Add</button></form>
<form method="post" style="margin-top:1rem"><input type="hidden" name="act" value="del">
<label>Remove</label><input name="domain" required>
<button>Delete</button></form></div>`
}

func (s *srv) boxes(w http.ResponseWriter, r *http.Request) {
	if !s.need(w, r) {
		return
	}
	flash := ""
	if r.Method == "POST" {
		u := strings.TrimSpace(r.FormValue("user"))
		d := strings.ToLower(strings.TrimSpace(r.FormValue("domain")))
		if !s.allow(d) {
			flash = `<p class="flash">Domain is outside the lock.</p>`
		} else if r.FormValue("act") == "add" {
			out, err := ink("box", u, d)
			flash = pre(out, err)
		} else if r.FormValue("act") == "del" {
			out, err := ink("delbox", u, d)
			flash = pre(out, err)
		}
	}
	out, err := ink("showboxes")
	fmt.Fprint(w, page("inkMail", flash+`<div class="card"><h2>Mailboxes</h2>
<form method="post"><input type="hidden" name="act" value="add">
<label>User</label><input name="user" required>
<label>Domain</label><input name="domain" required>
<button>Create box</button></form>
<form method="post"><input type="hidden" name="act" value="del">
<label>User</label><input name="user" required>
<label>Domain</label><input name="domain" required>
<button>Delete box</button></form></div>`+pre(out, err)))
}

func (s *srv) aliases(w http.ResponseWriter, r *http.Request) {
	if !s.need(w, r) {
		return
	}
	flash := ""
	if r.Method == "POST" {
		u := strings.TrimSpace(r.FormValue("user"))
		d := strings.ToLower(strings.TrimSpace(r.FormValue("domain")))
		e := strings.TrimSpace(r.FormValue("dest"))
		if !s.allow(d) {
			flash = `<p class="flash">Domain is outside the lock.</p>`
		} else if r.FormValue("act") == "add" {
			out, err := ink("alias", u, d, e)
			flash = pre(out, err)
		} else if r.FormValue("act") == "del" {
			out, err := ink("delalias", u, d)
			flash = pre(out, err)
		}
	}
	fmt.Fprint(w, page("inkMail", flash+`<div class="card"><h2>Aliases</h2>
<form method="post"><input type="hidden" name="act" value="add">
<label>Local part</label><input name="user" required>
<label>Domain</label><input name="domain" required>
<label>Forward to</label><input name="dest" required>
<button>Add alias</button></form>
<form method="post"><input type="hidden" name="act" value="del">
<label>Local part</label><input name="user" required>
<label>Domain</label><input name="domain" required>
<button>Delete alias</button></form></div>`))
}

func (s *srv) bimi(w http.ResponseWriter, r *http.Request) {
	if !s.need(w, r) {
		return
	}
	flash := ""
	if r.Method == "POST" {
		d := strings.ToLower(strings.TrimSpace(r.FormValue("domain")))
		if !s.allow(d) {
			flash = `<p class="flash">Domain is outside the lock.</p>`
		} else {
			f, hdr, err := r.FormFile("svg")
			if err != nil {
				flash = `<p class="flash">No SVG uploaded.</p>`
			} else {
				defer f.Close()
				raw, _ := io.ReadAll(f)
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
					}
				}
			}
		}
	}
	fmt.Fprint(w, page("inkMail", flash+`<div class="card"><h2>BIMI</h2>
<p class="muted">SVG Tiny PS served at <code>/domain.tld/bimi.svg</code> on the email TLD host. TXT is <code>default._bimi</code>.</p>
<p class="muted">Upload is written to <code>/srv/vip/files/domain.tld.svg</code>, then <code>ink set bimi -p vip -d domain.tld</code>. The drop is deleted after install.</p>
<form method="post" enctype="multipart/form-data">
<label>Domain</label><input name="domain" required>
<label>bimi.svg</label><input type="file" name="svg" accept="image/svg+xml,.svg" required>
<p><button>Install BIMI</button></p></form></div>`))
}

func pre(out string, err error) string {
	s := html.EscapeString(strings.TrimSpace(out))
	if err != nil {
		return `<p class="flash"><pre>` + s + "\n" + html.EscapeString(err.Error()) + `</pre></p>`
	}
	if s == "" {
		return ""
	}
	return `<div class="card"><pre>` + s + `</pre></div>`
}

func page(title, body string) string {
	nav := `<a href="/">Home</a><a href="/domains">Domains</a><a href="/boxes">Boxes</a><a href="/aliases">Aliases</a><a href="/bimi">BIMI</a>`
	return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>` + title + `</title>
<style>` + css + `</style></head><body class="has-pen">
<header><strong>` + title + `</strong><nav>` + nav + `</nav></header><main>` + body + `</main></body></html>`
}

const css = `
:root { --ink:#0e1218; --paper:#e8e4d9; --accent:#c4a35a; --muted:#8a8680; --card:#161c26cc; }
*{box-sizing:border-box}html,body{margin:0;min-height:100%}
body{font:16px/1.45 "Source Sans 3","Segoe UI",sans-serif;color:var(--paper);background-color:var(--ink);background-repeat:no-repeat;background-position:center;background-attachment:fixed;background-size:min(62vw,62vh)}
body.has-pen{background-image:url("/pen-logo.svg")}
a{color:var(--accent);text-decoration:none}a:hover{text-decoration:underline}
header{padding:1.2rem 1.5rem;border-bottom:1px solid #ffffff14;display:flex;gap:1rem;align-items:center;flex-wrap:wrap;background:#0e1218e6}
header nav a{margin-right:1rem;color:var(--paper)}
main{max-width:920px;margin:2rem auto;padding:0 1rem 3rem}
.card{background:var(--card);backdrop-filter:blur(8px);border:1px solid #ffffff14;border-radius:12px;padding:1.25rem 1.4rem;margin:1rem 0}
label{display:block;margin:.6rem 0 .2rem;color:var(--muted);font-size:.85rem}
input,button{font:inherit;padding:.45rem .6rem;border-radius:6px;border:1px solid #ffffff22;background:#0e1218;color:var(--paper)}
button{background:var(--accent);color:var(--ink);border:0;cursor:pointer;font-weight:650}
.muted{color:var(--muted)}.flash{background:#c4a35a22;border:1px solid var(--accent);padding:.7rem 1rem;border-radius:8px}
pre{white-space:pre-wrap}
`
