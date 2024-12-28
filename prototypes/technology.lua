local data_util = require "data-util"

local prerequisites = {
	"concrete",
	"advanced-circuit",
	"solar-energy",
	"laser",
}

local effects = {
	{
		type = "unlock-recipe",
		recipe = data_util.mod_prefix .. "solar-power-tower",
	},
	{
		type = "unlock-recipe",
		recipe = data_util.mod_prefix .. "heliostat-mirror",
	},
	{
		type = "unlock-recipe",
		recipe = "heat-exchanger",
	},
	{
		type = "unlock-recipe",
		recipe = "heat-pipe",
	}
};

if data.raw["technology"]["steam-turbine"] then
	-- This tech exists in some modpacks (space exploration) that seperate nuclear and steam
	table.insert(prerequisites, "steam-turbine")
else
	table.insert(effects, {
		type = "unlock-recipe",
		recipe = "steam-turbine",
	})
end

data:extend {
	{
		type = "technology",
		icon = data_util.sprite "technology/concentrated-solar-energy.png",
		icon_size = 256,
		name = data_util.mod_prefix .. "concentrated-solar-energy",
		prerequisites = prerequisites,
		effects = effects,
		unit =
		{
			count = 400,
			ingredients =
			{
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack",   1 },
				{ "chemical-science-pack",   1 }
			},
			time = 45
		},
	},
	{
		type = "technology",
		icon = data_util.sprite "technology/weaponized-solar-energy.png",
		icon_size = 256,
		name = data_util.mod_prefix .. "weaponized-solar-energy",
		prerequisites = {
			"laser-turret",
			data_util.mod_prefix .. "concentrated-solar-energy"
		},
		effects = {
			{
				type = "unlock-recipe",
				recipe = data_util.mod_prefix .. "solar-laser-tower",
			},
		},
		unit =
		{
			count = 200,
			ingredients =
			{
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack",   1 },
				{ "military-science-pack",   1 },
				{ "chemical-science-pack",   1 }
			},
			time = 45
		},
	}
}
