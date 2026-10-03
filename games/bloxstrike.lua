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
    BLOXSTRIKE VESPER HUB - COMPLETE NATIVE SKIN CHANGER & LOCK EDITION (V3 CACHED)
    Generated with local Vesper UI v1.0.0
]]

local Vesper = (function()

--[[
	Vesper UI  Ã‚Â·  v1.0.0
	Librairie d'interface pour Roblox (Luau) Ã¢â‚¬â€ style "panel dense" :
	rail lateral, onglets, groupes en 2 colonnes, addons en bout de ligne.

	Usage :
		local Vesper = loadstring(game:HttpGet("..."))()       -- executor
		local Vesper = require(path.to.Vesper)                 -- ModuleScript

	Hierarchie :
		Window > Tab (rail gauche) > Page (onglets du haut) > Group (colonne) > Elements
]]

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local GuiService       = game:GetService("GuiService")
local Stats            = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

--=====================================================================
-- Theme
--=====================================================================

local Library = {
	Version     = "1.0.0",
	Flags       = {},   -- flag -> valeur courante
	Options     = {},   -- flag -> objet element (:Set, :Get)
	Connections = {},
	Objects     = {},
	Unloaded    = false,
	Open        = true,
	ToggleKey   = Enum.KeyCode.RightShift,

	Theme = {
		Accent       = Color3.fromRGB(255, 150, 205),
		AccentDim    = Color3.fromRGB(146,  82, 116),
		Background   = Color3.fromRGB(  9,   9,  11),
		Panel        = Color3.fromRGB( 13,  13,  16),
		Panel2       = Color3.fromRGB( 17,  17,  20),
		Element      = Color3.fromRGB( 20,  20,  24),
		ElementHover = Color3.fromRGB( 32,  32,  38),
		Border       = Color3.fromRGB( 64,  64,  72),
		BorderSoft   = Color3.fromRGB( 34,  34,  40),
		Text         = Color3.fromRGB(228, 228, 234),
		TextDim      = Color3.fromRGB(152, 152, 162),
		TextFaint    = Color3.fromRGB( 98,  98, 108),
		Danger       = Color3.fromRGB(235,  85,  95),
		Success      = Color3.fromRGB(120, 220, 160),
	},
}

local Theme = Library.Theme

--=====================================================================
-- Metriques (bureau / tactile)
--=====================================================================

local ScreenGuiSize

local function DetectMobile()
	-- 1. Explicit user/global override
	if getgenv then
		if getgenv().FORCE_MOBILE == true or getgenv().MOBILE == true or getgenv().IS_MOBILE == true then
			return true
		end
		if getgenv().FORCE_DESKTOP == true or getgenv().DESKTOP == true then
			return false
		end
	end
	if _G then
		if _G.FORCE_MOBILE == true or _G.MOBILE == true or _G.IS_MOBILE == true then
			return true
		end
		if _G.FORCE_DESKTOP == true or _G.DESKTOP == true then
			return false
		end
	end

	-- 2. Native Roblox Platform: iOS (iPad & iPhone) and Android (Tablets & Phones)
	local okPlatform, platform = pcall(function() return UserInputService:GetPlatform() end)
	if okPlatform and platform then
		if platform == Enum.Platform.IOS or platform == Enum.Platform.Android then
			return true
		end
	end

	-- 3. Touch device without hardware keyboard
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return true
	end

	-- 4. Touch device without mouse
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return true
	end

	-- 5. Screen / Viewport check for touch devices (covers iPad / Tablets with Magic Keyboard or mouse connected)
	if UserInputService.TouchEnabled then
		local vp = (ScreenGuiSize and ScreenGuiSize()) or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize)
		if vp then
			local petitCote = math.min(vp.X, vp.Y)
			-- iPad Pro 12.9" is 1024, standard iPad/Air is 768-834. Desktop monitors have minimum side >= 1080
			if petitCote > 0 and petitCote <= 1100 then
				return true
			end
		else
			return true
		end
	end

	return false
end

Library.Mobile = false
Library.HasKeyboard = UserInputService.KeyboardEnabled

local M_DESKTOP = {
	Row        = 20,
	RowField   = 22,
	RowSlider  = 31,
	RowGap     = 4,
	Checkbox   = 10,
	Swatch     = 20, SwatchH = 11,
	Field      = 17, FieldW = 132,
	KeybindW   = 54,
	Button     = 22,
	GroupPadT  = 7, GroupPadB = 9, GroupPadX = 9,
	Header     = 17,
	TitleBar   = 25,
	PageTab    = 18,
	Columns    = 2,
	AddonSpace = 86,
	FontMul    = 1.3,
}

local M_TOUCH = {
	Row        = 28,
	RowField   = 30,
	RowSlider  = 40,
	RowGap     = 6,
	Checkbox   = 18,
	Swatch     = 34, SwatchH = 18,
	Field      = 26, FieldW = 150,
	KeybindW   = 70,
	Button     = 30,
	GroupPadT  = 9, GroupPadB = 11, GroupPadX = 10,
	Header     = 22,
	TitleBar   = 32,
	PageTab    = 26,
	Columns    = 1,
	AddonSpace = 140,
	FontMul    = 1.4,
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

local Registry = {}

--=====================================================================
-- Utilitaires
--=====================================================================

local FONT_FAMILY = "rbxasset://fonts/families/PressStart2P.json"
local FONT_SCALE = 0.72
local FONT_SNAP = 8

local function TS(size)
	local s = math.max(5, math.floor((size or 11) * FONT_SCALE * M.FontMul + 0.5))
	if FONT_SNAP > 0 then
		s = math.max(FONT_SNAP, math.floor(s / FONT_SNAP + 0.5) * FONT_SNAP)
	end
	return s
end

local function Font_(weight)
	return Font.new(FONT_FAMILY, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
end

local function New(class, props, children)
	local inst = Instance.new(class)
	local parent = (type(props) == "table" and props.Parent) or nil
	if type(props) == "table" then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				inst[k] = v
			end
		end
	end
	if type(children) == "table" then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	if parent then inst.Parent = parent end
	table.insert(Library.Objects, inst)
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
				if k == key then
					pcall(function() inst[prop] = color end)
				end
			end
		else
			Registry[inst] = nil
		end
	end
end

function Library:SetAccent(color)
	self:SetTheme("Accent", color)
	self:SetTheme("AccentDim", color:Lerp(Color3.new(0, 0, 0), 0.45))
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

local function Corner(radius, parent)
	return nil
end

local function Stroke(parent, key, thickness, transparency)
	local s = New("UIStroke", {
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
	Library:Register(s, { Color = key or "Border" })
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

local function Label(parent, text, size, colorKey, weight)
	local lbl = New("TextLabel", {
		BackgroundTransparency = 1,
		Text = string.upper(text or ""),
		FontFace = Font_(weight or Enum.FontWeight.Medium),
		TextSize = TS(size or 11),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true,
		Size = UDim2.fromScale(1, 1),
		Parent = parent,
	})
	Library:Register(lbl, { TextColor3 = colorKey or "Text" })
	return lbl
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

local ScreenGui = New("ScreenGui", {
	Name = "Vesper_" .. tostring(math.random(1e5, 1e6)),
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
-- Echelle
--=====================================================================

local ScaleTargets = {}

local function AutoScale()
	if Library.Mobile then return 1 end
	local h = ScreenGui.AbsoluteSize.Y
	if h <= 1 then
		local cam = workspace.CurrentCamera
		h = cam and cam.ViewportSize.Y or 720
	end
	if Library.Mobile then
		if h >= 1400 then return 2 end
		return 1
	end
	if h >= 1700 then return 3 end
	if h >= 800 then return 2 end
	return 1
end

Library.Scale = AutoScale()

local function Scalable(parent)
	local s = New("UIScale", { Scale = Library.Scale, Parent = parent })
	table.insert(ScaleTargets, s)
	return s
end

function Library:SetScale(n)
	n = math.max(1, math.floor(n))
	Library.Scale = n
	for _, obj in pairs(ScaleTargets) do
		if obj.Parent then obj.Scale = n end
	end
	if Library.Window and Library.Window.ApplyScale then
		Library.Window:ApplyScale(n)
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
-- Sons
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
				if body and #body > 5000 then
					writefile(SPLASH_FILE, body)
				end
			end
			return customAsset(SPLASH_FILE)
		end)
		if ok and asset then
			return asset
		end
	end
	return fallbackId
end

local SOUND_UI = GetSplashAsset()
Library.GetSplashAsset = GetSplashAsset

Library.Sound = {
	Enabled = true,
	Volume  = 1,
	Splash  = { Id = SOUND_UI, Speed = 1, Voice = false },
}
Library.SoundFailed = nil

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local soundCache = {}
local soundChecked = {}
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
		snd = New("Sound", {
			Name = "Vesper_" .. nom,
			Parent = SoundService,
		})
		soundCache[nom] = snd
	end

	if cfg.Voice then
		if snd.IsPlaying then return end
		local delai = cfg.Cooldown or 0
		local precedent = lastPlayed[nom]
		if precedent and os.clock() - precedent < delai then return end
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
		local ok = pcall(function() ContentProvider:PreloadAsync({ snd }) end)
		task.wait(0.3)
		if not snd.IsLoaded or snd.TimeLength <= 0 then
			Library.SoundFailed = id
			warn(string.format("[Vesper Sound] Audio failed to load: %s (TimeLength: %.2f, IsLoaded: %s, PlaceId: %d). If this is a private asset, Roblox permissions block it in third-party games.", tostring(id), snd.TimeLength, tostring(snd.IsLoaded), game.PlaceId))
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
-- Tooltip
--=====================================================================

local Tooltip = New("Frame", {
	Name = "Tooltip",
	Visible = false,
	AutomaticSize = Enum.AutomaticSize.XY,
	Size = UDim2.fromOffset(0, 0),
	ZIndex = 900,
	Parent = ScreenGui,
})
Library:Register(Tooltip, { BackgroundColor3 = "Background" })
Scalable(Tooltip)
Stroke(Tooltip, "Border")
Padding(Tooltip, 5, 5, 8, 8)

local TooltipText = New("TextLabel", {
	BackgroundTransparency = 1,
	AutomaticSize = Enum.AutomaticSize.XY,
	Size = UDim2.fromOffset(0, 0),
	FontFace = Font_(Enum.FontWeight.Medium),
	TextSize = TS(12),
	Text = "",
	ZIndex = 901,
	Parent = Tooltip,
})
Library:Register(TooltipText, { TextColor3 = "Text" })

function Library:ShowTooltip(text)
	if type(text) ~= "string" or text == "" then return end
	TooltipText.Text = string.upper(text)
	Tooltip.Visible = true
end

function Library:HideTooltip()
	Tooltip.Visible = false
end

Library:Connect(RunService.RenderStepped, function()
	if Tooltip.Visible then
		local x, y = MouseLocal()
		Tooltip.Position = UDim2.fromOffset(x + 14, y + 12)
	end
end)

--=====================================================================
-- Elements (mixin partage par tous les Groups)
--=====================================================================

local Elements = {}

local function CompactRow(group, text, height, tip)
	local row = New("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or M.Row),
		Parent = group.Container,
	})

	local lbl = Label(row, text, 12, "TextDim")
	lbl.Size = UDim2.new(1, -M.AddonSpace, 1, 0)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd

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
	List(right, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)

	if tip then
		local hover = Hit(row, "Tip", 1)
		Library:Connect(hover.MouseEnter, function() Library:ShowTooltip(tip) end)
		Library:Connect(hover.MouseLeave, function() Library:HideTooltip() end)
	end

	return row, lbl, right
end

local function WideRow(group, text, height, tip)
	local row = New("Frame", {
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		Parent = group.Container,
	})

	local head = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Parent = row,
	})

	local lbl = Label(head, text, 12, "TextDim")
	lbl.Size = UDim2.new(1, -M.AddonSpace, 1, 0)
	lbl.TextTruncate = Enum.TextTruncate.AtEnd

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
	List(right, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)

	if tip then
		local hover = Hit(head, "Tip", 1)
		Library:Connect(hover.MouseEnter, function() Library:ShowTooltip(tip) end)
		Library:Connect(hover.MouseLeave, function() Library:HideTooltip() end)
	end

	return row, lbl, right, head
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
-- Toggle
--=====================================================================

local function Checkbox(parent, size)
	local box = New("Frame", {
		Name = "Checkbox",
		Size = UDim2.fromOffset(size or M.Checkbox, size or M.Checkbox),
		Parent = parent,
	})
	Library:Register(box, { BackgroundColor3 = "Element" })
	Corner(4, box)
	local stroke = Stroke(box, "Border")

	local fill = New("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0, 0),
		BorderSizePixel = 0,
		Parent = box,
	})
	Library:Register(fill, { BackgroundColor3 = "Accent" })

	local function set(on, instant)
		local dur = instant and 0 or 0.12
		Tween(fill, dur, { Size = on and UDim2.new(1, -4, 1, -4) or UDim2.fromScale(0, 0) },
			Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Tween(stroke, dur, { Color = on and Theme.Accent or Theme.Border })
	end

	return box, set
end

function Elements:AddToggle(flag, opts)
	opts = opts or {}
	local text = opts.Text or opts.Name or flag
	local row, lbl, addons = CompactRow(self, text, M.Row)

	local box, setVisual = Checkbox(row)
	box.AnchorPoint = Vector2.new(0, 0.5)
	box.Position = UDim2.new(0, 0, 0.5, 0)
	local textX = M.Checkbox + 7
	lbl.Position = UDim2.fromOffset(textX, 0)
	lbl.Size = UDim2.new(1, -textX - M.AddonSpace, 1, 0)
	local obj = Bind({}, flag, opts.Default == true)
	obj.Callback = opts.Callback
	obj.Label = lbl
	obj.Row = row

	local hovering = false
	local function refresh(fire, instant)
		setVisual(obj.Value, instant)
		Tween(lbl, 0.14, { TextColor3 = obj.Value and Theme.Text or (hovering and Theme.Text or Theme.TextDim) })
		if flag then Library.Flags[flag] = obj.Value end
		if fire and obj.Callback then
			task.spawn(obj.Callback, obj.Value)
		end
	end

	function obj:Set(value, silent)
		obj.Value = value and true or false
		refresh(not silent)
	end
	function obj:Get() return obj.Value end
	function obj:SetText(t) lbl.Text = t end

	local hit = Hit(row, "Toggle", 6)
	Library:Connect(hit.MouseButton1Click, function()
		obj:Set(not obj.Value)
	end)
	Library:Connect(hit.MouseEnter, function()
		hovering = true
		Tween(lbl, 0.12, { TextColor3 = Theme.Text })
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function()
		hovering = false
		Tween(lbl, 0.12, { TextColor3 = obj.Value and Theme.Text or Theme.TextDim })
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
		Library:HideTooltip()
	end)

	refresh(false, true)
	if opts.Default and opts.Callback then task.spawn(opts.Callback, true) end

	return Addonable(obj, addons)
end

MiniToggle = function(holder, flag, opts)
	local box, setVisual = Checkbox(holder, M.Checkbox)
	local obj = Bind({}, flag, opts.Default == true)
	obj.Callback = opts.Callback

	function obj:Set(value, silent)
		obj.Value = value and true or false
		setVisual(obj.Value)
		if flag then Library.Flags[flag] = obj.Value end
		if not silent and obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end
	function obj:Get() return obj.Value end

	local hit = Hit(box, "MiniToggle", 8)
	Library:Connect(hit.MouseButton1Click, function() obj:Set(not obj.Value) end)
	Library:Connect(hit.MouseEnter, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
		Library:HideTooltip()
	end)

	setVisual(obj.Value, true)
	return obj
end

--=====================================================================
-- Interrupteur (pill)
--=====================================================================

local function Switch(parent, default, callback)
	local track = New("Frame", {
		Name = "Switch",
		Size = UDim2.fromOffset(28, 15),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Parent = parent,
	})
	Library:Register(track, { BackgroundColor3 = "Element" })
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	local stroke = Stroke(track, "Border")

	local knob = New("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(11, 11),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(170, 170, 185),
		Parent = track,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	local state = default == true
	local function apply(instant)
		local dur = instant and 0 or 0.18
		Tween(track, dur, { BackgroundColor3 = state and Theme.Accent or Theme.Element })
		Tween(stroke, dur, { Transparency = state and 1 or 0 })
		Tween(knob, dur, {
			Position = state and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			AnchorPoint = state and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
			BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 185),
		}, Enum.EasingStyle.Back)
	end

	local hit = Hit(track, "SwitchHit", 8)
	Library:Connect(hit.MouseButton1Click, function()
		state = not state
		apply()
		if callback then task.spawn(callback, state) end
	end)

	apply(true)

	return {
		Get = function() return state end,
		Set = function(_, v, silent)
			state = v and true or false
			apply()
			if not silent and callback then task.spawn(callback, state) end
		end,
	}
end

--=====================================================================
-- Button
--=====================================================================

function Elements:AddButton(text, opts)
	opts = opts or {}
	if type(text) == "table" then opts = text; text = opts.Text end
	local callback = opts.Callback

	local holder = New("Frame", {
		Name = "ButtonRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, M.Button),
		Parent = self.Container,
	})

	local btn = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		Parent = holder,
	})
	Library:Register(btn, { BackgroundColor3 = "Element" })
	Corner(5, btn)
	Stroke(btn, "Border")

	local lbl = Label(btn, text or "Button", 12, "Text", Enum.FontWeight.SemiBold)
	lbl.TextXAlignment = Enum.TextXAlignment.Center

	if opts.Accent then
		Library:Register(btn, { BackgroundColor3 = "Accent" })
		lbl.TextColor3 = Color3.new(1, 1, 1)
	end

	local hit = Hit(btn, "ButtonHit", 6)
	Library:Connect(hit.MouseEnter, function()
		Tween(btn, 0.12, { BackgroundColor3 = opts.Accent and Theme.Accent:Lerp(Color3.new(1,1,1), 0.12) or Theme.ElementHover })
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function()
		Tween(btn, 0.12, { BackgroundColor3 = opts.Accent and Theme.Accent or Theme.Element })
		Library:HideTooltip()
	end)
	Library:Connect(hit.MouseButton1Down, function()
		Tween(btn, 0.08, { Size = UDim2.new(1, -4, 1, -2), Position = UDim2.fromOffset(2, 1) })
	end)
	Library:Connect(hit.MouseButton1Up, function()
		Tween(btn, 0.16, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
	end)
	local function fireBtn()
		if callback then task.spawn(callback) end
	end
	Library:Connect(hit.MouseButton1Click, fireBtn)
	pcall(function() Library:Connect(hit.Activated, fireBtn) end)

	local obj = { Instance = btn }
	function obj:SetText(t) lbl.Text = t end
	return obj
end

--=====================================================================
-- Label / Paragraph / Divider
--=====================================================================

function Elements:AddLabel(text, opts)
	opts = opts or {}
	local holder = New("Frame", {
		Name = "LabelRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = opts.Wrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
		Parent = self.Container,
	})
	local lbl = Label(holder, text, opts.Size or 12, opts.Color or "TextDim")
	if opts.Wrap then
		lbl.TextWrapped = true
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.Size = UDim2.new(1, 0, 0, 0)
		lbl.TextYAlignment = Enum.TextYAlignment.Top
	end
	if opts.Center then lbl.TextXAlignment = Enum.TextXAlignment.Center end

	local obj = {}
	function obj:SetText(t) lbl.Text = string.upper(t or "") end
	function obj:SetColor(c) lbl.TextColor3 = c end
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
	List(holder, 3, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local t = Label(holder, title, 12, "Text", Enum.FontWeight.SemiBold)
	t.Size = UDim2.new(1, 0, 0, 15)

	local b = Label(holder, body, 11, "TextFaint")
	b.TextWrapped = true
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.Size = UDim2.new(1, 0, 0, 0)
	b.TextYAlignment = Enum.TextYAlignment.Top

	local obj = {}
	function obj:SetTitle(v) t.Text = v end
	function obj:SetBody(v) b.Text = v end
	return obj
end

function Elements:AddDivider()
	local holder = New("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 7),
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

	local row, lbl, addons = WideRow(self, text, M.RowSlider, opts.Tooltip)

	local valueLabel = Label(addons, "", 12, "Text", Enum.FontWeight.SemiBold)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.AutomaticSize = Enum.AutomaticSize.X
	valueLabel.Size = UDim2.new(0, 0, 1, 0)
	valueLabel.LayoutOrder = -1

	local track = New("Frame", {
		Name = "Track",
		Size = UDim2.new(1, 0, 0, 9),
		Position = UDim2.new(0, 0, 1, -9),
		Parent = row,
	})
	Library:Register(track, { BackgroundColor3 = "Element" })
	Stroke(track, "Border")

	local fill = New("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BorderSizePixel = 0,
		Parent = track,
	})
	Library:Register(fill, { BackgroundColor3 = "Accent" })
	New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(202, 202, 202)),
		}),
		Rotation = 90,
		Parent = fill,
	})

	local obj = Bind({}, flag, default)
	obj.Callback = opts.Callback

	local function paint(instant)
		local alpha = (max - min) == 0 and 0 or (obj.Value - min) / (max - min)
		local dur = instant and 0 or 0.09
		Tween(fill, dur, { Size = UDim2.fromScale(alpha, 1) })
		valueLabel.Text = tostring(Round(obj.Value, rounding)) .. suffix
	end

	function obj:Set(value, silent)
		value = math.clamp(Round(value, rounding), min, max)
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
		local alpha = math.clamp((mx - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * alpha)
	end

	local hit = Hit(track, "SliderHit", 6)
	hit.Size = UDim2.new(1, 0, 1, 12)
	hit.Position = UDim2.fromOffset(0, -6)

	Library:Connect(hit.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromMouse(input)
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
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
	end)
	Library:Connect(hit.MouseLeave, function()
		Tween(lbl, 0.12, { TextColor3 = Theme.TextDim })
	end)

	paint(true)
	if opts.Callback and opts.FireOnStart then task.spawn(opts.Callback, obj.Value) end

	return Addonable(obj, addons)
end

--=====================================================================
-- Popups (dropdown, color picker)
--=====================================================================

local function PointInside(gui, point)
	local p, s = gui.AbsolutePosition, gui.AbsoluteSize
	return point.X >= p.X and point.X <= p.X + s.X and point.Y >= p.Y and point.Y <= p.Y + s.Y
end

local function MakePopup(anchorGui, width, height)
	local popup = New("Frame", {
		Name = "Popup",
		Size = UDim2.fromOffset(width, height),
		Visible = false,
		ZIndex = 510,
		ClipsDescendants = true,
		Parent = PopupLayer,
	})
	Library:Register(popup, { BackgroundColor3 = "Panel2" })
	Scalable(popup)
	Stroke(popup, "Border")

	local scale = New("UIScale", { Scale = 1, Parent = popup })
	local followConn

	local function reposition()
		local origin = PopupLayer.AbsolutePosition
		local ap, as = anchorGui.AbsolutePosition, anchorGui.AbsoluteSize
		local vp = ScreenGui.AbsoluteSize
		local scale = Library.Scale
		local w = width * scale
		local h = popup.Size.Y.Offset * scale
		local x = math.clamp(ap.X - origin.X, 6, math.max(vp.X - w - 6, 6))
		local y = ap.Y - origin.Y + as.Y + 5
		if y + h > vp.Y - 6 then
			y = math.max(ap.Y - origin.Y - h - 5, 6)
		end
		popup.Position = UDim2.fromOffset(x, y)
	end

	local isOpen = false
	local closeFn

	local function close()
		if not isOpen then return end
		isOpen = false
		if followConn then followConn:Disconnect(); followConn = nil end
		Tween(popup, 0.12, { BackgroundTransparency = 1 })
		Tween(scale, 0.12, { Scale = 0.96 })
		task.delay(0.13, function()
			if not isOpen then popup.Visible = false end
		end)
		if ActivePopup == closeFn then ActivePopup = nil end
	end
	closeFn = close

	local function open()
		CloseActivePopup()
		isOpen = true
		reposition()
		popup.Visible = true
		popup.BackgroundTransparency = 1
		scale.Scale = 0.96
		Tween(popup, 0.14, { BackgroundTransparency = 0 })
		Tween(scale, 0.16, { Scale = 1 }, Enum.EasingStyle.Back)
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

local function FieldBox(parent, width, height)
	local box = New("Frame", {
		Name = "Field",
		Size = UDim2.fromOffset(width, height or 20),
		Parent = parent,
	})
	Library:Register(box, { BackgroundColor3 = "Element" })
	Corner(4, box)
	Stroke(box, "Border")
	return box
end

--=====================================================================
-- Dropdown
--=====================================================================

function Elements:AddDropdown(flag, opts)
	opts = opts or {}
	local text     = opts.Text or opts.Name or flag
	local values   = opts.Values or opts.Options or {}
	local multi    = opts.Multi == true
	local maxShow  = opts.MaxVisible or 6
	local placeholder = opts.Placeholder or "---"

	local row, lbl, addons = CompactRow(self, text, M.RowField, opts.Tooltip)
	local box = FieldBox(addons, opts.Width or M.FieldW, M.Field)

	local display = Label(box, "", 11, "TextFaint")
	display.Position = UDim2.fromOffset(7, 0)
	display.Size = UDim2.new(1, -24, 1, 0)
	display.TextTruncate = Enum.TextTruncate.AtEnd

	local chev = New("TextLabel", {
		BackgroundTransparency = 1,
		Text = "v",
		FontFace = Font_(Enum.FontWeight.Bold),
		TextSize = TS(9),
		Size = UDim2.new(0, 14, 1, 0),
		Position = UDim2.new(1, -15, 0, 0),
		Parent = box,
	})
	Library:Register(chev, { TextColor3 = "TextFaint" })

	local default = multi and (opts.Default or {}) or opts.Default
	local obj = Bind({}, flag, default)
	obj.Callback = opts.Callback
	obj.Values = values

	local popupHeight = math.min(#values, maxShow) * 22 + 8
	local popup, open, close, toggle, isOpen = MakePopup(box, opts.Width or 132, math.max(popupHeight, 30))

	local scroller = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Border,
		ZIndex = 511,
		Parent = popup,
	})
	Padding(scroller, 4, 4, 4, 4)
	List(scroller, 1, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

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
			local list = {}
			for _, v in ipairs(obj.Value) do table.insert(list, tostring(v)) end
			txt = #list > 0 and table.concat(list, ", ") or placeholder
		else
			txt = obj.Value ~= nil and tostring(obj.Value) or placeholder
		end
		display.Text = string.upper(txt)
		local empty = (txt == placeholder)
		Tween(display, 0.12, { TextColor3 = empty and Theme.TextFaint or Theme.Text })

		for value, entry in pairs(optionButtons) do
			local on = isSelected(value)
			Tween(entry.Label, 0.12, { TextColor3 = on and Theme.Accent or Theme.TextDim })
			Tween(entry.Bar, 0.14, { Size = on and UDim2.new(0, 2, 1, -6) or UDim2.new(0, 2, 0, 0) })
		end
	end

	local function fire()
		if flag then Library.Flags[flag] = obj.Value end
		if obj.Callback then task.spawn(obj.Callback, obj.Value) end
	end

	local function buildOptions()
		for _, entry in pairs(optionButtons) do entry.Frame:Destroy() end
		table.clear(optionButtons)

		for i, value in ipairs(obj.Values) do
			local item = New("Frame", {
				Name = "Option",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 21),
				LayoutOrder = i,
				ZIndex = 512,
				Parent = scroller,
			})
			Library:Register(item, { BackgroundColor3 = "ElementHover" })
			Corner(4, item)

			local bar = New("Frame", {
				Size = UDim2.new(0, 2, 0, 0),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BorderSizePixel = 0,
				ZIndex = 513,
				Parent = item,
			})
			Library:Register(bar, { BackgroundColor3 = "Accent" })
			Corner(2, bar)

			local ol = Label(item, tostring(value), 11, "TextDim")
			ol.Position = UDim2.fromOffset(9, 0)
			ol.Size = UDim2.new(1, -14, 1, 0)
			ol.ZIndex = 513

			local hit = Hit(item, "OptionHit", 514)
			Library:Connect(hit.MouseEnter, function()
				Tween(item, 0.1, { BackgroundTransparency = 0.55 })
			end)
			Library:Connect(hit.MouseLeave, function()
				Tween(item, 0.1, { BackgroundTransparency = 1 })
			end)
			Library:Connect(hit.MouseButton1Click, function()
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
				end
				refreshDisplay()
				fire()
			end)

			optionButtons[value] = { Frame = item, Label = ol, Bar = bar }
		end

		popup.Size = UDim2.fromOffset(opts.Width or 132, math.max(math.min(#obj.Values, maxShow) * 22 + 8, 30))
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

	local hit = Hit(box, "DropdownHit", 8)
	Library:Connect(hit.MouseButton1Click, function()
		toggle()
		Tween(chev, 0.16, { Rotation = isOpen() and 180 or 0 })
	end)
	Library:Connect(hit.MouseEnter, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
	end)
	Library:Connect(hit.MouseLeave, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
	end)

	buildOptions()
	refreshDisplay()

	return Addonable(obj, addons)
end

--=====================================================================
-- Textbox
--=====================================================================

function Elements:AddTextbox(flag, opts)
	opts = opts or {}
	local text = opts.Text or opts.Name or flag
	local row, lbl, addons = CompactRow(self, text, M.RowField, opts.Tooltip)
	local box = FieldBox(addons, opts.Width or M.FieldW, M.Field)

	local input = New("TextBox", {
		BackgroundTransparency = 1,
		Text = opts.Default or "",
		PlaceholderText = opts.Placeholder or "...",
		FontFace = Font_(Enum.FontWeight.Medium),
		TextSize = TS(11),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = opts.ClearOnFocus == true,
		Size = UDim2.new(1, -14, 1, 0),
		Position = UDim2.fromOffset(7, 0),
		ClipsDescendants = true,
		ZIndex = 6,
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
	end)
	Library:Connect(input.Focused, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
	end)
	Library:Connect(input.FocusLost, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
	end)

	return Addonable(obj, addons)
end

--=====================================================================
-- Keybind
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

	local box = FieldBox(parent, opts.Width or M.KeybindW, withLabel and M.Field or (M.Field - 2))
	local display = Label(box, "", 10, "TextDim", Enum.FontWeight.SemiBold)
	display.TextXAlignment = Enum.TextXAlignment.Center

	local obj = Bind({}, flag, {
		Key = opts.Default,
		Mode = opts.Mode or modes[1],
	})
	obj.Callback = opts.Callback
	obj.Changed = opts.Changed
	obj.Modes = modes
	obj.Active = false

	local listening = false

	local function paint()
		display.Text = listening and "[ ... ]" or ("[" .. string.upper(KeyName(obj.Value.Key)) .. "]")
		Tween(display, 0.12, {
			TextColor3 = listening and Theme.Accent or (obj.Value.Key and Theme.Text or Theme.TextFaint),
		})
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
		if obj.Value.Mode == "Toggle" then return obj.Active end
		return obj.Active
	end

	local hit = Hit(box, "KeybindHit", 8)
	Library:Connect(hit.MouseButton1Click, function()
		if not UserInputService.KeyboardEnabled then
			Library:Notify({
				Title = opts.Text or opts.Name or "Shortcut",
				Content = "Pas de clavier sur cet appareil.",
				Duration = 2,
			})
			return
		end
		listening = true
		paint()
	end)
	Library:Connect(hit.MouseButton2Click, function()
		local idx = table.find(modes, obj.Value.Mode) or 1
		local nextMode = modes[(idx % #modes) + 1]
		obj:Set({ Key = obj.Value.Key, Mode = nextMode })
		Library:Notify({
			Title = opts.Text or flag or "Keybind",
			Content = "Mode : " .. nextMode,
			Duration = 2,
		})
	end)
	Library:Connect(hit.MouseEnter, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
		Library:ShowTooltip(opts.Tooltip or "Clic gauche : assigner  Ã‚Â·  Clic droit : mode")
	end)
	Library:Connect(hit.MouseLeave, function()
		Tween(box, 0.12, { BackgroundColor3 = Theme.Element })
		Library:HideTooltip()
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
				if (typeof(key) == "EnumItem" and key == Enum.KeyCode.Backspace) then
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
	local row, lbl, addons = CompactRow(self, opts.Text or opts.Name or flag, M.RowField, opts.Tooltip)
	local obj = BuildKeybind(addons, flag, opts, true)
	return Addonable(obj, addons)
end

MiniKeybind = function(holder, flag, opts)
	return BuildKeybind(holder, flag, opts, false)
end

--=====================================================================
-- Color picker
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

local function BuildColorPicker(parent, flag, opts, height)
	opts = opts or {}
	local useAlpha = opts.Alpha == true

	local swatch = New("Frame", {
		Name = "Swatch",
		Size = UDim2.fromOffset(opts.Width or M.Swatch, height or M.SwatchH),
		BackgroundColor3 = opts.Default or Theme.Accent,
		Parent = parent,
	})
	Corner(3, swatch)
	Stroke(swatch, "Border")

	local obj = Bind({}, flag, opts.Default or Theme.Accent)
	obj.Alpha = opts.DefaultAlpha or 1
	obj.Callback = opts.Callback

	local h, s, v = Color3.toHSV(obj.Value)

	local W, SVH = 160, 108
	local popH = 8 + SVH + 8 + (useAlpha and 20 or 0) + 22 + 8
	local popup, open, close, toggle = MakePopup(swatch, W + 16, popH)

	local body = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 511,
		Parent = popup,
	})
	Padding(body, 8, 8, 8, 8)
	List(body, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local topRow = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, SVH),
		LayoutOrder = 1,
		ZIndex = 511,
		Parent = body,
	})

	local sv = New("Frame", {
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 512,
		Parent = topRow,
	})
	Corner(4, sv)

	local whiteLayer = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 513,
		Parent = sv,
	})
	Corner(4, whiteLayer)
	New("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = whiteLayer,
	})

	local blackLayer = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 514,
		Parent = sv,
	})
	Corner(4, blackLayer)
	New("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = blackLayer,
	})

	local svCursor = New("Frame", {
		Size = UDim2.fromOffset(9, 9),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 516,
		Parent = sv,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
	New("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Parent = svCursor })

	local hue = New("Frame", {
		Size = UDim2.new(0, 12, 1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 512,
		Parent = topRow,
	})
	Corner(4, hue)
	New("UIGradient", { Color = RAINBOW, Rotation = 90, Parent = hue })

	local hueCursor = New("Frame", {
		Size = UDim2.new(1, 4, 0, 3),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 515,
		Parent = hue,
	})
	Corner(2, hueCursor)

	local alphaBar, alphaCursor
	if useAlpha then
		alphaBar = New("Frame", {
			Size = UDim2.new(1, 0, 0, 12),
			LayoutOrder = 2,
			BackgroundColor3 = Color3.fromRGB(20, 20, 26),
			BorderSizePixel = 0,
			ZIndex = 512,
			Parent = body,
		})
		Corner(3, alphaBar)
		local grad = New("UIGradient", {
			Color = ColorSequence.new(obj.Value),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Parent = alphaBar,
		})
		alphaCursor = New("Frame", {
			Size = UDim2.new(0, 3, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 513,
			Parent = alphaBar,
		})
		Corner(2, alphaCursor)
		obj._alphaGradient = grad
	end

	local hexBox = New("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 3,
		ZIndex = 512,
		Parent = body,
	})
	Library:Register(hexBox, { BackgroundColor3 = "Element" })
	Corner(4, hexBox)
	Stroke(hexBox, "Border")

	local hexInput = New("TextBox", {
		BackgroundTransparency = 1,
		Text = "#FFFFFF",
		FontFace = Font_(Enum.FontWeight.Medium),
		TextSize = TS(11),
		Size = UDim2.new(1, -14, 1, 0),
		Position = UDim2.fromOffset(7, 0),
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
		if obj._alphaGradient then
			obj._alphaGradient.Color = ColorSequence.new(obj.Value)
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
		if alpha then obj.Alpha = math.clamp(alpha, 0, 1) end
		apply(silent)
	end
	function obj:Get() return obj.Value, obj.Alpha end

	local function bindDrag(gui, onMove)
		local dragging = false
		local hit = Hit(gui, "PickHit", 520)
		Library:Connect(hit.InputBegan, function(input)
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

	local hit = Hit(swatch, "SwatchHit", 8)
	Library:Connect(hit.MouseButton1Click, toggle)
	Library:Connect(hit.MouseEnter, function()
		if opts.Tooltip then Library:ShowTooltip(opts.Tooltip) end
	end)
	Library:Connect(hit.MouseLeave, function() Library:HideTooltip() end)

	apply(true)
	return obj
end

function Elements:AddColorPicker(flag, opts)
	opts = opts or {}
	local row, lbl, addons = CompactRow(self, opts.Text or opts.Name or flag, M.RowField, opts.Tooltip)
	local obj = BuildColorPicker(addons, flag, opts, M.SwatchH)
	return Addonable(obj, addons)
end

MiniColorPicker = function(holder, flag, opts)
	return BuildColorPicker(holder, flag, opts, M.SwatchH)
end

--=====================================================================
-- Group
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
		Parent = column,
	})
	Library:Register(frame, { BackgroundColor3 = "Panel" })
	Stroke(frame, "Border")

	List(frame, 0, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local header = New("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, M.Header),
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Parent = frame,
	})
	Library:Register(header, { BackgroundColor3 = "Accent" })

	New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 206, 206)),
		}),
		Rotation = 90,
		Parent = header,
	})

	local titleLabel = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = string.upper(title or "GROUP"),
		FontFace = Font_(Enum.FontWeight.Bold),
		TextSize = TS(11),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = Color3.fromRGB(14, 14, 18),
		Parent = header,
	})

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
	}, Group)

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

		local box = New("Frame", {
			Size = UDim2.fromOffset(M.Checkbox - 1, M.Checkbox - 1),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -5, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(14, 14, 18),
			BackgroundTransparency = 1,
			Parent = header,
		})
		New("UIStroke", { Thickness = 1, Color = Color3.fromRGB(14, 14, 18), Parent = box })

		local state = opts.Toggle == true
		local function paint(instant)
			local dur = instant and 0 or 0.12
			Tween(box, dur, { BackgroundTransparency = state and 0 or 1 })
			veil.Active = not state
			if state then
				Tween(veil, dur, { BackgroundTransparency = 1 })
				task.delay(dur + 0.02, function()
					if veil.Active == false then veil.Visible = false end
				end)
			else
				veil.Visible = true
				Tween(veil, dur, { BackgroundTransparency = 0.55 })
			end
		end

		local hit = Hit(header, "GroupToggle", 8)
		Library:Connect(hit.MouseButton1Click, function()
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

	function self:SetTitle(t) titleLabel.Text = string.upper(t) end
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

--=====================================================================
-- Tab
--=====================================================================

local Tab = {}
Tab.__index = Tab

function Tab:AddPage(name)
	local button = New("TextButton", {
		Name = "PageTab",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, M.PageTab),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = self.PageRow,
	})
	Padding(button, 0, 0, 8, 8)

	local btnLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Text = string.upper(name),
		FontFace = Font_(Enum.FontWeight.Medium),
		TextSize = TS(11),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = button,
	})
	Library:Register(btnLabel, { TextColor3 = "TextFaint" })

	local content = New("Frame", {
		Name = "Page_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self.PagesHolder,
	})

	local single = M.Columns == 1
	local function column(x)
		local col = New("ScrollingFrame", {
			Name = x == 0 and "Left" or "Right",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = single and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -4, 1, 0),
			Position = single and UDim2.new() or UDim2.new(x, x == 0 and 0 or 4, 0, 0),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Border,
			ScrollBarImageTransparency = 0.2,
			Parent = content,
		})
		List(col, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
		Padding(col, 0, 8, 0, 3)
		return col
	end

	local left = column(0)

	local page = setmetatable({
		Name = name,
		Content = content,
		Left = left,
		Right = single and left or column(0.5),
		Button = button,
		Label = btnLabel,
		Tab = self,
	}, Page)

	local function select()
		for _, other in ipairs(self.Pages) do
			other.Content.Visible = false
			Tween(other.Label, 0.12, { TextColor3 = Theme.TextFaint })
		end
		content.Visible = true
		Tween(btnLabel, 0.12, { TextColor3 = Theme.Accent })
		self.ActivePage = page
	end
	page.Select = select

	Library:Connect(button.MouseButton1Click, select)
	Library:Connect(button.MouseEnter, function()
		if self.ActivePage ~= page then Tween(btnLabel, 0.1, { TextColor3 = Theme.TextDim }) end
	end)
	Library:Connect(button.MouseLeave, function()
		if self.ActivePage ~= page then Tween(btnLabel, 0.1, { TextColor3 = Theme.TextFaint }) end
	end)

	table.insert(self.Pages, page)

	local many = #self.Pages > 1
	self.PageRow.Visible = many
	local rowH = M.PageTab + 6
	self.PagesHolder.Position = UDim2.fromOffset(0, many and rowH or 0)
	self.PagesHolder.Size = UDim2.new(1, 0, 1, many and -rowH or 0)

	if #self.Pages == 1 then
		task.defer(select)
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

--=====================================================================
-- Window
--=====================================================================

local Window = {}
Window.__index = Window

function Library:CreateWindow(opts)
	opts = opts or {}
	if opts.Accent then Library:SetAccent(opts.Accent) end
	if opts.ToggleKey then Library.ToggleKey = opts.ToggleKey end

	-- Ecran de chargement 3D automatique avec son au lancement
	if opts.Splash ~= false and not Library.SplashActive and not Library.CurrentSplash then
		local splashTitle = opts.Title or "NW HUB"
		local splashSub = opts.Subtitle or "INITIALIZING"
		Library:Splash({
			Title = splashTitle,
			Subtitle = splashSub,
			Steps = {
				"INITIALIZING ENGINE...",
				"CHECKING INTEGRITY...",
				"LOADING MODULES...",
				"READY"
			},
			Duration = opts.SplashDuration or 3.5,
			MinDuration = opts.MinDuration or 3.2,
			AutoFinish = true,
		})
	end

	if opts.Mobile ~= nil then
		ApplyMetrics(opts.Mobile)
	else
		ApplyMetrics(DetectMobile())
	end

	if opts.Scale then Library:SetScale(opts.Scale) end

	local size = opts.Size
	if not size or Library.Mobile then
		if Library.Mobile then
			local vp = ScreenGui.AbsoluteSize
			if vp.X <= 1 or vp.Y <= 1 then
				local cam = workspace.CurrentCamera
				vp = cam and cam.ViewportSize or Vector2.new(800, 600)
			end
			local sc = Library.Scale or 1
			local topBand = 38
			size = UDim2.fromOffset(
				math.max(260, math.floor((vp.X - 24) / sc)),
				math.max(180, math.floor((vp.Y - 24 - topBand) / sc)))
			opts.Position = opts.Position or UDim2.new(0.5, 0, 0.5, math.floor(topBand / 2))
		else
			size = UDim2.fromOffset(660, 430)
		end
	end

	local root = New("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = opts.Position or UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})

	local uiScale = Library.Scale
	local animScale = 1
	local windowScale = New("UIScale", { Scale = uiScale, Parent = root })

	if Library.Mobile then
		local topBand = 38
		local function fitToScreen()
			local vp = ScreenGui.AbsoluteSize
			if vp.X <= 1 or vp.Y <= 1 then
				local cam = workspace.CurrentCamera
				vp = cam and cam.ViewportSize or Vector2.new(800, 600)
			end
			local sc = Library.Scale or 1
			root.Size = UDim2.fromOffset(
				math.max(260, math.floor((vp.X - 24) / sc)),
				math.max(180, math.floor((vp.Y - 24 - topBand) / sc)))
			root.Position = UDim2.new(0.5, 0, 0.5, math.floor(topBand / 2))
		end
		fitToScreen()
		Library:Connect(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"), fitToScreen)
	end
	local function applyScale()
		windowScale.Scale = uiScale * animScale
	end

	New("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.35,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Size = UDim2.new(1, 70, 1, 70),
		Position = UDim2.fromOffset(-35, -31),
		ZIndex = 0,
		Parent = root,
	})

	local panel = New("Frame", {
		Name = "Panel",
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = root,
	})
	Library:Register(panel, { BackgroundColor3 = "Background" })
	local panelStroke = Stroke(panel, "Border")

	local inner = New("Frame", {
		Name = "Inner",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		Parent = panel,
	})
	Stroke(inner, "BorderSoft")

	local titleBar = New("Frame", {
		Name = "TitleBar",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 0, M.TitleBar),
		Parent = inner,
	})

	local titleLine = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0,
		Parent = titleBar,
	})
	Library:Register(titleLine, { BackgroundColor3 = "BorderSoft" })

	local brandText = string.upper(opts.Title or "VESPER")
	if not Library.Mobile and opts.Subtitle then
		brandText = brandText .. "  <font color='#6A6A72'>- " .. string.upper(opts.Subtitle) .. "</font>"
	end

	local brandW = 90
	local brand = New("TextLabel", {
		Name = "Brand",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(0, brandW, 1, 0),
		Text = brandText,
		RichText = true,
		FontFace = Font_(Enum.FontWeight.Bold),
		TextSize = TS(11),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = titleBar,
	})
	Library:Register(brand, { TextColor3 = "Text" })

	local tabsLeftOffset = brandW + 12
	local btnAreaW = Library.Mobile and 70 or 46
	local tabsWrap = New("ScrollingFrame", {
		Name = "TabsWrap",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(tabsLeftOffset, 0),
		Size = UDim2.new(1, -tabsLeftOffset - btnAreaW, 1, 0),
		CanvasSize = UDim2.new(0, 0, 1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollBarThickness = 0,
		ClipsDescendants = true,
		ScrollingDirection = Enum.ScrollingDirection.X,
		Parent = titleBar,
	})

	local tabsRow = New("Frame", {
		Name = "TabsRow",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = tabsWrap,
	})
	List(tabsRow, 0, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

	local btnSize = Library.Mobile and 24 or 14
	local unloadBtn = New("TextButton", {
		Name = "Unload",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, Library.Mobile and -32 or -24, 0.5, 0),
		Size = UDim2.fromOffset(btnSize, btnSize),
		Parent = titleBar,
	})
	local unloadIcon = New("Frame", {
		Name = "Icon",
		Size = UDim2.fromOffset(Library.Mobile and 9 or 7, Library.Mobile and 9 or 7),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Danger or Color3.fromRGB(235, 85, 95),
		BorderSizePixel = 0,
		Parent = unloadBtn,
	})
	Corner(2, unloadIcon)

	local closeBtn = New("TextButton", {
		Name = "Close",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.fromOffset(btnSize, btnSize),
		Parent = titleBar,
	})
	local closeBars = {}
	for i = 1, 2 do
		local barX = New("Frame", {
			Size = UDim2.new(0, Library.Mobile and 12 or 9, 0, Library.Mobile and 2 or 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = i == 1 and 45 or -45,
			BorderSizePixel = 0,
			Parent = closeBtn,
		})
		Library:Register(barX, { BackgroundColor3 = "TextFaint" })
		table.insert(closeBars, barX)
	end

	local contentHolder = New("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(9, M.TitleBar + 9),
		Size = UDim2.new(1, -18, 1, -(M.TitleBar + 9) - 22),
		Parent = inner,
	})

	local footer = New("TextLabel", {
		Name = "Footer",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 9, 1, -17),
		Size = UDim2.new(1, -18, 0, 14),
		Text = string.upper(opts.Footer or ""),
		FontFace = Font_(Enum.FontWeight.Medium),
		TextSize = TS(10),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = inner,
	})
	Library:Register(footer, { TextColor3 = "TextFaint" })

	local footerRight = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 9, 1, -17),
		Size = UDim2.new(1, -18, 0, 14),
		Text = string.upper(opts.StatusRight or opts.Status or ""),
		FontFace = Font_(Enum.FontWeight.Medium),
		TextSize = TS(10),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = inner,
	})
	Library:Register(footerRight, { TextColor3 = "TextFaint" })

	local grip = New("TextButton", {
		Name = "Grip",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 20,
		Parent = panel,
	})
	for i = 1, 3 do
		local d = New("Frame", {
			Size = UDim2.fromOffset(1, 1),
			Position = UDim2.fromOffset(10 - (i - 1) * 3, 10),
			BorderSizePixel = 0,
			ZIndex = 21,
			Parent = grip,
		})
		Library:Register(d, { BackgroundColor3 = "TextFaint" })
	end

	local self = setmetatable({
		Root = root,
		Content = contentHolder,
		TabsRow = tabsRow,
		TabIndicator = tabIndicator,
		Tabs = {},
		ActiveTab = nil,
	}, Window)
	Library.Window = self

	function self:ApplyScale(n)
		uiScale = math.max(1, math.floor(n))
		applyScale()
	end

	function self:SetStatus(left, right)
		if left then footer.Text = string.upper(left) end
		if right then footerRight.Text = string.upper(right) end
	end
	function self:SetFooter(t) footer.Text = string.upper(t) end

	local dragging, dragStart, startPos = false, nil, nil
	Library:Connect(titleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = InputPos(input)
			startPos = root.Position
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = InputPos(input) - dragStart
			root.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local resizing, resizeStart, startSize = false, nil, nil
	Library:Connect(grip.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = InputPos(input)
			startSize = root.AbsoluteSize
		end
	end)
	Library:Connect(UserInputService.InputChanged, function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = InputPos(input) - resizeStart
			root.Size = UDim2.fromOffset(
				math.clamp((startSize.X + delta.X) / uiScale, 380, 1400),
				math.clamp((startSize.Y + delta.Y) / uiScale, 240, 900))
		end
	end)
	Library:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)

	local function OpenEffect()
		local bande = New("Frame", {
			Name = "Sweep",
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 0, -4),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			ZIndex = 60,
			Parent = panel,
		})
		Tween(bande, 0.3, {
			Position = UDim2.new(0, 0, 1, 4),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quad)
		task.delay(0.36, function() bande:Destroy() end)

		panelStroke.Color = Theme.Accent
		Tween(panelStroke, 0.4, { Color = Theme.Border })
	end

	function self:SetOpen(state, instant)
		local etaitOuvert = Library.Open
		Library.Open = state
		CloseActivePopup()
		if not instant and state ~= etaitOuvert and state then
			OpenEffect()
		end
		if self.ToggleButton then
			if Library.Mobile then
				self.ToggleButton.Visible = true
			else
				self.ToggleButton.Visible = not state
			end
		end
		if state then
			root.Visible = true
			ModalCatcher.Modal = true
			animScale = instant and 1 or 0.96
			applyScale()
			Tween(windowScale, instant and 0 or 0.2, { Scale = uiScale }, Enum.EasingStyle.Quart)
			animScale = 1
			Library:ShowCursor(true)
		else
			ModalCatcher.Modal = false
			Library:ShowCursor(false)
			Tween(windowScale, instant and 0 or 0.12, { Scale = uiScale * 0.96 })
			task.delay(instant and 0 or 0.13, function()
				if not Library.Open then root.Visible = false end
			end)
		end
	end
	function self:Toggle() self:SetOpen(not Library.Open) end

	local function doClose() self:SetOpen(false) end
	Library:Connect(closeBtn.MouseButton1Click, doClose)
	pcall(function() Library:Connect(closeBtn.Activated, doClose) end)
	Library:Connect(closeBtn.MouseEnter, function()
		for _, barX in ipairs(closeBars) do
			Tween(barX, 0.1, { BackgroundColor3 = Theme.Accent })
		end
	end)
	Library:Connect(closeBtn.MouseLeave, function()
		for _, barX in ipairs(closeBars) do
			Tween(barX, 0.1, { BackgroundColor3 = Theme.TextFaint })
		end
	end)

	local function doUnload() Library:Unload() end
	Library:Connect(unloadBtn.MouseButton1Click, doUnload)
	pcall(function() Library:Connect(unloadBtn.Activated, doUnload) end)
	Library:Connect(unloadBtn.MouseEnter, function()
		Tween(unloadIcon, 0.1, { Size = UDim2.fromOffset(Library.Mobile and 11 or 9, Library.Mobile and 11 or 9) })
		Library:ShowTooltip("Unload Hub (Completely Exit)")
	end)
	Library:Connect(unloadBtn.MouseLeave, function()
		Tween(unloadIcon, 0.1, { Size = UDim2.fromOffset(Library.Mobile and 9 or 7, Library.Mobile and 9 or 7) })
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

	function self:AddTab(name)
		local button = New("TextButton", {
			Name = "Tab_" .. name,
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, M.TitleBar),
			AutomaticSize = Enum.AutomaticSize.X,
			Parent = tabsRow,
		})
		Padding(button, 0, 0, 9, 9)

		local label = New("TextLabel", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Text = string.upper(name),
			FontFace = Font_(Enum.FontWeight.Medium),
			TextSize = TS(11),
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = button,
		})
		Library:Register(label, { TextColor3 = "TextFaint" })

		local content = New("Frame", {
			Name = "Content_" .. name,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = contentHolder,
		})

		local pageRow = New("Frame", {
			Name = "PageRow",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, M.PageTab),
			Visible = false,
			Parent = content,
		})
		List(pageRow, 2, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

		local pagesHolder = New("Frame", {
			Name = "PagesHolder",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(1, 1),
			Parent = content,
		})

		local tabIndicator = New("Frame", {
			Name = "Indicator",
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Parent = button,
		})
		Library:Register(tabIndicator, { BackgroundColor3 = "Accent" })

		local tab = setmetatable({
			Name = name,
			Window = self,
			Button = button,
			Label = label,
			Indicator = tabIndicator,
			Content = content,
			PageRow = pageRow,
			PagesHolder = pagesHolder,
			Pages = {},
		}, Tab)

		function tab:Select()
			local _win = tab.Window or (Library and Library.Window) or self
			for _, other in ipairs(_win.Tabs) do
				other.Content.Visible = false
				Tween(other.Label, 0.12, { TextColor3 = Theme.TextFaint })
				if other.Indicator then
					Tween(other.Indicator, 0.12, { BackgroundTransparency = 1 })
				end
			end
			content.Visible = true
			Tween(label, 0.12, { TextColor3 = Theme.Text })
			if tab.Indicator then
				Tween(tab.Indicator, 0.15, { BackgroundTransparency = 0 })
			end
			_win.ActiveTab = tab
			if #tab.Pages > 0 then
				local pageToSelect = tab.ActivePage or tab.Pages[1]
				if pageToSelect and pageToSelect.Select then
					pageToSelect.Select()
				end
			end
		end

		Library:Connect(button.MouseButton1Click, function() tab:Select() end)
		Library:Connect(button.MouseButton1Down, function() tab:Select() end)
		Library:Connect(button.MouseEnter, function()
			if self.ActiveTab ~= tab then Tween(label, 0.1, { TextColor3 = Theme.TextDim }) end
		end)
		Library:Connect(button.MouseLeave, function()
			if self.ActiveTab ~= tab then Tween(label, 0.1, { TextColor3 = Theme.TextFaint }) end
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

	if opts.ToggleButton ~= false and (Library.Mobile or opts.ToggleButton) then
		local btnSize = Library.Mobile and 36 or 30
		local btn = New("Frame", {
			Name = "ToggleButton",
			Size = UDim2.fromOffset(btnSize, btnSize),
			Position = opts.ToggleButtonPosition or UDim2.new(0, 12, 0.5, -60),
			ZIndex = 950,
			Parent = ScreenGui,
		})
		Library:Register(btn, { BackgroundColor3 = "Background" })
		Scalable(btn)
		Stroke(btn, "Border")

		for i = 1, 3 do
			local bar = New("Frame", {
				Size = UDim2.fromOffset(Library.Mobile and 18 or 14, 2),
				Position = UDim2.new(0.5, 0, 0.5, (i - 2) * (Library.Mobile and 6 or 5)),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderSizePixel = 0,
				ZIndex = 951,
				Parent = btn,
			})
			Library:Register(bar, { BackgroundColor3 = "Accent" })
		end

		local moved, pressStart, btnStart = false, nil, nil
		local hit = Hit(btn, "ToggleHit", 952)
		Library:Connect(hit.InputBegan, function(input)
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
					btn.Position = UDim2.new(
						btnStart.X.Scale, btnStart.X.Offset + delta.X,
						btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
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

		self.ToggleButton = btn
	end

	self:SetOpen(not Library.SplashActive, true)
	return self
end

--=====================================================================
-- Ecran de chargement
--=====================================================================

local function BuildWireCube(parent, taille, epaisseur)
	local aretes = {}
	local demi = taille / 2
	local teinte = Theme.Accent:Lerp(Color3.new(0, 0, 0), 0.28)

	local function arete(cf)
		local p = New("Part", {
			Size = Vector3.new(epaisseur, epaisseur, taille + epaisseur),
			Material = Enum.Material.Neon,
			Color = teinte,
			Anchored = true,
			CanCollide = false,
			CastShadow = false,
			Parent = parent,
		})
		table.insert(aretes, { Part = p, Base = cf })
	end

	for _, a in ipairs({ -1, 1 }) do
		for _, b in ipairs({ -1, 1 }) do
			arete(CFrame.new(0, a * demi, b * demi) * CFrame.Angles(0, math.pi / 2, 0))
			arete(CFrame.new(a * demi, 0, b * demi) * CFrame.Angles(math.pi / 2, 0, 0))
			arete(CFrame.new(a * demi, b * demi, 0))
		end
	end

	return aretes
end

function Library:Splash(opts)
	opts = opts or {}
	Library.SplashActive = true
	local voix = Library:PlaySound("Splash")

	local backdrop = New("Frame", {
		Name = "Splash",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.08,
		ZIndex = 800,
		Parent = ScreenGui,
	})
	Library:Register(backdrop, { BackgroundColor3 = "Background" })

	local panel = New("Frame", {
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(224, 176),
		ZIndex = 801,
		Parent = backdrop,
	})
	Library:Register(panel, { BackgroundColor3 = "Background" })
	Stroke(panel, "Border")

	local echelle = New("UIScale", { Scale = Library.Scale * 0.94, Parent = panel })

	local inner = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		ZIndex = 802,
		Parent = panel,
	})
	Stroke(inner, "BorderSoft")

	local vpf = New("ViewportFrame", {
		Name = "Cube",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 14),
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.fromOffset(96, 96),
		Ambient = Color3.fromRGB(80, 80, 90),
		LightColor = Color3.fromRGB(255, 255, 255),
		ZIndex = 803,
		Parent = inner,
	})

	local cam = New("Camera", {
		CFrame = CFrame.lookAt(Vector3.new(0, 0, 10), Vector3.zero),
		FieldOfView = 40,
		Parent = vpf,
	})
	vpf.CurrentCamera = cam

	local aretes = BuildWireCube(vpf, 2.6, 0.075)

	local coeur = New("Part", {
		Size = Vector3.new(1.15, 1.15, 1.15),
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(30, 30, 36),
		Anchored = true,
		CanCollide = false,
		CastShadow = false,
		Parent = vpf,
	})

	local titre = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 116),
		Size = UDim2.new(1, 0, 0, 14),
		Text = string.upper(opts.Title or "VESPER"),
		FontFace = Font_(Enum.FontWeight.Bold),
		TextSize = TS(11),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 803,
		Parent = inner,
	})
	Library:Register(titre, { TextColor3 = "Text" })

	local etat = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 134),
		Size = UDim2.new(1, 0, 0, 12),
		Text = string.upper(opts.Subtitle or "LOADING"),
		FontFace = Font_(Enum.FontWeight.Medium),
		TextSize = TS(10),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 803,
		Parent = inner,
	})
	Library:Register(etat, { TextColor3 = "TextFaint" })

	local piste = New("Frame", {
		Position = UDim2.new(0, 14, 1, -20),
		Size = UDim2.new(1, -28, 0, 8),
		ZIndex = 803,
		Parent = inner,
	})
	Library:Register(piste, { BackgroundColor3 = "Element" })
	Stroke(piste, "Border")

	local jauge = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BorderSizePixel = 0,
		ZIndex = 804,
		Parent = piste,
	})
	Library:Register(jauge, { BackgroundColor3 = "Accent" })
	New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(202, 202, 202)),
		}),
		Rotation = 90,
		Parent = jauge,
	})

	Tween(echelle, 0.3, { Scale = Library.Scale }, Enum.EasingStyle.Quart)

	local obj = { Instance = backdrop, Progress = 0 }
	local tDebut = os.clock()
	local t = 0
	local spin

	spin = Library:Connect(RunService.RenderStepped, function(dt)
		t = t + dt
		local rot = CFrame.Angles(t * 0.55, t * 0.85, math.sin(t * 0.4) * 0.15)
		for _, a in ipairs(aretes) do
			a.Part.CFrame = rot * a.Base
		end
		coeur.CFrame = rot
	end)

	function obj:SetProgress(valeur, texte)
		obj.Progress = math.clamp(valeur or 0, 0, 1)
		Tween(jauge, 0.25, { Size = UDim2.fromScale(obj.Progress, 1) })
		if texte then etat.Text = string.upper(texte) end
	end

	function obj:Finish(instant)
		if obj.Done then return end
		obj.Done = true
		Library.SplashActive = false

		local function fermer()
			if spin then spin:Disconnect() end
			Tween(backdrop, 0.25, { BackgroundTransparency = 1 })
			Tween(echelle, 0.25, { Scale = Library.Scale * 0.96 })
			for _, d in ipairs(backdrop:GetDescendants()) do
				if d:IsA("TextLabel") then
					Tween(d, 0.2, { TextTransparency = 1 })
				elseif d:IsA("ViewportFrame") then
					Tween(d, 0.2, { ImageTransparency = 1 })
				elseif d:IsA("Frame") then
					Tween(d, 0.2, { BackgroundTransparency = 1 })
				elseif d:IsA("UIStroke") then
					Tween(d, 0.2, { Transparency = 1 })
				end
			end
			task.delay(0.28, function()
				backdrop:Destroy()
				if Library.Window then Library.Window:SetOpen(true) end
			end)
		end

		local attente = 0
		if not instant then
			attente = math.max(attente, (opts.MinDuration or 0) - (os.clock() - tDebut))
			if opts.WaitForSound and voix and voix.IsPlaying then
				local reste = (voix.TimeLength - voix.TimePosition)
					/ math.max(voix.PlaybackSpeed, 0.01)
				attente = math.max(attente, reste)
			end
			attente = math.clamp(attente, 0, 10)
		end

		Tween(jauge, math.max(attente, 0.2), { Size = UDim2.fromScale(1, 1) },
			Enum.EasingStyle.Linear)

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
			duree = math.max(duree, (voix.TimeLength / speed))
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
-- Notifications
--=====================================================================

local NotifHolder = New("Frame", {
	Name = "Notifications",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 14),
	Size = UDim2.fromOffset(270, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	ZIndex = 700,
	Parent = ScreenGui,
})
Scalable(NotifHolder)
List(NotifHolder, 8, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)

function Library:Notify(opts)
	if type(opts) == "string" then opts = { Content = opts } end
	opts = opts or {}
	local duration = opts.Duration or 4
	local accent = opts.Color or (opts.Type == "error" and Theme.Danger)
		or (opts.Type == "success" and Theme.Success) or Theme.Accent

	local card = New("Frame", {
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0,
		ZIndex = 701,
		Parent = NotifHolder,
	})
	Library:Register(card, { BackgroundColor3 = "Background" })
	Stroke(card, "Border")

	local scale = New("UIScale", { Scale = 0.9, Parent = card })

	local strip = New("Frame", {
		Size = UDim2.new(0, 2, 1, 0),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		ZIndex = 702,
		Parent = card,
	})

	local body = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, 0),
		Position = UDim2.fromOffset(12, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 702,
		Parent = card,
	})
	Padding(body, 10, 11, 0, 0)
	List(body, 2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	if opts.Title then
		local t = Label(body, opts.Title, 12, "Text", Enum.FontWeight.SemiBold)
		t.Size = UDim2.new(1, 0, 0, 15)
		t.ZIndex = 703
	end
	local c = Label(body, opts.Content or "", 11, "TextDim")
	c.TextWrapped = true
	c.AutomaticSize = Enum.AutomaticSize.Y
	c.Size = UDim2.new(1, 0, 0, 0)
	c.TextYAlignment = Enum.TextYAlignment.Top
	c.ZIndex = 703

	local progress = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ZIndex = 703,
		Parent = card,
	})

	card.BackgroundTransparency = 1
	Tween(card, 0.2, { BackgroundTransparency = 0 })
	Tween(scale, 0.24, { Scale = 1 }, Enum.EasingStyle.Back)
	Tween(progress, duration, { Size = UDim2.new(0, 0, 0, 1) }, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		Tween(card, 0.2, { BackgroundTransparency = 1 })
		Tween(scale, 0.2, { Scale = 0.9 })
		task.delay(0.22, function() card:Destroy() end)
	end)

	return card
end

--=====================================================================
-- Watermark
--=====================================================================

local Watermark = New("Frame", {
	Name = "Watermark",
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0.5, 0, 0, 6),
	Size = UDim2.fromOffset(160, 22),
	Visible = false,
	ZIndex = 600,
	Parent = ScreenGui,
})
Library:Register(Watermark, { BackgroundColor3 = "Background" })
Scalable(Watermark)
Stroke(Watermark, "Border")

local WatermarkInner = New("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(2, 2),
	Size = UDim2.new(1, -4, 1, -4),
	ZIndex = 601,
	Parent = Watermark,
})
Stroke(WatermarkInner, "BorderSoft")
Padding(WatermarkInner, 0, 0, 9, 9)

local WatermarkText = New("TextLabel", {
	BackgroundTransparency = 1,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.new(0, 0, 1, 0),
	FontFace = Font_(Enum.FontWeight.Bold),
	TextSize = TS(11),
	RichText = true,
	Text = "",
	ZIndex = 602,
	Parent = WatermarkInner,
})
Library:Register(WatermarkText, { TextColor3 = "Text" })

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
				local out = string.upper(watermarkTemplate)
					:gsub("{FPS}", tostring(fps))
					:gsub("{PING}", tostring(ping) .. "MS")
					:gsub("{PLAYER}%s*/%s*", "")
					:gsub("/%s*{PLAYER}", "")
					:gsub("{PLAYER}", "")
					:gsub("{TIME}", os.date("%H:%M:%S"))
				local head, tail = out:match("^%s*([^/]+)(.*)$")
				if head then
					local a = Theme.Accent
					out = string.format('<font color="rgb(%d,%d,%d)">%s</font>%s',
						math.floor(a.R * 255), math.floor(a.G * 255), math.floor(a.B * 255), head, tail)
				end
				WatermarkText.Text = out
				Watermark.Size = UDim2.fromOffset(
					math.ceil(WatermarkText.AbsoluteSize.X / Library.Scale) + 22, 22)
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
	Position = UDim2.fromOffset(14, 48),
	Size = UDim2.fromOffset(150, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Visible = false,
	ZIndex = 600,
	Parent = ScreenGui,
})
Library:Register(KeyList, { BackgroundColor3 = "Panel2" })
Scalable(KeyList)
Stroke(KeyList, "Border")

local KeyListTitle = New("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 22),
	FontFace = Font_(Enum.FontWeight.SemiBold),
	TextSize = TS(11),
	Text = "Raccourcis",
	ZIndex = 601,
	Parent = KeyList,
})
Library:Register(KeyListTitle, { TextColor3 = "Text" })

local KeyListBody = New("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 22),
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	ZIndex = 601,
	Parent = KeyList,
})
Padding(KeyListBody, 0, 8, 9, 9)
List(KeyListBody, 3, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

function Library:SetKeybindListVisible(v) KeyList.Visible = v end

do
	local rows = {}
	Library:Connect(RunService.Heartbeat, function()
		if not KeyList.Visible then return end
		for _, bind in ipairs(KeybindRegistry) do
			if bind.Value.Key then
				local row = rows[bind]
				if not row then
					row = New("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 14),
						ZIndex = 602,
						Parent = KeyListBody,
					})
					local name = Label(row, bind.DisplayName, 11, "TextDim")
					name.Size = UDim2.new(1, -46, 1, 0)
					name.TextTruncate = Enum.TextTruncate.AtEnd
					local key = Label(row, "", 11, "TextFaint", Enum.FontWeight.SemiBold)
					key.TextXAlignment = Enum.TextXAlignment.Right
					key.Size = UDim2.new(0, 46, 1, 0)
					key.Position = UDim2.new(1, -46, 0, 0)
					rows[bind] = { Frame = row, Key = key, Name = name }
					row = rows[bind]
				end
				row.Frame.Visible = true
				row.Key.Text = KeyName(bind.Value.Key)
				row.Name.TextColor3 = bind:GetState() and Theme.Accent or Theme.TextDim
			elseif rows[bind] then
				rows[bind].Frame.Visible = false
			end
		end
	end)
end

--=====================================================================
-- Curseur
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

local function DrawArrow(color, offset, zindex)
	for _, seg in ipairs(ARROW) do
		local px = New("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(seg[3], 1),
			Position = UDim2.fromOffset(seg[2] + offset, seg[1] + offset),
			ZIndex = zindex,
			Parent = Cursor,
		})
	end
end

DrawArrow(Color3.new(0, 0, 0), 1, 1000)
DrawArrow(Color3.new(1, 1, 1), 0, 1001)

local cursorEnabled = not Library.Mobile
local systemIconWasEnabled = nil

function Library:SetCursorEnabled(state)
	cursorEnabled = state ~= false
	if not cursorEnabled then
		Library:ShowCursor(false)
	end
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

-- Curseur : passe en Heartbeat + skip si menu fermé
Library:Connect(RunService.Heartbeat, function()
    if not Cursor.Visible then return end
    if not Library.Open then 
        Cursor.Visible = false
        return 
    end
    local origin = PopupLayer.AbsolutePosition
    local m = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    Cursor.Position = UDim2.fromOffset(m.X - inset.X - origin.X, m.Y - inset.Y - origin.Y)
    if UserInputService.MouseIconEnabled then
        UserInputService.MouseIconEnabled = false
    end
end)

--=====================================================================
-- Configuration (sauvegarde / chargement)
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

local HttpService = game:GetService("HttpService")
local CONFIG_DIR = "vesper"

local function HasFS()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfolder) == "function"
end

function Library:SaveConfigToFile(name, folder)
	local dir = folder or CONFIG_DIR
	if not HasFS() then return false, "systeme de fichiers indisponible" end
	if not isfolder(dir) then makefolder(dir) end
	local ok, err = pcall(function()
		writefile(dir .. "/" .. name .. ".json", HttpService:JSONEncode(Library:GetConfig()))
	end)
	return ok, err
end

function Library:LoadConfigFromFile(name, folder)
	local dir = folder or CONFIG_DIR
	if not HasFS() then return false, "systeme de fichiers indisponible" end
	local path = dir .. "/" .. name .. ".json"
	if not isfile(path) then return false, "config introuvable" end
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
-- DÃƒÂ©chargement
--=====================================================================

function Library:Unload()
	if Library.Unloaded then return end
	Library.Unloaded = true
	pcall(function() Library:ShowCursor(false) end)
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


-- ============================================================================
-- BLOXSTRIKE VESPER HUB - NATIVE SKIN CHANGER & HYBRID AIMBOT EDITION (FIXED V3)
-- ============================================================================

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local State = {
    -- Aimbot
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Hold",
    AimbotActive = false,
    AimMethod = "Mouse Delta (Safe)",
    AimTargetPart = "Head",
    AimSensitivity = 0.45,
    AimSmoothness = 0.25,
    AimFOV = 140,
    ShowAimFOV = true,
    FOVColor = Color3.fromRGB(255, 150, 205),
    TeamCheck = true,
    WallCheck = true,
    NoRecoil = false,

    -- ESP
    ESPEnabled = true,
    ESPBoxes = true,
    BoxColor = Color3.fromRGB(255, 60, 60),
    TeamColor = Color3.fromRGB(60, 180, 255),
    ESPNames = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPWeapon = true,
    ESPChams = true,
    ChamsFillColor = Color3.fromRGB(255, 60, 60),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsFillTransparency = 0.5,
    ChamsOutlineTransparency = 0,

    -- Skin changer (OFF par défaut = safe)
    SkinChanger = false,
    CustomKnife = "Karambit",
    CustomKnifeSkin = "Fade",
    CustomGloves = "Sports Gloves",
    CustomGlovesSkin = "Imperial",
    CustomAKSkin = "Sakura",
    CustomAWPSkin = "Lore",
    CustomM4A1Skin = "Retro",
    CustomM4A4Skin = "The Ambassador",
    CustomDeagleSkin = "Lore",
    CustomUSPSkin = "SpecOps",
    CustomGlockSkin = "Fade",

    -- World
    Fullbright = false,
    NightMode = false,
    FieldOfView = 90,
    CustomFOV = false,

    -- Misc & Movement
    BunnyHop = false,

    -- Anti-HvH / Rage Protection
    AntiAim = false,
    AntiAimPitch = "Down (-89°)",
    AntiAimYaw = "Spinbot (Fast)",
    NoFlash = true,
    NoSlowdown = true,
    FakeDuck = false,
    Resolver = true,
}

local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origCameraFOV = Camera.FieldOfView

local function IsAimbotKeyDown()
    if not State.Aimbot then return false end
    if State.AimbotMode == "Always" then return true end
    if State.AimbotMode == "Toggle" then return State.AimbotActive end

    local key = State.AimbotKey
    if not key then return false end
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.UserInputType then
            return UserInputService:IsMouseButtonPressed(key)
        elseif key.EnumType == Enum.KeyCode then
            return UserInputService:IsKeyDown(key)
        end
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not State.Aimbot or not State.AimbotKey then return end
    local matches = false
    if input.UserInputType == State.AimbotKey or input.KeyCode == State.AimbotKey then
        matches = true
    end
    if matches then
        if State.AimbotMode == "Toggle" then
            State.AimbotActive = not State.AimbotActive
        else
            State.AimbotActive = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not State.AimbotKey then return end
    local matches = false
    if input.UserInputType == State.AimbotKey or input.KeyCode == State.AimbotKey then
        matches = true
    end
    if matches and State.AimbotMode == "Hold" then
        State.AimbotActive = false
    end
end)

local FOVCircle = nil
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Radius = State.AimFOV
    FOVCircle.Color = State.FOVColor
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
end)

local function GetCharacterModel(player)
    if not player then return nil end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if charsFolder then
        return charsFolder:FindFirstChild(player.Name)
    end
    return player.Character
end

local function GetLocalCharacter()
    return GetCharacterModel(LocalPlayer)
end

local function GetPlayerTeam(model)
    if not model then return "Unknown" end
    local glove = model:GetAttribute("EquippedGloves")
    if glove then
        if glove:find("CT Glove") then return "CT" end
        if glove:find("T Glove") then return "T" end
    end
    local charName = model:GetAttribute("CharacterName")
    if charName then
        if charName == "IDF" or charName == "FBI" or charName == "SAS" or charName == "SWAT" or charName == "GIGN" or charName == "SEAL" then
            return "CT"
        elseif charName == "Anarchist" or charName == "Phoenix" or charName == "Separatist" or charName == "Pirate" or charName == "Balkan" or charName == "Leet" then
            return "T"
        end
    end
    return "Unknown"
end

local function IsEnemy(otherModel)
    if not State.TeamCheck then return true end
    local myModel = GetLocalCharacter()
    if not myModel or not otherModel then return true end
    local myTeam = GetPlayerTeam(myModel)
    local theirTeam = GetPlayerTeam(otherModel)
    if myTeam == "Unknown" or theirTeam == "Unknown" then
        return true
    end
    return myTeam ~= theirTeam
end

local function IsAlive(model)
    if not model then return false end
    local dead = model:GetAttribute("Dead")
    if dead == true then return false end
    local hp = model:GetAttribute("Health")
    if hp and hp <= 0 then return false end
    return model:FindFirstChild("HumanoidRootPart") ~= nil and model:FindFirstChild("Head") ~= nil
end

local function IsVisible(targetPart, ignoreList)
    if not State.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList or {GetLocalCharacter(), Camera}
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return false
end

local function GetClosestTarget()
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local shortestDist = State.AimFOV
    local bestTarget = nil
    local myModel = GetLocalCharacter()

    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return nil end

    for _, model in pairs(charsFolder:GetChildren()) do
        if model:IsA("Model") and model.Name ~= LocalPlayer.Name and IsAlive(model) and IsEnemy(model) then
            local part = model:FindFirstChild(State.AimTargetPart) or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist2D < shortestDist then
                        local ignore = {myModel, Camera}
                        if IsVisible(part, ignore) then
                            shortestDist = dist2D
                            bestTarget = {
                                Model = model,
                                Part = part,
                                ScreenPos = Vector2.new(screenPos.X, screenPos.Y),
                                Distance = dist2D
                            }
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- Recoil hook
task.spawn(function()
    pcall(function()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers")
        local camCtrl = controllers and controllers:FindFirstChild("CameraController")
        if camCtrl then
            local camMod = require(camCtrl)
            if camMod and camMod.setWeaponRecoil then
                local oldSetRecoil = camMod.setWeaponRecoil
                camMod.setWeaponRecoil = function(self, ...)
                    if State.NoRecoil then return end
                    return oldSetRecoil(self, ...)
                end
            end
            if camMod and camMod.weaponKick then
                local oldWeaponKick = camMod.weaponKick
                camMod.weaponKick = function(self, ...)
                    if State.NoRecoil then return end
                    return oldWeaponKick(self, ...)
                end
            end
        end
    end)
end)

-- =========================================================================
--  MAIN RENDER (split RenderStepped/Heartbeat) — 3× plus rapide
-- =========================================================================

-- Throttle timers
local _now, _lastAimbot, _lastAntiAim, _lastNoFlash, _lastNoSlowdown = 0, 0, 0, 0, 0
local _cachedMainGui, _cachedChar, _cachedNeck, _cachedWaist, _cachedHum = nil, nil, nil, nil, nil
local _lastCharRefresh = 0
local _lastWalkSpeedValue = nil

-- ─── RenderStepped : UNIQUEMENT aimbot + FOV (doit être à 60 fps pour être smooth)
RunService.RenderStepped:Connect(function(dt)
    -- FOV circle (ne réécrit que si changement)
    if FOVCircle then
        local wantVisible = State.ShowAimFOV and State.Aimbot
        if FOVCircle.Visible ~= wantVisible then FOVCircle.Visible = wantVisible end
        if wantVisible then
            FOVCircle.Radius = State.AimFOV
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Color = State.FOVColor
        end
    end

    -- Aimbot uniquement quand la touche est pressée
    if IsAimbotKeyDown() then
        local target = GetClosestTarget()
        if target and target.Part then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local delta = (target.ScreenPos - center)

            if State.AimMethod == "Mouse Delta (Safe)" and mousemoverel then
                local smoothFactor = math.clamp(1 - State.AimSmoothness, 0.05, 1)
                mousemoverel(delta.X * smoothFactor * State.AimSensitivity,
                             delta.Y * smoothFactor * State.AimSensitivity)
            else
                local currentCF = Camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, target.Part.Position)
                Camera.CFrame = currentCF:Lerp(targetCF, math.clamp(1 - State.AimSmoothness, 0.05, 0.95))
            end
        end
    end

    -- FOV custom (write only si changement)
    if State.CustomFOV and Camera.FieldOfView ~= State.FieldOfView then
        Camera.FieldOfView = State.FieldOfView
    end
end)

-- ─── Heartbeat : tout le reste, throttlé
RunService.Heartbeat:Connect(function(dt)
    _now = os.clock()

    -- ── A. ANTI-AIM (30 Hz — hitbox desync, pas besoin de plus)
    if State.AntiAim and _now - _lastAntiAim >= 0.033 then
        _lastAntiAim = _now
        local myChar = GetLocalCharacter()
        if myChar and myChar ~= _cachedChar then
            _cachedChar = myChar
            local ut = myChar:FindFirstChild("UpperTorso")
            _cachedNeck = ut and ut:FindFirstChild("Neck")
            _cachedWaist = ut and ut:FindFirstChild("Waist")
        end
        if _cachedNeck and _cachedNeck:IsA("Motor6D") then
            local pitchAngle = 0
            if State.AntiAimPitch == "Down (-89°)" then pitchAngle = math.rad(-89)
            elseif State.AntiAimPitch == "Up (+89°)" then pitchAngle = math.rad(89)
            elseif State.AntiAimPitch == "Jitter Pitch" then pitchAngle = (math.random(1, 2) == 1) and math.rad(-89) or math.rad(89) end

            local yawAngle = 0
            if State.AntiAimYaw == "Spinbot (Fast)" then yawAngle = (_now * 25) % (math.pi * 2)
            elseif State.AntiAimYaw == "Spinbot (Slow)" then yawAngle = (_now * 8) % (math.pi * 2)
            elseif State.AntiAimYaw == "Jitter (180°)" then yawAngle = (math.random(1, 2) == 1) and math.rad(90) or math.rad(-90)
            elseif State.AntiAimYaw == "Invert (Backwards)" then yawAngle = math.rad(180)
            elseif State.AntiAimYaw == "Random" then yawAngle = math.rad(math.random(-180, 180)) end

            _cachedNeck.C0 = CFrame.new(0, 0.8, 0) * CFrame.Angles(pitchAngle, yawAngle, 0)
            if _cachedWaist and _cachedWaist:IsA("Motor6D") then
                _cachedWaist.C0 = CFrame.new(0, 0.2, 0) * CFrame.Angles(pitchAngle * 0.5, yawAngle * 0.5, 0)
            end
        end
    end

    -- ── B. NOFLASH (5 Hz — un flash dure 3s, inutile de check 60×/sec)
    if State.NoFlash and _now - _lastNoFlash >= 0.2 then
        _lastNoFlash = _now
        if not _cachedMainGui then
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            _cachedMainGui = pgui and pgui:FindFirstChild("MainGui")
        end
        if _cachedMainGui then
            local flash = _cachedMainGui:FindFirstChild("Flash", true) or _cachedMainGui:FindFirstChild("Flashbang", true)
            if flash and flash:IsA("GuiObject") and flash.Visible then
                flash.Visible = false
                pcall(function() flash.BackgroundTransparency = 1 end)
                pcall(function() flash.ImageTransparency = 1 end)
            end
        else
            _cachedMainGui = nil  -- retry plus tard
        end
    end

    -- ── C. NOSLOWDOWN (10 Hz — write seulement si changement)
    if State.NoSlowdown and _now - _lastNoSlowdown >= 0.1 then
        _lastNoSlowdown = _now
        local myChar = _cachedChar or GetLocalCharacter()
        _cachedHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if _cachedHum and _cachedHum.Health > 0 and _cachedHum.WalkSpeed < 16 then
            _cachedHum.WalkSpeed = 16
        end
    end

    -- ── D. Refresh du cache character (2 Hz)
    if _now - _lastCharRefresh >= 0.5 then
        _lastCharRefresh = _now
        _cachedChar = GetLocalCharacter()
        _cachedNeck, _cachedWaist, _cachedHum = nil, nil, nil
    end
end)

-- =========================================================================
--  NATIVE SKIN CHANGER (V4 RECURSION-SAFE ENGINE)
-- =========================================================================

local KNOWN_GLOVES = {
    ["Sports Gloves"] = true,
    ["Driver Gloves"] = true,
    ["Operator Gloves"] = true,
    ["Hand Wraps"] = true,
}

-- 1. DÉ-HOOK PHYSIQUE DES HOOKS PRÉCÉDENTS
pcall(function()
    local skinMod = ReplicatedStorage.Components.Common:FindFirstChild("GetResolvedSkinInformation")
    if skinMod then
        local mod = require(skinMod)
        local lib = debug.getupvalue(mod, 1)
        if type(lib) == "table" and isexecutorclosure and restorefunction then
            for _, fnName in ipairs({"GetCameraModel", "GetCharacterModel", "GetGloves"}) do
                if lib[fnName] and isexecutorclosure(lib[fnName]) then
                    pcall(restorefunction, lib[fnName])
                end
            end
        end
    end
end)

-- 2. RÉCUPÉRATION ET VALIDATION DE LA LIBRAIRIE
local ItemLib = nil
pcall(function()
    local skinMod = ReplicatedStorage.Components.Common:FindFirstChild("GetResolvedSkinInformation")
    if skinMod then
        ItemLib = debug.getupvalue(require(skinMod), 1)
    end
end)

-- 3. VÉRIFICATION DE SÉCURITÉ ANTI-RÉCURSION
local safeToHook = (ItemLib ~= nil and hookfunction ~= nil)
if ItemLib and isexecutorclosure then
    for _, fnName in ipairs({"GetCameraModel", "GetCharacterModel", "GetGloves"}) do
        if ItemLib[fnName] and isexecutorclosure(ItemLib[fnName]) then
            safeToHook = false
            break
        end
    end
end

if safeToHook then
    local origGetCamera
    local origGetCharacter
    local origGetGloves

    local camCache = {}
    local charCache = {}
    local gloveCache = {}

    local function ResolveWeaponSkin(weaponName, skinName)
        if weaponName == "CT Knife" or weaponName == "T Knife" or weaponName == "Melee" then
            if State.CustomKnife and State.CustomKnife ~= "Default" then
                return State.CustomKnife, State.CustomKnifeSkin or "Vanilla"
            end
        elseif weaponName == "AK-47" and State.CustomAKSkin and State.CustomAKSkin ~= "Default" then
            return weaponName, State.CustomAKSkin
        elseif weaponName == "AWP" and State.CustomAWPSkin and State.CustomAWPSkin ~= "Default" then
            return weaponName, State.CustomAWPSkin
        elseif weaponName == "M4A1-S" and State.CustomM4A1Skin and State.CustomM4A1Skin ~= "Default" then
            return weaponName, State.CustomM4A1Skin
        elseif weaponName == "M4A4" and State.CustomM4A4Skin and State.CustomM4A4Skin ~= "Default" then
            return weaponName, State.CustomM4A4Skin
        elseif weaponName == "Desert Eagle" and State.CustomDeagleSkin and State.CustomDeagleSkin ~= "Default" then
            return weaponName, State.CustomDeagleSkin
        elseif weaponName == "USP-S" and State.CustomUSPSkin and State.CustomUSPSkin ~= "Default" then
            return weaponName, State.CustomUSPSkin
        elseif weaponName == "Glock-18" and State.CustomGlockSkin and State.CustomGlockSkin ~= "Default" then
            return weaponName, State.CustomGlockSkin
        end
        return weaponName, skinName
    end

    -- Hook GetCameraModel avec trampoline assigné
    origGetCamera = hookfunction(ItemLib.GetCameraModel, function(weaponName, skinName, float, ...)
        if not State.SkinChanger then
            return origGetCamera(weaponName, skinName, float, ...)
        end

        local tw, ts = ResolveWeaponSkin(weaponName, skinName)
        if tw == weaponName and ts == skinName then
            return origGetCamera(weaponName, skinName, float, ...)
        end

        local key = tw .. "|" .. ts
        local cached = camCache[key]

        if cached == true then
            return origGetCamera(tw, ts, float, ...)
        elseif cached == false then
            return origGetCamera(weaponName, skinName, float, ...)
        else
            local ok, result = pcall(origGetCamera, tw, ts, float, ...)
            if ok and result ~= nil then
                camCache[key] = true
                return result
            else
                camCache[key] = false
                return origGetCamera(weaponName, skinName, float, ...)
            end
        end
    end)

    -- Hook GetCharacterModel avec trampoline assigné
    origGetCharacter = hookfunction(ItemLib.GetCharacterModel, function(weaponName, skinName, float, ...)
        if not State.SkinChanger then
            return origGetCharacter(weaponName, skinName, float, ...)
        end

        local tw, ts = ResolveWeaponSkin(weaponName, skinName)
        if tw == weaponName and ts == skinName then
            return origGetCharacter(weaponName, skinName, float, ...)
        end

        local key = tw .. "|" .. ts
        local cached = charCache[key]

        if cached == true then
            return origGetCharacter(tw, ts, float, ...)
        elseif cached == false then
            return origGetCharacter(weaponName, skinName, float, ...)
        else
            local ok, result = pcall(origGetCharacter, tw, ts, float, ...)
            if ok and result ~= nil then
                charCache[key] = true
                return result
            else
                charCache[key] = false
                return origGetCharacter(weaponName, skinName, float, ...)
            end
        end
    end)

    -- Hook GetGloves avec trampoline assigné
    origGetGloves = hookfunction(ItemLib.GetGloves, function(gloveName, skinName, float, ...)
        if not State.SkinChanger then
            return origGetGloves(gloveName, skinName, float, ...)
        end

        local targetGlove = gloveName
        local targetSkin  = skinName
        if State.CustomGloves and State.CustomGloves ~= "Default" and KNOWN_GLOVES[State.CustomGloves] then
            targetGlove = State.CustomGloves
            targetSkin  = State.CustomGlovesSkin or "Vanilla"
        end

        if targetGlove == gloveName and targetSkin == skinName then
            return origGetGloves(gloveName, skinName, float, ...)
        end

        local key = targetGlove .. "|" .. targetSkin
        local cached = gloveCache[key]

        if cached == true then
            return origGetGloves(targetGlove, targetSkin, float, ...)
        elseif cached == false then
            return origGetGloves(gloveName, skinName, float, ...)
        else
            local ok, result = pcall(origGetGloves, targetGlove, targetSkin, float, ...)
            if ok and result ~= nil then
                gloveCache[key] = true
                return result
            else
                gloveCache[key] = false
                return origGetGloves(gloveName, skinName, float, ...)
            end
        end
    end)

    -- Hook Animation.construct (Pour charger les animations du couteau sélectionné : Karambit, Butterfly, M9, etc.)
    pcall(function()
        local animClass = ReplicatedStorage.Classes.WeaponComponent.Classes.Viewmodel.Classes:FindFirstChild("Animation")
        if animClass then
            local animMod = require(animClass)
            if animMod and animMod.construct then
                local origAnimConstruct
                origAnimConstruct = hookfunction(animMod.construct, function(self, weaponName, ...)
                    if State.SkinChanger and (weaponName == "CT Knife" or weaponName == "T Knife" or weaponName == "Melee") then
                        if State.CustomKnife and State.CustomKnife ~= "Default" then
                            weaponName = State.CustomKnife
                        end
                    end
                    return origAnimConstruct(self, weaponName, ...)
                end)
            end
        end
    end)

    -- Hook LoadAnimation natif (Redirige les IDs d'animation de couteau vers celles du couteau sélectionné)
    pcall(function()
        local KNIFE_ID_MAP = {
            ["rbxassetid://73279561117871"] = "Idle",
            ["rbxassetid://96223952975180"] = "Equip",
            ["rbxassetid://133759992196733"] = "Swing1",
            ["rbxassetid://96244857355862"] = "Swing2",
            ["rbxassetid://87783969058443"] = "Heavy Swing",
            ["rbxassetid://106608551022584"] = "BackStab",
            ["rbxassetid://86047967063680"] = "Inspect"
        }

        local dummyAnimator = Instance.new("Animator")
        local dummyAnimCtrl = Instance.new("AnimationController")

        local origAnimatorLoad
        origAnimatorLoad = hookfunction(dummyAnimator.LoadAnimation, function(self, animObj, ...)
            if State.SkinChanger and State.CustomKnife and State.CustomKnife ~= "Default" then
                if animObj and animObj:IsA("Animation") then
                    local animName = KNIFE_ID_MAP[animObj.AnimationId]
                    if animName then
                        local kFolder = ReplicatedStorage.Assets.WeaponAnimations:FindFirstChild(State.CustomKnife)
                        local camFolder = kFolder and kFolder:FindFirstChild("CameraAnimations")
                        local targetAnim = camFolder and camFolder:FindFirstChild(animName)
                        if targetAnim then
                            return origAnimatorLoad(self, targetAnim, ...)
                        end
                    end
                end
            end
            return origAnimatorLoad(self, animObj, ...)
        end)

        local origCtrlLoad
        origCtrlLoad = hookfunction(dummyAnimCtrl.LoadAnimation, function(self, animObj, ...)
            if State.SkinChanger and State.CustomKnife and State.CustomKnife ~= "Default" then
                if animObj and animObj:IsA("Animation") then
                    local animName = KNIFE_ID_MAP[animObj.AnimationId]
                    if animName then
                        local kFolder = ReplicatedStorage.Assets.WeaponAnimations:FindFirstChild(State.CustomKnife)
                        local camFolder = kFolder and kFolder:FindFirstChild("CameraAnimations")
                        local targetAnim = camFolder and camFolder:FindFirstChild(animName)
                        if targetAnim then
                            return origCtrlLoad(self, targetAnim, ...)
                        end
                    end
                end
            end
            return origCtrlLoad(self, animObj, ...)
        end)
    end)

    getgenv()._BloxStrikeOriginals = {
        GetCameraModel    = origGetCamera,
        GetCharacterModel = origGetCharacter,
        GetGloves         = origGetGloves,
    }

    getgenv().BloxStrike_ResetSkinCache = function()
        table.clear(camCache)
        table.clear(charCache)
        table.clear(gloveCache)
    end
end

-- Inventory injector (manual only)
local function InjectUnlockAllInventory()
    local ok, res = pcall(function()
        local DataController = require(ReplicatedStorage.Controllers.DataController)
        local cache = debug.getupvalue(DataController.Get, 1)
        local myData = cache and cache[LocalPlayer]
        if not myData then return 0 end

        myData.Credits = 999999
        myData.TradeTokens = 9999

        local desiredItems = {
            { Name = "Karambit", Skin = "Fade", Category = "Melee" },
            { Name = "Karambit", Skin = "Tiger Stripes", Category = "Melee" },
            { Name = "Karambit", Skin = "Damascus", Category = "Melee" },
            { Name = "Karambit", Skin = "Vanilla", Category = "Melee" },
            { Name = "Butterfly Knife", Skin = "Fade", Category = "Melee" },
            { Name = "M9 Bayonet", Skin = "Fade", Category = "Melee" },
            { Name = "Sports Gloves", Skin = "Imperial", Category = "Glove" },
            { Name = "Sports Gloves", Skin = "Malibu", Category = "Glove" },
            { Name = "Sports Gloves", Skin = "Racer", Category = "Glove" },
            { Name = "Sports Gloves", Skin = "Blackout", Category = "Glove" },
            { Name = "Driver Gloves", Skin = "Snow Leopard", Category = "Glove" },
            { Name = "Operator Gloves", Skin = "Hellwire", Category = "Glove" },
            { Name = "Hand Wraps", Skin = "Aztec", Category = "Glove" },
            { Name = "AK-47", Skin = "Sakura", Category = "Weapon" },
            { Name = "AK-47", Skin = "Lore", Category = "Weapon" },
            { Name = "AWP", Skin = "Lore", Category = "Weapon" },
            { Name = "M4A1-S", Skin = "Retro", Category = "Weapon" },
            { Name = "M4A4", Skin = "The Ambassador", Category = "Weapon" },
            { Name = "Desert Eagle", Skin = "Lore", Category = "Weapon" },
            { Name = "USP-S", Skin = "SpecOps", Category = "Weapon" },
            { Name = "Glock-18", Skin = "Fade", Category = "Weapon" },
        }

        local existing = {}
        for _, it in ipairs(myData.Inventory) do
            if it._id then existing[it._id] = true end
        end

        local addedCount = 0
        for i, it in ipairs(desiredItems) do
            local id = it.Name .. "_" .. it.Skin
            if not existing[id] then
                local itemObj = {
                    Type = it.Category or "Weapon",
                    Charm = false,
                    IsTradeable = false,
                    MetaData = {
                        CreatedAt = os.time(),
                        TradeHistory = {},
                        Origin = "Case",
                        Owner = LocalPlayer.UserId,
                        OriginalOwner = LocalPlayer.UserId,
                        LastTradeAt = 0
                    },
                    NameTag = false,
                    _id = id,
                    Name = it.Name,
                    Skin = it.Skin,
                    Float = 0.001,
                    StatTrack = 1337,
                    Serial = i,
                    Stickers = {}
                }
                table.insert(myData.Inventory, itemObj)
                existing[id] = true
                addedCount = addedCount + 1
            end
        end

        -- Auto-équiper dans le Loadout natif
        for _, team in ipairs({"Counter-Terrorists", "Terrorists"}) do
            if myData.Loadout and myData.Loadout[team] and myData.Loadout[team].Equipped then
                local knifeId = State.CustomKnife .. "_" .. (State.CustomKnifeSkin or "Fade")
                local gloveId = State.CustomGloves .. "_" .. (State.CustomGlovesSkin or "Imperial")
                myData.Loadout[team].Equipped["Equipped Melee"] = knifeId
                myData.Loadout[team].Equipped["Equipped Gloves"] = gloveId
            end
        end

        -- Notifier l'InventoryController pour forcer le rafraîchissement de l'UI
        pcall(function()
            local ic = ReplicatedStorage.Controllers:FindFirstChild("InventoryController")
            if ic then
                local icMod = require(ic)
                if icMod and icMod.OnInventoryChanged and icMod.OnInventoryChanged.Fire then
                    icMod.OnInventoryChanged:Fire(myData.Inventory)
                end
            end
        end)

        return addedCount
    end)
    return ok and res or 0
end

local function BloxStrike_EquipNativeItem(weaponName, skinName, category)
    pcall(function()
        local DataController = require(ReplicatedStorage.Controllers.DataController)
        local cache = debug.getupvalue(DataController.Get, 1)
        local myData = cache and cache[LocalPlayer]
        if not myData then return end

        local id = weaponName .. "_" .. skinName
        local targetItem = nil
        for _, it in ipairs(myData.Inventory) do
            if it._id == id then targetItem = it break end
        end

        if not targetItem then
            targetItem = {
                Type = category or "Weapon",
                Charm = false,
                IsTradeable = false,
                MetaData = { CreatedAt = os.time(), TradeHistory = {}, Origin = "Case", Owner = LocalPlayer.UserId, OriginalOwner = LocalPlayer.UserId, LastTradeAt = 0 },
                NameTag = false,
                _id = id,
                Name = weaponName,
                Skin = skinName,
                Float = 0.001,
                StatTrack = 1337,
                Serial = 1,
                Stickers = {}
            }
            table.insert(myData.Inventory, targetItem)
        end

        for _, team in ipairs({"Counter-Terrorists", "Terrorists"}) do
            if myData.Loadout and myData.Loadout[team] and myData.Loadout[team].Equipped then
                if category == "Melee" then
                    myData.Loadout[team].Equipped["Equipped Melee"] = id
                elseif category == "Glove" then
                    myData.Loadout[team].Equipped["Equipped Gloves"] = id
                end
            end
        end

        local ic = ReplicatedStorage.Controllers:FindFirstChild("InventoryController")
        if ic then
            local icMod = require(ic)
            if icMod and icMod.equipLocal and category == "Melee" then
                pcall(icMod.equipLocal, targetItem)
            end
            if icMod and icMod.OnInventoryChanged and icMod.OnInventoryChanged.Fire then
                icMod.OnInventoryChanged:Fire(myData.Inventory)
            end
        end
    end)
end

-- =========================================================================
--  KNIFE ANIMATION SWAPPER (Patch Database.Custom.Weapons)
-- =========================================================================

local VALID_KNIFE_ANIMS = {
    ["Karambit"] = true,
    ["Butterfly Knife"] = true,
    ["M9 Bayonet"] = true,
    ["Flip Knife"] = true,
    ["Gut Knife"] = true,
    ["Stiletto Knife"] = true,
    ["Skeleton Knife"] = true,
    ["LightSaber"] = true,
}

local KNIFE_ORIGINALS = nil  -- pour restore

local function ApplyKnifeAnimations(knifeName)
    local rs = game:GetService("ReplicatedStorage")
    local db = rs:FindFirstChild("Database")
    local custom = db and db:FindFirstChild("Custom")
    local weapons = custom and custom:FindFirstChild("Weapons")
    local wa = rs:FindFirstChild("Assets")
    wa = wa and wa:FindFirstChild("WeaponAnimations")
    if not (weapons and wa) then return false end

    local ctK = weapons:FindFirstChild("CT Knife")
    local tK  = weapons:FindFirstChild("T Knife")
    if not (ctK and tK) then return false end

    local ctData = require(ctK)
    local tData  = require(tK)

    -- Sauvegarde les originaux au premier appel
    if not KNIFE_ORIGINALS then
        KNIFE_ORIGINALS = {
            ctCam  = ctData.CameraAnimations,
            ctChar = ctData.CharacterAnimations,
            tCam   = tData.CameraAnimations,
            tChar  = tData.CharacterAnimations,
        }
    end

    -- Target : soit le couteau custom, soit retour aux originaux si "Default"
    local targetFolder = nil
    if knifeName and knifeName ~= "Default" and VALID_KNIFE_ANIMS[knifeName] then
        targetFolder = wa:FindFirstChild(knifeName)
    end

    local newCam, newChar
    if targetFolder then
        newCam  = targetFolder:FindFirstChild("CameraAnimations")
        newChar = targetFolder:FindFirstChild("CharacterAnimations")
    else
        newCam  = KNIFE_ORIGINALS.ctCam
        newChar = KNIFE_ORIGINALS.ctChar
    end

    if not (newCam and newChar) then return false end

    -- setreadonly(false) requis car les tables des modules sont readonly
    pcall(setreadonly, ctData, false)
    pcall(setreadonly, tData, false)

    ctData.CameraAnimations    = newCam
    ctData.CharacterAnimations = newChar
    tData.CameraAnimations     = newCam
    tData.CharacterAnimations  = newChar

    return true
end

-- Helper exporté globalement pour être appelé depuis les callbacks du dropdown
getgenv().BloxStrike_ApplyKnifeAnimations = ApplyKnifeAnimations

-- Initialisation immédiate des animations au chargement
if State.CustomKnife and State.CustomKnife ~= "Default" then
    pcall(ApplyKnifeAnimations, State.CustomKnife)
end

-- =========================================================================
--  ESP
-- =========================================================================
local ESP_Cache = {}

local function GetWeaponName(model)
    local wpFolder = model:FindFirstChild("WeaponModel")
    if wpFolder and #wpFolder:GetChildren() > 0 then
        return wpFolder:GetChildren()[1].Name
    end
    return "Primary"
end

local function CreateESP(model)
    if ESP_Cache[model] then return end

    local box = Drawing.new("Square")
    box.Thickness = 1.5; box.Filled = false; box.Transparency = 1; box.Visible = false

    local boxOutline = Drawing.new("Square")
    boxOutline.Thickness = 3; boxOutline.Filled = false; boxOutline.Transparency = 0.5
    boxOutline.Color = Color3.fromRGB(0, 0, 0); boxOutline.Visible = false

    local nameText = Drawing.new("Text")
    nameText.Size = 13; nameText.Center = true; nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameText.Color = Color3.fromRGB(255, 255, 255); nameText.Visible = false

    local infoText = Drawing.new("Text")
    infoText.Size = 11; infoText.Center = true; infoText.Outline = true
    infoText.OutlineColor = Color3.fromRGB(0, 0, 0)
    infoText.Color = Color3.fromRGB(200, 200, 200); infoText.Visible = false

    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1; healthBar.Filled = true; healthBar.Transparency = 1
    healthBar.Color = Color3.fromRGB(50, 220, 90); healthBar.Visible = false

    local healthOutline = Drawing.new("Square")
    healthOutline.Thickness = 1; healthOutline.Filled = true; healthOutline.Transparency = 0.6
    healthOutline.Color = Color3.fromRGB(0, 0, 0); healthOutline.Visible = false

    local highlight = Instance.new("Highlight")
    highlight.Name = "VesperChams"
    highlight.FillColor = State.ChamsFillColor
    highlight.OutlineColor = State.ChamsOutlineColor
    highlight.FillTransparency = State.ChamsFillTransparency
    highlight.OutlineTransparency = State.ChamsOutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Adornee = model
    pcall(function() highlight.Parent = game:GetService("CoreGui") end)

    ESP_Cache[model] = {
        Model = model,
        Highlight = highlight,
        Drawings = {
            Box = box, BoxOutline = boxOutline,
            Name = nameText, Info = infoText,
            HealthBar = healthBar, HealthOutline = healthOutline
        }
    }
end

-- =========================================================================
--  ESP — Heartbeat + throttle 30 Hz + early-out distance
-- =========================================================================
local ESP_UPDATE_INTERVAL = 1 / 30
local _lastESPUpdate = 0
local MAX_ESP_DISTANCE = 500  -- studs
local _espDistSq = MAX_ESP_DISTANCE * MAX_ESP_DISTANCE

RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - _lastESPUpdate < ESP_UPDATE_INTERVAL then return end
    _lastESPUpdate = now

    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return end

    local myModel = GetLocalCharacter()
    local camPos = Camera.CFrame.Position

    if not State.ESPEnabled then
        for _, data in pairs(ESP_Cache) do
            for _, d in pairs(data.Drawings) do if d.Visible then d.Visible = false end end
            if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
        end
        return
    end

    -- Un seul passage : création + update
    for _, model in pairs(charsFolder:GetChildren()) do
        if not model:IsA("Model") or model.Name == LocalPlayer.Name 
           or model == myModel or model == LocalPlayer.Character then
            continue
        end

        if not ESP_Cache[model] then CreateESP(model) end
        local data = ESP_Cache[model]
        if not data then continue end

        -- Early-out : skip si mort ou hors distance AVANT WorldToViewportPoint
        if not model.Parent or not IsAlive(model) then
            for _, d in pairs(data.Drawings) do if d.Visible then d.Visible = false end end
            if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
            continue
        end

        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Check distance AVANT W2VP (le plus gros gain)
        local distSq = (camPos - hrp.Position).Magnitude ^ 2
        if distSq > _espDistSq then
            for _, d in pairs(data.Drawings) do if d.Visible then d.Visible = false end end
            if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
            continue
        end

        -- Team check
        local isEnemy = IsEnemy(model)
        if State.TeamCheck and not isEnemy then
            for _, d in pairs(data.Drawings) do if d.Visible then d.Visible = false end end
            if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
            continue
        end

        local head = model:FindFirstChild("Head")
        if not head then continue end

        local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)
        local headTopPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.9, 0))
        local footPos, footOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.7, 0))

        if not (hrpOnScreen or headOnScreen or footOnScreen) then
            for _, d in pairs(data.Drawings) do if d.Visible then d.Visible = false end end
            if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
            continue
        end

        local height = math.abs(headTopPos.Y - footPos.Y)
        if height <= 15 or height >= 1200 then
            for _, d in pairs(data.Drawings) do if d.Visible then d.Visible = false end end
            if data.Highlight and data.Highlight.Enabled then data.Highlight.Enabled = false end
            continue
        end

        local width = math.clamp(height * 0.55, 8, 600)
        local topLeft = Vector2.new(hrpPos.X - width / 2, headTopPos.Y)
        local boxColor = isEnemy and State.BoxColor or State.TeamColor

        -- Box
        if State.ESPBoxes then
            local bo = data.Drawings.BoxOutline
            bo.Size, bo.Position, bo.Visible = Vector2.new(width, height), topLeft, true
            local b = data.Drawings.Box
            b.Size, b.Position, b.Color, b.Visible = Vector2.new(width, height), topLeft, boxColor, true
        else
            if data.Drawings.Box.Visible then data.Drawings.Box.Visible = false end
            if data.Drawings.BoxOutline.Visible then data.Drawings.BoxOutline.Visible = false end
        end

        -- Name
        if State.ESPNames then
            data.Drawings.Name.Text = model.Name .. " [" .. GetPlayerTeam(model) .. "]"
            data.Drawings.Name.Position = Vector2.new(hrpPos.X, topLeft.Y - 16)
            data.Drawings.Name.Visible = true
        elseif data.Drawings.Name.Visible then
            data.Drawings.Name.Visible = false
        end

        -- Info
        local infoParts = {}
        local hp = model:GetAttribute("Health") or 100
        if State.ESPHealth then table.insert(infoParts, hp .. " HP") end
        if State.ESPDistance then table.insert(infoParts, math.floor(math.sqrt(distSq)) .. "m") end
        if State.ESPWeapon then table.insert(infoParts, GetWeaponName(model)) end

        if #infoParts > 0 then
            data.Drawings.Info.Text = table.concat(infoParts, " • ")
            data.Drawings.Info.Position = Vector2.new(hrpPos.X, topLeft.Y + height + 3)
            data.Drawings.Info.Visible = true
        elseif data.Drawings.Info.Visible then
            data.Drawings.Info.Visible = false
        end

        -- Health
        if State.ESPHealth then
            local barWidth, barHeight = 3, height
            local hpPercent = math.clamp(hp / 100, 0, 1)
            local fillH = barHeight * hpPercent

            local ho = data.Drawings.HealthOutline
            ho.Size = Vector2.new(barWidth + 2, barHeight + 2)
            ho.Position = Vector2.new(topLeft.X - barWidth - 4, topLeft.Y - 1)
            ho.Visible = true

            local hb = data.Drawings.HealthBar
            hb.Size = Vector2.new(barWidth, fillH)
            hb.Position = Vector2.new(topLeft.X - barWidth - 3, topLeft.Y + (barHeight - fillH))
            hb.Color = Color3.fromHSV(hpPercent * 0.33, 0.9, 0.9)
            hb.Visible = true
        else
            if data.Drawings.HealthBar.Visible then data.Drawings.HealthBar.Visible = false end
            if data.Drawings.HealthOutline.Visible then data.Drawings.HealthOutline.Visible = false end
        end

        -- Chams
        if State.ESPChams and data.Highlight then
            if not data.Highlight.Enabled then data.Highlight.Enabled = true end
            data.Highlight.FillColor = isEnemy and State.ChamsFillColor or State.TeamColor
            data.Highlight.OutlineColor = State.ChamsOutlineColor
            data.Highlight.FillTransparency = State.ChamsFillTransparency
            data.Highlight.OutlineTransparency = State.ChamsOutlineTransparency
        elseif data.Highlight and data.Highlight.Enabled then
            data.Highlight.Enabled = false
        end
    end
end)

-- ═══ FIX ESP FANTÔME (Purge des modèles invalides / détruits / orphelins) ═══
local function HideESPDrawData(data)
    if not data then return end
    for _, d in pairs(data.Drawings) do
        if d and d.Visible then
            pcall(function() d.Visible = false end)
        end
    end
    if data.Highlight and data.Highlight.Enabled then
        pcall(function() data.Highlight.Enabled = false end)
    end
end

-- 1) Sweep rapide (toutes les 100ms) pour nettoyer le cache et cacher les orphelins
task.spawn(function()
    while task.wait(0.1) do
        local charsFolder = Workspace:FindFirstChild("Characters")
        for model, data in pairs(ESP_Cache) do
            local valid = model 
                and model.Parent ~= nil 
                and charsFolder ~= nil 
                and model.Parent == charsFolder 
                and IsAlive(model)

            if not valid then
                HideESPDrawData(data)
            end
        end

        -- Failsafe : si ESP désactivé ou Characters introuvable (fin de round)
        if not State.ESPEnabled or not charsFolder then
            for _, data in pairs(ESP_Cache) do
                HideESPDrawData(data)
            end
        end
    end
end)

-- 2) Écouteur instantané sur la suppression de modèle dans Characters
task.spawn(function()
    while task.wait(0.5) do
        local charsFolder = Workspace:FindFirstChild("Characters")
        if charsFolder then
            charsFolder.ChildRemoved:Connect(function(child)
                local data = ESP_Cache[child]
                if data then
                    HideESPDrawData(data)
                    for _, d in pairs(data.Drawings) do
                        pcall(function() d:Remove() end)
                    end
                    if data.Highlight then
                        pcall(function() data.Highlight:Destroy() end)
                    end
                    ESP_Cache[child] = nil
                end
            end)
            break
        end
    end
end)

-- Auto BunnyHop
RunService.Heartbeat:Connect(function()
    if not State.BunnyHop then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:GetFocusedTextBox() then
        pcall(function()
            local charCtrl = ReplicatedStorage:FindFirstChild("Controllers") and ReplicatedStorage.Controllers:FindFirstChild("CharacterController")
            if charCtrl then
                local mod = require(charCtrl)
                if mod and mod.jump then mod.jump() end
            end
        end)
    end
end)

-- =========================================================================
--  UI
-- =========================================================================

local Window = Vesper:CreateWindow({
    Title       = "BLOXSTRIKE",
    Footer      = "v1.0.1-fixed",
    Size        = UDim2.fromOffset(680, 500),
    Accent      = Color3.fromRGB(255, 150, 205),
    ToggleKey   = Enum.KeyCode.RightShift,
    StatusRight = "RShift to toggle",
    Splash      = false,
})

Vesper:SetWatermark("BLOXSTRIKE / FPS {fps} / {ping} / {time}", true)
Vesper:SetKeybindListVisible(false)

-- TAB COMBAT
local CombatTab = Window:AddTab("Combat")
local AimbotGroup = CombatTab:AddGroup("Legit & Smooth Aimbot", "Left")

AimbotGroup:AddToggle("AimbotToggle", {
    Text = "Enable Aimbot", Default = State.Aimbot,
    Tooltip = "Enables automatic camera tracking when aiming",
    Callback = function(v) State.Aimbot = v end
})

AimbotGroup:AddKeybind("AimbotKeybind", {
    Text = "Aimbot Key / Button",
    Default = Enum.UserInputType.MouseButton2, Mode = "Hold",
    Tooltip = "Left-click: Assign. Right-click: Switch mode.",
    Changed = function(k)
        if k then
            State.AimbotKey = k.Key
            State.AimbotMode = k.Mode or "Hold"
            local kName = (Vesper.KeyName and Vesper.KeyName(k.Key)) or (k.Key and k.Key.Name) or "None"
            Vesper:Notify({Title = "Aimbot Keybind", Content = kName .. " [" .. tostring(State.AimbotMode) .. "]", Duration = 2})
        end
    end
})

AimbotGroup:AddDropdown("AimMethod", {
    Text = "Aim Tracking Method",
    Values = {"Mouse Delta (Safe)", "Camera Direct"},
    Default = State.AimMethod,
    Callback = function(v) State.AimMethod = v end
})

AimbotGroup:AddDropdown("AimTargetPart", {
    Text = "Target Bone",
    Values = {"Head", "UpperTorso", "HumanoidRootPart"},
    Default = State.AimTargetPart,
    Callback = function(v) State.AimTargetPart = v end
})

AimbotGroup:AddSlider("AimSensitivity", {
    Text = "Aim Speed", Min = 0.1, Max = 1.0, Default = State.AimSensitivity,
    Rounding = 2, Suffix = "x",
    Callback = function(v) State.AimSensitivity = v end
})

AimbotGroup:AddSlider("AimSmoothness", {
    Text = "Aim Smoothness", Min = 0.05, Max = 0.95, Default = State.AimSmoothness,
    Rounding = 2,
    Callback = function(v) State.AimSmoothness = v end
})

AimbotGroup:AddSlider("AimFOV", {
    Text = "Aimbot FOV Radius", Min = 30, Max = 500, Default = State.AimFOV,
    Rounding = 0, Suffix = " px",
    Callback = function(v) State.AimFOV = v end
})

AimbotGroup:AddToggle("ShowFOV", {
    Text = "Show FOV Circle", Default = State.ShowAimFOV,
    Callback = function(v) State.ShowAimFOV = v end
})

AimbotGroup:AddColorPicker("FOVColor", {
    Text = "FOV Circle Color", Default = State.FOVColor,
    Callback = function(c) State.FOVColor = c end
})

local CombatModsGroup = CombatTab:AddGroup("Weapon Modifiers", "Right")

CombatModsGroup:AddToggle("NoRecoil", {
    Text = "No Recoil", Default = State.NoRecoil,
    Callback = function(v) State.NoRecoil = v end
})
CombatModsGroup:AddToggle("TeamCheck", {
    Text = "Team Check", Default = State.TeamCheck,
    Callback = function(v) State.TeamCheck = v end
})
CombatModsGroup:AddToggle("WallCheck", {
    Text = "Visibility Raycast Check", Default = State.WallCheck,
    Callback = function(v) State.WallCheck = v end
})

-- TAB SKINS
local SkinsTab = Window:AddTab("Skins")
local KnifeGroup = SkinsTab:AddGroup("Melee & Knife Changer", "Left")

KnifeGroup:AddToggle("EnableSkinChanger", {
    Text = "Enable Engine Skin Changer",
    Default = State.SkinChanger,
    Tooltip = "Active ceci seulement si tu veux changer de skin.",
    Callback = function(v)
        State.SkinChanger = v
        if getgenv().BloxStrike_ResetSkinCache then
            getgenv().BloxStrike_ResetSkinCache()
        end
    end
})

KnifeGroup:AddDropdown("CustomKnifeSelect", {
    Text = "Equipped Knife Model",
    Values = {"Karambit", "Butterfly Knife", "M9 Bayonet", "LightSaber", "Skeleton Knife", "Stiletto Knife", "Flip Knife", "Gut Knife", "Default"},
    Default = State.CustomKnife,
    Callback = function(v)
        State.CustomKnife = v
        if getgenv().BloxStrike_ResetSkinCache then
            getgenv().BloxStrike_ResetSkinCache()
        end
        -- Applique les animations du couteau
        if getgenv().BloxStrike_ApplyKnifeAnimations then
            getgenv().BloxStrike_ApplyKnifeAnimations(v)
        end
        -- Équipe le couteau côté inventaire
        if v ~= "Default" then
            BloxStrike_EquipNativeItem(v, State.CustomKnifeSkin or "Fade", "Melee")
        end
        Vesper:Notify({
            Title = "Knife Changer",
            Content = "Knife set to " .. v .. ". Re-equip your knife to refresh!",
            Duration = 3, Type = "info"
        })
    end
})

KnifeGroup:AddDropdown("CustomKnifeSkinSelect", {
    Text = "Knife Finish / Skin",
    Values = {"Fade", "Vanilla", "Tiger Stripes", "Damascus", "Doodle", "Rusted", "Woodland", "Whiteout", "Midnight", "Blackwidow", "Scarlet", "Aurora", "Frostbite", "Noir"},
    Default = State.CustomKnifeSkin,
    Callback = function(v)
        State.CustomKnifeSkin = v
        if getgenv().BloxStrike_ResetSkinCache then
            getgenv().BloxStrike_ResetSkinCache()
        end
        if State.CustomKnife and State.CustomKnife ~= "Default" then
            BloxStrike_EquipNativeItem(State.CustomKnife, v, "Melee")
        end
    end
})

KnifeGroup:AddDivider()

KnifeGroup:AddDropdown("CustomGlovesSelect", {
    Text = "Equipped Gloves",
    Values = {"Sports Gloves", "Driver Gloves", "Operator Gloves", "Hand Wraps", "Default"},
    Default = State.CustomGloves,
    Callback = function(v)
        State.CustomGloves = v
        if getgenv().BloxStrike_ResetSkinCache then
            getgenv().BloxStrike_ResetSkinCache()
        end
        if v ~= "Default" then
            BloxStrike_EquipNativeItem(v, State.CustomGlovesSkin or "Imperial", "Glove")
        end
    end
})

KnifeGroup:AddDropdown("CustomGlovesSkinSelect", {
    Text = "Gloves Pattern / Skin",
    Values = {"Imperial", "Vanilla", "Malibu", "Racer", "Blackout", "Snow Leopard", "Hellwire", "Aztec", "Superconductor", "Pandora", "Cobalt"},
    Default = State.CustomGlovesSkin,
    Callback = function(v)
        State.CustomGlovesSkin = v
        if getgenv().BloxStrike_ResetSkinCache then
            getgenv().BloxStrike_ResetSkinCache()
        end
        if State.CustomGloves and State.CustomGloves ~= "Default" then
            BloxStrike_EquipNativeItem(State.CustomGloves, v, "Glove")
        end
    end
})

KnifeGroup:AddButton("Unlock All (Add to Inventory)", {
    Tooltip = "Inject 20+ skins client-side",
    Callback = function()
        local added = InjectUnlockAllInventory()
        Vesper:Notify({Title = "Unlock All", Content = "Injected " .. tostring(added or 0) .. " items!", Duration = 4, Type = "success"})
    end
})

local GunsGroup = SkinsTab:AddGroup("Gun Skins & Finishes", "Right")

GunsGroup:AddDropdown("CustomAKSkin", {
    Text = "AK-47 Skin", Values = {"Sakura","Lore","Midas","Red Baron","Luminex","Default"}, Default = State.CustomAKSkin,
    Callback = function(v)
        State.CustomAKSkin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})
GunsGroup:AddDropdown("CustomAWPSkin", {
    Text = "AWP Skin", Values = {"Lore","Koi Pond","Freedom","Typhon","Default"}, Default = State.CustomAWPSkin,
    Callback = function(v)
        State.CustomAWPSkin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})
GunsGroup:AddDropdown("CustomM4A1Skin", {
    Text = "M4A1-S Skin", Values = {"Retro","Phaseprint","BlackOps","Default"}, Default = State.CustomM4A1Skin,
    Callback = function(v)
        State.CustomM4A1Skin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})
GunsGroup:AddDropdown("CustomM4A4Skin", {
    Text = "M4A4 Skin", Values = {"The Ambassador","Freedom","B-Hop","Default"}, Default = State.CustomM4A4Skin,
    Callback = function(v)
        State.CustomM4A4Skin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})
GunsGroup:AddDropdown("CustomDeagleSkin", {
    Text = "Desert Eagle Skin", Values = {"Lore","Hero of Hell","Mercy","Freedom","Default"}, Default = State.CustomDeagleSkin,
    Callback = function(v)
        State.CustomDeagleSkin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})
GunsGroup:AddDropdown("CustomUSPSkin", {
    Text = "USP-S Skin", Values = {"SpecOps","Luminex","Ajax","Default"}, Default = State.CustomUSPSkin,
    Callback = function(v)
        State.CustomUSPSkin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})
GunsGroup:AddDropdown("CustomGlockSkin", {
    Text = "Glock-18 Skin", Values = {"Fade","Hero of Hell","Aurora","Default"}, Default = State.CustomGlockSkin,
    Callback = function(v)
        State.CustomGlockSkin = v
        if getgenv().BloxStrike_ResetSkinCache then getgenv().BloxStrike_ResetSkinCache() end
    end
})

-- TAB VISUALS
local VisualTab = Window:AddTab("Visuals")
local EspGroup = VisualTab:AddGroup("Player ESP Overlay", "Left")

EspGroup:AddToggle("ESPEnable", {Text = "Enable Player ESP", Default = State.ESPEnabled, Callback = function(v) State.ESPEnabled = v end})
EspGroup:AddToggle("ESPBoxes", {Text = "Bounding Box ESP", Default = State.ESPBoxes, Callback = function(v) State.ESPBoxes = v end})
EspGroup:AddToggle("ESPNames", {Text = "Player Names & Teams", Default = State.ESPNames, Callback = function(v) State.ESPNames = v end})
EspGroup:AddToggle("ESPHealth", {Text = "Health Bar & Digits", Default = State.ESPHealth, Callback = function(v) State.ESPHealth = v end})
EspGroup:AddToggle("ESPDistance", {Text = "Distance Meters", Default = State.ESPDistance, Callback = function(v) State.ESPDistance = v end})
EspGroup:AddToggle("ESPWeapon", {Text = "Equipped Weapon Name", Default = State.ESPWeapon, Callback = function(v) State.ESPWeapon = v end})

local ChamsGroup = VisualTab:AddGroup("Chams & World Lighting", "Right")

ChamsGroup:AddToggle("ESPChams", {Text = "Wallhack Chams", Default = State.ESPChams, Callback = function(v) State.ESPChams = v end})
ChamsGroup:AddColorPicker("ChamsEnemyColor", {Text = "Enemy Chams Color", Default = State.ChamsFillColor, Callback = function(c) State.ChamsFillColor = c end})
ChamsGroup:AddSlider("ChamsTransparency", {Text = "Chams Transparency", Min = 0.1, Max = 0.9, Default = State.ChamsFillTransparency, Rounding = 2, Callback = function(v) State.ChamsFillTransparency = v end})

ChamsGroup:AddDivider()

ChamsGroup:AddToggle("Fullbright", {
    Text = "Fullbright", Default = State.Fullbright,
    Callback = function(v)
        State.Fullbright = v
        if v then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = origAmbient
            Lighting.OutdoorAmbient = origOutdoorAmbient
            Lighting.Brightness = origBrightness
        end
    end
})

ChamsGroup:AddToggle("NightMode", {
    Text = "Night Atmosphere", Default = State.NightMode,
    Callback = function(v)
        State.NightMode = v
        Lighting.ClockTime = v and 0 or origClockTime
    end
})

ChamsGroup:AddToggle("CustomFOVToggle", {
    Text = "Custom Camera FOV", Default = State.CustomFOV,
    Callback = function(v)
        State.CustomFOV = v
        if not v then Camera.FieldOfView = origCameraFOV end
    end
})

ChamsGroup:AddSlider("CustomFOVSlider", {
    Text = "Field of View", Min = 70, Max = 120, Default = State.FieldOfView,
    Rounding = 0, Suffix = " deg",
    Callback = function(v) State.FieldOfView = v end
})

-- TAB MISC / HVH
local UtilTab = Window:AddTab("Misc")
local MoveGroup = UtilTab:AddGroup("Tactical Movement", "Left")

MoveGroup:AddToggle("BunnyHop", {
    Text = "Auto BunnyHop (Hold Space)", Default = State.BunnyHop,
    Callback = function(v) State.BunnyHop = v end
})

local HvhGroup = UtilTab:AddGroup("Anti-HvH & Rage Defense", "Right")

HvhGroup:AddToggle("AntiAimToggle", {
    Text = "Enable Anti-Aim (Desync)", Default = State.AntiAim,
    Callback = function(v) State.AntiAim = v end
})

HvhGroup:AddDropdown("AntiAimPitchDropdown", {
    Text = "Pitch Angle",
    Values = {"Down (-89°)", "Up (+89°)", "Zero (0°)", "Jitter Pitch"},
    Default = State.AntiAimPitch,
    Callback = function(v) State.AntiAimPitch = v end
})

HvhGroup:AddDropdown("AntiAimYawDropdown", {
    Text = "Yaw Mode",
    Values = {"Spinbot (Fast)", "Spinbot (Slow)", "Jitter (180°)", "Invert (Backwards)", "Random"},
    Default = State.AntiAimYaw,
    Callback = function(v) State.AntiAimYaw = v end
})

HvhGroup:AddDivider()

HvhGroup:AddToggle("NoFlashToggle", {
    Text = "Flashbang Immunity (No Flash)", Default = State.NoFlash,
    Callback = function(v) State.NoFlash = v end
})

HvhGroup:AddToggle("NoSlowdownToggle", {
    Text = "Anti-Tagging (No Slowdown)", Default = State.NoSlowdown,
    Callback = function(v) State.NoSlowdown = v end
})

-- TAB SETTINGS
local SettingsTab = Window:AddTab("Settings")
local MenuCtrlGroup = SettingsTab:AddGroup("Interface Config", "Left")

MenuCtrlGroup:AddKeybind("ToggleKey", {
    Text = "Menu Keybind", Default = Enum.KeyCode.RightShift,
    Changed = function(k)
        if k and k.Key then
            Vesper.ToggleKey = k.Key
            Window:SetStatus(nil, k.Key.Name .. " to toggle")
        end
    end
})

MenuCtrlGroup:AddToggle("WatermarkToggle", {
    Text = "Top Watermark Bar", Default = true,
    Callback = function(v) Vesper:SetWatermarkVisible(v) end
})

MenuCtrlGroup:AddSlider("UIScale", {
    Text = "UI Scaling Factor", Min = 1.0, Max = 2.2,
    Default = Vesper.Scale or 1.8, Rounding = 1, Suffix = "x",
    Callback = function(v) Vesper:SetScale(v) end
})

local ThemeGroup = SettingsTab:AddGroup("Theme Colors", "Right")

ThemeGroup:AddColorPicker("AccentPicker", {
    Text = "Theme Accent", Default = Vesper.Theme.Accent,
    Callback = function(c) Vesper:SetAccent(c) end
})

Vesper:Notify({
    Title = "BLOXSTRIKE HUB",
    Content = "Loaded V4. Skin Changer OFF par défaut : active-le dans l'onglet Skins.",
    Duration = 5,
    Type = "success"
})

-- ═══ CLEANUP AU FERMETURE (V4 ROBUSTE) ═══
game:BindToClose(function()
    local O = getgenv()._BloxStrikeOriginals
    local rs = game:GetService("ReplicatedStorage")
    local skinMod = rs.Components.Common:FindFirstChild("GetResolvedSkinInformation")
    if skinMod then
        local mod = require(skinMod)
        local lib = debug.getupvalue(mod, 1)
        if type(lib) == "table" then
            for _, n in ipairs({"GetCameraModel", "GetCharacterModel", "GetGloves"}) do
                if O and O[n] then
                    lib[n] = O[n]
                    if restorefunction then
                        pcall(restorefunction, O[n])
                    end
                elseif restorefunction and lib[n] then
                    pcall(restorefunction, lib[n])
                end
            end
        end
    end
    if getgenv().BloxStrike_ApplyKnifeAnimations then
        pcall(getgenv().BloxStrike_ApplyKnifeAnimations, "Default")
    end
    getgenv()._BloxStrikeOriginals = nil
end)



