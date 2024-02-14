This dev/ folder will be deleted upon running `setup`

# Dev Notes

Version numbers after the first decimal always use two digits and leading zeros: 1.05.00, never 1.5 nor 1.5.1 etc

Developer release version numbers never end in 0. This reserves the final number of the stable channel for vital updates.

eg:

stable version examples:

- 1.04.00 (main release with new features)
- 1.04.10 (vital update, no new features)
- 1.04.13 (small update, no new features)
- 1.04.20 (vital update, no new features)
- 1.05.00 (main release with new features)

develper version examples:

- 1.04.03 (developer testing release)
- (NEVER 1.04.10)
- 1.04.19 (developer testing release)
- (NEVER 1.04.20)
- 1.04.21 (developer testing release)
- 1.04.22 (developer testing release)

## Note on Updates
Note: Update version numbers reference the framework. Ongoing updates continue for the serfs, etc job scripts. Framework needs version rated, sequential alteration, which is why "version" numbers apply to them. Any update will update job scripts and tools, regardless of the current version number.

The "repo" update list at verb/configs/inklists/repoverlist is updated with each update. To customize this, refer to repolinks in the same directory for versions and hashes, and run setrepocust to have your changes stick.

Files updated with `updateverber` can be seen at in several "Update..." blocks at the top of `verb-update/update` from the verb-update repo. These generally include:

- verb/ink
- verb/serfs
- verb/donjon
- verb/conf/lib
- verb/conf/inklists/ (some files, never verberverno)

## File & Script Structure Basics

I. All files are in the "verb" directory
	A. Verber uses a system of "bosses" (users) and "serfs" (bash scripts)
	B. Note basic directory (folder) structures (folder and directory are used interchangeably in verber instructions)
		- verb is the install folder
		- The inst directory will be deleted after install, necessary subdirectories of inst will be moved to where they need to go based on what you run before `setup`
		- First, the verber server must be pre-made (`make-preverber`), then made (`make-verber-laemp`).
		- This is a LAEMP server configuration (Nginx with an Apache reverse proxy for most webapps; some webapps only use Nginx)
		  - `make-verber-lemp` & `make-verber-lamp` are created as frameworks, but are not regularly tested
	C. The "conf" directory is simple and useful, containing many things:
		- MySQL database info for web apps by name
		- Info files: IP address, repo info, special inkVerb namespace, and other settings used by serfs and can be included in other bash scripts
		- Important MySQL configs that allow serfs and the MySQL boss to work with databases quickly, plus the MySQL root password if you ever need it
		- php.ini is only a symlink to the convenient file: php-YOURNAME.ini in configs.

II. "Serfs" (in the 'serfs' directory) are bash scripts that do the chores of the server, with no .sh extension
	A. They update, remove, install, create, etc.
	B. Every serf has instructions inside, many have variables and parameters
	  - Arguments for serf scripts are neither sanitized nor validated
		- Sometimes a serf will check for prerequisites or the number of arguments, but not always
		- Serfs must be run perfectly from the command line with little-to-no forgiveness
	C. "Bosses" are users (Linux, MySQL, etc.) so you don't need to login as root
		1. Bosses have home folders linked to verb, as needed
		2. Bosses are intended as a security option but are not necessary, you can run all serfs as root
		3. Bosses are sudoers and superusers and may require "sudo" if serf instructions require
	D. Serfs are intended to be run sudo by a boss, embedded in server-side scripts, such as PHP, Python, Perl, JS, etc., such as where Linux commands can be embedded for web interface GUI control.
	E. Some serfs deliver messages to help webmasters, but these are not necessarily intended to be displayed through a GUI server-side script
	F. Bosses and serfs leverage the power of verber: one-command installs, comparable to one-click installs.
		1. The most basic boss-serf chore is a MySQL boss creating databases when a serf installs a web app
		2. Serfs "install" web apps on the server without asking quesitons.
		3. The patron (you), then "setup" the web app after the serf "installs" it.
		4. Serfs will create your database, user, and password that you designate when you install a web app.
		5. The WordPress install serf enters the database info into the wp-config for you, so you don't even need it after you define it.
		6. Other web apps, on setup, may ask you for the MySQL database info you designated when you bossed the serf to install it.
		7. After installing an app, the serf should report a message with whatever instructions, databases and setup URL are necessary to finish setting-up the web app.
	G. "inkCert" is the inkVerb SSL serf task
		1. At release of verber, inkCert simply ran Letsencrypt cert scripts, so inkCert = Letsencrypt
		2. By telling serfs to do "inkcert" tasks throughout verber, Letsencrypt certs are fully managed by the verber
		3. inkCert automatically handles installation of mail certs and use in websites
		4. In later plans, inkVerb may become a certificate authority to offer free SSL certificates for all domains and subomains hosted on an inkVerb namespace verber server
		5. inkCert integrates with similar tools like inkDNS and inkDKIM, which automatically manage the DNS zone you need based on what you're doing, including DKIM-signed emails
	H. Backing up and restoring apps - AUTOMATED!!
		1. Use "backup" and "backuprestore" with the "namespace" of the app
		2. An app's "namespace" usually is the "vapps" subdireactory and the install serf "installAPPNAMESPACE"
		3. Use backupemail, etc. for email server backups. Normal backup does NOT work with email or email related apps.
		4. There are several serfs that start with "backup..." and each has instructions
	I. App "namespace"
		1. Every app has a unified name by which it is referred to throughout the server
		2. Email apps are somewhat of an exception
		3. Apps namespace appears in config files, vaps/APP directories, install serfs, etc. They are NOT listed anywhere, you have to just notice them.
	J. Serfs names
		1. Sefs tend to have unified "surnames" at the front of each surf's name so they sort by: task - app - mod |or| app - task - mod
		2. Serfs are surnamed this way to keep larger groups organized, usually depending on which surname would be more common. This is used by yeo.
		3. Serfs only use az09 characters so that APIs and terminal power-users can input them easily, they are not intended for noob humans looking them up as if in a phonebook, though, they do cluster somewhat alphabetically to help humans.
		4. Instructions for serfs exist in each file. THEY ARE NOT NOOB-PROOF! You could destroy your server system if you use a serf incorrectly. Read each file's instructions carefully before using from the command prompt.
		   * Serfs do not and never will have error-check/help functions and they use sh wherever possible; this is to keep their load and size small. Few (usually inkcert) use functions or bash rather than sh because the alternative would have made the files much larger.
		     ** The only exception to error-checking serfs relate to inkNet and inkCert, since those systems include many serfs with complex hierarchies. Their checks can automatically run batch serfs for unmet serf dependencies and prerequesites.
		   * Serfs are intended to be API-friendly/simple to support a "noob-proof" human interface, such as a GUI.
		   * Roadmap Note: A new set of larger "yeomen" bash scripts may be created with error-check/help and functions, which would be intended for Unix command line production.
			* An example yeoman could be "ink-inkinstall" run by a sudoer: $ sudo ink-install appname (for standard settings) or $ sudo ink-install appname -d database -u databaseuser -p databasepassword
			* The yeomen could be written by any contributor and a GUI is a higher roadmap priority. Feel free to pull-request in the repo: verber/yeomen
		5. Some special serfs, such as postinstall- don't always keep namespace tradition because it's not important and we want to keep serf names on the short side
		6. Here are some serf surnames to watch for:
			- install		(everything... web apps, inkVerb services, etc)
			- activate		(similar to install, but for an inkVerb service ready to go)
			- backup		(for apps, etc)
			- web			(web config settings, such as www, wildcard alias, and https redirects)
			- postinstall		(sometimes necessary after installing)
			- point			(domain forwarding)
			- new, add, kill	(users and domains, 'add' builds on an existing service or infrastructure created by 'new' or 'install', such as ftp, inknet, or domains)
			- set			(set/adjust site-wide settings)
			- show			(displays info already setup, that may be needed for other settings)
		7. Serf surnames that do jobs unique to a single service or app often start with the app/service name rather than the task.
			- wp			(WordPress)
			- inkcert (manages Letsencrypt & CertBot)
			- inkdkim (creating & managing OpenDKIM keys)
			- inkdns (managing the DNS zone, automatically populating it to the secondary DNS servers integrated by default)
			- mysql (MySQL on LAMP, MariaDB for LAEMP and LEMP)

III. inst/ contains files only used at installation and updates and some important root-user records
	A. `make-preverber`
		1. Installs basic tools needed before reboot before installing LEMP, etc.
		2. This is intended to work as a "canned", VPS-ready image, such as a VPS snapshot
	B. `make-verber-laemp` (`-lamp`, `-lemp`)
	  1. This needs a numeric argument for swap size in GB, see instructions in file
	  2. Installs all tools needed for a LAEMP Nginx-Apache server before a necessary reboot
	  3. After running, no further Linux package manager installations are needed to install other web tools available on the verber
	  4. One should run regular Linux updates on the verber after this, but it is theoretically not needed for the verber to funciton
	  5. This has no customized settings
	  6. This cannot be reversed (LAEMP can't change to LEMP, etc)
	  7. This links `setubverb` to the serfs directory so it could be run by the same method as any API may handle serfs
	  8. This is intended to work as a "canned", VPS-ready image, such as a VPS snapshot
	  9. The actual web server `.conf` files will be at `verb/conf/webserver/sites-available/nginx/` and/or `verb/conf/webserver/sites-available/httpd/`, which are linked to `/etc/nginx/sites-available` and `/etc/httpd/sites-available` respectively, et cetera
	    - Normal `/etc/nginx` and `/etc/httpd` directory structure will still work seamlessly
		- You can still use normal nginx and httpd enable commands if you choose, but to better honor this structure, use `serfs/ensiteapache` and `serfs/ensitenginx` to enable any sites from the CLI
		  - If you are using the `ink` CLI tool, this won't matter anyway because `ink` will handle this automatically
		- This structure allows easier CLI management of both `nginx` and `httpd` from the `verb/conf/webserver/` folder
	C. `setup`
	  1. This sets the customized user information, namespace, IP addresses, timezones, etc.
	  2. This requires another reboot after completion
      3. Some settings, such as IP4 & IP6 addresses, can be changed after `setup` installation
	  4. Most settings can't be changed after `setup` installation, including the hostname and timezone
	  5. This deletes the inst directory and the `setup` link
	  6. After this reboot, then a little more housekeeping
		  - inkDNS installation
		  - inkCert installation
		  - PostfixVmail installation
		  - Obtain inkCert certs for all "verb" domains
		  - Then the verber is ready to function

IV. The "donjon" - assets or "native apps"
	A. This is where native apps are kept. They may be written in Python or any other language.
	B. These apps are essential for the work of some routine tasks, often tied to cron tasks
	  - List of cron task times: (you may want to either avoid or be aware these times)
	    - `* 4 * * * root /opt/verb/donjon/mysqlbak.sh`
		- `* 5 * * * root /opt/verb/donjon/ldapbak.sh`
		- `15 1 * * * root /opt/verb/donjon/vapp.mysql.vbak.sh`
		- `*/5 * * * * root /opt/verb/donjon/digverbs.sh`
		- `*/5 * * * * root /opt/verb/donjon/digdomain.sh`
		- `*/15 * * * *  www-data php -f /usr/share/webapps/nextcloud/cron.php`
		- `* * * * * cd /srv/www/vapps/suitecrm; php -f cron.php > /dev/null 2>&1`
		- `22 * * * * root /opt/verb/donjon/sysmails.sh phpmail`/`msmtp`
		- `44 * * * * root /opt/verb/donjon/sysmails.sh nextcloud`
		- `14,44 * * * * root /opt/verb/donjon/rmdldirs.sh`
		- `15,55 * * * * root /opt/verb/conf/inknet/inknetrmcertdldirs.sh`
		- `0 0 * * * root /opt/verb/donjon/rmserial.sh > /dev/null 2>&1`
		- `3 3 * * * root /opt/verb/donjon/inkcert-renew-allsc.sh`
	    - `2 2 * * * root /opt/verb/donjon/inkcertcble-renew-all.sh`
		- `4 4 * * * root /opt/verb/donjon/inkcertcble-renew-all.sh`

V. inklists is meant for lists and repoes
	A. It contains universal, non-verber-specific config files that get updated regularly with the updateverber serf, such as version info
	B. It may contain more files once certain apps are installed
VI. conf is for configs and assets
    A. It contains various folders that are modified by `setup` and used elsewhere to manage the server
		- Some of these match the name of serfs that utilize them (not changed by `updateverber`)
			- inkdns (where DNS Zone files originate, either as ghost-master files or records you need to manually create where your domains are parked)
			- inkcert
		- site-files (for domain hosting configs and default web folders)
			- Not changed by `updateverber`
		- inklists (version numbers, including web app install versions and download package confirmation hashes used by the `inkget` serf)
			- Some files updated with `updateverber`
		- lib (assets used by instal serfs)
			- Folder is entirely replaced with `updateverber`
		- sql (created on installation, where database configs and `mariadb` .cnf files are stored by the system)
			- Not changed by `updateverber`

VII. tools contains common files and special root serfs needed for other CLI Clients logging in to do jobs on the verber (may be phased out)

VIII. Special user services and folders
	A. VIP (tech tools)
		1. VIP users are often known as "ftpvips" created by newftpvip, sharing the srv/vip folder as "home", granting wide access to all other users' spaces
		2. VIP governs many other special users and folders for FTP, web control, directly managing files for "vipdomains" via the serf adddomainvip or adddomainfiler
		3. VIP has a direct link into an boss user's home folder, along side serfs and possibly others
		4. Note the "vip" folder is in srv/vip, with a symlink to /var/www/vip
	B. VSFTP
		1. VSFTP creates "files", "filevips", and "ftpusers". See: newftpfiler, newftpvip, and newftpuser for details
		2. A "domainfiler" is a VSFTP user with access to a hosted domain's folder
		3. The "_filecabinet" is a global folder shared by "ftpfilers", but not available to ftpusers
		4. VSFTP's main directory is srv/vip, with some subdirectories for users
	C. Fossil
		1. Fossil can create a user specific to a fossil via the serf: newfossiluser
		2. Fossil users are not a real user on the system, but uses a serf to be created.
		3. Fossil's folder is in srv/vip
	D. Bosses
		1. Bosses are sudoers, but also have special folders via the "verb/boss" box
		2. The "boss box" includes vip, tools, serfs, and Inker knights (if Inker is installed)
		3. Bosses do not have direct access to config files in their home folders
		4. The "boss box" is at local/verb/boss, but boss home folders are in home/

IX. Server names
	A. The hostname of your server will be the main TLD
		1. For a normal, stand-alone, this means it will be: ink.YOURNAME.verb.ink
		2. For secondary installs, it will be such as blue.YOURNAME.verb.blue, etc.
		3. If you change to a non-inkVerb server, it could be such as: ink.YOURDOMAIN.com
	B. Custom server v inkVerb server
		1. An inkVerb verber server (using such as YOURNAME.verb.ink for $10 a year):
			- Offers to use the inkVerb repo for file installs, saving you additional server space (can't use with custom servers)
		2. A custom server (changes all verb.ink, verb.blue, etc to ink.YOURDOMAIN.com, blue.YOURDOMAIN.com, etc):
			- Cannot connect to the inkVerb repo, so you must follow the instructions to host your own.
			- Still uses the same file structure for inkVerb apps in the www/html directory
			- Retains nearly all other capabilities on the actual server

X. Other notes
	A. Exit codes from bash scripts
		1. Scripts are ordered to minimize damage if exited from an error. WordPress, for example, will finish the basic install requirements before attempting a plugin download.
		2. Note: All bash scropts have a `set -e` declaration, so included scripts that `exit` other than `0` will abort the entire process. Here are some codes:
		- `0` - non-fatal `exit` (often used for benign failed argument validation or harmless unmet prerequisites)
		- `1` - used by Linux
		- `2` - used by Linux
		- `3` - aborted by user at prompt (changed mind, didn't type 'yes', etc.)
		- `4` - failed attempt, such as a file not downloaded, not enough space, package not available/installed, argued file/value not listed, or login credentials rejected, thus cannot proceed
		- `5` - unmet/invalid credentials (ie arguments for a bash script are incomplete or incorrect or incompatible or inappropriate, it could cause a problem if continuing)
		- `6` - impossible error (something is wrong that shouldn't be possible, such as a script is messed up or something was changed manually-incorrectly, this error status is only for circumstances that creat a problem that didn't exist before, errors that notice a pre-existing problem should `exit 0`)
		- `7` - already done dilemma ('already installed' reports `7` only if it would cause a problem to continue, this is a mass abort `exit` status to avoid conflict. A benign 'already installed' will `exit 0`)
		- `8` - unmet dependency (the basic 'do your homework' message: something else should have been done first, but can't be complete automatically)
		- `9` - illegal/catostrophic attempt ('you are not allowed to destroy the system' or 'you are not authorized in this area' message)
	B. If statements, checks, and inclusions
		1. Scripts are organized to keep file size small and to standardize system-wide jobs, not to be fool-proof for lazy programming or new users.
		2. Many "if" checks and "usage" messages could be included in serfs, but are not because the user should more or less know what he is doing. Such errors will be in the yoeman tool for easier command line use and a GUI.
		3. The main purpose of "if" checks is for complex situations or to provide contingency alternatives for factors outside of the verber, such as failing to download a webapp for installation.
		4. Generally, failed "plugins" won't break an entire script; failing to download the core webapp will `exit 4` and the webapp won't be installed at all.
XI. Web host directory structure
	A. The /srv/www folder:
		- html: where all web folders link to and are found via apache or nginx config files
		- domains: hosted domains default web folders (keeping things simple for FTP client managent of personal projects)
		- email: roundcube & pfa apps
			- These apps are known as "Box" and "PO" at box. and po. subdomains of verb.email
		- forwards: where forwarding files go when a domain is set to forward
		- mailcatch: web folder greeting for mail subdomains (ie: mail. smtp. imap. pop.), used in SSL validation
		- one: used by verb.one subdomains, highly customizable
		- vapps: where most serfs install non-email web apps, such as Nextcloud and WordPress for specific domains
			- WordPress uses a `wp.` prefix on the name of the domain it is installed to
		- verb: where *.verb.* domain folders are hosted
	B. Hosting services (LAEMP/LAMP/LEMP)
		- The primary preferred stack is LAEMP, using an Apache-Nginx reverse proxy
			- This works very well with all the main web apps and services used on a verber
			- The LAMP or LEMP servers should only be used in special cases
			- The decision of LAEMP/LAMP/LEMP is decided by `verb/inst/make-verber-*` scripts run before `setup`
		- The actual services are:
			- `nginx` (Nginx)
			- `httpd` (Apache)
		- The web user is: `www` (not `www-data` nor `apache` etc)
		- The actual nginx & httpd .conf files are located in: verb/conf/webserver
			- These are structured as 'sites-available/nginx' etc, not `nginx/sites-available` (making CLI navigation easier)
			- These are linked to the normal locations, ie:
				- `/etc/nginx/sites-available -> /opt/verb/conf/webserver/sites-available/nginx`
				- `/etc/httpd/sites-available -> /opt/verb/conf/webserver/sites-available/httpd`
			- Properly enable sites with the `ensitenginx` and `ensiteapache` serfs, but normal links should also work
		- php.ini is at verb/conf/php.ini and linked to /etc/php/php.ini (so you don't need to hunt for it)
XII. Mounted volumes
	- Volume mounting is an option, placing man of the web hosted folders at various places on SSD and HDD mounted volumes
		- This is handled by the Rink, which creates and manages verb VPS instances in the first place. If you are managing a stand-alone verber installed manually, mounted volume systems will simply be non-existant by the system. But, don't delete any volume config files because the framework still depends on them, even if to remain at their default values.
	- Volumes actually reside in /mnt/
	- When SSD is mounted, entire web app folders are automatically installed to the SSD volume in /mnt/
	- When HDD is mounted, media and data folders (ie wp-content or nextcloud/data) are installed to the HDD volume in /mnt/
	- The serfs and verb framework is very good at automatically detecting where things go
	- Adding a volume after a web app is installed is generally no problem since the mounting scripts simply move the folders described in the section on web host directories

## Specific Script Families & `ink` tools

- The `ink` tool can be used to run many serfs from the CLI
  - This does not include all serfs, but mainly those that would be useful for routine management of the server
- Each serf has a mod option, for scripts placed in the verb/mods/ folder
  - `/opt/verb/mods/SERFNAME.replace` Replaces the script
	- `/opt/verb/mods/SERFNAME.before` Precedes the script
	- `/opt/verb/mods/SERFNAME.after` Follows the script

## inkDNS

- `inkdns*` scripts
  - These are meant to manage DNS records on a network made of:
	  1. A "Control Rink" verber with the inkVerb/rink repo installed
		  - This is the origin of new & created verbers
			- This creates ssh keys for a verber to call DNS changes on the two NS servers (below)
			  - This creates the ssh key on the verber, then installs them on the two NS servers
				  - This happens in `rink/addvps` via `rink/newverbrinkkeys`
		2. Two NS sameservers
		  - Fully automated and created by `rink/setuprinkns` on the Control Rink
	  3. As many other verbers that are created by the Control Rink
	- When the Control Rink creates new verbers through `rink/addvps`, `rink/newverbrinkkeys` will create these keys on the new verber, then list them on the two NS nameservers
	- Then, the verber will request its own changes/listings/delistings through `verb/serfs/rink*` serfs
	  - These serfs do not not actually run any command on the NS nameservers, but only leave a file for `rinkcon.loop` on the NS nameservers to find, validate, and then run
		- `rinkcon.loop` and its validation tools reside in `verb/rinkcon/`
			- On NS nameservers, `/opt/verb/rinkcon/rinkcon.loop` is initiated as the `inkdnscontrol` service by `setup`
			  - This can be checked with `systemctl status inkdnscontrol`
		  - Files other than the `log/` in this folder only exist if `make-dns` was run before running `setup`
			- This file performs validation using functions from:
			  - `verb/rinkcon/rinkcon.functions`
				- `verb/ink/ink.functions`
			- Logs are kept in `verb/rinkcon/logs`
				- `invalid` is for calls that are not valid, indicating some kind of security breach
				- `success` is for calls that were valid and run
		  - This loops through entries made in `/srv/sns/VERBNAME-TLD/calls/`
		    - These calls do not actually execute serfs, but initiate functions from `rinkcon.functions` which then execute serfs by the same names
			  - This adds security; only listed functions in `rinkcon.functions` can execute
	- Communication between all these servers use `ssh` keys and calls set up by the Control Rink
	- `inkdns*` serfs that contain `slave` in the name are meant to be run on an NS nameserver by the `rinkcon.cron` task script
	  - These rely on certain settings inside `/srv/sns/VERBUSER.TLD/` configs for their IP and other arguments to be completed
	- `inkdns*` and `rink*` serfs that contain `local` (and often `slave` also) are meant to be run manually on the server, such as for a `make-domainmod` verber, where NS records must be handled manually
	- Study `inkdnsrefreshbind` and `rinkadddomain` and `rinkkilldomain` carefully to see how they interact with each other, both on the local verber and on the NS nameservers
	  - Knowledge about these goes well beyond the capability of documentation; to sumarize would be to elaborate
	  - Essentially, these check, manage, and rebuild the entire `/var/named` directory, and other related settings, from the bottom up each time
- Parking
  - `db.*` and `nv.*` files can be placed in the `verb/conf/inkdns/parked/` directory
    - These must be properly formatted Zone and PTA (rDNS) files
	- These will be hosted by the local DNS Bind server after running `inkdnsrefreshbind`
	- These are added to NS nameservers with `rinkparkme`
	  - `rinkparkme` loops through `parked/db.*` files to list their domains on the NS nameservers
  - Other parking tools to park a domain and add entries per validated zone line may be created at a later date
    - Such tools would create individual zone file entries in a `parked/domain.tld/` folder as individual files
	  - These entries would then be sorted and formed into proper `db.*` and `nv.*` files via `inkdnsrefreshbind`
	- Another tool would allow dropping user prepared `db.*` and `nv.*` files into a `parked/domain.tld/` folder for validation

## serfs integration `ink`
IMPORTANT: As of v0.90.00, serfs are being integrated into the `ink` tool in verb/ink. This will manage the serfs by providing validation, help, and making them somewhat "mistake-proof". This is slowly rolling out to all serfs.

Scripts in verb/serfs are called "serfs". These have comment instructions and notes at the head of each script. These notes could extend past 10 and 20 lines, usually `head serfname` could give a good understanding and possible usage examples of how a serf is used.

The general serf help tool is the `info` serf, usage: `/opt/verb/serfs/info serfname`

This `info` serf displays other "meta" information available in most serfs via BASH arrays, just below the commented instructions, usually beginning wtih `usagenotes=`. These explain more details about prerequesite serfs, included serfs, other serfs that include the given serf, verb/conf/ files used, and the regEx validation checks used by `ink` for arguments.

The meta information is intended to be processed by the `serfs/info` serf, and the information will be displayed in an human readable arrangement in the terminal. This is for developers to understand serfs easily. The `vsettypes` and `vopttypes` arrays list, in respective order, the specific functions used by ink/ink.functions to validate those arguments when the serf is executed by the `ink` CLI command.

While still in early development, not all serfs have these variables and arrays, especially if they are meant to be included deep within sub scripts and not used alone. Eventually, all serfs need these blocks. The meta block (along with the three `if` statements for `.replace`, `.before` & `.after` files in verb/mods/) are mandatory for a serf to be considered fully valid. No pull requests will be approved for new serfs not containing these blocks properly arranged.

Using serfs directly is second preference to the `ink` command line tool, but may be 

Much of the information found with the `info` serf is redundant in the verb/ink/help/*.md files, which explain more how the server is affected by `ink` commands. See the section below on using `ink` as the primary command line tool.

## `verb` TLD impact
Every subdomain of each verb TLD (ie cloud.NAME.verb.blue or cloud.blue.DOMAINMOD.tld) impacts several settings and serfs

A complete list of affected files and scripts is at [dev/each-verb.md](https://github.com/inkVerb/verb/blob/main/dev/each-verb.md)

## ink CLI tool

`ink` is the CLI for a verber, handling most common commands needed to maintain a server. This section provides additional help information not included with `ink -h`...

### Dev & Debug options
These will not display in Help menues for individual actions and schema, only here in these notes!

Additional `ink` flags:

`-v` Verbose output (no log): `ink [ action ] [ schema ] [ args & -flags ] -v`
Normally, all output (STDERR & STDOUT) goes to: ink/log/outputlog
With the `-v` flag, all output (STDERR & STDOUT) will go to the terminal, rather than to ink/log/outputlog
This is for developers wanting to watch what happens on the server live
However, output goes to either ink/log/outputlog or terminal
If you want output both in the terminal and a file, use `-v | tee custom_log_file` at the end of your `ink` command for your own output file

`-c` CLI: `ink [ action ] [ schema ] [ args & -flags ] -c`
This will display only the 'serf/' script command that results from the `ink` CLI command

`-r` Richtext response: `ink [ action ] [ schema ] [ args & -flags ] -r`
Success/fail ourput will use HTML vsuccess/verror classes (success/error, respectively)

### SDK
verb supports mods!

#### The `ink` command prepares scripts based on getopts arguments
- These are sorted and validated in ink/*.ink files
  - Validation happens through functions in ink/ink.functions
- Help files are in ink/help/*.md files, output with `-h` for actions and schema
- The result in a script command at serfs/*

#### Writing your own mods
- Every serf script includes these files if they exist in verb/mods/
  - SERFNAME.replace - Replaces the entire script and finishes with `return`
  - SERFNAME.before - Runs before anything in the script starts
  - SERFNAME.after - Runs after everything in the script finishes

