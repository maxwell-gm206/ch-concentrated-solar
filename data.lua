--data.lua

require "prototypes.solar-energy"
require "prototypes.heliostat-mirror"
require "prototypes.solar-power-tower"
require "prototypes.solar-laser-tower"
require "prototypes.technology"
require "prototypes.recipe"
require "prototypes.item"
require "prototypes.achievement"
-- Increase entity size globally, to account for increased size on solar towers and shadows

data.raw["utility-constants"]["default"].entity_renderer_search_box_limits.bottom = 13
data.raw["utility-constants"]["default"].entity_renderer_search_box_limits.left = 8
