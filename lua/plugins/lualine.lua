return {
	-- Fast and easy to configu statusline.
	"nvim-lualine/lualine.nvim",
	config = function()
		-- Should be the same as the ones at ../utils/diagnostics.lua
		local diagnostic_symbols = {
			error = " ",
			warn = " ",
			info = " ",
			hint = "󰌶 ",
		}

		-- Should be the same as the ones at ./dev/overseer.lua
		local overseer_symbols = {
			[require("overseer").STATUS.PENDING] = "󰟃 ",
			[require("overseer").STATUS.RUNNING] = "󰐌 ",
			[require("overseer").STATUS.CANCELED] = "󰏥 ",
			[require("overseer").STATUS.SUCCESS] = "󰗠 ",
			[require("overseer").STATUS.FAILURE] = "󰅙 ",
			[require("overseer").STATUS.DISPOSED] = "󰄰 ",
		}

		local help_extension = { sections = { lualine_y = { "filetype" } }, filetypes = { "help" } }

		local dapui_extension = {
			sections = { lualine_a = { { "filename", file_status = false } } },
			inactive_sections = { lualine_c = { { "filename", file_status = false } } },
			filetypes = {
				"dap-repl",
				"dapui_console",
				"dapui_watches",
				"dapui_stacks",
				"dapui_breakpoints",
				"dapui_scopes",
			},
		}

		local nvimtree_extension = {
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
		}

		local overseer_list_extension = {
			sections = {
				lualine_a = {
					function()
						return "󰜎"
					end,
				},
			},
			inactive_sections = {
				lualine_c = {
					function()
						return "󰜎"
					end,
				},
			},
			filetypes = { "OverseerList" },
		}
		local overseer_output_extension = {
			sections = {
				lualine_c = { { "overseer", symbols = overseer_symbols } },
				lualine_x = {
					function()
						return vim.fn.line(".") .. "/" .. vim.fn.line("$")
					end,
				},
				lualine_z = {
					function()
						return " Overseer"
					end,
				},
			},
			inactive_sections = {
				lualine_c = { { "overseer", symbols = overseer_symbols } },
				lualine_x = {
					function()
						return " Overseer"
					end,
				},
			},
			filetypes = { "OverseerOutput" },
		}

		-- See the default config here:
		-- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#default-configuration
		require("lualine").setup({
			options = {
				icons_enabled = true,
			},
			extensions = {
				"trouble",
				help_extension,
				dapui_extension,
				nvimtree_extension,
				overseer_list_extension,
				overseer_output_extension,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {},
				lualine_c = {
					"diff",
					{
						"diagnostics",
						symbols = diagnostic_symbols,
					},
					{
						"overseer",
						symbols = overseer_symbols,
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
				lualine_x = { "filetype" },
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
            -- TODO: Is there maybe a way to instead of shortenning the path directory names to instead scroll the full thing?
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
