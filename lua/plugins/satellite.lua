-- Scrollbar.
-- Other good options are:
-- - https://github.com/dstein64/nvim-scrollview
-- - https://github.com/petertriho/nvim-scrollbar
return {
	"lewis6991/satellite.nvim",
	config = function()
		vim.api.nvim_set_hl(0, "SatelliteBar", { bg = "Gray" })
		require("satellite").setup({
			current_only = true,
			winblend = 60,
			handlers = {
				cursor = { enable = false },
				gitsigns = {
					overlap = true,
					signs = {
						delete = "│",
					},
				},
			},
		})
		vim.g.satellite = true
	end,
}
