local mq              = require('mq')
local Casting         = require("utils.casting")
local Comms           = require("utils.comms")
local Config          = require('utils.config')
local Core            = require("utils.core")
local Globals         = require("utils.globals")
local ItemManager     = require("utils.item_manager")
local Logger          = require("utils.logger")
local Modules         = require("utils.modules")
local Targeting       = require("utils.targeting")

-- Provide a valid aura name to check as they are named differently then the spells
-- -- Only use the first word(s) of the aura name, they are all unique (enough)
local auraSpellToName = {
    ["Mana Recursion Aura XI"] = "Mana Recursion",
    ["Mana Ripple Aura"] = "Mana Ripple",
    ["Mana Radix Aura"] = "Mana Radix",                 -- "Mana Radix Aura"
    ["Mana Replication Aura"] = "Mana Replication",     -- "Mana Replication Aura"
    ["Mana Repetition Aura"] = "Mana Repetition",       -- "Mana Repetition Aura"
    ["Mana Reciprocation Aura"] = "Mana Reciprocation", -- "Mana Reciprocation Aura"
    ["Mana Reverberation Aura"] = "Mana Rev",           -- "Mana Rev. Aura"
    ["Mana Repercussion Aura"] = "Mana Rep",            -- "Mana Rep. Aura"
    ["Mana Reiteration Aura"] = "Mana Recursion",       -- "Mana Recursion Aura"
    ["Mana Reiterate Aura"] = "Mana Reiterate",         -- "Mana Reiterate Aura"
    ["Mana Resurgence Aura"] = "Mana Resurgence",       -- "Mana Resurgence Aura"
    ["Mystifier's Aura"] = "Mystifier",                 -- "Mystifier's Aura"
    ["Entrancer's Aura"] = "Entrancer",                 -- "Entrancer's Aura"
    ["Illusionist's Aura"] = "Illusionist",             -- "Illusionist's Aura"
    ["Beguiler's Aura"] = "Beguiler",                   -- "Beguiler's Aura"
}

local _ClassConfig    = {
    _version          = "DODL CUSTOM",
    _author           = "eldudero",
    ['ModeChecks']    = {
        CanMez    = function() return true end,
        CanCharm  = function() return true end,
        IsMezzing = function() return Config:GetSetting('MezOn') end,
    },
    ['Modes']         = {
        'Default',
        'ModernEra', --Different DPS rotation, meant for ~90+ (and may not come fully online until 105ish)
    },
    ['PetPosition']   = {
        SummonAA   = function() return Casting.CanUseAA("Summon Companion") and "Summon Companion" end,
        RelocateAA = function()
            local cdAA = mq.TLO.Me.AltAbility("Companion's Discipline")
            return (cdAA and cdAA.Rank() or 0) >= 5 and "Companion's Discipline"
        end,
    },
    ['Themes']        = {
        ['Default'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.05, g = 0.45, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.05, g = 0.45, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.02, g = 0.17, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.05, g = 0.45, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.05, g = 0.45, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.02, g = 0.17, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.05, g = 0.45, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.05, g = 0.45, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.05, g = 0.45, b = 0.50, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.03, g = 0.28, b = 0.32, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.05, g = 0.45, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.05, g = 0.45, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.05, g = 0.45, b = 0.50, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.02, g = 0.17, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.10, g = 0.90, b = 1.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.10, g = 0.90, b = 1.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.05, g = 0.45, b = 0.50, a = 1.0, }, },
        },
        ['ModernEra'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.05, g = 0.30, b = 0.45, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.05, g = 0.30, b = 0.45, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.02, g = 0.11, b = 0.18, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.05, g = 0.30, b = 0.45, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.05, g = 0.30, b = 0.45, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.02, g = 0.11, b = 0.18, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.05, g = 0.30, b = 0.45, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.05, g = 0.30, b = 0.45, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.05, g = 0.30, b = 0.45, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.03, g = 0.19, b = 0.29, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.05, g = 0.30, b = 0.45, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.05, g = 0.30, b = 0.45, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.05, g = 0.30, b = 0.45, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.02, g = 0.11, b = 0.18, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.10, g = 0.90, b = 1.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.10, g = 0.90, b = 1.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.05, g = 0.30, b = 0.45, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Staff of Eternal Eloquence",
            "Oculus of Persuasion",
        },
    },
    ['AbilitySets']   = {
        ['PetSpell'] = {
            "Arkahn's Animation",    -- Level 126
            "Flariton's Animation",  -- Level 121
            "Constance's Animation", -- Level 116
            "Omica's Animation",     -- Level 111
            "Nureya's Animation",    -- Level 106
            "Gordianus' Animation",  -- Level 101
            "Xorlex's Animation",    -- Level 96
            "Seronvall's Animation", -- Level 91
            "Novak's Animation",     -- Level 86
            "Yozan's Animation",     -- Level 81
            "Erradien's Animation",  -- Level 76
            "Ellowind's Animation",  -- Level 71
            "Salik's Animation",     -- Level 66
            "Aeldorb's Animation",   -- Level 62
            "Zumaik's Animation",    -- Level 55
            "Kintaz's Animation",    -- Level 48
            "Yegoreff's Animation",  -- Level 41
            "Aanya's Animation",     -- Level 37
            "Boltran's Animation",   -- Level 31
            "Uleen's Animation",     -- Level 29
            "Sagar's Animation",     -- Level 22
            "Sisna's Animation",     -- Level 17
            "Shalee's Animation",    -- Level 14
            "Kilan's Animation",     -- Level 9
            "Mircyl's Animation",    -- Level 7
            "Juli's Animation",      -- Level 2
            "Pendril's Animation",   -- Level 1
        },
        ['PetBuffSpell'] = {
            "Empowered Minion IV", -- Level 128
            "Invigorated Minion",  -- Level 117
            "Infused Minion",      -- Level 107
            "Empowered Minion",    -- Level 97
        },
        ['TwincastAura'] = {
            "Twincast Aura Rk. III",
            "Twincast Aura Rk. II",
            "Twincast Aura",
        },
        ['SpellProcAura'] = {
            "Mana Reverberation Aura Rk. III",
            "Mana Reverberation Aura Rk. II",
            "Mana Reverberation Aura",
            "Mana Repercussion Aura",
            "Mana Reiteration Aura",
            "Mana Reiterate Aura",
            "Mana Resurgence Aura",
        },
        ['LearnersAura'] = {
        },
        ['HasteBuff'] = {
            "Hastening of Sviir Rk. III",
            "Hastening of Sviir Rk. II",
            "Hastening of Sviir",
            "Speed of Sviir",
            "Hastening of Aransir",
            "Speed of Aransir",
            "Hastening of Novak",
            "Speed of Novak",
            "Hastening of Erradien",
            "Speed of Erradien",
            "Hastening of Ellowind",
            "Speed of Ellowind",
            "Hastening of Salik",
            "Speed of Salik",
            "Speed of Vallon",
            "Speed of the Brood",
            "Visions of Grandeur",
            "Wondrous Rapidity",
            "Swift Like the Wind",
            "Celerity",
            "Augmentation",
            "Alacrity",
            "Quickness",
        },
        ['ManaRegen'] = {
            "Voice of Foresight Rk. III",
            "Voice of Foresight Rk. II",
            "Voice of Foresight",
            "Foresight",
            "Voice of Premeditation",
            "Premeditation",
            "Voice of Forethought",
            "Forethought",
            "Voice of Prescience",
            "Prescience",
            "Voice of Cognizance",
            "Voice of Intuition",
            "Voice of Clairvoyance",
            "Clairvoyance",
            "Voice of Quellious",
            "Tranquility",
            "Gift of Pure Thought",
            "Gift of Insight",
            "Clarity II",
            "Clarity",
            "Breeze",
        },
        ['MezBuff'] = {
            "Ward of the Mastermind Rk. III",
            "Ward of the Mastermind Rk. II",
            "Ward of the Mastermind",
            "Ward of Arctending",
            "Ward of Bafflement",
            "Ward of Befuddlement",
            "Ward of Mystifying",
            "Ward of Bewilderment",
            "Ward of Bedazzlement",
        },
        ['NdtBuff'] = {
            "Boon of Immolation",
            "Boon of the Clear Mind",
            "Boon of the Garou",
        },
        ['SelfHPBuff'] = {
            "Shield of the Dauntless Rk. III",
            "Shield of the Dauntless Rk. II",
            "Shield of the Dauntless",
            "Shield of Bronze",
            "Shield of Dreams",
            "Shield of the Void",
            "Spellbound Shield",
            "Sorcerous Shield",
            "Mystic Shield",
            "Shield of Maelin",
            "Shield of the Arcane",
            "Shield of the Magi",
            "Arch Shielding",
            "Greater Shielding",
            "Major Shielding",
            "Shielding",
            "Lesser Shielding",
            "Minor Shielding",
        },
        ['SelfRune1'] = {
            "Spectral Rune Rk. III",
            "Spectral Rune Rk. II",
            "Spectral Rune",
            "Pearlescent Rune",
            "Opalescent Rune",
            "Draconic Rune",
            "Ethereal Rune",
            "Arcane Rune",
        },
        ['SelfRune2'] = {
            "Polyiridescent Rune Rk. III",
            "Polyiridescent Rune Rk. II",
            "Polyiridescent Rune",
            "Polyarcanic Rune",
            "Polyspectral Rune",
            "Polychaotic Rune",
            "Multichromatic Rune",
            "Polychromatic Rune",
        },
        ['UnityRune'] = {
        },
        ['SingleRune'] = {
            "Rune of Xolok Rk. III",
            "Rune of Xolok Rk. II",
            "Rune of Xolok",
            "Rune of Tonmek",
            "Rune of Novak",
            "Rune of Yozan",
            "Rune of Erradien",
            "Rune of Ellowind",
            "Rune of Salik",
            "Rune of Zebuxoruk",
            "Rune V",
            "Rune IV",
            "Rune III",
            "Rune II",
            "Rune I",
        },
        ['GroupRune'] = {
            "Umbral Rune Rk. III",
            "Umbral Rune Rk. II",
            "Umbral Rune",
            "Shadowed Rune",
            "Twilight Rune",
            "Rune of the Void",
            "Rune of the Deep",
            "Rune of the Kedge",
            "Rune of Rikkukin",
            "Rune of the Scale",
        },
        ['AggroRune'] = {
            "Terrifying Rune Rk. III",
            "Terrifying Rune Rk. II",
            "Terrifying Rune",
            "Horrifying Rune",
        },
        ['AggroBuff'] = {
            "Horrifying Rune",
            "Horrifying Rune Rk. II",
            "Horrifying Rune Rk. III",
            "Horrifying Rune Effect",
            "Horrifying Rune Effect II",
            "Horrifying Rune Effect III",
            "Horrifying Visage",
            "Haunting Visage",
        },
        ['SingleSpellShield'] = {
            "Aegis of Xorbb Rk. III",
            "Aegis of Xorbb Rk. II",
            "Aegis of Xorbb",
            "Aegis of Soliadal",
            "Aegis of Zykean",
            "Aegis of Xadrith",
            "Aegis of Qandieal",
            "Aegis of Alendar",
            "Wall of Alendar",
            "Bulwark of Alendar",
            "Protection of Alendar",
            "Guard of Alendar",
            "Ward of Alendar",
        },
        ['GroupSpellShield'] = {
            "Legion of Xolok Rk. III",
            "Legion of Xolok Rk. II",
            "Legion of Xolok",
            "Legion of Tonmek",
            "Legion of Zykean",
            "Legion of Xadrith",
            "Legion of Qandieal",
            "Legion of Alendar",
            "Circle of Alendar",
        },
        ['SingleDotShield'] = {
            "Aegis of the Keeper Rk. III",
            "Aegis of the Keeper Rk. II",
            "Aegis of the Keeper",
        },
        ['GroupDotShield'] = {
            "Legion of the Keeper Rk. III",
            "Legion of the Keeper Rk. II",
            "Legion of the Keeper",
        },
        ['SingleMeleeShield'] = {
            "Umbral Auspice Rk. III",
            "Umbral Auspice Rk. II",
            "Umbral Auspice",
        },
        ['SelfGuardShield'] = {
            "Shield of Fate Rk. III",
            "Shield of Fate Rk. II",
            "Shield of Fate",
        },
        ['GroupAuspiceBuff'] = {
        },
        ['SpellProcBuff'] = {
            "Mana Reverberation Rk. III",
            "Mana Reverberation Rk. II",
            "Mana Reverberation",
            "Mana Repercussion",
            "Mana Reiteration",
            "Mana Reiterate",
            "Mana Resurgence",
            "Mana Recursion",
            "Mana Flare",
        },
        ['AllianceSpell'] = {
        },
        ['TwinCastMez'] = {
            "Chaotic Confounding Rk. III",
            "Chaotic Confounding Rk. II",
            "Chaotic Confounding",
            "Chaotic Confusion",
            "Chaotic Baffling",
            "Chaotic Befuddling",
        },
        ['PBAEStunSpell'] = {
            "Color Confluence Rk. III",
            "Color Confluence Rk. II",
            "Color Confluence",
            "Color Convergence",
            "Color Clash",
            "Color Conflux",
            "Color Cataclysm",
            "Color Collapse",
            "Color Snap",
            "Color Cloud",
            "Color Slant",
            "Color Skew",
            "Color Shift",
            "Color Flux",
        },
        ['TargetAEStun'] = {
            "Remote Color Confluence Rk. III",
            "Remote Color Confluence Rk. II",
            "Remote Color Confluence",
            "Remote Color Convergence",
        },
        ['SingleStunSpell1'] = {
            "Dizzying Squall Rk. III",
            "Dizzying Squall Rk. II",
            "Dizzying Squall",
            "Dizzying Gyre",
            "Dizzying Helix",
            "The Downward Spiral",
            "Whirling into the Hollow",
            "Spinning into the Void",
            "Whirl till you hurl",
        },
        ['CharmSpell'] = {
            "Temptation Rk. III",
            "Temptation Rk. II",
            "Temptation",
            "Compelling Edict",
            "Deception",
            "Dominate",
            "Seduction",
            "Haunting Whispers",
            "Cajole",
            "Coax",
            "True Name",
            "Compel",
            "Command of Druzzil",
            "Beckon",
            "Allure",
            "Cajoling Whispers",
            "Beguile",
            "Charm",
        },
        ['CharmCommand'] = {        -- chance to stun on break, later spells carry a pet buff
            "Impose Rk. III",
            "Impose Rk. II",
            "Impose",
            "Enforce",
            "Subjugate",
        },
        ['CharmDemand'] = {         -- chance to memblur on break, later spells carry a pet buff
        },
        ['CrippleSpell'] = {
            "Splintered Consciousness Rk. III",
            "Splintered Consciousness Rk. II",
            "Splintered Consciousness",
            "Fragmented Consciousness",
            "Shattered Consciousness",
            "Fractured Consciousness",
            "Synapsis Spasm",
            "Cripple",
            "Incapacitate",
            "Listless Power",
            "Disempower",
            "Enfeeblement",
        },
        ['SlowSpell'] = {
            "Desolate Undead",
            "Desolate Summoned",
            "Desolate Deeds",
            "Dreary Deeds",
            "Forlorn Deeds",
            "Shiftless Deeds",
            "Tepid Deeds",
            "Languid Pace",
        },
        ['Dispel'] = {
            "Recant Magic",
            "Pillage Enchantment",
            "Nullify Magic",
            "Strip Enchantment",
            "Cancel Magic",
            "Taper Enchantment",
        },
        ['TashSpell'] = {
            "Enunciation of Tashan Rk. III",
            "Enunciation of Tashan Rk. II",
            "Enunciation of Tashan",
            "Declaration of Tashan",
            "Clamor of Tashan",
            "Bark of Tashan",
            "Din of Tashan",
            "Echo of Tashan",
            "Howl of Tashan",
            "Tashanian",
            "Tashania",
            "Tashani",
            "Tashina",
        },
        ['ManaDrainNuke'] = {
            "Tears of Syrkl Rk. III",
            "Tears of Syrkl Rk. II",
            "Tears of Syrkl",
            "Tears of Wreliard",
            "Tears of Zykean",
            "Tears of Xadrith",
            "Tears of Qandieal",
            "Torment of Scio",
            "Torment of Argli",
            "Wandering Mind",
            "Mana Sieve",
        },
        ['DichoSpell'] = {
        },
        ['StrangleDot'] = {
            "Stifle Rk. III",
            "Stifle Rk. II",
            "Stifle",
            "Suffocation",
            "Constrict",
            "Smother",
            "Strangling Air",
            "Thin Air",
            "Arcane Noose",
            "Strangle",
            "Asphyxiate",
            "Gasping Embrace",
            "Suffocate",
            "Choke",
            "Suffocating Sphere",
            "Shallow Breath",
        },
        ['MindDot'] = {
            "Mind Squall Rk. III",
            "Mind Squall Rk. II",
            "Mind Squall",
            "Mind Spiral",
            "Mind Helix",
            "Mind Twist",
            "Mind Oscillate",
            "Mind Phobiate",
            "Mind Shatter",
        },
        ['ConstrictionDot'] = {
            "Confounding Constriction Rk. III",
            "Confounding Constriction Rk. II",
            "Confounding Constriction",
            "Confusing Constriction",
            "Baffling Constriction",
        },
        ['MagicNuke'] = {
            "Mindcleave Rk. III",
            "Mindcleave Rk. II",
            "Mindcleave",
            "Mindscythe",
            "Mindblade",
            "Spectral Assault",
            "Chromarcana",
            "Polychaotic Assault",
            "Multichromatic Assault",
            "Polychromatic Assault",
            "Ancient: Neurosis",
            "Colored Chaos",
            "Psychosis",
            "Madness of Ikkibi",
            "Ancient: Chaos Madness",
            "Insanity",
            "Ancient: Chaotic Visions",
            "Dementing Visions",
            "Dementia",
            "Discordant Mind",
            "Anarchy",
            "Chaos Flux",
            "Sanity Warp",
            "Chaotic Feedback",
        },
        ['RuneNuke'] = {
            "Chromatic Percussion Rk. III",
            "Chromatic Percussion Rk. II",
            "Chromatic Percussion",
            "Chromatic Flash",
            "Chromatic Jab",
        },
        ['ManaTapNuke'] = {
            "Mental Appropriation Rk. III",
            "Mental Appropriation Rk. II",
            "Mental Appropriation",
        },
        --Unused table, temporarily removed - was causing conflicts while resolving MagicNuke action maps (will revisit nukes later)
        -- ['ChromaNuke'] = {
        --- Chromatic Lowest Nuke - Normal -- >=LVL73
        --     "Polycascading Assault",   -- Level 113
        --     "Polyfluorescent Assault", -- Level 108
        --     "Polyrefractive Assault",  -- Level 103
        --     "Phantasmal Assault",      -- Level 98
        --     "Arcane Assault",          -- Level 93
        --     "Spectral Assault",        -- Level 88
        --     "Polychaotic Assault",     -- Level 83
        --     "Multichromatic Assault",  -- Level 78
        --     "Polychromatic Assault",   -- Level 73
        -- },
        ['CripSlowSpell'] = {
            "Diminishing Helix Rk. III",
            "Diminishing Helix Rk. II",
            "Diminishing Helix",
            "Attenuating Helix",
            "Curtailing Helix",
        },
        ['PetSpell'] = {
        },
        ['PetBuffSpell'] = {
            "Empowered Minion Rk. III",
            "Empowered Minion Rk. II",
            "Empowered Minion",
        },
        ['MezAESpell'] = {
            "Slackening Wave Rk. III",
            "Slackening Wave Rk. II",
            "Slackening Wave",
            "Peaceful Wave",
            "Serene Wave",
            "Ensorcelling Wave",
            "Quelling Wave",
            "Wake of Subdual",
            "Wake of Felicity",
            "Bliss of the Nihil",
            "Fascination",
            "Mesmerization",
        },
        ['MezAESpellFast'] = {
            "Slackening Glance Rk. III",
            "Slackening Glance Rk. II",
            "Slackening Glance",
        },
        ['MezPBAESpell'] = {
            "Disorientation Rk. III",
            "Disorientation Rk. II",
            "Disorientation",
            "Confusion",
            "Serenity",
            "Docility",
            "Visions of Kirathas",
            "Dreams of Veldyn",
            "Bewilderment",
            "Circle of Dreams",
            "Word of Morell",
            "Entrancing Lights",
        },
        ['MezSpell'] = {
            "Confound Rk. III",
            "Confound Rk. II",
            "Confound",
            "Mislead",
            "Baffle",
            "Befuddle",
            "Mystify",
            "Bewilderment",
            "Euphoria",
            "Felicity",
            "Bliss",
            "Sleep",
            "Apathy",
            "Ancient: Eternal Rapture",
            "Rapture",
            "Glamour of Kintaz",
            "Enthrall",
            "Mesmerize",
        },
        ['MezSpellFast'] = {
            "Confounding Flash Rk. III",
            "Confounding Flash Rk. II",
            "Confounding Flash",
            "Misleading Flash",
            "Baffling Flash",
            "Befuddling Flash",
            "Mystifying Flash",
            "Perplexing Flash",
        },
        ['BlurSpell'] = {
            "Memory Flux",
            "Reoccurring Amnesia",
            "Memory Blur",
        },
        ['AEBlurSpell'] = {
            "Blanket of Forgetfulness",
            "Mind Wipe",
        },
        ['CalmSpell'] = {
            "Quiescent Mind Rk. III",
            "Quiescent Mind Rk. II",
            "Quiescent Mind",
            "Halcyon Mind",
            "Bucolic Mind",
            "Hushed Mind",
            "Silent Mind",
            "Quiet Mind",
            "Placate",
            "Pacification",
            "Pacify",
            "Calm",
            "Soothe",
            "Lull",
        },
        ['FearSpell'] = {
            "Anxiety Attack",
            "Jitterskin",
            "Phobia",
            "Trepidation",
            "Invoke Fear",
            "Chase the Moon",
            "Fear",
        },
        ['RootSpell'] = {
            "Greater Healing",
            "Greater Shielding",
            "Greater Wolf Form",
            "Greater Summoning: Earth",
            "Greater Summoning: Water",
            "Greater Summoning: Fire",
            "Greater Summoning: Air",
            "Greater Conjuration: Earth",
            "Greater Conjuration: Water",
            "Greater Conjuration: Fire",
            "Greater Conjuration: Air",
            "Greater Reviviscence",
            "Greater Vocaration: Earth",
            "Greater Vocaration: Water",
            "Greater Vocaration: Fire",
            "Greater Vocaration: Air",
            "Greater Familiar",
            "Greater Immobilize",
            "Greater Decession",
            "Greater Healing Light",
            "Greater Mass Enchant Electrum",
            "Greater Mass Enchant Gold",
            "Greater Mass Enchant Platinum",
            "Greater Mass Enchant Silver",
            "Greater Mass Enchant Velium",
            "Greater Fetter",
            "Fetter",
            "Paralyzing Earth",
            "Immobilize",
            "Instill",
            "Root",
        },
    },
    ['Mez']           = {
        { type = "Spell", name = "TwinCastMez",     cond = function() return Config:GetSetting('TwincastMez') > 1 end, },
        { type = "Spell", name = "MezSpell",        cond = function() return Config:GetSetting('TwincastMez') == 1 end, },
        { type = "Spell", name = "MezAESpell", },
        { type = "AA",    name = "Beam of Slumber", cond = function() return Config:GetSetting('DoAAMez') end, },
    },
    ['Charm']         = {
        ['Abilities'] = {
            { type = "AA",    name = "Dire Charm", },
            { type = "Spell", name = "CharmSpell", },
            { type = "Spell", name = "CharmDemand", },
            { type = "Spell", name = "CharmCommand", },
        },
        ['PreCharm']  = {
            { name = "TashSpell", type = "Spell", cond = function(self, spell, target) return not target.Tashed() end, },
        },
        ['Assist']    = {
            { name = "PBAEStunSpell", type = "Spell", cond = function(self, spell, target) return Targeting.TargetNotStunned() and Targeting.InSpellRange(spell, target) end, },
            { name = "TashSpell",     type = "Spell", cond = function(self, spell, target) return Casting.DetSpellCheck(spell, target) end, },
        },
    },
    ['RotationOrder'] = {
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        {
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and not Core.IsCharming() and Casting.AmIBuffable()
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
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 10,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'Tash',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoTash') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Core.CombatActionsCheck()
            end,
        },
        { --Slow and Tash separated so we use both before we start DPS
            name = 'CripSlow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Dispel',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoDispel') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        { --AA Stuns, Runes, etc, moved from previous home in DPS
            name = 'CombatSupport',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(Default)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("Default") end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'DPS(ModernEra)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("ModernEra") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
    },
    ['Helpers']       = { --used to autoinventory our azure crystal after summon
        StashCrystal = function()
            mq.delay("2s", function() return mq.TLO.Cursor.ID() == mq.TLO.Me.AltAbility("Azure Mind Crystal").Spell.Base(1)() end)

            if not mq.TLO.Cursor() then
                Logger.log_debug("No valid item found on cursor, item handling aborted.")
                return false
            end

            Logger.log_debug("Sending the %s to our bags.", mq.TLO.Cursor())
            ItemManager.QueueAutoInv(mq.TLO.Cursor.ID())
        end,
        AuraCheck = function() -- remove undesired auras to stop spam conditions... this will only be triggered if we have already identified we are missing a desired aura
            if Casting.CanUseAA("Auroria Mastery") then
                -- If we can use two auras we will keep twincast and get rid of the other (including old versions of the spellproc aura line)
                -- Make sure we don't get rid of the first aura if the second aura is already free for whatever reason (fallback)
                ---@diagnostic disable-next-line: undefined-field
                if (mq.TLO.Me.Aura(1).Name() or "Twincast Aura") ~= "Twincast Aura" and mq.TLO.Me.Aura(2)() then mq.TLO.Me.Aura(1).Remove() end
                ---@diagnostic disable-next-line: undefined-field
                if (mq.TLO.Me.Aura(2).Name() or "Twincast Aura") ~= "Twincast Aura" then mq.TLO.Me.Aura(2).Remove() end
            else --if we can only use one aura, we will get rid of the current one since we are missing the one we want.
                ---@diagnostic disable-next-line: undefined-field
                mq.TLO.Me.Aura(1).Remove()
            end
        end,
    },
    ['Rotations']     = {
        ['Downtime'] = {
            {
                name = "Orator's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) end,
            },
            {
                name = "SelfGuardShield",
                type = "Spell",
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
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "MezBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune2",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "Eldritch Rune",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Veil of Mindshadow",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName) return Casting.SelfBuffAACheck(aaName) end,
            },

            {
                name = "Azure Mind Crystal",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.FindItem(aaName)() ~= nil end,
                cond = function(self, aaName) return mq.TLO.Me.PctMana() > 90 and not mq.TLO.FindItem(aaName)() end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.StashCrystal)
                    end
                end,
            },
            {
                name = "Gather Mana",
                type = "AA",
                cond = function(self, aaName) return mq.TLO.Me.PctMana() < 60 end,
            },
            {
                name = "LearnersAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self) self.Helpers.AuraCheck() end,
                cond = function(self, spell)
                    return Config:GetSetting('DoLearners') and not Casting.AuraActiveByName(spell.Name())
                end,
            },
            {
                name = "TwincastAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.Name()) end,
                pre_activate = function(self) self.Helpers.AuraCheck() end,
                cond = function(self, spell)
                    -- don't use this if we selected learners and don't have two auras
                    if Config:GetSetting('DoLearners') and not Casting.CanUseAA('Auroria Mastery') then return false end
                    return not Casting.AuraActiveByName(spell.Name())
                end,
            },
            {
                name = "SpellProcAura",
                type = "Spell",
                active_cond = function(self, spell)
                    local aura = spell and auraSpellToName[spell.Name()] or "None"
                    return Casting.AuraActiveByName(aura)
                end,
                pre_activate = function(self) self.Helpers.AuraCheck() end,
                cond = function(self, spell)
                    -- don't use this if we have learner's selected, whether one aura or two
                    local useLearnersInstead = Config:GetSetting('DoLearners') and Core.GetResolvedActionMapItem('LearnersAura')
                    -- don't use this if we don't have Twincast Aura up unless we don't have Twincast Aura or can use two auras
                    local useTwinCastInstead = Core.GetResolvedActionMapItem('TwincastAura') and not Casting.CanUseAA('Auroria Mastery')

                    if not spell or not spell() or useLearnersInstead or useTwinCastInstead then return false end
                    -- get the proper aura name. Don't use rankname, the table doesn't support it. We are only searching the first word of the aura name.
                    local aura = auraSpellToName[spell.Name()]
                    return not Casting.AuraActiveByName(aura)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell) return Casting.ReagentCheck(spell) end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetBuffSpell",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.ID()).ID() end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('PetBuffSpell') end,
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.ID()).ID() end,
                cond = function(self, spell) return Casting.PetBuffCheck(spell) end,
            },

        },
        ['GroupBuff'] = {
            {
                name = "ManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsACaster(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupSpellShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupSpellShield') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "GroupDotShield",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupDotShield') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "GroupAuspiceBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupAuspice') then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "NdtBuff",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    --Single target versions of the spell will only be used on Melee, group versions will be cast if they are missing from any groupmember
                    if not Config:GetSetting('DoNDTBuff') or ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target)) then return false end

                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SpellProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoProcBuff') or not Targeting.TargetIsACaster(target) then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 2 or ((spell.Level() or 0) > 73 and Targeting.TargetIsATank(target)) then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "AggroRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoAggroRune') or not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleRune",
                type = "Spell",
                active_cond = function(self, spell) return mq.TLO.Me.FindBuff("id " .. tostring(spell.ID()))() ~= nil end,
                cond = function(self, spell, target)
                    if Config:GetSetting('RuneChoice') ~= 1 then return false end
                    return Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
        },
        ['Dispel'] = {
            {
                name = "Eradicate Magic",
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Target.Beneficial() ~= nil
                end,
            },
            {
                name = "Dispel",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Eradicate Magic") then return false end
                    return mq.TLO.Target.Beneficial() ~= nil
                end,
            },
        },
        ['CombatSupport'] = {
            {
                name = "Glyph Spray",
                type = "AA",
                cond = function(self, aaName, target)
                    return ((Globals.AutoTargetIsNamed and target.Level() > mq.TLO.Me.Level()) or Core.GetMainAssistPctHPs() <= Config:GetSetting('EmergencyStart'))
                end,
            },
            {
                name = "Reactive Rune",
                type = "AA",
                cond = function(self, aaName, target)
                    return ((Globals.AutoTargetIsNamed and target.Level() > mq.TLO.Me.Level()) or Core.GetMainAssistPctHPs() <= Config:GetSetting('EmergencyStart'))
                end,
            },
            {
                name = "PBAEStunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if (Config:GetSetting('DoAEStun') == 2 and Core.GetMainAssistPctHPs() > Config:GetSetting('EmergencyStart')) or Config:GetSetting('DoAEStun') == 1 then return false end
                    return Casting.DetSpellCheck(spell) and Targeting.GetXTHaterCount() >= Config:GetSetting('AECount')
                end,
            },

            {
                name = "Self Stasis",
                type = "AA",
                cond = function(self, aaName)
                    if Config:GetSetting('CharmOn') and mq.TLO.Me.Pet.ID() > 0 then return false end
                    return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Globals.AutoTargetID
                end,
                post_activate = function(self, aaName, success)
                    if not success then return end
                    mq.delay(1000, function() return mq.TLO.Me.Buff("Self Stasis")() ~= nil end)
                    if mq.TLO.Me.Buff("Self Stasis")() then
                        Comms.PrintGroupMessage("We're out of combat, removing the Self Stasis buff so we can act again.")
                        Core.DoCmd('/removebuff =Self Stasis')
                    end
                end,
            },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Instability",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 30
            --     end,
            -- },
            {
                name = "Beguiler's Directed Banishment",
                type = "AA",
                cond = function(self, aaName, target)
                    if target.ID() == Globals.AutoTargetID then return false end
                    return mq.TLO.Me.PctAggro() > 99 and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,

            },
            {
                name = "Beguiler's Banishment",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and mq.TLO.SpawnCount("npc radius 20")() > 2
                end,

            },
            {
                name = "Doppelganger",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100) and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            -- { --This can interrupt spellcasting which can just make something worse. Let us trust healers and tanks.
            --     name = "Dimensional Shield",
            --     type = "AA",
            --     cond = function(self, aaName)
            --         return mq.TLO.Me.TargetOfTarget.ID() == mq.TLO.Me.ID() and mq.TLO.Target.ID() == Globals.AutoTargetID and mq.TLO.Me.PctHPs() <= 80            --     end,

            -- },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() >= 90
                end,

            },
            {
                name = "Silent Casting",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() >= 60
                end,

            },
        },
        ['DPS(Default)'] = {
            {
                name = "TwinCastMez",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('TwincastMez') ~= 3 or Modules:ExecModule("Mez", "IsMezImmune", target.ID()) then return false end
                    return not Casting.IHaveBuff(spell) and not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            {
                name = "MindDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoMindDot') then return false end
                    return Casting.DotSpellCheck(spell) and (Globals.AutoTargetIsNamed or not Casting.IHaveBuff(spell and spell.Trigger()))
                end,
            },
            {
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoStrangleDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoNuke') then return false end
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "ManaDrainNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoManaDrain') then return false end
                    return (target.CurrentMana() or 0) > 10 and Casting.OkayToNuke()
                end,
            },
        },
        ['DPS(ModernEra)'] = {
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Casting.OkayToNuke()
                end,
            },
            {
                name = "MindDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            { --Mana check used instead of dot mana check because this is spammed like a nuke
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            { --this is not an error, we want the spell twice in a row as part of the rotation.
                name = "StrangleDot",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "TwinCastMez",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('TwincastMez') ~= 3 or Modules:ExecModule("Mez", "IsMezImmune", target.ID()) then return false end
                    return not Casting.IHaveBuff(spell) and not mq.TLO.Me.Buff("Improved Twincast")()
                end,
            },
            { --used when the chanter or group members are low mana
                name = "ManaTapNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return (mq.TLO.Group.LowMana(80)() or -1) > 1 or not Casting.HaveManaToNuke()
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Illusions of Grandeur",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
            {
                name = "Calculated Insanity",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
            },
            {
                name = "Mental Contortion",
                type = "AA",
                cond = function(self, aaName, target) return Globals.AutoTargetIsNamed end,
            },
            {
                name = "Chromatic Haze",
                type = "AA",
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
                name = "Spire of Enchantment",
                type = "AA",
                cond = function(self, aaName) return not Casting.IHaveBuff("Illusions of Grandeur") end,
            },
            {
                name = "Phantasmal Opponent",
                type = "AA",
            },
        },
        ['Tash'] = {
            {
                name = "Bite of Tashani",
                type = "AA",
                cond = function(self, aaName)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AECount') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "TashSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and (not Casting.TargetHasBuff("Bite of Tashani") or Globals.AutoTargetIsNamed)
                end,
            },
        },
        ['CripSlow'] = {
            {
                name = "Enveloping Helix",
                type = "AA",
                cond = function(self, aaName, target)
                    if Targeting.GetXTHaterCount() < Config:GetSetting('AECount') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Slowing Helix",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoSlow') then return false end
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and (aaSpell.SlowPct() or 0) > (Targeting.GetTargetSlowedPct()) and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "CripSlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSlow') or not Casting.CanUseAA("Slowing Helix") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSlow') or Casting.CanUseAA("Slowing Helix") or Core.GetResolvedActionMapItem('CripSlowSpell') then return false end
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct()) and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "CrippleSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoCripple') or Casting.CanUseAA("Slowing Helix") or Core.GetResolvedActionMapItem('CripSlowSpell') then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
    },
    ['SpellList']     = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                { name = "TwinCastMez",      cond = function(self) return Config:GetSetting('DoSTMez') and Config:GetSetting('TwincastMez') > 1 end, },
                { name = "MezSpell",         cond = function(self) return Config:GetSetting('DoSTMez') and Config:GetSetting('TwincastMez') == 1 end, },
                { name = "MezAESpell",       cond = function(self) return Config:GetSetting('DoAEMez') end, },
                { name = "CharmDemand",      cond = function(self, spell) return Config:GetSetting('CharmOn') and Core.IsSelectedCharmSpell(spell) end, },
                { name = "CharmCommand",     cond = function(self, spell) return Config:GetSetting('CharmOn') and Core.IsSelectedCharmSpell(spell) end, },
                { name = "CharmSpell",       cond = function(self, spell) return Config:GetSetting('CharmOn') and Core.IsSelectedCharmSpell(spell) end, },
                { name = "PetSpell",         cond = function(self) return not Config:GetSetting('CharmOn') end, },
                { name = "TashSpell",        cond = function(self) return Config:GetSetting('DoTash') end, },
                { name = "CripSlowSpell",    cond = function(self) return (Config:GetSetting('DoSlow') or Config:GetSetting('DoCripple')) and not Casting.CanUseAA("Slowing Helix") end, },
                { name = "SlowSpell",        cond = function(self) return Config:GetSetting('DoSlow') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "CrippleSpell",     cond = function(self) return Config:GetSetting('DoCripple') and not Core.GetResolvedActionMapItem('CripSlowSpell') end, },
                { name = "PBAEStunSpell",    cond = function(self) return Config:GetSetting('DoAEStun') > 1 end, },
                { name = "NdtBuff",          cond = function(self) return Config:GetSetting('DoNDTBuff') end, },
                { name = "SpellProcBuff",    cond = function(self) return Config:GetSetting('DoProcBuff') end, },
                { name = "Dispel",           cond = function(self) return Config:GetSetting('DoDispel') and not Casting.CanUseAA("Eradicate Magic") end, },
                { name = "DichoSpell",       cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "MagicNuke",        cond = function(self) return Config:GetSetting('DoNuke') or Core.IsModeActive("ModernEra") end, },
                { name = "StrangleDot",      cond = function(self) return Config:GetSetting('DoStrangleDot') or Core.IsModeActive("ModernEra") end, },
                { name = "MindDot",          cond = function(self) return Config:GetSetting('DoMindDot') or Core.IsModeActive("ModernEra") end, },
                { name = "ManaTapNuke",      cond = function(self) return Core.IsModeActive("ModernEra") end, },
                { name = "ManaDrainNuke",    cond = function(self) return Config:GetSetting('DoManaDrain') and Core.IsModeActive("Default") end, },
                { name = "SingleRune",       cond = function(self) return Config:GetSetting('RuneChoice') == 1 end, },
                { name = "GroupRune",        cond = function(self) return Config:GetSetting('RuneChoice') == 2 end, },
                { name = "GroupAuspiceBuff", cond = function(self) return Config:GetSetting('DoGroupAuspice') end, },
                { name = "GroupSpellShield", cond = function(self) return Config:GetSetting('DoGroupSpellShield') end, },
                { name = "GroupDotShield",   cond = function(self) return Config:GetSetting('DoGroupDotShield') end, },
                { name = "AllianceSpell",    cond = function(self) return Config:GetSetting('DoAlliance') end, },
            },
        },
    },
    ['PullAbilities'] = {
        {
            id = 'TashSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('TashSpell').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('TashSpell').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('TashSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Dispel',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Dispel').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Dispel').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Dispel')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig'] = {
        ['Mode']               = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this PC. Default: The original RGMercs Config. ModernEra: DPS rotation and spellset aimed at modern live play (~90+)",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What are the different Modes about?",
            Answer = "The Default Mode is the original RGMercs configuration designed for levels 1 - 90.\n" ..
                "ModernEra Mode is a DPS rotation and spellset aimed at modern live play (~90+).\n" ..
                "The ModernEra Mode is designed to be used with the ModernEra DPS rotation and spellset.\n" ..
                "It should function well starting around level 90, but may not fully come into its own for a few levels after.",
        },

        --Buffs
        ['DoLearners']         = {
            DisplayName = "Do Learners",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Set to use the Learner's Aura instead of the Mana Regen Aura.",
            Default = false,
            FAQ = "How do I use my Learner's Aura?",
        },
        ['RuneChoice']         = {
            DisplayName = "Rune Selection:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip = "Select which line of Rune spells you prefer to use.\nPlease note that after level 73, the group rune has a built-in hate reduction when struck.",
            Type = "Combo",
            ComboOptions = { 'Single Target', 'Group', 'Off', },
            Default = 2,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            FAQ = "Why am I putting an aggro-reducing buff on the tank?",
            Answer =
            "You can configure your rune selections to use a single-target hate increasing rune on the tank, while using group (hate reducing) or single target runes on others.",
        },
        ['DoAggroRune']        = {
            DisplayName = "Do Aggro Rune",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 103,
            Tooltip = "Enable casting the Tank Aggro Rune",
            Default = true,
        },
        ['DoGroupSpellShield'] = {
            DisplayName = "Do Group Spellshield",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 104,
            Tooltip = "Enable casting the Group Spell Shield Line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoGroupDotShield']   = {
            DisplayName = "Do Group DoT Shield",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 105,
            Tooltip = "Enable casting the Group DoT Shield Line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoGroupAuspice']     = {
            DisplayName = "Do Group Auspice",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 106,
            Tooltip = "Enable casting the Group Auspice Buff Line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoProcBuff']         = {
            DisplayName = "Do Spellproc Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 107,
            Tooltip = "Enable casting the spell proc (Mana ... ) line.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoNDTBuff']          = {
            DisplayName = "Cast NDT",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 108,
            Tooltip = "Enable casting use Melee Proc Buff (Night's Dark Terror Line).",
            RequiresLoadoutChange = true,
            Default = true,
        },

        --Debuffs
        ['DoTash']             = {
            DisplayName = "Do Tash",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Tooltip = "Cast Tash Spells",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoSlow']             = {
            DisplayName = "Cast Slow",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Tooltip = "Enable casting Slow spells.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoCripple']          = {
            DisplayName = "Cast Cripple",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Misc Debuffs",
            Tooltip = "Enable casting Cripple spells.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoDispel']           = {
            DisplayName = "Do Dispel",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Dispel",
            Tooltip = "Enable removing beneficial enemy effects.",
            RequiresLoadoutChange = true,
            Default = true,
        },

        --Combat
        ['AECount']            = {
            DisplayName = "AE Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Debuff Rules",
            Index = 101,
            Tooltip = "Number of XT Haters before we will use AE Slow, Tash, or Stun.",
            Min = 1,
            Default = 3,
            Max = 15,
        },
        ['DoAEStun']           = {
            DisplayName = "PBAE Stun use:",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Stun",
            Index = 101,
            Tooltip = "When to use your PBAE Stun Line.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'At low MA health', 'Whenever Possible', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['TwincastMez']        = {
            DisplayName = "TwinCast Mez Usage:",
            Group = "Abilities",
            Header = "Mez",
            Category = "Mez General",
            Index = 101,
            Tooltip = "If selected, will replace the standard ST Mez with an option that gives a DD twincast effect.",
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Disabled', 'As ST Mez', 'As Mez and to Trigger Twincast', },
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Can you explain TwinCast Mez usage in more detail?",
            Answer =
                "Disabled: We will use our standard ST Mez in Gem 1.\n" ..
                "As ST Mez: We will use the Twincast Mez as our ST Mez in Gem 1.\n" ..
                "As Mez and to Trigger Twincast: As above and we will also use this spell in combat to trigger the twincast effect.",
        },
        ['EmergencyStart']     = {
            DisplayName = "Emergency Start",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 101,
            Tooltip = "The HP % emergency abilities will be used (Abilities used depend on whose health is low, the ENC or the MA).",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['DoChestClick']       = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your equipped chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },

        --DPS Low Level
        ['DoNuke']             = {
            DisplayName = "Magic Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Use your magic nuke in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoManaDrain']        = {
            DisplayName = "Mana Drain Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = "Use your mana drain nuke in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoStrangleDot']      = {
            DisplayName = "Strangle Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = "Use your magic damage (Strangle Line) Dot in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoMindDot']          = {
            DisplayName = "Mind Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 102,
            Tooltip = "Use your mana drain/magic damage (Mind Line) Dot on Named in the Default early/midgame DPS rotation.",
            RequiresLoadoutChange = true,
            Default = true,
        },
    },
    ['ClassFAQ']      = {
        {
            Question = "What is the current status of this class config?",
            Answer = "This class config is a current release aimed at official servers.\n\n" ..
                "  This config should perform well from from start to endgame, but a TLP or emu player may find it to be lacking exact customization for a specific era.\n\n" ..
                "  Additionally, those wishing more fine-tune control for specific encounters or raids should customize this config to their preference. \n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}

return _ClassConfig
