--- Client for modules/terminal/pi/socket-server.ts.
---
--- Bind `require("config.pi").prompt` to call Pi from Neovim. The first call
--- discovers the running Pi TUI instances; later calls target the selected
--- instance directly. Escape from the prompt input reopens the instance picker.
local M = {}

-- Match opencode.nvim's placeholder color, which the configured theme renders
-- in orange, without depending on the OpenCode plugin's highlight group.
vim.api.nvim_set_hl(0, "PiContextReference", { link = "@lsp.type.enum", default = true })
vim.api.nvim_set_hl(0, "PiSelectedInstance", { link = "FloatTitle", default = true })

local picker = require("utils.picker")
local uv = vim.uv
local context_references = { "@this", "@buffer", "@diagnostics_buffer", "@diagnostics_line", "@diagnostics", "@quickfix" }
function M.new()
	return setmetatable({}, { __index = M })
end

function M:enabled()
	return vim.bo.filetype == "snacks_input" and vim.b.pi_context_input == true
end

function M:get_trigger_characters()
	return { "@" }
end

function M:get_completions(context, callback)
	local before_cursor = context.line:sub(1, context.cursor[2])
	local _, _, start_column = before_cursor:find("()@[%a_]*$")
	if not start_column then
		callback({ items = {} })
		return
	end

	local kind = require("blink.cmp.types").CompletionItemKind.Enum
	local items = vim.tbl_map(function(reference)
		return {
			label = reference,
			kind = kind,
			textEdit = {
				newText = reference,
				range = {
					start = { line = context.cursor[1] - 1, character = start_column - 1 },
					["end"] = { line = context.cursor[1] - 1, character = context.cursor[2] },
				},
			},
		}
	end, context_references)
	callback({ items = items })
end

local selected_socket ---@type string|nil
local event_socket ---@type userdata|nil
local progress ---@type ProgressHandle|nil
local progress_phase ---@type string|nil
local terminal_stop_reason ---@type string|nil
local input_context ---@type table|nil
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

---@param socket_path string
local function forget_selected_socket(socket_path)
	if selected_socket == socket_path then
		selected_socket = nil
	end
end

local function ensure_progress()
	if progress then
		return
	end
	progress = require("fidget.progress").handle.create({
		title = "Pi",
		message = "Working",
		lsp_client = { name = "Pi" },
		percentage = 0,
	})
end

---@param phase string
---@param message string
local function set_progress(phase, message)
	ensure_progress()
	-- message_update arrives for every streamed token. Do not redraw Fidget
	-- unless Pi has actually entered a different visible phase.
	if progress_phase == phase then
		return
	end
	progress_phase = phase
	progress.message = message
end

---@param event table
local function handle_event(event)
	local event_name = event.event or "unknown event"
	-- Keep a single stable Fidget progress item alive for the whole Pi agent
	-- run. agent_settled, unlike agent_end, means retries and queued work have
	-- also completed.
	if event_name == "agent_start" then
		terminal_stop_reason = nil
		set_progress("starting", "Starting")
	elseif event_name == "turn_start" then
		set_progress("thinking", "Thinking")
	elseif event_name == "message_start" then
		if event.data and event.data.message and event.data.message.role == "assistant" then
			set_progress("responding", "Responding")
		end
	elseif event_name == "message_update" then
		set_progress("responding", "Responding")
	elseif event_name == "agent_end" then
		local messages = event.data and event.data.messages or {}
		local last_assistant
		for index = #messages, 1, -1 do
			if messages[index].role == "assistant" then
				last_assistant = messages[index]
				break
			end
		end
		if not (event.data and event.data.willRetry) and last_assistant then
			local reason = last_assistant.stopReason
			if reason == "error" or reason == "aborted" then
				terminal_stop_reason = reason
			end
		end
		set_progress("finishing", "Finishing")
	elseif event_name == "tool_execution_start" then
		local tool_name = event.data and event.data.toolName or "tool"
		set_progress("tool:" .. tool_name, "Running " .. tool_name)
	elseif event_name == "tool_execution_update" then
		local tool_name = event.data and event.data.toolName or "tool"
		set_progress("tool-update:" .. tool_name, "Running " .. tool_name .. "…")
	elseif event_name == "tool_execution_end" then
		local tool_name = event.data and event.data.toolName or "tool"
		set_progress("tool-finished:" .. tool_name, "Finished " .. tool_name)
	elseif event_name == "permissions:ui_prompt" then
		set_progress("permission", "Waiting for permission")
	elseif event_name == "ui_prompt_start" then
		set_progress("user-input", "Waiting for user input")
	elseif event_name == "session_compact" and progress then
		set_progress("compacted", "Context compacted")
	elseif event_name == "session_compact_failed" and progress then
		set_progress("compaction-failed", "Compaction failed")
	elseif event_name == "agent_settled" then
		if progress then
			progress.title = "Pi finished"
			progress.message = "Prompt completed"
			progress:finish()
			progress = nil
			progress_phase = nil
		end
	elseif event_name == "session_shutdown" then
		-- The subscription belongs to the terminating extension runtime. Even
		-- though /reload recreates the same pathname, require an explicit fresh
		-- selection rather than treating it as a live subscription.
		selected_socket = nil
		if progress then
			progress.title = "Pi disconnected"
			progress:finish()
			progress = nil
			progress_phase = nil
		end
	end

	if event_name == "permissions:ui_prompt" then
		local request = event.data and event.data.request or {}
		local tool = event.data.surface or request.surface or "tool"
		vim.notify("Pi permission request: " .. tool, vim.log.levels.WARN)
	elseif event_name == "ui_prompt_start" then
		local title = event.data and event.data.title
		vim.notify("Pi is waiting for user input" .. (title and (": " .. title) or ""), vim.log.levels.WARN)
	elseif event_name == "session_compact_failed" and not (event.data and event.data.aborted) then
		local reason = event.data and event.data.reason or "unknown reason"
		vim.notify("Pi compaction failed (" .. reason .. "); context may be full", vim.log.levels.WARN)
	elseif event_name == "agent_settled" then
		if terminal_stop_reason then
			vim.notify("Pi stopped: " .. terminal_stop_reason, vim.log.levels.WARN)
		else
			vim.notify("Pi prompt completed", vim.log.levels.INFO)
		end
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
			forget_selected_socket(socket_path)
			vim.notify("Pi event subscription failed: " .. connect_error, vim.log.levels.ERROR)
			return
		end

		socket:read_start(function(read_error, chunk)
			if socket ~= event_socket then
				return
			end
			if read_error or not chunk then
				close_event_subscription()
				forget_selected_socket(socket_path)
				vim.schedule(function()
					vim.notify("Pi socket lost", vim.log.levels.WARN)
				end)
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
				if ok and type(message) == "table" then
					vim.schedule(function()
						if message.type == "event" then
							handle_event(message)
						elseif message.type == "response" and message.success then
							require("fidget").notify("Subscribed to Pi events")
							if message.data and not message.data.idle then
								-- The agent may already be running when Neovim subscribes, in
								-- which case no future agent_start event is guaranteed.
								ensure_progress()
							end
						end
					end)
				end
			end
		end)

		socket:write(vim.json.encode({ id = "neovim-subscribe", type = "subscribe" }) .. "\n", function(write_error)
			if write_error and socket == event_socket then
				close_event_subscription()
				forget_selected_socket(socket_path)
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
---@param supports_chunks? boolean
---@return string|snacks.picker.Highlight[]
local function format_instance(instance, supports_chunks)
	local name = without_json_null(instance.sessionName)
	local started = relative_start_time(instance.startedAt)
	local cwd = shorten_home_directory(without_json_null(instance.cwd))
	local time = "󰥔 " .. started
	local folder = " " .. cwd
	local text = type(name) == "string" and name ~= ""
		and string.format("%s │ %s │ %s", name, time, folder)
		or string.format("%s │ %s", time, folder)
	if supports_chunks and instance.socket_path == selected_socket then
		return { { text, "PiSelectedInstance" } }
	end
	return text
end

---@param instance table
---@param on_ready? fun()
local function activate_instance(instance, on_ready)
	selected_socket = instance.socket_path
	subscribe(selected_socket)
	if on_ready then
		on_ready()
	else
		M.open_input()
	end
end

---@param force_picker? boolean
---@param on_ready? fun()
local function choose_instance(force_picker, on_ready)
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

			if #instances == 1 then
				if not force_picker then
					activate_instance(instances[1], on_ready)
				end
				-- Escape from the input opens the picker to switch instances. If
				-- there is only one live instance, there is nothing to choose, so
				-- treat it as immediately cancelling that picker as well.
				return
			end

			table.sort(instances, function(left, right)
				if left.socket_path == selected_socket then
					return true
				end
				if right.socket_path == selected_socket then
					return false
				end
				return (left.startedAt or 0) > (right.startedAt or 0)
			end)
			picker.select_one(instances, {
				prompt = "Select Pi instance",
				format_item = format_instance,
			}, function(instance)
				if not instance then
					return
				end
				activate_instance(instance, on_ready)
			end)
		end)
	end
end

---@param message string
---@param append_to_editor boolean
local function send_prompt(message, append_to_editor)
	request(selected_socket, {
		id = "neovim-prompt-" .. request_number,
		type = append_to_editor and "append_editor_text" or "prompt",
		message = message,
		delivery = "steer",
	}, function(response, error)
		if error or not response or not response.success then
			selected_socket = nil
			vim.notify("Pi prompt failed: " .. (error or response.error or "unknown error"), vim.log.levels.ERROR)
			choose_instance()
			return
		end
		vim.notify(append_to_editor and "Prompt appended to Pi editor" or "Prompt sent to Pi", vim.log.levels.INFO)
	end)
end

---@param bufnr integer
---@return string|nil
local function absolute_buffer_path(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	return path ~= "" and shorten_home_directory(vim.fn.fnamemodify(path, ":p")) or nil
end

---@return table
local function capture_input_context()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local start_line, end_line = cursor[1], cursor[1]
	if vim.fn.mode():match("^[vV\22]") then
		-- Visual marks are not finalized until visual mode ends. Execute Escape
		-- before reading them, matching opencode.nvim's context capture.
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", true)
		local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
		local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")
		start_line = math.min(start_pos[1], end_pos[1])
		end_line = math.max(start_pos[1], end_pos[1])
	end
	return {
		path = absolute_buffer_path(bufnr),
		start_line = start_line,
		end_line = end_line,
		cursor_line = cursor[1],
		cursor_column = cursor[2],
		diagnostics = vim.diagnostic.get(bufnr),
		quickfix = vim.fn.getqflist(),
	}
end

---@param diagnostics vim.Diagnostic[]
---@return string
local function format_diagnostics(diagnostics)
	if #diagnostics == 0 then
		return "No diagnostics found"
	end
	local lines = { "Diagnostics:" }
	for _, diagnostic in ipairs(diagnostics) do
		local path = absolute_buffer_path(diagnostic.bufnr) or "unknown file"
		local message = vim.trim(diagnostic.message:gsub("%s+", " "))
		local source = diagnostic.source and (" (" .. diagnostic.source .. ")") or ""
		table.insert(lines, string.format("- %s:L%d:C%d%s: %s", path, diagnostic.lnum + 1, diagnostic.col + 1, source, message))
	end
	return table.concat(lines, "\n")
end

---@param context table
---@return vim.Diagnostic[]
local function cursor_diagnostics(context)
	local line = context.cursor_line - 1
	local column = context.cursor_column
	return vim.tbl_filter(function(diagnostic)
		local end_line = diagnostic.end_lnum or diagnostic.lnum
		if line < diagnostic.lnum or line > end_line then
			return false
		end
		if diagnostic.lnum == end_line then
			return column >= diagnostic.col and column <= (diagnostic.end_col or math.huge)
		end
		if line == diagnostic.lnum then
			return column >= diagnostic.col
		end
		if line == end_line then
			return column <= (diagnostic.end_col or math.huge)
		end
		return true
	end, context.diagnostics)
end

---@param context table
---@return vim.Diagnostic[]
local function line_diagnostics(context)
	local line = context.cursor_line - 1
	return vim.tbl_filter(function(diagnostic)
		return diagnostic.lnum <= line and line <= (diagnostic.end_lnum or diagnostic.lnum)
	end, context.diagnostics)
end

---@param context table
---@return string
local function format_quickfix(context)
	if #context.quickfix == 0 then
		return "No quickfix entries found"
	end
	local lines = { "Quickfix entries:" }
	for _, entry in ipairs(context.quickfix) do
		local path = entry.filename
		if (not path or path == "") and entry.bufnr and entry.bufnr ~= 0 then
			path = vim.api.nvim_buf_get_name(entry.bufnr)
		end
		path = path and path ~= "" and shorten_home_directory(vim.fn.fnamemodify(path, ":p")) or "unknown file"
		local location = entry.lnum and entry.lnum > 0 and (":L" .. entry.lnum) or ""
		local message = entry.text and (": " .. vim.trim(entry.text:gsub("%s+", " "))) or ""
		table.insert(lines, "- " .. path .. location .. message)
	end
	return table.concat(lines, "\n")
end

---@param text string
---@return snacks.input.Highlight[]
local function highlight_context_references(text)
	local highlights = {}
	for start_column, end_column in text:gmatch("()@[%a_]+()") do
		local reference = text:sub(start_column, end_column - 1)
		for _, candidate in ipairs(context_references) do
			if vim.startswith(candidate, reference) then
				-- A partially typed valid reference, such as @diag.
				table.insert(highlights, { start_column - 1, end_column - 1, "PiContextReference" })
				break
			elseif vim.startswith(reference, candidate) then
				-- Preserve the valid colored prefix in text such as
				-- @diagnostics_more, while leaving the suffix uncolored.
				table.insert(highlights, { start_column - 1, start_column - 1 + #candidate, "PiContextReference" })
				break
			end
		end
	end
	return highlights
end

---@param message string
---@param context table
---@return string
local function expand_context_references(message, context)
	local this = context.path and string.format("%s:L%d-%d", context.path, context.start_line, context.end_line) or "unknown file"
	-- `%f[^%a_]` makes the reference exact: @this expands, while @this_more
	-- remains ordinary prompt text. A trailing space is not required.
	message = message:gsub("@this%f[^%a_]", this)
	message = message:gsub("@buffer%f[^%a_]", context.path or "unknown file")
	message = message:gsub("@diagnostics_buffer%f[^%a_]", format_diagnostics(context.diagnostics))
	message = message:gsub("@diagnostics_line%f[^%a_]", format_diagnostics(line_diagnostics(context)))
	message = message:gsub("@diagnostics%f[^%a_]", format_diagnostics(cursor_diagnostics(context)))
	return message:gsub("@quickfix%f[^%a_]", format_quickfix(context))
end

---@param default? string
function M.open_input(default)
	if not selected_socket then
		choose_instance()
		return
	end

	local input = Snacks.input({
		prompt = "Prompt AI (pi)",
		default = default,
		icon = "󰚩",
		highlight = highlight_context_references,
		win = { relative = "cursor", row = 1, col = -2 },
	}, function(message)
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
		local append_to_editor = message:sub(-1) == " "
		local context = input_context or capture_input_context()
		local wants_cursor_diagnostics = message:find("@diagnostics", 1, true)
			and not message:find("@diagnostics_line", 1, true)
			and not message:find("@diagnostics_buffer", 1, true)
		if wants_cursor_diagnostics and #cursor_diagnostics(context) == 0 then
			vim.notify("No diagnostics under the cursor", vim.log.levels.WARN)
			M.open_input(message)
			return
		end
		if message:find("@diagnostics_line", 1, true) and #line_diagnostics(context) == 0 then
			vim.notify("No diagnostics on the current line", vim.log.levels.WARN)
			M.open_input(message)
			return
		end
		if message:find("@diagnostics_buffer", 1, true) and #context.diagnostics == 0 then
			vim.notify("No diagnostics in the current buffer", vim.log.levels.WARN)
			M.open_input(message)
			return
		end
		if message:find("@quickfix", 1, true) and #context.quickfix == 0 then
			vim.notify("The quickfix list is empty", vim.log.levels.WARN)
			M.open_input(message)
			return
		end
		input_context = nil
		request_number = request_number + 1
		-- A trailing space means place the expanded prompt in Pi's editor for
		-- review rather than submitting it to the agent.
		send_prompt(expand_context_references(message, context), append_to_editor)
	end)
	-- Snacks disables completion in its prompt buffers by default. Opt this Pi
	-- input into blink.cmp's snacks_input source after the window is created.
	vim.b[input.buf].completion = true
	vim.b[input.buf].pi_context_input = true
end

--- Open the picker on first use, otherwise prompt the currently selected Pi.
function M.prompt()
	-- Capture selection, diagnostics, and quickfix state before Snacks.input
	-- changes focus. @this, @buffer, @diagnostics, and @quickfix in the prompt
	-- are expanded only when the input is submitted.
	input_context = capture_input_context()
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
