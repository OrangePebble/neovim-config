local utils = require("tasks.env_simulator.utils")
local picker = require("utils.picker")

local ddad_path = utils.ddad_path

---@type Task
local unit_tests = {
	name = "Run unit tests",
	dap = {
		enabled = true,
		options = {
			type = "gdb",
			cwd = ddad_path .. "/bazel-ddad",
		},
	},
	resolve_context = function()
		local context = {}
		local co = coroutine.running()

		local targets = utils.run_bazel_query({
			"--output=label_kind",
			"kind(cc_test, //tools/env_simulator/modules/stochastic_cognitive_model/tests/...)",
		}, ddad_path, co)
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

		local build_cmd = { context.selected_target }
		vim.list_extend(build_cmd, context.selected_config_args)
		vim.list_extend(build_cmd, context.selected_repository_args)
		if not utils.run_bazel_build(build_cmd, ddad_path, co) then
			return nil
		end

		local cquery_cmd = { "--output=files" }
		vim.list_extend(cquery_cmd, context.selected_config_args)
		vim.list_extend(cquery_cmd, context.selected_repository_args)
		table.insert(cquery_cmd, context.selected_target)
		local test_binary = utils.run_bazel_cquery(cquery_cmd, ddad_path, co)
		if not test_binary then
			return nil
		end
		local relative_test_binary = vim.trim(test_binary)
		if relative_test_binary == "" then
			vim.notify("Could not resolve the test binary.", vim.log.levels.ERROR)
			return nil
		end
		context.test_binary = ddad_path .. "/" .. relative_test_binary

		local test_output = utils.run_command(
			{ context.test_binary, "--gtest_list_tests" },
			ddad_path,
			co,
			"GTest",
			"Listing tests",
			"Listing tests finished",
			"Listting tests failed"
		)
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

		picker.select_many(test_names, {
			prompt = "Select unit test",
		}, function(selected)
			coroutine.resume(co, selected)
		end)
		context.selected_tests = coroutine.yield()
		if not context.selected_tests or vim.tbl_isempty(context.selected_tests) then
			return nil
		end
		context.test_filter = table.concat(context.selected_tests, ":")

		context.context_name = "Run unit tests:" .. table.concat(context.selected_tests, ", ")
		return context
	end,
	pre_run_cmd = function(context)
		-- This is already done in resolve_context because it is required to query available tests,
		--  but resolve_context is not called on reruns.
		local cmd = { "bazel", "build", context.selected_target }
		vim.list_extend(cmd, context.selected_config_args)
		vim.list_extend(cmd, context.selected_repository_args)
		return cmd
	end,
	cmd = function(context)
		return { context.test_binary, "--gtest_filter=" .. context.test_filter }
	end,
}

return { unit_tests }
