local sqrt = math.sqrt
local round = function(x) return math.floor(x+0.5) end

scaleBox = function(oldBox, linScale)
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

transformPicture = function(oldPic, scale)
  local linScale = sqrt(scale)
  local type = oldPic.type
  local newPic = table.deepcopy(oldPic)
  if not type then
    if oldPic.shift then
      newPic.shift = { oldPic.shift[1] * linScale, oldPic.shift[2] * linScale}
    end
    newPic.scale = linScale
  elseif type == "create-particle" then
    newPic.offset_deviation = scaleBox(oldPic.offset_deviation, linScale)
    newPic.initial_height = oldPic.initial_height * linScale
    newPic.initial_height_deviation = oldPic.initial_height_deviation * linScale
    newPic.speed_from_center = oldPic.speed_from_center * linScale
    newPic.scale = linScale
  end
  return newPic
end

transformPictures = function(oldPictures, scale)
  local pictures = {}
  for i, oldPic in ipairs(oldPictures) do
    pictures[i] = transformPicture(oldPic, scale)
  end
  return pictures
end

transformVariations = function(oldVariations, scale)
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
