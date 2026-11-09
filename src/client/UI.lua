-- UI: small helpers and the shared look of every panel on screen.

local UI = {}

UI.Theme = {
	panel = Color3.fromRGB(46, 22, 24),
	panelLight = Color3.fromRGB(74, 36, 34),
	row = Color3.fromRGB(62, 30, 30),
	gold = Color3.fromRGB(226, 178, 54),
	goldBright = Color3.fromRGB(255, 214, 96),
	cream = Color3.fromRGB(246, 236, 212),
	dim = Color3.fromRGB(196, 176, 150),
	saffron = Color3.fromRGB(232, 136, 24),
	green = Color3.fromRGB(110, 170, 96),
	red = Color3.fromRGB(196, 72, 60),
	calm = Color3.fromRGB(96, 190, 200),
	black = Color3.fromRGB(12, 8, 8),
}

UI.TitleFont = Enum.Font.Fondamento
UI.BodyFont = Enum.Font.Merriweather
UI.BoldFont = Enum.Font.GothamBold

-- Create an instance, set its properties, and add children.
function UI.new(class, props, children)
	local inst = Instance.new(class)
	local parent = nil
	if props then
		for key, value in pairs(props) do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function UI.corner(radius)
	return UI.new("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

function UI.stroke(color, thickness)
	return UI.new("UIStroke", { Color = color or UI.Theme.gold, Thickness = thickness or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

function UI.pad(n)
	return UI.new("UIPadding", {
		PaddingLeft = UDim.new(0, n), PaddingRight = UDim.new(0, n),
		PaddingTop = UDim.new(0, n), PaddingBottom = UDim.new(0, n),
	})
end

-- A framed panel.
function UI.panel(props)
	props.BackgroundColor3 = props.BackgroundColor3 or UI.Theme.panel
	props.BackgroundTransparency = props.BackgroundTransparency or 0.08
	props.BorderSizePixel = 0
	return UI.new("Frame", props, { UI.corner(12), UI.stroke(UI.Theme.gold, 2) })
end

function UI.label(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or UI.BodyFont
	props.TextColor3 = props.TextColor3 or UI.Theme.cream
	props.TextSize = props.TextSize or 18
	props.TextWrapped = (props.TextWrapped == nil) and true or props.TextWrapped
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	return UI.new("TextLabel", props)
end

function UI.button(props, onClick)
	props.BackgroundColor3 = props.BackgroundColor3 or UI.Theme.saffron
	props.BorderSizePixel = 0
	props.AutoButtonColor = true
	props.Font = props.Font or UI.BoldFont
	props.TextColor3 = props.TextColor3 or UI.Theme.black
	props.TextSize = props.TextSize or 16
	props.TextWrapped = true
	local b = UI.new("TextButton", props, { UI.corner(8) })
	if onClick then
		b.Activated:Connect(onClick)
	end
	return b
end

function UI.clear(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

return UI
