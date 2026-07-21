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
		resolve_context = function()
			local file_path = require("utils.picker").pick_file(vim.fn.getcwd(), nil)
			if not file_path then
				return nil
			end
			local cmd = { file_path }
			local co = coroutine.running()
			Snacks.input({ prompt = "Args:" }, function(value)
				coroutine.resume(co, value)
			end)
			vim.list_extend(cmd, vim.split(coroutine.yield() or "", " +", { trimempty = true }))
			return { cmd = cmd }
		end,
		cmd = function(context)
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
		resolve_context = function()
			local file_path = require("utils.picker").pick_file(vim.fn.getcwd(), nil)
			if not file_path then
				return nil
			end
			local cmd = { file_path }
			return { cmd = cmd }
		end,
		cmd = function(context)
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
		resolve_context = function()
			local file_path = require("utils.picker").pick_file(vim.fn.getcwd(), nil)
			if not file_path then
				return nil
			end
			local cmd = { file_path }
			return { cmd = cmd }
		end,
		cmd = function(context)
			return context.cmd
		end,
	},
}

return M
