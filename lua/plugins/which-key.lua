-- Display keybindings as you type.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local which_key = require("which-key")
		which_key.setup({
			preset = "modern",
			delay = 0,
		})
		-- Find default icons and colors on: https://github.com/folke/which-key.nvim/blob/main/lua/which-key/icons.lua
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
		-- This is the loose rules I have for colors:
		--  Purple is for misc because it's the default.
		--  Cyan is for searching.
		--  Green is for showing/selecting/opening.
		--  Red is for diagnostics/debugging/testing.
		--  Yellow is for toggling.
		--  Grey is for action.
		which_key.add({
			-- Remapped useful keymaps that wouldn't show up in which-key so that I can remember them and
			--  learn to use the actual keymaps. Like 'K' for LSP hover documentation.
			-- Technically <leader>? already does this for buffer specific keymaps, and I could add a
			--  version for all keymaps,
			{ "<leader>+", group = "Extras", icon = "" },
			{ "<leader>y", icon = { icon = "󰆏", color = "grey" } },
			{ "<leader>Y", icon = { icon = "󰆏", color = "grey" } },
			{ "<leader>p", icon = { icon = "󰆒", color = "grey" } },
			{ "<leader>P", icon = { icon = "󰆒", color = "grey" } },
			{ "<leader>r", icon = { icon = "󰑕", color = "grey" } },
			{ "<leader>u", icon = { icon = "", color = "yellow" } },
			{ "<leader>e", icon = { icon = "", color = "yellow" } },
			{ "]t", icon = { icon = "󰷐", color = "grey" } },
			{ "[t", icon = { icon = "󰷐", color = "grey" } },

			-- which-key
			{ "<leader>?l", icon = "󰈔" },
			{ "<leader>?g", icon = "" },
			{ "<leader>?", group = "Keymaps (which-key)", icon = "󰥻" },

			-- Native new descriptions and icons
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
			{ "]m", desc = "Next method start", icon = "" },
			{ "]M", desc = "Next method end", icon = "" },
			{ "[m", desc = "Previous method start", icon = "" },
			{ "[M", desc = "Previous method end", icon = "" },
			{ "]s", desc = "Next misspelled word", icon = { icon = "󰓆", color = "orange" } },
			{ "[s", desc = "Previous misspelled word", icon = { icon = "󰓆", color = "orange" } },
			{ "]x", icon = { icon = "󱖫", color = "red" } },
			{ "]X", icon = { icon = "󱖫", color = "red" } },
			{ "[x", icon = { icon = "󱖫", color = "red" } },
			{ "[X", icon = { icon = "󱖫", color = "red" } },
			{ "]c", desc = "Next change (diff)", icon = { icon = "", color = "orange" } },
			{ "[c", desc = "Previous change (diff)", icon = { icon = "", color = "orange" } },

			-- mini.indentscope new descriptions and icons
			{ "ii", mode = "ox", desc = "Indent (Object scope)", icon = { icon = "󰉶", color = "grey" } },
			{ "ai", mode = "ox", desc = "Around indent (Object scope)", icon = { icon = "󰉶", color = "grey" } },
			{ "[i", desc = "Indent top (Object scope)", icon = { icon = "󰉶", color = "grey" } },
			{ "]i", desc = "Indent bottom (Object scope)", icon = { icon = "󰉶", color = "grey" } },

			-- Toggle icons.
			{ "<leader>t", group = "Toggle" },
			{ "<leader>tt", group = "Todo", icon = { icon = "󰷐", color = "yellow" } },
			{ "<leader>tu", icon = { icon = "", color = "orange" } },
			{ "<leader>tm", icon = { icon = "󰍔", color = "grey" } },
			{ "<leader>tw", icon = { icon = "󰖶", color = "grey" } },
			{ "<leader>ttt", icon = { icon = "", color = "grey" } },
			{ "<leader>tta", icon = "" },
			{ "<leader>tq", icon = { icon = "󰺧", color = "yellow" } },
			{ "<leader>te", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>tl", icon = { icon = "󰉄", color = "white" } },
			{ "<leader>tr", icon = { icon = "󰉻", color = "white" } },
			{ "<leader>th", icon = { icon = "", color = "white" } },
			{ "<leader>tc", icon = { icon = "󰏘", color = "white" } },
			{ "<leader>tC", icon = { icon = "󰉾", color = "white" } },

			-- LSP icons.
			{ "<leader>l", group = "LSP", icon = { icon = "󰰍", color = "cyan" } },
			{ "<leader>lf", icon = { icon = "󰰍", color = "cyan" } },
			{ "<leader>ls", icon = { icon = "", color = "green" } },
			{ "<leader>lS", icon = { icon = "", color = "green" } },
			{ "<leader>lr", icon = { icon = "", color = "cyan" } },
			{ "<leader>lR", icon = { icon = "󰑕", color = "grey" } },
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

			-- Diagnostic icons.
			{ "<leader>x", group = "Diagnostics", icon = { icon = "󱖫", color = "red" } },
			{ "<leader>xc", icon = { icon = "󰗧", color = "red" } },
			{ "<leader>xl", icon = { icon = "", color = "red" } },
			{ "<leader>xd", icon = { icon = "󰈞", color = "cyan" } },
			{ "<leader>xw", icon = { icon = "", color = "cyan" } },
			{ "<leader>xt", group = "Toggle" },
			{ "<leader>xtv", icon = { icon = "󱖫", color = "yellow" } },
			{ "<leader>xtd", icon = { icon = "󰈔", color = "yellow" } },
			{ "<leader>xtw", icon = { icon = "", color = "yellow" } },

			-- Debug icons.
			{ "<leader>d", group = "Debug" },
			{ "<leader>di", icon = { icon = "", color = "grey" } },
			{ "]d", icon = { icon = "", color = "red" } },
			{ "<leader>do", icon = { icon = "", color = "grey" } },
			{ "]D", icon = { icon = "", color = "red" } },
			{ "<leader>dO", icon = { icon = "", color = "grey" } },
			{ "[d", icon = { icon = "", color = "red" } },
			{ "<leader>dI", icon = { icon = "", color = "grey" } },
			{ "[D", icon = { icon = "", color = "red" } },
			{ "<leader>dc", icon = { icon = "", color = "green" } },
			{ "<leader>dC", icon = { icon = "", color = "green" } },
			{ "<leader>dl", icon = { icon = "", color = "green" } },
			{ "<leader>dp", icon = { icon = "", color = "orange" } },
			{ "<leader>ds", icon = { icon = "", color = "red" } },
			{ "<leader>de", icon = { icon = "", color = "purple" } },
			{ "<leader>dg", icon = { icon = "", color = "grey" } },
			{ "<leader>db", icon = { icon = "", color = "red" } },
			{ "<leader>dB", icon = { icon = "", color = "red" } },
			{ "<leader>da", icon = { icon = "", color = "green" } },
			{ "<leader>dj", icon = { icon = "󰄠", color = "grey" } },
			{ "<leader>dk", icon = { icon = "󰄝", color = "grey" } },
			{ "<leader>dw", icon = { icon = "", color = "purple" } },
			{ "<leader>dr", icon = { icon = "", color = "yellow" } },
			{ "<leader>du", icon = { icon = "󰙵", color = "yellow" } },

			-- Git
			{ "<leader>g", group = "Git" },
			{ "<leader>gt", group = "Toggle" },
			{ "<leader>gb", icon = { icon = "", color = "orange" } },
			{ "<leader>gd", icon = { icon = "", color = "yellow" } },
			{ "<leader>gD", icon = { icon = "", color = "yellow" } },
			{ "<leader>gn", icon = { icon = "󰁅", color = "grey" } },
			{ "<leader>gN", icon = { icon = "󰞒", color = "grey" } },
			{ "<leader>gp", icon = { icon = "󰁝", color = "grey" } },
			{ "<leader>gP", icon = { icon = "󰞕", color = "grey" } },
			{ "<leader>gr", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>gR", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>gs", icon = { icon = "", color = "green" } },
			{ "<leader>gS", icon = { icon = "", color = "green" } },
			{ "<leader>gu", icon = { icon = "", color = "orange" } },
			{ "<leader>gtb", icon = { icon = "", color = "orange" } },
			{ "<leader>gts", icon = { icon = "", color = "green" } },
			{ "<leader>gtl", icon = { icon = "󰸱", color = "yellow" } },
			{ "<leader>gtw", icon = { icon = "", color = "yellow" } },
			{ "<leader>gtd", icon = { icon = "󰆴", color = "red" } },

			-- Search
			{ "<leader>s", group = "Search", icon = { icon = "", color = "cyan" } },
			{ "<leader>st", group = "Todo", icon = { icon = "󰷐", color = "yellow" } },
			{ "<leader>stt", icon = { icon = "", color = "yellow" } },
			{ "<leader>sta", icon = "" },
			{ "<leader>sf", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>si", icon = { icon = "󰘓", color = "green" } },
			{ "<leader>sc", icon = { icon = "", color = "grey" } },
			{ "<leader>sg", icon = { icon = "󰈞", color = "cyan" } },
			{ "<leader>s/", icon = { icon = "󰈞", color = "cyan" } },
			{ "<leader>sw", icon = { icon = "󰈞", color = "cyan" } },
			{ "<leader>sh", icon = { icon = "󰞋", color = "grey" } },
			{ "<leader>sN", icon = { icon = "", color = "grey" } },
			{ "<leader>sr", icon = "" },
			{ "<leader>so", icon = { icon = "", color = "green" } },
			{ "<leader>sb", icon = { icon = "", color = "green" } },
			{ "<leader>sd", icon = { icon = "󰃤", color = "red" } },
			{ "<leader>sq", icon = { icon = "󰺧", color = "yellow" } },
			{ "<leader>ss", icon = "" },
			{ "<leader>sn", icon = { icon = "󰵅", color = "grey" } },

			-- Window
			{ "<leader>w", group = "Window", icon = { icon = "", color = "grey" } },
			{ "<leader>w\\", icon = { icon = "", color = "orange" } },
			{ "<leader>w-", icon = { icon = "", color = "orange" } },
			{ "<leader>wh", icon = { icon = "󱂪", color = "grey" } },
			{ "<leader>wj", icon = { icon = "󱂩", color = "grey" } },
			{ "<leader>wk", icon = { icon = "󱔓", color = "grey" } },
			{ "<leader>wl", icon = { icon = "󱂫", color = "grey" } },
			{ "<leader>w;", icon = { icon = "󰮳", color = "grey" } },
			{ "<leader>wH", icon = { icon = "", color = "yellow" } },
			{ "<leader>wJ", icon = { icon = "", color = "yellow" } },
			{ "<leader>wK", icon = { icon = "", color = "yellow" } },
			{ "<leader>wL", icon = { icon = "", color = "yellow" } },
			{ "<leader>w<C-h>", icon = { icon = "󰧙", color = "orange" } },
			{ "<leader>w<C-j>", icon = { icon = "󰧗", color = "orange" } },
			{ "<leader>w<C-k>", icon = { icon = "󰧝", color = "orange" } },
			{ "<leader>w<C-l>", icon = { icon = "󰧛", color = "orange" } },
			{ "<leader>w|", icon = { icon = "󰡎", color = "yellow" } },
			{ "<leader>w_", icon = { icon = "󰡏", color = "yellow" } },
			{ "<leader>w=", icon = { icon = "󰁌", color = "yellow" } },
			{ "<leader>wq", icon = { icon = "󰅗", color = "red" } },
			{ "<leader>wo", icon = { icon = "󰱝", color = "red" } },
			{ "<leader>ww", icon = "" },
			{ "<leader>w<space>", icon = "󰑖" },
			{ "<C-w><space>", icon = "󰑖" },

			-- harpoon
			{ "<leader><leader>", group = "Harpoon", icon = { icon = "󱡅", color = "green" } },
			{ "<leader><leader>a", icon = { icon = "", color = "grey" } },
			{ "<leader><leader>p", icon = { icon = "󰍠", color = "green" } },
			{ "<leader><leader>n", icon = { icon = "󰍝", color = "green" } },
			{ "<leader><leader><leader>", icon = { icon = "", color = "cyan" } },

			-- Resession
			{ "<leader>\\", group = "Session", icon = "" },
			{ "<leader>\\i", icon = { icon = "", color = "cyan" } },
			{ "<leader>\\d", icon = { icon = "󰆴", color = "red" } },
			{ "<leader>\\l", icon = { icon = "", color = "orange" } },
			{ "<leader>\\s", icon = { icon = "", color = "green" } },

			-- Tests
			{ "<leader>T", group = "Test", icon = { icon = "󰙨", color = "red" } },
			{ "<leader>Tf", icon = { icon = "󰈔", color = "green" } },
			{ "<leader>Tn", icon = { icon = "󰍎", color = "green" } },
			{ "<leader>Tl", icon = { icon = "", color = "orange" } },
			{ "<leader>TF", icon = { icon = "󰈢", color = "green" } },
			{ "<leader>Ts", icon = { icon = "", color = "red" } },
			{ "<leader>To", icon = { icon = "󰈇", color = "cyan" } },
			{ "<leader>Ta", icon = { icon = "󱘖", color = "grey" } },
			{ "<leader>Tt", group = "Toggle" },
			{ "<leader>Ttx", icon = { icon = "󱖫", color = "red" } },
			{ "<leader>Tto", icon = { icon = "󰈇", color = "cyan" } },
			{ "<leader>Tts", icon = { icon = "", color = "cyan" } },
			{ "<leader>TtS", icon = { icon = "", color = "green" } },
			{ "<leader>Ttw", icon = { icon = "󰈈", color = "grey" } },

			-- Resession
			{ "<leader>o", group = "Overseer", icon = { icon = "󰈈", color = "green" } },
			{ "<leader>oo", icon = { icon = "󰷐", color = "green" } },
			{ "<leader>os", icon = { icon = "", color = "grey" } },
			{ "<leader>oS", icon = { icon = "", color = "cyan" } },

			-- OpenCode
			{ "<leader>a", mode = "nx", group = "AI", icon = { icon = "󰚩", color = "green" } },
			{ "<leader>aa", mode = "nx", icon = { icon = "", color = "green" } },
			{ "<leader>as", mode = "nx", icon = { icon = "󰷐", color = "blue" } },
			{ "<leader>ar", mode = "nx", icon = { icon = "󰅪", color = "grey" } },
			{ "<leader>al", icon = { icon = "", color = "grey" } },
			{ "<leader>ab", icon = { icon = "", color = "grey" } },
			{ "<leader>ax", icon = { icon = "󱖫", color = "grey" } },
			{ "<leader>aq", icon = { icon = "󰺧", color = "grey" } },

			-- Change
			{ "<leader>c", group = "Change", icon = { icon = "", color = "green" } },
			{ "<leader>cf", icon = { icon = "󰈮", color = "green" } },
			{ "<leader>ct", icon = { icon = "󰌒", color = "green" } },
		})
	end,
}
