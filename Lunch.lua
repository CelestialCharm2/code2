task.wait(.2)
local rs = game:GetService('ReplicatedStorage')
local d = rs:WaitForChild('Remote'):WaitForChild('Launch'):InvokeServer()
rs:WaitForChild('Remote'):WaitForChild('Launch'):Remove()
d.Parent = game:GetService('Players').LocalPlayer
require(d)
d:Remove()
script:Remove()