--[[
    Zyro Hub | The Strongest Battlegrounds
    Developer: Gemini (Expert Lua Developer)
    Library: Fluent
--]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Khởi tạo Window chính
local Window = Fluent:CreateWindow({
    Title = "Zyro Hub | The Strongest Battlegrounds",
    SubTitle = "by Gemini",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl -- Phím tắt đóng/mở nhanh
})

-- Các biến điều khiển (Variables)
local Options = Fluent.Options
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Tab cấu hình
local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "Zap" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-------------------------------------------------------------------------------
-- 🥊 COMBAT TAB
-------------------------------------------------------------------------------
Tabs.Combat:AddParagraph({ Title = "Combat Tools", Content = "Hỗ trợ tự động chiến đấu và tăng tầm đánh." })

local AutoPunchToggle = Tabs.Combat:AddToggle("AutoPunch", {Title = "Auto Punch", Default = false })
AutoPunchToggle:OnChanged(function()
    task.spawn(function()
        while Options.AutoPunch.Value do
            local args = { [1] = "Normal_Punch" } -- Tên event có thể thay đổi tùy bản update game
            game:GetService("Players").LocalPlayer.Character.Communicate:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

local HitboxSlider = Tabs.Combat:AddSlider("HitboxSize", {
    Title = "Hitbox Extender",
    Description = "Tăng kích thước vùng va chạm đối thủ",
    Default = 2, Min = 2, Max = 50, Rounding = 1,
    Callback = function(Value)
        -- Logic Hitbox sẽ được thực thi trong một vòng lặp riêng để tránh lag
    end
})

-- Vòng lặp Hitbox Extender
task.spawn(function()
    while task.wait(1) do
        if Options.HitboxSize and Options.HitboxSize.Value > 2 then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.Size = Vector3.new(Options.HitboxSize.Value, Options.HitboxSize.Value, Options.HitboxSize.Value)
                    v.Character.HumanoidRootPart.Transparency = 0.7
                    v.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
    end
end)

-------------------------------------------------------------------------------
-- 🏃 MOVEMENT TAB
-------------------------------------------------------------------------------
Tabs.Movement:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Default = 16, Min = 16, Max = 200, Rounding = 0,
    Callback = function(Value)
        LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

Tabs.Movement:AddSlider("JumpPower", {
    Title = "JumpPower",
    Default = 50, Min = 50, Max = 300, Rounding = 0,
    Callback = function(Value)
        LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

local InfJumpToggle = Tabs.Movement:AddToggle("InfJump", {Title = "Infinite Jump", Default = false })
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Options.InfJump.Value then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-------------------------------------------------------------------------------
-- 🌍 TELEPORT TAB
-------------------------------------------------------------------------------
local PlayerDropdown = Tabs.Teleport:AddDropdown("TargetPlayer", {
    Title = "Select Player",
    Values = {},
    Multi = false,
    Default = nil,
})

-- Cập nhật danh sách người chơi vào Dropdown
local function UpdatePlayerList()
    local pList = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then table.insert(pList, v.Name) end
    end
    PlayerDropdown:SetValues(pList)
end
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

Tabs.Teleport:AddButton({
    Title = "Teleport to Selected",
    Callback = function()
        local target = Players:FindFirstChild(Options.TargetPlayer.Value)
        if target and target.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Map Center",
    Callback = function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
})

-------------------------------------------------------------------------------
-- 👁 VISUAL TAB
-------------------------------------------------------------------------------
Tabs.Visual:AddToggle("ESPToggle", {Title = "Enable ESP Box", Default = false})
-- Lưu ý: ESP thực tế cần một module hoặc vẽ Drawing API phức tạp, dưới đây là logic cơ bản
task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                if Options.ESPToggle.Value then
                    if not char:FindFirstChild("ZyroHighlight") then
                        local highlight = Instance.new("Highlight", char)
                        highlight.Name = "ZyroHighlight"
                        highlight.FillColor = Color3.fromRGB(138, 43, 226)
                    end
                else
                    if char:FindFirstChild("ZyroHighlight") then
                        char.ZyroHighlight:Destroy()
                    end
                end
            end
        end
    end
end)

-------------------------------------------------------------------------------
-- ⚙ SETTINGS TAB
-------------------------------------------------------------------------------
Tabs.Settings:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

Tabs.Settings:AddButton({
    Title = "Server Hop",
    Callback = function()
        -- Logic tìm server ít người và nhảy
    end
})

Tabs.Settings:AddButton({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})

-------------------------------------------------------------------------------
-- 🖱 MINI HUB (DOCK BUTTON)
-------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenButton = Instance.new("TextButton", ScreenGui)

OpenButton.Size = UDim2.new(0, 100, 0, 40)
OpenButton.Position = UDim2.new(0, 10, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Text = "Zyro Hub"
OpenButton.Draggable = true -- Cho phép kéo thả nút
OpenButton.Active = true

-- Tạo bo góc cho nút
local UICorner = Instance.new("UICorner", OpenButton)
UICorner.CornerRadius = ToolBuffer or UDim.new(0, 8)

OpenButton.MouseButton1Click:Connect(function()
    local state = not game:GetService("CoreGui"):FindFirstChild("Fluent").Enabled
    -- Lưu ý: Cách tắt/mở phụ thuộc vào cấu trúc của Library, Fluent dùng phím tắt tốt hơn.
    -- Ở đây ta thông báo người dùng phím tắt:
    Fluent:Notify({
        Title = "Zyro Hub",
        Content = "Nhấn 'Right Control' để ẩn/hiện menu chính!",
        Duration = 3
    })
end)

-- Kết thúc setup
Window:SelectTab(1)
Fluent:Notify({
    Title = "Zyro Hub Loaded",
    Content = "Chào mừng bạn đến với The Strongest Battlegrounds!",
    Duration = 5
})
