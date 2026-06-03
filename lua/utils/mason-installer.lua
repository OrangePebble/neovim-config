local M = {}

M.tools = {}

M.ensure_installed = function(new_tools)
	vim.list_extend(M.tools, new_tools)
	require("mason-tool-installer").setup({ ensure_installed = M.tools })
end

return M
