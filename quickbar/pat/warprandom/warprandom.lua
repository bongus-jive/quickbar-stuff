local unfoundPlanets, foundPlanets = {}, {}
local size = 64
local region
local searchRoutine

local function initTypes(list)
  for _, cfg in pairs(list) do
    local params = cfg.baseParameters
    if params and params.worldType == "Terrestrial" and params.terrestrialType then
      for _, t in ipairs(params.terrestrialType) do unfoundPlanets[t] = true end
    end
  end
end

function init()
  initTypes(root.assetJson("/celestial.config:planetaryTypes"))
  initTypes(root.assetJson("/celestial.config:satelliteTypes"))
  local rand = sb.makeRandomSource()
  region = { rand:randi32(), rand:randi32() }
  searchRoutine = coroutine.wrap(search)
end

function update()
  if searchRoutine then searchRoutine() end
end

local function validPlanet(coord)
  local params = celestial.visitableParameters(coord)
  if not params then return end

  local name = params.typeName
  if unfoundPlanets[name] then
    unfoundPlanets[name] = nil
    foundPlanets[name] = coord
    return true
  end
end

function search()
  while jsize(unfoundPlanets) > 0 do
    region[3], region[4] = region[1] + size, region[2] + size

    while not celestial.scanRegionFullyLoaded(region) do
      celestial.scanSystems(region)
      coroutine.yield()
    end

    local systems = celestial.scanSystems(region)
    for _, system in pairs(systems) do
      for _, planet in pairs(celestial.children(system)) do
        if not validPlanet(planet) then
          for _, moon in pairs(celestial.children(planet)) do validPlanet(moon) end
        end
      end
    end

    size = size * 2
    if size > 1024 then break end
  end

  sb.logInfo("Found planets: %s", sb.printJson(foundPlanets))
  sb.logInfo("Unfound planets: %s", sb.printJson(unfoundPlanets))

  searchRoutine = nil

  local destinations = {}
  for name, co in pairs(foundPlanets) do
    local warpAction = ("CelestialWorld:%s:%s:%s:%s:%s"):format(co.location[1], co.location[2], co.location[3], co.planet, co.satellite)

    table.insert(destinations, {
      name = celestial.planetName(co),
      icon = name,
      planetName = name,
      warpAction = warpAction
    })
  end

  player.interact("OpenTeleportDialog", {
    canBookmark = false,
    includePartyMembers = false,
    includePlayerBookmarks = false,
    destinations = destinations
  }, player.id())

  pane.dismiss()
end
