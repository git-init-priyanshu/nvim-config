--- Custom claudecode.nvim terminal provider that runs Claude in a tmux pane.
---
--- claudecode.nvim keeps the MCP WebSocket server and lockfile inside Neovim,
--- decoupled from wherever the `claude` binary runs. This provider launches
--- `claude` in a right-side tmux pane while inlining the integration env vars
--- (which a jobstart env table would NOT deliver to the pane) so it connects
--- back to the in-editor server and gets full context: selection, at-mentions,
--- diagnostics, diffs.
---@type ClaudeCodeTerminalProvider
local M = {}

local PANE_MARKER = "@claude_pane"

local config = {
  split_width_percentage = 0.35,
}

---@param args string[]
---@return string
local function tmux(args)
  local cmd = { "tmux" }
  vim.list_extend(cmd, args)
  return vim.fn.system(cmd)
end

---Find the tmux pane previously marked as the Claude pane, if it still lives.
---@return string|nil pane_id
local function find_pane()
  local out = tmux { "list-panes", "-a", "-F", "#{pane_id} #{" .. PANE_MARKER .. "}" }
  for line in out:gmatch "[^\n]+" do
    local pane_id, marker = line:match "^(%%%S+)%s+(%S+)$"
    if pane_id and marker == "1" then
      return pane_id
    end
  end
  return nil
end

---Build the shell command run inside the pane, inlining the integration env
---vars so the pane inherits them regardless of the tmux server environment.
---@param cmd_string string
---@param env_table table<string, string>
---@return string
local function build_pane_command(cmd_string, env_table)
  local parts = { "env" }
  for key, value in pairs(env_table or {}) do
    table.insert(parts, string.format("%s=%s", key, vim.fn.shellescape(tostring(value))))
  end
  table.insert(parts, cmd_string)
  return table.concat(parts, " ")
end

---@param term_config ClaudeCodeTerminalConfig
function M.setup(term_config)
  config = vim.tbl_deep_extend("force", config, term_config or {})
end

---@param cmd_string string
---@param env_table table
---@param _effective_config ClaudeCodeTerminalConfig
---@param focus boolean|nil
function M.open(cmd_string, env_table, _effective_config, focus)
  local existing = find_pane()
  if existing then
    if focus then
      tmux { "select-pane", "-t", existing }
    end
    return
  end

  local width = math.floor((config.split_width_percentage or 0.35) * 100)
  local pane_command = build_pane_command(cmd_string, env_table)

  local out = tmux {
    "split-window",
    "-h",
    "-l",
    width .. "%",
    "-c",
    vim.fn.getcwd(),
    "-P",
    "-F",
    "#{pane_id}",
    pane_command,
  }
  local pane_id = out:gsub("%s+$", "")
  if pane_id == "" then
    vim.notify("Failed to open Claude tmux pane", vim.log.levels.ERROR)
    return
  end

  tmux { "set-option", "-p", "-t", pane_id, PANE_MARKER, "1" }
  if focus == false then
    -- keep focus in Neovim; split-window moves focus to the new pane by default
    tmux { "last-pane" }
  end
end

function M.close()
  local pane_id = find_pane()
  if pane_id then
    tmux { "kill-pane", "-t", pane_id }
  end
end

---@param cmd_string string
---@param env_table table
---@param effective_config ClaudeCodeTerminalConfig
function M.simple_toggle(cmd_string, env_table, effective_config)
  if find_pane() then
    M.close()
  else
    M.open(cmd_string, env_table, effective_config, true)
  end
end

---@param cmd_string string
---@param env_table table
---@param effective_config ClaudeCodeTerminalConfig
function M.focus_toggle(cmd_string, env_table, effective_config)
  local pane_id = find_pane()
  if pane_id then
    tmux { "select-pane", "-t", pane_id }
  else
    M.open(cmd_string, env_table, effective_config, true)
  end
end

---@param cmd_string string
---@param env_table table
---@param effective_config ClaudeCodeTerminalConfig
function M.toggle(cmd_string, env_table, effective_config)
  M.simple_toggle(cmd_string, env_table, effective_config)
end

---Custom provider owns no Neovim buffer.
---@return number|nil
function M.get_active_bufnr()
  return nil
end

---@return boolean
function M.is_available()
  return vim.env.TMUX ~= nil
end

function M.ensure_visible() end

---@return table|nil
function M._get_terminal_for_test()
  return nil
end

return M
