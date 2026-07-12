return {
	"folke/snacks.nvim",
	lazy = false,
	init = function()
		vim.g.snacks_dim = false
		vim.g.snacks_indent = true
	end,
	---@module "snacks"
	---@type snacks.Config
	opts = {
		dim = { enabled = true },
		lazygit = { configure = true },
		indent = {
			enabled = true,
			animate = { enabled = false },
			indent = { char = "" },
			scope = { hl = "SnacksIndent" },
			chunk = {
				enabled = true,
				char = {
					horizontal = "",
					arrow = "",
				},
				hl = "SnacksIndent",
			},
		},
		notifier = {
			enabled = true,
			-- Same as the default "compact" but with left aligned title.
			style = function(buf, notif, ctx)
				local title = vim.trim(notif.icon .. " " .. (notif.title or ""))
				if title ~= "" then
					ctx.opts.title = { { " " .. title .. " ", ctx.hl.title } }
					ctx.opts.title_pos = "left"
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
			end,
		},
		picker = {
			enabled = true,
			layouts = {
				vertical = {
					layout = {
						width = 0.8, -- Thicker than default
						min_width = 80, -- The threshold at which the layout fills the screen width
					},
				},
			},
			layout = {
				preset = function()
					-- 120 is the default
					return vim.o.columns >= 160 and "default" or "vertical"
				end,
			},
			actions = {
				toggle_preview_position = function(picker)
					local vertical = Snacks.picker.config.layout("vertical")
					if vim.deep_equal(picker.resolved_layout, vertical) then
						picker:set_layout("default")
					else
						picker:set_layout("vertical")
					end
				end,
			},
			win = {
				input = {
					-- footer_keys = { "?" },
					-- footer_pos = "right",
					keys = {
						["?"] = { "toggle_help_input", desc = "Help" },
						["<CR>"] = { "confirm", mode = { "i", "n" }, desc = "Confirm" },
						["<Esc>"] = { "cancel", desc = "Cancel" },
						["q"] = { "cancel", desc = "Cancel" },
						["<Up>"] = { "history_back", mode = { "i", "n" }, desc = "History back" },
						["<Down>"] = { "history_forward", mode = { "i", "n" }, desc = "History forward" },
						["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" }, desc = "Select and up" },
						["<Tab>"] = { "select_and_next", mode = { "i", "n" }, desc = "Select and down" },
						["<A-d>"] = { "inspect", mode = { "i", "n" }, desc = "Inspect" },
						["<A-f>"] = { "toggle_follow", mode = { "i", "n" }, desc = "Toggle follow symlinks" },
						["<A-h>"] = { "toggle_hidden", mode = { "i", "n" }, desc = "Toggle hidden" },
						["<A-i>"] = { "toggle_ignored", mode = { "i", "n" }, desc = "Toggle ignored" },
						["<A-r>"] = { "toggle_regex", mode = { "i", "n" }, desc = "Toggle regex" },
						["<A-m>"] = { "toggle_maximize", mode = { "i", "n" }, desc = "Toggle maximize" },
						["<A-P>"] = { "toggle_preview", mode = { "i", "n" }, desc = "Toggle preview" },
						["<A-p>"] = { "toggle_preview_position", mode = { "i", "n" }, desc = "Toggle preview location" },
						["<C-g>"] = { "toggle_live", mode = { "i", "n" }, desc = "Toggle live grep" },
						["<A-w>"] = { "cycle_win", mode = { "i", "n" }, desc = "Cycle window focus" },
						["<C-a>"] = { "select_all", mode = { "i", "n" }, desc = "Select all" },
						["<C-b>"] = { "preview_scroll_up", mode = { "i", "n" }, desc = "Scroll preview up" },
						["<C-f>"] = { "preview_scroll_down", mode = { "i", "n" }, desc = "Scroll preview down" },
						["<C-u>"] = { "list_scroll_up", mode = { "i", "n" }, desc = "Scroll list up" },
						["<C-d>"] = { "list_scroll_down", mode = { "i", "n" }, desc = "Scroll list down" },
						["<C-n>"] = { "list_down", mode = { "i", "n" }, desc = "List down" },
						["<C-p>"] = { "list_up", mode = { "i", "n" }, desc = "List up" },
						["j"] = { "list_down", desc = "List down" },
						["k"] = { "list_up", desc = "List up" },
						["G"] = { "list_bottom", desc = "List bottom" },
						["gg"] = { "list_top", desc = "List top" },
						["<C-q>"] = { "qflist", mode = { "i", "n" }, desc = "Add list to quickfix" },
						["<C-t>"] = { "tab", mode = { "i", "n" }, desc = "Open in tab" },
						["<C-s>"] = { "edit_split", mode = { "i", "n" }, desc = "Open in split" },
						["<C-v>"] = { "edit_vsplit", mode = { "i", "n" }, desc = "Open in vsplit" },
						["<C-r><C-a>"] = { "insert_alt", mode = { "i", "n" }, desc = "Insert alternative window" },
						["<C-r><C-f>"] = { "insert_filename", mode = { "i", "n" }, desc = "Insert file path" },
						["<C-r><C-w>"] = { "insert_cword", mode = { "i", "n" }, desc = "Insert word on cursor" },
						["<C-r><C-l>"] = { "insert_line", mode = { "i", "n" }, desc = "Insert line" },
						["%"] = { "print_path", desc = "Print selected path" },
						["<c-w>H"] = false,
						["<c-w>J"] = false,
						["<c-w>K"] = false,
						["<c-w>L"] = false,
						["/"] = false,
						["<C-Up>"] = false,
						["<C-Down>"] = false,
						["<S-CR>"] = false,
						["<c-j>"] = false,
						["<c-k>"] = false,
						["<c-c>"] = false,
						["<c-w>"] = false,
						["<c-r>#"] = false,
						["<c-r>%"] = false,
						["<c-r><c-p>"] = false,
					},
				},
				list = {
					keys = {
						["?"] = { "toggle_help_list", desc = "Help" },
						["<2-LeftMouse>"] = { "confirm", desc = "Confirm" },
						["<CR>"] = { "confirm", mode = { "i", "n" }, desc = "Confirm" },
						["<Esc>"] = { "cancel", desc = "Cancel" },
						["q"] = { "cancel", desc = "Cancel" },
						["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" }, desc = "Select and up" },
						["<Tab>"] = { "select_and_next", mode = { "i", "n" }, desc = "Select and down" },
						["<A-d>"] = { "inspect", mode = { "i", "n" }, desc = "Inspect" },
						["<A-f>"] = { "toggle_follow", mode = { "i", "n" }, desc = "Toggle follow symlinks" },
						["<A-h>"] = { "toggle_hidden", mode = { "i", "n" }, desc = "Toggle hidden" },
						["<A-i>"] = { "toggle_ignored", mode = { "i", "n" }, desc = "Toggle ignored" },
						["<A-m>"] = { "toggle_maximize", mode = { "i", "n" }, desc = "Toggle maximize" },
						["<A-P>"] = { "toggle_preview", mode = { "i", "n" }, desc = "Toggle preview" },
						["<A-p>"] = { "toggle_preview_position", mode = { "i", "n" }, desc = "Toggle preview location" },
						["<A-w>"] = { "cycle_win", mode = { "i", "n" }, desc = "Cycle window focus" },
						["<C-a>"] = { "select_all", mode = { "i", "n" }, desc = "Select all" },
						["<C-b>"] = { "preview_scroll_up", mode = { "i", "n" }, desc = "Scroll preview up" },
						["<C-f>"] = { "preview_scroll_down", mode = { "i", "n" }, desc = "Scroll preview down" },
						["<C-u>"] = { "list_scroll_up", mode = { "i", "n" }, desc = "Scroll list up" },
						["<C-d>"] = { "list_scroll_down", mode = { "i", "n" }, desc = "Scroll list down" },
						["<C-n>"] = { "list_down", mode = { "i", "n" }, desc = "List down" },
						["<C-p>"] = { "list_up", mode = { "i", "n" }, desc = "List up" },
						["j"] = { "list_down", desc = "List down" },
						["k"] = { "list_up", desc = "List up" },
						["G"] = { "list_bottom", desc = "List bottom" },
						["gg"] = { "list_top", desc = "List top" },
						["<Down>"] = { "list_down", mode = { "i", "n" }, desc = "List down" },
						["<Up>"] = { "list_up", mode = { "i", "n" }, desc = "List up" },
						["<C-q>"] = { "qflist", mode = { "i", "n" }, desc = "Add list to quickfix" },
						["<C-t>"] = { "tab", mode = { "i", "n" }, desc = "Open in tab" },
						["<C-s>"] = { "edit_split", mode = { "i", "n" }, desc = "Open in split" },
						["<C-v>"] = { "edit_vsplit", mode = { "i", "n" }, desc = "Open in vsplit" },
						["i"] = { "focus_input", desc = "Focus input" },
						["%"] = { "print_path", desc = "Print selected path" },
						["<c-w>H"] = false,
						["<c-w>J"] = false,
						["<c-w>K"] = false,
						["<c-w>L"] = false,
						["/"] = false,
						["<S-CR>"] = false,
						["<c-j>"] = false,
						["<c-k>"] = false,
						["zb"] = false,
						["zt"] = false,
						["zz"] = false,
						["<C-g>"] = false,
					},
				},
				preview = {
					keys = {
						["?"] = { "toggle_help_preview", desc = "Help" },
						["<Esc>"] = { "cancel", desc = "Cancel" },
						["q"] = { "cancel", desc = "Cancel" },
						["i"] = { "focus_input", desc = "Focus input" },
						["<A-w>"] = { "cycle_win", mode = { "i", "n" }, desc = "Cycle window focus" },
					},
				},
			},
		},
	},
}
