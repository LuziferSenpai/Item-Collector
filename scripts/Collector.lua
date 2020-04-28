local item_collector = {}
local collector_metatable = { __index = item_collector }

function item_collector.new( entity )
    local position = entity.position
    local surface = entity.surface
    
    local collector_entity = surface.create_entity{ name = "item-collector", position = position, force = entity.force, player = entity.last_user }

    entity.destroy()

    local collector =
    {
        entity = collector_entity,
        index = tostring( collector_entity.unit_number ),
        range = 25,
        position = position,
        surface = surface,
        rendering = {},
        frame = {},
        button = {},
        circuits = 0
    }

    setmetatable( collector, collector_metatable )

    return collector
end

function item_collector:update()
    local items = self.surface.find_entities_filtered{ position = self.position, radius = self.range, name = "item-on-ground" }
    local inventory = self.entity.get_inventory( defines.inventory.chest )

    for _, item in pairs( items ) do
        local stack = item.stack

        if inventory.can_insert( stack ) then
            inventory.insert( stack )
            item.destroy()
        end
    end
end

function item_collector:update_range( number )
    local newrange = self.range + number

    if newrange >= 25 and newrange <= 50 then
        self.range = newrange
        self.circuits = self.circuits + ( number * 2 )

        for _, rendering1 in pairs( self.rendering ) do
            if rendering.is_valid( rendering1 ) then
                rendering.set_radius( rendering1, newrange )
            end
        end

        for _, button in pairs( self.button ) do
            if button.valid then
                button.number = self.circuits
            end
        end

        return true
    else
        return false
    end
end

function item_collector:render( player_id )
    local player_string = tostring( player_id )
    local rendering1 = self.rendering[player_string]

    if rendering1 and rendering.is_valid( rendering1 ) then
        rendering.destroy( rendering1 )

        self.rendering[player_string] = nil
    else
        local entity = self.entity

        self.rendering[player_string] = rendering.draw_circle
        {
            color = { r = 33, g = 107, b = 33, a = 0.5 },
            radius = self.range,
            filled = true,
            target = entity,
            surface = entity.surface,
            players = { player_id },
            draw_on_ground = true
        }
    end
end

function item_collector:gui_create( player_id )
    local player_string = tostring( player_id )
    local player = game.players[player_id]
    local gui = player.gui.screen
    local frame = gui.add{ type = "frame", name = "Collector_Frame", direction = "vertical" }
    frame.add{ type = "label", caption = { "Collector-Headline" } }.style.font = "heading-1"
    frame.add{ type = "line", direction = "horizontal" }
    frame.add{ type = "label", name = "Collector_Index", caption = self.index }.visible = false
    local flow = frame.add{ type = "flow", direction = "vertical" }
    local button = flow.add{ type = "sprite-button", name = "Collector_Button", sprite = "item/advanced-circuit", number = self.circuits, mouse_button_filter = { "left", "right" } }

    frame.location = { x = 5, y = ( player.display_resolution.height / 2 ) - 166 }

    flow.style.horizontally_stretchable = true
    flow.style.horizontal_align = "center"

    self.frame[player_string] = frame
    self.button[player_string] = button
end

function item_collector:gui_destroy( player_id )
    local player_string = tostring( player_id )
    self.frame[player_string].destroy()

    self.frame[player_string] = nil
    self.button[player_string] = nil
end

function item_collector:on_removed()
    if self.circuits > 0 then
        self.surface.spill_item_stack( self.position, { name = "advanced-circuit", count = self.circuits } )
    end
end

local lib = {}

lib.load = function( collector )
    setmetatable( collector, collector_metatable )
end

lib.new = item_collector.new

return lib