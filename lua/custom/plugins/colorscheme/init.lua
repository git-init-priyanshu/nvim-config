local lazy_utils = require "custom.utils.lazy"
local highlight_overrides = require "custom.plugins.colorscheme.hl_overrides"
local palette = require "custom.plugins.colorscheme.palette"

local normalize_hl = function(opts)
  local result = vim.deepcopy(opts)
  local style = result.style
  if type(style) == "table" then
    for _, attr in ipairs(style) do
      result[attr] = true
    end
    result.style = nil
  elseif type(style) == "string" then
    for attr in style:gmatch "%S+" do
      result[attr] = true
    end
    result.style = nil
  end
  return result
end

local apply_theme_overrides = function()
  local C = palette.get_palette()
  local highlights = highlight_overrides(C)
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, normalize_hl(opts))
  end

  vim.g.terminal_color_0 = C.surface1
  vim.g.terminal_color_1 = C.red
  vim.g.terminal_color_2 = C.green
  vim.g.terminal_color_3 = C.yellow
  vim.g.terminal_color_4 = C.blue
  vim.g.terminal_color_5 = C.pink
  vim.g.terminal_color_6 = C.teal
  vim.g.terminal_color_7 = C.subtext1
  vim.g.terminal_color_8 = C.surface2
  vim.g.terminal_color_9 = C.red
  vim.g.terminal_color_10 = C.green
  vim.g.terminal_color_11 = C.yellow
  vim.g.terminal_color_12 = C.blue
  vim.g.terminal_color_13 = C.pink
  vim.g.terminal_color_14 = C.teal
  vim.g.terminal_color_15 = C.subtext0
end

return {
  {
    "tanvirtin/monokai.nvim",
    name = "monokai",
    event = "LazyFile",
    init = function() end,
    config = function(_, opts)
      require("monokai").setup(opts)

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "monokai*",
        callback = function()
          lazy_utils.on_load("monokai", function()
            apply_theme_overrides()
          end)
        end,
      })

      if vim.g.colors_name and vim.g.colors_name:match "^monokai" then
        apply_theme_overrides()
      end
    end,
    opts = {
      italics = true,
      palette = {
        base1 = "#272822",
        base2 = "#1F201B",
        base3 = "#2E323C",
        base4 = "#333842",
        base5 = "#5B5C55",
        base6 = "#A1A1A1",
        base7 = "#FFFFFF",
        border = "#A1B5B1",
        brown = "#504945",
        white = "#FFFFFF",
        grey = "#808080",
        black = "#000000",
        pink = "#F92672",
        green = "#A6E22D",
        aqua = "#66D9EF",
        yellow = "#D6BC63",
        orange = "#FD971F",
        purple = "#AE81FF",
        red = "#F92672",
        diff_add = "#3D5213",
        diff_remove = "#4A0F23",
        diff_change = "#27406B",
        diff_text = "#23324D",
      },
      custom_hlgroups = {},
    },
  },
}
