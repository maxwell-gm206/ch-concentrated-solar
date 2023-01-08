data_util = require "data-util"

data:extend {

	{
		type = "technology",
		icon = data_util.sprite "technology/concentrated-solar-energy.png",
		icon_size = 256, icon_mipmaps = 4,
		name = data_util.mod_prefix .. "concentrated-solar-energy",
		prerequisites = {
			"nuclear-power",
			"solar-energy"
		},
		effects = {
			{
				type = "unlock-recipe",
				recipe = data_util.mod_prefix .. "solar-power-tower",
			},
			{
				type = "unlock-recipe",
				recipe = data_util.mod_prefix .. "heliostat-mirror",
			},
		},
		unit =
		{
			count = 300,
			ingredients =
			{
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 }
			},
			time = 30
		},
	},
	{
		type = "technology",
		icon = data_util.sprite "technology/weaponized-solar-energy.png",
		icon_size = 256, icon_mipmaps = 4,
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
				{ "logistic-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "chemical-science-pack", 1 }
			},
			time = 30
		},
	}
}
