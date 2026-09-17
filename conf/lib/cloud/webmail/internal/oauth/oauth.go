package oauth

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

type Profile struct {
	Sub   string
	Email string
	Name  string
}

type Cfg struct {
	GoogleID, GoogleSecret string
	GitHubID, GitHubSecret string
	Callback               string
}

func (c Cfg) Enabled(p string) bool {
	switch p {
	case "google":
		return c.GoogleID != "" && c.GoogleSecret != ""
	case "github":
		return c.GitHubID != "" && c.GitHubSecret != ""
	}
	return false
}

func (c Cfg) Providers() map[string]string {
	out := map[string]string{}
	if c.Enabled("google") {
		out["google"] = "Google"
	}
	if c.Enabled("github") {
		out["github"] = "GitHub"
	}
	return out
}

func (c Cfg) StartURL(p, state string) string {
	if p == "google" {
		q := url.Values{
			"client_id":     {c.GoogleID},
			"redirect_uri":  {c.Callback},
			"response_type": {"code"},
			"scope":         {"openid email profile"},
			"state":         {state},
			"access_type":   {"online"},
		}
		return "https://accounts.google.com/o/oauth2/v2/auth?" + q.Encode()
	}
	q := url.Values{
		"client_id":    {c.GitHubID},
		"redirect_uri": {c.Callback},
		"scope":        {"user:email"},
		"state":        {state},
	}
	return "https://github.com/login/oauth/authorize?" + q.Encode()
}

func (c Cfg) Profile(p, code string) (*Profile, error) {
	cli := &http.Client{Timeout: 20 * time.Second}
	if p == "google" {
		tok, err := postForm(cli, "https://oauth2.googleapis.com/token", url.Values{
			"code":          {code},
			"client_id":     {c.GoogleID},
			"client_secret": {c.GoogleSecret},
			"redirect_uri":  {c.Callback},
			"grant_type":    {"authorization_code"},
		})
		if err != nil {
			return nil, err
		}
		access, _ := tok["access_token"].(string)
		if access == "" {
			return nil, fmt.Errorf("no token")
		}
		info, err := getJSON(cli, "https://openidconnect.googleapis.com/v1/userinfo", access)
		if err != nil {
			return nil, err
		}
		return &Profile{
			Sub:   str(info["sub"]),
			Email: str(info["email"]),
			Name:  first(str(info["name"]), str(info["email"])),
		}, nil
	}
	tok, err := postForm(cli, "https://github.com/login/oauth/access_token", url.Values{
		"code":          {code},
		"client_id":     {c.GitHubID},
		"client_secret": {c.GitHubSecret},
		"redirect_uri":  {c.Callback},
	})
	if err != nil {
		return nil, err
	}
	access, _ := tok["access_token"].(string)
	if access == "" {
		return nil, fmt.Errorf("no token")
	}
	info, err := getJSON(cli, "https://api.github.com/user", access)
	if err != nil {
		return nil, err
	}
	email := str(info["email"])
	if email == "" {
		emails, _ := getJSONArr(cli, "https://api.github.com/user/emails", access)
		for _, e := range emails {
			if b, _ := e["primary"].(bool); b {
				email = str(e["email"])
				break
			}
		}
	}
	return &Profile{
		Sub:   fmt.Sprint(info["id"]),
		Email: email,
		Name:  first(str(info["name"]), str(info["login"])),
	}, nil
}

func str(v any) string {
	if v == nil {
		return ""
	}
	return strings.TrimSpace(fmt.Sprint(v))
}

func first(a, b string) string {
	if a != "" {
		return a
	}
	return b
}

func postForm(cli *http.Client, u string, fields url.Values) (map[string]any, error) {
	req, err := http.NewRequest("POST", u, strings.NewReader(fields.Encode()))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("Accept", "application/json")
	res, err := cli.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	b, _ := io.ReadAll(res.Body)
	var j map[string]any
	if json.Unmarshal(b, &j) != nil {
		vals, _ := url.ParseQuery(string(b))
		j = map[string]any{}
		for k, v := range vals {
			if len(v) > 0 {
				j[k] = v[0]
			}
		}
	}
	return j, nil
}

func getJSON(cli *http.Client, u, token string) (map[string]any, error) {
	req, _ := http.NewRequest("GET", u, nil)
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "inkMail")
	res, err := cli.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	b, _ := io.ReadAll(res.Body)
	var j map[string]any
	if json.Unmarshal(b, &j) != nil {
		return nil, fmt.Errorf("json")
	}
	return j, nil
}

func getJSONArr(cli *http.Client, u, token string) ([]map[string]any, error) {
	req, _ := http.NewRequest("GET", u, nil)
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Accept", "application/json")
	req.Header.Set("User-Agent", "inkMail")
	res, err := cli.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	b, _ := io.ReadAll(res.Body)
	var j []map[string]any
	if json.Unmarshal(b, &j) != nil {
		return nil, fmt.Errorf("json")
	}
	return j, nil
}
