return {
	{
		"EdenEast/nightfox.nvim",
		lazy = false, -- Don't lazy load.
		priority = 999, -- One of the first to be loaded.
		config = function()
			require("nightfox").setup({
				groups = {
					carbonfox = {
						WinSeparator = { fg = "palette.bg0", bg = "palette.bg0" },
					},
				},
				palettes = {
					carbonfox = {
						-- terafox orange and nordfox yellow because in carbonfox they are cyan
						yellow = "#ebcb8b",
						orange = "#ff8349",
					},
				},
			})
			vim.cmd("colorscheme carbonfox")
		end,
	},
	{
		"xiyaowong/nvim-transparent",
		lazy = false,
		priority = 999,
	},
	-- Other cool themes:
	"rebelot/kanagawa.nvim",
	"folke/tokyonight.nvim",
	"tiagovla/tokyodark.nvim",
	"Shatur/neovim-ayu",
	"Mofiqul/vscode.nvim",
	{ "catppuccin/nvim", name = "catppuccin" },
	{ "rose-pine/neovim", name = "rose-pine" },
}
