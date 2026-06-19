return {
	"stevearc/overseer.nvim",
	config = function()
		local overseer = require("overseer")
		---@type overseer.SetupOpts
		overseer.setup({
			task_list = {
				render = function(task)
					return require("overseer.render").format_compact(task)
				end,
				-- Make it so the list is very thin to make more space for the output.
				max_width = 5,
				min_width = 5,
				-- Changing most of the keymaps because I don't like them.
				keymaps = {
					["y"] = "",
					["s"] = { "keymap.run_action", opts = { action = "start" }, desc = "Start task" },
					["r"] = { "keymap.run_action", opts = { action = "restart" }, desc = "Restart task" },
					["c"] = { "keymap.run_action", opts = { action = "stop" }, desc = "Cancel task" },
					["w"] = { "keymap.run_action", opts = { action = "watch" }, desc = "Watch task" },
					["W"] = { "keymap.run_action", opts = { action = "unwatch" }, desc = "Unwatch task" },
					["d"] = { "keymap.run_action", opts = { action = "dispose" }, desc = "Dispose task" },
					["e"] = { "keymap.run_action", opts = { action = "edit" }, desc = "Edit task" },
					["<CR>"] = "keymap.run_action",
					["o"] = { "keymap.open", opts = { dir = "tab" }, desc = "Open task output in tab" },
					["<C-q>"] = {
						"keymap.run_action",
						opts = { action = "open output in quickfix" },
						desc = "Open task output in the quickfix",
					},
					["p"] = "keymap.toggle_preview",
					["["] = "keymap.prev_task",
					["]"] = "keymap.next_task",
					["<C-u>"] = "keymap.scroll_output_up",
					["<C-d>"] = "keymap.scroll_output_down",
					["."] = "keymap.toggle_show_wrapped",
					["q"] = { "<CMD>close<CR>", desc = "Close task list" },
					["?"] = "keymap.show_help",
					["g?"] = false,
					["g."] = false,
					["dd"] = false,
					["<C-e>"] = false,
					["<C-v>"] = false,
					["<C-s>"] = false,
					["<C-t>"] = false,
					["<C-f>"] = false,
					["{"] = false,
					["}"] = false,
					["<C-k>"] = false,
					["<C-j>"] = false,
				},
			},
			component_aliases = {
				default = {
					-- Change default to always use the custom component.
					"capture_raw_output",
					"on_exit_set_status",
					"on_complete_notify",
					{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
				},
			},
		})
	end,
}
