local M = {}

-- Disable multi-selection keymaps.
local single_select_keys = {
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
}

-- Make it so a single <Esc> exits the picker.
local single_esc_key = {
	win = {
		input = {
			keys = {
				["<Esc>"] = { "cancel", mode = { "n", "i" } },
			},
		},
	},
}

---@param opts table|nil
---@param snacks_opts table|nil
---@return table
local function with_snacks_opts(opts, snacks_opts)
	local merged_opts = vim.deepcopy(opts or {})
	merged_opts.snacks = vim.tbl_deep_extend("force", merged_opts.snacks or {}, snacks_opts or {})
	return merged_opts
end

---@param items any[]
---@param opts table|nil
---@param on_choice fun(item: any|nil)
function M.select_one(items, opts, on_choice)
	Snacks.picker.select(items, with_snacks_opts(opts, single_select_keys), on_choice)
end

---@param items any[]
---@param opts table|nil
---@param on_choice fun(items: any[]|nil)
function M.select_many(items, opts, on_choice)
	local done = false
	Snacks.picker.select(items, with_snacks_opts(opts, {
		actions = {
			confirm = function(picker, _)
				if done then
					return
				end
				done = true
				local selected = picker:selected({ fallback = true })
				picker:close()
				on_choice(vim.tbl_map(function(entry)
					return entry.item
				end, selected))
			end,
		},
	}), function()
		if done then
			return
		end
		done = true
		on_choice(nil)
	end)
end

-- This picker is intended for use in cases where the most common action is dismissing it.
---@param items any[]
---@param opts table|nil
---@param on_choice fun(item: any|nil)
function M.select_one_esc(items, opts, on_choice)
	Snacks.picker.select(items, with_snacks_opts(opts, vim.tbl_deep_extend("force", single_select_keys, single_esc_key)), on_choice)
end

-- This picker is intended for use in cases where the most common action is dismissing it.
---@param items any[]
---@param opts table|nil
---@param on_choice fun(items: any[]|nil)
function M.select_many_esc(items, opts, on_choice)
	M.select_many(items, with_snacks_opts(opts, single_esc_key), on_choice)
end

M.pick_file = function(path, title)
	if path:sub(-1) ~= "/" then
		path = path .. "/"
	end
	local co = coroutine.running()
	local selected = nil
	Snacks.picker.files({
		cwd = path,
		title = title or "Pick a file",
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
		snacks = single_select_keys,
	})
	coroutine.yield()
	if selected == nil then
		return nil
	end
	return path .. selected
end

return M
