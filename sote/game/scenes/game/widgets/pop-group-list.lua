local tabb = require "engine.table"
local ui = require "engine.ui"
local ut = require "game.ui-utils"

---@type TableState
local state = nil

local function init_state(base_unit)
    if state == nil then
        state = {
            header_height = UI_STYLE.table_header_height,
            individual_height = UI_STYLE.scrollable_list_item_height,
            slider_level = 0,
            slider_width = UI_STYLE.slider_width,
            sorted_field = 1,
            sorting_order = true
        }
    else
        state.header_height = UI_STYLE.table_header_height
        state.individual_height = UI_STYLE.scrollable_list_item_height
        state.slider_width = UI_STYLE.slider_width
    end
end

---@param rect Rect
---@param base_unit number
---@param province Province
return function(rect, base_unit, province)
    return function()
        ---@type TableColumn[]
        local columns = {
            {
                header = ".",
                render_closure = function(rect, k, v) ---@param v PopGroup
                    --ui.image(ASSETS.get_icon(v.race.icon)
                    require "game.scenes.game.widgets.portrait"(rect, v.head)
                end,
                width = 1,
                value = function(k, v) ---@param v PopGroup
                    return v.name
                end
            },
            {
                header = "head",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(v.head.name, rect)
                end,
                width = 6,
                value = function(k, v) ---@param v PopGroup
                    return v.head.name
                end
            },
            {
                header = "race",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(v.race.name, rect)
                end,
                width = 4,
                value = function(k, v) ---@param v PopGroup
                    return v.race.name
                end
            },
            {
                header = "culture",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(v.culture.name, rect)
                    ui.tooltip("This character follows the customs of " .. v.culture.name .. "."
                        .. require "game.economy.diet-breadth-model".culture_target_tooltip(v.culture), rect)
                end,
                width = 4,
                value = function(k, v) ---@param v PopGroup
                    return v.culture.name
                end
            },
            {
                header = "faith",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(v.faith.name, rect)
                end,
                width = 4,
                value = function(k, v) ---@param v PopGroup
                    return v.faith.name
                end
            },
            {
                header = "home",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(v.home_province.name, rect)
                end,
                width = 4,
                value = function(k, v) ---@param v PopGroup
                    return v.home_province.name
                end
            },
            {
                header = "size",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(tostring(tabb.size(v:pops())), rect)
                end,
                width = 2,
                value = function(k, v) ---@param v PopGroup
                    return tabb.size(v:pops())
                end
            },
            {
                header = "weight",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ut.generic_number_field(
                        "",
                        v:population_weight(),
                        rect,
                        "Combined CC weight of population group.",
                        ut.NUMBER_MODE.NUMBER,
                        ut.NAME_MODE.NAME
                    )
                end,
                width = 2,
                value = function(k, v) ---@param v PopGroup
                    return v:population_weight()
                end
            },
            {
                header = "work",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ut.generic_number_field(
                        "stone-crafting.png",
                        v.work_ratio,
                        rect,
                        "Percent of free time spent working versus foraging.",
                        ut.NUMBER_MODE.PERCENTAGE,
                        ut.NAME_MODE.ICON
                    )
                end,
                width = 2,
                value = function(k, v) ---@param v PopGroup
                    return v.work_ratio
                end
            },
            {
                header = "savings",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ut.money_entry(
                        "",
                        v.savings,
                        rect,
                        "Total wealth of this pop group. "
                        .. "Pops spend them on buying food and other commodities."
                    )
                end,
                width = 2,
                value = function(k, v) ---@param v PopGroup
                    return v.savings
                end
            },
            {
                header = "satisfac.",
                render_closure = ut.render_pop_satsifaction,
                width = 2,
                value = function(k, v) ---@param v PopGroup
                    return v.basic_needs_satisfaction
                end
            },
            {
                header = "life needs",
                render_closure = function (rect, k, v) ---@param v PopGroup

                    local needs_tooltip = ""
                    for need, values in pairs(v.need_satisfaction) do
                        local tooltip = ""
                        if NEEDS[need].life_need then
                            for case, value in pairs(values) do
                                if value.demanded > 0 then
                                    tooltip = tooltip .. "\n  " .. case .. ": "
                                        .. ut.to_fixed_point2(value.consumed) .. " / " .. ut.to_fixed_point2(value.demanded)
                                        .. " (" .. ut.to_fixed_point2(value.consumed / value.demanded * 100) .. "%)"
                                end
                            end
                        end
                        if tooltip ~= "" then
                            needs_tooltip = needs_tooltip .. "\n".. NEED_NAME[need] .. ": " .. tooltip
                        end
                    end

                    ut.data_entry_percentage(
                        "",
                        v.life_needs_satisfaction,
                        rect,
                        "Satisfaction of life needs of this character. " .. needs_tooltip
                    )
                end,
                width = 2,
                value = function(k, v) ---@param v PopGroup
                    return v.life_needs_satisfaction
                end
            }
        }
        init_state(base_unit)
        local top = rect:subrect(0, 0, rect.width, base_unit, "left", "up")
        local bottom = rect:subrect(0, base_unit, rect.width, rect.height - base_unit, "left", "up")
        ui.centered_text("Population Groups", top)
        ut.table(bottom, province:get_pop_groups(), columns, state)
    end
end