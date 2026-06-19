-- Custom overseer resession extension. Overwrites the old one.
-- Saves the task metadata and output but doesn't reopen the window if it was open.
-- WARN: These changes use internal/private/new fields that aren't supposed to be used so there are
--  some warnings. I could add ignores to each line but I think it looks worse than the underlines.

local M = {}

---@class overseer.CustomResessionConfig
---@field autostart_on_load? boolean
---@field filter? overseer.ListTaskOpts
local conf = {}

---@param data? overseer.CustomResessionConfig
M.config = function(data)
	conf = vim.tbl_extend("keep", data or {}, {
		autostart_on_load = false,
		filter = {},
	})
end

M.on_save = function()
	local task_list = require("overseer.task_list")
	local tasks = task_list.list_tasks(conf.filter)

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

M.on_load = function(data)
	local overseer = require("overseer")

	for _, entry in ipairs(data) do
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
		local term_id

		term_id = vim.api.nvim_open_term(bufnr, {})
		vim.bo[bufnr].scrollback = 99999
		pcall(vim.api.nvim_chan_send, term_id, saved_raw_output)

		vim.bo[bufnr].filetype = "OverseerOutput"
		vim.b[bufnr].overseer_task = task.id

		task.strategy.bufnr = bufnr
		task.strategy.term_id = term_id

		if conf.autostart_on_load then
			task:start()
		end
	end
end

return M
