local M = {}

---@class Config
---@field base_dir string
---@field include_filetypes string[] | nil
---@field exclude_pattern string
---@field get_snip_name fun(path: string): string
local config = {
  base_dir = "",
  include_filetypes = nil,
  exclude_pattern = [[^\.\|\~$]],
  get_snip_name = function(path)
    return vim.fn.fnamemodify(path, ":t:r")
  end,
  -- TODO: add support for watching files
}

---@param opts Config | nil
function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
  config.base_dir = vim.fn.expand(config.base_dir)
end

function M.get_config()
  return config
end

return M
