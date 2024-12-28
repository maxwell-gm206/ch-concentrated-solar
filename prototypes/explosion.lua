local data_util            = require("data-util")
local sounds               = require("__base__.prototypes.entity.sounds")
local explosion_animations = require("__base__.prototypes.entity.explosion-animations")

local function create_debris(particle, amount, height, area, speed)
	return {
		type = "create-particle",
		repeat_count = amount,
		particle_name = particle,
		offset_deviation = { { -(area), -(area) }, { (area), (area) } },
		initial_height = height,
		initial_height_deviation = height,
		initial_vertical_speed = speed,
		initial_vertical_speed_deviation = speed,
		speed_from_center = speed * 0.4,
		speed_from_center_deviation = speed * 0.4 * 1.2
	}
end

local target_effects = {
	create_debris("boiler-metal-particle-big", 12, 0.20, 0.70, 0.090),
	create_debris("boiler-metal-particle-big", 6, 0.00, 0.35, 0.045), -- fills middle
	create_debris("lab-long-metal-particle-medium", 12, 0.25, 0.70, 0.090),
	create_debris("boiler-metal-particle-medium", 16, 0.20, 0.70, 0.100),
	create_debris("lab-mechanical-component-particle-medium", 16, 0.25, 0.70, 0.100),
	create_debris("solar-panel-glass-particle-small", 120, 0.30, 0.70, 0.100)
}

local mirror_explosion = {
	type = "explosion",
	name = "heliostat-mirror-explosion",
	icon = data_util.sprite "icons/heliostat-mirror-icon.png",
	flags = { "not-on-map" },
	hidden = true,
	subgroup = "energy-explosions",
	order = "a-c-a",
	height = 0.0, -- check
	animations = explosion_animations.dust_explosion(),
	smoke = "smoke-fast",
	smoke_count = 2,
	smoke_slow_down_factor = 1,
	sound = sounds.medium_explosion,
	created_effect = {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = target_effects
		}
	}
}

data:extend({ mirror_explosion })
