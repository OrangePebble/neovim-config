local env_simulator_utils = require("tasks.env_simulator.utils")
local utils = require("tasks.utils")
local picker = require("utils.picker")

local ddad_path = env_simulator_utils.ddad_path

-- Instead of manually defining a list of targets, I could automatically get a list of targets using something like:
--  `bazel query --keep_going --noshow_progress --output label '//tools/env_simulator/astas_cli/... except kind(cc_test, //tools/env_simulator/astas_cli/...) except kind(filegroup, //tools/env_simulator/astas_cli/...)' 2>/dev/null`
-- But it is hard to filter those for targets I actually care about so I'll just add to this list whenever I find one I need.
-- Get all available targets with `bazel query --keep_going //...`.
-- For all possible 'bazel query' output formats, see: https://bazel.build/query/language#output-formats
local targets = {
	"//tools/env_simulator/astas_cli:astas_cli",
	"//tools/env_simulator/modules/stochastic_cognitive_model:stochastic_cognitive_model_lib",
	-- "//third_party/open_simulation_interface:open_simulation_interface",
	-- "//tools/env_simulator/modules/stochastic_cognitive_model/tests/Core/Sensor_Tests:sensor_tests",
	-- "//tools/env_simulator/modules/stochastic_cognitive_model/tests/DriverHighway/LaneChangeBehavior_Tests:lane_change_behavior_tests",
	-- "//tools/env_simulator/astas_core/Tests/Integration/Controller:qaml_agent_integration_controlled_intersection_test",
	-- "//tools/env_simulator/astas_core/Tests/Integration/Collision:collision_integration_test",
	-- "//third_party/googletest:googletest",
}

local bazel_bin = {
	name = "Run file in ./bazel-bin",
	dap = {
		enabled = true,
		options = {
			type = "gdb",
			cwd = ddad_path,
		},
	},
	first_run_pre = function(context)
		local file_path =
			require("utils.picker").pick_file(vim.fn.getcwd() .. "/bazel-bin", "Pick a file (./bazel-bin)")
		if not file_path then
			context.failed = true
			return
		end
		local cmd = { file_path }
		vim.list_extend(cmd, utils.input_args())
		context.cmd = cmd
	end,
	run_main = function(context)
		return context.cmd
	end,
}

local build = {
	-- Inspired by https://github.com/alexander-born/cmp-bazel
	name = "Build bazel targets",
	first_run_pre = function(context)
		local co = coroutine.running()
		local selected_targets = nil
		picker.select_many(targets, {
			prompt = "Select targets",
		}, function(selected)
			selected_targets = selected
			coroutine.resume(co)
		end)
		coroutine.yield()
		if not selected_targets then
			context.failed = true
			return
		end

		local cmd = {
			"bazel",
			"build",
			"--test_env=LD_LIBRARY_PATH=/opt/astas_core/lib_deps:/opt/astas_core/plugins:/usr/lib/x86_64-linux-gnu",
		}
		local selected_config = env_simulator_utils.select_config()
		if not selected_config then
			context.failed = true
			return
		end
		vim.list_extend(cmd, selected_config)
		local selected_repositories = env_simulator_utils.select_override_repositories()
		vim.list_extend(cmd, selected_repositories)
		local extra_args = utils.input_args()
		vim.list_extend(cmd, extra_args)

		table.insert(cmd, "--")
		vim.list_extend(cmd, selected_targets)

		context.cmd = cmd
	end,
	run_main = function(context)
		return context.cmd
	end,
}

local compile_commands = {
	name = "Generate compile_commands.json",
	first_run_pre = function(context)
		local co = coroutine.running()
		local selected_targets = nil
		picker.select_many(targets, {
			prompt = "Select targets",
		}, function(selected)
			selected_targets = selected
			coroutine.resume(co)
		end)
		coroutine.yield()
		if not selected_targets then
			context.failed = true
			return
		end

		-- Use this clangd's intrinsic headers, not GCC's compiler-internal headers.
		-- Resolving the executable also follows the Nix profile symlink.
		local clangd = vim.fn.exepath("clangd")
		local clangd_path = vim.uv.fs_realpath(clangd)
		local version = clangd_path and vim.system({ clangd, "--version" }, { text = true }):wait()
		local major = version and version.code == 0 and version.stdout:match("clangd version (%d+)")
		local builtin_include = major
			and vim.fn.fnamemodify(clangd_path, ":h:h") .. "/lib/clang/" .. major .. "/include"
		if not builtin_include or vim.fn.filereadable(builtin_include .. "/xmmintrin.h") ~= 1 then
			vim.notify("Cannot locate the installed clangd's builtin headers", vim.log.levels.ERROR)
			context.failed = true
			return
		end

		context.compile_commands_path = ddad_path .. "/compile_commands.json"
		local cmd = {
			"bazel-compile-commands",
			"--arguments",
			"-o",
			context.compile_commands_path,
			"-R",
			"external/ubuntu_24_04_sysroot/usr/lib/gcc/x86_64-linux-gnu/12/include=" .. builtin_include,
		}
		local selected_config = env_simulator_utils.select_config()
		if not selected_config then
			context.failed = true
			return
		end
		for _, flag in ipairs(selected_config) do
			vim.list_extend(cmd, { "-b", flag })
		end
		local selected_repositories = env_simulator_utils.select_override_repositories()
		for _, flag in ipairs(selected_repositories) do
			vim.list_extend(cmd, { "-b", flag })
		end
		local extra_args = utils.input_args()
		for _, flag in ipairs(extra_args) do
			vim.list_extend(cmd, { "-b", flag })
		end

		vim.list_extend(cmd, selected_targets)

		context.cmd = cmd
	end,
	run_main = function(context)
		return context.cmd
	end,
	run_post = function(context)
		-- Do not touch a previous database if Bazel analysis failed.
		if not context.main_run_overseer or context.main_run_overseer.exit_code ~= 0 then
			return
		end

		local ok, err = pcall(function()
			local path = context.compile_commands_path
			local database = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
			local unsupported_flags = {
				["-fno-canonical-system-headers"] = true,
				["-ftree-loop-vectorize"] = true,
			}
			for _, entry in ipairs(database) do
				entry.arguments = vim.tbl_filter(function(flag)
					return not unsupported_flags[flag]
				end, entry.arguments)
			end
			if vim.fn.writefile({ vim.json.encode(database) }, path) ~= 0 then
				error("Could not write " .. path)
			end
		end)
		if not ok then
			context.failed = true
			vim.notify("Failed to prepare compile_commands.json for clangd: " .. tostring(err), vim.log.levels.ERROR)
			return
		end
		vim.notify("Generated clangd-compatible compile_commands.json; restart clangd to reload it")
	end,
}

---@type Task[]
local M = {}

vim.list_extend(M, require("tasks.env_simulator.e2e_tests"))
vim.list_extend(M, require("tasks.env_simulator.unit_tests"))
vim.list_extend(M, require("tasks.env_simulator.integration_tests"))
vim.list_extend(M, {
	bazel_bin,
	build,
	compile_commands,
})

return M
