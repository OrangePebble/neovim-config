return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local Path = require("plenary.path")
		local prev_sel_item = nil

		-- Adds the ability to specify a line in harpoon with something like "path:line"
		harpoon:setup({
			-- You can find the regular default values at https://github.com/ThePrimeagen/harpoon/blob/87b1a3506211538f460786c23f98ec63ad9af4e5/lua/harpoon/config.lua
			default = {
				display = function(list_item)
					if list_item.context and list_item.context.fixed then
						return string.format("%s:%d", list_item.value, list_item.context.row)
					end
					return list_item.value
				end,
				select = function(list_item, _, options)
					if list_item == nil then
						return
					end
					options = options or {}
					local prev_fixed = prev_sel_item and prev_sel_item.context and prev_sel_item.context.fixed

					-- If changing between the same file and last selection was not fixed, update the row and col.
					-- This is here because changing between the same file doesn't trigger BufLeave.
					if prev_sel_item ~= nil and prev_sel_item.value == list_item.value and not prev_fixed then
						local cursor = vim.api.nvim_win_get_cursor(0)
						prev_sel_item.context = { row = cursor[1], col = cursor[2], fixed = false }
					end

					local bufnr = vim.fn.bufnr("^" .. list_item.value .. "$")
					-- Create the buffer if it doesn't exist
					if bufnr == -1 then
						bufnr = vim.fn.bufadd(list_item.value)
					end
					-- Load the buffer if it is unloaded
					if not vim.api.nvim_buf_is_loaded(bufnr) then
						vim.fn.bufload(bufnr)
						vim.api.nvim_set_option_value("buflisted", true, {
							buf = bufnr,
						})
					end

					if options.vsplit then
						vim.cmd("vsplit")
					elseif options.split then
						vim.cmd("split")
					elseif options.tabedit then
						vim.cmd("tabedit")
					end

					vim.api.nvim_set_current_buf(bufnr)

					-- I'm not changing "list_item.context.row/col" because I don't want to change fixed items and that is handled above and in BufLeave.

					-- When the row is bigger than the number of lines, we open the last line.
					local lines = vim.api.nvim_buf_line_count(bufnr)
					local row = math.min(list_item.context.row, lines)
					-- When the col is bigger than the line length, we open at the end of the line.
					local row_text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
					local col = math.min(list_item.context.col, #row_text[1])
					vim.api.nvim_win_set_cursor(0, { row, col })

					-- This works with BufLeave because BufLeave is triggered by the "vim.api.nvim_set_current_buf" above.
					prev_sel_item = list_item
				end,
				equals = function(list_item_a, list_item_b)
					if list_item_a == nil and list_item_b == nil then
						return true
					elseif list_item_a == nil or list_item_b == nil then
						return false
					elseif list_item_a.value ~= list_item_b.value then
						return false
					end

					local a_fixed = list_item_a.context and list_item_a.context.fixed
					local b_fixed = list_item_b.context and list_item_b.context.fixed
					if a_fixed ~= b_fixed then
						return false
					end
					-- If both are fixed, check if the rows are the same.
					if a_fixed then
						return list_item_a.context.row == list_item_b.context.row
					end
					return true
				end,
				create_list_item = function(_, name)
					name = name and vim.trim(name)

					local path
					local row = 1
					local col = 0
					local fixed = false

					-- If we specified a file and don't want to use the current buffer.
					if name then
						path, row = name:match("^(.-):(%d+)$")
						-- If it matches the regex and has a fixed row
						if path then
							row = math.max(1, tonumber(row))
							fixed = true
						else
							path = name
						end
					else
						path = Path:new(vim.api.nvim_buf_get_name(0)):make_relative(vim.loop.cwd())
					end

					if not fixed then
						local bufnr = vim.fn.bufnr(path, false)
						if bufnr ~= -1 then
							local cursor = vim.api.nvim_win_get_cursor(0)
							row = cursor[1]
							col = cursor[2]
						end
					end

					return {
						value = path,
						context = { row = row, col = col, fixed = fixed },
					}
				end,
				BufLeave = function(arg, list)
					local path = Path:new(vim.api.nvim_buf_get_name(arg.buf)):make_relative(list.config.get_root_dir())
					local cursor = vim.api.nvim_win_get_cursor(0)
					-- If "prev_sel_item" exists (and has the same path as the buffer just to make sure), don't search through the item list.
					if prev_sel_item ~= nil and prev_sel_item.value == path then
						-- If "prev_sel_item" is not fixed, update the row/col.
						if not (prev_sel_item.context and prev_sel_item.context.fixed) then
							prev_sel_item.context.row = cursor[1]
							prev_sel_item.context.col = cursor[2]
						end
					else
						-- Not using "list:get_by_value" because the list can now have multiple items with the same value.
						-- If we didn't get to the current buffer via harpoon, but it is in the list and not fixed, update the row/col.
						for _, item in pairs(list.items) do
							if item.value == path and not (item.context and item.context.fixed) then
								item.context.row = cursor[1]
								item.context.col = cursor[2]
							end
						end
					end
					-- The previous item doesn't matter in the new buffer
					prev_sel_item = nil
				end,
				autocmds = { "BufLeave" },
			},
		})

		--- Make it so the first 8 lines have the keymap key as the line number
		vim.g.harpoon_statuscolumn_keys = { "j", "k", "l", ";", "m", ",", ".", "/" }
		harpoon:extend({
			UI_CREATE = function(ctx)
				-- Disable regular line numbers
				vim.api.nvim_set_option_value("number", false, { win = ctx.win_id })
				-- Apply special line number format
				vim.api.nvim_set_option_value(
					"statuscolumn",
					"%{get(g:harpoon_statuscolumn_keys, v:lnum - 1, &rnu && v:relnum ? v:relnum : v:lnum)} ",
					{
						win = ctx.win_id,
					}
				)
			end,
		})
	end,
}
