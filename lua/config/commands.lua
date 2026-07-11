-- I'm leaving this here and not as a LSP buffer-local command because I ofter mistype :W and want
--  to keep the option.
local write_without_formatting = function(bang)
	if not vim.g.autoformat then
		vim.cmd.write({ bang = bang })
	else
		vim.g.autoformat = false
		vim.cmd.write({ bang = bang })
		vim.g.autoformat = true
	end
end
vim.api.nvim_create_user_command("W", function(table)
	write_without_formatting(table.bang)
end, {
	bang = true,
})
vim.api.nvim_create_user_command("Wq", function(table)
	write_without_formatting(table.bang)
	vim.cmd.quit({ bang = table.bang })
end, {
	bang = true,
})
vim.api.nvim_create_user_command("WQ", function(table)
	write_without_formatting(table.bang)
	vim.cmd.quit({ bang = table.bang })
end, {
	bang = true,
})
vim.api.nvim_create_user_command("Q", function(table)
	vim.cmd.quit({ bang = table.bang })
end, {
	bang = true,
})

-- Custom Overseer template runner so that I can use pickers with callbacks to customize the tasks.
-- Because overseer templates are syncronous and run in a C-call, I couldn't figure out how to turn
--  the callback-based picker syncronous. I tried using coroutines but those can't be used in a
--  C-call, so this is the best solution I thought of.
vim.api.nvim_create_user_command("OverseerCustomRun", function(_)
	local overseer = require("overseer")
	local overseer_template = require("overseer.template")
	local items = {}
	local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
	if string.match(cwd_name, "ddad") or string.match(cwd_name, "env_simulator") then
		vim.list_extend(items, {
			{
				-- Inspired by https://github.com/alexander-born/cmp-bazel
				name = "Build a bazel target",
				run = function()
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

					Snacks.picker.select(targets, {
						title = "Select target",
					}, function(selected_target)
						if selected_target == nil then
							return
						end
						Snacks.picker.select(
							-- TODO: add option for env_simulator_debug with clang flags so I get the best of both worlds, or clang with debug flags, whichever is easier
							-- TODO: remove F1 keymap for help
							{ "env_simulator_debug", "env_simulator_clang", "env_simulator_release" },
							{
								title = "Select config",
							},
							function(selected_config)
								local args = {}
								if selected_config ~= nil then
									vim.list_extend(args, { "--config=" .. selected_config })
								end
								vim.list_extend(args, vim.split(vim.fn.input("Args: "), " +", { trimempty = true }))
								local cmd = { "bazel", "build" }
								vim.list_extend(cmd, args)
								vim.list_extend(cmd, { "--", selected_target })
								local task = overseer.new_task({
									cmd = cmd,
									cwd = vim.fn.getcwd(),
									components = {
										{ "on_exit_set_status", "default" },
									},
								})
								task:start()
							end
						)
					end)
				end,
			},
		})
	end
	local search = {
		dir = vim.fn.getcwd(),
		filetype = vim.bo.filetype,
	}
	overseer_template.list(search, function(templates)
		vim.list_extend(
			items,
			vim.tbl_map(
				function(template)
					return {
						name = template.name,
						desc = template.desc,
						run = function()
							overseer_template.build_task(template, {
								params = {},
								search = search,
							}, function(err, task)
								if err then
									vim.notify(err, vim.log.levels.ERROR)
									return
								end
								if task then
									task:start()
								end
							end)
						end,
					}
				end,
				vim.tbl_filter(function(tmpl)
					return not tmpl.hide
				end, templates)
			)
		)

		if vim.tbl_isempty(items) then
			vim.notify("No task templates found.", vim.log.levels.WARN)
			return
		end

		Snacks.picker.select(items, {
			title = "Task template",
			format_item = function(item)
				if item.desc then
					return string.format("%s (%s)", item.name, item.desc)
				end
				return item.name
			end,
		}, function(item)
			if item then
				item.run()
			end
		end)
	end)
end, {})
