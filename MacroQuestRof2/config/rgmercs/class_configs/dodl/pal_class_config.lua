local mq           = require('mq')
local Set          = require('mq.set')
local Casting      = require("utils.casting")
local Combat       = require("utils.combat")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require('utils.globals')
local ItemManager  = require("utils.item_manager")
local Logger       = require("utils.logger")
local Targeting    = require("utils.targeting")
local Ui           = require("utils.ui")

local _ClassConfig = {
    _version              = "DODL CUSTOM",
    _author               = "eldudero",
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsHealing = function() return true end,
        IsCuring  = function() return Config:GetSetting('DoCures') end,
        IsRezing  = function()
            return (Core.GetResolvedActionMapItem('RezSpell') and Targeting.GetXTHaterCount() == 0) or
                (Casting.CanUseAA("Gift of Resurrection") and Config:GetSetting('DoBattleRez'))
        end,
    },
    ['Rez']               = {
        ['Combat'] = {
            { type = "AA", name = "Gift of Resurrection", },
        },
        ['Downtime'] = {
            { type = "AA", name = "Gift of Resurrection", },
            {
                type = "Spell",
                name = "RezSpell",
                cond = function(self, spell, target)
                    return Casting.DowntimeRezOkay()
                        and not Casting.CanUseAA('Gift of Resurrection')
                end,
            },
        },
    },
    ['Modes']             = {
        'Tank',
        'DPS',
    },
    ['Cure']              = {
        ['DetDispel'] = {
            { type = "AA", name = "Radiant Cure", },
            { type = "AA", name = "Purification", selfOnly = true, },
        },
        ['Poison'] = {
            { type = "Spell", name = "SplashHeal", load_cond = function(self) return self.Helpers.UseSplashHealCure(self) end, },
            { type = "Spell", name = "PurityCure", },
        },
        ['Disease'] = {
            { type = "Spell", name = "SplashHeal", load_cond = function(self) return self.Helpers.UseSplashHealCure(self) end, },
            { type = "Spell", name = "PurityCure", },
        },
        ['Curse'] = {
            { type = "Spell", name = "SplashHeal", load_cond = function(self) return self.Helpers.UseSplashHealCure(self) end, },
            { type = "Spell", name = "PurityCure", },
        },
        ['Corruption'] = {
            { type = "Spell", name = "SplashHeal",  load_cond = function(self) return self.Helpers.UseSplashHealCure(self) end, },
            { type = "Spell", name = "CureCorrupt", },
        },
    },
    ['Themes']            = {
        ['Tank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.40, g = 0.05, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.40, g = 0.05, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.15, g = 0.02, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.40, g = 0.05, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.40, g = 0.05, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.15, g = 0.02, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.40, g = 0.05, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.40, g = 0.05, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.40, g = 0.05, b = 0.50, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.25, g = 0.03, b = 0.32, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.40, g = 0.05, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.40, g = 0.05, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.40, g = 0.05, b = 0.50, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.15, g = 0.02, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.75, g = 0.20, b = 1.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.75, g = 0.20, b = 1.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.40, g = 0.05, b = 0.50, a = 1.0, }, },
        },
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.30, g = 0.05, b = 0.40, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.30, g = 0.05, b = 0.40, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.12, g = 0.02, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.30, g = 0.05, b = 0.40, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.30, g = 0.05, b = 0.40, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.12, g = 0.02, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.30, g = 0.05, b = 0.40, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.30, g = 0.05, b = 0.40, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.30, g = 0.05, b = 0.40, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.20, g = 0.03, b = 0.26, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.30, g = 0.05, b = 0.40, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.30, g = 0.05, b = 0.40, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.30, g = 0.05, b = 0.40, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.12, g = 0.02, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.75, g = 0.20, b = 1.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.75, g = 0.20, b = 1.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.30, g = 0.05, b = 0.40, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Nightbane, Sword of the Valiant",
            "Redemption",
        },
    },
    ['AbilitySets']       = {
        ['CrushTimer6'] = {
            "Crush of Tarew Rk. III",
            "Crush of Tarew Rk. II",
            "Crush of Tarew",
            "Crush of Tides",
            "Crush of Repentance",
            "Crush of Compunction",
        },
        ['CrushTimer5'] = {
            "Crush of the Iceclad Rk. III",
            "Crush of the Iceclad Rk. II",
            "Crush of the Iceclad",
            "Crush of Oseka",
            "Crush of Marr",
            "Crush of the Crying Seas",
        },
        ['TwinHealNuke'] = {
            "Glorious Expurgation Rk. III",
            "Glorious Expurgation Rk. II",
            "Glorious Expurgation",
            "Glorious Exculpation",
            "Glorious Exoneration",
            "Glorious Vindication",
        },
        ['TempHP'] = {
            "Steadfast Stance Rk. III",
            "Steadfast Stance Rk. II",
            "Steadfast Stance",
            "Stoic Stance",
            "Stubborn Stance",
            "Steely Stance",
        },
        ['Preservation'] = {
            "Preservation of the Iceclad Rk. III",
            "Preservation of the Iceclad Rk. II",
            "Preservation of the Iceclad",
            "Preservation of Oseka",
            "Preservation of Marr",
            "Preservation of Tunare",
            "Sustenance of Tunare",
            "Ward of Tunare",
        },
        ['HealNuke'] = {
            "Ostracize Rk. III",
            "Ostracize Rk. II",
            "Ostracize",
            "Reprimand",
            "Denouncement",
        },
        ['BlessingProc'] = {
        },
        ['DebuffNuke'] = {
            "Laudation Rk. III",
            "Laudation Rk. II",
            "Laudation",
            "Paean",
            "Elegy",
            "Eulogy",
            "Benediction",
            "Burial Rites",
            "Last Rites",
        },
        ['SteelProc'] = {             --Proc Heal ToT
            "Reinvigorating Steel Rk. III",
            "Reinvigorating Steel Rk. II",
            "Reinvigorating Steel",
            "Rejuvenating Steel",
        },
        ['FuryProc'] = {
            "Reverent Fury Rk. III",
            "Reverent Fury Rk. II",
            "Reverent Fury",
            "Zealous Fury",
            "Earnest Fury",
            "Devout Fury",
            "Righteous Fury",
            "Pious Fury",
            "Holy Order",
            "Pious Might",
            "Divine Might",
        },
        ['UndeadProc'] = {
            "Silvered Fury",
            "Ward of Nife",
            "Instrument of Nife",
        },
        ['Aurora'] = {
            "Aurora of Sunrise Rk. III",
            "Aurora of Sunrise Rk. II",
            "Aurora of Sunrise",
            "Aurora of Splendor",
            "Aurora of Daybreak",
            "Aurora of Dawnlight",
        },
        ['StunTimer5'] = {
            "Force of the Iceclad Rk. III",
            "Force of the Iceclad Rk. II",
            "Force of the Iceclad",
            "Force of Oseka",
            "Force of Marr",
            "Force of the Crying Seas",
            "Force of Timorous",
            "Force of Prexus",
            "Ancient: Force of Jeron",
            "Ancient: Force of Chaos",
            "Force of Akera",
            "Stun",
            "Desist",
        },
        ['StunTimer4'] = {
            "Reverent Force Rk. III",
            "Reverent Force Rk. II",
            "Reverent Force",
            "Zealous Force",
            "Earnest Force",
            "Devout Force",
            "Solemn Force",
            "Sacred Force",
            "Force of Piety",
            "Force of Akilae",
            "Cease",
        },
        ['HealStun'] = {
            "Force of Reverence Rk. III",
            "Force of Reverence Rk. II",
            "Force of Reverence",
        },
        ['HealWard'] = {               -- Heal ToT, Ward on Self
            "Protective Allegiance Rk. III",
            "Protective Allegiance Rk. II",
            "Protective Allegiance",
            "Protective Dedication",
            "Protective Devotion",
            "Protective Devotion",
            "Protective Confession",
        },
        ['Aego'] = {
            "Hand of the Pledged Keeper Rk. III",
            "Hand of the Pledged Keeper Rk. II",
            "Hand of the Pledged Keeper",
            "Pledged Keeper",
            "Hand of the Avowed Keeper",
            "Avowed Keeper",
            "Oathbound Keeper",
            "Sworn Keeper",
            "Oathbound Protector",
            "Sworn Protector",
            "Affirmation",
            "Guidance",
            "Blessing of Austerity",
            "Austerity",
        },
        ['Brells'] = {
        },
        ['SplashHeal'] = {
            "Splash of Cleansing Rk. III",
            "Splash of Cleansing Rk. II",
            "Splash of Cleansing",
            "Splash of Purification",
            "Splash of Sanctification",
        },
        ['HealTaunt'] = {
            "Valiant Healing III",
            "Valiant Healing II",
            "Valiant Healing",
            "Valiant Deflection Rk. III",
            "Valiant Deflection Rk. II",
            "Valiant Deflection",
        },
        ['Affirmation'] = {              --- Improved Super Taunt - Gets you Aggro for X seconds and reduces other Haters generation.
            "Unbroken Affirmation Rk. III",
            "Unbroken Affirmation Rk. II",
            "Unbroken Affirmation",
            "Undivided Affirmation",
        },
        ['WaveHeal'] = {                 -- Group Heal
            "Wave of Sorrow Rk. III",
            "Wave of Sorrow Rk. II",
            "Wave of Sorrow",
            "Wave of Contrition",
            "Wave of Penitence",
            "Wave of Remitment",
            "Wave of Absolution",
            "Wave of Forgiveness",
            "Wave of Piety",
            "Wave of Marr",
            "Wave of Trushar",
            "Healing Wave of Prexus",
            "Wave of Healing",
            "Wave of Life",
        },
        ['SelfHeal'] = {
            "Sorrow Rk. III",
            "Sorrow Rk. II",
            "Sorrow",
            "Contrition",
            "Penitence",
        },
        ['ReverseDS'] = {
            "Mark of the Exemplar Rk. III",
            "Mark of the Exemplar Rk. II",
            "Mark of the Exemplar",
            "Mark of the Reverent",
            "Mark of the Defender",
            "Mark of the Pure",
            "Mark of the Pious",
            "Mark of the Crusader",
            "Mark of the Saint",
        },
        -- ['Cleansing'] = {           -- ST HoT
        --     "Avowed Cleansing",     -- Level 123
        --     "Forthright Cleansing", -- Level 118
        --     "Sincere Cleansing",    -- Level 113
        --     "Merciful Cleansing",   -- Level 108
        --     "Ardent Cleansing",     -- Level 103
        --     "Reverent Cleansing",   -- Level 98
        --     "Zealous Cleansing",    -- Level 93
        --     "Earnest Cleansing",    -- Level 88
        --     "Devout Cleansing",     -- Level 83
        --     "Solemn Cleansing",     -- Level 78
        --     "Sacred Cleansing",     -- Level 73
        --     "Pious Cleansing",      -- Level 69
        --     "Supernal Cleansing",   -- Level 64
        --     "Celestial Cleansing",  -- Level 59
        --     "Ethereal Cleansing",   -- Level 44
        -- },
        ['BurstHeal'] = {            -- Smart Heal, Target or ToT
            "Burst of Sunrise Rk. III",
            "Burst of Sunrise Rk. II",
            "Burst of Sunrise",
            "Burst of Splendor",
            "Burst of Daybreak",
            "Burst of Dawnlight",
            "Burst of Morrow",
            "Burst of Sunlight",
        },
        ['ArmorSelfBuff'] = {
            "Armor of Formidable Grace Rk. III",
            "Armor of Formidable Grace Rk. II",
            "Armor of Formidable Grace",
            "Armor of Formidable Faith",
            "Armor of Implacable Faith",
            "Armor of Unwavering Faith",
            "Armor of Inexorable Faith",
            "Armor of Unrelenting Faith",
            "Armor of the Champion",
            "Aura of the Crusader",
        },
        ['RighteousStrike'] = {
            "Righteous Umbrage Rk. III",
            "Righteous Umbrage Rk. II",
            "Righteous Umbrage",
            "Righteous Vexation",
            "Righteous Indignation",
            "Righteous Fury",
        },
        ['Symbol'] = {
            "Symbol of Burim Rk. III",
            "Symbol of Burim Rk. II",
            "Symbol of Burim",
            "Symbol of Erillion",
            "Symbol of Jyleel",
            "Symbol of Jeneca",
            "Symbol of Bthur",
            "Symbol of Jeron",
            "Symbol of Marzin",
            "Symbol of Naltron",
            "Symbol of Pinzarn",
            "Symbol of Ryltan",
            "Symbol of Transal",
        },
        ['StunTimer6'] = {                    -- Timer 6, less damage than timer 6 crush, but inlcudes stun. Has Push.
            "Lesson of Sorrow Rk. III",
            "Lesson of Sorrow Rk. II",
            "Lesson of Sorrow",
            "Lesson of Remorse",
            "Lesson of Repentance",
            "Lesson of Compunction",
            "Lesson of Contrition",
            "Lesson of Penitence",
            "Serene Command",
        },
        ['Audacity'] = {                      -- Magic Resist debuff, Hate over time
            "Devout Audacity Rk. III",
            "Devout Audacity Rk. II",
            "Devout Audacity",
            "Righteous Audacity",
        },
        ['LightHeal'] = {                     --ToT Heal
            "Dazzling Light Rk. III",
            "Dazzling Light Rk. II",
            "Dazzling Light",
            "Brilliant Light",
            "Joyous Light",
            "Shining Light",
            "Radiant Light",
            "Gleaming Light",
            "Light of Piety",
            "Light of Order",
            "Light of Nife",
            "Light of Life",
        },
        -- ['Pacify'] = {
        --     "Assuring Words",  -- Level 121
        --     "Tranquil Words",  -- Level 116
        --     "Placating Words", -- Level 111
        --     "Dulcify",         -- Level 101
        --     "Reconcile",       -- Level 96
        --     "Mollify",         -- Level 91
        --     "Propitiate",      -- Level 86
        --     "Pacify",          -- Level 49
        --     "Calm",            -- Level 43
        --     "Soothe",          -- Level 25
        --     "Lull",            -- Level 10
        -- },
        ['TouchHeal'] = {
            "Reverent Touch Rk. III",
            "Reverent Touch Rk. II",
            "Reverent Touch",
            "Zealous Touch",
            "Earnest Touch",
            "Devout Touch",
            "Solemn Touch",
            "Sacred Touch",
            "Touch of Piety",
            "Touch of Nife",
            "Superior Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
            "Salve",
        },
        ['Dicho'] = {
        },
        ['PurityCure'] = {              --- Purity Cure Poison/Diease Cure Half Power to curse
            "Reverent Purity Rk. III",
            "Reverent Purity Rk. II",
            "Reverent Purity",
            "Zealous Purity",
            "Earnest Purity",
            "Devoted Purity",
        },
        -- ['CureCurse'] = {
        --     "Remove Greater Curse", -- Level 60
        --     "Eradicate Curse",      -- Level 60
        --     "Remove Curse",         -- Level 45
        --     "Remove Lesser Curse",  -- Level 34
        --     "Remove Minor Curse",   -- Level 19
        -- },
        ['CureCorrupt'] = {
            "Expurgate Rk. III",
            "Expurgate Rk. II",
            "Expurgate",
            "Purify",
            "Cleanse",
            "Cure Corruption",
        },
        ['ForHonor'] = {                --- Challenge Taunt Over time Debuff
            "Demand for Honor Rk. III",
            "Demand for Honor Rk. II",
            "Demand for Honor",
            "Provocation for Honor",
            "Confrontation for Honor",
            "Charge for Honor",
            "Trial For Honor",
            "Challenge for Honor",
        },
        ['Piety'] = {                   -- Spell Resist Buff
            "Silent Song of Quellious",
            "Silentfist Discipline",
            "Silent Dictation",
            "Silent Decree",
            "Silent Decree Rk. II",
            "Silent Decree Rk. III",
            "Silent Dictum",
            "Silent Dictum Rk. II",
            "Silent Dictum Rk. III",
            "Silent Mind",
            "Silent Mind Rk. II",
            "Silent Mind Rk. III",
            "Silent Edict",
            "Silent Edict Rk. II",
            "Silent Edict Rk. III",
            "Silent Proclamation",
            "Silent Proclamation Rk. II",
            "Silent Proclamation Rk. III",
            "Silent Mandate",
            "Silent Mandate Rk. II",
            "Silent Mandate Rk. III",
            "Silent Order",
            "Silent Order Rk. II",
            "Silent Order Rk. III",
            "Silent Piety",
        },
        ['Remorse'] = {                 -- Killshot buff
            "Remorse for the Fallen Rk. III",
            "Remorse for the Fallen Rk. II",
            "Remorse for the Fallen",
        },
        ['HealAura'] = {
            "Blessed Armor of the Risen",
            "Blessed Aquifer",
            "Blessed Aquifer Rk. II",
            "Blessed Aquifer Rk. III",
            "Blessed Aura",
            "Holy Aura",
        },
        ['UndeadNuke'] = {
            "Doctrine of Abrogation Rk. III",
            "Doctrine of Abrogation Rk. II",
            "Doctrine of Abrogation",
            "Abrogate the Undead",
            "Abolish the Undead",
            "Annihilate the Undead",
            "Spurn Undead",
            "Deny Undead",
            "Expel Undead",
            "Dismiss Undead",
            "Expulse Undead",
            "Ward Undead",
        },
        ['AllianceNuke'] = {
        },
        ['EndRegen'] = {
            "Rest Rk. III",
            "Rest Rk. II",
            "Rest",
            "Reprieve",
            "Respite",
        },
        ['CombatEndRegen'] = {
        },
        ['MeleeMit'] = {
            "Reprove Rk. III",
            "Reprove Rk. II",
            "Reprove",
            "Renounce",
            "Defy",
        },
        ['ArmorDisc'] = {
            "Armor of Reverence Rk. III",
            "Armor of Reverence Rk. II",
            "Armor of Reverence",
            "Armor of Zeal",
            "Armor of Courage",
        },
        ['Undeadburn'] = {
            "Holyforge Discipline",
        },
        ['Penitent'] = {
            "Penitent Reward III",
            "Penitent Reward II",
            "Penitent Reward",
            "Penitent Mending III",
            "Penitent Mending II",
            "Penitent Mending",
            "Reverent Penitence Rk. III",
            "Reverent Penitence Rk. II",
            "Reverent Penitence",
        },
        ['Mantle'] = {
            "Brightwing Mantle Rk. III",
            "Brightwing Mantle Rk. II",
            "Brightwing Mantle",
            "Prominent Mantle",
            "Exalted Mantle",
            "Honorific Mantle",
            "Armor of Decorum",
            "Armor of Righteousness",
            "Guard of Righteousness",
            "Guard of Humility",
            "Guard of Piety",
        },
        ['Guardian'] = {
            "Holy Guardian Discipline Rk. III",
            "Holy Guardian Discipline Rk. II",
            "Holy Guardian Discipline",
        },
        ['Spellblock'] = {
            "Sanctification Discipline",
        },
        ['Deflection'] = {
        },
        ['ReflexStrike'] = {
            "Reflexive Righteousness Rk. III",
            "Reflexive Righteousness Rk. II",
            "Reflexive Righteousness",
        },
        ['RezSpell'] = {
            "Resurrection",
            "Restoration",
            "Renewal",
            "Revive",
            "Reparation",
            "Reconstitution",
            "Reconstitute",
            "Reanimation",
            "Reanimate",
        },
    },
    ['AASets']            = {
        ['Disruption'] = {
            "Force of Disruption",
            "Divine Stun",
        },
    },
    ['Helpers']           = {
        UseSplashHealCure = function(self)
            return Config:GetSetting('SplashHealAsCure') and Core.GetResolvedActionMapItem('SplashHeal')
        end,
        --determine whether we should overwrite DPU buffs with better single buffs
        SingleBuffCheck = function(self)
            if Casting.CanUseAA("Divine Protector's Unity") and not Config:GetSetting('OverwriteDPUBuffs') then return false end
            return true
        end,
        --function to determine if we have enough mobs in range to use a defensive disc
        DefensiveDiscCheck = function(printDebug)
            local xtCount = mq.TLO.Me.XTarget() or 0
            if xtCount < Config:GetSetting('DiscCount') then return false end
            local haters = Set.new({})
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or (xtarg.TargetType() or ""):lower() == "auto hater")) and (xtarg.Distance() or 999) <= 30 then
                    if printDebug then
                        Logger.log_verbose("DefensiveDiscCheck(): XT(%d) Counting %s(%d) as a hater in range.", i, xtarg.CleanName() or "None", xtarg.ID())
                    end
                    haters:add(xtarg.ID())
                end
                if #haters:toList() >= Config:GetSetting('DiscCount') then return true end -- no need to keep counting once this threshold has been reached
            end
            return false
        end,
        shieldNeeded = function()
            -- check for exactly 100% to help ensure the mob is targeting us, over 100% can indicate another is still targeted
            return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or mq.TLO.Me.ActiveDisc.Name() == "Deflection Discipline" or
                (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) >= 234000 or
                (Config:GetSetting('NamedShieldLock') and ((Globals.AutoTargetIsNamed and Targeting.GetAutoTargetAggroPct() == 100) or Targeting.TankingXTNamed()))
        end,
    },
    ['HealRotationOrder'] = {
        {
            name = 'GroupHeal',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'BigHeal',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return Targeting.BigHealsNeeded(target) and not Targeting.TargetIsType("pet", target)
            end,
        },
        {
            name = 'MainHeal',
            state = 1,
            steps = 1,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
    },
    ['HealRotations']     = {
        ['GroupHeal'] = {
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "Gift of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return self.CombatState == "Combat" and Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "SplashHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('KeepSplashMemmed') end,
            },
            {
                name = "WaveHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWaveHeal') end,
            },
        },
        ['BigHeal'] = {
            {
                name = "Lay on Hands",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.GetTargetPctHPs() < Config:GetSetting('HPCritical')
                end,
            },
            {
                name = "SelfHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSelfHeal') end,
                cond = function(self, spell, target)
                    return self.CombatState == "Combat" and Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Marr's Gift",
                type = "AA",
                cond = function(self, aaName, target)
                    return self.CombatState == "Combat" and Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Hand of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return self.CombatState == "Combat" and (Targeting.TargetIsMyself(target) or Targeting.GetTargetPctHPs(target) < Config:GetSetting('HPCritical'))
                end,
            },
            {
                name = "Gift of Life",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return self.CombatState == "Combat" and (Targeting.TargetIsMyself(target) or Targeting.GetTargetPctHPs(target) < Config:GetSetting('HPCritical'))
                end,
            },
            {
                name = "TouchHeal",
                type = "Spell",
                load_cond = function() return Config:GetSetting("DoTouchHeal") == 1 end,
            },
        },
        ['MainHeal'] = {
            {
                name = "BurstHeal",
                type = "Spell",
            },
            {
                name = "TouchHeal",
                type = "Spell",
                load_cond = function() return Config:GetSetting("DoTouchHeal") == 2 end,
            },
        },
    },
    ['Charm']             = {
        ['Assist'] = {
            { name = "HealTaunt",   type = "Spell", },
            { name = "Audacity",    type = "Spell",   cond = function(self, spell, target) return Casting.DetSpellCheck(spell, target) end, },
            { name = "Disruption",  type = "AA", },
            { name = "Taunt",       type = "Ability", },
            { name = "CrushTimer5", type = "Spell",   load_cond = function(self) return Config:GetSetting('Timer5Choice') == 1 end, },
            { name = "CrushTimer6", type = "Spell",   load_cond = function(self) return Config:GetSetting('Timer6Choice') == 1 end, },
            {
                name = "StunTimer5",
                type = "Spell",
                load_cond = function(self)
                    return Config:GetSetting('Timer5Choice') == 2 or ((Config:GetSetting('Timer5Choice') == 1)) and not Core.GetResolvedActionMapItem('CrushTimer5')
                end,
            },
            { name = "StunTimer4", type = "Spell", load_cond = function(self) return Config:GetSetting('Timer4Choice') end, },
            { name = "StunTimer6", type = "Spell", load_cond = function(self) return Config:GetSetting('Timer6Choice') == 2 end, },
        },
    },
    ['RotationOrder']     = {
        { --Self Buffs
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Core.CombatActionsCheck() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'GroupBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Casting.GetBuffableIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Core.CombatActionsCheck()
            end,
        },
        { --Actions to lock down xtarg haters
            name = 'HateTools(AggroTarget)',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() and Config:GetSetting('TankAggroScan') end,
            targetId = function(self) return Targeting.CheckForAggroTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat"
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'HateTools(AutoTarget)',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and Targeting.HateToolsNeeded()
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'AEHateTools',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() and Config:GetSetting('AETauntAA') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and Combat.AETauntCheck(true)
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('UseBandolier') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'EmergencyDefenses',
            state = 1,
            steps = 2, -- help ensure that we cancel visage when needed
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Prioritized in their own rotation to help keep HP topped to the desired level, includes emergency abilities
            name = 'ToTHeals',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.LightHealsNeeded(mq.TLO.Me.TargetOfTarget)
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'Defenses',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.IHaveAggro(100) and
                    -- we are under our defense start HP
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('DefenseStart') or
                        -- we have met our defense count threshold
                        self.Helpers.DefensiveDiscCheck(true) or
                        -- we are fighting a named and we are tanking it
                        Targeting.TankingXTNamed())
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        { --Non-spell actions that can be used during/between casts
            name = 'CombatWeave',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
    },
    ['Rotations']         = {
        ['Downtime'] = {
            {
                name = "EndRegen",
                type = "Disc",
                load_cond = function(self) return not Core.GetResolvedActionMapItem("CombatEndRegen") end,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "HealAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell)
                    return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName()))
                end,
            },
            {
                name = "Divine Protector's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID() or 0) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "ArmorSelfBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FuryProc",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "UndeadProc",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) --use this always until we have a Fury proc, and optionally after that, up until the point that Fury is rolled into DPU
                    if (mq.TLO.Me.AltAbility("Divine Protector's Unity").Rank() or 0) > 1 or (Core.GetResolvedActionMapItem("FuryProc") and not Config:GetSetting('DoUndeadProc')) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Remorse",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Piety",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "Preservation",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) then return false end
                    return Casting.SelfBuffCheck(spell) and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTempHP') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 45
                end,
            },
            {
                name = "BlessingProc",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
            {
                name = "HealWard",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
            { --Charm Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Charm").Name() or "CharmClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCharmClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "SteelProc",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSteelProc') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 45
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Brells",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoBrells') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Aego",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('AegoSymbol') == 1 end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Symbol",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('AegoSymbol') == 2 end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Marr's Salvation",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoSalvation') end,
                cond = function(self, aaName, target)
                    if Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
                post_activate = function(self, aaName, success)
                    -- mq.delay(200, function() return mq.TLO.Me.Buff("Marr's Salvation")() ~= nil end)
                    if success and Core.IsTanking() and mq.TLO.Me.Buff("Marr's Salvation")() then
                        Core.DoCmd("/removebuff \"Marr's Salvation\"")
                    end
                end,
            },
        },
        ['EmergencyDefenses'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < Config:GetSetting('HPCritical')
                end,
            },
            --Note that on named we may already have a mantle/carapace running already, could make this remove other discs, but meh, Shield Flash still a thing.
            {
                name = "Deflection",
                type = "Disc",
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') and Casting.NoDiscActive() and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                pre_activate = function(self)
                    if Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                end,
            },
            --Penitent vs Armor is something I will need to do more homework on
            {
                name = "Penitent",
                type = "Disc",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Group Armor of The Inquisitor",
                type = "AA",
                cond = function(self, aaName)
                    return not Casting.IHaveBuff("Armor of the Inquisitor")
                end,
            },
            {
                name = "Armor of the Inquisitor",
                type = "AA",
                cond = function(self, aaName)
                    return not Casting.IHaveBuff("Armor of the Inquisitor")
                end,
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                load_cond = function(self) return Config:GetSetting('DoChestClick') end,
                cond = function(self, itemName, target)
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['HateTools(AggroTarget)'] = {
            {
                name = "HealTaunt",
                type = "Spell",
            },
            {
                name = "Audacity",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell, target)
                end,
            },
            {
                name = "ForHonor",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Disruption",
                type = "AA",
            },
            {
                name = "Taunt",
                type = "Ability",
            },
            {
                name = "CrushTimer5",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer5Choice') == 1 end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer6Choice') == 1 end,
            },
            {
                name = "StunTimer5",
                type = "Spell",
                load_cond = function(self)
                    return Config:GetSetting('Timer5Choice') == 2 or ((Config:GetSetting('Timer5Choice') == 1)) and not Core.GetResolvedActionMapItem('CrushTimer5')
                end,
            },
            {
                name = "StunTimer4",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer4Choice') end,
            },
            {
                name = "StunTimer6",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer6Choice') == 2 end,
            },
        },
        ['HateTools(AutoTarget)'] = {
            {
                name = "Disruption",
                type = "AA",
            },
            {
                name = "HealTaunt",
                type = "Spell",
                cond = function(self, abilityName, target)
                    return Targeting.LostAutoTargetAggro()
                end,
            },
            --used when we've lost hatred after it is initially established
            {
                name = "Ageless Enmity",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and Targeting.GetAutoTargetPctHPs() < 90 and Targeting.LostAutoTargetAggro()
                end,
            },
            --used to jumpstart hatred on named from the outset and prevent early rips from burns
            {
                name = "Affirmation",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Globals.AutoTargetIsNamed
                end,
            },
            {
                name = "Projection of Piety",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Targeting.LostAutoTargetAggro()
                end,
            },
            {
                name = "Audacity",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell, target)
                end,
            },
            {
                name = "ForHonor",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "CrushTimer5",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer5Choice') == 1 end,
                cond = function(self, spell, target)
                    return (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer6Choice') == 1 end,
                cond = function(self, spell, target)
                    return (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
        },
        ['AEHateTools'] = {
            {
                name = "Heroic Leap",
                type = "AA",
                cond = function(self, aaName, target)
                    return not mq.TLO.Me.HeadWet()
                end,
            },
            {
                name = "Beacon of the Righteous",
                type = "AA",
            },
            {
                name = "Hallowed Lodestar",
                type = "AA",
            },
        },
        ['Debuff'] = {
            {
                name = "Audacity",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell, target)
                end,
            },
            {
                name = "ReverseDS",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoReverseDS') < 3 end,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoReverseDS') == 2 and not Globals.AutoTargetIsNamed then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Valorous Rage",
                type = "AA",
            },
            {
                name = "RighteousStrike",
                type = "Disc",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
            {
                name = "Spire of Chivalry",
                type = "AA",
            },
            {
                name = "Thunder of Karana",
                type = "AA",
            },
            {
                name = "Hand of Tunare",
                type = "AA",
            },
            {
                name = "Holyforge",
                type = "Disc",
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive() and Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "Pureforge",
                type = "Disc",
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Inquisitor's Judgment",
                type = "AA",
            },
            {
                name = "Preservation",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "BlessingProc",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SteelProc",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSteelProc') end,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Marr's Gift",
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctMana() < 10
                end,
            },
        },
        ['Defenses'] = {
            {
                name = "MeleeMit",
                type = "Disc",
                cond = function(self, discSpell)
                    return not ((discSpell.Level() or 0) < 108 and not Casting.NoDiscActive())
                end,
            },
            {
                name = "ArmorDisc",
                type = "Disc",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Guardian",
                type = "Disc",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive()
                end,
            },
        },
        ['ToTHeals'] = {
            {
                name = "Dicho",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDicho') end,
                cond = function(self, spell, target)
                    return Targeting.GroupHealsNeeded() or Targeting.BigHealsNeeded(mq.TLO.Me)
                end,
            },
            {
                name = "BurstHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MainHealsNeeded(mq.TLO.Me.TargetOfTarget)
                end,
            },
            {
                name = "HealTaunt",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
            },
            {
                name = "HealNuke",
                type = "Spell",
            },
            {
                name = "LightHeal",
                type = "Spell",
                load_cond = function() return Config:GetSetting("DoLightHeal") end,
            },
        },
        ['CombatWeave'] = {
            { --Used if the group could benefit from the heal
                name = "ReflexStrike",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.GroupHealsNeeded()
                end,
            },
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Vanquish the Fallen",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Core.ShieldEquipped() or Casting.CanUseAA("Improved Bash")
                end,
            },
            {
                name = "Slam",
                type = "Ability",
            },
        },
        ['Combat'] = {
            {
                name = "ForHonor",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "HealStun",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MainHealsNeeded(mq.TLO.Me) or
                        (Core.IsTanking() and spell.RankName.Stacks() and (mq.TLO.Me.Song(spell.Trigger(1).Name).Duration.TotalSeconds() or 0) < 12)
                end,
            },
            {
                name = "HealWard",
                type = "Spell",
                load_cond = function(self) return Core.IsTanking() end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "TwinHealNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTwinHealNuke') end,
            },
            {
                name = "Disruptive Persecution",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "CrushTimer5",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer5Choice') == 1 end,
            },
            {
                name = "CrushTimer6",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer6Choice') == 1 end,
            },
            {
                name = "StunTimer5",
                type = "Spell",
                load_cond = function(self)
                    return Config:GetSetting('Timer5Choice') == 2 or ((Config:GetSetting('Timer5Choice') == 1)) and not Core.GetResolvedActionMapItem('CrushTimer5')
                end,
            },
            {
                name = "StunTimer4",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer4Choice') end,
            },
            {
                name = "StunTimer6",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('Timer6Choice') == 2 end,
            },
            {
                name = "Disruption",
                type = "AA",
                load_cond = function(self) return Core.IsTanking() end,
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                cond = function(self)
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return self.Helpers.shieldNeeded()
                end,
                custom_func = function(self)
                    ItemManager.BandolierSwap("Shield")
                    return true
                end,
            },
            {
                name = "Equip 2Hand",
                type = "CustomFunc",
                cond = function(self)
                    if mq.TLO.Me.Bandolier("2Hand").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('Equip2Hand') and not self.Helpers.shieldNeeded()
                end,
                custom_func = function(self)
                    ItemManager.BandolierSwap("2Hand")
                    return true
                end,
            },
        },
    },
    ['SpellList']         = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { name = "TouchHeal",   cond = function(self) return Config:GetSetting('DoTouchHeal') < 3 end, },
                { name = "LightHeal",   cond = function(self) return Config:GetSetting('DoLightHeal') end, },
                { name = "BurstHeal", },
                { name = "SelfHeal",    cond = function(self) return Config:GetSetting('DoSelfHeal') end, },
                { name = "SplashHeal",  cond = function(self) return Config:GetSetting('KeepSplashMemmed') end, },
                { name = "WaveHeal",    cond = function(self) return Config:GetSetting('DoWaveHeal') end, },
                { name = "HealTaunt",   cond = function(self) return Core.IsTanking() end, },
                { name = "Audacity",    cond = function(self) return Core.IsTanking() end, },
                { name = "ForHonor",    cond = function(self) return Core.IsTanking() end, },
                { name = "StunTimer4",  cond = function(self) return Core.IsTanking() and Config:GetSetting('Timer4Choice') end, },
                { name = "CrushTimer5", cond = function(self) return Core.IsTanking() and Config:GetSetting('Timer5Choice') == 1 end, },
                {
                    name = "StunTimer5",
                    cond = function(self)
                        return Core.IsTanking() and
                            (Config:GetSetting('Timer5Choice') == 2 or ((Config:GetSetting('Timer5Choice') == 1)) and not Core.GetResolvedActionMapItem('CrushTimer5'))
                    end,
                },
                { name = "CrushTimer6",  cond = function(self) return Core.IsTanking() and Config:GetSetting('Timer6Choice') == 1 end, },
                { name = "StunTimer6",   cond = function(self) return Core.IsTanking() and Config:GetSetting('Timer6Choice') == 2 end, },
                { name = "Preservation", cond = function(self) return Core.IsTanking() end, },
                { name = "TempHP",       cond = function(self) return Config:GetSetting('DoTempHP') end, },
                { name = "SteelProc",    cond = function(self) return Config:GetSetting('DoSteelProc') end, },
                { name = "HealStun", },
                { name = "HealNuke", },
                { name = "Dicho",        cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "TwinHealNuke", cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },
                { name = "ReverseDS",    cond = function(self) return Config:GetSetting('DoReverseDS') < 3 end, },
                { name = "HealWard",     cond = function(self) return Core.IsTanking() end, },
                { name = "PurityCure",   cond = function(self) return Config:GetSetting('KeepPurityMemmed') end, },
                { name = "CureCorrupt",  cond = function(self) return Config:GetSetting('KeepCorruptMemmed') end, },
                { name = "BlessingProc", },
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'StunTimer4',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('StunTimer4')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('StunTimer4')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Audacity',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Audacity').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Audacity').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Audacity')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'ForHonor',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('ForHonor').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('ForHonor').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('ForHonor')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        --Mode
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Mode",
            Tooltip = "Select the active Combat Mode for this PC.",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes do?",
            Answer = "Tank Mode will focus on tanking and aggro, while DPS mode will focus on DPS. Both have a secondary focus of healing.",
        },

        --Buffs and Debuffs
        ['DoTempHP']          = {
            DisplayName = "Temp HP Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 3,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("TempHP") end,
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why do we have the Temp HP Buff always memorized?",
            Answer = "Temp HP buffs have a very long refresh time after scribing, making them infeasible to use if not gemmed.",
        },
        ['OverwriteDPUBuffs'] = {
            DisplayName = "Overwrite DPU Buffs",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 5,
            Tooltip = "Overwrite DPU with single buffs when they are better than the DPU effect.",
            Default = false,
            ConfigType = "Advanced",
        },
        ['DoVetAA']           = {
            DisplayName = "Use Vet AA",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 8,
            Tooltip = "Use Veteran AA such as Intensity of the Resolute or Armor of Experience as necessary.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        ['DoUndeadProc']      = {
            DisplayName = "Use Undead Proc",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Use Undead proc over Fury proc until Fury is rolled into Divine Protector's Unity (Level 80).",
            Default = false,
        },
        ['DoSteelProc']       = {
            DisplayName = "Use Steel Proc",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 3,
            Tooltip = "Use your Steel Proc line.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['DoBrells']          = {
            DisplayName = "Do Brells",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Enable Casting Brells",
            Default = true,
        },
        ['AegoSymbol']        = {
            DisplayName = "Aego/Symbol Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Choose whether to use the Aegolism or Symbol Line of HP Buffs.",
            Type = "Combo",
            ComboOptions = { 'Aegolism Line (Keeper)', 'Symbol Line', 'None', },
            Default = 1,
            Min = 1,
            Max = 3,
        },
        ['DoSalvation']       = {
            DisplayName = "Marr's Salvation",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use your group hatred reduction buff AA (The Paladin will cancel it on themself if in Tank Mode).",
            Default = true,
            RequiresLoadoutChange = true,
        },

        --Hate Tools
        ['Timer4Choice']      = {
            DisplayName = "Use Timer 4 Stun",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 101,
            Tooltip = "Use your Timer 4 'Force' line of stuns.",
            Default = mq.TLO.Me.Level() < 92 and true or false,
            RequiresLoadoutChange = true,
        },
        ['Timer5Choice']      = {
            DisplayName = "Timer 5 Choice:",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 101,
            Tooltip =
            "Choose which Timer 5 spell line to use (For the best experience for leveling, the standard stun will be used until others are available.\nIt is recommended to switch this line out for the Timer 3 'Healstun' once it is available.).",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Crush', 'Standard Stun', 'Disabled', },
            Default = mq.TLO.Me.Level() < 99 and 1 or 3,
            Min = 1,
            Max = 4,
            ConfigType = "Advanced",
        },
        ['Timer6Choice']      = {
            DisplayName = "Timer 6 Choice:",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 102,
            Tooltip = "Choose which Timer 6 spell line to use.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Crush', '"Lesson" Stun', 'Disabled', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoDicho']           = {
            DisplayName = "Cast Dicho",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 104,
            Tooltip = "Use your Dichotomic Hate/Stun/GroupHeal spell.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['AETauntAA']         = {
            DisplayName = "Use AE Taunt AA",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 101,
            Tooltip = "Use AE Taunt AA.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },

        --Defenses
        ['DiscCount']         = {
            DisplayName = "Def. Disc. Count",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 101,
            Tooltip = "Number of mobs around you before you use preemptively use Defensive Discs.",
            Default = 4,
            Min = 1,
            Max = 10,
            ConfigType = "Advanced",
        },
        ['DefenseStart']      = {
            DisplayName = "Defense HP",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 102,
            Tooltip = "The HP % where we will use defensive actions like discs, epics, etc.\nNote that fighting a named will also trigger these actions.",
            Default = 60,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['EmergencyStart']    = {
            DisplayName = "Emergency Start",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 103,
            Tooltip = "The HP % before all but essential rotations are cut in favor of emergency or defensive abilities.",
            Default = 40,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['HPCritical']        = {
            DisplayName = "HP Critical",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 104,
            Tooltip =
            "The HP % that we will use abilities like Lay on Hands or Gift of Life.\nMost other rotations are cut to give our full focus to survival.",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },

        --Equipment
        ['DoChestClick']      = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['DoCharmClick']      = {
            DisplayName = "Do Charm Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click your charm for Geomantra.",
            Default = false,
        },
        ['UseBandolier']      = {
            DisplayName = "Dynamic Weapon Swap",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 101,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"2Hand\" TO USE THIS FUNCTION.***",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['EquipShield']       = {
            DisplayName = "Equip Shield",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 102,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['Equip2Hand']        = {
            DisplayName = "Equip 2Hand",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 103,
            Tooltip = "Over this HP%, you will swap to your \"2Hand\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['NamedShieldLock']   = {
            DisplayName = "Shield on Named",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 104,
            Tooltip = "Keep Shield equipped while tanking a named.",
            Default = true,
            FAQ = "Why does my PAL switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
        },
        ['DoTouchHeal']       = {
            DisplayName = "Touch Heal Use:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Choose when the Paladin will use the single-target Touch-line healing spell.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Emergency Use(BigHeal)', 'Standard Use(MainHeal)', 'Never', },
            Default = mq.TLO.Me.Level() > 72 and 3 or 2,
            Min = 1,
            Max = 3,
        },
        ['DoLightHeal']       = {
            DisplayName = "Do Light Heal",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 102,
            Tooltip = "Use your ToT heal ('... Light') line of spells.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoSelfHeal']        = {
            DisplayName = "Do Self Heal",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 102,
            Tooltip = "Use your emergency self-heal line of spells.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoWaveHeal']        = {
            DisplayName = "Do Wave Heal",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 102,
            Tooltip = "Use your group heal ('Wave of ...') line of spells.",
            RequiresLoadoutChange = true,
            Default = mq.TLO.Me.Level() < 83 and true or false,
        },
        ['KeepSplashMemmed']  = {
            DisplayName = "Mem Splash Heal",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 104,
            Tooltip =
            "Memorize your 'Splash' line AE heal/cure, and use it as a group heal or cure. (If unchecked, we may mem/use it out of combat as a cure, depending on other settings.)",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoTwinHealNuke']    = {
            DisplayName = "Twin Heal Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['KeepPurityMemmed']  = {
            DisplayName = "Mem Purity Cure",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 101,
            Tooltip = "Memorize your Purity line (cure poi/dis/curse) when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if enabled.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['KeepCorruptMemmed'] = {
            DisplayName = "Mem Cure Corruption",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 102,
            Tooltip = "Memorize cure corruption spell when possible (depending on other selected options). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if available.",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
        },
        ['SplashHealAsCure']  = {
            DisplayName = "Use Splash Heal to Cure",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 103,
            Tooltip = "If the Splash Heal is available, use it to cure detrimental effects.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        ['DoReverseDS']       = {
            DisplayName = "Reverse DS",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Misc Debuffs",
            Index = 101,
            Tooltip = "Choose when to use your Reverse DS ('Mark of ...') line of debuffs.",
            Type = "Combo",
            ComboOptions = { 'Always', 'Only on Named', 'Never', },
            Default = 3,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
        },
        ['HealPriority']      = {
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
            Answer = "This class config is an Alpha config, lacking playtesting.\n\n" ..
                "  The defaults are aimed towards late game live tanking, but it has the options for other modes or methods.\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}

return _ClassConfig
