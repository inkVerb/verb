# set serverlts

## This installs Node 22 LTS for Ghost, isolated from pacman, and writes `verb/conf/serverlts`
- Ghost 6 requires **Node 22 only**. Arch `extra/nodejs` is whatever is current (24+ in 2026) and will break Ghost.
- Node is the official binary under `/opt/verb/lts/node`. `pacman -Syu` cannot touch it. That is the Arch-correct pin: do not fight extra/nodejs with IgnorePkg for a version extra does not ship.
- `serverlts` is created at runtime. It is **not** in git and **not** written by `inst/setup`.
- PHP version is recorded. PHP is **not** IgnorePkg'd unless you set `PHPIgnore=true` in `serverlts` and re-run (skipping php upgrades means missing security updates; Roundcube already uses `composer --ignore-platform-reqs`).
- Default: if Node 22 is already at `/opt/verb/lts/node`, **skip** nodejs.org, the tarball, `npm rebuild`, and Ghost restarts.
- `ink update verber` does **not** call this every time. A one-shot version patch (0.90.09) runs it if Ghost sites exist. After that, use this serf or `ink install ghost`.

## Usage
- `ink set serverlts`
  - Same as `./setserverlts`
  - Creates `/opt/verb/conf/serverlts`
  - Installs Node 22 only if missing or wrong major
- `ink set serverlts -f`
  - Same as `./setserverlts refresh`
  - Hits nodejs.org and installs a newer 22.x patch if one exists
