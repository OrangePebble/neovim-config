local overseer = require("overseer")
local dap = require("dap")
local picker = require("utils.picker")

---@type Task[]
local tasks = {}
local task_defaults = require("tasks.task_defaults")
local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

-- Get tasks that are chosen when Neovim first opens.
---@return Task[]
local function get_initial_tasks()
	local t = {}
	-- Allow for alternative directory names for cases where I may want a 2nd version for some reason.
	if string.match(cwd_name, ".*ddad.*") or string.match(cwd_name, ".*env_simulator.*") then
		vim.list_extend(t, require("tasks.env_simulator"))
	end
	if string.match(cwd_name, ".*gt%-gen%-core.*") then
		vim.list_extend(t, require("tasks.gt_gen_core"))
	end
	if string.match(cwd_name, ".*openscenario1_engine.*") then
		vim.list_extend(t, require("tasks.open_scenario_engine"))
	end
	if string.match(cwd_name, ".*mantle%-api.*") then
		vim.list_extend(t, require("tasks.mantle_api"))
	end
	return t
end
vim.list_extend(tasks, get_initial_tasks())

-- Get tasks that are chosen whenever a choose_* function below is run.
---@return Task[]
local function get_runtime_tasks()
	local t = {}
	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.b[bufnr]["dap-srcft"] or vim.bo[bufnr].filetype
	if
		string.match(cwd_name, ".*ddad.*")
		or string.match(cwd_name, ".*env_simulator.*")
		or filetype == "c"
		or filetype == "cpp"
		or filetype == "rust"
	then
		vim.list_extend(t, require("tasks.gdb"))
	end
	return t
end

---@type { name: string, run: fun() }[]
local overseer_tasks = {}
---@type { name: string, run: fun() }[]
local dap_tasks = {}

---@type { task: Task, context: TaskContext }
local last_overseer_task = nil
---@type { task: Task, context: TaskContext }|{ regular_dap: true }
local last_dap_task = nil

---@param name string
---@param task_type "overseer"|"dap"
---@return Task|nil
local function find_task(name, task_type)
	for _, task_set in ipairs({ tasks, get_runtime_tasks() }) do
		for _, task in ipairs(task_set) do
			task = vim.tbl_deep_extend("keep", task, task_defaults)
			if task.name == name and task[task_type] and task[task_type].enabled then
				return task
			end
		end
	end
end

---@param task Task
---@param context TaskContext
---@param first_run? boolean
local function run_task(task, context, first_run)
	local first_run_pre_overseer_tasks
	local run_pre_overseer_tasks
	local run_post_overseer_tasks
	context.failed = nil -- I need to reset this because it may have been set to true in a previous run.
	if first_run then
		if task.first_run_pre then
			first_run_pre_overseer_tasks = task.first_run_pre(context)
		end
		if context.failed then
			vim.notify(
				"The task '" .. task.name .. "' was cancelled or failed while resolving context",
				vim.log.levels.ERROR
			)
			return
		end
		if context.is_overseer then
			last_overseer_task = { task = task, context = context }
			vim.g.last_overseer_task = { task_name = task.name, context = context }
		elseif context.is_dap then
			last_dap_task = { task = task, context = context }
			vim.g.last_dap_task = { task_name = task.name, context = context }
		else
			vim.notify(
				"The task '" .. task.name .. "' did not set if it was an Overseer or DAP task",
				vim.log.levels.ERROR
			)
			return
		end
	end
	local main_name = task.name
	if context.main_name then
		main_name = context.main_name
	end
	if task.run_pre then
		run_pre_overseer_tasks = task.run_pre(context)
	end
	if context.failed then
		vim.notify("The `pre` step of the task " .. main_name .. "' failed", vim.log.levels.ERROR)
		return
	end
	local main_cmd = task.run_main(context)
	if context.failed then
		vim.notify("The cmd building step of the task " .. main_name .. "' failed", vim.log.levels.ERROR)
		return
	end
	if context.is_overseer then
		context.main_run_overseer =
			overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, { name = main_name, cmd = main_cmd }))
		local co = coroutine.running()
		context.main_run_overseer:subscribe("on_complete", function()
			coroutine.resume(co)
		end)
		context.main_run_overseer:start()
		coroutine.yield()
	else
		local config = vim.tbl_deep_extend("force", task.dap.options, {
			name = main_name,
			program = main_cmd[1],
			args = vim.list_slice(main_cmd, 2),
		})
		local time_start = os.time()
		local listener_key = "tasks.dap_complete." .. main_name .. "." .. tostring(time_start)
		local repl_output = {}
		local exit_code = nil
		local was_canceled = false
		local co = coroutine.running()
		dap.listeners.after.event_terminated[listener_key] = function()
			dap.listeners.before.terminate[listener_key] = nil
			dap.listeners.before.disconnect[listener_key] = nil
			dap.listeners.after.event_terminated[listener_key] = nil
			dap.listeners.after.event_exited[listener_key] = nil
			dap.listeners.after.event_output[listener_key] = nil

			---@type overseer.Status
			local status
			if was_canceled then
				status = "CANCELED"
			elseif exit_code == 0 then
				status = "SUCCESS"
			else
				status = "FAILURE"
			end

			local lines = {}
			local repl_buffer_found = false
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "dap-repl" then
					lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
					repl_buffer_found = true
					break
				end
			end

			local output = repl_buffer_found and table.concat(lines, "\n") or table.concat(repl_output)

			local repl_task = overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, {
				name = "DAP Output: " .. main_name,
				cmd = main_cmd,
			}))
			repl_task.status = status
			repl_task.exit_code = exit_code
			repl_task.time_start = time_start
			repl_task.time_end = os.time()
			repl_task.metadata.raw_output = output
			context.main_run_overseer = repl_task

			local bufnr = vim.api.nvim_create_buf(false, true)
			local term_id = vim.api.nvim_open_term(bufnr, {})
			vim.bo[bufnr].scrollback = 99999
			pcall(vim.api.nvim_chan_send, term_id, repl_task.metadata.raw_output)
			vim.bo[bufnr].filetype = "OverseerOutput"
			vim.b[bufnr].overseer_task = repl_task.id
			---@diagnostic disable-next-line: invisible, inject-field
			repl_task.strategy.bufnr = bufnr
			---@diagnostic disable-next-line: invisible, inject-field
			repl_task.strategy.term_id = term_id

			coroutine.resume(co)
		end
		dap.listeners.before.terminate[listener_key] = function()
			was_canceled = true
		end
		dap.listeners.before.disconnect[listener_key] = function()
			was_canceled = true
		end
		dap.listeners.after.event_exited[listener_key] = function(_, body)
			exit_code = body and body.exitCode or nil
		end
		dap.listeners.after.event_output[listener_key] = function(_, body)
			if body and body.category ~= "telemetry" and body.output and body.output ~= "" then
				table.insert(repl_output, body.output)
			end
		end
		dap.run(config)
		coroutine.yield()
	end
	for _, overseer_task in ipairs(first_run_pre_overseer_tasks or {}) do
		overseer_task.parent_id = context.main_run_overseer.id
	end
	for _, overseer_task in ipairs(run_pre_overseer_tasks or {}) do
		overseer_task.parent_id = context.main_run_overseer.id
	end
	if task.run_post then
		run_post_overseer_tasks = task.run_post(context)
	end
	for _, overseer_task in ipairs(run_post_overseer_tasks or {}) do
		overseer_task.parent_id = context.main_run_overseer.id
	end
	if context.failed then
		vim.notify("The `post` step of the task " .. main_name .. "' failed", vim.log.levels.ERROR)
		return
	end
end

---@param generic_tasks Task[]
---@return { name: string, run: fun() }[]
local function generic_to_overseer_tasks(generic_tasks)
	local local_overseer_tasks = {}
	for i = 1, #generic_tasks do
		generic_tasks[i] = vim.tbl_deep_extend("keep", generic_tasks[i], task_defaults)
		local task = generic_tasks[i]

		if task.overseer.enabled then
			table.insert(local_overseer_tasks, {
				name = task.name,
				run = function()
					run_task(task, { is_overseer = true }, true)
				end,
			})
		end
	end
	return local_overseer_tasks
end
vim.list_extend(overseer_tasks, generic_to_overseer_tasks(get_initial_tasks()))

---@param generic_tasks Task[]
---@return { name: string, run: fun() }[]
local function generic_to_dap_tasks(generic_tasks)
	local local_dap_tasks = {}
	for i = 1, #generic_tasks do
		generic_tasks[i] = vim.tbl_deep_extend("keep", generic_tasks[i], task_defaults)
		local task = generic_tasks[i]

		if task.dap.enabled then
			table.insert(local_dap_tasks, {
				name = task.name,
				run = function()
					run_task(task, { is_dap = true }, true)
				end,
			})
		end
	end
	return local_dap_tasks
end
vim.list_extend(dap_tasks, generic_to_dap_tasks(get_initial_tasks()))

local M = {}

-- Custom Overseer template runner so that I can use pickers with callbacks to customize the tasks.
-- Because overseer templates are syncronous and run in a C-call, I couldn't figure out how to turn
--  the callback-based picker syncronous. I tried using coroutines but those can't be used in a
--  C-call, so this is the best solution I thought of.
M.choose_and_run_overseer_task = function()
	local items = vim.deepcopy(overseer_tasks)
	vim.list_extend(items, generic_to_overseer_tasks(get_runtime_tasks()))

	local overseer_template = require("overseer.template")
	local search = {
		dir = vim.fn.getcwd(),
		filetype = vim.bo.filetype,
	}
	overseer_template.list(search, function(templates)
		vim.list_extend(
			items,
			vim.tbl_map(
				function(template)
					return {
						name = template.name,
						desc = template.desc,
						run = function()
							overseer_template.build_task(template, {
								params = {},
								search = search,
							}, function(err, task)
								if err then
									vim.notify(err, vim.log.levels.ERROR)
									return
								end
								if task then
									task:start()
								end
							end)
						end,
					}
				end,
				vim.tbl_filter(function(tmpl)
					return not tmpl.hide
				end, templates)
			)
		)
		if vim.tbl_isempty(items) then
			vim.notify("No tasks found.", vim.log.levels.WARN)
			return
		end
		picker.select_one(items, {
			prompt = "Select task",
			format_item = function(item)
				if item.desc then
					return string.format("%s (%s)", item.name, item.desc)
				end
				return item.name
			end,
		}, function(item)
			if item then
				local co = coroutine.create(item.run)
				local ok, err = coroutine.resume(co)
				if not ok then
					vim.notify(err, vim.log.levels.ERROR)
				end
			end
		end)
	end)
end

M.choose_and_run_dap_task = function()
	local items = vim.deepcopy(dap_tasks)
	vim.list_extend(items, generic_to_dap_tasks(get_runtime_tasks()))

	local seen_configurations = {}
	local seen_item_names = {}
	for _, item in ipairs(items) do
		seen_item_names[item.name] = true
	end
	local function add_configurations(configurations)
		for _, configuration in ipairs(configurations or {}) do
			if not seen_configurations[configuration] and not seen_item_names[configuration.name] then
				seen_configurations[configuration] = true
				seen_item_names[configuration.name] = true
				table.insert(items, {
					name = configuration.name,
					run = function()
						local listener_key = "tasks.regular_dap." .. configuration.name
						local function clear_regular_dap_listeners()
							dap.listeners.after.event_initialized[listener_key] = nil
							dap.listeners.after.event_terminated[listener_key] = nil
						end
						dap.listeners.after.event_initialized[listener_key] = function()
							clear_regular_dap_listeners()
							last_dap_task = { regular_dap = true }
							vim.g.last_dap_task = {
								regular_dap = true,
								name = configuration.name,
							}
						end
						dap.listeners.after.event_terminated[listener_key] = clear_regular_dap_listeners
						dap.run(configuration)
					end,
				})
			end
		end
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.b[bufnr]["dap-srcft"] or vim.bo[bufnr].filetype
	add_configurations(dap.configurations[filetype])
	for _, provider in pairs(dap.providers.configs or {}) do
		add_configurations(provider(bufnr))
	end

	if vim.tbl_isempty(items) then
		vim.notify("No debugging tasks found.", vim.log.levels.WARN)
		return
	end

	picker.select_one(items, {
		prompt = "Select debugging task",
		format_item = function(item)
			return item.name
		end,
	}, function(item)
		if item then
			local co = coroutine.create(item.run)
			local ok, err = coroutine.resume(co)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		end
	end)
end

M.run_last_overseer_task = function()
	if last_overseer_task then
		local co = coroutine.create(function()
			run_task(last_overseer_task.task, last_overseer_task.context)
		end)
		local ok, err = coroutine.resume(co)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
		end
	elseif vim.g.last_overseer_task then
		local saved = vim.g.last_overseer_task
		local task = find_task(saved.task_name, "overseer")
		if task then
			local co = coroutine.create(function()
				run_task(task, saved.context)
			end)
			local ok, err = coroutine.resume(co)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		else
			vim.notify("Saved Overseer task is no longer available.", vim.log.levels.WARN)
		end
	else
		local task = overseer.list_tasks({
			sort = require("overseer.task_list").sort_finished_recently,
		})[1]
		if task then
			task:clone():start()
		else
			vim.notify("No tasks found.", vim.log.levels.WARN)
		end
	end
end

M.run_last_dap_task = function()
	if last_dap_task then
		if last_dap_task.regular_dap then
			dap.run_last()
		else
			local co = coroutine.create(function()
				run_task(last_dap_task.task, last_dap_task.context)
			end)
			local ok, err = coroutine.resume(co)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		end
	elseif vim.g.last_dap_task then
		local saved = vim.g.last_dap_task
		local task = find_task(saved.task_name, "dap")
		if task then
			local co = coroutine.create(function()
				run_task(task, saved.context)
			end)
			local ok, err = coroutine.resume(co)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		else
			vim.notify("Saved debugging task is no longer available.", vim.log.levels.WARN)
		end
	else
		vim.notify("No debugging tasks found.", vim.log.levels.WARN)
	end
end

M.init_shell_task_command = function()
	vim.api.nvim_create_user_command("ShellTask", function(args)
		local task = vim.tbl_deep_extend("keep", {
			name = args.args,
			run_main = function()
				return args.args
			end,
			overseer = {
				options = {
					ephemeral = false,
				},
			},
		}, task_defaults)
		if not args.bang then
			local co = coroutine.create(function()
				run_task(task, { is_overseer = true }, true)
			end)
			local ok, err = coroutine.resume(co)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		end
	end, {
		bang = true,
		complete = "shellcmdline",
		desc = "Run a shell command as a task",
		nargs = "+",
	})
end
M.init_shell_task_command()

return M
