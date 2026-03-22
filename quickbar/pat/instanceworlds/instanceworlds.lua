local icons = root.assetJson("/quickbar/pat/instanceworlds/instanceworlds.config:icons")
local worlds = root.assetJson("/instance_worlds.config")

local worldNames = {}
for k, _ in pairs(worlds) do table.insert(worldNames, k) end
table.sort(worldNames)

for i, icon in ipairs(icons) do
  icon.priority = icon.priority or 0
  icon.sort = icon.sort or 0
  icon.destinations = {}
  icon.index = i
end

table.sort(icons, function(a, b)
  if a.priority == b.priority then return a.index < b.index end
  return a.priority > b.priority 
end)

local defaultIcon = { icon = "default", destinations = {} }
local matchIcons = {}
for _, icon in ipairs(icons) do
  for _, name in ipairs(icon.names or {}) do table.insert(matchIcons, { name = name, icon = icon }) end
  for _, pattern in ipairs(icon.patterns or {}) do table.insert(matchIcons, { pattern = pattern, icon = icon }) end
end

local function findIcon(worldName)
  local lower = worldName:lower()

  for _, match in ipairs(matchIcons) do
    if (match.name and match.name == worldName)
    or (match.pattern and lower:match(match.pattern)) then
      return match.icon
    end
  end

  return defaultIcon
end

for _, name in ipairs(worldNames) do
  local icon = findIcon(name)

  table.insert(icon.destinations, {
    name = name,
    icon = icon.icon,
    warpAction = string.format("instanceworld:%s", name),
    planetName = worlds[name].persistent and "^darkgray;persistent" or ""
  })
end

table.sort(icons, function(a, b) 
  if a.sort == b.sort then return a.index < b.index end
  return a.sort > b.sort
end)
table.insert(icons, defaultIcon)

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
