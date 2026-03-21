local icons = root.assetJson("/quickbar/pat/instanceworlds/instanceworlds.config:icons")
local worlds = root.assetJson("/instance_worlds.config")

local worldNames = {}
for k, _ in pairs(worlds) do table.insert(worldNames, k) end
table.sort(worldNames)

for i, icon in ipairs(icons) do
  icon.destinations = {}
  icon.priority = icon.priority or 0
  icon.sort = i
end
table.sort(icons, function(a, b) return (a.priority >= b.priority) and (a.sort < b.sort) end)

local iconNames, iconPatterns = {}, {}
for i = #icons, 1, -1 do
  local icon = icons[i]
  for _, name in ipairs(icon.names or {}) do iconNames[name] = icon end
  for _, pattern in ipairs(icon.patterns or {}) do iconPatterns[pattern] = icon end
end

local iconDefault = { icon = "default", destinations = {} }
table.insert(icons, iconDefault)

local function findIcon(worldName)
  local named = iconNames[worldName]
  if named then return named end

  for pattern, icon in pairs(iconPatterns) do
    if worldName:lower():match(pattern) then return icon end
  end

  return iconDefault
end

for _, name in ipairs(worldNames) do
  local world = worlds[name]
  local icon = findIcon(name)

  table.insert(icon.destinations, {
    name = name,
    warpAction = string.format("instanceworld:%s", name),
    planetName = world.persistent and "^darkgray;persistent" or "",
    icon = icon.icon
  })
end

local destinations = {}
for _, icon in ipairs(icons) do
  for _, destination in ipairs(icon.destinations) do
    table.insert(destinations, destination)
  end
end

player.interact("OpenTeleportDialog", {
  canBookmark = false,
  includePartyMembers = false,
  includePlayerBookmarks = false,
  destinations = destinations
}, player.id())
