local data_util = require "data-util"

local mirror_ingredients =
{
	{ "steel-plate", 5 },
	{ "electronic-circuit", 5 },
}
local laser_tower_ingredients =
{
	{ "concrete", 500 },
}
local power_tower_ingredients =
{
	{ "concrete", 500 },
	{ "steel-plate", 400 },
}

if data.raw.item["glass"] then
	--- Replace copper with glass
	table.insert(mirror_ingredients, { "glass", 5 })

	table.insert(laser_tower_ingredients, { "steel-plate", 400 })
	table.insert(laser_tower_ingredients, { "glass", 100 })
else
	table.insert(mirror_ingredients, { "copper-plate", 5 })

	table.insert(laser_tower_ingredients, { "steel-plate", 500 })
end

if data.raw.item["electric-motor"] then
	-- Add motorisation
	table.insert(mirror_ingredients, { "electric-motor", 3 })

	table.insert(laser_tower_ingredients, { "electric-motor", 20 })
else
	table.insert(laser_tower_ingredients, { "iron-gear-wheel", 20 })
end

if data.raw.item["lithium-chloride"] then
	-- This is close enough to salt to count
	table.insert(power_tower_ingredients, { "lithium-chloride", 300 })
end

if mods["Krastorio2"] then

	table.insert(power_tower_ingredients, { "heat-pipe", 20 })
	table.insert(power_tower_ingredients, { "copper-plate", 300 })
else

	table.insert(power_tower_ingredients, { "copper-plate", 400 })
end

data:extend {
	{
		type = "recipe",
		name = data_util.mod_prefix .. "heliostat-mirror",
		energy_required = 5,
		enabled = false,
		ingredients = mirror_ingredients,
		result = data_util.mod_prefix .. "heliostat-mirror"
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-laser-tower",
		energy_required = 8,
		enabled = false,
		ingredients = laser_tower_ingredients,
		result = data_util.mod_prefix .. "solar-laser-tower",
		requester_paste_multiplier = 1
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-power-tower",
		energy_required = 8,
		enabled = false,
		ingredients = power_tower_ingredients,
		result = data_util.mod_prefix .. "solar-power-tower",
		requester_paste_multiplier = 1
	},
}
