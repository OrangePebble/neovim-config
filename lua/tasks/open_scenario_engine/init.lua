local picker = require("utils.picker")
local utils = require("tasks.utils")

-- The repository root contains the Bazel workspace in its engine/ subdirectory.
-- Also support opening Neovim directly from that workspace.
local bazel_workspace = vim.fn.getcwd()
if vim.fn.filereadable(bazel_workspace .. "/MODULE.bazel") == 0 then
	bazel_workspace = bazel_workspace .. "/engine"
end

local targets = {
	"//:open_scenario_engine",
}

local build = {
	name = "Build bazel targets",
	overseer = {
		options = {
			cwd = bazel_workspace,
		},
	},
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
			"--config=ose",
			"--config=ose_clang",
			-- open_scenario_parser omits this required standard header.
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
	overseer = {
		options = {
			cwd = bazel_workspace,
		},
	},
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
			"--config=ose",
			"-b",
			"--config=ose_clang",
			-- open_scenario_parser omits this required standard header.
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
return { build, compile_commands }
