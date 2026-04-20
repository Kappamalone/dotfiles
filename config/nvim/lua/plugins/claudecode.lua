return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        split_width_percentage = 0.45,
      },
      diff_opts = {
        open_in_new_tab = true,
        hide_terminal_in_new_tab = true,
      }
    },
  },
}

-- local toggle_key = "<C-,>"
-- return {
--   {
--     "coder/claudecode.nvim",
--     dependencies = { "folke/snacks.nvim" },
--     keys = {
--       { toggle_key, "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code", mode = { "n", "x" } },
--     },
--     opts = {
--       terminal = {
--         ---@module "snacks"
--         ---@type snacks.win.Config|{}
--         snacks_win_opts = {
--           position = "float",
--           width = 0.9,
--           height = 0.9,
--           keys = {
--             claude_hide = {
--               toggle_key,
--               function(self)
--                 self:hide()
--               end,
--               mode = "t",
--               desc = "Hide",
--             },
--           },
--         },
--       },
--
--       diff_opts = {
--         open_in_new_tab = true,
--         hide_terminal_in_new_tab = true,
--         auto_close = true,
--       }
--     },
--   },
-- }
