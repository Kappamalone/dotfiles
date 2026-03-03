return {
  {
    "ojroques/nvim-osc52",
    config = function(_, opts)
      local osc52 = require("osc52")
      osc52.setup(opts)

      -- Use OSC52 as the clipboard provider
      local function copy(lines, _)
        osc52.copy(table.concat(lines, "\n"))
      end
      local function paste()
        -- Fallback to current default register content
        return { vim.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
      end

      vim.opt.clipboard = "unnamedplus"
      vim.g.clipboard = {
        name = "osc52",
        copy = { ["+"] = copy, ["*"] = copy },
        paste = { ["+"] = paste, ["*"] = paste },
      }

      -- Optional: handy keymaps
      local map = vim.keymap.set
      -- Yank current line/selection to system clipboard via OSC52
      map({ "n", "x" }, "<leader>y", function()
        -- Visual mode: copy selection; Normal: copy register '+'
        if vim.fn.mode():find("[vV\022]") then
          osc52.copy_visual()
        else
          osc52.copy_register("+")
        end
      end, { desc = "Yank to system clipboard (OSC52)" })
    end,
  },
}

