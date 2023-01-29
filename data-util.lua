local data_util = require("shared-util")

data_util.sprite = function(name)
	return '__ch-concentrated-solar__/graphics/' .. name
end

data_util.auto_hr = function(inputs)


	inputs.hr_version = table.deepcopy(inputs)
	inputs.hr_version.scale = (inputs.scale or 1) / 2
	if inputs.hr_version.width then

		inputs.hr_version.width = inputs.hr_version.width * 2
		inputs.hr_version.height = inputs.hr_version.height * 2
	else
		inputs.hr_version.size = inputs.hr_version.size * 2
	end


	inputs.hr_version.filename = data_util.sprite(inputs.filename .. "-hr.png")
	inputs.filename = data_util.sprite(inputs.filename .. ".png")
	return inputs
end

-- (per second)
---@type uint
data_util.solar_max_production_kw = 60000

if mods["Krastorio2"] then
	data_util.solar_max_production_kw = 110000
end


-- (per second)
data_util.solar_max_consumption = 1

-- At the max temp, we want to generate exactly max production kw
-- using exactly max consumption units per second

-- luckily, this is easy to calculate, as the base temp of solar fluid is set to 0

-- production  = temp * heap capacity

data_util.solar_heat_capacity_kj = data_util.solar_max_production_kw / data_util.solar_max_temp

-- scale to 1 second intervals

data_util.solar_heat_capacity_kj = data_util.solar_heat_capacity_kj / data_util.solar_max_consumption



return data_util
