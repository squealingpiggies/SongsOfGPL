local pg = {}

---Runs pop aging on all pops in a single province
---@param province Province
function pg.age(province)
	for _, pp in pairs(province.all_pops) do
		pp.age = pp.age + 1
	end
	for _, pp in pairs(province.outlaws) do
		pp.age = pp.age + 1
	end
	for _, char in pairs(province.characters) do
		char.age = char.age + 1
	end
	for _, group in pairs(province:get_pop_groups()) do
		group:calculate_needs()
	end
end

return pg
