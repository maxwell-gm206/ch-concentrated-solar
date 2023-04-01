local data_util = require("data-util")

local hit_effects = require("__base__.prototypes.entity.hit-effects")

require("util")

local tower_shift         = { 0, -(17 / 2 - 2.5) }
local tower_size          = { x = 5, y = 17 }

local tower_collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } }
local tower_selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } }
local tower_drawing_box   = { { -2.5, -14.5 }, { 2.5, 2.5 } }

data:extend {
	{
		type = "reactor",
		name = data_util.mod_prefix .. "solar-power-tower",
		icon = data_util.sprite "solar-power-tower-icon.png",
		icon_size = 64,
		icon_mipmaps = 4,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 1, result = data_util.mod_prefix .. "solar-power-tower" },
		max_health = 500,
		corpse = "medium-remnants",
		dying_explosion = "nuclear-reactor-explosion",
		radius_visualisation_specification = {
			sprite = { filename = data_util.sprite "solar-power-tower-radius-visualisation.png", size = 12 },
			distance = data_util.tower_capture_radius
		},
		--- ENERGY


		consumption            = data_util.solar_max_production_mw .. "MW",
		scale_energy_usage     = true,
		neighbour_bonus        = 0,
		energy_source          =
		{
			type = "fluid",
			fluid_box = {
				base_area           = data_util.solar_max_temp,
				height              = 0.01,
				pipe_connections    = {},
				production_type     = "input",
				minimum_temperature = 100.0,
				maximum_temperature = data_util.solar_max_temp,
				filter              = data_util.mod_prefix .. "solar-fluid"
			},
			--destroy_non_fuel_fluid = true,
			burns_fluid = false,
			scale_fluid_usage = true,
			fluid_usage_per_tick = data_util.solar_max_consumption / 60,
			maximum_temperature = data_util.solar_max_temp,
			--fuel_category = control_util.mod_prefix .. "solar-energy",
			--fuel_inventory_size = 1

			-- Lights are banned
			light_flicker = {
				minimum_intensity = 0,
				maximum_intensity = 0,
				derivation_change_frequency = 0,
				derivation_change_deviation = 0,
				minimum_light_size = 0,
				light_intensity_to_size_coefficient = 0,
				color = { 0, 0, 0 }
			}
		},
		collision_box          = tower_collision_box,
		selection_box          = tower_selection_box,
		drawing_box            = tower_drawing_box,
		damaged_trigger_effect = hit_effects.entity(),
		--- GRAPHICS

		picture                =
		{
			layers =
			{
				data_util.auto_hr {
					filename = "solar-power-tower",
					width = 32 * tower_size.x,
					height = 32 * tower_size.y,
					shift = tower_shift,
				},
				{
					filename = data_util.sprite "solar-power-tower-shadow.png",
					width = 736,
					height = 160,
					shift = { 9.3, 0 },
					draw_as_shadow = true,
					--hr_version =
					--{
					--	filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-shadow.png",
					--	width = 525,
					--	height = 323,
					--	scale = 0.5,
					--	shift = { 1.625, 0 },
					--	draw_as_shadow = true
					--}
				}
			}
		},
		working_light_picture  = data_util.auto_hr {
			filename = "solar-power-tower-working",
			blend_mode = "additive",
			draw_as_glow = true,
			width = 32 * 4,
			height = 32 * 4,
			shift = { 0, -12.35 },
		},
		-- add a light to smooth out the effects of all the incoming beams
		light                  = { intensity = 0.6, size = 9.9, shift = { 0.0, -12.35 } },
		-- use_fuel_glow_color = false, -- should use glow color from fuel item prototype as light color and tint for working_light_picture
		-- default_fuel_glow_color = { 0, 1, 0, 1 } -- color used as working_light_picture tint for fuels that don't have glow color defined

		heat_buffer            =
		{
			max_temperature = data_util.solar_max_temp,
			specific_heat = "500KJ",
			max_transfer = "10GW",
			minimum_glow_temperature = 250,
			connections =
			{
				{
					position = { -2, -2 },
					direction = defines.direction.north
				},
				{
					position = { 0, -2 },
					direction = defines.direction.north
				},
				{
					position = { 2, -2 },
					direction = defines.direction.north
				},
				{
					position = { 2, -2 },
					direction = defines.direction.east
				},
				{
					position = { 2, 0 },
					direction = defines.direction.east
				},
				{
					position = { 2, 2 },
					direction = defines.direction.east
				},
				{
					position = { 2, 2 },
					direction = defines.direction.south
				},
				{
					position = { 0, 2 },
					direction = defines.direction.south
				},
				{
					position = { -2, 2 },
					direction = defines.direction.south
				},
				{
					position = { -2, 2 },
					direction = defines.direction.west
				},
				{
					position = { -2, 0 },
					direction = defines.direction.west
				},
				{
					position = { -2, -2 },
					direction = defines.direction.west
				}
			},
			heat_picture = apply_heat_pipe_glow(data_util.auto_hr
				{
					filename = "solar-power-tower-heated",
					width = 32 * tower_size.x,
					height = 32 * tower_size.y,
					shift = tower_shift,
				}),
		},
		--- HEAT PIPE CONNECTION TEXTURES
		lower_layer_picture    =
		{
			filename = "__base__/graphics/entity/nuclear-reactor/reactor-pipes.png",
			width = 156,
			height = 156,
			shift = util.by_pixel(-2, -4),
			hr_version =
			{
				filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-pipes.png",
				width = 320,
				height = 316,
				scale = 0.5,
				shift = util.by_pixel(-1, -5)
			}
		},
		heat_lower_layer_picture = apply_heat_pipe_glow
			{
				filename = "__base__/graphics/entity/nuclear-reactor/reactor-pipes-heated.png",
				width = 156,
				height = 156,
				shift = util.by_pixel(-3, -4),
				hr_version =
				{
					filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-pipes-heated.png",
					width = 320,
					height = 316,
					scale = 0.5,
					shift = util.by_pixel(-0.5, -4.5)
				}
			},
		connection_patches_connected =
		{
			sheet =
			{
				filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches.png",
				width = 32,
				height = 32,
				variation_count = 12,
				hr_version =
				{
					filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-connect-patches.png",
					width = 64,
					height = 64,
					variation_count = 12,
					scale = 0.5
				}
			}
		},
		connection_patches_disconnected =
		{
			sheet =
			{
				filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches.png",
				width = 32,
				height = 32,
				variation_count = 12,
				y = 32,
				hr_version =
				{
					filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-connect-patches.png",
					width = 64,
					height = 64,
					variation_count = 12,
					y = 64,
					scale = 0.5
				}
			}
		},
		heat_connection_patches_connected =
		{
			sheet = apply_heat_pipe_glow
				{
					filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches-heated.png",
					width = 32,
					height = 32,
					variation_count = 12,
					hr_version =
					{
						filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-connect-patches-heated.png",
						width = 64,
						height = 64,
						variation_count = 12,
						scale = 0.5
					}
				}
		},
		heat_connection_patches_disconnected =
		{
			sheet = apply_heat_pipe_glow
				{
					filename = "__base__/graphics/entity/nuclear-reactor/reactor-connect-patches-heated.png",
					width = 32,
					height = 32,
					variation_count = 12,
					y = 32,
					hr_version =
					{
						filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-connect-patches-heated.png",
						width = 64,
						height = 64,
						variation_count = 12,
						y = 64,
						scale = 0.5
					}
				}
		},
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		--	vehicle_impact_sound = sounds.generic_impact,
		--	open_sound = sounds.machine_open,
		--	close_sound = sounds.machine_close,
		working_sound =
		{
			sound =
			{
				{
					filename = "__base__/sound/nuclear-reactor-1.ogg",
					volume = 0.55
				},
				{
					filename = "__base__/sound/nuclear-reactor-2.ogg",
					volume = 0.55
				}
			},
			--idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.3 },
			max_sounds_per_type = 3,
			fade_in_ticks = 4,
			fade_out_ticks = 20
		}
	},
}
