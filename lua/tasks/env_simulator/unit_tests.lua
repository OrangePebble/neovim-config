local utils = require("tasks.env_simulator.utils")
local picker = require("utils.picker")

local ddad_path = utils.ddad_path

---@param cmd string[]
---@param co thread
---@return string|nil
local function run_bazel_query(cmd, co)
	local progress = require("fidget.progress").handle.create({
		title = "Running query",
		lsp_client = { name = "Bazel" },
		message = table.concat(cmd, " "),
		percentage = 0,
	})

	vim.system(cmd, { text = true, cwd = ddad_path }, function(result)
		vim.schedule(function()
			progress.title = result.code == 0 and "Query finished" or "Query failed"
			progress:finish()
			coroutine.resume(co, result)
		end)
	end)

	local result = coroutine.yield()
	if result.code ~= 0 then
		local stderr = vim.trim(result.stderr or "")
		vim.notify(stderr ~= "" and stderr or "Bazel query failed", vim.log.levels.ERROR)
		return nil
	end

	return result.stdout or ""
end

---@type Task
local unit_tests = {
	name = "Run unit test",
	resolve_context = function()
		local context = {}
		local co = coroutine.running()

		local targets = run_bazel_query({
			"bazel",
			"query",
			"--output=label_kind",
			"kind(cc_test, //tools/env_simulator/modules/stochastic_cognitive_model/tests/...)",
		}, co)
		if not targets then
			return nil
		end

		local test_targets = {}
		for line in vim.gsplit(targets, "\n", { trimempty = true }) do
			local target = line:match("^cc_test rule (//[^%s]+)$")
			if target then
				table.insert(test_targets, target)
			end
		end
		table.sort(test_targets)
		if vim.tbl_isempty(test_targets) then
			vim.notify("No cc_test targets found.", vim.log.levels.WARN)
			return nil
		end

		picker.select_one(test_targets, {
			prompt = "Select unit-test target",
			format_item = function(item)
				return item:match("^[^:]+:(.+)$") or item
			end,
		}, function(item)
			coroutine.resume(co, item)
		end)
		context.selected_target = coroutine.yield()
		if not context.selected_target then
			return nil
		end

		context.selected_config_args = utils.select_config(co)
		if not context.selected_config_args then
			return nil
		end
		context.selected_repository_args = utils.select_override_repositories(co)

		local build_cmd = { "bazel", "build", context.selected_target }
		vim.list_extend(build_cmd, context.selected_config_args)
		vim.list_extend(build_cmd, context.selected_repository_args)
		if not run_bazel_query(build_cmd, co) then
			return nil
		end

		local cquery_cmd = { "bazel", "cquery", "--output=files" }
		vim.list_extend(cquery_cmd, context.selected_config_args)
		vim.list_extend(cquery_cmd, context.selected_repository_args)
		table.insert(cquery_cmd, context.selected_target)
		local test_binary = run_bazel_query(cquery_cmd, co)
		if not test_binary then
			return nil
		end
		context.test_binary = vim.trim(test_binary)
		if context.test_binary == "" then
			vim.notify("Could not resolve the test binary.", vim.log.levels.ERROR)
			return nil
		end

		local test_output = run_bazel_query({ context.test_binary, "--gtest_list_tests" }, co)
		if not test_output then
			return nil
		end
		local listed_tests = vim.split(test_output, "\n", { trimempty = true })
		local test_names = {}
		local test_suite = nil
		for _, line in ipairs(listed_tests) do
			if not line:match("^%s") then
				test_suite = line
			elseif test_suite then
				local test_name = vim.trim(line):match("^([^%s#]+)")
				if test_name then
					table.insert(test_names, test_suite .. test_name)
				end
			end
		end
		if vim.tbl_isempty(test_names) then
			vim.notify("No GoogleTest cases found.", vim.log.levels.WARN)
			return nil
		end

		picker.select_one(test_names, {
			prompt = "Select unit test",
		}, function(item)
			coroutine.resume(co, item)
		end)
		context.selected_test = coroutine.yield()
		if not context.selected_test then
			return nil
		end

		context.context_name = "Run " .. context.selected_test .. " unit test"
		return context
	end,
	cmd = function(context)
		local cmd = { "bazel", "run", context.selected_target }
		vim.list_extend(cmd, context.selected_config_args)
		vim.list_extend(cmd, context.selected_repository_args)
		vim.list_extend(cmd, { "--", "--gtest_filter=" .. context.selected_test })
		return cmd
	end,
}

return { unit_tests }
