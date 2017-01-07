require "tree-growth-lib/constants"

--- Sets subgroup and next levels.
-- This function does the most important thing for tree_growth:
-- It sets the subgroup (for quick filtering) and registers the next stages in the tree's life.
-- @param a table contaning an optional truthy "first" (for saplings) and an optional upgrades table "next".
--        The upgrades table is a list of upgrade tables, each upgrade table should have "probability", "minDelay", "maxDelay" and "suffix".
-- @param baseName the base name of this tree
-- @param tree the tree to modify
tree_growth.defineTreeUpgrades = function(options, baseName, tree)
  local isFirst = options.first
  local isLast = not (options.next and options.next[1])

  -- assign group
  if isFirst then
    tree.subgroup = tree_growth.groups.sapling -- todo why is this an item subgroup?
  elseif not isLast then
    tree.subgroup = tree_growth.groups.intermediate
  else
    tree.subgroup = tree_growth.groups.mature
  end
  if not isLast then
    local nextTrees = {}
    for i, data in ipairs(options.next) do
      assert((data.minDelay and data.maxDelay) or data.delay, "need to specify at minDelay and maxDelay or delay")
      nextTrees[i] = {
        name = baseName .. data.suffix,
        minDelay = data.minDelay or data.delay,
        maxDelay = data.maxDelay or data.delay,
        probability = data.probability,
      }
    end
    tree.order = serpent.dump(nextTrees)
  else
    tree.order = nil
  end
end
