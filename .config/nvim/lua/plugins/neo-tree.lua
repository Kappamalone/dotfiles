return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = false,
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,      -- Show all items, even previously filtered ones
        hide_dotfiles = false,
        hide_hidden = false, -- For Windows-style hidden files (if relevant)
        hide_gitignored = false,
      },
    },
  },
}
