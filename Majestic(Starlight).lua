-- MajesticHUB (Starlight)
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Window = Starlight:CreateWindow({
    Name = "MajesticHUB",
    Subtitle = "by HerobrineMag",
    Icon = 82795327169782,

    LoadingSettings = {
        Title = "MajesticHUB",
        Subtitle = "Loaded successfully",
    },

    FileSettings = {
        ConfigFolder = "MajesticHUB"
    },
})

-- ==================== TABS ====================
local MainSection = Window:CreateTabSection("Main")
local VisualSection = Window:CreateTabSection("Visuals")
local CombatSection = Window:CreateTabSection("Combat")

local MainTab = MainSection:CreateTab({
    Name = "Main",
    Icon = NebulaIcons:GetIcon("format_list_bulleted", "Material"),
    Columns = 1,
}, "MainTab")

local MovementTab = MainSection:CreateTab({
    Name = "Movement",
    Icon = NebulaIcons:GetIcon("directions_run", "Material"),
    Columns = 1,
}, "MovementTab")

local VisualTab = VisualSection:CreateTab({
    Name = "ESP",
    Icon = NebulaIcons:GetIcon("visibility", "Material"),
    Columns = 2,
}, "VisualTab")

local CombatTab = CombatSection:CreateTab({
    Name = "Aimbot",
    Icon = NebulaIcons:GetIcon("gps_fixed", "Material"),
    Columns = 2,
}, "CombatTab")

-- ==================== MAIN ====================
local MainGroup = MainTab:CreateGroupbox({
    Name = "Scripts",
    Column = 1,
}, "MainGroup")

MainGroup:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
}, "IYButton")

MainGroup:CreateButton({
    Name = "Invisible",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/3Rnd9rHf"))()
    end,
}, "InvisibleButton")

MainGroup:CreateButton({
    Name = "AntiAFK",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KazeOnTop/Rice-Anti-Afk/main/Wind", true))()
    end,
}, "AntiAFKButton")

-- ==================== MOVEMENT ====================
local MovementGroup = MovementTab:CreateGroupbox({
    Name = "Speed",
    Column = 1,
}, "MovementGroup")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local speed = humanoid.WalkSpeed

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speed
end
player.CharacterAdded:Connect(onCharacterAdded)

MovementGroup:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = speed,
    Callback = function(Value)
        speed = Value
    end,
}, "SpeedSlider")

game:GetService("RunService").Heartbeat:Connect(function()
    if humanoid and humanoid.MoveDirection.Magnitude > 0 and humanoidRootPart then
        local direction = humanoid.MoveDirection.Unit
        local velocity = humanoidRootPart.Velocity
        humanoidRootPart.Velocity = Vector3.new(direction.X * speed, velocity.Y, direction.Z * speed)
    end
end)

-- ==================== TEAM CHECK ====================
local ignoreTeammates = false

local function isTeammate(otherPlayer)
    local localPlayer = game.Players.LocalPlayer
    if not otherPlayer or otherPlayer == localPlayer then return true end

    if localPlayer.Team and otherPlayer.Team then
        return localPlayer.Team == otherPlayer.Team
    end
    if localPlayer.TeamColor and otherPlayer.TeamColor then
        return localPlayer.TeamColor == otherPlayer.TeamColor
    end
    return false
end

-- ==================== ESP + SKELETON + BOTS ====================
local espType = "None" -- "None", "Chams", "Skeleton"
local highlightTable = {}
local skeletonTable = {}

local chamsOutlineColor = Color3.fromRGB(255, 0, 0)
local chamsFillColor = Color3.fromRGB(255, 0, 0)
local chamsFillTransparency = 0.6

local skeletonColor = Color3.fromRGB(0, 255, 0)
local skeletonThickness = 1.5

local R15_BONES = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local R6_BONES = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local function createHighlight(char)
    if not char or highlightTable[char] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "MajesticESP"
    highlight.Parent = char
    highlight.FillTransparency = chamsFillTransparency
    highlight.FillColor = chamsFillColor
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = chamsOutlineColor
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlightTable[char] = highlight
end

local function removeHighlight(char)
    if highlightTable[char] then
        highlightTable[char]:Destroy()
        highlightTable[char] = nil
    end
end

local function createSkeleton(char)
    if not char or skeletonTable[char] then return end

    local lines = {}
    local headCircle = Drawing.new("Circle")
    headCircle.Visible = false
    headCircle.Thickness = skeletonThickness
    headCircle.Color = skeletonColor
    headCircle.Filled = false
    headCircle.NumSides = 16
    headCircle.Radius = 4

    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local bones = isR15 and R15_BONES or R6_BONES

    for _ = 1, #bones do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = skeletonThickness
        line.Color = skeletonColor
        table.insert(lines, line)
    end

    skeletonTable[char] = {
        lines = lines,
        head = headCircle,
        bones = bones,
        isR15 = isR15
    }
end

local function removeSkeleton(char)
    local data = skeletonTable[char]
    if data then
        for _, line in ipairs(data.lines) do
            line:Remove()
        end
        data.head:Remove()
        skeletonTable[char] = nil
    end
end

local function updateSkeleton(char)
    local data = skeletonTable[char]
    if not data then return end

    local cam = workspace.CurrentCamera
    local bones = data.bones

    local head = char:FindFirstChild("Head")
    if head then
        local pos, onScreen = cam:WorldToViewportPoint(head.Position)
        if onScreen and pos.Z > 0 then
            local top = cam:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y * 0.5, 0))
            local bottom = cam:WorldToViewportPoint(head.Position - Vector3.new(0, head.Size.Y * 0.5, 0))
            local radius = math.abs(top.Y - bottom.Y) * 0.55

            data.head.Position = Vector2.new(pos.X, pos.Y)
            data.head.Radius = math.clamp(radius, 2, 30)
            data.head.Color = skeletonColor
            data.head.Thickness = skeletonThickness
            data.head.Visible = true
        else
            data.head.Visible = false
        end
    else
        data.head.Visible = false
    end

    for i, bonePair in ipairs(bones) do
        local line = data.lines[i]
        local part0 = char:FindFirstChild(bonePair[1])
        local part1 = char:FindFirstChild(bonePair[2])

        if part0 and part1 then
            local pos0, on0 = cam:WorldToViewportPoint(part0.Position)
            local pos1, on1 = cam:WorldToViewportPoint(part1.Position)

            if (on0 or on1) and pos0.Z > 0 and pos1.Z > 0 then
                line.From = Vector2.new(pos0.X, pos0.Y)
                line.To = Vector2.new(pos1.X, pos1.Y)
                line.Color = skeletonColor
                line.Thickness = skeletonThickness
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

-- Проверка: является ли объект ботом / NPC
local function isBotCharacter(char)
    if not char or not char:FindFirstChildOfClass("Humanoid") then return false end
    if char == player.Character then return false end

    local plr = game.Players:GetPlayerFromCharacter(char)
    if plr then
        -- Если это игрок с FollowUserId == 0 — считаем ботом
        if plr.FollowUserId == 0 then
            return true
        end
        return false -- обычный игрок
    end

    -- Нет игрока = NPC/бот
    return true
end

local function shouldShowESP(charOrPlayer)
    if typeof(charOrPlayer) == "Instance" and charOrPlayer:IsA("Model") then
        -- Это персонаж (бот/NPC)
        if charOrPlayer == player.Character then return false end
        return true
    end

    -- Это Player
    local otherPlayer = charOrPlayer
    if not otherPlayer or otherPlayer == player then return false end
    if ignoreTeammates and isTeammate(otherPlayer) then return false end
    return true
end

local function refreshCharacterESP(char)
    if not char or not char.Parent then return end

    if shouldShowESP(char) or isBotCharacter(char) then
        if espType == "Chams" then
            createHighlight(char)
            removeSkeleton(char)
        elseif espType == "Skeleton" then
            removeHighlight(char)
            createSkeleton(char)
        else
            removeHighlight(char)
            removeSkeleton(char)
        end
    else
        removeHighlight(char)
        removeSkeleton(char)
    end
end

local function updateAllESP()
    -- Обычные игроки
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            refreshCharacterESP(plr.Character)
        end
    end

    -- Боты / NPC (ищем по Workspace)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("Head") then
            if isBotCharacter(obj) then
                refreshCharacterESP(obj)
            end
        end
    end
end

local function onPlayerAdded(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.35)
        if plr.Character then
            refreshCharacterESP(plr.Character)
        end
    end)
    if plr.Character then
        refreshCharacterESP(plr.Character)
    end
end

for _, plr in ipairs(game.Players:GetPlayers()) do
    if plr ~= player then
        onPlayerAdded(plr)
    end
end
game.Players.PlayerAdded:Connect(onPlayerAdded)

game.Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        removeHighlight(plr.Character)
        removeSkeleton(plr.Character)
    end
end)

-- Периодически ищем новых ботов
task.spawn(function()
    while true do
        task.wait(2)
        if espType ~= "None" then
            updateAllESP()
        end
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if espType ~= "Skeleton" then return end
    for char, data in pairs(skeletonTable) do
        if char and char.Parent and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            updateSkeleton(char)
        else
            removeSkeleton(char)
        end
    end
end)

-- UI Visual
local ESPGroup = VisualTab:CreateGroupbox({
    Name = "ESP",
    Column = 1,
}, "ESPGroup")

local ESPTypeLabel = ESPGroup:CreateLabel({
    Name = "ESP Type",
}, "ESPTypeLabel")

ESPTypeLabel:AddDropdown({
    Options = {"None", "Chams", "Skeleton"},
    CurrentOption = "None",
    Callback = function(Value)
        local selected = typeof(Value) == "table" and Value[1] or Value
        espType = selected or "None"

        for char, _ in pairs(highlightTable) do
            removeHighlight(char)
        end
        for char, _ in pairs(skeletonTable) do
            removeSkeleton(char)
        end

        updateAllESP()
    end,
}, "ESPTypeDropdown")

local ChamsOutlineLabel = ESPGroup:CreateLabel({
    Name = "Chams Outline",
}, "ChamsOutlineLabel")
ChamsOutlineLabel:AddColorPicker({
    CurrentValue = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        chamsOutlineColor = Color
        for _, hl in pairs(highlightTable) do
            if hl then hl.OutlineColor = Color end
        end
    end,
}, "ChamsOutlinePicker")

local ChamsFillLabel = ESPGroup:CreateLabel({
    Name = "Chams Fill",
}, "ChamsFillLabel")
ChamsFillLabel:AddColorPicker({
    CurrentValue = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        chamsFillColor = Color
        for _, hl in pairs(highlightTable) do
            if hl then hl.FillColor = Color end
        end
    end,
}, "ChamsFillPicker")

ESPGroup:CreateSlider({
    Name = "Fill Transparency",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.6,
    Callback = function(Value)
        chamsFillTransparency = Value
        for _, hl in pairs(highlightTable) do
            if hl then hl.FillTransparency = Value end
        end
    end,
}, "FillTransparencySlider")

local SkeletonGroup = VisualTab:CreateGroupbox({
    Name = "Skeleton",
    Column = 2,
}, "SkeletonGroup")

SkeletonGroup:CreateSlider({
    Name = "Thickness",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = 1.5,
    Callback = function(Value)
        skeletonThickness = Value
    end,
}, "SkeletonThickness")

local SkeletonColorLabel = SkeletonGroup:CreateLabel({
    Name = "Skeleton Color",
}, "SkeletonColorLabel")
SkeletonColorLabel:AddColorPicker({
    CurrentValue = Color3.fromRGB(0, 255, 0),
    Callback = function(Color)
        skeletonColor = Color
    end,
}, "SkeletonColorPicker")

-- ==================== AIMBOT + TRACER (рабочая логика) ====================
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local mouse = player:GetMouse()
local Players = game:GetService("Players")

local aiming = false
local aimRadius = 100
local aimColor = Color3.fromRGB(255, 0, 0)
local aimSmoothness = 1
local aimbotEnabled = false
local aimCircleThickness = 2
local wallCheck = false

local tracerEnabled = false
local tracerColor = Color3.fromRGB(255, 50, 50)
local tracerThickness = 1.5

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Thickness = 2
circle.Color = aimColor
circle.Transparency = 1
circle.Filled = false
circle.Radius = aimRadius

local tracerLine = Drawing.new("Line")
tracerLine.Visible = false
tracerLine.Thickness = tracerThickness
tracerLine.Color = tracerColor

local function findNearestPlayerHeadInRadius(radius)
    local nearestHead = nil
    local nearestDistance = radius

    -- Игроки
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            if ignoreTeammates and isTeammate(otherPlayer) then
                continue
            end

            local head = otherPlayer.Character.Head

            if wallCheck then
                local origin = camera.CFrame.Position
                local direction = (head.Position - origin)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {player.Character, camera}
                local result = workspace:Raycast(origin, direction.Unit * direction.Magnitude, rayParams)

                if result then
                    local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                    local hitPlayer = hitChar and Players:GetPlayerFromCharacter(hitChar)
                    if not (hitPlayer and hitPlayer ~= player) then
                        continue
                    end
                end
            end

            local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
            local distanceFromCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

            if distanceFromCenter <= radius and onScreen and distanceFromCenter < nearestDistance then
                nearestHead = head
                nearestDistance = distanceFromCenter
            end
        end
    end

    -- Боты / NPC
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and isBotCharacter(obj) and obj:FindFirstChild("Head") then
            local head = obj.Head
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if wallCheck then
                    local origin = camera.CFrame.Position
                    local direction = (head.Position - origin)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {player.Character, camera}
                    local result = workspace:Raycast(origin, direction.Unit * direction.Magnitude, rayParams)

                    if result then
                        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                        if hitChar ~= obj then
                            continue
                        end
                    end
                end

                local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                local distanceFromCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

                if distanceFromCenter <= radius and onScreen and distanceFromCenter < nearestDistance then
                    nearestHead = head
                    nearestDistance = distanceFromCenter
                end
            end
        end
    end

    return nearestHead
end

local function aimAt(head)
    if head then
        local headPosition = head.Position
        local direction = (headPosition - camera.CFrame.Position).unit
        local targetCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / aimSmoothness)
    end
end

local aimConnection
local aimMouseDownConnection
local aimMouseUpConnection

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
        circle.Thickness = aimCircleThickness

        local targetHead = nil
        if aiming then
            targetHead = findNearestPlayerHeadInRadius(aimRadius)
            if targetHead then
                aimAt(targetHead)
            end
        else
            targetHead = findNearestPlayerHeadInRadius(aimRadius)
        end

        if tracerEnabled and targetHead then
            local pos, onScreen = camera:WorldToViewportPoint(targetHead.Position)
            if onScreen then
                tracerLine.From = Vector2.new(centerX, centerY)
                tracerLine.To = Vector2.new(pos.X, pos.Y)
                tracerLine.Color = tracerColor
                tracerLine.Thickness = tracerThickness
                tracerLine.Visible = true
            else
                tracerLine.Visible = false
            end
        else
            tracerLine.Visible = false
        end
    end)
end

local function disableAimbot()
    aiming = false
    circle.Visible = false
    tracerLine.Visible = false

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

-- UI Combat
local AimbotGroup = CombatTab:CreateGroupbox({
    Name = "Aimbot",
    Column = 1,
}, "AimbotGroup")

local TracerGroup = CombatTab:CreateGroupbox({
    Name = "Tracer",
    Column = 2,
}, "TracerGroup")

AimbotGroup:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            enableAimbot()
        else
            disableAimbot()
        end
    end,
}, "AimbotToggle")

AimbotGroup:CreateToggle({
    Name = "WallCheck",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        wallCheck = Value
    end,
}, "WallCheckToggle")

AimbotGroup:CreateToggle({
    Name = "TeamCheck",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        ignoreTeammates = Value
        updateAllESP()
    end,
}, "TeamCheckToggle")

AimbotGroup:CreateSlider({
    Name = "FOV Radius",
    Range = {20, 400},
    Increment = 1,
    CurrentValue = aimRadius,
    Callback = function(Value)
        aimRadius = Value
    end,
}, "RadiusSlider")

AimbotGroup:CreateSlider({
    Name = "FOV Thickness",
    Range = {1, 6},
    Increment = 0.1,
    CurrentValue = 2,
    Callback = function(Value)
        aimCircleThickness = Value
        circle.Thickness = Value
    end,
}, "FOVThicknessSlider")

AimbotGroup:CreateSlider({
    Name = "Smoothness",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = aimSmoothness,
    Callback = function(Value)
        aimSmoothness = Value
    end,
}, "SmoothSlider")

local AimColorLabel = AimbotGroup:CreateLabel({
    Name = "FOV Color",
}, "AimColorLabel")
AimColorLabel:AddColorPicker({
    CurrentValue = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        aimColor = Color
    end,
}, "AimColorPicker")

TracerGroup:CreateToggle({
    Name = "Enable Tracer",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        tracerEnabled = Value
        if not Value then
            tracerLine.Visible = false
        end
    end,
}, "TracerToggle")

TracerGroup:CreateSlider({
    Name = "Thickness",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = 1.5,
    Callback = function(Value)
        tracerThickness = Value
    end,
}, "TracerThickness")

local TracerColorLabel = TracerGroup:CreateLabel({
    Name = "Tracer Color",
}, "TracerColorLabel")
TracerColorLabel:AddColorPicker({
    CurrentValue = Color3.fromRGB(255, 50, 50),
    Callback = function(Color)
        tracerColor = Color
    end,
}, "TracerColorPicker")

Starlight:Notification({
    Title = "MajesticHUB",
    Icon = NebulaIcons:GetIcon("sparkle", "Material"),
    Content = "Welcome! Script loaded successfully.",
}, "LoadNotification")
