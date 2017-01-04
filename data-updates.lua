require "prototypes/treeItems"
require "prototypes/treeEntities"
require "config"

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

-- Create particles for small trees
for _, optionsTable in pairs(configuration.particles) do
  local suffix = optionsTable.suffix or ("-" .. optionsTable.id)
  createParticles(optionsTable.suffix, optionsTable.areaScale)
end

-- Loop over all existing trees
local oldTrees = data.raw.tree
for _, oldTree in pairs(oldTrees) do
  local skip = false

  if oldTree.subgroup ~= "trees" then
    skip = true
  end

  if not skip then
    createTreeEntityHierarchyForTree(configuration.treeEntities, oldTree)
    local saplingItem = createSaplingItemFromTree(oldTree)
    createRecipeForSapling(saplingItem)
  end
end
