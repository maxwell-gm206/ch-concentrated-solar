--control.lua

local control_util = require "control-util"

local util = require "util"

if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

script.on_init(control_util.on_init)

local function on_nth_tick_beam_update(event)

	--control_util.consistencyCheck()

	--control_util.delete_all_beams()



	for i = 1, global.tower_beam_update_count or 1, 1 do

		global.last_updated_tower_beam = next(global.tower_mirrors, global.last_updated_tower_beam)

		if global.last_updated_tower_beam then
			local tower = global.towers[global.last_updated_tower_beam]
			local sid = tower.surface.index


			--log("Generating beams on " .. data.surface.name)

			-- Start spawning beams for the day

			local stage = math.floor(control_util.calc_sun(tower.surface) * control_util.sun_stages) - 1

			print("Generating beams around " .. global.last_updated_tower_beam)
			-- max possible time a beam could live for, to account for possible errors
			local ttl = math.abs(tower.surface.evening - tower.surface.dawn) * tower.surface.ticks_per_day

			--game.print("New sun stage " .. stage .. " with life of " .. ttl)
			for mid, mirror in pairs(global.tower_mirrors[global.last_updated_tower_beam]) do
				-- Can only spawn sun rays on mirrors with towers

				local group = (mid * 29) % control_util.mirror_groups

				if group <= stage and global.mirror_tower[mid].beam == nil then
					-- at this point, we dont need to worry about the old beams,
					-- as they have been destroyed
					global.mirror_tower[mid].beam = control_util.generateBeam
					{
						mirror = mirror,
						tower = tower,
						ttl = ttl
					}
				elseif group > stage and global.mirror_tower[mid].beam then
					global.mirror_tower[mid].beam.destroy()
					global.mirror_tower[mid].beam = nil

				end
				--
				--log("trying beam for mirror in group " .. group)
				--
				--	-- If our group is valued at the current sun stage, fire our laser
				--	global.mirror_tower[mid].beam = control_util.generateBeam
				--	{
				--		mirror = mirror,
				--		tower = tower,
				--		ttl = ttl
				--	}
				--	--elseif group > stage and global.mirror_tower[mid].beam then
				--	--	-- handle sudden timeskips, mostly from my debugging time set commands
				--	--	global.mirror_tower[mid].beam.destroy()
				--else
				--	global.mirror_tower[mid].beam = nil

			end
			--global.surfaces[sid].last_sun_stage = stage
			--end
		end
	end
end

local function on_nth_tick_tower_update(event)

	--control_util.buildTrees()
	--control_util.consistencyCheck()


	-- Place fluid in towers



	for i = 1, global.tower_update_count or 1, 1 do

		global.last_updated_tower = next(global.tower_mirrors, global.last_updated_tower)

		if global.last_updated_tower then
			local tid = global.last_updated_tower
			local mirrors = global.tower_mirrors[tid]


			--print("Updating tower " .. tid)

			local tower = global.towers[tid]

			if tower and tower.valid then
				--print("updating tower " .. tid)
				local sun = control_util.calc_sun(tower.surface)

				tower.clear_fluid_inside()

				if sun > 0 and table_size(mirrors) > 0 then
					local amount = control_util.fluidTempPerMirror * sun * table_size(mirrors)
					-- set to temprature and amount, as fluid turrets cannot display temprature
					tower.insert_fluid {
						name        = control_util.mod_prefix .. "solar-fluid",
						amount      = amount,
						temperature = amount
					}

					--game.get_player(1).create_local_flying_text {
					--	position = tower.position,
					--	text = control_util.fluidTempPerMirror
					--}

				end

				-- Show alternate in range towers for mirrors
				--if control_util.DEBUG_LINES then
				--	for mid, mirror in pairs(mirrors) do
				--		rendering.draw_line {
				--			surface = tower.surface,
				--			from = mirror.position,
				--			to = tower.position,
				--			color = { 0, 1, 1, 0.5 },
				--			width = 2,
				--			time_to_live = control_util.fluid_ticks + 1,
				--			only_in_alt_mode = true,
				--			draw_on_ground = true
				--		}
				--		if global.mirror_tower[mid].in_range then
				--			for a_tid, a_tower in pairs(global.mirror_tower[mid].in_range) do
				--				if a_tower and a_tower.valid then
				--					rendering.draw_line {
				--						surface = tower.surface,
				--						from = mirror.position,
				--						to = a_tower.position,
				--						color = { 1, 1, 0, 0.5 },
				--						width = 2,
				--						time_to_live = control_util.fluid_ticks + 1,
				--						only_in_alt_mode = true,
				--						draw_on_ground = true
				--					}
				--				end
				--			end
				--		end
				--	end
				--end
			else
				print("Deleting tower " .. tid)
				control_util.notify_tower_invalid(tid)
			end

			--for mid, data in pairs(global.mirror_tower) do
			--	rendering.draw_line {
			--		surface = data.mirror.surface,
			--		from = data.mirror.position,
			--		to = data.tower.position,
			--		color = { 0, 1, 1, 0.5 },
			--		width = 2,
			--		time_to_live = control_util.ticks + 1,
			--		only_in_alt_mode = true,
			--		draw_on_ground = true
			--	}
			--end

		end
	end
end

script.on_nth_tick(control_util.tower_update_interval, on_nth_tick_tower_update)

script.on_nth_tick(control_util.beam_update_interval, on_nth_tick_beam_update)

-- ON ENTITY ADDED
script.on_event(
	{
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
	},
	function(event)
		control_util.on_built_entity_callback(event.created_entity, event.tick)
	end
)
script.on_event(
	{
		defines.events.script_raised_built,
		defines.events.script_raised_revive
	},
	function(event)
		control_util.on_built_entity_callback(event.entity, event.tick)
	end
)

boxes = {}

script.on_event(
	{ defines.events.on_selected_entity_changed },
	function(event)

		local player = game.get_player(event.player_index)

		if player == nil then
			return
		end

		--cleanup old boxes
		if boxes[event.player_index] then
			for _, box in pairs(boxes[event.player_index]) do
				box.destroy()
			end
			boxes[event.player_index] = nil
		end
		--create new boxes?
		if player.selected and control_util.isTower(player.selected.name)
			and global.tower_mirrors[player.selected.unit_number] then

			-- Create a single box for the entire catchment area of the tower
			boxes[event.player_index] = {
				[player.selected.unit_number] = player.selected.surface.create_entity {
					type = "highlight-box",
					name = "highlight-box",
					position = player.selected.position,

					bounding_box = control_util.get_tower_catch_area { tower = player.selected,
						radius = control_util.tower_capture_radius },

					render_player_index = event.player_index,
					time_to_live = 500,
				}
			}

		elseif player.selected and player.selected.name == control_util.heliostat_mirror then

			local td = global.mirror_tower[player.selected.unit_number]

			if td and td.tower and td.tower.valid then
				boxes[event.player_index] = { [td.tower.unit_number] = player.selected.surface.create_entity {
					type = "highlight-box",
					name = "highlight-box",
					position = td.tower.position,
					bounding_box = td.tower.selection_box,
					render_player_index = event.player_index,
					time_to_live = 500,
				} }
			end
		end
	end
)



script.on_event(
	{ defines.events.on_script_trigger_effect },
	function(event)

		--game.print("script triggered effect!")

		if event.effect_id == control_util.mod_prefix .. "sunlight-laser-damage" then
			local target = event.target_entity
			local tower = event.source_entity
			--game.get_player(1).create_local_flying_text { text = tower.fluidbox[1].temperature,
			--	position = target.position }

			if target and tower and #tower.fluidbox > 0 then
				local beam = control_util.generateBeam {
					tower = tower,
					mirror = target,
					ttl = control_util.solar_laser_ticks_between_shots - 1,
					mirrored = false,
					blend = 1,
				}
				beam.set_beam_target(target)

			else
				--game.print("Turret it empty!")
			end

		end

	end
)

script.on_event(defines.events.on_entity_damaged,
	function(event)
		-- deal extra damage based on solar temprature

		if event.cause and control_util.isTower(event.cause.name) then
			local ammo = event.cause.fluidbox[1] or event.cause.fluidbox[2]

			event.entity.health = event.entity.health + event.final_damage_amount

			local newDamage = event.final_damage_amount * ammo.temperature / 600

			event.entity.health = event.entity.health - newDamage

			print("laser turret dealt " .. newDamage .. " from " .. event.original_damage_amount)

		end
	end)


script.on_event(defines.events.on_runtime_mod_setting_changed,
	function(param1)

		script.on_nth_tick(control_util.tower_update_interval, nil)
		script.on_nth_tick(control_util.beam_update_interval, nil)

		control_util.update_settings()

		control_util.on_tower_count_changed()

		script.on_nth_tick(control_util.tower_update_interval, on_nth_tick_tower_update)
		script.on_nth_tick(control_util.beam_update_interval, on_nth_tick_beam_update)
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
			control_util.buildTrees()
		end

		local entity = event.entity


		--game.print("entity " .. entity.unit_number .. " destroyed")

		if entity.name == control_util.heliostat_mirror then


			--game.print("Removing mirror")

			-- if this mirror is connected to a tower
			if global.mirror_tower[entity.unit_number] and global.mirror_tower[entity.unit_number].tower then
				-- remove this mirror from our tower's list
				-- and remove the reference from this mirror to the tower

				--game.print("Removing mirror from tower")

				control_util.removeMirrorFromTower { tower = global.mirror_tower[entity.unit_number].tower, mirror = entity }

			else

				--game.print("Removed mirror with no tower")
			end

			global.mirrors[entity.unit_number] = nil

		elseif global.towers[entity.unit_number] and control_util.isTower(entity.name) then
			control_util.notify_tower_invalid(entity.unit_number)
		end

		--game.print("entity " .. entity.unit_number .. " destroyed")

		--control_util.consistencyCheck()
	end
)

--script.on_event(
--	{
--		defines.events.on_player_mined_entity,
--	},
--	function(event)
--
--	end
--)
--
--script.on_event(
--	{
--		defines.events.on_robot_mined,
--	},
--	function(event)
--
--	end
--)

--- APPLY FILTERS
do
	local filters = {
		{ filter = "name", name = control_util.heliostat_mirror },
	}

	for tower, is in pairs(is_tower) do
		if is then
			table.insert(filters, { filter = "name", name = tower })
		end
	end

	script.set_event_filter(defines.events.on_built_entity, filters)
	script.set_event_filter(defines.events.on_robot_built_entity, filters)
	script.set_event_filter(defines.events.on_robot_pre_mined, filters)
	script.set_event_filter(defines.events.on_pre_player_mined_item, filters)
	--script.set_event_filter(defines.events.on_entity_damaged, {
	--	{ filter = "damage-type", damage_type = "laser" }
	--})
end
rendering.clear("ch-concentrated-solar")
