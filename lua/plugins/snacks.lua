return {
	"folke/snacks.nvim",
	lazy = false,
	---@module "snacks"
	---@type snacks.Config
	opts = {
		picker = { enabled = true },
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
	},
	init = function()
		vim.g.snacks_dim = false
	end,
}
