-- Better number/sign/fold column.
-- Adds more customization and click handlers.
return {
	"luukvbaal/statuscol.nvim",
	config = function()
		vim.opt.numberwidth = 3
		local ft_buft = require("utils.ft_buft")
		local builtin = require("statuscol.builtin")
		require("statuscol").setup({
			relculright = true,
			segments = {
				{ text = { "%s" }, click = "v:lua.ScSa" },
				{ text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
				{
					text = { " " },
					condition = {
						function(args)
							return builtin.not_empty(args) and vim.opt.foldcolumn._value == "0"
						end,
					},
					click = "v:lua.ScLa",
				},
				{ text = { "%C" }, click = "v:lua.ScSa" },
			},
			clickhandlers = {
				Lnum = builtin.gitsigns_click,
			},
			ft_ignore = ft_buft.special_filetypes,
			bt_ignore = ft_buft.special_buftypes,
		})
	end,
}
