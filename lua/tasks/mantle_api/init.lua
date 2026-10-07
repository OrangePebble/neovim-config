local picker = require("utils.picker")
local utils = require("tasks.utils")

local targets = {
	"//:mantle_api",
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
			"--config=mantle_api",
			"--config=mantle_api_clang",
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
	name = "Generate compile_commands.json (all targets)",
	resolve_context = function()
		local co = coroutine.running()
		local cmd = {
			"bazel-compile-commands",
			"-b",
			"--config=mantle_api",
			"-b",
			"--config=mantle_api_clang",
		}
		local extra_args = utils.input_args(co)
		for _, flag in ipairs(extra_args) do
			vim.list_extend(cmd, { "-b", flag })
		end

		-- Headers do not have Bazel compile actions. Generate commands for every
		-- source target so clangd can infer a command for the header being edited.
		table.insert(cmd, "//...")

		return { cmd = cmd }
	end,
	cmd = function(context)
		return context.cmd
	end,
}

---@type Task[]
return { build, compile_commands }

