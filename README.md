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

Treesitter can be manually added to path if glibc is old: https://github.com/tree-sitter/tree-sitter/releases/tag/v0.25.10

Grug-far relies on somewhat new rg.

TODO: not sure if debugging is setup correctly

TODO: automatically jump to first quickfix item (toggleable)
TODO: need to setup commands to set tab local project root dir

- would be nice to have rainbow delimiters

### Random useful commands

- `rr`-> record replay
- `ss -tlnp` -> list out all listening sockets 
- `strace ...` -> trace system calls


```
```
  Enabled Plugins: (8)
    ● ai.claudecode  claudecode.nvim
    ● coding.blink  blink.cmp  friendly-snippets  blink.compat  catppuccin
    ● coding.mini-surround  mini.surround
    ● dap.core  mason-nvim-dap.nvim  mason.nvim  nvim-dap  nvim-dap-ui  nvim-dap-virtual-text  nvim-nio
    ● editor.neo-tree  neo-tree.nvim
    ● editor.snacks_picker    nvim-lspconfig  snacks.nvim  alpha-nvim  dashboard-nvim  flash.nvim  mini.starter  todo-comments.nvim
      Fast and modern file picker
    ● util.gh  lang.git  gh.nvim  litee.nvim
    ● util.octo  lang.git  octo.nvim  snacks.nvim

  Enabled Languages: (1)
    ● lang.git  cmp-git  nvim-treesitter  nvim-cmp
```
```
