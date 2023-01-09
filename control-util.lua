local control_util = require "shared-util"

---@type Global
--global = global

---@type LuaGameScript
--game = game

---@type LuaRendering
--rendering = rendering

---@type LuaBootstrap
--script = script


tower_names = {}
is_tower = {}

control_util.registerTowerName = function(name)
	is_tower[name] = true
	table.insert(tower_names, name)
end

control_util.isTower = function(name)
	return is_tower[name] ~= nil
end


control_util.dist_sqr = function(p1, p2)
	return (p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2
end

---@nodiscard
control_util.inv_lerp = function(a, b, v)
	return math.max(math.min((v - a) / (b - a), 1), 0)
end

---@nodiscard
control_util.calc_sun = function(surface)
	if surface.daytime > surface.evening then
		--game.print("morning!")
		return control_util.inv_lerp(surface.morning, surface.dawn, surface.daytime)
	else
		--game.print("evening!")
		return control_util.inv_lerp(surface.evening, surface.dusk, surface.daytime)
	end
end



---@param mirror LuaEntity
---@return LuaEntity?
---@nodiscard
control_util.getTowerForMirror = function(mirror)

	if global.mirror_tower[mirror.unit_number] then
		local tower = global.mirror_tower[mirror.unit_number].tower

		if tower and tower.valid then
			return tower
		end
	end

	return nil
end

---@param mirror LuaEntity
---@return number
---@nodiscard
--- Distance from `mirror` to it's tower
control_util.distance_to_tower = function(mirror)

	local tower = control_util.getTowerForMirror(mirror)

	if tower then
		return control_util.dist_sqr(mirror.position, tower.position)
	else
		return math.huge
	end
end

---@param inputs MirrorTower
--- run `linkMirrorToTower` if the new tower has a distance lower than the original
--- and store the tower as in range is it is
control_util.linkMirrorToTowerIfCloser = function(inputs)
	-- Only link towers and mirrors if they have the same force
	if inputs.mirror.force.name ~= inputs.tower.force.name then
		return
	end

	local tower = control_util.getTowerForMirror(inputs.mirror)

	if tower and tower.valid then

		local curDist = control_util.dist_sqr(inputs.mirror.position, tower.position)

		local newDist = control_util.dist_sqr(inputs.mirror.position, inputs.tower.position)

		if newDist < curDist and newDist < control_util.tower_capture_radius_sqr then
			control_util.linkMirrorToTower(inputs)
		elseif newDist < control_util.tower_capture_radius_sqr then
			-- Tower not closer, but still in range, could be used later,
			-- add it to the mirror's list of other towers in range

			--game.print("alternate tower in range")
			control_util.mark_in_range(inputs.mirror.unit_number, inputs.tower)
		end
	else

		control_util.linkMirrorToTower(inputs)
	end

end



---@param inputs {tower:LuaEntity, mirror:LuaEntity, ttl:uint?, mirrored:boolean?, blend : number?}
---@return LuaEntity?
---@nodiscard
--- Create a beam from a `mirror` to a `tower`, lasting for `ttl`
control_util.generateBeam = function(inputs)
	local name

	if inputs.mirrored == nil or inputs.mirrored then
		name = control_util.mod_prefix .. "mirrored-solar-beam"
	else
		name = control_util.mod_prefix .. "solar-beam"
	end

	local source = control_util.towerTarget(inputs.tower)
	local target = inputs.mirror.position

	target.y = target.y - 0.5
	local blend = inputs.blend or 0.9
	-- shift towards mirror a little
	source.x = source.x * blend + target.x * (1 - blend)
	source.y = source.y * blend + target.y * (1 - blend)


	return inputs.mirror.surface.create_entity {
		position = target,
		name = name,
		raise_built = false,
		duration = inputs.ttl or 0,
		target_position = target,
		source_position = source
	}
end

---@param tower LuaEntity
---@return MapPosition
control_util.towerTarget = function(tower)
	return { x = tower.position.x, y = tower.position.y - 13 }
end

---@param inputs {towers:LuaEntity[], position:Vector, ignore_id : number?}
---@return LuaEntity?
---@nodiscard
control_util.closestTower = function(inputs)

	local bestTower = nil
	local bestDistance = nil
	for _, tower in pairs(inputs.towers) do
		if tower and tower.valid and tower.unit_number ~= inputs.ignore_id then
			local dist = control_util.dist_sqr(tower.position, inputs.position)

			if bestTower == nil or
				(bestTower and dist < bestDistance) then
				bestTower = tower
				bestDistance = dist
			end
		end
	end

	return bestTower
end

---@param inputs {entity:LuaEntity, radius:number? }
---@return LuaEntity[]
---@nodiscard
control_util.find_towers_around_entity = function(inputs)
	local r = inputs.radius or control_util.tower_capture_radius
	return inputs.entity.surface.find_entities_filtered {
		name = tower_names,
		force = inputs.entity.force,
		area = { { inputs.entity.position.x - r, inputs.entity.position.y - r },
			{ inputs.entity.position.x + r, inputs.entity.position.y + r } }
	}
end

---@param inputs {entity:LuaEntity, radius:number? }
---@return LuaEntity[]
---@nodiscard
control_util.find_mirrors_around_entity = function(inputs)
	local r = inputs.radius or control_util.tower_capture_radius
	return inputs.entity.surface.find_entities_filtered {
		name = control_util.heliostat_mirror,
		force = inputs.entity.force,
		area = { { inputs.entity.position.x - r, inputs.entity.position.y - r },
			{ inputs.entity.position.x + r, inputs.entity.position.y + r } }
	}
end

control_util.mark_in_range = function(mid, tower)
	if global.mirror_tower[mid].in_range then
		global.mirror_tower[mid].in_range[tower.unit_number] = tower
	else
		global.mirror_tower[mid].in_range = { [tower.unit_number] = tower }
	end
end

control_util.mark_out_range = function(mid, tower)
	if global.mirror_tower[mid] and global.mirror_tower[mid].in_range then
		global.mirror_tower[mid].in_range[tower.unit_number] = nil
	end
end

control_util.convert_to_indexed_table = function(array)
	t = {}
	for _, e in pairs(array) do
		t[e.unit_number] = e
	end
	return t
end

---@param args {mirror:LuaEntity, tower:LuaEntity, all_in_range : LuaEntity[]? }
--- Link a mirror and a tower, rotating the mirror to point in the correct direction
--- `all_in_range` - all towers in range of the mirror, assigned to `[mid]=in_range` if mirror is new
control_util.linkMirrorToTower = function(args)

	local tower = args.tower
	local mirror = args.mirror

	assert(mirror, "No mirror")
	assert(tower, "No tower")
	assert(tower.surface.index == mirror.surface.index, "Attempted to link tower and mirror on different surfaces")

	local mid = mirror.unit_number


	if global.mirror_tower[mid] then
		if global.mirror_tower[mid].tower then
			-- If this mirror has a tower, do something about it

			if global.mirror_tower[mid].tower.unit_number == tower.unit_number then
				-- We are already linked to this tower!
				return
			else
				--add the previous link to in_range
				control_util.mark_in_range(mid, global.mirror_tower[mid].tower)
				-- Clean up previous link
				control_util.removeMirrorFromTower { mirror = mirror, tower = global.mirror_tower[mid].tower }
			end
		end
		-- If this tower was marked in range before, remove it
		control_util.mark_out_range(mid, tower)
		-- Link in the mirror -> tower direction
		global.mirror_tower[mid].tower = tower

	else
		global.mirror_tower[mid] = {
			tower = tower,
			mirror = mirror,
			in_range = args.all_in_range
		}
		-- In range could include the closest tower, due to lazyness
		control_util.mark_out_range(mid, tower)
	end





	-- Don't generate beams, this will happen naturally

	-- Link in the tower -> mirrors direction

	if global.tower_mirrors[tower.unit_number] == nil then
		-- This shouldn't be possible, but happened so I had to add it
		global.tower_mirrors[tower.unit_number] = { [mirror.unit_number] = mirror }
	else
		local r = global.tower_mirrors[tower.unit_number]
		r[mirror.unit_number] = mirror
		global.tower_mirrors[tower.unit_number] = r
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

	--control_util.delete_all_beams()

	global.tower_mirrors = {}
	global.mirror_tower = {}
	global.mirrors = {}
	global.beam_mirrors = {}
	global.towers = {}

	--control_util.consistencyCheck()

	for _, surface in pairs(game.surfaces) do

		local towers = surface.find_entities_filtered({ name = tower_names });

		if towers then
			for _, tower in pairs(towers) do

				-- Mark each tower as new
				control_util.on_built_entity_callback(tower, game.tick + 1)

			end
		end
	end


	control_util.consistencyCheck()
end



---@param args {tower:LuaEntity?, tid : number? , mirror:LuaEntity, clearTowerMirrorsRelation:boolean?}
control_util.removeMirrorFromTower = function(args)
	-- unpack and verify arguments
	local tid = args.tid or args.tower.unit_number

	local mirror = args.mirror

	assert(tid ~= nil)
	assert(mirror ~= nil)
	--assert(global.mirror_tower[mirror.unit_number].tower.unit_number == tid,
	--"Mirror not connected to tower in mirrors->tower")

	--game.print("removing mirror ")

	-- Destroy beams if we have them
	if global.mirror_tower[mirror.unit_number].beam then

		--game.print("removing mirror beam")

		global.mirror_tower[mirror.unit_number].beam.destroy()
	end
	-- Remove mirror -> tower relation
	global.mirror_tower[mirror.unit_number].tower = nil


	if args.clearTowerMirrorsRelation == nil or args.clearTowerMirrorsRelation then
		-- Remove tower -> mirrors relation
		-- Skip this step for deleting a tower, when entire relation can be removed at once later
		local r = global.tower_mirrors[tid]
		r[mirror.unit_number] = nil
		global.tower_mirrors[tid] = r

		--control_util.consistencyCheck()
	end

	--control_util.consistencyCheck()
end

control_util.consistencyCheck = function()
	for tid, mirrors in pairs(global.tower_mirrors) do

		if not global.towers[tid] or not global.towers[tid].valid then

			control_util.notify_tower_invalid(tid)

			log("NOT CONSISTENT: tower " .. tid .. " ref to invalid tower")

		else
			for _, mirror in pairs(mirrors) do
				assert(global.mirror_tower[mirror.unit_number], "NOT CONSISTENT: tower->mirror->tower relation does not exist")

				assert(global.mirror_tower[mirror.unit_number].tower.unit_number == tid,
					"NOT CONSISTENT: mirror points to multiple towers")

				assert(mirror.valid, "NOT CONSISTENT: tower->mirrors ref to invalid mirror")


				assert(global.towers[tid].unit_number == tid, "NOT CONSISTENT: tower does not point to self")
			end
		end
	end


	for mid, mirror in pairs(global.mirrors) do
		assert(global.mirrors[mid].unit_number == mid, "NOT CONSISTENT: mirror does not point to self")
		assert(global.mirrors[mid].valid, "NOT CONSISTENT: mirror ref to invalid mirror")
	end
end

---@param tid number
control_util.notify_tower_invalid = function(tid)
	-- Delete a tower from the database
	--game.print("tower " .. entity.unit_number .. " destroyed")

	-- Remove every mirror -> tower relation

	for _, mirror in pairs(global.tower_mirrors[tid]) do
		control_util.removeMirrorFromTower { tid = tid, mirror = mirror, clearTowerMirrorsRelation = false }
	end

	local entity = global.towers[tid]

	if entity and entity.valid then
		-- Find new targets for orphaned mirrors
		--local otherNearbyTowers = control_util.find_towers_around_entity {
		--	entity = entity,
		--	radius = control_util.tower_capture_radius * 2,
		--}

		--if table_size(otherNearbyTowers) > 1 then
		-- need at least 2 near towers for this to work for at least some of the mirrors

		for mid, mirror in pairs(global.tower_mirrors[tid]) do

			if global.mirror_tower[mid] and global.mirror_tower[mid].in_range then
				local tower = control_util.closestTower {
					towers = global.mirror_tower[mid].in_range,
					position = mirror.position,
					ignore = tid,
				}

				if tower then

					control_util.linkMirrorToTower {
						mirror = mirror,
						tower = tower
					}
				end
			end
		end
		--end
	end
	-- remove this tower from record
	global.towers[tid] = nil
	-- Remove every tower -> mirror relation, return to consistency
	global.tower_mirrors[tid] = nil


	-- Fixes issue when last updated tower has just been destroyed
	-- "invalid key to next"
	if global.last_updated_tower == tid then
		global.last_updated_tower = 0
	end
	if global.last_updated_tower_beam == tid then
		global.last_updated_tower_beam = 0
	end

	control_util.on_tower_count_changed()
end

---@param entity LuaEntity
---@param tick uint
control_util.on_built_entity_callback = function(entity, tick)

	assert(entity, "Called back with nil entity")
	assert(tick, "Called back with nil tick")

	--game.print("Somthing was built")

	if global.mirror_tower == nil then
		control_util.buildTrees()
	else
		local surface = entity.surface

		if entity.name == control_util.heliostat_mirror then
			-- Register this mirror
			global.mirrors[entity.unit_number] = entity

			-- Find a tower for this mirror
			local towers = control_util.find_towers_around_entity { entity = entity }

			local tower = control_util.closestTower { towers = towers, position = entity.position }

			if tower then
				-- Pick the closest tower out of the avaliable
				control_util.linkMirrorToTower {
					mirror = entity,
					tower = tower,
					all_in_range = control_util.convert_to_indexed_table(towers)
				}

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
			local mirrors = control_util.find_mirrors_around_entity { entity = entity }

			--added_mirrors = {}
			global.towers[entity.unit_number] = entity
			global.tower_mirrors[entity.unit_number] = {}

			-- if any are closer to this tower then their current, switch their target

			for _, mirror in pairs(mirrors) do
				-- will always succed if this mirror has no tower
				control_util.linkMirrorToTowerIfCloser { mirror = mirror, tower = entity }
			end


			control_util.on_tower_count_changed()
		end
	end

	--control_util.consistencyCheck()
end

control_util.on_tower_count_changed = function()
	global.tower_update_count = math.ceil(table_size(global.tower_mirrors) * control_util.tower_update_fraction)
	global.tower_beam_update_count = math.ceil(table_size(global.tower_mirrors) * control_util.beam_update_fraction)

	print(table_size(global.tower_mirrors) .. " " .. global.tower_update_count)
end

control_util.update_settings = function()
	control_util.tower_update_interval = settings.global["tower-update-interval"].value
	control_util.tower_full_update_time = settings.global["full-tower-update-time"].value
	control_util.beam_update_interval = settings.global["beam-update-interval"].value
	control_util.beam_full_update_time = settings.global["full-beam-update-time"].value

	control_util.tower_update_fraction = control_util.tower_update_interval / control_util.tower_full_update_time
	control_util.beam_update_fraction = control_util.beam_update_interval / control_util.beam_full_update_time


end

control_util.update_settings()

local mirror_kw = 100
control_util.fluidPerTickPerMirror = mirror_kw / control_util.solar_heat_capacity_kj / 60
control_util.fluidTempPerMirror = mirror_kw / control_util.solar_heat_capacity_kj
control_util.tower_capture_radius = 33
control_util.tower_capture_radius_sqr = control_util.tower_capture_radius ^ 2
control_util.sun_stages = 20
-- Number of groups of mirrors that will have sun rays spawned on them
control_util.mirror_groups = 50
-- Number of sets of mirrors, used to spawn sun-rays
control_util.DEBUG_LINES = false


control_util.registerTowerName(control_util.mod_prefix .. "solar-power-tower")
control_util.registerTowerName(control_util.mod_prefix .. "solar-laser-tower")

return control_util
