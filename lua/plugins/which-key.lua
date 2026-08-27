-- Display keybindings as you type.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		vim.opt.timeoutlen = 0 -- Works better with this plugin

		-- See "map-modes" help section for available modes.

		-- Find default icons and colors on: https://github.com/folke/which-key.nvim/blob/main/lua/which-key/icons.lua
		-- Find keymaps set by default on: https://github.com/folke/which-key.nvim/blob/main/lua/which-key/plugins/presets.lua
		-- Find more icons on: https://www.nerdfonts.com/cheat-sheet
		-- Available colors (https://github.com/folke/which-key.nvim#-colors):
		--  - azure
		--  - blue
		--  - cyan
		--  - green
		--  - grey
		--  - orange
		--  - purple
		--  - red
		--  - yellow
		-- This are the loose rules I have for colors:
		--  Purple is for misc because it's the default.
		--  Blue is for searching.
		--  Green is for showing/selecting/opening.
		--  Red is for diagnostics/debugging/testing.
		--  Yellow is for toggling.
		--  Grey is for action.
		--  Cyan is for LSP and related things.

		local which_key = require("which-key")
		which_key.setup({
			preset = "modern",
			delay = 0,
		})

		which_key.add({
			{ "<leader>+", group = "Extras", icon = "" },
			{ "<leader>y", mode = { "n", "x" }, icon = { icon = "󰆏", color = "grey" } },
			{ "<leader>Y", icon = { icon = "󰆏", color = "grey" } },
			{ "<leader>p", mode = { "n", "x" }, icon = { icon = "󰆒", color = "grey" } },
			{ "<leader>P", icon = { icon = "󰆒", color = "grey" } },
			{ "<leader>u", icon = { icon = "", color = "yellow" } },
			{ "<leader>e", icon = { icon = "", color = "yellow" } },
			{ "<leader>d", mode = "x", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>%", icon = { icon = "󰈔", color = "grey" } },
			{ "]t", icon = { icon = "󰷐", color = "grey" } },
			{ "[t", icon = { icon = "󰷐", color = "grey" } },
		})

		-- which-key
		which_key.add({
			{ "<leader>?l", icon = "󰈔" },
			{ "<leader>?g", icon = "" },
			{ "<leader>?", group = "Keymaps (which-key)", icon = "󰥻" },
		})

		-- Native new descriptions and icons
		which_key.add({
			{ "]b", desc = "Next buffer", icon = { icon = "", color = "green" } },
			{ "]B", desc = "Last buffer", icon = { icon = "", color = "green" } },
			{ "[b", desc = "Previous buffer", icon = { icon = "", color = "green" } },
			{ "[B", desc = "First buffer", icon = { icon = "", color = "green" } },
			{ "]q", desc = "Next quickfix", icon = { icon = "󰺧", color = "grey" } },
			{ "]Q", desc = "Last quickfix", icon = { icon = "󰺧", color = "grey" } },
			{ "[q", desc = "Previous quickfix", icon = { icon = "󰺧", color = "grey" } },
			{ "[Q", desc = "First quickfix", icon = { icon = "󰺧", color = "grey" } },
			{ "]l", desc = "Next location-list", icon = "󰺧" },
			{ "]L", desc = "Last location-list", icon = "󰺧" },
			{ "[l", desc = "Previous location-list", icon = "󰺧" },
			{ "[L", desc = "First location-list", icon = "󰺧" },
			{ "]a", desc = "Next file in args", icon = { icon = "󰈔", color = "green" } },
			{ "]A", desc = "Last file in args", icon = { icon = "󰈔", color = "green" } },
			{ "[a", desc = "Previous file in args", icon = { icon = "󰈔", color = "green" } },
			{ "[A", desc = "First file in args", icon = { icon = "󰈔", color = "green" } },
			{ "]s", desc = "Next misspelled word", icon = { icon = "󰓆", color = "orange" } },
			{ "[s", desc = "Previous misspelled word", icon = { icon = "󰓆", color = "orange" } },
			{ "]x", icon = { icon = "󱖫", color = "red" } },
			{ "]X", icon = { icon = "󱖫", color = "red" } },
			{ "[x", icon = { icon = "󱖫", color = "red" } },
			{ "[X", icon = { icon = "󱖫", color = "red" } },
			{ "]c", icon = { icon = "", color = "orange" } },
			{ "[c", icon = { icon = "", color = "orange" } },
			{
				mode = { "n", "x", "o" },
				{ "]m", desc = "Next method start", icon = { icon = "", color = "cyan" } },
				{ "]M", desc = "Next method end", icon = { icon = "", color = "cyan" } },
				{ "[m", desc = "Previous method start", icon = "" },
				{ "[M", desc = "Previous method end", icon = "" },
				{ "](", desc = "(", icon = "" },
				{ "]<", desc = "<", icon = "" },
				{ "]{", desc = "{", icon = "" },
				{ "[(", desc = "(", icon = "" },
				{ "[<", desc = "<", icon = "" },
				{ "[{", desc = "{", icon = "" },
			},
		})

		-- Toggle icons.
		which_key.add({
			{ "<leader>t", group = "Toggle" },
			{ "<leader>tt", icon = { icon = "󰷐", color = "yellow" } },
			{ "<leader>tu", icon = { icon = "", color = "orange" } },
			{ "<leader>tm", icon = { icon = "󰍔", color = "grey" } },
			{ "<leader>tM", icon = { icon = "󰍔", color = "grey" } },
			{ "<leader>tw", icon = { icon = "", color = "grey" } },
			{ "<leader>tq", icon = { icon = "󰺧", color = "yellow" } },
			{ "<leader>te", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>td", icon = { icon = "󰉄", color = "grey" } },
			{ "<leader>tr", icon = { icon = "󰉻", color = "grey" } },
			{ "<leader>tn", icon = { icon = "󰉻", color = "grey" } },
			{ "<leader>th", icon = { icon = "", color = "grey" } },
			{ "<leader>tc", icon = { icon = "󰏘", color = "grey" } },
			{ "<leader>tC", icon = { icon = "󰉾", color = "grey" } },
			{ "<leader>tf", icon = { icon = "", color = "grey" } },
			{ "<leader>ts", icon = { icon = "", color = "grey" } },
			{ "<leader>tW", icon = { icon = "󱁐", color = "grey" } },
			{ "<leader>ti", icon = { icon = "󰉶", color = "grey" } },
			{ "<leader>tb", icon = { icon = "󱕒", color = "grey" } },
		})

		-- LSP icons.
		which_key.add({
			{ "<leader>l", group = "LSP", icon = { icon = "󰰍", color = "cyan" } },
			{ "<leader>ls", icon = { icon = "", color = "green" } },
			{ "<leader>lS", icon = { icon = "", color = "green" } },
			{ "<leader>lR", icon = { icon = "", color = "cyan" } },
			{ "<leader>lr", icon = { icon = "󰑕", color = "grey" } },
			{ "<leader>lT", icon = { icon = "", color = "cyan" } },
			{ "<leader>li", icon = { icon = "", color = "cyan" } },
			{ "<leader>ld", icon = { icon = "", color = "cyan" } },
			{ "<leader>lD", icon = { icon = "󱍟", color = "cyan" } },
			{ "<leader>la", icon = { icon = "", color = "grey" } },
			{ "<leader>lo", icon = { icon = "󰋺", color = "grey" } },
			{ "<leader>lt", group = "Toggle" },
			{ "<leader>lts", icon = { icon = "", color = "yellow" } },
			{ "<leader>lth", icon = { icon = "󰫧", color = "yellow" } },
			{ "<leader>ltl", icon = { icon = "󰰍", color = "yellow" } },
		})

		-- Diagnostic icons.
		which_key.add({
			{ "<leader>x", group = "Diagnostics", icon = { icon = "󱖫", color = "red" } },
			{ "<leader>xc", icon = { icon = "󰗧", color = "red" } },
			{ "<leader>xl", icon = { icon = "", color = "red" } },
			{ "<leader>xd", icon = { icon = "󰈞", color = "blue" } },
			{ "<leader>xw", icon = { icon = "", color = "blue" } },
			{ "<leader>xt", group = "Toggle" },
			{ "<leader>xtv", icon = { icon = "󱖫", color = "yellow" } },
			{ "<leader>xtd", icon = { icon = "󰈔", color = "yellow" } },
			{ "<leader>xtw", icon = { icon = "", color = "yellow" } },
		})

		-- DAP icons.
		which_key.add({
			{ "<leader>d", group = "Debug" },
			{ "<leader>db", icon = { icon = "", color = "orange" } },
			{ "<leader>dB", icon = { icon = "", color = "orange" } },
			{ "<leader>dr", icon = { icon = "", color = "green" } },
			{ "<leader>dl", icon = { icon = "", color = "green" } },
			{ "<leader>dc", icon = { icon = "", color = "green" } },
			{ "<leader>dC", icon = { icon = "", color = "green" } },
			{ "<leader>dp", icon = { icon = "", color = "orange" } },
			{ "<leader>dq", icon = { icon = "", color = "red" } },
			{ "<leader>dg", icon = { icon = "", color = "grey" } },
			{ "<leader>dj", icon = { icon = "󰄠", color = "grey" } },
			{ "<leader>dk", icon = { icon = "󰄝", color = "grey" } },
			{ "]d", icon = { icon = "", color = "red" } },
			{ "]D", icon = { icon = "", color = "red" } },
			{ "[d", icon = { icon = "", color = "red" } },
			{ "[D", icon = { icon = "", color = "red" } },
			{ "<leader>ds", icon = { icon = "", color = "grey" } },
			{ "<leader>di", icon = { icon = "", color = "grey" } },
			{ "<leader>dS", icon = { icon = "", color = "grey" } },
			{ "<leader>dI", icon = { icon = "", color = "grey" } },
			{ "<leader>dw", icon = { icon = "", color = "azure" } },
			{ "<leader>de", icon = { icon = "", color = "azure" } },
			{ "<leader>dt", icon = { icon = "󰙵", color = "yellow" } },
			{ "<leader>dT", group = "Toggle" },
			{ "<leader>dTr", icon = { icon = "", color = "yellow" } },
			{ "<leader>dTv", icon = { icon = "󰫧", color = "yellow" } },
		})

		-- Git
		which_key.add({
			{ "<leader>g", mode = { "n", "x" }, group = "Git" },
			{ "<leader>gt", group = "Toggle" },
			{ "<leader>gb", icon = { icon = "", color = "orange" } },
			{ "<leader>gp", icon = { icon = "󰈈", color = "yellow" } },
			{ "<leader>gd", icon = { icon = "", color = "yellow" } },
			{ "<leader>gD", icon = { icon = "", color = "yellow" } },
			{ "<leader>g]", icon = { icon = "󰁅", color = "grey" } },
			{ "<leader>g}", icon = { icon = "󰞒", color = "grey" } },
			{ "<leader>g[", icon = { icon = "󰁝", color = "grey" } },
			{ "<leader>g{", icon = { icon = "󰞕", color = "grey" } },
			{ "<leader>gr", mode = { "n", "x" }, icon = { icon = "󰆴", color = "red" } },
			{ "<leader>gR", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>gs", mode = { "n", "x" }, icon = { icon = "", color = "green" } },
			{ "<leader>gS", icon = { icon = "", color = "green" } },
			{ "<leader>gu", icon = { icon = "", color = "orange" } },
			{ "<leader>gtb", icon = { icon = "", color = "orange" } },
			{ "<leader>gtB", icon = { icon = "", color = "orange" } },
			{ "<leader>gts", icon = { icon = "", color = "green" } },
			{ "<leader>gtl", icon = { icon = "󰸱", color = "yellow" } },
			{ "<leader>gtn", icon = { icon = "󰉻", color = "yellow" } },
			{ "<leader>gtw", icon = { icon = "", color = "yellow" } },
			{ "<leader>gtd", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>gl", icon = { icon = "󰋣", color = "grey" } },
			{ "<leader>go", icon = { icon = "󰖟", color = "grey" } },
		})

		-- Search
		which_key.add({
			{ "<leader>s", mode = { "n", "x" }, group = "Search", icon = { icon = "", color = "blue" } },
			{ "<leader>st", icon = { icon = "󰷐", color = "yellow" } },
			{ "<leader>sf", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>sF", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>sc", icon = "" },
			{ "<leader>sg", icon = { icon = "󰈞", color = "blue" } },
			{ "<leader>s/", icon = { icon = "󰈞", color = "blue" } },
			{ "<leader>sw", mode = { "n", "x" }, icon = { icon = "󰈞", color = "blue" } },
			{ "<leader>sh", icon = { icon = "󰞋", color = "grey" } },
			{ "<leader>sN", icon = { icon = "", color = "grey" } },
			{ "<leader>sR", icon = "" },
			{ "<leader>sr", icon = { icon = "", color = "green" } },
			{ "<leader>sb", icon = { icon = "", color = "green" } },
			{ "<leader>sH", icon = "" },
			{ "<leader>sq", icon = { icon = "󰺧", color = "yellow" } },
			{ "<leader>ss", icon = "" },
			{ "<leader>sn", icon = { icon = "󰵅", color = "grey" } },
		})

		which_key.add({
			-- Window
			{ "<leader>w", group = "Window", icon = { icon = "", color = "grey" } },
			{ "<leader>w\\", icon = { icon = "", color = "orange" } },
			{ "<leader>w-", icon = { icon = "", color = "orange" } },
			{ "<leader>wh", icon = { icon = "󱂪", color = "grey" } },
			{ "<A-h>", icon = { icon = "󱂪", color = "grey" } },
			{ "<leader>wj", icon = { icon = "󱂩", color = "grey" } },
			{ "<A-j>", icon = { icon = "󱂩", color = "grey" } },
			{ "<leader>wk", icon = { icon = "󱔓", color = "grey" } },
			{ "<A-k>", icon = { icon = "󱔓", color = "grey" } },
			{ "<leader>wl", icon = { icon = "󱂫", color = "grey" } },
			{ "<A-l>", icon = { icon = "󱂫", color = "grey" } },
			{ "<leader>w;", icon = { icon = "󰮳", color = "grey" } },
			{ "<leader>wH", icon = { icon = "", color = "yellow" } },
			{ "<A-H>", icon = { icon = "", color = "yellow" } },
			{ "<leader>wJ", icon = { icon = "", color = "yellow" } },
			{ "<A-J>", icon = { icon = "", color = "yellow" } },
			{ "<leader>wK", icon = { icon = "", color = "yellow" } },
			{ "<A-K>", icon = { icon = "", color = "yellow" } },
			{ "<leader>wL", icon = { icon = "", color = "yellow" } },
			{ "<A-L>", icon = { icon = "", color = "yellow" } },
			{ "<leader>w<C-h>", icon = { icon = "󰧙", color = "orange" } },
			{ "<A-C-h>", icon = { icon = "󰧙", color = "orange" } },
			{ "<leader>w<C-j>", icon = { icon = "󰧗", color = "orange" } },
			{ "<A-C-j>", icon = { icon = "󰧗", color = "orange" } },
			{ "<leader>w<C-k>", icon = { icon = "󰧝", color = "orange" } },
			{ "<A-C-k>", icon = { icon = "󰧝", color = "orange" } },
			{ "<leader>w<C-l>", icon = { icon = "󰧛", color = "orange" } },
			{ "<A-C-l>", icon = { icon = "󰧛", color = "orange" } },
			{ "<leader>w|", icon = { icon = "󰡎", color = "yellow" } },
			{ "<leader>w_", icon = { icon = "󰡏", color = "yellow" } },
			{ "<leader>w=", icon = { icon = "󰁌", color = "yellow" } },
			{ "<leader>wq", icon = { icon = "󰅗", color = "red" } },
			{ "<leader>wo", icon = { icon = "󰱝", color = "red" } },
			{ "<leader>ww", icon = "" },
			{ "<leader>w<space>", icon = "󰑖" },
			{ "<C-w><space>", icon = "󰑖" },
		})

		-- harpoon
		which_key.add({
			{ "<leader><leader>", group = "Harpoon", icon = { icon = "󱡅", color = "green" } },
			{ "<leader><leader>a", icon = { icon = "", color = "grey" } },
			{ "<leader><leader>p", icon = { icon = "󰍠", color = "green" } },
			{ "<leader><leader>n", icon = { icon = "󰍝", color = "green" } },
			{ "<leader><leader><leader>", icon = { icon = "", color = "blue" } },
		})

		-- Resession
		which_key.add({
			{ "<leader>\\", group = "Session", icon = "" },
			{ "<leader>\\i", icon = { icon = "", color = "blue" } },
			{ "<leader>\\d", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>\\l", icon = { icon = "", color = "orange" } },
			{ "<leader>\\s", icon = { icon = "", color = "green" } },
		})

		-- Tests
		which_key.add({
			{ "<leader>T", group = "Test", icon = { icon = "󰙨", color = "red" } },
			{ "<leader>Tf", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>Tn", icon = { icon = "󰍎", color = "green" } },
			{ "<leader>Tl", icon = { icon = "", color = "orange" } },
			{ "<leader>TF", icon = { icon = "󰈢", color = "green" } },
			{ "<leader>Ts", icon = { icon = "", color = "red" } },
			{ "<leader>To", icon = { icon = "󰈇", color = "azure" } },
			{ "<leader>Ta", icon = { icon = "󱘖", color = "grey" } },
			{ "<leader>Tt", group = "Toggle" },
			{ "<leader>Ttx", icon = { icon = "󱖫", color = "red" } },
			{ "<leader>Tto", icon = { icon = "󰈇", color = "azure" } },
			{ "<leader>Tts", icon = { icon = "", color = "azure" } },
			{ "<leader>TtS", icon = { icon = "", color = "grey" } },
			{ "<leader>Ttw", icon = { icon = "󰈈", color = "grey" } },
		})

		-- Overseer
		which_key.add({
			{ "<leader>r", group = "Run", icon = { icon = "󰜎", color = "green" } },
			{ "<leader>rr", icon = { icon = "󰷐", color = "green" } },
			{ "<leader>rl", icon = { icon = "", color = "orange" } },
			{ "<leader>rs", icon = { icon = "", color = "grey" } },
			{ "<leader>rS", icon = { icon = "", color = "azure" } },
		})

		-- OpenCode
		which_key.add({
			{ "<leader>a", mode = { "n", "x" }, group = "AI", icon = { icon = "󰚩", color = "green" } },
			{ "<leader>aa", mode = { "n", "x" }, icon = { icon = "", color = "green" } },
			{ "<leader>as", mode = { "n", "x" }, icon = { icon = "󰷐", color = "blue" } },
			{ "<leader>ar", mode = { "n", "x" }, icon = { icon = "󰅪", color = "grey" } },
			{ "<leader>al", icon = { icon = "", color = "grey" } },
			{ "<leader>ab", icon = { icon = "", color = "grey" } },
			{ "<leader>ax", icon = { icon = "󱖫", color = "grey" } },
			{ "<leader>aq", icon = { icon = "󰺧", color = "grey" } },
		})

		-- Change
		which_key.add({
			{ "<leader>c", group = "Change", icon = { icon = "", color = "green" } },
			{ "<leader>cf", icon = { icon = "󰈮", color = "green" } },
			{ "<leader>ct", icon = { icon = "󰌒", color = "green" } },
		})

		-- g*
		which_key.add({
			{ "g'", desc = "Marks", icon = { icon = "󰸕", color = "purple" } },
			{ "g`", desc = "Marks", icon = { icon = "󰸕", color = "purple" } },
			{ "gx", mode = { "n", "x" }, desc = "Open with system app", icon = { icon = "󰏋", color = "green" } },
			{ "g<", desc = "Display previous command output", icon = { icon = "", color = "green" } },
			{ "g~", mode = { "n", "x" }, desc = "Toggle case", icon = { icon = "󰬴", color = "yellow" } },
			{ "gu", mode = { "n", "x" }, desc = "Lowercase", icon = { icon = "󰬵", color = "grey" } },
			{ "gU", mode = { "n", "x" }, desc = "Uppercase", icon = { icon = "󰬶", color = "grey" } },
			{ "gv", desc = "Last visual selection", icon = { icon = "", color = "green" } },
			{ "gi", desc = "Last insert", icon = { icon = "󰸱", color = "green" } },
			{
				"g%",
				mode = { "n", "x", "o" },
				desc = "Cycle backwards through matching group",
				icon = { icon = "󰅩", color = "grey" },
			},
			{ "gc", mode = { "n", "x" }, name = "Comment", icon = { icon = "󰐣", color = "grey" } },
			{ "gc", mode = "o", hidden = true },
			{
				"ge",
				mode = { "n", "x", "o" },
				desc = "Previous end of word",
				icon = { icon = "󰘟", color = "purple" },
			},
			{ "g,", desc = "Go to newer position in change list", icon = { icon = "", color = "purple" } },
			{ "g;", desc = "Go to older position in change list", icon = { icon = "", color = "purple" } },
			{ "gt", desc = "Go to next tab page", icon = { icon = "󰓩", color = "green" } },
			{ "gT", desc = "Go to previous tab page", icon = { icon = "󰓩", color = "green" } },
			{ "gn", desc = "Search forwards and select", icon = { icon = "󰈞", color = "blue" } },
			{ "gN", desc = "Search backwards and select", icon = { icon = "󰈞", color = "blue" } },
			{ "gf", desc = "Open file", icon = { icon = "󰈔", color = "green" } },
			-- Remove LSP keymaps
			{ "gr", mode = { "n", "x" }, hidden = true },
			{ "gO", hidden = true },
		})

		-- z*
		which_key.add({
			{ "zf", mode = { "n", "x" }, desc = "Create fold", icon = { icon = "", color = "green" } },
			{ "zc", desc = "Close fold under cursor", icon = { icon = "󰕎", color = "orange" } },
			{ "zC", desc = "Close all folds under cursor", icon = { icon = "󰕎", color = "orange" } },
			{ "zd", desc = "Delete fold under cursor", icon = { icon = "󰆴", color = "red" } },
			{ "zD", desc = "Delete all folds under cursor", icon = { icon = "󰆴", color = "red" } },
			{ "zE", desc = "Delete all folds in file", icon = { icon = "󰆴", color = "red" } },
			{ "zm", desc = "Fold more", icon = { icon = "󰕎", color = "orange" } },
			{ "zM", desc = "Close all folds", icon = { icon = "󰕎", color = "orange" } },
			{ "zo", desc = "Open fold under cursor", icon = { icon = "󰕏", color = "green" } },
			{ "zO", desc = "Open all folds under cursor", icon = { icon = "󰕏", color = "green" } },
			{ "zr", desc = "Fold less", icon = { icon = "󰕏", color = "green" } },
			{ "zR", desc = "Open all folds", icon = { icon = "󰕏", color = "green" } },
			{ "zv", desc = "Open folds until cursor", icon = { icon = "󰕏", color = "green" } },
			{ "zx", desc = "Update folds", icon = { icon = "󰚰", color = "purple" } },
			{ "zz", desc = "Center this line", icon = { icon = "󰘢", color = "grey" } },
			{ "z<CR>", desc = "Top this line", icon = { icon = "󰘣", color = "grey" } },
			{ "zt", desc = "Top this line", icon = { icon = "󰘣", color = "grey" } },
			{ "zb", desc = "Bottom this line", icon = { icon = "󰘡", color = "grey" } },
			{ "ze", desc = "Right this line", icon = { icon = "󰘠", color = "grey" } },
			{ "zs", desc = "Left this line", icon = { icon = "󰘟", color = "grey" } },
			{ "zH", desc = "Half screen to the left", icon = { icon = "󱂪", color = "grey" } },
			{ "zL", desc = "Half screen to the right", icon = { icon = "󱂫", color = "grey" } },
			{ "z=", group = "Spelling suggestions", icon = { icon = "󰓆", color = "azure" } },
			{ "zw", desc = "Mark work as bad/misspelling", icon = { icon = "󰓆", color = "azure" } },
			{ "zg", desc = "Add word to spell list", icon = { icon = "󰓆", color = "azure" } },
		})

		-- Operators
		which_key.add({
			mode = { "n", "x" },
			{ "!", desc = "Run program", icon = { icon = "", color = "grey" } },
			{ "<", desc = "Indent left", icon = { icon = "󰉵", color = "purple" } },
			{ ">", desc = "Indent right", icon = { icon = "󰉶", color = "purple" } },
			{ "V", desc = "Visual Line", icon = { icon = "󰒅", color = "green" } },
			{ "c", desc = "Change", icon = { icon = "", color = "yellow" } },
			{ "d", desc = "Delete", icon = { icon = "󰆴", color = "red" } },
			{ "r", desc = "Replace", icon = { icon = "", color = "yellow" } },
			{ "v", desc = "Visual", icon = { icon = "󰒅", color = "green" } },
			{ "y", desc = "Yank", icon = { icon = "󰆏", color = "grey" } },
			{ "~", desc = "Toggle case", icon = { icon = "󰬴", color = "purple" } },
			{ "<C-h>", icon = { icon = "󰧙", color = "orange" } },
			{ "<C-j>", icon = { icon = "󰧗", color = "orange" } },
			{ "<C-k>", icon = { icon = "󰧝", color = "orange" } },
			{ "<C-l>", icon = { icon = "󰧛", color = "orange" } },
			{ "z", group = "Fold", icon = { icon = "", color = "green" } },
			{ "Q", desc = "Repeat last register", icon = { icon = "󰑊", color = "red" } },
			{ "@", desc = "Execute register", icon = { icon = "󰑊", color = "red" } },
			{ "#", desc = "Search selection backwards", icon = { icon = "󰈞", color = "blue" } },
			{ "*", desc = "Search selection forwards", icon = { icon = "󰈞", color = "blue" } },
			{ "<C-w>", group = "Window" },
		})

		-- Motions (Yank, Delete, Change)
		which_key.add({
			mode = { "o", "x", "n" },
			{ "0", hidden = true },
			{ "b", hidden = true },
			{ "B", desc = "Prev WORD", icon = { icon = "󰘟", color = "purple" } },
			{ "e", hidden = true },
			{ "E", desc = "Next end of WORD", icon = { icon = "󰘠", color = "purple" } },
			{ "f", hidden = true },
			{ "F", hidden = true },
			{ "G", desc = "Last line", icon = { icon = "󰘡", color = "purple" } },
			{ "h", hidden = true },
			{ "j", hidden = true },
			{ "k", hidden = true },
			{ "l", hidden = true },
			{ "t", hidden = true },
			{ "T", hidden = true },
			{ "w", hidden = true },
			{ "W", desc = "Next WORD", icon = { icon = "󰘠", color = "purple" } },

			{ "$", desc = "End of line", icon = { icon = "󰘠", color = "purple" } },
			{ "%", desc = "Matching (){}[]", icon = { icon = "󰅩", color = "grey" } },
			{ ",", desc = "<count> Prev f|t|F|T", icon = { icon = "", color = "blue" } },
			{ "/", desc = "Search forward", icon = { icon = "󰈞", color = "blue" } },
			{ ";", desc = "<count> Next f|t|F|T", icon = { icon = "", color = "blue" } },
			{ "?", desc = "Search backward", icon = { icon = "󰈞", color = "blue" } },
			{ "^", desc = "Start of line (non ws)", icon = { icon = "󰘟", color = "purple" } },
			{ "{", desc = "Prev empty line", icon = { icon = "󰘣", color = "grey" } },
			{ "}", desc = "Next empty line", icon = { icon = "󰘡", color = "grey" } },

			{ "gg", desc = "First line", icon = { icon = "󰘣", color = "purple" } },

			{ "]", group = "Next", icon = { icon = "󰒭", color = "grey" } },
			{ "]%", desc = "Next unmatched group", icon = { icon = "󰅩", color = "cyan" } },
			{ "[", group = "Previous", icon = { icon = "󰒮", color = "grey" } },
			{ "[%", desc = "Previous unmatched group", icon = { icon = "󰅩", color = "cyan" } },
		})

		-- Treesitter
		which_key.add({
			mode = { "x" },
			{ "]n", desc = "Next node", icon = { icon = "󰅩", color = "grey" } },
			{ "[n", desc = "Previous node", icon = { icon = "󰅩", color = "grey" } },
		})

		-- Around/Inside with mini.ai
		local function get_textobjects_keymaps(prefix)
			return {
				{ prefix .. '"', desc = '""', icon = "" },
				{ prefix .. "'", desc = "''", icon = "" },
				{ prefix .. "`", desc = "``", icon = "" },
				{ prefix .. "(", desc = "()", icon = "" },
				{ prefix .. "<", desc = "<>", icon = "" },
				{ prefix .. "B", desc = "{}", icon = "" },
				{ prefix .. "{", desc = "{}", icon = "" },
				{ prefix .. "[", desc = "[]", icon = "" },
				{ prefix .. "b", desc = "[]|()|{}", icon = "" },
				{ prefix .. "w", desc = "Word", icon = { icon = "", color = "grey" } },
				{ prefix .. "W", desc = "WORD", icon = { icon = "", color = "grey" } },
				{ prefix .. "p", desc = "Paragraph", icon = { icon = "󰉢", color = "grey" } },
				{ prefix .. "s", desc = "Sentence", icon = { icon = ".", color = "grey" } },
				{ prefix .. "t", desc = "Tag block", icon = { icon = "󰗀", color = "grey" } },
				{ prefix .. "<Space>", desc = "󱁐", icon = "" },
				{ prefix .. "*", desc = "*", icon = "" },
				{ prefix .. "q", desc = "Quote", icon = { icon = "󰉾", color = "grey" } },
				{ prefix .. "?", desc = "User prompt", icon = { icon = "", color = "blue" } },
				{ prefix .. "f", desc = "Function call", icon = { icon = "󰊕", color = "grey" } },
				{ prefix .. "a", desc = "Argument", icon = { icon = "󰊕", color = "grey" } },
			}
		end
		which_key.add({
			mode = { "o", "x" },
			{ "a", group = "Around", icon = { icon = "󰉾", color = "green" } },
			{ "i", group = "Inside", icon = { icon = "󰉾", color = "green" } },
			{ "a)", hidden = true },
			{ "i)", hidden = true },
			{ "a>", hidden = true },
			{ "i>", hidden = true },
			{ "a}", hidden = true },
			{ "i}", hidden = true },
			{ "a]", hidden = true },
			{ "i]", hidden = true },
			get_textobjects_keymaps("a"),
			get_textobjects_keymaps("i"),

			{ "al", group = "Last/Prev", icon = { icon = "󰉾", color = "red" } },
			get_textobjects_keymaps("al"),
			{ "il", group = "Last/Prev", icon = { icon = "󰉾", color = "red" } },
			get_textobjects_keymaps("il"),
			{ "an", group = "Next", icon = { icon = "󰉾", color = "red" } },
			get_textobjects_keymaps("an"),
			{ "in", group = "Next", icon = { icon = "󰉾", color = "red" } },
			get_textobjects_keymaps("in"),
		})
		which_key.add({
			mode = { "n", "o", "x" },
			{ "g[", group = "Go to left around", icon = { icon = "󰉾", color = "grey" } },
			get_textobjects_keymaps("g["),
			{ "g]", group = "Go to right around", icon = { icon = "󰉾", color = "grey" } },
			get_textobjects_keymaps("g]"),
		})
	end,
}
