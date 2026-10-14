local M = {}

---@param co thread
function M.input_args(co)
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
---@param co thread
---@param category string
---@param prog_msg string
---@param succ_msg string
---@param fail_msg string
---@return { task: overseer.Task, output: string|nil }
function M.run_command(cmd, cwd, co, category, prog_msg, succ_msg, fail_msg)
	local overseer = require("overseer")
	local task_defaults = require("tasks.task_defaults")
	local output_chunks = {}
	local progress = require("fidget.progress").handle.create({
		title = prog_msg,
		lsp_client = { name = category },
		message = table.concat(cmd, " "),
		percentage = 0,
	})
	local task = overseer.new_task(vim.tbl_deep_extend("force", task_defaults.overseer.options, {
		cmd = cmd,
		cwd = cwd,
		components = { "capture_raw_output", "on_exit_set_status" },
		-- `metadata.raw_output` contains ANSI and other terminal characters, so we use this for clean output.
		strategy = {
			"system",
			wrap_opts = {
				text = true,
				stdout = function(_, data)
					if data then
						table.insert(output_chunks, data)
					end
				end,
				stderr = function(_, data)
					if data then
						table.insert(output_chunks, data)
					end
				end,
			},
		},
	}))

	task:subscribe("on_complete", function()
		coroutine.resume(co)
	end)
	task:start()
	coroutine.yield()

	local succeeded = task.status == "SUCCESS"
	progress.title = succeeded and succ_msg or fail_msg
	progress:finish()
	local output = table.concat(output_chunks)
	if not succeeded then
		local trimmed_output = vim.trim(output or "")
		vim.notify(trimmed_output ~= "" and trimmed_output or category .. ": " .. fail_msg, vim.log.levels.ERROR)
	end

	return { task = task, output = output }
end

---@param args string[]
---@param cwd string
---@param co thread
---@return { task: overseer.Task, output: string|nil }
function M.run_bazel_query(args, cwd, co)
	return M.run_command(
		vim.list_extend({ "bazel", "query" }, args),
		cwd,
		co,
		"Bazel",
		"Running query",
		"Query finished",
		"Query failed"
	)
end
---@param args string[]
---@param cwd string
---@param co thread
---@return { task: overseer.Task, output: string|nil }
function M.run_bazel_cquery(args, cwd, co)
	return M.run_command(
		vim.list_extend({ "bazel", "cquery" }, args),
		cwd,
		co,
		"Bazel",
		"Running configurable query",
		"Configurable query finished",
		"Configurable query failed"
	)
end
---@param args string[]
---@param cwd string
---@param co thread
---@return { task: overseer.Task, output: string|nil }
function M.run_bazel_build(args, cwd, co)
	return M.run_command(
		vim.list_extend({ "bazel", "build" }, args),
		cwd,
		co,
		"Bazel",
		"Building",
		"Build finished",
		"Build failed"
	)
end

return M
