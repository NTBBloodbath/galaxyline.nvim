local colors = {}

colors.default = {
  bg = "#202328",
  fg = "#bbc2cf",
  yellow = "#ECBE7B",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  blue = "#51afef",
  red = "#ec5f67",
}

colors["doom-one"] = {
  bg = "#23272e",
  fg = "#bbc2cf",
  fg_alt = "#5B6268",
  yellow = "#ECBE7B",
  cyan = "#46D9FF",
  green = "#98be65",
  orange = "#da8548",
  magenta = "#c678dd",
  blue = "#51afef",
  red = "#ff6c6b",
  violet = "#a9a1e1",
}

colors.gruvbox = {
  bg = "#32302f",
  fg = "#d4be98",
  fg_alt = "#ddc7a1",
  yellow = "#d8a657",
  cyan = "#89b482",
  green = "#a9b665",
  orange = "#e78a4e",
  magenta = "#d3869b",
  blue = "#7daea3",
  red = "#ea6962",
  violet = "#a9a1e1",
}

colors.nord = {
  bg = "#3B4252",
  fg = "#ECEFF4",
  fg_alt = "#D8DEE9",
  yellow = "#EBCB8B",
  cyan = "#88C0D0",
  green = "#A3BE8C",
  orange = "#D08770",
  magenta = "#B48EAD",
  blue = "#5E81AC",
  red = "#BF616A",
  violet = "#a9a1e1",
}

colors.dracula = {
  bg = "#21222C",
  fg = "#F8F8F2",
  fg_alt = "#ABB2BF",
  yellow = "#F1FA8C",
  cyan = "#8BE9FD",
  green = "#50FA7B",
  orange = "#FFB86C",
  magenta = "#BD93F9",
  blue = "#A4FFFF",
  red = "#FF5555",
  violet = "#a9a1e1",
}

colors.get_color = function(color)
  return function()
    for theme_name, _ in pairs(colors) do
      if vim.g.colors_name and vim.g.colors_name:find(theme_name, 1, true) then
        return colors[theme_name][color]
      end
    end

    return colors.default[color]
  end
end

return colors
