local JOBTYPE = require "game.raws.job_types"

local ll = {}

function ll.load()
	local Race = require "game.raws.race"

	Race:new {
		name = "human",
		r = 0.85,
		g = 0.85,
		b = 0.85,
		icon = 'barbute.png',
	}
	Race:new {
		name = 'high beaver',
		r = 0.68,
		g = 0.4,
		b = 0.3,
		icon = 'beaver.png',
		description = 'high beavers',
		males_per_hundred_females = 108,
		child_age = 4,
		teen_age = 15,
		adult_age = 20,
		middle_age = 50,
		elder_age = 70,
		max_age = 100,
		minimum_comfortable_temperature = -5,
		minimum_absolute_temperature = -25,
		fecundity = 0.85,
		spotting = 0.5,
		visibility = 2,
		female_body_size = 1.5,
		female_efficiency = {
			[JOBTYPE.FARMER] = 1,
			[JOBTYPE.ARTISAN] = 1.5,
			[JOBTYPE.CLERK] = 1,
			[JOBTYPE.LABOURER] = 2,
			[JOBTYPE.WARRIOR] = 1.1,
			[JOBTYPE.HAULING] = 2,
			[JOBTYPE.FORAGER] = 1.2
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 3
			},
			[NEED.FOOD] = {
				['food'] = 1.2,
				['timber'] = 0.1,
				['grain'] = 0.2,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.125 / 2 -- beavers have really nice fur
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 / 4,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 2,
			},
		},
		female_infrastructure_needs = 2,
		male_body_size = 2,
		male_efficiency = {
			[JOBTYPE.FARMER] = 1,
			[JOBTYPE.ARTISAN] = 1.5,
			[JOBTYPE.CLERK] = 1,
			[JOBTYPE.LABOURER] = 2,
			[JOBTYPE.WARRIOR] = 1.1,
			[JOBTYPE.HAULING] = 2,
			[JOBTYPE.FORAGER] = 1.2
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 3
			},
			[NEED.FOOD] = {
				['food'] = 1.2,
				['timber'] = 0.1,
				['grain'] = 0.2,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.125 / 2 -- beavers have really nice fur
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 / 4,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 2,
			},
		},
		male_infrastructure_needs = 2,

		carrying_capacity_weight = 1.1,
		requires_large_river = true
	}
	Race:new {
		name = 'elf',
		r = 0.1,
		g = 0.5,
		b = 0.1,
		icon = 'woman-elf-face.png',
		description = 'elves',
		males_per_hundred_females = 100,
		child_age = 5,
		teen_age = 100,
		adult_age = 200,
		middle_age = 650,
		elder_age = 800,
		max_age = 1000,
		minimum_comfortable_temperature = -5,
		minimum_absolute_temperature = -15,
		fecundity = 0.5,
		spotting = 2,
		visibility = 0.5,
		female_body_size = 0.9,
		female_efficiency = {
			[JOBTYPE.FARMER] = 1,
			[JOBTYPE.ARTISAN] = 1.8,
			[JOBTYPE.CLERK] = 1.5,
			[JOBTYPE.LABOURER] = 0.8,
			[JOBTYPE.WARRIOR] = 1.5,
			[JOBTYPE.HAULING] = 0.8,
			[JOBTYPE.FORAGER] = 1.5
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['food'] = 0.75,
				['grain'] = 0.25,
				['fruit'] = 0.25,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 / 4,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 1,
			},
		},
		female_infrastructure_needs = 5,
		male_body_size = 0.95,
		male_efficiency = {
			[JOBTYPE.FARMER] = 1,
			[JOBTYPE.ARTISAN] = 1.8,
			[JOBTYPE.CLERK] = 1.5,
			[JOBTYPE.LABOURER] = 0.8,
			[JOBTYPE.WARRIOR] = 1.5,
			[JOBTYPE.HAULING] = 0.8,
			[JOBTYPE.FORAGER] = 1.5
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['food'] = 0.85,
				['grain'] = 0.2,
				['fruit'] = 0.2,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 / 2,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 1,
			},
		},
		male_infrastructure_needs = 5,
		carrying_capacity_weight = 2,

		requires_large_forest = true

	}
	Race:new {
		name = 'dwarf',
		r = 0.99,
		g = 0.106,
		b = 0.133,
		icon = 'dwarf.png',
		description = 'dwarf',
		males_per_hundred_females = 102,
		child_age = 4,
		teen_age = 30,
		adult_age = 50,
		middle_age = 150,
		elder_age = 250,
		max_age = 300,
		minimum_comfortable_temperature = -10,
		minimum_absolute_temperature = -25,
		minimum_comfortable_elevation = 800,
		fecundity = 0.75,
		spotting = 0.75,
		visibility = 1.0,
		female_body_size = 0.7,
		female_efficiency = {
			[JOBTYPE.FARMER] = 1.1,
			[JOBTYPE.ARTISAN] = 2.5,
			[JOBTYPE.CLERK] = 1.2,
			[JOBTYPE.LABOURER] = 1.8,
			[JOBTYPE.WARRIOR] = 1.1,
			[JOBTYPE.HAULING] = 1.1,
			[JOBTYPE.FORAGER] = 0.8
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['food'] = 0.7,
				['meat'] = 0.25,
				['grain'] = 0.25,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 * 2,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 1.5,
			},
		},
		female_infrastructure_needs = 3,
		male_body_size = 0.8,
		male_efficiency = {
			[JOBTYPE.FARMER] = 1.1,
			[JOBTYPE.ARTISAN] = 2.5,
			[JOBTYPE.CLERK] = 1.2,
			[JOBTYPE.LABOURER] = 1.8,
			[JOBTYPE.WARRIOR] = 1.1,
			[JOBTYPE.HAULING] = 1.1,
			[JOBTYPE.FORAGER] = 0.8
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['food'] = 0.8,
				['meat'] = 0.25,
				['grain'] = 0.25,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 * 2,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 1.5,
			},
		},
		male_infrastructure_needs = 3,
		carrying_capacity_weight = 1.5,

	}

	Race:new {
		name = 'Goblin',
		r = 0.1,
		g = 0.7,
		b = 0.1,
		icon = 'goblin.png',
		description = 'goblin',
		males_per_hundred_females = 102,
		child_age = 1,
		teen_age = 5,
		adult_age = 10,
		middle_age = 20,
		elder_age = 35,
		max_age = 50,
		minimum_comfortable_temperature = 5,
		minimum_absolute_temperature = -10,
		fecundity = 4,
		spotting = 0.75,
		visibility = 0.75,
		female_body_size = 0.5,
		female_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.25,
			[JOBTYPE.CLERK] = 0.25,
			[JOBTYPE.LABOURER] = 0.25,
			[JOBTYPE.WARRIOR] = 0.25,
			[JOBTYPE.HAULING] = 0.5,
			[JOBTYPE.FORAGER] = 0.25
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 0.25
			},
			[NEED.FOOD] = {
				['food'] = 0.3,
				['fruit'] = 0.1,
				['meat'] = 0.1,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.25
			},
			[NEED.FURNITURE] = {
				['furniture'] = 0.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 / 2,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 1,
			},
		},
		female_infrastructure_needs = 0.25,
		male_body_size = 0.6,
		male_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.25,
			[JOBTYPE.CLERK] = 0.25,
			[JOBTYPE.LABOURER] = 0.25,
			[JOBTYPE.WARRIOR] = 0.25,
			[JOBTYPE.HAULING] = 0.5,
			[JOBTYPE.FORAGER] = 0.25
		},
		male_needs = {
			[NEED.WATER] = { ['water'] = 0.25 },
			[NEED.FOOD] = {
				['food'] = 0.3,
				['fruit'] = 0.1,
				['meat'] = 0.1,
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.25
			},
			[NEED.FURNITURE] = {
				['furniture'] = 0.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.125 / 2,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.125,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.125,
			},
			[NEED.LUXURY] = {
				['intoxicants'] = 1,
			},
		},
		male_infrastructure_needs = 0.25,
		carrying_capacity_weight = 0.25,
	}


	-- for testing purpose
	-- Race:new {
	-- 	name = 'WeakGoblin',
	-- 	r = 0.0,
	-- 	g = 0.9,
	-- 	b = 0.0,
	-- 	icon = 'goblin.png',
	-- 	description = 'weak goblin',
	-- 	males_per_hundred_females = 102,
	-- 	child_age = 1,
	-- 	teen_age = 2,
	-- 	adult_age = 3,
	-- 	middle_age = 4,
	-- 	elder_age = 5,
	-- 	max_age = 6,
	-- 	minimum_comfortable_temperature = 5,
	-- 	minimum_absolute_temperature = -10,
	-- 	fecundity = 4,
	-- 	spotting = 1.5,
	-- 	visibility = 0.5,
	-- 	female_body_size = 0.5,
	-- 	female_efficiency = {
	-- 		[JOBTYPE.FARMER] = 0.25,
	-- 		[JOBTYPE.ARTISAN] = 0.25,
	-- 		[JOBTYPE.CLERK] = 0.25,
	-- 		[JOBTYPE.LABOURER] = 0.25,
	-- 		[JOBTYPE.WARRIOR] = 0.25,
	-- 		[JOBTYPE.HAULING] = 0.5,
	-- 		[JOBTYPE.FORAGER] = 0.25
	-- 	},
	-- 	female_needs = {
	-- 		[NEED.WATER] = 0.25,
	-- 		[NEED.FOOD] = 0.25,
	-- 		-- [NEED.FRUIT] = 0.25,
	-- 		-- [NEED.GRAIN] = 0.25,
	-- 		-- [NEED.MEAT] = 0.25,
	-- 		[NEED.CLOTHING] = 0.25,
	-- 		[NEED.FURNITURE] = 0.25,
	-- 		[NEED.TOOLS] = 0.125 / 2,
	-- 		[NEED.HEALTHCARE] = 0.125,
	-- 		[NEED.STORAGE] = 0.125,
	-- 		[NEED.LUXURY] = 1
	-- 	},
	-- 	female_infrastructure_needs = 0.25,
	-- 	male_body_size = 0.6,
	-- 	male_efficiency = {
	-- 		[JOBTYPE.FARMER] = 0.25,
	-- 		[JOBTYPE.ARTISAN] = 0.25,
	-- 		[JOBTYPE.CLERK] = 0.25,
	-- 		[JOBTYPE.LABOURER] = 0.25,
	-- 		[JOBTYPE.WARRIOR] = 0.25,
	-- 		[JOBTYPE.HAULING] = 0.5,
	-- 		[JOBTYPE.FORAGER] = 0.25
	-- 	},
	-- 	male_needs = {
	-- 		[NEED.WATER] = 0.25,
	-- 		[NEED.FOOD] = 0.25,
	-- 		-- [NEED.FRUIT] = 0.25,
	-- 		-- [NEED.GRAIN] = 0.25,
	-- 		-- [NEED.MEAT] = 0.25,
	-- 		[NEED.CLOTHING] = 0.25,
	-- 		[NEED.FURNITURE] = 0.25,
	-- 		[NEED.TOOLS] = 0.125 / 2,
	-- 		[NEED.HEALTHCARE] = 0.125,
	-- 		[NEED.STORAGE] = 0.125,
	-- 		[NEED.LUXURY] = 1
	-- 	},
	-- 	male_infrastructure_needs = 0.25,
	-- 	carrying_capacity_weight = 0.25,
	-- }
end

return ll
