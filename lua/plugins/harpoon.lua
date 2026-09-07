return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({})

		--- Make it so the first 8 lines have the keymap key as the line number
		vim.g.harpoon_statuscolumn_keys = { "j", "k", "l", ";", "m", ",", ".", "/" }
		harpoon:extend({
			UI_CREATE = function(ctx)
				vim.api.nvim_set_option_value("number", false, { win = ctx.win_id })
				vim.api.nvim_set_option_value(
					"statuscolumn",
					"%{get(g:harpoon_statuscolumn_keys, v:lnum - 1, &rnu && v:relnum ? v:relnum : v:lnum)} ",
					{
						win = ctx.win_id,
					}
				)
			end,
		})
	end,
}
