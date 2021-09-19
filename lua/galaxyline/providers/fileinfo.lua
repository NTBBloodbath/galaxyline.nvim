local fileinfo = {}

local function file_readonly()
  if vim.bo.filetype == "help" then
    return true
  end
  return vim.bo.readonly
end
--[[ local icon = readonly_icon or ""
  if vim.bo.readonly == true then
    return " " .. icon .. " "
  end
  return ""
end ]]

local function file_with_icons(file, modified_icon, readonly_icon)
  if vim.fn.empty(file) == 1 then
    return ""
  end

  modified_icon = modified_icon or ""
  readonly_icon = readonly_icon or ""

  if file_readonly() then
    file = readonly_icon .. " " .. file
  end

  if vim.bo.modifiable and vim.bo.modified then
    file = file .. " " .. modified_icon
  end

  return " " .. file .. " "
end

--- Get the current file name
--- @param modified_icon string
--- @param readonly_icon string
--- @return string
fileinfo.get_current_file_name = function(modified_icon, readonly_icon)
  local file = vim.fn.expand("%:t")
  return file_with_icons(file, modified_icon, readonly_icon)
end

fileinfo.get_current_file_path = function(modified_icon, readonly_icon)
  local max_dirs = 1
  local file_with_path = "..."
  local file_sep = package.config:sub(1, 1)
  local path_to_file = vim.split(vim.fn.fnamemodify(vim.fn.expand("%"), ":~:."), file_sep)
  for i, _ in ipairs(path_to_file) do
    if i <= max_dirs then
      if i == 1 then
        if path_to_file[#path_to_file - max_dirs] == nil then
          file_with_path = file_with_path .. "/" .. path_to_file[#path_to_file - (#path_to_file - 1)]
        else
          file_with_path = file_with_path .. "/" .. path_to_file[#path_to_file - max_dirs]
        end
      else
        file_with_path = file_with_path .. "/" .. path_to_file[#path_to_file - (i - 1)]
      end
    else
      file_with_path = file_with_path .. "/" .. path_to_file[#path_to_file]
      break
    end
  end

  return file_with_icons(file_with_path, modified_icon, readonly_icon)
end

-- format print current file size
fileinfo.format_file_size = function(file)
  local size = vim.fn.getfsize(file)
  if size == 0 or size == -1 or size == -2 then
    return ""
  end
  if size < 1024 then
    size = size .. "b"
  elseif size < 1024 * 1024 then
    size = string.format("%.1f", size / 1024) .. "k"
  elseif size < 1024 * 1024 * 1024 then
    size = string.format("%.1f", size / 1024 / 1024) .. "m"
  else
    size = string.format("%.1f", size / 1024 / 1024 / 1024) .. "g"
  end
  return size .. " "
end

fileinfo.get_file_size = function()
  local file = vim.fn.expand("%:p")
  if string.len(file) == 0 then
    return ""
  end
  return fileinfo.format_file_size(file)
end

-- get file encode
fileinfo.get_file_encode = function()
  local encode = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
  return " " .. encode:upper()
end

-- get file format
-- and cover to upper
fileinfo.get_file_format = function()
  return vim.bo.fileformat:upper()
end

-- show line:column
fileinfo.line_column = function()
  local line = vim.fn.line(".")
  local column = vim.fn.col(".")
  return string.format("%3d :%2d ", line, column)
end

-- show current line percent of all lines
fileinfo.current_line_percent = function()
  local current_line = vim.fn.line(".")
  local total_line = vim.fn.line("$")
  if current_line == 1 then
    return " Top "
  elseif current_line == vim.fn.line("$") then
    return " Bot "
  end
  local result, _ = math.modf((current_line / total_line) * 100)
  return " " .. result .. "% "
end

local icon_colors = {
  Brown = "#905532",
  Aqua = "#3AFFDB",
  Blue = "#689FB6",
  Darkblue = "#44788E",
  Purple = "#834F79",
  Red = "#AE403F",
  Beige = "#F5C06F",
  Yellow = "#F09F17",
  Orange = "#D4843E",
  Darkorange = "#F16529",
  Pink = "#CB6F6F",
  Salmon = "#EE6E73",
  Green = "#8FAA54",
  Lightgreen = "#31B53E",
  White = "#FFFFFF",
  LightBlue = "#5fd7ff",
}

local icons = {
  Brown = { "" },
  Aqua = { "" },
  LightBlue = { "", "" },
  Blue = { "", "", "", "", "", "", "", "", "", "", "", "", "" },
  Darkblue = { "", "" },
  Purple = { "", "", "", "", "" },
  Red = { "", "", "", "", "", "" },
  Beige = { "", "", "" },
  Yellow = { "", "", "λ", "", "" },
  Orange = { "", "" },
  Darkorange = { "", "", "", "", "" },
  Pink = { "", "" },
  Salmon = { "" },
  Green = { "", "", "", "", "", "" },
  Lightgreen = { "", "", "", "﵂" },
  White = { "", "", "", "", "", "" },
}

-- filetype or extensions : { colors ,icon}
local user_icons = {}

fileinfo.define_file_icon = function()
  return user_icons
end

local function get_file_info()
  return vim.fn.expand("%:t"), vim.fn.expand("%:e")
end

fileinfo.get_file_icon = function()
  local icon = ""
  if vim.fn.exists("*WebDevIconsGetFileTypeSymbol") == 1 then
    icon = vim.fn.WebDevIconsGetFileTypeSymbol()
    return icon .. " "
  end
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    print("No icon plugin found. Please install 'kyazdani42/nvim-web-devicons'")
    return ""
  end
  local f_name, f_extension = get_file_info()
  icon = devicons.get_icon(f_name, f_extension)
  if icon == nil then
    if user_icons[vim.bo.filetype] ~= nil then
      icon = user_icons[vim.bo.filetype][2]
    elseif user_icons[f_extension] ~= nil then
      icon = user_icons[f_extension][2]
    else
      icon = ""
    end
  end
  return icon .. " "
end

fileinfo.get_file_icon_color = function()
  local filetype = vim.bo.filetype
  local f_name, f_ext = get_file_info()

  if user_icons[filetype] ~= nil then
    return user_icons[filetype][1]
  end

  if user_icons[f_ext] ~= nil then
    return user_icons[f_ext][1]
  end

  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    local icon, iconhl = devicons.get_icon(f_name, f_ext)
    if icon ~= nil then
      return vim.fn.synIDattr(vim.fn.hlID(iconhl), "fg")
    end
  end

  local icon = fileinfo.get_file_icon():match("%S+")
  for k, _ in pairs(icons) do
    if vim.fn.index(icons[k], icon) ~= -1 then
      return icon_colors[k]
    end
  end
end

fileinfo.filename_in_special_buffer = function()
  local short_list = require("galaxyline").short_line_list
  local fname = fileinfo.get_current_file_name()
  for _, v in ipairs(short_list) do
    if v == vim.bo.filetype then
      return ""
    end
  end
  return fname
end

return fileinfo
