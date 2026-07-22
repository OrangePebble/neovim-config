return {
	{
		"mfussenegger/nvim-dap",
		recommended = true,
		desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

		dependencies = {
			{
				-- fancy UI for the debugger
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
			{
				-- virtual text for the debugger
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
			-- mason.nvim integration
			"jay-babu/mason-nvim-dap.nvim",
			"nvim-lua/plenary.nvim",
		},

		config = function()
			require("mason-nvim-dap").setup({
				-- Makes a best effort to setup the various debuggers with reasonable debug configurations
				automatic_installation = true,
				-- Additional handler configuration.
				handlers = {},
				-- Get all possible values for here at:
				--  https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
				ensure_installed = {},
			})

			vim.fn.sign_define("DapStopped", { text = "󰁕 ", texthl = "DapStopped", linehl = "DapStoppedLine" })
			vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DapBreakpointCondition" })
			vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DapBreakpointRejected" })
			vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DapLogPoint" })

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end

			local dap = require("dap")
			local dapui = require("dapui")
			---@diagnostic disable-next-line: missing-fields
			dapui.setup({
				floating = {
					border = "single",
					mappings = {
						close = {},
					},
				},
				layouts = {
					{
						elements = { "scopes", "breakpoints", "stacks", "watches" },
						size = 30,
						position = "left",
					},
					{
						elements = {
							"repl",
							-- "console",
						},
						size = 12,
						position = "bottom",
					},
				},
			})

			-- Overwritting the closing keymaps for the eval floating window so it doesn't also close the dapui splits.
			-- This required disabling floating mappings above, so all other floating dapui closing mappings don't work currently.
			local dapui_hover_group = vim.api.nvim_create_augroup("DapuiHoverKeymaps", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				group = dapui_hover_group,
				pattern = "dapui_hover",
				callback = function(event)
					local close_hover = function()
						require("dapui.windows").close_float("hover")
						vim.api.nvim_win_close(0, true)
					end

					local opts = { buffer = event.buf, silent = true, nowait = true, desc = "Close DAP eval" }
					vim.keymap.set("n", "q", close_hover, opts)
					vim.keymap.set("n", "<Esc>", close_hover, opts)
				end,
			})

			local repl_hint_shown = false
			dap.listeners.after.event_stopped["dapui_config"] = function()
				if not repl_hint_shown then
					repl_hint_shown = true
					require("dap.repl").append(
						"DAP commands are prefixed with '.'. Run '.help' to see more.",
						"$",
						{ newline = false }
					)
				end
			end
			dap.listeners.after.event_terminated["dapui_config"] = function()
				repl_hint_shown = false
			end

			-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#c-c-rust-via-gdb
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
		end,
	},
}
