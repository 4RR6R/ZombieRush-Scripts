--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a server-side velocity desynchronization issue affecting AI target prediction mechanics
    While this technique can also be used to fling zombies or players outside of the map boundaries (when playing as a zombie), that is not the primary purpose of this proof of concept
	This issue will be fixed in a future update

    Status: Functional

    Created for security research and responsible disclosure purposes only
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

RunService.PostSimulation:Connect(function()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		local realVelocity = humanoidRootPart.AssemblyLinearVelocity
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(math.cos(tick()), 0, math.sin(tick())) * 50 -- Vulnerability is here -> Velocity desynchronization
		RunService.RenderStepped:Wait()
		humanoidRootPart.AssemblyLinearVelocity = realVelocity
	end
end)
