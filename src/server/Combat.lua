-- Combat: Calm (the player's "health"), the monk's abilities, and meditation.
--
-- Nothing is killed in this game. Mara's soldiers are troubles of the mind; when they are
-- met steadily they are "dispelled" and fall apart into petals, as Mara's weapons turned
-- to flowers. When a player's Calm runs out they are "overwhelmed" and return to the last
-- shrine they prayed at.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))
local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Quests = require(script.Parent.Quests)

local Combat = {}

-- Everything that can be struck: Mara's soldiers, his daughters, and Mara himself.
Combat.targets = {}
local projectiles = {}
local meditateHooks = {}

function Combat.addTarget(t)
	t.tagged = t.tagged or {}
	t.alive = true
	table.insert(Combat.targets, t)
end

function Combat.removeTarget(t)
	t.alive = false
	for i, other in ipairs(Combat.targets) do
		if other == t then
			table.remove(Combat.targets, i)
			break
		end
	end
end

function Combat.onMeditateTick(fn)
	table.insert(meditateHooks, fn)
end

----------------------------------------------------------------------
-- Where players are
----------------------------------------------------------------------
function Combat.root(player)
	local character = player.Character
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local hum = character:FindFirstChildOfClass("Humanoid")
	if root and hum and hum.Health > 0 then
		return root, hum
	end
	return nil
end

function Combat.position(player)
	local root = Combat.root(player)
	return root and root.Position or nil
end

function Combat.shrineCFrame(shrineId)
	for _, s in ipairs(Config.Shrines) do
		if s.id == shrineId then
			return CFrame.new(s.x - 9, 4.5, s.z) * CFrame.Angles(0, math.rad(-90), 0)
		end
	end
	return CFrame.new(Config.Places.spawn.x, 4.5, Config.Places.spawn.z)
end

function Combat.toShrine(player, shrineId)
	local character = player.Character
	if character and character.PrimaryPart then
		character:PivotTo(Combat.shrineCFrame(shrineId))
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end
	end
end

----------------------------------------------------------------------
-- Speed, healing and harm
----------------------------------------------------------------------
function Combat.refreshSpeed(player)
	local root, hum = Combat.root(player)
	local session = PlayerData.session(player)
	if not root or not session then
		return
	end
	local now = os.clock()
	local speed = Config.Player.BaseSpeed
	if PlayerData.hasPath(player, "effort") then
		speed = speed + 3
	end
	if now < session.speedUntil then
		speed = speed + Config.Items.tea.amount
	end
	if now < session.slowUntil then
		speed = speed * 0.6
	end
	if math.abs(hum.WalkSpeed - speed) > 0.05 then
		hum.WalkSpeed = speed
	end
end

function Combat.heal(player, amount)
	local max = player:GetAttribute("MaxCalm") or Config.Player.BaseCalm
	local calm = player:GetAttribute("Calm") or max
	if calm < max then
		player:SetAttribute("Calm", math.min(max, calm + amount))
	end
end

function Combat.setMeditating(player, on)
	local session = PlayerData.session(player)
	if not session then
		return
	end
	on = on and true or false
	if session.meditating == on then
		return
	end
	local root = Combat.root(player)
	if on and not root then
		return
	end
	session.meditating = on
	session.meditateAt = root and root.Position or nil
	player:SetAttribute("Meditating", on)
end

local function overwhelm(player)
	local session = PlayerData.session(player)
	local profile = PlayerData.get(player)
	if not session or not profile then
		return
	end
	local now = os.clock()
	session.graceUntil = now + Config.Player.OverwhelmGrace + 1.2
	Combat.setMeditating(player, false)
	player:SetAttribute("Calm", player:GetAttribute("MaxCalm"))
	local line = Story.OverwhelmLines[math.random(1, #Story.OverwhelmLines)]
	Remotes.fxTo(player, "overwhelm", { text = line })
	task.delay(0.7, function()
		if player.Parent then
			Combat.toShrine(player, profile.checkpoint)
		end
	end)
end

-- Reduce a player's Calm. Returns true if it landed.
function Combat.hurt(player, amount)
	local session = PlayerData.session(player)
	if not session or not Combat.root(player) then
		return false
	end
	local now = os.clock()
	if now < session.graceUntil then
		return false
	end
	if session.meditating then
		amount = amount * Config.Player.MeditateShield
	end
	if now < session.shieldUntil then
		amount = amount * 0.7
	end
	session.lastHurt = now
	local calm = (player:GetAttribute("Calm") or 0) - amount
	if calm <= 0 then
		overwhelm(player)
	else
		player:SetAttribute("Calm", calm)
		Remotes.fxTo(player, "hurt", { amount = amount })
	end
	return true
end

function Combat.slow(player, seconds)
	local session = PlayerData.session(player)
	if session then
		session.slowUntil = math.max(session.slowUntil, os.clock() + seconds)
		Combat.refreshSpeed(player)
	end
end

function Combat.canBeTargeted(player)
	local session = PlayerData.session(player)
	if not session or os.clock() < session.graceUntil then
		return false
	end
	return Combat.root(player) ~= nil
end

----------------------------------------------------------------------
-- Striking targets
----------------------------------------------------------------------
function Combat.damage(target, player, amount)
	if not target.alive or target.invulnerable then
		return false
	end
	amount = math.floor(amount + 0.5)
	target.hp = target.hp - amount
	if player then
		target.tagged[player] = true
	end
	if target.hum then
		target.hum.Health = math.max(1, target.hp)
	end
	if target.root then
		Remotes.fx("hit", { pos = target.root.Position + Vector3.new(0, 3, 0), amount = amount })
	end
	if target.onDamage then
		target.onDamage(target, player, amount)
	end
	if target.hp <= 0 then
		target.alive = false
		if target.onDefeat then
			target.onDefeat(target, player)
		end
	end
	return true
end

local function targetsNear(pos, range)
	local found = {}
	for _, t in ipairs(Combat.targets) do
		if t.alive and t.root and t.root.Parent then
			local d = (t.root.Position - pos).Magnitude - (t.hitRadius or 0)
			if d <= range then
				table.insert(found, { target = t, dist = d })
			end
		end
	end
	table.sort(found, function(a, b)
		return a.dist < b.dist
	end)
	return found
end
Combat.targetsNear = targetsNear

local function ready(session, name, cooldown)
	local now = os.clock()
	if now < (session.cooldowns[name] or 0) then
		return false
	end
	session.cooldowns[name] = now + cooldown
	return true
end

local function strikePower(player)
	local profile = PlayerData.get(player)
	local dmg = profile.abilities.staff and Config.StaffDamage or Config.Abilities.strike.damage
	if PlayerData.hasPath(player, "action") then
		dmg = dmg * 1.3
	end
	if (profile.inv.vajra or 0) > 0 then
		dmg = dmg * 1.25
	end
	return dmg
end

local Abilities = {}

function Abilities.strike(player, session, profile, root)
	if not ready(session, "strike", Config.Abilities.strike.cooldown - 0.08) then
		return
	end
	Combat.setMeditating(player, false)
	local range = profile.abilities.staff and Config.StaffRange or Config.Abilities.strike.range
	local look = root.CFrame.LookVector
	local dmg = strikePower(player)
	local hits = 0
	for _, entry in ipairs(targetsNear(root.Position, range)) do
		local t = entry.target
		local to = t.root.Position - root.Position
		local flat = Vector3.new(to.X, 0, to.Z)
		if flat.Magnitude < 3 + (t.hitRadius or 0) or flat.Unit:Dot(look) > 0.1 then
			Combat.damage(t, player, dmg)
			hits = hits + 1
			if hits >= 3 then
				break
			end
		end
	end
end

function Abilities.beads(player, session, profile, root)
	if not profile.abilities.beads then
		return
	end
	local cd = Config.Abilities.beads.cooldown
	if (profile.inv.long_mala or 0) > 0 then
		cd = cd / 2
	end
	if not ready(session, "beads", cd - 0.08) then
		return
	end
	Combat.setMeditating(player, false)
	local origin = root.Position + Vector3.new(0, 1.5, 0)
	local dir = root.CFrame.LookVector
	local best = nil
	for _, entry in ipairs(targetsNear(root.Position, Config.Abilities.beads.range)) do
		local to = entry.target.root.Position - root.Position
		if to.Magnitude > 0.1 and to.Unit:Dot(root.CFrame.LookVector) > -0.25 then
			best = entry.target
			break
		end
	end
	if best then
		local to = (best.root.Position + Vector3.new(0, 1, 0)) - origin
		if to.Magnitude > 0.1 then
			dir = to.Unit
		end
	end
	local bead = Instance.new("Part")
	bead.Name = "Bead"
	bead.Shape = Enum.PartType.Ball
	bead.Size = Vector3.new(1.1, 1.1, 1.1)
	bead.Material = Enum.Material.Neon
	bead.Color = Color3.fromRGB(255, 214, 110)
	bead.Anchored = true
	bead.CanCollide = false
	bead.CanTouch = false
	bead.CanQuery = false
	bead.CastShadow = false
	bead.CFrame = CFrame.new(origin + dir * 2)
	local light = Instance.new("PointLight")
	light.Color = bead.Color
	light.Range = 10
	light.Parent = bead
	bead.Parent = workspace
	table.insert(projectiles, {
		part = bead, dir = dir, speed = 95, life = 1.1, player = player,
		damage = Config.Abilities.beads.damage * (PlayerData.hasPath(player, "action") and 1.3 or 1),
	})
end

function Abilities.metta(player, session, profile, root)
	if not profile.abilities.metta then
		return
	end
	if not ready(session, "metta", Config.Abilities.metta.cooldown - 0.1) then
		return
	end
	local range = Config.Abilities.metta.range
	local dmg = Config.Abilities.metta.damage
	if PlayerData.hasPath(player, "intention") then
		dmg = dmg * 1.4
	end
	Remotes.fx("ring", { pos = root.Position, radius = range, color = Color3.fromRGB(255, 190, 210), time = 0.7 })
	for _, entry in ipairs(targetsNear(root.Position, range)) do
		Combat.damage(entry.target, player, dmg)
	end
	Combat.heal(player, 12)
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local pos = Combat.position(other)
			if pos and (pos - root.Position).Magnitude <= range then
				Combat.heal(other, 25)
				Remotes.notify(other, player.DisplayName .. " shares loving-kindness with you.", "good")
			end
		end
	end
end

function Abilities.bowl(player, session, profile, root)
	if not profile.abilities.bowl then
		return
	end
	if not ready(session, "bowl", Config.Abilities.bowl.cooldown - 0.1) then
		return
	end
	local range = Config.Abilities.bowl.range
	local now = os.clock()
	Remotes.fx("ring", { pos = root.Position, radius = range, color = Color3.fromRGB(255, 220, 130), time = 1.1 })
	for _, entry in ipairs(targetsNear(root.Position, range)) do
		local t = entry.target
		if not t.static then
			local seconds = t.big and 1.5 or Config.Abilities.bowl.stun
			t.stunUntil = math.max(t.stunUntil or 0, now + seconds)
		end
	end
end

function Abilities.meditate(player, session, profile, root, on)
	if on and not ready(session, "meditate", 0.3) then
		return
	end
	Combat.setMeditating(player, on)
end

-- Called when a player presses an ability button.
function Combat.use(player, name, arg)
	local session = PlayerData.session(player)
	local profile = PlayerData.get(player)
	local root = Combat.root(player)
	local fn = Abilities[name]
	if not session or not profile or not root or not fn then
		return
	end
	fn(player, session, profile, root, arg)
end

----------------------------------------------------------------------
-- The walking staff
----------------------------------------------------------------------
function Combat.equipStaff(player)
	local profile = PlayerData.get(player)
	local character = player.Character
	if not profile or not character or not profile.abilities.staff then
		return
	end
	if character:FindFirstChild("WalkingStaff") then
		return
	end
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not hand then
		return
	end
	local staff = Instance.new("Part")
	staff.Name = "WalkingStaff"
	staff.Size = Vector3.new(0.3, 6.2, 0.3)
	staff.Material = Enum.Material.Wood
	staff.Color = Color3.fromRGB(110, 78, 50)
	staff.CanCollide = false
	staff.CanTouch = false
	staff.CanQuery = false
	staff.Massless = true
	staff.CFrame = hand.CFrame * CFrame.new(0, 1.1, -0.55)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hand
	weld.Part1 = staff
	weld.Parent = staff
	for i = 0, 2 do
		local ring = Instance.new("Part")
		ring.Name = "Ring"
		ring.Shape = Enum.PartType.Ball
		ring.Size = Vector3.new(0.55 - i * 0.08, 0.55 - i * 0.08, 0.55 - i * 0.08)
		ring.Material = Enum.Material.Metal
		ring.Color = Color3.fromRGB(226, 178, 54)
		ring.CanCollide = false
		ring.CanTouch = false
		ring.CanQuery = false
		ring.Massless = true
		ring.CFrame = staff.CFrame * CFrame.new(0, 2.5 + i * 0.36, 0)
		local rw = Instance.new("WeldConstraint")
		rw.Part0 = staff
		rw.Part1 = ring
		rw.Parent = ring
		ring.Parent = staff
	end
	staff.Parent = character
end

----------------------------------------------------------------------
-- Loops
----------------------------------------------------------------------
local function spotAt(pos)
	for _, s in ipairs(Config.MeditationSpots) do
		local dx, dz = pos.X - s.x, pos.Z - s.z
		if dx * dx + dz * dz <= s.radius * s.radius then
			return s
		end
	end
	return nil
end

local TICK = 0.5

local function tickPlayer(player, now)
	local session = PlayerData.session(player)
	local root = Combat.root(player)
	if not session or not root then
		return
	end
	local regen = 0
	if session.meditating then
		local moved = session.meditateAt and (root.Position - session.meditateAt).Magnitude or 0
		if moved > 4 then
			Combat.setMeditating(player, false)
		else
			regen = Config.Player.MeditateRegen
			if PlayerData.hasPath(player, "concentration") then
				regen = regen * 2
			end
			local spot = spotAt(root.Position)
			if spot then
				Quests.progress(player, "meditate", spot.id, TICK)
			end
			for _, fn in ipairs(meditateHooks) do
				fn(player, root.Position, TICK)
			end
		end
	elseif now - session.lastHurt > Config.Player.HurtRegenDelay then
		regen = Config.Player.PassiveRegen
	end
	if now < session.regenUntil then
		regen = regen + Config.Items.incense.amount
	end
	if regen > 0 then
		Combat.heal(player, regen * TICK)
	end
	Combat.refreshSpeed(player)
end

function Combat.start()
	task.spawn(function()
		while true do
			task.wait(TICK)
			local now = os.clock()
			for _, player in ipairs(Players:GetPlayers()) do
				local ok, err = pcall(tickPlayer, player, now)
				if not ok then
					warn("[Bodhi Path] player tick failed:", err)
				end
			end
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		for i = #projectiles, 1, -1 do
			local p = projectiles[i]
			p.life = p.life - dt
			local pos = p.part.Position + p.dir * p.speed * dt
			p.part.CFrame = CFrame.new(pos)
			local hit = false
			for _, t in ipairs(Combat.targets) do
				if t.alive and t.root and t.root.Parent then
					if (t.root.Position - pos).Magnitude <= 3.5 + (t.hitRadius or 0) then
						Combat.damage(t, p.player, p.damage)
						hit = true
						break
					end
				end
			end
			if hit or p.life <= 0 then
				p.part:Destroy()
				table.remove(projectiles, i)
			end
		end
	end)

	-- when a step of the journey grants the staff, put it in the player's hand
	Quests.onReward(function(player, reward)
		if reward.ability == "staff" then
			Combat.equipStaff(player)
		end
	end)
end

return Combat
