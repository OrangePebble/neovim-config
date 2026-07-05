-- Linting plugin.
return {
	"mfussenegger/nvim-lint",
	dependencies = {
		-- Adds the ability to automatically install LSPs, linters, etc.
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		-- INFO: Get available linters at:
		--  https://github.com/mfussenegger/nvim-lint/tree/master#available-linters
		--  https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
		-- INFO: Get all available filetypes at:
		--  https://github.com/neovim/neovim/blob/master/runtime/lua/vim/filetype.lua
		lint.linters_by_ft = {
			-- lua = { "luacheck" },
			nix = { "statix" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			python = { "flake8" },
			-- c = { "clangtidy" },
			-- cpp = { "clangtidy" },
			dockerfile = { "hadolint" },
			cmake = { "cmakelint" },

			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			vue = { "eslint_d" },

			json = { "eslint_d" },
			jsonc = { "eslint_d" },
		}

		require("utils.mason-installer").ensure_installed({
			"luacheck",
		})

		-- Create autocommand which carries out the actual linting
		-- on the specified events.
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
			group = lint_augroup,
			callback = function()
				-- Only run the linter in buffers that you can modify in order to
				-- avoid superfluous noise, notably within the handy LSP pop-ups that
				-- describe the hovered symbol using Markdown.
				if vim.bo.modifiable then
					lint.try_lint()
				end
			end,
		})
	end,
}
