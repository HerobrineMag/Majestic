local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "MajesticHUB", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "MajesticHUBv1"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    PremiumOnly = false
})


local SpeedTab = Window:MakeTab({
    Name = "SpeedHack",
    PremiumOnly = false
})

local ESPTab = Window:MakeTab({
    Name = "ESP",
    PremiumOnly = false
})

local AimbotTab = Window:MakeTab({
    Name = "AimBot",
    PremiumOnly = false
})

local DeathBallTab = Window:MakeTab({
    Name = "Death Ball",
    PremiumOnly = false
})

MainTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local speed = humanoid.WalkSpeed

local function updateSpeed(value)
    speed = value
end

SpeedTab:AddSlider({
    Name = "Speed",
    Min = humanoid.WalkSpeed,
    Max = 300,
    Increment = 1,
    Color = Color3.fromRGB(0,255,0),
    ValueName = " px",
    Default = humanoid.WalkSpeed,
    Callback = function(Value)
        updateSpeed(Value)
    end	
})



game:GetService("RunService").Heartbeat:Connect(function()
    if humanoid.MoveDirection.Magnitude > 0 then
        local direction = humanoid.MoveDirection.Unit
        local velocity = humanoidRootPart.Velocity
        humanoidRootPart.Velocity = Vector3.new(direction.X * speed, velocity.Y, direction.Z * speed)
    end
end)

local espEnabled = false
local highlightTable = {}
local espColor = Color3.fromRGB(255, 255, 255)

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

ESPTab:AddToggle({
	Name = "Enable ESP",
	Default = false,
    Callback = function(Value)
        espEnabled = Value
        updateESP()
    end
})

ESPTab:AddColorpicker({
    Name = "ESP Color",
    Default = espColor,
	Callback = function(Value)
        espColor = Value
        for _, highlight in pairs(highlightTable) do
            if highlight then
                highlight.OutlineColor = espColor
            end
        end
    end
})


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
AimbotTab:AddToggle({
    Name = "Enable Aimbot",
    Default = aimbotEnabled,
    Callback = function(Value)
        aimbotEnabled = Value
        if aimbotEnabled then
            enableAimbot()
        else
            disableAimbot()
        end
    end
})

AimbotTab:AddSlider({
    Name = "Aim Radius",
	Nim = 0,
    Max = 300,
	Increment = 1,
    Default = aimRadius,
    ValueName = " ",
    	Callback = function(Value)
            aimRadius = Value
    	end
})

AimbotTab:AddColorpicker({
    Name = "Aim Color",
	Color = Color3.fromRGB(255, 0, 0),
    Default = aimColor,
	Flag = "ColorPicker1",
	Callback = function(Value)
        aimColor = Value
	end
}) 

AimbotTab:AddSlider({
    Name = "Smooth Aim",
	Min = 0, 
    Max = 20, -- The Minimum And Maximum Values Respectively
	Increment = 1,
    Default = aimSmoothness, -- Basically The Changing Value/Rounding Off
	CurrentValue = 0,
    	Callback = function(Value)
            aimSmoothness = Value
    	end
})

OrionLib:MakeNotification({ 
	Name  = "MajesticHUB Loaded",
	Image = "rbxassetid://4483362458",
	Content = "Welcome to MajesticHUB!",
    Time = 3
})

OrionLib:Init()
