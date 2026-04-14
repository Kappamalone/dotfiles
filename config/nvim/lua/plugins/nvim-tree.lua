-- ~/.config/nvim/lua/plugins/nvim-tree.lua
-- TODO: command to get full path from tree
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- for icons
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    init = function()
      -- nvim-tree recommends disabling netrw to avoid conflicts
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.opt.termguicolors = true
    end,
    keys = {
      -- Explorer at project root (LazyVim-style)
      {
        "<leader>fe",
        function()
          local api = require("nvim-tree.api")
          local ok, root = pcall(function() return LazyVim.root() end)
          api.tree.toggle({ path = ok and root or vim.uv.cwd(), focus = true })
        end,
        desc = "Explorer NvimTree (Root Dir)",
      },
      -- Explorer at current working directory
      {
        "<leader>fE",
        function()
          require("nvim-tree.api").tree.toggle({ path = vim.uv.cwd(), focus = true })
        end,
        desc = "Explorer NvimTree (cwd)",
      },

      { "<leader>e", "<leader>fe", desc = "Explorer NvimTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NvimTree (cwd)",     remap = true },
    },
    opts = {
      update_cwd = false,
      respect_buf_cwd = false,
      sync_root_with_cwd = false,

      -- Highlight current file in tree but DO NOT re-root the tree
      update_focused_file = {
        enable = true,
        update_root = false,
      },

      view = { width = 30, side = "left" },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = { show = { git = true } },
      },
      filters = { dotfiles = false, git_ignored = false },
      git = { enable = true, ignore = false, timeout = 400 },

      -- Usual file-open behavior
      -- actions = { open_file = { quit_on_open = false, resize_window = true } },
      actions = {
          change_dir = {
            enable = true,
            global = false, -- don't mutate global cwd
          },
        },

    },
  },
}
