local beams = {}
local control_util = require "control-util"


---@param inputs {tower:LuaEntity, mirror:LuaEntity, ttl:uint?, mirrored:boolean?, blend : number?}
---@return LuaEntity?
---@nodiscard
--- Create a beam from a `mirror` to a `tower`, lasting for `ttl`
function beams.generateBeam(inputs)
	local name

	if inputs.mirrored == nil or inputs.mirrored then
		name = control_util.mod_prefix .. "mirrored-solar-beam"
	else
		name = control_util.mod_prefix .. "solar-beam"
	end

	local source = control_util.towerTarget(inputs.tower)
	local target = inputs.mirror.position

	target.y = target.y - 0.5
	local blend = inputs.blend or 0.9
	-- shift towards mirror a little
	source.x = source.x * blend + target.x * (1 - blend)
	source.y = source.y * blend + target.y * (1 - blend)


	return inputs.mirror.surface.create_entity {
		position = target,
		name = name,
		raise_built = false,
		duration = inputs.ttl or 0,
		target_position = target,
		source_position = source
	}
end

function beams.delete_all_beams()
	for _, surf in pairs(game.surfaces) do
		beams = surf.find_entities_filtered { name = control_util.mod_prefix .. "mirrored-solar-beam" }
		for _, beam in pairs(beams) do
			beam.destroy()
		end
	end
end

return beams
