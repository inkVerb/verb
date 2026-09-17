package ui

import "html"

const CSS = `
:root { --ink:#0e1218; --paper:#e8e4d9; --accent:#c4a35a; --muted:#8a8680; --card:#161c26cc; }
*{box-sizing:border-box}
html,body{margin:0;min-height:100%}
body{
  font:16px/1.45 "Source Sans 3", "Segoe UI", sans-serif;
  color:var(--pw-fg, var(--paper));
  background-color:var(--pw-page, var(--ink));
  background-repeat:no-repeat;background-position:center center;
  background-attachment:fixed;background-size:min(62vw,62vh);
}
body.has-pen{background-image:url("pen-logo.svg")}
a{color:var(--accent);text-decoration:none}a:hover{text-decoration:underline}
header{padding:1.2rem 1.5rem;border-bottom:1px solid #ffffff14;display:flex;gap:1rem;align-items:center;flex-wrap:wrap;background:var(--pw-head, #0e1218e6)}
header strong{letter-spacing:.08em;text-transform:uppercase;font-size:.9rem}
header nav{display:flex;flex-wrap:wrap;align-items:center;column-gap:0.3em;row-gap:0.3em}
header nav a{color:var(--paper);padding:0.2em 0.8em;border-radius:4px}
header nav a:hover{background:#f71771;color:#ccc;text-decoration:none}
main{max-width:920px;margin:2rem auto;padding:0 1rem 3rem}
.card{background:var(--card);backdrop-filter:blur(8px);border:1px solid #ffffff14;border-radius:12px;padding:1.25rem 1.4rem;margin:1rem 0}
label{display:block;margin:.6rem 0 .2rem;color:var(--muted);font-size:.85rem}
input,select,button,textarea{font:inherit;padding:.45rem .6rem;border-radius:6px;border:1px solid #ffffff22;background:#0e1218;color:var(--paper)}
button,.btn{background:var(--accent);color:var(--ink);border:0;cursor:pointer;font-weight:650}
.muted{color:var(--muted)}.flash{background:#c4a35a22;border:1px solid var(--accent);padding:.7rem 1rem;border-radius:8px}
table{width:100%;border-collapse:collapse}
td,th{text-align:left;padding:.4rem .3rem;border-bottom:1px solid #ffffff10}
.login{max-width:360px;margin:12vh auto}h1,h2,h3{font-weight:600}
.lt_button,.set_gray,input[type=submit].lt_button,input[type=submit].set_gray{
  cursor:pointer;color:#ccc;border:none;border-radius:8px;padding:0.8em 1em;
  text-align:center;text-decoration:none;display:inline-block;
  font:1em/1.5em "monospace","Courier New",monospace;background-color:#222;
}
.lt_button{background-color:#444}
.lt_button:hover,.set_gray:hover{background-color:#f71771;color:#ccc}
.noticegreen,p.noticegreen,span.noticegreen{color:#448844}
.noticered,p.noticered,span.noticered{color:#884444}
input.noticegreen,textarea.noticegreen,select.noticegreen{border:2px solid #448844;box-sizing:border-box}
input.noticered,textarea.noticered,select.noticered{border:2px solid #884444;box-sizing:border-box}
.field-hint{display:block;margin-top:0.25em}
.noticehide{-webkit-animation:fadeOut 8s;animation:fadeOut 8s;animation-fill-mode:forwards}
@keyframes fadeOut{0%{opacity:1}99%{opacity:0.01}100%{opacity:0}}
span.noticered a,p.noticered a{color:#f71771}
.login-id{display:flex;flex-direction:column;align-items:flex-start;gap:0.45em;margin:0.4em 0 1.2em}
.login-or{margin:0.9em 0 0.5em;letter-spacing:0.08em}
a.id-btn,button.id-btn{
  display:flex;align-items:center;justify-content:flex-start;gap:0.7em;width:14.5em;box-sizing:border-box;
  cursor:pointer;background-color:#222;color:#ccc;border:none;border-radius:8px;padding:0.7em 1em;
  text-align:left;text-decoration:none;font:1em/1.4em "monospace","Courier New",monospace;
}
a.id-btn:hover,button.id-btn:hover{background-color:#f71771;color:#ccc;text-decoration:none}
.id-ico{display:inline-flex;width:1.25em;height:1.25em;flex:0 0 1.25em;align-items:center;justify-content:center;color:#ccc}
.id-svg{width:1.25em;height:1.25em;display:block}
.id-lab{display:block}
.id-check-svg{color:#6cbb6c;width:1.15em;height:1.15em}
table.id-link{width:auto;max-width:100%;border-collapse:collapse;margin:0.6em 0 1.4em}
table.id-link th,table.id-link td{text-align:left;vertical-align:middle;padding:0.55em 0.75em 0.55em 0;border-bottom:1px solid #444}
table.oauth-list{table-layout:fixed;width:25.6em;max-width:100%}
table.oauth-list col.oauth-col-who{width:11em}
table.oauth-list col.oauth-col-mark{width:4.6em}
table.oauth-list col.oauth-col-act{width:10em}
table.oauth-list td.id-act{width:10em;text-align:center}
table.oauth-list td.id-act button{min-width:9em;box-sizing:border-box}
table.oauth-list td.id-mark{width:4.6em;text-align:center}
table.pk-list{table-layout:fixed;width:36em;max-width:100%}
table.pk-list td{vertical-align:middle;height:3.1em;box-sizing:border-box}
table.pk-list form.pk-row{display:grid;grid-template-columns:minmax(0,1fr) 4.6em 1.6em;align-items:center;column-gap:0.45em;margin:0;height:2em}
table.pk-list .pk-who,table.pk-list .pk-act{display:grid;grid-template-columns:1fr;grid-template-rows:2em;height:2em;min-width:0}
table.pk-list .pk-who .pk-label,table.pk-list .pk-who .pk-input{grid-area:1/1;width:100%;max-width:100%;box-sizing:border-box;min-width:0;height:2em;max-height:2em}
table.pk-list .pk-who .pk-label{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;line-height:2em}
table.pk-list .pk-who .pk-input{font:1em/2em Verdana,Arial,Helvetica,sans-serif;padding:0 0.45em;margin:0;border:1px solid #666;border-radius:4px}
table.pk-list .pk-act .pk-edit,table.pk-list .pk-act .pk-save{grid-area:1/1;width:4.6em;box-sizing:border-box;text-align:center}
table.pk-list .pk-label[hidden],table.pk-list .pk-input[hidden],table.pk-list .pk-edit[hidden],table.pk-list .pk-save[hidden]{display:none!important}
table.pk-list .pk-cancel{width:1.5em;height:1.5em;padding:0;border-radius:50%;border:1.5px solid #888;background:transparent;color:#ccc;font:700 1em/1 Verdana,Arial,Helvetica,sans-serif;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;visibility:hidden;box-sizing:border-box}
table.pk-list .pk-row.is-editing .pk-cancel{visibility:visible}
.pw-login-toggle{display:flex;align-items:center;gap:0.75em;flex-wrap:wrap}
.totp-qr{display:inline-block;background:#fff;padding:0.55em;border-radius:8px;margin:0.5em 0 0.8em;line-height:0}
.totp-qr svg{display:block;width:15em;height:15em}
.sans{font-family:Verdana,Arial,Helvetica,sans-serif}
.dk,.lt{color:#777}
p.field{margin:0.7em 0}
pre{white-space:pre-wrap}
`

func EmptyList() string {
	return `<p class="lt sans"><b>Nothing yet</b></p>`
}

func Page(title, nav, body, base, theme, extraHead string, pen bool) string {
	cls := ""
	if pen {
		cls = ` class="has-pen"`
	}
	baseTag := ""
	if base != "" {
		baseTag = `<base href="` + html.EscapeString(base) + `">`
	}
	themeLink := ""
	if theme != "" {
		themeLink = `<link rel="stylesheet" id="pw-theme-css" href="static/themes/` + html.EscapeString(theme) + `.css">`
	}
	return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">` +
		baseTag + `<title>` + html.EscapeString(title) + `</title><style>` + CSS + `</style>` + themeLink + extraHead +
		`</head><body` + cls + `><header><strong>` + html.EscapeString(title) + `</strong><nav>` + nav + `</nav></header><main>` + body + `</main></body></html>`
}

func BrandIcon(which string) string {
	svg := ""
	switch which {
	case "passkey":
		svg = `<svg class="id-svg" viewBox="0 0 24 24" aria-hidden="true"><circle cx="8.2" cy="12" r="3.6" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="8.2" cy="12" r="1.1" fill="currentColor"/><path fill="currentColor" d="M11.6 11.15h9.2v1.7h-2.05V16h-1.9v-3.15h-1.4V16h-1.9v-3.15h-1.95z"/></svg>`
	case "google":
		svg = `<svg class="id-svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12.2 11.15v2.55h4.08c-.2 1.05-1.18 2.92-4.08 2.92-2.46 0-4.47-2.04-4.47-4.55s2.01-4.55 4.47-4.55c1.4 0 2.34.6 2.88 1.14l1.97-1.91C15.7 5.4 14.12 4.7 12.2 4.7 8.22 4.7 5 7.9 5 11.92S8.22 19.15 12.2 19.15c3.96 0 6.55-2.78 6.55-6.7 0-.45-.05-.78-.12-1.12H12.2z"/></svg>`
	case "github":
		svg = `<svg class="id-svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 2C6.48 2 2 6.58 2 12.26c0 4.52 2.87 8.35 6.84 9.71.5.1.68-.22.68-.49 0-.24-.01-.87-.01-1.71-2.78.62-3.37-1.37-3.37-1.37-.45-1.18-1.11-1.5-1.11-1.5-.91-.64.07-.63.07-.63 1 .07 1.53 1.06 1.53 1.06.9 1.57 2.36 1.11 2.94.85.09-.66.35-1.11.63-1.37-2.22-.26-4.56-1.14-4.56-5.07 0-1.12.39-2.03 1.03-2.75-.1-.26-.45-1.3.1-2.7 0 0 .84-.27 2.75 1.05A9.3 9.3 0 0 1 12 6.84c.85 0 1.71.12 2.51.34 1.9-1.32 2.74-1.05 2.74-1.05.55 1.4.21 2.44.1 2.7.64.72 1.03 1.63 1.03 2.75 0 3.94-2.34 4.8-4.58 5.06.36.32.68.94.68 1.9 0 1.37-.01 2.47-.01 2.8 0 .27.18.59.69.49A10.05 10.05 0 0 0 22 12.26C22 6.58 17.52 2 12 2z"/></svg>`
	case "check":
		svg = `<svg class="id-svg id-check-svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" d="M5 12.5 10 17.5 19 6.5"/></svg>`
	}
	return `<span class="id-ico">` + svg + `</span>`
}

func IDButton(kind, label, href, attrs string) string {
	inner := BrandIcon(kind) + `<span class="id-lab">` + html.EscapeString(label) + `</span>`
	if href != "" {
		a := attrs
		if a != "" {
			a = " " + a
		}
		return `<a class="id-btn" href="` + html.EscapeString(href) + `"` + a + `>` + inner + `</a>`
	}
	a := attrs
	if a != "" {
		a = " " + a
	}
	return `<button type="button" class="id-btn"` + a + `>` + inner + `</button>`
}
