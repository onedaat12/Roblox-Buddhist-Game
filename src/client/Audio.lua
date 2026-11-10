-- Audio: plays the music for the current step of the journey and the sound effects.
-- The sound IDs themselves live in ReplicatedStorage.Shared.Sounds.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Sounds = require(Shared:WaitForChild("Sounds"))
local Story = require(Shared:WaitForChild("Story"))
local Config = require(Shared:WaitForChild("Config"))

local Audio = {}

local player = Players.LocalPlayer
local folder = Instance.new("Folder")
folder.Name = "BodhiPathAudio"
folder.Parent = SoundService

local function asset(id)
	return "rbxassetid://" .. tostring(id)
end

----------------------------------------------------------------------
-- Music
----------------------------------------------------------------------
local current = nil
local currentId = 0

-- The track for a step; if that step has none, the nearest earlier step that has one.
local function musicFor(stage)
	local quest = Story.Quests[stage]
	if not quest then
		return 0
	end
	local index = 0
	for i, entry in ipairs(Sounds.Music) do
		if entry.step == quest.id then
			index = i
		end
	end
	for i = index, 1, -1 do
		local id = Sounds.Music[i].id
		if type(id) == "number" and id > 0 then
			return id
		end
	end
	return 0
end

function Audio.setStage(stage)
	local id = musicFor(stage)
	if id == currentId then
		return
	end
	currentId = id
	local old = current
	current = nil
	if old then
		local t = TweenService:Create(old, TweenInfo.new(2), { Volume = 0 })
		t:Play()
		task.delay(2.2, function()
			old:Destroy()
		end)
	end
	if id > 0 then
		local s = Instance.new("Sound")
		s.Name = "Music"
		s.SoundId = asset(id)
		s.Looped = true
		s.Volume = 0
		s.Parent = folder
		s:Play()
		TweenService:Create(s, TweenInfo.new(2.5), { Volume = Sounds.MusicVolume }):Play()
		current = s
	end
end

----------------------------------------------------------------------
-- Sound effects
----------------------------------------------------------------------
local lastPlayed = {}

-- Play an effect by name. If "pos" is given, it is only heard when you are near it.
function Audio.play(name, pos, volume)
	local id = Sounds.Effects[name]
	if type(id) ~= "number" or id <= 0 then
		return
	end
	local now = os.clock()
	if now - (lastPlayed[name] or -10) < 0.08 then
		return
	end
	if pos then
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - pos).Magnitude > 160 then
			return
		end
	end
	lastPlayed[name] = now
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = asset(id)
	s.Volume = (volume or 1) * Sounds.EffectVolume
	s.Parent = folder
	s:Play()
	task.delay(12, function()
		s:Destroy()
	end)
end

----------------------------------------------------------------------
-- Running water: louder the closer you are to a stream or river
----------------------------------------------------------------------
local HEAR = 75 -- studs from the bank at which water can first be heard

-- 0 (out of earshot) to 1 (standing at the water or on a bridge over it).
local function waterNearness(x)
	local best = 0
	for _, river in ipairs(Config.Rivers) do
		local fromBank = math.max(0, math.abs(x - river.x) - river.width / 2)
		local near = 1 - fromBank / HEAR
		if river.width < 20 then
			near = near * 0.75 -- a small stream is gentler than a great river
		end
		if near > best then
			best = near
		end
	end
	return best * best -- fades in gently, swells close by
end
Audio.waterNearness = waterNearness

-- Are you standing in a river's shallows (below the banks, not up on a bridge)?
local function inRiver(pos)
	if pos.Y > 1.2 then
		return false
	end
	for _, river in ipairs(Config.Rivers) do
		if math.abs(pos.X - river.x) < river.width / 2 + 3 then
			return true
		end
	end
	return false
end

-- A looping sound that is faded up and down. Returns nil if no sound has been chosen.
local function loop(name)
	local id = Sounds.Ambient and Sounds.Ambient[name]
	if type(id) ~= "number" or id <= 0 then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = asset(id)
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = folder
	return function(want, quickness)
		sound.Volume = sound.Volume + (want - sound.Volume) * quickness
		if sound.Volume > 0.01 then
			if not sound.IsPlaying then
				sound:Play()
			end
		elseif sound.IsPlaying then
			sound:Stop()
		end
	end
end

do
	local stream, wade, swim = loop("stream"), loop("wade"), loop("swim")
	if stream or wade or swim or (Sounds.Effects.splash or 0) > 0 then
		task.spawn(function()
			local wasInWater = false
			while true do
				task.wait(0.15)
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local hum = character and character:FindFirstChildOfClass("Humanoid")
				local near, wading, swimming = 0, false, false
				if root and hum then
					near = waterNearness(root.Position.X)
					local moving = hum.MoveDirection.Magnitude > 0.1
					local inWater = hum:GetState() == Enum.HumanoidStateType.Swimming
					if inWater and not wasInWater then
						Audio.play("splash")
					end
					wasInWater = inWater
					swimming = inWater and moving
					wading = moving and not inWater and inRiver(root.Position)
				end
				if stream then
					stream(near * Sounds.WaterVolume, 0.25)
				end
				if wade then
					wade(wading and Sounds.EffectVolume or 0, 0.5)
				end
				if swim then
					swim(swimming and Sounds.EffectVolume or 0, 0.5)
				end
			end
		end)
	end
end

return Audio
