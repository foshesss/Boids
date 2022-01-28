local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Encyclopedia = require(ReplicatedStorage.Encyclopedia)
_G.Encyclopedia = Encyclopedia


local SETTINGS = {
	AreaSize = 50,
	NumBoids = 25
}

-- visual creation of the area
local p = Encyclopedia.NewInstance("Part", {
	Size = Vector3.new(1,0,1) * SETTINGS.AreaSize + Vector3.new(0,.25,0),
	CanCollide = false,
	Anchored = true,
	Position = Vector3.new(.5,0,.5) * SETTINGS.AreaSize,
	Transparency = .5,
	Color = Color3.fromRGB(76, 76, 76)
})

local Camera = workspace.CurrentCamera

-- sets camera to focus on the area in which boids will be placed
game:GetService("RunService").RenderStepped:Connect(function()
	Camera.CFrame = CFrame.new(p.Position + Vector3.new(0,40,0), p.Position)
end)

local Boid = require(script.Boid)

for i = 1, SETTINGS.NumBoids do
	Boid.new(SETTINGS.AreaSize, i == 1)
end
