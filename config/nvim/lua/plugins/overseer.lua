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
    { "<leader>oc", "<cmd>OverseerRun<cr>",    desc = "Overseer: Compile" },
    { "<leader>or", "<cmd>OverseerRestartLast<cr>",    desc = "Overseer: Recompile" },
  },
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

    local function project_root()
      return vim.fn.getcwd()
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
