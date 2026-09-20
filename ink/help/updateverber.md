# update verber

## This downloads and updates the Verber core files
- Same as `./updateverber`
- Clones `inkVerb/verb` (this verber's `Vbranch`, default `main`) via `verb-update` and copies:
  - `ink/` (actions, felt, help)
  - `serfs/`
  - `donjon/`
  - `conf/lib` (including `vapptools/`)
- Then runs `ink set serverlts` so Ghost stays on Node 22 LTS isolated from pacman
- Does **not** change `verb/conf/*` server settings, and does **not** run `pacman -Syu`
- First time on a verber that does not yet have this felt: `/opt/verb/serfs/updateverber`, then `ink update verber` after that

## Usage
- `ink update verber`
  - Same as `./updateverber`
  - Pulls latest ink, serfs, and lib from the verb repo
  - Syncs Node LTS for any Ghost sites
