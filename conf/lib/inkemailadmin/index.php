<?php
/**
 * inkEmail Admin — Maddy control plane (not Roundcube, not PFA).
 * Login is a single SysAdmin password (701bio-style session). All mutations
 * go through sudo /opt/verb/serfs/inkemail* (www cannot run serfs as root).
 */
declare(strict_types=1);
session_start();

$CONF = '/opt/verb/conf/inkemailadmin.conf';
$cfg = is_file($CONF) ? (function_exists('parse_ini_file') ? parse_ini_file($CONF) : []) : [];
$passfile = $cfg['passfile'] ?? '/opt/verb/conf/inkemailadmin.pass';
$hash = is_file($passfile) ? trim((string)file_get_contents($passfile)) : '';

function h(string $s): string { return htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function need_login(): void {
    if (empty($_SESSION['iea'])) {
        header('Location: ?view=login');
        exit;
    }
}
function serf(string $name, array $args = []): array {
    $allow = [
        'inkemaildomain','inkemaildeldomain','inkemailbox','inkemaildelbox',
        'inkemailalias','inkemaildelalias','inkemailshowdomains','inkemailshowboxes',
        'inkemailunsubscribelist','inkemailunsubscriberemove','inkemailaddscriptfilter',
        'inkdnsaddbimi','inkemailsetbimi','setbimi','inkmail',
    ];
    if (!in_array($name, $allow, true)) {
        return [1, 'unknown serf'];
    }
    $bin = '/opt/verb/serfs/' . $name;
    if (!is_executable($bin)) {
        return [1, 'unknown serf'];
    }
    $cmd = '/usr/bin/sudo -n ' . escapeshellarg($bin);
    foreach ($args as $a) {
        $cmd .= ' ' . escapeshellarg((string)$a);
    }
    $out = [];
    $code = 0;
    exec($cmd . ' 2>&1', $out, $code);
    return [$code, implode("\n", $out)];
}
function flash(?string $set = null): string {
    if ($set !== null) { $_SESSION['flash'] = $set; return ''; }
    $m = $_SESSION['flash'] ?? '';
    unset($_SESSION['flash']);
    return $m;
}

$view = $_GET['view'] ?? 'home';
$flash = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $act = $_POST['act'] ?? '';
    if ($act === 'login') {
        $pw = (string)($_POST['password'] ?? '');
        if ($hash !== '' && password_verify($pw, $hash)) {
            $_SESSION['iea'] = 1;
            header('Location: ?view=home');
            exit;
        }
        $flash = 'Login failed.';
        $view = 'login';
    } elseif ($act === 'logout') {
        $_SESSION = [];
        session_destroy();
        header('Location: ?view=login');
        exit;
    } else {
        need_login();
        if (!hash_equals($_SESSION['csrf'] ?? '', (string)($_POST['csrf'] ?? ''))) {
            flash('Bad CSRF token.');
            header('Location: ?view=home');
            exit;
        }
        if ($act === 'adddomain') {
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            [, $o] = serf('inkemaildomain', [$d]);
            serf('inkemailaddscriptfilter', ['unsubscribe', $d]);
            serf('inkdnsaddbimi', [$d]);
            flash($o ?: "Domain $d added.");
            header('Location: ?view=domains'); exit;
        }
        if ($act === 'deldomain') {
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            [, $o] = serf('inkemaildeldomain', [$d]);
            flash($o ?: "Domain $d removed.");
            header('Location: ?view=domains'); exit;
        }
        if ($act === 'addbox') {
            $u = strtolower(trim((string)($_POST['user'] ?? '')));
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            [, $o] = serf('inkemailbox', [$u, $d]);
            flash($o ?: "Mailbox $u@$d created.");
            header('Location: ?view=boxes'); exit;
        }
        if ($act === 'delbox') {
            $e = strtolower(trim((string)($_POST['email'] ?? '')));
            [, $o] = serf('inkemaildelbox', [$e]);
            flash($o ?: "Deleted $e.");
            header('Location: ?view=boxes'); exit;
        }
        if ($act === 'addalias') {
            $u = strtolower(trim((string)($_POST['user'] ?? '')));
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            $g = strtolower(trim((string)($_POST['goto'] ?? '')));
            [, $o] = serf('inkemailalias', [$u, $d, $g]);
            flash($o ?: "Alias $u@$d → $g");
            header('Location: ?view=aliases'); exit;
        }
        if ($act === 'delalias') {
            $u = strtolower(trim((string)($_POST['user'] ?? '')));
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            $g = strtolower(trim((string)($_POST['goto'] ?? '')));
            [, $o] = serf('inkemaildelalias', [$u, $d, $g]);
            flash($o ?: 'Alias removed.');
            header('Location: ?view=aliases'); exit;
        }
        if ($act === 'unsubremove') {
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            $e = strtolower(trim((string)($_POST['email'] ?? '')));
            [, $o] = serf('inkemailunsubscriberemove', [$d, $e]);
            flash($o ?: 'Removed.');
            header('Location: ?view=unsubscribe&domain=' . rawurlencode($d)); exit;
        }
        if ($act === 'bimi') {
            $d = strtolower(trim((string)($_POST['domain'] ?? '')));
            if (!is_uploaded_file($_FILES['svg']['tmp_name'] ?? '')) {
                flash('No SVG uploaded.');
            } else {
                $raw = (string)file_get_contents($_FILES['svg']['tmp_name']);
                if (stripos($raw, '<svg') === false) {
                    flash('Not an SVG.');
                } else {
                    $vip = '/srv/vip/files/' . $d . '.bimi.svg';
                    @mkdir('/srv/vip/files', 0750, true);
                    if (@file_put_contents($vip, $raw) === false) {
                        flash('Could not write VIP drop.');
                    } else {
                        [, $o] = serf('setbimi', [$d, 'vip']);
                        flash($o ?: "Wrote https://$d/bimi.svg via ink set bimi -p vip");
                    }
                }
            }
            header('Location: ?view=bimi'); exit;
        }
    }
}

if ($view !== 'login') { need_login(); }
if (empty($_SESSION['csrf'])) { $_SESSION['csrf'] = bin2hex(random_bytes(16)); }
$csrf = $_SESSION['csrf'];
$flash = $flash ?: flash();

function domains(): array {
    [, $o] = serf('inkemailshowdomains');
    $list = [];
    foreach (preg_split('/\s+/', trim($o)) as $d) {
        if ($d !== '' && strpos($d, '.') !== false) { $list[] = $d; }
    }
    sort($list);
    return $list;
}

?><!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>inkEmail Admin</title>
<style>
:root { --ink:#1a1a18; --paper:#f6f1e7; --accent:#c45c26; --line:#d9d0c3; --ok:#2d6a4f; }
* { box-sizing:border-box; }
body { margin:0; font:16px/1.45 "Iowan Old Style", Palatino, serif; background:var(--paper); color:var(--ink); }
header { display:flex; gap:1rem; align-items:center; padding:.8rem 1.2rem; background:var(--ink); color:var(--paper); }
header a { color:var(--paper); text-decoration:none; }
nav { display:flex; gap:.8rem; flex-wrap:wrap; }
main { max-width:52rem; margin:1.5rem auto; padding:0 1rem 3rem; }
.flash { background:#fff3cd; border:1px solid #e0c36a; padding:.6rem .8rem; margin-bottom:1rem; white-space:pre-wrap; }
form.card, .card { background:#fff; border:1px solid var(--line); padding:1rem; margin:1rem 0; }
label { display:block; margin:.4rem 0 .15rem; font-size:.9rem; }
input[type=text], input[type=password], input[type=email], input[type=file], select {
  width:100%; padding:.45rem .5rem; border:1px solid var(--line); background:#fff;
}
button, .btn { cursor:pointer; background:var(--accent); color:#fff; border:0; padding:.45rem .9rem; }
table { width:100%; border-collapse:collapse; }
th, td { text-align:left; padding:.35rem .4rem; border-bottom:1px solid var(--line); }
.row { display:flex; gap:.5rem; flex-wrap:wrap; align-items:flex-end; }
.row > * { flex:1; min-width:8rem; }
.muted { color:#666; font-size:.9rem; }
</style>
</head>
<body>
<header>
  <strong>inkEmail</strong>
  <?php if (!empty($_SESSION['iea'])): ?>
  <nav>
    <a href="?view=home">Home</a>
    <a href="?view=domains">Domains</a>
    <a href="?view=boxes">Mailboxes</a>
    <a href="?view=aliases">Aliases</a>
    <a href="?view=unsubscribe">Unsubscribe</a>
    <a href="?view=bimi">BIMI</a>
  </nav>
  <form method="post" style="margin-left:auto"><input type="hidden" name="act" value="logout"><button>Logout</button></form>
  <?php endif; ?>
</header>
<main>
<?php if ($flash): ?><div class="flash"><?= h($flash) ?></div><?php endif; ?>

<?php if ($view === 'login'): ?>
<form class="card" method="post">
  <input type="hidden" name="act" value="login">
  <h1>SysAdmin login</h1>
  <p class="muted">Maddy control plane. Roundcube is webmail only.</p>
  <label>Password</label>
  <input type="password" name="password" required autofocus>
  <p><button>Sign in</button></p>
</form>

<?php elseif ($view === 'home'): ?>
<div class="card">
  <h1>Maddy mail</h1>
  <p>Domains, boxes, aliases, List-Unsubscribe, and BIMI. Mutations run <code>inkemail*</code> serfs via sudo. This is not PostfixAdmin and not Roundcube.</p>
  <ul>
    <li><a href="?view=domains">Mail domains</a></li>
    <li><a href="?view=boxes">Mailboxes</a></li>
    <li><a href="?view=aliases">Aliases</a></li>
    <li><a href="?view=unsubscribe">Unsubscribe list</a></li>
    <li><a href="?view=bimi">BIMI logo (domain.tld/bimi.svg)</a></li>
  </ul>
</div>

<?php elseif ($view === 'domains'):
$doms = domains(); ?>
<div class="card">
  <h1>Domains</h1>
  <form method="post" class="row">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="adddomain">
    <div><label>Add domain</label><input type="text" name="domain" placeholder="example.com" required></div>
    <div><button>Add</button></div>
  </form>
  <table>
    <tr><th>Domain</th><th></th></tr>
    <?php foreach ($doms as $d): ?>
    <tr>
      <td><?= h($d) ?></td>
      <td>
        <form method="post" onsubmit="return confirm('Remove <?= h($d) ?>?')">
          <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
          <input type="hidden" name="act" value="deldomain">
          <input type="hidden" name="domain" value="<?= h($d) ?>">
          <button>Remove</button>
        </form>
      </td>
    </tr>
    <?php endforeach; ?>
  </table>
</div>

<?php elseif ($view === 'boxes'):
$doms = domains();
[, $boxes] = serf('inkemailshowboxes');
?>
<div class="card">
  <h1>Mailboxes</h1>
  <form method="post" class="row">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="addbox">
    <div><label>User</label><input type="text" name="user" required></div>
    <div><label>Domain</label>
      <select name="domain"><?php foreach ($doms as $d): ?><option><?= h($d) ?></option><?php endforeach; ?></select>
    </div>
    <div><button>Create (password in /srv/email/pass)</button></div>
  </form>
  <pre class="muted"><?= h($boxes) ?></pre>
  <form method="post" class="row">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="delbox">
    <div><label>Delete address</label><input type="email" name="email" required></div>
    <div><button>Delete</button></div>
  </form>
</div>

<?php elseif ($view === 'aliases'):
$doms = domains();
$alist = is_file('/etc/maddy/conf.d/aliases.conf') ? (string)file_get_contents('/etc/maddy/conf.d/aliases.conf') : '';
?>
<div class="card">
  <h1>Aliases</h1>
  <form method="post" class="row">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="addalias">
    <div><label>User</label><input type="text" name="user" required></div>
    <div><label>Domain</label>
      <select name="domain"><?php foreach ($doms as $d): ?><option><?= h($d) ?></option><?php endforeach; ?></select>
    </div>
    <div><label>Forward to</label><input type="email" name="goto" required></div>
    <div><button>Add</button></div>
  </form>
  <pre class="muted"><?= h($alist) ?></pre>
  <form method="post" class="row">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="delalias">
    <div><label>User</label><input type="text" name="user" required></div>
    <div><label>Domain</label><input type="text" name="domain" required></div>
    <div><label>Goto</label><input type="email" name="goto" required></div>
    <div><button>Remove</button></div>
  </form>
</div>

<?php elseif ($view === 'unsubscribe'):
$doms = domains();
$d = strtolower(trim((string)($_GET['domain'] ?? ($doms[0] ?? ''))));
[, $ul] = $d ? serf('inkemailunsubscribelist', [$d]) : [0, ''];
?>
<div class="card">
  <h1>Unsubscribe</h1>
  <form method="get" class="row">
    <input type="hidden" name="view" value="unsubscribe">
    <div><label>Domain</label>
      <select name="domain" onchange="this.form.submit()"><?php foreach ($doms as $x): ?>
        <option<?= $x===$d?' selected':'' ?>><?= h($x) ?></option>
      <?php endforeach; ?></select>
    </div>
  </form>
  <pre class="muted"><?= h($ul) ?></pre>
  <form method="post" class="row">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="unsubremove">
    <input type="hidden" name="domain" value="<?= h($d) ?>">
    <div><label>Remove address</label><input type="email" name="email" required></div>
    <div><button>Remove</button></div>
  </form>
</div>

<?php elseif ($view === 'bimi'):
$doms = domains();
?>
<div class="card">
  <h1>BIMI</h1>
  <p class="muted">SVG Tiny PS at <code>https://domain.tld/bimi.svg</code>. TXT is <code>default._bimi</code>. WordPress will not rewrite an existing file.</p>
  <form method="post" enctype="multipart/form-data">
    <input type="hidden" name="csrf" value="<?= h($csrf) ?>">
    <input type="hidden" name="act" value="bimi">
    <label>Domain</label>
    <select name="domain"><?php foreach ($doms as $d): ?><option><?= h($d) ?></option><?php endforeach; ?></select>
    <label>bimi.svg</label>
    <input type="file" name="svg" accept="image/svg+xml,.svg" required>
    <p><button>Upload</button></p>
  </form>
</div>
<?php endif; ?>
</main>
</body>
</html>
