-- ~/.config/nvim/lua/plugins/colorscheme-everforest.lua
return {
  -- Install the theme plugin
  {
    -- "sainnhe/gruvbox-material",
    "sainnhe/everforest",
    lazy = false,          -- load at startup
    priority = 1000,       -- make sure it loads before other UI plugins
    init = function ()
      vim.g.everforest_background = "hard"
      vim.o.termguicolors = true
    end
  },

  -- Tell LazyVim your chosen colorscheme (so it doesn’t override it)
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },

  -- Lualine integration
  {
  "nvim-lualine/lualine.nvim",
    optional = true,
    opts = {
      options = {
        theme = "everforest",
      },
    },
  },

}
