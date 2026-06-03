-- WARN: Set things here so they only apply when the LSP attaches and don't clutter otherwise.

local M = {}

M.on_attach = function(event)
	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if not client then
		return
	end

	-- Used by lualine to know when to display symbols
	vim.b.has_lsp = true

	local bufnr = event.buf
	local keymap = function(mode, lhs, rhs, opts)
		vim.keymap.set(
			mode,
			lhs,
			rhs,
			vim.tbl_extend("keep", opts, {
				noremap = true, -- prevent recursive mapping
				silent = true, -- don't print the command to the cli
				buffer = bufnr, -- restrict the keymap to the local buffer number
			})
		)
	end

	-- Enable inlay hints on buffers that support it
	-- if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
	-- 	vim.lsp.inlay_hint.enable()
	-- end

	-- Highlight references of the word under your cursor when your cursor rests there for a little
	--  while.
	-- See `:help CursorHold` for information about when this is executed
	-- if client and client:supports_method("textDocument/documentHighlight", event.buf) then
	-- 	local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
	-- 	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	-- 		buffer = event.buf,
	-- 		group = highlight_augroup,
	-- 		callback = vim.lsp.buf.document_highlight,
	-- 	})
	-- 	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	-- 		buffer = event.buf,
	-- 		group = highlight_augroup,
	-- 		callback = vim.lsp.buf.clear_references,
	-- 	})
	-- 	vim.api.nvim_create_autocmd("LspDetach", {
	-- 		group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
	-- 		callback = function(event2)
	-- 			vim.lsp.buf.clear_references()
	-- 			vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
	-- 		end,
	-- 	})
	-- end
end

return M
