return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release
	config = function()
		if vim.env.WINDOWS_USER then
			---@type obsidian.config
			require("obsidian").setup({
				legacy_commands = false,
				frontmatter = { enabled = false },
        footer = { enabled = false }, -- this is shown in lualine instead
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
