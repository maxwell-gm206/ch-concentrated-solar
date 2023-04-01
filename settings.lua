data:extend({
	{
		type = "int-setting",
		name = "ch-solar-max-production-mw",
		setting_type = "startup",
		default_value = 60,
		minimum_value = 1,
	},
	{
		type = "double-setting",
		name = "ch-k2-production-mult",
		setting_type = "startup",
		default_value = 1.9,
		minimum_value = 0,
	},
	{
		type = "bool-setting",
		name = "ch-enable-beams",
		setting_type = "runtime-global",
		default_value = true,
	},
})
