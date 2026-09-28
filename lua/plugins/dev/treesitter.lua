return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("nvim-treesitter").install({
			-- Install parsers not built-in into neovim.
			-- To get installed parsers run :lua vim.print(require("nvim-treesitter").get_installed())
			-- For possible parsers check https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers
			"bash",
			"cpp",
			"css",
			"devicetree", -- For my zmk config
			"diff",
			"dockerfile",
			"go",
			"html",
			"javascript",
			"jsdoc",
			"json",
			"luadoc",
			"nix",
			"python",
			"regex",
			"rust",
			"toml",
			"typescript",
			"yaml",
		})
		vim.treesitter.language.register("cpp", { "tpp" })

		-- So treesitter has had a massive revamp and removed a bunch of features so that they
		--  become just the foundation for the features and is therefore easier to maintain.
		-- Use https://github.com/MeanderingProgrammer/treesitter-modules.nvim#implementing-yourself
		--  and the treesitter repo learn more about how to implement these features.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter.setup", {}),
			callback = function(args)
				local buf = args.buf
				local filetype = args.match

				-- Check if a parser exists for the current buffer.
				local language = vim.treesitter.language.get_lang(filetype) or filetype
				if not vim.treesitter.language.add(language) then
					return
				end

				-- Enable the parser.
				vim.treesitter.start(buf, language)

				-- Uses treesitter to know how much to indent each line.
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
