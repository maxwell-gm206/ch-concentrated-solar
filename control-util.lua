local control_util = require "shared-util"

---@type Global
global = global

---@type LuaGameScript
game = game

---@type LuaRendering
rendering = rendering

---@type LuaBootstrap
script = script


tower_names = {}
is_tower = {}

control_util.registerTowerName = function(name)
	is_tower[name] = true
	table.insert(tower_names, name)
end

control_util.isTower = function(name)
	return is_tower[name] ~= nil
end



---@nodiscard
control_util.inv_lerp = function(a, b, v)
	return math.max(math.min((v - a) / (b - a), 1), 0)
end

---@nodiscard
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
---@nodiscard
control_util.getSunStage = function(time_info)
	return math.floor(time_info.sun * control_util.sun_stages) - 1
end

---@param mirror LuaEntity
---@return LuaEntity?
---@nodiscard
control_util.getTowerForMirror = function(mirror)

	if global.mirror_tower[mirror.unit_number] and global.mirror_tower[mirror.unit_number].tower then
		return global.mirror_tower[mirror.unit_number].tower
	else
		return nil
	end

end

---@param mirror LuaEntity
---@return number
---@nodiscard
--- Distance from `mirror` to it's tower
control_util.distance_to_tower = function(mirror)

	local tower = control_util.getTowerForMirror(mirror)

	if tower then
		return util.distance(mirror.position, tower.position)
	else
		return math.huge
	end
end

---@param inputs MirrorTower
--- run `linkMirrorToTower` if the new tower has a distance lower than the original
control_util.linkMirrorToTowerIfCloser = function(inputs)

	local curDist = control_util.distance_to_tower(inputs.mirror)

	local newDist = util.distance(inputs.mirror.position, inputs.tower.position)

	if newDist < curDist and newDist < control_util.tower_capture_radius then
		control_util.linkMirrorToTower(inputs)
	end
end



---@param inputs {tower:LuaEntity, mirror:LuaEntity, ttl:number}
---@return LuaEntity
---@nodiscard
--- Create a beam from a `mirror` to a `tower`, lasting for `ttl`
control_util.generateBeam = function(inputs)

	return inputs.mirror.surface.create_entity {
		position = inputs.mirror.position,
		name = control_util.mod_prefix .. "mirrored-solar-beam",
		raise_built = false,
		time_to_live = inputs.ttl,
		target_position = control_util.towerTarget(inputs.tower),
		source_position = inputs.mirror.position
	}
end

---@param tower LuaEntity
---@return Vector
control_util.towerTarget = function(tower)
	return { tower.position.x, tower.position.y - 13 }
end

---@param inputs {towers:LuaEntity[], position:Vector, ignore : LuaEntity?}
---@return LuaEntity?
---@nodiscard
control_util.closestTower = function(inputs)

	local bestTower = nil
	local bestDistance = nil
	for _, tower in pairs(inputs.towers) do
		if tower ~= inputs.ignore then
			local dist = util.distance(tower.position, inputs.position)

			if bestTower == nil or bestTower and
				dist < bestDistance then
				bestTower = tower
				bestDistance = dist
			end
		end
	end

	return bestTower
end




---@param args MirrorTower
--- Link a mirror and a tower, rotating the mirror to point in the correct direction
control_util.linkMirrorToTower = function(args)

	local tower = args.tower
	local mirror = args.mirror

	assert(mirror, "No mirror")
	assert(tower, "No tower")
	assert(tower.surface.index == mirror.surface.index, "Attempted to link tower and mirror on different surfaces")

	local mid = mirror.unit_number


	if global.mirror_tower[mid] ~= nil then
		if global.mirror_tower[mid].tower.unit_number == tower.unit_number then
			-- We are already linked to this tower!
			return
		else
			-- Clean up previous link
			control_util.removeMirrorFromTower { mirror = mirror, tower = global.mirror_tower[mid].tower }
		end
	end

	-- Link in the mirror -> tower direction

	global.mirror_tower[mid] = {
		tower = tower,
		mirror = mirror,
	}

	-- Don't generate beams, this will happen naturally

	-- Link in the tower -> mirrors direction

	if global.tower_mirrors[tower.unit_number] == nil then
		-- This shouldn't be possible, but happened so I had to add it
		global.tower_mirrors[tower.unit_number] = { mirror }
	else
		table.insert(global.tower_mirrors[tower.unit_number], mirror)
	end

	local x = mirror.position.x - tower.position.x
	local y = mirror.position.y - tower.position.y

	mirror.orientation = -math.atan2(y, x) * 0.15915494309 + 0.25


end

control_util.delete_all_beams = function()
	for _, surf in pairs(game.surfaces) do
		beams = surf.find_entities_filtered { name = control_util.mod_prefix .. "mirrored-solar-beam" }
		for _, beam in pairs(beams) do
			beam.destroy()
		end
	end

end




control_util.on_init = function()
	control_util.buildSurfaces()
	control_util.buildTrees()
	game.print(control_util.mod_prefix .. "welcome")
end

control_util.buildSurfaces = function()

	global.surfaces = {}


	for _, surface in pairs(game.surfaces) do
		if global.surfaces[surface.index] == nil then
			--game.print("reseting surface" .. surface.index)
			global.surfaces[surface.index] = { last_sun_stage = 0, surface = surface }
		end
	end
end

control_util.buildTrees = function()
	--game.print("generating mirror links")

	control_util.delete_all_beams()

	global.tower_mirrors = {}
	global.mirror_tower = {}
	global.mirrors = {}
	global.towers = {}

	--control_util.consistencyCheck()

	for _, surface in pairs(game.surfaces) do

		local towers = surface.find_entities_filtered({ name = tower_names });

		if towers then
			for _, tower in pairs(towers) do

				-- Mark each tower as new
				control_util.on_built_entity_callback(tower)

			end
		end
	end


	control_util.consistencyCheck()
end



---@param args {tower:LuaEntity, mirror:LuaEntity, clearTowerMirrorsRelation:boolean?}
control_util.removeMirrorFromTower = function(args)
	-- unpack and verify arguments
	local tower = args.tower
	local mirror = args.mirror
	local clearTowerMirrorsRelation = args.clearTowerMirrorsRelation or true

	assert(tower ~= nil)
	assert(mirror ~= nil)
	assert(global.mirror_tower[mirror.unit_number].tower == tower, "Mirror not connected to tower in mirrors->tower")

	--game.print("removing mirror ")

	-- Destroy beams if we have them
	if global.mirror_tower[mirror.unit_number].beam then

		--game.print("removing mirror beam")

		global.mirror_tower[mirror.unit_number].beam.destroy()
	end
	-- Remove mirror -> tower relation
	global.mirror_tower[mirror.unit_number] = nil


	if clearTowerMirrorsRelation then
		-- Remove tower -> mirrors relation
		-- Skip this step for deleting a tower, when entire relation can be removed at once later

		local add_mirrors = {}
		local found = false
		local old_mirrors = global.tower_mirrors[tower.unit_number]

		for _, old_mirror in pairs(old_mirrors) do
			if old_mirror.unit_number ~= mirror.unit_number then
				table.insert(add_mirrors, old_mirror)
			else
				found = true
			end
		end


		assert(found, "Mirror not connected to tower in tower->mirrors")

		assert(table_size(old_mirrors) == table_size(add_mirrors) + 1,
			"Incorrect removal of mirror: started with " .. table_size(old_mirrors) .. ", ended with " .. table_size(add_mirrors))

		global.tower_mirrors[tower.unit_number] = add_mirrors
	end

	--control_util.consistencyCheck()
end

control_util.consistencyCheck = function()
	for tid, mirrors in pairs(global.tower_mirrors) do

		assert(global.towers[tid] and global.towers[tid].valid, "NOT CONSISTENT: tower " .. tid .. " ref to invalid tower")

		for _, mirror in pairs(mirrors) do
			assert(global.mirror_tower[mirror.unit_number], "NOT CONSISTENT: tower->mirror->tower relation does not exist")

			assert(global.mirror_tower[mirror.unit_number].tower.unit_number == tid,
				"NOT CONSISTENT: mirror points to multiple towers")

			assert(mirror.valid, "NOT CONSISTENT: tower->mirrors ref to invalid mirror")


			assert(global.towers[tid].unit_number == tid, "NOT CONSISTENT: tower does not point to self")
		end
	end


	for mid, mirror in pairs(global.mirrors) do
		assert(global.mirrors[mid].unit_number == mid, "NOT CONSISTENT: mirror does not point to self")
		assert(global.mirrors[mid].valid, "NOT CONSISTENT: mirror ref to invalid mirror")
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
				name = tower_names,
				position = entity.position,
				radius = control_util.tower_capture_radius
			}
			if towers ~= nil and table_size(towers) > 0 then
				-- Pick the closest tower out of the avaliable

				control_util.linkMirrorToTower { mirror = entity,
					tower = control_util.closestTower { towers = towers, position = entity.position } }
			else
				-- Handle case with no towers in range
				game.get_player(1).create_local_flying_text {
					text = { control_util.mod_prefix .. "no-tower-in-range" },
					position = entity.position,
					color = nil,
					time_to_live = 60,
					speed = 1.0,
				}
			end

		elseif control_util.isTower(entity.name) then

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

				-- will always succed if this mirror has no tower
				control_util.linkMirrorToTowerIfCloser { mirror = mirror, tower = entity }


			end

			-- if any are closer to this tower then their current, switch their target


		end
	end

	--control_util.consistencyCheck()
end

control_util.fluid_ticks = 60
control_util.sun_ticks = 600
local mirror_kw = 100
local fluid_kj = 1000
control_util.fluidPerTickPerMirror = mirror_kw / fluid_kj / 60
control_util.tower_capture_radius = 40
control_util.sun_stages = 10
-- Number of groups of mirrors that will have sun rays spawned on them
control_util.mirror_groups = 100
-- Number of sets of mirrors, used to spawn sun-rays



control_util.registerTowerName(control_util.mod_prefix .. "solar-power-tower")
control_util.registerTowerName(control_util.mod_prefix .. "solar-laser-tower")

return control_util
