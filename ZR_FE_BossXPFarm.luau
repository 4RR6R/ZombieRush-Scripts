--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a server-side validation flaw in the WeaponEvent damage calculation system
    This allows manipulation of damage attribution logic, potentially enabling unintended XP gain without properly reducing boss health
	This issue will be fixed in a future update

    Status: Functional

    Created for security research and responsible disclosure purposes only
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local character = localPlayer.character or localPlayer.CharacterAdded:Wait()

local primaryWeapons = ReplicatedStorage:WaitForChild("WeaponRequirements"):WaitForChild("Primary")

local weaponEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("WeaponEvent")
local backpackEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BackpackEvent")

local primary = localPlayer:WaitForChild("EquipStorage"):WaitForChild("Primary")
local gameTime = ReplicatedStorage:WaitForChild("GameProperties"):WaitForChild("GameState"):WaitForChild("Time")

local zombieStorage = workspace:WaitForChild("Zombie Storage")

local blacklistedZombies = {}

--[[
    Searches for a target among zombies based on health, distance, and type criteria.
    Includes humanoid state verification and a blacklist to mitigate latency issues.

    @param origin Vector3 - The reference position to measure distance from.
    @param range number - The maximum allowed distance from the origin.
    @param bossInclude boolean - If true, bosses are prioritized (immediate return). If false, they are ignored.
    @param zombieType string - Selection mode: "LowHealth" (lowest HP) or "HighHealth" (highest HP).
    @return Model? - The zombie model matching the criteria, or nil if no target is found.
]]
local function getZombieTarget(origin : Vector3, range : number, bossInclude : boolean, zombieType : "LowHealth" | "HighHealth") : Model?
    local bestZombie = nil
    local bestHealth = (zombieType == "LowHealth") and math.huge or 0
    for _, instance in (bossInclude and workspace:GetChildren() or zombieStorage:GetChildren()) do
        local torso = instance:FindFirstChild("Torso")
        local humanoid = instance:FindFirstChild("Humanoid")
        if torso and humanoid and (humanoid.Health > 0.1 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead) and instance:FindFirstChild("Enemy") and not table.find(blacklistedZombies, instance, 1) then
            if (torso.Position - origin).Magnitude <= range then
                local currentHealth = humanoid.Health
                if zombieType == "HighHealth" then
                    if currentHealth > bestHealth then
                        bestHealth = currentHealth
                        bestZombie = instance
                    end
                elseif zombieType == "LowHealth" then
                    if currentHealth < bestHealth then
                        bestHealth = currentHealth
                        bestZombie = instance
                    end
                end
            end
        end
    end
    if not bestZombie and bossInclude then
        return getZombieTarget(origin, range, false, zombieType) 
    end
    return bestZombie
end

--[[
    Main function to handle weapon firing logic
]]
local function main() : () -> ()
	warn("Processing...")
	if not character:FindFirstChild("Alive") then
		return warn("Please wait for the next wave")
	end
	backpackEvent:FireServer("Unequip")
	backpackEvent:FireServer("Equip", primary.Value)
	character.ChildAdded:Wait()
	local tool = character:FindFirstChild(primary.Value)
	task.wait(1)
	if not tool then
		backpackEvent:FireServer("Unequip")
		return warn("You do not have a weapon equipped")
	end
	local zombieTarget = gameTime.Value <= 30 and getZombieTarget(tool.Handle.Muzzle.WorldPosition, tool:GetAttribute("Range"), false, "LowHealth") or getZombieTarget(tool.Handle.Muzzle.WorldPosition, tool:GetAttribute("Range"), true, "LowHealth")
	if not zombieTarget then
		backpackEvent:FireServer("Unequip")
		return warn("There are no more functional zombies")
	end
	while true do
		if not tool or not tool:FindFirstChild("Handle") or not tool:IsDescendantOf(character) then
			warn("Weapon has been unequipped")
			break
		end
		if zombieTarget and zombieTarget:FindFirstChild("Head") then
		    if not zombieTarget:GetAttribute("Boss") then
		        table.insert(blacklistedZombies, zombieTarget)
		    end
			local muzzlePosition = tool.Handle.Muzzle.WorldPosition
			local targetDirection = (zombieTarget.Head.Position - muzzlePosition).Unit
			weaponEvent:FireServer({
				Tool = tool,
				RealTool = tool,
				HumanoidTables = {{
					-- We make sure that the zombie will take damage to gain XP by sending a positive amount of hits
					HeadHits = tool:GetAttribute("Burst"),
					-- We send a negative amount of hits to compensate and prevent the zombie from taking damage
					BodyHits = zombieTarget:GetAttribute("Boss") ~= nil and -tool:GetAttribute("Burst") * 1.5 or 0,
					-- This way, the zombie won't take any damage, but you'll still earn XP for hitting it
					THumanoid = zombieTarget.Humanoid,
				}},
				LaserProperties = table.create(tool:GetAttribute("Burst"), {
					Enum.Material.Neon,
					BrickColor.Black(),
					targetDirection,
					CFrame.new(muzzlePosition, muzzlePosition + targetDirection),
					zombieTarget.Head.Position,
					tool:GetAttribute("Range"),
					true,
					Vector3.zero
				}),
			})
		else
			warn("Target not found, retrying...")
		end
		zombieTarget = gameTime.Value <= 30 and getZombieTarget(tool.Handle.Muzzle.WorldPosition, tool:GetAttribute("Range"), false, "LowHealth") or getZombieTarget(tool.Handle.Muzzle.WorldPosition, tool:GetAttribute("Range"), true, "LowHealth")
		table.remove(blacklistedZombies, 1)
		task.wait(1 / tool:GetAttribute("Firerate"))
	end
end

main()
