local JOBTYPE = require "game.raws.job_types"

---@class Race
---@field name string
---@field icon string
---@field description string
---@field r number
---@field g number
---@field b number
---@field carrying_capacity_weight number
---@field fecundity number
---@field spotting number How good is this unit at scouting
---@field visibility number How visible is this unit in battles
---@field males_per_hundred_females number
---@field child_age number
---@field teen_age number
---@field adult_age number
---@field middle_age number
---@field elder_age number
---@field max_age number
---@field minimum_comfortable_temperature number
---@field minimum_absolute_temperature number
---@field minimum_comfortable_elevation number
---@field female_body_size number
---@field female_efficiency table<JOBTYPE, number>
---@field female_needs table<NEED, table<TradeGoodUseCaseReference, number>>
---@field female_infrastructure_needs number
---@field male_body_size number
---@field male_efficiency table<JOBTYPE, number>
---@field male_needs table<NEED, table<TradeGoodUseCaseReference, number>>
---@field male_infrastructure_needs number
---@field requires_large_river boolean
---@field requires_large_forest boolean

---@class Race
local Race = {}
Race.__index = Race
---@param o Race
---@return Race
function Race:new(o)
	---@type Race
	local r = {}

	r.name = "<race>"
	r.icon = "uncertainty.png"
	r.description = "<race description>"
	r.r = love.math.random()
	r.g = love.math.random()
	r.b = love.math.random()
	r.males_per_hundred_females = 104
	r.child_age = 3
	r.teen_age = 12
	r.adult_age = 16
	r.middle_age = 40
	r.elder_age = 65
	r.max_age = 85
	r.minimum_comfortable_temperature = 5
	r.minimum_absolute_temperature = -10
	r.minimum_comfortable_elevation = 0
	r.fecundity = 1
	r.spotting = 1
	r.visibility = 1
	r.female_body_size = 1
	r.female_needs = {}
	r.female_infrastructure_needs = 1
	r.male_body_size = 1
	r.male_needs = {}
	r.male_infrastructure_needs = 1
	r.carrying_capacity_weight = 1

	r.female_efficiency = {
		[JOBTYPE.FARMER] = 1,
		[JOBTYPE.ARTISAN] = 1,
		[JOBTYPE.CLERK] = 1,
		[JOBTYPE.LABOURER] = 1,
		[JOBTYPE.WARRIOR] = 1,
		[JOBTYPE.HAULING] = 1,
		[JOBTYPE.FORAGER] = 1
	}

	r.female_needs = {
		[NEED.WATER] = {
			['water'] = 1,
		},
		[NEED.FOOD] = {
			['food'] = 0.8,
			['meat'] = 0.2,
		},
		[NEED.CLOTHING] = {
			['clothes'] = 1,
		},
		[NEED.FURNITURE] = {
			['furniture'] = 1,
		},
		[NEED.TOOLS] = {
			['tools'] = 0.125,
		},
		[NEED.HEALTHCARE] = {
			['healthcare'] = 0.125,
		},
		[NEED.STORAGE] = {
			['storage'] = 0.125,
		},
		[NEED.LUXURY] = {
			['luxury'] = 1,
		},
	}

	r.male_efficiency = {
		[JOBTYPE.FARMER] = 1,
		[JOBTYPE.ARTISAN] = 1,
		[JOBTYPE.CLERK] = 1,
		[JOBTYPE.LABOURER] = 1,
		[JOBTYPE.WARRIOR] = 1,
		[JOBTYPE.HAULING] = 1,
		[JOBTYPE.FORAGER] = 1
	}

	r.male_needs = {
		[NEED.WATER] = {
			['water'] = 1,
		},
		[NEED.FOOD] = {
			['food'] = 0.5,
			['fruit'] = 0.2,
			['grain'] = 0.2,
			['meat'] = 0.1,
		},
		[NEED.CLOTHING] = {
			['clothes'] = 1,
		},
		[NEED.FURNITURE] = {
			['furniture'] = 1,
		},
		[NEED.TOOLS] = {
			['tools'] = 0.125,
		},
		[NEED.HEALTHCARE] = {
			['healthcare'] = 0.125,
		},
		[NEED.STORAGE] = {
			['storage'] = 0.125,
		},
		[NEED.LUXURY] = {
			['luxury'] = 1,
		},
	}

	r.requires_large_river = false
	r.requires_large_forest = false

	for k, v in pairs(o) do
		r[k] = v
	end
	setmetatable(r, Race)
	if RAWS_MANAGER.races_by_name[r.name] ~= nil then
		local msg = "Failed to load a race (" .. tostring(r.name) .. ")"
		print(msg)
		error(msg)
	end

	-- assert that needs are valid
	for need_name, demand in pairs(r.male_needs) do
		local need = NEEDS[need_name]
		if need == nil then
			error(r.name .. "WRONG MALE NEED NAME: " .. need_name)
		end
	end
	for need_name, demand in pairs(r.female_needs) do
		local need = NEEDS[need_name]
		if need == nil then
			error(r.name .. " WRONG FEMALE NEED NAME: " .. need_name)
		end
	end


	RAWS_MANAGER.races_by_name[r.name] = r
	return r
end

return Race
