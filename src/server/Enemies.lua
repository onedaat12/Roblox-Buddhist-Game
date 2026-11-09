-- Enemies: Mara's ten armies and his three daughters.
-- Soldiers appear only where players are nearby, chase them, and wear down their Calm.
-- Each army has its own character: Hunger drains you from a distance, Sloth slows you,
-- Doubt never stays where you look for it, and so on (see Config.Enemies).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Quests = require(script.Parent.Quests)
local Combat = require(script.Parent.Combat)
local Rig = require(script.Parent.Rig)
local Kit = require(script.Parent.Kit)

local Enemies = {}

local MAX_ALIVE = 36
local WAKE_DISTANCE = 230
local SLEEP_DISTANCE = 330
local AGGRO = 70
local LEASH = 120

local folder = nil
local spawns = {}
local alive = {}
local rng = Random.new()

local function playerPositions()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local pos = Combat.position(player)
		if pos then
			table.insert(list, { player = player, pos = pos })
		end
	end
	return list
end

local function glowColor(cfg)
	return Color3.fromRGB(cfg.glow[1], cfg.glow[2], cfg.glow[3])
end

-- Reward everyone who helped, and count it toward their journey.
local function reward(enemy)
	local cfg = enemy.cfg
	for player in pairs(enemy.tagged) do
		if player.Parent and PlayerData.get(player) then
			local pos = Combat.position(player)
			if pos and (pos - enemy.lastPos).Magnitude < 160 then
				PlayerData.addMerit(player, cfg.merit or 5)
				local profile = PlayerData.get(player)
				profile.dispelled = profile.dispelled + 1
				Quests.progress(player, "dispel", enemy.typeId)
				if enemy.group then
					Quests.progress(player, "dispel", enemy.group)
				end
			end
		end
	end
end

local function remove(enemy)
	Combat.removeTarget(enemy)
	for i, other in ipairs(alive) do
		if other == enemy then
			table.remove(alive, i)
			break
		end
	end
	if enemy.spawn then
		for i, other in ipairs(enemy.spawn.alive) do
			if other == enemy then
				table.remove(enemy.spawn.alive, i)
				break
			end
		end
	end
	if enemy.model then
		enemy.model:Destroy()
	end
end

-- Create one soldier. Returns the enemy record (which is also a Combat target).
function Enemies.create(typeId, x, z, spawn, options)
	local cfg = Config.Enemies[typeId]
	options = options or {}
	local model, hum = Rig.make(cfg.name, "enemy", cfg)
	local hp = math.floor(cfg.hp * (options.hpScale or 1))
	hum.MaxHealth = hp
	hum.Health = hp
	hum.WalkSpeed = cfg.speed
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	hum.NameDisplayDistance = 60
	hum.HealthDisplayDistance = 60
	Rig.place(model, Kit.at(x, z, rng:NextNumber(0, 360)), folder)
	Rig.animate(model, true)
	local root = model:FindFirstChild("HumanoidRootPart")
	local enemy = {
		typeId = typeId,
		cfg = cfg,
		model = model,
		hum = hum,
		root = root,
		hp = hp,
		maxHp = hp,
		home = Vector3.new(x, 0, z),
		spawn = spawn,
		group = options.group or (spawn and spawn.def.group) or nil,
		hitRadius = 1.5 * (cfg.scale or 1),
		big = cfg.daughter or false,
		stunUntil = 0,
		nextAttack = 0,
		nextSpecial = 0,
		nextWander = 0,
		lastPos = root.Position,
		temporary = options.temporary or false,
	}
	enemy.onDefeat = function(self)
		self.lastPos = self.root.Position
		Remotes.fx("petals", { pos = self.root.Position, color = glowColor(cfg), big = self.big })
		reward(self)
		if self.spawn then
			self.spawn.nextRespawn = os.clock() + (self.spawn.def.respawn or 22)
		end
		if options.onDefeat then
			options.onDefeat(self)
		end
		remove(self)
	end
	Combat.addTarget(enemy)
	table.insert(alive, enemy)
	if spawn then
		table.insert(spawn.alive, enemy)
	end
	return enemy
end

function Enemies.remove(enemy)
	remove(enemy)
end

function Enemies.count()
	return #alive
end

----------------------------------------------------------------------
-- Behaviour
----------------------------------------------------------------------
local function think(enemy, now, players)
	local root, hum, cfg = enemy.root, enemy.hum, enemy.cfg
	if not root.Parent or root.Position.Y < -60 then
		remove(enemy)
		return
	end
	local pos = root.Position
	enemy.lastPos = pos
	if now < enemy.stunUntil then
		hum.WalkSpeed = 0
		return
	end

	-- choose the nearest player who can be reached
	local target, targetPos, best = nil, nil, AGGRO
	for _, entry in ipairs(players) do
		local d = (entry.pos - pos).Magnitude
		if d < best and (entry.pos - enemy.home).Magnitude < LEASH and Combat.canBeTargeted(entry.player) then
			target, targetPos, best = entry.player, entry.pos, d
		end
	end

	if not target then
		hum.WalkSpeed = cfg.speed * 0.5
		if now >= enemy.nextWander then
			enemy.nextWander = now + rng:NextNumber(3, 7)
			local a = rng:NextNumber(0, math.pi * 2)
			local r = rng:NextNumber(2, (enemy.spawn and enemy.spawn.def.radius) or 12)
			hum:MoveTo(enemy.home + Vector3.new(math.cos(a) * r, pos.Y, math.sin(a) * r))
		end
		return
	end

	hum.WalkSpeed = cfg.speed
	local reach = cfg.range * (cfg.scale or 1) * 0.8 + 2
	if best > reach then
		hum:MoveTo(targetPos)
	else
		hum:MoveTo(pos)
		if now >= enemy.nextAttack then
			enemy.nextAttack = now + 1.5
			if Combat.hurt(target, cfg.dmg) then
				if cfg.special == "slow" then
					Combat.slow(target, 3.5)
				elseif cfg.special == "steal" then
					local profile = PlayerData.get(target)
					if profile and profile.merit > 0 then
						PlayerData.addMerit(target, -math.min(4, profile.merit), true)
						Remotes.notify(target, "Gain and Fame took a little of your merit.", "warn")
					end
				end
			end
		end
	end

	-- special behaviours
	if cfg.special == "drain" and best < 22 and now >= enemy.nextSpecial then
		enemy.nextSpecial = now + 1
		Combat.hurt(target, enemy.big and 4 or 2)
	elseif cfg.special == "pull" and best < 26 then
		Combat.slow(target, 0.8)
	elseif cfg.special == "blink" and best > 12 and now >= enemy.nextSpecial then
		enemy.nextSpecial = now + (enemy.big and 4 or 5.5)
		local a = rng:NextNumber(0, math.pi * 2)
		local dest = targetPos + Vector3.new(math.cos(a) * 7, 0, math.sin(a) * 7)
		Remotes.fx("ring", { pos = pos, radius = 5, color = glowColor(cfg), time = 0.4 })
		enemy.model:PivotTo(CFrame.new(dest.X, pos.Y + 0.5, dest.Z))
		Remotes.fx("ring", { pos = dest, radius = 5, color = glowColor(cfg), time = 0.4 })
	end
end

local function manage(now, players)
	for _, spawn in ipairs(spawns) do
		local def = spawn.def
		local nearest = math.huge
		for _, entry in ipairs(players) do
			local dx, dz = entry.pos.X - def.x, entry.pos.Z - def.z
			local d = math.sqrt(dx * dx + dz * dz)
			if d < nearest then
				nearest = d
			end
		end
		if nearest < WAKE_DISTANCE then
			if #spawn.alive < def.count and now >= spawn.nextRespawn and #alive < MAX_ALIVE then
				local a = rng:NextNumber(0, math.pi * 2)
				local r = rng:NextNumber(0, def.radius)
				Enemies.create(def.type, def.x + math.cos(a) * r, def.z + math.sin(a) * r, spawn)
				spawn.nextRespawn = now + 0.6
			end
		elseif nearest > SLEEP_DISTANCE and #spawn.alive > 0 then
			for i = #spawn.alive, 1, -1 do
				remove(spawn.alive[i])
			end
		end
	end
end

function Enemies.start()
	folder = Kit.folder(workspace, "Shadows")
	for _, def in ipairs(Config.Spawns) do
		table.insert(spawns, { def = def, alive = {}, nextRespawn = 0 })
	end
	task.spawn(function()
		while true do
			task.wait(0.3)
			local now = os.clock()
			local players = playerPositions()
			local ok, err = pcall(manage, now, players)
			if not ok then
				warn("[Bodhi Path] spawn manager failed:", err)
			end
			for i = #alive, 1, -1 do
				local enemy = alive[i]
				if enemy and enemy.alive then
					local ok2, err2 = pcall(think, enemy, now, players)
					if not ok2 then
						warn("[Bodhi Path] enemy failed:", err2)
						remove(enemy)
					end
				end
			end
		end
	end)
end

return Enemies
