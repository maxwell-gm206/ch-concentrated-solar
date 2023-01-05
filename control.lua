--control.lua

control_util = require "shared-util"

util = require "util"

script.on_event(defines.events.on_player_changed_position,
	function(event)
		local player = game.get_player(event.player_index) -- get the player that moved
		-- if they're wearing our armor
		if player.character and player.get_inventory(defines.inventory.character_armor).get_item_count("fire-armor") >= 1 then
			-- create the fire where they're standing
			player.surface.create_entity { name = "fire-flame", position = player.position, force = "neutral" }
		end
	end
)

local function inv_lerp(a, b, v)
	return math.max(math.min((v - a) / (b - a), 1), 0)
end

local function calc_sun(surface)
	if surface.daytime > surface.evening then
		--game.print("morning!")
		return { sun = inv_lerp(surface.morning, surface.dawn, surface.daytime), moring = true }
	else
		--game.print("evening!")
		return { sun = inv_lerp(surface.evening, surface.dusk, surface.daytime), morning = false }
	end
end

local function getSunStage(time_info)

	return math.floor(time_info.sun * sun_stages) - 1
end

local function distance_to_tower(mirror)

	return util.distance(mirror.position, global.mirror_tower[mirror.unit_number].position)

end

local ticks = 60
local mirror_kw = 100
local fluid_kj = 1000
local fluidPerTickPerMirror = mirror_kw / fluid_kj / 60
local tower_capture_radius = 40
sun_stages = 20
-- Number of groups of mirrors that will have sun rays spawned on them
local mirror_groups = 100
-- Number of sets of mirrors, used to spawn sun-rays


local function generateBeam(mirror, tower, ttl)

	global.mirror_tower[mirror.unit_number].beam = mirror.surface.create_entity {
		position = mirror.position,
		name = control_util.mod_prefix .. "mirred-solar-beam",
		raise_built = false,
		time_to_live = ttl,
		target_position = { tower.position.x, tower.position.y - 13 },
		source_position = mirror.position
	}

end

local function linkMirrorToTower(tower, mirror)

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

	time = calc_sun(mirror.surface)

	stage = getSunStage(time)

	if mid % mirror_groups < stage then
		generateBeam(mirror, tower, (mirror.surface.daytime - mirror.surface.evening) * mirror.surface.ticks_per_day)
	end


end

local function cleanTrees()
	if global.mirror_tower then
		for key, value in pairs(global.mirror_tower) do
			if value.beam then

				value.beam.destroy()
			end
		end
	end

end

local function buildTrees()
	--game.print("generating mirror links")

	cleanTrees()

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
					radius = tower_capture_radius
				}
				global.tower_mirrors[tower.unit_number] = {}

				for _, mirror in ipairs(mirrors) do
					if global.mirror_tower[mirror.unit_number] == nil then

						linkMirrorToTower(tower, mirror)

						global.mirrors[mirror.unit_number] = mirror

					end
				end



				global.towers[tower.unit_number] = tower

				--game.print(#global.tower_mirrors[tower.unit_number])
			end
		end
	end
end

local function removeMirrorFromTower(tower, mirror, remove_mirror_from_tower_links)

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

script.on_init(buildTrees)

script.on_nth_tick(ticks, function(event)
	--buildTrees()
	--buildTrees()

	--game.print("iterating!")


	if global.surfaces then
		for sid, data in pairs(global.surfaces) do
			time_info = calc_sun(data.surface)
			local sun = time_info.sun

			if time_info.moring and sun < 0.9 then
				-- Start spawning beams for the day

				local stage = getSunStage(time_info)


				if (global.surfaces[sid].last_sun_stage ~= stage) then



					local ttl = math.abs(data.surface.evening - data.surface.dawn) * data.surface.ticks_per_day

					game.print("New sun stage " .. stage .. " with life of " .. ttl)
					for mid, mirror in pairs(global.mirrors) do
						-- Can only spawn sun rays on mirrors with towers
						if global.mirror_tower[mid] then

							local tower = global.mirror_tower[mid].tower

							local group = mid % mirror_groups

							if group <= stage and group > global.surfaces[sid].last_sun_stage then
								-- If our group is valued at the current sun stage, fire our laser
								generateBeam(mirror, tower, ttl)
							elseif group > stage and global.mirror_tower[mid].beam then
								-- handle sudden timeskips, mostly from my debugging time set commands
								global.mirror_tower[mid].beam.destroy()
							end
						end
					end


					global.surfaces[sid].last_sun_stage = stage

				end

			end
		end



		--game.print("Ticked")

		--game.print(serpent.block(global.surfaces))

		if global.tower_mirrors ~= nil then
			--surface.ticks_per_day = 25000
			--game.print(sun)
			--game.print("has towers")

			--for i = 1, #entities do
			--	game.print(serpent.block(entities[i]))
			--end

			for tid, mirrors in pairs(global.tower_mirrors) do
				local tower = global.towers[tid]

				--game.print(tower.position)

				local surface = tower.surface

				local time_info = calc_sun(surface)
				local sun = time_info.sun





				--game.print("asdf")


				--	game.get_player(1).create_local_flying_text {
				--		text = { tower.temperature },
				--		position = { tower.position.x, tower.position.y - 0.5 },
				--		color = nil,
				--		time_to_live = 20,
				--		speed = 1.0,
				--	}

				if sun > 0 and #mirrors > 0 then

					tower.insert_fluid {
						name = control_util.mod_prefix .. "solar-fluid",
						amount = #mirrors * sun * fluidPerTickPerMirror * ticks
					}

				end

				--for _, mirror in ipairs(mirrors) do

				--game.get_player(1).create_local_flying_text {
				--	text = { tower.unit_number },
				--	position = tower.position,
				--	color = nil,
				--	time_to_live = 20,
				--	speed = 1.0,
				--}
				for _, mirror in pairs(mirrors) do
					rendering.draw_line {
						surface = surface,
						from = mirror.position,
						to = tower.position,
						color = { 1, 1, 0 },
						width = 2,
						time_to_live = ticks + 1,
						only_in_alt_mode = true,
						draw_on_ground = true
					}

				end
			end

			--tower.temperature = tower.temperature + surface.solar_power_multiplier * sun * tempPerTick / ticks
			--end
		end
	end
	--if global.mirror_tower ~= nil then
	--	for mirror_num, tower in pairs(global.mirror_tower) do
	--		--
	--		mirror = global.mirrors[mirror_num]
	--		surface = mirror.surface



	--game.get_player(1).create_local_flying_text {
	--	text = { mirror.orientation },
	--	position = mirror.position,
	--	color = nil,
	--	time_to_live = 20,
	--	speed = 1.0,
	--}

	--		local sun = calc_sun(surface)
	--		if sun > 0 then
	--
	--			contents = mirror.get_fluid_count(control_util.mod_prefix .. "solar-fluid")
	--
	--
	--			--rendering.draw_line {
	--			--	surface = surface,
	--			--	from = mirror.position,
	--			--	to = tower.position,
	--			--	color = { 1, 1, 0 },
	--			--	width = 2,
	--			--	time_to_live = 10,
	--			--	only_in_alt_mode = true,
	--			--	draw_on_ground = true
	--			--}
	--
	--			if contents > 0 then
	--				mirror.clear_fluid_inside()
	--
	--				tower.insert_fluid { name = control_util.mod_prefix .. "solar-fluid", amount = contents * sun }
	--			end
	--
	--		end
	--		--rendering.draw_line {
	--		--	surface = surface,
	--		--	from = global.mirrors[mirror_num].position,
	--		--	to = tower.position,
	--		--	color = { 0, 1, 1 },
	--		--	width = 2
	--		--}
	--	end
	--end
end
)
-- ON ENTITY ADDED

script.on_event(
	{
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
		defines.events.script_raised_built,
		defines.events.script_raised_revive
	},
	function(event)

		--game.print("Somthing was built")

		if global.mirror_tower == nil then
			buildTrees()

		else
			local entity = event.created_entity
			local surface = entity.surface

			if entity.name == control_util.heliostat_mirror then
				-- Register this mirror
				global.mirrors[entity.unit_number] = entity

				-- Find a tower for this mirror

				local towers = surface.find_entities_filtered {
					name = control_util.solar_power_tower,
					position = entity.position,
					radius = tower_capture_radius
				}

				if towers ~= nil and #towers > 0 then
					linkMirrorToTower(towers[1], entity)
					--global.mirror_tower[entity.unit_number] = towers[1]
					--table.insert(global.tower_mirrors[towers[1].unit_number], entity)

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
					radius = tower_capture_radius
				}

				--added_mirrors = {}
				global.towers[entity.unit_number] = entity
				global.tower_mirrors[entity.unit_number] = {}

				for _, mirror in ipairs(mirrors) do

					if global.mirror_tower[mirror.unit_number] == nil then
						--table.insert(added_mirrors, mirror)
						linkMirrorToTower(entity, mirror)
					end

				end

				-- if any are closer to this tower then their current, switch their target


				--global.tower_mirrors[entity.unit_number] = added_mirrors
			end
		end
	end
)
-- ON ENTITY REMOVED
script.on_event(
	{
		defines.events.on_pre_player_mined_item,
		defines.events.on_robot_pre_mined,
		defines.events.on_entity_died,
		defines.events.script_raised_destroy
	},
	function(event)

		--game.print("Somthing was removed")
		if global.tower_mirrors == nil then
			buildTrees()
		end

		local entity = event.entity

		if global.mirrors[entity.unit_number] ~= nil and entity.name == control_util.heliostat_mirror then
			global.mirrors[entity.unit_number] = nil

			if global.mirror_tower[entity.unit_number] ~= nil then
				-- remove this mirror from our tower's list
				-- and remove the reference from this mirror to the tower

				removeMirrorFromTower(global.mirror_tower[entity.unit_number].tower, entity, true)


			end

		elseif global.towers[entity.unit_number] ~= nil and entity.name == control_util.solar_power_tower then


			for _, mirror in ipairs(global.tower_mirrors[entity.unit_number]) do

				removeMirrorFromTower(entity, mirror, false)
			end

			global.tower_mirrors[entity.unit_number] = nil

		end
	end
)
script.set_event_filter(defines.events.on_built_entity,
	{ { filter = "name", name = control_util.heliostat_mirror },
		{ filter = "name", name = control_util.solar_power_tower } })


rendering.clear("ch-concentrated-solar")
