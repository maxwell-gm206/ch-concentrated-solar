control_util = require("data-util")

data:extend {
	{
		type         = "item",
		name         = control_util.mod_prefix .. "heliostat-mirror",
		subgroup     = 'energy',
		icon         = control_util.sprite "0002.png",
		icon_size    = 32 * 3,
		stack_size   = 10,
		place_result = control_util.mod_prefix .. "heliostat-mirror"
	},

	{
		type  = "turret",
		name  = control_util.mod_prefix .. "heliostat-mirror",
		flags = { "placeable-neutral", "player-creation" },

		icon      = control_util.sprite "0002.png",
		icon_size = 32 * 3,

		show_recipe_icon = false,

		--crafting_categories = { control_util.mod_prefix .. "solar-energy" },
		--crafting_speed      = 1,
		-- energy_usage     = "1W",
		-- energy_source    = {
		-- 	type = "void"
		-- },
		call_for_help_radius = 0,
		attack_parameters    = {
			type      = "beam",
			ammo_type = { category = "beam" },
			range     = 0,
			cooldown  = 1000000,
		},
		minable              = {
			mining_time = 0.5,
			result      = control_util.mod_prefix .. 'heliostat-mirror'
		},
		max_health           = 150,
		corpse               = 'small-remnants',
		collision_box        = { { -1.4, -1.4 }, { 1.4, 1.4 } },
		selection_box        = { { -1.5, -1.5 }, { 1.5, 1.5 } },

		base_picture = {
			filename = control_util.sprite(control_util.mod_prefix .. "heliostat-mirror-turret-base.png"),
			size = 32 * 3,
			direction_count = 1,
			frame_count = 1,
		},

		folded_animation = {
			direction_count = 16,
			filename = control_util.sprite(control_util.mod_prefix .. "heliostat-mirror-turret-16.png"),
			size = 32 * 4,
			frame_count = 1,
			line_length = 4
			--north = {
			--	direction_count = 1,
			--	filename = control_util.sprite "0002.png",
			--	width = 32 * 3,
			--	height = 32 * 3
			--},
			--south = {
			--	direction_count = 1,
			--	filename = control_util.sprite "0004.png",
			--	width = 32 * 3,
			--	height = 32 * 3
			--},
			--east = {
			--	direction_count = 1,
			--	filename = control_util.sprite "0006.png",
			--	width = 32 * 3,
			--	height = 32 * 3
			--
			--},
			--west = {
			--	direction_count = 1,
			--	filename = control_util.sprite "0008.png",
			--	width = 32 * 3,
			--	height = 32 * 3
			--},
		},
		--fluid_boxes      =
		--{
		--	{
		--		production_type = "input",
		--		--pipe_picture = assembler2pipepictures(),
		--		--pipe_covers = pipecoverspictures(),
		--		base_area = 10,
		--		base_level = -1,
		--		pipe_connections = { { type = "input", position = { 0, -2 } } },
		--		secondary_draw_orders = { north = -1 },
		--
		--	},
		--	{
		--		production_type = "output",
		--		--pipe_picture = assembler2pipepictures(),
		--		--pipe_covers = pipecoverspictures(),
		--		base_area = 10,
		--		base_level = 1,
		--		pipe_connections = { { type = "output", position = { 0, 2 } } },
		--		secondary_draw_orders = { north = -1 }
		--	},
		--	off_when_no_fluid_recipe = false
		--},
	},
	{
		type = "recipe",
		name = control_util.mod_prefix .. "heliostat-mirror",
		energy_required = 10,
		enabled = true,
		ingredients =
		{
			{ "steel-plate", 5 },
			{ "electronic-circuit", 15 },
			{ "copper-plate", 5 }
		},
		result = control_util.mod_prefix .. "heliostat-mirror"
	}

}
