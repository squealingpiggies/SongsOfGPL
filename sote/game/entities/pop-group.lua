local job_types = require "game.raws.job_types"
local tabb = require "engine.table"

---@class (exact) PopGroup
---@field __index PopGroup
---@field race Race
---@field faith Faith
---@field culture Culture
---@field name string
---@field savings number
---@field head POP
---@field adults table<POP, POP>
---@field children table<POP, POP>
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field need_satisfaction table<NEED, table<TradeGoodUseCaseReference,{consumed:number, demanded:number}>>
---@field total_time number cumulative time from all pops in group
---@field forage_ratio number a number in (0, 1) interval representing a ratio of time pop spends to forage
---@field work_ratio number a number in (0, 1) interval representing a ratio of time workers spend on a job compared to maximal
---@field province Province Points to current position of pops.
---@field home_province Province Points to home of pops.

local rtab = {}

---@class PopGroup
rtab.PopGroup = {}
rtab.PopGroup.__index = rtab.PopGroup
---Creates a new PopGroup
---@param head POP
---@param home Province
---@param location Province
---@return PopGroup
function rtab.PopGroup:new(head, home, location)
	local tabb = require "engine.table"

	---@type PopGroup
	local r = {}
	setmetatable(r, rtab.PopGroup)

	r.province                 = location
	r.home_province            = home

	r.race                     = head.race
	r.faith                    = head.faith
	r.culture                  = head.culture

	r.name                     = head.culture.language:get_random_name()

	r.savings                  = 0
	r.head                     = head
	r.adults                   = {}
	r.children                 = {}

	r.total_time               = 0
	r.forage_ratio             = 0.75
	r.work_ratio               = 0.25
	r:calculate_needs()

	return r
end

---@return table<POP, POP>
function rtab.PopGroup:pops()
	local pops = {}
	if self.head then pops[self.head] = self.head end
	for _, s in pairs(self.adults) do
		pops[s] = s
	end
	for _, c in pairs(self.children) do
		pops[c] = c
	end
	return pops
end

---Adds a pop to the children table
---@param pop any
function rtab.PopGroup:add_child(pop)
	self.children[pop] = pop
	self:add_needs(pop)
end

---Adds a pop to the adults table
---@param pop any
function rtab.PopGroup:add_adult(pop)
	self.adults[pop] = pop
	self:add_needs(pop)
end

---Removes a pop from group and sets new head if needed
---@param pop any
function rtab.PopGroup:remove_pop(pop)
	if self.head == pop then
		_, self.head = tabb.random_select_from_set(self.adults)
		if self.head == nil then
			_, self.head = tabb.random_select_from_set(self.children)
			if self.head then
				self.children[self.head] = nil
			end
		else
			self.adults[self.head] = nil
		end
	end
	self.children[pop] = nil
	self.adults[pop] = nil
	if self.head == pop
		or self.children[pop] ~= nil
		or self.adults[pop] ~= nil
	then
		error("FAILED TO REMOVE POP FROM GROUP IN POP")
	end
	--self:remove_needs(pop)
end

---Recallulates and aggregates all pop's need demands, free_time
function rtab.PopGroup:calculate_needs()
	local low_life_need, high_life_needs = false, true
	local total_time, total_life_need, total_basic_need = 0, 0, 0
	local life_needs_satisfaction, basic_needs_satisfaction = 0, 0
	local needs_satisfaction = tabb.accumulate(NEEDS, {}, function (needs_satisfaction, need_index, _)
		needs_satisfaction[need_index] = {}
		return needs_satisfaction
	end)
	tabb.accumulate(self:pops(), nil, function (_, _, pop)
		total_time = total_time + pop:free_time()
		pop.forage_ratio = self.forage_ratio
		pop.work_ratio = self.work_ratio
		--pop:recalculate_needs_satisfaction()
		tabb.accumulate(NEEDS, nil, function (_, need_index, need)
			if pop.need_satisfaction[need_index] then
				tabb.accumulate(pop.need_satisfaction[need_index], needs_satisfaction[need_index], function (need_satisfaction, case, values)
					local demanded = values.demanded or 0
					if demanded > 0 then
						local consumed = values.consumed
						if need.life_need then
							total_life_need = total_life_need + demanded
							life_needs_satisfaction = life_needs_satisfaction + consumed
							local ratio = consumed / demanded
							if ratio < 0.5 then
								low_life_need = true
							elseif ratio < 0.6 then
								high_life_needs = false
							end
						else
							total_basic_need = total_basic_need + demanded
							basic_needs_satisfaction = basic_needs_satisfaction + consumed
						end
						need_satisfaction[case] = {
							consumed = (need_satisfaction[case] and need_satisfaction[case].consumed or 0) + consumed,
							demanded = (need_satisfaction[case] and need_satisfaction[case].demanded or 0) + demanded
						}
					end
					return need_satisfaction
				end)
			end
		end)
		return needs_satisfaction
	end)
	if low_life_need then
		self.forage_ratio = math.min(0.99, self.forage_ratio * 1.15)
		self.work_ratio = math.max(0.01, 1 - self.forage_ratio)
	elseif high_life_needs then
		self.forage_ratio = math.max(0.01, self.forage_ratio * 0.9)
		self.work_ratio = math.max(0.01, 1 - self.forage_ratio)
	end
	self.life_needs_satisfaction = life_needs_satisfaction / total_life_need
	self.basic_needs_satisfaction = (basic_needs_satisfaction + life_needs_satisfaction) / (total_basic_need + total_life_need)
	self.need_satisfaction = needs_satisfaction
end

function rtab.PopGroup:add_needs(pop)
	self.total_time = self.total_time + pop:free_time(pop)
	tabb.accumulate(pop.need_satisfaction, self.need_satisfaction, function (group_need_satisfaction, need_index, cases)
		tabb.accumulate(cases, nil, function (_, case, values)
			local base = group_need_satisfaction[need_index] and group_need_satisfaction[need_index][case] or nil
			group_need_satisfaction[need_index][case] = {
				consumed = (base and base.consumed or 0) + values.consumed,
				demanded = (base and base.demanded or 0) + values.demanded,
			}
		end)
		return group_need_satisfaction
	end)
end

function rtab.PopGroup:remove_needs(pop)
	self.total_time = self.total_time - pop:free_time(pop)
	tabb.accumulate(pop.need_satisfaction, self.need_satisfaction, function (group_need_satisfaction, need_index, cases)
		tabb.accumulate(cases, nil, function (_, case, values)
			local base = group_need_satisfaction[need_index] and group_need_satisfaction[need_index][case] or nil
			group_need_satisfaction[need_index][case] = {
				consumed = (base and base.consumed or 0) - values.consumed,
				demanded = (base and base.demanded or 0) - values.demanded,
			}
			if base.demanded < 0.001 then
				group_need_satisfaction[need_index][case] = nil
			end
		end)
		return group_need_satisfaction
	end)
end

---@return number pop_group_weight
function rtab.PopGroup:population_weight()
	return tabb.accumulate(self:pops(),0,function (weight, _, pop)
		return weight + pop.race.carrying_capacity_weight * pop:get_age_multiplier()
	end)
end

return rtab
