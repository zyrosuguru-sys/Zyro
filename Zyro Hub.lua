-- Zyro Hub v1.0 | Full Rayfield Hub
-- TSB / Roblox

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- Wait for CoreGui ready
repeat task.wait() until game:IsLoaded() and game:GetService("CoreGui")

-- Wait for Character
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- =====================
-- FLAGS & SETTINGS
-- =====================
local HitboxEnabled = false
local HitboxSize = 5

-- =====================
-- LOAD RAYFIELD
-- =====================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Zyro Hub v1.0",
	LoadingTitle = "Zyro Hub",
	LoadingSubtitle = "by Zyro",
	ConfigurationSaving = {Enabled=true, FolderName="ZyroHub", FileName="Config"}
})

-- =====================
-- CREATE TABS
-- =====================
local TechTab = Window:CreateTab("Tech",4483362458)
local FixLagTab = Window:CreateTab("Fix Lag",4483362458)
local CombatTab = Window:CreateTab("Combat",4483362458)
local ScriptTab = Window:CreateTab("Script",4483362458)

-- =====================
-- TECH TAB
-- =====================
TechTab:CreateButton({
	Name = "Supa Tech (Zyro)",
	Callback = function()
		loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-Supa-tech-v2-77454"))()
	end
})

-- =====================
-- FIX LAG TAB
-- =====================
-- Helper function xoá effect/practice
local function ClearEffects(obj)
	for _,v in pairs(obj:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") or v:IsA("Explosion") or v:IsA("Decal") or v:IsA("Texture") then
			v:Destroy()
		end
	end
end

-- Helper function xoá map cỏ, đá, cây, ghế, giữ nền
local function CleanMap()
	for _,v in pairs(Workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			local n = v.Name:lower()
			if n:find("tree") or n:find("grass") or n:find("rock") or n:find("chair") or n:find("bush") or n:find("wall") then
				v:Destroy()
			else
				v.Material = Enum.Material.SmoothPlastic
			end
		end
	end
end

-- Helper function tối màn hình
local function SetDark()
	Lighting.Brightness = 0.7
	Lighting.GlobalShadows = false
end

-- Helper function xoá đầu/chân phải nhân vật
local function CleanCharacters()
	for _,p in pairs(Players:GetPlayers()) do
		if p.Character then
			for _,v in pairs(p.Character:GetDescendants()) do
				if v:IsA("Accessory") or v:IsA("Hat") or v.Name=="Head" or v.Name=="RightLeg" or v.Name=="RightLowerLeg" or v.Name=="RightFoot" then
					v:Destroy()
				end
			end
		end
	end
end

-- FPS Rainbow
local gui = Instance.new("ScreenGui",game.CoreGui)
local fps = Instance.new("TextLabel",gui)
fps.Size = UDim2.new(0,90,0,22)
fps.Position = UDim2.new(1,-95,1,-30)
fps.BackgroundTransparency = 0.3
fps.BackgroundColor3 = Color3.fromRGB(20,20,20)
fps.TextScaled = true
local frames,last,hue = 0,tick(),0
RunService.RenderStepped:Connect(function()
	frames += 1
	hue += 0.01
	if hue>1 then hue=0 end
	fps.TextColor3 = Color3.fromHSV(hue,1,1)
	if tick()-last>=1 then
		fps.Text="FPS: "..frames
		frames=0
		last=tick()
	end
end)

-- Fix Lag V1 Button
FixLagTab:CreateButton({
	Name = "Fix Lag V1",
	Callback = function()
		CleanMap()
		ClearEffects(Workspace)
		CleanCharacters()
		SetDark()
		print("✅ Fix Lag V1 Activated")
	end
})

-- Fix Lag V2 Button
FixLagTab:CreateButton({
	Name = "Fix Lag V2",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/marianscriptKing/SUPER-MAX.lau/main/SUPER%20MAX%20PERFORMANCE"))()
	end
})

-- =====================
-- COMBAT TAB
-- =====================
CombatTab:CreateToggle({
	Name = "Enable Hitbox",
	CurrentValue = false,
	Callback = function(v)
		HitboxEnabled=v
		for _,p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = p.Character.HumanoidRootPart
				hrp.Size = HitboxEnabled and Vector3.new(HitboxSize,HitboxSize,HitboxSize) or Vector3.new(2,2,1)
				hrp.Transparency = HitboxEnabled and 0.7 or 1
				hrp.CanCollide=false
			end
		end
	end
})

CombatTab:CreateSlider({
	Name = "Hitbox Size",
	Min = 2,
	Max = 20,
	Increment = 1,
	CurrentValue = HitboxSize,
	Callback = function(v)
		HitboxSize=v
	end
})

-- =====================
-- SCRIPT TAB
-- =====================
ScriptTab:CreateButton({
	Name = "Tthanh Hub",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/Tthanh%20Tong%20Hop%20Tech.txt"))()
	end
})

print("✅ Zyro Hub v1.0 Loaded | All Tabs Functional")
