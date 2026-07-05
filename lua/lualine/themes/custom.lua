local fg = "#f2f2f2"
local red = "#ee5396" -- 1
local green = "#25be6a" -- 2
local yellow = "#ebcb8b" -- 3
local blue = "#78a9ff" -- 4
local magenta = "#be95ff" -- 5
local orange = "#ff8349" -- 16

local bg_dark = "#0c0c0c"
local fg_dark1 = "#b8b8b8" -- hsl(fg1).darken(24).hex
local fg_dark2 = "#7d7d7d" -- hsl(fg1).darken(48).hex
local comment = "#595959" -- hsl(bg1).mix(hsl(fg1), 40).hex

-- To calculate run something like the following with the 1st hex being bg0 and 2nd being color:
-- :lua vim.print(require("lush").hsl("#0c0c0c").mix(require("lush").hsl("#78a9ff"), 30).hex)
local red_faded = "#462a36"
local green_faded = "#23342a"
local yellow_faded = "#4d4432"
local blue_faded = "#2e3d56"
local magenta_faded = "#40305a"
local orange_faded = "#4c3429"

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
