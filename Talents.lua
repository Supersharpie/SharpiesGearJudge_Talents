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

    if not shown then HideGlow(); return end
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
        local lvl = (l1 == l2) and string.format(L["L%d"], l1) or string.format(L["L%d-%d"], l1, l2)
        local ranks = (first == last) and tostring(last) or (first .. "-" .. last)
        table.insert(lvls, color .. lvl .. "|r")
        table.insert(lines, string.format("%s%s %s%s|r", color, L[name], ranks, max and ("/" .. max) or ""))
        i = j + 1
    end
    return lvls, lines
end

local UpdatePage -- set below (it wraps UpdatePageIn with the shown spec)
local pageGroup -- the spec the Builds page shows (nil = the active one)

local function UpdatePageIn()
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
        if btn.field == "stage" then btn:SetText(grey .. L[btn.label])  -- four across: no room for a count
        else btn:SetText(string.format("%s%s (%d)", grey, L[btn.label], n)) end
        if cat[btn.field] == btn.key then btn:LockHighlight() else btn:UnlockHighlight() end
        btn:SetShown(btn.field ~= "mode" or cat.stage == "leveling")
    end
    for k, btn in ipairs(page.list) do
        local b = list[k]
        if b then
            local mark = (active and active.id == b.id) and "|cff00ff00> |r" or ""
            btn:SetText(mark .. BuildName(b))
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
        page.info:SetText(L["No builds here for your class yet."])
        page.SetOrder({}, {})
        page.use:Hide(); page.clear:Show(); page.clear:SetEnabled(active ~= nil)
        return
    end
    page.use:Show(); page.clear:Show()
    page.use:SetEnabled(not (active and active.id == b.id))
    page.clear:SetEnabled(active ~= nil)

    local tree = ReadTree()
    local isActive = active and active.id == b.id
    page.name:SetText((isActive and (L["|cff00ff00Active:|r"] .. " ") or "") .. "|cffffd100" .. BuildName(b) .. "|r")

    local info = { "|cff999999" .. CategoryName(b.stage, b.role, b.mode) .. "|r" }
    if b.summary then table.insert(info, L[b.summary]) end
    table.insert(info, " ")
    table.insert(info, string.format(L["|cffffd100Gear Judge weights:|r %s while leveling, %s at 60."], ProfileLabel(b.leveling), ProfileLabel(b.endgame)))
    if b.stage == "pvp" then table.insert(info, L["PvP weights at every level: Stamina, armor and burst count for more, and hit stops at the player-vs-player caps."]) end
    if b.respec then
        table.insert(info, string.format(L["|cffffd100Respec at %d:|r %s (weights: %s, then %s at 60)."],
            b.respec.level, L[b.respec.name], ProfileLabel(b.respec.leveling), ProfileLabel(b.respec.endgame)))
    end
    if isActive and tree then
        local view, respecDue = T.ActiveView(b, tree)
        local st = T.Evaluate(view, tree)
        table.insert(info, " ")
        if respecDue then
            table.insert(info, string.format(L["|cff00ff00Time to respec:|r reset your talents at a trainer, then follow %s."], L[b.respec.name]))
        elseif st.complete and b.respec and view == b then
            table.insert(info, string.format(L["|cff00ff00Done until %d.|r Then respec to %s."], b.respec.level, L[b.respec.name]))
        elseif st.complete then
            table.insert(info, L["|cff00ff00Build complete.|r"])
        else
            table.insert(info, string.format(st.unspent == 1 and L["On track %d / %d, %d point to spend. Next: |cff00ff00%s|r"] or L["On track %d / %d, %d points to spend. Next: |cff00ff00%s|r"],
                st.onTrack, #view.points, st.unspent, TalentLabel(st.upcoming[1], tree)))
        end
        if #st.off > 0 and not respecDue then
            table.insert(info, string.format(L["|cffff6060Off-build: %s|r"], FormatOff(st.off)))
        end
    end
    page.info:SetText(table.concat(info, "\n"))

    local lv, tx = OrderLines(b, tree, b.respec and string.format(L["|cffffd100Talent order to %d|r"], b.respec.level - 1) or L["|cffffd100Talent order|r"], b.respec and b.respec.level)
    if b.respec then
        local lv2, tx2 = OrderLines(b.respec, tree, string.format(L["|cffffd100After the respec at %d|r"], b.respec.level))
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

-- Layout: categories and build list (left) | build details, buttons, settings (centre) | talent order (right)
local PAGE_LEFT_W, PAGE_RIGHT_W = 236, 300

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
    -- LEFT: TITLE, CATEGORIES, BUILD LIST
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

    -- Category rows: stage, then role, then Solo / Dungeon for leveling builds.
    page.catButtons = {}
    local CAT_TOP = -86
    local function CatRow(items, field, y)
        local width = (innerW - (#items - 1) * 4) / #items
        local x = 12
        for i, c in ipairs(items) do
            local btn = CreateFrame("Button", nil, LCol, "UIPanelButtonTemplate")
            btn:SetSize(c.w or width, 22)
            btn:SetPoint("TOPLEFT", x, y)
            x = x + (c.w or width) + 4
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
        local btn = CreateFrame("Button", nil, LCol, "UIPanelButtonTemplate")
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
    page.use:SetText(L["Use This Build"])
    page.use:SetScript("OnClick", function() if selectedId then T.SetBuild(selectedId, pageGroup or ActiveGroup()) end; UpdatePage() end)

    page.clear = CreateFrame("Button", nil, C, "UIPanelButtonTemplate")
    page.clear:SetSize(100, 24)
    page.clear:SetPoint("LEFT", page.use, "RIGHT", 6, 0)
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
