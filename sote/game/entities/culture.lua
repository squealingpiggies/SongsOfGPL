local cl = {}

---@class CultureGroup
---@field name string
---@field r number
---@field g number
---@field b number
---@field language Language
---@field view_on_treason number
---@field new fun(self:CultureGroup):CultureGroup

---@class Culture
---@field name string
---@field r number
---@field g number
---@field b number
---@field language Language
---@field culture_group CultureGroup
---@field new fun(self:Culture, group:CultureGroup):Culture
---@field traditional_units table<string, number> -- Defines "traditional" ratios for units recruited from this culture.
---@field traditional_militarization number A fraction of the society that cultures will try to put in military
---@field limit_interracial boolean?
---@field limit_interculture boolean?
---@field limit_interfaith boolean?

---@class CultureGroup
cl.CultureGroup = {}
cl.CultureGroup.__index = cl.CultureGroup
---@return CultureGroup
function cl.CultureGroup:new()
	---@type CultureGroup
	local o = {}

	o.r = love.math.random()
	o.g = love.math.random()
	o.b = love.math.random()
	o.language = require "game.entities.language".random()
	o.name = o.language:get_random_culture_name()

	o.view_on_treason = love.math.random(-20, 20)

	setmetatable(o, cl.CultureGroup)
	return o
end

---@class Culture
cl.Culture = {}
cl.Culture.__index = cl.Culture
---@param group CultureGroup
---@return Culture
function cl.Culture:new(group)
	---@type Culture
	local o = {}

	o.r = group.r
	o.g = group.g
	o.b = group.b
	o.culture_group = group
	o.language = group.language
	o.name = o.language:get_random_culture_name()
	o.traditional_units = {}
	o.traditional_militarization = 0.1
	if math.random() < 4/5 then
		o.limit_interracial = math.random() < 1/2
	end
	if math.random() < 4/5 then
		o.limit_interculture = math.random() < 1/2
	end
	if math.random() < 4/5 then
		o.limit_interfaith = math.random() < 1/2
	end

	setmetatable(o, cl.Culture)
	return o
end

---@param seperator string?
---@param initial string?
---@return string
function cl.Culture:get_desc(seperator,initial)
	local r = ""
	if initial ~= nil then
		r = initial
	end
	if seperator == nil then
		seperator = " "
	end
	if self.culture_group.view_on_treason < -15 then
		r = r .. seperator .. "Honorable"
	elseif self.culture_group.view_on_treason < -10 then
		r = r .. seperator .. "Reliable"
	elseif self.culture_group.view_on_treason < -5 then
		r = r .. seperator .. "Honest"
	elseif self.culture_group.view_on_treason < 5 then
		r = r .. seperator .. "Dishonest"
	elseif self.culture_group.view_on_treason < 10 then
		r = r .. seperator .. "Unreliable"
	elseif self.culture_group.view_on_treason > 15 then
		r = r .. seperator .. "Deceptive"
	end
	if self.limit_interracial ~= nil then
		r = r .. seperator .. "Racial "
		if self.limit_interracial == true then
			r = r .. "Isolationists"
		else
			r = r .. "Exclusionists"
		end
	end
	if self.limit_interculture ~= nil then
		r = r .. seperator .. "Cultural "
		if self.limit_interculture == true then
			r = r .. "Isolationists"
		else
			r = r .. "Exclusionists"
		end
	end
	if self.limit_interfaith ~= nil then
		r = r .. seperator .. "Religious "
		if self.limit_interfaith == true then
			r = r .. "Isolationists"
		else
			r = r .. "Exclusionists"
		end
	end
	return r
end

return cl
