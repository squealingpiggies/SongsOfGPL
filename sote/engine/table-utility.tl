local tab = {}
---Clears a table
function tab.clear<K,V>(table_to_clear: {K:V})
	for k, _ in pairs(table_to_clear) do
		table_to_clear[k] = nil
	end
end
--- Returns a shallow copy of a table
function tab.copy<K,V>(input_table: {K:V}):{K:V}
	local ret = {}
	for i, j in pairs(input_table) do
		ret[i] = j
	end
	return ret
end
--- Prints a table (shallowly)
function tab.print<K,V>(table_to_print: {K:V})
	print(tostring(table_to_print) .. ' = {')
	for i, j in pairs(table_to_print) do
		print('  ' .. tostring(i) .. ': ' .. tostring(j) .. ',')
	end
	print('}')
end
---Given a table, iterate over ipairs and return a boolean for whether or not a value is in the table.
function tab.contains<K,V>(table_to_check_for: {K:V}, value_to_check_for: V):boolean
	for _, v in pairs(table_to_check_for) do
		if v == value_to_check_for then
			return true
		end
	end
	return false
end
---Returns the number of entries if iterated over with pairs, O(n)
function tab.size<K,V>(table_to_use: {K:V}):number
	local c = 0
	for _, _ in pairs(table_to_use) do
		c = c + 1
	end
	return c
end
---Returns n-th entry in a table when iterated over with pairs, O(n)
---1-indexed, like normal Lua tables.
function tab.nth<K,V>(table_to_use: {K:V}, n: number): (K,V)
	local nth = 0
	for k, v in pairs(table_to_use) do
		nth = nth + 1
		if nth == n then
			return k, v
		end
	end
	return nil, nil
end
---Given a number between 0 and 1, returns a weighted entry.
function tab.select_one<K>(number: number, items: {K:number}):(K, number)
	local total_weight: number = 0
	for _, w in pairs(items) do
		total_weight = total_weight + w
	end
	local weight_thus_far: number = 0
	for k, w in pairs(items) do
		weight_thus_far = weight_thus_far + w
		if weight_thus_far / total_weight > number then
			return k
		end
	end
	return tab.nth(items,1)
end
---Given a table of objects mapping to numbers (weights), return a randomly selected entry
function tab.random_select<K>(items: {K:number}):(K,number)
	local weight: number = 0
	for _, v in pairs(items) do
		weight = weight + v
	end

	if weight > 0 then
		local threshold = math.random() * weight
		local sum: number = 0
		for k, v in pairs(items) do
			sum = sum + v
			if sum >= threshold then
				return k
			end
		end
	end
	return tab.nth(items, 1)
end
---Given a table of objects mapping to <anything>, return a randomly selected key (equiprobable) and its value
function tab.random_select_from_set<K,V>(items: {K:V}): (K,V)
	local size = tab.size(items)
	local k, v = tab.nth(items, math.random(size))
	return k, v
end
---Given a table and a function with parameter of table value type that resolves to a boolean,
---return a new table with all values that resolve to true
function tab.filter<K,V>(items: {K:V}, filter: function(V):boolean): {K:V}
	local r: {K:V} = {}
	for k,v in pairs(items) do
		if filter(v) then
			r[k] = v
		end
	end
	return r
end

return tab