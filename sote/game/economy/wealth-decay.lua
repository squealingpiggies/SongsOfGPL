local dec = {}

---Runs wealth decay on all provinces!
function dec.run()
	DATA.for_each_province(function (item)
		DATA.province_set_local_wealth(item,DATA.province_get_local_wealth(item) * 0.9999)
		DATA.province_set_trade_wealth(item,DATA.province_get_trade_wealth(item) * 0.9999)
	end)
end

return dec
