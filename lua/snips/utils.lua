local M = {}

---@param msg string
---@return nil
function M.log_error(msg)
  vim.notify("[custom-snips] " .. msg, vim.log.levels.WARN)
end

---@param str string
---@return boolean
function M.is_empty(str)
  return str == nil or str == ""
end

---@param path string
---@return string
function M.read_file(path)
  local uv = vim.loop
  local fd = assert(uv.fs_open(path, "r", 438))
  local stat = assert(uv.fs_fstat(fd))
  local data = assert(uv.fs_read(fd, stat.size, 0))
  assert(uv.fs_close(fd))
  return data
end

---@param str string
---@return string[]
function M.split_lines(str)
  local lines = {}
  for line in str:gmatch("([^\n]*)\n?") do
    table.insert(lines, line)
  end
  return lines
end

---@param path string
---@return string[]
function M.read_file_lines(path)
  return M.split_lines(M.read_file(path))
end

---@param dir string
function M.path_join(dir, entry)
  if string.match(dir, "/$") == nil then
    dir = dir .. "/"
  end
  return dir .. entry
end

return M
