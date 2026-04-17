return {
  {
    "tpope/vim-fugitive",
    keys = {
      {"<leader>gg", "<cmd>Git<cr>", desc="Fugitive: git status"},
      {"<leader>gd", "<cmd>Gvdiffsplit HEAD<cr>", desc="Fugitive: diff file vs HEAD"},
      { "<leader>gl", "<cmd>GcLog -- %<cr>", desc = "Fugitive: Git log -- %" },
      { "<leader>gL", "<cmd>vertical Git log<cr>", desc = "Fugitive: Git log" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Fugitive: Git blame" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Fugitive: Git commit" },
      { "<leader>gS", "<cmd>vertical Git diff --staged<cr>", desc = "Fugitive: Git diff --staged" },
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

            -- Optional but recommended: clean lifecycle
            vim.bo[buf].bufhidden = "wipe"
          end
        end,
      })
    end
  },
}
