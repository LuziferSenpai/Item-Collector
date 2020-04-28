local definesevent = defines.events
local definesentity = defines.gui_type.entity
local definesleftmouse = defines.mouse_button_type.left	
local definesrightmouse = defines.mouse_button_type.right

local collector_names =
{
    ["item-collector-area"] = require( "scripts/Collector" )
}
local script_data =
{
    collectors = {},
    next_index = nil
}

local on_created_entity = function( event )
    local entity = event.entity or event.created_entity

    if not ( entity and entity.valid ) then return end

    local collector_lib = collector_names[entity.name]

    if not collector_lib then return end

    local collector = collector_lib.new( entity )

    script_data.collectors[collector.index] = collector
end

local on_entity_removed = function( event )
    local entity = event.entity

    if not ( entity and entity.valid ) then return end
    local index = tostring( entity.unit_number )
    local collector = script_data.collectors[index]

    if collector then
        script_data.collectors[index] = nil

        collector:on_removed()
    end
end

local on_selected_entity_changed = function( event )
    local player_id = event.player_index
    local player = game.players[player_id]
    local entity = player.selected
    local last_entity = event.last_entity
    local collectors = script_data.collectors
    local collector

    if last_entity and last_entity.valid and last_entity.name == "item-collector" then
        collector = collectors[tostring( last_entity.unit_number )]

        if collector then
            collector:render( player_id )
        end
    end

    collector = nil

    if entity and entity.valid and entity.name == "item-collector" then
        collector = collectors[tostring( entity.unit_number )]

        if collector then
            collector:render( player_id )
        end
    end
end

local on_gui_click = function( event )
    local element = event.element
    
    if element and element.valid and element.name == "Collector_Button" then
        local player = game.players[event.player_index]
        local itemstack = player.cursor_stack
        
        if itemstack and itemstack.valid_for_read and itemstack.valid and itemstack.name == "advanced-circuit" then
            local button = event.button
            local collector = script_data.collectors[element.parent.parent.Collector_Index.caption]
            if collector then
                if button == definesleftmouse then
                    local boolean = collector:update_range( 0.5 )
                    
                    if boolean then
                        itemstack.count = itemstack.count - 1
                    else
                        player.print( { "Collector-Error" } )
                    end
                elseif button == definesrightmouse then
                    local boolean = collector:update_range( -0.5 )
                    
                    if boolean then
                        local count = player.insert{ name = "advanced-circuit", count = 1 }
                        
                        if count == 0 then
                            player.surface.spill_item_stack( player.position, { name = "advanced-circuit", count = 1 } )
                        end
                    else
                        player.print( { "Collector-Error" } )
                    end
                end
            end
        end
    end
end

local on_gui_opened = function( event )
    if event.gui_type == definesentity then
        local entity = event.entity

        if entity and entity.valid and entity.name == "item-collector" then
            local collector = script_data.collectors[tostring( entity.unit_number )]

            if collector then
                collector:gui_create( event.player_index )
            end
        end
    end
end

local on_gui_closed = function( event )
    if event.gui_type == definesentity then
        local entity = event.entity

        if entity and entity.valid and entity.name == "item-collector" then
            local collector = script_data.collectors[tostring( entity.unit_number )]

            if collector then
                collector:gui_destroy( event.player_index )
            end
        end
    end
end

local on_tick = function()
    local index, collector = next( script_data.collectors, script_data.next_index )

    if index then
        script_data.next_index = index
        
        collector:update()
    else
        script_data.next_index = nil
    end
end

local lib = {}

lib.events = 
{
    [definesevent.on_built_entity] = on_created_entity,
    [definesevent.on_robot_built_entity] = on_created_entity,
    [definesevent.script_raised_built] = on_created_entity,
    [definesevent.script_raised_revive] = on_created_entity,
    [definesevent.on_entity_died] = on_entity_removed,
    [definesevent.on_robot_mined_entity] = on_entity_removed,
    [definesevent.script_raised_destroy] = on_entity_removed,
    [definesevent.on_player_mined_entity] = on_entity_removed,
    [definesevent.on_selected_entity_changed] = on_selected_entity_changed,
    [definesevent.on_gui_click] = on_gui_click,
    [definesevent.on_gui_opened] = on_gui_opened,
    [definesevent.on_gui_closed] = on_gui_closed,
    [definesevent.on_tick] = on_tick
}

lib.on_init = function()
    global.script_data = global.script_data or script_data
end

lib.on_load = function()
    script_data = global.script_data or script_data

    for _, collector in pairs( script_data.collectors ) do
        local lib = collector_names[collector.entity.name]

        if lib.load then lib.load( collector ) end
    end
end

lib.on_configuration_changed = function()
    global.script_data = global.script_data or script_data

    global.itemCollectors = nil

    for _, force in pairs( game.forces ) do
        force.reset_technology_effects()
    end
end

return lib