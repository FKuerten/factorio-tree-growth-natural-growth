local round = function(x) return math.floor(x+0.5) end

local initialize = function()
  if not global.growingTrees then
    global.growingTrees = {}
  end
  if not global.groups then
    global.groups = remote.call("tree-growth-core", "getGroups")
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
  getNextTreeData = function(prototype)
    local name = prototype.name
    if prototype.subgroup.name == tree_growth.groups.sapling or
       prototype.subgroup.name == tree_growth.groups.intermediate then
      -- ok
    elseif prototype.subgroup.name == tree_growth.groups.mature then
      -- mature has no next
      return
    else
      -- maybe a mature tree, maybe something else, nothing we can grow
      return
    end

    -- cached?
    if nextTreeData[name] then 
      return nextTreeData[name]
    end
    -- not cached

    local nextData = loadstring(prototype.order)()
    nextTreeData[name] = nextData
    return nextData
  end
end

local onTreePlaced = function(entity)
  -- The decision of the next upgrade is done early
  local prototype = entity.prototype
  local nextTrees = getNextTreeData(prototype)
  if not nextTrees then
    return -- final tree or something else
  end
  local nextTree = pickRandomTree(nextTrees)

  -- Decide when to upgrade
  local delay = nextTree.minDelay + round(math.random() * (nextTree.maxDelay - nextTree.minDelay))

  local data = {
    entity = entity,
    nextName = nextTree.name,
    tickUpgrade = game.tick + delay,
  }

  table.insert(global.growingTrees, data)
  table.sort(global.growingTrees, treeSorter)
  global.nextGrowth = global.growingTrees[1].tickUpgrade
end

local onEntityPlaced = function(event)
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