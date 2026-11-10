-- Props: trees, rocks, animals and small objects.
-- Every function takes the place to put the thing ("o", a ground-level frame) and
-- builds it from simple parts. Structures treat -Z as "front".

local Kit = require(script.Parent.Kit)
local C = Kit.C
local M = Enum.Material

local Props = {}

local function V(x, y, z)
	return Vector3.new(x, y, z)
end
local rad = math.rad
local NOCOL = { collide = false }
local SOFT = { collide = false, shadow = false }

----------------------------------------------------------------------
-- Trees and plants
----------------------------------------------------------------------

-- Sal tree: tall and straight. The Buddha was born and passed away beneath sal trees.
function Props.sal(parent, o, s)
	s = s or 1
	local h = 18 * s
	Kit.cyl(parent, o * CFrame.new(0, h / 2, 0), 1.8 * s, h, C.trunk, M.Wood)
	Kit.blob(parent, o * CFrame.new(0, h * 0.8, 0), V(13 * s, 9 * s, 13 * s), C.leaf, M.Grass, NOCOL)
	Kit.blob(parent, o * CFrame.new(2.5 * s, h * 1.03, 1.5 * s), V(9 * s, 7 * s, 9 * s), C.leafLight, M.Grass, NOCOL)
	Kit.blob(parent, o * CFrame.new(-3 * s, h * 0.93, -2 * s), V(8.5 * s, 6 * s, 8.5 * s), C.leafDark, M.Grass, NOCOL)
end

-- A smaller round tree (mango / rose-apple).
function Props.roundTree(parent, o, s, leafColor)
	s = s or 1
	local h = 9 * s
	Kit.cyl(parent, o * CFrame.new(0, h / 2, 0), 1.6 * s, h, C.trunk, M.Wood)
	Kit.blob(parent, o * CFrame.new(0, h + 2.5 * s, 0), V(14 * s, 9 * s, 14 * s), leafColor or C.leafDark, M.Grass, NOCOL)
	Kit.blob(parent, o * CFrame.new(3 * s, h + 4.5 * s, -2 * s), V(8 * s, 6 * s, 8 * s), C.leaf, M.Grass, NOCOL)
end

-- Banyan: a huge spreading fig with hanging roots.
function Props.banyan(parent, o, s)
	s = s or 1
	local m = Kit.model(parent, "Banyan")
	Kit.cyl(m, o * CFrame.new(0, 8 * s, 0), 7 * s, 16 * s, C.trunk, M.Wood)
	Kit.cyl(m, o * CFrame.new(0, 1 * s, 0), 10 * s, 2 * s, C.trunk, M.Wood)
	for i = 0, 6 do
		local a = i / 7 * math.pi * 2
		local r = 13 * s
		Kit.blob(m, o * CFrame.new(math.cos(a) * r, 19 * s + (i % 2) * 2 * s, math.sin(a) * r), V(20 * s, 10 * s, 20 * s), (i % 2 == 0) and C.leafDark or C.leaf, M.Grass, NOCOL)
	end
	Kit.blob(m, o * CFrame.new(0, 24 * s, 0), V(24 * s, 11 * s, 24 * s), C.leaf, M.Grass, NOCOL)
	for i = 0, 8 do
		local a = i / 9 * math.pi * 2 + 0.3
		local r = (9 + (i % 3) * 4) * s
		local hh = 15 * s
		Kit.cyl(m, o * CFrame.new(math.cos(a) * r, hh / 2, math.sin(a) * r), 0.7 * s, hh, C.trunkPale, M.Wood, SOFT)
	end
	return m
end

function Props.palm(parent, o, s, lean)
	s = s or 1
	local h = 22 * s
	local tilt = o * CFrame.Angles(rad(lean or 7), 0, 0)
	Kit.cyl(parent, tilt * CFrame.new(0, h / 2, 0), 1.3 * s, h, C.trunkPale, M.Wood)
	local top = tilt * CFrame.new(0, h, 0)
	for i = 0, 7 do
		local f = top * CFrame.Angles(0, rad(i * 45), 0) * CFrame.Angles(rad(-24 - (i % 2) * 10), 0, 0) * CFrame.new(0, 0, -5.5 * s)
		Kit.block(parent, f, V(1.8 * s, 0.25, 11 * s), (i % 2 == 0) and C.leaf or C.leafLight, M.Grass, SOFT)
	end
	Kit.ball(parent, top * CFrame.new(0.6, -0.8, 0.4), 1.2 * s, C.woodDark, M.Wood, SOFT)
	Kit.ball(parent, top * CFrame.new(-0.6, -0.9, -0.3), 1.2 * s, C.woodDark, M.Wood, SOFT)
end

function Props.bamboo(parent, o, rng, n)
	for _ = 1, n or 7 do
		local h = rng:NextNumber(14, 24)
		local cf = o * CFrame.new(rng:NextNumber(-2.5, 2.5), 0, rng:NextNumber(-2.5, 2.5)) * CFrame.Angles(rad(rng:NextNumber(-6, 6)), 0, rad(rng:NextNumber(-6, 6)))
		Kit.cyl(parent, cf * CFrame.new(0, h / 2, 0), 0.6, h, C.bamboo, M.SmoothPlastic, SOFT)
		Kit.blob(parent, cf * CFrame.new(0, h, 0), V(3.4, 2.4, 3.4), C.leafLight, M.Grass, SOFT)
	end
end

function Props.bush(parent, o, s, color)
	s = s or 1
	Kit.blob(parent, o * CFrame.new(0, 1.2 * s, 0), V(5 * s, 3.2 * s, 5 * s), color or C.leafDark, M.Grass, SOFT)
end

function Props.flowers(parent, o, color, rng)
	Kit.blob(parent, o * CFrame.new(0, 0.5, 0), V(4, 1.4, 4), C.leaf, M.Grass, SOFT)
	for _ = 1, 4 do
		Kit.ball(parent, o * CFrame.new(rng:NextNumber(-1.4, 1.4), 1.2, rng:NextNumber(-1.4, 1.4)), 0.8, color, M.SmoothPlastic, SOFT)
	end
end

function Props.rock(parent, o, s, color, rng)
	s = s or 1
	local cf = o * CFrame.new(0, 0.9 * s, 0) * CFrame.Angles(rad(rng:NextNumber(-18, 18)), rad(rng:NextNumber(0, 360)), rad(rng:NextNumber(-18, 18)))
	Kit.block(parent, cf, V(rng:NextNumber(3, 5) * s, rng:NextNumber(2, 3.4) * s, rng:NextNumber(3, 5) * s), color or C.stone, M.Slate)
end

-- A bare, twisted tree for Mara's Field.
function Props.deadTree(parent, o, s)
	s = s or 1
	local trunk = o * CFrame.Angles(rad(6), 0, rad(-5))
	Kit.cyl(parent, trunk * CFrame.new(0, 7 * s, 0), 1.6 * s, 14 * s, C.black, M.Wood)
	Kit.block(parent, trunk * CFrame.new(0, 12 * s, 0) * CFrame.Angles(0, 0, rad(50)) * CFrame.new(0, 3.5 * s, 0), V(0.8 * s, 7 * s, 0.8 * s), C.black, M.Wood, SOFT)
	Kit.block(parent, trunk * CFrame.new(0, 10 * s, 0) * CFrame.Angles(0, rad(120), rad(-55)) * CFrame.new(0, 3 * s, 0), V(0.7 * s, 6 * s, 0.7 * s), C.black, M.Wood, SOFT)
	Kit.block(parent, trunk * CFrame.new(0, 14 * s, 0) * CFrame.Angles(rad(35), rad(40), 0) * CFrame.new(0, 2.5 * s, 0), V(0.6 * s, 5 * s, 0.6 * s), C.black, M.Wood, SOFT)
end

-- A lotus pad with a flower, floating at water level.
function Props.lotus(parent, o, color, open)
	Kit.cyl(parent, o * CFrame.new(0, 0.05, 0), 3, 0.12, C.leaf, M.SmoothPlastic, SOFT)
	if open ~= false then
		local c = color or C.lotusPink
		for i = 0, 5 do
			local f = o * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, rad(i * 60), 0) * CFrame.Angles(rad(35), 0, 0) * CFrame.new(0, 0.3, -0.5)
			Kit.blob(parent, f, V(0.7, 0.3, 1.3), c, M.SmoothPlastic, SOFT)
		end
		Kit.ball(parent, o * CFrame.new(0, 0.6, 0), 0.55, C.flagYellow, M.SmoothPlastic, SOFT)
	end
end

-- A flooded rice paddy.
function Props.paddy(parent, o, w, d, rng)
	Kit.block(parent, o * CFrame.new(0, 0.12, 0), V(w, 0.24, d), Color3.fromRGB(96, 150, 140), M.Glass, { collide = false, shadow = false, transparency = 0.25, reflectance = 0.2 })
	Kit.block(parent, o * CFrame.new(0, 0.3, d / 2), V(w + 1.6, 0.6, 1.2), C.mudDark, M.Mud, SOFT)
	Kit.block(parent, o * CFrame.new(0, 0.3, -d / 2), V(w + 1.6, 0.6, 1.2), C.mudDark, M.Mud, SOFT)
	Kit.block(parent, o * CFrame.new(w / 2, 0.3, 0), V(1.2, 0.6, d), C.mudDark, M.Mud, SOFT)
	Kit.block(parent, o * CFrame.new(-w / 2, 0.3, 0), V(1.2, 0.6, d), C.mudDark, M.Mud, SOFT)
	local rows = math.floor(d / 4)
	for r = 1, rows do
		local z = -d / 2 + r * (d / (rows + 1))
		Kit.block(parent, o * CFrame.new(0, 0.9, z), V(w - 3, 1.5, 0.5), (r % 2 == 0) and C.leafLight or C.bamboo, M.Grass, SOFT)
	end
	if rng then
		rng:NextNumber()
	end
end

-- A patch of yellow mustard in flower.
function Props.mustard(parent, o, w, d)
	Kit.block(parent, o * CFrame.new(0, 0.9, 0), V(w, 1.8, d), Color3.fromRGB(226, 196, 44), M.Grass, SOFT)
	Kit.block(parent, o * CFrame.new(0, 0.4, 0), V(w + 0.6, 0.8, d + 0.6), C.leaf, M.Grass, SOFT)
end

----------------------------------------------------------------------
-- Small objects
----------------------------------------------------------------------

function Props.pot(parent, o, s, color)
	s = s or 1
	Kit.blob(parent, o * CFrame.new(0, 1.1 * s, 0), V(2.2 * s, 2.2 * s, 2.2 * s), color or C.terracotta, M.SmoothPlastic, SOFT)
	Kit.cyl(parent, o * CFrame.new(0, 2.2 * s, 0), 1.3 * s, 0.5 * s, color or C.terracotta, M.SmoothPlastic, SOFT)
end

-- A small butter lamp with a living flame.
function Props.butterLamp(parent, o, lit)
	Kit.cyl(parent, o * CFrame.new(0, 0.3, 0), 0.9, 0.6, C.gold, M.Metal, SOFT)
	local cup = Kit.cyl(parent, o * CFrame.new(0, 0.75, 0), 1.2, 0.3, C.gold, M.Metal, SOFT)
	if lit ~= false then
		local flame = Kit.ball(parent, o * CFrame.new(0, 1.15, 0), 0.5, C.goldBright, M.Neon, SOFT)
		Kit.light(flame, Color3.fromRGB(255, 190, 110), 12, 1)
	end
	return cup
end

function Props.lantern(parent, o)
	Kit.block(parent, o * CFrame.new(0, 0.4, 0), V(2.6, 0.8, 2.6), C.stone, M.Slate)
	Kit.cyl(parent, o * CFrame.new(0, 2.6, 0), 1, 3.6, C.stone, M.Slate)
	Kit.block(parent, o * CFrame.new(0, 4.7, 0), V(2.4, 0.5, 2.4), C.stone, M.Slate, NOCOL)
	local glow = Kit.block(parent, o * CFrame.new(0, 5.6, 0), V(1.5, 1.4, 1.5), Color3.fromRGB(255, 214, 150), M.Neon, SOFT)
	Kit.light(glow, Color3.fromRGB(255, 200, 130), 18, 1.1)
	Kit.block(parent, o * CFrame.new(0, 6.6, 0), V(3.2, 0.5, 3.2), C.stoneDark, M.Slate, NOCOL)
	Kit.block(parent, o * CFrame.new(0, 7.1, 0), V(1.8, 0.5, 1.8), C.stoneDark, M.Slate, NOCOL)
	Kit.ball(parent, o * CFrame.new(0, 7.7, 0), 0.8, C.stoneDark, M.Slate, SOFT)
end

function Props.incenseBurner(parent, o)
	Kit.cyl(parent, o * CFrame.new(0, 0.9, 0), 1.2, 1.8, C.bronze, M.Metal)
	local bowl = Kit.blob(parent, o * CFrame.new(0, 2.2, 0), V(3.2, 1.6, 3.2), C.bronze, M.Metal, NOCOL)
	Kit.cyl(parent, o * CFrame.new(0, 2.8, 0), 2.6, 0.2, C.ash, M.Sand, SOFT)
	for i = -1, 1 do
		Kit.cyl(parent, o * CFrame.new(i * 0.5, 3.5, 0), 0.12, 1.4, C.woodRed, M.SmoothPlastic, SOFT)
	end
	local tip = Kit.ball(parent, o * CFrame.new(0, 4.2, 0), 0.2, C.ember, M.Neon, SOFT)
	Kit.smoke(tip)
	return bowl
end

-- A line of five-coloured prayer flags between two points.
function Props.flags(parent, p1, p2, poles)
	local d = p2 - p1
	local len = d.Magnitude
	local mid = (p1 + p2) / 2
	local cf = CFrame.new(mid, p2)
	Kit.block(parent, cf, V(0.12, 0.12, len), C.ivory, M.Fabric, SOFT)
	local n = math.max(3, math.floor(len / 2.4))
	for i = 1, n do
		local t = (i - 0.5) / n
		local sag = math.sin(t * math.pi) * (len * 0.04)
		local fcf = cf * CFrame.new(0, -0.9 - sag, -len / 2 + t * len)
		Kit.block(parent, fcf, V(0.08, 1.5, 1.6), Kit.FlagColors[(i - 1) % 5 + 1], M.Fabric, SOFT)
	end
	if poles then
		if poles ~= "end" then
			Kit.cyl(parent, CFrame.new(p1.X, p1.Y / 2, p1.Z), 0.5, p1.Y, C.woodDark, M.Wood)
		end
		Kit.cyl(parent, CFrame.new(p2.X, p2.Y / 2, p2.Z), 0.5, p2.Y, C.woodDark, M.Wood)
	end
end

function Props.campfire(parent, o)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		Kit.block(parent, o * CFrame.new(math.cos(a) * 1.8, 0.4, math.sin(a) * 1.8) * CFrame.Angles(0, -a, 0), V(1, 0.8, 1.2), C.stoneDark, M.Slate, SOFT)
	end
	Kit.block(parent, o * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, rad(30), rad(20)), V(2.6, 0.5, 0.5), C.woodDark, M.Wood, SOFT)
	Kit.block(parent, o * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, rad(-50), rad(-20)), V(2.6, 0.5, 0.5), C.woodDark, M.Wood, SOFT)
	local core = Kit.ball(parent, o * CFrame.new(0, 0.7, 0), 1, C.ember, M.Neon, SOFT)
	Kit.fire(core, 5, 9)
	Kit.light(core, Color3.fromRGB(255, 150, 70), 22, 1.4)
end

-- A tall iron brazier (ring of fires around Mara's arena).
function Props.brazier(parent, o, flameColor)
	Kit.cyl(parent, o * CFrame.new(0, 3, 0), 0.8, 6, C.black, M.Metal)
	Kit.block(parent, o * CFrame.new(0, 0.3, 0), V(3, 0.6, 3), C.black, M.Metal)
	Kit.blob(parent, o * CFrame.new(0, 6.4, 0), V(4, 2, 4), C.black, M.Metal, NOCOL)
	local core = Kit.ball(parent, o * CFrame.new(0, 7.2, 0), 1.6, flameColor or C.ember, M.Neon, SOFT)
	local f = Kit.fire(core, 8, 12)
	if flameColor then
		f.Color = flameColor
		f.SecondaryColor = Color3.fromRGB(80, 20, 120)
	end
	Kit.light(core, flameColor or Color3.fromRGB(255, 140, 60), 30, 1.6)
end

-- A tattered war banner.
function Props.banner(parent, o, color)
	Kit.cyl(parent, o * CFrame.new(0, 8, 0), 0.5, 16, C.black, M.Wood)
	Kit.block(parent, o * CFrame.new(1.8, 12.5, 0), V(3.2, 6, 0.15), color or Color3.fromRGB(110, 20, 30), M.Fabric, SOFT)
	Kit.block(parent, o * CFrame.new(1.2, 8.8, 0), V(1.6, 1.6, 0.15), color or Color3.fromRGB(110, 20, 30), M.Fabric, SOFT)
	Kit.ball(parent, o * CFrame.new(0, 16.3, 0), 1, C.bone, M.SmoothPlastic, SOFT)
end

function Props.haystack(parent, o)
	Kit.blob(parent, o * CFrame.new(0, 2.6, 0), V(7, 6.4, 7), C.thatch, M.Grass)
	Kit.cyl(parent, o * CFrame.new(0, 5.6, 0), 0.4, 3, C.wood, M.Wood, SOFT)
end

function Props.cart(parent, o)
	Kit.block(parent, o * CFrame.new(0, 2.4, 0), V(5, 0.5, 8), C.wood, M.WoodPlanks)
	Kit.block(parent, o * CFrame.new(2.4, 3.2, 0), V(0.3, 1.4, 8), C.woodDark, M.WoodPlanks, NOCOL)
	Kit.block(parent, o * CFrame.new(-2.4, 3.2, 0), V(0.3, 1.4, 8), C.woodDark, M.WoodPlanks, NOCOL)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.cyl(parent, o * CFrame.new(sx * 2.9, 2, 0.5) * CFrame.Angles(0, 0, rad(90)), 4, 0.5, C.woodDark, M.Wood)
	end
	Kit.block(parent, o * CFrame.new(0, 2.2, -6.5), V(0.4, 0.4, 5.5), C.woodDark, M.Wood, NOCOL)
	Kit.blob(parent, o * CFrame.new(0, 3.6, 0.5), V(4, 2.4, 6), C.thatch, M.Grass, NOCOL)
end

function Props.well(parent, o)
	local m = Kit.model(parent, "Well")
	for i = 0, 9 do
		local a = i / 10 * math.pi * 2
		Kit.block(m, o * CFrame.new(math.cos(a) * 3.6, 1.4, math.sin(a) * 3.6) * CFrame.Angles(0, -a, 0), V(1.4, 2.8, 2.5), C.stone, M.Cobblestone)
	end
	Kit.cyl(m, o * CFrame.new(0, 1.2, 0), 6.4, 0.3, Color3.fromRGB(40, 80, 96), M.Glass, { collide = false, shadow = false, transparency = 0.2 })
	Kit.cyl(m, o * CFrame.new(-3.8, 4, 0), 0.5, 8, C.woodDark, M.Wood)
	Kit.cyl(m, o * CFrame.new(3.8, 4, 0), 0.5, 8, C.woodDark, M.Wood)
	Kit.block(m, o * CFrame.new(0, 7.8, 0), V(9, 0.5, 0.5), C.woodDark, M.Wood, NOCOL)
	Kit.cyl(m, o * CFrame.new(0, 5.6, 0), 0.12, 4, C.ivory, M.Fabric, SOFT)
	Kit.cyl(m, o * CFrame.new(0, 3.4, 0), 1.3, 1.4, C.wood, M.WoodPlanks, SOFT)
	return m
end

-- A market stall with a striped canopy and heaps of goods.
function Props.stall(parent, o, canopy, goods)
	local m = Kit.model(parent, "Stall")
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			Kit.cyl(m, o * CFrame.new(sx * 4.5, 4, sz * 3), 0.4, 8, C.woodDark, M.Wood)
		end
	end
	local roof = o * CFrame.new(0, 8.2, 0) * CFrame.Angles(rad(-10), 0, 0)
	for i = -2, 2 do
		Kit.block(m, roof * CFrame.new(i * 2.1, 0, 0), V(2.1, 0.2, 8), (i % 2 == 0) and canopy or C.ivory, M.Fabric, NOCOL)
	end
	Kit.block(m, o * CFrame.new(0, 2.6, -1), V(8.6, 0.4, 3.2), C.wood, M.WoodPlanks)
	Kit.block(m, o * CFrame.new(-3.9, 1.2, -1), V(0.5, 2.4, 3), C.woodDark, M.Wood)
	Kit.block(m, o * CFrame.new(3.9, 1.2, -1), V(0.5, 2.4, 3), C.woodDark, M.Wood)
	local colors = goods or { Color3.fromRGB(240, 150, 30), Color3.fromRGB(220, 60, 50), Color3.fromRGB(240, 210, 60), Color3.fromRGB(120, 170, 60) }
	for i = 1, 4 do
		local x = -3.6 + i * 1.5
		Kit.blob(m, o * CFrame.new(x, 3.3, -1), V(1.4, 1.2, 1.8), colors[(i - 1) % #colors + 1], M.SmoothPlastic, SOFT)
	end
	Kit.blob(m, o * CFrame.new(-2.8, 1, 2.4), V(2.2, 2, 2.2), C.thatch, M.Fabric, SOFT)
	Kit.blob(m, o * CFrame.new(2.8, 1, 2.4), V(2.2, 2, 2.2), C.ivory, M.Fabric, SOFT)
	return m
end

function Props.signpost(parent, o, text)
	Kit.cyl(parent, o * CFrame.new(0, 3, 0), 0.5, 6, C.woodDark, M.Wood)
	local board = Kit.block(parent, o * CFrame.new(0, 5.4, 0), V(6, 1.8, 0.3), C.wood, M.WoodPlanks, NOCOL)
	Kit.plaque(board, text, C.ivory, { Enum.NormalId.Front, Enum.NormalId.Back })
	return board
end

-- A funeral bier: a shrouded figure laid on a litter, with marigold garlands.
function Props.bier(parent, o)
	Kit.block(parent, o * CFrame.new(0, 1.2, 0), V(3.4, 0.3, 8.6), C.bamboo, M.Wood)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(parent, o * CFrame.new(sx * 1.7, 1.2, 0), V(0.35, 0.35, 11), C.woodDark, M.Wood, NOCOL)
		for _, sz in ipairs({ -1, 1 }) do
			Kit.cyl(parent, o * CFrame.new(sx * 1.5, 0.55, sz * 3.6), 0.4, 1.1, C.woodDark, M.Wood, NOCOL)
		end
	end
	Kit.blob(parent, o * CFrame.new(0, 1.9, 0.3), V(2.6, 1.3, 7), C.white, M.Fabric, NOCOL)
	Kit.blob(parent, o * CFrame.new(0, 2.1, -3), V(1.5, 1.3, 1.5), C.white, M.Fabric, NOCOL)
	Kit.blob(parent, o * CFrame.new(0, 2.6, 0.3), V(2.2, 0.4, 3), Color3.fromRGB(240, 150, 30), M.SmoothPlastic, SOFT)
end

----------------------------------------------------------------------
-- Animals (still figures)
----------------------------------------------------------------------

function Props.cow(parent, o, color)
	local c = color or C.white
	local m = Kit.model(parent, "Cow")
	Kit.block(m, o * CFrame.new(0, 3.2, 0), V(2.4, 2.6, 5.2), c, M.SmoothPlastic)
	Kit.blob(m, o * CFrame.new(0, 4.7, -1.4), V(1.8, 1.4, 2), c, M.SmoothPlastic, SOFT)
	Kit.block(m, o * CFrame.new(0, 3.8, -3.4), V(1.6, 1.7, 2), c, M.SmoothPlastic, NOCOL)
	Kit.block(m, o * CFrame.new(0, 3.4, -4.5), V(1.2, 1, 0.8), Color3.fromRGB(226, 190, 170), M.SmoothPlastic, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(m, o * CFrame.new(sx * 0.8, 4.9, -3.3) * CFrame.Angles(0, 0, rad(sx * -30)), V(0.25, 1.1, 0.25), C.bone, M.SmoothPlastic, SOFT)
		for _, sz in ipairs({ -1, 1 }) do
			Kit.block(m, o * CFrame.new(sx * 0.8, 1, sz * 2), V(0.6, 2, 0.6), c, M.SmoothPlastic, NOCOL)
		end
	end
	Kit.block(m, o * CFrame.new(0, 2.9, 2.7) * CFrame.Angles(rad(15), 0, 0), V(0.2, 2, 0.2), c, M.SmoothPlastic, SOFT)
	return m
end

-- Kanthaka, the white horse who carried the prince from the palace.
function Props.horse(parent, o)
	local c = C.white
	local m = Kit.model(parent, "Kanthaka")
	Kit.block(m, o * CFrame.new(0, 4.6, 0), V(2.2, 2.4, 6), c, M.SmoothPlastic)
	Kit.block(m, o * CFrame.new(0, 6.2, -3.3) * CFrame.Angles(rad(-35), 0, 0), V(1.4, 3.6, 1.6), c, M.SmoothPlastic, NOCOL)
	Kit.block(m, o * CFrame.new(0, 7.7, -4.9) * CFrame.Angles(rad(20), 0, 0), V(1.2, 1.4, 2.6), c, M.SmoothPlastic, NOCOL)
	Kit.block(m, o * CFrame.new(0, 6.6, -2.8) * CFrame.Angles(rad(-35), 0, 0), V(0.4, 3.8, 0.8), C.ivory, M.SmoothPlastic, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(m, o * CFrame.new(sx * 0.4, 8.6, -4.3), V(0.3, 0.7, 0.3), c, M.SmoothPlastic, SOFT)
		for _, sz in ipairs({ -1, 1 }) do
			Kit.block(m, o * CFrame.new(sx * 0.75, 1.75, sz * 2.4), V(0.6, 3.5, 0.6), c, M.SmoothPlastic, NOCOL)
		end
	end
	Kit.block(m, o * CFrame.new(0, 4.2, 3.4) * CFrame.Angles(rad(25), 0, 0), V(0.5, 3, 0.5), C.ivory, M.SmoothPlastic, SOFT)
	Kit.block(m, o * CFrame.new(0, 5.9, 0), V(2.4, 0.3, 2.6), Color3.fromRGB(150, 30, 40), M.Fabric, SOFT)
	Kit.block(m, o * CFrame.new(0, 5.95, 0), V(2.5, 0.25, 1.2), C.gold, M.Fabric, SOFT)
	return m
end

function Props.deer(parent, o, color)
	local c = color or Color3.fromRGB(176, 124, 76)
	Kit.block(parent, o * CFrame.new(0, 2.6, 0), V(1.3, 1.5, 3.4), c, M.SmoothPlastic, NOCOL)
	Kit.block(parent, o * CFrame.new(0, 3.9, -1.7) * CFrame.Angles(rad(-25), 0, 0), V(0.8, 2, 0.8), c, M.SmoothPlastic, SOFT)
	Kit.block(parent, o * CFrame.new(0, 4.9, -2.4), V(0.8, 0.8, 1.4), c, M.SmoothPlastic, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(parent, o * CFrame.new(sx * 0.3, 5.7, -2.1) * CFrame.Angles(0, 0, rad(sx * -20)), V(0.15, 1.2, 0.15), C.bone, M.SmoothPlastic, SOFT)
		for _, sz in ipairs({ -1, 1 }) do
			Kit.block(parent, o * CFrame.new(sx * 0.45, 0.95, sz * 1.3), V(0.3, 1.9, 0.3), c, M.SmoothPlastic, SOFT)
		end
	end
end

-- An elephant. Used for the temple elephant and (scaled up, darkened) for Girimekhala.
function Props.elephant(parent, o, s, color, opts)
	s = s or 1
	opts = opts or {}
	local c = color or Color3.fromRGB(128, 124, 126)
	local m = Kit.model(parent, opts.name or "Elephant")
	Kit.blob(m, o * CFrame.new(0, 8 * s, 1 * s), V(9 * s, 9 * s, 14 * s), c, M.SmoothPlastic)
	Kit.blob(m, o * CFrame.new(0, 9.5 * s, -7 * s), V(7 * s, 7.5 * s, 7 * s), c, M.SmoothPlastic)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.blob(m, o * CFrame.new(sx * 4.4 * s, 9.5 * s, -5.5 * s) * CFrame.Angles(0, rad(sx * 25), 0), V(0.8 * s, 7 * s, 5.5 * s), c, M.SmoothPlastic, NOCOL)
		Kit.cyl(m, o * CFrame.new(sx * 2.6 * s, 2.5 * s, -3.5 * s), 2.8 * s, 5 * s, c, M.SmoothPlastic)
		Kit.cyl(m, o * CFrame.new(sx * 2.6 * s, 2.5 * s, 5 * s), 2.8 * s, 5 * s, c, M.SmoothPlastic)
		Kit.block(m, o * CFrame.new(sx * 1.9 * s, 6.5 * s, -10.6 * s) * CFrame.Angles(rad(55), 0, 0), V(0.7 * s, 5 * s, 0.7 * s), C.bone, M.SmoothPlastic, NOCOL)
		Kit.ball(m, o * CFrame.new(sx * 2.2 * s, 10.6 * s, -9.6 * s), 0.7 * s, opts.eye or C.black, opts.eye and M.Neon or M.SmoothPlastic, SOFT)
	end
	local trunkTop = o * CFrame.new(0, 8.6 * s, -10 * s)
	for i = 0, 4 do
		local seg = trunkTop * CFrame.new(0, -i * 1.7 * s, -i * 0.25 * s)
		Kit.cyl(m, seg, (2.2 - i * 0.3) * s, 1.9 * s, c, M.SmoothPlastic, NOCOL)
	end
	Kit.block(m, o * CFrame.new(0, 6 * s, 8 * s) * CFrame.Angles(rad(20), 0, 0), V(0.5 * s, 5 * s, 0.5 * s), c, M.SmoothPlastic, SOFT)
	if opts.cloth then
		Kit.block(m, o * CFrame.new(0, 12.4 * s, 1 * s), V(8.4 * s, 0.5 * s, 8 * s), opts.cloth, M.Fabric, NOCOL)
		Kit.block(m, o * CFrame.new(4.4 * s, 9.6 * s, 1 * s), V(0.4 * s, 5.6 * s, 7 * s), opts.cloth, M.Fabric, NOCOL)
		Kit.block(m, o * CFrame.new(-4.4 * s, 9.6 * s, 1 * s), V(0.4 * s, 5.6 * s, 7 * s), opts.cloth, M.Fabric, NOCOL)
		Kit.block(m, o * CFrame.new(0, 12.7 * s, 1 * s), V(8.6 * s, 0.2 * s, 2 * s), C.gold, M.Fabric, SOFT)
		Kit.blob(m, o * CFrame.new(0, 12.4 * s, -7.4 * s), V(4 * s, 1.4 * s, 4 * s), opts.cloth, M.Fabric, SOFT)
	end
	return m
end

----------------------------------------------------------------------
-- Animals of the Jataka tales (small still figures)
----------------------------------------------------------------------

function Props.hare(parent, o)
	local c = Color3.fromRGB(206, 186, 154)
	Kit.blob(parent, o * CFrame.new(0, 0.75, 0), V(1.2, 1.1, 1.8), c, M.SmoothPlastic, NOCOL)
	Kit.ball(parent, o * CFrame.new(0, 1.4, -0.9), 0.9, c, M.SmoothPlastic, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(parent, o * CFrame.new(sx * 0.22, 2.2, -0.8) * CFrame.Angles(rad(-10), 0, rad(sx * -8)), V(0.2, 1, 0.3), c, M.SmoothPlastic, SOFT)
		Kit.ball(parent, o * CFrame.new(sx * 0.3, 1.5, -1.25), 0.14, C.black, M.SmoothPlastic, SOFT)
	end
	Kit.ball(parent, o * CFrame.new(0, 0.9, 0.95), 0.45, C.white, M.SmoothPlastic, SOFT)
end

function Props.monkey(parent, o)
	local c = Color3.fromRGB(140, 100, 70)
	local face = Color3.fromRGB(222, 190, 160)
	Kit.blob(parent, o * CFrame.new(0, 1.2, 0), V(1.4, 1.9, 1.3), c, M.SmoothPlastic, NOCOL)
	Kit.ball(parent, o * CFrame.new(0, 2.6, -0.2), 1.1, c, M.SmoothPlastic, SOFT)
	Kit.blob(parent, o * CFrame.new(0, 2.5, -0.65), V(0.75, 0.65, 0.45), face, M.SmoothPlastic, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(parent, o * CFrame.new(sx * 0.85, 1.4, -0.2) * CFrame.Angles(rad(-15), 0, rad(sx * 8)), V(0.35, 1.5, 0.35), c, M.SmoothPlastic, SOFT)
		Kit.block(parent, o * CFrame.new(sx * 0.5, 0.25, -0.7), V(0.4, 0.4, 1.1), c, M.SmoothPlastic, SOFT)
		Kit.ball(parent, o * CFrame.new(sx * 0.6, 2.7, -0.2), 0.4, face, M.SmoothPlastic, SOFT)
		Kit.ball(parent, o * CFrame.new(sx * 0.2, 2.65, -0.85), 0.12, C.black, M.SmoothPlastic, SOFT)
	end
	Kit.block(parent, o * CFrame.new(0, 0.9, 1.3) * CFrame.Angles(rad(40), 0, 0), V(0.2, 0.2, 2.2), c, M.SmoothPlastic, SOFT)
end

function Props.goose(parent, o)
	local c = C.goldBright
	local beak = Color3.fromRGB(226, 120, 40)
	Kit.blob(parent, o * CFrame.new(0, 1.3, 0), V(1.4, 1.3, 2.4), c, M.Metal, NOCOL)
	Kit.block(parent, o * CFrame.new(0, 2.4, -1) * CFrame.Angles(rad(-15), 0, 0), V(0.4, 1.7, 0.4), c, M.Metal, SOFT)
	Kit.ball(parent, o * CFrame.new(0, 3.3, -1.25), 0.7, c, M.Metal, SOFT)
	Kit.block(parent, o * CFrame.new(0, 3.25, -1.75), V(0.25, 0.2, 0.6), beak, M.SmoothPlastic, SOFT)
	Kit.block(parent, o * CFrame.new(0, 1.7, 1.3) * CFrame.Angles(rad(25), 0, 0), V(0.9, 0.2, 0.9), c, M.Metal, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(parent, o * CFrame.new(sx * 0.3, 0.35, 0), V(0.15, 0.7, 0.15), beak, M.SmoothPlastic, SOFT)
		Kit.blob(parent, o * CFrame.new(sx * 0.7, 1.45, 0.15), V(0.3, 0.9, 1.8), c, M.Metal, SOFT)
		Kit.ball(parent, o * CFrame.new(sx * 0.3, 3.4, -1.45), 0.12, C.black, M.SmoothPlastic, SOFT)
	end
end

function Props.quail(parent, o)
	local c = Color3.fromRGB(150, 120, 90)
	Kit.blob(parent, o * CFrame.new(0, 0.6, 0), V(1, 0.9, 1.3), c, M.SmoothPlastic, NOCOL)
	Kit.ball(parent, o * CFrame.new(0, 1.1, -0.5), 0.55, c, M.SmoothPlastic, SOFT)
	Kit.block(parent, o * CFrame.new(0, 1.05, -0.85), V(0.14, 0.12, 0.25), Color3.fromRGB(60, 50, 40), M.SmoothPlastic, SOFT)
	Kit.block(parent, o * CFrame.new(0, 1.55, -0.5) * CFrame.Angles(rad(-20), 0, 0), V(0.08, 0.45, 0.08), C.black, M.SmoothPlastic, SOFT)
	Kit.blob(parent, o * CFrame.new(0, 0.55, 0.1), V(1.05, 0.5, 0.9), Color3.fromRGB(196, 170, 130), M.SmoothPlastic, SOFT)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.ball(parent, o * CFrame.new(sx * 0.22, 1.18, -0.7), 0.09, C.black, M.SmoothPlastic, SOFT)
	end
end

----------------------------------------------------------------------
-- The Eight Auspicious Symbols (floating golden figures). "o" is the centre.
----------------------------------------------------------------------
local FIND = { collide = false, shadow = false }

function Props.symbol(parent, o, id)
	local gold = C.goldBright
	local red = Color3.fromRGB(190, 40, 44)
	if id == "vase" then
		Kit.blob(parent, o, V(1.9, 1.9, 1.9), gold, M.Metal, FIND)
		Kit.cyl(parent, o * CFrame.new(0, -1, 0), 1.1, 0.3, gold, M.Metal, FIND)
		Kit.cyl(parent, o * CFrame.new(0, 1.1, 0), 0.9, 0.7, gold, M.Metal, FIND)
		Kit.cyl(parent, o * CFrame.new(0, 1.5, 0), 1.4, 0.2, gold, M.Metal, FIND)
		Kit.ball(parent, o * CFrame.new(0, 1.95, 0), 0.6, red, M.Neon, FIND)
	elseif id == "parasol" then
		Kit.cyl(parent, o, 0.2, 3.2, gold, M.Metal, FIND)
		Kit.blob(parent, o * CFrame.new(0, 1.7, 0), V(3, 1.3, 3), gold, M.Metal, FIND)
		Kit.cyl(parent, o * CFrame.new(0, 1.3, 0), 3, 0.3, red, M.Fabric, FIND)
		Kit.ball(parent, o * CFrame.new(0, 2.45, 0), 0.45, gold, M.Neon, FIND)
	elseif id == "fishes" then
		for _, sx in ipairs({ -1, 1 }) do
			local f = o * CFrame.new(sx * 0.6, 0, 0) * CFrame.Angles(rad(sx * 90 - 90), rad(sx * 12), 0)
			Kit.blob(parent, f, V(0.7, 1, 2.3), gold, M.Metal, FIND)
			Kit.block(parent, f * CFrame.new(0, 0, 1.35), V(0.1, 0.9, 0.6), gold, M.Metal, FIND)
			Kit.ball(parent, f * CFrame.new(0.3, 0.15, -0.75), 0.16, C.black, M.SmoothPlastic, FIND)
		end
	elseif id == "knot" then
		local k = o * CFrame.Angles(0, 0, rad(45))
		for _, d in ipairs({ -0.75, 0, 0.75 }) do
			Kit.block(parent, k * CFrame.new(d, 0, 0), V(0.3, 2.6, 0.3), gold, M.Metal, FIND)
			Kit.block(parent, k * CFrame.new(0, d, 0), V(2.6, 0.3, 0.34), gold, M.Metal, FIND)
		end
	elseif id == "conch" then
		Kit.blob(parent, o, V(1.5, 1.5, 2.4), C.white, M.SmoothPlastic, FIND)
		Kit.blob(parent, o * CFrame.new(0, 0, -1.2), V(1, 1, 1.5), C.white, M.SmoothPlastic, FIND)
		Kit.ball(parent, o * CFrame.new(0, 0, 1.3), 0.6, gold, M.Metal, FIND)
		Kit.ball(parent, o * CFrame.new(0, 0, -2), 0.4, gold, M.Metal, FIND)
	elseif id == "lotus" then
		Props.lotus(parent, o * CFrame.new(0, -0.6, 0), gold, true)
	elseif id == "banner" then
		Kit.cyl(parent, o, 0.2, 3.8, gold, M.Metal, FIND)
		Kit.cyl(parent, o * CFrame.new(0, 0.6, 0), 1.3, 1.6, red, M.Fabric, FIND)
		Kit.cyl(parent, o * CFrame.new(0, -0.3, 0), 1.5, 0.2, gold, M.Metal, FIND)
		Kit.cyl(parent, o * CFrame.new(0, 1.5, 0), 1.7, 0.25, gold, M.Metal, FIND)
		Kit.ball(parent, o * CFrame.new(0, 2.1, 0), 0.5, gold, M.Neon, FIND)
	else -- the wheel
		local face = o * CFrame.Angles(rad(90), 0, 0)
		Kit.cyl(parent, face, 2.8, 0.25, gold, M.Metal, FIND)
		Kit.cyl(parent, face, 0.8, 0.5, red, M.Metal, FIND)
		for i = 0, 3 do
			Kit.block(parent, o * CFrame.Angles(0, 0, rad(i * 45)), V(0.18, 3.3, 0.3), gold, M.Metal, FIND)
		end
	end
end

return Props
