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
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
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
				dapui.close()
			end
			dap.listeners.after.event_exited["dapui_config"] = function()
				repl_hint_shown = false
				dapui.close()
			end

			-- Cache for last-used program/args/address so run_last reuses them.
			local _cache = {}
			local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
			local function cached(key, fn)
				return function()
					if _cache[key] ~= nil then
						return _cache[key]
					end
					local result = fn()
					_cache[key] = result
					return result
				end
			end
			-- Reset cache so next explicit launch prompts again.
			vim.api.nvim_create_user_command("DapResetCache", function()
				_cache = {}
			end, { desc = "Reset DAP selection cache" })
			local function pick_executable(path, title)
				if path:sub(-1) ~= "/" then
					path = path .. "/"
				end
				local co = coroutine.running()
				local selected = nil
				Snacks.picker.files({
					cwd = path,
					title = title or "Path to executable",
					ignored = true,
					hidden = true,
					layout = { hidden = { "preview" } },
					confirm = function(picker, item)
						picker:close()
						selected = item and item.file or nil
						if co then
							coroutine.resume(co)
						end
					end,
				})
				if co then
					coroutine.yield()
				end
				return path .. selected
			end
			local default_program = cached("program", function()
				return pick_executable(vim.fn.getcwd(), nil)
			end)
			local default_args = cached("args", function()
				return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
			end)

			-- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#c-c-rust-via-gdb
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			dap.configurations.c = {}
			-- Adding these optional ones first so they show on top of the list.
			if string.match(cwd_name, "ddad") then
				vim.list_extend(dap.configurations.c, {
					{
						name = "Launch astas_cli",
						type = "gdb",
						request = "launch",
						cwd = "${workspaceFolder}",
						program = cached("program", function()
							return vim.fn.getcwd() .. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli"
						end),
						args = default_args,
					},
					{
						name = "Launch file in ./bazel-bin",
						type = "gdb",
						request = "launch",
						cwd = "${workspaceFolder}",
						program = cached("program", function()
							return pick_executable(vim.fn.getcwd() .. "/bazel-bin", "Path to executable (./bazel-bin)")
						end),
						args = default_args,
					},
				})
			end
			vim.list_extend(dap.configurations.c, {
				{
					name = "Launch file",
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
			})
			dap.configurations.cpp = dap.configurations.c
			dap.configurations.rust = dap.configurations.c
		end,
	},
}
