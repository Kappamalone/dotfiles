-- ~/.config/nvim/lua/plugins/nvim-tree.lua
return {
  -- 1) Turn off Neo-tree (LazyVim’s default explorer)
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- 2) Use nvim-tree instead
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
      -- Keep <leader>e / <leader>E aliases (like LazyVim’s defaults)
      { "<leader>e", "<leader>fe", desc = "Explorer NvimTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NvimTree (cwd)",     remap = true },

      -- Quality-of-life: common nvim-tree keys you likely used in LunarVim
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
      { "<leader>fq", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file in tree" },
    },
    opts = {
      -- Mirrors the typical LunarVim feel while staying close to nvim-tree defaults
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = true },
      view = { width = 30, side = "left" },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = { show = { git = true } },
      },
      filters = { dotfiles = false, git_ignored = false },
      git = { enable = true, ignore = false, timeout = 400 },
      actions = { open_file = { quit_on_open = false, resize_window = true } },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end,
  },

  -- 3) Make Bufferline account for the NvimTree sidebar (optional but nice)
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.options = opts.options or {}
      opts.options.offsets = opts.options.offsets or {}

      -- Replace any Neo-tree offset with NvimTree & add one if missing
      local has = false
      for _, o in ipairs(opts.options.offsets) do
        if o.filetype == "NvimTree" then has = true end
        if o.filetype == "neo-tree" then
          o.filetype = "NvimTree"
          o.text = o.text or "File Explorer"
          o.highlight = o.highlight or "Directory"
          o.text_align = o.text_align or "left"
          has = true
        end
      end
      if not has then
        table.insert(opts.options.offsets, {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        })
      end
      return opts
    end,
  },
}
