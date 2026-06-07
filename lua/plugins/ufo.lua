return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	config = function()
		vim.o.foldcolumn = "1"
		vim.o.fillchars = "eob: ,fold: ,foldopen: ,foldsep: ,foldinner: ,foldclose:󰅂"
		-- Setting treesitter as the provider here instead of using the regular method elsewhere
		--  because this is supposedly faster and lets me manually add folds beside the treesitter
		--  ones.
		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
		})
		-- TODO: THIS DOESN'T EVEN LOOK LIKE IT WORKS DURING DIFFMODE SO I GUESS IT'S USELESS?
		--  and I should just manually change the virtual text, and figure out how to enable
		--  manual folds after the lsp/treesitter are set
		-- maybe i can even set lsp, set treesitter, then set to manual
		-- TODO: figure out why the fold column is visible during diff mode
		-- TODO: figure out how to save folds between window/buffer change and session restore

		-- TODO: figure out if I want to keep these as these seem to have different functionality
		--  I never use them so I might as well keep the defaults
		-- TODO: add the 'K' keymap in the readme
		-- TODO: set which-key icon to the 'K' keymap
		-- TODO: set which-key icons to the fold keymaps
		-- TODO: add toggles for showing whitespace characters like tab
		-- TODO: move these keymaps to the keymap file
		-- TODO: change TMUX to remove the > separator from tabs without name
		-- TODO: change fold column toggle to just change fillchars

		-- TODO: https://github.com/neovim/neovim/discussions/34246
		-- TODO: look into foldenable: https://stackoverflow.com/a/79405264
		-- TODO: add @type and @method lsp hints to places

		-- These are the default keymaps but they keep the foldlevel and use internal ufo API.
		-- If not set folds are reset on leaving and entering the buffer.
		-- vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		-- vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
		-- vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
		-- vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)

		-- vim.keymap.set("n", "K", function()
		-- 	local winid = require("ufo").peekFoldedLinesUnderCursor()
		-- 	if not winid then
		-- 		vim.lsp.buf.hover()
		-- 	end
		-- end)
	end,
}
