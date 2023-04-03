local highlight = {}

local control_util = require "control-util"

highlight.cursor_stack_changed = function(event)
	-- Generate structure if not exists - remove eventually, but keep for backwards compat
	global.player_tower_rect = global.player_tower_rect or {}

	-- Player garenteed to exist- they caused the callback
	local stack = game.get_player(event.player_index).cursor_stack

	if stack and stack.valid_for_read and
		(control_util.isTower(stack.name) or stack.name == control_util.heliostat_mirror) then
		-- Ensure table exists, but do not overwrite - possible for this to be called multiple times in a row
		global.player_tower_rect[event.player_index] = global.player_tower_rect[event.player_index] or {}

		for tid, td in pairs(global.towers) do
			if not global.player_tower_rect[event.player_index][tid] then
				global.player_tower_rect[event.player_index][tid] = rendering.draw_rectangle {
					draw_on_ground = true,
					color = { r = 0.12 * 0.2, g = 0.457 * 0.2, b = 0.593 * 0.2, a = 0.1 },
					left_top = td.tower,
					right_bottom = td.tower,
					left_top_offset = {
						x = -control_util.tower_capture_radius,
						y = -control_util.tower_capture_radius
					},
					right_bottom_offset = {
						x = control_util.tower_capture_radius,
						y = control_util.tower_capture_radius
					},
					filled = true,
					players = { event.player_index },
					surface = td.tower.surface
				}
			end
		end
	elseif global.player_tower_rect[event.player_index] then
		-- Item in cursor not a solar entity, remove all rects

		for _, rect in pairs(global.player_tower_rect[event.player_index]) do
			rendering.destroy(rect)
		end
		global.player_tower_rect[event.player_index] = nil
	end
end

highlight.selected_entity_changed = function(event)
	local player = game.get_player(event.player_index)

	if player == nil then
		return
	end

	global.player_boxes = global.player_boxes or {}

	--cleanup old boxes
	if global.player_boxes[event.player_index] then
		global.player_boxes[event.player_index].destroy()
		global.player_boxes[event.player_index] = nil
	end
	--create new boxes?
	if player.selected and player.selected.name == control_util.heliostat_mirror then
		local td = global.mirrors[player.selected.unit_number]

		if td and td.tower and td.tower.valid then
			global.player_boxes[event.player_index] = player.selected.surface.create_entity {
				type = "highlight-box",
				name = "highlight-box",
				position = td.tower.position,
				bounding_box = td.tower.selection_box,
				render_player_index = event.player_index,
				time_to_live = 1000,
			}
		end
	end
end

return highlight
