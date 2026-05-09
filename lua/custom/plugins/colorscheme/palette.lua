local M = {}

local palette = {
  rosewater = "#F8F8F2",
  flamingo = "#FF6188",
  pink = "#F92672",
  mauve = "#AE81FF",
  red = "#F92672",
  maroon = "#E75A7C",
  peach = "#FD971F",
  yellow = "#D6BC63",
  green = "#A6E22D",
  teal = "#66D9EF",
  sky = "#78DCE8",
  sapphire = "#4DD0E1",
  blue = "#66D9EF",
  lavender = "#AE81FF",
  text = "#FFFFFF",
  subtext1 = "#C6C6C0",
  subtext0 = "#A1A1A1",
  overlay0 = "#808080",
  surface2 = "#6B6C65",
  surface1 = "#5B5C55",
  surface0 = "#494A45",
  base = "#272822",
  mantle = "#1F201B",
  dark_purple = "#C678DD",
  sun = "#FFE9B6",
  vibrant_green = "#B6F4BE",
}

M.get_palette = function(_)
  return vim.deepcopy(palette)
end

return M
