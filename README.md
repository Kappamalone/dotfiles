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

TODO: automatically jump to first quickfix item (toggleable)

TODO: make debugging executable and most recent core ergonomic

TODO: need to setup commands to set tab local project root dir
TODO: commands to set a tcd within nvim-tree and then corresponding grep/find file

TODO: make vim fugitive status buffer and compile buffer something you can "q" on
TODO: make vim fugitive commit drop straight into insert mode
