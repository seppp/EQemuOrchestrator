-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

-- [ NOTE ON ORDERING ] --
-- Order matters! Lua will implicitly iterate everything in an array
-- in order by default so always put the first thing you want checked
-- towards the top of the list.

local mq        = require('mq')
local Casting   = require("utils.casting")
local Config    = require('utils.config')
local Core      = require("utils.core")
local Globals   = require("utils.globals")
local Logger    = require("utils.logger")
local Modules   = require("utils.modules")
local Movement  = require("utils.movement")
local Strings   = require("utils.strings")
local Targeting = require("utils.targeting")

local Tooltips  = {
    ArrowOpener         = "Spell Line: Archery Attack with High Crit Chance when not in Combat. Consumes a 50 range CLASS 3 Wood Silver Tip Arrow when cast.",
    PullOpener          = "Spell Line: Archery Attack when not in Combat. Consumes a 50 range CLASS 3 Wood Silver Tip Arrow when cast.",
    CalledShotsArrow    = "Spell Line: Quad Archery Attack + Increase Archery Dmg Against Target",
    FocusedArrows       = "Spell Line: Quad Archery Attack",
    DichoSpell          = "Spell Line: Cast best Summer's Cyclone + Double Massive Archery Attack + Lower Hatred",
    SummerNuke          = "Spell Line: Fire Nuke + Cold Nuke + Increase Hatred",
    SwarmDot            = "Spell Line: Magic DoT",
    ShortSwarmDot       = "Spell Line: Prismatic DoT + ToT Damage Shield",
    UnityBuff           = "AA: Casts Highest Level of Scribed Buffs (ParryProcBuff, Hunt, Protectionbuff, Eyes)",
    Protectionbuff      = "Spell Line: Increase AC + Self Damage Shield",
    ShoutBuff           = "Spell Line: Increase Attack and Double Attack Chance",
    AggroBuff           = "Spell Line: Harms Target HP and Hatred Increase",
    AggroReducerBuff    = "Spell Line: Hatred Decrease Proc",
    AggroKick           = "Spell Line: Two Kicks w/ Increased Accuracy that Increase Hatred",
    ParryProcBuff       = "Spell Line: Magic Nuke w/ Parry Chance Proc",
    Eyes                = "Spell Line: Increase Chance to Hit with Archery",
    GroupStrengthBuff   = "Spell Line: Increase Group's Attack",
    GroupPredatorBuff   = "Spell Line: Increase Group's Attack",
    GroupEnrichmentBuff = "Spell Line: Increase Group's Base Damage",
    Rathe               = "Spell Line: Increase AC + Damage Shield",
    BowDisc             = "Discipline: Increase Archery Skill Check and Damage Modifier",
    MeleeDisc           = "Discipline: Add Melee Damage DoT Proc",
    DefenseDisc         = "Discpline: Parry Chance 100%",
    Fireboon            = "Spell Line: Fire Nuke + Additional Damage w/ Fire Spells",
    Firenuke            = "Spell Line: Fire Nuke",
    Iceboon             = "Spell Line: Cold Nuke + Additional Damage w/ Cold Spells",
    Icenuke             = "Spell Line: Cold Nuke",
    Heartshot           = "Spell Line: Archery Attack. Consumes a 50 range CLASS 3 Wood Silver Tip Arrow when cast.",
    EndRegenDisc        = "Discipline: Endurance Regen + Self Slow",
    Coat                = "Spell Line: Increase AC + Self Damage Shield",
    Mask                = "Spell Line: Increase Magnification + Mana Regen + See Invis",
    Hunt                = "Spell Line: Add Crit Chance and Accuracy Buff Proc on Killshot",
    Heal                = "Spell Line: Heal",
    Fastheal            = "Spell Line: Fast Cast Heal",
    Totheal             = "Spell Line: Heals Target of Target if Used on an Enemy",
    RegenSpells         = "Spell Line: Increase Regeneration",
    SnareSpells         = "Spell Line: Decrease Enemy Movement Speed",
    FireFist            = "Spell Line: Self Increase Attack",
    DsBuff              = "Spell Line: Damage Shield",
    SkinLike            = "Spell Line: Increase AC + Increase Max HP",
    MoveSpells          = "Spell Line: Increase Movement Speed",
    Alliance            = "Spell Line: Alliance (Requires Multiple of Same Class). Adds Fire Damage to other Ranger Spells and triggers a massive Fire and Cold Nuke",
    Cloak               = "Spell Line: Melee Absorb Proc + ATK/AC/Fire Resist Debuff",
    Veil                = "Spell Line: Add Parry Proc",
    JoltingKicks        = "Spell Line: Two Kicks w/ Increased Accuracy that Decrease Hatred",
    AEBlades            = "Spell Line: Quad Attack against up to 8 targets in Front of You",
    FocusedBlades       = "Spell Line: Quad Attack w/ Increased Accuracy",
    ReflexSlashHeal     = "Spell Line: Quad Attack w/ Increase Accuracy + Group HoT",
    AEArrows            = "Spell Line: Quad Archery Attack w/ Increased Accuracy against up to 8 targets in Front of You",
    Entrap              = "AA: Snare",
    Kick                = "Use Kick Ability",
    Taunt               = "Use Taunt Ability",
    Epic                = 'Item: Casts Epic Weapon Ability',
    GotF                = "AA: Wolf Form + v3 Haste + Regen + Attack + Increase Skill Damage",
    GGotF               = "AA: Group Wolf Form + v3 Haste + Regen + Attack + Increase Skill Damage",
    OA                  = "AA: Increase Melee Damage + Accuracy + Attack + Crit Chance + Minimum Damage + Minimum Base Damage",
    EA                  = "AA: Increase Fire and Cold Spell Damage against Target",
    AotH                = "AA: Increase Skill, Spell, and Heal Crit Chance + Accuracy + Attack",
    OE                  = "AA: Decrease Melee Damage + Increase Chance to Avoid Melee + Increase Movement Speed",
    PackHunt            = "AA: Summons a pack of wolves",
    PoisonArrow         = "AA: Adds Archery proc that consumes mana to deal high damage",
    FlamingArrow        = "AA: Adds Archery proc that consumes mana to deal high damage",
    PotSW               = "AA: Mitigate Melee and Spell Damage + Increase Magic Resistance",
    CG                  = "AA: Decrease Hatred and Hatred Generation when HP drops below 50%",
    SS                  = "AA: Reduce Hatred Generation",
    IF                  = "AA: Melee Proc Chance 100% + Decrease Hatred Generation",
    BotB                = "AA: Decrease Hatred + Decrease Hatred Proc when hit in Melee + 100% Parry Chance when below 50% HP",
    EB                  = "AA: Increase 1H Attack Damage + Increase 2H Minimum Attack Damage",
    SCF                 = "AA: Group Buff that drains Mana or Endurance and Twin Casts Spells or Abilities Depending on Class",
    SotP                = "AA: Increase Max HP and Dex Cap + Decreased Hatred Generation + Increased Melee Proc Chance + Increased Melee Minimum Damage",
    EoN                 = "AA: High Chance to Dispel Your Target",
    RangedMode          = "Skill: Use /autofire instead of using Melee",
}

-- helper function for advanced logic to see if we want to use Windstalker's Unity
local function castWSU()
    local unityAction = Modules:ExecModule("Class", "GetResolvedActionMapItem", "Protectionbuff")
    if not unityAction then return false end

    local res = unityAction.Level() <=
        (mq.TLO.Me.AltAbility("Wildstalker's Unity (Azia)").Spell.Level() or 0) and
        mq.TLO.Me.AltAbility("Wildstalker's Unity (Azia)").MinLevel() <= mq.TLO.Me.Level() and
        mq.TLO.Me.AltAbility("Wildstalker's Unity (Azia)").Rank() > 0

    return res
end

local _ClassConfig = {
    _version              = "DODL CUSTOM",
    _author               = "eldudero",
    ['CommandHandlers']   = {
        makeammo = {
            usage = "/rgl makeammo ##",
            about = "Make ## number of Class 3 Wood Silver Tip Arrows. Minimum of 5",
            handler =
                function(self, amount)
                    local packSlots = {
                        { slot = 23, name = 'pack1', }, { slot = 24, name = 'pack2', }, { slot = 25, name = 'pack3', }, { slot = 26, name = 'pack4', },
                        { slot = 27, name = 'pack5', }, { slot = 28, name = 'pack6', }, { slot = 29, name = 'pack7', }, { slot = 30, name = 'pack8', },
                    }
                    local delay = 5
                    local matTable = { 'Several Shield Cut Fletchings', 'Small Groove Nocks', 'Bundled Wooden Arrow Shafts', 'Silver Tipped Arrowheads', }
                    local kitSlot = ''

                    -- How many bundles to make. Dividing as each combine makes 5 arrows
                    if amount == nil then
                        amount = 5
                    end
                    local toMake = tonumber(amount) / 5

                    --Check for and open fletching kit in inventory
                    local kitsToFind = { 'Fletching Kit', 'Planar Fletching Kit', 'Collapsible Fletching Kit', 'Surefall Fletching Kit', }
                    local fletchKit = ''

                    -- Iterates through top level inventory
                    -- If a bag matches a medicine bag, it's set to medBag
                    -- Also stores the inventory slot in bagSlot
                    for packIndex = 23, 32 do
                        local packNum = mq.TLO.Me.Inventory(packIndex).Name()

                        -- Check if packNum's name is in the list of bags to find
                        if table.concat(kitsToFind, ","):find(packNum) then
                            for _, packInfo in ipairs(packSlots) do
                                if packInfo.slot == packIndex then
                                    fletchKit = packNum
                                    kitSlot = packInfo.name
                                    break
                                end
                            end
                        end
                    end

                    -- Ensure a kit was found then open it and enter Experimentation mode
                    -- To Do: Find a way to see if container is open
                    if fletchKit ~= '' then
                        Core.DoCmd('/timed %d /itemnotify "%s" rightmouseup', delay, fletchKit)
                        delay = delay + 5
                        Core.DoCmd('/timed %d /notify TradeskillWnd COMBW_ExperimentButton leftmouseup', delay)
                        delay = delay + 5
                    end

                    -- j is how many bundles to make (toMake)
                    -- Iterates through matTable to place one of each item in the fletching kit
                    -- When all are added, hits Combine and autoinventories the item
                    for j = 1, toMake do
                        for i = 1, toMake do
                            local matName = matTable[i]

                            Core.DoCmd('/timed %d /nomodkey /ctrl /itemnotify "%s" leftmouseup', delay, matName)
                            delay = delay + 5
                            Core.DoCmd('/timed %d /itemnotify in %s %d leftmouseup', delay, kitSlot, i)
                            delay = delay + 5
                            if i == #matTable then
                                Core.DoCmd('/timed %d /combine %s', delay, kitSlot)
                                delay = delay + 7
                                Core.DoCmd('/timed %d /autoinventory', delay)
                                delay = delay + 5
                                Core.DoCmd('/timed %d /echo Combine #%d', delay, j)
                                delay = delay + 13
                            end
                        end
                    end

                    return true
                end,
        },
    },
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsHealing = function() return Core.IsModeActive("Healer") or Core.IsModeActive("Hybrid") end,
    },
    ['Modes']             = {
        'DPS',
        'Tank',
        'Healer',
        'Hybrid',
    },
    ['Themes']            = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.12, g = 0.32, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.12, g = 0.32, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.05, g = 0.13, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.12, g = 0.32, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.12, g = 0.32, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.05, g = 0.13, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.12, g = 0.32, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.12, g = 0.32, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.12, g = 0.32, b = 0.08, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.08, g = 0.21, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.12, g = 0.32, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.12, g = 0.32, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.12, g = 0.32, b = 0.08, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.05, g = 0.13, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.70, g = 0.48, b = 0.12, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.70, g = 0.48, b = 0.12, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.12, g = 0.32, b = 0.08, a = 1.0, }, },
        },
        ['Tank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.18, g = 0.28, b = 0.12, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.18, g = 0.28, b = 0.12, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.07, g = 0.11, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.18, g = 0.28, b = 0.12, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.18, g = 0.28, b = 0.12, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.07, g = 0.11, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.18, g = 0.28, b = 0.12, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.18, g = 0.28, b = 0.12, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.18, g = 0.28, b = 0.12, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.12, g = 0.18, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.18, g = 0.28, b = 0.12, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.18, g = 0.28, b = 0.12, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.18, g = 0.28, b = 0.12, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.07, g = 0.11, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.55, g = 0.65, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.55, g = 0.65, b = 0.35, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.18, g = 0.28, b = 0.12, a = 1.0, }, },
        },
        ['Healer'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.10, g = 0.38, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.10, g = 0.38, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.04, g = 0.15, b = 0.06, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.10, g = 0.38, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.10, g = 0.38, b = 0.15, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.04, g = 0.15, b = 0.06, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.10, g = 0.38, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.10, g = 0.38, b = 0.15, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.10, g = 0.38, b = 0.15, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.07, g = 0.25, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.10, g = 0.38, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.10, g = 0.38, b = 0.15, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.10, g = 0.38, b = 0.15, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.04, g = 0.15, b = 0.06, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.35, g = 0.85, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.35, g = 0.85, b = 0.35, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.10, g = 0.38, b = 0.15, a = 1.0, }, },
        },
        ['Hybrid'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.15, g = 0.30, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.15, g = 0.30, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.06, g = 0.12, b = 0.04, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.15, g = 0.30, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.15, g = 0.30, b = 0.10, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.06, g = 0.12, b = 0.04, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.15, g = 0.30, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.15, g = 0.30, b = 0.10, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.15, g = 0.30, b = 0.10, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.10, g = 0.20, b = 0.07, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.15, g = 0.30, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.15, g = 0.30, b = 0.10, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.15, g = 0.30, b = 0.10, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.06, g = 0.12, b = 0.04, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.60, g = 0.75, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.60, g = 0.75, b = 0.20, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.15, g = 0.30, b = 0.10, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Heartwood Blade",
            "Aurora, the Heartwood Blade",
        },
    },
    ['AbilitySets']       = {
        ['ArrowOpener'] = {
        },
        ['PullOpener'] = {
            "Heartspike Rk. II",
            "Heartspike Rk. III",
            "Heartspike",
            "Heartrip",
            "Heartrend",
            "Heartpierce",
            "Deadfall",
        },
        ['CalledShotsArrow'] = {
            "Forecasted Shots Rk. III",
            "Forecasted Shots Rk. II",
            "Forecasted Shots",
            "Announced Shots",
            "Called Shots",
        },
        ['FocusedArrows'] = {
            "Focused Rain of Arrows Rk. III",
            "Focused Rain of Arrows Rk. II",
            "Focused Rain of Arrows",
            "Focused Arrow Swarm",
            "Focused Tempest of Arrows",
            "Focused Storm of Arrows",
        },
        ['DichoSpell'] = {
        },
        ['SummerNuke'] = {
        },
        ['SwarmDot'] = {
            "Dreadbeetle Swarm Rk. III",
            "Dreadbeetle Swarm Rk. II",
            "Dreadbeetle Swarm",
            "Vespid Swarm",
            "Scarab Swarm",
            "Beetle Swarm",
            "Hornet Swarm",
            "Wasp Swarm",
            "Locust Swarm",
            "Drifting Death",
            "Fire Swarm",
            "Drones of Doom",
            "Swarm of Pain",
            "Stinging Swarm",
        },
        ['ShortSwarmDot'] = {
            "Swarm of Vespines Rk. III",
            "Swarm of Vespines Rk. II",
            "Swarm of Vespines",
            "Swarm of Sand Wasps",
            "Swarm of Hornets",
            "Swarm of Bees",
        },
        ['UnityBuff'] = {
        },
        ['Protectionbuff'] = {
            "Protection of the Bosque Rk. III",
            "Protection of the Bosque Rk. II",
            "Protection of the Bosque",
            "Protection of the Copse",
            "Protection of the Vale",
            "Protection of the Paw",
            "Protection of the Kirkoten",
            "Protection of the Minohten",
            "Protection of the Wild",
            "Force of Nature",
        },
        ['ShoutBuff'] = {
            "Shout of the Predator Rk. III",
            "Shout of the Predator Rk. II",
            "Shout of the Predator",
        },
        ['AggroBuff'] = {
            "Devastating Impact Rk. III",
            "Devastating Impact Rk. II",
            "Devastating Impact",
            "Devastating Slashes",
            "Devastating Edges",
            "Devastating Blades",
        },
        ['AggroReducerBuff'] = {
            "Jolting Shock Rk. III",
            "Jolting Shock Rk. II",
            "Jolting Shock",
            "Jolting Impact",
            "Jolting Edges",
            "Jolting Swings",
            "Jolting Strikes",
            "Jolting Blades",
        },
        ['AggroKick'] = {
            "Enraging Heel Kicks Rk. III",
            "Enraging Heel Kicks Rk. II",
            "Enraging Heel Kicks",
            "Enraging Crescent Kicks",
        },
        ['ParryProcBuff'] = {
            "Deafening Weapons Rk. III",
            "Deafening Weapons Rk. II",
            "Deafening Weapons",
            "Deafening Edges",
            "Crackling Edges",
            "Crackling Blades",
            "Thundering Blades",
        },
        ['Eyes'] = {
            "Eyes of the Howler Rk. III",
            "Eyes of the Howler Rk. II",
            "Eyes of the Howler",
            "Eyes of the Raptor",
            "Eyes of the Wolf",
            "Eyes of the Nocturnal",
            "Eyes of the Peregrine",
            "Eyes of the Owl",
            "Eagle Eye",
            "Falcon Eye",
            "Hawk Eye",
        },
        ['GroupStrengthBuff'] = {
            "Strength of the Bosquestalker Rk. III",
            "Strength of the Bosquestalker Rk. II",
            "Strength of the Bosquestalker",
            "Strength of the Gladetender",
            "Strength of the Thicket Stalker",
            "Strength of the Tracker",
            "Strength of the Gladewalker",
            "Strength of the Forest Stalker",
            "Strength of the Hunter",
            "Strength of Tunare",
            "Strength of Nature",
        },
        ['GroupPredatorBuff'] = {
            "Shout of the Predator Rk. III",
            "Shout of the Predator Rk. II",
            "Shout of the Predator",
            "Cry of the Predator",
            "Roar of the Predator",
            "Yowl of the Predator",
            "Gnarl of the Predator",
            "Snarl of the Predator",
            "Howl of the Predator",
            "Spirit of the Predator",
            "Call of the Predator",
            "Mark of the Predator",
        },
        ['GroupEnrichmentBuff'] = {
        },
        ['Rathe'] = {
            "Cloak of Spurs Rk. III",
            "Cloak of Spurs Rk. II",
            "Cloak of Spurs",
            "Cloak of Burrs",
            "Cloak of Quills",
            "Cloak of Feathers",
            "Cloak of Scales",
            "Guard of the Earth",
            "Call of the Rathe",
            "Call of Earth",
        },
        ['BowDisc'] = {
            "Pureshot Discipline Rk. III",
            "Pureshot Discipline Rk. II",
            "Pureshot Discipline",
            "Sureshot Discipline",
            "Aimshot Discipline",
            "Trueshot Discipline",
        },
        ['MeleeDisc'] = {
        },
        ['DefenseDisc'] = {
            "Weapon Affinity Discipline",
            "Weapon Affiliation",
            "Weapon Affiliation Rk. II",
            "Weapon Affiliation Rk. III",
            "Weapon Bond",
            "Weapon Bond Rk. II",
            "Weapon Bond Rk. III",
            "Weapon Covenant",
            "Weapon Covenant Rk. II",
            "Weapon Covenant Rk. III",
            "Weapon Shield Discipline",
        },
        ['Fireboon'] = {
            "Ashcloud Boon Rk. III",
            "Ashcloud Boon Rk. II",
            "Ashcloud Boon",
        },
        ['Firenuke'] = {
            "Vileoak Ash Rk. III",
            "Vileoak Ash Rk. II",
            "Vileoak Ash",
            "Beastwood Ash",
            "Burning Ash",
            "Cataclysm Ash",
            "Galvanic Ash",
            "Volcanic Ash",
            "Scorched Earth",
            "Hearth Embers",
            "Sylvan Burn",
            "Ancient: Burning Chaos",
            "Brushfire",
            "FireStrike",
            "Call of Flame",
            "Burning Arrow",
            "Flaming Arrow",
            "Ignite",
            "Burst of Fire",
            "Flame Lick",
        },
        ['Iceboon'] = {
            "Windblast Boon Rk. III",
            "Windblast Boon Rk. II",
            "Windblast Boon",
        },
        ['Icenuke'] = {
            "Bitter Wind Rk. III",
            "Bitter Wind Rk. II",
            "Bitter Wind",
            "Biting Wind",
            "Windwhip Bite",
            "Rimefall Bite",
            "Icefall Chill",
            "Ancient: North Wind",
            "Frost Wind",
            "Frozen Wind",
            "Frozen Wind",
            "Icewind",
        },
        ['Heartshot'] = {
            "Heartslash Rk. III",
            "Heartslash Rk. II",
            "Heartslash",
            "Heartslice",
            "Heartsting",
            "Heartsting",
            "Heartshot",
        },
        ['EndRegenDisc'] = {
            "Rest Rk. III",
            "Rest Rk. II",
            "Rest",
            "Reprieve",
            "Respite",
        },
        ['Coat'] = {
            "Spurcoat Rk. III",
            "Spurcoat Rk. II",
            "Spurcoat",
            "Burrcoat",
            "Quillcoat",
            "Spinecoat",
            "Briarcoat",
            "Bladecoat",
            "Thorncoat",
            "Spikecoat",
            "Bramblecoat",
            "Barbcoat",
            "Thistlecoat",
        },
        ['Mask'] = {
            "Mask of the Hunter",
            "Mask of the Forest",
            "Mask of the Wild",
            "Mask of the Doll",
            "Mask of the Shadowcat",
            "Mask of the Shadowcat Rk. II",
            "Mask of the Shadowcat Rk. III",
            "Mask of the Raptor",
            "Mask of the Raptor Rk. II",
            "Mask of the Raptor Rk. III",
            "Mask of the Arboreal",
            "Mask of the Arboreal Rk. II",
            "Mask of the Arboreal Rk. III",
            "Mask of the Thicket Dweller",
            "Mask of the Thicket Dweller Rk. II",
            "Mask of the Thicket Dweller Rk. III",
            "Mask of the Bosquetender",
            "Mask of the Bosquetender Rk. II",
            "Mask of the Bosquetender Rk. III",
            "Mask of the Stalker",
        },
        ['Hunt'] = {
            "Inspired by the Hunt Rk. III",
            "Inspired by the Hunt Rk. II",
            "Inspired by the Hunt",
            "Galvanized by the Hunt",
            "Invigorated by the Hunt",
            "Consumed by the Hunt",
        },
        ['Heal'] = {
            "Cloudburst Rk. III",
            "Cloudburst Rk. II",
            "Cloudburst",
            "Purespring",
            "Purefont",
            "Oceangreen Aquifer",
            "Dragonscale Aquifer",
            "Sunderock Springwater",
            "Sylvan Water",
            "Sylvan Light",
            "Chloroblast",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
            "Salve",
        },
        ['Fastheal'] = {             -- 30s recast. ToT
            "Desperate Drenching Rk. III",
            "Desperate Drenching Rk. II",
            "Desperate Drenching",
            "Desperate Downpour",
            "Desperate Deluge",
        },
        ['Totheal'] = {
            "Cloudburst Rk. III",
            "Cloudburst Rk. II",
            "Cloudburst",
        },
        ['RegenSpells'] = {
            "Regrowth of the Grove",
            "Regrowth of Dar Khura",
            "Regrowth",
            "Chloroplast",
        },
        ['SnareSpells'] = {
            "Earthen Roots",
            "Earthen Strength",
            "Earthen Stance",
            "Earthen Stance Rk. II",
            "Earthen Stance Rk. III",
            "Earthen Shackles",
            "Earthen Embrace",
            "Ensnare",
            "Snare",
            "Tangling Weeds",
        },
        ['FireFist'] = {
            "Feral Spirit",
            "Feral Pack",
            "Feral Vigor",
            "Feral Guard",
            "Feralize",
            "Feralize Rk. II",
            "Feralize Rk. III",
            "Feralisis",
            "Feralisis Rk. II",
            "Feralisis Rk. III",
            "Feralization",
            "Feralization Rk. II",
            "Feralization Rk. III",
            "Feralescense",
            "Feralescense Rk. II",
            "Feralescense Rk. III",
            "Feralisera",
            "Feralisera Rk. II",
            "Feralisera Rk. III",
            "Feralisenia",
            "Feralisenia Rk. II",
            "Feralisenia Rk. III",
            "Feral Form",
            "Greater Wolf Form",
            "Wolf Form",
            "Firefist",
        },
        ['DsBuff'] = {
            "Shield of Nettlespines Rk. III",
            "Shield of Nettlespines Rk. II",
            "Shield of Nettlespines",
            "Shield of Bramblespikes",
            "Shield of Nettlespikes",
            "Shield of DrySpines",
            "Shield of Spurs",
            "Shield of Needles",
            "Shield of Briar",
            "Shield of Thorns",
            "Shield of Spikes",
            "Shield of Brambles",
            "Shield of Thistles",
        },
        ['SkinLike'] = {
            "Natureskin",
            "Skin Like Nature",
            "Skin Like Diamond",
            "Skin Like Steel",
            "Skin Like Rock",
            "Skin Like Wood",
        },
        ['MoveSpells'] = {
            "Spirit Sight",
            "Spirit of Monkey",
            "Spirit Strength",
            "Spirit of Cat",
            "Spirit of Ox",
            "Spirit of Cheetah",
            "Spirit Pouch",
            "Spirit of Bear",
            "Spirit Strike",
            "Spirit of Snake",
            "Spirit Armor",
            "Spirit Tap",
            "Spirit Quickening",
            "Spirit of Scale",
            "Spirit of Oak",
            "Spirit of the Howler",
            "Spiritual Light",
            "Spiritual Radiance",
            "Spiritual Brawn",
            "Spirit of Bih`Li",
            "Spirit of Sharik",
            "Spirit of Keshuval",
            "Spirit of Herikol",
            "Spirit of Yekan",
            "Spirit of Kashek",
            "Spirit of Omakin",
            "Spirit of Zehkes",
            "Spirit of Khurenz",
            "Spiritual Purity",
            "Spiritual Strength",
            "Spirit of Khati Sha",
            "Spirit of Khaliz",
            "Spirit of Lightning",
            "Spirit of the Blizzard",
            "Spirit of Inferno",
            "Spirit of the Scorpion",
            "Spirit of Vermin",
            "Spirit of Wind",
            "Spirit of the Storm",
            "Spirit of Flame",
            "Spirit of Snow",
            "Spirit of the Predator",
            "Spiritual Vigor",
            "Spirit of Arag",
            "Spirit of Rellic",
            "Spiritual Dominion",
            "Spirit of Sorsha",
            "Spirit of Ash",
            "Spirit of Rage Discipline",
            "Spirit of Sense",
            "Spirit of Perseverance",
            "Spirit of Fortitude",
            "Spirit Veil",
            "Spirit of Might",
            "Spiritual Serenity",
            "Spiritual Vitality",
            "Spirit of Alladnu",
            "Spirit of Irionu",
            "Spiritual Ascendance",
            "Spirit of Rashara",
            "Spirit of the Panther",
            "Spirit of the Leopard",
            "Spirit Salve",
            "Spirit of the Puma",
            "Spirit of the Jaguar",
            "Spirit of Oroshar",
            "Spirit of the Stoic One",
            "Spirit of the Stoic One Rk. II",
            "Spirit of the Stoic One Rk. III",
            "Spiritual Vim",
            "Spiritual Vim Rk. II",
            "Spiritual Vim Rk. III",
            "Spirit of Lairn",
            "Spirit of Lairn Rk. II",
            "Spirit of Lairn Rk. III",
            "Spiritual Enlightenment",
            "Spiritual Enlightenment Rk. II",
            "Spiritual Enlightenment Rk. III",
            "Spirit of Uluanes",
            "Spiritual Vivacity",
            "Spiritual Vivacity Rk. II",
            "Spiritual Vivacity Rk. III",
            "Spirit of Jeswin",
            "Spirit of Jeswin Rk. II",
            "Spirit of Jeswin Rk. III",
            "Spiritual Epiphany",
            "Spiritual Epiphany Rk. II",
            "Spiritual Epiphany Rk. III",
            "Spirit of Silverwing",
            "Spirit of the Stalwart",
            "Spirit of the Stalwart Rk. II",
            "Spirit of the Stalwart Rk. III",
            "Spirit of Vehemence",
            "Spirit of Vehemence Rk. II",
            "Spirit of Vehemence Rk. III",
            "Spiritual Verve",
            "Spiritual Verve Rk. II",
            "Spiritual Verve Rk. III",
            "Spirit of Vaxztn",
            "Spirit of Vaxztn Rk. II",
            "Spirit of Vaxztn Rk. III",
            "Spiritual Edification",
            "Spiritual Edification Rk. II",
            "Spiritual Edification Rk. III",
            "Spirit of Hoshkar",
            "Spirit of the Resolute",
            "Spirit of the Resolute Rk. II",
            "Spirit of the Resolute Rk. III",
            "Spirit of Determination",
            "Spirit of Determination Rk. II",
            "Spirit of Determination Rk. III",
            "Spirit of the Relentless",
            "Spirit of the Relentless Rk. II",
            "Spirit of the Relentless Rk. III",
            "Spirit of Valor",
            "Spirit of Valor Rk. II",
            "Spirit of Valor Rk. III",
            "Spiritual Valor",
            "Spiritual Valor Rk. II",
            "Spiritual Valor Rk. III",
            "Spirit of Averc",
            "Spirit of Kron",
            "Spirit of Kron Rk. II",
            "Spirit of Kron Rk. III",
            "Spiritual Enhancement",
            "Spiritual Enhancement Rk. II",
            "Spiritual Enhancement Rk. III",
            "Spirit of the Indomitable",
            "Spirit of the Indomitable Rk. II",
            "Spirit of the Indomitable Rk. III",
            "Spirit of Resolve",
            "Spirit of Resolve Rk. II",
            "Spirit of Resolve Rk. III",
            "Spiritual Valiance",
            "Spiritual Valiance Rk. II",
            "Spiritual Valiance Rk. III",
            "Spirit of Kolos",
            "Spirit of Bale",
            "Spirit of Bale Rk. II",
            "Spirit of Bale Rk. III",
            "Spiritual Enrichment",
            "Spiritual Enrichment Rk. II",
            "Spiritual Enrichment Rk. III",
            "Spirited Axe Throw",
            "Spirited Axe Throw Rk. II",
            "Spirited Axe Throw Rk. III",
            "Spirit of the Steadfast",
            "Spirit of the Steadfast Rk. II",
            "Spirit of the Steadfast Rk. III",
            "Spirit of Dauntlessness",
            "Spirit of Dauntlessness Rk. II",
            "Spirit of Dauntlessness Rk. III",
            "Spiritual Vindication",
            "Spiritual Vindication Rk. II",
            "Spiritual Vindication Rk. III",
            "Spirit of Lachemit",
            "Spirit of Nak",
            "Spirit of Nak Rk. II",
            "Spirit of Nak Rk. III",
            "Spiritual Evolution",
            "Spiritual Evolution Rk. II",
            "Spiritual Evolution Rk. III",
            "Spirit Bolstering",
            "Spirit Bolstering Rk. II",
            "Spirit Bolstering Rk. III",
            "Spiritual Surge",
            "Spiritual Surge Rk. II",
            "Spiritual Surge Rk. III",
            "Spiritual Unity",
            "Spiritual Unity Rk. II",
            "Spiritual Unity Rk. III",
            "Spirit of Eagle",
            "Pack Shrew",
            "Spirit of the Shrew",
            "Spirit of Wolf",
        },
        ['Alliance'] = {
        },
        ['Cloak'] = {
        },
        ['Veil'] = {
            "Arbor Veil Rk. III",
            "Arbor Veil Rk. II",
            "Arbor Veil",
            "Veil of Alaris",
            "Nature Veil",
        },
        ['JoltingKicks'] = {
            "Jolting Heel Kicks Rk. III",
            "Jolting Heel Kicks Rk. II",
            "Jolting Heel Kicks",
            "Jolting Crescent Kicks",
            "Jolting Hook Kicks",
            "Jolting Frontkicks",
            "Jolting Kicks",
        },
        ['AEBlades'] = {
            "Storm of Blades Rk. III",
            "Storm of Blades Rk. II",
            "Storm of Blades",
        },
        ['FocusedBlades'] = {
            "Focused Storm of Blades Rk. III",
            "Focused Storm of Blades Rk. II",
            "Focused Storm of Blades",
        },
        ['ReflexSlashHeal'] = {
            "Reflexive Bladespurs Rk. III",
            "Reflexive Bladespurs Rk. II",
            "Reflexive Bladespurs",
        },
        ['AEArrows'] = {
            "Rain of Arrows Rk. III",
            "Rain of Arrows Rk. II",
            "Rain of Arrows",
            "Squall of Arrows",
            "Arrow Swarm",
            "Swarm of Arrows",
            "Tempest of Arrows",
            "Fusillade of Arrows",
            "Storm of Arrows",
            "Barrage of Arrows",
            "Arc of Arrows",
            "Hail of Arrows",
        },
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent decisions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['MainHealPoint'] = {
            {
                name = "Fastheal",
                type = "Spell",
                cond = function(self, _, target)
                    return Config:GetSetting('DoHeals')
                end,
            },
            {
                name = "Heal",
                type = "Spell",
                cond = function(self, _, target)
                    return Config:GetSetting('DoHeals')
                end,
            },
        },
    },
    ['Charm']             = {
        ['Assist'] = {
            { name = "Taunt", type = "Ability", },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Casting.GetBuffableIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Ranged Positioning',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Config:GetSetting('DoMelee') and not Core.IsModeActive("Healer")
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'DPS Buffs',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Defense',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Tank',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            load_cond = function(self, spell) return Core.IsTanking() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']         = {
        ['Downtime'] = {
            {
                name = "Wildstalker's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.UnityBuff,
                active_cond = function(self, aaName) return Casting.TargetHasBuff(mq.TLO.Me.AltAbility(aaName).Spell, mq.TLO.Me) end,
                cond = function(self, aaName)
                    return castWSU() and not Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Protectionbuff",
                type = "Spell",
                tooltip = Tooltips.Protectionbuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "ParryProcBuff",
                type = "Spell",
                tooltip = Tooltips.ParryProcBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Hunt",
                type = "Spell",
                tooltip = Tooltips.Hunt,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Eyes",
                type = "Spell",
                tooltip = Tooltips.Eyes,
                load_cond = function(self) return not Config:GetSetting('DoMask') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return not castWSU() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Coat",
                type = "Spell",
                tooltip = Tooltips.Coat,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Mask",
                type = "Spell",
                tooltip = Tooltips.Mask,
                load_cond = function(self) return Config:GetSetting('DoMask') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FireFist",
                type = "Spell",
                tooltip = Tooltips.FireFist,
                load_cond = function(self) return Config:GetSetting('DoFireFist') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "DsBuff",
                type = "Spell",
                tooltip = Tooltips.DsBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SkinLike",
                type = "Spell",
                tooltip = Tooltips.SkinLike,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Cloak",
                type = "Spell",
                tooltip = Tooltips.Cloak,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Veil",
                type = "Spell",
                tooltip = Tooltips.Veil,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AggroReducerBuff",
                type = "Spell",
                tooltip = Tooltips.AggroReducerBuff,
                load_cond = function(self, spell) return not Core.IsTanking() end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Config:GetSetting('DoAggroReducerBuff') and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AggroBuff",
                type = "Spell",
                tooltip = Tooltips.AggroBuff,
                load_cond = function(self, spell) return Core.IsTanking() end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return not Config:GetSetting('DoAggroReducerBuff') and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Poison Arrows",
                type = "AA",
                tooltip = Tooltips.PoisonArrow,
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName) and Config:GetSetting('DoPoisonArrow')
                end,
            },
            {
                name = "Flaming Arrows",
                type = "AA",
                tooltip = Tooltips.FlamingArrow,
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName, target)
                    return Casting.SelfBuffAACheck(aaName) and (mq.TLO.Me.Level() < 86 or not Config:GetSetting('DoPoisonArrow'))
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Rathe",
                type = "Spell",
                tooltip = Tooltips.Rathe,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupStrengthBuff",
                type = "Spell",
                tooltip = Tooltips.GroupStrengthBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupPredatorBuff",
                type = "Spell",
                tooltip = Tooltips.GroupPredatorBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ShoutBuff",
                type = "Spell",
                tooltip = Tooltips.ShoutBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupEnrichmentBuff",
                type = "Spell",
                tooltip = Tooltips.GroupEnrichmentBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                tooltip = Tooltips.MoveSpells,
                load_cond = function(self) return Config:GetSetting('DoRunSpeed') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if Config.TempSettings.NoLevZone then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "RegenSpells",
                type = "Spell",
                tooltip = Tooltips.RegenSpells,
                load_cond = function(self) return Config:GetSetting('DoRegen') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Pack Hunt",
                type = "AA",
                tooltip = Tooltips.PackHunt,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Entropy of Nature",
                type = "AA",
                tooltip = Tooltips.EoN,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Spire of the Pathfinders",
                type = "AA",
                tooltip = Tooltips.SotP,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Scarlet Cheetah's Fang",
                type = "AA",
                tooltip = Tooltips.SCF,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Empowered Blades",
                type = "AA",
                tooltip = Tooltips.EB,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Auspice of the Hunter",
                type = "AA",
                tooltip = Tooltips.AotH,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "BowDisc",
                type = "Disc",
                tooltip = Tooltips.BowDisc,
                cond = function(self)
                    return Casting.NoDiscActive() and not Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "MeleeDisc",
                type = "Disc",
                tooltip = Tooltips.MeleeDisc,
                cond = function(self)
                    return Casting.NoDiscActive() and Config:GetSetting('DoMelee')
                end,
            },
        },
        ['Tank'] = {
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.TargetOfTarget.ID() ~= mq.TLO.Me.ID() and target.ID() > 0 and Targeting.GetTargetDistance(target) < 30
                end,
            },
            {
                name = "AggroKick",
                type = "Disc",
                tooltip = Tooltips.AggroKick,
                cond = function(self)
                    return Targeting.GetTargetDistance() <= 50 and mq.TLO.Me.PctAggro() > 50
                end,
            },
            {
                name = "SummerNuke",
                type = "Spell",
                tooltip = Tooltips.SummerNuke,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and (mq.TLO.Me.PctAggro() < 100 or mq.TLO.Me.SecondaryPctAggro() > 50)
                end,
            },
        },
        ['Ranged Positioning'] = {
            {
                name = "Ranged Nav",
                type = "CustomFunc",
                custom_func = function(self)
                    Core.SafeCallFunc("Ranger Ranged Nav", self.Helpers.rangedNav)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "ArrowOpener",
                type = "Spell",
                tooltip = Tooltips.ArrowOpener,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and Config:GetSetting('DoOpener') and Config:GetSetting('DoReagentArrow')
                end,
            },
            {
                name = "PullOpener",
                type = "Spell",
                tooltip = Tooltips.PullOpener,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and Config:GetSetting('DoReagentArrow')
                end,
            },
            {
                name = "CalledShotsArrow",
                type = "Spell",
                tooltip = Tooltips.CalledShotsArrow,
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "FocusedArrows",
                type = "Spell",
                tooltip = Tooltips.FocusedArrows,
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                tooltip = Tooltips.DichoSpell,
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Heartshot",
                type = "Spell",
                tooltip = Tooltips.Heartshot,
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Fireboon",
                type = "Spell",
                tooltip = Tooltips.Fireboon,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and not Casting.SelfBuffCheck(spell) --hardcode later, we need trigger
                end,
            },
            {
                name = "Iceboon",
                type = "Spell",
                tooltip = Tooltips.Iceboon,
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and not Casting.SelfBuffCheck(spell) --hardcode later, we need trigger
                end,
            },
            {
                name = "Entrap",
                tooltip = Tooltips.Entrap,
                type = "AA",
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoSnare') and Casting.DetAACheck(aaName) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareSpells",
                type = "Spell",
                tooltip = Tooltips.SnareSpells,
                cond = function(self, spell, target)
                    return Config:GetSetting('DoSnare') and Casting.DetSpellCheck(spell) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "AEArrows",
                type = "Spell",
                tooltip = Tooltips.AEArrows,
                cond = function(self, spell)
                    return Casting.OkayToNuke() and Config:GetSetting('DoAoE')
                end,
            },
            {
                name = "SwarmDot",
                type = "Spell",
                tooltip = Tooltips.SwarmDot,
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "ShortSwarmDot",
                type = "Spell",
                tooltip = Tooltips.ShortSwarmDot,
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "Firenuke",
                type = "Spell",
                tooltip = Tooltips.Firenuke,
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Icenuke",
                type = "Spell",
                tooltip = Tooltips.Icenuke,
                cond = function(self, spell)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Elemental Arrow",
                tooltip = Tooltips.EA,
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "AEBlades",
                type = "Disc",
                tooltip = Tooltips.AEBlades,
                cond = function(self)
                    return Config:GetSetting('DoAoE') and Targeting.GetTargetDistance() < 50 and Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "FocusedBlades",
                type = "Disc",
                tooltip = Tooltips.FocusedBlades,
                cond = function(self)
                    return Targeting.GetTargetDistance() < 50 and Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "ReflexSlashHeal",
                type = "Disc",
                tooltip = Tooltips.ReflexSlashHeal,
                cond = function(self)
                    return Targeting.GetTargetDistance() < 50 and Config:GetSetting('DoMelee')
                end,
            },
            {
                name = "EndRegenDisc",
                type = "Disc",
                tooltip = Tooltips.EndRegenDisc,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive() and not Casting.IHaveBuff(discSpell.RankName.Name() or "") and mq.TLO.Me.PctEndurance() < 30
                end,
            },
            {
                name = "Kick",
                type = "Ability",
            },
        },
        ['DPS Buffs'] = {
            {
                name = "Guardian of the Forest",
                type = "AA",
                tooltip = Tooltips.GotF,
                cond = function(self, spell)
                    return not Casting.IHaveBuff("Group Guardian of the Forest") and not Casting.IHaveBuff("Outrider's Accuracy")
                end,
            },
            {
                name = "Outrider's Accuracy",
                type = "AA",
                tooltip = Tooltips.OA,
                cond = function(self, spell)
                    return not Casting.IHaveBuff("Group Guardian of the Forest") and not Casting.IHaveBuff("Guardian of the Forest")
                end,
            },
            {
                name = "Group Guardian of the Forest",
                type = "AA",
                tooltip = Tooltips.GGotF,
                cond = function(self, spell)
                    return not Casting.IHaveBuff("Guardian of the Forest") and not Casting.IHaveBuff("Outrider's Accuracy")
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName)
                    return Casting.NoDiscActive()
                end,
            },
        },
        ['Defense'] = {
            {
                name = "DefenseDisc",
                type = "Disc",
                tooltip = Tooltips.DefenseDisc,
                cond = function(self)
                    return mq.TLO.Me.PctHPs() < 20 and Casting.NoDiscActive()
                end,
            },
            {
                name = "Outrider's Evasion",
                tooltip = Tooltips.OE,
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctHPs() < 30
                end,
            },
            {
                name = "Protection of the Spirit Wolf",
                tooltip = Tooltips.PotSW,
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctHPs() < 40
                end,
            },
            {
                name = "Bulwark of the Brownies",
                tooltip = Tooltips.BotB,
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctHPs() < 50
                end,
            },
            {
                name = "JoltingKicks",
                type = "Disc",
                tooltip = Tooltips.JoltingKicks,
                cond = function(self)
                    return Targeting.GetTargetDistance() <= 50
                end,
            },
            {
                name = "Imbued Ferocity",
                type = "AA",
                tooltip = Tooltips.IF,
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctAggro() > 45
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                tooltip = Tooltips.SS,
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctAggro() > 60
                end,
            },
            {
                name = "Chameleon's Gift",
                type = "AA",
                tooltip = Tooltips.CG,
                cond = function(self, spell)
                    return mq.TLO.Me.PctAggro() > 70 and mq.TLO.Me.PctHPs() < 50
                end,
            },
            {
                name = "SummerNuke",
                type = "Spell",
                tooltip = Tooltips.SummerNuke,
                cond = function(self, spell)
                    return mq.TLO.Me.PctAggro() < 60
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "Fastheal", },
                { name = "Heal", },
            },
        },
        { -- SpellGem2 - Is Our Standard Fire Nuke 3-115
            gem = 2,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Firenuke", },
            },
        },
        { -- SpellGem 3 - This is Our Swarm Dot From 25 to 115
            gem = 3,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SwarmDot", },
            },
        },
        { -- Use ArrowOpener if enabled or Snare if no AASnare
            gem = 4,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ArrowOpener", cond = function(self) return Config:GetSetting('DoOpener') end, },
                { name = "SnareSpells", cond = function(self) return not Casting.DetAACheck(mq.TLO.Me.AltAbility(219).Name()) and Config:GetSetting('DoSnare') end, },
            },
        },
        {
            gem = 5,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "DichoSpell", cond = function(self) return mq.TLO.Me.Level() >= 101 end, },
                { name = "Icenuke", },
            },
        },
        {
            gem = 6,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "CalledShotsArrow", },
            },
        },
        {
            gem = 7,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FocusedArrows", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Heartshot", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SummerNuke", },
                { name = "AEArrows",   cond = function(self) return Config:GetSetting('DoAoE') end, },
                { name = "Veil", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ShortSwarmDot", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Iceboon", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Fireboon", },
                { name = "Icenuke", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Alliance", },
            },
        },
    },
    ['Helpers']           = {
        rangedNav = function(reason)
            if Config:GetSetting('DoMelee') then return end
            if (Globals.AutoTargetID or 0) == 0 then return end

            local bowRange = Config:GetSetting('BowRange')

            if reason then
                Logger.log_verbose("rangedNav: reason=%s dist=%d bowRange=%d stick=%s LoS=%s", reason,
                    Targeting.GetTargetDistance(), bowRange, Config:GetSetting('UseRangedStick'), mq.TLO.Target.LineOfSight())
            end

            if not mq.TLO.Me.Moving() then
                Core.DoCmd('/squelch /face fast')
            end

            if not mq.TLO.Me.AutoFire() then
                Core.DoCmd('/autofire on')
            end

            -- No line of sight: sweep laterally around the target for a spot with a real (game) clear shot.
            if reason == "cantsee" then
                if not Movement:NavAroundCircle(mq.TLO.Target, bowRange) then
                    -- Nav can't path (off the mesh): stick toward the target to walk back onto it.
                    Logger.log_warn("Ranged nav: no navigable line-of-sight spot (off mesh?), falling back to a stick.")
                    Movement:DoStickCmd("%d id %d moveback uw", bowRange, Globals.AutoTargetID)
                    if not Config:GetSetting('UseRangedStick') then
                        -- Loose holds nothing: run the stick only until we regain line of sight, then drop it.
                        mq.delay(100, function() return mq.TLO.Stick.Active() end)
                        mq.delay(3000, function() return mq.TLO.Target.ID() == 0 or mq.TLO.Target.LineOfSight() end)
                        Movement:DoStickCmd("off")
                        Movement:ClearLastStickTimer()
                    end
                end
                return
            end

            if Config:GetSetting('UseRangedStick') then -- Use Ranged Stick: hold bow range with a stick.
                if reason == "toofar" or Targeting.GetTargetDistance() > bowRange + 10 then
                    if not mq.TLO.Navigation.Active() then
                        Movement:DoNav(true, "id %d distance=%d lineofsight=on", Globals.AutoTargetID, bowRange)
                        Core.DoCmd('/squelch /face fast')
                    end
                elseif (mq.TLO.Stick.StickTarget() or 0) ~= Globals.AutoTargetID or (mq.TLO.Stick.Status() or "off"):lower() == "off" then
                    Core.DoCmd('/squelch /face fast')
                    local stickHow = Config:GetSetting('StickHow') or ""
                    if #stickHow > 0 then
                        Movement:DoStickCmd("%s", stickHow)
                    else
                        Movement:DoStickCmd("%d id %d moveback uw", bowRange, Globals.AutoTargetID)
                    end
                end
            else -- Loose: react to the game's own range messages, one-shot, no held position.
                if reason == "toofar" then
                    Movement:DoNav(true, "id %d distance=%d lineofsight=on", Globals.AutoTargetID, bowRange)
                    Core.DoCmd('/squelch /face fast')
                elseif reason == "tooclose" then
                    Core.DoCmd('/squelch /face fast')
                    Movement:DoStickCmd("%d moveback uw", bowRange)
                    mq.delay(100, function() return mq.TLO.Stick.Active() end)
                    mq.delay(500, function() return not mq.TLO.Me.Moving() end)
                    Movement:DoStickCmd("off")
                    Movement:ClearLastStickTimer()
                end
            end
        end,

        PreEngage = function(target)
            if not target or not target() then return end
            local openerAbility = Core.GetResolvedActionMapItem('ArrowOpener')

            if not Config:GetSetting("DoOpener") or not openerAbility then return end

            Logger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility.RankName.Name() or "None")

            if openerAbility and openerAbility() and mq.TLO.Me.PctMana() >= Config:GetSetting("ManaToNuke") and Casting.SpellReady(openerAbility) then
                Core.DoCmd("/squelch /face fast")
                Casting.UseSpell(openerAbility.RankName.Name(), target.ID(), false)
                Logger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility.RankName.Name() or "None")
            else
                Logger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %sd", openerAbility.RankName.Name() or "None",
                    Strings.BoolToColorString(Config:GetSetting("DoOpener")))
            end
        end,
    },
    ['PullAbilities']     = {
        {
            id = 'Snare',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SnareSpells')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SnareSpells')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SnareSpells')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']               = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 4,
            FAQ = "What do the different Modes Do?",
            Help = "Modes are used to change the behavior of the Mercenary based on the current situation. The modes are as follows:\n\n" ..
                "1. DPS - This mode is used for general DPS and is the default mode.\n" ..
                "2. Tank - This mode is used when you are tanking.\n" ..
                "3. Healer - This mode is used when you are healing.\n" ..
                "4. Hybrid - This mode is a combination of the other 3 and will attempt to be a jack of all trades.",
        },
        --Archery
        ['BowRange']           = {
            DisplayName = "Bow Range",
            Group = "Combat",
            Header = "Positioning",
            Category = "Archery",
            Index = 101,
            Tooltip = "The preferred distance to reposition to if we are too close/far or have no LoS (also the default range for ranged stick).",
            Default = 40,
            Min = 31,
            Max = 300,
            FAQ = "Why is my ranger rubber-banding, charging back and forth or changing heading constantly?",
            Answer = "Some terrain blocks LoS while MQ reports that the ranger has LoS.\n" ..
                "While we will attempt to solve this issue, manual intervention or setting adjustment may be required (Bow Range, Ranged Stick, etc).",
        },
        ['UseRangedStick']     = {
            DisplayName = "Use Ranged Stick",
            Group = "Combat",
            Header = "Positioning",
            Category = "Archery",
            Index = 102,
            Tooltip = "Disabled - autofire from present position, moving only if needed (too close/far, no LoS).\n" ..
                "Enabled - use stick while autofiring. Uses Stick How setting if set, otherwise uses '<bowrangesetting> moveback uw'",
            Default = false,
            Warning = function()
                if not Config:GetSetting('UseRangedStick') then return false, "" end
                local bowRange = Config:GetSetting('BowRange')
                if Config:GetSetting('ChaseOn') then
                    if Config:GetSetting('ChaseDistance') < bowRange then
                        return true, "Warning: Chase Distance is below Bow Range - chase may fight the ranged stick hold."
                    end
                elseif Config:GetSetting('ReturnToCamp') and Config:GetSetting('CampLeashCombat') and Config:GetSetting('AutoCampRadius') < bowRange then
                    return true, "Warning: Camp Radius is below Bow Range - Leash to Camp (Combat) may fight the ranged stick hold."
                end
                return false, ""
            end,
            FAQ = "Why is my ranger rubber-banding, charging back and forth or changing heading constantly?",
            Answer = "Turn off Use Ranged Stick (the default), so the ranger only repositions when a shot is actually refused instead of holding position.",
        },
        ['DoSnare']            = {
            DisplayName = "Cast Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Tooltip = "Enable casting Snare spells.",
            Default = true,
        },
        ['DoDot']              = {
            DisplayName = "Cast DOTs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
        },
        ['DoHeals']            = {
            DisplayName = "Cast Heals",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Tooltip = "Enable casting of Healing spells.",
            Default = true,
        },
        ['DoRegen']            = {
            DisplayName = "Cast Regen Spells",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Enable casting of Regen spells.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoRunSpeed']         = {
            DisplayName = "Cast Run Speed Buffs",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use Ranger Run Speed Buffs.",
            Default = true,
        },
        ['DoMask']             = {
            DisplayName = "Cast Mask Spell",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Use Ranger Mask Spell",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoFireFist']         = {
            DisplayName = "Cast FireFist",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Use Ranger FireFist Line of Spells",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoAoE']              = {
            DisplayName = "Use AoEs",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Tooltip = "Enable AoE abilities and spells.",
            Default = false,
        },
        ['DoOpener']           = {
            DisplayName = "Use Openers",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Opening Arrow Shot Silent Shot Line.",
            Default = true,
        },
        ['DoPoisonArrow']      = {
            DisplayName = "Use Poison Arrow",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Enable use of Poison Arrow.",
            Default = true,
        },
        ['DoReagentArrow']     = {
            DisplayName = "Use Reagent Arrow",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Toggle usage of Spells and Openers that require Reagent arrows.",
            Default = false,
        },
        ['DoAggroReducerBuff'] = {
            DisplayName = "Cast Aggro Reducer Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Use Aggro Reduction Buffs.",
            Default = true,
        },
        ['HealPriority']       = {
            DisplayName = "Healing Priority",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Index = 101,
            Type = "Combo",
            ComboOptions = { 'Ignore', 'Big Heal Point', },
            Default = 2,
            Min = 1,
            Max = 2,
            Tooltip = "When to yield offensive rotations for healing:\n1 - Ignore (never)\n2 - Big Heal Point",
            ConfigType = "Advanced",
        },
    },
    ['ClassFAQ']          = {
        {
            Question = "What is the current status of this class config?",
            Answer = "This class config is a current release aimed at official servers.\n\n" ..
                "  This config is largely a port from older code, and has seen only minor adjustments. It has been flagged for revamp when we have the chance!\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },

}

return _ClassConfig
