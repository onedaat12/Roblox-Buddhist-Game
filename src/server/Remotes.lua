-- Remotes: the messages that travel between the server and each player's screen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Remotes"

local function event(name)
	local e = Instance.new("RemoteEvent")
	e.Name = name
	e.Parent = folder
	return e
end

local Remotes = {
	Action = event("Action"), -- player -> server: "I pressed / chose something"
	State = event("State"), -- server -> player: your progress, bag, robes ...
	Notify = event("Notify"), -- server -> player: a short message
	Dialog = event("Dialog"), -- server -> player: someone speaks, or the story is told
	Fx = event("Fx"), -- server -> players: a visual effect
	UI = event("UI"), -- server -> player: open a window (shop, shrine, robes)
}

-- Shared state of the fight with Mara, readable by every player's screen.
local boss = Instance.new("Folder")
boss.Name = "BossState"
boss:SetAttribute("Phase", "idle")
boss:SetAttribute("Text", "")
boss:SetAttribute("Hp", 0)
boss:SetAttribute("MaxHp", 1)
boss.Parent = ReplicatedStorage
Remotes.BossState = boss

folder.Parent = ReplicatedStorage

-- kind: "info", "good", "warn", "quest", "merit"
function Remotes.notify(player, text, kind)
	Remotes.Notify:FireClient(player, text, kind or "info")
end

function Remotes.notifyAll(text, kind)
	Remotes.Notify:FireAllClients(text, kind or "info")
end

-- lines: a list of { speaker, text }. An empty speaker is the storyteller.
function Remotes.dialog(player, lines, title)
	if Remotes.onDialog then
		Remotes.onDialog(player, lines)
	end
	Remotes.Dialog:FireClient(player, lines, title)
end

function Remotes.fx(name, data)
	Remotes.Fx:FireAllClients(name, data)
end

function Remotes.fxTo(player, name, data)
	Remotes.Fx:FireClient(player, name, data)
end

return Remotes
