local MODNAME = "__Item_Collector_Updated__"

local collector_entity = util.table.deepcopy( data.raw["container"]["steel-chest"] )
collector_entity.name = "item-collector"
collector_entity.icon = MODNAME .. "/graphics/icons/smart-chest.png"
collector_entity.minable.result = "item-collector-area"
collector_entity.subgroup = "storage"
collector_entity.order = "a[items]-za[item-collector]"
collector_entity.picture = { filename = MODNAME .. "/graphics/smart-chest.png", priority = "extra-high", width = 62, height = 41, shift = { 0.4, -0.13 } }

local area_entity = util.table.deepcopy( data.raw["container"]["steel-chest"] )
area_entity.name = "item-collector-area"
area_entity.icon = MODNAME .. "/graphics/icons/smart-chest.png"
area_entity.minable.result = "item-collector-area"
area_entity.picture = { filename = MODNAME .. "/graphics/smart-chest-area.png", priority = "extra-high", width = 1600, height = 1600, shift = {0.4, -0.13} }

local area_item = util.table.deepcopy( data.raw["item"]["steel-chest"] )
area_item.name = "item-collector-area"
area_item.icon = MODNAME .. "/graphics/icons/smart-chest.png"
area_item.order = "a[items]-zb[item-collector]"
area_item.place_result = "item-collector-area"

local area_recipe = util.table.deepcopy( data.raw["recipe"]["steel-chest"] )
area_recipe.name = "item-collector-area"
area_recipe.enabled = true
area_recipe.ingredients = { { "steel-chest", 1 }, { "processing-unit", 20 }, { "solar-panel", 1 }, { "battery", 5 } }
area_recipe.result = "item-collector-area"

data:extend{ collector_entity, area_entity, area_item, area_recipe }