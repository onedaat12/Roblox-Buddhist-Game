-- The Bodhi Path: everything the player sees on screen and every button they press.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Story = require(Shared:WaitForChild("Story"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BossState = ReplicatedStorage:WaitForChild("BossState")
local UI = require(script.Parent:WaitForChild("UI"))
local Fx = require(script.Parent:WaitForChild("Fx"))
local Audio = require(script.Parent:WaitForChild("Audio"))

local T = UI.Theme
local Action = Remotes:WaitForChild("Action")

local state = {
	merit = 0, stage = 1, prog = {}, inv = {}, abilities = { strike = true, meditate = true },
	robes = {}, robe = "novice", path = 0, leaves = {}, collected = {}, shrines = {}, bought = {}, lotus = {},
	weapon = "auto", symbols = {}, friends = {},
}

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

----------------------------------------------------------------------
-- The screen
----------------------------------------------------------------------
local gui = UI.new("ScreenGui", { Name = "BodhiPath", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 5 })
local root = UI.new("Frame", { Name = "Root", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = gui })
local scale = UI.new("UIScale", { Parent = root })
gui.Parent = player:WaitForChild("PlayerGui")

local function fitScreen()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1600, 900)
	local s = math.clamp(math.min(size.X / 1500, size.Y / 860), 0.5, 1.25)
	scale.Scale = s
	root.Size = UDim2.new(1 / s, 0, 1 / s, 0)
end
fitScreen()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
end

-- Calm and merit (top left)
local status = UI.panel({ Name = "Status", Position = UDim2.new(0, 20, 0, 54), Size = UDim2.new(0, 330, 0, 84), Parent = root })
UI.label({ Text = "Calm", Font = UI.TitleFont, TextSize = 20, TextColor3 = T.goldBright, Position = UDim2.new(0, 14, 0, 6), Size = UDim2.new(0, 70, 0, 26), Parent = status })
local calmBack = UI.new("Frame", { BackgroundColor3 = T.black, BorderSizePixel = 0, Position = UDim2.new(0, 84, 0, 12), Size = UDim2.new(0, 230, 0, 18), Parent = status }, { UI.corner(9) })
local calmFill = UI.new("Frame", { BackgroundColor3 = T.calm, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), Parent = calmBack }, { UI.corner(9) })
local calmText = UI.label({ Text = "100 / 100", Font = UI.BoldFont, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2, Parent = calmBack })
UI.label({ Text = "Merit", Font = UI.TitleFont, TextSize = 20, TextColor3 = T.goldBright, Position = UDim2.new(0, 14, 0, 42), Size = UDim2.new(0, 70, 0, 30), Parent = status })
local meritText = UI.label({ Text = "0", Font = UI.BoldFont, TextSize = 22, Position = UDim2.new(0, 84, 0, 42), Size = UDim2.new(0, 120, 0, 30), Parent = status })
local buffText = UI.label({ Text = "", TextSize = 13, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(0, 170, 0, 42), Size = UDim2.new(0, 146, 0, 30), Parent = status })

-- Menu buttons (under the status panel)
local menu = UI.new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 146), Size = UDim2.new(0, 330, 0, 36), Parent = root })
UI.new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = menu })

-- Quest tracker (top right)
local tracker = UI.panel({ Name = "Tracker", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 54), Size = UDim2.new(0, 380, 0, 190), Parent = root })
local questTitle = UI.label({ Text = "", Font = UI.TitleFont, TextSize = 24, TextColor3 = T.goldBright, Position = UDim2.new(0, 14, 0, 6), Size = UDim2.new(1, -28, 0, 30), Parent = tracker })
local questIntro = UI.label({ Text = "", TextSize = 14, TextColor3 = T.dim, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.new(0, 14, 0, 38), Size = UDim2.new(1, -28, 0, 58), Parent = tracker })
local questList = UI.new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 100), Size = UDim2.new(1, -28, 0, 84), Parent = tracker })
UI.new("UIListLayout", { Padding = UDim.new(0, 2), Parent = questList })

-- Messages (top centre)
local toasts = UI.new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 130), Size = UDim2.new(0, 560, 0, 220), Parent = root })
UI.new("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = toasts })

-- Zone title
local zoneTitle = UI.label({ Text = "", Font = UI.TitleFont, TextSize = 54, TextColor3 = T.goldBright, TextTransparency = 1, TextStrokeTransparency = 1, TextStrokeColor3 = T.black, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.2, 0), Size = UDim2.new(0, 900, 0, 64), Parent = root })
local zoneSub = UI.label({ Text = "", Font = UI.BodyFont, TextSize = 22, TextTransparency = 1, TextStrokeTransparency = 1, TextStrokeColor3 = T.black, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.2, 66), Size = UDim2.new(0, 900, 0, 30), Parent = root })

-- Mara (top centre)
local bossPanel = UI.panel({ Name = "Mara", Visible = false, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 46), Size = UDim2.new(0, 620, 0, 76), Parent = root })
local bossText = UI.label({ Text = "", TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 12, 0, 4), Size = UDim2.new(1, -24, 0, 42), Parent = bossPanel })
local bossBack = UI.new("Frame", { BackgroundColor3 = T.black, BorderSizePixel = 0, Position = UDim2.new(0, 16, 0, 50), Size = UDim2.new(1, -32, 0, 16), Parent = bossPanel }, { UI.corner(8) })
local bossFill = UI.new("Frame", { BackgroundColor3 = T.red, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), Parent = bossBack }, { UI.corner(8) })
local earthButton = UI.button({ Text = "Touch the Earth  (T)", Visible = false, TextSize = 30, Font = UI.TitleFont, BackgroundColor3 = T.goldBright, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.6, 0), Size = UDim2.new(0, 420, 0, 90), Parent = root }, function()
	Action:FireServer("TouchEarth")
end)

-- Screen flashes
local vignette = UI.new("Frame", { BackgroundColor3 = T.red, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = 40, Active = false, Parent = root })
local fade = UI.new("Frame", { BackgroundColor3 = T.black, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = 50, Active = false, Parent = root })
local fadeText = UI.label({ Text = "", Font = UI.TitleFont, TextSize = 34, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 900, 0, 160), ZIndex = 51, Parent = root })

local function tween(obj, seconds, props)
	local t = TweenService:Create(obj, TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

----------------------------------------------------------------------
-- Messages
----------------------------------------------------------------------
local TOAST_COLOR = { info = T.cream, good = T.green, warn = T.saffron, quest = T.goldBright, merit = T.goldBright }

local function toast(text, kind)
	if kind == "merit" or kind == "quest" then
		Audio.play(kind)
	end
	local count = 0
	for _, child in ipairs(toasts:GetChildren()) do
		if child:IsA("GuiObject") then
			count = count + 1
		end
	end
	if count >= 5 then
		for _, child in ipairs(toasts:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
				break
			end
		end
	end
	local big = kind == "quest"
	local frame = UI.new("Frame", { BackgroundColor3 = T.panel, BackgroundTransparency = 0.15, BorderSizePixel = 0, Size = UDim2.new(0, big and 520 or 440, 0, big and 46 or 34), Parent = toasts }, { UI.corner(8), UI.stroke(TOAST_COLOR[kind] or T.cream, 1.5) })
	UI.label({ Text = big and ("New step:  " .. text) or text, Font = big and UI.TitleFont or UI.BodyFont, TextSize = big and 22 or 15, TextColor3 = TOAST_COLOR[kind] or T.cream, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -16, 1, 0), Parent = frame })
	task.delay(big and 5 or 3.6, function()
		if frame.Parent then
			frame:Destroy()
		end
	end)
end

----------------------------------------------------------------------
-- Dialogue and story-telling
----------------------------------------------------------------------
local dialog = UI.panel({ Name = "Dialog", Visible = false, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -130), Size = UDim2.new(0, 900, 0, 180), ZIndex = 20, Parent = root })
local dialogWho = UI.label({ Text = "", Font = UI.TitleFont, TextSize = 26, TextColor3 = T.goldBright, Position = UDim2.new(0, 22, 0, 10), Size = UDim2.new(1, -44, 0, 32), ZIndex = 21, Parent = dialog })
local dialogText = UI.label({ Text = "", TextSize = 19, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.new(0, 22, 0, 48), Size = UDim2.new(1, -44, 0, 88), ZIndex = 21, Parent = dialog })
local dialogNext = UI.button({ Text = "Continue", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -12), Size = UDim2.new(0, 150, 0, 34), ZIndex = 22, Parent = dialog })
local dialogQueue = {}
local dialogOpen = false

local function showNextLine()
	local line = table.remove(dialogQueue, 1)
	if not line then
		if dialogOpen then
			Action:FireServer("DialogDone")
		end
		dialogOpen = false
		dialog.Visible = false
		return
	end
	dialogOpen = true
	dialog.Visible = true
	local who = line[1] or ""
	dialogWho.Text = (who == "") and "The Story" or who
	dialogWho.TextColor3 = (who == "") and T.dim or T.goldBright
	dialogText.Font = (who == "") and Enum.Font.Garamond or UI.BodyFont
	dialogText.TextSize = (who == "") and 22 or 19
	dialogText.Text = line[2] or ""
	dialogNext.Text = (#dialogQueue > 0) and "Continue" or "Close"
end

local function queueDialog(lines)
	if type(lines) ~= "table" then
		return
	end
	for _, line in ipairs(lines) do
		table.insert(dialogQueue, line)
	end
	if not dialogOpen then
		Audio.play("talk")
		showNextLine()
	end
end
dialogNext.Activated:Connect(showNextLine)

----------------------------------------------------------------------
-- Windows (bag, shop, robes, path, shrine, leaves)
----------------------------------------------------------------------
local window = UI.panel({ Name = "Window", Visible = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -10), Size = UDim2.new(0, 780, 0, 540), ZIndex = 30, Parent = root })
local windowTitle = UI.label({ Text = "", Font = UI.TitleFont, TextSize = 32, TextColor3 = T.goldBright, Position = UDim2.new(0, 24, 0, 10), Size = UDim2.new(1, -110, 0, 40), ZIndex = 31, Parent = window })
local windowSub = UI.label({ Text = "", TextSize = 15, TextColor3 = T.dim, Position = UDim2.new(0, 24, 0, 50), Size = UDim2.new(1, -48, 0, 22), ZIndex = 31, Parent = window })
local windowList = UI.new("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 18, 0, 82), Size = UDim2.new(1, -36, 1, -100), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 8, ScrollBarImageColor3 = T.gold, ZIndex = 31, Parent = window })
UI.new("UIListLayout", { Padding = UDim.new(0, 8), Parent = windowList })
local openWindow = nil -- { kind = ..., arg = ... }

local function closeWindow()
	openWindow = nil
	window.Visible = false
end
UI.button({ Text = "X", TextSize = 20, BackgroundColor3 = T.red, TextColor3 = T.cream, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.new(0, 40, 0, 36), ZIndex = 32, Parent = window }, closeWindow)

-- One row in a window: a name, a description, and (optionally) a button.
local function row(name, desc, buttonText, buttonColor, onClick, height)
	local frame = UI.new("Frame", { BackgroundColor3 = T.row, BorderSizePixel = 0, Size = UDim2.new(1, -12, 0, height or 68), ZIndex = 31, Parent = windowList }, { UI.corner(8) })
	UI.label({ Text = name, Font = UI.BoldFont, TextSize = 17, TextColor3 = T.goldBright, Position = UDim2.new(0, 14, 0, 6), Size = UDim2.new(1, -200, 0, 22), ZIndex = 32, Parent = frame })
	UI.label({ Text = desc, TextSize = 14, TextColor3 = T.cream, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.new(0, 14, 0, 28), Size = UDim2.new(1, -200, 1, -32), ZIndex = 32, Parent = frame })
	if buttonText then
		local b = UI.button({ Text = buttonText, BackgroundColor3 = buttonColor or T.saffron, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 160, 0, 38), ZIndex = 32, Parent = frame }, onClick)
		if not onClick then
			b.AutoButtonColor = false
			b.BackgroundTransparency = 0.5
		end
	end
	return frame
end

local function heading(text)
	UI.label({ Text = text, Font = UI.TitleFont, TextSize = 22, TextColor3 = T.gold, Size = UDim2.new(1, -12, 0, 30), ZIndex = 31, Parent = windowList })
end

local function price(base)
	if state.path >= 3 then
		return math.floor(base * 0.85 + 0.5)
	end
	return base
end

local function leafCount()
	local n = 0
	for _ in pairs(state.leaves) do
		n = n + 1
	end
	return n
end

local function countOf(list)
	local n = 0
	for _ in pairs(list or {}) do
		n = n + 1
	end
	return n
end

-- The weapon in hand: its id and its entry in Config.Weapons.
local function heldWeapon()
	local id = state.weapon or "auto"
	if id == "auto" then
		id = state.abilities.staff and "staff" or "palm"
	end
	if id ~= "palm" and (not Config.Weapons[id] or (state.inv[id] or 0) < 1) then
		id = "palm"
	end
	return id, Config.Weapons[id]
end

local Windows = {}

function Windows.bag()
	windowTitle.Text = "Bag"
	windowSub.Text = "What you carry. A monk owns little."
	local ids = {}
	for id, count in pairs(state.inv) do
		if count > 0 and Config.Items[id] then
			table.insert(ids, id)
		end
	end
	table.sort(ids, function(a, b)
		return Config.Items[a].order < Config.Items[b].order
	end)
	if #ids == 0 then
		row("Empty", "Your bag is empty. Villagers give alms, and shops trade for merit.", nil)
	end
	for _, id in ipairs(ids) do
		local def = Config.Items[id]
		local label = nil
		if def.use == "heal" or def.use == "speed" or def.use == "regen" or def.use == "quest" then
			label = (def.use == "heal" or def.use == "quest") and "Eat" or "Use"
		elseif def.use == "offer" then
			label = "Offer"
		elseif def.use == "equip" then
			label = (heldWeapon() == id) and "Put away" or "Hold"
		end
		local color = (label == "Put away") and T.green or nil
		row(def.name .. ((def.use == "equip") and "" or ("  x" .. state.inv[id])), def.desc, label, color, label and function()
			Action:FireServer("UseItem", id)
		end or nil)
	end
end

function Windows.shop(shopId)
	local shop = Config.Shops[shopId]
	if not shop then
		return
	end
	windowTitle.Text = shop.name
	windowSub.Text = "Merit: " .. state.merit .. "    Everything here is paid for with merit, not coins."
	for _, entry in ipairs(shop.stock) do
		local def = Config.Items[entry.item]
		local owned = entry.once and (state.bought[entry.item] or (state.inv[entry.item] or 0) > 0)
		if owned then
			row(def.name, def.desc, "Owned", T.green, nil)
		else
			local cost = price(entry.price)
			row(def.name, def.desc, cost .. " merit", (state.merit >= cost) and T.saffron or T.dim, function()
				Action:FireServer("Buy", shopId, entry.item)
			end)
		end
	end
end

function Windows.robes()
	windowTitle.Text = "Robes"
	windowSub.Text = "Merit: " .. state.merit .. "    Robes of the Buddhist traditions. Some can only be earned."
	for _, def in ipairs(Config.Robes) do
		if state.robe == def.id then
			row(def.name, def.desc, "Wearing", T.green, nil)
		elseif state.robes[def.id] then
			row(def.name, def.desc, "Wear", T.goldBright, function()
				Action:FireServer("WearRobe", def.id)
			end)
		elseif def.quest or def.reward then
			row(def.name, def.desc, "Earned on the journey", T.dim, nil)
		else
			local cost = price(def.price or 0)
			row(def.name, def.desc, cost .. " merit", (state.merit >= cost) and T.saffron or T.dim, function()
				Action:FireServer("BuyRobe", def.id)
			end)
		end
	end
end

local function pathRows()
	for i, step in ipairs(Config.Path) do
		local title = i .. ". " .. step.name .. "  (" .. step.pali .. ")"
		if i <= state.path then
			row(title, step.text, "Practised", T.green, nil, 60)
		elseif i == state.path + 1 then
			row(title, step.text, step.cost .. " merit", (state.merit >= step.cost) and T.saffron or T.dim, function()
				Action:FireServer("BuyPath")
			end, 60)
		else
			row(title, step.text, "Later", T.dim, nil, 60)
		end
	end
end

function Windows.path()
	windowTitle.Text = "The Noble Eightfold Path"
	windowSub.Text = "Merit: " .. state.merit .. "    Practised in order, at any shrine."
	pathRows()
end

function Windows.leaves()
	windowTitle.Text = "Things Found"
	windowSub.Text = "Leaves " .. leafCount() .. " of " .. #Config.Leaves .. "    Symbols " .. countOf(state.symbols) .. " of " .. #Config.Symbols .. "    Animal friends " .. countOf(state.friends) .. " of " .. #Config.Animals
	heading("The Eight Auspicious Symbols")
	for _, def in ipairs(Config.Symbols) do
		if state.symbols and state.symbols[def.id] then
			row(def.name, def.text, nil, nil, nil, 76)
		else
			row("A hidden symbol", "Not yet found. One is hidden in each land, far from the road. Find all eight to earn the Sword of Wisdom.", nil, nil, nil, 60)
		end
	end
	heading("Animals of the Jataka Tales")
	for _, def in ipairs(Config.Animals) do
		if state.friends and state.friends[def.id] then
			row(def.name, def.text .. "  (" .. def.source .. ", retold)", nil, nil, nil, 112)
		else
			row("An animal you have not met", "Somewhere along the road an animal is waiting. Share Alms Rice with it to hear its story. Befriend all six to earn the Wheel of Light.", nil, nil, nil, 50)
		end
	end
	heading("Bodhi Leaves")
	for i, teaching in ipairs(Story.Teachings) do
		if state.leaves["leaf_" .. i] then
			row("Leaf " .. i, teaching.text .. "  (" .. teaching.source .. ", paraphrased)", nil, nil, nil, 76)
		else
			row("Leaf " .. i, "Not yet found. Look off the road, in quiet corners.", nil, nil, nil, 50)
		end
	end
end

function Windows.shrine(shrineId)
	local name = "Shrine"
	for _, s in ipairs(Config.Shrines) do
		if s.id == shrineId then
			name = s.name
		end
	end
	windowTitle.Text = name
	windowSub.Text = "Merit: " .. state.merit .. "    Your Calm is restored. You will return here if you are overwhelmed."
	heading("Offerings")
	local any = false
	for _, id in ipairs({ "lotus", "lamp" }) do
		local count = state.inv[id] or 0
		if count > 0 then
			any = true
			local def = Config.Items[id]
			row(def.name .. "  x" .. count, def.desc, "Offer", nil, function()
				Action:FireServer("UseItem", id)
			end, 60)
		end
	end
	if not any then
		row("Nothing to offer", "Lotus flowers grow in the ponds. Butter lamps are sold in the shops.", nil, nil, nil, 50)
	end
	heading("Travel to another shrine")
	for _, s in ipairs(Config.Shrines) do
		if s.id ~= shrineId and state.shrines[s.id] then
			row(s.name, "A shrine you have prayed at.", "Travel", T.goldBright, function()
				Action:FireServer("Travel", s.id)
				closeWindow()
			end, 50)
		end
	end
	heading("The Noble Eightfold Path")
	pathRows()
end

local function refreshWindow()
	if not openWindow then
		return
	end
	local y = windowList.CanvasPosition
	UI.clear(windowList)
	Windows[openWindow.kind](openWindow.arg)
	windowList.CanvasPosition = y
end

local function showWindow(kind, arg)
	if openWindow and openWindow.kind == kind and kind ~= "shop" and kind ~= "shrine" then
		closeWindow()
		return
	end
	openWindow = { kind = kind, arg = arg }
	window.Visible = true
	windowList.CanvasPosition = Vector2.new(0, 0)
	refreshWindow()
end

local function menuButton(text, kind)
	UI.button({ Text = text, TextSize = 14, BackgroundColor3 = T.panelLight, TextColor3 = T.goldBright, Size = UDim2.new(0, 78, 1, 0), Parent = menu }, function()
		showWindow(kind)
	end)
end
menuButton("Bag (B)", "bag")
menuButton("Path (P)", "path")
menuButton("Robes", "robes")
menuButton("Finds", "leaves")

----------------------------------------------------------------------
-- Abilities (bottom centre)
----------------------------------------------------------------------
local bar = UI.new("Frame", { Name = "Abilities", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.new(0, 460, 0, 92), Parent = root })
UI.new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = bar })

local abilityButtons = {}
local cooldownEnds = {}
local cooldownLength = {}
local meditating = false
local slashTrack = nil
local slashOwner = nil

local function humanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function playSlash()
	local hum = humanoid()
	if not hum then
		return
	end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end
	pcall(function()
		if not slashTrack or slashOwner ~= animator then
			slashOwner = animator
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://522635514"
			slashTrack = animator:LoadAnimation(anim)
			slashTrack.Priority = Enum.AnimationPriority.Action
		end
		slashTrack:Play(0.05)
	end)
end

local function setMeditating(on)
	if meditating == on then
		return
	end
	meditating = on
	if on then
		Audio.play("meditate")
	end
	local hum = humanoid()
	if hum then
		hum.Sit = on
	end
	Action:FireServer("meditate", on)
end

local function useAbility(name)
	local def = Config.Abilities[name]
	if not def or not state.abilities[name] then
		return
	end
	if dialogOpen then
		return
	end
	if name == "meditate" then
		setMeditating(not meditating)
		return
	end
	local now = os.clock()
	if now < (cooldownEnds[name] or 0) then
		return
	end
	local cd = def.cooldown
	if name == "beads" and (state.inv.long_mala or 0) > 0 then
		cd = cd / 2
	end
	if name == "strike" then
		local _, weapon = heldWeapon()
		cd = weapon.cooldown
	end
	cooldownEnds[name] = now + cd
	cooldownLength[name] = cd
	if meditating then
		setMeditating(false)
	end
	if name == "strike" then
		playSlash()
	end
	Audio.play(name)
	Action:FireServer(name)
end

do
	local names = {}
	for name in pairs(Config.Abilities) do
		table.insert(names, name)
	end
	table.sort(names, function(a, b)
		return Config.Abilities[a].order < Config.Abilities[b].order
	end)
	for _, name in ipairs(names) do
		local def = Config.Abilities[name]
		local b = UI.button({ Name = name, Text = "", BackgroundColor3 = T.panel, LayoutOrder = def.order, Size = UDim2.new(0, 82, 0, 82), ClipsDescendants = true, Parent = bar }, function()
			useAbility(name)
		end)
		UI.stroke(T.gold, 2).Parent = b
		UI.label({ Text = def.name, Font = UI.TitleFont, TextSize = 19, TextColor3 = T.goldBright, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 0, 14), Size = UDim2.new(1, 0, 0, 30), ZIndex = 3, Parent = b })
		UI.label({ Text = def.key, Font = UI.BoldFont, TextSize = 14, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 1, -28), Size = UDim2.new(1, 0, 0, 20), ZIndex = 3, Parent = b })
		local shade = UI.new("Frame", { Name = "Shade", BackgroundColor3 = T.black, BackgroundTransparency = 0.35, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 0), ZIndex = 2, Parent = b })
		abilityButtons[name] = { button = b, shade = shade }
	end
end

----------------------------------------------------------------------
-- Keeping the screen up to date
----------------------------------------------------------------------
local marker = Instance.new("Part")
marker.Name = "GoalMarker"
marker.Anchored = true
marker.CanCollide = false
marker.CanTouch = false
marker.CanQuery = false
marker.Transparency = 1
marker.Size = Vector3.new(1, 1, 1)
local markerGui = UI.new("BillboardGui", { Size = UDim2.new(0, 150, 0, 54), AlwaysOnTop = true, LightInfluence = 0, MaxDistance = 100000, Enabled = false, Parent = marker })
local markerDiamond = UI.new("Frame", { BackgroundColor3 = T.goldBright, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 2), Size = UDim2.new(0, 18, 0, 18), Rotation = 45, Parent = markerGui }, { UI.stroke(T.black, 2) })
local markerText = UI.label({ Text = "", Font = UI.BoldFont, TextSize = 15, TextColor3 = T.goldBright, TextStrokeTransparency = 0.2, TextStrokeColor3 = T.black, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 22), Parent = markerGui })
marker.Parent = workspace
local goal = nil

local function npcPlace(id)
	for _, npc in ipairs(Story.NPCs) do
		if npc.id == id then
			return npc
		end
	end
	return nil
end

local INTERACT_PLACE = { temple_bell = "temple_bell", hair_rock = "hair_rock", bowl_river = "bowl_river", vajrasana = "seat" }

-- Where should the golden marker point for this objective?
local function goalFor(obj)
	if obj.kind == "talk" then
		return npcPlace(obj.target)
	elseif obj.kind == "interact" then
		return Config.Places[INTERACT_PLACE[obj.target] or ""]
	elseif obj.kind == "alms" then
		-- the next villager who has not yet filled the bowl
		for _, npc in ipairs(Story.NPCs) do
			if npc.alms and not (state.almsGiven and state.almsGiven[npc.id]) then
				return npc
			end
		end
		return { x = 190, z = 0 }
	elseif obj.kind == "meditate" then
		for _, s in ipairs(Config.MeditationSpots) do
			if s.id == obj.target then
				return s
			end
		end
	elseif obj.kind == "reach" then
		return Config.Areas[obj.target]
	elseif obj.kind == "dispel" then
		for _, s in ipairs(Config.Spawns) do
			if s.type == obj.target or s.group == obj.target then
				return s
			end
		end
	elseif obj.kind == "collect" then
		for i, p in ipairs(Config.Kusa) do
			if not state.collected["kusa_" .. i] then
				return p
			end
		end
	elseif obj.kind == "boss" then
		return Config.Places.arena
	end
	return nil
end

local function refreshTracker()
	local quest = Story.Quests[state.stage] or Story.Quests[1]
	questTitle.Text = quest.title
	questIntro.Text = quest.intro or ""
	UI.clear(questList)
	goal = nil
	for i, obj in ipairs(quest.objectives) do
		local need = obj.count or 1
		local have = math.min(need, math.floor(state.prog[tostring(i)] or 0))
		local done = have >= need
		local text = obj.text
		if need > 1 then
			text = text .. "  " .. have .. " / " .. need
		end
		UI.label({ Text = (done and "[done]  " or "-  ") .. text, Font = UI.BoldFont, TextSize = 15, TextColor3 = done and T.green or T.cream, Size = UDim2.new(1, 0, 0, 20), Parent = questList })
		if not done and not goal then
			goal = goalFor(obj)
		end
	end
	if quest.final then
		UI.label({ Text = "Leaves found: " .. leafCount() .. " / " .. #Config.Leaves, Font = UI.BoldFont, TextSize = 15, Size = UDim2.new(1, 0, 0, 20), Parent = questList })
		UI.label({ Text = "Eightfold Path: " .. state.path .. " / " .. #Config.Path, Font = UI.BoldFont, TextSize = 15, Size = UDim2.new(1, 0, 0, 20), Parent = questList })
	end
	if goal then
		marker.CFrame = CFrame.new(goal.x, (goal.y or 0) + 11, goal.z)
		markerGui.Enabled = true
	else
		markerGui.Enabled = false
	end
end

local function refreshAbilities()
	for name, entry in pairs(abilityButtons) do
		entry.button.Visible = state.abilities[name] == true
	end
end

local function refreshCalm()
	local max = player:GetAttribute("MaxCalm") or 100
	local calm = math.clamp(player:GetAttribute("Calm") or max, 0, max)
	calmFill.Size = UDim2.new(calm / max, 0, 1, 0)
	calmFill.BackgroundColor3 = (calm / max < 0.3) and T.red or T.calm
	calmText.Text = math.floor(calm + 0.5) .. " / " .. max
end

local function refreshMerit()
	meritText.Text = tostring(player:GetAttribute("Merit") or state.merit or 0)
end

player:GetAttributeChangedSignal("Calm"):Connect(refreshCalm)
player:GetAttributeChangedSignal("MaxCalm"):Connect(refreshCalm)
player:GetAttributeChangedSignal("Merit"):Connect(refreshMerit)
player:GetAttributeChangedSignal("Meditating"):Connect(function()
	if not player:GetAttribute("Meditating") and meditating then
		meditating = false
		local hum = humanoid()
		if hum then
			hum.Sit = false
		end
	end
end)

Remotes:WaitForChild("State").OnClientEvent:Connect(function(new)
	if type(new) ~= "table" then
		return
	end
	for key, value in pairs(new) do
		state[key] = value
	end
	refreshTracker()
	refreshAbilities()
	refreshMerit()
	refreshWindow()
	Fx.refreshWorld(state)
	Audio.setStage(state.stage)
end)

Remotes:WaitForChild("Notify").OnClientEvent:Connect(toast)
Remotes:WaitForChild("Dialog").OnClientEvent:Connect(queueDialog)
Remotes:WaitForChild("UI").OnClientEvent:Connect(function(kind, arg)
	if Windows[kind] then
		if kind == "shrine" then
			Audio.play("pray")
		end
		openWindow = nil
		showWindow(kind, arg)
	end
end)

----------------------------------------------------------------------
-- Effects sent by the server
----------------------------------------------------------------------
local function flash(color, peak, seconds)
	fade.BackgroundColor3 = color
	fade.BackgroundTransparency = peak
	tween(fade, seconds, { BackgroundTransparency = 1 })
end

local Effects = {}
Effects.petals = Fx.petals
Effects.ring = Fx.ring
Effects.hit = Fx.hit
function Effects.bell()
	Fx.shake(0.4, 0.25)
end
function Effects.hurt()
	vignette.BackgroundTransparency = 0.72
	tween(vignette, 0.5, { BackgroundTransparency = 1 })
end
function Effects.fade()
	fade.BackgroundColor3 = T.black
	tween(fade, 0.3, { BackgroundTransparency = 0 })
	task.delay(0.8, function()
		tween(fade, 0.6, { BackgroundTransparency = 1 })
	end)
end
function Effects.overwhelm(data)
	meditating = false
	fade.BackgroundColor3 = T.black
	tween(fade, 0.5, { BackgroundTransparency = 0 })
	fadeText.Text = data.text or ""
	tween(fadeText, 0.5, { TextTransparency = 0 })
	task.delay(3, function()
		tween(fade, 1, { BackgroundTransparency = 1 })
		tween(fadeText, 1, { TextTransparency = 1 })
	end)
end
function Effects.storm(data)
	flash(data.color or T.black, 0.55, 1.2)
	Fx.shake(0.6, 0.4)
end
function Effects.quake()
	Fx.shake(3, 1.6)
	flash(Color3.fromRGB(255, 240, 200), 0.1, 3)
end
function Effects.awaken()
	fade.BackgroundColor3 = Color3.fromRGB(255, 248, 226)
	tween(fade, 2.5, { BackgroundTransparency = 0 })
	fadeText.TextColor3 = Color3.fromRGB(120, 80, 20)
	fadeText.Text = "The morning star rises.\nYou are awake."
	task.delay(2.5, function()
		Fx.setMood("dawn", 0.1)
		tween(fadeText, 1, { TextTransparency = 0 })
	end)
	task.delay(8, function()
		tween(fade, 4, { BackgroundTransparency = 1 })
		tween(fadeText, 3, { TextTransparency = 1 })
	end)
	task.delay(12.5, function()
		fadeText.TextColor3 = T.cream
	end)
end

Remotes:WaitForChild("Fx").OnClientEvent:Connect(function(name, data)
	Audio.play(name, type(data) == "table" and data.pos or nil)
	local fn = Effects[name]
	if fn then
		local ok, err = pcall(fn, data or {})
		if not ok then
			warn("[Bodhi Path] effect failed:", name, err)
		end
	end
end)

----------------------------------------------------------------------
-- Mara
----------------------------------------------------------------------
local function refreshBoss()
	local phase = BossState:GetAttribute("Phase") or "idle"
	local near = false
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local a = Config.Places.arena
		near = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(a.x, 0, a.z)).Magnitude < a.radius + 60
	end
	bossPanel.Visible = phase ~= "idle" and near
	earthButton.Visible = phase == "witness" and near
	local text = BossState:GetAttribute("Text") or ""
	if phase == "mara" then
		local hp, max = BossState:GetAttribute("Hp") or 0, BossState:GetAttribute("MaxHp") or 1
		bossBack.Visible = true
		bossFill.Size = UDim2.new(math.clamp(hp / math.max(1, max), 0, 1), 0, 1, 0)
	elseif phase == "host" or phase == "storms" then
		local count, need = BossState:GetAttribute("Count") or 0, BossState:GetAttribute("Need") or 1
		bossBack.Visible = true
		bossFill.Size = UDim2.new(math.clamp(count / math.max(1, need), 0, 1), 0, 1, 0)
		text = text .. "  (" .. count .. " / " .. need .. ")"
	else
		bossBack.Visible = false
	end
	bossText.Text = text
end
BossState.AttributeChanged:Connect(refreshBoss)

----------------------------------------------------------------------
-- Keys
----------------------------------------------------------------------
local KEYS = {}
for name, def in pairs(Config.Abilities) do
	KEYS[Enum.KeyCode[def.key]] = name
end

UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
		if dialogOpen then
			showNextLine()
			return
		end
	end
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dialogOpen then
			showNextLine()
		elseif not openWindow then
			useAbility("strike")
		end
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		local ability = KEYS[input.KeyCode]
		if ability then
			useAbility(ability)
		elseif input.KeyCode == Enum.KeyCode.B then
			showWindow("bag")
		elseif input.KeyCode == Enum.KeyCode.P then
			showWindow("path")
		elseif input.KeyCode == Enum.KeyCode.T then
			Action:FireServer("TouchEarth")
		elseif input.KeyCode == Enum.KeyCode.Escape then
			closeWindow()
		end
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
		if input.KeyCode == Enum.KeyCode.ButtonR2 then
			useAbility("strike")
		elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
			useAbility("beads")
		elseif input.KeyCode == Enum.KeyCode.ButtonY then
			useAbility("meditate")
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
			useAbility("metta")
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
			useAbility("bowl")
		end
	end
end)

----------------------------------------------------------------------
-- Every frame / every half second
----------------------------------------------------------------------
local currentZone = nil

local function showZone(zone)
	zoneTitle.Text = zone.name
	zoneSub.Text = zone.sub
	tween(zoneTitle, 1, { TextTransparency = 0, TextStrokeTransparency = 0.4 })
	tween(zoneSub, 1, { TextTransparency = 0, TextStrokeTransparency = 0.5 })
	task.delay(4.5, function()
		if currentZone == zone then
			tween(zoneTitle, 1.5, { TextTransparency = 1, TextStrokeTransparency = 1 })
			tween(zoneSub, 1.5, { TextTransparency = 1, TextStrokeTransparency = 1 })
		end
	end)
end

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	for name, entry in pairs(abilityButtons) do
		local left = (cooldownEnds[name] or 0) - now
		local length = cooldownLength[name] or 1
		if left > 0 and length > 0.6 then
			entry.shade.Size = UDim2.new(1, 0, math.clamp(left / length, 0, 1), 0)
		else
			entry.shade.Size = UDim2.new(1, 0, 0, 0)
		end
	end
	local med = abilityButtons.meditate
	if med then
		med.button.BackgroundColor3 = meditating and T.saffron or T.panel
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local hum = humanoid()
		if hrp then
			local zone = Fx.zoneAt(hrp.Position.X)
			if zone ~= currentZone then
				currentZone = zone
				showZone(zone)
			end
			local mood = zone.light
			if zone.id == "bodhgaya" and player:GetAttribute("Awakened") then
				mood = "dawn"
			end
			Fx.setMood(mood, 4)
			if goal then
				local d = (Vector3.new(goal.x, hrp.Position.Y, goal.z) - hrp.Position).Magnitude
				markerText.Text = math.floor(d / 3.5 + 0.5) .. " m"
				markerGui.Enabled = d > 14
			end
		end
		-- standing up (jumping or walking) ends meditation
		if meditating and hum and not hum.Sit then
			meditating = false
			Action:FireServer("meditate", false)
		end
		buffText.Text = meditating and "Meditating" or ""
		refreshBoss()
	end
end)

refreshCalm()
refreshMerit()
refreshTracker()
refreshAbilities()
Action:FireServer("Ready")
