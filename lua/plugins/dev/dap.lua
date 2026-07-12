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

			-- Highlight stopped line.
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			local breakpoint_icons = {
				Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = " ",
				BreakpointCondition = " ",
				BreakpointRejected = " ",
				LogPoint = { ".>", "DiagnosticInfo" },
			}
			for name, sign in pairs(breakpoint_icons) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					---@diagnostic disable-next-line: assign-type-mismatch
					{ text = sign[1], texthl = sign[2] or "DiagnosticError", linehl = sign[3], numhl = sign[3] }
				)
			end

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end

			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup()

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

			-- Reset cache so next explicit launch prompts again.
			local function default_program()
				return require("utils.picker").pick_file(vim.fn.getcwd(), nil) or dap.ABORT
			end
			local function default_args()
				return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
			end

			-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#c-c-rust-via-gdb
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			-- See available options at: https://sourceware.org/gdb/current/onlinedocs/gdb.html/Debugger-Adapter-Protocol.html
			dap.configurations.c = {
				{
					name = "Run file",
					type = "gdb",
					request = "launch",
					cwd = "${workspaceFolder}",
					program = default_program,
					args = default_args,
				},
				{
					name = "Select and attach to process",
					type = "gdb",
					request = "attach",
					pid = function()
						local name = vim.fn.input("Executable name (filter): ")
						return require("dap.utils").pick_process({ filter = name })
					end,
					cwd = "${workspaceFolder}",
					program = default_program,
				},
				{
					name = "Attach to gdbserver :1234",
					type = "gdb",
					request = "attach",
					target = "localhost:1234",
					cwd = "${workspaceFolder}",
					program = default_program,
				},
			}
			dap.configurations.cpp = dap.configurations.c
			dap.configurations.rust = dap.configurations.c
		end,
	},
}
