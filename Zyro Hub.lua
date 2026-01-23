--[[
    Zyro Hub - The Strongest Battleground
    Created by: AI Assistant
    Version: 1.0
    Features: Tech Loader, Player Options, Map Utilities, Settings
]]

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ========== VARIABLES ==========
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local gui = nil
local hubEnabled = false
local techList = {}
local connections = {}
local settings = {
    keybind = Enum.KeyCode.RightShift,
    theme = "Dark",
    autoLoadTech = false,
    autoUpdateTech = true
}

-- ========== TECH DATABASE ==========
local defaultTechs = {
    ["Supa Tech V2"] = {
        url = "https://raw.githubusercontent.com/example/supatech/main/tech.lua",
        loaded = false
    },
    ["Kai Tech"] = {
        url = "https://raw.githubusercontent.com/example/kaitech/main/tech.lua", 
        loaded = false
    },
    ["Freeze Tech"] = {
        url = "https://raw.githubusercontent.com/example/freezetech/main/tech.lua",
        loaded = false
    },
    ["Lethal Kiba"] = {
        url = "https://raw.githubusercontent.com/example/lethalkiba/main/tech.lua",
        loaded = false
    }
}

-- ========== PLAYER FEATURES ==========
local playerFeatures = {
    speedHack = {enabled = false, value = 16},
    jumpHack = {enabled = false, value = 50},
    noFallDamage = {enabled = false},
    autoFarm = {enabled = false},
    godMode = {enabled = false},
    infiniteStamina = {enabled = false},
    espEnabled = {enabled = false}
}

-- ========== UTILITY FUNCTIONS ==========
local Utilities = {}

function Utilities:CreateNotification(title, message, duration)
    -- Tạo thông báo đơn giản
    warn("[Zyro Hub] " .. title .. ": " .. message)
    
    -- Có thể thêm UI notification ở đây
end

function Utilities:LoadScript(url)
    local success, response = pcall(function()
        local script = loadstring(game:HttpGet(url))()
        return script
    end)
    
    if success then
        return response
    else
        Utilities:CreateNotification("Lỗi", "Không thể load script: " .. tostring(response), 3)
        return nil
    end
end

function Utilities:ScanForTechs()
    -- Quét ReplicatedStorage và ServerScriptService cho tech
    local foundTechs = {}
    
    local function scanFolder(folder)
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                if string.find(obj.Name:lower(), "tech") or 
                   string.find(obj.Name:lower(), "script") then
                    table.insert(foundTechs, {
                        name = obj.Name,
                        path = obj:GetFullName(),
                        type = "ModuleScript"
                    })
                end
            end
        end
    end
    
    -- Quét các folder phổ biến
    local foldersToScan = {ReplicatedStorage, game:GetService("ServerScriptService")}
    for _, folder in ipairs(foldersToScan) do
        scanFolder(folder)
    end
    
    return foundTechs
end

-- ========== UI CREATION ==========
local UICreator = {}

function UICreator:CreateMainGUI()
    -- Tạo ScreenGui chính
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZyroHub"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Container chính
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Thanh tiêu đề
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Zyro Hub v1.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    -- Tabs container
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -20, 0, 40)
    tabsContainer.Position = UDim2.new(0, 10, 0, 45)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = mainFrame
    
    -- Content container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -90)
    contentFrame.Position = UDim2.new(0, 10, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        titleBar = titleBar,
        contentFrame = contentFrame,
        tabsContainer = tabsContainer,
        closeButton = closeButton
    }
end

function UICreator:CreateTabs(guiElements)
    local tabs = {}
    local currentTab = nil
    
    local tabButtons = {
        {"TechLoader", "Tech Loader"},
        {"Player", "Player Options"},
        {"Map", "Map Utilities"},
        {"Settings", "Settings"}
    }
    
    local function createTabButton(name, text, index)
        local button = Instance.new("TextButton")
        button.Name = name .. "Tab"
        button.Size = UDim2.new(0.25, -5, 1, 0)
        button.Position = UDim2.new(0.25 * (index - 1), 0, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.Parent = guiElements.tabsContainer
        
        -- Tạo frame nội dung cho tab
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = name .. "Frame"
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = guiElements.contentFrame
        
        tabs[name] = {
            button = button,
            frame = tabFrame,
            name = name
        }
        
        button.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.frame.Visible = false
                currentTab.button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
            
            tabFrame.Visible = true
            button.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
            currentTab = tabs[name]
        end)
        
        return tabs[name]
    end
    
    -- Tạo các tab
    for i, tabInfo in ipairs(tabButtons) do
        createTabButton(tabInfo[1], tabInfo[2], i)
    end
    
    -- Mặc định mở tab đầu tiên
    if tabs["TechLoader"] then
        tabs["TechLoader"].frame.Visible = true
        tabs["TechLoader"].button.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        currentTab = tabs["TechLoader"]
    end
    
    return tabs
end

function UICreator:CreateTechLoaderTab(tabFrame)
    -- Scroll frame cho tech list
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "TechScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, -40)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = tabFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = scrollFrame
    
    -- Search bar
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, 0, 0, 30)
    searchBox.Position = UDim2.new(0, 0, 1, -35)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    searchBox.BorderSizePixel = 0
    searchBox.Text = "Tìm kiếm tech..."
    searchBox.PlaceholderText = "Tìm kiếm tech..."
    searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.Parent = tabFrame
    
    -- Thêm tech mặc định vào database
    for techName, techData in pairs(defaultTechs) do
        techList[techName] = techData
    end
    
    local function createTechEntry(techName, techData)
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = techName .. "Entry"
        entryFrame.Size = UDim2.new(1, -10, 0, 50)
        entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        entryFrame.BorderSizePixel = 0
        entryFrame.Parent = scrollFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = techName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = entryFrame
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusLabel"
        statusLabel.Size = UDim2.new(0, 80, 0, 20)
        statusLabel.Position = UDim2.new(0.6, 0, 0.5, -10)
        statusLabel.BackgroundColor3 = techData.loaded and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
        statusLabel.BorderSizePixel = 0
        statusLabel.Text = techData.loaded and "Đã Load" or "Chưa Load"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextSize = 12
        statusLabel.Parent = entryFrame
        
        local loadButton = Instance.new("TextButton")
        loadButton.Name = "LoadButton"
        loadButton.Size = UDim2.new(0, 60, 0, 30)
        loadButton.Position = UDim2.new(1, -70, 0.5, -15)
        loadButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        loadButton.BorderSizePixel = 0
        loadButton.Text = "LOAD"
        loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadButton.Font = Enum.Font.GothamBold
        loadButton.TextSize = 14
        loadButton.Parent = entryFrame
        
        loadButton.MouseButton1Click:Connect(function()
            Utilities:CreateNotification("Tech Loader", "Đang load " .. techName, 2)
            
            local success, result = pcall(function()
                local script = Utilities:LoadScript(techData.url)
                if script then
                    techData.loaded = true
                    statusLabel.Text = "Đã Load"
                    statusLabel.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
                    loadButton.Text = "LOADED"
                    loadButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    loadButton.Active = false
                    Utilities:CreateNotification("Thành công", techName .. " đã được load!", 3)
                end
            end)
            
            if not success then
                Utilities:CreateNotification("Lỗi", "Không thể load " .. techName, 3)
            end
        end)
        
        return entryFrame
    end
    
    -- Tạo entries cho tech
    for techName, techData in pairs(techList) do
        createTechEntry(techName, techData)
    end
    
    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchBox.Text:lower()
        
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                local nameLabel = child:FindFirstChild("NameLabel")
                if nameLabel then
                    local techName = nameLabel.Text:lower()
                    child.Visible = techName:find(searchText) ~= nil or searchText == ""
                end
            end
        end
    end)
end

function UICreator:CreatePlayerTab(tabFrame)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayerScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = tabFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = scrollFrame
    
    -- Speed Hack
    local speedFrame = Instance.new("Frame")
    speedFrame.Name = "SpeedFrame"
    speedFrame.Size = UDim2.new(1, 0, 0, 60)
    speedFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    speedFrame.BorderSizePixel = 0
    speedFrame.Parent = scrollFrame
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Name = "SpeedToggle"
    speedToggle.Size = UDim2.new(0, 100, 0, 30)
    speedToggle.Position = UDim2.new(0, 10, 0.5, -15)
    speedToggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    speedToggle.BorderSizePixel = 0
    speedToggle.Text = "SPEED: OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.TextSize = 14
    speedToggle.Parent = speedFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0, 150, 1, 0)
    speedLabel.Position = UDim2.new(0, 120, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Tốc độ: 16"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 16
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedFrame
    
    local speedSlider = Instance.new("TextBox")
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(0, 80, 0, 25)
    speedSlider.Position = UDim2.new(1, -90, 0.5, -12)
    speedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    speedSlider.BorderSizePixel = 0
    speedSlider.Text = "16"
    speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedSlider.Font = Enum.Font.Gotham
    speedSlider.TextSize = 14
    speedSlider.Parent = speedFrame
    
    -- Jump Hack
    local jumpFrame = Instance.new("Frame")
    jumpFrame.Name = "JumpFrame"
    jumpFrame.Size = UDim2.new(1, 0, 0, 60)
    jumpFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    jumpFrame.BorderSizePixel = 0
    jumpFrame.Parent = scrollFrame
    
    local jumpToggle = Instance.new("TextButton")
    jumpToggle.Name = "JumpToggle"
    jumpToggle.Size = UDim2.new(0, 100, 0, 30)
    jumpToggle.Position = UDim2.new(0, 10, 0.5, -15)
    jumpToggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    jumpToggle.BorderSizePixel = 0
    jumpToggle.Text = "JUMP: OFF"
    jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpToggle.Font = Enum.Font.GothamBold
    jumpToggle.TextSize = 14
    jumpToggle.Parent = jumpFrame
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Name = "JumpLabel"
    jumpLabel.Size = UDim2.new(0, 150, 1, 0)
    jumpLabel.Position = UDim2.new(0, 120, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Nhảy: 50"
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextSize = 16
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpFrame
    
    local jumpSlider = Instance.new("TextBox")
    jumpSlider.Name = "JumpSlider"
    jumpSlider.Size = UDim2.new(0, 80, 0, 25)
    jumpSlider.Position = UDim2.new(1, -90, 0.5, -12)
    jumpSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    jumpSlider.BorderSizePixel = 0
    jumpSlider.Text = "50"
    jumpSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpSlider.Font = Enum.Font.Gotham
    jumpSlider.TextSize = 14
    jumpSlider.Parent = jumpFrame
    
    -- God Mode
    local godFrame = Instance.new("Frame")
    godFrame.Name = "GodFrame"
    godFrame.Size = UDim2.new(1, 0, 0, 40)
    godFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    godFrame.BorderSizePixel = 0
    godFrame.Parent = scrollFrame
    
    local godToggle = Instance.new("TextButton")
    godToggle.Name = "GodToggle"
    godToggle.Size = UDim2.new(0, 200, 0, 30)
    godToggle.Position = UDim2.new(0.5, -100, 0.5, -15)
    godToggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    godToggle.BorderSizePixel = 0
    godToggle.Text = "GOD MODE: OFF"
    godToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    godToggle.Font = Enum.Font.GothamBold
    godToggle.TextSize = 14
    godToggle.Parent = godFrame
    
    -- Auto Farm
    local farmFrame = Instance.new("Frame")
    farmFrame.Name = "FarmFrame"
    farmFrame.Size = UDim2.new(1, 0, 0, 40)
    farmFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    farmFrame.BorderSizePixel = 0
    farmFrame.Parent = scrollFrame
    
    local farmToggle = Instance.new("TextButton")
    farmToggle.Name = "FarmToggle"
    farmToggle.Size = UDim2.new(0, 200, 0, 30)
    farmToggle.Position = UDim2.new(0.5, -100, 0.5, -15)
    farmToggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    farmToggle.BorderSizePixel = 0
    farmToggle.Text = "AUTO FARM: OFF"
    farmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmToggle.Font = Enum.Font.GothamBold
    farmToggle.TextSize = 14
    farmToggle.Parent = farmFrame
    
    -- ESP
    local espFrame = Instance.new("Frame")
    espFrame.Name = "EspFrame"
    espFrame.Size = UDim2.new(1, 0, 0, 40)
    espFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    espFrame.BorderSizePixel = 0
    espFrame.Parent = scrollFrame
    
    local espToggle = Instance.new("TextButton")
    espToggle.Name = "EspToggle"
    espToggle.Size = UDim2.new(0, 200, 0, 30)
    espToggle.Position = UDim2.new(0.5, -100, 0.5, -15)
    espToggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    espToggle.BorderSizePixel = 0
    espToggle.Text = "ESP: OFF"
    espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    espToggle.Font = Enum.Font.GothamBold
    espToggle.TextSize = 14
    espToggle.Parent = espFrame
    
    -- Toggle handlers
    speedToggle.MouseButton1Click:Connect(function()
        playerFeatures.speedHack.enabled = not playerFeatures.speedHack.enabled
        speedToggle.Text = "SPEED: " .. (playerFeatures.speedHack.enabled and "ON" or "OFF")
        speedToggle.BackgroundColor3 = playerFeatures.speedHack.enabled and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    end)
    
    jumpToggle.MouseButton1Click:Connect(function()
        playerFeatures.jumpHack.enabled = not playerFeatures.jumpHack.enabled
        jumpToggle.Text = "JUMP: " .. (playerFeatures.jumpHack.enabled and "ON" or "OFF")
        jumpToggle.BackgroundColor3 = playerFeatures.jumpHack.enabled and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    end)
    
    godToggle.MouseButton1Click:Connect(function()
        playerFeatures.godMode.enabled = not playerFeatures.godMode.enabled
        godToggle.Text = "GOD MODE: " .. (playerFeatures.godMode.enabled and "ON" or "OFF")
        godToggle.BackgroundColor3 = playerFeatures.godMode.enabled and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    end)
    
    farmToggle.MouseButton1Click:Connect(function()
        playerFeatures.autoFarm.enabled = not playerFeatures.autoFarm.enabled
        farmToggle.Text = "AUTO FARM: " .. (playerFeatures.autoFarm.enabled and "ON" or "OFF")
        farmToggle.BackgroundColor3 = playerFeatures.autoFarm.enabled and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    end)
    
    espToggle.MouseButton1Click:Connect(function()
        playerFeatures.espEnabled.enabled = not playerFeatures.espEnabled.enabled
        espToggle.Text = "ESP: " .. (playerFeatures.espEnabled.enabled and "ON" or "OFF")
        espToggle.BackgroundColor3 = playerFeatures.espEnabled.enabled and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    end)
    
    -- Slider handlers
    speedSlider.FocusLost:Connect(function()
        local value = tonumber(speedSlider.Text)
        if value and value >= 1 and value <= 100 then
            playerFeatures.speedHack.value = value
            speedLabel.Text = "Tốc độ: " .. value
        else
            speedSlider.Text = tostring(playerFeatures.speedHack.value)
        end
    end)
    
    jumpSlider.FocusLost:Connect(function()
        local value = tonumber(jumpSlider.Text)
        if value and value >= 1 and value <= 500 then
            playerFeatures.jumpHack.value = value
            jumpLabel.Text = "Nhảy: " .. value
        else
            jumpSlider.Text = tostring(playerFeatures.jumpHack.value)
        end
    end)
end

function UICreator:CreateMapTab(tabFrame)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "MapScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = tabFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = scrollFrame
    
    -- Teleport buttons
    local teleportLocations = {
        {"Spawn Point", Vector3.new(0, 5, 0)},
        {"Boss Arena", Vector3.new(100, 5, 0)},
        {"Item Shop", Vector3.new(-50, 5, 50)},
        {"Training Area", Vector3.new(0, 5, 100)}
    }
    
    for i, location in ipairs(teleportLocations) do
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Name = location[1] .. "Frame"
        buttonFrame.Size = UDim2.new(1, 0, 0, 40)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        buttonFrame.BorderSizePixel = 0
        buttonFrame.Parent = scrollFrame
        
        local teleportButton = Instance.new("TextButton")
        teleportButton.Name = location[1] .. "Button"
        teleportButton.Size = UDim2.new(1, -20, 0, 30)
        teleportButton.Position = UDim2.new(0, 10, 0.5, -15)
        teleportButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        teleportButton.BorderSizePixel = 0
        teleportButton.Text = "TP: " .. location[1]
        teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        teleportButton.Font = Enum.Font.GothamBold
        teleportButton.TextSize = 14
        teleportButton.Parent = buttonFrame
        
        teleportButton.MouseButton1Click:Connect(function()
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.RootPart.CFrame = CFrame.new(location[2])
                Utilities:CreateNotification("Map", "Đã teleport đến " .. location[1], 2)
            end
        end)
    end
    
    -- Auto Collect Items
    local collectFrame = Instance.new("Frame")
    collectFrame.Name = "CollectFrame"
    collectFrame.Size = UDim2.new(1, 0, 0, 40)
    collectFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    collectFrame.BorderSizePixel = 0
    collectFrame.Parent = scrollFrame
    
    local collectToggle = Instance.new("TextButton")
    collectToggle.Name = "CollectToggle"
    collectToggle.Size = UDim2.new(1, -20, 0, 30)
    collectToggle.Position = UDim2.new(0, 10, 0.5, -15)
    collectToggle.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    collectToggle.BorderSizePixel = 0
    collectToggle.Text = "AUTO COLLECT: OFF"
    collectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    collectToggle.Font = Enum.Font.GothamBold
    collectToggle.TextSize = 14
    collectToggle.Parent = collectFrame
    
    collectToggle.MouseButton1Click:Connect(function()
        -- Implement auto collect functionality here
        Utilities:CreateNotification("Map", "Auto Collect chưa được implement", 2)
    end)
end

function UICreator:CreateSettingsTab(tabFrame)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "SettingsScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = tabFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = scrollFrame
    
    -- Keybind setting
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "KeybindFrame"
    keybindFrame.Size = UDim2.new(1, 0, 0, 60)
    keybindFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = scrollFrame
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "KeybindLabel"
    keybindLabel.Size = UDim2.new(0, 200, 1, 0)
    keybindLabel.Position = UDim2.new(0, 10, 0, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "Keybind: RightShift"
    keybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.TextSize = 16
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindFrame
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "KeybindButton"
    keybindButton.Size = UDim2.new(0, 100, 0, 30)
    keybindButton.Position = UDim2.new(1, -110, 0.5, -15)
    keybindButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    keybindButton.BorderSizePixel = 0
    keybindButton.Text = "CHANGE"
    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindButton.Font = Enum.Font.GothamBold
    keybindButton.TextSize = 14
    keybindButton.Parent = keybindFrame
    
    -- Theme setting
    local themeFrame = Instance.new("Frame")
    themeFrame.Name = "ThemeFrame"
    themeFrame.Size = UDim2.new(1, 0, 0, 60)
    themeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    themeFrame.BorderSizePixel = 0
    themeFrame.Parent = scrollFrame
    
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Name = "ThemeLabel"
    themeLabel.Size = UDim2.new(0, 200, 1, 0)
    themeLabel.Position = UDim2.new(0, 10, 0, 0)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Theme: Dark"
    themeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeLabel.Font = Enum.Font.Gotham
    themeLabel.TextSize = 16
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    themeLabel.Parent = themeFrame
    
    local themeButton = Instance.new("TextButton")
    themeButton.Name = "ThemeButton"
    themeButton.Size = UDim2.new(0, 100, 0, 30)
    themeButton.Position = UDim2.new(1, -110, 0.5, -15)
    themeButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    themeButton.BorderSizePixel = 0
    themeButton.Text = "TOGGLE"
    themeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeButton.Font = Enum.Font.GothamBold
    themeButton.TextSize = 14
    themeButton.Parent = themeFrame
    
    -- Auto Load Tech
    local autoLoadFrame = Instance.new("Frame")
    autoLoadFrame.Name = "AutoLoadFrame"
    autoLoadFrame.Size = UDim2.new(1, 0, 0, 40)
    autoLoadFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    autoLoadFrame.BorderSizePixel = 0
    autoLoadFrame.Parent = scrollFrame
    
    local autoLoadToggle = Instance.new("TextButton")
    autoLoadToggle.Name = "AutoLoadToggle"
    autoLoadToggle.Size = UDim2.new(1, -20, 0, 30)
    autoLoadToggle.Position = UDim2.new(0, 10, 0.5, -15)
    autoLoadToggle.BackgroundColor3 = settings.autoLoadTech and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    autoLoadToggle.BorderSizePixel = 0
    autoLoadToggle.Text = "AUTO LOAD TECH: " .. (settings.autoLoadTech and "ON" or "OFF")
    autoLoadToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoLoadToggle.Font = Enum.Font.GothamBold
    autoLoadToggle.TextSize = 14
    autoLoadToggle.Parent = autoLoadFrame
    
    autoLoadToggle.MouseButton1Click:Connect(function()
        settings.autoLoadTech = not settings.autoLoadTech
        autoLoadToggle.Text = "AUTO LOAD TECH: " .. (settings.autoLoadTech and "ON" or "OFF")
        autoLoadToggle.BackgroundColor3 = settings.autoLoadTech and Color3.fromRGB(60, 180, 80) or Color3.fromRGB(180, 60, 60)
    end)
    
    -- Scan for techs button
    local scanFrame = Instance.new("Frame")
    scanFrame.Name = "ScanFrame"
    scanFrame.Size = UDim2.new(1, 0, 0, 40)
    scanFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    scanFrame.BorderSizePixel = 0
    scanFrame.Parent = scrollFrame
    
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(1, -20, 0, 30)
    scanButton.Position = UDim2.new(0, 10, 0.5, -15)
    scanButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    scanButton.BorderSizePixel = 0
    scanButton.Text = "SCAN FOR TECHS"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.Font = Enum.Font.GothamBold
    scanButton.TextSize = 14
    scanButton.Parent = scanFrame
    
    scanButton.MouseButton1Click:Connect(function()
        Utilities:CreateNotification("Settings", "Đang quét tech...", 2)
        local foundTechs = Utilities:ScanForTechs()
        Utilities:CreateNotification("Settings", "Tìm thấy " .. #foundTechs .. " tech", 3)
    end)
end

-- ========== FEATURE HANDLERS ==========
local FeatureHandlers = {}

function FeatureHandlers:HandleSpeedHack()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and playerFeatures.speedHack.enabled then
        humanoid.WalkSpeed = playerFeatures.speedHack.value
    elseif humanoid then
        humanoid.WalkSpeed = 16 -- Default speed
    end
end

function FeatureHandlers:HandleJumpHack()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and playerFeatures.jumpHack.enabled then
        humanoid.JumpPower = playerFeatures.jumpHack.value
    elseif humanoid then
        humanoid.JumpPower = 50 -- Default jump
    end
end

function FeatureHandlers:HandleGodMode()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and playerFeatures.godMode.enabled then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

function FeatureHandlers:HandleAutoFarm()
    if playerFeatures.autoFarm.enabled then
        -- Implement auto farm logic here
        -- This would depend on the specific game mechanics
    end
end

function FeatureHandlers:HandleESP()
    if playerFeatures.espEnabled.enabled then
        -- Implement ESP logic here
        -- Highlight NPCs, players, or items
    end
end

-- ========== MAIN INITIALIZATION ==========
local ZyroHub = {}

function ZyroHub:Initialize()
    Utilities:CreateNotification("Zyro Hub", "Đang khởi động...", 2)
    
    -- Tạo GUI
    local guiElements = UICreator:CreateMainGUI()
    gui = guiElements
    
    -- Tạo tabs
    local tabs = UICreator:CreateTabs(guiElements)
    
    -- Tạo nội dung cho từng tab
    UICreator:CreateTechLoaderTab(tabs["TechLoader"].frame)
    UICreator:CreatePlayerTab(tabs["Player"].frame)
    UICreator:CreateMapTab(tabs["Map"].frame)
    UICreator:CreateSettingsTab(tabs["Settings"].frame)
    
    -- Kết nối sự kiện
    guiElements.closeButton.MouseButton1Click:Connect(function()
        ZyroHub:ToggleGUI(false)
    end)
    
    -- Keybind toggle
    local keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == settings.keybind then
            ZyroHub:ToggleGUI(not hubEnabled)
        end
    end)
    table.insert(connections, keybindConnection)
    
    -- Run features loop
    local runConnection = RunService.Heartbeat:Connect(function()
        FeatureHandlers:HandleSpeedHack()
        FeatureHandlers:HandleJumpHack()
        FeatureHandlers:HandleGodMode()
        FeatureHandlers:HandleAutoFarm()
        FeatureHandlers:HandleESP()
    end)
    table.insert(connections, runConnection)
    
    -- Character added event
    local characterConnection = player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        FeatureHandlers:HandleSpeedHack()
        FeatureHandlers:HandleJumpHack()
    end)
    table.insert(connections, characterConnection)
    
    Utilities:CreateNotification("Zyro Hub", "Khởi động thành công! Nhấn RightShift để mở", 3)
    
    -- Auto load tech nếu enabled
    if settings.autoLoadTech then
        task.wait(2)
        for techName, techData in pairs(defaultTechs) do
            if not techData.loaded then
                Utilities:CreateNotification("Auto Load", "Đang load " .. techName, 2)
                local success = pcall(function()
                    Utilities:LoadScript(techData.url)
                    techData.loaded = true
                end)
            end
        end
    end
end

function ZyroHub:ToggleGUI(enable)
    if not gui then return end
    
    hubEnabled = enable
    gui.mainFrame.Visible = enable
    
    if enable then
        -- Animation khi mở
        gui.mainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(gui.mainFrame, tweenInfo, {
            Size = UDim2.new(0, 400, 0, 500)
        })
        tween:Play()
    end
end

function ZyroHub:Cleanup()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    
    if gui and gui.screenGui then
        gui.screenGui:Destroy()
    end
end

-- ========== EXECUTION ==========
-- Chờ player load
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Khởi động hub
ZyroHub:Initialize()

-- Cleanup khi player rời
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        ZyroHub:Cleanup()
    end
end)

-- Return ZyroHub object cho external access
return ZyroHub
