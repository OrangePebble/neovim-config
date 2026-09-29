-- Visually distinguishes code injected into other languages (e.g. bash inside a Lua string).
--
-- Injected code keeps its own syntax highlighting, but:
--   * its foreground colors are blended slightly toward a tint color, and
--   * it gets a lighter background panel, starting at the block's shared indentation and
--     ending at its longest line.
--
-- Everything is drawn with ephemeral extmarks from a decoration provider, so nothing is stored
-- in the buffer and the marks are rebuilt on every redraw.

local M = {}

-- Only injections matching an entry are tinted.
---@type table<string, string[]>
local included_injections = {
	lua = { "bash" },
	nix = { "bash" },
	javascript = { "html", "css" },
	html = { "css", "javascript" },
}

-- Edit this common injected-code highlight to experiment with its foreground and background.
-- Its foreground is also the target color for per-capture syntax blending below.
local injected_code_highlight = {
	fg = vim.g.colorscheme.green,
	bg = vim.g.colorscheme.background_1,
}
local tint_strength = 0.20

local namespace = vim.api.nvim_create_namespace("injected-code-tint")
local injected_code_group = "InjectedCode"
local tint_groups = {}
local pending_languages = {}

--- Whether position (row, col) comes strictly before (other_row, other_col).
---@param row integer
---@param col integer
---@param other_row integer
---@param other_col integer
---@return boolean
local function before(row, col, other_row, other_col)
	return row < other_row or (row == other_row and col < other_col)
end

--- Highlights a range with an ephemeral extmark, ignoring empty ranges.
---@param buf integer
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@param group string
---@param priority_offset integer Added to the Tree-sitter priority so this layers above/below other marks.
---@param hl_eol? boolean Continue the highlight to the end of the screen line. Needs a multiline range.
local function tint_range(buf, start_row, start_col, end_row, end_col, group, priority_offset, hl_eol)
	if not before(start_row, start_col, end_row, end_col) then
		return
	end

	vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
		end_row = end_row,
		end_col = end_col,
		hl_group = group,
		-- Higher-priority token marks combine their foreground with this group's background.
		hl_mode = "combine",
		priority = vim.hl.priorities.treesitter + priority_offset,
		hl_eol = hl_eol,
		ephemeral = true,
	})
end

--- Tints every included injection below `tree`, recursing so nested injections are handled too.
--- Only the part of each injected block inside the redrawn range is drawn.
---@param tree vim.treesitter.LanguageTree
---@param buf integer
---@param start_row integer Start of the range being redrawn.
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@param text_width integer Width of the window's text area, excluding number, sign and fold columns.
local function tint_children(tree, buf, start_row, start_col, end_row, end_col, text_width)
	local host = tree:lang()
	for language, child in pairs(tree:children()) do
		-- Only injections matching an entry in the include list are tinted.
		local included = false
		for _, candidate in ipairs(included_injections[host] or {}) do
			if candidate == language then
				included = true
				break
			end
		end

		if included then
			local ok, query = pcall(vim.treesitter.query.get, language, "highlights")
			if not ok or not query then
				query = nil
			end
			local groups = tint_groups[language]

			-- Lazily build this language's tint groups the first time it is encountered, since doing
			-- so needs highlight lookups that are best avoided directly inside a decoration callback.
			if not groups and not pending_languages[language] then
				pending_languages[language] = true
				vim.schedule(function()
					pending_languages[language] = nil
					tint_groups[language] = {}
					local hl_ok, highlights_query = pcall(vim.treesitter.query.get, language, "highlights")
					local target = hl_ok
						and highlights_query
						and vim.api.nvim_get_hl(0, { name = injected_code_group, link = false }).fg
					if target then
						for _, capture in ipairs(highlights_query.captures) do
							local highlight =
								vim.api.nvim_get_hl(0, { name = "@" .. capture .. "." .. language, link = false })
							if highlight.fg then
								local group_name = "InjectedCodeTint." .. language .. "." .. capture
								-- Blend the capture's foreground toward InjectedCode's fg, channel by channel.
								local first_red = math.floor(highlight.fg / 0x10000) % 0x100
								local first_green = math.floor(highlight.fg / 0x100) % 0x100
								local first_blue = highlight.fg % 0x100
								local second_red = math.floor(target / 0x10000) % 0x100
								local second_green = math.floor(target / 0x100) % 0x100
								local second_blue = target % 0x100
								local original_strength = 1 - tint_strength
								local blended_fg = math.floor(
									first_red * original_strength + second_red * tint_strength
								) * 0x10000 + math.floor(
									first_green * original_strength + second_green * tint_strength
								) * 0x100 + math.floor(
									first_blue * original_strength + second_blue * tint_strength
								)
								vim.api.nvim_set_hl(0, group_name, { fg = string.format("#%06x", blended_fg) })
								tint_groups[language][capture] = group_name
							end
						end
					end
					vim.cmd("redraw")
				end)
			end

			child:for_each_tree(function(injected_tree)
				local block_start_row, block_start_col, block_end_row, block_end_col = injected_tree:root():range()
				-- Skip blocks that do not overlap the range being redrawn.
				if block_end_row < start_row or block_start_row > end_row then
					return
				end

				-- Clip the block to the redrawn range for drawing, but measure the whole block so every
				-- redraw chunk agrees on the same indentation and width.
				local tint_start_row, tint_start_col = block_start_row, block_start_col
				local tint_end_row, tint_end_col = block_end_row, block_end_col
				if before(tint_start_row, tint_start_col, start_row, start_col) then
					tint_start_row, tint_start_col = start_row, start_col
				end
				if before(end_row, end_col, tint_end_row, tint_end_col) then
					tint_end_row, tint_end_col = end_row, end_col
				end

				-- Measure the injected block: its shared indentation and the width of its longest line.
				-- Widths are in display columns, so tabs and wide characters are handled correctly.
				local indentation_width
				local longest_width = 0
				local block_lines = vim.api.nvim_buf_get_lines(
					buf,
					block_start_row,
					block_end_row + (block_end_col > 0 and 1 or 0),
					false
				)

				-- First pass: the shared indentation is the smallest indentation of any non-blank line.
				for index, line in ipairs(block_lines) do
					local row = block_start_row + index - 1
					-- The first and last lines may be only partly inside the block (e.g. after a `[[` delimiter).
					local line_start_col = row == block_start_row and block_start_col or 0
					local line_end_col = row == block_end_row and block_end_col or #line
					local first_non_whitespace = line:find("%S", line_start_col + 1)
					if first_non_whitespace and first_non_whitespace <= line_end_col then
						local line_indentation_width = vim.fn.strdisplaywidth(line:sub(1, first_non_whitespace - 1))
						indentation_width =
							math.min(indentation_width or line_indentation_width, line_indentation_width)
					end
				end

				-- Second pass: the longest line, measured from the shared indentation. This includes any
				-- extra indentation a line has beyond the shared one.
				if indentation_width then
					for index, line in ipairs(block_lines) do
						local row = block_start_row + index - 1
						local line_end_col = row == block_end_row and block_end_col or #line
						local line_width = vim.fn.strdisplaywidth(line:sub(1, line_end_col))
						longest_width = math.max(longest_width, line_width - indentation_width)
					end
				end

				-- Draws the background panel for the part of the block inside the redrawn range. If the
				-- whole block is blank, there is no indentation to align the panel to, so nothing is drawn.
				--
				-- Per line, three layers are used:
				--   1. A multiline `hl_eol` extmark colors the text and the newline, running to the window edge.
				--   2. Virtual text pads the line out to the block's longest line with the panel color.
				--   3. Virtual text after that resets the rest of the line to Normal, cutting off the `hl_eol`
				--      overflow.
				-- Blank lines have no text to anchor to, so they use a single overlay from column 0 instead.
				--
				-- Note: `text_width` is treated as the available width for a single screen line. For injected
				-- lines wider than the window (whether or not `wrap` is set), the padding/reset past that width
				-- can be misaligned; this is not accounted for, since injected code is expected to fit on screen.
				if indentation_width then
					local line_count = vim.api.nvim_buf_line_count(buf)
					-- How many cells remain between the panel's right edge and the window's right edge.
					local normal_padding = math.max(text_width - indentation_width - longest_width, 0)
					-- A range ending at column 0 stops before `tint_end_row`, so that row is not part of the block.
					local last_row = tint_end_col == 0 and tint_end_row - 1 or tint_end_row
					-- Fetched once for the whole range rather than per row.
					local lines = vim.api.nvim_buf_get_lines(buf, tint_start_row, last_row + 1, false)

					for row = tint_start_row, last_row do
						local line = lines[row - tint_start_row + 1]
						local line_start_col = row == tint_start_row and tint_start_col or 0
						local line_end_col = row == tint_end_row and tint_end_col or #line
						local first_non_whitespace = line:find("%S", line_start_col + 1)
						local is_blank = not first_non_whitespace or first_non_whitespace > line_end_col
						-- The background starts at the shared indentation, so the leading prefix keeps the
						-- normal color.
						local background_start_col = line_end_col
						if first_non_whitespace and first_non_whitespace <= line_end_col then
							-- Walk forward byte by byte until the display width reaches the shared indentation,
							-- to find the byte column where the background starts.
							local byte_col = line_start_col
							while byte_col < first_non_whitespace - 1 do
								local next_col = byte_col + 1
								if vim.fn.strdisplaywidth(line:sub(1, next_col)) > indentation_width then
									-- A tab crossing the desired display column cannot be partially highlighted,
									-- so start after it instead. Anything else can simply start at the current
									-- column.
									byte_col = line:sub(next_col, next_col) == "\t" and first_non_whitespace - 1
										or byte_col
									break
								end
								byte_col = next_col
							end
							background_start_col = byte_col
						end

						-- If the block ends before the physical end of the line (e.g. a closing `]]` follows
						-- it), the trailing text must stay untouched, so no end-of-line handling is done.
						local covers_eol = line_end_col == #line
						local width = is_blank and 0
							or vim.fn.strdisplaywidth(line:sub(background_start_col + 1, line_end_col))
						-- The longest line has no panel padding, so leave its newline normal. Shorter lines use
						-- hl_eol to color the newline and the panel's padding. hl_eol needs a multiline range
						-- that cannot extend past the last buffer line.
						local extends_to_next_line = covers_eol and width < longest_width and row + 1 < line_count
						tint_range(
							buf,
							row,
							background_start_col,
							extends_to_next_line and row + 1 or row,
							extends_to_next_line and 0 or line_end_col,
							injected_code_group,
							3,
							extends_to_next_line
						)

						if covers_eol then
							if is_blank then
								-- No text to attach virtual text to, so overlay the whole line from column 0:
								-- the shared indentation, then the panel, then the reset to Normal.
								vim.api.nvim_buf_set_extmark(buf, namespace, row, 0, {
									virt_text = {
										{ string.rep(" ", indentation_width), "Normal" },
										{ string.rep(" ", longest_width), injected_code_group },
										{ string.rep(" ", normal_padding), "Normal" },
									},
									virt_text_pos = "overlay",
									priority = vim.hl.priorities.treesitter + 4,
									ephemeral = true,
								})
							elseif extends_to_next_line then
								-- Pad after the text up to the longest line, then reset to Normal. The newline
								-- cell is already colored by hl_eol, so it is subtracted from the panel padding
								-- and added to the reset.
								vim.api.nvim_buf_set_extmark(buf, namespace, row, line_end_col, {
									virt_text = {
										{
											string.rep(" ", math.max(longest_width - 1 - width, 0)),
											injected_code_group,
										},
										{ string.rep(" ", normal_padding + 1), "Normal" },
									},
									virt_text_pos = "eol",
									priority = vim.hl.priorities.treesitter + 4,
									ephemeral = true,
								})
							end
						end
					end
				end

				-- Per-token foregrounds use a higher priority and combine with the shared background.
				if groups and query then
					for capture, node in query:iter_captures(injected_tree:root(), buf, start_row, end_row) do
						local group = groups[query.captures[capture]]
						if group then
							local node_start_row, node_start_col, node_end_row, node_end_col = node:range()
							tint_range(buf, node_start_row, node_start_col, node_end_row, node_end_col, group, 4)
						end
					end
				end
			end)
		end

		-- Recurse even when this child is not included, since its own injections may be.
		tint_children(child, buf, start_row, start_col, end_row, end_col, text_width)
	end
end

--- Registers the decoration provider.
function M.setup()
	-- Colorschemes are never switched at runtime, so this only ever needs to run once.
	vim.api.nvim_set_hl(0, injected_code_group, injected_code_highlight)

	-- Called during redraw for each range of a window that needs to be drawn.
	vim.api.nvim_set_decoration_provider(namespace, {
		on_range = function(_, win, buf, start_row, start_col, end_row, end_col)
			-- Buffers without a Tree-sitter parser have no injections.
			local ok, parser = pcall(vim.treesitter.get_parser, buf)
			if not ok or not parser then
				return
			end

			local info = vim.fn.getwininfo(win)[1]
			if not info then
				return
			end

			-- Make sure injected trees exist and are current before walking them.
			parser:parse()
			-- textoff is the width of the number, sign and fold columns, which the text area excludes.
			tint_children(parser, buf, start_row, start_col, end_row, end_col, info.width - info.textoff)
		end,
	})
end

return M
