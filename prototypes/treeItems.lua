--require "stdlib/string"
--require "stdlib/log/logger"

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
    name = "tree-growth-saplings",
    group = "tree-growth",
    order = "b",
  },
})

function createSaplingItemFromTree(tree)
  local name = tree.name .. "-sapling"
  data:extend({
    {
      type = "item",
      name = name,
      icon = tree.icon,
      flags = {"goes-to-main-inventory"},
      subgroup = "tree-growth-saplings",
      order = tree.order,
      place_result = name,
      fuel_value = "1MJ", -- todo
      stack_size = 50,
    },
  })
end
