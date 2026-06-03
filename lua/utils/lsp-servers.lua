-- INFO: Get all configurations provided by lspconfig at:
--  https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- INFO: Get all available filetypes at:
--  https://github.com/neovim/neovim/blob/master/runtime/lua/vim/filetype.lua
-- INFO: See `:help lsp-config` for information about keys and how to configure.
local M = {}

M.setup = function()
	vim.filetype.add({
		extension = {
			-- Changing these extensions to match the OpenGL shader filetype.
			fs = "glsl",
			vs = "glsl",
		},
	})

	-- Language servers to enable and automatically install using Mason.
	---@type table<string, vim.lsp.Config>
	local servers_ensure_installed = {
		lua_ls = { -- lua
			-- Recommended configuration for working in Neovim.
			on_init = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						-- Tell the language server which version of Lua you're using (most
						-- likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
						-- Tell the language server how to find Lua modules same way as Neovim
						-- (see `:h lua-module-load`)
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
						},
					},
					-- Make the server aware of Neovim runtime files
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							-- For LSP Settings Type Annotations: https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
							vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
							-- Depending on the usage, you might want to add additional paths
							-- here.
							-- '${3rd}/luv/library',
							-- '${3rd}/busted/library',
						},
					},
				})
			end,
			settings = {
				Lua = {
					format = { enable = false },
				},
			},
		},
		bashls = { -- bash
			filetypes = { "sh", "bash", "zsh" },
		},
		tombi = { -- toml
			settings = {
				tombi = {
					validate = true,
					format = {
						enable = true,
					},
				},
			},
		},
		yamlls = { -- yaml
			settings = {
				yaml = {
					schemas = {
						["https://json.schemastore.org/composer.json"] = "composer.json",
						["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
						["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
					},
					validate = true,
					format = {
						enable = false, -- Using 'prettierd' instead.
					},
				},
			},
		},
		jsonls = { -- json
			init_oprions = {
				provideFormatter = false, -- Using 'prettierd' instead.
			},
		},
	}
	-- Language servers to enable but not automatically install.
	---@type table<string, vim.lsp.Config>
	local servers = vim.tbl_extend("error", servers_ensure_installed, {
		clangd = {}, -- c/c++
		cmake = {}, -- CMakeLists.txt
		dockerls = {}, -- dockerfile
		nil_ls = {}, -- nix
		pyright = {}, -- pyright
		qmlls = {}, -- qml
		glsl_analyzer = {}, -- OpenGL shader language
		ts_ls = { -- typescript
			settings = {
				typescript = {
					indentStyle = "space",
					indentSize = 4,
				},
			},
		},
	})

	local ensure_installed = vim.tbl_keys(servers_ensure_installed or {})
	-- Other tools to be installed by Mason.
	vim.list_extend(ensure_installed, {
		-- Formatters
		-- INFO: See expected formatters and the files they affect at: ../plugins/dev/conform.lua
		"stylua",
		"beautysh",
		"prettierd",

		-- Linters
		-- INFO: See expected linters and the files they affect at: ../plugins/dev/lint.lua
		"luacheck",
	})
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	-- cmp.nvim recommends setting capabilities on all LSPs.
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	for name, server in pairs(servers) do
		vim.lsp.config(name, vim.tbl_extend("force", server, { capabilities = capabilities }))
		vim.lsp.enable(name)
	end
end

return M
