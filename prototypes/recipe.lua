local data_util = require "data-util"
data:extend {
	{
		type = "recipe",
		name = data_util.mod_prefix .. "heliostat-mirror",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{ "steel-plate", 5 },
			{ "electronic-circuit", 5 },
			{ "copper-plate", 5 }
		},
		result = data_util.mod_prefix .. "heliostat-mirror"
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-laser-tower",
		energy_required = 8,
		enabled = false,
		ingredients =
		{
			{ "concrete", 500 },
			{ "steel-plate", 500 },
			{ "iron-gear-wheel", 20 },
		},
		result = data_util.mod_prefix .. "solar-laser-tower",
		requester_paste_multiplier = 1
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-power-tower",
		energy_required = 8,
		enabled = false,
		ingredients =
		{
			{ "concrete", 500 },
			{ "steel-plate", 500 },
			{ "copper-plate", 500 }
		},
		result = data_util.mod_prefix .. "solar-power-tower",
		requester_paste_multiplier = 1
	},
}
