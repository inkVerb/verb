<?php
/**
 * Fit <img> (and wrapping <figure>) so media cannot overflow the post body.
 * Used by ghost2wp, wp2ghost, and the one-time wpfitimages cleaner.
 *
 * Keeps wrap/float/align, percent widths, and Ghost kg-width-* / WP align* classes.
 * If nothing constrains the image, sets max-width:100%;height:auto.
 * Pixel CSS widths (the Ghost kg-image width="2488" / style="width:2488px" problem)
 * are dropped so the browser uses intrinsic width only as a hint.
 */
declare(strict_types=1);

function imgfit_html(string $html): string
{
    if ($html === '' || !str_contains(strtolower($html), '<img') && !str_contains(strtolower($html), '<figure')) {
        return $html;
    }
    $html = preg_replace_callback('/<figure\b[^>]*>/i', static function (array $m): string {
        return imgfit_open_tag($m[0], 'figure');
    }, $html) ?? $html;
    $html = preg_replace_callback('/<img\b[^>]*>/i', static function (array $m): string {
        return imgfit_open_tag($m[0], 'img');
    }, $html) ?? $html;
    return $html;
}

function imgfit_image_tag(string $src, string $alt = '', array $extra = []): string
{
    $attrs = [
        'src' => $src,
        'alt' => $alt,
    ];
    if (!empty($extra['width']) && (int) $extra['width'] > 0) {
        $attrs['width'] = (string) (int) $extra['width'];
    }
    if (!empty($extra['height']) && (int) $extra['height'] > 0) {
        $attrs['height'] = (string) (int) $extra['height'];
    }
    $card = strtolower((string) ($extra['cardWidth'] ?? $extra['card_width'] ?? 'regular'));
    $figClass = ['kg-card', 'kg-image-card'];
    if ($card === 'wide') {
        $figClass[] = 'kg-width-wide';
        $figClass[] = 'alignwide';
    } elseif ($card === 'full') {
        $figClass[] = 'kg-width-full';
        $figClass[] = 'alignfull';
    }
    $img = imgfit_open_tag('<img src="" alt="">', 'img', $attrs);
    if (!empty($extra['href'])) {
        $href = htmlspecialchars((string) $extra['href'], ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
        $img = '<a href="' . $href . '">' . $img . '</a>';
    }
    $cap = trim((string) ($extra['caption'] ?? ''));
    $fig = '<figure class="' . htmlspecialchars(implode(' ', $figClass), ENT_QUOTES) . '">' . $img;
    if ($cap !== '') {
        $fig .= '<figcaption>' . $cap . '</figcaption>';
    }
    $fig .= '</figure>';
    return imgfit_html($fig);
}

function imgfit_open_tag(string $tag, string $name, ?array $forced = null): string
{
    $attrs = $forced ?? imgfit_parse_attrs($tag);
    $class = preg_split('/\s+/', trim((string) ($attrs['class'] ?? ''))) ?: [];
    $class = array_values(array_filter($class, static fn($c) => $c !== ''));
    $classL = array_map('strtolower', $class);

    if (in_array('kg-width-wide', $classL, true) && !in_array('alignwide', $classL, true)) {
        $class[] = 'alignwide';
        $classL[] = 'alignwide';
    }
    if (in_array('kg-width-full', $classL, true) && !in_array('alignfull', $classL, true)) {
        $class[] = 'alignfull';
        $classL[] = 'alignfull';
    }

    $style = imgfit_parse_style((string) ($attrs['style'] ?? ''));
    $style = imgfit_constrain_style($style, $classL, $name);
    if ($class !== []) {
        $attrs['class'] = implode(' ', $class);
    }
    $built = imgfit_style_string($style);
    if ($built !== '') {
        $attrs['style'] = $built;
    } else {
        unset($attrs['style']);
    }

    $self = strtolower($name) === 'img' || str_ends_with(rtrim($tag), '/>');
    $out = '<' . $name;
    foreach ($attrs as $k => $v) {
        $out .= ' ' . $k . '="' . str_replace(['&', '"'], ['&', '"'], (string) $v) . '"';
    }
    $out .= $self ? '>' : '>';
    return $out;
}

function imgfit_parse_attrs(string $tag): array
{
    $attrs = [];
    if (!preg_match_all('/([a-zA-Z_:][a-zA-Z0-9:._-]*)\s*=\s*(["\'])(.*?)\2/s', $tag, $m, PREG_SET_ORDER)) {
        return $attrs;
    }
    foreach ($m as $a) {
        $attrs[strtolower($a[1])] = html_entity_decode($a[3], ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }
    return $attrs;
}

function imgfit_parse_style(string $style): array
{
    $map = [];
    foreach (explode(';', $style) as $part) {
        $part = trim($part);
        if ($part === '' || !str_contains($part, ':')) {
            continue;
        }
        [$k, $v] = explode(':', $part, 2);
        $k = strtolower(trim($k));
        $v = trim($v);
        if ($k !== '' && $v !== '') {
            $map[$k] = $v;
        }
    }
    return $map;
}

function imgfit_style_string(array $map): string
{
    $out = [];
    foreach ($map as $k => $v) {
        if ($v === '') {
            continue;
        }
        $out[] = $k . ':' . $v;
    }
    return implode(';', $out);
}

function imgfit_constrain_style(array $style, array $classL, string $name): array
{
    $width = $style['width'] ?? '';
    $isPct = (bool) preg_match('/^\d+(\.\d+)?\s*%/', $width);
    $isPx = (bool) preg_match('/^\d+(\.\d+)?\s*px/i', $width);
    $isAuto = strtolower($width) === 'auto';

    if ($isPx) {
        unset($style['width']);
        $width = '';
        $isPct = false;
        $isAuto = false;
    }

    if (!isset($style['max-width']) && !$isPct) {
        $style['max-width'] = '100%';
    }

    $height = $style['height'] ?? '';
    if ($height === '' || preg_match('/px/i', $height) || strtolower($height) === 'auto') {
        $style['height'] = 'auto';
    }

    if (in_array('alignleft', $classL, true) && !isset($style['float'])) {
        $style['float'] = 'left';
        $style['margin'] = $style['margin'] ?? '0 1em 1em 0';
        if (!isset($style['max-width'])) {
            $style['max-width'] = '100%';
        }
    }
    if (in_array('alignright', $classL, true) && !isset($style['float'])) {
        $style['float'] = 'right';
        $style['margin'] = $style['margin'] ?? '0 0 1em 1em';
    }
    if (in_array('aligncenter', $classL, true) && ($style['display'] ?? '') !== 'inline' && ($style['display'] ?? '') !== 'inline-block') {
        $style['display'] = $style['display'] ?? 'block';
        $style['margin-left'] = $style['margin-left'] ?? 'auto';
        $style['margin-right'] = $style['margin-right'] ?? 'auto';
    }

    $display = strtolower((string) ($style['display'] ?? ''));
    if ($display === '' && $name === 'img' && !isset($style['float'])) {
        $isInline = in_array('kg-image', $classL, true) === false && (in_array('alignnone', $classL, true) || $display === 'inline');
        if (!$isInline) {
            $style['display'] = 'block';
        }
    }

    if (!isset($style['width']) && !$isPct && !$isAuto) {
        $style['width'] = 'auto';
    }

    return $style;
}
