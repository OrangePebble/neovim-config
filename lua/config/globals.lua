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

-- https://github.com/EdenEast/nightfox.nvim
-- Carbonfox with some changes:
-- - Terafox red
-- - Nordfox yellow
-- - Nightfox cyan
-- - Terafox orange
-- stylua: ignore
local carbonfox = {
	---- Regular terminal colors
	background_0 =           "#0c0c0c",
	foreground_0 =           "#f2f2f2",
	black =                  "#282828",
	red =                    "#e85c51",
	green =                  "#25be6a",
	yellow =                 "#ebcb8b",
	blue =                   "#78a9ff",
	magenta =                "#be95ff",
	cyan =                   "#63cdcf",
	white =                  "#dfdfe0",
	black_bright =           "#4a4a4a", -- black.lighten(15)
	red_bright =             "#ef8c85", -- red.lighten(30)
	green_bright =           "#5ddf98", -- green.lighten(30)
	yellow_bright =          "#f1daac", -- yellow.lighten(30)
	blue_bright =            "#a3c5ff", -- blue.lighten(30)
	magenta_bright =         "#d9c2ff", -- magenta.lighten(45)
	cyan_bright =            "#92dcdd", -- cyan.lighten(30)
	white_bright =           "#eaeaeb", -- white.lighten(30)
	---- Extended terminal colors (used by terminals like 'foot')
	selection_background_0 = "#2a2a2a",
	black_dim =              "#242424", -- black.darken(15)
	red_dim =                "#c54e45",
	green_dim =              "#20a25a", -- green.darken(15)
	yellow_dim =             "#d9b263",
	blue_dim =               "#4287ff", -- blue.darken(15)
	magenta_dim =            "#9757ff", -- magenta.darken(15)
	cyan_dim =               "#40c2c4", -- cyan.darken(15)
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
	orange_bright =          "#ffb999", -- orange.lighten(45)
	orange_dim =             "#d96f3e",
	pink =                   "#ff7eb6",
	pink_bright =            "#ffb8d7", -- pink.lighten(45)
	pink_dim =               "#ff4797", -- pink.darken(15)
	comment =                "#6e6e6e", -- hsl(background_0).mix(hsl(foreground_0), 40)
	-- Lualine
	red_faded =              "#5a3230", -- hsl(background_0).mix(hsl(red), 30)
	green_faded =            "#23342a", -- hsl(background_0).mix(hsl(green), 30)
	yellow_faded =           "#4d4432", -- hsl(background_0).mix(hsl(yellow), 30)
	blue_faded =             "#2e3d56", -- hsl(background_0).mix(hsl(blue), 30)
	magenta_faded =          "#40305a", -- hsl(background_0).mix(hsl(magenta), 30)
	orange_faded =           "#4c3429", -- hsl(background_0).mix(hsl(orange), 30)
}

vim.g.colorscheme = carbonfox
