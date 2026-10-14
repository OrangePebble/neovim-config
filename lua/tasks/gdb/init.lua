---@type Task[]
local M = {
	{
		name = "Run file",
		dap = {
			enabled = true,
			options = {
				type = "gdb",
			},
		},
		first_run_pre = function(context)
			local file_path = require("utils.picker").pick_file(vim.fn.getcwd(), nil)
			if not file_path then
				context.failed = true
				return
			end

			local cmd = { file_path }
			local co = coroutine.running()
			Snacks.input({ prompt = "Args:" }, function(value)
				coroutine.resume(co, value)
			end)
			vim.list_extend(cmd, vim.split(coroutine.yield() or "", " +", { trimempty = true }))
			context.cmd = cmd
		end,
		run_main = function(context)
			return context.cmd
		end,
	},
	{
		name = "Select and attach to process",
		overseer = {
			enabled = false,
		},
		dap = {
			enabled = true,
			options = {
				type = "gdb",
				request = "attach",
				pid = function()
					return coroutine.create(function(dap_co)
						Snacks.input({ prompt = "Executable name (filter):" }, function(value)
							coroutine.resume(dap_co, require("dap.utils").pick_process({ filter = value or "" }))
						end)
						return coroutine.yield()
					end)
				end,
			},
		},
		first_run_pre = function(context)
			local file_path = require("utils.picker").pick_file(vim.fn.getcwd(), nil)
			if not file_path then
				context.failed = true
				return
			end
			context.cmd = { file_path }
		end,
		run_main = function(context)
			return context.cmd
		end,
	},
	{
		name = "Attach to gdbserver :1234",
		overseer = {
			enabled = false,
		},
		dap = {
			enabled = true,
			options = {
				type = "gdb",
				request = "attach",
				target = "localhost:1234",
			},
		},
		first_run_pre = function(context)
			local file_path = require("utils.picker").pick_file(vim.fn.getcwd(), nil)
			if not file_path then
				context.failed = true
				return
			end
			context.cmd = { file_path }
		end,
		run_main = function(context)
			return context.cmd
		end,
	},
}

return M
