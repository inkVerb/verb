/* inkMail — passkeys, oauth AJAX, totp QR, passkey edit (99 lessons) */
(function () {
  window.pwBindPassLogin = function (cbId, msgId, postTo) {
    var cb = document.getElementById(cbId);
    var box = document.getElementById(msgId);
    if (!cb || !cb.form) return;
    cb.addEventListener('change', function () {
      var fd = new FormData(cb.form);
      fd.append('ajax', '1');
      fd.set('disable_password', cb.checked ? '1' : '0');
      var x = new XMLHttpRequest();
      x.open('POST', postTo);
      x.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      x.onload = function () {
        var j = null;
        try { j = JSON.parse(x.responseText || ''); } catch (e) { j = null; }
        if (j && j.ok) {
          if (typeof j.off === 'boolean') cb.checked = j.off;
          if (box) {
            box.innerHTML = '';
            void box.offsetWidth;
            box.innerHTML = '<span class="noticegreen noticehide sans">' + (j.msg || 'Saved') + '</span>';
          }
          return;
        }
        cb.checked = !cb.checked;
        if (typeof j.off === 'boolean') cb.checked = j.off;
        if (box) {
          var err = (j && j.error_html) ? j.error_html : ((j && j.error) || 'Save failed');
          box.innerHTML = '<span class="noticered sans">' + err + '</span>';
        }
      };
      x.onerror = function () {
        cb.checked = !cb.checked;
        if (box) box.innerHTML = '<span class="noticered sans">Save failed</span>';
      };
      x.send(fd);
    });
  };

  var pwOauthCheck = '<span class="id-ico"><svg class="id-svg id-check-svg" viewBox="0 0 24 24" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" d="M5 12.5 10 17.5 19 6.5"/></svg></span>';

  function pwOauthSetRow(table, provider, linked) {
    var btn = table.querySelector('[data-oauth="' + provider + '"]');
    if (!btn) return;
    var row = btn.closest('tr');
    if (!row) return;
    var mark = row.querySelector('.id-mark');
    var act = row.querySelector('.id-act');
    if (mark) mark.innerHTML = linked ? pwOauthCheck : '&nbsp;';
    if (act) {
      if (linked) {
        act.innerHTML = '<button type="button" class="set_gray" data-oauth="' + provider + '" data-act="disconnect" title="Stop using this login">Disconnect</button>';
      } else {
        act.innerHTML = '<button type="button" class="lt_button" data-oauth="' + provider + '" data-act="connect" title="Link this login">Connect</button>';
      }
    }
  }

  window.pwBindOauthLinks = function (tableSel) {
    var table = document.querySelector(tableSel);
    if (!table || table.getAttribute('data-oauth-bound')) return;
    table.setAttribute('data-oauth-bound', '1');
    window.addEventListener('message', function (ev) {
      if (ev.origin !== window.location.origin) return;
      var d = ev.data;
      if (!d || !d.inkmailoauth) return;
      if (d.ok) pwOauthSetRow(table, d.provider, true);
    });
    table.addEventListener('click', function (ev) {
      var btn = ev.target.closest ? ev.target.closest('[data-oauth]') : null;
      if (!btn || !table.contains(btn)) return;
      ev.preventDefault();
      var p = btn.getAttribute('data-oauth');
      var act = btn.getAttribute('data-act');
      if (act === 'connect') {
        var w = 520, h = 640;
        var left = window.screenX + Math.max(0, (window.outerWidth - w) / 2);
        var top = window.screenY + Math.max(0, (window.outerHeight - h) / 2);
        window.open(
          'oauth?p=' + encodeURIComponent(p) + '&link=1&popup=1',
          'inkmailoauth',
          'popup=yes,width=' + w + ',height=' + h + ',left=' + left + ',top=' + top
        );
        return;
      }
      if (act === 'disconnect') {
        var fd = new FormData();
        fd.append('_csrf', table.getAttribute('data-csrf') || '');
        fd.append('ajax', '1');
        fd.append('unlink_oauth', p);
        var x = new XMLHttpRequest();
        x.open('POST', 'ajax/save-oauth');
        x.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        x.onload = function () {
          var j = null;
          try { j = JSON.parse(x.responseText || ''); } catch (e) { j = null; }
          if (j && j.ok) pwOauthSetRow(table, p, false);
        };
        x.send(fd);
      }
    });
  };

  function b64uToBuf(s) {
    s = s.replace(/-/g, '+').replace(/_/g, '/');
    while (s.length % 4) s += '=';
    var bin = atob(s);
    var u = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) u[i] = bin.charCodeAt(i);
    return u.buffer;
  }
  function bufToB64u(buf) {
    var u = new Uint8Array(buf);
    var s = '';
    for (var i = 0; i < u.length; i++) s += String.fromCharCode(u[i]);
    return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  window.pwPasskeyRegister = async function (optUrl, saveUrl, csrf) {
    var opt = await (await fetch(optUrl, { credentials: 'same-origin' })).json();
    opt.challenge = b64uToBuf(opt.challenge);
    opt.user.id = b64uToBuf(opt.user.id);
    var cred = await navigator.credentials.create({ publicKey: opt });
    var spki = cred.response.getPublicKey();
    var body = new URLSearchParams();
    body.set('_csrf', csrf);
    body.set('id', bufToB64u(cred.rawId));
    body.set('spki', bufToB64u(spki));
    body.set('name', 'Passkey');
    await fetch(saveUrl, { method: 'POST', body: body, credentials: 'same-origin' });
    location.reload();
  };

  window.pwPasskeyLogin = async function (optUrl) {
    var opt = await (await fetch(optUrl, { credentials: 'same-origin' })).json();
    opt.challenge = b64uToBuf(opt.challenge);
    if (opt.allowCredentials) {
      opt.allowCredentials.forEach(function (c) { c.id = b64uToBuf(c.id); });
    }
    var cred = await navigator.credentials.get({ publicKey: opt });
    var fd = new FormData();
    fd.set('passkey', '1');
    fd.set('id', bufToB64u(cred.rawId));
    fd.set('clientData', bufToB64u(cred.response.clientDataJSON));
    fd.set('authData', bufToB64u(cred.response.authenticatorData));
    fd.set('sig', bufToB64u(cred.response.signature));
    var x = await fetch('login', { method: 'POST', body: fd, credentials: 'same-origin' });
    if (x.redirected) { location.href = x.url; return; }
    location.href = 'login';
  };

  window.pwDrawTotpQr = function (elId) {
    var el = document.getElementById(elId);
    if (!el || typeof qrcodegen === 'undefined') return;
    var uri = el.getAttribute('data-otpauth') || '';
    if (!uri) return;
    var qr = qrcodegen.QrCode.encodeText(uri, qrcodegen.QrCode.Ecc.MEDIUM);
    var n = qr.size, q = 4, dim = n + 2 * q;
    var parts = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + dim + ' ' + dim + '" width="240" height="240" shape-rendering="crispEdges" aria-hidden="true">'];
    parts.push('<rect width="' + dim + '" height="' + dim + '" fill="#ffffff"/>');
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (qr.getModule(x, y)) {
          parts.push('<rect x="' + (x + q) + '" y="' + (y + q) + '" width="1" height="1" fill="#111111"/>');
        }
      }
    }
    parts.push('</svg>');
    el.innerHTML = parts.join('');
  };

  window.pwPkEdit = function (btn) {
    var form = btn.closest ? btn.closest('.pk-row') : btn.form;
    if (!form) return;
    var rows = document.querySelectorAll('.pk-row.is-editing');
    for (var i = 0; i < rows.length; i++) {
      if (rows[i] !== form) pwPkClose(rows[i]);
    }
    pwPkOpen(form);
  };
  function pwPkOpen(form) {
    form.classList.add('is-editing');
    var label = form.querySelector('.pk-label');
    var input = form.querySelector('.pk-input');
    var edit = form.querySelector('.pk-edit');
    var save = form.querySelector('.pk-save');
    if (label) label.hidden = true;
    if (edit) edit.hidden = true;
    if (save) save.hidden = false;
    if (input) {
      input.setAttribute('data-orig', input.value);
      input.hidden = false;
      input.focus();
      input.select();
    }
  }
  function pwPkClose(form) {
    form.classList.remove('is-editing');
    var label = form.querySelector('.pk-label');
    var input = form.querySelector('.pk-input');
    var edit = form.querySelector('.pk-edit');
    var save = form.querySelector('.pk-save');
    if (label) label.hidden = false;
    if (input) input.hidden = true;
    if (edit) edit.hidden = false;
    if (save) save.hidden = true;
  }
  window.pwPkCancel = function (btn) {
    var form = btn.closest ? btn.closest('.pk-row') : btn.form;
    if (!form) return;
    var input = form.querySelector('.pk-input');
    var orig = input ? input.getAttribute('data-orig') : null;
    if (input && orig !== null) input.value = orig;
    pwPkClose(form);
  };
})();
