package main

import (
	"encoding/json"
	"fmt"
	"html"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"inkverb/inkmail/internal/form"
	"inkverb/inkmail/internal/ident"
	"inkverb/inkmail/internal/totp"
	"inkverb/inkmail/internal/ui"
	"inkverb/inkmail/internal/webauthn"
)

func (s *srv) login(w http.ResponseWriter, r *http.Request) {
	se, _ := s.readSess(r)
	if s.authed(se) {
		http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
		return
	}
	errMsg := ""
	needTotp := se.Pending
	a := s.id.Get()

	if r.Method == "POST" && r.FormValue("passkey") != "" {
		chal := se.WAChal
		u := s.id.Get()
		ok := false
		for _, pk := range u.Passkeys {
			if webauthn.B64u(webauthn.B64d(pk.CredentialID)) == strings.TrimRight(r.FormValue("id"), "=") || pk.CredentialID == r.FormValue("id") || webauthn.B64u(webauthn.B64d(r.FormValue("id"))) == webauthn.B64u(webauthn.B64d(pk.CredentialID)) {
				if webauthn.Assert(r.FormValue("id"), r.FormValue("clientData"), r.FormValue("authData"), r.FormValue("sig"), chal, pk.PublicKey) {
					ok = true
					break
				}
			}
		}
		if ok {
			if u.TotpEnabled {
				se.User = u.Username
				se.Pending = true
				se.Via = "passkey"
				se.WAChal = ""
				s.putSess(w, se)
				needTotp = true
			} else {
				se.User = u.Username
				se.Pending = false
				se.Via = "passkey"
				se.WAChal = ""
				s.putSess(w, se)
				http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
				return
			}
		} else {
			errMsg = "Passkey failed."
		}
	} else if r.Method == "POST" && r.FormValue("totp_code") != "" {
		if !s.csrfOK(r, se) {
			errMsg = "Bad request."
			needTotp = true
		} else if se.Pending && totp.Verify(a.TotpSecret, r.FormValue("totp_code")) {
			se.Pending = false
			s.putSess(w, se)
			http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
			return
		} else {
			errMsg = "That code did not match."
			needTotp = true
		}
	} else if r.Method == "POST" && r.FormValue("username") != "" {
		if !s.csrfOK(r, se) {
			errMsg = "Bad request."
		} else {
			user := strings.TrimSpace(r.FormValue("username"))
			pass := r.FormValue("pass")
			if (user == a.Username || user == a.Email) && s.id.PasswordOn() && ident.CheckPass(a.Pass, pass) {
				if a.TotpEnabled {
					se.User = a.Username
					se.Pending = true
					se.Via = "password"
					s.putSess(w, se)
					needTotp = true
				} else {
					se.User = a.Username
					se.Pending = false
					se.Via = "password"
					s.putSess(w, se)
					http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
					return
				}
			} else {
				errMsg = "The username and password do not match those on file."
			}
		}
	}

	if se.CSRF == "" {
		se.CSRF = ident.NewCSRF()
		s.putSess(w, se)
	}

	if !s.id.HasPassword() && !s.authed(se) && !needTotp {
		s.setup(w, r, se)
		return
	}

	body := `<div class="card login"><h1>inkMail</h1>`
	if errMsg != "" {
		body += `<p class="sans noticered">` + html.EscapeString(errMsg) + `</p>`
	}
	if needTotp {
		body += `<h3>Authenticator</h3><form method="post">` + s.csrfField(se) +
			`<p class="field sans"><label for="totp_code">Code</label><input name="totp_code" id="totp_code" inputmode="numeric" autocomplete="one-time-code" required></p>` +
			`<p><input type="submit" class="set_gray" value="Verify"></p></form>`
	} else {
		body += `<h3>Login Options</h3>
<form method="post">` + s.csrfField(se) + `
<p class="sans">Username<br><input name="username" required autocomplete="username"></p>
<p class="sans">Password<br><input type="password" name="pass" required autocomplete="current-password"></p>
<p><input type="submit" class="set_gray" value="Log in"></p></form>
<p class="sans dk login-or">OR</p><div class="login-id">` +
			ui.IDButton("passkey", "Passkey", "", `id="pkbtn"`)
		oc := s.oauthCfg(r)
		for p, lab := range oc.Providers() {
			body += ui.IDButton(p, lab, "oauth?p="+p, "")
		}
		body += `</div>
<p class="muted">Or sign in through the verb (or rink) admin SSO.</p>
<script>document.getElementById("pkbtn").onclick=function(){pwPasskeyLogin("passkey-options");};</script>`
	}
	body += `</div>`
	fmt.Fprint(w, s.page("inkMail", body, se, ""))
}

func (s *srv) setup(w http.ResponseWriter, r *http.Request, se ident.Session) {
	f := form.New()
	msg := ""
	if r.Method == "POST" && r.FormValue("setup") == "1" {
		if !s.csrfOK(r, se) {
			msg = `<p class="noticered">Bad request.</p>`
		} else {
			f.Grab(r, "pass1", "pass2")
			p1, p2 := f.Get("pass1"), f.Get("pass2")
			if len(p1) < 8 || p1 != p2 {
				f.Fail("pass1", "Passwords must match and be at least 8 characters.")
				f.Fail("pass2", "Passwords must match and be at least 8 characters.")
			}
			if f.OK() {
				_ = s.id.Update(func(a *ident.Admin) {
					a.Pass = ident.HashPass(p1)
					a.PassLogin = true
				})
				se.User = s.id.Get().Username
				se.Pending = false
				s.putSess(w, se)
				http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
				return
			}
		}
	}
	if se.CSRF == "" {
		se.CSRF = ident.NewCSRF()
		s.putSess(w, se)
	}
	body := `<div class="card login"><h1>Set a password</h1>` + msg +
		`<p class="sans">First-run: choose a password for this operator.</p>
<form method="post">` + s.csrfField(se) + `<input type="hidden" name="setup" value="1">
<p class="sans">New<br>` + f.Input("pass1", "password", "required") + `</p>
<p class="sans">Confirm<br>` + f.Input("pass2", "password", "required") + `</p>
<p><input type="submit" class="lt_button" value="Set password"></p></form></div>`
	fmt.Fprint(w, s.page("inkMail", body, se, ""))
}

func (s *srv) logout(w http.ResponseWriter, r *http.Request) {
	s.clearSess(w)
	http.SetCookie(w, &http.Cookie{Name: "inkmail_sso", Value: "", Path: "/", MaxAge: -1})
	http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
}

func (s *srv) locker(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	f := form.New()
	msg := ""
	a := s.id.Get()
	if r.Method == "POST" && s.csrfOK(r, se) {
		if r.FormValue("save_contact") == "1" {
			f.Grab(r, "name", "email")
			name := f.Get("name")
			email := strings.ToLower(f.Get("email"))
			f.Put("email", email)
			if name == "" {
				f.Fail("name", "Name is required.")
			}
			if email == "" || !strings.Contains(email, "@") {
				f.Fail("email", "Enter a valid email address.")
			}
			if f.OK() {
				_ = s.id.Update(func(ad *ident.Admin) {
					ad.Name = name
					ad.Email = email
				})
				msg = `<p class="sans noticegreen">Saved.</p>`
				f = form.New()
				a = s.id.Get()
			}
		} else if r.FormValue("save_theme") == "1" {
			tid := r.FormValue("theme")
			if strings.HasPrefix(tid, "theme-") {
				if _, err := os.Stat(filepath.Join("web/static/themes", tid+".css")); err == nil {
					_ = s.id.Update(func(ad *ident.Admin) { ad.Theme = tid })
					msg = `<p class="sans noticegreen">Theme saved.</p>`
					a = s.id.Get()
				}
			}
		}
	}
	if !f.Bad() {
		f.Put("name", a.Name)
		f.Put("email", a.Email)
	}
	themes := []string{"theme-dusk-desk", "theme-twilight-write", "theme-city-night", "theme-cream-write", "theme-pink-dust", "theme-99"}
	themeForm := `<h3>Theme</h3><form method="post" class="sans">` + s.csrfField(se) + `<input type="hidden" name="save_theme" value="1">`
	cur := a.Theme
	if cur == "" {
		cur = "theme-dusk-desk"
	}
	for _, tid := range themes {
		ck := ""
		if cur == tid {
			ck = " checked"
		}
		themeForm += `<p class="field"><label><input type="radio" name="theme" value="` + html.EscapeString(tid) + `"` + ck + `> ` + html.EscapeString(tid) + `</label></p>`
	}
	themeForm += `<p><input type="submit" class="lt_button" value="Save theme"></p></form>`
	body := `<div class="card"><h2>My Locker</h2>` + msg +
		`<form method="post" class="sans">` + s.csrfField(se) + `<input type="hidden" name="save_contact" value="1">
<p class="field">Name<br>` + f.Input("name", "text", `maxlength="80" required`) + `</p>
<p class="field">Email<br>` + f.Input("email", "email", `maxlength="120" required`) + `</p>
<p><input type="submit" class="lt_button" value="Save"></p></form>` + themeForm +
		`<p><a class="set_gray" href="password">Password</a> <a class="set_gray" href="security">Security</a></p></div>`
	fmt.Fprint(w, s.page("inkMail", body, se, ""))
}

func (s *srv) password(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	a := s.id.Get()
	f := form.New()
	msg := ""
	noPass := !s.id.PasswordOn()
	if r.Method == "POST" && s.csrfOK(r, se) {
		keys := []string{"pass1", "pass2"}
		if !noPass {
			keys = []string{"current", "pass1", "pass2"}
		}
		f.Grab(r, keys...)
		if !noPass && !ident.CheckPass(a.Pass, f.Get("current")) {
			f.Fail("current", "Current password is incorrect.")
		}
		p1, p2 := f.Get("pass1"), f.Get("pass2")
		if len(p1) < 8 || p1 != p2 {
			f.Fail("pass1", "New passwords must match and be at least 8 characters.")
			f.Fail("pass2", "New passwords must match and be at least 8 characters.")
		}
		if f.OK() {
			_ = s.id.Update(func(ad *ident.Admin) {
				ad.Pass = ident.HashPass(p1)
				ad.PassLogin = true
			})
			msg = `<p class="sans noticegreen">Password changed.</p>`
			noPass = false
			f = form.New()
		}
	}
	body := `<div class="card"><h2>Password</h2>` + msg + `<form method="post">` + s.csrfField(se)
	if !noPass {
		body += `<p class="sans">Current<br>` + f.Input("current", "password", "required") + `</p>`
	}
	body += `<p class="sans">New<br>` + f.Input("pass1", "password", "required") + `</p>
<p class="sans">Confirm<br>` + f.Input("pass2", "password", "required") + `</p>
<p><input type="submit" class="lt_button" value="` + map[bool]string{true: "Set password", false: "Change password"}[noPass] + `"></p></form>
<p class="sans dk">Disable password login from <a href="security">Security</a> after a passkey and a linked login are on. Contact lives on <a href="locker">Locker</a>.</p></div>`
	fmt.Fprint(w, s.page("inkMail", body, se, ""))
}

func (s *srv) security(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	a := s.id.Get()
	tf := form.New()
	if r.Method == "POST" && s.csrfOK(r, se) {
		switch {
		case r.FormValue("totp_start") != "":
			se.TotpPend = totp.Secret()
			s.putSess(w, se)
		case r.FormValue("totp_confirm") != "" && se.TotpPend != "":
			tf.Grab(r, "code")
			if totp.Verify(se.TotpPend, tf.Get("code")) {
				_ = s.id.Update(func(ad *ident.Admin) {
					ad.TotpSecret = se.TotpPend
					ad.TotpEnabled = true
				})
				se.TotpPend = ""
				s.putSess(w, se)
				tf = form.New()
			} else {
				tf.Fail("code", "That code did not match.")
			}
		case r.FormValue("totp_off") != "":
			_ = s.id.Update(func(ad *ident.Admin) {
				ad.TotpSecret = ""
				ad.TotpEnabled = false
			})
		case r.FormValue("id") != "" && r.FormValue("spki") != "":
			spki := webauthn.B64d(r.FormValue("spki"))
			pk := ident.Passkey{
				ID: ident.NewID(), CredentialID: r.FormValue("id"),
				PublicKey: webauthn.SPKIToPEM(spki), Name: r.FormValue("name"),
				CreatedAt: time.Now().UTC().Format(time.RFC3339),
			}
			if pk.Name == "" {
				pk.Name = "Passkey"
			}
			_ = s.id.Update(func(ad *ident.Admin) { ad.Passkeys = append(ad.Passkeys, pk) })
			http.Redirect(w, r, s.basePath()+"security", http.StatusSeeOther)
			return
		case r.FormValue("rename_pk") != "":
			id := r.FormValue("rename_pk")
			name := strings.TrimSpace(r.FormValue("pk_name"))
			if name == "" {
				name = "Passkey"
			}
			_ = s.id.Update(func(ad *ident.Admin) {
				for i := range ad.Passkeys {
					if ad.Passkeys[i].ID == id {
						ad.Passkeys[i].Name = name
					}
				}
			})
		case r.FormValue("del_pk") != "":
			id := r.FormValue("del_pk")
			_ = s.id.Update(func(ad *ident.Admin) {
				if !ad.PassLogin && len(ad.Passkeys) < 2 && len(ad.OAuth) == 0 {
					return
				}
				out := ad.Passkeys[:0]
				for _, pk := range ad.Passkeys {
					if pk.ID != id {
						out = append(out, pk)
					}
				}
				ad.Passkeys = out
			})
		}
		a = s.id.Get()
	}

	body := `<div class="card"><h2>Security</h2>
<p class="sans dk"><a href="locker">Locker</a> · <a href="password">Password</a></p>
<h3>Authenticator (TOTP)</h3>`
	if a.TotpEnabled {
		body += `<p class="sans noticegreen">Authenticator is on.</p>
<form method="post">` + s.csrfField(se) + `<input type="submit" name="totp_off" class="set_gray" value="Turn off"></form>`
	} else if se.TotpPend != "" {
		uri := totp.URI(se.TotpPend, a.Username, "inkMail")
		body += `<p class="sans">Scan this with your authenticator app, or type the secret below.</p>
<div class="totp-qr" id="totp-qr" data-otpauth="` + html.EscapeString(uri) + `"></div>
<p class="sans totp-secret"><code>` + html.EscapeString(se.TotpPend) + `</code></p>
<form method="post">` + s.csrfField(se) + `
<p class="field sans"><label for="totp_code">Code</label>` + tf.Input("code", "text", `id="totp_code" inputmode="numeric" autocomplete="one-time-code" required`) + `
 <input type="submit" name="totp_confirm" class="lt_button" value="Confirm"></p></form>
<script src="static/qrcodegen.js"></script><script>pwDrawTotpQr("totp-qr");</script>`
	} else {
		body += `<form method="post">` + s.csrfField(se) + `<input type="submit" name="totp_start" class="lt_button" value="Set up authenticator"></form>`
	}

	body += `<h3>Passkeys</h3>
<p class="sans dk">Works over https; platform (Apple, Google, etc) or hardware key (YubiKey, etc).</p>
<p><button type="button" class="lt_button" id="pkadd">Add a passkey</button></p>`
	if len(a.Passkeys) == 0 {
		body += ui.EmptyList()
	} else {
		body += `<table class="id-link pk-list"><colgroup><col><col><col></colgroup><tbody>`
		for _, pk := range a.Passkeys {
			body += `<tr><td class="pk-name"><form method="post" class="pk-row">` + s.csrfField(se) +
				`<input type="hidden" name="rename_pk" value="` + html.EscapeString(pk.ID) + `">
<span class="pk-who"><span class="pk-label sans">` + html.EscapeString(pk.Name) + `</span>
<input type="text" class="pk-input" name="pk_name" value="` + html.EscapeString(pk.Name) + `" maxlength="80" hidden aria-label="Passkey name"></span>
<span class="pk-act"><button type="button" class="lt_button pk-edit" onclick="pwPkEdit(this)">Edit</button>
<input type="submit" class="lt_button pk-save" value="Save" hidden></span>
<button type="button" class="pk-cancel" onclick="pwPkCancel(this)" title="Cancel" aria-label="Cancel edit">×</button>
</form></td><td class="sans dk">` + html.EscapeString(pk.CreatedAt) + `</td><td>
<form method="post" style="display:inline">` + s.csrfField(se) + `<input type="hidden" name="del_pk" value="` + html.EscapeString(pk.ID) + `">
<input type="submit" class="set_gray" value="Remove"></form></td></tr>`
		}
		body += `</tbody></table>`
	}

	oc := s.oauthCfg(r)
	have := map[string]bool{}
	for _, o := range a.OAuth {
		have[o.Provider] = true
	}
	rows := ""
	for _, p := range []string{"google", "github"} {
		lab := map[string]string{"google": "Google", "github": "GitHub"}[p]
		on := have[p]
		if !on && !oc.Enabled(p) {
			continue
		}
		rows += `<tr><td class="id-who">` + ui.BrandIcon(p) + `<span class="id-lab">` + lab + `</span></td>`
		mark := "&nbsp;"
		if on {
			mark = ui.BrandIcon("check")
		}
		rows += `<td class="id-mark">` + mark + `</td><td class="id-act">`
		if on {
			rows += `<button type="button" class="set_gray" data-oauth="` + p + `" data-act="disconnect" title="Stop using this login">Disconnect</button>`
		} else {
			rows += `<button type="button" class="lt_button" data-oauth="` + p + `" data-act="connect" title="Link this login">Connect</button>`
		}
		rows += `</td></tr>`
	}
	if rows != "" {
		body += `<h3>Linked logins</h3>
<table class="id-link oauth-list" id="oauth-list" data-csrf="` + html.EscapeString(se.CSRF) + `"><colgroup><col class="oauth-col-who"><col class="oauth-col-mark"><col class="oauth-col-act"></colgroup><tbody>` + rows + `</tbody></table>
<script>pwBindOauthLinks("#oauth-list");</script>`
	}

	if len(a.Passkeys) > 0 && len(a.OAuth) > 0 {
		ck := ""
		if !s.id.PasswordOn() {
			ck = " checked"
		}
		body += `<form method="post" id="nopwform" class="sans pw-login-toggle" action="ajax/save-pass-login" onsubmit="return false;">` + s.csrfField(se) +
			`<label><input type="checkbox" name="disable_password" id="disable_password" value="1"` + ck + `> Disable password login</label>
<span id="pw_login_saved"></span></form>
<script>pwBindPassLogin("disable_password","pw_login_saved","ajax/save-pass-login");</script>`
	}
	body += `</div>
<script>document.getElementById("pkadd").onclick=function(){pwPasskeyRegister("passkey-create","security",` + jsonString(se.CSRF) + `);};</script>`
	fmt.Fprint(w, s.page("inkMail", body, se, `<script src="static/qrcodegen.js"></script>`))
}

func jsonString(s string) string {
	b, _ := json.Marshal(s)
	return string(b)
}

func (s *srv) pkOptions(w http.ResponseWriter, r *http.Request) {
	se, _ := s.readSess(r)
	chal := randBytes(32)
	se.WAChal = webauthn.B64u(chal)
	if se.CSRF == "" {
		se.CSRF = ident.NewCSRF()
	}
	s.putSess(w, se)
	var ids []string
	if s.authed(se) {
		for _, pk := range s.id.Get().Passkeys {
			ids = append(ids, pk.CredentialID)
		}
	}
	jsonWrite(w, webauthn.OptionsGet(s.host(r), chal, ids), 200)
}

func (s *srv) pkCreate(w http.ResponseWriter, r *http.Request) {
	se, ok := s.need(w, r)
	if !ok {
		return
	}
	chal := randBytes(32)
	se.WAChal = webauthn.B64u(chal)
	s.putSess(w, se)
	a := s.id.Get()
	disp := a.Name
	if disp == "" {
		disp = a.Username
	}
	jsonWrite(w, webauthn.OptionsCreate(s.host(r), "inkMail", a.Username, disp, []byte(a.Username), chal), 200)
}

func (s *srv) ajaxOauth(w http.ResponseWriter, r *http.Request) {
	se, ok := s.readSess(r)
	if !ok || !s.authed(se) {
		jsonWrite(w, map[string]any{"ok": false, "error": "auth"}, 401)
		return
	}
	if r.Method != "POST" || !s.csrfOK(r, se) {
		jsonWrite(w, map[string]any{"ok": false, "error": "csrf"}, 400)
		return
	}
	p := r.FormValue("unlink_oauth")
	if p != "google" && p != "github" {
		jsonWrite(w, map[string]any{"ok": false, "error": "Unknown login."}, 400)
		return
	}
	err := ""
	_ = s.id.Update(func(ad *ident.Admin) {
		if !ad.PassLogin && len(ad.Passkeys) == 0 && len(ad.OAuth) < 2 {
			err = "Keep at least one way in."
			return
		}
		out := ad.OAuth[:0]
		for _, o := range ad.OAuth {
			if o.Provider != p {
				out = append(out, o)
			}
		}
		ad.OAuth = out
	})
	if err != "" {
		jsonWrite(w, map[string]any{"ok": false, "error": err}, 400)
		return
	}
	jsonWrite(w, map[string]any{"ok": true, "provider": p, "linked": false}, 200)
}

func (s *srv) ajaxPassLogin(w http.ResponseWriter, r *http.Request) {
	se, ok := s.readSess(r)
	if !ok || !s.authed(se) {
		jsonWrite(w, map[string]any{"ok": false, "error": "auth"}, 401)
		return
	}
	if r.Method != "POST" || !s.csrfOK(r, se) {
		jsonWrite(w, map[string]any{"ok": false, "error": "csrf"}, 400)
		return
	}
	if !s.id.CanDisablePass() {
		jsonWrite(w, map[string]any{"ok": false, "error": "Need a passkey and a linked login first."}, 400)
		return
	}
	off := r.FormValue("disable_password") != "" && r.FormValue("disable_password") != "0"
	if off {
		_ = s.id.Update(func(ad *ident.Admin) { ad.PassLogin = false })
		jsonWrite(w, map[string]any{"ok": true, "msg": "Saved", "off": true}, 200)
		return
	}
	if !s.id.HasPassword() {
		jsonWrite(w, map[string]any{
			"ok": false, "error": "Set a password first.",
			"error_html": `Set a <a href="password">password</a> first.`, "off": true,
		}, 400)
		return
	}
	_ = s.id.Update(func(ad *ident.Admin) { ad.PassLogin = true })
	jsonWrite(w, map[string]any{"ok": true, "msg": "Saved", "off": false}, 200)
}

func (s *srv) oauth(w http.ResponseWriter, r *http.Request) {
	se, _ := s.readSess(r)
	p := r.URL.Query().Get("p")
	if p == "" {
		p = r.FormValue("p")
	}
	link := r.URL.Query().Get("link") != "" || r.FormValue("link") != ""
	popup := r.URL.Query().Get("popup") != "" || r.FormValue("popup") != ""
	oc := s.oauthCfg(r)

	popupDone := func(ok bool, provider, err string) {
		payload, _ := json.Marshal(map[string]any{"ok": ok, "provider": provider, "error": err})
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(w, `<!doctype html><html><body><script>(function(){var d=%s;try{if(window.opener)window.opener.postMessage({inkmailoauth:1,ok:!!d.ok,provider:d.provider,error:d.error||""},window.location.origin);}catch(e){}window.close();})();</script><p>You can close this window.</p></body></html>`, payload)
	}

	if code := r.URL.Query().Get("code"); code != "" {
		state := r.URL.Query().Get("state")
		if se.OAuthState == "" || state != se.OAuthState {
			if se.OAuthPop {
				popupDone(false, se.OAuthProv, "State mismatch.")
				return
			}
			http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
			return
		}
		prov := se.OAuthProv
		wasLink := se.OAuthLink
		wasPop := se.OAuthPop
		se.OAuthState, se.OAuthProv, se.OAuthLink, se.OAuthPop = "", "", false, false
		prof, err := oc.Profile(prov, code)
		if err != nil || prof == nil || prof.Sub == "" {
			if wasPop {
				popupDone(false, prov, "Could not read that account.")
				return
			}
			http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
			return
		}
		a := s.id.Get()
		found := false
		for _, o := range a.OAuth {
			if o.Provider == prov && o.Subject == prof.Sub {
				found = true
				break
			}
		}
		if wasLink {
			if !s.authed(se) {
				if wasPop {
					popupDone(false, prov, "Sign in first to link.")
					return
				}
				http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
				return
			}
			if !found {
				_ = s.id.Update(func(ad *ident.Admin) {
					ad.OAuth = append(ad.OAuth, ident.OAuth{Provider: prov, Subject: prof.Sub, Email: prof.Email})
				})
			}
			s.putSess(w, se)
			if wasPop {
				popupDone(true, prov, "")
				return
			}
			http.Redirect(w, r, s.basePath()+"security", http.StatusSeeOther)
			return
		}
		if !found {
			if wasPop {
				popupDone(false, prov, "No inkMail account for that login. Sign in and connect it from Security.")
				return
			}
			http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
			return
		}
		if a.TotpEnabled {
			se.User = a.Username
			se.Pending = true
			se.Via = "oauth"
			s.putSess(w, se)
			if wasPop {
				popupDone(false, prov, "Authenticator required.")
				return
			}
			http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
			return
		}
		se.User = a.Username
		se.Pending = false
		se.Via = "oauth"
		s.putSess(w, se)
		if wasPop {
			popupDone(true, prov, "")
			return
		}
		http.Redirect(w, r, s.basePath(), http.StatusSeeOther)
		return
	}

	if p != "google" && p != "github" {
		http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
		return
	}
	if !oc.Enabled(p) {
		if popup {
			popupDone(false, p, "That sign-in is not set up on this site.")
			return
		}
		http.Redirect(w, r, s.basePath()+"login", http.StatusSeeOther)
		return
	}
	st := ident.RandHex(16)
	se.OAuthState = st
	se.OAuthProv = p
	se.OAuthLink = link
	se.OAuthPop = popup
	if se.CSRF == "" {
		se.CSRF = ident.NewCSRF()
	}
	s.putSess(w, se)
	http.Redirect(w, r, oc.StartURL(p, st), http.StatusSeeOther)
}
