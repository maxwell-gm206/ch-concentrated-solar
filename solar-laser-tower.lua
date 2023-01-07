local data_util = require("data-util")
local sounds = require("__base__.prototypes.entity.sounds")
local util = require "util"
local hit_effects = require("__base__.prototypes.entity.hit-effects")

local function solar_laser_turret_extension(inputs)
	return {
		filename = data_util.sprite "solar-laser-tower-raise.png",
		priority = "medium",
		size = 32 * 3,
		frame_count = inputs.frame_count or 16,
		line_length = inputs.line_length or 0,
		run_mode = inputs.run_mode or "forward",
		axially_symmetrical = false,
		direction_count = 4,
		scale = 1.5,
		shift = { 0, -13 },
		--hr_version =
		--{
		--	filename = "__base__/graphics/entity/laser-turret/hr-laser-turret-raising.png",
		--	priority = "medium",
		--	width = 130,
		--	height = 126,
		--	frame_count = inputs.frame_count or 15,
		--	line_length = inputs.line_length or 0,
		--	run_mode = inputs.run_mode or "forward",
		--	axially_symmetrical = false,
		--	direction_count = 4,
		--	shift = util.by_pixel(0, -32.5),
		--	scale = 0.5
		--}
	}
end

local function solar_laser_turret_shooting()
	return {
		filename = data_util.sprite "solar-laser-tower-fire.png",
		line_length = 8,
		width = 32 * 3,
		height = 32 * 3,
		frame_count = 1,
		direction_count = 64,
		scale = 1.5,
		shift = { 0, -13 },
		--hr_version =
		--{
		--	filename = "__base__/graphics/entity/laser-turret/hr-laser-turret-shooting.png",
		--	line_length = 8,
		--	width = 126,
		--	height = 120,
		--	frame_count = 1,
		--	direction_count = 64,
		--	shift = util.by_pixel(0, -35),
		--	scale = 0.5
		--}
	}
end

data:extend {
	{
		type = "item",
		name = data_util.mod_prefix .. "solar-laser-tower",
		subgroup = 'energy',
		icon = data_util.sprite "solar-laser-tower-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		stack_size = 10,
		place_result = data_util.mod_prefix .. "solar-laser-tower"
	},
	{
		type = "recipe",
		name = data_util.mod_prefix .. "solar-laser-tower",
		energy_required = 8,
		enabled = true,
		ingredients =
		{
			{ "concrete", 500 },
			{ "steel-plate", 500 },
			{ "advanced-circuit", 500 },
			{ "copper-plate", 500 }
		},
		result = data_util.mod_prefix .. "solar-laser-tower",
		requester_paste_multiplier = 1
	},

	{
		type = "electric-turret",
		name = data_util.mod_prefix .. "solar-laser-tower",
		icon = data_util.sprite "solar-laser-tower-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		flags = { "placeable-player", "placeable-enemy", "player-creation" },
		minable = { mining_time = 0.5, result = data_util.mod_prefix .. "solar-laser-tower" },
		max_health = 1000,
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		drawing_box = { { -2.5, -14.5 }, { 2.5, 2.5 } },
		damaged_trigger_effect = hit_effects.entity(),
		rotation_speed = 0.01,
		preparing_speed = 0.05,
		preparing_sound = sounds.laser_turret_activate,
		folding_sound = sounds.laser_turret_deactivate,
		corpse = "medium-remnants",
		dying_explosion = "laser-turret-explosion",
		folding_speed = 0.05,
		energy_source =
		{
			type = "electric",
			buffer_capacity = "801kJ",
			input_flow_limit = "9600kW",
			drain = "24kW",
			usage_priority = "primary-input"
		},
		folded_animation =
		{
			layers =
			{
				solar_laser_turret_extension { frame_count = 1, line_length = 1 },
				--laser_turret_extension_shadow { frame_count = 1, line_length = 1 },
				--laser_turret_extension_mask { frame_count = 1, line_length = 1 }
			}
		},
		preparing_animation =
		{
			layers =
			{
				solar_laser_turret_extension {},
				--laser_turret_extension_shadow {},
				--laser_turret_extension_mask {}
			}
		},
		prepared_animation =
		{
			layers =
			{
				solar_laser_turret_shooting(),
				--laser_turret_shooting_shadow(),
				--laser_turret_shooting_mask()
			}
		},
		--attacking_speed = 0.1,
		--energy_glow_animation = laser_turret_shooting_glow(),
		glow_light_intensity = 0.5, -- defaults to 0
		folding_animation =
		{
			layers =
			{
				solar_laser_turret_extension { run_mode = "backward" },
				--laser_turret_extension_shadow { run_mode = "backward" },
				--laser_turret_extension_mask { run_mode = "backward" }
			}
		},
		base_picture_render_layer = "higher-object-under",
		gun_animation_render_layer = "higher-object-above",
		base_picture =
		{
			layers =
			{
				{
					filename = data_util.sprite "solar-laser-tower.png",
					width = 32 * 5,
					height = 32 * 17,
					shift = { 0, -(17 / 2 - 2.5) },
					priority = "high",
					direction_count = 1,
					frame_count = 1,
					--hr_version =
					--{
					--	filename = "__base__/graphics/entity/laser-turret/hr-laser-turret-base.png",
					--	priority = "high",
					--	width = 138,
					--	height = 104,
					--	direction_count = 1,
					--	frame_count = 1,
					--	shift = util.by_pixel(-0.5, 2),
					--	scale = 0.5
					--}
				},
				{
					filename = data_util.sprite "solar-power-tower-shadow.png",
					width = 32 * 15,
					height = 32 * 5,
					shift = { 5, 0 },
					draw_as_shadow = true,
					priority = "high",
					direction_count = 1,
					frame_count = 1,
					--hr_version =
					--{
					--	filename = "__base__/graphics/entity/laser-turret/hr-laser-turret-base-shadow.png",
					--	line_length = 1,
					--	width = 132,
					--	height = 82,
					--	draw_as_shadow = true,
					--	direction_count = 1,
					--	frame_count = 1,
					--	shift = util.by_pixel(6, 3),
					--	scale = 0.5
					--}
				},
				{
					filename = data_util.sprite "solar-laser-tower-mask.png",
					width = 32 * 5,
					height = 32 * 17,
					shift = { 0, -(17 / 2 - 2.5) },
					flags = { "mask" },
					priority = "high",
					axially_symmetrical = false,
					apply_runtime_tint = true,
					direction_count = 1,
					frame_count = 1,
					--hr_version =
					--{
					--	filename = "__base__/graphics/entity/laser-turret/hr-laser-turret-base-shadow.png",
					--flags = { "mask" },
					--	line_length = 1,
					--	width = 132,
					--	height = 82,
					--	draw_as_shadow = true,
					--	direction_count = 1,
					--	frame_count = 1,
					--	shift = util.by_pixel(6, 3),
					--	scale = 0.5
					--}
				}
			}
		},
		vehicle_impact_sound = sounds.generic_impact,
		is_military_target = true,
		attack_parameters =
		{
			type = "beam",
			warmup = 10,
			cooldown = 40,
			range = 50,
			min_attack_distance = 10,
			source_direction_count = 64,
			source_offset = { 0, -3.423489 / 4 },
			damage_modifier = 2,
			ammo_type =
			{
				category = "laser",
				energy_consumption = "800kJ",
				action =
				{
					type = "area",
					radius = 3,
					action_delivery =
					{
						type = "beam",
						beam = data_util.mod_prefix .. "solar-beam",
						max_length = 50,
						duration = 40,
						source_offset = { 0, -13 },
						target_effects = {
							type = "create-entity",
							entity_name = "fire-flame",
							check_buildability = true
						}
					}
				}
			}
		},

		call_for_help_radius = 40,
		--water_reflection =
		--{
		--	pictures =
		--	{
		--		filename = "__base__/graphics/entity/laser-turret/laser-turret-reflection.png",
		--		priority = "extra-high",
		--		width = 20,
		--		height = 32,
		--		shift = util.by_pixel(0, 40),
		--		variation_count = 1,
		--		scale = 5
		--	},
		--	rotate = false,
		--	orientation_to_variation = false
		--}
	},
}
