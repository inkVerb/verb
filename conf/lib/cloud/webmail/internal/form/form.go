// Package form keeps accepted posted fields (green) and clears failed ones (red).
// Login pages do not use this.
package form

import (
	"html"
	"net/http"
	"strings"
)

type Form struct {
	values map[string]string
	errors map[string]string
	posted bool
}

func New() *Form {
	return &Form{values: map[string]string{}, errors: map[string]string{}}
}

func (f *Form) Grab(r *http.Request, keys ...string) *Form {
	f.posted = true
	if r.PostForm == nil {
		_ = r.ParseForm()
	}
	for _, k := range keys {
		f.values[k] = strings.TrimSpace(r.FormValue(k))
	}
	return f
}

func (f *Form) Fail(field, msg string)  { f.errors[field] = msg }
func (f *Form) OK() bool                { return f.posted && len(f.errors) == 0 }
func (f *Form) Bad() bool               { return len(f.errors) > 0 }
func (f *Form) Get(field string) string { return f.values[field] }
func (f *Form) Put(field, v string)     { f.values[field] = v }

func (f *Form) Keep(field string) string {
	if _, bad := f.errors[field]; bad {
		return ""
	}
	return f.values[field]
}

func (f *Form) Class(field string) string {
	if !f.posted {
		return ""
	}
	if _, bad := f.errors[field]; bad {
		return "noticered"
	}
	return "noticegreen"
}

func (f *Form) Note(field string) string {
	msg, ok := f.errors[field]
	if !ok {
		return ""
	}
	return `<span class="sans noticered field-hint">` + html.EscapeString(msg) + `</span>`
}

func (f *Form) Input(name, typ, attrs string) string {
	cls := f.Class(name)
	b := `<input type="` + html.EscapeString(typ) + `" name="` + html.EscapeString(name) + `"`
	if !strings.Contains(strings.ToLower(attrs), "id=") {
		b += ` id="` + html.EscapeString(name) + `"`
	}
	if cls != "" {
		b += ` class="` + cls + `"`
	}
	b += ` value="` + html.EscapeString(f.Keep(name)) + `"`
	if attrs != "" {
		b += " " + attrs
	}
	return b + `>` + f.Note(name)
}
