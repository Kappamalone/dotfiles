-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false
vim.opt.relativenumber = false
vim.g.autoformat = false
vim.opt.clipboard = "unnamedplus"
vim.o.showtabline = 2

-- === Core-dump helpers ===
-- User-configurable globals (can also be set in project-specific files)
-- Example:
--   vim.g.core_exe = "/path/to/build/my_app"
--   vim.g.core_dir = "/var/crash"
vim.g.core_exe = vim.g.core_exe or (vim.fn.getcwd())
vim.g.core_dir = vim.g.core_dir or vim.fn.getcwd()

-- Find the newest (by mtime) file in a directory that looks like a core dump.
-- You can tweak the "looks like a core" predicate for your environment.
local function newest_core_in(dir)
  local uv = vim.uv or vim.loop

  -- Normalize dir
  dir = vim.fs.normalize(dir)

  -- A small predicate for "core-looking" filenames.
  -- Linux often: "core", "core.<pid>", "core.<exe>.<pid>"
  -- macOS can produce "core.<pid>" (if enabled), BSDs similar.
  local function is_core_name(name)
    -- Accept "core", "core.*", or "core-*" (some distros)
    return name:match("^core$") or name:match("^core[.-].+") or name:match("^core%..+")
  end

  local newest_path, newest_mtime = nil, -math.huge

  local fd = uv.fs_scandir(dir)
  if not fd then
    return nil, ("Can't scan directory: %s"):format(dir)
  end

  while true do
    local name, typ = uv.fs_scandir_next(fd)
    if not name then break end
    if typ == "file" and is_core_name(name) then
      local path = dir .. "/" .. name
      local stat = uv.fs_stat(path)
      if stat and stat.mtime and stat.mtime.sec then
        local m = stat.mtime.sec + (stat.mtime.nsec or 0) * 1e-9
        if m > newest_mtime then
          newest_mtime, newest_path = m, path
        end
      elseif stat and stat.mtime then
        -- Older libuv versions expose mtime as a number
        if stat.mtime > newest_mtime then
          newest_mtime, newest_path = stat.mtime, path
        end
      end
    end
  end

  if not newest_path then
    return nil, ("No core-like files found in %s"):format(dir)
  end
  return vim.fs.normalize(newest_path), nil
end

-- Main :Core command
vim.api.nvim_create_user_command("Core", function()
  local exe = vim.g.core_exe
  local core_dir = vim.g.core_dir

  if not exe or exe == "" then
    vim.notify("[Core] vim.g.core_exe is not set", vim.log.levels.ERROR)
    return
  end
  if not core_dir or core_dir == "" then
    vim.notify("[Core] vim.g.core_dir is not set", vim.log.levels.ERROR)
    return
  end

  -- Resolve to absolute paths (if relative)
  if not exe:match("^/") and not exe:match("^%a:[/\\]") then
    exe = vim.fs.normalize(vim.fn.getcwd() .. "/" .. exe)
  end
  if not core_dir:match("^/") and not core_dir:match("^%a:[/\\]") then
    core_dir = vim.fs.normalize(vim.fn.getcwd() .. "/" .. core_dir)
  end

  -- Verify exe exists
  if vim.uv.fs_stat(exe) == nil then
    vim.notify(("[Core] Program not found: %s"):format(exe), vim.log.levels.ERROR)
    return
  end

  local core, err = newest_core_in(core_dir)
  if not core then
    vim.notify("[Core] " .. err, vim.log.levels.WARN)
    return
  end

  -- Open gdb in a vertical split terminal
  local cmd = "vsplit | terminal gdb " .. vim.fn.shellescape(exe) .. " " .. vim.fn.shellescape(core)
  vim.cmd(cmd)
end, { desc = "Open newest core in gdb using vim.g.core_exe & vim.g.core_dir" })

-- Optional: quick interactive setter
vim.api.nvim_create_user_command("CoreConfig", function()
  local exe = vim.fn.input("Program (vim.g.core_exe): ", vim.g.core_exe or "", "file")
  if exe and #exe > 0 then vim.g.core_exe = exe end

  local dir = vim.fn.input("Core dir (vim.g.core_dir): ", vim.g.core_dir or vim.fn.getcwd(), "dir")
  if dir and #dir > 0 then vim.g.core_dir = dir end

  vim.notify(("[Core] Configured:\n  exe: %s\n  cores: %s"):format(vim.g.core_exe, vim.g.core_dir))
end, { desc = "Set vim.g.core_exe and vim.g.core_dir interactively" })
