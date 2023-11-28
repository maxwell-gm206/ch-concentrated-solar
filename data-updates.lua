data_util = require "data-util"

if mods["Krastorio2"] then
	data.raw.turret["chcs-heliostat-mirror"].fast_replaceable_group = "solar-panel"

	data_util.add_prerequisite("chcs-concentrated-solar-energy", "kr-advanced-solar-panel")
	-- Power buff comes at cost of more expensive research
end


if mods["space-exploration"] then
	-- Place solar-y objects with other SE solar objects
	data.raw.recipe["chcs-solar-power-tower"].subgroup = "solar"
	data.raw.recipe["chcs-solar-power-tower"].order = "d[solar-panel]-b[solar-power-tower]-a"

	data.raw.item["chcs-solar-power-tower"].subgroup = "solar"
	data.raw.item["chcs-solar-power-tower"].order = "d[solar-panel]-b[solar-power-tower]-a"

	data.raw.recipe["chcs-heliostat-mirror"].subgroup = "solar"
	data.raw.recipe["chcs-heliostat-mirror"].order = "d[solar-panel]-b[heliostat-mirror]-a"

	data.raw.item["chcs-heliostat-mirror"].subgroup = "solar"
	data.raw.item["chcs-heliostat-mirror"].order = "d[solar-panel]-b[heliostat-mirror]-a"

	data_util.add_research_ingredient("chcs-concentrated-solar-energy", "space-science-pack")
	data_util.add_research_ingredient("chcs-weaponized-solar-energy", "space-science-pack")

	data_util.add_prerequisite("chcs-concentrated-solar-energy", "space-science-pack")

	if mods["Krastorio2"] then
		data_util.add_prerequisite("chcs-concentrated-solar-energy", "kr-optimization-tech-card")
		data_util.add_prerequisite("chcs-weaponized-solar-energy", "kr-optimization-tech-card")
	end
else
	if mods["Krastorio2"] then
		-- only add production to non-space
		data_util.add_research_ingredient("chcs-concentrated-solar-energy", "production-science-pack")
		data_util.add_research_ingredient("chcs-weaponized-solar-energy", "production-science-pack")
	end
end
