local utils = require("snips.utils")
local config = require("snips.config")

local M = {}

---@class Snip
---@field path string
---@field name string

---@alias SnipsByFt table<filetype, Snip[]>

---Gets all snippet files
---@return SnipsByFt
function M.get_snip_files()
  local opts = config.get_config()

  if utils.is_empty(opts.base_dir) then
    utils.log_error("base_dir can not be empty")
    return {}
  end

  if not vim.fn.isdirectory(opts.base_dir) then
    utils.log_error("base_dir is not a directory")
    return {}
  end

  -- by default skip hidden and backup files
  local exclude_regex = vim.regex(opts.exclude_pattern or [[^\.\|\~$]])

  local valid_filetypes = {}
  for _, x in ipairs(opts.include_filetypes or {}) do
    valid_filetypes[x] = true
  end

  local function should_include_filetype(filetype)
    return opts.include_filetypes == nil or valid_filetypes[filetype] == true
  end

  local function must_exclude_dir(dir)
    return not exclude_regex:match_str(dir)
  end

  local snips = {}
  -- TODO: return an iterator to files instead of loading everything into memory
  local function get_files_recursive(path)
    if vim.fn.isdirectory(path) == 0 then
      local filetype = vim.filetype.match({ filename = path })
      if filetype == nil then
        utils.log_error("Could not determine filetype of " .. path)
      elseif should_include_filetype(filetype) then
        snips[filetype] = snips[filetype] or {}
        table.insert(snips[filetype], {
          path = path,
          name = opts.get_snip_name(path),
        })
      end
    else
      for _, entry in pairs(vim.fn.readdir(path, must_exclude_dir)) do
        get_files_recursive(utils.path_join(path, entry))
      end
    end
  end

  get_files_recursive(vim.fn.fnamemodify(opts.base_dir, ":p"))
  return snips
end

---Add snips to luasnip
---@param snips SnipsByFt
function M.add_to_luasnip(snips)
  local ls = require("luasnip")
  for filetype, filepaths in pairs(snips) do
    local ext_snips = {}
    for _, snip in ipairs(filepaths) do
      table.insert(ext_snips, ls.snippet(snip.name, ls.text_node(utils.read_file_lines(snip.path))))
    end

    ls.add_snippets(nil, { [filetype] = ext_snips })
  end
end

function M.load_snips()
  M.add_to_luasnip(M.get_snip_files())
end

---@param opts Config | nil
function M.setup(opts)
  config.setup(opts)
  M.load_snips()
end

return M
