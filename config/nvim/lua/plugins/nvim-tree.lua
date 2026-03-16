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
      sync_root_with_cwd = false,
      respect_buf_cwd = false,

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
      actions = { open_file = { quit_on_open = false, resize_window = true } },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      -- Add a tree-local mapping to set cwd to the node’s directory
      local api = require("nvim-tree.api")
      local function on_attach(bufnr)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
        end

        -- Your usual nvim-tree mappings can go here (optional)
        -- map("<CR>", api.node.open.edit, "Open")

        local function set_cwd_to_node(global)
          local node = api.tree.get_node_under_cursor()
          if not node then return end

          local path = node.absolute_path or node.link_to or node.name
          local uv = vim.uv or vim.loop
          local stat = uv.fs_stat(path)

          local dir = path
          if not (stat and stat.type == "directory") then
            dir = vim.fs.dirname(path)
          end

          local cmd = global and "cd" or "lcd" -- choose global or window-local
          vim.cmd(cmd .. " " .. vim.fn.fnameescape(dir))
          vim.notify(string.format("%s → %s", cmd, dir))
        end

        -- <leader>cd (global): set cwd to the node’s directory, WITHOUT changing tree root
        map("<leader>cd", function() set_cwd_to_node(true) end, "Set cwd to node directory (global)")
        -- Optional alternative: window-local cwd
        -- map("<leader>cD", function() set_cwd_to_node(false) end, "Set lcd to node directory (window)")
      end

      -- Attach our mappings to nvim-tree buffer(s)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NvimTree",
        callback = function(args) on_attach(args.buf) end,
      })

      -- OPTIONAL: If you also want cwd to follow opened files automatically (root stays fixed),
      -- uncomment this autocmd. Otherwise, rely only on <leader>cd inside the tree.
      -- vim.api.nvim_create_autocmd("BufEnter", {
      --   callback = function(ev)
      --     -- Skip special buffers and the tree itself
      --     if vim.bo[ev.buf].buftype ~= "" then return end
      --     if vim.bo[ev.buf].filetype == "NvimTree" then return end
      --     local file = vim.api.nvim_buf_get_name(ev.buf)
      --     if file == "" then return end
      --     local dir = vim.fs.dirname(file)
      --     vim.cmd("cd " .. vim.fn.fnameescape(dir)) -- or "lcd" for window-local
      --   end,
      -- })
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
