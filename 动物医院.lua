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

local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local sanityConn
local crazySanityConn
local crazyDeductConn
local autoInteractConn
local autoInteractRange = 20

local Window = Library:CreateWindow({
    Title = "动物医院",
    Footer = "苏 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("动物医院脚本 - 创作者：苏", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("功能", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('我们将持续更新此脚本')
NoticeGroup:AddLabel('创作者：苏')

local FuncGroup = Tabs.Main:AddLeftGroupbox("核心功能")

local sanityInjected = false
local sanityAttrConn = nil
local sanityHeartbeatConn = nil

local function keepSanityFull()
	pcall(function()
		LocalPlayer:SetAttribute("Sanity", 100)
	end)
end

FuncGroup:AddToggle('SanityToggle', {
	Text = '无限理智(三合一最强版)',
	Default = false,
	Tooltip = '注入Lib + 属性监听 + 心跳保持，全理智通用',
	Callback = function(Value)
		if Value then
			if not sanityInjected then
				pcall(function()
					local Lib = require(ReplicatedStorage:WaitForChild("Lib"))
					Lib.Inject("PlayerLostSanity", keepSanityFull)
					sanityInjected = true
				end)
			end
			sanityAttrConn = LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(keepSanityFull)
			sanityHeartbeatConn = RunService.Heartbeat:Connect(keepSanityFull)
			keepSanityFull()
			Library:Notify("无限理智(三合一最强版)已开启", 3)
		else
			if sanityAttrConn then
				sanityAttrConn:Disconnect()
				sanityAttrConn = nil
			end
			if sanityHeartbeatConn then
				sanityHeartbeatConn:Disconnect()
				sanityHeartbeatConn = nil
			end
			Library:Notify("无限理智已关闭", 3)
		end
	end
})

FuncGroup:AddToggle('CrazySanityToggle', {
    Text = '疯狂加理智',
    Default = false,
    Tooltip = '持续疯狂向服务器发送负值理智请求，全理智通用',
    Callback = function(Value)
        if crazySanityConn then
            pcall(function() crazySanityConn:Disconnect() end)
            crazySanityConn = nil
        end
        if Value then
            local event = ReplicatedStorage.Util.Net:FindFirstChild("RE/PlayerLostSanity")
            if not event then
                Library:Notify("未找到 RE/PlayerLostSanity 事件", 3)
                return
            end
            crazySanityConn = RunService.Heartbeat:Connect(function()
                local args = {
                    [1] = -1,
                    [2] = "Job Stress",
                    [3] = true
                }
                pcall(function()
                    event:FireServer(unpack(args))
                end)
            end)
            Library:Notify("疯狂加理智已开启", 3)
        else
            Library:Notify("疯狂加理智已关闭", 3)
        end
    end
})

FuncGroup:AddToggle('CrazyDeductToggle', {
    Text = '疯狂扣理智',
    Default = false,
    Tooltip = '持续疯狂向服务器发送正值理智扣除请求，全理智通用',
    Callback = function(Value)
        if crazyDeductConn then
            pcall(function() crazyDeductConn:Disconnect() end)
            crazyDeductConn = nil
        end
        if Value then
            local event = ReplicatedStorage.Util.Net:FindFirstChild("RE/PlayerLostSanity")
            if not event then
                Library:Notify("未找到 RE/PlayerLostSanity 事件", 3)
                return
            end
            crazyDeductConn = RunService.Heartbeat:Connect(function()
                local args = {
                    [1] = 1,
                    [2] = "Job Stress",
                    [3] = true
                }
                pcall(function()
                    event:FireServer(unpack(args))
                end)
            end)
            Library:Notify("疯狂扣理智已开启", 3)
        else
            Library:Notify("疯狂扣理智已关闭", 3)
        end
    end
})

local addedConn

local function isAnomaly(npc)
    local attr = npc:GetAttributes()
    return attr.Skinwalker
        or attr.SkinwalkerEasy
        or attr.PenaltyWhenLettingIn
        or attr.PhotoEffect == "CursedPhoto"
        or attr.PhotoEffect2 == "CursedPhoto"
end

local function removeEsp(npc)
    local highlight = npc:FindFirstChild("PurityHighlight")
    if highlight then highlight:Destroy() end
    local billboard = npc:FindFirstChild("PurityESP")
    if billboard then billboard:Destroy() end
end

local function addEsp(npc)
    if npc:FindFirstChild("PurityHighlight") then return end
    local root = npc.PrimaryPart
        or npc:FindFirstChild("HumanoidRootPart")
        or npc:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PurityHighlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 70, 70)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = npc

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PurityESP"
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(120, 22)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.MaxDistance = math.huge
    billboard.Parent = npc

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = "Anomaly"
    label.TextColor3 = Color3.fromRGB(255, 70, 70)
    label.TextStrokeTransparency = 0
    label.TextScaled = false
    label.TextSize = 16
    label.Parent = billboard
end

local function updateNpc(npc)
    if not npc:IsA("Model") then return end
    if npc.Name:lower() == "doctor" then return end
    removeEsp(npc)
    if isAnomaly(npc) then addEsp(npc) end
end


local roomTargets = {
	[1] = Vector3.new(-176.97714233398438, 3.457531213760376, -44.89796829223633),
	[2] = Vector3.new(-113.41072082519531, 3.457531213760376, -56.384185791015625),
	[3] = Vector3.new(-177.35275268554688, 3.457531213760376, -83.09056091308594),
	[4] = Vector3.new(-113.19596099853516, 3.457531213760376, -94.8563461303711),
	[5] = Vector3.new(-149.87570190429688, 3.4575307369232178, -124.0009994506836),
}

local medicinePositions = {
	["Eye Drops"] = Vector3.new(-153.5434112548828, 3.4575307369232178, -56.69102478027344),
	["IV Drops"] = Vector3.new(-153.68731689453125, 3.5194523334503174, -59.822845458984375),
	["Medkit"] = Vector3.new(-153.85501098632812, 3.535428047180176, -68.59256744384766),
	["Thermo"] = Vector3.new(-153.8463592529297, 3.5348756313323975, -72.05299377441406),
	["Ointment"] = Vector3.new(-153.8675994873047, 3.4796974658966064, -80.22147369384766),
	["Bandages"] = Vector3.new(-153.80979919433594, 3.5194523334503174, -83.2136459350586),
	["Maple Syrup"] = Vector3.new(-135.71234130859375, 3.4575307369232178, -81.63136291503906),
	["Cough Syrup"] = Vector3.new(-135.74819946289062, 3.4575307369232178, -78.73336029003906),
	["Medicine"] = Vector3.new(-135.69619750976562, 3.4575307369232178, -61.638641357421875),
	["Herbs"] = Vector3.new(-135.89955139160156, 3.4575307369232178, -58.78034973144531),
}

local Medical = workspace:FindFirstChild("Rooms") and workspace.Rooms:FindFirstChild("Medical")
local NPCs = workspace:FindFirstChild("NPCs")
local scanRoot = workspace:FindFirstChild("Runtime") and workspace.Runtime:FindFirstChild("LootPoints") or workspace
local initPos = Vector3.new(-104.34941864013672, 3.412531614303589, 0.06773799657821655)

getgenv().AutoNpcFarm = false
getgenv().AutoMedicine = false

local npcTransit = false
local npcTransitStart = 0
local npcTargetPos = nil

local function npcInteract(char)
	if not char or not char:FindFirstChild("Head") then return end
	pcall(function()
		local headY = char.Head.Position.Y
		for _, obj in ipairs(scanRoot:GetDescendants()) do
			if obj:IsA("ProximityPrompt") then
				local parent = obj.Parent
				if parent then
					local pos
					if parent:IsA("Model") then
						pos = parent:GetPivot().Position
					elseif parent:IsA("BasePart") then
						pos = parent.Position
					end
					if pos and pos.Y <= headY then
						fireproximityprompt(obj)
					end
				end
			end
		end
	end)
end

task.spawn(function()
	while true do
		if getgenv().AutoNpcFarm then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
				if not npcTransit then
					pcall(function()
						char.HumanoidRootPart.CFrame = CFrame.new(initPos)
					end)
					npcInteract(char)
					if NPCs and Medical then
						for roomIdx = 1, 5 do
							local room = Medical:FindFirstChild("Room" .. roomIdx)
							if room then
								local bed = room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("Bed")
								if bed then
									local bedPos = bed:IsA("Model") and bed:GetPivot().Position or bed.Position
									for _, npc in ipairs(NPCs:GetChildren()) do
										if npc:IsA("Model") then
											local npcPos = npc:GetPivot().Position
											if (npcPos - bedPos).Magnitude <= 5 then
												pcall(function()
													npc:MoveTo(roomTargets[roomIdx])
												end)
												npcTargetPos = roomTargets[roomIdx]
												npcTransit = true
												npcTransitStart = tick()
												break
											end
										end
									end
									if npcTransit then break end
								end
							end
							if npcTransit then break end
						end
					end
				else
					local elapsed = tick() - npcTransitStart
					if elapsed < 3 then
						pcall(function()
							char.HumanoidRootPart.CFrame = CFrame.new(initPos)
						end)
						npcInteract(char)
					elseif elapsed < 13 then
						if npcTargetPos then
							pcall(function()
								char.HumanoidRootPart.CFrame = CFrame.new(npcTargetPos)
							end)
						end
						npcInteract(char)
					else
						pcall(function()
							char.HumanoidRootPart.CFrame = CFrame.new(initPos)
						end)
						npcInteract(char)
						npcTransit = false
						npcTargetPos = nil
					end
				end
			end
		end
		task.wait(1)
	end
end)

local vim = game:GetService("VirtualInputManager")

local function pressNumberKeys()
	for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}) do
		vim:SendKeyEvent(true, key, false, game)
		task.wait(0.05)
		vim:SendKeyEvent(false, key, false, game)
		task.wait(0.05)
	end
end

local function doMedicineInteract()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then return end
	local rootPos = char.HumanoidRootPart.Position
	local headY = char.Head.Position.Y
	local nearestPrompt = nil
	local nearestDist = math.huge
	for _, obj in ipairs(scanRoot:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			local parent = obj.Parent
			if parent then
				local pos
				if parent:IsA("Model") then
					pos = parent:GetPivot().Position
				elseif parent:IsA("BasePart") then
					pos = parent.Position
				end
				if pos and pos.Y <= headY then
					local dist = (pos - rootPos).Magnitude
					if dist < nearestDist then
						nearestDist = dist
						nearestPrompt = obj
					end
				end
			end
		end
	end
	if nearestPrompt then
		pcall(function() fireproximityprompt(nearestPrompt) end)
	end
end

local function hasItem(name)
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp and bp:FindFirstChild(name) then return true end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(name) then return true end
	return false
end

local function getBed(roomIndex)
	return Medical:FindFirstChild("Room"..roomIndex) and Medical["Room"..roomIndex]:FindFirstChild("Minigame") and Medical["Room"..roomIndex].Minigame:FindFirstChild("Bed")
end

local processedTasks = {}

local function scanRequest()
	for key, _ in pairs(processedTasks) do
		local roomIdxStr, itemName = key:match("^(\d+)_(.+)$")
		if roomIdxStr and itemName then
			local roomIdx = tonumber(roomIdxStr)
			local room = Medical:FindFirstChild("Room"..roomIdx)
			if room then
				local inv = room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("TV") and room.Minigame.TV:FindFirstChild("Screen") and room.Minigame.TV.Screen:FindFirstChild("UI") and room.Minigame.TV.Screen.UI:FindFirstChild("Report") and room.Minigame.TV.Screen.UI.Report:FindFirstChild("inv")
				if inv and not inv:FindFirstChild(itemName) then
					processedTasks[key] = nil
				end
			else
				processedTasks[key] = nil
			end
		end
	end
	for roomIdx = 1, 5 do
		local room = Medical:FindFirstChild("Room"..roomIdx)
		if room then
			local inv = room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("TV") and room.Minigame.TV:FindFirstChild("Screen") and room.Minigame.TV.Screen:FindFirstChild("UI") and room.Minigame.TV.Screen.UI:FindFirstChild("Report") and room.Minigame.TV.Screen.UI.Report:FindFirstChild("inv")
			if inv then
				for itemName, _ in pairs(medicinePositions) do
					if inv:FindFirstChild(itemName) then
						local key = roomIdx .. "_" .. itemName
						if not processedTasks[key] then
							return itemName, roomIdx
						end
					end
				end
			end
		end
	end
	return nil, nil
end

local medState = "idle"
local medItem = nil
local medRoom = nil
local medReturnStart = 0

task.spawn(function()
	while true do
		if getgenv().AutoMedicine then
			if medState == "idle" then
				local item, roomIdx = scanRequest()
				if item and roomIdx then
					medItem = item
					medRoom = roomIdx
					medState = "fetching"
				end
			elseif medState == "fetching" then
				local pos = medicinePositions[medItem]
				if pos then
					pcall(function()
						LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
					end)
				end
				doMedicineInteract()
				pressNumberKeys()
				if hasItem(medItem) then
					medState = "delivering"
				end
			elseif medState == "delivering" then
				local bed = getBed(medRoom)
				if bed then
					local bedPos = bed.PrimaryPart and bed.PrimaryPart.Position or bed:GetPivot().Position
					pcall(function()
						LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(bedPos)
					end)
					doMedicineInteract()
					pressNumberKeys()
				else
					medState = "returning"
					medReturnStart = tick()
				end
				if not hasItem(medItem) then
					local key = medRoom .. "_" .. medItem
					processedTasks[key] = true
					medState = "returning"
					medReturnStart = tick()
				end
			elseif medState == "returning" then
				pcall(function()
					LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(initPos)
				end)
				if (tick() - medReturnStart) >= 2 then
					medState = "idle"
				end
			end
		end
		task.wait(1)
	end
end)

FuncGroup:AddToggle('AutoNpcFarmToggle', {
	Text = '入驻+检测农场（不要与自动治疗同时开）',
	Default = false,
	Tooltip = '自动NPC农场，不能与自动治疗同时开启',
	Callback = function(Value)
		getgenv().AutoNpcFarm = Value
		if Value and getgenv().AutoMedicine then
			getgenv().AutoMedicine = false
			Library:Notify("已关闭自动治疗，不能同时开启", 3)
		end
	end
})

FuncGroup:AddToggle('AutoMedicineToggle', {
	Text = '自动治疗（不要与自动农场同时开）',
	Default = false,
	Tooltip = '自动治疗，需要先完成入住',
	Callback = function(Value)
		getgenv().AutoMedicine = Value
		if Value and getgenv().AutoNpcFarm then
			getgenv().AutoNpcFarm = false
			Library:Notify("已关闭自动农场，不能同时开启", 3)
		end
	end
})

FuncGroup:AddToggle('AnomalyESPToggle', {
    Text = '异常体透视',
    Default = false,
    Tooltip = '高亮显示异常体并标注名称',
    Callback = function(state)
        if addedConn then
            addedConn:Disconnect()
            addedConn = nil
        end
        for _, npc in ipairs(workspace.NPCs:GetChildren()) do
            removeEsp(npc)
        end
        if not state then return end
        for _, npc in ipairs(workspace.NPCs:GetChildren()) do
            updateNpc(npc)
        end
        addedConn = workspace.NPCs.ChildAdded:Connect(function(npc)
            task.defer(updateNpc, npc)
        end)
    end
})

local dustConn = nil
local dustEnabled = false

FuncGroup:AddToggle('DustToggle', {
    Text = '反延迟',
    Default = false,
    Tooltip = '删除延迟相关的地图部件以减少延迟',
    Callback = function(state)
        dustEnabled = state
        if state then
            local ws = workspace
            local targets = {
                ws.Baseplate,
                ws:FindFirstChild("HD Particles (Anime)"),
                ws.Doors,
                ws.Effects,
                ws:GetChildren()[149],
                ws:GetChildren()[135]
            }
            for _, obj in pairs(targets) do
                if obj and obj.Destroy then obj:Destroy() end
            end
            Library:Notify("反延迟已执行", 3)
        end
    end
})

local GeneralGroup = Tabs.Main:AddRightGroupbox("通用功能")

GeneralGroup:AddButton({
    Text = '复活一次',
    Tooltip = '复制当前服务器实例ID并重进当前服务器',
    Func = function()
        local jobId = game.JobId
        if jobId and jobId ~= "" then
            pcall(function()
                setclipboard(jobId)
            end)
            Library:Notify("已复制实例ID，正在重进当前服务器", 3)
            task.wait(0.5)
            pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
            end)
        else
            Library:Notify("获取实例ID失败，无法重进", 3)
        end
    end
})

GeneralGroup:AddToggle('AutoInteractToggle', {
    Text = '自动交互',
    Default = false,
    Tooltip = '自动触发范围内的 ProximityPrompt',
    Callback = function(Value)
        if autoInteractConn then
            autoInteractConn:Disconnect()
            autoInteractConn = nil
        end
        if Value then
            autoInteractConn = RunService.Heartbeat:Connect(function()
                local wow_player = Players.LocalPlayer
                local wow_char = wow_player.Character
                if not wow_char then return end
                local wow_hrp = wow_char:FindFirstChild("HumanoidRootPart")
                if not wow_hrp then return end
                local wow_runtime = workspace:FindFirstChild("Runtime")
                local wow_scanRoot = wow_runtime and wow_runtime:FindFirstChild("LootPoints") or workspace
                for _, wow_obj in ipairs(wow_scanRoot:GetDescendants()) do
                    if wow_obj:IsA("ProximityPrompt") then
                        local wow_parent = wow_obj.Parent
                        if wow_parent and wow_parent:IsA("BasePart") then
                            local wow_dist = (wow_parent.Position - wow_hrp.Position).Magnitude
                            if wow_dist <= autoInteractRange then
                                pcall(function()
                                    fireproximityprompt(wow_obj)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
})

GeneralGroup:AddSlider('AutoInteractRange', {
    Text = '交互范围',
    Default = 20,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        autoInteractRange = Value
    end
})

local noclipConn = nil
local noclipEnabled = false

GeneralGroup:AddToggle('NoclipToggle', {
    Text = '穿墙',
    Default = false,
    Tooltip = '关闭自身碰撞，可以穿过墙壁和障碍物',
    Callback = function(state)
        noclipEnabled = state
        if noclipConn then
            pcall(function() noclipConn:Disconnect() end)
            noclipConn = nil
        end
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
            Library:Notify("穿墙已开启", 3)
        else
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            Library:Notify("穿墙已关闭", 3)
        end
    end
})

local speedConn = nil
local speedValue = 16

local function getHumanoid()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChildOfClass("Humanoid") end
end

local function startSpeedAntiPull(speed)
    if speedConn then speedConn:Disconnect() end
    speedConn = RunService.Heartbeat:Connect(function()
        local hum = getHumanoid()
        if hum and hum.WalkSpeed ~= speed then
            hum.WalkSpeed = speed
        end
    end)
end

local function stopSpeedAntiPull()
    if speedConn then speedConn:Disconnect() end
    speedConn = nil
end

GeneralGroup:AddToggle('SpeedToggle', {
    Text = '修改移速',
    Default = false,
    Tooltip = '修改玩家移动速度',
    Callback = function(state)
        if state then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = speedValue end
            startSpeedAntiPull(speedValue)
            Library:Notify("修改移速已开启，当前移速：" .. speedValue, 3)
        else
            stopSpeedAntiPull()
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 end
            Library:Notify("修改移速已关闭，恢复默认移速", 3)
        end
    end
})

GeneralGroup:AddSlider('SpeedSlider', {
    Text = '移速数值',
    Default = 16,
    Min = 5,
    Max = 1000,
    Rounding = 0,
    Suffix = "",
    Callback = function(Value)
        speedValue = Value
        if Toggles.SpeedToggle and Toggles.SpeedToggle.Value then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = Value end
            startSpeedAntiPull(Value)
        end
    end
})

local flyActive = false
local flyConn = nil
local flyBodyVelocity = nil
local flyRotConn = nil
local flyAnimTrack = nil

local function getRoot()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function getHum()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChildOfClass("Humanoid") end
end

local function startFlying()
    local root = getRoot()
    if not root then return end
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVelocity.P = 1250
    flyBodyVelocity.Parent = root
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local camera = workspace.CurrentCamera
        local camLook = camera.CFrame.LookVector
        if flyBodyVelocity then
            flyBodyVelocity.Velocity = camLook * 50
        end
    end)
    flyRotConn = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local root = getRoot()
        if root then
            local camera = workspace.CurrentCamera
            root.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
        end
    end)
    local hum = getHum()
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://282574440"
        flyAnimTrack = hum:LoadAnimation(anim)
        if flyAnimTrack then
            flyAnimTrack.Looped = true
            flyAnimTrack:Play()
        end
    end
end

local function stopFlying()
    flyActive = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyRotConn then flyRotConn:Disconnect() flyRotConn = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyAnimTrack then flyAnimTrack:Stop() flyAnimTrack = nil end
end

GeneralGroup:AddToggle('FlyToggle', {
    Text = '飞行',
    Default = false,
    Tooltip = '开启飞行模式，按W前进',
    Callback = function(state)
        flyActive = state
        if state then
            startFlying()
            Library:Notify("飞行已开启", 3)
        else
            stopFlying()
            Library:Notify("飞行已关闭", 3)
        end
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    if sanityConn then sanityConn:Disconnect() end
    if crazySanityConn then crazySanityConn:Disconnect() end
    if crazyDeductConn then crazyDeductConn:Disconnect() end
    if addedConn then addedConn:Disconnect() end
    if autoInteractConn then autoInteractConn:Disconnect() end
    if getgenv().AutoNpcFarm then getgenv().AutoNpcFarm = false end
    if getgenv().AutoMedicine then getgenv().AutoMedicine = false end
    if noclipConn then noclipConn:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    stopFlying()
    Library:Unload()
end })

SettingsGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

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
