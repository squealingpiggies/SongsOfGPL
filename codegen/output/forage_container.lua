local ffi = require("ffi")
---@class struct_forage_container
---@field resource FORAGE_RESOURCE 
---@field limit number 
---@field amount number 
---@field efficiency number 
ffi.cdef[[
    typedef struct {
        uint8_t resource;
        float limit;
        float amount;
        float efficiency;
    } forage_container;
]]
