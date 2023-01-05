local shared_util = {}

---@class Color
---@field r number?
---@field g number?
---@field b number?
---@field a number?

---@class Vector
---@field x number?
---@field y number?

---@class LuaEntity
---@field unit_number number
---@field position Vector
---@field surface LuaSurface
---@field name string
---@field destroy fun()
--- Insert fluid into this entity. Fluidbox is chosen automatically.
---@field insert_fluid fun(fluid: Fluid): number
---@field clear_fluid_inside fun()


---@class Fluid
---@field name 	string
--- Fluid prototype name of the fluid.
---@field amount number
--- Amount of the fluid.
---@field temperature number?

---@class LuaSurface
---@field index number
---@field morning number
---@field evening number
---@field dawn number
---@field dusk number
---@field daytime number
---@field ticks_per_day number
---@field find_entities_filtered fun(filters:table): LuaEntity[]
---@field create_entity fun(params:table): LuaEntity


---@class LuaGameScript
---@field surfaces LuaSurface[]
---@field print string
---@field get_player fun(num: number)

---@class LuaRendering
---@field draw_line fun(params: table)
---@field clear fun(mod:string)

---@class BuildEvent
---@field entity LuaEntity
---@field name string
---@field tick number

---@class Global
---@field mirror_tower {[number]: {beam:LuaEntity?, tower:LuaEntity, mirror:LuaEntity}}
---@field tower_mirrors {[number] : LuaEntity[]}
---@field mirrors {[number] : LuaEntity}
---@field towers {[number] : LuaEntity}
---@field surfaces table


---@class Data
---@field extend fun(data:table, other:table)

---@type Data
data = data

---@type table
defines = defines

shared_util.mod_prefix = "chcs-"
shared_util.solar_power_tower = shared_util.mod_prefix .. "solar-power-tower"
shared_util.heliostat_mirror = shared_util.mod_prefix .. "heliostat-mirror"

return shared_util
