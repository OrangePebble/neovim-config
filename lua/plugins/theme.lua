return {
	{
		"rktjmp/lush.nvim",
		init = function()
			vim.cmd("colorscheme custom")
		end,
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false, -- Don't lazy load.
		priority = 999, -- One of the first to be loaded.
		config = function()
			require("nightfox").setup({
				groups = {
					all = {
						WinSeparator = { fg = "palette.bg0", bg = "palette.bg0" },
					},
				},
				palettes = {
					carbonfox = {
						-- terafox orange and nordfox yellow because in carbonfox they are cyan
						yellow = "#ebcb8b",
						orange = "#ff8349",
					},
					custom = {
						-- terafox orange and nordfox yellow because in carbonfox they are cyan
						yellow = "#ebcb8b",
						orange = "#ff8349",
					},
				},
			})
		end,
	},
	-- {
	-- 	"xiyaowong/nvim-transparent",
	-- 	lazy = false,
	-- 	priority = 999,
	-- },
	-- -- Other cool themes:
	-- "rebelot/kanagawa.nvim",
	-- "folke/tokyonight.nvim",
	-- "tiagovla/tokyodark.nvim",
	-- "Shatur/neovim-ayu",
	-- "Mofiqul/vscode.nvim",
	-- { "catppuccin/nvim", name = "catppuccin" },
	-- { "rose-pine/neovim", name = "rose-pine" },
}
