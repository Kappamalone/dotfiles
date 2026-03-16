-- lua/plugins/overseer.lua
return {
  "stevearc/overseer.nvim",
  event = "VeryLazy",
  opts = {
    use_terminal = false,
    task_list = {
      direction = "bottom",
      min_height = 25,
      max_height = 25,
    },
    templates = { "builtin" },
  },
  keys = {
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer: Task list" },
    { "<leader>oo", "<cmd>OverseerRun<cr>",    desc = "Overseer: Compile" }, -- TODO: bind this directly to ./compile.sh
    { "<leader>or", "<cmd>OverseerRestartLast<cr>",    desc = "Overseer: Recompile" },
    { "<leader>op", function()
        local input = vim.fn.input("Set project root path: ", vim.g.MANUAL_PROJECT_ROOT or vim.loop.cwd() or "", "dir")
        if input ~= nil and input ~= "" then
          vim.g.MANUAL_PROJECT_ROOT = vim.fn.fnamemodify(input, ":p")
          vim.notify("Project root set to: " .. vim.g.MANUAL_PROJECT_ROOT, vim.log.levels.INFO)
        end
      end,
      desc = "Overseer: Prompt & set project root"
    },

  },
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

    
    vim.g.MANUAL_PROJECT_ROOT = vim.g.MANUAL_PROJECT_ROOT or nil

    local function project_root()
      -- Prefer manual root if set; fall back to LazyVim root
      if vim.g.MANUAL_PROJECT_ROOT and vim.g.MANUAL_PROJECT_ROOT ~= "" then
        return vim.g.MANUAL_PROJECT_ROOT
      end
      return LazyVim.root()
    end

    overseer.register_template({
      name = "Compile.sh (local)",
      desc = "Run ./compile.sh (chmod +x if needed), populate quickfix, show output",
      condition = {
        callback = function()
          return vim.fn.filereadable("compile.sh") == 1
        end,
      },
      builder = function()
        return {
          cmd = { "bash", "-lc", "chmod +x ./compile.sh && ./compile.sh" },
          cwd = project_root(),
          components = {
            "default",                     -- basic terminal, status, etc.  [1](https://github.com/stevearc/overseer.nvim/blob/master/doc/explanation.md)
            { "on_output_parse", parser = "errorformat" }, -- parse using &errorformat
            "on_output_quickfix",         -- push parsed results to quickfix  [1](https://github.com/stevearc/overseer.nvim/blob/master/doc/explanation.md)
            "on_complete_notify",         -- desktop notif on finish           [1](https://github.com/stevearc/overseer.nvim/blob/master/doc/explanation.md)
          },
        }
      end,
    })

    -------------------------------------------------------------------------
    -- Convenience: "Restart last task" like a one-key recompile
    -------------------------------------------------------------------------
    vim.api.nvim_create_user_command("OverseerRestartLast", function()
      local tasks = overseer.list_tasks({ recent_first = true })
      if tasks[1] then
        tasks[1]:restart()
      else
        vim.notify("No recent task", vim.log.levels.WARN)
      end
    end, {})
  end,
}
