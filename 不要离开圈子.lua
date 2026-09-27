-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
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

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "不要离开圈子",
    Footer = "苏 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "不要离开圈子",
    Description = "创作者：苏帝\nQQ：3305310017\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('恐拜大帝将持续更新此脚本')
NoticeGroup:AddLabel('创作者：苏')

local MainFeatureGroup = Tabs.Main:AddLeftGroupbox("主要功能")
local KillAuraGroup = Tabs.Main:AddRightGroupbox("杀戮光环")

local WallParts = {}
local WallEnabled = false
local LastSafePos = nil
local HeartbeatConn = nil

local BaseCoords = {
    {-50.7, 4.4, 67.0},
    {-58.4, 4.4, 61.0},
    {-64.7, 4.4, 54.9},
    {-69.6, 4.4, 50.1},
    {-74.6, 4.4, 45.5},
    {-80.3, 4.4, 38.2},
    {-84.4, 4.4, 31.1},
    {-89.4, 4.4, 16.8},
    {-90.5, 4.4, 10.1},
    {-91.2, 4.4, 1.1},
    {-90.8, 4.4, -6.5},
    {-90.5, 4.4, -10.1},
    {-89.6, 4.4, -14.8},
    {-87.7, 4.4, -22.0},
    {-85.9, 4.4, -29.9},
    {-84.2, 4.4, -38.0},
    {-75.6, 4.4, -54.6},
    {-69.1, 4.4, -61.3},
    {-60.3, 4.4, -68.5},
    {-49.8, 4.4, -75.0},
    {-38.9, 4.4, -80.0},
    {-29.1, 4.4, -83.3},
    {-18.9, 4.4, -85.8},
    {-8.5, 4.4, -88.2},
    {3.8, 4.4, -89.6},
    {15.2, 4.4, -89.4},
    {26.5, 4.4, -87.7},
    {36.8, 4.4, -84.3},
    {47.3, 4.4, -78.1},
    {61.0, 4.4, -67.0},
    {70.2, 4.4, -55.4},
    {77.9, 4.4, -37.5},
    {83.6, 4.4, -10.6},
    {82.4, 4.4, 40.8},
    {70, 4.4, 55},
    {45, 4.4, 68},
    {15, 4.4, 75},
    {-15, 4.4, 74},
    {-35, 4.4, 70}
}

local CircleCenterX, CircleCenterZ = 0, 0
for _, c in pairs(BaseCoords) do
    CircleCenterX = CircleCenterX + c[1]
    CircleCenterZ = CircleCenterZ + c[3]
end
CircleCenterX = CircleCenterX / #BaseCoords
CircleCenterZ = CircleCenterZ / #BaseCoords

local function Densify(coords)
    local result = {}
    for i = 1, #coords do
        local n = i % #coords + 1
        local a = coords[i]
        local b = coords[n]
        table.insert(result, {a[1], a[2], a[3]})
        local dx = b[1] - a[1]
        local dz = b[3] - a[3]
        local dist = math.sqrt(dx * dx + dz * dz)
        if dist > 12 then
            local segs = math.ceil(dist / 10)
            for j = 1, segs - 1 do
                local t = j / segs
                table.insert(result, {a[1] + dx * t, a[2], a[3] + dz * t})
            end
        end
    end
    return result
end

local Coords = Densify(BaseCoords)

local function MakeWall()
    for _, p in pairs(WallParts) do
        p:Destroy()
    end
    WallParts = {}
    local cx, cz = 0, 0
    for _, c in pairs(Coords) do
        cx = cx + c[1]
        cz = cz + c[3]
    end
    cx = cx / #Coords
    cz = cz / #Coords
    local FinalCoords = {}
    for _, c in pairs(Coords) do
        local dx = cx - c[1]
        local dz = cz - c[3]
        local d = math.sqrt(dx * dx + dz * dz)
        if d > 0 then
            local r = (d - 3) / d
            table.insert(FinalCoords, {c[1] + dx * (1 - r), c[2], c[3] + dz * (1 - r)})
        else
            table.insert(FinalCoords, c)
        end
    end
    for i = 1, #FinalCoords do
        local n = i % #FinalCoords + 1
        local a = FinalCoords[i]
        local b = FinalCoords[n]
        local x1, z1 = a[1], a[3]
        local x2, z2 = b[1], b[3]
        local mx = (x1 + x2) / 2
        local mz = (z1 + z2) / 2
        local dx = x2 - x1
        local dz = z2 - z1
        local len = math.sqrt(dx * dx + dz * dz)
        if len > 0.1 then
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = true
            part.Transparency = 1
            part.Size = Vector3.new(12, 300, len)
            part.CFrame = CFrame.new(mx, 100, mz) * CFrame.Angles(0, math.atan2(dx, dz), 0)
            part.Parent = workspace
            table.insert(WallParts, part)
        end
    end
end

local function ClearWall()
    for _, p in pairs(WallParts) do
        p:Destroy()
    end
    WallParts = {}
end

local function PointInPolygon(px, pz, poly)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local xi, zi = poly[i][1], poly[i][3]
        local xj, zj = poly[j][1], poly[j][3]
        if ((zi > pz) ~= (zj > pz)) and (px < (xj - xi) * (pz - zi) / (zj - zi) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function GetNearestPointOnPolygon(px, pz, poly)
    local bestX, bestZ, bestDist = poly[1][1], poly[1][3], math.huge
    for i = 1, #poly do
        local n = i % #poly + 1
        local ax, az = poly[i][1], poly[i][3]
        local bx, bz = poly[n][1], poly[n][3]
        local dx = bx - ax
        local dz = bz - az
        local len = math.sqrt(dx * dx + dz * dz)
        if len > 0 then
            local t = math.clamp(((px - ax) * dx + (pz - az) * dz) / (len * len), 0, 1)
            local nx = ax + dx * t
            local nz = az + dz * t
            local dist = math.sqrt((px - nx) * (px - nx) + (pz - nz) * (pz - nz))
            if dist < bestDist then
                bestDist = dist
                bestX = nx
                bestZ = nz
            end
        end
    end
    return bestX, bestZ, bestDist
end

local function PullBack()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local px, pz = hrp.Position.X, hrp.Position.Z
    if not PointInPolygon(px, pz, Coords) then
        local nx, nz = GetNearestPointOnPolygon(px, pz, Coords)
        local ny = hrp.Position.Y
        if LastSafePos then
            hrp.CFrame = CFrame.new(LastSafePos.X, LastSafePos.Y, LastSafePos.Z)
            hrp.Velocity = Vector3.new(0, 0, 0)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        wait(0.01)
        hrp.CFrame = CFrame.new(nx, ny, nz)
        hrp.Velocity = Vector3.new(0, 0, 0)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        LastSafePos = Vector3.new(nx, ny, nz)
    else
        LastSafePos = hrp.Position
    end
end

local function StartLoop()
    if HeartbeatConn then HeartbeatConn:Disconnect() end
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        PullBack()
    end)
end

local function StopLoop()
    if HeartbeatConn then
        HeartbeatConn:Disconnect()
        HeartbeatConn = nil
    end
    LastSafePos = nil
end

MainFeatureGroup:AddToggle("WallToggle", {
    Text = "不会离开圈子",
    Default = false,
    Tooltip = "开启后在指定坐标圈内生成隐形墙壁并实时回拉",
    Callback = function(Value)
        WallEnabled = Value
        if WallEnabled then
            MakeWall()
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    LastSafePos = hrp.Position
                end
            end
            StartLoop()
        else
            ClearWall()
            StopLoop()
        end
    end,
})

player.CharacterAdded:Connect(function(char)
    if WallEnabled then
        wait(0.5)
        local hrp = char:WaitForChild("HumanoidRootPart")
        LastSafePos = hrp.Position
    end
end)

local AntiRagdollEnabled = false
local AntiRagdollHeartbeat = nil

local function BlockRagdoll()
    AntiRagdollHeartbeat = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            humanoid.AutoRotate = true
            pcall(function()
                char.Animate.Disabled = false
            end)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Anchored then
            hrp.Anchored = false
        end
    end)
end

local function UnblockRagdoll()
    if AntiRagdollHeartbeat then
        AntiRagdollHeartbeat:Disconnect()
        AntiRagdollHeartbeat = nil
    end
end

MainFeatureGroup:AddToggle("AntiRagdollToggle", {
    Text = "防摔倒",
    Default = false,
    Tooltip = "开启后防止被远程摔倒",
    Callback = function(Value)
        AntiRagdollEnabled = Value
        if AntiRagdollEnabled then
            BlockRagdoll()
        else
            UnblockRagdoll()
        end
    end,
})

player.CharacterAdded:Connect(function()
    if AntiRagdollEnabled then
        wait(0.5)
        BlockRagdoll()
    end
end)

local AutoDodgeEnabled = false
local AutoDodgeHeartbeat = nil

local function GetWaveHeight()
    local waveModel = workspace:FindFirstChild("WaveModel")
    if not waveModel then return nil end
    for _, child in ipairs(waveModel:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position.Y
        end
    end
    return nil
end

local function AutoDodgeLoop()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local waveY = GetWaveHeight()
    if waveY then
        local targetPos = Vector3.new(CircleCenterX, waveY + 10, CircleCenterZ)
        hrp.CFrame = CFrame.new(targetPos)
        hrp.Velocity = Vector3.new(0, 0, 0)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

local function StartAutoDodge()
    if AutoDodgeHeartbeat then AutoDodgeHeartbeat:Disconnect() end
    AutoDodgeHeartbeat = RunService.Heartbeat:Connect(AutoDodgeLoop)
end

local function StopAutoDodge()
    if AutoDodgeHeartbeat then
        AutoDodgeHeartbeat:Disconnect()
        AutoDodgeHeartbeat = nil
    end
end

MainFeatureGroup:AddToggle("AutoDodgeToggle", {
    Text = "自动躲避海啸",
    Default = false,
    Tooltip = "检测到海啸时自动移动到圈子正中央并比海啸高10米",
    Callback = function(Value)
        AutoDodgeEnabled = Value
        if AutoDodgeEnabled then
            StartAutoDodge()
        else
            StopAutoDodge()
        end
    end,
})

player.CharacterAdded:Connect(function()
    if AutoDodgeEnabled then
        wait(0.5)
        StartAutoDodge()
    end
end)

local AutoToiletEnabled = false
local AutoToiletThread = nil

local ToiletPos = Vector3.new(13.1, 4.4, 0.7)

local function FindDoor()
    local runtime = workspace:FindFirstChild("Runtime")
    local lootPoints = runtime and runtime:FindFirstChild("LootPoints")
    if lootPoints then
        local door = lootPoints:FindFirstChild("Door")
        if door then return door end
    end
    return workspace:FindFirstChild("Door")
end

local function FirePromptsInRange(center, range)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (parent.Position - center).Magnitude
                if dist <= range then
                    pcall(function()
                        fireproximityprompt(obj)
                    end)
                end
            end
        end
    end
end

local function ToiletOnce()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(ToiletPos)
    hrp.Velocity = Vector3.new(0, 0, 0)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
    task.wait(0.1)
    FirePromptsInRange(ToiletPos, 10)
end

local function StartAutoToilet()
    if AutoToiletThread then return end
    AutoToiletThread = task.spawn(function()
        while AutoToiletEnabled do
            ToiletOnce()
            task.wait(2)
        end
        AutoToiletThread = nil
    end)
end

local function StopAutoToilet()
    AutoToiletEnabled = false
    AutoToiletThread = nil
end

MainFeatureGroup:AddToggle("AutoToiletToggle", {
    Text = "自动上厕所",
    Default = false,
    Tooltip = "开启后自动传送到Door并交互",
    Callback = function(Value)
        AutoToiletEnabled = Value
        if AutoToiletEnabled then
            StartAutoToilet()
        else
            StopAutoToilet()
        end
    end,
})

MainFeatureGroup:AddButton("上厕所一次", function()
    ToiletOnce()
end)

player.CharacterAdded:Connect(function()
    if AutoToiletEnabled then
        wait(0.5)
        StartAutoToilet()
    end
end)

local AutoDodgeLaserEnabled = false
local AutoDodgeLaserHeartbeat = nil

local function FindLaserModel()
    return workspace:FindFirstChild("LaserModel")
end

local function GetLaserPosition()
    local laser = FindLaserModel()
    if not laser then return nil end
    if laser:IsA("Model") then
        local primary = laser.PrimaryPart
        if primary then return primary.Position end
        for _, child in ipairs(laser:GetChildren()) do
            if child:IsA("BasePart") then
                return child.Position
            end
        end
    elseif laser:IsA("BasePart") then
        return laser.Position
    end
    return nil
end

local function AutoDodgeLaserLoop()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local laserPos = GetLaserPosition()
    if not laserPos then return end
    local myPos = hrp.Position
    local dir = (myPos - laserPos)
    dir = Vector3.new(dir.X, 0, dir.Z)
    local dist = dir.Magnitude
    if dist > 0.001 then
        dir = dir.Unit
    else
        dir = Vector3.new(1, 0, 0)
    end
    local targetPos = laserPos + dir * 10
    targetPos = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
    hrp.CFrame = CFrame.new(targetPos)
    hrp.Velocity = Vector3.new(0, 0, 0)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end

local function StartAutoDodgeLaser()
    if AutoDodgeLaserHeartbeat then AutoDodgeLaserHeartbeat:Disconnect() end
    AutoDodgeLaserHeartbeat = RunService.Heartbeat:Connect(AutoDodgeLaserLoop)
end

local function StopAutoDodgeLaser()
    if AutoDodgeLaserHeartbeat then
        AutoDodgeLaserHeartbeat:Disconnect()
        AutoDodgeLaserHeartbeat = nil
    end
end

MainFeatureGroup:AddToggle("AutoDodgeLaserToggle", {
    Text = "自动躲避激光",
    Default = false,
    Tooltip = "检测到LaserModel时自动保持在它前方10米",
    Callback = function(Value)
        AutoDodgeLaserEnabled = Value
        if AutoDodgeLaserEnabled then
            StartAutoDodgeLaser()
        else
            StopAutoDodgeLaser()
        end
    end,
})

player.CharacterAdded:Connect(function()
    if AutoDodgeLaserEnabled then
        wait(0.5)
        StartAutoDodgeLaser()
    end
end)

local AutoSeatEnabled = false
local AutoSeatThread = nil
local AutoSeatSat = false

local function GetAllChairs()
    local chairs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Chair" and obj:IsA("Model") then
            table.insert(chairs, obj)
        end
    end
    return chairs
end

local function IsChairOccupied(chair)
    local seatPart = chair:FindFirstChild("SeatPart")
    if seatPart then
        local seat = seatPart:FindFirstChildOfClass("Seat")
        if seat and seat.Occupant then
            return true
        end
    end
    for _, child in ipairs(chair:GetDescendants()) do
        if child:IsA("Seat") and child.Occupant then
            return true
        end
        if child:IsA("VehicleSeat") and child.Occupant then
            return true
        end
    end
    return false
end

local function GetChairPosition(chair)
    if chair:IsA("Model") then
        local primary = chair.PrimaryPart
        if primary then return primary.Position end
        for _, child in ipairs(chair:GetChildren()) do
            if child:IsA("BasePart") then
                return child.Position
            end
        end
    end
    return nil
end

local function IsPlayerNearChair(chairPos)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - chairPos).Magnitude
                if dist <= 1 then
                    return true
                end
            end
        end
    end
    return false
end

local function AutoSeatLoop()
    while AutoSeatEnabled do
        local char = player.Character
        if not char then
            task.wait(1)
        else
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.SeatPart then
                AutoSeatSat = true
            end

            local chairs = GetAllChairs()
            if #chairs < 2 then
                AutoSeatSat = false
                task.wait(1)
            else
                if AutoSeatSat then
                    task.wait(1)
                else
                    local bestChair = nil
                    local bestDist = math.huge
                    for _, chair in ipairs(chairs) do
                        if IsChairOccupied(chair) then continue end
                        local pos = GetChairPosition(chair)
                        if not pos then continue end
                        if IsPlayerNearChair(pos) then continue end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        local dist = (pos - hrp.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestChair = chair
                        end
                    end

                    if bestChair then
                        local pos = GetChairPosition(bestChair)
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp and pos then
                            hrp.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Velocity = Vector3.new(0, 0, 0)
                                    part.RotVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                            task.wait(0.2)
                            if humanoid then
                                pcall(function()
                                    humanoid.Jump = true
                                end)
                            end
                            AutoSeatSat = true
                        end
                    end
                    task.wait(1)
                end
            end
        end
    end
    AutoSeatThread = nil
end

local function StartAutoSeat()
    if AutoSeatThread then return end
    AutoSeatSat = false
    AutoSeatThread = task.spawn(AutoSeatLoop)
end

local function StopAutoSeat()
    AutoSeatEnabled = false
    AutoSeatSat = false
    AutoSeatThread = nil
end

MainFeatureGroup:AddToggle("AutoSeatToggle", {
    Text = "自动座椅子",
    Default = false,
    Tooltip = "检测到多个椅子时自动坐到附近没人的椅子上",
    Callback = function(Value)
        AutoSeatEnabled = Value
        if AutoSeatEnabled then
            StartAutoSeat()
        else
            StopAutoSeat()
        end
    end,
})

player.CharacterAdded:Connect(function()
    if AutoSeatEnabled then
        wait(0.5)
        StartAutoSeat()
    end
end)

local AutoFoodEnabled = false
local AutoFoodThread = nil

local function GetAllFoodSpawns()
    local spawns = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "FoodSpawn" and obj:IsA("BasePart") then
            table.insert(spawns, obj)
        end
    end
    return spawns
end

local function GetNearestFoodSpawn()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local spawns = GetAllFoodSpawns()
    local best = nil
    local bestDist = math.huge
    for _, spawn in ipairs(spawns) do
        local dist = (spawn.Position - hrp.Position).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = spawn
        end
    end
    return best
end

local function IsHoldingFood()
    local char = player.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            return true
        end
    end
    return false
end

local function EquipFirstFood()
    local char = player.Character
    if not char then return end
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
            return
        end
    end
end

local function PressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function AutoFoodLoop()
    while AutoFoodEnabled do
        local char = player.Character
        if not char then
            task.wait(1)
        else
            local foodSpawn = GetNearestFoodSpawn()
            if foodSpawn then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(foodSpawn.Position)
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Velocity = Vector3.new(0, 0, 0)
                            part.RotVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                    task.wait(0.1)
                    FirePromptsInRange(foodSpawn.Position, 10)
                    task.wait(0.2)
                end
            end

            if not IsHoldingFood() then
                EquipFirstFood()
                task.wait(0.2)
            end

            if IsHoldingFood() then
                PressE()
            end

            task.wait(0.5)
        end
    end
    AutoFoodThread = nil
end

local function StartAutoFood()
    if AutoFoodThread then return end
    AutoFoodThread = task.spawn(AutoFoodLoop)
end

local function StopAutoFood()
    AutoFoodEnabled = false
    AutoFoodThread = nil
end

MainFeatureGroup:AddToggle("AutoFoodToggle", {
    Text = "自动拿食物",
    Default = false,
    Tooltip = "自动传送到FoodSpawn并交互拿取",
    Callback = function(Value)
        AutoFoodEnabled = Value
        if AutoFoodEnabled then
            StartAutoFood()
        else
            StopAutoFood()
        end
    end,
})

MainFeatureGroup:AddToggle("AutoEatToggle", {
    Text = "自动吃食物",
    Default = false,
    Tooltip = "自动装备食物并按E键吃",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    local char = player.Character
                    if char then
                        if not IsHoldingFood() then
                            EquipFirstFood()
                            task.wait(0.2)
                        end
                        if IsHoldingFood() then
                            PressE()
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

player.CharacterAdded:Connect(function()
    if AutoFoodEnabled then
        wait(0.5)
        StartAutoFood()
    end
end)

local function FindGasMask()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GasMask" then
            if obj:IsA("Model") then
                local primary = obj.PrimaryPart
                if primary then return primary.Position end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then
                        return child.Position
                    end
                end
            elseif obj:IsA("BasePart") then
                return obj.Position
            end
        end
    end
    return nil
end

MainFeatureGroup:AddButton("传送到防毒面罩", function()
    local pos = FindGasMask()
    if not pos then
        Library:Notify({
            Title = "提示",
            Description = "未找到防毒面罩",
            Time = 3,
        })
        return
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
    hrp.Velocity = Vector3.new(0, 0, 0)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

local function FindTowerCoil()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "ВИСЯЧКА" then
            if obj:IsA("Model") then
                local primary = obj.PrimaryPart
                if primary then return primary.Position end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then
                        return child.Position
                    end
                end
            elseif obj:IsA("BasePart") then
                return obj.Position
            end
        end
    end
    return nil
end

MainFeatureGroup:AddButton("自动拿取高塔线圈", function()
    local pos = FindTowerCoil()
    if not pos then
        Library:Notify({
            Title = "提示",
            Description = "未找到高塔线圈",
            Time = 3,
        })
        return
    end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
    hrp.Velocity = Vector3.new(0, 0, 0)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.new(0, 0, 0)
            part.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
    task.wait(0.1)
    FirePromptsInRange(pos, 10)
end)

local SnowballKillAuraEnabled = false
local SnowballKillAuraRange = 50
local SnowballTool = nil
local SnowballConfig = nil
local SnowballRemote = nil
local SnowballModule = nil
local SnowballAnims = nil
local SnowballAnimator = nil

local function FindSnowballTool()
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if tool:FindFirstChild("Config") and tool:FindFirstChild("Animations") then
                    return tool
                end
                if tool.Name == "Snowball" then
                    return tool
                end
            end
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                if tool:FindFirstChild("Config") and tool:FindFirstChild("Animations") then
                    return tool
                end
                if tool.Name == "Snowball" then
                    return tool
                end
            end
        end
    end
    return nil
end

local function UpdateSnowballRefs()
    SnowballTool = FindSnowballTool()
    if SnowballTool then
        SnowballConfig = SnowballTool:FindFirstChild("Config")
        local animsFolder = SnowballTool:FindFirstChild("Animations")
        local char = player.Character
        if char and animsFolder then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                SnowballAnimator = humanoid:FindFirstChild("Animator")
                if SnowballAnimator then
                    SnowballAnims = {}
                    for _, anim in ipairs(animsFolder:GetChildren()) do
                        SnowballAnims[anim.Name] = SnowballAnimator:LoadAnimation(anim)
                    end
                    if SnowballAnims.Throw then
                        SnowballAnims.Throw.Ended:Connect(function()
                            if SnowballAnims.Recharge then
                                SnowballAnims.Recharge:Play()
                            end
                            local sounds = SnowballTool:FindFirstChild("Sounds")
                            if sounds and sounds:FindFirstChild("Recharge") then
                                sounds.Recharge:Play()
                            end
                        end)
                    end
                end
            end
        end
    end
    local rs = game:GetService("ReplicatedStorage")
    local sf = rs:FindFirstChild("Snowball")
    if sf then
        SnowballRemote = sf:FindFirstChild("RemoteEvent")
        local mod = sf:FindFirstChild("Snowball")
        if mod then
            SnowballModule = require(mod)
        end
    end
end

local function ClearSnowballAnims()
    if SnowballAnims then
        for _, anim in pairs(SnowballAnims) do
            anim:Stop()
            anim:Destroy()
        end
        SnowballAnims = nil
    end
    SnowballAnimator = nil
    SnowballConfig = nil
end

local function GetNearbyPlayers(range)
    local nearby = {}
    local char = player.Character
    if not char then return nearby end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nearby end
    local myPos = hrp.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            if phrp then
                local dist = (phrp.Position - myPos).Magnitude
                if dist <= range then
                    table.insert(nearby, {Player = p, HRP = phrp, Distance = dist})
                end
            end
        end
    end
    return nearby
end

local function SnowballThrowAtTarget(targetHRP)
    if not SnowballModule or not SnowballRemote then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    if humanoid:HasTag("SnowballHitEffects") then return end
    local muzzleForward = 0
    local muzzleUp = 0
    local delayBefore = 0
    if SnowballConfig then
        local mf = SnowballConfig:FindFirstChild("MuzzleOffsetForward")
        local mu = SnowballConfig:FindFirstChild("MuzzleOffsetUp")
        local db = SnowballConfig:FindFirstChild("DelayBeforeSnowballThrow")
        if mf then muzzleForward = mf.Value end
        if mu then muzzleUp = mu.Value end
        if db then delayBefore = db.Value end
    end
    if SnowballAnims and SnowballAnims.Throw then
        SnowballAnims.Throw:Play()
    end
    task.wait(delayBefore)
    local v14 = hrp.CFrame + hrp.CFrame.LookVector * muzzleForward
    local v16 = v14 + Vector3.new(0, muzzleUp, 0)
    local v17 = targetHRP.Position
    if (v17 - v16.Position).Magnitude > 100 then
        v17 = hrp.Position + (v17 - hrp.Position).Unit * 100
    end
    local v18 = (v17 - v16.Position).Unit
    if SnowballModule:Create(player, v18) then
        SnowballRemote:FireServer(v18)
    end
end

local function SnowballKillAuraLoop()
    while SnowballKillAuraEnabled do
        local char = player.Character
        if not char then
            task.wait(0.5)
        else
            local equipped = false
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name == "Snowball" or (tool:FindFirstChild("Config") and tool:FindFirstChild("Animations"))) then
                    equipped = true
                    if tool ~= SnowballTool then
                        UpdateSnowballRefs()
                    end
                    break
                end
            end
            if not equipped then
                task.wait(0.5)
            else
                local targets = GetNearbyPlayers(SnowballKillAuraRange)
                for _, target in ipairs(targets) do
                    if not SnowballKillAuraEnabled then break end
                    SnowballThrowAtTarget(target.HRP)
                    task.wait(0.05)
                end
                task.wait(0.05)
            end
        end
    end
end

local RedLightKillAuraEnabled = false
local RedLightKillAuraRange = 50
local RedLightDamage = 10
local RedLightRemote = nil
local RedLightReady = true

local function FindRedLightRemote()
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj.Name == "RemoteBridge" and obj:IsA("RemoteEvent") then
                return obj
            end
        end
    end
    local rs = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(rs:GetDescendants()) do
        if obj.Name == "RemoteBridge" and obj:IsA("RemoteEvent") then
            return obj
        end
    end
    return nil
end

local function PlayRedLightSound(soundId, volume, duration)
    local sound = Instance.new("Sound")
    sound.SoundId = ("rbxassetid://%s"):format(tostring(soundId))
    sound.Volume = volume
    sound.Parent = SoundService
    TweenService:Create(sound, TweenInfo.new(0.5), {Volume = volume}):Play()
    sound:Play()
    task.delay(duration or sound.TimeLength or 0.3, function()
        TweenService:Create(sound, TweenInfo.new(1), {Volume = 0}):Play()
        task.delay(1, function()
            sound:Destroy()
        end)
    end)
end

local function DamageTargetPlayer(targetPlayer)
    if not RedLightReady then return end
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid then return end
    RedLightReady = false
    if RedLightRemote then
        pcall(function()
            RedLightRemote:FireServer()
        end)
    end
    task.wait(0.5)
    PlayRedLightSound(4502821590, 0.7, 0.3)
    local damage = RedLightDamage
    if targetPlayer:GetAttribute("Amulet") == "Helmet" then
        damage = damage - damage * 5 / 100
    end
    targetHumanoid:TakeDamage(damage)
    task.delay(0.1, function()
        RedLightReady = true
    end)
end

local function RedLightKillAuraLoop()
    while RedLightKillAuraEnabled do
        local char = player.Character
        if not char then
            task.wait(0.5)
        else
            local targets = GetNearbyPlayers(RedLightKillAuraRange)
            for _, target in ipairs(targets) do
                if not RedLightKillAuraEnabled then break end
                DamageTargetPlayer(target.Player)
                task.wait(0.1)
            end
            task.wait(0.1)
        end
    end
end

KillAuraGroup:AddToggle("SnowballKillAuraToggle", {
    Text = "雪球杀戮光环（需要装备雪球）",
    Default = false,
    Tooltip = "开启后自动攻击范围内的所有玩家，需要装备雪球道具",
    Callback = function(Value)
        SnowballKillAuraEnabled = Value
        if Value then
            UpdateSnowballRefs()
            task.spawn(SnowballKillAuraLoop)
        end
    end,
})

KillAuraGroup:AddSlider("SnowballKillAuraRangeSlider", {
    Text = "雪球杀戮光环范围",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        SnowballKillAuraRange = Value
    end,
})

KillAuraGroup:AddToggle("RedLightKillAuraToggle", {
    Text = "红绿灯杀戮光环",
    Default = false,
    Tooltip = "开启后自动对范围内玩家使用红绿灯扣血事件",
    Callback = function(Value)
        RedLightKillAuraEnabled = Value
        if Value then
            RedLightRemote = FindRedLightRemote()
            task.spawn(RedLightKillAuraLoop)
        end
    end,
})

KillAuraGroup:AddSlider("RedLightKillAuraRangeSlider", {
    Text = "红绿灯杀戮光环范围",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        RedLightKillAuraRange = Value
    end,
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    if WallEnabled then
        ClearWall()
        StopLoop()
    end
    if AntiRagdollEnabled then
        UnblockRagdoll()
    end
    AutoDodgeEnabled = false
    StopAutoDodge()
    AutoToiletEnabled = false
    AutoDodgeLaserEnabled = false
    StopAutoDodgeLaser()
    AutoSeatEnabled = false
    AutoFoodEnabled = false
    SnowballKillAuraEnabled = false
    RedLightKillAuraEnabled = false
    ClearSnowballAnims()
    Library:Unload()
end)

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptTheme")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("MyScriptConfig")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

player.CharacterAdded:Connect(function(char)
    wait(0.5)
    local humanoid = char:WaitForChild("Humanoid")
    SnowballAnimator = humanoid:WaitForChild("Animator")
    UpdateSnowballRefs()
    if SnowballKillAuraEnabled then
        task.spawn(SnowballKillAuraLoop)
    end
end)

if player.Character then
    player.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            if child.Name == "Snowball" or (child:FindFirstChild("Config") and child:FindFirstChild("Animations")) then
                UpdateSnowballRefs()
            end
        end
    end)

    player.Character.ChildRemoved:Connect(function(child)
        if child == SnowballTool then
            ClearSnowballAnims()
            SnowballTool = nil
        end
    end)
else
    player.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                if child.Name == "Snowball" or (child:FindFirstChild("Config") and child:FindFirstChild("Animations")) then
                    UpdateSnowballRefs()
                end
            end
        end)

        char.ChildRemoved:Connect(function(child)
            if child == SnowballTool then
                ClearSnowballAnims()
                SnowballTool = nil
            end
        end)
    end)
end

