-- For this file I'm assuming that env_simulator will always be a ddad submodule.

local ddad_path = vim.fn.getcwd()
if string.match(vim.fn.fnamemodify(ddad_path, ":t"), ".*env_simulator.*") then
	-- 2 directories up
	ddad_path = vim.fn.fnamemodify(ddad_path, ":h:h")
end

---@type Task[]
local M = {
	{
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

			-- Pick a test configuration directory
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
				"bash",
				"-c",
				[[
          set -e # Fail this script on first command failure
          cp "$COMMON_RESOURCES_PATH/MiscObjects"               "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/UserSettings"              "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/Vehicles"                  "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/systemConfigBlueprint.xml" "$SELECTED_TEST_PATH" -r --remove-destination
          cp "$COMMON_RESOURCES_PATH/ProfilesCatalog.xml"       "$SELECTED_TEST_PATH" -r --remove-destination
          sed -i "s|Plugins = {/path/to/update}|Plugins = {/opt/astas_core/plugins, $DDAD_PATH/bazel-bin/external/gecco_default/src/controller}|" "$SELECTED_TEST_PATH/UserSettings/UserSettings.ini"
          sed -i "s|"/path/to/update"|"$SELECTED_TEST_PATH"|" "$SELECTED_TEST_PATH/Scenarios/XOSC/Scenario.xosc"

          mkdir -p "$OUTPUT_PATH"
          sed -i "s|OutputDirectoryPath = /path/to/update|OutputDirectoryPath = $OUTPUT_PATH|" "$SELECTED_TEST_PATH/UserSettings/UserSettings.ini"

          bazel build --config=env_simulator_clang --compilation_mode=dbg --cxxopt=-O0 --strip=never --override_repository=osi_query_library=/home/pedro/projects/osi-query-library -- //tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip
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
	},
	{
		name = "Run file in ./bazel-bin",
		dap = {
			enabled = true,
			options = {
				type = "gdb",
			},
		},
		resolve_context = function()
			local file_path =
				require("utils.picker").pick_file(vim.fn.getcwd() .. "/bazel-bin", "Pick a file (./bazel-bin)")
			if not file_path then
				return nil
			end
			local cmd = { file_path }
			vim.list_extend(cmd, vim.split(vim.fn.input("Args: "), " +", { trimempty = true }))
			return { cmd = cmd }
		end,
		cmd = function(context)
			return context.cmd
		end,
	},
	{
		-- Inspired by https://github.com/alexander-born/cmp-bazel
		name = "Build bazel targets",
		resolve_context = function()
			-- Instead of manually defining a list of targets, I could automatically get a list of targets using something like:
			--  `bazel query --keep_going --noshow_progress --output label '//tools/env_simulator/astas_cli/... except kind(cc_test, //tools/env_simulator/astas_cli/...) except kind(filegroup, //tools/env_simulator/astas_cli/...)' 2>/dev/null`
			-- But it is hard to filter those for targets I actually care about so I'll just add to this list whenever I find one I need.
			-- Get all available targets with `bazel query --keep_going //...`.
			-- For all possible 'bazel query' output formats, see: https://bazel.build/query/language#output-formats
			local targets = {
				"//tools/env_simulator/astas_cli:astas_cli",
				"//tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip",
				"//tools/env_simulator/modules/stochastic_cognitive_model:stochastic_cognitive_model_lib",
				"//third_party/open_simulation_interface:open_simulation_interface",
				"//tools/env_simulator/modules/stochastic_cognitive_model/tests/Core/Sensor_Tests:sensor_tests",
				"//third_party/googletest:googletest",
			}

			local co = coroutine.running()
			Snacks.picker.select(targets, {
				prompt = "Select targets",
				snacks = {
					actions = {
						confirm = function(picker, _)
							local selected = picker:selected({ fallback = true })
							picker:close()
							local values = vim.tbl_map(function(entry)
								return entry.item
							end, selected)
							coroutine.resume(co, values)
						end,
					},
				},
			}, function(_) end)
			local selected_targets = coroutine.yield()
			if not selected_targets then
				return nil
			end

			local special_config = "env_simulator_clang with debug flags"
			Snacks.picker.select(
				{ special_config, "env_simulator_debug", "env_simulator_clang", "env_simulator_release" },
				{
					prompt = "Select config",
				},
				function(v)
					coroutine.resume(co, v)
				end
			)
			local selected_config = coroutine.yield()

			-- TODO: add picker for external repos

			local cmd = { "bazel", "build" }
			if selected_config ~= nil then
				if selected_config == special_config then
					vim.list_extend(
						cmd,
						{ "--config=env_simulator_clang", "--compilation_mode=dbg", "--cxxopt=-O0", "--strip=never" }
					)
				else
					vim.list_extend(cmd, { "--config=" .. selected_config })
				end
			end
			vim.list_extend(cmd, vim.split(vim.fn.input("Args: "), " +", { trimempty = true }))
			table.insert(cmd, "--")
			vim.list_extend(cmd, selected_targets)

			return { cmd = cmd }
		end,
		cmd = function(context)
			return context.cmd
		end,
	},
}

if string.match(vim.fn.getcwd(), ".*env_simulator.*") then
	for _, task in ipairs(M) do
		if task.dap then
			task.dap.options.cwd = ddad_path
		end
	end
end

return M
