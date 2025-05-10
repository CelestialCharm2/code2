while true do
wait(0.002)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(0.34)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
wait(0.06)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(0.8)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
script.Parent.Close:Play()
wait(0.002)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(2)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
--script.Parent.Strike:Play()
--script.Parent.StrikeFar:Play()
wait()
end