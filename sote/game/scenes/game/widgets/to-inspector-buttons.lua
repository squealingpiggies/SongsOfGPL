local ui = require "engine.ui"
local ut = require "game.ui-utils"

local ib = {}

---@param game GameScene
---@param realm Realm
---@param rect Rect
function ib.icon_button_to_realm(game, realm, rect)
    if ut.coa(realm, rect) then
        game.selected.realm = realm
        game.inspector = "realm"
    end
end

---@param game GameScene
---@param realm Realm
---@param rect Rect
---@param tooltip string?
---@param potential boolean?
---@param active boolean?
function ib.text_button_to_realm(game, realm, rect, text, tooltip, potential, active)
    if ut.text_button(text, rect, tooltip, potential, active) then
        game.selected.realm = realm
        game.inspector = "realm"
    end
end

---@param game GameScene
---@param character Character
---@param rect Rect
function ib.icon_button_to_character(game, character, rect)
    require "game.scenes.game.widgets.portrait"(rect, character)
    if ui.invisible_button(rect) then
        game.selected.character = character
        game.inspector = "character"
    end
end

---@param game GameScene
---@param character Character
---@param rect Rect
---@param tooltip string?
---@param potential boolean?
---@param active boolean?
function ib.text_button_to_character(game, character, rect, text, tooltip, potential, active)
    if ut.text_button(text, rect, tooltip, potential, active) then
        game.selected.character = character
        game.inspector = "character"
    end
end

---@param game GameScene
---@param province Province
---@param rect Rect
---@param tooltip string?
---@param potential boolean?
---@param active boolean?
function ib.text_button_to_province(game, province, rect, text, tooltip, potential, active)
    if ut.text_button(text, rect, tooltip, potential, active) then
        game.selected.province = province
        game.selected.tile = province.center
        game.inspector = "tile"
    end
end

return ib
