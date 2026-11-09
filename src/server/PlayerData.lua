-- PlayerData: each player's saved progress (merit, bag, robes, how far they have walked)
-- plus short-lived things that last only for one visit (cooldowns, blessings).

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))
local Remotes = require(script.Parent.Remotes)

local PlayerData = {}

local profiles = {}
local sessions = {}
local store = nil
local storeWarned = false

do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DataStoreName)
	end)
	if ok then
		store = result
	end
end

local function defaults()
	return {
		v = 1,
		merit = 0,
		stage = 1,
		prog = {},
		inv = {},
		abilities = { strike = true, meditate = true },
		robes = { own = true, novice = true },
		robe = "novice",
		path = 0,
		leaves = {},
		collected = {},
		shrines = { village = true },
		checkpoint = "village",
		bonusCalm = 0,
		awakened = false,
		lastDaily = 0,
		dispelled = 0,
		bought = {},
		bossWins = 0,
	}
end

local function sanitize(data)
	local base = defaults()
	if type(data) ~= "table" then
		return base
	end
	for key, value in pairs(base) do
		if data[key] == nil or type(data[key]) ~= type(value) then
			data[key] = value
		end
	end
	if data.stage < 1 then
		data.stage = 1
	end
	if data.stage > #Story.Quests then
		data.stage = #Story.Quests
	end
	data.abilities.strike = true
	data.abilities.meditate = true
	data.robes.own = true
	data.robes.novice = true
	return data
end

local function warnStore(err)
	if not storeWarned then
		storeWarned = true
		warn("[Bodhi Path] Saving is not available right now, so progress will last only for this visit. (" .. tostring(err) .. ")")
	end
end

----------------------------------------------------------------------
-- Loading and saving
----------------------------------------------------------------------
function PlayerData.load(player)
	local profile = nil
	local canSave = false
	if store then
		local key = "p_" .. player.UserId
		for attempt = 1, 3 do
			local ok, result = pcall(function()
				return store:GetAsync(key)
			end)
			if ok then
				profile = sanitize(result)
				canSave = true
				break
			end
			warnStore(result)
			if attempt < 3 then
				task.wait(1.5)
			end
		end
	end
	if not profile then
		profile = defaults()
	end
	if not player.Parent then
		return nil
	end
	profiles[player] = profile
	sessions[player] = {
		canSave = canSave,
		cooldowns = {},
		lastHurt = 0,
		speedUntil = 0,
		regenUntil = 0,
		shieldUntil = 0,
		slowUntil = 0,
		graceUntil = 0,
		meditating = false,
		lotus = {},
		wheels = {},
		tagged = {},
	}

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local merit = Instance.new("IntValue")
	merit.Name = "Merit"
	merit.Value = profile.merit
	merit.Parent = stats
	local journey = Instance.new("IntValue")
	journey.Name = "Journey"
	journey.Value = math.floor((profile.stage - 1) / (#Story.Quests - 1) * 100)
	journey.Parent = stats
	stats.Parent = player

	player:SetAttribute("MaxCalm", PlayerData.maxCalm(player))
	player:SetAttribute("Calm", PlayerData.maxCalm(player))
	player:SetAttribute("Merit", profile.merit)
	player:SetAttribute("Stage", profile.stage)
	player:SetAttribute("Meditating", false)
	player:SetAttribute("Awakened", profile.awakened)
	return profile
end

function PlayerData.save(player)
	local profile = profiles[player]
	local session = sessions[player]
	if not profile or not session or not session.canSave or not store then
		return
	end
	local ok, err = pcall(function()
		store:SetAsync("p_" .. player.UserId, profile)
	end)
	if not ok then
		warnStore(err)
	end
end

function PlayerData.release(player)
	PlayerData.save(player)
	profiles[player] = nil
	sessions[player] = nil
end

function PlayerData.get(player)
	return profiles[player]
end

function PlayerData.session(player)
	return sessions[player]
end

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
function PlayerData.hasPath(player, id)
	local profile = profiles[player]
	if not profile then
		return false
	end
	for i, step in ipairs(Config.Path) do
		if step.id == id then
			return profile.path >= i
		end
	end
	return false
end

function PlayerData.count(player, item)
	local profile = profiles[player]
	return profile and profile.inv[item] or 0
end

function PlayerData.give(player, item, amount)
	local profile = profiles[player]
	if not profile then
		return
	end
	profile.inv[item] = (profile.inv[item] or 0) + (amount or 1)
	local def = Config.Items[item]
	if def and def.unlock then
		profile.abilities[def.unlock] = true
	end
end

function PlayerData.take(player, item, amount)
	local profile = profiles[player]
	if not profile then
		return false
	end
	local have = profile.inv[item] or 0
	amount = amount or 1
	if have < amount then
		return false
	end
	have = have - amount
	if have <= 0 then
		profile.inv[item] = nil
	else
		profile.inv[item] = have
	end
	return true
end

function PlayerData.maxCalm(player)
	local profile = profiles[player]
	local value = Config.Player.BaseCalm
	if profile then
		value = value + profile.bonusCalm
		if PlayerData.hasPath(player, "mindfulness") then
			value = value + 40
		end
	end
	return value
end

function PlayerData.refreshCalm(player)
	local max = PlayerData.maxCalm(player)
	player:SetAttribute("MaxCalm", max)
	local calm = player:GetAttribute("Calm") or max
	if calm > max then
		player:SetAttribute("Calm", max)
	end
end

-- Add merit. Returns how much was actually given. "plain" skips the bonuses.
function PlayerData.addMerit(player, amount, plain)
	local profile = profiles[player]
	if not profile or amount == 0 then
		return 0
	end
	if amount > 0 and not plain then
		local mult = 1
		if PlayerData.hasPath(player, "view") then
			mult = mult + 0.2
		end
		if (profile.inv.wheel_charm or 0) > 0 then
			mult = mult + 0.1
		end
		amount = math.floor(amount * mult + 0.5)
	end
	profile.merit = math.max(0, profile.merit + amount)
	player:SetAttribute("Merit", profile.merit)
	local stats = player:FindFirstChild("leaderstats")
	if stats and stats:FindFirstChild("Merit") then
		stats.Merit.Value = profile.merit
	end
	if amount > 0 then
		Remotes.notify(player, "+" .. amount .. " merit", "merit")
	end
	return amount
end

function PlayerData.spend(player, amount)
	local profile = profiles[player]
	if not profile or profile.merit < amount then
		return false
	end
	PlayerData.addMerit(player, -amount, true)
	return true
end

-- Send the player's screen everything it needs to draw the HUD and windows.
function PlayerData.push(player)
	local profile = profiles[player]
	if not profile then
		return
	end
	player:SetAttribute("Stage", profile.stage)
	local stats = player:FindFirstChild("leaderstats")
	if stats and stats:FindFirstChild("Journey") then
		stats.Journey.Value = math.floor((profile.stage - 1) / (#Story.Quests - 1) * 100)
	end
	Remotes.State:FireClient(player, {
		merit = profile.merit,
		stage = profile.stage,
		prog = profile.prog,
		inv = profile.inv,
		abilities = profile.abilities,
		robes = profile.robes,
		robe = profile.robe,
		path = profile.path,
		leaves = profile.leaves,
		collected = profile.collected,
		shrines = profile.shrines,
		checkpoint = profile.checkpoint,
		awakened = profile.awakened,
		bought = profile.bought,
		lotus = sessions[player] and sessions[player].lotus or {},
	})
end

function PlayerData.all()
	return profiles
end

-- Autosave, and save everyone when the server shuts down.
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerData.save(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		PlayerData.save(player)
	end
end)

return PlayerData
