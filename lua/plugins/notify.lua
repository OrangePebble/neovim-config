return {
	-- Prettier notifications.
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({
				render = "wrapped-compact",
			})
			-- Set this plugin as the default notification handler
			vim.notify = require("notify")
		end,
	},
	-- Prettier progress handler (for things like LSP/DAP progress).
	-- I could've integrated LSP progress with 'nvim-notify' instead by using 'nvim-lsp_notify' but
	--  that leaves an ugly debug notification in the history, and DAP progress with some manual
	--  configuration but I might not want progress to polute notification history.
	{
		"j-hui/fidget.nvim",
		opts = {},
	},
}
