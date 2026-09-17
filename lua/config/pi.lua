--- Client for modules/terminal/pi/socket-server.ts.
---
--- Bind `require("config.pi").prompt` to call Pi from Neovim. The first call
--- discovers the running Pi TUI instances; later calls target the selected
--- instance directly. Escape from the prompt input reopens the instance picker.
local M = {}

local uv = vim.uv
local selected_socket ---@type string|nil
local request_number = 0

---@return string
local function socket_directory()
	if vim.env.XDG_RUNTIME_DIR and vim.env.XDG_RUNTIME_DIR ~= "" then
		return vim.fs.joinpath(vim.env.XDG_RUNTIME_DIR, "pi-sockets")
	end
	return "/tmp/pi-" .. vim.fn.getuid() .. "-sockets"
end

---@param socket userdata
local function close_socket(socket)
	if not socket:is_closing() then
		socket:read_stop()
		socket:close()
	end
end

---@param socket_path string
---@param request table
---@param callback fun(response: table|nil, error: string|nil)
local function request(socket_path, request, callback)
	local socket = assert(uv.new_pipe(false))
	local completed = false
	local timer = assert(uv.new_timer())
	local buffer = ""

	local function finish(response, error)
		if completed then
			return
		end
		completed = true
		if not timer:is_closing() then
			timer:stop()
			timer:close()
		end
		close_socket(socket)
		vim.schedule(function()
			callback(response, error)
		end)
	end

	-- A stale socket normally fails connect immediately. The timeout also keeps
	-- discovery responsive if a process is wedged after accepting a connection.
	timer:start(1000, 0, function()
		finish(nil, "timed out")
	end)

	socket:connect(socket_path, function(connect_error)
		if completed then
			return
		end
		if connect_error then
			finish(nil, connect_error)
			return
		end

		socket:read_start(function(read_error, chunk)
			if completed then
				return
			end
			if read_error then
				finish(nil, read_error)
				return
			end
			if not chunk then
				finish(nil, "connection closed without a response")
				return
			end

			buffer = buffer .. chunk
			local newline = buffer:find("\n", 1, true)
			if not newline then
				return
			end
			local line = buffer:sub(1, newline - 1):gsub("\r$", "")
			local ok, response = pcall(vim.json.decode, line)
			if ok and type(response) == "table" then
				finish(response, nil)
			else
				finish(nil, "invalid JSON response")
			end
		end)

		socket:write(vim.json.encode(request) .. "\n", function(write_error)
			if completed then
				return
			end
			if write_error then
				finish(nil, write_error)
			end
		end)
	end)
end

---@param value unknown
---@return unknown
local function without_json_null(value)
	-- `condition and nil or value` would return value again because nil is
	-- falsy in Lua, so this must be an explicit branch.
	if value == vim.NIL then
		return nil
	end
	return value
end

---@param instance table
---@return string
local function format_instance(instance)
	local model = without_json_null(instance.model)
	local model_name = model and (model.provider .. "/" .. model.id) or "no model"
	local name = without_json_null(instance.sessionName) or "unnamed session"
	local cwd = without_json_null(instance.cwd) or "unknown cwd"
	return string.format("%s  │  %s  │  %s", name, model_name, cwd)
end

---@param force_picker? boolean
local function choose_instance(force_picker)
	local socket_paths = vim.fn.globpath(socket_directory(), "*.sock", false, true)
	if #socket_paths == 0 then
		vim.notify("No running Pi TUI sockets found in " .. socket_directory(), vim.log.levels.WARN)
		return
	end

	local instances = {}
	local remaining = #socket_paths
	for _, socket_path in ipairs(socket_paths) do
		request(socket_path, { id = "neovim-info", type = "get_info" }, function(response)
			if response and response.success and response.data and response.data.instance then
				local instance = response.data.instance
				instance.socket_path = socket_path
				instances[#instances + 1] = instance
			end
			remaining = remaining - 1
			if remaining ~= 0 then
				return
			end

			if #instances == 0 then
				vim.notify("Pi sockets were found, but none responded to get_info", vim.log.levels.WARN)
				return
			end

			if #instances == 1 and not force_picker then
				selected_socket = instances[1].socket_path
				M.open_input()
				return
			end

			table.sort(instances, function(left, right)
				return format_instance(left) < format_instance(right)
			end)
			Snacks.picker.select(instances, {
				prompt = "Select Pi instance",
				format_item = format_instance,
			}, function(instance)
				if not instance then
					return
				end
				selected_socket = instance.socket_path
				M.open_input()
			end)
		end)
	end
end

---@param message string
local function send_prompt(message)
	request(selected_socket, {
		id = "neovim-prompt-" .. request_number,
		type = "prompt",
		message = message,
		delivery = "steer",
	}, function(response, error)
		if error or not response or not response.success then
			selected_socket = nil
			vim.notify("Pi prompt failed: " .. (error or response.error or "unknown error"), vim.log.levels.ERROR)
			choose_instance()
			return
		end
		vim.notify("Prompt sent to Pi", vim.log.levels.INFO)
	end)
end

function M.open_input()
	if not selected_socket then
		choose_instance()
		return
	end

	Snacks.input({ prompt = "Prompt Pi" }, function(message)
		-- Snacks passes nil only when the user cancels (including Escape). Return
		-- to the picker so a different live Pi instance can be selected.
		if message == nil then
			choose_instance(true)
			return
		end
		if vim.trim(message) == "" then
			M.open_input()
			return
		end
		request_number = request_number + 1
		send_prompt(message)
	end)
end

--- Open the picker on first use, otherwise prompt the currently selected Pi.
function M.prompt()
	if selected_socket then
		M.open_input()
	else
		choose_instance()
	end
end

--- Forget the selected instance so the next `prompt()` call opens the picker.
function M.reset()
	selected_socket = nil
end

return M
