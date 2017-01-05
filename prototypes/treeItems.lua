require "config"

data:extend({
  {
    type = "item-group",
    name = "tree-growth",
    order = "e",
    inventory_order = "e",
    icon = "__base__/graphics/icons/tree-05.png",
  },
  {
    type = "item-subgroup",
    name = tree_growth.groups.sapling,
    group = "tree-growth",
    order = "a",
  },
  {
    type = "item-subgroup",
    name = tree_growth.groups.intermediate,
    group = "tree-growth",
    order = "b",
  },
  {
    type = "item-subgroup",
    name = tree_growth.groups.mature,
    group = "tree-growth",
    order = "c",
  },
})

function createSaplingItemFromTree(tree)
  local name = tree.name .. "-sapling"
  local saplingItem = {
    type = "item",
    name = name,
    icon = tree.icon,
    flags = {"goes-to-main-inventory"},
    subgroup = "tree-growth-saplings",
    order = tree.order,
    place_result = name,
    fuel_value = "1MJ", -- todo
    stack_size = 50,
  }
  data:extend({saplingItem})
  return saplingItem
end
