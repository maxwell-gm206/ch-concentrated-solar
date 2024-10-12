local data_util = require("shared-util")

function data_util.sprite(name)
	return '__ch-concentrated-solar__/graphics/' .. name
end

function data_util.auto_hr(inputs)
	-- inputs.hr_version = table.deepcopy(inputs)
	-- inputs.hr_version.scale = (inputs.scale or 1) / 2
	-- if inputs.hr_version.width then
	-- 	inputs.hr_version.width = inputs.hr_version.width * 2
	-- 	inputs.hr_version.height = inputs.hr_version.height * 2
	-- else
	-- 	inputs.hr_version.size = inputs.hr_version.size * 2
	-- end


	-- inputs.hr_version.filename = data_util.sprite(inputs.filename .. "-hr.png")
	inputs.scale = (inputs.scale or 1) / 2
	inputs.filename = data_util.sprite(inputs.filename .. ".png")
	return inputs
end

-- Mod compatibility helpers - TODO: credit these properly, i forgor

function data_util.add_prerequisite(tech_name, prerequisite)
	local technology = data.raw.technology[tech_name]
	for _, name in pairs(technology.prerequisites) do
		if name == prerequisite then
			return
		end
	end
	table.insert(technology.prerequisites, prerequisite)
end

function data_util.remove_prerequisite(tech_name, prerequisite)
	local technology = data.raw.technology[tech_name]
	for i, name in pairs(technology.prerequisites) do
		if name == prerequisite then
			table.remove(technology.prerequisites, i)
		end
	end
end

function data_util.add_research_ingredient(tech_name, ingredient)
	local technology = data.raw.technology[tech_name]
	for _, name in pairs(technology.unit.ingredients) do
		if name[1] == ingredient then
			-- already exists
			return
		end
	end
	table.insert(technology.unit.ingredients, { ingredient, 1 })
end

function data_util.remove_research_ingredient(tech_name, ingredient)
	local technology = data.raw.technology[tech_name]
	for i, name in pairs(technology.unit.ingredients) do
		if name[1] == ingredient then
			table.remove(technology.unit.ingredients, i)
		end
	end
end

function data_util.contains_research_ingredient(tech_name, ingredient)
	local technology = data.raw.technology[tech_name]
	for _, name in pairs(technology.unit.ingredients) do
		if name[1] == ingredient then
			return true
		end
	end
	return false
end

-- Multiply production by K2 scalar if k2 is installed

data_util.solar_max_production_mw = settings.startup["ch-solar-max-production-mw"].value
if mods["Krastorio2"] then
	data_util.solar_max_production_mw =
		math.ceil(
			data_util.solar_max_production_mw *
			settings.startup["ch-k2-production-mult"].value)
end


-- (per second)
data_util.solar_max_consumption = 1

-- At the max temp, we want to generate exactly max production kw
-- using exactly max consumption units per second

-- luckily, this is easy to calculate, as the base temp of solar fluid is set to 0

-- production  = temp * heap capacity

data_util.solar_heat_capacity_kj = (data_util.solar_max_production_mw * 1000) / data_util.solar_max_temp

-- scale to 1 second intervals

data_util.solar_heat_capacity_kj = data_util.solar_heat_capacity_kj / data_util.solar_max_consumption



return data_util
