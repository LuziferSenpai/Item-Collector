local MODNAME = "__Item_Collector_Updated__"

local collector_entity = util.table.deepcopy( data.raw["container"]["steel-chest"] )
collector_entity.name = "item-collector"
collector_entity.icon = MODNAME .. "/graphics/smart-chest-i.png"
collector_entity.icon_size = 32
collector_entity.icon_mipmap = nil
collector_entity.minable.result = "item-collector-area"
collector_entity.subgroup = "storage"
collector_entity.order = "a[items]-za[item-collector]"
collector_entity.inventory_size = 50
collector_entity.picture = { filename = MODNAME .. "/graphics/smart-chest.png", priority = "extra-high", width = 62, height = 41, shift = { 0.4, -0.13 } }
collector_entity.placeable_by = { item = "item-collector-area", count = 1 }

local area_entity = util.table.deepcopy( data.raw["container"]["steel-chest"] )
area_entity.name = "item-collector-area"
area_entity.icon = MODNAME .. "/graphics/smart-chest-i.png"
area_entity.icon_size = 32
area_entity.icon_mipmap = nil
area_entity.minable.result = "item-collector-area"
area_entity.picture = { layers = { { filename = MODNAME .. "/graphics/circle.png", priority = "extra-high", width = 1600, height = 1600 }, { filename = MODNAME .. "/graphics/smart-chest.png", priority = "extra-high", width = 62, height = 41, shift = { 0.4, -0.13 } } } }

local area_item = util.table.deepcopy( data.raw["item"]["steel-chest"] )
area_item.name = "item-collector-area"
area_item.icon = MODNAME .. "/graphics/smart-chest-i.png"
area_item.icon_size = 32
area_item.icon_mipmap = nil
area_item.order = "a[items]-zb[item-collector]"
area_item.place_result = "item-collector-area"

local area_recipe = util.table.deepcopy( data.raw["recipe"]["steel-chest"] )
area_recipe.name = "item-collector-area"
area_recipe.enabled = true
area_recipe.ingredients = { { "steel-chest", 1 }, { "processing-unit", 20 }, { "solar-panel", 1 }, { "battery", 5 } }
area_recipe.result = "item-collector-area"

data:extend{ collector_entity, area_entity, area_item, area_recipe }