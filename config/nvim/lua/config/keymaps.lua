-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- For C++
vim.keymap.set("n","<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>",{ desc = "Switch Source/Header (C/C++)" })

-- No highlight
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "No highlight"})

-- Note to self:
-- I need to understand how root vs cwd works
-- I think they're both arbitrary? with root being set by things like nvim-tree and cwd being set by us

-- Swap cwd and root commands, since cwd should be the common case
-- TODO: replace this clusterfuck with:
-- default easy file finding/grepping from root -> (space space, space /)
-- uncommon special directory selected by nvim-tree -> (space ff, space sg)
-- extra uncommon cwd -> (space fF, space sG)

vim.keymap.del("n", "<leader><space>")
vim.keymap.del("n", "<leader>ff")
vim.keymap.del("n", "<leader>fF")
vim.keymap.del("n", "<leader>/")
vim.keymap.del("n", "<leader>sg")
vim.keymap.del("n", "<leader>sG")

map("n", "<leader><space>", function()
  require("lazyvim.util").pick("files", { cwd = vim.api.nvim_exec2("pwd", { output = true }).output})()
end, { desc = "Find files (cwd)" })

map("n", "<leader>ff", function()
  require("lazyvim.util").pick("files")()
end, { desc = "Find files (root dir)" })


map("n", "<leader>/", function()
  require("lazyvim.util").pick("grep", { cwd = vim.api.nvim_exec2("pwd", { output = true }).output })()
end, { desc = "Grep (cwd)" })

map("n", "<leader>sg", function()
  require("lazyvim.util").pick("grep")()
end, { desc = "Grep (root dir)" })

-- Set a new config path
vim.keymap.del("n", "<leader>fc")
map("n", "<leader>fc", function()
  require("lazyvim.util").pick("files", {
    cwd = vim.fn.expand("~/dotfiles"),
  })()
end, { desc = "Find Files (my config)" })

-- Disable macros completely
vim.keymap.set("n", "q", "<nop>")
vim.keymap.set("n", "@", "<nop>")

-- Swap step over / step out for DAP
local dap = require("dap")
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", dap.step_out,  { desc = "Step Out" })

-- Poor man's M-x compile
vim.keymap.set("n", "<leader>oo", function() require("util.compile").run() end, { desc = "Compile: ./compile.sh" })
vim.keymap.set("n", "<leader>op", function() require("util.compile").set_project_root() end, { desc = "Set project root if LazyVim.root() is incorrect" })
vim.keymap.set("n", "<leader>ot", function() require("util.compile").toggle() end, { desc = "Toggle compile window" })
vim.keymap.set("n", "<leader>oq", function() require("util.compile").stop() end, { desc = "Kill current job" })

-- Debugging
local debugging = require("util.debugging")

vim.keymap.set("n", "<leader>dn", debugging.set_debug_binary, { desc = "Set debug binary" })
vim.keymap.set("n", "<leader>dm", debugging.set_core_directory, { desc = "Set core directory" })
vim.keymap.set("n", "<leader>dd", debugging.dap_run, { desc = "DAP: Debug binary" })
vim.keymap.set("n", "<leader>dD", debugging.dap_run_latest_core, { desc = "DAP: Debug latest core" })
vim.keymap.set("n", "<leader>da", debugging.dap_run_with_args, { desc = "DAP: Debug binary with args" })

-- Directional escape from terminal mode
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])
