-- ========== UI库加载 ==========
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui"))()

-- 如果加载失败，使用备用UI库
if not Library then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
end

-- ========== 创建窗口 ==========
local Window = Library:CreateWindow({
    Title = "最后一站",
    Center = true,
    AutoShow = true,
    TabPadding = 6,
    MenuFadeTime = 0.12,
    Size = UDim2.fromOffset(600, 470)
})

-- ========== 标签页 ==========
local Tabs = {
    Rage = Window:AddTab("Ragebot"),
    Melee = Window:AddTab("杀戮光环"),
    State = Window:AddTab("状态"),
    Settings = Window:AddTab("设置")
}

-- ========== Ragebot 标签页 ==========
local RageLeft = Tabs.Rage:AddLeftGroupbox("基础设置")
local RageRight = Tabs.Rage:AddRightGroupbox("进阶设置")

RageLeft:AddToggle("RageEnabled", {
    Text = "启用 Ragebot",
    Default = false,
    Tooltip = "开启远程自动瞄准功能",
    Callback = function(value)
        Config.Rage.Enabled = value
    end
})

RageLeft:AddSlider("RageRange", {
    Text = "有效距离",
    Default = 500,
    Min = 20,
    Max = 2000,
    Rounding = 1,
    Suffix = " studs",
    Tooltip = "自动瞄准的最大有效距离",
    Callback = function(value)
        Config.Rage.Range = value
    end
})

RageLeft:AddSlider("RageFireDelay", {
    Text = "射击间隔",
    Default = 0.08,
    Min = 0.02,
    Max = 0.5,
    Rounding = 3,
    Suffix = "s",
    Tooltip = "每次射击之间的延迟时间",
    Callback = function(value)
        Config.Rage.FireDelay = value
    end
})

RageLeft:AddDropdown("RageAimPart", {
    Text = "瞄准部位",
    Default = "Head",
    Values = {"Head", "Root", "Any"},
    Multi = false,
    Tooltip = "选择优先瞄准的身体部位",
    Callback = function(value)
        Config.Rage.AimPart = value
    end
})

RageLeft:AddToggle("LockCamera", {
    Text = "锁定相机",
    Default = true,
    Tooltip = "开火时自动锁定视角到目标",
    Callback = function(value)
        Config.Rage.LockCamera = value
    end
})

RageRight:AddToggle("AutoWarp", {
    Text = "自动瞬移",
    Default = false,
    Tooltip = "超出射程时自动瞬移靠近目标",
    Callback = function(value)
        Config.Rage.AutoWarp = value
    end
})

RageRight:AddSlider("WarpOffset", {
    Text = "落点偏移",
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 1,
    Suffix = " studs",
    Tooltip = "瞬移到目标附近时的偏移距离",
    Callback = function(value)
        Config.Rage.WarpOffset = value
    end
})

RageRight:AddDivider()

RageRight:AddToggle("HealthCheck", {
    Text = "血量检查",
    Default = true,
    Tooltip = "只攻击有血量标志部件的实体",
    Callback = function(value)
        Config.Health.Enabled = value
        entityCache.time = 0
    end
})

RageRight:AddInput("HealthIndicator", {
    Text = "血量标志",
    Default = "HumanoidRootPart",
    Placeholder = "输入部件名称",
    Numeric = false,
    Finished = true,
    Tooltip = "用于判断实体是否存活的部件名称",
    Callback = function(value)
        Config.Health.IndicatorName = value ~= "" and value or "HumanoidRootPart"
        entityCache.time = 0
    end
})

-- ========== 杀戮光环标签页 ==========
local MeleeLeft = Tabs.Melee:AddLeftGroupbox("基础设置")
local MeleeRight = Tabs.Melee:AddRightGroupbox("范围扩展")

MeleeLeft:AddToggle("MeleeEnabled", {
    Text = "启用杀戮光环",
    Default = false,
    Tooltip = "开启近战自动攻击功能",
    Callback = function(value)
        Config.Melee.Enabled = value
    end
})

MeleeLeft:AddSlider("MeleeRange", {
    Text = "攻击范围",
    Default = 30,
    Min = 5,
    Max = 200,
    Rounding = 1,
    Suffix = " studs",
    Tooltip = "近战攻击的最大范围",
    Callback = function(value)
        Config.Melee.Range = value
    end
})

MeleeLeft:AddSlider("AttackDelay", {
    Text = "攻击间隔",
    Default = 0.08,
    Min = 0.01,
    Max = 0.5,
    Rounding = 3,
    Suffix = "s",
    Tooltip = "每次攻击之间的延迟时间",
    Callback = function(value)
        Config.Melee.AttackDelay = value
    end
})

MeleeLeft:AddSlider("MaxTargets", {
    Text = "最大目标",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Suffix = "个",
    Tooltip = "同时攻击的最大目标数量",
    Callback = function(value)
        Config.Melee.MaxTargets = value
    end
})

MeleeLeft:AddSlider("PerTargetCooldown", {
    Text = "目标冷却",
    Default = 0.1,
    Min = 0.01,
    Max = 0.5,
    Rounding = 3,
    Suffix = "s",
    Tooltip = "对同一目标的攻击冷却时间",
    Callback = function(value)
        Config.Melee.PerTargetCooldown = value
    end
})

MeleeRight:AddToggle("MeleeAutoTP", {
    Text = "自动瞬移",
    Default = true,
    Tooltip = "超出攻击范围时自动瞬移靠近目标",
    Callback = function(value)
        Config.Melee.AutoTP = value
    end
})

MeleeRight:AddSlider("TPThreshold", {
    Text = "触发距离",
    Default = 15,
    Min = 5,
    Max = 200,
    Rounding = 1,
    Suffix = " studs",
    Tooltip = "超过此距离时触发瞬移",
    Callback = function(value)
        Config.Melee.TPThreshold = value
    end
})

MeleeRight:AddSlider("TPOffset", {
    Text = "落点偏移",
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 1,
    Suffix = " studs",
    Tooltip = "瞬移到目标附近时的偏移距离",
    Callback = function(value)
        Config.Melee.TPOffset = value
    end
})

MeleeRight:AddSlider("TPCooldown", {
    Text = "传送冷却",
    Default = 0.15,
    Min = 0.05,
    Max = 2,
    Rounding = 3,
    Suffix = "s",
    Tooltip = "两次瞬移之间的冷却时间",
    Callback = function(value)
        Config.Melee.TPCooldown = value
    end
})

MeleeRight:AddDivider()

MeleeRight:AddToggle("TPReturn", {
    Text = "攻击后返回",
    Default = true,
    Tooltip = "攻击完成后回到原始位置",
    Callback = function(value)
        Config.Melee.TPReturn = value
    end
})

MeleeRight:AddSlider("TPReturnDelay", {
    Text = "返回延迟",
    Default = 0.04,
    Min = 0,
    Max = 0.3,
    Rounding = 3,
    Suffix = "s",
    Tooltip = "攻击完成后返回原点的延迟时间",
    Callback = function(value)
        Config.Melee.TPReturnDelay = value
    end
})

-- ========== 状态标签页 ==========
local StateGroup = Tabs.State:AddLeftGroupbox("采样模板")
local EntityGroup = Tabs.State:AddRightGroupbox("实体过滤")

StateGroup:AddLabel("信号源：等待链接")
StateGroup:AddLabel("消息 ID：—")
StateGroup:AddLabel("武器类型：—")
StateGroup:AddLabel("动作：—")
StateGroup:AddLabel("Fire 参数数：—")
StateGroup:AddLabel("Fire 结构：—")
StateGroup:AddLabel("Fire 模板：—")
StateGroup:AddLabel("Attack 模板：—")
StateGroup:AddLabel("Hit 模板：—")
StateGroup:AddLabel("采样次数：0")

EntityGroup:AddLabel("血量检查：关闭")
EntityGroup:AddLabel("血量标志：HumanoidRootPart")
EntityGroup:AddLabel("存活实体：0")
EntityGroup:AddLabel("Ragebot：关")
EntityGroup:AddLabel("杀戮光环：关")

-- 状态更新标签引用
local StateLabels = {}
for _, label in ipairs(StateGroup:GetChildren()) do
    if label:IsA("TextLabel") then
        local text = label.Text:split("：")
        if #text == 2 then
            StateLabels[text[1]] = label
        end
    end
end

local EntityLabels = {}
for _, label in ipairs(EntityGroup:GetChildren()) do
    if label:IsA("TextLabel") then
        local text = label.Text:split("：")
        if #text == 2 then
            EntityLabels[text[1]] = label
        end
    end
end

-- ========== 设置标签页 ==========
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("快捷键")
local AboutGroup = Tabs.Settings:AddRightGroupbox("关于")

SettingsGroup:AddKeybind("RageKeybind", {
    Text = "Ragebot 开关",
    Default = Enum.KeyCode.J,
    Mode = "Toggle",
    Callback = function()
        Config.Rage.Enabled = not Config.Rage.Enabled
    end
})

SettingsGroup:AddKeybind("MeleeKeybind", {
    Text = "杀戮光环开关",
    Default = Enum.KeyCode.K,
    Mode = "Toggle",
    Callback = function()
        Config.Melee.Enabled = not Config.Melee.Enabled
    end
})

SettingsGroup:AddKeybind("ToggleUI", {
    Text = "隐藏/显示 UI",
    Default = Enum.KeyCode.RightShift,
    Mode = "Toggle",
    Callback = function()
        Window:Toggle()
    end
})

AboutGroup:AddLabel("最后一站 v1.0")
AboutGroup:AddLabel("作者：苏脚本工作室")
AboutGroup:AddLabel("")
AboutGroup:AddLabel("快捷键：")
AboutGroup:AddLabel("  RightShift - 隐藏/显示")
AboutGroup:AddLabel("  J - Ragebot 开关")
AboutGroup:AddLabel("  K - 杀戮光环开关")

-- ========== 更新状态UI ==========
task.spawn(function()
    while task.wait(0.5) do
        -- 更新采样模板状态
        if StateLabels["信号源"] then
            local srcStatus = Config.Signal.Event and "已链接" or "等待链接"
            StateLabels["信号源"].Text = "信号源：" .. srcStatus
        end
        if StateLabels["消息 ID"] then
            StateLabels["消息 ID"].Text = "消息 ID：" .. (Config.Signal.IdForce or Config.Signal.MsgId or "—")
        end
        if StateLabels["武器类型"] then
            StateLabels["武器类型"].Text = "武器类型：" .. (Config.Signal.TypeForce or Config.Signal.WeaponType or "—")
        end
        if StateLabels["动作"] then
            StateLabels["动作"].Text = "动作：" .. (Config.Signal.ActionForce or Config.Signal.Action or "—")
        end
        if StateLabels["Fire 参数数"] then
            StateLabels["Fire 参数数"].Text = "Fire 参数数：" .. (Config.Signal.Template.Fire and tostring(Config.Signal.Template.Fire.n) or "—")
        end
        if StateLabels["Fire 结构"] then
            local fireT = Config.Signal.Template.Fire
            local shape = "—"
            if fireT and fireT.n then
                local parts = {}
                for i = 1, fireT.n do
                    local v = fireT[i]
                    local t = typeof(v)
                    if t == "table" then
                        local first = v[1]
                        if typeof(first) == "Vector3" then
                            parts[i] = "V" .. #v
                        elseif type(first) == "table" and typeof(first[1]) == "Instance" then
                            parts[i] = "P" .. #v
                        else
                            parts[i] = "tbl"
                        end
                    elseif t == "Vector3" then
                        parts[i] = "V3"
                    elseif t == "number" then
                        parts[i] = "num"
                    elseif t == "string" then
                        parts[i] = "str"
                    else
                        parts[i] = t:sub(1, 3)
                    end
                end
                shape = table.concat(parts, " ")
            end
            StateLabels["Fire 结构"].Text = "Fire 结构：" .. shape
        end
        if StateLabels["Fire 模板"] then
            local fireT = Config.Signal.Template.Fire
            local status = "—"
            if fireT then
                status = templateHasHits(fireT) and "完整（含 hits）" or "缺 hits（请打中一次）"
            end
            StateLabels["Fire 模板"].Text = "Fire 模板：" .. status
        end
        if StateLabels["Attack 模板"] then
            local status = Config.Signal.Template.Attack and "已捕获" or "—"
            StateLabels["Attack 模板"].Text = "Attack 模板：" .. status
        end
        if StateLabels["Hit 模板"] then
            local status = Config.Signal.Template.Hit and "已捕获" or "—"
            StateLabels["Hit 模板"].Text = "Hit 模板：" .. status
        end
        if StateLabels["采样次数"] then
            StateLabels["采样次数"].Text = "采样次数：" .. Config.Signal.Count
        end
        
        -- 更新实体状态
        if EntityLabels["血量检查"] then
            local status = Config.Health.Enabled and "开启" or "关闭"
            EntityLabels["血量检查"].Text = "血量检查：" .. status
        end
        if EntityLabels["血量标志"] then
            EntityLabels["血量标志"].Text = "血量标志：" .. (Config.Health.IndicatorName or "HumanoidRootPart")
        end
        if EntityLabels["存活实体"] then
            EntityLabels["存活实体"].Text = "存活实体：" .. #collectEntities()
        end
        if EntityLabels["Ragebot"] then
            local status = Config.Rage.Enabled and "开" or "关"
            EntityLabels["Ragebot"].Text = "Ragebot：" .. status
        end
        if EntityLabels["杀戮光环"] then
            local status = Config.Melee.Enabled and "开" or "关"
            EntityLabels["杀戮光环"].Text = "杀戮光环：" .. status
        end
    end
end)

-- ========== 通知提示 ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "加载成功",
    Text = "最后一站 v1.0 已加载\n按 RightShift 隐藏/显示 UI",
    Duration = 4
})
