return {
	-- Fast and easy to configu statusline.
	"nvim-lualine/lualine.nvim",
	config = function()
		-- See the default config here:
		-- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#default-configuration
		require("lualine").setup({
			options = {
				icons_enabled = true,
			},
			extensions = {
				"trouble",
				"nvim-dap-ui",
				{ sections = { lualine_y = { "filetype" } }, filetypes = { "help" } },
				{
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
					inactive_sections = {
						lualine_c = {
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
				{
					sections = {
						lualine_a = {
							function()
								-- Returning just the filetype icon because the window is usually very thin.
								return "󰜎"
							end,
						},
					},
					inactive_sections = {
						lualine_c = {
							function()
								-- Returning just the filetype icon because the window is usually very thin.
								return "󰜎"
							end,
						},
					},
					filetypes = { "OverseerList" },
				},
				{
					sections = {
						lualine_c = { { "overseer", symbols = { [require("overseer").STATUS.PENDING] = "󱎫 " } } },
						lualine_z = { "filetype" },
					},
					inactive_sections = {
						lualine_c = { { "overseer", symbols = { [require("overseer").STATUS.PENDING] = "󱎫 " } } },
						lualine_x = { "filetype" },
					},
					filetypes = { "OverseerOutput" },
				},
			},
			sections = {
				lualine_a = { "mode" },
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
					{
						"overseer",
						symbols = {
							[require("overseer").STATUS.PENDING] = "󱎫 ",
						},
						cond = function()
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								local buf = vim.api.nvim_win_get_buf(win)
								if vim.bo[buf].filetype == "OverseerOutput" then
									return false
								end
							end
							return true
						end,
					},
				},
				lualine_c = {},
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
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
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
