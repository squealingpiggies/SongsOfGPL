local record stru
    starts_with: function(str: string, start: string): boolean
    ends_with:  function(str: string, ending: string): boolean
    patternescape: function(str: string): (string, integer)
    trim: function(str:string,chars:string|nil): string
end
stru.starts_with = function (str: string, start: string): boolean
    return str:sub(1, #start) == start
end
stru.ends_with = function (str: string, ending: string): boolean
    return ending == "" or str:sub(-#ending) == ending
end
stru.patternescape = function(str: string): (string, integer)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end
stru.trim = function(str:string,chars:string|nil): string
    if not chars then return str:match("^[%s]*(.-)[%s]*$") end
    local s: string; local _n : any = stru.patternescape(chars)
    return str:match("^[" .. s .. "]*(.-)[" .. s .. "]*$")
end

return stru