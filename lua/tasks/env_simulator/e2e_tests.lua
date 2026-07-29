local utils = require("tasks.env_simulator.utils")

local ddad_path = utils.ddad_path

---@param cmd string[]
---@return string|nil
local function run_bazel_query(cmd)
	local result = vim.system(cmd, { text = true, cwd = ddad_path }):wait()
	if result.code ~= 0 then
		local stderr = vim.trim(result.stderr or "")
		vim.notify(stderr ~= "" and stderr or "Bazel query failed", vim.log.levels.ERROR)
		return nil
	end

	return result.stdout or ""
end

---@param items string[]
---@param prompt string
---@return string|nil
local function select_item(items, prompt)
	local co = coroutine.running()
	Snacks.picker.select(items, {
		prompt = prompt,
	}, function(item)
		coroutine.resume(co, item)
	end)
	return coroutine.yield()
end

---@return string[]|nil
local function list_e2e_test_targets()
	local output = run_bazel_query({ "bazel", "query", "--output=label_kind", "//tools/env_simulator/e2e_tests:*" })
	if not output then
		return nil
	end

	local bazel_targets = {}
	for line in vim.gsplit(output, "\n", { trimempty = true }) do
		local target = line:match("^py_test rule (//tools/env_simulator/e2e_tests:[^%s]+)$")
		if target then
			table.insert(bazel_targets, target)
		end
	end
	table.sort(bazel_targets)

	if vim.tbl_isempty(bazel_targets) then
		vim.notify("No E2E py_test targets found.", vim.log.levels.WARN)
		return nil
	end

	return bazel_targets
end

---@param bazel_target string
---@return string|nil
local function get_e2e_test_json_path(bazel_target)
	local target_output = run_bazel_query({ "bazel", "query", "--output=build", bazel_target })
	if not target_output then
		return nil
	end

	local json_filegroup = target_output:match("%$%(location%s+(//tools/env_simulator/ExampleData:[^%)]+)%)")
	if not json_filegroup then
		vim.notify("Could not resolve E2E test JSON filegroup.", vim.log.levels.ERROR)
		return nil
	end

	local filegroup_output = run_bazel_query({ "bazel", "query", "--output=build", json_filegroup })
	if not filegroup_output then
		return nil
	end

	local relative_json_path = filegroup_output:match('srcs = %[%"//tools/env_simulator/ExampleData:([^%"]+%.json)%"%]')
	if not relative_json_path then
		vim.notify("Could not resolve E2E test JSON path.", vim.log.levels.ERROR)
		return nil
	end

	return ddad_path .. "/tools/env_simulator/ExampleData/" .. relative_json_path
end

---@param json_path string
---@return string[]|nil
local function list_json_test_names(json_path)
	local ok, json_text = pcall(vim.fn.readfile, json_path)
	if not ok then
		vim.notify("Could not read E2E test JSON: " .. json_path, vim.log.levels.ERROR)
		return nil
	end

	local decode_ok, decoded = pcall(vim.json.decode, table.concat(json_text, "\n"))
	if not decode_ok then
		vim.notify("Could not decode E2E test JSON: " .. json_path, vim.log.levels.ERROR)
		return nil
	end

	local test_names = {}
	for test_name in pairs(decoded.tests or {}) do
		if not vim.startswith(test_name, "DISABLED_") then
			table.insert(test_names, test_name)
		end
	end
	table.sort(test_names)

	if vim.tbl_isempty(test_names) then
		vim.notify("No enabled tests found in E2E JSON.", vim.log.levels.WARN)
		return nil
	end

	return test_names
end

local e2e_tests = {
	name = "Run SCMHighway E2E test",
	resolve_context = function()
		local context = {}
		context.ddad_path = ddad_path

		local bazel_targets = list_e2e_test_targets()
		if not bazel_targets then
			return nil
		end

		context.selected_target = select_item(bazel_targets, "Select E2E Bazel target")
		if context.selected_target == nil then
			return nil
		end

		context.selected_test_json_path = get_e2e_test_json_path(context.selected_target)
		if context.selected_test_json_path == nil then
			return nil
		end

		local test_names = list_json_test_names(context.selected_test_json_path)
		if not test_names then
			return nil
		end

		context.selected_test = select_item(test_names, "Select E2E test")
		if context.selected_test == nil then
			return nil
		end

		return context
	end,
	cmd = function(context)
		return {
			"bazel",
			"run",
			"--config=env_simulator_release",
			context.selected_target,
			"--",
			"--store-artifacts",
			"-vvv",
			"-k=" .. context.selected_test,
		}
	end,
}

local e2e_tests_astas_cli = {
	name = "Run SCMHighway E2E test in astas_cli",
	dap = {
		enabled = true,
		options = {
			type = "gdb",
		},
	},
	resolve_context = function()
		local context = {}
		context.ddad_path = ddad_path
		context.tests_path = context.ddad_path
			.. "/tools/env_simulator/ASTAS_DATA/E2EOpTestArtifacts/SCMHighway/Resources/Configurations/"
		context.common_resources_path = context.ddad_path
			.. "/tools/env_simulator/ExampleData/E2EOpTestArtifacts/SCMHighway/Resources/Common"

		local dirs = {}
		for name, type in vim.fs.dir(context.tests_path) do
			if type == "directory" then
				table.insert(dirs, name)
			end
		end
		table.sort(dirs)

		local co = coroutine.running()
		Snacks.picker.select(dirs, {
			prompt = "Select configuration directory",
		}, function(v)
			coroutine.resume(co, v)
		end)
		context.selected_test = coroutine.yield()
		if context.selected_test == nil then
			return nil
		end
		context.selected_test_path = context.tests_path .. context.selected_test

		local selected_config = utils.select_config(co)
		context.selected_config = table.concat(selected_config, " ")
		local selected_repositories = utils.select_override_repositories(co)
		context.selected_repositories = table.concat(selected_repositories, " ")

		return context
	end,
	pre_run_cmd = function(context)
		context.output_path = vim.fn.expand("~")
			.. "/simulation_outputs/"
			.. context.selected_test
			.. "/"
			.. os.date("%y-%m-%d_%Hh%Mm%Ss")
		return {
			"env",
			"COMMON_RESOURCES_PATH=" .. context.common_resources_path,
			"SELECTED_TEST_PATH=" .. context.selected_test_path,
			"DDAD_PATH=" .. context.ddad_path,
			"OUTPUT_PATH=" .. context.output_path,
			"SELECTED_CONFIG=" .. context.selected_config,
			"SELECTED_REPOSITORIES=" .. context.selected_repositories,
			"bash",
			"-c",
			[[
          set -e # Fail this script on first command failure

          bazel build $SELECTED_CONFIG $SELECTED_REPOSITORIES -- //tools/env_simulator/astas_cli:astas_cli //tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip

          cp "$COMMON_RESOURCES_PATH/MiscObjects"               "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/UserSettings"              "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/Vehicles"                  "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/systemConfigBlueprint.xml" "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/ProfilesCatalog.xml"       "$SELECTED_TEST_PATH" -r --remove-destination
          sed -i "s|Plugins = {/path/to/update}|Plugins = {/opt/astas_core/plugins, $DDAD_PATH/bazel-bin/external/gecco_default/src/controller}|" "$SELECTED_TEST_PATH/UserSettings/UserSettings.ini"
          sed -i "s|"/path/to/update"|"$SELECTED_TEST_PATH"|" "$SELECTED_TEST_PATH/Scenarios/XOSC/Scenario.xosc"

          mkdir -p "$OUTPUT_PATH"
          sed -i "s|OutputDirectoryPath = /path/to/update|OutputDirectoryPath = $OUTPUT_PATH|" "$SELECTED_TEST_PATH/UserSettings/UserSettings.ini"

          cp "$DDAD_PATH/bazel-bin/tools/env_simulator/modules/stochastic_cognitive_model/AlgorithmScm.fmu" "$SELECTED_TEST_PATH"
        ]],
		}
	end,
	cmd = function(context)
		return {
			context.ddad_path .. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli",
			"-t",
			"100",
			"-n",
			"1",
			"-r",
			"0",
			"-s",
			context.selected_test_path .. "/Scenarios/XOSC/Scenario.xosc",
			"-d",
			context.selected_test_path,
			"-p",
			context.output_path,
			"-l",
			context.output_path,
			"-o",
			context.output_path .. "/output.mcap",
		}
	end,
}

---@type Task[]
local M = {
	e2e_tests,
	e2e_tests_astas_cli,
}

return M
