local radius = 25


local function ONLOAD()
    global.itemCollectors = global.itemCollectors or {}
end

local function ONBUILD( event )
    local entity = event.created_entity
    if entity.name == "item-collector-area" then
        local surface = entity.surface
        local force = entity.force
        newCollector = surface.create_entity{ name = "item-collector", position = entity.position, force = force }
        entity.destroy()
        table.insert( global.itemCollectors, newCollector )
    end
end

local function ONREMOVE( event )
    local entity = event.entity
    if entity.name == "item-collector" then
        for index, l in pairs( global.itemCollectors ) do
            if entity == l then
                global.itemCollectors[index] = nil
                break
            end
        end
    end
end

script.on_init( ONLOAD )

script.on_event( defines.events.on_tick, function( event )
    if #global.itemCollectors > 0 and event.tick % ( game.speed * 60 ) == 0 then
        local items
        local inventory
        for k, collector in pairs( global.itemCollectors ) do
            if collector.valid then
                local posi = collector.position
                items = collector.surface.find_entities_filtered{ area = { { posi.x - radius, posi.y - radius }, { posi.x + radius, posi.y + radius } }, name = "item-on-ground" }
                if #items > 0 then
                    inventory = collector.get_inventory( defines.inventory.chest )
                    for _, item in pairs( items ) do
                        local stack = item.stack
                        if inventory.can_insert( stack ) then
                            inventory.insert( stack )
                            item.destroy()
                        end
                    end
                end
            else
                table.remove( global.itemCollectors, k )
            end
        end
    end
end )

script.on_event( defines.events.on_built_entity, ONBUILD )
script.on_event( defines.events.on_robot_built_entity, ONBUILD )
script.on_event( defines.events.on_pre_player_mined_item, ONREMOVE )
script.on_event( defines.events.on_robot_pre_mined, ONREMOVE )
script.on_event( defines.events.on_entity_died, ONREMOVE )