local data_util = require "data-util"

local mirror_ingredients =
{
	{ type = "item", name = "steel-plate",        amount = 5 },
	{ type = "item", name = "electronic-circuit", amount = 5 },
}
local laser_tower_ingredients =
{
	{ type = "item", name = "concrete", amount = 500 },
}
local power_tower_ingredients =
{
	{ type = "item", name = "concrete",    amount = 500 },
	{ type = "item", name = "steel-plate", amount = 400 },
}

if data.raw.item["glass"] then
	--- Replace copper with glass
	table.insert(mirror_ingredients, { type = "item", name = "glass", amount = 5 })

	table.insert(laser_tower_ingredients, { type = "item", name = "steel-plate", amount = 400 })
	table.insert(laser_tower_ingredients, { type = "item", name = "glass", amount = 100 })
else
	table.insert(mirror_ingredients, { type = "item", name = "copper-plate", amount = 5 })

	table.insert(laser_tower_ingredients, { type = "item", name = "steel-plate", amount = 500 })
end

if data.raw.item["electric-motor"] then
	-- Add motorisation
	table.insert(mirror_ingredients, { type = "item", name = "electric-motor", amount = 3 })

	table.insert(laser_tower_ingredients, { type = "item", name = "electric-motor", amount = 20 })
else
	table.insert(laser_tower_ingredients, { type = "item", name = "iron-gear-wheel", amount = 20 })
end

if data.raw.item["lithium-chloride"] then
	-- This is close enough to salt to count
	table.insert(power_tower_ingredients, { type = "item", name = "lithium-chloride", amount = 300 })
end

if mods["Krastorio2"] then
	table.insert(power_tower_ingredients, { type = "item", name = "heat-pipe", amount = 20 })
	table.insert(power_tower_ingredients, { type = "item", name = "copper-plate", amount = 300 })
else
	table.insert(power_tower_ingredients, { type = "item", name = "copper-plate", amount = 400 })
end

data:extend {
	{
		type = "recipe",
		name = data_util.mod_prefix .. "heliostat-mirror",
		energy_required = 5,
		enabled = false,
		ingredients = mirror_ingredients,
		results = { { type = "item", name = data_util.mod_prefix .. "heliostat-mirror", amount = 1 } }
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-laser-tower",
		energy_required = 8,
		enabled = false,
		ingredients = laser_tower_ingredients,
		results = { { type = "item", name = data_util.mod_prefix .. "solar-laser-tower", amount = 1 } },
		requester_paste_multiplier = 1
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-power-tower",
		energy_required = 8,
		enabled = false,
		ingredients = power_tower_ingredients,
		results = { { type = "item", name = data_util.mod_prefix .. "solar-power-tower", amount = 1 } },
		requester_paste_multiplier = 1
	},
}
