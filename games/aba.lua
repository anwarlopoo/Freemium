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

-- Anti-spam Execute : si un chargement est deja en cours, ce run est ignore.
-- (Spammer Execute pendant le boot du blob 2.8 Mo cree des inits concurrentes :
-- l'unload n'existe pas encore a mi-chargement, donc les loops de l'ancien run
-- survivaient + GUI a moitie construite = freeze.) Watchdog 30s anti-blocage.
if getgenv().__NW_ABA_LOADING == true then return end
getgenv().__NW_ABA_LOADING = true
task.delay(30, function()
    pcall(function() getgenv().__NW_ABA_LOADING = false end)
end)

-- =========================================================================
--  NW HUB | ANIME BATTLE ARENA (ABA) [KYŌKA SUIGETSU EDITION]
--  Architecture: Pure Kyōka UI v1.0.0 Native • Zero Rayfield Adapter
--  100% Undetected • Anti-NetworkMonitor Protection • Authentic Input Pipeline
-- =========================================================================

-- Pre-instance cleanup
pcall(function()
    if getgenv().ABA_UnloadFunction then
        pcall(getgenv().ABA_UnloadFunction)
        task.wait(0.15)
    end
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            for _, c in ipairs(cam:GetChildren()) do
                if c:IsA("BlurEffect") or c.Name:find("Kyoka") or c.Name:find("Blur") then
                    c:Destroy()
                end
            end
        end
    end)
    local targets = {}
    if gethui then pcall(function() table.insert(targets, gethui()) end) end
    pcall(function() table.insert(targets, game:GetService("CoreGui")) end)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp:FindFirstChild("PlayerGui") then
            table.insert(targets, lp.PlayerGui)
        end
    end)
    for _, parent in ipairs(targets) do
        for _, c in ipairs(parent:GetChildren()) do
            if c:IsA("ScreenGui") and (c.Name:find("Vesper") or c.Name:find("Kyoka") or c.Name:find("NWHub") or c.Name:find("ABA")) then
                pcall(function() c:Destroy() end)
            end
        end
    end
end)

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
			local win = tab.Window or (Library and Library.Window) or self
			for _, other in ipairs((win and win.Tabs) or {}) do
				if other ~= tab then
					other.Content.Visible = false
					other.PillBox.Visible = false
					other.Paint(false)
				end
			end
			win.ActiveTab = tab
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
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 10, 1, -10),
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
				-- Coin bas-gauche : ne couvre plus la barre de vie (en haut au centre)
				Watermark.Position = UDim2.new(0, 10, 1, -10)
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


local Vesper = Kyoka


-- Pre-unload existing active instance
if getgenv().ABA_UnloadFunction then
    pcall(getgenv().ABA_UnloadFunction)
    task.wait(0.15)
end

getgenv().ABA_Unloaded = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Connections = {}

local State = {
    -- Combat (Auto-Parry / Defense)
    AutoBlock = false,             -- Disabled by default, matches UI toggle (Default = false)
    BlockMode = "Authentic Key (UD)", -- "Authentic Key (UD)" or "Direct Remote"
    BlockDistance = 16,    -- 16 studs tight melee combat range (prevents blocking in the void)
    HumanizerDelay = 0.04, -- Humanized reaction time (s)
    BlockDuration = 0.6,   -- Base duration to hold block (s)  -- Duration to hold block (s)
    BlockCooldown = 0.25,  -- Internal throttle cooldown (s)
    CheckFacing = true,    -- Only block if attacker faces us
    IgnoreTeammates = true,
    AutoDodge = true,      -- Enabled by default to dodge unblockable Guardbreaks (Default = true)
    -- Projectile & Skill Aimlock
    ProjectileLock = true,         -- Projectile / Skill Aimlock toggle
    LockMode = "Face and Camera",  -- "Face and Camera", "Face Only", "Camera Only"
    LockOnCast = true,             -- Auto-lock for 0.45s upon pressing 1, 2, 3, 4
    LockHoldKey = Enum.KeyCode.E,  -- Key to hold lock
    LockDistance = 150,            -- Max studs range for aimlock
    LockPredictVelocity = true,    -- Predict enemy movement based on velocity
    LockSmoothing = 0.35,          -- Camera smoothing factor (0.05 to 1.0)
    -- M1 Trade (Auto-Unblock & Counter M1 on Block Hit)
    M1Trade = true,
    M1TradeReaction = 0.02, -- Micro delay (s) after impact
    M1TradeImpactTiming = 0.16, -- Calibrated optimal window (live-tested)
    M1TradeAutoFace = true,     -- Authentic Q dash away on threat
    DodgeCooldown = 1.5,
    -- Auto Counter (persos avec un counter : le joue auto sur menace bloquable)
    AutoCounter = false,           -- OFF par défaut : ça dépense ton counter
    CounterSlot = "Auto",          -- "Auto" (détection par nom) ou "Slot 1".."Slot 4"
    CounterRange = 16,             -- Portée max de déclenchement (studs)
    CounterCooldown = 2.5,         -- Délai min entre deux counters (s)
    CounterHumanizer = 0.06,       -- Micro-délai avant d'appuyer (s)
    CounterCatchRange = 9,         -- Distance de déclenchement final : on attend que l'attaquant soit vraiment dessus
    CounterMaxWait = 0.35,         -- Attente max en suivi avant de forcer le counter (s)

    -- Awakening Automation
    AutoAwakening = false,         -- Disabled by default, matches UI toggle (Default = false)

    -- Auto Play (public bot: chase + M1 + skills + awaken)
    AutoPlay = false,              -- Master switch (Tab Auto Play)
    AutoPlay_M1 = true,            -- Spam M1 en melee
    AutoPlay_Skills = true,        -- Joue les moves 1-4 quand prets
    AutoPlay_Skill1 = true,
    AutoPlay_Skill2 = true,
    AutoPlay_Skill3 = true,
    AutoPlay_Skill4 = true,
    AutoPlay_Chase = true,         -- Suit la cible (Humanoid:MoveTo, pas de TP)
    AutoPlay_Awaken = true,        -- Appuie G quand la barre est pleine (pendant le bot)
    AutoPlay_TargetMode = "Closest", -- "Closest" ou "Lowest HP"
    AutoPlay_Range = 250,          -- Portee d'engagement (studs)
    AutoPlay_AttackRange = 9,      -- Portee M1 (studs)
    AutoPlay_SkillRange = 60,      -- Portee max pour lancer un skill (studs)
    AutoPlay_SkillDelay = 1.2,     -- Delai min entre deux skills (s)
    AutoPlay_AutoJump = true,      -- Saute quand coince contre un mur
    AutoPlay_MoveSpeed = 18,       -- Vitesse de chase en studs/s (stepping direct)
    AutoPlay_Humanize = true,      -- Timings humains : jitter, micro-pauses, strafes

    -- Imitation (enregistre TON style de jeu et le rejoue)
    ImitateEnabled = false,        -- Utilise les stats du recording charge

    -- UI persistence (sauvegarde dans les profils)
    KyokaEffects = true,           -- effets Kyoka (shatter)
    ShowWatermark = true,          -- filigrane
    QTEGate = true,                -- QTE auto uniquement pour les persos Black Flash
    EcoMode = false,               -- Eco mode: scan rates halved, Highlights off (weak devices)

    -- Tech (locks specifiques)
    TechBlueTP = false,            -- Blue (Gojo) : TP instant sur le joueur locke



    -- Move Aim & Hitbox Extender (Server-Authoritative Hijack)
    HitboxExtender = true,
    HitboxSize = 8,                -- Aim Assist range multiplier (range = HitboxSize * 8 + 20 studs)

    -- Anti-Ban & Safeguards
    AutoQTE = true,                 -- Solves Kokushibo, Black Flash, Nanami QTEs with humanized anti-macro jitter
    BlackFlashDelay = 0.03,          -- Micro-délai ajouté au clic d'ouverture de fenêtre BF (s)
    StaffDetector = true,           -- Scans for group rank >= 2 in 3735330
    StaffAction = "Notify & Hop",   -- "Notify Only", "Notify & Hop", "Instant Disconnect"
    AntiCombatTagHop = true,

    -- Visuals
    PlayerESP = true,              -- Enabled by default (Default = true)
    ShowBlocking = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowAwakenBar = true,          -- Live Awakening charge % / awakened state tracker
    ShowCooldowns = true,          -- Move 1-4 attack cooldown and active skill tracker
    Fullbright = false,            -- Disabled by default, matches UI toggle (Default = false)
    AntiInvis = true,               -- Reveals cloaked enemies (Sanji stealth, Zabuza Hidden Mist, etc.)
    AntiBlind = true,               -- Nullifies ScreenFlip flashbang and negative lighting filters
    AntiScreenShake = true,         -- Strips disorienting screen tremors from heavy ultimates

    -- Movement (Stealth)
    SpeedBoost = false,            -- Disabled by default, matches UI toggle (Default = false)
    SpeedMultiplier = 1.25,
    InfiniteJump = false,          -- Disabled by default, matches UI toggle (Default = false)

    -- Utility
    AntiAFK = true,

    -- Locomotion & Status Bypasses (Client-Native Anti-Ban)
    NoJumpPenalty = true,          -- Removes landing lag / jump fatigue by maintaining NoJumpPenalty tag
    DodgeWhileSlowed = true,       -- Allows dodging out of stuns/slows by maintaining DodgeOkay tag
    AntiConfuse = true,            -- Prevents Sakanade / Shinji control and move key reversal
    AntiGenjutsu = true,           -- Sight-Immunity: hooks IsLookingAt to evade gaze illusions/petrifications
    AutoTech = true,               -- Auto-recovers mid-air on downslam / knockdown using humanized Space tech
}

getgenv().ABA_State = State
local function GetState() return State end

-- ESP Tracking table
local ESPItems = {}
local GlobalMovelistCache = {}

-- Clean ESP helper with Bulletproof Unload & De-duplication
local function ClearESP()
    for _, item in ipairs(ESPItems) do
        if item.Highlight then pcall(function() item.Highlight:Destroy() end) end
        if item.MasterBillboard then pcall(function() item.MasterBillboard:Destroy() end) end
        if item.Billboard then pcall(function() item.Billboard:Destroy() end) end
    end
    table.clear(ESPItems)

    -- Thorough cleanup of any lingering billboards in Workspace
    pcall(function()
        local live = Workspace:FindFirstChild("Live")
        if live then
            for _, m in ipairs(live:GetChildren()) do
                for _, d in ipairs(m:GetDescendants()) do
                    if d:IsA("BillboardGui") and (d.Name == "ABA_ESP_MasterBillboard" or d.Name:find("ABA_ESP")) then
                        pcall(function() d:Destroy() end)
                    end
                end
            end
        end
    end)
end

-- Cleanup handler
getgenv().ABA_UnloadFunction = function()
    getgenv().ABA_Unloaded = true
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    ClearESP()
    pcall(function()
        local lm = Workspace:FindFirstChild("ABA_Vesper_LockMarker")
        if lm then lm:Destroy() end
    end)
    -- Deep scan for any remaining ESP artifacts
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, d in ipairs(p.Character:GetDescendants()) do
                if d:IsA("BillboardGui") and (d.Name == "ABA_ESP_MasterBillboard" or d.Name:find("ABA_ESP")) then
                    pcall(function() d:Destroy() end)
                end
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        local njp = char:FindFirstChild("NoJumpPenalty")
        if njp then pcall(function() njp:Destroy() end) end
        local dok = char:FindFirstChild("DodgeOkay")
        if dok then pcall(function() dok:Destroy() end) end
    end
    if InputRemote and originalFireServer then
        pcall(function()
            if typeof(hookfunction) == "function" then
                hookfunction(InputRemote.FireServer, originalFireServer)
            end
        end)
    end
    pcall(function() Vesper:Unload() end)
    print("[NW Hub] Anime Battle Arena Hub Unloaded cleanly.")
end

-- Anti-AFK
local afkConn = LocalPlayer.Idled:Connect(function()
    if State.AntiAFK and not getgenv().ABA_Unloaded then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end)
table.insert(Connections, afkConn)

-- Throttled Visuals & Lighting Watchdog (0.25s interval - eliminates 160 fps loop overhead)
local origAmbient = Lighting.Ambient
local origBrightness = Lighting.Brightness
local lastVisualThrottle = 0
local visualWatchdogConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local now = tick()
    if now - lastVisualThrottle < 0.25 then return end
    lastVisualThrottle = now

    if State.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    end

    if State.AntiBlind then
        local flip = Lighting:FindFirstChild("flipcolor")
        if flip and flip.Saturation < 0 then
            flip.Saturation = 0
        end
        local wb = Lighting:FindFirstChild("whitenblack")
        if wb and wb.Brightness > 0 then
            wb.Brightness = 0
            wb.Contrast = 0
            wb.Saturation = 0
            wb.TintColor = Color3.fromRGB(255, 255, 255)
        end
    end
end)
table.insert(Connections, visualWatchdogConn)

-- Anti-ScreenShake (0.2s interval)
local lastShakeThrottle = 0
local antiShakeConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    if not State.AntiScreenShake then return end
    local now = tick()
    if now - lastShakeThrottle < 0.2 then return end
    lastShakeThrottle = now

    local char = LocalPlayer.Character
    if char then
        local s1 = char:FindFirstChild("ScreenShaking")
        if s1 then pcall(function() s1:Destroy() end) end
        local s2 = char:FindFirstChild("BigShaking")
        if s2 then pcall(function() s2:Destroy() end) end
    end
end)
table.insert(Connections, antiShakeConn)

-- Anti-Invisibility Watchdog (0.4s interval - eliminates 1600+ FindFirstChild calls/sec)
local lastInvisThrottle = 0
local antiInvisConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    if not State.AntiInvis then return end
    local now = tick()
    if now - lastInvisThrottle < 0.4 then return end
    lastInvisThrottle = now

    local live = Workspace:FindFirstChild("Live")
    if live then
        local myChar = LocalPlayer.Character
        for _, model in ipairs(live:GetChildren()) do
            if model:IsA("Model") and model ~= myChar then
                local torso = model:FindFirstChild("Torso")
                if torso and torso.Transparency > 0.5 then
                    torso.Transparency = 0.3
                end
                local head = model:FindFirstChild("Head")
                if head and head.Transparency > 0.5 then
                    head.Transparency = 0.3
                end
                local tm = torso and torso:FindFirstChild("TeamMarker")
                if tm and not tm.Enabled then
                    tm.Enabled = true
                end
            end
        end
    end
end)
table.insert(Connections, antiInvisConn)

-- Infinite Jump (jump custom du jeu : JumpPower=0 donc ChangeState est ignore.
-- On applique une impulsion verticale + un vrai tap Espace pour le pipeline jeu)
local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and not getgenv().ABA_Unloaded then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 52, v.Z)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.delay(0.05, function()
                    pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
                end)
            end)
        end
    end
end)
table.insert(Connections, infJumpConn)

-- Anti-Respawn Freeze Watchdog (0.5s interval)
local lastRespawnThrottle = 0
local respawnWatchdogConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local now = tick()
    if now - lastRespawnThrottle < 0.5 then return end
    lastRespawnThrottle = now

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local respawnGui = pg and pg:FindFirstChild("Respawning")
    if respawnGui and respawnGui.Enabled then
        local secLabel = respawnGui:FindFirstChild("SecondsLeft")
        if secLabel and (secLabel.Text == "0" or secLabel.Text == "0.0") then
            local char = LocalPlayer.Character
            if char and not char:FindFirstChild("Loaded") then
                local loadedFolder = Instance.new("Folder")
                loadedFolder.Name = "Loaded"
                loadedFolder.Parent = char
            end

            task.delay(1.5, function()
                local pg2 = LocalPlayer:FindFirstChild("PlayerGui")
                local stuckGui = pg2 and pg2:FindFirstChild("Respawning")
                if stuckGui and stuckGui.Enabled then
                    local stuckChar = LocalPlayer.Character
                    if stuckChar then
                        local action = stuckChar:FindFirstChild("Action")
                        if action then pcall(function() action:Destroy() end) end
                        local hum = stuckChar:FindFirstChild("Humanoid")
                        if hum then
                            Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                            Workspace.CurrentCamera.CameraSubject = hum
                        end
                    end
                    local hud = pg2:FindFirstChild("HUD")
                    if hud then
                        if hud:FindFirstChild("Timer") then hud.Timer.Visible = true end
                        if hud:FindFirstChild("Health") then hud.Health.Visible = true end
                        if hud:FindFirstChild("Ultimate") then hud.Ultimate.Visible = true end
                    end
                    pcall(function() stuckGui.Enabled = false end)
                    pcall(function() stuckGui:Destroy() end)
                end
            end)
        end
    end
end)
table.insert(Connections, respawnWatchdogConn)

-- Status & Mechanics Bypasses Watchdog (0.3s interval)
local lastStatusThrottle = 0
local statusBypassConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local now = tick()
    if now - lastStatusThrottle < 0.3 then return end
    lastStatusThrottle = now

    local char = LocalPlayer.Character
    if not char then return end

    -- 1. NoJumpPenalty
    if State.NoJumpPenalty then
        if not char:FindFirstChild("NoJumpPenalty") then
            local f = Instance.new("Folder")
            f.Name = "NoJumpPenalty"
            f.Parent = char
        end
    else
        local njp = char:FindFirstChild("NoJumpPenalty")
        if njp then pcall(function() njp:Destroy() end) end
    end

    -- 2. DodgeOkay
    if State.DodgeWhileSlowed then
        if not char:FindFirstChild("DodgeOkay") then
            local f = Instance.new("Folder")
            f.Name = "DodgeOkay"
            f.Parent = char
        end
    else
        local dok = char:FindFirstChild("DodgeOkay")
        if dok then pcall(function() dok:Destroy() end) end
    end

    -- 3. Anti-Confuse
    if State.AntiConfuse then
        local conf = char:FindFirstChild("Confuse")
        if conf then
            pcall(function() conf:Destroy() end)
        end
    end
end)
table.insert(Connections, statusBypassConn)

-- Auto-Tech / Air Recovery (Recovers from knockdown / downslam instantly on first valid frame)
local lastTechTime = 0
local autoTechConn = RunService.Heartbeat:Connect(function()
    if not State.AutoTech or getgenv().ABA_Unloaded then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local now = tick()
    if (now - lastTechTime > 0.8) and not char:FindFirstChild("Action") then
        local state = hum:GetState()
        if (state == Enum.HumanoidStateType.Freefall and hrp.AssemblyLinearVelocity.Y < -35) or state == Enum.HumanoidStateType.Ragdoll then
            lastTechTime = now
            task.spawn(function()
                task.wait(math.random(15, 35) / 1000)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.04)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)
table.insert(Connections, autoTechConn)

-- =========================================================================
--  ANTI-BAN AUDIT ENGINE (STAFF DETECTOR & QTE SOLVERS)
-- =========================================================================

local STAFF_GROUP_ID = 3735330
local function CheckStaffPlayer(plr)
    if plr == LocalPlayer then return end
    local s, rank = pcall(function() return plr:GetRankInGroup(STAFF_GROUP_ID) end)
    if s and rank and rank >= 2 then
        local msg = string.format("Staff detected: %s (Rank %d) in Group %d!", plr.Name, rank, STAFF_GROUP_ID)
        warn("[NW Hub Anti-Ban] " .. msg)
        Vesper:Notify({ Title = "STAFF DETECTED", Content = msg, Type = "error" })

        if State.StaffAction == "Notify & Hop" then
            local char = LocalPlayer.Character
            if State.AntiCombatTagHop and char and char:FindFirstChild("CombatTag") then
                Vesper:Notify({ Title = "Combat Tagged", Content = "Waiting for combat tag to clear before hopping...", Type = "warning" })
                repeat task.wait(0.5) until not char:FindFirstChild("CombatTag") or getgenv().ABA_Unloaded
            end
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        elseif State.StaffAction == "Instant Disconnect" then
            -- FIX BUG: game:Shutdown() n'existe que côté serveur, sur client ça throw "Shutdown can only be called on server"
            -- Remplacé par Kick local (même effet anti-ban, sans erreur console)
            pcall(function() LocalPlayer:Kick("[NW Hub Anti-Ban] Staff detected - disconnected for safety") end)
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(CheckStaffPlayer, p)
end

local staffJoinConn = Players.PlayerAdded:Connect(function(plr)
    if State.StaffDetector and not getgenv().ABA_Unloaded then
        task.spawn(CheckStaffPlayer, plr)
    end
end)
table.insert(Connections, staffJoinConn)

-- =========================================================================
--  HUMANIZED ANTI-BAN QTE SOLVER (NANAMI 7:3, BLACK FLASH, KOKUSHIBO)
-- =========================================================================

local function SendViewportCenterClick(btn)
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local cx, cy = vp.X / 2, vp.Y / 2
    VirtualInputManager:SendMouseButtonEvent(cx, cy, btn or 0, true, game, 0)
    task.wait(0.035 + (math.random(8, 18) / 1000))
    VirtualInputManager:SendMouseButtonEvent(cx, cy, btn or 0, false, game, 0)
end

-- 1. Kokushibo QTE Auto-Solve (Dual-Layer: RemoteFunction Hook + Authentic Virtual Right-Click)
local kokuConn = LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if not State.AutoQTE or getgenv().ABA_Unloaded then return end
    if child.Name == "FrenchKokushibo" then
        task.spawn(function()
            Vesper:Notify({ Title = "Kokushibo QTE", Content = "Auto-Solving Blood Demon Art QTE...", Type = "info" })
            task.wait(0.1)
            SendViewportCenterClick(1)
            task.wait(0.3)
            SendViewportCenterClick(1)
        end)
    end
end)
table.insert(Connections, kokuConn)

-- 2. Nanami 7:3 Ratio Perfect Hit / Black Flash Auto-Timing
-- ABA .RunOnceLocal line 373: NanamiCheck cutter starts at 0.005, sweetspot is math.abs(0.7 - cutter) < 0.02 (0.680 to 0.720)
-- When cutter hits 0.70, u44 is true and clicking triggers u45 = true (Ratio / Black Flash critical hit!)
local lastNanamiSolve = 0
local lastNanamiCheck = 0
local nanamiHeartbeatConn = RunService.Heartbeat:Connect(function()
    if not State.AutoQTE or getgenv().ABA_Unloaded then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end

    -- Fast attribute check
    local charName = myChar:GetAttribute("SpawnChar") or myChar:GetAttribute("LastLoadedChar")
    if charName ~= "Nanami" then return end

    local now = tick()
    if now - lastNanamiCheck < (State.EcoMode and 0.1 or 0.05) then return end
    lastNanamiCheck = now

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local gui = (pg and pg:FindFirstChild("NanamiCutGUI")) or myChar:FindFirstChild("NanamiCutGUI")

    if gui and gui.Parent then
        local mainBar = gui:FindFirstChild("MainBar")
        local cutter = mainBar and mainBar:FindFirstChild("Cutter")
        if cutter then
            local x = cutter.Position.X.Scale
            local now = tick()
            -- Fire within the exact ratio sweetspot (0.690 - 0.708)
            if x >= 0.690 and x <= 0.708 and (now - lastNanamiSolve > 0.4) then
                lastNanamiSolve = now
                SendViewportCenterClick(0)
                Vesper:Notify({ Title = "Nanami Ratio", Content = "7:3 Critical Ratio Click Sent!", Type = "success" })
            end
        end
    end
end)
table.insert(Connections, nanamiHeartbeatConn)

-- 3. Universal Black Flash Auto-Timing (Calibrated for Todo, Yuji, Gojo, Sukuna)
-- ABA .RunOnceLocal Line 467: BlackFlashCheck zooms FOV to 6 over v53 (approx 0.42s-0.48s).
-- Sweetspot u55 only activates AFTER wait(v53). Clicking early (<0.40s) permanently disqualifies the player!
-- UNIFIED: un seul clic par QTE (debounce partagé entre FOV / Yuji / hook Remote) + délai réglable.
-- Le timing part du DÉBUT DU ZOOM, pas du début du move.
local lastBFClick = 0

-- Clic immédiat (fenêtre déjà ouverte) : micro-jitter humain seulement, JAMAIS de délai fixe.
-- Les délais fixes sont faux dès que le windup (v53) change selon le move.
-- Debounce long (3s) : les watchers sont un fallback, ils ne doivent jamais doubler le hook.
local function FireBFClickNow()
    local now = tick()
    if now - lastBFClick < 3.0 then return false end
    lastBFClick = now
    task.spawn(function()
        -- Clamp anti-config périmée : une sauvegarde avec l'ancien défaut 0.48 raterait la fenêtre
        local extra = math.clamp(tonumber(State.BlackFlashDelay) or 0.03, 0, 0.3)
        task.wait(extra + (math.random(5, 20) / 1000))
        if getgenv().ABA_Unloaded then return end
        SendViewportCenterClick(0)
        Vesper:Notify({ Title = "Anti-Ban QTE", Content = "Black Flash Landed!", Type = "success" })
    end)
    return true
end

-- Watcher FOV v2 : le jeu restaure le FOV (6 -> 70) exactement à l'ouverture de la
-- fenêtre (u55=true) : on clique dès que le FOV remonte. Aucun timing deviné.
-- GATE : seulement pour les persos Black Flash (Vegeta & co zoom la camera aussi
-- sur leurs cinématiques -> faux positifs sinon).
local BF_CHARACTERS = { "yuji", "itadori", "todo", "gojo", "satoru", "sukuna", "nanami", "mahito", "yuta", "hakari" }
local function IsBlackFlashChar()
    if State.QTEGate == false then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local name = tostring(char:GetAttribute("SpawnChar") or char:GetAttribute("LastLoadedChar") or ""):lower()
    for _, k in ipairs(BF_CHARACTERS) do
        if name:find(k, 1, true) then return true end
    end
    return false
end

local bfZoomSeen = false
local bfZoomSince = 0
local bfFrameTick = 0
local bfConn = RunService.RenderStepped:Connect(function()
    if not State.AutoQTE or not IsBlackFlashChar() or getgenv().ABA_Unloaded then bfZoomSeen = false; return end
    local nowBf = tick()
    if nowBf - bfFrameTick < 0.01 then return end
    bfFrameTick = nowBf
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local fov = cam.FieldOfView
    if fov <= 12 then
        if not bfZoomSeen then bfZoomSeen = true; bfZoomSince = tick() end
    elseif bfZoomSeen then
        if fov > 20 then
            bfZoomSeen = false
            FireBFClickNow()
        elseif tick() - bfZoomSince > 4 then
            bfZoomSeen = false -- zoom anormal, reset sans cliquer à l'aveugle
        end
    end
end)
table.insert(Connections, bfConn)

-- 3b. Sukuna Awakened Move 1 (Shrine Grab / Cleave) Guaranteed Auto Black Flash
-- Precise animation timing: Sukuna's grab anim (rbxassetid://18352161100) runs at 1.4x speed.
-- Keyframe KF2.2999 occurs at 2.2999s / 1.4 = exactly 1.64s into the grab.
-- Clicking M1 at exactly 1.64s triggers HasBlackFlashed and executes the critical Black Flash slam!
local lastSukunaBF = 0

local function TriggerSukunaBlackFlashImpact()
    local now = tick()
    if now - lastSukunaBF < 2.0 then return end
    lastSukunaBF = now
    task.spawn(function()
        -- Exact impact frame delay calibrated for 1.4x animation speed
        task.wait(1.64)
        SendViewportCenterClick(0)
        task.wait(0.04)
        SendViewportCenterClick(0)
        Vesper:Notify({ Title = "Sukuna Awaken", Content = "Move 1 Black Flash Landed!", Type = "success" })
    end)
end

-- Hook 1: Animation Tracker on Humanoid (instantaneous detection of grab track 18352161100)
local function HookSukunaHumanoid(hum)
    if not hum then return end
    -- Un seul perso hooke a la fois : deconnecte les hooks du perso precedent
    -- (sinon les closures epinglent les vieux models = fuite memoire lente).
    local prevSuk = getgenv().__NW_SUKCONNS
    if type(prevSuk) == "table" then
        for _, c in ipairs(prevSuk) do pcall(function() c:Disconnect() end) end
    end
    local mySukConns = {}
    getgenv().__NW_SUKCONNS = mySukConns
    local animConn = hum.AnimationPlayed:Connect(function(track)
        if not State.AutoQTE or not IsBlackFlashChar() or getgenv().ABA_Unloaded then return end
        local animId = track.Animation and track.Animation.AnimationId or ""
        if string.find(animId, "18352161100") then
            TriggerSukunaBlackFlashImpact()
        end
    end)
    table.insert(mySukConns, animConn)
    table.insert(Connections, animConn)
end

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    HookSukunaHumanoid(LocalPlayer.Character.Humanoid)
end

local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum then HookSukunaHumanoid(hum) end
end)
table.insert(Connections, charAddedConn)

-- Hook 2: Fallback Watchdog on GrabBrick (triggers if animation listener drops or lags)
local sukunaGrabConn = RunService.Heartbeat:Connect(function()
    if not State.AutoQTE or not IsBlackFlashChar() or getgenv().ABA_Unloaded then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end

    local isAwakened = myChar:FindFirstChild("State2") or myChar:FindFirstChild("SUPERAWAKENWHENEVER")
    if not isAwakened then return end

    local gb = myChar:FindFirstChild("GrabBrick")
    if gb and not gb:GetAttribute("BFHooked") then
        gb:SetAttribute("BFHooked", true)
        TriggerSukunaBlackFlashImpact()
    end
end)
table.insert(Connections, sukunaGrabConn)

-- 4. Yuji Itadori Divergent Blow (Move 1) & Black Flash Auto-Solve Watchdog
-- L'attribut UsingDivergentBlow est posé au DÉBUT du move : aucun clic à délai fixe
-- (partait avant la fin de l'anim). On attend zoom puis restauration (= fenêtre ouverte).
local lastYujiBF = 0
local yujiWatchdogConn = RunService.Heartbeat:Connect(function()
    if not State.AutoQTE or not IsBlackFlashChar() or getgenv().ABA_Unloaded then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end

    local isUsingDivergent = myChar:GetAttribute("UsingDivergentBlow")
    -- Le jeu stocke parfois la string "false" (truthy en Lua) : on ne garde que le vrai true
    local now = tick()
    if (isUsingDivergent == true or isUsingDivergent == "true") and (now - lastYujiBF > 1.5) then
        lastYujiBF = now
        task.spawn(function()
            local t0 = tick()
            local sawZoom = false
            while tick() - t0 < 4 do
                if getgenv().ABA_Unloaded then return end
                local c = Workspace.CurrentCamera
                if c then
                    if c.FieldOfView <= 12 then sawZoom = true
                    elseif sawZoom and c.FieldOfView > 20 then break end
                end
                task.wait(0.03)
            end
            if sawZoom then FireBFClickNow() end
        end)
    end
end)
table.insert(Connections, yujiWatchdogConn)

-- 5. GUARANTEED DIRECT QTE SOLVER HOOKS (Black Flash, Kokushibo, Nanami, Sight Immunity)
-- NOTE: In Roblox, RemoteFunction.OnClientInvoke is write-only. Attempting to read it throws a runtime error!
-- We set clean, independent handlers with pcall per remote so nothing ever crashes.

local rep = game:GetService("ReplicatedStorage")

-- 1. Universal Black Flash Direct Return & Impact Simulation (Todo, Yuji, Gojo, Sukuna)
pcall(function()
    local bfCheck = rep:FindFirstChild("BlackFlashCheck")
    if bfCheck and bfCheck:IsA("RemoteFunction") then
        bfCheck.OnClientInvoke = function(p51, p52)
            -- Émulation EXACTE du handler jeu (.RunOnceLocal L467) : on écoute les VRAIS inputs
            -- et u56=true seulement si le clic tombe dans [windup, windup+sweetspot].
            -- L'ancien override répondait true,true à l'aveugle sans écouteur : le serveur ne validait pas.
            if State.AutoQTE and IsBlackFlashChar() and not getgenv().ABA_Unloaded then
                local totalTime = tonumber(p51) or 0.6
                local sweetspot = tonumber(p52) or 0.15
                local windup = math.max(0, totalTime - sweetspot)
                local u54, u55, u56 = false, false, false
                local conn
                conn = game:GetService("UserInputService").InputBegan:Connect(function(p57)
                    if u54 then return end
                    if p57.UserInputType == Enum.UserInputType.MouseButton1
                        or p57.UserInputType == Enum.UserInputType.Touch
                        or p57.KeyCode == Enum.KeyCode.ButtonB then
                        if u55 then u56 = true else u54 = true end
                    end
                end)
                task.spawn(function()
                    pcall(function()
                        game:GetService("TweenService"):Create(workspace.CurrentCamera, TweenInfo.new(windup, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                            FieldOfView = 6
                        }):Play()
                    end)
                end)
                task.wait(windup)
                u55 = true
                if sweetspot <= 0 then
                    pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)
                    pcall(function() conn:Disconnect() end)
                    return false, true
                end
                lastBFClick = tick()
                SendViewportCenterClick(0)
                task.spawn(function()
                    pcall(function()
                        game:GetService("TweenService"):Create(workspace.CurrentCamera, TweenInfo.new(sweetspot), {
                            FieldOfView = 70
                        }):Play()
                    end)
                end)
                task.wait(sweetspot)
                pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)
                u55 = false
                pcall(function() conn:Disconnect() end)
                Vesper:Notify({ Title = "Black Flash", Content = "Strike Connected & Auto Black Flash Landed!", Type = "success" })
                return u56, true
            end
            return true, true
        end
    end
end)

-- 2. Kokushibo QTE (Blood Demon Art / FrenchKokushibo)
pcall(function()
    local kokuCheck = rep:FindFirstChild("KokushiboCheck")
    if kokuCheck and kokuCheck:IsA("RemoteFunction") then
        kokuCheck.OnClientInvoke = function(p65, p66)
            if State.AutoQTE and not getgenv().ABA_Unloaded then
                local v67 = (tonumber(p66) or 0.2) * 2
                local v68 = math.max(0, (tonumber(p65) or 0.8) * 2 - v67)

                -- Clone FrenchKokushibo GUI if available so player sees visual cues
                local fk = rep:FindFirstChild("FrenchKokushibo")
                local fkClone = nil
                if fk then
                    pcall(function()
                        fkClone = fk:Clone()
                        fkClone.Parent = LocalPlayer:FindFirstChild("PlayerGui")
                    end)
                end

                -- Wait for sword windup animation
                task.wait(v68)

                -- Sweetspot reaction delay
                local humanReaction = math.clamp(v67 * 0.25 + (math.random(10, 25) / 1000), 0.02, math.max(0.03, v67 * 0.7))
                task.wait(humanReaction)

                -- Send authentic Right Click
                SendViewportCenterClick(1)

                task.wait(math.max(0, v67 - humanReaction))

                if fkClone then
                    pcall(function() fkClone:Destroy() end)
                end

                task.spawn(function()
                    Vesper:Notify({ Title = "Kokushibo QTE", Content = "Blood Demon Art Counter Landed!", Type = "success" })
                end)

                return true
            end
            return true
        end
    end
end)

-- 3. Nanami 7:3 Ratio Technique (Full Visual GUI Display + Guaranteed Auto-Ratio)
pcall(function()
    local nanamiCheck = rep:FindFirstChild("NanamiCheck")
    if nanamiCheck and nanamiCheck:IsA("RemoteFunction") then
        nanamiCheck.OnClientInvoke = function(p39, p40, p41)
            if not p39 or not p39:FindFirstChild("HumanoidRootPart") then
                return false, nil, true
            end

            local HumanoidRootPart = p39.HumanoidRootPart
            local v42 = rep:FindFirstChild("NanamiCutGUI")
            if v42 then
                v42 = v42:Clone()
                v42.MainBar.Rotation = -80
                v42.Parent = HumanoidRootPart
                v42.Adornee = HumanoidRootPart
            end

            local UserInputService2 = game:GetService("UserInputService")
            local u43 = false
            local u44 = false
            local u45 = false

            local v47 = UserInputService2.InputBegan:Connect(function(p46)
                if u43 then return end
                if p46.UserInputType == Enum.UserInputType.MouseButton1 or p46.UserInputType == Enum.UserInputType.Touch or p46.KeyCode == Enum.KeyCode.ButtonB then
                    if u44 then
                        u45 = true
                        return
                    end
                    u43 = true
                end
            end)

            local v48 = 0.005
            local v49 = 0
            local autoClicked = false

            while v48 < 1 and (p41 and p41:GetAttribute("NANAMIAIM") and not (u43 or u45)) do
                local task_wait_ret = task.wait()
                local v50 = task_wait_ret / (p40 or 0.8)
                local math_abs_ret = math.abs(0.7 - v48)

                if v42 and v42:FindFirstChild("MainBar") then
                    if v48 < 0.7 then
                        v42.MainBar.Rotation = v48 / 0.7 * 80 + -80
                    else
                        v42.MainBar.Rotation = 0
                    end
                end

                if math_abs_ret < 0.025 then
                    v50 = v50 / 8
                elseif math_abs_ret < 0.05 then
                    v50 = v50 / 4
                end

                v48 = v48 + v50
                if v42 and v42:FindFirstChild("MainBar") and v42.MainBar:FindFirstChild("Cutter") then
                    v42.MainBar.Cutter.Position = UDim2.new(v48, 0, 0.5, 0)
                end

                if math_abs_ret < 0.02 then
                    u44 = true
                    -- Auto-solve: if AutoQTE is active, automatically trigger ratio hit
                    if State.AutoQTE and not autoClicked then
                        autoClicked = true
                        u45 = true
                        SendViewportCenterClick(0)
                        task.spawn(function()
                            Vesper:Notify({ Title = "Nanami 7:3", Content = "Critical Ratio Black Flash Landed!", Type = "success" })
                        end)
                        break
                    end
                else
                    u44 = false
                end

                if u44 then
                    v49 = v49 + task_wait_ret
                end
            end

            v47:Disconnect()

            if v42 then
                if u45 and (p41 and p41:GetAttribute("NANAMIAIM")) then
                    if v42:FindFirstChild("MainBar") and v42.MainBar:FindFirstChild("Cutter") then
                        v42.MainBar.Cutter.Position = UDim2.new(0.7, 0, 0.5, 0)
                        game:GetService("TweenService"):Create(v42, TweenInfo.new(0.25), {
                            Size = UDim2.new(10, 200, 10, 200)
                        }):Play()
                        v42.MainBar.Cutter.Size = UDim2.new(0.016, 0, 12, 0)
                        game:GetService("TweenService"):Create(v42.MainBar.Cutter, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 0, 24, 0),
                            BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        }):Play()
                    end
                    local ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
                    ColorCorrectionEffect.Parent = game.Lighting
                    ColorCorrectionEffect.TintColor = Color3.fromRGB()
                    game.Debris:AddItem(ColorCorrectionEffect, 0.15)
                    game.Debris:AddItem(v42, 0.5)
                else
                    game.Debris:AddItem(v42, 0.5)
                end
            end

            return u45, nil, true
        end
    end
end)

-- 4. Sight Immunity / Anti-Genjutsu (Itachi, Aizen, Medusa)
pcall(function()
    local isLooking = rep:FindFirstChild("IsLookingAt")
    if isLooking and isLooking:IsA("RemoteFunction") then
        isLooking.OnClientInvoke = function(...)
            if State.AntiGenjutsu and not getgenv().ABA_Unloaded then
                return false -- Always evasive, never caught by sight attacks
            end
            return false
        end
    end
end)

-- 5. Additional QTE checks: OsuCheck & ChrolloCheck
pcall(function()
    local osu = rep:FindFirstChild("OsuCheck")
    if osu and osu:IsA("RemoteFunction") then
        osu.OnClientInvoke = function(...)
            if State.AutoQTE and not getgenv().ABA_Unloaded then
                return true
            end
            return true
        end
    end
    local chrollo = rep:FindFirstChild("ChrolloCheck")
    if chrollo and chrollo:IsA("RemoteFunction") then
        chrollo.OnClientInvoke = function(...)
            if State.AutoQTE and not getgenv().ABA_Unloaded then
                return true
            end
            return true
        end
    end
    local chrollo2 = rep:FindFirstChild("ChrolloCheck2")
    if chrollo2 and chrollo2:IsA("RemoteFunction") then
        chrollo2.OnClientInvoke = function(...)
            if State.AutoQTE and not getgenv().ABA_Unloaded then
                return true
            end
            return true
        end
    end
end)

-- =========================================================================
--  CORE COMBAT & ENGINE LOGIC
-- =========================================================================

-- Helper: High-Performance Throttled Enemy Cache (Fixes 2 FPS lag from 36+ dummies)
local CachedEnemies = {}
local lastEnemyCacheTick = 0

local function GetLiveEnemies()
    local now = tick()
    if now - lastEnemyCacheTick < (State.EcoMode and 0.2 or 0.1) then
        return CachedEnemies
    end
    lastEnemyCacheTick = now

    local enemies = {}
    local live = Workspace:FindFirstChild("Live")
    if not live then
        CachedEnemies = enemies
        return enemies
    end

    local myChar = LocalPlayer.Character
    local myTeam = LocalPlayer.Team
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position

    for _, model in ipairs(live:GetChildren()) do
        if model:IsA("Model") and model ~= myChar then
            local hum = model:FindFirstChild("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local plr = Players:GetPlayerFromCharacter(model)
                local isTeammate = false
                if plr and State.IgnoreTeammates and myTeam and plr.Team and plr.Team == myTeam and plr.Team.Name ~= "FFA" and plr.Team.Name ~= ".AFK" then
                    isTeammate = true
                end

                if not isTeammate then
                    local dist = myPos and (hrp.Position - myPos).Magnitude or 999
                    table.insert(enemies, {
                        Model = model,
                        Humanoid = hum,
                        RootPart = hrp,
                        Player = plr,
                        Distance = dist
                    })
                end
            end
        end
    end

    -- Sort closest first
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    CachedEnemies = enemies
    return enemies
end

-- Authentic Directional Dodge (Q + A/D/S)
local lastDodgeTick = 0
local dodgeSideToggle = false

local function PerformDirectionalDodge(dirKey)
    local now = tick()
    if now - lastDodgeTick < State.DodgeCooldown then return end
    lastDodgeTick = now

    dirKey = dirKey or (dodgeSideToggle and Enum.KeyCode.D or Enum.KeyCode.A)

    -- Authentic directional dodge: hold direction key, tap Q, release direction key
    VirtualInputManager:SendKeyEvent(true, dirKey, false, game)
    task.wait(0.015)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.04)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.02)
    VirtualInputManager:SendKeyEvent(false, dirKey, false, game)
end

-- 1. STEALTH AUTO-PARRY / AUTO-BLOCK (Virtual Input + Remote Hybrid)
local lastBlockTick = 0
local isCurrentlyBlocking = false
local blockReleaseTick = 0

local lastBlockPressTick = 0
local lastBlockReleaseTick = 0

local function PerformBlockPress()
    if isCurrentlyBlocking then return end
    isCurrentlyBlocking = true
    lastBlockPressTick = tick()

    if State.BlockMode == "Authentic Key (UD)" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    else
        local inputRemote = LocalPlayer.Backpack:FindFirstChild("Input")
        if inputRemote then
            pcall(function() inputRemote:FireServer("BlockOn") end)
        end
    end
end

local function PerformBlockRelease()
    if not isCurrentlyBlocking then return end
    isCurrentlyBlocking = false
    lastBlockReleaseTick = tick()

    if State.BlockMode == "Authentic Key (UD)" then
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    else
        local inputRemote = LocalPlayer.Backpack:FindFirstChild("Input")
        if inputRemote then
            pcall(function() inputRemote:FireServer("BlockOff") end)
        end
    end
end




-- ====================================================================
-- ====================================================================
-- M1 TRADE / GUARD COUNTER ENGINE (Instant Block Punish & Combo Starter)
-- ====================================================================

-- Forward declarations : le moteur Auto Counter est défini plus bas mais appelé
-- depuis PerformM1Trade (déclenchement sur impact bloqué). Sans ça : nil call.
local FindCounterSlot, PerformAutoCounter, TrackAndFireCounter, IsHelplessEnemy
local lastCounterTick, lastOwnAttackTick

-- Vérifie si l'attaquant effectue un M1 ou un Skill
local function IsAttackerDoingM1(enemyModel)
    if not enemyModel or not enemyModel:IsA("Model") then return false end

    -- 1. S'il a un marqueur de Skill actif (Action / UsingSkill), ce n'est PAS un M1 !
    local act = enemyModel:FindFirstChild("Action") or enemyModel:FindFirstChild("UsingSkill")
    if act then
        local actVal = (act:IsA("StringValue") and act.Value:lower()) or act.Name:lower()
        if actVal ~= "" and actVal ~= "none" and actVal ~= "m1" and actVal ~= "light" then
            return false
        end
    end

    -- 2. Vérifie les animations en cours de l'ennemi
    local hum = enemyModel:FindFirstChildOfClass("Humanoid")
    if hum then
        local tracks = hum:GetPlayingAnimationTracks()
        for _, track in ipairs(tracks) do
            local animName = track.Name:lower()
            -- Si c'est un skill nommé, exclure immédiatement
            if animName:find("gatling") or animName:find("ora") or animName:find("muda") or animName:find("barrage")
               or animName:find("kamehameha") or animName:find("rasen") or animName:find("cero") or animName:find("getsuga")
               or animName:find("smash") or animName:find("beam") or animName:find("blast") or animName:find("projectile")
               or animName:find("rush") or animName:find("flurry") or animName:find("volley") or animName:find("rapid")
               or animName:find("assault") or animName:find("beatdown") or animName:find("multi") or animName:find("fist") then
                return false
            end

            -- Si c'est une animation M1 officielle ABA
            local animId = (track.Animation and track.Animation.AnimationId) or ""
            local idNum = animId:match("%d+")
            if idNum and BasicM1AnimIds and BasicM1AnimIds[idNum] then
                return true
            end
            if animName:sub(1, 5) == "light" or animName == "m1" or animName == "m1swing" or animName:find("punch") or animName:find("slash") then
                return true
            end
        end
    end

    -- Fallback mêlée (comportement d'origine restauré) : si aucun skill détecté ci-dessus
    -- et l'attaquant est au corps-à-corps, c'est un M1. Les anims M1 ABA sont courtes
    -- et souvent déjà terminées à l'impact du bloc, donc exiger une anim prouvée casse le trade.
    -- À distance (>12 studs, ex: beam bloqué), on ne trade pas pour éviter un M1 dans le vide.
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local attHRP = enemyModel:FindFirstChild("HumanoidRootPart")
    if myHRP and attHRP then
        local dist = (attHRP.Position - myHRP.Position).Magnitude
        if dist <= 12 then
            return true
        end
    end
    return false
end

local lastM1TradeTick = 0
-- Anti-barrage : si la garde prend 3+ impacts en <0.7s (fists/beam barrage),
-- on ne trade PAS (sinon on lache la garde et on mange le combo entier).
local barrageUntil = 0
-- Verrou post-trade : pendant un combo reussi, on ignore l'input block du joueur
local tradeLockUntil = 0

local function PerformM1Trade(attacker, triggerReason)
    if not State.M1Trade or getgenv().ABA_Unloaded then return end
    if tick() < barrageUntil then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChild("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end

    -- Vérifie si le joueur est en train de bloquer
    local isGuarding = isCurrentlyBlocking
        or (myChar:FindFirstChild("Blocking") and myChar.Blocking.Value == true)
        or (myChar:FindFirstChild("FHeld") and myChar.FHeld.Value == true)
        or UserInputService:IsKeyDown(Enum.KeyCode.F)
        or (tick() - lastBlockPressTick < 0.5)

    if not isGuarding then return end

    -- Résolution de l'attaquant
    if not (attacker and attacker:IsA("Model") and attacker:FindFirstChild("HumanoidRootPart")) then
        local lh = myChar:FindFirstChild("LastHit")
        if lh and lh.Value and lh.Value:IsA("Model") and lh.Value ~= myChar and lh.Value:FindFirstChild("HumanoidRootPart") then
            attacker = lh.Value
        else
            local closestDist = 12
            for _, enemy in ipairs(GetLiveEnemies()) do
                if enemy.Distance <= closestDist then
                    attacker = enemy.Model
                    closestDist = enemy.Distance
                end
            end
        end
    end

    local attHRP = attacker and attacker:FindFirstChild("HumanoidRootPart")

    -- ⚠️ RÈGLE STRICTE 1 : EXCLURE LES SPELLS / SKILLS !
    -- M1 Trade ne s'active QUE si l'ennemi clique / M1 (pas sur un spell bloqué)
    if attacker and not IsAttackerDoingM1(attacker) then
        return
    end

    -- AUTO COUNTER PRIORITAIRE : impact réellement bloqué + counter prêt = on joue le
    -- counter (attrape la suite du M1/skill) au lieu du trade M1. Signal 100% fiable,
    -- même contre des M1 aux anims génériques indétectables.
    do
        local tNow = os.clock()
        -- Pas de gate "ma propre attaque" : un impact SUR MA GARDE prouve l'attaque adverse.
        -- (Uptilt dans le vide ne touche jamais ma garde -> jamais de counter fantôme.)
        if State.AutoCounter and attacker and attHRP
            and (tNow - lastCounterTick >= (State.CounterCooldown or 2.5)) then
            local eHum = attacker:FindFirstChildOfClass("Humanoid")
            local dist = (attHRP.Position - myHRP.Position).Magnitude
            if eHum and dist <= (State.CounterRange or 16)
                and not IsHelplessEnemy(myHRP, { Model = attacker, RootPart = attHRP, Humanoid = eHum }) then
                local slot = FindCounterSlot()
                if slot and not (attacker.Name:lower():find("dummy")) then
                    lastCounterTick = tNow
                    -- L'attaquant est déjà sur nous (impact) : tir direct, pas de suivi
                    task.spawn(PerformAutoCounter, slot, { Model = attacker, RootPart = attHRP, Humanoid = eHum, Distance = dist })
                    return
                end
            end
        end
    end

    -- Internal debounce
    local now = os.clock()
    if now - lastM1TradeTick < 0.18 then return end
    lastM1TradeTick = now

    -- 1. UNBLOCK : Lâche la garde immédiatement pour riposter
    local bc = LocalPlayer.PlayerScripts:FindFirstChild("BaseContext")
    if bc and bc:FindFirstChild("Block") then
        pcall(function() bc.Block:Fire(false) end)
    end
    local inputRemote = game:GetService("StarterPack"):FindFirstChild("Input") or LocalPlayer.Backpack:FindFirstChild("Input")
    if inputRemote then
        pcall(function() inputRemote:FireServer("BlockOff") end)
    end
    pcall(function()
        if myChar:FindFirstChild("Blocking") then myChar.Blocking.Value = false end
        if myChar:FindFirstChild("FHeld") then myChar.FHeld.Value = false end
    end)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    isCurrentlyBlocking = false
    lastBlockReleaseTick = tick()
    blockReleaseTick = 0

    -- 2. AUTO-FACE : Oriente instantanément le personnage vers l'attaquant
    if State.M1TradeAutoFace and attHRP then
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(attHRP.Position.X, myHRP.Position.Y, attHRP.Position.Z))
    end

    -- 3. FRAME ADVANTAGE TIMING : absorption ultra-courte pour punir dès le 1er M1
    local delayTime = math.max(0.01, (State.M1TradeReaction or 0.02))
    task.wait(delayTime)

    -- 4. COUNTER M1 : Clic immédiat pour initier le combo
    if bc and bc:FindFirstChild("MouseClick") then
        pcall(function() bc.MouseClick:Fire(true) end)
        task.delay(0.05, function()
            pcall(function() bc.MouseClick:Fire(false) end)
        end)
    end
    SendViewportCenterClick(0)

    if inputRemote then
        local aimCF = attHRP and attHRP.CFrame or (myHRP and myHRP.CFrame * CFrame.new(0, 0, -3)) or CFrame.new()
        pcall(function()
            inputRemote:FireServer("M1", {
                air = false,
                mousehit = aimCF,
                md = Vector3.zero,
                dodgevelo = false,
                skeydown = false,
                skeyreal = false
            })
        end)
    end

    -- SUIVI DU TRADE (garde persistante) :
    --  - M1 reussi (le combo monte) -> on verrouille le block du joueur ~1.2s
    --    pour que son F tenu ne casse pas le combo.
    --  - M1 rate -> si le joueur tient toujours block (F), on remet la garde
    --    automatiquement apres un court delai (le temps que le M1 finisse).
    local comboBefore = -1
    local comboVal = myChar:FindFirstChild("Combo")
    if comboVal and comboVal:IsA("IntValue") then comboBefore = comboVal.Value end
    task.spawn(function()
        task.wait(0.55)
        if getgenv().ABA_Unloaded then return end
        local ch = LocalPlayer.Character
        local c2 = ch and ch:FindFirstChild("Combo")
        local landed = (comboBefore >= 0 and c2 and c2:IsA("IntValue") and c2.Value > comboBefore)
        -- NOTE : le trade envoie un keyup F synthetique -> IsKeyDown(F) retombe a
        -- false meme si le joueur tient encore la touche. On se base donc sur
        -- l'etat de garde au moment du trade (isGuarding), capture ci-dessus.
        if landed then
            tradeLockUntil = tick() + 1.2
            -- Block persistant : apres le combo, si le joueur gardait la touche,
            -- la garde revient toute seule (pas besoin de relacher/rappuyer).
            task.delay(1.25, function()
                if getgenv().ABA_Unloaded then return end
                if isGuarding then
                    PerformBlockPress()
                end
            end)
        else
            if isGuarding and not getgenv().ABA_Unloaded then
                PerformBlockPress()
            end
        end
    end)
end

-- ====================================================================
-- AUTO COUNTER ENGINE (persos avec un counter : joué auto sur menace bloquable)
-- Détection générique : scan le Backpack (configs live) à la recherche d'un
-- move de counter par mots-clés, ou slot forcé manuellement (noms customs).
-- ====================================================================
lastCounterTick = 0
-- Horodatage de MES propres attaques (clic/M1 + touches 1-4) : si je viens d'attaquer,
-- l'ennemi est en réaction (hitstun/juggle), pas en attaque -> pas de counter.
-- Ça supprime les counters gâchés pendant mon propre combo/updraft.
lastOwnAttackTick = -10
table.insert(Connections, UserInputService.InputBegan:Connect(function(input)
    if getgenv().ABA_Unloaded then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.Two
        or input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.Four then
        lastOwnAttackTick = tick()
    end
end))

-- Ennemi "impuissant" (éjecté par mon combo, ragdoll, ou en fuite à toute vitesse) :
-- ce n'est jamais une vraie attaque, on garde le counter.
IsHelplessEnemy = function(myHRP, target)
    local eHRP = target and target.RootPart
    local eHum = target and target.Humanoid
    if not eHRP or not eHum or not myHRP then return true end
    local ok, st = pcall(function() return eHum:GetState() end)
    if ok then
        if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.Physics
            or st == Enum.HumanoidStateType.Seated then
            return true
        end
        -- Saut normal (jump-in à ~50) : peut attaquer, jamais impuissant
        if st == Enum.HumanoidStateType.Jumping then return false end
    end
    -- Éjecté : vertical au-dessus de tout saut normal
    if eHRP.Velocity.Y > 65 then return true end
    local dir = myHRP.Position - eHRP.Position
    if dir.Magnitude > 0.01 and eHRP.Velocity:Dot(dir.Unit) < -15 then return true end
    return false
end

local COUNTER_KEYWORDS = { "counter", "reversal", "parry", "reflect", "riposte", "punish", "stance", "foresight", "afterimage", "infinity", "limitless" }
local SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }

local function IsCounterReady(cfg)
    if not cfg then return false end
    local cd = cfg:GetAttribute("COOLDOWN")
    -- Convention ABA (même que l'ESP) : l'attribut monte jusqu'à 20 = prêt
    return cd == nil or (tonumber(cd) or 0) >= 20
end

FindCounterSlot = function()
    local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end

    local slots = {} -- [slotNum] = Configuration
    local order = 0
    for _, itemObj in ipairs(bp:GetChildren()) do
        if itemObj:IsA("Configuration") then
            order = order + 1
            local slotNum = order
            local cfg = itemObj:FindFirstChild(".Config")
            if cfg then
                for _, s in ipairs(cfg:GetChildren()) do
                    if s.Name:sub(1, 4) == "Slot" then
                        slotNum = tonumber(s.Name:sub(5)) or slotNum
                    end
                end
            end
            if slotNum >= 1 and slotNum <= 4 then
                slots[slotNum] = itemObj
            end
        end
    end

    -- Slot forcé manuellement (counters aux noms customs)
    local want = State.CounterSlot or "Auto"
    if want ~= "Auto" then
        local n = tonumber(tostring(want):match("%d"))
        local cfg = n and slots[n]
        if cfg and SLOT_KEYS[n] and IsCounterReady(cfg) then
            return { Slot = n, Key = SLOT_KEYS[n], Name = cfg.Name }
        end
        return nil
    end

    -- Auto-détection par nom de move
    for n = 1, 4 do
        local cfg = slots[n]
        if cfg and SLOT_KEYS[n] then
            local low = cfg.Name:lower()
            for _, kw in ipairs(COUNTER_KEYWORDS) do
                if low:find(kw) then
                    if IsCounterReady(cfg) then
                        return { Slot = n, Key = SLOT_KEYS[n], Name = cfg.Name }
                    end
                    break
                end
            end
        end
    end
    return nil
end

PerformAutoCounter = function(slot, target)
    if not State.AutoCounter or getgenv().ABA_Unloaded then return end
    -- Pas de gate temporelle ici : on n'est appelé QUE sur impact bloqué réel
    -- (l'attaque adverse a vraiment touché). Les faux positifs sont impossibles.
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChild("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    -- Pas de counter en pleine action / stun / skill
    if myChar:FindFirstChild("Action") or myChar:FindFirstChild("UsingSkill") then return end

    -- Face l'attaquant puis joue le counter (vrai input 1-4, pipeline authentique)
    local attHRP = target and target.RootPart
    if attHRP then
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(attHRP.Position.X, myHRP.Position.Y, attHRP.Position.Z))
    end
    if isCurrentlyBlocking then
        PerformBlockRelease()
    end
    task.wait(math.max(0.01, State.CounterHumanizer or 0.06))
    if getgenv().ABA_Unloaded then return end
    -- Voie officielle : InputAction:Fire(true/false), pattern exact du jeu lui-même
    -- (LocalCharacterScriptNew : Fire1-5 -> Move:Fire). Les touches VIM ne traversent
    -- pas sur certains executors (mesuré : 0/4 moves partis au clavier virtuel).
    local act = nil
    pcall(function()
        local bc = LocalPlayer.PlayerScripts:FindFirstChild("BaseContext")
        act = bc and bc:FindFirstChild("Move" .. tostring(slot.Slot or 0))
    end)
    if act then
        pcall(function() act:Fire(true) end)
        -- Hold ~0.35s (vérifié en jeu) : les moves à charge annulent si release trop tôt.
        -- Les moves instantanés partent au press, le release est ignoré (cooldown).
        task.wait(0.35)
        pcall(function() act:Fire(false) end)
    end
    -- Fallback legacy (executors où le clavier virtuel marche)
    VirtualInputManager:SendKeyEvent(true, slot.Key, false, game)
    task.wait(0.06)
    VirtualInputManager:SendKeyEvent(false, slot.Key, false, game)
end

-- Suivi parfait : on ARME à détection (menace à CounterRange) mais on ne TIRE que quand
-- l'attaquant est à CatchRange (impact imminent) ou à la fin de MaxWait. Entre-temps on reste
-- face à lui et on annule si la cible meurt/part ou si le counter n'est plus prêt (pas de gâchis).
TrackAndFireCounter = function(slot, target)
    if not State.AutoCounter or getgenv().ABA_Unloaded then return end
    local t0 = tick()
    local maxWait = State.CounterMaxWait or 0.35
    local catchAt = State.CounterCatchRange or 9

    while tick() - t0 < maxWait do
        if getgenv().ABA_Unloaded or not State.AutoCounter then return end
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        if not myHRP or not myHum or myHum.Health <= 0 then return end
        local model = target and target.Model
        local hrp = target and target.RootPart
        local hum = target and target.Humanoid
        if not model or not model.Parent or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
            return -- cible morte/partie : on garde le counter
        end
        -- L'ennemi s'est fait éjecter en cours de suivi (par moi ou un allié) : on annule, pas de gâchis
        if IsHelplessEnemy(myHRP, target) then return end
        local d = (hrp.Position - myHRP.Position).Magnitude
        -- Reste face à l'attaquant pendant l'approche (il peut strafer)
        myHRP.CFrame = CFrame.new(myHRP.Position, Vector3.new(hrp.Position.X, myHRP.Position.Y, hrp.Position.Z))
        if d <= catchAt then break end
        task.wait(0.03)
    end

    -- Re-valide juste avant de tirer : counter toujours prêt (pas utilisé entre-temps) ?
    local fresh = FindCounterSlot()
    if not fresh or fresh.Name ~= slot.Name then return end
    PerformAutoCounter(fresh, target)
end

-- ====================================================================
-- AUTO COUNTER DIRECT (independant du M1 Trade : marche meme si M1Trade OFF)
-- Sur un impact REELLEMENT bloque : si un counter est pret -> on le joue.
-- ====================================================================
local function TryAutoCounter()
    if not State.AutoCounter or getgenv().ABA_Unloaded then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChild("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    local now = os.clock()
    if now - lastCounterTick < (State.CounterCooldown or 2.5) then return end
    -- Attaquant : LastHit puis le plus proche
    local attacker = nil
    local lh = myChar:FindFirstChild("LastHit")
    if lh and lh.Value and lh.Value:IsA("Model") and lh.Value ~= myChar and lh.Value:FindFirstChild("HumanoidRootPart") then
        attacker = lh.Value
    else
        local closest, cd = nil, 12
        for _, e in ipairs(GetLiveEnemies()) do
            if e.Distance <= cd then cd = e.Distance; closest = e.Model end
        end
        attacker = closest
    end
    if not attacker then return end
    local attHRP = attacker:FindFirstChild("HumanoidRootPart")
    local eHum = attacker:FindFirstChildOfClass("Humanoid")
    if not (attHRP and eHum) or eHum.Health <= 0 then return end
    local dist = (attHRP.Position - myHRP.Position).Magnitude
    if dist > (State.CounterRange or 16) then return end
    if IsHelplessEnemy(myHRP, { Model = attacker, RootPart = attHRP, Humanoid = eHum }) then return end
    local slot = FindCounterSlot()
    if slot and not attacker.Name:lower():find("dummy") then
        lastCounterTick = now
        task.spawn(PerformAutoCounter, slot, { Model = attacker, RootPart = attHRP, Humanoid = eHum, Distance = dist })
    end
end

-- ====================================================================
-- Instant Event-Based Block Impact Hooks (Active Guard State Driven)
-- ====================================================================
local function HookM1TradeEvents(char)
    if not char then return end

    task.spawn(function()
        -- Hooks du perso precedent deconnectes (anti-fuite, meme pattern que Sukuna).
        local prevM1 = getgenv().__NW_M1CONNS
        if type(prevM1) == "table" then
            for _, c in ipairs(prevM1) do pcall(function() c:Disconnect() end) end
        end
        local myM1Conns = {}
        getgenv().__NW_M1CONNS = myM1Conns
        local function trackM1(c) table.insert(myM1Conns, c); table.insert(Connections, c); return c end
        local hum = char:WaitForChild("Humanoid", 8)
        local hrp = char:WaitForChild("HumanoidRootPart", 8)
        local blocking = char:WaitForChild("Blocking", 8)
        local fheld = char:WaitForChild("FHeld", 8)
        if not hum or not hrp then return end

        local function CheckGuarding()
            return isCurrentlyBlocking
                or (blocking and blocking.Value == true)
                or (fheld and fheld.Value == true)
                or UserInputService:IsKeyDown(Enum.KeyCode.F)
                or (tick() - lastBlockPressTick < 0.4)
        end

        -- Anti-barrage : 3+ impacts en <0.7s = barrage (fists/beam) -> pas de trade
        local impactTimes = {}
        local function RegisterImpact()
            local now = tick()
            table.insert(impactTimes, now)
            while #impactTimes > 0 and now - impactTimes[1] > 0.7 do
                table.remove(impactTimes, 1)
            end
            if #impactTimes >= 3 then
                barrageUntil = tick() + 1.2
            end
        end

        -- 1. ÉCOUTE DIRECTE DU SON DE BLOCAGE (Dès le 1er coup touché sur la garde !)
        local blockSound = hrp:FindFirstChild("BlockSound")
        if blockSound then
            trackM1(blockSound.Played:Connect(function()
                if CheckGuarding() then
                    RegisterImpact()
                    PerformM1Trade(nil, "BlockSound")
                    TryAutoCounter()
                end
            end))
        end

        -- Si BlockSound est ajouté dynamiquement
        trackM1(hrp.ChildAdded:Connect(function(child)
            if child.Name == "BlockSound" and child:IsA("Sound") then
                trackM1(child.Played:Connect(function()
                    if CheckGuarding() then
                        RegisterImpact()
                        PerformM1Trade(nil, "BlockSoundDynamic")
                        TryAutoCounter()
                    end
                end))
            end
        end))

        -- 2. ÉCOUTE DE L'IMPACT PARTICULES SUR LE HRP
        local blockParticle = hrp:FindFirstChild("Block")
        if blockParticle and blockParticle:IsA("ParticleEmitter") then
            trackM1(blockParticle:GetPropertyChangedSignal("Enabled"):Connect(function()
                if blockParticle.Enabled and CheckGuarding() then
                    RegisterImpact()
                    PerformM1Trade(nil, "BlockParticle")
                    TryAutoCounter()
                end
            end))
        end

        -- 3. ÉCOUTE DE LA BAISSE DE VIE (Pour les M1s avec chip damage)
        local lastHp = hum.Health
        trackM1(hum.HealthChanged:Connect(function(newHp)
            local delta = lastHp - newHp
            lastHp = newHp
            if delta < 0.05 or delta > 25 then return end -- Évite les gros burst de spells (> 25 dmg)

            if CheckGuarding() then
                RegisterImpact()
                PerformM1Trade(nil, "GuardedHP")
                TryAutoCounter()
            end
        end))
    end)
end

if LocalPlayer.Character then
    HookM1TradeEvents(LocalPlayer.Character)
end
table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.2)
    HookM1TradeEvents(newChar)
end))

-- ====================================================================
-- GUARDBREAK VS BLOCKABLE THREAT ENGINE (ABA Authentic Classification)
-- ====================================================================

local KnownGuardbreaks = {
    ["1,000,000% smash"] = true,
    ["10%"] = true,
    ["100% smash"] = true,
    ["1080 pound phoenix"] = true,
    ["16th form: moonbow, half moon"] = true,
    ["20mv vari"] = true,
    ["2nd tap variant"] = true,
    ["5 second"] = true,
    ["5 ton hammer"] = true,
    ["50 damage"] = true,
    ["8th form: moon dragon ringtail"] = true,
    ["9th form: waning moonswaths"] = true,
    ["aerial variant"] = true,
    ["air barrage"] = true,
    ["air bubble"] = true,
    ["air variation"] = true,
    ["airstrike"] = true,
    ["always"] = true,
    ["amaru"] = true,
    ["amaterasu"] = true,
    ["amaterasu variation"] = true,
    ["amazing impact"] = true,
    ["amputate"] = true,
    ["angel rush"] = true,
    ["angry kamehameha"] = true,
    ["annihilate ray"] = true,
    ["anti-esper dropkick"] = true,
    ["ap shot"] = true,
    ["ap shot barrage"] = true,
    ["aqua!"] = true,
    ["army of shadows"] = true,
    ["asakujaku"] = true,
    ["assassinate"] = true,
    ["atelier logic"] = true,
    ["atmospheric alteration"] = true,
    ["atomic blast"] = true,
    ["awakening"] = true,
    ["backhand"] = true,
    ["balloon inflate"] = true,
    ["barrel"] = true,
    ["bazooka"] = true,
    ["bearing shot"] = true,
    ["beatdown heavy"] = true,
    ["begone"] = true,
    ["beneficent radiance"] = true,
    ["berserking leap"] = true,
    ["big bang"] = true,
    ["big bang attack"] = true,
    ["big bang impact"] = true,
    ["bijuu dama"] = true,
    ["bird"] = true,
    ["black divider"] = true,
    ["black flash"] = true,
    ["black getsuga"] = true,
    ["black kamehameha"] = true,
    ["black ops"] = true,
    ["black power ball"] = true,
    ["black slash"] = true,
    ["blade combo"] = true,
    ["blast"] = true,
    ["blender"] = true,
    ["blind"] = true,
    ["blitz"] = true,
    ["blitz tackle"] = true,
    ["blood frenzy"] = true,
    ["bloodlust"] = true,
    ["blue infusion"] = true,
    ["body mutation"] = true,
    ["bomb"] = true,
    ["bonk"] = true,
    ["boogie woogie: smashdown"] = true,
    ["boulder throw"] = true,
    ["breaker"] = true,
    ["brilliant bone blades"] = true,
    ["brilliant flame"] = true,
    ["brutal tornado"] = true,
    ["brute force"] = true,
    ["bull thrust"] = true,
    ["bungee flail"] = true,
    ["bunker bolt"] = true,
    ["bunker breaker"] = true,
    ["burning attack"] = true,
    ["burst"] = true,
    ["burst energy"] = true,
    ["buster cannon"] = true,
    ["but"] = true,
    ["c4"] = true,
    ["card slicer"] = true,
    ["card throw"] = true,
    ["carolina smash"] = true,
    ["cero"] = true,
    ["cero metralleta"] = true,
    ["cero oscuras"] = true,
    ["chaff grenade"] = true,
    ["chain jail punishment"] = true,
    ["chain slam"] = true,
    ["chain swipe"] = true,
    ["chakram barrage"] = true,
    ["change the future"] = true,
    ["checkmate"] = true,
    ["chidori"] = true,
    ["chidori lament,"] = true,
    ["chidori stream"] = true,
    ["chidori true spear"] = true,
    ["chord assassination"] = true,
    ["chōōdama rasengan"] = true,
    ["clacker overdrive"] = true,
    ["claw"] = true,
    ["claymore"] = true,
    ["clear blue sky"] = true,
    ["cleave"] = true,
    ["cleaving strikes"] = true,
    ["cloaked lariat"] = true,
    ["close-range blast"] = true,
    ["cognac"] = true,
    ["coin bomb"] = true,
    ["collier"] = true,
    ["colossal uppercut"] = true,
    ["combat knife"] = true,
    ["comet strike"] = true,
    ["concasse"] = true,
    ["concasser"] = true,
    ["concassé"] = true,
    ["consecutive normal punches"] = true,
    ["contender"] = true,
    ["counter"] = true,
    ["counter shock"] = true,
    ["counter!"] = true,
    ["cover"] = true,
    ["crescent moon variant"] = true,
    ["crimson blade"] = true,
    ["crimson dragon fist"] = true,
    ["critical hit"] = true,
    ["cross kicks"] = true,
    ["cross slash"] = true,
    ["crown splitter"] = true,
    ["crush"] = true,
    ["cry"] = true,
    ["culverin"] = true,
    ["curse blade"] = true,
    ["cutting edge"] = true,
    ["cyclops punches"] = true,
    ["daishinkan"] = true,
    ["danku"] = true,
    ["dark claw"] = true,
    ["dark matter blaze"] = true,
    ["darkness"] = true,
    ["darkness flame dragon"] = true,
    ["darkness flame sword"] = true,
    ["dash"] = true,
    ["dash barrage"] = true,
    ["dazzling kick"] = true,
    ["death beam"] = true,
    ["death beam barrage"] = true,
    ["death saucer"] = true,
    ["death saucers"] = true,
    ["debris"] = true,
    ["decapitate"] = true,
    ["decimate"] = true,
    ["delaware detroit smash"] = true,
    ["delaware smash"] = true,
    ["demon claw strike"] = true,
    ["demon geyser"] = true,
    ["demon gun"] = true,
    ["demon hunt slash"] = true,
    ["demon tile punch"] = true,
    ["desert grande espada"] = true,
    ["desert spada"] = true,
    ["desert vacuum"] = true,
    ["desk smash"] = true,
    ["destruction energy"] = true,
    ["destruction fist"] = true,
    ["destructive death: thunder clap"] = true,
    ["destructive kicks"] = true,
    ["destructo disc"] = true,
    ["destructo disc barrage"] = true,
    ["detroit smash"] = true,
    ["diable jambe strike"] = true,
    ["dirt"] = true,
    ["disaster flame"] = true,
    ["disc steal"] = true,
    ["dismantle"] = true,
    ["dive"] = true,
    ["divergent blow"] = true,
    ["divergent fist"] = true,
    ["divine departure"] = true,
    ["divine lasso"] = true,
    ["dodon ray"] = true,
    ["dora barrage"] = true,
    ["doraaa!!!"] = true,
    ["double eraser cannon"] = true,
    ["down smash"] = true,
    ["downkick"] = true,
    ["downslam dummy"] = true,
    ["dowsing chain parry"] = true,
    ["dragon breath jutsu"] = true,
    ["dragon combo"] = true,
    ["dragon fist"] = true,
    ["dragon flower"] = true,
    ["dragon twister"] = true,
    ["dropkick elimination"] = true,
    ["during this interval has gojo shoot"] = true,
    ["dynamic mess em-up punch"] = true,
    ["east"] = true,
    ["eight layered: demon core"] = true,
    ["elephant gun"] = true,
    ["ember insects"] = true,
    ["end style: chaotic afterglow"] = true,
    ["endless eclipse"] = true,
    ["energy surge"] = true,
    ["energy wave"] = true,
    ["enhance armament"] = true,
    ["enuma elish"] = true,
    ["eraser blow"] = true,
    ["eraser cannon"] = true,
    ["erasure"] = true,
    ["erasure barrage"] = true,
    ["erasure ω"] = true,
    ["erdication tone"] = true,
    ["esoteric combo"] = true,
    ["especially"] = true,
    ["eternal darkness slash"] = true,
    ["ex shield dive"] = true,
    ["ex shield slide"] = true,
    ["excalibur"] = true,
    ["exploding clone"] = true,
    ["explosive beads"] = true,
    ["explosive field"] = true,
    ["explosive kunai"] = true,
    ["explosive kunais"] = true,
    ["explosive wave"] = true,
    ["exterminate"] = true,
    ["f hold variant"] = true,
    ["fa jin"] = true,
    ["falling lightning"] = true,
    ["father & son kamehameha"] = true,
    ["feather slashes"] = true,
    ["fiery barrage"] = true,
    ["fighting spirit"] = true,
    ["final destruction"] = true,
    ["final explosion"] = true,
    ["final flash"] = true,
    ["final impact"] = true,
    ["final kamehameha"] = true,
    ["final punch"] = true,
    ["final strike"] = true,
    ["finger cero"] = true,
    ["fire arrow"] = true,
    ["fire dragon roar"] = true,
    ["fire extinguisher"] = true,
    ["fire fist"] = true,
    ["fireball jutsu"] = true,
    ["firefly light"] = true,
    ["first dance"] = true,
    ["first hand"] = true,
    ["fishman bullets"] = true,
    ["five thousand tile punch"] = true,
    ["flambage shot"] = true,
    ["flame arrow"] = true,
    ["flame control"] = true,
    ["flame emperor"] = true,
    ["flame pillar"] = true,
    ["flaming tiger"] = true,
    ["flash break"] = true,
    ["flash freeze"] = true,
    ["flash kick"] = true,
    ["flashfreeze heatwave"] = true,
    ["flashstep"] = true,
    ["flight"] = true,
    ["flood"] = true,
    ["flourish"] = true,
    ["flurry kick"] = true,
    ["flying sword"] = true,
    ["fragor"] = true,
    ["freeze."] = true,
    ["freezing dash"] = true,
    ["freezing touch"] = true,
    ["frit assorti"] = true,
    ["fuga"] = true,
    ["future sight"] = true,
    ["gae bolg"] = true,
    ["galaxy impact: blue"] = true,
    ["galick"] = true,
    ["galick gun"] = true,
    ["gamma knife"] = true,
    ["gate of babylon (heavy)"] = true,
    ["gear third"] = true,
    ["getajob youbum"] = true,
    ["getsuga"] = true,
    ["getsuga slash"] = true,
    ["getsuga tensho"] = true,
    ["giant killer moves"] = true,
    ["giant rasengan"] = true,
    ["gigant axe"] = true,
    ["gigant pistol"] = true,
    ["gigantic meteor"] = true,
    ["gigantic roar"] = true,
    ["giorno"] = true,
    ["glacier"] = true,
    ["god big bang"] = true,
    ["gokei"] = true,
    ["goku"] = true,
    ["grab"] = true,
    ["gran ray cero"] = true,
    ["gran rey cero"] = true,
    ["great dragon shock"] = true,
    ["great eruption"] = true,
    ["great fireball"] = true,
    ["great hurricane"] = true,
    ["great tsunami"] = true,
    ["grenade"] = true,
    ["grenadier shot"] = true,
    ["grind"] = true,
    ["grip"] = true,
    ["grizzly magnum"] = true,
    ["ground crush"] = true,
    ["ground shaking"] = true,
    ["guillotine drop"] = true,
    ["gun"] = true,
    ["gura punch"] = true,
    ["gyuki grab"] = true,
    ["gyuki smash"] = true,
    ["hair grab"] = true,
    ["hammer"] = true,
    ["hamon bottlecap"] = true,
    ["hand of god"] = true,
    ["hat throw"] = true,
    ["head cracker"] = true,
    ["headbutt"] = true,
    ["heat dome attack"] = true,
    ["heaven sword"] = true,
    ["heavy slam"] = true,
    ["heavy strike"] = true,
    ["hecate 2"] = true,
    ["hell memories"] = true,
    ["hell spider"] = true,
    ["hellzone grenade"] = true,
    ["hierro counter"] = true,
    ["high output slash"] = true,
    ["hirudora"] = true,
    ["hit 1 — shotgun"] = true,
    ["hit 2 — smg spray"] = true,
    ["hit 3 — grenade"] = true,
    ["hold"] = true,
    ["hold up"] = true,
    ["hollow purple"] = true,
    ["home run"] = true,
    ["homing shot"] = true,
    ["hoverboard"] = true,
    ["howitzer impact"] = true,
    ["hyakuhachi pound ho"] = true,
    ["ice age"] = true,
    ["ice ball"] = true,
    ["ice crater"] = true,
    ["ice daggers"] = true,
    ["ice geyser"] = true,
    ["ice guard"] = true,
    ["ice path"] = true,
    ["ice prison"] = true,
    ["ice quake"] = true,
    ["ice trap"] = true,
    ["ice wall"] = true,
    ["ichimonji"] = true,
    ["impale"] = true,
    ["incinerate"] = true,
    ["indras arrow"] = true,
    ["infantry"] = true,
    ["inferno style"] = true,
    ["infinite void"] = true,
    ["injection shot"] = true,
    ["instant transmission"] = true,
    ["instant transmission kamehameha"] = true,
    ["instinct"] = true,
    ["instinct."] = true,
    ["insulted my hair?"] = true,
    ["invisible air"] = true,
    ["ironbreaker"] = true,
    ["ironbreaker revolution"] = true,
    ["irooni"] = true,
    ["island shake"] = true,
    ["island shaking"] = true,
    ["it kamehameha"] = true,
    ["jab"] = true,
    ["jave rin"] = true,
    ["jeep"] = true,
    ["jet bazooka"] = true,
    ["jet kick"] = true,
    ["judgement"] = true,
    ["justice crash"] = true,
    ["kageoni"] = true,
    ["kaioken finish"] = true,
    ["kaioken rush"] = true,
    ["kame"] = true,
    ["kame blast"] = true,
    ["kamehameha"] = true,
    ["kick"] = true,
    ["kick barrage"] = true,
    ["kick combo"] = true,
    ["kick rush"] = true,
    ["kicking"] = true,
    ["king cobra"] = true,
    ["king kong gun"] = true,
    ["king moves"] = true,
    ["kingsblade"] = true,
    ["kiribachi"] = true,
    ["kirin"] = true,
    ["kon"] = true,
    ["kurama roar"] = true,
    ["kurohitsugi,"] = true,
    ["landmines"] = true,
    ["lava fist"] = true,
    ["lava pillar"] = true,
    ["lava pool"] = true,
    ["leap"] = true,
    ["legendary weapon"] = true,
    ["letter i hunt"] = true,
    ["letter u hunt"] = true,
    ["life punch"] = true,
    ["light explosion"] = true,
    ["light grenade"] = true,
    ["light spear"] = true,
    ["light speed kick"] = true,
    ["lightning flame roar"] = true,
    ["lightning palm"] = true,
    ["lion song"] = true,
    ["looking at the clouds"] = true,
    ["maana blast"] = true,
    ["maana blast [cancelled"] = true,
    ["maana combo"] = true,
    ["madness impact"] = true,
    ["mahoraga"] = true,
    ["maka chop"] = true,
    ["malevolent shrine"] = true,
    ["mana burst"] = true,
    ["manchester axe kick"] = true,
    ["maser ho"] = true,
    ["maximum purple"] = true,
    ["megumin!"] = true,
    ["mero mero mellow"] = true,
    ["meteor"] = true,
    ["meteor shower"] = true,
    ["meteor smash"] = true,
    ["mini c3"] = true,
    ["mortal flame fist"] = true,
    ["mortal flamethrower"] = true,
    ["moves"] = true,
    ["muda barrage"] = true,
    ["mugetsu"] = true,
    ["nadegiri"] = true,
    ["napoleon"] = true,
    ["nergal blast"] = true,
    ["next dance"] = true,
    ["nigiri ripple"] = true,
    ["nikita"] = true,
    ["nine lives"] = true,
    ["noble phantasm"] = true,
    ["noble phantasm, via expugnatio: distant trampling domination"] = true,
    ["normal punch"] = true,
    ["normal use"] = true,
    ["normal ver."] = true,
    ["normal version"] = true,
    ["nova ascension"] = true,
    ["ocean current throw"] = true,
    ["odama rasengan"] = true,
    ["omega blaster"] = true,
    ["once per life"] = true,
    ["onigiri"] = true,
    ["onslaught"] = true,
    ["ora!"] = true,
    ["overdrive"] = true,
    ["overkill spiral"] = true,
    ["overtime collapse"] = true,
    ["overwhelming firepower"] = true,
    ["panther barbs"] = true,
    ["panther king claw"] = true,
    ["partisan"] = true,
    ["party table kick course"] = true,
    ["penetrator"] = true,
    ["perfect shot"] = true,
    ["perfect susanoo chidori"] = true,
    ["perfume breaker"] = true,
    ["perfume femur: magna"] = true,
    ["pheasant beak"] = true,
    ["photon wave"] = true,
    ["piercing lunge"] = true,
    ["planetary rasengan"] = true,
    ["police girl"] = true,
    ["pound phoenix"] = true,
    ["power counter"] = true,
    ["power roar"] = true,
    ["primary lotus"] = true,
    ["prominence burn"] = true,
    ["psychic blast"] = true,
    ["psychic punch"] = true,
    ["pulverizing pull"] = true,
    ["punch"] = true,
    ["punch onslaught"] = true,
    ["punching!"] = true,
    ["punishment"] = true,
    ["quake"] = true,
    ["quake bubble"] = true,
    ["qualkreis"] = true,
    ["r010:laser"] = true,
    ["r020: mirage"] = true,
    ["r020:mirage"] = true,
    ["radio knife"] = true,
    ["rage blast"] = true,
    ["ragnorok"] = true,
    ["raigo"] = true,
    ["raijin senkei"] = true,
    ["raikiri"] = true,
    ["raikoho"] = true,
    ["railgun"] = true,
    ["rapid kick rush"] = true,
    ["rapid sword stream"] = true,
    ["rasengan"] = true,
    ["rasengan barrage"] = true,
    ["rasengan throw"] = true,
    ["rasenshuriken"] = true,
    ["ratio collapse"] = true,
    ["ratio technique"] = true,
    ["ravager"] = true,
    ["reap"] = true,
    ["reckless charge"] = true,
    ["recovery bash"] = true,
    ["red"] = true,
    ["red cannon"] = true,
    ["red hawk"] = true,
    ["red reversal"] = true,
    ["reiatsu burst"] = true,
    ["reishi armoury"] = true,
    ["relentless strikes"] = true,
    ["resentment"] = true,
    ["reservoir"] = true,
    ["reversal red"] = true,
    ["ricochet"] = true,
    ["ricochet shot"] = true,
    ["right gun"] = true,
    ["rika"] = true,
    ["riot javelin"] = true,
    ["ripple fisticuffs"] = true,
    ["rising wind"] = true,
    ["road roller"] = true,
    ["roar"] = true,
    ["rocket launcher"] = true,
    ["rokougan"] = true,
    ["rolling thunder"] = true,
    ["rotation"] = true,
    ["rubble drop"] = true,
    ["rubble smash"] = true,
    ["run"] = true,
    ["rush"] = true,
    ["rushdown"] = true,
    ["sables pesado"] = true,
    ["saikuru"] = true,
    ["sakanade"] = true,
    ["sand shower"] = true,
    ["sand tsunami"] = true,
    ["sango"] = true,
    ["sankt alter"] = true,
    ["sanzen sekai"] = true,
    ["satan punch"] = true,
    ["savage kicks"] = true,
    ["scarlet punch"] = true,
    ["schwartzshieldo"] = true,
    ["scissor"] = true,
    ["scissor combo"] = true,
    ["scream"] = true,
    ["scythe weasel"] = true,
    ["sea splitter"] = true,
    ["second hand"] = true,
    ["self-transfiguration"] = true,
    ["serious punch"] = true,
    ["severance"] = true,
    ["severe hurricane"] = true,
    ["shaark!!!"] = true,
    ["shadow barrage"] = true,
    ["shadow clones"] = true,
    ["shadow slay"] = true,
    ["shadow the world"] = true,
    ["shark bomb jutsu"] = true,
    ["shark tooth drill"] = true,
    ["sheer heart attack"] = true,
    ["shield"] = true,
    ["shield dive"] = true,
    ["shield slide"] = true,
    ["shimmer"] = true,
    ["shinsu"] = true,
    ["shirafune"] = true,
    ["shishi sonson"] = true,
    ["shockwave"] = true,
    ["shoot to kill"] = true,
    ["shrine"] = true,
    ["shunpo slice"] = true,
    ["sickle of sorrow"] = true,
    ["sing"] = true,
    ["six paths"] = true,
    ["sixty-seventh hand"] = true,
    ["skate dash"] = true,
    ["skyscraper"] = true,
    ["slam dunk"] = true,
    ["slash"] = true,
    ["slashdown"] = true,
    ["slave arrow"] = true,
    ["sledgehammer"] = true,
    ["slice"] = true,
    ["slicing exorcism: flood"] = true,
    ["slow homing shot"] = true,
    ["smack"] = true,
    ["smash"] = true,
    ["smoke crescent"] = true,
    ["smokescreen"] = true,
    ["snipe"] = true,
    ["soaring strikes"] = true,
    ["sokatsui"] = true,
    ["sokotsu"] = true,
    ["solar heat haze"] = true,
    ["sonido kicks"] = true,
    ["sonido strike"] = true,
    ["soul rend"] = true,
    ["space"] = true,
    ["space bowabunga"] = true,
    ["spear"] = true,
    ["spear hand"] = true,
    ["spear thrust"] = true,
    ["special beam cannon"] = true,
    ["spiders"] = true,
    ["spike field"] = true,
    ["spikes"] = true,
    ["spinning elbow"] = true,
    ["spinning meteor"] = true,
    ["spirit bomb"] = true,
    ["spirit excalibur"] = true,
    ["spirit gun"] = true,
    ["spirit punch"] = true,
    ["square accel"] = true,
    ["squid bomb"] = true,
    ["st. louis smash"] = true,
    ["stand crash"] = true,
    ["stand leap"] = true,
    ["stand rush"] = true,
    ["stardust breaker ver."] = true,
    ["stardust fall"] = true,
    ["starrk"] = true,
    ["stinger"] = true,
    ["stove, open"] = true,
    ["straight cutball"] = true,
    ["striking tide"] = true,
    ["string performance: rhythm"] = true,
    ["string trick"] = true,
    ["stronger backhand"] = true,
    ["successful"] = true,
    ["summon: beru"] = true,
    ["summon: tank"] = true,
    ["sun & moon"] = true,
    ["sunlight slicer od"] = true,
    ["sunlight yellow overdrive"] = true,
    ["super burst energy"] = true,
    ["super explosive wave"] = true,
    ["super kamehameha"] = true,
    ["super shark bomb jutsu"] = true,
    ["super spirit bomb"] = true,
    ["super spirit sword"] = true,
    ["supreme genes"] = true,
    ["surprise kick"] = true,
    ["susanoo guard"] = true,
    ["susanoo rush"] = true,
    ["susanoo slash"] = true,
    ["swarming shot"] = true,
    ["swatter"] = true,
    ["sweep"] = true,
    ["sweeping blow"] = true,
    ["sword combo"] = true,
    ["sword conversion"] = true,
    ["sword cultivation"] = true,
    ["sword volley"] = true,
    ["taijutsu combo"] = true,
    ["tail beast twister"] = true,
    ["tailed beast bomb"] = true,
    ["talisman"] = true,
    ["tatsumaki"] = true,
    ["tekkai"] = true,
    ["telepathic volcano"] = true,
    ["tendril"] = true,
    ["tenjin"] = true,
    ["tensho"] = true,
    ["terraform"] = true,
    ["texas smash"] = true,
    ["thermal element"] = true,
    ["three thousand worlds"] = true,
    ["throw ex"] = true,
    ["thunder strike"] = true,
    ["thunderclap & flash"] = true,
    ["tiger hunt"] = true,
    ["time shift"] = true,
    ["torch"] = true,
    ["tracking shards"] = true,
    ["transmute weapon"] = true,
    ["tree"] = true,
    ["triple snipe"] = true,
    ["troias tragōidia: tempestuous immortal chariot"] = true,
    ["true power"] = true,
    ["true strength"] = true,
    ["true strike"] = true,
    ["turtle power"] = true,
    ["tyrant lancer"] = true,
    ["ultimate rush"] = true,
    ["ultra crush cannon"] = true,
    ["ultra dynamite"] = true,
    ["umbral control"] = true,
    ["umbral pressure"] = true,
    ["umbral strike"] = true,
    ["united states of smash"] = true,
    ["unknowing fire"] = true,
    ["unravel"] = true,
    ["up close"] = true,
    ["uppercut"] = true,
    ["upward"] = true,
    ["use 1 [dash"] = true,
    ["use 1 [tornado"] = true,
    ["use 2 [counter"] = true,
    ["use 2: debris"] = true,
    ["use 2: flying raijin: level 2"] = true,
    ["use 2: leap + detroit smash"] = true,
    ["use 2: mask + flash strike"] = true,
    ["use 2: mask + getsuga"] = true,
    ["use 2: quake"] = true,
    ["use 2: unlimited void + hollow purple"] = true,
    ["use 2: unlimited void + maximum collapsing blue"] = true,
    ["v2 lariat"] = true,
    ["vampiric strength"] = true,
    ["vanish kick"] = true,
    ["vault"] = true,
    ["virtuous assault"] = true,
    ["volcanic rush"] = true,
    ["volleyball"] = true,
    ["wall of flames"] = true,
    ["warping leaps"] = true,
    ["watch your back!"] = true,
    ["water dragon"] = true,
    ["waterfowl dance"] = true,
    ["wave explosion"] = true,
    ["weak repel"] = true,
    ["weak strike"] = true,
    ["weak texas smash"] = true,
    ["wen ning"] = true,
    ["whack-a-mole jutsu"] = true,
    ["wheels industry"] = true,
    ["whiff"] = true,
    ["whirlpool"] = true,
    ["whirlwind"] = true,
    ["white ripple"] = true,
    ["wild leap"] = true,
    ["will"] = true,
    ["wind style: rasenshuriken"] = true,
    ["witch hunt slash"] = true,
    ["with an orb"] = true,
    ["wolves"] = true,
    ["world cutting slash"] = true,
    ["worm"] = true,
    ["wyoming smash"] = true,
    ["x4 kaioken kamehameha"] = true,
    ["yasaka beads"] = true,
    ["yellow flash whirlwind"] = true,
    ["yoruba forge"] = true,
    ["you can nullify and reflect attacks from anyone"] = true,
    ["your next line is"] = true,
    ["zelkova workshop"] = true,
    ["zeroth bow"] = true,
    ["zeus and prometheus"] = true,
    ["zeus or prometheus"] = true,
    ["zodd"] = true,
    ["zomba"] = true,
    ["zoom punch"] = true,
    ["ōdama rasengan"] = true,
    ["☆ idol punch ☆"] = true,
    ["❹ wolves"] = true,
}

local RadialGuardbreaks = {
    ["16th form: moonbow, half moon"] = true,
    ["5 ton hammer"] = true,
    ["aerial variant"] = true,
    ["air barrage"] = true,
    ["airstrike"] = true,
    ["amaterasu variation"] = true,
    ["aqua!"] = true,
    ["asakujaku"] = true,
    ["atmospheric alteration"] = true,
    ["awakening"] = true,
    ["backhand"] = true,
    ["beneficent radiance"] = true,
    ["berserking leap"] = true,
    ["black divider"] = true,
    ["black kamehameha"] = true,
    ["black power ball"] = true,
    ["blind"] = true,
    ["blitz tackle"] = true,
    ["bonk"] = true,
    ["boogie woogie: smashdown"] = true,
    ["bunker breaker"] = true,
    ["but"] = true,
    ["c4"] = true,
    ["chain slam"] = true,
    ["chidori lament,"] = true,
    ["claymore"] = true,
    ["clear blue sky"] = true,
    ["cognac"] = true,
    ["collier"] = true,
    ["cover"] = true,
    ["cyclops punches"] = true,
    ["demon hunt slash"] = true,
    ["desert grande espada"] = true,
    ["desk smash"] = true,
    ["dismantle"] = true,
    ["divine departure"] = true,
    ["dodon ray"] = true,
    ["down smash"] = true,
    ["downkick"] = true,
    ["downslam dummy"] = true,
    ["dowsing chain parry"] = true,
    ["during this interval has gojo shoot"] = true,
    ["eraser blow"] = true,
    ["erasure ω"] = true,
    ["erdication tone"] = true,
    ["ex shield dive"] = true,
    ["exterminate"] = true,
    ["falling lightning"] = true,
    ["final explosion"] = true,
    ["first hand"] = true,
    ["flame pillar"] = true,
    ["flashstep"] = true,
    ["flood"] = true,
    ["future sight"] = true,
    ["glacier"] = true,
    ["grab"] = true,
    ["great tsunami"] = true,
    ["grenade"] = true,
    ["gyuki grab"] = true,
    ["hammer"] = true,
    ["hand of god"] = true,
    ["head cracker"] = true,
    ["heavy slam"] = true,
    ["hecate 2"] = true,
    ["hell memories"] = true,
    ["hell spider"] = true,
    ["hierro counter"] = true,
    ["hirudora"] = true,
    ["howitzer impact"] = true,
    ["ice quake"] = true,
    ["ichimonji"] = true,
    ["infantry"] = true,
    ["instant transmission"] = true,
    ["ironbreaker revolution"] = true,
    ["jab"] = true,
    ["jeep"] = true,
    ["judgement"] = true,
    ["justice crash"] = true,
    ["kick combo"] = true,
    ["king cobra"] = true,
    ["kingsblade"] = true,
    ["kirin"] = true,
    ["kon"] = true,
    ["leap"] = true,
    ["light spear"] = true,
    ["madness impact"] = true,
    ["manchester axe kick"] = true,
    ["meteor"] = true,
    ["meteor shower"] = true,
    ["meteor smash"] = true,
    ["mortal flame fist"] = true,
    ["nikita"] = true,
    ["noble phantasm, via expugnatio: distant trampling domination"] = true,
    ["ocean current throw"] = true,
    ["once per life"] = true,
    ["ora!"] = true,
    ["partisan"] = true,
    ["primary lotus"] = true,
    ["psychic punch"] = true,
    ["quake"] = true,
    ["radio knife"] = true,
    ["raijin senkei"] = true,
    ["ratio collapse"] = true,
    ["reiatsu burst"] = true,
    ["relentless strikes"] = true,
    ["reversal red"] = true,
    ["rika"] = true,
    ["road roller"] = true,
    ["roar"] = true,
    ["rubble drop"] = true,
    ["sand tsunami"] = true,
    ["sankt alter"] = true,
    ["shield dive"] = true,
    ["shrine"] = true,
    ["sickle of sorrow"] = true,
    ["slam dunk"] = true,
    ["sledgehammer"] = true,
    ["smack"] = true,
    ["sonido strike"] = true,
    ["space bowabunga"] = true,
    ["spear"] = true,
    ["spinning meteor"] = true,
    ["spirit punch"] = true,
    ["squid bomb"] = true,
    ["st. louis smash"] = true,
    ["stand leap"] = true,
    ["stinger"] = true,
    ["stronger backhand"] = true,
    ["swatter"] = true,
    ["sweep"] = true,
    ["tekkai"] = true,
    ["texas smash"] = true,
    ["tiger hunt"] = true,
    ["true power"] = true,
    ["true strength"] = true,
    ["umbral pressure"] = true,
    ["uppercut"] = true,
    ["use 2 [counter"] = true,
    ["use 2: flying raijin: level 2"] = true,
    ["use 2: quake"] = true,
    ["vampiric strength"] = true,
    ["vanish kick"] = true,
    ["vault"] = true,
    ["warping leaps"] = true,
    ["weak texas smash"] = true,
    ["wen ning"] = true,
    ["whack-a-mole jutsu"] = true,
    ["wheels industry"] = true,
    ["wild leap"] = true,
    ["witch hunt slash"] = true,
    ["wyoming smash"] = true,
    ["yoruba forge"] = true,
    ["zeus and prometheus"] = true,
    ["zomba"] = true,
    ["quake bubble"] = true,
    ["island shake"] = true,
    ["island shaking"] = true,
    ["spinning meteor"] = true,
    ["shinra tensei"] = true,
    ["overtime collapse"] = true,
    ["road roller"] = true,
    ["stand crash"] = true,
    ["malevolent shrine"] = true,
    ["sand tsunami"] = true,
    ["tree slam"] = true,
    ["hellzone grenade"] = true,
    ["super spirit bomb"] = true,
    ["slam"] = true,
    ["final explosion"] = true,
}

local BasicM1AnimIds = {
    ["1461027506"] = true,
    ["1461128859"] = true,
    ["1461136273"] = true,
    ["1461137417"] = true,
    ["1461128166"] = true,
    ["1461142361"] = true,
    ["1461139102"] = true,
    ["1461138523"] = true,
    ["1461091042"] = true,
    ["1461145506"] = true,
    ["1461127258"] = true,
    ["1461267662"] = true,
    ["1461098537"] = true,
    ["1461140455"] = true,
    ["1461136875"] = true,
    ["1461252313"] = true,
    ["1461265895"] = true,
    ["84229654169757"] = true,
    ["121557576385951"] = true,
    ["133394919932479"] = true,
    ["18352161100"] = true,
}

local gbMemoCache = {}
local function IsMoveGuardbreak(moveName)
    if not moveName or type(moveName) ~= "string" then return false end
    local lower = moveName:lower()
    local cached = gbMemoCache[lower]
    if cached ~= nil then return cached end

    if KnownGuardbreaks[lower] then
        gbMemoCache[lower] = true
        return true
    end
    for gbName, _ in pairs(KnownGuardbreaks) do
        if #gbName >= 4 and lower:find(gbName, 1, true) then
            gbMemoCache[lower] = true
            return true
        end
    end
    gbMemoCache[lower] = false
    return false
end

local function GetGuardbreakDodgeKey(moveName)
    if not moveName or type(moveName) ~= "string" then
        dodgeSideToggle = not dodgeSideToggle
        return dodgeSideToggle and Enum.KeyCode.D or Enum.KeyCode.A
    end

    local lower = moveName:lower()

    -- 1. Radial / 360 AOE Guardbreaks -> DASH BACKWARDS (S)
    for name, _ in pairs(RadialGuardbreaks) do
        if lower:find(name, 1, true) then
            return Enum.KeyCode.S
        end
    end

    -- 2. Linear / Beam / Dash / Punch Guardbreaks (Bazooka, Cero, Smash, Cleave, etc.)
    -- MUST DASH SIDEWAYS (A or D) to immediately exit the forward line of fire!
    dodgeSideToggle = not dodgeSideToggle
    return dodgeSideToggle and Enum.KeyCode.D or Enum.KeyCode.A
end

local function IsRangedMove(moveName)
    if not moveName or type(moveName) ~= "string" then return false end
    local lower = moveName:lower()
    local rangedKeywords = {
        "pistol", "kamehameha", "getsuga", "cero", "rasen", "beam", "blast",
        "projectile", "arrow", "fuga", "purple", "red", "cleave", "dismantle",
        "special beam", "enuma", "babylon", "spirit gun", "bullet", "bazooka",
        "rocket", "shot", "fireball"
    }
    for _, kw in ipairs(rangedKeywords) do
        if lower:find(kw, 1, true) then
            return true
        end
    end
    return false
end

local function CheckTargetThreat(target, activeTracks, dist, dot)
    local isGuardbreak = false
    local isThreat = false
    local threatMoveName = nil

    -- 1. Check actively playing animation tracks
    for _, track in ipairs(activeTracks) do
        local animName = track.Name:lower()
        if not animName:find("idle") and not animName:find("walk") and not animName:find("run") and not animName:find("jump") and not animName:find("fall") and not animName:find("dance") and not animName:find("sit") then
            -- Guardbreak check on animation name
            if IsMoveGuardbreak(animName) then
                isGuardbreak = true
                isThreat = true
                threatMoveName = animName
                break
            end

            -- Standard ABA M1 IDs (Light1-5)
            local animId = (track.Animation and track.Animation.AnimationId) or ""
            local idNum = animId:match("%d+")
            if idNum and BasicM1AnimIds and BasicM1AnimIds[idNum] then
                isThreat = true
                threatMoveName = "M1"
                break
            end
            if animName:sub(1, 5) == "light" or animName == "m1" or animName == "m1swing" then
                isThreat = true
                threatMoveName = "M1"
                break
            end

            -- Named attack / skill animations
            if animName:find("punch") or animName:find("kick") or animName:find("slash") 
               or animName:find("gatling") or animName:find("pistol") or animName:find("rocket") 
               or animName:find("rush") or animName:find("kamehameha") or animName:find("strike") 
               or animName:find("multi") or animName:find("barrage") or animName:find("muda") 
               or animName:find("ora") or animName:find("cero") or animName:find("getsuga") then
                isThreat = true
                threatMoveName = animName
                break
            end
        end
    end

    -- 2. Check enemy Character children / action state
    if not isThreat then
        local act = target.Model:FindFirstChild("Action") or target.Model:FindFirstChild("UsingSkill")
        if act then
            isThreat = true
            local actVal = (act:IsA("StringValue") and act.Value:lower()) or act.Name:lower()
            if IsMoveGuardbreak(actVal) then
                isGuardbreak = true
            end
            threatMoveName = actVal ~= "" and actVal or "Skill"
        end
    end

    -- 3. STRICT DISTANCE & AIM FILTER (Eliminates false blocking in the void!)
    -- If outside close melee strike range (> 16 studs):
    -- It can ONLY be a threat if it is an actual RANGED projectile / guardbreak aimed directly at us!
    if isThreat and dist > 16 then
        local isRanged = IsRangedMove(threatMoveName) or isGuardbreak
        if not isRanged or (dot and dot < 0.82) then
            -- Discard: distant melee swing or not aimed at us
            return false, false, nil
        end
    end

    return isThreat, isGuardbreak, threatMoveName
end

local lastParryTick = 0
local parryConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local now = tick()
    -- FIX FPS: 0.016 (60Hz) + GetPlayingAnimationTracks par ennemi = 600+ allocs/sec -> 4 FPS mesuré
    -- 0.05 (20Hz) suffit pour block/dodge humain (réaction 150-200ms) et divise le coût par 3
    if now - lastParryTick < (State.EcoMode and 0.1 or 0.05) then return end
    lastParryTick = now

    local curState = GetState()

    -- Release block if hold timer expired
    if isCurrentlyBlocking and tick() >= blockReleaseTick then
        PerformBlockRelease()
    end

    -- If neither AutoBlock nor AutoDodge is active, nothing to defend against
    if not curState.AutoBlock and not curState.AutoDodge then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChild("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end

    local now = tick()
    local enemies = GetLiveEnemies()

    for _, target in ipairs(enemies) do
        if target.Distance <= curState.BlockDistance then
            local eHRP = target.RootPart
            local eHum = target.Humanoid
            local toMe = (myHRP.Position - eHRP.Position).Unit
            local dot = eHRP.CFrame.LookVector:Dot(toMe)
            local isFacing = true
            if curState.CheckFacing then
                -- Melee requires dot > 0.55 (directly facing us); ranged requires dot > 0.82
                isFacing = (dot > 0.55)
            end

            if isFacing then
                local activeTracks = eHum:GetPlayingAnimationTracks()
                local isThreat, isGuardbreak, threatMoveName = CheckTargetThreat(target, activeTracks, target.Distance, dot)

                if isThreat then
                    if isGuardbreak then
                        -- =========================================================
                        -- 1. GUARDBREAK / UNBLOCKABLE ATTACK DETECTED
                        -- =========================================================
                        -- Drop block immediately so shield does not get shattered!
                        if isCurrentlyBlocking then
                            PerformBlockRelease()
                        end

                        -- Directional Dodge: Side (A/D) for Beams/Punches, Backwards (S) for Radial AOEs
                        if curState.AutoDodge and (now - lastDodgeTick >= curState.DodgeCooldown) then
                            local dodgeKey = GetGuardbreakDodgeKey(threatMoveName)
                            PerformDirectionalDodge(dodgeKey)
                        end
                    else
                        -- =========================================================
                        -- 2. BLOCKABLE ATTACK DETECTED (Gatling, Pistol, Rocket, M1s)
                        -- =========================================================
                        -- STRICT RULE: NEVER DODGE A BLOCKABLE ATTACK!
                        -- Always block with F so M1Trade absorbs the hit and counters!
                        -- 2b. AUTO COUNTER PRÉDICTIF (Gojo Infinity & co) : on arme sur une
                        -- attaque adverse PROUVÉE + mains libres. Pas de counter fantôme :
                        --  - mains libres 0.45s : si je viens d'attaquer (updraft/combo),
                        --    l'ennemi réagit, il n'attaque pas
                        --  - jamais sur cible impuissante (éjectée/fuite), mannequin,
                        --    ni sur simple marqueur d'Action sans preuve d'attaque
                        -- Le déclenchement sur IMPACT (PerformM1Trade) reste le filet principal.
                        if curState.AutoCounter and target.Distance <= (curState.CounterRange or 16)
                            and (now - lastCounterTick >= (curState.CounterCooldown or 2.5))
                            and (now - lastOwnAttackTick >= 0.45)
                            and not IsHelplessEnemy(myHRP, target)
                            and not (target.Model and target.Model.Name:lower():find("dummy")) then
                            local eAct = target.Model:FindFirstChild("Action") or target.Model:FindFirstChild("UsingSkill")
                            local actVal = eAct and ((eAct:IsA("StringValue") and eAct.Value:lower()) or eAct.Name:lower()) or ""
                            local provenM1 = (threatMoveName == "M1")
                            local offensiveCast = (actVal ~= "" and actVal ~= "none")
                            if provenM1 or offensiveCast then
                                local slot = FindCounterSlot()
                                if slot then
                                    lastCounterTick = now
                                    task.spawn(TrackAndFireCounter, slot, target)
                                    break
                                end
                            end
                        end
                        if curState.AutoBlock then
                            local isMultiHit = IsEnemyInMultiHitBarrage(target.Model)
                                or (threatMoveName and (threatMoveName:lower():find("gatling") or threatMoveName:lower():find("rush") or threatMoveName:lower():find("barrage") or threatMoveName:lower():find("rapid")))

                            if isCurrentlyBlocking then
                                -- CONTINUOUS BLOCK: Keep holding F dynamically as long as Gatling/attack is ongoing!
                                local extendDuration = isMultiHit and 0.5 or 0.25
                                blockReleaseTick = math.max(blockReleaseTick, now + curState.BlockDuration + extendDuration)
                            else
                                -- Start blocking!
                                if now - lastBlockTick >= curState.BlockCooldown then
                                    lastBlockTick = now
                                    local initialHold = isMultiHit and (curState.BlockDuration + 1.2) or curState.BlockDuration
                                    blockReleaseTick = now + initialHold

                                    task.delay(curState.HumanizerDelay, function()
                                        if not getgenv().ABA_Unloaded and curState.AutoBlock and not isCurrentlyBlocking then
                                            PerformBlockPress()
                                        end
                                    end)
                                end
                            end
                        end
                    end
                    break
                end
            end
        end
    end
end)
table.insert(Connections, parryConn)



-- 3. AUTO AWAKENING (G) (Throttled 0.25s)
local lastAwakenCheck = 0
local autoAwakenConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local curState = GetState()
    if not curState.AutoAwakening then return end

    local now = tick()
    if now - lastAwakenCheck < 0.25 then return end
    lastAwakenCheck = now

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHum = myChar:FindFirstChild("Humanoid")
    if not myHum or myHum.Health <= 0 then return end
        local hud = LocalPlayer.PlayerGui:FindFirstChild("HUD")
        if hud then
            local ult = hud:FindFirstChild("Ultimate") or hud:FindFirstChild("Ultimate2")
            if ult then
                local bar = ult:FindFirstChild("Bar")
                local ultiIcon = ult:FindFirstChild("ulti")
                local isFull = false
                if bar and bar.Size.X.Scale >= 0.98 then isFull = true end
                if ultiIcon and ultiIcon.Visible then isFull = true end

                if isFull then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                    task.delay(0.05, function()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                    end)
                end
            end
        end
end)
table.insert(Connections, autoAwakenConn)

-- =========================================================================
--  AUTO PLAY BOT v2 (public games: chase + M1 + skills 1-4 + awaken G)
--  Deplacement : stepping direct du HRP (ABA ignore MoveTo) + steering par
--  raycasts (evite les coins), escalade anti-stuck + blacklist des cibles
--  inatteignables. Caches pour l'optim. Humanizer pour ne pas sentir le bot.
--
--  TOUT est dans un do ... end : le chunk principal approche la limite Lua
--  de 200 locals (compile error "Out of local registers") sans ce scope.
-- =========================================================================
do
local AP_SLOT_KEYS = { [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four }
local apLastSkillTick = { [1] = 0, [2] = 0, [3] = 0, [4] = 0 }
local apLastM1Tick = 0
local apM1Gap = 0.28          -- rythme des M1 (remplace par le rythme enregistre si imitation)
local apLastImitTicks = 0     -- cadence des sauts/dodges imites
local apStuckPos, apStuckTime = nil, 0
local apCurrentTarget = nil
-- Forward decl : definies dans le bloc Imitation plus bas, utilisees par les boucles du bot
local AP_ImitStats, AP_EffectiveAtkR
getgenv().ABA_AutoPlayTarget = nil

-- ------------------------------------------------------------------ caches
-- Refs perso (HRP/Humanoid/Animator/Run/BaseContext/Input) rafraichies 2s max.
local apRefs = { char = nil, refreshed = 0 }
local function AP_RefreshRefs()
    local char = LocalPlayer.Character
    local now = tick()
    if char ~= apRefs.char or now - apRefs.refreshed > 2 then
        apRefs.char = char
        apRefs.refreshed = now
        apRefs.hrp = char and char:FindFirstChild("HumanoidRootPart")
        apRefs.hum = char and char:FindFirstChildOfClass("Humanoid")
        apRefs.animator = apRefs.hum and apRefs.hum:FindFirstChildOfClass("Animator")
        local anims = char and char:FindFirstChild("Anims")
        apRefs.runAnim = anims and anims:FindFirstChild("Run")
        apRefs.bc = LocalPlayer.PlayerScripts and LocalPlayer.PlayerScripts:FindFirstChild("BaseContext")
        local bp = LocalPlayer:FindFirstChild("Backpack")
        apRefs.inputRemote = game:GetService("StarterPack"):FindFirstChild("Input")
            or (bp and bp:FindFirstChild("Input"))
    end
    return apRefs
end

-- Readiness des skills : un seul scan Backpack tous les 0.3s (avant : 4 scans/0.2s)
local apSkillCache = { t = 0, map = {} }
local function AP_IsSkillReady(slotNum)
    local now = tick()
    if now - apSkillCache.t > 0.3 then
        apSkillCache.t = now
        local map = {}
        local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local order = 0
            for _, itemObj in ipairs(bp:GetChildren()) do
                if itemObj:IsA("Configuration") then
                    order = order + 1
                    local cfg = itemObj:FindFirstChild(".Config")
                    local n = order
                    if cfg then
                        for _, s in ipairs(cfg:GetChildren()) do
                            if s.Name:sub(1, 4) == "Slot" then n = tonumber(s.Name:sub(5)) or n end
                        end
                    end
                    if n >= 1 and n <= 4 then
                        local cd = itemObj:GetAttribute("COOLDOWN")
                        map[n] = (cd == nil or (tonumber(cd) or 0) >= 20)
                    end
                end
            end
        end
        apSkillCache.map = map
    end
    return apSkillCache.map[slotNum] == true
end

-- Blacklist : cible inatteignable -> ignoree quelques secondes (anti-blocage
-- dans un coin, derriere un mur ou sur une plateforme insensible au saut).
local apBlacklist = {}
local function AP_IsBlacklisted(model)
    if not model then return false end
    local until_ = apBlacklist[model]
    if not until_ then return false end
    if until_ < tick() then
        apBlacklist[model] = nil
        return false
    end
    return true
end
local function AP_BlacklistTarget(model, secs)
    if model then apBlacklist[model] = tick() + (secs or 10) end
end

-- Ligne de vue (throttle 0.25s) : ne pas taper a travers les murs.
local apLosParams = RaycastParams.new()
apLosParams.FilterType = Enum.RaycastFilterType.Exclude
local apLosCache = { t = 0, model = nil, ok = false }
local function AP_HasLOS(myChar, myHRP, target)
    if not (myChar and myHRP and target and target.RootPart) then return true end
    local now = tick()
    if target.Model ~= apLosCache.model or now - apLosCache.t > 0.25 then
        apLosCache.t = now
        apLosCache.model = target.Model
        apLosParams.FilterDescendantsInstances = { myChar }
        local origin = myHRP.Position + Vector3.new(0, 2, 0)
        local hit = workspace:Raycast(origin, target.RootPart.Position - origin, apLosParams)
        apLosCache.ok = (hit == nil) or (hit.Instance and hit.Instance:IsDescendantOf(target.Model))
    end
    return apLosCache.ok
end

-- Steering anti-coins : teste 7 directions, prend la premiere libre.
local apAvoidParams = RaycastParams.new()
apAvoidParams.FilterType = Enum.RaycastFilterType.Exclude
local apSteer = { t = 0, dir = nil, blocked = false }
local function AP_ChooseStepDir(myChar, targetModel, origin, dir)
    apAvoidParams.FilterDescendantsInstances = { myChar, targetModel }
    local probes = { 0, 35, -35, 70, -70, 105, -105, 140, -140 }
    for _, ang in ipairs(probes) do
        local rad = math.rad(ang)
        local c, s = math.cos(rad), math.sin(rad)
        local d = Vector3.new(dir.X * c - dir.Z * s, 0, dir.X * s + dir.Z * c)
        local hit = workspace:Raycast(origin + Vector3.new(0, 2.5, 0), d * 5, apAvoidParams)
        if not hit then return d, false end
    end
    return dir, true
end

-- Humanizer : vitesse legerement variable, micro-pauses, strafes, hops.
local apHum = {
    speedJitter = 1, speedJitterUntil = 0,
    engageOffset = 0, engageTarget = nil,
    pauseUntil = 0, pauseRoll = 0,
    strafeDir = 1, strafeUntil = 0, strafeNext = 0,
    hopNext = 0,
}
local apStuckLevel, apStuckPos2, apStuckT2 = 0, nil, 0

local function AP_IsAwakened(char)
    if not char then return false end
    return char:FindFirstChild("State2") ~= nil
        or char:FindFirstChild("SUPERAWAKENWHENEVER") ~= nil
        or char:FindFirstChild("MobAwaken") ~= nil
        or char:FindFirstChild("Mode") ~= nil
end

local function AP_IsAwakenReady()
    local hud = LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("HUD")
    local ult = hud and (hud:FindFirstChild("Ultimate") or hud:FindFirstChild("Ultimate2"))
    if not ult then return false end
    local bar = ult:FindFirstChild("Bar")
    local ultiIcon = ult:FindFirstChild("ulti")
    if bar and bar.Size and bar.Size.X.Scale >= 0.98 then return true end
    if ultiIcon and ultiIcon.Visible then return true end
    return false
end

local apLastAwakenPress = 0
local function AP_PressAwaken()
    local now = tick()
    if now - apLastAwakenPress < 3 then return end
    apLastAwakenPress = now
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
    task.delay(0.05, function()
        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game) end)
    end)
end

local function AP_GetTarget()
    local enemies = GetLiveEnemies()
    if #enemies == 0 then return nil end
    local rng = State.AutoPlay_Range or 250
    local mode = State.AutoPlay_TargetMode or "Closest"
    local playersOnly = (mode == "Players Only")
    local best, bestScore = nil, math.huge
    for _, e in ipairs(enemies) do
        if e.Distance <= rng and e.Model and not AP_IsBlacklisted(e.Model) then
            if not playersOnly or e.Player ~= nil then
                local score = e.Distance
                if mode == "Lowest HP" then
                    score = (e.Humanoid and e.Humanoid.Health > 0) and e.Humanoid.Health or math.huge
                end
                if score < bestScore then
                    bestScore = score
                    best = e
                end
            end
        end
    end
    return best
end

-- (AP_IsSkillReady version cachee : definie dans le bloc caches plus haut)

-- v3 : le jeu gere le mouvement (et tourne le CORPS vers la camera). Le bot
-- pilote donc avec de VRAIES touches W+Shift, camera braquee sur la cible
-- (elle tient, teste camDot=1.0), et n'utilise le stepping CFrame qu'en
-- secours si la progression est nulle (mur, input bloque).
local apKeys = { W = false, Shift = false, A = false, D = false, S = false }
local AP_KEYCODES = {
    W = Enum.KeyCode.W,
    Shift = Enum.KeyCode.LeftShift,
    A = Enum.KeyCode.A,
    D = Enum.KeyCode.D,
    S = Enum.KeyCode.S,
}

local function AP_Key(name, down)
    if apKeys[name] == down then return end
    apKeys[name] = down
    local kc = AP_KEYCODES[name]
    if kc then
        pcall(function() VirtualInputManager:SendKeyEvent(down, kc, false, game) end)
    end
end

local function AP_ReleaseKeys()
    for name in pairs(apKeys) do
        AP_Key(name, false)
    end
end
getgenv().ABA_AP_ReleaseKeys = AP_ReleaseKeys

-- Camera : garde SA POSITION (sinon la vue saute dans la tete du perso) et
-- regarde la cible. C'est ce qui fait que le corps suit (le jeu tourne le
-- personnage vers la camera quand il y a du mouvement/attaque).
local function AP_AimCamera(targetPos)
    if not targetPos then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    pcall(function()
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, Vector3.new(targetPos.X, cam.CFrame.Position.Y + 1, targetPos.Z))
    end)
end

-- "Busy" reel : Action (folder vide quand idle) / UsingSkill (StringValue vide quand idle).
-- Ne JAMAIS bloquer le deplacement la-dessus : la game gere elle-meme les locks d'action.
-- Cache 0.1s : appele a chaque frame, pas la peine de re-scanner plus souvent.
local apBusyCache = { t = 0, v = false }
local function AP_IsBusy(char)
    local now = tick()
    if now - apBusyCache.t < 0.1 then return apBusyCache.v end
    apBusyCache.t = now
    local busy = false
    if char then
        local us = char:FindFirstChild("UsingSkill")
        if us and us:IsA("StringValue") and us.Value ~= "" then
            busy = true
        else
            local act = char:FindFirstChild("Action")
            if act then
                if act:IsA("StringValue") then
                    local v = act.Value:lower()
                    if v ~= "" and v ~= "none" and v ~= "m1" and v ~= "light" then busy = true end
                elseif act:IsA("Folder") and (#act:GetChildren() > 0 or next(act:GetAttributes()) ~= nil) then
                    busy = true
                end
            end
        end
    end
    apBusyCache.v = busy
    return busy
end

local function AP_DoM1(myHRP, target)
    local now = os.clock()
    if now - apLastM1Tick < apM1Gap then return end
    apLastM1Tick = now
    -- Cadence : imitation > slider, + jitter humain (jamais un metronome)
    local st = AP_ImitStats and AP_ImitStats()
    local baseGap
    if st and st.m1Intervals and #st.m1Intervals > 0 then
        baseGap = st.m1Intervals[math.random(1, #st.m1Intervals)]
    else
        baseGap = 0.28
    end
    if State.AutoPlay_Humanize ~= false then
        baseGap = baseGap * (0.85 + math.random() * 0.4)
        if math.random() < 0.04 then baseGap = baseGap + 0.4 + math.random() * 0.5 end
    end
    apM1Gap = baseGap
    local targetHRP = target.RootPart
    if not targetHRP then return end
    AP_AimCamera(targetHRP.Position, myHRP)
    local refs = AP_RefreshRefs()
    local bc = refs.bc
    if bc and bc:FindFirstChild("MouseClick") then
        pcall(function() bc.MouseClick:Fire(true) end)
        task.delay(0.05, function() pcall(function() bc.MouseClick:Fire(false) end) end)
    end
    SendViewportCenterClick(0)
    local inputRemote = refs.inputRemote
        or game:GetService("StarterPack"):FindFirstChild("Input")
        or (refs.char and refs.char:FindFirstChild("Input"))
    if inputRemote then
        -- Cible tres au-dessus/dessous : vise son XZ a MON niveau (les jambes),
        -- sinon le mousehit part 20 studs en l'air et le M1 whiff.
        local aimPoint = targetHRP.Position
        if math.abs(aimPoint.Y - myHRP.Position.Y) > 8 then
            aimPoint = Vector3.new(aimPoint.X, myHRP.Position.Y, aimPoint.Z)
        end
        local aimCF = CFrame.lookAt(myHRP.Position, aimPoint)
        pcall(function()
            inputRemote:FireServer("M1", {
                air = false,
                mousehit = aimCF,
                md = Vector3.zero,
                dodgevelo = false,
                skeydown = false,
                skeyreal = false,
            })
        end)
    end
end

local function AP_CastSkill(slotNum, myHRP, target, extraDelay)
    local now = tick()
    local baseDelay = State.AutoPlay_SkillDelay or 1.2
    if State.AutoPlay_Humanize ~= false then
        baseDelay = baseDelay * (0.8 + math.random() * 0.4)
    end
    if now - (apLastSkillTick[slotNum] or 0) < baseDelay then return false end
    if not AP_IsSkillReady(slotNum) then return false end
    local refs = AP_RefreshRefs()
    local myChar = refs.char
    if not myChar then return false end
    if AP_IsBusy(myChar) then return false end
    if extraDelay and extraDelay > 0 then task.wait(extraDelay) end
    if target and target.RootPart then AP_AimCamera(target.RootPart.Position, myHRP) end
    local bc = refs.bc
    local act = bc and bc:FindFirstChild("Move" .. tostring(slotNum))
    if act then
        apLastSkillTick[slotNum] = now
        pcall(function() act:Fire(true) end)
        task.wait(0.35)
        pcall(function() act:Fire(false) end)
        local key = AP_SLOT_KEYS[slotNum]
        if key then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.06)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end)
        end
        return true
    end
    return false
end

-- Chase : stepping direct du HRP, FLUIDE frame par frame (pas de pas de 0.9 studs
-- toutes les 50ms : c'est ca qui donnait l'impression de bug/tremble). La camera
-- n'est plus touchee pendant le deplacement : elle reste celle du joueur.
-- Le perso joue l'anim Run du jeu pendant l'avance (sinon il glisse sans
-- animation : ca se voit direct que c'est un bot).
local apRunTrack, apRunOwner = nil, nil

local function AP_SetRunAnim(char, hum, moving)
    if not (char and hum) then return end
    if apRunOwner ~= char then
        if apRunTrack then pcall(function() apRunTrack:Stop(0) end) end
        apRunTrack, apRunOwner = nil, char
    end
    local animator = hum:FindFirstChildOfClass("Animator")
    local anims = char:FindFirstChild("Anims")
    local runAnim = anims and anims:FindFirstChild("Run")
    if not (animator and runAnim) then return end
    if moving then
        if not apRunTrack then
            local ok, track = pcall(function() return animator:LoadAnimation(runAnim) end)
            if ok and track then
                apRunTrack = track
                -- Meme priorite que le sprint du jeu (Action) : le rendu est identique.
                pcall(function() apRunTrack.Priority = Enum.AnimationPriority.Action end)
            end
        end
        if apRunTrack and not apRunTrack.IsPlaying then
            pcall(function() apRunTrack:Play(0.15) end)
        end
        if apRunTrack then
            pcall(function()
                apRunTrack:AdjustSpeed(math.clamp((State.AutoPlay_MoveSpeed or 18) / 16, 0.6, 1.8))
            end)
        end
    else
        if apRunTrack and apRunTrack.IsPlaying then
            pcall(function() apRunTrack:Stop(0.15) end)
        end
    end
end

local apLastHopTick = 0
local apLastTargetRefresh = 0
local apProgPos, apProgT = nil, 0
local apFallbackUntil = 0
local apMoveFrameTick = 0
local apMoveConn = RunService.Heartbeat:Connect(function(dt)
    if getgenv().ABA_Unloaded then return end
    -- Anti hyper-fire (certains executors tirent Heartbeat a 1000+/s) :
    -- plafond ~120Hz, invisible a 60 FPS normaux (16.7ms > 8ms).
    local nowF = tick()
    if nowF - apMoveFrameTick < 0.008 then return end
    apMoveFrameTick = nowF
    if not State.AutoPlay then
        apCurrentTarget = nil
        getgenv().ABA_AutoPlayTarget = nil
        AP_ReleaseKeys()
        if apRunTrack then AP_SetRunAnim(apRunOwner, apRunOwner and apRunOwner:FindFirstChildOfClass("Humanoid"), false) end
        return
    end
    local now = tick()
    local refs = AP_RefreshRefs()
    local myChar, myHRP, myHum = refs.char, refs.hrp, refs.hum
    if not myHRP or not myHum or myHum.Health <= 0 then
        AP_ReleaseKeys()
        AP_SetRunAnim(myChar, myHum, false)
        return
    end
    -- Rafraichit la cible 10x/s seulement (le cache ennemis a deja son throttle)
    if now - apLastTargetRefresh > (State.EcoMode and 0.2 or 0.1) then
        apLastTargetRefresh = now
        apCurrentTarget = AP_GetTarget()
    end
    local target = apCurrentTarget
    getgenv().ABA_AutoPlayTarget = target and target.Model or nil
    if not target or not target.RootPart then
        AP_ReleaseKeys()
        AP_SetRunAnim(myChar, myHum, false)
        apStuckPos, apStuckPos2 = nil, nil
        apStuckLevel = 0
        return
    end
    -- LA CIBLE EST TOUJOURS DANS LA VUE : camera braquee chaque frame. C'est ce
    -- qui fait que le CORPS regarde l'ennemi (le jeu tourne le perso vers la
    -- camera quand il bouge/attaque) — le rendu est 100% joueur.
    AP_AimCamera(target.RootPart.Position)
    -- Humanizer : la vitesse du stepping de secours dose comme un joueur
    if State.AutoPlay_Humanize ~= false then
        if now > apHum.speedJitterUntil then
            apHum.speedJitter = 0.88 + math.random() * 0.24
            apHum.speedJitterUntil = now + 0.6 + math.random() * 0.9
        end
    else
        apHum.speedJitter = 1
    end
    -- Distance d'engagement : imitation + bande humaine (+/-1.5 studs par cible)
    local baseEngage = AP_EffectiveAtkR and AP_EffectiveAtkR() or (State.AutoPlay_AttackRange or 9)
    if apHum.engageTarget ~= target.Model then
        apHum.engageTarget = target.Model
        apHum.engageOffset = (State.AutoPlay_Humanize ~= false) and ((math.random() - 0.5) * 3) or 0
    end
    local atkR = math.max(3.5, baseEngage + apHum.engageOffset)
    local dx = target.RootPart.Position.X - myHRP.Position.X
    local dz = target.RootPart.Position.Z - myHRP.Position.Z
    local flat = Vector3.new(dx, 0, dz)
    local flatMag = flat.Magnitude
    local dy = target.RootPart.Position.Y - myHRP.Position.Y
    local vGap = math.abs(dy)
    local wantStep = State.AutoPlay_Chase and flatMag > atkR
    if wantStep and not AP_IsBusy(myChar) then
        local desiredDir = flatMag > 0.5 and flat.Unit or Vector3.new(0, 0, -1)
        -- Micro-pause humaine : lache W une fraction de seconde
        local pausing = false
        if State.AutoPlay_Humanize ~= false then
            if now > apHum.pauseRoll then
                apHum.pauseRoll = now + 1.5 + math.random() * 2
                if math.random() < 0.06 then
                    apHum.pauseUntil = now + 0.12 + math.random() * 0.2
                end
            end
            if now < apHum.pauseUntil then pausing = true end
        end
        if pausing then
            AP_Key("W", false)
            AP_Key("Shift", false)
        else
            -- Mouvement JOUEUR : vraies touches W+Shift, camera deja sur la cible.
            -- Shift tenu en permanence pendant le deplacement (sprint constant).
            AP_Key("W", true)
            AP_Key("Shift", true)
        end
        -- Watchdog : si ca n'avance pas (mur/input bloque), top-up en stepping
        -- CFrame (avec steering par raycasts) pendant 1s puis on redonne la main.
        if not apProgPos then
            apProgPos, apProgT = myHRP.Position, now
        elseif now - apProgT > 1.5 then
            local progressed = (myHRP.Position - apProgPos).Magnitude > 9
            apProgPos, apProgT = myHRP.Position, now
            if not progressed then
                apFallbackUntil = now + 1.0
                AP_Key("W", false)
                task.delay(0.05, function()
                    if State.AutoPlay and apKeys then AP_Key("W", true) end
                end)
            end
        end
        if now < apFallbackUntil then
            if now - apSteer.t > 0.1 then
                apSteer.t = now
                local chosen, blocked = AP_ChooseStepDir(myChar, target.Model, myHRP.Position, desiredDir)
                apSteer.dir = chosen
                apSteer.blocked = blocked
            end
            local moveDir = apSteer.dir or desiredDir
            if flatMag > 0.5 then
                local stepDt = math.min(dt or 0.016, 0.05)
                local speed = (State.AutoPlay_MoveSpeed or 18) * (apHum.speedJitter or 1)
                local step = math.min(speed * stepDt, flatMag)
                pcall(function()
                    local newPos = myHRP.Position + moveDir * step
                    myHRP.CFrame = CFrame.lookAt(newPos, newPos + desiredDir)
                end)
            end
            AP_SetRunAnim(myChar, myHum, true)
        else
            -- Mouvement input : le jeu gere l'anim (Run du sprint), on n'ajoute rien
            AP_SetRunAnim(myChar, myHum, false)
        end
        -- Saut : cible en hauteur (grimper un rebord), ou petit bunny-hop humain
        local doHop = false
        if vGap > 6 and flatMag > atkR + 2 and now - apLastHopTick > 0.7 then
            doHop = true
        elseif State.AutoPlay_Humanize ~= false and now > apHum.hopNext then
            apHum.hopNext = now + 4 + math.random() * 5
            if math.random() < 0.35 and vGap < 4 then doHop = true end
        end
        if doHop then
            apLastHopTick = now
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.delay(0.06, function()
                    pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
                end)
            end)
        end
        -- Escalade anti-stuck : < 3 studs de progres en 2s -> 1) saut + restart
        -- steering 2) recul lateral 3) blacklist de la cible (coin/mur/plateforme)
        if State.AutoPlay_AutoJump then
            if not apStuckPos2 then
                apStuckPos2, apStuckT2, apStuckLevel = myHRP.Position, now, 0
            elseif now - apStuckT2 > 2 then
                local progressed2 = (myHRP.Position - apStuckPos2).Magnitude > 3
                apStuckPos2, apStuckT2 = myHRP.Position, now
                if progressed2 then
                    apStuckLevel = 0
                else
                    apStuckLevel = apStuckLevel + 1
                    if apStuckLevel == 1 then
                        apSteer.t = 0
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                            task.delay(0.06, function()
                                pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
                            end)
                        end)
                    elseif apStuckLevel == 2 then
                        apSteer.t = 0
                        pcall(function() myHRP.CFrame = myHRP.CFrame - desiredDir * 6 end)
                    else
                        AP_BlacklistTarget(target.Model, 12)
                        apCurrentTarget = nil
                        apStuckLevel = 0
                    end
                end
            end
        end
    else
        AP_ReleaseKeys()
        AP_SetRunAnim(myChar, myHum, false)
        apStuckPos, apStuckPos2 = nil, nil
        apStuckLevel = 0
        apProgPos = nil
        -- Strafe de duel avec VRAIES touches A/D (comme un joueur qui tourne
        -- autour de sa cible) + recul occasionnel en S.
        if State.AutoPlay_Chase and flatMag <= atkR + 4 and State.AutoPlay_Humanize ~= false then
            if now > apHum.strafeNext then
                apHum.strafeNext = now + 1.4 + math.random() * 1.6
                apHum.strafeDir = (math.random() < 0.5) and 1 or -1
                apHum.strafeUntil = now + 0.2 + math.random() * 0.35
                apHum.strafeBack = math.random() < 0.2
            end
            if now < apHum.strafeUntil then
                if apHum.strafeBack then
                    AP_Key("S", true)
                else
                    AP_Key(apHum.strafeDir > 0 and "D" or "A", true)
                end
            else
                AP_Key("A", false)
                AP_Key("D", false)
                AP_Key("S", false)
            end
        else
            AP_Key("A", false)
            AP_Key("D", false)
            AP_Key("S", false)
        end
        -- Imitation : rejoue les sauts/dodges que TU faisais au contact
        local st = AP_ImitStats and AP_ImitStats()
        if st and flatMag <= (atkR + 3) and now - apLastImitTicks > 0.5 then
            apLastImitTicks = now
            local hopP = math.clamp((st.hopRate or 0) * 5, 0, 0.7)
            local dodgeP = math.clamp((st.dodgeRate or 0) * 5, 0, 0.7)
            if math.random() < hopP then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.delay(0.06, function()
                        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
                    end)
                end)
            end
            if math.random() < dodgeP then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.delay(0.05, function()
                        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game) end)
                    end)
                end)
            end
        end
    end
end)
table.insert(Connections, apMoveConn)

-- Les touches doivent etre relachees meme si le unload coupe la connexion en plein chase
local apPrevUnload = getgenv().ABA_UnloadFunction
getgenv().ABA_UnloadFunction = function()
    pcall(function() AP_ReleaseKeys() end)
    pcall(function()
        if apRunTrack and apRunTrack.IsPlaying then apRunTrack:Stop(0) end
    end)
    if apPrevUnload then pcall(apPrevUnload) end
end

-- Attaques : M1 + skills + awaken, boucle dediee cadencee
local apAwakenAt = 0
task.spawn(function()
    while not getgenv().ABA_Unloaded do
        task.wait(0.2)
        if not State.AutoPlay then
            apAwakenAt = 0
            continue
        end
        local refs = AP_RefreshRefs()
        local myChar, myHRP, myHum = refs.char, refs.hrp, refs.hum
        if not myHRP or not myHum or myHum.Health <= 0 then continue end
        if AP_IsBusy(myChar) then continue end
        -- Awaken prioritaire : barre pleine -> G, avec un delai humain aleatoire
        if (State.AutoPlay_Awaken or State.AutoAwakening) and not AP_IsAwakened(myChar) and AP_IsAwakenReady() then
            local nowA = tick()
            if apAwakenAt == 0 then
                apAwakenAt = nowA + 0.3 + math.random() * 0.9
            elseif nowA >= apAwakenAt then
                apAwakenAt = 0
                AP_PressAwaken()
                task.wait(0.8)
                continue
            end
        else
            apAwakenAt = 0
        end
        local target = apCurrentTarget or AP_GetTarget()
        if not target or not target.RootPart or not target.Humanoid or target.Humanoid.Health <= 0 then continue end
        -- Distance HORIZONTALE : sur un gros perso/dummy (HRP 20+ studs plus haut),
        -- le 3D dit "trop loin" et le bot ne tapait jamais. Les jambes sont a cote.
        local flatDist = (Vector3.new(target.RootPart.Position.X - myHRP.Position.X, 0, target.RootPart.Position.Z - myHRP.Position.Z)).Magnitude
        local atkR = AP_EffectiveAtkR and AP_EffectiveAtkR() or (State.AutoPlay_AttackRange or 9)
        local sklR = State.AutoPlay_SkillRange or 60
        -- Ligne de vue : pas de M1/skill a travers les murs (aucun joueur ne fait ca)
        local los = AP_HasLOS(myChar, myHRP, target) or flatDist <= 5
        if State.AutoPlay_M1 and flatDist <= atkR + 2 and los then
            AP_DoM1(myHRP, target)
        end
        if State.AutoPlay_Skills and flatDist <= sklR and los
            and not (IsHelplessEnemy and IsHelplessEnemy(myHRP, target)) then
            local st = AP_ImitStats and AP_ImitStats()
            local extraDelay = (State.AutoPlay_Humanize ~= false) and (0.08 + math.random() * 0.17) or nil
            if st and st.skAvgDist then
                -- Imitation : joue le skill dont la distance d'usage enregistree
                -- colle le mieux a la situation actuelle (ton ordre a toi).
                local bestSlot, bestScore = nil, math.huge
                for slot = 1, 4 do
                    local want = (slot == 1 and State.AutoPlay_Skill1)
                        or (slot == 2 and State.AutoPlay_Skill2)
                        or (slot == 3 and State.AutoPlay_Skill3)
                        or (slot == 4 and State.AutoPlay_Skill4)
                    if want and AP_IsSkillReady(slot) then
                        local avgd = st.skAvgDist[slot]
                        local score = avgd and math.abs(avgd - flatDist) or 500
                        if score < bestScore then bestScore, bestSlot = score, slot end
                    end
                end
                if bestSlot then AP_CastSkill(bestSlot, myHRP, target, extraDelay) end
            else
                for slot = 1, 4 do
                    if not State.AutoPlay then break end
                    local want = (slot == 1 and State.AutoPlay_Skill1)
                        or (slot == 2 and State.AutoPlay_Skill2)
                        or (slot == 3 and State.AutoPlay_Skill3)
                        or (slot == 4 and State.AutoPlay_Skill4)
                    if want then
                        local ok = AP_CastSkill(slot, myHRP, target, extraDelay)
                        if ok then break end
                    end
                end
            end
        end
    end
end)

-- =========================================================================
--  IMITATION ENGINE (record TON style -> le bot le rejoue)
--  Enregistre a 10 Hz ce que TU fais en jeu : distance d'engagement, rythme
--  des M1, skills par distance, sauts, dodges, mouvement. Le bot rejoue ces
--  stats a la place des valeurs par defaut quand "Imitate My Style" est ON.
-- =========================================================================
local IMIT_FOLDER = "nwhub_configs/aba"
-- HttpService n'est PAS un global Roblox : le bloc Kyoka a le sien, scope interne.
local HttpService = game:GetService("HttpService")

local ImitationRecorder = {
    Active = false,
    Name = "style1",
    Samples = {},
    Pending = { m1 = 0, sk = 0, j = 0, dg = 0 },
    LastTick = 0,
}
getgenv().ABA_Recorder = ImitationRecorder

local function ImitEnsureFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder("nwhub_configs")) then makefolder("nwhub_configs") end
        if makefolder and not (isfolder and isfolder(IMIT_FOLDER)) then makefolder(IMIT_FOLDER) end
    end)
end

-- Compteurs d'inputs du joueur (consommes a chaque tick d'enregistrement)
local imitInputConn = UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ImitationRecorder.Pending.m1 = ImitationRecorder.Pending.m1 + 1
    elseif input.KeyCode == Enum.KeyCode.One then ImitationRecorder.Pending.sk = 1
    elseif input.KeyCode == Enum.KeyCode.Two then ImitationRecorder.Pending.sk = 2
    elseif input.KeyCode == Enum.KeyCode.Three then ImitationRecorder.Pending.sk = 3
    elseif input.KeyCode == Enum.KeyCode.Four then ImitationRecorder.Pending.sk = 4
    elseif input.KeyCode == Enum.KeyCode.Space then ImitationRecorder.Pending.j = ImitationRecorder.Pending.j + 1
    elseif input.KeyCode == Enum.KeyCode.Q then ImitationRecorder.Pending.dg = ImitationRecorder.Pending.dg + 1
    end
end)
table.insert(Connections, imitInputConn)

local function ImitNearest()
    local best, bd = nil, math.huge
    for _, e in ipairs(GetLiveEnemies()) do
        if e.Distance < bd then bd, best = e.Distance, e end
    end
    return best, bd
end

-- Un echantillon : [dist, ecartY, HP%, HPcible, approche, mt, ms, m1, skill, jump, dodge, block]
local function ImitTakeSample()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    local target = ImitNearest()
    local cam = workspace.CurrentCamera
    local kW = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
    local kS = UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0
    local kA = UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0
    local kD = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
    local moveVec = Vector3.zero
    if cam then
        local look = cam.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z)
        if look.Magnitude > 0.01 then
            look = look.Unit
            local right = look:Cross(Vector3.new(0, 1, 0))
            moveVec = look * (kW - kS) + right * (kD - kA)
        end
    end
    local flatDist, vGap, approach, tgtHP = 999, 0, 0, -1
    local flatDir = nil
    if target and target.RootPart and target.Humanoid then
        local dx = target.RootPart.Position.X - myHRP.Position.X
        local dz = target.RootPart.Position.Z - myHRP.Position.Z
        local flat = Vector3.new(dx, 0, dz)
        flatDist = flat.Magnitude
        vGap = target.RootPart.Position.Y - myHRP.Position.Y
        tgtHP = target.Humanoid.Health
        if flat.Magnitude > 0.5 then flatDir = flat.Unit end
        approach = target.RootPart.AssemblyLinearVelocity:Dot(flatDir or Vector3.zero) / 50
    end
    local mt, ms = 0, 0
    if flatDir and moveVec.Magnitude > 0.1 then
        local toward = flatDir:Dot(moveVec.Unit)
        mt = toward > 0.35 and 1 or (toward < -0.35 and -1 or 0)
        local rightT = flatDir:Cross(Vector3.new(0, 1, 0))
        local side = rightT:Dot(moveVec.Unit)
        ms = side > 0.35 and 1 or (side < -0.35 and -1 or 0)
    end
    local blocking = (myChar:FindFirstChild("Blocking") and myChar.Blocking.Value == true) and 1 or 0
    local p = ImitationRecorder.Pending
    table.insert(ImitationRecorder.Samples, {
        math.floor(flatDist * 10) / 10,
        math.floor(vGap * 10) / 10,
        math.floor((myHum.Health / math.max(myHum.MaxHealth, 1)) * 100),
        math.floor(tgtHP),
        math.floor(approach * 100) / 100,
        mt, ms, p.m1, p.sk, p.j, p.dg, blocking,
    })
    ImitationRecorder.Pending = { m1 = 0, sk = 0, j = 0, dg = 0 }
    if #ImitationRecorder.Samples >= 8000 then
        ImitationRecorder.Active = false
        Vesper:Notify({ Title = "Recorder", Content = "8000 samples reached — recording stopped (remember to Save).", Type = "warning" })
    end
end

local imitRecorderConn = RunService.Heartbeat:Connect(function()
    if not ImitationRecorder.Active then return end
    local now = tick()
    if now - ImitationRecorder.LastTick < 0.1 then return end
    ImitationRecorder.LastTick = now
    pcall(ImitTakeSample)
end)
table.insert(Connections, imitRecorderConn)

function ImitationRecorder:Start(name)
    if name and #tostring(name) > 0 then
        self.Name = tostring(name):gsub("[^%w_%-]", "")
    end
    if State.AutoPlay then
        State.AutoPlay = false
        Vesper:Notify({ Title = "Recorder", Content = "AutoPlay disabled while recording YOUR gameplay (not the bot's).", Type = "info" })
    end
    self.Samples = {}
    self.Pending = { m1 = 0, sk = 0, j = 0, dg = 0 }
    self.LastTick = 0
    self.Active = true
end

function ImitationRecorder:Stop()
    self.Active = false
    return #self.Samples
end

function ImitationRecorder:Save()
    ImitEnsureFolder()
    local path = IMIT_FOLDER .. "/imitation_" .. self.Name .. ".json"
    local json = nil
    pcall(function()
        json = HttpService:JSONEncode({
            name = self.Name,
            count = #self.Samples,
            samples = self.Samples,
        })
    end)
    if not json then return false, path end
    local ok = pcall(function() writefile(path, json) end)
    if not ok then
        -- Certains executors ont besoin d'un instant apres makefolder
        task.wait(0.25)
        ImitEnsureFolder()
        ok = pcall(function() writefile(path, json) end)
    end
    return ok, path
end

local function ImitStatsFromSamples(samples)
    local n = #samples
    local engageSum, engageCount = 0, 0
    local skDists = { {}, {}, {}, {} }
    local m1Ticks = {}
    local hopCount, dodgeCount, moveBias, inRangeCount = 0, 0, 0, 0
    for i, s in ipairs(samples) do
        local d, mt, m1, sk, j, dg = s[1], s[6], s[8], s[9], s[10], s[11]
        if d <= 25 then
            inRangeCount = inRangeCount + 1
            if (m1 and m1 > 0) or (sk and sk >= 1 and sk <= 4) then
                engageSum = engageSum + d
                engageCount = engageCount + 1
            end
            if sk and sk >= 1 and sk <= 4 then
                table.insert(skDists[sk], d)
            end
            if m1 and m1 > 0 then table.insert(m1Ticks, i) end
            if j and j > 0 then hopCount = hopCount + 1 end
            if dg and dg > 0 then dodgeCount = dodgeCount + 1 end
            moveBias = moveBias + (mt or 0)
        end
    end
    -- Rythme des M1 : ecart entre deux ticks qui contiennent un clic
    local m1Intervals = {}
    for k = 2, #m1Ticks do
        local dt = (m1Ticks[k] - m1Ticks[k - 1]) * 0.1
        if dt >= 0.1 and dt <= 3 then table.insert(m1Intervals, dt) end
    end
    local avg = function(t)
        if #t == 0 then return nil end
        local sum = 0
        for _, v in ipairs(t) do sum = sum + v end
        return sum / #t
    end
    return {
        count = n,
        engage = engageCount > 0 and (engageSum / engageCount) or nil,
        m1Intervals = m1Intervals,
        skAvgDist = { avg(skDists[1]), avg(skDists[2]), avg(skDists[3]), avg(skDists[4]) },
        hopRate = inRangeCount > 0 and (hopCount / inRangeCount) or 0,
        dodgeRate = inRangeCount > 0 and (dodgeCount / inRangeCount) or 0,
        moveBias = inRangeCount > 0 and (moveBias / inRangeCount) or 0,
    }
end

function ImitationRecorder:Load(name)
    ImitEnsureFolder()
    local path = IMIT_FOLDER .. "/imitation_" .. tostring(name) .. ".json"
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(decoded) ~= "table" or type(decoded.samples) ~= "table" or #decoded.samples == 0 then
        return false
    end
    self.Samples = decoded.samples
    self.Name = decoded.name or tostring(name)
    local stats = ImitStatsFromSamples(self.Samples)
    getgenv().ABA_ImitateStats = stats
    return true, stats
end

function ImitationRecorder:List()
    ImitEnsureFolder()
    local out = {}
    pcall(function()
        if listfiles and isfolder(IMIT_FOLDER) then
            for _, f in ipairs(listfiles(IMIT_FOLDER)) do
                local nm = f:match("imitation_([^/\\]+)%.json$")
                if nm and not table.find(out, nm) then table.insert(out, nm) end
            end
        end
    end)
    return out
end

-- Lecture par le bot : stats seulement si l'imitation est active
AP_ImitStats = function()
    if State.ImitateEnabled then return getgenv().ABA_ImitateStats end
    return nil
end

AP_EffectiveAtkR = function()
    local st = AP_ImitStats()
    if st and st.engage and st.engage > 3 then
        return math.clamp(st.engage, 4, 20)
    end
    return State.AutoPlay_AttackRange or 9
end
end -- /do AUTO PLAY BOT v2
-- =========================================================================
--  TECH — BLUE SPECTATE + ORB SNAP (Gojo Blue)
--  - 1er appui Blue (confirme) -> spectate IMMEDIAT sur le mec (pas de delai).
--  - Clic pendant le mode -> le rond bleu qui spawn est replace sur la cible.
--  (do ... end : on garde le chunk sous la limite de 200 locals)
-- =========================================================================
do
local TechLock = { lockedName = nil, modeUntil = 0, clickTick = -99, lastScan = 0, slots = {}, firstSeen = {} }

local function TL_PlayerList()
    local out = {}
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LocalPlayer then table.insert(out, p.Name) end
    end
    return out
end

local function TL_LockedPlayer()
    local name = TechLock.lockedName
    if name and name ~= "Nearest" and name ~= "—" then
        local p = game:GetService("Players"):FindFirstChild(name)
        if p and p.Character then return p end
    end
    return nil
end

local function TL_NearestPlayer()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, bd = nil, math.huge
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d < bd then bd, best = d, p end
            end
        end
    end
    return best
end

-- Resout la cible sous forme normalisee { Player?, Model, RootPart, Name }
local function TL_ResolveTarget()
    local locked = TL_LockedPlayer()
    if locked and locked.Character then
        local hrp = locked.Character:FindFirstChild("HumanoidRootPart")
        return { Player = locked, Model = locked.Character, RootPart = hrp, Name = locked.Name }
    end
    local nearP = TL_NearestPlayer()
    if nearP and nearP.Character then
        local hrp = nearP.Character:FindFirstChild("HumanoidRootPart")
        return { Player = nearP, Model = nearP.Character, RootPart = hrp, Name = nearP.Name }
    end
    -- Fallback (serveur vide) : l'ennemi le plus proche (dummies inclus).
    local best, bd = nil, math.huge
    for _, e in ipairs(GetLiveEnemies()) do
        if e.Model and e.RootPart and e.Distance < bd and e.Distance <= (State.AutoPlay_Range or 250) then
            bd = e.Distance
            best = e
        end
    end
    if best then
        return { Player = best.Player, Model = best.Model, RootPart = best.RootPart, Name = best.Model.Name }
    end
    return nil
end

-- Scan Backpack : slot -> nom du move (cache 0.35s)
local function TL_ScanMoves()
    local now = tick()
    if now - TechLock.lastScan < 0.35 then return TechLock.slots end
    TechLock.lastScan = now
    local map = {}
    local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
    if bp then
        local order = 0
        for _, itemObj in ipairs(bp:GetChildren()) do
            if itemObj:IsA("Configuration") then
                order = order + 1
                local cfg = itemObj:FindFirstChild(".Config")
                local n = order
                if cfg then
                    for _, s in ipairs(cfg:GetChildren()) do
                        if s.Name:sub(1, 4) == "Slot" then n = tonumber(s.Name:sub(5)) or n end
                    end
                end
                if n >= 1 and n <= 4 then map[n] = itemObj.Name end
            end
        end
    end
    TechLock.slots = map
    return map
end

local function TL_IsBlue(name)
    if type(name) ~= "string" then return false end
    local low = name:lower()
    return low:find("%f[%a]blue%f[%A]") ~= nil or low:find("blue", 1, true) ~= nil
end

-- Statut affiche dans l'onglet (label mis plus bas par l'UI)
local function TL_SetStatus(t)
    local lbl = getgenv().__TLStatusLabel
    if lbl and lbl.SetText then pcall(function() lbl:SetText("State: " .. t) end) end
end

-- Armement : touche 1-4 sur le slot Blue -> SPECTATE IMMEDIAT (pas de delai).
-- C'est ce qui supprime le delai : on ne passe plus par la sonde WASD.
local tlKeyConn = UserInputService.InputBegan:Connect(function(input)
    if not State.TechBlueTP or getgenv().ABA_Unloaded then return end
    local slot = nil
    if input.KeyCode == Enum.KeyCode.One then slot = 1
    elseif input.KeyCode == Enum.KeyCode.Two then slot = 2
    elseif input.KeyCode == Enum.KeyCode.Three then slot = 3
    elseif input.KeyCode == Enum.KeyCode.Four then slot = 4 end
    if slot then
        local name = TL_ScanMoves()[slot]
        if TL_IsBlue(name) then
            TechLock.modeUntil = math.max(TechLock.modeUntil or 0, tick() + 2)
        end
    end
end)
table.insert(Connections, tlKeyConn)

-- Clic pendant le mode : le rond bleu qui spawn est replace sur la cible.
-- (Le rond bleu apparait quand on clique ; on snap les parts du Thrown creees
-- juste apres le clic et proches de nous.)
local tlClickConn = UserInputService.InputBegan:Connect(function(input, gp)
    if not State.TechBlueTP or getgenv().ABA_Unloaded then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if tick() >= (TechLock.modeUntil or 0) then return end
    TechLock.clickTick = tick()
    local tgt = TL_ResolveTarget()
    TechLock.clickTarget = tgt
end)
table.insert(Connections, tlClickConn)

local tlNext = 0
local tlStatusNext = 0
local tlFrameTick = 0
local tlWatchConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    if not State.TechBlueTP then
        TechLock.modeUntil = 0
        TechLock.spect = false
        TechLock.curTarget = nil
        TL_SetStatus("out of mode")
        return
    end
    local now = tick()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    -- Anti hyper-fire : plafond ~60Hz (snap 0.6s et resolve 10Hz inchanges).
    local nowTl = tick()
    if nowTl - tlFrameTick < 0.016 then return end
    tlFrameTick = nowTl
    -- Cast Blue confirme par le jeu -> prolonge le mode (rond actif)
    local us = myChar:FindFirstChild("UsingSkill")
    local blueActive = us and us:IsA("StringValue") and TL_IsBlue(us.Value)
    if blueActive then
        TechLock.modeUntil = math.max(TechLock.modeUntil or 0, now + 15)
    end
    local inBlueCtx = now < (TechLock.modeUntil or 0)
    -- Freecam detectee ? (le jeu detache la camera du perso en mode Blue)
    local cam = workspace.CurrentCamera
    local freeCam = false
    if cam then
        local subjOk = (cam.CameraSubject == myHum)
        local camD = (cam.CFrame.Position - myHRP.Position).Magnitude
        if (not subjOk) or camD > 30 then
            freeCam = true
        end
    end
    -- Le spectate ne s'enclenche QUE pendant le Blue REELLEMENT en cours
    -- (UsingSkill == Blue confirme par le jeu) + freecam. Un simple dezoom
    -- avec une fenetre residuelle (appui touche sans cast, us vide) ne vole
    -- plus la camera : le gate distance seul ne suffit plus.
    local inSpect = inBlueCtx and blueActive and freeCam
    TechLock.spect = inSpect
    if now > tlStatusNext then
        tlStatusNext = now + 0.5
        if inSpect then
            local ct = TechLock.curTarget
            TL_SetStatus("FREECAM — spectate " .. (ct and tostring(ct.Name) or "?"))
        elseif inBlueCtx then
            TL_SetStatus("mode (waiting for freecam)")
        else
            TL_SetStatus("out of mode")
        end
    end
    if not inSpect then
        TechLock.curTarget = nil
        return
    end
    -- Cible : resolve throttlee (10Hz)
    if now >= tlNext then
        tlNext = now + 0.1
        TechLock.curTarget = TL_ResolveTarget()
    end
    local target = TechLock.curTarget
    if not target then return end
    local tModel = target.Model
    local tHRP = target.RootPart
    local tHum = tModel and tModel:FindFirstChildOfClass("Humanoid")
    if not (tModel and tModel.Parent and tHRP and tHum) or tHum.Health <= 0 then
        TechLock.curTarget = nil
        return
    end
    local aimPos = tHRP.Position
    -- Snap du rond bleu au clic : pendant 0.6s apres le clic, les parts du
    -- Thrown nouvellement creees PRES DE NOUS (le rond vient de nous) sont
    -- replacees sur la cible. On prend aussi les anchored (le serveur les
    -- reecrit vite, mais le client/hitframe les voit a la bonne place).
    if now - (TechLock.clickTick or -99) < 0.6 then
        local thrown = workspace:FindFirstChild("Thrown")
        local myPos = myHRP.Position
        if thrown then
            for _, d in ipairs(thrown:GetDescendants()) do
                if d:IsA("BasePart") then
                    local first = TechLock.firstSeen[d]
                    if not first then
                        first = now
                        TechLock.firstSeen[d] = now
                    end
                    local age = first - (TechLock.clickTick or 0)
                    if age > -0.05 and age < 0.45 then
                        local dist = (d.Position - myPos).Magnitude
                        if dist < 45 then
                            pcall(function()
                                d.CFrame = CFrame.new(aimPos)
                                d.AssemblyLinearVelocity = Vector3.zero
                            end)
                        end
                    end
                end
            end
            -- purge : oublie les parts detruites / vieilles de +5s
            for part, ts in pairs(TechLock.firstSeen) do
                if typeof(part) ~= "Instance" or not part.Parent or now - ts > 5 then
                    TechLock.firstSeen[part] = nil
                end
            end
        end
    end
end)
table.insert(Connections, tlWatchConn)

-- SPECTATE : ecrit APRÈS le script camera du jeu (sinon il ecrase notre write).
-- Camera derriere le joueur pendant le mode Blue (fluide, chaque frame).
pcall(function() RunService:UnbindFromRenderStep("NWABA_BlueSpectate") end)
local tlBindOk = pcall(function()
    RunService:BindToRenderStep("NWABA_BlueSpectate", Enum.RenderPriority.Last.Value + 100, function()
        if getgenv().ABA_Unloaded then return end
        if not State.TechBlueTP then return end
        if not TechLock.spect then return end
        local target = TechLock.curTarget
        if not target then return end
        local tModel = target.Model
        local tHRP = target.RootPart
        if not (tModel and tModel.Parent and tHRP) then return end
        local cam = workspace.CurrentCamera
        if cam then
            local look = tHRP.CFrame.LookVector
            local back = Vector3.new(look.X, 0, look.Z)
            if back.Magnitude < 0.05 then back = Vector3.new(0, 0, 1) end
            back = back.Unit
            local camPos = tHRP.Position - back * 10 + Vector3.new(0, 5, 0)
            pcall(function()
                cam.CFrame = CFrame.lookAt(camPos, tHRP.Position + Vector3.new(0, 2, 0))
            end)
        end
        TechLock.spectWrites = (TechLock.spectWrites or 0) + 1
    end)
end)
getgenv().__TLBindOk = tlBindOk
table.insert(Connections, { Disconnect = function() pcall(function() RunService:UnbindFromRenderStep("NWABA_BlueSpectate") end) end })

getgenv().__TechLock = {
    List = TL_PlayerList,
    SetTarget = function(name) TechLock.lockedName = name end,
    GetTarget = function() return TechLock.lockedName end,
    IsBlue = TL_IsBlue,
    InMode = function() return tick() < (TechLock.modeUntil or 0) end,
    ForceMode = function(secs) TechLock.modeUntil = tick() + (secs or 5) end,
    SpectWrites = function() return TechLock.spectWrites or 0 end,
    ResolveTest = function()
        local ok, res = pcall(TL_ResolveTarget)
        if not ok then return "ERROR: " .. tostring(res) end
        if not res then return "nil" end
        return "ok:" .. tostring(res.Name)
    end,
    CurTarget = function()
        local t = TechLock.curTarget
        return t and tostring(t.Name) or "nil"
    end,
}
end -- /do TECH PLAYER LOCK



-- =========================================================================
--  MOVE AIM & HITBOX EXTENDER ENGINE (Server-Authoritative Mousehit Hijack)
-- =========================================================================
-- ABA fait la détection de hitbox et de portée côté SERVEUR.
-- Le client envoie l'événement réseau "Input" avec mousehit, targ et camdir.
-- On intercepte et réécrit ces arguments pour rediriger les M1 et skills vers l'ennemi.
local InputRemote = LocalPlayer.Backpack:FindFirstChild("Input")
    or game:GetService("StarterPack"):FindFirstChild("Input")

local originalFireServer = nil
if InputRemote and typeof(hookfunction) == "function" then
    originalFireServer = hookfunction(InputRemote.FireServer, function(self, action, data)
        if getgenv().ABA_Unloaded then
            return originalFireServer(self, action, data)
        end
        if type(action) ~= "string" or type(data) ~= "table" then
            return originalFireServer(self, action, data)
        end

        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then
            return originalFireServer(self, action, data)
        end

        if not State.HitboxExtender then
            return originalFireServer(self, action, data)
        end

        -- Recherche de la cible optimale dans la zone d'assistance
        local enemies = GetLiveEnemies()
        local cam = workspace.CurrentCamera
        local bestEnemy, bestScore = nil, math.huge
        local maxRange = State.HitboxSize * 8 + 20  -- Portée dynamique selon slider

        for _, enemy in ipairs(enemies) do
            if enemy.Distance <= maxRange and enemy.RootPart and enemy.Humanoid and enemy.Humanoid.Health > 0 then
                local screenPos, onScreen = cam:WorldToViewportPoint(enemy.RootPart.Position)
                if onScreen then
                    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    local score = screenDist + enemy.Distance * 1.5
                    if score < bestScore then
                        bestScore = score
                        bestEnemy = enemy
                    end
                end
            end
        end

        if bestEnemy and bestEnemy.RootPart then
            local targetCF = CFrame.lookAt(myHRP.Position, bestEnemy.RootPart.Position)
            if action == "M1" then
                data.mousehit = targetCF
                data.air = false
                data.skeydown = true
                data.skeyreal = false
                data.md = Vector3.zero
            elseif action == "UseMove" then
                data.mousehit = targetCF
                data.targ = bestEnemy.Model.Name
                data.teamtarg = bestEnemy.Model.Name
                data.campos = myHRP.Position
                data.camdir = (bestEnemy.RootPart.Position - myHRP.Position).Unit
                data.air = false
                data.neutral = false
                data.running = false
            end
        end

        return originalFireServer(self, action, data)
    end)

    table.insert(Connections, {
        Disconnect = function()
            pcall(function()
                if originalFireServer and typeof(hookfunction) == "function" then
                    hookfunction(InputRemote.FireServer, originalFireServer)
                end
            end)
        end
    })

    print("[NW Hub] Move Aim & Hitbox Extender hooked on input.FireServer")
end

-- =========================================================================
--  COMBO LOCK : pendant un M1 Trade reussi, on avale l'input Block du joueur
--  (~1.2s) pour que son F tenu ne casse pas le combo. Normal le reste du temps.
-- =========================================================================
do
    local bcRef = LocalPlayer.PlayerScripts and LocalPlayer.PlayerScripts:FindFirstChild("BaseContext")
    local blockAction = bcRef and bcRef:FindFirstChild("Block")
    if blockAction and typeof(hookfunction) == "function" then
        local origBlockFire = blockAction.Fire
        pcall(function()
            hookfunction(blockAction.Fire, function(self, v)
                if v and tick() < tradeLockUntil then
                    return -- ignore le block pendant le combo en cours
                end
                return origBlockFire(self, v)
            end)
        end)
        print("[NW Hub] Combo lock hooked on BaseContext.Block")
    end
end

-- 4. STEALTH SPEED BOOST
local speedFrameTick = 0
local speedConn = RunService.Heartbeat:Connect(function(dt)
    if getgenv().ABA_Unloaded then return end
    local curState = GetState()
    if not curState.SpeedBoost then return end
    local nowSp = tick()
    if nowSp - speedFrameTick < 0.008 then return end
    speedFrameTick = nowSp

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    if hum.MoveDirection.Magnitude > 0 then
        local deltaMult = math.clamp(curState.SpeedMultiplier - 1.0, 0.05, 1.0)
        local moveStep = hum.MoveDirection * (hum.WalkSpeed * deltaMult * dt)
        hrp.CFrame = hrp.CFrame + moveStep
    end
end)
table.insert(Connections, speedConn)

-- =========================================================================
--  ESP VISUAL PIPELINE (AUTHENTIC ABA MOVE CARDS & AWAKENING GAUGE)
-- =========================================================================

local function CreateESPForEnemy(target)
    local model = target.Model
    local hrp = target.RootPart
    local hum = target.Humanoid
    local plr = target.Player

    -- Thorough cleanup of previous ESP billboards on this model
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BillboardGui") and (d.Name:find("ABA_ESP") or d.Name:find("ABA_Awaken")) then
            pcall(function() d:Destroy() end)
        end
    end

    -- Highlight for real players (skipped in Eco mode: depth prepass kills mobile GPUs)
    local highlight = nil
    if plr ~= nil and not State.EcoMode then
        highlight = Instance.new("Highlight")
        highlight.Name = "ABA_Highlight"
        highlight.Adornee = model
        highlight.FillColor = Color3.fromRGB(255, 60, 80)
        -- FIX FPS: Highlight = tueur de FPS #1 sur Roblox (re-rendu depth). 0.75 -> 0.9 + DepthMode occluded
        highlight.FillTransparency = 0.9
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.6
        pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.Occluded end)
        highlight.Parent = hrp
    end

    -- Master Overhead Billboard (Pure Square ABA HUD Cards + Awakening Gauge - Zero Black Bar)
    local masterBB = Instance.new("BillboardGui")
    masterBB.Name = "ABA_ESP_MasterBillboard"
    masterBB.Adornee = hrp
    masterBB.Size = UDim2.new(0, 244, 0, 54)
    masterBB.StudsOffset = Vector3.new(0, 4.8, 0)
    -- FIX FPS: AlwaysOnTop=true force le rendu à travers les murs pour 10 billboards = overdraw énorme
    masterBB.AlwaysOnTop = false
    masterBB.MaxDistance = 150

    local cardsRow = Instance.new("Frame")
    cardsRow.Name = "CardsRow"
    cardsRow.Size = UDim2.new(1, 0, 1, 0)
    cardsRow.BackgroundTransparency = 1
    cardsRow.BorderSizePixel = 0
    cardsRow.Parent = masterBB

    -- Vertical Awakening Pill Bar integrated on left (Height matches 54px square cards)
    local pillOuter = Instance.new("Frame")
    pillOuter.Name = "PillOuter"
    pillOuter.Size = UDim2.new(0, 10, 0, 54)
    pillOuter.Position = UDim2.new(0, 0, 0, 0)
    pillOuter.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    pillOuter.BackgroundTransparency = 0.2
    pillOuter.BorderSizePixel = 0
    pillOuter.ClipsDescendants = true
    pillOuter.Parent = cardsRow

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pillOuter

    local pillStroke = Instance.new("UIStroke")
    pillStroke.Color = Color3.fromRGB(0, 0, 0)
    pillStroke.Thickness = 1.5
    pillStroke.Parent = pillOuter

    local pillFill = Instance.new("Frame")
    pillFill.Name = "PillFill"
    pillFill.Size = UDim2.new(1, 0, 0, 0)
    pillFill.Position = UDim2.new(0, 0, 1, 0)
    pillFill.BackgroundColor3 = Color3.fromRGB(225, 30, 40)
    pillFill.BorderSizePixel = 0
    pillFill.Parent = pillOuter

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = pillFill

    -- Cards Container on the right (Contains 4 exact 54x54 square cards)
    local cardsContainer = Instance.new("Frame")
    cardsContainer.Name = "CardsContainer"
    cardsContainer.Size = UDim2.new(0, 228, 0, 54)
    cardsContainer.Position = UDim2.new(0, 15, 0, 0)
    cardsContainer.BackgroundTransparency = 1
    cardsContainer.BorderSizePixel = 0
    cardsContainer.Parent = cardsRow

    local cardsLayout = Instance.new("UIListLayout")
    cardsLayout.FillDirection = Enum.FillDirection.Horizontal
    cardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    cardsLayout.Padding = UDim.new(0, 4)
    cardsLayout.Parent = cardsContainer

    local moveCards = {}
    for slot = 1, 4 do
        -- Pure 54x54 square card identical to ABA in-game HUD
        local card = Instance.new("Frame")
        card.Name = "Slot_" .. slot
        card.Size = UDim2.new(0, 54, 0, 54)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Visible = false
        card.Parent = cardsContainer

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 5)
        cCorner.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(0, 0, 0)
        cStroke.Thickness = 1.5
        cStroke.Parent = card

        -- Vertical gradient identical to ABA HUD (bright top, dark bottom)
        local cGrad = Instance.new("UIGradient")
        cGrad.Rotation = 90
        cGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 120, 205)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 45, 95))
        })
        cGrad.Parent = card

        -- Slot Number (Top-Left, bold with dark outline)
        local num = Instance.new("TextLabel")
        num.Name = "Num"
        num.Size = UDim2.new(0, 15, 0, 15)
        num.Position = UDim2.new(0, 4, 0, 2)
        num.BackgroundTransparency = 1
        num.Text = tostring(slot)
        num.Font = Enum.Font.ArialBold
        num.TextColor3 = Color3.fromRGB(255, 255, 255)
        num.TextStrokeTransparency = 0
        num.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        num.TextScaled = true
        num.ZIndex = 3
        num.Parent = card

        -- Move Name (Centered, SciFi font identical to ABA HUD)
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "MoveName"
        nameLbl.Size = UDim2.new(1, -4, 0.50, 0)
        nameLbl.Position = UDim2.new(0, 2, 0.40, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = ""
        nameLbl.Font = Enum.Font.SciFi
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.TextWrapped = true
        nameLbl.TextScaled = true
        nameLbl.ZIndex = 3
        nameLbl.Parent = card

        -- Guardbreaks Tag (Bottom, italic SciFi font identical to ABA HUD)
        local gbLbl = Instance.new("TextLabel")
        gbLbl.Name = "GBTag"
        gbLbl.Size = UDim2.new(1, -4, 0, 11)
        gbLbl.Position = UDim2.new(0, 2, 1, -12)
        gbLbl.BackgroundTransparency = 1
        gbLbl.Text = "Guardbreaks"
        gbLbl.Font = Enum.Font.SciFi
        gbLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        gbLbl.TextTransparency = 0.35
        gbLbl.TextStrokeTransparency = 0.6
        gbLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        gbLbl.TextScaled = true
        gbLbl.Visible = false
        gbLbl.ZIndex = 3
        gbLbl.Parent = card

        -- CD Overlay Frame
        local cdFrame = Instance.new("Frame")
        cdFrame.Name = "CD"
        cdFrame.Size = UDim2.new(1, 0, 0, 0)
        cdFrame.Position = UDim2.new(0, 0, 1, 0)
        cdFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        cdFrame.BackgroundTransparency = 0.5
        cdFrame.BorderSizePixel = 0
        cdFrame.Visible = false
        cdFrame.ZIndex = 4
        cdFrame.Parent = card

        local cdText = Instance.new("TextLabel")
        cdText.Name = "CDText"
        cdText.Size = UDim2.new(1, 0, 1, 0)
        cdText.BackgroundTransparency = 1
        cdText.Text = ""
        cdText.Font = Enum.Font.GothamBold
        cdText.TextColor3 = Color3.fromRGB(255, 255, 255)
        cdText.TextStrokeTransparency = 0
        cdText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        cdText.TextScaled = true
        cdText.ZIndex = 5
        cdText.Parent = cdFrame

        moveCards[slot] = {
            Card = card,
            Grad = cGrad,
            Stroke = cStroke,
            Num = num,
            NameLbl = nameLbl,
            GBTag = gbLbl,
            CDFrame = cdFrame,
            CDText = cdText
        }
    end

    masterBB.Parent = hrp

    table.insert(ESPItems, {
        Model = model,
        HRP = hrp,
        Humanoid = hum,
        Player = plr,
        Highlight = highlight,
        MasterBillboard = masterBB,
        CardsRow = cardsRow,
        PillOuter = pillOuter,
        PillFill = pillFill,
        MoveCards = moveCards,
    })
end

local lastESPThrottle = 0
-- FIX FPS: RenderStepped -> Heartbeat + 0.08 -> 0.25 (ESP n'a pas besoin de 60Hz, 4Hz suffit)
local espUpdateConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local curState = GetState()

    if not curState.PlayerESP then
        if #ESPItems > 0 then ClearESP() end
        return
    end

    local now = tick()
    if now - lastESPThrottle < (State.EcoMode and 0.5 or 0.25) then return end
    lastESPThrottle = now

    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- Clean stale items
    for i = #ESPItems, 1, -1 do
        local item = ESPItems[i]
        if not item.Model or not item.Model.Parent or not item.Humanoid or item.Humanoid.Health <= 0 then
            if item.Highlight then pcall(function() item.Highlight:Destroy() end) end
            if item.MasterBillboard then pcall(function() item.MasterBillboard:Destroy() end) end
            table.remove(ESPItems, i)
        end
    end

    -- Add missing enemies (Limit to closest 10 targets to maintain smooth 60+ FPS)
    local enemies = GetLiveEnemies()
    local maxCount = math.min(#enemies, State.EcoMode and 6 or 10)
    for i = 1, maxCount do
        local target = enemies[i]
        local found = false
        for _, item in ipairs(ESPItems) do
            if item.Model == target.Model then found = true; break end
        end
        if not found and target.Distance <= 250 then
            CreateESPForEnemy(target)
        end
    end

    -- Update info for all active items
    for _, item in ipairs(ESPItems) do
        local model = item.Model
        local hum = item.Humanoid
        local hrp = item.HRP
        local plr = item.Player or (model and (Players:GetPlayerFromCharacter(model) or Players:FindFirstChild(model.Name)))

        -- Check if model is awakened
        local isAwakened = false
        if model and (model:FindFirstChild("State2") or model:FindFirstChild("SUPERAWAKENWHENEVER") or model:FindFirstChild("MobAwaken") or model:FindFirstChild("Mode")) then
            isAwakened = true
        end

        -- 1. Vertical Awakening Pill Bar Update
        if curState.ShowAwakenBar and item.PillOuter and item.PillFill then
            local chargeVal = 0
            local maxCharge = 325
            local chargeObj = plr and plr:FindFirstChild("Charge")
            if chargeObj and chargeObj:IsA("DoubleConstrainedValue") then
                chargeVal = chargeObj.Value or 0
                maxCharge = (chargeObj.MaxValue and chargeObj.MaxValue > 0) and chargeObj.MaxValue or 325
            end

            local fillRatio = math.clamp(chargeVal / maxCharge, 0, 1)
            if isAwakened then
                fillRatio = 1
                item.PillFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            else
                item.PillFill.BackgroundColor3 = Color3.fromRGB(225, 30, 40)
            end

            item.PillFill.Size = UDim2.new(1, 0, fillRatio, 0)
            item.PillFill.Position = UDim2.new(0, 0, 1 - fillRatio, 0)
            item.PillOuter.Visible = (plr ~= nil or isAwakened or (chargeObj ~= nil))
        elseif item.PillOuter then
            item.PillOuter.Visible = false
        end

        -- 2. Overhead Attack Move Cards Update (Multi-Source with Zero-Spell Auto-Hide)
        local itemDist = (myHRP and hrp) and (hrp.Position - myHRP.Position).Magnitude or 999
        if curState.ShowCooldowns and item.CardsRow and item.MoveCards and itemDist <= 135 then
            local moves = {}

            -- Source 1: Real-time Backpack (live cooldowns & configurations)
            if plr and plr:FindFirstChild("Backpack") then
                local slotIdx = 0
                for _, itemObj in ipairs(plr.Backpack:GetChildren()) do
                    if itemObj:IsA("Configuration") then
                        slotIdx = slotIdx + 1
                        local slotNum = slotIdx
                        local cfg = itemObj:FindFirstChild(".Config")
                        if cfg then
                            for _, s in ipairs(cfg:GetChildren()) do
                                if s.Name:sub(1, 4) == "Slot" then
                                    slotNum = tonumber(s.Name:sub(5)) or slotNum
                                end
                            end
                        end
                        local cd = itemObj:GetAttribute("COOLDOWN")
                        local gb = itemObj:GetAttribute("GUARDBREAKS") or IsMoveGuardbreak(itemObj.Name)
                        if slotNum and slotNum >= 1 and slotNum <= 4 then
                            moves[slotNum] = {
                                Name = itemObj.Name,
                                CD = cd or 20,
                                GB = (gb == true)
                            }
                        end
                    end
                end
            end

            -- Source 2: Character Model Children / Tools
            local moveCount = 0
            for _ in pairs(moves) do moveCount = moveCount + 1 end
            if moveCount < 4 and model then
                for _, itemObj in ipairs(model:GetChildren()) do
                    if itemObj:IsA("Configuration") or itemObj:IsA("Tool") then
                        local n = itemObj.Name
                        if not moves[1] then moves[1] = { Name = n, CD = 20, GB = IsMoveGuardbreak(n) }
                        elseif not moves[2] then moves[2] = { Name = n, CD = 20, GB = IsMoveGuardbreak(n) }
                        elseif not moves[3] then moves[3] = { Name = n, CD = 20, GB = IsMoveGuardbreak(n) }
                        elseif not moves[4] then moves[4] = { Name = n, CD = 20, GB = IsMoveGuardbreak(n) }
                        end
                    end
                end
            end

            -- Source 3: Global Cached ReplicatedStorage.CharMovelists
            moveCount = 0
            for _ in pairs(moves) do moveCount = moveCount + 1 end
            if moveCount == 0 and model then
                local charName = model:GetAttribute("SpawnChar") or model:GetAttribute("LastLoadedChar")
                if charName then
                    local cachedMovelist = GlobalMovelistCache[charName]
                    if cachedMovelist == nil then
                        local cml = game:GetService("ReplicatedStorage"):FindFirstChild("CharMovelists")
                        local mod = cml and (cml:FindFirstChild(charName) or cml:FindFirstChild(charName .. " [Pre-Timeskip]") or cml:FindFirstChild(charName .. " [Timeskip]"))
                        if mod and mod:IsA("ModuleScript") then
                            local s, data = pcall(require, mod)
                            if s and type(data) == "table" then
                                GlobalMovelistCache[charName] = data
                                cachedMovelist = data
                            else
                                GlobalMovelistCache[charName] = false
                            end
                        else
                            GlobalMovelistCache[charName] = false
                        end
                    end

                    if cachedMovelist then
                        local section = isAwakened and (cachedMovelist.Mode or cachedMovelist.Awakening or cachedMovelist.Base) or cachedMovelist.Base
                        if section then
                            for slot = 1, 4 do
                                local mObj = section["Move" .. slot]
                                if mObj and mObj.Name then
                                    moves[slot] = {
                                        Name = mObj.Name,
                                        CD = 20,
                                        GB = (mObj.Tags and (mObj.Tags.Guardbreaks or mObj.Tags.Unblockable)) or IsMoveGuardbreak(mObj.Name)
                                    }
                                end
                            end
                        end
                    end
                end
            end

            -- Display cards ONLY if character has actual moves
            local hasAnyMove = false
            for s = 1, 4 do
                if moves[s] and moves[s].Name and moves[s].Name ~= "" then
                    hasAnyMove = true
                    break
                end
            end

            if hasAnyMove then
                local topColor = isAwakened and Color3.fromRGB(225, 30, 40) or Color3.fromRGB(15, 120, 205)
                local botColor = isAwakened and Color3.fromRGB(80, 10, 15) or Color3.fromRGB(8, 45, 95)
                local strokeColor = isAwakened and Color3.fromRGB(70, 10, 15) or Color3.fromRGB(0, 0, 0)

                for s = 1, 4 do
                    local cData = item.MoveCards[s]
                    local mInfo = moves[s]

                    if mInfo and mInfo.Name and mInfo.Name ~= "" then
                        cData.Grad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, topColor),
                            ColorSequenceKeypoint.new(1, botColor)
                        })
                        cData.Stroke.Color = strokeColor
                        cData.NameLbl.Text = mInfo.Name
                        cData.GBTag.Visible = (mInfo.GB == true)

                        local cdVal = mInfo.CD or 20
                        if cdVal < 20 then
                            local cdRatio = math.clamp(1 - (cdVal / 20), 0, 1)
                            cData.CDFrame.Size = UDim2.new(1, 0, cdRatio, 0)
                            cData.CDFrame.Position = UDim2.new(0, 0, 1 - cdRatio, 0)
                            local remSec = math.max(1, math.floor(20 - cdVal))
                            cData.CDText.Text = string.format("%ds", remSec)
                            cData.CDFrame.Visible = true
                        else
                            cData.CDFrame.Visible = false
                        end
                        cData.Card.Visible = true
                    else
                        cData.Card.Visible = false
                    end
                end
                item.CardsRow.Visible = true
                item.MasterBillboard.Enabled = true
            else
                item.CardsRow.Visible = false
                item.MasterBillboard.Enabled = false
            end
        elseif item.MasterBillboard then
            item.MasterBillboard.Enabled = false
        end
    end
end)
table.insert(Connections, espUpdateConn)

-- =========================================================================
-- =========================================================================
--  PROJECTILE & SKILL AIMLOCK LOGIC
-- =========================================================================
local isHoldingLockKey = false
local autoLockUntil = 0
local currentLockTarget = nil

local function GetBestProjectileTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local cam = Workspace.CurrentCamera
    if not cam then return nil end

    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local enemies = GetLiveEnemies()
    local bestTarget = nil
    local bestScore = math.huge

    local maxRange = State.LockDistance or 150

    for _, enemy in ipairs(enemies) do
        if enemy.Distance <= maxRange and enemy.RootPart and enemy.Humanoid and enemy.Humanoid.Health > 0 then
            local pos, onScreen = cam:WorldToViewportPoint(enemy.RootPart.Position)
            local screenDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
            
            -- Prioritize enemies closer to screen center and closer in distance
            local score = (onScreen and screenDist or (screenDist + 2000)) + (enemy.Distance * 2)
            if score < bestScore then
                bestScore = score
                bestTarget = enemy
            end
        end
    end

    return bestTarget
end

-- Detect skill cast (Keys 1, 2, 3, 4) to automatically lock for 0.45s during skill execution
local skillKeys = {
    [Enum.KeyCode.One] = true,
    [Enum.KeyCode.Two] = true,
    [Enum.KeyCode.Three] = true,
    [Enum.KeyCode.Four] = true,
}

local skillCastConn = UserInputService.InputBegan:Connect(function(input, processed)
    -- Don't trigger if user is typing in chat / text box
    if UserInputService:GetFocusedTextBox() then return end

    local currentLockKey = State.LockHoldKey or Enum.KeyCode.E
    if input.KeyCode == currentLockKey then
        isHoldingLockKey = true
    end

    if State.ProjectileLock and State.LockOnCast and skillKeys[input.KeyCode] then
        autoLockUntil = tick() + 0.50
    end
end)
table.insert(Connections, skillCastConn)

local lockEndConn = UserInputService.InputEnded:Connect(function(input, processed)
    local currentLockKey = State.LockHoldKey or Enum.KeyCode.E
    if input.KeyCode == currentLockKey then
        isHoldingLockKey = false
    end
end)
table.insert(Connections, lockEndConn)

-- Visual Lock Target Marker (Discreet red/amber reticle over locked target)
local lockMarker = Instance.new("Highlight")
lockMarker.Name = "ABA_Vesper_LockMarker"
lockMarker.FillColor = Color3.fromRGB(255, 60, 60)
lockMarker.OutlineColor = Color3.fromRGB(255, 220, 0)
lockMarker.FillTransparency = 0.65
lockMarker.OutlineTransparency = 0.1
lockMarker.Enabled = false
pcall(function() lockMarker.Parent = Workspace end)

-- Update Lock Highlight directly without separate loop
local function UpdateLockMarker(target)
    if target and target.Model and target.Humanoid and target.Humanoid.Health > 0 then
        if lockMarker.Adornee ~= target.Model then
            lockMarker.Adornee = target.Model
        end
        if not State.EcoMode and not lockMarker.Enabled then
            lockMarker.Enabled = true
        end
    else
        if lockMarker.Enabled then
            lockMarker.Enabled = false
            lockMarker.Adornee = nil
        end
    end
end

-- Aimlock: acquisition de cible lente (10Hz, le coûteux) + application caméra rapide (chaque frame, le fluide)
-- Le saccadé venait du Lerp caméra à 20Hz : la rotation DOIT tourner à la fréquence d'affichage.
local lastLockTick = 0
local projApplyTick = 0
local lockAcquireConn = RunService.Heartbeat:Connect(function()
    if getgenv().ABA_Unloaded then return end
    if not State.ProjectileLock then
        currentLockTarget = nil
        UpdateLockMarker(nil)
        return
    end

    local isLockActive = isHoldingLockKey or (tick() < autoLockUntil)
    if not isLockActive then
        currentLockTarget = nil
        UpdateLockMarker(nil)
        return
    end

    local now = tick()
    if now - lastLockTick < (State.EcoMode and 0.2 or 0.1) then return end
    lastLockTick = now

    local target = GetBestProjectileTarget()
    currentLockTarget = target
    UpdateLockMarker(target)
end)
table.insert(Connections, lockAcquireConn)

local projectileLockConn = RunService.RenderStepped:Connect(function()
    if getgenv().ABA_Unloaded then return end
    local target = currentLockTarget
    if not State.ProjectileLock or not target then return end

    local isLockActive = isHoldingLockKey or (tick() < autoLockUntil)
    if not isLockActive then return end
    -- Plafond ~120Hz anti hyper-fire (invisible a 60 FPS) + Eco : 1 frame sur 2.
    local nowPl = tick()
    if nowPl - projApplyTick < 0.008 then return end
    projApplyTick = nowPl
    if State.EcoMode and (math.floor(nowPl * 60) % 2 == 0) then return end

    -- Valide le cache (cible morte/partie entre deux acquisitions)
    local model = target.Model
    local hrp = target.RootPart
    local hum = target.Humanoid
    if not model or not model.Parent or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
        currentLockTarget = nil
        UpdateLockMarker(nil)
        return
    end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    -- Target position calculation (with velocity prediction for moving targets)
    local targetPos = hrp.Position
    if State.LockPredictVelocity and hrp.Velocity.Magnitude > 1 then
        local dist = (hrp.Position - myHRP.Position).Magnitude
        local travelTime = math.clamp(dist / 160, 0.05, 0.35)
        targetPos = targetPos + (hrp.Velocity * travelTime)
    end

    local cam = Workspace.CurrentCamera
    local mode = State.LockMode or "Face and Camera"

    -- 1. Align HumanoidRootPart horizontally towards target (crucial for ABA directional skills)
    if mode == "Face Only" or mode == "Face and Camera" then
        local flatTargetPos = Vector3.new(targetPos.X, myHRP.Position.Y, targetPos.Z)
        if (flatTargetPos - myHRP.Position).Magnitude > 0.5 then
            myHRP.CFrame = CFrame.new(myHRP.Position, flatTargetPos)
        end
    end

    -- 2. Align Camera towards target (crucial for ray-based skills & visual lock)
    if cam and (mode == "Camera Only" or mode == "Face and Camera") then
        local camPos = cam.CFrame.Position
        local targetCFrame = CFrame.new(camPos, targetPos)
        local smoothing = math.clamp(State.LockSmoothing or 0.35, 0.05, 1.0)
        cam.CFrame = cam.CFrame:Lerp(targetCFrame, smoothing)
    end
end)
table.insert(Connections, projectileLockConn)

-- =========================================================================
--  KYŌKA UI VIEWPORT CREATION
-- =========================================================================
local isMobile = Kyoka.Mobile
if isMobile == nil then isMobile = (type(DetectMobile) == "function" and DetectMobile()) or false end
local Window = Kyoka:CreateWindow({
    Title          = "ANIME BATTLE ARENA",
    Subtitle       = "Kyōka Suigetsu [VIP]",
    Game           = "Anime Battle Arena",
    Footer         = "NW HUB · VIP",
    StatusRight    = isMobile and "Tap icon to toggle" or "RCtrl to toggle",
    Tier           = "Lifetime VIP",
    ToggleKey      = Enum.KeyCode.RightControl,
    ToggleButton   = true,
    Blur           = false,
    Splash         = true,
    SplashDuration = 3.2,
    Size           = isMobile and nil or UDim2.fromOffset(720, 480),
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
    }
})

Kyoka:SetWatermark("NW HUB / ABA / FPS {fps} / {ping} / {time}", true)

local CombatTab = Window:AddTab("Combat")
local TradeGroup = CombatTab:AddGroup("M1 Trade & Counter", "Left")

TradeGroup:AddToggle("M1Trade", {
    Text = "M1 Trade (Auto Counter)",
    Default = true,
    Tooltip = "When guarding, automatically unblocks and M1s immediately when an enemy strikes your guard to win the frame trade",
    Callback = function(v) State.M1Trade = v end
})

TradeGroup:AddSlider("M1TradeImpactTiming", {
    Text = "Block Impact Absorption",
    Min = 0.10,
    Max = 0.30,
    Default = 0.16,
    Rounding = 2,
    Suffix = "s",
    Tooltip = "Ensures the enemy hit connects and is fully absorbed by your block before dropping guard",
    Callback = function(v) State.M1TradeImpactTiming = v end
})

TradeGroup:AddSlider("M1TradeReaction", {
    Text = "Post-Impact Counter Delay",
    Min = 0.01,
    Max = 0.10,
    Default = 0.02,
    Rounding = 2,
    Suffix = "s",
    Tooltip = "Micro-delay after absorbing the hit before executing the counter M1",
    Callback = function(v) State.M1TradeReaction = v end
})

TradeGroup:AddToggle("M1TradeAutoFace", {
    Text = "Trade Auto-Face Attacker",
    Default = true,
    Tooltip = "Instantly aligns facing angle towards the attacker to ensure the counter M1 lands",
    Callback = function(v) State.M1TradeAutoFace = v end
})

TradeGroup:AddToggle("CheckFacing", {
    Text = "Only When Attacker Faces",
    Default = true,
    Callback = function(v) State.CheckFacing = v end
})

local HitboxGroup = CombatTab:AddGroup("Move Aim & Hitbox Extender", "Left")

HitboxGroup:AddToggle("HitboxExtender", {
    Text = "Enable Move Aim Extender",
    Default = true,
    Tooltip = "Widens the impact zone and automatically redirects mousehit and targ to the nearest enemy (Chidori, Rasengan, etc.)",
    Callback = function(v) State.HitboxExtender = v end
})

HitboxGroup:AddSlider("HitboxSize", {
    Text = "Aim Assist Range",
    Min = 2,
    Max = 15,
    Default = 8,
    Rounding = 1,
    Suffix = " studs",
    Tooltip = "Max aim-assist range (the script auto-aims at the nearest enemy inside this zone)",
    Callback = function(v) State.HitboxSize = v end
})

local ProjectileGroup = CombatTab:AddGroup("Projectile & Skill Lock", "Right")

ProjectileGroup:AddToggle("ProjectileLock", {
    Text = "Enable Projectile Lock",
    Default = true,
    Tooltip = "Locks facing and camera onto the nearest enemy when firing projectiles / skills",
    Callback = function(v) State.ProjectileLock = v end
})

ProjectileGroup:AddDropdown("LockMode", {
    Text = "Lock Mode",
    Values = { "Face and Camera", "Face Only", "Camera Only" },
    Default = "Face and Camera",
    Tooltip = "Face and Camera: rotates body and camera. Face Only: rotates body only. Camera Only: aim camera only.",
    Callback = function(v) State.LockMode = v end
})

ProjectileGroup:AddToggle("LockOnCast", {
    Text = "Auto-Lock On Skill Cast (1-4)",
    Default = true,
    Tooltip = "Automatically locks onto the target for 0.45s whenever you press 1, 2, 3, or 4",
    Callback = function(v) State.LockOnCast = v end
})

ProjectileGroup:AddKeybind("LockHoldKey", {
    Text = "Hold Lock Key",
    Default = Enum.KeyCode.E,
    Modes = { "Hold", "Toggle" },
    Tooltip = "Hold or toggle key to maintain lock on target",
    Callback = function(active)
        isHoldingLockKey = active
    end,
    Changed = function(v)
        if v and v.Key then
            State.LockHoldKey = v.Key
        end
    end
})

ProjectileGroup:AddSlider("LockDistance", {
    Text = "Lock Range",
    Min = 30,
    Max = 350,
    Default = 150,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Maximum target acquisition distance for projectile aimlock",
    Callback = function(v) State.LockDistance = v end
})

ProjectileGroup:AddToggle("LockPredictVelocity", {
    Text = "Velocity Lead Prediction",
    Default = true,
    Tooltip = "Predicts moving targets trajectory so projectiles hit moving enemies",
    Callback = function(v) State.LockPredictVelocity = v end
})

ProjectileGroup:AddSlider("LockSmoothing", {
    Text = "Camera Smooth Speed",
    Min = 0.1,
    Max = 1.0,
    Default = 0.35,
    Rounding = 2,
    Tooltip = "Smoothing factor for camera tracking (higher = snappier, lower = smoother)",
    Callback = function(v) State.LockSmoothing = v end
})

local CounterGroup = CombatTab:AddGroup("Auto Counter", "Right")

CounterGroup:AddToggle("AutoCounter", {
    Text = "Auto Counter (if character has one)",
    Default = false,
    Tooltip = "Auto-uses your counter move (auto-detected by name, or force a slot) on blockable threats instead of blocking",
    Callback = function(v) State.AutoCounter = v end
})

CounterGroup:AddDropdown("CounterSlot", {
    Text = "Counter Move Slot",
    Values = { "Auto", "Slot 1", "Slot 2", "Slot 3", "Slot 4" },
    Default = "Auto",
    Tooltip = "Auto detects the counter by move name. Force a slot for counters with custom names.",
    Callback = function(v) State.CounterSlot = v end
})

CounterGroup:AddSlider("CounterRange", {
    Text = "Counter Range",
    Min = 6,
    Max = 30,
    Default = 16,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v) State.CounterRange = v end
})

CounterGroup:AddSlider("CounterCooldown", {
    Text = "Counter Cooldown",
    Min = 1,
    Max = 6,
    Default = 2.5,
    Rounding = 1,
    Suffix = "s",
    Callback = function(v) State.CounterCooldown = v end
})

CounterGroup:AddSlider("CounterCatchRange", {
    Text = "Catch Range (fire when attacker closer than)",
    Min = 5,
    Max = 15,
    Default = 9,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Lower = later = more perfect (but riskier). Higher = safer, earlier.",
    Callback = function(v) State.CounterCatchRange = v end
})

CounterGroup:AddSlider("CounterMaxWait", {
    Text = "Max Track Wait",
    Min = 0.1,
    Max = 0.8,
    Default = 0.35,
    Rounding = 2,
    Suffix = "s",
    Tooltip = "If the attacker never closes in, fire anyway after this delay.",
    Callback = function(v) State.CounterMaxWait = v end
})

local EvasiveGroup = CombatTab:AddGroup("Mobility & Evasive Defense", "Right")

EvasiveGroup:AddToggle("AutoDodge", {
    Text = "Threat Auto-Dodge (Q)",
    Default = true,
    Tooltip = "Evades unblockable Guardbreaks with authentic Q dash (blockable attacks are deflected by Auto Block)",
    Callback = function(v) State.AutoDodge = v end
})

EvasiveGroup:AddSlider("DodgeCooldown", {
    Text = "Dodge Cooldown",
    Min = 0.5,
    Max = 3.0,
    Default = 1.5,
    Rounding = 1,
    Suffix = "s",
    Callback = function(v) State.DodgeCooldown = v end
})

EvasiveGroup:AddToggle("IgnoreTeammates", {
    Text = "Ignore Teammates",
    Default = true,
    Tooltip = "Does not trigger parry or attacks on team members",
    Callback = function(v) State.IgnoreTeammates = v end
})

-- =========================================================================
--  AWAKENING TAB
-- =========================================================================
local AttackTab = Window:AddTab("Mode")
local ModeGroup = AttackTab:AddGroup("Awakening Automation", "Left")

ModeGroup:AddToggle("AutoAwakening", {
    Text = "Auto Awakening / Mode (G)",
    Default = false,
    Tooltip = "Automatically presses G when awakening bar is completely charged",
    Callback = function(v) State.AutoAwakening = v end
})

-- =========================================================================
--  ANTI-BAN TAB
-- =========================================================================
local AntiBanTab = Window:AddTab("Anti-Ban")
local SafeguardsGroup = AntiBanTab:AddGroup("Safeguards & Heuristics", "Left")

SafeguardsGroup:AddToggle("AutoQTE", {
    Text = "Anti-Macro QTE Solver",
    Default = true,
    Tooltip = "Solves Kokushibo, Black Flash, and Nanami QTEs with humanized anti-macro jitter",
    Callback = function(v) State.AutoQTE = v end
})

SafeguardsGroup:AddToggle("QTEGate", {
    Text = "QTE: Black Flash Chars Only",
    Default = true,
    Tooltip = "Prevents QTE false positives on other characters (e.g. Vegeta zooming the camera). OFF = old behavior.",
    Callback = function(v) State.QTEGate = v end
})

SafeguardsGroup:AddSlider("BlackFlashDelay", {
    Text = "Black Flash Extra Delay",
    Min = 0,
    Max = 0.3,
    Default = 0.03,
    Rounding = 2,
    Suffix = "s",
    Tooltip = "Extra micro-delay on the window-open click. Raise slightly if clicks still land early.",
    Callback = function(v) State.BlackFlashDelay = v end
})

SafeguardsGroup:AddToggle("StaffDetector", {
    Text = "Staff / Mod Detector",
    Default = true,
    Tooltip = "Monitors Group 3735330 for Rank >= 2 developers and staff",
    Callback = function(v) State.StaffDetector = v end
})

SafeguardsGroup:AddDropdown("StaffAction", {
    Text = "Action on Staff Join",
    Values = { "Notify Only", "Notify & Hop", "Instant Disconnect" },
    Default = "Notify & Hop",
    Callback = function(v) State.StaffAction = v end
})

SafeguardsGroup:AddToggle("AntiCombatTagHop", {
    Text = "Wait For Combat Tag Before Hop",
    Default = true,
    Tooltip = "Prevents combat-logging penalties when hopping servers",
    Callback = function(v) State.AntiCombatTagHop = v end
})

local CombatBypassesGroup = AntiBanTab:AddGroup("Mechanics & Status Bypasses", "Right")

CombatBypassesGroup:AddToggle("NoJumpPenalty", {
    Text = "Anti-Landing Lag (No Jump Slow)",
    Default = true,
    Tooltip = "Eliminates the 0.45s landing penalty for fluid bunnyhopping and movement",
    Callback = function(v) State.NoJumpPenalty = v end
})

CombatBypassesGroup:AddToggle("DodgeWhileSlowed", {
    Text = "Dodge While Slowed",
    Default = true,
    Tooltip = "Enables Q/E dodging even when afflicted by slow debuffs",
    Callback = function(v) State.DodgeWhileSlowed = v end
})

CombatBypassesGroup:AddToggle("AntiConfuse", {
    Text = "Anti-Confuse (Sakanade Counter)",
    Default = true,
    Tooltip = "Prevents controls and moves (1-4) from being reversed by Shinji",
    Callback = function(v) State.AntiConfuse = v end
})

CombatBypassesGroup:AddToggle("AntiGenjutsu", {
    Text = "Sight Immunity (Anti-Genjutsu)",
    Default = true,
    Tooltip = "Evades gaze-based attacks (Tsukuyomi, Kyoka Suigetsu, Petrification)",
    Callback = function(v) State.AntiGenjutsu = v end
})

CombatBypassesGroup:AddToggle("AutoTech", {
    Text = "Auto Air-Recovery / Knockdown Tech",
    Default = true,
    Tooltip = "Recovers immediately mid-air from knockdowns with humanized timing",
    Callback = function(v) State.AutoTech = v end
})

-- =========================================================================
--  VISUALS TAB
-- =========================================================================
local VisualsTab = Window:AddTab("Visuals")
local EspGroup = VisualsTab:AddGroup("Player ESP", "Left")

EspGroup:AddToggle("PlayerESP", {
    Text = "Enable ESP",
    Default = true,
    Callback = function(v)
        State.PlayerESP = v
        if not v then ClearESP() end
    end
})

EspGroup:AddToggle("ShowHealth", {
    Text = "Show Health",
    Default = true,
    Callback = function(v) State.ShowHealth = v end
})

EspGroup:AddToggle("ShowDistance", {
    Text = "Show Distance",
    Default = true,
    Callback = function(v) State.ShowDistance = v end
})

EspGroup:AddToggle("ShowBlocking", {
    Text = "Show Guarding State",
    Default = true,
    Callback = function(v) State.ShowBlocking = v end
})

EspGroup:AddToggle("ShowAwakenBar", {
    Text = "Show Awaken Bar / %",
    Default = true,
    Callback = function(v) State.ShowAwakenBar = v end
})

EspGroup:AddToggle("ShowCooldowns", {
    Text = "Show Attack Cooldowns",
    Default = true,
    Callback = function(v) State.ShowCooldowns = v end
})

local WorldGroup = VisualsTab:AddGroup("World Lighting", "Right")

WorldGroup:AddToggle("Fullbright", {
    Text = "Fullbright (No Shadows)",
    Default = false,
    Callback = function(v)
        State.Fullbright = v
        if not v then
            Lighting.Ambient = origAmbient
            Lighting.Brightness = origBrightness
        end
    end
})

WorldGroup:AddToggle("AntiInvis", {
    Text = "Anti-Invis / True Sight",
    Default = true,
    Tooltip = "Reveals invisible & stealth characters (Sanji stealth, Hidden Mist, etc.)",
    Callback = function(v) State.AntiInvis = v end
})

WorldGroup:AddToggle("AntiBlind", {
    Text = "Anti-Blind / Anti-Flashbang",
    Default = true,
    Tooltip = "Prevents flashbangs and negative saturation screen effects",
    Callback = function(v) State.AntiBlind = v end
})

WorldGroup:AddToggle("AntiScreenShake", {
    Text = "Anti-Screen Shake",
    Default = true,
    Tooltip = "Stops disorienting screen shakes during heavy ultimate attacks",
    Callback = function(v) State.AntiScreenShake = v end
})

-- =========================================================================
--  MOVEMENT TAB
-- =========================================================================
local MoveTab = Window:AddTab("Movement")
local MoveGroup = MoveTab:AddGroup("Stealth Locomotion", "Left")

MoveGroup:AddToggle("SpeedBoost", {
    Text = "Stealth Speed Boost",
    Default = false,
    Tooltip = "Bypasses LocalCharacterScript walkspeed checks via micro-CFrame lerp",
    Callback = function(v) State.SpeedBoost = v end
})

MoveGroup:AddSlider("SpeedMultiplier", {
    Text = "Speed Multiplier",
    Min = 1.0,
    Max = 2.0,
    Default = 1.25,
    Rounding = 2,
    Suffix = "x",
    Callback = function(v) State.SpeedMultiplier = v end
})

MoveGroup:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(v) State.InfiniteJump = v end
})

-- =========================================================================
--  AUTO PLAY TAB (public bot: robot qui joue, awaken inclus)
-- =========================================================================
local AutoPlayTab = Window:AddTab("Auto Play")
local BotGroup = AutoPlayTab:AddGroup("Bot Control", "Left")

BotGroup:AddToggle("AutoPlay", {
    Text = "Enable Auto Play Bot",
    Default = false,
    Tooltip = "The bot plays in public games: chase + M1 + skills 1-4 + awaken G. Keep AutoBlock / AutoDodge ON for defense.",
    Callback = function(v)
        State.AutoPlay = v
        if v then
            Kyoka:Notify({ Title = "Auto Play", Content = "Bot started: it chases, M1s, casts skills and awakens by itself.", Type = "success" })
        end
    end
})

BotGroup:AddToggle("AutoPlay_Chase", {
    Text = "Auto Chase Target",
    Default = true,
    Tooltip = "Moves toward the target (direct stepping, no teleport, no keyboard input)",
    Callback = function(v) State.AutoPlay_Chase = v end
})

BotGroup:AddToggle("AutoPlay_M1", {
    Text = "Auto M1 Combo",
    Default = true,
    Tooltip = "Spams M1 at melee range using the authentic pipeline (click + remote)",
    Callback = function(v) State.AutoPlay_M1 = v end
})

BotGroup:AddToggle("AutoPlay_Skills", {
    Text = "Auto Skills (1-4)",
    Default = true,
    Tooltip = "Casts ready moves via BaseContext Move1-4 when the target is in range",
    Callback = function(v) State.AutoPlay_Skills = v end
})

BotGroup:AddToggle("AutoPlay_Skill1", {
    Text = "Use Skill Slot 1",
    Default = true,
    Callback = function(v) State.AutoPlay_Skill1 = v end
})

BotGroup:AddToggle("AutoPlay_Skill2", {
    Text = "Use Skill Slot 2",
    Default = true,
    Callback = function(v) State.AutoPlay_Skill2 = v end
})

BotGroup:AddToggle("AutoPlay_Skill3", {
    Text = "Use Skill Slot 3",
    Default = true,
    Callback = function(v) State.AutoPlay_Skill3 = v end
})

BotGroup:AddToggle("AutoPlay_Skill4", {
    Text = "Use Skill Slot 4",
    Default = true,
    Callback = function(v) State.AutoPlay_Skill4 = v end
})

BotGroup:AddToggle("AutoPlay_Awaken", {
    Text = "Auto Awaken While Botting (G)",
    Default = true,
    Tooltip = "Presses G as soon as the awaken bar is full, even if the Mode toggle is OFF",
    Callback = function(v) State.AutoPlay_Awaken = v end
})

BotGroup:AddToggle("AutoPlay_AutoJump", {
    Text = "Auto Jump When Stuck",
    Default = true,
    Tooltip = "Auto-jumps when the bot gets stuck (wall, ledge, corner)",
    Callback = function(v) State.AutoPlay_AutoJump = v end
})

BotGroup:AddToggle("AutoPlay_Humanize", {
    Text = "Humanize (anti-bot look)",
    Default = true,
    Tooltip = "Human timings: speed/click jitter, micro-pauses, duel strafes, occasional hops",
    Callback = function(v) State.AutoPlay_Humanize = v end
})

local TargetGroup = AutoPlayTab:AddGroup("Targeting & Timing", "Right")

TargetGroup:AddDropdown("AutoPlay_TargetMode", {
    Text = "Target Priority",
    Values = { "Closest", "Lowest HP", "Players Only" },
    Default = "Closest",
    Tooltip = "Closest: nearest target. Lowest HP: finishes the weak. Players Only: ignores dummies/NPCs.",
    Callback = function(v) State.AutoPlay_TargetMode = v end
})

TargetGroup:AddSlider("AutoPlay_Range", {
    Text = "Engage Range",
    Min = 50,
    Max = 1000,
    Default = 250,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "The bot ignores enemies beyond this distance",
    Callback = function(v) State.AutoPlay_Range = v end
})

TargetGroup:AddSlider("AutoPlay_AttackRange", {
    Text = "M1 Attack Range",
    Min = 5,
    Max = 15,
    Default = 9,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v) State.AutoPlay_AttackRange = v end
})

TargetGroup:AddSlider("AutoPlay_SkillRange", {
    Text = "Skill Cast Range",
    Min = 20,
    Max = 120,
    Default = 60,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(v) State.AutoPlay_SkillRange = v end
})

TargetGroup:AddSlider("AutoPlay_MoveSpeed", {
    Text = "Chase Speed",
    Min = 10,
    Max = 30,
    Default = 18,
    Rounding = 0,
    Suffix = " studs/s",
    Tooltip = "Bot speed toward the target (direct stepping, reliable everywhere)",
    Callback = function(v) State.AutoPlay_MoveSpeed = v end
})

TargetGroup:AddSlider("AutoPlay_SkillDelay", {
    Text = "Delay Between Skills",
    Min = 0.5,
    Max = 5.0,
    Default = 1.2,
    Rounding = 1,
    Suffix = "s",
    Tooltip = "Min delay between two skills so it doesn't dump everything at once",
    Callback = function(v) State.AutoPlay_SkillDelay = v end
})

TargetGroup:AddLabel("Public games only. Keep Auto QTE + Staff Detector ON. Defense = Combat tab.", {})

-- =========================================================================
--  IMITATION GROUP (record ton style -> le bot le rejoue)
-- =========================================================================
local ImitGroup = AutoPlayTab:AddGroup("Imitation — Record My Style", "Left")
local imitStatusLabel = ImitGroup:AddLabel("Recorder: idle", { Color = "TextDim" })

local imitNameBox = { value = "style1" }
ImitGroup:AddTextbox("ImitName", {
    Text = "Recording Name",
    Default = "style1",
    Placeholder = "e.g. ranked, 1v1",
    ClearOnFocus = false,
    Callback = function(v)
        if v and #v > 0 then imitNameBox.value = v:gsub("[^%w_%-]", "") end
    end
})

ImitGroup:AddButton("ImitStartRec", {
    Text = "Start Recording (bot stops)",
    Accent = true,
    Callback = function()
        if getgenv().ABA_Recorder then
            getgenv().ABA_Recorder:Start(imitNameBox.value)
            imitStatusLabel:SetText("Recorder: REC (" .. imitNameBox.value .. ") — play normally")
            pcall(function() imitStatusLabel:SetColor(Kyoka.Theme.Accent) end)
            Kyoka:Notify({ Title = "Recorder", Content = "REC ON — play as usual, the hub is recording your style.", Type = "success" })
        end
    end
})

ImitGroup:AddButton("ImitStopRec", {
    Text = "Stop + Save Recording",
    Callback = function()
        local rec = getgenv().ABA_Recorder
        if not rec then return end
        local n = rec:Stop()
        local ok, path = rec:Save()
        imitStatusLabel:SetText("Recorder: saved " .. tostring(n) .. " samples")
        pcall(function() imitStatusLabel:SetColor(Kyoka.Theme.Success) end)
        if ok then
            Kyoka:Notify({ Title = "Recorder", Content = "Saved " .. tostring(n) .. " samples (" .. tostring(path) .. ")", Type = "success" })
        else
            Kyoka:Notify({ Title = "Recorder", Content = "Save FAILED (fs executor ?)", Type = "error" })
        end
    end
})

local imitDropdown
ImitGroup:AddButton("ImitRefresh", {
    Text = "Refresh Recordings",
    Callback = function()
        local rec = getgenv().ABA_Recorder
        if rec and imitDropdown and imitDropdown.SetValues then
            local list = rec:List()
            if #list == 0 then list = { "—" } end
            imitDropdown:SetValues(list, true)
            Kyoka:Notify({ Title = "Recorder", Content = tostring(#list) .. " recording(s) found", Type = "info" })
        end
    end
})

imitDropdown = ImitGroup:AddDropdown("ImitSelect", {
    Text = "My Recordings",
    Values = (getgenv().ABA_Recorder and getgenv().ABA_Recorder:List()) or { "—" },
    Default = "—",
    Callback = function(v) end
})

ImitGroup:AddButton("ImitLoad", {
    Text = "Load Selected Style",
    Callback = function()
        local rec = getgenv().ABA_Recorder
        local sel = imitDropdown and imitDropdown.Value or nil
        if not rec or not sel or sel == "—" then
            Kyoka:Notify({ Title = "Recorder", Content = "Pick a recording from the list.", Type = "warning" })
            return
        end
        local ok, stats = rec:Load(sel)
        if ok and stats then
            imitStatusLabel:SetText(string.format("Loaded [%s]: %d samples, engage %.1f studs", tostring(sel), stats.count, stats.engage or -1))
            pcall(function() imitStatusLabel:SetColor(Kyoka.Theme.Success) end)
            Kyoka:Notify({
                Title = "Imitation",
                Content = string.format("Style [%s] loaded: %d samples, engage %.1f studs, %d M1 intervals.", tostring(sel), stats.count, stats.engage or -1, #(stats.m1Intervals or {})),
                Type = "success"
            })
        else
            Kyoka:Notify({ Title = "Imitation", Content = "Load FAILED (invalid file?)", Type = "error" })
        end
    end
})

ImitGroup:AddToggle("ImitateEnabled", {
    Text = "Imitate My Style (bot)",
    Default = false,
    Tooltip = "The bot replays your engage distances, M1 cadence, skills by distance, hops/dodges",
    Callback = function(v) State.ImitateEnabled = v end
})

ImitGroup:AddLabel("Tip: turn off AutoPlay, click Start, play 1-2 matches, then Stop+Save.", {})

-- =========================================================================
--  TECH TAB (locks joueur)
-- =========================================================================
do
local TechTab = Window:AddTab("Tech")
local LockGroup = TechTab:AddGroup("Blue Spectate Lock", "Left")

local techDropdown
local function techValues()
    local vals = { "Nearest" }
    if getgenv().__TechLock then
        for _, n in ipairs(getgenv().__TechLock.List()) do table.insert(vals, n) end
    end
    return vals
end

techDropdown = LockGroup:AddDropdown("TechLockTarget", {
    Text = "Locked Player",
    Values = techValues(),
    Default = "Nearest",
    Callback = function(v)
        if getgenv().__TechLock then getgenv().__TechLock.SetTarget(v) end
    end
})

LockGroup:AddButton("TechRefreshPlayers", {
    Text = "Refresh Players",
    Callback = function()
        if techDropdown and techDropdown.SetValues then
            techDropdown:SetValues(techValues(), true)
        end
        Kyoka:Notify({ Title = "Tech", Content = "Player list refreshed.", Type = "info" })
    end
})

LockGroup:AddToggle("TechBlueTP", {
    Text = "Blue Spectate Lock (watch the target)",
    Default = false,
    Tooltip = "Spectates ONLY in real Blue-mode freecam (detected: camera detached from your character). Never a POV on a simple press.",
    Callback = function(v) State.TechBlueTP = v end
})

local techStatusLabel = LockGroup:AddLabel("State: out of mode", { Color = "TextDim" })
getgenv().__TLStatusLabel = techStatusLabel

LockGroup:AddLabel("Pick a player (or Nearest), enable it, cast Blue -> when WASD moves the blow, the view follows the target.", {})

local LockInfo = TechTab:AddGroup("Notes", "Right")
LockInfo:AddLabel("No teleport: this lock only keeps the camera on the target at all times.", {})
LockInfo:AddLabel("Works for any move whose name contains 'Blue'.", {})
LockInfo:AddLabel("Use in combat only.", {})
end

-- =========================================================================
--  SETTINGS TAB
-- =========================================================================
local SettingsTab = Window:AddTab("Settings")
local ConfigGroup = SettingsTab:AddGroup("Configuration Profile", "Left")

ConfigGroup:AddButton("Switch Character", {
    Text = "Switch Character",
    Callback = function()
        Kyoka:Notify({ Title = "Switch Character", Content = "Reloading session to select character...", Type = "info" })
        task.wait(0.5)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

ConfigGroup:AddButton("Unload Script", {
    Text = "Unload Cleanly",
    Callback = function()
        if getgenv().ABA_UnloadFunction then
            getgenv().ABA_UnloadFunction()
        end
    end
})

ConfigGroup:AddDivider()

-- Multi-Profile & Auto-Load Config Manager
local CONFIG_FOLDER = "nwhub_configs/aba"
local AUTOLOAD_FILE = "nwhub_configs/aba/autoload.txt"

local function EnsureConfigFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder("nwhub_configs")) then
            makefolder("nwhub_configs")
        end
        if makefolder and not (isfolder and isfolder(CONFIG_FOLDER)) then
            makefolder(CONFIG_FOLDER)
        end
    end)
end

EnsureConfigFolder()

local function GetConfigList()
    local configs = { "default" }
    pcall(function()
        if listfiles and isfolder and isfolder(CONFIG_FOLDER) then
            for _, f in ipairs(listfiles(CONFIG_FOLDER)) do
                local name = f:match("([^/\\]+)%.json$")
                if name then
                    if not table.find(configs, name) then
                        table.insert(configs, name)
                    end
                end
            end
        end
    end)
    return configs
end

local function GetCurrentAutoLoad()
    local autoName = "none"
    pcall(function()
        if isfile and isfile(AUTOLOAD_FILE) and readfile then
            local str = readfile(AUTOLOAD_FILE)
            if str and #str > 0 then
                autoName = str:gsub("^%s*(.-)%s*$", "%1")
            end
        end
    end)
    return autoName
end

local selectedConfig = "default"
local currentAutoLoadName = GetCurrentAutoLoad()

local autoLoadStatusLabel = ConfigGroup:AddLabel("Auto-Load: " .. (currentAutoLoadName ~= "none" and ("[" .. currentAutoLoadName .. "]") or "Disabled"), {
    Color = (currentAutoLoadName ~= "none") and "Accent" or "TextDim"
})

local configNameInput = "default"
ConfigGroup:AddTextbox("ConfigNameInput", {
    Text = "Profile Name",
    Default = "default",
    Placeholder = "e.g. ranked, 1v1, casual",
    ClearOnFocus = false,
    Callback = function(val)
        if val and #val > 0 then
            configNameInput = val:gsub("[^%w_%-]", "")
        end
    end
})

local configDropdown
configDropdown = ConfigGroup:AddDropdown("SelectedConfigDropdown", {
    Text = "Select Profile",
    Values = GetConfigList(),
    Default = "default",
    Callback = function(val)
        if val then
            selectedConfig = val
        end
    end
})

ConfigGroup:AddButton("Save Profile", {
    Text = "Save Profile",
    Accent = true,
    Callback = function()
        EnsureConfigFolder()
        local targetName = (configNameInput and #configNameInput > 0) and configNameInput or selectedConfig or "default"
        pcall(function()
            if writefile then
                local data = {
                    State = State,
                    UiTheme = {
                        Accent = Kyoka.Theme.Accent and { Kyoka.Theme.Accent.R, Kyoka.Theme.Accent.G, Kyoka.Theme.Accent.B } or nil,
                        Scale = Kyoka.Scale,
                        Effects = Kyoka.Effects,
                    }
                }
                local json = game:GetService("HttpService"):JSONEncode(data)
                writefile(CONFIG_FOLDER .. "/" .. targetName .. ".json", json)
                -- Also save legacy root file if default
                if targetName == "default" then
                    writefile("ABA_Kyoka_Config.json", game:GetService("HttpService"):JSONEncode(State))
                end
                Kyoka:Notify({ Title = "Config Saved", Content = "Saved profile [" .. targetName .. "]", Type = "success" })
                if configDropdown and configDropdown.SetValues then
                    configDropdown:SetValues(GetConfigList(), true)
                    configDropdown:Set(targetName)
                end
            end
        end)
    end
})

ConfigGroup:AddButton("Load Profile", {
    Text = "Load Profile",
    Callback = function()
        local targetName = selectedConfig or configNameInput or "default"
        local filePath = CONFIG_FOLDER .. "/" .. targetName .. ".json"
        local loaded = false
        pcall(function()
            if readfile and isfile then
                local rawData = nil
                if isfile(filePath) then
                    rawData = readfile(filePath)
                elseif targetName == "default" and isfile("ABA_Kyoka_Config.json") then
                    rawData = readfile("ABA_Kyoka_Config.json")
                end
                if rawData then
                    local decoded = game:GetService("HttpService"):JSONDecode(rawData)
                    local stateData = decoded.State or decoded
                    for k, v in pairs(stateData) do
                        State[k] = v
                        local opt = Kyoka.Options and Kyoka.Options[k]
                        if opt and opt.Set then
                            pcall(function() opt:Set(v, true) end)
                        end
                    end
                    -- Les toggles UI (effets Kyoka / watermark) ne passent pas par leur
                    -- callback en mode silent -> application explicite pour qu'ils
                    -- restent sauvegardes (fix "settings qui se reset").
                    if stateData.KyokaEffects ~= nil then
                        pcall(function() Kyoka.Effects = stateData.KyokaEffects and true or false end)
                    end
                    if stateData.ShowWatermark ~= nil then
                        pcall(function() Kyoka:SetWatermarkVisible(stateData.ShowWatermark and true or false) end)
                    end
                    if decoded.UiTheme then
                        if decoded.UiTheme.Scale and Kyoka.SetScale then
                            pcall(function() Kyoka:SetScale(decoded.UiTheme.Scale) end)
                        end
                        if decoded.UiTheme.Accent and Kyoka.SetAccent then
                            pcall(function()
                                local a = decoded.UiTheme.Accent
                                Kyoka:SetAccent(Color3.new(a[1], a[2], a[3]))
                            end)
                        end
                    end
                    loaded = true
                    Kyoka:Notify({ Title = "Config Loaded", Content = "Loaded profile [" .. targetName .. "] successfully!", Type = "success" })
                else
                    Kyoka:Notify({ Title = "Config", Content = "Profile file not found: " .. targetName, Type = "error" })
                end
            end
        end)
    end
})

ConfigGroup:AddButton("Set As Auto-Load", {
    Text = "Set As Auto-Load",
    Callback = function()
        EnsureConfigFolder()
        local targetName = selectedConfig or configNameInput or "default"
        pcall(function()
            if writefile then
                writefile(AUTOLOAD_FILE, targetName)
                currentAutoLoadName = targetName
                if autoLoadStatusLabel and autoLoadStatusLabel.SetText then
                    autoLoadStatusLabel:SetText("Auto-Load: [" .. targetName .. "]")
                    pcall(function() autoLoadStatusLabel:SetColor(Kyoka.Theme.Accent) end)
                end
                Kyoka:Notify({ Title = "Auto-Load Config", Content = "Profile [" .. targetName .. "] set to auto-load on start!", Type = "success" })
            end
        end)
    end
})

ConfigGroup:AddButton("Clear Auto-Load", {
    Text = "Clear Auto-Load",
    Danger = true,
    Callback = function()
        pcall(function()
            if delfile and isfile and isfile(AUTOLOAD_FILE) then
                delfile(AUTOLOAD_FILE)
            elseif writefile then
                writefile(AUTOLOAD_FILE, "")
            end
            currentAutoLoadName = "none"
            if autoLoadStatusLabel and autoLoadStatusLabel.SetText then
                autoLoadStatusLabel:SetText("Auto-Load: Disabled")
                pcall(function() autoLoadStatusLabel:SetColor(Kyoka.Theme.TextDim) end)
            end
            Kyoka:Notify({ Title = "Auto-Load Config", Content = "Auto-load disabled.", Type = "info" })
        end)
    end
})

ConfigGroup:AddButton("Refresh Profiles List", {
    Text = "Refresh Profiles",
    Callback = function()
        if configDropdown and configDropdown.SetValues then
            configDropdown:SetValues(GetConfigList(), true)
            Kyoka:Notify({ Title = "Config Manager", Content = "Refreshed profiles list.", Type = "info" })
        end
    end
})

local InterfaceGroup = SettingsTab:AddGroup("UI Controls", "Right")

InterfaceGroup:AddKeybind("ToggleKey", {
    Text = "Menu Keybind",
    Default = Enum.KeyCode.RightControl,
    Tooltip = "Key to toggle this interface",
    Changed = function(v)
        if v and v.Key then
            Kyoka.ToggleKey = v.Key
            Window:SetStatus(nil, Kyoka.KeyName(v.Key) .. " to toggle")
        end
    end
})

InterfaceGroup:AddToggle("KyokaEffects", {
    Text = "Kyōka Effects (Shatter)",
    Default = true,
    Callback = function(v)
        Kyoka.Effects = v
        State.KyokaEffects = v
    end
})

InterfaceGroup:AddToggle("ShowWatermark", {
    Text = "Watermark",
    Default = true,
    Callback = function(v)
        Kyoka:SetWatermarkVisible(v)
        State.ShowWatermark = v
    end
})

InterfaceGroup:AddToggle("EcoMode", {
    Text = "Eco Mode (weak devices)",
    Default = false,
    Tooltip = "Halves scan rates and disables Highlights. Turn ON on phones / low-end PCs that lag or crash.",
    Callback = function(v) State.EcoMode = v end
})

InterfaceGroup:AddToggle("ShowKeybinds", {
    Text = "Keybinds List",
    Default = false,
    Callback = function(v) Kyoka:SetKeybindListVisible(v) end
})

InterfaceGroup:AddSlider("UiScale", {
    Text = "UI Scale",
    Min = 1.0,
    Max = 2.5,
    Default = 1.8,
    Rounding = 1,
    Suffix = "x",
    Callback = function(v) Kyoka:SetScale(v) end
})

InterfaceGroup:AddToggle("PixelCursor", {
    Text = "Kyōka Cursor",
    Default = true,
    Callback = function(v) Kyoka:SetCursorEnabled(v) end
})

InterfaceGroup:AddColorPicker("AccentColor", {
    Text = "Accent Color",
    Default = Kyoka.Theme.Accent,
    Callback = function(c) Kyoka:SetAccent(c) end
})

-- Startup Auto-Load Execution
task.spawn(function()
    task.wait(0.6)
    pcall(function()
        if isfile and isfile(AUTOLOAD_FILE) and readfile then
            local autoTarget = readfile(AUTOLOAD_FILE):gsub("^%s*(.-)%s*$", "%1")
            if autoTarget and #autoTarget > 0 and autoTarget ~= "none" then
                local path = CONFIG_FOLDER .. "/" .. autoTarget .. ".json"
                local rawData = nil
                if isfile(path) then
                    rawData = readfile(path)
                elseif autoTarget == "default" and isfile("ABA_Kyoka_Config.json") then
                    rawData = readfile("ABA_Kyoka_Config.json")
                end
                if rawData then
                    local decoded = game:GetService("HttpService"):JSONDecode(rawData)
                    local stateData = decoded.State or decoded
                    for k, v in pairs(stateData) do
                        State[k] = v
                        local opt = Kyoka.Options and Kyoka.Options[k]
                        if opt and opt.Set then
                            pcall(function() opt:Set(v, true) end)
                        end
                    end
                    -- Les toggles UI (effets Kyoka / watermark) ne passent pas par leur
                    -- callback en mode silent -> application explicite pour qu'ils
                    -- restent sauvegardes (fix "settings qui se reset").
                    if stateData.KyokaEffects ~= nil then
                        pcall(function() Kyoka.Effects = stateData.KyokaEffects and true or false end)
                    end
                    if stateData.ShowWatermark ~= nil then
                        pcall(function() Kyoka:SetWatermarkVisible(stateData.ShowWatermark and true or false) end)
                    end
                    if decoded.UiTheme then
                        if decoded.UiTheme.Scale and Kyoka.SetScale then
                            pcall(function() Kyoka:SetScale(decoded.UiTheme.Scale) end)
                        end
                        if decoded.UiTheme.Accent and Kyoka.SetAccent then
                            pcall(function()
                                local a = decoded.UiTheme.Accent
                                Kyoka:SetAccent(Color3.new(a[1], a[2], a[3]))
                            end)
                        end
                    end
                    Kyoka:Notify({ Title = "Auto-Load", Content = "Auto-loaded profile [" .. autoTarget .. "]", Type = "success" })
                end
            end
        end
    end)
end)

if not Vesper.SplashActive then
    pcall(function() Window:SetOpen(true, true) end)
end
pcall(function() CombatTab:Select() end)
print("[NW Hub] Anime Battle Arena Kyōka UI Hub loaded successfully!")
pcall(function() getgenv().__NW_ABA_LOADING = false end)
