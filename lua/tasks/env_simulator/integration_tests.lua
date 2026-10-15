local env_simulator_utils = require("tasks.env_simulator.utils")
local utils = require("tasks.utils")
local picker = require("utils.picker")

local ddad_path = env_simulator_utils.ddad_path

---@type Task
local integration_tests = {
	name = "Run integration tests",
	overseer = {
		options = {
			cwd = ddad_path .. "/bazel-ddad",
			env = {
				LD_LIBRARY_PATH = "/opt/astas_core/lib_deps:/opt/astas_core/plugins:/usr/lib/x86_64-linux-gnu",
			},
		},
	},
	dap = {
		enabled = true,
		options = {
			type = "gdb",
			cwd = ddad_path .. "/bazel-ddad",
			env = {
				LD_LIBRARY_PATH = "/opt/astas_core/lib_deps:/opt/astas_core/plugins:/usr/lib/x86_64-linux-gnu",
			},
		},
	},
	first_run_pre = function(context)
		local co = coroutine.running()
		local pre_tasks = {}

		local query_result = utils.run_bazel_query({
			"--output=label_kind",
			"kind(cc_test, //tools/env_simulator/astas_core/Tests/Integration/...)",
		}, ddad_path, co)
		table.insert(pre_tasks, query_result.task)
		local targets = query_result.output
		if not targets then
			context.failed = true
			return pre_tasks
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
			context.failed = true
			return pre_tasks
		end

		picker.select_one(test_targets, {
			prompt = "Select integration-test target",
			format_item = function(item)
				return item:match("^[^:]+:(.+)$") or item
			end,
		}, function(item)
			coroutine.resume(co, item)
		end)
		context.selected_target = coroutine.yield()
		if not context.selected_target then
			context.failed = true
			return pre_tasks
		end

		context.selected_config_args = env_simulator_utils.select_config(co)
		if not context.selected_config_args then
			context.failed = true
			return pre_tasks
		end
		context.selected_repository_args = env_simulator_utils.select_override_repositories(co)

		local build_cmd = { context.selected_target }
		vim.list_extend(build_cmd, context.selected_config_args)
		vim.list_extend(build_cmd, context.selected_repository_args)
		local build_result = utils.run_bazel_build(build_cmd, ddad_path, co)
		table.insert(pre_tasks, build_result.task)
		if build_result.task.status ~= "SUCCESS" then
			context.failed = true
			return pre_tasks
		end

		local cquery_cmd = { "--output=files" }
		vim.list_extend(cquery_cmd, context.selected_config_args)
		vim.list_extend(cquery_cmd, context.selected_repository_args)
		table.insert(cquery_cmd, context.selected_target)
		local cquery_result = utils.run_bazel_cquery(cquery_cmd, ddad_path, co)
		table.insert(pre_tasks, cquery_result.task)
		local test_binary = cquery_result.output
		if not test_binary then
			context.failed = true
			return pre_tasks
		end
		local relative_test_binary = vim.trim(test_binary)
		if relative_test_binary == "" then
			vim.notify("Could not resolve the test binary.", vim.log.levels.ERROR)
			context.failed = true
			return pre_tasks
		end
		context.test_binary = ddad_path .. "/" .. relative_test_binary

		local list_result = utils.run_command(
			{ context.test_binary, "--gtest_list_tests" },
			ddad_path,
			co,
			"GTest",
			"Listing tests",
			"Listing tests finished",
			"Listing tests failed"
		)
		table.insert(pre_tasks, list_result.task)
		if not list_result.output then
			context.failed = true
			return pre_tasks
		end
		local listed_tests = vim.split(list_result.output, "\n", { trimempty = true })
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
			context.failed = true
			return pre_tasks
		end

		picker.select_many(test_names, {
			prompt = "Select integration test",
		}, function(selected)
			coroutine.resume(co, selected)
		end)
		context.selected_tests = coroutine.yield()
		if not context.selected_tests or vim.tbl_isempty(context.selected_tests) then
			context.failed = true
			return pre_tasks
		end
		context.test_filter = table.concat(context.selected_tests, ":")
		context.main_name = "Run integration tests: " .. table.concat(context.selected_tests, ", ")
		return pre_tasks
	end,
	run_pre = function(context)
		-- The build already runs in first_run_pre to query available tests. This
		-- repeats it on reruns, when first_run_pre is intentionally skipped.
		local cmd = { "bazel", "build", context.selected_target }
		vim.list_extend(cmd, context.selected_config_args)
		vim.list_extend(cmd, context.selected_repository_args)
		local result = utils.run_bazel_build(cmd, ddad_path, coroutine.running())
		if result.task.status ~= "SUCCESS" then
			context.failed = true
		end
		return { result.task }
	end,
	run_main = function(context)
		return { context.test_binary, "--gtest_filter=" .. context.test_filter }
	end,
}

return { integration_tests }
