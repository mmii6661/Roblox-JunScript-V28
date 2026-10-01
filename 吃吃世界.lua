-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "吃吃世界",
    Text = "作者：苏\nQQ：2164591198"
})

local function safeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("加载失败: " .. url)
        return nil
    end
    return result
end

local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

if not Library then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "UI 库加载失败，请检查网络或脚本资源",
        Duration = 5,
    })
    return
end

local function Notify(msg)
    Library:Notify(msg, 3)
end

local actionSpeedActive = false
local eatMultiplyActive = false
local eatMultiplier = 2
local desiredWalkSpeed = 16

local SmoothFollowEnabled = false
local AimbotEnabled = false
local CrosshairEnabled = false
local CrosshairSpinEnabled = false
local AimbotRadius = math.floor(workspace.CurrentCamera.ViewportSize.Y / 3)
local predictionTime = 0
local aimSmoothness = 0.5

local lockTargetEnabled = false
local lockedPlayer = nil
local currentTarget = nil

local AimbotCircle = Instance.new("Frame")
AimbotCircle.Name = "AimbotCircle"
AimbotCircle.Parent = game:GetService("CoreGui")
AimbotCircle.Size = UDim2.new(0, AimbotRadius*2, 0, AimbotRadius*2)
AimbotCircle.Position = UDim2.new(0.5, -AimbotRadius, 0.5, -AimbotRadius)
AimbotCircle.BackgroundTransparency = 1
AimbotCircle.BorderSizePixel = 0
AimbotCircle.Visible = false
local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.new(1,1,1)
circleStroke.Thickness = 2
circleStroke.Parent = AimbotCircle
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1,0)
circleCorner.Parent = AimbotCircle

local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "CrosshairGui"
CrosshairGui.Parent = game.Players.LocalPlayer.PlayerGui
CrosshairGui.ResetOnSpawn = false
CrosshairGui.IgnoreGuiInset = true

local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Name = "Crosshair"
CrosshairFrame.Parent = CrosshairGui
CrosshairFrame.Size = UDim2.new(0, 30, 0, 30)
CrosshairFrame.Position = UDim2.new(0.5, -15, 0.5, -15)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false

local hLine = Instance.new("Frame")
hLine.Parent = CrosshairFrame
hLine.Size = UDim2.new(1, 0, 0, 2)
hLine.Position = UDim2.new(0, 0, 0.5, -1)
hLine.BackgroundColor3 = Color3.new(1,1,1)
hLine.BorderSizePixel = 0

local vLine = Instance.new("Frame")
vLine.Parent = CrosshairFrame
vLine.Size = UDim2.new(0, 2, 1, 0)
vLine.Position = UDim2.new(0.5, -1, 0, 0)
vLine.BackgroundColor3 = Color3.new(1,1,1)
vLine.BorderSizePixel = 0

local dot = Instance.new("Frame")
dot.Parent = CrosshairFrame
dot.Size = UDim2.new(0, 6, 0, 6)
dot.Position = UDim2.new(0.5, -3, 0.5, -3)
dot.BackgroundColor3 = Color3.new(1,1,1)
dot.BorderSizePixel = 0
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1,0)
dotCorner.Parent = dot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    if not SmoothFollowEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local nearest = nil
    local minDist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = p
            end
        end
    end
    if nearest then
        local targetRoot = nearest.Character.HumanoidRootPart
        local offset = targetRoot.CFrame.LookVector * -2.5
        myRoot.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
    end
end)

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then
        AimbotCircle.Visible = false
        currentTarget = nil
        return
    end
    AimbotCircle.Visible = true
    AimbotCircle.Size = UDim2.new(0, AimbotRadius*2, 0, AimbotRadius*2)
    AimbotCircle.Position = UDim2.new(0.5, -AimbotRadius, 0.5, -AimbotRadius)

    local camPos = Camera.CFrame.Position

    if lockTargetEnabled then
        if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = lockedPlayer.Character.HumanoidRootPart.Position
            local predictedPos = targetPos + lockedPlayer.Character.HumanoidRootPart.Velocity * predictionTime
            local dir = (predictedPos - camPos).Unit
            local lerpAlpha = 1 / (1 + aimSmoothness * 9)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + dir), lerpAlpha)
            return
        else
            lockedPlayer = nil
            lockTargetEnabled = false
            Notify("锁定目标已失效，锁定已解除")
        end
    end

    local closestDist = math.huge
    local closestPlayer = nil
    local closestVelocity = Vector3.zero
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local targetPos = char.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
            if onScreen then
                local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if distFromCenter <= AimbotRadius then
                    local realDist = (targetPos - camPos).Magnitude
                    if realDist < closestDist then
                        closestDist = realDist
                        closestPlayer = p
                        closestVelocity = char.HumanoidRootPart.Velocity
                    end
                end
            end
        end
    end
    currentTarget = closestPlayer
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = closestPlayer.Character.HumanoidRootPart.Position
        local predictedPos = targetPos + closestVelocity * predictionTime
        local dir = (predictedPos - camPos).Unit
        local lerpAlpha = 1 / (1 + aimSmoothness * 9)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + dir), lerpAlpha)
    end
end)

RunService.Heartbeat:Connect(function()
    if CrosshairEnabled and CrosshairSpinEnabled then
        CrosshairFrame.Rotation = (CrosshairFrame.Rotation + 1) % 360
    elseif CrosshairEnabled and not CrosshairSpinEnabled then
        CrosshairFrame.Rotation = 0
    end
    CrosshairFrame.Visible = CrosshairEnabled
end)

task.spawn(function()
    while true do
        if actionSpeedActive then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(3.0)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

local function hookEatEvents()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local function scanAndHook(container)
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("eat") or name:find("consume") or name:find("food") then
                    local oldFire = obj.FireServer
                    obj.FireServer = function(self, ...)
                        if eatMultiplyActive then
                            for i = 1, eatMultiplier do
                                oldFire(self, ...)
                                task.wait(0.05)
                            end
                            return
                        end
                        return oldFire(self, ...)
                    end
                end
            end
        end
    end
    scanAndHook(replicatedStorage)
    pcall(function()
        scanAndHook(game:GetService("ReplicatedFirst"))
        scanAndHook(workspace)
    end)
end
hookEatEvents()

local function loadFlightScript()
    local success, err = pcall(function()
        local main = Instance.new("ScreenGui")
        local Frame = Instance.new("Frame")
        local up = Instance.new("TextButton")
        local down = Instance.new("TextButton")
        local onof = Instance.new("TextButton")
        local TextLabel = Instance.new("TextLabel")
        local plus = Instance.new("TextButton")
        local speed = Instance.new("TextLabel")
        local mine = Instance.new("TextButton")
        local closebutton = Instance.new("TextButton")
        local mini = Instance.new("TextButton")
        local mini2 = Instance.new("TextButton")

        main.Name = "main"
        main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        main.ResetOnSpawn = false

        Frame.Parent = main
        Frame.BackgroundColor3 = Color3.fromRGB(163,255,137)
        Frame.BorderColor3 = Color3.fromRGB(103,221,213)
        Frame.Position = UDim2.new(0.100320168,0,0.379746825,0)
        Frame.Size = UDim2.new(0,190,0,57)

        up.Name = "up"
        up.Parent = Frame
        up.BackgroundColor3 = Color3.fromRGB(79,255,152)
        up.Size = UDim2.new(0,44,0,28)
        up.Font = Enum.Font.SourceSans
        up.Text = "上升"
        up.TextColor3 = Color3.fromRGB(0,0,0)
        up.TextSize = 14

        down.Name = "down"
        down.Parent = Frame
        down.BackgroundColor3 = Color3.fromRGB(215,255,121)
        down.Position = UDim2.new(0,0,0.491228074,0)
        down.Size = UDim2.new(0,44,0,28)
        down.Font = Enum.Font.SourceSans
        down.Text = "下落"
        down.TextColor3 = Color3.fromRGB(0,0,0)
        down.TextSize = 14

        onof.Name = "onof"
        onof.Parent = Frame
        onof.BackgroundColor3 = Color3.fromRGB(255,249,74)
        onof.Position = UDim2.new(0.702823281,0,0.491228074,0)
        onof.Size = UDim2.new(0,56,0,28)
        onof.Font = Enum.Font.SourceSans
        onof.Text = "飞"
        onof.TextColor3 = Color3.fromRGB(0,0,0)
        onof.TextSize = 14

        TextLabel.Parent = Frame
        TextLabel.BackgroundColor3 = Color3.fromRGB(242,60,255)
        TextLabel.Position = UDim2.new(0.469327301,0,0,0)
        TextLabel.Size = UDim2.new(0,100,0,28)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "恐拜大帝"
        TextLabel.TextColor3 = Color3.fromRGB(0,0,0)
        TextLabel.TextScaled = true
        TextLabel.TextSize = 14
        TextLabel.TextWrapped = true

        plus.Name = "plus"
        plus.Parent = Frame
        plus.BackgroundColor3 = Color3.fromRGB(133,145,255)
        plus.Position = UDim2.new(0.231578946,0,0,0)
        plus.Size = UDim2.new(0,45,0,28)
        plus.Font = Enum.Font.SourceSans
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(0,0,0)
        plus.TextScaled = true
        plus.TextSize = 14
        plus.TextWrapped = true

        speed.Name = "speed"
        speed.Parent = Frame
        speed.BackgroundColor3 = Color3.fromRGB(255,85,0)
        speed.Position = UDim2.new(0.468421042,0,0.491228074,0)
        speed.Size = UDim2.new(0,44,0,28)
        speed.Font = Enum.Font.SourceSans
        speed.Text = "1"
        speed.TextColor3 = Color3.fromRGB(0,0,0)
        speed.TextScaled = true
        speed.TextSize = 14
        speed.TextWrapped = true

        mine.Name = "mine"
        mine.Parent = Frame
        mine.BackgroundColor3 = Color3.fromRGB(123,255,247)
        mine.Position = UDim2.new(0.231578946,0,0.491228074,0)
        mine.Size = UDim2.new(0,45,0,29)
        mine.Font = Enum.Font.SourceSans
        mine.Text = "-"
        mine.TextColor3 = Color3.fromRGB(0,0,0)
        mine.TextScaled = true
        mine.TextSize = 14
        mine.TextWrapped = true

        closebutton.Name = "Close"
        closebutton.Parent = Frame
        closebutton.BackgroundColor3 = Color3.fromRGB(225,25,0)
        closebutton.Font = Enum.Font.SourceSans
        closebutton.Size = UDim2.new(0,45,0,28)
        closebutton.Text = "X"
        closebutton.TextSize = 30
        closebutton.Position = UDim2.new(0,0,-1,27)

        mini.Name = "minimize"
        mini.Parent = Frame
        mini.BackgroundColor3 = Color3.fromRGB(192,150,230)
        mini.Font = Enum.Font.SourceSans
        mini.Size = UDim2.new(0,45,0,28)
        mini.Text = "-"
        mini.TextSize = 40
        mini.Position = UDim2.new(0,44,-1,27)

        mini2.Name = "minimize2"
        mini2.Parent = Frame
        mini2.BackgroundColor3 = Color3.fromRGB(192,150,230)
        mini2.Font = Enum.Font.SourceSans
        mini2.Size = UDim2.new(0,45,0,28)
        mini2.Text = "+"
        mini2.TextSize = 40
        mini2.Position = UDim2.new(0,44,0,30)
        mini2.Visible = false

        local speeds = 1
        local speaker = game:GetService("Players").LocalPlayer
        local chr = game.Players.LocalPlayer.Character
        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
        local nowe = false

        Notify("飞行脚本已加载")

        Frame.Active = true
        Frame.Draggable = true

        closebutton.MouseButton1Click:Connect(function()
            main:Destroy()
        end)

        up.MouseButton1Click:Connect(function()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end)

        down.MouseButton1Click:Connect(function()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0, -3, 0)
            end
        end)

        mini.MouseButton1Click:Connect(function()
            up.Visible = false
            down.Visible = false
            onof.Visible = false
            plus.Visible = false
            speed.Visible = false
            mine.Visible = false
            closebutton.Visible = false
            mini.Visible = false
            mini2.Visible = true
            Frame.Size = UDim2.new(0, 100, 0, 28)
            TextLabel.Position = UDim2.new(0, 0, 0, 0)
        end)

        mini2.MouseButton1Click:Connect(function()
            up.Visible = true
            down.Visible = true
            onof.Visible = true
            plus.Visible = true
            speed.Visible = true
            mine.Visible = true
            closebutton.Visible = true
            mini.Visible = true
            mini2.Visible = false
            Frame.Size = UDim2.new(0, 190, 0, 57)
            TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
        end)

        plus.MouseButton1Click:Connect(function()
            speeds = speeds + 1
            speed.Text = tostring(speeds)
        end)

        mine.MouseButton1Click:Connect(function()
            if speeds > 1 then
                speeds = speeds - 1
                speed.Text = tostring(speeds)
            else
                speed.Text = "错误"
                task.wait(0.2)
                speed.Text = "1"
            end
        end)

        speaker.CharacterAdded:Connect(function(newChar)
            chr = newChar
            hum = chr:FindFirstChildOfClass("Humanoid")
        end)

        onof.MouseButton1Click:Connect(function()
            nowe = not nowe
            onof.Text = "飞"
            if nowe then
                if hum then
                    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                        hum:SetStateEnabled(state, false)
                    end
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                end
                if chr.Animate then
                    chr.Animate.Disabled = true
                end
                if hum then
                    for i, v in next, hum:GetPlayingAnimationTracks() do
                        v:AdjustSpeed(0)
                    end
                end
                task.spawn(function()
                    local runService = game:GetService("RunService")
                    while nowe and chr and hum do
                        runService.Heartbeat:Wait()
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection * speeds)
                        end
                    end
                end)
                if hum.RigType == Enum.HumanoidRigType.R6 then
                    local plr = game.Players.LocalPlayer
                    local torso = plr.Character.Torso
                    local bg = Instance.new("BodyGyro", torso)
                    bg.P = 9e4
                    bg.maxTorque = Vector3.new(9e9,9e9,9e9)
                    bg.CFrame = torso.CFrame
                    local bv = Instance.new("BodyVelocity", torso)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    if nowe then
                        plr.Character.Humanoid.PlatformStand = true
                    end
                    while nowe and plr.Character.Humanoid.Health > 0 do
                        game:GetService("RunService").RenderStepped:Wait()
                        bg.CFrame = workspace.CurrentCamera.CoordinateFrame
                    end
                    bg:Destroy()
                    bv:Destroy()
                    plr.Character.Humanoid.PlatformStand = false
                    plr.Character.Animate.Disabled = false
                else
                    local plr = game.Players.LocalPlayer
                    local UpperTorso = plr.Character.UpperTorso
                    local bg = Instance.new("BodyGyro", UpperTorso)
                    bg.P = 9e4
                    bg.maxTorque = Vector3.new(9e9,9e9,9e9)
                    bg.CFrame = UpperTorso.CFrame
                    local bv = Instance.new("BodyVelocity", UpperTorso)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    if nowe then
                        plr.Character.Humanoid.PlatformStand = true
                    end
                    while nowe and plr.Character.Humanoid.Health > 0 do
                        task.wait()
                        bg.CFrame = workspace.CurrentCamera.CoordinateFrame
                    end
                    bg:Destroy()
                    bv:Destroy()
                    plr.Character.Humanoid.PlatformStand = false
                    plr.Character.Animate.Disabled = false
                end
            else
                if hum then
                    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                        hum:SetStateEnabled(state, true)
                    end
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                if chr.Animate then
                    chr.Animate.Disabled = false
                end
            end
        end)
    end)
    if not success then
        Notify("飞行脚本加载失败："..tostring(err))
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= desiredWalkSpeed then
                humanoid.WalkSpeed = desiredWalkSpeed
            end
        end
    end
end)

local autoFarmEnabled = false
local autoSellEnabled = false
local turnEatEnabled = false
local grabDelay = 0.1
local eatDelay = 0.2
local loopDelay = 0.2
local stepDistance = 3
local stepDelay = 0.3
local sellAfterLoops = 5

local function autoFarmLoop()
    local player = game:GetService("Players").LocalPlayer
    local grabArgs = {false, false, false}
    local currentLoops = 0
    while autoFarmEnabled do
        local character = player.Character
        if character and character:FindFirstChild("Events") then
            local events = character.Events
            if events:FindFirstChild("Grab") then
                events.Grab:FireServer(unpack(grabArgs))
            end
            task.wait(grabDelay)
            if not autoFarmEnabled then break end
            if events:FindFirstChild("Eat") then
                for i = 1, 4 do
                    if not autoFarmEnabled then break end
                    events.Eat:FireServer()
                    task.wait(eatDelay)
                end
            end
            if not autoFarmEnabled then break end
            currentLoops = currentLoops + 1
            if autoSellEnabled and currentLoops >= sellAfterLoops then
                if events:FindFirstChild("Sell") then
                    events.Sell:FireServer()
                end
                currentLoops = 0
            end
            if not autoFarmEnabled then break end
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and rootPart then
                if turnEatEnabled then
                    local randomAngle = math.rad(math.random(-90, 90))
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, randomAngle, 0)
                end
                local forwardDirection = rootPart.CFrame.LookVector
                local targetPosition = rootPart.Position + (forwardDirection * stepDistance)
                humanoid:MoveTo(targetPosition)
                task.wait(stepDelay)
            end
        end
        task.wait(loopDelay)
    end
end

local Window = Library:CreateWindow({
    Title = "吃吃世界",
    Footer = "恐拜大帝 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("主要", "star"),
    Visual = Window:AddTab("视觉", "eye"),
    Other = Window:AddTab("其他", "settings"),
}

local LeftGroup = Tabs.Main:AddLeftGroupbox("功能控制")
local RightGroup = Tabs.Main:AddRightGroupbox("特殊功能")
local AutoGroup = Tabs.Main:AddLeftGroupbox("自动化挂机")

LeftGroup:AddToggle('ActionSpeed', {
    Text = '动作加速（吃东西/搬起）',
    Default = false,
    Callback = function(Value)
        actionSpeedActive = Value
        Notify("动作加速" .. (Value and "已开启" or "已关闭"))
    end
})

LeftGroup:AddToggle('EatMultiply', {
    Text = '吃一口长好几倍',
    Default = false,
    Callback = function(Value)
        eatMultiplyActive = Value
        Notify("吃倍数" .. (Value and "已开启" or "已关闭"))
    end
})

LeftGroup:AddSlider('EatMultiplier', {
    Text = '吃倍数',
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = " 倍",
    Callback = function(Value)
        eatMultiplier = Value
        if eatMultiplyActive then
            Notify("吃倍数已设为 " .. Value)
        end
    end
})

LeftGroup:AddSlider('WalkSpeed', {
    Text = '移动速度',
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        desiredWalkSpeed = Value
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = Value end
        end
        Notify("移动速度已设为 " .. Value)
    end
})

AutoGroup:AddToggle('AutoFarm', {
    Text = '自动挂机',
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            task.spawn(autoFarmLoop)
            Notify("自动挂机已开启")
        else
            Notify("自动挂机已关闭")
        end
    end
})

AutoGroup:AddToggle('AutoSell', {
    Text = '自动出售',
    Default = false,
    Callback = function(Value)
        autoSellEnabled = Value
        Notify("自动出售" .. (Value and "已开启" or "已关闭"))
    end
})

AutoGroup:AddToggle('TurnEat', {
    Text = '转弯吃',
    Default = false,
    Callback = function(Value)
        turnEatEnabled = Value
        Notify("转弯吃" .. (Value and "已开启" or "已关闭"))
    end
})

AutoGroup:AddSlider('GrabDelay', {
    Text = '抓取后等待',
    Default = 0.1,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Suffix = " 秒",
    Callback = function(Value)
        grabDelay = Value
    end
})

AutoGroup:AddSlider('EatDelay', {
    Text = '吃饭间隔',
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Suffix = " 秒",
    Callback = function(Value)
        eatDelay = Value
    end
})

AutoGroup:AddSlider('StepDistance', {
    Text = '移动距离',
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        stepDistance = Value
    end
})

AutoGroup:AddSlider('SellInterval', {
    Text = '出售间隔(轮)',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Suffix = " 轮",
    Callback = function(Value)
        sellAfterLoops = Value
    end
})

RightGroup:AddButton({
    Text = '召唤飞行脚本',
    Func = loadFlightScript,
    DoubleClick = false
})

local VisualLeft = Tabs.Visual:AddLeftGroupbox("自瞄设置")
local VisualRight = Tabs.Visual:AddRightGroupbox("其他视觉")

VisualLeft:AddToggle('Aimbot', {
    Text = '自瞄',
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
        if not Value then
            AimbotCircle.Visible = false
            currentTarget = nil
        end
        Notify("自瞄" .. (Value and "已开启" or "已关闭"))
    end
})

VisualLeft:AddSlider('AimbotRadius', {
    Text = '自瞄半径',
    Default = 100,
    Min = 50,
    Max = 400,
    Rounding = 0,
    Suffix = " px",
    Callback = function(Value)
        AimbotRadius = Value
    end
})

VisualLeft:AddSlider('Prediction', {
    Text = '预判强度',
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Suffix = " 秒",
    Callback = function(Value)
        predictionTime = Value
    end
})

VisualLeft:AddSlider('Smoothness', {
    Text = '平滑参数',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        aimSmoothness = Value
    end
})

VisualLeft:AddToggle('LockTarget', {
    Text = '锁定模式',
    Default = false,
    Callback = function(Value)
        lockTargetEnabled = Value
        if Value then
            if AimbotEnabled and currentTarget then
                lockedPlayer = currentTarget
                Notify("已锁定目标")
            else
                lockedPlayer = nil
                Notify("没有可锁定的目标")
            end
        else
            lockedPlayer = nil
            Notify("锁定已取消")
        end
    end
})

VisualRight:AddToggle('SmoothFollow', {
    Text = '平滑跟随',
    Default = false,
    Callback = function(Value)
        SmoothFollowEnabled = Value
        Notify("平滑跟随" .. (Value and "已开启" or "已关闭"))
    end
})

VisualRight:AddToggle('Crosshair', {
    Text = '准星',
    Default = false,
    Callback = function(Value)
        CrosshairEnabled = Value
        Notify("准星" .. (Value and "已显示" or "已隐藏"))
    end
})

VisualRight:AddToggle('CrosshairSpin', {
    Text = '准星旋转',
    Default = false,
    Callback = function(Value)
        CrosshairSpinEnabled = Value
        if CrosshairEnabled then
            CrosshairFrame.Rotation = 0
        end
        Notify("准星旋转" .. (Value and "已开启" or "已关闭"))
    end
})

local OtherLeft = Tabs.Other:AddLeftGroupbox("杂项")
OtherLeft:AddLabel("作者：恐拜大帝")
OtherLeft:AddLabel("QQ：3999698324", true)
OtherLeft:AddButton({
    Text = '卸载脚本',
    Func = function() Library:Unload() end
})

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("ChiChiWorld")
    ThemeManager:ApplyToTab(Tabs.Other)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("ChiChiWorldConfig")
    SaveManager:BuildConfigSection(Tabs.Other)
end

Notify("吃吃世界脚本已加载")
