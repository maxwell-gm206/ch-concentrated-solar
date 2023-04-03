-- Sync all mirror relations into one table

local o_mirrors = global.mirrors

global.mirrors = global.mirror_towers or {}

if o_mirrors then
	for mid, mirror_entity in pairs(o_mirrors) do
		if mirror_entity then
			if not global.mirrors[mid] then
				global.mirrors[mid] = { mirror = mirror_entity, in_range = {} }
			else
				global.mirrors[mid].mirror = mirror_entity
			end
		end
	end
end

-- sync all tower relations into one table
local o_towers = global.towers

global.towers = {}

if o_towers then
	for tid, tower in pairs(o_towers) do
		global.towers[tid] = { tower = tower, mirrors = {} }
	end
end

if global.tower_mirrors then
	for tid, mirrors in pairs(global.tower_mirrors) do
		global.towers[tid].mirrors = mirrors
	end
end

for tid, td in pairs(global.towers) do
	for mid, e in pairs(td.mirrors) do
		if global.mirrors[mid] then
			global.mirrors[mid].tower = td.tower
			global.mirrors[mid].mirror = e
		else
			global.mirrors[mid] = { mirror = e, tower = td.tower, in_range = {} }
		end
	end
end


-- No longer used
global.tower_mirrors = nil
global.mirror_tower = nil
global.mirror_towers = nil
global.beam_mirrors = nil
global.surfaces = nil
