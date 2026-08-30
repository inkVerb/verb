# show inklog

## This pages the ink CLI raw serf output log
- `ink show inklog`
- Same keys as journalctl: space page down, b page up, q quit
- Opens at the end of the file (newest output)
- File: `ink/log/outputlog` (also `/var/log/ink/outputlog`)
- Command notices (not raw serf output) are in `inklog` in the same directory
- Normally `ink` writes serf STDOUT/STDERR only to this log; `-v` sends them to the terminal instead
