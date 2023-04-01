local nthtick = {}

local control_util = require "control-util"
local beams = require "control.beams"

nthtick.on_nth_tick_beam_update = function(event)
	--control_util.consistencyCheck()

	--beams.delete_all_beams()

	if not global.tower_mirrors[global.last_updated_tower_beam] then
		global.last_updated_tower_beam = nil
	end

	for i = 1, global.tower_beam_update_count or 1, 1 do
		global.last_updated_tower_beam = next(global.tower_mirrors, global.last_updated_tower_beam)

		if global.last_updated_tower_beam then
			local tower = global.towers[global.last_updated_tower_beam]
			local sid = tower.surface.index

			--log("Generating beams on " .. data.surface.name)

			-- Start spawning beams for the day

			local stage = math.floor(control_util.calc_sun(tower.surface) * control_util.sun_stages) - 1

			--print("Generating beams around " .. global.last_updated_tower_beam)
			-- max possible time a beam could live for, to account for possible errors
			local ttl = math.abs(tower.surface.evening - tower.surface.dawn) * tower.surface.ticks_per_day

			--game.print("New sun stage " .. stage .. " with life of " .. ttl)
			for mid, mirror in pairs(global.tower_mirrors[global.last_updated_tower_beam]) do
				-- Can only spawn sun rays on mirrors with towers

				local group = (mid * 29) % control_util.mirror_groups

				if group <= stage and global.mirror_tower[mid].beam == nil then
					-- at this point, we dont need to worry about the old beams,
					-- as they have been destroyed
					global.mirror_tower[mid].beam = beams.generateBeam
						{
							mirror = mirror,
							tower = tower,
							ttl = ttl
						}
				elseif group > stage and global.mirror_tower[mid].beam then
					global.mirror_tower[mid].beam.destroy()
					global.mirror_tower[mid].beam = nil
				end
			end
		end
	end
end

nthtick.on_nth_tick_tower_update = function(event)
	--control_util.buildTrees()
	--control_util.consistencyCheck()

	-- Place fluid in towers

	if not global.tower_mirrors[global.last_updated_tower] then
		global.last_updated_tower = nil
	end

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
					-- set to temprature and amount, as fluid turrets cannot display temperature
					tower.insert_fluid {
						name        = control_util.mod_prefix .. "solar-fluid",
						amount      = amount,
						temperature = amount
					}
				end
			else
				--print("Deleting tower " .. tid)
				control_util.notify_tower_invalid(tid)
			end
		end
	end
end

return nthtick
