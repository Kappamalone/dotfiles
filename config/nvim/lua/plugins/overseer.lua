-- lua/plugins/overseer.lua
return {
  "stevearc/overseer.nvim",
  event = "VeryLazy",
  opts = {
    -- UI feel; tweak to taste
    task_list = {
      direction = "bottom",
      min_height = 25,
      max_height = 25,
    },
    -- load builtin templates (make, npm, cargo, VS Code tasks) in case your repo has them
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

    -------------------------------------------------------------------------
    -- 1) Emacs-like: run your compile.sh, parse errors -> quickfix
    -------------------------------------------------------------------------
    -- Uses Neovim-style errorformat parsing path (simple) AND shows how to switch
    -- to JSON diagnostics if you want bulletproof parsing (see commented alt below).
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
      -- If quickfix doesn't populate with your script, try the JSON approach:
      -- components = {
      --   "default",
      --   { "on_output_parse", parser = "extract_json" },   -- JSON parser
      --   "on_result_diagnostics_quickfix",                 -- put diagnostics into quickfix
      --   "on_complete_notify",
      -- }
      -- (The JSON route pairs well with compilers that can emit JSON diagnostics.) [5](https://blog.csdn.net/gitblog_00852/article/details/148989669)[6](https://www.reddit.com/r/neovim/comments/w8n831/use_overseernvim_to_run_commands_on_save/)
    })

    -------------------------------------------------------------------------
    -- 2) C++: build & run with JSON diagnostics (very reliable quickfix)
    -------------------------------------------------------------------------
    overseer.register_template({
      name = "C++ (JSON diagnostics) build & run",
      desc = "g++ -std=c++2a with -fdiagnostics-format=json, then run ./build/main",
      condition = {
        callback = function()
          return vim.fn.filereadable("main.cpp") == 1
        end,
      },
      builder = function()
        local cmd = table.concat({
          "mkdir -p build",
          -- You can swap g++ for clang++; the JSON diagnostics idea is the same.
          "g++ -std=c++2a -Wall -Wextra -fdiagnostics-format=json main.cpp -o build/main",
          "./build/main",
        }, " && ")
        return {
          cmd = { "bash", "-lc", cmd },
          cwd = project_root(),
          components = {
            "default",
            { "on_output_parse", parser = "extract_json" }, -- parse compiler JSON  [5](https://blog.csdn.net/gitblog_00852/article/details/148989669)
            "on_result_diagnostics_quickfix",               -- populate quickfix    [6](https://www.reddit.com/r/neovim/comments/w8n831/use_overseernvim_to_run_commands_on_save/)
            "on_complete_notify",
          },
        }
      end,
    })

    -------------------------------------------------------------------------
    -- 3) Remote flow: build locally -> scp binary -> run on remote over SSH
    -------------------------------------------------------------------------
    -- This uses Overseer's parameter form so you can enter host/paths the first time
    -- and then just re-run the same task from history (or restart). [2](https://deepwiki.com/stevearc/overseer.nvim/4-user-interface)
    overseer.register_template({
      name = "Remote build → SCP → remote run",
      desc = "Build locally, scp to remote, then run on the remote host",
      params = {
        host       = { desc = "user@host",           default = "user@server" },
        remote_bin = { desc = "Remote path to bin",  default = "~/bin/main" },
        run_cmd    = { desc = "Remote run command",  default = "~/bin/main" },
        build_cmd  = {
          desc = "Local build command",
          default = "mkdir -p build && g++ -std=c++2a -O2 -fdiagnostics-format=json main.cpp -o build/main",
        },
        local_bin  = { desc = "Local binary path",   default = "build/main" },
        scp_opts   = { desc = "scp options",         default = "-q" },
        ssh_opts   = { desc = "ssh options",         default = "-o BatchMode=yes" },
      },
      builder = function(p)
        local pipeline = table.concat({
          p.build_cmd,
          string.format("scp %s %q %s:%q", p.scp_opts, p.local_bin, p.host, p.remote_bin),
          string.format("ssh %s %s %q", p.ssh_opts, p.host, p.run_cmd),
        }, " && ")
        return {
          cmd = { "bash", "-lc", pipeline },
          cwd = project_root(),
          components = {
            "default",
            -- If your build_cmd emits JSON diagnostics, keep JSON parsing:
            { "on_output_parse", parser = "extract_json" }, -- or switch to "errorformat"
            "on_result_diagnostics_quickfix",
            "on_complete_notify",
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
