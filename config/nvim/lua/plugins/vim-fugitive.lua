return {
  {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
      { "<leader>gg", "<cmd>vertical Git<cr>", desc="Fugitive: git status"},
      { "<leader>gd", "<cmd>Gvdiffsplit HEAD<cr>", desc="Fugitive: diff fugitive object vs HEAD"},
      { "<leader>gD", "<cmd>tab Gvdiffsplit HEAD<cr>", desc="Fugitive: diff fugitive object vs HEAD (tab)"},
      { "<leader>gl", "<cmd>vertical Git log -p %<cr>", desc = "Fugitive: Git log commits of file"},
      { "<leader>gL", "<cmd>vertical Git log<cr>", desc = "Fugitive: Git log" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Fugitive: Git blame" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Fugitive: Git commit" },
      { "<leader>gS", "<cmd>vertical Git diff --staged<cr>", desc = "Fugitive: Git diff --staged" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Fugitive: Git push (async)" },
    },
    config = function(_, opts)
      -- clangd notification spams without this
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Only applies to clangd
          if client.name ~= "clangd" then
            return
          end

          local uri = vim.uri_from_bufnr(bufnr)
          if not uri or not uri:match("^file://") then
            -- Disable capabilities that cause noise
            client.server_capabilities.documentHighlightProvider = false
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.referencesProvider = false
          end
        end,
      })

      local function smart_quit()
        -- If this is the only window, close the buffer
        if vim.fn.winnr('$') == 1 then
          vim.cmd('bd')
        else
          vim.cmd('close')
        end
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function(ev)
          local buf = ev.buf

          local name = vim.api.nvim_buf_get_name(buf)
          local bt   = vim.bo[buf].buftype
          local mod  = vim.bo[buf].modifiable
          local listed = vim.bo[buf].buflisted

          -- Detect ephemeral/fugitive-style buffers
          if bt ~= ""
            or mod == false
            or listed == false
            or name:match("^fugitive://")
          then
            vim.keymap.set(
              "n",
              "q",
              smart_quit,
              { buffer = buf, silent = true, nowait = true }
            )

            -- this fucks up toggle term and claude for some reason
            -- vim.bo[buf].bufhidden = "wipe"
          end
        end,
      })
      
      -- start us off in insertion mode when writing a git commit, unless we're rewording one (test)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gitcommit",
        callback = function()
          -- Check whether there is any non-comment content
          for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
            if not line:match("^%s*#") and not line:match("^%s*$") then
              return -- reword/amend: do NOT enter insert
            end
          end

          -- Fresh commit: enter insert mode
          vim.cmd("startinsert")
        end,
      })

    end
  },
}
