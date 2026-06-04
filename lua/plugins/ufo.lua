return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	config = function()
		vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"
		-- Setting treesitter as the provider here instead of using the regular method elsewhere
		--  because this is supposedly faster and lets me manually add folds beside the treesitter
		--  ones.
		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
		})
		-- TODO: figure out if I want to keep these as these seem to have different functionality
		--  I never use them so I might as well keep the defaults
		-- TODO: add the 'K' keymap in the readme
		-- TODO: set which-key icon to the 'K' keymap
		-- TODO: set which-key icons to the fold keymaps

		-- These are the default keymaps but they keep the foldlevel and use internal ufo API.
		-- If not set folds are reset on leaving and entering the buffer.
		-- vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		-- vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
		-- vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
		-- vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)

		vim.keymap.set("n", "K", function()
			local winid = require("ufo").peekFoldedLinesUnderCursor()
			if not winid then
				vim.lsp.buf.hover()
			end
		end)
	end,
}
