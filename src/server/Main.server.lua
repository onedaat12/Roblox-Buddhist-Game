-- The Bodhi Path: server start-up.
-- Builds the world, then looks after each player who arrives.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

Players.CharacterAutoLoads = false
Players.RespawnTime = 3

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))

local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Quests = require(script.Parent.Quests)
local World = require(script.Parent.World)
local Rig = require(script.Parent.Rig)
local Combat = require(script.Parent.Combat)
local Enemies = require(script.Parent.Enemies)
local NPCs = require(script.Parent.NPCs)
local Robes = require(script.Parent.Robes)
local Interact = require(script.Parent.Interact)
local Boss = require(script.Parent.Boss)

local function step(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[Bodhi Path] " .. name .. " failed: " .. tostring(err))
	end
end

step("Building the world", World.build)
step("Preparing characters", Rig.init)
step("Combat", Combat.start)
step("People", NPCs.start)
step("Mara's armies", Enemies.start)
step("Mara", function()
	Boss.start(World.objects)
end)
step("Interactions", function()
	Interact.start(World.objects)
end)

----------------------------------------------------------------------
-- Awakening
----------------------------------------------------------------------
Quests.onComplete(function(player, quest)
	if quest.id ~= "watch3" then
		return
	end
	local profile = PlayerData.get(player)
	if not profile then
		return
	end
	profile.awakened = true
	profile.robe = "golden"
	player:SetAttribute("Awakened", true)
	Combat.setMeditating(player, false)
	Remotes.fxTo(player, "awaken", {})
	Remotes.notifyAll(player.DisplayName .. " has awakened beneath the Bodhi tree.", "good")
	PlayerData.push(player)
	task.wait(1)
	Robes.apply(player)
end)

----------------------------------------------------------------------
-- Players
----------------------------------------------------------------------
local ABILITY = { strike = true, beads = true, metta = true, bowl = true, meditate = true }

Remotes.Action.OnServerEvent:Connect(function(player, kind, a, b)
	if type(kind) ~= "string" or not PlayerData.get(player) then
		return
	end
	local ok, err = pcall(function()
		if ABILITY[kind] then
			Combat.use(player, kind, a)
		elseif kind == "TouchEarth" then
			Boss.touchEarth(player)
		elseif kind == "DialogDone" then
			Combat.endTalk(player)
		elseif kind == "Ready" then
			PlayerData.push(player)
		else
			Interact.action(player, kind, a, b)
		end
	end)
	if not ok then
		warn("[Bodhi Path] action " .. kind .. " failed: " .. tostring(err))
	end
end)

local function onCharacter(player, character)
	local waited = 0
	while not PlayerData.get(player) and player.Parent and waited < 20 do
		task.wait(0.1)
		waited = waited + 0.1
	end
	local profile = PlayerData.get(player)
	if not profile or character.Parent == nil then
		return
	end
	local session = PlayerData.session(player)
	session.meditating = false
	session.graceUntil = os.clock() + 3
	player:SetAttribute("Meditating", false)
	player:SetAttribute("Calm", PlayerData.maxCalm(player))

	task.wait(0.15)
	Combat.toShrine(player, profile.checkpoint)

	local hum = character:WaitForChild("Humanoid", 10)
	if hum then
		hum.Died:Connect(function()
			task.wait(Players.RespawnTime)
			if player.Parent then
				player:LoadCharacter()
			end
		end)
	end

	if not player:HasAppearanceLoaded() then
		local t = 0
		while not player:HasAppearanceLoaded() and t < 6 and character.Parent do
			task.wait(0.25)
			t = t + 0.25
		end
	end
	if character.Parent then
		Robes.apply(player)
		Combat.refreshSpeed(player)
	end
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		local ok, err = pcall(onCharacter, player, character)
		if not ok then
			warn("[Bodhi Path] character setup failed: " .. tostring(err))
		end
	end)
	local profile = PlayerData.load(player)
	if not profile then
		return
	end
	player:LoadCharacter()
	Quests.enter(player, true)
	if profile.stage == 1 then
		Remotes.dialog(player, {
			{ "", "Welcome to " .. Config.Title .. "." },
			{ "", "Two and a half thousand years ago, Prince Siddhartha left his palace to find an end to suffering. He found it beneath the Bodhi tree, and became the Buddha." },
			{ "", "You are a seeker walking that same road. Mara, lord of all that binds the heart, will try to turn you back." },
			{ "", "Your goal is on the right of the screen. Begin by speaking with the Venerable Abbot, in front of the great temple behind you." },
		}, Config.Title)
	else
		local quest = Story.Quests[profile.stage]
		Remotes.notify(player, "Welcome back. " .. quest.title, "quest")
	end
end

Players.PlayerAdded:Connect(function(player)
	local ok, err = pcall(onPlayer, player)
	if not ok then
		warn("[Bodhi Path] player setup failed: " .. tostring(err))
	end
end)
Players.PlayerRemoving:Connect(function(player)
	PlayerData.release(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		local ok, err = pcall(onPlayer, player)
		if not ok then
			warn("[Bodhi Path] player setup failed: " .. tostring(err))
		end
	end)
end

print("[Bodhi Path] Ready.")
