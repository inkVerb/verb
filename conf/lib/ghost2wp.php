#!/usr/bin/php
<?php
/**
 * Ghost (MariaDB + content/) → WordPress.
 *
 * Ghost tables are READ-ONLY. WordPress cannot be "the Ghost database after
 * a rewrite": the WP installer creates wp_* tables, and Ghost's schema is
 * unrelated. This CLI loads WordPress (wp-config + wp-load), runs wp_install()
 * only if those tables are missing, then copies posts, pages, tags, menus,
 * and media into the WP library.
 *
 *   php /opt/verb/conf/lib/ghost2wp.php \
 *     --wp-root=/srv/www/vapps/wp.formosan.dog \
 *     --ghost-db=gstformosandogXXXX \
 *     --ghost-content=/srv/ghost/formosan.dog/content \
 *     --ghost-config=/srv/ghost/formosan.dog/config.production.json \
 *     --site-url=https://formosan.dog \
 *     --mysql-cnf=/opt/verb/conf/sql/mysqlboss.cnf
 */
declare(strict_types=1);

$opt = getopt('', [
    'wp-root:',
    'ghost-db:',
    'ghost-content:',
    'ghost-config:',
    'site-url:',
    'mysql-cnf:',
    'admin-user:',
    'admin-email:',
    'admin-pass:',
    'dry-run',
    'media-only',
    'help',
]);

if (isset($opt['help']) || empty($opt['wp-root'])) {
    fwrite(STDERR, <<<TXT
Ghost → WordPress importer. Ghost's database is never rewritten.

Required:
  --wp-root=DIR             WordPress root (wp-config.php lives here)

Ghost source (need a database name, from --ghost-db or --ghost-config):
  --ghost-db=NAME           Ghost MariaDB database name
  --ghost-config=FILE       Ghost config.production.json (url + database name)
  --ghost-content=DIR       Ghost content/ (images, files, media)

Optional:
  --site-url=URL            Public site URL (default: config url / https://host)
  --mysql-cnf=FILE          MariaDB client cnf. Default: /opt/verb/conf/sql/mysqlboss.cnf
  --admin-user=NAME         Only if WordPress tables are not installed yet (default: admin)
  --admin-email=EMAIL       Only if WordPress tables are not installed yet
  --admin-pass=PASS         Only if WordPress tables are not installed yet (random if omitted)
  --dry-run                 Print what would happen; no writes, no copies
  --media-only              Copy/register media only (posts already imported)

Media is COPIED (Ghost files stay). Run the bash helper if you also want a move.

TXT);
    exit(isset($opt['help']) ? 0 : 5);
}

$wpRoot = rtrim((string) $opt['wp-root'], '/');
$ghostCfgPath = (string) ($opt['ghost-config'] ?? '');
$ghostJson = $ghostCfgPath !== '' ? load_ghost_json($ghostCfgPath) : [];
$ghostDb = (string) ($opt['ghost-db'] ?? '');
if ($ghostDb === '') {
    $ghostDb = (string) ($ghostJson['database']['connection']['database'] ?? '');
}
$ghostContent = isset($opt['ghost-content']) ? rtrim((string) $opt['ghost-content'], '/') : '';
$mysqlCnf = (string) ($opt['mysql-cnf'] ?? '/opt/verb/conf/sql/mysqlboss.cnf');
$dry = isset($opt['dry-run']);
$mediaOnly = isset($opt['media-only']);

if ($ghostDb === '') {
    fwrite(STDERR, "Need --ghost-db or a --ghost-config that names database.connection.database.\n");
    exit(5);
}
if (!is_file($wpRoot . '/wp-config.php')) {
    fwrite(STDERR, "No wp-config.php in {$wpRoot}. Run installwp first.\n");
    exit(8);
}

$cnf = load_mysql_cnf($mysqlCnf);
try {
    $ghost = ghost_pdo($cnf, $ghostDb);
} catch (PDOException $e) {
    fwrite(STDERR, 'Ghost DB connect failed: ' . $e->getMessage() . "\n");
    exit(8);
}

$siteUrl = rtrim((string) ($opt['site-url'] ?? ''), '/');
if ($siteUrl === '') {
    $siteUrl = rtrim((string) ($ghostJson['url'] ?? ''), '/');
}
if ($siteUrl === '') {
    $siteUrl = rtrim((string) ghost_setting($ghost, 'url', ''), '/');
}
if ($siteUrl !== '' && !preg_match('#^https?://#i', $siteUrl)) {
    $siteUrl = 'https://' . ltrim($siteUrl, '/');
}
$gSite = $siteUrl;
if ($gSite === '') {
    $gSite = rtrim((string) ghost_setting($ghost, 'site_url', ''), '/');
}
if ($siteUrl === '' || $siteUrl === 'https://') {
    $host = (string) (parse_url((string) ($ghostJson['url'] ?? ''), PHP_URL_HOST) ?: 'localhost');
    $siteUrl = 'https://' . $host;
    if ($gSite === '') {
        $gSite = $siteUrl;
    }
}

$title = (string) (ghost_setting($ghost, 'title', '') ?: 'Blog');
$tagline = (string) ghost_setting($ghost, 'description', '');
$adminEmail = (string) ($opt['admin-email'] ?? ghost_owner_email($ghost) ?? 'admin@localhost');
$adminUser = (string) ($opt['admin-user'] ?? 'admin');
$adminPass = (string) ($opt['admin-pass'] ?? bin2hex(random_bytes(8)));

$_SERVER['HTTP_HOST'] = (string) (parse_url($siteUrl, PHP_URL_HOST) ?: 'localhost');
$_SERVER['REQUEST_URI'] = '/';
$_SERVER['SERVER_PROTOCOL'] = 'HTTP/1.1';
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['HTTPS'] = 'on';
if (!defined('WP_INSTALLING')) {
    define('WP_INSTALLING', true);
}
if (!defined('WP_USE_THEMES')) {
    define('WP_USE_THEMES', false);
}
if (!defined('DISABLE_WP_CRON')) {
    define('DISABLE_WP_CRON', true);
}

chdir($wpRoot);
require $wpRoot . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/upgrade.php';
require_once ABSPATH . 'wp-admin/includes/image.php';
require_once ABSPATH . 'wp-admin/includes/file.php';
require_once ABSPATH . 'wp-admin/includes/media.php';

global $wpdb;

$installed = $wpdb->get_var("SHOW TABLES LIKE '{$wpdb->posts}'");
if (!$installed) {
    if ($dry) {
        echo "[dry-run] would run wp_install() as {$adminUser} <{$adminEmail}>\n";
    } else {
        echo "WordPress tables missing — installing core as {$adminUser}…\n";
        wp_install($title, $adminUser, $adminEmail, true, '', $adminPass, 'en_US');
        echo "Admin password (save this): {$adminPass}\n";
    }
}

if ($siteUrl !== '' && !$dry) {
    update_option('siteurl', $siteUrl);
    update_option('home', $siteUrl);
    update_option('blogname', $title);
    if ($tagline !== '') {
        update_option('blogdescription', $tagline);
    }
    update_option('permalink_structure', '/%postname%/');
    $tz = (string) ghost_setting($ghost, 'timezone', '');
    if ($tz !== '' && in_array($tz, timezone_identifiers_list(), true)) {
        update_option('timezone_string', $tz);
    }
}

$uploads = wp_upload_dir();
$uploadBasedir = (string) ($uploads['basedir'] ?? $wpRoot . '/wp-content/uploads');
$uploadBaseurl = rtrim((string) ($uploads['baseurl'] ?? $siteUrl . '/wp-content/uploads'), '/');

echo "Ghost DB: {$ghostDb}\nWP root: {$wpRoot}\nSite: {$siteUrl}\nUploads: {$uploadBasedir}\n";

$attByRel = [];
if ($ghostContent !== '' && is_dir($ghostContent)) {
    copy_ghost_media($ghostContent, $uploadBasedir, $dry);
} elseif ($ghostContent !== '') {
    fwrite(STDERR, "Ghost content dir not found: {$ghostContent} (continuing, URLs still rewritten)\n");
}
if (!$dry) {
    $attByRel = register_uploads($uploadBasedir, $uploadBaseurl);
    echo 'Media items: ' . count($attByRel) . "\n";
} else {
    echo "[dry-run] would register media under {$uploadBasedir}\n";
}

if ($mediaOnly) {
    echo "Done (media-only).\n";
    exit(0);
}

if (!$dry) {
    $wpdb->query("DELETE FROM {$wpdb->posts} WHERE post_type IN ('post','page') AND post_name IN ('hello-world','sample-page')");
    $wpdb->query("DELETE FROM {$wpdb->comments} WHERE comment_post_ID NOT IN (SELECT ID FROM {$wpdb->posts})");
}

if (function_exists('kses_remove_filters')) {
    kses_remove_filters();
}

$authorMap = import_authors($ghost, $dry);
$defaultAuthor = 1;
if ($authorMap !== []) {
    $defaultAuthor = (int) reset($authorMap);
}
if ($defaultAuthor < 1 && !$dry) {
    $admins = get_users(['role' => 'administrator', 'number' => 1]);
    $defaultAuthor = isset($admins[0]) ? (int) $admins[0]->ID : 1;
}
$termMap = import_tags($ghost, $dry);
$postMap = import_posts($ghost, $authorMap, $defaultAuthor, $termMap, $attByRel, $siteUrl, $gSite, $dry);
import_menus($ghost, $postMap, $siteUrl, $gSite, $dry);
import_site_logo($ghost, $attByRel, $dry);

echo 'Posts/pages: ' . count($postMap) . "\nDone.\n";
exit(0);

function wp_dt(mixed $s): string
{
    if (!is_string($s) || $s === '') {
        return gmdate('Y-m-d H:i:s');
    }
    $t = strtotime($s);
    return $t ? gmdate('Y-m-d H:i:s', $t) : gmdate('Y-m-d H:i:s');
}

function load_mysql_cnf(string $path): array
{
    if (!is_file($path)) {
        fwrite(STDERR, "MariaDB cnf not found: {$path}\n");
        exit(8);
    }
    $raw = parse_ini_file($path, true, INI_SCANNER_RAW);
    $c = is_array($raw) ? ($raw['client'] ?? $raw) : [];
    return [
        'user' => (string) ($c['user'] ?? 'root'),
        'password' => (string) ($c['password'] ?? $c['pass'] ?? ''),
        'host' => (string) ($c['host'] ?? 'localhost'),
        'socket' => (string) ($c['socket'] ?? ''),
    ];
}

function load_ghost_json(string $path): array
{
    if (!is_file($path)) {
        fwrite(STDERR, "Ghost config not found: {$path}\n");
        return [];
    }
    $j = json_decode((string) file_get_contents($path), true);
    return is_array($j) ? $j : [];
}

function ghost_pdo(array $cnf, string $db): PDO
{
    $dsn = $cnf['socket'] !== ''
        ? 'mysql:unix_socket=' . $cnf['socket'] . ';dbname=' . $db . ';charset=utf8mb4'
        : 'mysql:host=' . $cnf['host'] . ';dbname=' . $db . ';charset=utf8mb4';
    return new PDO($dsn, $cnf['user'], $cnf['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
}

function ghost_has(PDO $g, string $table): bool
{
    $st = $g->prepare('SHOW TABLES LIKE ?');
    $st->execute([$table]);
    return (bool) $st->fetchColumn();
}

function ghost_cols(PDO $g, string $table): array
{
    static $cache = [];
    if (isset($cache[$table])) {
        return $cache[$table];
    }
    $cache[$table] = [];
    if (!preg_match('/^[A-Za-z0-9_]+$/', $table) || !ghost_has($g, $table)) {
        return $cache[$table];
    }
    foreach ($g->query('SHOW COLUMNS FROM `' . $table . '`') as $r) {
        $cache[$table][strtolower((string) $r['Field'])] = true;
    }
    return $cache[$table];
}

function ghost_col(PDO $g, string $table, string $col): bool
{
    return isset(ghost_cols($g, $table)[strtolower($col)]);
}

function ghost_setting(PDO $g, string $key, string $default = ''): string
{
    if (!ghost_has($g, 'settings')) {
        return $default;
    }
    $st = $g->prepare('SELECT value FROM settings WHERE `key`=? LIMIT 1');
    $st->execute([$key]);
    $v = $st->fetchColumn();
    return is_string($v) && $v !== '' ? $v : $default;
}

function ghost_owner_email(PDO $g): ?string
{
    if (!ghost_has($g, 'users')) {
        return null;
    }
    if (ghost_has($g, 'roles_users') && ghost_has($g, 'roles')) {
        $e = $g->query("SELECT u.email FROM users u JOIN roles_users ru ON ru.user_id=u.id JOIN roles r ON r.id=ru.role_id WHERE r.name IN ('Owner','Administrator') ORDER BY r.name='Owner' DESC LIMIT 1");
        $v = $e ? $e->fetchColumn() : false;
        if (is_string($v) && $v !== '') {
            return $v;
        }
    }
    $e = $g->query('SELECT email FROM users ORDER BY created_at ASC LIMIT 1');
    $v = $e ? $e->fetchColumn() : false;
    return is_string($v) && $v !== '' ? $v : null;
}

function rewrite_urls(string $html, string $siteUrl, string $gSite): string
{
    $wpImg = rtrim($siteUrl, '/') . '/wp-content/uploads';
    $wpFiles = rtrim($siteUrl, '/') . '/wp-content/uploads/files';
    $from = [
        '__GHOST_URL__/content/images/',
        '__GHOST_URL__/content/files/',
        '__GHOST_URL__/content/media/',
        rtrim($gSite, '/') . '/content/images/',
        rtrim($gSite, '/') . '/content/files/',
        rtrim($gSite, '/') . '/content/media/',
        '/content/images/',
        '/content/files/',
        '/content/media/',
    ];
    $to = [
        $wpImg . '/',
        $wpFiles . '/',
        $wpImg . '/',
        $wpImg . '/',
        $wpFiles . '/',
        $wpImg . '/',
        $wpImg . '/',
        $wpFiles . '/',
        $wpImg . '/',
    ];
    $html = str_replace($from, $to, $html);
    $html = preg_replace('#/wp-content/uploads/size/w\d+/+#', '/wp-content/uploads/', $html) ?? $html;
    $html = preg_replace('#/content/images/size/w\d+/+#', '/wp-content/uploads/', $html) ?? $html;
    return $html;
}

function ghost_rel_from_url(string $url): string
{
    $url = str_replace('__GHOST_URL__', '', $url);
    $url = preg_replace('#https?://[^/]+#', '', $url) ?? $url;
    $url = preg_replace('#/content/images/size/w\d+/+#', '/content/images/', $url) ?? $url;
    if (preg_match('#/content/images/(.+)$#', $url, $m)) {
        return ltrim($m[1], '/');
    }
    if (preg_match('#/content/media/(.+)$#', $url, $m)) {
        return ltrim($m[1], '/');
    }
    if (preg_match('#/content/files/(.+)$#', $url, $m)) {
        return 'files/' . ltrim($m[1], '/');
    }
    if (preg_match('#/wp-content/uploads/(.+)$#', $url, $m)) {
        return ltrim($m[1], '/');
    }
    return ltrim($url, '/');
}

function find_attachment(array $attByRel, string $rel): int
{
    if ($rel !== '' && !empty($attByRel[$rel])) {
        return (int) $attByRel[$rel];
    }
    $base = basename($rel);
    if ($base === '' || $base === '.' || $base === '/') {
        return 0;
    }
    foreach ($attByRel as $k => $id) {
        if (basename((string) $k) === $base) {
            return (int) $id;
        }
    }
    return 0;
}

function mime_for(string $path): string
{
    $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
    return match ($ext) {
        'jpg', 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'svg' => 'image/svg+xml',
        'avif' => 'image/avif',
        'ico' => 'image/x-icon',
        'mp4' => 'video/mp4',
        'webm' => 'video/webm',
        'mp3' => 'audio/mpeg',
        'pdf' => 'application/pdf',
        'zip' => 'application/zip',
        default => 'application/octet-stream',
    };
}

function skip_media_path(string $norm): bool
{
    foreach (['/size/', '/.git/', '/cache/', '/tmp/'] as $p) {
        if (str_contains($norm, $p)) {
            return true;
        }
    }
    $base = basename($norm);
    if (in_array($base, ['index.php', '.htaccess', '.DS_Store', 'Thumbs.db'], true)) {
        return true;
    }
    if (preg_match('/-\d+x\d+\.(jpe?g|png|gif|webp|avif)$/i', $base)) {
        return true;
    }
    return false;
}

function copy_ghost_media(string $contentDir, string $basedir, bool $dry): int
{
    $n = 0;
    $roots = [
        $contentDir . '/images' => '',
        $contentDir . '/media' => '',
        $contentDir . '/files' => 'files/',
    ];
    foreach ($roots as $root => $prefix) {
        if (!is_dir($root)) {
            continue;
        }
        $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($root, FilesystemIterator::SKIP_DOTS));
        foreach ($it as $file) {
            /** @var SplFileInfo $file */
            if (!$file->isFile()) {
                continue;
            }
            $full = $file->getPathname();
            $norm = str_replace('\\', '/', $full);
            if (skip_media_path($norm)) {
                continue;
            }
            $rel = $prefix . ltrim(substr($norm, strlen(rtrim($root, '/'))), '/');
            $dest = $basedir . '/' . $rel;
            $n++;
            if ($dry) {
                continue;
            }
            $dir = dirname($dest);
            if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
                fwrite(STDERR, "mkdir failed: {$dir}\n");
                continue;
            }
            if (!is_file($dest)) {
                copy($full, $dest);
            }
            @chmod($dest, 0644);
        }
    }
    echo ($dry ? '[dry-run] would copy' : 'Copied') . " {$n} media files.\n";
    return $n;
}

function register_uploads(string $basedir, string $baseurl): array
{
    global $wpdb;
    $map = [];
    if (!is_dir($basedir)) {
        return $map;
    }
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($basedir, FilesystemIterator::SKIP_DOTS));
    foreach ($it as $file) {
        /** @var SplFileInfo $file */
        if (!$file->isFile()) {
            continue;
        }
        $full = $file->getPathname();
        $norm = str_replace('\\', '/', $full);
        if (skip_media_path($norm)) {
            continue;
        }
        $rel = ltrim(substr($norm, strlen(rtrim($basedir, '/'))), '/');
        if ($rel === '') {
            continue;
        }
        $existing = (int) $wpdb->get_var($wpdb->prepare(
            "SELECT post_id FROM {$wpdb->postmeta} WHERE meta_key='_wp_attached_file' AND meta_value=%s LIMIT 1",
            $rel
        ));
        if ($existing > 0) {
            $map[$rel] = $existing;
            continue;
        }
        $guid = $baseurl . '/' . $rel;
        $now = current_time('mysql');
        $nowGmt = current_time('mysql', true);
        $wpdb->insert($wpdb->posts, [
            'post_author' => 1,
            'post_date' => $now,
            'post_date_gmt' => $nowGmt,
            'post_content' => '',
            'post_title' => pathinfo($rel, PATHINFO_FILENAME),
            'post_excerpt' => '',
            'post_status' => 'inherit',
            'comment_status' => 'closed',
            'ping_status' => 'closed',
            'post_name' => sanitize_title(pathinfo($rel, PATHINFO_FILENAME)),
            'to_ping' => '',
            'pinged' => '',
            'post_modified' => $now,
            'post_modified_gmt' => $nowGmt,
            'post_content_filtered' => '',
            'post_parent' => 0,
            'guid' => $guid,
            'menu_order' => 0,
            'post_type' => 'attachment',
            'post_mime_type' => mime_for($rel),
            'comment_count' => 0,
        ]);
        $id = (int) $wpdb->insert_id;
        if ($id < 1) {
            continue;
        }
        update_post_meta($id, '_wp_attached_file', $rel);
        $mime = mime_for($rel);
        if (str_starts_with($mime, 'image/') && $mime !== 'image/svg+xml' && is_file($full)) {
            $sz = @getimagesize($full);
            if (is_array($sz)) {
                update_post_meta($id, '_wp_attachment_metadata', [
                    'width' => $sz[0],
                    'height' => $sz[1],
                    'file' => $rel,
                    'sizes' => [],
                    'image_meta' => [
                        'aperture' => '0',
                        'credit' => '',
                        'camera' => '',
                        'caption' => '',
                        'created_timestamp' => '0',
                        'copyright' => '',
                        'focal_length' => '0',
                        'iso' => '0',
                        'shutter_speed' => '0',
                        'title' => '',
                        'orientation' => '0',
                        'keywords' => [],
                    ],
                ]);
            }
        }
        $map[$rel] = $id;
    }
    return $map;
}

function lexical_to_html(string $json): string
{
    $data = json_decode($json, true);
    if (!is_array($data)) {
        return '';
    }
    $root = $data['root']['children'] ?? $data['children'] ?? [];
    return is_array($root) ? lexical_nodes($root) : '';
}

function lexical_nodes(array $nodes): string
{
    $html = '';
    foreach ($nodes as $n) {
        if (!is_array($n)) {
            continue;
        }
        $type = (string) ($n['type'] ?? '');
        $children = is_array($n['children'] ?? null) ? lexical_nodes($n['children']) : '';
        $text = htmlspecialchars((string) ($n['text'] ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
        if ($text !== '') {
            $f = (int) ($n['format'] ?? 0);
            if ($f & 1) {
                $text = '<strong>' . $text . '</strong>';
            }
            if ($f & 2) {
                $text = '<em>' . $text . '</em>';
            }
            if ($f & 8) {
                $text = '<u>' . $text . '</u>';
            }
            if ($f & 4) {
                $text = '<s>' . $text . '</s>';
            }
            if ($f & 16) {
                $text = '<code>' . $text . '</code>';
            }
        }
        $html .= match ($type) {
            'text', 'extended-text', 'extended-text-node' => $text,
            'linebreak', 'line-break' => '<br>',
            'paragraph' => '<p>' . $children . $text . '</p>',
            'heading' => '<' . (preg_replace('/[^a-z0-9]/', '', strtolower((string) ($n['tag'] ?? 'h2'))) ?: 'h2') . '>' . $children . $text . '</' . (preg_replace('/[^a-z0-9]/', '', strtolower((string) ($n['tag'] ?? 'h2'))) ?: 'h2') . '>',
            'quote' => '<blockquote>' . $children . $text . '</blockquote>',
            'list' => (($n['listType'] ?? $n['tag'] ?? 'bullet') === 'number' ? '<ol>' : '<ul>') . $children . (($n['listType'] ?? $n['tag'] ?? 'bullet') === 'number' ? '</ol>' : '</ul>'),
            'listitem', 'list-item' => '<li>' . $children . $text . '</li>',
            'link' => '<a href="' . htmlspecialchars((string) ($n['url'] ?? $n['rel'] ?? '#'), ENT_QUOTES) . '">' . $children . $text . '</a>',
            'image' => '<figure><img src="' . htmlspecialchars((string) ($n['src'] ?? ''), ENT_QUOTES) . '" alt="' . htmlspecialchars((string) ($n['alt'] ?? ''), ENT_QUOTES) . '"></figure>',
            'html', 'htmlcard' => (string) ($n['html'] ?? $n['value'] ?? $children),
            default => $children . $text,
        };
    }
    return $html;
}

function mobiledoc_to_html(string $json): string
{
    $d = json_decode($json, true);
    if (!is_array($d)) {
        return '';
    }
    $out = '';
    foreach ($d['cards'] ?? [] as $card) {
        if (!is_array($card)) {
            continue;
        }
        $name = (string) ($card[0] ?? '');
        $payload = is_array($card[1] ?? null) ? $card[1] : [];
        if (in_array($name, ['html', 'card-html', 'markdown', 'card-markdown', 'embed'], true) && !empty($payload['html'])) {
            $out .= (string) $payload['html'];
        } elseif ($name === 'image' && !empty($payload['src'])) {
            $out .= '<img src="' . htmlspecialchars((string) $payload['src'], ENT_QUOTES) . '" alt="' . htmlspecialchars((string) ($payload['alt'] ?? ''), ENT_QUOTES) . '">';
        }
    }
    return $out;
}

function ghost_html(array $row): string
{
    $html = trim((string) ($row['html'] ?? ''));
    if ($html !== '' && $html !== '<p></p>') {
        return $html;
    }
    $lex = trim((string) ($row['lexical'] ?? ''));
    if ($lex !== '') {
        $html = trim(lexical_to_html($lex));
        if ($html !== '') {
            return $html;
        }
    }
    $md = trim((string) ($row['mobiledoc'] ?? ''));
    if ($md !== '') {
        $html = trim(mobiledoc_to_html($md));
        if ($html !== '') {
            return $html;
        }
    }
    $plain = trim((string) ($row['plaintext'] ?? ''));
    if ($plain !== '') {
        return '<p>' . nl2br(htmlspecialchars($plain, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'), false) . '</p>';
    }
    return '';
}

function import_authors(PDO $g, bool $dry): array
{
    $map = [];
    if (!ghost_has($g, 'users')) {
        return $map;
    }
    $rows = $g->query('SELECT * FROM users')->fetchAll();
    foreach ($rows as $u) {
        $email = trim((string) ($u['email'] ?? ''));
        $login = sanitize_user((string) ($u['slug'] ?? $u['name'] ?? 'author'), true);
        if ($login === '') {
            $login = 'author' . substr((string) $u['id'], -6);
        }
        if ($dry) {
            $map[(string) $u['id']] = 1;
            continue;
        }
        $existing = $email !== '' ? get_user_by('email', $email) : get_user_by('login', $login);
        if ($existing) {
            $map[(string) $u['id']] = (int) $existing->ID;
            continue;
        }
        $pass = wp_generate_password(16, true);
        $uid = wp_create_user($login, $pass, $email !== '' ? $email : $login . '@imported.invalid');
        if (is_wp_error($uid)) {
            fwrite(STDERR, 'User skip ' . $login . ': ' . $uid->get_error_message() . "\n");
            continue;
        }
        wp_update_user([
            'ID' => $uid,
            'display_name' => (string) ($u['name'] ?? $login),
            'user_url' => (string) ($u['website'] ?? ''),
            'description' => (string) ($u['bio'] ?? ''),
            'role' => 'author',
        ]);
        $map[(string) $u['id']] = (int) $uid;
    }
    return $map;
}

function import_tags(PDO $g, bool $dry): array
{
    $map = [];
    if (!ghost_has($g, 'tags')) {
        return $map;
    }
    $rows = $g->query('SELECT * FROM tags')->fetchAll();
    foreach ($rows as $t) {
        $name = (string) ($t['name'] ?? '');
        $slug = (string) ($t['slug'] ?? '');
        if ($name === '' || str_starts_with($name, '#')) {
            continue;
        }
        if (($t['visibility'] ?? 'public') === 'internal') {
            continue;
        }
        if ($dry) {
            $map[(string) $t['id']] = 0;
            continue;
        }
        $got = term_exists($slug, 'post_tag');
        if (!$got) {
            $got = wp_insert_term($name, 'post_tag', [
                'slug' => $slug,
                'description' => (string) ($t['description'] ?? ''),
            ]);
        }
        if (is_wp_error($got)) {
            continue;
        }
        $map[(string) $t['id']] = (int) ($got['term_id'] ?? $got);
    }
    return $map;
}

function post_authors(PDO $g, string $postId, array $row): array
{
    $ids = [];
    if (ghost_has($g, 'posts_authors')) {
        $sql = 'SELECT author_id FROM posts_authors WHERE post_id=?';
        if (ghost_col($g, 'posts_authors', 'sort_order')) {
            $sql .= ' ORDER BY sort_order ASC';
        }
        $st = $g->prepare($sql);
        $st->execute([$postId]);
        foreach ($st->fetchAll() as $a) {
            $ids[] = (string) $a['author_id'];
        }
    }
    if ($ids === [] && !empty($row['author_id'])) {
        $ids[] = (string) $row['author_id'];
    }
    return $ids;
}

function post_tag_ids(PDO $g, string $postId): array
{
    if (!ghost_has($g, 'posts_tags')) {
        return [];
    }
    $sql = 'SELECT tag_id FROM posts_tags WHERE post_id=?';
    if (ghost_col($g, 'posts_tags', 'sort_order')) {
        $sql .= ' ORDER BY sort_order ASC';
    }
    $st = $g->prepare($sql);
    $st->execute([$postId]);
    $out = [];
    foreach ($st->fetchAll() as $r) {
        $out[] = (string) $r['tag_id'];
    }
    return $out;
}

function import_posts(PDO $g, array $authorMap, int $defaultAuthor, array $termMap, array $attByRel, string $siteUrl, string $gSite, bool $dry): array
{
    global $wpdb;
    $map = [];
    if (!ghost_has($g, 'posts')) {
        fwrite(STDERR, "Ghost has no posts table.\n");
        return $map;
    }
    $rows = $g->query("SELECT * FROM posts WHERE type IN ('post','page') ORDER BY COALESCE(published_at, created_at) ASC")->fetchAll();
    $metaByPost = [];
    if (ghost_has($g, 'posts_meta')) {
        foreach ($g->query('SELECT * FROM posts_meta')->fetchAll() as $m) {
            $metaByPost[(string) $m['post_id']] = $m;
        }
    }
    echo 'Ghost posts/pages to import: ' . count($rows) . "\n";
    foreach ($rows as $row) {
        $gid = (string) $row['id'];
        $type = ($row['type'] ?? 'post') === 'page' ? 'page' : 'post';
        $status = match ((string) ($row['status'] ?? 'draft')) {
            'published', 'sent' => 'publish',
            'scheduled' => 'future',
            default => 'draft',
        };
        if (($row['visibility'] ?? 'public') !== 'public' && $status === 'publish') {
            $status = 'private';
        }
        $html = rewrite_urls(ghost_html($row), $siteUrl, $gSite);
        if ($html !== '') {
            $html = "<!-- wp:html -->\n{$html}\n<!-- /wp:html -->";
        }
        $slug = sanitize_title((string) ($row['slug'] ?? $row['title'] ?? $gid));
        $authors = post_authors($g, $gid, $row);
        $author = $defaultAuthor;
        foreach ($authors as $ga) {
            if (!empty($authorMap[$ga])) {
                $author = (int) $authorMap[$ga];
                break;
            }
        }
        $pubRaw = (string) ($row['published_at'] ?? '');
        if ($pubRaw === '') {
            $pubRaw = (string) ($row['created_at'] ?? '');
        }
        $updRaw = (string) ($row['updated_at'] ?? '');
        if ($updRaw === '') {
            $updRaw = $pubRaw;
        }
        $pub = wp_dt($pubRaw);
        $updated = wp_dt($updRaw);
        $excerpt = trim((string) ($row['custom_excerpt'] ?? ''));
        if ($excerpt === '' && !empty($row['plaintext'])) {
            $excerpt = wp_html_excerpt(wp_strip_all_tags((string) $row['plaintext']), 160, '…');
        }
        if ($dry) {
            $map[$gid] = 0;
            echo "  [dry-run] {$type} /{$slug} {$status}\n";
            continue;
        }
        $already = (int) $wpdb->get_var($wpdb->prepare(
            "SELECT post_id FROM {$wpdb->postmeta} WHERE meta_key='_ghost_id' AND meta_value=%s LIMIT 1",
            $gid
        ));
        $now = [
            'post_author' => $author,
            'post_date' => $pub,
            'post_date_gmt' => $pub,
            'post_content' => $html,
            'post_title' => (string) ($row['title'] ?? ''),
            'post_excerpt' => $excerpt,
            'post_status' => $status,
            'comment_status' => 'closed',
            'ping_status' => 'closed',
            'post_name' => $slug,
            'to_ping' => '',
            'pinged' => '',
            'post_modified' => $updated,
            'post_modified_gmt' => $updated,
            'post_content_filtered' => '',
            'post_parent' => 0,
            'guid' => $siteUrl . '/' . $slug . '/',
            'menu_order' => 0,
            'post_type' => $type,
            'post_mime_type' => '',
            'comment_count' => 0,
        ];
        if ($already > 0) {
            $wpdb->update($wpdb->posts, $now, ['ID' => $already]);
            $wid = $already;
        } else {
            $wpdb->insert($wpdb->posts, $now);
            $wid = (int) $wpdb->insert_id;
            if ($wid < 1) {
                fwrite(STDERR, "Insert failed for Ghost {$type} {$slug}\n");
                continue;
            }
            update_post_meta($wid, '_ghost_id', $gid);
        }
        $map[$gid] = $wid;
        if (!empty($row['featured'])) {
            $sticky = get_option('sticky_posts', []);
            if (!is_array($sticky)) {
                $sticky = [];
            }
            if (!in_array($wid, $sticky, true)) {
                $sticky[] = $wid;
                update_option('sticky_posts', $sticky);
            }
        }
        $feat = (string) ($row['feature_image'] ?? '');
        if ($feat !== '') {
            $aid = find_attachment($attByRel, ghost_rel_from_url($feat));
            if ($aid > 0) {
                update_post_meta($wid, '_thumbnail_id', $aid);
            }
        }
        $pm = $metaByPost[$gid] ?? [];
        foreach ([
            'meta_title' => '_ghost_meta_title',
            'meta_description' => '_ghost_meta_description',
            'canonical_url' => '_ghost_canonical_url',
        ] as $src => $key) {
            if (!empty($pm[$src])) {
                update_post_meta($wid, $key, (string) $pm[$src]);
            } elseif (!empty($row[$src])) {
                update_post_meta($wid, $key, (string) $row[$src]);
            }
        }
        $tids = [];
        foreach (post_tag_ids($g, $gid) as $tid) {
            if (!empty($termMap[$tid])) {
                $tids[] = (int) $termMap[$tid];
            }
        }
        if ($tids && $type === 'post') {
            wp_set_post_terms($wid, $tids, 'post_tag', false);
        }
    }
    return $map;
}

function import_menus(PDO $g, array $postMap, string $siteUrl, string $gSite, bool $dry): void
{
    $keys = ['navigation' => 'Primary', 'secondary_navigation' => 'Secondary'];
    $locations = [];
    foreach ($keys as $key => $label) {
        $raw = ghost_setting($g, $key, '');
        if ($raw === '' || $raw === '[]' || $raw === 'null') {
            continue;
        }
        $items = json_decode($raw, true);
        if (!is_array($items) || $items === []) {
            continue;
        }
        if ($dry) {
            echo "[dry-run] menu {$label}: " . count($items) . " items\n";
            continue;
        }
        $name = 'Ghost ' . $label;
        $menuObj = wp_get_nav_menu_object($name);
        if ($menuObj) {
            $menuId = (int) $menuObj->term_id;
        } else {
            $created = wp_create_nav_menu($name);
            if (is_wp_error($created)) {
                fwrite(STDERR, 'Menu skip ' . $name . ': ' . $created->get_error_message() . "\n");
                continue;
            }
            $menuId = (int) $created;
        }
        $old = wp_get_nav_menu_items($menuId);
        if (is_array($old)) {
            foreach ($old as $it) {
                wp_delete_post((int) $it->ID, true);
            }
        }
        $pos = 1;
        foreach ($items as $it) {
            if (!is_array($it)) {
                continue;
            }
            $lab = (string) ($it['label'] ?? $it['title'] ?? 'Item');
            $url = (string) ($it['url'] ?? '/');
            $url = str_replace(['__GHOST_URL__', rtrim($gSite, '/')], ['', rtrim($siteUrl, '/')], $url);
            if ($url === '' || $url === '/') {
                $url = $siteUrl . '/';
            } elseif (isset($url[0]) && $url[0] === '/') {
                $url = $siteUrl . $url;
            }
            $args = [
                'menu-item-title' => $lab,
                'menu-item-status' => 'publish',
                'menu-item-type' => 'custom',
                'menu-item-url' => $url,
                'menu-item-position' => $pos++,
            ];
            $path = (string) (parse_url($url, PHP_URL_PATH) ?: '');
            $slug = trim($path, '/');
            if ($slug !== '') {
                foreach ($postMap as $wid) {
                    $p = get_post((int) $wid);
                    if ($p && $p->post_name === $slug) {
                        $args['menu-item-type'] = 'post_type';
                        $args['menu-item-object'] = $p->post_type;
                        $args['menu-item-object-id'] = (int) $p->ID;
                        unset($args['menu-item-url']);
                        break;
                    }
                }
            }
            wp_update_nav_menu_item($menuId, 0, $args);
        }
        echo "Menu {$label}: " . count($items) . " items\n";
        if ($key === 'navigation') {
            $locations['primary'] = $menuId;
            $locations['primary-menu'] = $menuId;
            $locations['menu-1'] = $menuId;
            $locations['main-menu'] = $menuId;
        } else {
            $locations['secondary'] = $menuId;
            $locations['footer'] = $menuId;
            $locations['footer-menu'] = $menuId;
        }
    }
    if ($locations !== [] && !$dry) {
        $mod = get_theme_mod('nav_menu_locations');
        if (!is_array($mod)) {
            $mod = [];
        }
        set_theme_mod('nav_menu_locations', array_merge($mod, $locations));
    }
}

function import_site_logo(PDO $g, array $attByRel, bool $dry): void
{
    $logo = ghost_setting($g, 'logo', '');
    if ($logo === '') {
        $logo = ghost_setting($g, 'icon', '');
    }
    if ($logo === '' || $dry) {
        return;
    }
    $aid = find_attachment($attByRel, ghost_rel_from_url($logo));
    if ($aid > 0) {
        set_theme_mod('custom_logo', $aid);
        update_option('site_logo', $aid);
        echo "Site logo set (attachment {$aid}).\n";
    }
}
