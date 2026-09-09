local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "MajesticHUB",
    SubTitle = "by HerobrineMag",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "user" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ===================== MAIN =====================
Tabs.Main:AddButton({
    Title = "Infinite Yield",
    Description = "Load Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

Tabs.Main:AddButton({
    Title = "Invisible",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/3Rnd9rHf"))()
    end
})

Tabs.Main:AddButton({
    Title = "AntiAFK",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KazeOnTop/Rice-Anti-Afk/main/Wind", true))()
    end
})

-- ===================== MOVEMENT =====================
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local speed = humanoid.WalkSpeed

local function updateSpeed(Value)
    speed = Value
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speed
end)

Tabs.Movement:AddSlider("Speed", {
    Title = "Speed",
    Default = speed,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        updateSpeed(Value)
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if humanoid and humanoid.MoveDirection.Magnitude > 0 then
        local direction = humanoid.MoveDirection.Unit
        local velocity = humanoidRootPart.Velocity
        humanoidRootPart.Velocity = Vector3.new(direction.X * speed, velocity.Y, direction.Z * speed)
    end
end)

-- ===================== VISUAL (ESP) =====================
local espEnabled = false
local highlightTable = {}
local espColor = Color3.fromRGB(255, 255, 255)

local function createHighlight(char)
    local highlight = Instance.new("Highlight")
    highlight.Parent = char
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = espColor
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlightTable[char] = highlight
end

local function addESPToPlayer(plr)
    if espEnabled then
        if plr.Character then createHighlight(plr.Character) end
        plr.CharacterAdded:Connect(function(char)
            if espEnabled then createHighlight(char) end
        end)
    end
end

local function updateESP()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if espEnabled then
            addESPToPlayer(plr)
        else
            if plr.Character and highlightTable[plr.Character] then
                highlightTable[plr.Character]:Destroy()
                highlightTable[plr.Character] = nil
            end
        end
    end
end

for _, plr in pairs(game.Players:GetPlayers()) do addESPToPlayer(plr) end
game.Players.PlayerAdded:Connect(addESPToPlayer)

Tabs.Visual:AddToggle("ESPToggle", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        updateESP()
    end
})

Tabs.Visual:AddColorpicker("ESPColor", {
    Title = "ESP Color",
    Default = espColor,
    Callback = function(Value)
        espColor = Value
        for _, hl in pairs(highlightTable) do
            if hl then hl.OutlineColor = espColor end
        end
    end
})

-- ===================== COMBAT (AIMBOT) =====================
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local mouse = player:GetMouse()

local aiming = false
local aimRadius = 100
local aimColor = Color3.fromRGB(255, 0, 0)
local aimSmoothness = 1
local aimbotEnabled = false
local ignoreTeammates = false

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Thickness = 2
circle.Color = aimColor
circle.Transparency = 1
circle.Filled = false
circle.Radius = aimRadius

local function isTeammate(other)
    return player.Team and player.Team == other.Team
end

local function findNearestPlayerHeadInRadius(radius)
    local nearestHead, nearestDistance = nil, radius
    for _, other in pairs(game.Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("Head") then
            if ignoreTeammates and isTeammate(other) then continue end
            local head = other.Character.Head
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
            if dist <= radius and onScreen and dist < nearestDistance then
                nearestHead = head
                nearestDistance = dist
            end
        end
    end
    return nearestHead
end

local function aimAt(head)
    if head then
        local dir = (head.Position - camera.CFrame.Position).Unit
        local target = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + dir)
        camera.CFrame = camera.CFrame:Lerp(target, 1 / aimSmoothness)
    end
end

local aimConnection, aimMouseDown, aimMouseUp

local function enableAimbot()
    circle.Visible = true
    aimMouseDown = mouse.Button2Down:Connect(function() aiming = true end)
    aimMouseUp = mouse.Button2Up:Connect(function() aiming = false end)
    aimConnection = runService.RenderStepped:Connect(function()
        local cx, cy = camera.ViewportSize.X/2, camera.ViewportSize.Y/2
        circle.Position = Vector2.new(cx, cy)
        circle.Radius = aimRadius
        circle.Color = aimColor
        if aiming then
            local target = findNearestPlayerHeadInRadius(aimRadius)
            if target then aimAt(target) end
        end
    end)
end

local function disableAimbot()
    aiming = false
    circle.Visible = false
    if aimConnection then aimConnection:Disconnect() end
    if aimMouseDown then aimMouseDown:Disconnect() end
    if aimMouseUp then aimMouseUp:Disconnect() end
end

Tabs.Combat:AddToggle("Aimbot", {
    Title = "Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then enableAimbot() else disableAimbot() end
    end
})

Tabs.Combat:AddSlider("Radius", {
    Title = "Radius",
    Default = 100,
    Min = 0,
    Max = 300,
    Rounding = 1,
    Callback = function(Value) aimRadius = Value end
})

Tabs.Combat:AddColorpicker("AimColor", {
    Title = "Aim Color",
    Default = aimColor,
    Callback = function(Value) aimColor = Value end
})

Tabs.Combat:AddSlider("Smooth", {
    Title = "Smooth",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(Value) aimSmoothness = Value end
})

Tabs.Combat:AddToggle("TeamCheck", {
    Title = "Team Check",
    Default = false,
    Callback = function(Value) ignoreTeammates = Value end
})

-- Managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("MajesticHUB")
SaveManager:SetFolder("MajesticHUB")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "MajesticHUB", Content = "Loaded successfully!", Duration = 5 })
