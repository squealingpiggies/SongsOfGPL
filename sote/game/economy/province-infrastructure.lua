local pop_utils = require "game.entities.pop".POP

local r = {}

---
function r.run()
	---#logging LOGS:write("province infrastructure " .. tostring(province).."\n")
	---#logging LOGS:flush()

	-- First, calculate infrastructure needs
	local prov_inf = {}

	-- From pops
	DATA.for_each_pop(function (pop)
		local province = PROVINCE(pop)
		local race = DATA.fatten_race(DATA.pop_get_race(pop))
		local female = DATA.pop_get_female(pop)

		local n = race.male_infrastructure_needs
		if female then
			n = race.female_infrastructure_needs
		end
		---@type number
		prov_inf[province] = (prov_inf[province] or 0) + n * AGE_MULTIPLIER(pop)
	end)

	-- From buildings
	DATA.for_each_building_estate(function (location)
		local province = ESTATE_PROVINCE(DATA.building_estate_get_estate(location))
		local building = DATA.building_estate_get_building(location)
		local building_type = DATA.building_get_current_type(building)
		local infrastructure_needs = DATA.building_type_get_needed_infrastructure(building_type)
		---@type number
		prov_inf[province] = (prov_inf[province] or 0) + infrastructure_needs
	end)

	DATA.for_each_province(function (item)
		-- decay local and trade wealth
		DATA.province_set_local_wealth(item,DATA.province_get_local_wealth(item) * 0.9999)
		DATA.province_set_trade_wealth(item,DATA.province_get_trade_wealth(item) * 0.9999)

		-- Write the needs
		local inf = prov_inf[item] or 0
		DATA.province_set_infrastructure_needed(item,inf)

		-- Once we know the needed infrastructure, handle investments
		local inv = DATA.province_get_infrastructure_investment(item)
		local spillover = 0
		if inv > inf then
			spillover = inv - inf
		end
		-- If we're overinvested, remove a fraction above the invested amount
		inv = inv - spillover * 0.9

		-- Lastly, invest a fraction of the investment into actual infrastructure
		local invested = inv * (1 / (12 * 5)) -- 5 years to invest everything
		DATA.province_set_infrastructure_investment(item,inv - invested)
		local new_inf = DATA.province_get_infrastructure(item) + invested

		-- At the very end, apply some decay to present infrastructure as to prevent runaway growth
		local infrastructure_decay_rate = 1 - 1 / (12 * 100) -- 100 years to decay everything
		if DATA.province_get_infrastructure(item) > inf then
			infrastructure_decay_rate = 1 - 1 / (12 * 50) -- 50 years to decay the part above the needed amount
		end
		DATA.province_set_infrastructure(item, new_inf * infrastructure_decay_rate)
	end)
end

return r
