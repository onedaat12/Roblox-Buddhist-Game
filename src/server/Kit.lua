-- Kit: small helpers for building the world out of simple parts.
-- Every structure in the game is assembled from these (blocks, cylinders, balls),
-- so nothing has to be made by hand in Roblox Studio.

local Kit = {}

local function rgb(c)
	return Color3.fromRGB(c[1], c[2], c[3])
end
Kit.rgb = rgb

-- A shared palette so the whole world keeps one look.
Kit.C = {
	sandstone = Color3.fromRGB(214, 178, 128),
	sandstoneDark = Color3.fromRGB(176, 138, 94),
	sandstoneLight = Color3.fromRGB(234, 208, 164),
	redstone = Color3.fromRGB(168, 84, 62),
	brick = Color3.fromRGB(170, 96, 70),
	mud = Color3.fromRGB(196, 160, 118),
	mudDark = Color3.fromRGB(150, 116, 84),
	white = Color3.fromRGB(240, 236, 226),
	ivory = Color3.fromRGB(226, 216, 194),
	gold = Color3.fromRGB(226, 178, 54),
	goldBright = Color3.fromRGB(255, 214, 96),
	bronze = Color3.fromRGB(150, 104, 54),
	wood = Color3.fromRGB(122, 84, 52),
	woodDark = Color3.fromRGB(84, 56, 36),
	woodRed = Color3.fromRGB(150, 44, 34),
	thatch = Color3.fromRGB(196, 164, 92),
	terracotta = Color3.fromRGB(190, 98, 62),
	tileTeal = Color3.fromRGB(44, 92, 96),
	tileGrey = Color3.fromRGB(70, 74, 82),
	stone = Color3.fromRGB(136, 134, 128),
	stoneDark = Color3.fromRGB(92, 90, 88),
	leaf = Color3.fromRGB(74, 128, 62),
	leafDark = Color3.fromRGB(48, 98, 52),
	leafLight = Color3.fromRGB(118, 160, 72),
	leafDry = Color3.fromRGB(146, 142, 78),
	bamboo = Color3.fromRGB(128, 164, 76),
	trunk = Color3.fromRGB(104, 78, 56),
	trunkPale = Color3.fromRGB(150, 130, 104),
	lotusPink = Color3.fromRGB(240, 150, 190),
	lotusWhite = Color3.fromRGB(250, 236, 240),
	saffron = Color3.fromRGB(232, 136, 24),
	maroon = Color3.fromRGB(122, 28, 40),
	flagBlue = Color3.fromRGB(40, 90, 200),
	flagWhite = Color3.fromRGB(245, 245, 245),
	flagRed = Color3.fromRGB(205, 44, 44),
	flagGreen = Color3.fromRGB(46, 150, 70),
	flagYellow = Color3.fromRGB(240, 200, 40),
	water = Color3.fromRGB(64, 140, 150),
	ash = Color3.fromRGB(60, 56, 60),
	ember = Color3.fromRGB(255, 120, 40),
	bone = Color3.fromRGB(214, 206, 186),
	black = Color3.fromRGB(26, 24, 28),
}

Kit.FlagColors = { Kit.C.flagBlue, Kit.C.flagWhite, Kit.C.flagRed, Kit.C.flagGreen, Kit.C.flagYellow }

local function toCF(v)
	if typeof(v) == "Vector3" then
		return CFrame.new(v)
	end
	return v
end
Kit.toCF = toCF

local function apply(part, opts)
	if not opts then
		return
	end
	if opts.collide ~= nil then
		part.CanCollide = opts.collide
	end
	if opts.shadow ~= nil then
		part.CastShadow = opts.shadow
	end
	if opts.transparency then
		part.Transparency = opts.transparency
	end
	if opts.reflectance then
		part.Reflectance = opts.reflectance
	end
	if opts.name then
		part.Name = opts.name
	end
	if opts.anchored ~= nil then
		part.Anchored = opts.anchored
	end
	if opts.touch ~= nil then
		part.CanTouch = opts.touch
	end
	if opts.query ~= nil then
		part.CanQuery = opts.query
	end
end

local function base(shape, size, cf, color, material)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Shape = shape
	p.Size = size
	p.CFrame = cf
	p.Color = color or Kit.C.stone
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanTouch = false
	return p
end

-- A box.
function Kit.block(parent, cf, size, color, material, opts)
	local p = base(Enum.PartType.Block, size, toCF(cf), color, material)
	apply(p, opts)
	p.Parent = parent
	return p
end

-- An upright cylinder: "cf" is its centre, its axis follows cf's up direction.
function Kit.cyl(parent, cf, diameter, height, color, material, opts)
	local p = base(Enum.PartType.Cylinder, Vector3.new(height, diameter, diameter), toCF(cf) * CFrame.Angles(0, 0, math.rad(90)), color, material)
	apply(p, opts)
	p.Parent = parent
	return p
end

-- A perfect ball.
function Kit.ball(parent, cf, diameter, color, material, opts)
	local p = base(Enum.PartType.Ball, Vector3.new(diameter, diameter, diameter), toCF(cf), color, material)
	apply(p, opts)
	p.Parent = parent
	return p
end

-- A stretched ball (egg / dome / leaf-cloud shapes).
function Kit.blob(parent, cf, size, color, material, opts)
	local p = base(Enum.PartType.Block, size, toCF(cf), color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	apply(p, opts)
	p.Parent = parent
	return p
end

function Kit.model(parent, name)
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

function Kit.folder(parent, name)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

-- A ground-level frame at (x, z), turned by "yaw" degrees. Structures treat -Z as their front.
function Kit.at(x, z, yaw, y)
	return CFrame.new(x, y or 0, z) * CFrame.Angles(0, math.rad(yaw or 0), 0)
end

-- Yaw (degrees) that makes a structure's front face the given direction.
Kit.FACE_NEG_Z = 0
Kit.FACE_POS_Z = 180
Kit.FACE_POS_X = -90
Kit.FACE_NEG_X = 90

-- Yaw that makes a structure at (x, z) face the point (tx, tz).
function Kit.yawToward(x, z, tx, tz)
	local dx, dz = tx - x, tz - z
	return math.deg(math.atan2(-dx, -dz))
end

function Kit.light(parent, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Color = color or Color3.fromRGB(255, 200, 130)
	l.Range = range or 16
	l.Brightness = brightness or 1.2
	l.Shadows = false
	l.Parent = parent
	return l
end

function Kit.fire(parent, size, heat)
	local f = Instance.new("Fire")
	f.Size = size or 4
	f.Heat = heat or 8
	f.Parent = parent
	return f
end

function Kit.smoke(parent, color)
	local e = Instance.new("ParticleEmitter")
	e.Rate = 4
	e.Lifetime = NumberRange.new(3, 5)
	e.Speed = NumberRange.new(1, 2)
	e.SpreadAngle = Vector2.new(12, 12)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 2.2) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) })
	e.Color = ColorSequence.new(color or Color3.fromRGB(230, 225, 215))
	e.LightEmission = 0.1
	e.Parent = parent
	return e
end

function Kit.sparkle(parent, color, rate)
	local e = Instance.new("ParticleEmitter")
	e.Rate = rate or 6
	e.Lifetime = NumberRange.new(1.2, 2)
	e.Speed = NumberRange.new(0.5, 1.5)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
	e.Color = ColorSequence.new(color or Kit.C.goldBright)
	e.LightEmission = 0.8
	e.Parent = parent
	return e
end

-- A floating label that always faces the camera (used for signs and markers).
function Kit.sign(parent, text, color, height, maxDistance, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Sign"
	gui.Size = size or UDim2.new(0, 220, 0, 44)
	gui.StudsOffset = Vector3.new(0, height or 4, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = maxDistance or 110
	gui.LightInfluence = 0
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Kit.C.goldBright
	label.TextStrokeColor3 = Color3.fromRGB(40, 20, 10)
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.Fondamento
	label.TextScaled = true
	label.Parent = gui
	gui.Parent = parent
	return gui
end

-- An interaction prompt (works with keyboard, touch and gamepad).
function Kit.prompt(parent, action, object, distance, hold)
	local p = Instance.new("ProximityPrompt")
	p.ActionText = action
	p.ObjectText = object or ""
	p.MaxActivationDistance = distance or 12
	p.HoldDuration = hold or 0
	p.RequiresLineOfSight = false
	p.Parent = parent
	return p
end

-- Weld "part" to "to", keeping where it is now.
function Kit.weld(part, to)
	local w = Instance.new("WeldConstraint")
	w.Part0 = to
	w.Part1 = part
	w.Parent = part
	return w
end

return Kit
