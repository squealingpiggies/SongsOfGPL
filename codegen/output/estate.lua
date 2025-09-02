local ffi = require("ffi")
----------estate----------


---estate: LSP types---

---Unique identificator for estate entity
---@class (exact) estate_id : table
---@field is_estate number
---@class (exact) fat_estate_id
---@field id estate_id Unique estate id
---@field savings number 
---@field balance_last_tick number 

---@class struct_estate
---@field savings number 
---@field inventory table<trade_good_id, number> 
---@field inventory_sold_last_tick table<trade_good_id, number> 
---@field inventory_bought_last_tick table<trade_good_id, number> 
---@field inventory_demanded_last_tick table<trade_good_id, number> 
---@field balance_last_tick number 
---@field throughput_boosts table<production_method_id, number> 
---@field input_efficiency_boosts table<production_method_id, number> 
---@field local_efficiency_boosts table<production_method_id, number> 
---@field output_efficiency_boosts table<production_method_id, number> 


ffi.cdef[[
void dcon_estate_set_savings(int32_t, float);
float dcon_estate_get_savings(int32_t);
void dcon_estate_resize_inventory(uint32_t);
void dcon_estate_set_inventory(int32_t, int32_t, float);
float dcon_estate_get_inventory(int32_t, int32_t);
void dcon_estate_resize_inventory_sold_last_tick(uint32_t);
void dcon_estate_set_inventory_sold_last_tick(int32_t, int32_t, float);
float dcon_estate_get_inventory_sold_last_tick(int32_t, int32_t);
void dcon_estate_resize_inventory_bought_last_tick(uint32_t);
void dcon_estate_set_inventory_bought_last_tick(int32_t, int32_t, float);
float dcon_estate_get_inventory_bought_last_tick(int32_t, int32_t);
void dcon_estate_resize_inventory_demanded_last_tick(uint32_t);
void dcon_estate_set_inventory_demanded_last_tick(int32_t, int32_t, float);
float dcon_estate_get_inventory_demanded_last_tick(int32_t, int32_t);
void dcon_estate_set_balance_last_tick(int32_t, float);
float dcon_estate_get_balance_last_tick(int32_t);
void dcon_estate_resize_throughput_boosts(uint32_t);
void dcon_estate_set_throughput_boosts(int32_t, int32_t, float);
float dcon_estate_get_throughput_boosts(int32_t, int32_t);
void dcon_estate_resize_input_efficiency_boosts(uint32_t);
void dcon_estate_set_input_efficiency_boosts(int32_t, int32_t, float);
float dcon_estate_get_input_efficiency_boosts(int32_t, int32_t);
void dcon_estate_resize_local_efficiency_boosts(uint32_t);
void dcon_estate_set_local_efficiency_boosts(int32_t, int32_t, float);
float dcon_estate_get_local_efficiency_boosts(int32_t, int32_t);
void dcon_estate_resize_output_efficiency_boosts(uint32_t);
void dcon_estate_set_output_efficiency_boosts(int32_t, int32_t, float);
float dcon_estate_get_output_efficiency_boosts(int32_t, int32_t);
void dcon_delete_estate(int32_t j);
int32_t dcon_create_estate();
bool dcon_estate_is_valid(int32_t);
void dcon_estate_resize(uint32_t sz);
uint32_t dcon_estate_size();
]]

---estate: FFI arrays---

---estate: LUA bindings---

DATA.estate_size = 300000
DCON.dcon_estate_resize_inventory(101)
DCON.dcon_estate_resize_inventory_sold_last_tick(101)
DCON.dcon_estate_resize_inventory_bought_last_tick(101)
DCON.dcon_estate_resize_inventory_demanded_last_tick(101)
DCON.dcon_estate_resize_throughput_boosts(251)
DCON.dcon_estate_resize_input_efficiency_boosts(251)
DCON.dcon_estate_resize_local_efficiency_boosts(251)
DCON.dcon_estate_resize_output_efficiency_boosts(251)
---@return estate_id
function DATA.create_estate()
    ---@type estate_id
    local i  = DCON.dcon_create_estate() + 1
    return i --[[@as estate_id]] 
end
---@param i estate_id
function DATA.delete_estate(i)
    assert(DCON.dcon_estate_is_valid(i - 1), " ATTEMPT TO DELETE INVALID OBJECT " .. tostring(i))
    return DCON.dcon_delete_estate(i - 1)
end
---@param func fun(item: estate_id) 
function DATA.for_each_estate(func)
    ---@type number
    local range = DCON.dcon_estate_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_is_valid(i) then func(i + 1 --[[@as estate_id]]) end
    end
end
---@param func fun(item: estate_id):boolean 
---@return table<estate_id, estate_id> 
function DATA.filter_estate(func)
    ---@type table<estate_id, estate_id> 
    local t = {}
    ---@type number
    local range = DCON.dcon_estate_size()
    for i = 0, range - 1 do
        if DCON.dcon_estate_is_valid(i) and func(i + 1 --[[@as estate_id]]) then t[i + 1 --[[@as estate_id]]] = i + 1 --[[@as estate_id]] end
    end
    return t
end

---@param estate_id estate_id valid estate id
---@return number savings 
function DATA.estate_get_savings(estate_id)
    return DCON.dcon_estate_get_savings(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_savings(estate_id, value)
    DCON.dcon_estate_set_savings(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_savings(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_savings(estate_id - 1)
    DCON.dcon_estate_set_savings(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory 
function DATA.estate_get_inventory(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory(estate_id, index, value)
    DCON.dcon_estate_set_inventory(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory_sold_last_tick 
function DATA.estate_get_inventory_sold_last_tick(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory_sold_last_tick(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory_sold_last_tick(estate_id, index, value)
    DCON.dcon_estate_set_inventory_sold_last_tick(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory_sold_last_tick(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory_sold_last_tick(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory_sold_last_tick(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory_bought_last_tick 
function DATA.estate_get_inventory_bought_last_tick(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory_bought_last_tick(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory_bought_last_tick(estate_id, index, value)
    DCON.dcon_estate_set_inventory_bought_last_tick(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory_bought_last_tick(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory_bought_last_tick(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory_bought_last_tick(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid
---@return number inventory_demanded_last_tick 
function DATA.estate_get_inventory_demanded_last_tick(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_inventory_demanded_last_tick(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_set_inventory_demanded_last_tick(estate_id, index, value)
    DCON.dcon_estate_set_inventory_demanded_last_tick(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index trade_good_id valid index
---@param value number valid number
function DATA.estate_inc_inventory_demanded_last_tick(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_inventory_demanded_last_tick(estate_id - 1, index - 1)
    DCON.dcon_estate_set_inventory_demanded_last_tick(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@return number balance_last_tick 
function DATA.estate_get_balance_last_tick(estate_id)
    return DCON.dcon_estate_get_balance_last_tick(estate_id - 1)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_set_balance_last_tick(estate_id, value)
    DCON.dcon_estate_set_balance_last_tick(estate_id - 1, value)
end
---@param estate_id estate_id valid estate id
---@param value number valid number
function DATA.estate_inc_balance_last_tick(estate_id, value)
    ---@type number
    local current = DCON.dcon_estate_get_balance_last_tick(estate_id - 1)
    DCON.dcon_estate_set_balance_last_tick(estate_id - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number throughput_boosts 
function DATA.estate_get_throughput_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_throughput_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_throughput_boosts(estate_id, index, value)
    DCON.dcon_estate_set_throughput_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_throughput_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_throughput_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_throughput_boosts(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number input_efficiency_boosts 
function DATA.estate_get_input_efficiency_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_input_efficiency_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_input_efficiency_boosts(estate_id, index, value)
    DCON.dcon_estate_set_input_efficiency_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_input_efficiency_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_input_efficiency_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_input_efficiency_boosts(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number local_efficiency_boosts 
function DATA.estate_get_local_efficiency_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_local_efficiency_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_local_efficiency_boosts(estate_id, index, value)
    DCON.dcon_estate_set_local_efficiency_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_local_efficiency_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_local_efficiency_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_local_efficiency_boosts(estate_id - 1, index - 1, current + value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid
---@return number output_efficiency_boosts 
function DATA.estate_get_output_efficiency_boosts(estate_id, index)
    assert(index ~= 0)
    return DCON.dcon_estate_get_output_efficiency_boosts(estate_id - 1, index - 1)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_set_output_efficiency_boosts(estate_id, index, value)
    DCON.dcon_estate_set_output_efficiency_boosts(estate_id - 1, index - 1, value)
end
---@param estate_id estate_id valid estate id
---@param index production_method_id valid index
---@param value number valid number
function DATA.estate_inc_output_efficiency_boosts(estate_id, index, value)
    ---@type number
    local current = DCON.dcon_estate_get_output_efficiency_boosts(estate_id - 1, index - 1)
    DCON.dcon_estate_set_output_efficiency_boosts(estate_id - 1, index - 1, current + value)
end

local fat_estate_id_metatable = {
    __index = function (t,k)
        if (k == "savings") then return DATA.estate_get_savings(t.id) end
        if (k == "balance_last_tick") then return DATA.estate_get_balance_last_tick(t.id) end
        return rawget(t, k)
    end,
    __newindex = function (t,k,v)
        if (k == "savings") then
            DATA.estate_set_savings(t.id, v)
            return
        end
        if (k == "balance_last_tick") then
            DATA.estate_set_balance_last_tick(t.id, v)
            return
        end
        rawset(t, k, v)
    end
}
---@param id estate_id
---@return fat_estate_id fat_id
function DATA.fatten_estate(id)
    local result = {id = id}
    setmetatable(result, fat_estate_id_metatable)
    return result --[[@as fat_estate_id]]
end
