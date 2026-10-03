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

-- Certains executeurs (ex: Real) exposent firesignal/Connection:Fire mais ce
-- sont des no-ops silencieux : l'appel reussit sans rien declencher. On le
-- detecte une fois au chargement (bouton test reel) pour ne jamais compter
-- sur un faux succes (skills, dialogues, click detectors).
-- (Globals volontaires : le chunk principal est au plafond des 200 locals Luau.)
function NW_DetectBrokenFiresignal()
    if type(firesignal) ~= "function" then return true end
    local ok, broken = pcall(function()
        local parentGui = nil
        pcall(function()
            if type(gethui) == "function" then parentGui = gethui() end
        end)
        if not parentGui then
            pcall(function() parentGui = game:GetService("CoreGui") end)
        end
        local screen = Instance.new("ScreenGui")
        screen.Name = "NWFireTest"
        screen.ResetOnSpawn = false
        if parentGui then pcall(function() screen.Parent = parentGui end) end
        local btn = Instance.new("TextButton")
        btn.Parent = screen
        local hit = false
        btn.MouseButton1Click:Connect(function() hit = true end)
        pcall(function() firesignal(btn.MouseButton1Click) end)
        task.wait()
        local res = not hit
        pcall(function() screen:Destroy() end)
        return res
    end)
    if not ok then return false end
    return broken
end
NW_NoFiresignal = NW_DetectBrokenFiresignal()

--[[
    ╔══════════════════════════════════════════════════════════════════════════╗
    ║                       KYŌKA UI · SLAYERS 2 HUB                          ║
    ║        Exact Game Engine Integrations (Workspace.Humanoids.Regions)     ║
    ║   Auto Farm (Anti-Void Float Platform + VirtualInput Combat Attack)     ║
    ╚══════════════════════════════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Cleanup ancienne instance
if _G.SlayersKyokaHub then
    pcall(function() _G.SlayersKyokaHub:Destroy() end)
    _G.SlayersKyokaHub = nil
end

pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local lp = game:GetService("Players").LocalPlayer
    local function clean(p)
        if not p then return end
        for _, c in ipairs(p:GetChildren()) do
            if c:IsA("ScreenGui") and (c.Name:find("Vesper") or c.Name:find("Kyoka")) then
                pcall(function() c:Destroy() end)
            end
        end
    end
    clean(CoreGui)
    if CoreGui:FindFirstChild("RobloxGui") then clean(CoreGui.RobloxGui) end
    if lp and lp:FindFirstChild("PlayerGui") then clean(lp.PlayerGui) end
end)


--=====================================================================
-- Librairie Kyōka UI (Embarquée Directement — Zero Dépendance Externe)
--=====================================================================
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
	Blur        = true,
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

-- Certains executors bloquent Instance.new quand le code tourne dans le thread
-- d'un callback de signal ("The current thread cannot access 'Instance' (lacking
-- capability Plugin)"). On retente donc avec une identité élevée, puis on clone
-- un modèle pré-créé au chargement (les méthodes d'instance ne sont pas
-- restreintes, contrairement à la librairie Instance).
local NewTemplates = {}
local NewRestrictedWarned = false

local function RawInstanceNew(class)
	local ok, inst = pcall(Instance.new, class)
	if ok and inst then return inst end
	if setthreadidentity then
		local old = (getthreadidentity and getthreadidentity()) or 8
		local created
		pcall(function()
			setthreadidentity(8)
			created = Instance.new(class)
		end)
		pcall(function() setthreadidentity(old) end)
		if created then return created end
	end
	if not NewRestrictedWarned then
		NewRestrictedWarned = true
		warn("[Kyoka] Instance.new blocked in this thread; using template fallback for runtime UI.")
	end
	return nil
end

-- Pré-création de modèles pour les classes utilisées au runtime (callbacks,
-- notifications, ESP) afin de pouvoir les cloner sans Instance.new.
task.defer(function()
	for _, class in ipairs({ "Frame", "TextLabel", "TextButton", "UIStroke", "UICorner", "UIPadding", "UIListLayout", "UIGradient", "UIScale", "Highlight", "BillboardGui", "NumberValue", "StringValue", "Part" }) do
		local ok, inst = pcall(Instance.new, class)
		if ok and inst then NewTemplates[class] = inst end
	end
end)

local function New(class, props, children)
	local inst = RawInstanceNew(class)
	if not inst then
		local template = NewTemplates[class]
		if template then
			pcall(function() inst = template:Clone() end)
		end
	end
	if not inst then
		-- Dernier recours : objet factice non parenté pour ne pas casser l'appelant
		local ok, dummy = pcall(Instance.new, "Folder")
		if not ok then return nil end
		inst = dummy
	end
	local parent = (type(props) == "table" and props.Parent) or nil
	if type(props) == "table" then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				pcall(function() inst[k] = v end)
			end
		end
	end
	if type(children) == "table" then
		for _, child in ipairs(children) do
			if child then child.Parent = inst end
		end
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
	if Library.Mobile then return 2.4 end
	-- Fenêtre ≈ 72 % de la hauteur d'écran, avec un plancher élevé pour que
	-- les infos restent lisibles même sur petit écran (1080p ≈ x1.45).
	local h = ViewportSize().Y
	local base = 540
	local f = math.max(h * 0.72 / base, math.min(1.2, (h - 30) / base))
	return math.clamp(Round(f * 2, 1), 2.3, 4)
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
	if not Library.Blur then on = false end
	Tween(DimFx, 0.45, { BackgroundTransparency = on and 0.62 or 1 })
	for _, v in ipairs(DimVignette) do
		Tween(v, 0.45, { BackgroundTransparency = on and 0.62 or 1 })
	end
	if on and not (BlurFx and BlurFx.Parent) then
		local cam = workspace.CurrentCamera
		if cam then
			BlurFx = New("BlurEffect", { Name = "KyokaBlur", Size = 0, Parent = cam })
		end
	end
	if BlurFx and BlurFx.Parent then
		Tween(BlurFx, 0.45, { Size = on and 14 or 0 })
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
			Library:Notify({
				Title = text,
				Content = opts.LockedText or "Premium only. Get a key to unlock it.",
				Duration = 3,
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
		local w = opts.Size and opts.Size.X.Offset or 860
		local h = opts.Size and opts.Size.Y.Offset or 560
		size = UDim2.fromOffset(math.max(w, 720), math.max(h, 470))
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

	Library:Connect(UserInputService.InputBegan, function(input, processed)
		if processed then return end
		if input.KeyCode == Library.ToggleKey then
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

local function NotifyImpl(self, opts)
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

-- Enveloppe sûre : une notification ne doit JAMAIS faire planter l'appelant
-- (ex: erreur "lacking capability Plugin" sur certains executors).
function Library:Notify(opts)
	local ok = pcall(NotifyImpl, self, opts)
	if ok then return end
	task.spawn(function()
		if setthreadidentity then pcall(setthreadidentity, 8) end
		local ok2 = pcall(NotifyImpl, self, opts)
		if not ok2 then
			local title, content
			if type(opts) == "table" then
				title = opts.Title or ""
				content = opts.Content or ""
			else
				title = ""
				content = tostring(opts)
			end
			warn(string.format("[Kyoka]%s %s", title ~= "" and (" " .. title .. " -") or "", content))
		end
	end)
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
	Library:Connect(RunService.RenderStepped, function(dt)
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

--=====================================================================
-- Liste des raccourcis actifs
--=====================================================================

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

--=====================================================================
-- Curseur dessiné (beaucoup de jeux cachent l'icône système)
--=====================================================================

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

if not Kyoka then
    warn("[Kyoka Hub] Error: Failed to initialize Kyōka UI")
    return
end

--=====================================================================
local Hub
local SignalFunction
pcall(function()
    SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
    if SignalFunction and type(SignalFunction.ToServer) == "function" and not SignalFunction._kyokaHooked then
        local rawToServer = SignalFunction.ToServer
        SignalFunction.ToServer = function(signalName, ...)
            if signalName == "SunDamage" and Hub and Hub.Combat and Hub.Combat.NoSunDamage then
                local isBurning = select(1, ...)
                if isBurning == true then
                    return rawToServer(signalName, false)
                end
            end
            return rawToServer(signalName, ...)
        end
        SignalFunction._kyokaHooked = true
    end
end)

local SignalEvent
pcall(function()
    SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
end)

local Clans
pcall(function()
    Clans = require(ReplicatedStorage.CAM.Clans)
end)

local function GetPlayerDataFolder()
    local ps = ReplicatedStorage:FindFirstChild("Player_Service")
    local data = ps and ps:FindFirstChild("Data")
    local myData = data and data:FindFirstChild(LocalPlayer.Name)
    if not myData then return nil end
    local slotEquipped = myData:FindFirstChild("slotEquipped")
    local slotNum = slotEquipped and tostring(slotEquipped.Value) or "1"
    local slots = myData:FindFirstChild("slots")
    if slots then
        return slots:FindFirstChild("Slot" .. slotNum) or slots:FindFirstChild(slotNum) or slots:GetChildren()[1]
    end
    return myData
end

local function GetCurrentClan()
    local data = GetPlayerDataFolder()
    local c = data and data:FindFirstChild("Clan")
    return c and c.Value or "None"
end

local function GetTotalSpins()
    local data = GetPlayerDataFolder()
    local spinning = data and data:FindFirstChild("Spinning")
    if not spinning then return 0 end
    local free = spinning:FindFirstChild("FreeClanSpins") and spinning.FreeClanSpins.Value or 0
    local normal = spinning:FindFirstChild("Spins") and spinning.Spins.Value or 0
    return free + normal
end

local function GetCurrentBDA()
    local data = GetPlayerDataFolder()
    local powers = data and data:FindFirstChild("Powers")
    local da = powers and powers:FindFirstChild("DemonArt")
    local val = da and da.Value
    return (val and val ~= "") and tostring(val) or "None"
end

local function GetTotalBDASpins()
    local data = GetPlayerDataFolder()
    local spinning = data and data:FindFirstChild("Spinning")
    local freeOther = spinning and spinning:FindFirstChild("FreeOtherSpins")
    return freeOther and freeOther.Value or 0
end

local function GetMyValuesFolder()
    local ps = ReplicatedStorage:FindFirstChild("Player_Service")
    local vals = ps and ps:FindFirstChild("Values")
    return vals and vals:FindFirstChild(LocalPlayer.Name)
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Système de combat natif Slayers 2 (InputHandler direct)
local InputHandler
pcall(function()
    InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
end)


local function IsPlayerStunnedOrRagdolled()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.GettingUp then
        return true
    end

    local u2 = nil
    pcall(function()
        u2 = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(LocalPlayer.Name)
    end)
    if u2 then
        if u2:FindFirstChild("Stun") or u2:FindFirstChild("Strict_Stun") or u2:FindFirstChild("CombatStun") or u2:FindFirstChild("RagDoll") then
            return true
        end
    end

    return false
end

local function ForceUnfreezeCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local animator = hum and hum:FindFirstChildOfClass("Animator")

    -- 1. Nettoyer les valeurs Stun/Ragdoll/Blocking orphelines dans Player_Service
    pcall(function()
        local u2 = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(LocalPlayer.Name)
        if u2 then
            local toRemove = { "Stun", "Strict_Stun", "CombatStun", "RagDoll", "Ragdoll", "ragdoll", "ragDoll", "Blocking", "JumpingDisabled", "skill_stand_still", "skill_slow" }
            for _, name in ipairs(toRemove) do
                local v = u2:FindFirstChild(name)
                if v then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end)

    -- 2. Nettoyer les marqueurs de ralentissement sur HumanoidRootPart
    pcall(function()
        if root then
            local toRemoveRoot = { "skill_stand_still", "skill_slow", "air_combo_bp" }
            for _, name in ipairs(toRemoveRoot) do
                local v = root:FindFirstChild(name)
                if v then pcall(function() v:Destroy() end) end
            end
        end
    end)

    -- 3. Relâcher les inputs virtuels de parade et combat
    pcall(function()
        if InputHandler and InputHandler.VirtualRelease then
            InputHandler.VirtualRelease("Block")
            InputHandler.VirtualRelease("Combat")
        end
    end)

    -- 4. Nettoyer les contraintes Ragdoll et rétablir les RigidJoints
    pcall(function()
        local ragdoll = char:FindFirstChild("RagdollConstraints")
        if ragdoll then
            for _, child in ipairs(ragdoll:GetChildren()) do
                if child:IsA("Constraint") then
                    child.Enabled = false
                    if child:FindFirstChild("RigidJoint") and child.RigidJoint.Value then
                        local rj = child.RigidJoint.Value
                        local att1 = child.Attachment1
                        if att1 and att1.Parent and rj.Part1 ~= att1.Parent then
                            rj.Part1 = att1.Parent
                        end
                    end
                end
            end
        end
    end)

    -- 5. Stopper et détruire les pistes d'animations d'attaque bloquées (Anti-64 limit)
    pcall(function()
        if animator then
            for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
                if tr.Name ~= "idle" then
                    pcall(function()
                        tr:Stop(0)
                        tr:Destroy()
                    end)
                end
            end
        end
    end)

    -- 6. Restaurer l'état Humanoid, vitesse de marche et puissance de saut
    pcall(function()
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Running)
            if hum.WalkSpeed < 10 then
                hum.WalkSpeed = 16
            end
            if hum.JumpPower == 0 then
                hum.JumpPower = 50
            end
            hum.PlatformStand = false
            hum.Sit = false
            hum.AutoRotate = true
        end
    end)
end

-- Exécution directe des compétences de combat (Spells / Breathing / Demon Art)
local lastSkillCast = 0
local lastSkillName = nil
local function CastAvailableSkill()
    if not Hub or not Hub.Farm or not Hub.Farm.AutoSkills then return false end
    if IsPlayerStunnedOrRagdolled() then return false end
    local now = os.clock()
    local baseGap = Hub.Farm.InstantKill and 0.1 or (Hub.Farm.SkillInterval or 1.0)
    local skillGap = baseGap * (0.7 + math.random() * 0.7)
    if math.random() < 0.14 then
        skillGap = skillGap * (1.8 + math.random() * 1.6)
    end
    if (now - lastSkillCast) < skillGap then return false end

    local casted = false
    pcall(function()
        local sp = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
        local keys = sp.get_current_keys()
        if not keys or #keys == 0 then return end

        -- Filtrer les compétences actives (exclure Blocking)
        local validSkills = {}
        for _, k in ipairs(keys) do
            if k.Name and k.Name ~= "Blocking" and k.Key and not k.RequiresModeBar then
                table.insert(validSkills, k)
            end
        end

        if #validSkills == 0 then return end

        local pick = math.random(1, #validSkills)
        if #validSkills > 1 and validSkills[pick] and validSkills[pick].Name == lastSkillName then
            for _ = 1, 6 do
                pick = math.random(1, #validSkills)
                if validSkills[pick] and validSkills[pick].Name ~= lastSkillName then break end
            end
        end
        local targetSkill = validSkills[pick]

        if not targetSkill then return end

        -- Méthode 1 : Invocation Direct Engine via Skill_Controller sous Thread Identity 2
        local oldId = getthreadidentity and getthreadidentity() or 8
        local held = false
        pcall(function()
            if setthreadidentity then setthreadidentity(2) end
            local sc = require(ReplicatedStorage.CAM.Client.Controllers.Skill_Controller)
            held = sc.Attempt_Hold(targetSkill.Name)
            if held then
                task.delay(0.08, function()
                    pcall(function()
                        if setthreadidentity then setthreadidentity(2) end
                        sc.StopHold(targetSkill.Name)
                        if setthreadidentity then setthreadidentity(oldId) end
                    end)
                end)
            end
        end)
        if setthreadidentity then setthreadidentity(oldId) end

        if held then
            lastSkillCast = now
            lastSkillName = targetSkill.Name
            casted = true
            return
        end

        -- Méthode 2 : UI Button Click (si présent dans SkillsHolder).
        -- Sautee si firesignal est un no-op (ex: Real), sinon elle marquerait
        -- un faux succes et bloquerait la Methode 3.
        if not NW_NoFiresignal then
        pcall(function()
            local sh = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ComponentsHolder")
            local bh = sh and sh:FindFirstChild("BottomHolder")
            local skillsHolder = bh and bh:FindFirstChild("SkillsHolder")
            if skillsHolder then
                for _, frame in ipairs(skillsHolder:GetChildren()) do
                    local keyLabel = frame:FindFirstChild("KeyLabel", true)
                    if keyLabel and keyLabel.Text == targetSkill.Key then
                        local btn = frame:FindFirstChildWhichIsA("GuiButton", true)
                        if btn then
                            firesignal(btn.MouseButton1Down)
                            task.wait(0.04)
                            firesignal(btn.MouseButton1Up)
                            lastSkillCast = now
                            lastSkillName = targetSkill.Name
                            casted = true
                            return
                        end
                    end
                end
            end
        end)
        end

        if casted then return end

        -- Méthode 3 : Simulation VIM Touche Clavier
        if targetSkill.Key and VirtualInputManager then
            local keyEnum = Enum.KeyCode[targetSkill.Key]
            if keyEnum then
                VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
                task.wait(0.04)
                VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
                lastSkillCast = now
                lastSkillName = targetSkill.Name
                casted = true
            end
        end
    end)
    return casted
end

-- Attaque prouvee post-update (portee du hub donjon) :
-- le serveur valide CHAQUE attaque (combo exact + cooldown reel) via
-- Combat_presets.Check_can_do_combat_server. Les taps en rafale sont
-- rejetes silencieusement ("coups qui ne s'enregistrent pas"). On MAINTIENT
-- l'input et le jeu enchaine les M1 au tempo serveur (holdChain).
NW_ATTACK_HELD = false
NW_LAST_EQUIP_CHECK = 0

function EnsureWeaponEquipped()
    if not Hub.Farm.AutoEquipWeapon then return end
    local now = os.clock()
    if (now - (NW_LAST_EQUIP_CHECK or 0)) < 0.4 then return end
    NW_LAST_EQUIP_CHECK = now
    pcall(function()
        local ic = LocalPlayer:FindFirstChild("Items_Config")
        if ic and ic:FindFirstChild("Equipped") then
            if ic.Equipped.Value == 0 then
                ic.Equipped.Value = 1
                if SignalEvent and SignalEvent.ToServer then
                    SignalEvent.ToServer("Item_Equip", 1)
                end
            end
        end
        local vals = GetMyValuesFolder()
        if vals and vals:FindFirstChild("tooldisabled") then
            vals.tooldisabled:Destroy()
        end
    end)
end

function ReleaseAttack()
    NW_ATTACK_HELD = false
    if InputHandler and InputHandler.VirtualRelease then
        pcall(function() InputHandler.VirtualRelease("Combat") end)
    elseif mouse1press and mouse1release then
        pcall(mouse1release)
    end
end

-- Defense : une ancienne execution du hub aurait pu laisser des cooldowns
-- trafiques dans Combat_presets (le serveur rejette alors TOUT). On restaure
-- les vraies valeurs, comme le hub donjon.
pcall(function()
    NW_CombatPresets = require(ReplicatedStorage.CAM.Global.Combat_presets)
end)
function RestoreCombatPresets()
    pcall(function()
        if not (NW_CombatPresets and NW_CombatPresets.Presets) then return end
        local saved = _G.KyokaOWPresetOriginals
        if saved then
            for k, orig in pairs(saved.Presets or {}) do
                local p = NW_CombatPresets.Presets[k]
                if p ~= nil then NW_CombatPresets.Presets[k] = orig end
            end
            if saved.combo_duration ~= nil then
                NW_CombatPresets.combo_duration = saved.combo_duration
            end
            _G.KyokaOWPresetOriginals = nil
        end
        for _, p in pairs(NW_CombatPresets.Presets) do
            if type(p) == "table" then
                if type(p.Cooldown) == "number" and p.Cooldown <= 0 then
                    p.Cooldown = nil
                end
            end
        end
        if type(NW_CombatPresets.combo_duration) == "number" and NW_CombatPresets.combo_duration < 0.5 then
            NW_CombatPresets.combo_duration = 1.35
        end
    end)
end
task.spawn(RestoreCombatPresets)

local function PerformAttack(multiCount)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- Stun : on nettoie immediatement au lieu de rester bloque
    if IsPlayerStunnedOrRagdolled() then
        ForceUnfreezeCharacter()
    end

    EnsureWeaponEquipped()

    -- Release block immediately before attack so M1 is never swallowed
    if InputHandler and InputHandler.VirtualRelease then
        pcall(function() InputHandler.VirtualRelease("Block") end)
    end

    if NW_ATTACK_HELD then return end

    -- Anti-overflow des animations (64 AnimationTrack limit guard)
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator and Hub.Combat.TrackGuard then
        pcall(function()
            local tracks = animator:GetPlayingAnimationTracks()
            for _, tr in ipairs(tracks) do
                local n = tr.Name
                if string.find(n, "Swing") or string.find(n, "Punch") or string.find(n, "Slash") or string.find(n, "React") then
                    pcall(function()
                        tr:Stop(0)
                        tr:Destroy()
                    end)
                end
            end
        end)
    end

    -- Duree de maintien : le jeu enchaine les M1 tant que l'input reste enfonce.
    -- InstantKill = maintien quasi permanent. Sinon la duree suit "Hits Per Cycle"
    -- (le serveur garde de toute facon son propre rythme max).
    local holdTime
    if Hub.Farm.InstantKill then
        holdTime = 1.2
    elseif Hub.Farm.MultiHit then
        holdTime = 0.3 + math.clamp(multiCount or Hub.Farm.MultiHitCount or 4, 1, 10) * 0.1
    else
        holdTime = 0.15
    end

    if InputHandler and InputHandler.VirtualPress and InputHandler.VirtualRelease then
        NW_ATTACK_HELD = true
        InputHandler.VirtualPress("Combat")
        task.delay(holdTime, ReleaseAttack)
    elseif mouse1press and mouse1release then
        mouse1press()
        task.delay(holdTime, function() pcall(mouse1release) end)
    elseif mouse1click then
        mouse1click()
    elseif VirtualInputManager then
        VirtualInputManager:SendMouseButtonEvent(600, 400, 0, true, game, 0)
        task.delay(holdTime, function()
            pcall(function() VirtualInputManager:SendMouseButtonEvent(600, 400, 0, false, game, 0) end)
        end)
    end
end

-- Détection des Mobs vivants dans Workspace.Humanoids.Regions
local function GetAliveMobs()
    local alive = {}
    local humsFolder = Workspace:FindFirstChild("Humanoids")
    local regions = humsFolder and humsFolder:FindFirstChild("Regions")

    if regions then
        for _, region in ipairs(regions:GetChildren()) do
            local activeNpcs = region:FindFirstChild("ActiveNpcs")
            if activeNpcs then
                for _, mobTypeFolder in ipairs(activeNpcs:GetChildren()) do
                    for _, mobModel in ipairs(mobTypeFolder:GetChildren()) do
                        if mobModel:IsA("Model") and mobModel ~= LocalPlayer.Character then
                            local hum = mobModel:FindFirstChildOfClass("Humanoid")
                            local root = mobModel:FindFirstChild("HumanoidRootPart") or mobModel:FindFirstChild("Torso")
                            if hum and root and hum.Health > 0 and root.Position.Y > -400 then
                                table.insert(alive, {
                                    Model = mobModel,
                                    Root = root,
                                    Humanoid = hum,
                                    Name = mobModel.Name,
                                    Type = mobTypeFolder.Name,
                                    Region = region.Name
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback si les mobs spawnent directement dans Humanoids
    if #alive == 0 and humsFolder then
        for _, c in ipairs(humsFolder:GetChildren()) do
            if c:IsA("Model") and c ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(c) then
                local hum = c:FindFirstChildOfClass("Humanoid")
                local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
                if hum and root and hum.Health > 0 and root.Position.Y > -400 then
                    table.insert(alive, {
                        Model = c,
                        Root = root,
                        Humanoid = hum,
                        Name = c.Name,
                        Type = c.Name,
                        Region = "Direct"
                    })
                end
            end
        end
    end

    return alive
end

local BossesList = {
    ["yetidemon"] = true,
    ["smallyeti"] = true,
    ["handdemon"] = true,
    ["zuko"] = true,
    ["saneri"] = true,
    ["obari"] = true,
    ["shinora"] = true,
    ["giyen"] = true,
    ["tengai"] = true,
    ["tengen"] = true,
    ["zentaro"] = true,
    ["gyorei"] = true,
    ["rengu"] = true,
    ["gyutai"] = true,
    ["datai"] = true,
    ["reaper"] = true,
    ["akazo"] = true,
    ["domae"] = true,
    ["nezura"] = true,
    ["yahari"] = true,
    ["sumari"] = true,
    ["enru"] = true,
    -- Raid Bosses & Sealed Cache guards (Temporary region). Were missing, so
    -- Boss mode could never target them (verified live: Lancer Captain ignored).
    ["groveraider"] = true,
    ["raidcaptain"] = true,
    ["cacheprowler"] = true,
    ["prowlercaptain"] = true,
    ["cachelancer"] = true,
    ["lancercaptain"] = true,
    -- Bosses de Quête de Région
    ["hoyuzo"] = true,
    ["kaiden"] = true,
    ["fujiko"] = true,
    ["motherbear"] = true,
    -- Trainees (considérés comme Bosses / Mini-Bosses dans le moteur)
    ["flametrainee"] = true,
    ["watertrainee"] = true,
    ["watertraineesabito"] = true,
    ["thundertrainee"] = true,
    ["windtrainee"] = true,
    ["soundtrainee"] = true,
    ["stonetrainee"] = true,
    ["serpenttrainee"] = true,
    ["insecttrainee"] = true,
    ["taichitrainee"] = true,
    ["taichitraineesuzume"] = true,
    ["soryutrainee"] = true,
    ["soryutraineegoki"] = true,
    ["reapertrainee"] = true,
    ["reapertraineekuzan"] = true
}

local function IsBossMob(mob)
    local rawName = string.lower(mob.Name or "")
    local cleanName = string.gsub(rawName, "%s+", "")
    local rawType = string.lower(mob.Type or "")
    local cleanType = string.gsub(rawType, "%s+", "")
    return BossesList[rawName] or BossesList[cleanName] or BossesList[rawType] or BossesList[cleanType] or string.find(rawName, "trainee") or string.find(rawType, "trainee") or false
end

local function IsTargetValid(mob, filterName, regionFilter, categoryFilter)
    if not mob then return false end
    if not mob.Model or not mob.Model.Parent then return false end
    if not mob.Humanoid or not mob.Humanoid.Parent or (mob.Humanoid.Health or 0) <= 0 then return false end
    if not mob.Root or not mob.Root.Parent or mob.Root.Position.Y <= -400 then return false end

    local isCiv = string.find(string.lower(mob.Type or ""), "civilian") or string.find(string.lower(mob.Name or ""), "civilian")
    local isCivFilter = (type(filterName) == "string" and filterName ~= "All") and (string.find(string.lower(filterName), "civilian") or string.find(string.lower(filterName), "civil"))
    if isCiv and not isCivFilter then return false end

    local isBoss = IsBossMob(mob)
    if categoryFilter == "Boss" and not isBoss then return false end
    if categoryFilter == "Normal" and isBoss then
        -- Explicit pick wins: user pinpointed this exact mob by name, so allow it
        -- even though it is boss-classified (e.g. raid guards farmed in Normal mode
        -- before they became Boss-category). Categories only filter "All" picks.
        local function exactPick(fItem)
            if not fItem or fItem == "All" or fItem == "All Bosses" or fItem == "All Normal Mobs" then
                return false
            end
            local fLow = string.lower(fItem)
            local fClean = string.gsub(fLow, "%s+", "")
            local fBase = fClean:gsub("_%a+", "")
            local mType = string.lower(mob.Type or "")
            local mName = string.lower(mob.Name or "")
            local mTypeClean = string.gsub(mType, "%s+", "")
            local mNameClean = string.gsub(mName, "%s+", "")
            local mTypeBase = mTypeClean:gsub("_%a+", "")
            local mNameBase = mNameClean:gsub("_%a+", "")
            return mTypeClean == fClean or mNameClean == fClean
                or mType == fLow or mName == fLow
                or mTypeBase == fBase or mNameBase == fBase
        end
        local explicit = false
        if type(filterName) == "table" then
            for _, fItem in ipairs(filterName) do
                if exactPick(fItem) then explicit = true break end
            end
        else
            explicit = exactPick(filterName)
        end
        if not explicit then return false end
    end

    local function matchSingleName(fItem)
        if not fItem or fItem == "All" or fItem == "All Bosses" or fItem == "All Normal Mobs" then
            return true
        end
        local fLow = string.lower(fItem)
        local fClean = string.gsub(fLow, "%s+", "")
        local mType = string.lower(mob.Type or "")
        local mName = string.lower(mob.Name or "")
        local mTypeClean = string.gsub(mType, "%s+", "")
        local mNameClean = string.gsub(mName, "%s+", "")

        -- Match exact name / clean name first to avoid "Hoyuzo" matching "Hoyuzo Subordinate"
        if mTypeClean == fClean or mNameClean == fClean or mType == fLow or mName == fLow then
            return true
        end

        -- Strip region suffix from filter item (e.g. "GreaterDemon_ButterflyEstate" -> "greaterdemon")
        local fBase = fClean:gsub("_%a+", "")

        -- Strip region suffix from mob type/name if present
        local mTypeBase = mTypeClean:gsub("_%a+", "")
        local mNameBase = mNameClean:gsub("_%a+", "")

        if mTypeBase == fBase or mNameBase == fBase or mTypeClean == fBase or mNameClean == fBase then
            return true
        end

        -- Prevent Greater Demon from matching Lesser Demon or vice-versa
        local fHasGreater = string.find(fBase, "greater") ~= nil
        local fHasLesser = string.find(fBase, "lesser") ~= nil
        local mHasGreater = (string.find(mTypeClean, "greater") or string.find(mNameClean, "greater")) ~= nil
        local mHasLesser = (string.find(mTypeClean, "lesser") or string.find(mNameClean, "lesser")) ~= nil

        if fHasGreater and mHasLesser then return false end
        if fHasLesser and mHasGreater then return false end

        if string.find(fClean, "trainee") and (mType:find("trainee") or mName:find("trainee")) then
            local prefix = fClean:gsub("trainee", "")
            if prefix == "" or mTypeClean:find(prefix) or mNameClean:find(prefix) then
                return true
            end
        elseif (fClean:find("tengen") or fClean:find("tengai")) and (mType:find("tengai") or mName:find("tengai")) then
            return true
        elseif not string.find(mTypeClean, "subordinate") and not string.find(mNameClean, "subordinate") then
            -- Fallback substring match only if not a subordinate when searching for a boss
            if string.find(mType, fLow) or string.find(mName, fLow) or string.find(mTypeClean, fClean) or string.find(mNameClean, fClean) or string.find(mTypeClean, fBase) or string.find(mNameClean, fBase) then
                return true
            end
        end
        return false
    end

    local matchesFilter = false
    if type(filterName) == "table" then
        if #filterName == 0 then
            matchesFilter = true
        else
            for _, fItem in ipairs(filterName) do
                if matchSingleName(fItem) then
                    matchesFilter = true
                    break
                end
            end
        end
    else
        matchesFilter = matchSingleName(filterName)
    end

    if not matchesFilter then return false end
    return true
end

local function GetClosestMob(filterName, regionFilter, categoryFilter)
    local myRoot = GetRootPart()
    if not myRoot then return nil end

    local mobs = GetAliveMobs()
    local closest = nil
    local shortestDist = math.huge

    for _, mob in ipairs(mobs) do
        if IsTargetValid(mob, filterName, regionFilter, categoryFilter) then
            local matchesRegion = (regionFilter == "All" or mob.Region == regionFilter)
            if matchesRegion then
                local dist = (myRoot.Position - mob.Root.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = mob
                end
            end
        end
    end

    return closest
end

-- Trouve instantanément le premier boss vivant parmi la liste des bosses sélectionnés (évite d'attendre dans le vide)
local function FindAliveBossFromList(bossList, regionFilter)
    if not bossList or #bossList == 0 then return nil end
    local myRoot = GetRootPart()
    local myPos = myRoot and myRoot.Position

    local mobs = GetAliveMobs()
    local bestMob = nil
    local bestDist = math.huge

    for _, mob in ipairs(mobs) do
        if IsTargetValid(mob, bossList, regionFilter, "Boss") then
            local matchesRegion = (not regionFilter or regionFilter == "All" or mob.Region == regionFilter)
            if matchesRegion then
                local dist = myPos and (myPos - mob.Root.Position).Magnitude or 0
                if dist < bestDist then
                    bestDist = dist
                    bestMob = mob
                end
            end
        end
    end

    return bestMob
end

-- Détection des Joueurs vivants pour le Player Farm (Support Intégral StreamingEnabled & Anti-Void)
local function GetAlivePlayers()
    local alive = {}
    local myRoot = GetRootPart()
    local myPos = myRoot and myRoot.Position or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local pivot = char:GetPivot()
            local pos = (root and root.Position) or (pivot and pivot.Position)
            local cf = (root and root.CFrame) or pivot
            local health = (hum and hum.Health) or 100

            -- Vérification rigoureuse des limites réelles de la carte jouable (élimine les joueurs dans le vide ou l'écran de chargement)
            if pos and health > 0 and pos.Y > 0 and pos.Y < 2500 and math.abs(pos.X) < 3500 and math.abs(pos.Z) < 3500 then
                table.insert(alive, {
                    Player = plr,
                    Model = char,
                    Root = root,
                    Position = pos,
                    CFrame = cf,
                    Humanoid = hum,
                    Health = health,
                    Name = plr.Name,
                    DisplayName = plr.DisplayName,
                    Type = "Player",
                    Region = "World",
                    HasRoot = (root ~= nil)
                })
            end
        end
    end

    -- Priorité aux joueurs déjà physiquement présents et confirmés dans le monde (HasRoot == true), puis tri par distance
    table.sort(alive, function(a, b)
        if a.HasRoot ~= b.HasRoot then
            return a.HasRoot
        end
        if myPos and a.Position and b.Position then
            return (myPos - a.Position).Magnitude < (myPos - b.Position).Magnitude
        end
        return false
    end)

    return alive
end

local function IsPlayerTargetValid(target, selectedPlayerName)
    if not target then return false end
    if not target.Player or not target.Player.Parent then return false end
    if not target.Model or not target.Model.Parent then return false end

    -- Mettre à jour dynamiquement Root et Humanoid s'ils ont été streamés
    local root = target.Model:FindFirstChild("HumanoidRootPart") or target.Model:FindFirstChild("Torso")
    if root then
        target.Root = root
        target.Position = root.Position
        target.CFrame = root.CFrame
        target.HasRoot = true
    else
        local pivot = target.Model:GetPivot()
        if pivot then
            target.Position = pivot.Position
            target.CFrame = pivot
        end
    end

    local hum = target.Model:FindFirstChildOfClass("Humanoid")
    if hum then
        target.Humanoid = hum
        target.Health = hum.Health
        if hum.Health <= 0 then return false end
    end

    if not target.Position then return false end
    -- Vérification des limites de la carte jouable
    if target.Position.Y <= 0 or target.Position.Y >= 2500 or math.abs(target.Position.X) >= 3500 or math.abs(target.Position.Z) >= 3500 then
        return false
    end

    if selectedPlayerName and selectedPlayerName ~= "All Players" then
        local sLow = string.lower(selectedPlayerName)
        local nLow = string.lower(target.Name or "")
        local dLow = string.lower(target.DisplayName or "")
        if nLow ~= sLow and dLow ~= sLow and not sLow:find(nLow, 1, true) then
            return false
        end
    end

    return true
end

local function GetClosestPlayer(selectedPlayerName)
    local myRoot = GetRootPart()
    local myPos = myRoot and myRoot.Position or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position)
    if not myPos then return nil end

    local players = GetAlivePlayers()
    local closest = nil
    local shortestDist = math.huge

    local sLow = selectedPlayerName and string.lower(selectedPlayerName)

    for _, p in ipairs(players) do
        local matches = true
        if sLow and sLow ~= "all players" then
            local nLow = string.lower(p.Name or "")
            local dLow = string.lower(p.DisplayName or "")
            if nLow ~= sLow and dLow ~= sLow and not sLow:find(nLow, 1, true) then
                matches = false
            end
        end

        if matches then
            local dist = (myPos - p.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = p
            end
        end
    end

    return closest
end


--=====================================================================
-- Structure de Configuration Globale
--=====================================================================
Hub = {
    Alive = true,
    Connections = {},
    ESPHighlights = {},
    CurrentTarget = nil,
    LockedTarget = nil,
    FarmPlatform = nil,
    IsInteractingQuest = false,
    IsCollectingLoot = false,
    IsLeavingForStaff = false,

    -- Server travel (fix anti-cheat) : payer les Wen pour debloquer une
    -- shrine verrouillee lors d'un travel (sinon le travel est ignore).
    TravelPayUnlock = true,

    -- Anti-Mod: instant server hop when a staff member joins.
    -- Ouw Productions group roles: Member 1 / Early Access 2 / Tester 3 /
    -- Content Creator 4 / Balancers 4 / Admin 5 / Studio Developer 6 /
    -- Partner 254 / Owner 255. Staff = rank >= 5 (verified live: 0/14
    -- regular players are in the group at all).
    Protection = {
        StaffDetectEnabled = true,
        StaffGroupId = 12851171,
        StaffMinRank = 5,
        StaffRecheckInterval = 20,
    },

    Farm = {
        AutoFarm = false,
        TargetLock = true,
        MobCategory = "Normal", -- "Normal", "Boss", "All"
        NormalMob = "All Normal Mobs",
        BossMob = "All Bosses",
        SelectedBosses = {},
        BossRotationInterval = 15.0,
        TargetMob = "All",
        RegionFilter = "All",
        AutoTravelToRegion = true,
        Distance = 2.0,
        AutoM1 = true,
        AutoEquipWeapon = true, -- garde le katana equipe (sinon les M1 sont ignores)
        -- Player Farm (Auto Farm Joueurs)
        PlayerFarm = false,
        PlayerTargetMode = "Closest Player", -- "Closest Player", "Specific Player"
        SelectedPlayer = "All Players",
        PlayerSafeMode = "Overhead",
        PlayerHeightOffset = 3.0,
        PlayerDistance = 2.5,
        -- Safe & Powerful Combat Options
        SafeMode = "Overhead", -- "Overhead", "Underground", "In Front"
        HeightOffset = 2.5,
        MultiHit = true,
        MultiHitCount = 3,
        -- Auto Skills / Spells
        AutoSkills = true,
        SkillInterval = 1.0,
        -- Instant Kill (Max DPS Burst)
        InstantKill = false,
        AutoCollectChests = true,
        AutoCollectLoot = true,
        AutoCollectSouls = true,
        BossLootWaitTime = 4.0,
        MobLootWaitTime = 1.8,
        -- Auto Quest Engine
        AutoQuest = false,
        AutoAcceptNextQuest = true,
        QuestMode = "Auto Best Quest (By Level)", -- "Auto Best Quest (By Level)", or specific quest name
        ActiveQuestName = nil,
        ActiveQuestTarget = nil,
        -- Quêtes refusées par le PNJ (prérequis non remplis, race, etc.) :
        -- mises de côté temporairement pour ne pas bloquer la boucle.
        QuestBlacklist = {},
        QuestFailCount = {},
    },

    -- Sealed Cache Farm (T1 / T2 / T3) + Server Hop
    CacheFarm = {
        Enabled = false,
        Tiers = { ["Sealed Cache T1"] = true, ["Sealed Cache T2"] = true, ["Sealed Cache T3"] = true },
        KillGuards = true,
        ServerHop = true,
        PreferEmpty = true,
        HopDelay = 12,
        Hops = 0,
        Opened = {},
        NoCacheSince = nil,
        LastAction = 0,
        LastHop = 0,
        LastStatus = "",
    },

    -- Black Marketer (Night Market timed vendor)
    NightMarket = {
        Auto = false,
        LastCycle = nil,
        CheckAt = 0,
        Label = nil,
    },

    -- Discord Boss-Farm Webhooks (loot drops + progress)
    Webhook = {
        Url = "",
        DropsEnabled = false,
        ProgressEnabled = false,
        OnlyWhileFarming = true,
        MinRarity = 3,
        ProgressMinutes = 15,
        LastProgressAt = 0,
        LastBoss = nil,
        LastBossAt = nil,
        Defeated = {},
        BossKillsTotal = 0,
        WenStart = nil,
        QuestsStart = nil,
        StartTime = 0,
        SeenItems = nil,
        ItemMeta = {},
        ThumbCache = {},
        Label = nil,
        KillsLabel = nil,
        LabelAt = 0,
    },

    -- Config Save / Load (vesper/*.json + auto-load)
    Config = {
        Name = "default",
        AutoLoad = false,
    },

    Training = {
        AutoMinigames = false,
        AutoBoulder = false,
        AutoSquats = false,
        AutoPushups = false,
        AutoMeditation = false,
        AutoStay = false,
        StationName = "Meditation",
    },

    Combat = {
        InfStamina = true,
        NoSunDamage = false,
        NoColdDamage = false,
        FastAttack = false,
        AntiFreeze = true,
        TrackGuard = true,
    },

    Visuals = {
        PlayerESP = false,
        MobESP = true,
        ESPBoxes = true,
        PlayerColor = Color3.fromRGB(124, 108, 255),
        MobColor = Color3.fromRGB(255, 65, 65),
        -- ESP du monde (leviers Nightfall, clés serpent, coffres, StudyProps...)
        WorldESP = {
            Levers = false,
            SerpentKey = false,
            SerpentBox = false,
            StudyProps = false,
            Chests = false,
            SpiderLily = false,
            Shrines = false,
            SpawnCrystals = false,
            SimonPlates = false,
            ShowDistance = true,
        },
    },

    -- Énigmes de la map (leviers Nightfall Sickles)
    Puzzles = {
        AutoPullLevers = false,
        AutoTravelLevers = true,
        LastPull = 0,
        NotifiedSolved = false,
    },

    -- Pêche automatique
    Fish = {
        Auto = false,
        State = "idle",        -- idle | cast | wait_bite | bite | collect
        LastAction = 0,
        Caught = 0,
        Failed = 0,
        RodName = nil,
        RodSlot = nil,
        WaterPoint = nil,
        AutoSellFish = true,
        AutoBuyRod = false,
        LastRodCheck = 0,
    },

    -- Raffinage automatique (Refiner Hagane)
    Refine = {
        Auto = false,
        ItemName = nil,
        UseGuard = false,
        LastAttempt = 0,
        Attempts = 0,
        Greats = 0,
        Fails = 0,
    },

    -- Vente automatique (Ginzo)
    Sell = {
        Auto = false,
        Mode = "Fish Only",   -- "Fish Only" | "All Sellable"
        LastSell = 0,
        TotalEarned = 0,
    },

    Spin = {
        AutoSpin = false,
        Mode = "Rarity", -- "Rarity" or "Specific Clan"
        StopRarity = "Mythic+", -- "Mythic+", "Supreme Only", "Legendary+"
        TargetClan = "Kamado",
        Delay = 0.15, -- Vitesse optimale sans rate limit (6.6 spins/sec)
        IsSpinning = false,
        LastResult = "None",

        BDA = {
            AutoSpin = false,
            Mode = "Rarity",
            StopRarity = "Legendary+",
            TargetBDA = "Shockwave",
            Delay = 0.15,
            LastResult = "None"
        }
    },

    Misc = {
        CustomSpeed = false,
        WalkSpeed = 35,
        NoClip = false,
        InfiniteJump = false,
    }
}
_G.SlayersKyokaHub = Hub

--=====================================================================
-- Gestion de la Plateforme Anti-Chute
--=====================================================================
-- IMPORTANT : la plateforme NE DOIT PAS être solide. Les groupes de collision
-- ne peuvent pas être créés côté client (API serveur uniquement) et les mobs
-- sont dans le même groupe que le joueur : une plateforme solide se faisait
-- donc "escalader" par les mobs, qui montaient dessus pendant que la
-- plateforme se repositionnait au-dessus d'eux -> ascenseur infini.
-- Le maintien en l'air est assuré par le repositionnement CFrame à chaque
-- frame du moteur de farm ; la plateforme ne sert plus que de repère.
-- Modèle pré-créé : sur les executors qui bloquent Instance.new dans les
-- callbacks, on clone ce modèle au lieu de créer une nouvelle Part.
local FarmPlatformTemplate = nil
pcall(function()
    local p = Instance.new("Part")
    p.Name = "KyokaFarmPlatform"
    p.Size = Vector3.new(8, 1, 8)
    p.Transparency = 1
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Parent = nil
    FarmPlatformTemplate = p
end)

local function EnsureFarmPlatform(cframe)
    local root = GetRootPart()
    if not root then return end

    if not Hub.FarmPlatform or not Hub.FarmPlatform.Parent then
        local p = nil
        if FarmPlatformTemplate then
            pcall(function() p = FarmPlatformTemplate:Clone() end)
        end
        if not p then
            pcall(function() p = Instance.new("Part") end)
        end
        if not p then return end
        p.Name = "KyokaFarmPlatform"
        p.Size = Vector3.new(8, 1, 8)
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.Parent = Workspace
        Hub.FarmPlatform = p
    end

    local pos = (typeof(cframe) == "CFrame" and cframe.Position) or (typeof(cframe) == "Vector3" and cframe) or (root.Position)
    Hub.FarmPlatform.Size = Vector3.new(8, 1, 8)
    Hub.FarmPlatform.CanCollide = false
    Hub.FarmPlatform.CanTouch = false
    Hub.FarmPlatform.CanQuery = false
    -- Toujours horizontal dans l'espace monde (aucun basculement vertical ni glissade)
    Hub.FarmPlatform.CFrame = CFrame.new(pos.X, pos.Y - 3.2, pos.Z)
end

local function RemoveFarmPlatform()
    if Hub.FarmPlatform then
        pcall(function() Hub.FarmPlatform:Destroy() end)
        Hub.FarmPlatform = nil
    end
end

-- Points de référence par région (pour auto-voyage et streaming)
local RegionWaypoints = {
    ["Hidden Mist Village"] = Vector3.new(1651.0, 607.3, -124.0),
    ["Mistfall Harbor"] = Vector3.new(140.7, 873.5, 728.2),
    ["Bamboo Grove"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["Windy Peak"] = Vector3.new(-456.0, 1241.0, -932.0),
    ["Butterfly Estate"] = Vector3.new(-1772.0, 311.3, -110.9),
    ["Iceveil Valley"] = Vector3.new(283.9, 1305.0, -2041.2),
    ["Final Selection Plains"] = Vector3.new(-1834.0, 35.0, 487.5),
    ["Misc"] = Vector3.new(-315.6, 1292.6, -1488.7),
    ["Temporary"] = Vector3.new(807.0, 1122.0, -1005.0),
}

-- Variables pour l'alternance et rotation des Bosses sélectionnés
local bossRotationIndex = 1
local lastBossRotationTime = 0

-- Points de référence précis par type de Mob (Téléportation directe dès sélection)
local MobSpawnWaypoints = {
    ["Kanoe Demon Slayer"] = Vector3.new(283.9, 1305.0, -2041.2),
    ["Mizunoe Demon Slayer"] = Vector3.new(-1834.0, 35.0, 487.5),
    ["Mizunoto"] = Vector3.new(-784.5, 966.5, -133.8),
    ["Civilian"] = Vector3.new(-567.4, 1246.0, -1024.5),
    ["*Civilian*"] = Vector3.new(-703.9, 1246.0, -946.1),
    ["Bandit"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["KaruVillageBandit"] = Vector3.new(-456.0, 1241.0, -932.0),
    ["Spy"] = Vector3.new(-456.0, 1241.0, -932.0),
    ["VillageSpy"] = Vector3.new(-456.0, 1241.0, -932.0),
    ["Bear Cub"] = Vector3.new(520.0, 1122.0, -1045.0),
    ["Mother Bear"] = Vector3.new(507.2, 1124.0, -970.3),
    ["Kaiden"] = Vector3.new(634.0, 1131.5, -1167.0),
    ["Kaiden Subordinate"] = Vector3.new(590.0, 1148.0, -1300.0),
    ["Hoyuzo"] = Vector3.new(546.9, 1003.9, -1166.8),
    ["Hoyuzo Subordinate"] = Vector3.new(546.9, 1003.9, -1166.8),
    ["Grove Raider"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["Raid Captain"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["Cache Prowler"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["Prowler Captain"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["Cache Lancer"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["Lancer Captain"] = Vector3.new(570.0, 1140.0, -1150.0),
    ["IceveilRoadBandit"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["IceveilRoadMarauder"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["IceveilRoadPikeman"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["High Demon"] = Vector3.new(283.9, 1302.0, -2041.2),
    ["Fire Profound Demon"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["Ice Profound Demon"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["GreaterDemon_ButterflyEstate"] = Vector3.new(-498.9, 284.8, 528.8),
    ["LesserDemon_ButterflyEstate"] = Vector3.new(-675.7, 230.5, 397.1),
    ["Greater Demon"] = Vector3.new(-498.9, 284.8, 528.8),
    ["Lesser Demon"] = Vector3.new(-675.7, 230.5, 397.1),
    ["BloodHoundedDemon_MistfallHarbor"] = Vector3.new(140.7, 873.5, 728.2),
    ["Beast Born Demon"] = Vector3.new(140.7, 873.5, 728.2),
    ["YetiDemon"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["SmallYeti"] = Vector3.new(142.1, 1385.1, -2783.2),
    ["HandDemon"] = Vector3.new(-1834.0, 35.0, 487.5),
    ["Flame Trainee"] = Vector3.new(-1128.9, 1029.0, 994.4),
    ["Water Trainee"] = Vector3.new(815.3, 1018.8, 101.6),
    ["Water Trainee Sabito"] = Vector3.new(815.3, 1018.8, 101.6),
    ["Thunder Trainee"] = Vector3.new(2425.5, 1073.6, -556.8),
    ["Wind Trainee"] = Vector3.new(-941.6, 1381.0, -2635.6),
    ["Sound Trainee"] = Vector3.new(192.5, 1349.0, -2581.3),
    ["Stone Trainee"] = Vector3.new(2685.2, 1073.6, -568.8),
    ["Serpent Trainee"] = Vector3.new(-271.4, 1292.0, -1535.7),
    ["Insect Trainee"] = Vector3.new(-1395.6, 261.5, 69.2),
    ["Tai Chi Trainee"] = Vector3.new(2360.5, 602.0, -642.3),
    ["Tai Chi Trainee Suzume"] = Vector3.new(2360.5, 602.0, -642.3),
    ["Soryu Trainee"] = Vector3.new(-427.0, 288.8, 543.3),
    ["Soryu Trainee Goki"] = Vector3.new(-427.0, 288.8, 543.3),
    ["Reaper Trainee"] = Vector3.new(-1219.3, 1373.6, -3034.4),
    ["Reaper Trainee Kuzan"] = Vector3.new(-1219.3, 1373.6, -3034.4),
    ["Tengai"] = Vector3.new(-133.5, 1349.0, -2631.3),
    ["Tengen"] = Vector3.new(-133.5, 1349.0, -2631.3),
    ["Tengai (Tengen)"] = Vector3.new(-133.5, 1349.0, -2631.3),
    ["Zentaro"] = Vector3.new(1332.1, 821.5, -1017.6),
    ["Reaper"] = Vector3.new(98.5, 1043.0, -573.9),
    ["Akazo"] = Vector3.new(-1132.0, 1380.9, -1746.6),
    ["Shinora"] = Vector3.new(-452.6, 964.5, 2.1),
    ["Yahari"] = Vector3.new(825.7, 1019.2, -641.3),
    ["Domae"] = Vector3.new(-296.5, 1350.5, -3451.3),
    ["Obari"] = Vector3.new(770.5, 1121.0, -1047.0),
    ["Saneri"] = Vector3.new(-379.1, 1093.5, -422.4),
    ["Enru"] = Vector3.new(821.8, 800.0, 543.9),
    ["Sumari"] = Vector3.new(396.4, 1018.0, -620.4),
    ["Rengu"] = Vector3.new(-712.9, 965.0, 883.8),
    ["Gyorei"] = Vector3.new(2574.6, 1089.0, -742.4),
    ["Datai"] = Vector3.new(-165.5, 1043.0, -1137.5),
    ["Nezura"] = Vector3.new(-1459.5, 276.0, 935.5),
    ["Giyen"] = Vector3.new(388.9, 1018.0, -85.1),
    ["Gyutai"] = Vector3.new(-266.1, 1043.2, -1139.7),
    ["Fujiko"] = Vector3.new(-2459.5, 37.9, 1119.0),
    ["Mother Bear"] = Vector3.new(540.5, 1121.0, -1023.5),
}

--=====================================================================
-- Résolution DYNAMIQUE des points de spawn (données officielles du jeu)
-- Le tableau statique ci-dessus peut devenir obsolète après une MAJ de la
-- map : on interroge donc ReplicatedStorage.Regions (NpcSpawns) en priorité.
--=====================================================================
local DynamicSpawnCache = {}

local function NormalizeName(n)
    return string.lower(string.gsub(tostring(n or ""), "%s+", ""))
end

local function GetMobSpawnPosition(name)
    if not name or name == "All" or name == "All Bosses" or name == "All Normal Mobs" then return nil end
    if DynamicSpawnCache[name] ~= nil then return DynamicSpawnCache[name] end

    local pos = nil

    pcall(function()
        local Regions = require(ReplicatedStorage.Regions)
        local raw = Regions.GetNpcSpawn(name)
        if typeof(raw) == "Vector3" then
            pos = raw
        elseif typeof(raw) == "CFrame" then
            pos = raw.Position
        end
    end)

    if not pos then
        pcall(function()
            local Regions = require(ReplicatedStorage.Regions)
            local target = NormalizeName(name)
            for npcName, raw in pairs(Regions.NpcSpawns) do
                if NormalizeName(npcName) == target then
                    if typeof(raw) == "Vector3" then
                        pos = raw
                    elseif typeof(raw) == "CFrame" then
                        pos = raw.Position
                    end
                    break
                end
            end
        end)
    end

    if not pos then
        local target = NormalizeName(name)
        for wpName, wpPos in pairs(MobSpawnWaypoints) do
            local wNorm = NormalizeName(wpName)
            if wNorm == target then
                pos = wpPos
                break
            end
        end
    end

    if not pos then
        local tLow = string.lower(name)
        local target = NormalizeName(name)
        for wpName, wpPos in pairs(MobSpawnWaypoints) do
            local wLow = string.lower(wpName)
            local wNorm = NormalizeName(wpName)
            if string.find(wNorm, target, 1, true) or string.find(target, wNorm, 1, true)
                or string.find(wLow, tLow, 1, true) or string.find(tLow, wLow, 1, true) then
                pos = wpPos
                break
            end
        end
    end

    DynamicSpawnCache[name] = pos
    return pos
end

--=====================================================================
-- SERVER TRAVEL (fix anti-cheat Slayers 2)
-- Depuis l'update serveur, tout CFrame client longue distance est revert
-- (le perso est server-authoritative) -> les TP "classiques" declenchaient
-- le rollback et les bans. Seuls le travel officiel par shrine (signal
-- serveur "TravelShrine") et la marche sont acceptes.
-- Strategie : micro-hop CFrame <= 40 studs (tolere), sinon travel serveur
-- vers la shrine la plus proche puis marche jusqu'a la cible exacte.
--=====================================================================
local SHRINE_TRAVEL_POINTS = {
    { name = "Hidden Mist Village Shrine", pos = Vector3.new(1266.2, 980.9, -482.3) },
    { name = "Windy Peak Shrine",          pos = Vector3.new(-409.4, 1250.2, -1312.0) },
    { name = "Butterfly Estate Shrine",    pos = Vector3.new(-1728.8, 315.2, 126.6) },
    { name = "Frost Veil Shrine",          pos = Vector3.new(142.1, 1385.1, -2783.2) },
    { name = "Mistfall Harbor Shrine",     pos = Vector3.new(140.7, 873.5, 728.2) },
}

local MICRO_HOP_STUDS = 40

local function NearestShrineTravel(targetPos)
    local best, bestD = nil, math.huge
    for _, s in ipairs(SHRINE_TRAVEL_POINTS) do
        local d = (s.pos - targetPos).Magnitude
        if d < bestD then best, bestD = s, d end
    end
    return best
end

local function ServerTravelToShrine(shrine)
    if not shrine then return false end
    if not (SignalEvent and type(SignalEvent.ToServer) == "function") then return false end
    local guard = Hub._LastShrineTravel
    local now = os.clock()
    if guard and guard.name == shrine.name and (now - guard.at) < 5 then
        return guard.ok
    end
    local r0 = GetRootPart()
    local before = r0 and r0.Position or nil
    local moved = false
    pcall(function() SignalEvent.ToServer("TravelShrine", shrine.name) end)
    local deadline = os.clock() + 0.9
    while os.clock() < deadline do
        task.wait(0.1)
        local r = GetRootPart()
        if r and (r.Position - shrine.pos).Magnitude < 40 then moved = true break end
        if before and r and (r.Position - before).Magnitude > 150 then moved = true break end
    end
    -- Shrine verrouillee : unlock officiel (paye en Wen) puis re-travel.
    if not moved and Hub.TravelPayUnlock ~= false
        and SignalFunction and type(SignalFunction.ToServer) == "function" then
        pcall(function() SignalFunction.ToServer("UnlockShrine", shrine.name) end)
        task.wait(0.5)
        pcall(function() SignalEvent.ToServer("TravelShrine", shrine.name) end)
        local deadline2 = os.clock() + 1.6
        while os.clock() < deadline2 do
            task.wait(0.1)
            local r = GetRootPart()
            if r and (r.Position - shrine.pos).Magnitude < 40 then moved = true break end
            if before and r and (r.Position - before).Magnitude > 150 then moved = true break end
        end
    end
    Hub._LastShrineTravel = { name = shrine.name, at = os.clock(), ok = moved }
    return moved
end

local PathfindingService = game:GetService("PathfindingService")

-- Zone courante (AreaLocator du jeu) d'une position. Sert a choisir entre
-- marche directe (meme zone) et travel serveur par shrine (cross-map).
function NWGetAreaName(pos)
    local mod = NW_AREA_MOD
    if not mod then
        local ok, m = pcall(function()
            return require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
        end)
        if not ok or type(m) ~= "table" then return nil end
        NW_AREA_MOD = m
        mod = m
    end
    local okU, Locator = pcall(debug.getupvalue, mod.Update, 1)
    if not okU or type(Locator) ~= "table" or type(Locator.Find) ~= "function" then return nil end
    local okF, areaName = pcall(function()
        local a, b = Locator.Find(Vector2.new(pos.X, pos.Z), mod.CurrentAreas, pos.Y)
        return tostring(b or a or "")
    end)
    if okF and type(areaName) == "string" and areaName ~= "" and areaName ~= "nil" then
        return areaName
    end
    return nil
end

local function WalkToPosition(targetPos, name, timeout)
    local job = Hub._WalkJob
    if job and (os.clock() - job.at) < 1.5 and (job.target - targetPos).Magnitude < 60 then
        return
    end
    Hub._WalkJob = { target = targetPos, at = os.clock() }
    Hub._TravelSeq = (Hub._TravelSeq or 0) + 1
    local mySeq = Hub._TravelSeq
    task.spawn(function()
        local deadline = os.clock() + (timeout or 180)
        while os.clock() < deadline and Hub.Alive and Hub._TravelSeq == mySeq do
            local hum = GetHumanoid()
            local root = GetRootPart()
            if not hum or not root then break end
            if (targetPos - root.Position).Magnitude < 16 then break end
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentCanClimb = true,
                WaypointSpacing = 14,
            })
            local okP = pcall(function() path:ComputeAsync(root.Position, targetPos) end)
            local moved = false
            if okP and path.Status == Enum.PathStatus.Success then
                for _, wp in ipairs(path:GetWaypoints()) do
                    if os.clock() > deadline or not Hub.Alive or Hub._TravelSeq ~= mySeq then break end
                    local r = GetRootPart()
                    if not r or (targetPos - r.Position).Magnitude < 16 then break end
                    if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                    hum:MoveTo(wp.Position)
                    local before = r.Position
                    local t0 = os.clock()
                    while os.clock() - t0 < 5 do
                        local rr = GetRootPart()
                        if not rr then break end
                        if (wp.Position - rr.Position).Magnitude < 7 or (targetPos - rr.Position).Magnitude < 16 then break end
                        task.wait(0.12)
                    end
                    local rr = GetRootPart()
                    if rr and (rr.Position - before).Magnitude > 5 then moved = true end
                end
            end
            if not moved then
                -- Fallback : avance directe + micro-hop de deblocage (<= 30 studs,
                -- tolere par le serveur) quand le pathfinding echoue ou que le perso
                -- reste coince dans la geometrie apres un travel serveur.
                local r = GetRootPart()
                if r then
                    local dir = targetPos - r.Position
                    local flat = Vector3.new(dir.X, 0, dir.Z)
                    flat = flat.Magnitude > 1 and flat.Unit or Vector3.zero
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    r.CFrame = CFrame.new(r.Position + flat * 12 + Vector3.new(0, 8, 0))
                    task.wait(0.4)
                    local h2 = GetHumanoid()
                    if h2 then h2:MoveTo(targetPos) end
                    task.wait(1.2)
                end
            end
            task.wait(0.2)
        end
        local root = GetRootPart()
        if name and root and (root.Position - targetPos).Magnitude < 40 then
            Kyoka:Notify({ Title = "Travel", Content = "Arrived at: " .. name, Type = "success", Duration = 3 })
        end
    end)
end

--=====================================================================
-- FLY TRAVEL (TP / fly sous anti-cheat)
-- Decouvert live : le serveur rollback les CFrame instantanes et les
-- tweens AU SOL rapides, mais les tweens EN L'AIR (~100-150 studs/s)
-- sont acceptes et persistent. Strategie : montee verticale, segments
-- horizontaux (~250 studs) a FLY_SPEED, descente snappee au sol.
--=====================================================================
FLY_SPEED = 120
FLY_LEG_MAX = 250
FLY_CRUISE_EXTRA = 150

function FlyGroundAt(pos)
    local ok, ray = pcall(function()
        return workspace:Raycast(pos + Vector3.new(0, 120, 0), Vector3.new(0, -600, 0))
    end)
    if ok and ray then
        return ray.Position
    end
    return nil
end

function FlyLeg(dest, dur)
    local root = GetRootPart()
    if not root then return false end
    local TS = game:GetService("TweenService")
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local ok, tw = pcall(function()
        return TS:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = CFrame.new(dest) })
    end)
    if not ok or not tw then return false end
    pcall(function() tw:Play() end)
    task.wait(dur + 0.2)
    local r2 = GetRootPart()
    if r2 then
        r2.AssemblyLinearVelocity = Vector3.zero
        r2.AssemblyAngularVelocity = Vector3.zero
        return (r2.Position - dest).Magnitude
    end
    return false
end

function FlyTravelTo(targetPos, name, timeout)
    local job = Hub._WalkJob
    if job and (os.clock() - job.at) < 1.5 and (job.target - targetPos).Magnitude < 60 then
        return
    end
    Hub._WalkJob = { target = targetPos, at = os.clock() }
    Hub._TravelSeq = (Hub._TravelSeq or 0) + 1
    local mySeq = Hub._TravelSeq
    task.spawn(function()
        local deadline = os.clock() + (timeout or 150)
        local destGround = FlyGroundAt(targetPos)
        local legs = 0
        local stuckBoost = 0
        while os.clock() < deadline and Hub.Alive and legs < 60 and Hub._TravelSeq == mySeq do
            local root = GetRootPart()
            local hum = GetHumanoid()
            if not root or not hum then break end
            local remaining = targetPos - root.Position
            local horiz = Vector3.new(remaining.X, 0, remaining.Z).Magnitude
            if horiz < 25 then break end
            local groundHere = FlyGroundAt(root.Position)
            -- FIX anti-climb infini : base = terrain connu (jamais Y actuel,
            -- sinon cruise = Y+150 a chaque boucle et le perso monte sans fin).
            local baseY = targetPos.Y
            if destGround and destGround.Y > baseY then baseY = destGround.Y end
            if groundHere and groundHere.Y > baseY then baseY = groundHere.Y end
            -- Echantillonne le relief sur le trajet (sommets) pour ne pas
            -- se faire enterrer dans une montagne en chemin.
            for _, f in ipairs({ 0.25, 0.5, 0.75 }) do
                local px = root.Position.X + (targetPos.X - root.Position.X) * f
                local pz = root.Position.Z + (targetPos.Z - root.Position.Z) * f
                local okT, ty = pcall(function()
                    local r = workspace:Raycast(Vector3.new(px, 2600, pz), Vector3.new(0, -4500, 0))
                    return r and r.Position.Y or nil
                end)
                if okT and ty and ty > baseY then baseY = ty end
            end
            local cruiseY = baseY + FLY_CRUISE_EXTRA + stuckBoost
            if cruiseY > 2400 then cruiseY = 2400 end
            if cruiseY < -200 then cruiseY = -200 end
            if root.Position.Y < cruiseY - 30 then
                -- Montee verticale rapide vers l'altitude de croisiere
                local upDest = Vector3.new(root.Position.X, cruiseY, root.Position.Z)
                local upD = FlyLeg(upDest, math.max(0.5, (cruiseY - root.Position.Y) / 220))
                legs = legs + 1
                if upD == false then break end
                root = GetRootPart()
                if not root then break end
            end
            -- Approche finale : on plonge vers la cible des qu'on est au-dessus.
            local goalY = cruiseY
            if horiz < 140 then goalY = targetPos.Y + 6 end
            local goal = Vector3.new(targetPos.X, goalY, targetPos.Z)
            local hop = goal - root.Position
            if hop.Magnitude > FLY_LEG_MAX then
                hop = hop.Unit * FLY_LEG_MAX
            end
            local d0 = FlyLeg(root.Position + hop, hop.Magnitude / FLY_SPEED)
            legs = legs + 1
            if d0 == false then break end
            if d0 ~= nil and d0 > 140 then
                -- Leg fortement devie (pull serveur ou relief) : on releve
                -- la croisiere pour passer au-dessus.
                stuckBoost = math.min(stuckBoost + 120, 600)
                task.wait(0.25)
            end
        end
        -- Descente finale snappee au sol / cible
        local root = GetRootPart()
        if root then
            local land = FlyGroundAt(targetPos) or targetPos
            local drop = Vector3.new(targetPos.X, land.Y + 3, targetPos.Z)
            if (drop - root.Position).Magnitude > 12 then
                FlyLeg(drop, math.max(0.6, (drop - root.Position).Magnitude / FLY_SPEED))
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.7)
        end
        local r2 = GetRootPart()
        if name and r2 and (r2.Position - targetPos).Magnitude < 60 then
            Kyoka:Notify({ Title = "Travel", Content = "Arrived at: " .. name, Type = "success", Duration = 3 })
        end
        if Hub._TravelSeq == mySeq then Hub._WalkJob = nil end
    end)
end

local function TeleportToPosition(targetPos, name)
    local root = GetRootPart()
    if not root then return end
    local dist = (targetPos - root.Position).Magnitude
    if dist <= MICRO_HOP_STUDS then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        EnsureFarmPlatform(root.CFrame)
        if name then
            Kyoka:Notify({ Title = "Teleport", Content = "Arrived at: " .. name, Type = "success", Duration = 3 })
        end
        return
    end
    -- Meme zone (ou cible proche) : marche directe. Evite un detour shrine
    -- absurde pour les boss/mobs de la region courante.
    local sameArea = dist <= 1200
    if not sameArea then
        local pa = NWGetAreaName(root.Position)
        local ta = NWGetAreaName(targetPos)
        sameArea = (pa ~= nil and ta ~= nil and pa == ta)
    end
    if sameArea then
        if name then
            Kyoka:Notify({ Title = "Travel", Content = "En route vers " .. name .. " (fly)..." , Type = "info", Duration = 3 })
        end
        FlyTravelTo(targetPos, name)
        return
    end
    local shrine = NearestShrineTravel(targetPos)
    local traveled = ServerTravelToShrine(shrine)
    local r2 = GetRootPart()
    if r2 and (targetPos - r2.Position).Magnitude <= 60 then
        if name then
            Kyoka:Notify({ Title = "Travel", Content = "Arrived at: " .. name .. " (shrine)", Type = "success", Duration = 3 })
        end
        return
    end
    if name then
        local how = traveled and "Travel serveur + fly" or "Fly"
        Kyoka:Notify({ Title = "Travel", Content = how .. " vers " .. name .. "..." , Type = "info", Duration = 3 })
    end
    FlyTravelTo(targetPos, name)
end

--=====================================================================
-- Système Auto Quest & Progression XP
--=====================================================================
-- Système Auto Quest & Progression XP (Architecture Serveur Intégrale)
--=====================================================================
local QuestDatabase = {
    {
        Name = "Ill take 3 bandits",
        DisplayName = "Bandits (Lv 0+)",
        QuestInstanceName = "Defeat 3 bandits",
        MinLevel = 0,
        Category = "Normal",
        Region = "Windy Peak",
        Race = "Any",
        NPC = "Krue",
        MobName = "Bandit",
        MobWp = Vector3.new(-297, 1224, -1023),
        Tasks = { ["Bandits remaining"] = "Bandit" }
    },
    {
        Name = "Ill take the bandit boss(Lv 7)",
        DisplayName = "Zuko (Boss Lv 7+)",
        QuestInstanceName = "Defeat The Bandit Boss",
        MinLevel = 7,
        Category = "Boss",
        Region = "Windy Peak",
        Race = "Any",
        NPC = "Krue",
        MobName = "Zuko",
        MobWp = Vector3.new(-297, 1224, -1023),
        Tasks = { ["Defeat Zuko"] = "Zuko" }
    },
    {
        Name = "Ill drive the bears back(Lv 10)",
        DisplayName = "Bear Cubs (Lv 10+)",
        QuestInstanceName = "Hunt the Bears",
        MinLevel = 10,
        Category = "Normal",
        Region = "Bamboo Grove",
        Race = "Any",
        NPC = "Tom",
        MobName = "Bear Cub",
        MobWp = Vector3.new(540, 1121, -1024),
        Tasks = { ["Bear Cubs hunted"] = "Bear Cub" }
    },
    {
        Name = "Ill fell the Mother Bear(Lv 18)",
        DisplayName = "Mother Bear (Lv 18+)",
        QuestInstanceName = "Fell the Mother Bear",
        MinLevel = 18,
        Category = "Normal",
        Region = "Bamboo Grove",
        Race = "Any",
        NPC = "Tom",
        MobName = "Mother Bear",
        MobWp = Vector3.new(540, 1121, -1024),
        Tasks = { ["Fell the Mother Bear"] = "Mother Bear" }
    },
    {
        Name = "Ill clear out his subordinates(Lv 26)",
        DisplayName = "Kaiden Subordinates (Lv 26+)",
        QuestInstanceName = "Clear Kaiden's Subordinates",
        MinLevel = 26,
        Category = "Normal",
        Region = "Bamboo Grove",
        Race = "Any",
        NPC = "Chaka",
        MobName = "Kaiden Subordinate",
        MobWp = Vector3.new(585, 1146, -1315),
        Tasks = { ["Subordinates defeated"] = "Kaiden Subordinate" }
    },
    {
        Name = "Ill deal with Kaiden(Lv 34)",
        DisplayName = "Kaiden (Boss Lv 34+)",
        QuestInstanceName = "Defeat Kaiden",
        MinLevel = 34,
        Category = "Boss",
        Region = "Bamboo Grove",
        Race = "Any",
        NPC = "Chaka",
        MobName = "Kaiden",
        MobWp = Vector3.new(585, 1146, -1315),
        Tasks = { ["Defeat Kaiden"] = "Kaiden" }
    },
    {
        Name = "I will clear out his guards(Lv 40)",
        DisplayName = "Hoyuzo Guards (Lv 40+)",
        QuestInstanceName = "Clear Hoyuzo's Guard",
        MinLevel = 40,
        Category = "Normal",
        Region = "Bamboo Grove",
        Race = "Any",
        NPC = "Wagwan",
        MobName = "Hoyuzo Subordinate",
        MobWp = Vector3.new(533, 1001, -1357),
        Tasks = { ["Guards defeated"] = "Hoyuzo Subordinate" }
    },
    {
        Name = "Ill drive them off(Lv 47)",
        DisplayName = "Beast Born Demons (Lv 47+)",
        QuestInstanceName = "Hold the Night",
        MinLevel = 47,
        Category = "Normal",
        Region = "Mistfall Harbor",
        Race = "Any",
        NPC = "Rin",
        MobName = "Beast Born Demon",
        MobWp = Vector3.new(170, 888, 603),
        Tasks = { ["Beast Born Demons defeated"] = "Beast Born Demon" }
    },
    {
        Name = "I will take care of Hoyuzo(Lv 50)",
        DisplayName = "Hoyuzo (Boss Lv 50+)",
        QuestInstanceName = "Defeat Hoyuzo",
        MinLevel = 50,
        Category = "Boss",
        Region = "Bamboo Grove",
        Race = "Any",
        NPC = "Wagwan",
        MobName = "Hoyuzo",
        MobWp = Vector3.new(746, 1001, -1413),
        Tasks = { ["Defeat Hoyuzo"] = "Hoyuzo" }
    },
    {
        Name = "Ill clear the cave(Lv 62)",
        DisplayName = "Blood Hounded Demons (Lv 62+)",
        QuestInstanceName = "Purge Dreamfall Hollow",
        MinLevel = 62,
        Category = "Normal",
        Region = "Mistfall Harbor",
        Race = { "Slayer", "Hybrid" },
        NPC = "Jugg",
        MobName = "Blood Hounded Demon",
        MobWp = Vector3.new(789, 829, 927),
        Tasks = { ["Blood Hounded Demons defeated"] = "Blood Hounded Demon" }
    },
    {
        Name = "Ill eliminate the Mizunoto(Lv 62)",
        DisplayName = "Mizunoto Slayers (Lv 62+)",
        QuestInstanceName = "Eliminate the Mizunoto",
        MinLevel = 62,
        Category = "Normal",
        Region = "Mistfall Harbor",
        Race = { "Demon", "Hybrid" },
        NPC = "Shady Individual Rooyi",
        MobName = "Mizunoto",
        MobWp = Vector3.new(-834, 964, -76),
        Tasks = { ["Broken Nichirin Katanas"] = "Mizunoto" }
    },
    {
        Name = "Ill thin them out(Lv 75)",
        DisplayName = "Lesser Demons (Lv 75+)",
        QuestInstanceName = "Thin the Cavern Floor",
        MinLevel = 75,
        Category = "Normal",
        Region = "Butterfly Estate",
        Race = { "Slayer", "Hybrid" },
        NPC = "Demon Slayer Goro",
        MobName = "Lesser Demon",
        MobWp = Vector3.new(-675, 230, 397),
        Tasks = { ["Lesser Demons defeated"] = "Lesser Demon" }
    },
    {
        Name = "Ill break their watch(Lv 75)",
        DisplayName = "Mizunoe Slayers (Lv 75+)",
        QuestInstanceName = "Break Their Watch",
        MinLevel = 75,
        Category = "Normal",
        Region = "Final Selection Plains",
        Race = { "Demon", "Hybrid" },
        NPC = "Demon Mokuro",
        MobName = "Mizunoe Demon Slayer",
        MobWp = Vector3.new(-1835, 31, 487),
        Tasks = { ["Mizunoe Demon Slayers defeated"] = "Mizunoe Demon Slayer" }
    },
    {
        Name = "Ill go up after the greater ones(Lv 83)",
        DisplayName = "Greater Demons (Lv 83+)",
        QuestInstanceName = "Hunt the Greater Demons",
        MinLevel = 83,
        Category = "Normal",
        Region = "Butterfly Estate",
        Race = { "Slayer", "Hybrid" },
        NPC = "Demon Slayer Goro",
        MobName = "Greater Demon",
        MobWp = Vector3.new(-498, 284, 528),
        Tasks = { ["Greater Demons defeated"] = "Greater Demon" }
    },
    {
        Name = "Ill help you defeat them(Lv 90)",
        DisplayName = "High Demons (Lv 90+)",
        QuestInstanceName = "Drive Off the High Demons",
        MinLevel = 90,
        Category = "Normal",
        Region = "Iceveil Valley",
        Race = { "Slayer", "Hybrid" },
        NPC = "Wounded Slayer Tomoi",
        MobName = "High Demon",
        MobWp = Vector3.new(388, 1253, -1928),
        Tasks = { ["High Demons defeated"] = "High Demon" }
    },
    {
        Name = "Theyre not welcome here(Lv 90)",
        DisplayName = "Kanoe Slayers (Lv 90+)",
        QuestInstanceName = "They're Not Welcome Here",
        MinLevel = 90,
        Category = "Normal",
        Region = "Iceveil Valley",
        Race = { "Demon", "Hybrid" },
        NPC = "Demon Delroy",
        MobName = "Kanoe Demon Slayer",
        MobWp = Vector3.new(283, 1302, -2042),
        Tasks = { ["Kanoe Demon Slayers defeated"] = "Kanoe Demon Slayer" }
    },
    {
        Name = "Ill drive back the frost(Lv 105)",
        DisplayName = "Ice Profound Demons (Lv 105+)",
        QuestInstanceName = "Drive Back the Frost",
        MinLevel = 105,
        Category = "Normal",
        Region = "Iceveil Valley",
        Race = "Any",
        NPC = "Demon Slayer Mitsu",
        MobName = "Ice Profound Demon",
        MobWp = Vector3.new(-920, 1381, -2448),
        Tasks = { ["Ice Profound Demons defeated"] = "Ice Profound Demon" }
    },
    {
        Name = "Ill put out the blaze(Lv 115)",
        DisplayName = "Fire Profound Demons (Lv 115+)",
        QuestInstanceName = "Put Out the Blaze",
        MinLevel = 115,
        Category = "Normal",
        Region = "Iceveil Valley",
        Race = "Any",
        NPC = "Demon Slayer Mitsu",
        MobName = "Fire Profound Demon",
        MobWp = Vector3.new(-916, 1374, -2431),
        Tasks = { ["Fire Profound Demons defeated"] = "Fire Profound Demon" }
    }
}

local function GetPlayerRace()
    local race = nil
    pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        local curSlot, accountData = Utility.GetData(LocalPlayer, true)
        if curSlot and curSlot:FindFirstChild("Race") and tostring(curSlot.Race.Value) ~= "" then
            race = tostring(curSlot.Race.Value)
        elseif accountData and accountData:FindFirstChild("Race") and tostring(accountData.Race.Value) ~= "" then
            race = tostring(accountData.Race.Value)
        end
    end)
    if not race then
        pcall(function()
            local Utility = require(ReplicatedStorage.CAM.Global.Utility)
            local curSlot, accountData = Utility.GetData(LocalPlayer, false)
            local r = (curSlot and curSlot:FindFirstChild("Race")) or (accountData and accountData:FindFirstChild("Race"))
            if r and tostring(r.Value) ~= "" then race = tostring(r.Value) end
        end)
    end
    if not race then
        pcall(function()
            local folder = GetPlayerDataFolder()
            local r = folder and folder:FindFirstChild("Race")
            if r and tostring(r.Value) ~= "" then race = tostring(r.Value) end
        end)
    end
    if not race then
        pcall(function()
            local ps = ReplicatedStorage:FindFirstChild("Player_Service")
            local data = ps and ps:FindFirstChild("Data")
            local myData = data and data:FindFirstChild(LocalPlayer.Name)
            if myData then
                local slots = myData:FindFirstChild("slots")
                local slotEquipped = myData:FindFirstChild("slotEquipped")
                local slotNum = slotEquipped and tostring(slotEquipped.Value) or "1"
                local slot = slots and (slots:FindFirstChild("Slot" .. slotNum) or slots:FindFirstChild(slotNum) or slots:GetChildren()[1])
                local r = (slot and slot:FindFirstChild("Race")) or myData:FindFirstChild("Race")
                if r and tostring(r.Value) ~= "" then race = tostring(r.Value) end
            end
        end)
    end
    return race or "Slayer"
end

local function GetPlayerLevel()
    local success, lvl = pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
        local curSlot, accountData = Utility.GetData(LocalPlayer, true)
        local expFolder = (curSlot and curSlot:FindFirstChild("Exp")) or (accountData and accountData:FindFirstChild("Exp"))
        if expFolder and expFolder:FindFirstChild("Goal") then
            local expPerLevel = gameSettings and gameSettings.expPerLevel or 60
            return math.floor(expFolder.Goal.Value / expPerLevel)
        end
    end)
    if success and type(lvl) == "number" and lvl > 0 then
        return lvl
    end
    return 1
end

-- Exigences OFFICIELLES du jeu (Race / Level / MaxLevel) lues dans Quests.Holder.
-- Indispensable pour l'Auto Quest : un Demon ne peut pas prendre les quetes
-- Slayer (et inversement), donc on filtre avec les vraies regles du serveur.
Hub.GetLiveQuestRequirements = function(questKey)
    if type(questKey) ~= "string" or questKey == "" then return nil end
    if not Hub._LiveQuestReqCache then Hub._LiveQuestReqCache = {} end
    local cache = Hub._LiveQuestReqCache
    local cached = cache[questKey]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end
    local req = nil
    pcall(function()
        local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
        local q = Quests.Holder and Quests.Holder[questKey]
        if q and type(q.Requirements) == "table" then
            req = {}
            for k, v in pairs(q.Requirements) do req[k] = v end
        end
    end)
    cache[questKey] = req or false
    return req
end

Hub.QuestMeetsLiveRequirements = function(qDef)
    if not qDef then return true end
    local req = nil
    for _, candidate in ipairs({ qDef.Name, qDef.QuestString, qDef.QuestInstanceName }) do
        if type(candidate) == "string" then
            local r = Hub.GetLiveQuestRequirements(candidate)
            if r then
                req = r
                break
            end
        end
    end
    if not req then return true end
    local level = GetPlayerLevel()
    if type(req.Level) == "number" and level < req.Level then return false end
    if type(req.MaxLevel) == "number" and level > req.MaxLevel then return false end
    if req.Race ~= nil then
        local myRace = tostring(GetPlayerRace())
        local ok = false
        if type(req.Race) == "table" then
            for _, r in pairs(req.Race) do
                if tostring(r) == myRace then ok = true break end
            end
        else
            ok = (tostring(req.Race) == myRace)
        end
        if not ok then return false end
    end
    return true
end

local function GetNpcPosition(npcName)
    if not npcName then return nil, nil end

    -- 1. Check in Workspace.Debree.Regions and Workspace.Humanoids.Regions
    local debree = Workspace:FindFirstChild("Debree")
    local regions = debree and debree:FindFirstChild("Regions")
    if regions then
        for _, r in ipairs(regions:GetChildren()) do
            local stat = r:FindFirstChild("StationaryNpcs")
            local act = r:FindFirstChild("ActiveNpcs")
            local npcModel = (stat and stat:FindFirstChild(npcName)) or (act and act:FindFirstChild(npcName))
            if npcModel then
                local hrp = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Torso") or npcModel.PrimaryPart
                if hrp then return hrp.Position, npcModel end
            end
        end
    end

    local humanoids = Workspace:FindFirstChild("Humanoids")
    local hRegions = humanoids and humanoids:FindFirstChild("Regions")
    if hRegions then
        for _, r in ipairs(hRegions:GetChildren()) do
            local stat = r:FindFirstChild("StationaryNpcs")
            local act = r:FindFirstChild("ActiveNpcs")
            local npcModel = (stat and stat:FindFirstChild(npcName)) or (act and act:FindFirstChild(npcName))
            if npcModel then
                local hrp = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChild("Torso") or npcModel.PrimaryPart
                if hrp then return hrp.Position, npcModel end
            end
        end
    end

    -- 2. Fallback via ReplicatedStorage.Regions.GetNpcSpawn
    local ok, pos = pcall(function()
        local Regions = require(ReplicatedStorage.Regions)
        if Regions.GetNpcSpawn then
            return Regions.GetNpcSpawn(npcName)
        end
    end)
    if ok and typeof(pos) == "Vector3" then
        return pos, nil
    end

    -- 3. Static fallback table for all known quest NPCs
    local staticNpcSpawns = {
        ["Krue"] = Vector3.new(-425.5, 1243.5, -952.5),
        ["Tom"] = Vector3.new(540.0, 1121.0, -1024.0),
        ["Chaka"] = Vector3.new(585.0, 1146.0, -1315.0),
        ["Wagwan"] = Vector3.new(723.8, 1019.2, -802.0),
        ["Rin"] = Vector3.new(170.0, 888.0, 603.0),
        ["Jugg"] = Vector3.new(487.7, 874.1, 1007.8),
        ["Shady Individual Rooyi"] = Vector3.new(-834.0, 964.0, -76.0),
        ["Demon Slayer Goro"] = Vector3.new(-872.0, 234.8, 318.5),
        ["Demon Mokuro"] = Vector3.new(-1835.0, 31.0, 487.0),
        ["Wounded Slayer Tomoi"] = Vector3.new(485.3, 1222.6, -1813.0),
        ["Demon Delroy"] = Vector3.new(283.0, 1302.0, -2042.0),
        ["Demon Slayer Mitsu"] = Vector3.new(-824.3, 1381.5, -2537.8),
    }
    return staticNpcSpawns[npcName], nil
end

local function GetActiveQuest()
    local success, res = pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        local curSlot, accountData = Utility.GetData(LocalPlayer, true)
        local questFolder = (curSlot and curSlot:FindFirstChild("Quests")) or (accountData and accountData:FindFirstChild("Quests"))
        local holder = questFolder and questFolder:FindFirstChild("Holder")
        if not holder then return nil end

        local bestQuest = nil
        for _, q in ipairs(holder:GetChildren()) do
            local qStr = q:FindFirstChild("QuestString") and q.QuestString.Value or q.Name
            local tasks = {}
            local isFinished = true
            local hasAnyTask = false
            if q:FindFirstChild("Tasks") then
                for _, t in ipairs(q.Tasks:GetChildren()) do
                    hasAnyTask = true
                    local v = t:FindFirstChild("Value") and t.Value.Value or 0
                    local m = t:FindFirstChild("Max") and t.Max.Value or 1
                    tasks[t.Name] = { Current = v, Max = m }
                    if v < m then
                        isFinished = false
                    end
                end
            end

            local qObj = {
                Name = q.Name,
                QuestString = qStr,
                Tasks = tasks,
                Finished = hasAnyTask and isFinished,
                IsFinished = hasAnyTask and isFinished,
                HasTasks = hasAnyTask,
                Instance = q
            }

            -- Prioriser les quêtes avec des tâches réelles actives
            if hasAnyTask and not isFinished then
                return qObj
            elseif hasAnyTask then
                bestQuest = qObj
            elseif not bestQuest then
                bestQuest = qObj
            end
        end
        return bestQuest
    end)
    return success and res or nil
end

local function CancelCurrentQuest()
    local active = GetActiveQuest()
    local cancelled = false
    if active then
        pcall(function()
            local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
            SignalEvent.ToServer("RemoveQuest", active.Name)
            if active.QuestString and active.QuestString ~= active.Name then
                SignalEvent.ToServer("RemoveQuest", active.QuestString)
            end
        end)
        pcall(function()
            local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
            Quests.DeleteQuest(LocalPlayer, active.Instance or active.Name)
        end)
        cancelled = true
    end

    -- Nettoyer tout résidu client orphelin sans tâches serveur
    pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        local curSlot = Utility.GetData(LocalPlayer, true)
        local holder = curSlot and curSlot:FindFirstChild("Quests") and curSlot.Quests:FindFirstChild("Holder")
        if holder then
            for _, q in ipairs(holder:GetChildren()) do
                if not q:FindFirstChild("Tasks") or #q.Tasks:GetChildren() == 0 then
                    pcall(function() q:Destroy() end)
                end
            end
        end
    end)
    return cancelled
end

local function IsQuestAvailable(qDef)
    if not qDef then return false end
    local pRace = GetPlayerRace()
    if qDef.Race and qDef.Race ~= "Any" then
        if type(qDef.Race) == "table" then
            local found = false
            for _, r in ipairs(qDef.Race) do
                if r == pRace then found = true break end
            end
            if not found then return false end
        elseif type(qDef.Race) == "string" and qDef.Race ~= pRace then
            return false
        end
    end
    if not Hub.QuestMeetsLiveRequirements(qDef) then return false end
    return true
end

local lastQuestAttempt = 0
local lastTurnInAttempt = 0
local IsTurningInQuest = false

-- Cooldown officiel du jeu entre deux acceptations de quête (Quests.QuestCD)
local function GetQuestCooldownRemaining()
    local remaining = 0
    pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
        local curSlot = Utility.GetData(LocalPlayer, true)
        local lastTime = curSlot and curSlot:FindFirstChild("Quests") and curSlot.Quests:FindFirstChild("LastTime")
        if lastTime then
            local nowTick = Utility.Tick and Utility.Tick() or os.time()
            local cd = Quests.QuestCD or 30
            remaining = math.max(0, cd - (nowTick - lastTime.Value))
        end
    end)
    return remaining
end

local function CloseOfficialDialogue()
    pcall(function()
        local DialogueUtility = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.DialogueUtility)
        DialogueUtility.Close()
    end)
    pcall(function()
        local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
        Dialogue.CurrentDialogue.Current = nil
        if Dialogue.CurrentDialogue.Cancel then
            Dialogue.CurrentDialogue.Cancel:Fire()
        end
    end)
end

-- Clics/GUI compatibles tous executeurs : on privilégie de vrais inputs souris
-- (VirtualInputManager) au lieu de firesignal, qui fait planter certains
-- executeurs ("flying"/"real") au point de fermer le jeu.
Hub.WithGameUiVisible = function(fn)
    local gui = Kyoka and Kyoka.ScreenGui
    local wasEnabled = nil
    if gui then
        wasEnabled = gui.Enabled
        pcall(function() gui.Enabled = false end)
    end
    local ok = pcall(fn)
    if gui and wasEnabled ~= nil then
        task.wait(0.08)
        pcall(function() gui.Enabled = wasEnabled end)
    end
    return ok
end

Hub.ClickGuiButton = function(btn)
    if not btn or not btn.Parent then return false end
    local clicked = false
    if VirtualInputManager then
        Hub.WithGameUiVisible(function()
            local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
            task.wait(0.04)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            clicked = true
        end)
    end
    if clicked then return true end
    if NW_NoFiresignal then return false end
    local ok1 = pcall(function() firesignal(btn.MouseButton1Click) end)
    local ok2 = pcall(function() firesignal(btn.Activated) end)
    return ok1 or ok2
end

Hub.FireClickDetectorSafe = function(cd)
    if not cd or not cd.Parent then return false end
    if type(fireclickdetector) == "function" then
        local ok = pcall(function() fireclickdetector(cd) end)
        if ok then return true end
    end
    local parent = cd.Parent
    if parent and VirtualInputManager then
        local screenPos, onScreen = nil, false
        if parent:IsA("BasePart") then
            local cam = Workspace.CurrentCamera
            if cam then
                screenPos, onScreen = cam:WorldToViewportPoint(parent.Position)
            end
        elseif parent:IsA("GuiObject") then
            screenPos = parent.AbsolutePosition + (parent.AbsoluteSize / 2)
            onScreen = true
        end
        if screenPos and onScreen then
            local ok = Hub.WithGameUiVisible(function()
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                task.wait(0.04)
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
            end)
            if ok then return true end
        end
    end
    if NW_NoFiresignal then return false end
    return pcall(function() firesignal(cd.MouseButton1Click) end)
end

-- Certains executeurs (Potassium, etc.) bloquent les ecritures GUI depuis les
-- threads de signaux (Heartbeat) : "cannot access 'Instance' (lacking
-- capability Plugin)". On passe donc par une file traitee par un thread
-- cree au chargement du script (celui-ci a toutes les capacites).
-- IMPORTANT : le callback ne doit QUE ecrire du texte deja calcule (ne pas
-- appeler de fonctions de lecture du jeu dedans : sous l'identite 8 les
-- lectures d'instances peuvent etre bloquees selon l'executeur).
Hub.GuiWrite = function(fn)
    if type(setthreadidentity) == "function" then
        local old = 8
        pcall(function() old = getthreadidentity() or 8 end)
        pcall(setthreadidentity, 8)
        local ok, err = pcall(fn)
        pcall(setthreadidentity, old)
        return ok, err
    end
    return pcall(fn)
end

Hub.FirePromptSafe = function(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Parent then return false end
    local fired = pcall(function() fireproximityprompt(prompt) end)
    if fired then return true end
    local key = prompt.KeyboardKeyCode
    if key and key ~= Enum.KeyCode.Unknown and VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
        return true
    end
    return false
end

-- Reponse de dialogue 100% fiable : on rejoue EXACTEMENT ce que fait le clic
-- du bouton du jeu (DialogueUtility.DoAll(valeur, cle)) au lieu de dependre
-- d'un clic souris qui peut rater selon l'executeur / l'inset du GUI.
Hub.AnswerDialogueDirect = function(label, matcher)
    local answered = false
    pcall(function()
        local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
        local DialogueUtility = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.DialogueUtility)
        local nodeName = Dialogue.CurrentDialogue and Dialogue.CurrentDialogue.Current
        local def = nodeName and Dialogue.Diagloues and Dialogue.Diagloues[nodeName]
        local answers = def and def.Answers
        local value, chosenKey = nil, nil
        local function norm(s)
            local low = string.lower(tostring(s or ""))
            local compact = string.gsub(low, "%s+", "")
            return string.gsub(compact, "%(%s*lv%s*%d+%s*%)", "")
        end
        if type(answers) == "table" then
            for k, v in pairs(answers) do
                if type(k) == "string" and k == label then
                    value, chosenKey = v, k
                    break
                end
            end
            if value == nil then
                for k, v in pairs(answers) do
                    if type(k) == "string" and matcher then
                        if matcher(k) or matcher(norm(k)) then
                            value, chosenKey = v, k
                            break
                        end
                    end
                end
            end
        end
        if value == nil and matcher then
            pcall(function()
                local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
                for key in pairs(Quests.Holder) do
                    if matcher(key) or matcher(norm(key)) then
                        value, chosenKey = "AddQuest", key
                        break
                    end
                end
            end)
        end
        if value ~= nil and value ~= false then
            DialogueUtility.DoAll(value, chosenKey or label)
            answered = true
        end
    end)
    return answered
end

-- Flux de dialogue officiel partagé : téléportation devant le PNJ, prompt,
-- avancée des bulles puis clic sur la réponse validée par le serveur.
-- `matcher(name)` doit retourner true pour la réponse à cliquer.
local function RunNpcDialogue(npcName, matcher, maxWait)
    local npcPos, npcModel = GetNpcPosition(npcName)
    if not npcPos then
        pcall(function()
            local Regions = require(ReplicatedStorage.Regions)
            local raw = Regions.GetNpcSpawn(npcName)
            if typeof(raw) == "Vector3" then
                npcPos = raw
            elseif typeof(raw) == "CFrame" then
                npcPos = raw.Position
            end
        end)
    end
    if not npcPos then return false, false, "npc_not_found" end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false, false, "no_character" end

    Hub.IsInteractingQuest = true
    RemoveFarmPlatform()

    -- 1. Téléportation devant le PNJ (validation de proximité serveur)
    local approachPos = npcPos + Vector3.new(0, 2, 3)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = CFrame.new(approachPos, npcPos)
    EnsureFarmPlatform(root.CFrame)

    pcall(function()
        local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
        AreaLocator:Update(root)
    end)

    -- 2. Attendre que le PNJ soit streamé (map streaming) avant de tirer le prompt
    local streamDeadline = os.clock() + 3.0
    while os.clock() < streamDeadline do
        if npcModel and npcModel.Parent then break end
        local p2, m2 = GetNpcPosition(npcName)
        if m2 then
            npcModel = m2
            npcPos = p2 or npcPos
            break
        end
        task.wait(0.15)
    end

    -- 3. Tirer le ProximityPrompt (avec relance si le dialogue n'apparaît pas)
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local function GetDialogueParts()
        local comp = PlayerGui and PlayerGui:FindFirstChild("ComponentsHolder")
        local df = comp and comp:FindFirstChild("DialogueFrame")
        local actual = df and df:FindFirstChild("Actual")
        local bh = actual and actual:FindFirstChild("ButtonHolder")
        return bh, actual
    end

    local function FireNpcPrompt()
        local prompt = nil
        if npcModel and npcModel.Parent then
            prompt = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
        if not prompt then
            local _, foundModel = GetNpcPosition(npcName)
            if foundModel then
                npcModel = foundModel
                prompt = foundModel:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
        end
        if prompt then
            return Hub.FirePromptSafe(prompt)
        end
        return false
    end

    FireNpcPrompt()
    task.wait(0.35)

    -- 4. Boucle UI : avancer les bulles puis cliquer la réponse attendue
    local uiDeadline = os.clock() + (maxWait or 9.0)
    local lastAdvance = 0
    local sawDialogueUI = false
    local dialogueGoneAt = nil
    local clickedViaUI = false
    local retriedPrompt = false

    while os.clock() < uiDeadline do
        local bh, actual = GetDialogueParts()
        if bh then
            sawDialogueUI = true
            dialogueGoneAt = nil
            local target = nil
            local seen = {}
            local function matchesAny(s)
                if type(s) ~= "string" or s == "" then return false end
                if matcher(s) then return true end
                local low = string.lower(s)
                local compact = string.gsub(low, "%s+", "")
                local noLv = string.gsub(compact, "%(%s*lv%s*%d+%s*%)", "")
                if low ~= s and matcher(low) then return true end
                if compact ~= "" and matcher(compact) then return true end
                if noLv ~= "" and matcher(noLv) then return true end
                return false
            end
            for _, c in ipairs(bh:GetChildren()) do
                table.insert(seen, c.Name)
                if matchesAny(c.Name) then
                    target = c
                elseif c:IsA("GuiObject") then
                    for _, lbl in ipairs(c:GetDescendants()) do
                        if lbl:IsA("TextLabel") and lbl.Text and lbl.Text ~= "" and matchesAny(lbl.Text) then
                            target = c
                            break
                        end
                    end
                end
                if target then break end
            end
            Hub.Farm._LastDialogueButtons = seen
            if target then
                local btn = target:FindFirstChildWhichIsA("TextButton", true)
                if btn then
                    Hub.ClickGuiButton(btn)
                    clickedViaUI = true
                end
                task.wait(0.05)
                Hub.AnswerDialogueDirect(target.Name, matcher)
                break
            end

            -- Avancer les noeuds d'intro du dialogue (bulle -> réponses)
            if actual then
                local cd = actual:FindFirstChild("ClickDetector")
                if cd and cd.Visible and (os.clock() - lastAdvance) >= 0.25 then
                    lastAdvance = os.clock()
                    Hub.FireClickDetectorSafe(cd)
                end
            end
        else
            if sawDialogueUI and not dialogueGoneAt then
                dialogueGoneAt = os.clock()
            end
            -- Le dialogue s'est ouvert puis refermé sans la réponse attendue : inutile d'attendre 9s
            if dialogueGoneAt and (os.clock() - dialogueGoneAt) > 1.0 then
                break
            end
            -- Le dialogue n'apparaît pas : relancer le prompt une fois
            if not sawDialogueUI and not retriedPrompt and (os.clock() > uiDeadline - (maxWait or 9.0) + 1.5) then
                retriedPrompt = true
                FireNpcPrompt()
            end
        end
        task.wait(0.2)
    end

    CloseOfficialDialogue()
    task.wait(0.1)
    Hub.IsInteractingQuest = false
    return clickedViaUI, sawDialogueUI
end

local function RequestAddQuest(questKey)
    if Hub.IsInteractingQuest then return false, "Already interacting" end

    local qDef = nil
    for _, q in ipairs(QuestDatabase) do
        if q.Name == questKey or q.DisplayName == questKey then
            qDef = q
            break
        end
    end
    if not qDef then return false, "Quest not in database" end

    -- Vérifier si la quête demandée est déjà active sur le serveur
    local active = GetActiveQuest()
    if active and (active.QuestString == qDef.Name or active.Name == qDef.QuestInstanceName or active.Name == qDef.Name) then
        if not active.IsFinished then
            return true, "Already active"
        end
    end

    local qNameLow = string.lower(qDef.Name)
    local clickedViaUI, sawDialogueUI = RunNpcDialogue(qDef.NPC, function(btnName)
        local bLow = string.lower(btnName)
        return btnName == qDef.Name or string.find(bLow, qNameLow, 1, true) ~= nil
    end, 9.0)

    -- Fallback UNIQUEMENT si aucun dialogue n'est jamais apparu (PNJ sans prompt/dialogue).
    -- Ne jamais doubler avec un signal direct quand le dialogue existe : ca cree une quete
    -- fantome que le serveur ne valide pas (kills non comptes + impossible a abandonner).
    if not clickedViaUI and not sawDialogueUI then
        pcall(function()
            local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
            if Dialogue.Functions and Dialogue.Functions.AddQuest then
                Dialogue.Functions.AddQuest(qDef.Name)
            end
        end)
        pcall(function()
            local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
            SignalEvent.ToServer("AddQuest", qDef.Name)
        end)
    end

    -- Attendre la confirmation officielle du serveur dans curSlot.Quests.Holder
    local added = false
    local deadline = os.clock() + 3.0
    while os.clock() < deadline do
        task.wait(0.1)
        local cur = GetActiveQuest()
        if cur and (cur.QuestString == qDef.Name or cur.Name == qDef.QuestInstanceName or cur.Name == qDef.Name) then
            added = true
            break
        end
    end

    return added
end

-- Remise de quête ("Return to X") auprès du PNJ donneur via le dialogue officiel.
-- Le jeu complète la tâche côté serveur (SignalEvent "QuestProgress") au clic.
local function RequestQuestTurnIn(activeQuest, taskName)
    if IsTurningInQuest or Hub.IsInteractingQuest then return false, "busy" end
    if not activeQuest then return false, "no_quest" end

    local questKey = activeQuest.QuestString
    local npcName = nil
    pcall(function()
        local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
        local info = Quests.Holder[questKey]
        npcName = info and info.OfferNpc
    end)
    if not npcName then
        for _, qDef in ipairs(QuestDatabase) do
            if qDef.Name == questKey or qDef.QuestInstanceName == activeQuest.Name then
                npcName = qDef.NPC
                break
            end
        end
    end
    if not npcName then return false, "npc_unknown" end

    local delivered = false
    pcall(function()
        local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
        local info = Quests.Holder[questKey]
        local spec = info and info.TaskSpecs and info.TaskSpecs[taskName]
        if not (spec and spec.Type == "Deliver" and spec.TargetNpc) then return end

        local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
        local DialogueUtility = require(ReplicatedStorage.CAM.Client.Components.Client.DialogueComponent.DialogueUtility)

        local npcLast = string.lower(tostring(spec.TargetNpc):match("(%S+)$") or "")
        local itemTail = ""
        if spec.RequiredItem then
            itemTail = string.lower(tostring(spec.RequiredItem)):match("(%a+)%s*$") or ""
        end

        local fnKey = nil
        for key in pairs(Dialogue.Functions) do
            local kl = string.lower(key)
            if string.find(kl, "deliver", 1, true) and (npcLast == "" or string.find(kl, npcLast, 1, true)) then
                if itemTail == "" or string.find(kl, itemTail, 1, true) then
                    fnKey = key
                    break
                end
            end
        end
        if not fnKey then return end

        local label = taskName
        for _, d in pairs(Dialogue.Diagloues) do
            local a = d.Answers
            if type(a) == "table" then
                for lbl, val in pairs(a) do
                    if val == fnKey or (type(val) == "table" and table.find(val, fnKey)) then
                        label = tostring(lbl)
                        break
                    end
                end
            end
            if label ~= taskName then break end
        end

        local npcPos = GetNpcPosition(spec.TargetNpc) or GetNpcPosition(npcName)
        local root = GetRootPart()
        if npcPos and root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = CFrame.new(npcPos + Vector3.new(0, 2, 3), npcPos)
            EnsureFarmPlatform(root.CFrame)
            pcall(function()
                local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
                AreaLocator:Update(root)
            end)
            task.wait(0.3)
        end

        DialogueUtility.DoAll(fnKey, label)

        local deadline = os.clock() + 2.5
        while os.clock() < deadline do
            task.wait(0.15)
            local cur = GetActiveQuest()
            if not cur or cur.Name ~= activeQuest.Name then
                delivered = true
                break
            end
        end
    end)

    if delivered then
        return true, true
    end

    IsTurningInQuest = true
    local okCall, clicked, sawDialogue = pcall(RunNpcDialogue, npcName, function(btnName)
        local bLow = string.lower(btnName)
        local tLow = string.lower(taskName)
        if btnName == taskName or string.find(bLow, tLow, 1, true) ~= nil then return true end
        if string.find(bLow, "hand over", 1, true) ~= nil then return true end
        local spec = nil
        pcall(function()
            local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
            local info = Quests.Holder[activeQuest.QuestString]
            spec = info and info.TaskSpecs and info.TaskSpecs[taskName]
        end)
        if spec and spec.RequiredItem then
            local itemLow = string.lower(tostring(spec.RequiredItem))
            local lastWord = itemLow:match("([%a]+)$")
            if lastWord and #lastWord >= 4 and string.find(bLow, lastWord, 1, true) ~= nil then
                return true
            end
        end
        return false
    end, 9.0)
    IsTurningInQuest = false
    if not okCall then return false, "dialogue_error" end

    return clicked, sawDialogue
end

-- Blacklist temporaire des quêtes que le PNJ refuse (prérequis de dialogue non
-- remplis, race, etc.). Évite de boucler indéfiniment sur une quête impossible.
local function IsQuestBlacklisted(questName)
    local untilTime = Hub.Farm.QuestBlacklist and Hub.Farm.QuestBlacklist[questName]
    if not untilTime then return false end
    if os.clock() >= untilTime then
        Hub.Farm.QuestBlacklist[questName] = nil
        Hub.Farm.QuestFailCount[questName] = nil
        return false
    end
    return true
end

local function BlacklistQuest(questName, duration)
    if not Hub.Farm.QuestBlacklist then Hub.Farm.QuestBlacklist = {} end
    Hub.Farm.QuestBlacklist[questName] = os.clock() + (duration or 300)
    Hub.Farm.QuestFailCount[questName] = nil
end

local function ClearQuestBlacklist()
    if Hub.Farm.QuestBlacklist then table.clear(Hub.Farm.QuestBlacklist) end
    if Hub.Farm.QuestFailCount then table.clear(Hub.Farm.QuestFailCount) end
end

local function GetBestQuestForLevel(lvl)
    local best = nil
    local highestMinLvl = -1
    for _, q in ipairs(QuestDatabase) do
        if lvl >= q.MinLevel and q.MinLevel >= highestMinLvl and IsQuestAvailable(q) and not IsQuestBlacklisted(q.Name) then
            highestMinLvl = q.MinLevel
            best = q
        end
    end
    if not best then
        -- Aucune quête du niveau dispo : prendre la première non blacklistée, même plus bas niveau
        for _, q in ipairs(QuestDatabase) do
            if lvl >= q.MinLevel and IsQuestAvailable(q) and not IsQuestBlacklisted(q.Name) then
                best = q
                break
            end
        end
    end
    return best
end

--=====================================================================
-- Helpers : Pêche, Raffinage, Vente & Énigmes (Nightfall)
--=====================================================================

-- Table utilitaire unique : évite d'exploser la limite de 200 registres locaux
-- de Luau sur un script aussi gros (l'erreur "Out of local registers").
local Util = {}
Util.FishItems = {
    ["OuwFish"] = true, ["Sea Horse"] = true, ["Coral"] = true, ["OuwFwesh"] = true,
    ["Clown Fish"] = true, ["Zebra Fish"] = true, ["Golden Fish"] = true, ["Fish Head"] = true,
}
Util.FishingSpots = {
    Vector3.new(141, 1103, -2792),
    Vector3.new(623, 948, -398),
    Vector3.new(2011, 516, -486),
}

do
local FISH_ITEMS = Util.FishItems
local FISHING_SPOTS = Util.FishingSpots

local function GetInventoryFolder()
    local ok, folder = pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        local curSlot = Utility.GetData(LocalPlayer, true)
        local inv = curSlot and curSlot:FindFirstChild("Inventory")
        return inv and inv:FindFirstChild("Inventory")
    end)
    return ok and folder or nil
end

local function GetInventoryList()
    local list = {}
    local inv = GetInventoryFolder()
    if not inv then return list end
    for _, c in ipairs(inv:GetChildren()) do
        local id = c:FindFirstChild("Id")
        local amount = c:FindFirstChild("Amount")
        table.insert(list, { Name = c.Name, Id = id and id.Value or nil, Amount = amount and amount.Value or 1 })
    end
    return list
end

local function GetItemDef(name)
    local defs = ReplicatedStorage:FindFirstChild("Items")
    if not defs then return nil end
    local ok, def = pcall(function()
        local d = defs:FindFirstChild(name, true)
        if d then return require(d) end
    end)
    return (ok and type(def) == "table") and def or nil
end

local function CountFishItems()
    local total = 0
    for _, item in ipairs(GetInventoryList()) do
        if FISH_ITEMS[item.Name] == true then
            total = total + (tonumber(item.Amount) or 0)
        end
    end
    return total
end

local function FindRodItem()
    for _, item in ipairs(GetInventoryList()) do
        if string.find(string.lower(item.Name), "fishing rod", 1, true) then
            return item
        end
    end
    return nil
end

-- Équipe une canne à pêche (toolbar + Items_Config), renvoie le slot
local function EnsureRodEquipped()
    local rod = FindRodItem()
    if not rod or not rod.Id then return nil end
    local data = GetPlayerDataFolder()
    local inventory = data and data:FindFirstChild("Inventory")
    local toolbar = inventory and inventory:FindFirstChild("Toolbar")
    if not toolbar then return nil end

    local slotName = nil
    for _, name in ipairs({ "One", "Two", "Three", "Four", "Five" }) do
        local v = toolbar:FindFirstChild(name)
        if v and v.Value == rod.Id then
            slotName = name
            break
        end
    end
    if not slotName then
        for _, name in ipairs({ "One", "Two", "Three", "Four", "Five" }) do
            local v = toolbar:FindFirstChild(name)
            if v and v.Value == 0 then
                slotName = name
                break
            end
        end
        slotName = slotName or "One"
        pcall(function()
            if SignalEvent then SignalEvent.ToServer("Toolbar_Equip", slotName, rod.Id) end
        end)
        task.wait(0.25)
    end

    local slotNum = ({ One = 1, Two = 2, Three = 3, Four = 4, Five = 5 })[slotName]
    local itemsConfig = LocalPlayer:FindFirstChild("Items_Config")
    if itemsConfig and itemsConfig:FindFirstChild("Equipped") then
        if itemsConfig.Equipped.Value ~= slotNum then
            itemsConfig.Equipped.Value = slotNum
        end
    end
    -- Envoi explicite : si le Toolbar n'a pas (re)connecté son Changed, l'équipement
    -- serveur n'a pas lieu et aucune morsure ne peut arriver (pas de Portal).
    pcall(function()
        if SignalEvent then SignalEvent.ToServer("Item_Equip", slotNum) end
    end)

    -- Équipe automatiquement le MEILLEUR appât dispo (plus haute CatchChance)
    -- si aucun n'est actif. Le Worm (0.05) est un mauvais choix par défaut.
    pcall(function()
        local misc = data:FindFirstChild("Misc")
        local baitId = misc and misc:FindFirstChild("EquippedBaitId")
        if baitId and baitId:IsA("ValueBase") and (baitId.Value == 0 or baitId.Value == nil) then
            local bestId, bestCatch = nil, -1
            for _, item in ipairs(GetInventoryList()) do
                local def = GetItemDef(item.Name)
                if def and def.BaitTier ~= nil and item.Id then
                    local cc = def.FishingStats and tonumber(def.FishingStats.CatchChance) or 0
                    if cc > bestCatch then bestCatch = cc bestId = item.Id end
                end
            end
            if bestId and SignalEvent then
                SignalEvent.ToServer("EquipBait", bestId)
            end
        end
    end)
    return slotNum, rod.Name
end

-- Les parts taggées SwimParts sont des TouchPart avec CanQuery = false : AUCUN
-- raycast ne peut les toucher. On teste donc géométriquement si un point est
-- DANS le volume d'eau (PointToObjectSpace), puis on vérifie juste l'absence
-- d'obstacle au-dessus avec un raycast normal.
local WATER_DIRS = {
    { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 },
    { 0.707, 0.707 }, { -0.707, 0.707 }, { 0.707, -0.707 }, { -0.707, -0.707 },
}

local function GetSwimVolumes()
    local vols = {}
    local cs = game:GetService("CollectionService")
    for _, p in ipairs(cs:GetTagged("SwimParts")) do
        if p:IsA("BasePart") then
            table.insert(vols, p)
        elseif p:IsA("Model") then
            local pp = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart", true)
            if pp then table.insert(vols, pp) end
        end
    end
    return vols
end

local function VolumeSurfacePoint(vol, x, z)
    if not vol or not vol.Parent then return nil end
    local ok, res = pcall(function()
        local half = vol.Size * 0.5
        local lp = vol.CFrame:PointToObjectSpace(Vector3.new(x, vol.Position.Y, z))
        if math.abs(lp.X) > half.X or math.abs(lp.Z) > half.Z then return nil end
        return (vol.CFrame * CFrame.new(
            math.clamp(lp.X, -half.X, half.X),
            half.Y,
            math.clamp(lp.Z, -half.Z, half.Z)
        )).Position
    end)
    if ok then return res end
    return nil
end

local function NearestWaterSurface(myPos, maxRadius)
    local vols = GetSwimVolumes()
    if #vols == 0 then return nil end
    table.sort(vols, function(a, b)
        return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
    end)
    local best, bestDist = nil, math.huge
    for _, vol in ipairs(vols) do
        if (vol.Position - myPos).Magnitude < 600 then
            for radius = 0, maxRadius or 96, 8 do
                for _, dir in ipairs(WATER_DIRS) do
                    local surf = VolumeSurfacePoint(vol, myPos.X + dir[1] * radius, myPos.Z + dir[2] * radius)
                    if surf then
                        local d = (surf - myPos).Magnitude
                        if d < bestDist then bestDist = d best = surf end
                    end
                end
            end
        end
    end
    return best, bestDist
end

local function FindCastableWaterPoint(waterPos, myRoot)
    if not myRoot then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Workspace:FindFirstChild("Debree"), LocalPlayer.Character }

    -- Recherche en grille autour du joueur : le centre d'une flaque peut être
    -- sous un dock (obstrué), l'eau libre est souvent à quelques dizaines de studs.
    local myPos = myRoot.Position
    local vols = GetSwimVolumes()
    if #vols == 0 then return nil end
    table.sort(vols, function(a, b)
        return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude
    end)
    for _, vol in ipairs(vols) do
        if (vol.Position - myPos).Magnitude < 600 then
            for radius = 0, 96, 8 do
                for _, dir in ipairs(WATER_DIRS) do
                    local surf = VolumeSurfacePoint(vol, myPos.X + dir[1] * radius, myPos.Z + dir[2] * radius)
                    if surf then
                        -- Le serveur (findWater) annule le cast si un objet solide
                        -- surplombe la surface au point visé (même de 0.2 stud, ex:
                        -- le mesh de berge au bord de l'eau). On reproduit son test :
                        -- raycast descendant, refus si le premier hit est au-dessus.
                        local hy = math.max(surf.Y, myPos.Y) + 50
                        local obstr = Workspace:Raycast(Vector3.new(surf.X, hy, surf.Z), Vector3.new(0, -(hy - surf.Y + 25), 0), params)
                        if obstr == nil or obstr.Position.Y <= surf.Y then
                            return surf, vol
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function FindWaterPoint(maxDist)
    local myRoot = GetRootPart()
    if not myRoot then return nil, nil end
    local best, bestDist = NearestWaterSurface(myRoot.Position, maxDist or 150)
    if best and bestDist <= (maxDist or 150) then return best, bestDist end
    return nil, bestDist
end

local function CastRod(waterPoint)
    if not SignalEvent or not waterPoint then return false end
    pcall(function() SignalEvent.ToServer("Tool_Mouse", "Down", waterPoint) end)
    task.wait(0.06)
    pcall(function() SignalEvent.ToServer("Tool_Mouse", "Up", waterPoint) end)
    return true
end

-- Trouve un point de BERGE (terre ferme) autour d'un point d'eau : le cast
-- exige d'être au sol (FloorMaterial ~= Air), pas dans l'eau.
local function FindShorePoint(waterPos)
    if not waterPos then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = { LocalPlayer.Character }
    end
    -- La berge doit être AU-DESSUS de la surface : un fond sous-marin (même
    -- solide) laisserait le personnage en nage et le serveur refuserait le cast.
    local best, bestDist = nil, math.huge
    for _, radius in ipairs({ 18, 28, 40, 56, 76, 100, 130, 170 }) do
        for i = 0, 15 do
            local angle = (i / 16) * math.pi * 2
            local probe = waterPos + Vector3.new(math.cos(angle) * radius, 30, math.sin(angle) * radius)
            local hit = Workspace:Raycast(probe, Vector3.new(0, -90, 0), params)
            if hit and hit.Instance and hit.Material ~= Enum.Material.Water then
                if hit.Position.Y > waterPos.Y + 0.5 then
                    local d = (hit.Position - waterPos).Magnitude
                    if d < bestDist then bestDist = d best = hit.Position end
                end
            end
        end
        if best then break end
    end
    return best
end

local function UncastRod(waterPoint)
    if not SignalEvent then return end
    pcall(function() SignalEvent.ToServer("Tool_Mouse", "Up", waterPoint or Vector3.zero) end)
end

-- Le serveur crée un "FishingBobber" (avec RopeConstraint "FishingLine") dans
-- Debree dès qu'un cast est accepté : c'est la preuve que la ligne est à l'eau.
function Util.HasFishingBobber()
    local deb = Workspace:FindFirstChild("Debree")
    if not deb then return false end
    for _, c in ipairs(deb:GetChildren()) do
        -- Sans appât, le flotteur est un Part renommé "FishingLine_<n>" ;
        -- avec appât, c'est un Model contenant un part "FishingBobber".
        if c.Name == "FishingBobber" then return true end
        if string.sub(c.Name, 1, 12) == "FishingLine_" then return true end
        if c:FindFirstChild("FishingBobber") ~= nil then return true end
    end
    return false
end

-- Vérifie qu'on peut caster d'ici (au sol et hors de l'eau) ; sinon rejoint une
-- berge au-dessus de l'eau et recalcule un point d'eau castable depuis celle-ci.
-- Renvoie (peutCaster, pointDEau).
function Util.EnsureCastingSpot(castPoint, myRoot)
    local function canCast()
        local root = GetRootPart()
        if not root then return false end
        local char = root.Parent
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.FloorMaterial == Enum.Material.Air then return false end
        local swim = char:GetAttribute("SwimState")
        if swim and swim > 0 then return false end
        return true
    end

    if myRoot and castPoint and canCast() and (castPoint - myRoot.Position).Magnitude <= 32 then
        return true, castPoint
    end

    local shore = FindShorePoint(castPoint)
    if not shore then
        -- Aucune berge trouvée : on tente quand même si on est au sol.
        return canCast(), castPoint
    end

    TeleportToPosition(shore, "Fishing Spot")
    task.wait(1.1)

    local root = GetRootPart()
    if not root then return false, castPoint end
    local again = FindCastableWaterPoint(castPoint, root)
    if again then castPoint = again end

    if not canCast() then
        -- Le système de nage peut mettre un instant à se couper après l'arrivée.
        task.wait(0.8)
    end
    return canCast(), castPoint
end

-- Suivi événementiel des prises : le scan par attribut ne voit que les enfants
-- directs, alors que les prises peuvent être imbriquées. On écoute les ajouts
-- dans Debree et on fusionne avec le scan (zéro coût en continu).
local function RefreshCatchTracker()
    if Hub.Fish._catchTracker then return true end
    local deb = Workspace:FindFirstChild("Debree")
    if not deb then return false end
    local ok = pcall(function()
        table.insert(Hub.Connections, deb.DescendantAdded:Connect(function(inst)
            pcall(function()
                if inst and inst.Parent and inst:GetAttribute("CatchItem") ~= nil then
                    Hub.Fish._liveCatches = Hub.Fish._liveCatches or {}
                    table.insert(Hub.Fish._liveCatches, inst)
                end
            end)
        end))
        table.insert(Hub.Connections, deb.DescendantRemoving:Connect(function(inst)
            pcall(function()
                local list = Hub.Fish._liveCatches
                if list then
                    for i = #list, 1, -1 do
                        if list[i] == inst or not list[i].Parent then
                            table.remove(list, i)
                        end
                    end
                end
            end)
        end))
    end)
    if ok then Hub.Fish._catchTracker = true end
    return ok
end

-- Poissons/déchets de pêche au sol (attribut CatchItem posé par le serveur)
local function FindFishingCatches()
    local found = {}
    local seen = {}
    local function addCatch(c)
        if not c or seen[c] then return end
        local part = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart", true)
        if part then
            seen[c] = true
            table.insert(found, {
                Model = c,
                Part = part,
                Pos = part.Position,
                Prompt = c:FindFirstChildWhichIsA("ProximityPrompt", true),
            })
        end
    end
    if Hub.Fish._liveCatches then
        for i = #Hub.Fish._liveCatches, 1, -1 do
            local c = Hub.Fish._liveCatches[i]
            if not c or not c.Parent then
                table.remove(Hub.Fish._liveCatches, i)
            elseif c:GetAttribute("CatchItem") ~= nil then
                addCatch(c)
            end
        end
    end
    local function scan(container)
        if not container then return end
        for _, c in ipairs(container:GetChildren()) do
            if c:GetAttribute("CatchItem") ~= nil then
                addCatch(c)
            end
        end
    end
    scan(Workspace:FindFirstChild("Debree"))
    scan(Workspace)
    return found
end

-- Vente : s'appuie sur Shop.GetSellPayout pour ne vendre que ce qui rapporte
local function GetSellPayout(name)
    local ok, payout = pcall(function()
        local Shop = require(ReplicatedStorage.CAM.Global.Shop)
        return Shop.GetSellPayout(name)
    end)
    if ok and type(payout) == "table" then return payout end
    return nil
end

local function BuildSellSelection(mode)
    local selection = {}
    for _, item in ipairs(GetInventoryList()) do
        if item.Amount > 0 then
            local keep = false
            if mode == "Fish Only" then
                keep = FISH_ITEMS[item.Name] == true
            elseif mode == "Wen Items Only" then
                local payout = GetSellPayout(item.Name)
                keep = payout ~= nil and payout.Wen ~= nil
            elseif mode == "All Sellable (No Equipment)" then
                local payout = GetSellPayout(item.Name)
                local def = GetItemDef(item.Name)
                keep = payout ~= nil and (def == nil or def.EquipType == nil)
            end
            if keep then
                selection[item.Name] = item.Amount
            end
        end
    end
    return selection
end

local function SellSelection(selection)
    if not SignalFunction then return nil, "no_signal" end
    local ok, res = pcall(function()
        return SignalFunction.ToServer("SellItems", selection)
    end)
    if not ok then return nil, tostring(res) end
    return res
end

-- Se téléporte près de Ginzo (seul vendeur Wen) avant de vendre
local function TravelToGinzo()
    local ginzoPos = Vector3.new(274, 942, 528)
    pcall(function()
        local Regions = require(ReplicatedStorage.Regions)
        local raw = Regions.GetNpcSpawn("Ginzo")
        if typeof(raw) == "Vector3" then ginzoPos = raw end
    end)
    local myRoot = GetRootPart()
    if myRoot and (myRoot.Position - ginzoPos).Magnitude > 45 then
        TeleportToPosition(ginzoPos, "Ginzo")
        task.wait(0.9)
    end
end

local function DoSellNow(mode, silent)
    local selection = BuildSellSelection(mode or Hub.Sell.Mode or "All Sellable (No Equipment)")
    local names = {}
    for name, n in pairs(selection) do table.insert(names, name .. " x" .. n) end
    if #names == 0 then
        if not silent then
            Kyoka:Notify({ Title = "Auto Sell", Content = "Nothing sellable for mode: " .. tostring(mode), Type = "info" })
        end
        return false, 0
    end
    TravelToGinzo()
    local res = SellSelection(selection)
    if res == nil then
        Kyoka:Notify({ Title = "Auto Sell", Content = "Server refused the sale (stay near Ginzo / check items).", Type = "error" })
        return false, 0
    end
    local earned = 0
    local mats = 0
    if type(res) == "table" then
        for _, payout in pairs(res) do
            if type(payout) == "table" then
                if payout.Wen then earned = earned + payout.Wen end
                for k, v in pairs(payout) do
                    if k ~= "Wen" and type(v) == "number" then mats = mats + v end
                end
            end
        end
    end
    Hub.Sell.TotalEarned = (Hub.Sell.TotalEarned or 0) + earned
    Kyoka:Notify({
        Title = "Auto Sell",
        Content = string.format("Sold %d stack(s) -> +%d Wen%s", #names, earned, mats > 0 and (" +" .. mats .. " materials") or ""),
        Type = "success",
        Duration = 5,
    })
    return true, earned
end

-- Raffinage
local function GetRefinableItems()
    local list = {}
    for _, item in ipairs(GetInventoryList()) do
        local def = GetItemDef(item.Name)
        if def and def.Refinable == true then
            table.insert(list, item)
        end
    end
    return list
end

local function GetItemRefineLevel(itemName)
    local inv = GetInventoryFolder()
    local item = inv and inv:FindFirstChild(itemName)
    if not item then return nil end
    local lvl = item:FindFirstChild("RefineLevel") or item:FindFirstChild("RefinementLevel") or item:FindFirstChild("Level")
    if lvl and lvl:IsA("ValueBase") then return tonumber(lvl.Value) end
    return nil
end

local function DoRefineAttempt(itemName, useGuard)
    local target = nil
    for _, item in ipairs(GetInventoryList()) do
        if item.Name == itemName then target = item break end
    end
    if not target or not target.Id then return nil, "item_not_found" end
    local ok, res = pcall(function()
        return SignalFunction.ToServer("RefinementRequest", {
            action = "Attempt",
            Id = target.Id,
            UseGuard = useGuard == true,
        })
    end)
    if not ok then return nil, tostring(res) end
    return res
end

local function TravelToHagane()
    local pos = Vector3.new(1732, 694, -765)
    pcall(function()
        local Regions = require(ReplicatedStorage.Regions)
        local raw = Regions.GetNpcSpawn("Refiner Hagane")
        if typeof(raw) == "Vector3" then pos = raw end
    end)
    local myRoot = GetRootPart()
    if myRoot and (myRoot.Position - pos).Magnitude > 45 then
        TeleportToPosition(pos, "Refiner Hagane")
        task.wait(0.9)
    end
end

--=====================================================================
-- Déblocage de la pêche : permis (Sofen) + achat de la canne (Jeso)
--=====================================================================
local PERMIT_QUEST = "Ill find the permit stamp(Lv 45)"
local PERMIT_STAMP_POS = Vector3.new(-449.76, 800.362, 750.014)

local function TravelToNpc(npcName, fallbackPos)
    local pos = fallbackPos
    pcall(function()
        local Regions = require(ReplicatedStorage.Regions)
        local raw = Regions.GetNpcSpawn(npcName)
        if typeof(raw) == "Vector3" then pos = raw end
    end)
    if not pos then return false end
    local myRoot = GetRootPart()
    if myRoot and (myRoot.Position - pos).Magnitude > 40 then
        TeleportToPosition(pos, npcName)
        task.wait(0.9)
    end
    return true
end

local function AcceptGameQuestByDialogue(npcName, answerText, fallbackPos)
    TravelToNpc(npcName, fallbackPos)
    local clicked = RunNpcDialogue(npcName, function(btnName)
        return btnName == answerText or string.find(string.lower(btnName), string.lower(answerText), 1, true) ~= nil
    end, 9.0)
    local accepted = false
    local deadline = os.clock() + 3.0
    while os.clock() < deadline do
        task.wait(0.1)
        local active = GetActiveQuest()
        if active then
            accepted = true
            break
        end
    end
    return accepted, clicked
end

local function TurnInGameQuestByDialogue(npcName, answerText, fallbackPos)
    TravelToNpc(npcName, fallbackPos)
    return RunNpcDialogue(npcName, function(btnName)
        return btnName == answerText or string.find(string.lower(btnName), string.lower(answerText), 1, true) ~= nil
    end, 9.0)
end

local function FindPermitStamp()
    local found = {}
    local function scan(container)
        if not container then return end
        for _, c in ipairs(container:GetChildren()) do
            -- Le modèle spawné s'appelle "Permit Stamp1" (suffixe de slot) : match par préfixe
            if c.Name == "Permit Stamp" or string.find(c.Name, "Permit Stamp", 1, true) == 1 then
                local part = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local prompt = c:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if not prompt and part then
                        prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
                    end
                    table.insert(found, {
                        Model = c,
                        Part = part,
                        Pos = part.Position,
                        Prompt = prompt,
                    })
                end
            end
        end
    end
    scan(Workspace:FindFirstChild("Debree"))
    scan(Workspace)
    return found
end

local function HasFishingPermit()
    local ok, has = pcall(function()
        local data = GetPlayerDataFolder()
        local inv = data and data:FindFirstChild("Inventory") and data.Inventory:FindFirstChild("Inventory")
        return inv ~= nil and inv:FindFirstChild("Fishing Permit") ~= nil
    end)
    return ok and has == true
end

local function BuyFishingRod(rodName)
    rodName = rodName or "Basic Fishing Rod"
    TravelToNpc("Fisherman Jeso", Vector3.new(-192, 807, 603))
    local ok, res = pcall(function()
        return SignalFunction.ToServer("PurchaseFromShop", rodName, 1, nil)
    end)
    return ok and res == true, res
end

-- Flux complet : accepter la quête du permis -> ramasser le tampon -> rendre -> acheter la canne
local function UnlockFishing()
    if Hub.IsInteractingQuest then return false, "busy" end
    local data = GetPlayerDataFolder()
    if not data then return false, "no_data" end

    if HasFishingPermit() then
        local bought, res = BuyFishingRod("Basic Fishing Rod")
        if bought then
            Kyoka:Notify({ Title = "Fishing Unlocked", Content = "Permit OK - Basic Fishing Rod bought!", Type = "success", Duration = 6 })
            return true, "bought"
        end
        return false, "purchase_refused"
    end

    local level = math.floor((data.Exp and data.Exp.Goal.Value or 60) / 60)
    if level < 45 then
        Kyoka:Notify({ Title = "Fishing Unlock", Content = string.format("Permit quest needs Level 45 (you are %d). Auto-Quest can level you up first.", level), Type = "warning", Duration = 8 })
        return false, "level"
    end

    -- 1. Accepter la quête chez Sofen (annule la quête en cours + attend le cooldown serveur)
    local active = GetActiveQuest()
    if active then
        CancelCurrentQuest()
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
        task.wait(0.8)
    end
    Kyoka:Notify({ Title = "Fishing Unlock", Content = "Accepting the permit quest at Sofen...", Type = "info", Duration = 4 })

    local accepted = false
    for attempt = 1, 3 do
        local cdRemaining = GetQuestCooldownRemaining()
        if cdRemaining > 0.5 then
            Kyoka:Notify({ Title = "Fishing Unlock", Content = string.format("Waiting %.0fs for the quest cooldown...", cdRemaining), Type = "info", Duration = 3 })
            local cdDeadline = os.clock() + cdRemaining + 0.5
            while os.clock() < cdDeadline do task.wait(0.5) end
        end
        accepted = AcceptGameQuestByDialogue("Dock Master Sofen", PERMIT_QUEST, Vector3.new(-161, 796, 703))
        if accepted then break end
        task.wait(1.0)
    end
    if not accepted then
        Kyoka:Notify({ Title = "Fishing Unlock", Content = "Could not accept the permit quest (need 5000 Wen / Level 45 / cooldown).", Type = "error", Duration = 8 })
        return false, "accept_failed"
    end

    -- 2. Ramasser le tampon (le modèle s'appelle "Permit Stamp1", prompt "Pick Up")
    Kyoka:Notify({ Title = "Fishing Unlock", Content = "Fetching the Permit Stamp...", Type = "info", Duration = 4 })
    local function HasStampItem()
        local ok, has = pcall(function()
            local d = GetPlayerDataFolder()
            local inv = d and d:FindFirstChild("Inventory") and d.Inventory:FindFirstChild("Inventory")
            return inv ~= nil and inv:FindFirstChild("Permit Stamp") ~= nil
        end)
        return ok and has == true
    end

    local stampCollected = false
    for attempt = 1, 4 do
        local stamps = FindPermitStamp()
        if #stamps == 0 then
            TeleportToPosition(PERMIT_STAMP_POS, "Permit Stamp")
            task.wait(1.2)
            stamps = FindPermitStamp()
        end
        for _, s in ipairs(stamps) do
            if s.Prompt then
                TeleportToPosition(s.Pos + Vector3.new(0, 2, 0))
                task.wait(0.3)
                pcall(fireproximityprompt, s.Prompt)
                -- attendre la validation serveur (item dans l'inventaire)
                local itemDeadline = os.clock() + 2.5
                while os.clock() < itemDeadline do
                    task.wait(0.2)
                    if HasStampItem() then
                        stampCollected = true
                        break
                    end
                end
            end
        end
        if stampCollected then break end
        task.wait(0.8)
    end

    if not stampCollected then
        Kyoka:Notify({ Title = "Fishing Unlock", Content = "Could not pick up the Permit Stamp - retry the button.", Type = "warning", Duration = 8 })
        return false, "stamp_failed"
    end

    -- 3. Rendre la quête à Sofen (réponse exacte du dialogue : "Hand over the permit stamp")
    task.wait(0.5)
    Kyoka:Notify({ Title = "Fishing Unlock", Content = "Returning the stamp to Sofen...", Type = "info", Duration = 4 })
    TurnInGameQuestByDialogue("Dock Master Sofen", "Hand over the permit stamp", Vector3.new(-161, 796, 703))

    -- Le dialogue de remerciement défile en chaîne : on attend le permis jusqu'à 8s
    local permitDeadline = os.clock() + 8.0
    while os.clock() < permitDeadline and not HasFishingPermit() do
        task.wait(0.4)
    end
    if not HasFishingPermit() then
        Kyoka:Notify({ Title = "Fishing Unlock", Content = "Permit not received yet - retry the button in a few seconds.", Type = "warning", Duration = 8 })
        return false, "turnin_pending"
    end

    -- 4. Acheter la canne
    local bought, res = BuyFishingRod("Basic Fishing Rod")
    if bought then
        Kyoka:Notify({ Title = "Fishing Unlocked", Content = "Permit obtained + Basic Fishing Rod bought!", Type = "success", Duration = 8 })
        return true, "bought"
    end
    Kyoka:Notify({ Title = "Fishing Unlock", Content = "Permit obtained but rod purchase was refused (need 3500 Wen).", Type = "warning", Duration = 8 })
    return false, "purchase_refused"
end

-- Auto-win de la pêche : intercepte les listeners "fishing rod" du portail
-- client pour répondre immédiatement "poisson attrapé" sans faire le mini-jeu.
-- Le hook lit le hub VIVANT via _G (sinon un reload garderait l'ancienne instance).
pcall(function()
    local SCP = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
    if SCP then
        if not SCP._kyokaRawLink then
            SCP._kyokaRawLink = SCP.Link
        end
        local rawLink = SCP._kyokaRawLink
        SCP.Link = function(name, duration)
            local link = rawLink(name, duration)
            -- La Legendary (et autres cannes) peut utiliser un canal dédié :
            -- on intercepte tout lien "fishing rod", pas seulement "FishingRod".
            local isRodLink = type(link) == "table" and type(name) == "string"
                and (name == "FishingRod" or (string.find(string.lower(name), "fish", 1, true) and string.find(string.lower(name), "rod", 1, true)))
            if isRodLink then
                local rawConnect = link.Connect
                if type(rawConnect) == "function" then
                    link.Connect = function(self, fn)
                        pcall(function()
                            local H = _G.SlayersKyokaHub
                            if H and H.Fish then H.Fish.HookActive = true H.Fish.LastRodLink = name end
                        end)
                        return rawConnect(self, function(kind, token)
                            local H = _G.SlayersKyokaHub
                            local F = H and H.Fish
                            if F then
                                if kind == "Bite" then
                                    F.LastBiteAt = os.clock()
                                    if F.Auto then
                                        F.Bites = (F.Bites or 0) + 1
                                        -- Délai HUMANISÉ avant d'annoncer la victoire : on imite
                                        -- le temps de réaction d'un joueur (2-8s par défaut). Le
                                        -- signalement instantané systématique semble repérable.
                                        local delayMin = tonumber(F.ReportDelayMin)
                                        if delayMin == nil then delayMin = tonumber(F.ReportDelay) or 5 end
                                        local delayMax = tonumber(F.ReportDelayMax)
                                        if delayMax == nil then delayMax = (tonumber(F.ReportDelay) or 0) > 0 and tonumber(F.ReportDelay) or 9 end
                                        if delayMax < delayMin then delayMax = delayMin end
                                        if delayMax > 0.2 then
                                            task.spawn(function()
                                                task.wait(delayMin + math.random() * (delayMax - delayMin))
                                                pcall(function() self:Server(token, true) end)
                                            end)
                                            return
                                        end
                                        local reported = false
                                        if self and type(self.Server) == "function" then
                                            local okReport = pcall(function() self:Server(token, true) end)
                                            reported = okReport == true
                                        end
                                        if reported then return end
                                    end
                                elseif kind == "BiteMissed" then
                                    F.LastBiteMissedAt = os.clock()
                                elseif kind == "BiteCancel" then
                                    F.LastBiteCancelAt = os.clock()
                                end
                            end
                            return fn(kind, token)
                        end)
                    end
                end
            end
            return link
        end
    end
end)

-- Force la canne à se ré-équiper proprement pour que son listener "FishingRod"
-- se ré-enregistre en passant par notre hook. Ne JAMAIS détruire le listener
-- via SCP.Destroy : ça le tue silencieusement sans le recréer et plus aucune
-- morsure n'arrive (le serveur n'a plus personne à qui parler).
local function ForceRodReequip()
    local slot = Hub.Fish.RodSlot
    if not slot then
        local s = EnsureRodEquipped()
        slot = s
    end
    Hub.Fish.RodSlot = slot
    if slot and SignalEvent then
        pcall(function() SignalEvent.ToServer("Item_Equip", 0) end)
        task.wait(0.6)
        pcall(function() SignalEvent.ToServer("Item_Equip", slot) end)
        task.wait(0.6)
    end
    return slot ~= nil
end

local function RefreshFishingBiteHook()
    task.spawn(function()
        pcall(function() ForceRodReequip() end)
    end)
end

-- Exposition via la table Util
Util.GetInventoryList = GetInventoryList
Util.GetItemDef = GetItemDef
Util.CountFishItems = CountFishItems
Util.FindRodItem = FindRodItem
Util.EnsureRodEquipped = EnsureRodEquipped
Util.FindWaterPoint = FindWaterPoint
Util.FindShorePoint = FindShorePoint
Util.FindCastableWaterPoint = FindCastableWaterPoint
Util.CastRod = CastRod
Util.UncastRod = UncastRod
Util.FindFishingCatches = FindFishingCatches
Util.GetSellPayout = GetSellPayout
Util.BuildSellSelection = BuildSellSelection
Util.SellSelection = SellSelection
Util.TravelToGinzo = TravelToGinzo
Util.DoSellNow = DoSellNow
Util.GetRefinableItems = GetRefinableItems
Util.DoRefineAttempt = DoRefineAttempt
Util.TravelToHagane = TravelToHagane
Util.UnlockFishing = UnlockFishing
Util.BuyFishingRod = BuyFishingRod
Util.HasFishingPermit = HasFishingPermit
Util.RefreshFishingBiteHook = RefreshFishingBiteHook
Util.RefreshCatchTracker = RefreshCatchTracker
end

--=====================================================================
-- Interface Kyōka UI
--=====================================================================
local Window = Kyoka:CreateWindow({
    Title       = "KYŌKA",
    Subtitle    = "SLAYERS 2",
    Game        = "Slayers 2",
    Footer      = "kyoka · slayers 2 v2.0",
    StatusRight = "RShift to hide",
    Tier        = "Master",
    ToggleKey   = Enum.KeyCode.RightShift,
    Splash      = true,
})

Kyoka:SetWatermark("Kyoka Hub / Slayers 2 / {fps} fps / {ping}", true)
Kyoka:SetKeybindListVisible(true)

-- ==================== TAB FARM ====================
local FarmTab = Window:AddTab("Farm")
local FarmPage = FarmTab:AddPage("Mobs Farm")
local PlayerPage = FarmTab:AddPage("Players Farm")
local QuestPage = FarmTab:AddPage("Quests Farm")
local TrainingPage = FarmTab:AddPage("Training Farm")
local UtilityPage = FarmTab:AddPage("Fish & Utility")

local AutoFarmGroup = FarmPage:AddGroup("Mob Auto Farm", "Left")

-- Refs croisees pour sync UI (ON/OFF mutuel Farm <-> Quest + bouton STOP ALL)
local AutoFarmToggleObj = nil
local AutoQuestToggleObj = nil
local PlayerFarmToggleObj = nil

local function SyncToggle(obj, state)
    if obj then pcall(function() obj:Set(state, true) end) end
end

AutoFarmToggleObj = AutoFarmGroup:AddToggle("AutoFarmToggle", {
    Text = "Enable Auto Farm",
    Default = false,
    Callback = function(val)
        Hub.Farm.AutoFarm = val
        if not val then
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            RemoveFarmPlatform()
            local root = GetRootPart()
            if root then root.AssemblyLinearVelocity = Vector3.zero end
            -- Couper aussi l'Auto Quest : sinon il continue a prendre des quetes + teleporter
            if Hub.Farm.AutoQuest then
                Hub.Farm.AutoQuest = false
                Hub.IsInteractingQuest = false
                SyncToggle(AutoQuestToggleObj, false)
                Kyoka:Notify({ Title = "Auto Farm", Content = "Auto Farm + Auto Quest disabled!", Type = "warning" })
            end
        end
    end
}):AddKeybind("AutoFarmKey", { Default = Enum.KeyCode.V, Mode = "Toggle" })

AutoFarmGroup:AddToggle("TargetLockToggle", {
    Text = "Lock Target Until Death",
    Default = true,
    Tooltip = "Locks onto the current boss or mob until death. Zero target switching mid-fight!",
    Callback = function(val)
        Hub.Farm.TargetLock = val
    end
})

-- Listes séparées : Monstres Normaux vs Bosses & Hashiras
local normalMobList = {
    "All Normal Mobs",
    -- Pourfendeurs & Apprentis (Karma Négatif)
    "Kanoe Demon Slayer",
    "Mizunoe Demon Slayer",
    "Mizunoto",
    "Civilian",
    "*Civilian*",
    -- Bandits & Civils
    "Bandit",
    "KaruVillageBandit",
    "Spy",
    "VillageSpy",
    -- Famille Ours & Animaux
    "Bear Cub",
    "Mother Bear",
    "Kaiden",
    "Kaiden Subordinate",
    "Hoyuzo",
    "Hoyuzo Subordinate",
    -- Démons Communs & Élites
    "High Demon",
    "LesserDemon",
    "RogueDemon",
    "Lost",
    "Beast Born Demon",
    "BloodHoundedDemon_MistfallHarbor",
    "GreaterDemon_ButterflyEstate",
    "LesserDemon_ButterflyEstate",
    "Fire Profound Demon",
    "Ice Profound Demon",
    -- NOTE: raid mobs (Grove Raider, Raid Captain, Cache Prowler/Lancer...)
    -- are Boss-category now (see bossMobList). Selecting them here would
    -- silently match nothing since Bosses are excluded from Normal.
    -- Iceveil
    "Kanoe Demon Slayer",
    "IceveilRoadBandit",
    "IceveilRoadMarauder",
    "IceveilRoadPikeman",
    -- Stagiaires / Apprentis
    "Flame Trainee",
    "Water Trainee",
    "Thunder Trainee",
    "Wind Trainee",
    "Sound Trainee",
    "Stone Trainee",
    "Serpent Trainee",
    "Insect Trainee",
    "Tai Chi Trainee",
    "Soryu Trainee",
    "Reaper Trainee"
}

local bossMobList = {
    "All Bosses",
    -- Grands Bosses de Monde
    "YetiDemon",
    "SmallYeti",
    "HandDemon",
    "Hoyuzo",
    "Kaiden",
    "Mother Bear",
    "Fujiko",
    -- PNJ Boss / Maîtres & Hashiras
    "Zuko",
    "Saneri",
    "Obari",
    "Shinora",
    "Giyen",
    "Tengai (Tengen)",
    "Tengai",
    "Tengen",
    "Zentaro",
    "Gyorei",
    "Rengu",
    -- Démons d'Art Sanguinaire (Evil Art)
    "Gyutai",
    "Datai",
    "Reaper",
    "Akazo",
    "Domae",
    "Nezura",
    "Yahari",
    "Sumari",
    "Enru",
    -- Bosses de Raid & Gardes des Caches Scellées (Temporary)
    "Grove Raider",
    "Raid Captain",
    "Cache Prowler",
    "Prowler Captain",
    "Cache Lancer",
    "Lancer Captain",
    -- Stagiaires / Apprentis (Mini-Bosses)
    "Flame Trainee",
    "Water Trainee",
    "Water Trainee Sabito",
    "Thunder Trainee",
    "Wind Trainee",
    "Sound Trainee",
    "Stone Trainee",
    "Serpent Trainee",
    "Insect Trainee",
    "Tai Chi Trainee",
    "Tai Chi Trainee Suzume",
    "Soryu Trainee",
    "Soryu Trainee Goki",
    "Reaper Trainee",
    "Reaper Trainee Kuzan"
}

local comprehensiveRegionList = {
    "All",
    "Bamboo Grove",
    "Windy Peak",
    "Iceveil Valley",
    "Mistfall Harbor",
    "Hidden Mist Village",
    "Butterfly Estate",
    "Final Selection Plains",
    "Misc",
    "Temporary"
}

-- Table de correspondance pour détection instantanée de catégorie
local BossLookup = {}
for _, b in ipairs(bossMobList) do
    if b ~= "All Bosses" then
        BossLookup[string.lower(b)] = true
        BossLookup[string.lower(string.gsub(b, "%s+", ""))] = true
    end
end

-- Sélecteur de Catégorie : Normal Mobs Only, Bosses Only, All
AutoFarmGroup:AddDropdown("MobCategorySelection", {
    Text = "Target Category",
    Values = { "Normal Mobs", "Bosses & Hashiras", "All Targets" },
    Default = "Normal Mobs",
    Callback = function(val)
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
        if val == "Normal Mobs" then
            Hub.Farm.MobCategory = "Normal"
            Hub.Farm.TargetMob = (Hub.Farm.NormalMob == "All Normal Mobs") and "All" or Hub.Farm.NormalMob
        elseif val == "Bosses & Hashiras" then
            Hub.Farm.MobCategory = "Boss"
            if Hub.Farm.SelectedBosses and #Hub.Farm.SelectedBosses > 0 then
                Hub.Farm.TargetMob = Hub.Farm.SelectedBosses
            else
                Hub.Farm.TargetMob = (Hub.Farm.BossMob == "All Bosses") and "All" or Hub.Farm.BossMob
            end
        else
            Hub.Farm.MobCategory = "All"
            Hub.Farm.TargetMob = "All"
        end
    end
})

AutoFarmGroup:AddDropdown("NormalMobSelection", {
    Text = "Normal Mob Target",
    Values = normalMobList,
    Default = "All Normal Mobs",
    Callback = function(val)
        Hub.Farm.NormalMob = val
        if Hub.Farm.MobCategory == "Normal" then
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            Hub.Farm.TargetMob = (val == "All Normal Mobs") and "All" or val

            if Hub.Farm.AutoFarm and Hub.Farm.AutoTravelToRegion and val ~= "All Normal Mobs" then
                local wp = GetMobSpawnPosition(val)
                if wp then
                    TeleportToPosition(wp, val .. " Spawn")
                end
            end
        end
    end
})

AutoFarmGroup:AddDropdown("BossMobSelection", {
    Text = "Boss Target (Multi-Select & Rotation)",
    Values = bossMobList,
    Default = { "All Bosses" },
    Multi = true,
    Tooltip = "Select one or multiple bosses! The bot will automatically alternate and patrol strictly between them.",
    Callback = function(val)
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
        bossRotationIndex = 1
        lastBossRotationTime = tick()

        local selected = {}
        if type(val) == "string" then
            if val ~= "All Bosses" and val ~= "All" and val ~= "" then
                table.insert(selected, val)
            end
        elseif type(val) == "table" then
            for _, b in ipairs(val) do
                if b ~= "All Bosses" and b ~= "All" and b ~= "" then
                    table.insert(selected, b)
                end
            end
        end

        Hub.Farm.SelectedBosses = selected
        if #selected == 0 then
            Hub.Farm.BossMob = "All Bosses"
            if Hub.Farm.MobCategory == "Boss" then
                Hub.Farm.TargetMob = "All"
            end
        else
            Hub.Farm.BossMob = (#selected == 1) and selected[1] or string.format("Multiple (%d)", #selected)
            if Hub.Farm.MobCategory == "Boss" then
                Hub.Farm.TargetMob = selected
                if Hub.Farm.AutoFarm and Hub.Farm.AutoTravelToRegion then
                    local aliveBoss = FindAliveBossFromList(selected, Hub.Farm.RegionFilter)
                    if aliveBoss then
                        for idx, bName in ipairs(selected) do
                            if IsTargetValid(aliveBoss, bName, "All", "Boss") then
                                bossRotationIndex = idx
                                break
                            end
                        end
                        if aliveBoss.Root then
                            TeleportToPosition(aliveBoss.Root.Position, aliveBoss.Name .. " (Alive)")
                        end
                    else
                        local firstBoss = selected[1]
                        local wp = GetMobSpawnPosition(firstBoss)
                        if wp then
                            TeleportToPosition(wp, firstBoss .. " Spawn")
                        end
                    end
                end
            end
        end
    end
})

AutoFarmGroup:AddSlider("BossRotationDelaySlider", {
    Text = "Boss Patrol / Rotation Delay (s)",
    Min = 5,
    Max = 60,
    Default = 15,
    Float = 1,
    Tooltip = "Time to wait at a boss spawn before rotating to the next selected boss if it has not spawned yet.",
    Callback = function(val)
        Hub.Farm.BossRotationInterval = val
    end
})

AutoFarmGroup:AddDropdown("FarmRegionSelection", {
    Text = "Region Filter",
    Values = comprehensiveRegionList,
    Default = "All",
    Callback = function(val)
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
        Hub.Farm.RegionFilter = val
    end
})

AutoFarmGroup:AddToggle("AutoTravelRegionToggle", {
    Text = "Auto-Travel To Region (Load Mobs)",
    Default = true,
    Tooltip = "Automatically teleports to target region to force server mob streaming & spawning!",
    Callback = function(val)
        Hub.Farm.AutoTravelToRegion = val
    end
})

AutoFarmGroup:AddDropdown("FarmSafeModeDropdown", {
    Text = "Farm Position Mode",
    Values = { "Overhead (Safe - Recommended)", "In Front (Classic)" },
    Default = "Overhead (Safe - Recommended)",
    Tooltip = "Overhead positions you above mob head with safety platform, safe from melee attacks!",
    Callback = function(val)
        if string.find(val, "Overhead") then
            Hub.Farm.SafeMode = "Overhead"
        else
            Hub.Farm.SafeMode = "In Front"
        end
    end
})

AutoFarmGroup:AddSlider("FarmHeightOffsetSlider", {
    Text = "Safe Vertical Offset",
    Min = 2.5,
    Max = 9.0,
    Default = 4.2,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(val)
        Hub.Farm.HeightOffset = val
    end
})

AutoFarmGroup:AddSlider("FarmDistanceSlider", {
    Text = "Target Distance",
    Min = 1.5,
    Max = 8,
    Default = 2.8,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(val)
        Hub.Farm.Distance = val
    end
})

local CombatFarmGroup = FarmPage:AddGroup("Combat Helpers", "Right")
CombatFarmGroup:AddToggle("MultiHitToggle", {
    Text = "Multi-Hit / Fast Burst (3x Combo)",
    Default = true,
    Tooltip = "Chains multiple rapid hits per cycle to burst down mobs extra fast!",
    Callback = function(val)
        Hub.Farm.MultiHit = val
    end
})

CombatFarmGroup:AddSlider("MultiHitCountSlider", {
    Text = "Hits Per Cycle",
    Min = 1,
    Max = 5,
    Default = 3,
    Rounding = 0,
    Callback = function(val)
        Hub.Farm.MultiHitCount = val
    end
})

CombatFarmGroup:AddToggle("InstantKillToggle", {
    Text = "Instant Kill (Max DPS Burst)",
    Default = false,
    Tooltip = "Turbo mode: mashes M1 (5 hits per burst) and every skill with almost no delay, melting bosses in seconds!",
    Callback = function(val)
        Hub.Farm.InstantKill = val
    end
})

CombatFarmGroup:AddToggle("AutoSkillsToggle", {
    Text = "Auto Skills / Spells Rotation",
    Default = true,
    Tooltip = "Automatically casts all unlocked breathing/demon art skills in sequence during combat!",
    Callback = function(val)
        Hub.Farm.AutoSkills = val
    end
})

CombatFarmGroup:AddSlider("SkillIntervalSlider", {
    Text = "Skill Cast Cooldown",
    Min = 0.5,
    Max = 3.0,
    Default = 1.0,
    Rounding = 1,
    Suffix = "s",
    Tooltip = "Cooldown delay between skill invocations",
    Callback = function(val)
        Hub.Farm.SkillInterval = val
    end
})

CombatFarmGroup:AddToggle("AutoM1Toggle", {
    Text = "Auto M1 Attack",
    Default = true,
    Callback = function(val)
        Hub.Farm.AutoM1 = val
    end
})

CombatFarmGroup:AddToggle("AutoEquipWeaponToggle", {
    Text = "Auto-Equip Katana / Weapon",
    Default = true,
    Tooltip = "Ensures your katana is permanently drawn and equipped so attacks never get disabled!",
    Callback = function(val)
        Hub.Farm.AutoEquipWeapon = val
        if val then EnsureWeaponEquipped() end
    end
})

CombatFarmGroup:AddToggle("AutoChestsToggle", {
    Text = "Auto Collect Chests (World & Boss)",
    Default = true,
    Tooltip = "Automatically detects, opens, and loots all nearby and unlocked chests (Boss Drops, World Events, Caches)!",
    Callback = function(val)
        Hub.Farm.AutoCollectChests = val
    end
})

CombatFarmGroup:AddToggle("AutoLootToggle", {
    Text = "Auto Collect Loot Drops",
    Default = true,
    Tooltip = "Automatically vacuums up all nearby drop items, coins, and materials!",
    Callback = function(val)
        Hub.Farm.AutoCollectLoot = val
    end
})

CombatFarmGroup:AddToggle("AutoSoulsToggle", {
    Text = "Auto Collect Demon Souls",
    Default = true,
    Tooltip = "Automatically detects and absorbs all Demon Souls (Weak, Strong, Brave) dropped by demons upon death!",
    Callback = function(val)
        Hub.Farm.AutoCollectSouls = val
    end
})

CombatFarmGroup:AddSlider("BossLootWaitSlider", {
    Text = "Boss Loot Wait Time",
    Min = 1.5,
    Max = 8.0,
    Default = 4.0,
    Rounding = 1,
    Suffix = "s",
    Tooltip = "Time dedicated to waiting for chests & vacuuming drops after defeating a boss before moving to the next mob.",
    Callback = function(val)
        Hub.Farm.BossLootWaitTime = val
    end
})

-- ==================== SEALED CACHE FARM (T1 / T2 / T3) ====================
do
    local CacheFarmGroup = FarmPage:AddGroup("Sealed Cache Farm (T1 / T2 / T3)", "Right")

    Hub.CacheFarm.StatusLabel = CacheFarmGroup:AddLabel("Cache Status: Idle")
    Hub.CacheFarm.SetStatus = function(text)
        Hub.CacheFarm.LastStatus = text
        local lbl = Hub.CacheFarm.StatusLabel
        if lbl then
            Hub.GuiWrite(function() lbl:SetText("Cache Status: " .. text) end)
        end
    end

    CacheFarmGroup:AddToggle("CacheFarmToggle", {
        Text = "Enable Sealed Cache Auto Farm",
        Default = false,
        Tooltip = "Patrols every Sealed Cache (T1/T2/T3) in the server, kills the raider guards, opens the cache, loots it, then hops to a fresh server!",
        Callback = function(val)
            Hub.CacheFarm.Enabled = val
            Hub.CacheFarm.NoCacheSince = nil
            Hub.CacheFarm.Opened = {}
            if val then
                Hub.CacheFarm.SetStatus("Scanning for sealed caches...")
                Kyoka:Notify({ Title = "Cache Farm", Content = "Sealed Cache farm enabled (T1/T2/T3)!", Type = "info" })
            else
                Hub.CacheFarm.SetStatus("Idle")
                RemoveFarmPlatform()
            end
        end
    })

    CacheFarmGroup:AddDropdown("CacheTierSelection", {
        Text = "Cache Tiers",
        Values = { "Sealed Cache T1", "Sealed Cache T2", "Sealed Cache T3" },
        Default = { "Sealed Cache T1", "Sealed Cache T2", "Sealed Cache T3" },
        Multi = true,
        Tooltip = "Select which sealed cache tiers to farm.",
        Callback = function(val)
            local tiers = { ["Sealed Cache T1"] = false, ["Sealed Cache T2"] = false, ["Sealed Cache T3"] = false }
            if type(val) == "string" then
                if tiers[val] ~= nil then tiers[val] = true end
            elseif type(val) == "table" then
                for _, v in ipairs(val) do
                    if tiers[v] ~= nil then tiers[v] = true end
                end
            end
            Hub.CacheFarm.Tiers = tiers
            Hub.CacheFarm.NoCacheSince = nil
        end
    })

    CacheFarmGroup:AddToggle("CacheKillGuardsToggle", {
        Text = "Kill Guards (Instant Kill)",
        Default = true,
        Tooltip = "Destroys the raider guards protecting the cache with max DPS before opening it.",
        Callback = function(val)
            Hub.CacheFarm.KillGuards = val
        end
    })

    CacheFarmGroup:AddToggle("CacheServerHopToggle", {
        Text = "Server Hop When Cleared / No Cache",
        Default = true,
        Tooltip = "Teleports you to a fresh server once every selected cache is looted (or when the server has none).",
        Callback = function(val)
            Hub.CacheFarm.ServerHop = val
        end
    })

    CacheFarmGroup:AddToggle("CachePreferEmptyToggle", {
        Text = "Prefer Low-Population Servers",
        Default = true,
        Tooltip = "When hopping, picks servers with the fewest players so the caches are untouched.",
        Callback = function(val)
            Hub.CacheFarm.PreferEmpty = val
        end
    })

    CacheFarmGroup:AddSlider("CacheHopDelaySlider", {
        Text = "Hop Delay After Cleared",
        Min = 3,
        Max = 60,
        Default = 12,
        Rounding = 0,
        Suffix = "s",
        Tooltip = "Time to wait after the last cache is looted (or after finding an empty server) before hopping.",
        Callback = function(val)
            Hub.CacheFarm.HopDelay = val
        end
    })

    CacheFarmGroup:AddButton("Server Hop Now", {
        Accent = true,
        Callback = function()
            if Hub.CacheFarm.DoServerHop then
                Hub.CacheFarm.DoServerHop(true)
            end
        end
    })

    CacheFarmGroup:AddButton("Rescan Caches Now", {
        Callback = function()
            Hub.CacheFarm.NoCacheSince = nil
            Hub.CacheFarm.Opened = {}
            Hub.CacheFarm.SetStatus("Rescanning caches...")
        end
    })
end

CombatFarmGroup:AddButton("Collect Nearby Chests & Loot Now", {
    Accent = true,
    Callback = function()
        local myRoot = GetRootPart()
        if not myRoot then return end

        local chestCount = 0
        local lootCount = 0

        -- Collect Chests
        local function IsSafeChestPrompt(prompt, partPos, maxDist)
            if not prompt or not partPos or not prompt:IsA("ProximityPrompt") then return false end
            if not prompt.Parent then return false end

            local act = (prompt.ActionText or ""):lower()
            local obj = (prompt.ObjectText or ""):lower()
            local pName = (prompt.Name or ""):lower()
            if act:find("chat") or act:find("talk") or act:find("speak") or act:find("train") or act:find("buy") or act:find("shop") or act:find("quest") or act:find("dialogue") then
                return false
            end
            if obj:find("trainer") or obj:find("urokodaki") or obj:find("muzan") or obj:find("npc") or obj:find("station") or obj:find("corps") or obj:find("slayer") or obj:find("shop") then
                return false
            end

            if (partPos - myRoot.Position).Magnitude > (maxDist or 150) then
                return false
            end

            local cur = prompt.Parent
            local chestModel = nil
            while cur and cur ~= Workspace do
                if cur.Parent == Workspace:FindFirstChild("Chests") or cur:GetAttribute("ChestState") ~= nil or cur:GetAttribute("IsOpen") ~= nil or cur:GetAttribute("ChestId") ~= nil or cur:GetAttribute("ChestGuid") ~= nil then
                    chestModel = cur
                    break
                end
                cur = cur.Parent
            end

            if not chestModel and not pName:find("chest") and not obj:find("chest") and not obj:find("cache") and not act:find("open") then
                return false
            end

            if chestModel then
                if chestModel:GetAttribute("IsOpen") == true or chestModel:GetAttribute("ChestState") == "Opened" or chestModel:GetAttribute("ChestState") == "Despawned" then
                    return false
                end
                -- FIX raid: les Sealed Cache / boss chests sont Locked jusqu'à la mort des gardes.
                -- On les autorise si le prompt est actif (comme en auto), sinon on attend.
                if chestModel:GetAttribute("ChestState") == "Locked" and not prompt.Enabled then
                    return false
                end
                -- FIX: ne pas rejeter les mounds qui portent des attributs de coffre (raid),
                -- seulement les vrais Snow Mound (ChestMound sans ChestId/Guid/State)
                if string.find(chestModel.Name:lower(), "mound") then
                    if chestModel:GetAttribute("ChestId") == nil and chestModel:GetAttribute("ChestGuid") == nil and chestModel:GetAttribute("ChestState") == nil then
                        return false
                    end
                end
            end

            return true
        end

        local function ScanAndCollectChests()
            local myPos = myRoot.Position
            local cFolder = Workspace:FindFirstChild("Chests")
            local cs = game:GetService("CollectionService")

            local chestsToOpen = {}
            local seenPrompts = {}

            local function checkAndAddPrompt(p)
                if not p or not p:IsA("ProximityPrompt") or seenPrompts[p] then return end
                local parent = p.Parent
                local partPos = parent and (parent:IsA("Attachment") and parent.WorldPosition or (parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and parent:GetPivot().Position)))
                if partPos and IsSafeChestPrompt(p, partPos, 150) then
                    seenPrompts[p] = true
                    table.insert(chestsToOpen, { prompt = p, pos = partPos })
                end
            end

            if cFolder then
                for _, c in ipairs(cFolder:GetDescendants()) do
                    if c:IsA("ProximityPrompt") then
                        checkAndAddPrompt(c)
                    end
                end
            end

            for _, c in ipairs(cs:GetTagged("Chest")) do
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("ProximityPrompt") then
                        checkAndAddPrompt(p)
                    end
                end
            end

            for _, item in ipairs(chestsToOpen) do
                local p = item.prompt
                local partPos = item.pos
                local oldDist = p.MaxActivationDistance
                pcall(function()
                    p.MaxActivationDistance = 50
                end)

                local savedCF = myRoot.CFrame
                myRoot.CFrame = CFrame.new(partPos + Vector3.new(0, 1.2, 0))
                task.wait(0.12)

                -- PROVEN MCP live: hold légitime requis pour prompts Custom.
                local needHold = 0
                pcall(function() needHold = tonumber(p.HoldDuration) or 0 end)
                if p.Enabled then
                    pcall(function() p:InputHoldBegin() end)
                    task.wait(math.min(needHold + 0.4, 3.0))
                    pcall(function() p:InputHoldEnd() end)
                end
                pcall(fireproximityprompt, p)
                local promptKey = (p.KeyboardKeyCode ~= Enum.KeyCode.Unknown and p.KeyboardKeyCode) or Enum.KeyCode.T
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                    task.wait(0.12)
                    VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                end
                task.wait(0.08)

                myRoot.CFrame = savedCF
                pcall(function()
                    p.MaxActivationDistance = oldDist
                end)
                chestCount = chestCount + 1
            end
        end

        pcall(ScanAndCollectChests)

        -- Collect Drops (STRICTLY LootDrops, NEVER Debree which contains NPCs!)
        local myUserId = LocalPlayer.UserId
        local lFolder = Workspace:FindFirstChild("LootDrops")
        local cs = game:GetService("CollectionService")
        local candidateDrops = {}
        local seenDropPrompts = {}

        local function checkAndAddDrop(item)
            if not item or not item.Parent then return end
            if item:FindFirstAncestor("Regions") or item:FindFirstAncestor("StationaryNpcs") or item.Name == "Regions" or item.Name == "Debree" then
                return
            end

            local isDrop = (item:GetAttribute("DropItemId") ~= nil) or (item.Parent == lFolder) or cs:HasTag(item, "LootDrop")
            if not isDrop then return end

            local ownerId = item:GetAttribute("DropOwnerUserId")
            local reserved = item:GetAttribute("DropReservedFor")
            local canClaim = (ownerId == nil or ownerId == myUserId)
            if reserved and not string.find(reserved, "," .. myUserId .. ",") then
                canClaim = false
            end
            if not canClaim then return end

            local part = item:IsA("BasePart") and item or (item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
            local pos = part and part.Position or (item:IsA("Model") and item:GetPivot().Position)
            if not pos or (pos - myRoot.Position).Magnitude > 150 then return end

            local p = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if p and not seenDropPrompts[p] then
                local act = (p.ActionText or ""):lower()
                local obj = (p.ObjectText or ""):lower()
                if act:find("chat") or act:find("talk") or act:find("speak") or act:find("train") or act:find("buy") or act:find("shop") or act:find("quest") then
                    return
                end
                if obj:find("trainer") or obj:find("urokodaki") or obj:find("muzan") or obj:find("npc") then
                    return
                end
                seenDropPrompts[p] = true
                table.insert(candidateDrops, { prompt = p, pos = pos, part = part })
            end
        end

        if lFolder then
            for _, item in ipairs(lFolder:GetChildren()) do
                checkAndAddDrop(item)
            end
        end
        for _, item in ipairs(cs:GetTagged("LootDrop")) do
            if item.Parent ~= lFolder then
                checkAndAddDrop(item)
            end
        end

        for _, d in ipairs(candidateDrops) do
            local p = d.prompt
            local pos = d.pos
            local part = d.part
            local oldDist = p.MaxActivationDistance
            pcall(function()
                p.MaxActivationDistance = 30
            end)

            local savedCF = myRoot.CFrame
            myRoot.CFrame = CFrame.new(pos + Vector3.new(0, 1.0, 0))
            task.wait(0.12)

            -- PROVEN MCP live: hold légitime requis pour prompts Custom.
            local needHold = 0
            pcall(function() needHold = tonumber(p.HoldDuration) or 0 end)
            if p.Enabled then
                pcall(function() p:InputHoldBegin() end)
                task.wait(math.min(needHold + 0.4, 3.0))
                pcall(function() p:InputHoldEnd() end)
            end
            pcall(fireproximityprompt, p)
            local promptKey = (p.KeyboardKeyCode ~= Enum.KeyCode.Unknown and p.KeyboardKeyCode) or Enum.KeyCode.T
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                task.wait(0.12)
                VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
            end
            if part then
                pcall(function()
                    firetouchinterest(myRoot, part, 0)
                    task.wait(0.02)
                    firetouchinterest(myRoot, part, 1)
                end)
            end
            task.wait(0.08)

            myRoot.CFrame = savedCF
            pcall(function()
                p.MaxActivationDistance = oldDist
            end)
            lootCount = lootCount + 1
        end

        -- Collect Demon Souls (Weak, Strong, Brave)
        local soulCount = 0
        local candidateSouls = {}
        local seenSoulParts = {}

        local function checkAndAddSoul(item)
            if not item or not item.Parent then return end
            if item:FindFirstAncestor("StationaryNpcs") or item:FindFirstAncestor("ActiveNpcs") then return end
            if item:FindFirstAncestor("Regions") and not item:FindFirstAncestor("Debree") then
                -- Souls live in Workspace.Debree, never inside Regions/Humanoids
                return
            end
            if item:FindFirstChildOfClass("Humanoid") then return end

            local iName = (item.Name or "")
            local name = iName:lower()
            -- FIX MCP live: souls are exactly "Weak Soul"/"Strong Soul"/"Brave Soul"
            -- in Workspace.Debree with SoulPrompt/Claim starting DISABLED (server-gated).
            -- Pickup = wait Enabled then fire prompt (CanTouch=false so touch never works).
            local isSoul = name == "weak soul" or name == "strong soul" or name == "brave soul"
            if not isSoul then
                if name:find("soul") then
                    -- Guard against NPCs/styles like "Harvester of Souls": require Model without Humanoid
                    -- and parent Debree/LootDrops/Workspace (not Regions/Npcs)
                    local parentName = item.Parent and item.Parent.Name or ""
                    if parentName == "Debree" or parentName == "LootDrops" or item.Parent == Workspace then
                        isSoul = true
                    else
                        return
                    end
                elseif item:GetAttribute("IsSoul") or item:GetAttribute("SoulType") then
                    isSoul = true
                end
            end
            if not isSoul then return end

            -- FIX: use Pivot first (live souls may have no Root/Hitbox at scan time during despawn)
            local pos = nil
            pcall(function()
                if item:IsA("Model") then pos = item:GetPivot().Position
                elseif item:IsA("BasePart") then pos = item.Position end
            end)
            local part = item:IsA("BasePart") and item or (item:FindFirstChild("Root") or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
            if not pos then
                pos = part and part.Position or nil
            end
            if not pos or (pos - myRoot.Position).Magnitude > 350 then return end
            if part and seenSoulParts[part] then return end
            if part then seenSoulParts[part] = true end

            table.insert(candidateSouls, {
                prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true),
                pos = pos,
                part = part,
                model = item:IsA("Model") and item or nil,
            })
        end

        for _, item in ipairs(Workspace:GetChildren()) do checkAndAddSoul(item) end
        local debree = Workspace:FindFirstChild("Debree")
        if debree then
            -- FIX: souls can be nested, scan descendants not just children
            for _, item in ipairs(debree:GetDescendants()) do
                if item:IsA("Model") and (item.Name == "Weak Soul" or item.Name == "Strong Soul" or item.Name == "Brave Soul") then
                    checkAndAddSoul(item)
                end
            end
            for _, item in ipairs(debree:GetChildren()) do checkAndAddSoul(item) end
        end
        if lFolder then for _, item in ipairs(lFolder:GetChildren()) do checkAndAddSoul(item) end end
        for _, tag in ipairs({"Soul", "Souls", "DemonSoul"}) do
            for _, item in ipairs(cs:GetTagged(tag)) do checkAndAddSoul(item) end
        end

        for _, s in ipairs(candidateSouls) do
            local p = s.prompt
            local pos = s.pos
            local part = s.part

            local savedCF = myRoot.CFrame
            -- FIX MCP live: souls carry SoulPrompt/Claim (hold=1, maxD=10) starting
            -- DISABLED at spawn; the server ignores activation while disabled, so we
            -- must WAIT for Enabled==true (claimable) before firing. Proximity sweep
            -- alone never collects (CanTouch=false on all soul parts).
            myRoot.CFrame = CFrame.new(pos + Vector3.new(0, 0.6, 0))
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.12)

            if p then
                -- PROVEN MCP live: fireproximityprompt does NOT collect SoulPrompt
                -- (GONE=false x40+), but legit InputHoldBegin/End DOES (GONE=true).
                -- Wait for server to enable the prompt (spawn flight ~1s). Timeout 3s.
                local waitT = 0
                while not p.Enabled and waitT < 3.0 and p.Parent do
                    task.wait(0.1)
                    waitT = waitT + 0.1
                end
                local oldDist = p.MaxActivationDistance
                pcall(function()
                    p.MaxActivationDistance = 60
                end)
                -- Legit hold (keep server HoldDuration, don't zero it: server may
                -- validate hold length via began/ended timestamps).
                local needHold = 0
                pcall(function() needHold = tonumber(p.HoldDuration) or 0 end)
                if p.Enabled then
                    pcall(function() p:InputHoldBegin() end)
                    task.wait(math.min(needHold + 0.4, 3.0))
                    pcall(function() p:InputHoldEnd() end)
                    -- Fallback: classic fire + key press in case hold API is restricted.
                    pcall(fireproximityprompt, p)
                else
                    pcall(fireproximityprompt, p)
                end
                local promptKey = (p.KeyboardKeyCode ~= Enum.KeyCode.Unknown and p.KeyboardKeyCode) or Enum.KeyCode.T
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                    task.wait(0.12)
                    VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                end
                pcall(function()
                    p.MaxActivationDistance = oldDist
                end)
            end

            if part then
                pcall(function()
                    firetouchinterest(myRoot, part, 0)
                    task.wait(0.03)
                    firetouchinterest(myRoot, part, 1)
                end)
            end
            -- Magnet sweep: orbit pivot to trigger server pickup (souls despawn fast)
            for _, off in ipairs({Vector3.new(2,0.6,0), Vector3.new(-2,0.6,0), Vector3.new(0,0.6,2), Vector3.new(0,0.6,-2)}) do
                if not s.model or s.model.Parent then
                    myRoot.CFrame = CFrame.new(pos + off)
                    task.wait(0.06)
                else
                    break
                end
            end
            task.wait(0.1)

            myRoot.CFrame = savedCF
            soulCount = soulCount + 1
        end

        Kyoka:Notify({
            Title = "Auto Collect",
            Content = string.format("%d Chests, %d Items & %d Souls collected!", chestCount, lootCount, soulCount),
            Type = "success",
            Duration = 4
        })
    end
})

-- ==================== SUB-PAGE PLAYERS FARM ====================
local PlayerFarmGroup = PlayerPage:AddGroup("Player Auto Farm", "Left")
local PlayerControlsGroup = PlayerPage:AddGroup("Target & Quick Actions", "Right")

local function GetOnlinePlayerNames()
    local names = { "All Players" }
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

PlayerFarmToggleObj = PlayerFarmGroup:AddToggle("PlayerFarmToggle", {
    Text = "Enable Player Auto Farm",
    Default = false,
    Tooltip = "Automatically teleports to and attacks players with safe anti-void platform!",
    Callback = function(val)
        Hub.Farm.PlayerFarm = val
        if not val then
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            RemoveFarmPlatform()
            local root = GetRootPart()
            if root then root.AssemblyLinearVelocity = Vector3.zero end
        else
            -- Désactiver Mob Farm pour éviter le conflit de cible
            if Hub.Farm.AutoFarm then
                Hub.Farm.AutoFarm = false
            end
            Kyoka:Notify({ Title = "Player Farm", Content = "Player Farm enabled!", Type = "success" })
        end
    end
}):AddKeybind("PlayerFarmKey", { Default = Enum.KeyCode.H, Mode = "Toggle" })

PlayerFarmGroup:AddDropdown("PlayerSafeModeDropdown", {
    Text = "Player Position Mode",
    Values = { "Overhead (Safe - Recommended)", "In Front (Classic)" },
    Default = "Overhead (Safe - Recommended)",
    Tooltip = "Overhead positions you above the player with safety platform, out of normal reach!",
    Callback = function(val)
        if string.find(val, "Overhead") then
            Hub.Farm.PlayerSafeMode = "Overhead"
        else
            Hub.Farm.PlayerSafeMode = "In Front"
        end
    end
})

PlayerFarmGroup:AddSlider("PlayerHeightOffsetSlider", {
    Text = "Vertical Height Offset",
    Min = 2.0,
    Max = 9.0,
    Default = 3.2,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(val)
        Hub.Farm.PlayerHeightOffset = val
    end
})

PlayerFarmGroup:AddSlider("PlayerDistanceSlider", {
    Text = "Horizontal Distance",
    Min = 1.5,
    Max = 8.0,
    Default = 2.5,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(val)
        Hub.Farm.PlayerDistance = val
    end
})

local playerDropdown = PlayerControlsGroup:AddDropdown("SelectedPlayerDropdown", {
    Text = "Target Player",
    Values = GetOnlinePlayerNames(),
    Default = "All Players",
    Tooltip = "Choose a specific player to hunt down, or select 'All Players' to hunt the closest one!",
    Callback = function(val)
        Hub.Farm.SelectedPlayer = val
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
    end
})

PlayerControlsGroup:AddButton("Refresh Player List", {
    Callback = function()
        local updatedList = GetOnlinePlayerNames()
        if playerDropdown and playerDropdown.SetValues then
            playerDropdown:SetValues(updatedList, true)
            Kyoka:Notify({ Title = "Players", Content = string.format("%d players online", #updatedList - 1), Type = "info" })
        end
    end
})

PlayerControlsGroup:AddButton("Teleport To Target Player", {
    Accent = true,
    Callback = function()
        local target = nil
        if Hub.Farm.SelectedPlayer == "All Players" then
            target = GetClosestPlayer("All Players")
        else
            for _, p in ipairs(GetAlivePlayers()) do
                local sLow = string.lower(Hub.Farm.SelectedPlayer or "")
                local nLow = string.lower(p.Name or "")
                local dLow = string.lower(p.DisplayName or "")
                if nLow == sLow or dLow == sLow or sLow:find(nLow, 1, true) then
                    target = p
                    break
                end
            end
        end

        if target and target.Position then
            TeleportToPosition(target.Position + Vector3.new(0, 3, 0), target.Name)
        else
            local inServer = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and (plr.Name == Hub.Farm.SelectedPlayer or plr.DisplayName == Hub.Farm.SelectedPlayer) then
                    inServer = true
                    break
                end
            end
            if inServer then
                Kyoka:Notify({ Title = "Teleport", Content = "Target player is respawning...", Type = "warning" })
            else
                Kyoka:Notify({ Title = "Teleport", Content = "Target player not found in server", Type = "error" })
            end
        end
    end
})

-- ==================== SUB-PAGE QUESTS FARM ====================
local QuestOptionsList = { "Auto Best Quest (By Level)" }
for _, q in ipairs(QuestDatabase) do
    table.insert(QuestOptionsList, q.DisplayName)
end

local AutoQuestGroup = QuestPage:AddGroup("Auto Quest Automation", "Left")
local QuestStatusGroup = QuestPage:AddGroup("Current Quest & Controls", "Right")

AutoQuestToggleObj = AutoQuestGroup:AddToggle("AutoQuestToggle", {
    Text = "Enable Auto Quest (Auto EXP)",
    Default = false,
    Tooltip = "Automatically takes optimal level-appropriate quests, tracks tasks, kills targets, and repeats for infinite EXP!",
    Callback = function(val)
        Hub.Farm.AutoQuest = val
        if val then
            -- Activer également Auto Farm si pas encore activé pour combattre les cibles
            if not Hub.Farm.AutoFarm then
                Hub.Farm.AutoFarm = true
                SyncToggle(AutoFarmToggleObj, true)
            end
            Kyoka:Notify({ Title = "Auto Quest", Content = "Auto Quest loop active! Auto-taking level quests...", Type = "success" })
        else
            -- Arret franc : quete + farm, sinon le perso continue a se battre et on croit que rien ne s'est coupé
            Hub.IsInteractingQuest = false
            Hub.Farm.AutoFarm = false
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            RemoveFarmPlatform()
            local root = GetRootPart()
            if root then root.AssemblyLinearVelocity = Vector3.zero end
            SyncToggle(AutoFarmToggleObj, false)
            Kyoka:Notify({ Title = "Auto Quest", Content = "Auto Quest + Farm disabled!", Type = "warning" })
        end
    end
}):AddKeybind("AutoQuestKey", { Default = Enum.KeyCode.B, Mode = "Toggle" })

Hub.Farm._QuestRaceLabel = AutoQuestGroup:AddLabel("Detected Race: ... | Quests filtered by the game rules")

AutoQuestGroup:AddDropdown("QuestSelectionDropdown", {
    Text = "Selected Quest",
    Values = QuestOptionsList,
    Default = "Auto Best Quest (By Level)",
    Tooltip = "Choose a specific quest to repeat, or let the hub automatically pick the highest XP quest for your level!",
    Callback = function(val)
        Hub.Farm.QuestMode = val
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
    end
})

AutoQuestGroup:AddToggle("AutoAcceptNextQuest", {
    Text = "Instant Re-Take on Complete",
    Default = true,
    Tooltip = "Immediately takes a new quest the moment current quest tasks are completed!",
    Callback = function(val)
        Hub.Farm.AutoAcceptNextQuest = val
    end
})

QuestStatusGroup:AddButton("Take Best Level Quest Now", {
    Accent = true,
    Callback = function()
        local lvl = GetPlayerLevel()
        local best = GetBestQuestForLevel(lvl)
        if best then
            local active = GetActiveQuest()
            if active and active.IsFinished then
                CancelCurrentQuest()
                task.wait(0.2)
            end

            local ok = RequestAddQuest(best.Name)
            if ok then
                Hub.Farm.TargetMob = best.MobName
                Hub.Farm.MobCategory = best.Category
                Hub.Farm.RegionFilter = best.Region
                Hub.LockedTarget = nil
                Hub.CurrentTarget = nil
                Kyoka:Notify({ Title = "Quest Accepted", Content = string.format("Accepted: %s (Lv %d+, Your Lv: %d)", best.DisplayName, best.MinLevel, lvl), Type = "success", Duration = 4 })
                if best.MobWp then
                    TeleportToPosition(best.MobWp, best.MobName .. " Area")
                    local myRoot = GetRootPart()
                    if myRoot then
                        pcall(function()
                            local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
                            AreaLocator:Update(myRoot)
                        end)
                    end
                end
            else
                Kyoka:Notify({ Title = "Quest Notice", Content = string.format("Could not add quest %s", best.DisplayName), Type = "warning" })
            end
        end
    end
})

QuestStatusGroup:AddButton("Teleport To Quest Mob Spawn", {
    Callback = function()
        local active = GetActiveQuest()
        local targetMob = nil
        local targetWp = nil

        if active and active.Tasks then
            for taskName, taskData in pairs(active.Tasks) do
                for _, qDef in ipairs(QuestDatabase) do
                    if qDef.Tasks[taskName] then
                        targetMob = qDef.Tasks[taskName]
                        targetWp = qDef.MobWp
                        break
                    end
                end
                if targetMob then break end
            end
        end

        if not targetMob then
            local lvl = GetPlayerLevel()
            local best = GetBestQuestForLevel(lvl)
            if best then
                targetMob = best.MobName
                targetWp = best.MobWp
            end
        end

        if targetWp then
            TeleportToPosition(targetWp, (targetMob or "Quest Mob") .. " Spawn")
        else
            Kyoka:Notify({ Title = "Teleport", Content = "No active quest mob waypoint found", Type = "error" })
        end
    end
})

QuestStatusGroup:AddButton("Check Active Quest Status", {
    Callback = function()
        local lvl = GetPlayerLevel()
        local active = GetActiveQuest()
        if active then
            local taskStr = ""
            for tName, tData in pairs(active.Tasks) do
                taskStr = taskStr .. string.format("%s: %d/%d ", tName, tData.Current, tData.Max)
            end
            Kyoka:Notify({
                Title = "Active Quest",
                Content = string.format("Player Lv %d | %s | %s", lvl, active.Name, taskStr),
                Type = "info",
                Duration = 6
            })
        else
            Kyoka:Notify({
                Title = "Active Quest",
                Content = string.format("Player Lv %d | No active quest in progress", lvl),
                Type = "info",
                Duration = 4
            })
        end
    end
})

QuestStatusGroup:AddButton("Reset Quest Blacklist", {
    Tooltip = "Clears quests temporarily skipped because the NPC refused them (missing prerequisites).",
    Callback = function()
        ClearQuestBlacklist()
        Kyoka:Notify({ Title = "Quest Blacklist", Content = "Quest blacklist cleared. All quests available again.", Type = "success" })
    end
})

QuestStatusGroup:AddButton("Cancel Active Quest (Instant Abandon)", {
    Accent = false,
    Callback = function()
        local active = GetActiveQuest()
        local ok = CancelCurrentQuest()
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
        if ok or active then
            Kyoka:Notify({
                Title = "Quest Abandoned",
                Content = "Active quest successfully cancelled and removed!",
                Type = "success",
                Duration = 4
            })
        else
            Kyoka:Notify({
                Title = "Quest Notice",
                Content = "No active quest was found to cancel.",
                Type = "info",
                Duration = 3
            })
        end
    end
})

QuestStatusGroup:AddButton("STOP ALL (Farm + Quest)", {
    Accent = false,
    Tooltip = "Desactive Auto Farm ET Auto Quest, nettoie cible + plateforme. Arret franc garanti.",
    Callback = function()
        Hub.Farm.AutoQuest = false
        Hub.Farm.AutoFarm = false
        Hub.Farm.PlayerFarm = false
        Hub.Training.AutoStay = false
        Hub.IsInteractingQuest = false
        Hub.LockedTarget = nil
        Hub.CurrentTarget = nil
        RemoveFarmPlatform()
        local root = GetRootPart()
        if root then root.AssemblyLinearVelocity = Vector3.zero end
        SyncToggle(AutoQuestToggleObj, false)
        SyncToggle(AutoFarmToggleObj, false)
        SyncToggle(PlayerFarmToggleObj, false)
        Kyoka:Notify({ Title = "STOP ALL", Content = "Farm + Quest + Player Farm disabled!", Type = "error", Duration = 4 })
    end
})

-- ==================== SUB-PAGE TRAINING ====================
local TrainingLeftGroup = TrainingPage:AddGroup("Minigame Automations", "Left")
local TrainingRightGroup = TrainingPage:AddGroup("Training Stations (Teleports)", "Right")

TrainingLeftGroup:AddToggle("AutoMinigamesToggle", {
    Text = "Instant Auto-Win Minigames",
    Default = true,
    Callback = function(val)
        Hub.Training.AutoMinigames = val
        if val then
            Kyoka:Notify({ Title = "Auto Training", Content = "Instant minigame auto-win enabled (100% score)!", Type = "info" })
        end
    end
})

-- Les mini-jeux d'entraînement sont lancés par le SERVEUR (impossible de les
-- démarrer côté client) : l'auto-win ci-dessus les termine instantanément dès
-- qu'ils sont actifs. Ce toggle garde simplement le joueur sur la station.
local trainingStations = {
    ["Meditation"] = Vector3.new(-1890.5, 318.3, 34.1),
    ["Pushups"] = Vector3.new(-1680.2, 318.8, -200.0),
    ["Squat Rack"] = Vector3.new(-1827.9, 317.1, 76.2),
    ["Cup Game"] = Vector3.new(-1893.2, 318.7, -3.6),
    ["Target Shooting"] = Vector3.new(-1495.3, 318.0, -134.1),
    ["Boulder Push"] = Vector3.new(-311.6, 1074.6, -569.6),
    ["Boulder Split"] = Vector3.new(-1046.8, 1133.5, -616.8),
    ["Parkour Dungeon"] = Vector3.new(130.3, 1074.1, -1301.8),
}

TrainingLeftGroup:AddDropdown("TrainingStationDropdown", {
    Text = "Training Station",
    Values = { "Meditation", "Pushups", "Squat Rack", "Cup Game", "Target Shooting", "Boulder Push", "Boulder Split", "Parkour Dungeon" },
    Default = "Meditation",
    Callback = function(val)
        Hub.Training.StationName = val
    end
})

TrainingLeftGroup:AddToggle("AutoStayTrainingToggle", {
    Text = "Auto-Stay at Training Station (AFK)",
    Default = false,
    Tooltip = "Keeps teleporting you back onto the selected training station so you never drift off while training.",
    Callback = function(val)
        Hub.Training.AutoStay = val
        if val then
            Kyoka:Notify({ Title = "Auto Training", Content = "Auto-stay enabled on: " .. tostring(Hub.Training.StationName or "Meditation"), Type = "info" })
        end
    end
})

TrainingRightGroup:AddButton("TP Sabito (Boulder Split)", {
    Accent = true,
    Callback = function()
        TeleportToPosition(Vector3.new(-1046.8, 1133.5, -628.8), "Sabito (Boulder Split)")
    end
})

TrainingRightGroup:AddButton("TP Boulder Push", {
    Callback = function()
        TeleportToPosition(Vector3.new(-306.3, 1073.2, -593.9), "Boulder Push")
    end
})

TrainingRightGroup:AddButton("TP Parkour Dungeon", {
    Callback = function()
        TeleportToPosition(Vector3.new(116.3, 1069.1, -1290.9), "Parkour Dungeon")
    end
})

TrainingRightGroup:AddButton("TP Power Statue", {
    Callback = function()
        TeleportToPosition(Vector3.new(-697.4, 1386.5, -1914.3), "Power Statue")
    end
})

-- ==================== SUB-PAGE FISH & UTILITY ====================
local FishGroup = UtilityPage:AddGroup("Auto Fish", "Left")
local RefineGroup = UtilityPage:AddGroup("Auto Refine (Hagane)", "Left")
local SellGroup = UtilityPage:AddGroup("Auto Sell (Ginzo)", "Right")

local FishStatusLabel = FishGroup:AddLabel("Status: idle | Caught: 0", { Color = "TextDim" })

FishGroup:AddToggle("AutoFishToggle", {
    Text = "Enable Auto Fish",
    Default = false,
    Tooltip = "Equips your fishing rod, finds water, casts, auto-wins the bite minigame and collects the catch. Requires a Fishing Rod in your inventory.",
    Callback = function(val)
        Hub.Fish.Auto = val
        Hub.Fish.State = "idle"
        Hub.Fish.LastAction = 0
        if val then
            pcall(function() Util.RefreshFishingBiteHook() end)
            pcall(function() Util.RefreshCatchTracker() end)
            local rod = Util.FindRodItem()
            if not rod then
                Kyoka:Notify({ Title = "Auto Fish", Content = "No Fishing Rod! Buy one from Fisherman Jeso - requires the 'Earn a Fishing Permit' quest (Lv 45 + 5000 Wen).", Type = "error", Duration = 10 })
            else
                Kyoka:Notify({ Title = "Auto Fish", Content = "Fishing with: " .. rod.Name, Type = "success" })
            end
        end
    end
})

FishGroup:AddToggle("AutoSellFishToggle", {
    Text = "Auto-Sell Fish (when full stacks)",
    Default = true,
    Tooltip = "Sells caught fish to Ginzo automatically every 2 minutes while Auto Fish is running.",
    Callback = function(val)
        Hub.Fish.AutoSellFish = val
    end
})

FishGroup:AddButton("Fish Once Now (single cast)", {
    Accent = true,
    Callback = function()
        task.spawn(function()
            local slot, rodName = Util.EnsureRodEquipped()
            if not slot then
                Kyoka:Notify({ Title = "Auto Fish", Content = "No Fishing Rod in inventory.", Type = "error" })
                return
            end
            local water, dist = Util.FindWaterPoint(150)
            if not water then
                Kyoka:Notify({ Title = "Auto Fish", Content = "No water nearby - teleporting to a fishing spot...", Type = "info" })
                local myRoot = GetRootPart()
                local best, bestD = nil, math.huge
                for _, s in ipairs(Util.FishingSpots) do
                    local d = (s - myRoot.Position).Magnitude
                    if d < bestD then best, bestD = s, d end
                end
                if best then
                    TeleportToPosition(best, "Fishing Spot")
                    task.wait(1.2)
                    water = Util.FindWaterPoint(150)
                end
            end
            if not water then
                Kyoka:Notify({ Title = "Auto Fish", Content = "Still no water found nearby.", Type = "warning" })
                return
            end
            Util.CastRod(water)
            Kyoka:Notify({ Title = "Auto Fish", Content = "Cast! Waiting for a bite...", Type = "info" })
        end)
    end
})

FishGroup:AddButton("Sell All Fish Now", {
    Callback = function()
        task.spawn(function() Util.DoSellNow("Fish Only") end)
    end
})

FishGroup:AddButton("AUTO UNLOCK FISHING (Permit + Rod)", {
    Accent = true,
    Tooltip = "Full auto: accepts the permit quest at Sofen (needs Lv 45 + 5000 Wen), collects the Permit Stamp, turns it in, then buys the Basic Fishing Rod at Jeso.",
    Callback = function()
        task.spawn(function()
            local ok, reason = Util.UnlockFishing()
            if not ok and reason == "level" then
                Kyoka:Notify({ Title = "Fishing Unlock", Content = "Tip: enable Auto Quest on the Quests Farm page to reach Lv 45 first.", Type = "info", Duration = 8 })
            end
        end)
    end
})

FishGroup:AddToggle("AutoBuyRodToggle", {
    Text = "Auto-Buy Rod When Permit Ready",
    Default = false,
    Tooltip = "Checks every 60s: as soon as you own the Fishing Permit, buys the Basic Fishing Rod automatically (3500 Wen).",
    Callback = function(val)
        Hub.Fish.AutoBuyRod = val
        if val then
            Kyoka:Notify({ Title = "Auto Fish", Content = "Auto-buy rod armed (needs the Fishing Permit).", Type = "info" })
        end
    end
})

FishGroup:AddButton("Buy Basic Rod Now", {
    Callback = function()
        task.spawn(function()
            local ok, res = Util.BuyFishingRod("Basic Fishing Rod")
            if ok then
                Kyoka:Notify({ Title = "Fishing", Content = "Basic Fishing Rod bought!", Type = "success" })
            else
                local hasPermit = Util.HasFishingPermit()
                Kyoka:Notify({
                    Title = "Fishing",
                    Content = hasPermit and "Purchase refused (need 3500 Wen)." or "Purchase refused: you need the 'Earn a Fishing Permit' quest done (Lv 45).",
                    Type = "error",
                    Duration = 8,
                })
            end
        end)
    end
})

FishGroup:AddButton("TP: Permit Stamp (fishing unlock)", {
    Tooltip = "The 'Earn a Fishing Permit' quest (Sofen, Lv 45, 5000 Wen) needs this stamp. Rods can't be bought without the permit.",
    Callback = function()
        TeleportToPosition(Vector3.new(-449.76, 800.36, 750.01), "Permit Stamp")
    end
})

FishGroup:AddButton("TP: Mistfall Fishing Dock", {
    Callback = function()
        TeleportToPosition(Vector3.new(623, 948, -398), "Fishing Dock")
    end
})

-- --- Auto Refine ---
local RefineStatusLabel = RefineGroup:AddLabel("Idle | Attempts: 0", { Color = "TextDim" })

local RefineDropdown = RefineGroup:AddDropdown("RefineItemDropdown", {
    Text = "Item To Refine",
    Values = { "(none refinable)" },
    Default = "(none refinable)",
    Tooltip = "Only refinable items (rods, weapons with the Refinable flag) can be refined at Hagane.",
    Callback = function(val)
        if val ~= "(none refinable)" then
            Hub.Refine.ItemName = val
        end
    end
})

RefineGroup:AddButton("Refresh Refinable Items", {
    Callback = function()
        local items = Util.GetRefinableItems()
        local names = {}
        for _, item in ipairs(items) do
            table.insert(names, item.Name)
        end
        if #names == 0 then names = { "(none refinable)" } end
        if RefineDropdown and RefineDropdown.SetValues then
            RefineDropdown:SetValues(names, true)
        end
        Kyoka:Notify({ Title = "Auto Refine", Content = string.format("%d refinable item(s) found.", #items), Type = "info" })
    end
})

RefineGroup:AddToggle("UseGuardToggle", {
    Text = "Use Refinement Guard",
    Default = false,
    Tooltip = "Consumes a Refinement Guard on each attempt to boost success odds.",
    Callback = function(val)
        Hub.Refine.UseGuard = val
    end
})

RefineGroup:AddToggle("AutoRefineToggle", {
    Text = "Enable Auto Refine",
    Default = false,
    Tooltip = "Teleports to Refiner Hagane and keeps refining the selected item until it hits max level or you run out of Wen/ore.",
    Callback = function(val)
        Hub.Refine.Auto = val
        Hub.Refine.LastAttempt = 0
        if val then
            if not Hub.Refine.ItemName then
                local items = Util.GetRefinableItems()
                if #items > 0 then Hub.Refine.ItemName = items[1].Name end
            end
            if Hub.Refine.ItemName then
                Kyoka:Notify({ Title = "Auto Refine", Content = "Refining: " .. Hub.Refine.ItemName, Type = "success" })
            else
                Kyoka:Notify({ Title = "Auto Refine", Content = "No refinable item found. Get a rod/weapon first.", Type = "warning" })
                Hub.Refine.Auto = false
            end
        end
    end
})

RefineGroup:AddButton("Refine Once Now", {
    Callback = function()
        task.spawn(function()
            local name = Hub.Refine.ItemName
            if not name then
                local items = Util.GetRefinableItems()
                if #items > 0 then name = items[1].Name Hub.Refine.ItemName = name end
            end
            if not name then
                Kyoka:Notify({ Title = "Auto Refine", Content = "No refinable item selected.", Type = "warning" })
                return
            end
            Util.TravelToHagane()
            local res, err = Util.DoRefineAttempt(name, Hub.Refine.UseGuard)
            if res == nil then
                Kyoka:Notify({ Title = "Auto Refine", Content = "Refine failed: " .. tostring(err), Type = "error" })
            elseif type(res) == "table" then
                Kyoka:Notify({ Title = "Auto Refine", Content = string.format("Outcome: %s%s", tostring(res.Outcome), res.Reason and (" (" .. tostring(res.Reason) .. ")") or ""), Type = res.Outcome == "Fail" and "warning" or "success" })
            end
        end)
    end
})

-- --- Auto Sell ---
local SellStatusLabel = SellGroup:AddLabel("Earned: 0 Wen | Idle", { Color = "TextDim" })

SellGroup:AddDropdown("SellModeDropdown", {
    Text = "Sell Mode",
    Values = { "Fish Only", "Wen Items Only", "All Sellable (No Equipment)" },
    Default = "All Sellable (No Equipment)",
    Tooltip = "Fish Only = fish. Wen Items Only = items that pay Wen (fish, coin pouches...). All Sellable = everything the game buys, except equipped gear.",
    Callback = function(val)
        Hub.Sell.Mode = val
    end
})

SellGroup:AddToggle("AutoSellToggle", {
    Text = "Enable Auto Sell (every 90s)",
    Default = false,
    Tooltip = "Periodically teleports to Ginzo and sells everything matching the selected mode.",
    Callback = function(val)
        Hub.Sell.Auto = val
        Hub.Sell.LastSell = 0
        if val then
            Kyoka:Notify({ Title = "Auto Sell", Content = "Auto-sell enabled (" .. tostring(Hub.Sell.Mode) .. ").", Type = "success" })
        end
    end
})

SellGroup:AddButton("Sell Now", {
    Accent = true,
    Callback = function()
        task.spawn(function() Util.DoSellNow(Hub.Sell.Mode) end)
    end
})

SellGroup:AddButton("Preview Sellable Items", {
    Callback = function()
        local selection = Util.BuildSellSelection(Hub.Sell.Mode)
        local names = {}
        for name, n in pairs(selection) do table.insert(names, name .. " x" .. n) end
        if #names == 0 then
            Kyoka:Notify({ Title = "Auto Sell", Content = "Nothing matches mode: " .. tostring(Hub.Sell.Mode), Type = "info" })
        else
            Kyoka:Notify({ Title = "Auto Sell Preview (" .. #names .. ")", Content = table.concat(names, ", "), Type = "info", Duration = 8 })
        end
    end
})

-- ==================== TAB CLAN SPINS ====================
local SpinTab = Window:AddTab("Spins")
local SpinPage = SpinTab:AddPage("Clan Spins")
local SpinMainGroup = SpinPage:AddGroup("Auto Clan Spin", "Left")
local SpinInfoGroup = SpinPage:AddGroup("Spin Status & Inventory", "Right")

local clanListAll = {
    -- Supreme
    "Kamado", "Rengoku", "Soyama", "Uzui",
    -- Mythic
    "Agatsuma", "Douma", "Himejima", "Iguro", "Shinazugawa", "Tamayo",
    -- Legendary
    "Kocho", "Shabana", "Tomioka", "Ubuyashiki",
    -- Rare
    "Makomo", "Sabito", "Susumaru", "Urokodaki", "Yahaba",
    -- Uncommon
    "Aori", "Aoshima", "Kaneki", "Kurotsume", "Yamagiri",
    -- Common
    "Ando", "Aokawa", "Fujiwara", "Fukukoshi", "Hagiwara", "Hozumi", "Kanzaki", "Kazetani", "Kuroaki", "Kurosaki", "Mori", "Saito", "Sakurai", "Suzuki", "Toka", "Tsukino", "Yukimori"
}

local initialClan = GetCurrentClan()
local initialSpins = GetTotalSpins()
local currentClanLabel = SpinInfoGroup:AddLabel("Current Clan: " .. tostring(initialClan))
local totalSpinsLabel = SpinInfoGroup:AddLabel("Spins Left: " .. tostring(initialSpins))
local lastRollLabel = SpinInfoGroup:AddLabel("Last Rolled: None")

local function UpdateRealtimeSpinLabels()
    pcall(function()
        local clan = GetCurrentClan()
        local spins = GetTotalSpins()
        if currentClanLabel then currentClanLabel:SetText("Current Clan: " .. tostring(clan)) end
        if totalSpinsLabel then totalSpinsLabel:SetText("Spins Left: " .. tostring(spins)) end
    end)
end

-- Attacher des écouteurs en temps réel dès que les valeurs changent sur le serveur
pcall(function()
    local folder = GetPlayerDataFolder()
    if folder then
        local cVal = folder:FindFirstChild("Clan")
        local spFolder = folder:FindFirstChild("Spinning")
        if cVal then
            table.insert(Hub.Connections, cVal:GetPropertyChangedSignal("Value"):Connect(UpdateRealtimeSpinLabels))
        end
        if spFolder then
            local freeV = spFolder:FindFirstChild("FreeClanSpins")
            local normV = spFolder:FindFirstChild("Spins")
            if freeV then
                table.insert(Hub.Connections, freeV:GetPropertyChangedSignal("Value"):Connect(UpdateRealtimeSpinLabels))
            end
            if normV then
                table.insert(Hub.Connections, normV:GetPropertyChangedSignal("Value"):Connect(UpdateRealtimeSpinLabels))
            end
        end
    end
end)

local autoSpinThread = nil
local autoSpinToggle

local function StopAutoSpin(uncheckUI)
    Hub.Spin.AutoSpin = false
    if uncheckUI and autoSpinToggle then
        pcall(function() autoSpinToggle:Set(false, true) end)
    end
    if autoSpinThread and coroutine.running() ~= autoSpinThread then
        pcall(task.cancel, autoSpinThread)
        autoSpinThread = nil
    end
end

local function StartAutoSpin()
    if autoSpinThread and coroutine.running() ~= autoSpinThread then
        pcall(task.cancel, autoSpinThread)
        autoSpinThread = nil
    end

    Hub.Spin.AutoSpin = true

    autoSpinThread = task.spawn(function()
        local consecutiveFailures = 0
        while Hub.Spin.AutoSpin and Hub.Alive do
            local totalSpins = GetTotalSpins()
            if totalSpins <= 0 then
                StopAutoSpin(true)
                Kyoka:Notify({ Title = "Auto Spin", Content = "No spins available!", Type = "warning" })
                break
            end

            -- Attendre que le spin précédent soit entièrement validé par le serveur
            local waitStart = os.clock()
            while LocalPlayer:GetAttribute("PendingClanSpin") ~= nil and (os.clock() - waitStart < 1.5) do
                task.wait(0.02)
            end

            local ok, res = pcall(function()
                return SignalFunction.ToServer("ClanSpin")
            end)

            if ok and typeof(res) == "string" then
                -- Valider immédiatement la transaction auprès du serveur
                pcall(function() SignalEvent.ToServer("ClanSpinComplete") end)

                -- Attendre le clear de PendingClanSpin pour éviter tout rejet 'nil'
                local clearStart = os.clock()
                while LocalPlayer:GetAttribute("PendingClanSpin") ~= nil and (os.clock() - clearStart < 0.5) do
                    task.wait(0.02)
                end

                consecutiveFailures = 0
                Hub.Spin.LastResult = res
                local tier = Clans and Clans.TierOf(res)
                local tierName = tier and tier.name or "Common"
                local rarityNum = tier and tier.rarity or 1

                pcall(function()
                    if lastRollLabel then lastRollLabel:SetText("Last Rolled: " .. res .. " (" .. tierName .. ")") end
                end)
                UpdateRealtimeSpinLabels()

                -- Vérifier les conditions d'arrêt
                local stop = false
                if Hub.Spin.Mode == "Specific Clan" then
                    if string.lower(res) == string.lower(tostring(Hub.Spin.TargetClan or "")) then
                        stop = true
                    end
                else
                    -- Rareté : Mythic ou supérieur par défaut (rarity >= 6)
                    if Hub.Spin.StopRarity == "Supreme Only" and rarityNum >= 7 then
                        stop = true
                    elseif Hub.Spin.StopRarity == "Legendary+" and rarityNum >= 5 then
                        stop = true
                    elseif rarityNum >= 6 then
                        stop = true
                    end
                end

                if stop then
                    StopAutoSpin(true)
                    Kyoka:Notify({
                        Title = "Auto Spin Completed!",
                        Content = "Rolled: " .. res .. " [" .. tierName .. "]",
                        Type = "success",
                        Duration = 8
                    })
                    break
                end
            else
                -- Si rejet temporaire ou délai serveur, attendre et relancer
                pcall(function() SignalEvent.ToServer("ClanSpinComplete") end)
                consecutiveFailures = consecutiveFailures + 1
                if consecutiveFailures >= 8 then
                    StopAutoSpin(true)
                    Kyoka:Notify({ Title = "Auto Spin", Content = "Spin refused by server (check spins / cooldown). Stopped.", Type = "error", Duration = 5 })
                    break
                end
                task.wait(0.25)
            end

            task.wait((Hub.Spin.Delay or 0.15) * (0.9 + math.random() * 0.35))
        end
        autoSpinThread = nil
    end)
end

autoSpinToggle = SpinMainGroup:AddToggle("AutoSpinToggle", {
    Text = "Enable Fast Auto Spin",
    Default = false,
    Callback = function(val)
        if val then
            Kyoka:Notify({ Title = "Auto Spin", Content = "Fast Auto Clan Spin enabled!", Type = "info" })
            StartAutoSpin()
        else
            StopAutoSpin(false)
        end
    end
})

SpinMainGroup:AddDropdown("SpinModeDropdown", {
    Text = "Stop Condition Mode",
    Values = { "Stop on Rarity", "Stop on Specific Clan" },
    Default = "Stop on Rarity",
    Callback = function(val)
        Hub.Spin.Mode = (val == "Stop on Rarity") and "Rarity" or "Specific Clan"
    end
})

SpinMainGroup:AddDropdown("StopRarityDropdown", {
    Text = "Target Rarity (Stop At)",
    Values = { "Mythic or Higher (Mythic/Supreme)", "Supreme Only", "Legendary or Higher" },
    Default = "Mythic or Higher (Mythic/Supreme)",
    Callback = function(val)
        if val == "Supreme Only" then
            Hub.Spin.StopRarity = "Supreme Only"
        elseif val == "Legendary or Higher" then
            Hub.Spin.StopRarity = "Legendary+"
        else
            Hub.Spin.StopRarity = "Mythic+"
        end
    end
})

SpinMainGroup:AddDropdown("TargetClanDropdown", {
    Text = "Target Specific Clan",
    Values = clanListAll,
    Default = "Kamado",
    Callback = function(val)
        Hub.Spin.TargetClan = val
    end
})

SpinMainGroup:AddSlider("SpinSpeedSlider", {
    Text = "Spin Delay (Seconds)",
    Min = 0.12,
    Max = 0.5,
    Default = 0.15,
    Rounding = 2,
    Suffix = "s",
    Callback = function(val)
        Hub.Spin.Delay = val
    end
})

SpinInfoGroup:AddButton("Spin 1 Time Now", {
    Accent = true,
    Callback = function()
        if SignalFunction and SignalEvent then
            local ok, res = pcall(function() return SignalFunction.ToServer("ClanSpin") end)
            if ok and typeof(res) == "string" then
                pcall(function() SignalEvent.ToServer("ClanSpinComplete") end)
                local tier = Clans and Clans.TierOf(res)
                local tierName = tier and tier.name or "Common"
                lastRollLabel:SetText("Last Rolled: " .. res .. " (" .. tierName .. ")")
                UpdateRealtimeSpinLabels()
                Kyoka:Notify({ Title = "Spin Result", Content = res .. " [" .. tierName .. "]", Type = "success" })
            else
                Kyoka:Notify({ Title = "Spin Error", Content = "No spins left or network error", Type = "error" })
            end
        end
    end
})

-- ==================== SUB-PAGE BDA SPINS ====================
local BDAPage = SpinTab:AddPage("Blood Demon Arts")
local BDAMainGroup = BDAPage:AddGroup("Auto BDA Spin (Demons)", "Left")
local BDAInfoGroup = BDAPage:AddGroup("BDA Status & Inventory", "Right")

local bdaListAll = {
    "Arrow",
    "Blood Manipulation",
    "Cryokinesis",
    "Dream",
    "Obi Manipulation",
    "Pyrokenesis",
    "Reaper",
    "Shockwave",
    "Tamari"
}

local initialBDA = GetCurrentBDA()
local initialBDASpins = GetTotalBDASpins()
local currentBDALabel = BDAInfoGroup:AddLabel("Current BDA: " .. tostring(initialBDA))
local totalBDASpinsLabel = BDAInfoGroup:AddLabel("BDA Spins Left: " .. tostring(initialBDASpins))
local lastBDARollLabel = BDAInfoGroup:AddLabel("Last Rolled: None")

local function UpdateRealtimeBDALabels()
    pcall(function()
        local bda = GetCurrentBDA()
        local spins = GetTotalBDASpins()
        if currentBDALabel then currentBDALabel:SetText("Current BDA: " .. tostring(bda)) end
        if totalBDASpinsLabel then totalBDASpinsLabel:SetText("BDA Spins Left: " .. tostring(spins)) end
    end)
end

-- Écouteurs de mise à jour pour BDA
pcall(function()
    local folder = GetPlayerDataFolder()
    if folder then
        local powers = folder:FindFirstChild("Powers")
        local daVal = powers and powers:FindFirstChild("DemonArt")
        local spFolder = folder:FindFirstChild("Spinning")
        local bdaSpinsVal = spFolder and spFolder:FindFirstChild("FreeOtherSpins")
        if daVal then
            table.insert(Hub.Connections, daVal:GetPropertyChangedSignal("Value"):Connect(UpdateRealtimeBDALabels))
        end
        if bdaSpinsVal then
            table.insert(Hub.Connections, bdaSpinsVal:GetPropertyChangedSignal("Value"):Connect(UpdateRealtimeBDALabels))
        end
    end
end)

local autoSpinBDAThread = nil
local autoSpinBDAToggle

local function StopAutoSpinBDA(uncheckUI)
    Hub.Spin.BDA.AutoSpin = false
    if uncheckUI and autoSpinBDAToggle then
        pcall(function() autoSpinBDAToggle:Set(false, true) end)
    end
    if autoSpinBDAThread and coroutine.running() ~= autoSpinBDAThread then
        pcall(task.cancel, autoSpinBDAThread)
        autoSpinBDAThread = nil
    end
end

local function StartAutoSpinBDA()
    if autoSpinBDAThread and coroutine.running() ~= autoSpinBDAThread then
        pcall(task.cancel, autoSpinBDAThread)
        autoSpinBDAThread = nil
    end

    Hub.Spin.BDA.AutoSpin = true

    autoSpinBDAThread = task.spawn(function()
        local consecutiveFailures = 0
        while Hub.Spin.BDA.AutoSpin and Hub.Alive do
            local totalSpins = GetTotalBDASpins()
            if totalSpins <= 0 then
                StopAutoSpinBDA(true)
                Kyoka:Notify({ Title = "BDA Spin", Content = "No BDA spins available!", Type = "warning" })
                break
            end

            -- Attendre validation serveur
            local waitStart = os.clock()
            while LocalPlayer:GetAttribute("PendingEvilArtSpin") ~= nil and (os.clock() - waitStart < 1.5) do
                task.wait(0.02)
            end

            local ok, res = pcall(function()
                return SignalFunction.ToServer("EvilArtSpin")
            end)

            if ok and typeof(res) == "string" then
                pcall(function() SignalEvent.ToServer("EvilArtSpinComplete") end)

                local clearStart = os.clock()
                while LocalPlayer:GetAttribute("PendingEvilArtSpin") ~= nil and (os.clock() - clearStart < 0.5) do
                    task.wait(0.02)
                end

                consecutiveFailures = 0
                Hub.Spin.BDA.LastResult = res
                pcall(function()
                    if lastBDARollLabel then lastBDARollLabel:SetText("Last Rolled: " .. res) end
                end)
                UpdateRealtimeBDALabels()

                -- Condition d'arrêt
                local stop = false
                if Hub.Spin.BDA.Mode == "Specific BDA" then
                    if string.lower(res) == string.lower(tostring(Hub.Spin.BDA.TargetBDA or "")) then
                        stop = true
                    end
                else
                    -- Arrêt dès l'obtention d'un BDA non-vide
                    stop = true
                end

                if stop then
                    StopAutoSpinBDA(true)
                    Kyoka:Notify({
                        Title = "BDA Spin Completed!",
                        Content = "Rolled: " .. res,
                        Type = "success",
                        Duration = 8
                    })
                    break
                end
            else
                pcall(function() SignalEvent.ToServer("EvilArtSpinComplete") end)
                consecutiveFailures = consecutiveFailures + 1
                if consecutiveFailures >= 8 then
                    StopAutoSpinBDA(true)
                    Kyoka:Notify({ Title = "BDA Spin", Content = "BDA spin refused (Demon Art requires a Demon race or spins). Stopped.", Type = "error", Duration = 5 })
                    break
                end
                task.wait(0.25)
            end

            task.wait((Hub.Spin.BDA.Delay or 0.15) * (0.9 + math.random() * 0.35))
        end
        autoSpinBDAThread = nil
    end)
end

autoSpinBDAToggle = BDAMainGroup:AddToggle("AutoBDAToggle", {
    Text = "Enable Fast BDA Spin",
    Default = false,
    Callback = function(val)
        if val then
            Kyoka:Notify({ Title = "BDA Spin", Content = "Fast Auto BDA Spin enabled!", Type = "info" })
            StartAutoSpinBDA()
        else
            StopAutoSpinBDA(false)
        end
    end
})

BDAMainGroup:AddDropdown("BDASpinModeDropdown", {
    Text = "Stop Condition Mode",
    Values = { "Stop on Specific BDA", "Stop on Any BDA" },
    Default = "Stop on Specific BDA",
    Callback = function(val)
        Hub.Spin.BDA.Mode = (val == "Stop on Specific BDA") and "Specific BDA" or "Any"
    end
})

BDAMainGroup:AddDropdown("TargetBDADropdown", {
    Text = "Target BDA",
    Values = bdaListAll,
    Default = "Shockwave",
    Callback = function(val)
        Hub.Spin.BDA.TargetBDA = val
    end
})

BDAMainGroup:AddSlider("BDASpinSpeedSlider", {
    Text = "Spin Delay (Seconds)",
    Min = 0.12,
    Max = 0.5,
    Default = 0.15,
    Rounding = 2,
    Suffix = "s",
    Callback = function(val)
        Hub.Spin.BDA.Delay = val
    end
})

BDAInfoGroup:AddButton("Spin 1 BDA Now", {
    Accent = true,
    Callback = function()
        if SignalFunction and SignalEvent then
            local ok, res = pcall(function() return SignalFunction.ToServer("EvilArtSpin") end)
            if ok and typeof(res) == "string" then
                pcall(function() SignalEvent.ToServer("EvilArtSpinComplete") end)
                if lastBDARollLabel then lastBDARollLabel:SetText("Last Rolled: " .. res) end
                UpdateRealtimeBDALabels()
                Kyoka:Notify({ Title = "BDA Spin Result", Content = res, Type = "success" })
            else
                Kyoka:Notify({ Title = "Spin Error", Content = "Demons only or no spins left", Type = "error" })
            end
        end
    end
})

-- ==================== TAB COMBAT ====================
local CombatTab = Window:AddTab("Combat")
local CombatGroup = CombatTab:AddGroup("Stamina & Buffs", "Left")

CombatGroup:AddToggle("InfStaminaToggle", {
    Text = "Infinite Stamina (Engine Lock)",
    Default = true,
    Callback = function(val)
        Hub.Combat.InfStamina = val
    end
})

Hub.Combat.SetSunScript = function(enabled)
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local ucs = pg and pg:FindFirstChild("UCS")
        local gp = ucs and ucs:FindFirstChild("Game_Play")
        local sun = gp and gp:FindFirstChild("SunDamage")
        if sun and sun:IsA("LocalScript") then
            sun.Enabled = enabled and true or false
        end
    end)
end

Hub.Combat.PurgeFrostTicks = function()
    local vf = GetMyValuesFolder()
    if not vf then return end
    for _, tickName in ipairs({ "Snow Frost Tick", "Frost Tick" }) do
        local t = vf:FindFirstChild(tickName)
        if t then pcall(function() t:Destroy() end) end
    end
end

CombatGroup:AddToggle("NoSunDamageToggle", {
    Text = "No Sun Damage (Demon Immunity)",
    Default = false,
    Callback = function(val)
        Hub.Combat.NoSunDamage = val
        if val then
            Hub.Combat.SetSunScript(false)
            pcall(function()
                local prev = LocalPlayer:GetAttribute("SecondarySituation")
                if prev ~= "Sunless" then Hub.Combat._PrevSecondarySituation = prev end
                LocalPlayer:SetAttribute("SecondarySituation", "Sunless")
            end)
            pcall(function()
                if SignalFunction and SignalFunction.ToServer then
                    SignalFunction.ToServer("SunDamage", false)
                end
            end)
            Kyoka:Notify({ Title = "Sun Immunity", Content = "Sun damage immunity enabled!", Type = "success" })
        else
            Hub.Combat.SetSunScript(true)
            pcall(function()
                if LocalPlayer:GetAttribute("SecondarySituation") == "Sunless" then
                    LocalPlayer:SetAttribute("SecondarySituation", Hub.Combat._PrevSecondarySituation)
                end
            end)
        end
    end
})

CombatGroup:AddToggle("NoColdDamageToggle", {
    Text = "No Cold / Snow Damage (HP Lock + Campfire Rescue)",
    Default = false,
    Tooltip = "In the Snow biome the frost tick is server-side. This locks your HP bar at max (no more visible damage) and, when your real HP drops too low, warps you to a campfire (fires are real safe zones) so you never die from the cold.",
    Callback = function(val)
        Hub.Combat.NoColdDamage = val
        if val then
            pcall(Hub.Combat.PurgeFrostTicks)
            Kyoka:Notify({ Title = "Cold Immunity", Content = "Cold immunity enabled: HP locked + campfire rescue!", Type = "success" })
        else
            if Hub.Combat._ColdHumConn then
                pcall(function() Hub.Combat._ColdHumConn:Disconnect() end)
                Hub.Combat._ColdHumConn = nil
                Hub.Combat._ColdHum = nil
            end
            Hub.Combat._ColdTrueHP = nil
        end
    end
})

CombatGroup:AddToggle("FastAttackToggle", {
    Text = "Fast M1 Attack (Continuous)",
    Default = false,
    Callback = function(val)
        Hub.Combat.FastAttack = val
    end
})

CombatGroup:AddToggle("AntiFreezeToggle", {
    Text = "Auto Anti-Freeze & Stun Recovery",
    Default = true,
    Tooltip = "Automatically detects and unstucks character if frozen, stuck in ragdoll, or immobilized!",
    Callback = function(val)
        Hub.Combat.AntiFreeze = val
    end
})

CombatGroup:AddToggle("TrackGuardToggle", {
    Text = "Animation Track Guard (Anti-64 Cap)",
    Default = true,
    Tooltip = "Prevents exceeding Roblox 64-track ceiling by cleaning finished/duplicate attack animations!",
    Callback = function(val)
        Hub.Combat.TrackGuard = val
    end
})

local DefenseGroup = CombatTab:AddGroup("Player Status", "Right")
DefenseGroup:AddLabel("Game: Slayers 2 (Ouwland)")
DefenseGroup:AddButton("Fix Character / Unfreeze (Unstuck)", {
    Accent = true,
    Callback = function()
        ForceUnfreezeCharacter()
        Kyoka:Notify({ Title = "Character Restored", Content = "Movement, jump, and animations unfrozen!", Type = "success" })
    end
})
DefenseGroup:AddButton("Replenish Stamina Max", {
    Callback = function()
        local folder = GetMyValuesFolder()
        local staminaVal = folder and folder:FindFirstChild("Stamina")
        if staminaVal then
            staminaVal.Value = staminaVal.MaxValue or 220
            Kyoka:Notify({ Title = "Stamina", Content = "Stamina restored to maximum.", Type = "success" })
        end
    end
})

-- ==================== TAB TELEPORTS ====================
local TeleportTab = Window:AddTab("Teleports")
local TpRegionsGroup = TeleportTab:AddGroup("Major Regions & Towns", "Left")
local TpSpecialGroup = TeleportTab:AddGroup("NPCs, Bosses & Shrines", "Left")
local TpTrainersGroup = TeleportTab:AddGroup("All Trainers & Combat Masters", "Right")

-- ==================== ALL TRAINERS & COMBAT MASTERS ====================
local TrainersDatabase = {
    {
        Name = "Water Trainer Urokodaki",
        DisplayName = "Water Breathing (Urokodaki)",
        Position = Vector3.new(667.2, 1022.7, -228.2),
        Style = "Water Breathing",
        Region = "Bamboo Grove / Mistfall"
    },
    {
        Name = "Thunder Trainer Zentaro",
        DisplayName = "Thunder Breathing (Zentaro)",
        Position = Vector3.new(1970.2, 1660.0, -609.8),
        Style = "Thunder Breathing",
        Region = "Verdant Cliffs (High Mountain)"
    },
    {
        Name = "Flame Trainer Rengu",
        DisplayName = "Flame Breathing (Rengu)",
        Position = Vector3.new(-967.6, 1028.7, 1188.2),
        Style = "Flame Breathing",
        Region = "Forgotten Ruins"
    },
    {
        Name = "Wind Trainer Saneri",
        DisplayName = "Wind Breathing (Saneri)",
        Position = Vector3.new(-275.6, 1187.5, -3436.7),
        Style = "Wind Breathing",
        Region = "Iceveil Mountain / Windy Pass"
    },
    {
        Name = "Stone Trainer Gyorei",
        DisplayName = "Stone Breathing (Gyorei)",
        Position = Vector3.new(2578.6, 1095.8, -828.4),
        Style = "Stone Breathing",
        Region = "Stone Sanctuary"
    },
    {
        Name = "Insect Trainer Shinora",
        DisplayName = "Insect Breathing (Shinora)",
        Position = Vector3.new(-1798.9, 347.9, -189.3),
        Style = "Insect Breathing",
        Region = "Butterfly Estate"
    },
    {
        Name = "Serpent Trainer Obari",
        DisplayName = "Serpent Breathing (Obari)",
        Position = Vector3.new(37.0, 1311.2, -1179.5),
        Style = "Serpent Breathing",
        Region = "Windy Peak Cave"
    },
    {
        Name = "Sound Trainer Tengai",
        DisplayName = "Sound Breathing (Tengai)",
        Position = Vector3.new(464.9, 1491.1, -3272.8),
        Style = "Sound Breathing",
        Region = "Iceveil Peak"
    },
    {
        Name = "Soryu Expert Kazuma",
        DisplayName = "Soryu Martial Arts (Kazuma)",
        Position = Vector3.new(-769.5, 909.4, 303.3),
        Style = "Soryu (Fist Combat)",
        Region = "Mistfall Harbor Outskirts"
    },
    {
        Name = "Tai Chi Expert Renjiro",
        DisplayName = "Tai Chi Martial Arts (Renjiro)",
        Position = Vector3.new(1883.1, 686.6, -761.1),
        Style = "Tai Chi (Combat)",
        Region = "Hidden Mist Outskirts"
    },
    {
        Name = "Harvester of Souls Zurinyz",
        DisplayName = "Reaper / Dark Style (Zurinyz)",
        Position = Vector3.new(-1212.6, 1387.4, -2371.6),
        Style = "Soul Harvester / Reaper",
        Region = "Iceveil Hollow"
    }
}

local TrainerNamesList = {}
for _, t in ipairs(TrainersDatabase) do
    table.insert(TrainerNamesList, t.DisplayName)
end

local selectedTrainerName = TrainerNamesList[1]
TpTrainersGroup:AddDropdown("SelectedTrainerDropdown", {
    Text = "Select Trainer",
    Values = TrainerNamesList,
    Default = TrainerNamesList[1],
    Tooltip = "Choose any breathing trainer or combat style master in the game",
    Callback = function(val)
        selectedTrainerName = val
    end
})

TpTrainersGroup:AddButton("Teleport To Selected Trainer", {
    Accent = true,
    Callback = function()
        for _, t in ipairs(TrainersDatabase) do
            if t.DisplayName == selectedTrainerName then
                TeleportToPosition(t.Position, t.DisplayName)
                break
            end
        end
    end
})

-- Direct quick buttons for each trainer
for _, t in ipairs(TrainersDatabase) do
    TpTrainersGroup:AddButton(t.DisplayName, {
        Callback = function()
            TeleportToPosition(t.Position, t.DisplayName)
        end
    })
end

TpRegionsGroup:AddButton("Hidden Mist Village", {
    Accent = true,
    Callback = function()
        TeleportToPosition(Vector3.new(1651.0, 607.3, -124.0), "Hidden Mist Village")
    end
})

TpRegionsGroup:AddButton("Mistfall Harbor", {
    Callback = function()
        TeleportToPosition(Vector3.new(140.7, 873.5, 728.2), "Mistfall Harbor")
    end
})

TpRegionsGroup:AddButton("Bamboo Grove", {
    Callback = function()
        TeleportToPosition(Vector3.new(422.0, 1128.0, -915.0), "Bamboo Grove")
    end
})

TpRegionsGroup:AddButton("Windy Peak", {
    Callback = function()
        TeleportToPosition(Vector3.new(-456.0, 1241.0, -932.0), "Windy Peak")
    end
})

TpRegionsGroup:AddButton("Butterfly Estate", {
    Callback = function()
        TeleportToPosition(Vector3.new(-1772.0, 311.3, -110.9), "Butterfly Estate")
    end
})

TpRegionsGroup:AddButton("Iceveil Valley", {
    Callback = function()
        TeleportToPosition(Vector3.new(142.1, 1385.1, -2783.2), "Iceveil Valley")
    end
})

TpRegionsGroup:AddButton("Verdant Cliffs", {
    Callback = function()
        TeleportToPosition(Vector3.new(1775.0, 715.0, -425.0), "Verdant Cliffs")
    end
})

TpRegionsGroup:AddButton("Forgotten Ruins", {
    Callback = function()
        TeleportToPosition(Vector3.new(-954.0, 950.0, 945.5), "Forgotten Ruins")
    end
})

TpRegionsGroup:AddButton("Stone Sanctuary", {
    Callback = function()
        TeleportToPosition(Vector3.new(2564.1, 980.0, -590.0), "Stone Sanctuary")
    end
})

TpRegionsGroup:AddButton("Final Selection Plains", {
    Callback = function()
        TeleportToPosition(Vector3.new(-1994.1, 750.0, 1050.1), "Final Selection Plains")
    end
})

-- Entree donjon Ouwigahara (fix post-update) : le CFrame vers le portail est
-- revert par le serveur ; on vole (fly) jusqu'au portail puis on declenche
-- le prompt officiel "Enter | Ouwigahara" (fireproximityprompt) -> le SERVEUR
-- teleporte dans le donjon (instantane, legit, pas de flag ban).
OUWIGAHARA_PORTAL_POS = Vector3.new(-1607.1, 1018.0, 1142.4)

function FireOuwigaharaPrompt()
    if type(fireproximityprompt) ~= "function" then
        return false, "fireproximityprompt indisponible sur cet executor"
    end
    local pad = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("OuwigaharaPromptPad")
    local prompt = pad and pad:FindFirstChild("Ouwigahara")
    if not (prompt and prompt:IsA("ProximityPrompt")) then
        return false, "prompt du portail introuvable (zone non streamee ?)"
    end
    local root = GetRootPart()
    if root then
        local ppos = nil
        pcall(function()
            if prompt.Parent and prompt.Parent:IsA("BasePart") then ppos = prompt.Parent.Position end
        end)
        if ppos and (ppos - root.Position).Magnitude > (prompt.MaxActivationDistance or 10) + 40 then
            return false, "trop loin du portail"
        end
    end
    local ok, err = pcall(function() fireproximityprompt(prompt) end)
    if not ok then
        return false, tostring(err):sub(1, 80)
    end
    return true
end

function EnterOuwigaharaDungeon(label)
    Kyoka:Notify({ Title = "Dungeon", Content = "Vol vers le portail Ouwigahara, entree auto a l'arrivee...", Type = "info", Duration = 5 })
    TeleportToPosition(OUWIGAHARA_PORTAL_POS, label or "Ouwigahara Dungeon Portal")
    task.spawn(function()
        local deadline = os.clock() + 240
        while os.clock() < deadline and Hub.Alive do
            local r = GetRootPart()
            if not r then break end
            if (r.Position - OUWIGAHARA_PORTAL_POS).Magnitude < 45 then break end
            task.wait(0.5)
        end
        local ok, why = FireOuwigaharaPrompt()
        if ok then
            Kyoka:Notify({ Title = "Dungeon", Content = "Entree Ouwigahara !", Type = "success", Duration = 5 })
        else
            Kyoka:Notify({ Title = "Dungeon", Content = tostring(why) .. " - appuie sur le prompt au portail.", Type = "warning", Duration = 7 })
        end
    end)
end

TpRegionsGroup:AddButton("Ouwigahara Dungeon Portal (Map Entrance)", {
    Accent = true,
    Callback = function()
        EnterOuwigaharaDungeon("Ouwigahara Dungeon Portal")
    end
})

TpRegionsGroup:AddButton("Teleport To Dungeon Server (Match / Queue)", {
    Danger = true,
    Callback = function()
        -- Les signaux MinigameQueue/OuwigaharaJoin sont morts post-update.
        -- Meme chemin que le portail : fly + prompt officiel (serveur TP).
        EnterOuwigaharaDungeon("Ouwigahara (file donjon)")
    end
})

TpSpecialGroup:AddButton("Muzan (Night Wandering NPC)", {
    Accent = true,
    Callback = function()
        local function FindNightWanderingMuzan()
            local debree = Workspace:FindFirstChild("Debree")
            if debree then
                local regions = debree:FindFirstChild("Regions")
                if regions then
                    for _, reg in ipairs(regions:GetChildren()) do
                        local stat = reg:FindFirstChild("StationaryNpcs")
                        local act = reg:FindFirstChild("ActiveNpcs")
                        local m = (stat and stat:FindFirstChild("Muzan")) or (act and act:FindFirstChild("Muzan"))
                        if m and m:IsA("Model") and m.Name == "Muzan" then
                            local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
                            if r then return r end
                        end
                    end
                end
            end

            local humanoids = Workspace:FindFirstChild("Humanoids")
            if humanoids then
                local regions = humanoids:FindFirstChild("Regions")
                if regions then
                    for _, reg in ipairs(regions:GetChildren()) do
                        local stat = reg:FindFirstChild("StationaryNpcs")
                        local act = reg:FindFirstChild("ActiveNpcs")
                        local m = (stat and stat:FindFirstChild("Muzan")) or (act and act:FindFirstChild("Muzan"))
                        if m and m:IsA("Model") and m.Name == "Muzan" then
                            local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
                            if r then return r end
                        end
                    end
                end
            end

            for _, m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and m.Name == "Muzan" and m.Name ~= "MuzanLairModel" then
                    local pName = m.Parent and m.Parent.Name or ""
                    local gName = m.Parent and m.Parent.Parent and m.Parent.Parent.Name or ""
                    if pName ~= "DetachedMaps" and pName ~= "Muzan's Lair" and gName ~= "DetachedMaps" and not m:GetFullName():find("MuzanLairModel") then
                        local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
                        if r then return r end
                    end
                end
            end

            return nil
        end

        local muzanRoot = FindNightWanderingMuzan()
        local root = GetRootPart()

        if muzanRoot and root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = muzanRoot.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)
            EnsureFarmPlatform(root.CFrame)
            Kyoka:Notify({ Title = "Night Wandering Muzan", Content = "Teleported directly in front of Muzan!", Type = "success", Duration = 4 })
            return
        end

        -- Si Muzan n'est pas encore streamé dans le client, explorer ses 3 zones de patrouille nocturne
        Kyoka:Notify({ Title = "Night Wandering Muzan", Content = "Searching along night patrol routes...", Type = "info", Duration = 3 })
        local routes = {
            Vector3.new(1920.59, 601, -880.99),
            Vector3.new(55, 828, 781.5),
            Vector3.new(-687, 1383, -2606.5)
        }

        task.spawn(function()
            for i, route in ipairs(routes) do
                local myR = GetRootPart()
                if myR then
                    myR.AssemblyLinearVelocity = Vector3.zero
                    myR.AssemblyAngularVelocity = Vector3.zero
                    myR.CFrame = CFrame.new(route + Vector3.new(0, 3, 0))
                end

                -- Polling pour laisser le temps à StreamingEnabled de répliquer Muzan
                local found = nil
                for _ = 1, 6 do
                    task.wait(0.25)
                    found = FindNightWanderingMuzan()
                    if found then break end
                end

                if found then
                    local curR = GetRootPart()
                    if curR then
                        curR.AssemblyLinearVelocity = Vector3.zero
                        curR.AssemblyAngularVelocity = Vector3.zero
                        curR.CFrame = found.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)
                        EnsureFarmPlatform(curR.CFrame)
                        Kyoka:Notify({ Title = "Muzan Found!", Content = "Arrived directly in front of Night Wandering Muzan!", Type = "success", Duration = 5 })
                        return
                    end
                end
            end
            Kyoka:Notify({ Title = "Muzan", Content = "Night Wandering Muzan is not spawned right now (Wait for nightfall).", Type = "warning", Duration = 5 })
        end)
    end
})

-- ==================== BLACK MARKETER (NIGHT MARKET) ====================
do
    Hub.NightMarket.Label = TpSpecialGroup:AddLabel("Black Marketer (Night Market): checking...")

    TpSpecialGroup:AddButton("Teleport To Black Marketer (Night Market)", {
        Accent = true,
        Tooltip = "Teleports to the Black Marketer timed vendor. He only spawns periodically (Night Market).",
        Callback = function()
            Hub.TeleportToBlackMarketer(true)
        end
    })

    TpSpecialGroup:AddToggle("AutoNightMarketToggle", {
        Text = "Auto-Teleport To Black Marketer When He Spawns",
        Default = false,
        Tooltip = "Watches the Night Market and teleports you to the Black Marketer as soon as he spawns (once per spawn).",
        Callback = function(val)
            Hub.NightMarket.Auto = val
            Hub.NightMarket.LastCycle = nil
            if val then
                Kyoka:Notify({ Title = "Night Market", Content = "Watching for the Black Marketer spawn...", Type = "info", Duration = 5 })
            end
        end
    })
end

TpSpecialGroup:AddButton("Muzan's Lair (Throne / Biwa)", {
    Callback = function()
        TeleportToPosition(Vector3.new(2466.3, 1079.3, 2334.5), "Muzan's Lair (Throne)")
    end
})

TpSpecialGroup:AddButton("TP Closest Spider Lily (Flower)", {
    Accent = true,
    Callback = function()
        local myRoot = GetRootPart()
        if not myRoot then return end

        local function GetAvailableLilies()
            local found = {}
            local debree = Workspace:FindFirstChild("Debree")
            if debree then
                for _, m in ipairs(debree:GetChildren()) do
                    if m.Name == "Spider Lily" then
                        local p = m:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local root = m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart", true)
                        local pos = root and root.Position or (m:GetPivot() and m:GetPivot().Position)
                        if pos then
                            table.insert(found, {
                                model = m,
                                pos = pos,
                                prompt = p
                            })
                        end
                    end
                end
            end
            return found
        end

        local lilies = GetAvailableLilies()
        local closest = nil
        local shortestDist = math.huge

        for _, l in ipairs(lilies) do
            local d = (myRoot.Position - l.pos).Magnitude
            if d < shortestDist then
                shortestDist = d
                closest = l
            end
        end

        if closest then
            TeleportToPosition(closest.pos + Vector3.new(0, 1.5, 0), "Spider Lily")
            if closest.prompt then
                task.wait(0.3)
                pcall(fireproximityprompt, closest.prompt)
            end
        else
            -- Si aucune plante n'est dans le champ immédiat, explorer les zones de spawn connues
            Kyoka:Notify({ Title = "Spider Lily", Content = "Searching for active Spider Lily spawn...", Type = "info", Duration = 3 })
            local knownSpawns = {
                Vector3.new(1279.3, 981.0, -435.1),
                Vector3.new(1321.3, 981.0, -184.9),
                Vector3.new(2712.0, 1077.0, -554.5)
            }
            task.spawn(function()
                for _, spot in ipairs(knownSpawns) do
                    TeleportToPosition(spot)
                    task.wait(0.7)
                    local current = GetAvailableLilies()
                    if #current > 0 then
                        local l = current[1]
                        TeleportToPosition(l.pos + Vector3.new(0, 1.5, 0), "Spider Lily")
                        if l.prompt then
                            task.wait(0.3)
                            pcall(fireproximityprompt, l.prompt)
                        end
                        return
                    end
                end
                Kyoka:Notify({ Title = "Spider Lily", Content = "No Spider Lilies ready to harvest right now.", Type = "warning", Duration = 4 })
            end)
        end
    end
})

TpSpecialGroup:AddButton("Collect All Spider Lilies (Auto-Grab)", {
    Callback = function()
        local function GetAvailableLilies()
            local found = {}
            local debree = Workspace:FindFirstChild("Debree")
            if debree then
                for _, m in ipairs(debree:GetChildren()) do
                    if m.Name == "Spider Lily" then
                        local p = m:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local root = m:FindFirstChild("RootPart") or m:FindFirstChildWhichIsA("BasePart", true)
                        local pos = root and root.Position or (m:GetPivot() and m:GetPivot().Position)
                        if pos and p then
                            table.insert(found, { pos = pos, prompt = p })
                        end
                    end
                end
            end
            return found
        end

        local spots = {
            Vector3.new(1279.3, 981.0, -435.1),
            Vector3.new(1321.3, 981.0, -184.9),
            Vector3.new(2712.0, 1077.0, -554.5)
        }

        task.spawn(function()
            local totalCollected = 0
            for i, spot in ipairs(spots) do
                TeleportToPosition(spot)
                task.wait(0.6)
                local current = GetAvailableLilies()
                for _, l in ipairs(current) do
                    if l.prompt then
                        TeleportToPosition(l.pos + Vector3.new(0, 1.5, 0))
                        task.wait(0.2)
                        pcall(fireproximityprompt, l.prompt)
                        totalCollected = totalCollected + 1
                        task.wait(0.3)
                    end
                end
            end
            Kyoka:Notify({ Title = "Spider Lilies", Content = totalCollected .. " Spider Lilies collected!", Type = "success", Duration = 5 })
        end)
    end
})



TpSpecialGroup:AddButton("Sabito (Boulder Split)", {
    Callback = function()
        TeleportToPosition(Vector3.new(-1046.8, 1133.5, -628.8), "Sabito")
    end
})

TpSpecialGroup:AddButton("Village Weapon Shop (Raze)", {
    Callback = function()
        TeleportToPosition(Vector3.new(-586.3, 1244.6, -1085.8), "Village Weapon Shop")
    end
})

TpSpecialGroup:AddButton("Hidden Mist Shrine (35k Wen)", {
    Callback = function()
        TeleportToPosition(Vector3.new(1266.2, 980.9, -482.3), "Hidden Mist Shrine")
    end
})

TpSpecialGroup:AddButton("Bamboo Grove Shrine", {
    Callback = function()
        TeleportToPosition(Vector3.new(-409.4, 1250.2, -1312.0), "Bamboo Grove Shrine")
    end
})

TpSpecialGroup:AddButton("Butterfly Estate Shrine", {
    Callback = function()
        TeleportToPosition(Vector3.new(-1728.8, 315.2, 126.6), "Butterfly Estate Shrine")
    end
})

TpSpecialGroup:AddButton("Frost Veil Shrine (Iceveil)", {
    Callback = function()
        TeleportToPosition(Vector3.new(142.1, 1385.1, -2783.2), "Frost Veil Shrine")
    end
})

-- ==================== TAB VISUALS ====================
local VisualsTab = Window:AddTab("Visuals")
local VisualsGroup = VisualsTab:AddGroup("Chams / ESP", "Left")

VisualsGroup:AddToggle("MobESPToggle", {
    Text = "Mob ESP",
    Default = true,
    Callback = function(val)
        Hub.Visuals.MobESP = val
    end
}):AddColorPicker("MobColorPicker", {
    Default = Color3.fromRGB(255, 65, 65),
    Callback = function(c)
        Hub.Visuals.MobColor = c
    end
})

VisualsGroup:AddToggle("PlayerESPToggle", {
    Text = "Player ESP",
    Default = false,
    Callback = function(val)
        Hub.Visuals.PlayerESP = val
    end
}):AddColorPicker("PlayerColorPicker", {
    Default = Color3.fromRGB(124, 108, 255),
    Callback = function(c)
        Hub.Visuals.PlayerColor = c
    end
})

local ESPConfigGroup = VisualsTab:AddGroup("ESP Styling", "Right")
ESPConfigGroup:AddToggle("ESPBoxesToggle", {
    Text = "Full Chams (Highlight)",
    Default = true,
    Callback = function(val)
        Hub.Visuals.ESPBoxes = val
    end
})

-- ==================== WORLD ESP (puzzles, clés, coffres) ====================
local WorldESPGroup = VisualsTab:AddGroup("World ESP & Nightfall", "Left")

WorldESPGroup:AddToggle("WorldESPShowDistance", {
    Text = "Show Name + Distance Labels",
    Default = true,
    Callback = function(val)
        Hub.Visuals.WorldESP.ShowDistance = val
    end
})

WorldESPGroup:AddToggle("ESPLeversToggle", {
    Text = "Sickles Levers ESP (Nightfall)",
    Default = false,
    Tooltip = "Highlights the 10 randomly-spawned sewer levers with a distance label.",
    Callback = function(val)
        Hub.Visuals.WorldESP.Levers = val
    end
})

WorldESPGroup:AddToggle("ESPSerpentKeyToggle", {
    Text = "Serpent Key ESP",
    Default = false,
    Tooltip = "Highlights the Nightfall Serpent Key when it spawns.",
    Callback = function(val)
        Hub.Visuals.WorldESP.SerpentKey = val
    end
})

WorldESPGroup:AddToggle("ESPSerpentBoxToggle", {
    Text = "Serpent Box ESP",
    Default = false,
    Callback = function(val)
        Hub.Visuals.WorldESP.SerpentBox = val
    end
})

WorldESPGroup:AddToggle("ESPStudyPropsToggle", {
    Text = "Nightfall/Firstlight StudyProps ESP",
    Default = false,
    Tooltip = "Highlights weapon schematics props (Nightfall Sickles, Katana, Mask, Claws...)",
    Callback = function(val)
        Hub.Visuals.WorldESP.StudyProps = val
    end
})

WorldESPGroup:AddToggle("ESPChestsToggle", {
    Text = "Chests & Mounds ESP",
    Default = false,
    Callback = function(val)
        Hub.Visuals.WorldESP.Chests = val
    end
})

WorldESPGroup:AddToggle("ESPSpiderLilyToggle", {
    Text = "Spider Lily ESP",
    Default = false,
    Callback = function(val)
        Hub.Visuals.WorldESP.SpiderLily = val
    end
})

WorldESPGroup:AddToggle("ESPShrinesToggle", {
    Text = "Shrines & Spawn Crystals ESP",
    Default = false,
    Callback = function(val)
        Hub.Visuals.WorldESP.Shrines = val
        Hub.Visuals.WorldESP.SpawnCrystals = val
    end
})

WorldESPGroup:AddToggle("ESPSimonPlatesToggle", {
    Text = "Simon Plates ESP (Firstlight Lantern)",
    Default = false,
    Callback = function(val)
        Hub.Visuals.WorldESP.SimonPlates = val
    end
})

local PuzzleGroup = VisualsTab:AddGroup("Nightfall Auto-Solve", "Right")

PuzzleGroup:AddToggle("AutoPullLeversToggle", {
    Text = "Auto Pull All Sickles Levers",
    Default = false,
    Tooltip = "Automatically triggers every sewer lever it can reach. Combine with Lever ESP to find them, or teleport to each one automatically.",
    Callback = function(val)
        Hub.Puzzles.AutoPullLevers = val
        Hub.Puzzles.NotifiedSolved = false
        if val then
            Kyoka:Notify({ Title = "Nightfall", Content = "Auto-pulling every Sickles lever it can find...", Type = "info" })
        end
    end
})

PuzzleGroup:AddToggle("AutoTravelLeversToggle", {
    Text = "Auto-Teleport To Each Lever",
    Default = true,
    Tooltip = "When Auto Pull is on, teleports to each lever instead of waiting for you to walk there.",
    Callback = function(val)
        Hub.Puzzles.AutoTravelLevers = val
    end
})

PuzzleGroup:AddButton("Teleport To Closest Lever Now", {
    Accent = true,
    Callback = function()
        local best, bestDist = nil, math.huge
        local cs = game:GetService("CollectionService")
        local myRoot = GetRootPart()
        if not myRoot then return end
        for _, lever in ipairs(cs:GetTagged("SicklesLever")) do
            local part = lever:FindFirstChild("A_")
            local pos = part and part:GetPivot().Position
            if pos then
                local d = (pos - myRoot.Position).Magnitude
                if d < bestDist then best, bestDist = lever, d end
            end
        end
        if best then
            local a = best:FindFirstChild("A_")
            TeleportToPosition(a:GetPivot().Position, "Sickles Lever")
        else
            Kyoka:Notify({ Title = "Nightfall", Content = "No Sickles levers spawned right now (world event inactive).", Type = "warning" })
        end
    end
})

local LeverStatusLabel = PuzzleGroup:AddLabel("Levers: 0/10 pulled", { Color = "TextDim" })

-- ==================== TAB MOVEMENT ====================
local MiscTab = Window:AddTab("Misc")
local MoveGroup = MiscTab:AddGroup("Movement Controls", "Left")

MoveGroup:AddToggle("CustomSpeedToggle", {
    Text = "Speed Hack",
    Default = false,
    Callback = function(val)
        Hub.Misc.CustomSpeed = val
    end
})

MoveGroup:AddSlider("WalkSpeedSlider", {
    Text = "WalkSpeed",
    Min = 16,
    Max = 120,
    Default = 35,
    Rounding = 0,
    Callback = function(val)
        Hub.Misc.WalkSpeed = val
    end
})

MoveGroup:AddToggle("NoClipToggle", {
    Text = "NoClip",
    Default = false,
    Callback = function(val)
        Hub.Misc.NoClip = val
    end
}):AddKeybind("NoClipKey", { Default = Enum.KeyCode.N, Mode = "Toggle" })

MoveGroup:AddToggle("InfJumpToggle", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(val)
        Hub.Misc.InfiniteJump = val
    end
})

-- ==================== TAB SETTINGS ====================
local SettingsTab = Window:AddTab("Settings")
local SettingsGroup = SettingsTab:AddGroup("Menu Controls", "Left")
SettingsGroup:AddKeybind("MenuToggleKey", {
    Text = "Open/Close Menu",
    Default = Enum.KeyCode.RightShift,
    Changed = function(bind)
        if bind.Key then Kyoka.ToggleKey = bind.Key end
    end
})

SettingsGroup:AddColorPicker("AccentPicker", {
    Text = "Theme Accent",
    Default = Kyoka.Theme.Accent,
    Callback = function(c)
        Kyoka:SetAccent(c)
    end
})

SettingsGroup:AddSlider("ScaleSlider", {
    Text = "UI Scale",
    Min = 1.6,
    Max = 4.0,
    Default = Kyoka.Scale or 2.4,
    Rounding = 1,
    Callback = function(s)
        Kyoka:SetScale(s)
    end
})

local SessionGroup = SettingsTab:AddGroup("Session", "Right")
SessionGroup:AddButton("Unload Kyōka Hub", {
    Danger = true,
    Callback = function()
        Hub:Destroy()
        Kyoka:Unload()
    end
})

do
    local ConfigGroup = SettingsTab:AddGroup("Hub Config", "Right")

    ConfigGroup:AddTextbox("HubConfigName", {
        Text = "Config Name",
        Placeholder = "default",
        Default = "default",
        Tooltip = "Name of the config file (saved in vesper/<name>.json).",
        Callback = function(val)
            local name = tostring(val or ""):match("^%s*(.-)%s*$"):gsub("[^%w%-%_ ]", "")
            if name == "" then name = "default" end
            Hub.Config.Name = name
        end
    })

    ConfigGroup:AddButton("Save Config", {
        Accent = true,
        Tooltip = "Saves every toggle, slider, dropdown and textbox (webhook URL included).",
        Callback = function()
            local ok, err = Kyoka:SaveConfigToFile(Hub.Config.Name)
            if ok then
                if Hub.Config.AutoLoad then
                    pcall(function()
                        if type(writefile) == "function" then
                            writefile("vesper/autoload.txt", Hub.Config.Name)
                        end
                    end)
                end
                Kyoka:Notify({ Title = "Config", Content = "Saved config: " .. Hub.Config.Name, Type = "success", Duration = 4 })
            else
                Kyoka:Notify({ Title = "Config", Content = "Save failed: " .. tostring(err), Type = "error", Duration = 5 })
            end
        end
    })

    ConfigGroup:AddButton("Load Config", {
        Tooltip = "Loads the named config file.",
        Callback = function()
            local ok, err = Kyoka:LoadConfigFromFile(Hub.Config.Name)
            if ok then
                Kyoka:Notify({ Title = "Config", Content = "Loaded config: " .. Hub.Config.Name, Type = "success", Duration = 4 })
            else
                Kyoka:Notify({ Title = "Config", Content = "Load failed: " .. tostring(err), Type = "error", Duration = 5 })
            end
        end
    })

    ConfigGroup:AddToggle("HubAutoLoadToggle", {
        Text = "Auto-Load Config on Start",
        Default = false,
        Tooltip = "Automatically loads this config every time the hub starts.",
        Callback = function(val)
            Hub.Config.AutoLoad = val and true or false
            if Hub.Config.AutoLoad then
                pcall(function()
                    if type(writefile) == "function" then
                        if type(isfolder) == "function" and not isfolder("vesper") then makefolder("vesper") end
                        writefile("vesper/autoload.txt", Hub.Config.Name)
                    end
                end)
                Kyoka:Notify({ Title = "Config", Content = "Auto-load ON (" .. Hub.Config.Name .. "). Saved on next Save.", Type = "info", Duration = 4 })
            else
                pcall(function()
                    if type(delfile) == "function" and type(isfile) == "function" and isfile("vesper/autoload.txt") then
                        delfile("vesper/autoload.txt")
                    end
                end)
            end
        end
    })

    ConfigGroup:AddToggle("TravelPayUnlockToggle", {
        Text = "Auto-Unlock Shrines (Travel, pays Wen)",
        Default = true,
        Tooltip = "Server travel (anti-cheat fix) passe par les shrines. Si la shrine cible est verrouillee, paie automatiquement les Wen (15k-45k) pour la debloquer, sinon le travel est ignore.",
        Callback = function(val)
            Hub.TravelPayUnlock = val and true or false
        end
    })
end

do
    -- Anti-Mod protection: instant server hop when staff joins.
    local ProtectionGroup = SettingsTab:AddGroup("Anti-Mod Protection", "Right")

    ProtectionGroup:AddToggle("StaffDetectToggle", {
        Text = "Leave on Staff Join (Anti-Ban)",
        Default = true,
        Tooltip = "Instantly hops to a new server if an Ouw staff member (Admin rank 5+, Dev, Partner, Owner) joins. Prevents mod bans while exploiting.",
        Callback = function(val)
            Hub.Protection.StaffDetectEnabled = val and true or false
            Kyoka:Notify({
                Title = "Protection",
                Content = val and "Anti-mod ON: will hop server if staff joins." or "Anti-mod OFF: you will NOT be protected.",
                Type = val and "success" or "error",
                Duration = 4,
            })
        end
    })

    ProtectionGroup:AddLabel("Watches Ouw group ranks (Admin 5+). Instant server hop, no delay.")
end

-- =====================================================================
-- Anti-Mod watcher: scan on load + PlayerAdded + periodic recheck.
-- Client cannot Kick itself, so we Teleport out = instant leave.
-- =====================================================================
do
    local function IsStaffMember(plr)
        if not plr or plr == LocalPlayer then return false end
        local ok, rank = pcall(function()
            return plr:GetRankInGroup(Hub.Protection.StaffGroupId)
        end)
        return ok and (tonumber(rank) or 0) >= (Hub.Protection.StaffMinRank or 5)
    end

    local function LeaveForStaff(staffName)
        if Hub.IsLeavingForStaff then return end
        Hub.IsLeavingForStaff = true
        Hub.Alive = false
        pcall(function()
            Kyoka:Notify({
                Title = "STAFF DETECTED",
                Content = (staffName or "Staff") .. " joined — leaving server NOW!",
                Type = "error",
                Duration = 5,
            })
        end)
        warn("[NW Hub Protection] Staff detected (" .. tostring(staffName) .. ") — hopping server.")
        -- Instant hop to a fresh public server of the same place.
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
        -- Fallback if teleport was blocked: keep trying every 2s.
        task.spawn(function()
            for _ = 1, 10 do
                task.wait(2)
                local stillThere = false
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if IsStaffMember(p) then stillThere = true break end
                    end
                end)
                if not stillThere then break end
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        end)
    end

    local function ScanForStaff()
        if not Hub.Protection.StaffDetectEnabled or Hub.IsLeavingForStaff then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if IsStaffMember(p) then
                LeaveForStaff(p.Name)
                break
            end
        end
    end

    -- Staff already here when hub loads? Catch after replication settles.
    task.delay(8, ScanForStaff)

    table.insert(Hub.Connections, Players.PlayerAdded:Connect(function(plr)
        -- Rank replicates shortly after join; check now + delayed recheck.
        task.wait(3)
        if not Hub.Protection.StaffDetectEnabled or Hub.IsLeavingForStaff then return end
        if IsStaffMember(plr) then
            LeaveForStaff(plr.Name)
        end
    end))

    -- Periodic recheck (catches rank changes / missed joins).
    task.spawn(function()
        while Hub.Alive do
            task.wait(Hub.Protection.StaffRecheckInterval or 20)
            if not Hub.Alive then break end
            pcall(ScanForStaff)
        end
    end)
end

do
    local WebhookSettingsGroup = SettingsTab:AddGroup("Discord Webhook", "Right")
    local WebhookStatsGroup = SettingsTab:AddGroup("Farm Session", "Right")

    Hub.Webhook.Label = WebhookSettingsGroup:AddLabel("Session: - | Kills: 0 | Wen: +0 | No URL")
    Hub.Webhook.KillsLabel = WebhookStatsGroup:AddLabel("Top Defeated: none yet")

    WebhookSettingsGroup:AddTextbox("FarmWebhookURL", {
        Text = "Webhook URL",
        Placeholder = "https://discord.com/api/webhooks/...",
        Default = "",
        Tooltip = "Paste your Discord channel webhook URL. Drop pings and progress reports are posted here.",
        Callback = function(val)
            local url = tostring(val or ""):match("^%s*(.-)%s*$")
            Hub.Webhook.Url = url
            Hub.Webhook.SeenItems = nil
            if url ~= "" then
                Hub.GuiWrite(function()
                    if Hub.Webhook.Label then Hub.Webhook.Label:SetText("Webhook URL saved. Enable drops / progress below.") end
                end)
            end
        end
    })

    WebhookSettingsGroup:AddToggle("WebhookDropsToggle", {
        Text = "Enable Loot Drop Webhooks",
        Default = false,
        Tooltip = "Posts a Discord embed each time you obtain an item at or above the min rarity.",
        Callback = function(val)
            Hub.Webhook.DropsEnabled = val and true or false
            Hub.Webhook.SeenItems = nil
        end
    })

    WebhookSettingsGroup:AddToggle("WebhookProgressToggle", {
        Text = "Enable Progress Reports",
        Default = false,
        Tooltip = "Posts a Discord progress embed (level, exp, wen, kills) every X minutes.",
        Callback = function(val)
            Hub.Webhook.ProgressEnabled = val and true or false
            if val then Hub.Webhook.LastProgressAt = 0 end
        end
    })

    WebhookSettingsGroup:AddToggle("WebhookOnlyFarmingToggle", {
        Text = "Only While Auto Farm Is Active",
        Default = true,
        Tooltip = "Only send webhooks while Auto Farm is running.",
        Callback = function(val)
            Hub.Webhook.OnlyWhileFarming = val and true or false
        end
    })

    WebhookSettingsGroup:AddSlider("WebhookMinRaritySlider", {
        Text = "Min Drop Rarity",
        Min = 1,
        Max = 7,
        Default = 3,
        Rounding = 0,
        Tooltip = "1 Common, 2 UnCommon, 3 Rare, 4 Epic, 5 Legendary, 6 Mythic, 7 Impossible.",
        Callback = function(val)
            Hub.Webhook.MinRarity = math.floor(tonumber(val) or 3)
        end
    })

    WebhookSettingsGroup:AddSlider("WebhookProgressMinutesSlider", {
        Text = "Progress Every",
        Min = 1,
        Max = 120,
        Default = 15,
        Rounding = 0,
        Suffix = " min",
        Tooltip = "Minutes between automatic progress reports.",
        Callback = function(val)
            Hub.Webhook.ProgressMinutes = math.floor(tonumber(val) or 15)
        end
    })

    WebhookSettingsGroup:AddButton("Send Test Webhook", {
        Accent = true,
        Tooltip = "Posts a small test embed to verify your URL.",
        Callback = function()
            task.spawn(function()
                local ts = nil
                pcall(function() ts = os.date("!%Y-%m-%dT%H:%M:%SZ") end)
                local embed = {
                    title = "Webhook Test",
                    description = "Slayers 2 Hub webhooks are working.",
                    color = 0x7C6CFF,
                    fields = {
                        { name = "Player", value = LocalPlayer.Name, inline = true },
                    },
                }
                if ts then embed.timestamp = ts end
                Hub.WebhookSend({ username = "Slayers 2 Hub | " .. LocalPlayer.Name, embeds = { embed } })
            end)
            Kyoka:Notify({ Title = "Webhook", Content = "Test embed sent (check Discord).", Type = "info", Duration = 3 })
        end
    })

    WebhookSettingsGroup:AddButton("Send Progress Now", {
        Tooltip = "Posts the farm progress embed immediately.",
        Callback = function()
            Hub.SendProgressWebhook(true)
            Kyoka:Notify({ Title = "Webhook", Content = "Progress report sent.", Type = "info", Duration = 3 })
        end
    })

    WebhookSettingsGroup:AddButton("Reset Counters", {
        Tooltip = "Restarts session stats (kills, wen earned, session time) from now.",
        Callback = function()
            Hub.Webhook.Defeated = {}
            Hub.Webhook.BossKillsTotal = 0
            Hub.Webhook.WenStart = nil
            Hub.Webhook.QuestsStart = nil
            Hub.Webhook.StartTime = os.clock()
            Hub.Webhook.SeenItems = nil
            Hub.Webhook.LastBoss = nil
            Hub.Webhook.LastBossAt = nil
            Kyoka:Notify({ Title = "Webhook", Content = "Session counters reset.", Type = "info", Duration = 3 })
        end
    })
end

--=====================================================================
-- Moteurs de Boucle & Logique en Temps Réel
--=====================================================================

-- 1. Infinite Jump
table.insert(Hub.Connections, UserInputService.JumpRequest:Connect(function()
    if Hub.Misc.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- 2. NoClip
table.insert(Hub.Connections, RunService.Stepped:Connect(function()
    if Hub.Misc.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end))

-- 3. Speed & Infinite Stamina
-- Le jeu recalcule Humanoid.WalkSpeed toutes les 75ms : on écrit donc AUSSI la
-- valeur d'override officielle ("WalkSpeed" prioritaire dans Player_Service.Values)
-- que le contrôleur du jeu lit en priorité.
local SpeedOverrideValue = nil
local function ApplySpeedOverride(on, speed)
    local vf = GetMyValuesFolder()
    if not vf then return end
    if on then
        if not SpeedOverrideValue or not SpeedOverrideValue.Parent then
            SpeedOverrideValue = Instance.new("NumberValue")
            SpeedOverrideValue.Name = "WalkSpeed"
            SpeedOverrideValue:SetAttribute("KyokaOverride", true)
            SpeedOverrideValue:SetAttribute("Priority", 1000)
            SpeedOverrideValue.Parent = vf
        end
        if SpeedOverrideValue.Value ~= speed then
            SpeedOverrideValue.Value = speed
        end
    elseif SpeedOverrideValue then
        pcall(function() SpeedOverrideValue:Destroy() end)
        SpeedOverrideValue = nil
    end
end

table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = GetHumanoid()

    if hum and char then
        if Hub.Misc.CustomSpeed then
            hum.WalkSpeed = Hub.Misc.WalkSpeed
            ApplySpeedOverride(true, Hub.Misc.WalkSpeed)
        elseif SpeedOverrideValue then
            ApplySpeedOverride(false)
        end

        if Hub.Combat.InfStamina then
            local folder = GetMyValuesFolder()
            local staminaVal = folder and folder:FindFirstChild("Stamina")
            if staminaVal and staminaVal.Value < (staminaVal.MaxValue or 220) then
                staminaVal.Value = staminaVal.MaxValue or 220
            end
        end
    end
end))

-- 5. Auto Farm Loop (Anti-Void Platform + VIM Attack + Sticky Target Lock + Auto Quest)
local lastAttack = 0
local lastTravelCheck = 0
local lastChestLootCheck = 0
local lastQuestCheck = 0
local lastBossKillPos = nil
local lastBossKillTime = 0
local lastMobKillPos = nil
local lastMobKillTime = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()

    if Hub.IsCollectingLoot then
        if not Hub._CollectingSince then
            Hub._CollectingSince = now
        elseif (now - Hub._CollectingSince) > 30 then
            Hub.IsCollectingLoot = false
            Hub._CollectingSince = nil
        end
    else
        Hub._CollectingSince = nil
    end
    if Hub.IsInteractingQuest then
        if not Hub._InteractingSince then
            Hub._InteractingSince = now
        elseif (now - Hub._InteractingSince) > 30 then
            Hub.IsInteractingQuest = false
            Hub._InteractingSince = nil
        end
    else
        Hub._InteractingSince = nil
    end

    -- Auto Quest Engine Hook
    if Hub.Farm.AutoQuest and (now - lastQuestCheck) >= 2.0 then
        lastQuestCheck = now
        local lvl = GetPlayerLevel()
        local active = GetActiveQuest()

        -- Déterminer la quête désirée selon le niveau ou la sélection manuelle
        local desiredQuest = nil
        if Hub.Farm.QuestMode == "Auto Best Quest (By Level)" then
            desiredQuest = GetBestQuestForLevel(lvl)
        else
            for _, q in ipairs(QuestDatabase) do
                if q.DisplayName == Hub.Farm.QuestMode then
                    desiredQuest = q
                    break
                end
            end
        end

        if Hub.Farm._QuestRaceLabel and (now - (Hub.Farm._QuestLabelAt or 0)) >= 2 then
            Hub.Farm._QuestLabelAt = now
            local engineRaceText = string.format("Detected Race: %s | Level: %d | Next Quest: %s", tostring(GetPlayerRace()), lvl, desiredQuest and desiredQuest.DisplayName or "none")
            local lbl = Hub.Farm._QuestRaceLabel
            Hub.GuiWrite(function()
                lbl:SetText(engineRaceText)
            end)
        end

        -- Une quête en cours n'est JAMAIS abandonnée automatiquement (le serveur valide et
        -- récompense la quête dès que ses tâches sont complètes). On n'annule que si
        -- l'utilisateur a explicitement forcé une autre quête manuelle.
        local shouldCancel = false
        if active and not active.IsFinished and Hub.Farm.QuestMode ~= "Auto Best Quest (By Level)" and desiredQuest then
            local aClean = string.lower(string.gsub(active.QuestString or active.Name, "%s+", ""))
            local dClean = string.lower(string.gsub(desiredQuest.Name, "%s+", ""))
            if not aClean:find(dClean, 1, true) and not dClean:find(aClean, 1, true) then
                shouldCancel = true
            end
        end

        if shouldCancel then
            CancelCurrentQuest()
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            active = nil
            lastQuestCheck = now + 1.0
        end

        -- Accepter la nouvelle quête auprès du PNJ approprié (respecte le cooldown serveur)
        if not active and not Hub.IsInteractingQuest and not IsTurningInQuest and Hub.Farm.AutoAcceptNextQuest ~= false then
            local cdRemaining = GetQuestCooldownRemaining()
            if desiredQuest and cdRemaining <= 0.25 and (now - lastQuestAttempt) >= 3.0 then
                lastQuestAttempt = now
                task.spawn(function()
                    local ok = RequestAddQuest(desiredQuest.Name)
                    -- L'utilisateur a pu couper l'Auto Quest pendant la prise : ne pas teleporter/farmer
                    if not Hub.Farm.AutoQuest then return end
                    if ok then
                        Hub.Farm.QuestFailCount[desiredQuest.Name] = nil
                        Kyoka:Notify({ Title = "Quest Accepted", Content = string.format("Accepted: %s", desiredQuest.DisplayName), Type = "success" })
                        Hub.Farm.TargetMob = desiredQuest.MobName
                        Hub.Farm.MobCategory = desiredQuest.Category
                        Hub.Farm.RegionFilter = desiredQuest.Region
                        Hub.LockedTarget = nil
                        Hub.CurrentTarget = nil
                        local wp = GetMobSpawnPosition(desiredQuest.MobName) or desiredQuest.MobWp
                        if wp then
                            TeleportToPosition(wp, desiredQuest.MobName .. " Area")
                            local myRoot = GetRootPart()
                            if myRoot then
                                pcall(function()
                                    local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
                                    AreaLocator:Update(myRoot)
                                end)
                            end
                        end
                    else
                        -- Échec : le PNJ refuse probablement la quête (prérequis de dialogue,
                        -- race, niveau de compétence...). Après 2 échecs on la met de côté
                        -- quelques minutes pour continuer à farmer avec une autre quête.
                        Hub.Farm.QuestFailCount[desiredQuest.Name] = (Hub.Farm.QuestFailCount[desiredQuest.Name] or 0) + 1
                        if Hub.Farm.QuestFailCount[desiredQuest.Name] >= 2 then
                            BlacklistQuest(desiredQuest.Name, 300)
                            local nextQuest = GetBestQuestForLevel(GetPlayerLevel())
                            local seenBtns = Hub.Farm._LastDialogueButtons
                            local extra = ""
                            if type(seenBtns) == "table" and #seenBtns > 0 then
                                local shown = {}
                                for i = 1, math.min(#seenBtns, 3) do
                                    shown[#shown+1] = tostring(seenBtns[i])
                                end
                                extra = " | NPC buttons: " .. table.concat(shown, ", ")
                            end
                            Kyoka:Notify({
                                Title = "Quest Unavailable",
                                Content = string.format("%s not accepted (dialogue/click failed). Switching to: %s%s", desiredQuest.DisplayName, nextQuest and nextQuest.DisplayName or "none", extra),
                                Type = "warning",
                                Duration = 7
                            })
                        end
                    end
                end)
            end
        end

        if active and not active.IsFinished and not Hub.IsInteractingQuest then
            -- Tâches restantes : combat vs remise au PNJ ("Return to X")
            local hasPendingKill = false
            local pendingReturnTask = nil
            for taskName, taskData in pairs(active.Tasks) do
                if taskData.Current < taskData.Max then
                    if string.find(string.lower(taskName), "return to", 1, true) then
                        pendingReturnTask = pendingReturnTask or taskName
                    else
                        hasPendingKill = true
                    end
                end
            end

            if not hasPendingKill and pendingReturnTask then
                -- Toutes les tâches de combat sont faites : retourner voir le PNJ donneur
                if not IsTurningInQuest and (now - lastTurnInAttempt) >= 4.0 then
                    lastTurnInAttempt = now
                    task.spawn(function()
                        local ok = RequestQuestTurnIn(active, pendingReturnTask)
                        if ok and Hub.Farm.AutoQuest then
                            Kyoka:Notify({ Title = "Quest Turn-In", Content = "Quest handed in to NPC!", Type = "success", Duration = 3 })
                            lastTurnInAttempt = os.clock() + 5.0
                        end
                    end)
                end
            else
                -- Une quête est active : cibler le monstre demandé par la tâche
                local targetMob = nil
                local targetCategory = "Normal"
                local targetRegion = "All"
                local targetWp = nil

                -- 1. Correspondance exacte par nom de tâche dans la base
                for taskName, taskData in pairs(active.Tasks) do
                    if taskData.Current < taskData.Max then
                        for _, qDef in ipairs(QuestDatabase) do
                            if qDef.Tasks[taskName] then
                                targetMob = qDef.Tasks[taskName]
                                targetCategory = qDef.Category
                                targetRegion = qDef.Region
                                targetWp = qDef.MobWp
                                break
                            end
                        end
                        if targetMob then break end
                    end
                end

                -- 2. Recherche par inclusion du nom du monstre dans la tâche (ex: "Lesser Demons defeated" -> "Lesser Demon")
                if not targetMob then
                    for taskName, taskData in pairs(active.Tasks) do
                        if taskData.Current < taskData.Max then
                            local tLow = string.lower(taskName)
                            for _, qDef in ipairs(QuestDatabase) do
                                if tLow:find(string.lower(qDef.MobName), 1, true) then
                                    targetMob = qDef.MobName
                                    targetCategory = qDef.Category
                                    targetRegion = qDef.Region
                                    targetWp = qDef.MobWp
                                    break
                                end
                            end
                            if targetMob then break end
                        end
                    end
                end

                -- 3. Recherche par QuestString ou QuestInstanceName
                if not targetMob then
                    local aNameLow = string.lower(active.Name or "")
                    local aStrLow = string.lower(active.QuestString or "")
                    for _, qDef in ipairs(QuestDatabase) do
                        local qMobLow = string.lower(qDef.MobName)
                        local qNameLow = string.lower(qDef.Name)
                        local qInstLow = string.lower(qDef.QuestInstanceName or "")
                        if qDef.Name == active.QuestString or qDef.QuestInstanceName == active.Name or aNameLow:find(qMobLow, 1, true) or aStrLow:find(qMobLow, 1, true) or qNameLow:find(aNameLow, 1, true) or qInstLow:find(aNameLow, 1, true) then
                            targetMob = qDef.MobName
                            targetCategory = qDef.Category
                            targetRegion = qDef.Region
                            targetWp = qDef.MobWp
                            break
                        end
                    end
                end

                if targetMob then
                    -- Point de spawn officiel du jeu en priorité (le tableau statique peut être obsolète)
                    local liveWp = GetMobSpawnPosition(targetMob)
                    if liveWp then targetWp = liveWp end

                    if Hub.Farm.TargetMob ~= targetMob then
                        Hub.Farm.TargetMob = targetMob
                        Hub.Farm.MobCategory = targetCategory
                        Hub.Farm.RegionFilter = targetRegion
                        Hub.LockedTarget = nil
                        Hub.CurrentTarget = nil
                    end

                    -- Téléportation vers la zone du mob si aucun n'est présent à proximité
                    local myRoot = GetRootPart()
                    if myRoot and targetWp and (myRoot.Position - targetWp).Magnitude > 90 then
                        local mobs = GetAliveMobs()
                        local mobFoundNearby = false
                        for _, m in ipairs(mobs) do
                            if IsTargetValid(m, targetMob, targetRegion, targetCategory) and (m.Root.Position - myRoot.Position).Magnitude <= 80 then
                                mobFoundNearby = true
                                break
                            end
                        end
                        if not mobFoundNearby then
                            TeleportToPosition(targetWp, targetMob .. " Area")
                            local r = GetRootPart()
                            if r then
                                pcall(function()
                                    local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
                                    AreaLocator:Update(r)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    if Hub.Farm.AutoFarm and not Hub.IsInteractingQuest and not Hub.IsCollectingLoot then
        local myRoot = GetRootPart()
        local myHum = GetHumanoid()
        if myRoot and myHum and myHum.Health > 0 then
            -- Vérifier si le joueur est en état de choc ou ragdoll (laisser le moteur physique se relever)
            if IsPlayerStunnedOrRagdolled() then
                RemoveFarmPlatform()
            else
                local target = Hub.LockedTarget

                -- Si TargetLock est actif, vérifier si la cible actuelle est toujours en vie et valide
                if Hub.Farm.TargetLock and target then
                    if not IsTargetValid(target, Hub.Farm.TargetMob, Hub.Farm.RegionFilter, Hub.Farm.MobCategory) then
                        if target.Root then
                            if IsBossMob(target) then
                                lastBossKillPos = target.Root.Position
                                lastBossKillTime = now
                                Hub.RegisterBossKill(target)

                                -- Si plusieurs bosses sont sélectionnés, vérifier immédiatement s'il y en a un vivant
                                if type(Hub.Farm.SelectedBosses) == "table" and #Hub.Farm.SelectedBosses > 1 then
                                    local aliveBoss = FindAliveBossFromList(Hub.Farm.SelectedBosses, Hub.Farm.RegionFilter)
                                    if aliveBoss then
                                        for idx, bName in ipairs(Hub.Farm.SelectedBosses) do
                                            if IsTargetValid(aliveBoss, bName, "All", "Boss") then
                                                bossRotationIndex = idx
                                                break
                                            end
                                        end
                                        lastBossRotationTime = now
                                        target = aliveBoss
                                        Hub.LockedTarget = aliveBoss
                                    else
                                        bossRotationIndex = (bossRotationIndex % #Hub.Farm.SelectedBosses) + 1
                                        lastBossRotationTime = now
                                    end
                                end
                            else
                                -- Normal Mob / Demon Kill : Sauvegarder la position pour aspirer l'âme (Soul)
                                local mName = (target.Name or ""):lower()
                                if mName:find("demon") or mName:find("lost") or mName:find("beast") then
                                    lastMobKillPos = target.Root.Position
                                    lastMobKillTime = now
                                end
                            end
                        end
                        if not Hub.LockedTarget or Hub.LockedTarget == target and not IsTargetValid(target, Hub.Farm.TargetMob, Hub.Farm.RegionFilter, Hub.Farm.MobCategory) then
                            target = nil
                            Hub.LockedTarget = nil
                        end
                    end
                else
                    target = nil
                end

                -- Vérifier la période de grâce pour le loot du boss ou monstre vaincu (Chests, Loot, Demon Souls)
                local bossWaitLimit = Hub.Farm.BossLootWaitTime or 4.0
                local mobWaitLimit = Hub.Farm.MobLootWaitTime or 1.8
                local isWaitingBossLoot = (Hub.Farm.AutoCollectChests or Hub.Farm.AutoCollectLoot or Hub.Farm.AutoCollectSouls) and lastBossKillPos and (now - lastBossKillTime) < bossWaitLimit
                local isWaitingMobLoot = (Hub.Farm.AutoCollectSouls or Hub.Farm.AutoCollectLoot) and lastMobKillPos and (now - lastMobKillTime) < mobWaitLimit
                local isWaitingLoot = isWaitingBossLoot or isWaitingMobLoot
                local waitingPos = isWaitingBossLoot and lastBossKillPos or lastMobKillPos

                -- Si aucune cible verrouillée n'est active et qu'on n'attend pas le loot : acquérir la plus proche
                if not target and not isWaitingLoot then
                    target = GetClosestMob(Hub.Farm.TargetMob, Hub.Farm.RegionFilter, Hub.Farm.MobCategory)
                    Hub.LockedTarget = target
                end

                if isWaitingLoot and not target and waitingPos then
                    -- Maintenir le joueur au-dessus du lieu de mort pendant l'apparition du coffre / loot / âme
                    local targetPos = waitingPos + Vector3.new(0, Hub.Farm.HeightOffset or 2.5, 0)
                    local targetCFrame = CFrame.new(targetPos, waitingPos)
                    myRoot.CFrame = targetCFrame
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                    EnsureFarmPlatform(targetCFrame)
                elseif target and target.Root and target.Humanoid and target.Humanoid.Health > 0 and target.Root.Position.Y > -400 then
                    Hub.CurrentTarget = target
                    local mobRoot = target.Root
                    local mobPos = mobRoot.Position

                    -- Calcul de position selon le SafeMode choisi
                    local targetCFrame
                    local offset = Hub.Farm.HeightOffset or 2.5

                    if Hub.Farm.SafeMode == "Overhead" then
                        -- 2.5 studs au-dessus du mob : dans la portée exacte des coups M1 / hitbox tout en esquivant les attaques terrestres
                        local targetPos = mobPos + Vector3.new(0, offset, 0)
                        targetCFrame = CFrame.new(targetPos, mobPos)
                    else
                        -- Mode classique : devant le mob
                        local look = mobRoot.CFrame.LookVector
                        local flatLook = Vector3.new(look.X, 0, look.Z)
                        if flatLook.Magnitude > 0.001 then
                            flatLook = flatLook.Unit
                        else
                            flatLook = Vector3.new(0, 0, 1)
                        end
                        local targetPos = mobPos + (flatLook * (Hub.Farm.Distance or 2.0))
                        targetCFrame = CFrame.new(targetPos, Vector3.new(mobPos.X, targetPos.Y, mobPos.Z))
                    end
                    
                    myRoot.CFrame = targetCFrame
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero

                    -- Placer la plateforme anti-vide sous les pieds du joueur
                    EnsureFarmPlatform(targetCFrame)

                    -- Attaque de combat avec Multi-Hit burst (turbo en Instant Kill)
                    if Hub.Farm.AutoM1 and (now - lastAttack) >= (Hub.Farm.InstantKill and 0.06 or 0.28) * (0.9 + math.random() * 0.3) then
                        lastAttack = now
                        local hitCount = Hub.Farm.InstantKill and 5 or (Hub.Farm.MultiHit and (Hub.Farm.MultiHitCount or 3) or 1)
                        PerformAttack(hitCount)
                    end

                    -- Auto Skills / Spells Rotation (sans bloquer ni interférer avec l'Auto M1)
                    if Hub.Farm.AutoSkills then
                        CastAvailableSkill()
                    end
                else
                    Hub.CurrentTarget = nil
                    Hub.LockedTarget = nil
                    if not isWaitingBossLoot then
                        RemoveFarmPlatform()
                    end

                    -- Si aucun mob n'est chargé localement et qu'on n'attend pas de loot, s'y téléporter pour forcer le streaming
                    if not isWaitingBossLoot and Hub.Farm.AutoTravelToRegion and not Hub.IsCollectingLoot and not Hub.IsInteractingQuest and (now - lastTravelCheck) >= 2.5 then
                        lastTravelCheck = now
                        local myPos = myRoot.Position

                        local directWp = nil
                        local travelTargetName = nil

                        -- Mode Boss : Alternance intelligente entre les boss sélectionnés
                        local activeBossList = {}
                        if type(Hub.Farm.SelectedBosses) == "table" and #Hub.Farm.SelectedBosses > 0 then
                            for _, b in ipairs(Hub.Farm.SelectedBosses) do
                                if b ~= "All Bosses" and b ~= "All" and b ~= "" then
                                    table.insert(activeBossList, b)
                                end
                            end
                        elseif type(Hub.Farm.BossMob) == "string" and Hub.Farm.BossMob ~= "All Bosses" and Hub.Farm.BossMob ~= "All" then
                            table.insert(activeBossList, Hub.Farm.BossMob)
                        end

                        if Hub.Farm.MobCategory == "Boss" and #activeBossList > 0 then
                            -- OPTIMISATION ACTIVE : Vérifier si un des bosses sélectionnés est déjà vivant dans le jeu !
                            local aliveBoss = FindAliveBossFromList(activeBossList, Hub.Farm.RegionFilter)
                            local currentBossName = nil

                            if aliveBoss then
                                -- Un boss sélectionné est vivant : s'y diriger immédiatement sans attendre !
                                for idx, bName in ipairs(activeBossList) do
                                    if IsTargetValid(aliveBoss, bName, "All", "Boss") then
                                        bossRotationIndex = idx
                                        currentBossName = bName
                                        break
                                    end
                                end
                                if not currentBossName then
                                    currentBossName = activeBossList[bossRotationIndex] or activeBossList[1]
                                end
                                lastBossRotationTime = now
                                directWp = (aliveBoss.Root and aliveBoss.Root.Position) or GetMobSpawnPosition(currentBossName)
                            else
                                -- Aucun boss de la liste n'est vivant : alternance de patrouille selon l'intervalle configuré
                                local rotInterval = Hub.Farm.BossRotationInterval or 15.0
                                if #activeBossList > 1 and (now - lastBossRotationTime) >= rotInterval then
                                    bossRotationIndex = (bossRotationIndex % #activeBossList) + 1
                                    lastBossRotationTime = now
                                end

                                if bossRotationIndex > #activeBossList then
                                    bossRotationIndex = 1
                                end

                                currentBossName = activeBossList[bossRotationIndex]
                                directWp = GetMobSpawnPosition(currentBossName)
                            end

                            travelTargetName = currentBossName
                        elseif Hub.Farm.TargetMob and Hub.Farm.TargetMob ~= "All" and type(Hub.Farm.TargetMob) == "string" then
                            travelTargetName = Hub.Farm.TargetMob
                            directWp = GetMobSpawnPosition(travelTargetName)
                            if not directWp then
                                local tLow = string.lower(travelTargetName)
                                local tClean = string.gsub(tLow, "%s+", "")
                                for wpName, wpPos in pairs(MobSpawnWaypoints) do
                                    local wLow = string.lower(wpName)
                                    local wClean = string.gsub(wLow, "%s+", "")
                                    if wLow == tLow or wClean == tClean or string.find(wLow, tLow) or string.find(tLow, wLow) then
                                        directWp = wpPos
                                        break
                                    end
                                end
                            end
                        end

                        if directWp then
                            if (myPos - directWp).Magnitude > 60 then
                                TeleportToPosition(directWp, (travelTargetName or "Boss") .. " Spawn")
                            end
                        elseif Hub.Farm.RegionFilter ~= "All" then
                            -- 2. Téléportation à la région sélectionnée
                            local wp = RegionWaypoints[Hub.Farm.RegionFilter]
                            if wp and (myPos - wp).Magnitude > 80 then
                                TeleportToPosition(wp, Hub.Farm.RegionFilter)
                            end
                        end
                    end
                end
            end
        end
    else
        if not Hub.Farm.PlayerFarm then
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            RemoveFarmPlatform()
        end
    end

    -- Player Auto Farm Execution
    if Hub.Farm.PlayerFarm and not Hub.IsInteractingQuest and not Hub.IsCollectingLoot then
        local myRoot = GetRootPart()
        local myHum = GetHumanoid()
        if myRoot and myHum and myHum.Health > 0 then
            if IsPlayerStunnedOrRagdolled() then
                RemoveFarmPlatform()
            else
                local target = Hub.LockedTarget

                if target and target.Type == "Player" then
                    if not IsPlayerTargetValid(target, Hub.Farm.SelectedPlayer) then
                        target = nil
                        Hub.LockedTarget = nil
                    end
                else
                    target = nil
                end

                if not target then
                    target = GetClosestPlayer(Hub.Farm.SelectedPlayer)
                    Hub.LockedTarget = target
                end

                if target and target.Position and target.Position.Y > 0 and target.Position.Y < 2500 then
                    -- Mettre à jour dynamiquement Root s'il est désormais streamé
                    if not target.Root and target.Model then
                        target.Root = target.Model:FindFirstChild("HumanoidRootPart") or target.Model:FindFirstChild("Torso")
                    end

                    local playerPos = (target.Root and target.Root.Position) or target.Position
                    local myDist = (myRoot.Position - playerPos).Magnitude

                    -- Si la cible est éloignée (> 40 studs), se téléporter directement à proximité sans notification intempestive
                    if myDist > 40 then
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                        myRoot.CFrame = CFrame.new(playerPos + Vector3.new(0, (Hub.Farm.PlayerHeightOffset or 3.2) + 1, 0))
                        EnsureFarmPlatform(myRoot.CFrame)
                    end

                    Hub.CurrentTarget = target
                    local offset = Hub.Farm.PlayerHeightOffset or 3.2
                    local targetCFrame

                    local lookDir = (target.Root and target.Root.CFrame.LookVector) or (target.CFrame and target.CFrame.LookVector) or Vector3.new(0, 0, 1)
                    local flatDir = Vector3.new(lookDir.X, 0, lookDir.Z)
                    if flatDir.Magnitude < 0.01 then flatDir = Vector3.new(0, 0, 1) else flatDir = flatDir.Unit end

                    if Hub.Farm.PlayerSafeMode == "Overhead" then
                        -- Rester fermement au-dessus de la cible en position debout (sans basculement vertical vers le vide)
                        local targetPos = playerPos + Vector3.new(0, offset, 0)
                        targetCFrame = CFrame.lookAt(targetPos, targetPos + flatDir) * CFrame.Angles(-math.rad(45), 0, 0)
                    else
                        -- Devant la cible
                        local targetPos = playerPos + (flatDir * (Hub.Farm.PlayerDistance or 2.5))
                        targetCFrame = CFrame.lookAt(targetPos, playerPos)
                    end

                    myRoot.CFrame = targetCFrame
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero

                    EnsureFarmPlatform(targetCFrame)

                    -- Auto M1 Attack (uniquement à portée de combat)
                    if Hub.Farm.AutoM1 and myDist <= 30 and (now - lastAttack) >= 0.28 * (0.9 + math.random() * 0.3) then
                        lastAttack = now
                        local hitCount = Hub.Farm.MultiHit and (Hub.Farm.MultiHitCount or 3) or 1
                        PerformAttack(hitCount)
                    end

                    -- Auto Skills Rotation (uniquement à portée de frappe)
                    if Hub.Farm.AutoSkills and myDist <= 30 then
                        CastAvailableSkill()
                    end
                else
                    Hub.CurrentTarget = nil
                    Hub.LockedTarget = nil
                    RemoveFarmPlatform()
                end
            end
        end
    end

    -- Auto Collect Chests, Loot Drops & Demon Souls (Ultra-Reliable Vacuum Queue)
    local lootCheckInterval = ((lastBossKillPos and (now - lastBossKillTime) < (Hub.Farm.BossLootWaitTime or 5.0)) or (lastMobKillPos and (now - lastMobKillTime) < (Hub.Farm.MobLootWaitTime or 2.5))) and 0.15 or 0.50
    if (Hub.Farm.AutoCollectChests or Hub.Farm.AutoCollectLoot or Hub.Farm.AutoCollectSouls) and not Hub.IsCollectingLoot and (now - lastChestLootCheck) >= lootCheckInterval then
        lastChestLootCheck = now
        local myRoot = GetRootPart()
        local myHum = GetHumanoid()
        if myRoot and myHum and myHum.Health > 0 then
            local myPos = myRoot.Position
            local myUserId = LocalPlayer.UserId
            local refPos = (lastBossKillPos and (now - lastBossKillTime) < (Hub.Farm.BossLootWaitTime or 5.0)) and lastBossKillPos 
                or ((lastMobKillPos and (now - lastMobKillTime) < (Hub.Farm.MobLootWaitTime or 2.5)) and lastMobKillPos or myPos)

            -- Helper: Nettoyer et aspirer TOUS les LootDrops autour d'un point (Zéro Miss)
            local function VacuumAllDrops(centerPos, maxDist, timeout)
                local vDeadline = tick() + (timeout or 6.0)
                local lFolder = Workspace:FindFirstChild("LootDrops")
                local cs = game:GetService("CollectionService")

                while tick() < vDeadline and Hub.Alive do
                    local r = GetRootPart()
                    if not r then break end
                    local currentPos = r.Position

                    local candidateDrops = {}
                    local function evaluateCandidate(item)
                        if not item or not item.Parent then return end
                        if item:FindFirstAncestor("Regions") or item:FindFirstAncestor("StationaryNpcs") then return end
                        if item.Name == "Regions" or item.Name == "Debree" then return end

                        -- Ignorer impérativement les drops déjà réclamés
                        if item:GetAttribute("DropClaimedBy") ~= nil then return end

                        local isDrop = (item:GetAttribute("DropItemId") ~= nil) or (item.Parent == lFolder) or cs:HasTag(item, "LootDrop")
                        if not isDrop then return end

                        local ownerId = item:GetAttribute("DropOwnerUserId")
                        local reserved = item:GetAttribute("DropReservedFor")
                        local canClaim = (ownerId == nil or ownerId == myUserId or ownerId == 0)
                        if reserved and not string.find(tostring(reserved), "," .. myUserId .. ",", 1, true) then
                            canClaim = false
                        end
                        if not canClaim then return end

                        -- Coordonnée exacte d'atterrissage (DropTarget prioritaire sur la position en vol)
                        local dropTarget = item:GetAttribute("DropTarget")
                        local part = item:IsA("BasePart") and item or (item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
                        local pos = (typeof(dropTarget) == "Vector3" and dropTarget) or (part and part.Position) or (item:IsA("Model") and item:GetPivot().Position)
                        if not pos then return end

                        local d = (pos - (centerPos or currentPos)).Magnitude
                        if d <= (maxDist or 350) then
                            table.insert(candidateDrops, { Item = item, Part = part, Pos = pos, Dist = d })
                        end
                    end

                    if lFolder then
                        for _, item in ipairs(lFolder:GetChildren()) do evaluateCandidate(item) end
                    end
                    for _, item in ipairs(cs:GetTagged("LootDrop")) do
                        if not lFolder or item.Parent ~= lFolder then evaluateCandidate(item) end
                    end

                    -- Si aucun drop détecté, attendre 0.25s et re-vérifier (le temps que le serveur finisse de les instancier)
                    if #candidateDrops == 0 then
                        task.wait(0.25)
                        if lFolder then
                            for _, item in ipairs(lFolder:GetChildren()) do evaluateCandidate(item) end
                        end
                        for _, item in ipairs(cs:GetTagged("LootDrop")) do
                            if not lFolder or item.Parent ~= lFolder then evaluateCandidate(item) end
                        end
                        if #candidateDrops == 0 then
                            break
                        end
                    end

                    table.sort(candidateDrops, function(a, b) return a.Dist < b.Dist end)

                    local collectedAny = false
                    for _, dropData in ipairs(candidateDrops) do
                        local item = dropData.Item
                        local part = dropData.Part
                        local pos = dropData.Pos

                        -- Re-vérifier que le drop n'a pas été absorbé entre-temps
                        if item and item.Parent and item:GetAttribute("DropClaimedBy") == nil and r then
                            local targetCF = CFrame.new(pos + Vector3.new(0, 1.2, 0))
                            r.CFrame = targetCF
                            r.AssemblyLinearVelocity = Vector3.zero
                            r.AssemblyAngularVelocity = Vector3.zero
                            EnsureFarmPlatform(targetCF)

                            local p = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if p then
                                -- FIX MCP: VisualBinder garde prompt.Enabled=false pendant le vol (phase flight).
                                -- Forcer true trop tôt = reject serveur. Attendre la fin du vol.
                                local waitFlight = 0
                                while not p.Enabled and waitFlight < 1.5 and item.Parent and item:GetAttribute("DropClaimedBy") == nil do
                                    task.wait(0.15)
                                    waitFlight = waitFlight + 0.15
                                end
                                local oldDist = p.MaxActivationDistance
                                pcall(function()
                                    p.MaxActivationDistance = 60
                                end)

                                -- PROVEN MCP live (souls): fireproximityprompt alone never
                                -- collects Custom prompts; legit InputHoldBegin/End DOES.
                                local needHold = 0
                                pcall(function() needHold = tonumber(p.HoldDuration) or 0 end)
                                if p.Enabled then
                                    pcall(function() p:InputHoldBegin() end)
                                    task.wait(math.min(needHold + 0.4, 3.0))
                                    pcall(function() p:InputHoldEnd() end)
                                end
                                pcall(fireproximityprompt, p)

                                local promptKey = (p.KeyboardKeyCode ~= Enum.KeyCode.Unknown and p.KeyboardKeyCode) or Enum.KeyCode.T
                                if VirtualInputManager then
                                    VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                                    task.wait(0.05)
                                    VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                                end

                                pcall(function()
                                    p.MaxActivationDistance = oldDist
                                end)
                            end

                            if part then
                                pcall(function()
                                    firetouchinterest(r, part, 0)
                                    task.wait(0.02)
                                    firetouchinterest(r, part, 1)
                                end)
                            end

                            -- Délai de réplication serveur nécessaire (140ms pour éviter le rate-limit / spam filter)
                            task.wait(0.14)

                            -- Si le serveur n'a pas encore validé l'absorption, re-tirer une confirmation
                            if item and item.Parent and item:GetAttribute("DropClaimedBy") == nil then
                                if p then
                                    if p.Enabled then
                                        local need2 = 0
                                        pcall(function() need2 = tonumber(p.HoldDuration) or 0 end)
                                        pcall(function() p:InputHoldBegin() end)
                                        task.wait(math.min(need2 + 0.4, 3.0))
                                        pcall(function() p:InputHoldEnd() end)
                                    end
                                    pcall(fireproximityprompt, p)
                                end
                                if part then
                                    pcall(function()
                                        firetouchinterest(r, part, 0)
                                        task.wait(0.02)
                                        firetouchinterest(r, part, 1)
                                    end)
                                end
                                task.wait(0.08)
                            end

                            collectedAny = true
                        end
                    end

                    if not collectedAny then break end
                    task.wait(0.08)
                end
            end

            -- Détecter si un coffre valide doit être ouvert
            local targetChestPrompt = nil
            local targetChestPos = nil
            local targetChestModel = nil

            if Hub.Farm.AutoCollectChests then
                local function isValidChest(prompt, partPos)
                    if not prompt or not partPos or not prompt:IsA("ProximityPrompt") then return false end
                    if not prompt.Parent then return false end
                    if (partPos - myPos).Magnitude > 350 and (partPos - refPos).Magnitude > 350 then return false end

                    local act = (prompt.ActionText or ""):lower()
                    local obj = (prompt.ObjectText or ""):lower()
                    local pName = (prompt.Name or ""):lower()
                    if act:find("chat") or act:find("talk") or act:find("speak") or act:find("train") or act:find("buy") or act:find("shop") or act:find("quest") or act:find("dialogue") then
                        return false
                    end
                    if obj:find("trainer") or obj:find("urokodaki") or obj:find("muzan") or obj:find("npc") or obj:find("station") or obj:find("corps") or obj:find("slayer") or obj:find("shop") then
                        return false
                    end

                    local cur = prompt.Parent
                    local chestModel = nil
                    while cur and cur ~= Workspace do
                        if cur.Parent == Workspace:FindFirstChild("Chests") or cur:GetAttribute("ChestState") ~= nil or cur:GetAttribute("IsOpen") ~= nil or cur:GetAttribute("ChestId") ~= nil or cur:GetAttribute("ChestGuid") ~= nil then
                            chestModel = cur
                            break
                        end
                        cur = cur.Parent
                    end

                    if not chestModel and not pName:find("chest") and not obj:find("chest") and not obj:find("cache") and not act:find("open") then
                        return false
                    end

                    if chestModel then
                        if chestModel:GetAttribute("IsOpen") == true or chestModel:GetAttribute("ChestState") == "Opened" or chestModel:GetAttribute("ChestState") == "Despawned" then
                            return false
                        end
                        -- Si le coffre est marqué Locked ET que le prompt n'est pas actif, attendre la fin de la vague
                        if chestModel:GetAttribute("ChestState") == "Locked" and not prompt.Enabled then
                            return false
                        end
                        local mName = (chestModel.Name or ""):lower()
                        if mName:find("mound") then
                            return false
                        end
                    end

                    return true, chestModel
                end

                local cFolder = Workspace:FindFirstChild("Chests")
                if cFolder then
                    for _, c in ipairs(cFolder:GetDescendants()) do
                        if c:IsA("ProximityPrompt") then
                            local parent = c.Parent
                            local partPos = parent and (parent:IsA("Attachment") and parent.WorldPosition or (parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and parent:GetPivot().Position)))
                            local ok, chM = isValidChest(c, partPos)
                            if ok then
                                targetChestPrompt = c
                                targetChestPos = partPos
                                targetChestModel = chM
                                break
                            end
                        end
                    end
                end

                if not targetChestPrompt then
                    local cs = game:GetService("CollectionService")
                    for _, c in ipairs(cs:GetTagged("Chest")) do
                        for _, p in ipairs(c:GetDescendants()) do
                            if p:IsA("ProximityPrompt") then
                                local parent = p.Parent
                                local partPos = parent and (parent:IsA("Attachment") and parent.WorldPosition or (parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and parent:GetPivot().Position)))
                                local ok, chM = isValidChest(p, partPos)
                                if ok then
                                    targetChestPrompt = p
                                    targetChestPos = partPos
                                    targetChestModel = chM
                                    break
                                end
                            end
                        end
                        if targetChestPrompt then break end
                    end
                end
            end

            -- Détection des Demon Souls (Weak Soul, Strong Soul, Brave Soul)
            -- FIX MCP live: Model in Workspace.Debree, SoulPrompt/Claim starts disabled.
            local targetSoulPrompt = nil
            local targetSoulPos = nil
            local targetSoulPart = nil
            local targetSoulModel = nil
            if Hub.Farm.AutoCollectSouls and not targetChestPrompt then
                local function checkAndSetSoul(item)
                    if not item or not item.Parent then return false end
                    if item:FindFirstAncestor("StationaryNpcs") or item:FindFirstAncestor("ActiveNpcs") then return false end
                    if item:FindFirstAncestor("Regions") and not item:FindFirstAncestor("Debree") then return false end
                    if item:FindFirstChildOfClass("Humanoid") then return false end

                    local iName = (item.Name or "")
                    local name = iName:lower()
                    local isSoul = name == "weak soul" or name == "strong soul" or name == "brave soul"
                    if not isSoul then
                        if name:find("soul") then
                            local pn = item.Parent and item.Parent.Name or ""
                            if pn == "Debree" or pn == "LootDrops" or item.Parent == Workspace then
                                isSoul = true
                            else
                                return false
                            end
                        elseif item:GetAttribute("IsSoul") or item:GetAttribute("SoulType") then
                            isSoul = true
                        end
                    end
                    if not isSoul then return false end

                    local pos = nil
                    pcall(function()
                        if item:IsA("Model") then pos = item:GetPivot().Position
                        elseif item:IsA("BasePart") then pos = item.Position end
                    end)
                    local part = item:IsA("BasePart") and item or (item:FindFirstChild("Root") or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
                    if not pos then pos = part and part.Position or nil end
                    if not pos then return false end
                    if (pos - myPos).Magnitude > 350 and (pos - refPos).Magnitude > 350 then return false end

                    targetSoulPrompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                    targetSoulPos = pos
                    targetSoulPart = part
                    targetSoulModel = item:IsA("Model") and item or nil
                    return true
                end

                for _, item in ipairs(Workspace:GetChildren()) do
                    if checkAndSetSoul(item) then break end
                end
                if not targetSoulPos then
                    local debree = Workspace:FindFirstChild("Debree")
                    if debree then
                        -- exact-name descendants first (fast path for live souls)
                        for _, item in ipairs(debree:GetDescendants()) do
                            if item:IsA("Model") and (item.Name == "Weak Soul" or item.Name == "Strong Soul" or item.Name == "Brave Soul") then
                                if checkAndSetSoul(item) then break end
                            end
                        end
                        if not targetSoulPos then
                            for _, item in ipairs(debree:GetChildren()) do
                                if checkAndSetSoul(item) then break end
                            end
                        end
                    end
                end
                if not targetSoulPos then
                    local lFolder = Workspace:FindFirstChild("LootDrops")
                    if lFolder then
                        for _, item in ipairs(lFolder:GetChildren()) do
                            if checkAndSetSoul(item) then break end
                        end
                    end
                end
                if not targetSoulPos then
                    local cs = game:GetService("CollectionService")
                    for _, tag in ipairs({"Soul", "Souls", "DemonSoul"}) do
                        for _, item in ipairs(cs:GetTagged(tag)) do
                            if checkAndSetSoul(item) then break end
                        end
                        if targetSoulPos then break end
                    end
                end
            end

            -- Détection de drops existants au sol (LootDrops)
            local hasNearbyDrops = false
            if Hub.Farm.AutoCollectLoot and not targetChestPrompt and not targetSoulPos then
                local lFolder = Workspace:FindFirstChild("LootDrops")
                local cs = game:GetService("CollectionService")
                local function checkHasDrop(item)
                    if not item or not item.Parent then return false end
                    if item:FindFirstAncestor("Regions") or item:FindFirstAncestor("StationaryNpcs") then return false end
                    if item.Name == "Regions" or item.Name == "Debree" then return false end
                    if item:GetAttribute("DropClaimedBy") ~= nil then return false end
                    local isDrop = (item:GetAttribute("DropItemId") ~= nil) or (item.Parent == lFolder) or cs:HasTag(item, "LootDrop")
                    if not isDrop then return false end
                    local dropTarget = item:GetAttribute("DropTarget")
                    local part = item:IsA("BasePart") and item or (item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
                    local pos = (typeof(dropTarget) == "Vector3" and dropTarget) or (part and part.Position) or (item:IsA("Model") and item:GetPivot().Position)
                    if pos and ((pos - myPos).Magnitude <= 350 or (pos - refPos).Magnitude <= 350) then
                        return true
                    end
                    return false
                end

                if lFolder then
                    for _, item in ipairs(lFolder:GetChildren()) do
                        if checkHasDrop(item) then hasNearbyDrops = true break end
                    end
                end
                if not hasNearbyDrops then
                    for _, item in ipairs(cs:GetTagged("LootDrop")) do
                        if not lFolder or item.Parent ~= lFolder then
                            if checkHasDrop(item) then hasNearbyDrops = true break end
                        end
                    end
                end
            end

            -- Exécuter la routine de collecte complète (Coffre + Aspiration de tous les drops + Âmes)
            if targetChestPrompt or targetSoulPos or hasNearbyDrops then
                Hub.IsCollectingLoot = true
                task.spawn(function()
                    local r = GetRootPart()
                    if not r then Hub.IsCollectingLoot = false return end

                    -- 1. CAS COFFRE : Ouvrir le coffre, attendre l'éjection du loot et tout aspirer
                    -- FIX MCP raid: Sealed Cache / boss chest = ChestId + ChestState Locked->Opened,
                    -- le loot = LootDrop + Souls. Il faut aspirer les deux après ouverture.
                    if targetChestPrompt and targetChestPos then
                        local prompt = targetChestPrompt
                        local oldDist = prompt.MaxActivationDistance
                        pcall(function()
                            prompt.MaxActivationDistance = 60
                        end)

                        -- Se placer devant le coffre avec plateforme stable
                        local chestCF = CFrame.new(targetChestPos + Vector3.new(0, 1.5, 2.5), targetChestPos)
                        r.CFrame = chestCF
                        r.AssemblyLinearVelocity = Vector3.zero
                        r.AssemblyAngularVelocity = Vector3.zero
                        EnsureFarmPlatform(chestCF)
                        task.wait(0.18)

                        -- PROVEN MCP live (souls): fire seul ne collecte pas les prompts
                        -- Custom; hold légitime requis. Même pattern pour les coffres.
                        local needHold = 0
                        pcall(function() needHold = tonumber(prompt.HoldDuration) or 0 end)
                        if prompt.Enabled then
                            pcall(function() prompt:InputHoldBegin() end)
                            task.wait(math.min(needHold + 0.4, 3.0))
                            pcall(function() prompt:InputHoldEnd() end)
                        end
                        pcall(fireproximityprompt, prompt)

                        local promptKey = (prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode) or Enum.KeyCode.T
                        if VirtualInputManager then
                            VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                            task.wait(0.08)
                            VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                        end

                        -- Attendre que le coffre s'ouvre (animation & réplication serveur)
                        local openStart = tick()
                        while (tick() - openStart) < 2.5 do
                            if targetChestModel and (targetChestModel:GetAttribute("IsOpen") == true or targetChestModel:GetAttribute("ChestState") == "Opened") then
                                break
                            end
                            if (tick() - openStart) > 0.6 and (tick() - openStart) < 0.75 then
                                if prompt.Enabled then
                                    pcall(function() prompt:InputHoldBegin() end)
                                    task.wait(0.3)
                                    pcall(function() prompt:InputHoldEnd() end)
                                end
                                pcall(fireproximityprompt, prompt)
                            end
                            task.wait(0.12)
                        end

                        pcall(function()
                            prompt.MaxActivationDistance = oldDist
                        end)

                        -- Attente active que les drops soient générés par le serveur et commencent à atterrir
                        -- FIX raid: les boss chests drop aussi des Souls dans Debree, pas que du LootDrop
                        local spawnWaitStart = tick()
                        while (tick() - spawnWaitStart) < 2.5 do
                            local dropsPresent = false
                            local lF = Workspace:FindFirstChild("LootDrops")
                            local cService = game:GetService("CollectionService")
                            local deb = Workspace:FindFirstChild("Debree")
                            if lF and #lF:GetChildren() > 0 then dropsPresent = true end
                            if not dropsPresent and #cService:GetTagged("LootDrop") > 0 then dropsPresent = true end
                            if not dropsPresent and deb then
                                for _, d in ipairs(deb:GetChildren()) do
                                    if d.Name == "Weak Soul" or d.Name == "Strong Soul" or d.Name == "Brave Soul" then
                                        dropsPresent = true
                                        break
                                    end
                                end
                            end
                            if dropsPresent then
                                task.wait(0.6)
                                break
                            end
                            task.wait(0.15)
                        end

                        -- Aspirer TOUS les drops générés par le coffre (timeout généreux de 6.0s)
                        VacuumAllDrops(targetChestPos, 250, 6.0)
                        -- + balayage âmes autour du coffre (raid boss chest loot des souls)
                        -- PROVEN: hold légitime requis, pas fire seul.
                        pcall(function()
                            local deb2 = Workspace:FindFirstChild("Debree")
                            if deb2 then
                                for _, s in ipairs(deb2:GetDescendants()) do
                                    if s:IsA("Model") and (s.Name == "Weak Soul" or s.Name == "Strong Soul" or s.Name == "Brave Soul") then
                                        local ok, sp = pcall(function() return s:GetPivot().Position end)
                                        if ok and sp and (sp - targetChestPos).Magnitude <= 250 then
                                            r.CFrame = CFrame.new(sp + Vector3.new(0, 0.6, 0))
                                            r.AssemblyLinearVelocity = Vector3.zero
                                            local pr = s:FindFirstChildWhichIsA("ProximityPrompt", true)
                                            if pr then
                                                local wt = 0
                                                while not pr.Enabled and wt < 3.0 and pr.Parent do
                                                    task.wait(0.1)
                                                    wt = wt + 0.1
                                                end
                                                pcall(function() pr.MaxActivationDistance = 60 end)
                                                if pr.Enabled then
                                                    local nh = 0
                                                    pcall(function() nh = tonumber(pr.HoldDuration) or 0 end)
                                                    pcall(function() pr:InputHoldBegin() end)
                                                    task.wait(math.min(nh + 0.4, 3.0))
                                                    pcall(function() pr:InputHoldEnd() end)
                                                    pcall(fireproximityprompt, pr)
                                                end
                                                task.wait(0.15)
                                            else
                                                task.wait(0.1)
                                                for _, off in ipairs({Vector3.new(2,0.6,0), Vector3.new(-2,0.6,0), Vector3.new(0,0.6,2)}) do
                                                    if not s.Parent then break end
                                                    r.CFrame = CFrame.new(sp + off)
                                                    task.wait(0.06)
                                                end
                                            end
                                        end
                                        if not s.Parent then break end
                                    end
                                end
                            end
                        end)

                    -- 2. CAS ÂME DE DÉMON (Soul)
                    -- PROVEN MCP live: fireproximityprompt never collects SoulPrompt
                    -- (GONE=false x40+); legit InputHoldBegin/End DOES (GONE=true).
                    elseif targetSoulPos then
                        local targetCF = CFrame.new(targetSoulPos + Vector3.new(0, 0.6, 0))
                        r.CFrame = targetCF
                        r.AssemblyLinearVelocity = Vector3.zero
                        r.AssemblyAngularVelocity = Vector3.zero
                        EnsureFarmPlatform(targetCF)
                        task.wait(0.12)

                        if targetSoulPrompt then
                            local prompt = targetSoulPrompt
                            local waitT = 0
                            while not prompt.Enabled and waitT < 3.0 and prompt.Parent do
                                task.wait(0.1)
                                waitT = waitT + 0.1
                            end
                            local oldDist = prompt.MaxActivationDistance
                            pcall(function()
                                prompt.MaxActivationDistance = 60
                            end)
                            local needHold = 0
                            pcall(function() needHold = tonumber(prompt.HoldDuration) or 0 end)
                            if prompt.Enabled then
                                pcall(function() prompt:InputHoldBegin() end)
                                task.wait(math.min(needHold + 0.4, 3.0))
                                pcall(function() prompt:InputHoldEnd() end)
                                pcall(fireproximityprompt, prompt)
                            else
                                pcall(fireproximityprompt, prompt)
                            end
                            local promptKey = (prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode) or Enum.KeyCode.T
                            if VirtualInputManager then
                                VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                                task.wait(0.06)
                                VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                            end
                            pcall(function()
                                prompt.MaxActivationDistance = oldDist
                            end)
                        end

                        if targetSoulPart then
                            pcall(function()
                                firetouchinterest(r, targetSoulPart, 0)
                                task.wait(0.03)
                                firetouchinterest(r, targetSoulPart, 1)
                            end)
                        end
                        -- Magnet sweep autour du pivot (le serveur ramasse au contact proche)
                        for _, off in ipairs({Vector3.new(2,0.6,0), Vector3.new(-2,0.6,0), Vector3.new(0,0.6,2), Vector3.new(0,0.6,-2), Vector3.new(0,1.5,0)}) do
                            if targetSoulModel and not targetSoulModel.Parent then break end
                            if targetSoulPart and not targetSoulPart.Parent then break end
                            r.CFrame = CFrame.new(targetSoulPos + off)
                            r.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.07)
                        end
                        task.wait(0.1)
                        lastMobKillPos = nil

                    -- 3. CAS LOOT AU SOL (Vacuum des drops existants)
                    elseif hasNearbyDrops then
                        VacuumAllDrops(refPos, 350, 4.0)
                    end

                    Hub.IsCollectingLoot = false
                end)
            end
        end
    end
end))

-- =====================================================================
-- 5b. Sealed Cache Farm (T1 / T2 / T3) + Guard Killer + Server Hop
-- =====================================================================
do
local TeleportService = game:GetService("TeleportService")
local CacheHttpService = game:GetService("HttpService")
local CollectionServiceC = game:GetService("CollectionService")

local CACHE_GUARD_KEYWORDS = { "groveraider", "raidcaptain", "cacheprowler", "prowlercaptain", "cachelancer", "lancercaptain" }

local function GetAllCacheChests()
    local result = {}
    local seen = {}
    local function tryAdd(inst)
        if not inst or seen[inst] then return end
        seen[inst] = true
        local chestId = inst:GetAttribute("ChestId")
        -- FIX MCP raid: ChestId peut être "Sealed Cache T1/T2/T3" mais aussi via ChestModel/Name.
        -- On accepte si Tiers match OU si le nom contient "sealed cache"/"cache".
        local idOk = (type(chestId) == "string" and Hub.CacheFarm.Tiers[chestId])
        if not idOk then
            local n = (inst.Name or ""):lower()
            local modelAttr = (inst:GetAttribute("ChestModel") or ""):lower()
            if n:find("sealed cache") or n:find("cache") or tostring(modelAttr):find("sealed cache") then
                -- vérifier que le tier est activé si on peut le déduire
                idOk = true
                for tier, enabled in pairs(Hub.CacheFarm.Tiers) do
                    if enabled and (n:find(tier:lower()) or tostring(modelAttr):find(tier:lower())) then
                        idOk = true
                        break
                    end
                end
            end
        end
        if not idOk then return end
        local state = inst:GetAttribute("ChestState")
        local isOpen = inst:GetAttribute("IsOpen") == true or state == "Opened" or state == "Despawned"
        local guid = inst:GetAttribute("ChestGuid")
        local alreadyLooted = (type(guid) == "string" and Hub.CacheFarm.Opened[guid] == true)
        if not isOpen and not alreadyLooted then
            table.insert(result, inst)
        end
    end
    for _, inst in ipairs(CollectionServiceC:GetTagged("Chest")) do
        tryAdd(inst)
    end
    -- FIX: fallback si le tag Chest n'est pas encore posé (streaming / retard serveur)
    pcall(function()
        local cf = Workspace:FindFirstChild("Chests")
        if cf then
            for _, inst in ipairs(cf:GetDescendants()) do
                if inst:IsA("Model") or inst:IsA("BasePart") then
                    if inst:GetAttribute("ChestId") ~= nil or inst:GetAttribute("ChestGuid") ~= nil or inst:GetAttribute("ChestState") ~= nil then
                        -- remonter au modèle coffre
                        local cur = inst
                        while cur and cur.Parent and cur.Parent ~= Workspace and cur.Parent ~= cf do
                            cur = cur.Parent
                        end
                        tryAdd(cur)
                    end
                end
            end
        end
    end)
    return result
end

local function GetChestPrompt(chest)
    if not chest then return nil end
    for _, d in ipairs(chest:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

local function GetCacheGuardsNear(pos, radius)
    local guards = {}
    for _, mob in ipairs(GetAliveMobs()) do
        if mob.Root and mob.Humanoid and mob.Humanoid.Health > 0 then
            local combined = string.lower(tostring(mob.Name or "")) .. string.lower(tostring(mob.Type or ""))
            if not string.find(combined, "civilian", 1, true) then
                local d = (mob.Root.Position - pos).Magnitude
                if d <= radius then
                    local isGuard = false
                    for _, kw in ipairs(CACHE_GUARD_KEYWORDS) do
                        if string.find(combined, kw, 1, true) then isGuard = true break end
                    end
                    table.insert(guards, { Mob = mob, Dist = d, IsGuard = isGuard })
                end
            end
        end
    end
    table.sort(guards, function(a, b)
        if a.IsGuard ~= b.IsGuard then return a.IsGuard end
        return a.Dist < b.Dist
    end)
    return guards
end

local function BurstKillCacheGuard(guard, myRoot)
    local gRoot = guard.Root
    if not gRoot or not gRoot.Parent then return end
    local offset = Hub.Farm.HeightOffset or 2.6
    local cf = CFrame.new(gRoot.Position + Vector3.new(0, offset, 0), gRoot.Position)
    myRoot.CFrame = cf
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
    EnsureFarmPlatform(cf)
    PerformAttack(5)
    if Hub.Farm.AutoSkills then CastAvailableSkill() end
end

local function TryOpenCacheChest(chest, chestPos, myRoot)
    local prompt = GetChestPrompt(chest)
    if not prompt then return false end

    local oldDist = prompt.MaxActivationDistance
    pcall(function()
        prompt.MaxActivationDistance = 60
    end)

    local cf = CFrame.new(chestPos + Vector3.new(0, 1.5, 2.5), chestPos)
    myRoot.CFrame = cf
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
    EnsureFarmPlatform(cf)
    task.wait(0.2)

    -- PROVEN MCP live: hold légitime requis pour les prompts Custom.
    local needHold = 0
    pcall(function() needHold = tonumber(prompt.HoldDuration) or 0 end)
    if prompt.Enabled then
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(math.min(needHold + 0.4, 3.0))
        pcall(function() prompt:InputHoldEnd() end)
    end
    pcall(fireproximityprompt, prompt)

    local promptKey = (prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode) or Enum.KeyCode.T
    if VirtualInputManager then
        VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
        task.wait(0.08)
        VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
    end
    -- Re-fire si Locked (le coffre raid se déverrouille après les gardes)
    task.wait(0.4)
    if chest.Parent and chest:GetAttribute("ChestState") ~= "Opened" and chest:GetAttribute("IsOpen") ~= true then
        if prompt.Enabled then
            pcall(function() prompt:InputHoldBegin() end)
            task.wait(0.3)
            pcall(function() prompt:InputHoldEnd() end)
        end
        pcall(fireproximityprompt, prompt)
    end
    task.wait(0.15)

    local chestPart = chest:FindFirstChildWhichIsA("BasePart", true)
    if chestPart then
        pcall(function()
            firetouchinterest(myRoot, chestPart, 0)
            task.wait(0.03)
            firetouchinterest(myRoot, chestPart, 1)
        end)
    end

    pcall(function()
        prompt.MaxActivationDistance = oldDist
    end)

    local isOpen = (chest:GetAttribute("IsOpen") == true) or (chest:GetAttribute("ChestState") == "Opened")
    local guid = chest:GetAttribute("ChestGuid")
    if isOpen and type(guid) == "string" then
        Hub.CacheFarm.Opened[guid] = true
    end
    -- FIX raid: après ouverture, sweep local loot + souls (boss chest drop les deux).
    -- On stocke dans Hub pour que l'Auto Farm vienne aspirer même si CacheFarm tourne.
    if isOpen then
        Hub.CacheFarm.LastOpenedPos = chestPos
        Hub.CacheFarm.LastOpenedTime = os.clock()
        task.spawn(function()
            local r2 = GetRootPart()
            if not r2 then return end
            task.wait(0.6)
            if not chest.Parent then return end
            -- sweep drops
            pcall(function()
                local lf = Workspace:FindFirstChild("LootDrops")
                if lf then
                    for _, it in ipairs(lf:GetChildren()) do
                        if not it.Parent then break end
                        local pp = it:IsA("BasePart") and it.Position or nil
                        if not pp then
                            local ok, pv = pcall(function() return it:GetPivot().Position end)
                            if ok then pp = pv end
                        end
                        if pp and (pp - chestPos).Magnitude <= 120 then
                            r2.CFrame = CFrame.new(pp + Vector3.new(0, 1.2, 0))
                            task.wait(0.12)
                            local pr = it:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if pr and pr.Enabled then
                                local nh = 0
                                pcall(function() nh = tonumber(pr.HoldDuration) or 0 end)
                                pcall(function() pr:InputHoldBegin() end)
                                task.wait(math.min(nh + 0.4, 3.0))
                                pcall(function() pr:InputHoldEnd() end)
                            end
                            if pr then pcall(fireproximityprompt, pr) end
                        end
                    end
                end
            end)
            -- sweep souls (SoulPrompt/Claim spawns disabled: wait Enabled then fire)
            pcall(function()
                local deb = Workspace:FindFirstChild("Debree")
                if deb then
                    for _, s in ipairs(deb:GetDescendants()) do
                        if s:IsA("Model") and (s.Name == "Weak Soul" or s.Name == "Strong Soul" or s.Name == "Brave Soul") then
                            local ok, sp = pcall(function() return s:GetPivot().Position end)
                            if ok and sp and (sp - chestPos).Magnitude <= 150 then
                                r2.CFrame = CFrame.new(sp + Vector3.new(0, 0.6, 0))
                                r2.AssemblyLinearVelocity = Vector3.zero
                                local pr = s:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if pr then
                                    local wt = 0
                                    while not pr.Enabled and wt < 3.0 and pr.Parent do
                                        task.wait(0.1)
                                        wt = wt + 0.1
                                    end
                                    pcall(function()
                                        pr.MaxActivationDistance = 60
                                    end)
                                    if pr.Enabled then
                                        local nh2 = 0
                                        pcall(function() nh2 = tonumber(pr.HoldDuration) or 0 end)
                                        pcall(function() pr:InputHoldBegin() end)
                                        task.wait(math.min(nh2 + 0.4, 3.0))
                                        pcall(function() pr:InputHoldEnd() end)
                                        pcall(fireproximityprompt, pr)
                                    end
                                    task.wait(0.15)
                                else
                                    task.wait(0.12)
                                end
                            end
                            if not s.Parent then break end
                        end
                    end
                end
            end)
        end)
    end
    return isOpen
end

local function FetchPublicServers()
    local placeId = game.PlaceId
    local servers = {}
    local cursor = nil
    for _ = 1, 2 do
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId)
        if cursor and cursor ~= "" then
            url = url .. "&cursor=" .. tostring(cursor)
        end
        local ok, body = pcall(function() return game:HttpGet(url, true) end)
        if not ok or type(body) ~= "string" or #body < 5 then break end
        local ok2, data = pcall(function() return CacheHttpService:JSONDecode(body) end)
        if not ok2 or type(data) ~= "table" or type(data.data) ~= "table" then break end
        for _, s in ipairs(data.data) do
            if type(s.id) == "string" then
                table.insert(servers, s)
            end
        end
        cursor = data.next_cursor
        if not cursor or cursor == "" then break end
    end
    return servers
end

local function GetRequestFunction()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if syn and type(syn.request) == "function" then return syn.request end
    if http and type(http.request) == "function" then return http.request end
    return nil
end

local function LaunchDeepLinkHop(placeId, jobId)
    local req = GetRequestFunction()
    if not req then return false end
    local links = {
        string.format("roblox://experiences/start?placeId=%d&gameInstanceId=%s", placeId, jobId),
        string.format("roblox://placeId=%d&gameInstanceId=%s", placeId, jobId),
    }
    for _, url in ipairs(links) do
        local ok = pcall(function() req({ Url = url, Method = "GET" }) end)
        if ok then return true end
    end
    return false
end

local function IsSubPlaceGodChild()
    if Hub.CacheFarm._IsSubPlace ~= nil then return Hub.CacheFarm._IsSubPlace end
    local isSub = false
    pcall(function()
        local body = game:HttpGet("https://games.roblox.com/v1/games?universeIds=" .. tostring(game.GameId), true)
        local data = CacheHttpService:JSONDecode(body)
        if type(data) == "table" and data.data and data.data[1] then
            local root = tonumber(data.data[1].rootPlaceId)
            if root and root ~= game.PlaceId then
                Hub.CacheFarm._RootPlaceId = root
                isSub = true
            end
        end
    end)
    Hub.CacheFarm._IsSubPlace = isSub
    return isSub
end

if not Hub.CacheFarm._TeleportFailConn then
    pcall(function()
        Hub.CacheFarm._TeleportFailConn = TeleportService.TeleportInitFailed:Connect(function(player, result, err)
            if player ~= LocalPlayer then return end
            local pid = Hub.CacheFarm.HopPendingId
            if not pid or Hub.CacheFarm.HopDeepLinkUsed then return end
            Hub.CacheFarm.HopDeepLinkUsed = true
            if LaunchDeepLinkHop(game.PlaceId, pid) then
                Hub.CacheFarm.SetStatus("World restricted (773) - opening server via Roblox app...")
            else
                Hub.CacheFarm.SetStatus("Teleport blocked (773) - no deep link support here")
                Kyoka:Notify({ Title = "Server Hop", Content = "This world refuses direct teleports (error 773). Use an executor with 'request' support or rejoin manually.", Type = "error", Duration = 7 })
            end
        end)
    end)
end

DoServerHop = function(manual)
    if not manual and not Hub.CacheFarm.Enabled then return end
    local now = os.clock()
    if (now - (Hub.CacheFarm.LastHop or 0)) < 6 then return end
    Hub.CacheFarm.LastHop = now

    Hub.CacheFarm.SetStatus("Searching for a fresh server...")
    local servers = FetchPublicServers()
    if #servers == 0 then
        Hub.CacheFarm.SetStatus("Server list unavailable (HttpService blocked?)")
        if manual then
            Kyoka:Notify({ Title = "Server Hop", Content = "Could not fetch the server list. Try again in a moment.", Type = "error" })
        else
            Hub.CacheFarm.NoCacheSince = os.clock()
        end
        return
    end

    local candidates = {}
    for _, s in ipairs(servers) do
        if s.id ~= game.JobId then
            local playing = tonumber(s.playing) or 0
            local maxPlayers = tonumber(s.maxPlayers) or 0
            if maxPlayers == 0 or playing < maxPlayers then
                table.insert(candidates, { id = s.id, playing = playing })
            end
        end
    end
    if #candidates == 0 then
        Hub.CacheFarm.SetStatus("No open servers right now, retrying...")
        Hub.CacheFarm.NoCacheSince = os.clock()
        return
    end

    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    local target = candidates[1]
    if not Hub.CacheFarm.PreferEmpty then
        target = candidates[math.random(1, math.min(#candidates, 15))]
    end

    Hub.CacheFarm.Hops = (Hub.CacheFarm.Hops or 0) + 1
    Hub.CacheFarm.NoCacheSince = nil
    Hub.CacheFarm.HopPendingId = target.id
    Hub.CacheFarm.HopDeepLinkUsed = false
    Hub.CacheFarm.SetStatus(string.format("Hopping to fresh server (%d players) - hop #%d", target.playing, Hub.CacheFarm.Hops))
    Kyoka:Notify({ Title = "Server Hop", Content = string.format("Hopping to a fresh server (%d players)...", target.playing), Type = "info", Duration = 5 })

    -- Methode 1 (officielle, marche meme sur les sous-lieux) : on demande au
    -- serveur de nous teleporter vers l'instance choisie via le signal du jeu
    -- "TeleportServer". C'est exactement le flux utilise par le menu du jeu,
    -- donc plus d'erreur 773 "place is restricted".
    local hopOk = false
    pcall(function()
        local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
        if Teleporter and Teleporter.Request then
            local success = Teleporter.Request({
                placeId = game.PlaceId,
                jobId = target.id,
                allowFallback = true,
            }, { Title = "Server Hop", SubTitle = string.format("%d players", target.playing) })
            hopOk = success == true
        end
    end)

    if not hopOk then
        pcall(function()
            local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
            if SignalFunction and SignalFunction.ToServer then
                SignalFunction.ToServer("TeleportServer", {
                    placeId = game.PlaceId,
                    jobId = target.id,
                    allowFallback = true,
                })
                hopOk = true
            end
        end)
    end

    if hopOk then
        Hub.CacheFarm.SetStatus(string.format("Server hop requested (%d players)...", target.playing))
        return
    end

    -- Methode 2 : teleport client classique (univers sans restriction de lieu)
    if IsSubPlaceGodChild() then
        if LaunchDeepLinkHop(game.PlaceId, target.id) then
            Hub.CacheFarm.HopDeepLinkUsed = true
            Hub.CacheFarm.SetStatus("Restricted world: opening server via Roblox app...")
            return
        end
    end

    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
    end)
    if not ok then
        if LaunchDeepLinkHop(game.PlaceId, target.id) then
            Hub.CacheFarm.HopDeepLinkUsed = true
        else
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end
end

local lastCacheScan = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    if not Hub.CacheFarm.Enabled then return end
    local now = os.clock()
    if (now - lastCacheScan) < 0.35 then return end
    lastCacheScan = now

    local myRoot = GetRootPart()
    local myHum = GetHumanoid()
    if not (myRoot and myHum and myHum.Health > 0) then return end
    if Hub.IsCollectingLoot or Hub.IsInteractingQuest then return end
    if Hub.Farm.AutoFarm or Hub.Farm.PlayerFarm then
        Hub.CacheFarm.SetStatus("Paused - turn off Auto Farm / Player Farm first")
        return
    end

    local chest, chestPos, bestDist = nil, nil, math.huge
    for _, c in ipairs(GetAllCacheChests()) do
        local okP, cpos = pcall(function() return c:GetPivot().Position end)
        if not okP or not cpos then
            local okB, bb = pcall(function() return c:GetBoundingBox() end)
            if okB and bb then cpos = bb.Position end
        end
        if cpos then
            local d = (cpos - myRoot.Position).Magnitude
            if d < bestDist then
                bestDist = d
                chest = c
                chestPos = cpos
            end
        end
    end

    if chest then
        Hub.CacheFarm.NoCacheSince = nil
        local guid = chest:GetAttribute("ChestGuid")
        local label = type(guid) == "string" and guid or (chest:GetAttribute("ChestId") or "Sealed Cache")
        local guards = GetCacheGuardsNear(chestPos, 130)
        local prompt = GetChestPrompt(chest)
        local state = chest:GetAttribute("ChestState")

        if #guards > 0 and Hub.CacheFarm.KillGuards then
            Hub.CacheFarm.SetStatus(string.format("%s: killing %d guard(s)", label, #guards))
            BurstKillCacheGuard(guards[1].Mob, myRoot)
        elseif #guards > 0 then
            Hub.CacheFarm.SetStatus(string.format("%s: %d guard(s) alive - enable Kill Guards", label, #guards))
            local cf = CFrame.new(chestPos + Vector3.new(0, 6, 0), chestPos)
            myRoot.CFrame = cf
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            EnsureFarmPlatform(cf)
        elseif prompt and (state ~= "Locked" or prompt.Enabled) then
            Hub.CacheFarm.SetStatus(label .. ": opening cache...")
            TryOpenCacheChest(chest, chestPos, myRoot)
        else
            Hub.CacheFarm.SetStatus(label .. ": waiting for unlock...")
            local cf = CFrame.new(chestPos + Vector3.new(0, 4, 0), chestPos)
            myRoot.CFrame = cf
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            EnsureFarmPlatform(cf)
        end
    else
        if not Hub.CacheFarm.NoCacheSince then Hub.CacheFarm.NoCacheSince = now end
        if Hub.CacheFarm.ServerHop then
            local waitLeft = (Hub.CacheFarm.HopDelay or 12) - (now - Hub.CacheFarm.NoCacheSince)
            if waitLeft > 0 then
                Hub.CacheFarm.SetStatus(string.format("No cache here - hopping in %.0fs", waitLeft))
            else
                Hub.CacheFarm.SetStatus("No cache here - hopping now...")
                DoServerHop(false)
            end
        else
            Hub.CacheFarm.SetStatus("No sealed cache found in this server")
        end
    end
end))

Hub.CacheFarm.DoServerHop = DoServerHop
end

-- =====================================================================
-- Black Marketer (Night Market timed vendor) - spawn detection + TP
-- =====================================================================
Hub.GetBlackMarketerInfo = function()
    local info = { Active = false, Position = nil, NextIn = nil, Cycle = nil }
    pcall(function()
        local cfg = require(ReplicatedStorage.Ouwland.Content.Misc.Npcs:FindFirstChild("Black Marketer"))
        local TimedVendor = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.TimedVendor)
        if type(cfg) == "table" and type(cfg.TimedVendor) == "table" then
            local state = TimedVendor.GetState(cfg.TimedVendor)
            info.Active = state.Active == true
            info.NextIn = state.NextEdgeIn
            info.Cycle = state.Cycle
            if info.Active then
                local spots = cfg.Spawns
                if type(spots) == "table" and #spots > 0 then
                    local idx = TimedVendor.GetSpotIndex(cfg.TimedVendor, state.Cycle, #spots)
                    local cfr = spots[idx]
                    if typeof(cfr) == "CFrame" then
                        info.Position = cfr.Position
                    elseif typeof(cfr) == "Vector3" then
                        info.Position = cfr
                    end
                end
            end
        end
    end)
    return info
end

Hub.TeleportToBlackMarketer = function(manual, info)
    info = info or Hub.GetBlackMarketerInfo()
    if not info.Active then
        if manual then
            local secs = info.NextIn or 0
            Kyoka:Notify({ Title = "Night Market", Content = string.format("Black Marketer not spawned yet (next in %d:%02d).", math.floor(secs / 60), math.floor(secs % 60)), Type = "warning", Duration = 5 })
        end
        return false
    end
    -- 1. Priorite au vrai modele spawn/stream (position exacte)
    local pos = nil
    pcall(function()
        local folders = {}
        local debree = Workspace:FindFirstChild("Debree")
        if debree and debree:FindFirstChild("Regions") then table.insert(folders, debree.Regions) end
        local humanoids = Workspace:FindFirstChild("Humanoids")
        if humanoids and humanoids:FindFirstChild("Regions") then table.insert(folders, humanoids.Regions) end
        for _, regs in ipairs(folders) do
            for _, reg in ipairs(regs:GetChildren()) do
                local stat = reg:FindFirstChild("StationaryNpcs")
                local act = reg:FindFirstChild("ActiveNpcs")
                local m = (stat and stat:FindFirstChild("Black Marketer")) or (act and act:FindFirstChild("Black Marketer"))
                if m then
                    local r = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m.PrimaryPart
                    if r then
                        pos = r.Position
                        break
                    end
                end
            end
            if pos then break end
        end
    end)
    -- 2. Sinon le spot exact calcule pour ce cycle (TimedVendor.GetSpotIndex)
    if not pos then pos = info.Position end
    -- 3. Dernier recours : spawn statique du jeu
    if not pos then
        pcall(function()
            local Regions = require(ReplicatedStorage.Regions)
            local raw = Regions.GetNpcSpawn("Black Marketer")
            if typeof(raw) == "Vector3" then
                pos = raw
            elseif typeof(raw) == "CFrame" then
                pos = raw.Position
            end
        end)
    end
    if not pos then
        if manual then
            Kyoka:Notify({ Title = "Night Market", Content = "Marketer is active but his position is unknown. Try again in a moment.", Type = "warning", Duration = 5 })
        end
        return false
    end
    TeleportToPosition(pos + Vector3.new(0, 2, 0), "Black Marketer (Night Market)")
    return true
end

table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if (now - (Hub.NightMarket.CheckAt or 0)) < 3 then return end
    Hub.NightMarket.CheckAt = now
    local info = Hub.GetBlackMarketerInfo()
    local label = Hub.NightMarket.Label
    if label then
        local text
        if info.Active then
            text = "Black Marketer (Night Market): SPAWNED - come get your loot!"
        else
            local secs = math.floor(info.NextIn or 0)
            text = string.format("Black Marketer (Night Market): not spawned - next in %d:%02d", math.floor(secs / 60), secs % 60)
        end
        Hub.GuiWrite(function() label:SetText(text) end)
    end
    if Hub.NightMarket.Auto and info.Active then
        if Hub.NightMarket.LastCycle ~= info.Cycle then
            Hub.NightMarket.LastCycle = info.Cycle
            if Hub.TeleportToBlackMarketer(false, info) then
                Kyoka:Notify({ Title = "Night Market", Content = "Black Marketer spawned - teleported to him!", Type = "success", Duration = 6 })
            end
        end
    elseif not info.Active then
        Hub.NightMarket.LastCycle = nil
    end
end))

-- =====================================================================
-- Discord Webhooks : boss loot drops + farm progress
-- =====================================================================
do
local function WebhookRequestFn()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if syn and type(syn.request) == "function" then return syn.request end
    if http and type(http.request) == "function" then return http.request end
    return nil
end

local function IsoNow()
    local ok, s = pcall(os.date, "!%Y-%m-%dT%H:%M:%SZ")
    if ok and type(s) == "string" then return s end
    return nil
end

local function FmtNum(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(n)
    local out = ""
    while #s > 3 do
        out = "," .. string.sub(s, -3) .. out
        s = string.sub(s, 1, #s - 3)
    end
    return s .. out
end

local function FmtSession(sec)
    sec = math.max(0, math.floor(tonumber(sec) or 0))
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    if h > 0 then
        return string.format("%dh %02dm", h, m)
    end
    local s = sec % 60
    if m > 0 then
        return string.format("%dm %02ds", m, s)
    end
    return string.format("%ds", s)
end

local function GetSlotData()
    local slot = nil
    pcall(function()
        local Utility = require(ReplicatedStorage.CAM.Global.Utility)
        slot = Utility.GetData(LocalPlayer, true)
    end)
    return slot
end

local function GetWen()
    local slot = GetSlotData()
    local w = slot and slot:FindFirstChild("Wen")
    return w and tonumber(w.Value) or 0
end

local function GetExpInfo()
    local slot = GetSlotData()
    local exp = slot and slot:FindFirstChild("Exp")
    local cur = exp and exp:FindFirstChild("Current") and tonumber(exp.Current.Value) or 0
    local goal = exp and exp:FindFirstChild("Goal") and tonumber(exp.Goal.Value) or 0
    return cur, goal
end

local function GetQuestsDoneTotal()
    local slot = GetSlotData()
    local quests = slot and slot:FindFirstChild("Quests")
    local done = quests and quests:FindFirstChild("Completed")
    if done then
        local n = 0
        for _ in ipairs(done:GetChildren()) do n = n + 1 end
        return n
    end
    return 0
end

local function RarityColorInt(rarity)
    local color = nil
    pcall(function()
        local Rar = require(ReplicatedStorage.CAM.Global.Rarities)
        color = Rar.Colors and (Rar.Colors[rarity] or Rar.Colors[tostring(rarity)])
    end)
    if typeof(color) == "Color3" then
        local v = math.floor(color.R * 255) * 65536 + math.floor(color.G * 255) * 256 + math.floor(color.B * 255)
        if v > 0 then return v end
    end
    return 0x7C6CFF
end

local function SnapshotInventory()
    local snap = {}
    pcall(function()
        local slot = GetSlotData()
        local inv = slot and slot:FindFirstChild("Inventory")
        local items = inv and inv:FindFirstChild("Inventory")
        if items then
            for _, it in ipairs(items:GetChildren()) do
                local amt = 1
                local a = it:FindFirstChild("Amount")
                if a then amt = tonumber(a.Value) or 1 end
                snap[it.Name] = (snap[it.Name] or 0) + amt
            end
        end
    end)
    return snap
end

Hub.RegisterBossKill = function(mob)
    if not mob then return end
    local hum = mob.Humanoid
    if hum and hum.Health > 0 then return end
    local name = tostring((mob.Name ~= "" and mob.Name) or mob.Type or "Unknown")
    Hub.Webhook.Defeated[name] = (Hub.Webhook.Defeated[name] or 0) + 1
    Hub.Webhook.BossKillsTotal = (Hub.Webhook.BossKillsTotal or 0) + 1
    Hub.Webhook.LastBoss = name
    Hub.Webhook.LastBossAt = os.clock()
end

Hub.WebhookSend = function(payload)
    local url = Hub.Webhook.Url
    if type(url) ~= "string" or #url < 10 then return false end
    local req = WebhookRequestFn()
    if not req then return false end
    local body = nil
    local okEnc = pcall(function()
        body = game:GetService("HttpService"):JSONEncode(payload)
    end)
    if not okEnc or type(body) ~= "string" then return false end
    task.spawn(function()
        pcall(function()
            req({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        end)
    end)
    return true
end

Hub.GetItemMeta = function(name)
    if type(name) ~= "string" or name == "" then return nil end
    local cached = Hub.Webhook.ItemMeta[name]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end
    local meta = nil
    pcall(function()
        local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
        local def = Items and Items[name]
        if def then
            meta = { Rarity = tonumber(def.Rarity) or 1, Icon = def.Icon }
        end
    end)
    Hub.Webhook.ItemMeta[name] = meta or false
    return meta
end

Hub.ResolveThumbUrl = function(name)
    local hit = Hub.Webhook.ThumbCache[name]
    if hit ~= nil then
        if hit == false then return nil end
        return hit
    end
    local url = nil
    pcall(function()
        local meta = Hub.GetItemMeta(name)
        local iconId = meta and meta.Icon and string.match(tostring(meta.Icon), "%d+")
        if iconId then
            local req = WebhookRequestFn()
            if req then
                local resp = req({ Url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. iconId .. "&size=420x420&format=Png&isCircular=false", Method = "GET" })
                local raw = nil
                if type(resp) == "string" then raw = resp
                elseif type(resp) == "table" then raw = resp.Body or resp.body end
                if type(raw) == "string" and #raw > 5 then
                    local data = game:GetService("HttpService"):JSONDecode(raw)
                    local first = data and data.data and data.data[1]
                    if first and type(first.imageUrl) == "string" and #first.imageUrl > 5 then
                        url = first.imageUrl
                    end
                end
            end
        end
    end)
    Hub.Webhook.ThumbCache[name] = url or false
    return url
end

Hub.BuildDropPayload = function(itemName, qty, source)
    local meta = Hub.GetItemMeta(itemName)
    local rarity = (meta and meta.Rarity) or 1
    local fields = {
        { name = "Player", value = LocalPlayer.Name, inline = true },
    }
    if source and source ~= "" then
        table.insert(fields, { name = "Source", value = tostring(source), inline = true })
    end
    local embed = {
        title = tostring(itemName),
        description = string.format("Obtained x%d", qty),
        color = RarityColorInt(rarity),
        fields = fields,
        footer = { text = "Slayers 2 Hub" },
    }
    local ts = IsoNow()
    if ts then embed.timestamp = ts end
    return { username = "Slayers 2 Hub | " .. LocalPlayer.Name, embeds = { embed } }
end

Hub.SendDropWebhook = function(itemName, qty, source)
    if not Hub.Webhook.DropsEnabled then return false end
    if Hub.Webhook.OnlyWhileFarming and not Hub.Farm.AutoFarm then return false end
    local meta = Hub.GetItemMeta(itemName)
    local rarity = (meta and meta.Rarity) or 1
    if rarity < (Hub.Webhook.MinRarity or 3) then return false end
    task.spawn(function()
        local thumb = Hub.ResolveThumbUrl(itemName)
        local payload = Hub.BuildDropPayload(itemName, qty, source)
        if thumb and payload and payload.embeds and payload.embeds[1] then
            payload.embeds[1].thumbnail = { url = thumb }
        end
        Hub.WebhookSend(payload)
    end)
    return true
end

Hub.BuildProgressPayload = function()
    local now = os.clock()
    local wen = GetWen()
    local cur, goal = GetExpInfo()
    if Hub.Webhook.WenStart == nil then Hub.Webhook.WenStart = wen end
    if Hub.Webhook.StartTime == nil or Hub.Webhook.StartTime == 0 then Hub.Webhook.StartTime = now end
    local earned = math.max(0, wen - (Hub.Webhook.WenStart or wen))
    local questsTotal = GetQuestsDoneTotal()
    if Hub.Webhook.QuestsStart == nil then Hub.Webhook.QuestsStart = questsTotal end
    local sorted = {}
    for name, count in pairs(Hub.Webhook.Defeated) do
        table.insert(sorted, { name = name, count = count })
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    local lines = {}
    for i = 1, math.min(#sorted, 10) do
        lines[#lines+1] = string.format("%s x%d", sorted[i].name, sorted[i].count)
    end
    if #lines == 0 then lines = { "No boss kills yet" } end
    local embed = {
        title = "Farm Progress",
        color = 0x7C6CFF,
        fields = {
            { name = "Level", value = tostring(GetPlayerLevel()), inline = true },
            { name = "Exp", value = string.format("%s / %s", FmtNum(cur), FmtNum(goal)), inline = true },
            { name = "Wen", value = FmtNum(wen), inline = true },
            { name = "Wen Earned", value = FmtNum(earned), inline = true },
            { name = "Quests Done", value = tostring(questsTotal), inline = true },
            { name = "Session", value = FmtSession(now - (Hub.Webhook.StartTime or now)), inline = true },
            { name = "Defeated", value = table.concat(lines, "\n"), inline = false },
        },
        footer = { text = "Slayers 2 Hub | " .. LocalPlayer.Name },
    }
    local ts = IsoNow()
    if ts then embed.timestamp = ts end
    return { username = "Slayers 2 Hub | " .. LocalPlayer.Name, embeds = { embed } }
end

Hub.SendProgressWebhook = function(manual)
    if not Hub.Webhook.ProgressEnabled and not manual then return false end
    local now = os.clock()
    if not manual and Hub.Webhook.OnlyWhileFarming and not Hub.Farm.AutoFarm then return false end
    task.spawn(function()
        Hub.WebhookSend(Hub.BuildProgressPayload())
    end)
    if not manual then Hub.Webhook.LastProgressAt = now end
    return true
end

local lastDropScan = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if Hub.Webhook.StartTime == 0 then Hub.Webhook.StartTime = now end
    if Hub.Webhook.WenStart == nil then Hub.Webhook.WenStart = GetWen() end
    if Hub.Webhook.QuestsStart == nil then Hub.Webhook.QuestsStart = GetQuestsDoneTotal() end

    if (Hub.Webhook.DropsEnabled or Hub.Webhook.ProgressEnabled) and (now - lastDropScan) >= 1.0 then
        lastDropScan = now
        local snap = SnapshotInventory()
        local prev = Hub.Webhook.SeenItems
        if not prev then
            Hub.Webhook.SeenItems = snap
        else
            local farmingOk = (not Hub.Webhook.OnlyWhileFarming) or Hub.Farm.AutoFarm
            for name, amt in pairs(snap) do
                local before = prev[name] or 0
                if amt > before then
                    local delta = amt - before
                    if Hub.Webhook.DropsEnabled and farmingOk then
                        local source = nil
                        if Hub.Webhook.LastBoss and Hub.Webhook.LastBossAt and (now - Hub.Webhook.LastBossAt) < 60 then
                            source = "Boss: " .. tostring(Hub.Webhook.LastBoss)
                        end
                        Hub.SendDropWebhook(name, delta, source)
                    end
                end
            end
            Hub.Webhook.SeenItems = snap
        end
    end

    if Hub.Webhook.ProgressEnabled then
        local interval = (Hub.Webhook.ProgressMinutes or 15) * 60
        if interval > 0 and (now - (Hub.Webhook.LastProgressAt or 0)) >= interval then
            Hub.SendProgressWebhook(false)
        end
    end

    if (Hub.Webhook.Label or Hub.Webhook.KillsLabel) and (now - (Hub.Webhook.LabelAt or 0)) >= 3 then
        Hub.Webhook.LabelAt = now
        local kills = Hub.Webhook.BossKillsTotal or 0
        local wen = GetWen()
        local earned = (Hub.Webhook.WenStart ~= nil) and math.max(0, wen - Hub.Webhook.WenStart) or 0
        local reqOk = WebhookRequestFn() ~= nil
        local urlOk = type(Hub.Webhook.Url) == "string" and #Hub.Webhook.Url > 10
        local statusText = string.format("Session: %s | Kills: %d | Wen: +%s | %s", FmtSession(now - Hub.Webhook.StartTime), kills, FmtNum(earned), (urlOk and (reqOk and "Ready" or "No HTTP fn")) or "No URL")
        local sorted = {}
        for name, count in pairs(Hub.Webhook.Defeated) do
            table.insert(sorted, { name = name, count = count })
        end
        table.sort(sorted, function(a, b) return a.count > b.count end)
        local top = {}
        for i = 1, math.min(#sorted, 5) do
            top[#top+1] = string.format("%s x%d", sorted[i].name, sorted[i].count)
        end
        local killsText = (#top > 0) and ("Top: " .. table.concat(top, ", ")) or "Top Defeated: none yet"
        Hub.GuiWrite(function()
            if Hub.Webhook.Label then Hub.Webhook.Label:SetText(statusText) end
            if Hub.Webhook.KillsLabel then Hub.Webhook.KillsLabel:SetText(killsText) end
        end)
    end
end))
end

-- 6. Auto Training Automation (Proximity Prompts & Instant Minigames)
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local myRoot = GetRootPart()
    if not myRoot then return end

    if Hub.Training.AutoBoulder then
        local bp = Workspace.Training:FindFirstChild("Boulder Push")
        if bp then
            for _, b in ipairs(bp:GetChildren()) do
                local prompt = b:FindFirstChildOfClass("ProximityPrompt")
                if prompt and (b.Position - myRoot.Position).Magnitude <= prompt.MaxActivationDistance + 4 then
                    fireproximityprompt(prompt)
                end
            end
        end
    end

    if Hub.Training.AutoSquats then
        local sq = Workspace.Training:FindFirstChild("Squat Rack")
        if sq then
            for _, item in ipairs(sq:GetChildren()) do
                local prompt = item:FindFirstChildOfClass("ProximityPrompt")
                if prompt and (item.Position - myRoot.Position).Magnitude <= prompt.MaxActivationDistance + 4 then
                    fireproximityprompt(prompt)
                end
            end
        end
    end

    -- Auto-Stay : garde le joueur posé sur la station d'entraînement choisie
    if Hub.Training.AutoStay and not Hub.IsInteractingQuest and not Hub.IsCollectingLoot then
        local now = os.clock()
        if (now - (Hub.Training._LastStay or 0)) >= 2.0 then
            Hub.Training._LastStay = now
            local stationPos = trainingStations and trainingStations[Hub.Training.StationName or "Meditation"]
            if stationPos and (myRoot.Position - stationPos).Magnitude > 6 then
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
                myRoot.CFrame = CFrame.new(stationPos + Vector3.new(0, 3, 0))
                EnsureFarmPlatform(myRoot.CFrame)
            end
        end
    end
end))

-- 7. Minigame Auto-Win Hook (Boulder, Squats, Pushups, Cup, Meditation)
local function CheckAndSolveMinigame(child)
    if not Hub.Training.AutoMinigames then return end
    if not child or not child:IsA("GuiObject") and not child:IsA("ScreenGui") then return end
    local cname = string.lower(child.Name)
    if string.find(cname, "slider") or string.find(cname, "cup") or string.find(cname, "training") or string.find(cname, "minigame") or string.find(cname, "bar") then
        task.wait(0.05)
        pcall(function()
            if SignalEvent then
                SignalEvent.ToServer("training_signaler", "Stop", true)
            end
        end)
    end
end

pcall(function()
    local miscGui = LocalPlayer.PlayerGui:WaitForChild("Misc", 5)
    if miscGui then
        table.insert(Hub.Connections, miscGui.ChildAdded:Connect(CheckAndSolveMinigame))
        for _, child in ipairs(miscGui:GetChildren()) do
            CheckAndSolveMinigame(child)
        end
    end
    table.insert(Hub.Connections, LocalPlayer.PlayerGui.ChildAdded:Connect(function(gui)
        if gui.Name == "Misc" then
            table.insert(Hub.Connections, gui.ChildAdded:Connect(CheckAndSolveMinigame))
        end
    end))
end)

-- Continuous Minigame check via valuesfolder
local lastMinigameSignal = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    if Hub.Training.AutoMinigames then
        local now = os.clock()
        if (now - lastMinigameSignal) >= 0.4 then
            local folder = GetMyValuesFolder()
            if folder then
                local standStill = folder:FindFirstChild("skill_stand_still")
                local pauseGame = folder:FindFirstChild("pause_gameplay")
                if (standStill and standStill.Value) or (pauseGame and pauseGame.Value) then
                    lastMinigameSignal = now
                    pcall(function()
                        if SignalEvent then
                            SignalEvent.ToServer("training_signaler", "Stop", true)
                        end
                    end)
                end
            end
        end
    end
end))

-- 8. Combat Buffs (Sun Damage Immunity, Continuous Fast Attack & Anti-Freeze Watchdog)
local lastSunImmunityCheck = 0
local lastFastM1 = 0
local lastFreezeCheck = 0
local frozenCounter = 0

Hub.Combat.GetColdCampfires = function()
    local positions = {}
    local map = Workspace:FindFirstChild("Map")
    local inner = map and map:FindFirstChild("Map")
    if inner then
        for _, d in ipairs(inner:GetChildren()) do
            if string.find(string.lower(d.Name), "iceveilcampfire", 1, true) then
                local ok, pos = pcall(function() return d:GetPivot().Position end)
                if ok and pos then table.insert(positions, pos) end
            end
        end
    end
    return positions
end

table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()

    -- Race / Level status (toujours actif, meme si Auto Quest est desactive)
    if Hub.Farm._QuestRaceLabel and (now - (Hub.Farm._QuestLabelAt or 0)) >= 3 then
        Hub.Farm._QuestLabelAt = now
        local detectedRace = GetPlayerRace()
        Hub.Farm._DetectedRace = detectedRace
        local raceText = string.format("Detected Race: %s | Level: %d | Quests filtered by the game rules", tostring(detectedRace), GetPlayerLevel())
        local lbl = Hub.Farm._QuestRaceLabel
        Hub.GuiWrite(function()
            lbl:SetText(raceText)
        end)
    end

    -- Sun Damage protection
    if Hub.Combat.NoSunDamage then
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local ucs = pg and pg:FindFirstChild("UCS")
            local gp = ucs and ucs:FindFirstChild("Game_Play")
            local sun = gp and gp:FindFirstChild("SunDamage")
            if sun and sun:IsA("LocalScript") and sun.Enabled then
                sun.Enabled = false
            end
        end)
        if LocalPlayer:GetAttribute("SecondarySituation") ~= "Sunless" then
            pcall(function() LocalPlayer:SetAttribute("SecondarySituation", "Sunless") end)
        end
        if (now - lastSunImmunityCheck) >= 0.5 then
            lastSunImmunityCheck = now
            pcall(function()
                if SignalFunction and SignalFunction.ToServer then
                    SignalFunction.ToServer("SunDamage", false)
                end
            end)
        end
    end

    -- Cold / Snow protection: pin the HP bar client-side, track the real (server) HP
    -- and warp to a campfire before the frost can actually kill us.
    if Hub.Combat.NoColdDamage then
        local myHum = GetHumanoid()
        if myHum and myHum.Health > 0 then
            pcall(Hub.Combat.PurgeFrostTicks)

            local myRoot = GetRootPart()
            local inSnow = myRoot and (LocalPlayer:GetAttribute("Biome") == "Snow")

            if inSnow then
                if Hub.Combat._ColdHum ~= myHum then
                    if Hub.Combat._ColdHumConn then
                        pcall(function() Hub.Combat._ColdHumConn:Disconnect() end)
                    end
                    Hub.Combat._ColdHum = myHum
                    Hub.Combat._ColdTrueHP = myHum.Health
                    Hub.Combat._ColdRescued = false
                    Hub.Combat._ColdHumConn = myHum.HealthChanged:Connect(function(h)
                        if not Hub.Combat.NoColdDamage then return end
                        if h >= myHum.MaxHealth - 0.5 then return end
                        local tracked = Hub.Combat._ColdTrueHP or h
                        if h < tracked then
                            Hub.Combat._ColdTrueHP = h
                        elseif h > tracked + 0.5 then
                            Hub.Combat._ColdTrueHP = h
                        end
                    end)
                end

                local trueHP = Hub.Combat._ColdTrueHP or myHum.Health
                if trueHP > myHum.MaxHealth * 0.85 then
                    Hub.Combat._ColdRescued = false
                end

                if myHum.Health < myHum.MaxHealth then
                    myHum.Health = myHum.MaxHealth
                end

                if not Hub.Combat._ColdRescued and trueHP <= (myHum.MaxHealth * 0.75) then
                    local lastRescue = Hub.Combat._ColdRescueAt or 0
                    if (now - lastRescue) >= 5 then
                        local dest, bestDist = nil, math.huge
                        for _, cpos in ipairs(Hub.Combat.GetColdCampfires()) do
                            local d = (cpos - myRoot.Position).Magnitude
                            if d < bestDist then bestDist = d; dest = cpos end
                        end
                        if dest and bestDist > 30 then
                            Hub.Combat._ColdRescueAt = now
                            Hub.Combat._ColdRescued = true
                            Hub.Combat._ColdTrueHP = myHum.MaxHealth
                            TeleportToPosition(dest, "Campfire (Cold Rescue)")
                        elseif Hub.Combat._ColdSafePos and (Hub.Combat._ColdSafePos - myRoot.Position).Magnitude > 60 then
                            Hub.Combat._ColdRescueAt = now
                            Hub.Combat._ColdRescued = true
                            Hub.Combat._ColdTrueHP = myHum.MaxHealth
                            TeleportToPosition(Hub.Combat._ColdSafePos, "Safe Zone (Cold Rescue)")
                        end
                    end
                end
            else
                if Hub.Combat._ColdHumConn then
                    pcall(function() Hub.Combat._ColdHumConn:Disconnect() end)
                    Hub.Combat._ColdHumConn = nil
                    Hub.Combat._ColdHum = nil
                end
                Hub.Combat._ColdTrueHP = nil
                if myRoot then
                    Hub.Combat._ColdSafePos = myRoot.Position
                end
            end
        end
    end

    -- Fast M1 Attack
    if Hub.Combat.FastAttack and (now - lastFastM1) >= 0.16 then
        local myRoot = GetRootPart()
        if myRoot and not Hub.Farm.AutoFarm then
            lastFastM1 = now
            PerformAttack()
        end
    end

    -- Anti-Freeze & Animation Limit Watchdog (Vérification et déblocage automatique)
    if Hub.Combat.AntiFreeze and (now - lastFreezeCheck) >= 1.0 then
        lastFreezeCheck = now
        local myHum = GetHumanoid()
        if myHum and myHum.Health > 0 then
            local isStuckSpeed = (myHum.WalkSpeed < 8 and myHum.JumpPower == 0)
            local isRagdoll = false
            local u2 = nil
            pcall(function()
                u2 = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(LocalPlayer.Name)
            end)
            if u2 and (u2:FindFirstChild("Stun") or u2:FindFirstChild("RagDoll") or u2:FindFirstChild("CombatStun")) then
                isRagdoll = true
            end

            if isStuckSpeed or isRagdoll then
                frozenCounter = frozenCounter + 1
                if frozenCounter >= 2 then
                    ForceUnfreezeCharacter()
                    frozenCounter = 0
                end
            else
                frozenCounter = 0
            end

            -- Nettoyage préventif des tracks orphelines (Plafond Roblox 64 tracks)
            if Hub.Combat.TrackGuard then
                local animator = myHum:FindFirstChildOfClass("Animator")
                if animator then
                    local tracks = animator:GetPlayingAnimationTracks()
                    if #tracks > 8 then
                        for _, tr in ipairs(tracks) do
                            local n = tr.Name
                            if string.find(n, "Swing") or string.find(n, "React") or string.find(n, "Dash") or string.find(n, "Combat") or tr.TimePosition >= (tr.Length - 0.05) or tr.Speed == 0 then
                                pcall(function()
                                    tr:Stop(0)
                                    tr:Destroy()
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end))

-- 7. Visuals (Highlights ESP)
local function UpdateESP()
    for inst, hl in pairs(Hub.ESPHighlights) do
        if not inst or not inst.Parent then
            pcall(function() hl:Destroy() end)
            Hub.ESPHighlights[inst] = nil
        end
    end

    -- Mob ESP
    if Hub.Visuals.MobESP then
        local mobs = GetAliveMobs()
        for _, mob in ipairs(mobs) do
            local model = mob.Model
            if not Hub.ESPHighlights[model] and Hub.Visuals.ESPBoxes then
                local hl = Instance.new("Highlight")
                hl.Name = "KyokaMobESP"
                hl.Adornee = model
                hl.FillColor = Hub.Visuals.MobColor
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.FillTransparency = 0.55
                hl.OutlineTransparency = 0.2
                hl.Parent = model
                Hub.ESPHighlights[model] = hl
            elseif Hub.ESPHighlights[model] then
                Hub.ESPHighlights[model].Enabled = Hub.Visuals.ESPBoxes
                Hub.ESPHighlights[model].FillColor = Hub.Visuals.MobColor
            end
        end
    else
        for inst, hl in pairs(Hub.ESPHighlights) do
            if hl.Name == "KyokaMobESP" then hl.Enabled = false end
        end
    end

    -- Player ESP
    if Hub.Visuals.PlayerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                if not Hub.ESPHighlights[char] and Hub.Visuals.ESPBoxes then
                    local hl = Instance.new("Highlight")
                    hl.Name = "KyokaPlayerESP"
                    hl.Adornee = char
                    hl.FillColor = Hub.Visuals.PlayerColor
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0.2
                    hl.Parent = char
                    Hub.ESPHighlights[char] = hl
                elseif Hub.ESPHighlights[char] then
                    Hub.ESPHighlights[char].Enabled = Hub.Visuals.ESPBoxes
                    Hub.ESPHighlights[char].FillColor = Hub.Visuals.PlayerColor
                end
            end
        end
    else
        for inst, hl in pairs(Hub.ESPHighlights) do
            if hl.Name == "KyokaPlayerESP" then hl.Enabled = false end
        end
    end
end

table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    UpdateESP()
end))

--=====================================================================
-- World ESP : leviers Nightfall, clés serpent, StudyProps, coffres...
--=====================================================================
local WorldESPTags = {
    Levers = { Tags = { "SicklesLever" }, Color = Color3.fromRGB(255, 205, 70), Label = "Lever" },
    SerpentKey = { Tags = { "SerpentKey" }, Color = Color3.fromRGB(90, 255, 130), Label = "Serpent Key" },
    SerpentBox = { Tags = { "SerpentBox" }, Color = Color3.fromRGB(90, 255, 130), Label = "Serpent Box" },
    StudyProps = { Tags = { "StudyProp" }, Color = Color3.fromRGB(185, 130, 255), Label = "Nightfall" },
    Chests = { Tags = { "Chest", "ChestMound" }, Color = Color3.fromRGB(255, 220, 90), Label = "Chest" },
    Shrines = { Tags = { "ShrineProximityPrompt" }, Color = Color3.fromRGB(130, 220, 255), Label = "Shrine" },
    SpawnCrystals = { Tags = { "SpawnCrystalProximityPrompt" }, Color = Color3.fromRGB(130, 220, 255), Label = "Spawn" },
    SimonPlates = { Tags = { "SimonPlate" }, Color = Color3.fromRGB(255, 160, 70), Label = "Plate" },
}

local WorldESPObjects = {}   -- [instance] = { Highlight = ..., Billboard = ..., Marker = ... }
local WorldESPActiveKeys = {}

-- Modèle de marqueur : certaines cibles (leviers Nightfall) n'ont aucune Part
-- tant que le serveur n'a pas fait spawn les éléments interactifs. On pose
-- alors un petit cube néon à leur position pour pouvoir les repérer.
local ESPMarkerTemplate = nil
pcall(function()
    local p = Instance.new("Part")
    p.Name = "KyokaESPMarker"
    p.Size = Vector3.new(2, 2, 2)
    p.Material = Enum.Material.Neon
    p.Transparency = 0.65
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Parent = nil
    ESPMarkerTemplate = p
end)

local function CreateESPMarker(pos, color)
    local marker = nil
    if ESPMarkerTemplate then
        pcall(function() marker = ESPMarkerTemplate:Clone() end)
    end
    if not marker then return nil end
    marker.Name = "KyokaESPMarker"
    marker.Color = color or Color3.fromRGB(255, 255, 255)
    marker.Position = pos
    marker.Parent = Workspace
    return marker
end

local function ClearWorldESPFor(inst)
    local entry = WorldESPObjects[inst]
    if entry then
        pcall(function() if entry.Highlight then entry.Highlight:Destroy() end end)
        pcall(function() if entry.Billboard then entry.Billboard:Destroy() end end)
        pcall(function() if entry.Marker then entry.Marker:Destroy() end end)
        WorldESPObjects[inst] = nil
    end
end

local function FindESPTarget(inst)
    if not inst or not inst.Parent then return nil end
    if inst:IsA("BasePart") then return inst end
    local part = inst:FindFirstChildWhichIsA("BasePart", true)
    return part
end

local function AttachWorldESP(inst, cfg, myRoot)
    if not inst or not inst.Parent then return end
    local part = FindESPTarget(inst)
    local pivot = nil
    if not part then
        local okP, p = pcall(function() return inst:GetPivot().Position end)
        if okP and p and p.Magnitude > 1 then pivot = p end
        if not pivot then return end
    end

    local entry = WorldESPObjects[inst]
    if not entry then
        entry = {}
        WorldESPObjects[inst] = entry

        if not part then
            entry.Marker = CreateESPMarker(pivot, cfg.Color)
            part = entry.Marker
        end
        if not part then return end

        local okH, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "KyokaWorldESP"
            h.FillColor = cfg.Color
            h.OutlineColor = Color3.new(1, 1, 1)
            h.FillTransparency = 0.55
            h.OutlineTransparency = 0.15
            h.Adornee = inst
            h.Parent = part
            return h
        end)
        if okH then entry.Highlight = hl end
        local okB, bb = pcall(function()
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "KyokaWorldESPLabel"
            billboard.Size = UDim2.fromOffset(190, 22)
            billboard.StudsOffset = Vector3.new(0, 3.2, 0)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = 4000
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.BackgroundTransparency = 1
            label.Size = UDim2.fromScale(1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = cfg.Color
            label.TextStrokeTransparency = 0.3
            label.Text = cfg.Label
            label.Parent = billboard
            billboard.Parent = part
            return billboard
        end)
        if okB then entry.Billboard = bb end
    else
        -- Suit la cible si elle bouge / si les vraies parts apparaissent
        if entry.Marker and entry.Marker.Parent then
            local okP, p = pcall(function() return inst:GetPivot().Position end)
            if okP and p and (entry.Marker.Position - p).Magnitude > 1 then
                entry.Marker.Position = p
            end
            if part and entry.Marker.Transparency > 0.66 then
                entry.Marker.Transparency = 0.65
            end
        end
    end

    if entry.Billboard and entry.Billboard.Parent then
        local label = entry.Billboard:FindFirstChild("Label")
        if label then
            local refPos = part and part.Position or pivot
            if Hub.Visuals.WorldESP.ShowDistance and myRoot and refPos then
                local d = math.floor((refPos - myRoot.Position).Magnitude)
                label.Text = string.format("%s [%dm]", cfg.Label, d)
            else
                label.Text = cfg.Label
            end
        end
    end
end

local lastWorldESPUpdate = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastWorldESPUpdate < 0.35 then return end
    lastWorldESPUpdate = now

    local cfg = Hub.Visuals.WorldESP
    local myRoot = GetRootPart()
    local active = {}

    -- Catégories par tag
    for key, def in pairs(WorldESPTags) do
        if cfg[key] then
            local cs = game:GetService("CollectionService")
            for _, tag in ipairs(def.Tags) do
                for _, inst in ipairs(cs:GetTagged(tag)) do
                    active[inst] = def
                end
            end
        end
    end

    -- Spider Lilies (par nom, dans Debree)
    if cfg.SpiderLily then
        local def = { Color = Color3.fromRGB(255, 90, 205), Label = "Spider Lily" }
        local debree = Workspace:FindFirstChild("Debree")
        if debree then
            for _, inst in ipairs(debree:GetChildren()) do
                if inst.Name == "Spider Lily" then
                    active[inst] = def
                end
            end
        end
    end

    -- Attache / met à jour
    for inst, def in pairs(active) do
        AttachWorldESP(inst, def, myRoot)
    end
    -- Nettoie ce qui n'est plus actif
    for inst in pairs(WorldESPObjects) do
        if not active[inst] or not inst.Parent then
            ClearWorldESPFor(inst)
        end
    end
    WorldESPActiveKeys = active
end))

--=====================================================================
-- Nightfall : Auto-Pull des leviers + compteur
--=====================================================================
local lastLeverPull = 0
local lastLeverStatus = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastLeverStatus >= 1.0 then
        lastLeverStatus = now
        local cs = game:GetService("CollectionService")
        local levers = cs:GetTagged("SicklesLever")
        local on = 0
        for _, lever in ipairs(levers) do
            local a = lever:FindFirstChild("A_")
            if a and a:GetAttribute("On") == true then
                on = on + 1
            end
        end
        if LeverStatusLabel then
            LeverStatusLabel:SetText(string.format("Levers pulled: %d/%d", on, #levers))
        end
        if #levers > 0 and on >= #levers and not Hub.Puzzles.NotifiedSolved then
            Hub.Puzzles.NotifiedSolved = true
            Kyoka:Notify({ Title = "Nightfall", Content = "All Sickles levers pulled! Sewer opened.", Type = "success", Duration = 8 })
        end
    end

    if not Hub.Puzzles.AutoPullLevers then return end
    if now - lastLeverPull < 0.45 then return end
    lastLeverPull = now

    local cs = game:GetService("CollectionService")
    local myRoot = GetRootPart()
    if not myRoot then return end

    for _, lever in ipairs(cs:GetTagged("SicklesLever")) do
        local a = lever:FindFirstChild("A_")
        if a and a:GetAttribute("On") ~= true then
            local main = a:FindFirstChild("LeverMain")
            local prompt = main and main:FindFirstChild("ProximityPrompt")
            if not prompt then
                prompt = a:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
            local pos = main and main:IsA("BasePart") and main.Position or a:GetPivot().Position
            if prompt and prompt.Enabled then
                local dist = (pos - myRoot.Position).Magnitude
                if dist > 12 and Hub.Puzzles.AutoTravelLevers then
                    -- se téléporter au levier (le prompt a besoin de proximité)
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                    myRoot.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    task.wait(0.25)
                end
                pcall(function() prompt:InputHoldBegin() end)
                task.wait(math.max(prompt.HoldDuration or 0, 0.05) + 0.08)
                pcall(function() prompt:InputHoldEnd() end)
                pcall(fireproximityprompt, prompt)
                return
            end
        end
    end
end))

--=====================================================================
-- Auto Refine (Refiner Hagane)
--=====================================================================
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local R = Hub.Refine
    if not R.Auto then return end
    if now - (R.LastAttempt or 0) < 1.4 then return end
    R.LastAttempt = now

    local name = R.ItemName
    if not name then
        local items = Util.GetRefinableItems()
        if #items > 0 then
            name = items[1].Name
            R.ItemName = name
        end
    end
    if not name then
        R.Auto = false
        Kyoka:Notify({ Title = "Auto Refine", Content = "No refinable item found. Stopped.", Type = "warning" })
        return
    end

    Util.TravelToHagane()
    local res, err = Util.DoRefineAttempt(name, R.UseGuard)
    R.Attempts = (R.Attempts or 0) + 1
    if res == nil then
        if RefineStatusLabel then RefineStatusLabel:SetText("Error: " .. tostring(err)) end
        R.Auto = false
        Kyoka:Notify({ Title = "Auto Refine", Content = "Stopped: " .. tostring(err), Type = "error", Duration = 6 })
        return
    end
    if type(res) == "table" then
        local outcome = tostring(res.Outcome)
        if outcome == "Great" or outcome == "Great Success" then
            R.Greats = (R.Greats or 0) + 1
        elseif outcome == "Fail" then
            R.Fails = (R.Fails or 0) + 1
        end
        if RefineStatusLabel then
            RefineStatusLabel:SetText(string.format("%s | Att: %d Great: %d Fail: %d", outcome, R.Attempts, R.Greats or 0, R.Fails or 0))
        end
        if res.Reason and (outcome == "Fail" or res.Ok ~= true) then
            -- Ressources insuffisantes / item max : on arrête
            if string.find(string.lower(tostring(res.Reason)), "ore") or string.find(string.lower(tostring(res.Reason)), "wen")
                or string.find(string.lower(tostring(res.Reason)), "max") or string.find(string.lower(tostring(res.Reason)), "not enough") then
                R.Auto = false
                Kyoka:Notify({ Title = "Auto Refine", Content = "Stopped: " .. tostring(res.Reason), Type = "warning", Duration = 6 })
            end
        end
    end
end))

--=====================================================================
-- Auto Sell (Ginzo) + Auto Fish
--=====================================================================
local lastAutoSell = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if not Hub.Sell.Auto then return end
    if now - lastAutoSell < 90 then return end
    lastAutoSell = now
    if Hub.IsInteractingQuest or Hub.IsCollectingLoot then return end
    task.spawn(function()
        local ok = Util.DoSellNow(Hub.Sell.Mode, true)
        if SellStatusLabel then
            SellStatusLabel:SetText(string.format("Earned: %d Wen | %s", Hub.Sell.TotalEarned or 0, ok and "Sold!" or "Idle"))
        end
    end)
end))

local lastFishStatus = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    local F = Hub.Fish

    if now - lastFishStatus >= 1.0 then
        lastFishStatus = now
        if FishStatusLabel then
            local fishText = string.format("Status: %s | Caught: %d | Failed: %d | Bites: %d%s", tostring(F.State), F.Caught or 0, F.Failed or 0, F.Bites or 0, F.HookActive and " | Hook OK" or "")
            Hub.GuiWrite(function() FishStatusLabel:SetText(fishText) end)
        end
    end

    -- Tracker de prises (au cas où Debree n'existait pas au chargement)
    if F.Auto and not F._catchTracker then
        pcall(function() Util.RefreshCatchTracker() end)
    end

    -- Auto-achat de la canne dès que le permis est obtenu
    if F.AutoBuyRod and now - (F.LastRodCheck or 0) >= 60 then
        F.LastRodCheck = now
        if not Util.FindRodItem() and Util.HasFishingPermit() then
            task.spawn(function()
                local ok = Util.BuyFishingRod("Basic Fishing Rod")
                if ok then
                    Kyoka:Notify({ Title = "Auto Fish", Content = "Basic Fishing Rod auto-bought!", Type = "success" })
                end
            end)
        end
    end

    if not F.Auto then return end
    if Hub.IsInteractingQuest then return end
    local myRoot = GetRootPart()
    local hum = GetHumanoid()
    if not myRoot or not hum or hum.Health <= 0 then return end

    -- Watchdog : si la canne ne répond plus (état serveur coincé après un cast
    -- raté), on force un ré-équipement pour recréer son état.
    if (F.Failed or 0) >= 2 and (F.LastRodReset == nil or now - F.LastRodReset > 20) then
        F.LastRodReset = now
        F.Failed = 0
        task.spawn(function()
            local ok = pcall(function()
                if SignalEvent then
                    SignalEvent.ToServer("Item_Equip", 0)
                    task.wait(1.0)
                    SignalEvent.ToServer("Item_Equip", F.RodSlot or 2)
                end
            end)
            if ok then
                Kyoka:Notify({ Title = "Auto Fish", Content = "Rod re-equipped (stuck state reset).", Type = "info", Duration = 4 })
            end
        end)
    end

    local state = F.State or "idle"
    if state == "idle" then
        if now - (F.LastAction or 0) < 1.0 then return end
        F.LastAction = now
        local slot, rodName = Util.EnsureRodEquipped()
        if not slot then
            F.Auto = false
            Kyoka:Notify({ Title = "Auto Fish", Content = "No Fishing Rod found - stopping. (Permit quest Lv 45 required to buy one.)", Type = "error", Duration = 8 })
            return
        end
        F.RodName = rodName
        F.RodSlot = slot

        -- Point d'eau castable autour du joueur (test geometrique : les
        -- volumes SwimParts ont CanQuery = false, aucun raycast ne les touche)
        local castPoint = Util.FindCastableWaterPoint(myRoot.Position, myRoot)
        if not castPoint then
            -- Pas d'eau streamée à proximité : voyager vers un spot connu
            -- pour forcer le streaming, au lieu de tout couper.
            local best, bestD = nil, math.huge
            for _, s in ipairs(Util.FishingSpots) do
                local d = (s - myRoot.Position).Magnitude
                if d < bestD then bestD = d best = s end
            end
            if best and bestD > 40 then
                TeleportToPosition(best, "Fishing Spot")
                F.LastAction = now
                return
            end
            F.Failed = (F.Failed or 0) + 1
            F.State = "idle"
            F.LastAction = now
            return
        end

        -- Le serveur refuse le cast si on nage ou si on n'est pas au sol : on
        -- rejoint une berge AU-DESSUS de l'eau avant de lancer la ligne.
        local canCast, newPoint = Util.EnsureCastingSpot(castPoint, myRoot)
        if newPoint then castPoint = newPoint end
        if not canCast then
            F.LastAction = now + 2.0
            return
        end

        F.WaterPoint = castPoint
        F.BobberSeen = nil
        F.AnchorPos = myRoot.Position
        Util.CastRod(castPoint)
        F.State = "cast"
        F.CastTime = now
    elseif state == "cast" then
        if now - (F.CastTime or 0) > 1.6 then
            F.State = "wait_bite"
            F.BiteWaitStart = now
        end
    elseif state == "wait_bite" then
        if (now - (F._catchScanAt or 0)) >= 0.4 then
            F._catchScanAt = now
            F._catchCache = Util.FindFishingCatches()
            if not F.BobberSeen and Util.HasFishingBobber() then
                F.BobberSeen = true
            end
        end
        local catches = F._catchCache or {}
        if #catches > 0 then
            F.State = "collect"
            F.LastAction = now
            F._collecting = false
        elseif (not F.BobberSeen) and now - (F.CastTime or 0) > 4 then
            -- Cast refusé (pas au sol / en nage) : aucun bobber n'est apparu.
            -- Relance rapide au lieu d'attendre le long timeout.
            F.Failed = (F.Failed or 0) + 1
            F.State = "idle"
            F.LastAction = now + 1.5
        elseif (F.LastBiteAt or 0) > (F.CastTime or 0) then
            -- Morsure reçue : le verdict part avec un délai humain, le serveur
            -- roule ensuite et enchaîne lui-même son uncast. On attend le tout
            -- avant de conclure à un raté, sinon on recasterait en tuant la
            -- morsure en cours (le MouseUp dé-castrait pendant l'attente).
            local missAfter = 4 + (tonumber(F.ReportDelayMax) or tonumber(F.ReportDelay) or 8)
            if now - F.LastBiteAt > missAfter then
                F.State = "idle"
                F.LastAction = now
            end
        elseif now - (F.CastTime or 0) > (F.BiteTimeout or 45) then
            -- Aucune morsure : cast mort ou canne coincée (BiteToken en attente
            -- côté serveur => tout MouseUp est ignoré). Ré-équipement complet.
            F.Failed = (F.Failed or 0) + 1
            F.State = "idle"
            F.LastAction = now + 2.0
            if F.LastRodReset == nil or now - F.LastRodReset > 25 then
                F.LastRodReset = now
                task.spawn(function()
                    pcall(function() Util.RefreshFishingBiteHook() end)
                end)
            end
        end
    elseif state == "collect" then
        if (now - (F._catchScanAt or 0)) >= 0.4 then
            F._catchScanAt = now
            F._catchCache = Util.FindFishingCatches()
        end
        local catches = F._catchCache or {}
        if #catches == 0 then
            F.State = "idle"
            F.LastAction = now
            F._collecting = false
        elseif F._collecting then
            -- collecte deja en cours sur un autre tick
        else
            F._collecting = true
            local function invMap()
                local m = {}
                for _, item in ipairs(Util.GetInventoryList()) do
                    m[item.Name] = (m[item.Name] or 0) + (tonumber(item.Amount) or 0)
                end
                return m
            end
            -- Prise la plus proche PROVENANT DE NOTRE lancer (on ignore celles
            -- des autres pêcheurs pour ne pas traverser la carte). Le serveur
            -- la tire vers notre canne (pullCatch) : elle arrive à nos pieds.
            local function nearestCatch()
                local rr = GetRootPart()
                local best, bestD = nil, math.huge
                for _, cc in ipairs(Util.FindFishingCatches()) do
                    if cc.Pos and (F.WaterPoint == nil or (cc.Pos - F.WaterPoint).Magnitude <= 80) then
                        local dd = rr and (cc.Pos - rr.Position).Magnitude or math.huge
                        if dd < bestD then bestD = dd best = cc end
                    end
                end
                return best, bestD, rr
            end
            local beforeInv = invMap()
            local target, targetD, r0 = nearestCatch()
            -- Laisser le temps à la livraison d'arriver : se téléporter tout
            -- de suite sur la prise, c'est la rater en chemin. Le prompt du
            -- serveur ne porte qu'à ~10 studs : on collecte sur place sous 8.
            if target and targetD > 8 then
                task.wait(1.5)
                target, targetD, r0 = nearestCatch()
            end
            -- Repli : si elle est coincée loin, aller la chercher une fois.
            if target and r0 and target.Pos and targetD > 8 then
                local cf = CFrame.new(target.Pos + Vector3.new(0, 2.2, 0))
                r0.CFrame = cf
                r0.AssemblyLinearVelocity = Vector3.zero
                r0.AssemblyAngularVelocity = Vector3.zero
                EnsureFarmPlatform(cf)
                task.wait(0.4)
                target, targetD, r0 = nearestCatch()
            end
            if target then
                if target.Prompt then
                    local p = target.Prompt
                    local holdSecs = 2
                    pcall(function()
                        p.Enabled = true
                        p.MaxActivationDistance = 60
                        holdSecs = tonumber(p.HoldDuration) or 2
                    end)
                    pcall(fireproximityprompt, target.Prompt)
                    task.wait(0.3)
                    if target.Model and target.Model.Parent then
                        -- Le fast-path n'a pas suffi (le serveur valide le maintien
                        -- via PromptHeld) : maintien réel de la touche, comme un joueur.
                        local promptKey = (p.KeyboardKeyCode ~= Enum.KeyCode.Unknown and p.KeyboardKeyCode) or Enum.KeyCode.E
                        if VirtualInputManager then
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                                task.wait(holdSecs + 0.6)
                                VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                            end)
                        end
                    end
                    task.wait(0.15)
                end
            end
            task.wait(0.6)
            F._catchCache = Util.FindFishingCatches()
            local gained = false
            local afterInv = invMap()
            for name, amt in pairs(afterInv) do
                if amt > (beforeInv[name] or 0) then gained = true break end
            end
            if not gained then
                -- La réplication de l'inventaire peut accuser un retard : seconde chance.
                task.wait(0.8)
                afterInv = invMap()
                for name, amt in pairs(afterInv) do
                    if amt > (beforeInv[name] or 0) then gained = true break end
                end
            end
            if gained then
                F.Caught = (F.Caught or 0) + 1
            else
                F.Failed = (F.Failed or 0) + 1
            end
            -- Retour au point de pêche exact après la collecte du loot.
            local back = GetRootPart()
            if F.AnchorPos and back and (back.Position - F.AnchorPos).Magnitude > 6 then
                pcall(function() TeleportToPosition(F.AnchorPos) end)
                task.wait(0.5)
            end
            F._collecting = false
            F.State = "recast"
            F.LastAction = now
        end
    elseif state == "recast" then
        -- Après une prise ou une morsure ratée, le serveur a déjà dé-casté tout
        -- seul : un MouseUp supplémentaire pourrait déclencher un cast fantôme.
        -- On laisse donc simplement retomber l'état vers idle.
        if now - (F.LastAction or 0) > 1.2 then
            F.State = "idle"
            F.LastAction = now
        end
    end

    -- Vente auto des poissons toutes les 2 min
    if F.Auto and F.AutoSellFish and (F.Caught or 0) > 0 and (F.LastAutoSell == nil or now - F.LastAutoSell > 120) then
        F.LastAutoSell = now
        task.spawn(function()
            Util.DoSellNow("Fish Only", true)
        end)
    end
end))

-- Nettoyage global
function Hub:Destroy()
    Hub.Alive = false
    pcall(function() StopAutoSpin(false) end)

    for _, conn in ipairs(Hub.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Hub.Connections)

    for _, hl in pairs(Hub.ESPHighlights) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(Hub.ESPHighlights)

    for inst in pairs(WorldESPObjects) do
        ClearWorldESPFor(inst)
    end

    RemoveFarmPlatform()

    pcall(function()
        if Kyoka and Kyoka.Unload then Kyoka:Unload() end
    end)

    _G.SlayersKyokaHub = nil
end

Kyoka:Notify({
    Title = "Kyōka Hub",
    Content = "Slayers 2 Hub Loaded (Anti-Void + Auto Farm Active)!",
    Type = "success",
    Duration = 4
})

-- Auto-Load de la config sauvegardee (Settings > Hub Config > Auto-Load).
-- Applique le fichier vesper/autoload.txt une fois que toute l'UI existe.
task.spawn(function()
    task.wait(1.5)
    if not Hub.Alive then return end
    local hasFS = type(writefile) == "function" and type(readfile) == "function" and type(isfolder) == "function"
    if not hasFS then return end
    local name = nil
    pcall(function()
        if isfile("vesper/autoload.txt") then
            local raw = readfile("vesper/autoload.txt")
            if type(raw) == "string" then
                name = raw:match("^%s*(.-)%s*$")
                if name == "" then name = nil end
            end
        end
    end)
    if not name then return end
    local loaded = Kyoka:LoadConfigFromFile(name)
    if loaded then
        Hub.Config.Name = name
        Hub.Config.AutoLoad = true
        pcall(function()
            local nameObj = Kyoka.Options and Kyoka.Options.HubConfigName
            if nameObj and nameObj.Set then nameObj:Set(name, true) end
            local autoObj = Kyoka.Options and Kyoka.Options.HubAutoLoadToggle
            if autoObj and autoObj.Set then autoObj:Set(true, true) end
        end)
        Kyoka:Notify({ Title = "Config", Content = "Auto-loaded config: " .. name, Type = "success", Duration = 4 })
    end
end)

--[[NW TELEMETRY (slayers2/vip) : reporte chargement + heartbeat vers /api/report
(anti-tamper : hash du module calculé par le loader + HWID + build). Best effort
silencieux : ne casse jamais le hub. Instalé par outil, ne pas éditer à la main.]]
do
if getgenv and getgenv().__NW_TM_slayers2 then return end
if getgenv then getgenv().__NW_TM_slayers2 = true end
local NW_GAME, NW_TIER = "slayers2", "vip"
local NW_API = "https://nwhub-platform.vercel.app"
local function nwHwid()
    if type(gethwid) == "function" then
        local ok, v = pcall(gethwid)
        if ok and type(v) == "string" and #v >= 3 then return v end
    end
    if type(get_hwid) == "function" then
        local ok, v = pcall(get_hwid)
        if ok and type(v) == "string" and #v >= 3 then return v end
    end
    local ok, v = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if ok and type(v) == "string" and #v >= 3 then return v end
    return "UNKNOWN_HWID"
end
local function nwKey()
    local k = ""
    pcall(function()
        if type(getgenv) == "function" then
            local g = getgenv()
            if g then
                if type(g.SCRIPT_KEY) == "string" and #g.SCRIPT_KEY >= 4 then k = g.SCRIPT_KEY end
                if k == "" and type(g.__NWKey) == "string" and #g.__NWKey >= 4 then k = g.__NWKey end
            end
        end
        if k == "" and type(_G.SCRIPT_KEY) == "string" and #_G.SCRIPT_KEY >= 4 then k = _G.SCRIPT_KEY end
        if k == "" and type(readfile) == "function" and type(isfile) == "function" and isfile("nwhub_saved_key.txt") then
            local s = readfile("nwhub_saved_key.txt")
            if type(s) == "string" and #s >= 4 then k = s:match("^%s*(.-)%s*$") end
        end
    end)
    return k or ""
end
local function nwSend(evt)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        local hs = game:GetService("HttpService")
        local g = (type(getgenv) == "function" and getgenv()) or {}
        local q = "key=" .. hs:UrlEncode(nwKey())
            .. "&hwid=" .. hs:UrlEncode(nwHwid())
            .. "&user=" .. hs:UrlEncode(lp and lp.Name or "")
            .. "&uid=" .. tostring(lp and lp.UserId or 0)
            .. "&place=" .. tostring(game.PlaceId or 0)
            .. "&game=" .. hs:UrlEncode(NW_GAME)
            .. "&build=" .. hs:UrlEncode("telemetry-1")
            .. "&tier=" .. hs:UrlEncode(NW_TIER)
            .. "&modhash=" .. hs:UrlEncode(g.__NW_MODHASH or "local")
            .. "&flags=&event=" .. hs:UrlEncode(evt)
        local req = (type(request) == "function" and request)
            or (type(http_request) == "function" and http_request)
            or (syn and type(syn.request) == "function" and syn.request)
        local body = nil
        if req then
            local okR, r = pcall(req, { Url = NW_API .. "/api/report", Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = hs:JSONEncode({ key = nwKey(), hwid = nwHwid(),
                    user = lp and lp.Name or "", uid = lp and lp.UserId or 0,
                    place = game.PlaceId or 0, game = NW_GAME, build = "telemetry-1",
                    tier = NW_TIER, modhash = g.__NW_MODHASH or "local", flags = "", event = evt }) })
            if okR and type(r) == "table" then body = r.Body or r.body end
        else
            local okR, res = pcall(game.HttpGet, game, NW_API .. "/api/report?" .. q)
            if okR then body = res end
        end
        if type(body) == "string" and body:find('"banned"%s*:%s*true') then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "NW Hub [Blacklisted]", Text = "This key/device is blacklisted.", Duration = 10 })
            end)
        end
    end)
end
task.spawn(function()
    nwSend("load")
    while true do
        task.wait(180)
        nwSend("beat")
    end
end)
end
