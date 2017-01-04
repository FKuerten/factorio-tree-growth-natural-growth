require "stdlib/string"
require "stdlib/log/logger"
local sqrt = math.sqrt
local round = function(x) return math.floor(x+0.5) end

local logger = Logger.new("tree-growth", "main", true)

local scaleBox = function(oldBox, linScale)
  local newBox = {}
  for k,v in ipairs(oldBox) do
    local n = {}
    for kk,vv in ipairs(v) do
      n[kk] = vv * linScale
    end
    newBox[k] = n
  end
  return newBox
end

local transformPicture = function(oldPic, scale)
  local linScale = sqrt(scale)
  local type = oldPic.type
  local newPic = table.deepcopy(oldPic)
  if not type then  
    newPic.width = round(oldPic.width * linScale)
    newPic.height = round(oldPic.height * linScale)
    if oldPic.shift then
      newPic.shift = { oldPic.shift[1] * linScale, oldPic.shift[2] * linScale}
    end
  elseif type == "create-particle" then
    newPic.offset_deviation = scaleBox(oldPic.offset_deviation, linScale)
    newPic.initial_height = oldPic.initial_height * linScale
    newPic.initial_height_deviation = oldPic.initial_height_deviation * linScale
    newPic.speed_from_center = oldPic.speed_from_center * linScale
  end
  return newPic
end

local transformPictures = function(oldPictures, scale)
  local pictures = {}
  for i, oldPic in pairs(oldPictures) do
    pictures[i] = transformPicture(oldPic, scale)
  end
  return pictures
end

local transformVariations = function(oldVariations, scale)
  local newVariations = {}
  for i, oldVariation in ipairs(oldVariations) do
    local newVariation = {}
    for k, oldPic in pairs(oldVariation) do
      newVariation[k] = transformPicture(oldPic, scale)
    end
    newVariations[i] = newVariation
  end
  return newVariations
end

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