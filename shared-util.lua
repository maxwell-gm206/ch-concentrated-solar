local shared_util = {}

---@using meta





shared_util.mod_prefix = "chcs-"
shared_util.solar_power_tower = shared_util.mod_prefix .. "solar-power-tower"
shared_util.heliostat_mirror = shared_util.mod_prefix .. "heliostat-mirror"


shared_util.solar_max_temp = 600
-- (per second)
shared_util.solar_max_production_kw = 40000
-- (per second)
shared_util.solar_max_consumption = 1


-- At the max temp, we want to generate exactly max production kw
-- using exactly max consumption units per second

-- luckily, this is easy to calculate, as the base temp of solar fluid is set to 0

-- production  = temp * heap capacity

shared_util.solar_heat_capacity_kj = shared_util.solar_max_production_kw / shared_util.solar_max_temp

-- scale to 1 second intervals

shared_util.solar_heat_capacity_kj = shared_util.solar_heat_capacity_kj / shared_util.solar_max_consumption

shared_util.solar_laser_ticks_between_shots = 60

return shared_util
