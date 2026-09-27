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
	Backg