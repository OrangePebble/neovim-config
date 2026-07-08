---@module "overseer"
---@type overseer.ComponentFileDefinition
return {
	desc = "Resume a coroutine on task completion and return status.",
	serializable = false,
	params = {
		coroutine = {
			desc = "Coroutine to resume with task status",
			type = "opaque",
		},
	},
	constructor = function(params)
		return {
			on_complete = function(self, task, status)
				if params.coroutine then
					coroutine.resume(params.coroutine, status)
				end
			end,
		}
	end,
}
