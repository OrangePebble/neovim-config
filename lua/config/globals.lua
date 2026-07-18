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
	background_0 =           "#161616",
	foreground_0 =           "#F2F2F2",
	black =                  "#282828",
	red =                    "#EE5396",
	green =                  "#25BE6A",
	yellow =                 "#EBCB8B",
	blue =                   "#78A9FF",
	magenta =                "#BE95FF",
	cyan =                   "#33B1FF",
	white =                  "#DFDFE0",
	black_bright =           "#4A4A4A", -- black.lighten(15)
	red_bright =             "#F16FA7", -- red.lighten(15)
	green_bright =           "#37D77F", -- green.lighten(15)
	yellow_bright =          "#EED29B", -- yellow.lighten(15)
	blue_bright =            "#8FB8FF", -- blue.lighten(15)
	magenta_bright =         "#C6A3FF", -- magenta.lighten(15)
	cyan_bright =            "#52BDFF", -- cyan.lighten(15)
	white_bright =           "#E5E5E6", -- white.lighten(15)
	---- Extended terminal colors (used by terminals like 'foot')
	selection_background_0 = "#2A2A2A",
	black_dim =              "#242424", -- black.darken(15)
	red_dim =                "#EA2A7D", -- red.darken(15)
	green_dim =              "#20A25A", -- green.darken(15)
	yellow_dim =             "#E3B559", -- yellow.darken(15)
	blue_dim =               "#4287FF", -- blue.darken(15)
	magenta_dim =            "#9757FF", -- magenta.darken(15)
	cyan_dim =               "#059FFF", -- cyan.darken(15)
	white_dim =              "#BEBEC1", -- white.darken(15)
	---- Neovim-only (maybe)
	background_1 =           "#0C0C0C",
	background_2 =           "#242424", -- background_1.lighten(6)
	background_3 =           "#333333", -- background_1.lighten(12)
	background_4 =           "#4F4F4F", -- background_1.lighten(24)
	foreground_1 =           "#B8B8B8", -- foreground_0.darken(24)
	foreground_2 =           "#7D7D7D", -- foreground_0.darken(48)
	selection_background_1 = "#525253",
	orange =                 "#FF8349",
	orange_bright =          "#FF9361", -- orange.lighten(15)
	orange_dim =             "#FF5F14", -- orange.darken(15)
	pink =                   "#FF7EB6",
	pink_bright =            "#FF94C2", -- pink.lighten(15)
	pink_dim =               "#FF4797", -- pink.darken(15)
	comment =                "#6E6E6E", -- hsl(background_0).mix(hsl(foreground_0), 40)
	-- Lualine
	red_faded =              "#462A36", -- hsl(background_1).mix(hsl(red), 30)
	green_faded =            "#23342A", -- hsl(background_1).mix(hsl(green), 30)
	yellow_faded =           "#4D4432", -- hsl(background_1).mix(hsl(yellow), 30)
	blue_faded =             "#2E3D56", -- hsl(background_1).mix(hsl(blue), 30)
	magenta_faded =          "#40305A", -- hsl(background_1).mix(hsl(magenta), 30)
	orange_faded =           "#4C3429", -- hsl(background_1).mix(hsl(orange), 30)
}

vim.g.colorscheme = carbonfox
