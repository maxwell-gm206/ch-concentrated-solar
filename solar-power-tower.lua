local data_util = require("data-util")

require("util")

data:extend {
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
		type = "recipe",
		name = data_util.mod_prefix .. "solar-power-tower",
		energy_required = 8,
		enabled = true,
		ingredients =
		{
			{ "concrete", 500 },
			{ "steel-plate", 500 },
			{ "advanced-circuit", 500 },
			{ "copper-plate", 500 }
		},
		result = data_util.mod_prefix .. "solar-power-tower",
		requester_paste_multiplier = 1
	},
	{
		type = "reactor",
		name = data_util.mod_prefix .. "solar-power-tower",
		icon = data_util.sprite "solar-power-tower-icon.png",
		icon_size = 64, icon_mipmaps = 4,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = data_util.mod_prefix .. "solar-power-tower" },
		max_health = 500,
		corpse = "medium-remnants",
		dying_explosion = "nuclear-reactor-explosion",
		consumption = "40MW",
		neighbour_bonus = 0,
		--energy_source =
		--{
		--	type = "burner",
		--	fuel_category = control_util.mod_prefix .. "solar-energy",
		--	fuel_inventory_size = 1
		--},

		energy_source =
		{

			type = "fluid",
			fluid_box = {
				base_area        = 10,
				height           = 2,
				pipe_connections = {},
				production_type  = "input",
				filter           = data_util.mod_prefix .. "solar-fluid"
			},
			destroy_non_fuel_fluid = true,
			burns_fluid = true,
			--scale_fluid_usage = true,
			--fuel_category = control_util.mod_prefix .. "solar-energy",
			--fuel_inventory_size = 1
		},
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		drawing_box   = { { -2.5, -14.5 }, { 2.5, 2.5 } },

		--damaged_trigger_effect = hit_effects.entity(),
		lower_layer_picture      =
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

		picture =
		{
			layers =
			{
				{
					filename = data_util.sprite "solar-power-tower.png",
					width = 32 * 5,
					height = 32 * 17,
					shift = { 0, -(17 / 2 - 2.5) },
					--hr_version =
					--{
					--	filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor.png",
					--	width = 302,
					--	height = 318,
					--	scale = 0.5,
					--	shift = util.by_pixel(-5, -7)
					--}
				},
				{
					filename = data_util.sprite "solar-power-tower-shadow.png",
					width = 32 * 15,
					height = 32 * 5,
					shift = { 5, 0 },
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

		working_light_picture =
		{
			filename = data_util.sprite "solar-power-tower-working.png",
			blend_mode = "additive",
			draw_as_glow = true,
			width = 32 * 4,
			height = 32 * 4,
			shift = { 0, -14 },
			--hr_version =
			--{
			--	filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-lights-color.png",
			--	blend_mode = "additive",
			--	draw_as_glow = true,
			--	width = 320,
			--	height = 320,
			--	scale = 0.5,
			--	shift = { -0.03125, -0.1875 },
			--}
		},

		--light = {intensity = 0.6, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.0, g = 1.0, b = 0.0}},
		-- use_fuel_glow_color = false, -- should use glow color from fuel item prototype as light color and tint for working_light_picture
		-- default_fuel_glow_color = { 0, 1, 0, 1 } -- color used as working_light_picture tint for fuels that don't have glow color defined

		heat_buffer =
		{
			max_temperature = 700,
			specific_heat = "50MJ",
			max_transfer = "10GW",
			minimum_glow_temperature = 350,
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

			heat_picture = apply_heat_pipe_glow
			{
				filename = data_util.sprite "solar-power-tower-heated.png",
				width = 32 * 5,
				height = 32 * 17,
				shift = { 0, -(17 / 2 - 2.5) },
				hr_version =
				{
					filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-heated.png",
					width = 216,
					height = 256,
					scale = 0.5,
					shift = util.by_pixel(3, -6.5)
				}
			},
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
