local pid = player.id()
if pid ~= 0 then
  world.sendEntityMessage(pid, "toggleMech")
end
