local control_util = require "control-util"

local notify_on_delete = {
	control_util.solar_power_tower, control_util.solar_laser_tower, control_util.heliostat_mirror,
}

for _, surface in pairs(game.surfaces) do
	for _, entity in pairs(surface.find_entities_filtered { name = notify_on_delete }) do
		local id, sec_id, type = script.register_on_object_destroyed(entity)
		assert(sec_id == entity.unit_number,
			"Register on object destroyed should return the entity ID of the object")
	end
end
