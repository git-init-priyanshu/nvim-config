local M = {}

local clamp = function(value)
  return math.min(255, math.max(0, math.floor(value + 0.5)))
end

local normalize_hex = function(hex)
  if type(hex) ~= "string" then
    return nil
  end
  local sanitized = hex:gsub("^#", "")
  if not sanitized:match "^%x%x%x%x%x%x$" then
    return nil
  end
  return sanitized
end

local to_rgb = function(hex)
  local normalized = normalize_hex(hex)
  if not normalized then
    return nil
  end
  return {
    tonumber(normalized:sub(1, 2), 16),
    tonumber(normalized:sub(3, 4), 16),
    tonumber(normalized:sub(5, 6), 16),
  }
end

local to_hex = function(rgb)
  return string.format("#%02X%02X%02X", clamp(rgb[1]), clamp(rgb[2]), clamp(rgb[3]))
end

local blend = function(foreground, alpha, background)
  local fg = to_rgb(foreground)
  local bg = to_rgb(background)
  if not fg or not bg then
    return foreground
  end

  local ratio = math.min(1, math.max(0, alpha))
  return to_hex {
    ratio * fg[1] + (1 - ratio) * bg[1],
    ratio * fg[2] + (1 - ratio) * bg[2],
    ratio * fg[3] + (1 - ratio) * bg[3],
  }
end

-- Function to convert hex color to RGB
M.hex_to_rgb = function(hex)
  -- Remove "#" if present
  hex = hex:gsub("^#", "")

  -- Check if valid hex string
  if not hex:match "^%x%x%x%x%x%x$" then
    return nil
  end

  -- Convert hex to RGB values
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)

  -- Return RGB string
  return string.format("rgb(%d, %d, %d)", r, g, b)
end

-- Function to convert RGB color to hex
M.rgb_to_hex = function(rgb)
  -- Extract RGB values using pattern matching
  local r, g, b = rgb:match "rgb%((%d+),%s*(%d+),%s*(%d+)%)"

  -- Check if valid RGB string
  if not (r and g and b) then
    return nil
  end

  -- Convert to numbers
  r, g, b = tonumber(r), tonumber(g), tonumber(b)

  -- Validate ranges
  if r < 0 or r > 255 or g < 0 or g > 255 or b < 0 or b > 255 then
    return nil
  end

  -- Convert to hex and return
  return string.format("#%02X%02X%02X", r, g, b)
end

M.darken = function(hex, amount, background)
  local bg = background or "#000000"
  return blend(bg, amount, hex)
end

M.brighten = function(hex, amount, foreground)
  local fg = foreground or "#ffffff"
  return blend(fg, amount, hex)
end

return M
