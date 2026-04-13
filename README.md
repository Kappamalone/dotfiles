# Notes

## LazyVim

LazyExtras that I use:
- coding.blink
- editor.neo-tree
- editor.snacks_picker
- dap.core + Mason to install cpp-tools
  - make sure to run `ulimit -c unlimited` to obtain core dumps
  - find where cores are located: `cat /proc/sys/kernel/core_pattern`
  - compile executable with `-g` to get debug symbols

Treesitter disabled. Grug-far relies on somewhat new rg.

TODO: automatically jump to first quickfix item

TODO: make debugging executable and most recent core ergonomic
