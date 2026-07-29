local M = {}

M.ddad_path = vim.fn.getcwd()
if string.match(vim.fn.fnamemodify(M.ddad_path, ":t"), ".*env_simulator.*") then
	-- 2 directories up
	M.ddad_path = vim.fn.fnamemodify(M.ddad_path, ":h:h")
end

---@param co thread
function M.select_config(co)
	local special_config = "env_simulator_clang with debug flags"
	Snacks.picker.select({ special_config, "env_simulator_debug", "env_simulator_clang", "env_simulator_release" }, {
		prompt = "Select config",
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
	}, function(v)
		coroutine.resume(co, v)
	end)
	local selected_config = coroutine.yield()

	local cmd_args = {}
	if selected_config ~= nil then
		if selected_config == special_config then
			vim.list_extend(
				cmd_args,
				{ "--config=env_simulator_clang", "--compilation_mode=dbg", "--cxxopt=-O0", "--strip=never" }
			)
		else
			table.insert(cmd_args, "--config=" .. selected_config)
		end
	end

	return cmd_args
end

---@param co thread
function M.select_override_repositories(co)
	local selected_repositories = nil
	Snacks.picker.select({ "osi_query_library" }, {
		prompt = "Select repositories to override",
		snacks = {
			actions = {
				confirm = function(picker, _)
					local selected = picker:selected({ fallback = true })
					selected_repositories = vim.tbl_map(function(entry)
						return entry.item
					end, selected)
					picker:close()
				end,
			},
			win = {
				input = {
					keys = {
						-- Cancel on first <Esc>
						["<Esc>"] = { "cancel", mode = { "n", "i" } },
					},
				},
			},
		},
	}, function()
		coroutine.resume(co)
	end)
	coroutine.yield()

	local cmd_args = {}
	for _, repository in ipairs(selected_repositories or {}) do
		if repository == "osi_query_library" then
			table.insert(cmd_args, "--override_repository=osi_query_library=/home/pedro/projects/osi-query-library")
		end
	end

	return cmd_args
end

---@param co thread
function M.input_args(co)
	Snacks.input({
		prompt = "Args:",
		win = {
			keys = {
				-- Cancel on first <Esc>
				i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
			},
		},
	}, function(value)
		coroutine.resume(co, value)
	end)
	return vim.split(coroutine.yield() or "", " +", { trimempty = true })
end

return M
