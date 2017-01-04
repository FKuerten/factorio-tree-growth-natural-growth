require "stdlib/string"
require "stdlib/log/logger"
require "util/entities"

local sqrt = math.sqrt
local round = function(x) return math.floor(x+0.5) end

local logger = Logger.new("tree-growth", "main", true)

local transformTree = function(oldTree)
  logger.log("transforming tree " .. oldTree.name)
  local newName = oldTree.name .. "-sapling"
  local newTree = table.deepcopy(oldTree)
  newTree.name = newName
  newTree.subgroup = "tree-growth-saplings" -- todo why is this an item subgroup?
  newTree.autoplace = nil
  newTree.minable = {
    count = 1,
    mining_particle = "wooden-particle",
    mining_time = 0.1,
    result = newName,
  }
  newTree.emissions_per_tick = oldTree.emissions_per_tick / 10
  newTree.max_health = round(oldTree.max_health * 0.1)
  newTree.collision_box = scaleBox(oldTree.collision_box, sqrt(0.1))
  newTree.selection_box = scaleBox(oldTree.selection_box, sqrt(0.1))
  if oldTree.drawing_box then
    newTree.drawing_box = scaleBox(oldTree.drawing_box, sqrt(0.1))
  end
  if oldTree.pictures then
    newTree.pictures = transformPictures(oldTree.pictures, 0.1)
  end
  if oldTree.variations then
    newTree.variations = transformVariations(oldTree.variations, 0.1)
  end
  return newTree
end

local oldTrees = data.raw.tree
local newTrees = {}
for _, oldTree in pairs(oldTrees) do
  local skip = false
  
  if oldTree.subgroup ~= "trees" then
    skip = true
  end
    
  -- Abort if the tree is strange
  if (not oldTree.pictures) and (not oldTree.variations) then
    --skip = true
  end
  
  --if not oldTree.emissions_per_tick then
  --  skip = true
  --  logger.log("skipping " .. oldTree.name .. " because it has no emissions")
  --end
  
  if not skip then   
    table.insert(newTrees, transformTree(oldTree))
  end
end

for _, newTree in pairs(newTrees) do
  data:extend({newTree})
end