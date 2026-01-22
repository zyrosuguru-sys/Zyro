--// ZYRO HUB V2 - PRO
--// Game: The Strongest Battlegrounds
--// UI: Rayfield
--// Mobile + PC Friendly

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Load UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Zyro Hub V2 | The Strongest Battlegrounds",
    LoadingTitle = "Zyro Hub V2",
    LoadingSubtitle = "PRO Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZyroHub",
        FileName = "TSB_V2"
    },
    KeySystem = false
})

------------------------------------------------
-- COMBAT
------------------------------------------------
local Combat = Window:CreateTab("🥊 Combat", 4483362458)

local AutoPunch = false
Combat:CreateToggle({
    Name = "Auto Punch",
    CurrentValue = false,
    Callback = function(v)
        AutoPunch = v
        task.spawn(function()
            while AutoPunch do
                pcall(function()
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,0)
                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0)
                end)
                task.wait(0.12)
            end
        end)
    end
})

local Hitbox = 6
Combat:CreateSlider({
    Name = "Hitbox Size",
    Range = {3,25},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(v)
        Hitbox = v
    end
})

task.spawn(function()
    while task.wait(1) do
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                hrp.Size = Vector3.new(Hitbox,Hitbox,Hitbox)
                hrp.Transparency = 0.6
                hrp.CanCollide = false
            end
        end
    end
end)

------------------------------------------------
-- MOVEMENT
------------------------------------------------
local Move = Window:CreateTab("🏃 Movement", 4483362458)

Move:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        LP.Character.Humanoid.WalkSpeed = v
    end
})

Move:CreateSlider({
    Name = "JumpPower",
    Range = {50,300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        LP.Character.Humanoid.JumpPower = v
    end
})

local InfJump = false
Move:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        InfJump = v
    end
})

UIS.JumpRequest:Connect(function()
    if InfJump then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

------------------------------------------------
-- TELEPORT
------------------------------------------------
local TP = Window:CreateTab("🌍 Teleport", 4483362458)

local PlayerList = {}
for _,v in pairs(Players:GetPlayers()) do
    if v ~= LP then table.insert(PlayerList, v.Name) end
end

local SelectedPlayer
TP:CreateDropdown({
    Name = "Select Player",
    Options = PlayerList,
    CurrentOption = nil,
    Callback = function(v)
        SelectedPlayer = v
    end
})

TP:CreateButton({
    Name = "Teleport To Player",
    Callback = function()
        if SelectedPlayer then
            local Target = Players:FindFirstChild(SelectedPlayer)
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame =
                    Target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
            end
        end
    end
})

------------------------------------------------
-- VISUAL
------------------------------------------------
local Visual = Window:CreateTab("👁 Visual", 4483362458)

local ESP = false
Visual:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Callback = function(v)
        ESP = v
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                if v then
                    if not plr.Character:FindFirstChild("ZyroESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "ZyroESP"
                        h.FillColor = Color3.fromRGB(170,0,255)
                        h.Parent = plr.Character
                    end
                else
                    if plr.Character:FindFirstChild("ZyroESP") then
                        plr.Character.ZyroESP:Destroy()
                    end
                end
            end
        end
    end
})

Visual:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        for _,v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end
})

------------------------------------------------
-- SETTINGS
------------------------------------------------
local Settings = Window:CreateTab("⚙ Settings", 4483362458)

Settings:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local Servers = Http:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        ))
        for _,s in pairs(Servers.data) do
            if s.playing < s.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(
                    game.PlaceId, s.id, LP
                )
                break
            end
        end
    end
})

Settings:CreateButton({
    Name = "Destroy Zyro Hub",
    Callback = function()
        Rayfield:Destroy()
    end
})

------------------------------------------------
-- MINI HUB (MOBILE)
------------------------------------------------
Rayfield:Notify({
    Title = "Zyro Hub V2",
    Content = "RightShift (PC) hoặc nút tròn (Mobile)",
    Duration = 6
})

UIS.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then
        Rayfield:ToggleUI()
    end
end)
