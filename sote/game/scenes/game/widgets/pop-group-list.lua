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
                header = "h",
                render_closure = function(rect, k, v)
                    local subrect = rect:centered_square()
                    subrect:shrink(1)
                    ut.coa(v.home_province.realm, subrect)
                    ui.tooltip("This pop considers itself a memeber of " .. v.home_province.realm.name .. ".", rect)
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.home_province.realm.name
                end
            },
            {
                header = "r",
                render_closure = function (rect, k, v)
                    local subrect = rect:centered_square()
                    subrect:shrink(1)
                    ut.render_icon(subrect, v.race.icon, 1, 1, 1, 1)
                    subrect:shrink(-1)
                    ut.render_icon(subrect, v.race.icon, v.race.r, v.race.g, v.race.b, 1)
                    ui.tooltip("This pop is a " .. v.race.name .. ".", rect)
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.race.name
                end
            },
            {
                header = "c",
                render_closure = function (rect, k, v)
                    local subrect = rect:centered_square()
                    subrect:shrink(1)
                    ut.render_icon(subrect, "musical-notes.png", 1, 1, 1, 1)
                    subrect:shrink(-1)
                    ut.render_icon(subrect, "musical-notes.png", v.culture.r, v.culture.g, v.culture.b, 1)
                    ui.tooltip("This pop follows the customs of " .. v.culture.name .. "."
                        .. require "game.economy.diet-breadth-model".culture_target_tooltip(v.culture), rect)
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.culture.name
                end
            },
            {
                header = "f",
                render_closure = function (rect, k, v)
                    local subrect = rect:centered_square()
                    subrect:shrink(1)
                    ut.render_icon(subrect, "tombstone.png", 1, 1, 1, 1)
                    subrect:shrink(-1)
                    ut.render_icon(subrect, "tombstone.png", v.faith.r, v.faith.g, v.faith.b, 1)
                    ui.tooltip("This pop is a member of the " .. v.faith.name .. " faith.", rect)
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.faith.name
                end
            },
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
                header = "description",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(v.name, rect)
                end,
                width = 6,
                value = function(k, v) ---@param v PopGroup
                    return v.name
                end
            },
            {
                header = "size",
                render_closure = function (rect, k, v) ---@param v PopGroup
                    ui.centered_text(tostring(v.size), rect)
                end,
                width = 3,
                value = function(k, v) ---@param v PopGroup
                    return v.size
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
                width = 3,
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
                width = 3,
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
                width = 3,
                value = function(k, v) ---@param v PopGroup
                    return v.savings
                end
            },
            {
                header = "satisfac.",
                render_closure = ut.render_pop_satsifaction,
                width = 3,
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
                width = 3,
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