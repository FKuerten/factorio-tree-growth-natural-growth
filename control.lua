local round = function(x) return math.floor(x+0.5) end

local onEntityPlaced -- forward
local initialize = function()
  if not global.growingTrees then
    global.growingTrees = {}
  end
  if not global.groups then
    global.groups = remote.call("tree-growth-core", "getGroups")
  end
  global.treePlantedEvent = remote.call("tree-growth-core", "getEvents")['on_tree_planted']
  script.on_event(global.treePlantedEvent, onEntityPlaced)
end

local onConfigurationChanged = function()
  global.groups = nil
  global.treeData = nil
  if global.treePlantedEvent then
    script.on_event(global.treePlantedEvent, nil)
    global.treePlantedEvent = nil
  end
  initialize()
end

local treeSorter = function(a,b)
  return a.tickUpgrade < b.tickUpgrade
end

local filterTrees = function(nextTrees, tile, variation)
  local result = {}
  for _, entry in ipairs(nextTrees) do
    local validTile = false
    if type(entry.tiles) == 'nil' or entry.tiles == true then
      validTile = true
    elseif type(entry.tiles) == 'table' then
      validTile = entry.tiles[tile]
    end
    
    local validVariation = false
    --game.surfaces["nauvis"].print(tostring(entry.variations))
    if entry.variations == 'id' or entry.variations == 'random' then
      validVariation = true
    elseif type(entry.variations) == 'table' then
      if entry.variation[variation] then
        validVariation = true
      end
    end
    --game.surfaces["nauvis"].print("validTile=" .. tostring(validTile) .. " validVariation=" .. tostring(validVariation))
    
    if validTile and validVariation then
      table.insert(result, entry)
    end
  end
  return result
end

local pickRandomTree = function(nextTrees)
  local sum = 0
  local lastEntry
  for _, entry in ipairs(nextTrees) do
    sum = sum + entry.probability
    lastEntry = entry
  end
  local r = math.random() * sum
  local offset = 0
  for _, entry in ipairs(nextTrees) do
    offset = offset + entry.probability
    if r < offset then
      return entry
    end
  end
  -- should not happen.
  return lastEntry
end

local pickVariation = function(entry, oldVariation)
  if entry.variations == 'id' then
    return oldVariation
  elseif entry.variations == 'random' then
    return 'random'
  else 
    return entry.variations[oldVariation]
  end
end

local getTreeData = function(name)
  return remote.call("tree-growth-core", "getTreeData", name)
end

local getNextData = function (prototype)
  local name = prototype.name
  if prototype.subgroup.name == global.groups.sapling or
     prototype.subgroup.name == global.groups.intermediate then
    -- ok
  elseif prototype.subgroup.name == global.groups.mature then
    -- mature has no next
    return
  else
    -- maybe a mature tree, maybe something else, nothing we can grow
    return
  end
  global.nextData = global.nextData or {}
  if not global.nextData[name] then
    global.nextData[name] = getTreeData(name).upgrades
  end
  return global.nextData[name]
end

local onTreePlaced = function(entity)
  -- The decision of the next upgrade is done early
  local prototype = entity.prototype
  local nextTrees = getNextData(prototype)
  if not nextTrees then
    return -- final tree or something else
  end
  local position = entity.position
  local surface = entity.surface
  local tile = surface.get_tile(position)
  local nextTrees = filterTrees(nextTrees, tile.name, entity.graphics_variation)
  assert(nextTrees)
  if #nextTrees == 0 then 
    return 
  end
  local nextTree = pickRandomTree(nextTrees)
  assert(nextTree)
  local newVariation = pickVariation(nextTree, entity.graphics_variation)

  -- Decide when to upgrade
  local delay = nextTree.minDelay + round(math.random() * (nextTree.maxDelay - nextTree.minDelay))
  delay = delay * settings.global['tgng-time-scale'].value

  local data = {
    entity = entity,
    nextName = nextTree.name,
    variation = newVariation,
    tickUpgrade = game.tick + delay,
  }

  table.insert(global.growingTrees, data)
  table.sort(global.growingTrees, treeSorter)
  global.nextGrowth = global.growingTrees[1].tickUpgrade
end

onEntityPlaced = function(event)
  local entity = event.created_entity
  local subgroup = entity.prototype.subgroup.name
  --entity.surface.print("subgroup: " .. entity.prototype.subgroup.name)
  if subgroup == global.groups.sapling or
     subgroup == global.groups.intermediate then
    onTreePlaced(entity)
  end
end

local growTree = function(entry)  
  local entity = entry.entity
  local nextName = entry.nextName  
  local surface = entity.surface
  local position = entity.position
  local newVariation = entry.variation
  
  -- TODO add support for keeping color 
  --local oldColor = 
  
  -- TODO add support for keeping deconstruction, but currently api does not yet support this
  --local wasMarkedForDeconstruction = entity.to_be_deconstructed
  --surface.print("tree grown: " .. entity.prototype.name .. " to " .. nextName)
  entity.destroy()
  local newEntity = surface.create_entity({
    name = nextName, 
    amount = 1,
    position = position,
    -- force?
  })
  if newEntity then
    --surface.print("newVariation="..tostring(newVariation))
    if type(newVariation) == 'number' then
      newEntity.graphics_variation = newVariation
    end
    -- it appears that create_entity does not trigger events
    script.raise_event(global.treePlantedEvent, {created_entity = newEntity})
  end
end

local onTick = function(event)
  if global.nextGrowth and (game.tick >= global.nextGrowth) then
    local entry = global.growingTrees[1]
    table.remove(global.growingTrees, 1)
    if global.growingTrees[1] then
      global.nextGrowth = global.growingTrees[1].tickUpgrade
    else
      global.nextGrowth = nil
    end
    if entry.entity.valid then
      growTree(entry)
    end
  end
end

script.on_init(initialize)
script.on_load(initialize)
script.on_configuration_changed(onConfigurationChanged)
script.on_event(defines.events.on_built_entity, onEntityPlaced)
script.on_event(defines.events.on_robot_built_entity, onEntityPlaced)
script.on_event(defines.events.on_tick, onTick)
