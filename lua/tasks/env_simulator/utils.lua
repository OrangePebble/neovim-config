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
		-- { "osi_query_library", "/home/pedro/projects/osi-query-library" },
		-- { "stochastics_library", "/home/pedro/projects/stochastics-library" },
		-- { "road_logic_suite", "/home/pedro/projects/road-logic-suite" },
		-- { "gt_gen_core_default", "/home/pedro/projects/gt-gen-core" },
	}
	if #available_repositories == 0 then
		return {}
	end

	local selected_repositories = nil
	picker.select_many_esc(available_repositories, {
		prompt = "Select repositories to override",
		format_item = function(repository)
			return repository[1]
		end,
	}, function(selected)
		selected_repositories = selected
		coroutine.resume(co)
	end)
	coroutine.yield()

	local cmd_args = {}
	for _, repository in ipairs(selected_repositories or {}) do
		table.insert(cmd_args, "--override_repository=" .. repository[1] .. "=" .. repository[2])
	end

	return cmd_args
end

return M
