

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
-- * next, a set of ids
configuration.treeEntities = {
  {
    id = "sapling",
    suffix = "-sapling",
    particleSuffix = "-sapling",
    areaScale = 0.1,
    first = true,
    nextSuffixes = {""},
  },
}

