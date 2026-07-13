---@type Task[]
local M = {
	{
		name = "Run SCMHighway E2E test",
		dap = {
			enabled = true,
			options = {
				type = "gdb",
			},
		},
		resolve_metadata = function()
			local metadata = {}
			metadata.ddad_path = vim.fn.getcwd()
			metadata.tests_path = metadata.ddad_path
				.. "/tools/env_simulator/ASTAS_DATA/E2EOpTestArtifacts/SCMHighway/Resources/Configurations/"
			metadata.common_resources_path = metadata.ddad_path
				.. "/tools/env_simulator/ExampleData/E2EOpTestArtifacts/SCMHighway/Resources/Common"

			-- Pick a test configuration directory
			local dirs = {}
			for name, type in vim.fs.dir(metadata.tests_path) do
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
			metadata.selected_test = coroutine.yield()
			if metadata.selected_test == nil then
				return nil
			end
			metadata.selected_test_path = metadata.tests_path .. metadata.selected_test

			return metadata
		end,
		pre_run_cmd = function(metadata)
			metadata.output_path = vim.fn.expand("~")
				.. "/simulation_outputs/"
				.. metadata.selected_test
				.. "/"
				.. string.format("%s-%03d", os.date("%y-%m-%d-%H-%M-%S"), vim.uv.hrtime() / 1e6 % 1000)

			local pre_run_script = vim.fn.tempname()
			vim.fn.writefile({
				string.format(
					"cp %s/MiscObjects %s -r --remove-destination",
					metadata.common_resources_path,
					metadata.selected_test_path
				),
				string.format(
					"cp %s/UserSettings %s -r --remove-destination",
					metadata.common_resources_path,
					metadata.selected_test_path
				),
				string.format(
					"cp %s/Vehicles %s -r --remove-destination",
					metadata.common_resources_path,
					metadata.selected_test_path
				),
				string.format(
					"cp %s/systemConfigBlueprint.xml %s -r --remove-destination",
					metadata.common_resources_path,
					metadata.selected_test_path
				),
				string.format(
					"cp %s/ProfilesCatalog.xml %s -r --remove-destination",
					metadata.common_resources_path,
					metadata.selected_test_path
				),
				string.format(
					'sed -i "s|Plugins = {/path/to/update}|Plugins = {/opt/astas_core/plugins, %s/bazel-bin/external/gecco_default/src/controller}|" "%s/UserSettings/UserSettings.ini"',
					metadata.ddad_path,
					metadata.selected_test_path
				),
				"mkdir -p " .. metadata.output_path,
				string.format(
					'sed -i "s|OutputDirectoryPath = /path/to/update|OutputDirectoryPath = %s|" "%s/UserSettings/UserSettings.ini"',
					metadata.output_path,
					metadata.selected_test_path
				),
				string.format(
					'sed -i "s|"/path/to/update"|"%s"|" "%s/Scenarios/XOSC/Scenario.xosc"',
					metadata.selected_test_path,
					metadata.selected_test_path
				),
				"bazel build --config=env_simulator_debug --override_repository=osi_query_library=/home/pedro/projects/osi-query-library //tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip",
				string.format(
					'cp "%s/bazel-bin/tools/env_simulator/modules/stochastic_cognitive_model/AlgorithmScm.fmu" "%s"',
					metadata.ddad_path,
					metadata.selected_test_path
				),
			}, pre_run_script)
			return { "bash", pre_run_script }
		end,
		cmd = function(metadata)
			return {
				metadata.ddad_path .. "/bazel-bin/tools/env_simulator/astas_cli/astas_cli",
				"-t",
				"50",
				"-n",
				"1",
				"-r",
				"0",
				"-s",
				metadata.selected_test_path .. "/Scenarios/XOSC/Scenario.xosc",
				"-d",
				metadata.selected_test_path,
				"-p",
				metadata.output_path,
				"-l",
				metadata.output_path,
				"-o",
				metadata.output_path .. "/output.mcap",
			}
		end,
	},
	{
		name = "Run file in ./bazel-bin",
		dap = {
			enabled = true,
			options = {
				type = "gdb",
			},
		},
		resolve_metadata = function()
			local file_path =
				require("utils.picker").pick_file(vim.fn.getcwd() .. "/bazel-bin", "Pick a file (./bazel-bin)")
			if not file_path then
				return nil
			end
			local cmd = { file_path }
			vim.list_extend(cmd, vim.split(vim.fn.input("Args: "), " +", { trimempty = true }))
			return { cmd = cmd }
		end,
		cmd = function(metadata)
			return metadata.cmd
		end,
	},
	{
		-- Inspired by https://github.com/alexander-born/cmp-bazel
		name = "Build a bazel target",
		resolve_metadata = function()
			-- Instead of manually defining a list of targets, I could automatically get a list of targets using something like:
			--  `bazel query --keep_going --noshow_progress --output label '//tools/env_simulator/astas_cli/... except kind(cc_test, //tools/env_simulator/astas_cli/...) except kind(filegroup, //tools/env_simulator/astas_cli/...)' 2>/dev/null`
			-- But it is hard to filter those for targets I actually care about so I'll just add to this list whenever I find one I need.
			-- Get all available targets with `bazel query --keep_going //...`.
			-- For all possible 'bazel query' output formats, see: https://bazel.build/query/language#output-formats
			local targets = {
				"//tools/env_simulator/astas_cli:astas_cli",
				"//tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip",
				"//tools/env_simulator/modules/stochastic_cognitive_model:stochastic_cognitive_model_lib",
				"//third_party/googletest:googletest",
				"//tools/env_simulator/modules/stochastic_cognitive_model/tests/Core/Sensor_Tests:sensor_tests",
			}

			local co = coroutine.running()
			Snacks.picker.select(targets, {
				prompt = "Select target",
			}, function(v)
				coroutine.resume(co, v)
			end)
			local selected_target = coroutine.yield()
			if not selected_target then
				return nil
			end

			Snacks.picker.select(
				-- TODO: add option for env_simulator_debug with clang flags so I get the best of both worlds, or clang with debug flags, whichever is easier
				{ "env_simulator_debug", "env_simulator_clang", "env_simulator_release" },
				{
					prompt = "Select config",
				},
				function(v)
					coroutine.resume(co, v)
				end
			)
			local selected_config = coroutine.yield()

			local cmd = { "bazel", "build" }
			if selected_config ~= nil then
				vim.list_extend(cmd, { "--config=" .. selected_config })
			end
			vim.list_extend(cmd, vim.split(vim.fn.input("Args: "), " +", { trimempty = true }))
			vim.list_extend(cmd, { "--", selected_target })

			return { cmd = cmd }
		end,
		cmd = function(metadata)
			return metadata.cmd
		end,
	},
}

return M
