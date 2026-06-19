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
		-- TODO: Improve/Remove keymaps inside the task list
		-- TODO: Make LSP's code action picker show a preview
	end,
}
