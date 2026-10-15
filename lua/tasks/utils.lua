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
	}))

	task:subscribe("on_complete", function()
		coroutine.resume(co)
	end)
	task:start()
	coroutine.yield()

	local succeeded = task.status == "SUCCESS"
	progress.title = succeeded and succ_msg or fail_msg
	progress:finish()
	if not succeeded then
		vim.notify("FAILURE " .. task.name, vim.log.levels.ERROR)
	end

	-- We get plain text output without special terminal characters by reading the buffer.
	-- We could get this directly from Overseer but that would require the OverseerResult buffer
	--  not have terminal features like redrawing and colors.
	local output = ""
	local output_bufnr = task:get_bufnr()
	if output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr) and task.exit_code ~= nil then
		local exit_marker = "[Process exited " .. task.exit_code .. "]"
		local lines
		-- We check if the line added by Overseer at the end exists a couple of times because buffer
		--  drawing is async and the contents might not be up to date yet.
		vim.wait(1000, function()
			lines = vim.api.nvim_buf_get_lines(output_bufnr, 0, -1, false)
			return vim.tbl_contains(lines, exit_marker)
		end, 10)
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
