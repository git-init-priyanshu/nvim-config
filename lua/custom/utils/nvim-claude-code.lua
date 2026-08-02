local M = {}

-- Build relative file path ( with line numbers when in visual mode )
---@param with_range boolean
---@return string|nil
function M.get(with_range)
  local path = vim.fn.expand "%:."
  if path == "" then
    vim.notify("No file path for this buffer", vim.log.levels.WARN)
    return nil
  end

  local result = path
  if with_range then
    local start_line = vim.fn.line "v"
    local end_line = vim.fn.line "."
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    if start_line == end_line then
      result = path .. "#L" .. start_line
    else
      result = path .. "#L" .. start_line .. "-" .. end_line
    end
    vim.cmd "normal! \27" -- exit visual mode
  end

  return result
end

-- Copy relative file path to clipboard
---@param with_range boolean
function M.copy(with_range)
  local result = M.get(with_range)
  if not result then
    return
  end
  vim.fn.setreg("+", result)
  vim.notify("Copied: " .. result, vim.log.levels.INFO)
end

return M
