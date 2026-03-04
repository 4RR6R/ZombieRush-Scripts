--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a critical server-side validation flaw in the WeaponEvent damage handling system
    By sending negative hit values, it is possible to invert the damage calculation logic, effectively regenerating zombie health instead of reducing it
	This issue will be fixed in a future update

    Status: Functional

    Created for security research and responsible disclosure purposes only
]]

getgenv().DesiredHealth = 6767676720

local originalNamecall; originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self : Instance, ... : any) : any
	local arguments = table.pack(...)
	local namecallmethod = getnamecallmethod()
	if not checkcaller() then
		if self.Name == "WeaponEvent" and namecallmethod == "FireServer" then
            local damage = arguments[1].Tool and arguments[1].Tool:GetAttribute("Damage") 
			for index in arguments[1].HumanoidTables do
                local currentHealth = arguments[1].HumanoidTables[index].THumanoid and arguments[1].HumanoidTables[index].THumanoid.Health
                if damage and currentHealth then
                    local totalNeeded = currentHealth - DesiredHealth
                    arguments[1].HumanoidTables[index].HeadHits = 0
                    arguments[1].HumanoidTables[index].BodyHits = math.min(math.round(totalNeeded / damage), 0) -- Vulnerability is here -> Negative number -> Invert damage calculation
                end
			end
		end
	end
	setnamecallmethod(namecallmethod)
	return originalNamecall(self, table.unpack(arguments, 1, arguments.n))
end))
