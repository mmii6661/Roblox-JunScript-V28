-- ===== 服务 =====
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ===== 小工具 =====
local function new(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		pcall(function()
			inst[k] = v
		end)
	end
	return inst
end

local function tween(inst, info, goal)
	return TweenService:Create(inst, info, goal)
end

local TweenInfoDefault = TweenInfo.new(
	0.18,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

-- ===== 根 UI =====
local ScreenGui = new("ScreenGui", {
	Name = "SuScriptUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Parent = PlayerGui
})

-- ========================================
-- ===== 灵动岛 胶囊（TextButton） =====
-- ========================================
local Island = new("TextButton", {
	Name = "DynamicIsland",
	Size = UDim2.new(0, 120, 0, 34),
	Position = UDim2.new(0.5, 0, 0, 12),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = Color3.fromRGB(10, 10, 12),
	Text = "",
	AutoButtonColor = false,
	Parent = ScreenGui
})
Island.ClipsDescendants = true
new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = Island })

local IslandStroke = new("UIStroke", { Thickness = 1.5, Parent = Island })
local IslandGrad = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 165, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0, 255)),
	}),
	Parent = IslandStroke
})
RunService.RenderStepped:Connect(function(dt)
	IslandGrad.Rotation = (IslandGrad.Rotation + 50 * dt) % 360
end)

local IslandText = new("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "苏",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Parent = Island
})

-- ========================================
-- ===== 主面板 =====
-- ========================================
local MainFrame = new("Frame", {
	Name = "MainFrame",
	Size = UDim2.new(0, 120, 0, 34),
	Position = UDim2.new(0.5, 0, 0, 12),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = Color3.fromRGB(24, 26, 34),
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
	Parent = ScreenGui
})
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })

local UIStroke = new("UIStroke", { Thickness = 2, Parent = MainFrame })
local RainbowGradient = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 165, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0, 255)),
	}),
	Parent = UIStroke
})
RunService.RenderStepped:Connect(function(dt)
	RainbowGradient.Rotation = (RainbowGradient.Rotation + 60 * dt) % 360
end)

-- ========================================
-- ===== 标题栏 =====
-- ========================================
local TitleBar = new("Frame", {
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = Color3.fromRGB(30, 33, 45),
	BorderSizePixel = 0,
	Parent = MainFrame
})
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TitleBar })

local TitleText = new("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	BackgroundTransparency = 1,
	Text = "苏脚本",
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = Color3.fromRGB(235, 238, 245),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = TitleBar
})

local CloseBtn = new("TextButton", {
	Size = UDim2.new(0, 30, 0, 30),
	Position = UDim2.new(1, -34, 0, 3),
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundColor3 = Color3.fromRGB(200, 60, 70),
	AutoButtonColor = false,
	Parent = TitleBar
})
new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CloseBtn })

-- ========================================
-- ===== Tab 栏 =====
-- ========================================
local TabBar = new("Frame", {
	Size = UDim2.new(1, 0, 0, 36),
	Position = UDim2.new(0, 0, 0, 36),
	BackgroundTransparency = 1,
	Parent = MainFrame
})

local Content = new("Frame", {
	Size = UDim2.new(1, 0, 1, -72),
	Position = UDim2.new(0, 0, 0, 72),
	BackgroundTransparency = 1,
	Parent = MainFrame
})

local HomePage = new("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Visible = true,
	Parent = Content
})

local SettingsPage = new("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Visible = false,
	Parent = Content
})

for _, page in ipairs({HomePage, SettingsPage}) do
	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = page
	})
	new("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = page })
end

-- ========================================
-- ===== 按钮工厂 =====
-- ========================================
local function createButton(text, callback)
	local btn = new("TextButton", {
		Size = UDim2.new(0, 320, 0, 38),
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		BackgroundColor3 = Color3.fromRGB(45, 50, 65),
		AutoButtonColor = false,
		Parent = nil
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })

	btn.MouseEnter:Connect(function()
		tween(btn, TweenInfoDefault, { BackgroundColor3 = Color3.fromRGB(60, 68, 90) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, TweenInfoDefault, { BackgroundColor3 = Color3.fromRGB(45, 50, 65) }):Play()
	end)
	btn.Activated:Connect(function()
		tween(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 310, 0, 36)
		}):Play()
		task.wait(0.08)
		tween(btn, TweenInfoDefault, { Size = UDim2.new(0, 320, 0, 38) }):Play()
		if callback then callback() end
	end)
	return btn
end

-- ========================================
-- ===== 确认弹窗工厂 =====
-- ========================================
local function createConfirmPopup(descText, onConfirm)
	local ConfirmOverlay = new("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		ZIndex = 200,
		Parent = ScreenGui
	})

	local ConfirmBox = new("Frame", {
		Size = UDim2.new(0, 300, 0, 160),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(24, 26, 34),
		ZIndex = 201,
		Parent = ScreenGui
	})
	new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = ConfirmBox })

	local ConfirmStroke = new("UIStroke", {
		Thickness = 2,
		Color = Color3.fromRGB(255, 80, 80),
		Parent = ConfirmBox
	})

	local ConfirmTitle = new("TextLabel", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 12),
		BackgroundTransparency = 1,
		Text = "⚠️ 确认执行",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 100, 100),
		Parent = ConfirmBox
	})

	local ConfirmDesc = new("TextLabel", {
		Size = UDim2.new(1, -20, 0, 50),
		Position = UDim2.new(0, 10, 0, 42),
		BackgroundTransparency = 1,
		Text = descText,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextWrapped = true,
		Parent = ConfirmBox
	})

	local CancelBtn = new("TextButton", {
		Size = UDim2.new(0, 130, 0, 34),
		Position = UDim2.new(0, 15, 1, -44),
		Text = "取消",
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		BackgroundColor3 = Color3.fromRGB(60, 64, 78),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = ConfirmBox
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = CancelBtn })

	local OkBtn = new("TextButton", {
		Size = UDim2.new(0, 130, 0, 34),
		Position = UDim2.new(1, -145, 1, -44),
		Text = "确定执行",
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(200, 60, 70),
		AutoButtonColor = false,
		ZIndex = 202,
		Parent = ConfirmBox
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = OkBtn })

	ConfirmBox.Size = UDim2.new(0, 0, 0, 0)
	ConfirmBox.Visible = true
	tween(ConfirmBox, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 300, 0, 160)
	}):Play()

	CancelBtn.Activated:Connect(function()
		local t = tween(ConfirmBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		})
		tween(ConfirmOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		t:Play()
		t.Completed:Wait()
		ConfirmBox:Destroy()
		ConfirmOverlay:Destroy()
	end)

	OkBtn.Activated:Connect(function()
		ConfirmBox:Destroy()
		ConfirmOverlay:Destroy()
		if onConfirm then onConfirm() end
	end)

	CancelBtn.MouseEnter:Connect(function()
		tween(CancelBtn, TweenInfoDefault, { BackgroundColor3 = Color3.fromRGB(80, 85, 100) }):Play()
	end)
	CancelBtn.MouseLeave:Connect(function()
		tween(CancelBtn, TweenInfoDefault, { BackgroundColor3 = Color3.fromRGB(60, 64, 78) }):Play()
	end)
	OkBtn.MouseEnter:Connect(function()
		tween(OkBtn, TweenInfoDefault, { BackgroundColor3 = Color3.fromRGB(230, 70, 80) }):Play()
	end)
	OkBtn.MouseLeave:Connect(function()
		tween(OkBtn, TweenInfoDefault, { BackgroundColor3 = Color3.fromRGB(200, 60, 70) }):Play()
	end)
end

-- ========================================
-- ===== 主页内容 =====
-- ========================================
createButton("🛒 在超市生存一周", function()
	createConfirmPopup("即将加载「在超市生存一周」脚本\n确定要执行吗？", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/mmii6661/Roblox-JunScript-V28/main/%E6%81%90%E8%84%9A%E6%9C%AC%E5%9C%A8%E8%B6%85%E5%B8%82%E7%94%9F%E6%B4%BB%E4%B8%80%E5%91%A8.lua"))()
	end)
end).Parent = HomePage

createButton("不要离开 ⭕", function()
	createConfirmPopup("即将加载「不要离开 ⭕」脚本\n确定要执行吗？", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/mmii6661/Roblox-JunScript-V28/main/%E4%B8%8D%E8%A6%81%E7%A6%BB%E5%BC%80%E5%9C%88%E5%AD%90.lua"))()
	end)
end).Parent = HomePage
createButton("🐾 动物医院", function()
	createConfirmPopup("即将加载「动物医院」脚本\n确定要执行吗？", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/mmii6661/Roblox-JunScript-V28/main/%E5%8A%A8%E7%89%A9%E5%8C%BB%E9%99%A2.lua"))()
	end)
end).Parent = HomePage
-- ========================================
-- ===== 设置页内容 =====
-- ========================================
createButton("切换夜色模式", function()
	print("苏脚本：换主题")
end).Parent = SettingsPage

createButton("重置 UI 位置", function()
	MainFrame.Position = UDim2.new(0.5, 0, 0, 12)
end).Parent = SettingsPage

-- ========================================
-- ===== Tab 按钮 =====
-- ========================================
local function createTab(name, targetPage, otherPage)
	local tab = new("TextButton", {
		Size = UDim2.new(0, 120, 0, 30),
		Text = name,
		Font = Enum.Font.GothamSemibold,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		BackgroundColor3 = Color3.fromRGB(40, 44, 58),
		AutoButtonColor = false,
		Parent = TabBar
	})
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tab })
	tab.Activated:Connect(function()
		targetPage.Visible = true
		otherPage.Visible = false
	end)
	return tab
end

local HomeTab = createTab("主页", HomePage, SettingsPage)
HomeTab.Position = UDim2.new(0, 20, 0, 3)
local SettingsTab = createTab("设置", SettingsPage, HomePage)
SettingsTab.Position = UDim2.new(0, 150, 0, 3)

-- ========================================
-- ===== 灵动岛 展开/收起 核心逻辑 =====
-- ========================================
local islandOpen = false
local IslandOpenSize  = UDim2.new(0, 420, 0, 280)
local IslandCloseSize = UDim2.new(0, 120, 0, 34)

local function setMain(show)
	islandOpen = show
	IslandText.TextTransparency = show and 1 or 0

	if show then
		tween(Island, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 130, 0, 38)
		}):Play()
		task.wait(0.08)
		tween(Island, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = IslandCloseSize
		}):Play()

		MainFrame.Visible = true
		MainFrame.Size = IslandCloseSize
		MainFrame.BackgroundTransparency = 0
		tween(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = IslandOpenSize
		}):Play()
	else
		local t = tween(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = IslandCloseSize
		})
		t:Play()
		t.Completed:Wait()
		MainFrame.Visible = false
	end
end

Island.Activated:Connect(function()
	setMain(not islandOpen)
end)

-- ========================================
-- ===== 关闭按钮 =====
-- ========================================
CloseBtn.Activated:Connect(function()
	if islandOpen then
		setMain(false)
	else
		local t = tween(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})
		t:Play()
		t.Completed:Wait()
		ScreenGui:Destroy()
	end
end)

-- ========================================
-- ===== H 键 =====
-- ========================================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.H then
		setMain(not islandOpen)
	end
end)

-- ========================================
-- ===== 拖动逻辑 =====
-- ========================================
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)
TitleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
