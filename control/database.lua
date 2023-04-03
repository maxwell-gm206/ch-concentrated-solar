local db = {}

local control_util = require "control-util"


db.on_init = function()
	-- Ensure every global table used exists

	---@type  {[uint] : MirrorTowerRelation}
	global.mirrors = global.mirrors or {}

	---@type {[uint] : {tower:LuaEntity, mirrors: {[uint] : LuaEntity}}}
	global.towers = global.towers or {}

	---@type {[uint] : LuaEntity}
	global.player_boxes = global.player_boxes or {}

	---@type {[uint] : LuaEntity}
	global.player_tower_rect = global.player_tower_rect or {}


	--control_util.buildTrees()

	db.consistencyCheck()

	game.print(control_util.mod_prefix .. "welcome")
end


-- catch all functions for if a tid or mid is safe to use
---@param tid uint?
---@nodiscard
db.valid_tid = function(tid)
	return tid and global.towers[tid] and global.towers[tid].tower and global.towers[tid].tower.valid
end
---@param mid uint?
---@nodiscard
db.valid_mid = function(mid)
	return mid and global.mirrors[mid] and global.mirrors[mid].mirror and global.mirrors[mid].mirror.valid
end

---@param inputs {towers:LuaEntity[], position:Vector, ignore_id : number?}
---@return LuaEntity?
---@nodiscard
db.closestTower = function(inputs)
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

---@param args {mirror:LuaEntity, tower:LuaEntity, all_in_range : LuaEntity[]? }
--- Link a mirror and a tower, rotating the mirror to point in the correct direction
--- `all_in_range` - all towers in range of the mirror, assigned to `[mid]=in_range` if mirror is new
db.linkMirrorToTower = function(args)
	local tower = args.tower
	local mirror = args.mirror

	assert(mirror, "No mirror")
	assert(tower, "No tower")
	assert(tower.surface.index == mirror.surface.index, "Attempted to link tower and mirror on different surfaces")

	local mid = mirror.unit_number


	if db.valid_mid(mid) then
		if global.mirrors[mid].tower then
			-- If this mirror has a tower, do something about it

			if global.mirrors[mid].tower.unit_number == tower.unit_number then
				-- We are already linked to this tower!
				return
			else
				--add the previous link to in_range
				db.mark_in_range(mid, global.mirrors[mid].tower)
				-- Clean up previous link
				db.removeMirrorFromTower { mid = mid, tid = global.mirrors[mid].tower.unit_number }
			end
		end
		-- If this tower was marked in range before, remove it
		db.mark_out_range(mid, tower)
		-- Link in the mirror -> tower direction
		global.mirrors[mid].tower = tower
	else
		global.mirrors[mid] = {
			tower = tower,
			mirror = mirror,
			in_range = args.all_in_range
		}
		-- In range could include the closest tower, due to lazyness
		db.mark_out_range(mid, tower)
	end


	-- Don't generate beams, this will happen naturally

	-- Link in the tower -> mirrors direction

	if not global.towers[tower.unit_number] then
		global.towers[tower.unit_number] = {
			tower = tower,
			mirrors = { [mirror.unit_number] = mirror },
		}
	else
		if not global.towers[tower.unit_number].mirrors then
			-- This shouldn't be possible, but happened so I had to add it
			global.towers[tower.unit_number].mirrors = { [mirror.unit_number] = mirror }
		else
			global.towers[tower.unit_number].mirrors[mirror.unit_number] = mirror
		end
	end

	local x = mirror.position.x - tower.position.x
	local y = mirror.position.y - tower.position.y

	mirror.orientation = math.atan2(y, x) * 0.15915494309 - 0.25
end


---@param inputs MirrorTower
--- run `linkMirrorToTower` if the new tower has a distance lower than the original
--- and store the tower as in range is it is
db.linkMirrorToTowerIfCloser = function(inputs)
	-- Only link towers and mirrors if they have the same force
	if inputs.mirror.force.name ~= inputs.tower.force.name then
		return
	end

	-- tower is valid if not nil
	local tower = db.getTowerForMirror(inputs.mirror)

	if tower then
		local curDist = control_util.dist_sqr(inputs.mirror.position, tower.position)

		local newDist = control_util.dist_sqr(inputs.mirror.position, inputs.tower.position)

		if newDist < curDist and newDist < control_util.tower_capture_radius_sqr then
			db.linkMirrorToTower(inputs)
		elseif newDist < control_util.tower_capture_radius_sqr then
			-- Tower not closer, but still in range, could be used later,
			-- add it to the mirror's list of other towers in range
			-- TODO: should use bounds, but not important

			--game.print("alternate tower in range")
			db.mark_in_range(inputs.mirror.unit_number, inputs.tower)
		end
	else
		db.linkMirrorToTower(inputs)
	end
end


---@param tid uint
db.notify_tower_invalid = function(tid)
	-- Delete a tower from the database
	--game.print("tower " .. entity.unit_number .. " destroyed")

	-- Remove every mirror -> tower relation

	for mid, mirror in pairs(global.towers[tid].mirrors) do
		db.removeMirrorFromTower { mid = mid }

		-- Find new targets for orphaned mirrors, if it still exists

		if db.valid_mid(mid) and global.mirrors[mid].in_range then
			local tower = db.closestTower {
				towers = global.mirrors[mid].in_range,
				position = mirror.position,
				ignore = tid,
			}

			if tower then
				db.linkMirrorToTower {
					mirror = mirror,
					tower = tower
				}
			end
		end
	end
	--end
	-- remove this tower from record
	-- Remove every tower -> mirror relation, return to consistency
	global.towers[tid] = nil


	-- Fixes issue when last updated tower has just been destroyed
	-- "invalid key to next"

	if global.last_updated_tower == tid then
		global.last_updated_tower = nil
	end
	if global.last_updated_tower_beam == tid then
		global.last_updated_tower_beam = nil
	end

	db.on_tower_count_changed()
end


db.on_tower_count_changed = function()
	global.tower_update_count = math.ceil(table_size(global.towers) * control_util.tower_update_fraction)
	global.tower_beam_update_count = math.ceil(table_size(global.towers) * control_util.beam_update_fraction)

	print(table_size(global.towers) .. " " .. global.tower_update_count)
end

---@param mirror LuaEntity
---@return LuaEntity?
---@nodiscard
db.getTowerForMirror = function(mirror)
	if global.mirrors[mirror.unit_number] then
		local tower = global.mirrors[mirror.unit_number].tower

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
db.distance_to_tower = function(mirror)
	local tower = db.getTowerForMirror(mirror)

	if tower then
		return control_util.dist_sqr(mirror.position, tower.position)
	else
		return math.huge
	end
end

db.mark_in_range = function(mid, tower)
	if global.mirrors[mid].in_range then
		global.mirrors[mid].in_range[tower.unit_number] = tower
	else
		global.mirrors[mid].in_range = { [tower.unit_number] = tower }
	end
end

db.mark_out_range = function(mid, tower)
	if global.mirrors[mid] and global.mirrors[mid].in_range then
		global.mirrors[mid].in_range[tower.unit_number] = nil
	end
end




db.buildTrees = function()
	print("Generating tower relations")

	--beams.delete_all_beams()

	--control_util.consistencyCheck()

	for _, surface in pairs(game.surfaces) do
		local towers = surface.find_entities_filtered({ name = tower_names });

		if towers then
			for _, tower in pairs(towers) do
				-- Mark each tower as new
				db.on_built_entity_callback(tower, game.tick + 1)
			end
		end
	end


	db.consistencyCheck()
end


-- If we don't want to remove the mirror from the tower's list of mirrors
-- (tower destroyed), simply do not include the tid in calling
---@param args { tid : uint?  , mid:uint}
db.removeMirrorFromTower = function(args)
	-- unpack and verify arguments

	if not db.valid_mid(args.mid) then return end

	local mid = args.mid

	--assert(global.mirrors[mid].tower.unit_number == tid,

	--"Mirror not connected to tower in mirrors->tower")

	-- Destroy beams if we have them
	if global.mirrors[mid].beam then
		global.mirrors[mid].beam.destroy()
	end

	-- Remove mirror -> tower relation
	global.mirrors[mid].tower = nil


	if args.tid then
		-- Remove tower -> mirrors relation
		-- Skip this step for deleting a tower, when entire relation can be removed at once later
		global.towers[args.tid].mirrors[mid] = nil


		--control_util.consistencyCheck()
	end

	--control_util.consistencyCheck()
end

db.consistencyCheck = function()
	for tid, mirrors in pairs(global.towers) do
		if not db.valid_tid(tid) then
			db.notify_tower_invalid(tid)

			log("NOT CONSISTENT: tower " .. tid .. " ref to invalid tower")
		else
			for _, mirror in pairs(mirrors) do
				assert(global.mirrors[mirror.unit_number],
					"NOT CONSISTENT: tower->mirror->tower relation does not exist")

				assert(global.mirrors[mirror.unit_number].tower.unit_number == tid,
					"NOT CONSISTENT: mirror points to multiple towers")

				assert(mirror.valid, "NOT CONSISTENT: tower->mirrors ref to invalid mirror")


				assert(global.towers[tid].tower.unit_number == tid, "NOT CONSISTENT: tower does not point to self")
			end
		end
	end


	for mid, mirror in pairs(global.mirrors) do
		assert(global.mirrors[mid].mirror.unit_number == mid, "NOT CONSISTENT: mirror does not point to self")
		assert(global.mirrors[mid].mirror.valid, "NOT CONSISTENT: mirror ref to invalid mirror")
	end
end


---@param entity LuaEntity
---@param tick uint
db.on_built_entity_callback = function(entity, tick)
	assert(entity, "Called back with nil entity")
	assert(tick, "Called back with nil tick")

	--game.print("Somthing was built")

	if global.mirrors == nil then
		db.buildTrees()
	else
		if entity.name == control_util.heliostat_mirror then
			-- Register this mirror
			global.mirrors[entity.unit_number] = { mirror = entity }

			-- Find a tower for this mirror
			local towers = control_util.find_towers_around_entity { entity = entity }

			local tower = db.closestTower { towers = towers, position = entity.position }

			if tower then
				-- Pick the closest tower out of the avaliable
				db.linkMirrorToTower {
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
			global.towers[entity.unit_number] = { tower = entity, mirrors = {} }

			-- if any are closer to this tower then their current, switch their target

			for _, mirror in pairs(mirrors) do
				-- will always succed if this mirror has no tower
				db.linkMirrorToTowerIfCloser { mirror = mirror, tower = entity }
			end


			db.on_tower_count_changed()
		end
	end

	--control_util.consistencyCheck()
end

return db
