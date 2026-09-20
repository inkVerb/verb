# update verber

## This downloads and updates the Verber core files
- Same as `./updateverber`
- Clones `inkVerb/verb-update`, runs `verb-update/update`, which clones `inkVerb/verb` (this verber's `Vbranch`, default `main`) and copies:
  - `ink/` (actions, felt, help)
  - `serfs/`
  - `donjon/`
  - `conf/lib` (including `vapptools/`)
- Then runs **version patches** in `verb-update/update` (only if `Verno` is behind)
- Prints the patch changelog(s) and ends with `Verber at v… framework from verb-update`
- Does **not** run `setserverlts` on every update. Node LTS is a version patch (0.90.09) plus `ink set serverlts` / `ink install ghost`
- Does **not** change `verb/conf/*` server settings, and does **not** run `pacman -Syu`
- First time on a verber that does not yet have this felt: `/opt/verb/serfs/updateverber`, then `ink update verber` after that

## Usage
- `ink update verber`
  - Same as `./updateverber`
  - Full dump of `verb-update/update` (including the Verno line) goes to the terminal
