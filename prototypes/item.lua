local data_util = require "data-util"


data:extend {
	{
		type = "item",
		name = data_util.mod_prefix .. "solar-laser-tower",
		subgroup = 'defensive-structure',
		icon = data_util.sprite "solar-laser-tower-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		stack_size = 10,
		place_result = data_util.mod_prefix .. "solar-laser-tower",
		order = "b[turret]-c[flamethrower-turret]-b[solar-laser]",
	},
	{
		type = "item",
		name = data_util.mod_prefix .. "solar-power-tower",
		subgroup = 'energy',
		icon = data_util.sprite "solar-power-tower-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		stack_size = 10,
		place_result = data_util.mod_prefix .. "solar-power-tower",
		order = "f[solar-energy]-b[power-tower]",
	},
	{
		type = "item",
		name = data_util.mod_prefix .. "heliostat-mirror",
		subgroup = 'energy',
		icon = data_util.sprite "heliostat-mirror-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		stack_size = 50,
		place_result = data_util.mod_prefix .. "heliostat-mirror",
		order = "f[solar-energy]-a[mirror]",
	},

}
