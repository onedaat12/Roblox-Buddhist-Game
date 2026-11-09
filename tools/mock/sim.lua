-- Simulated playthrough. Loads the game's scripts into the stand-in engine (mock.lua),
-- starts the server, adds one player, starts that player's screen, and then plays the
-- whole journey from the temple to the Bodhi tree, reporting anything that goes wrong.
-- Expects globals: MOCK, FILES, OUT_DIR.

local Mock = MOCK
local data, methods, fire, sig = Mock.data, Mock.methods, Mock.fire, Mock.sig

local function section(name)
	print("")
	print("== " .. name .. " (t=" .. string.format("%.0f", Mock.now) .. "s)")
end

----------------------------------------------------------------------
-- Put the scripts where Roblox would put them
----------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
for _, name in ipairs({ "Lighting", "CollectionService", "TweenService", "RunService", "DataStoreService", "Debris", "UserInputService", "StarterGui" }) do
	game:GetService(name)
end

local function folder(parent, name)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end
local sps = Mock.create("StarterPlayerScripts")
Mock.setParent(sps, StarterPlayer)
local homes = {
	shared = folder(ReplicatedStorage, "Shared"),
	server = folder(ServerScriptService, "Server"),
	client = folder(sps, "Client"),
}
local scripts = {}
for _, file in ipairs(FILES) do
	local inst = Mock.create(file.class)
	data[inst].props.Name = file.name
	data[inst].source = file.source
	Mock.setParent(inst, homes[file.dir])
	scripts[file.dir .. "/" .. file.name] = inst
end

local function start(key)
	local inst = scripts[key]
	local fn = Mock.runScript(inst, data[inst].source, key)
	if fn then
		task.spawn(fn)
	end
end

local function module(name)
	for inst, value in pairs(Mock.loaded) do
		if data[inst].props.Name == name then
			return value
		end
	end
	error("module not loaded: " .. name)
end

----------------------------------------------------------------------
section("Starting the server")
start("server/Main")
Mock.run(3)

local parts, promptsList = 0, {}
for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("BasePart") then
		parts = parts + 1
	elseif d:IsA("ProximityPrompt") then
		table.insert(promptsList, d)
	end
end
print("  parts in the world: " .. parts .. ", prompts: " .. #promptsList .. ", terrain fills: " .. #Mock.terrain)

----------------------------------------------------------------------
section("A player joins")
local player = Mock.create("Player")
data[player].props.Name = "Tester"
data[player].props.DisplayName = "Tester"
data[player].props.UserId = 1
local playerGui = Mock.create("PlayerGui")
Mock.setParent(playerGui, player)
Mock.setParent(player, Players)
Mock.localPlayer = player
data[Players].props.LocalPlayer = player
fire(sig(Players, "PlayerAdded"), player)
Mock.run(4)

section("Starting the player's screen")
start("client/Main")
Mock.run(3)

local Config = module("Config")
local Story = module("Story")
local PlayerData = module("PlayerData")
local Combat = module("Combat")
local Remotes = ReplicatedStorage.Remotes
local BossState = ReplicatedStorage.BossState
local profile = PlayerData.get(player)
assert(profile, "the player's profile was not loaded")

local function act(...)
	Remotes.Action:FireServer(...)
end
local function tp(x, z, y)
	local character = player.Character
	character:PivotTo(CFrame.new(x, y or 4, z))
end
local function prompts()
	local list = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			table.insert(list, d)
		end
	end
	return list
end
local function trigger(objectText, all)
	local n = 0
	for _, p in ipairs(prompts()) do
		if p.ObjectText == objectText then
			local part = p.Parent
			if part:IsA("BasePart") then
				tp(part.Position.X + 3, part.Position.Z, part.Position.Y + 2)
			end
			fire(sig(p, "Triggered"), player)
			n = n + 1
			if not all then
				break
			end
		end
	end
	if n == 0 then
		Mock.errors = Mock.errors + 1
		print("  ERROR: no prompt found for \"" .. objectText .. "\"")
	end
	return n
end
local function npc(id)
	for _, def in ipairs(Story.NPCs) do
		if def.id == id then
			return def
		end
	end
end

local INTERACT = { temple_bell = "Temple Bell", hair_rock = "The Flat Rock", bowl_river = "The Neranjara", vajrasana = "The Diamond Seat" }

local function findTarget(want)
	for _, t in ipairs(Combat.targets) do
		if t.alive and t.root and (want == nil or t.typeId == want or t.group == want or (want == "temp" and t.temporary)) then
			return t
		end
	end
	return nil
end
local function attack(t)
	local p = t.root.Position
	player.Character:PivotTo(CFrame.new(Vector3.new(p.X - 4 - (t.hitRadius or 0), p.Y, p.Z), Vector3.new(p.X, p.Y, p.Z)))
	act("strike")
	act("beads")
	act("metta")
	act("bowl")
end

local overwhelmed = 0
Remotes.Fx.OnClientEvent:Connect(function(name)
	if name == "overwhelm" then
		overwhelmed = overwhelmed + 1
	end
end)

local function doObjective(obj)
	if obj.kind == "talk" then
		trigger(npc(obj.target).name)
	elseif obj.kind == "interact" then
		trigger(INTERACT[obj.target])
	elseif obj.kind == "alms" then
		for _, def in ipairs(Story.NPCs) do
			if def.alms then
				trigger(def.name)
			end
		end
	elseif obj.kind == "meditate" then
		for _, s in ipairs(Config.MeditationSpots) do
			if s.id == obj.target then
				tp(s.x, s.z, (obj.target == "bodhi_seat") and 6 or 4)
			end
		end
		act("meditate", true)
		Mock.run(obj.count + 2)
	elseif obj.kind == "reach" then
		local a = Config.Areas[obj.target]
		tp(a.x, a.z)
		Mock.run(2)
	elseif obj.kind == "dispel" then
		local t = findTarget(obj.target)
		if t then
			attack(t)
		else
			for _, s in ipairs(Config.Spawns) do
				if s.type == obj.target or s.group == obj.target then
					tp(s.x + 12, s.z)
					break
				end
			end
		end
		Mock.run(0.5)
	elseif obj.kind == "collect" then
		trigger("Kusa Grass", true)
	elseif obj.kind == "use" then
		act("UseItem", obj.target)
	elseif obj.kind == "boss" then
		local phase = BossState:GetAttribute("Phase")
		local a = Config.Places.arena
		if phase == "idle" or phase == "won" then
			tp(a.x, a.z)
			Mock.run(1.5)
		elseif phase == "witness" then
			tp(a.x, a.z)
			act("TouchEarth")
			Mock.run(1)
		elseif phase == "storms" then
			tp(a.x, a.z)
			act("meditate", true)
			Mock.run(2)
		else
			local t = findTarget("temp")
			if phase == "mara" then
				for _, c in ipairs(Combat.targets) do
					if c.name == "Mara" and c.alive then
						t = c
					end
				end
			end
			if t then
				attack(t)
			else
				tp(a.x, a.z)
			end
			Mock.run(0.5)
		end
	end
end

----------------------------------------------------------------------
section("Playing the journey")
local lastStage, stageStart = 0, Mock.now
local guard = 0
while profile.stage < #Story.Quests and guard < 20000 do
	guard = guard + 1
	local quest = Story.Quests[profile.stage]
	if profile.stage ~= lastStage then
		if lastStage > 0 then
			print(string.format("  step %2d %-28s done in %4.0fs  merit %d", lastStage, Story.Quests[lastStage].id, Mock.now - stageStart, profile.merit))
		end
		lastStage, stageStart = profile.stage, Mock.now
	end
	if Mock.errors > 12 then
		print("  too many errors; stopping the journey")
		break
	end
	if Mock.now - stageStart > 900 then
		Mock.errors = Mock.errors + 1
		print("  ERROR: stuck on step " .. quest.id)
		break
	end
	local did = false
	for i, obj in ipairs(quest.objectives) do
		if (profile.prog[tostring(i)] or 0) < (obj.count or 1) then
			doObjective(obj)
			did = true
			break
		end
	end
	Mock.run(0.3)
	if not did then
		Mock.run(0.5)
	end
end
print(string.format("  finished at step %d of %d (%s); overwhelmed %d times; total time %.0fs", profile.stage, #Story.Quests, Story.Quests[profile.stage].id, overwhelmed, Mock.now))
if profile.stage < #Story.Quests then
	Mock.errors = Mock.errors + 1
	print("  ERROR: the journey could not be completed")
end
if not profile.awakened then
	Mock.errors = Mock.errors + 1
	print("  ERROR: the player was not marked as awakened")
end

----------------------------------------------------------------------
section("Trying everything else")
profile.merit = 5000
for _, s in ipairs(Config.Shrines) do
	trigger(s.name)
end
Mock.run(1)
tp(Config.Shrines[1].x - 5, Config.Shrines[1].z)
for _ = 1, #Config.Path + 1 do
	act("BuyPath")
end
for shopId, shop in pairs(Config.Shops) do
	for _, entry in ipairs(shop.stock) do
		act("Buy", shopId, entry.item)
		act("Buy", shopId, entry.item)
	end
end
for _, robe in ipairs(Config.Robes) do
	act("BuyRobe", robe.id)
	act("WearRobe", robe.id)
end
Mock.run(2)
for id in pairs(Config.Items) do
	act("UseItem", id)
end
act("UseItem", "nonsense")
act("Buy", "nowhere", 5)
act("Travel", "bodhgaya")
Mock.run(2)
trigger("Prayer Wheel", true)
trigger("Temple Bell")
trigger("Bodhi Leaf", true)
trigger("Lotus Flower", true)
trigger("Lotus Flower", true)
trigger("Challenge Mara")
for _, def in ipairs(Story.NPCs) do
	trigger(def.name)
	trigger(def.name)
end
Mock.run(3)
local leaves = 0
for _ in pairs(profile.leaves) do
	leaves = leaves + 1
end
print("  path steps: " .. profile.path .. "/" .. #Config.Path .. ", leaves: " .. leaves .. "/" .. #Config.Leaves .. ", pilgrim robe: " .. tostring(profile.robes.pilgrim == true))
if profile.path ~= #Config.Path or leaves ~= #Config.Leaves then
	Mock.errors = Mock.errors + 1
	print("  ERROR: the Eightfold Path or the leaves did not complete")
end

-- every window and every button on the player's screen
for _, kind in ipairs({ { "shop", "village" }, { "shop", "senani" }, { "robes" }, { "shrine", "village" } }) do
	Remotes.UI:FireClient(player, kind[1], kind[2])
	Mock.run(0.3)
end
local pressed = 0
for round = 1, 2 do
	for _, d in ipairs(playerGui:GetDescendants()) do
		if d:IsA("TextButton") and d.Parent then
			fire(sig(d, "Activated"))
			pressed = pressed + 1
			Mock.run(0.05)
		end
	end
end
local UIS = game:GetService("UserInputService")
for _, key in ipairs({ "F", "R", "Q", "G", "M", "B", "P", "T", "Space", "Escape", "M" }) do
	fire(sig(UIS, "InputBegan"), { KeyCode = Enum.KeyCode[key], UserInputType = Enum.UserInputType.Keyboard }, false)
	Mock.run(0.2)
end
fire(sig(UIS, "InputBegan"), { KeyCode = Enum.KeyCode.A, UserInputType = Enum.UserInputType.MouseButton1 }, false)
for _, fx in ipairs({ "petals", "ring", "hit", "bell", "hurt", "fade", "overwhelm", "storm", "quake", "awaken" }) do
	Remotes.Fx:FireClient(player, fx, { pos = Vector3.new(0, 5, 0), amount = 5, color = Color3.new(1, 0, 0), radius = 10, text = "x" })
end
Mock.run(15)
print("  buttons pressed: " .. pressed)

-- walk the length of the world so every zone's light and title is shown
for x = -100, 2800, 150 do
	tp(x, 0)
	Mock.run(0.6)
end

-- a second fight with Mara, started from the gong, and left unfinished
trigger("Challenge Mara")
tp(Config.Places.arena.x, Config.Places.arena.z)
Mock.run(20)
tp(0, 0)
Mock.run(30)

-- the player dies, respawns, leaves; then comes back and finds their progress saved
local hum = player.Character:FindFirstChildOfClass("Humanoid")
data[hum].props.Health = 0
fire(sig(hum, "Died"))
Mock.run(6)
fire(sig(Players, "PlayerRemoving"), player)
Mock.run(1)
fire(sig(Players, "PlayerAdded"), player)
Mock.run(4)
local again = PlayerData.get(player)
print("  after rejoining: step " .. tostring(again and again.stage) .. ", merit " .. tostring(again and again.merit))
if not again or again.stage ~= #Story.Quests then
	Mock.errors = Mock.errors + 1
	print("  ERROR: progress was not saved and restored")
end

----------------------------------------------------------------------
-- Write the world out so it can be looked at in a browser (tools/viewer.html)
----------------------------------------------------------------------
if OUT_DIR then
	local out = {}
	local function n(v)
		return string.format("%.2f", v)
	end
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 0.95 and not d:IsDescendantOf(player.Character) then
			local cf, s, c = d.CFrame, d.Size, d.Color
			local shape = "b"
			if d:IsA("Part") then
				if d.Shape == Enum.PartType.Cylinder then
					shape = "c"
				elseif d.Shape == Enum.PartType.Ball or d:FindFirstChildOfClass("SpecialMesh") then
					shape = "s"
				end
			end
			local m = { cf:GetComponents() }
			local nums = {}
			for i = 1, 12 do
				nums[i] = n(m[i])
			end
			out[#out + 1] = string.format('["%s",%s,%s,%s,%s,%d,%d,%d,%s]', shape, table.concat(nums, ","), n(s.X), n(s.Y), n(s.Z), math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255), n(d.Transparency))
		end
	end
	local terr = {}
	for _, t in ipairs(Mock.terrain) do
		if t.kind == "block" then
			terr[#terr + 1] = string.format('["block","%s",%s,%s,%s,%s,%s,%s]', t.mat, n(t.cf.X), n(t.cf.Y), n(t.cf.Z), n(t.size.X), n(t.size.Y), n(t.size.Z))
		elseif t.kind == "ball" then
			terr[#terr + 1] = string.format('["ball","%s",%s,%s,%s,%s]', t.mat, n(t.pos.X), n(t.pos.Y), n(t.pos.Z), n(t.r))
		else
			terr[#terr + 1] = string.format('["cyl","%s",%s,%s,%s,%s,%s]', t.mat, n(t.cf.X), n(t.cf.Y), n(t.cf.Z), n(t.h), n(t.r))
		end
	end
	WORLD_JSON = '{"parts":[' .. table.concat(out, ",\n") .. '],"terrain":[' .. table.concat(terr, ",\n") .. "]}"
	print("")
	print("  world snapshot: " .. #out .. " parts")
end

section("Result")
local stubs = {}
for name, count in pairs(Mock.stubs) do
	stubs[#stubs + 1] = name .. " x" .. count
end
table.sort(stubs)
if #stubs > 0 then
	print("  engine features the stand-in does not act out (called, not simulated):")
	print("    " .. table.concat(stubs, ", "))
end
print("  warnings: " .. tostring(Mock.warnings or 0) .. ", errors: " .. Mock.errors)
SIM_ERRORS = Mock.errors
