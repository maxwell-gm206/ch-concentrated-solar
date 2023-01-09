---@meta



---@class MirrorTower
---@field mirror LuaEntity
---@field tower LuaEntity

---@class BuildEvent
---@field entity LuaEntity
---@field name string
---@field tick integer

---@class MirrorTowerRelation
---@field beam LuaEntity
---@field tower LuaEntity
---@field mirror LuaEntity
---Other towers in range, if there are any
---@field in_range {[integer]:LuaEntity}?


---@class Global
---@field mirror_tower {[integer]: MirrorTowerRelation}
---@field tower_mirrors {[integer] : {[integer] : LuaEntity}}
---@field mirrors {[integer] : LuaEntity?}
---@field towers {[integer] : LuaEntity?}
---@field surfaces table


---@class Global
global = {}
