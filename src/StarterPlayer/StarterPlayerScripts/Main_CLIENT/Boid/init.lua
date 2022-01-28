local Encyclopedia = _G.Encyclopedia
--[[
-[Boids.lua]---------------
	Created based on a Sebastian Lague video (https://www.youtube.com/watch?v=bqtqltqcQhw). An unfinished project, uploaded
	as an open sourced tool to display the action of boids avoiding eachother.

[Boid]:
	[Methods]:
		Boid.new(area, mine) - Constructor method
			area: 	[number] - Size of the area that the Boid can move (area is positioned directly about the origin)
			mine:	[boolean] - used for coloring-- sets this Boid to red, so I could focus on one Boid during testing

		Boid:_init() - [void] - Activates the Boid and makes it move, following the rule of no colliding with other Boids.

--]]

local SETTINGS = {
	Speed = 15 -- Speed of boids
}

----- Loaded Services -----
local RunService = game:GetService("RunService")

----- Private variables -----
local Boids = workspace.Boids
local RNG = Random.new()
local BoidColors = require(script.BoidColors)

-- Object:
local Boid = {
	
}
Boid.__index = Boid

function Boid.new(area, mine)
	local self = setmetatable({
		_maid = Encyclopedia.GetMaid(),
		
		_direction = Vector3.new(RNG:NextNumber(-1, 1), 0, RNG:NextNumber(-1, 1)).Unit,
		_area = area,
		mine = mine
	}, Boid)
	
	self:_init()
	
	return self
end

function Boid:_init()
	local Maid = self._maid
	
	local my_boid =  script.BoidObj:Clone()
	my_boid.Position = Vector3.new( -- random position
		math.random(self._area), 
		0, 
		math.random(self._area)
	)
	my_boid.BoidColor.Color3 = (if self.mine == true then Color3.fromRGB(255, 98, 98) else BoidColors[math.random(#BoidColors)])
	my_boid.Parent = Boids
	
	
	
	local direction = self._direction
	
	-- make the boid move
	Maid:GiveTask(
		RunService.Stepped:Connect(function(t, dt)
			local curr_pos = my_boid.Position
			
			do -- adjust position based on area bounds
				if curr_pos.X > self._area then
					curr_pos = Vector3.new(0, curr_pos.Y, curr_pos.Z)
				elseif curr_pos.X < 0 then
					curr_pos = Vector3.new(self._area, curr_pos.Y, curr_pos.Z)
				end

				if curr_pos.Z > self._area then
					curr_pos = Vector3.new(curr_pos.X, curr_pos.Y, 0)
				elseif curr_pos.Z < 0 then
					curr_pos = Vector3.new(curr_pos.X, curr_pos.Y, self._area)
				end
			end
			
			-- finds nearby boids and get away from them
			for _, boid in ipairs(Boids:GetChildren()) do
				local magnitude = (curr_pos - boid.Position).Magnitude
				
				if my_boid ~= boid and magnitude < script:GetAttribute("AvoidDist") and boid.Position then
					local other_boid_pos = boid.Position
					local dir = (curr_pos - other_boid_pos).Unit
					
					if dir:Dot(direction) > 0 then
						continue
					end
					
					local new_dir = ((curr_pos - boid.Position)).Unit * math.abs(5 - magnitude)/5
					direction = (new_dir + direction).Unit
				end
			end
			
			-- position/move the boid
			local current_cframe = 
				CFrame.new(
					curr_pos, 
					curr_pos + direction
				)
			my_boid.CFrame = current_cframe + (direction * SETTINGS.Speed * dt)
		end)
	)
end


return Boid