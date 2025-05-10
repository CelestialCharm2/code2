while true do
wait(0.5)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(0.7)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
wait(0.06)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(.008)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
script.Parent.Close:Play()
wait(5)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(3)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
--script.Parent.Strike:Play()
--script.Parent.StrikeFar:Play()
wait()
end