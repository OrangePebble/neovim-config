-- Plugin to save Neovim sessions.

-- Saves the overseer task metadata and output.
-- WARN: These changes use internal/private/new fields that aren't supposed to be used so there are
-- some warnings. I could add ignores to each line but I think it looks worse than the underlines.
local function save_overseer_tasks()
	local task_list = require("overseer.task_list")
	local tasks = task_list.list_tasks({
		filter = function(task)
			return not (task.metadata and task.metadata.ignore_on_session_save)
		end,
	})

	if #tasks == 0 then
		return nil
	end

	local saved = {}
	for _, task in ipairs(tasks) do
		local entry = task:serialize()
		if task.status == "RUNNING" then
			entry._saved_status = "CANCELED"
			entry._saved_time_end = os.time()
		else
			entry._saved_status = task.status
			entry._saved_time_end = task.time_end
		end
		entry._saved_time_start = task.time_start
		entry._saved_exit_code = task.exit_code
		table.insert(saved, entry)
	end

	return saved
end
local function restore_overseer_tasks(tasks)
	local overseer = require("overseer")

	for _, entry in ipairs(tasks) do
		local saved_status = entry._saved_status
		local saved_exit_code = entry._saved_exit_code
		local saved_time_start = entry._saved_time_start
		local saved_time_end = entry._saved_time_end
		local saved_raw_output = entry.metadata and entry.metadata.raw_output or ""
		entry.components = { "capture_raw_output", "default" }
		local task = overseer.new_task(entry)
		if saved_status then
			task.status = saved_status
		end
		if saved_exit_code then
			task.exit_code = saved_exit_code
			saved_raw_output = saved_raw_output .. string.format("\n[Process exited %d]", saved_exit_code)
		end
		if saved_time_start then
			task.time_start = saved_time_start
		end
		if saved_time_end then
			task.time_end = saved_time_end
		end

		local bufnr = vim.api.nvim_create_buf(false, true)
		local term_id = vim.api.nvim_open_term(bufnr, {})
		vim.bo[bufnr].scrollback = 99999
		pcall(vim.api.nvim_chan_send, term_id, saved_raw_output)

		vim.bo[bufnr].filetype = "OverseerOutput"
		vim.b[bufnr].overseer_task = task.id

		task.strategy.bufnr = bufnr
		task.strategy.term_id = term_id
	end
end

return {
	"rmagatti/auto-session",
	lazy = false,
	config = function()
		local auto_session = require("auto-session")
		auto_session.setup({
			suppressed_dirs = { "~/", "~/home", "~/home/projects", "/" },
			save_and_restore_shada = true,
			save_extra_data = function()
				local data = {
					overseer_tasks = save_overseer_tasks(),
					last_overseer_task = vim.g.last_overseer_task,
					last_dap_task = vim.g.last_dap_task,
				}
				if not data.overseer_tasks and not data.last_overseer_task and not data.last_dap_task then
					return nil
				end
				return vim.json.encode(data)
			end,
			restore_extra_data = function(_, extra_data)
				local ok, data = pcall(vim.json.decode, extra_data)
				if not ok then
					return
				end

				-- Sessions saved before task-selection persistence stored the task list directly.
				local tasks = data.overseer_tasks or data
				vim.g.last_overseer_task = data.last_overseer_task
				vim.g.last_dap_task = data.last_dap_task
				if tasks then
					restore_overseer_tasks(tasks)
				end
			end,
		})

		-- auto-session saves on exit but I want to save more often in case of crashes.
		local function autosave()
			vim.defer_fn(function()
				auto_session.save_session(nil, { show_message = false })
				require("fidget").notify(string.format('Saved session "%s"', vim.fn.getcwd()))
				autosave()
			end, 300000)
		end
		autosave()
	end,
}
