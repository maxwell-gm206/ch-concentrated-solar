local data_util = require("data-util")

local solar_beam_blend_mode = "additive"

local mirrored_solar_beam = {
	filename = data_util.sprite "mirrored-solar-beam.png",
	flags = beam_non_light_flags,

	width = 64,
	height = 64,
	frame_count = 1,
	scale = 0.5,
	blend_mode = solar_beam_blend_mode
}
local solar_beam = {
	filename = data_util.sprite "solar-beam.png",
	flags = beam_non_light_flags,
	width = 64,
	height = 96,
	frame_count = 1,
	scale = 1,
	blend_mode = solar_beam_blend_mode
}


data:extend {
	{ type = "fuel-category", name = data_util.mod_prefix .. "solar-energy" },
	{
		type = "fluid",
		icon = "__base__/graphics/icons/tooltips/tooltip-category-chemical.png",
		icon_size = 40, icon_mipmaps = 2,
		name = data_util.mod_prefix .. "solar-fluid",
		hidden = true,
		auto_barrel = false,
		base_color = { 0, 0, 0 },
		flow_color = { 0, 0, 0 },
		default_temperature = 40,
		fuel_value = "1MJ"
	},
	{

		type = "beam",
		name = data_util.mod_prefix .. "mirrored-solar-beam",
		flags = { "not-on-map" },
		width = 0.5,
		damage_interval = 20,
		random_target_offset = true,

		head = mirrored_solar_beam,
		tail = mirrored_solar_beam,
		body =
		{
			mirrored_solar_beam
		},
	},
	{

		type = "beam",
		name = data_util.mod_prefix .. "solar-beam",
		flags = { "not-on-map" },
		width = 1,
		damage_interval = 20,
		random_target_offset = true,

		head = solar_beam,
		tail = solar_beam,
		body =
		{
			solar_beam
		},
	}
}
