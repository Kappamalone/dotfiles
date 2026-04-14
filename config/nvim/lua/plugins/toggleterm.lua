return {
  {
    "akinsho/toggleterm.nvim",
    opts = {
      -- This binds ToggleTerm to Ctrl + \
      -- Note the double brackets to avoid escaping issues.
      open_mapping = [[<c-\>]],
      -- Optional: choose how it opens (float, tab, horizontal, vertical)
      direction = "float",
      -- Optional: keep terminal size and buffers consistent across toggles
      persist_size = true,
      persist_mode = true,
      shade_terminals = true,
    },
  },
}
