-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Adding q behaviour to certain windows
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  callback = function(event)
    local buf = event.buf

    if vim.bo[buf].filetype == "fugitive" then
      vim.keymap.set("n", "q", "<cmd>close<cr>", {
        buffer = buf,
        silent = true,
      })
      vim.bo[buf].buflisted = false
      return
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "[compile]" or name:match("%[compile%]") then
      vim.keymap.set("n", "q", "<cmd>close<cr>", {
        buffer = buf,
        silent = true,
      })
      return
    end
  end,
})
