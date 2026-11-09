-- ZonesEast: the second half of the journey.
-- Uruvela (the grove of austerities), Senani village and the Neranjara river,
-- Mara's Field, and Bodh Gaya with the Bodhi tree.

local Kit = require(script.Parent.Kit)
local Props = require(script.Parent.Props)
local B = require(script.Parent.Buildings)

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
-- Uruvela
----------------------------------------------------------------------
local function uruvela(ctx)
	local root = Kit.folder(ctx.root, "Uruvela")
	local rng = ctx.rng
	local P = ctx.Config.Places
	ctx.pave(1220, 1580, -7, 7, M.Sand)

	-- the camp of the five ascetics
	Props.campfire(root, Kit.at(P.ascetic_camp.x + 2, P.ascetic_camp.z - 2, 0))
	B.hut(root, Kit.at(1296, -78, Kit.yawToward(1296, -78, 1322, -52)), 5)
	ctx.reserve(1296, -78, 8)
	ctx.reserve(P.ascetic_camp.x, P.ascetic_camp.z, 20)
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2
		Kit.cyl(root, CFrame.new(P.ascetic_camp.x + 2 + math.cos(a) * 9, 0.2, P.ascetic_camp.z - 2 + math.sin(a) * 9), 3, 0.4, C.thatch, M.Fabric, { collide = false, shadow = false })
	end
	ctx.pave(1318, 1326, -36, -7, M.Sand)

	-- the cave
	B.cave(root, Kit.at(P.cave.x, P.cave.z, Kit.FACE_NEG_Z))
	ctx.reserve(P.cave.x, P.cave.z, 30)
	ctx.pave(P.cave.x - 4, P.cave.x + 4, 7, P.cave.z - 18, M.Sand)
	Props.signpost(root, Kit.at(P.cave.x + 7, 11, 90), "The Cave of Austerities")
	Props.signpost(root, Kit.at(1330, -11, 90), "Camp of the Five Ascetics")

	-- one green tree in a dry land: the memory of the rose-apple tree
	Props.roundTree(root, Kit.at(1486, -84, 0), 1.5, C.leaf)
	Kit.block(root, CFrame.new(1486, 0.3, -76), V(6, 0.6, 5), C.stone, M.Slate)
	ctx.reserve(1486, -84, 12)

	local sand = Color3.fromRGB(190, 160, 120)
	local sandDark = Color3.fromRGB(150, 122, 92)
	ctx.scatter(1224, 1576, 54, 4.5, function(o)
		Props.rock(root, o, rng:NextNumber(0.9, 2.6), (rng:NextNumber() < 0.5) and sand or sandDark, rng)
	end)
	ctx.scatter(1224, 1576, 22, 7, function(o)
		Props.roundTree(root, o, rng:NextNumber(0.7, 1.1), C.leafDry)
	end)
	ctx.scatter(1224, 1576, 10, 5, function(o)
		Props.deadTree(root, o, rng:NextNumber(0.7, 1))
	end)
	ctx.scatter(1224, 1576, 30, 3, function(o)
		Props.bush(root, o, rng:NextNumber(0.6, 1.1), C.leafDry)
	end)
end

----------------------------------------------------------------------
-- Senani and the Neranjara
----------------------------------------------------------------------
local function senani(ctx)
	local root = Kit.folder(ctx.root, "Senani")
	local rng = ctx.rng
	local P = ctx.Config.Places
	local rx, half = P.neranjara.x, P.neranjara.width / 2
	ctx.pave(1580, 1800, -8, 8, M.Cobblestone)
	ctx.pave(1800, rx - half - 16, -7, 7, M.Ground)
	ctx.pave(rx + half + 2, 2040, -7, 7, M.Ground)
	ctx.pave(1638, 1650, -44, -8, M.Cobblestone)
	ctx.pave(1696, 1704, 8, 36, M.Ground)

	B.shop(root, Kit.at(P.store2.x, P.store2.z, Kit.FACE_POS_Z), "Senani Trading Post", { awning = C.flagBlue, wall = C.sandstoneLight, band = C.flagBlue })
	ctx.reserve(P.store2.x, P.store2.z, 24)

	local houses = {
		{ 1650, 60, Kit.FACE_NEG_Z, "thatch", C.mud },
		{ 1612, -66, Kit.FACE_POS_Z, "flat", C.ivory },
		{ 1742, -58, Kit.FACE_POS_Z, "tile", C.mud },
		{ 1778, 60, Kit.FACE_NEG_Z, "flat", C.sandstoneLight },
		{ 1696, -108, Kit.FACE_POS_Z, "thatch", C.mud },
		{ 1616, 104, Kit.FACE_NEG_Z, "tile", C.ivory },
	}
	for i, h in ipairs(houses) do
		B.house(root, Kit.at(h[1], h[2], h[3]), { roof = h[4], wall = h[5], band = (i % 2 == 0) and C.saffron or C.flagGreen, rug = FLOWER[i % #FLOWER + 1] })
		ctx.reserve(h[1], h[2], 17)
	end

	-- Sujata's banyan, with the offerings left at its roots
	Props.banyan(root, Kit.at(P.sujata_tree.x, P.sujata_tree.z + 6, 0), 1.2)
	ctx.reserve(P.sujata_tree.x, P.sujata_tree.z + 6, 12)
	Kit.block(root, CFrame.new(1692, 1, 50), V(5, 2, 3), C.sandstone, M.Sandstone)
	Props.butterLamp(root, CFrame.new(1690.6, 2, 50))
	Props.butterLamp(root, CFrame.new(1693.4, 2, 50))
	Props.flowers(root, Kit.at(1688, 46, 0), Color3.fromRGB(240, 150, 30), rng)
	Props.flowers(root, Kit.at(1697, 47, 0), Color3.fromRGB(236, 80, 90), rng)
	Props.flags(root, V(1680, 13, 40), V(1722, 13, 40), true)

	-- cattle pen
	local px, pz = 1752, 98
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(root, CFrame.new(px + sx * 16, 2.2, pz), V(0.4, 0.4, 24), C.wood, M.Wood)
		Kit.block(root, CFrame.new(px + sx * 16, 1.2, pz), V(0.4, 0.4, 24), C.wood, M.Wood)
		Kit.block(root, CFrame.new(px, 2.2, pz + sx * 12), V(32, 0.4, 0.4), C.wood, M.Wood)
		Kit.block(root, CFrame.new(px, 1.2, pz + sx * 12), V(32, 0.4, 0.4), C.wood, M.Wood)
		for _, sz in ipairs({ -1, 1 }) do
			Kit.cyl(root, CFrame.new(px + sx * 16, 1.5, pz + sz * 12), 0.7, 3, C.woodDark, M.Wood)
		end
	end
	Props.cow(root, Kit.at(px - 8, pz - 3, 30))
	Props.cow(root, Kit.at(px + 2, pz + 4, 160), Color3.fromRGB(196, 160, 118))
	Props.cow(root, Kit.at(px + 9, pz - 4, 250))
	Props.cow(root, Kit.at(px - 3, pz + 6, 80), Color3.fromRGB(120, 92, 70))
	Props.haystack(root, Kit.at(px + 22, pz + 2, 0))
	ctx.reserve(px, pz, 22)
	ctx.reserve(px + 22, pz + 2, 6)

	Props.well(root, Kit.at(1668, 26, 0))
	ctx.reserve(1668, 26, 7)
	Props.stall(root, Kit.at(1690, -21, Kit.FACE_POS_Z), C.flagGreen)
	Props.stall(root, Kit.at(1728, 21, Kit.FACE_NEG_Z), C.saffron)
	ctx.reserve(1690, -21, 8)
	ctx.reserve(1728, 21, 8)
	Props.cart(root, Kit.at(1764, -26, 110))
	ctx.reserve(1764, -26, 7)
	B.pagoda(root, Kit.at(1792, -96, 0), 3, 16, C.tileTeal)
	ctx.reserve(1792, -96, 20)
	Props.signpost(root, Kit.at(1590, 11, 90), "Senani Village")
	Props.signpost(root, Kit.at(1812, -11, 90), "The Neranjara")

	-- stone steps (a ghat) down into the river
	local bank = rx - half
	ctx.fill(bank - 14, bank, -4, 4, -17, 17, M.Air)
	for i = 0, 6 do
		Kit.block(root, CFrame.new(bank - 15 + i * 3, 0.2 - i * 0.55 - 2, 0), V(3.2, 4, 34), C.sandstone, M.Sandstone)
	end
	for _, sz in ipairs({ -1, 1 }) do
		Kit.block(root, CFrame.new(bank - 16, 3, sz * 18.5), V(3, 6, 3), C.sandstoneDark, M.Sandstone)
		Kit.ball(root, CFrame.new(bank - 16, 7, sz * 18.5), 2.4, C.gold, M.Metal, { collide = false })
	end
	Props.flags(root, V(bank - 16, 14, -18.5), V(bank - 16, 14, 18.5), true)
	local bowlSpot = Kit.block(root, CFrame.new(P.bowl_river.x, 0.4, P.bowl_river.z), V(4, 4, 4), C.gold, M.SmoothPlastic, { collide = false, shadow = false, transparency = 1, name = "BowlSpot" })
	ctx.objects.bowl_river = bowlSpot
	ctx.reserve(bank - 8, 0, 20)

	-- a sandbar in the middle, and stones to either side of it
	ctx.fill(rx - 10, rx + 10, -10, -1.2, -48, 48, M.Sand)
	B.steppingStones(root, bank + 3, rx - 13, 0, rng, 0.3)
	B.steppingStones(root, rx + 13, rx + half - 3, 0, rng, 0.3)
	for _, bx in ipairs({ bank - 3, rx + half + 3 }) do
		local z = -140
		while z < 140 do
			if math.abs(z) > 24 then
				for _ = 1, 4 do
					local cf = CFrame.new(bx + rng:NextNumber(-2, 2), 0, z + rng:NextNumber(-2, 2)) * CFrame.Angles(math.rad(rng:NextNumber(-8, 8)), 0, math.rad(rng:NextNumber(-8, 8)))
					Kit.block(root, cf * CFrame.new(0, 2.6, 0), V(0.25, 5.2, 0.25), C.bamboo, M.Grass, { collide = false, shadow = false })
				end
			end
			z = z + rng:NextNumber(9, 16)
		end
	end

	-- Mucalinda's pool
	ctx.pond(P.mucalinda.x, P.mucalinda.z, 16)
	Kit.cyl(root, CFrame.new(P.mucalinda.x, -3, P.mucalinda.z), 11, 7, C.stone, M.Slate)
	B.naga(root, Kit.at(P.mucalinda.x, P.mucalinda.z, Kit.FACE_POS_Z, 0.5), 0.8)
	for i = 1, 5 do
		local a = i * 1.3
		Props.lotus(root, CFrame.new(P.mucalinda.x + math.cos(a) * 12, -0.95, P.mucalinda.z + math.sin(a) * 12), C.lotusPink, i % 2 == 0)
	end
	Props.signpost(root, Kit.at(1988, -72, 30), "Mucalinda's Pool")

	-- wild grass on the east bank
	ctx.scatter(rx + half + 8, 2034, 46, 2.5, function(o)
		for _ = 1, 4 do
			local cf = o * CFrame.new(rng:NextNumber(-1.5, 1.5), 0, rng:NextNumber(-1.5, 1.5)) * CFrame.Angles(math.rad(rng:NextNumber(-12, 12)), 0, math.rad(rng:NextNumber(-12, 12)))
			Kit.block(root, cf * CFrame.new(0, 1.3, 0), V(0.2, 2.6, 0.45), Color3.fromRGB(112, 150, 70), M.Grass, { collide = false, shadow = false })
		end
	end)

	ctx.scatter(1584, 2036, 26, 8, function(o)
		local pick = rng:NextNumber()
		if pick < 0.45 then
			Props.palm(root, o, rng:NextNumber(0.9, 1.25), rng:NextNumber(3, 10))
		elseif pick < 0.75 then
			Props.roundTree(root, o, rng:NextNumber(0.9, 1.3))
		else
			Props.sal(root, o, rng:NextNumber(0.9, 1.2))
		end
	end)
	ctx.scatter(1584, 2036, 26, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end)
	ctx.scatter(1584, 2036, 10, 4, function(o)
		Props.rock(root, o, rng:NextNumber(0.8, 1.6), C.stone, rng)
	end)
end

----------------------------------------------------------------------
-- Mara's Field
----------------------------------------------------------------------
local function mara(ctx)
	local root = Kit.folder(ctx.root, "MarasField")
	local rng = ctx.rng
	local P = ctx.Config.Places
	local terrain = workspace.Terrain
	ctx.pave(2040, 2560, -7, 7, M.Slate)

	-- the arena where Mara waits
	terrain:FillCylinder(CFrame.new(P.arena.x, -2, P.arena.z), 4, P.arena.radius + 4, M.Slate)
	ctx.reserve(P.arena.x, P.arena.z, P.arena.radius + 10)
	local violet = Color3.fromRGB(170, 90, 255)
	for i = 0, 21 do
		local a = i / 22 * math.pi * 2
		local z = math.sin(a) * (P.arena.radius + 2)
		if math.abs(z) > 12 then
			Props.brazier(root, Kit.at(P.arena.x + math.cos(a) * (P.arena.radius + 2), z, 0), violet)
		end
	end
	for i = 0, 11 do
		local a = i / 12 * math.pi * 2 + 0.26
		local r = P.arena.radius + 12
		local z = math.sin(a) * r
		if math.abs(z) > 16 then
			local cf = Kit.at(P.arena.x + math.cos(a) * r, z, rng:NextNumber(0, 360)) * CFrame.Angles(math.rad(rng:NextNumber(-12, 12)), 0, math.rad(rng:NextNumber(-12, 12)))
			local h = rng:NextNumber(20, 34)
			Kit.block(root, cf * CFrame.new(0, h / 2 - 2, 0), V(5, h, 5), Color3.fromRGB(36, 30, 40), M.Basalt)
		end
	end

	-- Girimekhala, Mara's elephant, "a hundred and fifty leagues high"
	local mount = Kit.at(P.mara.x, P.mara.z, Kit.FACE_NEG_X)
	local scale = 2.3
	ctx.objects.elephant = Props.elephant(root, mount, scale, Color3.fromRGB(46, 40, 50), { name = "Girimekhala", eye = Color3.fromRGB(255, 60, 40), cloth = Color3.fromRGB(110, 20, 32) })
	ctx.objects.maraSeat = mount * CFrame.new(0, 12.9 * scale, 1 * scale)

	-- the pavilions of the three daughters
	local tints = { d1 = Color3.fromRGB(70, 200, 190), d2 = Color3.fromRGB(130, 140, 240), d3 = Color3.fromRGB(240, 90, 140) }
	for _, s in ipairs(ctx.Config.Spawns) do
		if tints[s.id] then
			B.pavilion(root, Kit.at(s.x, s.z, 0), tints[s.id])
			ctx.reserve(s.x, s.z, 20)
			ctx.pave(s.x - 3, s.x + 3, math.min(0, s.z), math.max(0, s.z), M.Slate)
		end
	end

	-- banners and fires along the road
	local x = 2070
	local n = 0
	while x < 2400 do
		n = n + 1
		local side = (n % 2 == 0) and 1 or -1
		Props.banner(root, Kit.at(x, side * 12, 90))
		Props.brazier(root, Kit.at(x + 22, -side * 12, 0))
		ctx.reserve(x, side * 12, 3)
		ctx.reserve(x + 22, -side * 12, 3)
		x = x + 46
	end
	Props.signpost(root, Kit.at(2052, 11, 90), "Mara's Field")

	-- glowing cracks in the ground
	ctx.scatter(2046, 2400, 34, 5, function(_, px, pz)
		local w = rng:NextNumber(3, 6)
		local d = rng:NextNumber(6, 16)
		if rng:NextNumber() < 0.5 then
			w, d = d, w
		end
		ctx.fill(px - w / 2, px + w / 2, -3, 0, pz - d / 2, pz + d / 2, M.CrackedLava)
	end)
	ctx.scatter(2046, 2556, 70, 5, function(o)
		Props.deadTree(root, o, rng:NextNumber(0.8, 1.5))
	end)
	ctx.scatter(2046, 2556, 46, 4, function(o)
		Props.rock(root, o, rng:NextNumber(1, 2.8), Color3.fromRGB(44, 38, 46), rng)
	end)
	ctx.scatter(2046, 2400, 16, 4, function(o)
		local h = rng:NextNumber(14, 26)
		Kit.block(root, o * CFrame.Angles(math.rad(rng:NextNumber(-14, 14)), 0, math.rad(rng:NextNumber(-14, 14))) * CFrame.new(0, h / 2 - 2, 0), V(4, h, 4), Color3.fromRGB(36, 30, 40), M.Basalt)
	end)
end

----------------------------------------------------------------------
-- Bodh Gaya
----------------------------------------------------------------------
local function bodhgaya(ctx)
	local root = Kit.folder(ctx.root, "BodhGaya")
	local rng = ctx.rng
	local P = ctx.Config.Places
	ctx.pave(2560, 2694, -7, 7, M.Limestone)

	local _, seat = B.bodhiTree(root, Kit.at(P.tree.x, P.tree.z, 0))
	ctx.objects.seat = seat
	ctx.reserve(P.tree.x, P.tree.z, 56)

	-- the Mahabodhi temple stands beside the tree
	B.temple(root, Kit.at(2822, 0, Kit.FACE_NEG_X))
	ctx.reserve(2822, 0, 48)

	for _, z in ipairs({ 70, -74 }) do
		ctx.pond(2662, z, 14)
		for i = 1, 6 do
			local a = i * 1.1
			local r = 3 + (i % 3) * 3.2
			Props.lotus(root, CFrame.new(2662 + math.cos(a) * r, -0.95, z + math.sin(a) * r), (i % 2 == 0) and C.lotusWhite or C.lotusPink, i % 3 ~= 0)
		end
	end
	for _, s in ipairs({ { 2618, 34 }, { 2618, -34 }, { 2652, 30 }, { 2652, -30 } }) do
		B.stupa(root, Kit.at(s[1], s[2], 0), 3.6)
		ctx.reserve(s[1], s[2], 8)
	end
	for _, x in ipairs({ 2606, 2636, 2666 }) do
		Props.flags(root, V(x, 15, -13), V(x, 15, 13), true)
		ctx.reserve(x, 13, 2)
		ctx.reserve(x, -13, 2)
	end
	for _, x in ipairs({ 2580, 2622, 2680 }) do
		for _, z in ipairs({ -11, 11 }) do
			Props.lantern(root, Kit.at(x + 8, z, 0))
			ctx.reserve(x + 8, z, 3)
		end
	end
	Props.signpost(root, Kit.at(2572, 11, 90), "Bodh Gaya")
	Props.deer(root, Kit.at(2630, 96, 20))
	Props.deer(root, Kit.at(2638, 104, 150))
	Props.deer(root, Kit.at(2610, -100, 240))
	Props.deer(root, Kit.at(2700, -108, 60))
	ctx.reserve(2634, 100, 8)
	ctx.reserve(2610, -100, 5)
	ctx.reserve(2700, -108, 5)

	ctx.scatter(2564, 2850, 40, 8, function(o)
		if rng:NextNumber() < 0.55 then
			Props.sal(root, o, rng:NextNumber(0.9, 1.4))
		else
			Props.roundTree(root, o, rng:NextNumber(1, 1.5))
		end
	end)
	ctx.scatter(2564, 2850, 60, 3, function(o)
		Props.flowers(root, o, FLOWER[rng:NextInteger(1, #FLOWER)], rng)
	end)
	ctx.scatter(2564, 2850, 16, 3, function(o)
		Props.bush(root, o, rng:NextNumber(0.8, 1.4), C.leafLight)
	end)
end

function Zones.build(ctx)
	uruvela(ctx)
	senani(ctx)
	mara(ctx)
	bodhgaya(ctx)
end

return Zones
