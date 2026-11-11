-- Robux: the few things that can be bought with Robux. They change only how things
-- look, or are a gift to everyone in the game. Nothing here makes the journey easier.
--
-- The ID numbers live in Config.Robux. While an ID is 0 that item is "coming soon"
-- and cannot be bought.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Combat = require(script.Parent.Combat)
local Cosmetics = require(script.Parent.Cosmetics)

local Robux = {}

local function passById(id)
	for _, def in ipairs(Config.Robux.passes) do
		if def.id == id then
			return def
		end
	end
	return nil
end

local function productById(id)
	for _, def in ipairs(Config.Robux.products) do
		if def.id == id then
			return def
		end
	end
	return nil
end

-- Hand over what a pass includes. Safe to call more than once.
function Robux.grantPass(player, id, quiet)
	local def = passById(id)
	local profile = PlayerData.get(player)
	if not def or not profile then
		return false
	end
	local new = not profile.bought["pass_" .. id]
	profile.bought["pass_" .. id] = true
	if def.robe then
		profile.robes[def.robe] = true
	end
	for _, itemId in ipairs(def.items or {}) do
		if (profile.inv[itemId] or 0) < 1 then
			PlayerData.give(player, itemId, 1)
		end
	end
	if new and not quiet then
		Remotes.notify(player, "Thank you. " .. def.name .. " is yours: look in your Bag and at the robe-maker's.", "good")
	end
	PlayerData.push(player)
	return true
end

-- When a player arrives, see which passes they already own.
function Robux.check(player)
	for _, def in ipairs(Config.Robux.passes) do
		if def.passId > 0 then
			local ok, owns = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, def.passId)
			end)
			if ok and owns and player.Parent then
				Robux.grantPass(player, def.id, true)
			end
		end
	end
end

function Robux.buyPass(player, id)
	local def = passById(id)
	local profile = PlayerData.get(player)
	if not def or not profile then
		return
	end
	if profile.bought["pass_" .. id] then
		Remotes.notify(player, "You already have this.", "info")
	elseif def.passId <= 0 then
		Remotes.notify(player, def.name .. " is not available yet.", "info")
	else
		MarketplaceService:PromptGamePassPurchase(player, def.passId)
	end
end

function Robux.buyProduct(player, id)
	local def = productById(id)
	if not def then
		return
	end
	if def.productId <= 0 then
		Remotes.notify(player, def.name .. " is not available yet.", "info")
	else
		MarketplaceService:PromptProductPurchase(player, def.productId)
	end
end

-- An offering of flowers: petals fall around every player in the game.
function Robux.flowers(player)
	Remotes.notifyAll(player.DisplayName .. " has made an offering of flowers for everyone.", "good")
	task.spawn(function()
		local rng = Random.new()
		for _ = 1, 10 do
			for _, other in ipairs(Players:GetPlayers()) do
				local pos = Combat.position(other)
				if pos then
					local at = pos + Vector3.new(rng:NextNumber(-14, 14), rng:NextNumber(8, 14), rng:NextNumber(-14, 14))
					Remotes.fx("petals", { pos = at, color = Color3.fromRGB(255, 200, 220), big = true })
				end
			end
			task.wait(0.6)
		end
	end)
end

function Robux.start()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, bought)
		if not bought then
			return
		end
		for _, def in ipairs(Config.Robux.passes) do
			if def.passId == passId and def.passId > 0 then
				Robux.grantPass(player, def.id)
				if def.robe then
					local profile = PlayerData.get(player)
					if profile then
						profile.robe = def.robe
						PlayerData.push(player)
						task.spawn(require(script.Parent.Robes).apply, player)
					end
				end
				Cosmetics.apply(player)
			end
		end
	end)

	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		for _, def in ipairs(Config.Robux.products) do
			if def.productId == receipt.ProductId and def.productId > 0 then
				if def.id == "flowers" then
					Robux.flowers(player)
				end
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

return Robux
