--[[

-[InitEncyclopedia]------------------------
	
	Members:
		Services -- folder containing all server-sided services
			(services you don't ever use on the client)
		SharedServices -- folder containing all services used on both
			the client and server
		
	Methods [Encyclopedia]:
		Encyclopedia.GetService(service) -- retrieves the target service module
			service	[string]
			
		Encyclopedia.GetUtil(name) -- retrieves the target utility module
			name	[string]
			
		Encyclopedia.NewInstance(class, properties)
			class		[string]
			properties	[table]
			
		Encyclopedia.TraversePath(path, origin) 
		- traverses a string path, and starts at the origin
			path		[string] -- formatted like this "Resources.Item.Drop.Bandit"
			origin 		[Service] -- ReplicatedStorage, ServerStorage, etc.
			
		Encyclopedia.DeepCopy(original) - deep copies any table you need.. EVER.
			original	[table]
		
		-- Quenty's st00f --
		Encyclopedia.GetMaid() -- returns a brand new Maid (Maid.new())
		Encyclopedia.CreateSignal() -- returns a brand new Signal (Signal.new())
	
]]

local SETTINGS = {
	Name = "Encyclopedia"
}

----- Loaded Services -----
local RunService = game:GetService("RunService")

----- Private Variables -----
local Services = if RunService:IsServer() == true then
	script.Services else nil
local SharedServices = script.SharedServices
local Loaded_Services = {
	
}

---- Utils -----
local Utils = script.Utils
local Maid = require(Utils.Maid)
local Signal = require(Utils.Signal)

---- Private functions -----

-- Encyclopedia Object:
local Encyclopedia = {
	
}

function Encyclopedia.GetService(name)
	local service = Loaded_Services[name]
	if service ~= nil then return service end
	
	service = SharedServices:FindFirstChild(name)
	
	if service == nil and Services ~= nil then
		service = Services:FindFirstChild(name)
	end
	
	assert(service ~= nil, 
		"[Encyclopedia] Could not find \""..name.."\"")
	assert(service:IsA("ModuleScript") == true,
		"[Encyclopedia] \""..name.."\" is not a ModuleScript.")
	
	service = require(service)
	Loaded_Services[name] = service
	
	print("\""..name.."\" has been loaded for the first time.")
	return service
end

function Encyclopedia.GetMaid()
	return Maid.new()
end

function Encyclopedia.CreateSignal()
	return Signal.new()
end

function Encyclopedia.GetUtil(name)
	local util = Utils:FindFirstChild(name)
	assert(util ~= nil, string.format("[Encyclopedia] Util '%s' does not exist.", name))
	
	return require(util)
end

function Encyclopedia.NewInstance(class, properties)
	local instance = Instance.new(class)
	for k, v in pairs(properties) do
		if k ~= "Parent" then
			instance[k] = v
		end
	end
	instance.Parent = properties.Parent or workspace
	return instance
end

function Encyclopedia.TraversePath(path, origin)
	local t = origin

	for _, path in ipairs(string.split(path, '.')) do
		t = t[path]
	end

	return t:Clone()
end

function Encyclopedia.DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = Encyclopedia.DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

-- Initialize:
if RunService:IsServer() == true then
	Services.Parent = game:GetService("ServerStorage")
end

return Encyclopedia