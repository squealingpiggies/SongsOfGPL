local effects = {}

---comment
---@param character Character
function effects.death(character)
    -- print('character', character.name, 'died')

    if WORLD:does_player_see_realm_news(character.realm) then
        WORLD:emit_notification(character.name .. " had died.")
    end

    if character.unit_of_warband then
        if character == character.unit_of_warband.commander then
            character.unit_of_warband:unset_commander()
        else
            character.unit_of_warband:unset_character_as_unit(character)
        end
    end

    if character.mother then character.mother.children[character] = nil end
    if character.father then character.father.children[character] = nil end
    for _,c in pairs(character.children) do
        if c.mother == character then c.mother = nil end
        if c.father == character then c.father = nil end
        character.children[c] = nil
    end

    for _, target in pairs(character.successor_of) do
        target.successor = nil
        character.successor_of[target] = nil
    end

    character.dead = true
end


return effects