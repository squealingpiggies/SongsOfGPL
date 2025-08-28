#include <cassert>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <random>
#include <iostream>
#include "objs.hpp"
#define DCON_LUADLL_EXPORTS
#include "sote_functions.hpp"
#include "lua_objs.hpp"

#ifdef _WIN32
#include <fileapi.h>
#include <WinBase.h>
#include <winnls.h>
#else
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#endif

// void save_to_file() {
// 	state.make_s
// }


struct tile_cube_coord {
	int32_t x;
	int32_t y;
	int32_t f;
};

// backend time tracking
static uint32_t WORLD_CURRENT_YEAR;
static uint32_t WORLD_CURRENT_TICK;
static uint32_t WORLD_TICKS_PER_MINUTE;
static uint32_t WORLD_TICKS_PER_HOUR;
static uint32_t WORLD_TICKS_PER_DAY;
static uint32_t WORLD_TICKS_PER_MONTH;

void set_world_current_year(uint32_t year) {
	WORLD_CURRENT_YEAR = year;
}
uint32_t get_world_current_year(void) {
	return WORLD_CURRENT_YEAR;
}
void set_world_current_tick(uint32_t tick) {
	WORLD_CURRENT_TICK = tick;
}
uint32_t get_world_current_tick(void) {
	return WORLD_CURRENT_TICK;
}
void set_world_tick_definitions(uint32_t minute, uint32_t hour, uint32_t day, uint32_t month) {
	WORLD_TICKS_PER_MINUTE = minute;
	WORLD_TICKS_PER_HOUR = hour;
	WORLD_TICKS_PER_DAY = day;
	WORLD_TICKS_PER_MONTH = month;
}
uint32_t get_world_ticks_per_minute(void) {
	return WORLD_TICKS_PER_MINUTE;
}
uint32_t get_world_ticks_per_hour(void) {
	return WORLD_TICKS_PER_HOUR;
}
uint32_t get_world_ticks_per_day(void) {
	return WORLD_TICKS_PER_DAY;
}
uint32_t get_world_ticks_per_month(void) {
	return WORLD_TICKS_PER_MONTH;
}

// Given a tile ID, returns x/y/f coordinates.
tile_cube_coord id_to_coords(int32_t tile_id, uint32_t world_size) {
	auto adjusted_id = (double)(tile_id - 1);
	auto ws = (double)world_size;
	auto f = std::floor(adjusted_id / (ws * ws));
	auto remaining = adjusted_id - f * ws * ws;
	auto y = std::floor(remaining / ws);
	auto x = remaining - y * ws;
	return {
		(int32_t)x, (int32_t)y, (int32_t)f
	};
}

int32_t coords_to_id(int32_t x, int32_t y, int32_t f, uint32_t world_size) {
	return 1 + (x + y * world_size + f * world_size * world_size);
}

constexpr inline uint8_t NEIGH_TOP = 1;
constexpr inline uint8_t NEIGH_BOTTOM = 2;
constexpr inline uint8_t NEIGH_RIGHT = 3;
constexpr inline uint8_t NEIGH_LEFT = 4;

constexpr inline uint8_t cube_FRONT = 0;
constexpr inline uint8_t cube_LEFT = 1;
constexpr inline uint8_t cube_BACK = 2;
constexpr inline uint8_t cube_RIGHT = 3;
constexpr inline uint8_t cube_TOP = 4;
constexpr inline uint8_t cube_BOTTOM = 5;

int32_t get_neighbor(int32_t tile_id, uint8_t neighbor_index, uint32_t world_size) {
	auto cube_coords = id_to_coords(tile_id, world_size);
	auto x = cube_coords.x;
	auto y = cube_coords.y;
	auto f = cube_coords.f;

	auto wsmo = world_size - 1;

	int32_t rx = 0;
	int32_t ry = 0;
	int32_t rf = 0;

	if (neighbor_index == NEIGH_TOP) {
		if (y == wsmo) {
			if (f == cube_TOP) {
				rf = cube_RIGHT;
				rx = wsmo - x;
				ry = wsmo;
			} else if (f == cube_BOTTOM) {
				rf = cube_RIGHT;
				rx = x;
				ry = 0;
			} else if (f == cube_FRONT) {
				rf = cube_TOP;
				rx = wsmo;
				ry = x;
			} else if (f == cube_BACK) {
				rf = cube_TOP;
				rx = 0;
				ry = wsmo - x;
			} else if (f == cube_LEFT) {
				rf = cube_TOP;
				rx = x;
				ry = 0;
			} else if (f == cube_RIGHT) {
				rf = cube_TOP;
				rx = wsmo - x;
				ry = wsmo;
			} else {
				assert(false);
			}
		} else {
			rf = f;
			rx = x;
			ry = y + 1;
		}
	} else if (neighbor_index == NEIGH_BOTTOM) {
		if (y == 0) {
			if (f == cube_TOP) {
				rf = cube_LEFT;
				rx = x;
				ry = wsmo;
			} else if (f == cube_BOTTOM) {
				rf = cube_LEFT;
				rx = wsmo - x;
				ry = 0;
			} else if (f == cube_FRONT) {
				rf = cube_BOTTOM;
				rx = 0;
				ry = x;
			} else if (f == cube_BACK) {
				rf = cube_BOTTOM;
				rx = wsmo;
				ry = wsmo - x;
			} else if (f == cube_LEFT) {
				rf = cube_BOTTOM;
				rx = wsmo - x;
				ry = 0;
			} else if (f == cube_RIGHT) {
				rf = cube_BOTTOM;
				rx = x;
				ry = wsmo;
			} else {
				assert(false);
			}
		} else {
			rf = f;
			rx = x;
			ry = y - 1;
		}
	} else if (neighbor_index == NEIGH_LEFT) {
		if (x == 0) {
			if (f == cube_TOP) {
				rf = cube_BACK;
				rx = wsmo - y;
				ry = wsmo;
			} else if (f == cube_BOTTOM) {
				rf = cube_FRONT;
				rx = y;
				ry = 0;
			} else if (f == cube_FRONT) {
				rf = cube_LEFT;
				rx = wsmo;
				ry = y;
			} else if (f == cube_BACK) {
				rf = cube_RIGHT;
				rx = wsmo;
				ry = y;
			} else if (f == cube_LEFT) {
				rf = cube_BACK;
				rx = wsmo;
				ry = y;
			} else if (f == cube_RIGHT) {
				rf = cube_FRONT;
				rx = wsmo;
				ry = y;
			} else {
				assert(false);
			}
		} else {
			rf = f;
			rx = x - 1;
			ry = y;
		}
	} else if (neighbor_index == NEIGH_RIGHT) {
		if (x == wsmo) {
			if (f == cube_TOP) {
				rf = cube_FRONT;
				rx = y;
				ry = wsmo;
			} else if (f == cube_BOTTOM) {
				rf = cube_BACK;
				rx = wsmo - y;
				ry = 0;
			} else if (f == cube_FRONT) {
				rf = cube_RIGHT;
				rx = 0;
				ry = y;
			} else if (f == cube_BACK) {
				rf = cube_LEFT;
				rx = 0;
				ry = y;
			} else if (f == cube_LEFT) {
				rf = cube_FRONT;
				rx = 0;
				ry = y;
			} else if (f == cube_RIGHT) {
				rf = cube_BACK;
				rx = 0;
				ry = y;
			} else
				assert(false);
			}
		else {
			rf = f;
			rx = x + 1;
			ry = y;
		}
	} else {
		assert(false);
	}

	return coords_to_id(rx, ry, rf, world_size);
}

static auto GOOD_CATEGORY = (uint8_t)((base_types::TRADE_GOOD_CATEGORY::GOOD));

constexpr inline float MAX_INDUCED_DEMAND = 3.f;

// how much of income is siphoned to local wealth pool
constexpr inline float INCOME_TO_LOCAL_WEALTH_MULTIPLIER = 0.125f / 4.f;

// pops work at least this time
constexpr inline float MINIMAL_WORKING_RATIO = 0.2f;

constexpr inline float spending_ratio = 0.1f;

float forage_efficiency(float foragers, float carrying_capacity) {
	if (foragers > carrying_capacity) {
		return carrying_capacity / (foragers + 1);
	} else {
		return 2 - expf(-0.7*(carrying_capacity - foragers)/carrying_capacity);
	}
}

void load_state(char const* name) {
#ifdef _WIN32
	int wchars_num = MultiByteToWideChar( CP_UTF8 , 0 , name , -1, NULL , 0 );
	wchar_t* w_name = new wchar_t[wchars_num];
	MultiByteToWideChar( CP_UTF8 , 0 , name , -1, w_name , wchars_num );

	auto file_handle = CreateFileW(
		w_name,
		GENERIC_READ,
		FILE_SHARE_READ,
		nullptr,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN,
		nullptr
	);

	if(file_handle != INVALID_HANDLE_VALUE) {
		auto mapping_handle = CreateFileMappingW(file_handle, nullptr, PAGE_READONLY, 0, 0, nullptr);
		if(mapping_handle) {
			auto data = (std::byte const*)MapViewOfFile(mapping_handle, FILE_MAP_READ, 0, 0, 0);
			if(data) {
				_LARGE_INTEGER pvalue;
				GetFileSizeEx(file_handle, &pvalue);
				auto file_size = uint32_t(pvalue.QuadPart);

				dcon::load_record loaded;
				dcon::load_record selection = state.make_serialize_record_everything();
				state.deserialize(data, data + file_size, loaded, selection);

				UnmapViewOfFile(data);
			}
			CloseHandle(mapping_handle);
		}
		CloseHandle(file_handle);
	}
	delete[] w_name;
#else
	int file_descriptor = open(name, O_RDONLY | O_NONBLOCK);
	if (file_descriptor != -1) {
		struct stat sb;
		if(fstat(file_descriptor, &sb) != -1) {
			auto file_size = sb.st_size;
#if _POSIX_C_SOURCE >= 200112L
			posix_fadvise(file_descriptor, 0, static_cast<off_t>(file_size), POSIX_FADV_WILLNEED);
#endif
#if defined(_GNU_SOURCE) || defined(_DEFAULT_SOURCE) || defined(_BSD_SOURCE) || defined(_SVID_SOURCE)
			void* mapping_handle = mmap(0, file_size, PROT_READ, MAP_PRIVATE, file_descriptor, 0);
			assert(mapping_handle != MAP_FAILED);
			std::byte const* content = static_cast<std::byte const*>(mapping_handle);
			dcon::load_record loaded;
			dcon::load_record selection = state.make_serialize_record_everything();
			state.deserialize(content, content + file_size, loaded, selection);
			if(munmap(mapping_handle, file_size) == -1) {
				assert(false);
			}
#else
			void* buffer = malloc(file_size);
			read(file_descriptor, buffer, file_size);
			std::byte const* content = static_cast<std::byte const*>(buffer);
			dcon::load_record loaded;
			dcon::load_record selection = state.make_serialize_record_everything();
			state.deserialize(content, content + file_size, loaded, selection);
			free(buffer);
#endif
		}
		close(file_descriptor);
	}
#endif
}

// converting birth tick into human readable values
uint32_t birth_month(dcon::pop_id pop) {
	auto birthtick = state.pop_get_birth_tick(pop);
	auto month = birthtick / WORLD_TICKS_PER_MONTH;
//	std::cout << std::to_string(month) + " = " + std::to_string(birthtick) + " / " + std::to_string(WORLD_TICKS_PER_MONTH) + "\n";
	return month;
}
uint32_t birth_day(dcon::pop_id pop) {
	auto birthtick = state.pop_get_birth_tick(pop);
	auto month = birthtick / WORLD_TICKS_PER_MONTH;
	auto day_tick = birthtick - month * WORLD_TICKS_PER_MONTH;
	auto day = day_tick / WORLD_TICKS_PER_DAY;
//	std::cout << std::to_string(day) + " = " + std::to_string(day_tick) + " / " + std::to_string(WORLD_TICKS_PER_DAY) + "\n";
	return day+1; // since day cycles between 1 and 30
}
uint32_t birth_hour(dcon::pop_id pop) {
	auto birthtick = state.pop_get_birth_tick(pop);
	auto month = birthtick / WORLD_TICKS_PER_MONTH;
	auto day_tick = birthtick - month * WORLD_TICKS_PER_MONTH;
	auto day = day_tick / WORLD_TICKS_PER_DAY;
	auto hour_tick = day_tick - day * WORLD_TICKS_PER_DAY;
	auto hour = hour_tick / WORLD_TICKS_PER_HOUR;
//	std::cout << std::to_string(hour) + " = " + std::to_string(hour_tick) + " / " + std::to_string(WORLD_TICKS_PER_HOUR) + "\n";
	return hour;
}
uint32_t birth_minute(dcon::pop_id pop) {
	auto birthtick = state.pop_get_birth_tick(pop);
	auto month = birthtick / WORLD_TICKS_PER_MONTH;
	auto day_tick = birthtick - month * WORLD_TICKS_PER_MONTH;
	auto day = day_tick / WORLD_TICKS_PER_DAY;
	auto hour_tick = day_tick - day * WORLD_TICKS_PER_DAY;
	auto hour = hour_tick / WORLD_TICKS_PER_HOUR;
	auto minute_tick = hour_tick - hour * WORLD_TICKS_PER_HOUR;
	auto minute = minute_tick / WORLD_TICKS_PER_MINUTE;
//	std::cout << std::to_string(minute) + " = " + std::to_string(minute_tick) + " / " + std::to_string(WORLD_TICKS_PER_MINUTE) + "\n";
	return minute;
}
// converting birth year and tick into age values
uint32_t age_ticks(dcon::pop_id pop) {
	return (WORLD_CURRENT_YEAR - state.pop_get_birth_year(pop))
		* WORLD_TICKS_PER_MONTH * 12 + WORLD_CURRENT_TICK - state.pop_get_birth_tick(pop);
}
uint32_t age_months(dcon::pop_id pop) {
	return age_ticks(pop) / WORLD_TICKS_PER_MONTH;
}
uint32_t age_years(dcon::pop_id pop) {
	return age_ticks(pop) / WORLD_TICKS_PER_MONTH / 12;
}
// using age values
float age_multiplier(dcon::pop_id pop) {
	float age_multiplier = 1.f;
	auto age = age_ticks(pop);
	auto race = state.pop_get_race(pop);

	auto conversion = WORLD_TICKS_PER_MONTH * 12;
	auto adult_age = state.race_get_adult_age(race) * conversion;
	auto middle_age = state.race_get_middle_age(race) * conversion;
	auto max_age = state.race_get_max_age(race) * conversion;

	if (age < adult_age) {
		age_multiplier = 0.25 + 0.75 * age / adult_age; // [.25,1.f)
	} else if (age >= middle_age) {
		age_multiplier = 1.f - 0.1 * (age - middle_age) / (max_age - middle_age); // [1.f,.75)
	}
	return age_multiplier;
}
// pop time calculations
float pop_free_time(dcon::pop_id pop) {
	auto age = age_ticks(pop);
	auto race = state.pop_get_race(pop);
	auto teen = state.race_get_teen_age(race) * WORLD_TICKS_PER_MONTH * 12;
	if (age < teen) {
		return age / teen;
	} else {
		return 1.f;
	}
}
float pop_warband_time(dcon::pop_id pop, float free) {
	auto remaining = free - 0.05f;
	if (remaining <= 0.f) {
		return 0.f;
	}
	auto unitship = state.pop_get_warband_unit_as_unit(pop);
	auto warband = state.warband_unit_get_warband(unitship);
	if (state.warband_is_valid(warband)) {
		auto time = state.warband_get_current_time_used_ratio(warband);
		if (remaining < time) {
			return remaining;
		} else {
			return time;
		}
	} else {
		return 0.f;
	}
}
float pop_forage_time(dcon::pop_id pop, float free, float warband) {
	auto remaining = free - warband;
	auto desire = state.pop_get_forage_ratio(pop);
	if (remaining < desire) {
		return remaining;
	} else {
		return desire;
	}
}
float pop_work_time(dcon::pop_id pop, float free, float warband, float forage) {
	auto remaining = free - warband - forage;
	if (remaining < 0.f) {
		return 0.f;
	} else {
		return remaining;
	}
}

float job_efficiency(dcon::race_id race, bool female, uint8_t jobtype) {
	if (female) {
		return state.race_get_female_efficiency(race, jobtype) ;
	}
	return state.race_get_male_efficiency(race, jobtype);
}
float job_efficiency(dcon::pop_id pop, uint8_t jobtype) {
	return job_efficiency(
		state.pop_get_race(pop),
		state.pop_get_female(pop),
		jobtype
	) * age_multiplier(pop);
}

bool pop_same_location(dcon::pop_id a, dcon::pop_id b) {
	auto a_estate = state.pop_location_get_estate(state.pop_get_pop_location_as_pop(a));
	auto b_estate = state.pop_location_get_estate(state.pop_get_pop_location_as_pop(a));
	if (state.estate_is_valid(a_estate) && a_estate == b_estate) {
		return true;
	} // if not in same estate, check if in same tile
	auto a_tile = state.estate_location_get_tile(state.estate_get_estate_location_as_estate(a_estate));
	auto b_tile = state.estate_location_get_tile(state.estate_get_estate_location_as_estate(a_estate));
	if (state.tile_is_valid(a_tile) && a_tile == b_tile) {
		return true;
	}
	return false;
}

bool is_dependent_of(dcon::pop_id pop, dcon::pop_id parent) {
	auto age = age_years(pop);
	auto race = state.pop_get_race(pop);
	auto teen_age = state.race_get_teen_age(race);
	if (age < teen_age && parent && pop_same_location(pop,parent))
		return true;
	return false;
}
bool is_dependent(dcon::pop_id pop) {
	auto age = age_years(pop);
	auto race = state.pop_get_race(pop);
	auto teen_age = state.race_get_teen_age(race);
	auto parent = state.parent_child_relation_get_parent(state.pop_get_parent_child_relation_as_child(pop));
	if (age < teen_age && parent && pop_same_location(pop,parent))
		return true;
	return false;
}

void update_vegetation(float speed) {
	state.execute_serial_over_tile([speed](auto ids) {
		auto conifer = state.tile_get_conifer(ids);
		auto broadleaf = state.tile_get_broadleaf(ids);
		auto shrub = state.tile_get_shrub(ids);
		auto grass = state.tile_get_grass(ids);

		auto ideal_conifer = state.tile_get_ideal_conifer(ids);
		auto ideal_broadleaf = state.tile_get_ideal_broadleaf(ids);
		auto ideal_shrub = state.tile_get_ideal_shrub(ids);
		auto ideal_grass = state.tile_get_ideal_grass(ids);

		state.tile_set_conifer(ids, conifer * (1.f - speed) + ideal_conifer * speed);
		state.tile_set_broadleaf(ids, broadleaf * (1.f - speed) + ideal_broadleaf * speed);
		state.tile_set_shrub(ids, shrub * (1.f - speed) + ideal_shrub * speed);
		state.tile_set_grass(ids, grass * (1.f - speed) + ideal_grass * speed);
	});
}

template<typename T>
ve::fp_vector get_permeability(T tile_id) {
	ve::fp_vector tile_perm = 2.5f;
	auto sand = state.tile_get_sand(tile_id);
	auto silt = state.tile_get_silt(tile_id);
	auto clay = state.tile_get_clay(tile_id);

	tile_perm = ve::select(sand > 0.15f, tile_perm - 2.f * (sand - 0.15f) / (1.0f - 0.15f), tile_perm);
	tile_perm = ve::select(silt > 0.85f, tile_perm - 2.f * (sand - 0.15f) / (1.0f - 0.15f), tile_perm);
	tile_perm = ve::select(clay > 0.2f, tile_perm - 1.25f * (clay - 0.2f) / (1.0f - 0.2f), tile_perm);

	return tile_perm / 2.5f;
}


void apply_resource(int32_t resource_index) {
	dcon::resource_fat_id res = dcon::fatten(state, dcon::resource_id{(dcon::resource_id::value_base_t)resource_index});

	auto rng_engine = std::default_random_engine();
	auto distribution = std::uniform_real_distribution<float> {0, 1};

	auto generator = std::bind(distribution, rng_engine);

	state.execute_parallel_over_tile([&](auto tiles) {
		auto tile_is_land = state.tile_get_is_land(tiles);

		ve::mask_vector land_check {false};

		if (res.get_land()) {
			land_check = land_check || tile_is_land;
		}
		if (res.get_water()) {
			land_check = land_check || (!tile_is_land);
		}

		auto coast_check = state.tile_get_is_coast(tiles);

		auto conifers = state.tile_get_conifer(tiles);
		auto broadleaf = state.tile_get_broadleaf(tiles);
		auto trees = conifers + broadleaf;


		ve::mask_vector base_check =
		(
			(
				(
						land_check
					&&
						(
								coast_check
							||
								!res.get_coastal()
						)
				)
			&&
				(
					state.tile_get_elevation(tiles) <= res.get_maximum_elevation()
					&&
					state.tile_get_elevation(tiles) >= res.get_minimum_elevation()
				)
			)
		&&
			(
				(
					trees <= res.get_maximum_trees()
					&&
					trees >= res.get_minimum_trees()
				)
				&&
				(
					(state.tile_get_ice_age_ice(tiles) > 0)
					||
					!res.get_ice_age()
				)
			)
		);

		ve::mask_vector bedrock_check {false};
		if (!res.get_required_bedrock(0)) {
			bedrock_check = ve::mask_vector{true};
		}

		for (int i = 0; i <  state.resource_get_required_bedrock_size(); i++) {
			auto requirement = res.get_required_bedrock(i);
			if (!requirement) {
				break;
			}
			bedrock_check = bedrock_check || (state.tile_get_bedrock(tiles) == requirement);
		}

		ve::mask_vector biome_check {false};
		if (!res.get_required_biome(0)) {
			biome_check = ve::mask_vector{true};
		}

		for (int i = 0; i <  state.resource_get_required_biome_size(); i++) {
			auto requirement = res.get_required_biome(i);
			if (!requirement) {
				break;
			}
			biome_check = biome_check || (state.tile_get_biome(tiles) == requirement);
		}

		auto result = base_check && bedrock_check && biome_check;

		auto dice_roll = ve::apply([&](auto tile) {
			return generator() < 1.f / res.get_base_frequency();
		}, tiles);

		ve::value_to_vector_type<dcon::resource_id> current = state.tile_get_resource(tiles);
		ve::value_to_vector_type<dcon::resource_id> candidate = res.id;

		state.tile_set_resource(tiles, ve::select(result && dice_roll, candidate, current));
	});
}

void apply_biome(int32_t biome_index) {
	dcon::biome_fat_id biome = dcon::fatten(state, dcon::biome_id{(uint8_t)biome_index});

	state.execute_parallel_over_tile([&biome](auto ids) {

		auto trees = state.tile_get_broadleaf(ids) + state.tile_get_conifer(ids);
		auto dead_land = 1 - trees - state.tile_get_shrub(ids) - state.tile_get_grass(ids);
		auto conifer_fraction = ve::select(trees == 0, 0.5f, state.tile_get_conifer(ids) / trees);

		auto jan_temp = state.tile_get_january_temperature(ids);
		auto jan_rain = state.tile_get_january_rain(ids);
		auto jul_temp = state.tile_get_july_temperature(ids);
		auto jul_rain = state.tile_get_july_temperature(ids);

		auto rain = (jan_rain + jul_rain) * 0.5f;
		auto temperature = (jan_temp + jul_temp) / 2;
		auto summer_temperature = ve::max(jan_temp, jul_temp);
		auto winter_temperature = ve::min(jan_temp, jul_temp);

		auto permeability = get_permeability(ids);

		auto available_water = rain * 2 * permeability;

		auto soil_depth = state.tile_get_sand(ids) + state.tile_get_silt(ids) + state.tile_get_clay(ids);

		ve::mask_vector biome_mask =
			(
				(
					(
						(
							(
								state.tile_get_slope(ids) > biome.get_minimum_slope()
							&&
								state.tile_get_slope(ids) < biome.get_maximum_slope()
							)
						&&
							(
								state.tile_get_is_land(ids) != biome.get_aquatic()
							&&
								state.tile_get_has_marsh(ids) == biome.get_marsh()
							)
						)
					&&
						(
							(
								state.tile_get_elevation(ids) > biome.get_minimum_elevation()
							&&
								state.tile_get_elevation(ids) < biome.get_maximum_elevation()
							)
						&&
							(
								state.tile_get_sand(ids) > biome.get_minimum_sand()
							&&
								state.tile_get_sand(ids) < biome.get_maximum_sand()
							)
						)
					)
				&&
					(
						(
							(
								state.tile_get_clay(ids) > biome.get_minimum_clay()
							&&
								state.tile_get_clay(ids) < biome.get_maximum_clay()
							)
						&&
							(
								state.tile_get_silt(ids) > biome.get_minimum_silt()
							&&
								state.tile_get_silt(ids) < biome.get_maximum_silt()
							)
						)
					&&
						(
							(
								state.tile_get_shrub(ids) > biome.get_minimum_shrubs()
							&&
								state.tile_get_shrub(ids) < biome.get_maximum_shrubs()
							)
						&&
							(
								state.tile_get_grass(ids) > biome.get_minimum_grass()
							&&
								state.tile_get_grass(ids) < biome.get_maximum_grass()
							)
						)
					)
				)
			&&
				(
					(
						(
							(
								trees > biome.get_minimum_trees()
							&&
								trees < biome.get_maximum_trees()
							)
						&&
							(
								dead_land > biome.get_minimum_dead_land()
							&&
								dead_land < biome.get_maximum_dead_land()
							)
						)
					&&
						(
							(
								conifer_fraction > biome.get_minimum_conifer_fraction()
							&&
								conifer_fraction < biome.get_maximum_conifer_fraction()
							)
						&&
							(
								rain > biome.get_minimum_rain()
							&&
								rain < biome.get_maximum_rain()
							)
						)
					)
				&&
					(
						(
							(
								temperature > biome.get_minimum_temperature()
							&&
								temperature < biome.get_maximum_temperature()
							)
						&&
							(
								summer_temperature > biome.get_minimum_summer_temperature()
							&&
								summer_temperature < biome.get_maximum_summer_temperature()
							)
						)
					&&
						(
							(
								winter_temperature > biome.get_minimum_winter_temperature()
							&&
								winter_temperature < biome.get_maximum_winter_temperature()
							)
						// &&
						// 	(
						// 		state.tile_get_shrub(ids) > biome.get_minimum_grass()
						// 	&&
						// 		state.tile_get_shrub(ids) < biome.get_maximum_grass()
						// 	)
						)
					)
				)
			)
		&&
			(
				(
					(
						(
							available_water > biome.get_minimum_available_water()
						)
						&&
						(
							available_water < biome.get_maximum_available_water()
						)
					)
					&&
					(
						(
							soil_depth > biome.get_minimum_soil_depth()
						)
						&&
						(
							soil_depth < biome.get_maximum_soil_depth()
						)
					)
				)
				&&
				(
					(
						state.tile_get_soil_minerals(ids) > biome.get_minimum_soil_richness()
						&&
						state.tile_get_soil_minerals(ids) < biome.get_maximum_soil_richness()
					)
					&&
					biome.get_icy() == (state.tile_get_ice(ids) > 0.001)
				)
			);

		ve::value_to_vector_type<dcon::biome_id> current = state.tile_get_biome(ids);
		ve::value_to_vector_type<dcon::biome_id> candidate = biome.id;

		state.tile_set_biome(ids, ve::select(biome_mask, candidate, current));
	});
}

float price_score(float price) {
	return std::min(1.f, 1000.f / price);
}
ve::fp_vector price_score(ve::fp_vector price) {
	return ve::min(1.f, 1000.f / price);
}

float get_normalizing_coefficient_use_case(dcon::use_case_id use, dcon::province_id provinces) {
	auto total_exp = 0.f;
	state.use_case_for_each_use_weight(use, [&](dcon::use_weight_id weight_id) {
		auto trade_good = state.use_weight_get_trade_good(weight_id);
		auto price = state.province_get_local_prices(provinces, trade_good);
		auto weight = state.use_weight_get_weight(weight_id);

		total_exp = total_exp + price_score(price / weight);
	});

	return total_exp;
}

// this function calculates how much money pop is ready to pay for 1 unit of use case
// if price is high, we do not buy this good
// we divide price by weight because $1$ unit of good convers to $weight$ units of use
float get_price_integral_use_case(dcon::use_case_id use, dcon::province_id province) {
	auto integral = 0.f;
	state.use_case_for_each_use_weight(use, [&](dcon::use_weight_id weight_id) {
		auto trade_good = state.use_weight_get_trade_good(weight_id);
		auto price = state.province_get_local_prices(province, trade_good);
		auto weight = state.use_weight_get_weight(weight_id);

		integral = integral + price_score(price / weight);
	});
	return integral;
}

float record_production(dcon::province_id province, dcon::trade_good_id trade_good, float amount) {
	assert(amount >= 0.f);

	auto current = state.province_get_local_production(province, trade_good);
	state.province_set_local_production(province, trade_good, current + amount);

	auto price = state.province_get_local_prices(province, trade_good);
	return price * amount;
}

float record_demand(dcon::province_id province, dcon::trade_good_id trade_good, float amount) {
	assert(amount >= 0.f);

	auto current = state.province_get_local_demand(province, trade_good);
	state.province_set_local_demand(province, trade_good, current + amount);

	auto price = state.province_get_local_prices(province, trade_good);
	return price * amount;
}

void record_use_demand(dcon::province_id province, dcon::use_case_id use_case, float amount) {
	assert(amount >= 0.f);

	auto current = state.province_get_local_use_buffer_demand(province, use_case);
	state.province_set_local_use_buffer_demand(province, use_case, current + amount);
}

void pop_forage_update(dcon::pop_id pop, dcon::province_id province) {
	auto size = state.province_get_size(province);
	auto free_time = pop_free_time(pop);
	auto warband_time = pop_warband_time(pop,free_time);
	auto forage_time = pop_forage_time(pop,free_time,warband_time);
	auto work_time = pop_work_time(pop,free_time,warband_time,forage_time);
	// set actual work time for production call so as to not recalculate it
	state.pop_set_work_ratio(pop,work_time);

	auto estimated_profit = 0.f;

	for (uint32_t i = 0; i < state.province_get_foragers_targets_size(); i++){
		base_types::forage_container& forage_case = state.province_get_foragers_targets(province, i);

		auto output = dcon::trade_good_id{dcon::trade_good_id::value_base_t(int32_t(forage_case.output_good - 1))};

		if (!output) {
			break;
		}

		auto current = state.pop_get_inventory(pop, output);
		auto culture = state.pop_get_culture(pop);
		auto cultural_priority = state.culture_get_traditional_forager_targets(culture, (uint8_t)(forage_case.forage));

		dcon::forage_resource_id resource {(dcon::forage_resource_id::value_base_t)((int)forage_case.forage - 1)};
		auto amount = forage_case.amount;

		if (amount == 0) {
			continue;
		}

		auto output_value = forage_case.output_value;
		auto efficiency = job_efficiency(pop, state.forage_resource_get_handle(resource));

		auto speed = 10.f;
		// time to find a resource
		auto search_time_per_unit = size / amount / speed;

		// time to gather the resource when it's found
		auto handle_time_per_unit = 1 / efficiency;

		//time required to gather and find one unit of resource
		auto total_time_per_unit = search_time_per_unit + handle_time_per_unit;

		// how many units of goods one unit of resource yields
		auto output_per_unit = forage_case.output_value;


		auto output_total = output_per_unit
			/ total_time_per_unit
			* forage_time
			* cultural_priority
			* state.province_get_forage_efficiency(province);

		// std::cout << int(forage_case.forage) << " "
		// 	<< current << " "
		// 	<< output_per_unit << " "
		// 	<< total_time_per_unit << " "
		// 	<< forage_time << " "
		// 	<< cultural_priority << " "
		// 	<< state.province_get_forage_efficiency(province) << " \n";

		estimated_profit += output_total * state.province_get_local_prices(province, output);

		assert(output_total > 0);

		state.pop_set_inventory(
			pop,
			output,
			std::max(0.f, current + output_total)
		);
	}

	// update forage time based on profit:
	// forage profit is considered as unreliable
	// to allow advanced production
	estimated_profit = estimated_profit * 0.5f;
	auto employment = state.pop_get_employment(pop);
	if (state.employment_get_building(employment)) {
		auto work_profit = state.employment_get_worker_income(employment);
		if(state.pop_get_free_will(pop) && !state.pop_get_is_player(pop)) {
			// estimated forage profit is already modified by work time
			if (work_profit / work_time > estimated_profit / forage_time * 1.05f && forage_time > 0.05f) {
				state.pop_set_forage_ratio(pop, forage_time * 0.98f);
			} else if (work_profit / work_time < estimated_profit / forage_time * 0.95f && forage_time < 0.95f) {
				state.pop_set_forage_ratio(pop, forage_time * 1.02f);
			}
		}
	}
}

// can do in parallel over provinces
void pops_produce(dcon::province_id province) {
	// recalculate buildings-based foragers
	state.province_set_foragers(province, 0.f);

	state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
		auto tile = state.tile_province_membership_get_tile(tile_membership);
		state.tile_for_each_estate_location(tile, [&](auto estate_location) {
			auto estate = state.estate_location_get_estate(estate_location);
			state.estate_for_each_building_estate(estate, [&](auto building_location) {
				auto building = state.building_estate_get_building(building_location);
				auto btype = state.building_get_current_type(building);
				auto production_method = state.building_type_get_production_method(btype);
				if (state.production_method_get_foraging(production_method)){
					state.province_get_foragers(province) += state.building_get_production_scale(building);
				}
			});
			state.estate_for_each_pop_location(estate, [&](auto location) {
				auto pop = state.pop_location_get_pop(location);
				state.province_get_foragers(province) += state.pop_get_forage_ratio(pop);
			});
		});
	});

	state.province_set_forage_efficiency(province, forage_efficiency(
		state.province_get_foragers(province),
		state.province_get_foragers_limit(province)
	));

	// TODO move to production estate production phase?
	state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
		auto tile = state.tile_province_membership_get_tile(tile_membership);
		state.tile_for_each_estate_location(tile, [&](auto estate_location) {
			auto estate = state.estate_location_get_estate(estate_location);
			state.estate_for_each_pop_location(estate, [&](auto location) {
				auto pop = state.pop_location_get_pop(location);
				pop_forage_update(pop, province);
			});
		});
	});
}

void update_building_scale() {
	state.for_each_building([&](auto building){
		auto estate = state.building_get_estate_from_building_estate(building);
		auto tile = state.estate_get_tile_from_estate_location(estate);
		auto province = state.tile_get_province_from_tile_province_membership(tile);
		auto btype = state.building_get_current_type(building);
		auto production_method = state.building_type_get_production_method(btype);
		auto associated_job = state.production_method_get_job_type(production_method);
		auto worker = state.building_get_worker_from_employment(building);

		auto worktime = worker != dcon::pop_id{} ? state.pop_get_work_ratio(worker) : 0.f;
		auto efficiency = ve::apply([&](auto w, auto job_type) {
			if (w) {
				return job_efficiency(w, job_type);
			} else {
				return 0.f;
			}
		}, worker, associated_job) * (2.f - worktime);

		auto scale = worktime * efficiency;

		auto final_production_scale = scale * state.province_get_throughput_boosts(province, production_method);
		auto final_output_scale = scale
			* (1 + state.province_get_output_efficiency_boosts(province, production_method))
			* (state.province_get_local_efficiency_boosts(province, production_method));
		auto final_input_scale = scale * (1 - state.province_get_input_efficiency_boosts(province, production_method));

		state.building_set_production_scale(building, final_production_scale);
		state.building_set_output_scale(building, final_output_scale);
		state.building_set_input_scale(building, final_input_scale);
	});
}

// depends on province
void estates_produce(dcon::province_id province) {
	state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
		auto tile = state.tile_province_membership_get_tile(tile_membership);
		state.tile_for_each_estate_location(tile, [&](auto id) {
			auto estate = state.estate_location_get_estate(id);

			auto used_but_not_consumed_goods = state.trade_good_make_vectorizable_float_buffer();

			state.estate_for_each_building_estate(estate, [&](auto building_location) {
				auto building = state.building_estate_get_building(building_location);

				auto building_type = state.building_get_current_type(building);
				auto production_method = state.building_type_get_production_method(building_type);
				auto input_scale = state.building_get_input_scale(building);
				auto output_scale = state.building_get_output_scale(building);

				// calculate available inputs in the estate stockpile
				auto min_input = 1.f;

				for (uint32_t i = 0; i < state.production_method_get_inputs_size(); i++) {
					if (input_scale == 0) break;

					base_types::use_case_container input = state.production_method_get_inputs(production_method, i);
					if (input.use == 0) break;

					float use_required = input_scale * input.amount;

					// auto have_to_satisfy = input.amount * input_scale;
					float use_in_inventory = 0.f;

					state.use_case_for_each_use_weight_as_use_case(dcon::use_case_id{(uint8_t)(input.use - 1)}, [&](auto weight_id){
						auto weight = state.use_weight_get_weight(weight_id);
						auto trade_good = state.use_weight_get_trade_good(weight_id);

						auto inventory = std::max(0.f, state.estate_get_inventory(estate, trade_good) - used_but_not_consumed_goods.get(trade_good));

						if (use_in_inventory + inventory * weight < use_required) {
							use_in_inventory += inventory * weight;
						} else {
							use_in_inventory = use_required;
						}

					});

					min_input = std::min(min_input, use_in_inventory / use_required);
				}

				// actual consumption:

				for (uint32_t i = 0; i < state.production_method_get_inputs_size(); i++) {
					if (input_scale == 0) break;

					base_types::use_case_container input = state.production_method_get_inputs(production_method, i);
					if (input.use == 0) break;

					float use_required = input_scale * input.amount;

					// auto have_to_satisfy = input.amount * input_scale;
					float use_in_inventory = 0.f;
					auto use = dcon::use_case_id{(uint8_t)(input.use - 1)};
					auto actual_consumption_effect = state.use_case_get_good_consumption(use);

					state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
						auto weight = state.use_weight_get_weight(weight_id);
						auto trade_good = state.use_weight_get_trade_good(weight_id);

						// try to consume
						auto inventory = std::max(0.f, state.estate_get_inventory(estate, trade_good) - used_but_not_consumed_goods.get(trade_good));

						if (use_in_inventory + inventory * weight < use_required) {
							used_but_not_consumed_goods.set(trade_good, used_but_not_consumed_goods.get(trade_good) + inventory);
							state.estate_set_inventory(estate, trade_good, inventory * (1.f - actual_consumption_effect));
							use_in_inventory += inventory * weight;
						} else {
							used_but_not_consumed_goods.set(trade_good, used_but_not_consumed_goods.get(trade_good) + (use_required - use_in_inventory) / weight);
							state.estate_set_inventory(estate, trade_good, std::max(0.f, inventory - (use_required - use_in_inventory) / weight * actual_consumption_effect));
							use_in_inventory = use_required;
						}

						// std::cout << use_in_inventory << "/" << use_required << "\n";
					});

					min_input = std::min(min_input, use_in_inventory / use_required);

					// std::cout << min_input << " " << input_scale << " " << input.amount << "\n";

					base_types::use_case_container& stats = state.building_get_amount_of_inputs(building, i);
					stats.amount = min_input * input_scale * input.amount;
				}

				// actual production

				for (uint32_t i = 0; i < state.production_method_get_outputs_size(); i++) {
					base_types::trade_good_container& output = state.production_method_get_outputs(production_method, i);
					if(!output.good) {
						break;
					}
					auto good = dcon::trade_good_id{dcon::trade_good_id::value_base_t(output.good - 1)};
					auto inventory = state.estate_get_inventory(estate, good);

					state.estate_set_inventory(estate, good, inventory + output.amount * output_scale * min_input);

					base_types::trade_good_container& stats = state.building_get_amount_of_outputs(building, i);
					stats.amount = min_input * output_scale * output.amount;
					stats.good = output.good;
				}
			});
		});
	});
}

void pops_consume() {
	static auto uses_buffer = state.trade_good_category_make_vectorizable_float_buffer();

	state.for_each_pop([&](auto pop){
		if (is_dependent(pop)) return;

		// std::cout << "pop: " << pop.index();

		for (uint32_t i = 0; i < state.pop_get_need_satisfaction_size(); i++) {
			base_types::need_satisfaction& need = state.pop_get_need_satisfaction(pop, i);
			// std::cout << "need: " << i << " " << need.use_case;

			if (need.use_case == 0)	break;

			auto demanded = need.demanded;

			auto use = dcon::use_case_id{dcon::use_case_id::value_base_t(need.use_case - 1)};

			state.pop_for_each_parent_child_relation_as_parent(pop, [&](auto child_rel) {
				auto child = state.parent_child_relation_get_child(child_rel);
				if (is_dependent_of(pop,child)) {
					base_types::need_satisfaction& need_child = state.pop_get_need_satisfaction(child, i);
					demanded += need_child.demanded;
					// transfer half of relevent trade goods for collective satisfaction
					state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
						auto trade_good = state.use_weight_get_trade_good(weight_id);
						auto amount = state.pop_get_inventory(child,trade_good);
						state.pop_set_inventory(child,trade_good,amount*0.5);
						state.pop_set_inventory(pop,trade_good,state.pop_get_inventory(pop,trade_good)+amount*0.5);
					});
				}
			});


			auto actual_consumption_rate = state.use_case_get_good_consumption(use);
			auto satisfied = 0.f;

			state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
				auto weight = state.use_weight_get_weight(weight_id);
				auto trade_good = state.use_weight_get_trade_good(weight_id);

				auto inventory = state.pop_get_inventory(pop, trade_good);
				auto can_consume = inventory * weight;

				if (satisfied >= demanded) {
					return;
				} else if (satisfied + can_consume > demanded) {
					auto consumed = (demanded - satisfied) / weight * actual_consumption_rate;
					state.pop_set_inventory(pop, trade_good, std::max(0.f, inventory - consumed));
					satisfied = demanded;
					return;
				} else {
					satisfied += can_consume;
					auto consumed = inventory * actual_consumption_rate;
					state.pop_set_inventory(pop, trade_good, std::max(0.f, inventory - consumed));
				}
			});

			auto satisfaction = satisfied / demanded;

			need.consumed = need.demanded * satisfaction;
			state.pop_for_each_parent_child_relation_as_parent(pop, [&](auto child_rel) {
				auto child = state.parent_child_relation_get_child(child_rel);
				auto child_age = age_years(child);
				auto teen_age = state.race_get_teen_age(state.pop_get_race(child));
				if (child_age < teen_age) {
					base_types::need_satisfaction& need_child = state.pop_get_need_satisfaction(child, i);
					need_child.consumed = need.demanded * satisfaction;
				}
			});
		}
	});
}

void pops_sell() {
	state.for_each_pop([&](auto pop) {
		if (state.pop_get_is_player(pop)) {
			return;
		}
		auto estate = state.pop_get_estate_from_pop_location(pop);
		auto tile = state.estate_get_tile_from_estate_location(estate);
		auto province = state.tile_get_province_from_tile_province_membership(tile);
		auto income = 0.f;
		state.for_each_trade_good([&](auto trade_good) {
			auto inventory = state.pop_get_inventory(pop, trade_good);
			auto sell_ratio = 0.1f + 0.9f * (1.f - state.trade_good_get_decay(trade_good));
			income += inventory * 0.1f * state.province_get_local_prices(province, trade_good);
			state.pop_set_inventory(pop, trade_good, inventory * 0.9f);
			record_production(province, trade_good, inventory * 0.1f);
		});

		auto race = state.pop_get_race(pop);
		auto max_age = state.race_get_max_age(race);
		auto age = age_years(pop);

		auto base_income = 10.f * age / max_age;

		state.pop_set_pending_economy_income(pop, state.pop_get_pending_economy_income(pop) + income + base_income);
	});
}


// can be used in parallel over provinces
void estates_sell(dcon::province_id province) {
	state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
		auto tile = state.tile_province_membership_get_tile(tile_membership);
		state.tile_for_each_estate_location(tile, [&](auto id) {
			auto estate = state.estate_location_get_estate(id);
			auto income = 0.f;
			state.for_each_trade_good([&](auto trade_good) {
				auto inventory = state.estate_get_inventory(estate, trade_good);
				auto sell_ratio = 1.f;
				if (state.trade_good_get_belongs_to_category(trade_good) == GOOD_CATEGORY) {
					sell_ratio = std::min(1.f, 0.5f / (state.trade_good_get_decay(trade_good) + 0.001f));
				}
				auto income_from_good = inventory * sell_ratio * state.province_get_local_prices(province, trade_good);
				income += income_from_good;
				state.estate_set_inventory_sold_last_tick(estate, trade_good, inventory * sell_ratio);
				state.estate_set_inventory(estate, trade_good, inventory * (1.f - sell_ratio));
				record_production(province, trade_good, inventory * sell_ratio);
			});
			state.estate_set_savings(estate, state.estate_get_savings(estate) + income);
			state.estate_get_balance_last_tick(estate) += income;
		});
	});
}

// pops buy everything
// useful for them according to prices
// usefulness dep}s on weight, price and total according need
void pops_demand() {
	state.for_each_pop([&](auto pop){
		auto estate = state.pop_get_estate_from_pop_location(pop);
		auto tile = state.estate_get_tile_from_estate_location(estate);
		auto province = state.tile_get_province_from_tile_province_membership(tile);

		auto budget = state.pop_get_savings(pop) * state.pop_get_spend_savings_ratio(pop);
		auto total_score = 0.01f;
		auto total_cost = 0.f;

		for (uint32_t i = 0; i < state.pop_get_need_satisfaction_size(); i++) {
			base_types::need_satisfaction& need = state.pop_get_need_satisfaction(pop, i);
			if (need.use_case == 0)	break;
			auto use = dcon::use_case_id{dcon::use_case_id::value_base_t(need.use_case - 1)};
			state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
				auto weight = state.use_weight_get_weight(weight_id);
				auto trade_good = state.use_weight_get_trade_good(weight_id);
				// auto demand_satisfaction = state.province_get_local_satisfaction(province, trade_good);

				auto price = state.province_get_local_prices(province, trade_good);
				auto score = need.demanded * price_score(price / weight);
				total_score += score;
				total_cost += need.demanded * score * price;
			});
		};

		if (total_score == 0.f) return;


		auto scale = 1.f;
		if (total_cost > 0.f) {
			scale = std::min(MAX_INDUCED_DEMAND, budget / total_cost);
		}

		for (uint32_t i = 0; i < state.pop_get_need_satisfaction_size(); i++) {
			base_types::need_satisfaction& need = state.pop_get_need_satisfaction(pop, i);
			auto use = dcon::use_case_id{dcon::use_case_id::value_base_t(need.use_case - 1)};
			if (!use)	break;
			state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
				auto weight = state.use_weight_get_weight(weight_id);
				auto trade_good = state.use_weight_get_trade_good(weight_id);
				// auto demand_satisfaction = state.province_get_local_satisfaction(province, trade_good);

				auto price = state.province_get_local_prices(province, trade_good);
				auto score = need.demanded * price_score(price / weight);
				auto distribution = score / total_score;

				auto demand = need.demanded * distribution * scale;

				record_demand(province, trade_good, demand);
			});
		};
	});
}

// same as for pops
void estates_demand(dcon::province_id province) {
	state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
		auto tile = state.tile_province_membership_get_tile(tile_membership);
		state.tile_for_each_estate_location(tile, [&](auto id) {
			auto estate = state.estate_location_get_estate(id);
			auto total_required_inputs = state.use_case_make_vectorizable_float_buffer();
			auto total_required_goods = state.trade_good_make_vectorizable_float_buffer();

			state.estate_for_each_building_estate(estate, [&](auto building_location) {
				auto building = state.building_estate_get_building(building_location);
				auto building_type = state.building_get_current_type(building);
				auto production_method = state.building_type_get_production_method(building_type);

				auto total_score = 0.01f;
				auto total_cost = 0.f;

				for (uint32_t i = 0; i < state.production_method_get_inputs_size(); i++) {
					base_types::use_case_container& input = state.production_method_get_inputs(production_method, i);

					if(input.use == 0) break;

					auto use = dcon::use_case_id{dcon::use_case_id::value_base_t(input.use - 1)};
					total_required_inputs.set(use, total_required_inputs.get(use) + input.amount);
				}
			});

			// turn use cases into goods:
			// we want to buy most cost effective goods first
			// very simplistic scoring:

			state.for_each_use_case([&](auto use){
				auto required = total_required_inputs.get(use);
				if (required == 0.f) {
					return;
				}
				float total_score = 0.f;
				state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
					auto weight = state.use_weight_get_weight(weight_id);
					auto trade_good = state.use_weight_get_trade_good(weight_id);
					auto price = state.province_get_local_prices(province, trade_good);
					auto score = weight / (price + 0.01f);

					total_score += score;
				});
				state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
					auto weight = state.use_weight_get_weight(weight_id);
					auto trade_good = state.use_weight_get_trade_good(weight_id);
					auto price = state.province_get_local_prices(province, trade_good);
					auto score = weight / (price + 0.01f);
					auto actual_score = score / total_score;
					total_required_goods.set(trade_good, total_required_goods.get(trade_good) + actual_score * required / weight);
				});
			});

			// calculate how much we can actually afford:
			float total_cost = 0.f;
			state.for_each_trade_good([&](auto trade_good) {
				auto price = state.province_get_local_prices(province, trade_good);
				total_cost += price * total_required_goods.get(trade_good);
			});
			float budget = state.estate_get_savings(estate);
			float can_buy = 1.f;
			if (total_cost > budget && total_cost > 0.f) {
				can_buy = budget / total_cost;
			}
			// now we can finally demand the goods:
			state.for_each_trade_good([&](auto trade_good) {
				record_demand(province, trade_good, total_required_goods.get(trade_good) * can_buy);
				state.estate_set_inventory_demanded_last_tick(estate, trade_good, total_required_goods.get(trade_good) * can_buy);
			});
		});
	});
}

void pops_buy() {
	state.for_each_pop([&](auto pop){
		auto estate = state.pop_get_estate_from_pop_location(pop);
		auto tile = state.estate_get_tile_from_estate_location(estate);
		auto province = state.tile_get_province_from_tile_province_membership(tile);

		auto budget = state.pop_get_savings(pop) * state.pop_get_spend_savings_ratio(pop);
		auto total_score = 0.01f;
		auto total_cost = 0.f;

		for (uint32_t i = 0; i < state.pop_get_need_satisfaction_size(); i++) {
			base_types::need_satisfaction& need = state.pop_get_need_satisfaction(pop, i);

			if (need.use_case == 0) break;

			auto use = dcon::use_case_id{dcon::use_case_id::value_base_t(need.use_case - 1)};
			state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
				auto weight = state.use_weight_get_weight(weight_id);
				auto trade_good = state.use_weight_get_trade_good(weight_id);
				auto demand_satisfaction = state.province_get_local_satisfaction(province, trade_good);

				auto price = state.province_get_local_prices(province, trade_good);

				assert(need.demanded >= 0.f);
				assert(price_score(price / weight) >= 0.f);
				assert(demand_satisfaction >= 0.f);

				auto score = need.demanded * price_score(price / weight) * demand_satisfaction;
				assert(score >= 0.f);

				total_score += score;
				total_cost += need.demanded * score * price;
			});
		};

		if (total_score == 0.f) return;

		auto scale = 0.f;
		if (total_cost > 0.f) {
			// buy a lot if price is low
			scale = std::min(MAX_INDUCED_DEMAND, budget / total_cost);
		}

		for (uint32_t i = 0; i < state.pop_get_need_satisfaction_size(); i++) {
			base_types::need_satisfaction& need = state.pop_get_need_satisfaction(pop, i);
			if (need.use_case == 0)	break;

			auto use = dcon::use_case_id{dcon::use_case_id::value_base_t(need.use_case - 1)};
			state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id){
				auto weight = state.use_weight_get_weight(weight_id);
				auto trade_good = state.use_weight_get_trade_good(weight_id);
				auto demand_satisfaction = state.province_get_local_satisfaction(province, trade_good);

				auto price = state.province_get_local_prices(province, trade_good);

				assert(need.demanded >= 0.f);
				assert(price_score(price / weight) >= 0.f);
				assert(demand_satisfaction >= 0.f);

				auto score = need.demanded * price_score(price / weight) * demand_satisfaction;

				assert(score >= 0.f);
				assert(total_score > 0.f);

				auto distribution = score / total_score;

				assert(distribution >= 0.f);
				assert(scale >= 0.f);

				auto demand = distribution * scale;

				assert(demand >= 0.f);
				assert(demand_satisfaction >= 0.f);

				state.pop_set_inventory(pop, trade_good, state.pop_get_inventory(pop, trade_good) + demand * demand_satisfaction);
				state.pop_set_pending_economy_income(
					pop,
					std::max(0.f, state.pop_get_pending_economy_income(pop)
					- demand * demand_satisfaction * price)
				);
			});
		};
	});
}

void pops_update_stats() {
	state.for_each_pop([&](auto pop) {
		auto total_basic_consumed = 0.f;
		auto total_basic_demanded = 0.f;

		auto total_life_demanded = 0.f;
		auto total_life_consumed = 0.f;

		for (uint32_t i = 0; i < state.pop_get_need_satisfaction_size(); i++) {
			base_types::need_satisfaction& need = state.pop_get_need_satisfaction(pop, i);
			if (need.use_case == 0) break;

			auto need_id = dcon::need_id{dcon::need_id::value_base_t(int(need.need) - 1)};

			if (state.need_get_life_need(need_id)){
				total_life_consumed += need.consumed;
				total_life_demanded += need.demanded;
			} else {
				total_basic_consumed += need.consumed;
				total_basic_demanded += need.demanded;
			}
		}

		auto life_satisfaction = total_life_consumed / total_life_demanded;
		auto basic_satisfaction = (total_basic_consumed + total_life_consumed) / (total_basic_demanded + total_life_demanded);
		state.pop_set_life_needs_satisfaction(pop, life_satisfaction);
		state.pop_set_basic_needs_satisfaction(pop, basic_satisfaction);

		// shift foraging based on life satisfaction
		auto forage_ratio = state.pop_get_forage_ratio(pop);
		if (life_satisfaction < 0.5f) {
			forage_ratio *= 1.05f;
		} else if (life_satisfaction >= 1.f) {
			forage_ratio *= 0.95f;
		}
		if (forage_ratio < 0.05f) forage_ratio = 0.05f;
		else if (forage_ratio > 0.95f) forage_ratio = 0.95f;
		state.pop_set_forage_ratio(pop, forage_ratio);
	});
}

void estates_buy() {
	// we do not change province data here
	// update is mostly serial without complex conditions and matrices
	// so we could run parallel over trade goods and serial over estates
	concurrency::parallel_for(uint32_t(0), state.trade_good_size(), [&](auto trade_good_raw_id) {
		dcon::trade_good_id trade_good { dcon::trade_good_id::value_base_t(trade_good_raw_id) };
		if (!state.trade_good_is_valid(trade_good)) return;

		state.execute_serial_over_estate([&](auto estates) {
			auto tile = state.estate_get_tile_from_estate_location(estates);
			auto provinces = state.tile_get_province_from_tile_province_membership(tile);
			auto price = state.province_get_local_prices(provinces, trade_good);

			auto demanded = state.estate_get_inventory_demanded_last_tick(estates, trade_good);
			auto actually_bought_ratio = state.province_get_local_satisfaction(provinces, trade_good);
			auto bought = demanded * actually_bought_ratio;

			auto cost = price * bought;

			auto budget = state.estate_get_savings(estates);
			auto stock = state.estate_get_inventory(estates, trade_good);
			auto last_change = state.estate_get_balance_last_tick(estates);

			state.estate_set_savings(estates, ve::max(0.f, budget - cost));
			state.estate_set_balance_last_tick(estates, last_change - cost);
			state.estate_set_inventory_bought_last_tick(estates, trade_good, bought);
			state.estate_set_inventory(estates, trade_good, stock + bought);
		});
	});
}

constexpr inline float WORKERS_SHARE = 0.01f;

// estates can interact only with local pops
// can do in parallel over provinces
void estates_pay(dcon::province_id province) {
	state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
		auto tile = state.tile_province_membership_get_tile(tile_membership);
		state.tile_for_each_estate_location(tile, [&](auto id) {
			auto estate = state.estate_location_get_estate(id);
			auto savings = state.estate_get_savings(estate);

			auto wage_budget = savings * WORKERS_SHARE;
			state.estate_get_balance_last_tick(estate) -= wage_budget;

			float total_work_time = 0.f;
			state.estate_for_each_building_estate(estate, [&](auto building_location) {
				auto building = state.building_estate_get_building(building_location);
				auto worker = state.building_get_worker_from_employment(building);
				if (worker) {
					total_work_time += state.pop_get_work_ratio(worker);
				}
			});

			if (total_work_time < 0.01f) {
				return;
			}

			state.estate_for_each_building_estate(estate, [&](auto building_location) {
				auto building = state.building_estate_get_building(building_location);
				auto worker = state.building_get_worker_from_employment(building);
				if (worker) {
					auto work_ratio = state.pop_get_work_ratio(worker);
					auto share = wage_budget * work_ratio / total_work_time;
					state.pop_get_pending_economy_income(worker) += share;
					state.building_set_worker_income_from_employment(building, share);
				}
			});
		});
	});
}

// TODO: rewrite more stuff to parallel loops, as there are a lot of opportunities for parallelisation
void update_economy() {
	uint32_t trade_goods_count = state.trade_good_size();

	// reset data
	state.for_each_building([&](auto building) {
		auto building_type = state.building_get_current_type(building);
		auto production_method = state.building_type_get_production_method(building_type);
		for (uint32_t i = 0; i < state.production_method_get_inputs_size(); i++) {
			base_types::trade_good_container& output = state.building_get_amount_of_outputs(building, i);
			base_types::use_case_container& input = state.building_get_amount_of_inputs(building, i);
			base_types::trade_good_container& base_output = state.production_method_get_outputs(production_method, i);
			base_types::use_case_container& base_input = state.production_method_get_inputs(production_method, i);
			output.amount = 0.f;
			output.good = base_output.good;
			input.amount = 0.f;
			input.use = base_input.use;
		}
	});
	state.execute_serial_over_estate([&](auto estates) {
		state.estate_set_balance_last_tick(estates, 0.f);
	});
	concurrency::parallel_for(uint32_t(0), state.trade_good_size(), [&](auto trade_good_raw_id) {
		dcon::trade_good_id trade_good { dcon::trade_good_id::value_base_t(trade_good_raw_id) };
		if (!state.trade_good_is_valid(trade_good)) return;
		state.execute_serial_over_estate([&](auto estates) {
			state.estate_set_inventory_demanded_last_tick(estates, trade_good, 0.f);
			state.estate_set_inventory_sold_last_tick(estates, trade_good, 0.f);
			state.estate_set_inventory_bought_last_tick(estates, trade_good, 0.f);
		});
	});

	// update pops self value
	state.execute_serial_over_pop([&](auto pops) {
		state.pop_set_expected_wage(pops, ve::max(state.pop_get_savings(pops) * 0.01f, state.pop_get_expected_wage(pops)));
	});

	auto eps = 0.001f;

	update_building_scale();

	const float pop_donation = 0.05f;

	concurrency::parallel_for(uint32_t(0), state.province_size(), [&](auto province_raw_id) {
		dcon::province_id province{ dcon::province_id::value_base_t(province_raw_id) };
		if (!state.province_is_valid(province)) return;
		float donation = 0.f;
		state.province_for_each_tile_province_membership_as_province(province, [&](auto tile_membership) {
			auto tile = state.tile_province_membership_get_tile(tile_membership);
			state.tile_for_each_estate_location(tile, [&](auto id) {
				auto estate = state.estate_location_get_estate(id);
				state.estate_for_each_pop_location_as_estate(estate, [&](auto pop_location) {
					auto pop = state.pop_location_get_pop(pop_location);
					auto character_location = state.pop_get_estate_from_character_location(pop);
					if (character_location) return;

					donation += state.pop_get_savings(pop) * pop_donation;
					state.pop_get_savings(pop) *= (1.f - pop_donation);
				});
			});
		});
		state.province_get_local_wealth(province) += donation * 0.8f;
		state.province_get_trade_wealth(province) += donation * 0.2f;

		float local_wealth = state.province_get_local_wealth(province);
		float trade_wealth = state.province_get_trade_wealth(province);
		state.province_set_local_wealth(province, local_wealth * 0.9f + trade_wealth * 0.1f);
		state.province_set_trade_wealth(province, local_wealth * 0.1f + trade_wealth * 0.9f);
	});

	state.execute_serial_over_pop([&](auto ids){
		state.pop_set_pending_economy_income(ids, 0.f);
	});

	// demand stage
	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };
		state.execute_serial_over_province([&](auto ids){
			state.province_set_local_demand(ids, trade_good, 0.f);
		});
	});

	pops_demand();
	concurrency::parallel_for(uint32_t(0), state.province_size(), [&](auto province_raw_id) {
		dcon::province_id province{ dcon::province_id::value_base_t(province_raw_id) };
		if (!state.province_is_valid(province)) return;
		estates_demand(province);
	});

	// stockpiles demand cheap goods:
	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };

		auto decay = state.trade_good_get_decay(trade_good);

		state.execute_serial_over_province([&](auto ids){

			auto current_demand = state.province_get_local_demand(ids, trade_good);

			auto local_price = state.province_get_local_prices(ids, trade_good);
			auto merchants_wealth = state.province_get_trade_wealth(ids);
			auto budget = merchants_wealth * 0.5f / trade_goods_count;
			auto target = budget / (local_price + 1.f) * (0.1f + decay);
			auto current = state.province_get_local_storage(ids, trade_good);
			auto demand = ve::select(target > current, target - current, 0.f);

			state.province_set_local_demand(ids, trade_good, current_demand + demand);
			state.province_set_local_merchants_demand(ids, trade_good, demand);
		});
	});

	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };
		state.execute_serial_over_province([&](auto ids){
				state.province_set_local_production(ids, trade_good, 0.f);
		});
	});
	pops_sell();
	concurrency::parallel_for(uint32_t(0), state.province_size(), [&](auto province_raw_id) {
		dcon::province_id province{ dcon::province_id::value_base_t(province_raw_id) };
		if (!state.province_is_valid(province)) return;
		estates_sell(province);
	});

	// stockpiles sell out expensive goods
	for (int good_id = uint32_t(0); good_id < trade_goods_count; good_id++) {
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };

		auto decay = state.trade_good_get_decay(trade_good);

		state.execute_serial_over_province([&](auto ids){

			auto current_supply = state.province_get_local_production(ids, trade_good);

			auto local_price = state.province_get_local_prices(ids, trade_good);
			auto merchants_wealth = state.province_get_trade_wealth(ids);
			auto budget = merchants_wealth * 0.5f / trade_goods_count;
			auto target = budget / (local_price + 1.f) * (0.1f + decay);
			auto current = state.province_get_local_storage(ids, trade_good);
			auto supply = ve::select(target < current, current - target, 0.f);

			state.province_set_local_production(ids, trade_good, current_supply + supply);
			state.province_set_local_storage(ids, trade_good, current - supply);
			state.province_set_trade_wealth(ids, merchants_wealth + supply * local_price);
		});
	};

	// decay inventories of producers
	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };
		float inventory_decay = state.trade_good_get_decay(trade_good);
		state.execute_serial_over_pop([&](auto ids){
			auto inventory = state.pop_get_inventory(ids, trade_good);
			state.pop_set_inventory(ids, trade_good, inventory * inventory_decay);
		});
		state.execute_serial_over_estate([&](auto ids){
			auto inventory = state.estate_get_inventory(ids, trade_good);
			state.estate_set_inventory(ids, trade_good, inventory * inventory_decay);
		});
	});

	// decay inventories in provinces and realms:
	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };
		float inventory_decay = state.trade_good_get_decay(trade_good);
		state.execute_serial_over_province([&](auto ids){
			auto stockpiles = state.province_get_local_storage(ids, trade_good);
			state.province_set_local_storage(ids, trade_good, stockpiles * inventory_decay);
		});
		state.execute_serial_over_realm([&](auto ids){
			auto stockpiles = state.realm_get_resources(ids, trade_good);
			state.realm_set_resources(ids, trade_good, stockpiles * inventory_decay);
		});
	});

	// supply: calculated
	// demand: calculated
	// update demand satisfaction
	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };

		auto decay = state.trade_good_get_decay(trade_good);

		state.execute_serial_over_province([&](auto ids){
			auto current = state.province_get_local_storage(ids, trade_good);
			auto demand = state.province_get_local_demand(ids, trade_good);
			auto production = state.province_get_local_production(ids, trade_good);
			auto satisfaction = ve::select(demand <= production, 1.f, production / demand);
			state.province_set_local_satisfaction(ids, trade_good, satisfaction);
			state.province_set_local_storage(ids, trade_good, ve::max(0.f, current + production * decay - satisfaction * demand));
		});
	});

	// now we are able to execute buyment requests
	estates_buy();
	pops_buy();

	// stockpiles actually buy out demanded goods:
	for (int good_id = uint32_t(0); good_id < trade_goods_count; good_id++) {
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };

		auto decay = state.trade_good_get_decay(trade_good);

		state.execute_serial_over_province([&](auto ids){
			auto local_price = state.province_get_local_prices(ids, trade_good);
			auto merchants_wealth = state.province_get_trade_wealth(ids);
			auto current = state.province_get_local_storage(ids, trade_good);
			auto demand = state.province_get_local_merchants_demand(ids, trade_good);
			auto satisfied_demand = state.province_get_local_satisfaction(ids, trade_good);

			state.province_set_local_storage(ids, trade_good, current + demand * satisfied_demand);
			state.province_set_trade_wealth(ids, merchants_wealth - demand * satisfied_demand * local_price);
		});
	};

	state.execute_parallel_over_province([&](auto provinces) {
		ve::apply([&](dcon::province_id p) { pops_produce(p); }, provinces);
	});
	state.for_each_warband([&](auto warband) {
		if (!state.warband_get_in_settlement(warband)) {
			auto tile = state.warband_get_location_from_warband_location(warband);
			auto province = state.tile_get_province_from_tile_province_membership(tile);
			state.warband_for_each_warband_unit(warband, [&](auto warband_unit) {
				auto pop = state.warband_unit_get_unit(warband_unit);
				pop_forage_update(pop, province);
			});
		}
	});

	pops_consume();
	state.execute_parallel_over_province([&](auto provinces) {
		ve::apply([&](dcon::province_id p) { estates_produce(p); }, provinces);
	});

	// now we sum up production and calculate trading balance in savings of local merchants

	state.for_each_trade_good([&](auto trade_good) {
		state.execute_serial_over_province([&](auto province){
			auto demanded = state.province_get_local_demand(province, trade_good);
			auto satisfied = ve::min(1.f, state.province_get_local_satisfaction(province, trade_good));
			auto produced = state.province_get_local_production(province, trade_good);
			auto price = state.province_get_local_prices(province, trade_good);

			auto balance = demanded * satisfied - produced * price;
			auto wealth = state.province_get_trade_wealth(province);

			auto result = ve::select(balance + wealth > 0.f, balance + wealth, 0.f);
			state.province_set_trade_wealth(province, result);
			state.province_set_local_consumption(province, trade_good, demanded * satisfied);
		});
	});

	concurrency::parallel_for(uint32_t(0), trade_goods_count, [&](auto good_id){
		dcon::trade_good_id trade_good{ dcon::trade_good_id::value_base_t(good_id) };
		state.execute_serial_over_province([&](auto ids){
			auto supply = state.province_get_local_production(ids, trade_good) + 0.2f;
			auto demand = state.province_get_local_demand(ids, trade_good) + 0.1f;

			auto current_price = state.province_get_local_prices(ids, trade_good);

			auto oversupply = supply / demand;
			auto overdemand = demand / supply;

			auto speed = 0.01f * (overdemand - oversupply);

			auto new_price = ve::min(1000.f, ve::max(0.01f, current_price + speed));

			state.province_set_local_prices(ids, trade_good, new_price);
		});
	});

	state.execute_parallel_over_province([&](auto provinces) {
		ve::apply([&](dcon::province_id p) { estates_pay(p); }, provinces);
	});
	pops_update_stats();
}

float estimate_province_use_price(dcon::province_id province, dcon::use_case_id use) {
	auto min_adjusted_price = std::numeric_limits<float>::max();

	state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id) {
		auto good = state.use_weight_get_trade_good(weight_id);
		auto weight = state.use_weight_get_weight(weight_id);
		auto price = state.province_get_local_prices(province, good);

		auto adjusted_price = price / weight;

		if (adjusted_price < min_adjusted_price) {
			min_adjusted_price = adjusted_price;
		}
	});

	float integral = 0;
	float integral_of_identity = 0;

	state.use_case_for_each_use_weight_as_use_case(use, [&](auto weight_id) {
		auto good = state.use_weight_get_trade_good(weight_id);
		auto weight = state.use_weight_get_weight(weight_id);
		auto price = state.province_get_local_prices(province, good);

		auto adjusted_price = price / weight;
		auto predensity = expf(-adjusted_price + min_adjusted_price);

		integral_of_identity = integral_of_identity + predensity;
		integral = integral + adjusted_price * predensity;
	});

	return integral / integral_of_identity;
}

// uses softmax of adjusted prices to calculate distribution used in estimation
float estimate_province_use_price(uint32_t province_lua_id, uint32_t use_lua_id) {
	dcon::province_id province {dcon::province_id::value_base_t(province_lua_id - 1)};
	dcon::use_case_id use {dcon::use_case_id::value_base_t(use_lua_id - 1)};

	return estimate_province_use_price(province, use);
}

float estimate_building_type_income(int32_t province_lua, int32_t building_type_lua, int32_t race_lua, bool female) {
	dcon::province_id province {dcon::province_id::value_base_t(province_lua - 1)};
	dcon::building_type_id building_type {dcon::building_type_id::value_base_t(building_type_lua - 1)};
	dcon::race_id race {dcon::race_id::value_base_t(race_lua - 1)};
	auto method = state.building_type_get_production_method(building_type);
	auto associated_job = state.production_method_get_job_type(method);
	auto efficiency = job_efficiency(race, female, associated_job);

	float throughput_boost =
		(1 + state.province_get_throughput_boosts(province, method))
		* efficiency;
	float input_modifier = std::max(0.f, 1 - state.province_get_input_efficiency_boosts(province, method));
	float output_modifier =
		(1 + state.province_get_output_efficiency_boosts(province, method))
		* efficiency;

	float income = 0;
	for (uint32_t i = 0; i < state.production_method_get_inputs_size(); i++) {
		base_types::use_case_container& input = state.production_method_get_inputs(method, i);
		if(!input.use) {
			break;
		}

		auto use = dcon::use_case_id {dcon::use_case_id::value_base_t(input.use - 1)};
		income -= input_modifier * estimate_province_use_price(province, use) * input.amount;
	}
	for (uint32_t i = 0; i < state.production_method_get_outputs_size(); i++) {
		base_types::trade_good_container& output = state.production_method_get_outputs(method, i);
		if(!output.good) {
			break;
		}
		auto good = dcon::trade_good_id{dcon::trade_good_id::value_base_t(output.good - 1)};
		income += output.amount * output_modifier * state.province_get_local_prices(province, good);
	}

    return income * throughput_boost;
}


void set_province_data(dcon::province_id province, uint8_t index, base_types::FORAGE_RESOURCE forage, int32_t output_raw_id, float output_value, float available_amount){

	base_types::forage_container& forage_data = state.province_get_foragers_targets(province, index - 1);

	forage_data.forage = forage;
	forage_data.amount = available_amount;
	forage_data.output_good = output_raw_id;
	forage_data.output_value = output_value * 4;
}


void update_foraging_data(
	int32_t province_raw_id,
	int32_t water_raw_id,
	int32_t berries_raw_id,
	int32_t grain_raw_id,
	int32_t bark_raw_id,
	int32_t timber_raw_id,
	int32_t meat_raw_id,
	int32_t hide_raw_id,
	int32_t mushroom_raw_id,
	int32_t shellfish_raw_id,
	int32_t seaweed_raw_id,
	int32_t fish_raw_id,
	int32_t world_size
) {
	auto province = dcon::province_id { dcon::province_id::value_base_t(province_raw_id - 1)};

	auto hydration = state.province_get_hydration(province);
	float fruit = 0.f;
	float seeds = 0.f;
	float shell = 0.f;
	float fish = 0.f;
	float game = 0.f;
	float wood = 0.f;


	state.province_for_each_tile_province_membership_as_province(province, [&](auto membership) {

		dcon::tile_id tile_id = state.tile_province_membership_get_tile(membership);

		float warmest = state.tile_get_january_temperature(tile_id);
		float coldest = state.tile_get_july_temperature(tile_id);
		if (coldest > warmest) {
			std::swap(warmest, coldest);
		}

		float grass = state.tile_get_grass(tile_id);
		float shrub = state.tile_get_shrub(tile_id);
		float broadleaf = state.tile_get_broadleaf(tile_id);
		float conifer = state.tile_get_conifer(tile_id);

		float effective_temperature = (18.f * warmest - 10.f * coldest) / (warmest - coldest + 8.f);
		float temperture_weighting =  1.f / (1.f + expf(-0.2f * (effective_temperature - 10.f)));

		float primary_production = temperture_weighting * (0.5 * grass + 0.4 * shrub + 0.3 * broadleaf + 0.2 * conifer);
		float wood_production = temperture_weighting * (0.3 * conifer + 0.2 * broadleaf + 0.1 * shrub);

		// weight net production by 'biomass' assimilation efficiency
		// some of assimilation efficiency goes towards structural material: timber

		// check for marine resources
		float marine_production = 0.f;

		if (state.tile_get_has_marsh(tile_id)) {
			marine_production += 0.5f;
		}
		if (state.tile_get_has_river(tile_id)) {
			marine_production += 0.5f;
		}

		for (uint32_t i = 1; i <= 4; i++) {
			auto neighbor = dcon::tile_id{ (dcon::tile_id::value_base_t)(get_neighbor(tile_id.index() + 1, i, world_size) - 1)};
			if (!state.tile_get_is_land(neighbor)) {
				marine_production += 0.25f;
			}
		}


		if (primary_production > 0) {
			// determine animal energy from eating folliage and reduce from plant output
			game += 0.125 * (primary_production + wood_production);
			primary_production = primary_production * 0.875;
			wood_production = wood_production * 0.875;

			// determine plant food from remaining pp
			auto fruit_plants = shrub + broadleaf;
			auto seed_plants = conifer + grass;
			auto flora_total = fruit_plants + seed_plants;
			if (flora_total > 0.f) {
				auto fruit_percentage = 0.5f / (1 + expf(-10.f * (fruit_plants / flora_total - 0.5f)));
				fruit += primary_production * (0.25f + fruit_percentage);
				seeds += primary_production * (0.75f - fruit_percentage);
			}
		}
		if (marine_production > 0) {
			// determine animal energy from marine output
			game += 0.125f * marine_production;
			marine_production = marine_production * 0.875f;
			// determine marine food spread from climate
			auto temperature_weight = 0.75f / (1.f + expf(-0.125f*(effective_temperature - 16.f)));
			shell += marine_production * (0.25f + temperature_weight * 0.25f);
			fish += marine_production * (0.75f - temperature_weight * 0.25f);
		}

		wood += wood_production;
	});

	auto net_production = fruit + seeds + shell + fish + game;
	// determine energy available in decomposers
	auto fungi = net_production * 0.125f;

	set_province_data(province, 1, base_types::FORAGE_RESOURCE::WATER, water_raw_id, 8, hydration);
	set_province_data(province, 2, base_types::FORAGE_RESOURCE::FRUIT, berries_raw_id, 1.6, fruit);
	set_province_data(province, 3, base_types::FORAGE_RESOURCE::GRAIN, grain_raw_id, 2, seeds);
	set_province_data(province, 4, base_types::FORAGE_RESOURCE::WOOD, bark_raw_id, 1.25, wood);
	set_province_data(province, 5, base_types::FORAGE_RESOURCE::WOOD, timber_raw_id, 0.25, wood);
	set_province_data(province, 6, base_types::FORAGE_RESOURCE::GAME, meat_raw_id, 1, game);
	set_province_data(province, 7, base_types::FORAGE_RESOURCE::GAME, hide_raw_id, 0.25, game);
	set_province_data(province, 8, base_types::FORAGE_RESOURCE::FUNGI, mushroom_raw_id, 1.25, fungi);
	set_province_data(province, 9, base_types::FORAGE_RESOURCE::SHELL, shellfish_raw_id, 1, shell);
	set_province_data(province, 10, base_types::FORAGE_RESOURCE::SHELL, seaweed_raw_id, 2, shell);
	set_province_data(province, 11, base_types::FORAGE_RESOURCE::FISH, fish_raw_id, 1.25, fish);
	state.province_set_foragers_limit(province, net_production);
}

struct image_coord {
	uint32_t x;
	uint32_t y;
};

const image_coord face_to_offset[6] = {
	{0, 0},
	{1, 0},
	{2, 0},
	{0, 1},
	{1, 1},
	{2, 1}
};

image_coord tile_id_to_color_coords(dcon::tile_id tile, uint32_t world_size) {
	auto cube_coord = id_to_coords(tile.index() + 1, world_size);
	uint32_t fx = face_to_offset[cube_coord.f].x * world_size;
	uint32_t fy = face_to_offset[cube_coord.f].y * world_size;
	return {cube_coord.x + fx, cube_coord.y + fy};
}

void update_map_mode_pointer(uint8_t* map, uint32_t world_size) {
	state.for_each_tile([&](dcon::tile_id tile) {
		auto pixel = tile_id_to_color_coords(tile, world_size);
		auto pixel_index = pixel.x + pixel.y * world_size * 3;

		auto r = state.tile_get_real_r(tile);
		auto g = state.tile_get_real_g(tile);
		auto b = state.tile_get_real_b(tile);

		map[pixel_index * 4 + 0] = uint8_t(255 * r);
		map[pixel_index * 4 + 1] = uint8_t(255 * g);
		map[pixel_index * 4 + 2] = uint8_t(255 * b);
		map[pixel_index * 4 + 3] = uint8_t(255 * 1);
	});
}

void ai_update_price_belief(int32_t trader_raw_id) {
	auto trader = dcon::pop_id { dcon::pop_id::value_base_t(trader_raw_id - 1)};
	auto estate = state.pop_get_estate_from_character_location(trader);
	auto tile = state.estate_get_tile_from_estate_location(estate);
	auto province = state.tile_get_province_from_tile_province_membership(tile);

	// there is passive decrease of sell price
	// and passive increase of buy price (up to a certain limit)
	// to represent reduction of confidence in ability
	// to sell and buy at current prices you believe in

	// another force is moving your price beliefs toward the local price

	state.for_each_trade_good([&](dcon::trade_good_id tgid) {
		auto sell = state.pop_get_price_belief_sell(trader, tgid);
		auto buy = state.pop_get_price_belief_buy(trader, tgid);
		auto local_price = state.province_get_local_prices(province, tgid);

		if (sell == 0.f) {
			state.pop_set_price_belief_sell(trader, tgid, local_price * 0.8);
		}
		if (buy == 0.f) {
			state.pop_set_price_belief_buy(trader, tgid, local_price * 1.2);
		}

		auto belief_sell_gradient = (local_price * 0.9f - sell) * 0.1f - 0.01f;
		auto belief_buy_gradient = (local_price * 1.1f - buy) * 0.1f + 0.01f;

		state.pop_set_price_belief_sell(trader, tgid, std::max(0.01f, sell + belief_sell_gradient));
		state.pop_set_price_belief_buy(trader, tgid, std::max(0.01f, buy + belief_buy_gradient));
	});
}

void ai_trade(int32_t trader_raw_id) {
	auto trader = dcon::pop_id { dcon::pop_id::value_base_t(trader_raw_id - 1)};
	auto estate = state.pop_get_estate_from_character_location(trader);
	auto tile = state.estate_get_tile_from_estate_location(estate);
	auto province = state.tile_get_province_from_tile_province_membership(tile);

	if (!province) {
		return;
	}

	if (state.pop_get_is_player(trader)) {
		return;
	}

	// buy if you belive you can sell for higher price
	// sell if you belive you can buy for lower price

	auto& wealth = state.pop_get_savings(trader);
	auto& local_traders_wealth = state.province_get_local_wealth(province);

	state.for_each_trade_good([&](dcon::trade_good_id tgid) {
		auto sell = state.pop_get_price_belief_sell(trader, tgid);
		auto buy = state.pop_get_price_belief_buy(trader, tgid);

		auto local_price = state.province_get_local_prices(province, tgid);
		auto& local_stockpile = state.province_get_local_storage(province, tgid);
		auto& trader_stockpile = state.pop_get_inventory(trader, tgid);

		// TODO: move the sell and buy functions to cpp
		// and figure out a way to store notifications

		if (local_stockpile >= 1 && wealth > local_price && sell > local_price * 1.2f) {
			wealth -= local_price;
			local_traders_wealth += local_price;
			local_stockpile -= 1;
			trader_stockpile += 1;
		}

		if (trader_stockpile >= 1 && local_traders_wealth > local_price && buy < local_price * 0.8f) {
			wealth += local_price;
			local_traders_wealth -= local_price;
			local_stockpile += 1;
			trader_stockpile -= 1;
		}
	});
}