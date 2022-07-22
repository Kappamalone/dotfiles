-- Based off of LunarVim/nvim-basic-ide

require "impatient"
require "user.plugins"

--- Colorscheme
vim.opt.termguicolors = true
vim.o.background = "dark"
vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_foreground = 'material'
vim.g.gruvbox_material_better_performance = 1
vim.cmd [[ colorscheme gruvbox-material ]]

-- Options
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.exrc = true
vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true

-- Keymaps
local keymap = vim.keymap.set
local opts = { silent = true }
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- LSP and Coq
-- Run :LspInstallInfo, then :LspInstall <server>
-- Run :LspInfo to check currently running lsp
require("nvim-lsp-installer").setup()
local lspconfig = require("lspconfig")
vim.g.coq_settings = {
    auto_start = 'shut-up',
    clients = {
        lsp = {
            enabled = true,
        },
        tree_sitter = {
            enabled = true,
            weight_adjust = 1.0
        },
    },
}

local coq = require("coq")
lspconfig.sumneko_lua.setup{
    coq.lsp_ensure_capabilities(),
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
}
lspconfig.clangd.setup{coq.lsp_ensure_capabilities()}
lspconfig.gopls.setup{coq.lsp_ensure_capabilities()}
lspconfig.rust_analyzer.setup{coq.lsp_ensure_capabilities()}

-- NvimTree
require("nvim-tree").setup()
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Lightspeed
require("lightspeed")

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)

-- Glow
vim.keymap.set('n', '<Leader>p', ':Glow<CR>')

-- ToggleTerm
local toggleterm = require("toggleterm")
keymap("n", "<C-s>", ":w<CR>", opts) -- TODO: can you also bind <C-Bslash> to save without overwriting toggleterm?
toggleterm.setup({
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_terminals = false,
    shading_factor = 0,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = "curved",
    },
})


-- Autopairs TODO: clean this up
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({
    map_bs = true,
    map_cr = false,
    enable_check_bracket_line = false
})

vim.g.coq_settings = { keymap = { recommended = false } }

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

-- skip it, if you use another global object
_G.MUtils= {}

MUtils.CR = function()
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
            return npairs.esc('<c-y>')
        else
            return npairs.esc('<c-e>') .. npairs.autopairs_cr()
        end
    else
        return npairs.autopairs_cr()
    end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
        return npairs.esc('<c-e>') .. npairs.autopairs_bs()
    else
        return npairs.autopairs_bs()
    end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })

-- Neoformat
vim.cmd[[
    augroup fmt
        autocmd!
        autocmd BufWritePre * undojoin | Neoformat
    augroup END
]]

-- For some reason if this is loaded before certain plugins (ToggleTerm) it breaks them?
-- Treesitter (I have no idea what  this does)
local nvim_treesitter = require("nvim-treesitter.configs")

nvim_treesitter.setup({
    ensure_installed = "all", -- one of "all" or a list of languages
    ignore_install = { "" },  -- List of parsers to ignore installing
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = { "css" }, -- list of language that will be disabled
    },
    autopairs = {
        enable = true,
    },
    indent = { enable = true, disable = { "python", "css" } },
})
