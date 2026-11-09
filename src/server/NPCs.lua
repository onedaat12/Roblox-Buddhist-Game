-- NPCs: the people of the story. They stand (or sit) where the story needs them,
-- speak when spoken to, give alms, and keep the shops. A few simply wander so the
-- villages feel alive.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Story = require(Shared:WaitForChild("Story"))
local Remotes = require(script.Parent.Remotes)
local PlayerData = require(script.Parent.PlayerData)
local Quests = require(script.Parent.Quests)
local Rig = require(script.Parent.Rig)
local Kit = require(script.Parent.Kit)

local NPCs = {}

-- People who sit on the ground rather than stand.
local SITTING = {
	sick_man = true, ascetic = true, alara = true, alara_student = true, uddaka = true,
	bhaddiya = true, vappa = true, mahanama = true, assaji = true,
}

local ALMS_WAIT = 600 -- seconds before the same villager gives again

local people = {}
local wanderers = {}
local rng = Random.new()

local function talk(player, npc)
	local def = npc.def
	local profile = PlayerData.get(player)
	local session = PlayerData.session(player)
	if not profile or not session then
		return
	end

	-- part of the current step of the journey?
	local obj = Quests.active(player, "talk", def.id)
	if obj then
		Remotes.dialog(player, obj.lines, def.name)
		Quests.progress(player, "talk", def.id)
		return
	end

	-- alms
	if def.alms and (profile.inv.alms_bowl or 0) > 0 then
		session.alms = session.alms or {}
		local now = os.clock()
		if now >= (session.alms[def.id] or 0) then
			session.alms[def.id] = now + ALMS_WAIT
			PlayerData.give(player, "rice", 1)
			Remotes.dialog(player, {
				{ def.name, def.lines[1] },
				{ "", def.name .. " places a ladle of rice in your bowl. (Alms Rice added to your Bag.)" },
			}, def.name)
			if not Quests.progress(player, "alms", "alms") then
				PlayerData.push(player)
			end
			return
		end
	end

	if def.shop then
		Remotes.UI:FireClient(player, "shop", def.shop)
		return
	end
	if def.robes then
		Remotes.UI:FireClient(player, "robes")
		return
	end

	local line = def.lines[rng:NextInteger(1, #def.lines)]
	Remotes.dialog(player, { { def.name, line } }, def.name)
end

local function makePerson(def, folder)
	local model, hum = Rig.make(def.name, def.look)
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	hum.NameDisplayDistance = 70
	hum.WalkSpeed = 7
	local yaw = 0
	if def.face then
		yaw = Kit.yawToward(def.x, def.z, def.face.x, def.face.z)
	end
	local home = Kit.at(def.x, def.z, yaw, def.y or 0)
	Rig.place(model, home, folder)
	local tracks = Rig.animate(model, false)
	local root = model:FindFirstChild("HumanoidRootPart")
	local npc = { def = def, model = model, hum = hum, root = root, home = home, tracks = tracks }
	return npc
end

function NPCs.start()
	local folder = Kit.folder(workspace, "People")

	for _, def in ipairs(Story.NPCs) do
		local ok, result = pcall(makePerson, def, folder)
		if ok then
			local npc = result
			local action = "Talk"
			if def.shop then
				action = "Trade"
			elseif def.robes then
				action = "Robes"
			end
			local prompt = Kit.prompt(npc.root, action, def.name, 11)
			prompt.Triggered:Connect(function(player)
				talk(player, npc)
			end)
			if SITTING[def.id] then
				npc.sitting = true
				task.delay(2, function()
					if npc.hum.Parent then
						npc.hum.Sit = true
						if npc.tracks then
							npc.tracks.idle:Stop(0.2)
							npc.tracks.sit:Play(0.2)
						end
					end
				end)
			end
			table.insert(people, npc)
		else
			warn("[Bodhi Path] Could not create " .. def.name .. ":", result)
		end
	end

	for _, def in ipairs(Story.Wanderers) do
		local ok, result = pcall(makePerson, def, folder)
		if ok then
			result.nextMove = 0
			table.insert(wanderers, result)
		end
	end

	-- keep people where they belong, and let the wanderers wander
	task.spawn(function()
		while true do
			task.wait(2.5)
			local now = os.clock()
			for _, npc in ipairs(people) do
				if npc.root.Parent then
					local away = (npc.root.Position - npc.home.Position)
					local flat = Vector3.new(away.X, 0, away.Z).Magnitude
					if npc.root.Position.Y < -30 or flat > 30 then
						npc.model:PivotTo(npc.home * CFrame.new(0, 4, 0))
					elseif flat > 4 and not npc.sitting then
						npc.hum:MoveTo(npc.home.Position)
					end
				end
			end
			for _, npc in ipairs(wanderers) do
				if npc.root.Parent then
					if npc.root.Position.Y < -30 then
						npc.model:PivotTo(npc.home * CFrame.new(0, 4, 0))
					elseif now >= npc.nextMove then
						npc.nextMove = now + rng:NextNumber(5, 11)
						local a = rng:NextNumber(0, math.pi * 2)
						local r = rng:NextNumber(4, npc.def.radius or 20)
						local dest = npc.home.Position + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
						-- stay off the far side of the road only if it keeps them near home
						npc.hum:MoveTo(dest)
					end
				end
			end
		end
	end)
end

return NPCs
