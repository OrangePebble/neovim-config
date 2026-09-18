return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release
	config = function()
		if vim.env.WINDOWS_USER then
			---@type obsidian.config
			require("obsidian").setup({
				legacy_commands = false,
				ui = { enable = false },
				frontmatter = { enabled = false },
				footer = {
					enabled = true,
					separator = "________________________________________________________________________________",
				},
				workspaces = {
					{
						name = "vault",
						path = "/mnt/c/Users/" .. vim.env.WINDOWS_USER .. "/Documents/sync/obsidian",
					},
				},
			})
		end
	end,
}
