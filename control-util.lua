local control_util = require "shared-util"

---@type Global
global = global

---@type LuaGameScript
game = game

---@type LuaRendering
rendering = rendering

script = script



control_util.inv_lerp = function(a, b, v)
	return math.max(math.min((v - a) / (b - a), 1), 0)
end

control_util.calc_sun = function(surface)
	if surface.daytime > surface.evening then
		--game.print("morning!")
		return { sun = control_util.inv_lerp(surface.morning, surface.dawn, surface.daytime), moring = true }
	else
		--game.print("evening!")
		return { sun = control_util.inv_lerp(surface.evening, surface.dusk, surface.daytime), morning = false }
	end
end

--- Get the "Stage" of the sun - an integer number reprosenting how far raised it is
control_util.getSunStage = function(time_info)
	return math.floor(time_info.sun * control_util.sun_stages) - 1
end

---@param mirror LuaEntity
--- Distance from `mirror` to it's tower
control_util.distance_to_tower = function(mirror)
	return util.distance(mirror.position, global.mirror_tower[mirror.unit_number].tower.position)
end

---@param mirror LuaEntity
---@param tower LuaEntity
--- run `linkMirrorToTower` if the new tower has a distance lower than the original
control_util.linkMirrorToTowerIfCloser = function(mirror, tower)

	local curDist = control_util.distance_to_tower(mirror)
	local newDist = util.distance(mirror.position, tower.position)

	if newDist < curDist then
		control_util.linkMirrorToTower(tower, mirror)
	end
end


---@param mirror LuaEntity
---@param tower LuaEntity
---@param ttl number
--- Create a beam from a `mirror` to a `tower`, lasting for `ttl`
control_util.generateBeam = function(mirror, tower, ttl)
	global.mirror_tower[mirror.unit_number].beam = mirror.surface.create_entity {
		position = mirror.position,
		name = control_util.mod_prefix .. "mirred-solar-beam",
		raise_built = false,
		time_to_live = ttl,
		target_position = { tower.position.x, tower.position.y - 13 },
		source_position = mirror.position
	}
end

---@param mirror LuaEntity
---@param tower LuaEntity
--- Link a mirror and a tower, rotating the mirror to point in the correct direction
control_util.linkMirrorToTower = function(mirror, tower)

	assert(tower.surface.index == mirror.surface.index, "Attempted to link tower and mirror on different surfaces")

	local mid = mirror.unit_number

	if global.mirror_tower[mid] ~= nil then
		if global.mirror_tower[mid].tower.unit_number == tower.unit_number then
			return
		end
	end


	global.mirror_tower[mid] = {
		tower = tower,
		mirror = mirror,
		beam = nil,
	}



	table.insert(global.tower_mirrors[tower.unit_number], mirror)


	local x = mirror.position.x - tower.position.x
	local y = mirror.position.y - tower.position.y

	mirror.orientation = -math.atan2(y, x) * 0.15915494309 + 0.25

	time = control_util.calc_sun(mirror.surface)

	stage = control_util.getSunStage(time)

	if mid % control_util.mirror_groups < stage then
		control_util.generateBeam(mirror, tower,
			(mirror.surface.daytime - mirror.surface.evening) * mirror.surface.ticks_per_day)
	end


end

control_util.cleanTrees = function()
	if global.mirror_tower then
		for key, value in pairs(global.mirror_tower) do
			if value.beam then

				value.beam.destroy()
			end
		end
	end

end

control_util.buildTrees = function()
	--game.print("generating mirror links")

	control_util.cleanTrees()

	global.tower_mirrors = {}
	global.mirror_tower = {}
	global.mirrors = {}
	global.towers = {}
	if global.surfaces == nil then
		global.surfaces = {}
	end


	for _, surface in pairs(game.surfaces) do
		if global.surfaces[surface.index] == nil then
			--game.print("reseting surface" .. surface.index)
			global.surfaces[surface.index] = { last_sun_stage = 0, surface = surface }
		end

		towers = surface.find_entities_filtered({ name = control_util.solar_power_tower });


		--game.print(surface.name)
		--game.print(#towers)

		if towers then
			for _, tower in ipairs(towers) do


				--game.print(tower.position)

				local mirrors = surface.find_entities_filtered {
					name = control_util.heliostat_mirror,
					position = tower.position,
					radius = control_util.tower_capture_radius
				}
				global.tower_mirrors[tower.unit_number] = {}

				for _, mirror in ipairs(mirrors) do
					if global.mirror_tower[mirror.unit_number] == nil then

						control_util.linkMirrorToTower(tower, mirror)

						global.mirrors[mirror.unit_number] = mirror

					end
				end



				global.towers[tower.unit_number] = tower

				--game.print(#global.tower_mirrors[tower.unit_number])
			end
		end
	end
end

control_util.removeMirrorFromTower = function(tower, mirror, remove_mirror_from_tower_links)

	if global.mirror_tower[mirror.unit_number].beam then

		global.mirror_tower[mirror.unit_number].beam.destroy()
	end
	global.mirror_tower[mirror.unit_number] = nil

	if remove_mirror_from_tower_links then

		add_mirrors = {}

		old_mirrors = global.tower_mirrors[tower.unit_number]

		for _, old_mirror in ipairs(old_mirrors) do
			if old_mirror.unit_number ~= mirror.unit_number then
				table.insert(add_mirrors, old_mirror)
			end
		end
		assert(#old_mirrors == #add_mirrors + 1,
			"Incorrect removal of mirror: started with " .. #old_mirrors .. ", ended with " .. #add_mirrors)

		global.tower_mirrors[tower.unit_number] = add_mirrors

	end

end



---@param entity LuaEntity
control_util.on_built_entity_callback = function(entity)
	assert(entity ~= nil, "Called back with nil entity")


	--game.print("Somthing was built")

	if global.mirror_tower == nil then
		control_util.buildTrees()

	else
		local surface = entity.surface

		if entity.name == control_util.heliostat_mirror then
			-- Register this mirror
			global.mirrors[entity.unit_number] = entity

			-- Find a tower for this mirror
			local towers = surface.find_entities_filtered {
				name = control_util.solar_power_tower,
				position = entity.position,
				radius = control_util.tower_capture_radius
			}
			if towers ~= nil and #towers > 0 then
				-- Pick the closest tower out of the avaliable
				local bestTower = nil
				local bestDistance = nil
				for _, tower in pairs(towers) do
					local dist = util.distance(tower.position, entity.position)
					if bestTower == nil or bestTower and
						dist < bestDistance then
						bestTower = tower
						bestDistance = dist
					end
				end

				control_util.linkMirrorToTower(entity, bestTower)
			else
				--TODO: Handle case with no towers in range
				game.get_player(1).create_local_flying_text {
					text = { control_util.mod_prefix .. "no-tower-in-range" },
					position = entity.position,
					color = nil,
					time_to_live = 60,
					speed = 1.0,
				}
			end

		elseif entity.name == control_util.solar_power_tower then

			--get mirrors in radius around us
			local mirrors = entity.surface.find_entities_filtered {
				name = control_util.heliostat_mirror,
				position = entity.position,
				radius = control_util.tower_capture_radius
			}

			--added_mirrors = {}
			global.towers[entity.unit_number] = entity
			global.tower_mirrors[entity.unit_number] = {}

			for _, mirror in pairs(mirrors) do

				if global.mirror_tower[mirror.unit_number] == nil then
					control_util.linkMirrorToTower(mirror, entity)
				else
					control_util.linkMirrorToTowerIfCloser(mirror, entity)

				end

			end

			-- if any are closer to this tower then their current, switch their target


		end
	end
end

control_util.ticks = 60
local mirror_kw = 100
local fluid_kj = 1000
control_util.fluidPerTickPerMirror = mirror_kw / fluid_kj / 60
control_util.tower_capture_radius = 40
control_util.sun_stages = 20
-- Number of groups of mirrors that will have sun rays spawned on them
control_util.mirror_groups = 100
-- Number of sets of mirrors, used to spawn sun-rays


return control_util
