-- ZonesWest: the first half of the journey.
-- Kapilavastu (home temple and village), the Road of the Four Sights,
-- the River Anoma, and the Forest of the Teachers.

local Kit = require(script.Parent.Kit)
local Props = require(script.Parent.Props)
local B = require(script.Parent.Buildings)
local Garden = require(script.Parent.Garden)

local C = Kit.C
local M = Enum.Material

local Zones = {}

local function V(x, y, z)
	return Vector3.new(x, y, z)
end

local FLOWER = {
	Color3.fromRGB(240, 150, 30), Color3.fromRGB(236, 80, 90), Color3.fromRGB(250, 220, 80),
	Color3.fromRGB(240, 240, 240), Color3.fromRGB(190, 110, 220),
}

----------------------------------------------------------------------
-- Kapilavastu: the monastery and the village
----------------------------------------------------------------------
local function village(ctx)
	local root = Kit.folder(ctx.root, "Kapilavastu")
	local rng = ctx.rng
	local P = ctx.Config.Places

	-- paving
	ctx.pave(-50, 104, -36, 36, M.Limestone)
	ctx.pave(-27, -13, 36, 66, M.Limestone)
	ctx.pave(5, 19, -46, -36, M.Limestone)
	ctx.pave(104, 116, -7, 7, M.Limestone)
	ctx.pave(128, 258, -8, 8, M.Cobblestone)
	ctx.pave(154, 166, 8, 46, M.Cobblestone)
	ctx.pave(198, 210, -46, -8, M.Cobblestone)

	-- compound wall with the main gateway on the east side
	local wx0, wx1, wz = -136, 106, 126
	B.wall(root, wx0, -wz, wx1, -wz, 9, C.ivory, M.Sandstone)
	B.wall(root, wx0, wz, wx1, wz, 9, C.ivory, M.Sandstone)
	B.wall(root, wx0, -wz, wx0, wz, 9, C.ivory, M.Sandstone)
	B.wall(root, wx1, -wz, wx1, -11.5, 9, C.ivory, M.Sandstone)
	B.wall(root, wx1, 11.5, wx1, wz, 9, C.ivory, M.Sandstone)
	B.torana(root, Kit.at(wx1, 0, 90), 20, 20)
	ctx.reserve(wx1, 0, 14)

	-- the great temple
	B.temple(root, Kit.at(P.temple.x, P.temple.z, Kit.FACE_POS_X))
	ctx.reserve(P.temple.x, P.temple.z, 48)
	Props.incenseBurner(root, Kit.at(-36, -9, 0))
	ctx.reserve(-36, -9, 3)

	-- meditation hall
	B.hall(root, Kit.at(P.hall.x, P.hall.z, 0))
	ctx.reserve(P.hall.x, P.hall.z, 34)

	-- bell
	local _, bell, striker = B.bellPavilion(root, Kit.at(P.temple_bell.x, P.temple_bell.z, 0))
	ctx.objects.bell = bell
	ctx.objects.striker = striker
	ctx.reserve(P.temple_bell.x, P.temple_bell.z, 14)

	-- prayer wheels
	local _, wheels = B.prayerWheels(root, Kit.at(P.wheels.x, P.wheels.z, 0), 8)
	for _, w in ipairs(wheels) do
		table.insert(ctx.objects.wheels, w)
	end
	ctx.reserve(P.wheels.x, P.wheels.z, 20)

	-- lotus pond
	ctx.pond(P.lotus_pond.x, P.lotus_pond.z, 20)
	for i = 1, 9 do
		local a = i * 0.7
		local r = 5 + (i % 4) * 3.4
		Props.lotus(root, CFrame.new(P.lotus_pond.x + math.cos(a) * r, -0.95, P.lotus_pond.z + math.sin(a) * r), (i % 3 == 0) and C.lotusWhite or C.lotusPink, i % 2 == 0)
	end

	-- pagoda, monks' quarters, refectory
	B.pagoda(root, Kit.at(-104, -84, 0), 5, 22, C.tileGrey)
	ctx.reserve(-104, -84, 24)
	B.house(root, Kit.at(-116, 36, Kit.FACE_POS_X), { w = 20, d = 14, roof = "flat", wall = C.ivory, band = C.maroon, name = "MonksQuarters" })
	B.house(root, Kit.at(-116, 62, Kit.FACE_POS_X), { w = 20, d = 14, roof = "flat", wall = C.ivory, band = C.maroon, name = "MonksQuarters" })
	ctx.reserve(-116, 36, 15)
	ctx.reserve(-116, 62, 15)
	B.house(root, Kit.at(72, 96, 0), { w = 30, d = 20, h = 11, roof = "tile", wall = C.ivory, band = C.saffron, name = "Refectory" })
	ctx.reserve(72, 96, 22)

	-- stone lanterns and prayer flags along the courtyard
	for _, x in ipairs({ -36, -12, 12, 36, 60, 84 }) do
		for _, z in ipairs({ -22, 22 }) do
			Props.lantern(root, Kit.at(x, z, 0))
			ctx.reserve(x, z, 3)
		end
	end
	Props.flags(root, V(-65.5, 34, 0), V(-12, 12, -30), "end")
	Props.flags(root, V(-65.5, 34, 0), V(-12, 12, 30), "end")
	Props.flags(root, V(60, 13, -36), V(100, 13, -36), true)
	Props.flags(root, V(60, 13, 36), V(100, 13, 36), true)

	-- the temple elephant
	Props.elephant(root, Kit.at(84, -66, Kit.FACE_NEG_X), 0.8, nil, { cloth = C.maroon })
	ctx.reserve(84, -66, 14)

	-- the Pilgrims' Garden: a place to meet, south of the courtyard
	Garden.build(ctx, root)

	-- trees and flowers inside the compound
	ctx.scatter(-128, 100, 16, 9, function(o)
		if rng:NextNumber() < 0.5 then
			Props.sal(root, o, rng:NextNumber(0.8, 1.1))
		else
			Props.roundTree(root, o, rng:NextNumber(0.9, 1.3))
		end
	end, 118)
	ctx.scatter(-128, 100, 24, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end, 118)

	-- the stream and the bridge to the village
	B.bridge(root, Kit.at(122, 0, 90), 26, 12, C.wood)

	-- village
	B.shop(root, Kit.at(P.store.x, P.store.z, Kit.FACE_NEG_Z), "The Merit Store", { awning = C.saffron })
	ctx.reserve(P.store.x, P.store.z, 24)
	B.shop(root, Kit.at(P.tailor.x, P.tailor.z, Kit.FACE_POS_Z), "Visakha's Robes", { awning = C.maroon, wall = C.mud, band = C.maroon, goods = { C.saffron, C.maroon, Color3.fromRGB(128, 130, 134), C.black, C.white, Color3.fromRGB(150, 92, 38) } })
	ctx.reserve(P.tailor.x, P.tailor.z, 24)

	local houses = {
		{ 146, -54, Kit.FACE_POS_Z, "thatch", C.mud },
		{ 244, -56, Kit.FACE_POS_Z, "flat", C.ivory },
		{ 212, 56, Kit.FACE_NEG_Z, "tile", C.mud },
		{ 246, 60, Kit.FACE_NEG_Z, "thatch", C.sandstoneLight },
		{ 180, 108, Kit.FACE_NEG_Z, "flat", C.mud },
		{ 152, -104, Kit.FACE_POS_Z, "thatch", C.sandstoneLight },
		{ 230, -108, Kit.FACE_POS_Z, "tile", C.ivory },
	}
	for i, h in ipairs(houses) do
		B.house(root, Kit.at(h[1], h[2], h[3]), { roof = h[4], wall = h[5], band = (i % 2 == 0) and C.redstone or C.flagBlue, rug = FLOWER[i % #FLOWER + 1] })
		ctx.reserve(h[1], h[2], 17)
	end

	Props.stall(root, Kit.at(150, -20, Kit.FACE_POS_Z), C.saffron)
	Props.stall(root, Kit.at(180, 20, Kit.FACE_NEG_Z), C.flagRed)
	Props.stall(root, Kit.at(214, -20, Kit.FACE_POS_Z), C.flagBlue, { Color3.fromRGB(190, 98, 62), Color3.fromRGB(150, 116, 84), Color3.fromRGB(214, 178, 128) })
	Props.stall(root, Kit.at(234, 21, Kit.FACE_NEG_Z), C.flagGreen)
	for _, s in ipairs({ { 150, -20 }, { 180, 20 }, { 214, -20 }, { 234, 21 } }) do
		ctx.reserve(s[1], s[2], 8)
	end
	Props.well(root, Kit.at(194, 30, 0))
	ctx.reserve(194, 30, 7)
	Props.banyan(root, Kit.at(176, -30, 0), 0.9)
	ctx.reserve(176, -30, 8)
	Props.cart(root, Kit.at(228, -30, 30))
	ctx.reserve(228, -30, 7)
	Props.haystack(root, Kit.at(250, -96, 0))
	Props.haystack(root, Kit.at(242, -90, 0))
	ctx.reserve(246, -93, 9)
	Props.cow(root, Kit.at(232, 98, 40))
	Props.cow(root, Kit.at(244, 92, 200), Color3.fromRGB(196, 160, 118))
	ctx.reserve(238, 95, 10)
	for i = 1, 6 do
		Props.pot(root, Kit.at(166 + i * 1.6, 46 - (i % 2) * 1.6, 0), 0.6 + (i % 3) * 0.2)
	end
	Props.flags(root, V(140, 15, -10), V(140, 15, 10), true)
	Props.flags(root, V(256, 15, -10), V(256, 15, 10), true)
	Props.signpost(root, Kit.at(132, 11, 90), "Kapilavastu Village")
	Props.signpost(root, Kit.at(252, -11, 90), "East: the Four Sights")

	ctx.scatter(128, 256, 10, 7, function(o)
		if rng:NextNumber() < 0.6 then
			Props.palm(root, o, rng:NextNumber(0.85, 1.15), rng:NextNumber(3, 10))
		else
			Props.roundTree(root, o, rng:NextNumber(0.8, 1.2))
		end
	end)
	ctx.scatter(128, 256, 14, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end)
	ctx.scatter(-200, -140, 10, 9, function(o)
		Props.sal(root, o, rng:NextNumber(0.9, 1.3))
	end)
end

----------------------------------------------------------------------
-- The Road of the Four Sights
----------------------------------------------------------------------
local function road(ctx)
	local root = Kit.folder(ctx.root, "FourSights")
	local rng = ctx.rng
	ctx.pave(258, 620, -7, 7, M.Ground)

	-- rice paddies to the north, mustard to the south
	for _, x in ipairs({ 300, 340, 380 }) do
		for _, z in ipairs({ 52, 90 }) do
			Props.paddy(root, Kit.at(x, z, 0), 34, 32, rng)
			ctx.reserve(x, z, 23)
		end
	end
	for _, f in ipairs({ { 306, -62 }, { 346, -70 }, { 388, -96 }, { 326, -106 } }) do
		Props.mustard(root, Kit.at(f[1], f[2], rng:NextNumber(-8, 8)), 32, 24)
		ctx.reserve(f[1], f[2], 19)
	end

	-- first sight: the old man resting in the shade
	Props.roundTree(root, Kit.at(340, 27, 0), 1.2)
	Kit.block(root, CFrame.new(334, 1, 25), V(5, 0.5, 1.6), C.wood, M.WoodPlanks)
	Kit.block(root, CFrame.new(332.2, 0.5, 25), V(0.5, 1, 1.4), C.woodDark, M.Wood)
	Kit.block(root, CFrame.new(335.8, 0.5, 25), V(0.5, 1, 1.4), C.woodDark, M.Wood)
	ctx.reserve(338, 26, 9)

	-- second sight: the sick man outside his hut
	B.house(root, Kit.at(412, -42, Kit.FACE_POS_Z), { w = 18, d = 14, h = 9, roof = "thatch", wall = C.mud })
	ctx.reserve(412, -42, 15)
	Kit.block(root, CFrame.new(418, 1.1, -26), V(3.6, 0.4, 6.6), C.wood, M.WoodPlanks)
	Kit.block(root, CFrame.new(418, 1.45, -26), V(3.2, 0.3, 6.2), C.ivory, M.Fabric, { collide = false })
	Props.pot(root, Kit.at(408, -28, 0), 0.7)

	-- the stream, its bridge, and the third sight: the funeral by the water
	B.bridge(root, Kit.at(456, 0, 90), 26, 12, C.wood)
	Props.bier(root, Kit.at(505, 40, 35))
	ctx.reserve(505, 40, 8)
	for i = 0, 3 do
		Kit.block(root, CFrame.new(522, 0.6 + i * 1, 58) * CFrame.Angles(0, math.rad(i * 90), 0), V(8, 1, 3), C.woodDark, M.Wood)
	end
	local pyre = Kit.ball(root, CFrame.new(522, 5, 58), 1, C.ember, M.Neon, { collide = false, shadow = false })
	Kit.smoke(pyre, Color3.fromRGB(150, 150, 150))
	ctx.reserve(522, 58, 8)
	for i = 1, 5 do
		Props.flowers(root, Kit.at(498 + i * 3, 46 + (i % 2) * 3, 0), Color3.fromRGB(240, 150, 30), rng)
	end

	-- fourth sight: the ascetic beneath the banyan
	Props.banyan(root, Kit.at(586, -36, 0), 1)
	ctx.reserve(586, -36, 10)
	Kit.block(root, CFrame.new(577, 0.3, -20), V(5, 0.6, 5), C.stone, M.Slate)

	-- a great stupa at the end of the road
	B.stupa(root, Kit.at(604, 72, 0), 10)
	ctx.reserve(604, 72, 18)
	B.torana(root, Kit.at(604, 52, 0), 12, 13)
	Props.flags(root, V(604, 26, 72), V(576, 11, 60), "end")
	Props.flags(root, V(604, 26, 72), V(628, 11, 54), "end")

	Props.signpost(root, Kit.at(268, 11, 90), "The Road of the Four Sights")
	Props.signpost(root, Kit.at(608, -11, 90), "East: River Anoma")
	for _, x in ipairs({ 300, 380, 520 }) do
		Props.lantern(root, Kit.at(x, 11, 0))
		ctx.reserve(x, 11, 3)
	end
	Props.deer(root, Kit.at(548, 84, 40))
	Props.deer(root, Kit.at(556, 92, 100))
	ctx.reserve(552, 88, 8)

	ctx.scatter(262, 618, 34, 8, function(o)
		local pick = rng:NextNumber()
		if pick < 0.4 then
			Props.roundTree(root, o, rng:NextNumber(0.9, 1.4))
		elseif pick < 0.7 then
			Props.palm(root, o, rng:NextNumber(0.9, 1.2), rng:NextNumber(3, 10))
		else
			Props.sal(root, o, rng:NextNumber(0.9, 1.2))
		end
	end)
	ctx.scatter(262, 618, 26, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end)
	ctx.scatter(262, 618, 12, 4, function(o)
		Props.rock(root, o, rng:NextNumber(0.8, 1.6), C.stone, rng)
	end)
	ctx.scatter(262, 618, 14, 3, function(o)
		Props.bush(root, o, rng:NextNumber(0.8, 1.4))
	end)
end

----------------------------------------------------------------------
-- The River Anoma
----------------------------------------------------------------------
local function anoma(ctx)
	local root = Kit.folder(ctx.root, "Anoma")
	local rng = ctx.rng
	local P = ctx.Config.Places
	local rx, half = P.anoma_river.x, P.anoma_river.width / 2
	ctx.pave(620, rx - half - 2, -7, 7, M.Ground)
	ctx.pave(rx + half + 2, 830, -7, 7, M.Ground)

	B.steppingStones(root, rx - half - 1, rx + half + 1, 0, rng, 0.3)

	-- a fisherman's boat drawn up on the west bank
	Kit.blob(root, CFrame.new(702, 0.8, 52) * CFrame.Angles(0, math.rad(20), math.rad(8)), V(5, 2.4, 14), C.wood, M.WoodPlanks)
	Kit.block(root, CFrame.new(702, 1.6, 52) * CFrame.Angles(0, math.rad(20), math.rad(8)), V(4, 0.3, 1.2), C.woodDark, M.WoodPlanks, { collide = false })
	ctx.reserve(702, 52, 8)

	-- reeds along both banks
	for _, bx in ipairs({ rx - half - 3, rx + half + 3 }) do
		local z = -140
		while z < 140 do
			if math.abs(z) > 14 then
				for _ = 1, 4 do
					local cf = CFrame.new(bx + rng:NextNumber(-2, 2), 0, z + rng:NextNumber(-2, 2)) * CFrame.Angles(math.rad(rng:NextNumber(-8, 8)), 0, math.rad(rng:NextNumber(-8, 8)))
					Kit.block(root, cf * CFrame.new(0, 2.6, 0), V(0.25, 5.2, 0.25), C.bamboo, M.Grass, { collide = false, shadow = false })
				end
			end
			z = z + rng:NextNumber(9, 16)
		end
	end

	-- Kanthaka, and the rock where the prince left his old life
	Props.horse(root, Kit.at(794, 27, 70))
	ctx.reserve(794, 27, 7)
	local rock = Kit.blob(root, CFrame.new(P.hair_rock.x, 1.2, P.hair_rock.z), V(11, 3.4, 9), C.stone, M.Slate)
	rock.Name = "HairRock"
	Kit.block(root, CFrame.new(P.hair_rock.x - 1.5, 3, P.hair_rock.z), V(3.4, 0.5, 2.4), Color3.fromRGB(40, 60, 160), M.Fabric, { collide = false })
	Kit.block(root, CFrame.new(P.hair_rock.x - 1.5, 3.3, P.hair_rock.z), V(3.5, 0.15, 0.8), C.gold, M.Fabric, { collide = false })
	Kit.cyl(root, CFrame.new(P.hair_rock.x + 2, 3.3, P.hair_rock.z + 1), 1.6, 0.9, C.gold, M.Metal, { collide = false })
	Kit.block(root, CFrame.new(P.hair_rock.x + 1.4, 3.6, P.hair_rock.z - 2) * CFrame.Angles(0, math.rad(30), math.rad(72)), V(0.3, 5, 0.6), Color3.fromRGB(200, 204, 214), M.Metal, { collide = false })
	ctx.objects.hair_rock = rock
	ctx.reserve(P.hair_rock.x, P.hair_rock.z, 9)

	Props.signpost(root, Kit.at(628, 11, 90), "River Anoma")
	ctx.scatter(622, 828, 18, 8, function(o)
		if rng:NextNumber() < 0.5 then
			Props.palm(root, o, rng:NextNumber(0.9, 1.2), rng:NextNumber(3, 10))
		else
			Props.sal(root, o, rng:NextNumber(0.9, 1.3))
		end
	end)
	ctx.scatter(622, 828, 12, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end)
	ctx.scatter(622, 828, 10, 4, function(o)
		Props.rock(root, o, rng:NextNumber(0.8, 1.8), C.stone, rng)
	end)
end

----------------------------------------------------------------------
-- The Forest of the Teachers
----------------------------------------------------------------------
local function hermitage(ctx, root, place, toward, name)
	local rng = ctx.rng
	local dir = (toward > place.z) and 1 or -1 -- which way the road lies
	local yaw = (dir == -1) and Kit.FACE_NEG_Z or Kit.FACE_POS_Z
	B.hut(root, Kit.at(place.x, place.z - dir * 10, yaw), 7)
	ctx.reserve(place.x, place.z - dir * 10, 11)
	B.hut(root, Kit.at(place.x + 22, place.z - dir * 6, yaw), 5)
	ctx.reserve(place.x + 22, place.z - dir * 6, 8)
	local spotZ = place.z + dir * 18
	for i = -2, 2 do
		Kit.cyl(root, CFrame.new(place.x + i * 4.4, 0.25, spotZ + (math.abs(i) % 2) * 3 * dir), 3, 0.5, C.thatch, M.Fabric, { collide = false, shadow = false })
	end
	Props.campfire(root, Kit.at(place.x + 11, spotZ - dir * 4, 0))
	ctx.reserve(place.x, spotZ, 16)
	ctx.pave(place.x - 4, place.x + 4, math.min(-dir * 7, spotZ + dir * 4), math.max(-dir * 7, spotZ + dir * 4), M.Ground)
	Props.flags(root, V(place.x - 14, 12, place.z), V(place.x + 14, 12, place.z), true)
	Props.signpost(root, Kit.at(place.x + 6, -dir * 11, 90), name)
	rng:NextNumber()
end

local function forest(ctx)
	local root = Kit.folder(ctx.root, "Forest")
	local rng = ctx.rng
	local P = ctx.Config.Places
	ctx.pave(830, 1220, -7, 7, M.Mud)

	hermitage(ctx, root, P.alara, 0, "Hermitage of Alara Kalama")
	hermitage(ctx, root, P.uddaka, 0, "Hermitage of Uddaka Ramaputta")
	B.bridge(root, Kit.at(1040, 0, 90), 26, 12, C.woodDark)

	for _, x in ipairs({ 880, 960, 1000, 1080, 1140, 1200 }) do
		Props.lantern(root, Kit.at(x, (x % 160 == 0) and 11 or -11, 0))
		ctx.reserve(x, (x % 160 == 0) and 11 or -11, 3)
	end

	ctx.scatter(834, 1216, 120, 6.5, function(o)
		Props.sal(root, o, rng:NextNumber(0.9, 1.5))
	end)
	ctx.scatter(834, 1216, 24, 5, function(o)
		Props.bamboo(root, o, rng, rng:NextInteger(5, 8))
	end)
	ctx.scatter(834, 1216, 40, 3, function(o)
		Props.bush(root, o, rng:NextNumber(0.8, 1.6), (rng:NextNumber() < 0.5) and C.leafDark or C.leaf)
	end)
	ctx.scatter(834, 1216, 18, 4, function(o)
		Props.rock(root, o, rng:NextNumber(0.9, 2), C.stoneDark, rng)
	end)
	ctx.scatter(834, 1216, 16, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end)
end

function Zones.build(ctx)
	village(ctx)
	road(ctx)
	anoma(ctx)
	forest(ctx)
end

return Zones
