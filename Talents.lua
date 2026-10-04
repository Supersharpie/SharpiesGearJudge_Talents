-- ============================================================================
-- SGJ Talents Plugin: talent build guide for WoW Forever
-- Pick a build; the plugin names the next talent on level-up, highlights it in
-- the talent window, warns when points go off-build, and (optionally) tells
-- Gear Judge which leveling role and level-60 profile the build is for.
-- ============================================================================

local addonName, T = ...
_G.SGJ_Talents = T

local PREFIX = "|cffa335ee[SGJ Talents]|r "
local FIRST_POINT_LEVEL = 10      -- point k of a build is spent at level 9 + k
local UPCOMING_LINES = 5

T.Builds = {}
T.BuildList = {}

-- Builds are registered by Builds.lua. order = { { "Talent Name", count }, ... }
-- in the order the points are spent; it is expanded into one entry per point.
-- An optional respec = { level, name, leveling, endgame, summary, order } is a
-- full re-spend from zero after a talent reset at that level: its first points
-- all land at the respec level, then one per level.
local function Expand(order)
    local points = {}
    for _, step in ipairs(order) do
        for _ = 1, step[2] do table.insert(points, step[1]) end
    end
    return points
end

function T.RegisterBuild(b)
    -- Builds page category: stage raid/leveling/farming, role tank/healer/dps, mode solo/dungeon (leveling only)
    b.stage = b.stage or "leveling"
    b.role = b.role or "dps"
    if b.stage == "leveling" then b.mode = b.mode or "solo" else b.mode = nil end
    b.points = Expand(b.order)
    b.levelOf = function(i) return i + FIRST_POINT_LEVEL - 1 end
    local r = b.respec
    if r then
        -- The first part ends the level before the respec: later points are never spent.
        while #b.points > r.level - FIRST_POINT_LEVEL do table.remove(b.points) end
        r.points = Expand(r.order)
        r.id, r.class, r.parent = b.id, b.class, b
        r.levelOf = function(i) return math.max(r.level, i + FIRST_POINT_LEVEL - 1) end
    end
    T.Builds[b.id] = b
    table.insert(T.BuildList, b)
end

local function Print(msg) print(PREFIX .. msg) end

local function GetMSC() return _G.MSC end

local function IsSupported()
    local MSC = GetMSC()
    return C_Traits and C_Traits.GetNodeInfo and MSC and MSC.ForEachTraitTalent and true or false
end

local function CharKey()
    return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

local function PlayerClass()
    local _, cls = UnitClass("player")
    return cls
end

-- =========================================================================
-- 1. SAVED SETTINGS
-- =========================================================================
local db, charDB

local function InitDB()
    SGJ_TalentsDB = SGJ_TalentsDB or {}
    db = SGJ_TalentsDB
    if db.linkGear == nil then db.linkGear = true end
    if db.remind == nil then db.remind = true end
    if db.showPanel == nil then db.showPanel = true end
    db.chars = db.chars or {}
    db.chars[CharKey()] = db.chars[CharKey()] or {}
    charDB = db.chars[CharKey()]
end

local function GetActiveBuild()
    local id = charDB and charDB.build
    local b = id and T.Builds[id]
    if b and b.class == PlayerClass() then return b end
    return nil
end

local function ClassBuilds()
    local list, cls = {}, PlayerClass()
    for _, b in ipairs(T.BuildList) do
        if b.class == cls then table.insert(list, b) end
    end
    return list
end

-- Build categories, in the order the Builds page and /sgjt list show them:
-- Max Level (Raid) by role, Leveling by role and then Solo / Dungeon, or Farming by role.
local STAGES = { { key = "raid", label = "Max Level (Raid)", short = "Max Level" }, { key = "leveling", label = "Leveling" }, { key = "farming", label = "Farming" } }
local ROLES = { { key = "tank", label = "Tank" }, { key = "healer", label = "Healer" }, { key = "dps", label = "DPS" } }
local MODES = { { key = "solo", label = "Solo" }, { key = "dungeon", label = "Dungeon" } }
local LABEL = {}
for _, t in ipairs({ STAGES, ROLES, MODES }) do for _, c in ipairs(t) do LABEL[c.key] = c.label end end

-- mode is ignored for raid builds; a nil role or mode matches any.
local function InCategory(b, stage, role, mode)
    return b.stage == stage and (role == nil or b.role == role)
        and (stage ~= "leveling" or mode == nil or b.mode == mode)
end

local function CategoryBuilds(stage, role, mode)
    local list = {}
    for _, b in ipairs(ClassBuilds()) do
        if InCategory(b, stage, role, mode) then table.insert(list, b) end
    end
    return list
end

-- "Leveling - DPS - Solo" / "Max Level (Raid) - Tank"
local function CategoryName(stage, role, mode)
    local s = LABEL[stage] .. " - " .. LABEL[role]
    if stage == "leveling" and mode then s = s .. " - " .. LABEL[mode] end
    return s
end

-- =========================================================================
-- 2. READING THE TALENT TREE
-- =========================================================================
-- name -> { rank, max, nodeID, tab }, read through Gear Judge's trait walker.
local function ReadTree()
    local MSC = GetMSC()
    if not (MSC and MSC.ForEachTraitTalent) then return nil end
    local tree = {}
    local ok, found = pcall(MSC.ForEachTraitTalent, function(name, rank, tab, node)
        tree[name] = {
            rank = rank or 0,
            max = node and tonumber(node.maxRanks) or nil,
            nodeID = node and node.ID or nil,
            tab = tab,
        }
    end)
    if not ok or not found then return nil end
    return tree
end

local function GetTraitConfig()
    local configID
    local spec = C_SpecializationInfo
    if spec and spec.GetActiveSpecGroup and spec.GetCombatConfigIDForSpecGroup then
        local ok, group = pcall(spec.GetActiveSpecGroup)
        if ok and group then
            local ok2, id = pcall(spec.GetCombatConfigIDForSpecGroup, group)
            if ok2 then configID = id end
        end
    end
    if not configID and C_ClassTalents and C_ClassTalents.GetActiveConfigID then
        local ok, id = pcall(C_ClassTalents.GetActiveConfigID)
        if ok then configID = id end
    end
    if not configID then return nil end
    local ok, info = pcall(C_Traits.GetConfigInfo, configID)
    return configID, ok and info and info.treeIDs and info.treeIDs[1] or nil
end

-- Unspent talent points: the tree's currency when the client reports it,
-- otherwise one point per level from 10 minus what is spent.
local function GetUnspent(spent)
    local configID, treeID = GetTraitConfig()
    if configID and treeID and C_Traits.GetTreeCurrencyInfo then
        local ok, currencies = pcall(C_Traits.GetTreeCurrencyInfo, configID, treeID, false)
        if ok and type(currencies) == "table" and #currencies > 0 then
            local q = 0
            for _, c in ipairs(currencies) do q = q + (tonumber(c.quantity) or 0) end
            return q
        end
    end
    return math.max(0, (UnitLevel("player") or 0) - (FIRST_POINT_LEVEL - 1) - (spent or 0))
end

-- =========================================================================
-- 3. COMPARING THE TREE WITH A BUILD
-- =========================================================================
-- Returns a status table:
--   nextIndex/nextName/nextRank: the first point of the build not yet spent
--   onTrack: how many of the build's points (in order) are already in place
--   spent, unspent: points spent and still to spend
--   off: talents ranked higher than the whole build ever takes them
function T.Evaluate(build, tree)
    local st = { spent = 0, off = {}, upcoming = {} }
    if not (build and tree) then return st end

    local planned = {}
    for i, name in ipairs(build.points) do
        planned[name] = (planned[name] or 0) + 1
        local have = tree[name] and tree[name].rank or 0
        if have < planned[name] then
            if not st.nextIndex then
                st.nextIndex, st.nextName, st.nextRank = i, name, planned[name]
            end
            if #st.upcoming < UPCOMING_LINES then
                table.insert(st.upcoming, { index = i, name = name, rank = planned[name],
                    max = (tree[name] and tree[name].max) })
            end
        end
    end
    st.onTrack = st.nextIndex and (st.nextIndex - 1) or #build.points

    for name, info in pairs(tree) do
        st.spent = st.spent + info.rank
        local extra = info.rank - (planned[name] or 0)
        if extra > 0 then table.insert(st.off, { name = name, extra = extra }) end
    end
    table.sort(st.off, function(a, b) return a.name < b.name end)
    st.unspent = GetUnspent(st.spent)
    st.complete = st.nextIndex == nil
    return st
end

-- The part of a build the player is on now: the build itself, or its respec
-- once the player is at the respec level and has reset (nothing spent outside
-- the respec's talents). Returns view, respecDue; respecDue means the player
-- is at the respec level but still on the old talents.
-- Points spent in talents a build doesn't take (at those ranks).
function T.OffPoints(st)
    local n = 0
    for _, o in ipairs(st.off) do n = n + o.extra end
    return n
end

-- A player past the respec level is on whichever phase their talents fit
-- better, so a respec that differs from ours by a few points still counts.
function T.ActiveView(b, tree)
    local r = b and b.respec
    if not (r and tree) or (UnitLevel("player") or 0) < r.level then return b, false end
    local off2 = T.OffPoints(T.Evaluate(r, tree))
    if off2 == 0 or off2 < T.OffPoints(T.Evaluate(b, tree)) then return r, false end
    return b, true
end


-- The build whose opening the current talents follow furthest (for a first suggestion).
function T.SuggestBuild(tree)
    local best, bestTrack = nil, 0
    for _, b in ipairs(ClassBuilds()) do
        local st = T.Evaluate(b, tree)
        if #st.off == 0 and st.onTrack > bestTrack then best, bestTrack = b, st.onTrack end
    end
    return best
end

local function TalentLabel(entry, tree)
    local max = entry.max or (tree and tree[entry.name] and tree[entry.name].max)
    if max then return string.format("%s (%d/%d)", entry.name, entry.rank, max) end
    return string.format("%s (rank %d)", entry.name, entry.rank)
end

-- =========================================================================
-- 4. GEAR JUDGE LINK
-- =========================================================================
local function ApplyGearLink()
    local MSC = GetMSC()
    if not (MSC and MSC.SetTalentBuildRole) then return end
    local b = GetActiveBuild()
    if db.linkGear and b then
        local tree = b.respec and ReadTree()
        local view = tree and T.ActiveView(b, tree) or b
        MSC.SetTalentBuildRole(view.leveling, view.endgame)
    else
        MSC.SetTalentBuildRole(nil, nil)
    end
end

-- =========================================================================
-- 5. TALENT WINDOW: HIGHLIGHT + PANEL
-- =========================================================================
local glow, panel
local hookedFrame = false

local function GetTalentsFrame()
    local psf = _G.PlayerSpellsFrame
    return psf and psf.TalentsFrame or nil
end

local function CreateGlow()
    glow = CreateFrame("Frame")
    glow:Hide()
    local tex = glow:CreateTexture(nil, "OVERLAY")
    tex:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    tex:SetBlendMode("ADD")
    tex:SetVertexColor(0.3, 1, 0.3)
    tex:SetPoint("CENTER")
    glow.tex = tex
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.35)
    a:SetDuration(0.7)
    glow.anim = ag
end

local function HideGlow()
    if glow then
        glow:Hide()
        glow.anim:Stop()
    end
end

local function ShowGlowOn(button)
    if not glow then CreateGlow() end
    glow:SetParent(button)
    glow:ClearAllPoints()
    glow:SetAllPoints(button)
    glow:SetFrameLevel((button:GetFrameLevel() or 1) + 10)
    local w = button:GetWidth() or 40
    glow.tex:SetSize(w * 1.9, w * 1.9)
    glow:Show()
    glow.anim:Play()
end

local function FormatOff(off)
    local parts = {}
    for _, o in ipairs(off) do table.insert(parts, o.name .. " +" .. o.extra) end
    return table.concat(parts, ", ")
end

local RefreshPanel -- forward

local function CreatePanel()
    panel = CreateFrame("Frame", "SGJTalentsPanel", UIParent, "BackdropTemplate")
    panel:SetSize(270, 230)
    panel:SetFrameStrata("HIGH")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    if panel.SetBackdrop then
        panel:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 14,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        panel:SetBackdropColor(0.05, 0.05, 0.08, 0.92)
    end

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("SGJ Talent Build")

    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 0, 0)
    close:SetScript("OnClick", function() db.showPanel = false; panel:Hide() end)

    panel.buildName = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.buildName:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    panel.buildName:SetWidth(250)
    panel.buildName:SetJustifyH("LEFT")

    panel.body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.body:SetPoint("TOPLEFT", panel.buildName, "BOTTOMLEFT", 0, -6)
    panel.body:SetWidth(250)
    panel.body:SetJustifyH("LEFT")
    panel.body:SetSpacing(2)

    local change = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    change:SetSize(110, 22)
    change:SetPoint("BOTTOMLEFT", 8, 8)
    change:SetText("Change Build")
    change:SetScript("OnClick", function() panel.picking = not panel.picking; RefreshPanel() end)
    panel.change = change

    -- Build picker: one button per class build, plus "No build"
    panel.pick = {}
    for i = 1, 8 do
        local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btn:SetSize(250, 20)
        btn:SetPoint("TOPLEFT", panel.buildName, "BOTTOMLEFT", 0, -6 - (i - 1) * 22)
        btn:Hide()
        panel.pick[i] = btn
    end
end

local function AnchorPanel()
    local psf = _G.PlayerSpellsFrame
    panel:ClearAllPoints()
    if psf and psf:IsShown() then
        panel:SetPoint("TOPLEFT", psf, "TOPRIGHT", 4, -30)
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 300, 80)
    end
end

function RefreshPanel()
    if not panel then return end
    local b = GetActiveBuild()
    local tree = ReadTree()

    for _, btn in ipairs(panel.pick) do btn:Hide() end
    if panel.picking then
        panel.buildName:SetText("Choose a build:")
        panel.body:SetText("")
        local list = ClassBuilds()
        local n = 0
        for _, cb in ipairs(list) do
            n = n + 1
            local btn = panel.pick[n]
            if not btn then break end
            btn:SetText(cb.name)
            btn:SetScript("OnClick", function() T.SetBuild(cb.id); panel.picking = false; RefreshPanel() end)
            btn:Show()
        end
        if panel.pick[n + 1] then
            local btn = panel.pick[n + 1]
            btn:SetText("No build")
            btn:SetScript("OnClick", function() T.SetBuild(nil); panel.picking = false; RefreshPanel() end)
            btn:Show()
        end
        panel.change:SetText("Back")
        panel:SetHeight(math.max(140, 70 + (n + 1) * 22 + 30))
        return
    end
    panel.change:SetText("Change Build")

    if not b then
        panel.buildName:SetText("|cff999999No build selected|r")
        local hint = "Click Change Build to pick one."
        local suggested = tree and T.SuggestBuild(tree)
        if suggested then hint = "Your talents follow |cffffd100" .. suggested.name .. "|r.\n" .. hint end
        panel.body:SetText(hint)
        panel:SetHeight(110)
        return
    end

    if not tree then
        panel.buildName:SetText("|cffffd100" .. b.name .. "|r")
        panel.body:SetText("Talents could not be read yet.")
        panel:SetHeight(110)
        return
    end

    local view, respecDue = T.ActiveView(b, tree)
    panel.buildName:SetText("|cffffd100" .. view.name .. "|r")
    local st = T.Evaluate(view, tree)
    local lines = {}
    if respecDue then
        table.insert(lines, string.format("|cff00ff00Time to respec:|r reset your talents at a trainer, then follow |cffffd100%s|r.", b.respec.name))
        table.insert(lines, " ")
    elseif b.respec and view == b then
        table.insert(lines, string.format("|cff999999Respec at %d to %s.|r", b.respec.level, b.respec.name))
        table.insert(lines, " ")
    end
    if respecDue then
        -- nothing more to plan on the old talents
    elseif st.complete and b.respec and view == b then
        table.insert(lines, string.format("|cff00ff00Done until %d.|r Then respec to |cffffd100%s|r.", b.respec.level, b.respec.name))
    elseif st.complete then
        table.insert(lines, "|cff00ff00Build complete.|r")
    else
        local unspentText = (st.unspent > 0) and string.format("|cff00ff00%d point%s to spend|r", st.unspent, st.unspent == 1 and "" or "s") or "No unspent points"
        table.insert(lines, string.format("On track: %d / %d   %s", st.onTrack, #view.points, unspentText))
        table.insert(lines, " ")
        table.insert(lines, "|cffffd100Next talents|r")
        for i, u in ipairs(st.upcoming) do
            local color = (i == 1) and "|cff00ff00" or "|cffffffff"
            table.insert(lines, string.format("%sL%d  %s|r", color, view.levelOf(u.index), TalentLabel(u, tree)))
        end
    end
    if #st.off > 0 and not respecDue then
        table.insert(lines, " ")
        table.insert(lines, "|cffff6060Off-build: " .. FormatOff(st.off) .. "|r")
    end
    if view.summary then
        table.insert(lines, " ")
        table.insert(lines, "|cff999999" .. view.summary .. "|r")
    end
    panel.body:SetText(table.concat(lines, "\n"))
    panel:SetHeight(math.max(120, (panel.body:GetStringHeight() or 100) + 80))
end

-- Show/hide the highlight and panel to match the talent window.
local function RefreshTalentWindow()
    if T.RefreshPage then T.RefreshPage() end
    local tf = GetTalentsFrame()
    local shown = tf and tf:IsVisible()

    if panel then
        if shown and db.showPanel then
            AnchorPanel()
            RefreshPanel()
            panel:Show()
        elseif panel.standalone then
            RefreshPanel()
        else
            panel:Hide()
        end
    end

    if not shown then HideGlow(); return end
    local b = GetActiveBuild()
    local tree = b and ReadTree()
    local view, respecDue
    if tree then view, respecDue = T.ActiveView(b, tree) end
    local st = view and not respecDue and T.Evaluate(view, tree)
    local nextInfo = st and st.nextName and tree[st.nextName]
    local button
    if nextInfo and nextInfo.nodeID and tf.GetTalentButtonByNodeID then
        local ok, btn = pcall(tf.GetTalentButtonByNodeID, tf, nextInfo.nodeID)
        if ok then button = btn end
    end
    if button and button:IsVisible() then ShowGlowOn(button) else HideGlow() end
end

local function QueueRefresh()
    if C_Timer and C_Timer.After then
        C_Timer.After(0.1, RefreshTalentWindow)
    else
        RefreshTalentWindow()
    end
end

local function HookTalentWindow()
    if hookedFrame then return end
    local psf = _G.PlayerSpellsFrame
    local tf = GetTalentsFrame()
    if not (psf and tf) then return end
    hookedFrame = true
    if not panel then CreatePanel(); panel:Hide() end
    psf:HookScript("OnShow", QueueRefresh)
    psf:HookScript("OnHide", QueueRefresh)
    tf:HookScript("OnShow", QueueRefresh)
    tf:HookScript("OnHide", QueueRefresh)
    if type(tf.LoadTalentTreeInternal) == "function" then
        pcall(hooksecurefunc, tf, "LoadTalentTreeInternal", QueueRefresh)
    end
    QueueRefresh()
end

-- =========================================================================
-- 6. REMINDERS
-- =========================================================================
local lastOffKey

local function Remind(reason)
    if not db.remind then return end
    local b = GetActiveBuild()
    if not b then return end
    local tree = ReadTree()
    if not tree then return end
    local view, respecDue = T.ActiveView(b, tree)
    if respecDue then
        Print(string.format("Level %d: time to respec. Reset your talents at a trainer, then follow |cffffd100%s|r.", b.respec.level, b.respec.name))
        if reason == "level" and UIErrorsFrame then
            UIErrorsFrame:AddMessage("SGJ: time to respec to " .. b.respec.name, 0.3, 1, 0.3)
        end
        return
    end
    local st = T.Evaluate(view, tree)
    if st.complete or st.unspent <= 0 or not st.nextName then return end
    local nextEntry = st.upcoming[1] or { name = st.nextName, rank = st.nextRank }
    local msg = string.format("Next talent: |cff00ff00%s|r  (%s)", TalentLabel(nextEntry, tree), view.name)
    if reason == "level" and UIErrorsFrame then
        UIErrorsFrame:AddMessage("SGJ: next talent " .. TalentLabel(nextEntry, tree), 0.3, 1, 0.3)
    end
    Print(msg)
end

local function CheckOffBuild()
    local b = GetActiveBuild()
    if not b then lastOffKey = nil; return end
    local tree = ReadTree()
    if not tree then return end
    local view, respecDue = T.ActiveView(b, tree)
    if respecDue then lastOffKey = ""; return end
    local st = T.Evaluate(view, tree)
    local key = FormatOff(st.off)
    if key ~= "" and key ~= lastOffKey and lastOffKey ~= nil then
        Print("|cffff6060Off-build:|r " .. key .. " is not part of " .. view.name .. ".")
    end
    lastOffKey = key
end

-- =========================================================================
-- 7. PUBLIC ACTIONS
-- =========================================================================
function T.SetBuild(id)
    if id and not (T.Builds[id] and T.Builds[id].class == PlayerClass()) then
        Print("Unknown build for your class: " .. tostring(id))
        return
    end
    charDB.build = id
    lastOffKey = nil
    ApplyGearLink()
    if id then
        Print("Build set to |cffffd100" .. T.Builds[id].name .. "|r.")
        CheckOffBuild()
        if lastOffKey and lastOffKey ~= "" then
            Print("|cffff6060Already off-build:|r " .. lastOffKey .. ".")
        end
        Remind("set")
    else
        Print("Build cleared.")
    end
    QueueRefresh()
end

local function FindBuild(arg)
    arg = (arg or ""):lower()
    if arg == "" then return nil end
    for _, b in ipairs(ClassBuilds()) do
        if b.id:lower() == arg or (b.short and b.short:lower() == arg) then return b end
    end
    return nil
end

local function ListBuilds()
    local list = ClassBuilds()
    if #list == 0 then Print("No builds for your class yet."); return end
    local active = GetActiveBuild()
    Print("Builds for your class:")
    for _, st in ipairs(STAGES) do
        for _, ro in ipairs(ROLES) do
            for _, mo in ipairs(st.key == "leveling" and MODES or { {} }) do
                local group = CategoryBuilds(st.key, ro.key, mo.key)
                if #group > 0 then
                    print("  " .. CategoryName(st.key, ro.key, mo.key) .. ":")
                    for _, b in ipairs(group) do
                        local mark = (active and active.id == b.id) and " |cff00ff00(active)|r" or ""
                        print(string.format("     |cffffd100%s|r  %s%s", b.short or b.id, b.name, mark))
                    end
                end
            end
        end
    end
    print("   Use |cffffffff/sgjt set <name>|r, e.g. /sgjt set " .. (list[1].short or list[1].id))
end

local function ShowStandalone()
    if not panel then CreatePanel() end
    db.showPanel = true
    panel.standalone = true
    AnchorPanel()
    RefreshPanel()
    panel:Show()
end

SLASH_SGJTALENTS1 = "/sgjt"
SLASH_SGJTALENTS2 = "/sgjtalents"
SlashCmdList["SGJTALENTS"] = function(msg)
    if not IsSupported() then
        Print("This plugin needs WoW Forever's talent system and Sharpie's Gear Judge.")
        return
    end
    local cmd, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()
    if cmd == "" or cmd == "show" then
        ShowStandalone()
    elseif cmd == "hide" then
        if panel then panel.standalone = false; panel:Hide() end
    elseif cmd == "list" then
        ListBuilds()
    elseif cmd == "set" then
        local b = FindBuild(rest)
        if b then T.SetBuild(b.id) else Print("No build named '" .. rest .. "'. Try /sgjt list.") end
    elseif cmd == "clear" or cmd == "none" then
        T.SetBuild(nil)
    elseif cmd == "next" then
        if not GetActiveBuild() then Print("No build selected. Try /sgjt list.") return end
        local tree = ReadTree()
        if not tree then Print("Talents could not be read yet.") return end
        local view, respecDue = T.ActiveView(GetActiveBuild(), tree)
        if respecDue then Remind("next") return end
        local st = T.Evaluate(view, tree)
        if st.complete and view.respec and view == GetActiveBuild() then
            Print(string.format("Done until %d. Then respec to |cffffd100%s|r.", view.respec.level, view.respec.name)) return
        end
        if st.complete then Print("Build complete.") return end
        Print(string.format("Next talent: |cff00ff00%s|r (on track %d/%d, %d unspent)",
            TalentLabel(st.upcoming[1], tree), st.onTrack, #view.points, st.unspent))
    elseif cmd == "link" then
        db.linkGear = (rest:lower() ~= "off")
        ApplyGearLink()
        Print("Gear Judge follows the build: " .. (db.linkGear and "|cff00ff00on|r" or "|cffff6060off|r"))
    elseif cmd == "remind" then
        db.remind = (rest:lower() ~= "off")
        Print("Level-up reminders: " .. (db.remind and "|cff00ff00on|r" or "|cffff6060off|r"))
    else
        Print("Commands:")
        print("   /sgjt - show the build panel")
        print("   /sgjt list - builds for your class")
        print("   /sgjt set <name> - choose a build")
        print("   /sgjt next - the next talent to take")
        print("   /sgjt clear - no build")
        print("   /sgjt link on|off - Gear Judge weights follow the build")
        print("   /sgjt remind on|off - level-up reminders")
    end
end

-- =========================================================================
-- 7b. PAGE IN THE GEAR JUDGE WINDOW (MSC.RegisterPluginTab)
-- =========================================================================
local page, selectedId
local LIST_BUTTONS = 8
local LIST_TOP = -172      -- the build list starts below the three category rows
local cat                  -- { stage, role, mode } shown on the page

-- Start on the active build's category; otherwise Max Level at 60 (Leveling if the
-- class has no raid builds yet), else
-- Leveling with the role of the class's first leveling build (its Solo Leveling build).
local function DefaultCategory()
    local b = GetActiveBuild()
    if b then return { stage = b.stage, role = b.role, mode = b.mode or "solo" } end
    local stage = ((UnitLevel("player") or 0) >= 60) and "raid" or "leveling"
    if #CategoryBuilds(stage) == 0 then stage = (stage == "raid") and "leveling" or "raid" end
    local role, mode = "dps", "solo"
    for _, x in ipairs(ClassBuilds()) do
        if x.stage == stage then role = x.role; mode = x.mode or "solo"; break end
    end
    return { stage = stage, role = role, mode = mode }
end

-- A readable name for a Gear Judge weight profile key.
local function ProfileLabel(key)
    local MSC = GetMSC()
    local pn = MSC and MSC.CurrentClass and MSC.CurrentClass.PrettyNames
    if not key then return "automatic" end
    if pn then
        if pn[key] then return pn[key] end
        -- A leveling role names its level bands ("Holy: Solo Leveling (21-40)"); use the highest band's
        -- name without the levels, so the label is the same every time (pairs() order isn't).
        local best, bestLo
        for k, v in pairs(pn) do
            local lo = k:match("^" .. key .. "_(%d+)_%d+$")
            lo = tonumber(lo)
            if lo and (not bestLo or lo > bestLo) then best, bestLo = v, lo end
        end
        if best then return (best:gsub("%s*%(%d+%-%d+%)$", "")) end
    end
    return key
end

-- One line per run of points in the same talent: "L10-14  Redoubt 1-5/5".
-- Points already taken are green, the next one gold, later ones grey.
-- Returns two aligned columns: levels and talents (header in the talent column).
local function OrderLines(view, tree, header, stopLevel)
    local lvls, lines = { " " }, { header }
    local counts, nextMarked = {}, false
    local i, n = 1, #view.points
    if stopLevel then
        while n > 0 and view.levelOf(n) >= stopLevel do n = n - 1 end
    end
    while i <= n do
        local name = view.points[i]
        local j = i
        while j < n and view.points[j + 1] == name do j = j + 1 end
        local first = (counts[name] or 0) + 1
        local last = first + (j - i)
        counts[name] = last
        local have = tree and tree[name] and tree[name].rank or 0
        local max = tree and tree[name] and tree[name].max
        local color
        if have >= last then color = "|cff55ff55"
        elseif not nextMarked then color = "|cffffd100"; nextMarked = true
        else color = "|cffaaaaaa" end
        local l1, l2 = view.levelOf(i), view.levelOf(j)
        local lvl = (l1 == l2) and ("L" .. l1) or ("L" .. l1 .. "-" .. l2)
        local ranks = (first == last) and tostring(last) or (first .. "-" .. last)
        table.insert(lvls, color .. lvl .. "|r")
        table.insert(lines, string.format("%s%s %s%s|r", color, name, ranks, max and ("/" .. max) or ""))
        i = j + 1
    end
    return lvls, lines
end

local function UpdatePage()
    if not page then return end
    local active = GetActiveBuild()
    cat = cat or DefaultCategory()
    local list = CategoryBuilds(cat.stage, cat.role, cat.mode)
    local sel = selectedId and T.Builds[selectedId]
    if not (sel and sel.class == PlayerClass() and InCategory(sel, cat.stage, cat.role, cat.mode)) then
        selectedId = (active and InCategory(active, cat.stage, cat.role, cat.mode) and active.id) or (list[1] and list[1].id)
    end
    -- Category buttons: the chosen one stays lit; each shows how many builds it holds.
    for _, btn in ipairs(page.catButtons) do
        local n
        if btn.field == "stage" then n = #CategoryBuilds(btn.key)
        elseif btn.field == "role" then n = #CategoryBuilds(cat.stage, btn.key)
        else n = #CategoryBuilds("leveling", cat.role, btn.key) end
        local grey = n > 0 and "" or "|cff888888"
        if btn.field == "stage" then btn:SetText(grey .. btn.label)  -- three across: no room for a count
        else btn:SetText(string.format("%s%s (%d)", grey, btn.label, n)) end
        if cat[btn.field] == btn.key then btn:LockHighlight() else btn:UnlockHighlight() end
        btn:SetShown(btn.field ~= "mode" or cat.stage == "leveling")
    end
    for k, btn in ipairs(page.list) do
        local b = list[k]
        if b then
            local mark = (active and active.id == b.id) and "|cff00ff00> |r" or ""
            btn:SetText(mark .. b.name)
            btn.id = b.id
            if b.id == selectedId then btn:LockHighlight() else btn:UnlockHighlight() end
            btn:Show()
        else
            btn:Hide()
        end
    end

    local b = selectedId and T.Builds[selectedId]
    if not b then
        page.name:SetText("|cffffd100" .. CategoryName(cat.stage, cat.role, cat.mode) .. "|r")
        page.info:SetText("No builds here for your class yet.")
        page.SetOrder({}, {})
        page.use:Hide(); page.clear:Show(); page.clear:SetEnabled(active ~= nil)
        return
    end
    page.use:Show(); page.clear:Show()
    page.use:SetEnabled(not (active and active.id == b.id))
    page.clear:SetEnabled(active ~= nil)

    local tree = ReadTree()
    local isActive = active and active.id == b.id
    page.name:SetText((isActive and "|cff00ff00Active:|r " or "") .. "|cffffd100" .. b.name .. "|r")

    local info = { "|cff999999" .. CategoryName(b.stage, b.role, b.mode) .. "|r" }
    if b.summary then table.insert(info, b.summary) end
    table.insert(info, " ")
    table.insert(info, "|cffffd100Gear Judge weights:|r " .. ProfileLabel(b.leveling) .. " while leveling, " .. ProfileLabel(b.endgame) .. " at 60.")
    if b.respec then
        table.insert(info, string.format("|cffffd100Respec at %d:|r %s (weights: %s, then %s at 60).",
            b.respec.level, b.respec.name, ProfileLabel(b.respec.leveling), ProfileLabel(b.respec.endgame)))
    end
    if isActive and tree then
        local view, respecDue = T.ActiveView(b, tree)
        local st = T.Evaluate(view, tree)
        table.insert(info, " ")
        if respecDue then
            table.insert(info, "|cff00ff00Time to respec:|r reset your talents at a trainer, then follow " .. b.respec.name .. ".")
        elseif st.complete and b.respec and view == b then
            table.insert(info, string.format("|cff00ff00Done until %d.|r Then respec to %s.", b.respec.level, b.respec.name))
        elseif st.complete then
            table.insert(info, "|cff00ff00Build complete.|r")
        else
            table.insert(info, string.format("On track %d / %d, %d point%s to spend. Next: |cff00ff00%s|r",
                st.onTrack, #view.points, st.unspent, st.unspent == 1 and "" or "s", TalentLabel(st.upcoming[1], tree)))
        end
        if #st.off > 0 and not respecDue then
            table.insert(info, "|cffff6060Off-build: " .. FormatOff(st.off) .. "|r")
        end
    end
    page.info:SetText(table.concat(info, "\n"))

    local lv, tx = OrderLines(b, tree, b.respec and string.format("|cffffd100Talent order to %d|r", b.respec.level - 1) or "|cffffd100Talent order|r", b.respec and b.respec.level)
    if b.respec then
        local lv2, tx2 = OrderLines(b.respec, tree, string.format("|cffffd100After the respec at %d|r", b.respec.level))
        local aL, aT, bL, bT = lv, tx, lv2, tx2
        if (UnitLevel("player") or 0) >= b.respec.level then
            -- Past the respec: the new order matters now, the old one is history.
            aL, aT, bL, bT = lv2, tx2, lv, tx
        end
        lv, tx = {}, {}
        for k = 1, #aL do lv[#lv + 1] = aL[k]; tx[#tx + 1] = aT[k] end
        lv[#lv + 1] = " "; tx[#tx + 1] = " "
        for k = 1, #bL do lv[#lv + 1] = bL[k]; tx[#tx + 1] = bT[k] end
    end
    page.SetOrder(lv, tx)
end
T.RefreshPage = function() if page and page:IsShown() then UpdatePage() end end

-- Layout: categories and build list (left) | build details, buttons, settings (centre) | talent order (right)
local PAGE_LEFT_W, PAGE_RIGHT_W = 236, 300

local function BuildPage(parent)
    page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints()
    page:Hide()

    -- Columns
    local L = CreateFrame("Frame", nil, page)
    L:SetPoint("TOPLEFT"); L:SetPoint("BOTTOMLEFT"); L:SetWidth(PAGE_LEFT_W)
    local R = CreateFrame("Frame", nil, page)
    R:SetPoint("TOPRIGHT"); R:SetPoint("BOTTOMRIGHT"); R:SetWidth(PAGE_RIGHT_W)
    local C = CreateFrame("Frame", nil, page)
    C:SetPoint("TOPLEFT", L, "TOPRIGHT"); C:SetPoint("BOTTOMRIGHT", R, "BOTTOMLEFT")
    for _, col in ipairs({ L, R }) do
        local shade = col:CreateTexture(nil, "BACKGROUND"); shade:SetAllPoints(); shade:SetColorTexture(0, 0, 0, 0.25)
    end
    local function Divider(col, side)
        local t = col:CreateTexture(nil, "BORDER"); t:SetColorTexture(1, 1, 1, 0.08); t:SetWidth(1)
        t:SetPoint("TOP" .. side, 0, 0); t:SetPoint("BOTTOM" .. side, 0, 0)
    end
    Divider(L, "RIGHT"); Divider(R, "LEFT")

    -- ==========================================
    -- LEFT: TITLE, CATEGORIES, BUILD LIST
    -- ==========================================
    local innerW = PAGE_LEFT_W - 24
    local title = L:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText("Talent Builds")
    title:SetTextColor(1, 0.82, 0)

    local sub = L:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    sub:SetText("Pick a build for next-talent reminders, a glow in the talent window, and weights that follow it.")
    sub:SetWidth(innerW); sub:SetJustifyH("LEFT"); sub:SetTextColor(0.7, 0.7, 0.7)

    -- Category rows: stage, then role, then Solo / Dungeon for leveling builds.
    page.catButtons = {}
    local CAT_TOP = -86
    local function CatRow(items, field, y)
        local width = (innerW - (#items - 1) * 4) / #items
        for i, c in ipairs(items) do
            local btn = CreateFrame("Button", nil, L, "UIPanelButtonTemplate")
            btn:SetSize(width, 22)
            btn:SetPoint("TOPLEFT", 12 + (i - 1) * (width + 4), y)
            btn.field, btn.key, btn.label = field, c.key, c.short or c.label
            local fs = btn:GetFontString()
            if fs then fs:SetFontObject("GameFontHighlightSmall") end
            btn:SetScript("OnClick", function(self)
                cat = cat or DefaultCategory()
                cat[self.field] = self.key
                -- Land on a group that has builds: keep the role/mode if it has any, else the first that does.
                if self.field == "stage" and #CategoryBuilds(cat.stage, cat.role) == 0 then
                    for _, r in ipairs(ROLES) do if #CategoryBuilds(cat.stage, r.key) > 0 then cat.role = r.key; break end end
                end
                if cat.stage == "leveling" and self.field ~= "mode" and #CategoryBuilds("leveling", cat.role, cat.mode) == 0 then
                    for _, m in ipairs(MODES) do if #CategoryBuilds("leveling", cat.role, m.key) > 0 then cat.mode = m.key; break end end
                end
                selectedId = nil
                UpdatePage()
            end)
            table.insert(page.catButtons, btn)
        end
    end
    CatRow(STAGES, "stage", CAT_TOP)
    CatRow(ROLES, "role", CAT_TOP - 26)
    CatRow(MODES, "mode", CAT_TOP - 52)

    page.list = {}
    for k = 1, LIST_BUTTONS do
        local btn = CreateFrame("Button", nil, L, "UIPanelButtonTemplate")
        btn:SetSize(innerW, 34)
        btn:SetPoint("TOPLEFT", 12, LIST_TOP - (k - 1) * 38)
        btn:SetScript("OnClick", function(self) selectedId = self.id; UpdatePage() end)
        local fs = btn:GetFontString()
        if fs then
            fs:SetFontObject("GameFontHighlightSmall")
            fs:ClearAllPoints(); fs:SetPoint("LEFT", 10, 0); fs:SetPoint("RIGHT", -8, 0)
            fs:SetJustifyH("LEFT"); fs:SetWordWrap(true); fs:SetMaxLines(2)
        end
        btn:Hide()
        page.list[k] = btn
    end

    -- ==========================================
    -- CENTRE: BUILD DETAILS, USE / CLEAR, SETTINGS
    -- ==========================================
    page.name = C:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    page.name:SetPoint("TOPLEFT", 16, -14)
    page.name:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    page.name:SetJustifyH("LEFT")

    page.info = C:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.info:SetPoint("TOPLEFT", page.name, "BOTTOMLEFT", 0, -8)
    page.info:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    page.info:SetJustifyH("LEFT"); page.info:SetSpacing(3)

    page.use = CreateFrame("Button", nil, C, "UIPanelButtonTemplate")
    page.use:SetSize(140, 24)
    page.use:SetPoint("TOPLEFT", page.info, "BOTTOMLEFT", 0, -16)
    page.use:SetText("Use This Build")
    page.use:SetScript("OnClick", function() if selectedId then T.SetBuild(selectedId) end; UpdatePage() end)

    page.clear = CreateFrame("Button", nil, C, "UIPanelButtonTemplate")
    page.clear:SetSize(70, 24)
    page.clear:SetPoint("LEFT", page.use, "RIGHT", 6, 0)
    page.clear:SetText("Clear")
    page.clear:SetScript("OnClick", function() T.SetBuild(nil); UpdatePage() end)

    -- Settings, pinned to the bottom of the centre column
    local setHdr = C:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setHdr:SetPoint("BOTTOMLEFT", 16, 112)
    setHdr:SetText("Settings")
    local function Toggle(label, key, anchor, onChange)
        local box = CreateFrame("CheckButton", nil, C, "ChatConfigCheckButtonTemplate")
        box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
        box.Text:SetText(label); box.Text:SetTextColor(0.9, 0.9, 0.9)
        box:SetScript("OnShow", function(self) self:SetChecked(db[key]) end)
        box:SetChecked(db[key])
        box:SetScript("OnClick", function(self) db[key] = self:GetChecked() and true or false; if onChange then onChange() end end)
        return box
    end
    local link = Toggle("Weights follow the build", "linkGear", setHdr, ApplyGearLink)
    local rem = Toggle("Level-up reminders", "remind", link)
    Toggle("Panel beside the talent window", "showPanel", rem, QueueRefresh)

    -- ==========================================
    -- RIGHT: TALENT ORDER (scrolls the full height)
    -- ==========================================
    local orderHdr = R:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    orderHdr:SetPoint("TOPLEFT", 12, -14)
    orderHdr:SetText("Talent Order")
    local orderSub = R:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    orderSub:SetPoint("TOPLEFT", orderHdr, "BOTTOMLEFT", 0, -3)
    orderSub:SetText("|cff55ff55Taken|r  |cffffd100Next|r  |cffaaaaaaLater|r")

    -- A level column and a talent column, so they line up.
    local scroll = CreateFrame("ScrollFrame", nil, R, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", orderSub, "BOTTOMLEFT", 0, -10)
    scroll:SetPoint("BOTTOMRIGHT", -30, 12)
    page.orderChild = CreateFrame("Frame", nil, scroll)
    page.orderChild:SetSize(PAGE_RIGHT_W - 42, 400)
    scroll:SetScrollChild(page.orderChild)
    -- One row per talent line (a level cell and a talent cell), so a long talent name can't
    -- push the lines below it away from their levels; it's cut short on its own row instead.
    page.orderRows = {}
    local ROW_H = 15
    function page.SetOrder(lvls, lines)
        for i = 1, math.max(#lines, #page.orderRows) do
            local row = page.orderRows[i]
            if lines[i] then
                if not row then
                    row = CreateFrame("Frame", nil, page.orderChild); row:SetHeight(ROW_H)
                    row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H); row:SetPoint("RIGHT", page.orderChild, "RIGHT", 0, 0)
                    row.Lvl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.Lvl:SetPoint("LEFT", 0, 0); row.Lvl:SetWidth(52); row.Lvl:SetJustifyH("LEFT"); row.Lvl:SetWordWrap(false)
                    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.Text:SetPoint("LEFT", 56, 0); row.Text:SetPoint("RIGHT", 0, 0); row.Text:SetJustifyH("LEFT"); row.Text:SetWordWrap(false)
                    page.orderRows[i] = row
                end
                row.Lvl:SetText(lvls[i] or ""); row.Text:SetText(lines[i]); row:Show()
            elseif row then
                row:Hide()
            end
        end
        page.orderChild:SetHeight(math.max(1, #lines * ROW_H + 10))
    end
    -- The scroll area's width comes from the window; the rows stretch with it.
    scroll:SetScript("OnSizeChanged", function(_, w)
        if w and w > 120 then page.orderChild:SetWidth(w) end
    end)

    page:SetScript("OnShow", UpdatePage)
    GetMSC().ViewTalents = page
    GetMSC().UpdateTalentsView = UpdatePage
end

local function RegisterPage()
    local MSC = GetMSC()
    if MSC and MSC.RegisterPluginTab then
        MSC.RegisterPluginTab("Talent Builds", "Interface\\Icons\\Ability_Marksmanship", BuildPage, "ViewTalents", "UpdateTalentsView")
    end
end

-- =========================================================================
-- 8. EVENTS
-- =========================================================================
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_LEVEL_UP")
for _, e in ipairs({ "TRAIT_CONFIG_UPDATED", "PLAYER_TALENT_UPDATE", "CHARACTER_POINTS_CHANGED" }) do
    pcall(ev.RegisterEvent, ev, e)
end

local function IsAddOnLoadedSafe(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded(name) end
    if IsAddOnLoaded then return IsAddOnLoaded(name) end
    return false
end

ev:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            InitDB()
        elseif arg1 == "Blizzard_PlayerSpells" and IsSupported() then
            HookTalentWindow()
        end
    elseif event == "PLAYER_LOGIN" then
        if not IsSupported() then return end
        ApplyGearLink()
        RegisterPage()
        if IsAddOnLoadedSafe("Blizzard_PlayerSpells") then HookTalentWindow() end
        if C_Timer and C_Timer.After then
            C_Timer.After(5, function()
                CheckOffBuild()
                Remind("login")
                if not GetActiveBuild() and (UnitLevel("player") or 0) >= FIRST_POINT_LEVEL and #ClassBuilds() > 0 and not charDB.hinted then
                    charDB.hinted = true
                    Print("Pick a talent build with |cffffffff/sgjt|r to get next-talent reminders and highlights.")
                end
            end)
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if C_Timer and C_Timer.After then
            C_Timer.After(1.5, function() ApplyGearLink(); Remind("level"); QueueRefresh() end)
        end
    else
        -- Talent changes: the tree is re-read on demand; check for off-build points.
        if not IsSupported() then return end
        if C_Timer and C_Timer.After then
            C_Timer.After(0.2, function() ApplyGearLink(); CheckOffBuild(); QueueRefresh() end)
        end
    end
end)
