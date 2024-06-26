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

local function render_name(rect, k, v)
    local children = tabb.size(v.children)
    local name = v.name
    if v.parent then
        name = name .. " [" .. v.parent.name .. "]"
    end
    if children > 0 then
        name = name .. " (" .. children .. ")"
    end
    ui.left_text(name, rect)
end

---comment
---@param pop POP
---@return string
local function pop_display_occupation(pop)
    local job = "unemployed"
    if pop.job then
        job = pop.job.name
    elseif pop.age < pop.race.teen_age then
        job = "child"
    elseif pop.unit_of_warband then
        job = "warrior"
    end
    return job
end

local function pop_sex(pop)
    local f = "m"
    if pop.female then f = "f" end
    return f
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
                render_closure = function(rect, k, v)
                    --ui.image(ASSETS.get_icon(v.race.icon)
                    require "game.scenes.game.widgets.portrait"(rect, v)
                end,
                width = 1,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.name
                end
            },
            {
                header = "name",
                render_closure = render_name,
                width = 6,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.name
                end
            },
            {
                header = "race",
                render_closure = function (rect, k, v)
                    ui.centered_text(v.race.name, rect)
                end,
                width = 4,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.race.name
                end
            },
            {
                header = "culture",
                render_closure = function (rect, k, v)
                    ui.centered_text(v.culture.name, rect)
                    ui.tooltip("This character follows the customs of " .. v.culture.name .. "."
                        .. require "game.economy.diet-breadth-model".culture_target_tooltip(v.culture), rect)
                end,
                width = 4,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.culture.name
                end
            },
            {
                header = "faith",
                render_closure = function (rect, k, v)
                    ui.centered_text(v.faith.name, rect)
                end,
                width = 4,
                value = function(k, v)
                    ---@type POP
                    v = v
                    return v.faith.name
                end
            },
            {
                header = "job",
                render_closure = function (rect, k, v)
                    ui.centered_text(pop_display_occupation(v), rect)
                end,
                width = 4,
                value = function(k, v)
                    return pop_display_occupation(v)
                end
            },
            {
                header = "age",
                render_closure = function (rect, k, v)
                    ui.right_text(tostring(v.age), rect)
                end,
                width = 2,
                value = function(k, v)
                    return v.age
                end
            },
            {
                header = "sex",
                render_closure = function (rect, k, v)
                    ui.centered_text(pop_sex(v), rect)
                end,
                width = 1,
                value = function(k, v)
                    return pop_sex(v)
                end
            },
            {
                header = "savings",
                render_closure = function (rect, k, v)
                    ---@type POP
                    v = v
                    ut.money_entry(
                        "",
                        v.savings,
                        rect,
                        "Savings of this character. "
                        .. "Characters spend them on buying food and other commodities."
                    )
                end,
                width = 3,
                value = function(k, v)
                    return v.savings
                end
            },
            {
                header = "satisfac.",
                render_closure = ut.render_pop_satsifaction,
                width = 2,
                value = function(k, v)
                    return v.basic_needs_satisfaction
                end
            },
            {
                header = "life needs",
                render_closure = function (rect, k, v)
                    ---@type POP
                    v = v

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
                value = function(k, v)
                    return v.life_needs_satisfaction
                end
            }
        }
        init_state(base_unit)
        local top = rect:subrect(0, 0, rect.width, base_unit, "left", "up")
        local bottom = rect:subrect(0, base_unit, rect.width, rect.height - base_unit, "left", "up")
        ui.centered_text("Population", top)
        ut.table(bottom, province.all_pops, columns, state)
    end
end