-- 苏脚本 | 通缉专用 (WindUI 黑耀石主题 + 全功能)
if game.PlaceId ~= 14438406081 then return end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()

WindUI.TransparencyValue = 0.15

WindUI:AddTheme({
    Name = "Obsidian",
    Accent      = Color3.fromHex("#7C5CFF"),
    Background  = Color3.fromHex("#0B0B0F"),
    Outline     = Color3.fromHex("#1F1F27"),
    Text        = Color3.fromHex("#E6E6F0"),
    Placeholder = Color3.fromHex("#6B6B7B"),
    Button      = Color3.fromHex("#16161D"),
    Icon        = Color3.fromHex("#9A9AB0"),
})

WindUI:SetTheme("Obsidian")

-- ===== 全局变量 =====
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Camera = Workspace.CurrentCamera

local RootPart = nil
local AutoShoot = false
local ShooterModule = nil
local OriginalShoot = nil

getgenv().TrailColors = {
    StartColor = Color3.fromRGB(0, 170, 255),
    EndColor = Color3.fromRGB(255, 0, 0),
    MiddleColor1 = Color3.fromRGB(255, 0, 255),
    MiddleColor2 = Color3.fromRGB(255, 255, 0)
}

-- 自动刷钱变量
local IsAutoFarmRunning = false
local AutoFarmThread = nil
local GizmoFolder = Workspace:FindFirstChild("Gizmos") or Workspace:FindFirstChild("GizmoFolder") or Workspace
local PatrolPoints = {
    Vector3.new(-180, 43, -2805),
    Vector3.new(-905, 43, -1563),
    Vector3.new(-2907, 38, 1652),
    Vector3.new(-431, 40, -1400),
}

-- Hitbox变量
local HitboxHeadSize = 20
local HitboxDisabled = true
local HitboxTransparency = 0.7
local HitboxColor = Color3.fromRGB(255, 255, 255)
local HitboxRainbow = false
local HitboxTargetedUser = ""

-- 移动变量
local InfiniteJumpEnabled = false
local DefaultJumpPower = 50
local speedMultiplier = 2
local isSpeedEnabled = false

-- ===== 工具函数 =====
local function InitRootPart()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char then
            RootPart = char:WaitForChild("HumanoidRootPart", 5)
        end
    end)
end

local function playSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9047002353"
        sound.Volume = 0.3
        sound.Parent = SoundService
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

-- 弹道
local function createBeautifulTrail(origin, targetPos)
    local trailContainer = Instance.new("Folder")
    trailContainer.Name = "MagicTrail"
    trailContainer.Parent = Workspace
    
    local midPoint = (origin + targetPos) / 2
    local direction = (targetPos - origin).Unit
    local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
    local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)
    
    local curvePoints = {}
    for i = 0, 20 do
        local t = i / 20
        local point = (1-t)^2 * origin + 2*(1-t)*t * controlPoint + t^2 * targetPos
        table.insert(curvePoints, point)
    end
    
    for i = 1, #curvePoints - 1 do
        local startPoint = curvePoints[i]
        local endPoint = curvePoints[i + 1]
        local distance = (endPoint - startPoint).Magnitude
        
        local beamPart = Instance.new("Part")
        beamPart.Size = Vector3.new(0.15, 0.15, distance)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Material = Enum.Material.Neon
        beamPart.Transparency = 0.3
        beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance/2)
        beamPart.Parent = trailContainer
        
        local t = i / (#curvePoints - 1)
        local color
        if t < 0.3 then color = getgenv().TrailColors.StartColor
        elseif t < 0.6 then color = getgenv().TrailColors.MiddleColor1
        elseif t < 0.9 then color = getgenv().TrailColors.MiddleColor2
        else color = getgenv().TrailColors.EndColor end
        beamPart.Color = color
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 5
        pointLight.Range = 3
        pointLight.Color = color
        pointLight.Parent = beamPart
        
        local particles = Instance.new("ParticleEmitter")
        particles.Size = NumberSequence.new(0.1, 0.3)
        particles.Transparency = NumberSequence.new(0.3, 0.8)
        particles.Lifetime = NumberRange.new(0.5, 1)
        particles.Rate = 50
        particles.Speed = NumberRange.new(1, 2)
        particles.VelocitySpread = 180
        particles.Color = ColorSequence.new(color)
        particles.Parent = beamPart
    end
    
    task.delay(1.5, function()
        if trailContainer and trailContainer.Parent then trailContainer:Destroy() end
    end)
end

local function hasLineOfSight(shooterPos, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    local direction = (targetPos - shooterPos).Unit
    local distance = (targetPos - shooterPos).Magnitude
    local result = Workspace:Raycast(shooterPos, direction * distance, raycastParams)
    if result then
        local hitPart = result.Instance
        if hitPart then
            local hitChar = hitPart:FindFirstAncestorOfClass("Model")
            if hitChar and hitChar:FindFirstChild("Humanoid") then return true else return false end
        end
    end
    return true
end

-- ===== 自动刷钱函数 =====
local function GetBasePart(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("BasePart") then return descendant end
    end
    return nil
end

local function IsValidTarget(instance)
    local typeAttr = instance:GetAttribute("gizmoType")
    return typeAttr == "ATM" or typeAttr == "Register"
end

local function FindClosestTarget()
    if not GizmoFolder or not RootPart then return nil end
    local minDistance = math.huge
    local closestPart = nil
    for _, item in ipairs(GizmoFolder:GetChildren()) do
        if IsValidTarget(item) then
            local part = GetBasePart(item)
            if part then
                local dist = (RootPart.Position - part.Position).Magnitude
                if dist < minDistance then
                    closestPart = part
                    minDistance = dist
                end
            end
        end
    end
    return closestPart
end

local function TeleportToTarget(target)
    if not RootPart then return end
    if typeof(target) ~= "Instance" then
        if typeof(target) == "Vector3" then RootPart.CFrame = CFrame.new(target) end
    else
        RootPart.CFrame = target.CFrame * CFrame.new(0, 1, 0)
    end
end

local function SpamInteract(duration)
    local start = tick()
    while tick() - start < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.01)
    end
end

local function ProcessCollection(targetPart)
    SpamInteract(1.5)
end

local function StartAutoFarm()
    if AutoFarmThread or not GizmoFolder or not RootPart then return end
    IsAutoFarmRunning = true
    AutoFarmThread = task.spawn(function()
        while IsAutoFarmRunning do
            pcall(function()
                local target = FindClosestTarget()
                if target then
                    TeleportToTarget(target)
                    ProcessCollection(target)
                else
                    TeleportToTarget(PatrolPoints[math.random(1, #PatrolPoints)])
                end
                task.wait(1.5)
            end)
        end
    end)
end

local function StopAutoFarm()
    IsAutoFarmRunning = false
    if AutoFarmThread then task.cancel(AutoFarmThread) AutoFarmThread = nil end
end

-- ===== Hitbox =====
local function GenerateRainbowColor()
    local HueValue = tick() % 5 / 5
    return Color3.fromHSV(HueValue, 1, 1)
end

local function IsTargetedUser(PlayerName)
    local TargetLower = HitboxTargetedUser:lower()
    return PlayerName:lower():find(TargetLower, 1, true) ~= nil
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if HitboxDisabled then
            for _, NextPlayer in pairs(Players:GetPlayers()) do
                if NextPlayer ~= LocalPlayer then
                    pcall(function()
                        local Character = NextPlayer.Character
                        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
                        if HRP then
                            HRP.Size = Vector3.new(2, 2, 1)
                            HRP.Transparency = 1
                            HRP.BrickColor = BrickColor.new("Medium stone grey")
                            HRP.Material = Enum.Material.Plastic
                            HRP.CanCollide = true
                        end
                    end)
                end
            end
        else
            for _, NextPlayer in pairs(Players:GetPlayers()) do
                if NextPlayer ~= LocalPlayer then
                    pcall(function()
                        local Character = NextPlayer.Character
                        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
                        if HRP then
                            if HitboxTargetedUser == "" or IsTargetedUser(NextPlayer.Name) then
                                HRP.Size = Vector3.new(HitboxHeadSize, HitboxHeadSize, HitboxHeadSize)
                                HRP.Transparency = HitboxTransparency
                                HRP.BrickColor = HitboxRainbow and BrickColor.new(GenerateRainbowColor()) or BrickColor.new(HitboxColor)
                                HRP.Material = Enum.Material.Neon
                                HRP.CanCollide = false
                            else
                                HRP.Size = Vector3.new(2, 2, 1)
                                HRP.Transparency = 1
                                HRP.BrickColor = BrickColor.new("Medium stone grey")
                                HRP.Material = Enum.Material.Plastic
                                HRP.CanCollide = true
                            end
                        end
                    end)
                end
            end
        end
    end)
end)

-- ===== 无限跳 =====
local function InfiniteJumpLogic()
    UserInputService.JumpRequest:Connect(function()
        if not InfiniteJumpEnabled then return end
        pcall(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.JumpPower = DefaultJumpPower
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end)
end
task.spawn(InfiniteJumpLogic)

-- ===== 加速 =====
local function updateSpeed()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if isSpeedEnabled then
        humanoid.WalkSpeed = 16 * speedMultiplier
    else
        humanoid.WalkSpeed = 16
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChildOfClass("Humanoid")
    updateSpeed()
    task.wait(1)
    InitRootPart()
end)

-- ===== 弹窗 =====
local Confirmed = false
local username = LocalPlayer.Name
local gradientColors = {"#4169E1","#6A5ACD","#9370DB","#8A2BE2","#4B0082"}
local goldColor = "#FFD700"
local coloredUsername = ""

for i = 1, #username do
    local char = username:sub(i, i)
    if char:match("[A-Za-z0-9]") then
        local colorIndex = (i - 1) % #gradientColors + 1
        coloredUsername = coloredUsername .. '<font color="' .. gradientColors[colorIndex] .. '">' .. char .. '</font>'
    else
        coloredUsername = coloredUsername .. '<font color="' .. goldColor .. '">' .. char .. '</font>'
    end
end

WindUI:Popup({
    Title = '苏脚本',
    IconThemed = true,
    Icon = "crown",
    Content = "欢迎 " .. coloredUsername .. "\n感谢使用 | QQ群:1015718032",
    Buttons = {
        {Title = "取消", Callback = function() end, Variant = "Secondary"},
        {Title = "执行", Icon = "arrow-right", Callback = function() Confirmed = true createUI() end, Variant = "Primary"},
    }
})

-- ===== 主UI =====
function createUI()
    local Window = WindUI:CreateWindow({
        Title = '苏脚本 | 通缉',
        Icon = "crown",
        IconThemed = true,
        Author = "苏屿",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(600, 400),
        Transparent = true,
        Theme = "Obsidian",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        Background = "https://raw.githubusercontent.com/tnine-n9/TnineHubnb/refs/heads/main/1770443104414_edit_300225054024499.png",
        BackgroundImageTransparency = 0.45,
        User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({Title = "苏脚本", Content = "欢迎回来", Duration = 1, Icon = "4483362748"})
            end,
            Anonymous = false
        },
        SideBarWidth = 250,
    })

    Window:EditOpenButton({
        Title = "苏脚本",
        Icon = "crown",
        CornerRadius = UDim.new(0,16),
        StrokeThickness = 4,
        Color = ColorSequence.new(Color3.fromHex("7C5CFF")),
        Draggable = true,
    })

    Window:Tag({
        Title = "苏脚本(苏屿)",
        Color = Color3.fromHex("#7C5CFF")
    })

    -- ===== 通知 =====
    local infoTab = Window:Tab({Title = "通知", Icon = "layout-grid"})
    local infoSection = infoTab:Section({Title = "详情信息", Icon = "info", Opened = true})
    infoSection:Divider()
    infoSection:Paragraph({Title = "您当前的服务器为", Desc = "通缉\n欢迎使用苏脚本", ThumbnailSize = 190})
    infoSection:Paragraph({Title = "持续更新 有bug请提出来", ThumbnailSize = 190})
    infoSection:Paragraph({Title = "作者:苏屿", ThumbnailSize = 190})

    -- ===== 自动射击 =====
    local MainTab = Window:Tab({Title = "愤怒机器人全枪", Icon = "swords", IconColor = Color3.fromHex("#7C5CFF")})
    MainTab:Section({Title = "自动射击", TextSize = 16})

    MainTab:Input({
        Flag = "AutoShootInput",
        Title = "愤怒机器人 (open开启 / close关闭)",
        Desc = "输入open启用自动射击，close关闭",
        Value = "close",
        Placeholder = "输入open或close",
        Callback = function(v)
            AutoShoot = v:lower() == "open"
            if AutoShoot then
                task.spawn(function()
                    local clientTool = game:GetService("ReplicatedStorage")
                        :FindFirstChild("Client", true)
                        and game:GetService("ReplicatedStorage").Client:FindFirstChild("Wanted", true)
                        and game:GetService("ReplicatedStorage").Client.Wanted:FindFirstChild("Objects", true)
                        and game:GetService("ReplicatedStorage").Client.Wanted.Objects:FindFirstChild("ClientTool", true)
                        and game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components:FindFirstChild("Guns", true)
                        and game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns:FindFirstChild("Shooter", true)
                    
                    if not clientTool then
                        WindUI:Notify({Title = "错误", Content = "未找到枪械模块", Duration = 3})
                        AutoShoot = false
                        return
                    end
                    
                    ShooterModule = require(clientTool)
                    OriginalShoot = ShooterModule._shoot
                    
                    ShooterModule._shoot = function(self)
                        if not self or not self.tool then return OriginalShoot(self) end
                        local char = LocalPlayer.Character
                        if not char then return OriginalShoot(self) end
                        local shooterPos = char.HumanoidRootPart and char.HumanoidRootPart.Position or char.PrimaryPart.Position
                        local nearestPlayer, nearestDistance = nil, math.huge
                        
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local tp = p.Character.HumanoidRootPart.Position
                                local d = (shooterPos - tp).Magnitude
                                if hasLineOfSight(shooterPos, tp) and d < nearestDistance then
                                    nearestDistance = d
                                    nearestPlayer = p
                                end
                            end
                        end
                        
                        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
                            self.aimpoint = targetPos
                            self.aimpoint2 = targetPos
                            local muzzle = self.tool.model and self.tool.model.PrimaryPart
                            createBeautifulTrail(muzzle and muzzle.Position or shooterPos, targetPos)
                            if self.tool then
                                self.tool.shooting = true
                                self.tool.fireDebounce = 0
                                self.tool.fireMode = "auto"
                            end
                        else
                            if self.tool then self.tool.shooting = false end
                        end
                        return OriginalShoot(self)
                    end
                    
                    while AutoShoot do
                        if ShooterModule and ShooterModule._shoot then
                            local tool = char and char:FindFirstChildWhichIsA("Tool")
                            if tool then
                                local shooter = tool:FindFirstChild("Shooter") or {tool = tool}
                                pcall(function() ShooterModule._shoot(shooter) end)
                            end
                        end
                        task.wait(0.2)
                    end
                    if OriginalShoot then ShooterModule._shoot = OriginalShoot end
                end)
                WindUI:Notify({Title = "成功", Content = "愤怒机器人已启用", Duration = 3})
            else
                if ShooterModule and OriginalShoot then ShooterModule._shoot = OriginalShoot end
                WindUI:Notify({Title = "提示", Content = "愤怒机器人已关闭", Duration = 3})
            end
        end
    })

    MainTab:Section({Title = "弹道颜色调整", TextSize = 16})
    MainTab:Colorpicker({Flag = "TrailStart", Title = "起始颜色", Desc = "弹道开始颜色", Default = getgenv().TrailColors.StartColor, Transparency = 0, Callback = function(c) getgenv().TrailColors.StartColor = c end})
    MainTab:Colorpicker({Flag = "TrailMid1", Title = "中间颜色1", Desc = "弹道中间颜色", Default = getgenv().TrailColors.MiddleColor1, Transparency = 0, Callback = function(c) getgenv().TrailColors.MiddleColor1 = c end})
    MainTab:Colorpicker({Flag = "TrailMid2", Title = "中间颜色2", Desc = "弹道中间颜色", Default = getgenv().TrailColors.MiddleColor2, Transparency = 0, Callback = function(c) getgenv().TrailColors.MiddleColor2 = c end})
    MainTab:Colorpicker({Flag = "TrailEnd", Title = "结束颜色", Desc = "弹道结束颜色", Default = getgenv().TrailColors.EndColor, Transparency = 0, Callback = function(c) getgenv().TrailColors.EndColor = c end})

    MainTab:Button({Title = "测试弹道效果", Desc = "生成测试弹道", Icon = "zap", Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local sp = LocalPlayer.Character.HumanoidRootPart.Position
            createBeautifulTrail(sp, sp + Vector3.new(0, 0, -20))
        end
    end})

    -- ===== 武器修改 =====
    local WeaponTab = Window:Tab({Title = "武器修改", Icon = "target"})
    local function hookShoot(modifier)
        local ok, Shooter = pcall(require, game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
        if ok then
            local orig = Shooter._shoot
            Shooter._shoot = function(self) modifier(self) return orig(self) end
            WindUI:Notify({Title = "成功", Content = "已启用", Duration = 2})
        else
            WindUI:Notify({Title = "失败", Content = "未找到模块", Duration = 2})
        end
    end
    WeaponTab:Button({Title = "无限子弹", Callback = function() hookShoot(function(self) self.ammo = 9999 self.totalAmmo = 9999 end) end})
    WeaponTab:Button({Title = "无后坐力", Callback = function() hookShoot(function(self) self.recoil = {firstShotKick=0, climb=0, spread=0} end) end})
    WeaponTab:Button({Title = "无扩散", Callback = function() hookShoot(function(self) self.aim = {spreadAngle=0, zeroing=1000} end) end})
    WeaponTab:Button({Title = "快速射击", Callback = function() hookShoot(function(self) self.tool.fireDebounce = 0 self.tool.fireMode = "auto" end) end})
    WeaponTab:Button({Title = "无装弹", Callback = function() hookShoot(function(self) self.ammoData = {reloadTime=0, magSize=9999} end) end})

    -- ===== 自瞄 =====
    local AimbotTab = Window:Tab({Title = "自瞄", Icon = "target"})
    AimbotTab:Section({Title = "自瞄设置", TextSize = 16})

    local AimbotEnabled = false
    local AimbotKey = Enum.KeyCode.Q
    local AimbotFOV = 150
    local AimbotSmoothness = 0.15
    local AimbotTeamCheck = true
    local AimbotWallCheck = true

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(124, 92, 255)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Visible = false
    FOVCircle.Transparency = 0.8

    AimbotTab:Toggle({Title = "启用自瞄", Value = false, Callback = function(v)
        AimbotEnabled = v FOVCircle.Visible = v
        WindUI:Notify({Title = "苏脚本", Content = v and "自瞄已启用 (按住Q锁定)" or "自瞄已关闭", Duration = 3})
    end})

    AimbotTab:Slider({Title = "FOV范围", Desc = "屏幕内锁定范围", Value = {Min = 50, Max = 400, Default = 150}, Callback = function(v) AimbotFOV = v FOVCircle.Radius = v end})
    AimbotTab:Slider({Title = "平滑度", Desc = "越低越跟手，越高越平滑", Value = {Min = 0.05, Max = 0.5, Default = 0.15}, Callback = function(v) AimbotSmoothness = v end})
    AimbotTab:Toggle({Title = "队伍检测", Value = true, Callback = function(v) AimbotTeamCheck = v end})
    AimbotTab:Toggle({Title = "穿墙检测", Value = true, Callback = function(v) AimbotWallCheck = v end})

    AimbotTab:Input({Flag = "AimbotKey", Title = "自瞄按键", Desc = "输入按键名，如 Q / E / MB2", Value = "Q", Placeholder = "输入按键名", Callback = function(text)
        local ok, key = pcall(function() return Enum.KeyCode[text] end)
        if ok then AimbotKey = key WindUI:Notify({Title = "苏脚本", Content = "自瞄按键已设为 " .. text, Duration = 2})
        else WindUI:Notify({Title = "错误", Content = "无效按键名", Duration = 2}) end
    end})

    local function getClosestTarget()
        local closest, shortest = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (not AimbotTeamCheck or p.Team ~= LocalPlayer.Team) then
                if p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist <= AimbotFOV and dist < shortest then
                            if AimbotWallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
                                local result = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 5000, rayParams)
                                if result and result.Instance then
                                    local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                                    if hitChar ~= p.Character then continue end
                                end
                            end
                            shortest = dist closest = p
                        end
                    end
                end
            end
        end
        return closest
    end

    local aimbotConnection = RunService.RenderStepped:Connect(function()
        if not AimbotEnabled then return end
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if not UserInputService:IsKeyDown(AimbotKey) then return end
        local target = getClosestTarget()
        if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), AimbotSmoothness)
    end)

    -- ===== 战斗(Hitbox) =====
    local CombatTab = Window:Tab({Title = "战斗", Icon = "swords"})
    local Section_Combat = CombatTab:Section({TextSize = 17, Title = "Hitbox扩展", TextXAlignment = "Left"})
    Section_Combat:Paragraph({Title = "注意", Desc = "范围固定 但是要记得演戏 小心被挂DC"})

    Section_Combat:Toggle({TextSize = 14, Title = "启用 Hitbox Extender", Callback = function(state) HitboxDisabled = not state end, Default = false})
    Section_Combat:Slider({TextSize = 14, Title = "Hitbox大小", Desc = "调整命中框大小", Value = {Min = 5, Max = 50, Default = 20}, Callback = function(v) HitboxHeadSize = v end})
    Section_Combat:Toggle({TextSize = 14, Title = "彩虹颜色", Desc = "Hitbox颜色循环", Callback = function(state) HitboxRainbow = state end, Default = false})
    Section_Combat:Input({Flag = "HitboxTarget", Title = "指定玩家(留空=全部)", Desc = "输入玩家名", Value = "", Placeholder = "玩家名", Callback = function(text) HitboxTargetedUser = text end})

    -- ===== 传送 =====
    local TeleportTab = Window:Tab({Title = "传送", Icon = "map-pin"})
    
    local function TeleportTo(x, y, z)
        pcall(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(3)
            local hrp = char:WaitForChild("HumanoidRootPart", 3)
            hrp.CFrame = CFrame.new(x, y, z)
        end)
    end

    local Section_Places = TeleportTab:Section({TextSize = 16, Title = "地点传送", TextXAlignment = "Left"})
    Section_Places:Button({TextSize = 14, Title = "枪店", Callback = function() TeleportTo(-180.77, 43.13, -2805.05) end})
    Section_Places:Button({TextSize = 14, Title = "手机店", Callback = function() TeleportTo(-905.70, 42.98, -1563.35) end})
    Section_Places:Button({TextSize = 14, Title = "黑市", Callback = function() TeleportTo(-2907.39, 37.58, 1652.25) end})

    local Section_Crime = TeleportTab:Section({TextSize = 16, Title = "犯罪地点", TextXAlignment = "Left"})
    Section_Crime:Button({TextSize = 14, Title = "犯罪窝点", Callback = function() TeleportTo(-7939.26, 21.74, 1073.52) end})
    Section_Crime:Button({TextSize = 14, Title = "银行外", Callback = function() TeleportTo(-431.54, 40.09, -1400.08) end})
    Section_Crime:Button({TextSize = 14, Title = "小银行", Callback = function() TeleportTo(-6852.36, 42.61, 965.86) end})
    Section_Crime:Button({TextSize = 14, Title = "银行内部", Callback = function() TeleportTo(-399.28, 617.63, -1245.29) end})

    local Section_Special = TeleportTab:Section({TextSize = 16, Title = "特殊地点", TextXAlignment = "Left"})
    Section_Special:Button({TextSize = 14, Title = "警察局", Callback = function() TeleportTo(1583.31, 119.86, -716.63) end})
    Section_Special:Button({TextSize = 14, Title = "烈焰要塞", Callback = function() TeleportTo(-1412.96, 181.18, 3054.46) end})

    -- ===== 武器传送 =====
    local WeaponsTab = Window:Tab({Title = "武器", Icon = "swords"})
    local Section_Weapons = WeaponsTab:Section({TextSize = 16, Title = "武器获取", TextXAlignment = "Left"})
    Section_Weapons:Button({TextSize = 14, Title = "AWP狙击枪", Callback = function() TeleportTo(-822.97, 326.09, -506.58) end})
    Section_Weapons:Button({TextSize = 14, Title = "UMP 45", Callback = function() TeleportTo(1665.20, 143.84, -644.01) end})
    Section_Weapons:Button({TextSize = 14, Title = "贝内利 M1014", Callback = function() TeleportTo(1345.20, 141.52, -4809.11) end})
    Section_Weapons:Button({TextSize = 14, Title = "M4", Callback = function() TeleportTo(-6342.43, 134.86, -4326.83) end})
    Section_Weapons:Button({TextSize = 14, Title = "AK47", Callback = function() TeleportTo(-7835.20, 21.84, 1192.14) end})
    Section_Weapons:Button({TextSize = 14, Title = "火箭筒", Callback = function() TeleportTo(-1392.87, 209.34, 3217.20) end})
    Section_Weapons:Button({TextSize = 14, Title = "UZI", Callback = function() TeleportTo(-1348.55, 40.68, 2033.74) end})

    -- ===== 金钱(自动刷钱) =====
    local MoneyTab = Window:Tab({Title = "金钱", Icon = "dollar-sign"})
    local Section_AutoFarm = MoneyTab:Section({TextSize = 17, Title = "自动刷钱", TextXAlignment = "Left"})
    Section_AutoFarm:Toggle({TextSize = 14, Title = "自动全图刷钱", Callback = function(state)
        if state then StartAutoFarm() else StopAutoFarm() end
    end, Default = false})

    -- ===== 本地玩家 =====
    local PlayerTab = Window:Tab({Title = "本地玩家", Icon = "user"})
    local Section_LocalPlayer = PlayerTab:Section({TextSize = 17, Title = "玩家功能", TextXAlignment = "Left"})
    
    Section_LocalPlayer:Toggle({TextSize = 14, Title = "启用无限跳", Callback = function(state)
        InfiniteJumpEnabled = state
        if state then
            pcall(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) humanoid.JumpPower = DefaultJumpPower end
            end)
        end
    end, Default = false})

    Section_LocalPlayer:Toggle({TextSize = 14, Title = "加速移动", Callback = function(state) isSpeedEnabled = state updateSpeed() end, Default = false})
    Section_LocalPlayer:Slider({TextSize = 14, Title = "速度倍数", Desc = "调整移动速度倍数", Step = 0.1, Value = {Min = 1, Max = 5, Default = 2}, Callback = function(value) speedMultiplier = value if isSpeedEnabled then updateSpeed() end end})

    -- ===== 关于 =====
    local AboutTab = Window:Tab({Title = "关于", Icon = "info"})
    AboutTab:Section({Title = "脚本信息", TextSize = 16})
    AboutTab:Paragraph({Title = "苏脚本 | 通缉专用", Desc = "主要功能：\n• 愤怒机器人(hook)\n• 武器修改\n• 自动刷钱\n• 传送功能\n• 自瞄系统\n• Hitbox扩展\n• 本地玩家增强\n\n作者:苏屿 | QQ群:1015718032"})
    AboutTab:Button({Title = "检查更新", Desc = "检查脚本是否有更新版本", Icon = "refresh-cw", Callback = function()
        WindUI:Notify({Title = "检查更新", Content = "当前已是最新版本", Duration = 3})
    end})
    AboutTab:Button({Title = "反馈问题", Desc = "报告脚本使用中的问题", Icon = "alert-circle", Color = Color3.fromHex("#ff4830"), Callback = function()
        WindUI:Notify({Title = "反馈", Content = "请联系开发者反馈问题", Duration = 3})
    end})

    -- ===== 初始化 =====
    InitRootPart()
    
    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://88457346646245"
        snd.Volume = 1
        snd.Parent = SoundService
        snd:Play()
        snd.Ended:Connect(function() snd:Destroy() end)
    end)
    
    WindUI:Notify({Title = "苏脚本", Description = "加载成功 | 全部功能已就绪", Duration = 3})
end
