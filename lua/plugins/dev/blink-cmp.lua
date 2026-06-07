-- Completion plugin.
return {
	"saghen/blink.cmp",
	dependencies = {
		-- Large collection of pre-made snippets for various languages
		"rafamadriz/friendly-snippets",
	},
	-- Versions 2.* are currently unstable.
	version = "1.*",
	event = { "InsertEnter", "CmdlineEnter" },

	init = function() --
	end,

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			-- Jump between snippet placeholders.
			["<C-l>"] = { "snippet_forward", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },

			-- Easier to remember scroll keymaps than b/f
			["<C-k>"] = { "scroll_documentation_up", "fallback" },
			["<C-j>"] = { "scroll_documentation_down", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			-- Automatically show the documentation of the selected menu.
			documentation = { auto_show = true },
		},

		sources = {
			-- Find community sources at:
			--  https://cmp.saghen.dev/configuration/sources.html#community-sources
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				-- Slightly better completion for require statements and module annotations
				lua = { inherit_defaults = true, "lazydev" },
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
			},
		},

		-- Show the possible function arguments while typing inside the ().
		signature = { enabled = true },

		-- TODO: make tab autocomplete
		cmdline = {
			completion = {
				menu = {
					-- Only automatically show for some cmds.
					auto_show = function(ctx)
						return vim.fn.getcmdtype() == ":"
						-- enable for inputs as well, with:
						-- or vim.fn.getcmdtype() == '@'
					end,
				},
			},
		},

		-- Use the Rust fuzzy matcher if available, fall back to the Lua implementation.
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
