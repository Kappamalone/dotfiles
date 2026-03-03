-- this is me just trying to emulate the git functionality from lunarvim as best as possible
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local del = function(mode, lhs)
          pcall(vim.keymap.del, mode, lhs, { buffer = bufnr })
        end

        local gh = {
          "<leader>ghs", "<leader>ghr", "<leader>ghS", "<leader>ghu",
          "<leader>ghR", "<leader>ghp", "<leader>ghb", "<leader>ghB",
          "<leader>ghd", "<leader>ghD",
        }
        for _, lhs in ipairs(gh) do
          del("n", lhs)
          del("v", lhs)
        end
      end,
    },

    keys = {
      -- navigation
      { "<leader>gj", function() require("gitsigns").nav_hunk("next", { navigation_message = false }) end, desc = "Next Hunk" },
      { "<leader>gk", function() require("gitsigns").nav_hunk("prev", { navigation_message = false }) end, desc = "Prev Hunk" },

      -- blame / preview
      { "<leader>gl", function() require("gitsigns").blame_line() end, desc = "Blame Line" },
      { "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line (full)" },
      { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },

      -- stage / reset
      { "<leader>gs", function() require("gitsigns").stage_hunk() end,  mode = { "n", "v" }, desc = "Stage Hunk" },
      { "<leader>gr", function() require("gitsigns").reset_hunk() end,  mode = { "n", "v" }, desc = "Reset Hunk" },
      { "<leader>gR", function() require("gitsigns").reset_buffer() end,                    desc = "Reset Buffer" },
      { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end,                desc = "Undo Stage Hunk" },

      -- diff
      { "<leader>gd", function() require("gitsigns").diffthis("HEAD") end, desc = "Git Diff (HEAD)" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",                       -- ensures :Telescope is a lazy-load trigger

    opts = {
      defaults = {
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
          },
        },
      },
    },

    keys = {
      -- use Lua API; Lazy.nvim will auto-load telescope on keypress
      { "<leader>go", function() require("telescope.builtin").git_status()    end, desc = "Open changed file" },
      { "<leader>gb", function() require("telescope.builtin").git_branches()  end, desc = "Checkout branch" },
      { "<leader>gc", function() require("telescope.builtin").git_commits()   end, desc = "Checkout commit" },
      { "<leader>gC", function() require("telescope.builtin").git_bcommits()  end, desc = "Checkout commit (current file)" },

      -- also expose branches under the Search menu like LunarVim
      { "<leader>sb", function() require("telescope.builtin").git_branches()  end, desc = "Checkout branch (Search menu)" },
    },
  },

}
