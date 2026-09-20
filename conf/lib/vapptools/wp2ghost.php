#!/usr/bin/php
<?php
/**
 * WordPress → Ghost (MariaDB + content/).
 *
 * WordPress is READ-ONLY. Ghost must already be installed (tables exist).
 * Copies posts, pages, tags, navigation, and media into Ghost.
 *
 *   php /opt/verb/conf/lib/vapptools/wp2ghost.php \
 *     --wp-root=/srv/www/vapps/wp.example.com \
 *     --ghost-db=gstexampleXXXX \
 *     --ghost-content=/srv/ghost/example.com/content \
 *     --ghost-config=/srv/ghost/example.com/config.production.json \
 *     --site-url=https://example.com \
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
    'dry-run',
    'media-only',
    'help',
]);

if (isset($opt['help']) || empty($opt['wp-root'])) {
    fwrite(STDERR, <<<TXT
WordPress → Ghost importer. WordPress is never rewritten.

Required:
  --wp-root=DIR             WordPress root (wp-config.php lives here)

Ghost target (need a database name, from --ghost-db or --ghost-config):
  --ghost-db=NAME           Ghost MariaDB database name
  --ghost-config=FILE       Ghost config.production.json (url + database name)
  --ghost-content=DIR       Ghost content/ (images are copied here)

Optional:
  --site-url=URL            Public site URL (default: Ghost config url / WP home)
  --mysql-cnf=FILE          MariaDB client cnf. Default: /opt/verb/conf/sql/mysqlboss.cnf
  --dry-run                 Print what would happen; no writes, no copies
  --media-only              Copy media only

TXT);
    exit(isset($opt['help']) ? 0 : 5);
}

$wpRoot = rtrim((string) $opt['wp-root'], '/');
$ghostCfgPath = (string) ($opt['ghost-config'] ?? '');
$ghostJson = $ghostCfgPath !== '' ? load_json($ghostCfgPath) : [];
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
    fwrite(STDERR, "No wp-config.php in {$wpRoot}.\n");
    exit(8);
}

$cnf = load_mysql_cnf($mysqlCnf);
try {
    $ghost = ghost_pdo($cnf, $ghostDb);
} catch (PDOException $e) {
    fwrite(STDERR, 'Ghost DB connect failed: ' . $e->getMessage() . "\n");
    exit(8);
}
if (!ghost_has($ghost, 'posts')) {
    fwrite(STDERR, "Ghost database {$ghostDb} has no posts table. Run installghostsite first.\n");
    exit(8);
}

define('WP_USE_THEMES', false);
define('SHORTINIT', false);
$_SERVER['HTTP_HOST'] = (string) (parse_url((string) ($ghostJson['url'] ?? ''), PHP_URL_HOST) ?: 'localhost');
$_SERVER['REQUEST_URI'] = '/';
$_SERVER['REQUEST_METHOD'] = 'GET';
chdir($wpRoot);
require $wpRoot . '/wp-load.php';

$siteUrl = rtrim((string) ($opt['site-url'] ?? ''), '/');
if ($siteUrl === '') {
    $siteUrl = rtrim((string) ($ghostJson['url'] ?? ''), '/');
}
if ($siteUrl === '') {
    $siteUrl = rtrim((string) (get_option('home') ?: get_option('siteurl') ?: ''), '/');
}
if ($siteUrl !== '' && !preg_match('#^https?://#i', $siteUrl)) {
    $siteUrl = 'https://' . ltrim($siteUrl, '/');
}
if ($siteUrl === '') {
    $siteUrl = 'https://localhost';
}

$ownerId = ghost_owner_id($ghost);
if ($ownerId === '') {
    fwrite(STDERR, "Ghost has no users. Finish Ghost setup at {$siteUrl}/ghost first.\n");
    exit(8);
}

$uploads = wp_upload_dir();
$uploadBasedir = (string) ($uploads['basedir'] ?? $wpRoot . '/wp-content/uploads');
$uploadBaseurl = rtrim((string) ($uploads['baseurl'] ?? $siteUrl . '/wp-content/uploads'), '/');
$imgDir = $ghostContent !== '' ? $ghostContent . '/images' : '';

echo "WP root: {$wpRoot}\nGhost DB: {$ghostDb}\nSite: {$siteUrl}\n";

if ($ghostContent !== '' && is_dir($uploadBasedir)) {
    $n = copy_uploads($uploadBasedir, $imgDir, $dry);
    echo "Media files: {$n}\n";
} else {
    echo "No --ghost-content or WP uploads; rewriting URLs only.\n";
}

if ($mediaOnly) {
    echo "Done (media-only).\n";
    exit(0);
}

if (!$dry) {
    $title = (string) get_option('blogname', '');
    $tag = (string) get_option('blogdescription', '');
    if ($title !== '') {
        ghost_set($ghost, 'title', $title, $ownerId);
    }
    if ($tag !== '') {
        ghost_set($ghost, 'description', $tag, $ownerId);
    }
}

$termMap = import_tags($ghost, $ownerId, $dry);
$postMap = import_posts($ghost, $ownerId, $termMap, $siteUrl, $uploadBaseurl, $dry);
import_menus($ghost, $postMap, $siteUrl, $dry);

echo 'Posts/pages: ' . count($postMap) . "\nDone.\n";
exit(0);

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

function load_json(string $path): array
{
    if (!is_file($path)) {
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

function ghost_id(): string
{
    return bin2hex(random_bytes(12));
}

function ghost_uuid(): string
{
    $b = random_bytes(16);
    $b[6] = chr((ord($b[6]) & 0x0f) | 0x40);
    $b[8] = chr((ord($b[8]) & 0x3f) | 0x80);
    $h = bin2hex($b);
    return substr($h, 0, 8) . '-' . substr($h, 8, 4) . '-' . substr($h, 12, 4) . '-' . substr($h, 16, 4) . '-' . substr($h, 20, 12);
}

function ghost_owner_id(PDO $g): string
{
    if (!ghost_has($g, 'users')) {
        return '';
    }
    if (ghost_has($g, 'roles_users') && ghost_has($g, 'roles')) {
        $st = $g->query("SELECT u.id FROM users u JOIN roles_users ru ON ru.user_id=u.id JOIN roles r ON r.id=ru.role_id WHERE r.name IN ('Owner','Administrator') ORDER BY r.name='Owner' DESC LIMIT 1");
        $v = $st ? $st->fetchColumn() : false;
        if (is_string($v) && $v !== '') {
            return $v;
        }
    }
    $st = $g->query('SELECT id FROM users ORDER BY created_at ASC LIMIT 1');
    $v = $st ? $st->fetchColumn() : false;
    return is_string($v) && $v !== '' ? $v : '';
}

function ghost_insert(PDO $g, string $table, array $row): void
{
    $cols = ghost_cols($g, $table);
    $use = [];
    foreach ($row as $k => $v) {
        if (isset($cols[strtolower((string) $k)])) {
            $use[$k] = $v;
        }
    }
    if ($use === []) {
        return;
    }
    $fields = array_keys($use);
    $sql = 'INSERT INTO `' . $table . '` (`' . implode('`,`', $fields) . '`) VALUES (' . implode(',', array_fill(0, count($fields), '?')) . ')';
    $g->prepare($sql)->execute(array_values($use));
}

function ghost_update(PDO $g, string $table, array $row, string $whereCol, string $whereVal): void
{
    $cols = ghost_cols($g, $table);
    $use = [];
    foreach ($row as $k => $v) {
        if (isset($cols[strtolower((string) $k)]) && strtolower((string) $k) !== strtolower($whereCol)) {
            $use[$k] = $v;
        }
    }
    if ($use === []) {
        return;
    }
    $set = [];
    $vals = [];
    foreach ($use as $k => $v) {
        $set[] = '`' . $k . '`=?';
        $vals[] = $v;
    }
    $vals[] = $whereVal;
    $g->prepare('UPDATE `' . $table . '` SET ' . implode(',', $set) . ' WHERE `' . $whereCol . '`=?')->execute($vals);
}

function ghost_set(PDO $g, string $key, string $value, string $ownerId): void
{
    if (!ghost_has($g, 'settings')) {
        return;
    }
    $st = $g->prepare('SELECT id FROM settings WHERE `key`=? LIMIT 1');
    $st->execute([$key]);
    $id = $st->fetchColumn();
    $now = gmdate('Y-m-d H:i:s');
    if (is_string($id) && $id !== '') {
        ghost_update($g, 'settings', ['value' => $value, 'updated_at' => $now, 'updated_by' => $ownerId], 'id', $id);
        return;
    }
    ghost_insert($g, 'settings', [
        'id' => ghost_id(),
        'group' => 'site',
        'key' => $key,
        'value' => $value,
        'type' => 'string',
        'created_at' => $now,
        'created_by' => $ownerId,
        'updated_at' => $now,
        'updated_by' => $ownerId,
    ]);
}

function wp_dt(?string $s): string
{
    if ($s === null || $s === '' || $s === '0000-00-00 00:00:00') {
        return gmdate('Y-m-d H:i:s');
    }
    $t = strtotime($s);
    return $t ? gmdate('Y-m-d H:i:s', $t) : gmdate('Y-m-d H:i:s');
}

function strip_wp_comments(string $html): string
{
    $html = preg_replace('/<!--\s*\/?wp:.*?-->/s', '', $html) ?? $html;
    return trim($html);
}

function unsize_thumbs(string $s): string
{
    return preg_replace('/-\d+x\d+(\.(?:jpe?g|png|gif|webp|avif))/i', '$1', $s) ?? $s;
}

function rewrite_to_ghost(string $html, string $siteUrl, string $uploadBaseurl): string
{
    $html = unsize_thumbs($html);
    $from = [
        $uploadBaseurl . '/',
        rtrim($siteUrl, '/') . '/wp-content/uploads/',
        '/wp-content/uploads/',
    ];
    $to = [
        '__GHOST_URL__/content/images/',
        '__GHOST_URL__/content/images/',
        '/content/images/',
    ];
    return str_replace($from, $to, $html);
}

function html_to_lexical(string $html): string
{
    return (string) json_encode([
        'root' => [
            'children' => [[
                'type' => 'html',
                'version' => 1,
                'html' => $html,
            ]],
            'direction' => 'ltr',
            'format' => '',
            'indent' => 0,
            'type' => 'root',
            'version' => 1,
        ],
    ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}

function html_to_mobiledoc(string $html): string
{
    return (string) json_encode([
        'version' => '0.3.1',
        'atoms' => [],
        'cards' => [['html', ['html' => $html]]],
        'markups' => [],
        'sections' => [[10, 0]],
    ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
}

function plaintext_of(string $html): string
{
    $t = html_entity_decode(strip_tags($html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $t = preg_replace('/\s+/', ' ', $t) ?? $t;
    return trim($t);
}

function copy_uploads(string $src, string $dest, bool $dry): int
{
    $n = 0;
    if (!is_dir($src)) {
        return 0;
    }
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($src, FilesystemIterator::SKIP_DOTS));
    foreach ($it as $file) {
        /** @var SplFileInfo $file */
        if (!$file->isFile()) {
            continue;
        }
        $full = $file->getPathname();
        $rel = ltrim(str_replace('\\', '/', substr($full, strlen(rtrim($src, '/')))), '/');
        if (preg_match('/-\d+x\d+\.(?:jpe?g|png|gif|webp|avif)$/i', $rel)) {
            continue;
        }
        if (preg_match('/(?:^|\/)(?:\.|index\.php$|\.htaccess$)/', $rel)) {
            continue;
        }
        $n++;
        if ($dry || $dest === '') {
            continue;
        }
        $out = $dest . '/' . $rel;
        $dir = dirname($out);
        if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
            fwrite(STDERR, "mkdir failed: {$dir}\n");
            continue;
        }
        if (!is_file($out)) {
            copy($full, $out);
        }
        @chown($out, 'ghost');
        @chgrp($out, 'ghost');
    }
    return $n;
}

function import_tags(PDO $g, string $ownerId, bool $dry): array
{
    $map = [];
    $terms = get_terms(['taxonomy' => 'post_tag', 'hide_empty' => false]);
    if (!is_array($terms) || is_wp_error($terms)) {
        return $map;
    }
    $now = gmdate('Y-m-d H:i:s');
    foreach ($terms as $t) {
        $slug = (string) $t->slug;
        $name = (string) $t->name;
        if ($slug === '' || $name === '') {
            continue;
        }
        if ($dry) {
            $map[(int) $t->term_id] = ghost_id();
            continue;
        }
        $st = $g->prepare('SELECT id FROM tags WHERE slug=? LIMIT 1');
        $st->execute([$slug]);
        $gid = $st->fetchColumn();
        if (is_string($gid) && $gid !== '') {
            $map[(int) $t->term_id] = $gid;
            continue;
        }
        $gid = ghost_id();
        ghost_insert($g, 'tags', [
            'id' => $gid,
            'name' => $name,
            'slug' => $slug,
            'description' => (string) $t->description,
            'visibility' => 'public',
            'created_at' => $now,
            'created_by' => $ownerId,
            'updated_at' => $now,
            'updated_by' => $ownerId,
        ]);
        $map[(int) $t->term_id] = $gid;
    }
    return $map;
}

function import_posts(PDO $g, string $ownerId, array $termMap, string $siteUrl, string $uploadBaseurl, bool $dry): array
{
    $map = [];
    $q = new WP_Query([
        'post_type' => ['post', 'page'],
        'post_status' => ['publish', 'draft', 'future', 'private', 'pending'],
        'posts_per_page' => -1,
        'orderby' => 'date',
        'order' => 'ASC',
        'ignore_sticky_posts' => true,
    ]);
    foreach ($q->posts as $p) {
        $type = $p->post_type === 'page' ? 'page' : 'post';
        $status = match ((string) $p->post_status) {
            'publish' => 'published',
            'future' => 'scheduled',
            default => 'draft',
        };
        $vis = $p->post_status === 'private' ? 'members' : 'public';
        $html = strip_wp_comments((string) $p->post_content);
        $html = rewrite_to_ghost($html, $siteUrl, $uploadBaseurl);
        $slug = (string) ($p->post_name !== '' ? $p->post_name : sanitize_title((string) $p->post_title));
        $feat = '';
        $thumb = get_post_thumbnail_id($p->ID);
        if ($thumb) {
            $src = wp_get_attachment_image_url((int) $thumb, 'full');
            if (is_string($src) && $src !== '') {
                $feat = rewrite_to_ghost(unsize_thumbs($src), $siteUrl, $uploadBaseurl);
            }
        }
        $pub = wp_dt((string) ($p->post_date_gmt ?: $p->post_date));
        $upd = wp_dt((string) ($p->post_modified_gmt ?: $p->post_modified));
        if ($dry) {
            $map[(int) $p->ID] = ghost_id();
            echo "  [dry-run] {$type} /{$slug} {$status}\n";
            continue;
        }
        $st = $g->prepare('SELECT id FROM posts WHERE slug=? AND type=? LIMIT 1');
        $st->execute([$slug, $type]);
        $gid = $st->fetchColumn();
        $row = [
            'uuid' => ghost_uuid(),
            'title' => (string) $p->post_title,
            'slug' => $slug,
            'html' => $html,
            'plaintext' => plaintext_of($html),
            'lexical' => html_to_lexical($html),
            'mobiledoc' => html_to_mobiledoc($html),
            'feature_image' => $feat !== '' ? $feat : null,
            'featured' => is_sticky($p->ID) ? 1 : 0,
            'type' => $type,
            'status' => $status,
            'visibility' => $vis,
            'custom_excerpt' => (string) $p->post_excerpt,
            'created_at' => $pub,
            'created_by' => $ownerId,
            'updated_at' => $upd,
            'updated_by' => $ownerId,
            'published_at' => in_array($status, ['published', 'scheduled'], true) ? $pub : null,
            'published_by' => $ownerId,
            'show_title_and_feature_image' => 1,
        ];
        if (is_string($gid) && $gid !== '') {
            ghost_update($g, 'posts', $row, 'id', $gid);
        } else {
            $gid = ghost_id();
            $row['id'] = $gid;
            ghost_insert($g, 'posts', $row);
        }
        $map[(int) $p->ID] = $gid;
        if (ghost_has($g, 'posts_authors')) {
            $g->prepare('DELETE FROM posts_authors WHERE post_id=?')->execute([$gid]);
            ghost_insert($g, 'posts_authors', [
                'id' => ghost_id(),
                'post_id' => $gid,
                'author_id' => $ownerId,
                'sort_order' => 0,
            ]);
        }
        if ($type === 'post' && ghost_has($g, 'posts_tags')) {
            $g->prepare('DELETE FROM posts_tags WHERE post_id=?')->execute([$gid]);
            $tags = wp_get_post_terms($p->ID, 'post_tag');
            $ord = 0;
            if (is_array($tags) && !is_wp_error($tags)) {
                foreach ($tags as $tg) {
                    $tid = $termMap[(int) $tg->term_id] ?? '';
                    if ($tid === '') {
                        continue;
                    }
                    ghost_insert($g, 'posts_tags', [
                        'id' => ghost_id(),
                        'post_id' => $gid,
                        'tag_id' => $tid,
                        'sort_order' => $ord++,
                    ]);
                }
            }
        }
    }
    return $map;
}

function import_menus(PDO $g, array $postMap, string $siteUrl, bool $dry): void
{
    $items = [];
    $locs = get_nav_menu_locations();
    $menuId = 0;
    foreach (['primary', 'primary-menu', 'menu-1', 'main-menu'] as $loc) {
        if (!empty($locs[$loc])) {
            $menuId = (int) $locs[$loc];
            break;
        }
    }
    if ($menuId < 1) {
        $menus = wp_get_nav_menus();
        if (is_array($menus) && $menus !== []) {
            $menuId = (int) $menus[0]->term_id;
        }
    }
    if ($menuId < 1) {
        return;
    }
    $nav = wp_get_nav_menu_items($menuId);
    if (!is_array($nav)) {
        return;
    }
    foreach ($nav as $it) {
        if ((int) $it->menu_item_parent !== 0) {
            continue;
        }
        $label = (string) $it->title;
        $url = (string) $it->url;
        if ($url === '' || $url === $siteUrl || $url === $siteUrl . '/') {
            $url = '/';
        } else {
            $path = (string) (parse_url($url, PHP_URL_PATH) ?: $url);
            $url = $path === '' ? '/' : $path;
        }
        $items[] = ['label' => $label, 'url' => $url];
    }
    if ($items === []) {
        return;
    }
    $json = (string) json_encode($items, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    if ($dry) {
        echo '[dry-run] navigation: ' . count($items) . " items\n";
        return;
    }
    ghost_set($g, 'navigation', $json, ghost_owner_id($g));
}
