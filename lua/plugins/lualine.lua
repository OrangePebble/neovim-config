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
					"diff",
					{
						"diagnostics",
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
							hint = " ",
						},
					},
					{ "overseer", symbols = {
						[require("overseer").STATUS.PENDING] = "󱎫 ",
					} },
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

		-- This somewhat reduces the problem of cmdline printing its contents multiple times whenever
		--  a line wrap occurs, it now flickers instead by redrawing on every new character.
		-- This problem is caused by plugins that modify the cmdline like lualine and blink-cmp (if
		--  I don't disable cmdline functionality).
		-- This fix should be enough because line wrapping on the cmdline doesn't happen often, I've
		--  only noticed when I started using the OpenCode plugin.
		vim.api.nvim_create_autocmd("CmdlineChanged", {
			callback = function()
				vim.cmd("redraw")
			end,
		})
	end,
	dependencies = { "echasnovski/mini.icons" },
}
