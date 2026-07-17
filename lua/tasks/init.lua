local overseer = require("overseer")
local dap = require("dap")

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

---@type { task: Task, metadata: TaskMetadata }
local last_overseer_task = nil
---@type { task: Task, metadata: TaskMetadata }|{ regular_dap: true }
local last_dap_task = nil

---@param task Task
---@param metadata TaskMetadata
local function run_overseer_task(task, metadata)
	local function start_main_and_post_tasks()
		local main_task = overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, {
			name = task.name,
			cmd = task.cmd(metadata),
		}))
		if task.post_run_cmd then
			main_task:subscribe("on_complete", function(_, status)
				local post_task = overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, {
					name = "Post: " .. task.name,
					cmd = task.post_run_cmd(metadata, status),
				}))
				post_task:start()
			end)
		end
		main_task:start()
	end

	if task.pre_run_cmd then
		local pre_task = overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, {
			name = "Pre: " .. task.name,
			cmd = task.pre_run_cmd(metadata),
		}))
		pre_task:subscribe("on_complete", function(_, pre_status)
			if pre_status ~= "SUCCESS" then
				vim.notify("The task 'Pre: " .. task.name .. "' failed", vim.log.levels.ERROR)
				return
			end
			start_main_and_post_tasks()
		end)
		pre_task:start()
	else
		start_main_and_post_tasks()
	end
end

---@param task Task
---@param metadata TaskMetadata
local function run_dap_task(task, metadata)
	local function start_main_and_post_tasks()
		local cmd = task.cmd(metadata)
		local config = vim.tbl_deep_extend("force", task.dap.options, {
			name = task.name,
			program = cmd[1],
			args = vim.list_slice(cmd, 2),
		})

		local time_start = os.time()
		local listener_key = "tasks.dap_complete." .. task.name .. "." .. tostring(time_start)
		local repl_output = {}
		local function on_dap_complete(_, body)
			dap.listeners.after.event_terminated[listener_key] = nil
			dap.listeners.after.event_output[listener_key] = nil

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
				name = "DAP Output: " .. task.name,
				cmd = task.name,
			}))
			repl_task.status = "SUCCESS"
			repl_task.time_start = time_start
			repl_task.time_end = os.time()
			repl_task.metadata.raw_output = output

			local bufnr = vim.api.nvim_create_buf(false, true)
			local term_id = vim.api.nvim_open_term(bufnr, {})
			vim.bo[bufnr].scrollback = 99999
			pcall(vim.api.nvim_chan_send, term_id, repl_task.metadata.raw_output)
			vim.bo[bufnr].filetype = "OverseerOutput"
			vim.b[bufnr].overseer_task = repl_task.id
			repl_task.strategy.bufnr = bufnr
			repl_task.strategy.term_id = term_id

			if task.post_run_cmd then
				local status = body and body.exitCode and tostring(body.exitCode) or nil
				local post_task = overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, {
					name = "Post: " .. task.name,
					cmd = task.post_run_cmd(metadata, status),
				}))
				post_task:start()
			end
		end
		dap.listeners.after.event_terminated[listener_key] = on_dap_complete
		dap.listeners.after.event_output[listener_key] = function(_, body)
			if body and body.category ~= "telemetry" and body.output and body.output ~= "" then
				table.insert(repl_output, body.output)
			end
		end

		dap.run(config)
	end

	if task.pre_run_cmd then
		local pre_task = overseer.new_task(vim.tbl_deep_extend("force", task.overseer.options, {
			name = "Pre: " .. task.name,
			cmd = task.pre_run_cmd(metadata),
		}))
		pre_task:subscribe("on_complete", function(_, pre_status)
			if pre_status ~= "SUCCESS" then
				vim.notify("The task 'Pre: " .. task.name .. "' failed", vim.log.levels.ERROR)
				return
			end
			start_main_and_post_tasks()
		end)
		pre_task:start()
	else
		start_main_and_post_tasks()
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
					local metadata = task.resolve_metadata and task.resolve_metadata() or {}
					if not metadata then
						vim.notify(
							"The task '" .. task.name .. "' was cancelled or failed while resolving metadata",
							vim.log.levels.ERROR
						)
						return
					end
					metadata.is_overseer_task = true
					last_overseer_task = { task = task, metadata = metadata }
					run_overseer_task(task, metadata)
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
					local metadata = task.resolve_metadata and task.resolve_metadata() or {}
					if not metadata then
						vim.notify(
							"The task '" .. task.name .. "' was cancelled or failed while resolving metadata",
							vim.log.levels.ERROR
						)
						return
					end
					metadata.is_dap_task = true
					last_dap_task = { task = task, metadata = metadata }
					run_dap_task(task, metadata)
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
		Snacks.picker.select(items, {
			prompt = "Select task",
			format_item = function(item)
				if item.desc then
					return string.format("%s (%s)", item.name, item.desc)
				end
				return item.name
			end,
			snacks = {
				-- Disable multi-selection
				win = {
					input = {
						keys = {
							["<Tab>"] = false,
							["<S-Tab>"] = false,
							["<c-a>"] = false,
						},
					},
					list = {
						keys = {
							["<Tab>"] = false,
							["<S-Tab>"] = false,
							["<c-a>"] = false,
						},
					},
				},
			},
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

	Snacks.picker.select(items, {
		prompt = "Select debugging task",
		format_item = function(item)
			return item.name
		end,
		snacks = {
			-- Disable multi-selection
			win = {
				input = {
					keys = {
						["<Tab>"] = false,
						["<S-Tab>"] = false,
						["<c-a>"] = false,
					},
				},
				list = {
					keys = {
						["<Tab>"] = false,
						["<S-Tab>"] = false,
						["<c-a>"] = false,
					},
				},
			},
		},
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
		run_overseer_task(last_overseer_task.task, last_overseer_task.metadata)
	else
		vim.notify("No task has been run.", vim.log.levels.WARN)
	end
end

M.run_last_dap_task = function()
	if last_dap_task then
		if last_dap_task.regular_dap then
			dap.run_last()
		else
			run_dap_task(last_dap_task.task, last_dap_task.metadata)
		end
	else
		vim.notify("No debugging task has been run.", vim.log.levels.WARN)
	end
end

return M
