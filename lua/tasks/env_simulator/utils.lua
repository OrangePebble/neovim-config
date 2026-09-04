local M = {}
local picker = require("utils.picker")

M.ddad_path = vim.fn.getcwd()
if string.match(vim.fn.fnamemodify(M.ddad_path, ":t"), ".*env_simulator.*") then
	-- 2 directories up
	M.ddad_path = vim.fn.fnamemodify(M.ddad_path, ":h:h")
end

---@param co thread
function M.select_config(co)
	local special_config = "env_simulator_clang with debug flags"
	picker.select_one({
		special_config,
		"env_simulator_debug",
		"env_simulator_clang",
		"env_simulator_release",
	}, {
		prompt = "Select config",
	}, function(v)
		coroutine.resume(co, v)
	end)
	local selected_config = coroutine.yield()

	local cmd_args = {}
	if selected_config ~= nil then
		if selected_config == special_config then
			vim.list_extend(
				cmd_args,
				{ "--config=env_simulator_clang", "--compilation_mode=dbg", "--cxxopt=-O0", "--strip=never" }
			)
		else
			table.insert(cmd_args, "--config=" .. selected_config)
		end
	else
		return nil
	end

	return cmd_args
end

---@param co thread
function M.select_override_repositories(co)
	local available_repositories = {
		-- "osi_query_library",
		-- "stochastics-library",
	}
	if #available_repositories == 0 then
		return {}
	end

	local selected_repositories = nil
	picker.select_many_esc(available_repositories, {
		prompt = "Select repositories to override",
	}, function(selected)
		selected_repositories = selected
		coroutine.resume(co)
	end)
	coroutine.yield()

	local cmd_args = {}
	for _, repository in ipairs(selected_repositories or {}) do
		if repository == "osi_query_library" then
			table.insert(cmd_args, "--override_repository=osi_query_library=/home/pedro/projects/osi-query-library")
		elseif repository == "stochastics-library" then
			table.insert(cmd_args, "--override_repository=stochastics_library=/home/pedro/projects/stochastics-library")
		end
	end

	return cmd_args
end

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
---@return string|nil
function M.run_command(cmd, cwd, co, category, prog_msg, succ_msg, fail_msg)
	local progress = require("fidget.progress").handle.create({
		title = prog_msg,
		lsp_client = { name = category },
		message = table.concat(cmd, " "),
		percentage = 0,
	})

	vim.system(cmd, { text = true, cwd = cwd }, function(result)
		vim.schedule(function()
			progress.title = result.code == 0 and succ_msg or fail_msg
			progress:finish()
			coroutine.resume(co, result)
		end)
	end)

	local result = coroutine.yield()
	if result.code ~= 0 then
		local stderr = vim.trim(result.stderr or "")
		vim.notify(stderr ~= "" and stderr or category .. ": " .. fail_msg, vim.log.levels.ERROR)
		return nil
	end

	return result.stdout or ""
end
---@param args string[]
---@param cwd string
---@param co thread
---@return string|nil
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
---@return string|nil
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
---@return string|nil
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
