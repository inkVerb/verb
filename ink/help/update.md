# update

## This runs Verber and other updaters
- `ink update verber` clones `verb-update` and runs `verb-update/update` (copies ink, serfs, donjon, `conf/lib`, then version patches). Same as `./updateverber`
- The Verno / changelog dump from `verb-update/update` is shown in the terminal
- Node/PHP LTS is **not** an every-update hook. It is version-gated in `verb-update` and `ink set serverlts`
- Other updaters belong under this action as new schemas, not new actions
  - Add `ink/felt/updateSCHEMA.ink` and `ink/help/updateSCHEMA.md`
  - `ink update -s` lists them
- Serfs that can become schemas later (run the serf until they have a felt): `updateverberlegacy`, `updaterc`, `updatepfa`, `updatehtmlverbs`
- This does **not** replace `pacman -Syu`. Package updates stay native Arch.

## Schemas
Find available schemas with:
- `ink update -s` or
- `ink update --schemas`
