local tabb = require "engine.table"

---@class POP
---@field race Race
---@field faith Faith
---@field culture Culture
---@field female boolean
---@field age number
---@field name string
---@field savings number
---@field parent POP?
---@field children table<POP, POP>
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
---@field inventory table <TradeGoodReference, number?>
---@field price_memory table<TradeGoodReference, number?>
---@field need_satisfaction table<NEED, NeedSatisfaction>
---@field leading_warband Warband?
---@field recruiter_for_warband Warband?
---@field unit_of_warband Warband?
---@field busy boolean
---@field job Job?
---@field dead boolean
---@field get_age_multiplier fun(self:POP):number
---@field province Province Points to current position of pop/character.
---@field home_province Province Points to home of pop/character.
---@field realm Realm? Represents the home realm of the character
---@field leader_of table<Realm, Realm>
---@field rank CHARACTER_RANK?
---@field former_pop boolean

---@class NeedSatisfaction
---@field consumed number
---@field demanded number
---@field uses table<TradeGoodUseCaseReference,{consumed: number, demanded:number}>

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

	r.race = race
	r.faith = faith
	r.culture = culture
	r.female = female
	r.age = age

	r.name = culture.language:get_random_name()

	home:set_home(r)
	if character_flag then
		location:add_character(r)
	else
		location:add_guest_pop(r)
	end

	r.busy = false
	r.owned_buildings = {}
	r.inventory = {}
	r.price_memory = {}
	r.children = {}
	r.successor_of = {}
	-- dclare and define satisfactions
	r.need_satisfaction = {}
	tabb.accumulate(NEEDS, r.need_satisfaction, function (sat, index ,need)
		local total_demand = 0
		local uses = tabb.accumulate(need.use_cases, {}, function(use, case, num)
			local weight = race.male_needs[index]
			if female then
				weight = race.female_needs[index]
			end
			local demand = num * weight
			if not NEEDS[NEED.FOOD].age_independent then
				demand = demand * rtab.POP.get_age_multiplier(r)
			end
			use[case] = {
				consumed = demand * 0.25,
				demanded = demand
			}
			total_demand = total_demand + demand
			---@type table<string, {consumed: number, demanded: number}>
			return use
		end)
		---@type NeedSatisfaction
		sat[index] = {
			consumed = total_demand * 0.25,
			demanded = total_demand,
			uses = uses, ---@diagnostic disable-line
		}
		return sat
	end)

	r.basic_needs_satisfaction = 0.25
	r.life_needs_satisfaction = 0.25

	r.savings = 0
	r.popularity = {}
	r.loyalty = nil
	r.loyal	 = {}
	r.traits = {}

	r.leader_of = {}

	r.dead = false
	r.former_pop = false

	setmetatable(r, rtab.POP)

	return r
end

---Checks if pop belongs to characters table of current province
---@return boolean
function rtab.POP:is_character()
	return not self.dead and self.province.characters[self] == self
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
		age_multiplier = 0.1 -- baby
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

function rtab.POP:gauge_needs()
	local total_consumed_life = 0
	local total_demanded_life = 0
	local total_consumed_need = 0
	local total_demanded_need = 0
	tabb.accumulate(self.need_satisfaction, {}, function (sat, index, need)
		local total_consumed = 0
		local total_demanded = 0
		tabb.accumulate(need.uses, nil, function(use, case, num)
			total_consumed = total_consumed + num.consumed
			total_demanded = total_demanded + num.demanded
		end)
		need.consumed = total_consumed
		need.demanded = total_demanded
		if NEEDS[index].life_need then
			total_consumed_life = total_consumed_life + total_consumed
			total_demanded_life = total_demanded_life + total_demanded
		else
			total_consumed_need = total_consumed_need + total_consumed
			total_demanded_need = total_demanded_need + total_demanded
		end
		return sat
	end)
	self.life_needs_satisfaction = total_consumed_life / total_demanded_life
	self.basic_needs_satisfaction = (total_consumed_need + total_consumed_life)
		/ (total_demanded_need + total_demanded_life)
end

function rtab.POP:get_satisfaction_tooltip()
	local uit = require "game.ui-utils"
	local s = ""
	for need, value in pairs(self.need_satisfaction) do
		s = s
			.. "\n" .. NEED_NAME[need] .. " " .. uit.to_fixed_point2(value.consumed / value.demanded * 100) .. "%"
		for use, values in pairs(value.uses) do
			s = s
			.. "\n  " .. use .. ": " ..  uit.to_fixed_point2(values.consumed) .. " / " ..  uit.to_fixed_point2(values.demanded)
			.. " (" .. uit.to_fixed_point2(values.consumed / values.demanded * 100) .. "%)"
		end
	end
	return s
end

return rtab
