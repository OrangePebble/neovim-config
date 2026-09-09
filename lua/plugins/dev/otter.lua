-- Makes LSP work for languages embedded in other languages, like CSS in an HTML file

-- CSS in HTML style attribute doesn't use classes and therefore doesn't work with an LSP
local function disable_otter_in_style_attribute_injected_css(otter_keeper)
	local function is_style_attribute(bufnr, pos)
		local node = vim.treesitter.get_node({
			bufnr = bufnr,
			pos = pos,
			ignore_injections = true,
		})
		while node do
			if node:type() == "attribute" then
				for child in node:iter_children() do
					if child:type() == "attribute_name" and vim.treesitter.get_node_text(child, bufnr) == "style" then
						return true
					end
				end
			end
			node = node:parent()
		end
		return false
	end

	-- Disables the extraction of code into hidden otter buffers which prevents LSP diagnostics
	local original_extract_code_chunks = otter_keeper.extract_code_chunks
	otter_keeper.extract_code_chunks = function(bufnr, ...)
		local chunks = original_extract_code_chunks(bufnr, ...)
		if vim.bo[bufnr].filetype ~= "html" or not chunks.css then
			return chunks
		end

		chunks.css = vim.tbl_filter(function(chunk)
			return not is_style_attribute(bufnr, chunk.range.from)
		end, chunks.css)
		if #chunks.css == 0 then
			chunks.css = nil
		end
		return chunks
	end

	-- Prevents requests like completion, hover, definition, etc.
	local original_get_current_language_context = otter_keeper.get_current_language_context
	otter_keeper.get_current_language_context = function(bufnr, position)
		bufnr = bufnr or vim.api.nvim_get_current_buf()
		if vim.bo[bufnr].filetype == "html" then
			local pos = position or vim.api.nvim_win_get_cursor(0)
			pos = { pos[1] - 1, pos[2] }
			if is_style_attribute(bufnr, pos) then
				return nil
			end
		end
		return original_get_current_language_context(bufnr, position)
	end
end

local function automatically_activate_otter(otter, otter_keeper)
	-- Route LSP requests to Otter only within an injected language region.
	-- Required because I apply Otter in all buffers below, and without this, many LSP requests are called twice.
	local original_get_clients = vim.lsp.get_clients
	local snacks_lsp = require("snacks.picker.source.lsp")
	local snacks_get_clients = snacks_lsp.get_clients
	local function filter_otter_clients(clients, bufnr)
		local otter_client_name = "otter-ls[" .. bufnr .. "]"
		-- If this request has no Otter client for the buffer, return all clients.
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

	---@diagnostic disable-next-line: duplicate-set-field
	vim.lsp.get_clients = function(opts)
		local clients = original_get_clients(opts)
		local bufnr = opts and opts.bufnr

		-- Otter does not inject workspace-wide operations, so just return all clients.
		-- If no method is specified (like Snacks and statuslines do), also return all clients.
		if not bufnr or not opts.method then
			return clients
		end

		if bufnr == 0 then
			bufnr = vim.api.nvim_get_current_buf()
		end
		return filter_otter_clients(clients, bufnr)
	end

	-- Snacks filters method support after calling vim.lsp.get_clients without a method, so we need to filter Otter after.
	---@diagnostic disable-next-line: duplicate-set-field
	snacks_lsp.get_clients = function(bufnr, method)
		return filter_otter_clients(snacks_get_clients(bufnr, method), bufnr)
	end

	-- Automatically activate Otter for normal file buffers with an available Tree-sitter parser.
	-- Otter only creates hidden buffers and attaches its LSP when injected languages are found.
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
end

return {
	"jmbuhr/otter.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local otter = require("otter")
		local otter_keeper = require("otter.keeper")
		otter.setup()

		disable_otter_in_style_attribute_injected_css(otter_keeper)
		automatically_activate_otter(otter, otter_keeper)
	end,
}
