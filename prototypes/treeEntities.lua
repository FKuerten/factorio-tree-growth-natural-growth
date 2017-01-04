require "stdlib/string"
require "stdlib/log/logger"
require "util/entities"

local saplingAreaScale = 0.25

local sqrt = math.sqrt
local round = function(x) return math.floor(x+0.5) end

local logger = Logger.new("tree-growth", "main", true)

-- We need smaller particles for smaller trees
local function scaleParticle(oldParticle, suffix, areaScale)
  local newParticle = table.deepcopy(oldParticle)
  newParticle.name = oldParticle.name .. suffix
  newParticle.pictures = transformPictures(oldParticle.pictures, areaScale)
  newParticle.shadows = transformPictures(oldParticle.shadows, areaScale)
  return newParticle
end

data:extend({
  scaleParticle(data.raw["leaf-particle"]["leaf-particle"], "-sapling", saplingAreaScale),
  scaleParticle(data.raw["particle"]["branch-particle"], "-sapling", saplingAreaScale),
})

createSaplingEntityFromTree = function(oldTree)
  local scale = saplingAreaScale
  logger.log("transforming tree " .. oldTree.name)
  local newName = oldTree.name .. "-sapling"
  local newTree = table.deepcopy(oldTree)
  newTree.name = newName
  newTree.subgroup = "tree-growth-saplings" -- todo why is this an item subgroup?
  newTree.autoplace = nil
  newTree.flags = {"placeable-neutral", "breaths-air"}
  newTree.minable = {
    count = 1,
    mining_particle = "wooden-particle",
    mining_time = 0.1,
    result = newName,
  }
  newTree.corpse = nil
  newTree.remains_when_mined = nil
  newTree.emissions_per_tick = oldTree.emissions_per_tick * scale
  newTree.max_health = round(oldTree.max_health * scale)
  newTree.collision_box = scaleBox(oldTree.collision_box, sqrt(scale))
  newTree.selection_box = scaleBox(oldTree.selection_box, sqrt(scale))
  if oldTree.drawing_box then
    newTree.drawing_box = scaleBox(oldTree.drawing_box, sqrt(scale))
  end
  if oldTree.pictures then
    newTree.pictures = transformPictures(oldTree.pictures, scale)
  end
  if oldTree.variations then
    newTree.variations = transformVariations(oldTree.variations, "-sapling", scale)
  end
  data:extend({newTree})
  return newTree
end
