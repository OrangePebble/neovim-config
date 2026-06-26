return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	config = function()
		require("markview").setup({
			markdown = {
				-- Inspired by the glow preset.
				headings = {
					enable = true,
					shift_width = 0,
					heading_1 = {
						style = "label",
						sign = "",
						padding_left = " ",
						padding_right = " ",
					},
					heading_2 = {
						style = "label",
						sign = "",
						padding_left = "   ",
						padding_right = " ",
					},
					heading_3 = {
						style = "label",
						padding_left = "     ",
						padding_right = " ",
					},
					heading_4 = {
						style = "label",
						padding_left = "       ",
						padding_right = " ",
					},
					heading_5 = {
						style = "label",
						padding_left = "         ",
						padding_right = " ",
					},
					heading_6 = {
						style = "label",
						padding_left = "           ",
						padding_right = " ",
					},
					setext_1 = {
						sign = "",
					},
					setext_2 = {
						sign = "",
					},
				},
				code_blocks = {
					sign = false,
				},
			},
			preview = {
				-- Makes it so the line under the cursor displays the raw text in normal mode.
				hybrid_modes = { "n" },
				icon_provider = "mini",
			},
		})
		-- Fixes the weird rendering when I open Neovim on a file that was closed with Markview disabled.
		-- This doesn't fix the same weird rendering when I: disable Markview, change buffer, enable
		--  Markview, return to the markdown buffer; but its better than before.
		vim.api.nvim_create_autocmd("User", {
			pattern = "MarkviewAttach",
			callback = function(event)
				vim.cmd("Markview Toggle")
				vim.defer_fn(function()
					vim.cmd("Markview Toggle")
				end, 0)
			end,
		})
	end,
}
