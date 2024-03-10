local pg = {}

local POP = require "game.entities.pop".POP
local tabb = require "engine.table"
local character_ranks = require "game.raws.ranks.character_ranks"

---Runs natural growth and decay on a single province.
---@param province Province
function pg.growth(province)
	-- First, get the carrying capacity...
	local cc = province.foragers_limit
	local pop = province:population_weight()

	local death_rate = 1 / 12 / 4
	local birth_rate = 1 / 12 / 2

	-- Mark pops for removal...
	---@type POP[]
	local to_remove = {}
	---@type POP[]
	local to_add = {}

	local eligible = {}
	for _, pp in pairs(province.outlaws) do
		if pp.age > pp.race.max_age then
			to_remove[#to_remove + 1] = pp
		end
	end

	local race_sex = tabb.accumulate(tabb.join(tabb.copy(province.all_pops), province.characters), {}, function (a, _, pp)
		local food_satisfaction = math.min(pp.need_satisfaction[NEED.FOOD].consumed / pp.need_satisfaction[NEED.FOOD].demanded, 1)
		local water_satisfaction = math.min(pp.need_satisfaction[NEED.WATER].consumed / pp.need_satisfaction[NEED.WATER].demanded, 1)

		if pp.age > pp.race.max_age then
			to_remove[#to_remove + 1] = pp
		elseif food_satisfaction < 0.1 or pp.age > pp.race.elder_age then
			-- Deaths due to starvation or old age!
			if love.math.random() * food_satisfaction * water_satisfaction < (1 - cc / pop) * death_rate then
				to_remove[#to_remove + 1] = pp
			end
		else -- check if eligible to create more pop
			if a[pp.race] == nil then
				a[pp.race] = {
					[true] = 0,
					[false] = 0,
					['children'] = 0
				}
			end
			if pp.age < pp.race.teen_age then
				a[pp.race]['children'] = a[pp.race]['children'] + 1
			elseif food_satisfaction > 0.1 + 0.1 / pp.race.fecundity then
				a[pp.race][pp.female] = a[pp.race][pp.female] + 1
				if not pp:is_character() or tabb.size(pp.children) < 1 then
					eligible[pp] = pp
				end
			end
		end
		return a
	end)

	tabb.accumulate(eligible, to_add, function (a, _, pp)
		---@type POP
		pp = pp
		local sex_prob = race_sex[pp.race][not pp.female] / race_sex[pp.race][pp.female]

		-- if it's a female adult ...
		-- commenting out because it leads to instant explosion of population in low population provinces
		-- if pop < cc then
		-- 	if love.math.random() < (1 - pop / cc) * birth_rate * pp.race.fecundity / pp.race.carrying_capacity_weight then
		-- 		-- yay! spawn a new pop!
		-- 		to_add[#to_add + 1] = pp
		-- 	end
		-- end

		-- This pop growth is caused by overproduction of resources in the realm.
		-- The chance for growth should then depend on the amount of food produced
		-- Make sure that the expected food consumption has been calculated by this point!

		-- base on ratio of avaialbe breeding age pops
		local diff = race_sex[pp.race][not pp.female]
		local same = race_sex[pp.race][pp.female]
		local base = math.max(diff / same, 1)
		-- Calculate the fraction symbolizing the amount of "overproduction" of food
		base = base * pp.need_satisfaction[NEED.FOOD].consumed / pp.need_satisfaction[NEED.FOOD].demanded

		local fem = 100 / (100 + pp.race.males_per_hundred_females)
		local offspring = fem * pp.race.female_needs[NEED.FOOD] + (1 - fem) * pp.race.male_needs[NEED.FOOD]
		-- reduce rate based on number of children in province and cared for
		local children = race_sex[pp.race]['children']
		local dependents = tabb.size(pp.children)
		local rate = 1 / offspring
			* (diff + same) / math.max(1, 2 * children) ---@diagnostic disable-line
			* pp.race.fecundity / math.max(1, dependents)

		if love.math.random() < sex_prob * birth_rate * base * rate then
			-- yay! spawn a new pop!
			a[#to_add + 1] = pp
		end
		return a
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
		newborn.parent = pp
		pp.children[newborn] = newborn

		if character then
			newborn.rank = character_ranks.NOBLE
			WORLD:emit_immediate_event('character-child-birth-notification', pp, newborn)
		end
	end

	-- province:validate_population()
end

return pg
