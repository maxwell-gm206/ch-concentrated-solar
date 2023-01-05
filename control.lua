--control.lua

control_util = require "control-util"

util = require "util"



script.on_init(control_util.buildTrees)

script.on_nth_tick(control_util.ticks,
	function(event)
		--buildTrees()

		if global.surfaces then
			for sid, data in pairs(global.surfaces) do
				time_info = control_util.calc_sun(data.surface)
				local sun = time_info.sun

				if time_info.moring and sun < 0.9 then
					-- Start spawning beams for the day

					local stage = control_util.getSunStage(time_info)


					if (global.surfaces[sid].last_sun_stage ~= stage) then


						local ttl = math.abs(data.surface.evening - data.surface.dawn) * data.surface.ticks_per_day

						game.print("New sun stage " .. stage .. " with life of " .. ttl)
						for mid, mirror in pairs(global.mirrors) do
							-- Can only spawn sun rays on mirrors with towers
							if global.mirror_tower[mid] then

								local tower = global.mirror_tower[mid].tower

								local group = mid % control_util.mirror_groups

								if group <= stage and group > global.surfaces[sid].last_sun_stage then
									-- If our group is valued at the current sun stage, fire our laser
									control_util.generateBeam(mirror, tower, ttl)
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

			if global.tower_mirrors ~= nil then

				for tid, mirrors in pairs(global.tower_mirrors) do
					local tower = global.towers[tid]

					local surface = tower.surface

					local time_info = control_util.calc_sun(surface)
					local sun = time_info.sun

					if sun > 0 and #mirrors > 0 then

						tower.insert_fluid {
							name = control_util.mod_prefix .. "solar-fluid",
							amount = #mirrors * sun * control_util.fluidPerTickPerMirror * control_util.ticks
						}

					end


					for _, mirror in pairs(mirrors) do
						rendering.draw_line {
							surface = surface,
							from = mirror.position,
							to = tower.position,
							color = { 1, 1, 0 },
							width = 2,
							time_to_live = control_util.ticks + 1,
							only_in_alt_mode = true,
							draw_on_ground = true
						}

					end
				end


			end
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

		if global.mirrors[entity.unit_number] ~= nil and entity.name == control_util.heliostat_mirror then
			global.mirrors[entity.unit_number] = nil

			if global.mirror_tower[entity.unit_number] ~= nil then
				-- remove this mirror from our tower's list
				-- and remove the reference from this mirror to the tower

				control_util.removeMirrorFromTower(global.mirror_tower[entity.unit_number].tower, entity, true)


			end

		elseif global.towers[entity.unit_number] ~= nil and entity.name == control_util.solar_power_tower then


			for _, mirror in ipairs(global.tower_mirrors[entity.unit_number]) do

				control_util.removeMirrorFromTower(entity, mirror, false)
			end

			global.tower_mirrors[entity.unit_number] = nil

		end
	end
)
script.set_event_filter(defines.events.on_built_entity,
	{ { filter = "name", name = control_util.heliostat_mirror },
		{ filter = "name", name = control_util.solar_power_tower } })


rendering.clear("ch-concentrated-solar")
