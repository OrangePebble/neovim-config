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
