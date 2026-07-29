local utils = require("tasks.env_simulator.utils")

local ddad_path = utils.ddad_path

-- Instead of manually defining a list of targets, I could automatically get a list of targets using something like:
--  `bazel query --keep_going --noshow_progress --output label '//tools/env_simulator/astas_cli/... except kind(cc_test, //tools/env_simulator/astas_cli/...) except kind(filegroup, //tools/env_simulator/astas_cli/...)' 2>/dev/null`
-- But it is hard to filter those for targets I actually care about so I'll just add to this list whenever I find one I need.
-- Get all available targets with `bazel query --keep_going //...`.
-- For all possible 'bazel query' output formats, see: https://bazel.build/query/language#output-formats
local targets = {
	"//tools/env_simulator/astas_cli:astas_cli",
	"//tools/env_simulator/modules/stochastic_cognitive_model:create_fmu_zip",
	-- "//third_party/open_simulation_interface:open_simulation_interface",
	-- "//tools/env_simulator/modules/stochastic_cognitive_model:stochastic_cognitive_model_lib",
	-- "//tools/env_simulator/modules/stochastic_cognitive_model/tests/Core/Sensor_Tests:sensor_tests",
	-- "//third_party/googletest:googletest",
}

local bazel_bin = {
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
		local co = coroutine.running()
		local args = utils.input_args(co)
		vim.list_extend(cmd, args)
		return { cmd = cmd }
	end,
	cmd = function(context)
		return context.cmd
	end,
}

local build = {
	-- Inspired by https://github.com/alexander-born/cmp-bazel
	name = "Build bazel targets",
	resolve_context = function()
		local co = coroutine.running()
		local selected_targets = nil
		Snacks.picker.select(targets, {
			prompt = "Select targets",
			snacks = {
				actions = {
					confirm = function(picker, _)
						local selected = picker:selected({ fallback = true })
						selected_targets = vim.tbl_map(function(entry)
							return entry.item
						end, selected)
						picker:close()
					end,
				},
			},
		}, function()
			coroutine.resume(co)
		end)
		coroutine.yield()
		if not selected_targets then
			return nil
		end

		local cmd = { "bazel", "build" }
		local selected_config = utils.select_config(co)
		vim.list_extend(cmd, selected_config)
		local selected_repositories = utils.select_override_repositories(co)
		vim.list_extend(cmd, selected_repositories)
		local extra_args = utils.input_args(co)
		vim.list_extend(cmd, extra_args)

		table.insert(cmd, "--")
		vim.list_extend(cmd, selected_targets)

		return { cmd = cmd }
	end,
	cmd = function(context)
		return context.cmd
	end,
}

local compile_commands = {
	name = "Generate compile_commands.json",
	resolve_context = function()
		local co = coroutine.running()
		local selected_targets = nil
		Snacks.picker.select(targets, {
			prompt = "Select targets",
			snacks = {
				actions = {
					confirm = function(picker, _)
						local selected = picker:selected({ fallback = true })
						selected_targets = vim.tbl_map(function(entry)
							return entry.item
						end, selected)
						picker:close()
					end,
				},
			},
		}, function()
			coroutine.resume(co)
		end)
		coroutine.yield()
		if not selected_targets then
			return nil
		end

		local cmd = { "bazel-compile-commands" }
		local selected_config = utils.select_config(co)
		for _, flag in ipairs(selected_config) do
			vim.list_extend(cmd, { "-b", '"' .. flag .. '"' })
		end
		local selected_repositories = utils.select_override_repositories(co)
		for _, flag in ipairs(selected_repositories) do
			vim.list_extend(cmd, { "-b", '"' .. flag .. '"' })
		end
		local extra_args = utils.input_args(co)
		for _, flag in ipairs(extra_args) do
			vim.list_extend(cmd, { "-b", '"' .. flag .. '"' })
		end

		vim.list_extend(cmd, selected_targets)

		return { cmd = cmd }
	end,
	cmd = function(context)
		return context.cmd
	end,
}

---@type Task[]
local M = {
	bazel_bin,
	build,
	compile_commands,
}

vim.list_extend(M, require("tasks.env_simulator.e2e_tests"))

if string.match(vim.fn.getcwd(), ".*env_simulator.*") then
	for _, task in ipairs(M) do
		if task.dap then
			task.dap.options.cwd = ddad_path
		end
	end
end

return M
