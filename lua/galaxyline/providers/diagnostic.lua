local diagnostic = {}

-- coc diagnostic
local function get_coc_diagnostic(diag_type)
  local has_info, info = pcall(vim.api.nvim_buf_get_var, 0, 'coc_diagnostic_info')
  if not has_info then
    return
  end

  return info[diag_type]
end

-- nvim-lspconfig
-- see https://github.com/neovim/nvim-lspconfig
local function get_nvim_lsp_diagnostic()
  if next(vim.lsp.buf_get_clients(0)) == nil then
    return ''
  end

  return #vim.diagnostic.get(vim.api.nvim_get_current_buf())
end

diagnostic.get_diagnostic = function(diag_type)
  local count = 0

  if vim.fn.exists('*coc#rpc#start_server') == 1 then
    count = get_coc_diagnostic(diag_type:lower())
  elseif not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    count = get_nvim_lsp_diagnostic()
  end

  return count
end

local function get_formatted_diagnostic(diag_type)
  local count = diagnostic.get_diagnostic(diag_type)
  if not count then
    return
  end
  return count ~= 0 and count .. ' ' or ''
end

diagnostic.get_diagnostic_error = function()
  return get_formatted_diagnostic('Error')
end

diagnostic.get_diagnostic_warn = function()
  return get_formatted_diagnostic('Warning')
end

diagnostic.get_diagnostic_hint = function()
  return get_formatted_diagnostic('Hint')
end

diagnostic.get_diagnostic_info = function()
  return get_formatted_diagnostic('Information')
end

return diagnostic
