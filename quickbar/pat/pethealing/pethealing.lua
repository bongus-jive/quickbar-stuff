require "/scripts/util.lua"

local healing = false
local healTimer = 0
local frameTimer = 0
local scungus

function init()
  scungus = widget.getData("scungus")
  scungus.file = scungus.file..":"
  scungus.timer = 0
end

function update(dt)
  scungus.timer = (scungus.timer + (dt / scungus.duration)) % 1
  widget.setImage("scungus", scungus.file..math.floor(scungus.timer * scungus.frames))
  
  local input = widget.itemSlotItem("input")
  local output = widget.itemSlotItem("output")
  
  widget.setItemSlotProgress("input", healing and healTimer or 1)
  widget.setButtonEnabled("heal", input and input.name == "filledcapturepod" and not output)
  widget.setText("heal", healing and "Cancel" or "Heal")
  
  if healing then
    healTimer = math.min(healTimer + dt, 1)
    if healTimer == 1 then
      heal(input)
    end
  else
    healTimer = 0
  end
  
  if input and input.name == "filledcapturepod" and input.parameters then
    local percent = 0
    
    local pets = input.parameters.currentPets or input.parameters.pets
    if pets then
      if not pets[1] or not pets[1].status then
        percent = 1
      elseif not pets[1].status.dead then
        local health = pets[1].status.resources.health or 0
        local maxHealth = pets[1].status.resourceMax.health or 1
        
        percent = health / maxHealth
      end
    end
    
    if healing then
      percent = percent + (healTimer * (1 - percent))
    end
    widget.setProgress("health", percent)
    widget.setVisible("health", true)
  else
    widget.setVisible("health", false)
  end
end

function heal(item)
  healing = false
  
  local healedParams = copy(item.parameters) or {}
  jremove(healedParams, "inventoryIcon")
  jremove(healedParams, "currentPets")
  for _,pet in pairs(healedParams.pets or {}) do
    jremove(pet, "status")
  end
  healedParams.podItemHasPriority = true
  
  widget.setItemSlotItem("input", nil)
  widget.setItemSlotItem("output", {
    name = item.name,
    count = item.count,
    parameters = healedParams
  })
end

function toggleheal()
  healing = not healing
end

function slot(name)
  local item = widget.itemSlotItem(name)
  local swap = player.swapSlotItem()
  
  if name == "input" then
    widget.setItemSlotItem(name, swap)
    player.setSwapSlotItem(item)
    if healing then
      healing = false
    end
  elseif name == "output" and item and not swap then
    widget.setItemSlotItem(name, nil)
    player.setSwapSlotItem(item)
  end
end

function dismissed()
  local input = widget.itemSlotItem("input")
  local output = widget.itemSlotItem("output")
  
  if input then
    player.giveItem(input)
  end
  
  if output then
    player.giveItem(output)
  end
end