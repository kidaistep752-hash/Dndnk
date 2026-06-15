-- ====================================================================
--  PART 1: MASTER SERVICES & FILE CONSOLE SETUP
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Принудительное удаление старых копий меню для исключения багов
if CoreGui:FindFirstChild("SimpleNeonSense") then
    CoreGui.SimpleNeonSense:Destroy()
end

local FILE_NAME = "SimpleNeon_Config.json"
local Config = {
    Speedhack = false, SpeedValue = 16,
    Noclip = false,
    SelectedPlayer = "",
    Target = false,
    GodModeToggle = false,
    GodModeType = "Loop",
    SpinBot = false, SpinSpeed = 30,
    FlyMode = false, FlySpeedValue = 40,
    XNeoFlyActive = false,
    OnePunchFling = false,
    ESPToggle = false,
    ESPColor = "WHITE",
    MM2Mod = false
}
local SavedPositionBeforeTP = nil
local flingCooldowns = {}

local function saveSettings()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(Config) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end

local function loadSettings()
    if readfile and isfile and isfile(FILE_NAME) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
        if success then 
            for k, v in pairs(decoded) do 
                if k ~= "Target" and k ~= "Speedhack" and k ~= "SpinBot" and k ~= "FlyMode" and k ~= "GodModeToggle" and k ~= "ESPToggle" then 
                    Config[k] = v 
                end
            end
        end
    end
end
loadSettings()
-- ====================================================================
--  PART 2: DRAG MODULE & NEW ROUNDED DASHBOARDS
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleNeonSense"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0, 140)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.Text = "⚙️"
OpenButton.TextSize = 24
OpenButton.TextColor3 = Color3.fromRGB(186, 85, 211)
OpenButton.ZIndex = 11
OpenButton.Parent = ScreenGui
makeDraggable(OpenButton)

Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", OpenButton)
ButtonStroke.Color = Color3.fromRGB(186, 85, 211)
ButtonStroke.Thickness = 1.5

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 410, 0, 260)
MainFrame.Position = UDim2.new(0.5, -205, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
makeDraggable(MainFrame)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(186, 85, 211)
MainStroke.Thickness = 1.5

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 11

local TopLayout = Instance.new("UIListLayout", TopBar)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.Padding = UDim.new(0, 12)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.ZIndex = 11

-- НОВОЕ ОКНО СПЕЦИАЛЬНО ДЛЯ MM2 MOD
local MM2Window = Instance.new("Frame")
MM2Window.Size = UDim2.new(0, 180, 0, 150)
MM2Window.Position = UDim2.new(0.5, 215, 0.5, -75)
MM2Window.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MM2Window.Visible = false
MM2Window.ZIndex = 20
MM2Window.Parent = ScreenGui
makeDraggable(MM2Window)

Instance.new("UICorner", MM2Window).CornerRadius = UDim.new(0, 8)
local MM2Stroke = Instance.new("UIStroke", MM2Window)
MM2Stroke.Color = Color3.fromRGB(255, 65, 65)
MM2Stroke.Thickness = 1.5

local MM2Title = Instance.new("TextLabel", MM2Window)
MM2Title.Size = UDim2.new(1, 0, 0, 25)
MM2Title.BackgroundTransparency = 1
MM2Title.Text = "MM2 DASHBOARD"
MM2Title.TextColor3 = Color3.fromRGB(255, 65, 65)
MM2Title.Font = Enum.Font.SourceSansBold
MM2Title.TextSize = 12
MM2Title.ZIndex = 21

local MM2Content = Instance.new("Frame", MM2Window)
MM2Content.Size = UDim2.new(1, -10, 1, -35)
MM2Content.Position = UDim2.new(0, 5, 0, 30)
MM2Content.BackgroundTransparency = 1
MM2Content.ZIndex = 21

local MM2Layout = Instance.new("UIListLayout", MM2Content)
MM2Layout.Padding = UDim.new(0, 5)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if not MainFrame.Visible then MM2Window.Visible = false end
end)
-- ====================================================================
--  PART 3: NAVIGATION TABS & GENERIC BUTTON CODE
-- ====================================================================
local pages = {}
local function createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 65, 0, 25)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(110, 110, 110)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.ZIndex = 12
    TabBtn.Parent = TopBar

    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 0
    Page.ZIndex = 12

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(110, 110, 110)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    end)
    pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

local pPlayer = createTab("Player")
local pVisual = createTab("Visual")
local pGame = createTab("Game")
local pOther = createTab("Other")
local pSettings = createTab("Settings")

pages["Player"].Page.Visible = true
pages["Player"].Btn.TextColor3 = Color3.fromRGB(186, 85, 211)

local function createRoundedToggle(parent, text, onClick)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Btn.Text = text .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.TextSize = 13
    Btn.ZIndex = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text .. (state and " [ON]" or " [OFF]")
        Btn.TextColor3 = state and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(150, 150, 150)
        onClick(state)
    end)
end
-- ====================================================================
--  PART 4: ADAPTIVE SLIDER GENERATOR ENGINE
-- ====================================================================
local function createFeatureWithLeftSlider(parent, configKey, speedKey, text, min, max)
    local BigWrapper = Instance.new("Frame", parent)
    BigWrapper.Size = UDim2.new(1, 0, 0, 30)
    BigWrapper.BackgroundTransparency = 1
    BigWrapper.AutomaticSize = Enum.AutomaticSize.Y -- Авто-раздвижение

    local ListInWrapper = Instance.new("UIListLayout", BigWrapper)
    ListInWrapper.Padding = UDim.new(0, 4)

    local MainContainer = Instance.new("Frame", BigWrapper)
    MainContainer.Size = UDim2.new(1, 0, 0, 30)
    MainContainer.BackgroundTransparency = 1

    local ArrowBtn = Instance.new("TextButton", MainContainer)
    ArrowBtn.Size = UDim2.new(0, 20, 1, 0)
    ArrowBtn.BackgroundTransparency = 1
    ArrowBtn.Text = "▶"
    ArrowBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    ArrowBtn.TextSize = 13

    local ToggleBtn = Instance.new("TextButton", MainContainer)
    ToggleBtn.Size = UDim2.new(1, -25, 1, 0)
    ToggleBtn.Position = UDim2.new(0, 25, 0, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    ToggleBtn.Text = text .. " (" .. tostring(Config[speedKey]) .. ") [OFF]"
    ToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleBtn.TextSize = 13
    ToggleBtn.TextWrapped = true
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

    local SliderFrame = Instance.new("Frame", BigWrapper)
    SliderFrame.Size = UDim2.new(1, 0, 0, 22)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    SliderFrame.Visible = false
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 5)

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, -16, 0, 4)
    Bar.Position = UDim2.new(0, 8, 0, 9)
    Bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local Point = Instance.new("Frame", Bar)
    Point.Size = UDim2.new(0, 6, 0, 10)
    Point.Position = UDim2.new((Config[speedKey] - min) / (max - min), -3, 0.5, -5)
    Point.BackgroundColor3 = Color3.fromRGB(186, 85, 211)

    ArrowBtn.MouseButton1Click:Connect(function()
        SliderFrame.Visible = not SliderFrame.Visible
        ArrowBtn.Text = SliderFrame.Visible and "▼" or "▶"
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        saveSettings()
        ToggleBtn.Text = text .. " (" .. tostring(Config[speedKey]) .. ") " .. (Config[configKey] and "[ON]" or "[OFF]")
        ToggleBtn.TextColor3 = Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(150, 150, 150)
    end)

    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Point.Position = UDim2.new(relX, -3, 0.5, -5)
        local val = math.floor(min + (max - min) * relX)
        Config[speedKey] = val
        ToggleBtn.Text = text .. " (" .. tostring(val) .. ") " .. (Config[configKey] and "[ON]" or "[OFF]")
        saveSettings()
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
            local moveCon
            moveCon = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(moveInput)
                end
            end)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then moveCon:Disconnect() end end)
        end
    end)
end

-- Активация регулируемых слайдеров во вкладке Player
createFeatureWithLeftSlider(pPlayer, "Speedhack", "SpeedValue", "Speed", 16, 300)
createFeatureWithLeftSlider(pPlayer, "SpinBot", "SpinSpeed", "Spin Bot", 10, 150)
createFeatureWithLeftSlider(pPlayer, "FlyMode", "FlySpeedValue", "Fly Master", 10, 300)
-- ====================================================================
--  PART 5: SLIDING TARGET & ADVANCED GOD MODE SELECTOR
-- ====================================================================

-- 1. Адаптивный Раздвижной ТАРГЕТ во вкладке PLAYER
local TargetWrapperFrame = Instance.new("Frame", pPlayer)
TargetWrapperFrame.Size = UDim2.new(1, 0, 0, 30)
TargetWrapperFrame.BackgroundTransparency = 1
TargetWrapperFrame.AutomaticSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", TargetWrapperFrame).Padding = UDim.new(0, 4)

local TargetContainer = Instance.new("Frame", TargetWrapperFrame)
TargetContainer.Size = UDim2.new(1, 0, 0, 30)
TargetContainer.BackgroundTransparency = 1

local TargetToggle = Instance.new("TextButton", TargetContainer)
TargetToggle.Size = UDim2.new(1, -30, 1, 0)
TargetToggle.Position = UDim2.new(0, 30, 0, 0)
TargetToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
TargetToggle.Text = "Target [OFF]"
TargetToggle.TextColor3 = Color3.fromRGB(150, 150, 150)
TargetToggle.TextSize = 13
TargetToggle.TextWrapped = true
Instance.new("UICorner", TargetToggle).CornerRadius = UDim.new(0, 5)

local TargetArrow = Instance.new("TextButton", TargetContainer)
TargetArrow.Size = UDim2.new(0, 25, 1, 0)
TargetArrow.BackgroundTransparency = 1
TargetArrow.Text = "▶"
TargetArrow.TextColor3 = Color3.fromRGB(186, 85, 211)
TargetArrow.TextSize = 13

local Dropdown = Instance.new("ScrollingFrame", TargetWrapperFrame)
Dropdown.Size = UDim2.new(1, 0, 0, 85)
Dropdown.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Dropdown.Visible = false
Dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
Dropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", Dropdown).CornerRadius = UDim.new(0, 5)
Instance.new("UIListLayout", Dropdown)

local function refreshDropdown()
    for _, child in pairs(Dropdown:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local PBtn = Instance.new("TextButton", Dropdown)
            PBtn.Size = UDim2.new(1, 0, 0, 22)
            PBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            PBtn.Text = p.Name
            PBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            PBtn.TextSize = 12
            PBtn.MouseButton1Click:Connect(function()
                Config.SelectedPlayer = p.Name
                TargetToggle.Text = "Stuck: " .. p.Name
                Dropdown.Visible = false
                TargetArrow.Text = "▶"
                saveSettings()
            end)
        end
    end
end

TargetArrow.MouseButton1Click:Connect(function()
    Dropdown.Visible = not Dropdown.Visible
    TargetArrow.Text = Dropdown.Visible and "▼" or "▶"
    if Dropdown.Visible then refreshDropdown() end
end)

TargetToggle.MouseButton1Click:Connect(function()
    if Config.SelectedPlayer == "" then return end
    Config.Target = not Config.Target
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if Config.Target then
        TargetToggle.Text = "Tracking: " .. Config.SelectedPlayer
        TargetToggle.TextColor3 = Color3.fromRGB(186, 85, 211)
        if myHRP then SavedPositionBeforeTP = myHRP.CFrame end
    else
        TargetToggle.Text = "Target [OFF]"
        TargetToggle.TextColor3 = Color3.fromRGB(150, 150, 150)
        if SavedPositionBeforeTP and myHRP then
            myHRP.CFrame = SavedPositionBeforeTP
            SavedPositionBeforeTP = nil
        end
    end
end)

-- 2. Адаптивный Раздвижной GOD MODE во вкладке PLAYER
local GodWrapperFrame = Instance.new("Frame", pPlayer)
GodWrapperFrame.Size = UDim2.new(1, 0, 0, 30)
GodWrapperFrame.BackgroundTransparency = 1
GodWrapperFrame.AutomaticSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", GodWrapperFrame).Padding = UDim.new(0, 4)

local GodContainer = Instance.new("Frame", GodWrapperFrame)
GodContainer.Size = UDim2.new(1, 0, 0, 30)
GodContainer.BackgroundTransparency = 1

local GodToggle = Instance.new("TextButton", GodContainer)
GodToggle.Size = UDim2.new(1, -30, 1, 0)
GodToggle.Position = UDim2.new(0, 30, 0, 0)
GodToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
GodToggle.Text = "God Mode (" .. tostring(Config.GodModeType) .. ") [OFF]"
GodToggle.TextColor3 = Color3.fromRGB(150, 150, 150)
GodToggle.TextSize = 13
GodToggle.TextWrapped = true
Instance.new("UICorner", GodToggle).CornerRadius = UDim.new(0, 5)

local GodArrow = Instance.new("TextButton", GodContainer)
GodArrow.Size = UDim2.new(0, 25, 1, 0)
GodArrow.BackgroundTransparency = 1
GodArrow.Text = "▶"
GodArrow.TextColor3 = Color3.fromRGB(186, 85, 211)
GodArrow.TextSize = 13

local GodDropdown = Instance.new("ScrollingFrame", GodWrapperFrame)
GodDropdown.Size = UDim2.new(1, 0, 0, 75)
GodDropdown.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
GodDropdown.Visible = false
Instance.new("UICorner", GodDropdown).CornerRadius = UDim.new(0, 5)
Instance.new("UIListLayout", GodDropdown)

local function addGodOption(name)
    local OBtn = Instance.new("TextButton", GodDropdown)
    OBtn.Size = UDim2.new(1, 0, 0, 22)
    OBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    OBtn.Text = name
    OBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    OBtn.TextSize = 12
    OBtn.MouseButton1Click:Connect(function()
        Config.GodModeType = name
        GodToggle.Text = "God Mode (" .. name .. ") " .. (Config.GodModeToggle and "[ON]" or "[OFF]")
        GodDropdown.Visible = false
        GodArrow.Text = "▶"
        saveSettings()
    end)
end
addGodOption("Ghost")
addGodOption("Loop")
addGodOption("Auto TP")

GodArrow.MouseButton1Click:Connect(function()
    GodDropdown.Visible = not GodDropdown.Visible
    GodArrow.Text = GodDropdown.Visible and "▼" or "▶"
end)

GodToggle.MouseButton1Click:Connect(function()
    Config.GodModeToggle = not Config.GodModeToggle
    saveSettings()
    GodToggle.Text = "God Mode (" .. tostring(Config.GodModeType) .. ") " .. (Config.GodModeToggle and "[ON]" or "[OFF]")
    GodToggle.TextColor3 = Config.GodModeToggle and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(150, 150, 150)
    
    if Config.GodModeToggle and Config.GodModeType == "Ghost" and LocalPlayer.Character then
        local cam = workspace.CurrentCamera
        local oldCF = cam.CFrame
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.2)
        cam.CFrame = oldCF
    end
end)

createRoundedToggle(pPlayer, "One Punch", function(v) Config.OnePunchFling = v end)
createRoundedToggle(pPlayer, "Noclip", function(v) Config.Noclip = v saveSettings() end)
-- ====================================================================
--  PART 5.1: VISUAL PALETTE, GAME MM2 & SERVER MATCHMAKING
-- ====================================================================

-- 1. Наполнение VISUAL TAB (Раздвижной ESP и кнопки выбора цветов)
local EspWrapperFrame = Instance.new("Frame", pVisual)
EspWrapperFrame.Size = UDim2.new(1, 0, 0, 30)
EspWrapperFrame.BackgroundTransparency = 1
EspWrapperFrame.AutomaticSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", EspWrapperFrame).Padding = UDim.new(0, 4)

local EspContainer = Instance.new("Frame", EspWrapperFrame)
EspContainer.Size = UDim2.new(1, 0, 0, 30)
EspContainer.BackgroundTransparency = 1

local EspToggle = Instance.new("TextButton", EspContainer)
EspToggle.Size = UDim2.new(1, -30, 1, 0)
EspToggle.Position = UDim2.new(0, 30, 0, 0)
EspToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
EspToggle.Text = "Master ESP [OFF]"
EspToggle.TextColor3 = Color3.fromRGB(150, 150, 150)
EspToggle.TextSize = 13
Instance.new("UICorner", EspToggle).CornerRadius = UDim.new(0, 5)

local EspArrow = Instance.new("TextButton", EspContainer)
EspArrow.Size = UDim2.new(0, 25, 1, 0)
EspArrow.BackgroundTransparency = 1
EspArrow.Text = "▶"
EspArrow.TextColor3 = Color3.fromRGB(186, 85, 211)
EspArrow.TextSize = 13

local PaletteFrame = Instance.new("Frame", EspWrapperFrame)
PaletteFrame.Size = UDim2.new(1, 0, 0, 26)
PaletteFrame.BackgroundTransparency = 1
PaletteFrame.Visible = false

local PalLayout = Instance.new("UIListLayout", PaletteFrame)
PalLayout.FillDirection = Enum.FillDirection.Horizontal
PalLayout.Padding = UDim.new(0, 5)

local function createPaletteBtn(name, colorRGB)
    local CBtn = Instance.new("TextButton", PaletteFrame)
    CBtn.Size = UDim2.new(0.31, 0, 1, 0)
    CBtn.BackgroundColor3 = colorRGB
    CBtn.Text = name
    CBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CBtn.Font = Enum.Font.SourceSansBold
    CBtn.TextSize = 12
    Instance.new("UICorner", CBtn).CornerRadius = UDim.new(0, 4)
    CBtn.MouseButton1Click:Connect(function() 
        Config.ESPColor = name 
        saveSettings() 
    end)
end
createPaletteBtn("RED", Color3.fromRGB(255, 0, 0))
createPaletteBtn("BLUE", Color3.fromRGB(0, 100, 255))
createPaletteBtn("WHITE", Color3.fromRGB(255, 255, 255))

EspArrow.MouseButton1Click:Connect(function()
    PaletteFrame.Visible = not PaletteFrame.Visible
    EspArrow.Text = PaletteFrame.Visible and "▼" or "▶"
end)

EspToggle.MouseButton1Click:Connect(function()
    Config.ESPToggle = not Config.ESPToggle
    saveSettings()
    EspToggle.Text = "Master ESP " .. (Config.ESPToggle and "[ON]" or "[OFF]")
    EspToggle.TextColor3 = Config.ESPToggle and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(150, 150, 150)
end)

-- 2. Наполнение GAME TAB (MM2 ТРИГГЕР ОКНА)
local MM2Btn = Instance.new("TextButton", pGame)
MM2Btn.Size = UDim2.new(1, 0, 0, 30)
MM2Btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
MM2Btn.Text = "Murder Mystery 2 Mod [OFF]"
MM2Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
MM2Btn.TextSize = 13
Instance.new("UICorner", MM2Btn).CornerRadius = UDim.new(0, 5)

MM2Btn.MouseButton1Click:Connect(function()
    Config.MM2Mod = not Config.MM2Mod
    saveSettings()
    MM2Btn.Text = "Murder Mystery 2 Mod " .. (Config.MM2Mod and "[ON]" or "[OFF]")
    MM2Btn.TextColor3 = Config.MM2Mod and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(150, 150, 150)
    MM2Window.Visible = Config.MM2Mod
end)

-- 3. Наполнение OTHER TAB (Rejoin & Private)
local RejoinBtn = Instance.new("TextButton", pOther)
RejoinBtn.Size = UDim2.new(1, 0, 0, 30)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
RejoinBtn.Text = "Rejoin Server"
RejoinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
RejoinBtn.TextSize = 13
Instance.new("UICorner", RejoinBtn).CornerRadius = UDim.new(0, 5)

local PrivateBtn = Instance.new("TextButton", pOther)
PrivateBtn.Size = UDim2.new(1, 0, 0, 30)
PrivateBtn.BackgroundColor3 = Color3.fromRGB(22, 14, 25)
PrivateBtn.BorderSizePixel = 1
PrivateBtn.BorderColor3 = Color3.fromRGB(186, 85, 211)
PrivateBtn.Text = "Private Matchmaking"
PrivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrivateBtn.Font = Enum.Font.SourceSansBold
PrivateBtn.TextSize = 13
Instance.new("UICorner", PrivateBtn).CornerRadius = UDim.new(0, 5)

RejoinBtn.MouseButton1Click:Connect(function()
    saveSettings()
    pcall(function()
        if #Players:GetPlayers() <= 1 then 
            TeleportService:Teleport(game.PlaceId, LocalPlayer, nil)
        else 
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer, nil) 
        end
    end)
end)

PrivateBtn.MouseButton1Click:Connect(function()
    PrivateBtn.Text = "Forcing empty chamber..."
    PrivateBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    saveSettings()
    task.wait(0.5)
    pcall(function() 
        TeleportService:Teleport(game.PlaceId, nil, nil) 
    end)
end)

-- Справка во вкладке Settings
local infoLabel = Instance.new("TextLabel", pSettings)
infoLabel.Size = UDim2.new(1, 0, 0, 30)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "All settings auto-save to JSON file"
infoLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
infoLabel.TextSize = 12
-- ====================================================================
--  PART 6: FINAL TICK ENGINE, CFRAME FLY, FIXED FLING & ENEMY ESP
-- ====================================================================
local restoreHumanoidStates = function(humanoid)
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return end

    if Config.Speedhack then Hum.WalkSpeed = Config.SpeedValue else Hum.WalkSpeed = 16 end

    if Config.Noclip or Config.Target or Config.FlyMode or Config.OnePunchFling then
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if Config.Target and Config.SelectedPlayer ~= "" then
        local victim = Players:FindFirstChild(Config.SelectedPlayer)
        if victim and victim.Character and victim.Character:FindFirstChild("HumanoidRootPart") then
            HRP.CFrame = victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 2.2)
            HRP.Velocity = Vector3.new(0, 0, 0)
        else
            Config.Target = false
            if SavedPositionBeforeTP then HRP.CFrame = SavedPositionBeforeTP SavedPositionBeforeTP = nil end
        end
    end

    -- Логика плавного профессионального полёта XNEO через TranslateBy
    local AnimationScript = Char:FindFirstChild("Animate")
    if Config.FlyMode and not Config.Target then
        if not Config.XNeoFlyActive then
            Config.XNeoFlyActive = true
            if AnimationScript then AnimationScript.Disabled = true end
            for _, track in next, Hum:GetPlayingAnimationTracks() do track:AdjustSpeed(0) end
            Hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            Hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            Hum:ChangeState(Enum.HumanoidStateType.Swimming)
        end
        HRP.Velocity = Vector3.new(0, 0, 0)
        if Hum.MoveDirection.Magnitude > 0 then
            local speedMultiplier = (Config.FlySpeedValue / 10)
            Char:TranslateBy(Hum.MoveDirection * speedMultiplier)
        end
    else
        if Config.XNeoFlyActive then
            Config.XNeoFlyActive = false
            if AnimationScript then AnimationScript.Disabled = false end
            restoreHumanoidStates(Hum)
        end
    end

    -- Твой исправленный метод One Punch отталкивания
    if Config.OnePunchFling then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                local victimHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                local victimHum = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
                if victimHRP and victimHum and victimHum.Health > 0 then
                    local distance = (HRP.Position - victimHRP.Position).Magnitude
                    if distance < 4 then
                        local pushDirection = HRP.CFrame.LookVector + Vector3.new(0, 0.8, 0)
                        local force = Instance.new("BodyVelocity")
                        force.Velocity = pushDirection * 280 
                        force.MaxForce = Vector3.new(1e7, 1e7, 1e7)
                        force.Parent = victimHRP
                        game:GetService("Debris"):AddItem(force, 0.15)
                    end
                end
            end
        end
    end

    if Config.GodModeToggle then
        if Config.GodModeType == "Loop" then
            Hum.Health = Hum.MaxHealth
        elseif Config.GodModeType == "Auto TP" and Hum.Health > 0 and Hum.Health < 25 then
            local spawnLoc = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawnLoc then HRP.CFrame = spawnLoc.CFrame + Vector3.new(0, 3, 0) else HRP.CFrame = CFrame.new(0, 50, 0) end
        end
    end

    local spinObject = HRP:FindFirstChild("NeonSpinBot")
    if Config.SpinBot then
        if not spinObject then
            spinObject = Instance.new("AngularVelocity")
            spinObject.Name = "NeonSpinBot"
            spinObject.MaxTorque = math.huge
            spinObject.Attachment0 = HRP:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", HRP)
            spinObject.Parent = HRP
        end
        spinObject.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
    else
        if spinObject then spinObject:Destroy() end
    end

    -- Умный Highlight ESP: Подсвечивает только врагов, тебя не трогает
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("NeonSense_HighlightESP")
            if Config.ESPToggle then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "NeonSense_HighlightESP"
                    hl.Parent = p.Character
                end
                local selectedColor3 = Color3.fromRGB(255, 255, 255)
                if Config.ESPColor == "RED" then selectedColor3 = Color3.fromRGB(255, 0, 0)
                elseif Config.ESPColor == "BLUE" then selectedColor3 = Color3.fromRGB(0, 100, 255) end
                hl.Adornee = p.Character
                hl.FillColor = selectedColor3
                hl.OutlineColor = selectedColor3
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
            else
                if hl then hl:Destroy() end
            end
        elseif p == LocalPlayer and LocalPlayer.Character then
            local selfHl = LocalPlayer.Character:FindFirstChild("NeonSense_HighlightESP")
            if selfHl then selfHl:Destroy() end
        end
    end
end)
