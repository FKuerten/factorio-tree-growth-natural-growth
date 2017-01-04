require "prototypes/treeItems"
require "prototypes/treeEntities"

local createRecipeForSapling = function(saplingItem)
  local recipe = {
    type = "recipe",
    name = saplingItem.name,
    ingredients = {{"raw-wood",1}},
    result = saplingItem.name,
    result_count = 1
  }
  data:extend({recipe})
  return recipe
end

local oldTrees = data.raw.tree
for _, oldTree in pairs(oldTrees) do
  local skip = false

  if oldTree.subgroup ~= "trees" then
    skip = true
  end

  if not skip then
    createSaplingEntityFromTree(oldTree)
    local saplingItem = createSaplingItemFromTree(oldTree)
    createRecipeForSapling(saplingItem)
  end
end