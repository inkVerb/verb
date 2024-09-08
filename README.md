# Installation and information for inkVerb's "verber" web server
## verb-dev

For installation, see: [INSTALL.md](https://github.com/inkVerb/verb-dev/blob/master/INSTALL.md)

For Developer info, see: [dev/README.md](https://github.com/inkVerb/verb/blob/main/dev/README.md)

# ink
`ink` is a CLI tool to manage the "Verber" server, once installed

## Format

- `ink [ action ] [ schema ] [ flags & args ]`

Example:

- `ink add domain -d inkisaverb.com`

Help:

- ink: `ink -h`
- action: `ink add -h`
- schema: `ink add domain -h`

## Webmaster info
- `ink/actions.pb` lists actions
- `ink/help/*.md` has help files that correspond to ink/
- `ink` reads files in inks/*.ink by a conflated command
  - `ink add domain` will use serfs/adddomain.ink to validate and prepare a 'serf' script command in serfs/*
- `ink/dev/` contains some tools used for testing and authoring new .ink files
  - `ink/dev/serf-headers` explains the header meta info in serfs, retrieved by the 'info' serf
  - These can be useful in knowing the script workflow to create mods
- Logs are in the `logs/` directory
- Check system logs with:

- `journalctl -t verber.ink` - all logs
- `journalctl -t verber.ink -p err SYSLOG_FACILITY=22` - errors
- `journalctl -t verber.ink -p info SYSLOG_FACILITY=22` - standard info

# Bubblewrap workflow
- Domains can't be added until vmail is installed
  - Installinv vmail automatically obtains SSL certs for Postfixadmin & Roundcube web control panels
  - During Vmail install, no other SSL certs are set up
1. Install vmail :$ `sudo ink install vmail -r RoundcubeDir -p PostfixAdminDir -s PostfixAdminSetupPassword`
  - You can setup PostfixAdmin now or later at `your-postfix-url/setup.php`
2. Add any domains you know you will use :$ `sudo ink add domain -d inkisaverb.com`
3. Obtain the inkCert certificates per domain :$
  - `sudo ink cert -d inkisaverb.com`
  - `sudo ink cert -a`

## Postfix Workflow
Install the Postfix webmail server with this workflow:
- `ink install vmail` - default options
- `ink install vmail -r RoundcubeDir -p PostfixAdminDir -s PostfixAdminSetupPassword` - three common options
- `ink install vmail -h` - help, information, and usage

___

Licensing disclaimer: This is distributed "as is" and may install third party software. By using this, you fully accept any related licensing responsibility and/or obligation(s) that of any software and related agreements of whatever may be consequently installed.