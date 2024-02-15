local stru = {}
function stru.starts_with(str: string, start: string): boolean
    return str:sub(1, #start) == start
end
function stru.ends_with(str: string, ending: string): boolean
    return ending == "" or str:sub(-#ending) == ending
end
function stru.patternescape(str: string): (string, integer)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end
function stru.trim(str:string,chars:string|nil): string
    if not chars then return str:match("^[%s]*(.-)[%s]*$") end
    local s: string; local _n : any = stru.patternescape(chars)
    return str:match("^[" .. s .. "]*(.-)[" .. s .. "]*$")
end

return stru