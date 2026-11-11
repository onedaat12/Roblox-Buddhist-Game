-- Combat: Calm (the player's "health"), the monk's abilities, and meditation.
--
-- Nothing is killed in this game. Mara's soldiers are troubles of the mind; when they are
-- met steadily they are "dispelled" and fall apart into petals, as Mara's weapons turned
-- to flowers. When a player's Calm runs out they are "overwhelmed" and return to the last
-- shrine they prayed at.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
	if now < session.graceUntil or now < session.talkUntil then
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
	if not session or os.clock() < session.graceUntil or os.clock() < session.talkUntil then
		return false
	end
	return Combat.root(player) ~= nil
end

-- While someone is speaking to you (or the story is being told), Mara's shadows wait.
-- The player's screen reports when the last line has been read.
function Combat.beginTalk(player, lines)
	local session = PlayerData.session(player)
	if session then
		local count = type(lines) == "table" and #lines or 1
		local seconds = math.min(240, 20 * count + 5)
		session.talkUntil = math.max(session.talkUntil, os.clock() + seconds)
	end
end

function Combat.endTalk(player)
	local session = PlayerData.session(player)
	if session and os.clock() < session.talkUntil then
		session.talkUntil = os.clock() + 3
	end
end

-- While the Bag or another window is open, the shadows wait: for up to 25 seconds,
-- and then not again until 15 seconds have passed, so it cannot be used to hide
-- in the middle of a fight.
local PAUSE, PAUSE_REST = 25, 15

function Combat.beginPause(player)
	local session = PlayerData.session(player)
	local root = Combat.root(player)
	if not session or not root then
		return
	end
	local now = os.clock()
	if now < (session.pauseReadyAt or 0) then
		if #Combat.targetsNear(root.Position, 45) > 0 then
			Remotes.notify(player, "The shadows will not wait again so soon. Be quick.", "warn")
		end
		return
	end
	session.pauseReadyAt = now + PAUSE + PAUSE_REST
	session.pausedUntil = now + PAUSE
	session.talkUntil = math.max(session.talkUntil, now + PAUSE)
end

function Combat.endPause(player)
	local session = PlayerData.session(player)
	if not session then
		return
	end
	local now = os.clock()
	if now < (session.pausedUntil or 0) then
		session.pausedUntil = 0
		session.pauseReadyAt = now + PAUSE_REST
		if now < session.talkUntil then
			session.talkUntil = now + 2
		end
	end
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

-- Which weapon a player is holding: returns its id and its entry in Config.Weapons.
function Combat.weapon(player)
	local profile = PlayerData.get(player)
	local id = profile and profile.weapon or "palm"
	if id == "auto" then
		id = profile.abilities.staff and "staff" or "palm"
	end
	if id ~= "palm" and (not Config.Weapons[id] or (profile.inv[id] or 0) < 1) then
		id = "palm"
	end
	return id, Config.Weapons[id]
end

local function strikePower(player)
	local profile = PlayerData.get(player)
	local _, weapon = Combat.weapon(player)
	local dmg = weapon.damage
	if PlayerData.hasPath(player, "action") then
		dmg = dmg * 1.3
	end
	if (profile.inv.vajra or 0) > 0 then
		dmg = dmg * 1.25
	end
	return dmg
end

-- The Wheel of Light: flies out, turns, and comes back to the hand.
local wheels = {}

local function throwWheel(player, root, weapon, dmg)
	local disc = Instance.new("Part")
	disc.Name = "ThrownWheel"
	disc.Size = Vector3.new(3.2, 0.3, 3.2)
	disc.Material = Enum.Material.Neon
	disc.Color = Color3.fromRGB(255, 214, 110)
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanTouch = false
	disc.CanQuery = false
	disc.CastShadow = false
	local look = root.CFrame.LookVector
	local dir = Vector3.new(look.X, 0, look.Z)
	if dir.Magnitude < 0.1 then
		dir = Vector3.new(0, 0, -1)
	end
	dir = dir.Unit
	disc.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.5, 0) + dir * 2)
	local light = Instance.new("PointLight")
	light.Color = disc.Color
	light.Range = 14
	light.Parent = disc
	disc.Parent = workspace
	local speed = 90
	table.insert(wheels, {
		part = disc, dir = dir, speed = speed, out = weapon.range / speed, age = 0,
		player = player, damage = dmg, struck = {},
	})
end

local function moveWheels(dt)
	for i = #wheels, 1, -1 do
		local w = wheels[i]
		w.age = w.age + dt
		local pos = w.part.Position
		local done = false
		if w.age < w.out then
			pos = pos + w.dir * w.speed * dt
		else
			local home = Combat.root(w.player)
			if not home or w.age > 4 then
				done = true
			else
				if not w.returning then
					w.returning = true
					w.struck = {} -- it may touch each shadow again on the way back
				end
				local to = (home.Position + Vector3.new(0, 1.5, 0)) - pos
				local step = w.speed * dt
				if to.Magnitude <= step + 2 then
					done = true
				else
					pos = pos + to.Unit * step
				end
			end
		end
		w.part.CFrame = CFrame.new(pos) * CFrame.Angles(0, w.age * 18, 0)
		for _, t in ipairs(Combat.targets) do
			if t.alive and t.root and t.root.Parent and not w.struck[t] then
				if (t.root.Position - pos).Magnitude <= 4.5 + (t.hitRadius or 0) then
					w.struck[t] = true
					Combat.damage(t, w.player, w.damage)
				end
			end
		end
		if done then
			w.part:Destroy()
			table.remove(wheels, i)
		end
	end
end

-- The Paper Lantern: a circle of light stays where you stood. Shadows inside it are
-- slowed and worn away a little at a time.
local function lightLantern(player, root, weapon, dmg)
	local pos = root.Position
	local glow = Instance.new("Part")
	glow.Name = "LanternLight"
	glow.Shape = Enum.PartType.Cylinder
	glow.Size = Vector3.new(0.3, weapon.range * 2, weapon.range * 2)
	glow.Material = Enum.Material.Neon
	glow.Color = Color3.fromRGB(255, 206, 130)
	glow.Transparency = 0.8
	glow.Anchored = true
	glow.CanCollide = false
	glow.CanTouch = false
	glow.CanQuery = false
	glow.CastShadow = false
	glow.CFrame = CFrame.new(pos - Vector3.new(0, 2.7, 0)) * CFrame.Angles(0, 0, math.rad(90))
	local light = Instance.new("PointLight")
	light.Color = glow.Color
	light.Range = 30
	light.Brightness = 1.6
	light.Shadows = false
	light.Parent = glow
	glow.Parent = workspace
	Remotes.fx("ring", { pos = pos, radius = weapon.range, color = glow.Color, time = 0.8 })
	task.spawn(function()
		for _ = 1, weapon.field * 2 do
			task.wait(0.5)
			local now = os.clock()
			for _, entry in ipairs(targetsNear(pos, weapon.range)) do
				local t = entry.target
				t.slowUntil = now + 0.8
				Combat.damage(t, player, dmg)
			end
		end
		glow:Destroy()
	end)
end

local Abilities = {}

function Abilities.strike(player, session, profile, root)
	local _, weapon = Combat.weapon(player)
	if not ready(session, "strike", weapon.cooldown - 0.08) then
		return
	end
	Combat.setMeditating(player, false)
	Combat.swing(player)
	local range = weapon.range
	local look = root.CFrame.LookVector
	local dmg = strikePower(player)
	if weapon.thrown then
		throwWheel(player, root, weapon, dmg)
		return
	end
	if weapon.field then
		lightLantern(player, root, weapon, dmg)
		return
	end
	if weapon.ring then
		Remotes.fx("ring", { pos = root.Position, radius = range, color = Color3.fromRGB(255, 244, 214), time = 0.5 })
	end
	local now = os.clock()
	local hits = 0
	for _, entry in ipairs(targetsNear(root.Position, range)) do
		local t = entry.target
		local to = t.root.Position - root.Position
		local flat = Vector3.new(to.X, 0, to.Z)
		if weapon.all or flat.Magnitude < 3 + (t.hitRadius or 0) or flat.Unit:Dot(look) > 0.1 then
			Combat.damage(t, player, dmg)
			if t.alive and not t.static then
				if weapon.stun then
					local seconds = t.big and weapon.stun * 0.25 or weapon.stun
					t.stunUntil = math.max(t.stunUntil or 0, now + seconds)
				end
				if weapon.push and not t.big and t.model and flat.Magnitude > 0.1 then
					local at = t.root.Position
					local dest = at + flat.Unit * weapon.push
					t.model:PivotTo(CFrame.new(dest.X, at.Y + 0.5, dest.Z))
				end
			end
			hits = hits + 1
			if hits >= weapon.hits then
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
	session.talkUntil = 0 -- acting ends the pause that a conversation gives
	fn(player, session, profile, root, arg)
end

----------------------------------------------------------------------
-- The weapon in the player's hand
----------------------------------------------------------------------
local GRIP = CFrame.new(0, 1.1, -0.55)
local WOOD = Color3.fromRGB(110, 78, 50)
local BRASS = Color3.fromRGB(226, 178, 54)
local STEEL = Color3.fromRGB(196, 200, 208)

-- One piece of a weapon, fixed to its handle.
local function piece(handle, size, offset, color, material, shape)
	local p = Instance.new("Part")
	p.Name = "Piece"
	if shape then
		p.Shape = shape
	end
	p.Size = size
	p.Material = material or Enum.Material.Wood
	p.Color = color
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = false
	p.CFrame = handle.CFrame * offset
	local w = Instance.new("WeldConstraint")
	w.Part0 = handle
	w.Part1 = p
	w.Parent = p
	p.Parent = handle
	return p
end

-- Each builder shapes the handle, adds the pieces, and returns the height of the
-- weapon's tip above the middle of the handle.
local Builders = {}

function Builders.staff(handle)
	handle.Size = Vector3.new(0.3, 6.2, 0.3)
	for i = 0, 2 do
		local d = 0.55 - i * 0.08
		piece(handle, Vector3.new(d, d, d), CFrame.new(0, 2.5 + i * 0.36, 0), BRASS, Enum.Material.Metal, Enum.PartType.Ball)
	end
	return 3.1
end

function Builders.whisk(handle)
	handle.Size = Vector3.new(0.26, 2.2, 0.26)
	handle.Color = Color3.fromRGB(120, 36, 30)
	piece(handle, Vector3.new(0.4, 0.3, 0.4), CFrame.new(0, 1.2, 0), BRASS, Enum.Material.Metal)
	piece(handle, Vector3.new(0.55, 1.5, 0.55), CFrame.new(0, 2.05, 0), Color3.fromRGB(244, 240, 228), Enum.Material.Fabric)
	piece(handle, Vector3.new(0.4, 1.3, 0.4), CFrame.new(0, 3.3, 0), Color3.fromRGB(236, 232, 218), Enum.Material.Fabric)
	return 3.9
end

function Builders.spade(handle)
	handle.Size = Vector3.new(0.34, 7.4, 0.34)
	-- the flat spade at the top
	piece(handle, Vector3.new(1.5, 0.3, 0.2), CFrame.new(0, 3.75, 0), STEEL, Enum.Material.Metal)
	piece(handle, Vector3.new(1.9, 1.1, 0.14), CFrame.new(0, 4.4, 0), STEEL, Enum.Material.Metal)
	-- the crescent at the foot
	piece(handle, Vector3.new(0.5, 0.4, 0.5), CFrame.new(0, -3.7, 0), BRASS, Enum.Material.Metal)
	for _, side in ipairs({ -1, 1 }) do
		piece(handle, Vector3.new(1.1, 0.3, 0.14), CFrame.new(side * 0.5, -4.05, 0) * CFrame.Angles(0, 0, math.rad(side * -35)), STEEL, Enum.Material.Metal)
	end
	for i = 0, 1 do
		piece(handle, Vector3.new(0.5, 0.5, 0.5), CFrame.new(0, 3.2 - i * 0.4, 0), BRASS, Enum.Material.Metal, Enum.PartType.Ball)
	end
	return 4.9
end

function Builders.wisdom_sword(handle)
	handle.Size = Vector3.new(0.3, 1.3, 0.3)
	handle.Color = BRASS
	handle.Material = Enum.Material.Metal
	piece(handle, Vector3.new(0.5, 0.5, 0.5), CFrame.new(0, -0.8, 0), BRASS, Enum.Material.Metal, Enum.PartType.Ball)
	piece(handle, Vector3.new(1.5, 0.28, 0.4), CFrame.new(0, 0.75, 0), BRASS, Enum.Material.Metal)
	local blade = piece(handle, Vector3.new(0.5, 4.4, 0.14), CFrame.new(0, 3.05, 0), Color3.fromRGB(255, 206, 110), Enum.Material.Neon)
	piece(handle, Vector3.new(0.3, 0.6, 0.12), CFrame.new(0, 5.5, 0), Color3.fromRGB(255, 226, 150), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 190, 90)
	light.Range = 12
	light.Brightness = 1.3
	light.Shadows = false
	light.Parent = blade
	local flame = Instance.new("ParticleEmitter")
	flame.Rate = 14
	flame.Lifetime = NumberRange.new(0.4, 0.8)
	flame.Speed = NumberRange.new(1, 2.5)
	flame.SpreadAngle = Vector2.new(25, 25)
	flame.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0) })
	flame.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	flame.Color = ColorSequence.new(Color3.fromRGB(255, 170, 60))
	flame.LightEmission = 0.9
	flame.Parent = blade
	return 5.8
end

function Builders.conch(handle)
	local shell = Color3.fromRGB(246, 242, 232)
	handle.Size = Vector3.new(0.45, 1.2, 0.45)
	handle.Color = shell
	handle.Material = Enum.Material.SmoothPlastic
	piece(handle, Vector3.new(0.6, 0.3, 0.6), CFrame.new(0, -0.75, 0), BRASS, Enum.Material.Metal)
	piece(handle, Vector3.new(1.3, 1.3, 1.3), CFrame.new(0, 0.6, 0), shell, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	piece(handle, Vector3.new(0.95, 0.95, 0.95), CFrame.new(0, 1.35, 0), shell, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	piece(handle, Vector3.new(0.6, 0.6, 0.6), CFrame.new(0, 1.9, 0), shell, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	piece(handle, Vector3.new(0.35, 0.35, 0.35), CFrame.new(0, 2.3, 0), BRASS, Enum.Material.Metal, Enum.PartType.Ball)
	return 2.4
end

function Builders.bell(handle)
	handle.Size = Vector3.new(0.25, 1.5, 0.25)
	handle.Color = BRASS
	handle.Material = Enum.Material.Metal
	-- the half-vajra on top of the handle
	piece(handle, Vector3.new(0.45, 0.45, 0.45), CFrame.new(0, 0.85, 0), BRASS, Enum.Material.Metal, Enum.PartType.Ball)
	piece(handle, Vector3.new(0.2, 0.5, 0.2), CFrame.new(0, 1.25, 0), BRASS, Enum.Material.Metal)
	-- the bell itself, hanging below the hand
	piece(handle, Vector3.new(0.9, 0.3, 0.9), CFrame.new(0, -1.7, 0), BRASS, Enum.Material.Metal)
	piece(handle, Vector3.new(1.25, 0.8, 1.25), CFrame.new(0, -2.2, 0), BRASS, Enum.Material.Metal)
	piece(handle, Vector3.new(1.5, 0.2, 1.5), CFrame.new(0, -2.65, 0), BRASS, Enum.Material.Metal)
	return 1.5
end

function Builders.phurba(handle)
	handle.Size = Vector3.new(0.3, 1.2, 0.3)
	handle.Color = BRASS
	handle.Material = Enum.Material.Metal
	piece(handle, Vector3.new(0.55, 0.55, 0.55), CFrame.new(0, -0.8, 0), BRASS, Enum.Material.Metal, Enum.PartType.Ball)
	piece(handle, Vector3.new(0.7, 0.2, 0.7), CFrame.new(0, 0.65, 0), BRASS, Enum.Material.Metal)
	piece(handle, Vector3.new(0.45, 1.2, 0.45), CFrame.new(0, 1.3, 0) * CFrame.Angles(0, math.rad(45), 0), STEEL, Enum.Material.Metal)
	piece(handle, Vector3.new(0.3, 1, 0.3), CFrame.new(0, 2.3, 0) * CFrame.Angles(0, math.rad(45), 0), STEEL, Enum.Material.Metal)
	piece(handle, Vector3.new(0.15, 0.7, 0.15), CFrame.new(0, 3.1, 0) * CFrame.Angles(0, math.rad(45), 0), STEEL, Enum.Material.Metal)
	return 3.4
end

function Builders.chakra(handle)
	local gold = Color3.fromRGB(255, 214, 110)
	handle.Size = Vector3.new(0.25, 0.9, 0.25)
	handle.Color = BRASS
	handle.Material = Enum.Material.Metal
	local centre = CFrame.new(0, 1.9, 0)
	piece(handle, Vector3.new(0.7, 0.7, 0.7), centre, gold, Enum.Material.Neon, Enum.PartType.Ball)
	for i = 0, 3 do
		piece(handle, Vector3.new(0.16, 2.7, 0.2), centre * CFrame.Angles(0, 0, math.rad(i * 45)), BRASS, Enum.Material.Metal)
	end
	for i = 0, 7 do
		piece(handle, Vector3.new(1.12, 0.22, 0.28), centre * CFrame.Angles(0, 0, math.rad(i * 45)) * CFrame.new(0, 1.35, 0), BRASS, Enum.Material.Metal)
	end
	return 3.3
end

function Builders.lantern(handle)
	handle.Size = Vector3.new(0.2, 3, 0.2)
	local red = Color3.fromRGB(176, 40, 36)
	piece(handle, Vector3.new(1.3, 0.15, 1.3), CFrame.new(0, 1.6, 0), red, Enum.Material.Wood)
	local paper = piece(handle, Vector3.new(1.15, 1.5, 1.15), CFrame.new(0, 2.4, 0), Color3.fromRGB(255, 214, 150), Enum.Material.Neon)
	piece(handle, Vector3.new(1.3, 0.15, 1.3), CFrame.new(0, 3.2, 0), red, Enum.Material.Wood)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 200, 120)
	light.Range = 16
	light.Brightness = 1.4
	light.Shadows = false
	light.Parent = paper
	return 3.3
end

-- Put the chosen weapon in the player's hand (or take it away for the open palm).
function Combat.equipWeapon(player)
	local profile = PlayerData.get(player)
	local character = player.Character
	if not profile or not character then
		return
	end
	local id = Combat.weapon(player)
	local old = character:FindFirstChild("HeldWeapon")
	if old then
		if old:GetAttribute("Weapon") == id then
			return
		end
		old:Destroy()
	end
	local build = Builders[id]
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not build or not hand then
		return
	end
	local handle = Instance.new("Part")
	handle.Name = "HeldWeapon"
	handle:SetAttribute("Weapon", id)
	handle.Material = Enum.Material.Wood
	handle.Color = WOOD
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false
	handle.Massless = true
	handle.CFrame = hand.CFrame * GRIP
	local tip = build(handle)

	-- a streak of light that follows the tip while the weapon is swung
	local a0 = Instance.new("Attachment")
	a0.Name = "TipTop"
	a0.Position = Vector3.new(0, tip, 0)
	a0.Parent = handle
	local a1 = Instance.new("Attachment")
	a1.Name = "TipLow"
	a1.Position = Vector3.new(0, tip - 2.2, 0)
	a1.Parent = handle
	local trail = Instance.new("Trail")
	trail.Name = "SwingTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.22
	trail.MinLength = 0.05
	trail.LightEmission = 0.8
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 232, 170))
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
	trail.Enabled = false
	trail.Parent = handle

	-- held by a joint, so that it can be swung
	local grip = Instance.new("Weld")
	grip.Name = "Grip"
	grip.Part0 = hand
	grip.Part1 = handle
	grip.C0 = GRIP
	grip.Parent = handle
	handle.Parent = character
end

-- Sweep the held weapon forward and down in a wide arc, then bring it back.
function Combat.swing(player)
	local character = player.Character
	local handle = character and character:FindFirstChild("HeldWeapon")
	local grip = handle and handle:FindFirstChild("Grip")
	local id, weapon = Combat.weapon(player)
	if not grip or not weapon.swing or handle:GetAttribute("Swinging") then
		return
	end
	handle:SetAttribute("Swinging", true)
	local trail = handle:FindFirstChild("SwingTrail")
	if trail then
		trail.Enabled = true
	end
	local out = math.min(0.16, weapon.cooldown * 0.3)
	local back = math.min(0.22, weapon.cooldown * 0.45)
	local raised = CFrame.Angles(math.rad(35), 0, 0) * GRIP
	local swept = CFrame.Angles(math.rad(-weapon.swing), 0, math.rad(id == "whisk" and 35 or 0)) * GRIP
	grip.C0 = raised
	TweenService:Create(grip, TweenInfo.new(out, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = swept }):Play()
	task.delay(out + 0.03, function()
		if not grip.Parent then
			return
		end
		TweenService:Create(grip, TweenInfo.new(back, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { C0 = GRIP }):Play()
		task.wait(back)
		if handle.Parent then
			if trail then
				trail.Enabled = false
			end
			handle:SetAttribute("Swinging", false)
		end
	end)
end

-- Choose what to hold. Choosing the weapon already in hand puts it away.
function Combat.chooseWeapon(player, id)
	local profile = PlayerData.get(player)
	if not profile or not Config.Weapons[id] or id == "palm" or (profile.inv[id] or 0) < 1 then
		return
	end
	local current = Combat.weapon(player)
	if current == id then
		profile.weapon = "palm"
		Remotes.notify(player, "You put away the " .. Config.Weapons[id].name .. ". Your hands are open.", "info")
	else
		profile.weapon = id
		Remotes.notify(player, "You take up the " .. Config.Weapons[id].name .. ".", "good")
	end
	Combat.equipWeapon(player)
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
		moveWheels(dt)
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
			PlayerData.give(player, "staff", 1)
			local profile = PlayerData.get(player)
			if profile and profile.weapon == "palm" then
				profile.weapon = "staff"
			end
			Combat.equipWeapon(player)
			PlayerData.push(player)
		end
	end)

	Remotes.onDialog = Combat.beginTalk
end

return Combat
