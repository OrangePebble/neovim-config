-- This file is mostly for keymaps that don't use plugins, the ones that do should go in the
--  corresponding plugin folder.

-- INFO: To define which-key keymap groups and icons go to: ../plugins/which-key.lua
-- INFO: To change descriptions for existing keymaps go to: ../plugins/which-key.lua
-- INFO: For LSP keymaps that depend on the buffer (buffer-local) go to: ../plugins/dev/lspconfig.lua
-- INFO: For nvim-tree buffer-local keymaps go to: ../plugins/tree.lua
-- INFO: For completion (blink.cmp) mappings go to: ../plugins/dev/blink-cmp.lua

local keymap = vim.keymap.set

--== Native Neovim keymaps

-- Center screen when jumping
keymap("n", "n", "nzzzv", { desc = "Next search result (centered)" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Better indenting in visual mode
keymap("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
keymap("n", "J", function()
	-- Using this method instead of "mzJ`z" so the 'z' mark isn't set.
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd("normal! J")
	vim.api.nvim_win_set_cursor(0, pos)
end, { desc = "Join lines and keep cursor position" })

-- Yank to and paste from the system clipboard.
keymap({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard with motions" })
keymap("n", "<leader>Y", 'v$"+y', { desc = "Yank to clipboard until the end of the line" })
keymap("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
keymap("n", "<leader>P", '"+P', { desc = "Paste from clipboard before" })

-- Delete and paste without yanking (only on Visual mode so it doesn't interfere with other keymaps)
keymap("x", "<leader>d", '"_d', { desc = "Delete without yanking" })
keymap("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Clear search highlighting by pressing <Esc> in normal mode.
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Change increment number under cursor
keymap("n", "<C-c>", "<C-a>")

-- Exit from Terminal insert mode by using escape.
keymap("t", "<Esc>", "<C-\\><C-n>")

-- I don't want the help keymap. vim.keymap.del doesn't work for this
keymap({ "n", "i", "x", "s", "o" }, "<F1>", "<nop>")

--== Toggles
keymap("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Line wrap" })
keymap("n", "<leader>tn", function()
	vim.opt.relativenumber = not vim.opt.relativenumber._value
	vim.g.togglerelativenumber = not vim.g.togglerelativenumber
end, { desc = "Relative line numbers" })
keymap("n", "<leader>tN", function()
	if vim.opt.number._value then
		vim.opt.number = false
		vim.opt.relativenumber = false
	else
		vim.opt.number = true
		vim.opt.relativenumber = vim.g.togglerelativenumber
		vim.opt.numberwidth = 3
	end
end, { desc = "Number column" })
keymap("n", "<leader>ta", function()
	vim.g.autoformat = not vim.g.autoformat
end, { desc = "Auto-format" })
keymap("n", "<leader>th", function()
	vim.g.minicursorword_disable = not vim.g.minicursorword_disable
end, { desc = "Cursor word highlighting" })
keymap("n", "<leader>tC", function()
	if vim.opt.conceallevel._value == 0 then
		vim.opt.conceallevel = 2
	else
		vim.opt.conceallevel = 0
	end
end, { desc = "Conceal level (0<->2)" })
keymap("n", "<leader>tc", "<cmd>HighlightColors Toggle<cr>", { desc = "Color highlighting" })
keymap("n", "<leader>td", function()
	vim.g.snacks_dim = not vim.g.snacks_dim
	if vim.g.snacks_dim then
		Snacks.dim.enable()
	else
		Snacks.dim.disable()
	end
end, { desc = "Dim" })
keymap("n", "<leader>ts", function()
	if vim.opt.signcolumn._value == "yes" then
		vim.opt.signcolumn = "no"
	else
		vim.opt.signcolumn = "yes"
	end
end, { desc = "Sign column" })
keymap("n", "<leader>tf", function()
	if vim.opt.signcolumn._value == "no" and not vim.opt.number._value then
		-- When both sign and number columns are hidden, toggle foldcolumn visibility instead
		if vim.opt.foldcolumn._value == "0" then
			vim.opt.foldcolumn = "1"
		else
			vim.opt.foldcolumn = "0"
		end
	else
		if vim.opt.foldcolumn._value == "0" then
			vim.opt.foldcolumn = "1"
			vim.opt.numberwidth = 3
		else
			if vim.opt.fillchars._value == "eob: ,fold: ,foldopen:󰅀,foldsep: ,foldinner: ,foldclose:󰅂" then
				vim.opt.fillchars = "eob: ,fold: ,foldopen: ,foldsep: ,foldinner: ,foldclose:󰅂"
			else
				vim.opt.fillchars = "eob: ,fold: ,foldopen:󰅀,foldsep: ,foldinner: ,foldclose:󰅂"
			end
		end
	end
end, { desc = "Fold column" })
keymap("n", "<leader>tW", function()
	local listchars = vim.opt.listchars:get()
	if listchars.space == "·" then
		vim.opt.listchars:append({ eol = " ", tab = "  ", space = " " })
	else
		vim.opt.listchars:append({ eol = "↲", tab = "| ", space = "·" })
	end
end, { desc = "Whitespace indicators" })
keymap("n", "<leader>ti", function()
	vim.g.snacks_indent = not vim.g.snacks_indent
	if vim.g.snacks_indent then
		Snacks.indent.enable()
	else
		Snacks.indent.disable()
	end
end, { desc = "Indent scope guide" })
keymap("n", "<leader>tb", function()
	vim.g.satellite = not vim.g.satellite
	if vim.g.satellite then
		vim.cmd("SatelliteEnable")
	else
		vim.cmd("SatelliteDisable")
	end
end, { desc = "Scrollbar" })

--== smart-splits and native window keymaps
keymap("n", "<leader>wh", function()
	require("smart-splits").move_cursor_left()
end, { desc = "<A-h> Move left" })
keymap("n", "<A-h>", function()
	require("smart-splits").move_cursor_left()
end, { desc = "Move to the left window" })

keymap("n", "<leader>wj", function()
	require("smart-splits").move_cursor_down()
end, { desc = "<A-j> Move down" })
keymap("n", "<A-j>", function()
	require("smart-splits").move_cursor_down()
end, { desc = "Move to the bottom window" })

keymap("n", "<leader>wk", function()
	require("smart-splits").move_cursor_up()
end, { desc = "<A-k> Move up" })
keymap("n", "<A-k>", function()
	require("smart-splits").move_cursor_up()
end, { desc = "Move to the top window" })

keymap("n", "<leader>wl", function()
	require("smart-splits").move_cursor_right()
end, { desc = "<A-l> Move right" })
keymap("n", "<A-l>", function()
	require("smart-splits").move_cursor_right()
end, { desc = "Move to the right window" })

keymap("n", "<leader>w;", function()
	require("smart-splits").move_cursor_previous()
end, { desc = "Move to previous (inc. floating)" })
-- keymap("n", "<A-;>", function()
-- 	require("smart-splits").move_cursor_previous()
-- end, { desc = "Move to the previous window (including floating)" })

keymap("n", "<leader>wH", function()
	require("smart-splits").resize_left()
end, { desc = "<A-S-h> Resize left" })
keymap("n", "<A-S-h>", function()
	require("smart-splits").resize_left()
end, { desc = "Resize window left" })

keymap("n", "<leader>wJ", function()
	require("smart-splits").resize_down()
end, { desc = "<A-S-j> Resize down" })
keymap("n", "<A-S-j>", function()
	require("smart-splits").resize_down()
end, { desc = "Resize window down" })

keymap("n", "<leader>wK", function()
	require("smart-splits").resize_up()
end, { desc = "<A-S-k> Resize up" })
keymap("n", "<A-S-k>", function()
	require("smart-splits").resize_up()
end, { desc = "Resize window up" })

keymap("n", "<leader>wL", function()
	require("smart-splits").resize_right()
end, { desc = "<A-S-l> Resize right" })
keymap("n", "<A-S-l>", function()
	require("smart-splits").resize_right()
end, { desc = "Resize window right" })

keymap("n", "<leader>w<C-h>", function()
	require("smart-splits").swap_buf_left()
end, { desc = "<A-C-h> Swap left" })
keymap("n", "<A-C-h>", function()
	require("smart-splits").swap_buf_left()
end, { desc = "Swap buffer left" })

keymap("n", "<leader>w<C-j>", function()
	require("smart-splits").swap_buf_down()
end, { desc = "<A-C-j> Swap down" })
keymap("n", "<A-C-j>", function()
	require("smart-splits").swap_buf_down()
end, { desc = "Swap buffer down" })

keymap("n", "<leader>w<C-k>", function()
	require("smart-splits").swap_buf_up()
end, { desc = "<A-C-k> Swap up" })
keymap("n", "<A-C-k>", function()
	require("smart-splits").swap_buf_up()
end, { desc = "Swap buffer up" })

keymap("n", "<leader>w<C-l>", function()
	require("smart-splits").swap_buf_right()
end, { desc = "<A-C-l> Swap right" })
keymap("n", "<A-C-l>", function()
	require("smart-splits").swap_buf_right()
end, { desc = "Swap buffer right" })

keymap("n", "<leader>ww", function()
	require("which-key").show({ keys = "<C-w>" })
end, { desc = "Native window keymaps" })
keymap("n", "<leader>w-", "<C-w>s", { desc = "Split horizontally" })
keymap("n", "<leader>w\\", "<C-w>v", { desc = "Split vertically" })
keymap("n", "<leader>wq", "<C-w>q", { desc = "Close this window" })
keymap("n", "<leader>wo", "<C-w>o", { desc = "Close all other windows" })
keymap("n", "<leader>w=", "<C-w>=", { desc = "Equal height and width" })
keymap("n", "<leader>w_", "<C-w>_", { desc = "Max height" })
keymap("n", "<leader>w|", "<C-w>|", { desc = "Max width" })

-- This can cause a which-key recursion error when resizing too much, but so can holding down 'y', so whatever.
keymap("n", "<C-w><space>", function()
	require("which-key").show({ keys = "<C-w>", loop = true })
end, { desc = "Repeating (hydra mode)" })
keymap("n", "<leader>w<space>", function()
	require("which-key").show({ keys = "<leader>w", loop = true })
end, { desc = "Repeating (hydra mode)" })

--== which-key

-- Show global which-key keymaps.
-- Can also usually be reached by pressing backspace 1+ times in which-key.
keymap("n", "<leader>?g", function()
	require("which-key").show({ global = true })
end, { desc = "Global [<BS><BS>]" })
-- Show buffer-local keymaps (LSP, nvim-tree, ...).
keymap("n", "<leader>?l", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer-local (LSP, nvim-tree, ...)" })

--== nvim-tree
keymap("n", "<leader>te", "<Cmd>NvimTreeFindFileToggle<CR>", { desc = "File explorer (Tree)" })
keymap("n", "<leader>e", "<Cmd>NvimTreeFindFileToggle<CR>", { desc = "File explorer (Tree)" })

--== undotree
keymap("n", "<leader>tu", function()
	vim.cmd.UndotreeToggle()
	vim.cmd.UndotreeFocus()
end, { desc = "Undotree" })
keymap("n", "<leader>u", function()
	vim.cmd.UndotreeToggle()
	vim.cmd.UndotreeFocus()
end, { desc = "Undotree" })

--== TODO

-- 'to_fix_keywords' are the relevant keywords I usually care about.
local to_fix_keywords = { "TODO", "FIX", "FIXME" }

-- Search and toggle workspace TODOs
keymap("n", "<leader>stt", function()
	Snacks.picker.todo_comments({ keywords = to_fix_keywords })
end, { desc = "To do and fix" })
keymap("n", "<leader>sta", function()
	Snacks.picker.todo_comments()
end, { desc = "All" })
keymap("n", "<leader>ttt", function()
	require("trouble").toggle({ mode = "todo", filter = { tag = to_fix_keywords } })
end, { desc = "To do and fix" })
keymap("n", "<leader>tta", function()
	require("trouble").toggle("todo")
end, { desc = "All" })

-- Jumps to TODOs, these replace tab jumps but I don't use tabs.
-- Doesn't work across files, but neither does diagnostics, so if I want that just use quickfix.
keymap("n", "]t", function()
	require("todo-comments").jump_next({ keywords = to_fix_keywords })
end, { desc = "Next todo" })
keymap("n", "[t", function()
	require("todo-comments").jump_prev({ keywords = to_fix_keywords })
end, { desc = "Previous todo" })
vim.keymap.del("n", "]T")
vim.keymap.del("n", "[T")

--== Resession
keymap("n", "<leader>\\s", function()
	require("resession").save(vim.fn.getcwd(), { notify = false })
	vim.notify(
		string.format('Saved session "%s"', vim.fn.getcwd()),
		vim.log.levels.INFO,
		{ history = false, timeout = 1000 }
	)
end, { desc = "Save" })
keymap("n", "<leader>\\l", function()
	require("resession").load(vim.fn.getcwd())
end, { desc = "Load" })
keymap("n", "<leader>\\d", function()
	require("resession").delete(vim.fn.getcwd())
	vim.g.resession_deleted = true
end, { desc = "Delete" })
keymap("n", "<leader>\\i", function()
	vim.print(require("resession").get_current_session_info())
end, { desc = "Get info" })

--== Search
keymap("n", "<leader>ss", function()
	Snacks.picker()
end, { desc = "..." })
keymap("n", "<leader>sR", function()
	Snacks.picker.resume()
end, { desc = "Resume search" })
keymap("n", "<leader>sf", function()
	---@type snacks.picker.files.Config
	Snacks.picker.files({
		follow = true, -- Follow symlinks.
		hidden = true, -- Search dot-files.
	})
	vim.notify(
		string.format("Use <A-i> to toggle git-ignored files.", vim.fn.getcwd()),
		vim.log.levels.INFO,
		{ history = false }
	)
end, { desc = "Files" })
keymap("n", "<leader>sF", function()
	---@type snacks.picker.files.Config
	Snacks.picker.files({
		follow = true, -- Follow symlinks.
		hidden = true, -- Search dot-files.
		-- Remove git submodules from search results.
		exclude = vim.tbl_map(function(l)
			return l:match(" (%S+)$")
		end, vim.fn.systemlist("git config --file .gitmodules --get-regexp path 2>/dev/null")),
	})
end, { desc = "Files (excluding submodules)" })
keymap("n", "<leader>sN", function()
	---@type snacks.picker.files.Config
	Snacks.picker.files({
		follow = true, -- Follow symlinks.
		hidden = true, -- Search dot-files.
		dirs = { vim.fn.stdpath("config") },
	})
end, { desc = "Neovim config" })
keymap("n", "<leader>sr", function()
	Snacks.picker.recent()
end, { desc = "Recent files" })
keymap("n", "<leader>sg", function()
	-- I've thought about using `Snacks.picker.resume({ source = "grep" })` to automatically use the
	--  last search but using the keymaps to manually go through history is probably better.
	Snacks.picker.grep({
		follow = true, -- Follow symlinks.
		hidden = true, -- Search dot-files.
		limit_live = 999999,
	})
	vim.notify(
		string.format("Append '-- -g **/*' to glob filter directories.", vim.fn.getcwd()),
		vim.log.levels.INFO,
		{ history = false }
	)
	vim.notify(
		string.format("Use <C-G> to toggle live mode and fuzzy filter results.", vim.fn.getcwd()),
		vim.log.levels.INFO,
		{ history = false }
	)
end, { desc = "Grep" })
keymap("n", "<leader>s/", function()
	Snacks.picker.lines()
end, { desc = "Grep current buffer" })
keymap({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word({
		follow = true, -- Follow symlinks.
		hidden = true, -- Search dot-files.
	})
end, { desc = "Grep word on cursor" })
keymap("n", "<leader>sb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
keymap("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "Help" })
keymap("n", "<leader>sc", function()
	Snacks.picker.command_history()
end, { desc = "Command history" })
keymap("n", "<leader>sH", function()
	Snacks.picker.search_history()
end, { desc = "Search history" })
keymap("n", "<leader>sq", function()
	Snacks.picker.qflist()
end, { desc = "Quickfix list" })
keymap("n", "<leader>sn", function()
	Snacks.picker.notifications()
end, { desc = "Notifications" })

--== Trouble
keymap("n", "<leader>tq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
-- https://stackoverflow.com/questions/20933836/what-is-the-difference-between-location-list-and-quickfix-list-in-vim
-- Basically a single file quickfix list.
-- keymap("n", "<leader>tl", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })

--== markview
keymap("n", "<leader>tm", "<cmd>Markview Toggle<CR>", { desc = "Markview" })
keymap("n", "<leader>tM", "<CMD>Markview HybridToggle<CR>", { desc = "Markview hybrid mode" })

--== harpoon
keymap("n", "<leader><leader>j", function()
	require("harpoon"):list():select(1)
end, { desc = "Select 1" })
keymap("n", "<leader><leader>k", function()
	require("harpoon"):list():select(2)
end, { desc = "Select 2" })
keymap("n", "<leader><leader>l", function()
	require("harpoon"):list():select(3)
end, { desc = "Select 3" })
keymap("n", "<leader><leader>;", function()
	require("harpoon"):list():select(4)
end, { desc = "Select 4" })
keymap("n", "<leader><leader>m", function()
	require("harpoon"):list():select(5)
end, { desc = "Select 5" })
keymap("n", "<leader><leader>,", function()
	require("harpoon"):list():select(6)
end, { desc = "Select 6" })
keymap("n", "<leader><leader>.", function()
	require("harpoon"):list():select(7)
end, { desc = "Select 7" })
keymap("n", "<leader><leader>/", function()
	require("harpoon"):list():select(8)
end, { desc = "Select 8" })
keymap("n", "<leader><leader>n", function()
	require("harpoon"):list():next()
end, { desc = "Select next" })
keymap("n", "<leader><leader>p", function()
	require("harpoon"):list():prev()
end, { desc = "Select previous" })
keymap("n", "<leader><leader>a", function()
	require("harpoon"):list():add()
end, { desc = "Add" })
keymap("n", "<leader><leader><leader>", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Open list" })

--== Git
keymap("n", "]g", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Next git hunk" })
keymap("n", "<leader>g]", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "']g' Next hunk" })
keymap("n", "[g", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous git hunk" })
keymap("n", "<leader>g[", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "'[g' Previous hunk" })
keymap("n", "]G", "<cmd>Gitsigns nav_hunk last<CR>", { desc = "Last git hunk" })
keymap("n", "<leader>g}", "<cmd>Gitsigns nav_hunk Last<CR>", { desc = "']G' Last hunk" })
keymap("n", "[G", "<cmd>Gitsigns nav_hunk first<CR>", { desc = "First git hunk" })
keymap("n", "<leader>g{", "<cmd>Gitsigns nav_hunk first<CR>", { desc = "'[G' First hunk" })
keymap("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		require("gitsigns").nav_hunk("next")
	end
end, { desc = "Next change" })
keymap("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		require("gitsigns").nav_hunk("prev")
	end
end, { desc = "Previous change" })

keymap({ "n", "v" }, "<leader>gs", function()
	require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage hunk" })
keymap("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage buffer" })
keymap({ "n", "v" }, "<leader>gr", function()
	require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset hunk" })
keymap("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
keymap("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
keymap("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })

keymap("n", "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>", { desc = "Preview hunk" })
keymap("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff" })
keymap("n", "<leader>gD", "<cmd>Gitsigns diffthis HEAD~1<CR>", { desc = "Diff (last commit)" })

keymap("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Blame" })

keymap("n", "<leader>gts", "<cmd>Gitsigns toggle_signs<CR>", { desc = "Signs" })
keymap("n", "<leader>gtd", "<cmd>Gitsigns toggle_deleted<CR>", { desc = "Deleted" })
keymap("n", "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<CR>", { desc = "Word diff" })
keymap("n", "<leader>gtl", "<cmd>Gitsigns toggle_linehl<CR>", { desc = "Line highlight" })
keymap("n", "<leader>gtn", "<cmd>Gitsigns toggle_numhl<CR>", { desc = "Number highlight" })
keymap("n", "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Current line blame" })
keymap("n", "<leader>gtB", "<cmd>Gitsigns blame<cr>", { desc = "All line blames" })

keymap({ "o", "x" }, "ig", "<cmd>Gitsigns select_hunk<CR>", { desc = "Git hunk" })
keymap({ "o", "x" }, "ag", "<cmd>Gitsigns select_hunk<CR>", { desc = "Git hunk" })

keymap("n", "<leader>gl", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })

-- https://github.com/Muizzyranking/dot-files/blob/2681a4dd0ba7ed6995845877b49be1f789cd7720/config/nvim/lua/plugins/editor/git.lua#L22-L50
vim.keymap.set("n", "q", function()
	local has_diff = vim.wo.diff
	-- If not in diff view, just passthrough 'q'.
	if not has_diff then
		return "q"
	end

	local target_win
	-- Go through all windows and its buffer.
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		local bufname = vim.api.nvim_buf_get_name(buf)
		-- If the buffer is from gitsigns, set it as the target to close.
		if bufname:find("^gitsigns://") then
			target_win = win
			break
		end
	end

	-- Close the target window if it was found before.
	if target_win then
		vim.schedule(function()
			vim.api.nvim_win_close(target_win, true)
		end)
		return ""
	end

	-- If diff view was active but the target window was not found just passthrough 'q'.
	return "q"
end, { expr = true, silent = true })

--== LSP

-- Rename the variable under the cursor.
--  Most Language Servers support renaming across files, etc.
keymap("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })

-- Organize imports (most LSPs don't support this).
keymap("n", "<leader>lo", function()
	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })

-- Jump to the definition of the word under the cursor. This is where
--  a variable was first declared, or where a function is defined, etc.
keymap("n", "<leader>ld", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Definitions" })

-- Find references for the word under the cursor.
keymap("n", "<leader>lR", function()
	Snacks.picker.lsp_references()
end, { desc = "References" })

-- Jump to the implementation of the word under the cursor.
-- Useful when the language has ways of declaring types without an actual implementation.
keymap("n", "<leader>li", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Implementations" })

-- Jump to the type of the word under the cursor
-- Useful when I'm not sure what type a variable is and I want to see
--  the definition of its type, not where it was defined.
keymap("n", "<leader>lT", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Type definitions" })

-- Fuzzy find all the symbols in the current document.
--  Symbols are things like variables, functions, types, etc.
keymap("n", "<leader>ls", function()
	Snacks.picker.lsp_symbols()
end, { desc = "Document symbols" })

-- Fuzzy find all the symbols in the current workspace.
--  Similar to document symbols, except it searches over the entire project.
keymap("n", "<leader>lS", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "Workspace symbols" })

-- Execute a code action (to fix an error or other). Usually the cursor needs to be on top of an
--  error or a suggestion from the LSP for this to activate.
keymap("n", "<leader>la", function()
	vim.lsp.buf.code_action()
end, { desc = "Code action" })

--  In C this would take me to the header
keymap("n", "<leader>lD", function()
	Snacks.picker.lsp_declarations()
end, { desc = "Declarations" })

-- The other keymaps aren't buffer-local so this might as well become global.
vim.keymap.set("n", "K", function()
	vim.lsp.buf.hover()
end, { desc = "LSP Hover" })

-- Toggles
keymap(
	"n",
	"<leader>lts",
	"<cmd>Trouble lsp_document_symbols toggle focus=false multiline=false win.position=right<cr>",
	{ desc = "LSP Document Symbols" }
)
keymap(
	"n",
	"<leader>ltl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP definitions, references, ..." }
)
keymap("n", "<leader>lth", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Inlay hints" })

--== Diagnostics
keymap("n", "[x", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
keymap("n", "]x", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
keymap("n", "[X", function()
	vim.diagnostic.jump({ count = -999, float = true })
end, { desc = "First diagnostic" })
keymap("n", "]X", function()
	vim.diagnostic.jump({ count = 999, float = true })
end, { desc = "Last diagnostic" })
keymap("n", "<leader>xc", function()
	vim.diagnostic.open_float({ scope = "cursor" })
end, { desc = "Cursor diagnostics" })
keymap("n", "<leader>xl", function()
	vim.diagnostic.open_float({ scope = "line" })
end, { desc = "Line diagnostics" })
keymap("n", "<leader>xd", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Search document diagnostics" })
keymap("n", "<leader>xw", function()
	Snacks.picker.diagnostics()
end, { desc = "Search workspace diagnostics" })
keymap("n", "<leader>xtv", require("utils.diagnostics").toggle_virtual_lines, { desc = "Virtual lines" })
keymap("n", "<leader>xtd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Document diagnostics" })
keymap("n", "<leader>xtw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace diagnostics" })

--== DAP
keymap("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Set breakpoint condition" })
keymap("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })

-- TODO: think about making separate run/continue keybinds and renaming "Run to cursor" to "Continue to cursor"
keymap("n", "<leader>dr", function()
	require("dap").continue()
end, { desc = "Run/Continue" })
keymap("n", "<leader>dR", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })
keymap("n", "<leader>dl", function()
	require("dap").run_last()
end, { desc = "Repeat last run" })
keymap("n", "<leader>dp", function()
	require("dap").pause()
end, { desc = "Pause" })
keymap("n", "<leader>dq", function()
	require("dap").terminate()
end, { desc = "Quit" })

keymap("n", "<leader>dg", function()
	require("dap").goto_()
end, { desc = "Go to line (no execution)" })
keymap("n", "<leader>dj", function()
	require("dap").down()
end, { desc = "Down stack without stepping" })
keymap("n", "<leader>dk", function()
	require("dap").up()
end, { desc = "Up stack without stepping" })

keymap("n", "]d", function()
	require("dap").step_over()
end, { desc = "Step over (debug)" })
keymap("n", "]D", function()
	require("dap").step_into()
end, { desc = "Step into (debug)" })
keymap("n", "[d", function()
	require("dap").step_back()
end, { desc = "Step back (debug)" })
keymap("n", "[D", function()
	require("dap").step_out()
end, { desc = "Step out (debug)" })
keymap("n", "<leader>ds", function()
	require("dap").step_over()
end, { desc = "Step over" })
keymap("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Step into" })
keymap("n", "<leader>dS", function()
	require("dap").step_back()
end, { desc = "Step back" })
keymap("n", "<leader>dI", function()
	require("dap").step_out()
end, { desc = "Step out" })

keymap("n", "<leader>dw", function()
	require("dapui").elements.watches.add()
end, { desc = "Watch symbol on cursor" })
keymap({ "n" }, "<leader>de", function()
	require("dapui").eval()
end, { desc = "Eval symbol on cursor" })
keymap({ "x" }, "<leader>e", function()
	require("dapui").eval()
end, { desc = "Eval symbol on cursor (debug)" })

keymap("n", "<leader>dtr", function()
	require("dap").repl.toggle({}, "belowright 12split")
end, { desc = "Toggle REPL" })
keymap("n", "<leader>dtu", function()
	require("dapui").toggle({})
end, { desc = "Toggle DAP UI" })
keymap("n", "<leader>dtv", function()
	require("nvim-dap-virtual-text").toggle()
end, { desc = "Virtual text" })

--== Testing

keymap("n", "<leader>Tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run file" })
keymap("n", "<leader>TF", function()
	require("neotest").run.run(vim.uv.cwd())
end, { desc = "Run all test files" })
keymap("n", "<leader>Tn", function()
	require("neotest").run.run()
end, { desc = "Run nearest" })
keymap("n", "<leader>Td", function()
	require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest" })
keymap("n", "<leader>Tl", function()
	require("neotest").run.run_last()
end, { desc = "Rerun last" })
keymap("n", "<leader>Ts", function()
	require("neotest").run.stop()
end, { desc = "Stop" })

keymap("n", "<leader>Ta", function()
	require("neotest").run.attach()
end, { desc = "Attach to test" })

keymap("n", "<leader>To", function()
	require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Show output" })

keymap("n", "<leader>Tts", function()
	require("neotest").summary.toggle()
end, { desc = "Summary" })
keymap("n", "<leader>Tto", function()
	require("neotest").output_panel.toggle()
end, { desc = "Output" })
keymap("n", "<leader>Ttw", function()
	require("neotest").watch.toggle(vim.fn.expand("%"))
end, { desc = "Watch file" })
keymap("n", "<leader>Ttx", function()
	require("neotest").diagnostic()
end, { desc = "Display errors in diagnostics" })
keymap("n", "<leader>TtS", function()
	require("neotest").status()
end, { desc = "Signcolumn signs" })

--== Overseer
keymap("n", "<leader>rt", "<CMD>OverseerCustomRun<CR>", { desc = "Run template task" })
keymap("n", "<leader>rr", function()
	-- https://github.com/stevearc/overseer.nvim/blob/a93d9f6d6defdac4bcd6d2c8ba988650e42e0a0e/doc/recipes.md#restart-last-task
	local overseer = require("overseer")
	local tasks = overseer.list_tasks()
	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks found.", vim.log.levels.WARN)
		return
	end
	overseer.run_action(tasks[1], "restart")
end, { desc = "Restart last task" })
keymap("n", "<leader>rR", function()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks()
	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks found.", vim.log.levels.WARN)
		return
	end
	local last_task = tasks[1]
	if type(last_task.cmd) ~= "string" then
		vim.notify("Last task is not a shell command.", vim.log.levels.ERROR)
		return
	end
	vim.ui.input({
		prompt = "cmd: ",
		--- Solved in the if above.
		---@diagnostic disable-next-line: assign-type-mismatch
		default = last_task.cmd,
	}, function(input)
		if last_task.name == last_task.cmd then
			last_task.name = input
		end
		last_task.cmd = input
		overseer.run_action(last_task, "restart")
	end)
end, { desc = "Edit and restart last task" })
keymap("n", "<leader>rs", ":OverseerShell ", { desc = "Run shell command" })
keymap("n", "<leader>rS", ":OverseerShell! ", { desc = "Add shell task" })
keymap("n", "<leader>rl", function()
	require("overseer").toggle({ enter = false })
end, { desc = "Toggle task list and outputs" })

--== OpenCode
keymap({ "n", "x" }, "<leader>aa", function()
	require("opencode").ask("", { submit = true })
end, { desc = "Ask" })
keymap({ "n", "x" }, "<leader>as", function()
	require("opencode").select()
end, { desc = "Select action" })
keymap({ "n", "x" }, "<leader>ar", function()
	return require("opencode").operator("@this ")
end, { desc = "Add range", expr = true })
keymap("n", "<leader>al", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line", expr = true })
keymap("n", "<leader>ab", function()
	return require("opencode").operator("@buffer ") .. "_"
end, { desc = "Add buffer", expr = true })
keymap("n", "<leader>ax", function()
	if #vim.diagnostic.get(0) > 0 then
		return require("opencode").operator("@diagnostics ") .. "_"
	end
	vim.defer_fn(function()
		vim.notify("No diagnostics found.", vim.log.levels.ERROR, { history = false })
	end, 0)
end, { desc = "Add diagnostics", expr = true })
keymap("n", "<leader>aq", function()
	if #vim.fn.getqflist() > 0 then
		return require("opencode").operator("@quickfix ") .. "_"
	else
		vim.defer_fn(function()
			vim.notify("The quickfix list is empty.", vim.log.levels.ERROR, { history = false })
		end, 0)
	end
end, { desc = "Add quickfix list", expr = true })

--== Change
keymap(
	"n",
	"<leader>ct",
	":set tabstop=",
	{ desc = "How many spaces a tab is represented by, and the number of spaces pressing tab writes" }
)
keymap("n", "<leader>cf", function()
	Snacks.picker.select(vim.fn.getcompletion("", "filetype"), { prompt = "File type:" }, function(ft)
		if ft then
			vim.bo.filetype = ft
		end
	end)
end, { desc = "File type" })

--== Extras
keymap("n", "<leader>+:q", ":cdo ", {
	desc = "[:cdo ] Do something for each quickfix item, like 's/' (use '/gc' flags as 'c' asks you every item if it is to apply)",
})
keymap("n", "<leader>+:q", "<CMD>cgetexpr []<CR>", {
	desc = "[:cgetexpr []] Clear the quickfix list",
})
keymap("n", "<leader>+::", "q: ", {
	desc = "[q:] (<C-f> in cmd) Open cmd window where you can see the history and use modes (insert, visual, ...).",
})
keymap("n", "<leader>+:w", "<cmd>W<CR>", {
	desc = "[:W] Custom command to save without formatting",
})
keymap("n", "<leader>+i", "<C-i>", {
	desc = "[<C-i>] Jump to next cursor position",
})
keymap("n", "<leader>+o", "<C-o>", {
	desc = "[<C-o>] Jump to last cursor position",
})
keymap("n", "<leader>+:e", "<cmd>ene<CR>", {
	desc = "[:ene] Edit new and unnamed buffer",
})
keymap("n", "<leader>+:m", "<cmd>marks<CR>", {
	desc = "[:marks] Show marks, use [m*] to add a mark to * and [`*]/['*] to go to the mark at the cursor/line",
})
keymap("n", "<leader>+:d", ":delm ", {
	desc = "[:delm ] Delete a mark. Use [:delm z] to delete the 'z' mark.",
})
keymap("n", "<leader>+:r", "<cmd>registers<CR>", {
	desc = "[:registers] Show registers, use [\"#p] to paste the '#' register (alternate file)",
})
keymap("n", "<leader>+N", "<C-a>", {
	desc = "[<C-c>] Increment number under cursor. Original keymap is <C-a>.",
})
keymap("n", "<leader>+n", "<C-x>", {
	desc = "[<C-x>] Decrement number under cursor.",
})
keymap("n", "<leader>+:S", ":Sops ", {
	desc = "[:Sops ] Edit/encrypt/decrypt/... files with sops.",
})
keymap("n", "<leader>+:M", "<cmd>mes<CR>", {
	desc = "[:mes] Show all messages.",
})
keymap("n", "<leader>+:s", "<cmd>sort<CR>", {
	desc = "[:sort i] Sort the buffer's lines alphabetically case-insensitively. Can be used on a selection. Add '!' for reverse, 'u' for removing duplicates, and 'n' for numeric sort.",
})
keymap("n", "<leader>+gt", "gt", {
	desc = "[gt] Go to next tab.",
})
keymap("n", "<leader>+gT", "gT", {
	desc = "[gT] Go to previous tab.",
})
keymap("n", "<leader>+gu", "gu", {
	desc = "[gu] Change to lowercase.",
})
keymap("n", "<leader>+gU", "gU", {
	desc = "[gU] Change to uppercase.",
})
keymap("n", "<leader>+g<", "g<", {
	desc = "[g<] Reopen last command output.",
})
keymap("n", "<leader>+gv", "gv", {
	desc = "[gv] Reselect last visual selection.",
})
-- Useful because lualine doesn't print the full buffer name.
keymap("n", "<leader>+b", function()
	vim.print(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
end, {
	desc = "Print the current buffer's name.",
})
keymap("n", "<leader>+l", "<C-l>", {
	desc = "[<C-l>] Move to previous snippet field.",
})
keymap("n", "<leader>+h", "<C-h>", {
	desc = "[<C-h>] Move to next snippet field.",
})
keymap("n", "<leader>+!", "!", {
	desc = "[!] Print the contents of a command in the buffer.",
})
keymap("n", "<leader>+~", "~", {
	desc = "[~] Toggle the case of the character under the cursor.",
})
