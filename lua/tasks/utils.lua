local M = {}

-- Bazel flags that strip visual fluff, and make the output more suitable for parsing.
M.bazel_output_args = {
	"--color=no",
	"--curses=no",
	"--noshow_progress",
	"--noshow_loading_progress",
	"--noprogress_in_terminal_title",
}

function M.input_args()
	local co = coroutine.running()
	Snacks.input({
		prompt = "Args:",
		win = {
			keys = {
				-- Cancel on first <Esc>
				i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
			},
		},
	}, function(value)
		coroutine.resume(co, value)
	end)
	return vim.split(coroutine.yield() or "", " +", { trimempty = true })
end

---@param cmd string[]
---@param cwd string
---@param category string
---@param title string
---@return { task: overseer.Task, output: string|nil }
function M.run_command(cmd, cwd, category, title)
	local co = coroutine.running()
	local overseer = require("overseer")
	local task_defaults = require("tasks.task_defaults")
	local progress = require("fidget.progress").handle.create({
		title = title,
		lsp_client = { name = category },
		message = "",
	})
	local task = overseer.new_task(vim.tbl_deep_extend("force", task_defaults.overseer.options, {
		cmd = cmd,
		cwd = cwd,
		-- The regular output buffer preserves long lines and strips common ANSI escape sequences.
		strategy = { "jobstart", use_terminal = false },
		components = { "capture_raw_output", "on_exit_set_status" },
	}))

	task:subscribe("on_complete", function()
		coroutine.resume(co)
	end)
	task:start()
	coroutine.yield()

	local succeeded = task.status == "SUCCESS"
	progress.message = succeeded and "Completed" or "Failed"
	progress:finish()
	if not succeeded then
		vim.notify("FAILURE " .. task.name, vim.log.levels.ERROR)
	end

	local output = ""
	local output_bufnr = task:get_bufnr()
	if output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr) and task.exit_code ~= nil then
		local exit_marker = "[Process exited " .. task.exit_code .. "]"
		local lines = vim.api.nvim_buf_get_lines(output_bufnr, 0, -1, false)
		for i = #lines, 1, -1 do
			if lines[i] == exit_marker then
				table.remove(lines, i)
				break
			end
		end
		output = table.concat(lines, "\n")
	end

	return { task = task, output = output }
end

---@param args string[]
---@param cwd string
---@return { task: overseer.Task, output: string|nil }
function M.run_bazel_query(args, cwd)
	local cmd = vim.list_extend({ "bazel", "query" }, M.bazel_output_args)
	vim.list_extend(cmd, args)
	return M.run_command(cmd, cwd, "Bazel", "Querying")
end
---@param args string[]
---@param cwd string
---@return { task: overseer.Task, output: string|nil }
function M.run_bazel_cquery(args, cwd)
	local cmd = vim.list_extend({ "bazel", "cquery" }, M.bazel_output_args)
	vim.list_extend(cmd, args)
	return M.run_command(cmd, cwd, "Bazel", "Running configurable query")
end
---@param args string[]
---@param cwd string
---@return { task: overseer.Task, output: string|nil }
function M.run_bazel_build(args, cwd)
	local cmd = vim.list_extend({ "bazel", "build" }, M.bazel_output_args)
	vim.list_extend(cmd, args)
	return M.run_command(cmd, cwd, "Bazel", "Building")
end

return M
