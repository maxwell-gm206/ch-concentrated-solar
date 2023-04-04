local tower_laser = {}

local control_util = require "control-util"
local beams = require "control.beams"

function tower_laser.on_entity_damaged(event)
	--game.print("script triggered effect!")

	if event.effect_id == control_util.mod_prefix .. "sunlight-laser-damage" then
		local target = event.target_entity
		local tower = event.source_entity
		--game.get_player(1).create_local_flying_text { text = tower.fluidbox[1].temperature,
		--	position = target.position }

		if target and tower and #tower.fluidbox > 0 then
			local beam = beams.generateBeam {
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

function tower_laser.on_script_triggered_effect(event)
	--game.print("script triggered effect!")

	if event.effect_id == control_util.mod_prefix .. "sunlight-laser-damage" then
		local target = event.target_entity
		local tower = event.source_entity
		--game.get_player(1).create_local_flying_text { text = tower.fluidbox[1].temperature,
		--	position = target.position }

		if target and tower and #tower.fluidbox > 0 then
			local beam = beams.generateBeam {
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

return tower_laser
