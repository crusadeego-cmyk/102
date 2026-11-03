--[[
    NOTHING HUB V2
    Made by Hamdan
    500 actions | search | paged lists (no lag) | themes | HUD tools

    For your own Roblox Studio game.
    Place this single LocalScript in StarterPlayer > StarterPlayerScripts.

    Everything is client-side (local to the player). Server-wide effects
    need server-side code.
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("NOTHING_HUB_V2")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NOTHING_HUB_V2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

----------------------------------------------------------------------
-- Core helpers
----------------------------------------------------------------------
local conns = {}
local function bind(signal, fn) local c = signal:Connect(fn); table.insert(conns, c); return c end

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local palette = {
    {"Red", rgb(235, 64, 52)}, {"Orange", rgb(240, 140, 40)}, {"Yellow", rgb(245, 215, 50)},
    {"Green", rgb(70, 200, 90)}, {"Cyan", rgb(50, 210, 220)}, {"Blue", rgb(60, 110, 235)},
    {"Purple", rgb(150, 80, 225)}, {"Pink", rgb(240, 100, 180)}, {"White", rgb(245, 245, 245)},
    {"Black", rgb(20, 20, 20)}, {"Gray", rgb(130, 130, 135)}, {"Gold", rgb(212, 175, 55)},
    {"Brown", rgb(120, 80, 50)}, {"Teal", rgb(30, 150, 140)},
}

local themes = {
    Default = {bg = rgb(13, 13, 16), panel = rgb(18, 18, 22), item = rgb(32, 32, 39)},
    Black = {bg = rgb(6, 6, 6), panel = rgb(11, 11, 11), item = rgb(24, 24, 24)},
    Purple = {bg = rgb(28, 16, 45), panel = rgb(36, 22, 58), item = rgb(55, 36, 85)},
    Blue = {bg = rgb(11, 24, 44), panel = rgb(15, 32, 58), item = rgb(26, 52, 90)},
    Red = {bg = rgb(40, 12, 16), panel = rgb(52, 16, 22), item = rgb(80, 26, 34)},
    Green = {bg = rgb(11, 32, 20), panel = rgb(15, 42, 27), item = rgb(26, 66, 44)},
    Gray = {bg = rgb(36, 36, 40), panel = rgb(46, 46, 52), item = rgb(66, 66, 74)},
    Midnight = {bg = rgb(8, 10, 26), panel = rgb(12, 15, 36), item = rgb(24, 28, 62)},
    Ocean = {bg = rgb(8, 30, 40), panel = rgb(11, 40, 54), item = rgb(20, 66, 86)},
}
local themeOrder = {"Black", "Purple", "Blue", "Red", "Green", "Gray", "Midnight", "Ocean", "Default"}

local state = {
    speed = 16, jump = 50, flySpeed = 60, slots = {},
    t = {rainbow = true, notify = true, shadows = Lighting.GlobalShadows},
    accent = rgb(235, 235, 240), rainbowSpeed = 0.2, cycle = 0,
    voidY = -100, espColor = palette[1][2], trailColor = palette[5][2], auraColor = palette[3][2],
    crossSize = 12, crossColor = palette[4][2], itemH = 30, notifyTop = true,
    counter = 0, sw = {run = false, start = 0, acc = 0}, theme = "Default",
}

local base = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd, FogColor = Lighting.FogColor, ExposureCompensation = Lighting.ExposureCompensation,
    ColorShift_Top = Lighting.ColorShift_Top,
}
local baseGravity = workspace.Gravity

local function char() return player.Character end
local function hum() local c = char(); return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c = char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function fv(v) return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z) end
local function corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = o; return c end
local function stroke(o, th)
    local s = Instance.new("UIStroke"); s.Color = Color3.new(1, 1, 1); s.Thickness = th or 1.5; s.Parent = o; return s
end

----------------------------------------------------------------------
-- Loading screen
----------------------------------------------------------------------
do
    local ls = Instance.new("Frame")
    ls.Size = UDim2.fromScale(1, 1)
    ls.BackgroundColor3 = rgb(5, 5, 8)
    ls.BorderSizePixel = 0
    ls.ZIndex = 1000
    ls.Parent = gui
    local function lbl(text, y, size, font, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, size + 14)
        l.Position = UDim2.new(0, 0, y, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color
        l.TextSize = size
        l.Font = font
        l.ZIndex = 1001
        l.Parent = ls
    end
    lbl("NOTHING HUB V2", 0.36, 32, Enum.Font.GothamBlack, Color3.new(1, 1, 1))
    lbl("Made by Hamdan", 0.46, 16, Enum.Font.Gotham, rgb(190, 190, 190))
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.3, 0, 0, 5)
    bar.Position = UDim2.new(0.35, 0, 0.56, 0)
    bar.BackgroundColor3 = rgb(45, 45, 50)
    bar.BorderSizePixel = 0
    bar.ZIndex = 1001
    bar.Parent = ls
    corner(bar, 3)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    fill.BorderSizePixel = 0
    fill.ZIndex = 1002
    fill.Parent = bar
    corner(fill, 3)
    TweenService:Create(fill, TweenInfo.new(1.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.6)
    TweenService:Create(ls, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.delay(0.3, function() ls:Destroy() end)
end

----------------------------------------------------------------------
-- Toast notifications
----------------------------------------------------------------------
local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromOffset(260, 34)
toast.BackgroundColor3 = rgb(20, 20, 25)
toast.TextColor3 = Color3.new(1, 1, 1)
toast.TextSize = 12
toast.Font = Enum.Font.GothamBold
toast.ZIndex = 500
toast.Visible = false
toast.TextWrapped = true
toast.Parent = gui
corner(toast, 8)
stroke(toast, 1)
local toastToken = 0
local function notify(msg)
    if not state.t.notify then return end
    toastToken += 1
    local mine = toastToken
    toast.Position = state.notifyTop and UDim2.new(0.5, -130, 0, 70) or UDim2.new(0.5, -130, 1, -70)
    toast.Text = tostring(msg)
    toast.Visible = true
    task.delay(2, function() if mine == toastToken then toast.Visible = false end end)
end

----------------------------------------------------------------------
-- Main window
----------------------------------------------------------------------
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(500, 330)
main.Position = UDim2.new(0.5, -250, 0.5, -165)
main.BackgroundColor3 = themes.Default.bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
corner(main, 12)
local mainStroke = stroke(main, 1.5)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 22)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "N O T H I N G   H U B   V 2"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -110, 0, 14)
credit.Position = UDim2.fromOffset(12, 22)
credit.BackgroundTransparency = 1
credit.Text = "Made by Hamdan  •  500 actions"
credit.TextColor3 = rgb(150, 150, 160)
credit.TextSize = 10
credit.Font = Enum.Font.Gotham
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = titleBar

local function topButton(text, x, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(29, 27)
    b.Position = UDim2.new(1, x, 0, 6)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 18
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 10
    b.Parent = main
    corner(b, 6)
    return b
end
local minBtn = topButton("—", -68, rgb(38, 38, 46))
local closeBtn = topButton("×", -35, rgb(150, 40, 50))

local icon = Instance.new("TextButton")
icon.Size = UDim2.fromOffset(44, 44)
icon.Position = UDim2.new(0, 12, 0.5, -22)
icon.BackgroundColor3 = rgb(8, 8, 8)
icon.Text = "N"
icon.TextColor3 = Color3.new(1, 1, 1)
icon.TextSize = 22
icon.Font = Enum.Font.GothamBlack
icon.Visible = false
icon.ZIndex = 200
icon.Parent = gui
corner(icon, 22)
local iconStroke = stroke(icon, 2)

local function draggable(obj, handle, onTap)
    local dragging, moved, start, startPos, active = false, false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, start, startPos, active = true, false, i.Position, obj.Position, i
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    bind(UIS.InputEnded, function(i)
        if dragging and (i == active or i.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            if onTap and not moved then task.defer(onTap) end
        end
    end)
end
local function minimizeUI() main.Visible = false; icon.Visible = true end
local function reopenUI() icon.Visible = false; main.Visible = true end
draggable(main, titleBar)
draggable(icon, icon, reopenUI)
minBtn.Activated:Connect(minimizeUI)
closeBtn.Activated:Connect(function() gui:Destroy() end)

-- Sidebar
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 112, 1, -50)
sidebar.Position = UDim2.fromOffset(7, 43)
sidebar.BackgroundColor3 = themes.Default.panel
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 2
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.CanvasSize = UDim2.new()
sidebar.Parent = main
corner(sidebar, 8)
do
    local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, 4); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = sidebar
    local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0, 5); p.PaddingLeft = UDim.new(0, 5); p.PaddingRight = UDim.new(0, 5); p.PaddingBottom = UDim.new(0, 5); p.Parent = sidebar
end

-- Search
local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -133, 0, 28)
search.Position = UDim2.fromOffset(126, 43)
search.BackgroundColor3 = themes.Default.item
search.TextColor3 = Color3.new(1, 1, 1)
search.PlaceholderText = "Search 500 actions..."
search.PlaceholderColor3 = rgb(140, 140, 150)
search.Text = ""
search.TextSize = 12
search.Font = Enum.Font.Gotham
search.ClearTextOnFocus = false
search.TextXAlignment = Enum.TextXAlignment.Left
search.Parent = main
corner(search, 7)
do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 10); p.Parent = search end

-- Content
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -133, 1, -114)
content.Position = UDim2.fromOffset(126, 76)
content.BackgroundColor3 = themes.Default.panel
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.Parent = main
corner(content, 8)
do
    local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, 4); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = content
    local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0, 5); p.PaddingLeft = UDim.new(0, 5); p.PaddingRight = UDim.new(0, 5); p.PaddingBottom = UDim.new(0, 5); p.Parent = content
end

-- Pager
local pager = Instance.new("Frame")
pager.Size = UDim2.new(1, -133, 0, 28)
pager.Position = UDim2.new(0, 126, 1, -34)
pager.BackgroundTransparency = 1
pager.Parent = main
local function pagerButton(text, xs, xo)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.25, -4, 1, 0)
    b.Position = UDim2.new(xs, xo, 0, 0)
    b.BackgroundColor3 = themes.Default.item
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = pager
    corner(b, 7)
    return b
end
local prevBtn = pagerButton("◀  Prev", 0, 0)
local nextBtn = pagerButton("Next  ▶", 0.75, 4)
local pageLabel = Instance.new("TextLabel")
pageLabel.Size = UDim2.new(0.5, 0, 1, 0)
pageLabel.Position = UDim2.new(0.25, 0, 0, 0)
pageLabel.BackgroundTransparency = 1
pageLabel.TextColor3 = rgb(190, 190, 200)
pageLabel.TextSize = 11
pageLabel.Font = Enum.Font.Gotham
pageLabel.Parent = pager

-- HUD, crosshair, cinematic bars
local hud = Instance.new("TextLabel")
hud.AnchorPoint = Vector2.new(1, 0)
hud.Position = UDim2.new(1, -10, 0, 10)
hud.AutomaticSize = Enum.AutomaticSize.XY
hud.Size = UDim2.fromOffset(0, 0)
hud.BackgroundColor3 = Color3.new(0, 0, 0)
hud.BackgroundTransparency = 0.45
hud.TextColor3 = Color3.new(1, 1, 1)
hud.TextSize = 13
hud.Font = Enum.Font.GothamMedium
hud.TextXAlignment = Enum.TextXAlignment.Left
hud.Visible = false
hud.ZIndex = 50
hud.Parent = gui
corner(hud, 6)
do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.PaddingRight = UDim.new(0, 8); p.PaddingTop = UDim.new(0, 5); p.PaddingBottom = UDim.new(0, 5); p.Parent = hud end

local cross = Instance.new("Frame")
cross.AnchorPoint = Vector2.new(0.5, 0.5)
cross.Position = UDim2.fromScale(0.5, 0.5)
cross.BackgroundTransparency = 1
cross.Visible = false
cross.ZIndex = 60
cross.Parent = gui
local crossH, crossV = Instance.new("Frame"), Instance.new("Frame")
for _, f in ipairs({crossH, crossV}) do f.AnchorPoint = Vector2.new(0.5, 0.5); f.Position = UDim2.fromScale(0.5, 0.5); f.BorderSizePixel = 0; f.ZIndex = 60; f.Parent = cross end
local function updateCross()
    cross.Size = UDim2.fromOffset(state.crossSize * 2, state.crossSize * 2)
    crossH.Size = UDim2.new(1, 0, 0, 2)
    crossV.Size = UDim2.new(0, 2, 1, 0)
    crossH.BackgroundColor3, crossV.BackgroundColor3 = state.crossColor, state.crossColor
end
updateCross()

local bars = {}
for i = 1, 2 do
    local b = Instance.new("Frame")
    b.Size = UDim2.new(1, 0, 0.12, 0)
    b.Position = i == 1 and UDim2.fromScale(0, 0) or UDim2.fromScale(0, 0.88)
    b.BackgroundColor3 = Color3.new(0, 0, 0)
    b.BorderSizePixel = 0
    b.Visible = false
    b.ZIndex = 40
    b.Parent = gui
    bars[i] = b
end

----------------------------------------------------------------------
-- Registry + paged rendering
----------------------------------------------------------------------
local categories = {"Info", "Movement", "Character", "Camera", "Visuals", "World", "Fun", "Safety", "Tools", "Settings"}
local actions, allActions = {}, {}
for _, c in ipairs(categories) do actions[c] = {} end
local HND = {} -- toggle handlers by key

local function add(cat, name, fn, key)
    local a = {cat = cat, name = name, fn = fn, key = key, search = (cat .. " " .. name):lower()}
    table.insert(actions[cat], a)
    table.insert(allActions, a)
end
local function toggle(cat, name, key)
    add(cat, name, function()
        state.t[key] = not state.t[key]
        local f = HND[key]
        if f then f(state.t[key]) end
        notify(name .. ": " .. (state.t[key] and "ON" or "OFF"))
    end, key)
end

local PAGE = 20
local view = {cat = "Info", query = "", page = 1}
local sideButtons = {}
local render

local function labelFor(a)
    local b = view.query ~= "" and (a.cat .. " › " .. a.name) or a.name
    if a.key then return (state.t[a.key] and "● " or "○ ") .. b end
    return b
end

local function currentList()
    if view.query ~= "" then
        local q, out = view.query:lower(), {}
        for _, a in ipairs(allActions) do
            if a.search:find(q, 1, true) then out[#out + 1] = a end
        end
        return out
    end
    return actions[view.cat]
end

render = function()
    local theme = themes[state.theme]
    for _, c in ipairs(content:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    local list = currentList()
    local pages = math.max(1, math.ceil(#list / PAGE))
    view.page = math.clamp(view.page, 1, pages)
    local from = (view.page - 1) * PAGE + 1
    if #list == 0 then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 30)
        l.BackgroundTransparency = 1
        l.Text = "No results"
        l.TextColor3 = rgb(160, 160, 170)
        l.TextSize = 12
        l.Font = Enum.Font.Gotham
        l.Parent = content
    end
    for i = from, math.min(#list, from + PAGE - 1) do
        local a = list[i]
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, state.itemH)
        b.BackgroundColor3 = theme.item
        b.TextColor3 = rgb(240, 240, 245)
        b.TextSize = 12
        b.Font = Enum.Font.Gotham
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextTruncate = Enum.TextTruncate.AtEnd
        b.Text = labelFor(a)
        b.LayoutOrder = i
        b.Parent = content
        corner(b, 6)
        local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 10); p.Parent = b
        b.Activated:Connect(function()
            local ok, err = pcall(a.fn)
            if not ok then warn("[NOTHING HUB V2] " .. a.name .. ": " .. tostring(err)); notify("Action failed") end
            b.Text = labelFor(a)
        end)
    end
    pageLabel.Text = string.format("Page %d/%d  •  %d items", view.page, pages, #list)
    content.CanvasPosition = Vector2.zero
    for cat, btn in pairs(sideButtons) do
        local sel = view.query == "" and cat == view.cat
        btn.BackgroundColor3 = sel and theme.item:Lerp(Color3.new(1, 1, 1), 0.18) or theme.item
        btn.TextColor3 = sel and Color3.new(1, 1, 1) or rgb(185, 185, 195)
    end
end

for i, cat in ipairs(categories) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.BackgroundColor3 = themes.Default.item
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamMedium
    b.Text = cat
    b.LayoutOrder = i
    b.Parent = sidebar
    corner(b, 6)
    sideButtons[cat] = b
    b.Activated:Connect(function()
        view.cat, view.query, view.page = cat, "", 1
        search.Text = ""
        render()
    end)
end
bind(search:GetPropertyChangedSignal("Text"), function()
    view.query, view.page = search.Text, 1
    render()
end)
prevBtn.Activated:Connect(function() view.page -= 1; render() end)
nextBtn.Activated:Connect(function() view.page += 1; render() end)

local function applyTheme(name)
    state.theme = name
    local th = themes[name]
    main.BackgroundColor3 = th.bg
    sidebar.BackgroundColor3 = th.panel
    content.BackgroundColor3 = th.panel
    search.BackgroundColor3 = th.item
    prevBtn.BackgroundColor3, nextBtn.BackgroundColor3 = th.item, th.item
    render()
end
local function applyAccent()
    if not state.t.rainbow then mainStroke.Color, iconStroke.Color = state.accent, state.accent end
end

----------------------------------------------------------------------
-- Shared utilities
----------------------------------------------------------------------
local function eachPart(fn, deep)
    local c = char()
    if not c then return end
    for _, p in ipairs(deep and c:GetDescendants() or c:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then fn(p) end
    end
end
local orig = setmetatable({}, {__mode = "k"})
local function rememberLook()
    local c = char()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if not orig[p] then
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then orig[p] = {p.Color, p.Material, p.Transparency}
            elseif p:IsA("Decal") then orig[p] = {nil, nil, p.Transparency} end
        end
    end
end
local function restoreLook()
    for p, v in pairs(orig) do
        if p.Parent then
            if p:IsA("BasePart") then p.Color, p.Material = v[1], v[2] end
            p.Transparency = v[3]
        end
    end
end
local function moveBy(v) local c = char(); if c then c:PivotTo(c:GetPivot() + v) end end
local function applyMovement()
    local h = hum()
    if h then h.WalkSpeed = state.speed; h.UseJumpPower = true; h.JumpPower = state.jump end
end
local function flash(color)
    local f = Instance.new("Frame")
    f.Name = "NHV2_Temp"
    f.Size = UDim2.fromScale(1, 1)
    f.BackgroundColor3 = color
    f.BackgroundTransparency = 0.45
    f.BorderSizePixel = 0
    f.ZIndex = 300
    f.Parent = gui
    local tw = TweenService:Create(f, TweenInfo.new(1), {BackgroundTransparency = 1})
    tw:Play()
    tw.Completed:Connect(function() f:Destroy() end)
end
local function confetti(color)
    for _ = 1, 30 do
        local d = Instance.new("Frame")
        d.Name = "NHV2_Temp"
        d.Size = UDim2.fromOffset(7, 7)
        local x = math.random()
        d.Position = UDim2.new(x, 0, -0.05, 0)
        d.BackgroundColor3 = color or Color3.fromHSV(math.random(), 0.8, 1)
        d.BorderSizePixel = 0
        d.ZIndex = 80
        d.Parent = gui
        TweenService:Create(d, TweenInfo.new(1.5 + math.random() * 1.5), {Position = UDim2.new(x, 0, 1.1, 0), Rotation = math.random(0, 360)}):Play()
        task.delay(3.2, function() d:Destroy() end)
    end
end
local function fx(className, name)
    local e = Lighting:FindFirstChild(name)
    if not e then e = Instance.new(className); e.Name = name; e.Parent = Lighting end
    return e
end
local function restoreLighting()
    for k, v in pairs(base) do Lighting[k] = v end
    for _, e in ipairs(Lighting:GetChildren()) do
        if e.Name:sub(1, 5) == "NHV2_" then e:Destroy() end
    end
end
local function attach(name, className, props)
    local r = root()
    if not r then return end
    local o = r:FindFirstChild(name)
    if o then o:Destroy() end
    local i = Instance.new(className)
    i.Name = name
    for k, v in pairs(props or {}) do i[k] = v end
    i.Parent = r
    return i
end
local function detach(name) local r = root(); local o = r and r:FindFirstChild(name); if o then o:Destroy() end end
local function floorRay()
    local r = root()
    if not r then return end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char()}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    return workspace:Raycast(r.Position, Vector3.new(0, -20, 0), rp)
end
local function otherPlayers()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then l[#l + 1] = p end
    end
    return l
end
local function spawnCFrame()
    local s = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    return s and (s.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 10, 0)
end

-- ESP
local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        local e = p.Character and p.Character:FindFirstChild("NHV2_ESP")
        if e then e:Destroy() end
    end
    if not state.t.esp then return end
    for _, p in ipairs(otherPlayers()) do
        local h = Instance.new("Highlight")
        h.Name = "NHV2_ESP"
        h.FillColor = state.espColor
        h.OutlineColor = Color3.new(1, 1, 1)
        h.FillTransparency = 0.5
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = p.Character
    end
end
local function watchPlayer(p)
    bind(p.CharacterAdded, function() task.wait(1); if state.t.esp then refreshESP() end end)
end
for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
bind(Players.PlayerAdded, watchPlayer)

-- Toggle handlers
HND.fly = function(on)
    local r, h = root(), hum()
    if not r or not h then return end
    detach("NHV2_Fly")
    if on then
        attach("NHV2_Fly", "BodyVelocity", {MaxForce = Vector3.new(1e6, 1e6, 1e6), Velocity = Vector3.zero})
        h.PlatformStand = true
    else
        h.PlatformStand = false
    end
end
HND.sprint = function(on) if not on then applyMovement() end end
HND.trail = function(on)
    detach("NHV2_Trail"); detach("NHV2_TA0"); detach("NHV2_TA1")
    if not on then return end
    local a0 = attach("NHV2_TA0", "Attachment", {Position = Vector3.new(0, 1, 0)})
    local a1 = attach("NHV2_TA1", "Attachment", {Position = Vector3.new(0, -1, 0)})
    attach("NHV2_Trail", "Trail", {Attachment0 = a0, Attachment1 = a1, Lifetime = 0.6, Color = ColorSequence.new(state.trailColor), Transparency = NumberSequence.new(0, 1)})
end
HND.sparkles = function(on) detach("NHV2_Sparkles"); if on then attach("NHV2_Sparkles", "Sparkles", {SparkleColor = state.auraColor}) end end
HND.fire = function(on) detach("NHV2_Fire"); if on then attach("NHV2_Fire", "Fire", {Size = 6, Heat = 8}) end end
HND.smoke = function(on) detach("NHV2_Smoke"); if on then attach("NHV2_Smoke", "Smoke", {Size = 4, Opacity = 0.4}) end end
HND.aura = function(on) detach("NHV2_Aura"); if on then attach("NHV2_Aura", "PointLight", {Range = 18, Brightness = 2, Color = state.auraColor}) end end
HND.outline = function(on)
    local c = char()
    if not c then return end
    local o = c:FindFirstChild("NHV2_Self")
    if o then o:Destroy() end
    if on then
        local h = Instance.new("Highlight")
        h.Name = "NHV2_Self"; h.FillTransparency = 1; h.OutlineColor = state.accent; h.Parent = c
    end
end
HND.rainbowChar = function(on) if on then rememberLook() else restoreLook() end end
HND.keepUpright = function(on)
    local h = hum()
    if h then
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not on)
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not on)
    end
end
HND.bars = function(on) for _, b in ipairs(bars) do b.Visible = on end end
HND.crosshair = function(on) cross.Visible = on end
HND.esp = function() refreshESP() end
HND.shadows = function(on) Lighting.GlobalShadows = on end
HND.fullBright = function(on)
    if on then
        Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 3, 14, false
        Lighting.Ambient, Lighting.OutdoorAmbient = rgb(200, 200, 200), rgb(200, 200, 200)
    else
        for _, k in ipairs({"Brightness", "ClockTime", "GlobalShadows", "Ambient", "OutdoorAmbient"}) do Lighting[k] = base[k] end
    end
end
HND.bloom = function(on) local e = fx("BloomEffect", "NHV2_Bloom"); e.Intensity, e.Threshold, e.Size = 1.5, 0.8, 24; e.Enabled = on end
HND.sunrays = function(on) local e = fx("SunRaysEffect", "NHV2_Rays"); e.Intensity = 0.3; e.Enabled = on end
HND.dof = function(on) local e = fx("DepthOfFieldEffect", "NHV2_DOF"); e.FarIntensity, e.FocusDistance, e.InFocusRadius, e.NearIntensity = 0.5, 30, 20, 0; e.Enabled = on end
HND.rainbowSky = function(on) if not on then Lighting.ColorShift_Top = base.ColorShift_Top end end
HND.disco = function(on) if not on then Lighting.Ambient = base.Ambient end end
HND.rainbow = function(on) if not on then applyAccent() end end
local reapplyKeys = {"fly", "trail", "sparkles", "fire", "smoke", "aura", "outline", "keepUpright"}

----------------------------------------------------------------------
-- INFO (25)
----------------------------------------------------------------------
local function hv(prop, fmt)
    local h = hum()
    if not h then return "No character" end
    local v = h[prop]
    return fmt and string.format(fmt, v) or v
end
local info = {
    {"Username", function() return player.Name end},
    {"Display name", function() return player.DisplayName end},
    {"User ID", function() return player.UserId end},
    {"Account age", function() return player.AccountAge .. " days" end},
    {"Membership", function() return player.MembershipType.Name end},
    {"Health", function() return hv("Health", "%.0f") end},
    {"Max health", function() return hv("MaxHealth", "%.0f") end},
    {"Walk speed", function() return hv("WalkSpeed") end},
    {"Jump power", function() return hv("JumpPower") end},
    {"Hip height", function() return hv("HipHeight") end},
    {"Position", function() local r = root(); return r and fv(r.Position) or "No character" end},
    {"Orientation", function() local r = root(); return r and fv(r.Orientation) or "No character" end},
    {"Current speed", function() local r = root(); return r and string.format("%.1f studs/s", r.AssemblyLinearVelocity.Magnitude) or "No character" end},
    {"Place ID", function() return game.PlaceId end},
    {"Game name", function() return game.Name end},
    {"Server ID", function() return game.JobId ~= "" and game.JobId or "Studio session" end},
    {"Player count", function() return #Players:GetPlayers() end},
    {"Session uptime", function() return math.floor(workspace.DistributedGameTime) .. " seconds" end},
    {"Ping", function() local ok, v = pcall(function() return player:GetNetworkPing() * 1000 end); return ok and string.format("%d ms", v) or "Unavailable" end},
    {"Device", function() return (UIS.TouchEnabled and not UIS.KeyboardEnabled) and "Mobile" or "PC / Console" end},
    {"Camera position", function() return fv(workspace.CurrentCamera.CFrame.Position) end},
    {"Field of view", function() return workspace.CurrentCamera.FieldOfView end},
    {"Gravity", function() return workspace.Gravity end},
    {"Time of day", function() return Lighting.TimeOfDay end},
    {"Brightness", function() return Lighting.Brightness end},
}
for _, i in ipairs(info) do add("Info", "Show " .. i[1]:lower(), function() notify(i[1] .. ": " .. tostring(i[2]())) end) end

----------------------------------------------------------------------
-- MOVEMENT (94)
----------------------------------------------------------------------
for _, v in ipairs({0, 8, 16, 20, 24, 32, 40, 50, 60, 75, 100, 150, 200}) do
    add("Movement", "Set speed: " .. v, function() state.speed = v; applyMovement(); notify("Speed: " .. v) end)
end
for _, v in ipairs({0, 25, 50, 75, 100, 125, 150, 200, 300}) do
    add("Movement", "Set jump: " .. v, function() state.jump = v; applyMovement(); notify("Jump: " .. v) end)
end
for _, d in ipairs({1, 5, 10}) do
    add("Movement", "Speed +" .. d, function() state.speed = math.clamp(state.speed + d, 0, 500); applyMovement(); notify("Speed: " .. state.speed) end)
    add("Movement", "Speed -" .. d, function() state.speed = math.clamp(state.speed - d, 0, 500); applyMovement(); notify("Speed: " .. state.speed) end)
end
for _, d in ipairs({5, 10, 25}) do
    add("Movement", "Jump +" .. d, function() state.jump = math.clamp(state.jump + d, 0, 500); applyMovement(); notify("Jump: " .. state.jump) end)
    add("Movement", "Jump -" .. d, function() state.jump = math.clamp(state.jump - d, 0, 500); applyMovement(); notify("Jump: " .. state.jump) end)
end
add("Movement", "Reset speed", function() state.speed = 16; applyMovement(); notify("Speed reset") end)
add("Movement", "Reset jump", function() state.jump = 50; applyMovement(); notify("Jump reset") end)
add("Movement", "Reset speed & jump", function() state.speed, state.jump = 16, 50; applyMovement(); notify("Movement reset") end)
local dirs = {
    {"forward", function(cf) return cf.LookVector end}, {"back", function(cf) return -cf.LookVector end},
    {"left", function(cf) return -cf.RightVector end}, {"right", function(cf) return cf.RightVector end},
    {"up", function() return Vector3.yAxis end}, {"down", function() return -Vector3.yAxis end},
}
for _, d in ipairs(dirs) do
    for _, dist in ipairs({5, 10, 25, 50, 100}) do
        add("Movement", "Teleport " .. d[1] .. " " .. dist, function() local r = root(); if r then moveBy(d[2](r.CFrame) * dist) end end)
    end
end
for i = 1, 5 do
    add("Movement", "Save slot " .. i, function() local c = char(); if c then state.slots[i] = c:GetPivot(); notify("Saved slot " .. i) end end)
    add("Movement", "Go to slot " .. i, function() local c = char(); if c and state.slots[i] then c:PivotTo(state.slots[i]) else notify("Slot " .. i .. " is empty") end end)
end
add("Movement", "Stop movement", function() local r = root(); if r then r.AssemblyLinearVelocity = Vector3.zero end end)
for _, deg in ipairs({45, 90, 180}) do
    add("Movement", "Rotate " .. deg .. " degrees", function() local c = char(); if c then c:PivotTo(c:GetPivot() * CFrame.Angles(0, math.rad(deg), 0)) end end)
end
for _, v in ipairs({50, 100, 200}) do
    add("Movement", "Launch up " .. v, function() local r = root(); if r then local vel = r.AssemblyLinearVelocity; r.AssemblyLinearVelocity = Vector3.new(vel.X, v, vel.Z) end end)
end
for _, v in ipairs({50, 100, 150}) do
    add("Movement", "Dash forward " .. v, function() local r = root(); if r then r.AssemblyLinearVelocity = r.CFrame.LookVector * v + Vector3.new(0, r.AssemblyLinearVelocity.Y, 0) end end)
end
toggle("Movement", "Infinite jump", "infJump")
toggle("Movement", "Noclip", "noclip")
toggle("Movement", "Fly (jump = up)", "fly")
toggle("Movement", "Bunny hop", "bhop")
toggle("Movement", "Sprint boost x1.5", "sprint")
add("Movement", "Fly speed +10", function() state.flySpeed = math.clamp(state.flySpeed + 10, 10, 300); notify("Fly speed: " .. state.flySpeed) end)
add("Movement", "Fly speed -10", function() state.flySpeed = math.clamp(state.flySpeed - 10, 10, 300); notify("Fly speed: " .. state.flySpeed) end)

----------------------------------------------------------------------
-- CHARACTER (58)
----------------------------------------------------------------------
add("Character", "Reset character", function() local h = hum(); if h then h.Health = 0 end end)
add("Character", "Heal fully", function() local h = hum(); if h then h.Health = h.MaxHealth end end)
for _, v in ipairs({1, 10, 25, 50, 75, 100}) do
    add("Character", "Set health: " .. v, function() local h = hum(); if h then h.Health = math.min(v, h.MaxHealth) end end)
end
for _, v in ipairs({50, 100, 200, 500, 1000}) do
    add("Character", "Max health: " .. v, function() local h = hum(); if h then h.MaxHealth = v; h.Health = v end end)
end
add("Character", "Sit", function() local h = hum(); if h then h.Sit = true end end)
add("Character", "Stand", function() local h = hum(); if h then h.Sit = false end end)
add("Character", "Jump now", function() local h = hum(); if h then h.Jump = true end end)
add("Character", "Toggle auto rotate", function() local h = hum(); if h then h.AutoRotate = not h.AutoRotate; notify("Auto rotate: " .. tostring(h.AutoRotate)) end end)
add("Character", "Toggle platform stand", function() local h = hum(); if h then h.PlatformStand = not h.PlatformStand end end)
add("Character", "Toggle name display", function()
    local h = hum()
    if h then h.DisplayDistanceType = h.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None and Enum.HumanoidDisplayDistanceType.Viewer or Enum.HumanoidDisplayDistanceType.None end
end)
for _, v in ipairs({0, 1, 2, 4, 6, 8, 12}) do
    add("Character", "Hip height: " .. v, function() local h = hum(); if h then h.HipHeight = v end end)
end
for _, c in ipairs(palette) do
    add("Character", "Body color: " .. c[1], function() rememberLook(); eachPart(function(p) p.Color = c[2] end, true) end)
end
for _, v in ipairs({0, 0.25, 0.5, 0.75, 1}) do
    add("Character", "Transparency: " .. v, function()
        rememberLook()
        local cc = char()
        if cc then
            for _, p in ipairs(cc:GetDescendants()) do
                if (p:IsA("BasePart") and p.Name ~= "HumanoidRootPart") or p:IsA("Decal") then p.Transparency = v end
            end
        end
    end)
end
add("Character", "Reset look", function() restoreLook(); notify("Look restored") end)
for _, m in ipairs({"Neon", "ForceField", "Glass", "Metal", "Wood", "Plastic"}) do
    add("Character", "Material: " .. m, function() rememberLook(); eachPart(function(p) p.Material = Enum.Material[m] end, true) end)
end
for _, s in ipairs({0.5, 0.75, 1, 1.25, 1.5, 2}) do
    add("Character", "Body scale: " .. s .. "x", function()
        local h, found = hum(), false
        if h then
            for _, n in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}) do
                local v = h:FindFirstChild(n)
                if v then v.Value = s; found = true end
            end
        end
        if not found then notify("R15 scale values not found") end
    end)
end

----------------------------------------------------------------------
-- CAMERA (45)
----------------------------------------------------------------------
local function cam() return workspace.CurrentCamera end
for _, v in ipairs({30, 40, 50, 60, 70, 80, 90, 100, 110, 120}) do
    add("Camera", "FOV: " .. v, function() cam().FieldOfView = v end)
end
for _, d in ipairs({5, 10}) do
    add("Camera", "FOV +" .. d, function() cam().FieldOfView = math.clamp(cam().FieldOfView + d, 20, 120) end)
    add("Camera", "FOV -" .. d, function() cam().FieldOfView = math.clamp(cam().FieldOfView - d, 20, 120) end)
end
add("Camera", "Reset FOV", function() cam().FieldOfView = 70 end)
for _, v in ipairs({10, 25, 50, 100, 200, 400, 1000}) do
    add("Camera", "Max zoom: " .. v, function() player.CameraMaxZoomDistance = v end)
end
for _, v in ipairs({0.5, 5, 10, 20}) do
    add("Camera", "Min zoom: " .. v, function() player.CameraMaxZoomDistance = math.max(player.CameraMaxZoomDistance, v); player.CameraMinZoomDistance = v end)
end
add("Camera", "Camera mode: Classic", function() player.CameraMode = Enum.CameraMode.Classic end)
add("Camera", "Camera mode: First person lock", function() player.CameraMode = Enum.CameraMode.LockFirstPerson end)
add("Camera", "Reset zoom limits", function() player.CameraMinZoomDistance = 0.5; player.CameraMaxZoomDistance = 128 end)
local offsets = {{"Left", Vector3.new(-2, 0, 0)}, {"Right", Vector3.new(2, 0, 0)}, {"Up", Vector3.new(0, 2, 0)}, {"Down", Vector3.new(0, -2, 0)}, {"Back", Vector3.new(0, 0, 3)}, {"Reset", Vector3.zero}}
for _, o in ipairs(offsets) do
    add("Camera", "Camera offset: " .. o[1], function() local h = hum(); if h then h.CameraOffset = o[2] end end)
end
add("Camera", "Reset camera subject", function() local h = hum(); if h then cam().CameraSubject = h end end)
for _, v in ipairs({5, 10, 15, 20, 30}) do
    add("Camera", "Lock zoom: " .. v, function() player.CameraMinZoomDistance = 0.5; player.CameraMaxZoomDistance = v; player.CameraMinZoomDistance = v end)
end
toggle("Camera", "Cinematic bars", "bars")
local specIndex = 0
local function spectate(step)
    local l = otherPlayers()
    if #l == 0 then notify("No other players"); return end
    specIndex = ((specIndex - 1 + step) % #l) + 1
    local p = l[specIndex]
    cam().CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
    notify("Spectating " .. p.Name)
end
add("Camera", "Spectate next player", function() spectate(1) end)
add("Camera", "Spectate previous player", function() spectate(-1) end)
add("Camera", "Stop spectating", function() local h = hum(); if h then cam().CameraSubject = h end end)

----------------------------------------------------------------------
-- VISUALS (61)
----------------------------------------------------------------------
toggle("Visuals", "Full bright", "fullBright")
for _, v in ipairs({0, 0.5, 1, 2, 3, 5}) do
    add("Visuals", "Brightness: " .. v, function() Lighting.Brightness = v end)
end
for _, v in ipairs({-2, -1, 0, 1, 2}) do
    add("Visuals", "Exposure: " .. v, function() Lighting.ExposureCompensation = v end)
end
for i = 1, 12 do
    add("Visuals", "Ambient: " .. palette[i][1], function() Lighting.Ambient = palette[i][2]; Lighting.OutdoorAmbient = palette[i][2] end)
end
add("Visuals", "Reset ambient", function() Lighting.Ambient = base.Ambient; Lighting.OutdoorAmbient = base.OutdoorAmbient end)
for _, v in ipairs({-1, -0.5, 0, 0.5, 1}) do
    add("Visuals", "Saturation: " .. v, function() fx("ColorCorrectionEffect", "NHV2_CC").Saturation = v end)
end
for _, v in ipairs({-0.5, 0, 0.5, 1}) do
    add("Visuals", "Contrast: " .. v, function() fx("ColorCorrectionEffect", "NHV2_CC").Contrast = v end)
end
for i = 1, 8 do
    add("Visuals", "Tint: " .. palette[i][1], function() fx("ColorCorrectionEffect", "NHV2_CC").TintColor = palette[i][2] end)
end
add("Visuals", "Reset color correction", function() local e = Lighting:FindFirstChild("NHV2_CC"); if e then e:Destroy() end end)
for _, v in ipairs({0, 4, 8, 16, 24, 56}) do
    add("Visuals", "Blur: " .. v, function() fx("BlurEffect", "NHV2_Blur").Size = v end)
end
toggle("Visuals", "Bloom", "bloom")
toggle("Visuals", "Sun rays", "sunrays")
toggle("Visuals", "Depth of field", "dof")
add("Visuals", "Disable all post effects", function()
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") then e.Enabled = false end
    end
    for _, k in ipairs({"bloom", "sunrays", "dof"}) do state.t[k] = false end
    notify("Post effects disabled")
end)
toggle("Visuals", "Shadows", "shadows")
toggle("Visuals", "Player ESP", "esp")
for i = 1, 6 do
    add("Visuals", "ESP color: " .. palette[i][1], function() state.espColor = palette[i][2]; refreshESP() end)
end

----------------------------------------------------------------------
-- WORLD (49)
----------------------------------------------------------------------
for h = 0, 23 do
    add("World", string.format("Time: %02d:00", h), function() Lighting.ClockTime = h end)
end
add("World", "Time cycle: slow", function() state.cycle = 0.1; notify("Time cycle: slow") end)
add("World", "Time cycle: fast", function() state.cycle = 1; notify("Time cycle: fast") end)
add("World", "Time cycle: off", function() state.cycle = 0; notify("Time cycle: off") end)
for _, g in ipairs({0, 10, 25, 50, 100, 196.2, 300, 500}) do
    add("World", "Gravity: " .. g, function() workspace.Gravity = g end)
end
for _, v in ipairs({50, 100, 250, 500, 1000, 5000, 100000}) do
    add("World", "Fog distance: " .. v, function() Lighting.FogStart = 0; Lighting.FogEnd = v end)
end
for i = 1, 6 do
    add("World", "Fog color: " .. palette[i][1], function() Lighting.FogColor = palette[i][2] end)
end
add("World", "Remove fog", function() Lighting.FogStart = 0; Lighting.FogEnd = 100000 end)

----------------------------------------------------------------------
-- FUN (62)
----------------------------------------------------------------------
for i = 1, 8 do add("Fun", "Confetti: " .. palette[i][1], function() confetti(palette[i][2]) end) end
add("Fun", "Confetti: Rainbow", function() confetti(nil) end)
add("Fun", "Spin window", function() TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Rotation = main.Rotation + 360}):Play() end)
add("Fun", "Shake window", function()
    local p = main.Position
    task.spawn(function()
        for _ = 1, 8 do main.Position = p + UDim2.fromOffset(math.random(-5, 5), math.random(-5, 5)); task.wait(0.03) end
        main.Position = p
    end)
end)
add("Fun", "Bounce window", function() TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1, true), {Position = main.Position - UDim2.fromOffset(0, 40)}):Play() end)
add("Fun", "Flip window", function() TweenService:Create(main, TweenInfo.new(0.5), {Rotation = main.Rotation + 180}):Play() end)
add("Fun", "Random window color", function() main.BackgroundColor3 = Color3.fromHSV(math.random(), 0.6, 0.2) end)
add("Fun", "Wobble window", function()
    local r0 = main.Rotation
    task.spawn(function()
        for i = 1, 6 do main.Rotation = r0 + (i % 2 == 0 and 3 or -3); task.wait(0.06) end
        main.Rotation = r0
    end)
end)
toggle("Fun", "Spin character", "spin")
toggle("Fun", "Rainbow character", "rainbowChar")
toggle("Fun", "Trail", "trail")
toggle("Fun", "Sparkles", "sparkles")
toggle("Fun", "Fire", "fire")
toggle("Fun", "Smoke", "smoke")
toggle("Fun", "Light aura", "aura")
toggle("Fun", "Self outline", "outline")
for _, e in ipairs({"dance", "dance2", "dance3", "cheer", "laugh", "point", "wave"}) do
    add("Fun", "Emote: " .. e, function() local h = hum(); if h then pcall(function() h:PlayEmote(e) end) end end)
end
for i = 1, 8 do add("Fun", "Screen flash: " .. palette[i][1], function() flash(palette[i][2]) end) end
add("Fun", "Random body color", function() rememberLook(); local c = Color3.fromHSV(math.random(), 0.8, 1); eachPart(function(p) p.Color = c end, true) end)
add("Fun", "Random speed", function() state.speed = math.random(8, 60); applyMovement(); notify("Speed: " .. state.speed) end)
add("Fun", "Random message", function() local m = {"Hello!", "Have fun!", "Nothing Hub V2!", "Keep building!", "Made by Hamdan"}; notify(m[math.random(#m)]) end)
add("Fun", "Random nearby teleport", function() moveBy(Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))) end)
add("Fun", "Coin flip", function() notify(math.random(2) == 1 and "Heads" or "Tails") end)
add("Fun", "Dice roll", function() notify("Dice: " .. math.random(6)) end)
toggle("Fun", "Rainbow sky", "rainbowSky")
toggle("Fun", "Disco lights", "disco")
for i = 1, 8 do
    add("Fun", "Trail color: " .. palette[i][1], function()
        state.trailColor = palette[i][2]
        local t = root() and root():FindFirstChild("NHV2_Trail")
        if t then t.Color = ColorSequence.new(state.trailColor) end
    end)
end
for i = 1, 8 do
    add("Fun", "Aura color: " .. palette[i][1], function()
        state.auraColor = palette[i][2]
        local r = root()
        local l, s = r and r:FindFirstChild("NHV2_Aura"), r and r:FindFirstChild("NHV2_Sparkles")
        if l then l.Color = state.auraColor end
        if s then s.SparkleColor = state.auraColor end
    end)
end

----------------------------------------------------------------------
-- SAFETY (19)
----------------------------------------------------------------------
toggle("Safety", "Anti-void", "antiVoid")
toggle("Safety", "Anti-fling", "antiFling")
toggle("Safety", "Anti-sit", "antiSit")
toggle("Safety", "Auto-heal", "autoHeal")
toggle("Safety", "Lock walk speed", "lockSpeed")
toggle("Safety", "Lock jump power", "lockJump")
toggle("Safety", "Anti-stun", "antiStun")
toggle("Safety", "Keep upright", "keepUpright")
for _, y in ipairs({-50, -100, -250, -500}) do
    add("Safety", "Void height: " .. y, function() state.voidY = y; notify("Void height: " .. y) end)
end
add("Safety", "Teleport to spawn", function() local c = char(); if c then c:PivotTo(spawnCFrame()) end end)
add("Safety", "Clear lighting effects", function() restoreLighting(); workspace.Gravity = baseGravity; notify("Lighting restored") end)
add("Safety", "Clear temporary UI", function() for _, c in ipairs(gui:GetChildren()) do if c.Name == "NHV2_Temp" then c:Destroy() end end end)
add("Safety", "Emergency reset all", function()
    for k, v in pairs(state.t) do
        if v and k ~= "rainbow" and k ~= "notify" then
            state.t[k] = false
            local f = HND[k]
            if f then f(false) end
        end
    end
    restoreLighting(); restoreLook()
    workspace.Gravity = baseGravity
    state.speed, state.jump, state.cycle = 16, 50, 0
    applyMovement()
    notify("Everything reset")
    render()
end)
local platform
add("Safety", "Spawn safety platform", function()
    local r = root()
    if not r then return end
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Name = "NHV2_Platform"
    platform.Anchored = true
    platform.Size = Vector3.new(40, 1, 40)
    platform.Position = r.Position - Vector3.new(0, 4, 0)
    platform.Material = Enum.Material.Neon
    platform.Transparency = 0.5
    platform.Color = state.accent
    platform.Parent = workspace
end)
add("Safety", "Remove safety platform", function() if platform then platform:Destroy(); platform = nil end end)
toggle("Safety", "Low health alert", "healthAlert")

----------------------------------------------------------------------
-- TOOLS (39)
----------------------------------------------------------------------
toggle("Tools", "HUD: FPS", "hudFps")
toggle("Tools", "HUD: Ping", "hudPing")
toggle("Tools", "HUD: Coordinates", "hudPos")
toggle("Tools", "HUD: Clock", "hudClock")
toggle("Tools", "HUD: Speed", "hudSpeed")
toggle("Tools", "HUD: Health", "hudHealth")
toggle("Tools", "Crosshair", "crosshair")
for _, s in ipairs({8, 12, 20}) do add("Tools", "Crosshair size: " .. s, function() state.crossSize = s; updateCross() end) end
for _, i in ipairs({1, 4, 9, 5}) do add("Tools", "Crosshair color: " .. palette[i][1], function() state.crossColor = palette[i][2]; updateCross() end) end
add("Tools", "Rejoin game", function() pcall(function() TeleportService:Teleport(game.PlaceId, player) end) end)
add("Tools", "Print debug status", function() print("[NOTHING HUB V2] active for", player.Name, "| actions:", #allActions); notify("Debug printed") end)
add("Tools", "Print player list", function() for _, p in ipairs(Players:GetPlayers()) do print("[NOTHING HUB V2]", p.Name, p.UserId) end; notify("Players printed") end)
add("Tools", "Print character parts", function() local c = char(); if c then for _, p in ipairs(c:GetChildren()) do print("[NOTHING HUB V2]", p.ClassName, p.Name) end end; notify("Parts printed") end)
add("Tools", "Print lighting values", function()
    print("[NOTHING HUB V2] Brightness", Lighting.Brightness, "ClockTime", Lighting.ClockTime, "Fog", Lighting.FogStart, Lighting.FogEnd)
    notify("Lighting printed")
end)
add("Tools", "Stopwatch: start", function() if not state.sw.run then state.sw.run = true; state.sw.start = os.clock() end; notify("Stopwatch running") end)
add("Tools", "Stopwatch: stop", function()
    if state.sw.run then state.sw.acc += os.clock() - state.sw.start; state.sw.run = false end
    notify(string.format("Stopwatch: %.2fs", state.sw.acc))
end)
add("Tools", "Stopwatch: reset", function() state.sw = {run = false, start = 0, acc = 0}; notify("Stopwatch reset") end)
for _, s in ipairs({10, 30, 60, 300}) do
    local label = s < 60 and (s .. "s") or ((s / 60) .. "m")
    add("Tools", "Countdown " .. label, function()
        notify("Timer started: " .. label)
        task.delay(s, function() notify("Timer finished: " .. label); flash(palette[4][2]) end)
    end)
end
add("Tools", "Counter +1", function() state.counter += 1; notify("Counter: " .. state.counter) end)
add("Tools", "Counter -1", function() state.counter -= 1; notify("Counter: " .. state.counter) end)
add("Tools", "Counter reset", function() state.counter = 0; notify("Counter: 0") end)
add("Tools", "Nearest player distance", function()
    local r = root()
    if not r then return end
    local best, who = math.huge, nil
    for _, p in ipairs(otherPlayers()) do
        local d = (p.Character.HumanoidRootPart.Position - r.Position).Magnitude
        if d < best then best, who = d, p end
    end
    notify(who and string.format("%s: %.1f studs", who.Name, best) or "No other players")
end)
add("Tools", "Show player list", function()
    local n = {}
    for _, p in ipairs(Players:GetPlayers()) do n[#n + 1] = p.Name end
    notify(table.concat(n, ", "))
end)
add("Tools", "Teleport to nearest player", function()
    local r, c = root(), char()
    if not r or not c then return end
    local best, who = math.huge, nil
    for _, p in ipairs(otherPlayers()) do
        local d = (p.Character.HumanoidRootPart.Position - r.Position).Magnitude
        if d < best then best, who = d, p end
    end
    if who then c:PivotTo(who.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)) else notify("No other players") end
end)
add("Tools", "Teleport to random player", function()
    local c, l = char(), otherPlayers()
    if c and #l > 0 then c:PivotTo(l[math.random(#l)].Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)) else notify("No other players") end
end)
add("Tools", "Part under feet: name", function() local h = floorRay(); notify(h and h.Instance:GetFullName() or "Nothing below") end)
add("Tools", "Part under feet: material", function() local h = floorRay(); notify(h and h.Material.Name or "Nothing below") end)
add("Tools", "Teleport: spawn point", function() local c = char(); if c then c:PivotTo(spawnCFrame()) end end)
add("Tools", "Teleport: origin (0, 10, 0)", function() local c = char(); if c then c:PivotTo(CFrame.new(0, 10, 0)) end end)
add("Tools", "Teleport: sky (0, 500, 0)", function() local c = char(); if c then c:PivotTo(CFrame.new(0, 500, 0)) end end)
add("Tools", "Show total action count", function() notify(#allActions .. " actions registered") end)

----------------------------------------------------------------------
-- SETTINGS (48)
----------------------------------------------------------------------
for i = 1, 12 do
    add("Settings", "Accent: " .. palette[i][1], function()
        state.accent = palette[i][2]
        state.t.rainbow = false
        applyAccent()
        render()
    end)
end
for _, n in ipairs(themeOrder) do
    add("Settings", n == "Default" and "Theme: Default (reset)" or ("Theme: " .. n), function() applyTheme(n) end)
end
for _, v in ipairs({0, 0.1, 0.2, 0.3, 0.5}) do
    add("Settings", "Window transparency: " .. v, function() main.BackgroundTransparency = v end)
end
add("Settings", "Window size: Small", function() main.Size = UDim2.fromOffset(440, 300) end)
add("Settings", "Window size: Medium", function() main.Size = UDim2.fromOffset(500, 330) end)
add("Settings", "Window size: Large", function() main.Size = UDim2.fromOffset(580, 380) end)
add("Settings", "Reset window position", function() main.Position = UDim2.new(0.5, -main.Size.X.Offset / 2, 0.5, -main.Size.Y.Offset / 2); main.Rotation = 0 end)
for _, h in ipairs({26, 30, 34, 38, 42}) do
    add("Settings", "Button height: " .. h, function() state.itemH = h; render() end)
end
for _, th in ipairs({0, 1, 2, 3}) do
    add("Settings", "Border thickness: " .. th, function() mainStroke.Thickness = th; iconStroke.Thickness = th end)
end
toggle("Settings", "Rainbow border", "rainbow")
add("Settings", "Rainbow speed: slow", function() state.rainbowSpeed = 0.08 end)
add("Settings", "Rainbow speed: normal", function() state.rainbowSpeed = 0.2 end)
add("Settings", "Rainbow speed: fast", function() state.rainbowSpeed = 0.6 end)
toggle("Settings", "Notifications", "notify")
add("Settings", "Notifications: top", function() state.notifyTop = true; notify("Notifications at top") end)
add("Settings", "Notifications: bottom", function() state.notifyTop = false; notify("Notifications at bottom") end)
add("Settings", "Minimize hub", function() minimizeUI() end)
add("Settings", "Close hub", function() gui:Destroy() end)

----------------------------------------------------------------------
-- Main loops
----------------------------------------------------------------------
local fps, hue, discoT, hudT, alerted = 60, 0, 0, 0, false

bind(RunService.Heartbeat, function(dt)
    fps = fps * 0.9 + (1 / math.max(dt, 0.001)) * 0.1
    hue = (hue + dt * 0.2) % 1
    local t = state.t
    if state.cycle > 0 then Lighting.ClockTime = (Lighting.ClockTime + dt * state.cycle) % 24 end
    if t.rainbowSky then Lighting.ColorShift_Top = Color3.fromHSV(hue, 1, 1) end
    if t.disco then
        discoT += dt
        if discoT > 0.2 then discoT = 0; Lighting.Ambient = Color3.fromHSV(math.random(), 1, 1) end
    end
    local r, h = root(), hum()
    if r and h then
        if t.lockSpeed or t.sprint then h.WalkSpeed = state.speed * (t.sprint and 1.5 or 1) end
        if t.lockJump then h.UseJumpPower = true; h.JumpPower = state.jump end
        if t.bhop and h.FloorMaterial ~= Enum.Material.Air and h.MoveDirection.Magnitude > 0 then h.Jump = true end
        if t.spin then r.CFrame *= CFrame.Angles(0, dt * math.rad(360), 0) end
        if t.rainbowChar then eachPart(function(p) p.Color = Color3.fromHSV(hue, 0.8, 1) end) end
        if t.fly then
            local bv = r:FindFirstChild("NHV2_Fly")
            local c = workspace.CurrentCamera
            if bv and c then
                local look = c.CFrame.LookVector
                local flat = Vector3.new(look.X, 0, look.Z)
                local vel = Vector3.zero
                if flat.Magnitude > 0.01 then
                    flat = flat.Unit
                    local md = h.MoveDirection
                    local right = Vector3.new(flat.Z, 0, -flat.X)
                    vel = (look * md:Dot(flat) + c.CFrame.RightVector * md:Dot(right)) * state.flySpeed
                end
                if h.Jump or UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, state.flySpeed, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0, state.flySpeed, 0) end
                bv.Velocity = vel
            end
        end
        if t.autoHeal and h.Health > 0 and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
        if t.antiStun and not t.fly and h.PlatformStand then h.PlatformStand = false end
        if t.antiSit and h.Sit then h.Sit = false end
        if t.antiFling and not t.fly then
            local v = r.AssemblyLinearVelocity
            if v.Magnitude > 100 then
                r.AssemblyLinearVelocity = Vector3.new(0, math.clamp(v.Y, -50, 50), 0)
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end
        if t.antiVoid and r.Position.Y < state.voidY then
            local c = char()
            if c then c:PivotTo(state.slots[1] or spawnCFrame()) end
        end
        if t.healthAlert then
            local low = h.Health > 0 and h.Health < h.MaxHealth * 0.25
            if low and not alerted then notify("Low health!") end
            alerted = low
        end
    end
    hudT += dt
    if hudT >= 0.25 then
        hudT = 0
        local lines = {}
        if t.hudFps then lines[#lines + 1] = "FPS: " .. math.floor(fps) end
        if t.hudPing then
            local ok, v = pcall(function() return player:GetNetworkPing() * 1000 end)
            lines[#lines + 1] = "Ping: " .. (ok and math.floor(v) or "?") .. " ms"
        end
        if t.hudPos and r then lines[#lines + 1] = "XYZ: " .. fv(r.Position) end
        if t.hudClock then lines[#lines + 1] = os.date("%H:%M:%S") end
        if t.hudSpeed and r then
            local v = r.AssemblyLinearVelocity
            lines[#lines + 1] = string.format("Speed: %.1f", Vector3.new(v.X, 0, v.Z).Magnitude)
        end
        if t.hudHealth and h then lines[#lines + 1] = string.format("Health: %d/%d", h.Health, h.MaxHealth) end
        hud.Text = table.concat(lines, "\n")
        hud.Visible = #lines > 0
    end
end)

bind(RunService.Stepped, function()
    if state.t.noclip then
        local c = char()
        if c then
            for _, p in ipairs(c:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

bind(RunService.RenderStepped, function()
    if state.t.rainbow then
        local col = Color3.fromHSV((os.clock() * state.rainbowSpeed) % 1, 0.9, 1)
        mainStroke.Color, iconStroke.Color = col, col
    end
end)

bind(UIS.JumpRequest, function()
    if state.t.infJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

bind(player.CharacterAdded, function()
    task.wait(0.5)
    applyMovement()
    for _, k in ipairs(reapplyKeys) do
        if state.t[k] and HND[k] then HND[k](true) end
    end
end)

gui.Destroying:Connect(function()
    for _, c in ipairs(conns) do c:Disconnect() end
    pcall(function()
        for _, n in ipairs({"NHV2_Fly", "NHV2_Sparkles", "NHV2_Fire", "NHV2_Smoke", "NHV2_Aura", "NHV2_Trail", "NHV2_TA0", "NHV2_TA1"}) do detach(n) end
        local h = hum()
        if h then h.PlatformStand = false end
    end)
end)

render()
print("[NOTHING HUB V2] Registered actions:", #allActions)
notify("NOTHING HUB V2 loaded - " .. #allActions .. " actions")
