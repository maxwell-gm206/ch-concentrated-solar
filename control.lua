--control.lua

local control_util = require "control-util"
local highlight    = require "control.highlight"
local nthtick      = require "control.nthtick"
local tower_laser  = require "control.tower-laser"
local ui           = require "control.ui"

local util         = require "util"

if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

script.on_init(control_util.on_init)


script.on_nth_tick(control_util.tower_update_interval, nthtick.on_nth_tick_tower_update)

if settings.global["ch-enable-beams"].value then
	script.on_nth_tick(control_util.beam_update_interval, nthtick.on_nth_tick_beam_update)
end

script.on_nth_tick(60, ui.update_guis)

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


script.on_event(
	{ defines.events.on_selected_entity_changed },
	highlight.selected_entity_changed
)



script.on_event(
	{ defines.events.on_script_trigger_effect },
	tower_laser.on_script_trigger_effect
)

script.on_event(
	defines.events.on_entity_damaged,
	tower_laser.on_entity_damaged
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

				control_util.removeMirrorFromTower { tower = global.mirror_tower[entity.unit_number].tower, mirror =
					entity }
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

--- Show tower bounding box

script.on_event(
	defines.events.on_player_cursor_stack_changed,
	highlight.cursor_stack_changed
)

--- APPLY SETTINGS CHANGES

script.on_event(defines.events.on_runtime_mod_setting_changed,
	function(param1)
		--- Disable beams, unless they should be enabled

		script.on_nth_tick(control_util.beam_update_interval, nil)

		if settings.global["ch-enable-beams"].value then
			script.on_nth_tick(control_util.beam_update_interval, nthtick.on_nth_tick_beam_update)
		end
	end
)

--- CUSTOM UI HOOKS

script.on_event(defines.events.on_gui_opened, ui.on_gui_opened)
script.on_event(defines.events.on_gui_closed, ui.on_gui_closed)
script.on_event(defines.events.on_gui_click, ui.on_gui_click)


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
end




rendering.clear("ch-concentrated-solar")
