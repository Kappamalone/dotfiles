-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- I should rely on pinned buffers
vim.keymap.del("n", "<leader>bl")
vim.keymap.del("n", "<leader>br")

-- TODO: remap <leader>bo to remove all unpinned buffers so i stop screwing myself over

-- For C++
vim.keymap.set("n","<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>",{ desc = "Switch Source/Header (C/C++)" })

-- Swap cwd and root commands, since cwd should be the common case
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

