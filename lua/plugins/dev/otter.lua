-- Makes LSP work for languages embedded in other languages, like CSS in an HTML file
return {
	"jmbuhr/otter.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local otter = require("otter")
		local otter_keeper = require("otter.keeper")
		otter.setup()

		-- Route LSP requests to Otter only within an injected language region.
		-- Required because I apply Otter in all buffers below, and without this, many LSP requests are called twice.
		local original_get_clients = vim.lsp.get_clients
		---@diagnostic disable-next-line: duplicate-set-field
		vim.lsp.get_clients = function(opts)
			local clients = original_get_clients(opts)
			local bufnr = opts and opts.bufnr

			-- Otter does not inject workspace-wide operations, so just return all clients.
			if not bufnr then
				return clients
			end

			if bufnr == 0 then
				bufnr = vim.api.nvim_get_current_buf()
			end
			local otter_client_name = "otter-ls[" .. bufnr .. "]"

			-- If Otter is not applied in the current buffer, return all clients.
			if
				not vim.tbl_contains(
					vim.tbl_map(function(client)
						return client.name
					end, clients),
					otter_client_name
				)
			then
				return clients
			end

			-- Filter out Otter clients if the cursor is not at an injected language, and non-Otter clients if it is.
			return vim.tbl_filter(function(client)
				return (client.name == otter_client_name) == (otter_keeper.get_current_language_context(bufnr) ~= nil)
			end, clients)
		end

		-- Automatically activate Otter for normal file buffers with an available Tree-sitter parser.
		-- Otter only activates for files with injected languages.
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

					-- Only ask Otter to inspect buffers with an available Tree-sitter parser; get_parser creates it if needed.
					local has_parser = pcall(vim.treesitter.get_parser, args.buf)
					-- Do not create a second set of Otter buffers for this source buffer.
					if has_parser and not otter_keeper.has_raft(args.buf) then
						vim.api.nvim_buf_call(args.buf, otter.activate)
					end
				end)
			end,
		})
	end,
}
