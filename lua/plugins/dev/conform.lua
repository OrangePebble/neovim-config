-- Autoformat plugin.
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {

		-- Define your formatters
		-- INFO: Get all available formatters at:
		--  https://github.com/stevearc/conform.nvim/tree/master/lua/conform/formatters
		-- INFO: Get all available filetypes at:
		--  https://github.com/neovim/neovim/blob/master/runtime/lua/vim/filetype.lua
		-- INFO: Make these auto-install using Mason on ../../utils/lsp-servers.lua
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			nix = { "nixfmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			markdown = { "prettierd" },
			sh = { "beautysh" },
			bash = { "beautysh" },
			zsh = { "beautysh" },
			dockerfile = { "prettierd" },
			kdl = { "kdlfmt" }, -- niri config files
			cmake = { "gersemi" },

			html = { "prettierd" },
			css = { "prettierd" },
			javascript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			svelte = { "prettierd" },
			vue = { "prettierd" },

			json = { "prettierd" },
			jsonc = { "prettierd" },
			yaml = { "prettierd" },

			-- Add 'stop_after_first' to stop after using the first valid formatter.
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
		-- Customize formatters
		formatters = {
			-- shfmt = { append_args = { "-i", "2" }, },
		},

		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- Set up format-on-save
		format_on_save = function(bufnr)
			-- Disable autoformat on certain filetypes
			local ignore_filetypes = { "sql" }
			if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
				return
			end
			-- Disable with a global or buffer-local variable
			if not vim.g.autoformat then
				return
			end
			-- Disable autoformat for files in a certain path
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname:match("/node_modules/") then
				return
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
