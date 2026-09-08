local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ControlHintsHub") then
	playerGui.ControlHintsHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlHintsHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Bottom Left Hints Display
local hintsFrame = Instance.new("Frame")
hintsFrame.Size = UDim2.new(0, 240, 0, 140)
hintsFrame.Position = UDim2.new(0, 15, 1, -155)
hintsFrame.BackgroundTransparency = 1
hintsFrame.Parent = screenGui

local function createHintItem(name, text, posY)
	local container = Instance.new("TextButton")
	container.Name = name
	container.Size = UDim2.new(1, 0, 0, 28)
	container.Position = UDim2.new(0, 0, 0, posY)
	container.BackgroundTransparency = 0.8
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.TextColor3 = Color3.fromRGB(255, 255, 255)
	container.TextTransparency = 0.4
	container.Text = text
	container.Font = Enum.Font.GothamMedium
	container.TextSize = 14
	container.TextXAlignment = Enum.TextXAlignment.Left
	container.Parent = hintsFrame
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = container
	
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Name = "ActiveStroke"
	uiStroke.Color = Color3.fromRGB(46, 204, 113)
	uiStroke.Thickness = 2
	uiStroke.Transparency = 1
	uiStroke.Parent = container
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.Parent = container
	
	return container
end

local meleeHint = createHintItem("MeleeHint", "Melee Toggle: P", 0)
local repairHint = createHintItem("RepairHint", "Repair: G", 34)
local constructHint = createHintItem("ConstructHint", "Construct UI: M", 68)
local blockHint = createHintItem("BlockHint", "Block Toggle: O", 102)

-- Construct UI Frame (Draggable)
local constructFrame = Instance.new("Frame")
constructFrame.Size = UDim2.new(0, 220, 0, 110)
constructFrame.Position = UDim2.new(0.5, -110, 0.5, -55)
constructFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
constructFrame.BorderSizePixel = 0
constructFrame.Visible = false
constructFrame.Parent = screenGui

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 8)
cCorner.Parent = constructFrame

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, 0, 0, 30)
cTitle.BackgroundTransparency = 1
cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cTitle.Text = "Construction Menu"
cTitle.Font = Enum.Font.GothamBold
cTitle.TextSize = 13
cTitle.Parent = constructFrame

local idTextBox = Instance.new("TextBox")
idTextBox.Size = UDim2.new(1, -20, 0, 32)
idTextBox.Position = UDim2.new(0, 10, 0, 35)
idTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
idTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idTextBox.PlaceholderText = "ID (1-14 or 1001)"
idTextBox.Text = ""
idTextBox.Font = Enum.Font.GothamMedium
idTextBox.TextSize = 13
idTextBox.Parent = constructFrame

local idCorner = Instance.new("UICorner")
idCorner.CornerRadius = UDim.new(0, 6)
idCorner.Parent = idTextBox

local placeButton = Instance.new("TextButton")
placeButton.Size = UDim2.new(1, -20, 0, 30)
placeButton.Position = UDim2.new(0, 10, 0, 72)
placeButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
placeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
placeButton.Text = "Build Structure"
placeButton.Font = Enum.Font.GothamBold
placeButton.TextSize = 13
placeButton.Parent = constructFrame

local pCorner = Instance.new("UICorner")
pCorner.CornerRadius = UDim.new(0, 6)
pCorner.Parent = placeButton

-- Make Construct UI Draggable
local dragging, dragInput, dragStart, startPos
cTitle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = constructFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
cTitle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		constructFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- References & State Variables
local commonDirectory = ReplicatedStorage:FindFirstChild("CommonDirectory")
local remotesFolder = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Melee"):WaitForChild("Remotes")
local buildingFolderModule = game.ReplicatedStorage:FindFirstChild("Systems"):FindFirstChild("Building")
local buildingRemotes = buildingFolderModule and buildingFolderModule:FindFirstChild("Remotes")

local idToRealNameMap = {
	[1] = "WoodenBarricade", [2] = "WoodenWall", [3] = "WoodenPlatform", [4] = "WoodenBarrel",
	[5] = "WoodenStakes", [6] = "Gabion", [7] = "SandbagSmall", [8] = "SandbagLarge",
	[9] = "Earthwork", [10] = "SpikeTrap", [11] = "GunpowderBarrel", [12] = "BearTrap",
	[13] = "WoodenShield", [14] = "ArrowStation", [1001] = "EarthWall"
}

local meleeToggled = false
local blockToggled = false
local constructOpen = false
local currentVisualizer = nil
local isRepairing = false
local lmbDownTime = 0
local isHoldingLMB = false

local function setIndicator(btn, state)
	local stroke = btn:FindFirstChild("ActiveStroke")
	if stroke then
		stroke.Transparency = state and 0 or 1
	end
end

local function getValidMeleeTool(character)
	if not character then return nil end
	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		local name = tool.Name:lower()
		local excluded = {"pistol", "musket", "staff", "glove", "hammer", "shovel", "tachard", "bandage", "slurry", "explode"}
		for _, exc in ipairs(excluded) do
			if name:find(exc) then return nil end
		end
		return tool
	end
	return nil
end

local function findModelRecursive(parent, targetName)
	if not parent then return nil end
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == targetName and child:IsA("Model") then return child end
		local found = findModelRecursive(child, targetName)
		if found then return found end
	end
	return nil
end

local function getNearestTarget(character)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil, Vector3.new() end
	local nearestHum, nearestPos, minDistance = nil, Vector3.new(), math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= character then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
			if hum and hum.Health > 0 and hrp then
				local dist = (hrp.Position - root.Position).Magnitude
				if dist < 100 and dist < minDistance then
					minDistance = dist
					nearestHum = hum
					nearestPos = hrp.Position
				end
			end
		end
	end
	return nearestHum, nearestPos
end

-- Melee Logic (P)
local function toggleMelee()
	meleeToggled = not meleeToggled
	setIndicator(meleeHint, meleeToggled)
end

-- Block Logic (O)
local function toggleBlock()
	blockToggled = not blockToggled
	setIndicator(blockHint, blockToggled)
	local character = player.Character
	local tool = getValidMeleeTool(character)
	local blockRE = remotesFolder and remotesFolder:FindFirstChild("BlockRE")
	if blockRE and tool then blockRE:FireServer(blockToggled, tool) end
end

-- Construct UI Toggle (M)
local function toggleConstructUI()
	constructOpen = not constructOpen
	constructFrame.Visible = constructOpen
	setIndicator(constructHint, constructOpen)
	if not constructOpen and currentVisualizer then
		currentVisualizer:Destroy()
		currentVisualizer = nil
	end
end

-- Repair Logic (G)
local function executeRepair()
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local buildingsFolder = workspace:FindFirstChild("Buildings")
	if rootPart and buildingsFolder and buildingRemotes then
		local repairRE = buildingRemotes:FindFirstChild("RepairBuildingRE")
		local nearestBuilding = nil
		local minDistance = math.huge
		for _, model in ipairs(buildingsFolder:GetChildren()) do
			if model:IsA("Model") then
				local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
				if primary then
					local dist = (primary.Position - rootPart.Position).Magnitude
					if dist < minDistance then
						minDistance = dist
						nearestBuilding = model
					end
				end
			end
		end
		if nearestBuilding and repairRE then
			repairRE:FireServer(nearestBuilding)
		end
	end
end

-- Input Listeners (PC Keybinds & Mobile Touch)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.P then toggleMelee()
	elseif input.KeyCode == Enum.KeyCode.O then toggleBlock()
	elseif input.KeyCode == Enum.KeyCode.M then toggleConstructUI()
	elseif input.KeyCode == Enum.KeyCode.G then
		setIndicator(repairHint, true)
		executeRepair()
		isRepairing = true
		task.spawn(function()
			while isRepairing do
				task.wait(0.3)
				if isRepairing then executeRepair() end
			end
		end)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and meleeToggled then
		isHoldingLMB = true
		lmbDownTime = tick()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.G then
		isRepairing = false
		setIndicator(repairHint, false)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and meleeToggled and isHoldingLMB then
		isHoldingLMB = false
		local holdDuration = tick() - lmbDownTime
		local character = player.Character
		local tool = getValidMeleeTool(character)
		local attackRE = remotesFolder and remotesFolder:FindFirstChild("AttackRE")
		local weaponUseEvent = remotesFolder and remotesFolder:FindFirstChild("WeaponUseEvent")
		
		if tool and attackRE then
			if weaponUseEvent then
				if weaponUseEvent:IsA("BindableEvent") then weaponUseEvent:Fire()
				elseif weaponUseEvent:IsA("RemoteEvent") then weaponUseEvent:FireServer(tool) end
			end
			if holdDuration >= 0.3 then
				attackRE:FireServer(3, tool)
				task.wait(0.15)
				local targetHum, hitPos = getNearestTarget(character)
				attackRE:FireServer(4, tool, targetHum, hitPos)
			else
				attackRE:FireServer(0, tool)
				task.wait(0.1)
				local targetHum, hitPos = getNearestTarget(character)
				attackRE:FireServer(1, tool, targetHum, hitPos)
			end
		end
	end
end)

-- Mobile Click Support on text hints
meleeHint.MouseButton1Click:Connect(toggleMelee)
blockHint.MouseButton1Click:Connect(toggleBlock)
constructHint.MouseButton1Click:Connect(toggleConstructUI)
repairHint.MouseButton1Click:Connect(executeRepair)

-- Visualizer Update Logic
idTextBox:GetPropertyChangedSignal("Text"):Connect(function()
	if currentVisualizer then
		currentVisualizer:Destroy()
		currentVisualizer = nil
	end
	local text = idTextBox.Text
	if text == "" then return end
	local val = tonumber(text)
	if val and idToRealNameMap[val] then
		local foundModel = findModelRecursive(ReplicatedStorage, idToRealNameMap[val])
		if foundModel then
			currentVisualizer = foundModel:Clone()
			for _, part in ipairs(currentVisualizer:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Material = Enum.Material.SmoothPlastic
					part.Transparency = 0.5
					part.CanCollide = false
					part.Anchored = true
					part.Color = Color3.fromRGB(75, 151, 75)
				end
			end
			currentVisualizer.Parent = workspace
		end
	end
	if not currentVisualizer then
		local fallback = Instance.new("Part")
		fallback.Size = Vector3.new(5, 1, 5)
		fallback.Transparency = 0.5
		fallback.Anchored = true
		fallback.CanCollide = false
		fallback.Material = Enum.Material.SmoothPlastic
		fallback.Color = Color3.fromRGB(75, 151, 75)
		fallback.Parent = workspace
		currentVisualizer = fallback
	end
end)

RunService.RenderStepped:Connect(function()
	if currentVisualizer then
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local targetPos = root.Position + root.CFrame.LookVector * 10
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {char, currentVisualizer}
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			local rayResult = workspace:Raycast(targetPos + Vector3.new(0, 25, 0), Vector3.new(0, -50, 0), rayParams)
			local finalPos = rayResult and rayResult.Position or targetPos
			local finalCFrame = CFrame.new(finalPos + Vector3.new(0, 0.5, 0), finalPos + root.CFrame.LookVector * Vector3.new(1, 0, 1))

			if currentVisualizer:IsA("Model") then
				currentVisualizer:PivotTo(finalCFrame)
			elseif currentVisualizer:IsA("BasePart") then
				currentVisualizer.CFrame = finalCFrame
			end
		end
	end
end)

-- Build Placement (CFrame first, then ID)
placeButton.MouseButton1Click:Connect(function()
	local val = tonumber(idTextBox.Text)
	if val and buildingRemotes then
		local placeRE = buildingRemotes:FindFirstChild("PlaceBuildingRE")
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if placeRE and root then
			local targetPos = root.Position + root.CFrame.LookVector * 10
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = {char}
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			local rayResult = workspace:Raycast(targetPos + Vector3.new(0, 25, 0), Vector3.new(0, -50, 0), rayParams)
			local finalCFrame = rayResult and CFrame.new(rayResult.Position, rayResult.Position + root.CFrame.LookVector * Vector3.new(1, 0, 1)) or (root.CFrame + root.CFrame.LookVector * 10)
			placeRE:FireServer(finalCFrame, val)
		end
	end
end)
