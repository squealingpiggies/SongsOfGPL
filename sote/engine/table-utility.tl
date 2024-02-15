local record tab
	clear: function<K,V>(table_to_clear: {K:V})
	copy: function<K,V>(input_table: {K:V}):{K:V}
	print: function<K,V>(table_to_print: {K:V})
--	deep_print: function<K,V>(table_to_print: {K:V}, depth: string|nil)
	contains: function<K,V>(table_to_check_for: {K:V}, value_to_check_for: function(V):boolean):boolean
	size: function<K,V>(table_to_use: {K:V}):number
	nth: function<K,V>(table_to_use: {K:V}, n: number): (K,V)
	select_one: function<T>(number: number, items: {number:{T,number}}):T
	random_select: function<T>(items: {T:number}):T
	random_select_from_set: function<K,V>(items: {K:V}): {K:V}
	filter: function<K,V>(items: {K:V}, filter: function(V):boolean): {K:V}
end
---Clears a table
tab.clear = function<K,V>(table_to_clear: {K:V})
	for k, _ in pairs(table_to_clear) do
		table_to_clear[k] = nil
	end
end
--- Returns a shallow copy of a table
tab.copy = function<K,V>(input_table: {K:V}):{K:V}
	local ret = {}
	for i, j in pairs(input_table) do
		ret[i] = j
	end
	return ret
end
--- Prints a table (shallowly)
tab.print = function<K,V>(table_to_print: {K:V})
	print(tostring(table_to_print) .. ' = {')
	for i, j in pairs(table_to_print) do
		print('  ' .. tostring(i) .. ': ' .. tostring(j) .. ',')
	end
	print('}')
end
---Given a table, iterate over ipairs and return a boolean for whether or not a value is in the table.
tab.contains = function<K,V>(table_to_check_for: {K:V}, value_to_check_for: V):boolean
	for _, v in pairs(table_to_check_for) do
		if v == value_to_check_for then
			return true
		end
	end
	return false
end
---Returns the number of entries if iterated over with pairs, O(n)
tab.size = function<K,V>(table_to_use: {K:V}):number
	local c = 0
	for _, _ in pairs(table_to_use) do
		c = c + 1
	end
	return c
end
---Returns n-th entry in a table when iterated over with pairs, O(n)
---1-indexed, like normal Lua tables.
tab.nth = function<K,V>(table_to_use: {K:V}, n: number): (K,V)
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
tab.select_one = function<K>(number: number, items: {number:{K,number}}):(K,number)
	local total_weight: number = 0
	for _, w in pairs(items) do
		total_weight = total_weight + w[2]
	end
	local weight_thus_far: number = 0
	for _, w in pairs(items) do
		weight_thus_far = weight_thus_far + w[2]
		if weight_thus_far / total_weight > number then
			return w[1]
		end
	end
	return items[1][1]
end
---Given a table of objects mapping to <anything>, return a randomly selected key (equiprobable) and its value
tab.random_select_from_set = function<K,V>(items: {K:V}): (K,V)
	local size = tab.size(items)
	local k, v = tab.nth(items, math.random(size))
	return k, v
end
---Given a table and a function with parameter of table value type that resolves to a boolean,
---return a new table with all values that resolve to true
tab.filter = function<K,V>(items: {K:V}, filter: function(V):boolean): {K:V}
	local r: {K:V} = {}
	for k,v in pairs(items) do
		if filter(v) then
			r[k] = v
		end
	end
	return r
end

return tab