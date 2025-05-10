hairassets={"http://www.roblox.com/asset/?id=13597243","http://www.roblox.com/asset/?id=13070807","http://www.roblox.com/asset/?id=13597638","http://www.roblox.com/asset/?id=13597671","http://www.roblox.com/asset/?id=13597718","http://www.roblox.com/asset/?id=13597696","http://www.roblox.com/asset/?id=13597981","http://www.roblox.com/asset/?id=13598094","http://www.roblox.com/asset/?id=13694600"}
function onTouched(hit)
local human = hit.Parent:findFirstChild("Humanoid")
if (human ~= nil) then
if script.Parent.Name == "Lava Block" then
human.Health = human.Health - 100
end
if script.Parent.Name == "Magic Lava" then

end
end
end

script.Parent.Touched:connect(onTouched)
