<?php

/*
 +-----------------------------------------------------------------------+
 | Local configuration for the Roundcube Webmail installation.           |
 |                                                                       |
 | This is a sample configuration file only containing the minimum       |
 | setup required for a functional installation. Copy more options       |
 | from defaults.inc.php to this file to override the defaults.          |
 |                                                                       |
 | This file is part of the Roundcube Webmail client                     |
 | Copyright (C) 2005-2013, The Roundcube Dev Team                       |
 |                                                                       |
 | Licensed under the GNU General Public License version 3 or            |
 | any later version with exceptions for skins & plugins.                |
 | See the README file for a full license statement.                     |
 +-----------------------------------------------------------------------+
*/

$config = array();

$config['enable_installer'] = false;

// Database connection string (DSN) for read+write operations
// Format (compatible with PEAR MDB2): db_provider://user:password@host/database
// Currently supported db_providers: mysql, pgsql, sqlite, mssql, sqlsrv, oracle
// For examples see http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
// NOTE: for SQLite use absolute path (Linux): 'sqlite:////full/path/to/sqlite.db?mode=0646'
//       or (Windows): 'sqlite:///C:/full/path/to/sqlite.db'
// $config['db_dsnw'] = 'mysql://username:password@localhost/database';
$config['db_dsnw'] = 'mysql://rcmailusr:rcpass286@localhost/rcmail';

// The mail host chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
$config['imap_host'] = 'tls://imap.nameURI286';

// SMTP server host (for sending mails).
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// If left blank, the PHP mail() function is used
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
//$config['smtp_host'] = 'localhost'; // This breaks the SMTP sending
//$config['smtp_host'] = 'ssl://mail.nameURI286';
$config['smtp_host'] = 'tls://smtp.nameURI286';

// SMTP port (default is 25; use 587 for STARTTLS or 465 for the
// deprecated SSL over SMTP (aka SMTPS))
//$config['smtp_port'] = 465;
$config['smtp_port'] = 587;
$config['smtp_auth_type'] = 'LOGIN';

// SMTP username (if required) if you use %u as the username Roundcube
// will use the current username for login

$config['smtp_user'] = '%u';

// SMTP password (if required) if you use %p as the password Roundcube
// will use the current user's password for login
$config['smtp_pass'] = '%p';

// Automatically add this domain to user names for login
// Only for IMAP servers that require full e-mail addresses for login
// Specify an array with 'host' => 'domain' values to support multiple hosts
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
//$config['username_domain'] = '%n';
$config['username_domain'] = '%d';

// Name your service. This is displayed on the login screen and in the window title
$config['product_name'] = 'nameURI286 Roundcube webmail';

// specify an URL relative to the document root of this Roundcube installation
//$config['support_url'] = 'http://nameURI286'; // Disabling this until a RC becomes stable and a useful support page can be created
$config['support_url'] = '';

// replace Roundcube logo with this image
// specify an URL relative to the document root of this Roundcube installation
// an array can be used to specify different logos for specific template files, '*' for default logo
// for example array("*" => "/images/roundcube_logo.png", "messageprint" => "/images/roundcube_logo_print.png")
$config['skin_logo'] = 'verbink_logo.png';

// e.g. array( 'localhost:6379' );  array( '192.168.1.1:6379:1:secret' );
// check client IP in session authorization
$config['ip_check'] = true;

// this key is used to encrypt the users imap password which is stored
// in the session record (and the client cookie if remember password is enabled).
// please provide a string of exactly 24 chars.
// YOUR KEY MUST BE DIFFERENT THAN THE SAMPLE VALUE FOR SECURITY REASONS
$config['des_key'] = 'rcemailconfdeskeysalt286';

// inkVerb to limit mail sending rates
// How many seconds must pass between emails sent by a user
$config['sendmail_delay'] = 12;

// Maximum number of recipients per message. Default: 0 (no limit)
$config['max_recipients'] = 50;

// Maximum allowednumber of members of an address group. Default: 0 (no limit)
// If 'max_recipients' is set this value should be less or equal
$config['max_group_members'] = 50;

// List of active plugins (in plugins/ directory)
$config['plugins'] = array('archive','filesystem_attachments','hide_blockquote','identity_select','jqueryui','newmail_notifier','vcard_attachments','virtuser_file','zipdownload');
// Omitted: 'password',

// the default locale setting (leave empty for auto-detection)
// RFC1766 formatted language name like en_US, de_DE, de_CH, fr_FR, pt_BR
$config['language'] = 'en_US';

// compose html formatted messages by default
// 0 - never, 1 - always, 2 - on reply to HTML message, 3 - on forward or reply to HTML message
$config['htmleditor'] = 1;

// save compose message every 300 seconds (5min)
$config['draft_autosave'] = 180;

// inkVerb: Below are already set in defaults.inc.php. Uncomment to use alternate settings.

// skin name: folder from skins/
$config['skin'] = 'elastic';

// Interface layout. Default: 'widescreen'.
//  'widescreen' - three columns
//  'desktop'    - two columns, preview on bottom
//  'list'       - two columns, no preview
//$config['layout'] = 'widescreen';

// automatically create the above listed default folders on user login
// inkVerb: Postfix Admin won't create them because it requires www to own /srv/vmail, which must be owned by vmail:mail
//$config['create_default_folders'] = true;

// protect the default folders from renames, deletes, and subscription changes
//$config['protect_default_folders'] = faltruese;

// Disable localization of the default folder names listed above
//$config['show_real_foldernames'] = false;

// For STARTTLS IMAP
$config['imap_conn_options'] = array(
    'ssl' => array(
      'verify_peer'       => true,
      // inkCert
      'allow_self_signed' => false,
      'ssl_cert' => '/etc/ssl/private/vmail.crt',
      'ssl_key'  => '/etc/ssl/private/vmail.key',
      // Snakeoil
      //'allow_self_signed' => true,
      //'ssl_cert' => '/etc/ssl/server/server.crt',
      //'ssl_key'  => '/etc/ssl/server/server.key',
      // probably optional parameters
      //'ciphers' => 'TLSv1+HIGH:!aNull:@STRENGTH',
      //'peer_name'         => 'nameURI286',
    ),
);
// For STARTTLS SMTP
$config['smtp_conn_options'] = array(
    'ssl' => array(
      'verify_peer'       => true,
      // inkCert
      'allow_self_signed' => false,
      'ssl_cert' => '/etc/ssl/private/vmail.crt',
      'ssl_key'  => '/etc/ssl/private/vmail.key',
      // Snakeoil
      //'allow_self_signed' => true,
      //'ssl_cert' => '/etc/ssl/server/server.crt',
      //'ssl_key'  => '/etc/ssl/server/server.key',
      // probably optional parameters
      //'ciphers' => 'TLSv1+HIGH:!aNull:@STRENGTH',
      //'peer_name'         => 'nameURI286',
    ),
);
