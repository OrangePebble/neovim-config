-- Makes LSP work for languages embedded in other languages, like CSS in an HTML file
return {
	"jmbuhr/otter.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local otter = require("otter")
		otter.setup()

		-- Automatically activate Otter for normal, parser-backed file buffers.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("otter.activate", {}),
			pattern = "*",
			callback = function(args)
				if
					-- Skip special buffers such as terminals, help pages, and plugin panels.
					vim.bo[args.buf].buftype ~= ""
					-- Skip temporary buffers that do not appear in the normal buffer list.
					or not vim.bo[args.buf].buflisted
					-- Skip unnamed buffers, including a new file before its first write.
					or vim.api.nvim_buf_get_name(args.buf) == ""
				then
					return
				end

				vim.schedule(function()
					-- The buffer may have been closed while activation was deferred.
					if not vim.api.nvim_buf_is_valid(args.buf) or not vim.bo[args.buf].buflisted then
						return
					end

					-- Only ask Otter to inspect buffers with a Tree-sitter parser.
					local has_parser = pcall(vim.treesitter.get_parser, args.buf)
					-- Do not create a second set of Otter buffers for this source buffer.
					if has_parser and not require("otter.keeper").has_raft(args.buf) then
						vim.api.nvim_buf_call(args.buf, otter.activate)
					end
				end)
			end,
		})
	end,
}
