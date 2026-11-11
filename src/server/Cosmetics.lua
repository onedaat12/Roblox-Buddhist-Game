-- Cosmetics: things that change only how a player looks. Trails that follow behind,
-- small companions that float at the shoulder, and the colours of their sky lanterns.
-- None of them makes the journey easier.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local PlayerData = require(script.Parent.PlayerData)

local Cosmetics = {}

local FEET = -2.8 -- how far below the middle of the body the ground is

local function attachment(root, x, y, z)
	local a = Instance.new("Attachment")
	a.Name = "Cosmetic"
	a.Position = Vector3.new(x, y, z)
	a.Parent = root
	return a
end

local function ribbon(root, color, width, life)
	local a0 = attachment(root, -width / 2, FEET, 0.4)
	local a1 = attachment(root, width / 2, FEET, 0.4)
	local trail = Instance.new("Trail")
	trail.Name = "Cosmetic"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = life
	trail.MinLength = 0.1
	trail.LightEmission = 0.8
	trail.Color = ColorSequence.new(color)
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
	trail.Parent = root
end

local function drift(root, color, rate, size)
	local e = Instance.new("ParticleEmitter")
	e.Name = "Cosmetic"
	e.Rate = rate
	e.Lifetime = NumberRange.new(1.4, 2.4)
	e.Speed = NumberRange.new(0.4, 1.4)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Acceleration = Vector3.new(0, -2.5, 0)
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-120, 120)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, size * 0.3) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 1) })
	e.Color = ColorSequence.new(color)
	e.LightEmission = 0.3
	e.Parent = attachment(root, 0, FEET + 1.2, 0.8)
end

local Trails = {}

function Trails.trail_petals(root)
	drift(root, Color3.fromRGB(255, 176, 204), 9, 0.45)
end

function Trails.trail_light(root)
	ribbon(root, Color3.fromRGB(255, 236, 190), 1.6, 1.3)
end

function Trails.trail_gold(root)
	ribbon(root, Color3.fromRGB(255, 206, 80), 2.2, 1.8)
	drift(root, Color3.fromRGB(255, 220, 120), 5, 0.25)
end

-- A small thing that floats beside the shoulder.
local function floater(character, root, size, color, material)
	local p = Instance.new("Part")
	p.Name = "CosmeticPart"
	p.Shape = Enum.PartType.Ball
	p.Size = size
	p.Color = color
	p.Material = material
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = false
	p.CFrame = root.CFrame * CFrame.new(1.9, 2.5, 0.5)
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = p
	weld.C0 = CFrame.new(1.9, 2.5, 0.5)
	weld.Parent = p
	p.Parent = character
	return p
end

local function wing(body, side, color)
	local w = Instance.new("Part")
	w.Name = "Wing"
	w.Size = Vector3.new(0.7, 0.05, 0.6)
	w.Color = color
	w.Material = Enum.Material.Neon
	w.CanCollide = false
	w.CanTouch = false
	w.CanQuery = false
	w.Massless = true
	w.CastShadow = false
	w.CFrame = body.CFrame * CFrame.new(side * 0.36, 0.1, 0) * CFrame.Angles(0, 0, math.rad(side * 28))
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = w
	weld.Parent = w
	w.Parent = body
end

local Companions = {}

function Companions.firefly(character, root)
	local body = floater(character, root, Vector3.new(0.36, 0.36, 0.36), Color3.fromRGB(226, 255, 130), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(226, 255, 150)
	light.Range = 12
	light.Brightness = 1.2
	light.Shadows = false
	light.Parent = body
	local e = Instance.new("ParticleEmitter")
	e.Rate = 4
	e.Lifetime = NumberRange.new(0.6, 1.2)
	e.Speed = NumberRange.new(0.2, 0.8)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 0) })
	e.Color = ColorSequence.new(Color3.fromRGB(226, 255, 150))
	e.LightEmission = 1
	e.Parent = body
end

function Companions.butterfly(character, root)
	local body = floater(character, root, Vector3.new(0.2, 0.2, 0.2), Color3.fromRGB(60, 40, 30), Enum.Material.SmoothPlastic)
	wing(body, -1, Color3.fromRGB(255, 160, 60))
	wing(body, 1, Color3.fromRGB(255, 160, 60))
end

-- Put on (or take off) whatever the player has chosen to wear.
function Cosmetics.apply(player)
	local profile = PlayerData.get(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not profile or not root then
		return
	end
	for _, child in ipairs(root:GetChildren()) do
		if child.Name == "Cosmetic" then
			child:Destroy()
		end
	end
	for _, child in ipairs(character:GetChildren()) do
		if child.Name == "CosmeticPart" then
			child:Destroy()
		end
	end
	local worn = profile.worn or {}
	local trail = worn.trail
	if trail and Trails[trail] and (profile.inv[trail] or 0) > 0 then
		Trails[trail](root)
	end
	local companion = worn.companion
	if companion and Companions[companion] and (profile.inv[companion] or 0) > 0 then
		Companions[companion](character, root)
	end
end

-- Wear this item, or take it off if it is already on.
function Cosmetics.toggle(player, itemId)
	local profile = PlayerData.get(player)
	local def = Config.Items[itemId]
	if not profile or not def or not def.slot or (profile.inv[itemId] or 0) < 1 then
		return
	end
	if profile.worn[def.slot] == itemId then
		profile.worn[def.slot] = nil
	else
		profile.worn[def.slot] = itemId
	end
	Cosmetics.apply(player)
end

-- One of the lantern colours this player owns, or nil for the ordinary warm colours.
function Cosmetics.lanternColor(player, rng)
	local profile = PlayerData.get(player)
	if not profile then
		return nil
	end
	local owned = {}
	for id, def in pairs(Config.Items) do
		if def.lanternColor and (profile.inv[id] or 0) > 0 then
			table.insert(owned, def.lanternColor)
		end
	end
	if #owned == 0 then
		return nil
	end
	table.sort(owned, function(a, b)
		return a[1] * 65536 + a[2] * 256 + a[3] < b[1] * 65536 + b[2] * 256 + b[3]
	end)
	local c = owned[rng:NextInteger(1, #owned)]
	return Color3.fromRGB(c[1], c[2], c[3])
end

return Cosmetics
