data_util = require "data-util"


data:extend { {
	type = "item",
	name = data_util.mod_prefix .. "solar-laser-tower",
	subgroup = 'energy',
	icon = data_util.sprite "solar-laser-tower-icon.png",
	icon_size = 64, icon_mipmaps = 4,
	stack_size = 10,
	place_result = data_util.mod_prefix .. "solar-laser-tower"
},

	{
		type = "item",
		name = data_util.mod_prefix .. "solar-power-tower",
		subgroup = 'energy',
		icon = data_util.sprite "solar-power-tower-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		stack_size = 10,
		place_result = data_util.mod_prefix .. "solar-power-tower"
	},
	{
		type = "item",
		name = data_util.mod_prefix .. "heliostat-mirror",
		subgroup = 'energy',
		icon = data_util.sprite "heliostat-mirror-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		stack_size = 10,
		place_result = data_util.mod_prefix .. "heliostat-mirror"
	},

}
