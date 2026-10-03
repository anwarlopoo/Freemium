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
_G.SlayersDungeonHubs = _G.SlayersDungeonHubs or {}
for _, old in ipairs(_G.SlayersDungeonHubs) do
    if old and old.Destroy then pcall(function() old:Destroy() end) end
end
table.clear(_G.SlayersDungeonHubs)

if _G.SlayersDungeonKyokaHub and _G.SlayersDungeonKyokaHub.Destroy then
    pcall(function() _G.SlayersDungeonKyokaHub:Destroy() end)
end

-- Plateformes orphelines d'anciennes exécutions
for _, obj in ipairs(Workspace:GetChildren()) do
    if obj.Name == "KyokaDungeonPlatform" then pcall(function() obj:Destroy() end) end
end

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
		opts = opts or {}
		local userCallback = opts.Callback
		local kb = MiniKeybind(holder, flag, opts)
		-- Un raccourci posé sur un toggle doit piloter CE toggle (pas un état à part)
		if obj.Set and obj.Get then
			kb.Active = obj:Get() == true
			kb.Callback = function()
				obj:Set(not (obj:Get() == true))
				kb.Active = obj:Get() == true
				if userCallback then task.spawn(userCallback, obj:Get()) end
			end
			-- Garde l'état du raccourci synchronisé quand on clique l'interrupteur
			local baseSet = obj.Set
			obj.Set = function(self, value, silent)
				baseSet(self, value, silent)
				kb.Active = self:Get() == true
			end
		end
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
		-- Ne jamais voler une touche utilisée par le jeu (skills F/Z/X/C/V/B, etc.)
		if _G.KyokaKeyInUse and _G.KyokaKeyInUse(input.KeyCode) then return end

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
-- Système & Utilitaires Dédiés Slayers 2 Donjon (Ouwigahara / Minigames)
--=====================================================================
local Hub
local SignalFunction
pcall(function()
    SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
end)

local SignalEvent
pcall(function()
    SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
end)

local InputHandler
pcall(function()
    InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
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

-- Anti-conflit : les raccourcis du hub ne doivent jamais voler une touche de skill du jeu
_G.KyokaKeyInUse = function(keyCode)
    if not keyCode or keyCode == Enum.KeyCode.Unknown then return false end
    local used = false
    pcall(function()
        local sp = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
        local keys = sp.get_current_keys()
        if keys then
            for _, k in ipairs(keys) do
                if k.Key and k.Key == keyCode.Name then
                    used = true
                    break
                end
            end
        end
    end)
    return used
end

--=====================================================================
-- Configuration & État du Hub Donjon
--=====================================================================
Hub = {
    Alive = true,
    Connections = {},
    ESPHighlights = {},
    FarmPlatform = nil,
    CurrentTarget = nil,
    LockedTarget = nil,
    IsCollectingLoot = false,
    IsSpendingChestPoints = false,
    IsReadyingUp = false,
    LastCardPick = 0,
    LastChestShopCheck = 0,
    LastReadyUpCheck = 0,
    SafeHoverCFrame = nil,

    Farm = {
        AutoFarm = true,
        InstantKill = true, -- Blitz : chaîne M1 continue (combos validés serveur)
        TargetLock = true,
        TargetPriority = "Closest", -- "Closest", "Lowest HP", "Bosses First"
        SafeMode = "Sky", -- "Sky" (toujours en l'air), "Overhead" or "In Front"
        AirHeight = 6, -- Hauteur de vol au-dessus des mobs (mode Sky) - la hitbox serveur fait ~9 studs de profondeur vers le bas: au-dessus de 7 les coups ne touchent plus
        HeightOffset = 2.4, -- Portée idéale M1 (évite d'être trop haut)
        Distance = 2.4,
        AutoM1 = true,
        MultiHit = true,
        MultiHitCount = 4,
        AutoSkills = true,
        SkillInterval = 0.5,
        AutoCollectChests = true,
        AutoCollectLoot = true,
        HoverBetweenWaves = true,
        AutoEquipWeapon = true,
        SurvivalRetreat = true, -- Dernière vie + PV bas : lévitation hors de portée quelques secondes
    },

    Dungeon = {
        AutoPickCard = true,
        AutoBuyChests = true,
        AutoSkipBreak = true,
        ChestThreshold = 30000,
        AutoReadyUp = true,
        AutoLeaveShops = true, -- Fin de run : quitter la zone boutiques (LeavePad) pour pouvoir relancer
        AutoRejoin = true,     -- Queue un script de retour au donjon via queue_on_teleport
        HubUrl = "https://nwhub-platform.vercel.app/slayers2_dungeon.lua",
        FarmUntilItem = false,
        TargetItem = "",
        StopWhenItemObtained = true,
        -- Priorités "dégâts d'abord" : mobs tués plus vite = moins de dégâts
        -- subis = vagues tenues plus longtemps. La survie reprend le dessus
        -- automatiquement via le boost d'urgence quand Hearts <= 2 ou PV bas.
        -- Les cartes Event/Stat sont affinées par mots-clés (Momentum, Glass
        -- Cannon, Vampiric... positifs ; Pacifist, Iron Tower... négatifs).
        CardPriorities = {
            Skill = 10,
            Weapon = 10,
            Stat = 9,
            Forge = 8,
            ExtraLife = 7,
            Revive = 7,
            Heal = 7,
            Potion = 7,
            Clan = 7,
            AscendClan = 7,
            Event = 6,
            Points = 6,
            Fortune = 6,
            SkillSwap = 6,
            Trade = 4,
            Skip = 3,
            SkipFloor = 3,
            Reroll = 2,
            SwapMap = 1,
        }
    },

    Visuals = {
        MobESP = true,
        PlayerESP = false,
        ChestESP = true,
        ESPBoxes = true,
        MobColor = Color3.fromRGB(255, 65, 65),
        PlayerColor = Color3.fromRGB(124, 108, 255),
        ChestColor = Color3.fromRGB(255, 215, 0),
    },

    Combat = {
        InfStamina = true,
        AntiFreeze = true,
        TrackGuard = true,
    },

    Misc = {
        CustomSpeed = false,
        WalkSpeed = 35,
        NoClip = false,
        InfiniteJump = false,
    }
}
_G.SlayersDungeonKyokaHub = Hub
_G.SlayersDungeonHubs = _G.SlayersDungeonHubs or {}
table.insert(_G.SlayersDungeonHubs, Hub)

--=====================================================================
-- Plateforme Anti-Chute Sécurisée
--=====================================================================
local function EnsureFarmPlatform(cframe)
    local root = GetRootPart()
    if not root then return end

    if not Hub.FarmPlatform or not Hub.FarmPlatform.Parent then
        local p = Instance.new("Part")
        p.Name = "KyokaDungeonPlatform"
        p.Size = Vector3.new(20, 1.0, 20)
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = true
        p.Parent = Workspace
        Hub.FarmPlatform = p
    end

    local pos = (typeof(cframe) == "CFrame" and cframe.Position) or (typeof(cframe) == "Vector3" and cframe) or (root.Position)
    local part = Hub.FarmPlatform
    if part.Size ~= Vector3.new(20, 1.0, 20) then part.Size = Vector3.new(20, 1.0, 20) end
    if part.CanCollide ~= true then part.CanCollide = true end
    -- On ne réécrit le CFrame que si la plateforme a réellement bougé (évite
    -- des milliers de réplications inutiles par minute)
    local target = Vector3.new(pos.X, pos.Y - 3.4, pos.Z)
    if (part.Position - target).Magnitude > 0.05 then
        part.CFrame = CFrame.new(target)
    end
end

local function RemoveFarmPlatform()
    if Hub.FarmPlatform then
        pcall(function() Hub.FarmPlatform:Destroy() end)
        Hub.FarmPlatform = nil
    end
end

--=====================================================================
-- Système d'Équipement Permanent d'Arme (Anti-Désarmement)
--=====================================================================
local lastEquipCheck = 0
local function EnsureWeaponEquipped()
    if not Hub.Farm.AutoEquipWeapon then return end
    local now = os.clock()
    if (now - lastEquipCheck) < 0.4 then return end
    lastEquipCheck = now

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

--=====================================================================
-- Système de Combat & Défense
--=====================================================================
local CombatPresets = nil
pcall(function()
    CombatPresets = require(ReplicatedStorage.CAM.Global.Combat_presets)
end)

-- IMPORTANT : le serveur valide CHAQUE attaque avec
-- Combat_presets.Check_can_do_combat_server (combo suivant exact + cooldown réel).
-- Mettre les cooldowns à zéro ne fait donc PAS taper plus vite : ça fait juste
-- envoyer des paquets que le serveur rejette silencieusement (les fameux "coups
-- qui ne s'enregistrent pas"). On restaure toujours les vraies valeurs, et on
-- nettoie celles qu'une ancienne exécution du hub aurait laissées traînées.
local function RestoreCombatPresets()
    pcall(function()
        if not (CombatPresets and CombatPresets.Presets) then return end

        -- Valeurs sauvegardées par une éventuelle exécution précédente
        local saved = _G.KyokaDungeonPresetOriginals
        if saved then
            for k, orig in pairs(saved.Presets or {}) do
                local p = CombatPresets.Presets[k]
                if type(p) == "table" and type(orig) == "table" then
                    if orig.default ~= nil then p.default = orig.default end
                    if orig.final ~= nil then p.final = orig.final end
                end
            end
            if saved.combo_duration ~= nil then
                CombatPresets.combo_duration = saved.combo_duration
            end
            _G.KyokaDungeonPresetOriginals = nil
        end

        -- Filet de sécurité : l'ancienne version mettait default/final à 0.
        -- Le module require est mis en cache par client : si l'ancien hub a
        -- tourné dans cette session, on répare les cooldowns à la volée.
        for _, p in pairs(CombatPresets.Presets) do
            if type(p) == "table" then
                if type(p.default) == "number" and p.default <= 0.01 then p.default = 0.25 end
                if type(p.final) == "number" and p.final <= 0.01 then p.final = 1.65 end
            end
        end
        if type(CombatPresets.combo_duration) == "number" and CombatPresets.combo_duration < 0.5 then
            CombatPresets.combo_duration = 1.35
        end
    end)
end

RestoreCombatPresets()

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

local STUN_VALUES = {
    "Stun", "Strict_Stun", "CombatStun", "RagDoll", "Ragdoll", "ragdoll", "ragDoll",
    "pause_gameplay", "iframe", "noragdoll", "Blocking", "JumpingDisabled",
    "skill_stand_still", "skill_slow", "tooldisabled", "combatdisabled",
    "Swapping", "Using_Skill_Switch",
}

local function ForceUnfreezeCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local animator = hum and hum:FindFirstChildOfClass("Animator")

    pcall(function()
        local u2 = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(LocalPlayer.Name)
        if u2 then
            for _, name in ipairs(STUN_VALUES) do
                local v = u2:FindFirstChild(name)
                if v then pcall(function() v:Destroy() end) end
            end
        end
    end)

    pcall(function()
        for _, name in ipairs(STUN_VALUES) do
            local v = char:FindFirstChild(name)
            if v then pcall(function() v:Destroy() end) end
        end
    end)

    pcall(function()
        if root then
            local toRemoveRoot = { "skill_stand_still", "skill_slow", "air_combo_bp" }
            for _, name in ipairs(toRemoveRoot) do
                local v = root:FindFirstChild(name)
                if v then pcall(function() v:Destroy() end) end
            end
        end
    end)

    pcall(function()
        if InputHandler and InputHandler.VirtualRelease then
            InputHandler.VirtualRelease("Block")
            InputHandler.VirtualRelease("Combat")
        end
    end)

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

    pcall(function()
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Running)
            if hum.WalkSpeed < 10 then hum.WalkSpeed = 16 end
            if hum.JumpPower == 0 then hum.JumpPower = 50 end
            hum.PlatformStand = false
            hum.Sit = false
            hum.AutoRotate = true
        end
    end)

    EnsureWeaponEquipped()
end

-- Sortie d'urgence quand un NPC attrape le joueur : on s'envole très haut
-- (hors de portée des grabs) pour casser la boucle de stun infini.
local function EscapeStun()
    local root = GetRootPart()
    if not root then return end

    local pos = root.Position
    local nearest, nearestDist = nil, math.huge
    pcall(function()
        local hums = Workspace:FindFirstChild("Humanoids")
        if not hums then return end
        for _, d in ipairs(hums:GetDescendants()) do
            if d:IsA("Humanoid") and d.Health > 0 and d.Parent and d.Parent ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(d.Parent) then
                local mroot = d.Parent:FindFirstChild("HumanoidRootPart") or d.Parent:FindFirstChild("Torso")
                if mroot then
                    local dist = (mroot.Position - pos).Magnitude
                    if dist < nearestDist then nearest, nearestDist = mroot, dist end
                end
            end
        end
    end)

    -- Déjà largement au-dessus du danger : on ne monte pas plus haut
    if nearest and (pos.Y - nearest.Position.Y) > 50 then
        local cf = CFrame.new(pos)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        Hub.SafeHoverCFrame = cf
        EnsureFarmPlatform(cf)
        return
    end

    -- Point d'évasion : 40 studs au-dessus, légèrement décalé du mob le plus proche
    local escapePos = Vector3.new(pos.X, pos.Y + 40, pos.Z)
    if nearest and nearestDist < 80 then
        local away = (pos - nearest.Position) * Vector3.new(1, 0, 1)
        if away.Magnitude > 0.1 then
            escapePos = escapePos + away.Unit * 14
        end
    end

    local cf = CFrame.new(escapePos)
    root.CFrame = cf
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    Hub.SafeHoverCFrame = cf
    EnsureFarmPlatform(cf)
end

-- Récupère un point de spawn de la map du donjon en cours (parts streamés, sinon template de map)
local function GetDungeonSpawnCFrame()
    local debree = Workspace:FindFirstChild("Debree")
    local spawns = debree and debree:FindFirstChild("Spawns")
    local dungeon = spawns and spawns:FindFirstChild("Dungeon")
    if dungeon then
        local parts = {}
        for _, p in ipairs(dungeon:GetChildren()) do
            if p:IsA("BasePart") then table.insert(parts, p) end
        end
        if #parts > 0 then
            local p = parts[math.random(1, #parts)]
            return CFrame.new(p.Position + Vector3.new(0, 6, 0))
        end
    end

    local mapName = workspace:GetAttribute("MinigameMap")
    if mapName then
        local maps = ReplicatedStorage:FindFirstChild("Minigames Place")
        maps = maps and maps:FindFirstChild("Minigames")
        maps = maps and maps:FindFirstChild("Ouwigahara")
        maps = maps and maps:FindFirstChild("Maps")
        local map = maps and maps:FindFirstChild(mapName)
        local templateSpawns = map and map:FindFirstChild("Spawns")
        if templateSpawns then
            local parts = {}
            for _, p in ipairs(templateSpawns:GetChildren()) do
                if p:IsA("BasePart") then table.insert(parts, p) end
            end
            if #parts > 0 then
                local p = parts[math.random(1, #parts)]
                return CFrame.new(p.Position + Vector3.new(0, 6, 0))
            end
        end
    end
    return nil
end

-- Si le run a démarré mais qu'on est resté hors du donjon (TP client raté),
-- on se rend soi-même sur un point de spawn de la map (sinon "la vague ne commence jamais")
local function EnsureInsideDungeon(myRoot)
    local cf = GetDungeonSpawnCFrame()
    if not cf then return false end
    if (myRoot.Position - cf.Position).Magnitude < 250 then return false end
    pcall(function() LocalPlayer:RequestStreamAroundAsync(cf.Position) end)
    task.wait(0.15)
    myRoot.CFrame = cf
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
    Hub.SafeHoverCFrame = cf
    EnsureFarmPlatform(cf)
    Hub.LastDungeonTp = os.clock()
    return true
end

--=====================================================================
-- Moteur d'attaque (100% valide côté serveur)
-----------------------------------------------------------------------
-- CU.Combat > punch() gère déjà tout : combo suivant exact, cooldown du
-- preset, animation, puis envoi de Combat_Service. Le serveur re-valide via
-- Check_can_do_combat_server. Maintenir l'input "Combat" déclenche la chaîne
-- holdChain() du jeu : chaque coup part au bon moment avec le bon combo, donc
-- chaque coup touche. C'est ce que fait un joueur qui garde le clic enfoncé.
-- (L'ancienne version spammait des paquets Combat_Service avec des combos
-- arbitraires -> rejetés par le serveur = coups non enregistrés.)
--=====================================================================
local attackHeld = false

local function ReleaseAttack()
    if not attackHeld then return end
    attackHeld = false
    pcall(function()
        if InputHandler and InputHandler.VirtualRelease then
            InputHandler.VirtualRelease("Combat")
        end
    end)
end

local function PerformAttack(multiCount, target)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- Stun : on nettoie immédiatement au lieu de rester bloqué
    if IsPlayerStunnedOrRagdolled() then
        ForceUnfreezeCharacter()
    end

    EnsureWeaponEquipped()

    -- Release block immediately before attack so M1 is never swallowed
    if InputHandler and InputHandler.VirtualRelease then
        pcall(function() InputHandler.VirtualRelease("Block") end)
    end

    if attackHeld then return end

    -- Durée de maintien : le jeu enchaîne les M1 tant que l'input reste enfoncé.
    -- Blitz = maintien quasi permanent. Sinon "Hits Per Cycle" règle la longueur
    -- de la rafale (le serveur garde de toute façon son propre rythme max).
    local holdTime
    if Hub.Farm.InstantKill then
        holdTime = 1.2
    elseif Hub.Farm.MultiHit then
        holdTime = 0.3 + math.clamp(Hub.Farm.MultiHitCount or 4, 1, 10) * 0.1
    else
        holdTime = 0.15
    end

    if InputHandler and InputHandler.VirtualPress and InputHandler.VirtualRelease then
        attackHeld = true
        InputHandler.VirtualPress("Combat")
        task.delay(holdTime, ReleaseAttack)
    elseif mouse1press and mouse1release then
        mouse1press()
        task.delay(holdTime, function() pcall(mouse1release) end)
    elseif VirtualInputManager then
        VirtualInputManager:SendMouseButtonEvent(600, 400, 0, true, game, 0)
        task.delay(holdTime, function()
            pcall(function() VirtualInputManager:SendMouseButtonEvent(600, 400, 0, false, game, 0) end)
        end)
    end
end

-- Skills Rotation
local lastSkillCast = 0
local currentSkillIndex = 1
local function CastAvailableSkill()
    if not Hub or not Hub.Farm or not Hub.Farm.AutoSkills then return false end
    if IsPlayerStunnedOrRagdolled() then return false end
    local now = os.clock()
    if (now - lastSkillCast) < (Hub.Farm.SkillInterval or 0.8) then return false end

    local casted = false
    pcall(function()
        local sp = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
        local keys = sp.get_current_keys()
        if not keys or #keys == 0 then return end

        local validSkills = {}
        for _, k in ipairs(keys) do
            if k.Name and k.Name ~= "Blocking" and k.Key and not k.RequiresModeBar then
                table.insert(validSkills, k)
            end
        end

        if #validSkills == 0 then return end

        if currentSkillIndex > #validSkills then
            currentSkillIndex = 1
        end

        local targetSkill = validSkills[currentSkillIndex]
        currentSkillIndex = currentSkillIndex + 1
        if not targetSkill then return end

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
            casted = true
            return
        end

        -- Fallback VIM
        if targetSkill.Key and VirtualInputManager then
            local keyEnum = Enum.KeyCode[targetSkill.Key]
            if keyEnum then
                VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
                task.wait(0.04)
                VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
                lastSkillCast = now
                casted = true
            end
        end
    end)
    return casted
end

--=====================================================================
-- Détection des Monstres de Donjon (Scan Continuel Multi-Régions)
--=====================================================================
-- Cache du scan de mobs. ATTENTION Luau : impossible de stocker des champs sur
-- une fonction (attempt to index function) -> variables locales dédiées.
local mobScanCache, mobScanCacheAt, mobFullScanAt = nil, 0, 0

local function GetAliveDungeonMobs(force)
    -- Cache court : la fonction est appelée par la boucle principale, l'ESP et
    -- les automatisations. Sans cache on scanne Workspace.Humanoids 4x par frame.
    local nowCache = os.clock()
    if not force and mobScanCache and (nowCache - mobScanCacheAt) < 0.15 then
        return mobScanCache
    end

    local alive = {}
    local myChar = LocalPlayer.Character
    local myRoot = GetRootPart()
    local myPos = myRoot and myRoot.Position

    -- Fallback ULTIME (rate-limite) si la structure du donjon n'a pas de dossier
    -- Workspace.Humanoids : scan complet de Workspace pour trouver les mobs.
    local humsFolder = Workspace:FindFirstChild("Humanoids")
    if not humsFolder then
        if (nowCache - mobFullScanAt) < 0.75 then
            return mobScanCache or alive
        end
        mobFullScanAt = nowCache
        for _, mobModel in ipairs(Workspace:GetDescendants()) do
            if mobModel:IsA("Model") then
                if mobModel ~= myChar and not Players:GetPlayerFromCharacter(mobModel) then
                    local hum = mobModel:FindFirstChildOfClass("Humanoid")
                    local root = mobModel:FindFirstChild("HumanoidRootPart") or mobModel:FindFirstChild("Torso")
                    if hum and root and hum.Health > 0 and root.Position.Y > -1500 then
                        local isBoss = (hum.MaxHealth >= 300) or string.find(mobModel.Name:lower(), "demon") or string.find(mobModel.Name:lower(), "yeti")
                        table.insert(alive, {
                            Model = mobModel,
                            Root = root,
                            Humanoid = hum,
                            Name = mobModel.Name,
                            Type = mobModel.Name,
                            Region = "Dungeon",
                            MaxHealth = hum.MaxHealth,
                            Health = hum.Health,
                            IsBoss = isBoss
                        })
                    end
                end
            end
        end
        if #alive > 0 then Hub.LastMobSeenAt = os.clock() end
        mobScanCache = alive
        mobScanCacheAt = nowCache
        return alive
    end

    if humsFolder then
        local seen = {}

        local function tryAdd(mobModel, typeName, regionName)
            if not mobModel or not mobModel:IsA("Model") then return end
            if mobModel == myChar or seen[mobModel] then return end
            if Players:GetPlayerFromCharacter(mobModel) then return end
            local hum = mobModel:FindFirstChildOfClass("Humanoid")
            local root = mobModel:FindFirstChild("HumanoidRootPart") or mobModel:FindFirstChild("Torso")
            if hum and root and hum.Health > 0 and root.Position.Y > -1500 then
                seen[mobModel] = true
                local isBoss = (hum.MaxHealth >= 300) or string.find(mobModel.Name:lower(), "demon") or string.find(mobModel.Name:lower(), "yeti")
                table.insert(alive, {
                    Model = mobModel,
                    Root = root,
                    Humanoid = hum,
                    Name = mobModel.Name,
                    Type = typeName or mobModel.Name,
                    Region = regionName or "Dungeon",
                    MaxHealth = hum.MaxHealth,
                    Health = hum.Health,
                    IsBoss = isBoss
                })
            end
        end

        -- 1. Tous les dossiers ActiveNpcs, où qu'ils soient dans Humanoids
        --    (Regions.<x>.ActiveNpcs, Temporary.ActiveNpcs, etc.)
        --    Un seul GetDescendants() réutilisé pour le fallback (au lieu de deux).
        local descendants = humsFolder:GetDescendants()
        for _, activeNpcs in ipairs(descendants) do
            if activeNpcs.Name == "ActiveNpcs" then
                local parentName = activeNpcs.Parent and activeNpcs.Parent.Name or "Dungeon"
                for _, mobTypeFolder in ipairs(activeNpcs:GetChildren()) do
                    for _, mobModel in ipairs(mobTypeFolder:GetChildren()) do
                        tryAdd(mobModel, mobTypeFolder.Name, parentName)
                    end
                end
            end
        end

        -- 2. Fallback : n'importe quel Model avec Humanoid dans Humanoids
        --    (uniquement si le scan ActiveNpcs n'a rien trouvé)
        if #alive == 0 then
            for _, child in ipairs(descendants) do
                tryAdd(child, nil, nil)
            end
        end
    end

    -- 3. Dossiers ActiveNpcs éventuels sous Workspace.Map.Regions (petit dossier, scan léger)
    local mapRegions = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Regions")
    if mapRegions then
        local seen2 = {}
        for _, m in ipairs(alive) do seen2[m.Model] = true end
        for _, activeNpcs in ipairs(mapRegions:GetDescendants()) do
            if activeNpcs.Name == "ActiveNpcs" then
                for _, mobTypeFolder in ipairs(activeNpcs:GetChildren()) do
                    for _, mobModel in ipairs(mobTypeFolder:GetChildren()) do
                        if mobModel:IsA("Model") and not seen2[mobModel] then
                            local hum = mobModel:FindFirstChildOfClass("Humanoid")
                            local root = mobModel:FindFirstChild("HumanoidRootPart") or mobModel:FindFirstChild("Torso")
                            if hum and root and hum.Health > 0 and root.Position.Y > -1500 then
                                seen2[mobModel] = true
                                table.insert(alive, {
                                    Model = mobModel,
                                    Root = root,
                                    Humanoid = hum,
                                    Name = mobModel.Name,
                                    Type = mobTypeFolder.Name,
                                    Region = activeNpcs.Parent and activeNpcs.Parent.Name or "Map",
                                    MaxHealth = hum.MaxHealth,
                                    Health = hum.Health,
                                    IsBoss = (hum.MaxHealth >= 300)
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    if #alive > 0 then Hub.LastMobSeenAt = os.clock() end

    -- Tri selon la priorité choisie
    local priority = Hub.Farm.TargetPriority or "Closest"
    if priority == "Lowest HP" then
        table.sort(alive, function(a, b)
            return a.Health < b.Health
        end)
    elseif priority == "Bosses First" then
        table.sort(alive, function(a, b)
            if a.IsBoss ~= b.IsBoss then
                return a.IsBoss
            end
            if myPos then
                return (a.Root.Position - myPos).Magnitude < (b.Root.Position - myPos).Magnitude
            end
            return a.Health < b.Health
        end)
    else -- "Closest"
        if myPos then
            table.sort(alive, function(a, b)
                return (a.Root.Position - myPos).Magnitude < (b.Root.Position - myPos).Magnitude
            end)
        end
    end

    mobScanCache = alive
    mobScanCacheAt = nowCache
    return alive
end

--=====================================================================
-- Lecture de l'État du Donjon (Ouwigahara TopBar)
--=====================================================================
local function GetDungeonStatus()
    local topBar = LocalPlayer.PlayerGui:FindFirstChild("ComponentsHolder")
    topBar = topBar and topBar:FindFirstChild("MainNotificationFrame")
    topBar = topBar and topBar:FindFirstChild("OuwigaharaTopBar")

    local floorText = "Unknown"
    local leftText = "Unknown"
    local clockText = "--:--"

    if topBar then
        local f = topBar:FindFirstChild("Floor", true)
        local c = topBar:FindFirstChild("Clock", true)
        local v = topBar:FindFirstChild("Value", true)
        if f and f.Text then floorText = f.Text end
        if c and c.Text then clockText = c.Text end
        if v and v.Text then leftText = v.Text end
    end

    return {
        Floor = floorText,
        Clock = clockText,
        EnemiesLeft = leftText
    }
end

--=====================================================================
-- Auto Collecte Coffres & Loots Dédiée Donjon (Portée Illimitée Fin d'Étage)
--=====================================================================
local function AnyDangerMobsNearby()
    -- Réutilise le cache de scan des mobs (évite un GetDescendants complet par appel)
    return #GetAliveDungeonMobs() > 0
end

local function CollectDungeonChestsAndDrops()
    if Hub.IsReadyingUp or Hub.IsSpendingChestPoints or Hub.IsCollectingLoot then return end
    local myRoot = GetRootPart()
    if not myRoot then return end
    Hub.IsCollectingLoot = true
    Hub.LootStartedAt = os.clock()
    local myUserId = LocalPlayer.UserId

    -- Helper: Aspirer tous les LootDrops (Zéro Miss)
    local function VacuumDungeonDrops(timeout)
        if not Hub.Farm.AutoCollectLoot then return end
        local deadline = tick() + (timeout or 6.0)
        local lFolder = Workspace:FindFirstChild("LootDrops")
        local cs = game:GetService("CollectionService")

        while tick() < deadline and Hub.Alive do
            local r = GetRootPart()
            if not r then break end
            if AnyDangerMobsNearby() or Hub.IsReadyingUp or Hub.IsSpendingChestPoints then break end
            local currentPos = r.Position
            local candidateDrops = {}

            local function checkDrop(item)
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

                -- Coordonnée exacte d'atterrissage (DropTarget prioritaire)
                local dropTarget = item:GetAttribute("DropTarget")
                local part = item:IsA("BasePart") and item or (item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true))
                local pos = (typeof(dropTarget) == "Vector3" and dropTarget) or (part and part.Position) or (item:IsA("Model") and item:GetPivot().Position)
                if not pos then return end

                table.insert(candidateDrops, { Item = item, Part = part, Pos = pos, Dist = (pos - currentPos).Magnitude })
            end

            if lFolder then
                for _, item in ipairs(lFolder:GetChildren()) do checkDrop(item) end
            end
            for _, item in ipairs(cs:GetTagged("LootDrop")) do
                if not lFolder or item.Parent ~= lFolder then checkDrop(item) end
            end

            -- Si aucun drop détecté, attendre 0.25s et re-vérifier (le temps que le serveur finisse de les instancier)
            if #candidateDrops == 0 then
                task.wait(0.25)
                if lFolder then
                    for _, item in ipairs(lFolder:GetChildren()) do checkDrop(item) end
                end
                for _, item in ipairs(cs:GetTagged("LootDrop")) do
                    if not lFolder or item.Parent ~= lFolder then checkDrop(item) end
                end
                if #candidateDrops == 0 then
                    break
                end
            end

            table.sort(candidateDrops, function(a, b) return a.Dist < b.Dist end)

            local collectedAny = false
            for _, dData in ipairs(candidateDrops) do
                local item = dData.Item
                local part = dData.Part
                local pos = dData.Pos

                -- Re-vérifier que le drop n'a pas été absorbé entre-temps
                if item and item.Parent and item:GetAttribute("DropClaimedBy") == nil and r then
                    local targetCF = CFrame.new(pos + Vector3.new(0, 1.2, 0))
                    r.CFrame = targetCF
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    EnsureFarmPlatform(targetCF)

                    local p = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p then
                        p.Enabled = true
                        local oldHold = p.HoldDuration
                        local oldDist = p.MaxActivationDistance
                        p.HoldDuration = 0
                        p.MaxActivationDistance = 60
                        pcall(fireproximityprompt, p, 0)
                        pcall(fireproximityprompt, p)
                        local promptKey = (p.KeyboardKeyCode ~= Enum.KeyCode.Unknown and p.KeyboardKeyCode) or Enum.KeyCode.T
                        if VirtualInputManager then
                            VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
                        end
                        pcall(function()
                            p.HoldDuration = oldHold
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

                    -- Délai de réplication serveur (140ms pour éviter le drop anti-spam)
                    task.wait(0.14)

                    -- Confirmation immédiate si pas encore validé
                    if item and item.Parent and item:GetAttribute("DropClaimedBy") == nil then
                        if p then
                            p.Enabled = true
                            pcall(fireproximityprompt, p, 0)
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

    -- 1. Coffres (Ouwigahara Chests + Coffres Workspace) — uniquement si l'option est active
    local chestsToOpen = {}
    local function evaluateChest(ch)
        if not Hub.Farm.AutoCollectChests then return end
        if not ch or not ch.Parent then return end
        if ch:GetAttribute("IsOpen") == true or ch:GetAttribute("ChestState") == "Opened" or ch:GetAttribute("ChestState") == "Despawned" then
            return
        end
        local mName = (ch.Name or ""):lower()
        if mName:find("mound") then return end

        for _, prompt in ipairs(ch:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local act = (prompt.ActionText or ""):lower()
                local obj = (prompt.ObjectText or ""):lower()
                if not act:find("chat") and not act:find("talk") and not act:find("train") and not act:find("shop") and not obj:find("trainer") and not obj:find("npc") then
                    if not (ch:GetAttribute("ChestState") == "Locked" and not prompt.Enabled) then
                        local pPart = prompt.Parent
                        local pPos = pPart and (pPart:IsA("Attachment") and pPart.WorldPosition or (pPart:IsA("BasePart") and pPart.Position or pPart:GetPivot().Position)) or ch:GetPivot().Position
                        table.insert(chestsToOpen, { Model = ch, Prompt = prompt, Pos = pPos })
                        break
                    end
                end
            end
        end
    end

    local cFolder = Workspace:FindFirstChild("Chests")
    if cFolder then
        for _, ch in ipairs(cFolder:GetChildren()) do evaluateChest(ch) end
    end
    local cs = game:GetService("CollectionService")
    for _, ch in ipairs(cs:GetTagged("Chest")) do
        if not cFolder or ch.Parent ~= cFolder then evaluateChest(ch) end
    end

    for _, chData in ipairs(chestsToOpen) do
        local r = GetRootPart()
        if not r then break end
        if AnyDangerMobsNearby() or Hub.IsReadyingUp or Hub.IsSpendingChestPoints then break end
        local ch = chData.Model
        local prompt = chData.Prompt
        local pPos = chData.Pos

        if ch and ch.Parent and prompt and prompt.Parent then
            prompt.Enabled = true
            local oldHold = prompt.HoldDuration
            local oldDist = prompt.MaxActivationDistance
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 60

            local chestCF = CFrame.new(pPos + Vector3.new(0, 1.5, 2.5), pPos)
            r.CFrame = chestCF
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            EnsureFarmPlatform(chestCF)
            task.wait(0.18)

            pcall(fireproximityprompt, prompt, 0)
            pcall(fireproximityprompt, prompt)

            local promptKey = (prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode) or Enum.KeyCode.T
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
                task.wait(0.08)
                VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
            end

            local openStart = tick()
            while (tick() - openStart) < 2.5 do
                if ch:GetAttribute("IsOpen") == true or ch:GetAttribute("ChestState") == "Opened" then
                    break
                end
                if (tick() - openStart) > 0.6 and (tick() - openStart) < 0.75 then
                    pcall(fireproximityprompt, prompt, 0)
                    pcall(fireproximityprompt, prompt)
                end
                task.wait(0.12)
            end

            pcall(function()
                prompt.HoldDuration = oldHold
                prompt.MaxActivationDistance = oldDist
            end)

            -- Attente active des drops
            local spawnWaitStart = tick()
            while (tick() - spawnWaitStart) < 2.0 do
                local dropsPresent = false
                local lF = Workspace:FindFirstChild("LootDrops")
                local cService = game:GetService("CollectionService")
                if lF and #lF:GetChildren() > 0 then dropsPresent = true end
                if not dropsPresent and #cService:GetTagged("LootDrop") > 0 then dropsPresent = true end
                if dropsPresent then
                    task.wait(0.5)
                    break
                end
                task.wait(0.15)
            end

            VacuumDungeonDrops(6.0)
        end
    end

    -- 2. Aspiration globale finale de tous les drops restants
    VacuumDungeonDrops(4.0)

    Hub.IsCollectingLoot = false
end

--=====================================================================
-- Auto Pick Card (Cartes Ouwigahara avec Échelle de Priorité 1-10)
--=====================================================================
-- Types de cartes qui aident directement à survivre aux vagues suivantes.
local SURVIVAL_CARD_TYPES = {
    ExtraLife = true,
    Revive = true,
    Heal = true,
    Potion = true,
}

-- Mots-clés de survie (utilisés pour le boost d'urgence quand on est en danger)
local SURVIVAL_KEYWORDS = {
    "heal", "regen", "health", "life", "revive", "second chance",
    "reincarnation", "vampiric", "thick blood", "bulwark", "medic", "shield",
}

-- Bonus/malus par mots-clés du titre (surtout cartes Event & Stat).
-- Positif = dégâts / survie / progression. Négatif = piège pour un farm AFK
-- (désactive les skills, supprime les vies, réduit la vie max, etc.).
-- Basé sur le pool réel des 93 cartes Ouwigahara.
local CARD_KEYWORD_SCORES = {
    -- Dégâts / tempo
    ["glass cannon"] = 45,
    ["momentum"] = 42,
    ["frenzy"] = 38,
    ["lone wolf"] = 35,
    ["heavy hitter"] = 32,
    ["berserk"] = 30,
    ["vampiric"] = 30,
    ["venom fang"] = 28,
    ["wildfire"] = 28,
    ["deep freeze"] = 26,
    ["plague bearer"] = 26,
    ["attack speed"] = 26,
    ["damage"] = 22,
    ["cooldown"] = 16,
    ["crit"] = 16,
    -- Survie passive
    ["reincarnation"] = 40,
    ["second chance"] = 35,
    ["thick blood"] = 28,
    ["max health"] = 22,
    ["damage reduction"] = 22,
    ["heal"] = 12,
    ["health regen"] = 14,
    ["regen"] = 4, -- attention : matche aussi "Stamina Regen" -> valeur basse
    ["block"] = 10,
    ["stamina"] = 2,
    -- Progression / économie
    ["weapon"] = 12,
    ["skill"] = 10,
    ["points"] = 8,
    ["fortune"] = 6,
    ["reroll"] = 4,
    -- Events positifs (bonus sans vrai risque)
    ["streak"] = 12,
    ["lucky draw"] = 12,
    ["prodigy"] = 12,
    ["weapon master"] = 14,
    ["twin weapons"] = 14,
    ["warcry"] = 15,
    ["adrenaline"] = 18,
    ["bulwark"] = 15,
    ["medic"] = 15,
    ["lifeline"] = 20,
    ["parting gift"] = 10,
    ["communal heal"] = 8,
    ["last rites"] = 8,
    ["twin souls"] = 10,
    ["focused mind"] = 10,
    ["arsenal"] = 10,
    ["double down"] = 10,
    ["jackpot floor"] = 8,
    ["quartermaster"] = 6,
    ["hoarder"] = 4,
    ["bloodbank"] = 8,
    ["loaded dice"] = 6,
    ["mulligan"] = 6,
    ["endurance training"] = 6,
    ["rush hour"] = 6,
    ["rally"] = 6,
    ["the horde"] = 5,
    ["cheap seats"] = 2,
    ["time attack"] = 2,
    -- Events risqués (danger supplémentaire ou vie en moins)
    ["ascension"] = -15,
    ["boss rush"] = -20,
    ["twin bosses"] = -15,
    ["elite guard"] = -12,
    ["champion"] = -10,
    ["boss hunt"] = -10,
    ["fair fight"] = -6,
    ["blood pact"] = -15,
    -- Pièges à éviter en AFK
    ["pacifist"] = -60,
    ["reincarnated"] = -50,
    ["iron discipline"] = -45,
    ["bare hands"] = -40,
    ["iron tower"] = -40,
    ["reshuffle"] = -35,
    ["respec"] = -30,
    ["last stand"] = -30,
    ["glass floor"] = -25,
    ["bleeding floor"] = -25,
    ["blood moon"] = -25,
    ["long night"] = -20,
    ["featherweight"] = -20,
    ["cursed coin"] = -15,
    ["no guard"] = -12,
    ["heavy air"] = -10,
    ["fog of war"] = -8,
    ["lights out"] = -8,
    ["grounded"] = -8,
    ["double time"] = -8,
    ["thin air"] = -8,
    ["thick skin"] = -6,
    ["berserkers"] = -6,
    ["gold rush"] = -5,
    ["marathon"] = -5,
}

local function CardKeywordScore(title)
    if not title or title == "" then return 0 end
    local t = string.lower(tostring(title))
    local score = 0
    for kw, bonus in pairs(CARD_KEYWORD_SCORES) do
        if string.find(t, kw, 1, true) then score = score + bonus end
    end
    return score
end

local function IsSurvivalTitle(title)
    if not title or title == "" then return false end
    local t = string.lower(tostring(title))
    for _, kw in ipairs(SURVIVAL_KEYWORDS) do
        if string.find(t, kw, 1, true) then return true end
    end
    return false
end

local function CheckAndAutoPickCard()
    if not Hub.Dungeon.AutoPickCard then return end
    local now = os.clock()
    if (now - Hub.LastCardPick) < 0.35 then return end

    local offers = LocalPlayer:FindFirstChild("OuwigaharaOffers")
    if not offers then return end

    -- ---- Priorité survie dynamique ------------------------------------
    -- Objectif : tenir un maximum de vagues. Les vies du run sont exposées par
    -- le jeu via l'attribut "Hearts" sur le joueur (système Ouwigahara Lives).
    -- Dernière vie ou PV bas -> les cartes de survie passent devant tout le reste.
    local hearts = tonumber(LocalPlayer:GetAttribute("Hearts"))
    local hum = GetHumanoid()
    local hpRatio = (hum and hum.MaxHealth > 0) and (hum.Health / hum.MaxHealth) or 1

    local survivalBoost = 0
    if hearts ~= nil and hearts <= 1 then
        survivalBoost = 45
    elseif hearts ~= nil and hearts <= 2 then
        survivalBoost = 18
    end
    if hpRatio < 0.5 then survivalBoost = survivalBoost + 15 end
    if hpRatio < 0.3 then survivalBoost = survivalBoost + 15 end

    local alreadyPicked = offers:GetAttribute("Picked")

    local candidates = {}
    for _, card in ipairs(offers:GetChildren()) do
        if alreadyPicked == nil or tostring(alreadyPicked) ~= card.Name then
            local cType = card:GetAttribute("Type") or card.Name
            local cTitle = card:GetAttribute("Title") or cType
            local rarity = tonumber(card:GetAttribute("Rarity")) or 1
            local guaranteed = card:GetAttribute("Guaranteed") == true
            local userPriority = (Hub.Dungeon.CardPriorities and Hub.Dungeon.CardPriorities[cType]) or 5
            local score = (userPriority * 10) + rarity + (guaranteed and 5 or 0) + CardKeywordScore(cTitle)
            if survivalBoost > 0 and (SURVIVAL_CARD_TYPES[cType] or IsSurvivalTitle(cTitle)) then
                score = score + survivalBoost
            end
            table.insert(candidates, {
                Card = card,
                Id = card.Name,
                Type = cType,
                Title = cTitle,
                Priority = userPriority,
                Rarity = rarity,
                Score = score
            })
        end
    end

    if #candidates == 0 then return end

    table.sort(candidates, function(a, b)
        return a.Score > b.Score
    end)

    local best = candidates[1]
    if best then
        Hub.LastCardPick = now

        -- 1. Appel du signal officiel OuwigaharaRequest
        pcall(function()
            if SignalEvent and SignalEvent.ToServer then
                SignalEvent.ToServer("OuwigaharaRequest", {
                    action = "Pick",
                    id = best.Id
                })
            end
        end)

        -- 2. Clic interactif fallback sur le bouton UI PlayerGui
        pcall(function()
            local ch = LocalPlayer.PlayerGui:FindFirstChild("ComponentsHolder")
            local mn = ch and ch:FindFirstChild("MainNotificationFrame")
            local oGui = mn and mn:FindFirstChild("OuwigaharaOffers")
            local bbCards = oGui and oGui:FindFirstChild("BBCards")
            local cards = bbCards and bbCards:FindFirstChild("Cards")
            if cards then
                local cardFrame = cards:FindFirstChild(best.Id)
                local btn = cardFrame and cardFrame:FindFirstChild("Click", true)
                if btn and btn:IsA("GuiButton") and firesignal then
                    firesignal(btn.MouseButton1Click)
                end
            end
        end)

        pcall(function()
            if Kyoka and Kyoka.Notify then
                local extra = ""
                if SURVIVAL_CARD_TYPES[best.Type] and survivalBoost > 0 then
                    extra = " [SURVIE +" .. tostring(survivalBoost) .. "]"
                end
                Kyoka:Notify({
                    Title = "Auto Pick Card",
                    Content = "Picked " .. tostring(best.Type) .. " (" .. tostring(best.Title) .. ") [Prio: " .. tostring(best.Priority) .. "/10]" .. extra,
                    Type = "success",
                    Duration = 3
                })
            end
        end)
    end
end

--=====================================================================
-- Auto Achat Coffres Ouwigahara (Dépense >= 30k Points Automatique)
--=====================================================================
local function CheckAndAutoSpendChests()
    if not Hub.Dungeon.AutoBuyChests or Hub.IsSpendingChestPoints then return end

    local currentPoints = 0
    pcall(function()
        currentPoints = tonumber(LocalPlayer:GetAttribute("RunPoints")) or 0
        if currentPoints == 0 and LocalPlayer:FindFirstChild("leaderstats") then
            local pVal = LocalPlayer.leaderstats:FindFirstChild("Points")
            if pVal then currentPoints = tonumber(pVal.Value) or 0 end
        end
    end)

    local threshold = Hub.Dungeon.ChestThreshold or 30000
    if currentPoints < threshold then return end

    local minigameState = workspace:GetAttribute("MinigameState")
    local inShops = LocalPlayer:GetAttribute("InShops") == true or minigameState == "Ended" or minigameState == "Lobby"
    local aliveMobs = GetAliveDungeonMobs()
    local enemiesLeft = tonumber(workspace:GetAttribute("MinigameEnemiesLeft"))

    -- On achète uniquement lorsque le run est terminé / en shops / lobby ou étage entièrement nettoyé
    if not inShops and (#aliveMobs > 0 or (enemiesLeft ~= nil and enemiesLeft > 0)) then return end

    Hub.IsSpendingChestPoints = true
    Hub.SpendStartedAt = os.clock()
    local myRoot = GetRootPart()
    if not myRoot then Hub.IsSpendingChestPoints = false; return end

    local prevCF = myRoot.CFrame
    local chestPos = Vector3.new(-2315.742, 1145.319, -2582.007)

    -- Demande de streaming du chunk boutique
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(chestPos)
    end)
    task.wait(0.2)

    -- Téléportation sécurisée face au coffre Ouwigahara
    local chestCF = CFrame.new(chestPos + Vector3.new(0, 1.8, 3.2), chestPos)
    myRoot.CFrame = chestCF
    myRoot.AssemblyLinearVelocity = Vector3.zero
    EnsureFarmPlatform(chestCF)
    task.wait(0.3)

    -- Recherche du ProximityPrompt du coffre Ouwigahara
    local prompt = nil
    local cFolder = Workspace:FindFirstChild("Chests")
    local ouwiChest = cFolder and cFolder:FindFirstChild("Ouwigahara Chest")
    if ouwiChest then
        prompt = ouwiChest:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    if not prompt then
        for _, pr in ipairs(Workspace:GetDescendants()) do
            if pr:IsA("ProximityPrompt") then
                local aText = pr.ActionText or ""
                local oText = pr.ObjectText or ""
                if aText:find("30,000") or oText:find("Ouwigahara Chest") or aText:find("points") then
                    prompt = pr
                    break
                end
            end
        end
    end

    if prompt and prompt.Parent then
        prompt.Enabled = true
        local oldHold = prompt.HoldDuration
        local oldDist = prompt.MaxActivationDistance
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 60

        pcall(fireproximityprompt, prompt, 0)
        pcall(fireproximityprompt, prompt)

        local promptKey = (prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode) or Enum.KeyCode.T
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, promptKey, false, game)
            task.wait(0.08)
            VirtualInputManager:SendKeyEvent(false, promptKey, false, game)
        end

        task.wait(0.5)
        pcall(function()
            prompt.HoldDuration = oldHold
            prompt.MaxActivationDistance = oldDist
        end)

        pcall(function()
            if Kyoka and Kyoka.Notify then
                Kyoka:Notify({
                    Title = "Auto Chest Purchased",
                    Content = "Spent 30,000 points on Ouwigahara Chest! Vacuuming drops...",
                    Type = "success",
                    Duration = 4
                })
            end
        end)

        -- Aspiration immédiate des loots dispensés par le coffre
        CollectDungeonChestsAndDrops()
    end

    -- Si la partie était encore en cours, retour à la position précédente
    if not inShops and myRoot then
        myRoot.CFrame = prevCF
        EnsureFarmPlatform(prevCF)
    end

    Hub.IsSpendingChestPoints = false
end

--=====================================================================
-- Farm jusqu'à un item (détection dans l'inventaire)
--=====================================================================
-- Racine de l'inventaire (contient Inventory + Toolbar + Accessories)
local function GetInventoryRoot()
    local ps = ReplicatedStorage:FindFirstChild("Player_Service")
    local data = ps and ps:FindFirstChild("Data")
    local myData = data and data:FindFirstChild(LocalPlayer.Name)
    local slots = myData and myData:FindFirstChild("slots")
    local slot = slots and (slots:FindFirstChild("Slot1") or slots:GetChildren()[1])
    return slot and slot:FindFirstChild("Inventory") or nil
end

-- Quantité TOTALE possédée, où que soit l'item (inventaire, toolbar équipée,
-- accessoires...). 1 par exemplaire sans champ Amount.
local function GetItemAmount(rootInv, name)
    if not rootInv or not name or name == "" then return 0 end
    local lower = string.lower(name)
    local total, found = 0, false
    for _, d in ipairs(rootInv:GetDescendants()) do
        if string.lower(d.Name) == lower then
            found = true
            local amt = d:FindFirstChild("Amount")
            total = total + (amt and (tonumber(amt.Value) or 1) or 1)
        end
    end
    return found and total or 0
end

-- Toutes les cibles de farm possibles : items des shops + matériaux requis +
-- matériaux de base + items déjà vus par le joueur (archive). Trie + dédoublonné.
local function BuildFarmItemList()
    local names, seen = {}, {}
    local function add(n)
        n = tostring(n or "")
        if n == "" or seen[n] then return end
        seen[n] = true
        names[#names + 1] = n
    end

    -- 1) Items achetables dans les shops (Y compris leurs matériaux de prix)
    pcall(function()
        local content = ReplicatedStorage:FindFirstChild("Minigames Place")
        if not content then return end
        for _, npc in ipairs(content:GetDescendants()) do
            if npc:IsA("ModuleScript") and npc.Parent and npc.Parent.Name == "Npcs" then
                local ok, data = pcall(require, npc)
                if ok and type(data) == "table" and type(data.Shop) == "table" then
                    for itemName, info in pairs(data.Shop) do
                        if not tostring(itemName):find("Wen") and not tostring(itemName):find("Yen") then
                            add(itemName)
                        end
                        local price = info and info.Price
                        if type(price) == "table" then
                            for k, v in pairs(price) do
                                if k ~= "Wen" and k ~= "RunPoints" and k ~= "Points" and k ~= "Yen" and k ~= "Coins" then
                                    add(k)
                                    if type(v) == "table" then
                                        for k2 in pairs(v) do add(k2) end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- 2) Matériaux (cibles de farm classiques)
    pcall(function()
        local items = ReplicatedStorage:FindFirstChild("Items")
        local mats = items and items:FindFirstChild("Materials")
        if mats then
            for _, d in ipairs(mats:GetDescendants()) do
                if d:IsA("ModuleScript") then add(d.Name) end
            end
        end
    end)

    -- 3) Archive perso du joueur (tout ce qu'il a déjà vu)
    pcall(function()
        local ps = ReplicatedStorage:FindFirstChild("Player_Service")
        local myData = ps and ps:FindFirstChild("Data") and ps.Data:FindFirstChild(LocalPlayer.Name)
        local arch = myData and myData:FindFirstChild("Archives") and myData.Archives:FindFirstChild("Items")
        if arch and arch.Value and arch.Value ~= "" then
            for name in string.gmatch(arch.Value, "([^,]+)") do add(name) end
        end
    end)

    table.sort(names)
    return names
end

local function PlayItemFoundAlert()
    pcall(function()
        local SoundService = game:GetService("SoundService")
        local sound = SoundService:FindFirstChild("KyokaItemFound")
        if not sound then
            sound = Instance.new("Sound")
            sound.Name = "KyokaItemFound"
            sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
            sound.Parent = SoundService
        end
        sound.Volume = 1
        sound.TimePosition = 0
        sound:Play()
        task.delay(0.35, function() pcall(function() sound.TimePosition = 0; sound:Play() end) end)
        task.delay(0.7, function() pcall(function() sound.TimePosition = 0; sound:Play() end) end)
    end)
end

local function DisableAutomationForItemStop()
    Hub.Farm.AutoFarm = false
    Hub.Dungeon.AutoReadyUp = false
    Hub.Dungeon.AutoLeaveShops = false
    Hub.Farm.HoverBetweenWaves = false
    Hub.Farm.AutoM1 = false
    pcall(function()
        local flags = { "AutoFarmToggle", "AutoReadyUpToggle", "AutoLeaveShopsToggle", "HoverBetweenWavesToggle" }
        for _, flag in ipairs(flags) do
            local obj = Kyoka.Options and Kyoka.Options[flag]
            if obj and obj.Set then obj:Set(false, true) end
        end
    end)
    ReleaseAttack()
    RemoveFarmPlatform()
end

local function CheckTargetItem()
    if not Hub.Dungeon.FarmUntilItem then return end
    local name = Hub.Dungeon.TargetItem
    if not name or name == "" then return end
    if Hub.TargetItemFound then return end

    local inv = GetInventoryRoot()
    if not inv then return end

    local amount = GetItemAmount(inv, name)
    if Hub.TargetItemBaseline == nil then
        Hub.TargetItemBaseline = amount
        Hub.TargetItemCurrent = amount
        return
    end
    Hub.TargetItemCurrent = amount

    if amount > Hub.TargetItemBaseline then
        Hub.TargetItemFound = true
        PlayItemFoundAlert()
        pcall(function()
            if Kyoka and Kyoka.Notify then
                Kyoka:Notify({
                    Title = "ITEM OBTAINED!",
                    Content = tostring(name) .. " x" .. tostring(amount - Hub.TargetItemBaseline) ..
                        (Hub.Dungeon.StopWhenItemObtained and " — farm stopped." or " — farm continuing."),
                    Type = "success",
                    Duration = 12
                })
            end
        end)
        if Hub.Dungeon.StopWhenItemObtained then
            DisableAutomationForItemStop()
        end
    end
end

--=====================================================================
-- Auto Rejoin : bootstrap re-queue sur le prochain téléport (Ouwland)
--=====================================================================
-- Quand on quitte la zone boutiques (LeavePad), le client part vers Ouwland.
-- On profite de queue_on_teleport pour y faire tourner ce petit script : il
-- retrouve le portail Ouwigahara, le déclenche, puis re-queue le hub pour
-- qu'il redémarre automatiquement à l'arrivée dans le donjon.
local REJOIN_BOOTSTRAP = [==[
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local URL = "%%HUB_URL%%"
if game.PlaceId == 75556147183481 then return end
local function queueHub()
    local code = 'loadstring(game:HttpGet("' .. URL .. '"))()'
    if queue_on_teleport then pcall(queue_on_teleport, code)
    elseif queueonteleport then pcall(queueonteleport, code) end
end
task.wait(6)
local function findEntry()
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local txt = (tostring(d.ObjectText or "") .. " " .. tostring(d.ActionText or "")):lower()
            if txt:find("ouw") or txt:find("dungeon") or txt:find("climb") or txt:find("minigame") or txt:find("tower crystal") then
                return d
            end
        end
    end
    return nil
end
local deadline = os.clock() + 90
local prompt = nil
while os.clock() < deadline and not prompt do
    prompt = findEntry()
    if not prompt then
        local map = workspace:FindFirstChild("Map")
        local portal = map and map:FindFirstChild("OuwigaharaPortal")
        if portal then
            local ok, pivot = pcall(function() return portal:GetPivot().Position end)
            if ok and pivot then pcall(function() lp:RequestStreamAroundAsync(pivot) end) end
        end
        task.wait(1.5)
    end
end
if not prompt then
    warn("[Kyoka Rejoin] Ouwigahara portal not found - rejoin the dungeon manually")
    return
end
local part = prompt.Parent
local pos
if part and part:IsA("BasePart") then pos = part.Position
elseif part and part:IsA("Attachment") then pos = part.WorldPosition
elseif part then pcall(function() pos = part:GetPivot().Position end) end
if pos then pcall(function() lp:RequestStreamAroundAsync(pos) end) end
task.wait(0.5)
local char = lp.Character or lp.CharacterAdded:Wait()
local root = char and char:WaitForChild("HumanoidRootPart", 10)
if root and pos then
    local cf = CFrame.new(pos + Vector3.new(0, 4, 4))
    root.CFrame = cf
    task.wait(0.35)
    root.CFrame = cf
    pcall(fireproximityprompt, prompt, 0)
    pcall(fireproximityprompt, prompt)
    task.wait(0.5)
    pcall(fireproximityprompt, prompt, 0)
    queueHub()
end
]==]

local function QueueRejoinBootstrap()
    pcall(function()
        local q = queue_on_teleport or queueonteleport
        if not q then return end
        local url = Hub.Dungeon.HubUrl or ""
        if url == "" then return end
        local code = string.gsub(REJOIN_BOOTSTRAP, "%%%%HUB_URL%%%%", url)
        q(code)
    end)
end

--=====================================================================
-- Auto Ready Up Lobby (Boucle Infinie de Donjons AFK)
--=====================================================================
local function CheckAutoReadyUp()
    if not Hub.Dungeon.AutoReadyUp then return end
    if Hub.IsReadyingUp then return end
    local minigameState = workspace:GetAttribute("MinigameState")
    if minigameState ~= "Lobby" then return end
    if LocalPlayer:GetAttribute("Readied") == true then return end

    local myRoot = GetRootPart()
    if not myRoot then return end

    -- ---- Fin de run : zone boutiques ----
    -- Après une mort on est lâché dans la zone Shops. Le StartPad du lobby n'y
    -- existe pas : on ouvre d'abord TOUS les coffres de fin de run + on aspire
    -- les loots, on laisse l'achat auto de coffres (Auto Buy Chests) se faire,
    -- puis on prend le LeavePad (retour Ouwland) en queue-ant le rejoin.
    local inShops = LocalPlayer:GetAttribute("InShops") == true
    local shops = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Shops")
    local leavePad = shops and shops:FindFirstChild("LeavePad", true)
    if inShops and leavePad and leavePad:IsA("BasePart") then
        if not Hub.ShopsSeenAt then Hub.ShopsSeenAt = os.clock() end
        local waited = os.clock() - Hub.ShopsSeenAt

        -- 1) Coffres de fin de run + aspiration des loots.
        -- Le jeu pose UN coffre par cache (1 cache tous les 10 étages) dans les
        -- boutiques : on relance une passe tant qu'il reste des coffres fermés.
        if (Hub.EndRunLootPasses or 0) < 2 and waited > 1.0 then
            local pending = false
            local cFolder = Workspace:FindFirstChild("Chests")
            if cFolder then
                for _, ch in ipairs(cFolder:GetChildren()) do
                    local st = ch:GetAttribute("ChestState")
                    if ch:GetAttribute("IsOpen") ~= true and st ~= "Opened" and st ~= "Despawned" then
                        pending = true
                        break
                    end
                end
            end
            if pending or (Hub.EndRunLootPasses or 0) == 0 then
                Hub.EndRunLootPasses = (Hub.EndRunLootPasses or 0) + 1
                task.spawn(CollectDungeonChestsAndDrops)
                return
            end
        end
        -- 2) On laisse le loot et l'achat auto se terminer avant de partir
        if Hub.IsCollectingLoot or Hub.IsSpendingChestPoints then return end
        if not Hub.Dungeon.AutoLeaveShops then return end
        if waited < 8 then return end

        -- 3) LeavePad -> Ouwland (+ rejoin auto via queue_on_teleport)
        Hub.IsReadyingUp = true
        Hub.ReadyStartedAt = os.clock()
        if Hub.Dungeon.AutoRejoin then
            QueueRejoinBootstrap()
        end
        local lp = leavePad:FindFirstChildWhichIsA("ProximityPrompt", true)
        if lp then
            local leaveCF = CFrame.new(leavePad.Position + Vector3.new(0, 3, 0))
            myRoot.CFrame = leaveCF
            myRoot.AssemblyLinearVelocity = Vector3.zero
            EnsureFarmPlatform(leaveCF)
            task.wait(0.25)

            lp.Enabled = true
            local oldHold = lp.HoldDuration
            local oldDist = lp.MaxActivationDistance
            lp.HoldDuration = 0
            lp.MaxActivationDistance = 60

            pcall(fireproximityprompt, lp, 0)
            pcall(fireproximityprompt, lp)
            local leaveKey = (lp.KeyboardKeyCode ~= Enum.KeyCode.Unknown and lp.KeyboardKeyCode) or Enum.KeyCode.E
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, leaveKey, false, game)
                task.wait(0.08)
                VirtualInputManager:SendKeyEvent(false, leaveKey, false, game)
            end
            task.wait(0.4)
            pcall(function()
                lp.HoldDuration = oldHold
                lp.MaxActivationDistance = oldDist
            end)
        end

        Hub.IsReadyingUp = false
        return
    end
    Hub.ShopsSeenAt = nil
    Hub.EndRunLootPasses = nil

    Hub.IsReadyingUp = true
    Hub.ReadyStartedAt = os.clock()

    local startPad = nil
    local map = Workspace:FindFirstChild("Map")
    local mgMap = map and map:FindFirstChild("Minigame Map")
    startPad = mgMap and mgMap:FindFirstChild("StartPad", true)

    if not startPad then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "StartPad" and obj:IsA("BasePart") then
                startPad = obj
                break
            end
        end
    end

    if startPad then
        local prompt = startPad:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt.Enabled = true
            local oldHold = prompt.HoldDuration
            local oldDist = prompt.MaxActivationDistance
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 60

            local padCF = CFrame.new(startPad.Position + Vector3.new(0, 3, 0))
            myRoot.CFrame = padCF
            EnsureFarmPlatform(padCF)
            task.wait(0.2)

            -- Re-ancrage juste avant l'interaction (évite tout TP parasite)
            myRoot.CFrame = padCF
            myRoot.AssemblyLinearVelocity = Vector3.zero
            pcall(fireproximityprompt, prompt, 0)
            pcall(fireproximityprompt, prompt)

            local pKey = (prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode) or Enum.KeyCode.E
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, pKey, false, game)
                task.wait(0.08)
                VirtualInputManager:SendKeyEvent(false, pKey, false, game)
            end

            task.wait(0.15)
            myRoot.CFrame = padCF
            myRoot.AssemblyLinearVelocity = Vector3.zero
            pcall(fireproximityprompt, prompt, 0)

            pcall(function()
                prompt.HoldDuration = oldHold
                prompt.MaxActivationDistance = oldDist
            end)

            pcall(function()
                if Kyoka and Kyoka.Notify then
                    Kyoka:Notify({
                        Title = "Auto Ready Up",
                        Content = "Readied up for next Dungeon run!",
                        Type = "info",
                        Duration = 4
                    })
                end
            end)
        end
    end
    Hub.IsReadyingUp = false
end

--=====================================================================
-- Interface Utilisateur Kyōka Suigetsu
--=====================================================================
local Window = Kyoka:CreateWindow({
    Title       = "KYŌKA",
    Subtitle    = "SLAYERS 2 DUNGEON",
    Game        = "Slayers 2 (Dungeon)",
    Footer      = "kyoka · slayers 2 dungeon v2.0",
    StatusRight = "RShift to hide",
    Tier        = "Master",
    ToggleKey   = Enum.KeyCode.RightShift,
    Splash      = true,
})

Kyoka:SetWatermark("Kyoka Hub / Slayers 2 Dungeon / {fps} fps / {ping}", true)
Kyoka:SetKeybindListVisible(true)

-- ==================== TAB DUNGEON (UNIFIED) ====================
local DungeonTab = Window:AddTab("Dungeon")

-- 1. Left Group: Auto Farm & Blitz Execution
local FarmGroup = DungeonTab:AddGroup("Auto Farm & Blitz Execution", "Left")

FarmGroup:AddToggle("AutoFarmToggle", {
    Text = "Enable Auto Farm Mobs",
    Default = true,
    Tooltip = "Automatically teleports overhead and attacks every active mob across all dungeon waves!",
    Callback = function(val)
        Hub.Farm.AutoFarm = val
        if not val then
            Hub.LockedTarget = nil
            Hub.CurrentTarget = nil
            ReleaseAttack()
            RemoveFarmPlatform()
            local root = GetRootPart()
            if root then root.AssemblyLinearVelocity = Vector3.zero end
        end
    end
}):AddKeybind("AutoFarmKey", { Default = Enum.KeyCode.RightControl, Mode = "Toggle" })

FarmGroup:AddToggle("InstantKillToggle", {
    Text = "Blitz Mode (Continuous M1 Chain)",
    Default = true,
    Tooltip = "Keeps the attack input held so the game chains every M1 at the exact server-valid combo & cooldown. 100% of hits register (no more rejected attack packets).",
    Callback = function(val)
        Hub.Farm.InstantKill = val
        if not val then ReleaseAttack() end
    end
})

FarmGroup:AddDropdown("TargetPriorityDropdown", {
    Text = "Target Priority",
    Values = { "Closest", "Lowest HP", "Bosses First" },
    Default = "Closest",
    Callback = function(val)
        Hub.Farm.TargetPriority = val
        Hub.LockedTarget = nil
    end
})

FarmGroup:AddDropdown("SafeModeDropdown", {
    Text = "Position Mode",
    Values = { "Sky / Air (Safest - Recommended)", "Overhead (Safe)", "In Front (Classic)" },
    Default = "Sky / Air (Safest - Recommended)",
    Tooltip = "Sky keeps you floating high above the mobs at all times: you still deal damage and earn points, but NPC grabs/stuns can no longer reach you!",
    Callback = function(val)
        if string.find(val, "Sky") then
            Hub.Farm.SafeMode = "Sky"
        elseif string.find(val, "Overhead") then
            Hub.Farm.SafeMode = "Overhead"
        else
            Hub.Farm.SafeMode = "In Front"
        end
    end
})

FarmGroup:AddSlider("AirHeightSlider", {
    Text = "Air Farm Height",
    Min = 4,
    Max = 40,
    Default = 6,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "How high above the mobs you hover while farming in Sky mode. The server hitbox only reaches ~9 studs below you: 5-6 studs is the sweet spot (hits land, most grabs miss). Above ~7 your hits stop registering.",
    Callback = function(val)
        Hub.Farm.AirHeight = val
        Hub.Farm.EffectiveAirHeight = nil
    end
})

FarmGroup:AddSlider("HeightOffsetSlider", {
    Text = "Safe Vertical Height",
    Min = 1.8,
    Max = 6.0,
    Default = 2.4,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(val)
        Hub.Farm.HeightOffset = val
    end
})

FarmGroup:AddSlider("DistanceSlider", {
    Text = "Target Distance",
    Min = 1.5,
    Max = 6.0,
    Default = 2.4,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(val)
        Hub.Farm.Distance = val
    end
})

FarmGroup:AddToggle("MultiHitToggle", {
    Text = "Multi-Hit / Fast Burst",
    Default = true,
    Tooltip = "Keeps the attack input held so the game chains M1s in bursts. The server still validates every hit, so this only removes dead time between combos (no rejected packets).",
    Callback = function(val)
        Hub.Farm.MultiHit = val
    end
})

FarmGroup:AddSlider("MultiHitCountSlider", {
    Text = "Hits Per Cycle",
    Min = 1,
    Max = 10,
    Default = 4,
    Rounding = 0,
    Tooltip = "How long the M1 burst is held per cycle (0.4s to 1.3s). Longer = less downtime between combos; the game still paces hits at the server-valid rate.",
    Callback = function(val)
        Hub.Farm.MultiHitCount = val
    end
})

FarmGroup:AddToggle("AutoSkillsToggle", {
    Text = "Auto Skills / Spells Rotation",
    Default = true,
    Tooltip = "Automatically casts all unlocked breathing / demon art skills in sequence during combat!",
    Callback = function(val)
        Hub.Farm.AutoSkills = val
    end
})

FarmGroup:AddSlider("SkillIntervalSlider", {
    Text = "Skill Cast Cooldown",
    Min = 0.2,
    Max = 2.5,
    Default = 0.5,
    Rounding = 1,
    Suffix = "s",
    Callback = function(val)
        Hub.Farm.SkillInterval = val
    end
})

FarmGroup:AddToggle("AutoEquipWeaponToggle", {
    Text = "Auto-Equip Katana / Weapon",
    Default = true,
    Tooltip = "Ensures your katana is permanently drawn and equipped so attacks never get disabled!",
    Callback = function(val)
        Hub.Farm.AutoEquipWeapon = val
        if val then EnsureWeaponEquipped() end
    end
})

FarmGroup:AddToggle("HoverBetweenWavesToggle", {
    Text = "Safe Hover Between Waves",
    Default = true,
    Tooltip = "Keeps you safely floating in mid-air with an anchored platform while waiting for the next floor/wave mobs to spawn!",
    Callback = function(val)
        Hub.Farm.HoverBetweenWaves = val
    end
})

FarmGroup:AddToggle("SurvivalRetreatToggle", {
    Text = "Survival Retreat (Last Life)",
    Default = true,
    Tooltip = "When you are on your last life (or under 30% HP), levitates out of enemy reach for a few seconds instead of trading your last heart. Helps you survive many more waves.",
    Callback = function(val)
        Hub.Farm.SurvivalRetreat = val
        if not val then Hub.RetreatUntil = nil end
    end
})

-- 2. Right Group 1: Dungeon Live Status & Controls
local StatusGroup = DungeonTab:AddGroup("Dungeon Live Status", "Right")
local floorLabel = StatusGroup:AddLabel("Current Floor: Floor 1")
local enemiesLabel = StatusGroup:AddLabel("Enemies Left: 0")
local timerLabel = StatusGroup:AddLabel("Timer: --:--")
local livesLabel = StatusGroup:AddLabel("Lives: -")
local itemLabel = StatusGroup:AddLabel("Item farm: off")
local targetLabel = StatusGroup:AddLabel("Target: None")

StatusGroup:AddButton("Loot All Chests & Drops Now", {
    Accent = true,
    Callback = function()
        CollectDungeonChestsAndDrops()
    end
})

StatusGroup:AddButton("Spend Points on Ouwigahara Chest Now", {
    Callback = function()
        task.spawn(function()
            Hub.IsSpendingChestPoints = false
            CheckAndAutoSpendChests()
        end)
    end
})

StatusGroup:AddButton("Ready Up For Dungeon Now", {
    Callback = function()
        task.spawn(function()
            CheckAutoReadyUp()
        end)
    end
})

-- 3. Right Group 2: Dungeon QoL & Auto Automation
local QoLGroup = DungeonTab:AddGroup("Automation & QoL", "Right")

QoLGroup:AddToggle("AutoPickCardToggle", {
    Text = "Auto Pick Cards (Priority)",
    Default = true,
    Tooltip = "Automatically evaluates and selects the best offer card as soon as they appear based on priority weights!",
    Callback = function(val)
        Hub.Dungeon.AutoPickCard = val
        if val then CheckAndAutoPickCard() end
    end
})

QoLGroup:AddToggle("AutoBuyChestsToggle", {
    Text = "Auto Buy Chests (>= 30k pts)",
    Default = true,
    Tooltip = "Automatically spends accumulated points on Ouwigahara Chests when finished or >= 30,000 pts!",
    Callback = function(val)
        Hub.Dungeon.AutoBuyChests = val
    end
})

QoLGroup:AddSlider("ChestThresholdSlider", {
    Text = "Chest Spend Threshold",
    Min = 30000,
    Max = 150000,
    Default = 30000,
    Rounding = 0,
    Suffix = " pts",
    Callback = function(val)
        Hub.Dungeon.ChestThreshold = val
    end
})

QoLGroup:AddToggle("AutoSkipBreakToggle", {
    Text = "Auto Skip Wave Break",
    Default = true,
    Tooltip = "Votes to skip the break between waves automatically, so floors chain much faster!",
    Callback = function(val)
        Hub.Dungeon.AutoSkipBreak = val
    end
})

QoLGroup:AddToggle("AutoReadyUpToggle", {
    Text = "Auto Ready Up / Loop Next Run",
    Default = true,
    Tooltip = "Automatically interacts with the StartPad when returning to the lobby so you can overnight farm indefinitely!",
    Callback = function(val)
        Hub.Dungeon.AutoReadyUp = val
    end
})

QoLGroup:AddToggle("AutoLeaveShopsToggle", {
    Text = "Auto Leave Shops (End of Run)",
    Default = true,
    Tooltip = "After a run ends you are sent to the shops area, which has no Ready Pad. This opens every end-of-run chest first, then lets Auto Buy Chests run, then takes the Leave Pad so you can queue again.",
    Callback = function(val)
        Hub.Dungeon.AutoLeaveShops = val
        if not val then Hub.ShopsSeenAt = nil end
    end
})

QoLGroup:AddToggle("AutoRejoinToggle", {
    Text = "Auto Rejoin Dungeon (Sleep Loop)",
    Default = true,
    Tooltip = "Uses queue_on_teleport: when leaving the shops it queues a bootstrap that finds the Ouwigahara portal in the main world, enters it, and re-queues this hub so the next run starts automatically. Perfect for overnight farming.",
    Callback = function(val)
        Hub.Dungeon.AutoRejoin = val
    end
})

local farmItemValues = BuildFarmItemList()

QoLGroup:AddDropdown("TargetItemDropdown", {
    Text = "Farm Until Item",
    Values = farmItemValues,
    Default = nil,
    Placeholder = "Select an item...",
    Tooltip = "List = shop items + required craft materials + base materials + everything you've discovered. Scans your ENTIRE inventory (equipped weapon, toolbar, accessories) and stops as soon as you gain +1.",
    Callback = function(val)
        Hub.Dungeon.TargetItem = tostring(val or "")
        Hub.TargetItemBaseline = nil
        Hub.TargetItemFound = false
        -- Selecting a target automatically enables surveillance
        if Hub.Dungeon.TargetItem ~= "" and not Hub.Dungeon.FarmUntilItem then
            Hub.Dungeon.FarmUntilItem = true
            pcall(function()
                local obj = Kyoka.Options and Kyoka.Options.FarmUntilItemToggle
                if obj and obj.Set then obj:Set(true, true) end
            end)
        end
    end
})

QoLGroup:AddToggle("FarmUntilItemToggle", {
    Text = "Farm Until Item (stop when obtained)",
    Default = false,
    Tooltip = "Enables the target item watch. When the item shows up in your inventory: loud ping + notification, and all automation stops (unless Stop When Obtained is off).",
    Callback = function(val)
        Hub.Dungeon.FarmUntilItem = val
        Hub.TargetItemBaseline = nil
        Hub.TargetItemFound = false
        if val and Hub.Dungeon.TargetItem == "" then
            Kyoka:Notify({
                Title = "Farm Until Item",
                Content = "Select an item from the 'Farm Until Item' dropdown first (search enabled).",
                Type = "info",
                Duration = 5
            })
        end
    end
})

QoLGroup:AddToggle("StopWhenItemToggle", {
    Text = "Stop Automation When Obtained",
    Default = true,
    Tooltip = "When the target item drops: disables Auto Farm / Auto Ready Up / Auto Leave Shops and frees your character (the hub UI stays open).",
    Callback = function(val)
        Hub.Dungeon.StopWhenItemObtained = val
    end
})

QoLGroup:AddToggle("AutoChestsToggle", {
    Text = "Auto Collect Dungeon Chests",
    Default = true,
    Tooltip = "Automatically loots all chest drops when an area or boss is cleared!",
    Callback = function(val)
        Hub.Farm.AutoCollectChests = val
    end
})

QoLGroup:AddToggle("AutoLootToggle", {
    Text = "Auto Collect Loot & Drops",
    Default = true,
    Tooltip = "Vacuums up all dropped items, materials and coins!",
    Callback = function(val)
        Hub.Farm.AutoCollectLoot = val
    end
})

-- 4. Right Group 3: Card Priorities
local CardPrioGroup = DungeonTab:AddGroup("Card Priorities (1 - 10 Scale)", "Right")

-- Défauts "dégâts d'abord" (la survie est gérée par le boost d'urgence auto).
-- Modifiable via les sliders. Les cartes Event/Stat sont affinées par mots-clés.
local cardTypes = {
    { Name = "Skill", Label = "New Skills", Default = 10 },
    { Name = "Weapon", Label = "Weapon Upgrades", Default = 10 },
    { Name = "Stat", Label = "Stat Boosts", Default = 9 },
    { Name = "Forge", Label = "Forge Upgrades", Default = 8 },
    { Name = "ExtraLife", Label = "Extra Lives", Default = 7 },
    { Name = "Revive", Label = "Revive", Default = 7 },
    { Name = "Heal", Label = "Heals & Restores", Default = 7 },
    { Name = "Potion", Label = "Potions & Elixirs", Default = 7 },
    { Name = "Clan", Label = "Clan Rolls", Default = 7 },
    { Name = "AscendClan", Label = "Ascend Clan", Default = 7 },
    { Name = "Event", Label = "Events & Challenges", Default = 6 },
    { Name = "Points", Label = "Run Points / Trophies", Default = 6 },
    { Name = "Fortune", Label = "Fortune (Drop Rate)", Default = 6 },
    { Name = "SkillSwap", Label = "Skill Swap", Default = 6 },
    { Name = "Trade", Label = "Trader Offers", Default = 4 },
    { Name = "Skip", Label = "Skip Floor", Default = 3 },
    { Name = "SkipFloor", Label = "Skip Floor (alt)", Default = 3 },
    { Name = "Reroll", Label = "Rerolls", Default = 2 },
    { Name = "SwapMap", Label = "Swap Map", Default = 1 },
}

for _, item in ipairs(cardTypes) do
    CardPrioGroup:AddSlider("Prio_" .. item.Name, {
        Text = item.Label,
        Min = 1,
        Max = 10,
        Default = item.Default,
        Rounding = 0,
        Callback = function(val)
            if Hub.Dungeon and Hub.Dungeon.CardPriorities then
                Hub.Dungeon.CardPriorities[item.Name] = val
            end
        end
    })
end

-- ==================== TAB VISUALS ====================
local VisualsTab = Window:AddTab("Visuals")
local VisualsGroup = VisualsTab:AddGroup("Chams / ESP", "Left")

VisualsGroup:AddToggle("MobESPToggle", {
    Text = "Dungeon Mob ESP",
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
    Text = "Teammate / Player ESP",
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

VisualsGroup:AddToggle("ChestESPToggle", {
    Text = "Chest ESP",
    Default = true,
    Callback = function(val)
        Hub.Visuals.ChestESP = val
    end
}):AddColorPicker("ChestColorPicker", {
    Default = Color3.fromRGB(255, 215, 0),
    Callback = function(c)
        Hub.Visuals.ChestColor = c
    end
})

local VisualsConfigGroup = VisualsTab:AddGroup("ESP Styling", "Right")
VisualsConfigGroup:AddToggle("ESPBoxesToggle", {
    Text = "Full Chams (Highlight)",
    Default = true,
    Callback = function(val)
        Hub.Visuals.ESPBoxes = val
    end
})

-- ==================== TAB MISC ====================
local MiscTab = Window:AddTab("Misc")
local MoveGroup = MiscTab:AddGroup("Movement Controls", "Left")

MoveGroup:AddToggle("CustomSpeedToggle", {
    Text = "Speed Hack",
    Default = false,
    Callback = function(val)
        Hub.Misc.CustomSpeed = val
        if not val then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
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
        if not val then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        pcall(function() part.CanCollide = true end)
                    end
                end
            end
        end
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
    Min = 1.4,
    Max = 3.5,
    Default = 2,
    Rounding = 1,
    Callback = function(s)
        Kyoka:SetScale(s)
    end
})

local SessionGroup = SettingsTab:AddGroup("Session", "Right")
SessionGroup:AddButton("Unload Kyōka Dungeon Hub", {
    Danger = true,
    Callback = function()
        Hub:Destroy()
        Kyoka:Unload()
    end
})

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
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = GetHumanoid()

    if hum and char then
        if Hub.Misc.CustomSpeed then
            hum.WalkSpeed = Hub.Misc.WalkSpeed
        end

        if Hub.Combat.InfStamina then
            local folder = GetMyValuesFolder()
            if folder then
                local st = folder:FindFirstChild("Stamina")
                if st and st:IsA("NumberValue") or (st and st:IsA("IntValue")) then
                    st.Value = 100
                end
                local breath = folder:FindFirstChild("Breath")
                if breath and (breath:IsA("NumberValue") or breath:IsA("IntValue")) then
                    breath.Value = 100
                end
            end
        end
    end
end))

-- 4. Main Dungeon Farm Loop (Cœur d'Exécution)
local lastAttack = 0
local lastChestCheck = 0
local frozenCounter = 0

table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    if not Hub.Alive then return end
    local now = os.clock()

    -- Mise à jour des labels HUD (4x/seconde suffit, pas besoin de 60 fps)
    if (now - (Hub.LastHudAt or 0)) >= 0.25 then
        Hub.LastHudAt = now
        local status = GetDungeonStatus()
        local hearts = LocalPlayer:GetAttribute("Hearts")
        pcall(function()
            if floorLabel then floorLabel:SetText("Current Floor: " .. status.Floor) end
            if enemiesLabel then enemiesLabel:SetText("Enemies Left: " .. status.EnemiesLeft) end
            if timerLabel then timerLabel:SetText("Timer: " .. status.Clock) end
            if livesLabel then livesLabel:SetText("Lives: " .. (hearts ~= nil and tostring(hearts) or "-")) end
            if itemLabel then
                if Hub.Dungeon.FarmUntilItem and Hub.Dungeon.TargetItem ~= "" then
                    local state = Hub.TargetItemFound and "OBTAINED!" or ("x" .. tostring(Hub.TargetItemCurrent or 0) .. " (base " .. tostring(Hub.TargetItemBaseline or 0) .. ")")
                    itemLabel:SetText("Item farm: " .. Hub.Dungeon.TargetItem .. " — " .. state)
                else
                    itemLabel:SetText("Item farm: off")
                end
            end
        end)
    end

    -- Farm jusqu'à un item (vérif ~2x/seconde, indépendant du farm)
    if (now - (Hub.LastItemCheck or 0)) >= 0.5 then
        Hub.LastItemCheck = now
        task.spawn(CheckTargetItem)
    end

    -- Automatisations QoL indépendantes du farm (elles continuent même si Auto Farm est OFF)
    -- Vote skip automatique pendant les pauses entre vagues (accélère énormément les étages)
    if Hub.Dungeon.AutoSkipBreak then
        local waveBreak = workspace:GetAttribute("MinigameWaveBreak")
        if waveBreak ~= nil and (now - (Hub.LastSkipVote or 0)) > 0.5 then
            Hub.LastSkipVote = now
            pcall(function()
                if SignalEvent and SignalEvent.ToServer then
                    SignalEvent.ToServer("OuwigaharaRequest", { action = "Skip" })
                end
            end)
        end
    end

    if Hub.Dungeon.AutoPickCard and (now - Hub.LastCardPick) >= 0.35 then
        task.spawn(CheckAndAutoPickCard)
    end
    if Hub.Dungeon.AutoReadyUp and (now - Hub.LastReadyUpCheck) >= 1.5 then
        Hub.LastReadyUpCheck = now
        task.spawn(CheckAutoReadyUp)
    end
    if Hub.Dungeon.AutoBuyChests and (now - Hub.LastChestShopCheck) >= 1.0 then
        Hub.LastChestShopCheck = now
        task.spawn(CheckAndAutoSpendChests)
    end

    -- Watchdog : ne jamais rester bloqué sur un flag d'action
    if Hub.IsSpendingChestPoints and Hub.SpendStartedAt and (now - Hub.SpendStartedAt) > 25 then
        Hub.IsSpendingChestPoints = false
    end
    if Hub.IsReadyingUp and Hub.ReadyStartedAt and (now - Hub.ReadyStartedAt) > 15 then
        Hub.IsReadyingUp = false
    end
    if Hub.IsCollectingLoot and Hub.LootStartedAt and (now - Hub.LootStartedAt) > 25 then
        Hub.IsCollectingLoot = false
    end

    if Hub.IsReadyingUp then
        ReleaseAttack()
        return
    end
    if not Hub.Farm.AutoFarm or Hub.IsCollectingLoot then
        ReleaseAttack()
        return
    end

    local myRoot = GetRootPart()
    local myHum = GetHumanoid()
    if not myRoot or not myHum or myHum.Health <= 0 then return end

    -- Anti-stun : nettoyage immédiat + évasion en l'air (casse le stun infini des NPC)
    if IsPlayerStunnedOrRagdolled() then
        ForceUnfreezeCharacter()
        -- Une seule évasion par épisode de stun (évite de s'envoler à l'infini)
        if (now - (Hub.LastEscapeAt or 0)) > 1.5 then
            EscapeStun()
            Hub.LastEscapeAt = now
        end
        Hub.LastStunEscape = now
        if not Hub.WasStunned then
            Hub.StunCount = (Hub.StunCount or 0) + 1
            Hub.WasStunned = true
        end
        pcall(function()
            local names = {}
            local u2 = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(LocalPlayer.Name)
            if u2 then
                for _, c in ipairs(u2:GetChildren()) do table.insert(names, c.Name) end
            end
            Hub.LastStunValues = table.concat(names, ",")
            local hum = GetHumanoid()
            Hub.LastStunState = hum and hum:GetState().Name or "?"
        end)
    else
        Hub.WasStunned = false
    end

    -- S'assurer que l'arme est toujours dégainée
    EnsureWeaponEquipped()

    -- Gestion de la cible
    local target = Hub.LockedTarget
    if target then
        if not target.Model or not target.Model.Parent or not target.Humanoid or target.Humanoid.Health <= 0 or not target.Root or not target.Root.Parent then
            if target.Humanoid and (target.Humanoid.Health <= 0 or not target.Model.Parent) then
                Hub.KillCount = (Hub.KillCount or 0) + 1
                Hub.Farm.EffectiveAirHeight = nil -- les attaques portent : retour à la hauteur demandée
                local w = Hub.KillWatch and Hub.KillWatch[target.Model]
                if w then
                    Hub.LastKillTime = math.floor((os.clock() - w.Start) * 100) / 100
                    Hub.KillWatch[target.Model] = nil
                end
            end
            if Hub.KillWatch and target.Model then Hub.KillWatch[target.Model] = nil end
            target = nil
            Hub.LockedTarget = nil
        end
    end

    if not target then
        local mobs = GetAliveDungeonMobs()
        local blacklist = Hub.TargetBlacklist
        if #mobs > 0 then
            for _, m in ipairs(mobs) do
                local until_ = blacklist and blacklist[m.Model]
                if not until_ or now >= until_ then
                    if until_ then blacklist[m.Model] = nil end
                    target = m
                    break
                end
            end
            if target and Hub.Farm.TargetLock then
                Hub.LockedTarget = target
                Hub.KillWatch = Hub.KillWatch or {}
                Hub.KillWatch[target.Model] = { Start = now, LastHP = target.Humanoid.Health, LastHPTime = now }
            end
        end
    end

    Hub.CurrentTarget = target

    -- Survie : sur la dernière vie (ou PV < 30%), on lévite hors de portée
    -- quelques secondes pour casser l'aggro au lieu de mourir bêtement.
    local retreating = false
    if Hub.Farm.SurvivalRetreat and target then
        local hearts = tonumber(LocalPlayer:GetAttribute("Hearts"))
        local hpRatio = myHum.Health / math.max(myHum.MaxHealth, 1)
        local lastLife = (hearts ~= nil and hearts <= 1)
        local low = (lastLife and hpRatio < 0.55) or hpRatio < 0.3
        if low and (now - (Hub.LastRetreatAt or 0)) > 10 then
            Hub.RetreatUntil = now + 4
            Hub.LastRetreatAt = now
        end
        retreating = Hub.RetreatUntil ~= nil and now < Hub.RetreatUntil
    end

    if target and target.Root and target.Humanoid and target.Humanoid.Health > 0 then
        Hub.SafeHoverCFrame = nil
        pcall(function()
            if targetLabel then
                targetLabel:SetText("Target: " .. target.Name .. " [" .. math.floor(target.Humanoid.Health) .. "/" .. math.floor(target.Humanoid.MaxHealth) .. "]")
            end
        end)

        local mobRoot = target.Root
        local mobPos = mobRoot.Position
        local targetCFrame

        local offset = Hub.Farm.HeightOffset or 2.4
        if Hub.Farm.SafeMode == "Sky" then
            -- Farm en l'air : la hitbox serveur descend d'environ 9 studs sous le
            -- personnage, donc on reste juste assez haut pour toucher (6 par défaut)
            -- tout en étant hors de portée de la plupart des grabs.
            local airHeight = Hub.Farm.EffectiveAirHeight or Hub.Farm.AirHeight or 6
            if retreating then airHeight = airHeight + 14 end
            local targetPos = mobPos + Vector3.new(0, airHeight, 0)
            targetCFrame = CFrame.lookAt(targetPos, mobPos)
        elseif Hub.Farm.SafeMode == "Overhead" then
            -- Maintien vertical stable au-dessus du monstre orienté droit vers le sol
            local look = mobRoot.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(0, 0, 1) else flatLook = flatLook.Unit end
            local targetPos = mobPos + Vector3.new(0, offset, 0)
            targetCFrame = CFrame.lookAt(targetPos, targetPos + flatLook) * CFrame.Angles(-math.rad(25), 0, 0)
        else
            local look = mobRoot.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude < 0.01 then flatLook = Vector3.new(0, 0, 1) else flatLook = flatLook.Unit end
            local targetPos = mobPos + (flatLook * (Hub.Farm.Distance or 2.4))
            targetCFrame = CFrame.lookAt(targetPos, mobPos)
        end

        myRoot.CFrame = targetCFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero

        -- Pas de plateforme pendant le combat : une dalle invisible de 20x20
        -- posée sous les mobs les bloquait/faisait glitcher leurs déplacements.
        RemoveFarmPlatform()

        -- Auto Attack : chaîne M1 continue, combo + cooldown gérés par le jeu
        local attackCooldown = Hub.Farm.InstantKill and 0.1 or 0.3
        if Hub.Farm.AutoM1 and not retreating and (now - lastAttack) >= attackCooldown then
            lastAttack = now
            PerformAttack(Hub.Farm.MultiHitCount, target)
        elseif retreating then
            ReleaseAttack()
        end

        -- Auto Skills Rotation
        if Hub.Farm.AutoSkills and not retreating then
            CastAvailableSkill()
        end

        -- Chien de garde : si la vie de la cible ne bouge plus du tout, on change.
        -- Fenêtres larges (> 2s) pour ne pas blacklist un mob à cause du temps
        -- mort normal du combo final (1.65s) ou d'un cast de skill.
        local watch = Hub.KillWatch and Hub.KillWatch[target.Model]
        if watch then
            local hp = target.Humanoid.Health
            if hp < watch.LastHP then
                watch.LastHP = hp
                watch.LastHPTime = now
            end
            if (now - watch.Start) > 2.5 and (now - watch.LastHPTime) > 2.2 then
                Hub.TargetBlacklist = Hub.TargetBlacklist or {}
                Hub.TargetBlacklist[target.Model] = now + 2.5
                Hub.KillWatch[target.Model] = nil
                Hub.LockedTarget = nil
                -- Les coups ne portent pas (trop haut / mauvais angle) : on descend
                -- d'un cran, sans jamais passer sous 4 studs (hitbox serveur).
                local wanted = Hub.Farm.AirHeight or 6
                Hub.Farm.EffectiveAirHeight = math.max(4, math.min(Hub.Farm.EffectiveAirHeight or wanted, wanted) - 1)
            end
        end
    else
        ReleaseAttack()
        pcall(function()
            if targetLabel then targetLabel:SetText("Target: Waiting for wave / loot...") end
        end)

        -- Run en cours mais hors du donjon (TP raté) : on rejoint la map nous-mêmes
        local inRunNow = workspace:GetAttribute("MinigameState") ~= "Lobby"
        if inRunNow and (now - (Hub.LastMobSeenAt or 0)) > 5 and (now - (Hub.LastDungeonTp or 0)) > 6 then
            EnsureInsideDungeon(myRoot)
        end

        -- Vérifier et looter les coffres / drops sans restriction de distance
        -- (uniquement en donjon et étage réellement nettoyé : on ne se pose jamais au sol pendant une vague)
        local enemiesLeft = tonumber(workspace:GetAttribute("MinigameEnemiesLeft"))
        local mgState = workspace:GetAttribute("MinigameState")
        local inLobby = mgState == "Lobby"
        local cleared = (enemiesLeft ~= nil and enemiesLeft <= 0) or mgState == "Ended"
        -- Si le compteur n'est pas encore répliqué, on attend 4s sans aucun mob vu avant de considérer l'étage fini
        local quiet = (enemiesLeft == nil) and ((now - (Hub.LastMobSeenAt or 0)) > 4)
        local canLoot = (not inLobby) and (cleared or quiet)
        if canLoot and not Hub.IsSpendingChestPoints and (now - lastChestCheck) >= 0.5 and (Hub.Farm.AutoCollectChests or Hub.Farm.AutoCollectLoot) then
            lastChestCheck = now
            -- Dans un thread à part : la collecte contient des attentes (jusqu'à
            -- plusieurs secondes) qui figeaient toute la boucle de farm.
            task.spawn(CollectDungeonChestsAndDrops)
        end

        -- Maintenir une lévitation sécurisée au-dessus de l'arène (uniquement en donjon)
        -- Recalculée en continu sur la position réelle : jamais de CFrame "collant" qui
        -- te ramène en arrière quand le jeu te téléporte (entrée de donjon, etc.)
        local inRun = workspace:GetAttribute("MinigameState") ~= "Lobby"
        if Hub.Farm.HoverBetweenWaves and inRun and not Hub.IsCollectingLoot and not Hub.IsSpendingChestPoints then
            local baseY = myRoot.Position.Y
            local groundY = nil
            pcall(function()
                local filter = { LocalPlayer.Character }
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj.Name == "KyokaDungeonPlatform" then table.insert(filter, obj) end
                end
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = filter
                local hit = workspace:Raycast(myRoot.Position, Vector3.new(0, -600, 0), params)
                if hit then groundY = hit.Position.Y end
            end)
            if groundY then
                if (baseY - groundY) < 10 then
                    baseY = groundY + 12
                elseif (baseY - groundY) > 40 then
                    baseY = groundY + 14
                end
            end
            local hoverCF = CFrame.new(myRoot.Position.X, baseY, myRoot.Position.Z)
            Hub.SafeHoverCFrame = hoverCF
            myRoot.CFrame = hoverCF
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            EnsureFarmPlatform(hoverCF)
        else
            Hub.SafeHoverCFrame = nil
            RemoveFarmPlatform()
        end
    end

end))

-- Écoute proactive des offres de cartes dès leur apparition
table.insert(Hub.Connections, LocalPlayer.ChildAdded:Connect(function(child)
    if child.Name == "OuwigaharaOffers" then
        task.wait(0.12)
        task.spawn(CheckAndAutoPickCard)
    end
end))

-- 5. Visuals (Chams / Highlights ESP)
local function UpdateDungeonESP()
    for inst, hl in pairs(Hub.ESPHighlights) do
        if not inst or not inst.Parent then
            pcall(function() hl:Destroy() end)
            Hub.ESPHighlights[inst] = nil
        end
    end

    -- Mob ESP
    if Hub.Visuals.MobESP then
        local mobs = GetAliveDungeonMobs()
        for _, mob in ipairs(mobs) do
            local model = mob.Model
            if not Hub.ESPHighlights[model] and Hub.Visuals.ESPBoxes then
                local hl = Instance.new("Highlight")
                hl.Name = "KyokaDungeonMobESP"
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
            if hl.Name == "KyokaDungeonMobESP" then hl.Enabled = false end
        end
    end

    -- Player / Teammate ESP
    if Hub.Visuals.PlayerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                if not Hub.ESPHighlights[char] and Hub.Visuals.ESPBoxes then
                    local hl = Instance.new("Highlight")
                    hl.Name = "KyokaTeammateESP"
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
            if hl.Name == "KyokaTeammateESP" then hl.Enabled = false end
        end
    end

    -- Chest ESP
    if Hub.Visuals.ChestESP then
        local cFolder = Workspace:FindFirstChild("Chests")
        if cFolder then
            for _, chest in ipairs(cFolder:GetChildren()) do
                if not Hub.ESPHighlights[chest] and Hub.Visuals.ESPBoxes then
                    local hl = Instance.new("Highlight")
                    hl.Name = "KyokaChestESP"
                    hl.Adornee = chest
                    hl.FillColor = Hub.Visuals.ChestColor
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
                    hl.Parent = chest
                    Hub.ESPHighlights[chest] = hl
                elseif Hub.ESPHighlights[chest] then
                    Hub.ESPHighlights[chest].Enabled = Hub.Visuals.ESPBoxes
                    Hub.ESPHighlights[chest].FillColor = Hub.Visuals.ChestColor
                end
            end
        end
    else
        for inst, hl in pairs(Hub.ESPHighlights) do
            if hl.Name == "KyokaChestESP" then hl.Enabled = false end
        end
    end
end

-- ESP rafraîchi ~8x/seconde (inutile de reconstruire les Highlights à 60 fps)
local lastESPUpdate = 0
table.insert(Hub.Connections, RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if (now - lastESPUpdate) < 0.12 then return end
    lastESPUpdate = now
    UpdateDungeonESP()
end))

-- Nettoyage global
function Hub:Destroy()
    Hub.Alive = false

    ReleaseAttack()

    for _, conn in ipairs(Hub.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Hub.Connections)

    for _, hl in pairs(Hub.ESPHighlights) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(Hub.ESPHighlights)

    RemoveFarmPlatform()

    pcall(function()
        if Kyoka and Kyoka.Unload then Kyoka:Unload() end
    end)

    _G.SlayersDungeonKyokaHub = nil
end

Kyoka:Notify({
    Title = "Kyōka Dungeon Hub",
    Content = "Slayers 2 Dungeon Hub Loaded (Auto Farm Mobs Active)!",
    Type = "success",
    Duration = 5
})

--[[NW TELEMETRY (slayers2_dungeon/free) : reporte chargement + heartbeat vers /api/report
(anti-tamper : hash du module calculé par le loader + HWID + build). Best effort
silencieux : ne casse jamais le hub. Instalé par outil, ne pas éditer à la main.]]
do
if getgenv and getgenv().__NW_TM_slayers2_dungeon then return end
if getgenv then getgenv().__NW_TM_slayers2_dungeon = true end
local NW_GAME, NW_TIER = "slayers2_dungeon", "free"
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
