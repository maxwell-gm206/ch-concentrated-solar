--control.lua

local control_util = require "control-util"

local util = require "util"



script.on_init(control_util.on_init)

script.on_nth_tick(control_util.sun_ticks,
	function(event)

		--control_util.delete_all_beams()

		if global.surfaces then

			-- Spawn sun beams on surfaces
			for sid, data in pairs(global.surfaces) do
				local time_info = control_util.calc_sun(data.surface)

				-- Start spawning beams for the day

				local stage = control_util.getSunStage(time_info)

				if (global.surfaces[sid].last_sun_stage ~= stage) then


					local ttl = control_util.sun_ticks + 1 --math.abs(data.surface.evening - data.surface.dawn) * data.surface.ticks_per_day

					--game.print("New sun stage " .. stage .. " with life of " .. ttl)
					for mid, mirror in pairs(global.mirrors) do
						-- Can only spawn sun rays on mirrors with towers
						if global.mirror_tower[mid] then

							local tower = global.mirror_tower[mid].tower

							local group = mid % control_util.mirror_groups

							if group <= stage then
								-- If our group is valued at the current sun stage, fire our laser
								global.mirror_tower[mid].beam = control_util.generateBeam
								{
									mirror = mirror,
									tower = tower,
									ttl = ttl
								}
								--elseif group > stage and global.mirror_tower[mid].beam then
								--	-- handle sudden timeskips, mostly from my debugging time set commands
								--	global.mirror_tower[mid].beam.destroy()
							end
						end
					end
					global.surfaces[sid].last_sun_stage = stage
				end
			end
		end
	end
)

script.on_nth_tick(control_util.fluid_ticks,
	function(event)

		--control_util.buildTrees()
		--control_util.consistencyCheck()


		-- Place fluid in towers
		if global.tower_mirrors ~= nil then

			for tid, mirrors in pairs(global.tower_mirrors) do
				local tower = global.towers[tid]

				if tower and tower.valid then


					local surface = tower.surface

					local time_info = control_util.calc_sun(surface)
					local sun = time_info.sun

					if sun > 0 and table_size(mirrors) > 0 then

						tower.insert_fluid {
							name = control_util.mod_prefix .. "solar-fluid",
							amount = table_size(mirrors) * sun * control_util.fluidPerTickPerMirror * control_util.fluid_ticks
						}

					end


					for _, mirror in pairs(mirrors) do
						rendering.draw_line {
							surface = surface,
							from = mirror.position,
							to = tower.position,
							color = { 1, 1, 0, 0.5 },
							width = 2,
							time_to_live = control_util.fluid_ticks + 1,
							only_in_alt_mode = true,
							draw_on_ground = true
						}

					end
				end
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
)
-- ON ENTITY ADDED

script.on_event(
	{
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
	},
	function(event)
		control_util.on_built_entity_callback(event.created_entity)
	end
)
script.on_event(
	{
		defines.events.script_raised_built,
		defines.events.script_raised_revive
	},
	function(event)
		control_util.on_built_entity_callback(event.entity)
	end
)

script.on_event(
	{ defines.on_selected_entity_changed },
	function(event)
		game.print("selected")
		if game.get_player(event.player_index).selected.name == control_util.solar_power_tower then
			game.print("selected solar tower")
		elseif event.last_entity.name == control_util.solar_power_tower then
			game.print("deselected solar tower")
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
			control_util.buildTrees()
		end

		local entity = event.entity



		if entity.name == control_util.heliostat_mirror then


			--game.print("Removing mirror")

			-- if this mirror is connected to a tower
			if global.mirror_tower[entity.unit_number] then
				-- remove this mirror from our tower's list
				-- and remove the reference from this mirror to the tower

				--game.print("Removing mirror from tower")

				control_util.removeMirrorFromTower { tower = global.mirror_tower[entity.unit_number].tower, mirror = entity }

			else

				--game.print("Removed mirror with no tower")
			end

			global.mirrors[entity.unit_number] = nil

		elseif global.towers[entity.unit_number] and control_util.isTower(entity.name) then
			-- Delete a tower from the database

			-- Remove every mirror -> tower relation
			mirrors = global.tower_mirrors[entity.unit_number]

			for _, mirror in pairs(mirrors) do
				control_util.removeMirrorFromTower { tower = entity, mirror = mirror, clearTowerMirrorsRelation = false }
			end

			-- Remove every tower -> mirror relation, return to consistency
			global.tower_mirrors[entity.unit_number] = nil
			global.towers[entity.unit_number] = nil

			-- Find new targets for orphaned mirrors
			local otherNearbyTowers = entity.surface.find_entities_filtered {
				name = tower_names,
				position = entity.position,
				radius = control_util.tower_capture_radius * 2
			}

			if table_size(otherNearbyTowers) > 1 then
				-- need at least 2 near towers for this to work

				for _, mirror in pairs(mirrors) do
					control_util.linkMirrorToTower {
						mirror = mirror,
						tower = control_util.closestTower { towers = otherNearbyTowers, position = mirror.position, ignore = entity }
					}
				end

			end



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

filters = {
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

rendering.clear("ch-concentrated-solar")
