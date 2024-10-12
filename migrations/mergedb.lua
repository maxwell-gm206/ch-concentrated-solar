-- Sync all mirror relations into one table

local o_mirrors = storage.mirrors

storage.mirrors = storage.mirror_towers or {}

if o_mirrors then
	for mid, mirror_entity in pairs(o_mirrors) do
		if mirror_entity then
			if not storage.mirrors[mid] then
				storage.mirrors[mid] = { mirror = mirror_entity, in_range = {} }
			else
				storage.mirrors[mid].mirror = mirror_entity
			end
		end
	end
end

-- sync all tower relations into one table
local o_towers = storage.towers

storage.towers = {}

if o_towers then
	for tid, tower in pairs(o_towers) do
		storage.towers[tid] = { tower = tower, mirrors = {} }
	end
end

if storage.tower_mirrors then
	for tid, mirrors in pairs(storage.tower_mirrors) do
		storage.towers[tid].mirrors = mirrors
	end
end

for tid, td in pairs(storage.towers) do
	for mid, e in pairs(td.mirrors) do
		if storage.mirrors[mid] then
			storage.mirrors[mid].tower = td.tower
			storage.mirrors[mid].mirror = e
		else
			storage.mirrors[mid] = { mirror = e, tower = td.tower, in_range = {} }
		end
	end
end


-- No longer used
storage.tower_mirrors = nil
storage.mirror_tower = nil
storage.mirror_towers = nil
storage.beam_mirrors = nil
storage.surfaces = nil
