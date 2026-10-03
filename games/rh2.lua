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

-- Global Luau unpack compatibility
if not unpack then getgenv().unpack = table.unpack if _G then _G.unpack = table.unpack end end

-- Free / VIP tier (injected by deliver.js watermark for served copies; veil convention)
local _tierEnv = (type(getgenv) == "function" and getgenv()) or _G or {}
local IsFreeTier = (_tierEnv.__NW_IS_FREE == true) or (_tierEnv.__NW_TIER == "Free") or (_tierEnv.SCRIPT_KEY == "free") or (_tierEnv.FORCE_FREE == true) or (_tierEnv.FREE == true)

-- =====================================================================
-- NW HUB | RH2: THE JOURNEY EDITION — KYOKA UI PORT (V1.1.0 ENGLISH)
-- =====================================================================

-- Pre-unload existing active instance
if getgenv().RH2_UnloadFunction then
	pcall(getgenv().RH2_UnloadFunction)
	task.wait(0.15)
end

getgenv().RH2_Unloaded = false

local Players               = game:GetService("Players")
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local RunService            = game:GetService("RunService")
local CoreGui               = game:GetService("CoreGui")
local UserInputService      = game:GetService("UserInputService")
local VirtualUser           = game:GetService("VirtualUser")
local VirtualInputManager   = game:GetService("VirtualInputManager")
local Stats                 = game:GetService("Stats")
local HttpService           = game:GetService("HttpService")
local TweenService          = game:GetService("TweenService")
local GuiService            = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- =====================================================================
-- 1. KYOKA UI LIBRARY (V1.0.0 — KYOKA SUIGETSU THEME)
-- =====================================================================

-- =====================================================================
-- 1. KYOKA UI LIBRARY (V1.0.0 — KYOKA SUIGETSU THEME, VESPER-COMPAT API)
-- =====================================================================

local Vesper = (function()
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
-- Palette « Kyōka Suigetsu » : recherche globale (Ctrl+K)
--
-- La recherche de la fenêtre ne filtre que la page affichée. La palette,
-- elle, indexe TOUS les onglets, toutes les pages, tous les flags, et
-- porte le contrôle vivant dans la ligne de résultat : on bascule, on
-- fait glisser, on choisit sans quitter la palette.
--
-- L'index n'est pas reconstruit : Library.Options associe déjà chaque
-- flag à son objet (:Set / :Get). On enveloppe les méthodes Elements
-- pour retenir en plus le chemin (onglet › page › groupe) et la ligne.
--=====================================================================

-- Portée propre : le chunk principal frôle déjà la limite de locales de Luau.
;(function()

local P = {
	Entries  = {},   -- tout ce qui est indexé
	Commands = {},   -- Kyoka:AddCommand
	Pinned   = {},   -- flags épinglés (requête vide)
	Recent   = {},   -- derniers utilisés
	Rows     = {},   -- lignes affichées
	Results  = {},
	Index    = 1,
	Shown    = false,
}

Library.Palette        = P
Library.PaletteKey     = Enum.KeyCode.K
Library.PaletteEnabled = true

--=====================================================================
-- Indexation : on enveloppe les fabriques d'éléments
--=====================================================================

local KINDS = {
	AddToggle      = "toggle",
	AddSlider      = "slider",
	AddDropdown    = "dropdown",
	AddKeybind     = "keybind",
	AddColorPicker = "color",
	AddTextbox     = "textbox",
	AddButton      = "button",
}

for name, kind in pairs(KINDS) do
	local orig = Elements[name]
	if orig then
		Elements[name] = function(self, a, b, ...)
			local before = (self.Rows and #self.Rows) or 0
			local obj = orig(self, a, b, ...)
			local opts = (type(b) == "table" and b) or (type(a) == "table" and a) or {}
			local text
			if kind == "button" then
				text = (type(a) == "string" and a) or opts.Text or "Button"
			else
				text = opts.Text or opts.Name or (type(a) == "string" and a) or kind
			end
			local tracked = self.Rows and self.Rows[before + 1]
			table.insert(P.Entries, {
				Kind     = kind,
				Text     = tostring(text),
				Obj      = obj,
				Group    = self,
				Row      = tracked and tracked.Frame or nil,
				Flag     = (type(obj) == "table" and obj.Flag) or (type(a) == "string" and a) or nil,
				Min      = opts.Min,
				Max      = opts.Max,
				Rounding = opts.Rounding,
				Suffix   = opts.Suffix,
				Values   = opts.Values,
				Multi    = opts.Multi,
				Callback = opts.Callback,
			})
			return obj
		end
	end
end

local function PathOf(e)
	if e.Kind == "command" then return "Command" end
	local g    = e.Group
	local page = g and g.Page
	local tab  = page and page.Tab
	local parts = {}
	if tab and tab.Name then table.insert(parts, tab.Name) end
	if page and page.Name then table.insert(parts, page.Name) end
	if g and g.Title then table.insert(parts, g.Title.Text) end
	return table.concat(parts, " › ")
end

--=====================================================================
-- Correspondance : sous-chaîne d'abord, sous-séquence ensuite
--=====================================================================

local function Score(hay, q)
	if q == "" then return 0 end
	local i = string.find(hay, q, 1, true)
	if i then return 1000 - i end
	local pos, gaps = 0, 0
	for c = 1, #q do
		local at = string.find(hay, string.sub(q, c, c), pos + 1, true)
		if not at then return nil end
		gaps = gaps + (at - pos - 1)
		pos = at
	end
	return 400 - gaps
end

local function Highlight(text, q)
	if q == "" then return text end
	local low = string.lower(text)
	local i, j = string.find(low, q, 1, true)
	if not i then return text end
	local c = Theme.Accent
	return string.sub(text, 1, i - 1)
		.. string.format('<font color="rgb(%d,%d,%d)">', c.R * 255, c.G * 255, c.B * 255)
		.. string.sub(text, i, j) .. "</font>" .. string.sub(text, j + 1)
end

--=====================================================================
-- Valeur courante, pour l'aperçu de droite
--=====================================================================

local function ValueOf(e)
	local obj = e.Obj
	if type(obj) ~= "table" then return nil end
	local v = obj.Value
	if e.Kind == "slider" then
		return tostring(Round(v or 0, e.Rounding or 0)) .. (e.Suffix or "")
	elseif e.Kind == "dropdown" then
		if type(v) == "table" then
			local picked = {}
			for key, on in pairs(v) do
				if on then table.insert(picked, tostring(key)) end
			end
			table.sort(picked)
			if #picked == 0 then return "—" end
			if #picked <= 2 then return table.concat(picked, ", ") end
			return picked[1] .. " +" .. (#picked - 1)
		end
		return tostring(v or "—")
	elseif e.Kind == "keybind" then
		local k = type(v) == "table" and v.Key or v
		if typeof(k) == "EnumItem" then return k.Name end
		return k and tostring(k) or "—"
	elseif e.Kind == "textbox" then
		local s = tostring(v or "")
		return #s > 14 and (string.sub(s, 1, 13) .. "…") or (s ~= "" and s or "—")
	end
	return nil
end

--=====================================================================
-- Interface
--=====================================================================

local scrim = New("TextButton", {
	Name = "PaletteScrim",
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
	ZIndex = 700,
	Parent = ScreenGui,
})
Library:Register(scrim, { BackgroundColor3 = "Background" })

local panel = New("Frame", {
	Name = "Palette",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.13, 0),
	Size = UDim2.fromOffset(540, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 702,
	Parent = ScreenGui,
})
Scalable(panel)

local plate = New("Frame", {
	Name = "Plate",
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 702,
	Parent = panel,
})
Library:Register(plate, { BackgroundColor3 = "Panel" })
Corner(plate, 10)
local plateStroke = Stroke(plate, "Border")
List(plate, 0, Enum.FillDirection.Vertical)

-- Bandeau : le liseré qui s'allume au-dessus, comme une lame tirée.
local edge = New("Frame", {
	Name = "Edge",
	Size = UDim2.new(1, 0, 0, 1),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.new(1, 1, 1),
	LayoutOrder = 0,
	ZIndex = 706,
	Parent = plate,
})
AccentGradient(edge, function() return Seq({ Theme.Accent, Theme.Accent2, Theme.Accent }) end, 0,
	{ { 0, 1 }, { 0.5, 0 }, { 1, 1 } })

local header = New("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	LayoutOrder = 1,
	ZIndex = 703,
	Parent = plate,
})
Padding(header, 0, 0, 14, 14)

local brand = Label(header, "KYOKA SUIGETSU", 9.5, "Glass", Enum.FontWeight.Bold)
brand.ZIndex = 704

local counter = MonoLabel(header, "", 9.5, "TextDim")
counter.TextXAlignment = Enum.TextXAlignment.Right
counter.ZIndex = 704

-- Ligne de saisie
local queryRow = New("Frame", {
	Name = "Query",
	Size = UDim2.new(1, 0, 0, 42),
	BackgroundTransparency = 1,
	LayoutOrder = 2,
	ZIndex = 703,
	Parent = plate,
})
Padding(queryRow, 0, 0, 14, 12)

local glass = New("Frame", {
	Name = "Glass",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 0, 0.5, 0),
	Size = UDim2.fromOffset(12, 12),
	BackgroundTransparency = 1,
	ZIndex = 704,
	Parent = queryRow,
})
local ring = New("Frame", {
	Size = UDim2.fromOffset(11, 11),
	BackgroundTransparency = 1,
	ZIndex = 704,
	Parent = glass,
})
Corner(ring, "full")
local ringStroke = New("UIStroke", { Thickness = 1.6, Parent = ring })
Library:Register(ringStroke, { Color = "Accent" })

local box = New("TextBox", {
	Name = "Input",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 24, 0.5, 0),
	Size = UDim2.new(1, -74, 1, 0),
	BackgroundTransparency = 1,
	Text = "",
	PlaceholderText = "Search every control…",
	ClearTextOnFocus = false,
	FontFace = FontText(Enum.FontWeight.Medium),
	TextSize = TS(16),
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 704,
	Parent = queryRow,
})
Library:Register(box, { TextColor3 = "Text", PlaceholderColor3 = "TextFaint" })

local escChip = New("Frame", {
	Name = "Esc",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, 0, 0.5, 0),
	Size = UDim2.fromOffset(30, 16),
	ZIndex = 704,
	Parent = queryRow,
})
Library:Register(escChip, { BackgroundColor3 = "Element" })
Corner(escChip, 4)
Stroke(escChip, "Border")
local escText = MonoLabel(escChip, "ESC", 9, "TextDim")
escText.TextXAlignment = Enum.TextXAlignment.Center
escText.ZIndex = 705

local rule = New("Frame", {
	Name = "Rule",
	Size = UDim2.new(1, 0, 0, 1),
	BorderSizePixel = 0,
	LayoutOrder = 3,
	ZIndex = 703,
	Parent = plate,
})
Library:Register(rule, { BackgroundColor3 = "BorderSoft" })

local list = New("ScrollingFrame", {
	Name = "Results",
	Size = UDim2.new(1, 0, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Theme.Accent,
	ScrollBarImageTransparency = 0.4,
	LayoutOrder = 4,
	ZIndex = 703,
	Parent = plate,
})
List(list, 2, Enum.FillDirection.Vertical)
Padding(list, 6, 6, 6, 6)

local footer = New("Frame", {
	Name = "Footer",
	Size = UDim2.new(1, 0, 0, 24),
	BorderSizePixel = 0,
	LayoutOrder = 5,
	ZIndex = 703,
	Parent = plate,
})
Library:Register(footer, { BackgroundColor3 = "Panel2" })
Padding(footer, 0, 0, 14, 14)
local hints = Label(footer, "", 9.5, "TextDim")
hints.ZIndex = 704

local function PaintHints()
	local c = Theme.Text
	local key = string.format('<font color="rgb(%d,%d,%d)">', c.R * 255, c.G * 255, c.B * 255)
	hints.Text = key .. "UP DOWN</font> move   " .. key .. "LEFT RIGHT</font> value   "
		.. key .. "ENTER</font> apply   " .. key .. "TAB</font> reflect   " .. key .. "&gt;</font> commands"
end

--=====================================================================
-- Construction d'une ligne
--=====================================================================

local KIND_COLOR = {
	toggle = "Accent", slider = "Accent", dropdown = "Accent",
	keybind = "Accent2", color = "Accent2", textbox = "Accent2",
	button = "Success", command = "Success",
}

local function MakeControl(parent, e)
	local holder = New("Frame", {
		Name = "Control",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 706,
		Parent = parent,
	})

	-- Une Instance n'accepte pas de champ maison : le peintre vit à côté.
	local paint

	if e.Kind == "toggle" then
		local sw = New("Frame", {
			Size = UDim2.fromOffset(28, 14),
			Position = UDim2.new(0, 0, 0.5, -7),
			BorderSizePixel = 0,
			ZIndex = 706,
			Parent = holder,
		})
		Corner(sw, "full")
		local knob = New("Frame", {
			Size = UDim2.fromOffset(10, 10),
			BorderSizePixel = 0,
			ZIndex = 707,
			Parent = sw,
		})
		Corner(knob, "full")
		paint = function()
			local on = e.Obj and e.Obj.Value and true or false
			sw.BackgroundColor3 = on and Theme.Accent or Theme.ElementHover
			knob.BackgroundColor3 = on and Theme.Background or Theme.TextFaint
			knob.Position = on and UDim2.fromOffset(16, 2) or UDim2.fromOffset(2, 2)
		end

	elseif e.Kind == "slider" then
		local track = New("Frame", {
			Size = UDim2.fromOffset(72, 5),
			Position = UDim2.new(0, 0, 0.5, -2),
			BorderSizePixel = 0,
			ZIndex = 706,
			Parent = holder,
		})
		Library:Register(track, { BackgroundColor3 = "ElementHover" })
		Corner(track, "full")
		local fill = New("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 707,
			Parent = track,
		})
		Corner(fill, "full")
		AccentGradient(fill, function() return Seq({ Theme.Accent, Theme.Accent2 }) end)
		local val = MonoLabel(holder, "", 10, "Glass")
		val.Position = UDim2.fromOffset(78, 0)
		val.Size = UDim2.new(0, 44, 1, 0)
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.ZIndex = 706
		paint = function()
			local mn, mx = e.Min or 0, e.Max or 100
			local v = (e.Obj and e.Obj.Value) or mn
			fill.Size = UDim2.fromScale(mx - mn == 0 and 0 or math.clamp((v - mn) / (mx - mn), 0, 1), 1)
			val.Text = ValueOf(e) or ""
		end

	elseif e.Kind == "color" then
		local sw = New("Frame", {
			Size = UDim2.fromOffset(28, 14),
			Position = UDim2.new(0, 0, 0.5, -7),
			BorderSizePixel = 0,
			ZIndex = 706,
			Parent = holder,
		})
		Corner(sw, 4)
		Stroke(sw, "Border")
		paint = function()
			local v = e.Obj and e.Obj.Value
			sw.BackgroundColor3 = typeof(v) == "Color3" and v or Theme.Element
		end

	elseif e.Kind == "button" or e.Kind == "command" then
		local chip = New("Frame", {
			Size = UDim2.fromOffset(0, 16),
			Position = UDim2.new(0, 0, 0.5, -8),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 706,
			Parent = holder,
		})
		Corner(chip, 4)
		Padding(chip, 0, 0, 7, 7)
		local t = MonoLabel(chip, e.Kind == "command" and "ENTER" or "RUN", 9, "Text")
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.AutomaticSize = Enum.AutomaticSize.X
		t.Size = UDim2.new(0, 0, 1, 0)
		t.ZIndex = 707
		paint = function()
			chip.BackgroundColor3 = e.Danger and Theme.Danger or Theme.Accent
			t.TextColor3 = Theme.Background
		end

	else -- dropdown, keybind, textbox
		local chip = New("Frame", {
			Size = UDim2.fromOffset(0, 17),
			Position = UDim2.new(0, 0, 0.5, -8),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 706,
			Parent = holder,
		})
		Library:Register(chip, { BackgroundColor3 = "Element" })
		Corner(chip, 4)
		Stroke(chip, "Border")
		Padding(chip, 0, 0, 7, 7)
		local t = Label(chip, "", 10.5, "Text")
		t.AutomaticSize = Enum.AutomaticSize.X
		t.Size = UDim2.new(0, 0, 1, 0)
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.ZIndex = 707
		paint = function() t.Text = ValueOf(e) or "—" end
	end

	if paint then paint() end
	return holder, paint
end

local function MakeRow(e, q, i)
	local row = New("Frame", {
		Name = "PRow",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		LayoutOrder = i,
		ZIndex = 704,
		Parent = list,
	})

	local bg = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 704,
		Parent = row,
	})
	Library:Register(bg, { BackgroundColor3 = "ElementHover" })
	Corner(bg, 7)

	local bar = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(2, 24),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 705,
		Parent = row,
	})
	Library:Register(bar, { BackgroundColor3 = "Accent" })
	Corner(bar, "full")

	local dot = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(7, 7),
		BorderSizePixel = 0,
		ZIndex = 705,
		Parent = row,
	})
	Library:Register(dot, { BackgroundColor3 = KIND_COLOR[e.Kind] or "TextDim" })
	Corner(dot, e.Kind == "toggle" and "full" or 2)

	local title = Label(row, Highlight(e.Text, q), 12.5, "Text", Enum.FontWeight.SemiBold)
	title.Position = UDim2.fromOffset(28, 5)
	title.Size = UDim2.new(1, -170, 0, 16)
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = 705

	local path = Label(row, PathOf(e), 10, "TextDim")
	path.Position = UDim2.fromOffset(28, 21)
	path.Size = UDim2.new(1, -170, 0, 14)
	path.TextTruncate = Enum.TextTruncate.AtEnd
	path.ZIndex = 705

	local control, paint = MakeControl(row, e)
	control.Position = UDim2.new(1, -12, 0.5, 0)

	local hit = Hit(row, "Hit", 708)

	return { Frame = row, Bg = bg, Bar = bar, Title = title, Entry = e, Control = control, Paint = paint, Hit = hit }
end

--=====================================================================
-- Actions
--=====================================================================

local function Remember(e)
	for i = #P.Recent, 1, -1 do
		if P.Recent[i] == e then table.remove(P.Recent, i) end
	end
	table.insert(P.Recent, 1, e)
	while #P.Recent > 6 do table.remove(P.Recent) end
end

local Refresh, Close

local function Pulse(frame)
	local hover = frame and frame:FindFirstChild("Hover")
	if not hover then return end
	hover.BackgroundColor3 = Theme.Accent
	hover.BackgroundTransparency = 0.45
	Tween(hover, 0.9, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
	task.delay(0.95, function()
		if hover.Parent then hover.BackgroundColor3 = Theme.ElementHover end
	end)
end

local function Reflect(e)
	Close()
	local g    = e.Group
	local page = g and g.Page
	local tab  = page and page.Tab
	if Library.Window and not Library.Open and Library.Window.SetOpen then
		Library.Window:SetOpen(true)
	end
	if tab and tab.Select then pcall(function() tab:Select() end) end
	if page and page.Select then pcall(page.Select) end
	task.delay(0.16, function()
		local row = e.Row
		if not row or not row.Parent then return end
		local col = row.Parent
		if col:IsA("ScrollingFrame") then
			local y = row.AbsolutePosition.Y - col.AbsolutePosition.Y + col.CanvasPosition.Y
			col.CanvasPosition = Vector2.new(0, math.max(0, y - 30))
		end
		Pulse(row)
	end)
end

local function Step(e, dir)
	local obj = e.Obj
	if type(obj) ~= "table" or not obj.Set then return end
	if e.Kind == "slider" then
		local mn, mx = e.Min or 0, e.Max or 100
		local step = (mx - mn) / 20
		if (e.Rounding or 0) == 0 then step = math.max(1, math.floor(step + 0.5)) end
		obj:Set((obj.Value or mn) + dir * step)
	elseif e.Kind == "dropdown" and not e.Multi then
		local values = obj.Values or e.Values
		if type(values) ~= "table" or #values == 0 then return end
		local at = 1
		for i, v in ipairs(values) do
			if v == obj.Value then at = i break end
		end
		obj:Set(values[((at - 1 + dir) % #values) + 1])
	elseif e.Kind == "toggle" then
		obj:Set(dir > 0)
	else
		return
	end
	Remember(e)
	Refresh(true)
end

local function Activate(e)
	if e.Kind == "command" then
		Close()
		if e.Run then task.spawn(e.Run) end
		return
	elseif e.Kind == "button" then
		Close()
		if e.Callback then task.spawn(e.Callback) end
		return
	elseif e.Kind == "toggle" then
		if e.Obj and e.Obj.Set then e.Obj:Set(not e.Obj.Value) end
	elseif e.Kind == "dropdown" and not e.Multi then
		Step(e, 1)
		return
	else
		Reflect(e)
		Remember(e)
		return
	end
	Remember(e)
	Refresh(true)
	Library:PlaySound("Toggle")
end

--=====================================================================
-- Rendu
--=====================================================================

local function Collect(raw)
	local q = string.lower(raw or "")
	local onlyCommands = string.sub(q, 1, 1) == ">"
	if onlyCommands then q = string.gsub(string.sub(q, 2), "^%s+", "") end

	local out = {}

	if q == "" and not onlyCommands then
		for _, flag in ipairs(P.Pinned) do
			for _, e in ipairs(P.Entries) do
				if e.Flag == flag then table.insert(out, e) break end
			end
		end
		for _, e in ipairs(P.Recent) do
			local dup = false
			for _, o in ipairs(out) do if o == e then dup = true break end end
			if not dup then table.insert(out, e) end
		end
		if #out > 0 then return out, "PINNED · RECENT", q end
	end

	local pool = {}
	if not onlyCommands then
		for _, e in ipairs(P.Entries) do table.insert(pool, e) end
	end
	for _, c in ipairs(P.Commands) do table.insert(pool, c) end

	local scored = {}
	for _, e in ipairs(pool) do
		local s = Score(string.lower(e.Text), q)
		if not s then
			local ps = Score(string.lower(PathOf(e)), q)
			if ps then s = ps - 300 end
		end
		if not s and e.Keywords then
			for _, k in ipairs(e.Keywords) do
				local ks = Score(string.lower(tostring(k)), q)
				if ks then s = ks - 200 break end
			end
		end
		if s then
			if e.Kind == "command" then s = s + 40 end
			table.insert(scored, { E = e, S = s })
		end
	end
	table.sort(scored, function(a, b)
		if a.S == b.S then return a.E.Text < b.E.Text end
		return a.S > b.S
	end)
	for i = 1, math.min(#scored, 40) do table.insert(out, scored[i].E) end
	return out, onlyCommands and "COMMANDS" or (q == "" and "ALL CONTROLS" or "MATCHES"), q
end

local empty

function Refresh(valuesOnly)
	if valuesOnly then
		for _, r in ipairs(P.Rows) do
			if r.Paint then r.Paint() end
		end
		return
	end

	for _, r in ipairs(P.Rows) do r.Frame:Destroy() end
	table.clear(P.Rows)

	local results, caption, q = Collect(box.Text)
	P.Results = results
	P.Index = math.clamp(P.Index, 1, math.max(#results, 1))

	counter.Text = string.format("%d / %d", #results, #P.Entries + #P.Commands)
	brand.Text = caption == "MATCHES" and "KYOKA SUIGETSU" or caption

	if #results == 0 then
		empty.Visible = true
		empty.Text = 'Nothing reflects "' .. box.Text .. '"'
		list.Size = UDim2.new(1, 0, 0, 62)
	else
		empty.Visible = false
		for i, e in ipairs(results) do
			table.insert(P.Rows, MakeRow(e, q, i))
		end
		list.Size = UDim2.new(1, 0, 0, math.min(#results * 42 + 12, 300))
	end

	for i, r in ipairs(P.Rows) do
		local sel = (i == P.Index)
		r.Bg.BackgroundTransparency = sel and 0 or 1
		r.Bar.Visible = sel
		local entry, row = r.Entry, r
		Library:Connect(r.Hit.MouseButton1Click, function()
			P.Index = i
			Refresh()
			Activate(entry)
		end)
		Library:Connect(r.Hit.MouseEnter, function()
			if P.Index ~= i then
				P.Index = i
				for j, rr in ipairs(P.Rows) do
					rr.Bg.BackgroundTransparency = (j == i) and 0 or 1
					rr.Bar.Visible = (j == i)
				end
			end
		end)
		local _ = row
	end
end

empty = Label(list, "", 12, "TextDim")
empty.Position = UDim2.fromOffset(0, 18)
empty.Size = UDim2.new(1, 0, 0, 20)
empty.TextXAlignment = Enum.TextXAlignment.Center
empty.Visible = false
empty.ZIndex = 705

local function Move(dir)
	if #P.Results == 0 then return end
	P.Index = ((P.Index - 1 + dir) % #P.Results) + 1
	for j, rr in ipairs(P.Rows) do
		rr.Bg.BackgroundTransparency = (j == P.Index) and 0 or 1
		rr.Bar.Visible = (j == P.Index)
	end
	local r = P.Rows[P.Index]
	if r then
		local y = r.Frame.AbsolutePosition.Y - list.AbsolutePosition.Y + list.CanvasPosition.Y
		if y < list.CanvasPosition.Y then
			list.CanvasPosition = Vector2.new(0, math.max(0, y - 6))
		elseif y + 42 > list.CanvasPosition.Y + list.AbsoluteSize.Y then
			list.CanvasPosition = Vector2.new(0, y + 42 - list.AbsoluteSize.Y + 6)
		end
	end
end

--=====================================================================
-- Ouverture / fermeture
--=====================================================================

local function Open()
	if P.Shown or not Library.PaletteEnabled or Library.Unloaded then return end
	P.Shown = true
	P.Index = 1
	box.Text = ""
	PaintHints()
	Refresh()

	scrim.Visible = true
	scrim.BackgroundTransparency = 1
	Tween(scrim, 0.18, { BackgroundTransparency = 0.28 })

	panel.Visible = true
	panel.Position = UDim2.new(0.5, 0, 0.13, 18)
	plate.BackgroundTransparency = 1
	Tween(panel, 0.26, { Position = UDim2.new(0.5, 0, 0.13, 0) }, Enum.EasingStyle.Quint)
	Tween(plate, 0.18, { BackgroundTransparency = 0 })
	plateStroke.Color = Theme.Accent
	Tween(plateStroke, 0.5, { Color = Theme.Border })

	if Library.Blur then pcall(FX.GameBlur, true) end
	Library:PlaySound("Open")
	task.defer(function()
		if P.Shown then box:CaptureFocus() end
	end)
end

function Close()
	if not P.Shown then return end
	P.Shown = false
	box:ReleaseFocus()
	Tween(scrim, 0.14, { BackgroundTransparency = 1 })
	Tween(panel, 0.16, { Position = UDim2.new(0.5, 0, 0.13, 12) }, Enum.EasingStyle.Quad)
	Tween(plate, 0.14, { BackgroundTransparency = 1 })
	task.delay(0.17, function()
		if not P.Shown then
			panel.Visible = false
			scrim.Visible = false
		end
	end)
	if Library.Blur then pcall(FX.GameBlur, Library.Open == true) end
end

local function Toggle()
	if P.Shown then Close() else Open() end
end

Library:Connect(scrim.MouseButton1Click, Close)
Library:Connect(box:GetPropertyChangedSignal("Text"), function()
	P.Index = 1
	Refresh()
end)
Library:Connect(box.FocusLost, function(enter)
	if enter and P.Shown then
		local e = P.Results[P.Index]
		if e then Activate(e) end
		task.defer(function() if P.Shown then box:CaptureFocus() end end)
	end
end)

Library:Connect(UserInputService.InputBegan, function(input)
	if Library.Unloaded or not Library.PaletteEnabled then return end
	local k = input.KeyCode

	if k == Library.PaletteKey
		and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
		Toggle()
		return
	end

	if not P.Shown then return end

	if k == Enum.KeyCode.Escape then
		Close()
	elseif k == Enum.KeyCode.Down then
		Move(1)
	elseif k == Enum.KeyCode.Up then
		Move(-1)
	elseif k == Enum.KeyCode.Right then
		local e = P.Results[P.Index]; if e then Step(e, 1) end
	elseif k == Enum.KeyCode.Left then
		local e = P.Results[P.Index]; if e then Step(e, -1) end
	elseif k == Enum.KeyCode.Tab then
		local e = P.Results[P.Index]; if e and e.Kind ~= "command" then Reflect(e) end
	end
end)

--=====================================================================
-- API publique
--=====================================================================

function Library:OpenPalette()   Open()   end
function Library:ClosePalette()  Close()  end
function Library:TogglePalette() Toggle() end

function Library:SetPaletteEnabled(v)
	Library.PaletteEnabled = v and true or false
	if not Library.PaletteEnabled then Close() end
end

function Library:AddCommand(name, opts)
	opts = opts or {}
	local cmd = {
		Kind     = "command",
		Text     = tostring(name),
		Keywords = opts.Keywords,
		Danger   = opts.Danger,
		Run      = opts.Callback or opts.Run or function() end,
	}
	table.insert(P.Commands, cmd)
	return cmd
end

function Library:PinFlag(flag)
	for _, f in ipairs(P.Pinned) do if f == flag then return end end
	table.insert(P.Pinned, flag)
end

function Library:UnpinFlag(flag)
	for i = #P.Pinned, 1, -1 do
		if P.Pinned[i] == flag then table.remove(P.Pinned, i) end
	end
end

end)()

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
local Kyoka = Vesper -- alias (Kyoka UI, same API as Vesper)


-- =====================================================================
-- 2. RH2: THE JOURNEY GAMEPLAY ENGINE & STATE
-- =====================================================================

local DefaultState = {
	AutoGreen        = true,
	SilentAim        = true,
	SilentAimSmooth  = 0.70,
	AntiContest      = true,
	ManualPingOffset = 0,

	GhostSprint      = true,
	SpeedBoost       = true,
	SpeedMultiplier  = 1.45,

	AutoGuard        = false,
	AutoGuardRange   = 12,
	AutoSteal        = true,
	StealAuraRange   = 12,
	StealCooldown    = 0.15,
	StealKeybind     = Enum.KeyCode.F,

	AntiAFK          = true,
	AutoSave         = false,
	ActiveProfile    = "default",

	TotalShots       = 0,
	TotalGreens      = 0,
	TotalSteals      = 0,
	LastAction       = "Idle",
}

local State = table.clone(DefaultState)
getgenv().RH2_State = State

local function GetState() return getgenv().RH2_State or State end
getgenv().RH2_IsFree = IsFreeTier

-- VIP gate: blocks paid features on FREE tier (UI lock + logic enforcement)
local function PaidGate(feature)
	if IsFreeTier then
		Vesper:Notify({ Title = "VIP Only", Content = (feature or "This feature") .. " is VIP-only. Join Discord: discord.gg/Gp2N788WVh", Type = "error" })
		return true
	end
	return false
end

-- NBA Outfit Utilities
local VisualUnlock = {
	OriginalShirt = nil,
	OriginalPants = nil,
	HadOriginalShirt = false,
	HadOriginalPants = false,
	Saved = false,
	Presets = {
		Lakers24 = { Name = "Lakers #24 (Bryant)", Shirt = "rbxassetid://1326466989", Pants = "rbxassetid://1326468758" },
		Bulls23  = { Name = "Bulls #23 (Jordan)", Shirt = "rbxassetid://144076395", Pants = "rbxassetid://144076465" },
		Warriors30 = { Name = "Warriors #30 (Curry)", Shirt = "rbxassetid://298246332", Pants = "rbxassetid://298246401" },
		Celtics0 = { Name = "Celtics #0 (Tatum)", Shirt = "rbxassetid://1212879549", Pants = "rbxassetid://1212879948" },
	}
}

function VisualUnlock.BackupOriginal()
	local char = LocalPlayer.Character
	if not char then return end
	if not VisualUnlock.Saved then
		local shirt = char:FindFirstChildOfClass("Shirt")
		local pants = char:FindFirstChildOfClass("Pants")
		if shirt and shirt.ShirtTemplate ~= "" then
			VisualUnlock.OriginalShirt = shirt.ShirtTemplate
			VisualUnlock.HadOriginalShirt = true
		else
			VisualUnlock.OriginalShirt = nil
			VisualUnlock.HadOriginalShirt = false
		end
		if pants and pants.PantsTemplate ~= "" then
			VisualUnlock.OriginalPants = pants.PantsTemplate
			VisualUnlock.HadOriginalPants = true
		else
			VisualUnlock.OriginalPants = nil
			VisualUnlock.HadOriginalPants = false
		end
		VisualUnlock.Saved = true
	end
end

task.spawn(function()
	task.wait(1)
	VisualUnlock.BackupOriginal()
end)
LocalPlayer.CharacterAdded:Connect(function()
	VisualUnlock.Saved = false
	VisualUnlock.OriginalShirt = nil
	VisualUnlock.OriginalPants = nil
	VisualUnlock.HadOriginalShirt = false
	VisualUnlock.HadOriginalPants = false
	task.wait(1)
	VisualUnlock.BackupOriginal()
end)

function VisualUnlock.Restore()
	if PaidGate("Outfit restore") then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	VisualUnlock.BackupOriginal()
	local shirt = char:FindFirstChildOfClass("Shirt")
	local pants = char:FindFirstChildOfClass("Pants")

	if VisualUnlock.HadOriginalShirt and VisualUnlock.OriginalShirt then
		local s = shirt or Instance.new("Shirt", char)
		s.ShirtTemplate = VisualUnlock.OriginalShirt
	else
		if shirt then shirt:Destroy() end
	end

	if VisualUnlock.HadOriginalPants and VisualUnlock.OriginalPants then
		local p = pants or Instance.new("Pants", char)
		p.PantsTemplate = VisualUnlock.OriginalPants
	else
		if pants then pants:Destroy() end
	end

	Vesper:Notify({ Title = "Outfit", Content = "Original outfit restored", Type = "success" })
	return true
end

function VisualUnlock.ApplyPreset(presetKey)
	if PaidGate("Outfit preset") then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	VisualUnlock.BackupOriginal()
	local preset = VisualUnlock.Presets[presetKey]
	if not preset then return false end

	local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
	local pants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
	shirt.ShirtTemplate = preset.Shirt
	pants.PantsTemplate = preset.Pants

	Vesper:Notify({ Title = "Outfit", Content = "Applied: " .. preset.Name, Type = "success" })
	return true
end

function VisualUnlock.CloneNearestPlayer()
	if PaidGate("Outfit clone") then return false end
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	VisualUnlock.BackupOriginal()

	local myHrp = char.HumanoidRootPart
	local closestPlayer, closestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
			if d < closestDist then
				closestDist = d
				closestPlayer = p
			end
		end
	end

	if not closestPlayer or not closestPlayer.Character then
		Vesper:Notify({ Title = "Error", Content = "No player nearby", Type = "error" })
		return false
	end

	local srcShirt = closestPlayer.Character:FindFirstChildOfClass("Shirt")
	local srcPants = closestPlayer.Character:FindFirstChildOfClass("Pants")
	local myShirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
	local myPants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)

	if srcShirt then myShirt.ShirtTemplate = srcShirt.ShirtTemplate end
	if srcPants then myPants.PantsTemplate = srcPants.PantsTemplate end

	Vesper:Notify({ Title = "Outfit", Content = "Cloned @" .. closestPlayer.Name, Type = "success" })
	return true
end

function VisualUnlock.StealFromPlayerName(targetName)
	if PaidGate("Outfit steal") then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	VisualUnlock.BackupOriginal()

	local target = nil
	local lower = string.lower(targetName or "")
	if lower == "" then return false end

	for _, p in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(p.Name), lower, 1, true) or string.find(string.lower(p.DisplayName), lower, 1, true) then
			target = p
			break
		end
	end

	if not target or not target.Character then
		Vesper:Notify({ Title = "Error", Content = "Player not found", Type = "error" })
		return false
	end

	local srcShirt = target.Character:FindFirstChildOfClass("Shirt")
	local srcPants = target.Character:FindFirstChildOfClass("Pants")
	local myShirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
	local myPants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)

	if srcShirt then myShirt.ShirtTemplate = srcShirt.ShirtTemplate end
	if srcPants then myPants.PantsTemplate = srcPants.PantsTemplate end

	Vesper:Notify({ Title = "Outfit", Content = "Cloned @" .. target.Name, Type = "success" })
	return true
end

-- =====================================================================
-- UNLOCK ALL ENGINE (ANIMATIONS, LOCKER, GAMEPASS, NATIVE MENU)
-- =====================================================================

local UnlockAll = {
	JumpshotList = {
		"Base", "Jumpshot 1", "Jumpshot 2", "Jumpshot 3", "Jumpshot 4", "Jumpshot 5",
		"Jumpshot 6", "Jumpshot 7", "Jumpshot 8", "Jumpshot 9", "Jumpshot 10",
		"Jumpshot 11", "Jumpshot 12", "Jumpshot 13", "Jumpshot 14", "Jumpshot 15",
		"Jumpshot 16", "Jumpshot 17", "Jumpshot 18", "Jumpshot 19", "Jumpshot 20",
		"Jumpshot 21", "Jumpshot 22", "Jumpshot 23", "Jumpshot 24"
	},
	DunkList = {
		"Explosive Windmill Dunks", "Explosive Tomahawk Dunks", "Uber Athletic Tomahawks",
		"Leonardo Ruiz", "Ben Robinson", "Basic One Hand", "Reverse Dunks",
		"Pro Two Hand Dunks", "Reggie West ", "Backscratchers Off One",
		"Big Man Athletic Flushes", "Big Man Flashy Dunks", "Big Man Quick Flushes",
		"Big Man Rim Pull Ups", "Rim Hanging Dunks", "Flashy Rim Hanging Dunks",
		"Highflyer Dunks", "Highlight Reel Dunks", "One Hand 360 Dunks",
		"Leaning Windmill Dunks", "Quick Drops Off One", "Side Arm Tomahawk Dunks",
		"Straight Arm Tomahawks", "Xavier Powers"
	},
	CrossoverList = {
		"KB24", "Chef", "The Beard", "Reaper", "The Fox", "Charlotte's Web",
		"Elite 1", "Elite 2", "Elite 3", "Ice Trey", "Jermery Buckets",
		"Leonardo Ruiz", "Pro 1", "Pro 2", "Pro 3", "Pro 4", "Pro 5",
		"Real", "Tay Beam", "Terry Walker", "Xavier Powers", "Base", "Basic"
	},
	BehindTheBackList = {
		"Blue Arrow", "Breeze", "Cory Errving", "DG10", "Damian Banks ",
		"Derrick Jones", "Elite 1", "Elite 2", "Elite 3", "Elite 4",
		"Golden Boy", "Ice Trey", "Jaay Williams", "L-Train", "Meh Wade",
		"Pro 1", "Pro 2", "Pro 3", "Pro 4", "Reggie West", "Sav Banks", "Xavier Powers", "Base"
	},
	CelebrationList = {
		"KB24 Fist Pump", "Moonwalk", "Griddy", "Agent 0", "Air Guitar",
		"Baby Face Stomp", "Backflip", "Big Shot Bob", "Bow & Arrow",
		"Breakdown", "Bring it.", "Charged Up", "Drop It", "Feelin it",
		"Fireworks", "Flexin", "Follow Through", "Get Off Me", "Hero Kneel",
		"I AM HERE", "IT'S TOO EASY!", "Iced Up", "Party Party", "Robot",
		"Shadow Boxing", "Shuffle", "Smooth", "Sneaky Walk-Off", "SuperHero",
		"The Truth", "Unlimited Void", "Wooaahh", "YUP",
		"AHHHHHH", "Around The World ", "Coffee Grinder", "Coffin", "C’MERE!",
		"Desperado", "Fore!", "GO REL SAN", "Headless", "J Slide",
		"Let Loose ", "Levitate", "Ninja Way", "No Look", "Nonchalant",
		"Nothing", "Peek-A-Boo", "Pop Out", "Popular", "SO LIT",
		"Scuba", "Silly Shake", "So Based", "Stomp Ground", "Stunned",
		"Suns Out Guns Out", "Swoop!", "Take A Bow", "Taking A Break",
		"Ya Done.", "Yippy"
	},
	GreenSoundsList = {
		"None (Disabled)", "SIUUU!", "WHAT THE SIGMA", "Rick Roll", "EXPLOSION!", "FBI Open Up!",
		"Hello There!", "God Did", "KABINK", "Ping", "YEET", "Right Foot Creep",
		"Sin City", "Splash!", "The Dagger", "Wilhelm Scream", "Regular"
	},
	GreenEffectsList = {
		"Zoltraak", "Cleave", "Getsuga", "Black Hole", "Cursed Energy",
		"Future Sight", "Matrix", "Lightning", "Fire", "Rainbow",
		"Black Flame", "Explosion", "Shadow", "Thunder", "Void", "Regular"
	},
	MascotList = {
		"DRACO", "DRACO_OLD", "YETI", "WOLF", "LION", "KNIGHT", "RED PANDA",
		"GRIFFIN", "COUGAR", "RAM", "DONKEY", "INK"
	},
	CuratedTops = {
		"5IVESTAR Anime T-Shirt", "5ivestar Home Jersey", "5ivestar Away Jersey",
		"Astros T-Shirt", "Kings T-Shirt", "BAX Blue Text T-Shirt",
		"White 5IVESTAR Y2K Logo T-Shirt", "Black 5IVESTAR Longsleeve", "Light Blue 5IVESTAR Longsleeve",
		"Purple 5IVESTAR Longsleeve", "BAX Black Rose Zip Up", "Aura Pack Steampunk Cowboy Jacket"
	},
	CuratedBottoms = {
		"Astros Sweatpants", "5ivestar Home Shorts", "5ivestar Away Shorts",
		"Basic Black Sweatpants", "Basic White Shorts", "BAX Black Shorts",
		"BAX White Shorts", "BAX x RH2 Sweatpants", "Atlanta Griffins Jersey",
		"Austin Hornets Jersey", "Baggy Gym Sweatpants", "All White Shorts"
	},

	SelectedJumpshot = "Jumpshot 24",
	SelectedDunk = "Explosive Windmill Dunks",
	SelectedCrossover = "KB24",
	SelectedBehindTheBack = "Blue Arrow",
	SelectedCelebration = "KB24 Fist Pump",
	SelectedGreenSound = "None (Disabled)",
	SelectedGreenEffect = "Zoltraak",
	SelectedTop = "5IVESTAR Anime T-Shirt",
	SelectedBottom = "Astros Sweatpants",
	SelectedMascot = "DRACO",
	BetweenLegsList = {
		"Base", "Cory Errving", "DG10", "Derrick Jones", "Elite 1", "Elite 2",
		"Elite 3", "Elite 4", "Elite 5", "Flash", "Golden Boy", "Jaay Williams",
		"KB24", "Pro 1", "Pro 2", "Pro 3", "Swipa", "Tris"
	},
	HesiList = {
		"Base", "Blue Arrow", "Cory Errving", "Elite 1", "Elite 2", "Elite 3",
		"Elite 4", "Elite 5", "Pro 1", "Pro 2", "Pro 3", "Pro 4",
		"Real", "The Burner", "Tris"
	},
	StepbackList = {
		"Base", "Cory Errving", "Elite 1", "Elite 2", "Jermery Buckets",
		"Nathan Smith", "Pro 1", "Pro 2", "Pro 3", "Wall-Star"
	},
	LayupList = {
		"Base", "Acrobatic", "Circus", "Fundamental", "Jelly", "Layup 1",
		"Layup 2", "Layup 3", "Layup 4", "Layup 5", "Layup 6", "Layup 7",
		"Layup 8", "Layup 9", "Layup 10", "Legend", "Retro", "Small",
		"Swing", "Up & Under"
	},
	FloaterList = {
		"Base", "Floater 1", "Floater 2", "Floater 3", "Floater 4", "Floater 5",
		"Floater 6", "Floater 7", "Floater 8", "Floater 9", "Floater 10"
	},
	PostList = {
		"Base", "Deon Magizine", "LBJ Hammer", "Pro 1", "Pro 2", "Pro 3"
	},
	DribbleStyleList = {
		"Base", "Cory Errving", "Derrick Jones", "Elite", "Explosive",
		"Fundamental", "Quick", "Shifty", "Slasher", "Smooth"
	},
	ShoeList = {
		"5IVESTAR X RH2 Slam", "BAX Slide", "Dimstarsz", "Journey 2", "Journey 3",
		"Off Block X RH2 Slam", "RH2 Slam", "Rich Owens", "Shruggs", "Gator",
		"Scuba Fin", "Rubber Boots", "Bricktons", "Journey 4", "Bims"
	},
	SelectedBetweenLegs = "Base",
	SelectedHesi = "Base",
	SelectedStepback = "Base",
	SelectedLayup = "Base",
	SelectedFloater = "Base",
	SelectedPost = "Base",
	SelectedDribbleStyle = "Base",
	SelectedShoe = "RH2 Slam",
	SelectedShoeColor = "All Black",
	SelectedGreenSound = "Regular",
	SelectedGreenEffect = "Regular",

	GamepassesHooked = false,
	MenuUnlocked = false,
}

function UnlockAll.EquipJumpshot(pkgName)
	if PaidGate("Jumpshot unlock") then return false end
	local anims = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Animations")
	local pkg = anims and anims:FindFirstChild("Jumpshot_Packages") and anims.Jumpshot_Packages:FindFirstChild(pkgName)
	if not pkg then
		Vesper:Notify({ Title = "Unlock All", Content = "Jumpshot package not found: " .. tostring(pkgName), Type = "error" })
		return false
	end

	local bp = LocalPlayer:FindFirstChild("Backpack")
	local ga = bp and bp:FindFirstChild("GameplayAnimations")
	local shoot = ga and ga:FindFirstChild("ShootingAnimations")
	local jsAnim = shoot and shoot:FindFirstChild("Jumpshot")
	if not jsAnim then
		Vesper:Notify({ Title = "Unlock All", Content = "Shooting animations not found in Backpack", Type = "error" })
		return false
	end

	local targetAnim = pkg:FindFirstChild("R") or pkg:FindFirstChild("L") or pkg:FindFirstChildOfClass("Animation")
	if targetAnim then
		jsAnim.AnimationId = targetAnim.AnimationId
	end

	local mv = bp:FindFirstChild("MenuValues")
	if mv and mv:FindFirstChild("RefreshAnimations") then
		mv.RefreshAnimations.Value = true
		task.delay(0.1, function() pcall(function() mv.RefreshAnimations.Value = false end) end)
	end

	pcall(function()
		local gs = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GameplayScripts")
		local gh = gs and gs:FindFirstChild("Gameplay.Handler")
		if gh and getsenv then
			local env = getsenv(gh)
			if env and env.refreshAnimations then env.refreshAnimations() end
		end
	end)

	UnlockAll.SelectedJumpshot = pkgName
	Vesper:Notify({ Title = "Jumpshot Equipped", Content = "Loaded " .. pkgName .. " (Server Replicated)!", Type = "success" })
	return true
end

function UnlockAll.EquipDunk(pkgName)
	if PaidGate("Dunk unlock") then return false end
	local anims = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Animations")
	local dunkRoot = anims and anims:FindFirstChild("Dunk_Packages")
	local parkRoot = anims and anims:FindFirstChild("Park_Dunk_Packages")
	local pkg = (dunkRoot and dunkRoot:FindFirstChild(pkgName)) or (parkRoot and parkRoot:FindFirstChild(pkgName))
	if not pkg then
		Vesper:Notify({ Title = "Unlock All", Content = "Dunk package not found: " .. tostring(pkgName), Type = "error" })
		return false
	end

	local bp = LocalPlayer:FindFirstChild("Backpack")
	local ga = bp and bp:FindFirstChild("GameplayAnimations")
	local dunks = ga and ga:FindFirstChild("DunkingAnimations")
	if not dunks then
		Vesper:Notify({ Title = "Unlock All", Content = "Dunking animations not found in Backpack", Type = "error" })
		return false
	end

	for _, ch in ipairs(pkg:GetChildren()) do
		if ch:IsA("Animation") then
			local n = ch.Name
			if string.find(n, "MovingDunk 1") or string.find(n, "MovingDunk1") then
				if dunks:FindFirstChild("MovingDunk1") then dunks.MovingDunk1.AnimationId = ch.AnimationId end
			elseif string.find(n, "MovingDunk 2") or string.find(n, "MovingDunk2") then
				if dunks:FindFirstChild("MovingDunk2") then dunks.MovingDunk2.AnimationId = ch.AnimationId end
			elseif string.find(n, "MovingDunk 3") or string.find(n, "MovingDunk3") then
				if dunks:FindFirstChild("MovingDunk3") then dunks.MovingDunk3.AnimationId = ch.AnimationId end
			elseif string.find(n, "StandingDunk 1") or string.find(n, "StandingDunk1") then
				if dunks:FindFirstChild("StandingDunk1") then dunks.StandingDunk1.AnimationId = ch.AnimationId end
			elseif string.find(n, "StandingDunk 2") or string.find(n, "StandingDunk2") then
				if dunks:FindFirstChild("StandingDunk2") then dunks.StandingDunk2.AnimationId = ch.AnimationId end
			end
		end
	end

	local mv = bp:FindFirstChild("MenuValues")
	if mv and mv:FindFirstChild("RefreshAnimations") then
		mv.RefreshAnimations.Value = true
		task.delay(0.1, function() pcall(function() mv.RefreshAnimations.Value = false end) end)
	end

	pcall(function()
		local gs = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GameplayScripts")
		local gh = gs and gs:FindFirstChild("Gameplay.Handler")
		if gh and getsenv then
			local env = getsenv(gh)
			if env and env.refreshAnimations then env.refreshAnimations() end
		end
	end)

	UnlockAll.SelectedDunk = pkgName
	Vesper:Notify({ Title = "Dunk Equipped", Content = "Loaded " .. pkgName .. " (Server Replicated)!", Type = "success" })
	return true
end

function UnlockAll.EquipCrossover(pkgName)
	if PaidGate("Crossover unlock") then return false end
	local anims = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Animations")
	local pkg = anims and anims:FindFirstChild("Crossover_Packages") and anims.Crossover_Packages:FindFirstChild(pkgName)
	if not pkg then
		Vesper:Notify({ Title = "Unlock All", Content = "Crossover package not found: " .. tostring(pkgName), Type = "error" })
		return false
	end

	local bp = LocalPlayer:FindFirstChild("Backpack")
	local ga = bp and bp:FindFirstChild("GameplayAnimations")
	local da = ga and ga:FindFirstChild("DribbleAnimations")
	local crossAnim = da and da:FindFirstChild("Cross_Animations")
	if not crossAnim then
		Vesper:Notify({ Title = "Unlock All", Content = "Cross_Animations not found in Backpack", Type = "error" })
		return false
	end

	for _, sub in ipairs({ "Standing", "Moving", "Double Cross" }) do
		local srcSub = pkg:FindFirstChild(sub)
		local dstSub = crossAnim:FindFirstChild(sub)
		if srcSub and dstSub then
			for _, ch in ipairs(dstSub:GetChildren()) do ch:Destroy() end
			for _, ch in ipairs(srcSub:GetChildren()) do
				ch:Clone().Parent = dstSub
			end
		end
	end

	UnlockAll.SelectedCrossover = pkgName
	Vesper:Notify({ Title = "Crossover Equipped", Content = "Loaded " .. pkgName .. " crossover!", Type = "success" })
	return true
end

function UnlockAll.EquipBehindTheBack(pkgName)
	if PaidGate("Behind-the-back unlock") then return false end
	local anims = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Animations")
	local pkg = anims and anims:FindFirstChild("BehindTheBack_Packages") and anims.BehindTheBack_Packages:FindFirstChild(pkgName)
	if not pkg then
		Vesper:Notify({ Title = "Unlock All", Content = "BehindTheBack package not found", Type = "error" })
		return false
	end

	local bp = LocalPlayer:FindFirstChild("Backpack")
	local ga = bp and bp:FindFirstChild("GameplayAnimations")
	local da = ga and ga:FindFirstChild("DribbleAnimations")
	local bhbAnim = da and da:FindFirstChild("BHB_Animations")
	if not bhbAnim then
		Vesper:Notify({ Title = "Unlock All", Content = "BHB_Animations not found in Backpack", Type = "error" })
		return false
	end

	local m = pkg:FindFirstChild("Moving")
	if m then
		if m:FindFirstChild("R2L") and bhbAnim:FindFirstChild("Moving_R2L") then bhbAnim.Moving_R2L.AnimationId = m.R2L.AnimationId end
		if m:FindFirstChild("L2R") and bhbAnim:FindFirstChild("Moving_L2R") then bhbAnim.Moving_L2R.AnimationId = m.L2R.AnimationId end
	end
	local st = pkg:FindFirstChild("Standing")
	if st then
		if st:FindFirstChild("R2L") and bhbAnim:FindFirstChild("R2L") then bhbAnim.R2L.AnimationId = st.R2L.AnimationId end
		if st:FindFirstChild("L2R") and bhbAnim:FindFirstChild("L2R") then bhbAnim.L2R.AnimationId = st.L2R.AnimationId end
	end
	local sz = pkg:FindFirstChild("Sizeup")
	if sz then
		if sz:FindFirstChild("L2L") and bhbAnim:FindFirstChild("L2L") then bhbAnim.L2L.AnimationId = sz.L2L.AnimationId end
		if sz:FindFirstChild("R2R") and bhbAnim:FindFirstChild("R2R") then bhbAnim.R2R.AnimationId = sz.R2R.AnimationId end
	end

	UnlockAll.SelectedBehindTheBack = pkgName
	Vesper:Notify({ Title = "Behind-The-Back Equipped", Content = "Loaded " .. pkgName .. "!", Type = "success" })
	return true
end

-- Shared animation refresh (Backpack MenuValues + live Gameplay.Handler)
function UnlockAll.RefreshAnims()
	local bp = LocalPlayer:FindFirstChild("Backpack")
	local mv = bp and bp:FindFirstChild("MenuValues")
	if mv and mv:FindFirstChild("RefreshAnimations") then
		mv.RefreshAnimations.Value = true
		task.delay(0.1, function() pcall(function() mv.RefreshAnimations.Value = false end) end)
	end
	pcall(function()
		local gs = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GameplayScripts")
		local gh = gs and gs:FindFirstChild("Gameplay.Handler")
		if gh and getsenv then
			local env = getsenv(gh)
			if env and env.refreshAnimations then env.refreshAnimations() end
		end
	end)
end

-- Generic applier: map = { ["SrcSub/SrcAnim"] = "DstAnim" } ; "" sub = package root.
-- Also auto-copies root-level anims whose names match destination slots.
function UnlockAll.ApplyAnimMap(pkg, dst, map)
	local applied = 0
	if not pkg or not dst then return 0 end
	for srcKey, dstName in pairs(map) do
		local sub, anim = string.match(srcKey, "^(.-)/(.+)$")
		local src = nil
		if sub then
			local srcSub = pkg:FindFirstChild(sub)
			src = srcSub and srcSub:FindFirstChild(anim)
		else
			src = pkg:FindFirstChild(srcKey)
		end
		local slot = dstName and dst:FindFirstChild(dstName)
		if src and src:IsA("Animation") and slot and slot:IsA("Animation") then
			slot.AnimationId = src.AnimationId
			applied = applied + 1
		end
	end
	for _, ch in ipairs(pkg:GetChildren()) do
		if ch:IsA("Animation") then
			local slot = dst:FindFirstChild(ch.Name)
			if slot and slot:IsA("Animation") and slot.AnimationId ~= ch.AnimationId then
				slot.AnimationId = ch.AnimationId
				applied = applied + 1
			end
		end
	end
	return applied
end

function UnlockAll.GetAnimPkg(rootName, pkgName)
	local anims = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Animations")
	local root = anims and anims:FindFirstChild(rootName)
	return root and root:FindFirstChild(pkgName)
end

function UnlockAll.GetBackpackFolder(...)
	local node = LocalPlayer:FindFirstChild("Backpack")
	for _, name in ipairs({...}) do
		node = node and node:FindFirstChild(name)
		if not node then return nil end
	end
	return node
end

function UnlockAll.EquipBetweenLegs(pkgName)
	if PaidGate("Between-legs unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("BetweenTheLegs_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Between-legs package not found", Type = "error" }) return false end
	local dst = UnlockAll.GetBackpackFolder("GameplayAnimations", "DribbleAnimations", "BetweenLegs_Animations")
	if not dst then Vesper:Notify({ Title = "Unlock All", Content = "BetweenLegs_Animations not found in Backpack", Type = "error" }) return false end
	local n = UnlockAll.ApplyAnimMap(pkg, dst, {
		["Standing/L2R"] = "L2R", ["Standing/R2L"] = "R2L",
		["Moving/L2R"] = "Moving_L2R", ["Moving/R2L"] = "Moving_R2L",
	})
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedBetweenLegs = pkgName
	Vesper:Notify({ Title = "Between Legs Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(n) .. " slots)!", Type = "success" })
	return n > 0
end

function UnlockAll.EquipHesi(pkgName)
	if PaidGate("Hesi unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("Hesi_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Hesi package not found", Type = "error" }) return false end
	local dst = UnlockAll.GetBackpackFolder("GameplayAnimations", "DribbleAnimations", "Hesi_Animations")
	if not dst then Vesper:Notify({ Title = "Unlock All", Content = "Hesi_Animations not found in Backpack", Type = "error" }) return false end
	local n = UnlockAll.ApplyAnimMap(pkg, dst, { ["Standing/L"] = "L", ["Standing/R"] = "R" })
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedHesi = pkgName
	Vesper:Notify({ Title = "Hesi Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(n) .. " slots)!", Type = "success" })
	return n > 0
end

function UnlockAll.EquipStepback(pkgName)
	if PaidGate("Stepback unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("Stepback_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Stepback package not found", Type = "error" }) return false end
	local dst = UnlockAll.GetBackpackFolder("GameplayAnimations", "DribbleAnimations", "Stepback_Animations")
	if not dst then Vesper:Notify({ Title = "Unlock All", Content = "Stepback_Animations not found in Backpack", Type = "error" }) return false end
	local n = UnlockAll.ApplyAnimMap(pkg, dst, {
		["Moving/Moving_L"] = "Moving_L", ["Moving/Moving_R"] = "Moving_R",
		["Standing/RH_Stepback"] = "R", ["Standing/LH_Stepback"] = "L",
	})
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedStepback = pkgName
	Vesper:Notify({ Title = "Stepback Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(n) .. " slots)!", Type = "success" })
	return n > 0
end

function UnlockAll.EquipLayup(pkgName)
	if PaidGate("Layup unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("Layup_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Layup package not found: " .. tostring(pkgName), Type = "error" }) return false end
	local dst = UnlockAll.GetBackpackFolder("GameplayAnimations", "LayupAnimations")
	if not dst then Vesper:Notify({ Title = "Unlock All", Content = "LayupAnimations not found in Backpack", Type = "error" }) return false end
	local n = UnlockAll.ApplyAnimMap(pkg, dst, {})
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedLayup = pkgName
	Vesper:Notify({ Title = "Layup Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(n) .. " slots)!", Type = "success" })
	return n > 0
end

function UnlockAll.EquipFloater(pkgName)
	if PaidGate("Floater unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("Floater_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Floater package not found: " .. tostring(pkgName), Type = "error" }) return false end
	local dst = UnlockAll.GetBackpackFolder("GameplayAnimations", "FloaterAnimations")
	if not dst then Vesper:Notify({ Title = "Unlock All", Content = "FloaterAnimations not found in Backpack", Type = "error" }) return false end
	local n = UnlockAll.ApplyAnimMap(pkg, dst, {})
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedFloater = pkgName
	Vesper:Notify({ Title = "Floater Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(n) .. " slots)!", Type = "success" })
	return n > 0
end

function UnlockAll.EquipPost(pkgName)
	if PaidGate("Post moves unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("Post_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Post package not found: " .. tostring(pkgName), Type = "error" }) return false end
	local dst = UnlockAll.GetBackpackFolder("GameplayAnimations", "PostUpAnimations", "ShootingActions")
	if not dst then Vesper:Notify({ Title = "Unlock All", Content = "ShootingActions not found in Backpack", Type = "error" }) return false end
	local n = UnlockAll.ApplyAnimMap(pkg, dst, {
		["PostFade_L_RH"] = "PostFade_L_DominateHand", ["PostFade_R_LH"] = "PostFade_R_DominateHand",
		["Side_PostFade_L_RH"] = "Side_PostFade_L_DominateHand", ["Side_PostFade_R_LH"] = "Side_PostFade_R_DominateHand",
	})
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedPost = pkgName
	Vesper:Notify({ Title = "Post Moves Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(n) .. " slots)!", Type = "success" })
	return n > 0
end

function UnlockAll.EquipDribbleStyle(pkgName)
	if PaidGate("Dribble style unlock") then return false end
	local pkg = UnlockAll.GetAnimPkg("Dribble_Style_Packages", pkgName)
	if not pkg then Vesper:Notify({ Title = "Unlock All", Content = "Dribble style package not found", Type = "error" }) return false end
	local da = UnlockAll.GetBackpackFolder("GameplayAnimations", "DribbleAnimations")
	if not da then Vesper:Notify({ Title = "Unlock All", Content = "DribbleAnimations not found in Backpack", Type = "error" }) return false end
	local total = 0
	local ga = UnlockAll.GetBackpackFolder("GameplayAnimations")
	local idle = pkg:FindFirstChild("IdleDribble")
	if idle and ga then
		for _, ch in ipairs(idle:GetChildren()) do
			if ch:IsA("Animation") then
				local slot = (ch.Name == "LH" and ga:FindFirstChild("LHDribble")) or (ch.Name == "RH" and ga:FindFirstChild("RHDribble"))
				if slot and slot:IsA("Animation") then slot.AnimationId = ch.AnimationId total = total + 1 end
			end
		end
	end
	local spinDst = da:FindFirstChild("Spin_Animations")
	local spinSrc = pkg:FindFirstChild("Spin")
	if spinDst and spinSrc then
		for _, ch in ipairs(spinSrc:GetChildren()) do
			if ch:IsA("Animation") then
				local slot = spinDst:FindFirstChild(ch.Name)
				if slot and slot:IsA("Animation") then slot.AnimationId = ch.AnimationId total = total + 1 end
			end
		end
	end
	local sizeDst = da:FindFirstChild("Sizeup_Animations")
	local burstSrc = pkg:FindFirstChild("Burst")
	if sizeDst and burstSrc then
		for _, ch in ipairs(burstSrc:GetChildren()) do
			if ch:IsA("Animation") then
				local slot = sizeDst:FindFirstChild(ch.Name)
				if slot and slot:IsA("Animation") then slot.AnimationId = ch.AnimationId total = total + 1 end
			end
		end
	end
	UnlockAll.RefreshAnims()
	UnlockAll.SelectedDribbleStyle = pkgName
	Vesper:Notify({ Title = "Dribble Style Equipped", Content = "Loaded " .. pkgName .. " (" .. tostring(total) .. " slots)!", Type = "success" })
	return total > 0
end

function UnlockAll.GetShoeColorways(shoeName)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local shoes = assets and assets:FindFirstChild("Shoes")
	local shoe = shoes and shoes:FindFirstChild(shoeName or UnlockAll.SelectedShoe)
	local cw = shoe and shoe:FindFirstChild("Colorways")
	if not cw then return { "Default" } end
	local list = {}
	for _, c in ipairs(cw:GetChildren()) do table.insert(list, c.Name) end
	table.sort(list)
	if #list == 0 then return { "Default" } end
	return list
end

function UnlockAll.GetMenuRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local m = remotes:FindFirstChild("Menu.RE")
		if m and m:IsA("RemoteEvent") then return m end
	end
	return nil
end

function UnlockAll.EquipShoes(shoeName, colorName)
	if PaidGate("Shoes unlock") then return false end
	shoeName = shoeName or UnlockAll.SelectedShoe
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local shoes = assets and assets:FindFirstChild("Shoes")
	local shoe = shoes and shoes:FindFirstChild(shoeName)
	if not shoe then Vesper:Notify({ Title = "Locker", Content = "Shoe not found: " .. tostring(shoeName), Type = "error" }) return false end
	local cwFolder = shoe:FindFirstChild("Colorways")
	local cw = (colorName and cwFolder and cwFolder:FindFirstChild(colorName)) or (cwFolder and cwFolder:GetChildren()[1])
	if not cw then Vesper:Notify({ Title = "Locker", Content = "No colorways for " .. shoeName, Type = "error" }) return false end
	local label = shoe.Name .. " " .. cw.Name
	local before = {}
	pcall(function()
		local char = LocalPlayer.Character
		if char then for _, d in ipairs(char:GetDescendants()) do if d:IsA("SpecialMesh") then before[d:GetFullName()] = d.MeshId end end end
	end)
	local menuRE = UnlockAll.GetMenuRemote()
	if menuRE then pcall(function() menuRE:FireServer("Change Shoes", label) end) end
	task.delay(1.5, function()
		local changed = false
		pcall(function()
			local char = LocalPlayer.Character
			if char then for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("SpecialMesh") and before[d:GetFullName()] ~= d.MeshId then changed = true break end
			end end
		end)
		if changed then
			Vesper:Notify({ Title = "Shoes Equipped", Content = label .. " (Server Replicated)!", Type = "success" })
		else
			Vesper:Notify({ Title = "Shoes", Content = "Request sent (" .. label .. "). Unlock menu first or use native shop.", Type = "info" })
		end
	end)
	UnlockAll.SelectedShoe, UnlockAll.SelectedShoeColor = shoe.Name, cw.Name
	return true
end

function UnlockAll.GetGreenSounds()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local gs = assets and assets:FindFirstChild("GreenSounds")
	if not gs then return UnlockAll.GreenSoundsList end
	local list = {}
	for _, s in ipairs(gs:GetChildren()) do if s:IsA("Sound") then table.insert(list, s.Name) end end
	table.sort(list)
	if #list == 0 then return UnlockAll.GreenSoundsList end
	return list
end

function UnlockAll.GetGreenEffects()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local ge = assets and assets:FindFirstChild("GreenEffects")
	if not ge then return UnlockAll.GreenEffectsList end
	local list = {}
	for _, v in ipairs(ge:GetChildren()) do if v:IsA("IntValue") then table.insert(list, v.Name) end end
	table.sort(list)
	if #list == 0 then return UnlockAll.GreenEffectsList end
	return list
end

function UnlockAll.EquipGreenSound(soundName)
	if PaidGate("Green sound unlock") then return false end
	soundName = soundName or UnlockAll.SelectedGreenSound
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local gs = assets and assets:FindFirstChild("GreenSounds")
	local snd = gs and gs:FindFirstChild(soundName)
	if snd then
		pcall(function()
			local src = snd:IsA("Sound") and snd or snd:FindFirstChildOfClass("Sound")
			if src then
				local c = src:Clone()
				c.Parent = LocalPlayer:FindFirstChild("PlayerGui") or workspace
				c:Play()
				task.delay(4, function() pcall(function() c:Destroy() end) end)
			end
		end)
	end
	local menuRE = UnlockAll.GetMenuRemote()
	if menuRE then
		pcall(function() menuRE:FireServer("Change GreenSound", soundName) end)
		pcall(function() menuRE:FireServer("Change Green Sound", soundName) end)
	end
	UnlockAll.SelectedGreenSound = soundName
	Vesper:Notify({ Title = "Green Sound", Content = "Preview: " .. soundName .. " (pick it in native shop for permanent)", Type = "info" })
	return true
end

function UnlockAll.EquipGreenEffect(effectName)
	if PaidGate("Green effect unlock") then return false end
	effectName = effectName or UnlockAll.SelectedGreenEffect
	local menuRE = UnlockAll.GetMenuRemote()
	if menuRE then
		pcall(function() menuRE:FireServer("Change GreenEffect", effectName) end)
		pcall(function() menuRE:FireServer("Change Green Effect", effectName) end)
	end
	UnlockAll.SelectedGreenEffect = effectName
	Vesper:Notify({ Title = "Green Effect", Content = "Request sent: " .. effectName .. " (pick it in native shop for permanent)", Type = "info" })
	return true
end

function UnlockAll.EquipCelebration(celebName)
	if PaidGate("Celebration unlock") then return false end
	local anims = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("Animations")
	local celFolder = anims and anims:FindFirstChild("Jumpshot_Celebrations")
	local celeb = celFolder and celFolder:FindFirstChild(celebName)
	if not celeb then
		Vesper:Notify({ Title = "Unlock All", Content = "Celebration not found: " .. tostring(celebName), Type = "error" })
		return false
	end

	local targetAnim = celeb:IsA("Animation") and celeb or celeb:FindFirstChildOfClass("Animation")
	if not targetAnim then
		Vesper:Notify({ Title = "Unlock All", Content = "Animation not found in celebration", Type = "error" })
		return false
	end

	local bp = LocalPlayer:FindFirstChild("Backpack")
	local ga = bp and bp:FindFirstChild("GameplayAnimations")
	local shoot = ga and ga:FindFirstChild("ShootingAnimations")
	local gl = shoot and shoot:FindFirstChild("GreenLanding")
	if gl then
		gl.AnimationId = targetAnim.AnimationId
		UnlockAll.SelectedCelebration = celebName
		Vesper:Notify({ Title = "Celebration Equipped", Content = "Green Landing set to " .. celebName .. "!", Type = "success" })
		return true
	end
	return false
end

function UnlockAll.EquipTop(topName)
	if PaidGate("Top unlock") then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	VisualUnlock.BackupOriginal()

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local topsFolder = assets and assets:FindFirstChild("Tops")
	if not topsFolder then return false end

	local template = nil
	for _, d in ipairs(topsFolder:GetDescendants()) do
		if d:IsA("Shirt") and d.Parent and d.Parent.Name == topName and d.ShirtTemplate ~= "" then
			template = d.ShirtTemplate
			break
		end
	end

	if not template then
		for _, d in ipairs(topsFolder:GetDescendants()) do
			if d:IsA("Shirt") and d.ShirtTemplate ~= "" and string.find(string.lower(d.Parent.Name), string.lower(topName), 1, true) then
				template = d.ShirtTemplate
				break
			end
		end
	end

	if template then
		local s = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
		s.ShirtTemplate = template
		UnlockAll.SelectedTop = topName
		Vesper:Notify({ Title = "Locker", Content = "Equipped top: " .. topName, Type = "success" })
		return true
	else
		Vesper:Notify({ Title = "Locker", Content = "Could not find shirt template for " .. tostring(topName), Type = "error" })
		return false
	end
end

function UnlockAll.EquipBottom(bottomName)
	if PaidGate("Bottom unlock") then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	VisualUnlock.BackupOriginal()

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local botFolder = assets and assets:FindFirstChild("Bottoms")
	if not botFolder then return false end

	local template = nil
	for _, d in ipairs(botFolder:GetDescendants()) do
		if d:IsA("Pants") and d.Parent and d.Parent.Name == bottomName and d.PantsTemplate ~= "" then
			template = d.PantsTemplate
			break
		end
	end

	if not template then
		for _, d in ipairs(botFolder:GetDescendants()) do
			if d:IsA("Pants") and d.PantsTemplate ~= "" and string.find(string.lower(d.Parent.Name), string.lower(bottomName), 1, true) then
				template = d.PantsTemplate
				break
			end
		end
	end

	if template then
		local p = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
		p.PantsTemplate = template
		UnlockAll.SelectedBottom = bottomName
		Vesper:Notify({ Title = "Locker", Content = "Equipped bottoms: " .. bottomName, Type = "success" })
		return true
	else
		Vesper:Notify({ Title = "Locker", Content = "Could not find pants template for " .. tostring(bottomName), Type = "error" })
		return false
	end
end

function UnlockAll.EquipMascot(mascotName)
	if PaidGate("Mascot unlock") then return false end
	local char = LocalPlayer.Character
	if not char then return false end
	VisualUnlock.BackupOriginal()

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local mascot = assets and assets:FindFirstChild("Mascots") and assets.Mascots:FindFirstChild(mascotName)
	if not mascot then
		Vesper:Notify({ Title = "Locker", Content = "Mascot not found: " .. tostring(mascotName), Type = "error" })
		return false
	end

	local mAssets = mascot:FindFirstChild("Assets")
	if not mAssets then return false end

	local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
	local pants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)

	if mAssets:FindFirstChild("Top") then
		shirt.ShirtTemplate = mAssets.Top.ShirtTemplate
	end
	if mAssets:FindFirstChild("Bottom") then
		pants.PantsTemplate = mAssets.Bottom.PantsTemplate
	end

	local mc = mAssets:FindFirstChild("Mascot Colors")
	if mc and mc:IsA("BodyColors") then
		local charBc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
		charBc.HeadColor3 = mc.HeadColor3
		charBc.LeftArmColor3 = mc.LeftArmColor3
		charBc.RightArmColor3 = mc.RightArmColor3
		charBc.LeftLegColor3 = mc.LeftLegColor3
		charBc.RightLegColor3 = mc.RightLegColor3
		charBc.TorsoColor3 = mc.TorsoColor3
	end

	UnlockAll.SelectedMascot = mascotName
	Vesper:Notify({ Title = "Mascot Equipped", Content = "Equipped " .. mascotName .. " Mascot!", Type = "success" })
	return true
end

function UnlockAll.HookGamepasses()
	if PaidGate("Gamepass unlock") then return false end
	if UnlockAll.GamepassesHooked then return true end
	if hookmetamethod then
		local oldNamecall
		oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if method == "UserOwnsGamePassAsync" or method == "userOwnsGamePassAsync" then
				return true
			end
			return oldNamecall(self, ...)
		end))
		UnlockAll.GamepassesHooked = true
		Vesper:Notify({ Title = "Gamepasses", Content = "All Gamepasses & Emote Packs unlocked!", Type = "success" })
		return true
	end
	return false
end

function UnlockAll.UnlockMenu()
	if PaidGate("Menu unlock") then return false end
	local rs = ReplicatedStorage
	local assets = rs:FindFirstChild("Assets")
	if not assets then return false end

	local allTops = {}
	if assets:FindFirstChild("Tops") then
		for _, ch in ipairs(assets.Tops:GetChildren()) do table.insert(allTops, ch.Name) end
	end
	local allBottoms = {}
	if assets:FindFirstChild("Bottoms") then
		for _, ch in ipairs(assets.Bottoms:GetChildren()) do table.insert(allBottoms, ch.Name) end
	end
	local allShoes = {}
	if assets:FindFirstChild("Shoes") then
		for _, ch in ipairs(assets.Shoes:GetChildren()) do table.insert(allShoes, ch.Name) end
	end

	local reloadPassFn = nil

	if getgc then
		for _, fn in ipairs(getgc(true)) do
			if type(fn) == "function" and islclosure(fn) and not isexecutorclosure(fn) then
				local ok, info = pcall(debug.getinfo, fn)
				if ok and info and info.source and string.find(info.source, "Menu.Handler") then
					local okUv, uvs = pcall(debug.getupvalues, fn)
					if okUv and uvs then
						for i, uv in pairs(uvs) do
							if type(uv) == "table" and uv.Inventory and type(uv.Inventory.Tops) == "table" then
								uv.Inventory.Tops = allTops
								uv.Inventory.Bottoms = allBottoms
								uv.Inventory.Shoes = allShoes
								if uv["Journey Pass"] then
									local jp = uv["Journey Pass"]
									jp.JourneyPassLevel = 40
									jp.Level = 40
									jp.hasPremiumPass = true
									jp.Premium = true
									jp.JourneyPassEXP = 1250
									jp.JourneyPassMaxEXP = 1250
								end
							end
						end
					end

					if not reloadPassFn then
						local okConst, consts = pcall(debug.getconstants, fn)
						if okConst and consts then
							for _, c in ipairs(consts) do
								if c == "loadJourneyPass" then
									reloadPassFn = fn
									break
								end
							end
						end
					end
				end
			end
		end
	end

	if reloadPassFn then
		pcall(reloadPassFn)
	end

	UnlockAll.MenuUnlocked = true
	Vesper:Notify({
		Title = "RH2 Menu",
		Content = "Level 40 Premium Pass & All Items unlocked & rendered live!",
		Type = "success",
		Duration = 4
	})
	return true
end

getgenv().RH2_UnlockAll = UnlockAll

-- RH2 Gameplay Environment Resolver
local CachedEnv = nil
local function GetGameplayEnv()
	if CachedEnv and CachedEnv.script and CachedEnv.script.Parent then return CachedEnv end
	local char = LocalPlayer.Character
	if not char then return nil end
	local gs = char:FindFirstChild("GameplayScripts")
	local gh = gs and gs:FindFirstChild("Gameplay.Handler")
	if gh and getsenv then
		local ok, env = pcall(getsenv, gh)
		if ok and env then
			CachedEnv = env
			return env
		end
	end
	return nil
end

local function SafeGetCharacter(entity)
	if not entity then return nil end
	if typeof(entity) == "Instance" then
		if entity:IsA("Player") then return entity.Character end
		if entity:IsA("Model") then return entity end
	end
	return nil
end

-- Metamethod Hook: Anti-Cheat + Server Ghost Sprint + Anti-Contest
local PlayerEvents = ReplicatedStorage:FindFirstChild("PlayerEvents")
	or ReplicatedStorage:WaitForChild("PlayerEvents", 5)
	or ReplicatedStorage:FindFirstChild("Remotes")
	or ReplicatedStorage:FindFirstChild("Events")

local remote, lastAction, lastDetail
local lastRemote = 0
local releases = {}
local sending = false

local ping = 80
local biases = {}
local low, high, window = 76, 77, 0

local family, animation
local armed, fired = false, false
local started = 0
local pending
local oldPower, oldTime = 0, os.clock()
local firstPower, firstTime
local rate = 0

pcall(function()
	local oldMetaNamecall
	oldMetaNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		if getgenv().RH2_Unloaded then return oldMetaNamecall(self, ...) end

		local method = getnamecallmethod()
		local args = {...}

		if (method == "FireServer" or method == "fireServer") and self and self.Parent == PlayerEvents then
			local curState = GetState()

			if args[1] == "detected" then
				return nil
			end

			if curState.GhostSprint and #args == 1 and args[1] == true then
				return nil
			end

			if curState.AntiContest and not IsFreeTier and self.Name == "Magnitude" then
				if typeof(args[1]) == "table" and args[1].Action == "Contest" then
					args[1].ContestPercentage = 0
					args[1].Distance = 999
					return oldMetaNamecall(self, unpack(args))
				end
			end

			local state, action, detail = ...
			local shooting = action == "Shooting" or action == "Moving Dunk" or action == "Standing Dunk"
				or action == "Moving AO Dunk" or action == "Standing AO Dunk"

			if shooting and state == true then
				remote = self
				lastAction = action
				lastDetail = detail
				lastRemote = os.clock()
				curState.TotalShots = (curState.TotalShots or 0) + 1
				curState.LastAction = "Shot " .. tostring(detail or action)
			elseif shooting and state == false and sending == false and self == remote and lastAction then
				releases[lastAction .. ":" .. tostring(lastDetail)] = {action, detail}
			end
		end

		return oldMetaNamecall(self, ...)
	end))
end)

local function getShot(char)
	local hum = char:FindFirstChild("Humanoid")
	local animator = hum and hum:FindFirstChild("Animator")
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			local anim = track.Animation
			if anim then
				local folder = anim.Parent
				local found
				while folder and folder ~= game do
					local name = folder.Name
					if name == "ShootingAnimations" or name == "LayupAnimations" or name == "FloaterAnimations"
					or name == "PostUpAnimations" or name == "DunkingAnimations" then
						found = name
						break
					end
					folder = folder.Parent
				end

				local name = anim.Name
				local good = found == "ShootingAnimations" and (name == "Jumpshot" or name == "Freethrow_Shot" or string.sub(name, 1, 9) == "Jumpshot_")
					or found == "LayupAnimations" and not string.find(name, "Clutch", 1, true)
					or found == "FloaterAnimations" and string.find(name, "Floater", 1, true)
					or found == "PostUpAnimations" and (string.find(name, "PostFade", 1, true) or string.find(name, "Hook", 1, true) and not string.find(name, "Fake", 1, true))
					or found == "DunkingAnimations" and (string.sub(name, 1, 10) == "MovingDunk" or string.sub(name, 1, 12) == "StandingDunk")

				if good then return found, name end
			end
		end
	end
end

-- Shooting_RE resolver: the game stores action remotes under obfuscated
-- PlayerEvents names and wipes _G.RH2_Remotes after load, so the only
-- reliable handle is the Gameplay.Handler upvalue (read-only scan).
local function ResolveShootingRemote()
	if typeof(remote) == "Instance" and remote:IsA("RemoteEvent") and remote.Parent then
		return remote
	end
	if type(getgc) == "function" and debug and type(debug.getupvalue) == "function" then
		local isL = (type(islclosure) == "function" and islclosure) or function() return true end
		local isExec = (type(isexecutorclosure) == "function" and isexecutorclosure) or function() return false end
		pcall(function()
			for _, fn in ipairs(getgc(true)) do
				if type(fn) == "function" then
					local okI, info = pcall(debug.getinfo, fn)
					if okI and info and info.source and string.find(info.source, "Gameplay.Handler", 1, true) then
						local okL, lRes = pcall(isL, fn)
						if okL and lRes then
							local okE, eRes = pcall(isExec, fn)
							if okE and not eRes then
								for i = 1, 40 do
									local okU, name, val = pcall(debug.getupvalue, fn, i)
									if not okU or not name then break end
									if name == "Shooting_RE" and typeof(val) == "Instance" and val:IsA("RemoteEvent") and val.Parent then
										remote = val
										return
									end
								end
							end
						end
					end
				end
				if typeof(remote) == "Instance" and remote.Parent then break end
			end
		end)
	end
	return remote
end

local function release(char)
	if typeof(remote) ~= "Instance" or not remote:IsA("RemoteEvent") or not remote.Parent then
		remote = ResolveShootingRemote()
	end
	if not remote or os.clock() - lastRemote > 5 then return false end

	local match = releases[lastAction .. ":" .. tostring(lastDetail)]
	local action = match and match[1] or lastAction
	local detail = match and match[2] or lastDetail

	if not action then
		if family == "LayupAnimations" then
			action = "Shooting"
			detail = (lastDetail and tostring(lastDetail) ~= "" and tostring(lastDetail)) or "Layup"
		elseif family == "ShootingAnimations" then
			action = "Shooting"
			detail = "Moving Shot"
		end
	end

	if not detail and lastDetail then
		detail = lastDetail
	end
	if not detail and action == "Shooting" then
		detail = (family == "LayupAnimations" and "Layup") or "Standing Shot"
	end

	if not action or detail == nil then return false end

	sending = true
	remote:FireServer(false, action, detail)
	sending = false
	return true
end

local function resetEngine()
	armed, fired = false, false
	family, animation = nil, nil
	started = 0
	oldPower = 0
	firstPower, firstTime = nil, nil
	rate = 0
end

if PlayerEvents and PlayerEvents:FindFirstChild("Magnitude") then
	Vesper:Connect(PlayerEvents.Magnitude.OnClientEvent, function(data)
		if getgenv().RH2_Unloaded then return end
		if typeof(data) == "table" and data.Action == "Return Green Window" then
			local one = tonumber(data.Meter_1)
			local two = tonumber(data.Meter_2)
			if one and two then
				if two < one then one, two = two, one end
				low = one
				high = two - one < 1 and one + 1 or two
				window = os.clock() + 2.5
			end
		end
	end)
end

if PlayerEvents and PlayerEvents:FindFirstChild("ShotFeedBack") then
	Vesper:Connect(PlayerEvents.ShotFeedBack.OnClientEvent, function(registered, _, perfect)
		if getgenv().RH2_Unloaded then return end
		if registered == "SetTargetBar" then return end

		local shot = pending
		pending = nil

		if perfect then
			local curState = GetState()
			curState.TotalGreens = (curState.TotalGreens or 0) + 1
			curState.LastAction = "Green"
		end

		if not shot or perfect or typeof(registered) ~= "number" or os.clock() - shot.time > 3 then return end
		local lag = (registered - shot.power) / shot.rate
		if lag >= -0.05 and lag <= 0.65 then
			local wanted = math.clamp(lag - shot.ping, -0.025, 0.15)
			local old = biases[shot.name]
			biases[shot.name] = old and old + (wanted - old) * 0.35 or wanted
		end
	end)
end

task.spawn(function()
	while not getgenv().RH2_Unloaded do
		pcall(function()
			local val = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			ping = ping + (val - ping) * 0.25
		end)
		task.wait(0.25)
	end
end)

-- Main Heartbeat Loop: Auto Green + Ball Tracker
local lastShotTime = 0
local LastHeldBall = nil

Vesper:Connect(RunService.Heartbeat, function()
	if getgenv().RH2_Unloaded then return end
	local curState = GetState()
	local char = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")

	if not char or not backpack then
		resetEngine()
		return
	end

	if curState.AutoGreen then
		local values = backpack:FindFirstChild("ActionValues")
		local power = values and values:FindFirstChild("Power")

		if power then
			local menu = backpack:FindFirstChild("MenuValues")
			local meterType = menu and menu:FindFirstChild("ShotmeterType")
			local meterName = meterType and meterType.Value or "Overhead"
			local meter

			if meterName == "On Floor" then
				local pGui = LocalPlayer:FindFirstChild("PlayerGui")
				meter = pGui and pGui:FindFirstChild("Stamina_OnFloor")
			else
				if meterName ~= "Overhead" and meterName ~= "Vertical Bar" and meterName ~= "Pill" then
					meterName = "Overhead"
				end
				local head = char:FindFirstChild("Head")
				meter = head and head:FindFirstChild("MeterUi " .. meterName)
			end

			local pGui = LocalPlayer:FindFirstChild("PlayerGui")
			local dunkMeter = pGui and pGui:FindFirstChild("Dunk_Meter")
			local meterUp = (meter and meter.Enabled) or (dunkMeter and dunkMeter.Enabled)
			local hasBall = char:FindFirstChild("BallConnect")
			local value = power.Value
			local now = os.clock()

			if hasBall then
				if hasBall:IsA("JointInstance") then
					local p = (hasBall.Part1 and hasBall.Part1 ~= char:FindFirstChild("Right Arm") and hasBall.Part1) or hasBall.Part0
					if p and p:IsA("BasePart") then LastHeldBall = p end
				elseif hasBall:IsA("ObjectValue") and hasBall.Value and hasBall.Value:IsA("BasePart") then
					LastHeldBall = hasBall.Value
				end
			end

			if not armed then
				if not meterUp or not hasBall or value <= 0 then
					resetEngine()
				else
					armed = true
					started = now
				end
			elseif now - started > 0.15 and (value <= 0 or not meterUp or not hasBall) then
				resetEngine()
			end

			if value ~= oldPower then
				if not firstTime and value > 0 then
					firstPower = value
					firstTime = now
				elseif value > oldPower and now - firstTime >= 0.05 then
					rate = (value - firstPower) / (now - firstTime)
				end
				oldPower = value
				oldTime = now
			end

			if not fired and rate > 0 then
				if not family then
					family, animation = getShot(char)
					if not family and lastAction == "Shooting" and (os.clock() - lastRemote < 1.5) then
						local isLayupDetail = lastDetail and (string.find(tostring(lastDetail), "Layup") or string.find(tostring(lastDetail), "Scoop") or string.find(tostring(lastDetail), "Euro"))
						if isLayupDetail then
							family = "LayupAnimations"
							animation = tostring(lastDetail)
						end
					end
				end
				if family then
					local shot = family .. "/" .. animation
					local isLayup = family == "LayupAnimations" or (lastDetail and (string.find(tostring(lastDetail), "Layup") or string.find(tostring(lastDetail), "Scoop") or string.find(tostring(lastDetail), "Euro")))
					local isFloater = family == "FloaterAnimations" or (lastDetail and string.find(tostring(lastDetail), "Floater"))

					local target
					if now < window and low and high and (high > low) then
						target = (low + high) / 2
					else
						if isLayup then
							target = 64.0
						elseif isFloater then
							target = 68.0
						else
							target = 76.0
						end
					end

					local oneWay = (ping + (curState.ManualPingOffset or 0)) / 2000
					local lead = math.clamp(oneWay + (biases[shot] or 0.005), 0, 0.5)
					local predicted = value + rate * math.min(now - oldTime, 0.08)

					if predicted >= target - rate * lead then
						fired = true
						lastShotTime = os.clock()
						pending = {name = shot, power = predicted, rate = rate, ping = oneWay, time = now}
						if release(char) == false then
							fired = false
							pending = nil
						end
					end
				end
			end
		end
	end

	if curState.SilentAim and not IsFreeTier and (os.clock() - lastShotTime < 2.5) then
		local activeBall = LastHeldBall
		if activeBall and activeBall.Parent and activeBall:IsDescendantOf(workspace) and not activeBall:IsDescendantOf(char) then
			pcall(function()
				if activeBall:CanSetNetworkOwnership() then activeBall:SetNetworkOwner(LocalPlayer) end
			end)
		end
	end
end)

-- Sticky Defense Assist
Vesper:Connect(RunService.RenderStepped, function()
	if getgenv().RH2_Unloaded then return end
	local curState = GetState()
	if not curState.AutoGuard or IsFreeTier then return end

	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local env = GetGameplayEnv()
	if env and env.getClosestPlayerWithBall then
		pcall(function()
			local enemy = env.getClosestPlayerWithBall()
			local eChar = SafeGetCharacter(enemy)
			if eChar and eChar ~= char then
				local eHrp = eChar:FindFirstChild("HumanoidRootPart")
				if eHrp then
					local dist = (hrp.Position - eHrp.Position).Magnitude
					if dist <= curState.AutoGuardRange and dist > 3.0 then
						local lookPos = Vector3.new(eHrp.Position.X, hrp.Position.Y, eHrp.Position.Z)
						hrp.CFrame = CFrame.lookAt(hrp.Position, lookPos)
						local moveDir = (eHrp.Position - hrp.Position).Unit
						hrp.CFrame = hrp.CFrame + (moveDir * 0.08)
						if env.selectDefenseAnimation then pcall(env.selectDefenseAnimation) end
					end
				end
			end
		end)
	end
end)

-- Steal System
local lastStealTime = 0
local function ExecuteStealAction(targetName)
	local env = GetGameplayEnv()
	local curState = GetState()
	local success = false

	if env and env.StealingDebounces then
		local ok = pcall(env.StealingDebounces)
		if ok then success = true end
	end

	pcall(function()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.defer(function()
			task.wait(0.04)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end)
		success = true
	end)

	if success then
		curState.TotalSteals = (curState.TotalSteals or 0) + 1
		curState.LastAction = "Steal " .. tostring(targetName or "Enemy")
	end
	return success
end

Vesper:Connect(RunService.Heartbeat, function()
	if getgenv().RH2_Unloaded then return end
	local curState = GetState()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local now = os.clock()
	local isShootingOrCooldown = armed or (os.clock() - lastShotTime < 2.5)

	-- Auto Steal
	if not curState.AutoSteal then return end
	if now - lastStealTime < (curState.StealCooldown or 0.15) then return end

	local targetChar = nil
	local targetDist = curState.StealAuraRange or 12

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("BallConnect") then
			local pHrp = pl.Character:FindFirstChild("HumanoidRootPart")
			if pHrp then
				local d = (hrp.Position - pHrp.Position).Magnitude
				if d <= targetDist then
					targetDist = d
					targetChar = pl.Character
				end
			end
		end
	end

	if targetChar then
		lastStealTime = now
		ExecuteStealAction(targetChar.Name)
	end
end)

-- CFrame Speed & Ghost Stamina Loop
Vesper:Connect(RunService.Heartbeat, function(dt)
	if getgenv().RH2_Unloaded then return end
	local curState = GetState()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if curState.SpeedBoost and hrp and hum and hum.MoveDirection.Magnitude > 0 then
		local factor = (curState.SpeedMultiplier - 1.0) * 16 * dt
		hrp.CFrame = hrp.CFrame + (hum.MoveDirection * factor)
	end

	local env = GetGameplayEnv()
	if env and curState.GhostSprint then
		env.V_Stamina = 100
		env.lockDecreaseSpeed = false
		env.lockSpeed = false
		if env.updateStaminaMeter then pcall(env.updateStaminaMeter, 100) end
	end

	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local av = backpack and backpack:FindFirstChild("ActionValues")
	local stVal = av and av:FindFirstChild("Stamina")
	if stVal and curState.GhostSprint and stVal.Value < 100 then
		stVal.Value = 100
	end
end)

-- Anti-AFK
Vesper:Connect(LocalPlayer.Idled, function()
	local curState = GetState()
	if curState and curState.AntiAFK and not getgenv().RH2_Unloaded then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

-- =====================================================================
-- 3. VESPER UI RH2 INTERFACE (FULLY IN ENGLISH)
-- =====================================================================

-- Dynamic lists (always match current game content)
pcall(function()
	UnlockAll.GreenSoundsList = UnlockAll.GetGreenSounds()
	UnlockAll.GreenEffectsList = UnlockAll.GetGreenEffects()
	if not table.find(UnlockAll.GreenSoundsList, UnlockAll.SelectedGreenSound) then UnlockAll.SelectedGreenSound = UnlockAll.GreenSoundsList[1] end
	if not table.find(UnlockAll.GreenEffectsList, UnlockAll.SelectedGreenEffect) then UnlockAll.SelectedGreenEffect = UnlockAll.GreenEffectsList[1] end
	local cws = UnlockAll.GetShoeColorways(UnlockAll.SelectedShoe)
	if not table.find(cws, UnlockAll.SelectedShoeColor) then UnlockAll.SelectedShoeColor = cws[1] end
end)

local Window = Vesper:CreateWindow({
	Title       = "NW HUB",
	Subtitle    = "RH2: THE JOURNEY",
	Footer      = "v5.2.0-kyoka",
	Tier        = IsFreeTier and "FREE EDITION" or "VIP PREMIUM",
	Size        = UDim2.fromOffset(720, 470),
	Accent      = Color3.fromRGB(124, 108, 255),
	ForceAccent = true,
	ToggleKey   = Enum.KeyCode.RightControl,
	StatusRight = "RCtrl to toggle",
})

Vesper:SetWatermark("NW HUB / RH2 / FPS {fps} / {ping} / {time}", true)
Vesper:SetKeybindListVisible(false)

-- ----------------- TAB 1 : OFFENSE -----------------
local OffenseTab = Window:AddTab("Offense")
local TimingPage = OffenseTab:AddPage("Timing")
local BypassPage = OffenseTab:AddPage("Bypass")

local TimingGroup = TimingPage:AddGroup("Shot & Precision", "Left")
TimingGroup:AddToggle("AutoGreen", {
	Text = "Auto Green",
	Default = State.AutoGreen,
	Tooltip = "Triggers absolute green timing at 76.0ms",
	Callback = function(v) State.AutoGreen = v end
})

TimingGroup:AddSlider("ManualPingOffset", {
	Text = "Ping Offset",
	Min = -35,
	Max = 35,
	Default = State.ManualPingOffset,
	Rounding = 0,
	Suffix = "ms",
	Tooltip = "Fine-tune network latency compensation",
	Callback = function(v) State.ManualPingOffset = v end
})

local BypassGroup = BypassPage:AddGroup("Opponent Defense", "Left")
BypassGroup:AddToggle("AntiContest", {
	Text = (IsFreeTier and "🔒 " or "") .. "Always Open",
	Locked = IsFreeTier,
	LockedText = "Always Open is VIP-only.",
	Default = State.AntiContest,
	Tooltip = "Forces 0% contest on all your shots",
	Callback = function(v) if PaidGate("Always Open") then return end State.AntiContest = v end
})

BypassGroup:AddToggle("SilentAim", {
	Text = (IsFreeTier and "🔒 " or "") .. "Silent Aim",
	Locked = IsFreeTier,
	LockedText = "Silent Aim is VIP-only.",
	Default = State.SilentAim,
	Tooltip = "Guarantees network ball ownership on release",
	Callback = function(v) if PaidGate("Silent Aim") then return end State.SilentAim = v end
})

local StatsOffGroup = TimingPage:AddGroup("Shot Statistics", "Right")
local ShotLabel = StatsOffGroup:AddLabel("Shots: 0")
local GreenLabel = StatsOffGroup:AddLabel("Greens: 0")
local ActionLabel = StatsOffGroup:AddLabel("Status: Idle")

-- ----------------- TAB 2 : MOVEMENT -----------------
local MoveTab = Window:AddTab("Movement")
local MoveGroup = MoveTab:AddGroup("Stamina & Speed", "Left")

MoveGroup:AddToggle("GhostSprint", {
	Text = "Ghost Sprint",
	Default = State.GhostSprint,
	Tooltip = "Infinite stamina without notifying the server",
	Callback = function(v) State.GhostSprint = v end
})

MoveGroup:AddToggle("SpeedBoost", {
	Text = "Speed Boost",
	Default = State.SpeedBoost,
	Tooltip = "Smooth CFrame sprint amplification",
	Callback = function(v) State.SpeedBoost = v end
})

MoveGroup:AddSlider("SpeedMultiplier", {
	Text = "Speed Multiplier",
	Min = 1.0,
	Max = 2.2,
	Default = State.SpeedMultiplier,
	Rounding = 2,
	Suffix = "x",
	Callback = function(v) State.SpeedMultiplier = v end
})

-- ----------------- TAB 3 : DEFENSE -----------------
local DefTab = Window:AddTab("Defense")
local GuardGroup = DefTab:AddGroup("Auto Guard & Steal", "Left")

GuardGroup:AddToggle("AutoGuard", {
	Text = (IsFreeTier and "🔒 " or "") .. "Sticky Guard",
	Locked = IsFreeTier,
	LockedText = "Sticky Guard is VIP-only.",
	Default = State.AutoGuard,
	Tooltip = "Automatically tracks and locks onto ball handler",
	Callback = function(v) if PaidGate("Sticky Guard") then return end State.AutoGuard = v end
})

GuardGroup:AddSlider("AutoGuardRange", {
	Text = "Guard Range",
	Min = 6,
	Max = 20,
	Default = State.AutoGuardRange,
	Suffix = "studs",
	Callback = function(v) State.AutoGuardRange = v end
})

GuardGroup:AddToggle("AutoSteal", {
	Text = "Auto Steal",
	Default = State.AutoSteal,
	Tooltip = "Automatically swipes ball when in range",
	Callback = function(v) State.AutoSteal = v end
})
:AddKeybind("StealKey", {
	Default = Enum.KeyCode.F,
	Mode = "Hold",
	Tooltip = "Manual force steal keybind",
	Callback = function(s) if s then ExecuteStealAction("Manual Key") end end
})

GuardGroup:AddSlider("StealAuraRange", {
	Text = "Steal Range",
	Min = 4,
	Max = 20,
	Default = State.StealAuraRange,
	Suffix = "studs",
	Callback = function(v) State.StealAuraRange = v end
})

local StealsCountLabel = GuardGroup:AddLabel("Steals: 0")

-- ----------------- TAB 4 : ANIMATIONS (SERVER REPLICATED) -----------------
local UnlockTab = Window:AddTab("Animations")
local JumpDunkGroup = UnlockTab:AddGroup("Signature Shots & Dunks", "Left")
local DribbleCelebGroup = UnlockTab:AddGroup("Dribbles & Releases", "Right")

-- Jumpshots
JumpDunkGroup:AddDropdown("UnlockJumpshot", {
	Text = (IsFreeTier and "🔒 " or "") .. "Jumpshot Package",
	Values = UnlockAll.JumpshotList,
	Default = UnlockAll.SelectedJumpshot,
	Tooltip = "Select any signature jumpshot (Server replicated to all players)",
	Callback = function(choice) UnlockAll.SelectedJumpshot = choice end
})

JumpDunkGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Jumpshot Package", {
	Accent = true,
	Tooltip = "Injects jumpshot into Backpack & triggers server replication",
	Callback = function() UnlockAll.EquipJumpshot(UnlockAll.SelectedJumpshot) end
})

JumpDunkGroup:AddDivider()

-- Dunks
JumpDunkGroup:AddDropdown("UnlockDunk", {
	Text = (IsFreeTier and "🔒 " or "") .. "Dunk Package",
	Values = UnlockAll.DunkList,
	Default = UnlockAll.SelectedDunk,
	Tooltip = "Select signature dunk package (Server replicated to all players)",
	Callback = function(choice) UnlockAll.SelectedDunk = choice end
})

JumpDunkGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Dunk Package", {
	Accent = true,
	Tooltip = "Injects dunk package into Backpack & updates humanoid tracks",
	Callback = function() UnlockAll.EquipDunk(UnlockAll.SelectedDunk) end
})

JumpDunkGroup:AddDivider()

-- Celebrations
JumpDunkGroup:AddDropdown("UnlockCelebration", {
	Text = (IsFreeTier and "🔒 " or "") .. "Green Celebration",
	Values = UnlockAll.CelebrationList,
	Default = UnlockAll.SelectedCelebration,
	Tooltip = "Select signature landing celebration",
	Callback = function(choice) UnlockAll.SelectedCelebration = choice end
})

JumpDunkGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Celebration", {
	Tooltip = "Equips green landing celebration animation",
	Callback = function() UnlockAll.EquipCelebration(UnlockAll.SelectedCelebration) end
})

-- Crossovers
DribbleCelebGroup:AddDropdown("UnlockCrossover", {
	Text = (IsFreeTier and "🔒 " or "") .. "Crossover Moves",
	Values = UnlockAll.CrossoverList,
	Default = UnlockAll.SelectedCrossover,
	Tooltip = "Select signature crossover package",
	Callback = function(choice) UnlockAll.SelectedCrossover = choice end
})

DribbleCelebGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Crossover Moves", {
	Accent = true,
	Tooltip = "Equips crossover animations into Backpack",
	Callback = function() UnlockAll.EquipCrossover(UnlockAll.SelectedCrossover) end
})

DribbleCelebGroup:AddDivider()

-- Behind The Back
DribbleCelebGroup:AddDropdown("UnlockBehindTheBack", {
	Text = (IsFreeTier and "🔒 " or "") .. "Behind The Back Moves",
	Values = UnlockAll.BehindTheBackList,
	Default = UnlockAll.SelectedBehindTheBack,
	Tooltip = "Select signature behind-the-back animations",
	Callback = function(choice) UnlockAll.SelectedBehindTheBack = choice end
})

DribbleCelebGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Behind The Back Moves", {
	Accent = true,
	Tooltip = "Equips behind-the-back animations into Backpack",
	Callback = function() UnlockAll.EquipBehindTheBack(UnlockAll.SelectedBehindTheBack) end
})

local HandlesGroup = UnlockTab:AddGroup("Handles+ (BTL / Hesi / Stepback / Style)", "Left")

HandlesGroup:AddDropdown("UnlockBetweenLegs", {
	Text = (IsFreeTier and "🔒 " or "") .. "Between The Legs",
	Values = UnlockAll.BetweenLegsList,
	Default = UnlockAll.SelectedBetweenLegs,
	Callback = function(choice) UnlockAll.SelectedBetweenLegs = choice end
})

HandlesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Between The Legs", {
	Accent = true,
	Callback = function() UnlockAll.EquipBetweenLegs(UnlockAll.SelectedBetweenLegs) end
})

HandlesGroup:AddDropdown("UnlockHesi", {
	Text = (IsFreeTier and "🔒 " or "") .. "Hesi Moves",
	Values = UnlockAll.HesiList,
	Default = UnlockAll.SelectedHesi,
	Callback = function(choice) UnlockAll.SelectedHesi = choice end
})

HandlesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Hesi", {
	Accent = true,
	Callback = function() UnlockAll.EquipHesi(UnlockAll.SelectedHesi) end
})

HandlesGroup:AddDropdown("UnlockStepback", {
	Text = (IsFreeTier and "🔒 " or "") .. "Stepback Moves",
	Values = UnlockAll.StepbackList,
	Default = UnlockAll.SelectedStepback,
	Callback = function(choice) UnlockAll.SelectedStepback = choice end
})

HandlesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Stepback", {
	Accent = true,
	Callback = function() UnlockAll.EquipStepback(UnlockAll.SelectedStepback) end
})

HandlesGroup:AddDropdown("UnlockDribbleStyle", {
	Text = (IsFreeTier and "🔒 " or "") .. "Dribble Style",
	Values = UnlockAll.DribbleStyleList,
	Default = UnlockAll.SelectedDribbleStyle,
	Callback = function(choice) UnlockAll.SelectedDribbleStyle = choice end
})

HandlesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Dribble Style", {
	Accent = true,
	Callback = function() UnlockAll.EquipDribbleStyle(UnlockAll.SelectedDribbleStyle) end
})

local FinishGroup = UnlockTab:AddGroup("Layups, Floaters & Post", "Right")

FinishGroup:AddDropdown("UnlockLayup", {
	Text = (IsFreeTier and "🔒 " or "") .. "Layup Package",
	Values = UnlockAll.LayupList,
	Default = UnlockAll.SelectedLayup,
	Callback = function(choice) UnlockAll.SelectedLayup = choice end
})

FinishGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Layup Package", {
	Accent = true,
	Callback = function() UnlockAll.EquipLayup(UnlockAll.SelectedLayup) end
})

FinishGroup:AddDropdown("UnlockFloater", {
	Text = (IsFreeTier and "🔒 " or "") .. "Floater Package",
	Values = UnlockAll.FloaterList,
	Default = UnlockAll.SelectedFloater,
	Callback = function(choice) UnlockAll.SelectedFloater = choice end
})

FinishGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Floater Package", {
	Accent = true,
	Callback = function() UnlockAll.EquipFloater(UnlockAll.SelectedFloater) end
})

FinishGroup:AddDropdown("UnlockPost", {
	Text = (IsFreeTier and "🔒 " or "") .. "Post Moves",
	Values = UnlockAll.PostList,
	Default = UnlockAll.SelectedPost,
	Callback = function(choice) UnlockAll.SelectedPost = choice end
})

FinishGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Post Moves", {
	Accent = true,
	Callback = function() UnlockAll.EquipPost(UnlockAll.SelectedPost) end
})

-- ----------------- TAB 5 : LOCKER -----------------
local LockerTab = Window:AddTab("Locker")

if IsFreeTier then
	local VipGroup = LockerTab:AddGroup("VIP Upgrade", "Left")
	VipGroup:AddParagraph("Locked features", "Animations, outfits, Silent Aim, Always Open and Sticky Guard are VIP-only." .. (_tierEnv.__NW_KEYTAG and (" Session tag: ****-" .. tostring(_tierEnv.__NW_KEYTAG) .. ".") or ""))
	VipGroup:AddButton("Copy Discord Invite", {
		Accent = true,
		Callback = function()
			pcall(function()
				if type(setclipboard) == "function" then setclipboard("https://discord.gg/Gp2N788WVh") end
			end)
			Vesper:Notify({ Title = "VIP", Content = "Discord invite copied!", Type = "success" })
		end
	})
end
local LockerGroup = LockerTab:AddGroup("Outfits", "Left")

LockerGroup:AddDropdown("UnlockTop", {
	Text = (IsFreeTier and "🔒 " or "") .. "Top",
	Values = UnlockAll.CuratedTops,
	Default = UnlockAll.SelectedTop,
	Tooltip = "Select top (verified in-game names)",
	Callback = function(choice) UnlockAll.SelectedTop = choice end
})

LockerGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Top", {
	Accent = true,
	Tooltip = "Equips top on character",
	Callback = function() UnlockAll.EquipTop(UnlockAll.SelectedTop) end
})

LockerGroup:AddDropdown("UnlockBottom", {
	Text = (IsFreeTier and "🔒 " or "") .. "Bottom",
	Values = UnlockAll.CuratedBottoms,
	Default = UnlockAll.SelectedBottom,
	Tooltip = "Select bottom (verified in-game names)",
	Callback = function(choice) UnlockAll.SelectedBottom = choice end
})

LockerGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Bottom", {
	Accent = true,
	Tooltip = "Equips bottom on character",
	Callback = function() UnlockAll.EquipBottom(UnlockAll.SelectedBottom) end
})

LockerGroup:AddDropdown("UnlockMascot", {
	Text = (IsFreeTier and "🔒 " or "") .. "Mascot",
	Values = UnlockAll.MascotList,
	Default = UnlockAll.SelectedMascot,
	Tooltip = "Select mascot outfit",
	Callback = function(choice) UnlockAll.SelectedMascot = choice end
})

LockerGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Mascot", {
	Accent = true,
	Tooltip = "Equips mascot outfit on character",
	Callback = function() UnlockAll.EquipMascot(UnlockAll.SelectedMascot) end
})

LockerGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Restore Original Outfit", {
	Tooltip = "Restores outfit from before hub usage",
	Callback = function() VisualUnlock.Restore() end
})

local LockerRight = LockerTab:AddGroup("Presets & Unlocks", "Right")

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Lakers #24 (Bryant)", {
	Callback = function() VisualUnlock.ApplyPreset("Lakers24") end
})

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Bulls #23 (Jordan)", {
	Callback = function() VisualUnlock.ApplyPreset("Bulls23") end
})

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Warriors #30 (Curry)", {
	Callback = function() VisualUnlock.ApplyPreset("Warriors30") end
})

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Celtics #0 (Tatum)", {
	Callback = function() VisualUnlock.ApplyPreset("Celtics0") end
})

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Clone Nearest Player", {
	Callback = function() VisualUnlock.CloneNearestPlayer() end
})

LockerRight:AddDivider()

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Unlock All Gamepasses", {
	Accent = true,
	Tooltip = "Spoofs UserOwnsGamePassAsync to true",
	Callback = function() UnlockAll.HookGamepasses() end
})

LockerRight:AddButton((IsFreeTier and "🔒 " or "") .. "Unlock Menu (Lv40 Premium)", {
	Accent = true,
	Tooltip = "Unlocks all tops/bottoms/shoes + premium journey pass",
	Callback = function() UnlockAll.UnlockMenu() end
})

local ShoesGroup = LockerTab:AddGroup("Shoes & Greens", "Left")

ShoesGroup:AddDropdown("UnlockShoe", {
	Text = (IsFreeTier and "🔒 " or "") .. "Shoe Model",
	Values = UnlockAll.ShoeList,
	Default = UnlockAll.SelectedShoe,
	Callback = function(choice)
		UnlockAll.SelectedShoe = choice
		local cws = UnlockAll.GetShoeColorways(choice)
		UnlockAll.SelectedShoeColor = cws[1]
		if Vesper.Options.UnlockShoeColor then Vesper.Options.UnlockShoeColor:SetValues(cws, true) Vesper.Options.UnlockShoeColor:Set(cws[1]) end
	end
})

local ShoeColorDropdown = ShoesGroup:AddDropdown("UnlockShoeColor", {
	Text = (IsFreeTier and "🔒 " or "") .. "Colorway",
	Values = UnlockAll.GetShoeColorways(UnlockAll.SelectedShoe),
	Default = UnlockAll.SelectedShoeColor,
	Callback = function(choice) UnlockAll.SelectedShoeColor = choice end
})

ShoesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Shoes", {
	Accent = true,
	Tooltip = "Sends Change Shoes request (server replicated if owned/unlocked)",
	Callback = function() UnlockAll.EquipShoes(UnlockAll.SelectedShoe, UnlockAll.SelectedShoeColor) end
})

ShoesGroup:AddDropdown("UnlockGreenSound", {
	Text = (IsFreeTier and "🔒 " or "") .. "Green Sound",
	Values = UnlockAll.GreenSoundsList,
	Default = UnlockAll.SelectedGreenSound,
	Callback = function(choice) UnlockAll.SelectedGreenSound = choice end
})

ShoesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Green Sound", {
	Tooltip = "Plays preview + sends equip request",
	Callback = function() UnlockAll.EquipGreenSound(UnlockAll.SelectedGreenSound) end
})

ShoesGroup:AddDropdown("UnlockGreenEffect", {
	Text = (IsFreeTier and "🔒 " or "") .. "Green Effect",
	Values = UnlockAll.GreenEffectsList,
	Default = UnlockAll.SelectedGreenEffect,
	Callback = function(choice) UnlockAll.SelectedGreenEffect = choice end
})

ShoesGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Equip Green Effect", {
	Tooltip = "Sends equip request",
	Callback = function() UnlockAll.EquipGreenEffect(UnlockAll.SelectedGreenEffect) end
})

-- ----------------- TAB 6 : SETTINGS -----------------
local SettingsTab = Window:AddTab("Settings")
local PresetsGroup = SettingsTab:AddGroup("Profiles & Presets", "Left")

PresetsGroup:AddButton("Legit Preset", {
	Callback = function()
		State.AutoGreen = true
		State.AntiContest = false
		State.GhostSprint = false
		State.SpeedBoost = true
		State.SpeedMultiplier = 1.15
		State.AutoGuard = false
		State.AutoSteal = true
		State.StealAuraRange = 6
		Vesper.Options.AutoGreen:Set(true)
		Vesper.Options.AntiContest:Set(false)
		Vesper.Options.GhostSprint:Set(false)
		Vesper.Options.SpeedBoost:Set(true)
		Vesper.Options.SpeedMultiplier:Set(1.15)
		Vesper.Options.AutoGuard:Set(false)
		Vesper.Options.AutoSteal:Set(true)
		Vesper.Options.StealAuraRange:Set(6)
		Vesper:Notify({ Title = "Preset", Content = "Legit preset activated", Type = "success" })
	end
})

PresetsGroup:AddButton((IsFreeTier and "🔒 " or "") .. "Rage / God-Tier Preset", {
	Accent = true,
	Callback = function()
		if PaidGate("Rage preset") then return end
		State.AutoGreen = true
		State.AntiContest = true
		State.GhostSprint = true
		State.SpeedBoost = true
		State.SpeedMultiplier = 1.65
		State.AutoGuard = true
		State.AutoGuardRange = 16
		State.AutoSteal = true
		State.StealAuraRange = 16
		Vesper.Options.AutoGreen:Set(true)
		Vesper.Options.AntiContest:Set(true)
		Vesper.Options.GhostSprint:Set(true)
		Vesper.Options.SpeedBoost:Set(true)
		Vesper.Options.SpeedMultiplier:Set(1.65)
		Vesper.Options.AutoGuard:Set(true)
		Vesper.Options.AutoGuardRange:Set(16)
		Vesper.Options.AutoSteal:Set(true)
		Vesper.Options.StealAuraRange:Set(16)
		Vesper:Notify({ Title = "Preset", Content = "God-Tier preset activated", Type = "success" })
	end
})

local ConfigsGroup = SettingsTab:AddGroup("Configurations & Profiles", "Left")

local rh2ConfigName = "rh2_default"
local rh2ConfigDropdown = nil

local function getRh2Configs()
	local list = Vesper:ListConfigs("nwhub_rh2")
	if #list == 0 then list = { "rh2_default" } end
	return list
end

ConfigsGroup:AddTextbox("Rh2ConfigInput", {
	Text = "Config Name",
	Default = "rh2_default",
	Placeholder = "Config name...",
	Callback = function(val)
		if val and val:match("%S") then
			rh2ConfigName = val:match("^%s*(.-)%s*$")
		end
	end
})

rh2ConfigDropdown = ConfigsGroup:AddDropdown("Rh2SavedConfigs", {
	Text = "Saved Configs",
	Values = getRh2Configs(),
	Default = "rh2_default",
	Tooltip = "Select a saved configuration file",
	Callback = function(val)
		rh2ConfigName = val
		if Vesper.Options.Rh2ConfigInput then
			Vesper.Options.Rh2ConfigInput:Set(val)
		end
	end
})

ConfigsGroup:AddButton("Save Configuration", {
	Callback = function()
		local name = rh2ConfigName or "rh2_default"
		local ok, err = Vesper:SaveConfigToFile(name, "nwhub_rh2")
		if ok then
			Vesper:Notify({ Title = "Config Manager", Content = "Saved '" .. name .. ".json'", Type = "success" })
			if rh2ConfigDropdown then rh2ConfigDropdown:SetValues(getRh2Configs(), true) end
		else
			Vesper:Notify({ Title = "Config Error", Content = tostring(err or "Failed to save"), Type = "error" })
		end
	end
})

ConfigsGroup:AddButton("Load Configuration", {
	Callback = function()
		local name = rh2ConfigName or "rh2_default"
		local ok, err = Vesper:LoadConfigFromFile(name, "nwhub_rh2")
		if ok then
			Vesper:Notify({ Title = "Config Manager", Content = "Loaded '" .. name .. ".json'", Type = "success" })
		else
			Vesper:Notify({ Title = "Config Error", Content = tostring(err or "Config not found"), Type = "error" })
		end
	end
})

ConfigsGroup:AddButton("Refresh Configs List", {
	Callback = function()
		if rh2ConfigDropdown then
			rh2ConfigDropdown:SetValues(getRh2Configs(), true)
			Vesper:Notify({ Title = "Config Manager", Content = "Refreshed configs list", Type = "info" })
		end
	end
})

local SysGroup = SettingsTab:AddGroup("Interface & Unload", "Right")

SysGroup:AddToggle("ShowWatermark", {
	Text = "Show Watermark (FPS / Ping)",
	Default = true,
	Tooltip = "Toggle top watermark bar with FPS and Ping stats",
	Callback = function(v) Vesper:SetWatermarkVisible(v) end
})

SysGroup:AddToggle("ShowKeybinds", {
	Text = "Show Keybinds List",
	Default = false,
	Tooltip = "Toggle active keybinds list overlay",
	Callback = function(v) Vesper:SetKeybindListVisible(v) end
})

SysGroup:AddSlider("UiScale", {
	Text = "UI Scale",
	Min = 1.0,
	Max = 2.5,
	Default = Vesper.Scale or 1.8,
	Rounding = 1,
	Suffix = "x",
	Tooltip = "Global interface scale factor (1.8x default)",
	Callback = function(v) Vesper:SetScale(v) end
})

SysGroup:AddToggle("CustomCursor", {
	Text = "Vesper Cursor",
	Default = true,
	Tooltip = "Pixel vector cursor with drop shadow",
	Callback = function(v) Vesper:SetCursorEnabled(v) end
})

SysGroup:AddColorPicker("AccentColor", {
	Text = "Accent Color",
	Default = Vesper.Theme.Accent,
	Callback = function(c) Vesper:SetAccent(c) end
})

SysGroup:AddKeybind("ToggleBind", {
	Text = "Menu Keybind",
	Default = Enum.KeyCode.RightControl,
	Changed = function(v)
		if v.Key then
			Vesper.ToggleKey = v.Key
			local kName = (Vesper.KeyName and Vesper.KeyName(v.Key)) or tostring(v.Key.Name)
			Window:SetStatus(nil, kName .. " to toggle")
			Vesper:Notify({ Title = "Menu Keybind", Content = "Toggle key set to " .. kName, Duration = 2, Type = "info" })
		end
	end
})

SysGroup:AddToggle("AntiAFK", {
	Text = "Anti-AFK",
	Default = State.AntiAFK,
	Callback = function(v) State.AntiAFK = v end
})

SysGroup:AddDivider()

SysGroup:AddButton("Unload Hub", {
	Callback = function()
		getgenv().RH2_Unloaded = true
		getgenv().RH2_State = nil
		getgenv().RH2_UnloadFunction = nil
		Vesper:Unload()
	end
})

getgenv().RH2_UnloadFunction = function()
	getgenv().RH2_Unloaded = true
	getgenv().RH2_State = nil
	getgenv().RH2_UnloadFunction = nil
	Vesper:Unload()
end

-- Stats background synchronization loop
task.spawn(function()
	while not getgenv().RH2_Unloaded do
		pcall(function()
			local curState = GetState()
			ShotLabel:SetText("Shots: " .. tostring(curState.TotalShots or 0))
			GreenLabel:SetText("Greens: " .. tostring(curState.TotalGreens or 0))
			ActionLabel:SetText("Status: " .. tostring(curState.LastAction or "Idle"))
			StealsCountLabel:SetText("Steals: " .. tostring(curState.TotalSteals or 0))
		end)
		task.wait(0.3)
	end
end)

Vesper:Notify({
	Title = "NW Hub | RH2",
	Content = "Kyoka UI loaded. Press RightControl.",
	Duration = 5,
	Type = "success",
})

return Vesper