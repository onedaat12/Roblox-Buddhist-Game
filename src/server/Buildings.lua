-- Buildings: temples, stupas, gateways, houses and the other architecture of the journey.
-- Styles are drawn from Buddhist India and the wider Buddhist world: the stone spire of the
-- Mahabodhi temple, the domed stupas and carved gateways (toranas) of Sanchi, mud-walled
-- village houses, tiered East Asian roofs, Tibetan prayer wheels and prayer flags.
-- Structures treat -Z as their front.

local Kit = require(script.Parent.Kit)
local Props = require(script.Parent.Props)
local C = Kit.C
local M = Enum.Material

local B = {}

local function V(x, y, z)
	return Vector3.new(x, y, z)
end
local rad = math.rad
local NOCOL = { collide = false }
local SOFT = { collide = false, shadow = false }

----------------------------------------------------------------------
-- Statues
----------------------------------------------------------------------

-- A seated Buddha. mudra = "meditation" (hands in the lap) or "earth" (right hand
-- touching the ground, calling the earth to witness).
function B.buddha(parent, o, s, mudra, color)
	s = s or 1
	local g = color or C.gold
	local mat = M.Metal
	local m = Kit.model(parent, "BuddhaStatue")
	local function at(x, y, z)
		return o * CFrame.new(x * s, y * s, z * s)
	end
	Kit.cyl(m, at(0, 0.6, 0), 7.4 * s, 1.2 * s, C.lotusPink, M.SmoothPlastic)
	Kit.cyl(m, at(0, 1.45, 0), 6.4 * s, 0.5 * s, g, mat)
	Kit.blob(m, at(0, 2.5, -0.3), V(6 * s, 1.7 * s, 4 * s), g, mat, NOCOL)
	Kit.blob(m, at(0, 4.7, 0.2), V(3.6 * s, 4.4 * s, 2.4 * s), g, mat, NOCOL)
	Kit.blob(m, at(-1.9, 4.6, 0) * CFrame.Angles(0, 0, rad(-10)), V(1.2 * s, 3.2 * s, 1.4 * s), g, mat, NOCOL)
	if mudra == "earth" then
		Kit.blob(m, at(2.3, 4.2, -0.6) * CFrame.Angles(rad(-25), 0, rad(8)), V(1.1 * s, 3.4 * s, 1.2 * s), g, mat, NOCOL)
		Kit.blob(m, at(2.7, 2.3, -1.9), V(0.8 * s, 1.5 * s, 0.7 * s), g, mat, NOCOL)
		Kit.blob(m, at(-0.4, 3.1, -1.5), V(1.6 * s, 0.6 * s, 1.1 * s), g, mat, NOCOL)
	else
		Kit.blob(m, at(1.9, 4.6, 0) * CFrame.Angles(0, 0, rad(10)), V(1.2 * s, 3.2 * s, 1.4 * s), g, mat, NOCOL)
		Kit.blob(m, at(0, 3.1, -1.5), V(2.4 * s, 0.7 * s, 1.2 * s), g, mat, NOCOL)
	end
	Kit.cyl(m, at(0, 6.6, 0), 1 * s, 0.6 * s, g, mat, NOCOL)
	Kit.ball(m, at(0, 7.6, 0), 2.1 * s, g, mat, NOCOL)
	Kit.ball(m, at(0, 8.75, 0.1), 0.9 * s, g, mat, NOCOL)
	Kit.block(m, at(-1.08, 7.4, 0), V(0.25 * s, 1.1 * s, 0.4 * s), g, mat, SOFT)
	Kit.block(m, at(1.08, 7.4, 0), V(0.25 * s, 1.1 * s, 0.4 * s), g, mat, SOFT)
	Kit.cyl(m, at(0, 7.7, 1.25) * CFrame.Angles(rad(90), 0, 0), 4.8 * s, 0.2 * s, C.goldBright, M.SmoothPlastic, { collide = false, shadow = false, transparency = 0.25 })
	return m
end

-- Mucalinda, the naga king, sheltering the seated Buddha beneath his seven hoods.
function B.naga(parent, o, s)
	s = s or 1
	local st = Color3.fromRGB(96, 122, 104)
	local m = Kit.model(parent, "Mucalinda")
	local function at(x, y, z)
		return o * CFrame.new(x * s, y * s, z * s)
	end
	Kit.cyl(m, at(0, 1, 0), 11 * s, 2 * s, st, M.Slate)
	Kit.cyl(m, at(0, 3, 0), 9 * s, 2 * s, st, M.Slate)
	Kit.cyl(m, at(0, 5, 0), 7 * s, 2 * s, st, M.Slate)
	B.buddha(m, at(0, 6, -0.4), 0.62 * s, "meditation", C.gold)
	Kit.block(m, at(0, 10, 3) * CFrame.Angles(rad(-8), 0, 0), V(3 * s, 10 * s, 1.6 * s), st, M.Slate, NOCOL)
	for i = -3, 3 do
		local hood = at(i * 1.5, 14.5 - math.abs(i) * 0.6, 2.4 - math.abs(i) * 0.1) * CFrame.Angles(rad(-28), 0, rad(-i * 11))
		Kit.blob(m, hood, V(2.4 * s, 4.2 * s, 1.6 * s), st, M.Slate, NOCOL)
		Kit.ball(m, hood * CFrame.new(0.5 * s, 1 * s, -0.8 * s), 0.3 * s, C.goldBright, M.Neon, SOFT)
		Kit.ball(m, hood * CFrame.new(-0.5 * s, 1 * s, -0.8 * s), 0.3 * s, C.goldBright, M.Neon, SOFT)
	end
	return m
end

----------------------------------------------------------------------
-- Stupas, shrines, gateways
----------------------------------------------------------------------

function B.stupa(parent, o, r, opts)
	opts = opts or {}
	local white = opts.color or C.white
	local m = Kit.model(parent, opts.name or "Stupa")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	local plinth = Kit.block(m, at(0, 0.75, 0), V(2.7 * r, 1.5, 2.7 * r), C.sandstone, M.Sandstone)
	Kit.cyl(m, at(0, 1.5 + 0.3 * r, 0), 2.24 * r, 0.6 * r, white, M.Concrete)
	Kit.cyl(m, at(0, 1.5 + 0.62 * r, 0), 2.3 * r, 0.14 * r, C.gold, M.Metal, NOCOL)
	Kit.ball(m, at(0, 1.5 + 0.6 * r, 0), 2 * r, white, M.Concrete)
	local top = 1.5 + 1.6 * r
	Kit.block(m, at(0, top + 0.2 * r, 0), V(0.62 * r, 0.44 * r, 0.62 * r), C.ivory, M.Sandstone, NOCOL)
	Kit.cyl(m, at(0, top + 0.4 * r + 0.5 * r, 0), 0.14 * r, 1 * r, C.gold, M.Metal, NOCOL)
	Kit.cyl(m, at(0, top + 0.68 * r, 0), 0.9 * r, 0.1 * r, C.gold, M.Metal, NOCOL)
	Kit.cyl(m, at(0, top + 0.93 * r, 0), 0.66 * r, 0.1 * r, C.gold, M.Metal, NOCOL)
	Kit.cyl(m, at(0, top + 1.18 * r, 0), 0.42 * r, 0.1 * r, C.gold, M.Metal, NOCOL)
	Kit.ball(m, at(0, top + 1.5 * r, 0), 0.28 * r, C.goldBright, M.Metal, SOFT)
	return m, plinth
end

-- A wayside shrine: a small stupa with butter lamps. Returns the part that holds the prompt.
function B.shrine(parent, o, name)
	local m, plinth = B.stupa(parent, o, 3.2, { name = "Shrine" })
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			Props.butterLamp(m, o * CFrame.new(sx * 3.7, 1.5, sz * 3.7))
		end
	end
	Kit.block(m, o * CFrame.new(0, 0.2, 0), V(13, 0.4, 13), C.stone, M.Cobblestone)
	local glow = Kit.ball(m, o * CFrame.new(0, 12.2, 0), 0.9, C.goldBright, M.Neon, SOFT)
	Kit.light(glow, Color3.fromRGB(255, 220, 150), 26, 1.2)
	Kit.sparkle(glow, C.goldBright, 5)
	Kit.sign(plinth, name or "Shrine", C.goldBright, 14, 140)
	return m, plinth
end

-- A torana: the carved stone gateway of the great stupas. The opening runs along local X.
function B.torana(parent, o, w, h, color)
	w = w or 20
	h = h or 22
	local col = color or C.sandstone
	local m = Kit.model(parent, "Torana")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(m, at(sx * w / 2, h / 2, 0), V(2.8, h, 2.8), col, M.Sandstone)
		Kit.block(m, at(sx * w / 2, 0.6, 0), V(4, 1.2, 4), C.sandstoneDark, M.Sandstone)
		Kit.block(m, at(sx * w / 2, h * 0.6, 0), V(3.6, 1, 3.6), C.sandstoneLight, M.Sandstone, NOCOL)
		Kit.ball(m, at(sx * w / 2, h + 1.2, 0), 2, C.gold, M.Metal, SOFT)
	end
	local ys = { h - 1, h - 4.2, h - 7.4 }
	for i, y in ipairs(ys) do
		Kit.block(m, at(0, y, 0), V(w + 10 - i, 1.5, 2.3), C.sandstoneLight, M.Sandstone, NOCOL)
		for _, sx in ipairs({ -1, 1 }) do
			Kit.cyl(m, at(sx * (w / 2 + 5 - i / 2), y, 0) * CFrame.Angles(rad(90), 0, 0), 2.3, 2.3, col, M.Sandstone, SOFT)
		end
	end
	for _, x in ipairs({ -w / 4, 0, w / 4 }) do
		Kit.block(m, at(x, h - 2.6, 0), V(1.2, 1.8, 1.6), col, M.Sandstone, SOFT)
		Kit.block(m, at(x, h - 5.8, 0), V(1.2, 1.8, 1.6), col, M.Sandstone, SOFT)
	end
	-- The Dharma wheel at the summit.
	Kit.cyl(m, at(0, h + 2.4, 0) * CFrame.Angles(rad(90), 0, 0), 4.4, 0.5, C.gold, M.Metal, SOFT)
	Kit.cyl(m, at(0, h + 2.4, 0) * CFrame.Angles(rad(90), 0, 0), 1.2, 0.8, C.goldBright, M.Metal, SOFT)
	for i = 0, 3 do
		Kit.block(m, at(0, h + 2.4, 0) * CFrame.Angles(0, 0, rad(i * 45)), V(4.2, 0.25, 0.6), C.goldBright, M.Metal, SOFT)
	end
	return m
end

-- A straight wall between two ground points.
function B.wall(parent, x1, z1, x2, z2, h, color, material, cap)
	local p1 = Vector3.new(x1, 0, z1)
	local p2 = Vector3.new(x2, 0, z2)
	local len = (p2 - p1).Magnitude
	if len < 0.5 then
		return
	end
	local cf = CFrame.new((p1 + p2) / 2, p2)
	Kit.block(parent, cf * CFrame.new(0, h / 2, 0), V(2.4, h, len), color or C.sandstone, material or M.Sandstone)
	if cap ~= false then
		Kit.block(parent, cf * CFrame.new(0, h + 0.4, 0), V(3.2, 0.8, len + 0.4), C.sandstoneDark, material or M.Sandstone, NOCOL)
	end
end

----------------------------------------------------------------------
-- Houses, huts, shops
----------------------------------------------------------------------

-- A village house you can walk into. opts: w, d, h, door, wall, roof ("thatch", "tile", "flat"), interior
function B.house(parent, o, opts)
	opts = opts or {}
	local w, d, h = opts.w or 22, opts.d or 18, opts.h or 10
	local wallC = opts.wall or C.mud
	local wallM = M.Sandstone
	local t = 1.2
	local door = opts.door or 6
	local doorH = 7.6
	local y0 = 0.7
	local m = Kit.model(parent, opts.name or "House")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	Kit.block(m, at(0, y0 / 2, 0), V(w + 2, y0, d + 2), C.mudDark, M.Sandstone)
	Kit.block(m, at(0, y0 + h / 2, d / 2 - t / 2), V(w, h, t), wallC, wallM)
	Kit.block(m, at(-w / 2 + t / 2, y0 + h / 2, 0), V(t, h, d - 2 * t), wallC, wallM)
	Kit.block(m, at(w / 2 - t / 2, y0 + h / 2, 0), V(t, h, d - 2 * t), wallC, wallM)
	local side = (w - door) / 2
	Kit.block(m, at(-(door / 2 + side / 2), y0 + h / 2, -d / 2 + t / 2), V(side, h, t), wallC, wallM)
	Kit.block(m, at(door / 2 + side / 2, y0 + h / 2, -d / 2 + t / 2), V(side, h, t), wallC, wallM)
	Kit.block(m, at(0, y0 + doorH + (h - doorH) / 2, -d / 2 + t / 2), V(door, h - doorH, t), wallC, wallM)
	-- wooden door frame and a painted band along the base of the wall
	Kit.block(m, at(-door / 2 - 0.3, y0 + doorH / 2, -d / 2 + t / 2), V(0.6, doorH, t + 0.3), C.woodDark, M.Wood, NOCOL)
	Kit.block(m, at(door / 2 + 0.3, y0 + doorH / 2, -d / 2 + t / 2), V(0.6, doorH, t + 0.3), C.woodDark, M.Wood, NOCOL)
	Kit.block(m, at(0, y0 + doorH + 0.3, -d / 2 + t / 2), V(door + 1.2, 0.6, t + 0.3), C.woodDark, M.Wood, NOCOL)
	Kit.block(m, at(0, 0.2, -d / 2 - 1.8), V(door + 2, 0.4, 2.6), C.stone, M.Slate)
	local band = opts.band or C.redstone
	Kit.block(m, at(-(door / 2 + side / 2), y0 + 1, -d / 2 - 0.05), V(side, 2, 0.2), band, wallM, SOFT)
	Kit.block(m, at(door / 2 + side / 2, y0 + 1, -d / 2 - 0.05), V(side, 2, 0.2), band, wallM, SOFT)
	-- small windows (dark insets) on the side walls
	Kit.block(m, at(-w / 2 - 0.05, y0 + h * 0.6, 0), V(0.2, 2.6, 3), C.woodDark, M.Wood, SOFT)
	Kit.block(m, at(w / 2 + 0.05, y0 + h * 0.6, 0), V(0.2, 2.6, 3), C.woodDark, M.Wood, SOFT)

	local yTop = y0 + h
	local roof = opts.roof or "thatch"
	if roof == "flat" then
		Kit.block(m, at(0, yTop + 0.4, 0), V(w + 1.4, 0.8, d + 1.4), C.mudDark, wallM)
		Kit.block(m, at(0, yTop + 1.4, d / 2 + 0.3), V(w + 1.4, 1.4, 0.8), wallC, wallM, NOCOL)
		Kit.block(m, at(0, yTop + 1.4, -d / 2 - 0.3), V(w + 1.4, 1.4, 0.8), wallC, wallM, NOCOL)
		Kit.block(m, at(w / 2 + 0.3, yTop + 1.4, 0), V(0.8, 1.4, d), wallC, wallM, NOCOL)
		Kit.block(m, at(-w / 2 - 0.3, yTop + 1.4, 0), V(0.8, 1.4, d), wallC, wallM, NOCOL)
	else
		local roofC = (roof == "tile") and C.terracotta or C.thatch
		local roofM = (roof == "tile") and M.Slate or M.Grass
		local a = rad(30)
		local run = d / 2 + 2.2
		local len = run / math.cos(a)
		local rise = run * math.tan(a)
		for _, sgn in ipairs({ -1, 1 }) do
			Kit.block(m, at(0, yTop + rise / 2 - 0.2, sgn * run / 2) * CFrame.Angles(sgn * a, 0, 0), V(w + 4, 0.9, len + 0.6), roofC, roofM)
		end
		Kit.block(m, at(0, yTop + rise + 0.1, 0), V(w + 4.6, 0.8, 1.2), C.woodDark, M.Wood, NOCOL)
		local gableRise = (d / 2) * math.tan(a)
		for _, sx in ipairs({ -1, 1 }) do
			for i = 0, 2 do
				local frac = (i + 0.5) / 3
				Kit.block(m, at(sx * (w / 2 - t / 2), yTop + frac * gableRise, 0), V(t, gableRise / 3 + 0.05, (d - 1) * (1 - frac)), wallC, wallM, NOCOL)
			end
		end
	end

	if opts.interior ~= false then
		Kit.block(m, at(-w / 4, y0 + 0.08, 1), V(w / 3, 0.16, d / 2), opts.rug or Color3.fromRGB(150, 50, 50), M.Fabric, SOFT)
		Kit.block(m, at(w / 2 - 3.4, y0 + 1, d / 2 - 4), V(3.6, 0.5, 6.4), C.wood, M.WoodPlanks, NOCOL)
		Kit.block(m, at(w / 2 - 3.4, y0 + 1.4, d / 2 - 4), V(3.2, 0.4, 6), C.ivory, M.Fabric, SOFT)
		Props.pot(m, at(-w / 2 + 2.6, y0, d / 2 - 2.6), 1)
		Props.pot(m, at(-w / 2 + 5, y0, d / 2 - 2.4), 0.7, C.mudDark)
		local lamp = Props.butterLamp(m, at(0, y0, d / 2 - 2))
		Kit.light(lamp, Color3.fromRGB(255, 200, 140), 22, 1)
	end
	return m
end

-- A round thatched hut (hermitages and forest dwellings).
function B.hut(parent, o, r)
	r = r or 7
	local m = Kit.model(parent, "Hut")
	local n = 10
	for i = 1, n - 1 do
		local a = (i / n) * math.pi * 2 - math.pi / 2
		-- the gap (i = 0) is the doorway, facing -Z
		local cf = o * CFrame.new(math.cos(a) * r, 3.5, math.sin(a) * r) * CFrame.Angles(0, -a + math.pi / 2, 0)
		Kit.block(m, cf, V(2 * r * math.sin(math.pi / n) + 0.5, 7, 0.9), C.mud, M.Sandstone)
	end
	for i = 0, 4 do
		Kit.cyl(m, o * CFrame.new(0, 7.5 + i * 1.5, 0), (2 * r + 4) * (1 - i / 5.2), 1.6, (i % 2 == 0) and C.thatch or Color3.fromRGB(180, 148, 80), M.Grass, NOCOL)
	end
	Kit.cyl(m, o * CFrame.new(0, 0.15, 0), 2 * r, 0.3, C.mudDark, M.Sandstone, SOFT)
	return m
end

-- A shop: a larger house with a counter, shelves of goods, an awning and a sign.
function B.shop(parent, o, title, opts)
	opts = opts or {}
	local w, d, h = 30, 24, 12
	local m = B.house(parent, o, { w = w, d = d, h = h, door = 9, roof = opts.roof or "tile", wall = opts.wall or C.ivory, band = opts.band or C.saffron, interior = false, name = "Shop" })
	local y0 = 0.7
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	Kit.block(m, at(0, y0 + 1.7, 4), V(16, 3.4, 2.2), C.wood, M.WoodPlanks)
	Kit.block(m, at(0, y0 + 3.5, 4), V(16.6, 0.3, 2.8), C.woodDark, M.WoodPlanks, NOCOL)
	for _, sx in ipairs({ -1, 1 }) do
		for tier = 0, 2 do
			Kit.block(m, at(sx * (w / 2 - 2.4), y0 + 2.4 + tier * 2.8, 2), V(2.2, 0.3, 14), C.woodDark, M.WoodPlanks, NOCOL)
			for k = -2, 2 do
				local goods = opts.goods or { C.saffron, C.maroon, C.gold, C.flagBlue, C.terracotta, C.ivory }
				local color = goods[(k + tier * 2 + sx + 6) % #goods + 1]
				Kit.block(m, at(sx * (w / 2 - 2.4), y0 + 3.2 + tier * 2.8, 2 + k * 2.6), V(1.6, 1.3, 1.8), color, M.Fabric, SOFT)
			end
		end
	end
	Props.pot(m, at(-9, y0, 9), 1.1)
	Props.pot(m, at(9, y0, 9), 1.1, C.bronze)
	Kit.block(m, at(0, y0 + 0.08, -4), V(12, 0.16, 9), opts.rug or Color3.fromRGB(150, 50, 50), M.Fabric, SOFT)
	local lamp = Kit.ball(m, at(0, y0 + h - 1.5, 0), 1.2, Color3.fromRGB(255, 214, 150), M.Neon, SOFT)
	Kit.light(lamp, Color3.fromRGB(255, 205, 140), 40, 1.3)
	-- awning over the door
	Kit.block(m, at(0, y0 + 9.4, -d / 2 - 2.4) * CFrame.Angles(rad(-18), 0, 0), V(14, 0.3, 5.4), opts.awning or C.saffron, M.Fabric, NOCOL)
	Kit.cyl(m, at(-6.5, 4.6, -d / 2 - 4.6), 0.4, 9.2, C.woodDark, M.Wood)
	Kit.cyl(m, at(6.5, 4.6, -d / 2 - 4.6), 0.4, 9.2, C.woodDark, M.Wood)
	local board = Kit.block(m, at(0, y0 + h + 1.4, -d / 2 - 0.4), V(15, 2.6, 0.4), C.woodDark, M.WoodPlanks, NOCOL)
	Kit.plaque(board, title, C.goldBright, { Enum.NormalId.Front })
	return m
end

----------------------------------------------------------------------
-- The great temple (a shikhara tower in the manner of the Mahabodhi temple)
----------------------------------------------------------------------
function B.temple(parent, o)
	local m = Kit.model(parent, "Temple")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	local stone, dark, light = C.sandstone, C.sandstoneDark, C.sandstoneLight
	-- platform and front steps
	Kit.block(m, at(0, 2, 0), V(60, 4, 60), dark, M.Sandstone)
	for i = 1, 3 do
		Kit.block(m, at(0, (4 - i) / 2, -30 - (i - 0.5) * 2.4), V(22, 4 - i, 2.4), stone, M.Sandstone)
	end
	-- sanctum walls (36 x 36, door at the front)
	local hh, base = 18, 4
	Kit.block(m, at(0, base + hh / 2, 17), V(36, hh, 2), stone, M.Sandstone)
	Kit.block(m, at(-17, base + hh / 2, 0), V(2, hh, 32), stone, M.Sandstone)
	Kit.block(m, at(17, base + hh / 2, 0), V(2, hh, 32), stone, M.Sandstone)
	Kit.block(m, at(-11.5, base + hh / 2, -17), V(13, hh, 2), stone, M.Sandstone)
	Kit.block(m, at(11.5, base + hh / 2, -17), V(13, hh, 2), stone, M.Sandstone)
	Kit.block(m, at(0, base + 12 + 3, -17), V(10, 6, 2), stone, M.Sandstone)
	Kit.block(m, at(0, base + 12.3, -17.2), V(11.6, 0.8, 2.6), C.gold, M.Metal, NOCOL)
	-- porch
	for _, x in ipairs({ -14, -6, 6, 14 }) do
		Kit.cyl(m, at(x, base + 6.5, -24), 2, 13, light, M.Sandstone)
		Kit.block(m, at(x, base + 0.5, -24), V(3, 1, 3), dark, M.Sandstone, NOCOL)
		Kit.block(m, at(x, base + 12.6, -24), V(3, 0.8, 3), dark, M.Sandstone, NOCOL)
	end
	Kit.block(m, at(0, base + 13.6, -22), V(36, 1.2, 10), dark, M.Sandstone)
	Kit.block(m, at(0, base + 14.7, -22), V(32, 1, 8), stone, M.Sandstone, NOCOL)
	-- roof of the sanctum and the tower above it
	Kit.block(m, at(0, base + hh + 0.5, 0), V(39, 1, 39), dark, M.Sandstone)
	local y = base + hh + 1
	local tiers = 9
	for i = 0, tiers - 1 do
		local size = 34 - i * 3
		Kit.block(m, at(0, y + 2.1, 0), V(size, 4.2, size), (i % 2 == 0) and stone or light, M.Sandstone)
		Kit.block(m, at(0, y + 0.3, 0), V(size + 1.4, 0.6, size + 1.4), dark, M.Sandstone, NOCOL)
		-- a small niche on each face
		if size > 14 then
			Kit.block(m, at(0, y + 2.2, -size / 2 - 0.1), V(3, 2.6, 0.3), C.gold, M.Metal, SOFT)
			Kit.block(m, at(0, y + 2.2, size / 2 + 0.1), V(3, 2.6, 0.3), C.gold, M.Metal, SOFT)
			Kit.block(m, at(-size / 2 - 0.1, y + 2.2, 0), V(0.3, 2.6, 3), C.gold, M.Metal, SOFT)
			Kit.block(m, at(size / 2 + 0.1, y + 2.2, 0), V(0.3, 2.6, 3), C.gold, M.Metal, SOFT)
		end
		y = y + 4.2
	end
	Kit.blob(m, at(0, y + 1.8, 0), V(12, 4, 12), dark, M.Sandstone, NOCOL)
	Kit.ball(m, at(0, y + 5, 0), 3.4, C.gold, M.Metal, NOCOL)
	Kit.cyl(m, at(0, y + 9, 0), 0.7, 6, C.gold, M.Metal, NOCOL)
	Kit.ball(m, at(0, y + 12.2, 0), 1.1, C.goldBright, M.Metal, SOFT)
	-- four corner towers
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			local cy = base
			for i = 0, 3 do
				local size = 8 - i * 1.6
				Kit.block(m, at(sx * 24, cy + 1.6, sz * 24), V(size, 3.2, size), (i % 2 == 0) and stone or light, M.Sandstone)
				cy = cy + 3.2
			end
			Kit.ball(m, at(sx * 24, cy + 0.8, sz * 24), 1.8, C.gold, M.Metal, SOFT)
		end
	end
	-- inside: the image, an altar, lamps and incense
	B.buddha(m, at(0, base, 9), 1.5, "earth")
	Kit.block(m, at(0, base + 1, 1.5), V(10, 2, 3), C.woodRed, M.Wood)
	Kit.block(m, at(0, base + 2.1, 1.5), V(10.6, 0.3, 3.4), C.gold, M.Metal, NOCOL)
	for _, x in ipairs({ -3.6, 0, 3.6 }) do
		Props.butterLamp(m, at(x, base + 2.25, 1.5))
	end
	Props.incenseBurner(m, at(0, base, -6))
	Kit.block(m, at(0, base + 0.06, -8), V(12, 0.12, 14), C.maroon, M.Fabric, SOFT)
	local glow = Kit.block(m, at(0, base + 15, 0), V(1, 1, 1), C.goldBright, M.Neon, { collide = false, shadow = false, transparency = 1 })
	Kit.light(glow, Color3.fromRGB(255, 205, 140), 46, 1.5)
	for _, sx in ipairs({ -1, 1 }) do
		Kit.block(m, at(sx * 12, base + 9, 15.8), V(5, 14, 0.3), (sx == -1) and C.maroon or C.saffron, M.Fabric, SOFT)
	end
	return m
end

----------------------------------------------------------------------
-- East Asian roofs: the meditation hall and the pagoda
----------------------------------------------------------------------
local function tierRoof(m, cf, w, d, tileColor)
	Kit.block(m, cf * CFrame.new(0, 0.5, 0), V(w + 9, 1, d + 9), tileColor, M.Slate)
	Kit.block(m, cf * CFrame.new(0, 1.5, 0), V(w + 4, 1, d + 4), tileColor, M.Slate, NOCOL)
	Kit.block(m, cf * CFrame.new(0, 2.4, 0), V(w - 1, 0.8, d - 1), tileColor, M.Slate, NOCOL)
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			local corner = cf * CFrame.new(sx * (w + 9) / 2, 1, sz * (d + 9) / 2) * CFrame.Angles(0, rad(45), 0) * CFrame.Angles(rad(18 * -sz), 0, rad(18 * sx))
			Kit.block(m, corner, V(4, 0.8, 4), tileColor, M.Slate, SOFT)
			Kit.ball(m, cf * CFrame.new(sx * (w + 10.5) / 2, 2.2, sz * (d + 10.5) / 2), 0.9, C.gold, M.Metal, SOFT)
		end
	end
end

-- An open-sided meditation hall.
function B.hall(parent, o)
	local m = Kit.model(parent, "MeditationHall")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	Kit.block(m, at(0, 1, 0), V(48, 2, 38), C.stone, M.Cobblestone)
	Kit.block(m, at(0, 0.5, -20.2), V(20, 1, 2.4), C.stone, M.Cobblestone)
	Kit.block(m, at(0, 2.06, 0), V(44, 0.12, 34), C.wood, M.WoodPlanks, SOFT)
	for _, x in ipairs({ -21, -10.5, 0, 10.5, 21 }) do
		for _, z in ipairs({ -16, 16 }) do
			Kit.cyl(m, at(x, 8, z), 1.8, 12, C.woodRed, M.Wood)
			Kit.block(m, at(x, 2.4, z), V(2.6, 0.8, 2.6), C.stoneDark, M.Slate, NOCOL)
		end
	end
	for _, x in ipairs({ -21, 21 }) do
		Kit.cyl(m, at(x, 8, 0), 1.8, 12, C.woodRed, M.Wood)
	end
	Kit.block(m, at(0, 13.6, -16), V(46, 1.2, 1.4), C.woodDark, M.Wood, NOCOL)
	Kit.block(m, at(0, 13.6, 16), V(46, 1.2, 1.4), C.woodDark, M.Wood, NOCOL)
	Kit.block(m, at(-21, 13.6, 0), V(1.4, 1.2, 34), C.woodDark, M.Wood, NOCOL)
	Kit.block(m, at(21, 13.6, 0), V(1.4, 1.2, 34), C.woodDark, M.Wood, NOCOL)
	tierRoof(m, at(0, 14.2, 0), 46, 36, C.tileTeal)
	Kit.block(m, at(0, 18.8, 0), V(30, 4, 20), C.woodRed, M.Wood, NOCOL)
	Kit.block(m, at(0, 18.8, -10.1), V(22, 2.4, 0.2), C.gold, M.Metal, SOFT)
	tierRoof(m, at(0, 20.8, 0), 30, 20, C.tileTeal)
	Kit.block(m, at(0, 24.6, 0), V(26, 1.4, 2), C.gold, M.Metal, SOFT)
	-- inside
	Kit.block(m, at(0, 8, 15.2), V(20, 12, 0.6), C.ivory, M.Sandstone)
	B.buddha(m, at(0, 2, 11), 0.9, "meditation")
	for _, x in ipairs({ -12, -6, 0, 6, 12 }) do
		for _, z in ipairs({ -9, -3, 3 }) do
			Kit.cyl(m, at(x, 2.4, z), 2.6, 0.6, (math.abs(x) == 6) and C.saffron or C.maroon, M.Fabric, SOFT)
		end
	end
	Props.butterLamp(m, at(-5, 2.1, 11))
	Props.butterLamp(m, at(5, 2.1, 11))
	local glow = Kit.block(m, at(0, 11, 0), V(1, 1, 1), C.goldBright, M.Neon, { collide = false, shadow = false, transparency = 1 })
	Kit.light(glow, Color3.fromRGB(255, 210, 150), 44, 1.2)
	return m
end

-- A tiered pagoda tower.
function B.pagoda(parent, o, tiers, baseW, tileColor)
	tiers = tiers or 5
	baseW = baseW or 22
	local m = Kit.model(parent, "Pagoda")
	Kit.block(m, o * CFrame.new(0, 1, 0), V(baseW + 12, 2, baseW + 12), C.stone, M.Cobblestone)
	local y = 2
	for i = 0, tiers - 1 do
		local w = baseW - i * 3.2
		Kit.block(m, o * CFrame.new(0, y + 3.5, 0), V(w, 7, w), C.ivory, M.Sandstone)
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				Kit.block(m, o * CFrame.new(sx * w / 2, y + 3.5, sz * w / 2), V(1.2, 7, 1.2), C.woodRed, M.Wood, NOCOL)
			end
		end
		Kit.block(m, o * CFrame.new(0, y + 3.2, -w / 2 - 0.1), V(w * 0.3, 4.4, 0.3), C.woodDark, M.Wood, SOFT)
		tierRoof(m, o * CFrame.new(0, y + 7, 0), w, w, tileColor or C.tileGrey)
		y = y + 9.6
	end
	Kit.cyl(m, o * CFrame.new(0, y + 4, 0), 0.8, 10, C.gold, M.Metal, NOCOL)
	for i = 0, 4 do
		Kit.cyl(m, o * CFrame.new(0, y + 1.5 + i * 1.4, 0), 2.6 - i * 0.4, 0.4, C.gold, M.Metal, SOFT)
	end
	Kit.ball(m, o * CFrame.new(0, y + 9.6, 0), 1.3, C.goldBright, M.Metal, SOFT)
	return m
end

----------------------------------------------------------------------
-- The temple bell and the prayer wheels
----------------------------------------------------------------------
function B.bellPavilion(parent, o)
	local m = Kit.model(parent, "BellPavilion")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	Kit.block(m, at(0, 0.5, 0), V(16, 1, 16), C.stone, M.Cobblestone)
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			Kit.cyl(m, at(sx * 6, 7, sz * 6), 1.4, 12, C.woodRed, M.Wood)
		end
	end
	Kit.block(m, at(0, 12.6, 0), V(14, 1, 1.2), C.woodDark, M.Wood, NOCOL)
	tierRoof(m, at(0, 13, 0), 13, 13, C.tileTeal)
	Kit.cyl(m, at(0, 11.4, 0), 0.4, 1.6, C.black, M.Metal, SOFT)
	Kit.blob(m, at(0, 9.6, 0), V(5.2, 3.2, 5.2), C.bronze, M.Metal, NOCOL)
	local bell = Kit.cyl(m, at(0, 6.8, 0), 5.2, 5.4, C.bronze, M.Metal)
	bell.Name = "Bell"
	Kit.cyl(m, at(0, 4.3, 0), 5.6, 0.5, C.gold, M.Metal, NOCOL)
	Kit.cyl(m, at(0, 8.2, 0), 5.3, 0.3, C.gold, M.Metal, SOFT)
	local striker = Kit.block(m, at(5.6, 6.4, 0), V(5, 0.9, 0.9), C.wood, M.Wood, NOCOL)
	striker.Name = "Striker"
	Kit.cyl(m, at(5.6, 9.4, 0), 0.12, 5.2, C.ivory, M.Fabric, SOFT)
	return m, bell, striker
end

-- A row of prayer wheels. Returns the list of wheel cores (each can be spun).
function B.prayerWheels(parent, o, n)
	n = n or 8
	local m = Kit.model(parent, "PrayerWheels")
	local spacing = 4.2
	local half = (n - 1) * spacing / 2
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	Kit.block(m, at(0, 0.3, 0), V(half * 2 + 7, 0.6, 5), C.stone, M.Cobblestone)
	Kit.block(m, at(0, 1.7, 0), V(half * 2 + 5, 0.6, 1.2), C.woodRed, M.Wood, NOCOL)
	Kit.block(m, at(0, 7.9, 0), V(half * 2 + 5, 0.6, 1.2), C.woodRed, M.Wood, NOCOL)
	Kit.block(m, at(-half - 2.4, 4.4, 0), V(0.9, 8.2, 1.4), C.woodRed, M.Wood)
	Kit.block(m, at(half + 2.4, 4.4, 0), V(0.9, 8.2, 1.4), C.woodRed, M.Wood)
	Kit.block(m, at(0, 8.9, 0) * CFrame.Angles(rad(8), 0, 0), V(half * 2 + 8, 0.5, 5.4), C.tileTeal, M.Slate, NOCOL)
	local wheels = {}
	for i = 0, n - 1 do
		local x = -half + i * spacing
		Kit.cyl(m, at(x, 4.8, 0), 0.3, 6, C.black, M.Metal, SOFT)
		local core = Kit.cyl(m, at(x, 4.8, 0), 2.6, 3.8, C.bronze, M.Metal)
		core.Name = "Wheel"
		local function welded(p)
			p.Anchored = false
			p.Massless = true
			Kit.weld(p, core)
		end
		welded(Kit.cyl(m, at(x, 6.5, 0), 2.8, 0.3, C.gold, M.Metal, SOFT))
		welded(Kit.cyl(m, at(x, 3.1, 0), 2.8, 0.3, C.gold, M.Metal, SOFT))
		for k = 0, 2 do
			welded(Kit.block(m, at(x, 4.8, 0) * CFrame.Angles(0, rad(k * 120), 0) * CFrame.new(0, 0, -1.34), V(1.2, 1.8, 0.14), (k == 0) and C.goldBright or C.gold, M.Metal, SOFT))
		end
		table.insert(wheels, core)
	end
	return m, wheels
end

----------------------------------------------------------------------
-- Crossings
----------------------------------------------------------------------

-- A gently arched bridge. The deck runs along local Z.
function B.bridge(parent, o, len, w, color)
	len = len or 24
	w = w or 10
	local col = color or C.wood
	local m = Kit.model(parent, "Bridge")
	local n = 9
	local rise = len * 0.09
	local segLen = len / n
	for i = 1, n do
		local t = ((i - 0.5) / n) * 2 - 1
		local z = t * len / 2
		local y = rise * (1 - t * t) + 0.25
		local slope = -2 * rise * t / (len / 2)
		local ang = math.atan(slope)
		local cf = o * CFrame.new(0, y, z) * CFrame.Angles(-ang, 0, 0)
		Kit.block(m, cf, V(w, 0.6, segLen / math.cos(ang) + 0.3), col, M.WoodPlanks)
		for _, sx in ipairs({ -1, 1 }) do
			Kit.block(m, cf * CFrame.new(sx * (w / 2 - 0.3), 2.6, 0), V(0.4, 0.4, segLen / math.cos(ang) + 0.3), C.woodRed, M.Wood, NOCOL)
			if i % 2 == 1 then
				Kit.block(m, cf * CFrame.new(sx * (w / 2 - 0.3), 1.4, 0), V(0.5, 2.6, 0.5), C.woodRed, M.Wood, NOCOL)
			end
		end
	end
	for _, sz in ipairs({ -1, 1 }) do
		for _, sx in ipairs({ -1, 1 }) do
			Kit.block(m, o * CFrame.new(sx * (w / 2 - 0.3), 2, sz * (len / 2 + 0.6)), V(1, 4, 1), C.woodRed, M.Wood)
			Kit.ball(m, o * CFrame.new(sx * (w / 2 - 0.3), 4.5, sz * (len / 2 + 0.6)), 1.2, C.gold, M.Metal, SOFT)
		end
	end
	return m
end

-- Flat stones across a river, from (x1, z) to (x2, z).
function B.steppingStones(parent, x1, x2, z, rng, topY)
	local count = math.floor(math.abs(x2 - x1) / 7.5)
	for i = 0, count do
		local x = x1 + (x2 - x1) * (i / count)
		local dz = rng:NextNumber(-2, 2)
		Kit.cyl(parent, CFrame.new(x, (topY or 0.3) - 7, z + dz), rng:NextNumber(5.4, 6.6), 14, C.stone, M.Slate)
	end
end

----------------------------------------------------------------------
-- Special places
----------------------------------------------------------------------

-- The cave of austerities. Entrance faces -Z.
function B.cave(parent, o)
	local m = Kit.model(parent, "Cave")
	local rock = Color3.fromRGB(118, 104, 90)
	local dark = Color3.fromRGB(88, 78, 70)
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	Kit.block(m, at(-15, 9, 0) * CFrame.Angles(0, rad(6), rad(5)), V(11, 21, 34), rock, M.Slate)
	Kit.block(m, at(15, 9, 0) * CFrame.Angles(0, rad(-6), rad(-5)), V(11, 21, 34), rock, M.Slate)
	Kit.block(m, at(0, 9, 16) * CFrame.Angles(rad(-5), 0, 0), V(40, 21, 10), dark, M.Slate)
	Kit.block(m, at(0, 21, 0) * CFrame.Angles(rad(3), rad(8), 0), V(44, 8, 40), rock, M.Slate)
	Kit.block(m, at(-9.5, 7, -16) * CFrame.Angles(0, rad(-10), 0), V(8, 15, 6), dark, M.Slate)
	Kit.block(m, at(9.5, 7, -16) * CFrame.Angles(0, rad(10), 0), V(8, 15, 6), dark, M.Slate)
	Kit.block(m, at(0, 16, -17) * CFrame.Angles(rad(8), 0, 0), V(16, 5, 6), rock, M.Slate)
	Kit.blob(m, at(-5, 27, 3), V(34, 12, 30), rock, M.Slate, NOCOL)
	Kit.blob(m, at(11, 26, -7), V(20, 9, 20), dark, M.Slate, NOCOL)
	Kit.block(m, at(0, 0.5, 4), V(7, 1, 7), dark, M.Slate)
	Props.butterLamp(m, at(-5, 0, 8))
	Props.butterLamp(m, at(5, 0, 8))
	Props.butterLamp(m, at(0, 0, 10.5))
	local glow = Kit.block(m, at(0, 8, 2), V(1, 1, 1), C.goldBright, M.Neon, { collide = false, shadow = false, transparency = 1 })
	Kit.light(glow, Color3.fromRGB(255, 190, 120), 30, 0.8)
	return m
end

-- A pavilion of illusions for one of Mara's daughters.
function B.pavilion(parent, o, color)
	local m = Kit.model(parent, "Pavilion")
	Kit.cyl(m, o * CFrame.new(0, 0.6, 0), 28, 1.2, C.ivory, M.Marble)
	Kit.cyl(m, o * CFrame.new(0, 0.3, 0), 31, 0.6, C.gold, M.Metal)
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2 + math.pi / 8
		local p = o * CFrame.new(math.cos(a) * 11, 0, math.sin(a) * 11)
		Kit.cyl(m, p * CFrame.new(0, 7.2, 0), 1.1, 12, C.ivory, M.Marble)
		Kit.ball(m, p * CFrame.new(0, 13.6, 0), 1.6, C.gold, M.Metal, SOFT)
		if i % 2 == 0 then
			local a2 = (i + 1) / 8 * math.pi * 2 + math.pi / 8
			local q = o * CFrame.new(math.cos(a2) * 11, 0, math.sin(a2) * 11)
			local mid = (p.Position + q.Position) / 2 + Vector3.new(0, 8, 0)
			Kit.block(m, CFrame.new(mid, mid + (q.Position - p.Position)), V(0.15, 9, (q.Position - p.Position).Magnitude), color, M.Fabric, { collide = false, shadow = false, transparency = 0.35 })
		end
	end
	Kit.blob(m, o * CFrame.new(0, 17, 0), V(28, 10, 28), color, M.SmoothPlastic, NOCOL)
	Kit.cyl(m, o * CFrame.new(0, 13.4, 0), 26, 0.8, C.gold, M.Metal, NOCOL)
	Kit.ball(m, o * CFrame.new(0, 23, 0), 2.2, C.goldBright, M.Metal, SOFT)
	for i = 0, 3 do
		local a = i / 4 * math.pi * 2
		Kit.cyl(m, o * CFrame.new(math.cos(a) * 6, 1.5, math.sin(a) * 6), 3, 0.6, color, M.Fabric, SOFT)
	end
	local glow = Kit.ball(m, o * CFrame.new(0, 10.5, 0), 1.4, color, M.Neon, SOFT)
	Kit.light(glow, color, 40, 1.8)
	Kit.sparkle(glow, color, 10)
	return m
end

-- The Bodhi tree (Ficus religiosa) on its terrace, with the stone seat on the eastern (+X) side.
-- Returns the model and the seat part.
function B.bodhiTree(parent, o)
	local m = Kit.model(parent, "BodhiTree")
	local function at(x, y, z)
		return o * CFrame.new(x, y, z)
	end
	-- terrace in two low steps
	Kit.cyl(m, at(0, 0.5, 0), 100, 1, C.sandstoneDark, M.Sandstone)
	Kit.cyl(m, at(0, 1.5, 0), 92, 1, C.sandstone, M.Sandstone)
	local top = 2
	-- trunk: a fused bundle, as old fig trees grow
	Kit.cyl(m, at(0, top + 16, 0), 13, 32, C.trunk, M.Wood)
	for i = 0, 6 do
		local a = i / 7 * math.pi * 2
		Kit.cyl(m, at(math.cos(a) * 6, top + 13, math.sin(a) * 6), 5.2, 26 + (i % 3) * 3, (i % 2 == 0) and C.trunkPale or C.trunk, M.Wood)
		Kit.blob(m, at(math.cos(a + 0.4) * 9.5, top + 3, math.sin(a + 0.4) * 9.5) * CFrame.Angles(0, -a, 0), V(6, 9, 9), C.trunk, M.Wood)
	end
	-- great limbs
	for i = 0, 6 do
		local limb = at(0, top + 26, 0) * CFrame.Angles(0, rad(i * 51.4 + 12), 0) * CFrame.Angles(rad(52 + (i % 2) * 10), 0, 0)
		Kit.cyl(m, limb * CFrame.new(0, 16, 0), 4.2 - (i % 2), 32, C.trunk, M.Wood, NOCOL)
	end
	-- canopy
	local leafColors = { C.leaf, C.leafDark, C.leafLight }
	for i = 0, 9 do
		local a = i / 10 * math.pi * 2
		Kit.blob(m, at(math.cos(a) * 36, top + 50 + (i % 2) * 4, math.sin(a) * 36), V(42, 20, 42), leafColors[i % 3 + 1], M.Grass, NOCOL)
	end
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2 + 0.5
		Kit.blob(m, at(math.cos(a) * 17, top + 62, math.sin(a) * 17), V(44, 22, 44), leafColors[(i + 1) % 3 + 1], M.Grass, NOCOL)
	end
	Kit.blob(m, at(0, top + 73, 0), V(52, 24, 52), C.leaf, M.Grass, NOCOL)
	-- drifting leaves
	local drift = Kit.block(m, at(0, top + 46, 0), V(70, 1, 70), C.leaf, M.SmoothPlastic, { collide = false, shadow = false, transparency = 1 })
	local e = Instance.new("ParticleEmitter")
	e.Rate = 5
	e.Lifetime = NumberRange.new(9, 13)
	e.Speed = NumberRange.new(2.5, 4)
	e.EmissionDirection = Enum.NormalId.Bottom
	e.SpreadAngle = Vector2.new(20, 20)
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-60, 60)
	e.Size = NumberSequence.new(0.7)
	e.Color = ColorSequence.new(Color3.fromRGB(150, 190, 80), Color3.fromRGB(230, 200, 90))
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.8, 0.1), NumberSequenceKeypoint.new(1, 1) })
	e.Parent = drift
	-- golden railing, open to the west where the path arrives
	local posts = 28
	for i = 0, posts - 1 do
		local a = i / posts * math.pi * 2
		if math.cos(a) > -0.9 then
			local p = at(math.cos(a) * 44, top, math.sin(a) * 44)
			Kit.block(m, p * CFrame.new(0, 2, 0), V(1, 4, 1), C.sandstoneLight, M.Sandstone, NOCOL)
			Kit.ball(m, p * CFrame.new(0, 4.4, 0), 1.1, C.gold, M.Metal, SOFT)
			local a2 = (i + 1) / posts * math.pi * 2
			if math.cos(a2) > -0.9 then
				local q = at(math.cos(a2) * 44, top, math.sin(a2) * 44)
				local mid = (p.Position + q.Position) / 2
				local seg = CFrame.new(mid, q.Position)
				Kit.block(m, seg * CFrame.new(0, 3.2, 0), V(0.5, 0.5, (q.Position - p.Position).Magnitude), C.gold, M.Metal, NOCOL)
				Kit.block(m, seg * CFrame.new(0, 1.6, 0), V(0.5, 0.5, (q.Position - p.Position).Magnitude), C.gold, M.Metal, NOCOL)
			end
			if i % 2 == 0 then
				Props.butterLamp(m, at(math.cos(a) * 41, top, math.sin(a) * 41))
			end
		end
	end
	-- prayer flags from the trunk out to tall poles
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2 + 0.2
		local outer = (o * CFrame.new(math.cos(a) * 47, 16, math.sin(a) * 47)).Position
		local inner = (o * CFrame.new(math.cos(a) * 7, top + 24, math.sin(a) * 7)).Position
		Props.flags(m, inner, outer, false)
		Kit.cyl(m, CFrame.new(outer.X, outer.Y / 2, outer.Z), 0.6, outer.Y, C.woodDark, M.Wood)
	end
	-- the Vajrasana, the Diamond Seat, on the east side with its back to the trunk
	local seat = Kit.block(m, at(12, top + 0.6, 0), V(9, 1.2, 11), C.redstone, M.Marble)
	seat.Name = "Vajrasana"
	Kit.block(m, at(12, top + 0.6, 0), V(9.3, 0.4, 11.3), C.gold, M.Metal, NOCOL)
	Kit.block(m, at(12, top + 1.26, 0), V(7.6, 0.14, 9.6), Color3.fromRGB(150, 178, 92), M.Grass, SOFT)
	Props.butterLamp(m, at(18, top, 5))
	Props.butterLamp(m, at(18, top, -5))
	Props.incenseBurner(m, at(21, top, 0))
	local glow = Kit.block(m, at(12, top + 10, 0), V(1, 1, 1), C.goldBright, M.Neon, { collide = false, shadow = false, transparency = 1 })
	Kit.light(glow, Color3.fromRGB(255, 220, 160), 50, 1.4)
	return m, seat
end

return B
