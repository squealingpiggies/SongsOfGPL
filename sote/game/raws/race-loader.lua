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

	local beaver_portrait = {
		folder = "beaver",
		layers = {"cloth_behind.png", "base.png", "over_1.png", "over_2.png", "ear.png", "cloth.png"},
		layers_groups = {
			cloth = {"cloth_behind.png", "cloth.png"}
		}
	}

	Race:new {
		name = 'high beaver',
		r = 0.68,
		g = 0.4,
		b = 0.3,
		icon = 'beaver.png',
		male_portrait = {
			--- fallback is a portrait description which is active when needed portrait is not provided
			fallback = beaver_portrait,

			--- just to list all possible fields
			child = beaver_portrait,
			teen = beaver_portrait,
			adult = beaver_portrait,
			middle = beaver_portrait,
			elder = beaver_portrait
		},
		female_portrait = {
			fallback = beaver_portrait
		},
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
		visibility = 1.5,
		female_body_size = 1.25,
		female_efficiency = {
			[JOBTYPE.FARMER] = 1.0,
			[JOBTYPE.ARTISAN] = 2.0,
			[JOBTYPE.CLERK] = 1.50,
			[JOBTYPE.LABOURER] = 1.5,
			[JOBTYPE.WARRIOR] = 1.25,
			[JOBTYPE.HAULING] = 1.5,
			[JOBTYPE.FORAGER] = 2.0,
			[JOBTYPE.HUNTING] = 0.25
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 2.5
			},
			[NEED.FOOD] = {
				['calories'] = 1.25,	-- 1250 kcal
				['timber'] = 0.5,		-- 1000 kcal
				['grain'] = 0.25,		--  250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1.25 / 4 -- beavers have really nice fur
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1.25 / 4, -- beavers have really sharp teeth
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 1.25,
			},
			[NEED.STORAGE] = {
				['containers'] = 2.5,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.25,
			},
		},
		female_infrastructure_needs = 2,
		male_body_size = 2,
		male_efficiency = {
			[JOBTYPE.FARMER] = 1.0,
			[JOBTYPE.ARTISAN] = 2.0,
			[JOBTYPE.CLERK] = 1.25,
			[JOBTYPE.LABOURER] = 2.0,
			[JOBTYPE.WARRIOR] = 1.5,
			[JOBTYPE.HAULING] = 2.0,
			[JOBTYPE.FORAGER] = 2.0,
			[JOBTYPE.HUNTING] = 0.25
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 4.0
			},
			[NEED.FOOD] = {
				['calories'] = 2,		-- 2000 kcal
				['timber'] = 0.75,		-- 1500 kcal
				['grain'] = 0.5,		--  500 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 2.0 / 4 -- beavers have really nice fur
			},
			[NEED.FURNITURE] = {
				['furniture'] = 2.0
			},
			[NEED.TOOLS] = {
				['tools-like'] = 2.0 / 4, -- beavers have really sharp teeth
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 1.25,
			},
			[NEED.STORAGE] = {
				['containers'] = 4.0,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.25,
			},
		},
		male_infrastructure_needs = 4,

		carrying_capacity_weight = 1.25,
		requires_large_river = true
	}

	local gnoll_portrait = {
		folder = "gnoll",
		layers = {"base.PNG", "braid.PNG", "spine.PNG", "pattern.PNG", "eye.PNG"},
		layers_groups = {}
	}

	Race:new {
		name = 'gnoll',
		r = 0.8,
		g = 0.1,
		b = 0.3,
		icon = 'hound.png',
		male_portrait = {
			fallback = gnoll_portrait
		},
		female_portrait = {
			fallback = gnoll_portrait
		},
		description = 'gnolls',
		males_per_hundred_females = 50,
		child_age = 2,
		teen_age = 6,
		adult_age = 10,
		middle_age = 20,
		elder_age = 35,
		max_age = 40,
		minimum_comfortable_temperature = 0,
		minimum_absolute_temperature = -15,
		fecundity = 1.5,
		spotting = 2,
		visibility = 2,
		female_body_size = 2,
		female_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.25,
			[JOBTYPE.CLERK] = 0.25,
			[JOBTYPE.LABOURER] = 2,
			[JOBTYPE.WARRIOR] = 1.5,
			[JOBTYPE.HAULING] = 2,
			[JOBTYPE.FORAGER] = 0.25,
			[JOBTYPE.HUNTING] = 2.0
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 3.0
			},
			[NEED.FOOD] = {
				['calories'] = 2.0,		-- 2000 kcal
				['meat'] = 1.0,			-- 2000 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 2.0 / 2, -- gnolls have nice fur
			},
			[NEED.FURNITURE] = {
				['furniture'] = 2.0
			},
			[NEED.TOOLS] = {
				['tools-like'] = 2.0 / 2, -- gnolls have sharp teeth
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 2.0,
			},
			[NEED.STORAGE] = {
				['containers'] = 3.0,
			},
			[NEED.LUXURY] = {
				['liquors'] = 2.0,
			}
		},
		female_infrastructure_needs = 3.0,
		male_body_size = 1.25,
		male_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.25,
			[JOBTYPE.CLERK] = 0.25,
			[JOBTYPE.LABOURER] = 1.25,
			[JOBTYPE.WARRIOR] = 1.25,
			[JOBTYPE.HAULING] = 1.25,
			[JOBTYPE.FORAGER] = 0.25,
			[JOBTYPE.HUNTING] = 2.0
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 2.375
			},
			[NEED.FOOD] = {
				['calories'] = 1.5,	-- 1500 kcal
				['meat'] = 0.5,		-- 1000 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1.25 / 2, -- gnolls have nice fur
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1.25 / 2, -- gnolls have sharp teeth
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 2.0,
			},
			[NEED.STORAGE] = {
				['containers'] = 2.375,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.25,
			}
		},
		male_infrastructure_needs = 1.5,

		carrying_capacity_weight = 2
	}

	local orc_portrait = {
		folder = "orc",
		layers = {"base.PNG", "chin.PNG", "right_eye.PNG", "nose_mouth.PNG", "left_eye.PNG", "pattern.PNG", "hair.PNG", "cloth.PNG"},
		layers_groups = {
			eyes = {"right_eye.PNG", "left_eye.PNG"}
		}
	}

	Race:new {
		name = 'orc',
		r = 0.1,
		g = 0.8,
		b = 0.3,
		icon = 'orc-head.png',
		male_portrait = {
			fallback = orc_portrait
		},
		female_portrait = {
			fallback = orc_portrait
		},
		description = 'orc',
		males_per_hundred_females = 50,
		child_age = 3,
		teen_age = 7,
		adult_age = 10,
		middle_age = 30,
		elder_age = 50,
		max_age = 65,
		minimum_comfortable_temperature = 0,
		minimum_absolute_temperature = -15,
		fecundity = 1.1,
		spotting = 1,
		visibility = 1.1,
		female_body_size = 1.1,
		female_efficiency = {
			[JOBTYPE.FARMER] = 0.75,
			[JOBTYPE.ARTISAN] = 0.75,
			[JOBTYPE.CLERK] = 0.5,
			[JOBTYPE.LABOURER] = 1.25,
			[JOBTYPE.WARRIOR] = 1.5, -- orks have tusks
			[JOBTYPE.HAULING] = 1.25,
			[JOBTYPE.FORAGER] = 1.5,
			[JOBTYPE.HUNTING] = 1.5
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 2.0
			},
			[NEED.FOOD] = {
				['calories'] = 3,		-- 3000 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1.1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1.1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1.1 / 2 , -- orks have tusks
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 1.5,
			},
			[NEED.STORAGE] = {
				['containers'] = 2.0,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.1,
			},
		},
		female_infrastructure_needs = 1.0,
		male_body_size = 1.1,
		male_efficiency = {
			[JOBTYPE.FARMER] = 0.75,
			[JOBTYPE.ARTISAN] = 0.75,
			[JOBTYPE.CLERK] = 0.5,
			[JOBTYPE.LABOURER] = 1.25,
			[JOBTYPE.WARRIOR] = 1.5, -- orks have tusks
			[JOBTYPE.HAULING] = 1.25,
			[JOBTYPE.FORAGER] = 1.5,
			[JOBTYPE.HUNTING] = 1.5
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 2.0
			},
			[NEED.FOOD] = {
				['calories'] = 3.0,		-- 3000 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1.1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1.1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1.1 / 2 , -- orks have tusks
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 1.5,
			},
			[NEED.STORAGE] = {
				['containers'] = 2.0,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.1,
			},
		},
		male_infrastructure_needs = 1.0,

		carrying_capacity_weight = 1.5
	}

	Race:new {
		name = 'elf',
		r = 0.1,
		g = 0.5,
		b = 0.1,
		icon = 'woman-elf-face.png',
		male_portrait = {
			fallback = {
				folder = "null_middle",
				layers = {"hair_behind.png", "base.png", "neck.png", "cheeks.png",
							"chin.png", "ear.png", "eyes.png", "nose.png", "mouth.png", "hair.png", "clothes.png", "beard.png"},
				layers_groups = {
					hair = {"hair_behind.png", "hair.png"}
				}
			}
		},
		female_portrait = {
			fallback = {
				folder = "null_middle",
				layers = {"hair_behind.png", "base.png", "neck.png", "cheeks.png",
							"chin.png", "ear.png", "eyes.png", "nose.png", "mouth.png", "hair.png", "clothes.png"},
				layers_groups = {
					hair = {"hair_behind.png", "hair.png"}
				}
			}
		},
		description = 'elves',
		males_per_hundred_females = 100,
		child_age = 10,
		teen_age = 50,
		adult_age = 100,
		middle_age = 400,
		elder_age = 700,
		max_age = 1000,
		minimum_comfortable_temperature = -5,
		minimum_absolute_temperature = -15,
		fecundity = 0.5,
		spotting = 2,
		visibility = 0.5,
		female_body_size = 0.9,
		female_efficiency = {
			[JOBTYPE.FARMER] = 1,
			[JOBTYPE.ARTISAN] = 1.5,
			[JOBTYPE.CLERK] = 2.0,
			[JOBTYPE.LABOURER] = 0.75,
			[JOBTYPE.WARRIOR] = 1.5,
			[JOBTYPE.HAULING] = 0.75,
			[JOBTYPE.FORAGER] = 1,
			[JOBTYPE.HUNTING] = 1
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['calories'] = 0.9,		-- 900 kcal
				['fruit'] = 0.5,		-- 500 kcal
				['grain'] = 0.4,		-- 400 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 2,
			},
			[NEED.STORAGE] = {
				['containers'] = 1,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1,
			},
		},
		female_infrastructure_needs = 5,
		male_body_size = 0.9,
		male_efficiency = {
			[JOBTYPE.FARMER] = 1,
			[JOBTYPE.ARTISAN] = 1.5,
			[JOBTYPE.CLERK] = 2.0,
			[JOBTYPE.LABOURER] = 0.75,
			[JOBTYPE.WARRIOR] = 1.5,
			[JOBTYPE.HAULING] = 0.75,
			[JOBTYPE.FORAGER] = 1,
			[JOBTYPE.HUNTING] = 1
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['calories'] = 0.95,	-- 950 kcal
				['fruit'] = 0.5,		-- 500 kcal
				['grain'] = 0.45,		-- 450 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 2,
			},
			[NEED.STORAGE] = {
				['containers'] = 1,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1,
			},
		},
		male_infrastructure_needs = 5,
		carrying_capacity_weight = 2,

		requires_large_forest = true
	}

	---@type PortraitDescription
	local dwarf_portrait = {
		folder = "dwarf",
		layers = {"cloth behind.PNG", "base.PNG", "cloth.PNG", "beard_front.PNG", "hair_front.PNG", "hat.PNG"},
		layers_groups = {cloth = {"cloth behind.PNG", "cloth.PNG"}}
	}

	Race:new {
		name = 'dwarf',
		r = 0.99,
		g = 0.106,
		b = 0.133,
		icon = 'dwarf.png',
		male_portrait = {
			fallback = dwarf_portrait
		},
		female_portrait = {
			fallback = dwarf_portrait
		},
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
		spotting = 1.0,
		visibility = 0.75,
		female_body_size = 0.75,
		female_efficiency = {
			[JOBTYPE.FARMER] = 1.0,
			[JOBTYPE.ARTISAN] = 2.0,
			[JOBTYPE.CLERK] = 1.5,
			[JOBTYPE.LABOURER] = 2.0,
			[JOBTYPE.WARRIOR] = 1.0,
			[JOBTYPE.HAULING] = 1.5,
			[JOBTYPE.FORAGER] = 1.0,
			[JOBTYPE.HUNTING] = 1.0
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['calories'] = 1.5,	-- 1500 kcal
				['meat'] = 0.25,	--  500 kcal
				['fruit'] = 0.25,	--  250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1.5, -- a short, sturdy creature fond of drink and industry 
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 1.5,
			},
			[NEED.STORAGE] = {
				['containers'] = 1,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.5, -- a short, sturdy creature fond of drink and industry 
			},
		},
		female_infrastructure_needs = 3,
		male_body_size = 0.75,
		male_efficiency = {
			[JOBTYPE.FARMER] = 1.0,
			[JOBTYPE.ARTISAN] = 2.0,
			[JOBTYPE.CLERK] = 1.5,
			[JOBTYPE.LABOURER] = 2.0,
			[JOBTYPE.WARRIOR] = 1.0,
			[JOBTYPE.HAULING] = 1.5,
			[JOBTYPE.FORAGER] = 1.0,
			[JOBTYPE.HUNTING] = 1.0
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 1.25
			},
			[NEED.FOOD] = {
				['calories'] = 1.5,	-- 1500 kcal
				['meat'] = 0.25,	--  500 kcal
				['fruit'] = 0.25,	--  250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 1
			},
			[NEED.FURNITURE] = {
				['furniture'] = 1
			},
			[NEED.TOOLS] = {
				['tools-like'] = 1.5, -- a short, sturdy creature fond of drink and industry 
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 1.5,
			},
			[NEED.STORAGE] = {
				['containers'] = 1,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1.5, -- a short, sturdy creature fond of drink and industry 
			},
		},
		male_infrastructure_needs = 3,
		carrying_capacity_weight = 1.5,

	}

	Race:new {
		name = 'goblin',
		r = 0.1,
		g = 0.7,
		b = 0.1,
		icon = 'goblin.png',
		male_portrait = {
			fallback = {
				folder = "goblin",
				layers = {"04.png", "05.png", "055.png", "06.png", "07.png", "08.png", "09.png", "10.png", "11.png"},
				layers_groups = {
					ear = {"04.png", "07.png"},
					hair = {"055.png", "10.png"}
				}
			}
		},
		female_portrait = {
			fallback = {
				folder = "goblin",
				layers = {"04.png", "05.png", "055.png", "06.png", "07.png", "08.png", "09.png", "10.png"},
				layers_groups = {
					ear = {"04.png", "07.png"},
					hair = {"055.png", "10.png"}
				}
			}
		},
		description = 'goblin',
		males_per_hundred_females = 102,
		child_age = 1,
		teen_age = 5,
		adult_age = 10,
		middle_age = 20,
		elder_age = 40,
		max_age = 50,
		minimum_comfortable_temperature = 5,
		minimum_absolute_temperature = -10,
		fecundity = 2,
		spotting = 0.75,
		visibility = 0.75,
		female_body_size = 0.5,
		female_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.25,
			[JOBTYPE.CLERK] = 0.50,
			[JOBTYPE.LABOURER] = 0.25,
			[JOBTYPE.WARRIOR] = 0.25,
			[JOBTYPE.HAULING] = 0.50,
			[JOBTYPE.FORAGER] = 0.50,
			[JOBTYPE.HUNTING] = 0.25
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 0.25
			},
			[NEED.FOOD] = {
				['calories'] = 0.5,	-- 500 kcal
				['meat'] = 0.25,	-- 500 kcal
				['fruit'] = 0.25,	-- 250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.25
			},
			[NEED.FURNITURE] = {
				['furniture'] = 0.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.5,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.8,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.5,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1,
			},
		},
		female_infrastructure_needs = 0.25,
		male_body_size = 0.5,
		male_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.25,
			[JOBTYPE.CLERK] = 0.50,
			[JOBTYPE.LABOURER] = 0.25,
			[JOBTYPE.WARRIOR] = 0.25,
			[JOBTYPE.HAULING] = 0.50,
			[JOBTYPE.FORAGER] = 0.50,
			[JOBTYPE.HUNTING] = 0.25
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 0.25
			},
			[NEED.FOOD] = {
				['calories'] = 0.5,	-- 500 kcal
				['meat'] = 0.25,	-- 500 kcal
				['fruit'] = 0.25,	-- 250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.25
			},
			[NEED.FURNITURE] = {
				['furniture'] = 0.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.5,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.8,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.5,
			},
			[NEED.LUXURY] = {
				['liquors'] = 1,
			},
		},
		male_infrastructure_needs = 0.25,
		carrying_capacity_weight = 0.8,
	}

	Race:new {
		name = 'verman',
		r = 0.6,
		g = 0.6,
		b = 0.6,
		icon = 'rat.png',
		male_portrait = {
			fallback = {
				folder = "vermen",
				layers = {"ear_behind.PNG", "base.PNG", "ear_front.PNG", "eye.PNG", "patterns.PNG", "cloth.PNG", "hat.PNG"},
				layers_groups = {
					ear = {"ear_behind.PNG", "ear_front.PNG"}
				}
			}
		},
		female_portrait = {
			fallback = {
				folder = "vermen",
				layers = {"ear_behind.PNG", "base.PNG", "ear_front.PNG", "eye.PNG", "patterns.PNG", "cloth.PNG", "hat.PNG"},
				layers_groups = {
					ear = {"ear_behind.PNG", "ear_front.PNG"}
				}
			}
		},
		description = 'vermen',
		males_per_hundred_females = 110,
		child_age = 1,
		teen_age = 2,
		adult_age = 4,
		middle_age = 12,
		elder_age = 21,
		max_age = 25,
		minimum_comfortable_temperature = 15,
		minimum_absolute_temperature = -10,
		fecundity = 4,
		spotting = 2.0,
		visibility = 0.05,
		female_body_size = 0.25,
		female_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.125,
			[JOBTYPE.CLERK] = 0.125,
			[JOBTYPE.LABOURER] = 0.25,
			[JOBTYPE.WARRIOR] = 0.25,
			[JOBTYPE.HAULING] = 0.50,
			[JOBTYPE.FORAGER] = 0.50,
			[JOBTYPE.HUNTING] = 0.125
		},
		female_needs = {
			[NEED.WATER] = {
				['water'] = 0.25
			},
			[NEED.FOOD] = {
				['calories'] = 0.5,	--  500 kcal
				['fruit'] = 0.25,	--  250 kcal
				['grain'] = 0.25,	--  250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.25
			},
			[NEED.FURNITURE] = {
				['furniture'] = 0.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.25,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.5,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.25,
			},
			[NEED.LUXURY] = {
				['liquors'] = 0.25,
			},
		},
		female_infrastructure_needs = 0.1,
		male_body_size = 0.25,
		male_efficiency = {
			[JOBTYPE.FARMER] = 0.25,
			[JOBTYPE.ARTISAN] = 0.125,
			[JOBTYPE.CLERK] = 0.125,
			[JOBTYPE.LABOURER] = 0.25,
			[JOBTYPE.WARRIOR] = 0.25,
			[JOBTYPE.HAULING] = 0.50,
			[JOBTYPE.FORAGER] = 0.50,
			[JOBTYPE.HUNTING] = 0.125
		},
		male_needs = {
			[NEED.WATER] = {
				['water'] = 0.25
			},
			[NEED.FOOD] = {
				['calories'] = 0.5,	--  500 kcal
				['fruit'] = 0.25,	--  250 kcal
				['grain'] = 0.25,	--  250 kcal
			},
			[NEED.CLOTHING] = {
				['clothes'] = 0.25
			},
			[NEED.FURNITURE] = {
				['furniture'] = 0.25
			},
			[NEED.TOOLS] = {
				['tools-like'] = 0.25,
			},
			[NEED.HEALTHCARE] = {
				['healthcare'] = 0.5,
			},
			[NEED.STORAGE] = {
				['containers'] = 0.25,
			},
			[NEED.LUXURY] = {
				['liquors'] = 0.25,
			},
		},
		male_infrastructure_needs = 0.1,
		carrying_capacity_weight = 0.5,
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
