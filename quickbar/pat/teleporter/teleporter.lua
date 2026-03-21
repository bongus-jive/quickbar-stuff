local cfg = root.assetJson("/quickbar/pat/teleporter/teleporter.config")
local onShip = player.worldId() == player.ownShipWorldId()
local destinations = {}

for _, d in ipairs(cfg.destinations) do
  if (d.onShip == nil or d.onShip == onShip)
  or (not d.deploy or player.canDeploy()) then
    table.insert(destinations, d)
  end
end

player.interact("OpenTeleportDialog", {
  canBookmark = false,
  includePartyMembers = true,
  includePlayerBookmarks = true,
  destinations = destinations
}, player.id())
