--- Client for modules/terminal/pi/socket-server.ts.
---
--- Bind `require("config.pi").prompt` to call Pi from Neovim. The first call
--- discovers the running Pi TUI instances; later calls target the selected
--- instance directly. Escape from the prompt input reopens the instance picker.
local M = {}

local picker = require("utils.picker")
local uv = vim.uv
local selected_socket ---@type string|nil
local event_socket ---@type userdata|nil
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

local function close_event_subscription()
	if event_socket then
		close_socket(event_socket)
		event_socket = nil
	end
end

---@param event table
local function handle_event(event)
	if event.event == "permissions:ui_prompt" then
		local request = event.data and event.data.request or {}
		local tool = event.data.surface or request.surface or "tool"
		vim.notify("Pi permission request: " .. tool, vim.log.levels.WARN)
	elseif event.event == "agent_settled" then
		vim.notify("Pi prompt completed", vim.log.levels.INFO)
	end
end

---@param socket_path string
local function subscribe(socket_path)
	close_event_subscription()
	local socket = assert(uv.new_pipe(false))
	local buffer = ""
	event_socket = socket

	socket:connect(socket_path, function(connect_error)
		if socket ~= event_socket then
			return
		end
		if connect_error then
			close_event_subscription()
			vim.notify("Pi event subscription failed: " .. connect_error, vim.log.levels.ERROR)
			return
		end

		socket:read_start(function(read_error, chunk)
			if socket ~= event_socket then
				return
			end
			if read_error or not chunk then
				close_event_subscription()
				return
			end
			buffer = buffer .. chunk
			while true do
				local newline = buffer:find("\n", 1, true)
				if not newline then
					break
				end
				local line = buffer:sub(1, newline - 1):gsub("\r$", "")
				buffer = buffer:sub(newline + 1)
				local ok, message = pcall(vim.json.decode, line)
				if ok and type(message) == "table" and message.type == "event" then
					vim.schedule(function()
						handle_event(message)
					end)
				end
			end
		end)

		socket:write(vim.json.encode({ id = "neovim-subscribe", type = "subscribe" }) .. "\n", function(write_error)
			if write_error and socket == event_socket then
				close_event_subscription()
				vim.schedule(function()
					vim.notify("Pi event subscription failed: " .. write_error, vim.log.levels.ERROR)
				end)
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

---@param started_at unknown
---@return string
local function relative_start_time(started_at)
	if type(started_at) ~= "number" then
		return "unknown time"
	end
	local seconds = math.max(0, os.time() - started_at)
	if seconds < 60 then
		return "just now"
	elseif seconds < 60 * 60 then
		return string.format("%dm ago", math.floor(seconds / 60))
	elseif seconds < 24 * 60 * 60 then
		return string.format("%dh ago", math.floor(seconds / (60 * 60)))
	end
	return string.format("%dd ago", math.floor(seconds / (24 * 60 * 60)))
end

---@param directory unknown
---@return string
local function shorten_home_directory(directory)
	if type(directory) ~= "string" then
		return "unknown cwd"
	end
	local home = vim.env.HOME
	if not home or home == "" then
		return directory
	end
	if directory == home then
		return "~"
	end
	if vim.startswith(directory, home .. "/") then
		return "~" .. directory:sub(#home + 1)
	end
	return directory
end

---@param instance table
---@return string
local function format_instance(instance)
	local name = without_json_null(instance.sessionName)
	local started = relative_start_time(instance.startedAt)
	local cwd = shorten_home_directory(without_json_null(instance.cwd))
	local time = "󰥔 " .. started
	local folder = " " .. cwd
	if type(name) == "string" and name ~= "" then
		return string.format("%s │ %s │ %s", name, time, folder)
	end
	return string.format("%s │ %s", time, folder)
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
				subscribe(selected_socket)
				M.open_input()
				return
			end

			table.sort(instances, function(left, right)
				return format_instance(left) < format_instance(right)
			end)
			picker.select_one(instances, {
				prompt = "Select Pi instance",
				format_item = format_instance,
			}, function(instance)
				if not instance then
					return
				end
				selected_socket = instance.socket_path
				subscribe(selected_socket)
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
	close_event_subscription()
end

return M
