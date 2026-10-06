local picker = require("utils.picker")
local utils = require("tasks.utils")

local targets = {
	"//Core/Environment/Map/...",
}

local apply_patches = {
	name = "Apply env_simulator patches",
	cmd = function(_)
		return {
			"git",
			"apply",
			"~/projects/ddad/tools/env_simulator/modules/gt_gen_core/0001-Temporarily-remove-dependency-for-protobuf-differenc.patch",
			"~/projects/ddad/tools/env_simulator/modules/gt_gen_core/0002-Revert-refactor-Use-osi3-InterfaceVersion-to-detect-.patch",
			"~/projects/ddad/tools/env_simulator/modules/gt_gen_core/0003-revert_tpm_example_linker_script.patch",
			"~/projects/ddad/tools/env_simulator/modules/gt_gen_core/0004-remove-lane-boundary-type-structure-from-lane-shape.patch",
		}
	end,
}

local build = {
	name = "Build bazel targets",
	resolve_context = function()
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
			return nil
		end

		local cmd = {
			"bazel",
			"build",
			"--config=core",
			"--config=clang",
			"--repo_env=CC=" .. vim.fn.exepath("clang"),
			"--repo_env=CXX=" .. vim.fn.exepath("clang++"),
			"--cxxopt=-includealgorithm",
			"--features=-treat_warnings_as_errors",
			"--cxxopt=-includecstdint",
		}
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
		picker.select_many(targets, {
			prompt = "Select targets",
		}, function(selected)
			selected_targets = selected
			coroutine.resume(co)
		end)
		coroutine.yield()
		if not selected_targets then
			return nil
		end

		local cmd = {
			"bazel-compile-commands",
			"-b",
			"--config=core",
			"-b",
			"--config=clang",
			"-b",
			"--repo_env=CC=" .. vim.fn.exepath("clang"),
			"-b",
			"--repo_env=CXX=" .. vim.fn.exepath("clang++"),
			"-b",
			"--cxxopt=-includealgorithm",
			"-b",
			"--features=-treat_warnings_as_errors",
			"-b",
			"--cxxopt=-includecstdint",
		}
		local extra_args = utils.input_args(co)
		for _, flag in ipairs(extra_args) do
			vim.list_extend(cmd, { "-b", flag })
		end

		vim.list_extend(cmd, selected_targets)

		return { cmd = cmd }
	end,
	cmd = function(context)
		return context.cmd
	end,
}

---@type Task[]
return { apply_patches, build, compile_commands }
