--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script exploits a lack of server-side validation on the map voting system
    The 'VotingRemote' does not check if a player has already cast a vote, allowing a single client to send multiple requests and force the selection of a specific map (1-3)

    Status: Functional
    
    Created for security research and experimental purposes only
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Remotes")

local votingRemote = remotes:WaitForChild("VotingRemote")

local mapToVote = 1 -- The numbers range from 1 to 3 (left to right) for the maps displayed on the various screens

for _ = 1, 50 do
    votingRemote:FireServer(mapToVote)
    task.wait(1.25)
end
