-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- For C++
vim.keymap.set("n","<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>",{ desc = "Switch Source/Header (C/C++)" })

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
