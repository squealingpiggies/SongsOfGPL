local ui = require "engine.ui";
local ut = require "game.ui-utils"

local inspector = {}

---@return Rect
local function get_main_panel()
	local fs = ui.fullscreen()
	return fs:subrect(ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 2, ut.BASE_HEIGHT * 45, fs.height / 2, "left", "up")
end

---Returns whether or not clicks on the planet can be registered.
---@return boolean
function inspector.mask()
	if ui.trigger(get_main_panel()) then
		return false
	else
		return true
	end
end

---comment
---@param gam GameScene
function inspector.draw(gam)
    local rect = get_main_panel()

    ui.panel(rect)

    if ut.icon_button(ASSETS.icons["cancel.png"], rect:subrect(0, 0, ut.BASE_HEIGHT, ut.BASE_HEIGHT, "right", "up")) then
        gam.inspector = "tile"
    end

    local province = gam.selected.province

    if province == nil then
        return
    end

    local base_unit = ut.BASE_HEIGHT

    local population_data_rect = rect:subrect(0, 0, base_unit * 9, base_unit, "left", "up")

    ut.integer_entry("Population:", province:local_population(), population_data_rect)
    population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    ut.integer_entry("Groups:", require "engine.table".size(province.characters), population_data_rect)
    population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    ut.integer_entry("Families:", require "engine.table".size(province.characters), population_data_rect)
    population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    ut.integer_entry("Characters:", require "engine.table".size(province.characters), population_data_rect)
    population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    --ut.integer_entry("Families:",require "engine.table".size(province.families), population_data_rect)
    --population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    -- ut.money_entry("Trade wealth:", province.trade_wealth, population_data_rect)
    -- population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    -- ut.money_entry("Local income:", province.local_income, population_data_rect)
    -- population_data_rect.x = population_data_rect.x + population_data_rect.width + base_unit
    -- ut.money_entry("Local building upkeep:", province.local_building_upkeep, population_data_rect)
    -- population_data_rect.y = population_data_rect.y + base_unit

    rect.y = rect.y + base_unit
    rect.height = rect.height - base_unit
    if not  gam.pops_inspector_tab then  gam.pops_inspector_tab = "ALL POPS" end
    gam.pops_inspector_tab = ut.tabs(
        gam.pops_inspector_tab,
        ui.layout_builder():position(rect.x, rect.y):horizontal():build(),
        {
            {
                text = "ALL POPS",
                tooltip = "A listing of all pops currently in this province.",
                closure = function ()
                    require "game.scenes.game.widgets.pop-list" (rect, base_unit, province)()
                end,
            },
            {
                text = "POP GROUPS",
                tooltip = "A listing of current pops in this province grouped by home, race, cutlure, and faith.",
                closure = function ()
                    require "game.scenes.game.widgets.pop-group-list" (rect, base_unit, province)()
                end,
            }
        },
        1, ut.BASE_HEIGHT * 6
    )
end

return inspector