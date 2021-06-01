local swap = player.swapSlotItem()
local itemId = params and params[1] or "perfectlygenericitem"

if swap == nil then
	player.setSwapSlotItem({name = itemId})
elseif swap.name == itemId then
	swap.count = (swap.count or 1) + 1
	player.setSwapSlotItem(swap)
else
	pane.playSound("/sfx/interface/clickon_error.ogg")
end
