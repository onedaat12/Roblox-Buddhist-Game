-- World: builds the whole landscape when the server starts.
-- Terrain (ground, hills, rivers), lighting, the gates between zones, the things to
-- collect, and then each zone's own scenery (see ZonesWest and ZonesEast).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))
local Kit = require(script.Parent.Kit)
local Props = require(script.Parent.Props)
local B = require(script.Parent.Buildings)

local C = Kit.C
local M = Enum.Material
local terrain = workspace.Terrain

local World = {}

-- Things other server modules need to find again (bells, wheels, shrines, seats ...).
World.objects = {
	shrines = {},
	wheels = {},
	collectibles = {},
	gates = {},
}

local function V(x, y, z)
	return Vector3.new(x, y, z)
end

----------------------------------------------------------------------
-- Context shared with the zone builders
----------------------------------------------------------------------
local ctx = {}
ctx.rng = Random.new(20261109)
ctx.objects = World.objects
ctx.rivers = {}
ctx.reserved = {}

function ctx.fill(x0, x1, y0, y1, z0, z1, material)
	terrain:FillBlock(CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), V(x1 - x0, y1 - y0, z1 - z0), material)
end

function ctx.reserve(x, z, r)
	table.insert(ctx.reserved, { x, z, r })
end

function ctx.isFree(x, z, r)
	if math.abs(z) < 10 + r then
		return false
	end
	for _, river in ipairs(ctx.rivers) do
		if math.abs(x - river.x) < river.half + r + 4 then
			return false
		end
	end
	for _, gate in ipairs(Config.Gates) do
		if math.abs(x - gate.x) < 6 + r then
			return false
		end
	end
	for _, c in ipairs(ctx.reserved) do
		local dx, dz = x - c[1], z - c[2]
		local rr = c[3] + r
		if dx * dx + dz * dz < rr * rr then
			return false
		end
	end
	return true
end

-- Scatter "count" things between x0 and x1, keeping clear of roads, rivers and buildings.
function ctx.scatter(x0, x1, count, r, fn, zMax)
	local placed, tries = 0, 0
	local limit = zMax or 144
	while placed < count and tries < count * 14 do
		tries = tries + 1
		local x = ctx.rng:NextNumber(x0, x1)
		local z = ctx.rng:NextNumber(-limit, limit)
		if ctx.isFree(x, z, r) then
			ctx.reserve(x, z, r * 0.8)
			fn(Kit.at(x, z, ctx.rng:NextNumber(0, 360)), x, z)
			placed = placed + 1
		end
	end
end

-- A river or stream running across the road (along Z) at the given x.
function ctx.river(x, width, depth)
	local half = width / 2
	ctx.fill(x - half, x + half, -depth, 72, -320, 320, M.Air)
	ctx.fill(x - half - 4, x + half + 4, -depth - 4, -depth, -320, 320, M.Sand)
	ctx.fill(x - half, x + half, -depth, -2, -320, 320, M.Water)
	ctx.fill(x - half - 6, x - half, -4, 0, -170, 170, M.Sand)
	ctx.fill(x + half, x + half + 6, -4, 0, -170, 170, M.Sand)
	table.insert(ctx.rivers, { x = x, half = half })
end

-- A round pond.
function ctx.pond(x, z, radius)
	terrain:FillCylinder(CFrame.new(x, -1, z), 2, radius, M.Air)
	terrain:FillCylinder(CFrame.new(x, -5, z), 6, radius, M.Water)
	ctx.reserve(x, z, radius + 3)
	local n = math.floor(radius * 1.1)
	for i = 0, n - 1 do
		local a = i / n * math.pi * 2
		Kit.block(ctx.root, CFrame.new(x + math.cos(a) * (radius + 1.2), 0.1, z + math.sin(a) * (radius + 1.2)) * CFrame.Angles(0, -a, 0), V(2.4, 1.4, (math.pi * 2 * radius / n) + 1), C.stone, M.Cobblestone)
	end
end

-- A strip of road / paving laid into the ground.
function ctx.pave(x0, x1, z0, z1, material)
	ctx.fill(x0, x1, -3, 0, z0, z1, material)
end

-- Something a player can pick up once. Returns the root part.
function ctx.collectible(kind, id, x, y, z, actionText, objectText)
	local root = Kit.block(ctx.pickups, CFrame.new(x, y, z), V(2.4, 2.4, 2.4), C.goldBright, M.SmoothPlastic, { collide = false, shadow = false, transparency = 1, name = id })
	root.CanQuery = false
	root:SetAttribute("CollectId", id)
	root:SetAttribute("Kind", kind)
	local prompt = Kit.prompt(root, actionText, objectText, 13)
	CollectionService:AddTag(root, "Collectible")
	table.insert(World.objects.collectibles, { id = id, kind = kind, root = root, prompt = prompt })
	return root
end

----------------------------------------------------------------------
-- Lighting and sky
----------------------------------------------------------------------
local function setupLighting()
	Lighting.ClockTime = 8.6
	Lighting.GeographicLatitude = 24.7 -- Bodh Gaya
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(96, 88, 84)
	Lighting.OutdoorAmbient = Color3.fromRGB(140, 132, 120)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 232, 190)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.5
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.3
	Lighting.ExposureCompensation = 0.1

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.2
	atmosphere.Color = Color3.fromRGB(222, 206, 178)
	atmosphere.Decay = Color3.fromRGB(150, 120, 92)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.4
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.35
	bloom.Size = 30
	bloom.Threshold = 1.1
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "Mood"
	cc.Saturation = 0.12
	cc.Contrast = 0.06
	cc.TintColor = Color3.fromRGB(255, 244, 228)
	cc.Parent = Lighting

	local rays = Instance.new("SunRaysEffect")
	rays.Intensity = 0.08
	rays.Spread = 0.6
	rays.Parent = Lighting

	terrain.WaterColor = Color3.fromRGB(58, 132, 140)
	terrain.WaterTransparency = 0.45
	terrain.WaterReflectance = 0.25
	terrain.WaterWaveSize = 0.12
	terrain.WaterWaveSpeed = 8
end

----------------------------------------------------------------------
-- Ground, hills, distant mountains, outer walls
----------------------------------------------------------------------
local hillMaterial = {
	village = M.Grass, road = M.Grass, anoma = M.Grass, forest = M.LeafyGrass,
	uruvela = M.Sandstone, senani = M.Grass, mara = M.Basalt, bodhgaya = M.Grass,
}

local function zoneAt(x)
	for _, z in ipairs(Config.Zones) do
		if x >= z.x0 and x < z.x1 then
			return z
		end
	end
	if x < Config.Zones[1].x0 then
		return Config.Zones[1]
	end
	return Config.Zones[#Config.Zones]
end
World.zoneAt = zoneAt

local function buildGround()
	local rng = ctx.rng
	for i, zone in ipairs(Config.Zones) do
		local x0, x1 = zone.x0, zone.x1
		if i == 1 then
			x0 = x0 - 120
		end
		if i == #Config.Zones then
			x1 = x1 + 120
		end
		ctx.fill(x0, x1, -28, 0, -330, 330, M[zone.ground])
	end
	-- ridges along both sides
	local x = Config.WorldStart - 60
	while x < Config.WorldEnd + 60 do
		local zone = zoneAt(x)
		for _, side in ipairs({ -1, 1 }) do
			local r = rng:NextNumber(52, 78)
			local cx = x + rng:NextNumber(-10, 10)
			terrain:FillBall(V(cx, -12, side * (153 + r)), r, hillMaterial[zone.id])
			if rng:NextNumber() < 0.5 then
				terrain:FillBall(V(cx + rng:NextNumber(-14, 14), r * 0.55, side * (190 + r)), r * 0.62, M.Rock)
			end
		end
		x = x + 40
	end
	-- close off both ends of the valley
	for _, endX in ipairs({ Config.WorldStart - 40, Config.WorldEnd + 72 }) do
		local zone = zoneAt(endX)
		local z = -230
		while z <= 230 do
			terrain:FillBall(V(endX + rng:NextNumber(-8, 8), -10, z), rng:NextNumber(50, 66), hillMaterial[zone.id])
			z = z + 46
		end
	end
	-- the Himalaya, far to the north (simple distant shapes)
	local far = Kit.folder(ctx.root, "Mountains")
	local mx = Config.WorldStart - 200
	while mx < Config.WorldEnd + 300 do
		local size = rng:NextNumber(260, 420)
		local dist = rng:NextNumber(820, 1000) * ((rng:NextNumber() < 0.3) and -1 or 1)
		local cf = CFrame.new(mx, -size * 0.18, dist) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 90)), 0) * CFrame.Angles(math.rad(45), 0, math.rad(35.26))
		Kit.block(far, cf, V(size, size, size), Color3.fromRGB(112, 124, 150), M.Slate, { collide = false, shadow = false })
		Kit.block(far, cf * CFrame.new(size * 0.19, size * 0.19, size * 0.19), V(size * 0.64, size * 0.64, size * 0.64), Color3.fromRGB(238, 242, 250), M.Snow, { collide = false, shadow = false })
		mx = mx + rng:NextNumber(170, 250)
	end
	-- invisible walls so nobody leaves the valley
	local length = Config.WorldEnd - Config.WorldStart + 40
	local midX = (Config.WorldStart + Config.WorldEnd) / 2
	local limits = Kit.folder(ctx.root, "Limits")
	local hidden = { transparency = 1, shadow = false, name = "Limit" }
	Kit.block(limits, CFrame.new(midX, 110, Config.HalfWidth + 40), V(length, 260, 4), C.stone, M.SmoothPlastic, hidden)
	Kit.block(limits, CFrame.new(midX, 110, -Config.HalfWidth - 40), V(length, 260, 4), C.stone, M.SmoothPlastic, hidden)
	Kit.block(limits, CFrame.new(Config.WorldStart + 6, 110, 0), V(4, 260, 400), C.stone, M.SmoothPlastic, hidden)
	Kit.block(limits, CFrame.new(Config.WorldEnd - 4, 110, 0), V(4, 260, 400), C.stone, M.SmoothPlastic, hidden)
end

----------------------------------------------------------------------
-- Gates between zones
----------------------------------------------------------------------
local function buildGates()
	local folder = Kit.folder(ctx.root, "Gates")
	for _, gate in ipairs(Config.Gates) do
		local zone = zoneAt(gate.x + 1)
		local dark = zone.id == "mara"
		local stone = dark and Color3.fromRGB(70, 62, 70) or C.sandstone
		B.torana(folder, Kit.at(gate.x, 0, 90), 22, 24, stone)
		B.wall(folder, gate.x, 12.4, gate.x, Config.HalfWidth + 44, 18, stone, M.Sandstone)
		B.wall(folder, gate.x, -12.4, gate.x, -Config.HalfWidth - 44, 18, stone, M.Sandstone)
		local barrier = Kit.block(folder, CFrame.new(gate.x, 20, 0), V(2.4, 40, 22.4), C.gold, M.SmoothPlastic, { transparency = 1, shadow = false, name = "GateBarrier" })
		barrier:SetAttribute("GateId", gate.id)
		barrier:SetAttribute("MinStage", Story.QuestIndex[gate.quest])
		CollectionService:AddTag(barrier, "GateBarrier")
		local veil = Kit.block(folder, CFrame.new(gate.x, 8.2, 0), V(0.3, 16.4, 19.2), C.goldBright, M.Neon, { transparency = 0.72, shadow = false, collide = false, name = "GateVeil" })
		veil:SetAttribute("GateId", gate.id)
		veil:SetAttribute("MinStage", Story.QuestIndex[gate.quest])
		CollectionService:AddTag(veil, "GateVeil")
		World.objects.gates[gate.id] = { barrier = barrier, veil = veil, x = gate.x }
		ctx.reserve(gate.x, 0, 16)
	end
end

----------------------------------------------------------------------
-- Shrines and things to collect
----------------------------------------------------------------------
local function buildShrines()
	local folder = Kit.folder(ctx.root, "Shrines")
	for _, s in ipairs(Config.Shrines) do
		local _, plinth = B.shrine(folder, Kit.at(s.x, s.z, 0), s.name)
		World.objects.shrines[s.id] = plinth
		ctx.reserve(s.x, s.z, 11)
	end
end

local function buildCollectibles()
	ctx.pickups = Kit.folder(workspace, "Pickups")
	-- Bodhi leaves, each carrying a teaching
	for i, p in ipairs(Config.Leaves) do
		local y = (p.y or 0) + 3.4
		local root = ctx.collectible("leaf", "leaf_" .. i, p.x, y, p.z, "Read", "Bodhi Leaf")
		local leaf = Kit.blob(root, CFrame.new(p.x, y, p.z) * CFrame.Angles(math.rad(25), math.rad(i * 37), math.rad(20)), V(1.7, 0.25, 2.3), Color3.fromRGB(190, 220, 110), M.Neon, { collide = false, shadow = false })
		Kit.block(root, leaf.CFrame * CFrame.new(0, 0, 1.5), V(0.12, 0.12, 1.2), C.gold, M.Neon, { collide = false, shadow = false })
		Kit.sparkle(root, C.goldBright, 7)
		Kit.light(root, Color3.fromRGB(230, 240, 150), 14, 1.2)
		ctx.reserve(p.x, p.z, 4)
	end
	-- kusa grass on the east bank of the Neranjara
	for i, p in ipairs(Config.Kusa) do
		local root = ctx.collectible("kusa", "kusa_" .. i, p.x, 1.6, p.z, "Gather", "Kusa Grass")
		for k = 1, 7 do
			local cf = CFrame.new(p.x + ctx.rng:NextNumber(-1.2, 1.2), 0, p.z + ctx.rng:NextNumber(-1.2, 1.2)) * CFrame.Angles(math.rad(ctx.rng:NextNumber(-14, 14)), math.rad(ctx.rng:NextNumber(0, 180)), math.rad(ctx.rng:NextNumber(-14, 14)))
			Kit.block(root, cf * CFrame.new(0, 1.9, 0), V(0.22, 3.8, 0.5), (k % 2 == 0) and Color3.fromRGB(160, 190, 90) or Color3.fromRGB(128, 168, 76), M.Grass, { collide = false, shadow = false })
		end
		Kit.sparkle(root, Color3.fromRGB(200, 240, 140), 3)
		ctx.reserve(p.x, p.z, 4)
	end
	-- lotus flowers in the ponds
	for i, p in ipairs(Config.Lotus) do
		local root = ctx.collectible("lotus", "lotus_" .. i, p.x, -0.4, p.z, "Pick", "Lotus Flower")
		Props.lotus(root, CFrame.new(p.x, -0.95, p.z), (i % 2 == 0) and C.lotusWhite or C.lotusPink, true)
	end
end

----------------------------------------------------------------------
-- Build everything
----------------------------------------------------------------------
function World.build()
	local started = os.clock()
	ctx.root = Kit.folder(workspace, "World")
	ctx.Config = Config
	ctx.Story = Story

	setupLighting()
	buildGround()

	-- where players first appear
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Arrival"
	spawn.Anchored = true
	spawn.Size = V(12, 1, 12)
	spawn.CFrame = CFrame.new(Config.Places.spawn.x, 0.2, Config.Places.spawn.z) * CFrame.Angles(0, math.rad(-90), 0)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = ctx.root
	World.objects.spawn = spawn

	-- keep scenery away from the people and places of the story
	for _, npc in ipairs(Story.NPCs) do
		ctx.reserve(npc.x, npc.z, 5)
	end
	for _, s in ipairs(Config.MeditationSpots) do
		ctx.reserve(s.x, s.z, 8)
	end
	for _, p in ipairs(Config.Leaves) do
		ctx.reserve(p.x, p.z, 5)
	end
	for _, p in ipairs(Config.Kusa) do
		ctx.reserve(p.x, p.z, 5)
	end
	for _, s in ipairs(Config.Spawns) do
		ctx.reserve(s.x, s.z, 4)
	end

	-- rivers first, so that everything else can keep clear of them
	ctx.river(122, 12, 6)
	ctx.river(456, 12, 6)
	ctx.river(Config.Places.anoma_river.x, Config.Places.anoma_river.width, 10)
	ctx.river(1040, 12, 6)
	ctx.river(Config.Places.neranjara.x, Config.Places.neranjara.width, 10)

	buildGates()
	buildShrines()

	local west = require(script.Parent.ZonesWest)
	local east = require(script.Parent.ZonesEast)
	west.build(ctx)
	east.build(ctx)

	buildCollectibles()

	print(string.format("[Bodhi Path] World built in %.2f seconds", os.clock() - started))
end

World.ctx = ctx

return World
