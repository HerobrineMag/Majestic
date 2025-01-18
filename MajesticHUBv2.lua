local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

local Window = Luna:CreateWindow({
	Name = "MajesticHUB",
	Subtitle = nil,
	LogoID = "82795327169782",
	LoadingEnabled = true,
	LoadingTitle = "Loaded MajesticHUB...",
	LoadingSubtitle = "by HerobrineMag",

	ConfigSettings = {
		RootFolder = nil, 
		ConfigFolder = "MajesticHUB"
	},

	KeySystem = false, 
	KeySettings = {
		Title = "MajesticHUB",
		Subtitle = "Key System",
		Note = "Welcome to MajesticHUB!",
		SaveInRoot = false, 
		SaveKey = true,
		Key = {"testkey"},
		SecondAction = {
			Enabled = true,
			Type = "Link",
			Parameter = ""
		}
	}
})
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "format_list_bulleted",
    ImageSource = "Material",
    ShowTitle = true
})

local Movement = Window:CreateTab({
    Name = "Movement",
    Icon = "directions_run",
    ImageSource = "Material",
    ShowTitle = true
})

local Visual = Window:CreateTab({
    Name = "Visual",
    Icon = "visibility_off",
    ImageSource = "Material",
    ShowTitle = true
})

local Combat = Window:CreateTab({
    Name = "Combat",
    Icon = "account_circle",
    ImageSource = "Material",
    ShowTitle = true
})

local DeathBallTab = Window:CreateTab({
    Name = "Death Ball",
    Icon = "sports_baseball",
    ImageSource = "Material",
    ShowTitle = true
})

local Button = MainTab:CreateButton({
	Name = "Infinite Yield",
	Description = nil, 
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

local Button = MainTab:CreateButton({
	Name = "Invisible",
	Description = nil, 
    Callback = function()
        loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
    end
})

Movement:CreateSection("Speed")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local speed = humanoid.WalkSpeed

local function updateSpeed(Value)
    speed = Value
end

local function onCharacterAdded(newCharacter)
    if newCharacter == player.Character then
        character = newCharacter
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = speed -- Применяем сохраненную скорость
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

Movement:CreateSlider({
    Name = "Speed",
	Range = {speed, 200},
	Increment = 1,
    CurrentValue = speed,
    Callback = function(Value)
        updateSpeed(Value)
    end	
}, "SpeedSlider")

game:GetService("RunService").Heartbeat:Connect(function()
    if humanoid and humanoid.MoveDirection.Magnitude > 0 then
        local direction = humanoid.MoveDirection.Unit
        local velocity = humanoidRootPart.Velocity
        humanoidRootPart.Velocity = Vector3.new(direction.X * speed, velocity.Y, direction.Z * speed)
    end
end)

local espEnabled = false
local highlightTable = {}
local espColor = Color3.fromRGB(0, 0, 0)

local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = espColor
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlightTable[character] = highlight
end

local function addESPToPlayer(player)
    if espEnabled then
        if player.Character then
            createHighlight(player.Character)
        end
        player.CharacterAdded:Connect(function(character)
            if espEnabled then
                createHighlight(character)
            end
        end)
    end
end

local function updateESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if espEnabled then
            addESPToPlayer(player)
        else
            if player.Character and highlightTable[player.Character] then
                highlightTable[player.Character]:Destroy()
                highlightTable[player.Character] = nil
            end
        end
    end
end

for _, player in pairs(game.Players:GetPlayers()) do
    addESPToPlayer(player)
end

game.Players.PlayerAdded:Connect(function(player)
    addESPToPlayer(player)
end)

Visual:CreateSection("ESP")

Visual:CreateToggle({
	Name = "Enable ESP",
	Description = nil,
	CurrentValue = false,
    	Callback = function(Value)
            espEnabled = Value
            updateESP()
    	end
}, "ESPToggle")

Visual:CreateColorPicker({
    Name = "ESP Color",
    Default = espColor,
	Color = Color3.fromRGB(255, 255, 255),
	Flag = "ColorPicker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
        espColor = Value
        for _, highlight in pairs(highlightTable) do
            if highlight then
                highlight.OutlineColor = espColor
            end
        end
    end
}, "ColorPicker")

Combat:CreateSection("AimBot")

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")

local aiming = false
local aimRadius = 100
local aimColor = Color3.fromRGB(255, 0, 0)
local aimSmoothness = 1
local aimbotEnabled = false
local mouse = player:GetMouse()

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Thickness = 2
circle.Color = aimColor
circle.Transparency = 1
circle.Filled = false
circle.Radius = aimRadius

-- Функция для поиска ближайшей головы
local function findNearestPlayerHeadInRadius(radius)
    local nearestHead = nil
    local nearestDistance = radius

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
            local distanceFromCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

            if distanceFromCenter <= radius and onScreen and distanceFromCenter < nearestDistance then
                nearestHead = head
                nearestDistance = distanceFromCenter
            end
        end
    end

    return nearestHead
end

-- Функция для наведения камеры на голову
local function aimAt(head)
    if head then
        local headPosition = head.Position
        local direction = (headPosition - camera.CFrame.Position).unit
        local targetCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / aimSmoothness)
    end
end

-- Переменные для хранения подключений
local aimConnection
local aimMouseDownConnection
local aimMouseUpConnection

-- Функция для активации аимбота
local function enableAimbot()
    circle.Visible = true
    aimMouseDownConnection = mouse.Button2Down:Connect(function()
        aiming = true
    end)
    aimMouseUpConnection = mouse.Button2Up:Connect(function()
        aiming = false
    end)

    aimConnection = runService.RenderStepped:Connect(function()
        local centerX = camera.ViewportSize.X / 2
        local centerY = camera.ViewportSize.Y / 2
        circle.Position = Vector2.new(centerX, centerY)
        circle.Radius = aimRadius
        circle.Color = aimColor

        if aiming then
            local targetHead = findNearestPlayerHeadInRadius(aimRadius)
            if targetHead then
                aimAt(targetHead)
            end
        end
    end)
end

-- Функция для деактивации аимбота
local function disableAimbot()
    aiming = false
    circle.Visible = false

    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end

    if aimMouseDownConnection then
        aimMouseDownConnection:Disconnect()
        aimMouseDownConnection = nil
    end

    if aimMouseUpConnection then
        aimMouseUpConnection:Disconnect()
        aimMouseUpConnection = nil
    end
end

-- Переключатель аимбота
Combat:CreateToggle({
	Name = "Enable Aimbot",
    Default = aimbotEnabled,
	Description = nil,
	CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
            if aimbotEnabled then
                enableAimbot()
            else
                disableAimbot()
            end
    end
}, "AimbotToggle")

Combat:CreateSlider({
    Name = "Aim Radius",
	Range = {0, 300}, -- The Minimum And Maximum Values Respectively
	Increment = 1,
    CurrentValue = aimRadius,
    Callback = function(Value)
        aimRadius = Value
    end
}, "RadiusSlider")

Combat:CreateColorPicker({
    Name = "Aim Color",
	Color = Color3.fromRGB(255, 0, 0),
	Flag = "ColorPicker1",
	Callback = function(Value)
        aimColor = Value
	end
}, "AimbotColorPicker") 

Combat:CreateSlider({
    Name = "Smooth Aim",
	Range = {1, 20}, -- The Minimum And Maximum Values Respectively
	Increment = 1,
	CurrentValue = aimSmoothness,
    Callback = function(Value)
        aimSmoothness = Value
    end
}, "SmoothSlider")

Luna:Notification({ 
	Title = "Loaded...",
    Icon = "done_outline",
	ImageSource = "Material",
	Content = "Welcome to MajesticHUB!"
})
