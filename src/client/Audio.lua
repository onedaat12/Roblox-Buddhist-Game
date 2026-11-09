-- Audio: plays the music for the current step of the journey and the sound effects.
-- The sound IDs themselves live in ReplicatedStorage.Shared.Sounds.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Sounds = require(Shared:WaitForChild("Sounds"))
local Story = require(Shared:WaitForChild("Story"))

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

return Audio
