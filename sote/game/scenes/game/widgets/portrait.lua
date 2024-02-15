local tabb = require "sote.engine.table-utility"
local ui = require "engine.ui"
local ut = require "game.ui-utils"
local ranks = require "game.raws.ranks.character_ranks"

---@param rect Rect
---@param character Character
return function(rect, character)
    local style = ui.style.panel_outline
    if character.rank == ranks.NOBLE then
        -- silver color rgba
        ui.style.panel_outline = {r = 165 / 255, g = 169 / 255, b = 180 / 255, a = 1}
    elseif character.rank == ranks.CHIEF then
        -- gold color rgba
        ui.style.panel_outline = {r = 255 / 255, g = 215 / 255, b = 0 / 255, a = 1}
    end

    love.graphics.setLineWidth( 4 )
    ui.panel(rect)
    love.graphics.setLineWidth( 1 )

    ui.style.panel_outline = style

    ui.image(ASSETS.get_icon(character.race.icon), rect)
end