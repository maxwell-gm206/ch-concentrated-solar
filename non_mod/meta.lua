---@meta



---@class MirrorTower
---@field mirror LuaEntity
---@field tower LuaEntity

---@class BuildEvent
---@field entity LuaEntity
---@field name string
---@field tick integer

---@class MirrorTowerRelation
---@field beam LuaEntity?
---@field tower LuaEntity?
---@field mirror LuaEntity
---Other towers in range, if there are any
---@field in_range {[integer]:LuaEntity}?


---@class Global
---@field mirrors {[integer]: MirrorTowerRelation}
---@field towers {mirrors:{[integer] : LuaEntity?}, tower:LuaEntity }
---@field player_boxes {[integer] : LuaEntity?}


---@class Global
global = {}
