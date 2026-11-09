-- Rig: makes people (and Mara's soldiers) out of the standard Roblox character body.
-- One blank body is created when the server starts; every villager, monk and shadow is a
-- copy of it, recoloured and dressed with simple welded pieces (robes, wraps, turbans).

local Players = game:GetService("Players")

local Rig = {}

local template = nil
local fallback = false

local TORSO = { "UpperTorso", "LowerTorso" }
local LEFT_ARM = { "LeftUpperArm", "LeftLowerArm" }
local RIGHT_ARM = { "RightUpperArm", "RightLowerArm" }
local HANDS = { "LeftHand", "RightHand" }
local LEGS = { "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg" }
local FEET = { "LeftFoot", "RightFoot" }

local ANIM = {
	idle = 507766388,
	walk = 507777826,
	run = 507767714,
	sit = 2506281703,
}

local SKIN = {
	Color3.fromRGB(141, 85, 36), Color3.fromRGB(160, 108, 66), Color3.fromRGB(178, 126, 84),
	Color3.fromRGB(124, 76, 40), Color3.fromRGB(196, 146, 100),
}
local BRIGHT = {
	Color3.fromRGB(214, 60, 60), Color3.fromRGB(232, 136, 24), Color3.fromRGB(40, 120, 190),
	Color3.fromRGB(46, 150, 90), Color3.fromRGB(190, 60, 150), Color3.fromRGB(240, 196, 50),
	Color3.fromRGB(120, 60, 170),
}
local WHITE = Color3.fromRGB(238, 234, 224)
local BLACK = Color3.fromRGB(28, 24, 24)
local GREY = Color3.fromRGB(190, 190, 190)
local GOLD = Color3.fromRGB(226, 178, 54)

----------------------------------------------------------------------
-- The blank body
----------------------------------------------------------------------
local function buildFallback()
	-- A very simple figure, used only if Roblox cannot supply the standard body.
	local model = Instance.new("Model")
	local function part(name, size, pos, transparency)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = CFrame.new(pos)
		p.Transparency = transparency or 0
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CanCollide = false
		p.Parent = model
		return p
	end
	local root = part("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), 1)
	root.CanCollide = true
	local pieces = {
		part("LowerTorso", Vector3.new(2, 0.4, 1), Vector3.new(0, 2.2, 0)),
		part("UpperTorso", Vector3.new(2, 1.6, 1), Vector3.new(0, 3.2, 0)),
		part("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 4.6, 0)),
		part("LeftUpperArm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 3, 0)),
		part("RightUpperArm", Vector3.new(1, 2, 1), Vector3.new(1.5, 3, 0)),
		part("LeftUpperLeg", Vector3.new(1, 2, 1), Vector3.new(-0.5, 1, 0)),
		part("RightUpperLeg", Vector3.new(1, 2, 1), Vector3.new(0.5, 1, 0)),
	}
	for _, p in ipairs(pieces) do
		local w = Instance.new("WeldConstraint")
		w.Part0 = root
		w.Part1 = p
		w.Parent = p
	end
	local hum = Instance.new("Humanoid")
	hum.RigType = Enum.HumanoidRigType.R15
	hum.AutomaticScalingEnabled = false
	hum.HipHeight = 2
	hum.RequiresNeck = false
	hum.Parent = model
	model.PrimaryPart = root
	model:SetAttribute("SimpleRig", true)
	return model
end

function Rig.init()
	local ok, result = pcall(function()
		local desc = Instance.new("HumanoidDescription")
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if ok and result and result:FindFirstChild("HumanoidRootPart") and result:FindFirstChildOfClass("Humanoid") then
		template = result
		for _, d in ipairs(template:GetDescendants()) do
			if d:IsA("LuaSourceContainer") or d:IsA("BodyColors") or d:IsA("Clothing") or d:IsA("ShirtGraphic") then
				d:Destroy()
			end
		end
		if not template.PrimaryPart then
			template.PrimaryPart = template:FindFirstChild("HumanoidRootPart")
		end
	else
		warn("[Bodhi Path] Could not create the standard character body; using simple figures instead.", result)
		template = buildFallback()
		fallback = true
	end
	template.Name = "RigTemplate"
end

function Rig.isSimple()
	return fallback
end

----------------------------------------------------------------------
-- Dressing
----------------------------------------------------------------------
local function paint(model, names, color, style)
	for _, name in ipairs(names) do
		local p = model:FindFirstChild(name)
		if p and p:IsA("BasePart") then
			p.Color = color
			if style.material then
				p.Material = style.material
			end
			if style.transparency then
				p.Transparency = style.transparency
			end
		end
	end
end

-- Weld a simple piece onto a body part. shape: nil (block), "ball", "blob"
local function attach(model, baseName, offset, size, color, material, shape)
	local base = model:FindFirstChild(baseName)
	if not base then
		return nil
	end
	local p = Instance.new("Part")
	p.Name = "Dress"
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.Fabric
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.Anchored = false
	if shape == "ball" then
		p.Shape = Enum.PartType.Ball
	elseif shape == "blob" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = p
	end
	p.CFrame = base.CFrame * offset
	local w = Instance.new("WeldConstraint")
	w.Part0 = base
	w.Part1 = p
	w.Parent = p
	p.Parent = model
	return p
end
Rig.attach = attach

local function torsoName(model)
	if model:FindFirstChild("LowerTorso") then
		return "LowerTorso", "UpperTorso"
	end
	return "Torso", "Torso"
end

-- Pieces of clothing. Each is safe to call on any rig.
local Dress = {}

function Dress.wrap(model, color, length)
	local lower = torsoName(model)
	local len = length or 2.1
	local yOff = (lower == "Torso") and (-1 - len / 2) or (-0.15 - len / 2)
	attach(model, lower, CFrame.new(0, yOff, 0), Vector3.new(2.14, len, 1.18), color)
end

function Dress.sash(model, color, leftToRight)
	local _, upper = torsoName(model)
	local angle = leftToRight and -34 or 34
	attach(model, upper, CFrame.new(0, 0.05, 0) * CFrame.Angles(0, 0, math.rad(angle)), Vector3.new(0.55, 2.5, 1.14), color)
end

function Dress.shoulder(model, color)
	local _, upper = torsoName(model)
	attach(model, upper, CFrame.new(-0.72, 0.84, 0), Vector3.new(1.3, 0.3, 1.2), color)
end

function Dress.hair(model, color, style)
	attach(model, "Head", CFrame.new(0, 0.38, 0.06), Vector3.new(1.34, 0.72, 1.34), color, Enum.Material.SmoothPlastic, "blob")
	if style == "bun" then
		attach(model, "Head", CFrame.new(0, 0.3, 0.68), Vector3.new(0.7, 0.7, 0.7), color, Enum.Material.SmoothPlastic, "ball")
	elseif style == "long" then
		attach(model, "Head", CFrame.new(0, -0.3, 0.6), Vector3.new(1.1, 1.3, 0.3), color, Enum.Material.SmoothPlastic)
	elseif style == "topknot" then
		attach(model, "Head", CFrame.new(0, 0.9, 0), Vector3.new(0.72, 0.72, 0.72), color, Enum.Material.SmoothPlastic, "ball")
	end
end

function Dress.turban(model, color)
	attach(model, "Head", CFrame.new(0, 0.5, 0), Vector3.new(1.56, 0.95, 1.56), color, Enum.Material.Fabric, "blob")
	attach(model, "Head", CFrame.new(0, 0.62, -0.7), Vector3.new(0.3, 0.3, 0.3), GOLD, Enum.Material.Metal, "ball")
end

function Dress.beard(model, color, long)
	attach(model, "Head", CFrame.new(0, -0.62 - (long and 0.25 or 0), -0.48), Vector3.new(0.8, long and 1.2 or 0.6, 0.3), color, Enum.Material.SmoothPlastic)
end

function Dress.staff(model, color)
	attach(model, "RightHand", CFrame.new(0, 1.3, -0.35), Vector3.new(0.26, 5.6, 0.26), color or Color3.fromRGB(104, 78, 56), Enum.Material.Wood)
end

function Dress.bindi(model)
	attach(model, "Head", CFrame.new(0, 0.22, -0.6), Vector3.new(0.14, 0.14, 0.14), Color3.fromRGB(200, 30, 40), Enum.Material.SmoothPlastic, "ball")
end

function Dress.crown(model, color)
	attach(model, "Head", CFrame.new(0, 0.72, 0), Vector3.new(1.4, 0.5, 1.4), color or GOLD, Enum.Material.Metal, "blob")
	for i = -1, 1 do
		attach(model, "Head", CFrame.new(i * 0.4, 1.1 - math.abs(i) * 0.12, -0.3), Vector3.new(0.22, 0.7, 0.22), color or GOLD, Enum.Material.Metal)
	end
end

function Dress.horns(model, color)
	attach(model, "Head", CFrame.new(-0.45, 0.8, 0) * CFrame.Angles(0, 0, math.rad(24)), Vector3.new(0.22, 0.9, 0.22), color, Enum.Material.SmoothPlastic)
	attach(model, "Head", CFrame.new(0.45, 0.8, 0) * CFrame.Angles(0, 0, math.rad(-24)), Vector3.new(0.22, 0.9, 0.22), color, Enum.Material.SmoothPlastic)
end

function Dress.eyes(model, color)
	attach(model, "Head", CFrame.new(-0.26, 0.12, -0.58), Vector3.new(0.2, 0.2, 0.2), color, Enum.Material.Neon, "ball")
	attach(model, "Head", CFrame.new(0.26, 0.12, -0.58), Vector3.new(0.2, 0.2, 0.2), color, Enum.Material.Neon, "ball")
end

function Dress.weapon(model, color)
	attach(model, "RightHand", CFrame.new(0, -0.1, -1.7) * CFrame.Angles(math.rad(90), 0, 0), Vector3.new(0.28, 4.8, 0.28), Color3.fromRGB(40, 34, 40), Enum.Material.Wood)
	attach(model, "RightHand", CFrame.new(0, -0.1, -4.3) * CFrame.Angles(math.rad(90), 0, 0), Vector3.new(0.6, 1.3, 0.14), color, Enum.Material.Metal)
end

local function face(model, show)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	local decal = head:FindFirstChildOfClass("Decal")
	if show and not decal then
		decal = Instance.new("Decal")
		decal.Name = "face"
		decal.Face = Enum.NormalId.Front
		decal.Texture = "rbxasset://textures/face.png"
		decal.Parent = head
	elseif not show and decal then
		decal:Destroy()
	end
end

-- Monastic robe: one colour for body and wrap, a sash, right shoulder bare if asked.
local function robe(model, skin, main, sashColor, bare, style)
	paint(model, { "Head" }, skin, style)
	paint(model, HANDS, skin, style)
	paint(model, FEET, skin, style)
	paint(model, TORSO, main, style)
	paint(model, LEGS, main, style)
	paint(model, LEFT_ARM, main, style)
	paint(model, RIGHT_ARM, bare and skin or main, style)
	Dress.wrap(model, main, 2.3)
	Dress.sash(model, sashColor, false)
	Dress.shoulder(model, sashColor)
end
Rig.robe = robe
Rig.Dress = Dress

----------------------------------------------------------------------
-- Looks
----------------------------------------------------------------------
local Looks = {}

local function layman(model, rng, style, top, bottom, bareChest)
	local skin = SKIN[rng:NextInteger(1, #SKIN)]
	paint(model, { "Head" }, skin, style)
	paint(model, HANDS, skin, style)
	paint(model, FEET, skin, style)
	paint(model, LEFT_ARM, skin, style)
	paint(model, RIGHT_ARM, skin, style)
	paint(model, TORSO, bareChest and skin or top, style)
	paint(model, LEGS, skin, style)
	Dress.wrap(model, bottom, 1.9)
	return skin
end

function Looks.abbot(model, rng, style)
	robe(model, SKIN[2], Color3.fromRGB(150, 70, 30), GOLD, true, style)
end
function Looks.monk(model, rng, style)
	robe(model, SKIN[rng:NextInteger(1, #SKIN)], Color3.fromRGB(232, 136, 24), Color3.fromRGB(205, 110, 14), true, style)
end
function Looks.nun(model, rng, style)
	robe(model, SKIN[3], Color3.fromRGB(176, 110, 48), Color3.fromRGB(140, 84, 36), false, style)
end
function Looks.novice(model, rng, style)
	robe(model, SKIN[rng:NextInteger(1, #SKIN)], WHITE, Color3.fromRGB(205, 200, 188), false, style)
	style.scale = 0.78
end
function Looks.merchant(model, rng, style)
	layman(model, rng, style, Color3.fromRGB(236, 222, 190), WHITE, false)
	paint(model, LEFT_ARM, Color3.fromRGB(236, 222, 190), style)
	paint(model, RIGHT_ARM, Color3.fromRGB(236, 222, 190), style)
	Dress.turban(model, Color3.fromRGB(232, 136, 24))
	Dress.sash(model, Color3.fromRGB(150, 44, 34), true)
	Dress.beard(model, BLACK, false)
end
function Looks.villager_m(model, rng, style)
	local top = BRIGHT[rng:NextInteger(1, #BRIGHT)]
	layman(model, rng, style, top, WHITE, rng:NextNumber() < 0.4)
	if rng:NextNumber() < 0.6 then
		Dress.turban(model, BRIGHT[rng:NextInteger(1, #BRIGHT)])
	else
		Dress.hair(model, BLACK)
	end
end
function Looks.villager_f(model, rng, style)
	local sari = BRIGHT[rng:NextInteger(1, #BRIGHT)]
	local trim = BRIGHT[rng:NextInteger(1, #BRIGHT)]
	layman(model, rng, style, trim, sari, false)
	Dress.wrap(model, sari, 2.4)
	Dress.sash(model, sari, true)
	Dress.hair(model, BLACK, "bun")
	Dress.bindi(model)
end
function Looks.farmer(model, rng, style)
	layman(model, rng, style, WHITE, Color3.fromRGB(196, 170, 130), true)
	Dress.turban(model, WHITE)
end
function Looks.elder_m(model, rng, style)
	layman(model, rng, style, WHITE, WHITE, false)
	Dress.hair(model, GREY)
	Dress.beard(model, GREY, true)
	Dress.staff(model)
	style.scale = 0.94
end
function Looks.elder_f(model, rng, style)
	layman(model, rng, style, WHITE, WHITE, false)
	Dress.wrap(model, WHITE, 2.4)
	Dress.sash(model, Color3.fromRGB(214, 200, 170), true)
	Dress.hair(model, GREY, "bun")
	style.scale = 0.92
end
function Looks.child(model, rng, style)
	layman(model, rng, style, BRIGHT[rng:NextInteger(1, #BRIGHT)], BRIGHT[rng:NextInteger(1, #BRIGHT)], false)
	Dress.hair(model, BLACK, (rng:NextNumber() < 0.5) and "bun" or nil)
	style.scale = 0.66
end
function Looks.sick(model, rng, style)
	layman(model, rng, style, Color3.fromRGB(170, 160, 150), Color3.fromRGB(150, 140, 130), true)
	paint(model, { "Head" }, Color3.fromRGB(170, 140, 110), style)
	Dress.hair(model, BLACK)
end
function Looks.mourner(model, rng, style)
	layman(model, rng, style, WHITE, WHITE, false)
	paint(model, LEFT_ARM, WHITE, style)
	paint(model, RIGHT_ARM, WHITE, style)
	Dress.hair(model, BLACK)
end
function Looks.ascetic(model, rng, style)
	layman(model, rng, style, WHITE, Color3.fromRGB(176, 120, 60), true)
	Dress.hair(model, Color3.fromRGB(60, 44, 34), "topknot")
	Dress.beard(model, Color3.fromRGB(60, 44, 34), false)
	style.scale = 0.96
end
function Looks.channa(model, rng, style)
	layman(model, rng, style, Color3.fromRGB(40, 70, 170), WHITE, false)
	paint(model, LEFT_ARM, Color3.fromRGB(40, 70, 170), style)
	paint(model, RIGHT_ARM, Color3.fromRGB(40, 70, 170), style)
	Dress.turban(model, Color3.fromRGB(190, 40, 44))
	Dress.sash(model, GOLD, true)
end
function Looks.sage(model, rng, style)
	robe(model, SKIN[3], Color3.fromRGB(190, 130, 60), Color3.fromRGB(150, 96, 40), true, style)
	Dress.hair(model, WHITE, "topknot")
	Dress.beard(model, WHITE, true)
end
function Looks.sage2(model, rng, style)
	robe(model, SKIN[1], Color3.fromRGB(150, 96, 52), Color3.fromRGB(110, 70, 36), true, style)
	Dress.hair(model, GREY, "topknot")
	Dress.beard(model, GREY, true)
end
function Looks.sujata(model, rng, style)
	local sari = Color3.fromRGB(196, 40, 60)
	layman(model, rng, style, GOLD, sari, false)
	Dress.wrap(model, sari, 2.4)
	Dress.sash(model, GOLD, true)
	Dress.hair(model, BLACK, "bun")
	Dress.bindi(model)
	attach(model, "Head", CFrame.new(0.4, 0.5, 0.6), Vector3.new(0.34, 0.34, 0.34), WHITE, Enum.Material.SmoothPlastic, "ball")
end

-- A soldier of Mara's host: a dark, glowing figure. cfg comes from Config.Enemies.
function Looks.enemy(model, rng, style, cfg)
	local body = Color3.fromRGB(cfg.color[1], cfg.color[2], cfg.color[3])
	local glow = Color3.fromRGB(cfg.glow[1], cfg.glow[2], cfg.glow[3])
	local all = { "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftHand", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg", "LeftFoot", "RightFoot" }
	style.material = Enum.Material.SmoothPlastic
	paint(model, all, body, style)
	face(model, false)
	Dress.eyes(model, glow)
	if cfg.daughter then
		Dress.wrap(model, glow, 2.4)
		Dress.sash(model, GOLD, true)
		Dress.crown(model, GOLD)
		Dress.hair(model, BLACK, "long")
	else
		Dress.horns(model, glow)
		Dress.wrap(model, Color3.fromRGB(30, 26, 32), 1.4)
		Dress.weapon(model, glow)
	end
	local torso = model:FindFirstChild("UpperTorso")
	if torso then
		local light = Instance.new("PointLight")
		light.Color = glow
		light.Range = 10
		light.Brightness = 1.4
		light.Shadows = false
		light.Parent = torso
		local e = Instance.new("ParticleEmitter")
		e.Rate = 8
		e.Lifetime = NumberRange.new(0.8, 1.4)
		e.Speed = NumberRange.new(0.5, 2)
		e.SpreadAngle = Vector2.new(180, 180)
		e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
		e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
		e.Color = ColorSequence.new(glow)
		e.LightEmission = 0.6
		e.Parent = torso
	end
	style.scale = cfg.scale or 1
end

-- Mara himself: crowned, four-armed, armed.
function Looks.mara(model, rng, style)
	local body = Color3.fromRGB(70, 20, 90)
	local glow = Color3.fromRGB(255, 70, 50)
	local all = { "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftHand", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg", "LeftFoot", "RightFoot" }
	paint(model, all, body, style)
	face(model, false)
	Dress.eyes(model, glow)
	Dress.crown(model, GOLD)
	Dress.wrap(model, Color3.fromRGB(120, 16, 30), 2.2)
	Dress.sash(model, GOLD, true)
	Dress.weapon(model, glow)
	local _, upper = torsoName(model)
	for _, sx in ipairs({ -1, 1 }) do
		attach(model, upper, CFrame.new(sx * 1.7, 0.6, 0.2) * CFrame.Angles(0, 0, math.rad(sx * -62)), Vector3.new(0.8, 2.6, 0.8), body, Enum.Material.SmoothPlastic)
		attach(model, upper, CFrame.new(sx * 3, 1.5, 0.2), Vector3.new(0.3, 3.4, 0.3), GOLD, Enum.Material.Metal)
	end
	local torso = model:FindFirstChild(upper)
	if torso then
		local light = Instance.new("PointLight")
		light.Color = glow
		light.Range = 30
		light.Brightness = 2
		light.Shadows = false
		light.Parent = torso
	end
end

----------------------------------------------------------------------
-- Making and animating
----------------------------------------------------------------------
local lookRng = Random.new(77)

-- Make a figure. look = a name in Looks; extra is passed through (enemy settings).
function Rig.make(name, look, extra)
	local model = template:Clone()
	model.Name = name
	local hum = model:FindFirstChildOfClass("Humanoid")
	local style = {}
	face(model, true)
	local fn = Looks[look] or Looks.villager_m
	fn(model, lookRng, style, extra)
	if style.scale and style.scale ~= 1 then
		model:ScaleTo(style.scale)
		if fallback then
			hum.HipHeight = 2 * style.scale
		end
	end
	hum.DisplayName = name
	hum.BreakJointsOnDeath = false
	return model, hum
end

-- Put a figure on the ground at "cf" (a ground-level frame) and add it to the world.
function Rig.place(model, cf, parent)
	local hum = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	local lift = hum.HipHeight + root.Size.Y / 2 + 0.3
	model:PivotTo(cf * CFrame.new(0, lift, 0))
	model.Parent = parent
	pcall(function()
		root:SetNetworkOwner(nil)
	end)
end

-- Give a figure its idle / walk / sit animations. "fast" uses the run cycle.
function Rig.animate(model, fast)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or fallback then
		return nil
	end
	local tracks = nil
	local ok, err = pcall(function()
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = hum
		end
		local function load(id)
			local a = Instance.new("Animation")
			a.AnimationId = "rbxassetid://" .. id
			return animator:LoadAnimation(a)
		end
		local idle = load(ANIM.idle)
		local move = load(fast and ANIM.run or ANIM.walk)
		local sit = load(ANIM.sit)
		tracks = { idle = idle, move = move, sit = sit }
		idle:Play()
		hum.Running:Connect(function(speed)
			if speed > 0.5 then
				if not move.IsPlaying then
					move:Play(0.2)
				end
			elseif move.IsPlaying then
				move:Stop(0.2)
			end
		end)
		hum.Seated:Connect(function(active)
			if active then
				idle:Stop(0.2)
				move:Stop(0.2)
				sit:Play(0.2)
			else
				sit:Stop(0.2)
				idle:Play(0.2)
			end
		end)
	end)
	if not ok then
		warn("[Bodhi Path] Animation setup failed:", err)
	end
	return tracks
end

return Rig
