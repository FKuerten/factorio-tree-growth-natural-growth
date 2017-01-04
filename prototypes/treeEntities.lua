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

function createParticles (suffix, areaScale)
  data:extend({
    scaleParticle(data.raw["leaf-particle"]["leaf-particle"], suffix, areaScale),
    scaleParticle(data.raw["particle"]["branch-particle"], suffix, areaScale),
  })
end

-- @param options a tree entity option table
createEntityFromTree = function(options, oldTree)
  logger.log("transforming tree " .. oldTree.name)
  local suffix = options.suffix or ("-" .. options.id)
  local areaScale = options.areaScale
  local newName = oldTree.name .. suffix
  local newTree = table.deepcopy(oldTree)
  newTree.name = newName
  if options.first then
    newTree.subgroup = "tree-growth-saplings" -- todo why is this an item subgroup?
  else
    newTree.subgroup = "trees"
  end

  newTree.autoplace = nil
  newTree.flags = {"placeable-neutral", "breaths-air"}
  if options.first then
    newTree.minable = {
      count = 1,
      mining_particle = "wooden-particle",
      mining_time = 0.1,
      result = newName,
    }
    newTree.corpse = nil
    newTree.remains_when_mined = nil
  else
    newTree.minable.count = round(oldTree.minable.count * areaScale)
  end
  newTree.emissions_per_tick = oldTree.emissions_per_tick * areaScale
  newTree.max_health = round(oldTree.max_health * areaScale)
  newTree.collision_box = scaleBox(oldTree.collision_box, sqrt(areaScale))
  newTree.selection_box = scaleBox(oldTree.selection_box, sqrt(areaScale))
  if oldTree.drawing_box then
    newTree.drawing_box = scaleBox(oldTree.drawing_box, sqrt(areaScale))
  end
  if oldTree.pictures then
    newTree.pictures = transformPictures(oldTree.pictures, areaScale)
  end
  if oldTree.variations then
    newTree.variations = transformVariations(oldTree.variations, options.particleSuffix or "", areaScale)
  end

  data:extend({newTree})
  return newTree
end

function createTreeEntityHierarchyForTree(configuration, oldTree)
  for _, optionsTable in pairs(configuration) do
    createEntityFromTree(optionsTable, oldTree)
  end
end
