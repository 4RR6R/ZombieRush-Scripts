--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a server-side validation flaw in grenade handling through improper parameter type verification
    Consequently, the grenade is successfully thrown but never detonates
    This behavior is especially disruptive for attraction-type grenades (Pipe Bomb, Can-O-Beans) that draw zombies toward their location, as affected zombies will remain indefinitely gathered around a glitched grenade
	In other words, zombies will never chase you again, and you can consider yourself invincible and able to reach waves that are virtually unattainable even with the nuke launcher and ban hammer
 	This issue will be fixed in a future update

    Status: Functional

    Created for security research and responsible disclosure purposes only
]]

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local mapStorage = workspace:WaitForChild("Map Storage")

local raycastParameters = RaycastParams.new()
raycastParameters.FilterDescendantsInstances = {mapStorage}
raycastParameters.FilterType = Enum.RaycastFilterType.Include

local originalNamecall; originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local arguments = table.pack(...)
	local namecallmethod = getnamecallmethod()
	if not checkcaller() then
        if self.Name == localPlayer.Name .. "Nade" and namecallmethod == "FireServer" then
            local character = localPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local raycastResult = workspace:Raycast(humanoidRootPart.Position, -Vector3.yAxis * 1000, raycastParameters)
                arguments[1].StartPosition = raycastResult.Instance ~= nil and raycastResult.Position - Vector3.yAxis * 5 or arguments[1].StartPosition -- Vulnerability is here -> Bomb in the ground
                arguments[1].DirectionVector = Vector3.zero -- Preventing the game to add velocity on the bomb
            end
		end
	end
	setnamecallmethod(namecallmethod)
	return originalNamecall(self, table.unpack(arguments, 1, arguments.n))
end))
