-- https://github.com/tzhouhc/vim/blob/5b994bc79a1e935bc0ed7c2d797836ff3b351751/lua/lib/ft.lua
-- Records the types of ft's and buft's that should be ignored for the purpose
-- of activating plugins, keymaps, completions, etc

local M = {}

M.special_filetypes = {
	"help",
	"man",
	"netrw",
	"NvimTree",
	"neo-tree",
	"fzf",
	"FzfLua",
	"Telescope",
	"fugitive",
	"dashboard",
	"startify",
	"alpha",
	"lspinfo",
	"oil",
	"trouble",
	"OverseerList",
	"OverseerOutput",
	-- Add more as needed
}

M.special_buftypes = {
	"terminal",
	"nofile",
	"prompt",
	"quickfix",
	"help",
	"trouble",
	-- Add more as needed
}

function M.is_normal_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	-- Get buffer type/filetype
	local buf_type = vim.bo[bufnr].buftype
	local filetype = vim.bo[bufnr].filetype

	-- Check if the buffer is special
	for _, ft in ipairs(M.special_filetypes) do
		if filetype == ft then
			return false
		end
	end

	for _, bt in ipairs(M.special_buftypes) do
		if buf_type == bt then
			return false
		end
	end

	return true
end

function M.is_file_backed(bufnr)
	if vim.api.nvim_buf_get_name(bufnr) then
		return true
	end
	return false
end

return M
