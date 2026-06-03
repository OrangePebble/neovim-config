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
					local MiniNotify = require("mini.notify")
					local id = MiniNotify.add("Press <F1> for fzf-lua keymaps.", "INFO")
					vim.defer_fn(function()
						MiniNotify.remove(id)
					end, 3000)
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
