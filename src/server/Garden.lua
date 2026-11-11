-- Garden: the Pilgrims' Garden, a quiet corner of the temple compound where players
-- can meet. Nothing here is part of the story and no shadow comes near it.
--   * a tea pavilion with cushions to sit on, and a pot of tea to pour for friends
--   * five song bells and a drum that anyone can play
--   * sky lanterns to release
--   * a meditation circle that gives merit only when people sit there together

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Kit = require(script.Parent.Kit)
local Props = require(script.Parent.Props)

local C = Kit.C
local M = Enum.Material

local Garden = {}

local CENTRE = { x = -28, z = -94 }
local TEA = { x = -46, z = -94 }
local CIRCLE = { x = -10, z = -96 }
local CIRCLE_RADIUS = 13

local SOFT = { collide = false, shadow = false }

local function V(x, y, z)
	return Vector3.new(x, y, z)
end

-- A cushion or bench that a player can really sit on.
local function seat(parent, cf, size, color)
	local s = Instance.new("Seat")
	s.Name = "Cushion"
	s.Anchored = true
	s.Size = size
	s.Color = color
	s.Material = M.Fabric
	s.CFrame = cf
	s.Parent = parent
	return s
end

----------------------------------------------------------------------
-- Building the garden (called while the world is being made)
----------------------------------------------------------------------
function Garden.build(ctx, parent)
	local root = Kit.folder(parent, "PilgrimsGarden")
	local things = { bells = {} }

	-- keep trees and flowers out of the garden and off its path
	ctx.reserve(CENTRE.x, CENTRE.z, 31)
	for _, z in ipairs({ -42, -50, -58, -66 }) do
		ctx.reserve(CENTRE.x, z, 6)
	end

	-- the path from the courtyard, and a small paved square in the middle
	ctx.pave(CENTRE.x - 4, CENTRE.x + 4, -70, -36, M.Limestone)
	ctx.pave(CENTRE.x - 9, CENTRE.x + 9, CENTRE.z - 9, CENTRE.z + 9, M.Limestone)
	Props.signpost(root, Kit.at(CENTRE.x + 7, -39, 0), "Pilgrims' Garden")
	Props.flags(root, V(CENTRE.x - 22, 13, -70), V(CENTRE.x + 22, 13, -70), true)
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			Props.lantern(root, Kit.at(CENTRE.x + sx * 11, CENTRE.z + sz * 11, 0))
		end
	end

	-- two benches beside the way in
	for _, sx in ipairs({ -1, 1 }) do
		local x = CENTRE.x + sx * 10
		seat(root, CFrame.new(x, 1.7, -76) * CFrame.Angles(0, math.rad(180), 0), V(7, 0.5, 2.2), C.wood).Material = M.WoodPlanks
		Kit.block(root, CFrame.new(x - 3, 0.75, -76), V(0.5, 1.5, 2), C.woodDark, M.Wood)
		Kit.block(root, CFrame.new(x + 3, 0.75, -76), V(0.5, 1.5, 2), C.woodDark, M.Wood)
	end

	-- the tea pavilion
	do
		local o = Kit.at(TEA.x, TEA.z, 0)
		Kit.cyl(root, o * CFrame.new(0, 0.4, 0), 19, 0.8, C.wood, M.WoodPlanks)
		for i = 0, 5 do
			local a = i / 6 * math.pi * 2 + math.pi / 6
			Kit.cyl(root, o * CFrame.new(math.cos(a) * 8.4, 5.6, math.sin(a) * 8.4), 0.8, 9.6, C.woodRed, M.Wood)
		end
		Kit.cyl(root, o * CFrame.new(0, 10.6, 0), 21, 0.6, C.woodDark, M.Wood, { collide = false })
		Kit.blob(root, o * CFrame.new(0, 12.6, 0), V(23, 5, 23), C.tileTeal, M.Slate, { collide = false })
		Kit.ball(root, o * CFrame.new(0, 15.6, 0), 1.6, C.goldBright, M.Metal, SOFT)
		-- the low table and the teapot
		Kit.cyl(root, o * CFrame.new(0, 1.4, 0), 5.4, 1.2, C.woodDark, M.Wood)
		local pot = Kit.ball(root, o * CFrame.new(0, 2.7, 0), 1.5, C.bronze, M.Metal, SOFT)
		Kit.block(root, o * CFrame.new(0.95, 2.8, 0) * CFrame.Angles(0, 0, math.rad(-35)), V(0.9, 0.22, 0.22), C.bronze, M.Metal, SOFT)
		Kit.ball(root, o * CFrame.new(0, 3.55, 0), 0.4, C.gold, M.Metal, SOFT)
		Kit.smoke(pot, Color3.fromRGB(240, 240, 240))
		for i = 0, 5 do
			local a = i / 6 * math.pi * 2
			Kit.cyl(root, o * CFrame.new(math.cos(a) * 1.9, 2.15, math.sin(a) * 1.9), 0.5, 0.3, C.ivory, M.SmoothPlastic, SOFT)
			local at = (o * CFrame.new(math.cos(a) * 5.4, 1.1, math.sin(a) * 5.4)).Position
			seat(root, CFrame.new(at, V(o.Position.X, at.Y, o.Position.Z)), V(2.6, 0.6, 2.6), (i % 2 == 0) and C.maroon or C.saffron)
		end
		local lamp = Kit.ball(root, o * CFrame.new(0, 9.4, 0), 1, Color3.fromRGB(255, 214, 150), M.Neon, SOFT)
		Kit.light(lamp, Color3.fromRGB(255, 205, 140), 30, 1.2)
		things.teapot = pot
	end

	-- the meditation circle: eight cushions around a stone lantern
	do
		Kit.cyl(root, CFrame.new(CIRCLE.x, 0.15, CIRCLE.z), 22, 0.3, C.sandstoneLight, M.Sandstone)
		Props.lantern(root, Kit.at(CIRCLE.x, CIRCLE.z, 0))
		for i = 0, 7 do
			local a = i / 8 * math.pi * 2
			Kit.cyl(root, CFrame.new(CIRCLE.x + math.cos(a) * 8, 0.5, CIRCLE.z + math.sin(a) * 8), 3, 0.5, (i % 2 == 0) and C.saffron or C.maroon, M.Fabric)
		end
		things.circle = V(CIRCLE.x, 0, CIRCLE.z)
	end

	-- the song bells: five bells on a frame, low note to high note
	do
		local z = CENTRE.z - 21
		Kit.cyl(root, CFrame.new(CENTRE.x - 9, 3.5, z), 0.7, 7, C.woodRed, M.Wood)
		Kit.cyl(root, CFrame.new(CENTRE.x + 9, 3.5, z), 0.7, 7, C.woodRed, M.Wood)
		Kit.block(root, CFrame.new(CENTRE.x, 7.2, z), V(19.4, 0.6, 0.8), C.woodRed, M.Wood)
		for i = 1, 5 do
			local x = CENTRE.x - 9 + i * 3
			local size = 2.3 - i * 0.22
			Kit.block(root, CFrame.new(x, 6.5, z), V(0.12, 1, 0.12), C.woodDark, M.Wood, SOFT)
			local bell = Kit.cyl(root, CFrame.new(x, 6 - size / 2, z), size, size, C.gold, M.Metal, { collide = false })
			Kit.ball(root, CFrame.new(x, 6 - size - 0.15, z), 0.45, C.bronze, M.Metal, SOFT)
			table.insert(things.bells, bell)
		end
		-- the drum
		local dx = CENTRE.x + 15
		Kit.cyl(root, CFrame.new(dx, 0.6, z + 2), 3.2, 1.2, C.woodDark, M.Wood)
		local drum = Kit.cyl(root, CFrame.new(dx, 2.6, z + 2), 4.4, 2.8, C.woodRed, M.Wood)
		Kit.cyl(root, CFrame.new(dx, 4.05, z + 2), 4.2, 0.1, C.ivory, M.Fabric, SOFT)
		things.drum = drum
	end

	-- the lantern table in the middle of the square
	do
		local table_ = Kit.cyl(root, CFrame.new(CENTRE.x, 1.2, CENTRE.z), 4.6, 2.4, C.woodDark, M.Wood)
		for i = 0, 2 do
			local a = i / 3 * math.pi * 2
			local paper = Kit.block(root, CFrame.new(CENTRE.x + math.cos(a) * 1.1, 3.3, CENTRE.z + math.sin(a) * 1.1), V(1.1, 1.6, 1.1), Color3.fromRGB(255, 214, 150), M.Neon, SOFT)
			if i == 0 then
				Kit.light(paper, Color3.fromRGB(255, 200, 120), 20, 1.2)
			end
		end
		things.lanternTable = table_
	end

	-- the garland-maker's stall
	Props.stall(root, Kit.at(4, -116, Kit.FACE_POS_Z), C.lotusPink, { C.lotusPink, C.lotusWhite, C.saffron, C.flagYellow })
	ctx.reserve(4, -113, 9)

	ctx.objects.garden = things
	return root
end

----------------------------------------------------------------------
-- Using the garden (called once the game is running)
----------------------------------------------------------------------
local NOTES = { 1, 1.122, 1.26, 1.498, 1.682 } -- a five-note scale, so anything played sounds pleasant
local LANTERN_COLORS = {
	Color3.fromRGB(255, 206, 130), Color3.fromRGB(255, 170, 110), Color3.fromRGB(255, 226, 170),
	Color3.fromRGB(255, 150, 140), Color3.fromRGB(250, 190, 90),
}

function Garden.start(objects)
	local things = objects.garden
	if not things then
		return
	end
	local Remotes = require(script.Parent.Remotes)
	local PlayerData = require(script.Parent.PlayerData)
	local Combat = require(script.Parent.Combat)
	local Cosmetics = require(script.Parent.Cosmetics)
	local rng = Random.new()

	-- song bells
	for i, bell in ipairs(things.bells) do
		local prompt = Kit.prompt(bell, "Ring", "Song Bell", 8)
		prompt.Triggered:Connect(function()
			Remotes.fx("note", { pos = bell.Position, pitch = NOTES[i] or 1 })
			Remotes.fx("ring", { pos = bell.Position, radius = 4, color = Color3.fromRGB(255, 226, 150), time = 0.5 })
		end)
	end

	-- the drum
	if things.drum then
		local prompt = Kit.prompt(things.drum, "Beat", "Garden Drum", 9)
		prompt.Triggered:Connect(function()
			Remotes.fx("drum", { pos = things.drum.Position })
			Remotes.fx("ring", { pos = things.drum.Position + Vector3.new(0, 2, 0), radius = 6, color = Color3.fromRGB(255, 150, 110), time = 0.35 })
		end)
	end

	-- tea, poured for everyone sitting near
	if things.teapot then
		local prompt = Kit.prompt(things.teapot, "Pour tea", "Teapot", 10)
		prompt.Triggered:Connect(function(player)
			local session = PlayerData.session(player)
			if not session then
				return
			end
			local now = os.clock()
			if now < (session.teaAt or 0) then
				local left = math.ceil(session.teaAt - now)
				Remotes.notify(player, "The pot is still steeping. Ready in " .. left .. (left == 1 and " second." or " seconds."), "info")
				return
			end
			session.teaAt = now + 20
			Combat.heal(player, 30)
			local friends = 0
			for _, other in ipairs(Players:GetPlayers()) do
				if other ~= player then
					local pos = Combat.position(other)
					if pos and (pos - things.teapot.Position).Magnitude <= 18 then
						friends = friends + 1
						Combat.heal(other, 30)
						Remotes.notify(other, player.DisplayName .. " pours you a cup of tea.", "good")
					end
				end
			end
			if friends > 0 then
				PlayerData.addMerit(player, math.min(6, friends * 2))
				Remotes.notify(player, "You pour tea for " .. friends .. (friends == 1 and " friend." or " friends."), "good")
			else
				Remotes.notify(player, "You pour yourself a cup of tea. It is better shared.", "info")
			end
		end)
	end

	-- sky lanterns
	if things.lanternTable then
		local flying = 0
		local prompt = Kit.prompt(things.lanternTable, "Release a sky lantern", "Lantern Table", 10)
		prompt.Triggered:Connect(function(player)
			local session = PlayerData.session(player)
			if not session then
				return
			end
			local now = os.clock()
			if now < (session.lanternAt or 0) or flying >= 24 then
				return
			end
			session.lanternAt = now + 4
			flying = flying + 1
			local start = things.lanternTable.Position + Vector3.new(rng:NextNumber(-3, 3), 4, rng:NextNumber(-3, 3))
			local lantern = Instance.new("Part")
			lantern.Name = "SkyLantern"
			lantern.Size = Vector3.new(1.6, 2.2, 1.6)
			lantern.Material = Enum.Material.Neon
			lantern.Color = Cosmetics.lanternColor(player, rng) or LANTERN_COLORS[rng:NextInteger(1, #LANTERN_COLORS)]
			lantern.Anchored = true
			lantern.CanCollide = false
			lantern.CanTouch = false
			lantern.CanQuery = false
			lantern.CastShadow = false
			lantern.CFrame = CFrame.new(start)
			Kit.light(lantern, lantern.Color, 18, 1.4)
			lantern.Parent = workspace
			local drift = Vector3.new(rng:NextNumber(-45, 45), rng:NextNumber(130, 170), rng:NextNumber(-45, 45))
			TweenService:Create(lantern, TweenInfo.new(32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(start + drift) }):Play()
			task.delay(28, function()
				if lantern.Parent then
					TweenService:Create(lantern, TweenInfo.new(4), { Transparency = 1 }):Play()
				end
			end)
			task.delay(32.5, function()
				lantern:Destroy()
				flying = flying - 1
			end)
		end)
	end

	-- the meditation circle: merit comes only from sitting with others
	if things.circle then
		Combat.onMeditateTick(function(player, pos, dt)
			local flat = Vector3.new(pos.X - things.circle.X, 0, pos.Z - things.circle.Z)
			if flat.Magnitude > CIRCLE_RADIUS then
				return
			end
			local session = PlayerData.session(player)
			if not session then
				return
			end
			session.circleTime = (session.circleTime or 0) + dt
			if session.circleTime < 15 then
				return
			end
			session.circleTime = 0
			local companions = 0
			for _, other in ipairs(Players:GetPlayers()) do
				local theirs = other ~= player and PlayerData.session(other)
				local at = theirs and theirs.meditating and Combat.position(other)
				if at and Vector3.new(at.X - things.circle.X, 0, at.Z - things.circle.Z).Magnitude <= CIRCLE_RADIUS then
					companions = companions + 1
				end
			end
			if companions > 0 then
				PlayerData.addMerit(player, math.min(4, companions))
				if not session.circleTold then
					session.circleTold = true
					Remotes.notify(player, "You are sitting together. Each companion in the circle adds merit.", "good")
				end
			elseif not session.circleTold then
				session.circleTold = true
				Remotes.notify(player, "The circle is for sitting together. When others meditate here with you, everyone earns merit.", "info")
			end
		end)
	end
end

return Garden
