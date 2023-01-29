data_util = require "data-util"

if mods["Krastorio2"] then
	data.raw["turret"]["chcs-heliostat-mirror"].fast_replaceable_group = "solar-panel"

	table.insert(data.raw["technology"]["chcs-concentrated-solar-energy"].prerequisites, "kr-advanced-solar-panel")
	-- Power buff comes at cost of more expensive research


end


if mods["space-exploration"] then


	data.raw["turret"]["chcs-heliostat-mirror"].se_allow_in_space = true
	data.raw["reactor"]["chcs-solar-power-tower"].se_allow_in_space = true

	-- Place solar-y objects with other SE solar objects
	data.raw.recipe["chcs-solar-power-tower"].subgroup = "solar"
	data.raw.recipe["chcs-solar-power-tower"].order = "d[solar-panel]-b[solar-power-tower]-a"

	data.raw.item["chcs-solar-power-tower"].subgroup = "solar"
	data.raw.item["chcs-solar-power-tower"].order = "d[solar-panel]-b[solar-power-tower]-a"

	data.raw.recipe["chcs-heliostat-mirror"].subgroup = "solar"
	data.raw.recipe["chcs-heliostat-mirror"].order = "d[solar-panel]-b[heliostat-mirror]-a"

	data.raw.item["chcs-heliostat-mirror"].subgroup = "solar"
	data.raw.item["chcs-heliostat-mirror"].order = "d[solar-panel]-b[heliostat-mirror]-a"

	table.insert(data.raw["technology"]["chcs-concentrated-solar-energy"].unit.ingredients,
		{ "space-science-pack", 1 })

	table.insert(data.raw["technology"]["chcs-weaponized-solar-energy"].unit.ingredients, { "space-science-pack", 1 })

	table.insert(data.raw["technology"]["chcs-concentrated-solar-energy"].prerequisites, "space-science-pack")

	if mods["Krastorio2"] then

		table.insert(data.raw["technology"]["chcs-concentrated-solar-energy"].prerequisites, "kr-optimization-tech-card")
		table.insert(data.raw["technology"]["chcs-weaponized-solar-energy"].prerequisites, "kr-optimization-tech-card")

	end
else if mods["Krastorio2"] then
		-- only add production to non-space
		table.insert(data.raw["technology"]["chcs-concentrated-solar-energy"].unit.ingredients,
			{ "production-science-pack", 1 })

		table.insert(data.raw["technology"]["chcs-weaponized-solar-energy"].unit.ingredients, { "production-science-pack", 1 })

	end

end
