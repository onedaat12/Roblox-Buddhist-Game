-- Boss: the meeting with Mara, told in the order the old stories tell it.
--   1. Mara's host attacks.
--   2. Mara sends nine storms. To one who sits unmoved, they fall as flowers.
--   3. Mara himself attacks from the back of the elephant Girimekhala, hurling his discus.
--   4. Mara claims the seat and demands a witness. The seeker touches the earth,
--      the earth answers, and Mara's armies scatter.
-- Any number of players can face him together.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))
local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Quests = require(script.Parent.Quests)
local Combat = require(script.Parent.Combat)
local Enemies = require(script.Parent.Enemies)
local Rig = require(script.Parent.Rig)
local Kit = require(script.Parent.Kit)

local Boss = {}

local ARENA = Config.Places.arena
local CENTER = Vector3.new(ARENA.x, 0, ARENA.z)
local HOST_TYPES = { "desire", "discontent", "hunger", "craving", "sloth", "fear", "doubt", "hypocrisy", "fame", "pride" }

local state = Remotes.BossState
local folder = nil
local maraModel = nil
local maraHome = nil
local target = nil
local running = false
local earthTouchedBy = nil
local lastStart = -1000
local helpCooldown = {}
local rng = Random.new()

local function setPhase(phase, text)
	state:SetAttribute("Phase", phase)
	state:SetAttribute("Text", text or "")
end

local function participants()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local pos = Combat.position(player)
		if pos and PlayerData.get(player) then
			local flat = Vector3.new(pos.X, 0, pos.Z)
			if (flat - CENTER).Magnitude <= ARENA.radius + 34 then
				table.insert(list, { player = player, pos = pos })
			end
		end
	end
	return list
end

local function isMeditating(player)
	local session = PlayerData.session(player)
	return session ~= nil and session.meditating
end

-- Something falling from the sky onto a spot. Calls onImpact() when it lands.
local function hazard(pos, color, radius, delay, onImpact)
	local disc = Kit.cyl(folder, CFrame.new(pos.X, 0.35, pos.Z), radius * 2, 0.25, color, Enum.Material.Neon, { collide = false, shadow = false, transparency = 0.6 })
	local rock = Kit.ball(folder, CFrame.new(pos.X, 80, pos.Z), 4.5, color, Enum.Material.Neon, { collide = false, shadow = false })
	TweenService:Create(rock, TweenInfo.new(delay, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { CFrame = CFrame.new(pos.X, 2, pos.Z) }):Play()
	TweenService:Create(disc, TweenInfo.new(delay), { Transparency = 0.2 }):Play()
	task.delay(delay, function()
		disc:Destroy()
		rock:Destroy()
		onImpact()
	end)
end

local temps = {}
local function clearTemps(withPetals)
	for i = #temps, 1, -1 do
		local enemy = temps[i]
		if enemy.alive then
			if withPetals and enemy.root and enemy.root.Parent then
				Remotes.fx("petals", { pos = enemy.root.Position, color = Color3.fromRGB(255, 190, 210) })
			end
			Enemies.remove(enemy)
		end
		temps[i] = nil
	end
end

local function summon(count, onDefeat)
	for _ = 1, count do
		if Enemies.count() >= 30 then
			break
		end
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(26, ARENA.radius - 12)
		local typeId = HOST_TYPES[rng:NextInteger(1, #HOST_TYPES)]
		local enemy = Enemies.create(typeId, ARENA.x + math.cos(a) * r, ARENA.z + math.sin(a) * r, nil, {
			temporary = true,
			hpScale = 0.7,
			onDefeat = onDefeat,
		})
		enemy.home = CENTER
		table.insert(temps, enemy)
	end
end

local function showMara(visible)
	if not maraModel then
		return
	end
	maraModel.Parent = visible and folder or nil
end

local function reset()
	clearTemps(false)
	if target then
		target.invulnerable = true
		target.hp = target.maxHp
		target.alive = false
		Combat.removeTarget(target)
	end
	showMara(true)
	earthTouchedBy = nil
	running = false
	state:SetAttribute("Hp", 0)
	setPhase("idle", "")
end

----------------------------------------------------------------------
-- The four parts of the encounter. Each returns false if everyone has left.
----------------------------------------------------------------------
local function waitWhile(seconds, step)
	local elapsed = 0
	local empty = 0
	while elapsed < seconds do
		task.wait(0.5)
		elapsed = elapsed + 0.5
		local list = participants()
		if #list == 0 then
			empty = empty + 0.5
			if empty >= 8 then
				return false
			end
		else
			empty = 0
		end
		if step and step(elapsed, list) == true then
			return true
		end
	end
	return true
end

local function phaseHost()
	local count = #participants()
	local need = Config.Boss.hostToDispel + math.max(0, count - 1) * 4
	local dispelled = 0
	state:SetAttribute("Count", 0)
	state:SetAttribute("Need", need)
	setPhase("host", "Mara's host closes in. Dispel them!")
	Remotes.notifyAll("Mara: 'Arise, my armies. Drive this one from the tree!'", "warn")
	local finished = false
	local ok = waitWhile(240, function(elapsed)
		local living = 0
		for _, e in ipairs(temps) do
			if e.alive then
				living = living + 1
			end
		end
		if living < 4 + count and elapsed % 1.5 == 0 then
			summon(2, function()
				dispelled = dispelled + 1
				state:SetAttribute("Count", math.min(dispelled, need))
			end)
		end
		if dispelled >= need then
			finished = true
			return true
		end
		return false
	end)
	return ok and finished
end

local function phaseStorms()
	clearTemps(true)
	for i, storm in ipairs(Config.Storms) do
		local color = Color3.fromRGB(storm.color[1], storm.color[2], storm.color[3])
		setPhase("storms", "Mara sends " .. storm.name .. ". Sit unmoved (Meditate) and it falls as flowers.")
		state:SetAttribute("Count", i)
		state:SetAttribute("Need", #Config.Storms)
		Remotes.fx("storm", { color = color, index = i })
		local ok = waitWhile(Config.Boss.stormSeconds, function(elapsed, list)
			if elapsed % 1 ~= 0 then
				return false
			end
			for _, entry in ipairs(list) do
				local spot = entry.pos + Vector3.new(rng:NextNumber(-5, 5), 0, rng:NextNumber(-5, 5))
				hazard(spot, color, 7, 1.2, function()
					local unmoved = false
					for _, p in ipairs(participants()) do
						if (Vector3.new(p.pos.X, 0, p.pos.Z) - Vector3.new(spot.X, 0, spot.Z)).Magnitude <= 7.5 then
							if isMeditating(p.player) then
								unmoved = true
							else
								Combat.hurt(p.player, 13)
							end
						end
					end
					Remotes.fx("petals", { pos = Vector3.new(spot.X, 2, spot.Z), color = unmoved and Color3.fromRGB(255, 200, 220) or color })
				end)
			end
			return false
		end)
		if not ok then
			return false
		end
	end
	return true
end

local function throwDiscus(victim)
	local from = maraHome.Position + Vector3.new(-6, 4, 0)
	local pos = Combat.position(victim)
	if not pos then
		return
	end
	local to = Vector3.new(pos.X, 3, pos.Z)
	local disc = Kit.cyl(folder, CFrame.new(from), 5, 0.4, Color3.fromRGB(255, 90, 50), Enum.Material.Neon, { collide = false, shadow = false })
	Kit.light(disc, Color3.fromRGB(255, 90, 50), 18, 2)
	local travel = math.clamp((to - from).Magnitude / 75, 0.5, 1.6)
	TweenService:Create(disc, TweenInfo.new(travel, Enum.EasingStyle.Linear), { CFrame = CFrame.new(to) * CFrame.Angles(0, 0, math.rad(90)) }):Play()
	task.delay(travel, function()
		disc:Destroy()
		local now = Combat.position(victim)
		if now and (Vector3.new(now.X, 3, now.Z) - to).Magnitude <= 6.5 then
			if isMeditating(victim) then
				Remotes.fx("petals", { pos = to + Vector3.new(0, 6, 0), color = Color3.fromRGB(255, 200, 220), big = true })
				Remotes.notify(victim, "Mara's discus hangs above you as a canopy of flowers.", "good")
			else
				Combat.hurt(victim, 22)
				Remotes.fx("petals", { pos = to, color = Color3.fromRGB(255, 90, 50) })
			end
		end
	end)
end

local function stomp()
	local spot = Vector3.new(Config.Places.mara.x - 30, 0, Config.Places.mara.z)
	hazard(spot, Color3.fromRGB(200, 60, 255), 30, 1.6, function()
		Remotes.fx("ring", { pos = spot, radius = 32, color = Color3.fromRGB(200, 60, 255), time = 0.6 })
		for _, p in ipairs(participants()) do
			if (Vector3.new(p.pos.X, 0, p.pos.Z) - spot).Magnitude <= 31 then
				Combat.hurt(p.player, 18)
			end
		end
	end)
end

local function phaseMara(startFraction)
	local count = math.max(1, #participants())
	local maxHp = Config.Boss.hp + (count - 1) * Config.Boss.hpPerExtraPlayer
	target.maxHp = maxHp
	target.hp = math.floor(maxHp * (startFraction or 1))
	target.invulnerable = false
	target.tagged = {}
	if not target.alive then
		Combat.addTarget(target)
	end
	state:SetAttribute("MaxHp", maxHp)
	state:SetAttribute("Hp", target.hp)
	setPhase("mara", "Mara attacks! Strike back, and sit unmoved when he hurls his discus.")
	local defeated = false
	target.onDamage = function(self)
		state:SetAttribute("Hp", math.max(0, self.hp))
	end
	target.onDefeat = function()
		defeated = true
	end
	local ok = waitWhile(600, function(elapsed, list)
		if defeated then
			return true
		end
		if #list > 0 then
			if elapsed % 3.5 == 0 then
				throwDiscus(list[rng:NextInteger(1, #list)].player)
			end
			if elapsed % 9 == 0 then
				stomp()
			end
			if elapsed % 15 == 0 then
				summon(2)
			end
		end
		return false
	end)
	target.invulnerable = true
	return ok and defeated
end

local function phaseWitness()
	clearTemps(true)
	earthTouchedBy = nil
	setPhase("witness", "Mara: 'That seat is mine! My army is my witness. Who is yours?'  Touch the earth!")
	local ok = waitWhile(40, function()
		return earthTouchedBy ~= nil
	end)
	return ok and earthTouchedBy ~= nil
end

local function victory()
	local who = earthTouchedBy
	setPhase("won", "The earth roars: 'I am his witness.'")
	Remotes.fx("quake", { pos = CENTER, by = who and who.DisplayName or "" })
	if maraHome then
		Remotes.fx("petals", { pos = maraHome.Position, color = Color3.fromRGB(255, 120, 90), big = true })
	end
	showMara(false)
	Combat.removeTarget(target)
	local now = os.clock()
	for _, entry in ipairs(participants()) do
		local player = entry.player
		local profile = PlayerData.get(player)
		if Quests.active(player, "boss", "mara") then
			Quests.progress(player, "boss", "mara")
		elseif profile and Quests.reached(player, "seat") then
			if now >= (helpCooldown[player] or 0) then
				helpCooldown[player] = now + 600
				profile.bossWins = profile.bossWins + 1
				PlayerData.addMerit(player, 80)
				Remotes.notify(player, "You stood beside another seeker against Mara.", "good")
			end
		end
	end
	Remotes.notifyAll("Mara's armies scatter to the ends of the world.", "good")
	task.wait(Config.Boss.resetAfter)
end

local function fight()
	running = true
	lastStart = os.clock()
	local won = false
	if phaseHost() and phaseStorms() then
		local fraction = 1
		for _ = 1, 4 do
			if not phaseMara(fraction) then
				break
			end
			if phaseWitness() then
				won = true
				break
			end
			-- nobody answered: Mara gathers himself and attacks again
			Remotes.notifyAll("No one answers. Mara laughs and raises his discus again.", "warn")
			fraction = 0.35
			target.alive = false
			Combat.removeTarget(target)
		end
	end
	if won then
		victory()
	end
	reset()
end

----------------------------------------------------------------------
-- Public
----------------------------------------------------------------------
function Boss.touchEarth(player)
	if state:GetAttribute("Phase") ~= "witness" or earthTouchedBy then
		return
	end
	local pos = Combat.position(player)
	if pos and (Vector3.new(pos.X, 0, pos.Z) - CENTER).Magnitude <= ARENA.radius + 34 then
		earthTouchedBy = player
	end
end

function Boss.challenge()
	if running or os.clock() - lastStart < 20 then
		return false
	end
	task.spawn(function()
		local ok, err = pcall(fight)
		if not ok then
			warn("[Bodhi Path] The encounter with Mara failed:", err)
			reset()
		end
	end)
	return true
end

function Boss.start(objects)
	folder = Kit.folder(workspace, "MaraEncounter")
	maraHome = objects.maraSeat

	-- Mara, mounted on Girimekhala
	local model, hum = Rig.make("Mara", "mara")
	local hip = hum.HipHeight
	model:ScaleTo(2.6)
	hum.DisplayName = "Mara"
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.NameDisplayDistance = 200
	local root = model:FindFirstChild("HumanoidRootPart")
	root.Anchored = true
	local lift = hip * 2.6 + root.Size.Y / 2
	model:PivotTo(maraHome * CFrame.new(0, lift, 0))
	model.Parent = folder
	Rig.animate(model, false)
	maraModel = model

	local body = objects.elephant and objects.elephant:FindFirstChildWhichIsA("BasePart")
	target = {
		name = "Mara",
		root = body or root,
		hp = Config.Boss.hp,
		maxHp = Config.Boss.hp,
		hitRadius = 16,
		static = true,
		big = true,
		invulnerable = true,
		tagged = {},
		alive = false,
	}

	-- a gong for those who wish to face him again
	local gong = Kit.cyl(folder, CFrame.new(ARENA.x - ARENA.radius + 6, 5, 20) * CFrame.Angles(0, 0, math.rad(90)), 7, 0.6, Kit.C.bronze, Enum.Material.Metal)
	Kit.block(folder, CFrame.new(ARENA.x - ARENA.radius + 6, 9.4, 20), Vector3.new(1, 0.8, 10), Kit.C.black, Enum.Material.Wood)
	Kit.block(folder, CFrame.new(ARENA.x - ARENA.radius + 6, 4.7, 24.6), Vector3.new(1, 9.4, 0.8), Kit.C.black, Enum.Material.Wood)
	Kit.block(folder, CFrame.new(ARENA.x - ARENA.radius + 6, 4.7, 15.4), Vector3.new(1, 9.4, 0.8), Kit.C.black, Enum.Material.Wood)
	local prompt = Kit.prompt(gong, "Strike the gong", "Challenge Mara", 14, 0.6)
	prompt.Triggered:Connect(function(player)
		if not Quests.reached(player, "mara") then
			Remotes.notify(player, "Break through Mara's host first.", "warn")
		elseif running then
			Remotes.notify(player, "Mara is already here.", "info")
		elseif not Boss.challenge() then
			Remotes.notify(player, "The field is quiet. Wait a moment.", "info")
		end
	end)

	-- Mara appears by himself when a seeker who must face him steps into the ring
	local maraStage = Story.QuestIndex.mara
	task.spawn(function()
		while true do
			task.wait(1)
			if not running then
				for _, entry in ipairs(participants()) do
					local flat = Vector3.new(entry.pos.X, 0, entry.pos.Z)
					if Quests.stage(entry.player) == maraStage and (flat - CENTER).Magnitude <= ARENA.radius - 6 then
						Boss.challenge()
						break
					end
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		helpCooldown[player] = nil
	end)
	setPhase("idle", "")
end

return Boss
