<?php

$Conf['configured'] = true;

#$Conf['setup_password'] = 'changeme';


$Conf['postfix_admin_url'] = 'https://po.emailTLDURI286/pfafolder286';

$Conf['default_language'] = 'en';

$Conf['language_hook'] = '';

$Conf['database_type'] = 'mysqli';
$Conf['database_host'] = 'localhost';
$Conf['database_user'] = 'mail';
$Conf['database_password'] = 'mailpassword';
$Conf['database_name'] = 'mail';

$Conf['database_prefix'] = '';
$Conf['database_tables'] = array (
    'admin' => 'admin',
    'alias' => 'alias',
    'alias_domain' => 'alias_domain',
    'config' => 'config',
    'domain' => 'domain',
    'domain_admins' => 'domain_admins',
    'fetchmail' => 'fetchmail',
    'log' => 'log',
    'mailbox' => 'mailbox',
    'vacation' => 'vacation',
    'vacation_notification' => 'vacation_notification',
    'quota' => 'quota',
	'quota2' => 'quota2',
);

$Conf['admin_email'] = 'admin@nameURI286';

$Conf['smtp_server'] = 'localhost';
$Conf['smtp_port'] = '25';

#$Conf['encrypt'] = 'dovecot:SHA512-CRYPT'; # More secure, but Postfix Admin breaks; agree with /etc/dovecot/dovecot-sql.conf

$Conf['authlib_default_flavor'] = 'md5raw';

$Conf['dovecotpw'] = "/usr/sbin/doveadm pw";

$Conf['password_validation'] = array(
#    '/regular expression/' => '$PALANG key (optional: + parameter)',
    '/.{5}/'                => 'password_too_short 5',      # minimum length 5 characters
    '/([a-zA-Z].*){3}/'     => 'password_no_characters 3',  # must contain at least 3 letters (A-Z, a-z)
    '/([0-9].*){2}/'        => 'password_no_digits 2',      # must contain at least 2 digits
);

$Conf['generate_password'] = 'NO';

$Conf['show_password'] = 'NO';

$Conf['page_size'] = '500';

$Conf['default_aliases'] = array (
    'abuse' => 'abuse@nameURI286',
    'hostmaster' => 'hostmaster@nameURI286',
    'postmaster' => 'postmaster@nameURI286',
    'webmaster' => 'webmaster@nameURI286'
);

$Conf['domain_path'] = 'YES';

$Conf['domain_in_mailbox'] = 'NO';

$Conf['maildir_name_hook'] = 'NO';

$Conf['aliases'] = '1000';
$Conf['mailboxes'] = '1000';
$Conf['maxquota'] = '1000';
$Conf['domain_quota_default'] = '2048';

$Conf['quota'] = 'YES';

$Conf['domain_quota'] = 'YES';

$Conf['quota_multiplier'] = '1048576';


$Conf['transport'] = 'NO';

$Conf['transport_options'] = array (
    'virtual',
    'local',
    'relay'
);

$Conf['transport_default'] = 'virtual';

$Conf['vacation'] = 'YES';

$Conf['vacation_domain'] = 'away.nameURI286';

$Conf['vacation_control'] ='YES';

$Conf['vacation_control_admin'] = 'YES';

$Conf['vacation_choice_of_reply'] = array (
   0 => 'reply_once',        // Sends only Once the message during Out of Office
   # considered annoying - only send a reply on every mail if you really need it
   # 1 => 'reply_every_mail',       // Reply on every email
   60*60 *24*7 => 'reply_once_per_week'        // Reply if last autoreply was at least a week ago
);


$Conf['alias_control'] = 'YES';

$Conf['alias_control_admin'] = 'YES';

$Conf['special_alias_control'] = 'NO';

$Conf['alias_goto_limit'] = '0';

$Conf['alias_domain'] = 'YES';

$Conf['backup'] = 'YES';

$Conf['sendmail'] = 'YES';

$Conf['logging'] = 'YES';

$Conf['fetchmail'] = 'NO';

$Conf['fetchmail_extra_options'] = 'NO';

$Conf['show_header_text'] = 'YES';
$Conf['header_text'] = '';

$Conf['show_footer_text'] = 'YES';
$Conf['footer_text'] = 'Login to inkVerb webmail';
$Conf['footer_link'] = 'https://box.emailTLDURI286/rcfolder286';

$Conf['motd_user'] = 'Ink is a verb. So, get inking!';
$Conf['motd_admin'] = 'Ink is a verb. So, get inking!';
$Conf['motd_superadmin'] = 'Ink is a verb. So, get inking!';

$Conf['welcome_text'] = <<<EOM
Welcome to inkVerb email! This is the real-deal.

- Email accounts & forwarding are managed at po.emailTLDURI286/pfafolder286

- Use your favorite client (iPhone Mail, Outlook, Thunderbird, etc.)

- Info for email clients:

SMTP:   mail.EMAIL.DOMAIN   Port: 465 (SSL/TLS) 587 (STARTTLS)
IMAP:   mail.EMAIL.DOMAIN   Port: 993 (SSL/TLS) 143 (STARTTLS)
POP3:   mail.EMAIL.DOMAIN   Port: 995 (SSL/TLS) 110 (STARTTLS)

Authentication: Normal password
Username: [your username/email address]
Password: [your login password]

- You may also use webmail at: box.emailTLDURI286/rcfolder286

- You may also set up inside Gmail:

Gmail Part 1: Send "from" another email
Go to: Settings > Accounts and Import > Send mail as: > Add another email address you own...
Enter your email address ('Treat as alias' can be either option)...
On the page with SMTP settings, choose Port 587, TLS, and the password you set in your account at po.emailTLDURI286.

Gmail Part 2 (Option A): POP into your emailbox you set up at po.emailTLDURI286/pfafolder286
Go to: Settings > See all settings > Accounts and Import > Check mail from other accunts: > "Add a mail account" ...Then follow the steps to add the emailbox you created at po.emailTLDURI286/pfafolder286.

Gmail Part 2 (Option B): Forward to your Gmail
Rather than doing a POP from Gmail into the emailbox created at po.emailTLDURI286/pfafolder286, set up that same emailbox at po.emailTLDURI286/pfafolder286 to "Forward" or "Alias" to your Gmail.

*NOTE about Gmail: If you change your password or update the server, you'll also have to update/revisit the same settings in Gmail.
To change the Gmail settings later: Settings > Accounts and Import > Send mail as/Check mail from other accunts > [your email] - "edit info"

*NOTE about forwarding addresses: If you want to use one email address to send mail "from" a separate forwarding address, the "from" address must be the same domain and must forward to the sending address. For example. If you use "forwards@inkisaverb.com" to send mail via SMTP, but you want to use the "From" identity address as "jimmy@inkisaverb.com", then in Alias/Forwarding settings, "jimmy@inkisaverb.com" must be set to forward emails to "forwards@inkisaverb.com".

Thanks for using this real-deal, genuine email server for your email. And, remember...

Ink is a verb. So, ink!
EOM;

$Conf['emailcheck_resolve_domain']='YES';

$Conf['show_status']='YES';

$Conf['show_status_key']='YES';

$Conf['show_status_text']='&nbsp;&nbsp;';

$Conf['show_undeliverable']='YES';
$Conf['show_undeliverable_color']='tomato';

$Conf['show_undeliverable_exceptions']=array("unixmail.domain.ext","exchangeserver.domain.ext","nameURI286","gmail.com","hotmail.com","inkisaverb.com","yahoo.com");
$Conf['show_popimap']='YES';
$Conf['show_popimap_color']='darkgrey';

$Conf['show_custom_domains']=array("nameURI286");
$Conf['show_custom_colors']=array("#111111");

$Conf['recipient_delimiter'] = "+";

$Conf['mailbox_postcreation_script'] = '';

$Conf['mailbox_postedit_script'] = '';

$Conf['mailbox_postdeletion_script'] = '';

$Conf['domain_postcreation_script'] = '';

$Conf['domain_postdeletion_script'] = '';

$Conf['create_mailbox_subdirs'] = array('Archive','Drafts','Junk','Sent','Trash');
//$Conf['create_mailbox_subdirs'] = array();

$Conf['create_mailbox_subdirs_host']='localhost';

$Conf['create_mailbox_subdirs_prefix']='';

$Conf['used_quotas'] = 'NO';

$Conf['new_quota_table'] = 'YES';

$Conf['create_mailbox_subdirs_hostoptions'] = array('');

$Conf['theme_logo'] = 'images/logo-ink.png';

$Conf['theme_favicon'] = 'images/favicon-ink.ico';

$Conf['theme_css'] = 'css/default.css';

$Conf['theme_custom_css'] = '';

$Conf['xmlrpc_enabled'] = false;

/* vim: set expandtab softtabstop=4 tabstop=4 shiftwidth=4: */
