local job_types = require "game.raws.job_types"
local tabb = require "engine.table"

---@class (exact) PopGroup
---@field __index PopGroup
---@field race Race
---@field faith Faith
---@field culture Culture
---@field name string
---@field savings number total wealth of all pops in group
---@field size number total number of individual pops in group
---@field head POP
---@field adults table<POP, POP>
---@field children table<POP, POP>
---@field life_needs_satisfaction number from 0 to 1
---@field basic_needs_satisfaction number from 0 to 1
---@field need_satisfaction table<NEED, table<TradeGoodUseCaseReference,{consumed:number, demanded:number}>>
---@field total_time number cumulative time from all pops in group
---@field forage_efficiency number a number in (0, 1) of foraging tools satisfaction
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
---@param character boolean? whether to build a PopGroup or Family
---@return PopGroup
function rtab.PopGroup:new(head, home, location, character)
	local tabb = require "engine.table"

	---@type PopGroup
	local r = {}
	setmetatable(r, rtab.PopGroup)

	r.province              = location
	r.home_province         = home

	r.race                  = head.race
	r.faith                 = head.faith
	r.culture               = head.culture

	r.name                  = character and head.culture.language:get_random_name()
								or (head.faith.name .. " " .. head.culture.name .. " " .. require "engine.string".title(head.race.name))

	r.size					= 1
	r.head                  = head
	r.adults                = {}
	r.children              = {}

	r.total_time            = 0
	r.forage_efficiency     = 0
	r.forage_ratio          = 0.75
	r.work_ratio            = 0.25
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
	self.size = self.size + 1
end

---Adds a pop to the adults table
---@param pop any
function rtab.PopGroup:add_adult(pop)
	self.adults[pop] = pop
	self:add_needs(pop)
	self.size = self.size + 1
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
	else
		self.children[pop] = nil
		self.adults[pop] = nil
	end
	self.size = self.size - 1
	--self:remove_needs(pop)
end

---Recallulates and aggregates all pop's need demands, free_time
function rtab.PopGroup:calculate_needs()
	local total_time, total_life_need, total_basic_need = 0, 0, 0
	local total_savings, life_needs_satisfaction, basic_needs_satisfaction = 0, 0, 0
	local needs_satisfaction = tabb.accumulate(NEEDS, {}, function (needs_satisfaction, need_index, _)
		needs_satisfaction[need_index] = {}
		return needs_satisfaction
	end)
	tabb.accumulate(self:pops(), nil, function (_, _, pop)
		total_time = total_time + pop:free_time()
		total_savings = total_savings + (pop.savings or 0)
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
	self.life_needs_satisfaction = life_needs_satisfaction / total_life_need
	self.basic_needs_satisfaction = (basic_needs_satisfaction + life_needs_satisfaction) / (total_basic_need + total_life_need)
	self.need_satisfaction = needs_satisfaction
	self.savings = total_savings
end

function rtab.PopGroup:add_needs(pop)
	self.total_time = self.total_time + pop:free_time(pop)
	self.savings = self.savings + pop.savings
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
	self.savings = math.max(0, self.savings - pop.savings)
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

---Returns racial efficiency
---@param jobtype JOBTYPE
---@return number
function rtab.PopGroup:job_efficiency(jobtype)
	-- estimate average age from get_age_multiplier applied to population weight
	local age_weight = self:population_weight() / self.size
	local male_ratio = self.race.males_per_hundred_females / (100 + self.race.males_per_hundred_females)
	local efficiency = male_ratio * self.race.male_efficiency[jobtype] + (1 - male_ratio) * self.race.female_efficiency[jobtype] 
	return efficiency * age_weight
end

--- recalculates foraging time and tool needs then distributes pop group need satsifactions to pops
---@param satsifaction table<NEED, table<TradeGoodUseCaseReference, number>>
function rtab.PopGroup:distribute_satsisfaction(satsifaction)
print("DISTRIBUTE SATISFACTION: ")
	local total_basic_need, total_basic_satisfaction = 0, 0
	local total_life_need, total_life_satisfaction = 0, 0
	local low_life_need, high_life_needs = false, true
print("  OLD SATISFACTION: ")
for need_index, cases in pairs (self.need_satisfaction) do
	print("    " .. NEED_NAME[need_index])
	for case, value in pairs(cases) do
		print("      " .. case .. " " .. value.consumed .. " / " .. value.demanded)
	end
end
print("  ADD SATISFACTION: ")
for need_index, cases in pairs(satsifaction) do
	print("    " .. NEED_NAME[need_index])
	for case, value in pairs(cases) do
		print("      " .. case .. " " .. value)
	end
end
	tabb.accumulate(self:pops(), nil, function (_, _, pop)
		local pop_basic_need, pop_basic_satisfaction = 0, 0
		local pop_life_need, pop_life_satisfaction = 0, 0
		pop.forage_ratio = self.forage_ratio
		pop.work_ratio = self.work_ratio
		local tools_like, containers = 0, 0
		if pop.need_satisfaction[NEED.TOOLS] then
			tools_like = pop.need_satisfaction[NEED.TOOLS]['tools-like'] and pop.need_satisfaction[NEED.TOOLS]['tools-like'].demanded or 0
			containers = pop.need_satisfaction[NEED.TOOLS]['containers'] and pop.need_satisfaction[NEED.TOOLS]['containers'].demanded or 0
		end
		pop:recalcualte_foraging_tools(pop.need_satisfaction)
--print("  " .. pop.name .. " " .. pop.savings .. " / " .. self.savings .. "(".. pop.savings / self.savings .. ")")
		tabb.accumulate(pop.need_satisfaction, nil, function(_, need_index, cases)
--print("    " .. NEED_NAME[need_index])
			tabb.accumulate(cases, nil, function (_, case, values)
				local demanded = values.demanded
				if need_index == NEED.TOOLS then
					if case == 'tools-like' and tools_like then
						demanded = tools_like
					end
					if case == 'containers' and containers then
						demanded = containers
					end
				end
				if demanded > 0 then
					local percentage = self.savings and (pop.savings / self.savings) or (1 / self.size)
					local pops_consumed = self.need_satisfaction[need_index][case].consumed / self.need_satisfaction[need_index][case].demanded
					local pop_consumed = percentage * (satsifaction[need_index] and satsifaction[need_index][case] or 0)
					pop.need_satisfaction[need_index][case].consumed = pops_consumed * values.demanded + pop_consumed
--print("      " .. case .. " " .. pop.need_satisfaction[need_index][case].consumed)
					if NEEDS[need_index].life_need then
						pop_life_need = pop_life_need + values.demanded
						pop_life_satisfaction = pop_life_satisfaction + pop.need_satisfaction[need_index][case].consumed
					else
						pop_basic_need = pop_basic_need + values.demanded
						pop_basic_satisfaction = pop_basic_satisfaction + pop.need_satisfaction[need_index][case].consumed
					end
				end
			end)
	 	end)
		pop_basic_need = pop_basic_need + pop_life_need
		pop_basic_satisfaction = pop_basic_satisfaction + pop_life_satisfaction
		pop.life_needs_satisfaction = pop_life_satisfaction / pop_life_need
		pop.basic_needs_satisfaction = pop_basic_satisfaction / pop_basic_need
--print("  LIFE: " .. pop.life_needs_satisfaction .. " BASIC: " .. pop.basic_needs_satisfaction)
		total_life_need = total_life_need + pop_life_need
		total_life_satisfaction = total_life_satisfaction + pop_life_satisfaction
		total_basic_need = total_basic_need + pop_basic_need
		total_basic_satisfaction = total_basic_satisfaction + pop_basic_satisfaction
	end)
	local life_needs_satisfaction = total_life_satisfaction / (total_life_need or 1)
	local basic_needs_satisfaction = total_basic_satisfaction / (total_basic_need or 1)
	self.life_needs_satisfaction = life_needs_satisfaction
	self.basic_needs_satisfaction = basic_needs_satisfaction
	tabb.accumulate(self.need_satisfaction, nil, function (_, need_index, cases)
		tabb.accumulate(cases, nil, function (_, case, values)
			self.need_satisfaction[need_index][case].consumed  = values.consumed + (satsifaction[need_index] and satsifaction[need_index][case] or 0)
			if NEEDS[need_index].life_need then
				local ratio = self.need_satisfaction[need_index][case].consumed / values.demanded
				if ratio < 0.5 then
					low_life_need = true
				elseif ratio < 0.6 then
					high_life_needs = false
				end
			end
		end)
	end)
--	if low_life_need then
--		self.forage_ratio = math.min(0.99, self.forage_ratio * 1.15)
--		self.work_ratio = math.max(0.01, 1 - self.forage_ratio)
--	elseif high_life_needs then
--		self.forage_ratio = math.max(0.01, self.forage_ratio * 0.9)
--		self.work_ratio = math.max(0.01, 1 - self.forage_ratio)
--	end
--print("  NEW SATISFACTION: ")
--for need_index, cases in pairs (self.need_satisfaction) do
--	print("    " .. NEED_NAME[need_index])
--	for case, value in pairs(cases) do
--		print("      " .. case .. " " .. value.consumed .. " / " .. value.demanded)
--	end
--end
--print("    LIFE: " .. self.life_needs_satisfaction .. " BASIC: " .. self.basic_needs_satisfaction)
end

---@return number pop_group_weight
function rtab.PopGroup:population_weight()
	return tabb.accumulate(self:pops(),0,function (weight, _, pop)
		return weight + pop:carrying_capacity_weight()
	end)
end

return rtab
