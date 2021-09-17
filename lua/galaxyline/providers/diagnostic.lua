local diagnostic = {}

-- coc diagnostic
local function get_coc_diagnostic(diag_type)
  local has_info, info = pcall(vim.api.nvim_buf_get_var, 0, "coc_diagnostic_info")
  if not has_info then
    return ""
  end

  return info[diag_type]
end

-- nvim-lspconfig
-- see https://github.com/neovim/nvim-lspconfig
local function get_nvim_lsp_diagnostic(diag_type)
  if next(vim.lsp.buf_get_clients(0)) == nil then
    return ""
  end
  local active_clients = vim.lsp.get_active_clients()
  local count = 0

  if active_clients then
    for _, client in ipairs(active_clients) do
      count = count + vim.lsp.diagnostic.get_count(vim.api.nvim_get_current_buf(), diag_type, client.id)
    end

    return count
  end
end

diagnostic.get_diagnostic = function(diag_type)
  local count = 0

  if vim.fn.exists("*coc#rpc#start_server") == 1 then
    count = get_coc_diagnostic(diag_type:lower())
  elseif not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    count = get_nvim_lsp_diagnostic(diag_type)
  end

  return count
end

local function get_formatted_diagnostic(diag_type)
  local count = diagnostic.get_diagnostic(diag_type)
  return count ~= 0 and count .. " " or ""
end

diagnostic.get_diagnostic_error = function()
  return get_formatted_diagnostic("Error")
end

diagnostic.get_diagnostic_warn = function()
  return get_formatted_diagnostic("Warning")
end

diagnostic.get_diagnostic_hint = function()
  return get_formatted_diagnostic("Hint")
end

diagnostic.get_diagnostic_info = function()
  return get_formatted_diagnostic("Information")
end

return diagnostic
