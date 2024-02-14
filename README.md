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
- ink/actions.pb lists actions
- ink/help/*.md has help files that correspond to ink/
- `ink` reads files in inks/*.ink by a conflated command
  - `ink add domain` will use serfs/adddomain.ink to validate and prepare a 'serf' script command in serfs/*
- ink/dev/ contains some tools used for testing and authoring new .ink files
  - ink/dev/serf-headers explains the header meta info in serfs, retrieved by the 'info' serf
  - These can be useful in knowing the script workflow to create mods
- Logs are in the logs/ directory
- Check system logs with:

- `journalctl -t verber.ink` # all logs
- `journalctl -t verber.ink -p err SYSLOG_FACILITY=22` # errors
- `journalctl -t verber.ink -p info SYSLOG_FACILITY=22` # standard info
