-- Quickstart configurations for the built-in Neovim LSP client.
-- INFO: Get all configurations provided by lspconfig at:
--  https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- INFO: Get all available filetypes at:
--  https://github.com/neovim/neovim/blob/master/runtime/lua/vim/filetype.lua
-- INFO: See `:help lsp-config` for information about keys and how to configure.

return {
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
		{
			-- Automatically configure lua_ls to work with my Neovim configuration and plugins.
			-- Needs a `require()` or a `---@module` to load libraries in a file, or for the plugin
			--  to be included in `opts.libary` below.
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details:
					--  https://github.com/folke/lazydev.nvim#%EF%B8%8F-configuration

					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },

					-- The plugin loations can be found at ~/.local/share/nvim/lazy
					-- So I don't have to import the "lazy" module everytime I want to use `LazySpec` type.
					"lazy.nvim",
					"snacks.nvim",
				},
			},
		},
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
				xodr = "xml",
			},
		})
		-- Language servers to enable and automatically install using Mason.
		---@type table<string, vim.lsp.Config>
		local servers_ensure_installed = {
			lua_ls = {}, -- lua
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
			lemminx = { -- xml
				-- INFO: Added 'xodr' as an xml filetype above.
				filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "xosc", "xodr" },
				settings = {
					xml = {
						-- Found after searching `lemminx path:**/*.lua spaceBeforeEmptyCloseTag` on GitHub.
						format = {
							enabled = true,
							spaceBeforeEmptycloseTag = true,
							maxLineWidth = 999,
							joinContentLines = true,
							splitAttributes = "preserve",
							splitAttributesIndentSize = 1,
							closingBracketNewLine = false,
							formatComments = false,
							joinCommentLine = false,
							preservedNewlines = 1,
							preserveAttributeLineBreaks = true,
							preserveEmptyContent = true,
							emptyElements = "ignore",
						},
						-- Because I do this direct association I don't need to use catalogs, but here is some documentation:
						-- https://github.com/eclipse-lemminx/lemminx/blob/85de2145eb5acb40e5f3b2d4b0cbf8ce107e515b/docs/Configuration.md
						-- https://github.com/redhat-developer/vscode-xml/blob/ac784ed123b2ae0ec42b23f190c1d4402094d3dd/docs/Features/XMLCatalogFeatures.md
						-- https://github.com/redhat-developer/vscode-xml/blob/ac784ed123b2ae0ec42b23f190c1d4402094d3dd/docs/Validation.md#xml-catalog-with-xsd
						fileAssociations = {
							{
								pattern = "**/*.xosc",
								systemId = vim.fn.stdpath("config")
									.. "/lua/plugins/dev/xml/OpenSCENARIO_StrictValidation_1_3.xsd",
							},
							{
								pattern = "**/*.xodr",
								systemId = vim.fn.stdpath("config") .. "/lua/plugins/dev/xml/OpenDRIVE_1.4H.xsd",
								-- systemId = vim.fn.stdpath("config") .. "/lua/plugins/dev/xml/OpenDRIVE_1.3.xsd",
							},
						},
					},
				},
			},
		}
		require("utils.mason-installer").ensure_installed(vim.tbl_keys(servers_ensure_installed or {}))

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

		-- https://github.com/neovim/nvim-lspconfig/wiki/Running-language-servers-in-containers
		-- If this isn't enough check out existing lsp container and devcontainer plugins like:
		--  https://github.com/lspcontainers/lspcontainers.nvim
		-- INFO: I've tried doing this like lua_ls above but it seemed to use the regular cmd, maybe
		--  only when the new one failed but I couldn't tell.
		-- WARN: For clangd to find the built files, the workspace inside the container has to be
		--  the same as outside (the project directory).
		local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		-- Using regex match to check multiple names and patterns
		-- 'baibe' for my work's training project
		if string.match(cwd_name, "(.*baibe.*)") then
			if vim.system({ "docker", "exec", "workspace", "true" }):wait().code == 0 then
				servers.clangd = vim.tbl_deep_extend("force", servers.clangd, {
					cmd = {
						"docker",
						"exec",
						"-i",
						"workspace",
						"clangd-19",
						"--background-index",
					},
					before_init = function(params)
						-- The processId inside a container is different so we ignore it.
						params.processId = vim.NIL
					end,
				})
			else
				-- Dlay so neovim has time to load notification plugin.
				vim.defer_fn(function()
					vim.notify("clangd: docker exec failed (container not running?)", vim.log.levels.WARN)
				end, 1000)
			end
		end

		for name, server in pairs(servers) do
			vim.lsp.config(name, server)
			vim.lsp.enable(name)
		end
	end,
}
