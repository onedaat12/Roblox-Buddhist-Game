-- Fx: what the world looks like for this player.
-- Visual effects, the changing light of each zone, which gates are open, and which
-- things have already been collected.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local Fx = {}

local player = Players.LocalPlayer

----------------------------------------------------------------------
-- Effects in the world
----------------------------------------------------------------------
local function tempPart(pos, size)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Transparency = 1
	p.Size = size or Vector3.new(1, 1, 1)
	p.CFrame = CFrame.new(pos)
	p.Parent = workspace
	return p
end

-- A burst of petals: what is left when a shadow is dispelled.
function Fx.petals(data)
	local p = tempPart(data.pos, Vector3.new(2, 2, 2))
	local e = Instance.new("ParticleEmitter")
	e.Rate = 0
	e.Lifetime = NumberRange.new(1.2, 2.2)
	e.Speed = NumberRange.new(6, 14)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Acceleration = Vector3.new(0, -9, 0)
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-180, 180)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0.2) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.1), NumberSequenceKeypoint.new(1, 1) })
	e.Color = ColorSequence.new(Color3.fromRGB(255, 196, 214), data.color or Color3.fromRGB(255, 220, 150))
	e.LightEmission = 0.3
	e.Parent = p
	e:Emit(data.big and 70 or 26)
	Debris:AddItem(p, 3)
end

-- An expanding ring of light (Metta, the singing bowl, the temple bell).
function Fx.ring(data)
	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanTouch = false
	ring.CanQuery = false
	ring.CastShadow = false
	ring.Material = Enum.Material.Neon
	ring.Color = data.color or Color3.fromRGB(255, 220, 130)
	ring.Transparency = 0.45
	ring.Size = Vector3.new(0.4, 2, 2)
	ring.CFrame = CFrame.new(data.pos.X, data.pos.Y - 2, data.pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = workspace
	local d = (data.radius or 20) * 2
	TweenService:Create(ring, TweenInfo.new(data.time or 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.4, d, d), Transparency = 1 }):Play()
	Debris:AddItem(ring, (data.time or 0.8) + 0.2)
end

-- A number that floats up where a strike landed.
function Fx.hit(data)
	local p = tempPart(data.pos)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 90, 0, 36)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 24
	label.TextColor3 = Color3.fromRGB(255, 226, 150)
	label.TextStrokeTransparency = 0.3
	label.Text = tostring(data.amount)
	label.Parent = gui
	gui.Parent = p
	TweenService:Create(p, TweenInfo.new(0.7), { CFrame = CFrame.new(data.pos + Vector3.new(0, 4, 0)) }):Play()
	TweenService:Create(label, TweenInfo.new(0.7), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(p, 0.8)
end

function Fx.shake(seconds, strength)
	local camera = workspace.CurrentCamera
	local character = player.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if not camera or not hum then
		return
	end
	task.spawn(function()
		local t = 0
		while t < seconds do
			local k = strength * (1 - t / seconds)
			hum.CameraOffset = Vector3.new((math.random() - 0.5) * k, (math.random() - 0.5) * k, 0)
			t = t + task.wait(0.03)
		end
		hum.CameraOffset = Vector3.new(0, 0, 0)
	end)
end

----------------------------------------------------------------------
-- The light of each zone
----------------------------------------------------------------------
local MOODS = {
	morning = { clock = 8.6, bright = 2.6, tint = Color3.fromRGB(255, 244, 228), air = Color3.fromRGB(222, 206, 178), density = 0.3, haze = 1.4, ambient = Color3.fromRGB(140, 132, 120) },
	day = { clock = 11.2, bright = 2.8, tint = Color3.fromRGB(255, 250, 238), air = Color3.fromRGB(214, 214, 200), density = 0.28, haze = 1.2, ambient = Color3.fromRGB(146, 142, 134) },
	forest = { clock = 14.6, bright = 2.1, tint = Color3.fromRGB(226, 246, 220), air = Color3.fromRGB(160, 186, 150), density = 0.42, haze = 1.8, ambient = Color3.fromRGB(104, 126, 104) },
	harsh = { clock = 12.6, bright = 3.3, tint = Color3.fromRGB(255, 244, 210), air = Color3.fromRGB(232, 210, 168), density = 0.36, haze = 2.4, ambient = Color3.fromRGB(160, 146, 120) },
	golden = { clock = 16.9, bright = 2.5, tint = Color3.fromRGB(255, 232, 196), air = Color3.fromRGB(240, 196, 150), density = 0.32, haze = 1.6, ambient = Color3.fromRGB(150, 126, 104) },
	storm = { clock = 18.4, bright = 1.1, tint = Color3.fromRGB(206, 176, 226), air = Color3.fromRGB(70, 44, 84), density = 0.5, haze = 2.6, ambient = Color3.fromRGB(84, 64, 96) },
	night = { clock = 19.6, bright = 1.5, tint = Color3.fromRGB(196, 210, 255), air = Color3.fromRGB(60, 70, 110), density = 0.34, haze = 1.4, ambient = Color3.fromRGB(88, 96, 130) },
	dawn = { clock = 6.5, bright = 2.8, tint = Color3.fromRGB(255, 236, 200), air = Color3.fromRGB(255, 206, 150), density = 0.3, haze = 1.6, ambient = Color3.fromRGB(160, 140, 120) },
}

local currentMood = nil

function Fx.setMood(name, seconds)
	local mood = MOODS[name]
	if not mood or currentMood == name then
		return
	end
	currentMood = name
	local info = TweenInfo.new(seconds or 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(Lighting, info, { ClockTime = mood.clock, Brightness = mood.bright, OutdoorAmbient = mood.ambient }):Play()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		TweenService:Create(atmosphere, info, { Color = mood.air, Density = mood.density, Haze = mood.haze }):Play()
	end
	local cc = Lighting:FindFirstChild("Mood")
	if cc then
		TweenService:Create(cc, info, { TintColor = mood.tint }):Play()
	end
end

function Fx.zoneAt(x)
	for _, zone in ipairs(Config.Zones) do
		if x >= zone.x0 and x < zone.x1 then
			return zone
		end
	end
	if x < Config.Zones[1].x0 then
		return Config.Zones[1]
	end
	return Config.Zones[#Config.Zones]
end

----------------------------------------------------------------------
-- Gates and collected things (seen differently by each player)
----------------------------------------------------------------------
local stage = 1
local gone = {}

local function applyGate(part)
	local min = part:GetAttribute("MinStage") or 1
	local open = stage >= min
	if part.Name == "GateBarrier" then
		part.CanCollide = not open
	else
		part.Transparency = open and 1 or 0.72
	end
end

local function applyCollectible(root)
	local id = root:GetAttribute("CollectId")
	local hide = id ~= nil and gone[id] == true
	if root:GetAttribute("Hidden") == hide then
		return
	end
	root:SetAttribute("Hidden", hide)
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") then
			d.LocalTransparencyModifier = hide and 1 or 0
		elseif d:IsA("ParticleEmitter") or d:IsA("PointLight") or d:IsA("ProximityPrompt") then
			d.Enabled = not hide
		end
	end
end

function Fx.refreshWorld(state)
	stage = state.stage or 1
	gone = {}
	for id in pairs(state.leaves or {}) do
		gone[id] = true
	end
	for id in pairs(state.collected or {}) do
		gone[id] = true
	end
	for id in pairs(state.lotus or {}) do
		gone[id] = true
	end
	for _, part in ipairs(CollectionService:GetTagged("GateBarrier")) do
		applyGate(part)
	end
	for _, part in ipairs(CollectionService:GetTagged("GateVeil")) do
		applyGate(part)
	end
	for _, root in ipairs(CollectionService:GetTagged("Collectible")) do
		applyCollectible(root)
	end
end

CollectionService:GetInstanceAddedSignal("GateBarrier"):Connect(applyGate)
CollectionService:GetInstanceAddedSignal("GateVeil"):Connect(applyGate)
CollectionService:GetInstanceAddedSignal("Collectible"):Connect(applyCollectible)

return Fx
