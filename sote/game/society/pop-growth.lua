local pg = {}

local POP = require "game.entities.pop".POP
local tabb = require "engine.table"
local character_ranks = require "game.raws.ranks.character_ranks"
local economical = require "game.raws.values.economical"
local economic_effects = require "game.raws.effects.economic"

---Runs natural growth and decay on a single province.
---@param province Province
function pg.growth(province)
	-- First, get the carrying capacity...
	local cc = province.foragers_limit
	local cc_used = province:population_weight()
	local min_life_need = 0.125
	local death_rate = 0.003333333 -- 4% per year
	local birth_rate = 1 / 24 -- 1 every 2 years

	-- Mark pops for removal...
	---@type POP[]
	local to_remove = {}
	---@type POP[]
	local to_add = {}

	for _, pp in pairs(province.outlaws) do
		if pp.age > pp.race.max_age then
			to_remove[#to_remove + 1] = pp
		end
	end

	tabb.accumulate(province:get_pop_groups(), nil, function (_, _, group)
		-- find groups min life need satisfaction
		local min_life_satisfaction = tabb.accumulate(group.need_satisfaction, 3, function(b, need, cases)
			if NEEDS[need].life_need then
				b = tabb.accumulate(cases, b, function (c, _, v)
					local ratio = v.consumed / v.demanded
					if ratio < c then
						return ratio
					end
					return c
				end)
			end
			return b
		end)
		local k = (cc / group.race.carrying_capacity_weight)
		local rate = birth_rate * group.race.fecundity * min_life_need * (k - cc_used) / k * cc_used
		-- kill off pops for reasons
		tabb.accumulate(group:pops(), nil, function (_, _, pp)
			local age_adjusted_starvation_check = min_life_need / pp:get_age_multiplier()
			-- first remove all pop that reach max age
			if pp.age > pp.race.max_age then
				to_remove[#to_remove + 1] = pp
			-- next check for starvation
			elseif min_life_satisfaction < age_adjusted_starvation_check then -- prevent births if not at least 12.5% food or water
				-- children are more likely to die of starvation 
				if (age_adjusted_starvation_check - min_life_satisfaction) / age_adjusted_starvation_check * love.math.random() < death_rate then
					to_remove[#to_remove + 1] = pp
				end
			-- finally kill some old people for being old
			elseif pp.age >= pp.race.elder_age then
				if love.math.random() < (pp.race.max_age - pp.age) / (pp.race.max_age - pp.race.elder_age) * death_rate then
					to_remove[#to_remove + 1] = pp
				end
			elseif pp.age > pp.race.teen_age then
				-- teens and older adults have reduced chance to conceive
				local base = 1
				if pp.age < pp.race.adult_age then
					base = base * (pp.age - pp.race.teen_age) / (pp.race.adult_age - pp.race.teen_age)
				elseif pp.age >= pp.race.middle_age then
					base = base * (1 - (pp.age - pp.race.middle_age) / (pp.race.elder_age - pp.race.middle_age))
				end
				if love.math.random() < base * rate then
					-- yay! spawn a new pop!
					to_add[#to_add + 1] = pp
				end
			end
		end)
	end)
	-- Kill old pops...
	for _, pp in pairs(to_remove) do
		if pp:is_character() then
			WORLD:emit_immediate_event("death", pp, province)
		else
			province:kill_pop(pp)
		end
	end
	-- Add new pops...
	for _, pp in pairs(to_add) do
		local character = pp:is_character()
		local newborn = POP:new(
			pp.race,
			pp.faith,
			pp.culture,
			love.math.random() > pp.race.males_per_hundred_females / (100 + pp.race.males_per_hundred_females),
			0,
			pp.home_province, province,
			character
		)
		if character then
			newborn.mother = pp
			pp.children[newborn] = newborn
			newborn.rank = character_ranks.NOBLE
			local needs = newborn.race.male_needs
			if newborn.female then
				needs = newborn.race.female_needs
			end
			-- set newborn to parents satisfaction
			newborn.need_satisfaction = tabb.accumulate(pp.need_satisfaction, newborn.need_satisfaction, function (need_satisfaction, need, cases)
				need_satisfaction[need] = tabb.accumulate(cases, need_satisfaction[need], function (case_satisfaction, case, values)
					local demanded = (needs[need] and needs[need][case] or 0) * newborn:get_age_multiplier()
					if demanded > 0 then
						case_satisfaction[case] = { consumed = values.consumed / values.demanded * demanded, demanded = demanded}
					end
					return case_satisfaction
				end)
				return need_satisfaction
			end)
			WORLD:emit_immediate_event('character-child-birth-notification', pp, newborn)
		end
	end

	-- province:validate_population()
end

return pg