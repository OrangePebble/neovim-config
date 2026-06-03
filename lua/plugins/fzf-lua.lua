-- fzf wrapper (like telescope but faster).
return {
	"ibhagwan/fzf-lua",
	lazy = false,
	dependencies = { "echasnovski/mini.icons" },
	config = function()
		local FzfLua = require("fzf-lua")
		FzfLua.setup({
			defaults = {
				-- copen = false,
			},
			winopts = {
				on_create = function()
					-- Delay for half a second so the notification appears above the fzf-lua popup.
					vim.defer_fn(function()
						vim.notify("Press <F1> for fzf-lua keymaps.", "INFO", { hide_from_history = true })
					end, 500)
				end,
			},
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
				-- These are actions native to fzf, run `man fzf` to find out more.
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
		})
		FzfLua.register_ui_select()
	end,
}
