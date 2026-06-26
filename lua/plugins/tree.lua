-- A file explorer tree.

return {
	"nvim-tree/nvim-tree.lua",
	lazy = false,
	dependencies = { "echasnovski/mini.icons" },
	config = function()
		-- Remove background color from the NvimTree window (ui fix)
		-- vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])

		require("nvim-tree").setup({
			filters = {
				dotfiles = false, -- Show hidden files (dotfiles)
				git_ignored = false, -- Show files in .gitignore. Hide them with 'I'.
			},
			renderer = {
				root_folder_label = function()
					return ".."
				end,
				icons = {
					git_placement = "signcolumn",
					glyphs = {
						git = {
							untracked = "󰎜",
							unstaged = "",
							staged = "󰄬",
							deleted = "󰆴",
							renamed = "󰑕",
						},
					},
				},
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end
				-- Use default mappings.
				api.map.on_attach.default(bufnr)
				-- Make '?' open help.
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
			end,
		})
	end,
}
