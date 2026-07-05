return {
	-- Fast and easy to configu statusline.
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
				"nvim-dap-ui",
				{
					-- nvim-tree
					sections = {
						lualine_a = {
							{
								function()
									return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
								end,
								on_click = function()
									require("nvim-tree.api").tree.toggle()
								end,
							},
						},
					},
					filetypes = { "NvimTree" },
				},
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
				lualine_z = {
					-- Added this so I can easily tell if I've closed the wrong file during a git diff but
					--  it might also be useful in other occasions.
					{
						function()
							return vim.bo.buftype
						end,
						cond = function()
							return vim.bo.buftype ~= ""
						end,
					},
					{
						"filename",
						on_click = function()
							require("nvim-tree.api").tree.toggle({ focus = false })
						end,
						cond = function()
							return not vim.g.nvim_tree_open
						end,
					},
					{
						"filename",
						path = 1, -- Relative path
						on_click = function()
							require("nvim-tree.api").tree.close()
						end,
						cond = function()
							return vim.g.nvim_tree_open
						end,
					},
				},
			},
		})

		-- This somewhat reduces the problem of cmdline printing its contents multiple times whenever
		--  the line fills as this clears the prints when a character is removed/added. It now flickers
		--  instead.
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
