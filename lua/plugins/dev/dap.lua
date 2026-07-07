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
			-- Cache for last-used program/args/address so run_last reuses them.
			local _cache = {}

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
			local function dap_reset_cache()
				_cache = {}
			end
			vim.api.nvim_create_user_command("DapResetCache", dap_reset_cache, { desc = "Reset DAP selection cache" })

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
			require("mason-nvim-dap").setup({
				-- Makes a best effort to setup the various debuggers with reasonable debug configurations
				automatic_installation = true,
				-- Additional handler configuration.
				handlers = {
					function(config)
						-- all sources with no handler get passed here
						-- Keep original functionality
						require("mason-nvim-dap").default_setup(config)
					end,
					cppdbg = function(config)
						-- Taken from https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/configurations.lua
						--  and modified.
						local program_func = cached("program", function()
							local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
							if string.match(cwd_name, "ddad") then
								return pick_executable(
									vim.fn.getcwd() .. "/bazel-bin",
									"Path to executable (/bazel-bin)"
								)
							else
								return pick_executable(vim.fn.getcwd(), nil)
							end
						end)
						local args_func = cached("args", function()
							return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
						end)
						config.configurations = {
							{
								name = "Launch file",
								type = "cppdbg",
								request = "launch",
								cwd = "${workspaceFolder}",
								stopAtEntry = true,
								program = program_func,
							},
							{
								name = "Launch file (args)",
								type = "cppdbg",
								request = "launch",
								cwd = "${workspaceFolder}",
								stopAtEntry = true,
								program = program_func,
								args = args_func,
							},
							{
								name = "Attach to gdbserver :1234",
								type = "cppdbg",
								request = "launch",
								MIMode = "gdb",
								miDebuggerServerAddress = "localhost:1234",
								miDebuggerPath = vim.fn.exepath("gdb"),
								cwd = "${workspaceFolder}",
								program = program_func,
							},
							{
								name = "Attach to gdbserver (port)",
								type = "cppdbg",
								request = "launch",
								MIMode = "gdb",
								miDebuggerServerAddress = cached("gdbserver_addr", function()
									local uri = vim.fn.input("[host]:port : ")
									if uri:find("^%d+$") == 1 then
										uri = "localhost:" .. uri
									elseif uri:find(":", nil, true) == 1 then
										uri = "localhost" .. uri
									end
									return uri
								end),
								miDebuggerPath = vim.fn.exepath("gdb"),
								cwd = "${workspaceFolder}",
								program = program_func,
								args = args_func,
							},
						}
						require("mason-nvim-dap").default_setup(config) -- don't forget this!
					end,
				},
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
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
}
