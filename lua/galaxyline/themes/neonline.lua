-- Original design by Groctel:
-- https://github.com/Groctel/dotfiles/blob/0ccd8d6d992f300c6a79fc8987ed64132790e817/files-common/.config/nvim/lua/neonline.lua

local gl     = require('galaxyline')
local gls    = gl.section
local colors = {
    bg      = '#1f2335',
    fg      = '#06080A',
    red     = '#EE6D85',
    orange  = '#F6955B',
    yellow  = '#D7A65F',
    green   = '#95C561',
    blue    = '#7199EE',
    cyan    = '#38A89D',
    purple  = '#A485DD',
    magenta = '#bb9af7',
    white   = '#efefef',
}

local buffer    = require('galaxyline.providers.buffer')
local condition = require('galaxyline.condition')
local fileinfo  = require('galaxyline.providers.fileinfo')
local lsp       = require('galaxyline.providers.lsp')
local vcs       = require('galaxyline.providers.vcs')

gl.short_line_list = {'NvimTree', 'help', 'tagbar'}

-- Maps {{{1
local mode_color = { -- {{{2
	c  = colors.magenta, ['!'] = colors.red,
	i  = colors.green,   ic    = colors.yellow, ix     = colors.yellow,
	n  = colors.blue,
	no = colors.blue,    nov   = colors.blue,   noV    = colors.blue,
	r  = colors.cyan,    rm    = colors.cyan,   ['r?'] = colors.cyan,
	R  = colors.purple,  Rv    = colors.purple,
	s  = colors.orange,  S     = colors.orange, [''] = colors.orange,
	t  = colors.purple,
	v  = colors.red,     V     = colors.red,    [''] = colors.red,
}
-- }}}2

local mode_icon = { --- {{{2
	c = "🅒 ", ['!'] = "🅒 ",
	i = "🅘 ", ic    = "🅘 ", ix     = "🅘 ",
	n = "🅝 ",
	R = "🅡 ", Rv    = "🅡 ",
	r = "🅡 ", rm    = "🅡 ", ['r?'] = "🅡 ",
	s = "🅢 ", S     = "🅢 ", [''] = "🅢 ",
	t = "🅣 ",
	v = "🅥 ", V     = "🅥 ", [''] = "🅥 ",
}
-- }}}2

local num_icons = {"➊ ", "❷ ", "➌ ", "➍ ", "➎ ", "➏ ", "➐ ", "➑ ", "➒ ", " "}
-- }}}1

-- Left hand side modules {{{1
gls.left[0] = { Left = { -- {{{2
	highlight = {colors.blue, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyLeft guifg='..mode_color[vim.fn.mode()])
		return "█"
	end,
}}
-- }}}2

gls.left[1] = { ModeNum = { -- {{{2
	highlight = {colors.fg, colors.bg, 'bold'},

	provider = function ()
		vim.api.nvim_command('hi GalaxyModeNum guibg='..mode_color[vim.fn.mode()])
		return
			mode_icon[vim.fn.mode()]..
			num_icons[math.min(10, buffer.get_buffer_number())]
	end,
}}
-- }}}2

gls.left[2] = { BufSep = { -- {{{2
	highlight = {colors.bg, colors.bg},

	provider = function ()
		vim.api.nvim_command("hi GalaxyBufSep guibg="..mode_color[vim.fn.mode()])
		return "█"
	end,
}}
-- }}}2

gls.left[3] = { FileIcon = { -- {{{2
	condition = condition.buffer_not_empty,
	highlight = {fileinfo.get_file_icon_color, colors.bg},
	provider  = 'FileIcon',
}}
-- }}}2

gls.left[4] = { FileName = { -- {{{2
	condition = condition.buffer_not_empty,
	highlight = {colors.white, colors.bg, 'bold'},
	provider  = 'FileName',
}}
-- }}}2

gls.left[5] = { FileSep = { -- {{{2
	highlight = {colors.bg, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyFileSep guibg='..mode_color[vim.fn.mode()])
		return " "
	end,
}}
-- }}}2

gls.left[6] = { FileEF = { -- {{{2
	highlight = {colors.fg, colors.bg, 'bold'},

	provider = function ()
		local format_icon = {['DOS'] = " ", ['MAC'] = " ", ['UNIX'] = " "}
		local encode      = fileinfo.get_file_encode()
		local format      = fileinfo.get_file_format()

		vim.api.nvim_command('hi GalaxyFileEF guibg='..mode_color[vim.fn.mode()])
		return encode..' '..format_icon[format]
	end,
}}
-- }}}2

gls.left[7] = { EFSep = { -- {{{2
	highlight = {colors.bg, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyEFSep guibg='..mode_color[vim.fn.mode()])
		return "█"
	end,
}}
-- }}}2

gls.left[8] = { Git = { -- {{{2
	condition = condition.check_git_workspace,
	highlight = {colors.blue, colors.bg, 'bold'},

	provider = function ()
		vim.api.nvim_command('hi GalaxyGit guifg='..mode_color[vim.fn.mode()])
		local branch = vcs.get_git_branch()
		if (branch == nil) then branch = '???' end
		return ' '..branch..' '
	end,
}}
-- }}}2
-- }}}1

-- Centered modules {{{1
gls.mid[0] = { Empty = {
	highlight = {colors.bg, colors.bg},
	provider  = function () return end,
}}
-- }}}1

-- Right hand side modules {{{1
gls.right[0] = { LspClient = { -- {{{2
	highlight = {colors.fg, colors.bg, 'bold'},

	provider = function ()
		local icon = ' '
		local active_lsp = lsp.get_lsp_client()

		if active_lsp == 'No Active Lsp' then
			icon = ''
			active_lsp  = ''
		end

		vim.api.nvim_command('hi GalaxyLspClient guifg='..mode_color[vim.fn.mode()])
		return icon..active_lsp..' '
	end,
}}
-- }}}2

gls.right[1] = { DiagnosticError = { -- {{{2
	highlight = {colors.red, colors.bg, 'bold'},

	provider = function ()
		local icon = ' '
		local count = vim.diagnostic.get_count(0, 'Error')

		if count == 0 then
			return
		else
			return icon..count..' '
		end
	end,
}}
-- }}}2

gls.right[2] = { DiagnosticWarn = { -- {{{2
	highlight = {colors.yellow, colors.bg, 'bold'},

	provider = function ()
		local icon = ' '
		local count = vim.diagnostic.get_count(0, 'Warning')

		if count == 0 then
			return
		else
			return icon..count..' '
		end
	end,
}}
-- }}}2

gls.right[3] = { DiagnosticHint = { -- {{{2
	highlight = {colors.cyan, colors.bg, 'bold'},

	provider = function ()
		local icon = ' '
		local count = vim.diagnostic.get_count(0, 'Hint')

		if count == 0 then
			return
		else
			return icon..count..' '
		end
	end,
}}
-- }}}2

gls.right[4] = { DiagnosticInfo = { -- {{{2
	highlight = {colors.blue, colors.bg, 'bold'},

	provider = function ()
		local icon = ' '
		local count = vim.diagnostic.get_count(0, 'Information')

		if count == 0 then
			return
		else
			return icon..count..' '
		end
	end,
}}
-- }}}2

gls.right[5] = { LineSep = { -- {{{2
	highlight = {colors.bg, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyLineSep guibg='..mode_color[vim.fn.mode()])
		return " "
	end,
}}
-- }}}2

gls.right[6] = { LineInfo = { -- {{{2
	highlight = {colors.fg, colors.bg, 'bold'},

	provider = function ()
		local cursor = vim.api.nvim_win_get_cursor(0)

		vim.api.nvim_command('hi GalaxyLineInfo guibg='..mode_color[vim.fn.mode()])
		return '☰ '..cursor[1]..'/'..vim.api.nvim_buf_line_count(0)..':'..cursor[2]
	end,
}}
-- }}}2

gls.right[7] = { Right = { -- {{{2
	highlight = {colors.blue, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyRight guifg='..mode_color[vim.fn.mode()])
		return '█'
	end,
}}
-- }}}2
-- }}}1

-- Short line left hand side modules {{{1
gls.short_line_left[0] = { Left = { -- {{{2
	highlight = {colors.blue, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyLeft guifg='..mode_color[vim.fn.mode()])
		return "█"
	end,
}}
-- }}}2

gls.short_line_left[1] = { ModeNum = { -- {{{2
	highlight = {colors.fg, colors.bg, 'bold'},

	provider = function ()
		vim.api.nvim_command('hi GalaxyModeNum guibg='..mode_color[vim.fn.mode()])
		return
			mode_icon[vim.fn.mode()]..
			num_icons[math.min(10, buffer.get_buffer_number())]
	end,
}}
-- }}}2

gls.short_line_left[2] = { BufSep = { -- {{{2
	highlight = {colors.bg, colors.bg},

	provider = function ()
		vim.api.nvim_command("hi GalaxyBufSep guibg="..mode_color[vim.fn.mode()])
		return "█"
	end,
}}
-- }}}2

gls.short_line_left[3] = { FileIcon = { -- {{{2
	condition = condition.buffer_not_empty,
	highlight = {fileinfo.get_file_icon_color, colors.bg},
	provider  = 'FileIcon',
}}
-- }}}2

gls.short_line_left[4] = { FileName = { -- {{{2
	highlight = {colors.white, colors.bg, 'bold'},
	provider  = 'FileName',
}}
-- }}}2
-- }}}1

-- Short line right hand side modules {{{1
gls.short_line_right[1] = { LineSep = { -- {{{2
	highlight = {colors.bg, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyLineSep guibg='..mode_color[vim.fn.mode()])
		return " "
	end,
}}
-- }}}2

gls.short_line_right[2] = { LineInfo = { -- {{{2
	highlight = {colors.fg, colors.bg, 'bold'},

	provider = function ()
		local cursor = vim.api.nvim_win_get_cursor(0)

		vim.api.nvim_command('hi GalaxyLineInfo guibg='..mode_color[vim.fn.mode()])
		return '☰ '..cursor[1]..'/'..vim.api.nvim_buf_line_count(0)..':'..cursor[2]
	end,
}}
-- }}}2

gls.short_line_right[3] = { Right = { -- {{{2
	highlight = {colors.blue, colors.bg},

	provider = function ()
		vim.api.nvim_command('hi GalaxyRight guifg='..mode_color[vim.fn.mode()])
		return '█'
	end,
}}
-- }}}2
-- }}}1
