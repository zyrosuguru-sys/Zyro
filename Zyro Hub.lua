--[[
Zyro Hub - The Strongest Battlegrounds
Author: Zyro
Features:
- Auto Farm Items/Coins
- Auto Attack (Tech Script)
- Auto Upgrade Weapons
- Teleport to Key Locations
- GUI Menu
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZyroHubGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Zyro Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainFrame

-- Buttons Helper
local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 250, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.Text = name
    btn.Parent = MainFrame
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

-- Feature Toggles
local autoFarm = false
local autoUpgrade = false
local autoAttack = false

-- Key Locations (adjust based on actual map)
local locations = {
    Spawn = workspace:FindFirstChild("SpawnLocation"),
    Center = workspace:FindFirstChild("CenterPlatform"),
    HighSpot = workspace:FindFirstChild("HighSpot") -- example
}

-- Auto Farm Items/Coins
createButton("Toggle Auto Farm", UDim2.new(0, 50, 0, 70), function()
    autoFarm = not autoFarm
    if autoFarm then
        spawn(function()
            while autoFarm do
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "Coin" or obj.Name == "Item" then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                        wait(0.3)
                    end
                end
                wait(1)
            end
        end)
    end
end)

-- Auto Upgrade Weapons
createButton("Toggle Auto Upgrade", UDim2.new(0, 50, 0, 140), function()
    autoUpgrade = not autoUpgrade
    if autoUpgrade then
        spawn(function()
            while autoUpgrade do
                local upgradeEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("UpgradeWeapon")
                if upgradeEvent then
                    upgradeEvent:FireServer()
                end
                wait(2)
            end
        end)
    end
end)

-- Auto Attack (Tech Script)
createButton("Toggle Auto Attack", UDim2.new(0, 50, 0, 210), function()
    autoAttack = not autoAttack
    if autoAttack then
        spawn(function()
            while autoAttack do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyPos = player.Character.HumanoidRootPart.Position
                        local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                        if (myPos - enemyPos).Magnitude < 20 then -- attack range
                            local attackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Attack")
                            if attackEvent then
                                attackEvent:FireServer(player)
                            end
                        end
                    end
                end
                wait(0.5)
            end
        end)
    end
end)

-- Teleport Buttons
local yOffset = 280
for name, pos in pairs(locations) do
    createButton("Teleport to "..name, UDim2.new(0, 50, 0, yOffset), function()
        if pos then
            LocalPlayer.Character.HumanoidRootPart.CFrame = pos.CFrame + Vector3.new(0, 5, 0)
        end
    end)
    yOffset = yOffset + 70
end

-- Close GUI
createButton("Close GUI", UDim2.new(0, 50, 0, yOffset), function()
    ScreenGui:Destroy()
end)

print("Zyro Hub loaded successfully!")
