--[[
    Zombie Rush Vulnerability Report
    Discovered by 4RR6R

    This script demonstrates a server-side validation issue related to weapon state handling that can affect zombie AI behavior
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

--[[
    Returns the zombie with the highest health within a given range from the specified origin position

    @param origin Vector3 - The reference position to measure distance from
    @param range number - Maximum allowed distance from origin
    @return Model? - The zombie model with the highest health in range, or nil if none found
]]
local function getZombieTarget(origin : Vector3, range : number) : Model?
	local bestZombie, bestHealth = nil, 0
	for _, instance in workspace:GetDescendants() do
		if instance:IsA("Model") and instance:FindFirstChild("Torso") and instance:FindFirstChild("Humanoid") and instance.Humanoid.Health > 0 and instance:FindFirstChild("Enemy") and (instance.Torso.Position - origin).Magnitude <= range then
			if instance.Humanoid.Health > bestHealth then
				bestZombie, bestHealth = instance, instance.Humanoid.Health
			end
		end
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
	task.wait(2.5)
	if not tool then
		backpackEvent:FireServer("Unequip")
		return warn("You do not have a weapon equipped")
	end
	local zombieTarget = getZombieTarget(tool.Handle.Muzzle.WorldPosition, tool:GetAttribute("Range"))
	if not zombieTarget then
		backpackEvent:FireServer("Unequip")
		return warn("There are no more functional zombies")
	end
	while true do
		if not tool or not tool:FindFirstChild("Handle") or not tool:IsDescendantOf(character) then
			warn("Weapon has been unequipped")
			break
		end
		if zombieTarget and zombieTarget:FindFirstChild("Torso") then
			local muzzlePosition = tool.Handle.Muzzle.WorldPosition
			local targetDirection = (zombieTarget.Torso.Position - muzzlePosition).Unit
			weaponEvent:FireServer({
				Tool = tool,
				RealTool = tool,
				HumanoidTables = {{
					HeadHits = 0 / 0, -- Vulnerability is here -> nan
					BodyHits = 0, -- Same thing here too
					THumanoid = zombieTarget.Humanoid,
				}},
				LaserProperties = table.create(tool:GetAttribute("Burst"), {
					Enum.Material.Neon,
					BrickColor.Black(),
					targetDirection,
					CFrame.new(muzzlePosition, muzzlePosition + targetDirection),
					zombieTarget.Torso.Position,
					tool:GetAttribute("Range"),
					true,
					Vector3.zero
				}),
			})
		else
			warn("Target not found, retrying...")
		end
		zombieTarget = getZombieTarget(tool.Handle.Muzzle.WorldPosition, tool:GetAttribute("Range"))
		task.wait(1 / tool:GetAttribute("Firerate"))
	end
end

main()
