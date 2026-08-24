-- ========== 卡密验证系统 ==========
local httpService = game:GetService("HttpService")
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ========== 卡密配置 ==========
-- 在这里设置你的卡密列表（可以添加多个）
local validKeys = {
    ["VIP666"] = true,
    ["TEST123"] = true,
    ["FREE2024"] = true,
    ["ADMIN001"] = true
}

-- 也可以从远程服务器验证（推荐）
-- 设置远程验证地址（可选）
local VERIFY_URL = ""  -- 留空则使用本地验证

-- ========== 验证函数 ==========
local function verifyKey(key)
    key = tostring(key):gsub("%s+", "")  -- 去除空格
    
    -- 本地验证
    if validKeys[key] then
        return true
    end
    
    -- 远程验证（如果设置了URL）
    if VERIFY_URL ~= "" then
        local success, result = pcall(function()
            local response = httpService:PostAsync(VERIFY_URL, httpService:JSONEncode({
                key = key,
                username = player.Name,
                userId = player.UserId
            }), Enum.HttpContentType.ApplicationJson)
            local data = httpService:JSONDecode(response)
            return data.success == true
        end)
        if success and result then
            return true
        end
    end
    
    return false
end

-- ========== 创建验证界面 ==========
local verifyGui = Instance.new("ScreenGui")
verifyGui.Name = "VerifySystem"
verifyGui.ResetOnSpawn = false
verifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
verifyGui.Parent = CoreGui

-- 遮罩层
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.6
overlay.Parent = verifyGui

-- 验证窗口
local verifyPanel = Instance.new("Frame")
verifyPanel.Size = UDim2.new(0, 320, 0, 270)
verifyPanel.Position = UDim2.new(0.5, -160, 0.5, -135)
verifyPanel.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
verifyPanel.BorderSizePixel = 0
verifyPanel.Parent = verifyGui
local vpCorner = Instance.new("UICorner")
vpCorner.CornerRadius = UDim.new(0, 16)
vpCorner.Parent = verifyPanel

-- 标题
local verifyTitle = Instance.new("TextLabel")
verifyTitle.Size = UDim2.new(1, 0, 0, 50)
verifyTitle.Position = UDim2.new(0, 0, 0, 15)
verifyTitle.BackgroundTransparency = 1
verifyTitle.Text = "🔐 卡密验证"
verifyTitle.TextColor3 = Color3.new(1, 1, 1)
verifyTitle.TextSize = 24
verifyTitle.Font = Enum.Font.GothamBold
verifyTitle.Parent = verifyPanel

-- 提示文字
local tipText = Instance.new("TextLabel")
tipText.Size = UDim2.new(1, -40, 0, 30)
tipText.Position = UDim2.new(0, 20, 0, 65)
tipText.BackgroundTransparency = 1
tipText.Text = "请输入卡密解锁脚本"
tipText.TextColor3 = Color3.fromRGB(180, 170, 210)
tipText.TextSize = 14
tipText.Font = Enum.Font.Gotham
tipText.Parent = verifyPanel

-- 输入框
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0, 260, 0, 45)
keyBox.Position = UDim2.new(0.5, -130, 0, 100)
keyBox.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
keyBox.Text = ""
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.TextSize = 18
keyBox.Font = Enum.Font.GothamBold
keyBox.PlaceholderText = "输入卡密..."
keyBox.PlaceholderColor3 = Color3.fromRGB(120, 110, 150)
keyBox.ClearTextOnFocus = false
keyBox.Parent = verifyPanel
local kbCorner = Instance.new("UICorner")
kbCorner.CornerRadius = UDim.new(0, 10)
kbCorner.Parent = keyBox

-- 状态提示
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -40, 0, 25)
statusText.Position = UDim2.new(0, 20, 0, 152)
statusText.BackgroundTransparency = 1
statusText.Text = ""
statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
statusText.TextSize = 13
statusText.Font = Enum.Font.Gotham
statusText.Parent = verifyPanel

-- 验证按钮
local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0, 260, 0, 45)
verifyBtn.Position = UDim2.new(0.5, -130, 0, 185)
verifyBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
verifyBtn.Text = "✅ 验证"
verifyBtn.TextColor3 = Color3.new(1, 1, 1)
verifyBtn.TextSize = 18
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.Parent = verifyPanel
local vbCorner = Instance.new("UICorner")
vbCorner.CornerRadius = UDim.new(0, 10)
vbCorner.Parent = verifyBtn

-- 验证失败次数
local failCount = 0

-- 验证逻辑
local function attemptVerification()
    local key = keyBox.Text
    if key == "" then
        statusText.Text = "⚠️ 请输入卡密"
        return
    end
    
    statusText.Text = "⏳ 验证中..."
    verifyBtn.Text = "⏳ 验证中"
    verifyBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    verifyBtn.Active = false
    
    task.wait(0.5)  -- 防止暴力破解
    
    local success = verifyKey(key)
    
    if success then
        statusText.Text = "✅ 验证成功！正在加载脚本..."
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        verifyBtn.Text = "✅ 已解锁"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        
        task.wait(0.8)
        
        -- 销毁验证界面
        verifyGui:Destroy()
        
        -- 加载主脚本
        loadMainScript()
    else
        failCount = failCount + 1
        statusText.Text = "❌ 卡密错误！剩余尝试：" .. (3 - failCount)
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        verifyBtn.Text = "✅ 验证"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
        verifyBtn.Active = true
        
        if failCount >= 3 then
            statusText.Text = "❌ 验证失败过多，脚本已锁定"
            verifyBtn.Text = "🔒 已锁定"
            verifyBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
            verifyBtn.Active = false
            keyBox.Active = false
            
            task.wait(3)
            verifyGui:Destroy()
        end
    end
end

-- 绑定验证按钮
verifyBtn.MouseButton1Click:Connect(attemptVerification)

-- 回车键验证
keyBox.FocusLost:Connect(function(enter)
    if enter then
        attemptVerification()
    end
end)

-- ========== 主脚本函数 ==========
function loadMainScript()
    -- 这里放你的主脚本代码
    -- ========== 界面构建 ==========
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MysteryScriptUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    -- 主面板
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 290, 0, 410)
    panel.Position = UDim2.new(0.5, -145, 0.5, -205)
    panel.BackgroundColor3 = Color3.fromRGB(30, 22, 51)
    panel.BorderSizePixel = 0
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panel

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = panel

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -75, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ 俊脚本 · 已激活"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- 最小化按钮
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 32, 0, 32)
    minBtn.Position = UDim2.new(1, -68, 0, 4)
    minBtn.BackgroundColor3 = Color3.fromRGB(68, 55, 99)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.TextSize = 18
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = titleBar
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minBtn

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(144, 34, 30)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- 内容容器
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -90)
    contentFrame.Position = UDim2.new(0, 10, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = panel

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = contentFrame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 7)

    -- 创建按钮函数
    local function createButton(text, bgColor, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = bgColor
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.LayoutOrder = order
        btn.Parent = contentFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = btn
        return btn
    end

    -- ========== 创建功能按钮 ==========
    local playerESPBtn = createButton("👤 人物透视：关", Color3.fromRGB(49, 98, 155), 1)
    local aimBotBtn = createButton("🎯 子弹追踪：关", Color3.fromRGB(136, 42, 101), 2)
    local flyBtn = createButton("🕊️ 飞天：关", Color3.fromRGB(142, 193, 246), 3)
    local fallBtn = createButton("🛡️ 防掉落：关", Color3.fromRGB(182, 109, 226), 4)
    local speedBtn = createButton("💨 速度：16", Color3.fromRGB(208, 166, 216), 5)
    local jumpBtn = createButton("🦘 跳跃：50", Color3.fromRGB(150, 199, 192), 6)

    -- ========== 悬浮窗 ==========
    local floatingWindow = Instance.new("TextButton")
    floatingWindow.Size = UDim2.new(0, 45, 0, 45)
    floatingWindow.Position = UDim2.new(1, -55, 0, 10)
    floatingWindow.BackgroundColor3 = Color3.fromRGB(213, 179, 242)
    floatingWindow.Text = "⚡"
    floatingWindow.TextSize = 20
    floatingWindow.TextColor3 = Color3.new(1, 1, 1)
    floatingWindow.Font = Enum.Font.GothamBold
    floatingWindow.ZIndex = 999
    floatingWindow.Visible = false
    floatingWindow.Parent = screenGui
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatingWindow

    -- ========== 人物透视 ==========
    local playerESPEnabled = false
    local espData = {}

    local function getTeamColor3(p)
        if p.Team and player.Team and p.Team == player.Team then
            return Color3.fromRGB(198, 218, 247)
        end
        return Color3.fromRGB(234, 177, 188)
    end

    local function buildESP(p)
        if p == player then return end
        if espData[p] then return end
        local char = p.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local col = getTeamColor3(p)

        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESP_SelectionBox"
        selectionBox.Adornee = root
        selectionBox.Color3 = col
        selectionBox.LineThickness = 0.022
        selectionBox.SurfaceTransparency = 0.7
        selectionBox.Transparency = 0.2
        selectionBox.Parent = root

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 110, 0, 28)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = root

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = p.Name
        nameLabel.TextColor3 = col
        nameLabel.TextSize = 15
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = billboard

        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"
        hl.Adornee = char
        hl.FillTransparency = 0.9
        hl.OutlineTransparency = 0
        hl.OutlineColor = col
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        espData[p] = {selectionBox = selectionBox, billboard = billboard, highlight = hl}
    end

    local function clearOne(p)
        local d = espData[p]
        if not d then return end
        if d.selectionBox and d.selectionBox.Parent then d.selectionBox:Destroy() end
        if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
        if d.highlight and d.highlight.Parent then d.highlight:Destroy() end
        espData[p] = nil
    end

    local function clearPlayerESP()
        for p in pairs(espData) do clearOne(p) end
        espData = {}
    end

    local function onCharAdded(p, char)
        task.wait(0.5)
        if playerESPEnabled then buildESP(p) end
    end

    local function addPlayerESP(p)
        if p == player then return end
        if p.Character then onCharAdded(p, p.Character) end
        p.CharacterAdded:Connect(function(c)
            clearOne(p)
            onCharAdded(p, c)
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do addPlayerESP(p) end
    Players.PlayerAdded:Connect(addPlayerESP)
    Players.PlayerRemoving:Connect(clearOne)

    playerESPBtn.MouseButton1Click:Connect(function()
        playerESPEnabled = not playerESPEnabled
        if playerESPEnabled then
            playerESPBtn.Text = "👤 人物透视：开"
            playerESPBtn.BackgroundColor3 = Color3.fromRGB(201, 233, 206)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then buildESP(p) end
            end
        else
            playerESPBtn.Text = "👤 人物透视：关"
            playerESPBtn.BackgroundColor3 = Color3.fromRGB(203, 232, 238)
            clearPlayerESP()
        end
    end)

    -- ========== 子弹追踪 ==========
    local aimBotEnabled = false
    local aimBotConnection = nil

    local function getClosestTarget()
        local closest = nil
        local closestDist = math.huge
        local camera = workspace.CurrentCamera
        local char = player.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        for _, p in pairs(Players:GetPlayers()) do
            if p == player then continue end
            local pChar = p.Character
            if not pChar then continue end
            local pRoot = pChar:FindFirstChild("HumanoidRootPart")
            if not pRoot then continue end
            local pHumanoid = pChar:FindFirstChildOfClass("Humanoid")
            if not pHumanoid or pHumanoid.Health <= 0 then continue end
            local screenPos, onScreen = camera:WorldToViewportPoint(pRoot.Position)
            if not onScreen then continue end
            local dist = (root.Position - pRoot.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = pRoot
            end
        end
        return closest
    end

    local function enableAimBot()
        if aimBotConnection then return end
        aimBotConnection = runService.RenderStepped:Connect(function()
            if not aimBotEnabled then return end
            local target = getClosestTarget()
            if not target then return end
            local camera = workspace.CurrentCamera
            local char = player.Character
            if not char then return end
            local direction = (target.Position - camera.CFrame.Position).Unit
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + direction)
        end)
    end

    local function disableAimBot()
        if aimBotConnection then
            aimBotConnection:Disconnect()
            aimBotConnection = nil
        end
    end

    aimBotBtn.MouseButton1Click:Connect(function()
        aimBotEnabled = not aimBotEnabled
        if aimBotEnabled then
            aimBotBtn.Text = "🎯 子弹追踪：开"
            aimBotBtn.BackgroundColor3 = Color3.fromRGB(212, 186, 205)
            enableAimBot()
        else
            aimBotBtn.Text = "🎯 子弹追踪：关"
            aimBotBtn.BackgroundColor3 = Color3.fromRGB(195, 176, 188)
            disableAimBot()
        end
    end)

    -- ========== 飞天（自带虚拟摇杆） ==========
    local flying = false
    local flyBV, flyBG, flyConn
    local flySpeed = 55
    local flyVSpeed = 45
    local vy = 0

    local joyActive = false
    local joyStart = Vector2.new()
    local joyVec = Vector2.new(0, 0)

    local joyFrame = Instance.new("Frame")
    joyFrame.Size = UDim2.new(0, 140, 0, 140)
    joyFrame.Position = UDim2.new(0, 30, 1, -170)
    joyFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joyFrame.BackgroundTransparency = 0.8
    joyFrame.Visible = false
    joyFrame.Parent = screenGui
    local joyCorner = Instance.new("UICorner")
    joyCorner.CornerRadius = UDim.new(1, 0)
    joyCorner.Parent = joyFrame

    local joyKnob = Instance.new("Frame")
    joyKnob.Size = UDim2.new(0, 55, 0, 55)
    joyKnob.Position = UDim2.new(0.5, -27, 0.5, -27)
    joyKnob.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
    joyKnob.Parent = joyFrame
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = joyKnob

    local flyPad = Instance.new("Frame")
    flyPad.Size = UDim2.new(0, 110, 0, 120)
    flyPad.Position = UDim2.new(1, -130, 1, -140)
    flyPad.BackgroundTransparency = 1
    flyPad.Visible = false
    flyPad.Parent = screenGui

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 100, 0, 50)
    upBtn.Position = UDim2.new(0, 5, 0, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(173, 216, 253)
    upBtn.Text = "⬆ 上升"
    upBtn.TextColor3 = Color3.new(0, 0, 0)
    upBtn.TextSize = 17
    upBtn.Font = Enum.Font.GothamBold
    upBtn.Parent = flyPad
    local upC = Instance.new("UICorner")
    upC.CornerRadius = UDim.new(0, 12)
    upC.Parent = upBtn

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 100, 0, 50)
    downBtn.Position = UDim2.new(0, 5, 0, 60)
    downBtn.BackgroundColor3 = Color3.fromRGB(248, 188, 252)
    downBtn.Text = "⬇ 下降"
    downBtn.TextColor3 = Color3.new(0, 0, 0)
    downBtn.TextSize = 17
    downBtn.Font = Enum.Font.GothamBold
    downBtn.Parent = flyPad
    local downC = Instance.new("UICorner")
    downC.CornerRadius = UDim.new(0, 12)
    downC.Parent = downBtn

    userInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.UserInputType == Enum.UserInputType.Touch and flying then
            local pos = i.Position
            local vps = workspace.CurrentCamera.ViewportSize
            if pos.X < vps.X * 0.45 and pos.Y > vps.Y * 0.4 then
                joyActive = true
                joyStart = pos
                joyFrame.Position = UDim2.new(0, pos.X - 70, 0, pos.Y - 70)
                joyFrame.Visible = true
            end
        end
    end)

    userInputService.InputChanged:Connect(function(i, gp)
        if gp then return end
        if joyActive and i.UserInputType == Enum.UserInputType.Touch then
            local delta = i.Position - joyStart
            local maxR = 50
            if delta.Magnitude > maxR then delta = delta.Unit * maxR end
            joyKnob.Position = UDim2.new(0.5, -27 + delta.X, 0.5, -27 + delta.Y)
            joyVec = Vector2.new(delta.X / maxR, -delta.Y / maxR)
        end
    end)

    userInputService.InputEnded:Connect(function(i, gp)
        if joyActive and i.UserInputType == Enum.UserInputType.Touch then
            joyActive = false
            joyVec = Vector2.new(0, 0)
            joyKnob.Position = UDim2.new(0.5, -27, 0.5, -27)
            joyFrame.Visible = false
        end
    end)

    upBtn.MouseButton1Down:Connect(function() vy = flyVSpeed end)
    upBtn.MouseButton1Up:Connect(function() vy = 0 end)
    upBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then vy = 0 end
    end)
    downBtn.MouseButton1Down:Connect(function() vy = -flyVSpeed end)
    downBtn.MouseButton1Up:Connect(function() vy = 0 end)
    downBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then vy = 0 end
    end)

    local function startFly()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        flying = true
        hum.PlatformStand = true
        flyPad.Visible = true

        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.P = 7000
        flyBV.Parent = hrp

        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBG.P = 8500
        flyBG.Parent = hrp

        flyConn = runService.Heartbeat:Connect(function()
            if not flying then return end
            local cam = workspace.CurrentCamera
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector

            local move = (right * joyVec.X) + (look * joyVec.Y)
            move = Vector3.new(move.X, 0, move.Z)
            if move.Magnitude > 0.01 then
                move = move.Unit * flySpeed * math.min(1, joyVec.Magnitude)
            end

            flyBV.Velocity = Vector3.new(move.X, vy, move.Z)
            flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
        end)
    end

    local function stopFly()
        flying = false
        vy = 0
        joyActive = false
        joyVec = Vector2.new(0, 0)
        joyFrame.Visible = false
        flyPad.Visible = false
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    flyBtn.MouseButton1Click:Connect(function()
        if flying then
            stopFly()
            flyBtn.Text = "🕊️ 飞天：关"
            flyBtn.BackgroundColor3 = Color3.fromRGB(142, 193, 246)
        else
            startFly()
            flyBtn.Text = "🕊️ 飞天：开"
            flyBtn.BackgroundColor3 = Color3.fromRGB(226, 237, 233)
        end
    end)

    player.CharacterAdded:Connect(function()
        if flying then stopFly() end
    end)

    -- ========== 防掉落 ==========
    local fallDamageEnabled = false
    local fallConnections = {}

    local function enableFallProtection()
        local function protectCharacter(char)
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            if fallConnections[char] then
                fallConnections[char]:Disconnect()
                fallConnections[char] = nil
            end
            fallConnections[char] = humanoid.StateChanged:Connect(function(oldState, newState)
                if not fallDamageEnabled then return end
                if oldState == Enum.HumanoidStateType.FallingDown or oldState == Enum.HumanoidStateType.Freefall then
                    humanoid.Health = humanoid.MaxHealth
                    if newState == Enum.HumanoidStateType.GettingUp then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Freefall then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
        local char = player.Character
        if char then protectCharacter(char) end
        player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            if fallDamageEnabled then protectCharacter(newChar) end
        end)
    end

    local function disableFallProtection()
        for char, conn in pairs(fallConnections) do
            if conn then conn:Disconnect() end
        end
        fallConnections = {}
    end

    fallBtn.MouseButton1Click:Connect(function()
        fallDamageEnabled = not fallDamageEnabled
        if fallDamageEnabled then
            fallBtn.Text = "🛡️ 防掉落：开"
            fallBtn.BackgroundColor3 = Color3.fromRGB(211, 229, 214)
            enableFallProtection()
        else
            fallBtn.Text = "🛡️ 防掉落：关"
            fallBtn.BackgroundColor3 = Color3.fromRGB(196, 183, 209)
            disableFallProtection()
        end
    end)

    -- ========== 速度 ==========
    local currentSpeed = 16
    speedBtn.MouseButton1Click:Connect(function()
        currentSpeed = currentSpeed + 4
        if currentSpeed > 100 then currentSpeed = 16 end
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = currentSpeed end
        end
        speedBtn.Text = "💨 速度：" .. currentSpeed
    end)

    -- ========== 跳跃 ==========
    local currentJump = 50
    jumpBtn.MouseButton1Click:Connect(function()
        currentJump = currentJump + 10
        if currentJump > 200 then currentJump = 50 end
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = currentJump end
        end
        jumpBtn.Text = "🦘 跳跃：" .. currentJump
    end)

    -- ========== 隐藏/显示 ==========
    local uiHidden = false

    minBtn.MouseButton1Click:Connect(function()
        uiHidden = true
        panel.Visible = false
        floatingWindow.Visible = true
    end)

    floatingWindow.MouseButton1Click:Connect(function()
        uiHidden = false
        panel.Visible = true
        floatingWindow.Visible = false
    end)

    userInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.H then
            uiHidden = not uiHidden
            panel.Visible = not uiHidden
            floatingWindow.Visible = uiHidden
        end
    end)

    -- ========== 关闭清理 ==========
    closeBtn.MouseButton1Click:Connect(function()
        if flying then stopFly() end
        clearPlayerESP()
        disableFallProtection()
        disableAimBot()
        if screenGui then screenGui:Destroy() end
    end)

    print("✅ 俊脚本加载完成！按 H 隐藏/显示面板")
end
