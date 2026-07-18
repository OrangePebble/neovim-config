local fg = vim.g.colorscheme.foreground_0
local red = vim.g.colorscheme.red
local green = vim.g.colorscheme.green
local yellow = vim.g.colorscheme.yellow
local blue = vim.g.colorscheme.blue
local magenta = vim.g.colorscheme.magenta
local orange = vim.g.colorscheme.orange
local bg_dark = vim.g.colorscheme.background_1
local fg_dark1 = vim.g.colorscheme.foreground_1
local fg_dark2 = vim.g.colorscheme.foreground_2
local comment = vim.g.colorscheme.comment
local red_faded = vim.g.colorscheme.red_faded
local green_faded = vim.g.colorscheme.green_faded
local yellow_faded = vim.g.colorscheme.yellow_faded
local blue_faded = vim.g.colorscheme.blue_faded
local magenta_faded = vim.g.colorscheme.magenta_faded
local orange_faded = vim.g.colorscheme.orange_faded

return {
	normal = {
		a = { bg = blue, fg = bg_dark, gui = "bold" },
		b = { bg = blue_faded, fg = fg },
		c = { bg = bg_dark, fg = fg_dark1 },
	},
	insert = {
		a = { bg = green, fg = bg_dark, gui = "bold" },
		b = { bg = green_faded, fg = fg },
	},
	command = {
		a = { bg = yellow, fg = bg_dark, gui = "bold" },
		b = { bg = yellow_faded, fg = fg },
	},
	visual = {
		a = { bg = magenta, fg = bg_dark, gui = "bold" },
		b = { bg = magenta_faded, fg = fg },
	},
	replace = {
		a = { bg = red, fg = bg_dark, gui = "bold" },
		b = { bg = red_faded, fg = fg },
	},
	terminal = {
		a = { bg = orange, fg = bg_dark, gui = "bold" },
		b = { bg = orange_faded, fg = fg },
	},
	inactive = {
		a = { bg = bg_dark, fg = blue },
		b = { bg = bg_dark, fg = fg_dark2, gui = "bold" },
		c = { bg = bg_dark, fg = comment },
	},
}
