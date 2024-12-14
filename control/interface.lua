local control_util = require "control-util"

local interface = {}

function interface.towers()
	local towers = {}
	for number, tower in pairs(storage.towers) do
		towers[number] = { entity = tower.tower, mirror_count = table_size(tower.mirrors) }
	end
	return towers
end

interface.max_mirrors = control_util.surface_max_mirrors
interface.register_tower_name = control_util.register_tower_name

remote.add_interface("ch-concentrated-solar", interface)
