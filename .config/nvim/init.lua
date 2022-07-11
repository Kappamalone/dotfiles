-- Based off of LunarVim/nvim-basic-ide

require "plugins"

-- Colorscheme
vim.opt.termguicolors = true
vim.o.background = "dark"
vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_foreground = 'mix'
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

-- Keymaps
local keymap = vim.keymap.set
local opts = { silent = true }
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- LSP and Coq
-- Setup language servers using nvim-lsp-installer
-- See https://github.com/williamboman/nvim-lsp-installer
-- Run :LspInstallInfo, then :LspInstall <server>
-- Run :LspInfo to check currently running lsp
require("nvim-lsp-installer").setup {}
local lspconfig = require("lspconfig")
vim.g.coq_settings = {
    auto_start = true,
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

-- NvimTree
require("nvim-tree").setup()
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)

-- Treesitter (I have no idea what  this does)
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
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
