--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a server-side validation flaw in grenade handling through improper parameter type verification
    Consequently, the grenade is successfully thrown but never detonates
    This behavior is especially disruptive for attraction-type grenades (Pipe Bomb, Can-O-Beans) that draw zombies toward their location, as affected zombies will remain indefinitely gathered around a grenade that no longer functions

    Status: Patched

    Created for security research and responsible disclosure purposes only
]]

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local originalNamecall; originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self : Instance, ... : any) : any
	local arguments = table.pack(...)
	local traceback = debug.traceback()
	local namecallmethod = getnamecallmethod()
	if not checkcaller() then
		if self.Name == localPlayer.Name .. "Nade" and namecallmethod == "FireServer" then
			arguments[1].DirectionVector = "Totally_Not_A_Vector" -- Vulnerability was here -> Invalid argument 
		end
	end
	setnamecallmethod(namecallmethod)
	return originalNamecall(self, table.unpack(arguments, 1, arguments.n))
end))
