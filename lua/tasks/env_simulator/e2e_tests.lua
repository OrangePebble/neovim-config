local utils = require("tasks.env_simulator.utils")
local picker = require("utils.picker")

local ddad_path = utils.ddad_path

---@type Task
local e2e_tests = {
	name = "Run E2E test",
	resolve_context = function()
		local context = {}
		context.ddad_path = ddad_path

		local co = coroutine.running()

		-- List all e2e_tests targets
		local targets =
			utils.run_bazel_query({ "--output=label_kind", "//tools/env_simulator/e2e_tests:*" }, ddad_path, co)
		if not targets then
			return nil
		end

		-- Filter the targets to the py_test ones
		local test_targets = {}
		for line in vim.gsplit(targets, "\n", { trimempty = true }) do
			local target = line:match("^py_test rule (//tools/env_simulator/e2e_tests:[^%s]+)$")
			if target then
				table.insert(test_targets, target)
			end
		end
		table.sort(test_targets)
		if vim.tbl_isempty(test_targets) then
			vim.notify("No py_test targets found.", vim.log.levels.WARN)
			return nil
		end

		picker.select_one(test_targets, {
			prompt = "Select bazel target",
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

		-- Get build data about the selected_target
		local build_data = utils.run_bazel_query({ "--output=build", context.selected_target }, ddad_path, co)
		if not build_data then
			return nil
		end

		-- Get the file group for the JSON file
		local json_filegroup =
			build_data:match("%$%(location%s+(//tools/env_simulator/ExampleData:[^%s%)]+_json_file)%)")
		if not json_filegroup then
			vim.notify("Could not resolve the JSON filegroup.", vim.log.levels.ERROR)
			return nil
		end

		-- Get build data about the JSON file group
		local json_filegroup_build_data = utils.run_bazel_query({ "--output=build", json_filegroup }, ddad_path, co)
		if not json_filegroup_build_data then
			return nil
		end

		-- Get the JSON file's path
		local relative_json_path =
			json_filegroup_build_data:match('srcs = %["//tools/env_simulator/ExampleData:([^%"]+%.json)"%]')
		if not relative_json_path then
			vim.notify("Could not resolve the JSON path.", vim.log.levels.ERROR)
			return nil
		end
		local json_path = ddad_path .. "/tools/env_simulator/ExampleData/" .. relative_json_path
		local ok, json_text = pcall(vim.fn.readfile, json_path)
		if not ok then
			vim.notify("Could not read the JSON file: " .. json_path, vim.log.levels.ERROR)
			return nil
		end

		-- Read the JSON file and get available tests
		local decode_ok, decoded_json = pcall(vim.json.decode, table.concat(json_text, "\n"))
		if not decode_ok then
			vim.notify("Could not decode the JSON file: " .. json_path, vim.log.levels.ERROR)
			return nil
		end
		local test_names = {}
		for test_name in pairs(decoded_json.tests or {}) do
			if not vim.startswith(test_name:upper(), "DISABLED_") then
				table.insert(test_names, test_name)
			end
		end
		table.sort(test_names)
		if vim.tbl_isempty(test_names) then
			vim.notify("No enabled tests found in the JSON file: " .. json_path, vim.log.levels.WARN)
			return nil
		end

		picker.select_one(test_names, {
			prompt = "Select test",
		}, function(item)
			coroutine.resume(co, item)
		end)
		context.selected_test = coroutine.yield()
		if not context.selected_test then
			return nil
		end

		context.selected_config_args = utils.select_config(co)
		if not context.selected_config_args then
			return nil
		end
		context.selected_repository_args = utils.select_override_repositories(co)

		context.context_name = "Run " .. context.selected_test .. " E2E test"
		context.json_name = vim.fs.basename(json_path)
		context.output_parent_path = vim.fn.expand("~") .. "/simulation_outputs/e2e-tests"
		return context
	end,
	cmd = function(context)
		-- output_path is not inside resolve_context so that the date is different when run_last is used
		context.output_path = context.output_parent_path
			.. "/"
			.. context.selected_test
				:gsub("(%a)([%w']*)", function(first, rest)
					return first:upper() .. rest
				end)
				:gsub("%s+", "")
			.. "/"
			.. os.date("%y-%m-%d_%Hh%Mm%Ss")
		context.raw_artifacts_path = context.output_path .. "/E2E-Artifacts"

		local cmd = {
			"bazel",
			"run",
			context.selected_target,
		}
		vim.list_extend(cmd, context.selected_config_args)
		vim.list_extend(cmd, context.selected_repository_args)
		vim.list_extend(cmd, {
			"--",
			"--store-artifacts",
			"-vvv",
			"-k=" .. vim.split(context.selected_test, " +", { trimempty = true })[1],
			"--artifacts-path=" .. context.raw_artifacts_path,
		})

		return cmd
	end,
	post_run_cmd = function(context)
		local exit_code = context.task_overseer.exit_code
		local lines = {
			context.task_overseer.status .. " " .. tostring(exit_code == nil and "unknown" or exit_code),
			"",
		}

		local raw_output = context.task_overseer and context.task_overseer.metadata.raw_output or ""
		local plain_output = raw_output:gsub("\27%[[0-?]*[ -/]*[@-~]", "")
		vim.list_extend(lines, vim.split(plain_output, "\n", { plain = true }))

		vim.fn.writefile(lines, context.output_path .. "/console_output.txt")

		return {
			"env",
			"DDAD_PATH=" .. context.ddad_path,
			"JSON_NAME=" .. context.json_name,
			"SELECTED_TEST=" .. context.selected_test,
			"OUTPUT_PARENT_PATH=" .. context.output_parent_path,
			"OUTPUT_PATH=" .. context.output_path,
			"RAW_ARTIFACTS_PATH=" .. context.raw_artifacts_path,
			"bash",
			"-c",
			[[
          set -euo pipefail # Fail this script on first command failure

          TEST_GROUP=$(basename "${RAW_ARTIFACTS_PATH}"/tools/env_simulator/ExampleData/E2EOpTestArtifacts/*)

          mkdir "${OUTPUT_PATH}"/artifacts
          mv "${RAW_ARTIFACTS_PATH}"/tools/env_simulator/ExampleData/E2EOpTestArtifacts/*/Resources/*/*/*/* "${OUTPUT_PATH}"/artifacts
          rm -rf "${RAW_ARTIFACTS_PATH}"
          mv "${OUTPUT_PATH}"/console_output.txt "${OUTPUT_PATH}"/artifacts/*/

          cp "${DDAD_PATH}"/tools/env_simulator/ExampleData/E2EOpTestArtifacts/"${TEST_GROUP}"/Resources/"${JSON_NAME}" "${OUTPUT_PATH}"
          cp -r "${DDAD_PATH}"/tools/env_simulator/ExampleData/E2EOpTestArtifacts/"${TEST_GROUP}"/Resources/Configurations/"${SELECTED_TEST}" "${OUTPUT_PATH}"/configuration

          rm -rf "${OUTPUT_PARENT_PATH}"/_latest_artifacts
          mkdir "${OUTPUT_PARENT_PATH}"/_latest_artifacts
          cp -r "${OUTPUT_PATH}"/artifacts/*/* "${OUTPUT_PARENT_PATH}"/_latest_artifacts
      ]],
		}
	end,
}

---@type Task
local e2e_tests_astas_cli = {
	name = "Run E2E test scenario in astas_cli",
	dap = {
		enabled = true,
		options = {
			type = "gdb",
			cwd = ddad_path .. "/bazel-ddad",
		},
	},
	resolve_context = function()
		local context = {}
		context.ddad_path = ddad_path
		local co = coroutine.running()

		local test_groups_path = context.ddad_path .. "/tools/env_simulator/ExampleData/E2EOpTestArtifacts"
		local test_groups = {}
		for name, type in vim.fs.dir(test_groups_path) do
			if type == "directory" then
				table.insert(test_groups, name)
			end
		end
		table.sort(test_groups)
		picker.select_one(test_groups, {
			prompt = "Select test group",
		}, function(v)
			coroutine.resume(co, v)
		end)
		local selected_test_group = coroutine.yield()
		if not selected_test_group then
			return nil
		end

		local scenarios_path = test_groups_path .. "/" .. selected_test_group .. "/Resources/Configurations/"
		context.common_resources_path = test_groups_path .. "/" .. selected_test_group .. "/Resources/Common"

		local dirs = {}
		for name, type in vim.fs.dir(scenarios_path) do
			if type == "directory" then
				table.insert(dirs, name)
			end
		end
		table.sort(dirs)
		picker.select_one(dirs, {
			prompt = "Select scenario",
		}, function(v)
			coroutine.resume(co, v)
		end)
		context.selected_scenario = coroutine.yield()
		if not context.selected_scenario then
			return nil
		end
		context.selected_scenario_path = scenarios_path .. context.selected_scenario

		local selected_config_args = utils.select_config(co)
		if not selected_config_args then
			return nil
		end
		context.selected_config_args = table.concat(selected_config_args, " ")
		local selected_repository_args = utils.select_override_repositories(co)
		context.selected_repository_args = table.concat(selected_repository_args, " ")

		Snacks.input({ prompt = "Number of runs:", default = "1" }, function(value)
			coroutine.resume(co, value)
		end)
		context.run_count = coroutine.yield()
		if not context.run_count or not context.run_count:match("^%d+$") then
			return nil
		end

		Snacks.input({ prompt = "Seed:", default = "0" }, function(value)
			coroutine.resume(co, value)
		end)
		context.seed = coroutine.yield()
		if not context.seed or not context.seed:match("^%d+$") then
			return nil
		end

		context.context_name = "Run " .. context.selected_scenario .. " E2E test in astas_cli"

		context.output_parent_path = vim.fn.expand("~") .. "/simulation_outputs/e2e-tests-astas_cli"

		return context
	end,
	pre_run_cmd = function(context)
		-- output_path is not inside resolve_context so that the date is different when run_last is used
		context.output_path = context.output_parent_path
			.. "/"
			.. context.selected_scenario
			.. "/"
			.. os.date("%y-%m-%d_%Hh%Mm%Ss")

		return {
			"env",
			"COMMON_RESOURCES_PATH=" .. context.common_resources_path,
			"SELECTED_SCENARIO_PATH=" .. context.selected_scenario_path,
			"DDAD_PATH=" .. context.ddad_path,
			"OUTPUT_PATH=" .. context.output_path,
			"SELECTED_CONFIG_ARGS=" .. context.selected_config_args,
			"SELECTED_REPOSITORY_ARGS=" .. context.selected_repository_args,
			"bash",
			"-c",
			[[
          set -euo pipefail # Fail this script on first command failure

          bazel build $SELECTED_CONFIG_ARGS $SELECTED_REPOSITORY_ARGS -- //tools/env_simulator/astas_cli:astas_cli //tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip

          mkdir -p "${OUTPUT_PATH}"/artifacts
          cp -r "${SELECTED_SCENARIO_PATH}" "${OUTPUT_PATH}"/configuration
          # Using rsync because cp without overwriting is a mess
  				rsync -a --ignore-existing "${COMMON_RESOURCES_PATH}/" "${OUTPUT_PATH}"/configuration/
          cp "${DDAD_PATH}"/bazel-bin/tools/env_simulator/modules/stochastic_cognitive_model/AlgorithmScm.fmu "${OUTPUT_PATH}"/configuration

          sed -i "s|Plugins = {/path/to/update}|Plugins = {/opt/astas_core/plugins, ${DDAD_PATH}/bazel-bin/external/gecco_default/src/controller}|" "${OUTPUT_PATH}"/configuration/UserSettings/UserSettings.ini
          sed -i "s|\"/path/to/update\"|\"${OUTPUT_PATH}/configuration\"|" "${OUTPUT_PATH}"/configuration/Scenarios/XOSC/Scenario.xosc
          sed -i "s|OutputDirectoryPath = /path/to/update|OutputDirectoryPath = $OUTPUT_PATH/artifacts|" "${OUTPUT_PATH}"/configuration/UserSettings/UserSettings.ini
      ]],
		}
	end,
	cmd = function(context)
		return {
			context.ddad_path .. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli",
			"-t",
			"100",
			"-r",
			context.seed,
			"-n",
			context.run_count,
			"-s",
			context.output_path .. "/configuration/Scenarios/XOSC/Scenario.xosc",
			"-d",
			context.output_path .. "/configuration",
			"-p",
			context.output_path .. "/artifacts",
			"-l",
			context.output_path .. "/artifacts",
			"-o",
			context.output_path .. "/artifacts/output.mcap",
		}
	end,
	post_run_cmd = function(context)
		local exit_code = context.task_overseer.exit_code
		local lines = {
			context.task_overseer.status .. " " .. tostring(exit_code == nil and "unknown" or exit_code),
			"",
		}

		local raw_output = context.task_overseer and context.task_overseer.metadata.raw_output or ""
		local plain_output = raw_output:gsub("\27%[[0-?]*[ -/]*[@-~]", "")
		vim.list_extend(lines, vim.split(plain_output, "\n", { plain = true }))

		vim.fn.writefile(lines, context.output_path .. "/artifacts/console_output.txt")

		return {
			"env",
			"OUTPUT_PATH=" .. context.output_path,
			"OUTPUT_PARENT_PATH=" .. context.output_parent_path,
			"bash",
			"-c",
			[=[
          set -euo pipefail # Fail this script on first command failure

          VENV="${OUTPUT_PARENT_PATH}"/.venv
          if [ ! -f "${VENV}"/bin/activate ]; then
              # Uses system packages
              python3.12 -m venv --system-site-packages "${VENV}"
          fi
          source "${VENV}"/bin/activate

          # Install the pytest plugin into the venv if it is not importable yet.
          if ! python3.12 -c 'import pytest_optestrunner' >/dev/null 2>&1; then
               bazel fetch @op_test_runner//:op_test_runner
               OPTR_FOLDER="$(bazel info output_base)/external/op_test_runner"
               python3.12 -m pip install -e "$OPTR_FOLDER/plugin/optestrunner"
           fi

          cp "${OUTPUT_PATH}"/configuration/*.xodr "${OUTPUT_PATH}"/artifacts
          python3.12 -m pytest_optestrunner.merge_csv2csv -r "${OUTPUT_PATH}"/artifacts
          python3.12 -m pytest_optestrunner.merge -r "${OUTPUT_PATH}"/artifacts

          sed -i "s|schemaVersion=\"0.0.3\"|schemaVersion=\"0.3.1\"|" "${OUTPUT_PATH}"/artifacts/simulationOutput.xml

          rm "${OUTPUT_PATH}"/configuration/AlgorithmScm.fmu

          rm -rf "${OUTPUT_PARENT_PATH}"/_latest_artifacts
          mkdir "${OUTPUT_PARENT_PATH}"/_latest_artifacts
          cp -r "${OUTPUT_PATH}"/artifacts/* "${OUTPUT_PARENT_PATH}"/_latest_artifacts
          if [[ -e default.profraw ]]; then
            mv default.profraw "${OUTPUT_PARENT_PATH}"/_latest_artifacts
          fi
      ]=],
		}
	end,
}

---@type Task[]
local M = {
	e2e_tests,
	e2e_tests_astas_cli,
}

return M
