--control.lua

local control_util = require "control-util"
local highlight    = require "control.highlight"
local nthtick      = require "control.nthtick"
local ui           = require "control.ui"
local db           = require "control.database"

require "control.interface"

if script.active_mods["gvv"] then
	require("__gvv__.gvv")()
end

--- Setup other mods
function setup_other_mods()
	-- Warp drive machine compat - heliostat mirrors are a weird entity
	if remote.interfaces["WDM"] and remote.interfaces["WDM"].add_building_to_tile_color then
		-- Add to solar tiles
		remote.call("WDM", "add_building_to_tile_color", "blue", control_util.heliostat_mirror)
	end
end

script.on_init(function()
	db.on_init()

	setup_other_mods()
end)

script.on_configuration_changed(setup_other_mods)

script.on_nth_tick(control_util.tower_update_interval, nthtick.on_nth_tick_tower_update)

if settings.global["ch-enable-beams"].value then
	script.on_nth_tick(control_util.beam_update_interval, nthtick.on_nth_tick_beam_update)
end

script.on_nth_tick(60, ui.update_guis)

-- ON ENTITY ADDED
script.on_event(
	{
		defines.events.script_raised_built,
		defines.events.script_raised_revive,
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
		defines.events.on_space_platform_built_entity,
	},
	function(event)
		db.on_built_entity_callback(event.entity)
	end
)


script.on_event(
	{ defines.events.on_selected_entity_changed },
	highlight.selected_entity_changed
)

-- ON ENTITY REMOVED

script.on_event(
	{
		defines.events.on_pre_player_mined_item,
		defines.events.on_robot_mined_entity,
		defines.events.on_space_platform_mined_entity,
		defines.events.on_entity_died,
		defines.events.script_raised_destroy
	},
	function(event)
		-- game.print("Something was removed")
		if storage.towers == nil then
			db.buildTrees()
		end

		local eid = event.entity.unit_number

		if eid == nil then
			return
		end

		if db.on_destroyed_entity_callback(eid) then
			ui.update_guis()
		end
	end
)

script.on_event(
	{ defines.events.on_object_destroyed },
	function(event)
		if event.type == defines.target_type.entity then
			if storage.towers == nil then
				db.build_trees()
			end

			if db.on_destroyed_entity_callback(event.useful_id) then
				ui.update_guis()
			end
		end
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
	script.set_event_filter(defines.events.on_space_platform_built_entity, filters)
	script.set_event_filter(defines.events.script_raised_revive, filters)
	script.set_event_filter(defines.events.script_raised_built, filters)

	script.set_event_filter(defines.events.on_robot_mined_entity, filters)
	script.set_event_filter(defines.events.on_pre_player_mined_item, filters)
	script.set_event_filter(defines.events.on_space_platform_mined_entity, filters)
	script.set_event_filter(defines.events.on_entity_died, filters)
	script.set_event_filter(defines.events.script_raised_destroy, filters)
end


rendering.clear("ch-concentrated-solar")
