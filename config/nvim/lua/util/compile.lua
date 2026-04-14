local M = {}

-- Keep buffer handle across runs
local compile_buf = nil

local function project_root()
  if vim.t.MANUAL_PROJECT_ROOT and vim.t.MANUAL_PROJECT_ROOT ~= "" then
    return vim.t.MANUAL_PROJECT_ROOT
  end
  return LazyVim.root()
end

-- Find a window displaying the buffer (if any)
local function win_for_buf(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
end

function M.run()
  local root = project_root()
  local script = root .. "/compile.sh"

  if vim.fn.filereadable(script) ~= 1 then
    vim.notify("compile.sh not found in project root", vim.log.levels.ERROR)
    return
  end

  ---------------------------------------------------------------------------
  -- Reuse or create compile buffer + window
  ---------------------------------------------------------------------------
  if compile_buf and vim.api.nvim_buf_is_valid(compile_buf) then
    local win = win_for_buf(compile_buf)

    if win then
      vim.api.nvim_set_current_win(win)
    else
      vim.cmd("vsplit")
      vim.api.nvim_win_set_buf(0, compile_buf)
    end

    -- Clear old output
    vim.api.nvim_buf_set_lines(compile_buf, 0, -1, false, {})
  else
    vim.cmd("vert rightbelow vnew")
    local new_win = vim.api.nvim_get_current_win()
    compile_buf = vim.api.nvim_get_current_buf()

    compile_buf = vim.api.nvim_get_current_buf()

    vim.bo[compile_buf].buftype = "nofile"
    vim.bo[compile_buf].bufhidden = "hide"   -- IMPORTANT: not wipe
    vim.bo[compile_buf].buflisted = false
    vim.bo[compile_buf].swapfile = false
    vim.bo[compile_buf].filetype = "log"
    vim.api.nvim_buf_set_name(compile_buf, "[compile]")
    
    -- Window options (presentation)
    vim.wo[new_win].wrap          = true
    vim.wo[new_win].linebreak     = true
    vim.wo[new_win].breakindent   = true
    vim.wo[new_win].number        = false
    vim.wo[new_win].relativenumber= false
    vim.wo[new_win].signcolumn = "no"
    vim.wo[new_win].foldcolumn = "0"

    -- resize to 45%
    local target_width = math.floor(vim.o.columns * 0.40)
    vim.api.nvim_win_set_width(new_win, target_width)

  end

  ---------------------------------------------------------------------------
  -- Reset quickfix
  ---------------------------------------------------------------------------
  vim.fn.setqflist({}, "r")
  vim.cmd("cclose")

  ---------------------------------------------------------------------------
  -- Errorformat
  ---------------------------------------------------------------------------
  vim.opt_local.errorformat = table.concat({
    "%f:%l:%c: %trror: %m",
    "%f:%l:%c: %tarning: %m",
    "%f:%l: %trror: %m",
    "%f:%l: %tarning: %m",
  }, ",")

  ---------------------------------------------------------------------------
  -- Run compile.sh asynchronously
  ---------------------------------------------------------------------------
  vim.fn.jobstart(
    { "bash", "-lc", "chmod +x ./compile.sh && ./compile.sh" },
    {
      cwd = root,
      stdout_buffered = false,
      stderr_buffered = false,

      on_stdout = function(_, data)
        if not data then return end
        vim.api.nvim_buf_set_lines(compile_buf, -1, -1, false, data)
        vim.fn.setqflist({}, "a", { lines = data })
      end,

      on_stderr = function(_, data)
        if not data then return end
        vim.api.nvim_buf_set_lines(compile_buf, -1, -1, false, data)
        vim.fn.setqflist({}, "a", { lines = data })
      end,

      on_exit = function(_, code)
        if code ~= 0 then
          vim.notify("Compile failed", vim.log.levels.ERROR)
        else
          vim.notify("Compile succeeded", vim.log.levels.INFO)
        end
      end,
    }
  )
end

function M.set_project_root()
  local input = vim.fn.input("Set project root path: ", vim.t.MANUAL_PROJECT_ROOT or vim.loop.cwd() or "", "dir")
  if input ~= nil and input ~= "" then
    vim.t.MANUAL_PROJECT_ROOT = vim.fn.fnamemodify(input, ":p")
    vim.notify("Project root set to: " .. vim.t.MANUAL_PROJECT_ROOT, vim.log.levels.INFO)
  end
end

return M
