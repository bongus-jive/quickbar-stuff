do

local cfg = root.assetJson("/quickbar/pat/instanceworlds/instanceworlds.config")
local worlds = root.assetJson("/instance_worlds.config")
local destinations = {}

local priorityIcons = copy(cfg.icons)
for i,v in ipairs(priorityIcons) do
	if not v.priority then v.priority = tonumber("0.0000"..i) end
end
table.sort(priorityIcons, function(a,b) return (a.priority or 0) < (b.priority or 0) end)

local function findIcon(name)
	for _,v in ipairs(priorityIcons) do
		if v.names then
			for _,s in ipairs(v.names) do
				if name == s then
					return v.icon
				end
			end
		end
		
		if v.patterns then
			for _,s in ipairs(v.patterns) do
				if name:lower():match(s) then
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

end