local galaxyline = {}
galaxyline.section = {}
galaxyline.section.left = {}
galaxyline.section.right = {}
galaxyline.section.mid = {}
galaxyline.section.short_line_left = {}
galaxyline.section.short_line_right = {}
galaxyline.short_line_list = {}
galaxyline.exclude_filetypes = {}

local galaxyline_providers = require("galaxyline.provider").load_providers()

local function check_component_exists(component_name)
  for _, pos_value in pairs(galaxyline.section) do
    for _, v in pairs(pos_value) do
      if v[component_name] ~= nil then
        return true, v[component_name]
      end
    end
  end
  return false, nil
end

local function exec_provider(icon, cmd)
  local output = cmd()
  if output == nil then
    return ""
  end
  if string.len(icon) ~= 0 and string.len(output) ~= 0 and output then
    return icon .. output
  end
  return output
end

-- component decorator
-- that will output the component result with icon
-- component provider can be string or table
-- component icon can be string or function
function galaxyline.component_decorator(component_name)
  -- if section doesn't have component just return
  local ok, component_info = check_component_exists(component_name)
  if not ok then
    print(string.format("Does not found this component: %s", component_name))
    return
  end
  local provider = component_info.provider or ""
  local icon = component_info.icon or ""
  if type(icon) == "function" then
    icon = icon()
  end
  if type(icon) ~= "string" then
    icon = ""
  end

  local _switch = {
    ["string"] = function()
      if galaxyline_providers[provider] == nil then
        if next(galaxyline_providers) ~= nil then
          print(string.format("provider of %s does not exist in default provider group", component_name))
          return ""
        end
        return ""
      end
      return exec_provider(icon, galaxyline_providers[provider])
    end,
    ["function"] = function()
      return exec_provider(icon, provider)
    end,
    ["table"] = function()
      local output = ""
      for _, v in pairs(provider) do
        if type(v) ~= "string" and type(v) ~= "function" then
          print(string.format("Wrong provider type in %s", component_name))
          return ""
        end

        if type(v) == "string" then
          if type(galaxyline_providers[v]) ~= "function" then
            if next(galaxyline_providers) ~= nil then
              print(string.format("Does not found the provider in default provider in %s", component_name))
              return ""
            end
            return ""
          end
          output = output .. exec_provider(icon, galaxyline_providers[v])
        end

        if type(v) == "function" then
          output = output .. exec_provider(icon, v)
        end
      end
      return output
    end,
  }

  local _switch_metatable = {
    __index = function(_type)
      return print(string.format("Type %s of provider does not support", _type))
    end,
  }
  setmetatable(_switch, _switch_metatable)

  return _switch[type(provider)]()
end

local function generate_section(component_name)
  local line = ""
  line = line .. "%#" .. "Galaxy" .. component_name .. "#"
  line = line .. [[%{luaeval('require("galaxyline").component_decorator')]] .. '("' .. component_name .. '")}'
  return line
end

local function generate_separator_section(component_name, separator)
  local separator_name = component_name .. "Separator"
  local line = ""
  line = line .. "%#" .. separator_name .. "#" .. separator
  return line
end

local function section_complete_with_option(component, component_info, position)
  local tmp_line = ""
  -- get the component condition and dynamicswitch
  local condition = component_info.condition or nil
  local separator = component_info.separator or nil

  if condition then
    if condition() then
      tmp_line = tmp_line .. generate_section(component)
      if separator then
        if position == "left" then
          tmp_line = tmp_line .. generate_separator_section(component, separator)
        else
          tmp_line = generate_separator_section(component, separator) .. tmp_line
        end
      end
    end
    return tmp_line
  end

  tmp_line = tmp_line .. generate_section(component)
  if separator then
    if position == "left" then
      tmp_line = tmp_line .. generate_separator_section(component, separator)
    elseif position == "right" then
      tmp_line = generate_separator_section(component, separator) .. tmp_line
    else
      if type(separator) == "table" then
        tmp_line = generate_separator_section(component, separator[1])
          .. tmp_line
          .. generate_separator_section(component, separator[2])
      end
    end
  end

  return tmp_line
end

local hi_tbl = {}
local events = {
  "ColorScheme",
  "FileType",
  "BufWinEnter",
  "BufReadPost",
  "BufWritePost",
  "BufEnter",
  "WinEnter",
  "FileChangedShellPost",
  "VimResized",
  "TermOpen",
}

local function load_section(section_area, pos)
  local section = ""
  if section_area == nil then
    return section
  end

  for _, component in pairs(section_area) do
    for component_name, component_info in pairs(component) do
      local ls = section_complete_with_option(component_name, component_info, pos)
      section = section .. ls
      local group = "Galaxy" .. component_name
      local sgroup = component_name .. "Separator"
      hi_tbl[group] = component_info.highlight or {}
      hi_tbl[sgroup] = component_info.separator_highlight or {}
      if component_info.event and vim.fn.index(events, component_info.event) == -1 then
        events[#events + 1] = component_info.event
      end
    end
  end
  return section
end

local short_line = ""
local normal_line = ""

function galaxyline.load_galaxyline()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return
  end

  local left_section = load_section(galaxyline.section.left, "left")
  local right_section = load_section(galaxyline.section.right, "right")
  local mid_section = next(galaxyline.section.mid) ~= nil and load_section(galaxyline.section.mid, "mid") or nil
  local short_left_section = load_section(galaxyline.section.short_line_left, "left")
  local short_right_section = load_section(galaxyline.section.short_line_right, "right")
  local line

  if mid_section then
    local fill_section = "%#GalaxylineFillSection#%="
    line = left_section .. fill_section .. mid_section .. fill_section .. right_section
  else
    line = left_section .. "%=" .. right_section
  end
  normal_line = line
  short_line = short_left_section .. "%=" .. short_right_section

  if vim.tbl_contains(galaxyline.short_line_list, vim.bo.filetype) then
    line = short_line
  end

  if not vim.tbl_contains(galaxyline.exclude_filetypes, vim.bo.filetype) then
    vim.wo.statusline = line
    galaxyline.init_colorscheme()
  end
end

function galaxyline.inactive_galaxyline()
  if next(galaxyline.short_line_list) == nil then
    vim.wo.statusline = normal_line
  else
    vim.wo.statusline = short_line
  end
end

function galaxyline.init_colorscheme()
  require("galaxyline.highlighting").init_theme(hi_tbl)
end

function galaxyline.disable_galaxyline()
  vim.wo.statusline = ""
  vim.api.nvim_command("augroup galaxyline")
  vim.api.nvim_command("autocmd!")
  vim.api.nvim_command("augroup END!")
end

function galaxyline.galaxyline_augroup()
  vim.api.nvim_command("augroup galaxyline")
  vim.api.nvim_command("autocmd!")
  for _, def in ipairs(events) do
    local command = string.format('autocmd %s * lua require("galaxyline").load_galaxyline()', def)
    vim.api.nvim_command(command)
  end
  vim.api.nvim_command('autocmd WinLeave * lua require("galaxyline").inactive_galaxyline()')
  vim.api.nvim_command("augroup END")
end

return galaxyline
