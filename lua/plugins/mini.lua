-- Library of 40+ independent Lua modules.
return {
	-- Improve selection of 'inside' or 'around' objects.
	{ "echasnovski/mini.ai", version = "*", opts = {} },
	-- Improved commenting.
	{ "echasnovski/mini.comment", version = "*", opts = {} },
	-- Move text using Ctrl.
	{
		"echasnovski/mini.move",
		version = "*",
		opts = {
			mappings = {
				-- Original mappings use Alt, but because TMUX doesn't support C-S-* to resize windows, I've
				--  changed this to Ctrl, and window mappings to Alt.
				left = "<C-h>",
				right = "<C-l>",
				down = "<C-j>",
				up = "<C-k>",
				line_left = "<C-h>",
				line_right = "<C-l>",
				line_down = "<C-j>",
				line_up = "<C-k>",
			},
		},
	},
	-- Add, delete, replace, find, highlight surrounding (like pair of parenthesis, quotes, etc.).
	{ "echasnovski/mini.surround", version = "*", opts = {} },
	-- Autohighlight word under cursor.
	{
		"echasnovski/mini.cursorword",
		version = "*",
		config = function()
			vim.g.minicursorword_disable = true
			require("mini.cursorword").setup()
		end,
	},
	-- Highlight trailing whitespace.
	{ "echasnovski/mini.trailspace", version = "*", opts = {} },
	-- Buffer removing (unshow, delete, wipeout), which saves window layout.
	{ "echasnovski/mini.bufremove", version = "*", opts = {} },
	-- Icons for other plugins + colors for which-key.
	{
		"echasnovski/mini.icons",
		version = "*",
		opts = {},
		config = function()
			-- To add icons to nvim-tree.
			require("mini.icons").mock_nvim_web_devicons()
		end,
	},
}
