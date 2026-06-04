-- Quickstart configurations for the built-in Neovim LSP client.
-- INFO: Get all configurations provided by lspconfig at:
--  https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- INFO: Get all available filetypes at:
--  https://github.com/neovim/neovim/blob/master/runtime/lua/vim/filetype.lua
-- INFO: See `:help lsp-config` for information about keys and how to configure.

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} }, -- LSP/DAP/Linter installer & manager
			-- Adds the :LspInstall command and the ability to automatically enable and install LSPs.
			-- Also makes it so that 'mason-tool-installer' can use lspconfig package names.
			{ "mason-org/mason-lspconfig.nvim", opts = {
				automatic_enable = false,
			} },
			-- Adds the ability to automatically install LSPs, linters, etc.
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for LSP-based completion
		},
		config = function()
			--== Configure diagnostics format
			require("utils.diagnostics").setup()

			--== Set things only when an LSP is attached
			local lsp_on_attach_group = vim.api.nvim_create_augroup("LspMappings", {})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = lsp_on_attach_group,
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if not client then
						return
					end
					-- Used by lualine to know when to display symbols
					vim.b.has_lsp = true
				end,
			})

			--== LSP configurations

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
			require("utils.mason-installer").ensure_installed(vim.tbl_keys(servers_ensure_installed or {}))

			-- Language servers to enable but not automatically install.
			---@type table<string, vim.lsp.Config>
			local servers = vim.tbl_extend("error", servers_ensure_installed, {
				clangd = {
					-- https://github.com/neovim/nvim-lspconfig/wiki/Running-language-servers-in-containers
					-- If this isn't enough check out existing lsp container and devcontainer plugins like:
					--  https://github.com/lspcontainers/lspcontainers.nvim
					before_init = function(params)
						params.processId = vim.NIL
					end,
					on_init = function(client)
						if client.workspace_folders then
							local workspace_path = client.workspace_folders[1].name
							local workspace_name = vim.fn.fnamemodify(workspace_path, ":t")
							-- Using regex match to check multiple names and patterns
							-- 'baibe' for my work's training project
							if string.match(workspace_name, "(.*baibe.*)") then
								client.config = vim.tbl_deep_extend("force", client.config, {
									cmd = {
										"docker",
										"exec",
										"-i",
										"baibe-app",
										"clangd-19",
										"--background-index",
										"2>/dev/null",
									},
								})
							end
						end
					end,
				}, -- c/c++
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

			-- cmp.nvim recommends setting capabilities on all LSPs.
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			for name, server in pairs(servers) do
				vim.lsp.config(name, vim.tbl_extend("force", server, { capabilities = capabilities }))
				vim.lsp.enable(name)
			end
		end,
	},
}
