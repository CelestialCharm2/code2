while true do
wait(1)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(.7)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
wait(.6)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(1)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
script.Parent.Close:Play()
wait(3)
script.Parent.Transparency = (1)
script.Parent.PointLight.Enabled = false
wait(2)
script.Parent.Transparency = (0)
script.Parent.PointLight.Enabled = true
--script.Parent.Strike:Play()
--script.Parent.StrikeFar:Play()
wait()
end