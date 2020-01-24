local radius = 25
local de = defines.events

local function ONBUILD( event )
    local e = event.created_entity
    if e.name == "item-collector-area" then
        local s = e.surface
        local f = e.force
        n = s.create_entity{ name = "item-collector", position = e.position, force = f }
        e.destroy()
        table.insert( global.itemCollectors, n )
    end
end

script.on_init( function()
    global.itemCollectors = global.itemCollectors or {}
end )

script.on_event( de.on_tick, function( event )
    if #global.itemCollectors > 0 and event.tick % ( game.speed * 60 ) == 0 then
        local it
        local i
        for k, c in pairs( global.itemCollectors ) do
            if c.valid then
                local posi = c.position
                it = c.surface.find_entities_filtered{ area = { { posi.x - radius, posi.y - radius }, { posi.x + radius, posi.y + radius } }, name = "item-on-ground" }
                if #it > 0 then
                    i = c.get_inventory( defines.inventory.chest )
                    for _, item in pairs( it ) do
                        local stack = item.stack
                        if i.can_insert( stack ) then
                            i.insert( stack )
                            item.destroy()
                        end
                    end
                end
            else
                global.itemCollectors[k] = global.itemCollectors[#global.itemCollectors]
                global.itemCollectors[#global.itemCollectors] = nil
            end
        end
    end
end )

script.on_event( { de.on_built_entity,de.on_robot_built_entity }, ONBUILD )