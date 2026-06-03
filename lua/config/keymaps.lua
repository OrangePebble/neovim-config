-- This file is mostly for keymaps that don't use plugins, the ones that do should go in the
--  corresponding plugin folder.

-- INFO: To define which-key keymap groups and icons go to: ../plugins/which-key.lua
-- INFO: To change descriptions for existing keymaps go to: ../plugins/which-key.lua
-- INFO: For LSP keymaps that depend on the buffer (buffer-local) go to: ../utils/lsp-on-attach.lua
-- INFO: For nvim-tree buffer-local keymaps go to: ../plugins/tree.lua
-- INFO: For completion (cmp) mappings go to: ../plugins/cmp.lua

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
keymap("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Yank to and paste from the system clipboard.
keymap({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard with motions" })
keymap("n", "<leader>Y", 'v$"+y', { desc = "Yank to clipboard until the end of the line" })
keymap("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
keymap("n", "<leader>P", '"+P', { desc = "Paste from clipboard before" })

-- Delete and paste without yanking (only on Visual mode so it doesn't interfere with other keymaps)
keymap("v", "<leader>d", '"_d', { desc = "Delete without yanking" })
keymap("v", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Clear search highlighting by pressing <Esc> in normal mode.
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Change increment number under cursor
keymap("n", "<C-S-x>", "<C-a>")

--== Toggles
keymap("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Line wrap" })
keymap("n", "<leader>tr", function()
	vim.opt.relativenumber = not vim.opt.relativenumber._value
	vim.g.togglerelativenumber = not vim.g.togglerelativenumber
end, { desc = "Relative line numbers" })
keymap("n", "<leader>tf", function()
	vim.g.autoformat = not vim.g.autoformat
end, { desc = "Formatting on save" })
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
keymap("n", "<leader>tl", "<cmd>Twilight<CR>", { desc = "Twilight" })

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
	require("todo-comments.fzf").todo({ keywords = to_fix_keywords })
end, { desc = "To do and fix" })
keymap("n", "<leader>sta", "<cmd>TodoFzfLua<CR>", { desc = "All" })
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
	vim.notify(string.format('Saved session "%s"', vim.fn.getcwd()), "INFO", { hide_from_history = true })
end, { desc = "Save" })
keymap("n", "<leader>\\l", function()
	require("resession").load(vim.fn.getcwd())
end, { desc = "Load" })
keymap("n", "<leader>\\d", function()
	require("resession").delete(vim.fn.getcwd())
end, { desc = "Delete" })
keymap("n", "<leader>\\i", function()
	vim.print(require("resession").get_current_session_info())
end, { desc = "Get info" })

--== Search
keymap("n", "<leader>ss", "<cmd>FzfLua builtin<CR>", { desc = "..." }) -- All FzfLua options
keymap("n", "<leader>sr", "<cmd>FzfLua resume<CR>", { desc = "Resume search" })
keymap("n", "<leader>sf", function()
	require("fzf-lua").files({
		-- Remove git submodules from search results.
		-- Default value:
		--  https://github.com/ibhagwan/fzf-lua/blob/d59f857c76eb474ec00debcf043f14fd001805cc/lua/fzf-lua/defaults.lua#L523
		fd_opts = [[--color=never --type f --type l -L --exclude .git $(git config --file .gitmodules --get-regexp path | awk 'BEGIN { ORS=" " }; { print "--exclude " $2 }')]],
	})
end, { desc = "Files" })
keymap("n", "<leader>sN", function()
	require("fzf-lua").files({
		cwd = vim.fn.stdpath("config"),
	})
end, { desc = "Neovim config" })
keymap("n", "<leader>si", function()
	require("fzf-lua").files({
		-- Basically add '--no-ignore' to the default value in
		--  https://github.com/ibhagwan/fzf-lua/blob/d59f857c76eb474ec00debcf043f14fd001805cc/lua/fzf-lua/defaults.lua#L523
		fd_opts = [[--color=never --type f --type l -L --exclude .git --no-ignore]],
	})
end, { desc = "Files (including ignored)" })
keymap("n", "<leader>so", "<cmd>FzfLua oldfiles<CR>", { desc = "Oldfiles" })
keymap("n", "<leader>sg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
keymap("n", "<leader>s/", "<cmd>FzfLua lgrep_curbuf<CR>", { desc = "Live grep current buffer" })
keymap("n", "<leader>sw", "<cmd>FzfLua grep_cword<CR>", { desc = "Grep word on cursor" })
keymap("n", "<leader>sb", "<cmd>FzfLua buffers<CR>", { desc = "Buffers" })
keymap("n", "<leader>sh", "<cmd>FzfLua helptags<CR>", { desc = "Help" })
keymap("n", "<leader>sc", "<cmd>FzfLua command_history<CR>", { desc = "Command history" })
keymap("n", "<leader>sd", "<cmd>FzfLua dap_breakpoints<CR>", { desc = "Debug breakpoints" })
keymap("n", "<leader>sq", "<cmd>FzfLua quickfix<CR>", { desc = "Quickfix list" })
keymap("n", "<leader>sn", function()
	require("notify.integrations").pick()
end, { desc = "Notifications" })

--== Trouble
keymap("n", "<leader>tq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
-- https://stackoverflow.com/questions/20933836/what-is-the-difference-between-location-list-and-quickfix-list-in-vim
-- Basically a single file quickfix list.
-- keymap("n", "<leader>tl", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })

--== markview
keymap("n", "<leader>tm", "<cmd>Markview Toggle<CR>", { desc = "Markview" })

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
keymap("n", "<leader>gn", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "']g' Next hunk" })
keymap("n", "[g", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous git hunk" })
keymap("n", "<leader>gp", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "'[g' Previous hunk" })
keymap("n", "]G", "<cmd>Gitsigns nav_hunk last<CR>", { desc = "Last git hunk" })
keymap("n", "<leader>gN", "<cmd>Gitsigns nav_hunk Last<CR>", { desc = "']G' Last hunk" })
keymap("n", "[G", "<cmd>Gitsigns nav_hunk first<CR>", { desc = "First git hunk" })
keymap("n", "<leader>gP", "<cmd>Gitsigns nav_hunk first<CR>", { desc = "'[G' First hunk" })

keymap("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
keymap("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage buffer" })
keymap("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
keymap("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
keymap("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })

keymap("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff" })
keymap("n", "<leader>gD", "<cmd>Gitsigns diffthis @<CR>", { desc = "Diff (last commit)" })

keymap("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Blame" })

keymap("n", "<leader>gts", "<cmd>Gitsigns toggle_signs<CR>", { desc = "Signs" })
keymap("n", "<leader>gtd", "<cmd>Gitsigns toggle_deleted<CR>", { desc = "Deleted" })
keymap("n", "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<CR>", { desc = "Word diff" })
keymap("n", "<leader>gtl", "<cmd>Gitsigns toggle_linehl<CR>", { desc = "Line highlight" })
keymap("n", "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Current line blame" })

keymap({ "o", "x" }, "ig", "<cmd>Gitsigns select_hunk<CR>", { desc = "Git hunk" })
keymap({ "o", "x" }, "ag", "<cmd>Gitsigns select_hunk<CR>", { desc = "Git hunk" })

--== LSP

-- Rename the variable under the cursor.
--  Most Language Servers support renaming across files, etc.
keymap("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename" })
keymap("n", "<leader>lR", vim.lsp.buf.rename, { desc = "Rename" })

-- Organize imports (most LSPs don't support this).
keymap("n", "<leader>lo", function()
	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })

-- A combination of many of the keymaps below.
keymap("n", "<leader>lf", "<cmd>FzfLua lsp_finder<CR>", { desc = "Finder (definitions, references, ...)" })

-- Jump to the definition of the word under the cursor. This is where
--  a variable was first declared, or where a function is defined, etc.
keymap("n", "<leader>ld", "<cmd>FzfLua lsp_definitions<CR>", { desc = "Definitions" })

-- Find references for the word under the cursor.
keymap("n", "<leader>lr", "<cmd>FzfLua lsp_references<CR>", { desc = "References" })

-- Jump to the implementation of the word under the cursor.
-- Useful when the language has ways of declaring types without an actual implementation.
keymap("n", "<leader>li", "<cmd>FzfLua lsp_implementations<CR>", { desc = "Implementations" })

-- Jump to the type of the word under the cursor
-- Useful when I'm not sure what type a variable is and I want to see
--  the definition of its type, not where it was defined.
keymap("n", "<leader>lT", "<cmd>FzfLua lsp_typedefs<CR>", { desc = "Type definitions" })

-- Fuzzy find all the symbols in the current document.
--  Symbols are things like variables, functions, types, etc.
keymap("n", "<leader>ls", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Document symbols" })

-- Fuzzy find all the symbols in the current workspace.
--  Similar to document symbols, except it searches over the entire project.
keymap("n", "<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })

-- Execute a code action (to fix an error or other). Usually the cursor needs to be on top of an
--  error or a suggestion from the LSP for this to activate.
keymap("n", "<leader>la", "<cmd>FzfLua lsp_code_actions<CR>", { desc = "Code action" })

--  In C this would take me to the header
keymap("n", "<leader>lD", "<cmd>FzfLua lsp_declarations<CR>", { desc = "Declarations" })

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
	require("fzf-lua").diagnostics_document()
end, { desc = "Search document diagnostics" })
keymap("n", "<leader>xw", function()
	require("fzf-lua").diagnostics_workspace()
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
keymap("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "Run/Continue" })
keymap("n", "<leader>da", function()
	require("dap").continue({
		before = function(config)
			local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
			local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

			config = vim.deepcopy(config)
			config.args = function()
				local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
				if config.type and config.type == "java" then
					return new_args
				end
				return require("dap.utils").splitstr(new_args)
			end
			return config
		end,
	})
end, { desc = "Run with args" })
keymap("n", "<leader>dC", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })
keymap("n", "<leader>dg", function()
	require("dap").goto_()
end, { desc = "Go to line (no execution)" })
keymap("n", "<leader>dj", function()
	require("dap").down()
end, { desc = "Down stack without stepping" })
keymap("n", "<leader>dk", function()
	require("dap").up()
end, { desc = "Up stack without stepping" })
keymap("n", "<leader>dl", function()
	require("dap").run_last()
end, { desc = "Repeat last run" })

keymap("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Step into" })
keymap("n", "]d", function()
	require("dap").step_into()
end, { desc = "Step into (debug)" })
keymap("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "Step over" })
keymap("n", "]D", function()
	require("dap").step_over()
end, { desc = "Step over (debug)" })
keymap("n", "<leader>dO", function()
	require("dap").step_out()
end, { desc = "Step out" })
keymap("n", "[d", function()
	require("dap").step_out()
end, { desc = "Step out (debug)" })
keymap("n", "<leader>dI", function()
	require("dap").step_back()
end, { desc = "Step back" })
keymap("n", "[D", function()
	require("dap").step_back()
end, { desc = "Step back (debug)" })

keymap("n", "<leader>dp", function()
	require("dap").pause()
end, { desc = "Pause" })
keymap("n", "<leader>dr", function()
	require("dap").repl.toggle()
end, { desc = "Toggle REPL" })
keymap("n", "<leader>ds", function()
	require("dap").terminate()
end, { desc = "Stop" })
keymap("n", "<leader>du", function()
	require("dapui").toggle({})
end, { desc = "Toggle DAP UI" })
keymap("n", "<leader>dw", function()
	require("dapui").elements.watches.add()
end, { desc = "Watch symbol on cursor" })
keymap({ "n", "x" }, "<leader>de", function()
	require("dapui").eval()
end, { desc = "Eval symbol on cursor" })

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
keymap("n", "<leader>oo", "<CMD>OverseerRun<CR>", { desc = "Run template task" })
keymap("n", "<leader>os", ":OverseerShell ", { desc = "Run shell command" })
keymap("n", "<leader>oS", ":OverseerShell! ", { desc = "Add shell task" })
keymap("n", "<leader>ot", "<CMD>OverseerToggle<CR>", { desc = "Toggle" })

--== Change
keymap(
	"n",
	"<leader>ct",
	":set tabstop=",
	{ desc = "How many spaces a tab is represented by, and the number of spaces pressing tab writes" }
)
keymap("n", "<leader>cf", "<cmd>FzfLua filetypes<CR>", { desc = "File type" })

--== Extras
keymap("n", "<leader>+q", ":cdo ", {
	desc = "[:cdo ] Do something for each quickfix item, like 's/' (use '/gc' flags as 'c' asks you every item if it is to apply)",
})
keymap("n", "<leader>+:", "q: ", {
	desc = "[q:] Open cmd window where you can see the history and use modes (insert, visual, ...). Open window in regular cmd with <C-f>",
})
keymap("n", "<leader>+w", "<cmd>W<CR>", {
	desc = "[:W] Custom command to save without formatting",
})
keymap("n", "<leader>+i", "<C-i>", {
	desc = "[<C-i>] Jump to next cursor position",
})
keymap("n", "<leader>+o", "<C-o>", {
	desc = "[<C-o>] Jump to last cursor position",
})
keymap("n", "<leader>+e", "<cmd>ene<CR>", {
	desc = "[:ene] Edit new and unnamed buffer",
})
keymap("n", "<leader>+m", "<cmd>marks<CR>", {
	desc = "[:marks] Show marks, use [m*] to add a mark to * and [`*]/['*] to go to the mark at the cursor/line",
})
keymap("n", "<leader>+r", "<cmd>registers<CR>", {
	desc = "[:registers] Show registers",
})
keymap("n", "<leader>+N", "<C-a>", {
	desc = "[<C-S-x>] Increment number under cursor. Original keymap is <C-a>.",
})
keymap("n", "<leader>+n", "<C-x>", {
	desc = "[<C-x>] Decrement number under cursor.",
})
keymap("n", "<leader>+s", ":Sops ", {
	desc = "[:Sops ] Edit/encrypt/decrypt/... files with sops.",
})
keymap("n", "<leader>+M", "<cmd>mes<CR>", {
	desc = "[:mes] Show all messages.",
})
