configuration = {}
configuration.particles = {
  {
    id = "sapling",
    suffix = "-sapling",
    areaScale = 0.1,
  }
}
-- tree entity option table:
-- * id
-- * suffix
-- * particlesSuffix
-- * areaScale
-- * first, boolean
-- * next, a list of upgrades
-- ** suffix, in the prototype there will be name instead
-- ** probability that this upgrade is chosen
-- ** minDelay in ticks
-- ** maxDelay in ticks
configuration.treeEntities = {
  {
    id = "sapling",
    suffix = "-sapling",
    particleSuffix = "-sapling",
    areaScale = 0.1,
    first = true,
    next = {
      {
        suffix = "",
        probability = 1,
        minDelay = 60,
        maxDelay = 120
      },
    },
  },
}
