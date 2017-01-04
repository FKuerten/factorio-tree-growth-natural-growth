require "prototypes/treeItems"
require "prototypes/treeEntities"

local oldTrees = data.raw.tree
for _, oldTree in pairs(oldTrees) do
  local skip = false

  if oldTree.subgroup ~= "trees" then
    skip = true
  end

  if not skip then
    local newTree = createSaplingFromTree(oldTree)
    data:extend({newTree})
  end
end