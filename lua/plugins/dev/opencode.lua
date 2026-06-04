return {
	"nickjvandyke/opencode.nvim",
	version = "*", -- Latest stable release
	config = function()
		vim.g.opencode_opts = {
			lsp = {
				enabled = true,
				handlers = {
					hover = {
						enabled = false,
					},
				},
			},
			server = {
				start = function()
					vim.notify("Disabled opencode.nvim's server functinality.", "WARN", { hide_from_history = true })
				end,
				stop = function()
					vim.notify("Disabled opencode.nvim's server functinality.", "WARN", { hide_from_history = true })
				end,
				toggle = function()
					vim.notify("Disabled opencode.nvim's server functinality.", "WARN", { hide_from_history = true })
				end,
			},
		}

		vim.api.nvim_create_autocmd("User", {
			pattern = "OpencodeEvent:*", -- Optionally filter event types
			callback = function(args)
				local event = args.data.event
				local url = args.data.url

				-- See the available event types and their properties
				-- vim.notify(vim.inspect(event), "DEBUG")

				if event.type == "session.idle" then
					vim.notify("OpenCode finished responding.", "INFO", { hide_from_history = true })
				end
				-- if event.type == "server.connected" then
				-- 	vim.notify(
				-- 		"End the prompt with a space to append instead of submit.",
				-- 		"INFO",
				-- 		{ hide_from_history = true }
				-- 	)
				-- end
				if event.type == "permission.asked" and event.properties.permission == "edit" then
					vim.defer_fn(function()
						vim.notify("Press '<leader>?l' to see local keymaps.", "INFO", { hide_from_history = true })
					end, 5000)
				end
				-- if event.type == "server.heartbeat" then
				-- 	vim.notify("`opencode` is active")
				-- end
			end,
		})
	end,
}
