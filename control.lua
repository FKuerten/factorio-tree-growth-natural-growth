require "stdlib/string"
require "config"
local round = function(x) return math.floor(x+0.5) end

local initialize = function()
  if not global.growingTrees then
    global.growingTrees = {}
  end
end

local treeSorter = function(a,b)
  return a.tickUpgrade < b.tickUpgrade
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

local getNextTreeData
do
  local nextTreeData = {}
  getNextTreeData = function(name)
    if nextTreeData[name] then 
      return nextTreeData[name]
    end
    for _, optionTable in ipairs(configuration.treeEntities) do
      local suffix = optionTable.suffix or ("-" .. optionTable.id)
      if string.ends_with(name, suffix) then
        local prefix = string.sub(name, 0, -(string.len(suffix)+1))
        local nextData = {}
        for i, data in ipairs(optionTable.next) do
          nextData[i] = {
            name = prefix .. data.suffix,
            minDelay = data.minDelay,
            maxDelay = data.maxDelay,
            probability = data.probability,
          }
        end
        nextTreeData[name] = nextData
        return nextData
      end
    end
  end
end

local onTreePlaced = function(entity)
  
  -- The decision of the next upgrade is done early
  local prototype = entity.prototype
  local nextTrees = getNextTreeData(prototype.name)
  if not nextTrees then
    return -- final tree
  end
  local nextTree = pickRandomTree(nextTrees)
  
  -- Decide when to upgrade
  local delay = nextTree.minDelay + round(math.random() * (nextTree.maxDelay - nextTree.minDelay))
  
  local data = {
    entity = entity,
    nextName = nextTree.name,
    tickUpgrade = game.tick + delay,
  }
  
  entity.surface.print("tree placed: " .. prototype.name .. " will upgrade to: " .. nextTree.name)
  
  table.insert(global.growingTrees, data)
  table.sort(global.growingTrees, treeSorter)
  global.nextGrowth = global.growingTrees[1].tickUpgrade
end

local onEntityPlaced = function(event)
  local entity = event.created_entity
  local subgroup = entity.prototype.subgroup.name
  --entity.surface.print("subgroup: " .. entity.prototype.subgroup.name)
  if subgroup == tree_growth.groups.sapling or
     subgroup == tree_growth.groups.intermediate then
    onTreePlaced(entity)
  end
end

local growTree = function(entry)  
  local entity = entry.entity
  local nextName = entry.nextName  
  local surface = entity.surface
  local position = entity.position
  surface.print("tree grown: " .. entity.prototype.name .. " to " .. nextName)
  entity.destroy()
  local newEntity = surface.create_entity({
    name = nextName, 
    amount = 1,
    position = position,
    -- force?
  })
  -- it appears that create_entity does not trigger events
  onTreePlaced(newEntity)
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
script.on_event(defines.events.on_built_entity, onEntityPlaced)
script.on_event(defines.events.on_robot_built_entity, onEntityPlaced)
script.on_event(defines.events.on_tick, onTick)