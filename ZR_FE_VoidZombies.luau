--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a server-side validation issue related to weapon state handling that can affect zombie AI behavior and player entities
    Specifically, when using the Ban Hammer, this vulnerability allows players to be invalidated (voided) due to improper server-side validation of combat parameters
    This issue will be fixed in a future update

    Status: Patched

    Created for security research and responsible disclosure purposes only
]]

local originalNamecall; originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self : Instance, ... : any) : any
	local arguments = table.pack(...)
	local traceback = debug.traceback()
	local namecallmethod = getnamecallmethod()
	if not checkcaller() then
		if self.Name == "RemoteFunction" and namecallmethod == "InvokeServer" and string.find(traceback, "MeleeController", 1, true) then
			arguments[1].Direction = Vector3.zero / 0 -- Vulnerability is here -> nan, nan, nan (You can also put a huge vector3 -> Crazy Knockback)
		end
	end
    setnamecallmethod(namecallmethod)
	return originalNamecall(self, table.unpack(arguments, 1, arguments.n))
end))
