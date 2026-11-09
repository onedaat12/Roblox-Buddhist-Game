-- Quests: moves each player through the steps of the journey (see Story.Quests).
-- Other modules report what happened ("talked to the abbot", "dispelled a shadow")
-- and this module works out whether the current step is now complete.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))
local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)

local Quests = {}

local completeHooks = {}
local rewardHooks = {}

-- Other modules can ask to be told when a step is finished, or a reward is given.
function Quests.onComplete(fn)
	table.insert(completeHooks, fn)
end
function Quests.onReward(fn)
	table.insert(rewardHooks, fn)
end

function Quests.current(player)
	local profile = PlayerData.get(player)
	if not profile then
		return nil, 0
	end
	return Story.Quests[profile.stage], profile.stage
end

function Quests.stage(player)
	local profile = PlayerData.get(player)
	return profile and profile.stage or 0
end

-- Has the player reached (or passed) the named step?
function Quests.reached(player, questId)
	local profile = PlayerData.get(player)
	local index = Story.QuestIndex[questId]
	return profile ~= nil and index ~= nil and profile.stage >= index
end

-- Is there an unfinished objective of this kind and target in the current step?
function Quests.active(player, kind, target)
	local profile = PlayerData.get(player)
	if not profile then
		return nil
	end
	local quest = Story.Quests[profile.stage]
	for i, obj in ipairs(quest.objectives) do
		if obj.kind == kind and obj.target == target then
			local have = profile.prog[tostring(i)] or 0
			if have < (obj.count or 1) then
				return obj, i
			end
		end
	end
	return nil
end

local function giveReward(player, reward)
	if not reward then
		return
	end
	local profile = PlayerData.get(player)
	if reward.merit then
		PlayerData.addMerit(player, reward.merit, true)
	end
	if reward.items then
		for item, amount in pairs(reward.items) do
			PlayerData.give(player, item, amount)
			Remotes.notify(player, "Received: " .. Config.Items[item].name, "good")
		end
	end
	if reward.ability then
		profile.abilities[reward.ability] = true
		local def = Config.Abilities[reward.ability]
		if def then
			Remotes.notify(player, "New ability: " .. def.name .. " (" .. def.key .. ")", "good")
		elseif reward.ability == "staff" then
			Remotes.notify(player, "You now carry a walking staff. Your Strike reaches further and hits harder.", "good")
		end
	end
	if reward.robe then
		profile.robes[reward.robe] = true
	end
	if reward.maxCalm then
		profile.bonusCalm = profile.bonusCalm + reward.maxCalm
		PlayerData.refreshCalm(player)
		player:SetAttribute("Calm", PlayerData.maxCalm(player))
		Remotes.notify(player, "Your Calm has deepened (+" .. reward.maxCalm .. ").", "good")
	end
	for _, fn in ipairs(rewardHooks) do
		task.spawn(fn, player, reward)
	end
end

-- Called when a player arrives at a new step.
function Quests.enter(player, quiet)
	local profile = PlayerData.get(player)
	if not profile then
		return
	end
	local quest = Story.Quests[profile.stage]
	if quest.grant and not profile.collected["grant_" .. quest.id] then
		profile.collected["grant_" .. quest.id] = true
		giveReward(player, quest.grant)
	end
	if not quiet then
		Remotes.notify(player, quest.title, "quest")
	end
	PlayerData.push(player)
end

local function complete(player)
	local profile = PlayerData.get(player)
	local quest = Story.Quests[profile.stage]
	if quest.final then
		return
	end
	giveReward(player, quest.reward)
	if quest.outro then
		Remotes.dialog(player, quest.outro, quest.title)
	end
	profile.stage = math.min(#Story.Quests, profile.stage + 1)
	profile.prog = {}
	for _, fn in ipairs(completeHooks) do
		task.spawn(fn, player, quest)
	end
	Quests.enter(player)
	task.spawn(PlayerData.save, player)
end

-- Report that something happened. Returns true if it counted toward the current step.
function Quests.progress(player, kind, target, amount)
	local profile = PlayerData.get(player)
	if not profile then
		return false
	end
	local quest = Story.Quests[profile.stage]
	local changed = false
	for i, obj in ipairs(quest.objectives) do
		if obj.kind == kind and obj.target == target then
			local need = obj.count or 1
			local key = tostring(i)
			local have = profile.prog[key] or 0
			if have < need then
				have = math.min(need, have + (amount or 1))
				profile.prog[key] = have
				changed = true
			end
		end
	end
	if not changed then
		return false
	end
	local done = true
	for i, obj in ipairs(quest.objectives) do
		if (profile.prog[tostring(i)] or 0) < (obj.count or 1) then
			done = false
		end
	end
	if done then
		complete(player)
	else
		PlayerData.push(player)
	end
	return true
end

return Quests
