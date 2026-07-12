local M = {}

M.pick_file = function(path, title)
	if path:sub(-1) ~= "/" then
		path = path .. "/"
	end
	local co = coroutine.running()
	local selected = nil
	Snacks.picker.files({
		cwd = path,
		prompt = title or "Pick a file",
		ignored = true,
		hidden = true,
		layout = { hidden = { "preview" } },
		confirm = function(picker, item)
			selected = item and item.file or nil
			picker:close()
		end,
		on_close = function()
			coroutine.resume(co)
		end,
		snacks = {
			-- Disable multi-selection
			win = {
				input = {
					keys = {
						["<Tab>"] = false,
						["<S-Tab>"] = false,
						["<c-a>"] = false,
					},
				},
				list = {
					keys = {
						["<Tab>"] = false,
						["<S-Tab>"] = false,
						["<c-a>"] = false,
					},
				},
			},
		},
	})
	coroutine.yield()
	if selected == nil then
		return nil
	end
	return path .. selected
end

return M
