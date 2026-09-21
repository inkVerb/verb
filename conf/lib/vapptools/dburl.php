#!/usr/bin/php
<?php
/**
 * Generic URL rewrite across a MariaDB/MySQL schema.
 * Walks every text/blob/json column; PHP-serialized and JSON values are
 * decoded, rewritten, and re-encoded so string lengths stay valid.
 * Not WordPress-specific (any vapp database).
 *
 *   php dburl.php --db=NAME --user=U --pass=P --old=URL --new=URL
 *   php dburl.php --wp-config=/srv/www/vapps/wp.DOMAIN/wp-config.php --old=URL --new=URL
 */
declare(strict_types=1);

$opt = getopt('', [
    'db:', 'user:', 'pass:', 'host:',
    'wp-config:', 'old:', 'new:',
    'dry-run', 'help',
]);

if (isset($opt['help']) || empty($opt['old']) || empty($opt['new'])) {
    fwrite(STDERR, <<<TXT
Rewrite a URL everywhere in a MariaDB database (serialized PHP + JSON + plain text).

Required:
  --old=URL   Current public URL (http(s)://host or host)
  --new=URL   Destination public URL

Database (either):
  --db= --user= --pass= [--host=localhost]
  --wp-config=PATH   Read DB_* from wp-config.php; rewrite WP_HOME / WP_SITEURL

Optional:
  --dry-run   Print counts; no writes

TXT);
    exit(isset($opt['help']) ? 0 : 5);
}

$oldIn = (string) $opt['old'];
$newIn = (string) $opt['new'];
$dry = isset($opt['dry-run']);
$host = (string) ($opt['host'] ?? 'localhost');

function dburl_canon(string $u): string
{
    $u = trim($u);
    if ($u === '') {
        return '';
    }
    if (!preg_match('#^[a-z][a-z0-9+.-]*://#i', $u)) {
        $u = 'https://' . $u;
    }
    return rtrim($u, '/');
}

function dburl_host(string $u): string
{
    $h = parse_url(dburl_canon($u), PHP_URL_HOST);
    return is_string($h) ? strtolower($h) : '';
}

function dburl_pairs(string $old, string $new): array
{
    $old = dburl_canon($old);
    $new = dburl_canon($new);
    $oh = parse_url($old, PHP_URL_HOST) ?: '';
    $nh = parse_url($new, PHP_URL_HOST) ?: '';
    $os = parse_url($old, PHP_URL_SCHEME) ?: 'https';
    $ns = parse_url($new, PHP_URL_SCHEME) ?: 'https';
    $op = rtrim((string) (parse_url($old, PHP_URL_PATH) ?: ''), '/');
    $np = rtrim((string) (parse_url($new, PHP_URL_PATH) ?: ''), '/');
    $oldBase = $os . '://' . $oh . $op;
    $newBase = $ns . '://' . $nh . $np;
    $list = [
        $oldBase => $newBase,
        $oldBase . '/' => $newBase . '/',
        'http://' . $oh . $op => $newBase,
        'https://' . $oh . $op => $newBase,
        'http://' . $oh . $op . '/' => $newBase . '/',
        'https://' . $oh . $op . '/' => $newBase . '/',
        '//' . $oh . $op => '//' . $nh . $np,
        '//' . $oh . $op . '/' => '//' . $nh . $np . '/',
    ];
    $out = [];
    foreach ($list as $k => $v) {
        if ($k === '' || $k === $v) {
            continue;
        }
        $out[$k] = $v;
        $out[str_replace('/', '\\/', $k)] = str_replace('/', '\\/', $v);
        $out[rawurlencode($k)] = rawurlencode($v);
    }
    uksort($out, static function ($a, $b) {
        return strlen((string) $b) <=> strlen((string) $a);
    });
    return $out;
}

function dburl_apply(string $s, array $pairs): string
{
    foreach ($pairs as $from => $to) {
        if ($from !== '' && str_contains($s, $from)) {
            $s = str_replace($from, $to, $s);
        }
    }
    return $s;
}

function dburl_is_serialized(string $data): bool
{
    $data = trim($data);
    if ($data === 'N;') {
        return true;
    }
    if (!preg_match('/^([adObis]):/', $data, $m)) {
        return false;
    }
    switch ($m[1]) {
        case 's':
            return (bool) preg_match('/^s:\d+:"/', $data);
        case 'a':
        case 'O':
            return (bool) preg_match('/^' . $m[1] . ':\d+:{/', $data);
        case 'b':
        case 'i':
        case 'd':
            return (bool) preg_match('/^' . $m[1] . ':[0-9.E+-]+;/', $data);
    }
    return false;
}

function dburl_walk(mixed $data, array $pairs): mixed
{
    if (is_string($data)) {
        return dburl_apply($data, $pairs);
    }
    if (is_array($data)) {
        $out = [];
        foreach ($data as $k => $v) {
            $nk = is_string($k) ? dburl_apply($k, $pairs) : $k;
            $out[$nk] = dburl_walk($v, $pairs);
        }
        return $out;
    }
    if (is_object($data)) {
        foreach (get_object_vars($data) as $k => $v) {
            $data->{$k} = dburl_walk($v, $pairs);
        }
        return $data;
    }
    return $data;
}

function dburl_value(string $value, array $pairs): string
{
    $changed = dburl_apply($value, $pairs);
    if ($changed === $value && !dburl_is_serialized($value)) {
        $trim = ltrim($value);
        if ($trim === '' || ($trim[0] !== '{' && $trim[0] !== '[')) {
            return $value;
        }
    }
    if (dburl_is_serialized($value)) {
        $un = @unserialize($value);
        if ($un !== false || $value === 'b:0;') {
            return serialize(dburl_walk($un, $pairs));
        }
        $raw = dburl_apply($value, $pairs);
        return preg_replace_callback(
            '/s:(\d+):"(.*?)";/s',
            static function (array $m): string {
                return 's:' . strlen($m[2]) . ':"' . $m[2] . '";';
            },
            $raw
        ) ?? $raw;
    }
    $trim = ltrim($value);
    if ($trim !== '' && ($trim[0] === '{' || $trim[0] === '[')) {
        $json = json_decode($value, true);
        if (json_last_error() === JSON_ERROR_NONE && $json !== null) {
            $flags = JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE;
            if (str_contains($value, '\\/')) {
                $flags = JSON_UNESCAPED_UNICODE;
            }
            return json_encode(dburl_walk($json, $pairs), $flags) ?: $changed;
        }
    }
    return $changed;
}

function dburl_read_wp_config(string $path): array
{
    $c = (string) file_get_contents($path);
    $get = static function (string $key) use ($c): string {
        if (preg_match("/define\s*\(\s*['\"]" . preg_quote($key, '/') . "['\"]\s*,\s*['\"]([^'\"]*)['\"]/i", $c, $m)) {
            return $m[1];
        }
        return '';
    };
    return [
        'raw' => $c,
        'home' => $get('WP_HOME'),
        'siteurl' => $get('WP_SITEURL'),
        'db' => $get('DB_NAME'),
        'user' => $get('DB_USER'),
        'pass' => $get('DB_PASSWORD'),
        'host' => $get('DB_HOST') ?: 'localhost',
        'domain_current' => $get('DOMAIN_CURRENT_SITE'),
    ];
}

function dburl_write_wp_config(string $path, string $new): void
{
    $c = (string) file_get_contents($path);
    $new = dburl_canon($new);
    $repl = static function (string $key, string $url) use (&$c): void {
        $c = preg_replace(
            "/define\s*\(\s*(['\"])" . preg_quote($key, '/') . "\\1\s*,\s*['\"][^'\"]*['\"]\s*\)/",
            "define( '$key', '$url' )",
            $c,
            1
        ) ?? $c;
    };
    $repl('WP_SITEURL', $new);
    $repl('WP_HOME', $new);
    $host = dburl_host($new);
    if ($host !== '' && preg_match("/define\s*\(\s*['\"]DOMAIN_CURRENT_SITE['\"]/", $c)) {
        $c = preg_replace(
            "/define\s*\(\s*(['\"])DOMAIN_CURRENT_SITE\\1\s*,\s*['\"][^'\"]*['\"]\s*\)/",
            "define( 'DOMAIN_CURRENT_SITE', '$host' )",
            $c,
            1
        ) ?? $c;
    }
    $mode = fileperms($path);
    $mode = $mode !== false ? ($mode & 0777) : 0440;
    chmod($path, 0644);
    if (file_put_contents($path, $c) === false) {
        fwrite(STDERR, "Could not write {$path}.\n");
        exit(6);
    }
    chmod($path, $mode);
}

$oldC = dburl_canon($oldIn);
$newC = dburl_canon($newIn);
if ($oldC === '' || $newC === '' || dburl_host($oldC) === '' || dburl_host($newC) === '') {
    fwrite(STDERR, "Need full URLs or hosts for --old and --new.\n");
    exit(5);
}
if ($oldC === $newC) {
    fwrite(STDERR, "Old and new URLs are the same.\n");
    exit(8);
}

$db = (string) ($opt['db'] ?? '');
$user = (string) ($opt['user'] ?? '');
$pass = (string) ($opt['pass'] ?? '');
$wpConfig = (string) ($opt['wp-config'] ?? '');
$cfg = [];

if ($wpConfig !== '') {
    if (!is_file($wpConfig)) {
        fwrite(STDERR, "No wp-config at {$wpConfig}.\n");
        exit(8);
    }
    $cfg = dburl_read_wp_config($wpConfig);
    if ($db === '') {
        $db = $cfg['db'];
        $user = $cfg['user'];
        $pass = $cfg['pass'];
        $host = $cfg['host'] ?: $host;
    }
    $cfgHome = dburl_canon($cfg['home']);
    $cfgSite = dburl_canon($cfg['siteurl']);
    $oldOk = ($oldC === $cfgHome || $oldC === $cfgSite
        || dburl_host($oldC) === dburl_host($cfgHome)
        || dburl_host($oldC) === dburl_host($cfgSite));
    $newOk = ($newC === $cfgHome || $newC === $cfgSite
        || dburl_host($newC) === dburl_host($cfgHome)
        || dburl_host($newC) === dburl_host($cfgSite));
    if (!$oldOk && !$newOk) {
        fwrite(STDERR, "Old URL does not match wp-config WP_HOME/WP_SITEURL.\n");
        fwrite(STDERR, "  WP_HOME    = " . ($cfg['home'] !== '' ? $cfg['home'] : '(unset)') . "\n");
        fwrite(STDERR, "  WP_SITEURL = " . ($cfg['siteurl'] !== '' ? $cfg['siteurl'] : '(unset)') . "\n");
        fwrite(STDERR, "  given old  = {$oldC}\n");
        exit(8);
    }
    if ($oldOk && !$dry) {
        dburl_write_wp_config($wpConfig, $newC);
        fwrite(STDOUT, "wp-config WP_HOME / WP_SITEURL → {$newC}\n");
    } elseif ($newOk && !$oldOk) {
        fwrite(STDOUT, "wp-config already at the new URL; rewriting the database only.\n");
    }
}

if ($db === '' || $user === '') {
    fwrite(STDERR, "Need --db/--user/--pass or --wp-config.\n");
    exit(5);
}

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
    $mysqli = new mysqli($host, $user, $pass, $db);
} catch (mysqli_sql_exception $e) {
    fwrite(STDERR, "Database connect failed: " . $e->getMessage() . "\n");
    exit(6);
}
$mysqli->set_charset('utf8mb4');

$pairs = dburl_pairs($oldC, $newC);
$textTypes = '/char|text|blob|json|enum|set/i';
$tablesChanged = 0;
$rowsChanged = 0;

$tables = [];
$tq = $mysqli->query('SHOW TABLES');
while ($row = $tq->fetch_row()) {
    $tables[] = (string) $row[0];
}

foreach ($tables as $table) {
    if (!preg_match('/^[A-Za-z0-9_]+$/', $table)) {
        continue;
    }
    $pkCols = [];
    $keys = $mysqli->query("SHOW KEYS FROM `{$table}` WHERE Key_name = 'PRIMARY'");
    while ($k = $keys->fetch_assoc()) {
        $pkCols[] = (string) $k['Column_name'];
    }
    if ($pkCols === []) {
        continue;
    }
    $cols = [];
    $desc = $mysqli->query("SHOW COLUMNS FROM `{$table}`");
    while ($c = $desc->fetch_assoc()) {
        $field = (string) $c['Field'];
        $type = (string) $c['Type'];
        if (in_array($field, $pkCols, true)) {
            continue;
        }
        if (!preg_match($textTypes, $type)) {
            continue;
        }
        $cols[] = $field;
    }
    if ($cols === []) {
        continue;
    }
    $needles = array_unique(array_merge([$oldC], array_keys($pairs)));
    $whereParts = [];
    foreach ($cols as $col) {
        foreach ($needles as $n) {
            if (strlen($n) < 8) {
                continue;
            }
            $whereParts[] = '`' . str_replace('`', '', $col) . "` LIKE '%" . $mysqli->real_escape_string($n) . "%'";
        }
    }
    if ($whereParts === []) {
        continue;
    }
    $selectCols = array_merge($pkCols, $cols);
    $sel = [];
    foreach ($selectCols as $c) {
        $sel[] = '`' . str_replace('`', '', $c) . '`';
    }
    $sql = 'SELECT ' . implode(',', $sel) . " FROM `{$table}` WHERE " . implode(' OR ', $whereParts);
    try {
        $res = $mysqli->query($sql);
    } catch (mysqli_sql_exception $e) {
        fwrite(STDERR, "Skip {$table}: " . $e->getMessage() . "\n");
        continue;
    }
    $tRows = 0;
    while ($r = $res->fetch_assoc()) {
        $sets = [];
        $params = [];
        $types = '';
        foreach ($cols as $col) {
            $val = $r[$col];
            if (!is_string($val) || $val === '') {
                continue;
            }
            if (str_contains($val, "\0")) {
                continue;
            }
            $next = dburl_value($val, $pairs);
            if ($next === $val) {
                continue;
            }
            $sets[] = '`' . str_replace('`', '', $col) . '` = ?';
            $params[] = $next;
            $types .= 's';
        }
        if ($sets === []) {
            continue;
        }
        $where = [];
        foreach ($pkCols as $pk) {
            $where[] = '`' . str_replace('`', '', $pk) . '` = ?';
            $params[] = $r[$pk];
            $types .= 's';
        }
        $tRows++;
        if ($dry) {
            continue;
        }
        $upd = "UPDATE `{$table}` SET " . implode(', ', $sets) . ' WHERE ' . implode(' AND ', $where);
        $stmt = $mysqli->prepare($upd);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        $stmt->close();
    }
    $res->free();
    if ($tRows > 0) {
        $tablesChanged++;
        $rowsChanged += $tRows;
        fwrite(STDOUT, ($dry ? '[dry] ' : '') . "{$table}: {$tRows} row(s)\n");
    }
}

fwrite(STDOUT, ($dry ? '[dry] ' : '') . "Done. {$tablesChanged} table(s), {$rowsChanged} row(s). {$oldC} → {$newC}\n");
$mysqli->close();
exit(0);
