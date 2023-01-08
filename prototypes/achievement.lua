local data_util = require "data-util"

data:extend {
	{
		type = "build-entity-achievement",
		name = data_util.mod_prefix .. "bird-murderer",
		to_build = data_util.mod_prefix .. "heliostat-mirror",
		amount = 3920,
		icon = data_util.sprite "achievement/bird-murderer.png",
		icon_size = 128, icon_mipmaps = 1,
	}
}
