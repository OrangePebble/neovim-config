vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.autoformat = true

-- Many of the colors below are based on others, so here is an example to put a modified
--  version into the yank register, this specific command gets the currently selected
--  hex color and lightens it by 15%:
-- :'<,'>lua local s=vim.fn.getpos("'<"); local e=vim.fn.getpos("'>"); local c=vim.api.nvim_buf_get_text(0, s[2]-1, s[3]-1, e[2]-1, e[3], {})[1]; vim.fn.setreg('"', require("lush").hsl(c).lighten(15).hex)
--
-- The colors that use this will have the modification used and source color commented
--  afterwards, so modify the command above to get the new color.
-- Other colors require more complex modifications that will not be able to use the
--  command above directly.

-- Carbonfox with nordfox yellow and terafox orange
-- stylua: ignore
local carbonfox = {
	---- Regular terminal colors
	background_0 =           "#0c0c0c",
	foreground_0 =           "#f2f2f2",
	black =                  "#282828",
	red =                    "#ee5396",
	green =                  "#25be6a",
	yellow =                 "#ebcb8b",
	blue =                   "#78a9ff",
	magenta =                "#be95ff",
	cyan =                   "#33b1ff",
	white =                  "#dfdfe0",
	black_bright =           "#4a4a4a", -- black.lighten(15)
	red_bright =             "#f16fa7", -- red.lighten(15)
	green_bright =           "#37d77f", -- green.lighten(15)
	yellow_bright =          "#eed29b", -- yellow.lighten(15)
	blue_bright =            "#8fb8ff", -- blue.lighten(15)
	magenta_bright =         "#c6a3ff", -- magenta.lighten(15)
	cyan_bright =            "#52bdff", -- cyan.lighten(15)
	white_bright =           "#e5e5e6", -- white.lighten(15)
	---- Extended terminal colors (used by terminals like 'foot')
	selection_background_0 = "#2a2a2a",
	black_dim =              "#242424", -- black.darken(15)
	red_dim =                "#ea2a7d", -- red.darken(15)
	green_dim =              "#20a25a", -- green.darken(15)
	yellow_dim =             "#e3b559", -- yellow.darken(15)
	blue_dim =               "#4287ff", -- blue.darken(15)
	magenta_dim =            "#9757ff", -- magenta.darken(15)
	cyan_dim =               "#059fff", -- cyan.darken(15)
	white_dim =              "#bebec1", -- white.darken(15)
	---- Neovim-only (maybe)
	background_1 =           "#161616",
	background_2 =           "#242424", -- background_1.lighten(6)
	background_3 =           "#333333", -- background_1.lighten(12)
	background_4 =           "#4f4f4f", -- background_1.lighten(24)
	foreground_1 =           "#b8b8b8", -- foreground_0.darken(24)
	foreground_2 =           "#7d7d7d", -- foreground_0.darken(48)
	selection_background_1 = "#525253",
	orange =                 "#ff8349",
	orange_bright =          "#ff9361", -- orange.lighten(15)
	orange_dim =             "#ff5f14", -- orange.darken(15)
	pink =                   "#ff7eb6",
	pink_bright =            "#ff94c2", -- pink.lighten(15)
	pink_dim =               "#ff4797", -- pink.darken(15)
	comment =                "#6e6e6e", -- hsl(background_0).mix(hsl(foreground_0), 40)
	-- Lualine
	red_faded =              "#462a36", -- hsl(background_1).mix(hsl(red), 30)
	green_faded =            "#23342a", -- hsl(background_1).mix(hsl(green), 30)
	yellow_faded =           "#4d4432", -- hsl(background_1).mix(hsl(yellow), 30)
	blue_faded =             "#2e3d56", -- hsl(background_1).mix(hsl(blue), 30)
	magenta_faded =          "#40305a", -- hsl(background_1).mix(hsl(magenta), 30)
	orange_faded =           "#4c3429", -- hsl(background_1).mix(hsl(orange), 30)
}

vim.g.colorscheme = carbonfox
