local M = {}

local dap = require("dap")

-- TODO: think long and hard about how cwd should actually be Lazyvim.root() (look at compile module)

-- ---------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "coredebug" })
end

local function ensure_binary()
  if not vim.t.DEBUG_BINARY then
    notify("No debug binary set", vim.log.levels.ERROR)
    return nil
  end
  return vim.t.DEBUG_BINARY
end

local function ensure_core_dir()
  if not vim.t.CORE_DIR then
    notify("No core directory set", vim.log.levels.ERROR)
    return nil
  end
  return vim.t.CORE_DIR
end

local function find_latest_core(dir)
  local cores = vim.fn.globpath(dir, "core*", false, true)
  if #cores == 0 then
    return nil
  end

  table.sort(cores, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  return cores[1]
end

-- ---------------------------------------------------------------------
-- Public setters (your originals, slightly tightened)
-- ---------------------------------------------------------------------

function M.set_debug_binary()
  local input = vim.fn.input("Set target binary: ", vim.t.DEBUG_BINARY or (vim.fn.getcwd() .. "/") or "", "file")
  if input ~= "" then
    vim.t.DEBUG_BINARY = vim.fn.fnamemodify(input, ":p")
    notify("Debug binary set:\n" .. vim.t.DEBUG_BINARY)
  end
end

function M.set_core_directory()
  local input = vim.fn.input("Set core directory: ", vim.t.CORE_DIR or (vim.fn.getcwd() .. "/") or "", "dir")
  if input ~= "" then
    vim.t.CORE_DIR = vim.fn.fnamemodify(input, ":p")
    notify("Core directory set:\n" .. vim.t.CORE_DIR)
  end
end

-- ---------------------------------------------------------------------
-- DAP launchers
-- ---------------------------------------------------------------------

-- NOTE: if shit breaks, then cwd is probably the culprint

-- <leader>dd
-- Normal debugging run
function M.dap_run()
  local binary = ensure_binary()
  if not binary then return end

  dap.run({
    name = "Debug binary",
    type = "cppdbg",
    request = "launch",
    program = binary,
    cwd = vim.fn.getcwd(),
    stopAtEntry = true,
    setupCommands = {
      {
        description = "Enable pretty printing",
        text = "-enable-pretty-printing",
        ignoreFailures = true,
      },
    },
  })
end

-- <leader>da
-- Debug binary with arguments
-- TODO: test this
function M.dap_run_with_args()
  local binary = ensure_binary()
  if not binary then return end

  local argstr = vim.fn.input("Args: ")
  local args = {}

  if argstr ~= "" then
    -- simple shell-like splitting
    args = vim.fn.split(argstr, " ")
  end

  dap.run({
    name = "Debug binary (args)",
    type = "cppdbg",
    request = "launch",

    program = binary,
    args = args,
    cwd = vim.fn.getcwd(),

    stopAtEntry = true,

    MIMode = "gdb",
    miDebuggerPath = "gdb",

    setupCommands = {
      {
        description = "Enable pretty printing",
        text = "-enable-pretty-printing",
        ignoreFailures = true,
      },
    },
  })
end

-- <leader>dD
-- Debug latest core using gdb vertical split
function M.dap_run_latest_core()
  local binary = ensure_binary()
  local core_dir = ensure_core_dir()
  if not binary or not core_dir then return end

  local core = find_latest_core(core_dir)
  if not core then
    notify("No core files found in " .. core_dir, vim.log.levels.ERROR)
    return
  end

  notify("Using core:\n" .. core)

  vim.cmd("vertical terminal gdb -q " .. vim.fn.shellscape(binary) .. " " .. vim.fn.shellescape(core))
end


return M
