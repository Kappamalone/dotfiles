local M = {}

-- Keep buffer handle across runs
local compile_buf = nil
-- Keep job handle across runs
local compile_job = nil

---------------------------------------------------------------------------
-- Project root handling
---------------------------------------------------------------------------
local function project_root()
  if vim.t.MANUAL_PROJECT_ROOT and vim.t.MANUAL_PROJECT_ROOT ~= "" then
    return vim.t.MANUAL_PROJECT_ROOT
  end
  return LazyVim.root()
end

---------------------------------------------------------------------------
-- Window helpers
---------------------------------------------------------------------------

-- Find a window displaying the buffer (if any)
local function win_for_buf(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
end

-- Find the rightmost window in the current tab
local function rightmost_window()
  local wins = vim.api.nvim_tabpage_list_wins(0)

  local right_win = nil
  local max_col = -1

  for _, win in ipairs(wins) do
    local pos = vim.api.nvim_win_get_position(win)
    local col = pos[2]
    if col > max_col then
      max_col = col
      right_win = win
    end
  end

  return right_win
end

-- Open a vertical split from the rightmost window
local function open_rightmost_vsplit()
  local target = rightmost_window()
  if target then
    vim.api.nvim_set_current_win(target)
  end

  vim.cmd("vsplit")
  return vim.api.nvim_get_current_win()
end

-- Enforce a fixed width on a window
local function enforce_width(win, width)
  vim.wo[win].winfixwidth = true
  vim.api.nvim_win_set_width(win, width)
end

---------------------------------------------------------------------------
-- Window styling
---------------------------------------------------------------------------

local function apply_window_style(win)
  vim.wo[win].wrap           = true
  vim.wo[win].linebreak      = true
  vim.wo[win].breakindent    = true
  vim.wo[win].number         = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn     = "no"
  vim.wo[win].foldcolumn     = "0"
  vim.wo[win].winfixwidth    = true
end

---------------------------------------------------------------------------
-- Output helpers
---------------------------------------------------------------------------

local function autoscroll_if_at_bottom_and_not_focused(buf)
  local win = win_for_buf(buf)
  if not win then return end

  if vim.api.nvim_get_current_win() ~= win then
    local total_lines = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(win, { total_lines, 0 })
  end
end

local function strip_ansi(lines)
  local clean = {}
  for _, line in ipairs(lines) do
    line = line:gsub("\27%[[%d;]*m", "")
    table.insert(clean, line)
  end
  return clean
end

---------------------------------------------------------------------------
-- Compile runner
---------------------------------------------------------------------------

function M.run()
  if compile_job then
    vim.notify("Compile already running", vim.log.levels.ERROR)
    return
  end

  local root = project_root()
  local script = root .. "/compile.sh"

  if vim.fn.filereadable(script) ~= 1 then
    vim.notify("compile.sh not found in project root", vim.log.levels.ERROR)
    return
  end

  local target_width = math.floor(vim.o.columns * 0.40)
  local cur_win = vim.api.nvim_get_current_win()

  -------------------------------------------------------------------------
  -- Create or reuse compile buffer + window
  -------------------------------------------------------------------------

  if compile_buf and vim.api.nvim_buf_is_valid(compile_buf) then
    local win = win_for_buf(compile_buf)

    if not win then
      win = open_rightmost_vsplit()
      vim.api.nvim_win_set_buf(win, compile_buf)
      apply_window_style(win)
      enforce_width(win, target_width)
    end

    -- Clear old output
    vim.api.nvim_buf_set_lines(compile_buf, 0, -1, false, {})
  else
    local win = open_rightmost_vsplit()
    compile_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, compile_buf)

    vim.bo[compile_buf].buftype   = "nofile"
    vim.bo[compile_buf].bufhidden = "hide"
    vim.bo[compile_buf].buflisted = false
    vim.bo[compile_buf].swapfile  = false
    vim.bo[compile_buf].filetype  = "log"
    vim.api.nvim_buf_set_name(compile_buf, "[compile]")

    apply_window_style(win)
    enforce_width(win, target_width)
  end

  -- Restore focus
  if vim.api.nvim_win_is_valid(cur_win) then
    vim.api.nvim_set_current_win(cur_win)
  end

  -------------------------------------------------------------------------
  -- Reset quickfix
  -------------------------------------------------------------------------

  vim.fn.setqflist({}, "r")
  vim.cmd("cclose")

  -------------------------------------------------------------------------
  -- Errorformat
  -------------------------------------------------------------------------

  vim.opt_local.errorformat = table.concat({
    "%f:%l:%c: %trror: %m",
    "%f:%l:%c: %tarning: %m",
    "%f:%l: %trror: %m",
    "%f:%l: %tarning: %m",
  }, ",")

  -------------------------------------------------------------------------
  -- Run compile.sh asynchronously
  -------------------------------------------------------------------------


  vim.api.nvim_buf_set_lines(compile_buf, -1, -1, false, {
    "==> Running compile..."
  })
  local job_id = vim.fn.jobstart(
    { "bash", "-lc", "chmod +x ./compile.sh && exec stdbuf -oL -eL ./compile.sh" },
    {
      -- pty = true,
      cwd = root,
      stdout_buffered = false,
      stderr_buffered = false,

      on_stdout = function(_, data)
        if not data then return end
        local clean = strip_ansi(data)
        vim.api.nvim_buf_set_lines(compile_buf, -1, -1, false, clean)
        vim.fn.setqflist({}, "a", { lines = clean })
        autoscroll_if_at_bottom_and_not_focused(compile_buf)
      end,

      on_stderr = function(_, data)
        if not data then return end
        local clean = strip_ansi(data)
        vim.api.nvim_buf_set_lines(compile_buf, -1, -1, false, clean)
        vim.fn.setqflist({}, "a", { lines = clean })
        autoscroll_if_at_bottom_and_not_focused(compile_buf)
      end,

      on_exit = function(_, code)
        compile_job = nil

        if code ~= 0 then
          vim.notify("Compile failed", vim.log.levels.ERROR)
        else
          vim.notify("Compile succeeded", vim.log.levels.INFO)
        end

        vim.api.nvim_buf_set_lines(compile_buf, -1, -1, false, {
          code == 0 and "==> Success" or "==> Failed"
        })
      end,
    }
  )

  if job_id <= 0 then
    compile_job = nil
    vim.notify("Failed to start compile job", vim.log.levels.ERROR)
    return
  end
  compile_job = job_id

end

---------------------------------------------------------------------------
-- Toggle compile window
---------------------------------------------------------------------------

function M.toggle()
  if not compile_buf or not vim.api.nvim_buf_is_valid(compile_buf) then
    vim.notify("No compile buffer to toggle", vim.log.levels.WARN)
    return
  end

  local win = win_for_buf(compile_buf)

  if win then
    vim.api.nvim_win_close(win, false)
    return
  end

  local cur_win = vim.api.nvim_get_current_win()
  local new_win = open_rightmost_vsplit()

  vim.api.nvim_win_set_buf(new_win, compile_buf)
  apply_window_style(new_win)
  enforce_width(new_win, math.floor(vim.o.columns * 0.40))

  if vim.api.nvim_win_is_valid(cur_win) then
    vim.api.nvim_set_current_win(cur_win)
  end
end

---------------------------------------------------------------------------
-- Manual project root override
---------------------------------------------------------------------------

function M.set_project_root()
  local input = vim.fn.input(
    "Set project root path: ",
    vim.t.MANUAL_PROJECT_ROOT or vim.loop.cwd() or "",
    "dir"
  )

  if input ~= nil and input ~= "" then
    vim.t.MANUAL_PROJECT_ROOT = vim.fn.fnamemodify(input, ":p")
    vim.notify(
      "Project root set to: " .. vim.t.MANUAL_PROJECT_ROOT,
      vim.log.levels.INFO
    )
  end
end

---------------------------------------------------------------------------
-- Stop current job
---------------------------------------------------------------------------
function M.stop()
  if not compile_job then
    vim.notify("No compile job running", vim.log.levels.WARN)
    return
  end

  vim.fn.jobstop(compile_job)
  compile_job = nil
end

return M
