data_util = require("data-util")

local laser_beam_blend_mode = "additive"
data:extend {
	{ type = "recipe-category", name = data_util.mod_prefix .. "solar-energy" },
	{ type = "fuel-category", name = data_util.mod_prefix .. "solar-energy" },
	{
		type = "item",
		icon = "__base__/graphics/icons/coin.png",
		icon_size = 64,
		name = data_util.mod_prefix .. "solar-1kj",
		stack_size = 50,
		fuel_category = data_util.mod_prefix .. "solar-energy",
		only_in_cursor = true,
		fuel_value = "1KJ"
	},
	{
		type            = "recipe",
		name            = data_util.mod_prefix .. "produce-solar-1kj",
		ingredients     = {},
		energy_required = 30,
		result          = data_util.mod_prefix .. "solar-1kj",
		category        = data_util.mod_prefix .. "solar-energy",
		hide_from_stats = true
	},
	{
		type            = "recipe",
		name            = data_util.mod_prefix .. "produce-solar-fluid",
		ingredients     = {},
		energy_required = 3,
		--result          = data_util.mod_prefix .. "solar-1kj",
		results         = { { type = "fluid", name = data_util.mod_prefix .. "solar-fluid", amount = 100 } },
		category        = data_util.mod_prefix .. "solar-energy",
		hide_from_stats = true
	},
	{
		type = "fluid",
		icon = "__base__/graphics/icons/coin.png",
		icon_size = 64,
		name = data_util.mod_prefix .. "solar-fluid",
		hidden = true,
		auto_barrel = false,
		base_color = { 0, 0, 0 },
		flow_color = { 0, 0, 0 },
		default_temperature = 40,
		fuel_value = "1MJ"
	}, {

		type = "beam",
		name = data_util.mod_prefix .. "mirred-solar-beam",
		flags = { "not-on-map" },
		width = 0.5,
		damage_interval = 20,
		random_target_offset = true,

		head =
		{
			filename = data_util.sprite "solar-beam.png",
			flags = beam_non_light_flags,
			--line_length = 8,
			width = 64,
			height = 64,
			frame_count = 8,
			scale = 0.5,
			animation_speed = 0.5,
			blend_mode = laser_beam_blend_mode
		},
		tail =
		{
			filename = data_util.sprite "solar-beam.png",
			flags = beam_non_light_flags,
			width = 64,
			height = 64,
			frame_count = 8,
			--shift = util.by_pixel(11.5, 1),
			scale = 0.5,
			animation_speed = 0.5,
			blend_mode = laser_beam_blend_mode
		},
		body =
		{
			{
				filename = data_util.sprite "solar-beam.png",
				flags = beam_non_light_flags,
				line_length = 8,
				width = 64,
				height = 64,
				frame_count = 8,
				scale = 1,
				animation_speed = 0.5,
				blend_mode = laser_beam_blend_mode
			}
		},
		--
		--light_animations =
		--{
		--	head =
		--	{
		--		filename = "__base__/graphics/entity/laser-turret/hr-laser-body-light.png",
		--		line_length = 8,
		--		width = 64,
		--		height = 12,
		--		frame_count = 8,
		--		scale = 0.5,
		--		animation_speed = 0.5
		--	},
		--	tail =
		--	{
		--		filename = "__base__/graphics/entity/laser-turret/hr-laser-end-light.png",
		--		width = 110,
		--		height = 62,
		--		frame_count = 8,
		--		shift = util.by_pixel(11.5, 1),
		--		scale = 0.5,
		--		animation_speed = 0.5
		--	},
		--	body =
		--	{
		--		{
		--			filename = "__base__/graphics/entity/laser-turret/hr-laser-body-light.png",
		--			line_length = 8,
		--			width = 64,
		--			height = 12,
		--			frame_count = 8,
		--			scale = 0.5,
		--			animation_speed = 0.5
		--		}
		--	}
		--},

		--ground_light_animations =
		--{
		--	head =
		--	{
		--		filename = "__base__/graphics/entity/laser-turret/laser-ground-light-head.png",
		--		line_length = 1,
		--		width = 256,
		--		height = 256,
		--		repeat_count = 8,
		--		scale = 0.5,
		--		shift = util.by_pixel(-32, 0),
		--		animation_speed = 0.5,
		--		tint = { 0.5, 0.05, 0.05 }
		--	},
		--	tail =
		--	{
		--		filename = "__base__/graphics/entity/laser-turret/laser-ground-light-tail.png",
		--		line_length = 1,
		--		width = 256,
		--		height = 256,
		--		repeat_count = 8,
		--		scale = 0.5,
		--		shift = util.by_pixel(32, 0),
		--		animation_speed = 0.5,
		--		tint = { 0.5, 0.05, 0.05 }
		--	},
		--	body =
		--	{
		--		filename = "__base__/graphics/entity/laser-turret/laser-ground-light-body.png",
		--		line_length = 1,
		--		width = 64,
		--		height = 256,
		--		repeat_count = 8,
		--		scale = 0.5,
		--		animation_speed = 0.5,
		--		tint = { 0.5, 0.05, 0.05 }
		--	}
		--},
		--working_sound =
		--{
		--	sound =
		--	{
		--		filename = "__base__/sound/fight/laser-beam.ogg",
		--		volume = 0.75
		--	},
		--	max_sounds_per_type = 1
		--}
	}
}
