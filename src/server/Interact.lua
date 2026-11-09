-- Interact: everything a player can use in the world or choose in a window.
-- The temple bell, prayer wheels, shrines, things to pick up, the shops, robes,
-- the Eightfold Path, and using items from the Bag.

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
local Robes = require(script.Parent.Robes)
local Kit = require(script.Parent.Kit)

local Interact = {}

local function livelihood(player, amount)
	if PlayerData.hasPath(player, "livelihood") then
		return amount * 2
	end
	return amount
end

local function nearShrine(player, distance)
	local pos = Combat.position(player)
	if not pos then
		return nil
	end
	for _, s in ipairs(Config.Shrines) do
		local dx, dz = pos.X - s.x, pos.Z - s.z
		if dx * dx + dz * dz <= distance * distance then
			return s
		end
	end
	return nil
end

local function leafCount(profile)
	local n = 0
	for _ in pairs(profile.leaves) do
		n = n + 1
	end
	return n
end

----------------------------------------------------------------------
-- World objects
----------------------------------------------------------------------
local function setupBell(objects)
	if not objects.bell then
		return
	end
	local prompt = Kit.prompt(objects.bell, "Ring", "Temple Bell", 14)
	local swinging = false
	prompt.Triggered:Connect(function(player)
		local session = PlayerData.session(player)
		if not session then
			return
		end
		if not swinging and objects.striker then
			swinging = true
			local home = objects.striker.CFrame
			local tween = TweenService:Create(objects.striker, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { CFrame = home * CFrame.new(-2.2, 0, 0) })
			tween:Play()
			task.delay(0.3, function()
				TweenService:Create(objects.striker, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = home }):Play()
				task.wait(0.7)
				swinging = false
			end)
		end
		Remotes.fx("bell", { pos = objects.bell.Position })
		Remotes.fx("ring", { pos = objects.bell.Position - Vector3.new(0, 5, 0), radius = 26, color = Color3.fromRGB(255, 220, 130), time = 1.4 })
		if not Quests.progress(player, "interact", "temple_bell") then
			local now = os.clock()
			if now >= (session.bellAt or 0) then
				session.bellAt = now + 60
				PlayerData.addMerit(player, livelihood(player, 2))
			end
		end
	end)
end

local function setupWheels(objects)
	for index, core in ipairs(objects.wheels) do
		local prompt = Kit.prompt(core, "Spin", "Prayer Wheel", 9)
		local spinning = false
		prompt.Triggered:Connect(function(player)
			local session = PlayerData.session(player)
			if not session then
				return
			end
			if not spinning then
				spinning = true
				task.spawn(function()
					for _ = 1, 6 do
						local tween = TweenService:Create(core, TweenInfo.new(0.22, Enum.EasingStyle.Linear), { CFrame = core.CFrame * CFrame.Angles(math.rad(-120), 0, 0) })
						tween:Play()
						task.wait(0.22)
					end
					spinning = false
				end)
			end
			Remotes.fx("wheel", { pos = core.Position })
			local now = os.clock()
			if now >= (session.wheels[index] or 0) then
				session.wheels[index] = now + 45
				PlayerData.addMerit(player, livelihood(player, 1))
			end
		end)
	end
end

local function setupShrines(objects)
	for _, s in ipairs(Config.Shrines) do
		local part = objects.shrines[s.id]
		if part then
			local prompt = Kit.prompt(part, "Pray", s.name, 14)
			prompt.Triggered:Connect(function(player)
				local profile = PlayerData.get(player)
				if not profile then
					return
				end
				local first = not profile.shrines[s.id]
				profile.shrines[s.id] = true
				profile.checkpoint = s.id
				player:SetAttribute("Calm", PlayerData.maxCalm(player))
				if first then
					Remotes.notify(player, "Shrine found: " .. s.name .. ". You will return here if you are overwhelmed.", "good")
					PlayerData.addMerit(player, 5)
				end
				local today = math.floor(os.time() / 86400)
				if profile.lastDaily ~= today then
					profile.lastDaily = today
					PlayerData.addMerit(player, 40)
					Remotes.notify(player, "Daily devotion: your first prayer of the day.", "good")
				end
				PlayerData.push(player)
				Remotes.UI:FireClient(player, "shrine", s.id)
			end)
		end
	end
end

local function setupStoryPlaces(objects)
	if objects.hair_rock then
		local prompt = Kit.prompt(objects.hair_rock, "Leave your old life", "The Flat Rock", 14, 0.8)
		prompt.Triggered:Connect(function(player)
			if not Quests.progress(player, "interact", "hair_rock") then
				Remotes.dialog(player, { { "", "Silk, a crown, and a sword lie on the rock where the prince left them. He never came back for them." } })
			end
		end)
	end

	if objects.bowl_river then
		local prompt = Kit.prompt(objects.bowl_river, "Set the bowl on the water", "The Neranjara", 14, 0.8)
		local busy = false
		prompt.Triggered:Connect(function(player)
			if not Quests.active(player, "interact", "bowl_river") then
				Remotes.dialog(player, { { "", "The river slides by. Somewhere beneath it, the old stories say, a golden bowl rests in the palace of the naga king." } })
				return
			end
			PlayerData.take(player, "golden_bowl", 1)
			if not busy then
				busy = true
				local start = objects.bowl_river.Position
				local bowl = Kit.blob(workspace, CFrame.new(start.X + 8, -1.7, start.Z), Vector3.new(2.6, 1.2, 2.6), Kit.C.goldBright, Enum.Material.Metal, { collide = false })
				Kit.sparkle(bowl, Kit.C.goldBright, 14)
				local tween = TweenService:Create(bowl, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { CFrame = CFrame.new(start.X + 26, -1.7, start.Z - 110) })
				tween:Play()
				task.delay(6, function()
					TweenService:Create(bowl, TweenInfo.new(2), { CFrame = CFrame.new(start.X + 26, -9, start.Z - 118) }):Play()
					task.wait(2.2)
					bowl:Destroy()
					busy = false
				end)
			end
			Quests.progress(player, "interact", "bowl_river")
		end)
	end

	if objects.seat then
		local prompt = Kit.prompt(objects.seat, "Spread the kusa grass", "The Diamond Seat", 14, 1)
		prompt.Triggered:Connect(function(player)
			if Quests.active(player, "interact", "vajrasana") then
				if PlayerData.count(player, "kusa") < 8 then
					Remotes.notify(player, "You need eight handfuls of kusa grass.", "warn")
					return
				end
				PlayerData.take(player, "kusa", 8)
				Quests.progress(player, "interact", "vajrasana")
			elseif Quests.reached(player, "watch1") then
				Remotes.dialog(player, { { "", "The Vajrasana, the Diamond Seat. Sit here and meditate (M)." } })
			else
				Remotes.dialog(player, { { "", "A slab of polished stone at the foot of the great tree. It seems to be waiting for someone." } })
			end
		end)
	end
end

local function setupCollectibles(objects)
	for _, item in ipairs(objects.collectibles) do
		item.prompt.Triggered:Connect(function(player)
			local profile = PlayerData.get(player)
			local session = PlayerData.session(player)
			if not profile or not session then
				return
			end
			Remotes.fxTo(player, "pickup", {})
			if item.kind == "leaf" then
				local index = tonumber(string.sub(item.id, 6)) or 1
				local teaching = Story.Teachings[index] or Story.Teachings[1]
				local lines = { { "A Bodhi Leaf", teaching.text }, { "", "(" .. teaching.source .. ", paraphrased)" } }
				if not profile.leaves[item.id] then
					profile.leaves[item.id] = true
					PlayerData.addMerit(player, 10)
					local n = leafCount(profile)
					Remotes.notify(player, "Bodhi leaves found: " .. n .. " of " .. #Config.Leaves, "good")
					if n >= #Config.Leaves and not profile.robes.pilgrim then
						profile.robes.pilgrim = true
						Remotes.notify(player, "You have found every leaf. The Pilgrim's Robe is yours.", "good")
					end
					PlayerData.push(player)
				end
				Remotes.dialog(player, lines, "A Bodhi Leaf")
			elseif item.kind == "kusa" then
				if profile.collected[item.id] then
					Remotes.notify(player, "You have already gathered this grass.", "info")
				elseif Quests.active(player, "collect", "kusa") then
					profile.collected[item.id] = true
					PlayerData.give(player, "kusa", 1)
					Quests.progress(player, "collect", "kusa")
					PlayerData.push(player)
				else
					Remotes.notify(player, "Kusa grass. Sotthiya the grass-cutter tends this bank; speak with him first.", "info")
				end
			elseif item.kind == "lotus" then
				if session.lotus[item.id] then
					Remotes.notify(player, "You have already picked this lotus today.", "info")
				else
					session.lotus[item.id] = true
					PlayerData.give(player, "lotus", 1)
					Remotes.notify(player, "You picked a lotus. Offer it at any shrine.", "good")
					PlayerData.push(player)
				end
			end
		end)
	end
end

----------------------------------------------------------------------
-- Choices made in windows
----------------------------------------------------------------------
local Actions = {}

function Actions.UseItem(player, itemId)
	local def = Config.Items[itemId]
	local session = PlayerData.session(player)
	if type(itemId) ~= "string" or not def or not session or PlayerData.count(player, itemId) < 1 then
		return
	end
	local now = os.clock()
	if def.use == "heal" then
		local max = player:GetAttribute("MaxCalm") or 100
		if (player:GetAttribute("Calm") or max) >= max then
			Remotes.notify(player, "Your Calm is already full.", "info")
			return
		end
		PlayerData.take(player, itemId, 1)
		Combat.heal(player, def.amount)
	elseif def.use == "speed" then
		PlayerData.take(player, itemId, 1)
		session.speedUntil = now + def.duration
		Combat.refreshSpeed(player)
		Remotes.notify(player, "The tea warms you. You walk faster for a while.", "good")
	elseif def.use == "regen" then
		PlayerData.take(player, itemId, 1)
		session.regenUntil = now + def.duration
		Remotes.notify(player, "The incense steadies your breath.", "good")
	elseif def.use == "offer" then
		if not nearShrine(player, 30) then
			Remotes.notify(player, "Carry this to a shrine to offer it.", "info")
			return
		end
		PlayerData.take(player, itemId, 1)
		PlayerData.addMerit(player, livelihood(player, def.merit))
		if itemId == "lamp" then
			session.shieldUntil = now + 180
			Remotes.notify(player, "The lamp is lit. You are protected for a while.", "good")
		end
	elseif def.use == "quest" then
		if not Quests.active(player, "use", itemId) then
			Remotes.notify(player, "Not yet.", "info")
			return
		end
		PlayerData.take(player, itemId, 1)
		player:SetAttribute("Calm", PlayerData.maxCalm(player))
		Quests.progress(player, "use", itemId)
	else
		return
	end
	PlayerData.push(player)
end

local function priceFor(player, price)
	if PlayerData.hasPath(player, "speech") then
		return math.floor(price * 0.85 + 0.5)
	end
	return price
end

function Actions.Buy(player, shopId, itemId)
	local shop = type(shopId) == "string" and Config.Shops[shopId] or nil
	local profile = PlayerData.get(player)
	if not shop or not profile then
		return
	end
	for _, entry in ipairs(shop.stock) do
		if entry.item == itemId then
			local def = Config.Items[itemId]
			if entry.once and (profile.bought[itemId] or (profile.inv[itemId] or 0) > 0) then
				Remotes.notify(player, "You already have this.", "info")
				return
			end
			local price = priceFor(player, entry.price)
			if not PlayerData.spend(player, price) then
				Remotes.notify(player, "Not enough merit. Kind acts, prayer and the journey itself all earn merit.", "warn")
				return
			end
			if entry.once then
				profile.bought[itemId] = true
			end
			PlayerData.give(player, itemId, 1)
			Remotes.fxTo(player, "buy", {})
			Remotes.notify(player, "Received: " .. def.name, "good")
			if itemId == "prayer_flags" then
				task.spawn(Robes.apply, player)
			end
			PlayerData.push(player)
			return
		end
	end
end

function Actions.BuyRobe(player, robeId)
	local profile = PlayerData.get(player)
	local def = type(robeId) == "string" and Robes.def(robeId) or nil
	if not profile or not def or profile.robes[robeId] then
		return
	end
	if def.quest or def.reward or not def.price then
		Remotes.notify(player, "This robe cannot be bought. It is earned on the journey.", "info")
		return
	end
	if not PlayerData.spend(player, priceFor(player, def.price)) then
		Remotes.notify(player, "Not enough merit for this robe yet.", "warn")
		return
	end
	profile.robes[robeId] = true
	profile.robe = robeId
	Remotes.fxTo(player, "buy", {})
	Remotes.notify(player, "You now wear the " .. def.name .. ".", "good")
	PlayerData.push(player)
	Robes.apply(player)
end

function Actions.WearRobe(player, robeId)
	local profile = PlayerData.get(player)
	if not profile or type(robeId) ~= "string" or not profile.robes[robeId] or not Robes.def(robeId) then
		return
	end
	profile.robe = robeId
	PlayerData.push(player)
	Robes.apply(player)
end

function Actions.BuyPath(player)
	local profile = PlayerData.get(player)
	if not profile then
		return
	end
	local step = Config.Path[profile.path + 1]
	if not step then
		return
	end
	if not nearShrine(player, 34) then
		Remotes.notify(player, "The Eightfold Path is practised at a shrine. Pray at one first.", "info")
		return
	end
	if not PlayerData.spend(player, step.cost) then
		Remotes.notify(player, "Not enough merit for " .. step.name .. " yet.", "warn")
		return
	end
	profile.path = profile.path + 1
	PlayerData.refreshCalm(player)
	Combat.refreshSpeed(player)
	Remotes.notify(player, step.name .. " (" .. step.pali .. ") is now part of your practice.", "good")
	if profile.path >= #Config.Path then
		Remotes.notify(player, "You have completed the Noble Eightfold Path.", "good")
	end
	PlayerData.push(player)
end

function Actions.Travel(player, shrineId)
	local profile = PlayerData.get(player)
	if not profile or type(shrineId) ~= "string" or not profile.shrines[shrineId] then
		return
	end
	if not nearShrine(player, 34) then
		Remotes.notify(player, "You can travel between shrines only while standing at one.", "info")
		return
	end
	Combat.setMeditating(player, false)
	profile.checkpoint = shrineId
	Remotes.fxTo(player, "fade", {})
	task.delay(0.35, function()
		if player.Parent then
			Combat.toShrine(player, shrineId)
		end
	end)
end

function Interact.action(player, kind, a, b)
	local fn = Actions[kind]
	if fn then
		fn(player, a, b)
		return true
	end
	return false
end

----------------------------------------------------------------------
-- Gates and "arrive here" objectives
----------------------------------------------------------------------
local function watchPlayers()
	local warned = {}
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local root = Combat.root(player)
			local profile = PlayerData.get(player)
			if root and profile then
				local pos = root.Position
				for _, gate in ipairs(Config.Gates) do
					local need = Story.QuestIndex[gate.quest]
					if pos.X > gate.x + 3 and profile.stage < need then
						player.Character:PivotTo(CFrame.new(gate.x - 16, 4.5, math.clamp(pos.Z, -8, 8)))
						if os.clock() >= (warned[player] or 0) then
							warned[player] = os.clock() + 4
							Remotes.notify(player, gate.hint, "warn")
						end
						break
					end
				end
				local quest = Story.Quests[profile.stage]
				for _, obj in ipairs(quest.objectives) do
					if obj.kind == "reach" then
						local area = Config.Areas[obj.target]
						if area then
							local dx, dz = pos.X - area.x, pos.Z - area.z
							if dx * dx + dz * dz <= area.radius * area.radius then
								Quests.progress(player, "reach", obj.target)
								break
							end
						end
					end
				end
			end
		end
	end
end

function Interact.start(objects)
	setupBell(objects)
	setupWheels(objects)
	setupShrines(objects)
	setupStoryPlaces(objects)
	setupCollectibles(objects)
	task.spawn(watchPlayers)
end

return Interact
