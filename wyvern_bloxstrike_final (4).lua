-- ==========================================================
-- WYVERN BLOXSTRIKE - OBFUSCATION OPTIMIZED + REVERSIBLE LOW GFX + RATE LIMIT
-- ==========================================================

-- Wait for the game to fully load (Velocity Crash Preventer)
if not game:IsLoaded() then game.Loaded:Wait() end

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local setclipboard = nil
pcall(function() setclipboard = (rawget and rawget(_G,"setclipboard")) or (rawget and rawget(_G,"toclipboard")) or _G.setclipboard or _G.toclipboard end)

-- Moonveil guvenli gethui - obfuscation sirasinda nil olmaz
local function SafeGetHui()
    local ok, result = pcall(function()
        if gethui then return gethui() end
    end)
    if ok and result then return result end
    return CoreGui
end

local ExecutorName = "Unknown"
pcall(function() if identifyexecutor then ExecutorName = identifyexecutor() or "Unknown" end end)
local ExecLower = string.lower(ExecutorName)
local isXenoOrSolara = string.find(ExecLower, "xeno") ~= nil or string.find(ExecLower, "solara") ~= nil

-- ==========================================================
-- DISCORD EXECUTION LOGGER (WEBHOOK)
-- ==========================================================
local Webhook_URL = "PASTE_YOUR_WEBHOOK_LINK_HERE"

task.spawn(function()
    if Webhook_URL == "PASTE_YOUR_WEBHOOK_LINK_HERE" or Webhook_URL == "" then return end
    
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return end

    local isMobile = tostring(UserInputService.TouchEnabled)
    local country = "Unknown"
    
    pcall(function()
        local response = game:HttpGet("http://ip-api.com/json/?fields=country")
        local data = HttpService:JSONDecode(response)
        if data and data.country then
            country = data.country
        end
    end)

    local timeStr = os.date("%d/%m/%Y - %H:%M:%S")
    local profileLink = "https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile"

    local embedData = {
        ["embeds"] = {{
            ["title"] = "🚀 A New Script Has Been Executed!",
            ["color"] = 65535, -- Cyan Color
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", ["inline"] = true},
                {["name"] = "🌍 Country", ["value"] = country, ["inline"] = true},
                {["name"] = "💻 Executor", ["value"] = ExecutorName, ["inline"] = true},
                {["name"] = "📱 Mobile?", ["value"] = isMobile, ["inline"] = true},
                {["name"] = "⏰ Execution Time", ["value"] = timeStr, ["inline"] = true},
                {["name"] = "🔗 Roblox Profile", ["value"] = "[Click Here to View Profile](" .. profileLink .. ")", ["inline"] = false}
            },
            ["footer"] = {["text"] = "Wyvern Analytics System"}
        }}
    }

    pcall(function()
        req({
            Url = Webhook_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embedData)
        })
    end)
end)

-- ==========================================================
-- SYSTEM MODULES (Fetched after the game is loaded)
-- ==========================================================
local SkinsModule = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Components"):WaitForChild("Libraries"):WaitForChild("Skins"))
local Viewmodel = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("WeaponComponent"):WaitForChild("Classes"):WaitForChild("Viewmodel"))
local InventoryController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("InventoryController"))
local CharFolder = Workspace:WaitForChild("Characters")

-- ==========================================================
-- WYVERN ANTI-BAN & SAFE ERROR CATCHER KICK SYSTEM
-- ==========================================================
local function WyvernErrorKick(errMessage)
    if setclipboard then
        pcall(function() setclipboard("https://discord.gg/cEzvCvdBrm") end)
    end
    local kickText = "\n🛡️ WYVERN ANTI-BAN SYSTEM 🛡️\n\n"
        .. "The script detected an error and you have been disconnected from the server\n"
        .. "for security purposes to prevent an account ban.\n\n"
        .. "Error Details: " .. tostring(errMessage) .. "\n\n"
        .. "Please contact us.\nDiscord link copied to clipboard!"
    LocalPlayer:Kick(kickText)
end

local function PlayStartupSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://108038650150228"
    sound.Volume = 1
    sound.Parent = Workspace
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end
PlayStartupSound()

local Config = {
    SilentEnabled = false, Wallbang = false, FOV = 150, ShowFOV = true, TargetPart = "Head",
    Aimlock = false, AimSmoothness = 2, AimFOV = 150, AimKey = Enum.UserInputType.MouseButton2, AimWallCheck = true, TeamCheck = true,
    HitboxExpander = false, HitboxSize = 2, HitboxTransparency = 50, 
    ESP = false, Box = false, Box3D = false, Name = false, Distance = false, HPBar = false, Skeleton = false, Tracers = false, ViewTracers = false, ViewTracerLength = 15, Chams = false, ShowTeam = false, TeamColors = true,
    MenuKey = Enum.KeyCode.V,
    TPS = false, TPSKey = Enum.KeyCode.X, TPSDistance = 8,
    MovementEnabled = false, JumpPower = 25, SpeedValue = 16, Bhop = false,
    AntiFlash = false, LowGFX = false, AntiSmoke = false,
    SkyChanger = false, SkyTime = 14,
    AutoApplySkins = true, ActiveGunSkins = {}
}

local UIUpdaters = {}
local LowGFXCache = { Materials = {}, Reflectance = {}, Textures = {}, SurfaceAppearances = {}, Lighting = {} }

-- ==========================================================
-- NOTIFICATION SYSTEM
-- ==========================================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "Wyvern_Notifications"
NotifGui.Parent = SafeGetHui()

local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 300, 1, 0)
NotifContainer.Position = UDim2.new(1, -310, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifList = Instance.new("UIListLayout")
NotifList.Parent = NotifContainer
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, 10)
NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
NotifList.HorizontalAlignment = Enum.HorizontalAlignment.Right

local Theme = {
    Background = Color3.fromRGB(20, 0, 50),
    Panel = Color3.fromRGB(30, 30, 70),
    MainColor = Color3.fromRGB(0, 255, 255),
    AccentColor = Color3.fromRGB(255, 50, 200),
    Text = Color3.fromRGB(240, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180),
}

local function SendNotification(title, text, duration)
    duration = duration or 3
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 250, 0, 60)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BackgroundTransparency = 0.1
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.MainColor
    Stroke.Thickness = 1.5
    Stroke.Parent = Frame
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -20, 0, 20)
    TitleLbl.Position = UDim2.new(0, 10, 0, 5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Theme.MainColor
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Frame
    
    local TextLbl = Instance.new("TextLabel")
    TextLbl.Size = UDim2.new(1, -20, 0, 25)
    TextLbl.Position = UDim2.new(0, 10, 0, 25)
    TextLbl.BackgroundTransparency = 1
    TextLbl.Text = text
    TextLbl.TextColor3 = Theme.Text
    TextLbl.Font = Enum.Font.GothamMedium
    TextLbl.TextSize = 12
    TextLbl.TextXAlignment = Enum.TextXAlignment.Left
    TextLbl.TextWrapped = true
    TextLbl.Parent = Frame
    
    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, 0, 0, 4)
    BarBg.Position = UDim2.new(0, 0, 1, -4)
    BarBg.BackgroundColor3 = Theme.Panel
    BarBg.BorderSizePixel = 0
    BarBg.Parent = Frame
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 8)
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 1, 0)
    Bar.BackgroundColor3 = Theme.AccentColor
    Bar.BorderSizePixel = 0
    Bar.Parent = BarBg
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)
    
    Frame.Parent = NotifContainer
    
    Frame.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(Bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    
    task.delay(duration, function()
        local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
        tweenOut:Play()
        TweenService:Create(Stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(TextLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(BarBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Bar, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        tweenOut.Completed:Connect(function() Frame:Destroy() end)
    end)
end

-- ==========================================================
-- CONFIG SYSTEM
-- ==========================================================
local ConfigFolderName = "WyvernBloxstrikeConfigs"

local function SaveConfig(name)
    if not (writefile and isfolder and makefolder) then return false end
    if not isfolder(ConfigFolderName) then makefolder(ConfigFolderName) end
    local dataToSave = {}
    for k, v in pairs(Config) do
        if typeof(v) == "EnumItem" then dataToSave[k] = "ENUM_" .. tostring(v) else dataToSave[k] = v end
    end
    local json = HttpService:JSONEncode(dataToSave)
    writefile(ConfigFolderName .. "/" .. name .. ".json", json)
    return true
end

local function LoadConfig(name)
    if not (readfile and isfile) then return false end
    local path = ConfigFolderName .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local success, json = pcall(function() return readfile(path) end)
    if not success then return false end
    local success2, data = pcall(function() return HttpService:JSONDecode(json) end)
    if not success2 or type(data) ~= "table" then return false end
    for k, v in pairs(data) do
        if type(v) == "string" and string.sub(v, 1, 5) == "ENUM_" then
            local enumStr = string.sub(v, 6)
            local parts = string.split(enumStr, ".")
            pcall(function()
                local loadedEnum = Enum[parts[2]][parts[3]]
                if UIUpdaters[k] then UIUpdaters[k](loadedEnum) else Config[k] = loadedEnum end
            end)
        else
            if UIUpdaters[k] then UIUpdaters[k](v) else Config[k] = v end
        end
    end
    return true
end

local function DeleteConfig(name)
    if not delfile or not isfile then return false end
    local path = ConfigFolderName .. "/" .. name .. ".json"
    if isfile(path) then pcall(function() delfile(path) end) return true end
    return false
end

local Checkifbaseknife = {"CT Knife", "T Knife"}
local TargetKnife = "Karambit" 
local TargetSkin = "Vanilla"   
local TargetGlove = "Sports Gloves"
local TargetSkinGlove = "" 
local TargetGun = nil
local TargetGunSkin = nil

local FoundKnives = {}
local FoundSkins = {"Vanilla"}
local FoundGloves = {}
local FoundGloveSkins = {}
local AvailableGunSkins = {}

local KnifeKeywords = {
    "knife", "karambit", "bayonet", "butterfly", "gut", "huntsman",
    "falchion", "bowie", "daggers", "navaja", "stiletto", "talon",
    "ursus", "kukri", "dagger", "sickle", "machete"
}

local PanelTransparency = 0.7
local MainTransparency = 0.05

-- ==========================================================
-- STARTUP SPLASH SCREEN (SENKRON - ana GUI bitmeden baslamaz)
-- ==========================================================
do
    local SplashGui = Instance.new("ScreenGui")
    SplashGui.Name = "Wyvern_Splash"
    SplashGui.IgnoreGuiInset = true
    SplashGui.Parent = SafeGetHui()

    local SplashBg = Instance.new("Frame", SplashGui)
    SplashBg.Size = UDim2.new(1, 0, 1, 0)
    SplashBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SplashBg.BackgroundTransparency = 0
    SplashBg.BorderSizePixel = 0

    local SplashCard = Instance.new("Frame", SplashBg)
    SplashCard.AnchorPoint = Vector2.new(0.5, 0.5)
    SplashCard.Position = UDim2.new(0.5, 0, 0.5, 60)
    SplashCard.Size = UDim2.new(0, 320, 0, 110)
    SplashCard.BackgroundColor3 = Theme.Background
    SplashCard.BackgroundTransparency = 0.05
    SplashCard.BorderSizePixel = 0
    Instance.new("UICorner", SplashCard).CornerRadius = UDim.new(0, 12)

    local SplashStroke = Instance.new("UIStroke", SplashCard)
    SplashStroke.Color = Theme.MainColor
    SplashStroke.Thickness = 2

    local SplashTitle = Instance.new("TextLabel", SplashCard)
    SplashTitle.Size = UDim2.new(1, 0, 0, 40)
    SplashTitle.Position = UDim2.new(0, 0, 0, 12)
    SplashTitle.BackgroundTransparency = 1
    SplashTitle.Text = "WYVERN BLOXSTRIKE"
    SplashTitle.TextColor3 = Theme.MainColor
    SplashTitle.Font = Enum.Font.GothamBlack
    SplashTitle.TextSize = 26
    SplashTitle.TextTransparency = 1

    local SplashSub = Instance.new("TextLabel", SplashCard)
    SplashSub.Size = UDim2.new(1, 0, 0, 22)
    SplashSub.Position = UDim2.new(0, 0, 0, 52)
    SplashSub.BackgroundTransparency = 1
    SplashSub.Text = "Running on: " .. ExecutorName
    SplashSub.TextColor3 = Theme.TextDim
    SplashSub.Font = Enum.Font.GothamMedium
    SplashSub.TextSize = 12
    SplashSub.TextTransparency = 1

    local SplashBarBg = Instance.new("Frame", SplashCard)
    SplashBarBg.Size = UDim2.new(0.8, 0, 0, 3)
    SplashBarBg.Position = UDim2.new(0.1, 0, 0, 84)
    SplashBarBg.BackgroundColor3 = Theme.Panel
    SplashBarBg.BorderSizePixel = 0
    Instance.new("UICorner", SplashBarBg).CornerRadius = UDim.new(1, 0)

    local SplashBar = Instance.new("Frame", SplashBarBg)
    SplashBar.Size = UDim2.new(0, 0, 1, 0)
    SplashBar.BackgroundColor3 = Theme.MainColor
    SplashBar.BorderSizePixel = 0
    Instance.new("UICorner", SplashBar).CornerRadius = UDim.new(1, 0)

    local SplashStatus = Instance.new("TextLabel", SplashCard)
    SplashStatus.Size = UDim2.new(1, 0, 0, 16)
    SplashStatus.Position = UDim2.new(0, 0, 0, 90)
    SplashStatus.BackgroundTransparency = 1
    SplashStatus.Text = "Initializing..."
    SplashStatus.TextColor3 = Theme.AccentColor
    SplashStatus.Font = Enum.Font.GothamMedium
    SplashStatus.TextSize = 11
    SplashStatus.TextTransparency = 1

    -- Kart yukari gelsin, baslik belirsin
    TweenService:Create(SplashCard,   TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    TweenService:Create(SplashTitle,  TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    task.wait(0.5)
    TweenService:Create(SplashSub,    TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(SplashStatus, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    task.wait(0.45)

    -- Loading bar + status mesajlari (SENKRON)
    local statuses = {"Loading modules...", "Building GUI...", "Hooking services...", "Ready!"}
    for i, msg in ipairs(statuses) do
        SplashStatus.Text = msg
        local t = TweenService:Create(SplashBar, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {Size = UDim2.new(i / #statuses, 0, 1, 0)})
        t:Play()
        t.Completed:Wait()
    end
    task.wait(0.3)

    -- Fade out - tamamen bittikten sonra devam et
    TweenService:Create(SplashBg,     TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashCard,   TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashStroke, TweenInfo.new(0.45), {Transparency = 1}):Play()
    TweenService:Create(SplashTitle,  TweenInfo.new(0.45), {TextTransparency = 1}):Play()
    TweenService:Create(SplashSub,    TweenInfo.new(0.45), {TextTransparency = 1}):Play()
    TweenService:Create(SplashStatus, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
    local fadeBar = TweenService:Create(SplashBar, TweenInfo.new(0.45), {BackgroundTransparency = 1})
    fadeBar:Play()
    fadeBar.Completed:Wait()
    SplashGui:Destroy()
    -- Buradan sonra ana GUI yuklenir
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Wyvern_Bloxstrike"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = SafeGetHui()

for _, gui in pairs(ScreenGui.Parent:GetChildren()) do
    if gui.Name == "Wyvern_Bloxstrike" and gui ~= ScreenGui then gui:Destroy() end
end

local SilentFovGui = Instance.new("ScreenGui")
SilentFovGui.Name = "Wyvern_SilentFOV"
SilentFovGui.IgnoreGuiInset = true
SilentFovGui.Parent = SafeGetHui()

local SILENT_FOV = Instance.new("Frame", SilentFovGui)
SILENT_FOV.AnchorPoint = Vector2.new(0.5, 0.5)
SILENT_FOV.BackgroundTransparency = 1
SILENT_FOV.Visible = false
local SILENT_FOVCorner = Instance.new("UICorner", SILENT_FOV)
SILENT_FOVCorner.CornerRadius = UDim.new(1, 0)
local SILENT_FOVStroke = Instance.new("UIStroke", SILENT_FOV)
SILENT_FOVStroke.Thickness = 1.5
SILENT_FOVStroke.Color = Theme.MainColor

local AIMLOCK_FOV = Instance.new("Frame", SilentFovGui)
AIMLOCK_FOV.AnchorPoint = Vector2.new(0.5, 0.5)
AIMLOCK_FOV.BackgroundTransparency = 1
AIMLOCK_FOV.Visible = false
local AIMLOCK_FOVCorner = Instance.new("UICorner", AIMLOCK_FOV)
AIMLOCK_FOVCorner.CornerRadius = UDim.new(1, 0)
local AIMLOCK_FOVStroke = Instance.new("UIStroke", AIMLOCK_FOV)
AIMLOCK_FOVStroke.Thickness = 1.5
AIMLOCK_FOVStroke.Color = Theme.TextDim

local isMobile = UserInputService.TouchEnabled
local targetWidth = isMobile and 480 or 550
local targetHeight = isMobile and 340 or 400

local OpenMenuBtn = Instance.new("TextButton", ScreenGui)
OpenMenuBtn.Size = UDim2.new(0, 0, 0, 0) 
OpenMenuBtn.AnchorPoint = Vector2.new(0.5, 0.5)
OpenMenuBtn.Position = UDim2.new(0, 35, 0.5, 0)
OpenMenuBtn.BackgroundColor3 = Theme.Background
OpenMenuBtn.BackgroundTransparency = PanelTransparency
OpenMenuBtn.Text = "W"
OpenMenuBtn.TextColor3 = Theme.MainColor
OpenMenuBtn.Font = Enum.Font.GothamBlack
OpenMenuBtn.TextSize = 24
OpenMenuBtn.Visible = false
Instance.new("UICorner", OpenMenuBtn).CornerRadius = UDim.new(1, 0)
local OpenBtnStroke = Instance.new("UIStroke", OpenMenuBtn)
OpenBtnStroke.Color = Theme.AccentColor
OpenBtnStroke.Thickness = 2

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = MainTransparency
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.MainColor
MainStroke.Thickness = 1.5

TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, targetWidth, 0, targetHeight)}):Play()

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", TopBar)
Title.Text = "WYVERN BLOXSTRIKE"
Title.Size = UDim2.new(1, -60, 0.6, 0)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.MainColor
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Title pulse: MainColor <-> AccentColor arasi yumusak gecis
task.spawn(function()
    while Title and Title.Parent do
        TweenService:Create(Title, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Theme.AccentColor}):Play()
        task.wait(1.4)
        TweenService:Create(Title, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Theme.MainColor}):Play()
        task.wait(1.4)
    end
end)

local ExecLabel = Instance.new("TextLabel", TopBar)
ExecLabel.Text = "Running on: " .. ExecutorName
ExecLabel.Size = UDim2.new(1, -60, 0.4, 0)
ExecLabel.Position = UDim2.new(0, 15, 0.6, 0)
ExecLabel.BackgroundTransparency = 1
ExecLabel.TextColor3 = Theme.TextDim
ExecLabel.Font = Enum.Font.GothamMedium
ExecLabel.TextSize = 11
ExecLabel.TextXAlignment = Enum.TextXAlignment.Left

local IsMenuOpen = true
local isTweening = false
local function ToggleMenu(state)
    if isTweening then return end
    IsMenuOpen = state
    isTweening = true
    if state then
        MainFrame.Visible = true
        TweenService:Create(OpenMenuBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.3, function() OpenMenuBtn.Visible = false end)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, targetWidth, 0, targetHeight)})
        tween:Play()
        tween.Completed:Connect(function() isTweening = false end)
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            if not IsMenuOpen then
                MainFrame.Visible = false
                OpenMenuBtn.Visible = true
                TweenService:Create(OpenMenuBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
            end
            isTweening = false
        end)
    end
end

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.AccentColor
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function() ToggleMenu(false) end)
OpenMenuBtn.MouseButton1Click:Connect(function() ToggleMenu(true) end)

local Line = Instance.new("Frame", MainFrame)
Line.Size = UDim2.new(1, 0, 0, 1)
Line.Position = UDim2.new(0, 0, 0, 45)
Line.BackgroundColor3 = Theme.AccentColor
Line.BorderSizePixel = 0
Line.BackgroundTransparency = 0.5

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 46)
TabBar.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -20, 1, -95)
TabContainer.Position = UDim2.new(0, 10, 0, 85)
TabContainer.BackgroundTransparency = 1

local TotalTabs = 6
local ActiveTabIndicator = Instance.new("Frame", TabBar)
ActiveTabIndicator.Size = UDim2.new(1/TotalTabs, 0, 0, 2)
ActiveTabIndicator.Position = UDim2.new(0, 0, 1, -2)
ActiveTabIndicator.BackgroundColor3 = Theme.MainColor
ActiveTabIndicator.BorderSizePixel = 0

local function CreateTab(name, index)
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size = UDim2.new(1/TotalTabs, 0, 1, -2)
    TabBtn.Position = UDim2.new((index - 1) / TotalTabs, 0, 0, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = index == 1 and Theme.MainColor or Theme.TextDim
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    
    local Page = Instance.new("ScrollingFrame", TabContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.MainColor
    Page.Visible = (index == 1)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout", Page)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(TabContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") or child:IsA("Frame") then child.Visible = false end
        end
        for _, child in pairs(TabBar:GetChildren()) do
            if child:IsA("TextButton") then child.TextColor3 = Theme.TextDim end
        end
        Page.Visible = true
        TabBtn.TextColor3 = Theme.MainColor
        TweenService:Create(ActiveTabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new((index - 1) / TotalTabs, 0, 1, -2)
        }):Play()
    end)
    return Page
end

local function CreateToggle(parent, text, varName)
    local ToggleBtn = Instance.new("TextButton", parent)
    ToggleBtn.Size = UDim2.new(1, 0, 0, 32)
    ToggleBtn.BackgroundColor3 = Theme.Panel
    ToggleBtn.BackgroundTransparency = PanelTransparency
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)
    
    local Box = Instance.new("Frame", ToggleBtn)
    Box.Size = UDim2.new(0, 18, 0, 18)
    Box.Position = UDim2.new(0, 10, 0.5, -9)
    Box.BackgroundColor3 = Config[varName] and Theme.MainColor or Color3.fromRGB(20, 20, 30)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Config[varName] and Theme.MainColor or Theme.AccentColor
    BoxStroke.Thickness = 1.5
    
    local Label = Instance.new("TextLabel", ToggleBtn)
    Label.Text = text
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 38, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Config[varName] and Theme.Text or Theme.TextDim
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    UIUpdaters[varName] = function(val)
        Config[varName] = val
        TweenService:Create(Box, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = val and Theme.MainColor or Color3.fromRGB(20, 20, 30)}):Play()
        BoxStroke.Color = Config[varName] and Theme.MainColor or Theme.AccentColor
        Label.TextColor3 = Config[varName] and Theme.Text or Theme.TextDim
    end
    ToggleBtn.MouseButton1Click:Connect(function() UIUpdaters[varName](not Config[varName]) end)
end

-- SMOOTH SLIDER DESIGN
local function CreateSlider(parent, text, min, max, varName)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Theme.Panel
    Frame.BackgroundTransparency = PanelTransparency
    Frame.BorderSizePixel = 0
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel", Frame)
    ValueLabel.Text = tostring(Config[varName])
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -50, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Theme.MainColor
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local BarBg = Instance.new("Frame", Frame)
    BarBg.Size = UDim2.new(1, -20, 0, 4)
    BarBg.Position = UDim2.new(0, 10, 0, 32)
    BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    BarBg.BorderSizePixel = 0
    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
    
    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(math.clamp((Config[varName] - min) / (max - min), 0, 1), 0, 1, 0)
    BarFill.BackgroundColor3 = Theme.MainColor
    BarFill.BorderSizePixel = 0
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
    
    local Trigger = Instance.new("TextButton", BarBg)
    Trigger.Size = UDim2.new(1, 0, 1, 10)
    Trigger.Position = UDim2.new(0, 0, 0.5, -5)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""

    UIUpdaters[varName] = function(val)
        Config[varName] = val
        local pos = math.clamp((val - min) / (max - min), 0, 1)
        BarFill.Size = UDim2.new(pos, 0, 1, 0)
        ValueLabel.Text = tostring(val)
    end

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
        
        -- VISUAL SMOOTHNESS: The bar strictly follows the mouse
        BarFill.Size = UDim2.new(pos, 0, 1, 0)
        
        local rawVal = (max - min) * pos + min
        local val
        -- If the range is too small (e.g., 1-3 Hitbox), use decimal values
        if (max - min) <= 10 then
            val = math.floor(rawVal * 10) / 10
        else
            val = math.floor(rawVal)
        end
        
        Config[varName] = val
        ValueLabel.Text = tostring(val)
    end

    Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
end

local function CreateKeybind(parent, text, varName)
    local KeyFrame = Instance.new("Frame", parent)
    KeyFrame.Size = UDim2.new(1, 0, 0, 32)
    KeyFrame.BackgroundColor3 = Theme.Panel
    KeyFrame.BackgroundTransparency = PanelTransparency
    KeyFrame.BorderSizePixel = 0
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel", KeyFrame)
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local BindBtn = Instance.new("TextButton", KeyFrame)
    BindBtn.Size = UDim2.new(0, 100, 0, 24)
    BindBtn.Position = UDim2.new(1, -110, 0.5, -12)
    BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    BindBtn.BackgroundTransparency = 0.2
    BindBtn.Text = Config[varName].Name
    BindBtn.TextColor3 = Theme.AccentColor
    BindBtn.Font = Enum.Font.GothamBold
    BindBtn.TextSize = 12
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)

    UIUpdaters[varName] = function(val)
        Config[varName] = val
        BindBtn.Text = val.Name
    end

    local binding = false
    BindBtn.MouseButton1Click:Connect(function()
        if binding then return end
        binding = true
        BindBtn.Text = "..."
        task.delay(0.2, function()
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                    UIUpdaters[varName](input.KeyCode)
                    binding = false; conn:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    UIUpdaters[varName](input.UserInputType)
                    binding = false; conn:Disconnect()
                end
            end)
        end)
    end)
end

local function CreateButton(parent, text, feedbackText, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Theme.Panel
    Btn.BackgroundTransparency = PanelTransparency
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Theme.MainColor
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Color = Theme.AccentColor
    Stroke.Thickness = 1.5

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
        if feedbackText then
            local oldText = Btn.Text
            Btn.Text = feedbackText
            Btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.delay(1, function() Btn.Text = oldText; Btn.TextColor3 = Theme.MainColor end)
        end
    end)
    return Btn
end

local function CreateDivider(parent, text)
    local Lbl = Instance.new("TextLabel", parent)
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "- " .. text .. " -"
    Lbl.TextColor3 = Theme.AccentColor
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
end

local PageCombat = CreateTab("COMBAT", 1)
local PageVisuals = CreateTab("VISUALS", 2)
local PageGunSkins = CreateTab("GUN SKINS", 3)
local PageKnife = CreateTab("KNIVES", 4)
local PageGlove = CreateTab("GLOVES", 5)
local PageMisc = CreateTab("MISC", 6)

CreateDivider(PageCombat, "SILENT AIM")
if isXenoOrSolara then
    local WarningLbl = Instance.new("TextLabel", PageCombat)
    WarningLbl.Size = UDim2.new(1, 0, 0, 20)
    WarningLbl.BackgroundTransparency = 1
    WarningLbl.Text = "⚠ Xeno / Solara Does Not Support Silent Aim ⚠"
    WarningLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
    WarningLbl.Font = Enum.Font.GothamBold
    WarningLbl.TextSize = 11
end
CreateToggle(PageCombat, "Enable Silent Aim", "SilentEnabled")
CreateToggle(PageCombat, "Wallbang", "Wallbang")
CreateToggle(PageCombat, "Show Silent FOV", "ShowFOV")
CreateSlider(PageCombat, "Silent FOV Size", 50, 1000, "FOV")

CreateDivider(PageCombat, "AIM ASSIST")
CreateToggle(PageCombat, "Enable Aimlock", "Aimlock")
CreateKeybind(PageCombat, "Aimlock Key", "AimKey")
CreateToggle(PageCombat, "Aim Wall Check", "AimWallCheck")
CreateToggle(PageCombat, "Team Check", "TeamCheck")
CreateSlider(PageCombat, "Aim Smoothness", 1, 10, "AimSmoothness")
CreateSlider(PageCombat, "Aimlock FOV", 50, 1000, "AimFOV")

CreateDivider(PageCombat, "HITBOX EXPANDER")
CreateToggle(PageCombat, "Enable Hitbox", "HitboxExpander")
CreateSlider(PageCombat, "Hitbox Size", 1, 5, "HitboxSize") -- Max 5 Limit
CreateSlider(PageCombat, "Hitbox Transparency (%)", 0, 100, "HitboxTransparency")

CreateDivider(PageVisuals, "ESP VISUALS")
CreateToggle(PageVisuals, "Enable ESP", "ESP")
CreateToggle(PageVisuals, "Boxes", "Box")
CreateToggle(PageVisuals, "3D Box Mode", "Box3D")
CreateToggle(PageVisuals, "Names & Distance", "Name")
CreateToggle(PageVisuals, "Distance Text", "Distance")
CreateToggle(PageVisuals, "HP Bar ESP", "HPBar")
CreateToggle(PageVisuals, "Skeleton ESP", "Skeleton")
CreateToggle(PageVisuals, "Tracers", "Tracers")
CreateToggle(PageVisuals, "View Tracers", "ViewTracers")
CreateSlider(PageVisuals, "Trace Length", 5, 50, "ViewTracerLength")
CreateToggle(PageVisuals, "Chams (Glow)", "Chams")
CreateToggle(PageVisuals, "Show Teammates", "ShowTeam")
CreateToggle(PageVisuals, "Team Colors (Auto)", "TeamColors")

CreateDivider(PageVisuals, "WORLD MODS")
CreateToggle(PageVisuals, "Low GFX (FPS Boost)", "LowGFX")

-- Reversible Low GFX Updater (BAC SAFE - BLOCKS CAMERA OBJECTS)
local oldLowGFXUpdater = UIUpdaters["LowGFX"]
UIUpdaters["LowGFX"] = function(val)
    oldLowGFXUpdater(val)
    if val then
        LowGFXCache.Lighting.GlobalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
        for _, v in pairs(Workspace:GetDescendants()) do
            -- BAC Protection: Do not touch Camera and Characters
            if v:IsDescendantOf(Camera) or (v.Parent and v.Parent:FindFirstChild("Humanoid")) then
                continue
            end

            if v:IsA("BasePart") then
                LowGFXCache.Materials[v] = v.Material
                LowGFXCache.Reflectance[v] = v.Reflectance
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                LowGFXCache.Textures[v] = v.Transparency
                v.Transparency = 1
            elseif v:IsA("SurfaceAppearance") then
                LowGFXCache.SurfaceAppearances[v] = v.Parent
                v.Parent = nil -- Parent removed to avoid Transparency error
            end
        end
    else
        if LowGFXCache.Lighting.GlobalShadows ~= nil then Lighting.GlobalShadows = LowGFXCache.Lighting.GlobalShadows end
        for part, mat in pairs(LowGFXCache.Materials) do if part and part.Parent then part.Material = mat end end
        for part, ref in pairs(LowGFXCache.Reflectance) do if part and part.Parent then part.Reflectance = ref end end
        for tex, trans in pairs(LowGFXCache.Textures) do if tex and tex.Parent then tex.Transparency = trans end end
        for sa, parent in pairs(LowGFXCache.SurfaceAppearances) do if sa and parent then sa.Parent = parent end end
        table.clear(LowGFXCache.Materials)
        table.clear(LowGFXCache.Reflectance)
        table.clear(LowGFXCache.Textures)
        table.clear(LowGFXCache.SurfaceAppearances)
    end
end

CreateDivider(PageVisuals, "VISUAL MODS")
CreateToggle(PageVisuals, "Anti-Flash", "AntiFlash")
CreateToggle(PageVisuals, "Anti-Smoke", "AntiSmoke")

CreateDivider(PageVisuals, "SKY CHANGER")
CreateToggle(PageVisuals, "Enable Sky Changer", "SkyChanger")

-- Sky Changer - sadece deger degisince ClockTime set edilir, RenderStepped'de hic calismiyor
do
    -- Orijinal saati kaydet (toggle kapaninca geri yukle)
    local OriginalClockTime = Lighting.ClockTime

    local SkyFrame = Instance.new("Frame", PageVisuals)
    SkyFrame.Size = UDim2.new(1, 0, 0, 52)
    SkyFrame.BackgroundColor3 = Theme.Panel
    SkyFrame.BackgroundTransparency = PanelTransparency
    SkyFrame.BorderSizePixel = 0
    Instance.new("UICorner", SkyFrame).CornerRadius = UDim.new(0, 4)

    local SkyLabel = Instance.new("TextLabel", SkyFrame)
    SkyLabel.Size = UDim2.new(1, -20, 0, 20)
    SkyLabel.Position = UDim2.new(0, 10, 0, 5)
    SkyLabel.BackgroundTransparency = 1
    SkyLabel.Text = "Time of Day"
    SkyLabel.TextColor3 = Theme.Text
    SkyLabel.Font = Enum.Font.GothamMedium
    SkyLabel.TextSize = 13
    SkyLabel.TextXAlignment = Enum.TextXAlignment.Left

    local function timeToStr(t)
        local h = math.floor(t) % 24
        local m = math.floor((t - math.floor(t)) * 60)
        return string.format("%02d:%02d", h, m)
    end

    local SkyValLabel = Instance.new("TextLabel", SkyFrame)
    SkyValLabel.Size = UDim2.new(0, 55, 0, 20)
    SkyValLabel.Position = UDim2.new(1, -65, 0, 5)
    SkyValLabel.BackgroundTransparency = 1
    SkyValLabel.Text = timeToStr(Config.SkyTime)
    SkyValLabel.TextColor3 = Theme.MainColor
    SkyValLabel.Font = Enum.Font.GothamBold
    SkyValLabel.TextSize = 13
    SkyValLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SkyBarBg = Instance.new("Frame", SkyFrame)
    SkyBarBg.Size = UDim2.new(1, -20, 0, 6)
    SkyBarBg.Position = UDim2.new(0, 10, 0, 34)
    SkyBarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    SkyBarBg.BorderSizePixel = 0
    Instance.new("UICorner", SkyBarBg).CornerRadius = UDim.new(1, 0)

    local SkyBarFill = Instance.new("Frame", SkyBarBg)
    SkyBarFill.Size = UDim2.new(Config.SkyTime / 24, 0, 1, 0)
    SkyBarFill.BackgroundColor3 = Theme.MainColor
    SkyBarFill.BorderSizePixel = 0
    Instance.new("UICorner", SkyBarFill).CornerRadius = UDim.new(1, 0)

    local SkyHandle = Instance.new("Frame", SkyBarBg)
    SkyHandle.Size = UDim2.new(0, 14, 0, 14)
    SkyHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    SkyHandle.Position = UDim2.new(Config.SkyTime / 24, 0, 0.5, 0)
    SkyHandle.BackgroundColor3 = Theme.MainColor
    SkyHandle.BorderSizePixel = 0
    Instance.new("UICorner", SkyHandle).CornerRadius = UDim.new(1, 0)
    local HandleStroke = Instance.new("UIStroke", SkyHandle)
    HandleStroke.Color = Color3.fromRGB(255, 255, 255)
    HandleStroke.Thickness = 1.5
    HandleStroke.Transparency = 0.5

    local SkyTrigger = Instance.new("TextButton", SkyFrame)
    SkyTrigger.Size = UDim2.new(1, -20, 0, 22)
    SkyTrigger.Position = UDim2.new(0, 10, 0, 26)
    SkyTrigger.BackgroundTransparency = 1
    SkyTrigger.Text = ""
    SkyTrigger.ZIndex = 5

    local TimePresets = {
        {label = "Dawn",  value = 6},
        {label = "Noon",  value = 12},
        {label = "Dusk",  value = 18},
        {label = "Night", value = 0},
    }

    local PresetRow = Instance.new("Frame", PageVisuals)
    PresetRow.Size = UDim2.new(1, 0, 0, 28)
    PresetRow.BackgroundTransparency = 1
    local PresetLayout = Instance.new("UIListLayout", PresetRow)
    PresetLayout.FillDirection = Enum.FillDirection.Horizontal
    PresetLayout.Padding = UDim.new(0, 4)

    -- ANTI-CHEAT SAFE: ClockTime sadece bu fonksiyon cagirilinca set edilir
    -- RenderStepped'de kesinlikle calismiyor
    local function ApplySkyTime(val)
        pcall(function()
            Lighting.ClockTime = val % 24
        end)
    end

    local function UpdateSkySlider(val)
        val = math.clamp(math.floor(val * 10) / 10, 0, 23.9)
        Config.SkyTime = val
        local pct = val / 24
        SkyBarFill.Size = UDim2.new(pct, 0, 1, 0)
        SkyHandle.Position = UDim2.new(pct, 0, 0.5, 0)
        SkyValLabel.Text = timeToStr(val)
        if Config.SkyChanger then
            ApplySkyTime(val)
        end
    end

    for _, preset in ipairs(TimePresets) do
        local PBtn = Instance.new("TextButton", PresetRow)
        PBtn.Size = UDim2.new(0.23, 0, 1, 0)
        PBtn.BackgroundColor3 = Theme.Panel
        PBtn.BackgroundTransparency = PanelTransparency
        PBtn.Text = preset.label
        PBtn.TextColor3 = Theme.TextDim
        PBtn.Font = Enum.Font.GothamBold
        PBtn.TextSize = 10
        PBtn.BorderSizePixel = 0
        Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 4)
        PBtn.MouseButton1Click:Connect(function()
            UpdateSkySlider(preset.value)
            for _, b in pairs(PresetRow:GetChildren()) do
                if b:IsA("TextButton") then b.TextColor3 = Theme.TextDim end
            end
            PBtn.TextColor3 = Theme.MainColor
        end)
    end

    local skyDragging = false
    SkyTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            skyDragging = true
            local pos = math.clamp((input.Position.X - SkyBarBg.AbsolutePosition.X) / SkyBarBg.AbsoluteSize.X, 0, 1)
            UpdateSkySlider(pos * 24)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            skyDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if skyDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - SkyBarBg.AbsolutePosition.X) / SkyBarBg.AbsoluteSize.X, 0, 1)
            UpdateSkySlider(pos * 24)
        end
    end)

    local oldSkyUpdater = UIUpdaters["SkyChanger"]
    UIUpdaters["SkyChanger"] = function(val)
        if oldSkyUpdater then oldSkyUpdater(val) end
        Config.SkyChanger = val
        SkyBarFill.BackgroundColor3 = val and Theme.MainColor or Theme.TextDim
        SkyHandle.BackgroundColor3 = val and Theme.MainColor or Theme.TextDim
        if val then
            -- Acilinca bir kez ClockTime set et
            ApplySkyTime(Config.SkyTime)
        else
            -- Kapaninca orijinal saate geri don
            pcall(function()
                Lighting.ClockTime = OriginalClockTime
            end)
        end
    end
end

CreateDivider(PageVisuals, "CAMERA & TPS")
CreateToggle(PageVisuals, "Third Person (TPS)", "TPS")
CreateKeybind(PageVisuals, "TPS Keybind", "TPSKey")
CreateSlider(PageVisuals, "TPS Distance", 5, 25, "TPSDistance")

CreateDivider(PageMisc, "SETTINGS")
CreateKeybind(PageMisc, "Menu Toggle Key", "MenuKey")

CreateDivider(PageMisc, "CHARACTER MOVEMENT")
CreateToggle(PageMisc, "Enable Speed/Jump", "MovementEnabled")
CreateSlider(PageMisc, "Jump Power (Max 25)", 10, 25, "JumpPower")
CreateSlider(PageMisc, "Speed", 16, 25, "SpeedValue")
CreateToggle(PageMisc, "Auto Bhop (Hold Space)", "Bhop")

CreateDivider(PageMisc, "EXTERNAL SCRIPTS")
local isSkinLoaded = false
local SkinBtn = Instance.new("TextButton", PageMisc)
SkinBtn.Size = UDim2.new(1, 0, 0, 32)
SkinBtn.BackgroundColor3 = Theme.Panel
SkinBtn.BackgroundTransparency = PanelTransparency
SkinBtn.BorderSizePixel = 0
SkinBtn.Text = "Skin Changer"
SkinBtn.TextColor3 = Theme.MainColor
SkinBtn.Font = Enum.Font.GothamBold
SkinBtn.TextSize = 13
Instance.new("UICorner", SkinBtn).CornerRadius = UDim.new(0, 4)
local SkinStroke = Instance.new("UIStroke", SkinBtn)
SkinStroke.Color = Theme.AccentColor
SkinStroke.Thickness = 1.5

SkinBtn.MouseButton1Click:Connect(function()
    if not isSkinLoaded then
        isSkinLoaded = true
        SkinBtn.Text = "LOADING..."
        SkinBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
        task.spawn(function()
            pcall(function() loadstring(game:HttpGet("https://gist.githubusercontent.com/waydird/4115942e3a088e13c1dc539f6f752f7c/raw/6025e62495ef1de392617cd4940750974baeeb40/gistfile1.txt"))() end)
            SkinBtn.Text = "LOADED!"
            SkinBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end
end)

-- SERVER HOP AND REJOIN SYSTEM
CreateDivider(PageMisc, "SERVER")

local ServerBtnContainer = Instance.new("Frame", PageMisc)
ServerBtnContainer.Size = UDim2.new(1, 0, 0, 32)
ServerBtnContainer.BackgroundTransparency = 1
local SBtnLayout = Instance.new("UIListLayout", ServerBtnContainer)
SBtnLayout.FillDirection = Enum.FillDirection.Horizontal
SBtnLayout.Padding = UDim.new(0, 5)

local RejoinBtn = CreateButton(ServerBtnContainer, "REJOIN", "REJOINING...", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
RejoinBtn.Size = UDim2.new(0.48, 0, 1, 0)

local HopBtn = CreateButton(ServerBtnContainer, "SERVER HOP", "HOPPING...", function()
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    task.spawn(function()
        local success, result = pcall(function() return game:HttpGet(Api) end)
        if success then
            local data = HttpService:JSONDecode(result)
            if data and data.data then
                local servers = {}
                for _, v in ipairs(data.data) do
                    if v.playing and v.maxPlayers and v.playing < (v.maxPlayers - 1) and v.id ~= game.JobId then table.insert(servers, v.id) end
                end
                if #servers > 0 then
                    local randomServer = servers[math.random(1, #servers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
                end
            end
        end
    end)
end)
HopBtn.Size = UDim2.new(0.48, 0, 1, 0)

CreateDivider(PageMisc, "COMMUNITY")
CreateButton(PageMisc, "Copy Discord Link", "COPIED!", function()
    if setclipboard then setclipboard("https://discord.gg/cEzvCvdBrm") elseif toclipboard then toclipboard("https://discord.gg/cEzvCvdBrm") end
end)

-- ==========================================================
-- ADVANCED CONFIGURATION UI
-- ==========================================================
CreateDivider(PageMisc, "CONFIGURATION")

local ConfigNameBox = Instance.new("TextBox", PageMisc)
ConfigNameBox.Size = UDim2.new(1, 0, 0, 32)
ConfigNameBox.BackgroundColor3 = Theme.Panel
ConfigNameBox.BackgroundTransparency = PanelTransparency
ConfigNameBox.TextColor3 = Theme.Text
ConfigNameBox.PlaceholderText = "Enter Config Name (e.g. Legit)"
ConfigNameBox.Font = Enum.Font.GothamMedium
ConfigNameBox.TextSize = 13
ConfigNameBox.Text = "Default"
Instance.new("UICorner", ConfigNameBox).CornerRadius = UDim.new(0, 4)
local CNameStroke = Instance.new("UIStroke", ConfigNameBox)
CNameStroke.Color = Theme.AccentColor
CNameStroke.Thickness = 1

local ConfigScroll = Instance.new("ScrollingFrame", PageMisc)
ConfigScroll.Size = UDim2.new(1, 0, 0, 100)
ConfigScroll.BackgroundColor3 = Theme.Panel
ConfigScroll.BackgroundTransparency = PanelTransparency
ConfigScroll.BorderSizePixel = 0
ConfigScroll.ScrollBarThickness = 4
ConfigScroll.ScrollBarImageColor3 = Theme.MainColor

local ConfigListLayout = Instance.new("UIListLayout", ConfigScroll)
ConfigListLayout.Padding = UDim.new(0, 2)
ConfigListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function RefreshConfigList()
    for _, child in pairs(ConfigScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    if listfiles and isfolder(ConfigFolderName) then
        for _, file in pairs(listfiles(ConfigFolderName)) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/]+)%.json$") or file
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 25)
                btn.BackgroundColor3 = Theme.Background
                btn.BackgroundTransparency = PanelTransparency
                btn.TextColor3 = Theme.Text
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 13
                btn.Text = name
                btn.Parent = ConfigScroll
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                
                btn.MouseButton1Click:Connect(function()
                    ConfigNameBox.Text = name
                    for _, b in pairs(ConfigScroll:GetChildren()) do
                        if b:IsA("TextButton") then b.TextColor3 = Theme.Text; b.BackgroundColor3 = Theme.Background end
                    end
                    btn.TextColor3 = Theme.MainColor
                    btn.BackgroundColor3 = Theme.Panel
                end)
            end
        end
    end
    ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, ConfigListLayout.AbsoluteContentSize.Y + 5)
end

local ConfigBtnContainer = Instance.new("Frame", PageMisc)
ConfigBtnContainer.Size = UDim2.new(1, 0, 0, 32)
ConfigBtnContainer.BackgroundTransparency = 1

local CfgBtnLayout = Instance.new("UIListLayout", ConfigBtnContainer)
CfgBtnLayout.FillDirection = Enum.FillDirection.Horizontal
CfgBtnLayout.Padding = UDim.new(0, 5)

local SaveBtn = CreateButton(ConfigBtnContainer, "SAVE", "SAVED!", function()
    local name = ConfigNameBox.Text
    if name ~= "" then 
        local success = SaveConfig(name)
        if not success then ConfigNameBox.Text = "Error saving!" end
        RefreshConfigList()
    end
end)
SaveBtn.Size = UDim2.new(0.32, 0, 1, 0)

local LoadBtn = CreateButton(ConfigBtnContainer, "LOAD", "LOADED!", function()
    local name = ConfigNameBox.Text
    if name ~= "" then 
        local success = LoadConfig(name)
        if not success then ConfigNameBox.Text = "Not Found!" end
    end
end)
LoadBtn.Size = UDim2.new(0.32, 0, 1, 0)

local DeleteBtn = CreateButton(ConfigBtnContainer, "DEL", "DELETED!", function()
    local name = ConfigNameBox.Text
    if name ~= "" then 
        local success = DeleteConfig(name)
        if not success then ConfigNameBox.Text = "Delete Error!" end
        RefreshConfigList()
    end
end)
DeleteBtn.Size = UDim2.new(0.32, 0, 1, 0)
DeleteBtn.TextColor3 = Color3.fromRGB(255, 50, 50)

RefreshConfigList()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if UserInputService:GetFocusedTextBox() then return end
    local pressedKey = input.KeyCode
    local pressedMouse = input.UserInputType
    if pressedKey == Config.MenuKey or pressedMouse == Config.MenuKey then ToggleMenu(not IsMenuOpen) end
    if pressedKey == Config.TPSKey or pressedMouse == Config.TPSKey then UIUpdaters.TPS(not Config.TPS) end
end)

local function ScanItems()
    local skinsFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Skins")
    if skinsFolder then
        for _, folder in pairs(skinsFolder:GetChildren()) do
            local nameLower = folder.Name:lower()
            local isKnifeOrGlove = false
            for _, keyword in ipairs(KnifeKeywords) do
                if nameLower:find(keyword) then isKnifeOrGlove = true; table.insert(FoundKnives, folder.Name); break end
            end
            if not isKnifeOrGlove and (nameLower:find("glove") or nameLower:find("wraps")) then
                isKnifeOrGlove = true; table.insert(FoundGloves, folder.Name)
            end
            if not isKnifeOrGlove then
                AvailableGunSkins[folder.Name] = {}
                for _, skinFolder in pairs(folder:GetChildren()) do table.insert(AvailableGunSkins[folder.Name], skinFolder.Name) end
            end
        end
    end
end

local function UpdateSkins(folderName, isGlove)
    local tempSkins = {}
    if not isGlove then table.insert(tempSkins, "Vanilla") end
    local skinsFolder = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Skins")
    if skinsFolder then
        local targetFolder = skinsFolder:FindFirstChild(folderName)
        if targetFolder then for _, skin in pairs(targetFolder:GetChildren()) do table.insert(tempSkins, skin.Name) end end
    end
    if isGlove then FoundGloveSkins = tempSkins if #FoundGloveSkins > 0 then TargetSkinGlove = FoundGloveSkins[1] else TargetSkinGlove = "" end
    else FoundSkins = tempSkins end
end

ScanItems()
if #FoundGloves > 0 then TargetGlove = FoundGloves[1]; UpdateSkins(TargetGlove, true) end

PageGunSkins:ClearAllChildren(); PageGunSkins.CanvasSize = UDim2.new(0, 0, 0, 0); PageGunSkins.ScrollingEnabled = false

local AutoApplyFrame = Instance.new("Frame", PageGunSkins)
AutoApplyFrame.Size = UDim2.new(1, 0, 0, 30); AutoApplyFrame.BackgroundTransparency = 1

local AutoToggle = Instance.new("TextButton", AutoApplyFrame)
AutoToggle.Size = UDim2.new(0, 20, 0, 20); AutoToggle.Position = UDim2.new(0, 10, 0.5, -10)
AutoToggle.BackgroundColor3 = Config.AutoApplySkins and Theme.MainColor or Color3.fromRGB(60,60,60)
AutoToggle.Text = ""; Instance.new("UICorner", AutoToggle).CornerRadius = UDim.new(0, 4)

local AutoLabel = Instance.new("TextLabel", AutoApplyFrame)
AutoLabel.Text = "AUTO APPLY (Re-equip weapon)"
AutoLabel.Size = UDim2.new(0, 200, 1, 0); AutoLabel.Position = UDim2.new(0, 40, 0, 0); AutoLabel.BackgroundTransparency = 1
AutoLabel.TextColor3 = Theme.Text; AutoLabel.Font = Enum.Font.GothamBold; AutoLabel.TextSize = 12; AutoLabel.TextXAlignment = Enum.TextXAlignment.Left

AutoToggle.MouseButton1Click:Connect(function()
    Config.AutoApplySkins = not Config.AutoApplySkins
    AutoToggle.BackgroundColor3 = Config.AutoApplySkins and Theme.MainColor or Color3.fromRGB(60,60,60)
end)

local GunSearchBox = Instance.new("TextBox", PageGunSkins)
GunSearchBox.Size = UDim2.new(1, -20, 0, 30); GunSearchBox.Position = UDim2.new(0, 10, 0, 35)
GunSearchBox.BackgroundColor3 = Theme.Panel; GunSearchBox.BackgroundTransparency = PanelTransparency
GunSearchBox.Text = ""; GunSearchBox.PlaceholderText = "Search Weapon..."
GunSearchBox.PlaceholderColor3 = Theme.TextDim; GunSearchBox.TextColor3 = Theme.MainColor
GunSearchBox.Font = Enum.Font.GothamMedium; GunSearchBox.TextSize = 14
Instance.new("UICorner", GunSearchBox).CornerRadius = UDim.new(0, 6)
local GunSearchStroke = Instance.new("UIStroke", GunSearchBox)
GunSearchStroke.Color = Theme.AccentColor; GunSearchStroke.Thickness = 1.5; GunSearchStroke.Transparency = 0.5

local GunWeaponScroll = Instance.new("ScrollingFrame", PageGunSkins)
GunWeaponScroll.Size = UDim2.new(0.48, 0, 0.60, 0); GunWeaponScroll.Position = UDim2.new(0, 0, 0, 75)
GunWeaponScroll.BackgroundColor3 = Theme.Panel; GunWeaponScroll.BackgroundTransparency = PanelTransparency
GunWeaponScroll.BorderSizePixel = 0; GunWeaponScroll.ScrollBarThickness = 2; GunWeaponScroll.ScrollBarImageColor3 = Theme.MainColor
local GWList = Instance.new("UIListLayout", GunWeaponScroll); GWList.Padding = UDim.new(0, 4)

local GunSkinScroll = Instance.new("ScrollingFrame", PageGunSkins)
GunSkinScroll.Size = UDim2.new(0.48, 0, 0.60, 0); GunSkinScroll.Position = UDim2.new(0.52, 0, 0, 75)
GunSkinScroll.BackgroundColor3 = Theme.Panel; GunSkinScroll.BackgroundTransparency = PanelTransparency
GunSkinScroll.BorderSizePixel = 0; GunSkinScroll.ScrollBarThickness = 2; GunSkinScroll.ScrollBarImageColor3 = Theme.MainColor
local GSList = Instance.new("UIListLayout", GunSkinScroll); GSList.Padding = UDim.new(0, 4)

GunSearchBox:GetPropertyChangedSignal("Text"):Connect(function() 
    local text = GunSearchBox.Text:lower()
    for _, btn in pairs(GunWeaponScroll:GetChildren()) do 
        if btn:IsA("TextButton") then 
            if text == "" or btn.Text:lower():find(text) then btn.Visible = true else btn.Visible = false end 
        end 
    end 
end)

local function UpdateGunSkinList(weaponName)
    for _, c in pairs(GunSkinScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local skins = AvailableGunSkins[weaponName]
    if skins then
        local StockBtn = Instance.new("TextButton", GunSkinScroll)
        StockBtn.Text = "Stock"; StockBtn.Size = UDim2.new(1, -6, 0, 25); StockBtn.BackgroundColor3 = Theme.Background
        StockBtn.BackgroundTransparency = PanelTransparency; StockBtn.TextColor3 = Theme.Text; StockBtn.Font = Enum.Font.GothamMedium; StockBtn.TextSize = 12
        Instance.new("UICorner", StockBtn).CornerRadius = UDim.new(0,4)
        StockBtn.MouseButton1Click:Connect(function() 
            TargetGunSkin = "Stock"
            for _, b in pairs(GunSkinScroll:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Theme.Text; b.BackgroundColor3 = Theme.Background end end
            StockBtn.TextColor3 = Theme.MainColor; StockBtn.BackgroundColor3 = Theme.Panel 
        end)

        for _, skinName in ipairs(skins) do 
            local SBtn = Instance.new("TextButton", GunSkinScroll)
            SBtn.Text = skinName; SBtn.Size = UDim2.new(1, -6, 0, 25); SBtn.BackgroundColor3 = Theme.Background
            SBtn.BackgroundTransparency = PanelTransparency; SBtn.TextColor3 = Theme.Text; SBtn.Font = Enum.Font.GothamMedium; SBtn.TextSize = 12
            Instance.new("UICorner", SBtn).CornerRadius = UDim.new(0,4)
            SBtn.MouseButton1Click:Connect(function() 
                TargetGunSkin = skinName
                for _, b in pairs(GunSkinScroll:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Theme.Text; b.BackgroundColor3 = Theme.Background end end
                SBtn.TextColor3 = Theme.MainColor; SBtn.BackgroundColor3 = Theme.Panel 
            end) 
        end
        GunSkinScroll.CanvasSize = UDim2.new(0, 0, 0, GSList.AbsoluteContentSize.Y + 10)
    end
end

local sortedWeapons = {}
for w, _ in pairs(AvailableGunSkins) do table.insert(sortedWeapons, w) end
table.sort(sortedWeapons)

for _, weaponName in ipairs(sortedWeapons) do 
    local WBtn = Instance.new("TextButton", GunWeaponScroll)
    WBtn.Text = weaponName; WBtn.Size = UDim2.new(1, -6, 0, 25); WBtn.BackgroundColor3 = Theme.Background
    WBtn.BackgroundTransparency = PanelTransparency; WBtn.TextColor3 = Theme.Text; WBtn.Font = Enum.Font.GothamMedium; WBtn.TextSize = 12
    Instance.new("UICorner", WBtn).CornerRadius = UDim.new(0,4)
    WBtn.MouseButton1Click:Connect(function() 
        TargetGun = weaponName; TargetGunSkin = nil; UpdateGunSkinList(weaponName)
        for _, b in pairs(GunWeaponScroll:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Theme.Text; b.BackgroundColor3 = Theme.Background end end
        WBtn.TextColor3 = Theme.AccentColor; WBtn.BackgroundColor3 = Theme.Panel 
    end) 
end
GunWeaponScroll.CanvasSize = UDim2.new(0, 0, 0, GWList.AbsoluteContentSize.Y + 10)

local GunApplyBtn = Instance.new("TextButton", PageGunSkins)
GunApplyBtn.Text = "SAVE & APPLY ALL"
GunApplyBtn.Size = UDim2.new(1, 0, 0, 30); GunApplyBtn.Position = UDim2.new(0, 0, 1, -30)
GunApplyBtn.BackgroundColor3 = Theme.Panel; GunApplyBtn.BackgroundTransparency = PanelTransparency
GunApplyBtn.TextColor3 = Theme.MainColor; GunApplyBtn.Font = Enum.Font.GothamBlack; GunApplyBtn.TextSize = 14
Instance.new("UICorner", GunApplyBtn).CornerRadius = UDim.new(0, 6)
local GunApplyStroke = Instance.new("UIStroke", GunApplyBtn); GunApplyStroke.Color = Theme.AccentColor; GunApplyStroke.Thickness = 2

local SkinsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skins")

-- COMPREHENSIVE SKIN APPLIER (Advanced Exact Match Engine)
--[[moonveil:no-virtualize]]
local function ApplyWeaponSkin(weaponModel)
    local weaponName = weaponModel.Name
    local selectedSkin = Config.ActiveGunSkins[weaponName]
    if not selectedSkin or selectedSkin == "Stock" then return end
    
    local weaponFolder = SkinsFolder:FindFirstChild(weaponName)
    if not weaponFolder then return end
    
    local skinFolder = weaponFolder:FindFirstChild(selectedSkin)
    if not skinFolder then return end
    
    local assetSource = skinFolder:FindFirstChild("Camera") or skinFolder
    
    -- Find the correct wear level folder dynamically
    local finalSource = assetSource:FindFirstChild("Factory New") 
        or assetSource:FindFirstChild("Minimal Wear") 
        or assetSource:FindFirstChild("Field-Tested") 
        or assetSource:FindFirstChild("Well-Worn") 
        or assetSource:FindFirstChild("Battle-Scarred") 
        or assetSource
    
    -- Map exact names to textures
    local skinAssets = {}
    local fallbackAsset = nil
    
    for _, obj in pairs(finalSource:GetChildren()) do
        if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
            local name = string.lower(obj.Name)
            skinAssets[name] = obj
            
            if name:find("body") or name:find("receiver") or name:find("main") then
                fallbackAsset = obj
            end
        end
    end
    
    if not fallbackAsset then
        for _, obj in pairs(skinAssets) do fallbackAsset = obj; break; end
    end

    local function isArmOrGlove(n)
        n = string.lower(n)
        if n:find("glove") or n:find("sleeve") or n:find("arm") or n:find("wrist") then return true end
        -- Protect "hand" but not "handle" or "handguard"
        if n:find("hand") and not n:find("handle") and not n:find("handguard") then return true end
        return false
    end

    for _, descendant in pairs(weaponModel:GetDescendants()) do 
        if descendant:IsA("BasePart") then
            local descName = string.lower(descendant.Name)
            local parentName = descendant.Parent and string.lower(descendant.Parent.Name) or ""
            
            -- SECURITY FIX: Do not apply weapon skins to arms or gloves (using smart check)
            if isArmOrGlove(descName) or isArmOrGlove(parentName) then
                continue
            end

            -- 1. Try Exact Part Name
            local targetAsset = skinAssets[descName]
            
            -- 2. Try Internal SurfaceAppearance Name Match
            if not targetAsset then
                for _, child in pairs(descendant:GetChildren()) do
                    if child:IsA("SurfaceAppearance") then
                        local cName = string.lower(child.Name)
                        if skinAssets[cName] then
                            targetAsset = skinAssets[cName]
                            break
                        end
                    end
                end
            end

            -- 3. Fallback for MeshParts (Receiver/Body)
            if not targetAsset and descendant:IsA("MeshPart") then
                targetAsset = fallbackAsset
            end
            
            if targetAsset then 
                -- Clean old textures
                for _, old in pairs(descendant:GetChildren()) do 
                    if old:IsA("SurfaceAppearance") or old:IsA("Texture") or old:IsA("Decal") then old:Destroy() end 
                end
                
                if descendant:IsA("MeshPart") then descendant.TextureID = "" end
                local specialMesh = descendant:FindFirstChildWhichIsA("SpecialMesh")
                if specialMesh then specialMesh.TextureId = "" end
                
                -- Apply new texture safely
                if targetAsset:IsA("SurfaceAppearance") then
                    if descendant:IsA("MeshPart") then
                        targetAsset:Clone().Parent = descendant
                    end
                else
                    targetAsset:Clone().Parent = descendant
                end
            end 
        end
    end
end

GunApplyBtn.MouseButton1Click:Connect(function() 
    if TargetGun and TargetGunSkin then Config.ActiveGunSkins[TargetGun] = TargetGunSkin end
    GunApplyBtn.Text = "APPLIED!"; GunApplyBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
    local success, err = pcall(function()
        for _, child in pairs(Camera:GetChildren()) do if child:IsA("Model") then ApplyWeaponSkin(child) end end
    end)
    if not success then WyvernErrorKick("Skin Changer Error: " .. tostring(err)) return end
    task.wait(1)
    GunApplyBtn.Text = "SAVE & APPLY ALL"; GunApplyBtn.TextColor3 = Theme.MainColor 
end)

Camera.ChildAdded:Connect(function(child) 
    if Config.AutoApplySkins and AvailableGunSkins[child.Name] then 
        task.wait(0.2); 
        local success, err = pcall(function() ApplyWeaponSkin(child) end)
        if not success then WyvernErrorKick("Auto Skin Apply Error: " .. tostring(err)) end
    end 
end)

PageKnife:ClearAllChildren(); PageKnife.CanvasSize = UDim2.new(0, 0, 0, 0); PageKnife.ScrollingEnabled = false
local KnifeTitle = Instance.new("TextLabel", PageKnife); KnifeTitle.Size = UDim2.new(0.5, -5, 0, 20); KnifeTitle.Position = UDim2.new(0, 0, 0, 0); KnifeTitle.BackgroundTransparency = 1; KnifeTitle.Text = "KNIVES"; KnifeTitle.TextColor3 = Theme.MainColor; KnifeTitle.Font = Enum.Font.GothamBold; KnifeTitle.TextSize = 12
local SkinTitle = Instance.new("TextLabel", PageKnife); SkinTitle.Size = UDim2.new(0.5, -5, 0, 20); SkinTitle.Position = UDim2.new(0.5, 5, 0, 0); SkinTitle.BackgroundTransparency = 1; SkinTitle.Text = "SKINS (Vanilla)"; SkinTitle.TextColor3 = Theme.MainColor; SkinTitle.Font = Enum.Font.GothamBold; SkinTitle.TextSize = 12

local KnifeScroll = Instance.new("ScrollingFrame", PageKnife); KnifeScroll.Size = UDim2.new(0.5, -5, 1, -25); KnifeScroll.Position = UDim2.new(0, 0, 0, 25); KnifeScroll.BackgroundColor3 = Theme.Panel; KnifeScroll.BackgroundTransparency = PanelTransparency; KnifeScroll.BorderSizePixel = 0; KnifeScroll.ScrollBarThickness = 2; KnifeScroll.ScrollBarImageColor3 = Theme.MainColor
local KnifeLayout = Instance.new("UIListLayout", KnifeScroll); KnifeLayout.Padding = UDim.new(0, 4)
local SkinScroll = Instance.new("ScrollingFrame", PageKnife); SkinScroll.Size = UDim2.new(0.5, -5, 1, -25); SkinScroll.Position = UDim2.new(0.5, 5, 0, 25); SkinScroll.BackgroundColor3 = Theme.Panel; SkinScroll.BackgroundTransparency = PanelTransparency; SkinScroll.BorderSizePixel = 0; KnifeScroll.ScrollBarThickness = 2; SkinScroll.ScrollBarImageColor3 = Theme.MainColor
local SkinLayout = Instance.new("UIListLayout", SkinScroll); SkinLayout.Padding = UDim.new(0, 4)

local function CreateKnifeButton(text, parentScroll, isSkin)
    local btn = Instance.new("TextButton", parentScroll)
    btn.Size = UDim2.new(1, 0, 0, 25); btn.BackgroundColor3 = Theme.Background; btn.BackgroundTransparency = PanelTransparency; btn.TextColor3 = Theme.Text; btn.Text = text; btn.Font = Enum.Font.Gotham; btn.TextSize = 12; btn.BorderSizePixel = 0; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        if not isSkin then
            TargetKnife = text; SkinTitle.Text = "SKINS ("..text..")"
            UpdateSkins(TargetKnife, false)
            for _, child in pairs(SkinScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _, skin in ipairs(FoundSkins) do CreateKnifeButton(skin, SkinScroll, true) end
            SkinScroll.CanvasSize = UDim2.new(0, 0, 0, SkinLayout.AbsoluteContentSize.Y + 10)
            TargetSkin = "Vanilla"
            SendNotification("Knife Equipped", TargetKnife .. " will be applied next round.", 3)
        else
            TargetSkin = text
            local oldText = btn.Text
            btn.Text = "Applied!"
            btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.delay(1.5, function() if btn and btn.Parent then btn.Text = oldText; btn.TextColor3 = Theme.Text end end)
        end
    end)
end

PageGlove:ClearAllChildren(); PageGlove.CanvasSize = UDim2.new(0, 0, 0, 0); PageGlove.ScrollingEnabled = false
local GloveTitle = Instance.new("TextLabel", PageGlove); GloveTitle.Size = UDim2.new(0.5, -5, 0, 20); GloveTitle.Position = UDim2.new(0, 0, 0, 0); GloveTitle.BackgroundTransparency = 1; GloveTitle.Text = "GLOVES"; GloveTitle.TextColor3 = Theme.MainColor; GloveTitle.Font = Enum.Font.GothamBold; GloveTitle.TextSize = 12
local GloveSkinTitle = Instance.new("TextLabel", PageGlove); GloveSkinTitle.Size = UDim2.new(0.5, -5, 0, 20); GloveSkinTitle.Position = UDim2.new(0.5, 5, 0, 0); GloveSkinTitle.BackgroundTransparency = 1; GloveSkinTitle.Text = "SKINS ("..TargetSkinGlove..")"; GloveSkinTitle.TextColor3 = Theme.MainColor; GloveSkinTitle.Font = Enum.Font.GothamBold; GloveSkinTitle.TextSize = 12

local GloveScroll = Instance.new("ScrollingFrame", PageGlove); GloveScroll.Size = UDim2.new(0.5, -5, 1, -25); GloveScroll.Position = UDim2.new(0, 0, 0, 25); GloveScroll.BackgroundColor3 = Theme.Panel; GloveScroll.BackgroundTransparency = PanelTransparency; GloveScroll.BorderSizePixel = 0; GloveScroll.ScrollBarThickness = 2; GloveScroll.ScrollBarImageColor3 = Theme.MainColor
local GloveLayout = Instance.new("UIListLayout", GloveScroll); GloveLayout.Padding = UDim.new(0, 4)
local GloveSkinScroll = Instance.new("ScrollingFrame", PageGlove); GloveSkinScroll.Size = UDim2.new(0.5, -5, 1, -25); GloveSkinScroll.Position = UDim2.new(0.5, 5, 0, 25); GloveSkinScroll.BackgroundColor3 = Theme.Panel; GloveSkinScroll.BackgroundTransparency = PanelTransparency; GloveSkinScroll.BorderSizePixel = 0; GloveSkinScroll.ScrollBarThickness = 2; GloveSkinScroll.ScrollBarImageColor3 = Theme.MainColor
local GloveSkinLayout = Instance.new("UIListLayout", GloveSkinScroll); GloveSkinLayout.Padding = UDim.new(0, 4)

local function CreateGloveButton(text, parentScroll, isSkin)
    local btn = Instance.new("TextButton", parentScroll)
    btn.Size = UDim2.new(1, 0, 0, 25); btn.BackgroundColor3 = Theme.Background; btn.BackgroundTransparency = PanelTransparency; btn.TextColor3 = Theme.Text; btn.Text = text; btn.Font = Enum.Font.Gotham; btn.TextSize = 12; btn.BorderSizePixel = 0; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        if not isSkin then
            TargetGlove = text; UpdateSkins(TargetGlove, true); GloveSkinTitle.Text = "SKINS ("..(TargetSkinGlove ~= "" and TargetSkinGlove or "None")..")"
            for _, child in pairs(GloveSkinScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _, skin in ipairs(FoundGloveSkins) do CreateGloveButton(skin, GloveSkinScroll, true) end
            GloveSkinScroll.CanvasSize = UDim2.new(0, 0, 0, GloveSkinLayout.AbsoluteContentSize.Y + 10)
            SendNotification("Glove Equipped", TargetGlove .. " will be applied next round.", 3)
        else 
            TargetSkinGlove = text; GloveSkinTitle.Text = "SKINS ("..TargetSkinGlove..")"
            local oldText = btn.Text
            btn.Text = "Applied!"
            btn.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.delay(1.5, function() if btn and btn.Parent then btn.Text = oldText; btn.TextColor3 = Theme.Text end end)
        end
    end)
end

for _, knife in ipairs(FoundKnives) do CreateKnifeButton(knife, KnifeScroll, false) end
KnifeScroll.CanvasSize = UDim2.new(0, 0, 0, KnifeLayout.AbsoluteContentSize.Y + 10)
for _, skin in ipairs(FoundSkins) do CreateKnifeButton(skin, SkinScroll, true) end
SkinScroll.CanvasSize = UDim2.new(0, 0, 0, SkinLayout.AbsoluteContentSize.Y + 10)

for _, glove in ipairs(FoundGloves) do CreateGloveButton(glove, GloveScroll, false) end
GloveScroll.CanvasSize = UDim2.new(0, 0, 0, GloveLayout.AbsoluteContentSize.Y + 10)
for _, skin in ipairs(FoundGloveSkins) do CreateGloveButton(skin, GloveSkinScroll, true) end
GloveSkinScroll.CanvasSize = UDim2.new(0, 0, 0, GloveSkinLayout.AbsoluteContentSize.Y + 10)

local oldGetCameraModel = SkinsModule.GetCameraModel
SkinsModule.GetCameraModel = function(weapon, skin, ...)
    for _, knife in ipairs(Checkifbaseknife) do if weapon == knife then weapon = TargetKnife; skin = TargetSkin break end end
    return oldGetCameraModel(weapon, skin, ...)
end

local oldGetCharacterModel = SkinsModule.GetCharacterModel
SkinsModule.GetCharacterModel = function(weapon, skin, ...)
    for _, knife in ipairs(Checkifbaseknife) do if weapon == knife then weapon = TargetKnife; skin = TargetSkin break end end
    return oldGetCharacterModel(weapon, skin, ...)
end

local oldViewmodelNew = Viewmodel.new
Viewmodel.new = function(config, weapon, skin, ...)
    for _, knife in ipairs(Checkifbaseknife) do if weapon == knife then weapon = TargetKnife; skin = TargetSkin break end end
    return oldViewmodelNew(config, weapon, skin, ...)
end

local oldGetGloves = SkinsModule.GetGloves
if oldGetGloves then
    SkinsModule.GetGloves = function(glove, skin, ...)
        return oldGetGloves(TargetGlove, TargetSkinGlove, ...)
    end
end

-- ==========================================================
-- PURE AND FULLY APPROVED ESP SYSTEM (OBFUSCATION OPTIMIZED)
-- ==========================================================
local WallcastParams = RaycastParams.new()
WallcastParams.CollisionGroup = "Bullet"; WallcastParams.FilterType = Enum.RaycastFilterType.Exclude
local ExitParams = RaycastParams.new()
ExitParams.CollisionGroup = "Bullet"; ExitParams.FilterType = Enum.RaycastFilterType.Include

--[[moonveil:no-virtualize]]
local function IsTeammate(model)
    if not Config.TeamCheck then return false end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return false end
    local myTeam = nil
    if charsFolder:FindFirstChild("Terrorists") and charsFolder.Terrorists:FindFirstChild(LocalPlayer.Name) then myTeam = "Terrorists"
    elseif charsFolder:FindFirstChild("Counter-Terrorists") and charsFolder["Counter-Terrorists"]:FindFirstChild(LocalPlayer.Name) then myTeam = "Counter-Terrorists" end
    if myTeam and model:IsDescendantOf(charsFolder:FindFirstChild(myTeam)) then return true end
    return false
end

--[[moonveil:no-virtualize]]
local function IsVisible(targetPart, forceCheck)
    if forceCheck == nil and not Config.Wallbang then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = {Camera}
    if Workspace:FindFirstChild("Debris") then table.insert(ignoreList, Workspace.Debris) end
    if Workspace:FindFirstChild("RaycastVisualizers") then table.insert(ignoreList, Workspace.RaycastVisualizers) end
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end

    local charsFolder = Workspace:FindFirstChild("Characters")
    if charsFolder then
        for _, folder in pairs(charsFolder:GetChildren()) do
            for _, model in pairs(folder:GetChildren()) do
                if model ~= targetPart.Parent and (IsTeammate(model) or model.Name == LocalPlayer.Name) then
                    table.insert(ignoreList, model)
                end
            end
        end
    end

    local attempts = 0
    while attempts < 15 do
        attempts = attempts + 1
        params.FilterDescendantsInstances = ignoreList
        local result = Workspace:Raycast(origin, direction, params)
        if result then
            if result.Instance:IsDescendantOf(targetPart.Parent) then
                return true
            elseif result.Instance.Transparency >= 0.5 or not result.Instance.CanCollide or result.Instance.Name:lower():match("hitbox") or result.Instance.Name == "Glass" then
                table.insert(ignoreList, result.Instance)
            else
                return false
            end
        else
            return true
        end
    end
    return false
end

--[[moonveil:no-virtualize]]
local function GetAimPoint()
    if isMobile then return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) else return UserInputService:GetMouseLocation() end
end

--[[moonveil:no-virtualize]]
local function GetClosestTarget()
    local closest = nil
    local shortest = Config.AimFOV
    local aimPoint = GetAimPoint()
    
    if not CharFolder then return nil end
    
    for _, folder in pairs(CharFolder:GetChildren()) do 
        for _, model in pairs(folder:GetChildren()) do
            if model.Name ~= LocalPlayer.Name then 
                local head = model:FindFirstChild(Config.TargetPart)
                if not IsTeammate(model) and head then 
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then 
                            local dist = (Vector2.new(pos.X, pos.Y) - aimPoint).Magnitude
                            if dist < shortest then 
                                if Config.AimWallCheck then
                                    if IsVisible(head, true) then 
                                        closest = head
                                        shortest = dist 
                                    end
                                else
                                    closest = head
                                    shortest = dist
                                end
                            end 
                        end 
                    end
                end 
            end 
        end 
    end
    return closest
end

--[[moonveil:no-virtualize]]
local function getTarget(targetFOV)
    local aimPoint = GetAimPoint()
    local best, bestDist = nil, targetFOV
    if not CharFolder then return nil end

    for _, folder in pairs(CharFolder:GetChildren()) do
        for _, model in pairs(folder:GetChildren()) do
            if model:IsA("Model") and model.Name ~= LocalPlayer.Name and not IsTeammate(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local part = model:FindFirstChild(Config.TargetPart)
                
                if hum and hum.Health > 0 and part then
                    if not Config.Wallbang then
                        if not IsVisible(part, true) then continue end
                    end

                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - aimPoint).Magnitude
                        if d < bestDist then bestDist = d; best = { Part = part } end
                    end
                end
            end
        end
    end
    return best
end

--[[moonveil:no-virtualize]]
local function buildhit(origin, dir, targetPart, penetration)
    local targetPos = targetPart.Position
    local maxDist = (targetPos - origin).Magnitude
    local hits = {}; local excluded = { LocalPlayer.Character }; local castPos = origin; local penUsed = 0
    for i = 1, 4 do
        WallcastParams.FilterDescendantsInstances = excluded
        local hit = Workspace:Raycast(castPos, dir * maxDist, WallcastParams)
        if not hit then break end
        if hit.Instance:FindFirstAncestorWhichIsA("Model") and hit.Instance.Parent:FindFirstChildOfClass("Humanoid") then break end
        table.insert(hits, {Instance = hit.Instance, Position = hit.Position, Normal = hit.Normal, Material = hit.Material.Name, Distance = (hit.Position - castPos).Magnitude, Exit = false})
        
        ExitParams.FilterDescendantsInstances = { hit.Instance }
        local exitHit = Workspace:Raycast(hit.Position + dir * 10, -dir * 11, ExitParams)
        if exitHit then
            local thick = (exitHit.Position - hit.Position).Magnitude
            penUsed = penUsed + thick
            if penUsed > penetration then break end
            table.insert(hits, {Instance = exitHit.Instance, Position = exitHit.Position, Normal = exitHit.Normal, Material = hit.Material.Name, Distance = thick, Exit = true})
            castPos = exitHit.Position + dir * 0.01
        else break end
        table.insert(excluded, hit.Instance)
    end
    table.insert(hits, {Instance = targetPart, Position = targetPos, Normal = -dir, Material = "SmoothPlastic", Distance = (targetPos - castPos).Magnitude, Exit = false})
    return hits
end

--[[moonveil:no-virtualize]]
local function getWeaponProps()
    if InventoryController then
        local equipped = nil
        pcall(function() equipped = InventoryController.getCurrentEquipped() end)
        return equipped and equipped.Properties
    end
end

task.spawn(function()
    local ShootRemote
    while not ShootRemote do
        pcall(function() ShootRemote = require(ReplicatedStorage.Database.Security.Remotes).Inventory.ShootWeapon end)
        task.wait(1)
    end
    
    local oldSend
    local LastSilentTime = 0
    local RateLimitTime = 0
    
    --[[moonveil:no-virtualize]]
    local function SafeSend(data, ...)
        local currentTick = tick()
        
        -- RATE LIMIT: Max ~33 bullets/sec (increased from 0.06)
        if currentTick - RateLimitTime < 0.03 then 
            return 
        end
        RateLimitTime = currentTick
        
        local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if Config.SilentEnabled and isShooting and not isXenoOrSolara then
            local success, err = pcall(function()
                if data and data.Bullets then
                    local t = getTarget(Config.FOV)
                    local props = getWeaponProps()
                    if t and props then
                        local range = props.Range or 1000
                        local pen = props.Penetration or 0
                        local aimingOpt = tostring(props.AimingOptions or "")
                        if string.find(aimingOpt, "Scope") and not data.IsSniperScoped then data.IsSniperScoped = true end
                        
                        local allowSilent = false
                        if currentTick - LastSilentTime >= 0.05 then 
                            allowSilent = true
                            LastSilentTime = currentTick
                        end

                        if allowSilent then
                            for _, bullet in pairs(data.Bullets) do
                                local hitPart = t.Part
                                if math.random(1, 3) == 1 and t.Part.Parent:FindFirstChild("UpperTorso") then
                                    hitPart = t.Part.Parent.UpperTorso
                                end

                                local offset = Vector3.new(
                                    math.random(-15, 15) / 100,
                                    math.random(-15, 15) / 100,
                                    math.random(-15, 15) / 100
                                )
                                local targetPos = hitPart.Position + offset
                                local toTarget = targetPos - bullet.Origin
                                local distance = toTarget.Magnitude
                                
                                if distance <= range then
                                    bullet.Direction = toTarget.Unit
                                    if Config.Wallbang and pen > 0 then 
                                        bullet.Hits = buildhit(bullet.Origin, bullet.Direction, hitPart, pen)
                                    else 
                                        bullet.Hits = { { 
                                            Instance = hitPart, 
                                            Position = targetPos, 
                                            Normal = -bullet.Direction, 
                                            Material = "SmoothPlastic", 
                                            Distance = distance, 
                                            Exit = false 
                                        } } 
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            if not success then WyvernErrorKick("Silent Aim Error: " .. tostring(err)) end
        end
        return oldSend(data, ...)
    end

    if type(ShootRemote) == "table" then
        if setreadonly then setreadonly(ShootRemote, false) end
        oldSend = ShootRemote.Send
        ShootRemote.Send = SafeSend
        if setreadonly then setreadonly(ShootRemote, true) end
    else
        oldSend = ShootRemote.Send
        ShootRemote.Send = SafeSend
    end
end)

--[[moonveil:no-virtualize]]
local function UpdateHitbox() 
    if not CharFolder then return end 
    
    if Config.HitboxExpander then
        local size = Config.HitboxSize
        local trans = Config.HitboxTransparency / 100
        local targetSize = Vector3.new(size, size, size)
        
        for _, folder in pairs(CharFolder:GetChildren()) do 
            for _, model in pairs(folder:GetChildren()) do 
                if model.Name ~= LocalPlayer.Name and not IsTeammate(model) then 
                    local head = model:FindFirstChild("Head") 
                    -- SPAM PREVENTER: Only change if size is different (Prevents Janitor/Observer crash)
                    if head and head.Size ~= targetSize then 
                        head.Size = targetSize
                        head.Transparency = trans
                        head.CanCollide = false
                        head.Material = Enum.Material.Neon
                        head.Color = Theme.MainColor 
                    end 
                end 
            end 
        end
    end 
end

local ESP_Drawings = {}

local OldESPGui = SafeGetHui():FindFirstChild("Wyvern_ESP")
if OldESPGui then OldESPGui:Destroy() end

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "Wyvern_ESP"
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = SafeGetHui()

local function CreateGuiBox()
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.BorderSizePixel = 0
    local stroke = Instance.new("UIStroke", frame)
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    frame.Parent = ESPGui
    return {Frame = frame, Stroke = stroke}
end

local function CreateGuiLine()
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0
    frame.Visible = false
    frame.Parent = ESPGui
    return frame
end

local function CreateGuiText()
    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 13
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0
    txt.Visible = false
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.Parent = ESPGui
    return txt
end

--[[moonveil:no-virtualize]]
local function DrawLineGui(lineInstance, from, to, color, thickness)
    if not from or not to then lineInstance.Visible = false return end
    local dist = (to - from).Magnitude
    lineInstance.Size = UDim2.new(0, dist, 0, thickness or 1.5)
    lineInstance.Position = UDim2.new(0, (from.X + to.X) / 2, 0, (from.Y + to.Y) / 2)
    lineInstance.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
    lineInstance.BackgroundColor3 = color or Color3.new(1, 1, 1)
    lineInstance.Visible = true
end

--[[moonveil:no-virtualize]]
local function RemoveDrawing(model)
    if ESP_Drawings[model] then
        local d = ESP_Drawings[model]
        if d.BoxLines then for _, l in ipairs(d.BoxLines) do l:Destroy() end end
        if d.Box then d.Box.Frame:Destroy() end
        if d.BoxOutline then d.BoxOutline.Frame:Destroy() end
        if d.Name then d.Name:Destroy() end
        if d.Distance then d.Distance:Destroy() end
        if d.HPBg then d.HPBg:Destroy() end
        if d.HPFill then d.HPFill:Destroy() end
        if d.Tracer then d.Tracer:Destroy() end
        if d.ViewTracer then d.ViewTracer:Destroy() end
        if d.SkeletonLines then for _, line in pairs(d.SkeletonLines) do line:Destroy() end end
        ESP_Drawings[model] = nil
    end
end

--[[moonveil:no-virtualize]]
local function GetBonePos(char, partName)
    local part = char:FindFirstChild(partName) or char:FindFirstChild(partName:gsub("Upper", ""):gsub("Lower", ""))
    if part then
        local pos, vis = Camera:WorldToViewportPoint(part.Position)
        if vis then return Vector2.new(pos.X, pos.Y) end
    end
    return nil
end

--[[moonveil:no-virtualize]]
local function UpdateESP()
    if not CharFolder then return end

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0 then
        for model, _ in pairs(ESP_Drawings) do RemoveDrawing(model) end
        for _, folder in pairs(CharFolder:GetChildren()) do
            for _, model in pairs(folder:GetChildren()) do
                local hl = model:FindFirstChild("WyvernChams")
                if hl then hl:Destroy() end
            end
        end
        return
    end

    if not Config.ESP and not Config.Chams and not Config.Skeleton and not Config.ViewTracers then
        for model, _ in pairs(ESP_Drawings) do RemoveDrawing(model) end
        for _, folder in pairs(CharFolder:GetChildren()) do
            for _, model in pairs(folder:GetChildren()) do
                local hl = model:FindFirstChild("WyvernChams")
                if hl then hl:Destroy() end
            end
        end
        return
    end

    local currentModels = {}
    local WTVP = Camera.WorldToViewportPoint

    for _, folder in pairs(CharFolder:GetChildren()) do
        for _, model in pairs(folder:GetChildren()) do
            if model:IsA("Model") and model.Name ~= LocalPlayer.Name and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Head") then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local isFriendly = IsTeammate(model)
                    if isFriendly and not Config.ShowTeam then
                        if ESP_Drawings[model] then RemoveDrawing(model) end
                        local hl = model:FindFirstChild("WyvernChams")
                        if hl then hl:Destroy() end
                        continue
                    end

                    local isVisible = false
                    if not isFriendly and model:FindFirstChild("Head") then
                        isVisible = IsVisible(model.Head, true)
                    end

                    local drawColor = Color3.fromRGB(255, 50, 50)
                    if isFriendly then
                        drawColor = Color3.fromRGB(0, 255, 255)
                    elseif isVisible then
                        drawColor = Color3.fromRGB(0, 255, 0)
                    else
                        if Config.TeamColors then
                            if folder.Name == "Terrorists" then
                                drawColor = Color3.fromRGB(255, 130, 0)
                            elseif folder.Name == "Counter-Terrorists" then
                                drawColor = Color3.fromRGB(0, 140, 255)
                            end
                        end
                    end

                    if Config.Chams then
                        local hl = model:FindFirstChild("WyvernChams")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "WyvernChams"
                            hl.Parent = model
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        hl.FillColor = drawColor
                        hl.OutlineColor = drawColor
                    else
                        local hl = model:FindFirstChild("WyvernChams")
                        if hl then hl:Destroy() end
                    end

                    if Config.ESP or Config.Skeleton or Config.ViewTracers then
                        currentModels[model] = true
                        if not ESP_Drawings[model] then
                            ESP_Drawings[model] = {
                                BoxLines = {},
                                Box = CreateGuiBox(),
                                BoxOutline = CreateGuiBox(),
                                Name = CreateGuiText(),
                                Distance = CreateGuiText(),
                                HPBg = CreateGuiLine(),
                                HPFill = CreateGuiLine(),
                                Tracer = CreateGuiLine(),
                                ViewTracer = CreateGuiLine(),
                                SkeletonLines = {}
                            }
                            
                            for i = 1, 12 do table.insert(ESP_Drawings[model].BoxLines, CreateGuiLine()) end
                            for i = 1, 14 do table.insert(ESP_Drawings[model].SkeletonLines, CreateGuiLine()) end

                            local d = ESP_Drawings[model]
                            d.BoxOutline.Stroke.Thickness = 3
                            d.BoxOutline.Stroke.Color = Color3.new(0, 0, 0)
                            d.Box.Stroke.Thickness = 1.5
                        end

                        local d = ESP_Drawings[model]
                        local hrp = model.HumanoidRootPart
                        local head = model.Head
                        local vector, onScreen = WTVP(Camera, hrp.Position)

                        local headVector = WTVP(Camera, head.Position + Vector3.new(0, 0.5, 0))
                        local boxHeight = math.abs((vector.Y - headVector.Y) * 2.3)
                        local boxWidth = boxHeight / 1.5
                        local boxPos = Vector2.new(vector.X - boxWidth / 2, vector.Y - boxHeight / 2)

                        if onScreen then
                            if Config.ESP then
                                if Config.Box then
                                    if Config.Box3D then
                                        d.Box.Frame.Visible = false
                                        d.BoxOutline.Frame.Visible = false
                                        local Size = Vector3.new(2.5, 4.5, 2.5); local CF = hrp.CFrame
                                        local corners = { CF * CFrame.new(Size.X, Size.Y, Size.Z), CF * CFrame.new(Size.X, -Size.Y, Size.Z), CF * CFrame.new(-Size.X, -Size.Y, Size.Z), CF * CFrame.new(-Size.X, Size.Y, Size.Z), CF * CFrame.new(Size.X, Size.Y, -Size.Z), CF * CFrame.new(Size.X, -Size.Y, -Size.Z), CF * CFrame.new(-Size.X, -Size.Y, -Size.Z), CF * CFrame.new(-Size.X, Size.Y, -Size.Z) }
                                        local sCorners = {}
                                        for _, c in ipairs(corners) do
                                            local p, v = WTVP(Camera, c.Position)
                                            if v then table.insert(sCorners, Vector2.new(p.X, p.Y)) else table.insert(sCorners, nil) end
                                        end
                                        local lines = { {1,2}, {2,3}, {3,4}, {4,1}, {5,6}, {6,7}, {7,8}, {8,5}, {1,5}, {2,6}, {3,7}, {4,8} }
                                        for i, connection in ipairs(lines) do
                                            local line = d.BoxLines[i]
                                            local p1, p2 = sCorners[connection[1]], sCorners[connection[2]]
                                            if p1 and p2 then
                                                DrawLineGui(line, p1, p2, drawColor, 1.5)
                                            else
                                                line.Visible = false
                                            end
                                        end
                                    else
                                        for _, l in ipairs(d.BoxLines) do l.Visible = false end
                                        
                                        d.BoxOutline.Frame.Visible = true
                                        d.BoxOutline.Frame.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                                        d.BoxOutline.Frame.Position = UDim2.new(0, boxPos.X, 0, boxPos.Y)
                                        
                                        d.Box.Frame.Visible = true
                                        d.Box.Frame.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                                        d.Box.Frame.Position = UDim2.new(0, boxPos.X, 0, boxPos.Y)
                                        d.Box.Stroke.Color = drawColor
                                    end
                                else
                                    d.Box.Frame.Visible = false
                                    d.BoxOutline.Frame.Visible = false
                                    for _, l in ipairs(d.BoxLines) do l.Visible = false end
                                end

                                if Config.Name then
                                    d.Name.Visible = true
                                    d.Name.Text = model.Name
                                    d.Name.Position = UDim2.new(0, boxPos.X + (boxWidth / 2), 0, boxPos.Y - 10)
                                    d.Name.TextColor3 = drawColor
                                else
                                    d.Name.Visible = false
                                end

                                if Config.Distance then
                                    d.Distance.Visible = true
                                    local dist = 0
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                                    end
                                    d.Distance.Text = "[" .. dist .. "m]"
                                    d.Distance.Position = UDim2.new(0, boxPos.X + (boxWidth / 2), 0, boxPos.Y + boxHeight + 10)
                                    d.Distance.TextColor3 = Color3.new(1, 1, 1)
                                else
                                    d.Distance.Visible = false
                                end

                                if Config.HPBar then
                                    d.HPBg.Visible = true
                                    d.HPFill.Visible = true
                                    
                                    local hpPercent = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                    local barHeight = math.max(1, boxHeight * hpPercent)
                                    
                                    DrawLineGui(d.HPBg, Vector2.new(boxPos.X - 5, boxPos.Y - 1), Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight + 1), Color3.new(0, 0, 0), 3)
                                    DrawLineGui(d.HPFill, Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight), Vector2.new(boxPos.X - 5, boxPos.Y + boxHeight - barHeight), Color3.new(1 - hpPercent, hpPercent, 0), 1.5)
                                else
                                    d.HPBg.Visible = false
                                    d.HPFill.Visible = false
                                end

                                if Config.Tracers then
                                    local startPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    local endPos = Vector2.new(vector.X, vector.Y + (boxHeight / 2))
                                    DrawLineGui(d.Tracer, startPos, endPos, drawColor, 1.5)
                                else
                                    d.Tracer.Visible = false
                                end
                            else
                                d.Box.Frame.Visible = false
                                d.BoxOutline.Frame.Visible = false
                                d.Name.Visible = false
                                d.Distance.Visible = false
                                d.HPBg.Visible = false
                                d.HPFill.Visible = false
                                d.Tracer.Visible = false
                                for _, l in ipairs(d.BoxLines) do l.Visible = false end
                            end

                            if Config.Skeleton then
                                local joints = {
                                    {GetBonePos(model, "Head"), GetBonePos(model, "UpperTorso")},
                                    {GetBonePos(model, "UpperTorso"), GetBonePos(model, "LowerTorso")},
                                    {GetBonePos(model, "UpperTorso"), GetBonePos(model, "LeftUpperArm")},
                                    {GetBonePos(model, "LeftUpperArm"), GetBonePos(model, "LeftLowerArm")},
                                    {GetBonePos(model, "LeftLowerArm"), GetBonePos(model, "LeftHand")},
                                    {GetBonePos(model, "UpperTorso"), GetBonePos(model, "RightUpperArm")},
                                    {GetBonePos(model, "RightUpperArm"), GetBonePos(model, "RightLowerArm")},
                                    {GetBonePos(model, "RightLowerArm"), GetBonePos(model, "RightHand")},
                                    {GetBonePos(model, "LowerTorso"), GetBonePos(model, "LeftUpperLeg")},
                                    {GetBonePos(model, "LeftUpperLeg"), GetBonePos(model, "LeftLowerLeg")},
                                    {GetBonePos(model, "LeftLowerLeg"), GetBonePos(model, "LeftFoot")},
                                    {GetBonePos(model, "LowerTorso"), GetBonePos(model, "RightUpperLeg")},
                                    {GetBonePos(model, "RightUpperLeg"), GetBonePos(model, "RightLowerLeg")},
                                    {GetBonePos(model, "RightLowerLeg"), GetBonePos(model, "RightFoot")},
                                }
                                for i, line in ipairs(d.SkeletonLines) do
                                    local joint = joints[i]
                                    if joint and joint[1] and joint[2] then
                                        DrawLineGui(line, joint[1], joint[2], drawColor, 1.5)
                                    else
                                        line.Visible = false
                                    end
                                end
                            else
                                for _, line in ipairs(d.SkeletonLines) do line.Visible = false end
                            end

                            if Config.ViewTracers then
                                local headPos = head.Position
                                local lookVec = head.CFrame.LookVector * Config.ViewTracerLength
                                local endPos = headPos + lookVec
                                local p1, v1 = WTVP(Camera, headPos)
                                local p2, v2 = WTVP(Camera, endPos)
                                if v1 or v2 then
                                    DrawLineGui(d.ViewTracer, Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y), Color3.fromRGB(255, 50, 50), 1.5)
                                else
                                    d.ViewTracer.Visible = false
                                end
                            else
                                d.ViewTracer.Visible = false
                            end

                        else
                            d.Box.Frame.Visible = false
                            d.BoxOutline.Frame.Visible = false
                            d.Name.Visible = false
                            d.Distance.Visible = false
                            d.HPBg.Visible = false
                            d.HPFill.Visible = false
                            d.Tracer.Visible = false
                            d.ViewTracer.Visible = false
                            for _, l in ipairs(d.BoxLines) do l.Visible = false end
                            for _, l in ipairs(d.SkeletonLines) do l.Visible = false end
                        end
                    else
                        if ESP_Drawings[model] then RemoveDrawing(model) end
                    end
                end
            end
        end
    end

    for model, _ in pairs(ESP_Drawings) do
        if not currentModels[model] then RemoveDrawing(model) end
    end
end

--[[moonveil:no-virtualize]]
RunService.RenderStepped:Connect(function()
    local success, err = pcall(function()
        local char = LocalPlayer.Character
        if char then
            if Config.TPS then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.LocalTransparencyModifier = 0.5 end
                end
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, Config.TPSDistance)
                
                for _, child in pairs(Camera:GetChildren()) do
                    if child:IsA("Model") then
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.LocalTransparencyModifier = 1
                            end
                        end
                    end
                end
            else
                LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                
                for _, child in pairs(Camera:GetChildren()) do
                    if child:IsA("Model") then
                        for _, part in pairs(child:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.LocalTransparencyModifier = 0
                            end
                        end
                    end
                end
            end
            
            if char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if Config.MovementEnabled then
                    hum.WalkSpeed = Config.SpeedValue
                    hum.UseJumpPower = true
                    hum.JumpPower = Config.JumpPower
                end
                if Config.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        hum.Jump = true
                    end
                end
            end
        end
        
        -- SkyChanger artik RenderStepped'de calismiyor
        -- Sadece slider/toggle degisince bir kez set edilir (anti-cheat safe)
        
        if Config.AntiFlash then 
            Lighting.ExposureCompensation = 0
            for _, v in pairs(Lighting:GetChildren()) do 
                if v:IsA("ColorCorrectionEffect") and (v.Name:lower():find("flash") or v.TintColor == Color3.new(1,1,1)) then 
                    v.Enabled = false 
                end 
            end 
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            if pGui then 
                for _, gui in pairs(pGui:GetChildren()) do 
                    if gui.Name:lower():find("flash") or gui.Name:lower():find("blind") then 
                        gui:Destroy() 
                    end 
                end 
            end 
        end

        if Config.AntiSmoke then
            local Debris = Workspace:FindFirstChild("Debris")
            if Debris then
                for _, folder in pairs(Debris:GetChildren()) do
                    if folder:IsA("Folder") and folder.Name:find("VoxelSmoke") then
                        for _, obj in pairs(folder:GetChildren()) do
                            if obj:IsA("BasePart") then
                                -- LocalTransparencyModifier: client-side override,
                                -- server-side Transparency'yi etkilemez, oyun yakalamaz
                                obj.LocalTransparencyModifier = 1
                                obj.CastShadow = false
                                -- Tum particle/efekt instancelarini sil
                                for _, effect in pairs(obj:GetDescendants()) do
                                    if effect:IsA("ParticleEmitter") or effect:IsA("Smoke")
                                    or effect:IsA("Fire") or effect:IsA("Sparkles")
                                    or effect:IsA("Trail") or effect:IsA("Beam") then
                                        pcall(function() effect.Enabled = false end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        UpdateESP()
        UpdateHitbox()
        local aimPoint = GetAimPoint()

        if SILENT_FOV then
            local mouseLoc = UserInputService:GetMouseLocation()
            SILENT_FOV.Position = UDim2.fromOffset(mouseLoc.X, mouseLoc.Y)
            SILENT_FOV.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
            if Config.SilentEnabled and Config.ShowFOV then
                SILENT_FOV.Visible = true
                SILENT_FOVStroke.Color = getTarget(Config.FOV) and Color3.fromRGB(255, 50, 50) or Theme.MainColor
            else
                SILENT_FOV.Visible = false
            end
        end

        if AIMLOCK_FOV then
            AIMLOCK_FOV.Position = UDim2.fromOffset(aimPoint.X, aimPoint.Y)
            AIMLOCK_FOV.Size = UDim2.fromOffset(Config.AimFOV * 2, Config.AimFOV * 2)
            if Config.Aimlock then 
                AIMLOCK_FOV.Visible = true
                AIMLOCK_FOVStroke.Color = LockedTarget and Color3.fromRGB(0, 255, 100) or Theme.TextDim
            else 
                AIMLOCK_FOV.Visible = false 
            end
        end

        if Config.Aimlock then
            local isAiming = false
            if Config.AimKey.EnumType == Enum.UserInputType then isAiming = UserInputService:IsMouseButtonPressed(Config.AimKey) else isAiming = UserInputService:IsKeyDown(Config.AimKey) end
            
            if isAiming then
                if not LockedTarget then LockedTarget = GetClosestTarget() end
                
                if LockedTarget and LockedTarget.Parent and LockedTarget:IsDescendantOf(Workspace) then 
                    local pos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
                    if onScreen then
                        local xDiff = (pos.X - aimPoint.X)
                        local yDiff = (pos.Y - aimPoint.Y)
                        local moveX = xDiff / Config.AimSmoothness
                        local moveY = yDiff / Config.AimSmoothness
                        if mousemoverel then mousemoverel(moveX, moveY) end
                    end
                else 
                    LockedTarget = nil 
                end
            else 
                LockedTarget = nil 
            end
        else 
            LockedTarget = nil 
        end
    end)
    
    if not success then WyvernErrorKick("RenderStepped Loop Error: " .. tostring(err)) end
end)