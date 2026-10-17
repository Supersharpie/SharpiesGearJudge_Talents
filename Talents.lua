-- ============================================================================
-- SGJ Talents Plugin: talent build guide for WoW Forever
-- Pick a build; the plugin names the next talent on level-up, highlights it in
-- the talent window, warns when points go off-build, and (optionally) tells
-- Gear Judge which leveling role and level-60 profile the build is for.
-- ============================================================================

local addonName, T = ...
_G.SGJ_Talents = T
local L = (_G.MSC and _G.MSC.L) or setmetatable({}, { __index = function(t, k) return k end })

local PREFIX = "|cffa335ee[SGJ Talents]|r "
-- A build's display name; class-specific wording first (see MSC.ClassL in the core).
local function BuildName(b)
    local MSC = _G.MSC
    if MSC and MSC.ClassL then return MSC.ClassL(b.class, b.name) end
    return L[b.name]
end

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
    -- Builds page category: stage raid/leveling/farming/pvp, role tank/healer/dps, mode solo/dungeon (leveling only)
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

-- Full name (WoW Forever names have two parts; UnitName gives only the first).
local function CharKey()
    local MSC = _G.MSC
    if MSC and MSC.GetPlayerKey and MSC.GetCharacterName then return MSC:GetPlayerKey() end
    return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

-- The pre-fix key (first name only), so an existing build choice carries over once.
local function LegacyCharKey()
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

-- Dual Specialization: each spec group has its own build (charDB.builds[group]).
-- ctxGroup is the spec being shown or worked on (the talent window's tab, the
-- Builds page's spec switch); nil means the active spec.
local ctxGroup
local function ActiveGroup()
    local MSC = GetMSC()
    return (MSC and MSC.GetActiveSpecGroup and MSC.GetActiveSpecGroup()) or 1
end
local function HasDualSpec()
    local MSC = GetMSC()
    return (MSC and MSC.HasDualSpec and MSC.HasDualSpec()) and true or false
end
local function CtxGroup() return ctxGroup or ActiveGroup() end
local function SpecName(g)
    local MSC = GetMSC()
    return (MSC and MSC.SpecGroupName and MSC.SpecGroupName(g)) or tostring(g)
end
-- Runs fn(...) with ctxGroup = g (restored also on error).
local function InGroup(g, fn, ...)
    local old = ctxGroup
    ctxGroup = g
    local res = { pcall(fn, ...) }
    ctxGroup = old
    if not res[1] then error(res[2], 0) end
    return unpack(res, 2)
end
-- The builds chosen per spec group; the old single choice moves to the spec
-- the character is in.
local function Builds()
    if not charDB then return {} end
    if not charDB.builds then
        charDB.builds = {}
        if charDB.build then charDB.builds[ActiveGroup()] = charDB.build end
        charDB.build = nil
    end
    return charDB.builds
end

local function InitDB()
    SGJ_TalentsDB = SGJ_TalentsDB or {}
    db = SGJ_TalentsDB
    if db.linkGear == nil then db.linkGear = true end
    if db.remind == nil then db.remind = true end
    if db.showPanel == nil then db.showPanel = true end
    db.chars = db.chars or {}
    local key, legacy = CharKey(), LegacyCharKey()
    if not db.chars[key] and legacy ~= key and db.chars[legacy] then
        -- copy the choice saved under the old first-name key (several characters may share it)
        local copy = {}
        for k, v in pairs(db.chars[legacy]) do copy[k] = v end
        db.chars[key] = copy
    end
    db.chars[key] = db.chars[key] or {}
    charDB = db.chars[key]
end

-- The build chosen for a spec group (default: the one in context).
local function GetActiveBuild(group)
    local id = Builds()[group or CtxGroup()]
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
-- Max Level (Raid) by role, Leveling by role and then Solo / Dungeon, Farming by role, or PvP by
-- role (a PvP build runs from 10 to 60). w is the stage button's width on the Builds page.
local STAGES = { { key = "raid", label = "Max Level (Raid)", short = "Max Level", w = 66 }, { key = "leveling", label = "Leveling", w = 56 },
    { key = "farming", label = "Farming", w = 52 }, { key = "pvp", label = "PvP", w = 26 } }
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
    local s = L[LABEL[stage]] .. " - " .. L[LABEL[role]]
    if stage == "leveling" and mode then s = s .. " - " .. L[LABEL[mode]] end
    return s
end

-- =========================================================================
-- 2. READING THE TALENT TREE
-- =========================================================================
-- Builds name talents in English; the game reports them in the player's language.
-- Nodes are matched by spellID first (T.TalentIDs in Builds.lua, from the client's
-- trait tables): two talents that share a translated name (ptBR Arcane Concentration /
-- Arcane Focus) stay apart. Only a node whose spellID is missing or unknown falls back
-- to its translated name, mapped back to English from the player's own class builds.
local englishName, idName  -- translated name -> English (false = ambiguous); spellID -> English

local function BuildNameMaps()
    englishName, idName = {}, {}
    local ids = T.TalentIDs and T.TalentIDs[PlayerClass()] or {}
    for name, sid in pairs(ids) do idName[sid] = name end
    for _, b in ipairs(ClassBuilds()) do
        for _, list in ipairs({ b.points or {}, (b.respec and b.respec.points) or {} }) do
            for _, n in ipairs(list) do
                local loc = L[n]
                if englishName[loc] == nil or englishName[loc] == n then englishName[loc] = n
                else englishName[loc] = false end  -- two of the class's talents share this name
            end
        end
    end
end

local function GetTraitConfig(group)
    group = group or CtxGroup()
    local configID
    local spec = C_SpecializationInfo
    if spec and spec.GetCombatConfigIDForSpecGroup then
        local ok2, id = pcall(spec.GetCombatConfigIDForSpecGroup, group)
        if ok2 then configID = id end
    end
    if not configID and group == ActiveGroup() and C_ClassTalents and C_ClassTalents.GetActiveConfigID then
        local ok, id = pcall(C_ClassTalents.GetActiveConfigID)
        if ok then configID = id end
    end
    if not configID then return nil end
    local ok, info = pcall(C_Traits.GetConfigInfo, configID)
    return configID, ok and info and info.treeIDs and info.treeIDs[1] or nil
end

-- The spellID of a node's chosen entry (entry -> definition -> spellID), cached per entry.
local entrySpell = {}
local function NodeSpellID(configID, node)
    if not (configID and node and C_Traits and C_Traits.GetEntryInfo and C_Traits.GetDefinitionInfo) then return nil end
    local entryID = (node.activeEntry and node.activeEntry.entryID) or (node.entryIDs and node.entryIDs[1])
    if not entryID then return nil end
    if entrySpell[entryID] ~= nil then return entrySpell[entryID] or nil end
    local sid = false
    local ok, entry = pcall(C_Traits.GetEntryInfo, configID, entryID)
    if ok and type(entry) == "table" and entry.definitionID then
        local okDef, def = pcall(C_Traits.GetDefinitionInfo, entry.definitionID)
        if okDef and type(def) == "table" and tonumber(def.spellID) then sid = tonumber(def.spellID) end
    end
    entrySpell[entryID] = sid
    return sid or nil
end

-- name -> { rank, max, nodeID, tab }, read through Gear Judge's trait walker.
-- Names are the builds' English names; a talent no build of the class takes keeps
-- the game's name. The result is cached until talents change (MarkTreeDirty);
-- callers must not modify it.
-- One cached tree per spec group (default: the one in context).
local cachedTree = {}

local function MarkTreeDirty() wipe(cachedTree) end

local function ReadTree(group)
    group = group or CtxGroup()
    if cachedTree[group] then return cachedTree[group] end
    local MSC = GetMSC()
    if not (MSC and MSC.ForEachTraitTalent) then return nil end
    if not idName then BuildNameMaps() end
    local configID = GetTraitConfig(group)
    local tree, byName = {}, {}
    local function Info(rank, tab, node)
        return { rank = rank or 0, max = node and tonumber(node.maxRanks) or nil, nodeID = node and node.ID or nil, tab = tab }
    end
    local ok, found = pcall(MSC.ForEachTraitTalent, function(name, rank, tab, node)
        local sid = NodeSpellID(configID, node)
        local eng = sid and idName[sid]
        if eng then
            tree[eng] = Info(rank, tab, node)
        else
            table.insert(byName, { name = name, rank = rank, tab = tab, node = node })
        end
    end, group)
    if not ok or not found then return nil end
    -- Nodes the ids didn't place: by translated name, unless that talent was already
    -- found by id or the name is ambiguous; otherwise under the game's own name.
    for _, n in ipairs(byName) do
        local eng = englishName[n.name]
        local key = (eng and not tree[eng]) and eng or n.name
        local old = tree[key]
        if old then old.rank = old.rank + (n.rank or 0)  -- same name twice: keep the points counted
        else tree[key] = Info(n.rank, n.tab, n.node) end
    end
    cachedTree[group] = tree
    return tree
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
--   nextOf[name]: the build step (1 = first point) of that talent's next unspent rank
--   onTrack: how many of the build's points (in order) are already in place
--   spent, unspent: points spent and still to spend
--   off: talents ranked higher than the whole build ever takes them
function T.Evaluate(build, tree)
    local st = { spent = 0, off = {}, upcoming = {}, nextOf = {} }
    if not (build and tree) then return st end

    local planned = {}
    for i, name in ipairs(build.points) do
        planned[name] = (planned[name] or 0) + 1
        local have = tree[name] and tree[name].rank or 0
        if have < planned[name] then
            if not st.nextOf[name] then st.nextOf[name] = i end
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
    if max then return string.format("%s (%d/%d)", L[entry.name], entry.rank, max) end
    return string.format(L["%s (rank %d)"], L[entry.name], entry.rank)
end

-- =========================================================================
-- 4. GEAR JUDGE LINK
-- =========================================================================
-- The weights role a spec group's build asks for: leveling, endgame, pvp.
local function BuildRole(group)
    local b = GetActiveBuild(group)
    if not (db and db.linkGear and b) then return nil end
    local tree = b.respec and ReadTree(group)
    local view = tree and T.ActiveView(b, tree) or b
    return view.leveling, view.endgame, b.stage == "pvp"
end

local function ApplyGearLink()
    local MSC = GetMSC()
    if not (MSC and MSC.SetTalentBuildRole) then return end
    -- Gear Judge asks for the other spec's build when it scores that spec.
    MSC.GetTalentBuildRoleForGroup = function(group)
        local lev, endg, pvp = BuildRole(group)
        if not (lev or endg) then return nil end
        return { leveling = lev, endgame = endg, pvp = pvp or nil }
    end
    local ag = ActiveGroup()
    local b = GetActiveBuild(ag)
    if db.linkGear and b then
        local tree = b.respec and ReadTree(ag)
        local view = tree and T.ActiveView(b, tree) or b
        -- PvP builds also turn on the PvP weight model (at every level).
        MSC.SetTalentBuildRole(view.leveling, view.endgame, b.stage == "pvp")
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
    -- Gold, not green: learnable nodes already have green borders. Two stacked
    -- ADD layers so it stays bright against the tree art.
    glow.texs = {}
    for i = 1, 2 do
        local tex = glow:CreateTexture(nil, "OVERLAY")
        tex:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(1, 0.82, 0)
        tex:SetPoint("CENTER")
        glow.texs[i] = tex
    end
    local ag = glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.6)
    a:SetDuration(0.6)
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
    for _, tex in ipairs(glow.texs) do tex:SetSize(w * 2, w * 2) end
    glow:Show()
    glow.anim:Play()
end

-- Order badges: on every node the build still puts points in, the build step
-- (1 to 51) of its next point, top-left of the button (the rank count sits
-- bottom-right). As ranks are learned each badge moves on to the next step.
local badges = {}
-- Buttons carrying a badge get btn.sgjSteps: every step of that talent in the
-- build (learned ones greyed), added to the button's tooltip. The tree pools
-- its buttons, so the tags are cleared on each refresh.
local tagged, hookedButtons = {}, {}

local function HideBadges()
    for _, bd in ipairs(badges) do bd:Hide() end
    for btn in pairs(tagged) do btn.sgjSteps = nil end
    wipe(tagged)
end

local function AddStepsToTooltip(btn)
    if not (btn.sgjSteps and GameTooltip:IsOwned(btn)) then return end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["SGJ build steps:"], 1, 0.82, 0)
    GameTooltip:AddLine(btn.sgjSteps, 1, 1, 1, true)
    GameTooltip:Show()
end

-- "1 (L10), 2 (L11)" for every point the build puts in this talent; ranks
-- already learned are grey.
local function StepsText(view, name, have)
    local parts, rank = {}, 0
    for i, n in ipairs(view.points) do
        if n == name then
            rank = rank + 1
            local s = string.format("%d (%s)", i, string.format(L["L%d"], view.levelOf(i)))
            if rank <= have then s = "|cff808080" .. s .. "|r" end
            table.insert(parts, s)
        end
    end
    return table.concat(parts, ", ")
end

local function Badge(i)
    local bd = badges[i]
    if not bd then
        bd = CreateFrame("Frame")
        bd:SetSize(18, 16)
        local bg = bd:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.8)
        bd.text = bd:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bd.text:SetPoint("CENTER", 0, 0)
        bd.text:SetTextColor(1, 0.82, 0)
        badges[i] = bd
    end
    return bd
end

local function ShowBadges(tf, st, tree, view)
    HideBadges()
    if not (st and tf.GetTalentButtonByNodeID) then return end
    local n = 0
    for name, step in pairs(st.nextOf) do
        local info = tree[name]
        local ok, btn = false, nil
        if info and info.nodeID then ok, btn = pcall(tf.GetTalentButtonByNodeID, tf, info.nodeID) end
        if ok and btn and btn:IsVisible() then
            n = n + 1
            local bd = Badge(n)
            bd:SetParent(btn)
            bd:ClearAllPoints()
            bd:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 4)
            bd:SetFrameLevel((btn:GetFrameLevel() or 1) + 12)
            bd.text:SetText(step)
            bd:SetWidth(math.max(18, (bd.text:GetStringWidth() or 8) + 8))
            bd:Show()
            btn.sgjSteps = StepsText(view, name, info.rank or 0)
            tagged[btn] = true
            if not hookedButtons[btn] then
                hookedButtons[btn] = true
                btn:HookScript("OnEnter", AddStepsToTooltip)
            end
        end
    end
end

local function FormatOff(off)
    local parts = {}
    for _, o in ipairs(off) do table.insert(parts, L[o.name] .. " +" .. o.extra) end
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
    -- Once dragged, the panel stays where the player put it until the talent window is reopened.
    panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); self.userMoved = true end)
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
    title:SetText(L["SGJ Talent Build"])
    panel.title = title

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
    change:SetText(L["Change Build"])
    change:SetScript("OnClick", function() panel.picking = not panel.picking; RefreshPanel() end)
    panel.change = change

    -- Build picker: one button per class build, plus "No build" (made as needed, see PickButton)
    panel.pick = {}
end

local PICK_STEP = 22
local function PickButton(i)
    local btn = panel.pick[i]
    if not btn then
        btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        btn:SetSize(250, 20)
        btn:SetPoint("TOPLEFT", panel.buildName, "BOTTOMLEFT", 0, -6 - (i - 1) * PICK_STEP)
        btn:Hide()
        panel.pick[i] = btn
    end
    return btn
end

local function AnchorPanel()
    if panel.userMoved then return end
    local psf = _G.PlayerSpellsFrame
    panel:ClearAllPoints()
    if psf and psf:IsShown() then
        panel:SetPoint("TOPLEFT", psf, "TOPRIGHT", 4, -30)
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 300, 80)
    end
end

-- The spec group shown in the talent window (its Primary / Secondary tab).
local function ViewGroup()
    local tf = GetTalentsFrame()
    if tf and tf:IsVisible() and tf.GetTab and tf.secondarySpecTabID then
        local ok, tab = pcall(tf.GetTab, tf)
        if ok and tab == tf.secondarySpecTabID then return 2 end
        if ok and tab == tf.primarySpecTabID then return 1 end
    end
    return ActiveGroup()
end

local function RefreshPanelIn()
    if not panel then return end
    if panel.title then
        panel.title:SetText(HasDualSpec() and string.format(L["SGJ Talent Build (%s)"], SpecName(CtxGroup())) or L["SGJ Talent Build"])
    end
    local b = GetActiveBuild()
    local tree = ReadTree()

    for _, btn in ipairs(panel.pick) do btn:Hide() end
    if panel.picking then
        panel.buildName:SetText(L["Choose a build:"])
        panel.body:SetText("")
        local list = ClassBuilds()
        local n = #list
        for i, cb in ipairs(list) do
            local btn = PickButton(i)
            btn:SetText(L[cb.name])
            btn:SetScript("OnClick", function() T.SetBuild(cb.id, ViewGroup()); panel.picking = false; RefreshPanel() end)
            btn:Show()
        end
        local none = PickButton(n + 1)
        none:SetText(L["No build"])
        none:SetScript("OnClick", function() T.SetBuild(nil, ViewGroup()); panel.picking = false; RefreshPanel() end)
        none:Show()
        panel.change:SetText(L["Go Back"])
        panel:SetHeight(math.max(140, 70 + (n + 1) * PICK_STEP + 30))
        return
    end
    panel.change:SetText(L["Change Build"])

    if not b then
        panel.buildName:SetText(L["|cff999999No build selected|r"])
        local hint = L["Click Change Build to pick one."]
        local suggested = tree and T.SuggestBuild(tree)
        if suggested then hint = string.format(L["Your talents follow |cffffd100%s|r."], L[suggested.name]) .. "\n" .. hint end
        panel.body:SetText(hint)
        panel:SetHeight(110)
        return
    end

    if not tree then
        panel.buildName:SetText("|cffffd100" .. BuildName(b) .. "|r")
        panel.body:SetText(L["Talents could not be read yet."])
        panel:SetHeight(110)
        return
    end

    local view, respecDue = T.ActiveView(b, tree)
    panel.buildName:SetText("|cffffd100" .. L[view.name] .. "|r")
    local st = T.Evaluate(view, tree)
    local lines = {}
    if respecDue then
        table.insert(lines, string.format(L["|cff00ff00Time to respec:|r reset your talents at a trainer, then follow |cffffd100%s|r."], L[b.respec.name]))
        table.insert(lines, " ")
    elseif b.respec and view == b then
        table.insert(lines, string.format(L["|cff999999Respec at %d to %s.|r"], b.respec.level, L[b.respec.name]))
        table.insert(lines, " ")
    end
    if respecDue then
        -- nothing more to plan on the old talents
    elseif st.complete and b.respec and view == b then
        table.insert(lines, string.format(L["|cff00ff00Done until %d.|r Then respec to |cffffd100%s|r."], b.respec.level, L[b.respec.name]))
    elseif st.complete then
        table.insert(lines, L["|cff00ff00Build complete.|r"])
    else
        local unspentText = (st.unspent > 0) and string.format(st.unspent == 1 and L["|cff00ff00%d point to spend|r"] or L["|cff00ff00%d points to spend|r"], st.unspent) or L["No unspent points"]
        table.insert(lines, string.format(L["On track: %d / %d   %s"], st.onTrack, #view.points, unspentText))
        table.insert(lines, " ")
        table.insert(lines, L["|cffffd100Next talents|r"])
        for i, u in ipairs(st.upcoming) do
            local color = (i == 1) and "|cff00ff00" or "|cffffffff"
            table.insert(lines, string.format("%s%s  %s|r", color, string.format(L["L%d"], view.levelOf(u.index)), TalentLabel(u, tree)))
        end
    end
    if #st.off > 0 and not respecDue then
        table.insert(lines, " ")
        table.insert(lines, string.format(L["|cffff6060Off-build: %s|r"], FormatOff(st.off)))
    end
    if view.summary then
        table.insert(lines, " ")
        table.insert(lines, "|cff999999" .. L[view.summary] .. "|r")
    end
    panel.body:SetText(table.concat(lines, "\n"))
    panel:SetHeight(math.max(120, (panel.body:GetStringHeight() or 100) + 80))
end

function RefreshPanel() InGroup(ViewGroup(), RefreshPanelIn) end

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

    if not shown then HideGlow(); HideBadges(); return end
    -- The glow follows the tab shown (its talents and its build).
    local vg = ViewGroup()
    local b = GetActiveBuild(vg)
    local tree = b and ReadTree(vg)
    local view, respecDue
    if tree then view, respecDue = T.ActiveView(b, tree) end
    local st = view and not respecDue and InGroup(vg, T.Evaluate, view, tree)
    local nextInfo = st and st.nextName and tree[st.nextName]
    local button
    if nextInfo and nextInfo.nodeID and tf.GetTalentButtonByNodeID then
        local ok, btn = pcall(tf.GetTalentButtonByNodeID, tf, nextInfo.nodeID)
        if ok then button = btn end
    end
    if button and button:IsVisible() then ShowGlowOn(button) else HideGlow() end
    if st then ShowBadges(tf, st, tree, view) else HideBadges() end
end

local refreshPending = false

local function QueueRefresh()
    if C_Timer and C_Timer.After then
        if refreshPending then return end
        refreshPending = true
        C_Timer.After(0.1, function() refreshPending = false; RefreshTalentWindow() end)
    else
        RefreshTalentWindow()
    end
end

-- The talent window reloaded its tree: re-read our copy too.
local function OnTreeLoaded()
    MarkTreeDirty()
    QueueRefresh()
end

local function HookTalentWindow()
    if hookedFrame then return end
    local psf = _G.PlayerSpellsFrame
    local tf = GetTalentsFrame()
    if not (psf and tf) then return end
    hookedFrame = true
    if not panel then CreatePanel(); panel:Hide() end
    psf:HookScript("OnShow", function()
        if panel and not panel.standalone then panel.userMoved = nil end  -- dock beside the window again
        QueueRefresh()
    end)
    psf:HookScript("OnHide", QueueRefresh)
    tf:HookScript("OnShow", QueueRefresh)
    tf:HookScript("OnHide", QueueRefresh)
    if type(tf.LoadTalentTreeInternal) == "function" then
        pcall(hooksecurefunc, tf, "LoadTalentTreeInternal", OnTreeLoaded)
    end
    -- Dual Specialization: switching between the Primary and Secondary tabs.
    if type(tf.SetTab) == "function" then pcall(hooksecurefunc, tf, "SetTab", QueueRefresh) end
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
        Print(string.format(L["Level %d: time to respec. Reset your talents at a trainer, then follow |cffffd100%s|r."], b.respec.level, L[b.respec.name]))
        if reason == "level" and UIErrorsFrame then
            UIErrorsFrame:AddMessage(string.format(L["SGJ: time to respec to %s"], L[b.respec.name]), 0.3, 1, 0.3)
        end
        return
    end
    local st = T.Evaluate(view, tree)
    if st.complete or st.unspent <= 0 or not st.nextName then return end
    local nextEntry = st.upcoming[1] or { name = st.nextName, rank = st.nextRank }
    local msg = string.format(L["Next talent: |cff00ff00%s|r  (%s)"], TalentLabel(nextEntry, tree), L[view.name])
    if reason == "level" and UIErrorsFrame then
        UIErrorsFrame:AddMessage(string.format(L["SGJ: next talent %s"], TalentLabel(nextEntry, tree)), 0.3, 1, 0.3)
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
        Print(string.format(L["|cffff6060Off-build:|r %s is not part of %s."], key, L[view.name]))
    end
    lastOffKey = key
end

-- =========================================================================
-- 7. PUBLIC ACTIONS
-- =========================================================================
-- group: the spec group to set it for (default: the one in context).
function T.SetBuild(id, group)
    if id and not (T.Builds[id] and T.Builds[id].class == PlayerClass()) then
        Print(string.format(L["Unknown build for your class: %s"], tostring(id)))
        return
    end
    group = group or CtxGroup()
    Builds()[group] = id
    ApplyGearLink()
    if HasDualSpec() then
        if id then Print(string.format(L["Build for your %s spec set to |cffffd100%s|r."], SpecName(group), L[T.Builds[id].name]))
        else Print(string.format(L["Build cleared for your %s spec."], SpecName(group))) end
        if group ~= ActiveGroup() then QueueRefresh(); return end
        lastOffKey = nil
        if id then CheckOffBuild(); Remind("set") end
        QueueRefresh()
        return
    end
    lastOffKey = nil
    if id then
        Print(string.format(L["Build set to |cffffd100%s|r."], L[T.Builds[id].name]))
        CheckOffBuild()
        if lastOffKey and lastOffKey ~= "" then
            Print(string.format(L["|cffff6060Already off-build:|r %s."], lastOffKey))
        end
        Remind("set")
    else
        Print(L["Build cleared."])
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
    if #list == 0 then Print(L["No builds for your class yet."]); return end
    local active = GetActiveBuild()
    Print(L["Builds for your class:"])
    for _, st in ipairs(STAGES) do
        for _, ro in ipairs(ROLES) do
            for _, mo in ipairs(st.key == "leveling" and MODES or { {} }) do
                local group = CategoryBuilds(st.key, ro.key, mo.key)
                if #group > 0 then
                    print("  " .. string.format(L["%s:"], CategoryName(st.key, ro.key, mo.key)))
                    for _, b in ipairs(group) do
                        local mark = (active and active.id == b.id) and (" " .. L["|cff00ff00(active)|r"]) or ""
                        print(string.format("     |cffffd100%s|r  %s%s", b.short or b.id, BuildName(b), mark))
                    end
                end
            end
        end
    end
    print("   " .. string.format(L["Use |cffffffff/sgjt set <name>|r, e.g. /sgjt set %s"], list[1].short or list[1].id))
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
        Print(L["This plugin needs WoW Forever's talent system and Sharpie's Gear Judge."])
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
        if b then T.SetBuild(b.id) else Print(string.format(L["No build named '%s'. Try /sgjt list."], rest)) end
    elseif cmd == "clear" or cmd == "none" then
        T.SetBuild(nil)
    elseif cmd == "next" then
        if not GetActiveBuild() then Print(L["No build selected. Try /sgjt list."]) return end
        MarkTreeDirty()
        local tree = ReadTree()
        if not tree then Print(L["Talents could not be read yet."]) return end
        local view, respecDue = T.ActiveView(GetActiveBuild(), tree)
        if respecDue then Remind("next") return end
        local st = T.Evaluate(view, tree)
        if st.complete and view.respec and view == GetActiveBuild() then
            Print(string.format(L["Done until %d. Then respec to |cffffd100%s|r."], view.respec.level, L[view.respec.name])) return
        end
        if st.complete then Print(L["Build complete."]) return end
        Print(string.format(L["Next talent: |cff00ff00%s|r (on track %d/%d, %d unspent)"],
            TalentLabel(st.upcoming[1], tree), st.onTrack, #view.points, st.unspent))
    elseif cmd == "link" then
        db.linkGear = (rest:lower() ~= "off")
        ApplyGearLink()
        Print(string.format(L["Gear Judge follows the build: %s"], db.linkGear and L["|cff00ff00on|r"] or L["|cffff6060off|r"]))
    elseif cmd == "remind" then
        db.remind = (rest:lower() ~= "off")
        Print(string.format(L["Level-up reminders: %s"], db.remind and L["|cff00ff00on|r"] or L["|cffff6060off|r"]))
    else
        Print(L["Commands:"])
        print("   /sgjt - " .. L["show the build panel"])
        print("   /sgjt list - " .. L["builds for your class"])
        print("   /sgjt set " .. L["<name> - choose a build"])
        print("   /sgjt next - " .. L["the next talent to take"])
        print("   /sgjt clear - " .. L["no build"])
        print("   /sgjt link on|off - " .. L["Gear Judge weights follow the build"])
        print("   /sgjt remind on|off - " .. L["level-up reminders"])
    end
end

-- =========================================================================
-- 7b. PAGE IN THE GEAR JUDGE WINDOW (MSC.RegisterPluginTab)
-- =========================================================================
local page, selectedId
local cat                  -- { stage } shown on the page

-- Start on the active build's stage; otherwise Max Level at 60 (Leveling if the
-- class has no raid builds yet), else Leveling.
local function DefaultCategory()
    local b = GetActiveBuild()
    if b then return { stage = b.stage } end
    local stage = ((UnitLevel("player") or 0) >= 60) and "raid" or "leveling"
    if #CategoryBuilds(stage) == 0 then stage = (stage == "raid") and "leveling" or "raid" end
    return { stage = stage }
end

-- A readable name for a Gear Judge weight profile key.
local function ProfileLabel(key)
    local MSC = GetMSC()
    local pn = MSC and MSC.CurrentClass and MSC.CurrentClass.PrettyNames
    if not key then return L["automatic"] end
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

-- ---------------------------------------------------------------------------
-- Talent trees (Builds.lua T.Trees / T.TalentInfo, from the client's tables)
-- ---------------------------------------------------------------------------
-- Tree colours by the tree's English name; a tree not listed takes its slot's colour.
local TREE_COLOR = {
    ["Arms"] = { 0.78, 0.55, 0.32 }, ["Fury"] = { 0.90, 0.30, 0.25 }, ["Protection"] = { 0.35, 0.60, 0.95 },
    ["Holy"] = { 0.95, 0.80, 0.35 }, ["Retribution"] = { 0.90, 0.35, 0.40 },
    ["Beast Mastery"] = { 0.45, 0.80, 0.35 }, ["Marksmanship"] = { 0.35, 0.60, 0.95 }, ["Survival"] = { 0.80, 0.55, 0.30 },
    ["Assassination"] = { 0.45, 0.80, 0.35 }, ["Combat"] = { 0.90, 0.75, 0.30 }, ["Subtlety"] = { 0.55, 0.55, 0.85 },
    ["Discipline"] = { 0.85, 0.85, 0.85 }, ["Shadow"] = { 0.65, 0.45, 0.90 },
    ["Elemental"] = { 0.95, 0.55, 0.25 }, ["Enhancement"] = { 0.35, 0.60, 0.95 }, ["Restoration"] = { 0.40, 0.80, 0.45 },
    ["Arcane"] = { 0.70, 0.50, 0.95 }, ["Fire"] = { 0.95, 0.50, 0.20 }, ["Frost"] = { 0.45, 0.75, 1.00 },
    ["Affliction"] = { 0.45, 0.80, 0.35 }, ["Demonology"] = { 0.70, 0.45, 0.90 }, ["Destruction"] = { 0.90, 0.35, 0.25 },
    ["Balance"] = { 0.55, 0.55, 0.95 }, ["Feral Combat"] = { 0.95, 0.65, 0.25 },
}
local SLOT_COLOR = { { 0.95, 0.80, 0.35 }, { 0.35, 0.60, 0.95 }, { 0.90, 0.35, 0.40 } }
local LOCALE = GetLocale and GetLocale() or "enUS"

local function Trees() return T.Trees and T.Trees[PlayerClass()] or {} end
local function TreeColor(i)
    local t = Trees()[i]
    return (t and TREE_COLOR[t.name]) or SLOT_COLOR[i] or { 0.7, 0.7, 0.7 }
end
local function TreeName(i)
    local t = Trees()[i]
    if not t then return "?" end
    return (t.loc and t.loc[LOCALE]) or t.name
end
-- { tree index, tier, max rank } of a build talent, or nil.
local function TalentInfo(name)
    local c = T.TalentInfo and T.TalentInfo[PlayerClass()]
    return c and c[name]
end
local function TalentIcon(name)
    local ids = T.TalentIDs and T.TalentIDs[PlayerClass()]
    local sid = ids and ids[name]
    if not sid then return nil end
    if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(sid) end
    return GetSpellTexture and GetSpellTexture(sid)
end
-- Points per tree for a build's talents (the respec's, once past the respec level), and its main tree.
local function TreeSplit(b)
    local view = b
    if b.respec and (UnitLevel("player") or 0) >= b.respec.level then view = b.respec end
    local counts, main = { 0, 0, 0 }, 1
    for _, name in ipairs(view.points) do
        local info = TalentInfo(name)
        if info then counts[info[1]] = (counts[info[1]] or 0) + 1 end
    end
    for i = 1, 3 do if counts[i] > counts[main] then main = i end end
    return counts, main
end

-- One row per run of points in the same talent: "L10-14  Redoubt 1-5/5". A run the player
-- is part way through is split, so the points taken show green and the rest gold.
-- Rows: { lvl, text, color, tree, icon, key, isNext } or { header = text }.
local function OrderRows(view, tree, header, stopLevel, rows)
    rows = rows or {}
    table.insert(rows, { header = header })
    local counts, nextMarked = {}, false
    local i, n = 1, #view.points
    if stopLevel then
        while n > 0 and view.levelOf(n) >= stopLevel do n = n - 1 end
    end
    local function Add(name, i1, i2, first, last, color, isNext)
        local info = TalentInfo(name)
        local max = (tree and tree[name] and tree[name].max) or (info and info[3])
        local l1, l2 = view.levelOf(i1), view.levelOf(i2)
        local lvl = (l1 == l2) and string.format(L["L%d"], l1) or string.format(L["L%d-%d"], l1, l2)
        local ranks = (first == last) and tostring(last) or (first .. "-" .. last)
        table.insert(rows, { lvl = lvl, text = string.format("%s %s%s", L[name], ranks, max and ("/" .. max) or ""),
            color = color, tree = info and info[1], icon = TalentIcon(name), key = (max == 1), isNext = isNext })
    end
    while i <= n do
        local name = view.points[i]
        local j = i
        while j < n and view.points[j + 1] == name do j = j + 1 end
        local first = (counts[name] or 0) + 1
        local last = first + (j - i)
        counts[name] = last
        local have = tree and tree[name] and tree[name].rank or 0
        if have >= last then
            Add(name, i, j, first, last, "|cff55ff55", false)
        elseif have >= first and not nextMarked then
            local split = i + (have - first)  -- last point taken
            Add(name, i, split, first, have, "|cff55ff55", false)
            Add(name, split + 1, j, have + 1, last, "|cffffd100", true); nextMarked = true
        elseif not nextMarked then
            Add(name, i, j, first, last, "|cffffd100", true); nextMarked = true
        else
            Add(name, i, j, first, last, "|cffaaaaaa", false)
        end
        i = j + 1
    end
    return rows
end

local UpdatePage -- set below (it wraps UpdatePageIn with the shown spec)
local pageGroup -- the spec the Builds page shows (nil = the active one)

-- Small coloured tags under a build's name: Solo / Dungeon, Fastest, Experimental, % slower.
local function BuildTags(b)
    local tags = {}
    if b.stage == "leveling" and b.mode then
        table.insert(tags, (b.mode == "solo" and "|cff7fb2ff" or "|cffc29bff") .. L[LABEL[b.mode]] .. "|r")
    end
    if b.fastest then table.insert(tags, "|cff55ff55" .. L["Fastest"] .. "|r") end
    if b.experimental then table.insert(tags, "|cffff8000" .. L["Experimental"] .. "|r") end
    if b.slower then table.insert(tags, "|cff999999" .. string.format(L["%d%% slower"], b.slower) .. "|r") end
    return table.concat(tags, "  ")
end

local ROLE_ICON = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local ROLE_COORDS = { tank = { 0, 19/64, 22/64, 41/64 }, healer = { 20/64, 39/64, 1/64, 20/64 }, dps = { 20/64, 39/64, 22/64, 41/64 } }

local function UpdatePageIn()
    if not page then return end
    local active = GetActiveBuild()
    cat = cat or DefaultCategory()

    -- Stage tabs: the chosen one lit, empty ones greyed.
    for _, btn in ipairs(page.stageButtons) do
        local n = #CategoryBuilds(btn.key)
        btn.Text:SetText((n > 0 and "" or "|cff777777") .. L[btn.label])
        btn:SetSelected(cat.stage == btn.key)
    end

    -- Build list: every build of the stage, grouped by role.
    local entries = {}
    for _, r in ipairs(ROLES) do
        local list = CategoryBuilds(cat.stage, r.key)
        if #list > 0 then
            table.insert(entries, { role = r.key, label = L[r.label] })
            -- Solo before Dungeon, the fastest first.
            table.sort(list, function(a, b)
                local ma, mb = (a.mode == "dungeon") and 1 or 0, (b.mode == "dungeon") and 1 or 0
                if ma ~= mb then return ma < mb end
                if (a.fastest and 1 or 0) ~= (b.fastest and 1 or 0) then return a.fastest and true or false end
                return (a.slower or 0) < (b.slower or 0)
            end)
            for _, b in ipairs(list) do table.insert(entries, { build = b }) end
        end
    end
    local sel = selectedId and T.Builds[selectedId]
    if not (sel and sel.class == PlayerClass() and sel.stage == cat.stage) then
        selectedId = (active and active.stage == cat.stage and active.id) or nil
        if not selectedId then
            for _, e in ipairs(entries) do if e.build then selectedId = e.build.id; break end end
        end
    end
    page.SetList(entries, active)

    local b = selectedId and T.Builds[selectedId]
    if not b then
        page.icon:SetTexture(nil)
        page.name:SetText("|cffffd100" .. L[LABEL[cat.stage]] .. "|r")
        page.sub:SetText("")
        page.split:Hide()
        page.info:SetText(L["No builds here for your class yet."])
        page.progress:Hide()
        page.SetOrder({})
        page.use:Hide(); page.activeTag:Hide(); page.clear:SetEnabled(active ~= nil)
        return
    end

    local tree = ReadTree()
    local isActive = active and active.id == b.id
    local counts, main = TreeSplit(b)
    local t = Trees()[main]
    page.icon:SetTexture(t and t.icon or nil)
    page.name:SetText("|cffffd100" .. BuildName(b) .. "|r")
    local sub = CategoryName(b.stage, b.role, b.mode):gsub(" %- ", " · ")
    if b.fastest then sub = sub .. " · |cff55ff55" .. L["Fastest"] .. "|r" end
    if b.experimental then sub = sub .. " · |cffff8000" .. L["Experimental"] .. "|r" end
    page.sub:SetText("|cff999999" .. sub .. "|r")

    -- Tree split bar: one segment per tree, as wide as its share of the points.
    local total = counts[1] + counts[2] + counts[3]
    local barW = page.split:GetWidth()
    if not barW or barW < 10 then barW = 300 end
    local x, labels = 0, {}
    for i = 1, 3 do
        local seg = page.split.segs[i]
        local w = total > 0 and math.floor(barW * counts[i] / total + 0.5) or 0
        if i == 3 then w = math.max(0, barW - x) end
        local c = TreeColor(i)
        seg:SetColorTexture(c[1], c[2], c[3], 1)
        seg:ClearAllPoints(); seg:SetPoint("TOPLEFT", page.split, "TOPLEFT", x, 0)
        seg:SetSize(math.max(w, 0.01), 8); seg:SetShown(counts[i] > 0)
        x = x + w
        labels[i] = string.format("|cff%02x%02x%02x%s %d|r", math.floor(c[1] * 255), math.floor(c[2] * 255), math.floor(c[3] * 255), TreeName(i), counts[i])
    end
    page.split.label:SetText(table.concat(labels, "    "))
    page.split:Show()

    local info = {}
    if b.summary then table.insert(info, L[b.summary]) end
    -- experimental (2026-10-17): a model result nobody has tried in game yet
    if b.experimental then table.insert(info, L["|cffff8000Experimental:|r from our model only, not yet tried in game."]) end
    if b.slower then
        local fastest
        for _, x2 in ipairs(T.BuildList) do if x2.class == b.class and x2.fastest then fastest = x2; break end end
        if fastest then table.insert(info, string.format(L["About %d%% slower to level than %s, the fastest solo build, in our model."], b.slower, BuildName(fastest))) end
    end
    table.insert(info, " ")
    table.insert(info, string.format(L["|cffffd100Gear Judge weights:|r %s while leveling, %s at 60."], ProfileLabel(b.leveling), ProfileLabel(b.endgame)))
    if b.stage == "pvp" then table.insert(info, L["PvP weights at every level: Stamina, armor and burst count for more, and hit stops at the player-vs-player caps."]) end
    if b.respec then
        table.insert(info, string.format(L["|cffffd100Respec at %d:|r %s (weights: %s, then %s at 60)."],
            b.respec.level, L[b.respec.name], ProfileLabel(b.respec.leveling), ProfileLabel(b.respec.endgame)))
    end
    page.info:SetText(table.concat(info, "\n"))

    -- Progress box (the active build only): a bar, the next talent and its level, off-build points.
    local P = page.progress
    if isActive and tree then
        local view, respecDue = T.ActiveView(b, tree)
        local st = T.Evaluate(view, tree)
        local n = #view.points
        P.count:SetText(string.format(L["%d / %d"], st.onTrack, n))
        P.fill:SetWidth(math.max(0.01, (P.bar:GetWidth() or 200) * (n > 0 and st.onTrack / n or 0)))
        local lines = {}
        if respecDue then
            table.insert(lines, string.format(L["|cff00ff00Time to respec:|r reset your talents at a trainer, then follow %s."], L[b.respec.name]))
        elseif st.complete and b.respec and view == b then
            table.insert(lines, string.format(L["|cff00ff00Done until %d.|r Then respec to %s."], b.respec.level, L[b.respec.name]))
        elseif st.complete then
            table.insert(lines, L["|cff00ff00Build complete.|r"])
        else
            local nxt = st.upcoming[1]
            table.insert(lines, string.format(L["Next: %s at level %d"], "|cff00ff00" .. TalentLabel(nxt, tree) .. "|r", view.levelOf(nxt.index)))
            if st.unspent > 0 then
                table.insert(lines, string.format(st.unspent == 1 and L["%d point to spend"] or L["%d points to spend"], st.unspent))
            end
        end
        if #st.off > 0 and not respecDue then
            table.insert(lines, string.format(L["|cffff6060Off-build: %s|r"], FormatOff(st.off)))
        end
        P.text:SetText(table.concat(lines, "\n"))
        P:SetHeight(44 + P.text:GetStringHeight())
        P:Show()
    else
        P:Hide()
    end

    -- Use this build, or the Active mark when it already is.
    page.use:SetShown(not isActive); page.activeTag:SetShown(isActive and true or false)
    page.clear:SetEnabled(active ~= nil)

    local rows = OrderRows(b, tree, b.respec and string.format(L["|cffffd100Talent order to %d|r"], b.respec.level - 1) or L["|cffffd100Talent order|r"], b.respec and b.respec.level)
    if b.respec then
        local after = OrderRows(b.respec, tree, string.format(L["|cffffd100After the respec at %d|r"], b.respec.level))
        if (UnitLevel("player") or 0) >= b.respec.level then
            -- Past the respec: the new order matters now, the old one is history.
            rows, after = after, rows
        end
        table.insert(rows, { header = " " })
        for _, r in ipairs(after) do table.insert(rows, r) end
    end
    page.SetOrder(rows)
end
UpdatePage = function()
    if not page then return end
    if page.specButtons then
        local dual = HasDualSpec()
        if not dual then pageGroup = nil end
        local g = pageGroup or ActiveGroup()
        for i, btn in ipairs(page.specButtons) do
            btn:SetShown(dual)
            local mark = (i == ActiveGroup()) and " |cff00ff00*|r" or ""
            btn:SetText(SpecName(i) .. mark)
            if i == g then btn:LockHighlight() else btn:UnlockHighlight() end
        end
    end
    InGroup(pageGroup or ActiveGroup(), UpdatePageIn)
end
T.RefreshPage = function() if page and page:IsShown() then UpdatePage() end end

-- Layout: stage tabs and the build list (left) | build details, progress, settings (centre) | talent order (right)
local PAGE_LEFT_W, PAGE_RIGHT_W = 236, 300
local WHITE = "Interface\\Buttons\\WHITE8X8"

-- A flat button: dark fill and a thin border; SetSelected lights it gold.
local function FlatButton(parent, w, h)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, h)
    btn:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    local hl = btn:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.06)
    function btn:SetSelected(on)
        self.selected = on
        if on then
            self:SetBackdropColor(0.30, 0.22, 0.05, 0.85); self:SetBackdropBorderColor(1, 0.82, 0, 0.9)
        else
            self:SetBackdropColor(0.08, 0.08, 0.08, 0.85); self:SetBackdropBorderColor(1, 1, 1, 0.12)
        end
    end
    btn:SetSelected(false)
    return btn
end

local function BuildPage(parent)
    page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints()
    page:Hide()

    -- Columns
    local LCol = CreateFrame("Frame", nil, page)
    LCol:SetPoint("TOPLEFT"); LCol:SetPoint("BOTTOMLEFT"); LCol:SetWidth(PAGE_LEFT_W)
    local R = CreateFrame("Frame", nil, page)
    R:SetPoint("TOPRIGHT"); R:SetPoint("BOTTOMRIGHT"); R:SetWidth(PAGE_RIGHT_W)
    local C = CreateFrame("Frame", nil, page)
    C:SetPoint("TOPLEFT", LCol, "TOPRIGHT"); C:SetPoint("BOTTOMRIGHT", R, "BOTTOMLEFT")
    for _, col in ipairs({ LCol, R }) do
        local shade = col:CreateTexture(nil, "BACKGROUND"); shade:SetAllPoints(); shade:SetColorTexture(0, 0, 0, 0.25)
    end
    local function Divider(col, side)
        local t = col:CreateTexture(nil, "BORDER"); t:SetColorTexture(1, 1, 1, 0.08); t:SetWidth(1)
        t:SetPoint("TOP" .. side, 0, 0); t:SetPoint("BOTTOM" .. side, 0, 0)
    end
    Divider(LCol, "RIGHT"); Divider(R, "LEFT")

    -- ==========================================
    -- LEFT: TITLE, STAGE TABS, BUILD LIST
    -- ==========================================
    local innerW = PAGE_LEFT_W - 24
    local title = LCol:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(L["Talent Builds"])
    title:SetTextColor(1, 0.82, 0)

    -- Dual Specialization: which spec's build the page shows and sets (* = active).
    page.specButtons = {}
    for i = 1, 2 do
        local btn = CreateFrame("Button", nil, LCol, "UIPanelButtonTemplate")
        btn:SetSize(58, 18)
        btn:SetPoint("TOPRIGHT", -8 - (2 - i) * 60, -10)
        local fs = btn:GetFontString(); if fs then fs:SetFontObject("GameFontHighlightSmall") end
        btn:SetScript("OnClick", function() pageGroup = i; selectedId = nil; cat = nil; UpdatePage() end)
        btn:Hide()
        page.specButtons[i] = btn
    end

    local sub = LCol:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    sub:SetText(L["Pick a build for next-talent reminders, a glow in the talent window, and weights that follow it."])
    sub:SetWidth(innerW); sub:SetJustifyH("LEFT"); sub:SetTextColor(0.7, 0.7, 0.7)

    -- Stage tabs, one row; widths follow STAGES[].w.
    page.stageButtons = {}
    local totalW = 0
    for _, s in ipairs(STAGES) do totalW = totalW + (s.w or 50) end
    local gap, x = 3, 12
    local scale = (innerW - gap * (#STAGES - 1)) / totalW
    for _, s in ipairs(STAGES) do
        local w = math.floor((s.w or 50) * scale)
        local btn = FlatButton(LCol, w, 22)
        btn:SetPoint("TOPLEFT", x, -86)
        x = x + w + gap
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.Text:SetPoint("CENTER"); btn.Text:SetWidth(w - 4); btn.Text:SetWordWrap(false)
        btn.key, btn.label = s.key, s.short or s.label
        btn:SetScript("OnClick", function(self)
            cat = { stage = self.key }
            selectedId = nil
            UpdatePage()
        end)
        table.insert(page.stageButtons, btn)
    end

    -- The build list (scrolls if a stage has many builds).
    local listScroll = CreateFrame("ScrollFrame", nil, LCol, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 12, -118)
    listScroll:SetPoint("BOTTOMRIGHT", -26, 12)
    local listChild = CreateFrame("Frame", nil, listScroll)
    listChild:SetSize(innerW - 14, 400)
    listScroll:SetScrollChild(listChild)
    -- Hide the scroll bar when everything fits.
    local function FitScrollBar(sf)
        local bar = sf.ScrollBar
        if not bar then return end
        local need = (sf:GetScrollChild():GetHeight() or 0) > (sf:GetHeight() or 0) + 1
        bar:SetShown(need)
        if not need then sf:SetVerticalScroll(0) end
    end
    page.listHeaders, page.listRows = {}, {}
    local ROW_H, HDR_H = 38, 20
    function page.SetList(entries, active)
        local y, nh, nr = 0, 0, 0
        local w = listChild:GetWidth()
        for _, e in ipairs(entries) do
            if e.role then
                nh = nh + 1
                local h = page.listHeaders[nh]
                if not h then
                    h = CreateFrame("Frame", nil, listChild); h:SetHeight(HDR_H)
                    h.Icon = h:CreateTexture(nil, "ARTWORK"); h.Icon:SetSize(14, 14); h.Icon:SetPoint("LEFT", 0, 0)
                    h.Icon:SetTexture(ROLE_ICON)
                    h.Text = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); h.Text:SetPoint("LEFT", h.Icon, "RIGHT", 4, 0)
                    page.listHeaders[nh] = h
                end
                h:ClearAllPoints(); h:SetPoint("TOPLEFT", 0, -y); h:SetWidth(w)
                h.Icon:SetTexCoord(unpack(ROLE_COORDS[e.role]))
                h.Text:SetText(e.label); h:Show()
                y = y + HDR_H
            else
                nr = nr + 1
                local row = page.listRows[nr]
                if not row then
                    row = FlatButton(listChild, w, ROW_H - 4)
                    row.Name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.Name:SetPoint("TOPLEFT", 8, -5); row.Name:SetPoint("RIGHT", -8, 0)
                    row.Name:SetJustifyH("LEFT"); row.Name:SetWordWrap(false)
                    row.Tags = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    row.Tags:SetPoint("BOTTOMLEFT", 8, 5); row.Tags:SetJustifyH("LEFT"); row.Tags:SetWordWrap(false)
                    row.Active = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    row.Active:SetPoint("BOTTOMRIGHT", -6, 5)
                    row.Tags:SetPoint("RIGHT", row.Active, "LEFT", -4, 0)
                    row:SetScript("OnClick", function(self) selectedId = self.id; UpdatePage() end)
                    page.listRows[nr] = row
                end
                local b = e.build
                row.id = b.id
                row:ClearAllPoints(); row:SetPoint("TOPLEFT", 0, -y); row:SetWidth(w)
                row.Name:SetText(BuildName(b))
                row.Tags:SetText(BuildTags(b))
                row.Active:SetText((active and active.id == b.id) and ("|cff55ff55" .. L["Active"] .. "|r") or "")
                row:SetSelected(b.id == selectedId)
                row:Show()
                y = y + ROW_H
            end
        end
        for k = nh + 1, #page.listHeaders do page.listHeaders[k]:Hide() end
        for k = nr + 1, #page.listRows do page.listRows[k]:Hide() end
        listChild:SetHeight(math.max(1, y))
        FitScrollBar(listScroll)
    end
    listScroll:SetScript("OnSizeChanged", function(self, w)
        if w and w > 60 then listChild:SetWidth(w) end
        FitScrollBar(self)
    end)

    -- ==========================================
    -- CENTRE: HEADER, TREE SPLIT, DETAILS, PROGRESS, USE / CLEAR, SETTINGS
    -- ==========================================
    page.icon = C:CreateTexture(nil, "ARTWORK")
    page.icon:SetSize(36, 36); page.icon:SetPoint("TOPLEFT", 16, -14)
    page.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    page.name = C:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    page.name:SetPoint("TOPLEFT", page.icon, "TOPRIGHT", 10, -1)
    page.name:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    page.name:SetJustifyH("LEFT"); page.name:SetWordWrap(false)
    page.sub = C:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.sub:SetPoint("TOPLEFT", page.name, "BOTTOMLEFT", 0, -4)
    page.sub:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    page.sub:SetJustifyH("LEFT"); page.sub:SetWordWrap(false)

    page.split = CreateFrame("Frame", nil, C)
    page.split:SetPoint("TOPLEFT", page.icon, "BOTTOMLEFT", 0, -12)
    page.split:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    page.split:SetHeight(8)
    local splitBg = page.split:CreateTexture(nil, "BACKGROUND"); splitBg:SetAllPoints(); splitBg:SetColorTexture(1, 1, 1, 0.08)
    page.split.segs = {}
    for i = 1, 3 do page.split.segs[i] = page.split:CreateTexture(nil, "ARTWORK") end
    page.split.label = page.split:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.split.label:SetPoint("TOPLEFT", page.split, "BOTTOMLEFT", 0, -4)
    page.split:SetScript("OnSizeChanged", function() if page:IsShown() then UpdatePage() end end)

    page.info = C:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.info:SetPoint("TOPLEFT", page.split, "BOTTOMLEFT", 0, -26)
    page.info:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    page.info:SetJustifyH("LEFT"); page.info:SetSpacing(3)

    -- Progress box
    local P = CreateFrame("Frame", nil, C, "BackdropTemplate")
    P:SetPoint("TOPLEFT", page.info, "BOTTOMLEFT", 0, -12)
    P:SetPoint("RIGHT", C, "RIGHT", -16, 0)
    P:SetHeight(60)
    P:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    P:SetBackdropColor(0, 0, 0, 0.35); P:SetBackdropBorderColor(1, 1, 1, 0.1)
    local pLbl = P:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pLbl:SetPoint("TOPLEFT", 8, -7); pLbl:SetText(L["Progress"])
    P.count = P:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    P.count:SetPoint("TOPRIGHT", -8, -7)
    P.bar = P:CreateTexture(nil, "ARTWORK")
    P.bar:SetPoint("TOPLEFT", 8, -22); P.bar:SetPoint("RIGHT", P, "RIGHT", -8, 0); P.bar:SetHeight(6)
    P.bar:SetColorTexture(1, 1, 1, 0.1)
    P.fill = P:CreateTexture(nil, "OVERLAY")
    P.fill:SetPoint("TOPLEFT", P.bar, "TOPLEFT"); P.fill:SetHeight(6)
    P.fill:SetColorTexture(0.33, 0.85, 0.33, 1)
    P.text = P:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    P.text:SetPoint("TOPLEFT", P.bar, "BOTTOMLEFT", 0, -7); P.text:SetPoint("RIGHT", P, "RIGHT", -8, 0)
    P.text:SetJustifyH("LEFT"); P.text:SetSpacing(2)
    P:Hide()
    page.progress = P

    -- Buttons sit under the progress box when it shows, else under the details.
    local btnRow = CreateFrame("Frame", nil, C)
    btnRow:SetSize(260, 24)
    local function PlaceButtons()
        btnRow:ClearAllPoints()
        btnRow:SetPoint("TOPLEFT", P:IsShown() and P or page.info, "BOTTOMLEFT", 0, -14)
    end
    P:SetScript("OnShow", PlaceButtons); P:SetScript("OnHide", PlaceButtons); PlaceButtons()

    page.use = CreateFrame("Button", nil, btnRow, "UIPanelButtonTemplate")
    page.use:SetSize(140, 24)
    page.use:SetPoint("TOPLEFT")
    page.use:SetText(L["Use This Build"])
    page.use:SetScript("OnClick", function() if selectedId then T.SetBuild(selectedId, pageGroup or ActiveGroup()) end; UpdatePage() end)

    page.activeTag = CreateFrame("Frame", nil, btnRow)
    page.activeTag:SetSize(140, 24); page.activeTag:SetPoint("TOPLEFT")
    local check = page.activeTag:CreateTexture(nil, "ARTWORK")
    check:SetSize(16, 16); check:SetPoint("LEFT", 4, 0)
    check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
    local activeTxt = page.activeTag:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activeTxt:SetPoint("LEFT", check, "RIGHT", 4, 0)
    activeTxt:SetText("|cff55ff55" .. L["Active build"] .. "|r")
    page.activeTag:Hide()

    page.clear = CreateFrame("Button", nil, btnRow, "UIPanelButtonTemplate")
    page.clear:SetSize(100, 24)
    page.clear:SetPoint("TOPLEFT", 146, 0)
    page.clear:SetText(L["Clear Build"])
    page.clear:SetScript("OnClick", function() T.SetBuild(nil, pageGroup or ActiveGroup()); UpdatePage() end)

    -- Settings, pinned to the bottom of the centre column
    local setHdr = C:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setHdr:SetPoint("BOTTOMLEFT", 16, 112)
    setHdr:SetText(L["Settings"])
    local function Toggle(label, key, anchor, onChange)
        local box = CreateFrame("CheckButton", nil, C, "ChatConfigCheckButtonTemplate")
        box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
        box.Text:SetText(label); box.Text:SetTextColor(0.9, 0.9, 0.9)
        box:SetScript("OnShow", function(self) self:SetChecked(db[key]) end)
        box:SetChecked(db[key])
        box:SetScript("OnClick", function(self) db[key] = self:GetChecked() and true or false; if onChange then onChange() end end)
        return box
    end
    local link = Toggle(L["Weights follow the build"], "linkGear", setHdr, ApplyGearLink)
    local rem = Toggle(L["Level-up reminders"], "remind", link)
    Toggle(L["Panel beside the talent window"], "showPanel", rem, QueueRefresh)

    -- ==========================================
    -- RIGHT: TALENT ORDER (scrolls the full height)
    -- ==========================================
    local orderHdr = R:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    orderHdr:SetPoint("TOPLEFT", 12, -14)
    orderHdr:SetText(L["Talent Order"])
    local orderSub = R:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    orderSub:SetPoint("TOPLEFT", orderHdr, "BOTTOMLEFT", 0, -3)
    orderSub:SetText(L["|cff55ff55Taken|r"] .. "  " .. L["|cffffd100Next|r"] .. "  " .. L["|cffaaaaaaLater|r"])

    local scroll = CreateFrame("ScrollFrame", nil, R, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", orderSub, "BOTTOMLEFT", 0, -10)
    scroll:SetPoint("BOTTOMRIGHT", -30, 12)
    page.orderChild = CreateFrame("Frame", nil, scroll)
    page.orderChild:SetSize(PAGE_RIGHT_W - 42, 400)
    scroll:SetScrollChild(page.orderChild)
    -- One row per talent line: a tree stripe, the talent's icon, its levels and the talent.
    -- A long name is cut short on its own row, so it can't push later rows off their levels.
    page.orderRows = {}
    local OROW_H = 17
    function page.SetOrder(rows)
        local nextRow
        for i = 1, math.max(#rows, #page.orderRows) do
            local row = page.orderRows[i]
            local r = rows[i]
            if r then
                if not row then
                    row = CreateFrame("Frame", nil, page.orderChild); row:SetHeight(OROW_H)
                    row:SetPoint("TOPLEFT", 0, -(i - 1) * OROW_H); row:SetPoint("RIGHT", page.orderChild, "RIGHT", 0, 0)
                    row.Stripe = row:CreateTexture(nil, "ARTWORK"); row.Stripe:SetSize(3, OROW_H - 3); row.Stripe:SetPoint("LEFT", 0, 0)
                    row.Icon = row:CreateTexture(nil, "ARTWORK"); row.Icon:SetSize(14, 14); row.Icon:SetPoint("LEFT", 6, 0)
                    row.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    row.Lvl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.Lvl:SetPoint("LEFT", 24, 0); row.Lvl:SetWidth(46); row.Lvl:SetJustifyH("LEFT"); row.Lvl:SetWordWrap(false)
                    row.Text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.Text:SetPoint("LEFT", 72, 0); row.Text:SetPoint("RIGHT", 0, 0); row.Text:SetJustifyH("LEFT"); row.Text:SetWordWrap(false)
                    row.Head = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.Head:SetPoint("LEFT", 0, 0); row.Head:SetPoint("RIGHT", 0, 0); row.Head:SetJustifyH("LEFT"); row.Head:SetWordWrap(false)
                    page.orderRows[i] = row
                end
                if r.header then
                    row.Head:SetText(r.header); row.Head:Show()
                    row.Stripe:Hide(); row.Icon:Hide(); row.Lvl:Hide(); row.Text:Hide()
                else
                    row.Head:Hide()
                    local c = r.tree and TreeColor(r.tree)
                    if c then row.Stripe:SetColorTexture(c[1], c[2], c[3], 1); row.Stripe:Show() else row.Stripe:Hide() end
                    row.Icon:SetTexture(r.icon); row.Icon:SetShown(r.icon ~= nil)
                    row.Icon:SetDesaturated(r.color == "|cffaaaaaa")
                    row.Lvl:SetText(r.color .. r.lvl .. "|r"); row.Lvl:Show()
                    -- Key talents (single-rank abilities) stand out with an outline.
                    row.Text:SetFontObject(r.key and "GameFontHighlightSmallOutline" or "GameFontHighlightSmall")
                    row.Text:SetText(r.color .. r.text .. "|r"); row.Text:Show()
                    if r.isNext and not nextRow then nextRow = i end
                end
                row:Show()
            elseif row then
                row:Hide()
            end
        end
        page.orderChild:SetHeight(math.max(1, #rows * OROW_H + 10))
        -- Bring the next talent into view, a few rows from the top.
        if nextRow then
            local range = scroll:GetVerticalScrollRange() or 0
            scroll:SetVerticalScroll(math.min(range, math.max(0, (nextRow - 4) * OROW_H)))
        else
            scroll:SetVerticalScroll(0)
        end
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
        MSC.RegisterPluginTab(L["Talent Builds"], "Interface\\Icons\\Ability_Marksmanship", BuildPage, "ViewTalents", "UpdateTalentsView")
    end
end

-- =========================================================================
-- 8. EVENTS
-- =========================================================================
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_LEVEL_UP")
for _, e in ipairs({ "TRAIT_CONFIG_UPDATED", "PLAYER_TALENT_UPDATE", "CHARACTER_POINTS_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED" }) do
    pcall(ev.RegisterEvent, ev, e)
end
-- A talent picked in the window but not yet applied: refresh the glow and panel only.
-- (RegisterEvent errors on an event the client lacks, hence the pcall.)
local STAGED_EVENTS = { TRAIT_NODE_CHANGED = true, TRAIT_TREE_CURRENCY_INFO_UPDATED = true }
for e in pairs(STAGED_EVENTS) do pcall(ev.RegisterEvent, ev, e) end

local function IsAddOnLoadedSafe(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded(name) end
    if IsAddOnLoaded then return IsAddOnLoaded(name) end
    return false
end

local talentUpdatePending = false

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
                MarkTreeDirty()
                CheckOffBuild()
                Remind("login")
                if not GetActiveBuild() and (UnitLevel("player") or 0) >= FIRST_POINT_LEVEL and #ClassBuilds() > 0 and not charDB.hinted then
                    charDB.hinted = true
                    Print(L["Pick a talent build with |cffffffff/sgjt|r to get next-talent reminders and highlights."])
                end
            end)
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if C_Timer and C_Timer.After then
            C_Timer.After(1.5, function() MarkTreeDirty(); ApplyGearLink(); Remind("level"); QueueRefresh() end)
        end
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        -- The other spec is active now: its build drives the weights and reminders.
        if not IsSupported() then return end
        MarkTreeDirty(); lastOffKey = nil
        ApplyGearLink(); QueueRefresh()
        if C_Timer and C_Timer.After then C_Timer.After(1, function() MarkTreeDirty(); CheckOffBuild(); Remind("spec") end) end
    elseif STAGED_EVENTS[event] then
        if not IsSupported() then return end
        MarkTreeDirty()
        QueueRefresh()
    else
        -- Talent changes: one point spent fires all three events, so refresh once.
        if not IsSupported() then return end
        MarkTreeDirty()
        if C_Timer and C_Timer.After and not talentUpdatePending then
            talentUpdatePending = true
            C_Timer.After(0.2, function()
                talentUpdatePending = false
                MarkTreeDirty()
                ApplyGearLink(); CheckOffBuild(); QueueRefresh()
            end)
        end
    end
end)
