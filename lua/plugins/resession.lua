return {
	"stevearc/resession.nvim",
	config = function()
		local resession = require("resession")
		resession.setup({
			extensions = {
				overseer = {
					autostart_on_load = false,
				},
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

		-- Autosave every 5mins. The plugin has an autosave included but the notifications are saved
		--  in history.
		local function autosave()
			vim.defer_fn(function()
				resession.save(vim.fn.getcwd(), { notify = false })
				vim.notify(string.format('Saved session "%s"', vim.fn.getcwd()), "INFO", { hide_from_history = true })
				autosave()
			end, 300000)
		end
		autosave()
	end,
}
