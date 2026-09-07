return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local Path = require("plenary.path")
		harpoon:setup({
			default = {
				display = function(item)
					if item.context and item.context.fixed then
						return string.format("%s:%d", item.value, item.context.row)
					end
					return item.value
				end,
				equals = function(a, b)
					if not a or not b or a.value ~= b.value then
						return false
					end

					local a_fixed = a.context and a.context.fixed
					local b_fixed = b.context and b.context.fixed
					return a_fixed == b_fixed and (not a_fixed or a.context.row == b.context.row)
				end,
				create_list_item = function(_, value)
					value = value and vim.trim(value)
					local path, row
					if value then
						path, row = value:match("^(.-):(%d+)$")
					end
					if path then
						return { value = path, context = { row = math.max(1, tonumber(row)), col = 0, fixed = true } }
					end

					if value then
						return { value = value, context = { row = 1, col = 0, fixed = false } }
					end

					local cursor = vim.api.nvim_win_get_cursor(0)
					return {
						value = Path:new(vim.api.nvim_buf_get_name(0)):make_relative(vim.loop.cwd()),
						context = { row = cursor[1], col = cursor[2], fixed = false },
					}
				end,
				select = function(item, _, options)
					if not item then
						return
					end

					options = options or {}
					if options.vsplit then
						vim.cmd("vsplit")
					elseif options.split then
						vim.cmd("split")
					elseif options.tabedit then
						vim.cmd("tabedit")
					end

					vim.cmd.edit(vim.fn.fnameescape(item.value))
					local row = math.min(item.context and item.context.row or 1, vim.api.nvim_buf_line_count(0))
					local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
					vim.api.nvim_win_set_cursor(0, { row, math.min(item.context and item.context.col or 0, #line) })
				end,
				BufLeave = function(event, list)
					local path = Path:new(vim.api.nvim_buf_get_name(event.buf))
						:make_relative(list.config.get_root_dir())
					local cursor = vim.api.nvim_win_get_cursor(0)
					for _, item in pairs(list.items) do
						if item.value == path and not (item.context and item.context.fixed) then
							item.context = { row = cursor[1], col = cursor[2], fixed = false }
						end
					end
				end,
				autocmds = { "BufLeave" },
			},
		})

		--- Make it so the first 8 lines have the keymap key as the line number
		vim.g.harpoon_statuscolumn_keys = { "j", "k", "l", ";", "m", ",", ".", "/" }
		harpoon:extend({
			UI_CREATE = function(ctx)
				vim.api.nvim_set_option_value("number", false, { win = ctx.win_id })
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
