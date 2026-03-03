-- lua/plugins/blink-ghost-text-off.lua
return {
  {
    "saghen/blink.cmp",
    -- if you're following LazyVim's blink extra, tweak *completion* section:
    opts = {
      completion = {
        ghost_text = { enabled = false },
      },
      -- (optional) if you want to also disable ghost text in the cmdline:
      cmdline = {
        completion = {
          ghost_text = { enabled = false },
        },
      },
    },
  },
}
