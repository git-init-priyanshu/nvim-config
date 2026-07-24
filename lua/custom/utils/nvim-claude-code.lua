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

-- Send the file path to Claude Code in a vertical tmux pane ( right ).
-- Reuses an existing marked pane; otherwise splits a new one.
---@param with_range boolean
function M.send_to_claude(with_range)
  local result = M.get(with_range)
  if not result then
    return
  end

  if vim.env.TMUX == nil then
    vim.notify("Not inside a tmux session", vim.log.levels.WARN)
    return
  end

  local esc_cwd = vim.fn.shellescape(vim.fn.getcwd())
  local esc_txt = vim.fn.shellescape(result)
  local cmd = table.concat({
    [[existing=$(tmux list-panes -F '#{pane_id} #{@claude_pane}' | awk '$2=="1"{print $1; exit}')]],
    'if [ -n "$existing" ]; then',
    '  tmux select-pane -t "$existing"',
    "  tmux send-keys -t \"$existing\" -l " .. esc_txt,
    "else",
    "  id=$(tmux split-window -h -l 35% -c " .. esc_cwd .. " -P -F '#{pane_id}' claude)",
    '  tmux set-option -p -t "$id" @claude_pane 1',
    "  sleep 1.5",
    "  tmux send-keys -t \"$id\" -l " .. esc_txt,
    "fi",
  }, "\n")
  vim.fn.jobstart({ "sh", "-c", cmd }, { detach = true })
end

return M
