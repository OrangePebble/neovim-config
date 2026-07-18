-- A file explorer tree.
return {
	"nvim-tree/nvim-tree.lua",
	lazy = false,
	dependencies = {
		"echasnovski/mini.icons",
		-- Adds file operation support to LSPs.
		-- Has to be loaded after nvim-tree.
		-- snacks.nvim has an equivalent feature but it doesn't work as well.
		"Crysthamus/nvim-file-operations",
	},
	config = function()
		-- Remove background color from the NvimTree window (ui fix)
		-- vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])

		require("nvim-tree").setup({
			update_focused_file = {
				enable = true,
			},
			view = {
				signcolumn = "no",
			},
			filters = {
				dotfiles = false, -- Show hidden files (dotfiles)
				git_ignored = false, -- Show files in .gitignore. Hide them with 'I'.
			},
			renderer = {
				root_folder_label = function()
					return ".."
				end,
				icons = {
					git_placement = "right_align",
					bookmarks_placement = "right_align",
					diagnostics_placement = "right_align",
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
			actions = {
				open_file = {
					resize_window = false,
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

		-- Save if nvim-tree is open for use elsewhere like lualine.
		vim.g.nvim_tree_open = false
		local api = require("nvim-tree.api")
		local Event = api.events.Event
		api.events.subscribe(Event.TreeOpen, function(data)
			vim.g.nvim_tree_open = true
		end)
		api.events.subscribe(Event.TreeClose, function(data)
			vim.g.nvim_tree_open = false
		end)

		require("nvim-file-operations").setup()
	end,
}
