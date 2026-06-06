-- Automatically run code on defined events.

-- INFO: For LSP buffer-local autocmds go to: ../plugins/dev/lspconfig.lua

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = last_cursor_group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

-- Don't move after yank. Taken from https://github.com/svban/YankAssassin.nvim
local pre_yank_pos = {}
vim.api.nvim_create_autocmd({ "VimEnter", "CursorMoved" }, {
	callback = function()
		pre_yank_pos = vim.api.nvim_win_get_cursor(0)
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		-- Fixes the error caused by yanking in the file tree from 'nvim-tree'
		if vim.fn.bufname() == "" then
			return
		end
		-- Only restore position after yanked with 'y' operator only
		-- If not set, text yanked with c will also activate it
		local operators = { "y" } -- Add more operators here if needed
		if vim.tbl_contains(operators, vim.v.event.operator) then
			local myMode = vim.api.nvim_get_mode().mode
			if (myMode == "no") or (myMode == "n") then
				vim.api.nvim_win_set_cursor(0, pre_yank_pos)
			end
		end
	end,
})

-- https://github.com/folke/trouble.nvim/blob/main/docs/examples.md
-- Open Trouble Quickfix when the qf list opens. Makes the regular quickfix list unusable.
-- Look at the docs for a less extreme version.
vim.api.nvim_create_autocmd("BufRead", {
	callback = function(ev)
		if vim.bo[ev.buf].buftype == "quickfix" then
			vim.schedule(function()
				vim.cmd([[cclose]])
				vim.cmd([[Trouble qflist open]])
			end)
		end
	end,
})

-- https://github.com/nvim-tree/nvim-tree.lua/issues/1368#issuecomment-1512248492
-- https://github.com/tzhouhc/vim/blob/b9c6a5441ddac8d964ad24df2b996feb1e39d539/lua/plugins/ui/trouble.lua#L21-L32
-- exit if nvim-tree, trouble, etc. are the only buffers open
local ft_buft = require("utils.ft_buft")
vim.api.nvim_create_autocmd("QuitPre", {
	group = vim.api.nvim_create_augroup("EnsureInvalidCloses", {}),
	callback = function()
		local invalid_win = {}
		local wins = vim.api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local buf = vim.api.nvim_win_get_buf(w)
			if not (ft_buft.is_normal_buffer(buf) and ft_buft.is_file_backed(buf)) then
				table.insert(invalid_win, w)
			end
		end
		if #invalid_win == #wins - 1 then
			-- Should quit, so we close all invalid windows.
			for _, w in ipairs(invalid_win) do
				vim.api.nvim_win_close(w, true)
			end
		end
	end,
})

-- Show notification explaining keymaps when a snipped autocompletion is selected.
vim.api.nvim_create_autocmd("User", {
	pattern = "LuasnipPreExpand",
	callback = function()
		vim.notify("Use <C-l> and <C-h> to navigate snippet fields.", "INFO", { history = false })
	end,
})

-- https://github.com/sitiom/nvim-numbertoggle
-- Toggles relativenumber when entering insert mode.
vim.g.togglerelativenumber = vim.o.nu
local number_toggle_group = vim.api.nvim_create_augroup("numbertoggle", {})
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
	pattern = "*",
	group = number_toggle_group,
	callback = function()
		if not vim.g.togglerelativenumber then
			return
		end
		if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
			vim.opt.relativenumber = true
		end
	end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
	pattern = "*",
	group = number_toggle_group,
	callback = function()
		if not vim.g.togglerelativenumber then
			return
		end
		if vim.o.nu then
			vim.opt.relativenumber = false
			-- Conditional taken from https://github.com/rockyzhang24/dotfiles/commit/03dd14b5d43f812661b88c4660c03d714132abcf
			-- Workaround for https://github.com/neovim/neovim/issues/32068
			if not vim.tbl_contains({ "@", "-" }, vim.v.event.cmdtype) then
				vim.cmd("redraw")
			end
		end
	end,
})
