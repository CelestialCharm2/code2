local ConfigurationFile = script.Parent.Configuration
local LeftBlinker = script.Parent.LeftBlinker
local RightBlinker = script.Parent.RightBlinker
local LeftOn = true
local RightOn = false

function UpdateBlinkers()
	while ConfigurationFile:FindFirstChild("On").Value == true do
		if ConfigurationFile:FindFirstChild("Blink Time").Value > .02 then
			wait(ConfigurationFile:FindFirstChild("Blink Time").Value)
		else
			ConfigurationFile:FindFirstChild("Blink Time").Value = .03
		end
		if LeftOn then
			LeftBlinker.BrickColor = ConfigurationFile:FindFirstChild("Blinker Color 1").Value
			LeftOn = false
		else
			LeftBlinker.BrickColor = ConfigurationFile:FindFirstChild("Blinker Color 2").Value
			LeftOn = true
		end
		if RightOn then
			RightBlinker.BrickColor = ConfigurationFile:FindFirstChild("Blinker Color 1").Value
			RightOn = false
		else
			RightBlinker.BrickColor = ConfigurationFile:FindFirstChild("Blinker Color 2").Value
			RightOn = true
		end
	end
end
ConfigurationFile:FindFirstChild("On").Changed:connect(UpdateBlinkers)


local Children = script.Parent:GetChildren()
ConfigurationFile:FindFirstChild("Color 2").Changed:connect(function()
	for i = 1, #Children do
		if Children[i].Name == "BarColor2" then 
			Children[i].BrickColor = ConfigurationFile:FindFirstChild("Color 2").Value
		end
	end
end)
local Children = script.Parent:GetChildren()
ConfigurationFile:FindFirstChild("Color 1").Changed:connect(function()
	for i = 1, #Children do
		if Children[i].Name == "BarColor1" then 
			Children[i].BrickColor = ConfigurationFile:FindFirstChild("Color 1").Value
		end
	end
end)

UpdateBlinkers()