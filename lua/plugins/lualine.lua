-- Fast and easy to configu statusline.
return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local trouble = require("trouble")
		local symbols = trouble.statusline({
			mode = "lsp_document_symbols",
			groups = {},
			title = false,
			filter = { range = true },
			format = "{kind_icon}{symbol.name:Normal}",
			-- The following line is needed to fix the background color
			-- Set it to the lualine section you want to use
			hl_group = "lualine_c_normal",
		})
		-- See the default config here:
		-- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#default-configuration
		require("lualine").setup({
			options = {
				icons_enabled = true,
			},
			extensions = {
				"trouble",
				"nvim-tree",
				"nvim-dap-ui",
			},
			sections = {
				lualine_b = {
					{
						"diff",
						symbols = {
							added = " ",
							modified = " ",
							removed = " ",
						},
					},
					{
						"diagnostics",
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
							hint = " ",
						},
					},
				},
				lualine_c = {
					{
						symbols.get,
						cond = function()
							return symbols.has() and (vim.b.has_lsp == true)
						end,
					},
				},
				lualine_x = {},
				lualine_y = { "filetype" },
				lualine_z = { "filename" },
			},
		})
	end,
	dependencies = { "echasnovski/mini.icons" },
}
