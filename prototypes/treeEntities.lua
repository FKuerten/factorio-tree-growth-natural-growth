require "stdlib/string"
require "stdlib/log/logger"
require "util/entities"

local sqrt = math.sqrt
local round = function(x) return math.floor(x+0.5) end

local logger = Logger.new("tree-growth", "main", true)

createSaplingEntityFromTree = function(oldTree)
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
  data:extend({newTree})
end
