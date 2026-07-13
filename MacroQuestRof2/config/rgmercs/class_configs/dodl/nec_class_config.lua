-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

-- [ NOTE ON ORDERING ] --
-- Order matters! Lua will implicitly iterate everything in an array
-- in order by default so always put the first thing you want checked
-- towards the top of the list.

local mq           = require('mq')
local Casting      = require("utils.casting")
local Comms        = require("utils.comms")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require("utils.globals")
local Targeting    = require("utils.targeting")

local _ClassConfig = {
    _version            = "DODL CUSTOM",
    _author             = "eldudero",
    ['Modes']           = {
        'DPS',
    },
    ['ModeChecks']      = {
        -- necro can AA Rez
        IsRezing = function() return Casting.CanUseAA("Convergence") and (Config:GetSetting('DoBattleRez') or Targeting.GetXTHaterCount() == 0) end,
        CanCharm = function() return true end,
    },
    ['Rez']             = {
        ['Combat'] = {
            { type = "AA", name = "Convergence", cond = function(self, spell, target)
                return Casting.ReagentCheck(mq.TLO.Me.AltAbility("Convergence").Spell)
            end, },
        },
        ['Downtime'] = {
            { type = "AA", name = "Convergence", cond = function(self, spell, target)
                return Casting.ReagentCheck(mq.TLO.Me.AltAbility("Convergence").Spell)
            end, },
        },
    },
    ['PetPosition']     = {
        SummonAA   = function() return Casting.CanUseAA("Summon Companion") and "Summon Companion" end,
        RelocateAA = function()
            local cdAA = mq.TLO.Me.AltAbility("Companion's Discipline")
            return (cdAA and cdAA.Rank() or 0) >= 7 and "Companion's Discipline"
        end,
    },
    ['Themes']          = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 1.0, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.4, g = 0.05, b = 0.8, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.2, g = 0.05, b = 0.6, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.2, g = 0.05, b = 0.6, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.1, g = 0.05, b = 0.5, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.1, g = 0.05, b = 0.5, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.5, g = 0.05, b = 1.0, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.5, g = 0.05, b = 1.0, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.2, g = 0.05, b = 0.6, a = 1.0, }, },
        },
    },
    ['CommandHandlers'] = {
        startlich = {
            usage = "/rgl startlich",
            about = "Start your Lich Spell [Note: This will enabled DoLich if it is not already].",
            handler =
                function(self)
                    Config:SetSetting('DoLich', true)
                    Core.SafeCallFunc("Start Necro Lich", self.Helpers.StartLich, self)

                    return true
                end,
        },
        stoplich = {
            usage = "/rgl stoplich",
            about = "Stop your Lich Spell [Note: This will NOT disable DoLich].",
            handler =
                function(self)
                    Core.SafeCallFunc("Stop Necro Lich", self.Helpers.CancelLich, self)

                    return true
                end,
        },
    },
    ['ItemSets']        = {
        ['Epic'] = {
            "Deathwhisper",
            "Soulwhisper",
        },
        ['OoW_Chest'] = {
        },
    },
    ['AbilitySets']     = {
        ['SelfHPBuff'] = {
            "Shield of the Dauntless Rk. III",
            "Shield of the Dauntless Rk. II",
            "Shield of the Dauntless",
            "Shield of Bronze",
            "Shield of Dreams",
            "Shield of the Void",
            "Shield of Maelin",
            "Shield of the Arcane",
            "Shield of the Magi",
            "Arch Shielding",
            "Greater Shielding",
            "Major Shielding",
            "Shielding",
            "Lesser Shielding",
        },
        ['Levitate'] = {
            "Deadeye",
            "Dead Man Floating",
            "Deadeye Discipline",
            "Deadly Precision Discipline",
            "Deadly Aim Discipline",
            "Deadfall",
            "Deadfall Rk. II",
            "Deadfall Rk. III",
            "Deadlock Jaws",
            "Deadlock Jaws Rk. II",
            "Deadlock Jaws Rk. III",
            "Dead Men Floating",
        },
        ['SelfRune1'] = {
            "Zombieskin Rk. III",
            "Zombieskin Rk. II",
            "Zombieskin",
            "Ghoulskin",
            "Grimskin",
            "Corpseskin",
            "Shadowskin",
            "Wraithskin",
            "Dull Pain",
            "Force Shield",
            "Manaskin",
            "Diamondskin",
            "Steelskin",
            "Leatherskin",
            "Shieldskin",
        },
        ['SelfSpellShield1'] = {
            "Shield of Fate Rk. III",
            "Shield of Fate Rk. II",
            "Shield of Fate",
        },
        ['FDSpell'] = {
            "Death Pact",
            "Deathly Temptation",
            "Death's Silence",
            "Deathfury Axe",
            "Death's Despair",
            "Death's Regret",
            "Death Rune",
            "Deathclutch Manacles",
            "Deathclutch Manacles Rk. II",
            "Deathclutch Manacles Rk. III",
            "Death Peace",
        },
        ['CharmSpell'] = {
            "Enslave Death",
            "Thrall of Bones",
            "Cajole Undead",
            "Beguile Undead",
            "Dominate Undead",
        },
        ---DPS
        ['AllianceSpell'] = {
        },
        ['DichoDot'] = {
        },
        ['SwarmPet'] = {
        },
        ['Lifetap'] = {
            "Plunder Essence Rk. III",
            "Plunder Essence Rk. II",
            "Plunder Essence",
            "Bleed Essence",
            "Divert Essence",
            "Drain Essence",
            "Siphon Essence",
            "Drain Life",
            "Soulspike",
            "Touch of Mujaki",
            "Touch of Night",
            "Deflux",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Lifedraw",
            "Lifespike",
            "Lifetap",
        },
        ['DurationTap'] = {
            "Fang of Death",
            "Bond of Death",
            "Auspice",
            "Vampiric Curse",
            "Leech",
        },
        ['GroupLeech'] = {
            "Dark Leech Rk. III",
            "Dark Leech Rk. II",
            "Dark Leech",
            "Night Stalker",
        },
        ['ManaDrain'] = {
            "Mind Wipe",
            "Mind Strike",
            "Mind Shatter",
            "Mind Dissection Rk. II",
            "Mind Dissection Rk. III",
            "Mind Phobiate",
            "Mind Phobiate Rk. II",
            "Mind Phobiate Rk. III",
            "Mind Oscillate",
            "Mind Oscillate Rk. II",
            "Mind Oscillate Rk. III",
            "Mind Twist",
            "Mind Twist Rk. II",
            "Mind Twist Rk. III",
            "Mind Decomposition Rk. II",
            "Mind Decomposition Rk. III",
            "Mindshear Horror",
            "Mindshear Horror Rk. II",
            "Mindshear Horror Rk. III",
            "Mindfreeze",
            "Mindfreeze Rk. II",
            "Mindfreeze Rk. III",
            "Mindfreeze Strike",
            "Mind Helix",
            "Mind Helix Rk. II",
            "Mind Helix Rk. III",
            "Mind Helix Recourse",
            "Mind Helix Recourse II",
            "Mind Helix Recourse III",
            "Mindblade",
            "Mindblade Rk. II",
            "Mindblade Rk. III",
            "Mind Abrasion Rk. II",
            "Mind Abrasion Rk. III",
            "Mind Spiral",
            "Mind Spiral Rk. II",
            "Mind Spiral Rk. III",
            "Mind Spiral Recourse",
            "Mind Spiral Recourse II",
            "Mind Spiral Recourse III",
            "Mindscythe",
            "Mindscythe Rk. II",
            "Mindscythe Rk. III",
            "Mind Strip Rk. II",
            "Mind Strip Rk. III",
            "Mind Squall",
            "Mind Squall Rk. II",
            "Mind Squall Rk. III",
            "Mind Squall Recourse",
            "Mind Squall Recourse II",
            "Mind Squall Recourse III",
            "Mindcleave",
            "Mindcleave Rk. II",
            "Mindcleave Rk. III",
            "Mind Strip",
            "Mind Abrasion",
            "Thought Flay",
            "Mind Decomposition",
            "Mental Vivisection",
            "Mind Dissection",
            "Mind Flay",
            "Mind Wrack",
        },
        ['PoisonNuke1'] = {
            "Dissolving Venin Rk. III",
            "Dissolving Venin Rk. II",
            "Dissolving Venin",
            "Blighted Venin",
            "Withering Venin",
            "Ruinous Venin",
            "Venin",
            "Acikin",
            "Neurotoxin",
            "Shock of Poison",
        },
        ['PoisonNuke2'] = {
            "Impel for Blood Rk. III",
            "Impel for Blood Rk. II",
            "Impel for Blood",
            "Compel for Blood",
            "Exigency for Blood",
            "Supplication of Blood",
            "Demand for Blood",
            "Call for Blood",
        },
        ['FireNuke'] = {
            "Scintillate Bones Rk. III",
            "Scintillate Bones Rk. II",
            "Scintillate Bones",
            "Coruscate Bones",
            "Scorch Bones",
        },
        ['SearingDot'] = {
            "Coruscating Shadow Rk. III",
            "Coruscating Shadow Rk. II",
            "Coruscating Shadow",
            "Blazing Shadow",
            "Blistering Shadow",
            "Scorching Shadow",
            "Searing Shadow",
        },
        ['DreadDot'] = {
            "Pyre of Marnek Rk. III",
            "Pyre of Marnek Rk. II",
            "Pyre of Marnek",
            "Pyre of Hazarak",
            "Pyre of Nos",
            "Ashengate Pyre",
            "Dread Pyre",
            "Night Fire",
            "Funeral Pyre of Kelador",
            "Pyrocruor",
            "Ignite Blood",
            "Boil Blood",
            "Heat Blood",
        },
        ['DreadDot2'] = {
            "Pyre of Marnek Rk. III",
            "Pyre of Marnek Rk. II",
            "Pyre of Marnek",
            "Pyre of Hazarak",
            "Pyre of Nos",
            "Ashengate Pyre",
            "Dread Pyre",
            "Night Fire",
            "Funeral Pyre of Kelador",
            "Pyrocruor",
            "Ignite Blood",
            "Boil Blood",
            "Heat Blood",
        },
        ['FlashDot'] = {
        },
        ['MoriDot'] = {
            "Pyre of the Forsaken Rk. III",
            "Pyre of the Forsaken Rk. II",
            "Pyre of the Forsaken",
            "Pyre of the Bereft",
            "Pyre of the Forgotten",
            "Pyre of the Lifeless",
            "Pyre of the Fallen",
        },
        ['WoundDot'] = {
            "Violent Proliferation III",
            "Violent Proliferation II",
            "Violent Proliferation",
            "Pernicious Wounds Rk. III",
            "Pernicious Wounds Rk. II",
            "Pernicious Wounds",
            "Necrotizing Wounds",
            "Splirt",
            "Splart",
            "Splort",
            "Splurt",
        },
        ['HorrorDot'] = {
            "Termination Rk. III",
            "Termination Rk. II",
            "Termination",
            "Doom",
            "Demise",
            "Mortal Coil",
            "Anathema of Life",
            "Curse of Mortality",
            "Ancient: Curse of Mori",
            "Dark Nightmare",
            "Horror",
        },
        ['HorrorDot2'] = {
            "Termination Rk. III",
            "Termination Rk. II",
            "Termination",
            "Doom",
            "Demise",
            "Mortal Coil",
            "Anathema of Life",
            "Curse of Mortality",
            "Ancient: Curse of Mori",
            "Dark Nightmare",
            "Horror",
        },
        ['DeconDot'] = {
        },
        ['ScourgeDot'] = {
            "Scourge of Fates Rk. III",
            "Scourge of Fates Rk. II",
            "Scourge of Fates",
        },
        ['ComboDot'] = {                ---Combines GripDot and DecayDot
        },
        ['DecayDot'] = {
            "Chaos Flux",
            "Chaos Venom",
            "Chaos Flame",
            "Chaos Immolation",
            "Chaos Immolation Rk. II",
            "Chaos Immolation Rk. III",
            "Chaos Conflagration",
            "Chaos Conflagration Rk. II",
            "Chaos Conflagration Rk. III",
            "Chaos Combustion",
            "Chaos Combustion Rk. II",
            "Chaos Combustion Rk. III",
            "Chaos Char",
            "Chaos Char Rk. II",
            "Chaos Char Rk. III",
            "Chaos Blaze",
            "Chaos Blaze Rk. II",
            "Chaos Blaze Rk. III",
            "Chaos Incandescence",
            "Chaos Incandescence Rk. II",
            "Chaos Incandescence Rk. III",
            "Chaos Plague",
            "Dark Plague",
            "Cessation of Cor",
        },
        ['GripDot'] = {
            "Grip of Zalikor Rk. III",
            "Grip of Zalikor Rk. II",
            "Grip of Zalikor",
            "Grip of Zargo",
            "Grip of Mori",
            "Plague",
            "Asystole",
            "Scourge",
            "Heart Flutter",
            "Disease Cloud",
        },
        ['SwiftDiseaseDot'] = {
        },
        ['SwiftPoisonDot'] = {
        },
        ['VenomDot'] = {
            "Binaesa Venom Rk. III",
            "Binaesa Venom Rk. II",
            "Binaesa Venom",
            "Naeya Venom",
            "Slitheren Venom",
            "Venonscale Venom",
            "Blood of Thule",
            "Envenomed Bolt",
            "Chilling Embrace",
            "Venom of the Snake",
            "Poison Bolt",
        },
        ['VenomDot2'] = {
            "Binaesa Venom Rk. III",
            "Binaesa Venom Rk. II",
            "Binaesa Venom",
            "Naeya Venom",
            "Slitheren Venom",
            "Venonscale Venom",
            "Blood of Thule",
            "Envenomed Bolt",
            "Chilling Embrace",
            "Venom of the Snake",
            "Poison Bolt",
        },
        ['HazeDot'] = {
            "Chaos Flux",
            "Chaos Plague",
            "Chaos Flame",
            "Chaos Immolation",
            "Chaos Immolation Rk. II",
            "Chaos Immolation Rk. III",
            "Chaos Conflagration",
            "Chaos Conflagration Rk. II",
            "Chaos Conflagration Rk. III",
            "Chaos Combustion",
            "Chaos Combustion Rk. II",
            "Chaos Combustion Rk. III",
            "Chaos Char",
            "Chaos Char Rk. II",
            "Chaos Char Rk. III",
            "Chaos Blaze",
            "Chaos Blaze Rk. II",
            "Chaos Blaze Rk. III",
            "Chaos Incandescence",
            "Chaos Incandescence Rk. II",
            "Chaos Incandescence Rk. III",
            "Chaos Venom",
        },
        ['PutrefactionDot'] = {
            "Dissolution Rk. III",
            "Dissolution Rk. II",
            "Dissolution",
            "Mortification",
            "Fetidity",
            "Putrescence",
            "Putrefaction",
        },
        ['CripplingTap'] = {
            "Crippling Incapacity Rk. III",
            "Crippling Incapacity Rk. II",
            "Crippling Incapacity",
            "Crippling Claudication",
        },
        ['ChaoticDebuff'] = {
            "Chaotic Corruption Rk. III",
            "Chaotic Corruption Rk. II",
            "Chaotic Corruption",
            "Chaotic Contagion",
        },
        ['SnareDot'] = {
            "Clutching Darkness Rk. III",
            "Clutching Darkness Rk. II",
            "Clutching Darkness",
            "Viscous Darkness",
            "Tenuous Darkness",
            "Clawing Darkness",
            "Auroral Darkness",
            "Coruscating Darkness",
            "Desecrating Darkness",
            "Embracing Darkness",
            "Devouring Darkness",
            "Cascading Darkness",
            "Scent of Darkness",
            "Dooming Darkness",
            "Engulfing Darkness",
            "Clinging Darkness",
        },
        ['ScentDebuff'] = {
            "Scent of Dread Rk. III",
            "Scent of Dread Rk. II",
            "Scent of Dread",
            "Scent of Nightfall",
            "Scent of Doom",
            "Scent of Gloom",
            "Scent of Afterlight",
            "Scent of Twilight",
            "Scent of Midnight",
            "Scent of Terris",
            "Scent of Darkness",
            "Scent of Shadow",
            "Scent of Dusk",
        },
        ['LichSpell'] = {
            "Forsakenside Rk. III",
            "Forsakenside Rk. II",
            "Forsakenside",
            "Shadowside",
            "Darkside",
            "Netherside",
            "Spectralside",
            "Otherside",
            "Dark Possession",
            "Grave Pact",
            "Seduction of Saryrn",
            "Arch Lich",
            "Demi Lich",
            "Lich",
            "Call of Bones",
            "Allure of Death",
            "Dark Pact",
        },
        ['BestowBuff'] = {
            "Bestow Mortality Rk. III",
            "Bestow Mortality Rk. II",
            "Bestow Mortality",
            "Bestow Decay",
            "Bestow Unlife",
            "Bestow Undeath",
        },
        ['RogPetSpell'] = {
            "Dark Assassin XVI",    -- Level 130
            "Merciless Assassin",   -- Level 125
            "Unrelenting Assassin", -- Level 120
            "Restless Assassin",    -- Level 115
            "Reliving Assassin",    -- Level 110
            "Revived Assassin",     -- Level 105
            "Unearthed Assassin",   -- Level 100
            "Reborn Assassin",      -- Level 95
            "Raised Assassin",      -- Level 90
            "Unliving Murderer",    -- Level 85
            "Noxious Servant",      -- Level 80
            "Putrescent Servant",   -- Level 75
            "Dark Assassin",        -- Level 70
            "Saryrn's Companion",   -- Level 63
            "Minion of Shadows",    -- Level 53
        },
        ['WarPetSpell'] = {
            "Rasvimun's Shade",      -- Level 127
            "Margator's Shade",      -- Level 122
            "Luclin's Conqueror",    -- Level 117
            "Tserrina's Shade",      -- Level 112
            "Adalora's Shade",       -- Level 107
            "Miktokla's Shade",      -- Level 102
            "Zalifur's Shade",       -- Level 97
            "Vak`Ridel's Shade",     -- Level 92
            "Aziad's Shade",         -- Level 87
            "Bloodreaper's Shade",   -- Level 82
            "Relamar's Shade",       -- Level 77
            "Riza`farr's Shadow",    -- Level 72
            "Lost Soul",             -- Level 67
            "Child of Bertoxxulous", -- Level 65
            "Emissary of Thule",     -- Level 59
            "Servant of Bones",      -- Level 56
            "Invoke Death",          -- Level 48
            "Cackling Bones",        -- Level 44
            "Malignant Dead",        -- Level 39
            "Invoke Shadow",         -- Level 33
            "Summon Dead",           -- Level 29
            "Haunting Corpse",       -- Level 24
            "Animate Dead",          -- Level 20
            "Restless Bones",        -- Level 16
            "Convoke Shadow",        -- Level 12
            "Bone Walk",             -- Level 8
            "Leering Corpse",        -- Level 4
            "Cavorting Bones",       -- Level 1
        },
        ['PetBuff'] = {
        },
        ['PetHaste'] = {
            "Sigil of the Sundered Rk. III",
            "Sigil of the Sundered Rk. II",
            "Sigil of the Sundered",
            "Sigil of the Preternatural",
            "Sigil of the Moribund",
            "Sigil of the Aberrant",
            "Sigil of the Unnatural",
            "Glyph of Darkness",
            "Rune of Death",
            "Augmentation of Death",
            "Augment Death",
            "Intensify Death",
            "Focus Death",
        },
        ['PetHealSpell'] = {
            "Algid Mending Rk. III",
            "Algid Mending Rk. II",
            "Algid Mending",
            "Chilled Mending",
            "Gelid Mending",
            "Icy Stitches",
            "Wintry Revival",
            "Chilling Renewal",
            "Dark Salve",
            "Touch of Death",
            "Renew Bones",
            "Mend Bones",
        },
        ['FleshBuff'] = {
            "Burning Poison III",
            "Burning Poison II",
            "Burning Poison",
            "Flesh to Poison Rk. III",
            "Flesh to Poison Rk. II",
            "Flesh to Poison",
        },
    },
    ['Charm']           = {
        ['Abilities'] = {
            { name = "Dire Charm", type = "AA", },
            { name = "CharmSpell", type = "Spell", },
        },
    },
    ['RotationOrder']   = {
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
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and Casting.AmIBuffable() and not Core.IsCharming()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 10,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'Lich Management',
            timer = 10,
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return true
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'PetHealing',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, target) return (mq.TLO.Me.Pet.PctHPs() or 100) < Config:GetSetting('PetHealPct') end,
        },
        {
            name = 'Scent',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoScentDebuff') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Casting.OkayToDebuff() and Core.CombatActionsCheck()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Globals.AutoTargetIsNamed and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount') and
                    not Casting.IAmFeigning() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and
                    Casting.BurnCheck() and not Casting.IAmFeigning() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'DPS(MobHighHP)',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Targeting.MobNotLowHP(Targeting.GetAutoTarget()) and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'DPS(MobLowHP)',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning() and Targeting.MobHasLowHP(Targeting.GetAutoTarget()) and Core.CombatActionsCheck()
            end,
        },
    },
    ['Rotations']       = {
        ['Lich Management'] = {
            {
                name = "LichSpell",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Config:GetSetting('DoLich') and Casting.SelfBuffCheck(spell) and
                        (not Config:GetSetting('DoUnity') or not Casting.AAReady("Mortifier's Unity")) and
                        mq.TLO.Me.PctHPs() > Config:GetSetting('StopLichHP') and mq.TLO.Me.PctMana() <= Config:GetSetting('StartLichMana')
                end,
            },
            {
                name = "LichControl",
                type = "CustomFunc",
                cond = function(self, _)
                    local lichSpell = Core.GetResolvedActionMapItem('LichSpell')

                    return not (Config:GetSetting('DoUnity') and Casting.CanUseAA("Mortifier's Unity")) and lichSpell and lichSpell() and Casting.IHaveBuff(lichSpell) and
                        (mq.TLO.Me.PctHPs() <= Config:GetSetting('StopLichHP') or mq.TLO.Me.PctMana() >= Config:GetSetting('StopLichMana'))
                end,
                custom_func = function(self)
                    Core.SafeCallFunc("Stop Necro Lich", self.Helpers.CancelLich, self)
                end,
            },
            {
                name = "FleshControl",
                type = "CustomFunc",
                cond = function(self, _)
                    local fleshSpell = self:GetResolvedActionMapItem('FleshBuff')

                    return fleshSpell and fleshSpell() and Casting.IHaveBuff(fleshSpell) and mq.TLO.Me.PctHPs() <= Config:GetSetting('StopLichHP')
                end,
                custom_func = function(self)
                    Core.SafeCallFunc("Stop Flesh Buff", self.Helpers.CancelFlesh, self)
                end,
            },
        },
        ['Emergency']       = {
            {
                name = "Death's Effigy",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AggroFeign') then return false end
                    if Config:GetSetting('CharmOn') and mq.TLO.Me.Pet.ID() > 0 then return false end
                    return (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99) or (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100))
                end,
            },
            {
                name = "Death Peace",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99) or (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100))
                end,
            },
            {
                name = "Dying Grasp",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Embalmer's Carapace",
                type = "AA",
            },
            {
                name = "Lifetap",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLifetap') end,
            },
        },
        ['Scent']           = {
            {
                name = "Scent of Thule",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "ScentDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['DPS(MobHighHP)']  = {
            {
                name = "DurationTap",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDurationTap') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "DreadDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDreadDot') > 1 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "ManaDrain",
                type = "Spell",
                cond = function(self, spell, target)
                    if not spell or not spell() then return false end
                    return Casting.IHaveBuff(spell.Name() .. " Recourse") and (mq.TLO.Target.PctMana() or -1) > 0 and mq.TLO.Group.LowMana(40)() > 2
                end,
            },
            {
                name = "VenomDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoVenomDot') > 1 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "ComboDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoComboDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "HorrorDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHorrorDot') > 1 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "GroupLeech",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoGroupLeech') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target) and
                        self.Helpers.GroupMemberBelowHP(self, Config:GetSetting('LightHealPoint'))
                end,
            },
            {
                name = "DichoDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDichoDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "SearingDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSearingDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "MoriDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoMoriDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "WoundDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoWoundDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "DecayDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDecayDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "GripDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoGripDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "HazeDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHazeDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "DreadDot2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDreadDot') > 2 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "VenomDot2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoVenomDot') > 2 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "HorrorDot2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHorrorDot') > 2 end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell, target)
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell, target)
                    return Globals.AutoTargetIsNamed and Casting.OkayToNuke()
                end,
            },
            {
                name = "PoisonNuke2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "PoisonNuke1",
                type = "Spell",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('PoisonNuke2') end,
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
        },
        ['DPS(MobLowHP)']   = {
            {
                name = "Lifetap",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLifetap') end,
                cond = function(self, spell, target)
                    return Casting.OkayToNuke() and Targeting.LightHealsNeeded(mq.TLO.Me)
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "PoisonNuke2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "PoisonNuke1",
                type = "Spell",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('PoisonNuke2') end,
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
        },
        ['Snare']           = {
            {
                name = "Encroaching Darkness",
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Encroaching Darkness") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareDot",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Encroaching Darkness") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
        },
        ['Burn']            = { -- TODO: Needs optimization. For now its all just kinda thrown in. --Algar
            {
                name = "Scent of Thule",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName, target)
                    return Globals.AutoTargetIsNamed and Targeting.GetAutoTargetPctHPs() <= Config:GetSetting('BurnHPThreshold')
                end,
            },
            {
                name = "Funeral Pyre",
                type = "AA",
            },
            {
                name = "Hand of Death",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and Targeting.GetAutoTargetPctHPs() <= Config:GetSetting('BurnHPThreshold')
                end,
            },
            {
                name = "Mercurial Torment",
                type = "AA",
            },
            {
                name = "Heretic's Twincast",
                type = "AA",
            },
            {
                name = "Gathering Dusk",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and Targeting.GetAutoTargetPctHPs() <= Config:GetSetting('BurnHPThreshold') and mq.TLO.Me.PctAggro() <= 25
                end,
            },
            {
                name = "Swarm of Decay",
                type = "AA",
            },
            {
                name = "Wake the Dead",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.SpawnCount("corpse radius 100 los")() >= Config:GetSetting('WakeDeadCorpseCnt')
                end,
            },
            {
                name = "Companion's Fury",
                type = "AA",
            },
            {
                name = "Rise of Bones",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target) return Globals.AutoTargetIsNamed end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
            {
                name = "Spire of Necromancy",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and Targeting.GetAutoTargetPctHPs() <= Config:GetSetting('BurnHPThreshold')
                end,
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "BestowBuff",
                type = "Spell",
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 60
                end,
            },
            {
                name = "Dying Grasp",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() <= 50
                end,
            },
        },
        ['PetHealing']      = {
            {
                name = "Mend Companion",
                type = "AA",
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.Pet.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "Companion's Fortification",
                type = "AA",
                cond = function(self, aaName, target)
                    return (mq.TLO.Me.Pet.PctHPs() or 999) <= Config:GetSetting('BigHealPoint')
                end,
            },
            {
                name = "PetHealSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoPetHealSpell') end,
            },
        },
        ['Downtime']        = {
            {
                name = "Mortifier's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoUnity') and mq.TLO.Me.PctHPs() > Config:GetSetting('StopLichHP') and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Dead Man Floating",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoLevitate') and Casting.CanUseAA("Dead Man Floating") end,
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) end,
            },
            {
                name = "Levitate",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLevitate') and not Casting.CanUseAA("Dead Man Floating") end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfSpellShield1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Death Bloom",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < Config:GetSetting('DeathBloomPercent') end,
            },
            {
                name = "BestowBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "FleshBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyStart') and Casting.SelfBuffCheck(spell)
                end,
            },
        },
        ['PetSummon']       = { --TODO: Double check these lists to ensure someone leveling doesn't have to change options to keep pets current at lower levels
            {
                name_func = function(self)
                    return string.format("%sPetSpell", self.ClassConfig.DefaultConfig.PetType.ComboOptions[Config:GetSetting('PetType')])
                end,
                type = "Spell",
                active_cond = function(self) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell)
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    local pet = mq.TLO.Me.Pet
                    if success and pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff']         = {
            {
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "PetBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
    },
    ['Helpers']         = {
        -- Check if any group member (excluding self) is at or below a given HP%. This is used to make sure someone needs to heal before we use the group leech.
        -- The intent is to only use the mana heavy group leech as a quasi-heal when someone actually needs the health.
        GroupMemberBelowHP = function(self, pct)
            local count = mq.TLO.Group.Members() or 0
            for i = 1, count do
                local member = mq.TLO.Group.Member(i)
                if member and member() and (member.PctHPs() or 100) <= pct then
                    return true
                end
            end
            return false
        end,

        CancelLich = function(self)
            -- detspa means detremental spell affect
            -- spa is positive spell affect
            local lichName = mq.TLO.Me.FindBuff("detspa hp and spa mana")()
            Core.DoCmd("/removebuff %s", lichName)
        end,

        CancelFlesh = function(self)
            local fleshName = self:GetResolvedActionMapItem('FleshBuff')
            Core.DoCmd("/removebuff %s", fleshName)
        end,

        StartLich = function(self)
            local lichSpell = Core.GetResolvedActionMapItem('LichSpell')

            if lichSpell and lichSpell() then
                Casting.UseSpell(lichSpell.RankName.Name(), mq.TLO.Me.ID(), false)
            end
        end,
    },
    ['SpellList']       = {
        {
            name = "Default",
            -- cond = function(self) return true end, --Kept here for illustration, this line could be removed in this instance since we aren't using conditions.
            spells = {
                { name = "WarPetSpell",  cond = function(self) return Config:GetSetting('PetType') == 1 and (mq.TLO.Me.Pet.ID() or 0) == 0 end, },
                { name = "RogPetSpell",  cond = function(self) return Config:GetSetting('PetType') == 2 and (mq.TLO.Me.Pet.ID() or 0) == 0 end, },
                { name = "PetHealSpell", cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "PoisonNuke1",  cond = function(self) return not Core.GetResolvedActionMapItem('PoisonNuke2') end, },
                { name = "PoisonNuke2", },
                { name = "FireNuke", },
                { name = "Lifetap",      cond = function(self) return Config:GetSetting('DoLifetap') end, },
                { name = "CharmSpell",   cond = function(self, spell) return Config:GetSetting('CharmOn') and Core.IsSelectedCharmSpell(spell) end, },
                { name = "SnareDot",     cond = function(self) return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Enchroaching Darkness") end, },
                { name = "ScentDebuff",  cond = function(self) return Config:GetSetting('DoScentDebuff') and not Casting.CanUseAA("Scent of Thule") end, },
                { name = "LichSpell",    cond = function(self) return not Config:GetSetting('DoUnity') end, },
                { name = "SwarmPet", },
                { name = "DurationTap",  cond = function(self) return Config:GetSetting('DoDurationTap') end, },
                { name = "DreadDot",     cond = function(self) return Config:GetSetting('DoDreadDot') > 1 end, },
                { name = "VenomDot",     cond = function(self) return Config:GetSetting('DoVenomDot') > 1 end, },
                { name = "HorrorDot",    cond = function(self) return Config:GetSetting('DoHorrorDot') > 1 end, },
                { name = "ComboDot",     cond = function(self) return Config:GetSetting('DoComboDot') end, },
                { name = "GroupLeech",   cond = function(self) return Config:GetSetting('DoGroupLeech') end, },
                { name = "DichoDot",     cond = function(self) return Config:GetSetting('DoDichoDot') end, },
                { name = "SearingDot",   cond = function(self) return Config:GetSetting('DoSearingDot') end, },
                { name = "MoriDot",      cond = function(self) return Config:GetSetting('DoMoriDot') end, },
                { name = "WoundDot",     cond = function(self) return Config:GetSetting('DoWoundDot') end, },
                { name = "DecayDot",     cond = function(self) return Config:GetSetting('DoDecayDot') end, },
                { name = "GripDot",      cond = function(self) return Config:GetSetting('DoGripDot') end, },
                { name = "HazeDot",      cond = function(self) return Config:GetSetting('DoHazeDot') end, },
                { name = "DreadDot2",    cond = function(self) return Config:GetSetting('DoDreadDot') > 2 end, },
                { name = "VenomDot2",    cond = function(self) return Config:GetSetting('DoVenomDot') > 2 end, },
                { name = "HorrorDot2",   cond = function(self) return Config:GetSetting('DoHorrorDot') > 2 end, },
                { name = "ManaDrain", },
                { name = "FleshBuff",    cond = function(self) return not Config:GetSetting('DoUnity') or not Casting.CanUseAA("Mortifier's Unity") end, },
                { name = "BestowBuff", },
                { name = "PetBuff", },
            },
        },
    },
    ['DefaultConfig']   = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Currently Necros only have one mode, which is DPS. This mode will focus on DPS and some utility.",
        },
        ['PetType']           = {
            DisplayName = "Pet Class",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Summoning",
            Tooltip = "1 = War, 2 = Rog",
            Type = "Combo",
            ComboOptions = { 'War', 'Rog', },
            Default = function() return Core.GetResolvedActionMapItem('RogPetSpell') and 2 or 1 end,
            Min = 1,
            Max = 2,
            RequiresLoadoutChange = true,
        },
        ['DoPetHealSpell']    = {
            DisplayName = "Pet Heal Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Mem and cast your Pet Heal spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['PetHealPct']        = {
            DisplayName = "Pet Heal Spell HP%",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Index = 101,
            Tooltip = "Use your pet heal spell when your pet is at or below this HP percentage.",
            Default = 80,
            Min = 1,
            Max = 99,
        },
        ['DoLifeBurn']        = {
            DisplayName = "Use Life Burn",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Life Burn AA if your aggro is below 25%.",
            Default = true,
        },
        ['DoUnity']           = {
            DisplayName = "Cast Unity",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Enable casting Mortifiers Unity.",
            Default = true,
            Index = 101,
        },
        ['DeathBloomPercent'] = {
            DisplayName = "Death Bloom %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Tooltip = "Mana % at which to cast Death Bloom",
            Default = 40,
            Min = 1,
            Max = 100,
        },
        ['DoSnare']           = {
            DisplayName = "Use Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 101,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['SnareCount']        = {
            DisplayName = "Snare Max Mob Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 102,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
            Min = 1,
            Max = 99,
        },
        ['WakeDeadCorpseCnt'] = {
            DisplayName = "WtD Corpse Count",
            Group = "Abilities",
            Header = "Pet",
            Category = "Swarm Pets",
            Tooltip = "Number of Corpses before we cast Wake the Dead",
            Default = 5,
            Min = 1,
            Max = 20,
        },
        ['DoLich']            = {
            DisplayName = "Cast Lich",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Enable casting Lich spells.",
            RequiresLoadoutChange = true,
            Default = true,
            Index = 102,
        },
        ['StopLichHP']        = {
            DisplayName = "Stop Lich HP",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Cancel Lich at HP Pct [x]",
            RequiresLoadoutChange = false,
            Default = 25,
            Min = 1,
            Max = 99,
            Index = 103,
        },
        ['StopLichMana']      = {
            DisplayName = "Stop Lich Mana",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Cancel your Lich spell when your mana has increased to this percentage. (Selecting 101 will disable canceling lich based on mana percent.)",
            RequiresLoadoutChange = false,
            Default = 100,
            Min = 1,
            Max = 101,
            Index = 104,
        },
        ['StartLichMana']     = {
            DisplayName = "Start Lich Mana",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Start Lich at Mana Pct [x]",
            RequiresLoadoutChange = false,
            Default = 70,
            Min = 1,
            Max = 100,
            Index = 105,
        },
        ['DoLevitate']        = {
            DisplayName = "Do Levitate",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Enable self-casting your Dead Man Floating spell.",
            RequiresLoadoutChange = true,
            Default = true,
            Index = 106,
        },
        ['DoScentDebuff']     = {
            DisplayName = "Use Scent Debuff",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Tooltip = "Use your Scent debuff spells or AA.",
            RequiresLoadoutChange = true, --this setting is used as a load condition
            Default = false,
        },
        ['DoLifetap']         = {
            DisplayName = "Do Lifetap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 101,
            Tooltip = "Use the your ST Lifetap nuke line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['EmergencyStart']    = {
            DisplayName = "Emergency HP%",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 101,
            Tooltip = "Your HP % before we begin to use emergency mitigation abilities.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['AggroFeign']        = {
            DisplayName = "Emergency Feign",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 102,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a mob detected as a 'named' by RGMercs (see Named tab)..",
            Default = true,
        },
        ['DoDurationTap']     = {
            DisplayName = "Do Duration Tap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = "Use your duration tap line of dots.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoDreadDot']        = {
            DisplayName = "Do Dread Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 102,
            Tooltip = "Select the number of Dread (Fire) dots to use.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { "Disabled", "Current Tier", "Current + Last Tier", },
            Default = 2,
            Min = 1,
            Max = 3,
        },
        ['DoVenomDot']        = {
            DisplayName = "Do Venom Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 103,
            Tooltip = "Select the number of Venom (Poison) dots to use.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { "Disabled", "Current Tier", "Current + Last Tier", },
            Default = 2,
            Min = 1,
            Max = 3,
        },
        ['DoHorrorDot']       = {
            DisplayName = "Do Horror Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 104,
            Tooltip = "Select the number of Horror (Magic) dots to use.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { "Disabled", "Current Tier", "Current + Last Tier", },
            Default = 2,
            Min = 1,
            Max = 3,
        },
        ['DoComboDot']        = {
            DisplayName = "Do Combo Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 105,
            Tooltip = "Use your Disease combination (Grip+Decay) line of dots.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoGroupLeech']      = {
            DisplayName = "Do Group Leech",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 106,
            Tooltip = "Use your Group Leech dot line. Only fires when a watched party member is below the light heal threshold.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoDichoDot']        = {
            DisplayName = "Do Dicho Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 107,
            Tooltip = "Use your Dichotomic Paroxysm dot line.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoSearingDot']      = {
            DisplayName = "Do Searing Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 108,
            Tooltip = "Use your Searing (Fire) dot line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoMoriDot']         = {
            DisplayName = "Do Mori Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 109,
            Tooltip = "Use your Mori (Fire) dot line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoWoundDot']        = {
            DisplayName = "Do Wound Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 110,
            Tooltip = "Use your Wound (Magic) dot line.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoDecayDot']        = {
            DisplayName = "Do Decay Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 111,
            Tooltip = "Use your Decay (Disease) dot line.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoGripDot']         = {
            DisplayName = "Do Grip Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 112,
            Tooltip = "Use your Grip (Disease) dot line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoHazeDot']         = {
            DisplayName = "Do Haze Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 113,
            Tooltip = "Use your Haze (Poison) dot line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoChestClick']      = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['BurnHPThreshold']   = {
            DisplayName = "Burn HP Threshold",
            Group = "Combat",
            Header = "Burning",
            Category = "Burning",
            Index = 101,
            Tooltip =
            "Burn abilities that are best used once dots have been applied will be held until a named has reached this HP value. (Affected abilities: Spire, Hand of Death, Gathering Dusk, OoW Robe)",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
    },
    ['ClassFAQ']        = {
        {
            Question = "What is the current status of this class config?",
            Answer = "This class config is a current release aimed at official servers.\n\n" ..
                "  This config is largely a port from older code, and has seen only minor adjustments. It has been flagged for revamp when we have the chance!\n\n" ..
                " Some revamps have occured to provide more spell/dot options, but it's still rough around the edges!\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}

return _ClassConfig
