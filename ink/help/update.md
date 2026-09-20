# update

## This runs Verber and other updaters
- `ink update verber` downloads the latest verb repo and copies ink, serfs, donjon, and `conf/lib` (same as `./updateverber`)
- Other updaters belong under this action as new schemas, not new actions
  - Add `ink/felt/updateSCHEMA.ink` and `ink/help/updateSCHEMA.md`
  - `ink update -s` lists them
- Serfs that can become schemas later (run the serf until they have a felt): `updateverberlegacy`, `updaterc`, `updatepfa`, `updatehtmlverbs`
- This does **not** replace `pacman -Syu`. Package updates stay native Arch.

## Schemas
Find available schemas with:
- `ink update -s` or
- `ink update --schemas`
