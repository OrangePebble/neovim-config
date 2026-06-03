return {
	"stevearc/resession.nvim",
	config = function()
		local resession = require("resession")
		resession.setup({
			autosave = {
				enabled = true,
				interval = 300, -- seconds
				notify = true,
			},
			extensions = {
				overseer = {},
				alternate = {},
			},
		})

		-- Load a dir-specific session when you open Neovim, save it when you exit.
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				-- Only load the session if nvim was started with no args and without reading from stdin
				if vim.fn.argc(-1) == 0 and not vim.g.using_stdin then
					-- Save these to a different directory, so our manual sessions don't get polluted
					resession.load(vim.fn.getcwd(), { silence_errors = true })
				end
			end,
			nested = true,
		})
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				resession.save(vim.fn.getcwd(), { notify = false })
			end,
		})
		vim.api.nvim_create_autocmd("StdinReadPre", {
			callback = function()
				-- Store this for later
				vim.g.using_stdin = true
			end,
		})
	end,
}
