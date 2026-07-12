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
					title = title or "Path to file",
					ignored = true,
					hidden = true,
					layout = { hidden = { "preview" } },
					confirm = function(picker, item)
						selected = item and item.file or nil
						picker:close()
					end,
					on_close = function()
						if co then
							coroutine.resume(co)
						end
					end,
				})
				if co then
					coroutine.yield()
				end
				if selected == nil then
					return nil
				end
				return path .. selected
			end
			local default_program = cached("program", function()
				return pick_executable(vim.fn.getcwd(), nil) or dap.ABORT
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
			-- See available options at: https://sourceware.org/gdb/current/onlinedocs/gdb.html/Debugger-Adapter-Protocol.html
			local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
			-- Not also accepting "env_simulator" because breakpoints don't work there
			local is_ddad_workspace = string.match(cwd_name, "ddad")
			if is_ddad_workspace then
				local ddad_path = vim.fn.getcwd()
				vim.list_extend(dap.configurations.c, {
					{
						name = "Run SCMHighway E2E test",
						type = "gdb",
						request = "launch",
						cwd = "${workspaceFolder}",
						program = cached("program", function()
							return ddad_path .. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli"
						end),
						args = cached("args", function()
							local co = coroutine.running()

							-- Pick a configuration directory
							local configs_path = ddad_path
								.. "/tools/env_simulator/ASTAS_DATA/E2EOpTestArtifacts/SCMHighway/Resources/Configurations/"
							local dirs = {}
							for name, type in vim.fs.dir(configs_path) do
								if type == "directory" then
									table.insert(dirs, name)
								end
							end
							table.sort(dirs)
							Snacks.picker.select(dirs, {
								title = "Select configuration directory",
							}, function(value)
								if co then
									coroutine.resume(co, value)
								end
							end)
							local selected_test = coroutine.yield()
							if selected_test == nil then
								return dap.ABORT
							end
							local selected_test_path = configs_path .. selected_test
							local common_resources_path = ddad_path
								.. "/tools/env_simulator/ExampleData/E2EOpTestArtifacts/SCMHighway/Resources/Common"
							local output_path = vim.fn.expand("~")
								.. "/simulation_outputs/"
								.. selected_test
								.. "/"
								.. string.format("%s-%03d", os.date("%y-%m-%d-%H-%M-%S"), vim.uv.hrtime() / 1e6 % 1000)

							local tmp_file_path = vim.fn.tempname()
							vim.fn.writefile({
								string.format(
									"cp %s/MiscObjects %s -r --remove-destination",
									common_resources_path,
									selected_test_path
								),
								string.format(
									"cp %s/UserSettings %s -r --remove-destination",
									common_resources_path,
									selected_test_path
								),
								string.format(
									"cp %s/Vehicles %s -r --remove-destination",
									common_resources_path,
									selected_test_path
								),
								string.format(
									"cp %s/systemConfigBlueprint.xml %s -r --remove-destination",
									common_resources_path,
									selected_test_path
								),
								string.format(
									"cp %s/ProfilesCatalog.xml %s -r --remove-destination",
									common_resources_path,
									selected_test_path
								),
								string.format(
									'sed -i "s|Plugins = {/path/to/update}|Plugins = {/opt/astas_core/plugins, %s/bazel-bin/external/gecco_default/src/controller}|" "%s/UserSettings/UserSettings.ini"',
									ddad_path,
									selected_test_path
								),
								"mkdir -p " .. output_path,
								string.format(
									'sed -i "s|OutputDirectoryPath = /path/to/update|OutputDirectoryPath = %s|" "%s/UserSettings/UserSettings.ini"',
									output_path,
									selected_test_path
								),
								string.format(
									'sed -i "s|"/path/to/update"|"%s"|" "%s/Scenarios/XOSC/Scenario.xosc"',
									selected_test_path,
									selected_test_path
								),
								"bazel build --config=env_simulator_debug --override_repository=osi_query_library=/home/pedro/projects/osi-query-library //tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip",
								string.format(
									'cp "%s/bazel-bin/tools/env_simulator/modules/stochastic_cognitive_model/AlgorithmScm.fmu" "%s"',
									ddad_path,
									selected_test_path
								),
							}, tmp_file_path)

							-- Run pre-launch commands
							local overseer = require("overseer")
							local task = overseer.new_task({
								name = "Preparing SCMHighway's " .. selected_test .. " E2E test",
								ephemeral = true,
								cmd = { "bash", tmp_file_path },
								components = {
									{ "on_exit_set_status" },
								},
							})
							task:subscribe("on_complete", function(_, status)
								coroutine.resume(co, status)
							end)
							task:start()
							local status = coroutine.yield()
							if status ~= "SUCCESS" then
								return dap.ABORT
							end

							local args = string.format(
								"-t 100 -s %s -d %s -p %s -l %s -n 1 -r 0 -o %s",
								selected_test_path .. "/Scenarios/XOSC/Scenario.xosc",
								selected_test_path,
								output_path,
								output_path,
								output_path .. "/output.mcap"
							)
							vim.notify(
								"Debugging: "
									.. ddad_path
									.. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli "
									.. args,
								vim.log.levels.INFO
							)
							return args
						end),
					},
					{
						name = "Run astas_cli",
						type = "gdb",
						request = "launch",
						cwd = "${workspaceFolder}",
						program = cached("program", function()
							return ddad_path .. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli"
						end),
						args = default_args,
					},
					{
						name = "Run file in ./bazel-bin",
						type = "gdb",
						request = "launch",
						cwd = "${workspaceFolder}",
						program = cached("program", function()
							return pick_executable(ddad_path .. "/bazel-bin", "Path to file (./bazel-bin)") or dap.ABORT
						end),
						args = default_args,
					},
				})
			end
			vim.list_extend(dap.configurations.c, {
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
			})
			dap.configurations.cpp = dap.configurations.c
			dap.configurations.rust = dap.configurations.c
			dap.providers.configs["ddad.gdb"] = function(bufnr)
				if not is_ddad_workspace then
					return {}
				end
				-- "dap-srcft" is for overrides that dap may do so filetypes use configurations of another filetype
				-- Without this we may duplicate configurations.
				local filetype = vim.b[bufnr]["dap-srcft"] or vim.bo[bufnr].filetype
				local configurations = dap.configurations[filetype]
				if configurations ~= nil and #configurations > 0 then
					return {}
				end
				return dap.configurations.c
			end
		end,
	},
}
