--Nick24r7--

Intermission = math.random(5,10) ----Sets the amount of time for each eruption.----
lavacolors={"Neon orange","Br. yellowish orange","Bright orange","Bright red","Bright yellow"}
LavaCount = 40 ----This will be the average number of how many lava blocks are created----
MLavaChance = 0.1 ----M lava are special and will turn a robloxian into anything----
-------------------------------------DO NOT CHANGE ANYTHING ELSE BELOW!-------------------------------
debris=game:GetService("Debris")
while true do
wait(Intermission)
LavaCountTmp = LavaCount 
LavaCountTmp=LavaCountTmp + math.random(-4,4)
repeat
local glow=Instance.new("PointLight")
glow.Range = math.random(12,16)
glow.Color = Color3.new(255/255,255/255,1/255)
local smoke=Instance.new("Smoke")	
smoke.Color = Color3.new(128/255,128/255,128/255)
debris:AddItem(smoke,math.random(8,20))
smoke.RiseVelocity = math.random(4,11)
local fire=Instance.new("Fire")	
fire.Name = "Fire"
fire.Size = fire.Size + math.random(0,6)
fire.Heat = fire.Heat + math.random(0,12)
local lvp = Instance.new("Part")
lvp.Material = "Slate"
lvp.Name = "Lava Block"
if math.random()<=MLavaChance then
lvp.Material = "Plastic"
lvp.Reflectance = math.random(0.65536,1)
local spark=Instance.new("Sparkles")
spark.Parent = lvp
spark.Name = "The Ultimate"
lvp.Name = "Magic Lava"
end
lvp.Parent = game.Workspace
fire.Parent = lvp
glow.Parent = lvp
lvp.BackSurface = "Smooth"
lvp.BottomSurface = "Smooth"
lvp.FrontSurface = "Smooth"
lvp.LeftSurface = "Smooth"
lvp.RightSurface = "Smooth"
lvp.TopSurface = "Smooth"
local transferscript = script.Parent.LavaOT:Clone()
transferscript.Parent = lvp
transferscript.Disabled = false
lvp.Position = (script.Parent.Position)
lvp.Size = Vector3.new(math.random(3,8.86),math.random(3,9.12),math.random(3,9.33))
smoke.Size = math.random(12,22.5)
smoke.Parent = lvp
lvp.Friction=.125
lvp.Velocity = Vector3.new(0,math.random(225,320),0)
lvp.RotVelocity = Vector3.new(math.random(6.13,32.768)*8,math.random(6.13,32.768)*1.3,math.random(6.13,32.768)*10)
lvp.BrickColor=BrickColor.new(lavacolors[math.random(1,#lavacolors)])
debris:AddItem(lvp,math.random(30,120)*math.random(0.72,1.75))
LavaCountTmp = LavaCountTmp - 1
wait(math.random(0.3,1))
until LavaCountTmp == 0
end