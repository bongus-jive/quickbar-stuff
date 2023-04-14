do

local cfg = root.assetJson("/quickbar/pat/teleporter/teleporter.config")
local destinations = {}
local onShip = player.worldId() == player.ownShipWorldId()

for _,d in ipairs(cfg.destinations) do
	if (d.onShip == nil
	or (d.onShip == true and onShip)
	or (d.onShip == false and not onShip))
	and (not d.deploy or player.canDeploy()) then
		d.onShip = nil
		if d.warpAction == "self" then
			local pos = world.entityPosition(player.id())
			d.warpAction = string.format("Nowhere=%s.%s", math.floor(pos[1]), math.floor(pos[2]))
		end
		table.insert(destinations, d)
	end
end

player.interact("OpenTeleportDialog", {
	canBookmark = false,
	includePartyMembers = true,
	includePlayerBookmarks = true,
	destinations = destinations
}, player.id())

end