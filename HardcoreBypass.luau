--[[
    Zombie Rush HardcoreBypass
    Discovered by 4RR6R

    This script demonstrates a method to directly access the Hardcore game instance (PlaceID: 4301323950)
    By bypassing the main menu validation and level requirements, the client can force a session transfer to the Hardcore sub-place via TeleportService

    Status: Functional
    
    Created for security research and experimental purposes only
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local specificServerId = nil -- If you want to join a specific server in hardcore mode

local localPlayer = Players.LocalPlayer

-- All you have to do is manually teleport the player in hardcore mode
if specificServerId then
    TeleportService:TeleportToPlaceInstance(4301323950, specificServerId, localPlayer, nil, nil, nil)
else
    TeleportService:Teleport(4301323950, localPlayer, nil, nil)
end
