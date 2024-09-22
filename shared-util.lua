local shared_util = {}




shared_util.mod_prefix = "chcs-"
shared_util.solar_power_tower = shared_util.mod_prefix .. "solar-power-tower"
shared_util.heliostat_mirror = shared_util.mod_prefix .. "heliostat-mirror"

---@type uint
shared_util.solar_max_temp = 600



---@type uint
shared_util.fluidTempPerMirror = 1.1



shared_util.tower_capture_radius = 35
shared_util.tower_capture_radius_sqr = shared_util.tower_capture_radius ^ 2


shared_util.solar_laser_ticks_between_shots = 60




-- Number of groups of mirrors that will have sun rays spawned on them
shared_util.sun_stages = 20

-- Number of sets of mirrors, used to spawn sun-rays
shared_util.mirror_groups = 100

-- Number of mirrors required to saturate a tower on a solar intensity 1 world.
---@type uint
local max_mirrors_per_tower = math.ceil(shared_util.solar_max_temp / shared_util.fluidTempPerMirror)

-- Maximum mirrors to fully saturate a tower, based on the solar power multiplier of its surface.
-- Tower can be any reference entity, as long as it is on the current surface
---@nodiscard
---@param surface LuaSurface
---@return number
function shared_util.surface_max_mirrors(surface)
	return math.ceil(max_mirrors_per_tower / surface.solar_power_multiplier)
end

return shared_util
