#!/usr/bin/php
<?php
/**
 * One-time / idempotent: fit <img> in existing WordPress post_content so
 * pictures cannot overflow the post body. Uses imgfit.php (same as ghost2wp).
 *
 *   php /opt/verb/conf/lib/vapptools/wpfitimages.php \
 *     --wp-root=/srv/www/vapps/wp.formosan.dog \
 *     --site-url=https://formosan.dog
 *
 * Reads vapp credentials via wp-config.php (installwp wrote those from
 * verb/conf/vapps/vapp.wp.DOMAIN). Does not touch the Ghost database.
 */
declare(strict_types=1);

require_once __DIR__ . '/imgfit.php';

$opt = getopt('', ['wp-root:', 'site-url:', 'dry-run', 'help']);
if (isset($opt['help']) || empty($opt['wp-root'])) {
    fwrite(STDERR, <<<TXT
Fit images in WordPress post/page HTML (max-width:100%; height:auto; keep wrap/align).

Required:
  --wp-root=DIR     WordPress root (wp-config.php)

Optional:
  --site-url=URL    Public URL (sets HTTP_HOST only)
  --dry-run         Print what would change; no writes

TXT);
    exit(isset($opt['help']) ? 0 : 5);
}

$wpRoot = rtrim((string) $opt['wp-root'], '/');
$dry = isset($opt['dry-run']);
$siteUrl = rtrim((string) ($opt['site-url'] ?? ''), '/');

if (!is_file($wpRoot . '/wp-config.php')) {
    fwrite(STDERR, "No wp-config.php in {$wpRoot}.\n");
    exit(8);
}

$_SERVER['HTTP_HOST'] = (string) (parse_url($siteUrl !== '' ? $siteUrl : 'https://localhost', PHP_URL_HOST) ?: 'localhost');
$_SERVER['REQUEST_URI'] = '/';
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['HTTPS'] = 'on';
if (!defined('WP_USE_THEMES')) {
    define('WP_USE_THEMES', false);
}
if (!defined('DISABLE_WP_CRON')) {
    define('DISABLE_WP_CRON', true);
}

chdir($wpRoot);
require $wpRoot . '/wp-load.php';

global $wpdb;
$installed = $wpdb->get_var("SHOW TABLES LIKE '{$wpdb->posts}'");
if (!$installed) {
    fwrite(STDERR, "No WordPress posts table in this database.\n");
    exit(8);
}

$ids = $wpdb->get_col(
    "SELECT ID FROM {$wpdb->posts}
     WHERE post_type IN ('post','page')
       AND post_status NOT IN ('auto-draft','inherit')
     ORDER BY ID"
);

$checked = 0;
$changed = 0;
foreach ($ids as $id) {
    $id = (int) $id;
    $post = get_post($id);
    if (!$post) {
        continue;
    }
    $checked++;
    $old = (string) $post->post_content;
    $new = imgfit_html($old);
    if ($new === $old) {
        continue;
    }
    $changed++;
    if ($dry) {
        echo "[dry-run] would fit images in {$post->post_type} ID {$id} ({$post->post_name})\n";
        continue;
    }
    $wpdb->update(
        $wpdb->posts,
        [
            'post_content' => $new,
            'post_modified' => current_time('mysql'),
            'post_modified_gmt' => current_time('mysql', true),
        ],
        ['ID' => $id]
    );
    clean_post_cache($id);
    echo "Fitted images in {$post->post_type} ID {$id} ({$post->post_name})\n";
}

echo ($dry ? '[dry-run] ' : '') . "Checked {$checked} posts/pages, " . ($dry ? 'would update' : 'updated') . " {$changed}.\n";
exit(0);
