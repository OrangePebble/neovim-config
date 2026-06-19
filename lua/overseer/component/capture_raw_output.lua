---@module "overseer"
---@type overseer.ComponentFileDefinition
return {
	-- Uses "task.metadata" so that the value is serialized.
	desc = "Captures raw terminal output (which included colors) into task.metadata.raw_output",
	serializable = false,
	constructor = function()
		return {
			on_start = function(self, task)
				task.metadata.raw_output = ""
			end,
			on_output = function(self, task, data)
				task.metadata.raw_output = task.metadata.raw_output .. table.concat(data, "\n")
			end,
		}
	end,
}
