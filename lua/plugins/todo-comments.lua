return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		signs = false,
		keywords = {
			TODO = {
				color = "hint",
			},
			NOTE = {
				color = "info",
			},
		},
		colors = {
			test = { "DiagnosticOk" },
		},
	},
}
