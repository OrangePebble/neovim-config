return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("nvim-treesitter").install({
			"lua",
			"luadoc",
			"vim",
			"vimdoc",
			"nix",
			"bash",
			"c",
			"cpp",
			"css",
			"dockerfile",
			"go",
			"html",
			"javascript",
			"markdown",
			"markdown_inline",
			"python",
			"rust",
			"svelte",
			"typescript",
			"vue",
			"yaml",
			"json",
			"toml",
			"diff",
			"regex",
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

				-- you need some mechanism to avoid running on buffers that do not
				-- correspond to a language (like oil.nvim buffers), this implementation
				-- checks if a parser exists for the current language
				local language = vim.treesitter.language.get_lang(filetype) or filetype
				if not vim.treesitter.language.add(language) then
					return
				end

				-- replicate `highlight = { enable = true }`
				vim.treesitter.start(buf, language)

				-- replicate `indent = { enable = true }`
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

				-- `incremental_selection = { enable = true }` cannot be easily replicated
			end,
		})
	end,
}
