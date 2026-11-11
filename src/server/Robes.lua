-- Robes: dresses a player's avatar as a monastic.
-- The avatar keeps its own face, hair and body. Everything it was wearing (shirt, trousers,
-- jackets, shoes, hats, backpacks and the like) is taken off and replaced by a robe in the
-- chosen colours, with a wrap and a sash. "My Own Clothes" restores the avatar.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)
local Combat = require(script.Parent.Combat)
local Rig = require(script.Parent.Rig)
local Cosmetics = require(script.Parent.Cosmetics)

local Robes = {}

local originals = {} -- [character] = the avatar's own look

local function robeDef(id)
	for _, r in ipairs(Config.Robes) do
		if r.id == id then
			return r
		end
	end
	return nil
end
Robes.def = robeDef

-- Kinds of worn thing that stay on with a robe: they are part of the face and head.
local KEPT = {
	[Enum.AccessoryType.Hair] = true,
	[Enum.AccessoryType.Face] = true,
	[Enum.AccessoryType.Eyebrow] = true,
	[Enum.AccessoryType.Eyelash] = true,
}

-- Take off everything the avatar was wearing.
local function undress(desc)
	desc.Shirt = 0
	desc.Pants = 0
	desc.GraphicTShirt = 0
	desc.HatAccessory = ""
	desc.BackAccessory = ""
	desc.FrontAccessory = ""
	desc.NeckAccessory = ""
	desc.ShouldersAccessory = ""
	desc.WaistAccessory = ""
	-- layered clothing: jackets, sweaters, trousers, skirts, shoes ...
	pcall(function()
		local kept = {}
		for _, worn in ipairs(desc:GetAccessories(false)) do
			if KEPT[worn.AccessoryType] then
				table.insert(kept, worn)
			end
		end
		desc:SetAccessories(kept, false)
	end)
end

local function clearPieces(character)
	for _, child in ipairs(character:GetChildren()) do
		if child.Name == "RobePiece" then
			child:Destroy()
		end
	end
	for _, d in ipairs(character:GetDescendants()) do
		if d.Name == "RobeGlow" then
			d:Destroy()
		end
	end
end

function Robes.apply(player)
	local character = player.Character
	local profile = PlayerData.get(player)
	if not character or not profile then
		return
	end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return
	end
	local def = robeDef(profile.robe) or robeDef("novice")

	if not originals[character] then
		local ok, desc = pcall(function()
			return hum:GetAppliedDescription()
		end)
		if ok and desc then
			originals[character] = desc
			character.Destroying:Connect(function()
				originals[character] = nil
			end)
		end
	end
	local original = originals[character]

	clearPieces(character)

	if def.id == "own" or not def.main then
		if original then
			pcall(function()
				hum:ApplyDescription(original)
			end)
		end
	else
		local main = Color3.fromRGB(def.main[1], def.main[2], def.main[3])
		local sash = Color3.fromRGB(def.sash[1], def.sash[2], def.sash[3])
		if original then
			pcall(function()
				local desc = original:Clone()
				undress(desc)
				desc.TorsoColor = main
				desc.LeftArmColor = main
				desc.LeftLegColor = main
				desc.RightLegColor = main
				desc.RightArmColor = def.bare and original.HeadColor or main
				hum:ApplyDescription(desc)
			end)
		end
		if character.Parent and hum.Health > 0 then
			Rig.Dress.wrap(character, main, 2.3)
			Rig.Dress.sash(character, sash, false)
			Rig.Dress.shoulder(character, sash)
			for _, child in ipairs(character:GetChildren()) do
				if child.Name == "Dress" then
					child.Name = "RobePiece"
				end
			end
			if def.glow then
				local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
				if torso then
					local light = Instance.new("PointLight")
					light.Name = "RobeGlow"
					light.Color = Color3.fromRGB(255, 226, 150)
					light.Range = 16
					light.Brightness = 1.4
					light.Shadows = false
					light.Parent = torso
					local e = Instance.new("ParticleEmitter")
					e.Name = "RobeGlow"
					e.Rate = 6
					e.Lifetime = NumberRange.new(1.2, 2)
					e.Speed = NumberRange.new(0.4, 1.2)
					e.SpreadAngle = Vector2.new(180, 180)
					e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
					e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
					e.Color = ColorSequence.new(Color3.fromRGB(255, 226, 150))
					e.LightEmission = 0.8
					e.Parent = torso
				end
			end
		end
	end

	-- a trail of prayer-flag colours for those who carry prayer flags
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and (profile.inv.prayer_flags or 0) > 0 and not root:FindFirstChild("FlagTrail") then
		local a0 = Instance.new("Attachment")
		a0.Name = "FlagTrailTop"
		a0.Position = Vector3.new(0, 1.6, 0.6)
		a0.Parent = root
		local a1 = Instance.new("Attachment")
		a1.Name = "FlagTrailBottom"
		a1.Position = Vector3.new(0, 0.6, 0.6)
		a1.Parent = root
		local trail = Instance.new("Trail")
		trail.Name = "FlagTrail"
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 1.1
		trail.MinLength = 0.2
		trail.LightEmission = 0.2
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 90, 200)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(245, 245, 245)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(205, 44, 44)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(46, 150, 70)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 200, 40)),
		})
		trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
		trail.Parent = root
	end

	Combat.equipWeapon(player)
	Cosmetics.apply(player)
end

return Robes
