# set serverlts

## This installs Node 22 LTS for Ghost, isolated from pacman, and writes `verb/conf/serverlts`
- Ghost 6 requires **Node 22 only**. Arch `extra/nodejs` is whatever is current (24+ in 2026) and will break Ghost.
- Node is the official binary under `/opt/verb/lts/node`. `pacman -Syu` cannot touch it. That is the Arch-correct pin: do not fight extra/nodejs with IgnorePkg for a version extra does not ship.
- `serverlts` is created at runtime. It is **not** in git and **not** written by `inst/setup`.
- PHP version is recorded. PHP is **not** IgnorePkg'd unless you set `PHPIgnore=true` in `serverlts` and re-run (skipping php upgrades means missing security updates; Roundcube already uses `composer --ignore-platform-reqs`).
- Rewrites every `ghost_*.service` to `ExecStart=/opt/verb/lts/node/bin/ghost run`.
- `updateverber` runs this after serfs are copied, so existing Ghost sites are synced.

## Usage
- `ink set serverlts`
  - Same as `./setserverlts`
  - Creates `/opt/verb/conf/serverlts`
  - Installs or refreshes Node 22 LTS
  - Restarts Ghost units if any exist
