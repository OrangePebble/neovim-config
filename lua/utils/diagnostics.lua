local M = {}

-- https://www.reddit.com/r/neovim/comments/1jlq1iz/comment/mk5hxh7/

local diagnostic_signs = {
	[vim.diagnostic.severity.ERROR] = "",
	[vim.diagnostic.severity.WARN] = "",
	[vim.diagnostic.severity.INFO] = "",
	[vim.diagnostic.severity.HINT] = "󰌶",
}

local shorter_source_names = {
	-- ["Lua Diagnostics."] = "Lua",
	-- ["Lua Syntax Check."] = "Lua",
}

M.setup = function()
	vim.diagnostic.config({
		-- virtual_text = { spacing = 4, prefix = "", format = diagnostic_format, current_line = true, },
		float = {
			format = function(diagnostic)
				return string.format(
					"%s %s (%s)",
					diagnostic_signs[diagnostic.severity],
					diagnostic.message,
					shorter_source_names[diagnostic.source] or diagnostic.source
				)
			end,
		},
		signs = {
			text = diagnostic_signs,
		},
		underline = true,
		severity_sort = true,
	})
end

M.toggle_virtual_lines = function()
	if vim.g.diagnostic_virtual_lines == true then
		vim.diagnostic.config({ virtual_lines = false })
		vim.g.diagnostic_virtual_lines = false
	else
		vim.diagnostic.config({
			virtual_lines = {
				current_line = true,
				format = function(diagnostic)
					return string.format(
						"%s %s (%s) [%s]",
						diagnostic_signs[diagnostic.severity],
						diagnostic.message,
						shorter_source_names[diagnostic.source] or diagnostic.source,
						diagnostic.code
					)
				end,
			},
		})
		vim.g.diagnostic_virtual_lines = true
	end
end

return M
