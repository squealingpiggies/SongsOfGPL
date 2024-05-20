local job_types = require "game.raws.job_types"
local tabb = require "engine.table"

---@class (exact) POP
---@field __index POP
---@field race Race
---@field faith Faith
---@field culture Culture
---@field female boolean
---@field age number
---@field name string
---@field savings number
---@field mother POP?
---@field father POP?
---@field children table<POP, POP>
---@field group PopGroup
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field popularity table<Realm, number|nil>
---@field traits table<Trait, Trait>
---@field employer Building?
---@field loyalty POP?
---@field loyal table<POP, POP> who is loyal to this pop
---@field successor POP?
---@field successor_of table<POP, POP>
---@field owned_buildings table <Building, Building>
---@field has_trade_permits_in table<Realm, Realm>
---@field has_building_permits_in table<Realm, Realm>
---@field inventory table <TradeGoodReference, number?>
---@field price_memory table<TradeGoodReference, number?>
---@field need_satisfaction table<NEED, table<TradeGoodUseCaseReference,{consumed:number, demanded:number}>>
---@field forage_ratio number a number in (0, 1) interval representing a ratio of time pop spends to forage
---@field work_ratio number a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
---@field leading_warband Warband?
---@field recruiter_for_warband Warband?
---@field unit_of_warband Warband?
---@field busy boolean
---@field job Job?
---@field dead boolean
---@field province Province Points to current position of pop/character.
---@field home_province Province Points to home of pop/character.
---@field realm Realm? Represents the home realm of the character
---@field leader_of table<Realm, Realm>
---@field current_negotiations table<Character, Character>
---@field rank CHARACTER_RANK?
---@field former_pop boolean
---@field dna number[]

local rtab = {}

---@class POP
rtab.POP = {}
rtab.POP.__index = rtab.POP
---Creates a new POP
---@param race Race
---@param faith Faith
---@param culture Culture
---@param female boolean
---@param age number
---@param home Province
---@param location Province
---@param character_flag boolean?
---@return POP
function rtab.POP:new(race, faith, culture, female, age, home, location, character_flag)
	---@type POP
	local r = {}
	setmetatable(r, rtab.POP)

	r.race = race
	r.faith = faith
	r.culture = culture
	r.female = female
	r.age = age

	r.name = culture.language:get_random_name()

	-- calculate needs statisfaction before adding to group or family!
	r.forage_ratio = 0.75
	r.work_ratio = 0.25
	r.need_satisfaction = {}
	r:recalculate_needs_satisfaction(0.5)

	home:set_home(r)
	if character_flag then
		location:add_character(r)
	else
		location:add_guest_pop(r)
	end

	r.busy                     = false
	r.owned_buildings          = {}
	r.inventory                = {}
	r.price_memory             = {}
	r.children                 = {}
	r.successor_of             = {}
	r.current_negotiations     = {}

	r.has_trade_permits_in     = {}
	r.has_building_permits_in  = {}

	r.savings                  = 0
	r.popularity               = {}
	r.loyalty                  = nil
	r.loyal                    = {}
	r.traits                   = {}

	r.leader_of                = {}

	r.dead                     = false
	r.former_pop               = false

	r.dna                      = {}
	for i = 1, 20 do
		table.insert(r.dna, love.math.random())
	end

	return r
end

---Checks if pop belongs to characters table of current province
---@return boolean
function rtab.POP:is_character()
	return self.rank ~= nil
end

---Unregisters a pop as a military pop.  \
---The "fire" routine for soldiers. Also used in some other contexts?
function rtab.POP:unregister_military()
	if self.unit_of_warband then
		self.unit_of_warband:fire_unit(self)
	end
end

function rtab.POP:get_age_multiplier()
	local age_multiplier = 1
	if self.age < self.race.child_age then
		age_multiplier = 0.25 -- baby
	elseif self.age < self.race.teen_age then
		age_multiplier = 0.5 -- child
	elseif self.age < self.race.adult_age then
		age_multiplier = 0.75 -- teen
	elseif self.age < self.race.middle_age then
		age_multiplier = 1 -- adult
	elseif self.age < self.race.elder_age then
		age_multiplier = 0.95 -- middle age
	elseif self.age < self.race.max_age then
		age_multiplier = 0.9 -- elder
	end
	return age_multiplier
end

--- Recalculate and return satisfaction percentage
function rtab.POP:get_need_satisfaction()
	local total_consumed, total_demanded = 0, 0
	local life_consumed, life_demanded = 0, 0
	for need, cases in pairs(self.need_satisfaction) do
		local consumed, demanded = 0, 0
		for case, values in pairs(cases) do
			consumed = consumed + values.consumed
			demanded = demanded + values.demanded
		end
		if NEEDS[need].life_need then
			life_consumed = life_consumed + consumed
			life_demanded = life_demanded + demanded
		else
			total_consumed = total_consumed + consumed
			total_demanded = total_demanded + demanded
		end
	end
	self.life_needs_satisfaction = life_consumed / life_demanded
	self.basic_needs_satisfaction = (total_consumed + life_consumed) / (total_demanded + life_demanded)
end

---Returns age adjusted size of pop
---@return number size
function rtab.POP:size()
	if self.female then
		return self.race.female_body_size * self:get_age_multiplier()
	end
	return self.race.male_body_size * self:get_age_multiplier()
end

---Returns age adjust racial efficiency
---@param jobtype JOBTYPE
---@return number
function rtab.POP:job_efficiency(jobtype)
	if self.female then
		return self.race.female_efficiency[jobtype] * self:get_age_multiplier()
	end
	return self.race.male_efficiency[jobtype] * self:get_age_multiplier()
end

function rtab.POP:free_time()
	if self.age < self.race.teen_age then
		return self.age / self.race.teen_age
	end
	return 1
end

---Returns age adjust racial need for a single use case
---@param need NEED
---@param use_case TradeGoodUseCaseReference
---@return number
function rtab.POP:get_racial_need_use_case(need, use_case)
	if self.female then
		return self.race.female_needs[need][use_case] * self:get_age_multiplier()
	end
	return self.race.male_needs[need][use_case] * self:get_age_multiplier()
end

---Returns all use cases for a single need
---@param need_index NEED
---@param percentage number? optionally set consumed to percentage of demanded
---@return table<TradeGoodUseCaseReference, table<{consumed:number, demanded: number}>>
---@return number total_demanded
---@return number total_consumed
function rtab.POP:get_racial_need(need_index, percentage)
	local total_consumed, total_demanded = 0, 0
	local racial_need_table
	if self.female then
		racial_need_table = self.race.female_needs
	else
		racial_need_table = self.race.male_needs
	end
	local needs_collection = {}
	if racial_need_table and racial_need_table[need_index] then
		needs_collection = tabb.accumulate(racial_need_table[need_index], {}, function(need_collection, case, value)
			local demanded = value * self:get_age_multiplier()
			local consumed = percentage and (percentage * demanded) or
				(self.need_satisfaction[need_index] and self.need_satisfaction[need_index][case] and self.need_satisfaction[need_index][case].consumed or 0)
			total_consumed = total_consumed + consumed
			total_demanded = total_demanded + demanded
			need_collection[case] = {consumed = consumed, demanded = demanded }
			return need_collection
		end)
	end
	return needs_collection, total_consumed, total_demanded
end

---calculate and set pop needs
---@param percentage? number optional percentage to set life needs
function rtab.POP:recalculate_needs_satisfaction(percentage)
	local total_life_need, total_basic_need = 0, 0
	local total_life_satisfaction, total_basic_satisfaction = 0, 0
	local needs_satsifaction = tabb.accumulate(NEEDS, {}, function(needs_satsifaction, need_index, need)
		local need_collection, consumed, demanded = self:get_racial_need(need_index, need.life_need and percentage or nil)
		if demanded > 0 then
			if need.life_need then
				total_life_need = total_life_need + demanded
				total_life_satisfaction = total_life_satisfaction + consumed
			else
				total_basic_need = total_basic_need + demanded
				total_basic_satisfaction = total_basic_satisfaction + consumed
			end
			needs_satsifaction[need_index] = need_collection
		end
		return needs_satsifaction
	end)
	-- Add foraging tools from pop culture targets
	if not needs_satsifaction[NEED.TOOLS] then needs_satsifaction[NEED.TOOLS] = {} end
	local water_search = self.culture.traditional_forager_targets['water'].search
	local tools_like_demanded = (1 - water_search) * self:size()
	local tools_like_consumed = (self.need_satisfaction[NEED.TOOLS] and self.need_satisfaction[NEED.TOOLS]['tools-like'] and self.need_satisfaction[NEED.TOOLS]['tools-like'].consumed or 0)
	local containers_demanded = water_search * self:size()
	local containers_consumed = (self.need_satisfaction[NEED.TOOLS] and self.need_satisfaction[NEED.TOOLS]['containers'] and self.need_satisfaction[NEED.TOOLS]['containers'].consumed or 0)
	total_basic_need = total_basic_need + containers_demanded + tools_like_demanded
	total_basic_satisfaction = total_basic_satisfaction + containers_consumed + tools_like_consumed
	needs_satsifaction[NEED.TOOLS]['tools-like'] = {
		consumed = tools_like_consumed,
		demanded = tools_like_demanded,
	}
	needs_satsifaction[NEED.TOOLS]['containers'] = {
		consumed = containers_consumed,
		demanded = containers_demanded,
	}

	-- TOTO use production methods from culture foraging targets and get tool needs
	-- TOTO use culture to hold non life needs and calculate/update here

	self.need_satisfaction = needs_satsifaction
	self.life_needs_satisfaction = total_life_satisfaction / total_life_need
	self.basic_needs_satisfaction = (total_basic_satisfaction + total_life_satisfaction) / (total_basic_need + total_life_need)
end

---Returns the adjusted health value for the provided pop.
---@param unit UnitType
---@return number attack health modified by pop race and sex
function rtab.POP:get_health(unit)
	return unit.base_health * rtab.POP.size(self)
end

---Returns the adjusted attack value for the provided pop.
---@param unit UnitType
---@return number pop_adjusted attack modified by pop race and sex
function rtab.POP:get_attack(unit)
	return unit.base_attack * rtab.POP.job_efficiency(self,job_types.WARRIOR)
end

---Returns the adjusted armor value for the provided pop.
---@param unit UnitType
---@return number pop_adjusted armor modified by pop race and sex
function rtab.POP:get_armor(unit)
	return unit.base_armor
end

---Returns the adjusted speed value for the provided pop.
---@param unit UnitType?
---@return number pop_adjusted speed modified by pop race and sex
function rtab.POP:get_speed(unit)
	return (unit and unit.speed or 1)
end

---Returns the adjusted combat strength values for the provided pop.
---@param unit UnitType
---@return number health
---@return number attack
---@return number armor
---@return number speed
function rtab.POP:get_strength(unit)
	return self:get_health( unit), self:get_attack(unit), self:get_armor(unit), self:get_speed(unit)
end

---Returns the adjusted spotting value for the provided pop.
---@param unit UnitType?
---@return number pop_adjusted spotting modified by pop race and sex
function rtab.POP:get_spotting(unit)
	return (unit and unit.spotting or 1) * self.race.spotting
end

---Returns the adjusted visibility value for the provided pop.
---@param unit UnitType?
---@return number pop_adjusted visibility modified by pop race and sex
function rtab.POP:get_visibility(unit)
	return (unit and unit.visibility or 1) * self.race.visibility * self:size()
end

---Returns the adjusted travel day cost value for the provided pop.
---@param unit UnitType?
---@return number pop_adjusted food need modified by pop race and sex
function rtab.POP:get_supply_use(unit)
	local pop_food = self:get_racial_need_use_case(NEED.FOOD, 'calories')
	return ((unit and unit.supply_useds or 0) + pop_food) / 30
end

---Returns the adjusted hauling capacity value for the provided pop.
---@param unit UnitType?
---@return number pop_adjusted hauling modified by pop race and sex
function rtab.POP:get_supply_capacity(unit)
	local job = self.race.male_efficiency[job_types.HAULING]
	if self.female then
		job = self.race.female_efficiency[job_types.HAULING]
	end
	return (unit and unit.supply_capacity * 0.25 or 0) + job
end

return rtab
