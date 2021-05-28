local cfg = root.assetJson("/quickbar/pat/instanceworlds.config")
local worlds = root.assetJson("/instance_worlds.config")
local destinations = {}

local function findIcon(name)
	for _,v in ipairs(cfg.icons) do
		--match exact names
		if v.match then
			for _,s in ipairs(v.match) do
				if name == s then
					return v.icon
				end
			end
		end
		
		--find strings
		if v.find then
			for _,s in pairs(v.find) do
				if name:find(s) then
					return v.icon
				end
			end
		end
	end
	
	return "default"
end

--sort world names
local list = {}
for k,_ in pairs(worlds) do
	table.insert(list, k)
end
table.sort(list)

--find icon and add to destinations
for _,name in ipairs(list) do
	local world = worlds[name]
	local icon = findIcon(name)
	
	table.insert(destinations, {
		name = name,
		planetName = world.persistent and "^darkgray;persistent" or "",
		icon = icon,
		warpAction = "instanceworld:"..name
	})
end

--sort destinations by icon
local sortedDestinations = {}
for _,v in ipairs(cfg.icons) do
	for i,d in ipairs(destinations) do
		if d.icon == v.icon then
			table.insert(sortedDestinations, d)
			d.sorted = true
		end
	end
end

--add unsorted destinations
for _,d in ipairs(destinations) do
	if not d.sorted then
		table.insert(sortedDestinations, d)
	end
end

--the funny
player.interact("OpenTeleportDialog", {
	canBookmark = false,
	includePartyMembers = false,
	includePlayerBookmarks = false,
	destinations = sortedDestinations
}, player.id())