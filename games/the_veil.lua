--[[
    =====================================================================
    NW HUB & KYOKA UI · EXECUTOR COMPATIBILITY GUARD (ENGLISH)
    =====================================================================
    Blocks execution on unsupported executors (Solara, Xeno, Celery...)
    Displays a clean in-game warning notification and aborts Hub loading
    to prevent false bug reports on Discord.
    =====================================================================
]]

local function CheckExecutorCompatibility()
    local function resolveExecutorName()
        local name = "Unknown"
        if type(identifyexecutor) == "function" then
            local ok, n = pcall(identifyexecutor)
            if ok and type(n) == "string" and n ~= "" then return n end
        end
        if type(getexecutorname) == "function" then
            local ok, n = pcall(getexecutorname)
            if ok and type(n) == "string" and n ~= "" then return n end
        end
        return name
    end

    local execName = resolveExecutorName()
    local lower = execName:lower()

    -- 1. Explicitly blacklisted executors (Level 3 / Incomplete UNC)
    local blacklisted = {
        "solara", "xeno", "celery", "jjsploit", "vega x", "zorara", "incognito", "shadow"
    }
    local isBlacklisted = false
    for _, bad in ipairs(blacklisted) do
        if lower:find(bad) then
            isBlacklisted = true
            break
        end
    end

    -- 2. Essential Level 7/8 UNC capabilities
    local hasFiresignal = (type(firesignal) == "function")
    local hasHookMeta   = (type(hookmetamethod) == "function")
    local hasHookFunc   = (type(hookfunction) == "function")
    local hasRawMeta   = (type(getrawmetatable) == "function")

    local isSupported = not isBlacklisted and (hasFiresignal or hasHookMeta or hasHookFunc or hasRawMeta)

    if not isSupported then
        -- Developer Console Log (F9)
        warn("=====================================================================")
        warn(string.format("[NW Hub Security] UNSUPPORTED EXECUTOR DETECTED: '%s'", execName))
        warn("This script requires an executor with full UNC support (Level 7/8).")
        warn("The Hub has been blocked to prevent broken functions.")
        warn("THE SCRIPT HAS ZERO BUGS. Do not open a support ticket on Discord.")
        warn("Recommended supported executors:")
        warn("  - PC: Wave, Synapse Z, Madium, Real, Swift, Volt, MacSploit")
        warn("  - Mobile / Emulator: Delta, Codex, Hydrogen, Arceus X")
        warn("=====================================================================")

        -- Roblox Native Notification
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⚠️ Unsupported Executor!",
                Text = string.format("%s is not supported. Switch to Madium, Real, Wave, Delta, etc.", execName),
                Duration = 12
            })
        end)

        -- Clean Modern In-Game Warning Modal (Kyoka / NW Hub Theme)
        pcall(function()
            local TweenService = game:GetService("TweenService")
            local CoreGui = game:GetService("CoreGui")
            local Players = game:GetService("Players")
            local lp = Players.LocalPlayer

            local parentGui = nil
            if typeof(gethui) == "function" then
                pcall(function() parentGui = gethui() end)
            end
            if not parentGui then
                pcall(function() parentGui = CoreGui end)
            end
            if not parentGui and lp then
                parentGui = lp:FindFirstChild("PlayerGui")
            end
            if not parentGui then return end

            -- Cleanup previous popup if any
            local old = parentGui:FindFirstChild("NWHub_UnsupportedPopup")
            if old then pcall(function() old:Destroy() end) end

            local screen = Instance.new("ScreenGui")
            screen.Name = "NWHub_UnsupportedPopup"
            screen.ResetOnSpawn = false
            screen.DisplayOrder = 999999
            screen.IgnoreGuiInset = true

            local bg = Instance.new("Frame")
            bg.Name = "Backdrop"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bg.BackgroundTransparency = 0.45
            bg.BorderSizePixel = 0
            bg.Parent = screen

            local modal = Instance.new("Frame")
            modal.Name = "Modal"
            modal.AnchorPoint = Vector2.new(0.5, 0.5)
            modal.Position = UDim2.new(0.5, 0, 0.5, 0)
            modal.Size = UDim2.new(0, 480, 0, 360)
            modal.BackgroundColor3 = Color3.fromRGB(13, 11, 20)
            modal.BorderSizePixel = 0
            modal.ClipsDescendants = true
            modal.Parent = screen

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = modal

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 68, 85)
            stroke.Thickness = 1.5
            stroke.Transparency = 0.2
            stroke.Parent = modal

            -- Header Bar
            local header = Instance.new("Frame")
            header.Name = "Header"
            header.Size = UDim2.new(1, 0, 0, 44)
            header.BackgroundColor3 = Color3.fromRGB(20, 16, 32)
            header.BorderSizePixel = 0
            header.Parent = modal

            local headerCorner = Instance.new("UICorner")
            headerCorner.CornerRadius = UDim.new(0, 10)
            headerCorner.Parent = header

            local headerTitle = Instance.new("TextLabel")
            headerTitle.Name = "Title"
            headerTitle.Size = UDim2.new(1, -50, 1, 0)
            headerTitle.Position = UDim2.new(0, 16, 0, 0)
            headerTitle.BackgroundTransparency = 1
            headerTitle.Font = Enum.Font.GothamBold
            headerTitle.Text = "⚠️  UNSUPPORTED EXECUTOR"
            headerTitle.TextColor3 = Color3.fromRGB(255, 75, 90)
            headerTitle.TextSize = 14
            headerTitle.TextXAlignment = Enum.TextXAlignment.Left
            headerTitle.Parent = header

            -- Close cross top-right
            local closeX = Instance.new("TextButton")
            closeX.Name = "CloseX"
            closeX.Size = UDim2.new(0, 30, 0, 30)
            closeX.Position = UDim2.new(1, -38, 0, 7)
            closeX.BackgroundColor3 = Color3.fromRGB(30, 24, 46)
            closeX.BorderSizePixel = 0
            closeX.Font = Enum.Font.GothamBold
            closeX.Text = "✕"
            closeX.TextColor3 = Color3.fromRGB(200, 200, 220)
            closeX.TextSize = 13
            closeX.Parent = header

            local closeXCorner = Instance.new("UICorner")
            closeXCorner.CornerRadius = UDim.new(0, 6)
            closeXCorner.Parent = closeX

            -- Detected Executor Badge
            local badge = Instance.new("Frame")
            badge.Name = "Badge"
            badge.Size = UDim2.new(1, -32, 0, 32)
            badge.Position = UDim2.new(0, 16, 0, 54)
            badge.BackgroundColor3 = Color3.fromRGB(26, 18, 30)
            badge.BorderSizePixel = 0
            badge.Parent = modal

            local badgeCorner = Instance.new("UICorner")
            badgeCorner.CornerRadius = UDim.new(0, 6)
            badgeCorner.Parent = badge

            local badgeStroke = Instance.new("UIStroke")
            badgeStroke.Color = Color3.fromRGB(255, 68, 85)
            badgeStroke.Thickness = 1
            badgeStroke.Transparency = 0.5
            badgeStroke.Parent = badge

            local badgeText = Instance.new("TextLabel")
            badgeText.Size = UDim2.new(1, -16, 1, 0)
            badgeText.Position = UDim2.new(0, 10, 0, 0)
            badgeText.BackgroundTransparency = 1
            badgeText.Font = Enum.Font.GothamMedium
            badgeText.Text = string.format("Detected Executor: %s  (Incompatible)", execName)
            badgeText.TextColor3 = Color3.fromRGB(255, 110, 125)
            badgeText.TextSize = 12
            badgeText.TextXAlignment = Enum.TextXAlignment.Left
            badgeText.Parent = badge

            -- Main Explanatory Content in English
            local content = Instance.new("TextLabel")
            content.Name = "Body"
            content.Size = UDim2.new(1, -32, 0, 210)
            content.Position = UDim2.new(0, 16, 0, 94)
            content.BackgroundTransparency = 1
            content.Font = Enum.Font.Gotham
            content.TextSize = 12
            content.TextColor3 = Color3.fromRGB(220, 215, 235)
            content.TextXAlignment = Enum.TextXAlignment.Left
            content.TextYAlignment = Enum.TextYAlignment.Top
            content.TextWrapped = true
            content.LineHeight = 1.3
            content.Text = 
                "Your current executor lacks the advanced Luau / UNC features required to run this script (firesignal, hookmetamethod, game module access).\n\n" ..
                "🛑  The Hub has been BLOCKED to prevent broken features.\n" ..
                "💬  The script has ZERO bugs. Do NOT open a ticket or complain on Discord!\n\n" ..
                "✅  Recommended Supported Executors:\n" ..
                "     • PC: Madium, Real, Wave, Synapse Z, Swift, MacSploit\n" ..
                "     • Mobile / Emulator: Delta, Codex, Hydrogen, Arceus X\n\n" ..
                "❌  Incompatible Executors: Solara, Xeno, Celery, Vega X, etc."
            content.Parent = modal

            -- Bottom Action Buttons Holder
            local btnHolder = Instance.new("Frame")
            btnHolder.Name = "Buttons"
            btnHolder.Size = UDim2.new(1, -32, 0, 36)
            btnHolder.Position = UDim2.new(0, 16, 1, -48)
            btnHolder.BackgroundTransparency = 1
            btnHolder.Parent = modal

            -- Button 1: Understood (Close)
            local btnClose = Instance.new("TextButton")
            btnClose.Name = "BtnClose"
            btnClose.Size = UDim2.new(0.48, 0, 1, 0)
            btnClose.Position = UDim2.new(0, 0, 0, 0)
            btnClose.BackgroundColor3 = Color3.fromRGB(124, 108, 255)
            btnClose.BorderSizePixel = 0
            btnClose.Font = Enum.Font.GothamBold
            btnClose.Text = "I Understand"
            btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnClose.TextSize = 12
            btnClose.Parent = btnHolder

            local btnCloseCorner = Instance.new("UICorner")
            btnCloseCorner.CornerRadius = UDim.new(0, 6)
            btnCloseCorner.Parent = btnClose

            -- Button 2: Join Discord
            local btnDiscord = Instance.new("TextButton")
            btnDiscord.Name = "BtnDiscord"
            btnDiscord.Size = UDim2.new(0.48, 0, 1, 0)
            btnDiscord.Position = UDim2.new(0.52, 0, 0, 0)
            btnDiscord.BackgroundColor3 = Color3.fromRGB(28, 24, 42)
            btnDiscord.BorderSizePixel = 0
            btnDiscord.Font = Enum.Font.GothamMedium
            btnDiscord.Text = "Join Discord"
            btnDiscord.TextColor3 = Color3.fromRGB(200, 195, 225)
            btnDiscord.TextSize = 12
            btnDiscord.Parent = btnHolder

            local btnDiscordCorner = Instance.new("UICorner")
            btnDiscordCorner.CornerRadius = UDim.new(0, 6)
            btnDiscordCorner.Parent = btnDiscord

            local btnDiscordStroke = Instance.new("UIStroke")
            btnDiscordStroke.Color = Color3.fromRGB(60, 52, 90)
            btnDiscordStroke.Thickness = 1
            btnDiscordStroke.Parent = btnDiscord

            -- Close Animation
            local function dismiss()
                pcall(function()
                    local t1 = TweenService:Create(modal, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = UDim2.new(0, 480, 0, 0),
                        BackgroundTransparency = 1
                    })
                    local t2 = TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundTransparency = 1
                    })
                    t1:Play()
                    t2:Play()
                    t1.Completed:Connect(function()
                        screen:Destroy()
                    end)
                end)
            end

            btnClose.MouseButton1Click:Connect(dismiss)
            closeX.MouseButton1Click:Connect(dismiss)

            btnDiscord.MouseButton1Click:Connect(function()
                pcall(function()
                    local fullLink = "https://discord.gg/Gp2N788WVh"
                    if type(setclipboard) == "function" then
                        setclipboard(fullLink)
                    elseif type(toclipboard) == "function" then
                        toclipboard(fullLink)
                    end
                    btnDiscord.Text = "Link Copied!"
                    btnDiscord.TextColor3 = Color3.fromRGB(80, 240, 140)
                    task.delay(2, function()
                        pcall(function()
                            btnDiscord.Text = "Join Discord"
                            btnDiscord.TextColor3 = Color3.fromRGB(200, 195, 225)
                        end)
                    end)
                end)
            end)

            -- Animate Opening
            modal.Size = UDim2.new(0, 480, 0, 0)
            modal.BackgroundTransparency = 1
            screen.Parent = parentGui

            TweenService:Create(modal, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 480, 0, 360),
                BackgroundTransparency = 0
            }):Play()
        end)

        return false
    end

    return true
end
if not CheckExecutorCompatibility() then return end

-- ============================================================
--  NW Hub | The Veil — v5.0.1 (FIXED)
--  Dashboard, Farm, ESP, Player, World, Settings
-- ============================================================

-- Ensure game engine is fully loaded before executing
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================
--  CLIENT SECURITY GUARD (ANTI-TAMPER & INTEGRITY)
-- ============================================================
pcall(function()
    if type(hookfunction) == "function" and type(loadstring) == "function" then
        pcall(function()
            if iscclosure and isourclosure then
                if not iscclosure(loadstring) and not isourclosure(loadstring) then
                    return game:GetService("Players").LocalPlayer:Kick("\n[NW Hub Security]\nHook detected.")
                end
            end
        end)
    end
end)

local TAG_ID = "RBX_" .. game:GetService("HttpService"):GenerateGUID(false):gsub("-", ""):sub(1, 10)

local function GetUiContainer()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return game:GetService("CoreGui")
end

-- Clean previous instance
if getgenv().Veil_UnloadFunction then
    pcall(getgenv().Veil_UnloadFunction)
    task.wait(0.1)
end

local function PurgeAllResidues()
    local containers = { GetUiContainer(), game:GetService("CoreGui") }
    for _, cont in ipairs(containers) do
        if cont then
            for _, child in ipairs(cont:GetChildren()) do
                if child:GetAttribute(TAG_ID) or child:GetAttribute("NWHUB_ACTIVE") or child.Name:find("NW Hub") or child.Name:find("Rayfield") or child.Name:find("Sirius") or child.Name:find("Veil_") or child.Name:find("NW_") or child.Name:find("Kyoka") or child.Name:find("Vesper") then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

PurgeAllResidues()
getgenv().Veil_Unloaded = false

local _env = (type(getgenv) == "function" and getgenv()) or _G or {}
local IsFreeTier = (_env.__NW_IS_FREE == true) or (_env.__NW_TIER == "Free") or (_env.SCRIPT_KEY == "free") or (_env.FORCE_FREE == true) or (_env.FREE == true)
local TierName = IsFreeTier and "FREE" or "PREMIUM"
local TierSubtitle = IsFreeTier and "FREE EDITION" or "PREMIUM EDITION"

-- ============================================================
--  INITIALIZATION & SERVICES
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function ProtectInstance(inst)
    if not inst then return end
    pcall(function()
        if syn and type(syn.protect_gui) == "function" then
            syn.protect_gui(inst)
        elseif type(protectgui) == "function" then
            protectgui(inst)
        elseif type(protect_gui) == "function" then
            protect_gui(inst)
        end
    end)
end

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")
local UserInputService  = game:GetService("UserInputService")
local VIM               = game:GetService("VirtualInputManager")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local VirtualUser       = game:GetService("VirtualUser")

local Camera            = workspace.CurrentCamera

-- DYNAMIC NON-BLOCKING FOLDER ACQUISITION
local Remotes           = ReplicatedStorage:FindFirstChild("Remotes")
local DropsFolder       = workspace:FindFirstChild("Drops")
local MonstersFolder    = workspace:FindFirstChild("Monsters")
local EnemySpawnZonesFolder = workspace:FindFirstChild("EnemySpawnZones")
local NPCFolder         = workspace:FindFirstChild("NPCs")
local TrinketFolder     = workspace:FindFirstChild("TrinketSpawns")
local AreasFolder       = workspace:FindFirstChild("Areas")

-- Background folder resolver so nothing ever yields
task.spawn(function()
    while not getgenv().Veil_Unloaded do
        if not Remotes then Remotes = ReplicatedStorage:FindFirstChild("Remotes") end
        if not DropsFolder then DropsFolder = workspace:FindFirstChild("Drops") end
        if not MonstersFolder then MonstersFolder = workspace:FindFirstChild("Monsters") end
        if not EnemySpawnZonesFolder then EnemySpawnZonesFolder = workspace:FindFirstChild("EnemySpawnZones") end
        if not NPCFolder then NPCFolder = workspace:FindFirstChild("NPCs") end
        if not TrinketFolder then TrinketFolder = workspace:FindFirstChild("TrinketSpawns") end
        if not AreasFolder then AreasFolder = workspace:FindFirstChild("Areas") end
        task.wait(2.0)
    end
end)

local Connections = {}
local PickedUpDrops = {}
local ActiveESP = {}
local LootESP = {}
local NpcESP = {}
local TrinketESP = {}
local ChestESP = {}
local CachedNPCPositions = {}
local CachedActiveMonsters = {}
local SavedWaypoints = {
    ["The Glade"] = "Glade",
    ["Sky's Reach"] = "Sky",
    ["Echohold"] = "Echohold",
    ["Ironkeep"] = "Ironkeep",
    ["The Weeping Crypt"] = "Crypt",
    ["The Scorch Basin"] = "Scorch",
    ["The Shimmering Sanctum"] = "Shimmer",
    ["The Cyst"] = "Cyst",
    ["The Lone Pillar"] = "Lone",
    ["The Unstable Fissure"] = "Fissure",
    ["Aetherglow"] = "Aetherglow",
    ["The Twenty Shelves"] = "TheTwentyShelves",
    ["Camp Zero"] = "CampZero",
    ["The Colosseum"] = "Colosseum",
    ["The Manor"] = "Manor",
    ["The Pale Beyond"] = "Pale"
}
local LastActiveMonstersUpdate = 0
local LastLightingUpdate = 0

local EspScreenGui = Instance.new("ScreenGui")
EspScreenGui.Name = "Core_" .. HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 8)
EspScreenGui:SetAttribute(TAG_ID, true)
EspScreenGui.ResetOnSpawn = false
EspScreenGui.IgnoreGuiInset = true
EspScreenGui.DisplayOrder = 999999
ProtectInstance(EspScreenGui)
pcall(function() EspScreenGui.Parent = GetUiContainer() end)

-- BLACKLIST (Props that aren't lootable items)
local IgnoreDropNames = {
    ["GladeSpawn"] = true,
    ["GladeSpawns"] = true,
    ["Spawn"] = true,
    ["Clearance"] = true
}

-- REMOTES (Safe non-blocking references)
local InteractRemote      = Remotes and (Remotes:FindFirstChild("InteractPromptEvent") or Remotes:FindFirstChild("InteractEvent"))
local QuickDrinkRemote    = Remotes and Remotes:FindFirstChild("QuickDrinkEvent")
local DrinkPotionRemote   = Remotes and Remotes:FindFirstChild("DrinkPotion")
local ConsumableRemote    = Remotes and Remotes:FindFirstChild("ConsumableEvent")
local DashRemote          = Remotes and Remotes:FindFirstChild("DashEvent")
local SuperRunRemote      = Remotes and Remotes:FindFirstChild("SuperRunEvent")
local DoubleJumpRemote    = Remotes and Remotes:FindFirstChild("DoubleJumpEvent")
local TrashItemsRemote    = Remotes and Remotes:FindFirstChild("TrashItemsEvent")
local TeleportWaypointRemote = Remotes and Remotes:FindFirstChild("TeleportToWaypoint")

local OriginalLighting = {
    Brightness    = Lighting.Brightness,
    ClockTime     = Lighting.ClockTime,
    FogEnd        = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient       = Lighting.Ambient
}

-- ================================================
--  MASTER STATE
-- ================================================
local State = {
    MobFarm           = false,
    PlayerFarm        = false,
    VoidOwnedMobs     = false,
    AutoM1            = false,
    AutoCritical      = false,
    AutoM2            = false,
    AutoAbility       = false,
    Instakill         = false,
    AutoEquip         = false,
    NoDashCooldown    = false,
    AutoTrinketTp     = false,
    AutoPickup        = false,
    PickupRadius      = 200,
    AutoSell          = false,
    AutoSellLoop      = false,
    AutoOpenChests    = false,
    CloseDialogue     = false,
    TrinketFarm       = false,
    TrinketSpawnCount = 10,
    SelectedMobTarget = "All Mobs",
    SelectedPlayerTarget = "Nearest",
    SelectedShopNPC   = "Select...",
    FarmPosition      = "Above",
    FarmOffsetX       = 0,
    FarmOffsetY       = 0.4,
    FarmDistance      = 2.0,
    AttackSpeed       = 0.35,
    SelectedWeapon    = "Currently Equipped",
    ShowOwnership     = false,

    CellOfLifeFarm    = false,
    CellOfLifeDistance = 5.0,
    CellOfLifePosition = "Above",

    SilentAim         = false,
    SilentAimFOV      = 180,
    SilentAimTarget   = "Head",
    SilentAimMode     = "Mobs & Players",
    SilentAimShowFOV  = false,
    SilentAimShowLine = false,

    InfWeave          = false,
    InfDash           = false,

    LootFilterEnabled = false,
    LootFilterCommon  = false,
    LootFilterUncommon = false,
    LootFilterRare    = true,
    LootFilterEpic    = true,
    LootFilterLegendary = true,
    LootFilterMythic  = true,

    PlayerESP         = false,
    LocalPlayerESP    = false,
    ESPSinglePlayer   = false,
    ESPNearestOnly    = false,
    MobESP            = false,
    MobESPColor       = Color3.fromRGB(255, 65, 65),
    NpcESP            = false,
    NpcESPColor       = Color3.fromRGB(70, 220, 130),
    DropESP           = false,
    TrinketESP        = false,
    ChestESP          = false,
    ChestESPColor     = Color3.fromRGB(255, 170, 0),
    ItemHighlights    = true,
    ItemHighlightTrans = 0.6,
    ItemProximityHighlight = false,
    RarityColorCommon    = Color3.fromRGB(255, 255, 255),
    RarityColorUncommon  = Color3.fromRGB(50, 220, 50),
    RarityColorRare      = Color3.fromRGB(40, 140, 255),
    RarityColorEpic      = Color3.fromRGB(170, 60, 240),
    RarityColorLegendary = Color3.fromRGB(255, 200, 0),
    RarityColorMythic    = Color3.fromRGB(255, 45, 45),
    ESPBoxes          = true,
    BoxGlow           = true,
    Chams             = true,
    Names             = true,
    Distance          = true,
    HealthBars        = true,
    Weapons           = true,
    Boxes3D           = false,
    MaxESPDistance    = 1000,
    BoxType           = "2D",
    GlowTopTrans      = 0.5,
    GlowBotTrans      = 0.5,
    ChamsFillTrans    = 0.7,
    ChamsTransparency = 0.7,
    ChamsColor        = Color3.fromRGB(255, 255, 255),
    BoxTopColor       = Color3.fromRGB(255, 255, 255),
    BoxBottomColor    = Color3.fromRGB(255, 255, 255),

    Fly               = false,
    FlySpeed          = 50,
    Speedhack         = false,
    SpeedMultiplier   = 2.2,
    SuperRun          = false,
    InfiniteDoubleJump = false,
    InfiniteStamina   = false,
    NoSlow            = false,
    InfiniteJump      = false,
    CustomJumpHeight  = false,
    JumpPowerVal      = 50,
    IgnoreJumpLock    = false,
    Noclip            = false,
    NoAnimations      = false,
    AnimationSpeedVal = 1.0,
    AntiAFK           = true,
    DefenseAssist     = false,
    DefenseMode       = "Auto Parry (F)",
    DefenseDistance   = 18,
    DefenseDelay      = 0.50,
    DefenseHold       = 0.30,
    TPBackOnDeath     = false,
    AntiFling         = false,
    FlingTarget       = "",

    Spectating        = false,
    NoFog             = false,
    NoAtmosphere      = false,
    FullBright        = false,
    BrightnessVal     = 2.0,
    WorldAmbient      = false,
    WorldAmbientColor = Color3.fromRGB(150, 150, 150),
    FreeCam           = false,
    FreeCamSensitivity= 5,
    FreeCamSpeed      = 50,
    ThirdPersonLock   = false,
    CustomFOV         = false,
    FOVOverride       = 70,
    Crosshair         = false,
    CursorRing        = false,
    AntiLag           = false,
    FPSBoost          = false,
    FPSCapVal         = 240,
    TweenTeleport     = false,
    ClickTP           = false,
    NearbyAlert       = false,
    AlertRange        = 100,
    KickNearby        = false,
    KickRange         = 50,
    PlayerAttach      = false,
    AttachTarget      = "",
    AttachRange       = 10,
    AttachDist        = 5,
    AttachHeight      = 5
}

getgenv().Veil_State = State

-- ================================================
--  UD ENGINE & ANTI-CHEAT METATABLE HOOKS
-- ================================================
local function InitializeUdEngine()
    if not hookmetamethod or not newcclosure then return end
    if getgenv().__VEIL_HOOKED then return end
    getgenv().__VEIL_HOOKED = true

    local oldNamecall
    local inHook = false
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if inHook then return oldNamecall(self, ...) end

        local method = getnamecallmethod()
        local caller = checkcaller and checkcaller() or false

        if not caller then
            if method == "Kick" or method == "kick" then
                return
            end

            if method == "FireServer" or method == "InvokeServer" then
                local ok, name = pcall(function() return self.Name end)
                if ok and type(name) == "string" then
                    local lower = name:lower()
                    if lower:find("anticheat") or lower:find("security") or lower:find("ban")
                    or lower:find("telemetry") or lower:find("violation") or lower:find("tamper")
                    or lower:find("honeypot") or lower:find("report") or lower:find("anomaly") then
                        return
                    end
                end
            end
        end

        return oldNamecall(self, ...)
    end))

    print("[The Veil] UD Engine active (Safe Namecall Hook).")
end

pcall(InitializeUdEngine)

local LastAliveCFrame = nil
local FlyTargetPos = nil

-- ================================================
--  ENTITY & WORKSPACE HELPERS
-- ================================================
local function IsPlayerCharacter(model)
    if not model then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

local function IsDummyOrProp(model)
    if not model or not model.Name then return true end
    local n = model.Name:lower()
    if n:find("training dummy") or n:find("dummy") or n == "runner" or n:find("^runner") then
        return true
    end
    local team = model:FindFirstChild("Team")
    if team and tostring(team.Value):lower():find("player") then
        return true
    end
    if n:find("probe") or n:find("clearance") or n:find("boundary") or n:find("camera") or n:find("sound") or n:find("spawner") or n:find("hitbox") then
        return true
    end
    return false
end

local function GetEntityRoot(model)
    if not model then return nil end
    if not model:IsA("Model") then
        if model:IsA("BasePart") then return model end
        return nil
    end
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChildWhichIsA("BasePart")
end

local FarmHoverBv = nil
local function UpdateFarmHover(enable, root)
    if enable and root then
        if not FarmHoverBv or FarmHoverBv.Parent ~= root then
            pcall(function() if FarmHoverBv then FarmHoverBv:Destroy() end end)
            local bv = Instance.new("BodyVelocity")
            bv.Name = "_VeilFarmHover"
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = Vector3.zero
            bv.Parent = root
            FarmHoverBv = bv
        else
            FarmHoverBv.Velocity = Vector3.zero
            FarmHoverBv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        end
    else
        if FarmHoverBv then
            pcall(function() FarmHoverBv:Destroy() end)
            FarmHoverBv = nil
        end
    end
end

local function GetMobHumanoidAndRoot(model)
    if not model or not model.Parent or IsPlayerCharacter(model) or IsDummyOrProp(model) then
        return nil, nil
    end

    if not model:IsDescendantOf(workspace) then
        return nil, nil
    end

    local hum = model:FindFirstChild("Enemy") or model:FindFirstChildOfClass("Humanoid")
    local root = GetEntityRoot(model)

    if hum and root and hum.Health > 0 then
        local pos = root.Position
        if pos.Y > -1500 and pos.Y < 2500 and math.abs(pos.X) < 4500 and math.abs(pos.Z) < 4500 then
            return hum, root
        end
    end
    return nil, nil
end

local KNOWN_MONSTER_CATALOG = {
    "Alien", "Alien Engineer", "Alien Gunner", "Ancient Bones", "Angry Nimbus",
    "Armored Skeleton", "Bloated Hiveling", "Blood Hiveling", "Cambion", "Clown",
    "Crowned Goblin", "Cursed Hammer", "Dissonant", "Dissonant Brute", "Enchanted Sword",
    "Gigazapper", "Goblin", "Goblin Archer", "Goblin Sorcerer", "Goblin Thief",
    "Goblin Warlock", "Goblin Warrior", "Hiveling", "Hiveling Brute", "Hiveling Titan",
    "Hivelingstein", "Hungry", "Imp", "Martian Saucer", "Minotaur", "Necromancer",
    "Pillar Mimic", "Shrouded", "Skeleton", "Smelter Demon", "Starving Warrior",
    "Stone Husk", "The Angry Mask", "The Beholder", "The Bell", "The Cell Of Life",
    "The Crowned Nothing", "The Festering Wound", "The Laughing Mask", "The Puppeteer",
    "The Sleeping Mask", "The Stormcaller", "The Unfinished", "The Weeping Mask",
    "Turret Golem", "Twisted Fool", "Wraith"
}

local function GetAllActiveMonsters(forceRefresh)
    local now = tick()
    if not forceRefresh and (now - LastActiveMonstersUpdate < 0.5) then
        return CachedActiveMonsters
    end

    LastActiveMonstersUpdate = now
    local mobs = {}
    local seen = {}

    local function inspectEntity(child)
        if not child or not child:IsA("Model") or seen[child] or IsPlayerCharacter(child) or IsDummyOrProp(child) then
            return
        end
        local teamVal = child:FindFirstChild("Team")
        if teamVal and tostring(teamVal.Value):lower():find("player") then
            return
        end
        local hum = child:FindFirstChild("Enemy") or child:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < 1e20 then
            local root = GetEntityRoot(child)
            if root then
                seen[child] = true
                table.insert(mobs, child)
            end
        end
    end

    local function scan(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            inspectEntity(child)
            if child:IsA("Folder") then
                for _, sub in ipairs(child:GetChildren()) do
                    inspectEntity(sub)
                end
            end
        end
    end

    if MonstersFolder then scan(MonstersFolder) end
    if EnemySpawnZonesFolder then scan(EnemySpawnZonesFolder) end

    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and not seen[child] and child.Name ~= "Monsters" and child.Name ~= "EnemySpawnZones" and child.Name ~= "NPCs" and child.Name ~= "Drops" and child.Name ~= "Spawns" and child.Name ~= "Terrain" then
            if child:FindFirstChild("Enemy") then
                inspectEntity(child)
            end
        end
    end

    CachedActiveMonsters = mobs
    return mobs
end

local function GetMonsterTypeList()
    local set = {}
    local clean = {"All Mobs"}

    local allMobs = GetAllActiveMonsters(true)
    for _, mob in ipairs(allMobs) do
        local n = mob.Name
        if n and n ~= "" and not set[n] and not IsDummyOrProp(mob) then
            set[n] = true
            table.insert(clean, n)
        end
    end

    if #clean == 1 then
        table.insert(clean, "No Mobs Spawned")
    end

    table.sort(clean, function(a, b)
        if a == "All Mobs" then return true end
        if b == "All Mobs" then return false end
        if a == "No Mobs Spawned" then return false end
        if b == "No Mobs Spawned" then return true end
        return a < b
    end)

    return clean
end

local function GetAvailableWeapons()
    local list = {"Currently Equipped"}
    local seen = {}

    local function scanTools(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and not seen[item.Name] then
                seen[item.Name] = true
                table.insert(list, item.Name)
            end
        end
    end

    scanTools(LocalPlayer.Character)
    scanTools(LocalPlayer:FindFirstChild("Backpack"))

    return list
end

local function GetPlayerList(includeNearest)
    local list = includeNearest and {"Nearest"} or {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

local function GetNpcList()
    local set = {}
    local clean = {}

    local function checkAndAdd(obj)
        if (obj:IsA("Model") or obj:FindFirstChildWhichIsA("BasePart")) and not IsPlayerCharacter(obj) and not IsDummyOrProp(obj) then
            local root = GetEntityRoot(obj)
            if root then
                CachedNPCPositions[obj.Name] = root.CFrame
                if not set[obj.Name] and obj.Name ~= "HumanoidRootPart" then
                    set[obj.Name] = true
                    table.insert(clean, obj.Name)
                end
            end
        end
    end

    if NPCFolder then
        for _, child in pairs(NPCFolder:GetChildren()) do
            checkAndAdd(child)
            if child:IsA("Folder") or child:IsA("Model") then
                for _, sub in pairs(child:GetChildren()) do
                    if sub:IsA("Model") then checkAndAdd(sub) end
                end
            end
        end
    end

    if AreasFolder then
        for _, desc in pairs(AreasFolder:GetDescendants()) do
            if desc:IsA("Model") and (desc:FindFirstChild("NPC") or desc.Name:find("Wisp") or desc.Name:find("Merchant")) then
                checkAndAdd(desc)
            end
        end
    end

    table.sort(clean)
    return #clean > 0 and clean or {"No NPCs found"}
end

local function GetAreaList()
    local list = {"Spawn"}
    if AreasFolder then
        for _, a in pairs(AreasFolder:GetChildren()) do
            if a:IsA("Model") or a:IsA("Folder") or a:IsA("BasePart") then
                table.insert(list, a.Name)
            end
        end
    end
    return list
end

local function GetCurrentAreaName()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return "Unknown" end

    if AreasFolder then
        local closestArea = "Wilderness"
        local minD = 300
        for _, a in pairs(AreasFolder:GetChildren()) do
            local p = a:FindFirstChildWhichIsA("BasePart") or (a:IsA("BasePart") and a) or (a:IsA("Model") and a.PrimaryPart)
            if p then
                local d = (root.Position - p.Position).Magnitude
                if d < minD then
                    minD = d
                    closestArea = a.Name
                end
            end
        end
        return closestArea
    end
    return "The Veil Lands"
end

-- ================================================
--  WEAPON ACQUISITION & ATTACK
-- ================================================
local function GetDesiredWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if State.SelectedWeapon == "Currently Equipped" then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then return item end
        end
        return nil
    end

    local equippedTool = char:FindFirstChild(State.SelectedWeapon)
    if equippedTool and equippedTool:IsA("Tool") then
        return equippedTool
    end

    if bp and hum then
        local bpTool = bp:FindFirstChild(State.SelectedWeapon)
        if bpTool and bpTool:IsA("Tool") then
            hum:EquipTool(bpTool)
            task.wait(0.04)
            return bpTool
        end
    end

    return nil
end

local WeaponPartsCache = setmetatable({}, { __mode = "k" })
local function GetWeaponParts(tool)
    local cached = WeaponPartsCache[tool]
    if cached then
        -- valide seulement si les enfants n'ont pas changé
        local n = 0
        for _ in tool:GetChildren() do n = n + 1 end
        if cached.Count == n then return cached.Parts end
    end
    local parts = {}
    for _, p in ipairs(tool:GetDescendants()) do
        if p:IsA("BasePart") then table.insert(parts, p) end
    end
    WeaponPartsCache[tool] = { Parts = parts, Count = #tool:GetChildren() }
    return parts
end

local function PerformStrike(targetRoot, isHeavy)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = LocalPlayer:FindFirstChild("Backpack")

    local vals = char:FindFirstChild("Values")
    if vals then
        if State.Instakill then
            local pveDmg = vals:FindFirstChild("PVEDamageMultiplier")
            if pveDmg and pveDmg:IsA("NumberValue") then pveDmg.Value = 99999 end
            local uniDmg = vals:FindFirstChild("UniversalDamageMultiplier")
            if uniDmg and uniDmg:IsA("NumberValue") then uniDmg.Value = 99999 end
            local dmg = vals:FindFirstChild("DamageMultiplier")
            if dmg and dmg:IsA("NumberValue") then dmg.Value = 99999 end
        end
        if State.AutoCritical or isHeavy then
            local critMult = vals:FindFirstChild("CriticalMultiplier")
            if critMult and critMult:IsA("NumberValue") then critMult.Value = 999 end
        end
    end

    local activeTools = {}
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("Values") then
            table.insert(activeTools, item)
        end
    end

    if State.Instakill and bp then
        for _, bpItem in ipairs(bp:GetChildren()) do
            if bpItem:IsA("Tool") and bpItem:FindFirstChild("Values") and bpItem.Values:FindFirstChild("Stats") then
                pcall(function() bpItem.Parent = char end)
                table.insert(activeTools, bpItem)
            end
        end
    end

    if #activeTools == 0 then
        local bestWeapon = bp and (bp:FindFirstChild("Sahara Slicer") or bp:FindFirstChild("Bonesaber") or bp:FindFirstChildWhichIsA("Tool"))
        if bestWeapon and hum then
            pcall(function() hum:EquipTool(bestWeapon) end)
            table.insert(activeTools, bestWeapon)
        end
    end

    local aimCf
    if targetRoot and root then
        aimCf = CFrame.lookAt(root.Position, targetRoot.Position)
    else
        aimCf = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new()
    end

    local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    local rAbility = RemotesFolder and RemotesFolder:FindFirstChild("RAbilityEvent")
    local tAbility = RemotesFolder and RemotesFolder:FindFirstChild("TAbilityEvent")
    local vAbility = RemotesFolder and RemotesFolder:FindFirstChild("VAbilityEvent")
    local yAbility = RemotesFolder and RemotesFolder:FindFirstChild("YAbilityEvent")
    local uAbility = RemotesFolder and RemotesFolder:FindFirstChild("UAbilityEvent")
    local dashEv   = RemotesFolder and RemotesFolder:FindFirstChild("DashEvent")

    for _, tool in ipairs(activeTools) do
        local tVals = tool:FindFirstChild("Values")
        local stats = tVals and tVals:FindFirstChild("Stats")
        if stats and State.Instakill then
            local bDmg = stats:FindFirstChild("BaseDamage")
            if bDmg and bDmg:IsA("NumberValue") and bDmg.Value < 9999 then bDmg.Value = 9999 end
            local cDmg = stats:FindFirstChild("CriticalDamage")
            if cDmg and cDmg:IsA("NumberValue") and cDmg.Value < 9999 then cDmg.Value = 9999 end
            local atkCd = stats:FindFirstChild("AttackCooldown")
            if atkCd and atkCd:IsA("NumberValue") then atkCd.Value = 0.05 end
            local atkDl = stats:FindFirstChild("AttackDelay")
            if atkDl and atkDl:IsA("NumberValue") then atkDl.Value = 0 end
        end

        pcall(function()
            tool.Enabled = true
            tool:Activate()
        end)

        if State.Instakill or State.AutoAbility then
            if rAbility then pcall(function() rAbility:FireServer(tool, aimCf) end) end
            if tAbility then pcall(function() tAbility:FireServer(tool, aimCf) end) end
            if vAbility then pcall(function() vAbility:FireServer(tool, aimCf) end) end
            if yAbility then pcall(function() yAbility:FireServer(tool, aimCf) end) end
            if uAbility then pcall(function() uAbility:FireServer(tool, aimCf) end) end
        end
    end

    if State.Instakill and dashEv then
        pcall(function() dashEv:FireServer() end)
    end

    pcall(function()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local cx, cy = vp.X / 2, vp.Y / 2
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
        task.delay(0.015, function()
            pcall(function() VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 1) end)
        end)
    end)
    if not VIM then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0, 0))
            task.delay(0.015, function()
                pcall(function() vu:Button1Up(Vector2.new(0, 0)) end)
            end)
        end)
    end

    if targetRoot and firetouchinterest then
        local weaponParts = {}
        for _, tool in ipairs(activeTools) do
            for _, p in ipairs(GetWeaponParts(tool)) do
                table.insert(weaponParts, p)
            end
        end
        for _, limbName in ipairs({"RightHand", "Right Arm", "LeftHand", "Left Arm", "Torso", "HumanoidRootPart"}) do
            local limb = char:FindFirstChild(limbName)
            if limb and limb:IsA("BasePart") then table.insert(weaponParts, limb) end
        end

        local mobModel = targetRoot.Parent
        local targetParts = { targetRoot }
        if mobModel and mobModel:IsA("Model") then
            for _, partName in ipairs({"Torso", "UpperTorso", "Head", "Right Arm", "Left Arm"}) do
                local p = mobModel:FindFirstChild(partName)
                if p and p:IsA("BasePart") and p ~= targetRoot then
                    table.insert(targetParts, p)
                end
            end
        end

        for _, wp in ipairs(weaponParts) do
            for _, tp in ipairs(targetParts) do
                pcall(function()
                    firetouchinterest(wp, tp, 0)
                    firetouchinterest(wp, tp, 1)
                end)
            end
        end
    end
end

-- ================================================
--  TELEPORT LOGIC (NO DESYNC / NO RUBBERBAND)
-- ================================================
local IsTeleporting = false
local AbortCurrentTeleport = false

local function SafeTeleportTo(cf, allowAbort)
    if IsTeleporting then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not cf then return end

    local startPos = root.Position
    local finalTargetPos = cf.Position
    local totalDist = (finalTargetPos - startPos).Magnitude

    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    if totalDist <= 45 then
        pcall(function() char:PivotTo(cf) end)
        root.CFrame = cf
        task.wait(0.02)
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
        return
    end

    local waypoints = {}
    if finalTargetPos.Y < -500 and startPos.Y > -200 then
        table.insert(waypoints, Vector3.new(416.25, 40, -250))
        table.insert(waypoints, Vector3.new(416.25, finalTargetPos.Y, -250))
        table.insert(waypoints, finalTargetPos)
    elseif finalTargetPos.Y > -200 and startPos.Y < -500 then
        table.insert(waypoints, Vector3.new(416.25, startPos.Y, -250))
        table.insert(waypoints, Vector3.new(416.25, 40, -250))
        table.insert(waypoints, finalTargetPos)
    else
        table.insert(waypoints, finalTargetPos)
    end

    IsTeleporting = true
    AbortCurrentTeleport = false

    local noclipActive = true
    local noclipConn = RunService.Stepped:Connect(function()
        if not noclipActive then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end)

    local maxSpeed = 75

    for wpIdx, wpTarget in ipairs(waypoints) do
        if allowAbort and AbortCurrentTeleport then break end
        if not (char and char.Parent and root and root.Parent) then break end

        local segDist = (wpTarget - root.Position).Magnitude
        local segMaxDuration = math.max((segDist / maxSpeed) + 3.0, 5.0)
        local segStartTick = tick()
        local segLastTick = segStartTick

        while noclipActive and char and char.Parent and root and root.Parent do
            if allowAbort and AbortCurrentTeleport then break end
            local now = tick()
            if now - segStartTick > segMaxDuration then break end

            local dt = math.clamp(now - segLastTick, 0.001, 0.1)
            segLastTick = now

            local currentPos = root.Position
            local d = (wpTarget - currentPos).Magnitude
            if d <= 2.0 then break end

            local stepDist = math.min(maxSpeed * dt, d)
            local dir = (wpTarget - currentPos).Unit
            local nextPos = currentPos + (dir * stepDist)
            root.CFrame = CFrame.lookAt(nextPos, nextPos + dir)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
    end

    noclipActive = false
    pcall(function() noclipConn:Disconnect() end)

    if not (allowAbort and AbortCurrentTeleport) and root and root.Parent then
        local finalDist = (finalTargetPos - root.Position).Magnitude
        if finalDist <= 4.0 then
            pcall(function() char:PivotTo(cf) end)
            root.CFrame = cf
        end
    end

    task.wait(0.04)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    if not (State.Noclip or State.Fly or State.MobFarm or State.PlayerFarm) then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = true
            end
        end
    end

    IsTeleporting = false
    AbortCurrentTeleport = false
end

-- ================================================
--  SAFE AUTO PICKUP, PROXIMITY PROMPT & NOTIFICATIONS
-- ================================================
local function NotifyUser(title, message, duration)
    duration = duration or 3.5
    pcall(function()
        if Rayfield and Rayfield.Notify then
            Rayfield:Notify({
                Title = title,
                Content = message,
                Duration = duration,
                Image = 4483362458
            })
        end
    end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration
        })
    end)
    print(string.format("[%s] %s", title, message))
end

local function FireTouch(part)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and part and part:IsA("BasePart") then
        if firetouchinterest then
            pcall(function()
                firetouchinterest(root, part, 0)
                task.wait(0.02)
                firetouchinterest(root, part, 1)
            end)
        end
    end
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        local oldDist = prompt.MaxActivationDistance
        local oldHold = prompt.HoldDuration
        prompt.MaxActivationDistance = 99999
        prompt.HoldDuration = 0

        if fireproximityprompt then
            pcall(function() fireproximityprompt(prompt) end)
        end

        pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.04)
            prompt:InputHoldEnd()
        end)

        task.delay(0.25, function()
            pcall(function()
                prompt.MaxActivationDistance = oldDist
                prompt.HoldDuration = oldHold
            end)
        end)
    end)
end

local CachedGameRemotes = nil
local LastRemotesCacheTick = 0

local function GetCachedRemotesList()
    local now = tick()
    if CachedGameRemotes and (now - LastRemotesCacheTick < 15) then
        return CachedGameRemotes
    end
    LastRemotesCacheTick = now
    local targets = {}
    if Remotes then
        pcall(function()
            for _, desc in ipairs(Remotes:GetChildren()) do
                if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                    table.insert(targets, desc)
                end
            end
        end)
    end
    local rsRemotes = ReplicatedStorage:FindFirstChild("Remotes")
    if rsRemotes and rsRemotes ~= Remotes then
        pcall(function()
            for _, desc in ipairs(rsRemotes:GetChildren()) do
                if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                    table.insert(targets, desc)
                end
            end
        end)
    end
    CachedGameRemotes = targets
    return targets
end

local function DispatchMatchingRemotes(keywords, args, excludeKeywords)
    local fired = 0
    local targets = GetCachedRemotesList()
    local seen = {}
    for _, r in ipairs(targets) do
        if not seen[r] then
            seen[r] = true
            local name = r.Name:lower()

            local isExcluded = false
            local securityTraps = { "anticheat", "security", "ban", "kick", "flag", "report", "detection", "cheat", "exploit", "tamper", "verify", "telemetry", "analytics", "violation", "punish", "alert", "error", "log", "honeypot", "anomaly" }
            for _, trap in ipairs(securityTraps) do
                if name:find(trap) then
                    isExcluded = true
                    break
                end
            end

            if not isExcluded and excludeKeywords then
                for _, ex in ipairs(excludeKeywords) do
                    if name:find(ex:lower()) then
                        isExcluded = true
                        break
                    end
                end
            end

            if not isExcluded then
                local matched = false
                for _, kw in ipairs(keywords) do
                    if name:find(kw:lower()) then
                        matched = true
                        break
                    end
                end
                if matched then
                    pcall(function()
                        if r:IsA("RemoteEvent") then
                            if args then
                                r:FireServer(unpack(args))
                            else
                                r:FireServer()
                            end
                        elseif r:IsA("RemoteFunction") then
                            task.spawn(function()
                                if args then
                                    r:InvokeServer(unpack(args))
                                else
                                    r:InvokeServer()
                                end
                            end)
                        end
                        fired = fired + 1
                    end)
                end
            end
        end
    end
    return fired
end

local PickupRemotesCache = nil
local LastPickupRemotesCacheTick = 0
local function GetPickupRemotes()
    local now = tick()
    if PickupRemotesCache and (now - LastPickupRemotesCacheTick < 10) then
        return PickupRemotesCache
    end
    LastPickupRemotesCacheTick = now
    local remotes = {}
    local rems = GetCachedRemotesList()
    local kws = {"pickup", "loot", "drop", "collect", "grab", "item", "interact"}
    for _, r in ipairs(rems) do
        local rName = r.Name:lower()
        for _, kw in ipairs(kws) do
            if rName:find(kw) then
                table.insert(remotes, r)
                break
            end
        end
    end
    PickupRemotesCache = remotes
    return remotes
end

local function SafePickupItem(item)
    if not item or not item.Parent or getgenv().Veil_Unloaded then return end
    if IgnoreDropNames[item.Name] then return end

    if State.LootFilterEnabled then
        local rarityVal = item:FindFirstChild("Rarity") or item:FindFirstChildWhichIsA("StringValue")
        local rarity = "Common"
        if rarityVal and rarityVal:IsA("StringValue") then
            rarity = rarityVal.Value
        elseif item:GetAttribute("Rarity") then
            rarity = tostring(item:GetAttribute("Rarity"))
        end

        local pass = false
        if rarity == "Common" and State.LootFilterCommon then pass = true
        elseif rarity == "Uncommon" and State.LootFilterUncommon then pass = true
        elseif rarity == "Rare" and State.LootFilterRare then pass = true
        elseif rarity == "Epic" and State.LootFilterEpic then pass = true
        elseif rarity == "Legendary" and State.LootFilterLegendary then pass = true
        elseif rarity == "Mythic" and State.LootFilterMythic then pass = true
        end

        if not pass then return end
    end

    if PickedUpDrops[item] and (tick() - PickedUpDrops[item] < 1.0) then return end
    PickedUpDrops[item] = tick()

    local interact = InteractRemote or (Remotes and Remotes:FindFirstChild("InteractPromptEvent"))
    if interact then
        local arg = item:FindFirstChild("Argument")
        local argVal = arg and arg.Value or "PickupDrop"
        pcall(function()
            interact:FireServer(argVal, item)
        end)
    end

    if item:IsA("BasePart") then
        FireTouch(item)
    else
        for _, p in ipairs(item:GetDescendants()) do
            if p:IsA("BasePart") then
                FireTouch(p)
            end
        end
    end

    if item:IsA("ProximityPrompt") then
        TriggerPrompt(item)
    else
        for _, desc in ipairs(item:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                TriggerPrompt(desc)
            end
        end
    end

    local pRemotes = GetPickupRemotes()
    for _, r in ipairs(pRemotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer("PickupDrop", item)
                r:FireServer(item)
            elseif r:IsA("RemoteFunction") then
                task.spawn(function()
                    pcall(function() r:InvokeServer("PickupDrop", item) end)
                end)
            end
        end)
    end
end

local CachedChests = {}
local LastChestCacheTick = 0

local function IsChestPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    local act = (prompt.ActionText or ""):lower()
    local obj = (prompt.ObjectText or ""):lower()
    local parentName = (prompt.Parent.Name or ""):lower()
    local grandParentName = (prompt.Parent.Parent and prompt.Parent.Parent.Name or ""):lower()
    local combined = act .. " " .. obj .. " " .. parentName .. " " .. grandParentName

    local keywords = {"chest", "coffer", "crate", "urn", "stash", "cache", "treasure", "loot", "relic", "box", "container"}
    for _, kw in ipairs(keywords) do
        if combined:find(kw) then
            return true
        end
    end
    if (act:find("open") or act:find("unlock") or act:find("search") or act:find("take")) and not combined:find("door") and not combined:find("gate") and not combined:find("portal") then
        return true
    end
    return false
end

local function FindAllChests()
    local chests = {}
    local seen = {}

    local blacklist = {
        "crate", "barrel", "urn", "plate", "chestplate", "door", "portal",
        "wall", "house", "tavern", "table", "bench", "chair", "bed",
        "lamp", "torch", "lantern", "board", "dummy", "prop", "spawn", "probe"
    }

    local function isBlacklisted(name)
        if not name then return true end
        local n = name:lower()
        for _, b in ipairs(blacklist) do
            if n:find(b) then return true end
        end
        return false
    end

    local function isRealChestName(name)
        if not name or isBlacklisted(name) then return false end
        local n = name:lower()
        if n == "chest" or n == "coffer" or n:find("^chest") or n:find("^coffer")
        or n:find("treasure%s*chest") or n:find("loot%s*chest") or n:find("gold%s*chest")
        or n:find("silver%s*chest") or n:find("bronze%s*chest") or n:find("relic%s*chest") then
            return true
        end
        return false
    end

    local function addChest(obj, prompt, part, customName)
        if not obj or seen[obj] or isBlacklisted(obj.Name) then return end
        seen[obj] = true
        local p = part
            or obj:FindFirstChild("Main")
            or obj:FindFirstChildWhichIsA("BasePart")
            or (obj:IsA("BasePart") and obj)
            or obj.PrimaryPart
            or (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent)
        if p then
            local displayName = customName or obj.Name
            table.insert(chests, { Object = obj, Prompt = prompt, Part = p, Name = displayName })
        end
    end

    local function checkChestCandidate(desc)
        if not desc or IsPlayerCharacter(desc) or desc:FindFirstChild("Enemy") or desc:FindFirstChildOfClass("Humanoid") then return end
        local arg = desc:FindFirstChild("Argument")
        local prompt = desc:FindFirstChildWhichIsA("ProximityPrompt") or (desc:IsA("ProximityPrompt") and desc)

        if arg and arg:IsA("StringValue") and arg.Value == "OpenChest" then
            addChest(desc, prompt, nil, desc.Name)
        elseif prompt then
            local act = (prompt.ActionText or ""):lower()
            local objTxt = (prompt.ObjectText or ""):lower()
            if (objTxt:find("chest") or objTxt:find("coffer")) and not isBlacklisted(objTxt) then
                local pObj = desc:IsA("ProximityPrompt") and desc.Parent or desc
                addChest(pObj, prompt, nil, prompt.ObjectText)
            elseif (act:find("chest") or act:find("coffer")) and not isBlacklisted(act) then
                local pObj = desc:IsA("ProximityPrompt") and desc.Parent or desc
                addChest(pObj, prompt, nil, pObj.Name)
            end
        elseif (desc:IsA("Model") or desc:IsA("BasePart")) and isRealChestName(desc.Name) then
            local parent = desc.Parent
            if not (parent and seen[parent]) then
                addChest(desc, prompt, nil, desc.Name)
            end
        end
    end

    -- 1. Scan direct known containers first (O(1) search)
    local knownContainers = {
        workspace:FindFirstChild("Systems"),
        workspace:FindFirstChild("Chests"),
        workspace:FindFirstChild("Loot"),
        workspace:FindFirstChild("Spawns"),
        workspace:FindFirstChild("Interactables"),
        AreasFolder
    }
    for _, f in ipairs(knownContainers) do
        if f then
            for _, child in ipairs(f:GetDescendants()) do
                checkChestCandidate(child)
            end
        end
    end

    -- 2. Fast top-level scan for loose chests
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and not seen[child] and isRealChestName(child.Name) then
            checkChestCandidate(child)
        end
    end

    return chests
end

local IsScanningChests = false
local function UpdateChestCache(force)
    local now = tick()
    if (force or now - LastChestCacheTick >= 5.0) and not IsScanningChests then
        LastChestCacheTick = now
        IsScanningChests = true
        task.spawn(function()
            local ok, list = pcall(FindAllChests)
            if ok and list then
                CachedChests = list
            end
            IsScanningChests = false
        end)
    end
end

local function OpenAllMapChests()
    local chests = FindAllChests()
    if #chests == 0 then
        NotifyUser("NW Hub | Chests", "No chests found.", 3)
        return
    end

    NotifyUser("NW Hub | Chests", string.format("Opening %d chests...", #chests), 4)

    task.spawn(function()
        local opened = 0
        for i, chest in ipairs(chests) do
            if getgenv().Veil_Unloaded then break end
            if chest.Part and (chest.Prompt or chest.Object) then
                SafeTeleportTo(chest.Part.CFrame + Vector3.new(0, 2.5, 0))
                task.wait(0.20)
                if chest.Prompt and chest.Prompt.Parent then
                    TriggerPrompt(chest.Prompt)
                elseif chest.Object and chest.Object:FindFirstChild("Argument") and InteractRemote then
                    pcall(function()
                        InteractRemote:FireServer("OpenChest", chest.Object)
                    end)
                end
                FireTouch(chest.Part)
                opened = opened + 1
                task.wait(0.18)
            end
        end
        NotifyUser("NW Hub | Chests", string.format("Opened %d / %d chests.", opened, #chests), 4)
    end)
end

-- ================================================
--  FIX #3: TRINKET SCAN — FULL MAP SCAN
-- ================================================
local TRINKET_NAME_HINTS = {
    "trinket", "relic", "glowing", "shimmer", "glint", "sparkle",
    "artifact", "essence", "crystal", "orb", "shard", "fragment",
    "collectible", "collectable"
}
local TRINKET_PROMPT_HINTS = {
    "collect", "harvest", "pick", "pickup", "take", "grab",
    "relic", "trinket", "shimmer", "glint"
}

local function IsTrinketLike(obj, prompt)
    if not obj then return false end
    local name = (obj.Name or ""):lower()
    local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
    local full = name .. " " .. parentName
    for _, hint in ipairs(TRINKET_NAME_HINTS) do
        if full:find(hint) then return true end
    end
    if prompt then
        local act = (prompt.ActionText or ""):lower()
        local otxt = (prompt.ObjectText or ""):lower()
        local combined = act .. " " .. otxt .. " " .. full
        for _, hint in ipairs(TRINKET_PROMPT_HINTS) do
            if combined:find(hint) then return true end
        end
    end
    return false
end

local function FindAllTrinketAndLootItems()
    local items, seen = {}, {}

    local function addIfValid(obj, part)
        if not obj or seen[obj] then return end
        if IgnoreDropNames[obj.Name] then return end
        local p = part
            or (obj:IsA("BasePart") and obj)
            or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            or obj:FindFirstChildWhichIsA("BasePart")
        if not p then return end
        seen[obj] = true
        table.insert(items, { Object = obj, Part = p, Pivot = p.CFrame })
    end

    -- Dossiers connus : survol direct sans GetDescendants
    local folders = {
        DropsFolder, TrinketFolder,
        workspace:FindFirstChild("Trinkets"), workspace:FindFirstChild("Items"),
        workspace:FindFirstChild("Loot"),     workspace:FindFirstChild("Relics"),
        workspace:FindFirstChild("Chests"),   workspace:FindFirstChild("Debris"),
        workspace:FindFirstChild("WorldDrops"), workspace:FindFirstChild("Spawns"),
        workspace:FindFirstChild("Interactables"), workspace:FindFirstChild("Collectibles"),
        AreasFolder,
    }
    for _, f in ipairs(folders) do
        if f then
            local fn = (f.Name or ""):lower()
            local inFolderTrinket = fn:find("trinket") or fn:find("relic") or fn:find("collect")
            for _, child in ipairs(f:GetChildren()) do
                if not IsPlayerCharacter(child) and not child:IsA("Terrain") then
                    if inFolderTrinket or IsTrinketLike(child, nil) then
                        addIfValid(child)
                    end
                end
            end
        end
    end

    return items
end

local IsCollectingTrinkets = false

local function CollectAllMapTrinkets()
    if IsCollectingTrinkets then return end
    local items = FindAllTrinketAndLootItems()
    if #items == 0 then
        if not State.TrinketFarm then
            NotifyUser("NW Hub | Trinkets", "No relics found.", 3)
        end
        return
    end

    if not State.TrinketFarm then
        NotifyUser("NW Hub | Trinkets", string.format("Collecting %d relics...", #items), 3.5)
    end

    IsCollectingTrinkets = true
    task.spawn(function()
        local collected = 0
        for _, entry in ipairs(items) do
            if getgenv().Veil_Unloaded or not IsCollectingTrinkets then break end
            local targetCf = entry.Pivot or (entry.Part and entry.Part.CFrame)
            if targetCf then
                SafeTeleportTo(targetCf + Vector3.new(0, 2.0, 0), true)
                if getgenv().Veil_Unloaded or not IsCollectingTrinkets then break end
                task.wait(0.08)
                if entry.Part then FireTouch(entry.Part) end
                SafePickupItem(entry.Object)
                pcall(function()
                    for _, d in ipairs(entry.Object:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            TriggerPrompt(d)
                        end
                    end
                end)
                collected = collected + 1
                task.wait(0.08)
            end
        end
        IsCollectingTrinkets = false
        if collected > 0 and not State.TrinketFarm then
            NotifyUser("NW Hub | Trinkets", string.format("Collected %d / %d relics.", collected, #items), 3.5)
        end
    end)
end

-- ================================================
--  ESP ENGINE
-- ================================================
local function RemoveESP(model)
    if ActiveESP[model] then
        pcall(function()
            local item = ActiveESP[model]
            if item.Container then item.Container:Destroy() end
            if item.Highlight then item.Highlight:Destroy() end
            if item.Box3D then item.Box3D:Destroy() end
        end)
        ActiveESP[model] = nil
    end
end

local function RemoveDropESP(drop)
    if LootESP[drop] then
        pcall(function()
            if LootESP[drop].Highlight then LootESP[drop].Highlight:Destroy() end
            if LootESP[drop].Tag then LootESP[drop].Tag:Destroy() end
        end)
        LootESP[drop] = nil
    end
end

local function RemoveNpcESP(npc)
    if NpcESP[npc] then
        pcall(function()
            if NpcESP[npc].Highlight then NpcESP[npc].Highlight:Destroy() end
            if NpcESP[npc].Tag then NpcESP[npc].Tag:Destroy() end
        end)
        NpcESP[npc] = nil
    end
end

local function RemoveTrinketESP(obj)
    if TrinketESP[obj] then
        pcall(function()
            if TrinketESP[obj].Tag then TrinketESP[obj].Tag:Destroy() end
            if TrinketESP[obj].Highlight then TrinketESP[obj].Highlight:Destroy() end
        end)
        TrinketESP[obj] = nil
    end
end

local function RemoveChestESP(obj)
    if ChestESP[obj] then
        pcall(function()
            if ChestESP[obj].Tag then ChestESP[obj].Tag:Destroy() end
            if ChestESP[obj].Highlight then ChestESP[obj].Highlight:Destroy() end
        end)
        ChestESP[obj] = nil
    end
end

local function Create3DBoxAdornment(root, color)
    local box = Instance.new("SelectionBox")
    box.Name = "_rbx_3d"
    box:SetAttribute(TAG_ID, true)
    box.Adornee = root
    box.Color3 = color
    box.LineThickness = 0.04
    box.SurfaceTransparency = 0.9
    box.Parent = GetUiContainer()
    return box
end

local function CreateLootTag(part, name, color, prefix)
    local bb = Instance.new("BillboardGui")
    bb.Name = "_rbx_tag"
    bb:SetAttribute(TAG_ID, true)
    bb.Adornee = part
    bb.Size = UDim2.new(0, 150, 0, 22)
    bb.StudsOffset = Vector3.new(0, 1.8, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 300
    bb.LightInfluence = 0

    local title = Instance.new("TextLabel", bb)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = color
    title.TextStrokeTransparency = 0
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.Text = (prefix and (prefix .. " - ") or "") .. name

    bb.Parent = GetUiContainer()
    return bb, title
end

local function GetModelBounds(model, root)
    local rootCF = root.CFrame
    local rootPos = rootCF.Position
    local head = model:FindFirstChild("Head")
    local topY = head and (head.Position.Y + 1.1) or (rootPos.Y + 2.7)
    local btmY = rootPos.Y - 2.85
    return Vector3.new(rootPos.X, topY, rootPos.Z), Vector3.new(rootPos.X, btmY, rootPos.Z)
end

local function CreateShooterESP(model, isPlayer, isLocal)
    local root = GetEntityRoot(model)
    local hum = (isPlayer or isLocal) and model:FindFirstChildOfClass("Humanoid")
        or (model:FindFirstChild("Enemy") or model:FindFirstChildOfClass("Humanoid"))
    if not root or not hum then return nil end

    local hlColor = isLocal and Color3.fromRGB(0, 255, 220)
        or (isPlayer and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(255, 60, 60))
    local boxBorderColor = isLocal and Color3.fromRGB(0, 255, 220)
        or (isPlayer and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 255, 100))

    local container = Instance.new("Frame")
    container.Name = "_esp_" .. model.Name
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = EspScreenGui

    local boxOuter = Instance.new("Frame")
    boxOuter.Name = "BoxOuter"
    boxOuter.Size = UDim2.new(1, 2, 1, 2)
    boxOuter.Position = UDim2.new(0, -1, 0, -1)
    boxOuter.BackgroundTransparency = 1
    boxOuter.BorderSizePixel = 1
    boxOuter.BorderColor3 = Color3.fromRGB(0, 0, 0)
    boxOuter.BorderMode = Enum.BorderMode.Inset
    boxOuter.Parent = container

    local boxInner = Instance.new("Frame")
    boxInner.Name = "BoxInner"
    boxInner.Size = UDim2.new(1, 0, 1, 0)
    boxInner.Position = UDim2.new(0, 0, 0, 0)
    boxInner.BackgroundTransparency = 1
    boxInner.BorderSizePixel = 1
    boxInner.BorderColor3 = boxBorderColor
    boxInner.BorderMode = Enum.BorderMode.Inset
    boxInner.Parent = container

    local hpBarBg = Instance.new("Frame")
    hpBarBg.Name = "HpBarBg"
    hpBarBg.Size = UDim2.new(0, 4, 1, 0)
    hpBarBg.Position = UDim2.new(0, -6, 0, 0)
    hpBarBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    hpBarBg.BorderSizePixel = 1
    hpBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    hpBarBg.Parent = container

    local hpBarFill = Instance.new("Frame")
    hpBarFill.Name = "HpBarFill"
    hpBarFill.Size = UDim2.new(1, 0, 1, 0)
    hpBarFill.Position = UDim2.new(0, 0, 0, 0)
    hpBarFill.BackgroundColor3 = Color3.fromRGB(75, 230, 95)
    hpBarFill.BorderSizePixel = 0
    hpBarFill.Parent = hpBarBg

    local hpNumber = Instance.new("TextLabel")
    hpNumber.Name = "HpNumber"
    hpNumber.Size = UDim2.new(0, 32, 0, 12)
    hpNumber.Position = UDim2.new(0, -40, 0, 0)
    hpNumber.BackgroundTransparency = 1
    hpNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpNumber.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hpNumber.TextStrokeTransparency = 0
    hpNumber.Font = Enum.Font.GothamBold
    hpNumber.TextSize = 11
    hpNumber.TextXAlignment = Enum.TextXAlignment.Right
    hpNumber.Text = "100"
    hpNumber.Parent = container

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.AnchorPoint = Vector2.new(0.5, 1)
    nameLabel.Size = UDim2.new(0, 200, 0, 16)
    nameLabel.Position = UDim2.new(0.5, 0, 0, -4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Text = model.Name
    nameLabel.Parent = container

    local bottomLabel = Instance.new("TextLabel")
    bottomLabel.Name = "BottomLabel"
    bottomLabel.AnchorPoint = Vector2.new(0.5, 0)
    bottomLabel.Size = UDim2.new(0, 200, 0, 26)
    bottomLabel.Position = UDim2.new(0.5, 0, 1, 3)
    bottomLabel.BackgroundTransparency = 1
    bottomLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    bottomLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    bottomLabel.TextStrokeTransparency = 0
    bottomLabel.Font = Enum.Font.Gotham
    bottomLabel.TextSize = 11
    bottomLabel.TextXAlignment = Enum.TextXAlignment.Center
    bottomLabel.Text = ""
    bottomLabel.Parent = container

    local hl = Instance.new("Highlight")
    hl.Name = "Veil_Highlight"
    hl:SetAttribute(TAG_ID, true)
    hl.Adornee = model
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = State.ChamsTransparency or 0.7
    hl.OutlineTransparency = State.BoxGlow and 0.05 or 0.5
    hl.FillColor = hlColor
    hl.OutlineColor = boxBorderColor
    hl.Parent = GetUiContainer()

    local box3D = Create3DBoxAdornment(root, boxBorderColor)

    return {
        Container = container,
        BoxOuter = boxOuter,
        BoxInner = boxInner,
        HpBarBg = hpBarBg,
        HpBarFill = hpBarFill,
        HpNumber = hpNumber,
        NameLabel = nameLabel,
        BottomLabel = bottomLabel,
        Highlight = hl,
        Box3D = box3D,
        Model = model,
        Root = root,
        Humanoid = hum,
        IsPlayer = isPlayer,
        IsLocal = isLocal,
        BoxBorderColor = boxBorderColor
    }
end

local function ApplyEntityESP(model, isPlayer, isLocal)
    if not model or ActiveESP[model] or getgenv().Veil_Unloaded then return end
    local item = CreateShooterESP(model, isPlayer, isLocal)
    if item then
        ActiveESP[model] = item
    end
end

local function ApplyNpcESP(npc)
    if not npc or NpcESP[npc] or getgenv().Veil_Unloaded then return end
    local root = GetEntityRoot(npc)
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.Name = "Veil_NPCHighlight"
    hl:SetAttribute(TAG_ID, true)
    hl.Adornee = npc
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = Color3.fromRGB(60, 220, 120)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = State.ChamsTransparency or 0.7
    hl.OutlineTransparency = 0.1
    hl.Parent = GetUiContainer()

    local tag, lbl = CreateLootTag(root, npc.Name, Color3.fromRGB(60, 255, 140), "NPC")
    NpcESP[npc] = { Highlight = hl, Tag = tag, Label = lbl, Root = root }
end

local function GetItemRarity(item)
    if not item then return "Common" end
    local r = item:GetAttribute("Rarity")
    if r and type(r) == "string" and #r > 0 then
        return r
    end
    local rVal = item:FindFirstChild("Rarity")
    if rVal and rVal:IsA("ValueBase") and rVal.Value and tostring(rVal.Value) ~= "" then
        return tostring(rVal.Value)
    end
    local arg = item:FindFirstChild("Argument")
    if arg and arg:IsA("StringValue") and arg.Value and #arg.Value > 0 then
        local argR = arg:GetAttribute("Rarity")
        if argR then return tostring(argR) end
    end
    for _, child in ipairs(item:GetChildren()) do
        local cr = child:GetAttribute("Rarity")
        if cr and type(cr) == "string" and #cr > 0 then
            return cr
        end
    end
    return "Common"
end

local function GetRarityColor(rarityName)
    local r = string.lower(tostring(rarityName or "common")):gsub("%s+", "")
    if r == "common" then
        return State.RarityColorCommon or Color3.fromRGB(255, 255, 255)
    elseif r == "uncommon" then
        return State.RarityColorUncommon or Color3.fromRGB(50, 220, 50)
    elseif r == "rare" then
        return State.RarityColorRare or Color3.fromRGB(40, 140, 255)
    elseif r == "epic" or r == "elite" then
        return State.RarityColorEpic or Color3.fromRGB(170, 60, 240)
    elseif r == "legendary" then
        return State.RarityColorLegendary or Color3.fromRGB(255, 200, 0)
    elseif r == "mythic" or r == "godly" then
        return State.RarityColorMythic or Color3.fromRGB(255, 45, 45)
    end
    return State.RarityColorCommon or Color3.fromRGB(255, 255, 255)
end

local function HookNativeDropHighlight()
    local function hookDH()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local dh = pg and pg:FindFirstChild("DropHighlight")
        if dh and not dh:GetAttribute("Veil_RarityHooked") then
            dh:SetAttribute("Veil_RarityHooked", true)
            local function updateDH()
                if State.ItemProximityHighlight and dh.Adornee then
                    local rarity = GetItemRarity(dh.Adornee)
                    local col = GetRarityColor(rarity)
                    dh.OutlineColor = col
                end
            end
            table.insert(Connections, dh:GetPropertyChangedSignal("Adornee"):Connect(updateDH))
            table.insert(Connections, dh:GetPropertyChangedSignal("OutlineTransparency"):Connect(function()
                if State.ItemProximityHighlight and dh.Adornee and dh.OutlineTransparency < 0.9 then
                    local rarity = GetItemRarity(dh.Adornee)
                    local col = GetRarityColor(rarity)
                    dh.OutlineColor = col
                end
            end))
            if dh.Adornee then updateDH() end
        end
    end
    hookDH()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        table.insert(Connections, pg.ChildAdded:Connect(function(c)
            if c.Name == "DropHighlight" then
                task.delay(0.1, hookDH)
            end
        end))
    end
end

local function ApplyLootESP(drop)
    if not drop or LootESP[drop] or getgenv().Veil_Unloaded or IgnoreDropNames[drop.Name] then return end
    local root = drop:FindFirstChildWhichIsA("BasePart") or (drop:IsA("BasePart") and drop) or (drop:IsA("Model") and drop.PrimaryPart)
    if not root then return end

    local rarity = GetItemRarity(drop)
    local rarityColor = GetRarityColor(rarity)

    local hl = Instance.new("Highlight")
    hl.Name = "Veil_DropHighlight"
    hl:SetAttribute(TAG_ID, true)
    hl.Adornee = drop
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = rarityColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = State.ItemHighlightTrans or 0.6
    hl.OutlineTransparency = 0.2
    hl.Enabled = false
    pcall(function() hl.Parent = GetUiContainer() end)

    local tag, lbl = CreateLootTag(root, string.format("[%s] %s", rarity, drop.Name), rarityColor, "Item")
    LootESP[drop] = { Highlight = hl, Tag = tag, Label = lbl, Part = root, Rarity = rarity, LastColor = rarityColor }
end

local function ApplyTrinketESP(trinket)
    if not trinket or TrinketESP[trinket] or getgenv().Veil_Unloaded or IgnoreDropNames[trinket.Name] then return end
    local root = trinket:FindFirstChildWhichIsA("BasePart") or (trinket:IsA("BasePart") and trinket) or trinket.PrimaryPart
    if not root then return end

    local rarity = GetItemRarity(trinket)
    local color = (rarity and rarity ~= "Common" and GetRarityColor(rarity)) or State.RarityColorEpic

    local hl = Instance.new("Highlight")
    hl.Name = "Veil_TrinketHighlight"
    hl:SetAttribute(TAG_ID, true)
    hl.Adornee = trinket
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = State.ItemHighlightTrans or 0.6
    hl.OutlineTransparency = 0.2
    hl.Enabled = false
    pcall(function() hl.Parent = GetUiContainer() end)

    local tag, lbl = CreateLootTag(root, string.format("[%s] %s", rarity or "Relic", trinket.Name), color, "Relic")
    TrinketESP[trinket] = { Highlight = hl, Tag = tag, Label = lbl, Part = root, Rarity = rarity, LastColor = color }
end

local function ApplyChestESP(chest, customName)
    if not chest or ChestESP[chest] or getgenv().Veil_Unloaded then return end
    local n = (customName or chest.Name or ""):lower()
    if n:find("crate") or n:find("barrel") or n:find("urn") or n:find("plate") or n:find("door") or n:find("wall") or n:find("house") or n:find("tavern") then
        return
    end

    local root = chest:FindFirstChild("Main") or chest:FindFirstChildWhichIsA("BasePart") or (chest:IsA("BasePart") and chest) or chest.PrimaryPart
    if not root then return end

    local color = State.ChestESPColor or Color3.fromRGB(255, 170, 0)
    local name = customName or chest.Name or "Chest"

    local hl = Instance.new("Highlight")
    hl.Name = "Veil_ChestHighlight"
    hl:SetAttribute(TAG_ID, true)
    hl.Adornee = chest
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = State.ItemHighlightTrans or 0.6
    hl.OutlineTransparency = 0.2
    hl.Enabled = false
    pcall(function() hl.Parent = GetUiContainer() end)

    local tag, lbl = CreateLootTag(root, name, color, "Chest")
    ChestESP[chest] = { Highlight = hl, Tag = tag, Label = lbl, Part = root, Name = name, LastColor = color }
end

local EspWasActive = false
local LastESPUpdateTick = 0

local function UpdateAllESP()
    if getgenv().Veil_Unloaded then return end

    local anyEspActive = State.PlayerESP or State.MobESP or State.LocalPlayerESP or State.NpcESP or State.DropESP or State.TrinketESP or State.ChestESP
    if not anyEspActive then
        if EspWasActive then
            EspWasActive = false
            for _, esp in pairs(ActiveESP) do
                if esp.Container and esp.Container.Visible then esp.Container.Visible = false end
                if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                if esp.Box3D and esp.Box3D.Visible then esp.Box3D.Visible = false end
            end
            for _, esp in pairs(NpcESP) do
                if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
            end
            for _, esp in pairs(LootESP) do
                if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
            end
            for _, esp in pairs(TrinketESP) do
                if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
            end
            for _, esp in pairs(ChestESP) do
                if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
            end
        end
        return
    end

    EspWasActive = true

    -- Purge rapide des instances détruites
    for m in pairs(ActiveESP) do
        if not m.Parent then RemoveESP(m) end
    end
    for n in pairs(NpcESP) do if not n.Parent then RemoveNpcESP(n) end end
    for d in pairs(LootESP) do if not d.Parent then RemoveDropESP(d) end end
    for c in pairs(ChestESP) do if not c.Parent then RemoveChestESP(c) end end
    for t in pairs(TrinketESP) do if not t.Parent then RemoveTrinketESP(t) end end

    local cam = Camera or workspace.CurrentCamera
    if not cam then return end
    local camCF = cam.CFrame
    local camPos = camCF.Position
    local camLook = camCF.LookVector

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position or camPos

    local maxDist = State.MaxESPDistance or 300
    local nowTick = tick()
    local shouldUpdateText = (nowTick - (getgenv().__LastEspTextTick or 0) >= 0.25)
    if shouldUpdateText then
        getgenv().__LastEspTextTick = nowTick
    end

    local drawnEntities = 0
    for model, esp in pairs(ActiveESP) do
        if not model or not model.Parent or not esp.Humanoid or not esp.Root or esp.Humanoid.Health <= 0 then
            RemoveESP(model)
        else
            local active = false
            if esp.IsLocal then
                active = State.LocalPlayerESP
            elseif esp.IsPlayer then
                active = State.PlayerESP
            else
                active = State.MobESP
            end

            local dist = (myPos - esp.Root.Position).Magnitude
            if not active or dist > maxDist or drawnEntities >= 25 then
                if esp.Container and esp.Container.Visible then esp.Container.Visible = false end
                if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                if esp.Box3D and esp.Box3D.Visible then esp.Box3D.Visible = false end
            else
                drawnEntities = drawnEntities + 1
                if esp.Highlight then
                    if esp.Highlight.Enabled ~= State.Chams then esp.Highlight.Enabled = State.Chams end
                    if esp.LastChamsTrans ~= State.ChamsTransparency then
                        esp.LastChamsTrans = State.ChamsTransparency
                        esp.Highlight.FillTransparency = State.ChamsTransparency
                    end
                end
                if esp.Box3D then
                    if esp.Box3D.Visible ~= State.Boxes3D then esp.Box3D.Visible = State.Boxes3D end
                end

                local toTarget = (esp.Root.Position - camPos)
                local isForward = (toTarget:Dot(camLook) > 0)

                if not isForward then
                    if esp.Container.Visible then esp.Container.Visible = false end
                else
                    local rootPos3D = esp.Root.Position
                    local top3D, btm3D = GetModelBounds(model, esp.Root)

                    local sTop, onTop = cam:WorldToViewportPoint(top3D)
                    local sBtm, onBtm = cam:WorldToViewportPoint(btm3D)
                    local sRoot, onRoot = cam:WorldToViewportPoint(rootPos3D)

                    if sRoot.Z <= 0.5 then
                        if esp.Container.Visible then esp.Container.Visible = false end
                    else
                        local rawHeight = math.abs(sBtm.Y - sTop.Y)
                        local boxHeight = math.clamp(rawHeight, 6, 2500)
                        local boxWidth = math.clamp(boxHeight * 0.60, 4, 1500)
                        local centerX = sRoot.X
                        local topY = math.min(sTop.Y, sBtm.Y)
                        local leftX = math.floor(centerX - (boxWidth * 0.5))
                        local flTopY = math.floor(topY)
                        local flW = math.floor(boxWidth)
                        local flH = math.floor(boxHeight)

                        if esp.LastPosX ~= leftX or esp.LastPosY ~= flTopY or esp.LastW ~= flW or esp.LastH ~= flH then
                            esp.LastPosX = leftX
                            esp.LastPosY = flTopY
                            esp.LastW = flW
                            esp.LastH = flH
                            esp.Container.Position = UDim2.new(0, leftX, 0, flTopY)
                            esp.Container.Size = UDim2.new(0, flW, 0, flH)
                        end
                        if not esp.Container.Visible then esp.Container.Visible = true end

                        if esp.BoxOuter.Visible ~= State.ESPBoxes then esp.BoxOuter.Visible = State.ESPBoxes end
                        if esp.BoxInner and esp.BoxInner.Visible ~= State.ESPBoxes then esp.BoxInner.Visible = State.ESPBoxes end

                        local curHp = math.floor(math.clamp(esp.Humanoid.Health, 0, esp.Humanoid.MaxHealth))
                        local maxHp = math.max(math.floor(esp.Humanoid.MaxHealth), 1)

                        if State.HealthBars then
                            if not esp.HpBarBg.Visible then esp.HpBarBg.Visible = true end
                            if esp.LastHp ~= curHp or esp.LastMaxHp ~= maxHp then
                                esp.LastHp = curHp
                                esp.LastMaxHp = maxHp
                                local pct = math.clamp(curHp / maxHp, 0, 1)
                                esp.HpBarFill.Size = UDim2.new(1, 0, pct, 0)
                                esp.HpBarFill.Position = UDim2.new(0, 0, 1 - pct, 0)

                                local hpColor
                                if pct > 0.60 then
                                    hpColor = Color3.fromRGB(75, 230, 95)
                                elseif pct > 0.25 then
                                    hpColor = Color3.fromRGB(255, 160, 25)
                                else
                                    hpColor = Color3.fromRGB(245, 50, 50)
                                end
                                esp.HpBarFill.BackgroundColor3 = hpColor

                                esp.HpNumber.Position = UDim2.new(0, -34, 1 - pct, -6)
                                esp.HpNumber.Text = tostring(curHp)
                            end
                            if not esp.HpNumber.Visible then esp.HpNumber.Visible = true end
                        else
                            if esp.HpBarBg.Visible then esp.HpBarBg.Visible = false end
                            if esp.HpNumber.Visible then esp.HpNumber.Visible = false end
                        end

                        if State.Names then
                            if not esp.NameLabel.Visible then esp.NameLabel.Visible = true end
                            if not esp.NameCached then
                                local displayName = model.Name
                                if esp.IsPlayer then
                                    local plr = Players:GetPlayerFromCharacter(model)
                                    if plr and plr.DisplayName and plr.DisplayName ~= plr.Name then
                                        displayName = string.format("%s\n%s", plr.DisplayName, plr.Name)
                                    end
                                end
                                esp.NameLabel.Text = displayName
                                esp.NameCached = true
                            end
                        else
                            if esp.NameLabel.Visible then esp.NameLabel.Visible = false end
                        end

                        local showDist = State.Distance
                        local showWeap = State.Weapons
                        if showDist or showWeap then
                            local roundedDist = math.floor(dist * 0.2) * 5
                            local heldTool = showWeap and model:FindFirstChildWhichIsA("Tool")
                            local weapName = heldTool and heldTool.Name or ""

                            if esp.LastDistVal ~= roundedDist or esp.LastWeapVal ~= weapName then
                                esp.LastDistVal = roundedDist
                                esp.LastWeapVal = weapName

                                local distStr = showDist and (tostring(roundedDist) .. "st") or nil
                                local weapStr = showWeap and (weapName ~= "" and weapName or nil) or nil

                                if distStr and weapStr then
                                    esp.BottomLabel.Text = distStr .. "\n" .. weapStr
                                elseif distStr then
                                    esp.BottomLabel.Text = distStr
                                elseif weapStr then
                                    esp.BottomLabel.Text = weapStr
                                else
                                    esp.BottomLabel.Text = ""
                                end
                            end
                            if not esp.BottomLabel.Visible then esp.BottomLabel.Visible = true end
                        else
                            if esp.BottomLabel.Visible then esp.BottomLabel.Visible = false end
                        end
                    end
                end
            end
        end
    end

    if State.NpcESP then
        for npc, esp in pairs(NpcESP) do
            if not npc or not npc.Parent or not esp.Root then
                RemoveNpcESP(npc)
            else
                local dist = (myPos - esp.Root.Position).Magnitude
                if dist > maxDist then
                    if esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                    if esp.Tag.Enabled then esp.Tag.Enabled = false end
                else
                    if esp.Highlight.Enabled ~= State.Chams then esp.Highlight.Enabled = State.Chams end
                    if esp.Tag.Enabled ~= State.Names then esp.Tag.Enabled = State.Names end
                    if shouldUpdateText then
                        esp.Label.Text = State.Distance and string.format("%s - %dst", npc.Name, math.floor(dist)) or npc.Name
                    end
                end
            end
        end
    else
        for _, esp in pairs(NpcESP) do
            if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
            if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
        end
    end

    local MAX_ACTIVE_ITEM_HIGHLIGHTS = 8
    local MAX_HIGHLIGHT_DIST = 100
    local activeHighlights = 0

    if State.DropESP then
        for drop, esp in pairs(LootESP) do
            if not drop or not drop.Parent or not esp.Part then
                RemoveDropESP(drop)
            else
                local dist = (myPos - esp.Part.Position).Magnitude
                if dist > maxDist then
                    RemoveDropESP(drop)
                else
                    local rarity = esp.Rarity or GetItemRarity(drop)
                    local col = GetRarityColor(rarity)
                    if esp.Highlight then
                        local wantHl = (State.ItemHighlights or State.Chams) and (dist <= MAX_HIGHLIGHT_DIST) and (activeHighlights < MAX_ACTIVE_ITEM_HIGHLIGHTS)
                        if wantHl then
                            activeHighlights = activeHighlights + 1
                            if not esp.Highlight.Enabled then esp.Highlight.Enabled = true end
                            if esp.LastColor ~= col then
                                esp.Highlight.FillColor = col
                                if esp.Label then esp.Label.TextColor3 = col end
                                esp.LastColor = col
                            end
                        else
                            if esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                        end
                    end
                    if esp.Tag then
                        if not esp.Tag.Enabled then esp.Tag.Enabled = true end
                        if shouldUpdateText then
                            local baseText = string.format("[%s] %s", rarity, drop.Name)
                            esp.Label.Text = State.Distance and string.format("%s - %dst", baseText, math.floor(dist)) or baseText
                        end
                    end
                end
            end
        end
    else
        for _, esp in pairs(LootESP) do
            if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
            if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
        end
    end

    if State.TrinketESP then
        for tr, esp in pairs(TrinketESP) do
            if not tr or not tr.Parent or not esp.Part then
                RemoveTrinketESP(tr)
            else
                local dist = (myPos - esp.Part.Position).Magnitude
                if dist > maxDist then
                    RemoveTrinketESP(tr)
                else
                    local rarity = esp.Rarity or GetItemRarity(tr)
                    local col = (rarity and rarity ~= "Common" and GetRarityColor(rarity)) or State.RarityColorEpic
                    if esp.Highlight then
                        local wantHl = (State.ItemHighlights or State.Chams) and (dist <= MAX_HIGHLIGHT_DIST) and (activeHighlights < MAX_ACTIVE_ITEM_HIGHLIGHTS)
                        if wantHl then
                            activeHighlights = activeHighlights + 1
                            if not esp.Highlight.Enabled then esp.Highlight.Enabled = true end
                            if esp.LastColor ~= col then
                                esp.Highlight.FillColor = col
                                if esp.Label then esp.Label.TextColor3 = col end
                                esp.LastColor = col
                            end
                        else
                            if esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                        end
                    end
                    if esp.Tag then
                        if not esp.Tag.Enabled then esp.Tag.Enabled = true end
                        if shouldUpdateText then
                            local baseText = string.format("[%s] %s", rarity or "Relic", tr.Name)
                            esp.Label.Text = State.Distance and string.format("%s - %dst", baseText, math.floor(dist)) or baseText
                        end
                    end
                end
            end
        end
    else
        for _, esp in pairs(TrinketESP) do
            if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
            if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
        end
    end

    if State.ChestESP then
        for c, esp in pairs(ChestESP) do
            if not c or not c.Parent or not esp.Part then
                RemoveChestESP(c)
            else
                local dist = (myPos - esp.Part.Position).Magnitude
                if dist > maxDist then
                    RemoveChestESP(c)
                else
                    local col = State.ChestESPColor or Color3.fromRGB(255, 170, 0)
                    if esp.Highlight then
                        local wantHl = (State.ItemHighlights or State.Chams) and (dist <= MAX_HIGHLIGHT_DIST) and (activeHighlights < MAX_ACTIVE_ITEM_HIGHLIGHTS)
                        if wantHl then
                            activeHighlights = activeHighlights + 1
                            if not esp.Highlight.Enabled then esp.Highlight.Enabled = true end
                            if esp.LastColor ~= col then
                                esp.Highlight.FillColor = col
                                if esp.Label then esp.Label.TextColor3 = col end
                                esp.LastColor = col
                            end
                        else
                            if esp.Highlight.Enabled then esp.Highlight.Enabled = false end
                        end
                    end
                    if esp.Tag then
                        if not esp.Tag.Enabled then esp.Tag.Enabled = true end
                        if shouldUpdateText then
                            local baseText = string.format("[Chest] %s", esp.Name or c.Name)
                            esp.Label.Text = State.Distance and string.format("%s - %dst", baseText, math.floor(dist)) or baseText
                        end
                    end
                end
            end
        end
    else
        for _, esp in pairs(ChestESP) do
            if esp.Highlight and esp.Highlight.Enabled then esp.Highlight.Enabled = false end
            if esp.Tag and esp.Tag.Enabled then esp.Tag.Enabled = false end
        end
    end
end

local function ScanWorldESP()
    if getgenv().Veil_Unloaded then return end
    local anyEspActive = State.PlayerESP or State.MobESP or State.LocalPlayerESP or State.NpcESP or State.DropESP or State.TrinketESP or State.ChestESP
    if not anyEspActive then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = root and root.Position or (Camera and Camera.CFrame.Position)
    if not myPos then return end

    local maxDist = State.MaxESPDistance or 300

    if State.LocalPlayerESP and LocalPlayer.Character then
        ApplyEntityESP(LocalPlayer.Character, false, true)
    end

    if State.PlayerESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local pRoot = GetEntityRoot(plr.Character)
                if pRoot and (myPos - pRoot.Position).Magnitude <= maxDist then
                    ApplyEntityESP(plr.Character, true, false)
                end
            end
        end
    end

    if State.MobESP then
        local mobs = GetAllActiveMonsters()
        for _, mob in ipairs(mobs) do
            local _, mRoot = GetMobHumanoidAndRoot(mob)
            if mRoot and (myPos - mRoot.Position).Magnitude <= maxDist then
                ApplyEntityESP(mob, false, false)
            end
        end
    end

    if State.NpcESP and NPCFolder then
        local count = 0
        for _, npc in pairs(NPCFolder:GetChildren()) do
            local nRoot = GetEntityRoot(npc)
            if nRoot and (myPos - nRoot.Position).Magnitude <= maxDist then
                ApplyNpcESP(npc)
                count = count + 1
                if count >= 20 then break end
            end
        end
    end

    if State.DropESP then
        local count = 0
        local dropFolders = { DropsFolder, workspace:FindFirstChild("Items"), workspace:FindFirstChild("Loot"), workspace:FindFirstChild("WorldDrops") }
        for _, df in ipairs(dropFolders) do
            if df then
                for _, drop in pairs(df:GetChildren()) do
                    local p = drop:FindFirstChildWhichIsA("BasePart") or (drop:IsA("BasePart") and drop) or (drop:IsA("Model") and drop.PrimaryPart)
                    if p and (myPos - p.Position).Magnitude <= maxDist then
                        ApplyLootESP(drop)
                        count = count + 1
                        if count >= 35 then break end
                    end
                end
            end
            if count >= 35 then break end
        end
    end

    if State.TrinketESP then
        local count = 0
        local trinketFolders = { TrinketFolder, workspace:FindFirstChild("Trinkets"), workspace:FindFirstChild("Relics") }
        for _, tf in ipairs(trinketFolders) do
            if tf then
                for _, tr in pairs(tf:GetChildren()) do
                    local p = tr:FindFirstChildWhichIsA("BasePart") or (tr:IsA("BasePart") and tr) or (tr:IsA("Model") and tr.PrimaryPart)
                    if p and (myPos - p.Position).Magnitude <= maxDist then
                        ApplyTrinketESP(tr)
                        count = count + 1
                        if count >= 20 then break end
                    end
                end
            end
            if count >= 20 then break end
        end
    end

    if State.ChestESP then
        UpdateChestCache()
        local count = 0
        for _, chest in ipairs(CachedChests) do
            if chest.Object and chest.Part and (myPos - chest.Part.Position).Magnitude <= maxDist then
                ApplyChestESP(chest.Object, chest.Name)
                count = count + 1
                if count >= 35 then break end
            end
        end
    end
end

-- ================================================
--  FARM & COMBAT EXECUTION ENGINES
-- ================================================
local LastAttackTick = 0
local LastM2Tick = 0
local LastDashTick = 0
local LastAbilityTick = 0

local function GetClosestTargetMob()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end

    local allMobs = GetAllActiveMonsters()
    local closestMob = nil
    local shortestDist = math.huge

    for _, mob in ipairs(allMobs) do
        local matches = (State.SelectedMobTarget == "All Mobs") or (mob.Name == State.SelectedMobTarget and State.SelectedMobTarget ~= "No Mobs Spawned")
        if matches then
            local hum, mRoot = GetMobHumanoidAndRoot(mob)
            if hum and mRoot and hum.Health > 0 then
                local dist = (root.Position - mRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestMob = mob
                end
            end
        end
    end
    return closestMob, shortestDist
end

local function GetClosestTargetPlayer()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end

    local closestPlr = nil
    local shortestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if State.SelectedPlayerTarget == "Nearest" or plr.Name == State.SelectedPlayerTarget then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local pRoot = GetEntityRoot(plr.Character)
                if hum and pRoot and hum.Health > 0 then
                    local dist = (root.Position - pRoot.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPlr = plr.Character
                    end
                end
            end
        end
    end
    return closestPlr, shortestDist
end

-- ================================================
--  AUTO SELL / TRASH
-- ================================================
local IsAutoSelling = false
local function ExecuteAutoSell()
    if IsAutoSelling then return end
    IsAutoSelling = true
    local toSell = {}
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local inv = pg and pg:FindFirstChild("InventoryGui")

    if inv then
        for i = 1, 40 do
            local slot = inv:FindFirstChild("InvSlot_" .. i, true)
            if slot then
                local toolRef = slot:FindFirstChild("ToolRef")
                local fav = slot:FindFirstChild("FavoriteLabel")
                local isFav = fav and fav.Visible or false
                if toolRef and toolRef.Value and not isFav then
                    local isEquipped = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(toolRef.Value.Name)
                    if not isEquipped then
                        table.insert(toSell, toolRef.Value)
                    end
                end
            end
        end
    end

    if LocalPlayer:FindFirstChild("Backpack") then
        local seen = {}
        for _, t in ipairs(toSell) do seen[t] = true end
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and not seen[item] then
                table.insert(toSell, item)
            end
        end
    end

    if #toSell == 0 then
        IsAutoSelling = false
        return
    end

    local merchantSellMode = Remotes and Remotes:FindFirstChild("MerchantSellMode")
    if merchantSellMode then
        pcall(function() merchantSellMode:Fire(true) end)
    end

    local sellItemsRemote = Remotes and Remotes:FindFirstChild("SellItemsEvent")
    if sellItemsRemote then
        task.spawn(function()
            local sold = 0
            for i = 1, #toSell, 4 do
                if getgenv().Veil_Unloaded then break end
                local batch = {}
                for j = i, math.min(i + 3, #toSell) do
                    table.insert(batch, toSell[j])
                end
                pcall(function() sellItemsRemote:FireServer(batch) end)
                sold = sold + #batch
                task.wait(0.10)
            end
            NotifyUser("NW Hub | Auto Sell", string.format("Sold %d items.", sold), 3)
            IsAutoSelling = false
        end)
    else
        IsAutoSelling = false
    end
end

local function TrashAllJunk()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local dropped = 0
    local junkKeywords = {
        "junk", "scrap", "trash", "rock", "pebble", "wood", "broken",
        "rusty", "tattered", "cracked", "old", "bone", "tooth", "claw",
        "shard", "fragment", "remnant", "dirt", "twig", "feather", "common", "shabby"
    }

    local trashRemote = TrashItemsRemote or (Remotes and Remotes:FindFirstChild("TrashItemsEvent"))
    local dropRemote = Remotes and (Remotes:FindFirstChild("DropItemEvent") or Remotes:FindFirstChild("DropItem") or Remotes:FindFirstChild("Drop") or Remotes:FindFirstChild("DiscardItem"))

    local junkBatch = {}
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                local isJunk = false
                for _, kw in ipairs(junkKeywords) do
                    if n:find(kw) then
                        isJunk = true
                        break
                    end
                end
                if isJunk then
                    table.insert(junkBatch, item)
                    dropped = dropped + 1
                end
            end
        end
    end

    if #junkBatch > 0 then
        if trashRemote then
            pcall(function() trashRemote:FireServer(junkBatch) end)
        else
            for _, item in ipairs(junkBatch) do
                if dropRemote then pcall(function() dropRemote:FireServer(item) end) end
                pcall(function() item.Parent = workspace end)
            end
        end
    end
    NotifyUser("NW Hub | Trash", string.format("Trashed %d junk items.", dropped), 3)
end

-- ================================================
--  CROSSHAIR
-- ================================================
local CrosshairGui = nil
local function UpdateCrosshairUI()
    if getgenv().Veil_Unloaded then
        if CrosshairGui then CrosshairGui:Destroy() CrosshairGui = nil end
        return
    end

    if State.Crosshair or State.CursorRing then
        if not CrosshairGui then
            CrosshairGui = Instance.new("ScreenGui")
            CrosshairGui.Name = "_veil_ch_" .. HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 8)
            CrosshairGui.ResetOnSpawn = false
            CrosshairGui.DisplayOrder = 999999
            ProtectInstance(CrosshairGui)
            pcall(function() CrosshairGui.Parent = GetUiContainer() end)

            local chDot = Instance.new("Frame")
            chDot.Name = "CrosshairDot"
            chDot.Size = UDim2.new(0, 8, 0, 8)
            chDot.Position = UDim2.new(0.5, -4, 0.5, -4)
            chDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            chDot.BorderSizePixel = 0
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = chDot
            chDot.Parent = CrosshairGui

            local ring = Instance.new("ImageLabel")
            ring.Name = "CursorRing"
            ring.Size = UDim2.new(0, 32, 0, 32)
            ring.Position = UDim2.new(0.5, -16, 0.5, -16)
            ring.BackgroundTransparency = 1
            ring.Image = "rbxassetid://3570695787"
            ring.ImageColor3 = Color3.fromRGB(255, 255, 255)
            ring.Parent = CrosshairGui
        end

        local dot = CrosshairGui:FindFirstChild("CrosshairDot")
        if dot then dot.Visible = State.Crosshair end
        local r = CrosshairGui:FindFirstChild("CursorRing")
        if r then r.Visible = State.CursorRing end
    else
        if CrosshairGui then
            CrosshairGui:Destroy()
            CrosshairGui = nil
        end
    end
end

-- ================================================
--  BACKGROUND TASKS
-- ================================================
task.spawn(function()
    while not getgenv().Veil_Unloaded do
        if State.AutoSellLoop then
            pcall(ExecuteAutoSell)
        end
        task.wait(10.0)
    end
end)

task.spawn(function()
    while not getgenv().Veil_Unloaded do
        if State.CloseDialogue then
            pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, g in ipairs(pg:GetChildren()) do
                        if g:IsA("ScreenGui") then
                            local gn = g.Name:lower()
                            if gn:find("dialog") or gn:find("talk") or gn:find("speech") or gn:find("conversation") then
                                g.Enabled = false
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.6)
    end
end)

task.spawn(function()
    while not getgenv().Veil_Unloaded do
        if State.TrinketFarm and not IsCollectingTrinkets then
            pcall(CollectAllMapTrinkets)
        end
        task.wait(2.0)
    end
end)

-- ================================================
--  SILENT AIM (FIXED ORDER)
-- ================================================
local SilentAimFOVCircle = nil
local SilentAimTracerLine = nil
local LastBossSummonTick = 0
local LastInfWeaveTick = 0
local OriginalDashConfigs = nil

pcall(function()
    if Drawing and Drawing.new then
        SilentAimFOVCircle = Drawing.new("Circle")
        SilentAimFOVCircle.Thickness = 1.5
        SilentAimFOVCircle.NumSides = 36
        SilentAimFOVCircle.Radius = State.SilentAimFOV or 180
        SilentAimFOVCircle.Filled = false
        SilentAimFOVCircle.Transparency = 0.7
        SilentAimFOVCircle.Color = Color3.fromRGB(120, 160, 255)
        SilentAimFOVCircle.Visible = false

        SilentAimTracerLine = Drawing.new("Line")
        SilentAimTracerLine.Thickness = 1.5
        SilentAimTracerLine.Transparency = 0.8
        SilentAimTracerLine.Color = Color3.fromRGB(255, 80, 80)
        SilentAimTracerLine.Visible = false
    end
end)

local LastSilentAimTick = 0
local CachedSilentAimTarget = nil

local function GetSilentAimTarget()
    local now = tick()
    if now - LastSilentAimTick < 0.05 then
        return CachedSilentAimTarget
    end
    LastSilentAimTick = now

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        CachedSilentAimTarget = nil
        return nil
    end

    local cam = workspace.CurrentCamera
    if not cam then
        CachedSilentAimTarget = nil
        return nil
    end

    local mousePos
    if UserInputService.MouseEnabled then
        mousePos = UserInputService:GetMouseLocation()
    else
        local vp = cam.ViewportSize
        mousePos = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    end

    local bestPart = nil
    local shortestDist = State.SilentAimFOV or 180

    local function evalEntity(ent)
        if not ent or ent == char then return end
        local hum = ent:FindFirstChildOfClass("Humanoid") or ent:FindFirstChild("Enemy")
        if not hum or hum.Health <= 0 then return end

        local targetPart = ent:FindFirstChild(State.SilentAimTarget or "Head")
            or ent:FindFirstChild("HumanoidRootPart")
            or ent:FindFirstChild("Torso")
        if not targetPart then return end

        local sPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
        if not onScreen or sPos.Z <= 0 then return end

        local sVec = Vector2.new(sPos.X, sPos.Y)
        local dist = (mousePos - sVec).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            bestPart = targetPart
        end
    end

    if State.SilentAimMode == "Mobs & Players" or State.SilentAimMode == "Mobs Only" then
        for _, mob in ipairs(GetAllActiveMonsters()) do
            evalEntity(mob)
        end
    end

    if State.SilentAimMode == "Mobs & Players" or State.SilentAimMode == "Players Only" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                evalEntity(plr.Character)
            end
        end
    end

    CachedSilentAimTarget = bestPart
    return bestPart
end

RunService.RenderStepped:Connect(function()
    if getgenv().Veil_Unloaded then
        if SilentAimFOVCircle then pcall(function() SilentAimFOVCircle:Remove() end) end
        if SilentAimTracerLine then pcall(function() SilentAimTracerLine:Remove() end) end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local mousePos = UserInputService.MouseEnabled and UserInputService:GetMouseLocation() or (cam.ViewportSize * 0.5)

    if SilentAimFOVCircle then
        SilentAimFOVCircle.Visible = State.SilentAim and State.SilentAimShowFOV
        if SilentAimFOVCircle.Visible then
            SilentAimFOVCircle.Position = mousePos
            SilentAimFOVCircle.Radius = State.SilentAimFOV or 180
        end
    end

    if SilentAimTracerLine then
        local target = State.SilentAim and State.SilentAimShowLine and GetSilentAimTarget()
        if target then
            local tPos, onScreen = cam:WorldToViewportPoint(target.Position)
            if onScreen and tPos.Z > 0 then
                SilentAimTracerLine.From = mousePos
                SilentAimTracerLine.To = Vector2.new(tPos.X, tPos.Y)
                SilentAimTracerLine.Visible = true
            else
                SilentAimTracerLine.Visible = false
            end
        else
            SilentAimTracerLine.Visible = false
        end
    end
end)

pcall(function()
    local AimMod = require(ReplicatedStorage.Assets.Scripts.AimCFrame)
    if AimMod and not AimMod.__NW_Hooked then
        AimMod.__NW_Hooked = true
        local origGet = AimMod.Get
        AimMod.Get = function(...)
            if State.SilentAim then
                local target = GetSilentAimTarget()
                if target then
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local origin = myRoot.Position + Vector3.new(0, 1.2, 0)
                        return CFrame.lookAt(origin, target.Position)
                    end
                end
            end
            return origGet(...)
        end
    end
end)

-- ================================================
--  BOSS & FARMING PROCESS
-- ================================================
local function FindCellOfLifeBoss()
    for _, mob in ipairs(GetAllActiveMonsters(true)) do
        local n = mob.Name:lower()
        if n:find("cell") or n:find("cradle") or n:find("genesis") then
            local hum, mRoot = GetMobHumanoidAndRoot(mob)
            if hum and hum.Health > 0 and mRoot then
                return mob, hum, mRoot
            end
        end
    end
    if MonstersFolder then
        for _, c in ipairs(MonstersFolder:GetChildren()) do
            local n = c.Name:lower()
            if n:find("cell") or n:find("cradle") or n:find("genesis") then
                local hum, mRoot = GetMobHumanoidAndRoot(c)
                if hum and hum.Health > 0 and mRoot then
                    return c, hum, mRoot
                end
            end
        end
    end
    return nil, nil, nil
end

local function ProcessFarming()
    if getgenv().Veil_Unloaded then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if State.AutoEquip then
        GetDesiredWeapon()
    end

    if State.NoDashCooldown then
        local dRemote = DashRemote or (Remotes and Remotes:FindFirstChild("DashEvent"))
        if dRemote then
            local now = tick()
            if now - LastDashTick > 0.15 then
                LastDashTick = now
                pcall(function() dRemote:FireServer() end)
            end
        end
    end

    if State.AutoAbility then
        local now = tick()
        if now - LastAbilityTick > 1.0 then
            LastAbilityTick = now
            pcall(function()
                local ActionsMod = require(ReplicatedStorage.Assets.Scripts.Actions)
                for _, ab in ipairs({"AbilityR", "AbilityT", "AbilityV", "AbilityY", "AbilityU", "ClassAbility"}) do
                    pcall(function() ActionsMod.Fire(ab) end)
                end
            end)
            if Remotes then
                local equippedTool = char:FindFirstChildWhichIsA("Tool")
                for _, remName in ipairs({"RAbilityEvent", "TAbilityEvent", "VAbilityEvent", "YAbilityEvent", "UAbilityEvent"}) do
                    local ev = Remotes:FindFirstChild(remName)
                    if ev and ev:IsA("RemoteEvent") then
                        pcall(function() ev:FireServer(equippedTool) end)
                    end
                end
            end
        end
    end

    if State.InfWeave then
        pcall(function() char:SetAttribute("WeaveCdUntil", 0) end)
        local now = tick()
        if now - LastInfWeaveTick > 0.35 then
            LastInfWeaveTick = now
            local wRem = Remotes and Remotes:FindFirstChild("WeaveEvent")
            if wRem then pcall(function() wRem:FireServer() end) end
        end
    end

    local now = tick()
    if State.Instakill or State.AutoM1 then
        local effectiveAttackSpeed = State.Instakill and 0.18 or State.AttackSpeed
        if now - LastAttackTick >= effectiveAttackSpeed then
            LastAttackTick = now
            local targetMob, _ = GetClosestTargetMob()
            local mRoot = targetMob and select(2, GetMobHumanoidAndRoot(targetMob))
            if mRoot then
                PerformStrike(mRoot, State.AutoCritical or State.Instakill)
            else
                PerformStrike(nil, State.AutoCritical or State.Instakill)
            end
        end
    end

    if (State.AutoCritical or State.AutoM2) and not State.Instakill and not State.AutoM1 then
        if now - LastM2Tick >= (State.AttackSpeed + 0.4) then
            LastM2Tick = now
            local targetMob, _ = GetClosestTargetMob()
            local mRoot = targetMob and select(2, GetMobHumanoidAndRoot(targetMob))
            PerformStrike(mRoot, true)
        end
    end
end

-- ================================================
--  LOOTING & CHESTS PROCESS
-- ================================================
local LastLootScan = 0

local LootCandidateFolders = {
    DropsFolder,
    TrinketFolder,
    workspace:FindFirstChild("Trinkets"),
    workspace:FindFirstChild("Items"),
    workspace:FindFirstChild("Loot"),
    workspace:FindFirstChild("Relics"),
    workspace:FindFirstChild("WorldDrops"),
    workspace:FindFirstChild("Spawns")
}

local function ProcessLootAndChests()
    if getgenv().Veil_Unloaded then return end
    if not (State.AutoPickup or State.AutoOpenChests) then return end
    local now = tick()
    if now - LastLootScan < 0.50 then return end
    LastLootScan = now

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if State.AutoPickup then
        for _, folder in ipairs(LootCandidateFolders) do
            if folder then
                for _, item in ipairs(folder:GetChildren()) do
                    if not IgnoreDropNames[item.Name] and not PickedUpDrops[item] then
                        local pos = nil
                        local p = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item) or item.PrimaryPart
                        if p then
                            pos = p.Position
                        else
                            local ok, piv = pcall(function() return item:GetPivot() end)
                            if ok and piv then pos = piv.Position end
                        end
                        if pos and (root.Position - pos).Magnitude <= State.PickupRadius then
                            SafePickupItem(item)
                        end
                    end
                end
            end
        end
    end

    if State.AutoOpenChests then
        UpdateChestCache()
        for _, chest in ipairs(CachedChests) do
            if chest.Part and (chest.Prompt or chest.Object) then
                local dist = (root.Position - chest.Part.Position).Magnitude
                if dist <= 65 then
                    if chest.Prompt and chest.Prompt.Parent then
                        TriggerPrompt(chest.Prompt)
                    elseif chest.Object and chest.Object:FindFirstChild("Argument") and InteractRemote then
                        pcall(function()
                            InteractRemote:FireServer("OpenChest", chest.Object)
                        end)
                    end
                    FireTouch(chest.Part)
                end
            end
        end
    end
end

-- ================================================
--  PLAYER UTILITIES (FLY FIXED — CFrame-stepping, no BodyMovers)
-- ================================================
local BodyVel = nil
local BodyGyroInstance = nil

-- FIX #1: Fly no longer uses BodyVelocity/BodyGyro (detected by anti-cheat).
-- Uses CFrame-stepping capped at 75 studs/sec — same ceiling as SafeTeleportTo,
-- which is known to bypass the server's position check.
local function ToggleFlight(enable)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if enable then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
        end)
    else
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end)
    end
end

-- ================================================
--  DEFENSE ASSIST
-- ================================================
local KNOWN_ATTACK_ANIM_IDS = {
    ["111120198567964"] = true, ["107426583476702"] = true, ["101964986658271"] = true,
    ["122717912255850"] = true, ["78574776378072"]  = true, ["88334964131672"]  = true,
    ["119026980386875"] = true, ["124115242283206"] = true, ["85523425543983"]  = true,
    ["72331806081797"]  = true, ["83737908105165"]  = true, ["109112325741730"] = true,
    ["134789813912995"] = true,
}

local ATTACK_KEYWORDS = {
    "attack", "swing", "slash", "strike", "bite", "punch", "lunge",
    "smash", "heavy", "light", "claw", "stomp", "thrust", "shot",
    "cast", "m1", "m2", "combo", "slam", "cleave", "whip", "spit"
}

local SAFE_KEYWORDS = {
    "idle", "walk", "run", "sprint", "fall", "jump", "sit", "climb", "swim", "land", "cheer", "wave"
}

local LastDefenseTick = 0
local IsCurrentlyDefending = false
local HookedMonsters = {}

local function ExtractAnimId(animOrTrack)
    if not animOrTrack then return "" end
    local idStr = ""
    pcall(function()
        if animOrTrack:IsA("AnimationTrack") and animOrTrack.Animation then
            idStr = animOrTrack.Animation.AnimationId or ""
        elseif animOrTrack:IsA("Animation") then
            idStr = animOrTrack.AnimationId or ""
        end
    end)
    return idStr:match("%d+") or ""
end

local function IsAttackTrack(track)
    if not track then return false end

    local animId = ExtractAnimId(track)
    if animId ~= "" and KNOWN_ATTACK_ANIM_IDS[animId] then
        return true
    end

    local trackName = ""
    pcall(function()
        trackName = (track.Name or ""):lower()
        if track.Animation and track.Animation.Name then
            trackName = trackName .. " " .. track.Animation.Name:lower()
        end
    end)

    for _, kw in ipairs(ATTACK_KEYWORDS) do
        if trackName:find(kw) then
            return true
        end
    end

    for _, skw in ipairs(SAFE_KEYWORDS) do
        if trackName:find(skw) then
            return false
        end
    end

    return false
end

local function TriggerDefenseReaction(attackerName)
    local now = tick()
    local delayTime = math.clamp(tonumber(State.DefenseDelay) or 0.50, 0, 1.5)
    local holdTime  = math.clamp(tonumber(State.DefenseHold) or 0.30, 0.05, 1.0)
    local minInterval = delayTime + holdTime + 0.15

    if now - LastDefenseTick < minInterval or IsCurrentlyDefending then return end
    LastDefenseTick = now
    IsCurrentlyDefending = true

    local mode = State.DefenseMode or "Auto Parry (F)"
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    task.spawn(function()
        if delayTime > 0 then
            task.wait(delayTime)
        end

        pcall(function()
            NotifyUser("DEFENSE ASSIST", string.format("Parried %s! (%.2fs delay)", attackerName or "Enemy", delayTime), 1.2)
        end)

        if mode:find("Parry") or mode:find("Block") then
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            end)
            if keypress then pcall(function() keypress(0x46) end) end

            local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
            pcall(function()
                VIM:SendMouseButtonEvent(vp.X * 0.5, vp.Y * 0.5, 1, true, game, 0)
            end)
            if mouse2press then pcall(mouse2press) end

            task.wait(holdTime)

            pcall(function()
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
            if keyrelease then pcall(function() keyrelease(0x46) end) end

            pcall(function()
                VIM:SendMouseButtonEvent(vp.X * 0.5, vp.Y * 0.5, 1, false, game, 0)
            end)
            if mouse2release then pcall(mouse2release) end
        end

        if mode:find("Dodge") or mode:find("Roll") then
            local dRemote = DashRemote or (Remotes and Remotes:FindFirstChild("DashEvent"))
            if dRemote then
                pcall(function() dRemote:FireServer("DefaultRoll", "Forward") end)
            end
            pcall(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.04)
                VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end)
            if keypress and keyrelease then
                pcall(function()
                    keypress(0x51)
                    task.wait(0.04)
                    keyrelease(0x51)
                end)
            end
        end

        task.wait(0.08)
        IsCurrentlyDefending = false
    end)
end

local function HookMonsterAnimations(mob)
    if not mob or HookedMonsters[mob] then return end
    HookedMonsters[mob] = true

    local hum = mob:FindFirstChild("Enemy") or mob:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or hum

    local conn
    conn = animator.AnimationPlayed:Connect(function(track)
        if getgenv().Veil_Unloaded or not State.DefenseAssist then return end
        if not mob.Parent then conn:Disconnect() return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local mRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("RootPart") or mob.PrimaryPart
        if not mRoot then return end

        local maxDist = State.DefenseDistance or 18
        local dist = (root.Position - mRoot.Position).Magnitude
        if dist <= maxDist then
            if IsAttackTrack(track) then
                TriggerDefenseReaction(mob.Name)
            end
        end
    end)
    table.insert(Connections, conn)
end

local LastDefenseScanTick = 0
local function ProcessDefenseAssist()
    if not State.DefenseAssist or getgenv().Veil_Unloaded then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local now = tick()
    if now - LastDefenseScanTick < 0.25 then return end
    LastDefenseScanTick = now

    local maxDist = (State.DefenseDistance or 18) + 6
    local activeMobs = GetAllActiveMonsters()
    for _, mob in ipairs(activeMobs) do
        local hum, mRoot = GetMobHumanoidAndRoot(mob)
        if hum and mRoot and hum.Health > 0 then
            local dist = (root.Position - mRoot.Position).Magnitude
            if dist <= maxDist then
                HookMonsterAnimations(mob)
            end
        end
    end

    local stale = {}
    for mob in pairs(HookedMonsters) do
        if not mob.Parent or (mob:FindFirstChild("Enemy") or mob:FindFirstChildOfClass("Humanoid") or {Health={Value=0}}).Health == nil then
            stale[mob] = true
        end
    end
    for mob in pairs(stale) do HookedMonsters[mob] = nil end
end

local function ProcessPlayerMods()
    if getgenv().Veil_Unloaded then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return end

    if State.NearbyAlert or State.KickNearby then
        local now = tick()
        if now - (getgenv().__LastNearbyTick or 0) >= 0.5 then
            getgenv().__LastNearbyTick = now
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local pRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local d = (root.Position - pRoot.Position).Magnitude
                        if State.NearbyAlert and d <= (State.AlertRange or 100) then
                            NotifyUser("The Veil | Alert", string.format("Player %s within %.0f studs!", plr.Name, d), 1.0)
                        end
                        if State.KickNearby and d <= (State.KickRange or 50) then
                            LocalPlayer:Kick(string.format("[The Veil] Player %s within kick radius (%.0f studs)", plr.Name, d))
                            break
                        end
                    end
                end
            end
        end
    end

    if State.CustomFOV and State.FOVOverride and State.FOVOverride > 0 then
        if Camera and Camera.FieldOfView ~= State.FOVOverride then
            Camera.FieldOfView = State.FOVOverride
        end
    end

    if State.ThirdPersonLock then
        if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 10
        end
    end

    if State.InfiniteStamina then
        local vals = char:FindFirstChild("Values")
        if vals then
            local stam = vals:FindFirstChild("Stamina")
            if stam and stam:IsA("NumberValue") and stam.Value < 150 then
                stam.Value = 150
            end
            local costMult = vals:FindFirstChild("StaminaCostMultiplier")
            if costMult and costMult:IsA("NumberValue") then
                costMult.Value = 0
            end
            local regenMult = vals:FindFirstChild("StaminaRegenMultiplier")
            if regenMult and regenMult:IsA("NumberValue") then
                regenMult.Value = 999
            end
        end
    end

    if State.NoSlow and hum.WalkSpeed < 16 then
        hum.WalkSpeed = 16
    end

    if State.CustomJumpHeight then
        hum.JumpPower = State.JumpPowerVal
        hum.JumpHeight = State.JumpPowerVal
    end
    if State.IgnoreJumpLock and not hum.Jump then
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
    end

    if State.NoAnimations or State.AnimationSpeedVal ~= 1.0 then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if State.NoAnimations then
                    track:Stop()
                elseif State.AnimationSpeedVal ~= 1.0 then
                    track:AdjustSpeed(State.AnimationSpeedVal)
                end
            end
        end
    end

    if State.PlayerAttach and State.AttachTarget ~= "" then
        local targetPlr = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == State.AttachTarget or p.DisplayName == State.AttachTarget then
                targetPlr = p
                break
            end
        end
        if targetPlr and targetPlr.Character then
            local tRoot = GetEntityRoot(targetPlr.Character)
            if tRoot then
                local d = (root.Position - tRoot.Position).Magnitude
                local maxDetect = math.max((State.AttachRange or 10) * 10, 80)
                if d <= maxDetect then
                    local dist = math.clamp(State.AttachDist or 5, 2, 50)
                    local h = State.AttachHeight or 5
                    local desiredPos = tRoot.Position - (tRoot.CFrame.LookVector * dist) + Vector3.new(0, h, 0)
                    local desiredCf = CFrame.lookAt(desiredPos, tRoot.Position)
                    pcall(function() char:PivotTo(desiredCf) end)
                    root.CFrame = desiredCf
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
            end
        end
    end

    if State.AntiFling then
        root.RotVelocity = Vector3.new(0, 0, 0)
        local now = tick()
        if not LastAntiFlingTick or (now - LastAntiFlingTick >= 0.15) then
            LastAntiFlingTick = now
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end
end

-- ================================================
--  RESPAWN HANDLER
-- ================================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if getgenv().Veil_Unloaded then return end
    if State.TPBackOnDeath and LastAliveCFrame then
        task.spawn(function()
            local root = newChar:WaitForChild("HumanoidRootPart", 10)
            if root then
                task.wait(0.5)
                root.CFrame = LastAliveCFrame
                print("[NW Hub] Teleported back to last alive position!")
            end
        end)
    end
end)

-- ================================================
--  LIGHTING (FULLBRIGHT, NO FOG, NO ATMOSPHERE FIXED)
-- ================================================
local OriginalAtmosphereSettings = {}
local OriginalPostEffects = {}

local function ApplyWorldLighting(force)
    if getgenv().Veil_Unloaded then return end
    local anyLightingActive = State.FullBright or State.NoFog or State.NoAtmosphere or State.WorldAmbient

    if State.FullBright then
        pcall(function()
            Lighting.Brightness = State.BrightnessVal or 3.0
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.Ambient = State.WorldAmbientColor or Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = State.WorldAmbientColor or Color3.fromRGB(200, 200, 200)
            Lighting.ExposureCompensation = 0.5
        end)
    elseif force then
        pcall(function()
            Lighting.Brightness = OriginalLighting.Brightness or 2.0
            Lighting.ClockTime = OriginalLighting.ClockTime or 14
            Lighting.GlobalShadows = OriginalLighting.GlobalShadows ~= false
            Lighting.Ambient = OriginalLighting.Ambient or Color3.fromRGB(128, 128, 128)
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient or Color3.fromRGB(128, 128, 128)
            Lighting.ExposureCompensation = 0
        end)
    end

    if State.WorldAmbient and not State.FullBright then
        pcall(function()
            Lighting.Ambient = State.WorldAmbientColor or Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = State.WorldAmbientColor or Color3.fromRGB(200, 200, 200)
        end)
    end

    if State.NoFog then
        pcall(function()
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 1000000
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        end)
    elseif force and not State.NoFog then
        pcall(function()
            Lighting.FogEnd = OriginalLighting.FogEnd or 1000
            Lighting.FogStart = OriginalLighting.FogStart or 0
        end)
    end

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") then
            if not OriginalAtmosphereSettings[v] then
                OriginalAtmosphereSettings[v] = {
                    Density = v.Density,
                    Offset = v.Offset,
                    Haze = v.Haze,
                    Glare = v.Glare
                }
            end
            if State.NoAtmosphere or State.NoFog then
                v.Density = 0
                v.Haze = 0
                v.Glare = 0
                v.Offset = 0
            elseif not State.NoAtmosphere and not State.NoFog and OriginalAtmosphereSettings[v] then
                v.Density = OriginalAtmosphereSettings[v].Density
                v.Haze = OriginalAtmosphereSettings[v].Haze
                v.Glare = OriginalAtmosphereSettings[v].Glare
                v.Offset = OriginalAtmosphereSettings[v].Offset
            end
        elseif v:IsA("PostEffect") then
            if OriginalPostEffects[v] == nil then
                OriginalPostEffects[v] = v.Enabled
            end
            if State.NoAtmosphere then
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
                    v.Enabled = false
                end
            elseif not State.NoAtmosphere and OriginalPostEffects[v] ~= nil then
                v.Enabled = OriginalPostEffects[v]
            end
        end
    end
end

-- ================================================
--  HOOKS & EVENT CONNECTIONS
-- ================================================
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if getgenv().Veil_Unloaded then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if State.InfiniteJump then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if State.InfiniteDoubleJump and hum.FloorMaterial == Enum.Material.Air then
        local djRemote = DoubleJumpRemote or (Remotes and Remotes:FindFirstChild("DoubleJumpEvent"))
        if djRemote then
            pcall(function() djRemote:FireServer() end)
        end
        local currentVel = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(currentVel.X, 55, currentVel.Z)
    end
end)
table.insert(Connections, jumpConn)

local clickTpConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or getgenv().Veil_Unloaded or not State.ClickTP then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if mouse and root and mouse.Hit then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)
table.insert(Connections, clickTpConn)

if getconnections then
    pcall(function()
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            if conn.Disable then conn:Disable()
            elseif conn.Disconnect then conn:Disconnect() end
        end
    end)
else
    local afkConn = LocalPlayer.Idled:Connect(function()
        if State.AntiAFK and not getgenv().Veil_Unloaded then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
    table.insert(Connections, afkConn)
end

-- ================================================
--  MAIN HEARTBEAT LOOP (FLY FIXED)
-- ================================================
local LastFarmTick = 0
local LastModsTick = 0
local LastHeartbeatDt = 0.016

-- Noclip sur Stepped : s'exécute AVANT la physique, donc les collisions
-- sont testées avec CanCollide déjà à false pour la frame courante.
local noclipStepped = RunService.Stepped:Connect(function()
    if getgenv().Veil_Unloaded then return end
    if not (State.Noclip or State.Fly or State.MobFarm or State.PlayerFarm) then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)
table.insert(Connections, noclipStepped)

local mainHeartbeat = RunService.Heartbeat:Connect(function(dt)
    if getgenv().Veil_Unloaded then return end

    LastHeartbeatDt = dt

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        -- FIX #1: FLY via CFrame-stepping (anti-cheat safe, no BodyMovers)
        if State.Fly then
            if not hum.PlatformStand then hum.PlatformStand = true end

            -- position cible persistante : corrige la dérive gravité même sans input
            if not FlyTargetPos then FlyTargetPos = root.Position end

            local camCF = Camera.CFrame
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            local mag = moveDir.Magnitude
            if mag > 0.001 then
                local speed = math.min(State.FlySpeed or 50, 75)
                local dir = moveDir / mag
                local stepDt = math.min(LastHeartbeatDt, 0.05)
                FlyTargetPos = FlyTargetPos + dir * (speed * stepDt)
            end

            -- On ré-ancre TOUJOURS la CFrame, même à l'arrêt (fix dérive)
            local newCf = CFrame.lookAt(FlyTargetPos, FlyTargetPos + camCF.LookVector)
            pcall(function()
                root.CFrame = newCf
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                LastAliveCFrame = newCf
            end)
        else
            if FlyTargetPos then
                FlyTargetPos = nil
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    LastAliveCFrame = root.CFrame
                end)
            end
            if hum.PlatformStand and not State.MobFarm and not State.PlayerFarm then
                hum.PlatformStand = false
            end
        end

        if State.Speedhack and not State.MobFarm and not State.PlayerFarm and not State.Fly then
            if hum.MoveDirection.Magnitude > 0 then
                local speedMult = State.SpeedMultiplier or 2.0
                local baseSpeed = math.max(hum.WalkSpeed, 16)
                local targetSpeed = baseSpeed * speedMult
                local md = hum.MoveDirection.Unit
                local cv = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(md.X * targetSpeed, cv.Y, md.Z * targetSpeed)
            end
        end

        if hum.Health > 0 and root.Position.Y > -1400 then
            LastAliveCFrame = root.CFrame
        end

        if root.Position.Y < -1600 then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                local safeCf = LastAliveCFrame or CFrame.new(420, 40, 266)
                char:PivotTo(safeCf)
                root.CFrame = safeCf
                UpdateFarmHover(false)
            end)
        end
    end

    local now = tick()
    if now - LastModsTick >= 0.066 then
        LastModsTick = now
        if (State.Fly or State.Speedhack or State.NoSlow or State.Noclip or State.InfiniteStamina or State.PlayerAttach or State.AntiFling) then
            ProcessPlayerMods()
        end
    end

    if now - LastFarmTick >= 0.05 then
        LastFarmTick = now
        if State.DefenseAssist then
            ProcessDefenseAssist()
        end
        if State.Instakill or State.AutoM1 or State.AutoCritical or State.AutoM2 or State.AutoAbility or State.NoDashCooldown or State.AutoEquip then
            ProcessFarming()
        end
        if (State.AutoPickup or State.AutoOpenChests) then
            ProcessLootAndChests()
        end
    end
end)
table.insert(Connections, mainHeartbeat)

local LastLightingTick = 0
local espRenderConn = RunService.RenderStepped:Connect(function()
    if getgenv().Veil_Unloaded then return end
    local anyEspActive = State.PlayerESP or State.MobESP or State.LocalPlayerESP or State.NpcESP or State.DropESP or State.TrinketESP or State.ChestESP
    if anyEspActive then
        UpdateAllESP()
    end
    local now = tick()
    if now - LastLightingTick >= 0.5 then
        LastLightingTick = now
        if State.FullBright or State.NoFog or State.NoAtmosphere or State.WorldAmbient then
            ApplyWorldLighting()
        end
    end
end)
table.insert(Connections, espRenderConn)

task.spawn(function()
    while not getgenv().Veil_Unloaded do
        local anyEspActive = State.PlayerESP or State.MobESP or State.LocalPlayerESP or State.NpcESP or State.DropESP or State.TrinketESP or State.ChestESP
        if anyEspActive then
            pcall(ScanWorldESP)
        end
        task.wait(2.0)
    end
end)

pcall(HookNativeDropHighlight)

if DropsFolder then
    table.insert(Connections, DropsFolder.ChildAdded:Connect(function(drop)
        if State.DropESP and not getgenv().Veil_Unloaded then
            task.delay(0.1, function()
                pcall(ApplyLootESP, drop)
            end)
        end
    end))
end
if TrinketFolder then
    table.insert(Connections, TrinketFolder.ChildAdded:Connect(function(tr)
        if State.TrinketESP and not getgenv().Veil_Unloaded then
            task.delay(0.1, function()
                pcall(ApplyTrinketESP, tr)
            end)
        end
    end))
end

-- =====================================================================
--  VESPER UI (EMBEDDED)
-- =====================================================================
local Kyoka = (function()
--[[
	Kyōka UI  ·  v1.0.0
	Librairie d'interface Roblox (Luau), style « Kyōka Suigetsu » (Aizen).
	Remplaçant direct de Vesper : même API, mêmes objets, mêmes flags,
	même format de config. Seul le rendu change.

	Usage :
		local Kyoka = loadstring(game:HttpGet("..."))()   -- executor
		local Kyoka = require(path.to.Kyoka)               -- ModuleScript

	Hiérarchie :
		Window > Tab (barre latérale) > Page (pastilles du haut) > Group (colonne) > Éléments
]]

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local GuiService       = game:GetService("GuiService")
local Stats            = game:GetService("Stats")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--=====================================================================
-- Librairie et thème
--=====================================================================

local Library = {
	Version     = "1.0.0",
	Name        = "Kyoka",
	Flags       = {},   -- flag -> valeur courante
	Options     = {},   -- flag -> objet élément (:Set, :Get)
	Connections = {},
	Objects     = {},
	Unloaded    = false,
	Open        = true,
	ToggleKey   = Enum.KeyCode.RightShift,

	-- Les scripts Vesper passent un accent rose au CreateWindow : on le
	-- garde violet sauf demande explicite (SetAccent reste libre).
	KeepAccent  = true,
	-- Éclats, fissures, flou du jeu. false = ouverture sobre.
	Effects     = true,
	Blur        = false,
	-- Bannière animée par défaut (planche de sprites Aizen).
	DefaultBanner      = "rbxassetid://133659890941845",
	DefaultBannerSheet = { Columns = 5, Rows = 8, Frames = 40, FPS = 11, FrameSize = Vector2.new(200, 123) },

	Theme = {
		Accent       = Color3.fromRGB(124, 108, 255),
		AccentDim    = Color3.fromRGB( 74,  62, 170),
		Accent2      = Color3.fromRGB( 42, 212, 255),
		Background   = Color3.fromRGB(  7,   6,  12),
		Panel        = Color3.fromRGB( 12,  11,  20),
		Panel2       = Color3.fromRGB( 17,  15,  28),
		Element      = Color3.fromRGB( 22,  20,  36),
		ElementHover = Color3.fromRGB( 30,  27,  48),
		Border       = Color3.fromRGB( 38,  34,  58),
		BorderSoft   = Color3.fromRGB( 27,  24,  42),
		Text         = Color3.fromRGB(236, 235, 245),
		TextDim      = Color3.fromRGB(163, 161, 184),
		TextFaint    = Color3.fromRGB(108, 106, 130),
		Danger       = Color3.fromRGB(255,  90, 122),
		Success      = Color3.fromRGB( 61, 220, 132),
		Glass        = Color3.fromRGB(207, 201, 255),
	},
}

local Theme = Library.Theme

--=====================================================================
-- Détection mobile et métriques
--=====================================================================

local ScreenGuiSize

local function DetectMobile()
	local env = (getgenv and getgenv()) or _G
	if env then
		if env.FORCE_MOBILE == true or env.MOBILE == true or env.IS_MOBILE == true then return true end
		if env.FORCE_DESKTOP == true or env.DESKTOP == true then return false end
	end
	local okPlatform, platform = pcall(function() return UserInputService:GetPlatform() end)
	if okPlatform and (platform == Enum.Platform.IOS or platform == Enum.Platform.Android) then
		return true
	end
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return true end
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then return true end
	if UserInputService.TouchEnabled then
		local vp = (ScreenGuiSize and ScreenGuiSize()) or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize)
		if not vp then return true end
		local petitCote = math.min(vp.X, vp.Y)
		if petitCote > 0 and petitCote <= 1100 then return true end
	end
	return false
end

Library.Mobile = false
Library.HasKeyboard = UserInputService.KeyboardEnabled

local M_DESKTOP = {
	Row = 30, RowSlider = 44, RowWide = 54, RowGap = 2,
	SwitchW = 30, SwitchH = 16,
	Field = 26, FieldW = 132, KeybindW = 46,
	Swatch = 30, SwatchH = 16,
	Button = 30,
	GroupPadT = 6, GroupPadB = 8, GroupPadX = 10,
	Header = 30, TopBar = 46, Footer = 26,
	Sidebar = 170, Banner = 104, TabRow = 34,
	PageTab = 26, Columns = 2, AddonSpace = 92,
	FontMul = 1,
}

local M_TOUCH = {
	Row = 40, RowSlider = 56, RowWide = 66, RowGap = 4,
	SwitchW = 40, SwitchH = 22,
	Field = 34, FieldW = 150, KeybindW = 64,
	Swatch = 40, SwatchH = 22,
	Button = 40,
	GroupPadT = 8, GroupPadB = 10, GroupPadX = 12,
	Header = 34, TopBar = 52, Footer = 28,
	Sidebar = 132, Banner = 70, TabRow = 42,
	PageTab = 32, Columns = 1, AddonSpace = 150,
	FontMul = 1.15,
}

local M = {}

local function ApplyMetrics(mobile)
	Library.Mobile = mobile and true or false
	for k, v in pairs(M_DESKTOP) do M[k] = v end
	if mobile then
		for k, v in pairs(M_TOUCH) do M[k] = v end
	end
end

ApplyMetrics(DetectMobile())

--=====================================================================
-- Polices (toutes livrées avec Roblox)
--=====================================================================

local function FamilyOf(enumName, fallback)
	local ok, item = pcall(function() return Enum.Font[enumName] end)
	local font = Font.fromEnum(ok and item or fallback)
	return font.Family
end

local FAMILY_TEXT  = FamilyOf("BuilderSans", Enum.Font.GothamMedium)
local FAMILY_TITLE = FamilyOf("Michroma", Enum.Font.GothamBold)
local FAMILY_MONO  = FamilyOf("RobotoMono", Enum.Font.Code)

local function TS(size)
	return math.max(8, math.floor((size or 13) * M.FontMul + 0.5))
end

local function FontText(weight)
	return Font.new(FAMILY_TEXT, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
end
local function FontTitle()
	return Font.new(FAMILY_TITLE, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end
local function FontMono(weight)
	return Font.new(FAMILY_MONO, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
end

--=====================================================================
-- Utilitaires
--=====================================================================

local Registry = setmetatable({}, { __mode = "k" })

local function New(class, props, children)
	local inst = Instance.new(class)
	local parent = (type(props) == "table" and props.Parent) or nil
	if type(props) == "table" then
		for k, v in pairs(props) do
			if k ~= "Parent" then inst[k] = v end
		end
	end
	if type(children) == "table" then
		for _, child in ipairs(children) do child.Parent = inst end
	end
	if parent then inst.Parent = parent end
	return inst
end

function Library:Register(inst, map)
	if type(map) ~= "table" then return inst end
	Registry[inst] = map
	for prop, key in pairs(map) do
		inst[prop] = Theme[key]
	end
	return inst
end

function Library:SetTheme(key, color)
	Theme[key] = color
	for inst, map in pairs(Registry) do
		if typeof(inst) == "Instance" and inst.Parent ~= nil then
			for prop, k in pairs(map) do
				if k == key then pcall(function() inst[prop] = color end) end
			end
		end
	end
	if Library._OnTheme then pcall(Library._OnTheme, key, color) end
end

function Library:SetAccent(color)
	if typeof(color) ~= "Color3" then return end
	self:SetTheme("Accent", color)
	self:SetTheme("AccentDim", color:Lerp(Color3.new(0, 0, 0), 0.4))
end

function Library:Connect(signal, fn)
	local conn = signal:Connect(fn)
	table.insert(Library.Connections, conn)
	return conn
end

local function Tween(inst, dur, props, style, dir)
	local info = TweenInfo.new(dur or 0.16, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end

local function Corner(parent, radius)
	return New("UICorner", { CornerRadius = radius == "full" and UDim.new(1, 0) or UDim.new(0, radius or 6), Parent = parent })
end

local function Stroke(parent, key, thickness, transparency)
	local s = New("UIStroke", {
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
	Library:Register(s, { Color = key or "BorderSoft" })
	return s
end

local function Padding(parent, t, b, l, r)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
		PaddingLeft   = UDim.new(0, l or 0),
		PaddingRight  = UDim.new(0, r or l or 0),
		Parent = parent,
	})
end

local function List(parent, pad, dir, halign, valign)
	return New("UIListLayout", {
		Padding = UDim.new(0, pad or 0),
		FillDirection = dir or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Center,
		Parent = parent,
	})
end

-- Dégradé de couleurs (liste de Color3 réparties) et de transparences.
local function Seq(colors)
	local kps = {}
	for i, c in ipairs(colors) do
		table.insert(kps, ColorSequenceKeypoint.new((i - 1) / math.max(#colors - 1, 1), c))
	end
	return ColorSequence.new(kps)
end

local function NSeq(points)
	local kps = {}
	for _, p in ipairs(points) do
		table.insert(kps, NumberSequenceKeypoint.new(p[1], p[2]))
	end
	return NumberSequence.new(kps)
end

local function Gradient(parent, colors, rotation, transparency)
	return New("UIGradient", {
		Color = colors and Seq(colors) or nil,
		Rotation = rotation or 0,
		Transparency = transparency and NSeq(transparency) or nil,
		Parent = parent,
	})
end

local function Label(parent, text, size, colorKey, weight, font)
	local lbl = New("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(text or ""),
		FontFace = font or FontText(weight or Enum.FontWeight.Medium),
		TextSize = TS(size or 13),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true,
		Size = UDim2.fromScale(1, 1),
		Parent = parent,
	})
	Library:Register(lbl, { TextColor3 = colorKey or "Text" })
	return lbl
end

local function MonoLabel(parent, text, size, colorKey)
	return Label(parent, string.upper(tostring(text or "")), size or 10, colorKey or "TextDim", nil, FontMono(Enum.FontWeight.SemiBold))
end

local function Hit(parent, name, zindex)
	return New("TextButton", {
		Name = name or "Hit",
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromScale(1, 1),
		ZIndex = zindex or 5,
		Parent = parent,
	})
end

local function MousePos()
	local m = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	return Vector2.new(m.X - inset.X, m.Y - inset.Y)
end

local function Round(n, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(n * mult + 0.5) / mult
end

-- Dégradés qui dépendent de l'accent : reconstruits quand il change.
local AccentGradients = setmetatable({}, { __mode = "k" })

local function AccentGradient(parent, build, rotation, transparency)
	local g = New("UIGradient", {
		Color = build(),
		Rotation = rotation or 0,
		Transparency = transparency and NSeq(transparency) or nil,
		Parent = parent,
	})
	AccentGradients[g] = build
	return g
end

Library._OnTheme = function(key)
	if key ~= "Accent" and key ~= "Accent2" and key ~= "AccentDim" then return end
	for g, build in pairs(AccentGradients) do
		if g.Parent then pcall(function() g.Color = build() end) end
	end
end

local function AccentToCyan() return Seq({ Theme.Accent, Theme.Accent2 }) end
local function DimToCyan() return Seq({ Theme.AccentDim, Theme.Accent, Theme.Accent2 }) end

local function Diamond(parent, size, zindex)
	local d = New("Frame", {
		Name = "Diamond",
		Size = UDim2.fromOffset(size or 6, size or 6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Rotation = 45,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = zindex or 3,
		Parent = parent,
	})
	AccentGradient(d, AccentToCyan, 45)
	return d
end

--=====================================================================
-- ScreenGui racine
--=====================================================================

local function GetParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then
		local writable = pcall(function()
			local probe = Instance.new("Folder")
			probe.Parent = cg
			probe:Destroy()
		end)
		if writable then return cg end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- Le nom garde « Vesper » : les scripts existants nettoient une ancienne
-- instance en cherchant ce mot avant de se relancer.
local ScreenGui = New("ScreenGui", {
	Name = "Vesper_Kyoka_" .. tostring(math.random(1e5, 1e6)),
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
})
pcall(function()
	if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
end)
ScreenGui.Parent = GetParent()
Library.ScreenGui = ScreenGui
pcall(function() getgenv().NWHub_Instance = Library end)

ScreenGuiSize = function()
	return ScreenGui.AbsoluteSize
end

--=====================================================================
-- Échelle
-- Library.Scale reste en unités Vesper : 2 = taille nominale en 1080p.
-- Le facteur réel appliqué est Scale / 2.
--=====================================================================

local ScaleTargets = {}

local function ViewportSize()
	local vp = ScreenGui.AbsoluteSize
	if vp.X <= 1 or vp.Y <= 1 then
		local cam = workspace.CurrentCamera
		vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	end
	return vp
end

local function AutoScale()
	if Library.Mobile then return 2 end
	-- Fenêtre ≈ 55 % de la hauteur, jamais plus petite que la taille nominale
	-- tant que l'écran peut la contenir (sinon le texte devient illisible).
	local h = ViewportSize().Y
	local f = math.max(h * 0.55 / 470, math.min(1, (h - 60) / 470))
	return math.clamp(Round(f * 2, 1), 1.6, 4)
end

Library.Scale = AutoScale()

local function Factor()
	return (Library.Scale or 2) / 2
end

local function Scalable(parent)
	local s = New("UIScale", { Scale = Factor(), Parent = parent })
	table.insert(ScaleTargets, s)
	return s
end

function Library:SetScale(n)
	n = tonumber(n)
	if not n then return end
	Library.Scale = math.clamp(n, 0.8, 4)
	for _, obj in pairs(ScaleTargets) do
		if obj.Parent then obj.Scale = Factor() end
	end
	if Library.Window and Library.Window.ApplyScale then
		Library.Window:ApplyScale(Library.Scale)
	end
end

local PopupLayer = New("Frame", {
	Name = "PopupLayer",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 500,
	Parent = ScreenGui,
})
Library.PopupLayer = PopupLayer

local FxLayer = New("Frame", {
	Name = "FxLayer",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 860,
	Parent = ScreenGui,
})

local function InputPos(input)
	if input and input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input.Position.X, input.Position.Y)
	end
	return MousePos()
end

local function MouseLocal()
	local origin = PopupLayer.AbsolutePosition
	local p = MousePos()
	return p.X - origin.X, p.Y - origin.Y
end

local ModalCatcher = New("TextButton", {
	Name = "Modal",
	Text = "",
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(1, 1),
	Position = UDim2.fromOffset(-4, -4),
	Modal = true,
	Parent = ScreenGui,
})

local ActivePopup = nil
local function CloseActivePopup()
	if ActivePopup then
		local close = ActivePopup
		ActivePopup = nil
		close()
	end
end

--=====================================================================
-- Sons (identique à Vesper : même asset et même cache)
--=====================================================================

local customAsset = getsynasset or getcustomasset
local SPLASH_URL = "https://nwhub-platform.vercel.app/splash.mp3"
local SPLASH_FILE = "nwhub_splash_v2.mp3"

local function GetSplashAsset()
	local fallbackId = "rbxassetid://74227218855270"
	if customAsset and writefile and readfile then
		local ok, asset = pcall(function()
			if not (isfile and isfile(SPLASH_FILE)) then
				local body = game:HttpGet(SPLASH_URL)
				if body and #body > 5000 then writefile(SPLASH_FILE, body) end
			end
			return customAsset(SPLASH_FILE)
		end)
		if ok and asset then return asset end
	end
	return fallbackId
end

Library.GetSplashAsset = GetSplashAsset

Library.Sound = {
	Enabled = true,
	Volume  = 1,
	Splash  = { Id = "rbxassetid://74227218855270", Speed = 1, Voice = false },
}
Library.SoundFailed = nil

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local soundCache = {}
local lastPlayed = {}
local lastPick = {}

local function ResolveId(nom, cfg)
	local id = cfg.Id
	if type(id) ~= "table" then return id end
	if #id == 0 then return nil end
	if #id == 1 then return id[1] end
	local choix
	repeat
		choix = id[math.random(1, #id)]
	until choix ~= lastPick[nom]
	lastPick[nom] = choix
	return choix
end

function Library:PlaySound(nom)
	local cfg = Library.Sound[nom]
	if not cfg or not Library.Sound.Enabled or not cfg.Id then return end

	local snd = soundCache[nom]
	if not snd or not snd.Parent then
		snd = New("Sound", { Name = "Kyoka_" .. nom, Parent = SoundService })
		soundCache[nom] = snd
	end

	if cfg.Voice then
		if snd.IsPlaying then return end
		local precedent = lastPlayed[nom]
		if precedent and os.clock() - precedent < (cfg.Cooldown or 0) then return end
	end
	lastPlayed[nom] = os.clock()

	local id = (nom == "Splash" and GetSplashAsset()) or ResolveId(nom, cfg)
	if not id then return end
	if snd.SoundId ~= id then snd.SoundId = id end
	snd.Volume = cfg.Volume or Library.Sound.Volume or 1
	snd.PlaybackSpeed = cfg.Speed or 1
	snd.TimePosition = 0
	pcall(function() snd:Play() end)

	task.spawn(function()
		pcall(function() ContentProvider:PreloadAsync({ snd }) end)
		task.wait(0.3)
		if not snd.IsLoaded or snd.TimeLength <= 0 then
			Library.SoundFailed = id
		else
			Library.SoundFailed = nil
		end
	end)
	return snd
end

function Library:SetSoundEnabled(v)
	Library.Sound.Enabled = v and true or false
end

--=====================================================================
-- Infobulle
--=====================================================================

local Tooltip = New("Frame", {
	Name = "Tooltip",
	Visible = false,
	AutomaticSize = Enum.AutomaticSize.XY,
	Size = UDim2.fromOffset(0, 0),
	ZIndex = 900,
	Parent = ScreenGui,
})
Library:Register(Tooltip, { BackgroundColor3 = "Panel2" })
Corner(Tooltip, 6)
Scalable(Tooltip)
Stroke(Tooltip, "Border")
Padding(Tooltip, 6, 6, 9, 9)

local TooltipText = New("TextLabel", {
	BackgroundTransparency = 1,
	AutomaticSize = Enum.AutomaticSize.XY,
	Size = UDim2.fromOffset(0, 0),
	FontFace = FontText(Enum.FontWeight.Medium),
	TextSize = TS(12),
	Text = "",
	ZIndex = 901,
	Parent = Tooltip,
})
Library:Register(TooltipText, { TextColor3 = "Text" })

function Library:ShowTooltip(text)
	if type(text) ~= "string" or text == "" then return end
	TooltipText.Text = text
	Tooltip.Visible = true
end

function Library:HideTooltip()
	Tooltip.Visible = false
end

Library:Connect(RunService.RenderStepped, function()
	if Tooltip.Visible then
		local x, y = MouseLocal()
		Tooltip.Position = UDim2.fromOffset(x + 14, y + 14)
	end
end)

--=====================================================================
-- Effets : étincelles, onde, fissures, éclats, flou du jeu
-- Tout en Frames + UIGradient + TweenService, rien à uploader.
--=====================================================================

local FX = {}

local function ToFx(gui)
	local o = FxLayer.AbsolutePosition
	return gui.AbsolutePosition - o, gui.AbsoluteSize
end

-- Petites étincelles qui jaillissent d'un point (en pixels écran).
function FX.Sparks(point, count)
	if not Library.Effects then return end
	local o = FxLayer.AbsolutePosition
	local cx, cy = point.X - o.X, point.Y - o.Y
	for _ = 1, count or 10 do
		local sz = math.random(2, 4)
		local s = New("Frame", {
			Size = UDim2.fromOffset(sz, sz),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, cy),
			BackgroundColor3 = Theme.Glass,
			BorderSizePixel = 0,
			ZIndex = 870,
			Parent = FxLayer,
		})
		Corner(s, "full")
		local a = math.random() * math.pi * 2
		local d = 12 + math.random() * 22
		Tween(s, 0.5, {
			Position = UDim2.fromOffset(cx + math.cos(a) * d, cy + math.sin(a) * d),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(1, 1),
		}, Enum.EasingStyle.Quart)
		task.delay(0.52, function() s:Destroy() end)
	end
end

-- Onde circulaire dans un bouton, depuis le point cliqué.
function FX.Ripple(button, point)
	if not Library.Effects then return end
	local pos, size = button.AbsolutePosition, button.AbsoluteSize
	local f = Factor()
	local lx, ly = (point.X - pos.X) / f, (point.Y - pos.Y) / f
	local r = New("Frame", {
		Size = UDim2.fromOffset(0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(lx, ly),
		BackgroundColor3 = Theme.Glass,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = (button.ZIndex or 1) + 3,
		Parent = button,
	})
	Corner(r, "full")
	local d = math.max(size.X, size.Y) / f * 2.2
	Tween(r, 0.55, { Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
	task.delay(0.57, function() r:Destroy() end)
end

-- Fissures lumineuses : des rayons qui jaillissent d'un même point.
-- Roblox fait pivoter un objet autour de son centre, pas de son ancre : chaque
-- rayon vit donc dans un pivot de taille nulle posé sur l'origine, et c'est le
-- pivot qui tourne. Un objet tourné n'est pas coupé par ClipsDescendants :
-- la longueur est bornée au bord du panneau. Le halo imite le box-shadow web
-- avec trois épaisseurs superposées.
local BEAM_LAYERS = {
	{ Thick = 18, Transparency = 0.84, Color = "Accent" },
	{ Thick = 7, Transparency = 0.5, Color = "Accent" },
	{ Thick = 2, Transparency = 0, Color = "White" },
}

function FX.Cracks(panel, count)
	if not Library.Effects then return function() end end
	count = count or 7
	local objects = {}

	local host = panel.Parent
	local w = host and host:IsA("GuiObject") and host.Size.X.Offset or 0
	local h = host and host:IsA("GuiObject") and host.Size.Y.Offset or 0
	if w <= 0 or h <= 0 then
		local f = math.max(Factor(), 0.01)
		w, h = panel.AbsoluteSize.X / f, panel.AbsoluteSize.Y / f
	end

	local ox = w * (0.6 + math.random() * 0.25)
	local oy = h * (0.3 + math.random() * 0.3)

	-- Éclair au point d'impact.
	local burst = New("Frame", {
		Name = "Crack",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(ox, oy),
		Size = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 92,
		Parent = panel,
	})
	Corner(burst, "full")
	local halo = New("Frame", {
		Name = "Crack",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(ox, oy),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 91,
		Parent = panel,
	})
	Corner(halo, "full")
	table.insert(objects, burst)
	table.insert(objects, halo)
	Tween(burst, 0.35, { Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
	Tween(halo, 0.6, { Size = UDim2.fromOffset(110, 110), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)

	for i = 1, count do
		local angle = (i / count) * 360 + math.random() * 30
		local rad = math.rad(angle)
		local dx, dy = math.cos(rad), math.sin(rad)
		-- Distance jusqu'au bord du panneau dans cette direction.
		local tx = dx > 0 and (w - ox) / dx or (dx < 0 and -ox / dx or math.huge)
		local ty = dy > 0 and (h - oy) / dy or (dy < 0 and -oy / dy or math.huge)
		local len = math.min(160 + math.random() * 260, tx, ty)

		local pivot = New("Frame", {
			Name = "Crack",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(ox, oy),
			Size = UDim2.fromOffset(0, 0),
			Rotation = angle,
			ZIndex = 90,
			Parent = panel,
		})
		table.insert(objects, pivot)

		local beams = {}
		for li, layer in ipairs(BEAM_LAYERS) do
			local beam = New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromOffset(0, 0),
				Size = UDim2.fromOffset(0, layer.Thick),
				BackgroundColor3 = layer.Color == "White" and Color3.new(1, 1, 1) or Theme.Accent,
				BackgroundTransparency = layer.Transparency,
				BorderSizePixel = 0,
				ZIndex = 90 + li,
				Parent = pivot,
			})
			Corner(beam, "full")
			New("UIGradient", {
				Color = layer.Color == "White"
					and Seq({ Color3.new(1, 1, 1), Theme.Glass, Theme.Accent })
					or Seq({ Theme.Glass, Theme.Accent }),
				Transparency = NSeq({ { 0, 0 }, { 0.6, 0.15 }, { 1, 1 } }),
				Parent = beam,
			})
			beams[li] = { Frame = beam, Base = layer.Transparency, Thick = layer.Thick }
		end

		local delay = (i - 1) * 0.022
		task.delay(delay, function()
			if not pivot.Parent then return end
			for _, bm in ipairs(beams) do
				Tween(bm.Frame, 0.45, { Size = UDim2.fromOffset(len, bm.Thick) }, Enum.EasingStyle.Quint)
			end
		end)
		task.delay(delay + 0.75, function()
			if not pivot.Parent then return end
			for _, bm in ipairs(beams) do
				Tween(bm.Frame, 0.4, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
			end
		end)
		task.delay(delay + 1.2, function() pivot:Destroy() end)
	end
	task.delay(0.7, function() burst:Destroy(); halo:Destroy() end)

	return function()
		for _, o in ipairs(objects) do o:Destroy() end
	end
end

-- Liseré qui s'illumine puis s'éteint (le ::after de l'aperçu web).
function FX.EdgeFlash(panel, root)
	if not Library.Effects then return function() end end
	local objects = {}
	-- Un objet n'affiche qu'un UIStroke : l'anneau vit sur un cadre à part,
	-- posé exactement sur le panneau.
	local frame = New("Frame", {
		Name = "EdgeRing",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 95,
		Parent = root or panel,
	})
	Corner(frame, 12)
	local ring = New("UIStroke", {
		Color = Theme.Glass,
		Thickness = 1.5,
		Transparency = 0.05,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = frame,
	})
	table.insert(objects, frame)
	Tween(ring, 0.9, { Transparency = 1 }, Enum.EasingStyle.Quad)
	if root then
		for i = 1, 5 do
			local spread = i * 6
			local glow = New("Frame", {
				Name = "EdgeGlow",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, spread * 2, 1, spread * 2),
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.8 + i * 0.03,
				BorderSizePixel = 0,
				ZIndex = 0,
				Parent = root,
			})
			Corner(glow, 12 + spread)
			table.insert(objects, glow)
			Tween(glow, 0.9, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
		end
	end
	task.delay(0.95, function()
		for _, o in ipairs(objects) do o:Destroy() end
	end)
	return function()
		for _, o in ipairs(objects) do o:Destroy() end
	end
end

-- Bande de lumière diagonale qui balaie un cadre.
function FX.Sweep(panel, delay, duration)
	if not Library.Effects then return function() end end
	local band = New("Frame", {
		Name = "Sweep",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(-0.6, 0.5),
		Size = UDim2.fromScale(0.9, 3),
		Rotation = 22,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 89,
		Parent = panel,
	})
	New("UIGradient", {
		Color = Seq({ Theme.Glass, Color3.new(1, 1, 1), Theme.Accent2 }),
		Transparency = NSeq({ { 0, 1 }, { 0.4, 1 }, { 0.47, 0.72 }, { 0.5, 0.45 }, { 0.53, 0.75 }, { 0.6, 1 }, { 1, 1 } }),
		Parent = band,
	})
	task.delay(delay or 0, function()
		if band.Parent then
			Tween(band, duration or 0.9, { Position = UDim2.fromScale(1.6, 0.5) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		end
	end)
	task.delay((delay or 0) + (duration or 0.9) + 0.05, function() band:Destroy() end)
	return function() band:Destroy() end
end

-- Éclats de verre.
local function MakeShard(w, h, dark)
	local s = New("Frame", {
		Name = "Shard",
		Size = UDim2.fromOffset(w, h),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 865,
		Parent = FxLayer,
	})
	Corner(s, 2)
	if dark then
		New("UIGradient", {
			Rotation = 140,
			Color = Seq({ Theme.Glass, Theme.Panel2, Theme.Background, Theme.Accent }),
			Transparency = NSeq({ { 0, 0.45 }, { 0.18, 0.05 }, { 0.7, 0.05 }, { 1, 0.45 } }),
			Parent = s,
		})
	else
		New("UIGradient", {
			Rotation = 135,
			Color = Seq({ Theme.Glass, Theme.Accent, Theme.Background, Theme.Accent2 }),
			Transparency = NSeq({ { 0, 0.4 }, { 0.3, 0.6 }, { 0.62, 0.1 }, { 1, 0.65 } }),
			Parent = s,
		})
	end
	local st = New("UIStroke", {
		Color = dark and Theme.Accent or Theme.Glass,
		Transparency = 0.45,
		Thickness = 1,
		Parent = s,
	})
	return s, st
end

local function Grid(rect, cols, rows, dark)
	local out = {}
	local cw, ch = rect.w / cols, rect.h / rows
	for y = 0, rows - 1 do
		for x = 0, cols - 1 do
			local w = cw * (1.05 + math.random() * 0.35)
			local h = ch * (1.05 + math.random() * 0.35)
			local tx = rect.x + (x + 0.5) * cw + (math.random() - 0.5) * cw * 0.3
			local ty = rect.y + (y + 0.5) * ch + (math.random() - 0.5) * ch * 0.3
			local s, st = MakeShard(w, h, dark)
			table.insert(out, {
				Frame = s, Stroke = st, TX = tx, TY = ty,
				DX = tx - (rect.x + rect.w / 2), DY = ty - (rect.y + rect.h / 2),
				Rot = (math.random() - 0.5) * 3,
			})
		end
	end
	return out
end

-- Annulation : les éclats encore visibles s'effacent vite au lieu de
-- disparaître d'un coup.
local function DissolveShards(list)
	for _, sh in ipairs(list) do
		if sh.Frame.Parent then
			Tween(sh.Frame, 0.14, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
			Tween(sh.Stroke, 0.14, { Transparency = 1 }, Enum.EasingStyle.Quad)
		end
	end
	task.delay(0.16, function()
		for _, sh in ipairs(list) do sh.Frame:Destroy() end
	end)
end

-- Le miroir se reforme : les éclats convergent, onFlash révèle la fenêtre.
function FX.Assemble(rect, onFlash, onDone)
	local list = Grid(rect, 8, 6, false)
	for _, sh in ipairs(list) do
		local len = math.max(math.sqrt(sh.DX * sh.DX + sh.DY * sh.DY), 1)
		local far = 420 + math.random() * 520
		sh.Frame.Position = UDim2.fromOffset(
			sh.TX + sh.DX / len * far + (math.random() - 0.5) * 200,
			sh.TY + sh.DY / len * far + (math.random() - 0.5) * 200)
		sh.Frame.Rotation = (math.random() - 0.5) * 540
		sh.Frame.BackgroundTransparency = 1
		sh.Stroke.Transparency = 1
		local info = TweenInfo.new(0.62, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, math.random() * 0.16)
		TweenService:Create(sh.Frame, info, {
			Position = UDim2.fromOffset(sh.TX, sh.TY),
			Rotation = sh.Rot,
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(sh.Stroke, info, { Transparency = 0.45 }):Play()
	end

	local cancelled = false
	task.delay(0.8, function()
		if cancelled then return end
		FX.Flash(rect)
		if onFlash then onFlash() end
		for _, sh in ipairs(list) do
			Tween(sh.Frame, 0.35, { BackgroundTransparency = 1 })
			Tween(sh.Stroke, 0.35, { Transparency = 1 })
		end
		task.delay(0.4, function()
			if cancelled then return end
			for _, sh in ipairs(list) do sh.Frame:Destroy() end
			if onDone then onDone() end
		end)
	end)
	return function()
		if cancelled then return end
		cancelled = true
		DissolveShards(list)
	end
end

-- L'illusion se brise : les éclats tombent avec la gravité.
function FX.Shatter(rect, onDone)
	local list = Grid(rect, 9, 6, true)
	for _, sh in ipairs(list) do
		sh.X, sh.Y, sh.R = sh.TX, sh.TY, sh.Rot
		sh.VX = sh.DX * 0.012 + (math.random() - 0.5) * 3.5
		sh.VY = -1.5 - math.random() * 3.5 + sh.DY * 0.006
		sh.VR = (math.random() - 0.5) * 9
		sh.Frame.Position = UDim2.fromOffset(sh.X, sh.Y)
		sh.Frame.Rotation = sh.R
	end
	local t = 0
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		t = t + dt
		local k = math.min(dt * 60, 3)
		local fade = math.clamp(1 - math.max(0, t - 0.55) / 0.8, 0, 1)
		for _, sh in ipairs(list) do
			sh.VY = sh.VY + 0.32 * k
			sh.X = sh.X + sh.VX * k
			sh.Y = sh.Y + sh.VY * k
			sh.R = sh.R + sh.VR * k
			sh.Frame.Position = UDim2.fromOffset(sh.X, sh.Y)
			sh.Frame.Rotation = sh.R
			sh.Frame.BackgroundTransparency = 1 - fade
			sh.Stroke.Transparency = 1 - fade * 0.55
		end
		if t >= 1.4 then
			conn:Disconnect()
			for _, sh in ipairs(list) do sh.Frame:Destroy() end
			if onDone then onDone() end
		end
	end)
	table.insert(Library.Connections, conn)
	return function()
		if not conn.Connected then return end
		conn:Disconnect()
		DissolveShards(list)
	end
end

-- Anneau blanc qui s'élargit autour d'un rectangle.
function FX.Flash(rect)
	local ring = New("Frame", {
		Name = "Flash",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(rect.x + rect.w / 2, rect.y + rect.h / 2),
		Size = UDim2.fromOffset(rect.w, rect.h),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		ZIndex = 868,
		Parent = FxLayer,
	})
	Corner(ring, 14)
	local st = New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = ring })
	Tween(ring, 0.55, { Size = UDim2.fromOffset(rect.w * 1.06, rect.h * 1.06), BackgroundTransparency = 1 })
	Tween(st, 0.55, { Transparency = 1, Thickness = 6 })
	task.delay(0.6, function() ring:Destroy() end)
end

-- Flou et assombrissement du jeu derrière le menu.
local BlurFx
local DimFx = New("Frame", {
	Name = "Dim",
	BackgroundColor3 = Color3.fromRGB(9, 7, 22),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Active = false,
	ZIndex = 0,
	Parent = ScreenGui,
})
-- Teinte violette en haut, presque noire en bas, plus une vignette sur les
-- quatre bords : le jeu derrière le menu prend la couleur du thème.
New("UIGradient", {
	Rotation = 90,
	Color = Seq({ Color3.fromRGB(26, 18, 56), Color3.fromRGB(9, 7, 22), Color3.fromRGB(3, 2, 6) }),
	Parent = DimFx,
})
local DimVignette = {}
for _, rotation in ipairs({ 90, 0 }) do
	local v = New("Frame", {
		Name = "Vignette",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 0,
		Parent = ScreenGui,
	})
	Gradient(v, nil, rotation, { { 0, 0.25 }, { 0.32, 1 }, { 0.68, 1 }, { 1, 0.25 } })
	table.insert(DimVignette, v)
end

function FX.GameBlur(on)
	FX.ClearBlur()
	if DimFx then DimFx.BackgroundTransparency = 1 end
	if DimVignette then
		for _, v in ipairs(DimVignette) do v.BackgroundTransparency = 1 end
	end
end

function FX.ClearBlur()
	pcall(function() if BlurFx then BlurFx:Destroy() end end)
	BlurFx = nil
end

-- Rectangle d'une fenêtre dans le repère du calque d'effets.
function FX.RectOf(gui, finalScale)
	local pos, size = ToFx(gui)
	local cx, cy = pos.X + size.X / 2, pos.Y + size.Y / 2
	local w, h = size.X, size.Y
	if finalScale then
		local sx = finalScale.X or w
		local sy = finalScale.Y or h
		w, h = sx, sy
	end
	return { x = cx - w / 2, y = cy - h / 2, w = w, h = h }
end

Library.FX = FX

--=====================================================================
-- Éléments (mixin partagé par tous les groupes)
--=====================================================================

local Elements = {}

-- Chaque ligne est connue de son groupe pour la recherche du menu.
local function TrackRow(group, row, text)
	if group.Rows then
		table.insert(group.Rows, { Frame = row, Text = string.lower(tostring(text or "")) })
	end
end

local function RowHover(row)
	local hover = New("Frame", {
		Name = "Hover",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 12, 1, 0),
		Position = UDim2.fromOffset(-6, 0),
		ZIndex = 0,
		Parent = row,
	})
	Library:Register(hover, { BackgroundColor3 = "ElementHover" })
	Corner(hover, 6)
	return hover
end

-- Le libellé s'arrête là où commencent les contrôles de droite, quelle que
-- soit leur largeur (champ de texte, raccourci + couleur, etc.).
local function FitLabel(lbl, addons, container)
	local function fit()
		local total = container.AbsoluteSize.X
		if total <= 0 then return end
		local used = addons.AbsoluteSize.X
		local ratio = used > 0 and (used / total) or 0
		lbl.Size = UDim2.new(1 - ratio, used > 0 and -10 or 0, 1, 0)
	end
	Library:Connect(addons:GetPropertyChangedSignal("AbsoluteSize"), fit)
	Library:Connect(container:GetPropertyChangedSignal("AbsoluteSize"), fit)
	task.defer(fit)
end

local function CompactRow(group, text, height, tip)
	local row = New("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or M.Row),
		Parent = group.Container,
	})
	local hover = RowHover(row)

	local lbl = Label(row, text, 13, "TextDim")
	lbl.Size = UDim2.new(1, -M.AddonSpace, 1, 0)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = 2

	local right = New("Frame", {
		Name = "Addons",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 10,
		Parent = row,
	})
	List(right, 7, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)
	FitLabel(lbl, right, row)

	if tip then
		local h = Hit(row, "Tip", 1)
		Library:Connect(h.MouseEnter, function() Library:ShowTooltip(tip) end)
		Library:Connect(h.MouseLeave, function() Library:HideTooltip() end)
	end

	TrackRow(group, row, text)
	return row, lbl, right, hover
end

local function WideRow(group, text, height, tip)
	local row = New("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		Parent = group.Container,
	})
	local hover = RowHover(row)

	local head = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.new(1, 0, 0, 20),
		ZIndex = 2,
		Parent = row,
	})

	local lbl = Label(head, text, 13, "TextDim")
	lbl.Size = UDim2.new(1, -M.AddonSpace, 1, 0)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = 2

	local right = New("Frame", {
		Name = "Addons",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 10,
		Parent = head,
	})
	List(right, 7, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)
	FitLabel(lbl, right, head)

	if tip then
		local h = Hit(head, "Tip", 1)
		Library:Connect(h.MouseEnter, function() Library:ShowTooltip(tip) end)
		Library:Connect(h.MouseLeave, function() Library:HideTooltip() end)
	end

	TrackRow(group, row, text)
	return row, lbl, right, head, hover
end

local function Bind(obj, flag, default)
	obj.Flag = flag
	obj.Value = default
	if flag then
		Library.Flags[flag] = default
		Library.Options[flag] = obj
	end
	return obj
end

local MiniToggle, MiniKeybind, MiniColorPicker

local function Addonable(obj, holder)
	function obj:AddToggle(flag, opts)
		MiniToggle(holder, flag, opts or {})
		return obj
	end
	function obj:AddKeybind(flag, opts)
		MiniKeybind(holder, flag, opts or {})
		return obj
	end
	function obj:AddColorPicker(flag, opts)
		MiniColorPicker(holder, flag, opts or {})
		return obj
	end
	return obj
end

--=====================================================================
-- Interrupteur
--=====================================================================

local function Switch(parent, w, h)
	w, h = w or M.SwitchW, h or M.SwitchH
	local track = New("Frame", {
		Name = "Switch",
		Size = UDim2.fromOffset(w, h),
		LayoutOrder = 1000,
		ZIndex = 11,
		Parent = parent,
	})
	Library:Register(track, { BackgroundColor3 = "Element" })
	Corner(track, "full")
	local stroke = Stroke(track, "Border")

	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 12,
		Parent = track,
	})
	Corner(fill, "full")
	AccentGradient(fill, function() return Seq({ Theme.AccentDim, Theme.Accent }) end)

	local k = h - 6
	local knob = New("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(k, k),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(141, 138, 166),
		BorderSizePixel = 0,
		ZIndex = 13,
		Parent = track,
	})
	Corner(knob, "full")
	local glow = New("UIStroke", { Color = Theme.Glass, Thickness = 0, Transparency = 0.4, Parent = knob })

	local function set(on, instant)
		local d = instant and 0 or 0.3
		Tween(fill, d, { BackgroundTransparency = on and 0 or 1 })
		Tween(stroke, d, { Transparency = on and 1 or 0 })
		Tween(knob, d, {
			Position = on and UDim2.new(1, -k - 3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(141, 138, 166),
		}, Enum.EasingStyle.Exponential)
		Tween(glow, d, { Thickness = on and 2 or 0 })
	end

	return track, set, knob
end

--=====================================================================
-- Toggle
--=====================================================================

local function LockChip(parent)
	local chip = New("Frame", {
		Name = "Lock",
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 990,
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.82,
		Visible = false,
		ZIndex = 11,
		Parent = parent,
	})
	Registry[chip] = { BackgroundColor3 = "Accent" }
	Corner(chip, 5)
	Stroke(chip, "Accent", 1, 0.5)
	Padding(chip, 0, 0, 6, 6)
	local t = MonoLabel(chip, "PREMIUM", 9, "Glass")
	t.AutomaticSize = Enum.AutomaticSize.X
	t.Size = UDim2.new(0, 0, 1, 0)
	t.ZIndex = 12
	return chip
end

function Elements:AddToggle(flag, opts)
	opts = opts or {}
	local text = opts.Text or opts.Name or flag
	local row, lbl, addons, hover = CompactRow(self, text, M.Row)

	local track, setVisual, knob = Switch(addons)
	local lock = LockChip(addons)

	local obj = Bind({}, flag, opts.Default == true)
	obj.Callback = opts.Callback
	obj.Label = lbl
	obj.Row = row
	obj.Locked = opts.Locked == true

	local hovering = false
	local function paintLabel()
		local key = obj.Locked and "TextFaint" or ((obj.Value or hovering) and "Text" or "TextDim")
		Tween(lbl, 0.14, { TextColor3 = Theme[key] })
	end

	local function refresh(fire, instant)
		setVisual(obj.Value, instant)
		paintLabel()
		if flag then Library.Flags[flag] = obj.Value end
		if fire and obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end

	function obj:Set(value, silent)
		local before = obj.Value
		obj.Value = value and true or false
		refresh(not silent)
		if obj.Value and not before and not silent then
			task.defer(function()
				FX.Sparks(knob.AbsolutePosition + knob.AbsoluteSize / 2, 9)
			end)
		end
	end
	function obj:Get() return obj.Value end
	function obj:SetText(t) lbl.Text = t end
	function obj:SetLocked(v)
		obj.Locked = v and true or false
		lock.Visible = obj.Locked
		track.BackgroundTransparency = obj.Locked and 0.5 or 0
		paintLabel()
	end

	local hit = Hit(row, "Toggle", 6)
	Library:Connect(hit.MouseButton1Click, function()
		if obj.Locked then
			if setclipboard then pcall(setclipboard, "https://discord.gg/Gp2N788WVh") end
			Library:Notify({
				Title = "🔒 VIP EXCLUSIVE",
				Content = opts.LockedText or "This feature is reserved for VIP members! (Discord link copied)",
				Duration = 3.5,
			})
			return
		end
		obj:Set(not obj.Value)
	end)
	Library:Connect(hit.MouseEnter, function()
		hovering = true
		paintLabel()
		Tween(hover, 0.12, { BackgroundTransparency = 0.55 })
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function()
		hovering = false
		paintLabel()
		Tween(hover, 0.12, { BackgroundTransparency = 1 })
		Library:HideTooltip()
	end)

	obj:SetLocked(obj.Locked)
	refresh(false, true)
	if opts.Default and opts.Callback then task.spawn(opts.Callback, true) end

	return Addonable(obj, addons)
end

MiniToggle = function(holder, flag, opts)
	local track, setVisual = Switch(holder, math.floor(M.SwitchW * 0.82), math.floor(M.SwitchH * 0.82))
	track.LayoutOrder = 500
	local obj = Bind({}, flag, opts.Default == true)
	obj.Callback = opts.Callback

	function obj:Set(value, silent)
		obj.Value = value and true or false
		setVisual(obj.Value)
		if flag then Library.Flags[flag] = obj.Value end
		if not silent and obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end
	function obj:Get() return obj.Value end

	local hit = Hit(track, "MiniToggle", 14)
	Library:Connect(hit.MouseButton1Click, function() obj:Set(not obj.Value) end)
	Library:Connect(hit.MouseEnter, function()
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function() Library:HideTooltip() end)

	setVisual(obj.Value, true)
	return obj
end

--=====================================================================
-- Bouton
--=====================================================================

function Elements:AddButton(text, opts)
	opts = opts or {}
	if type(text) == "table" then opts = text; text = opts.Text end
	local callback = opts.Callback or opts.Func

	local holder = New("Frame", {
		Name = "ButtonRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, M.Button + 4),
		Parent = self.Container,
	})
	TrackRow(self, holder, text)

	local btn = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, M.Button),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = holder,
	})
	Library:Register(btn, { BackgroundColor3 = "Element" })
	Corner(btn, 7)
	local stroke = Stroke(btn, "Border")
	local press = New("UIScale", { Scale = 1, Parent = btn })

	local lbl = Label(btn, text or "Button", 13, "Text", Enum.FontWeight.SemiBold)
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.ZIndex = 4

	if opts.Locked then
		local lock = LockChip(btn)
		lock.AnchorPoint = Vector2.new(1, 0.5)
		lock.Position = UDim2.new(1, -6, 0.5, 0)
		lock.Visible = true
	end

	if opts.Accent then
		btn.BackgroundColor3 = Color3.new(1, 1, 1)
		Registry[btn] = nil
		AccentGradient(btn, function()
			return Seq({ Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.12), Theme.AccentDim })
		end, 90)
		stroke.Transparency = 1
		Registry[lbl] = nil
		lbl.TextColor3 = Color3.new(1, 1, 1)
	end

	local hit = Hit(btn, "ButtonHit", 6)
	Library:Connect(hit.MouseEnter, function()
		if opts.Accent then
			Tween(btn, 0.12, { BackgroundTransparency = 0 })
		else
			Tween(btn, 0.12, { BackgroundColor3 = Theme.ElementHover })
			Tween(stroke, 0.12, { Color = opts.Danger and Theme.Danger or Theme.Accent })
		end
		if opts.Danger then Tween(lbl, 0.12, { TextColor3 = Theme.Danger }) end
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function()
		if not opts.Accent then
			Tween(btn, 0.12, { BackgroundColor3 = Theme.Element })
			Tween(stroke, 0.12, { Color = Theme.Border })
		end
		if opts.Danger then Tween(lbl, 0.12, { TextColor3 = Theme.Text }) end
		Library:HideTooltip()
	end)
	Library:Connect(hit.MouseButton1Down, function()
		Tween(press, 0.08, { Scale = 0.97 })
		FX.Ripple(btn, MousePos())
	end)
	Library:Connect(hit.MouseButton1Up, function()
		Tween(press, 0.2, { Scale = 1 }, Enum.EasingStyle.Exponential)
	end)
	Library:Connect(hit.Activated, function()
		if opts.Locked then
			if setclipboard then pcall(setclipboard, "https://discord.gg/Gp2N788WVh") end
			Library:Notify({
				Title = "🔒 VIP EXCLUSIVE",
				Content = opts.LockedText or "This feature is reserved for VIP members! (Discord link copied)",
				Duration = 3.5,
			})
			return
		end
		if callback then task.spawn(callback) end
	end)

	local obj = { Instance = btn }
	function obj:SetText(t) lbl.Text = t end
	return obj
end

--=====================================================================
-- Label, paragraphe, séparateur
--=====================================================================

function Elements:AddLabel(text, opts)
	opts = opts or {}
	local holder = New("Frame", {
		Name = "LabelRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		AutomaticSize = opts.Wrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
		Parent = self.Container,
	})
	TrackRow(self, holder, text)
	local lbl = Label(holder, text, opts.Size or 12.5, opts.Color or "TextDim")
	if opts.Wrap then
		lbl.TextWrapped = true
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.Size = UDim2.new(1, 0, 0, 0)
		lbl.TextYAlignment = Enum.TextYAlignment.Top
	end
	if opts.Center then lbl.TextXAlignment = Enum.TextXAlignment.Center end

	local obj = {}
	function obj:SetText(t) lbl.Text = tostring(t or "") end
	function obj:SetColor(c) Registry[lbl] = nil; lbl.TextColor3 = c end
	return obj
end

function Elements:AddParagraph(title, body)
	local holder = New("Frame", {
		Name = "Paragraph",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.Container,
	})
	Padding(holder, 4, 6, 0, 0)
	List(holder, 3, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
	TrackRow(self, holder, tostring(title) .. " " .. tostring(body))

	local t = Label(holder, title, 13, "Text", Enum.FontWeight.SemiBold)
	t.Size = UDim2.new(1, 0, 0, 17)

	local b = Label(holder, body, 12, "TextDim")
	b.TextWrapped = true
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.Size = UDim2.new(1, 0, 0, 0)
	b.TextYAlignment = Enum.TextYAlignment.Top

	local obj = {}
	function obj:SetTitle(v) t.Text = tostring(v) end
	function obj:SetBody(v) b.Text = tostring(v) end
	function obj:Set(v1, v2)
		if v1 ~= nil then t.Text = tostring(v1) end
		if v2 ~= nil then b.Text = tostring(v2) end
	end
	return obj
end

function Elements:AddDivider()
	local holder = New("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 11),
		Parent = self.Container,
	})
	local line = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		BorderSizePixel = 0,
		Parent = holder,
	})
	Library:Register(line, { BackgroundColor3 = "Border" })
	Gradient(line, nil, 0, { { 0, 1 }, { 0.5, 0 }, { 1, 1 } })
	return {}
end

--=====================================================================
-- Slider
--=====================================================================

function Elements:AddSlider(flag, opts)
	opts = opts or {}
	local text     = opts.Text or opts.Name or flag
	local min      = opts.Min or 0
	local max      = opts.Max or 100
	local rounding = opts.Rounding or 0
	local suffix   = opts.Suffix or ""
	local default  = math.clamp(opts.Default or min, min, max)

	local row, lbl, addons, _, hover = WideRow(self, text, M.RowSlider, opts.Tooltip)

	local chip = New("Frame", {
		Name = "Value",
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = -1,
		ZIndex = 11,
		Parent = addons,
	})
	Library:Register(chip, { BackgroundColor3 = "Element" })
	Corner(chip, 5)
	Padding(chip, 0, 0, 6, 6)
	local valueLabel = MonoLabel(chip, "", 10.5, "Glass")
	valueLabel.AutomaticSize = Enum.AutomaticSize.X
	valueLabel.Size = UDim2.new(0, 0, 1, 0)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center
	valueLabel.ZIndex = 12

	local track = New("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 6),
		ZIndex = 3,
		Parent = row,
	})
	Library:Register(track, { BackgroundColor3 = "ElementHover" })
	Corner(track, "full")

	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = track,
	})
	Corner(fill, "full")
	AccentGradient(fill, DimToCyan)

	local knob = New("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = track,
	})
	Corner(knob, "full")
	local knobGlow = New("UIStroke", { Thickness = 3, Transparency = 0.55, Parent = knob })
	Library:Register(knobGlow, { Color = "Accent" })

	local obj = Bind({}, flag, default)
	obj.Callback = opts.Callback

	local function paint(instant)
		local alpha = (max - min) == 0 and 0 or (obj.Value - min) / (max - min)
		local dur = instant and 0 or 0.08
		Tween(fill, dur, { Size = UDim2.fromScale(alpha, 1) })
		Tween(knob, dur, { Position = UDim2.fromScale(alpha, 0.5) })
		valueLabel.Text = tostring(Round(obj.Value, rounding)) .. suffix
	end

	function obj:Set(value, silent)
		value = math.clamp(Round(tonumber(value) or min, rounding), min, max)
		local changed = value ~= obj.Value
		obj.Value = value
		if flag then Library.Flags[flag] = value end
		paint()
		if not silent and obj.Callback and changed then task.spawn(obj.Callback, value) end
	end
	function obj:Get() return obj.Value end
	function obj:SetRange(newMin, newMax)
		min, max = newMin, newMax
		obj:Set(obj.Value, true)
	end

	local dragging = false
	local function updateFromMouse(input)
		local mx = InputPos(input).X
		local a = math.clamp((mx - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * a)
	end

	local hit = Hit(track, "SliderHit", 8)
	hit.Size = UDim2.new(1, 0, 1, 18)
	hit.Position = UDim2.fromOffset(0, -9)

	Library:Connect(hit.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Tween(knob, 0.12, { Size = UDim2.fromOffset(15, 15) })
			updateFromMouse(input)
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			Tween(knob, 0.18, { Size = UDim2.fromOffset(12, 12) }, Enum.EasingStyle.Exponential)
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromMouse(input)
		end
	end)
	Library:Connect(hit.MouseEnter, function()
		Tween(lbl, 0.12, { TextColor3 = Theme.Text })
		Tween(hover, 0.12, { BackgroundTransparency = 0.55 })
	end)
	Library:Connect(hit.MouseLeave, function()
		Tween(lbl, 0.12, { TextColor3 = Theme.TextDim })
		Tween(hover, 0.12, { BackgroundTransparency = 1 })
	end)

	paint(true)
	if opts.Callback and opts.FireOnStart then task.spawn(opts.Callback, obj.Value) end

	return Addonable(obj, addons)
end

--=====================================================================
-- Popups (liste déroulante, sélecteur de couleur)
--=====================================================================

local function PointInside(gui, point)
	local p, s = gui.AbsolutePosition, gui.AbsoluteSize
	return point.X >= p.X and point.X <= p.X + s.X and point.Y >= p.Y and point.Y <= p.Y + s.Y
end

-- width peut être un nombre ou une fonction (largeur logique recalculée à l'ouverture).
local function MakePopup(anchorGui, width, height)
	local function W() return type(width) == "function" and width() or width end

	local popup = New("Frame", {
		Name = "Popup",
		Size = UDim2.fromOffset(W(), height),
		Visible = false,
		ZIndex = 510,
		ClipsDescendants = true,
		Parent = PopupLayer,
	})
	Library:Register(popup, { BackgroundColor3 = "Panel2" })
	Corner(popup, 8)
	local stroke = Stroke(popup, "Accent", 1, 0.5)
	local scale = New("UIScale", { Scale = Factor(), Parent = popup })

	-- Fondu de tout le contenu (fond, textes, liserés) et léger glissement
	-- vertical, comme l'aperçu web. On mémorise la transparence voulue de
	-- chaque objet à l'ouverture, puis on la rejoue depuis 1.
	local slide = New("NumberValue", { Value = 0 })
	local FADE_PROPS = {
		{ "GuiObject", "BackgroundTransparency" },
		{ "TextLabel", "TextTransparency" }, { "TextButton", "TextTransparency" }, { "TextBox", "TextTransparency" },
		{ "ImageLabel", "ImageTransparency" }, { "ImageButton", "ImageTransparency" },
		{ "UIStroke", "Transparency" },
		{ "ScrollingFrame", "ScrollBarImageTransparency" },
	}
	local saved -- { {inst, prop, value}, ... } pendant qu'une fermeture est en cours
	local openList
	local function restore()
		if not saved then return end
		for _, e in ipairs(saved) do pcall(function() e[1][e[2]] = e[3] end) end
		saved = nil
	end
	local function snapshot()
		local list = {}
		for _, d in ipairs(popup:GetDescendants()) do
			for _, fp in ipairs(FADE_PROPS) do
				if d:IsA(fp[1]) and d[fp[2]] < 1 then
					table.insert(list, { d, fp[2], d[fp[2]] })
				end
			end
		end
		return list
	end
	local function fadeTo(list, visible, dur)
		for _, e in ipairs(list) do
			if visible then e[1][e[2]] = 1 end
			Tween(e[1], dur, { [e[2]] = visible and e[3] or 1 }, Enum.EasingStyle.Quad)
		end
	end

	local followConn
	local function reposition()
		local origin = PopupLayer.AbsolutePosition
		local ap, as = anchorGui.AbsolutePosition, anchorGui.AbsoluteSize
		local vp = ScreenGui.AbsoluteSize
		local f = Factor()
		local w = popup.Size.X.Offset * f
		local h = popup.Size.Y.Offset * f
		local x = math.clamp(ap.X - origin.X, 6, math.max(vp.X - w - 6, 6))
		local y = ap.Y - origin.Y + as.Y + 4
		if y + h > vp.Y - 6 then
			y = math.max(ap.Y - origin.Y - h - 4, 6)
		end
		popup.Position = UDim2.fromOffset(x, y + slide.Value * f)
	end

	local isOpen = false
	local closeFn

	local function close()
		if not isOpen then return end
		isOpen = false
		if followConn then followConn:Disconnect(); followConn = nil end
		-- Les valeurs voulues sont celles de l'ouverture (une fermeture en plein
		-- fondu d'ouverture ne doit pas figer des valeurs intermédiaires).
		local list = openList or snapshot()
		saved = list
		Tween(popup, 0.16, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
		Tween(stroke, 0.16, { Transparency = 1 }, Enum.EasingStyle.Quad)
		fadeTo(list, false, 0.14)
		Tween(slide, 0.16, { Value = 6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.17, function()
			if not isOpen then
				popup.Visible = false
				restore()
			end
		end)
		if ActivePopup == closeFn then ActivePopup = nil end
	end
	closeFn = close

	local function open()
		CloseActivePopup()
		isOpen = true
		popup.Size = UDim2.fromOffset(W(), popup.Size.Y.Offset)
		scale.Scale = Factor()
		restore()
		slide.Value = 10
		reposition()
		popup.Visible = true
		popup.BackgroundTransparency = 1
		stroke.Transparency = 1
		openList = snapshot()
		fadeTo(openList, true, 0.26)
		Tween(popup, 0.2, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad)
		Tween(stroke, 0.26, { Transparency = 0.5 }, Enum.EasingStyle.Quad)
		Tween(slide, 0.45, { Value = 0 }, Enum.EasingStyle.Exponential)
		followConn = RunService.RenderStepped:Connect(reposition)
		ActivePopup = closeFn
	end

	local function toggle()
		if isOpen then close() else open() end
	end

	Library:Connect(UserInputService.InputBegan, function(input)
		if not isOpen then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local p = MousePos()
		if not PointInside(popup, p) and not PointInside(anchorGui, p) then
			close()
		end
	end)

	return popup, open, close, toggle, function() return isOpen end
end

local function FieldBox(parent, width, height, radius)
	local box = New("Frame", {
		Name = "Field",
		Size = width and UDim2.fromOffset(width, height or M.Field) or UDim2.new(1, 0, 0, height or M.Field),
		ZIndex = 11,
		Parent = parent,
	})
	Library:Register(box, { BackgroundColor3 = "Element" })
	Corner(box, radius or 7)
	local stroke = Stroke(box, "BorderSoft")
	return box, stroke
end

-- Chevron dessiné en deux traits.
local function Chevron(parent)
	local holder = New("Frame", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -9, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 13,
		Parent = parent,
	})
	for i = 1, 2 do
		local bar = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, i == 1 and -2 or 2, 0.5, 1),
			Size = UDim2.fromOffset(6, 1.5),
			Rotation = i == 1 and 45 or -45,
			BorderSizePixel = 0,
			ZIndex = 13,
			Parent = holder,
		})
		Library:Register(bar, { BackgroundColor3 = "TextFaint" })
	end
	return holder
end

-- Coche dessinée (deux traits).
local function Check(parent, zindex)
	local holder = New("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
		ZIndex = zindex,
		Parent = parent,
	})
	local a = New("Frame", { Position = UDim2.fromOffset(1, 5), Size = UDim2.fromOffset(4, 2), Rotation = 45, BorderSizePixel = 0, ZIndex = zindex, Parent = holder })
	local b = New("Frame", { Position = UDim2.fromOffset(3, 4), Size = UDim2.fromOffset(8, 2), Rotation = -50, BorderSizePixel = 0, ZIndex = zindex, Parent = holder })
	Library:Register(a, { BackgroundColor3 = "Accent" })
	Library:Register(b, { BackgroundColor3 = "Accent" })
	return holder
end

--=====================================================================
-- Liste déroulante
--=====================================================================

function Elements:AddDropdown(flag, opts)
	opts = opts or {}
	local text        = opts.Text or opts.Name or flag
	local values      = opts.Values or opts.Options or {}
	local multi       = opts.Multi == true
	local maxShow     = opts.MaxVisible or 7
	local placeholder = opts.Placeholder or "---"

	local row, lbl, addons, _, hover = WideRow(self, text, M.RowWide, opts.Tooltip)
	local box, boxStroke = FieldBox(row, nil, M.Field)
	box.AnchorPoint = Vector2.new(0, 1)
	box.Position = UDim2.new(0, 0, 1, -3)

	local display = Label(box, "", 12.5, "TextFaint")
	display.Position = UDim2.fromOffset(10, 0)
	display.Size = UDim2.new(1, -30, 1, 0)
	display.TextTruncate = Enum.TextTruncate.AtEnd
	display.ZIndex = 12
	local chev = Chevron(box)

	local default = multi and (opts.Default or {}) or opts.Default
	if multi and type(default) ~= "table" then default = { default } end
	local obj = Bind({}, flag, default)
	obj.Callback = opts.Callback
	obj.Values = values

	local ROW_H = 26
	local function popupWidth()
		return math.max(box.AbsoluteSize.X / Factor(), 140)
	end
	local popup, open, close, toggle, isOpen = MakePopup(box, popupWidth, 40)

	local searchBox
	local searchH = 0
	local function wantsSearch() return #obj.Values > 8 end

	local searchHolder = New("Frame", {
		Name = "Search",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 26),
		Position = UDim2.fromOffset(5, 5),
		Visible = false,
		ZIndex = 512,
		Parent = popup,
	})
	do
		local sb = FieldBox(searchHolder, nil, 26, 6)
		sb.ZIndex = 512
		searchBox = New("TextBox", {
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Search...",
			FontFace = FontText(),
			TextSize = TS(12),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.fromOffset(8, 0),
			ZIndex = 513,
			Parent = sb,
		})
		Library:Register(searchBox, { TextColor3 = "Text", PlaceholderColor3 = "TextFaint" })
	end

	local scroller = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ZIndex = 511,
		Parent = popup,
	})
	Padding(scroller, 4, 4, 4, 4)
	List(scroller, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local optionButtons = {}

	local function isSelected(v)
		if multi then
			for _, sel in ipairs(obj.Value) do
				if sel == v then return true end
			end
			return false
		end
		return obj.Value == v
	end

	local function refreshDisplay()
		local txt
		if multi then
			local parts = {}
			for _, v in ipairs(obj.Value) do table.insert(parts, tostring(v)) end
			txt = #parts > 0 and table.concat(parts, ", ") or placeholder
		else
			txt = obj.Value ~= nil and tostring(obj.Value) or placeholder
		end
		display.Text = txt
		Tween(display, 0.12, { TextColor3 = (txt == placeholder) and Theme.TextFaint or Theme.Text })

		for value, entry in pairs(optionButtons) do
			local on = isSelected(value)
			Tween(entry.Label, 0.12, { TextColor3 = on and Theme.Text or Theme.TextDim })
			Tween(entry.Frame, 0.12, { BackgroundTransparency = on and 0.8 or 1 })
			entry.Check.Visible = on
		end
	end

	local function fire()
		if flag then Library.Flags[flag] = obj.Value end
		if obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end

	local function sizePopup(visibleCount)
		searchH = wantsSearch() and 32 or 0
		searchHolder.Visible = searchH > 0
		scroller.Position = UDim2.fromOffset(0, searchH)
		scroller.Size = UDim2.new(1, 0, 1, -searchH)
		local shown = math.min(visibleCount, maxShow)
		popup.Size = UDim2.fromOffset(popup.Size.X.Offset, math.max(shown * (ROW_H + 2) + 10 + searchH, 38))
	end

	local function applySearch()
		local q = string.lower(searchBox.Text or "")
		local count = 0
		for value, entry in pairs(optionButtons) do
			local ok = q == "" or string.find(string.lower(tostring(value)), q, 1, true) ~= nil
			entry.Frame.Visible = ok
			if ok then count = count + 1 end
		end
		sizePopup(count)
	end

	local function buildOptions()
		for _, entry in pairs(optionButtons) do entry.Frame:Destroy() end
		table.clear(optionButtons)

		for i, value in ipairs(obj.Values) do
			local item = New("Frame", {
				Name = "Option",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, ROW_H),
				LayoutOrder = i,
				ZIndex = 512,
				Parent = scroller,
			})
			Library:Register(item, { BackgroundColor3 = "Accent" })
			Corner(item, 5)

			local ol = Label(item, tostring(value), 12.5, "TextDim")
			ol.Position = UDim2.fromOffset(9, 0)
			ol.Size = UDim2.new(1, -30, 1, 0)
			ol.TextTruncate = Enum.TextTruncate.AtEnd
			ol.ZIndex = 513

			local check = Check(item, 514)
			check.Visible = false

			local h = Hit(item, "OptionHit", 515)
			Library:Connect(h.MouseEnter, function()
				if not isSelected(value) then Tween(item, 0.1, { BackgroundTransparency = 0.9 }) end
			end)
			Library:Connect(h.MouseLeave, function()
				Tween(item, 0.1, { BackgroundTransparency = isSelected(value) and 0.8 or 1 })
			end)
			Library:Connect(h.MouseButton1Click, function()
				if multi then
					local removed = false
					for idx, sel in ipairs(obj.Value) do
						if sel == value then
							table.remove(obj.Value, idx)
							removed = true
							break
						end
					end
					if not removed then table.insert(obj.Value, value) end
				else
					if obj.Value == value and opts.AllowNull then
						obj.Value = nil
					else
						obj.Value = value
					end
					close()
					Tween(chev, 0.16, { Rotation = 0 })
				end
				refreshDisplay()
				fire()
			end)

			optionButtons[value] = { Frame = item, Label = ol, Check = check }
		end
		applySearch()
	end

	function obj:Set(value, silent)
		if multi and type(value) ~= "table" then
			value = value ~= nil and { value } or {}
		end
		obj.Value = value
		refreshDisplay()
		if flag then Library.Flags[flag] = obj.Value end
		if not silent and obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end
	function obj:Get() return obj.Value end
	function obj:SetValues(newValues, keep)
		obj.Values = newValues or {}
		buildOptions()
		if not keep then
			obj.Value = multi and {} or nil
		end
		refreshDisplay()
	end

	Library:Connect(searchBox:GetPropertyChangedSignal("Text"), applySearch)

	local h = Hit(box, "DropdownHit", 14)
	Library:Connect(h.MouseButton1Click, function()
		if not isOpen() then
			searchBox.Text = ""
		end
		toggle()
		Tween(chev, 0.18, { Rotation = isOpen() and 180 or 0 })
		Tween(boxStroke, 0.15, { Color = isOpen() and Theme.Accent or Theme.BorderSoft })
	end)
	Library:Connect(h.MouseEnter, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
		Tween(lbl, 0.12, { TextColor3 = Theme.Text })
		Tween(hover, 0.12, { BackgroundTransparency = 0.55 })
	end)
	Library:Connect(h.MouseLeave, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
		Tween(lbl, 0.12, { TextColor3 = Theme.TextDim })
		Tween(hover, 0.12, { BackgroundTransparency = 1 })
	end)
	Library:Connect(popup:GetPropertyChangedSignal("Visible"), function()
		if not popup.Visible then
			Tween(chev, 0.16, { Rotation = 0 })
			Tween(boxStroke, 0.15, { Color = Theme.BorderSoft })
		end
	end)

	buildOptions()
	refreshDisplay()

	return Addonable(obj, addons)
end

--=====================================================================
-- Champ texte
--=====================================================================

function Elements:AddTextbox(flag, opts)
	opts = opts or {}
	local text = opts.Text or opts.Name or flag
	local row, lbl, addons = CompactRow(self, text, M.Row + 2, opts.Tooltip)
	local box, stroke = FieldBox(addons, opts.Width or M.FieldW, M.Field - 2, 6)

	local input = New("TextBox", {
		BackgroundTransparency = 1,
		Text = opts.Default or "",
		PlaceholderText = opts.Placeholder or "...",
		FontFace = FontText(),
		TextSize = TS(12.5),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = opts.ClearOnFocus == true,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		ClipsDescendants = true,
		ZIndex = 12,
		Parent = box,
	})
	Library:Register(input, { TextColor3 = "Text", PlaceholderColor3 = "TextFaint" })

	local obj = Bind({}, flag, opts.Default or "")
	obj.Callback = opts.Callback

	function obj:Set(value, silent)
		obj.Value = tostring(value or "")
		input.Text = obj.Value
		if flag then Library.Flags[flag] = obj.Value end
		if not silent and obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end
	function obj:Get() return obj.Value end

	Library:Connect(input.FocusLost, function(enter)
		obj.Value = input.Text
		if flag then Library.Flags[flag] = obj.Value end
		if obj.Callback then task.spawn(obj.Callback, obj.Value, enter) end
		Tween(stroke, 0.15, { Color = Theme.BorderSoft })
	end)
	Library:Connect(input.Focused, function()
		Tween(stroke, 0.15, { Color = Theme.Accent })
	end)

	return Addonable(obj, addons)
end

--=====================================================================
-- Raccourci
--=====================================================================

local KeybindRegistry = {}

local KEY_ALIAS = {
	LeftShift = "LShift", RightShift = "RShift",
	LeftControl = "LCtrl", RightControl = "RCtrl",
	LeftAlt = "LAlt", RightAlt = "RAlt",
	MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
	Backspace = "BSpc", Return = "Enter", Escape = "Esc", Space = "Spc",
}

local function KeyName(key)
	if key == nil then return "NONE" end
	local name = typeof(key) == "EnumItem" and key.Name or tostring(key)
	return KEY_ALIAS[name] or name
end

Library.KeyName = KeyName

local function BuildKeybind(parent, flag, opts, withLabel)
	opts = opts or {}
	local modes = opts.Modes or { "Always", "Toggle", "Hold" }

	local box, stroke = FieldBox(parent, opts.Width or M.KeybindW, (withLabel and M.Field or M.Field - 4) - 4, 5)
	box.LayoutOrder = 700
	local display = MonoLabel(box, "", 10, "TextDim")
	display.TextXAlignment = Enum.TextXAlignment.Center
	display.ZIndex = 12

	local obj = Bind({}, flag, { Key = opts.Default, Mode = opts.Mode or modes[1] })
	obj.Callback = opts.Callback
	obj.Changed = opts.Changed
	obj.Modes = modes
	obj.Active = false

	local listening = false

	local function paint()
		display.Text = listening and "..." or string.upper(KeyName(obj.Value.Key))
		Tween(display, 0.12, {
			TextColor3 = listening and Theme.Accent or (obj.Value.Key and Theme.Text or Theme.TextFaint),
		})
		Tween(stroke, 0.12, { Color = listening and Theme.Accent or Theme.BorderSoft })
	end

	function obj:Set(value, silent)
		if typeof(value) == "EnumItem" or type(value) == "string" then
			value = { Key = value, Mode = obj.Value.Mode }
		end
		obj.Value = {
			Key = value and value.Key or nil,
			Mode = (value and value.Mode) or obj.Value.Mode or modes[1],
		}
		if flag then Library.Flags[flag] = obj.Value end
		paint()
		if not silent and obj.Changed then task.spawn(obj.Changed, obj.Value) end
	end
	function obj:Get() return obj.Value end

	function obj:GetState()
		if not obj.Value.Key then return false end
		if obj.Value.Mode == "Always" then return true end
		return obj.Active
	end

	local h = Hit(box, "KeybindHit", 14)
	Library:Connect(h.MouseButton1Click, function()
		if not UserInputService.KeyboardEnabled then
			Library:Notify({
				Title = opts.Text or opts.Name or "Shortcut",
				Content = "No keyboard on this device.",
				Duration = 2,
			})
			return
		end
		listening = true
		paint()
	end)
	Library:Connect(h.MouseButton2Click, function()
		local idx = table.find(modes, obj.Value.Mode) or 1
		local nextMode = modes[(idx % #modes) + 1]
		obj:Set({ Key = obj.Value.Key, Mode = nextMode })
		Library:Notify({ Title = opts.Text or flag or "Keybind", Content = "Mode: " .. nextMode, Duration = 2 })
	end)
	Library:Connect(h.MouseEnter, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
		Library:ShowTooltip(opts.Tooltip or "Left click: assign  ·  Right click: mode")
	end)
	Library:Connect(h.MouseLeave, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
		Library:HideTooltip()
	end)

	-- Le raccourci en écoute clignote.
	local blinkT = 0
	Library:Connect(RunService.Heartbeat, function(dt)
		if not listening then return end
		blinkT = blinkT + dt
		display.TextTransparency = (math.floor(blinkT * 4) % 2 == 0) and 0 or 0.5
	end)

	Library:Connect(UserInputService.InputBegan, function(input, processed)
		if listening then
			local key
			if input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3 then
				key = input.UserInputType
			end
			if key then
				listening = false
				display.TextTransparency = 0
				if key == Enum.KeyCode.Backspace then
					obj:Set({ Key = nil, Mode = obj.Value.Mode })
				else
					obj:Set({ Key = key, Mode = obj.Value.Mode })
				end
			end
			return
		end

		if processed or not obj.Value.Key then return end
		local matches = (input.KeyCode == obj.Value.Key) or (input.UserInputType == obj.Value.Key)
		if not matches then return end

		if obj.Value.Mode == "Toggle" then
			obj.Active = not obj.Active
		else
			obj.Active = true
		end
		if obj.Callback then task.spawn(obj.Callback, obj:GetState()) end
	end)

	Library:Connect(UserInputService.InputEnded, function(input)
		if not obj.Value.Key or obj.Value.Mode ~= "Hold" then return end
		local matches = (input.KeyCode == obj.Value.Key) or (input.UserInputType == obj.Value.Key)
		if matches then
			obj.Active = false
			if obj.Callback then task.spawn(obj.Callback, false) end
		end
	end)

	obj.DisplayName = opts.Text or opts.Name or flag or "Keybind"
	table.insert(KeybindRegistry, obj)

	paint()
	return obj
end

function Elements:AddKeybind(flag, opts)
	opts = opts or {}
	local _, _, addons = CompactRow(self, opts.Text or opts.Name or flag, M.Row, opts.Tooltip)
	local obj = BuildKeybind(addons, flag, opts, true)
	return Addonable(obj, addons)
end

MiniKeybind = function(holder, flag, opts)
	return BuildKeybind(holder, flag, opts, false)
end

--=====================================================================
-- Sélecteur de couleur
--=====================================================================

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,   0,   0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255,   0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(  0, 255,   0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(  0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(  0,   0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,   0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,   0,   0)),
})

local function BuildColorPicker(parent, flag, opts)
	opts = opts or {}
	local useAlpha = opts.Alpha == true

	local swatch = New("Frame", {
		Name = "Swatch",
		Size = UDim2.fromOffset(opts.Width or M.Swatch, M.SwatchH),
		BackgroundColor3 = opts.Default or Theme.Accent,
		LayoutOrder = 600,
		ZIndex = 11,
		Parent = parent,
	})
	Corner(swatch, 5)
	New("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.8, Parent = swatch })

	local obj = Bind({}, flag, opts.Default or Theme.Accent)
	obj.Alpha = opts.DefaultAlpha or 1
	obj.Callback = opts.Callback

	local h, s, v = Color3.toHSV(obj.Value)

	local W, SVH = 176, 112
	local popH = 10 + SVH + 8 + (useAlpha and 20 or 0) + 26 + 10
	local popup, _, _, toggle = MakePopup(swatch, W + 20, popH)

	local body = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 511,
		Parent = popup,
	})
	Padding(body, 10, 10, 10, 10)
	List(body, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local topRow = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, SVH),
		LayoutOrder = 1,
		ZIndex = 511,
		Parent = body,
	})

	local sv = New("Frame", {
		Size = UDim2.new(1, -22, 1, 0),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 512,
		Parent = topRow,
	})
	Corner(sv, 6)

	local whiteLayer = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 513,
		Parent = sv,
	})
	Corner(whiteLayer, 6)
	Gradient(whiteLayer, nil, 0, { { 0, 0 }, { 1, 1 } })

	local blackLayer = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 514,
		Parent = sv,
	})
	Corner(blackLayer, 6)
	Gradient(blackLayer, nil, 90, { { 0, 1 }, { 1, 0 } })

	local svCursor = New("Frame", {
		Size = UDim2.fromOffset(10, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 516,
		Parent = sv,
	})
	Corner(svCursor, "full")
	New("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Parent = svCursor })

	local hue = New("Frame", {
		Size = UDim2.new(0, 12, 1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 512,
		Parent = topRow,
	})
	Corner(hue, "full")
	New("UIGradient", { Color = RAINBOW, Rotation = 90, Parent = hue })

	local hueCursor = New("Frame", {
		Size = UDim2.new(1, 4, 0, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 515,
		Parent = hue,
	})
	Corner(hueCursor, "full")

	local alphaBar, alphaCursor, alphaGradient
	if useAlpha then
		alphaBar = New("Frame", {
			Size = UDim2.new(1, 0, 0, 12),
			LayoutOrder = 2,
			BackgroundColor3 = Color3.fromRGB(20, 18, 32),
			BorderSizePixel = 0,
			ZIndex = 512,
			Parent = body,
		})
		Corner(alphaBar, "full")
		alphaGradient = New("UIGradient", {
			Color = ColorSequence.new(obj.Value),
			Transparency = NSeq({ { 0, 1 }, { 1, 0 } }),
			Parent = alphaBar,
		})
		alphaCursor = New("Frame", {
			Size = UDim2.new(0, 4, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 513,
			Parent = alphaBar,
		})
		Corner(alphaCursor, "full")
	end

	local hexBox = FieldBox(body, nil, 26, 6)
	hexBox.LayoutOrder = 3
	hexBox.ZIndex = 512

	local hexInput = New("TextBox", {
		BackgroundTransparency = 1,
		Text = "#FFFFFF",
		FontFace = FontMono(),
		TextSize = TS(12),
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 513,
		Parent = hexBox,
	})
	Library:Register(hexInput, { TextColor3 = "Text" })

	local function apply(silent)
		obj.Value = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = obj.Value
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.fromScale(s, 1 - v)
		hueCursor.Position = UDim2.new(0.5, 0, h, 0)
		hexInput.Text = string.format("#%02X%02X%02X",
			math.floor(obj.Value.R * 255 + 0.5),
			math.floor(obj.Value.G * 255 + 0.5),
			math.floor(obj.Value.B * 255 + 0.5))
		if alphaGradient then
			alphaGradient.Color = ColorSequence.new(obj.Value)
			alphaCursor.Position = UDim2.new(obj.Alpha, 0, 0.5, 0)
		end
		if flag then
			Library.Flags[flag] = obj.Value
			Library.Flags[flag .. "_Alpha"] = obj.Alpha
		end
		if not silent and obj.Callback then task.spawn(obj.Callback, obj.Value, obj.Alpha) end
	end

	function obj:Set(color, alpha, silent)
		if typeof(color) == "Color3" then
			h, s, v = Color3.toHSV(color)
		end
		if type(alpha) == "number" then obj.Alpha = math.clamp(alpha, 0, 1) end
		if type(alpha) == "boolean" then silent = alpha end
		apply(silent)
	end
	function obj:Get() return obj.Value, obj.Alpha end

	local function bindDrag(gui, onMove)
		local dragging = false
		local hh = Hit(gui, "PickHit", 520)
		Library:Connect(hh.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				onMove(input)
			end
		end)
		Library:Connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		Library:Connect(UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				onMove(input)
			end
		end)
	end

	bindDrag(sv, function(input)
		local p = InputPos(input)
		s = math.clamp((p.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
		v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
		apply()
	end)

	bindDrag(hue, function(input)
		local p = InputPos(input)
		h = math.clamp((p.Y - hue.AbsolutePosition.Y) / math.max(hue.AbsoluteSize.Y, 1), 0, 0.999)
		apply()
	end)

	if useAlpha then
		bindDrag(alphaBar, function(input)
			local p = InputPos(input)
			obj.Alpha = math.clamp((p.X - alphaBar.AbsolutePosition.X) / math.max(alphaBar.AbsoluteSize.X, 1), 0, 1)
			apply()
		end)
	end

	Library:Connect(hexInput.FocusLost, function()
		local hexStr = hexInput.Text:gsub("#", "")
		if #hexStr == 6 and tonumber(hexStr, 16) then
			local n = tonumber(hexStr, 16)
			local color = Color3.fromRGB(
				bit32.band(bit32.rshift(n, 16), 255),
				bit32.band(bit32.rshift(n, 8), 255),
				bit32.band(n, 255))
			h, s, v = Color3.toHSV(color)
		end
		apply()
	end)

	local hh = Hit(swatch, "SwatchHit", 14)
	Library:Connect(hh.MouseButton1Click, toggle)
	Library:Connect(hh.MouseEnter, function()
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hh.MouseLeave, function() Library:HideTooltip() end)

	apply(true)
	return obj
end

function Elements:AddColorPicker(flag, opts)
	opts = opts or {}
	local _, _, addons = CompactRow(self, opts.Text or opts.Name or flag, M.Row, opts.Tooltip)
	local obj = BuildColorPicker(addons, flag, opts)
	return Addonable(obj, addons)
end

MiniColorPicker = function(holder, flag, opts)
	return BuildColorPicker(holder, flag, opts)
end

--=====================================================================
-- Groupe
--=====================================================================

local Group = {}
Group.__index = setmetatable(Group, { __index = Elements })

local function CreateGroup(page, title, side, opts)
	opts = opts or {}
	local column = (side == "Right" or side == 2) and page.Right or page.Left

	local frame = New("Frame", {
		Name = "Group",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		LayoutOrder = #page.Groups + 1,
		Parent = column,
	})
	Library:Register(frame, { BackgroundColor3 = "Panel" })
	Corner(frame, 9)
	local stroke = Stroke(frame, "BorderSoft")

	List(frame, 0, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local header = New("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, M.Header),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		ClipsDescendants = true,
		Parent = frame,
	})
	-- Roblox coupe en rectangle, pas selon l'arrondi du groupe : un fond carré
	-- rendrait les coins du haut carrés. Le fond est donc arrondi et dépasse
	-- vers le bas, où l'en-tête le coupe net.
	local headerBg = New("Frame", {
		Name = "Bg",
		Size = UDim2.new(1, 0, 1, 12),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = header,
	})
	Corner(headerBg, 9)
	AccentGradient(headerBg, function() return Seq({ Theme.Accent, Theme.Accent }) end, 0,
		{ { 0, 0.82 }, { 0.8, 1 }, { 1, 1 } })

	local headerLine = New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = header,
	})
	Library:Register(headerLine, { BackgroundColor3 = "BorderSoft" })

	local dia = Diamond(header, 6, 3)
	dia.Position = UDim2.new(0, 14, 0.5, 0)

	local titleLabel = MonoLabel(header, title or "GROUP", 11, "Glass")
	titleLabel.FontFace = FontMono(Enum.FontWeight.Bold)
	titleLabel.Position = UDim2.fromOffset(26, 0)
	titleLabel.Size = UDim2.new(1, -70, 1, 0)
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = 3

	-- Balayage de lumière sur le titre (joué à l'apparition).
	local headerSweep = New("Frame", {
		Name = "HeaderSweep",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.5, 1),
		Position = UDim2.fromScale(-0.5, 0),
		ZIndex = 4,
		Parent = header,
	})
	Gradient(headerSweep, nil, 0, { { 0, 1 }, { 0.5, 0.7 }, { 1, 1 } })

	local body = New("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = frame,
	})

	local container = New("Frame", {
		Name = "Container",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = body,
	})
	Padding(container, M.GroupPadT, M.GroupPadB, M.GroupPadX, M.GroupPadX)
	List(container, M.RowGap, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local self = setmetatable({
		Frame = frame,
		Container = container,
		Header = header,
		Title = titleLabel,
		Page = page,
		Rows = {},
	}, Group)
	table.insert(page.Groups, self)

	-- Survol : liseré qui s'allume et bande de lumière qui suit la souris.
	local spot = New("Frame", {
		Name = "Spot",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 0,
		Parent = body,
	})
	local spotGrad = AccentGradient(spot, function()
		return Seq({ Theme.Accent, Theme.Accent })
	end, 0, { { 0, 1 }, { 0.36, 1 }, { 0.5, 0.9 }, { 0.64, 1 }, { 1, 1 } })
	local spotConn
	local function stopSpot()
		if spotConn then spotConn:Disconnect(); spotConn = nil end
		spot.Visible = false
	end

	local hovered = false
	local hoverHit = New("TextButton", {
		Name = "HoverSense",
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
		Parent = body,
	})
	hoverHit.Active = false
	Library:Connect(hoverHit.MouseEnter, function()
		hovered = true
		Tween(stroke, 0.2, { Color = Theme.Accent, Transparency = 0.55 })
		if not Library.Effects or spotConn then return end
		spot.Visible = true
		spotConn = RunService.RenderStepped:Connect(function()
			local x, y = MouseLocal()
			local pos, size = frame.AbsolutePosition - ScreenGui.AbsolutePosition, frame.AbsoluteSize
			if size.X <= 0 then return end
			-- Le dégradé se décale pour que sa bande claire suive le curseur.
			spotGrad.Offset = Vector2.new(math.clamp((x - pos.X) / size.X - 0.5, -0.6, 0.6), 0)
		end)
	end)
	Library:Connect(hoverHit.MouseLeave, function()
		hovered = false
		Tween(stroke, 0.25, { Color = Theme.BorderSoft, Transparency = 0 })
		stopSpot()
	end)

	function self:Animate(delay)
		if not Library.Effects then return end
		task.delay(delay or 0, function()
			headerSweep.Position = UDim2.fromScale(-0.5, 0)
			Tween(headerSweep, 0.8, { Position = UDim2.fromScale(1.1, 0) }, Enum.EasingStyle.Quad)
			if not hovered then
				stroke.Color = Theme.Accent
				stroke.Transparency = 0.3
				Tween(stroke, 0.7, { Color = Theme.BorderSoft, Transparency = 0 })
			end
		end)
	end

	if opts.Toggle ~= nil or opts.Flag then
		local flag = opts.Flag

		local veil = New("Frame", {
			Name = "Veil",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Active = false,
			Visible = false,
			ZIndex = 40,
			Parent = body,
		})
		Library:Register(veil, { BackgroundColor3 = "Panel" })
		Corner(veil, 9)

		local holder = New("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(M.SwitchW, M.SwitchH),
			ZIndex = 5,
			Parent = header,
		})
		local track, setVisual = Switch(holder)
		track.Position = UDim2.fromOffset(0, 0)

		local state = opts.Toggle == true
		local function paint(instant)
			local dur = instant and 0 or 0.15
			setVisual(state, instant)
			veil.Active = not state
			if state then
				Tween(veil, dur, { BackgroundTransparency = 1 })
				task.delay(dur + 0.02, function()
					if veil.Active == false then veil.Visible = false end
				end)
			else
				veil.Visible = true
				Tween(veil, dur, { BackgroundTransparency = 0.45 })
			end
		end

		local hh = Hit(holder, "GroupToggle", 14)
		Library:Connect(hh.MouseButton1Click, function()
			state = not state
			paint()
			if flag then Library.Flags[flag] = state end
			if opts.Callback then task.spawn(opts.Callback, state) end
		end)

		paint(true)
		if flag then
			Library.Flags[flag] = state
			Library.Options[flag] = {
				Value = state,
				Get = function() return state end,
				Set = function(_, v, silent)
					state = v and true or false
					paint()
					if flag then Library.Flags[flag] = state end
					if not silent and opts.Callback then task.spawn(opts.Callback, state) end
				end,
			}
		end
	end

	function self:SetTitle(t) titleLabel.Text = string.upper(tostring(t)) end
	function self:Destroy() frame:Destroy() end

	return self
end

--=====================================================================
-- Page
--=====================================================================

local Page = {}
Page.__index = Page

function Page:AddGroup(title, side, opts)
	return CreateGroup(self, title, side, opts)
end
Page.AddSection = Page.AddGroup

-- Linoria / Obsidian : raccourcis courants.
function Page:AddLeftGroupbox(title) return CreateGroup(self, title, "Left") end
function Page:AddRightGroupbox(title) return CreateGroup(self, title, "Right") end

--=====================================================================
-- Tab
--=====================================================================

local Tab = {}
Tab.__index = Tab

function Tab:AddPage(name)
	local tab = self
	local button = New("TextButton", {
		Name = "Pill_" .. name,
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, M.PageTab - 6),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = #tab.Pages + 1,
		ZIndex = 22,
		Parent = tab.PageRow,
	})
	Padding(button, 0, 0, 11, 11)

	local btnLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Text = name,
		FontFace = FontText(Enum.FontWeight.SemiBold),
		TextSize = TS(12),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 23,
		Parent = button,
	})
	Library:Register(btnLabel, { TextColor3 = "TextDim" })

	local content = New("Frame", {
		Name = "Page_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = tab.PagesHolder,
	})

	local single = M.Columns == 1
	local function column(x)
		local col = New("ScrollingFrame", {
			Name = x == 0 and "Left" or "Right",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = single and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -5, 1, 0),
			Position = single and UDim2.new() or UDim2.new(x, x == 0 and 0 or 5, 0, 0),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Accent,
			ScrollBarImageTransparency = 0.4,
			Parent = content,
		})
		List(col, 10, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
		Padding(col, 2, 10, 1, 4)
		return col
	end

	local left = column(0)
	local right = single and left or column(0.5)
	local columns = { { Frame = left, Base = left.Position, Delay = 0 } }
	if not single then
		table.insert(columns, { Frame = right, Base = right.Position, Delay = 0.05 })
	end

	-- Voile de la couleur du fond : il s'efface pendant que les colonnes
	-- remontent, ce qui donne le fondu d'entrée sans CanvasGroup.
	local fader = New("Frame", {
		Name = "Fader",
		Size = UDim2.new(1, 0, 1, 20),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = content,
	})
	Library:Register(fader, { BackgroundColor3 = "Background" })

	local function playIn()
		fader.BackgroundTransparency = 0
		Tween(fader, 0.32, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
		for _, c in ipairs(columns) do
			c.Frame.Position = c.Base + UDim2.fromOffset(0, 12)
			local tw = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, c.Delay)
			TweenService:Create(c.Frame, tw, { Position = c.Base }):Play()
		end
	end

	local page = setmetatable({
		Name = name,
		Content = content,
		Left = left,
		Right = right,
		Button = button,
		Label = btnLabel,
		Tab = tab,
		Groups = {},
	}, Page)

	local function select()
		for _, other in ipairs(tab.Pages) do
			other.Content.Visible = false
			Tween(other.Label, 0.14, { TextColor3 = Theme.TextDim })
		end
		content.Visible = true
		playIn()
		Tween(btnLabel, 0.14, { TextColor3 = Color3.new(1, 1, 1) })
		tab.ActivePage = page
		if tab.MoveHighlight then tab.MoveHighlight(button) end
		for i, g in ipairs(page.Groups) do
			g:Animate((i - 1) * 0.06)
		end
		if tab.Window and tab.Window.ApplySearch then tab.Window:ApplySearch() end
	end
	page.Select = select

	Library:Connect(button.MouseButton1Click, select)
	Library:Connect(button.MouseEnter, function()
		if tab.ActivePage ~= page then Tween(btnLabel, 0.1, { TextColor3 = Theme.Text }) end
	end)
	Library:Connect(button.MouseLeave, function()
		if tab.ActivePage ~= page then Tween(btnLabel, 0.1, { TextColor3 = Theme.TextDim }) end
	end)

	table.insert(tab.Pages, page)
	if tab.RefreshPills then tab.RefreshPills() end

	if #tab.Pages == 1 then
		task.defer(function()
			if not tab.ActivePage then select() end
		end)
	end
	return page
end
Tab.AddSection = Tab.AddPage

function Tab:AddGroup(title, side, opts)
	if #self.Pages == 0 then
		self:AddPage("Main")
	end
	return self.Pages[1]:AddGroup(title, side, opts)
end

function Tab:AddLeftGroupbox(title) return self:AddGroup(title, "Left") end
function Tab:AddRightGroupbox(title) return self:AddGroup(title, "Right") end

function Tab:CountRows()
	local n = 0
	for _, p in ipairs(self.Pages) do
		for _, g in ipairs(p.Groups) do
			n = n + #g.Rows
		end
	end
	return n
end

--=====================================================================
-- Fenêtre
--=====================================================================

local Window = {}
Window.__index = Window

-- Icône d'onglet devinée d'après le nom. Seuls des symboles que les
-- polices Roblox dessinent en monochrome (donc teintables) sont utilisés.
local AUTO_ICONS = {
	{ { "farm", "auto", "main", "home" }, "◈" },
	{ { "combat", "fight", "pvp", "aim", "kill", "attack" }, "❖" },
	{ { "loot", "item", "inventory", "shop", "chest", "craft" }, "◇" },
	{ { "visual", "esp", "render", "world" }, "◉" },
	{ { "move", "movement", "teleport", "tp", "fly", "speed" }, "▲" },
	{ { "player", "misc", "other", "extra", "util" }, "◎" },
}
local function AutoIcon(name)
	local n = string.lower(tostring(name or ""))
	for _, entry in ipairs(AUTO_ICONS) do
		for _, key in ipairs(entry[1]) do
			if string.find(n, key, 1, true) then return entry[2] end
		end
	end
	return nil
end

-- Hōgyoku, dessiné en 2D comme l'aperçu web (un ViewportFrame rendait une
-- boule néon plate). Roblox n'a pas de dégradé radial : la sphère est une pile
-- de cercles emboîtés dont le centre glisse du point de lumière vers le centre,
-- et le halo une pile de cercles très transparents. Les anneaux sont de petits
-- segments projetés en 3D à chaque image, devant ou derrière la sphère.
local function OrbCircle(parent, size, color, transparency, z, pos)
	local c = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = pos or UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = color,
		BackgroundTransparency = transparency or 0,
		BorderSizePixel = 0,
		ZIndex = z or 1,
		Parent = parent,
	})
	Corner(c, "full")
	return c
end

local function OrbStops()
	return {
		{ 0, Color3.new(1, 1, 1) },
		{ 0.06, Color3.new(1, 1, 1) },
		{ 0.16, Theme.Glass },
		{ 0.42, Theme.Accent },
		{ 0.75, Color3.fromRGB(42, 28, 112) },
		{ 1, Color3.fromRGB(14, 10, 36) },
	}
end

local function SampleStops(stops, t)
	for i = 2, #stops do
		if t <= stops[i][1] then
			local a, b = stops[i - 1], stops[i]
			return a[2]:Lerp(b[2], math.clamp((t - a[1]) / math.max(b[1] - a[1], 1e-4), 0, 1))
		end
	end
	return stops[#stops][2]
end

-- size : côté de la boîte (120 = taille de l'écran de chargement web).
local function BuildOrb(parent, size)
	local k = size / 120
	local small = size < 70

	local box = New("Frame", {
		Name = "Orb",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		ZIndex = 5,
		Parent = parent,
	})

	-- Halo (box-shadow 0 0 40px / 0 0 90px), qui respire.
	local coreD = math.floor(68 * k + 0.5)
	local glow = New("Frame", {
		Name = "Glow",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		ZIndex = 1,
		Parent = box,
	})
	local glowScale = New("UIScale", { Scale = 1, Parent = glow })
	local glowLayers = {}
	-- Opacité décroissante vers l'extérieur : pas de bord visible.
	local GL = small and 8 or 16
	local spread = small and 14 or 58 * k
	for i = 1, GL do
		local d = coreD + spread * 2 * (i / GL)
		local alpha = (small and 0.16 or 0.11) * (1 - (i - 1) / GL) ^ 1.6
		table.insert(glowLayers, OrbCircle(glow, d, Theme.Accent, 1 - alpha, 1))
	end

	-- Sphère : radial-gradient(circle at 38% 32%, #fff 6%, glass 16%, accent 42%, #2a1c70 75%, #0e0a24).
	local core = New("Frame", {
		Name = "Core",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(coreD, coreD),
		ZIndex = 3,
		Parent = box,
	})
	local coreScale = New("UIScale", { Scale = 1, Parent = core })
	local R = coreD / 2
	local focal = Vector2.new(0.38, 0.32) * coreD
	local center = Vector2.new(R, R)
	local rg = (Vector2.new(coreD, coreD) - focal).Magnitude
	local tMax = (R + (focal - center).Magnitude) / rg
	local LAYERS = small and 10 or 18
	local coreLayers = {}
	for i = 0, LAYERS - 1 do
		local f = 1 - i / LAYERS
		local pos = focal:Lerp(center, f)
		local c = OrbCircle(core, R * f * 2, Color3.new(1, 1, 1), 0, 3 + i, UDim2.fromOffset(pos.X, pos.Y))
		table.insert(coreLayers, { Frame = c, T = f * tMax })
	end
	local lastAccent
	local function paintCore()
		if lastAccent == Theme.Accent then return end
		lastAccent = Theme.Accent
		local stops = OrbStops()
		for _, l in ipairs(coreLayers) do l.Frame.BackgroundColor3 = SampleStops(stops, l.T) end
		for _, g in ipairs(glowLayers) do g.BackgroundColor3 = Theme.Accent end
	end
	paintCore()

	-- Anneaux : r1 blanc en tirets (rotateX 72°), r2 cyan plein (rotateY 68° rotateX 20°).
	local thick = math.max(1, 1.5 * math.max(k, 0.7))
	local function makeRing(radius, count, dashed, color, transparency)
		local segs = {}
		for i = 1, count do
			segs[i] = New("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(2, thick),
				BackgroundColor3 = color,
				BackgroundTransparency = transparency,
				BorderSizePixel = 0,
				ZIndex = 2,
				Parent = box,
			})
		end
		return { Segs = segs, Radius = radius, Dashed = dashed, Base = transparency }
	end
	local ring1 = makeRing(54 * k, small and 24 or 40, true, Theme.Glass, 0.12)
	local ring2 = makeRing(60 * k, small and 36 or 72, false, Theme.Accent2, 0.3)

	local c72, s72 = math.cos(math.rad(72)), math.sin(math.rad(72))
	local c20, s20 = math.cos(math.rad(20)), math.sin(math.rad(20))
	local c68, s68 = math.cos(math.rad(68)), math.sin(math.rad(68))
	local function proj1(a)
		local x, y = math.cos(a), math.sin(a)
		return x, y * c72, y * s72
	end
	local function proj2(a)
		local x, y = math.cos(a), math.sin(a)
		local y1, z1 = y * c20, y * s20
		return x * c68 + z1 * s68, y1, -x * s68 + z1 * c68
	end

	local half = size / 2
	local function layoutRing(ring, proj, spin)
		local n = #ring.Segs
		local r = ring.Radius
		local arc = (ring.Dashed and 0.5 or 1) * math.pi * 2 / n
		for i, seg in ipairs(ring.Segs) do
			local a0 = (i - 1) / n * math.pi * 2 + spin
			local x0, y0, z0 = proj(a0)
			local x1, y1 = proj(a0 + arc)
			local px0, py0 = half + x0 * r, half + y0 * r
			local dx, dy = (x1 - x0) * r, (y1 - y0) * r
			seg.Position = UDim2.fromOffset(px0 + dx / 2, py0 + dy / 2)
			seg.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) + (ring.Dashed and 0 or 0.8), thick)
			seg.Rotation = math.deg(math.atan2(dy, dx))
			-- Devant la sphère ou derrière, et un peu plus sombre derrière.
			seg.ZIndex = z0 >= 0 and 30 or 2
			seg.BackgroundTransparency = ring.Hidden and 1 or (ring.Base + (z0 < 0 and 0.25 or 0))
		end
	end

	local t = 0
	local function step(dt)
		t = t + dt
		paintCore()
		glowScale.Scale = 1 + (math.sin(t * math.pi * 2 / 2.2) + 1) * 0.06
		layoutRing(ring1, proj1, t * math.pi * 2 / 4)
		layoutRing(ring2, proj2, -t * math.pi * 2 / 6)
	end
	step(0)

	-- Fin du chargement : la sphère enfle, blanchit puis se résorbe.
	local handle = { Core = core }
	function handle.Burst(duration)
		duration = duration or 0.35
		ring1.Hidden, ring2.Hidden = true, true
		Tween(coreScale, duration * 0.6, { Scale = 1.35 }, Enum.EasingStyle.Quad)
		for _, l in ipairs(coreLayers) do
			Tween(l.Frame, duration * 0.6, { BackgroundColor3 = l.Frame.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.55) }, Enum.EasingStyle.Quad)
		end
		task.delay(duration * 0.6, function()
			Tween(coreScale, duration * 0.4, { Scale = 0.2 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			for _, l in ipairs(coreLayers) do
				Tween(l.Frame, duration * 0.4, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
			end
			for _, g in ipairs(glowLayers) do
				Tween(g, duration * 0.6, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
			end
		end)
	end
	return box, step, handle
end

function Library:CreateWindow(opts)
	opts = opts or {}
	if opts.Accent and (opts.ForceAccent or not Library.KeepAccent) then Library:SetAccent(opts.Accent) end
	if opts.ToggleKey then Library.ToggleKey = opts.ToggleKey end
	if opts.Effects ~= nil then Library.Effects = opts.Effects ~= false end
	if opts.Blur ~= nil then Library.Blur = opts.Blur ~= false end

	if opts.Splash ~= false and not Library.SplashActive and not Library.CurrentSplash then
		Library:Splash({
			Title = opts.Title or "NW HUB",
			Subtitle = opts.Subtitle or "INITIALIZING",
			Steps = { "initializing", "checking integrity", "loading modules", "ready" },
			Duration = opts.SplashDuration or 3.5,
			MinDuration = opts.MinDuration or 3.2,
			AutoFinish = true,
		})
	end

	if opts.Mobile ~= nil then ApplyMetrics(opts.Mobile) else ApplyMetrics(DetectMobile()) end
	if opts.Scale then Library:SetScale(opts.Scale) end

	local uiFactor = Factor()
	local topBand = 38

	local function mobileSize()
		local vp = ViewportSize()
		return UDim2.fromOffset(
			math.max(300, math.floor((vp.X - 20) / uiFactor)),
			math.max(220, math.floor((vp.Y - 20 - topBand) / uiFactor)))
	end

	local size
	if Library.Mobile then
		size = mobileSize()
		opts.Position = opts.Position or UDim2.new(0.5, 0, 0.5, math.floor(topBand / 2))
	else
		local w = opts.Size and opts.Size.X.Offset or 720
		local h = opts.Size and opts.Size.Y.Offset or 470
		size = UDim2.fromOffset(math.max(w, 640), math.max(h, 420))
	end

	local root = New("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = opts.Position or UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 10,
		Parent = ScreenGui,
	})
	local windowScale = New("UIScale", { Scale = uiFactor, Parent = root })

	if Library.Mobile then
		Library:Connect(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"), function()
			root.Size = mobileSize()
			root.Position = UDim2.new(0.5, 0, 0.5, math.floor(topBand / 2))
		end)
	end

	-- Ombre douce : couches arrondies de plus en plus larges et transparentes.
	for i = 1, 10 do
		local spread = i * 3.5
		local layer = New("Frame", {
			Name = "Shadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 10),
			Size = UDim2.new(1, spread * 2, 1, spread * 2),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.9 + i * 0.008,
			BorderSizePixel = 0,
			ZIndex = 0,
			Parent = root,
		})
		Corner(layer, 12 + spread)
	end

	local panel = New("Frame", {
		Name = "Panel",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = root,
	})
	Corner(panel, 12)
	AccentGradient(panel, function()
		return Seq({ Theme.Panel:Lerp(Theme.Accent, 0.04), Theme.Background })
	end, 90)

	-- Liseré : UIStroke dont le dégradé tourne en continu.
	local panelStroke = New("UIStroke", {
		Color = Color3.new(1, 1, 1),
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = panel,
	})
	local strokeGradient = AccentGradient(panelStroke, function()
		return Seq({ Theme.AccentDim, Theme.Accent, Theme.Accent2, Theme.AccentDim })
	end, 0, { { 0, 0.75 }, { 0.35, 0.7 }, { 0.55, 0 }, { 0.68, 0.1 }, { 0.85, 0.75 }, { 1, 0.75 } })

	-- Vitrail fêlé en fond de fenêtre (l'illusion qui se fissure).
	local glass = New("Frame", {
		Name = "Glass",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		Parent = panel,
	})
	local glassLines = {}
	-- 8 fêlures qui partent du même point, puis 8 traverses qui les relient :
	-- ça donne des éclats, pas un éventail.
	for i = 1, 16 do
		local line = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(0, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = Theme.Glass,
			BackgroundTransparency = i <= 8 and 0.96 or 0.975,
			ZIndex = 1,
			Parent = glass,
		})
		table.insert(glassLines, line)
	end

	local RAYS = 8
	local CHORD = { 0.62, 0.45, 0.72, 0.5, 0.66, 0.42, 0.58, 0.7 }

	local function layoutGlass(t)
		local w = root.Size.X.Offset
		local h = root.Size.Y.Offset
		-- Le point de fracture dérive très lentement.
		local ox = w * (0.66 + math.sin(t * 0.08) * 0.05)
		local oy = h * (0.34 + math.cos(t * 0.06) * 0.05)

		local ends = {}
		for i = 1, RAYS do
			local a = (i - 1) / RAYS * math.pi * 2 + math.sin(t * 0.05 + i) * 0.03
			local dx, dy = math.cos(a), math.sin(a)
			local tx = dx > 0 and (w - ox) / dx or (dx < 0 and -ox / dx or math.huge)
			local ty = dy > 0 and (h - oy) / dy or (dy < 0 and -oy / dy or math.huge)
			local len = math.min(tx, ty)
			ends[i] = Vector2.new(ox + dx * len, oy + dy * len)
		end

		local function place(frame, p1, p2)
			local d = p2 - p1
			frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2, (p1.Y + p2.Y) / 2)
			frame.Size = UDim2.fromOffset(d.Magnitude, 1)
			frame.Rotation = math.deg(math.atan2(d.Y, d.X))
		end

		local origin = Vector2.new(ox, oy)
		for i = 1, RAYS do
			place(glassLines[i], origin, ends[i])
			local j = i % RAYS + 1
			place(glassLines[RAYS + i],
				origin:Lerp(ends[i], CHORD[i]),
				origin:Lerp(ends[j], CHORD[j]))
		end
	end
	layoutGlass(0)

	--=================================================================
	-- Barre latérale
	--=================================================================

	local sidebar = New("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, M.Sidebar, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = panel,
	})
	Corner(sidebar, 12)
	AccentGradient(sidebar, function() return Seq({ Theme.Accent, Theme.Background }) end, 90,
		{ { 0, 0.9 }, { 0.45, 1 }, { 1, 1 } })
	New("Frame", {
		Name = "Edge",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.BorderSoft,
		ZIndex = 3,
		Parent = sidebar,
	})

	-- Bannière : image animée optionnelle (Banner), sinon dégradé et kanji.
	local banner = New("Frame", {
		Name = "Banner",
		Size = UDim2.new(1, -1, 0, M.Banner),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = sidebar,
	})
	-- Seul le coin haut gauche est arrondi (celui de la fenêtre) : le fond et
	-- l'image dépassent à droite et en bas, où la bannière les coupe.
	local bannerBg = New("Frame", {
		Name = "Bg",
		Size = UDim2.new(1, 14, 1, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = banner,
	})
	Corner(bannerBg, 12)
	AccentGradient(bannerBg, function() return Seq({ Theme.Accent, Theme.AccentDim:Lerp(Theme.Background, 0.5), Theme.Background }) end, 125)

	local bannerKanji = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 8, 0, -14),
		Size = UDim2.fromOffset(110, 110),
		Text = "鏡",
		FontFace = FontText(Enum.FontWeight.Bold),
		TextSize = 96,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = 0.88,
		ZIndex = 4,
		Parent = banner,
	})

	local bannerImage = New("ImageLabel", {
		Name = "Art",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 14, 1, 14),
		ScaleType = Enum.ScaleType.Crop,
		Image = "",
		ImageColor3 = Color3.fromRGB(236, 232, 255),
		Visible = false,
		ZIndex = 4,
		Parent = banner,
	})
	Corner(bannerImage, 12)

	local sheet
	local function setBanner(image, sheetInfo)
		bannerImage.Image = image or ""
		bannerImage.Visible = image ~= nil and image ~= ""
		bannerKanji.Visible = not bannerImage.Visible
		sheet = nil
		if bannerImage.Visible and type(sheetInfo) == "table" then
			sheet = {
				Columns = sheetInfo.Columns or 1,
				Frames = sheetInfo.Frames or ((sheetInfo.Columns or 1) * (sheetInfo.Rows or 1)),
				FPS = sheetInfo.FPS or 15,
				Size = sheetInfo.FrameSize or Vector2.new(256, 144),
				T = 0,
			}
			bannerImage.ScaleType = Enum.ScaleType.Crop
			bannerImage.ImageRectSize = sheet.Size
		else
			bannerImage.ScaleType = Enum.ScaleType.Crop
			bannerImage.ImageRectSize = Vector2.zero
		end
	end
	-- Par défaut : Aizen animé (planche 5×8). Banner = false pour le retirer.
	if opts.Banner == nil then
		setBanner(Library.DefaultBanner, Library.DefaultBannerSheet)
	elseif opts.Banner ~= false then
		setBanner(opts.Banner, opts.BannerSheet)
	else
		setBanner(nil)
	end

	-- Voile violet puis noir, comme le dégradé posé sur l'image du site.
	local tint = New("Frame", {
		Name = "Tint",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = banner,
	})
	AccentGradient(tint, function()
		return Seq({ Theme.Accent, Theme.AccentDim, Theme.Background, Theme.Background })
	end, 90, { { 0, 0.82 }, { 0.45, 0.72 }, { 0.82, 0.15 }, { 1, 0 } })

	-- Lignes de balayage : le grain « vieille télé » de l'aperçu.
	for y = 0, M.Banner, 3 do
		New("Frame", {
			Name = "Scanline",
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.75,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = banner,
		})
	end

	local orb, orbStep = BuildOrb(banner, Library.Mobile and 34 or 44)
	orb.AnchorPoint = Vector2.new(0, 1)
	orb.Position = UDim2.new(0, 4, 1, -3)
	orb.ZIndex = 6

	local brandTitle = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, Library.Mobile and 40 or 52, 1, -22),
		Size = UDim2.new(1, -54, 0, 16),
		Text = string.upper(opts.Title or "NW HUB"),
		FontFace = FontTitle(),
		TextSize = TS(Library.Mobile and 10 or 12),
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 6,
		Parent = banner,
	})
	New("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.6, Thickness = 1, Parent = brandTitle })

	local brandSub = New("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, Library.Mobile and 40 or 52, 1, -8),
		Size = UDim2.new(1, -54, 0, 13),
		Text = opts.SideSubtitle or "鏡 花 水 月",
		FontFace = FontText(Enum.FontWeight.Bold),
		TextSize = TS(10),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 6,
		Parent = banner,
	})
	brandSub.TextColor3 = Color3.fromRGB(157, 147, 255)
	New("UIStroke", { Color = Color3.new(0, 0, 0), Transparency = 0.65, Thickness = 1, Parent = brandSub })

	-- Reiatsu : petites particules qui montent le long de la barre.
	local reiatsu = New("Frame", {
		Name = "Reiatsu",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, M.Banner),
		Size = UDim2.new(1, 0, 1, -M.Banner - 96),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = sidebar,
	})
	local motes = {}
	for i = 1, Library.Mobile and 8 or 16 do
		local sz = 2 + math.random() * 2.5
		local m = New("Frame", {
			Size = UDim2.fromOffset(sz, sz),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.Glass,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = reiatsu,
		})
		Corner(m, "full")
		table.insert(motes, {
			Frame = m,
			X = math.random(6, M.Sidebar - 8),
			Drift = (math.random() - 0.5) * 30,
			Life = 3.5 + math.random() * 4,
			T = math.random() * 7 + i * 0.1,
		})
	end

	local tabsList = New("ScrollingFrame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, M.Banner + 8),
		Size = UDim2.new(1, -1, 1, -M.Banner - 8 - 96),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ZIndex = 4,
		Parent = sidebar,
	})
	Padding(tabsList, 2, 6, 8, 8)
	List(tabsList, 3, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	-- Citation : la signature du thème.
	local quote = New("TextLabel", {
		Name = "Quote",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -66),
		Size = UDim2.new(1, -24, 0, 30),
		Text = opts.Quote or "« Everything goes according to plan. »",
		FontFace = FontText(Enum.FontWeight.Medium),
		TextSize = TS(9.5),
		TextWrapped = true,
		TextTransparency = 0.25,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		ZIndex = 4,
		Parent = sidebar,
	})
	Library:Register(quote, { TextColor3 = "TextFaint" })
	quote.Visible = opts.Quote ~= false

	-- Carte joueur.
	local userCard = New("Frame", {
		Name = "User",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, -1, 0, 58),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = sidebar,
	})
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.BorderSoft,
		ZIndex = 4,
		Parent = userCard,
	})
	local avatar = New("ImageLabel", {
		Name = "Avatar",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = Theme.Element,
		Image = "",
		ZIndex = 5,
		Parent = userCard,
	})
	Corner(avatar, "full")
	local avatarStroke = New("UIStroke", { Thickness = 2, Transparency = 0.5, Parent = avatar })
	Library:Register(avatarStroke, { Color = "Accent" })
	pcall(function()
		avatar.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(LocalPlayer.UserId)
	end)

	local userName = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 52, 0.5, -15),
		Size = UDim2.new(1, -60, 0, 16),
		Text = LocalPlayer and LocalPlayer.DisplayName or "Player",
		FontFace = FontText(Enum.FontWeight.SemiBold),
		TextSize = TS(12.5),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5,
		Parent = userCard,
	})
	Library:Register(userName, { TextColor3 = "Text" })

	local userTier = MonoLabel(userCard, opts.Tier or "", 9, "Glass")
	userTier.Position = UDim2.new(0, 52, 0.5, 2)
	userTier.Size = UDim2.new(1, -60, 0, 13)
	userTier.ZIndex = 5

	--=================================================================
	-- Zone principale
	--=================================================================

	local main = New("Frame", {
		Name = "Main",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(M.Sidebar, 0),
		Size = UDim2.new(1, -M.Sidebar, 1, 0),
		ZIndex = 2,
		Parent = panel,
	})

	local topBar = New("Frame", {
		Name = "TopBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, M.TopBar),
		ZIndex = 20,
		Parent = main,
	})
	New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.BorderSoft,
		ZIndex = 20,
		Parent = topBar,
	})

	local crumb = New("TextLabel", {
		Name = "Crumb",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		RichText = true,
		FontFace = FontText(Enum.FontWeight.Bold),
		TextSize = TS(14),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21,
		Parent = topBar,
	})
	Library:Register(crumb, { TextColor3 = "Text" })
	local crumbSub = string.upper(opts.Game or opts.Subtitle or "")

	local pillsHolder = New("Frame", {
		Name = "Pills",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(0, M.PageTab),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 21,
		Parent = topBar,
	})

	-- Boutons de fenêtre.
	local btnSize = Library.Mobile and 30 or 26
	local function topButton(name, offset)
		local b = New("TextButton", {
			Name = name,
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, offset, 0.5, 0),
			Size = UDim2.fromOffset(btnSize, btnSize),
			BackgroundTransparency = 1,
			ZIndex = 22,
			Parent = topBar,
		})
		Library:Register(b, { BackgroundColor3 = "ElementHover" })
		Corner(b, 7)
		return b
	end

	local closeBtn = topButton("Close", -10)
	local closeBars = {}
	for i = 1, 2 do
		local bar = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(11, 1.5),
			Rotation = i == 1 and 45 or -45,
			BorderSizePixel = 0,
			ZIndex = 23,
			Parent = closeBtn,
		})
		Library:Register(bar, { BackgroundColor3 = "TextDim" })
		table.insert(closeBars, bar)
	end

	local unloadBtn = topButton("Unload", -10 - btnSize - 4)
	local unloadIcon = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(8, 8),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Danger,
		ZIndex = 23,
		Parent = unloadBtn,
	})
	Corner(unloadIcon, "full")

	local searchW = Library.Mobile and 0 or 150
	local search = New("Frame", {
		Name = "Search",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10 - (btnSize + 4) * 2 - 4, 0.5, 0),
		Size = UDim2.fromOffset(searchW, Library.Mobile and 30 or 28),
		Visible = not Library.Mobile,
		ZIndex = 21,
		Parent = topBar,
	})
	Library:Register(search, { BackgroundColor3 = "Panel2" })
	Corner(search, 8)
	local searchStroke = Stroke(search, "BorderSoft")
	-- Loupe dessinée : un anneau et un manche.
	local lens = New("Frame", {
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.fromOffset(9, 9),
		BackgroundTransparency = 1,
		ZIndex = 22,
		Parent = search,
	})
	Corner(lens, "full")
	local lensStroke = New("UIStroke", { Thickness = 1.5, Parent = lens })
	Library:Register(lensStroke, { Color = "TextFaint" })
	local handle = New("Frame", {
		Position = UDim2.fromOffset(17, 17),
		Size = UDim2.fromOffset(5, 1.5),
		Rotation = 45,
		BorderSizePixel = 0,
		ZIndex = 22,
		Parent = search,
	})
	Library:Register(handle, { BackgroundColor3 = "TextFaint" })

	local searchBox = New("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -34, 1, 0),
		Text = "",
		PlaceholderText = "Search...",
		FontFace = FontText(),
		TextSize = TS(12),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 22,
		Parent = search,
	})
	Library:Register(searchBox, { TextColor3 = "Text", PlaceholderColor3 = "TextFaint" })

	local contentHolder = New("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, M.TopBar + 10),
		Size = UDim2.new(1, -24, 1, -(M.TopBar + 10) - M.Footer - 2),
		ZIndex = 2,
		Parent = main,
	})

	-- Kanji en filigrane derrière le contenu : la zone vide respire le thème.
	local ghost = New("TextLabel", {
		Name = "Ghost",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 10, 1, -M.Footer + 22),
		Size = UDim2.fromOffset(190, 190),
		Text = "鏡",
		FontFace = FontText(Enum.FontWeight.Bold),
		TextSize = 190,
		TextTransparency = 0.955,
		ZIndex = 1,
		Parent = main,
	})
	Library:Register(ghost, { TextColor3 = "Accent" })

	local footerBar = New("Frame", {
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, M.Footer),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = main,
	})
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.BorderSoft,
		ZIndex = 20,
		Parent = footerBar,
	})
	local footer = MonoLabel(footerBar, opts.Footer or "", 9.5, "TextFaint")
	footer.Position = UDim2.fromOffset(16, 0)
	footer.Size = UDim2.new(0.5, -16, 1, 0)
	footer.TextTruncate = Enum.TextTruncate.AtEnd
	footer.ZIndex = 21

	local footerRight = MonoLabel(footerBar, opts.StatusRight or opts.Status or "", 9.5, "TextFaint")
	footerRight.AnchorPoint = Vector2.new(1, 0)
	footerRight.Position = UDim2.new(1, -14, 0, 0)
	footerRight.Size = UDim2.new(0.5, -40, 1, 0)
	footerRight.TextXAlignment = Enum.TextXAlignment.Right
	footerRight.TextTruncate = Enum.TextTruncate.AtEnd
	footerRight.ZIndex = 21

	local statusDot = New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.fromOffset(6, 6),
		BorderSizePixel = 0,
		ZIndex = 21,
		Parent = footerBar,
	})
	Library:Register(statusDot, { BackgroundColor3 = "Success" })
	Corner(statusDot, "full")
	local function placeDot()
		statusDot.Position = UDim2.new(1, -14 - footerRight.TextBounds.X / math.max(windowScale.Scale, 0.01) - 8, 0.5, 0)
		statusDot.Visible = footerRight.Text ~= ""
	end
	Library:Connect(footerRight:GetPropertyChangedSignal("TextBounds"), placeDot)
	task.defer(placeDot)

	local grip = New("TextButton", {
		Name = "Grip",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(16, 16),
		ZIndex = 30,
		Visible = not Library.Mobile,
		Parent = panel,
	})
	for i = 1, 3 do
		local d = New("Frame", {
			Size = UDim2.fromOffset(2, 2),
			Position = UDim2.fromOffset(12 - (i - 1) * 4, 11),
			BorderSizePixel = 0,
			ZIndex = 31,
			Parent = grip,
		})
		Corner(d, "full")
		Library:Register(d, { BackgroundColor3 = "TextFaint" })
	end

	local self = setmetatable({
		Root = root,
		Panel = panel,
		Content = contentHolder,
		Tabs = {},
		ActiveTab = nil,
	}, Window)
	Library.Window = self

	function self:ApplyScale(n)
		uiFactor = math.max(0.4, (tonumber(n) or 2) / 2)
		windowScale.Scale = uiFactor
		if Library.Mobile then root.Size = mobileSize() end
	end

	function self:SetStatus(left, right)
		if left then footer.Text = string.upper(left) end
		if right then footerRight.Text = string.upper(right) end
	end
	function self:SetFooter(t) footer.Text = string.upper(tostring(t)) end
	function self:SetTier(t) userTier.Text = string.upper(tostring(t or "")) end
	function self:SetTitle(t) brandTitle.Text = string.upper(tostring(t)) end
	function self:SetBanner(image, sheetInfo) setBanner(image, sheetInfo) end

	local function updateCrumb()
		local tab = self.ActiveTab
		local name = tab and tab.Name or ""
		local sub = crumbSub ~= "" and ('  <font face="RobotoMono" size="%d" color="#%s">%s</font>'):format(
			TS(10), Theme.TextFaint:ToHex(), crumbSub) or ""
		crumb.Text = name .. sub
		task.defer(function()
			pillsHolder.Position = UDim2.new(0, 16 + crumb.TextBounds.X / math.max(windowScale.Scale, 0.01) + 14, 0.5, 0)
		end)
	end
	self.UpdateCrumb = updateCrumb

	-- Déplacement par la barre du haut et la bannière.
	local dragging, dragStart, startPos = false, nil, nil
	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = InputPos(input)
			startPos = root.Position
		end
	end
	Library:Connect(topBar.InputBegan, beginDrag)
	Library:Connect(banner.InputBegan, beginDrag)
	Library:Connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = InputPos(input) - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Redimensionnement.
	local resizing, resizeStart, startSize = false, nil, nil
	Library:Connect(grip.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = InputPos(input)
			startSize = Vector2.new(root.Size.X.Offset, root.Size.Y.Offset)
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = (InputPos(input) - resizeStart) / math.max(uiFactor, 0.01)
			root.Size = UDim2.fromOffset(
				math.clamp(startSize.X + delta.X, 640, 1400),
				math.clamp(startSize.Y + delta.Y, 420, 900))
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	-- Recherche dans la page courante.
	function self:ApplySearch()
		local tab = self.ActiveTab
		local page = tab and tab.ActivePage
		if not page then return end
		local q = string.lower(searchBox.Text or "")
		for _, g in ipairs(page.Groups) do
			local any = false
			local titleHit = q ~= "" and string.find(string.lower(g.Title.Text), q, 1, true) ~= nil
			for _, r in ipairs(g.Rows) do
				local ok = q == "" or titleHit or string.find(r.Text, q, 1, true) ~= nil
				r.Frame.Visible = ok
				any = any or ok
			end
			g.Frame.Visible = q == "" or any or titleHit or #g.Rows == 0 and q == ""
		end
	end
	Library:Connect(searchBox:GetPropertyChangedSignal("Text"), function() self:ApplySearch() end)
	Library:Connect(searchBox.Focused, function() Tween(searchStroke, 0.15, { Color = Theme.Accent }) end)
	Library:Connect(searchBox.FocusLost, function() Tween(searchStroke, 0.15, { Color = Theme.BorderSoft }) end)

	--=================================================================
	-- Animation continue (seulement menu ouvert)
	--=================================================================

	local clock = 0
	local countTimer = 0
	Library:Connect(RunService.RenderStepped, function(dt)
		if not root.Visible then return end
		clock = clock + dt

		strokeGradient.Rotation = (clock * 55) % 360
		orbStep(dt)
		layoutGlass(clock)

		for _, m in ipairs(motes) do
			m.T = m.T + dt
			local p = (m.T % m.Life) / m.Life
			local h = reiatsu.AbsoluteSize.Y / math.max(windowScale.Scale, 0.01)
			m.Frame.Position = UDim2.fromOffset(m.X + m.Drift * p, h - p * (h + 10))
			local a = p < 0.15 and p / 0.15 or (1 - p) / 0.85
			m.Frame.BackgroundTransparency = 1 - a * 0.85
		end

		if sheet then
			sheet.T = sheet.T + dt
			local frame = math.floor(sheet.T * sheet.FPS) % sheet.Frames
			local col = frame % sheet.Columns
			local row = math.floor(frame / sheet.Columns)
			bannerImage.ImageRectOffset = Vector2.new(col * sheet.Size.X, row * sheet.Size.Y)
		end

		countTimer = countTimer + dt
		if countTimer > 1 then
			countTimer = 0
			for _, tab in ipairs((self and self.Tabs) or {}) do
				if tab.CountLabel then tab.CountLabel.Text = tostring(tab:CountRows()) end
			end
		end
	end)

	--=================================================================
	-- Ouverture et fermeture
	--=================================================================

	-- Chaque appel à SetOpen reçoit un numéro : les rappels différés d'une
	-- transition dépassée ne touchent plus à la fenêtre. Un appel pendant une
	-- transition (ou juste après la précédente) annule ses effets et bascule
	-- sur l'animation courte, pour que spammer la touche reste propre.
	local generation = 0
	local cancelFx = {}
	local lastToggle = -math.huge
	local transitionUntil = 0

	local function cancelEffects()
		for _, cancel in ipairs(cancelFx) do pcall(cancel) end
		table.clear(cancelFx)
	end

	local function targetRect()
		local o = FxLayer.AbsolutePosition
		local center = root.AbsolutePosition + root.AbsoluteSize / 2 - o
		local w = root.Size.X.Offset * uiFactor
		local h = root.Size.Y.Offset * uiFactor
		return { x = center.X - w / 2, y = center.Y - h / 2, w = w, h = h }
	end

	-- Kyōka Suigetsu : la fenêtre apparaît en deux reflets décalés qui se
	-- rejoignent. Deux copies figées du panneau suffisent, dans un CanvasGroup
	-- pour pouvoir les effacer d'un bloc.
	local function doubleReflection()
		if not Library.Effects then return end
		for i, offset in ipairs({ Vector2.new(-18, -9), Vector2.new(18, 9) }) do
			local holder = New("CanvasGroup", {
				Name = "Reflection",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(offset.X, offset.Y),
				GroupTransparency = 0.55,
				GroupColor3 = i == 1 and Theme.Glass or Theme.Accent,
				ZIndex = 9,
				Parent = root,
			})
			local copy = panel:Clone()
			copy.Name = "Copy"
			copy.Parent = holder
			table.insert(cancelFx, function() holder:Destroy() end)
			Tween(holder, 0.5, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 1 }, Enum.EasingStyle.Exponential)
			task.delay(0.55, function() holder:Destroy() end)
		end
	end

	local function revealEffects()
		doubleReflection()
		table.insert(cancelFx, FX.Cracks(panel, 7))
		table.insert(cancelFx, FX.EdgeFlash(panel, root))
		table.insert(cancelFx, FX.Sweep(panel, 0.35, 0.9))
		panelStroke.Thickness = 2.5
		Tween(panelStroke, 0.6, { Thickness = 1.2 })
	end

	function self:SetOpen(state, instant)
		state = state and true or false
		local wasOpen = Library.Open
		Library.Open = state
		CloseActivePopup()

		generation = generation + 1
		local my = generation
		local now = os.clock()
		local spammed = now < transitionUntil or (now - lastToggle) < 0.45
		lastToggle = now
		cancelEffects()
		panelStroke.Thickness = 1.2

		if self.ToggleButton then
			self.ToggleButton.Visible = Library.Mobile or not state
		end

		local quick = instant or not Library.Effects or spammed

		if state then
			ModalCatcher.Modal = true
			Library:ShowCursor(true)
			FX.GameBlur(true)
			if quick or (wasOpen and root.Visible) then
				if not root.Visible then
					root.Visible = true
					windowScale.Scale = uiFactor * 0.95
				end
				Tween(windowScale, instant and 0 or 0.28, { Scale = uiFactor }, Enum.EasingStyle.Exponential)
				transitionUntil = now + (instant and 0 or 0.28)
				return
			end
			root.Visible = false
			windowScale.Scale = uiFactor
			transitionUntil = now + 1.25
			table.insert(cancelFx, FX.Assemble(targetRect(), function()
				if generation ~= my then return end
				root.Visible = true
				windowScale.Scale = uiFactor * 0.97
				Tween(windowScale, 0.35, { Scale = uiFactor }, Enum.EasingStyle.Exponential)
				revealEffects()
				local tab = self.ActiveTab
				if tab and tab.ActivePage then
					for i, g in ipairs(tab.ActivePage.Groups) do g:Animate(0.1 + (i - 1) * 0.06) end
				end
			end))
		else
			ModalCatcher.Modal = false
			Library:ShowCursor(false)
			FX.GameBlur(false)
			if quick or not root.Visible then
				local d = instant and 0 or 0.14
				Tween(windowScale, d, { Scale = uiFactor * 0.95 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				transitionUntil = now + d
				task.delay(d, function()
					if generation == my then root.Visible = false end
				end)
				return
			end
			-- Le menu se fige et se fissure, puis vole en éclats.
			transitionUntil = now + 0.3
			table.insert(cancelFx, FX.Cracks(panel, 6))
			panelStroke.Thickness = 2.5
			task.delay(0.26, function()
				if generation ~= my then return end
				local rect = targetRect()
				root.Visible = false
				panelStroke.Thickness = 1.2
				table.insert(cancelFx, FX.Shatter(rect))
			end)
		end
	end

	function self:Toggle() self:SetOpen(not Library.Open) end

	local function doClose() self:SetOpen(false) end
	Library:Connect(closeBtn.Activated, doClose)
	Library:Connect(closeBtn.MouseEnter, function()
		Tween(closeBtn, 0.12, { BackgroundTransparency = 0 })
		for _, bar in ipairs(closeBars) do Tween(bar, 0.12, { BackgroundColor3 = Theme.Danger }) end
	end)
	Library:Connect(closeBtn.MouseLeave, function()
		Tween(closeBtn, 0.12, { BackgroundTransparency = 1 })
		for _, bar in ipairs(closeBars) do Tween(bar, 0.12, { BackgroundColor3 = Theme.TextDim }) end
	end)

	Library:Connect(unloadBtn.Activated, function() Library:Unload() end)
	Library:Connect(unloadBtn.MouseEnter, function()
		Tween(unloadBtn, 0.12, { BackgroundTransparency = 0 })
		Tween(unloadIcon, 0.12, { Size = UDim2.fromOffset(10, 10) })
		Library:ShowTooltip("Unload (exit completely)")
	end)
	Library:Connect(unloadBtn.MouseLeave, function()
		Tween(unloadBtn, 0.12, { BackgroundTransparency = 1 })
		Tween(unloadIcon, 0.12, { Size = UDim2.fromOffset(8, 8) })
		Library:HideTooltip()
	end)

	function self:Unload() Library:Unload() end
	function self:Destroy() Library:Unload() end

	function self:Toggle() self:SetOpen(not Library.Open) end
	Library.Toggle = function() self:Toggle() end
	pcall(function() getgenv().NWHub_Window = self end)

	Library:Connect(UserInputService.InputBegan, function(input, processed)
		if UserInputService:GetFocusedTextBox() then return end
		local key = Library.ToggleKey or Enum.KeyCode.RightShift
		if input.KeyCode == key then
			self:Toggle()
		end
	end)

	--=================================================================
	-- Onglets
	--=================================================================

	function self:AddTab(name, icon)
		local button = New("TextButton", {
			Name = "Tab_" .. name,
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, M.TabRow),
			LayoutOrder = #self.Tabs + 1,
			ZIndex = 5,
			Parent = tabsList,
		})

		local bg = New("Frame", {
			Name = "Bg",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = button,
		})
		Corner(bg, 8)
		AccentGradient(bg, function() return Seq({ Theme.Accent, Theme.Accent }) end, 0, { { 0, 0.7 }, { 1, 0.96 } })

		local indicator = New("Frame", {
			Name = "Indicator",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, -8, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 7,
			Parent = button,
		})
		Corner(indicator, "full")
		AccentGradient(indicator, AccentToCyan, 90)

		local iconHolder = New("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromOffset(16, 16),
			ZIndex = 6,
			Parent = button,
		})
		local iconGui
		if icon == nil then icon = AutoIcon(name) end
		if type(icon) == "string" and (icon:find("rbxasset") or icon:find("rbxthumb") or icon:match("^%d+$")) then
			iconGui = New("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Image = icon:match("^%d+$") and ("rbxassetid://" .. icon) or icon,
				ImageColor3 = Theme.TextFaint,
				ZIndex = 6,
				Parent = iconHolder,
			})
		elseif type(icon) == "string" and #icon > 0 and #icon <= 4 then
			iconGui = New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Text = icon,
				FontFace = FontText(Enum.FontWeight.Bold),
				TextSize = TS(13),
				TextColor3 = Theme.TextFaint,
				ZIndex = 6,
				Parent = iconHolder,
			})
		else
			local d = Diamond(iconHolder, 6, 6)
			d.Position = UDim2.fromScale(0.5, 0.5)
		end

		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -62, 1, 0),
			Text = name,
			FontFace = FontText(Enum.FontWeight.SemiBold),
			TextSize = TS(13),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 6,
			Parent = button,
		})
		Library:Register(label, { TextColor3 = "TextDim" })

		local count = MonoLabel(button, "0", 9, "TextFaint")
		count.AnchorPoint = Vector2.new(1, 0)
		count.Position = UDim2.new(1, -8, 0, 0)
		count.Size = UDim2.new(0, 24, 1, 0)
		count.TextXAlignment = Enum.TextXAlignment.Right
		count.ZIndex = 6

		local content = New("Frame", {
			Name = "Content_" .. name,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = contentHolder,
		})

		-- Pastilles des pages : un surlignage qui glisse sous la rangée.
		local pillBox = New("Frame", {
			Name = "PillBox_" .. name,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, M.PageTab),
			AutomaticSize = Enum.AutomaticSize.X,
			Visible = false,
			ZIndex = 21,
			Parent = pillsHolder,
		})
		local pillBg = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			ZIndex = 21,
			Parent = pillBox,
		})
		Library:Register(pillBg, { BackgroundColor3 = "Panel2" })
		Corner(pillBg, 9)
		Stroke(pillBg, "BorderSoft")

		local highlight = New("Frame", {
			Name = "Highlight",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(0, M.PageTab - 6),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 22,
			Parent = pillBox,
		})
		Corner(highlight, 6)
		AccentGradient(highlight, function()
			return Seq({ Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.12), Theme.AccentDim })
		end, 90)

		local pageRow = New("Frame", {
			Name = "PageRow",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(3, 3),
			Size = UDim2.fromOffset(0, M.PageTab - 6),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 23,
			Parent = pillBox,
		})
		List(pageRow, 2, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		New("UIPadding", { PaddingRight = UDim.new(0, 3), Parent = pillBox })

		local tab = setmetatable({
			Name = name,
			Window = self,
			Button = button,
			Label = label,
			Indicator = indicator,
			CountLabel = count,
			Content = content,
			PageRow = pageRow,
			PillBox = pillBox,
			PagesHolder = content,
			Pages = {},
		}, Tab)

		function tab.RefreshPills()
			pillBox.Visible = (#tab.Pages > 1) and (self.ActiveTab == tab)
		end

		function tab.MoveHighlight(pill, instant)
			task.defer(function()
				local f = math.max(windowScale.Scale, 0.01)
				local x = (pill.AbsolutePosition.X - pillBox.AbsolutePosition.X) / f
				local w = pill.AbsoluteSize.X / f
				local d = instant and 0 or 0.35
				Tween(highlight, d, { Position = UDim2.new(0, x, 0.5, 0), Size = UDim2.fromOffset(w, M.PageTab - 6) })
			end)
		end

		local hovering = false
		local function paint(active)
			Tween(bg, 0.2, { BackgroundTransparency = active and 0 or (hovering and 0.6 or 1) })
			Tween(indicator, 0.25, { Size = UDim2.new(0, 3, 0, active and M.TabRow - 14 or 0) }, Enum.EasingStyle.Exponential)
			Tween(label, 0.15, { TextColor3 = active and Color3.new(1, 1, 1) or (hovering and Theme.Text or Theme.TextDim) })
			if iconGui then
				local c = active and Theme.Glass or Theme.TextFaint
				if iconGui:IsA("ImageLabel") then
					Tween(iconGui, 0.15, { ImageColor3 = c })
				else
					Tween(iconGui, 0.15, { TextColor3 = c })
				end
			end
		end

		function tab:Select()
			local _win = tab.Window or (Library and Library.Window) or self
			for _, other in ipairs(_win.Tabs) do
				if other ~= tab then
					other.Content.Visible = false
					other.PillBox.Visible = false
					other.Paint(false)
				end
			end
			_win.ActiveTab = tab
			content.Visible = true
			paint(true)
			tab.RefreshPills()
			count.Text = tostring(tab:CountRows())
			updateCrumb()
			local pageToSelect = tab.ActivePage or tab.Pages[1]
			if pageToSelect and pageToSelect.Select then
				pageToSelect.Select()
			end
		end
		tab.Paint = paint

		Library:Connect(button.MouseButton1Click, function()
			local _win = tab.Window or (Library and Library.Window) or self
			if _win.ActiveTab ~= tab then tab:Select() end
		end)
		Library:Connect(button.MouseButton1Down, function()
			local _win = tab.Window or (Library and Library.Window) or self
			if _win.ActiveTab ~= tab then tab:Select() end
		end)
		Library:Connect(button.MouseEnter, function()
			hovering = true
			if self.ActiveTab ~= tab then paint(false) end
		end)
		Library:Connect(button.MouseLeave, function()
			hovering = false
			if self.ActiveTab ~= tab then paint(false) end
		end)

		table.insert(self.Tabs, tab)
		if #self.Tabs == 1 then
			pcall(function() tab:Select() end)
			task.defer(function()
				local _win = tab.Window or (Library and Library.Window) or self
				if not _win.ActiveTab then tab:Select() end
			end)
		end
		return tab
	end

	--=================================================================
	-- Bouton d'ouverture (mobile ou sur demande)
	--=================================================================

	if opts.ToggleButton ~= false and (Library.Mobile or opts.ToggleButton) then
		local size2 = Library.Mobile and 46 or 38
		local btn = New("Frame", {
			Name = "ToggleButton",
			Size = UDim2.fromOffset(size2, size2),
			Position = opts.ToggleButtonPosition or UDim2.new(0, 14, 0.5, -60),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 950,
			Parent = ScreenGui,
		})
		Corner(btn, "full")
		AccentGradient(btn, function() return Seq({ Theme.Glass, Theme.Accent, Theme.Background }) end, 45)
		local st = New("UIStroke", { Thickness = 1.5, Transparency = 0.3, Parent = btn })
		Library:Register(st, { Color = "Accent" })
		Scalable(btn)
		local k = New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "鏡",
			FontFace = FontText(Enum.FontWeight.Bold),
			TextSize = 18,
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 951,
			Parent = btn,
		})

		local moved, pressStart, btnStart = false, nil, nil
		local hh = Hit(btn, "ToggleHit", 952)
		Library:Connect(hh.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				moved = false
				pressStart = InputPos(input)
				btnStart = btn.Position
			end
		end)
		Library:Connect(UserInputService.InputChanged, function(input)
			if not pressStart then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				local delta = InputPos(input) - pressStart
				if delta.Magnitude > 6 then
					moved = true
					btn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
				end
			end
		end)
		Library:Connect(UserInputService.InputEnded, function(input)
			if not pressStart then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				pressStart = nil
				if not moved then self:Toggle() end
			end
		end)
		k.Parent = btn
		self.ToggleButton = btn
	end

	-- Première ouverture : avec l'écran de chargement, c'est Finish()
	-- qui ouvre ; sinon on attend que le script ait construit ses onglets.
	Library.Open = false
	if not Library.SplashActive then
		task.defer(function()
			if not Library.Open and not Library.Unloaded then self:SetOpen(true) end
		end)
	end
	return self
end

--=====================================================================
-- Écran de chargement
--=====================================================================

function Library:Splash(opts)
	opts = opts or {}
	Library.SplashActive = true
	local voix = Library:PlaySound("Splash")

	-- Fond : radial-gradient(60% 55% at 50% 45%, #140f2c, #040308 75%).
	-- Pas de dégradé radial dans Roblox : des disques très transparents empilés.
	local backdrop = New("Frame", {
		Name = "Splash",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(4, 3, 8),
		BorderSizePixel = 0,
		ZIndex = 800,
		Parent = ScreenGui,
	})
	for i = 1, 26 do
		local disc = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.fromScale(1.3 * i / 26, 1.3 * i / 26),
			BackgroundColor3 = Color3.fromRGB(20, 15, 44),
			BackgroundTransparency = 1 - 0.14 * (1 - (i - 1) / 26),
			BorderSizePixel = 0,
			ZIndex = 800,
			Parent = backdrop,
		})
		Corner(disc, "full")
		New("UIAspectRatioConstraint", { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Width, Parent = disc })
	end

	local box = New("Frame", {
		Name = "Box",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(320, 260),
		BackgroundTransparency = 1,
		ZIndex = 801,
		Parent = backdrop,
	})
	local scale = New("UIScale", { Scale = Factor() * 0.96, Parent = box })

	local orb, orbStep, orbFx = BuildOrb(box, 120)
	orb.AnchorPoint = Vector2.new(0.5, 0)
	orb.Position = UDim2.new(0.5, 0, 0, 0)
	orb.ZIndex = 802

	-- 鏡花水月 : 34 px, interlettrage 0,25 em, halo violet (text-shadow 0 0 20px).
	-- Chaque caractère arrive de 1,8× et flou, simulé par un halo épais qui se resserre.
	local kanjiRow = New("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 136),
		Size = UDim2.fromOffset(180, 42),
		ZIndex = 802,
		Parent = box,
	})
	local kanji = {}
	local STEP = 42.5
	for i, ch in ipairs({ "鏡", "花", "水", "月" }) do
		local x = (i - 2.5) * STEP
		local function glyph(z, color, transparency)
			return New("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, x, 0.5, 0),
				Size = UDim2.fromOffset(60, 60),
				Text = ch,
				FontFace = FontText(Enum.FontWeight.Bold),
				TextSize = 34,
				TextColor3 = color,
				TextTransparency = transparency,
				ZIndex = z,
				Parent = kanjiRow,
			})
		end
		local halo = glyph(803, Theme.Accent, 1)
		local haloStroke = New("UIStroke", { Color = Theme.Accent, Thickness = 3, Transparency = 1, Parent = halo })
		local main = glyph(805, Color3.new(1, 1, 1), 1)
		local mainStroke = New("UIStroke", { Color = Theme.Accent, Thickness = 1, Transparency = 1, Parent = main })
		table.insert(kanji, { Main = main, MainStroke = mainStroke, Halo = halo, HaloStroke = haloStroke })
	end

	-- Titre espacé (Roblox n'a pas d'interlettrage).
	local spaced = string.upper(opts.Title or "NW HUB"):gsub(".", "%0 "):gsub("%s+$", "")
	local titre = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 194),
		Size = UDim2.new(1, 0, 0, 16),
		Text = spaced,
		FontFace = FontTitle(),
		TextSize = 13,
		TextTransparency = 1,
		ZIndex = 803,
		Parent = box,
	})
	Library:Register(titre, { TextColor3 = "Glass" })

	local piste = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 226),
		Size = UDim2.fromOffset(260, 3),
		BackgroundColor3 = Color3.fromRGB(27, 24, 48),
		BorderSizePixel = 0,
		ZIndex = 803,
		Parent = box,
	})
	Corner(piste, "full")

	-- Lueur sous la jauge (box-shadow 0 0 8px accent).
	local jaugeGlow = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 11),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		ZIndex = 803,
		Parent = piste,
	})
	Corner(jaugeGlow, "full")

	local jauge = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 804,
		Parent = piste,
	})
	Corner(jauge, "full")
	AccentGradient(jauge, function() return Seq({ Color3.fromRGB(91, 73, 230), Theme.Accent, Theme.Accent2 }) end)
	Library:Connect(jauge:GetPropertyChangedSignal("Size"), function()
		jaugeGlow.Size = UDim2.new(jauge.Size.X.Scale, 0, 0, 11)
	end)

	local etat = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 243),
		Size = UDim2.new(1, 0, 0, 14),
		Text = string.lower(opts.Subtitle or "loading"),
		FontFace = FontMono(),
		TextSize = 11,
		ZIndex = 803,
		Parent = box,
	})
	Library:Register(etat, { TextColor3 = "TextFaint" })

	Tween(scale, 0.6, { Scale = Factor() }, Enum.EasingStyle.Exponential)
	Tween(titre, 0.5, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
	for i, k in ipairs(kanji) do
		task.delay(0.2 + (i - 1) * 0.22, function()
			local info = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			k.Main.TextSize = 61
			k.Halo.TextSize = 61
			k.Halo.TextTransparency = 0.5
			k.HaloStroke.Thickness = 6
			k.HaloStroke.Transparency = 0.82
			TweenService:Create(k.Main, info, { TextSize = 34, TextTransparency = 0 }):Play()
			TweenService:Create(k.MainStroke, info, { Transparency = 0.7 }):Play()
			TweenService:Create(k.Halo, info, { TextSize = 34, TextTransparency = 0.78 }):Play()
			TweenService:Create(k.HaloStroke, info, { Thickness = 2.5, Transparency = 0.9 }):Play()
		end)
	end

	local obj = { Instance = backdrop, Progress = 0 }
	local tDebut = os.clock()
	local spin = Library:Connect(RunService.RenderStepped, function(dt)
		orbStep(dt)
	end)

	function obj:SetProgress(valeur, texte)
		obj.Progress = math.clamp(valeur or 0, 0, 1)
		Tween(jauge, 0.3, { Size = UDim2.fromScale(obj.Progress, 1) })
		if texte then etat.Text = string.lower(texte) end
	end

	function obj:Finish(instant)
		if obj.Done then return end
		obj.Done = true

		local function fermer()
			-- L'orbe éclate en morceaux de verre.
			if Library.Effects and not instant then
				local o = FxLayer.AbsolutePosition
				local c = orb.AbsolutePosition + orb.AbsoluteSize / 2 - o
				orbFx.Burst(0.35)
				task.delay(0.21, function()
					for _ = 1, 36 do
						local sz = 14 + math.random() * 40
						local shard = MakeShard(sz, sz * (0.5 + math.random()), false)
						shard.Position = UDim2.fromOffset(c.X, c.Y)
						local a = math.random() * math.pi * 2
						local d = 200 + math.random() * 520
						Tween(shard, 0.9, {
							Position = UDim2.fromOffset(c.X + math.cos(a) * d, c.Y + math.sin(a) * d),
							Rotation = (math.random() - 0.5) * 720,
							BackgroundTransparency = 1,
						}, Enum.EasingStyle.Quint)
						task.delay(0.95, function() shard:Destroy() end)
					end
					FX.Flash({ x = c.X - 70, y = c.Y - 70, w = 140, h = 140 })
				end)
			end

			local wait0 = (Library.Effects and not instant) and 0.45 or 0
			task.delay(wait0, function()
				if spin then spin:Disconnect() end
				Tween(backdrop, 0.35, { BackgroundTransparency = 1 })
				Tween(scale, 0.35, { Scale = Factor() * 1.04 })
				for _, d in ipairs(backdrop:GetDescendants()) do
					if d:IsA("TextLabel") then
						Tween(d, 0.25, { TextTransparency = 1 })
					elseif d:IsA("ViewportFrame") then
						Tween(d, 0.25, { ImageTransparency = 1 })
					elseif d:IsA("Frame") then
						Tween(d, 0.25, { BackgroundTransparency = 1 })
					elseif d:IsA("UIStroke") then
						Tween(d, 0.25, { Transparency = 1 })
					end
				end
				task.delay(0.38, function()
					backdrop:Destroy()
					Library.SplashActive = false
					if Library.Window and not Library.Unloaded then Library.Window:SetOpen(true) end
				end)
			end)
		end

		local attente = 0
		if not instant then
			attente = math.max(attente, (opts.MinDuration or 0) - (os.clock() - tDebut))
			if opts.WaitForSound and voix and voix.IsPlaying then
				local reste = (voix.TimeLength - voix.TimePosition) / math.max(voix.PlaybackSpeed, 0.01)
				attente = math.max(attente, reste)
			end
			attente = math.clamp(attente, 0, 10)
		end

		Tween(jauge, math.max(attente, 0.2), { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Linear)

		task.spawn(function()
			if attente > 0 then task.wait(attente) end
			if instant then fermer() else task.delay(0.2, fermer) end
		end)
	end

	if opts.Steps and #opts.Steps > 0 then
		local minDuree = opts.MinDuration or 2.0
		local duree = math.max(opts.Duration or 2.2, minDuree)
		if voix and voix.TimeLength and voix.TimeLength > 0 then
			local speed = (voix.PlaybackSpeed and voix.PlaybackSpeed > 0) and voix.PlaybackSpeed or 1
			duree = math.max(duree, voix.TimeLength / speed)
		end
		task.spawn(function()
			for i, etape in ipairs(opts.Steps) do
				if obj.Done then return end
				obj:SetProgress(i / #opts.Steps, etape)
				task.wait(duree / #opts.Steps)
			end
			if opts.AutoFinish ~= false then obj:Finish() end
		end)
	end

	Library.CurrentSplash = obj
	return obj
end

--=====================================================================
-- Notifications (en bas à droite)
--=====================================================================

local NotifHolder = New("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.fromOffset(290, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	ZIndex = 700,
	Parent = ScreenGui,
})
Scalable(NotifHolder)
List(NotifHolder, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)

function Library:Notify(opts)
	if type(opts) == "string" then opts = { Content = opts } end
	opts = opts or {}
	local duration = opts.Duration or 4
	local kind = opts.Type
	local accent = opts.Color or (kind == "error" and Theme.Danger) or (kind == "success" and Theme.Success) or Theme.Accent
	local accent2 = (kind == "error" or kind == "success") and accent or Theme.Accent2

	local slot = New("Frame", {
		Name = "Slot",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 700,
		Parent = NotifHolder,
	})

	local card = New("Frame", {
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(60, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 701,
		Parent = slot,
	})
	Library:Register(card, { BackgroundColor3 = "Panel" })
	Corner(card, 9)
	local stroke = Stroke(card, "Border", 1, 1)

	-- Ombre portée (box-shadow 0 14px 40px) : des couches arrondies.
	local shadows = {}
	for i = 1, 5 do
		local spread = i * 3
		local sh = New("Frame", {
			Name = "Shadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 5),
			Size = UDim2.new(1, spread * 2, 1, spread * 2),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 700,
			Parent = card,
		})
		Corner(sh, 9 + spread)
		table.insert(shadows, { Frame = sh, Target = 0.88 + i * 0.012 })
	end

	-- Icône : carré arrondi en dégradé, avec un halo de sa couleur.
	local iconGlow = {}
	for i = 1, 3 do
		local g = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(25, 25),
			Size = UDim2.fromOffset(26 + i * 7, 26 + i * 7),
			BackgroundColor3 = accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 701,
			Parent = card,
		})
		Corner(g, 7 + i * 3)
		table.insert(iconGlow, { Frame = g, Target = 0.9 + i * 0.03 })
	end

	local icon = New("Frame", {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ZIndex = 702,
		Parent = card,
	})
	Corner(icon, 7)
	New("UIGradient", { Rotation = 135, Color = Seq({ accent, accent:Lerp(Color3.new(0, 0, 0), 0.45) }), Parent = icon })
	local iconScale = New("UIScale", { Scale = 0.6, Parent = icon })
	local glyph = New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = kind == "error" and "!" or (kind == "success" and "✓" or "鏡"),
		FontFace = FontText(Enum.FontWeight.Bold),
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = 1,
		ZIndex = 703,
		Parent = icon,
	})

	local body = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(48, 0),
		Size = UDim2.new(1, -60, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 702,
		Parent = card,
	})
	Padding(body, 11, 14, 0, 0)
	List(body, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local texts = {}
	if opts.Title then
		local t = Label(body, opts.Title, 12.5, "Text", Enum.FontWeight.SemiBold)
		t.Size = UDim2.new(1, 0, 0, 16)
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.ZIndex = 703
		t.TextTransparency = 1
		table.insert(texts, t)
	end
	local c = Label(body, opts.Content or "", 11.5, "TextDim")
	c.TextWrapped = true
	c.AutomaticSize = Enum.AutomaticSize.Y
	c.Size = UDim2.new(1, 0, 0, 0)
	c.TextYAlignment = Enum.TextYAlignment.Top
	c.ZIndex = 703
	c.TextTransparency = 1
	table.insert(texts, c)

	-- Jauge de vie de la notification, dégradé comme sur le site.
	local bar = New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 5, 1, 0),
		Size = UDim2.new(1, -10, 0, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ZIndex = 704,
		Parent = card,
	})
	Corner(bar, "full")
	New("UIGradient", { Color = Seq({ accent, accent2 }), Parent = bar })

	-- Clic pour fermer tout de suite.
	local hit = Hit(card, "NotifHit", 705)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		Tween(card, 0.3, { Position = UDim2.fromOffset(60, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
		Tween(stroke, 0.25, { Transparency = 1 })
		Tween(icon, 0.25, { BackgroundTransparency = 1 })
		Tween(glyph, 0.25, { TextTransparency = 1 })
		Tween(bar, 0.25, { BackgroundTransparency = 1 })
		for _, g in ipairs(iconGlow) do Tween(g.Frame, 0.2, { BackgroundTransparency = 1 }) end
		for _, sh in ipairs(shadows) do Tween(sh.Frame, 0.2, { BackgroundTransparency = 1 }) end
		for _, t in ipairs(texts) do Tween(t, 0.25, { TextTransparency = 1 }) end
		task.delay(0.32, function() slot:Destroy() end)
	end
	Library:Connect(hit.MouseButton1Click, close)

	Tween(card, 0.45, { Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.04 }, Enum.EasingStyle.Exponential)
	Tween(stroke, 0.3, { Transparency = 0 })
	Tween(icon, 0.3, { BackgroundTransparency = 0 })
	Tween(iconScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Exponential)
	Tween(glyph, 0.3, { TextTransparency = 0 })
	Tween(bar, 0.3, { BackgroundTransparency = 0 })
	for _, sh in ipairs(shadows) do Tween(sh.Frame, 0.4, { BackgroundTransparency = sh.Target }) end
	for _, g in ipairs(iconGlow) do Tween(g.Frame, 0.4, { BackgroundTransparency = g.Target }) end
	for _, t in ipairs(texts) do Tween(t, 0.3, { TextTransparency = 0 }) end
	-- Reflet qui balaie la carte à l'arrivée, puis la jauge se vide.
	task.delay(0.12, function()
		if not closed then FX.Sweep(card, 0, 0.7) end
	end)
	Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

	task.delay(duration, close)

	return card
end

--=====================================================================
-- Filigrane
--=====================================================================

local Watermark = New("Frame", {
	Name = "Watermark",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(0, 26),
	AutomaticSize = Enum.AutomaticSize.X,
	Visible = false,
	ClipsDescendants = true,
	ZIndex = 600,
	Parent = ScreenGui,
})
Library:Register(Watermark, { BackgroundColor3 = "Panel" })
do
	local Watermark = New("Frame", {
		Name = "Watermark",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 600,
		Parent = ScreenGui,
	})
	Library:Register(Watermark, { BackgroundColor3 = "Panel" })
	Corner(Watermark, 7)
	Scalable(Watermark)
	Stroke(Watermark, "Border")
	List(Watermark, 0, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

	local WatermarkHead = New("Frame", {
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		LayoutOrder = 1,
		ZIndex = 601,
		Parent = Watermark,
	})
	AccentGradient(WatermarkHead, function() return Seq({ Theme.Accent, Theme.Accent }) end, 0, { { 0, 0.6 }, { 1, 0.9 } })
	Corner(WatermarkHead, 7)
	Padding(WatermarkHead, 0, 0, 10, 10)

	local WatermarkHeadText = New("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		FontFace = FontMono(Enum.FontWeight.Bold),
		TextSize = TS(11),
		TextColor3 = Color3.new(1, 1, 1),
		RichText = true,
		Text = "",
		ZIndex = 602,
		Parent = WatermarkHead,
	})

	local WatermarkText = New("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		FontFace = FontMono(Enum.FontWeight.Medium),
		TextSize = TS(11),
		RichText = true,
		Text = "",
		LayoutOrder = 2,
		ZIndex = 602,
		Parent = Watermark,
	})
	Library:Register(WatermarkText, { TextColor3 = "TextDim" })
	New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12), Parent = WatermarkText })

	local watermarkTemplate = ""
	local watermarkAuto = true
	local watermarkWanted = false

	local function ApplyWatermarkVisibility()
		Watermark.Visible = watermarkWanted and watermarkTemplate ~= ""
	end

	function Library:SetWatermark(text, visible)
		watermarkTemplate = text or ""
		if visible ~= nil then watermarkWanted = visible ~= false else watermarkWanted = true end
		ApplyWatermarkVisibility()
	end

	function Library:SetWatermarkVisible(v)
		watermarkWanted = v and true or false
		ApplyWatermarkVisibility()
	end

	function Library:SetWatermarkPosition(position, anchor)
		watermarkAuto = false
		Watermark.AnchorPoint = anchor or Vector2.new(0.5, 0)
		Watermark.Position = position or UDim2.new(0.5, 0, 0, 8)
	end

	do
		local frames, acc, fps = 0, 0, 60
		local lastInsetY = -1
		local lastWmTick = 0
		Library:Connect(RunService.RenderStepped, function(dt)
			local now = tick()
			if now - lastWmTick < 0.1 then return end   -- 10 Hz max
			lastWmTick = now

			frames = frames + 1
			acc = acc + dt
			if acc >= 0.5 then
				fps = math.floor(frames / acc)
				frames, acc = 0, 0
				if Watermark.Visible then
					local ping = 0
					pcall(function()
						ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
					end)
					local out = watermarkTemplate
						:gsub("{[Ff][Pp][Ss]}", tostring(fps))
						:gsub("{[Pp][Ii][Nn][Gg]}", tostring(ping) .. "ms")
						:gsub("{[Pp][Ll][Aa][Yy][Ee][Rr]}%s*/%s*", "")
						:gsub("/%s*{[Pp][Ll][Aa][Yy][Ee][Rr]}", "")
						:gsub("{[Pp][Ll][Aa][Yy][Ee][Rr]}", "")
						:gsub("{[Tt][Ii][Mm][Ee]}", os.date("%H:%M:%S"))
					local parts = {}
					for seg in out:gmatch("[^/]+") do
						local s = seg:match("^%s*(.-)%s*$")
						if s ~= "" then table.insert(parts, s) end
					end
					WatermarkHeadText.Text = "鏡 " .. string.upper(parts[1] or "")
					table.remove(parts, 1)
					WatermarkText.Text = string.upper(table.concat(parts, "  ·  "))
					WatermarkText.Visible = #parts > 0
				end
			end
			if Watermark.Visible and watermarkAuto then
				local insetY = GuiService:GetGuiInset().Y
				if insetY ~= lastInsetY then
					lastInsetY = insetY
					Watermark.Position = UDim2.new(0.5, 0, 0, insetY + 6)
				end
			end
		end)
	end
end

--=====================================================================
-- Liste des raccourcis actifs
--=====================================================================

do
	local KeyList = New("Frame", {
		Name = "KeybindList",
		Position = UDim2.fromOffset(16, 64),
		Size = UDim2.fromOffset(190, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 600,
		Parent = ScreenGui,
	})
	Library:Register(KeyList, { BackgroundColor3 = "Panel" })
	Corner(KeyList, 8)
	Scalable(KeyList)
	Stroke(KeyList, "Border")


	local KeyListHead = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 601,
		Parent = KeyList,
	})
	local KeyListHeadBg = New("Frame", {
		Size = UDim2.new(1, 0, 1, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 601,
		Parent = KeyListHead,
	})
	Corner(KeyListHeadBg, 8)
	AccentGradient(KeyListHeadBg, function() return Seq({ Theme.Accent, Theme.Accent }) end, 0, { { 0, 0.72 }, { 1, 1 } })

	-- Filet lumineux sur le bord haut, comme le filigrane du site.
	local KeyListEdge = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 604,
		Parent = KeyListHead,
	})
	AccentGradient(KeyListEdge, AccentToCyan, 0, { { 0, 0 }, { 0.55, 0.3 }, { 1, 1 } })

	local KeyListDia = Diamond(KeyListHead, 5, 602)
	KeyListDia.Position = UDim2.new(0, 11, 0.5, 0)

	local KeyListTitle = MonoLabel(KeyListHead, "KEYBINDS", 10, "Glass")
	KeyListTitle.Position = UDim2.fromOffset(21, 0)
	KeyListTitle.ZIndex = 602

	local KeyListCount = MonoLabel(KeyListHead, "", 9.5, "Glass")
	KeyListCount.AnchorPoint = Vector2.new(1, 0)
	KeyListCount.Position = UDim2.new(1, -10, 0, 0)
	KeyListCount.Size = UDim2.new(0, 30, 1, 0)
	KeyListCount.TextXAlignment = Enum.TextXAlignment.Right
	KeyListCount.ZIndex = 602

	local KeyListBody = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 601,
		Parent = KeyList,
	})
	Padding(KeyListBody, 6, 8, 10, 10)
	List(KeyListBody, 3, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local keyListWanted = false
	local function KeyListRefreshVisibility(count)
		KeyList.Visible = keyListWanted and count > 0
	end

	function Library:SetKeybindListVisible(v)
		keyListWanted = v and true or false
		KeyList.Visible = keyListWanted
	end

	do
		local rows = {}
		Library:Connect(RunService.Heartbeat, function()
			if not keyListWanted then return end
			local count = 0
			for _, bind in ipairs(KeybindRegistry) do
				if bind.Value.Key then
					count += 1
					local row = rows[bind]
					if not row then
						local frame = New("Frame", {
							Name = "Bind",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 20),
							ZIndex = 602,
							Parent = KeyListBody,
						})
						local name = Label(frame, bind.DisplayName, 11.5, "TextDim")
						name.Size = UDim2.new(1, -62, 1, 0)
						name.TextTruncate = Enum.TextTruncate.AtEnd
						name.ZIndex = 603

						-- Pastille de touche, comme les raccourcis dans le menu.
						local chip = New("Frame", {
							Name = "Chip",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.fromOffset(0, 17),
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundColor3 = Color3.new(1, 1, 1),
							ZIndex = 603,
							Parent = frame,
						})
						Library:Register(chip, { BackgroundColor3 = "Element" })
						Corner(chip, 5)
						local chipStroke = Stroke(chip, "Border")
						Padding(chip, 0, 0, 6, 6)
						local key = MonoLabel(chip, "", 9.5, "TextDim")
						key.AutomaticSize = Enum.AutomaticSize.X
						key.Size = UDim2.new(0, 0, 1, 0)
						key.TextXAlignment = Enum.TextXAlignment.Center
						key.ZIndex = 604

						rows[bind] = { Frame = frame, Key = key, Name = name, Chip = chip, Stroke = chipStroke }
						row = rows[bind]
					end
					row.Frame.Visible = true
					local on = bind:GetState()
					local text = "[" .. string.upper(KeyName(bind.Value.Key)) .. "]"
					if row.Key.Text ~= text then row.Key.Text = text end
					-- Repeint seulement quand l'état change.
					if row.On ~= on then
						row.On = on
						Tween(row.Name, 0.15, { TextColor3 = on and Color3.new(1, 1, 1) or Theme.TextDim })
						Tween(row.Key, 0.15, { TextColor3 = on and Theme.Glass or Theme.TextDim })
						Tween(row.Chip, 0.15, {
							BackgroundColor3 = on and Theme.Accent or Theme.Element,
							BackgroundTransparency = on and 0.72 or 0,
						})
						Tween(row.Stroke, 0.15, { Color = on and Theme.Accent or Theme.Border })
					end
				elseif rows[bind] then
					rows[bind].Frame.Visible = false
				end
			end
			KeyListCount.Text = tostring(count)
			KeyListRefreshVisibility(count)
		end)
	end
end

--=====================================================================
-- Curseur dessiné (beaucoup de jeux cachent l'icône système)
--=====================================================================

do
	local Cursor = New("Frame", {
		Name = "Cursor",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(12, 17),
		Visible = false,
		ZIndex = 1000,
		Parent = ScreenGui,
	})
	Scalable(Cursor)

	local ARROW = {
		{0,0,1}, {1,0,2}, {2,0,3}, {3,0,4}, {4,0,5}, {5,0,6},
		{6,0,7}, {7,0,8}, {8,0,9}, {9,0,6},
		{10,0,2}, {10,4,3},
		{11,0,1}, {11,5,3},
		{12,6,3},
		{13,7,2},
	}

	for _, pass in ipairs({ { Color3.new(0, 0, 0), 1, 1000 }, { Color3.new(1, 1, 1), 0, 1001 } }) do
		for _, seg in ipairs(ARROW) do
			New("Frame", {
				BackgroundColor3 = pass[1],
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(seg[3], 1),
				Position = UDim2.fromOffset(seg[2] + pass[2], seg[1] + pass[2]),
				ZIndex = pass[3],
				Parent = Cursor,
			})
		end
	end

	local cursorEnabled = not Library.Mobile
	local systemIconWasEnabled = nil

	function Library:SetCursorEnabled(state)
		cursorEnabled = state ~= false
		if not cursorEnabled then Library:ShowCursor(false) end
	end

	function Library:ShowCursor(state)
		if state and cursorEnabled then
			if systemIconWasEnabled == nil then
				systemIconWasEnabled = UserInputService.MouseIconEnabled
			end
			UserInputService.MouseIconEnabled = false
			Cursor.Visible = true
		else
			Cursor.Visible = false
			if systemIconWasEnabled ~= nil then
				UserInputService.MouseIconEnabled = systemIconWasEnabled
				systemIconWasEnabled = nil
			end
		end
	end

	Library:Connect(RunService.RenderStepped, function()
		if not Cursor.Visible then return end
		local x, y = MouseLocal()
		Cursor.Position = UDim2.fromOffset(x, y)
		if UserInputService.MouseIconEnabled then
			UserInputService.MouseIconEnabled = false
		end
	end)
end

--=====================================================================
-- Configuration (même format que Vesper)
--=====================================================================

local function Serialize(value)
	if typeof(value) == "Color3" then
		return { __t = "Color3", R = value.R, G = value.G, B = value.B }
	elseif typeof(value) == "EnumItem" then
		return { __t = "Enum", Name = value.Name, Type = tostring(value.EnumType) }
	elseif type(value) == "table" then
		if value.Key ~= nil or value.Mode ~= nil then
			local k = value.Key
			return {
				__t = "Keybind",
				Key = k and (typeof(k) == "EnumItem" and k.Name or tostring(k)) or nil,
				IsMouse = k and typeof(k) == "EnumItem" and tostring(k.EnumType) == "Enum.UserInputType" or false,
				Mode = value.Mode,
			}
		end
		local out = { __t = "List" }
		for i, v in ipairs(value) do out[i] = Serialize(v) end
		return out
	end
	return value
end

local function Deserialize(value)
	if type(value) ~= "table" then return value end
	if value.__t == "Color3" then
		return Color3.new(value.R, value.G, value.B)
	elseif value.__t == "Enum" then
		local enumType = value.Type:gsub("Enum%.", "")
		local ok, item = pcall(function() return Enum[enumType][value.Name] end)
		return ok and item or nil
	elseif value.__t == "Keybind" then
		local key
		if value.Key then
			if value.IsMouse then
				key = Enum.UserInputType[value.Key]
			else
				local ok, k = pcall(function() return Enum.KeyCode[value.Key] end)
				key = ok and k or nil
			end
		end
		return { Key = key, Mode = value.Mode }
	elseif value.__t == "List" then
		local out = {}
		for i, v in ipairs(value) do out[i] = Deserialize(v) end
		return out
	end
	return value
end

function Library:GetConfig()
	local data = {}
	for flag, option in pairs(Library.Options) do
		if option.Get then
			local ok, v = pcall(option.Get, option)
			if ok then data[flag] = Serialize(v) end
		end
	end
	return data
end

function Library:LoadConfig(data)
	if type(data) ~= "table" then return false end
	for flag, raw in pairs(data) do
		local option = Library.Options[flag]
		if option and option.Set then
			pcall(option.Set, option, Deserialize(raw))
		end
	end
	return true
end

local CONFIG_DIR = "vesper"

local function HasFS()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfolder) == "function"
end

function Library:SaveConfigToFile(name, folder)
	local dir = folder or CONFIG_DIR
	if not HasFS() then return false, "file system unavailable" end
	if not isfolder(dir) then makefolder(dir) end
	local ok, err = pcall(function()
		writefile(dir .. "/" .. name .. ".json", HttpService:JSONEncode(Library:GetConfig()))
	end)
	return ok, err
end

function Library:LoadConfigFromFile(name, folder)
	local dir = folder or CONFIG_DIR
	if not HasFS() then return false, "file system unavailable" end
	local path = dir .. "/" .. name .. ".json"
	if not isfile(path) then return false, "config not found" end
	local ok, err = pcall(function()
		Library:LoadConfig(HttpService:JSONDecode(readfile(path)))
	end)
	return ok, err
end

function Library:ListConfigs(folder)
	local dir = folder or CONFIG_DIR
	if not HasFS() or not isfolder(dir) then return {} end
	local out = {}
	for _, path in ipairs(listfiles(dir)) do
		local name = path:match("([^/\\]+)%.json$")
		if name then table.insert(out, name) end
	end
	return out
end

--=====================================================================
-- Déchargement
--=====================================================================

function Library:Unload()
	if Library.Unloaded then return end
	Library.Unloaded = true
	pcall(function() Library:ShowCursor(false) end)
	pcall(FX.ClearBlur)
	for _, conn in ipairs(Library.Connections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(Library.Connections)
	for _, snd in pairs(soundCache) do
		pcall(function() snd:Destroy() end)
	end
	table.clear(soundCache)
	pcall(function() ScreenGui:Destroy() end)
	if Library.OnUnload then pcall(Library.OnUnload) end
end

return Library

end)()


local Vesper = Kyoka

-- Guarantee splash asset ID
pcall(function()
    if Vesper and Vesper.Sound and Vesper.Sound.Splash then
        local asset = (Vesper.GetSplashAsset and Vesper.GetSplashAsset()) or Vesper.Sound.Splash.Id
        Vesper.Sound.Splash.Id = asset
        Vesper.Sound.Splash.Speed = 1
        Vesper.Sound.Splash.Volume = 1
    end
end)

-- =====================================================================
-- VESPER RAYFIELD ADAPTER (with CreateInput fix)
-- =====================================================================
local function CreateVesperRayfieldAdapter(Vesper)
    local Adapter = {
        Flags = setmetatable({}, {
            __index = function(_, k)
                return { CurrentValue = Vesper.Flags[k] }
            end
        })
    }

    function Adapter:Notify(cfg)
        cfg = cfg or {}
        Vesper:Notify({
            Title = cfg.Title or cfg.title or "NW Hub",
            Content = cfg.Content or cfg.content or cfg.Text or "",
            Duration = cfg.Duration or cfg.duration or 4,
            Type = cfg.Type or "info"
        })
    end

    function Adapter:Destroy()
        pcall(function() Vesper:Unload() end)
    end

    function Adapter:CreateWindow(cfg)
        cfg = cfg or {}
        local defaultTitle = "The Veil — " .. TierName
        local title = cfg.Name or cfg.name or cfg.Title or defaultTitle
        local subtitle = cfg.LoadingSubtitle or cfg.loadingsubtitle or cfg.Subtitle or TierSubtitle

        local toggleKey = cfg.ToggleKey or cfg.togglekey or cfg.OpenKey or cfg.openkey or Enum.KeyCode.RightControl
        local keyText = (Vesper.KeyName and Vesper.KeyName(toggleKey)) or (toggleKey and toggleKey.Name) or "RCtrl"

        local isMobile = Vesper.Mobile
        if isMobile == nil then isMobile = (type(DetectMobile) == "function" and DetectMobile()) or false end
        local win = Vesper:CreateWindow({
            Title = title,
            Subtitle = subtitle ~= "" and subtitle or nil,
            Tier = IsFreeTier and "FREE EDITION" or "VIP PREMIUM",
            Footer = "v5.0.1",
            Size = isMobile and nil or UDim2.fromOffset(720, 460),
            Accent = Color3.fromRGB(255, 150, 205),
            ToggleKey = toggleKey,
            StatusRight = (Vesper.Mobile and "Tap icon to toggle" or (keyText .. " to toggle")),
        })

        Vesper:SetWatermark("The Veil / " .. (subtitle ~= "" and subtitle or TierSubtitle) .. " / FPS {fps} / {ping} / {time}", true)
        Vesper:SetKeybindListVisible(false)

        local WindowWrapper = { Window = win }

        function WindowWrapper:Unload() pcall(function() Vesper:Unload() end) end
        function WindowWrapper:Destroy() pcall(function() Vesper:Unload() end) end

        function WindowWrapper:CreateTab(tabCfg)
            tabCfg = tabCfg or {}
            local tabName = tabCfg.Name or tabCfg.name or "Tab"
            local vTab = win:AddTab(tabName)

            local currentSide = "Left"
            local currentGroup = nil
            local groupCount = 0

            local TabWrapper = { Tab = vTab }

            local function ensureGroup(groupName)
                if not currentGroup or (groupName and currentGroup._name ~= groupName) then
                    groupCount = groupCount + 1
                    currentSide = (groupCount % 2 == 1) and "Left" or "Right"
                    local name = groupName or (tabName .. " (" .. currentSide .. ")")
                    currentGroup = vTab:AddGroup(name, currentSide)
                    currentGroup._name = name
                end
                return currentGroup
            end

            function TabWrapper:CreateSection(secCfg)
                secCfg = secCfg or {}
                local secName = secCfg.Name or secCfg.name or "Section"
                groupCount = groupCount + 1
                currentSide = (groupCount % 2 == 1) and "Left" or "Right"
                currentGroup = vTab:AddGroup(secName, currentSide)
                currentGroup._name = secName
                return currentGroup
            end

            function TabWrapper:CreateToggle(tCfg)
                tCfg = tCfg or {}
                local grp = ensureGroup()
                local flag = tCfg.Flag or tCfg.flag or tCfg.Name or tCfg.name
                local isLocked = (tCfg.Locked == true) or (tCfg.PremiumOnly == true and IsFreeTier)
                local el = grp:AddToggle(flag, {
                    Text = tCfg.Name or tCfg.name or flag,
                    Default = not isLocked and (tCfg.CurrentValue ~= nil and tCfg.CurrentValue or (tCfg.Default or false)) or false,
                    Tooltip = tCfg.Tooltip or tCfg.tooltip,
                    Locked = isLocked,
                    LockedText = tCfg.LockedText or "This feature is reserved for VIP members! Join Discord: https://discord.gg/Gp2N788WVh",
                    Callback = function(v)
                        if isLocked then return end
                        if tCfg.Callback then tCfg.Callback(v) end
                    end
                })
                return el
            end

            function TabWrapper:CreateSlider(sCfg)
                sCfg = sCfg or {}
                local grp = ensureGroup()
                local range = sCfg.Range or sCfg.range or {0, 100}
                local flag = sCfg.Flag or sCfg.flag or sCfg.Name or sCfg.name
                local rounding = 0
                if sCfg.Increment and sCfg.Increment < 1 then
                    rounding = 2
                end
                local el = grp:AddSlider(flag, {
                    Text = sCfg.Name or sCfg.name or flag,
                    Min = range[1] or 0,
                    Max = range[2] or 100,
                    Default = sCfg.CurrentValue or sCfg.Default or range[1],
                    Rounding = rounding,
                    Suffix = sCfg.Suffix or sCfg.suffix or "",
                    Tooltip = sCfg.Tooltip or sCfg.tooltip,
                    Callback = sCfg.Callback or sCfg.callback
                })
                return el
            end

            function TabWrapper:CreateDropdown(dCfg)
                dCfg = dCfg or {}
                local grp = ensureGroup()
                local flag = dCfg.Flag or dCfg.flag or dCfg.Name or dCfg.name
                local options = dCfg.Options or dCfg.options or {}
                local default = dCfg.CurrentOption or dCfg.Default
                if type(default) == "table" then
                    default = default[1]
                end
                local el = grp:AddDropdown(flag, {
                    Text = dCfg.Name or dCfg.name or flag,
                    Values = options,
                    Default = default,
                    Tooltip = dCfg.Tooltip or dCfg.tooltip,
                    Callback = function(val)
                        if dCfg.Callback then
                            dCfg.Callback(type(dCfg.CurrentOption) == "table" and {val} or val)
                        end
                    end
                })
                function el:Set(newVal)
                    if type(newVal) == "table" then newVal = newVal[1] end
                    if self.Select then
                        self:Select(newVal)
                    end
                end
                function el:Refresh(newOpts, selectVal)
                    if self.SetValues then
                        self:SetValues(newOpts or {}, selectVal ~= nil and true or false)
                    else
                        self.Values = newOpts or {}
                    end
                end
                return el
            end

            function TabWrapper:CreateButton(bCfg)
                bCfg = bCfg or {}
                local grp = ensureGroup()
                local isLocked = (bCfg.Locked == true) or (bCfg.PremiumOnly == true and IsFreeTier)
                local el = grp:AddButton(bCfg.Name or bCfg.name or "Button", {
                    Locked = isLocked,
                    LockedText = bCfg.LockedText or "This feature is reserved for VIP members! Join Discord: https://discord.gg/Gp2N788WVh",
                    Callback = function()
                        if isLocked then return end
                        if bCfg.Callback then bCfg.Callback() end
                    end
                })
                return el
            end

            function TabWrapper:CreateKeybind(kCfg)
                kCfg = kCfg or {}
                local grp = ensureGroup()
                local flag = kCfg.Flag or kCfg.flag or kCfg.Name or kCfg.name
                local el = grp:AddKeybind(flag, {
                    Text = kCfg.Name or kCfg.name or flag,
                    Default = kCfg.CurrentKeybind or kCfg.Default or Enum.KeyCode.E,
                    Mode = kCfg.Mode or "Toggle",
                    Callback = kCfg.Callback or kCfg.callback,
                    Changed = kCfg.Changed
                })
                return el
            end

            function TabWrapper:CreateColorPicker(cCfg)
                cCfg = cCfg or {}
                local grp = ensureGroup()
                local flag = cCfg.Flag or cCfg.flag or cCfg.Name or cCfg.name
                local el = grp:AddColorPicker(flag, {
                    Text = cCfg.Name or cCfg.name or flag,
                    Default = cCfg.Color or cCfg.Default or Color3.new(1, 1, 1),
                    Callback = cCfg.Callback or cCfg.callback
                })
                return el
            end

            function TabWrapper:CreateLabel(text)
                local grp = ensureGroup()
                local el = grp:AddLabel(tostring(text))
                function el:Set(t) self:SetText(tostring(t)) end
                return el
            end

            function TabWrapper:CreateText(tCfg)
                tCfg = tCfg or {}
                local grp = ensureGroup()
                local prefix = tCfg.Name or tCfg.name or ""
                local val = tCfg.Text or tCfg.text or ""
                local initial = (prefix ~= "" and (prefix .. ": ") or "") .. val
                local el = grp:AddLabel(initial)
                function el:Set(newVal)
                    local disp = (prefix ~= "" and (prefix .. ": ") or "") .. tostring(newVal)
                    self:SetText(disp)
                end
                return el
            end

            function TabWrapper:CreateParagraph(pCfg)
                pCfg = pCfg or {}
                local grp = ensureGroup()
                local title = pCfg.Title or pCfg.title or pCfg.Name or ""
                local body = pCfg.Content or pCfg.content or ""
                local el = grp:AddParagraph(title, body)
                return el
            end

            function TabWrapper:CreateDivider()
                local grp = ensureGroup()
                return grp:AddDivider()
            end

            -- FIX #4: use the actual AddTextbox method name
            function TabWrapper:CreateInput(iCfg)
                iCfg = iCfg or {}
                local grp = ensureGroup()
                local flag = iCfg.Flag or iCfg.flag or iCfg.Name or iCfg.name
                local el = grp:AddTextbox(flag, {
                    Text = iCfg.Name or iCfg.name or flag,
                    Default = iCfg.CurrentValue or iCfg.Default or "",
                    Placeholder = iCfg.PlaceholderText or iCfg.Placeholder or iCfg.placeholder or "",
                    Callback = iCfg.Callback or iCfg.callback
                })
                return el
            end

            -- Settings tab auto-extras
            if tabName:lower():find("setting") then
                task.defer(function()
                    local cleanGame = title:gsub("%s+", "_"):lower():gsub("[^%w_]", "")
                    local configFolder = "nwhub_" .. (cleanGame ~= "" and cleanGame or "game")
                    Vesper.ConfigFolder = configFolder

                    local currentCfgName = "default"
                    local configDropdown = nil

                    local function getUpdatedConfigs()
                        local list = Vesper:ListConfigs(configFolder)
                        if #list == 0 then list = { "default" } end
                        return list
                    end

                    local cfgGrp = vTab:AddGroup("Configuration Manager", "Left")

                    cfgGrp:AddTextbox("ConfigNameInput", {
                        Text = "Config Name",
                        Default = "default",
                        Placeholder = "Enter config name...",
                        Callback = function(val)
                            if val and val:match("%S") then
                                currentCfgName = val:match("^%s*(.-)%s*$")
                            end
                        end
                    })

                    configDropdown = cfgGrp:AddDropdown("SavedConfigsList", {
                        Text = "Saved Configs",
                        Values = getUpdatedConfigs(),
                        Default = "default",
                        Tooltip = "Select a saved configuration file",
                        Callback = function(val)
                            currentCfgName = val
                            if Vesper.Options.ConfigNameInput then
                                Vesper.Options.ConfigNameInput:Set(val)
                            end
                        end
                    })

                    cfgGrp:AddButton("Save Configuration", {
                        Callback = function()
                            local name = currentCfgName or "default"
                            local ok, err = Vesper:SaveConfigToFile(name, configFolder)
                            if ok then
                                Vesper:Notify({
                                    Title = "Config Manager",
                                    Content = "Saved '" .. name .. ".json'",
                                    Duration = 3,
                                    Type = "success"
                                })
                                if configDropdown then
                                    configDropdown:Refresh(getUpdatedConfigs(), name)
                                end
                            else
                                Vesper:Notify({
                                    Title = "Config Error",
                                    Content = tostring(err or "Failed to save"),
                                    Duration = 3,
                                    Type = "error"
                                })
                            end
                        end
                    })

                    cfgGrp:AddButton("Load Configuration", {
                        Callback = function()
                            local name = currentCfgName or "default"
                            local ok, err = Vesper:LoadConfigFromFile(name, configFolder)
                            if ok then
                                Vesper:Notify({
                                    Title = "Config Manager",
                                    Content = "Loaded '" .. name .. ".json'",
                                    Duration = 3,
                                    Type = "success"
                                })
                            else
                                Vesper:Notify({
                                    Title = "Config Error",
                                    Content = tostring(err or "Config not found"),
                                    Duration = 3,
                                    Type = "error"
                                })
                            end
                        end
                    })

                    cfgGrp:AddButton("Refresh Configs List", {
                        Callback = function()
                            if configDropdown then
                                configDropdown:Refresh(getUpdatedConfigs(), currentCfgName)
                                Vesper:Notify({
                                    Title = "Config Manager",
                                    Content = "Refreshed config files list",
                                    Duration = 2,
                                    Type = "info"
                                })
                            end
                        end
                    })

                    local sysGrp = vTab:AddGroup("Interface & Controls", "Right")

                    sysGrp:AddKeybind("MenuToggleKey", {
                        Text = "Menu Keybind",
                        Default = toggleKey,
                        Tooltip = "Key to open and close this hub menu",
                        Changed = function(v)
                            if v and v.Key then
                                Vesper.ToggleKey = v.Key
                                local kName = (Vesper.KeyName and Vesper.KeyName(v.Key)) or v.Key.Name
                                win:SetStatus(nil, kName .. " to toggle")
                                Vesper:Notify({
                                    Title = "Menu Keybind",
                                    Content = "Toggle key set to " .. kName,
                                    Duration = 2,
                                    Type = "info"
                                })
                            end
                        end
                    })

                    sysGrp:AddToggle("ShowWatermark", {
                        Text = "Show Watermark (FPS / Ping)",
                        Default = true,
                        Tooltip = "Toggle top watermark bar with FPS and Ping stats",
                        Callback = function(v) Vesper:SetWatermarkVisible(v) end
                    })

                    sysGrp:AddToggle("ShowKeybinds", {
                        Text = "Show Keybinds List",
                        Default = false,
                        Tooltip = "Toggle active keybinds list overlay",
                        Callback = function(v) Vesper:SetKeybindListVisible(v) end
                    })

                    sysGrp:AddSlider("KyokaScale", {
                        Text = "UI Scale",
                        Min = 1.0,
                        Max = 2.5,
                        Default = Vesper.Scale or 1.8,
                        Rounding = 1,
                        Suffix = "x",
                        Tooltip = "Global interface scale factor (1.8x default)",
                        Callback = function(v) Vesper:SetScale(v) end
                    })

                    sysGrp:AddToggle("KyokaCursor", {
                        Text = "Kyoka Cursor",
                        Default = true,
                        Tooltip = "Pixel vector cursor with drop shadow",
                        Callback = function(v) Vesper:SetCursorEnabled(v) end
                    })

                    sysGrp:AddColorPicker("KyokaAccent", {
                        Text = "Accent Color",
                        Default = Vesper.Theme.Accent,
                        Callback = function(c) Vesper:SetAccent(c) end
                    })
                end)
            end

            return TabWrapper
        end

        return WindowWrapper
    end

    return Adapter
end

local Rayfield = CreateVesperRayfieldAdapter(Vesper)

local Window = Rayfield:CreateWindow({
    Name = "The Veil — " .. TierName,
    LoadingTitle = "The Veil",
    LoadingSubtitle = TierSubtitle,
    Theme = "Default",
    ToggleKey = Enum.KeyCode.RightControl,
    OpenKey = Enum.KeyCode.RightControl
})

local UIElements = {}

-- ================================================
--  TAB 1 : UTILITIES
-- ================================================
local FarmTab = Window:CreateTab({ Name = "UTILITIES", Icon = "sparkles" })

if IsFreeTier then
    FarmTab:CreateSection({ Name = "Upgrade to VIP" })
    FarmTab:CreateButton({
        Name = "⭐ Unlock Premium / Join Discord",
        Callback = function()
            if setclipboard then pcall(setclipboard, "https://discord.gg/Gp2N788WVh") end
            NotifyUser("NW Hub | VIP", "Discord invite copied to clipboard! (https://discord.gg/Gp2N788WVh)", 4)
        end
    })
end

FarmTab:CreateSection({ Name = "Teleports & Boss" })

FarmTab:CreateButton({
    Name = "Teleport to The Cradle",
    Callback = function()
        SafeTeleportTo(CFrame.new(416.25, -857, -310.75))
        NotifyUser("NW Hub | Boss", "Teleported to The Cradle!", 2.5)
    end
})

FarmTab:CreateButton({
    Name = "Teleport to Surface (Lobby)",
    Callback = function()
        SafeTeleportTo(CFrame.new(431.7, 37.5, 270.1))
        NotifyUser("NW Hub | Teleport", "Teleported to Surface!", 2.5)
    end
})

FarmTab:CreateButton({
    Name = "Manual Summon Boss",
    Callback = function()
        if Remotes then
            local rel = Remotes:FindFirstChild("CradleRelease")
            if rel then pcall(function() rel:FireServer() end) end
            local cry = Remotes:FindFirstChild("CellOfLifeCrystalInteraction")
            if cry then pcall(function() cry:FireServer("SummonBoss") end) end
            NotifyUser("NW Hub | Boss", "Summon signal sent to The Cradle.", 3)
        end
    end
})

FarmTab:CreateSection({ Name = "Trinkets" })

FarmTab:CreateButton({
    Name = "Collect Trinkets",
    PremiumOnly = true,
    Callback = function()
        task.spawn(CollectAllMapTrinkets)
    end
})

FarmTab:CreateToggle({
    Name = "Trinket Farm",
    PremiumOnly = true,
    CurrentValue = State.TrinketFarm,
    Callback = function(v)
        State.TrinketFarm = v
        if not v then
            IsCollectingTrinkets = false
            AbortCurrentTeleport = true
            IsTeleporting = false
            UpdateFarmHover(false)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    for _, child in ipairs(root:GetChildren()) do
                        if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition") then
                            if child.Name:find("Hover") or child.Name:find("vel") or child.Name:find("gyro") or child.Name:find("Veil") then
                                child:Destroy()
                            end
                        end
                    end
                end)
            end
            if char and not (State.Noclip or State.Fly or State.MobFarm or State.PlayerFarm) then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.CanCollide = true
                    end
                end
            end
            NotifyUser("NW Hub | Trinkets", "Trinket farm stopped. Flight & teleports halted.", 2.5)
        end
    end
})

FarmTab:CreateSlider({
    Name = "Spawn Count",
    Range = {1, 50},
    Increment = 1,
    Suffix = "items",
    CurrentValue = State.TrinketSpawnCount,
    Callback = function(v) State.TrinketSpawnCount = v end
})

FarmTab:CreateToggle({
    Name = "Auto Pickup Nearby",
    CurrentValue = State.AutoPickup,
    Callback = function(v) State.AutoPickup = v end
})

FarmTab:CreateToggle({
    Name = "Filter Loot by Rarity",
    CurrentValue = State.LootFilterEnabled,
    Callback = function(v) State.LootFilterEnabled = v end
})

FarmTab:CreateToggle({
    Name = "Loot Common",
    CurrentValue = State.LootFilterCommon,
    Callback = function(v) State.LootFilterCommon = v end
})

FarmTab:CreateToggle({
    Name = "Loot Uncommon",
    CurrentValue = State.LootFilterUncommon,
    Callback = function(v) State.LootFilterUncommon = v end
})

FarmTab:CreateToggle({
    Name = "Loot Rare",
    CurrentValue = State.LootFilterRare,
    Callback = function(v) State.LootFilterRare = v end
})

FarmTab:CreateToggle({
    Name = "Loot Epic",
    CurrentValue = State.LootFilterEpic,
    Callback = function(v) State.LootFilterEpic = v end
})

FarmTab:CreateToggle({
    Name = "Loot Legendary",
    CurrentValue = State.LootFilterLegendary,
    Callback = function(v) State.LootFilterLegendary = v end
})

FarmTab:CreateToggle({
    Name = "Loot Mythic",
    CurrentValue = State.LootFilterMythic,
    Callback = function(v) State.LootFilterMythic = v end
})

FarmTab:CreateButton({
    Name = "Sell All Trinkets",
    PremiumOnly = true,
    Callback = function() ExecuteAutoSell() end
})

FarmTab:CreateButton({
    Name = "Trash All Junk",
    PremiumOnly = true,
    Callback = function() TrashAllJunk() end
})

FarmTab:CreateToggle({
    Name = "Auto Sell Loop",
    PremiumOnly = true,
    CurrentValue = State.AutoSellLoop,
    Callback = function(v) State.AutoSellLoop = v end
})

FarmTab:CreateToggle({
    Name = "Auto Open Chests",
    CurrentValue = State.AutoOpenChests,
    Callback = function(v)
        State.AutoOpenChests = v
        if v then
            UpdateChestCache()
            NotifyUser("NW Hub | Chests", string.format("Cached %d chests.", #CachedChests), 3)
        end
    end
})

FarmTab:CreateToggle({
    Name = "Close Dialogue",
    CurrentValue = State.CloseDialogue,
    Callback = function(v) State.CloseDialogue = v end
})

FarmTab:CreateDropdown({
    Name = "NPC",
    Flag = "Trinket_ShopNPC",
    Options = GetNpcList(),
    CurrentOption = State.SelectedShopNPC,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        State.SelectedShopNPC = opt or ""
    end
})

FarmTab:CreateButton({
    Name = "Open Shop",
    Callback = function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local shopGui = pg and pg:FindFirstChild("ShopGui")
        if shopGui then shopGui.Enabled = true end
        local req = Remotes and Remotes:FindFirstChild("RequestShopCatalog")
        if req then pcall(function() req:FireServer() end) end
        NotifyUser("NW Hub | Shop", "Shop interface opened.", 3)
    end
})

FarmTab:CreateButton({
    Name = "Register Interaction",
    Callback = function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local target = nil

        if State.SelectedShopNPC and State.SelectedShopNPC ~= "Select..." and State.SelectedShopNPC ~= "No NPCs found" and State.SelectedShopNPC ~= "" then
            target = (NPCFolder and NPCFolder:FindFirstChild(State.SelectedShopNPC, true)) or workspace:FindFirstChild(State.SelectedShopNPC, true)
        end

        if not target and root then
            local nearestDist = 999999
            local candidates = {}
            if NPCFolder then
                for _, c in ipairs(NPCFolder:GetChildren()) do table.insert(candidates, c) end
            end
            for _, c in ipairs(workspace:GetChildren()) do
                if c:IsA("Model") and not Players:GetPlayerFromCharacter(c) and not IsDummyOrProp(c) then
                    local n = c.Name:lower()
                    if n:find("npc") or n:find("merchant") or n:find("vendor") or n:find("shop") or n:find("wisp") or c:FindFirstChildWhichIsA("ProximityPrompt", true) then
                        table.insert(candidates, c)
                    end
                end
            end
            for _, c in ipairs(candidates) do
                local p = GetEntityRoot(c)
                if p then
                    local d = (root.Position - p.Position).Magnitude
                    if d < nearestDist then
                        nearestDist = d
                        target = c
                    end
                end
            end
        end

        if target then
            local reg = Remotes and (Remotes:FindFirstChild("RegisterNPCInteraction") or Remotes:FindFirstChild("InteractNPC") or Remotes:FindFirstChild("NPCInteraction"))
            if reg then
                pcall(function() reg:FireServer(target) end)
            end
            local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then TriggerPrompt(prompt) end
            NotifyUser("NW Hub | NPC", "Interaction registered for: " .. target.Name, 3)
        else
            NotifyUser("NW Hub | NPC", "No NPC found nearby.", 3)
        end
    end
})

FarmTab:CreateSection({ Name = "Network" })

FarmTab:CreateButton({
    Name = "Show Ownership",
    Callback = function()
        local mobs = GetAllActiveMonsters()
        local owned = 0
        for _, mob in ipairs(mobs) do
            local _, mRoot = GetMobHumanoidAndRoot(mob)
            if mRoot then
                local isO = (isnetworkowner and isnetworkowner(mRoot)) or (mRoot.ReceiveAge == 0)
                if isO then owned = owned + 1 end
            end
        end
        local msg = string.format("Ownership: %d / %d monsters simulated locally", owned, #mobs)
        NotifyUser("NW Hub | Network", msg, 4)
    end
})

-- ================================================
--  TAB 2 : PLAYER
-- ================================================
local PlayerTab = Window:CreateTab({ Name = "PLAYER", Icon = "user" })

PlayerTab:CreateSection({ Name = "Movement" })

PlayerTab:CreateToggle({
    Name = "Fly",
    PremiumOnly = true,
    CurrentValue = State.Fly,
    Callback = function(v)
        State.Fly = v
        ToggleFlight(v)
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "spd",
    CurrentValue = State.FlySpeed,
    Callback = function(v) State.FlySpeed = v end
})

PlayerTab:CreateToggle({
    Name = "Speedhack",
    PremiumOnly = true,
    CurrentValue = State.Speedhack,
    Callback = function(v) State.Speedhack = v end
})

PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {1.0, 10.0},
    Increment = 0.2,
    Suffix = "x",
    CurrentValue = State.SpeedMultiplier,
    Callback = function(v) State.SpeedMultiplier = v end
})

PlayerTab:CreateToggle({
    Name = "Infinite Flash Step (Zero Dash CD)",
    PremiumOnly = true,
    CurrentValue = State.InfDash,
    Callback = function(v)
        State.InfDash = v
        pcall(function()
            local DashMod = require(ReplicatedStorage.Assets.Scripts.DirectionalDash)
            if DashMod then
                if not OriginalDashRoll then
                    OriginalDashRoll = DashMod.Roll
                    DashMod.Roll = function(dashType, bypassStamina)
                        if State.InfDash then
                            pcall(function()
                                debug.setupvalue(OriginalDashRoll, 1, false)
                                debug.setupvalue(OriginalDashRoll, 2, 0)
                                debug.setupvalue(OriginalDashRoll, 4, 0)
                                debug.setupvalue(OriginalDashRoll, 7, 0)
                            end)
                            bypassStamina = true
                        end
                        return OriginalDashRoll(dashType, bypassStamina)
                    end
                end

                if DashMod.Configs then
                    if not OriginalDashConfigs then
                        OriginalDashConfigs = {}
                        for k, cfg in pairs(DashMod.Configs) do
                            OriginalDashConfigs[k] = {
                                time = cfg.time,
                                cooldown = cfg.cooldown,
                                startSpeed = cfg.startSpeed,
                                endSpeed = cfg.endSpeed,
                                airHang = cfg.airHang
                            }
                        end
                    end
                    for k, cfg in pairs(DashMod.Configs) do
                        if v then
                            cfg.time = 0.08
                            cfg.cooldown = 0
                            cfg.airHang = 0
                            if OriginalDashConfigs[k] and OriginalDashConfigs[k].startSpeed then
                                cfg.startSpeed = OriginalDashConfigs[k].startSpeed * 1.5
                            end
                        elseif OriginalDashConfigs and OriginalDashConfigs[k] then
                            cfg.time = OriginalDashConfigs[k].time
                            cfg.cooldown = OriginalDashConfigs[k].cooldown
                            cfg.airHang = OriginalDashConfigs[k].airHang
                            cfg.startSpeed = OriginalDashConfigs[k].startSpeed
                            cfg.endSpeed = OriginalDashConfigs[k].endSpeed
                        end
                    end
                end
            end
        end)
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Double Jump",
    PremiumOnly = true,
    CurrentValue = State.InfiniteDoubleJump,
    Callback = function(v) State.InfiniteDoubleJump = v end
})

PlayerTab:CreateToggle({
    Name = "Infinite Stamina",
    PremiumOnly = true,
    CurrentValue = State.InfiniteStamina,
    Callback = function(v) State.InfiniteStamina = v end
})

PlayerTab:CreateToggle({
    Name = "No Slow",
    PremiumOnly = true,
    CurrentValue = State.NoSlow,
    Callback = function(v) State.NoSlow = v end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = State.InfiniteJump,
    Callback = function(v) State.InfiniteJump = v end
})

PlayerTab:CreateSlider({
    Name = "Jump Height",
    Range = {30, 300},
    Increment = 5,
    Suffix = "jp",
    CurrentValue = State.JumpPowerVal,
    Callback = function(v) State.JumpPowerVal = v end
})

PlayerTab:CreateToggle({
    Name = "Ignore Jump Lock",
    CurrentValue = State.IgnoreJumpLock,
    Callback = function(v) State.IgnoreJumpLock = v end
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    PremiumOnly = true,
    CurrentValue = State.Noclip,
    Callback = function(v) State.Noclip = v end
})

PlayerTab:CreateSection({ Name = "Utility" })

PlayerTab:CreateToggle({
    Name = "No Animations",
    CurrentValue = State.NoAnimations,
    Callback = function(v) State.NoAnimations = v end
})

PlayerTab:CreateSlider({
    Name = "Anim Speed",
    Range = {0.1, 5.0},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = State.AnimationSpeedVal,
    Callback = function(v) State.AnimationSpeedVal = v end
})

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = State.AntiAFK,
    Callback = function(v) State.AntiAFK = v end
})

PlayerTab:CreateButton({
    Name = "Kill Self",
    Callback = function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
})

PlayerTab:CreateSection({ Name = "Defense Assist (Auto Parry / Dodge)" })

UIElements["DefenseAssist"] = PlayerTab:CreateToggle({
    Name = "Defense Assist",
    CurrentValue = State.DefenseAssist,
    Callback = function(v)
        State.DefenseAssist = v
        if v then
            NotifyUser("Defense Assist", "Active! Auto-parrying incoming monster attacks.", 2.5)
        end
    end
})

PlayerTab:CreateDropdown({
    Name = "Defense Action",
    Options = {"Auto Parry (F)", "Auto Dodge (Q)", "Parry + Dodge"},
    CurrentOption = State.DefenseMode,
    Callback = function(opt)
        State.DefenseMode = (type(opt) == "table" and opt[1]) or opt
    end
})

PlayerTab:CreateSlider({
    Name = "Defense Trigger Range",
    Range = {10, 25},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = State.DefenseDistance,
    Callback = function(v) State.DefenseDistance = v end
})

PlayerTab:CreateSlider({
    Name = "Parry Reaction Delay (Timing)",
    Range = {0.0, 1.0},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = State.DefenseDelay,
    Callback = function(v) State.DefenseDelay = v end
})

PlayerTab:CreateSlider({
    Name = "Parry Hold Duration",
    Range = {0.1, 0.8},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = State.DefenseHold,
    Callback = function(v) State.DefenseHold = v end
})

PlayerTab:CreateSection({ Name = "Misc Exploits" })

PlayerTab:CreateToggle({
    Name = "TP Back on Death",
    CurrentValue = State.TPBackOnDeath,
    Callback = function(v) State.TPBackOnDeath = v end
})

PlayerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local placeId = game.PlaceId
        local serversApi = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId)
        local req = (type(request) == "function" and request) or (http and http.request) or http_request
        if req then
            local res = req({ Url = serversApi, Method = "GET" })
            if res and res.Body then
                local data = HttpService:JSONDecode(res.Body)
                if data and data.data then
                    for _, s in ipairs(data.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                            break
                        end
                    end
                end
            end
        end
    end
})

PlayerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

local SelectedFlingPlr = GetPlayerList(false)[1] or ""
PlayerTab:CreateDropdown({
    Name = "Fling Target",
    Options = GetPlayerList(false),
    CurrentOption = SelectedFlingPlr,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        SelectedFlingPlr = opt or ""
    end
})

PlayerTab:CreateButton({
    Name = "Fling Player",
    PremiumOnly = true,
    Callback = function()
        local target = Players:FindFirstChild(SelectedFlingPlr)
        local tChar = target and target.Character
        local tRoot = tChar and GetEntityRoot(tChar)
        local myRoot = LocalPlayer.Character and GetEntityRoot(LocalPlayer.Character)
        if tRoot and myRoot then
            task.spawn(function()
                local oldCF = myRoot.CFrame
                local bAV = Instance.new("BodyAngularVelocity")
                bAV.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
                bAV.AngularVelocity = Vector3.new(99999, 99999, 99999)
                bAV.Parent = myRoot
                for i = 1, 35 do
                    myRoot.CFrame = tRoot.CFrame
                    task.wait(0.03)
                end
                bAV:Destroy()
                myRoot.CFrame = oldCF
            end)
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = State.AntiFling,
    Callback = function(v) State.AntiFling = v end
})

-- ================================================
--  TAB 3 : ESP
-- ================================================
local EspTab = Window:CreateTab({ Name = "ESP", Icon = "eye" })

EspTab:CreateSection({ Name = "Players" })

EspTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = State.PlayerESP,
    Callback = function(v)
        State.PlayerESP = v
        if not v then for m, esp in pairs(ActiveESP) do if esp.IsPlayer then RemoveESP(m) end end end
    end
})

EspTab:CreateToggle({
    Name = "Local Player ESP",
    CurrentValue = State.LocalPlayerESP,
    Callback = function(v)
        State.LocalPlayerESP = v
        if not v and LocalPlayer.Character then RemoveESP(LocalPlayer.Character) end
    end
})

EspTab:CreateToggle({
    Name = "ESP Single Player",
    CurrentValue = State.ESPSinglePlayer,
    Callback = function(v) State.ESPSinglePlayer = v end
})

EspTab:CreateToggle({
    Name = "ESP Nearest Only",
    CurrentValue = State.ESPNearestOnly,
    Callback = function(v) State.ESPNearestOnly = v end
})

EspTab:CreateSection({ Name = "Mobs" })

EspTab:CreateColorPicker({
    Name = "Mob ESP Color",
    Color = State.MobESPColor,
    Callback = function(v) State.MobESPColor = v end
})

EspTab:CreateToggle({
    Name = "Mob ESP",
    CurrentValue = State.MobESP,
    Callback = function(v)
        State.MobESP = v
        if not v then for m, esp in pairs(ActiveESP) do if not esp.IsPlayer and not esp.IsLocal then RemoveESP(m) end end end
    end
})

EspTab:CreateSection({ Name = "NPCs" })

EspTab:CreateColorPicker({
    Name = "NPC ESP Color",
    Color = State.NpcESPColor,
    Callback = function(v) State.NpcESPColor = v end
})

EspTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = State.NpcESP,
    Callback = function(v)
        State.NpcESP = v
        if not v then for n, _ in pairs(NpcESP) do RemoveNpcESP(n) end end
    end
})

EspTab:CreateSection({ Name = "Loot & Trinkets" })

EspTab:CreateToggle({
    Name = "Drop ESP",
    Flag = "ESP_DropESP",
    CurrentValue = State.DropESP,
    Callback = function(v)
        State.DropESP = v
        if not v then
            for d, _ in pairs(LootESP) do RemoveDropESP(d) end
        else
            task.spawn(ScanWorldESP)
        end
    end
})

EspTab:CreateToggle({
    Name = "Trinket ESP",
    Flag = "ESP_TrinketESP",
    CurrentValue = State.TrinketESP,
    Callback = function(v)
        State.TrinketESP = v
        if not v then
            for t, _ in pairs(TrinketESP) do RemoveTrinketESP(t) end
        else
            task.spawn(ScanWorldESP)
        end
    end
})

EspTab:CreateToggle({
    Name = "Chest ESP",
    Flag = "ESP_ChestESP",
    CurrentValue = State.ChestESP,
    Callback = function(v)
        State.ChestESP = v
        if not v then
            for c, _ in pairs(ChestESP) do RemoveChestESP(c) end
        else
            UpdateChestCache(true)
            task.spawn(ScanWorldESP)
        end
    end
})

EspTab:CreateColorPicker({
    Name = "Chest ESP Color",
    Color = State.ChestESPColor,
    Callback = function(v)
        State.ChestESPColor = v
        for _, esp in pairs(ChestESP) do
            if esp.Highlight then esp.Highlight.FillColor = v end
            if esp.Label then esp.Label.TextColor3 = v end
            esp.LastColor = v
        end
    end
})

EspTab:CreateToggle({
    Name = "Item Highlights",
    Flag = "ESP_ItemHighlights",
    CurrentValue = State.ItemHighlights,
    Callback = function(v)
        State.ItemHighlights = v
        for _, esp in pairs(LootESP) do
            if esp.Highlight then esp.Highlight.Enabled = v end
        end
        for _, esp in pairs(TrinketESP) do
            if esp.Highlight then esp.Highlight.Enabled = v end
        end
        for _, esp in pairs(ChestESP) do
            if esp.Highlight then esp.Highlight.Enabled = v end
        end
    end
})

EspTab:CreateToggle({
    Name = "Proximity Rarity Highlight",
    Flag = "ESP_ProximityRarityHighlight",
    CurrentValue = State.ItemProximityHighlight,
    Callback = function(v) State.ItemProximityHighlight = v end
})

EspTab:CreateSlider({
    Name = "Item Highlight Transparency",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = State.ItemHighlightTrans,
    Callback = function(v)
        State.ItemHighlightTrans = v
        for _, esp in pairs(LootESP) do
            if esp.Highlight then esp.Highlight.FillTransparency = v end
        end
        for _, esp in pairs(TrinketESP) do
            if esp.Highlight then esp.Highlight.FillTransparency = v end
        end
        for _, esp in pairs(ChestESP) do
            if esp.Highlight then esp.Highlight.FillTransparency = v end
        end
    end
})

EspTab:CreateSection({ Name = "Rarity Colors" })

EspTab:CreateColorPicker({ Name = "Common Color", Color = State.RarityColorCommon, Callback = function(v) State.RarityColorCommon = v end })
EspTab:CreateColorPicker({ Name = "Uncommon Color", Color = State.RarityColorUncommon, Callback = function(v) State.RarityColorUncommon = v end })
EspTab:CreateColorPicker({ Name = "Rare Color", Color = State.RarityColorRare, Callback = function(v) State.RarityColorRare = v end })
EspTab:CreateColorPicker({ Name = "Epic Color", Color = State.RarityColorEpic, Callback = function(v) State.RarityColorEpic = v end })
EspTab:CreateColorPicker({ Name = "Legendary Color", Color = State.RarityColorLegendary, Callback = function(v) State.RarityColorLegendary = v end })
EspTab:CreateColorPicker({ Name = "Mythic Color", Color = State.RarityColorMythic, Callback = function(v) State.RarityColorMythic = v end })

EspTab:CreateSection({ Name = "Config" })

EspTab:CreateToggle({ Name = "Boxes", CurrentValue = State.ESPBoxes, Callback = function(v) State.ESPBoxes = v end })
EspTab:CreateToggle({ Name = "Box Glow", CurrentValue = State.BoxGlow, Callback = function(v) State.BoxGlow = v end })
EspTab:CreateToggle({ Name = "Chams", CurrentValue = State.Chams, Callback = function(v) State.Chams = v end })
EspTab:CreateToggle({ Name = "Name", CurrentValue = State.Names, Callback = function(v) State.Names = v end })
EspTab:CreateToggle({ Name = "Distance", Flag = "ESP_DisplayDistance", CurrentValue = State.Distance, Callback = function(v) State.Distance = v end })
EspTab:CreateToggle({ Name = "Health Bar", CurrentValue = State.HealthBars, Callback = function(v) State.HealthBars = v end })
EspTab:CreateToggle({ Name = "Weapon", CurrentValue = State.Weapons, Callback = function(v) State.Weapons = v end })

EspTab:CreateSlider({
    Name = "Max Distance",
    Range = {50, 5000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = State.MaxESPDistance,
    Callback = function(v) State.MaxESPDistance = v end
})

EspTab:CreateDropdown({
    Name = "Box Type",
    Options = {"2D", "3D", "Corner"},
    CurrentOption = State.BoxType,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        State.BoxType = opt or "2D"
        State.Boxes3D = (opt == "3D")
    end
})

EspTab:CreateSlider({ Name = "Glow Top Trans", Range = {0, 1}, Increment = 0.05, CurrentValue = State.GlowTopTrans, Callback = function(v) State.GlowTopTrans = v end })
EspTab:CreateSlider({ Name = "Glow Bot Trans", Range = {0, 1}, Increment = 0.05, CurrentValue = State.GlowBotTrans, Callback = function(v) State.GlowBotTrans = v end })
EspTab:CreateSlider({
    Name = "Chams Fill Trans",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = State.ChamsFillTrans,
    Callback = function(v)
        State.ChamsFillTrans = v
        State.ChamsTransparency = v
    end
})
EspTab:CreateColorPicker({ Name = "Chams Color", Color = State.ChamsColor, Callback = function(v) State.ChamsColor = v end })
EspTab:CreateColorPicker({ Name = "Box Top Color", Color = State.BoxTopColor, Callback = function(v) State.BoxTopColor = v end })
EspTab:CreateColorPicker({ Name = "Box Bottom Color", Color = State.BoxBottomColor, Callback = function(v) State.BoxBottomColor = v end })

-- ================================================
--  TAB 4 : WORLD
-- ================================================
local WorldTab = Window:CreateTab({ Name = "WORLD", Icon = "globe" })

WorldTab:CreateSection({ Name = "Camera" })

local SpectateTarget = GetPlayerList(false)[1] or ""
WorldTab:CreateDropdown({
    Name = "Spectate Player Target",
    Options = GetPlayerList(false),
    CurrentOption = SpectateTarget,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        SpectateTarget = opt or ""
    end
})

WorldTab:CreateToggle({
    Name = "Spectate Player",
    CurrentValue = State.Spectating,
    Callback = function(v)
        State.Spectating = v
        if v then
            local target = Players:FindFirstChild(SpectateTarget)
            local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum end
        else
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then Camera.CameraSubject = myHum end
        end
    end
})

WorldTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = State.NoFog,
    Callback = function(v)
        State.NoFog = v
        ApplyWorldLighting(true)
    end
})

WorldTab:CreateToggle({
    Name = "No Atmosphere",
    CurrentValue = State.NoAtmosphere,
    Callback = function(v)
        State.NoAtmosphere = v
        ApplyWorldLighting(true)
    end
})

WorldTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = State.FullBright,
    Callback = function(v)
        State.FullBright = v
        ApplyWorldLighting(true)
    end
})

WorldTab:CreateSlider({
    Name = "Brightness",
    Range = {0.5, 10.0},
    Increment = 0.5,
    CurrentValue = State.BrightnessVal,
    Callback = function(v)
        State.BrightnessVal = v
        if State.FullBright then ApplyWorldLighting(true) end
    end
})

WorldTab:CreateToggle({
    Name = "World Ambient",
    CurrentValue = State.WorldAmbient,
    Callback = function(v)
        State.WorldAmbient = v
        ApplyWorldLighting(true)
    end
})
WorldTab:CreateColorPicker({
    Name = "Ambient Color",
    Color = State.WorldAmbientColor,
    Callback = function(v)
        State.WorldAmbientColor = v
        if State.WorldAmbient or State.FullBright then ApplyWorldLighting(true) end
    end
})

WorldTab:CreateToggle({
    Name = "Free Cam",
    CurrentValue = State.FreeCam,
    Callback = function(v)
        State.FreeCam = v
        if v then
            Camera.CameraType = Enum.CameraType.Scriptable
        else
            Camera.CameraType = Enum.CameraType.Custom
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then Camera.CameraSubject = myHum end
        end
    end
})

WorldTab:CreateSlider({ Name = "Free Cam Sensitivity", Range = {1, 10}, Increment = 1, CurrentValue = State.FreeCamSensitivity, Callback = function(v) State.FreeCamSensitivity = v end })
WorldTab:CreateSlider({ Name = "Free Cam Speed", Range = {10, 200}, Increment = 5, Suffix = "spd", CurrentValue = State.FreeCamSpeed, Callback = function(v) State.FreeCamSpeed = v end })

WorldTab:CreateSection({ Name = "Effects" })

WorldTab:CreateToggle({ Name = "3rd Person Lock", CurrentValue = State.ThirdPersonLock, Callback = function(v) State.ThirdPersonLock = v end })
WorldTab:CreateToggle({
    Name = "Custom FOV",
    CurrentValue = State.CustomFOV,
    Callback = function(v)
        State.CustomFOV = v
        if not v and Camera then
            Camera.FieldOfView = 70
        elseif v and Camera then
            Camera.FieldOfView = State.FOVOverride
        end
    end
})
WorldTab:CreateSlider({
    Name = "FOV Override",
    Range = {60, 120},
    Increment = 1,
    Suffix = "fov",
    CurrentValue = State.FOVOverride,
    Callback = function(v)
        State.FOVOverride = v
        if State.CustomFOV and Camera then Camera.FieldOfView = v end
    end
})

WorldTab:CreateToggle({ Name = "Crosshair", CurrentValue = State.Crosshair, Callback = function(v) State.Crosshair = v; pcall(UpdateCrosshairUI) end })
WorldTab:CreateToggle({ Name = "Cursor Ring", CurrentValue = State.CursorRing, Callback = function(v) State.CursorRing = v; pcall(UpdateCrosshairUI) end })

WorldTab:CreateSection({ Name = "Performance" })

WorldTab:CreateButton({
    Name = "Anti-Lag",
    Callback = function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
        NotifyUser("NW Hub | Performance", "Anti-Lag optimizations applied.", 3)
    end
})

WorldTab:CreateSlider({
    Name = "FPS Cap",
    Range = {30, 240},
    Increment = 10,
    Suffix = "fps",
    CurrentValue = State.FPSCapVal,
    Callback = function(v)
        State.FPSCapVal = v
        if setfpscap then setfpscap(v) end
    end
})

WorldTab:CreateToggle({
    Name = "Boost FPS",
    CurrentValue = State.FPSBoost,
    Callback = function(v)
        State.FPSBoost = v
        pcall(function() settings().Rendering.QualityLevel = v and 1 or 7 end)
    end
})

WorldTab:CreateSection({ Name = "Teleport" })

WorldTab:CreateButton({
    Name = "Copy Coordinates",
    Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and setclipboard then
            local pos = root.Position
            setclipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
            NotifyUser("NW Hub | Teleport", "Coordinates copied to clipboard!", 2.5)
        end
    end
})

WorldTab:CreateToggle({ Name = "Nearby Alert", CurrentValue = State.NearbyAlert, Callback = function(v) State.NearbyAlert = v end })
WorldTab:CreateSlider({ Name = "Alert Range", Range = {10, 500}, Increment = 10, Suffix = "studs", CurrentValue = State.AlertRange, Callback = function(v) State.AlertRange = v end })
WorldTab:CreateToggle({ Name = "Kick Nearby", CurrentValue = State.KickNearby, Callback = function(v) State.KickNearby = v end })
WorldTab:CreateSlider({ Name = "Kick Range", Range = {10, 100}, Increment = 5, Suffix = "studs", CurrentValue = State.KickRange, Callback = function(v) State.KickRange = v end })

local CoordInput = "0, 0, 0"
WorldTab:CreateInput({
    Name = "Coordinates",
    PlaceholderText = "X, Y, Z",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt) CoordInput = txt end
})

WorldTab:CreateButton({
    Name = "Tween To",
    Callback = function()
        local nums = {}
        for n in string.gmatch(CoordInput, "[-?%d%.]+") do
            table.insert(nums, tonumber(n))
        end
        if #nums >= 3 then
            SafeTeleportTo(CFrame.new(nums[1], nums[2], nums[3]))
        else
            NotifyUser("NW Hub | Teleport", "Invalid format. Expected X, Y, Z", 3)
        end
    end
})

WorldTab:CreateButton({
    Name = "Copy Position",
    Callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and setclipboard then
            setclipboard(tostring(root.CFrame))
            NotifyUser("NW Hub | Teleport", "CFrame position copied.", 2.5)
        end
    end
})

WorldTab:CreateToggle({ Name = "Click TP", CurrentValue = State.ClickTP, Callback = function(v) State.ClickTP = v end })

WorldTab:CreateSection({ Name = "TP NPCs" })

local SelectedNPCTp = GetNpcList()[1] or ""
local NPCTpDropdown = WorldTab:CreateDropdown({
    Name = "NPC",
    Flag = "TP_TargetNPC",
    Options = GetNpcList(),
    CurrentOption = SelectedNPCTp,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        SelectedNPCTp = opt or ""
    end
})

WorldTab:CreateButton({
    Name = "Refresh",
    Callback = function()
        local list = GetNpcList()
        pcall(function() NPCTpDropdown:Refresh(list, true) end)
    end
})

WorldTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not SelectedNPCTp or SelectedNPCTp == "No NPCs found" then return end
        local target = (NPCFolder and NPCFolder:FindFirstChild(SelectedNPCTp, true))
            or (AreasFolder and AreasFolder:FindFirstChild(SelectedNPCTp, true))
            or workspace:FindFirstChild(SelectedNPCTp, true)
        local tRoot = target and GetEntityRoot(target)
        if tRoot then
            SafeTeleportTo(tRoot.CFrame + Vector3.new(3, 0, 0))
        elseif CachedNPCPositions[SelectedNPCTp] then
            SafeTeleportTo(CachedNPCPositions[SelectedNPCTp] + Vector3.new(3, 0, 0))
        end
    end
})

WorldTab:CreateSection({ Name = "TP Areas" })

local SelectedArea = GetAreaList()[1] or "Spawn"
WorldTab:CreateDropdown({
    Name = "Area",
    Options = GetAreaList(),
    CurrentOption = SelectedArea,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        SelectedArea = opt or "Spawn"
    end
})

WorldTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if AreasFolder then
            local a = AreasFolder:FindFirstChild(SelectedArea)
            local p = a and (a:FindFirstChildWhichIsA("BasePart") or (a:IsA("BasePart") and a) or (a:IsA("Model") and a.PrimaryPart))
            if p then SafeTeleportTo(p.CFrame + Vector3.new(0, 3, 0)) end
        end
    end
})

local function GetWaypointList()
    local list = {}
    for k, _ in pairs(SavedWaypoints) do table.insert(list, k) end
    if #list == 0 then table.insert(list, "No Waypoints") end
    return list
end

local SelectedWaypoint = "The Glade"
WorldTab:CreateDropdown({
    Name = "Waypoint",
    Options = GetWaypointList(),
    CurrentOption = SelectedWaypoint,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        SelectedWaypoint = opt or "The Glade"
    end
})

WorldTab:CreateButton({
    Name = "Teleport via Waypoint",
    Callback = function()
        local key = SavedWaypoints[SelectedWaypoint]
        if key then
            local tpRemote = TeleportWaypointRemote or (Remotes and Remotes:FindFirstChild("TeleportToWaypoint"))
            if tpRemote then
                pcall(function() tpRemote:FireServer(key) end)
            end
            if AreasFolder then
                local a = AreasFolder:FindFirstChild(key) or AreasFolder:FindFirstChild(SelectedWaypoint)
                if a then
                    local p = a:FindFirstChildWhichIsA("BasePart") or (a:IsA("BasePart") and a) or (a:IsA("Model") and a.PrimaryPart)
                    if p then SafeTeleportTo(p.CFrame + Vector3.new(0, 3, 0)) end
                end
            end
            NotifyUser("NW Hub | Waypoints", "Teleporting to " .. SelectedWaypoint, 2.5)
        else
            NotifyUser("NW Hub | Waypoints", "Waypoint not found.", 2.5)
        end
    end
})

WorldTab:CreateSection({ Name = "Attach" })

local AttachPlr = GetPlayerList(false)[1] or ""
WorldTab:CreateDropdown({
    Name = "Attach Target",
    Options = GetPlayerList(false),
    CurrentOption = AttachPlr,
    Callback = function(opt)
        if typeof(opt) == "table" then opt = opt[1] end
        AttachPlr = opt or ""
        State.AttachTarget = AttachPlr
    end
})

WorldTab:CreateToggle({
    Name = "Attach Player",
    CurrentValue = State.PlayerAttach,
    Callback = function(v)
        State.PlayerAttach = v
        State.AttachTarget = AttachPlr
    end
})

WorldTab:CreateSlider({ Name = "Range", Flag = "Attach_DetectionRange", Range = {1, 50}, Increment = 1, Suffix = "studs", CurrentValue = State.AttachRange, Callback = function(v) State.AttachRange = v end })
WorldTab:CreateSlider({ Name = "Distance", Flag = "Attach_FollowDistance", Range = {1, 50}, Increment = 1, Suffix = "studs", CurrentValue = State.AttachDist, Callback = function(v) State.AttachDist = v end })
WorldTab:CreateSlider({ Name = "Height", Range = {-20, 20}, Increment = 1, Suffix = "studs", CurrentValue = State.AttachHeight, Callback = function(v) State.AttachHeight = v end })

WorldTab:CreateSection({ Name = "Rewards & Codes" })

WorldTab:CreateButton({
    Name = "Claim Daily Reward",
    Callback = function()
        if Remotes and Remotes:FindFirstChild("ClaimDailyReward") then
            pcall(function() Remotes.ClaimDailyReward:FireServer() end)
            NotifyUser("NW Hub | Rewards", "Daily reward claim sent!", 3)
        end
    end
})

WorldTab:CreateButton({
    Name = "Redeem All Active Codes",
    Callback = function()
        local codes = {"LASTONE", "EMERGENCY", "UPDATEFINALLY", "SORRY4SHUTDOWN", "VERITYBOMB", "RELEASE"}
        local redeem = Remotes and Remotes:FindFirstChild("RedeemCode")
        if redeem then
            task.spawn(function()
                for _, c in ipairs(codes) do
                    pcall(function() redeem:FireServer(c) end)
                    task.wait(0.25)
                end
                NotifyUser("NW Hub | Codes", "All active codes redeemed successfully!", 3.5)
            end)
        end
    end
})

-- ================================================
--  TAB 5 : SETTINGS
-- ================================================
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "settings" })

SettingsTab:CreateSection({ Name = "Keybinds" })

SettingsTab:CreateButton({
    Name = "Toggle Menu",
    Callback = function()
        pcall(function()
            if Window and Window.Toggle then Window:Toggle() end
        end)
    end
})


local function RealUnload()
    if getgenv().Veil_Unloaded then return end
    getgenv().Veil_Unloaded = true
    UD_Active = false

    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    table.clear(Connections)
    table.clear(PickedUpDrops)

    for m, _ in pairs(ActiveESP) do RemoveESP(m) end
    for d, _ in pairs(LootESP) do RemoveDropESP(d) end
    for n, _ in pairs(NpcESP) do RemoveNpcESP(n) end
    for t, _ in pairs(TrinketESP) do RemoveTrinketESP(t) end
    for c, _ in pairs(ChestESP) do RemoveChestESP(c) end
    table.clear(ActiveESP)
    table.clear(LootESP)
    table.clear(NpcESP)
    table.clear(TrinketESP)
    table.clear(ChestESP)

    ToggleFlight(false)

    if CrosshairGui then
        pcall(function() CrosshairGui:Destroy() end)
        CrosshairGui = nil
    end

    pcall(function()
        Lighting.Brightness    = OriginalLighting.Brightness
        Lighting.ClockTime     = OriginalLighting.ClockTime
        Lighting.FogEnd        = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient       = OriginalLighting.Ambient
    end)

    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    pcall(function() if Window and Window.Unload then Window:Unload() end end)
    pcall(function() if Rayfield and Rayfield.Destroy then Rayfield:Destroy() end end)
    pcall(function() if EspScreenGui then EspScreenGui:Destroy() end end)

    PurgeAllResidues()

    getgenv().Veil_State = nil
    getgenv().Veil_UnloadFunction = nil
    getgenv().__VEIL_HOOKED = nil

    print("[NW Hub] The Veil Unloaded Cleanly.")
end

getgenv().Veil_UnloadFunction = RealUnload
pcall(function() Vesper.OnUnload = RealUnload end)

SettingsTab:CreateButton({
    Name = "Unload NW Hub",
    Callback = RealUnload
})

if Rayfield and Rayfield.Notify then
    Rayfield:Notify({
        Title = "The Veil - PREMIUM",
        Content = "Loaded Successfully.",
        Duration = 5
    })
end

print("[NW Hub] The Veil - Premium v5.0.1 (FIXED) loaded successfully.")
print("[NW Hub] Fixes: Fly anti-cheat bypass, SilentAim crash, Full-map trinket farm, CreateInput method, ToggleFlight cleanup.")
-- END OF SCRIPT
