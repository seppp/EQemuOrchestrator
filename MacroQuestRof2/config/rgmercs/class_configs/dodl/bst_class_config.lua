local mq        = require('mq')
local Casting   = require("utils.casting")
local Combat    = require('utils.combat')
local Config    = require('utils.config')
local Core      = require("utils.core")
local Globals   = require("utils.globals")
local Targeting = require("utils.targeting")

return {
    _version              = "DODL CUSTOM",
    _author               = "eldudero",
    ['Modes']             = {
        'DPS',
    },
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return Config:GetSetting('DoCures') end,
    },
    ['Cure']              = {
        ['DetDispel'] = {
            { type = "AA", name = "Nature's Salve", selfOnly = true, },
        },
    },
    ['PetPosition']       = {
        SummonAA   = function() return Casting.CanUseAA("Summon Companion") and "Summon Companion" end,
        RelocateAA = function()
            local cdAA = mq.TLO.Me.AltAbility("Companion's Discipline")
            return (cdAA and cdAA.Rank() or 0) >= 4 and "Companion's Discipline"
        end,
    },
    ['Themes']            = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.50, g = 0.28, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.50, g = 0.28, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.20, g = 0.11, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.50, g = 0.28, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.50, g = 0.28, b = 0.03, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.20, g = 0.11, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.50, g = 0.28, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.50, g = 0.28, b = 0.03, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.50, g = 0.28, b = 0.03, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.33, g = 0.18, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.50, g = 0.28, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.50, g = 0.28, b = 0.03, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.50, g = 0.28, b = 0.03, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.20, g = 0.11, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.90, g = 0.45, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.90, g = 0.45, b = 0.05, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.50, g = 0.28, b = 0.03, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {                  --TODO: Add Omens Chest
        ['Epic'] = {
            "Spiritcaller Totem of the Feral",
        },
        ['OoW_Chest'] = {
            "Savagesoul Jerkin of the Wilds",
        },
        ['Coating'] = {
        },
    },
    ['AbilitySets']       = {       --TODO/Under Consideration: Add AoE Roar line, add rotation entry (tie it to Do AoE setting), swap in instead of lance 2, especially since the last lance2 is level 112
        ['SwarmPet'] = {
            "Kesar's Call III",
            "Kesar's Call II",
            "Kesar's Call",
            "Yell at the Moon Rk. III",
            "Yell at the Moon Rk. II",
            "Yell at the Moon",
            "Scream at the Moon",
            "Shout at the Moon",
            "Yowl at the Moon",
            "Howl at the Moon",
            "Bark at the Moon",
            "Bestial Empathy",
        },
        ['Feralgia'] = {
        },
        ['FrozenPoi'] = {
            "Frozen Carbomate Rk. III",
            "Frozen Carbomate Rk. II",
            "Frozen Carbomate",
            "Frozen Cyanin",
            "Frozen Venin",
            "Frozen Venom",
        },
        ['Maelstrom'] = {
        },
        ['PoiBite'] = {
            "Bite of the Vitrik Rk. III",
            "Bite of the Vitrik Rk. II",
            "Bite of the Vitrik",
            "Bite of the Borrower",
            "Bite of the Empress",
        },
        ['Icelance1'] = {
            "Kromrif Lance Rk. III",
            "Kromrif Lance Rk. II",
            "Kromrif Lance",
            "Glacial Lance",
            "Jagged Torrent",
            "Ancient: Savage Ice",
            "Ancient: Frozen Chaos",
            "Frost Spear",
            "Blizzard Blast",
            "Frost Shard",
            "Blast of Frost",
        },
        ['Icelance2'] = {
            "Frostrift Lance Rk. III",
            "Frostrift Lance Rk. II",
            "Frostrift Lance",
            "Frigid Lance",
            "Spiked Sleet",
            "Glacier Spear",
            "Ice Shard",
            "Ice Spear",
        },
        ['AERoar'] = {
            "Kromrif Roar Rk. III",
            "Kromrif Roar Rk. II",
            "Kromrif Roar",
            "Frostrift Roar",
            "Glacial Roar",
        },
        ['EndemicDot'] = {
            "Shiverback Endemic Rk. III",
            "Shiverback Endemic Rk. II",
            "Shiverback Endemic",
            "Tsetsian Endemic",
            "Fever Surge",
            "Fever Spike",
            "Festering Malady",
            "Plague",
            "Malaria",
            "Sicken",
        },
        ['BloodDot'] = {
            "Asp Blood Rk. III",
            "Asp Blood Rk. II",
            "Asp Blood",
            "Binaesa Blood",
            "Spinechiller Blood",
            "Ikaav Blood",
            "Chimera Blood",
            "Turepta Blood",
            "Scorpion Venom",
            "Venom of the Snake",
            "Envenomed Breath",
            "Tainted Breath",
        },
        ['ColdDot'] = {
        },
        ['SlowSpell'] = {
            "Drowsy",
        },
        ['DichoSpell'] = {
        },
        ['HealSpell'] = {
            "Mending of the Izon Rk. III",
            "Mending of the Izon Rk. II",
            "Mending of the Izon",
            "Minohten Mending",
            "Chloroblast",
            "Spirit Salve",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
            "Salve",
        },
        ['PetHealSpell'] = {
            "Salve of Blezon Rk. III",
            "Salve of Blezon Rk. II",
            "Salve of Blezon",
            "Salve of Yubai",
            "Salve of Sevna",
            "Salve of Reshan",
            "Salve of Feldan",
            "Healing of Uluanes",
            "Healing of Mikkily",
            "Healing of Sorsha",
            "Aid of Khurenz",
            "Vigor of Zehkes",
        },
        ['PetSpell'] = {
            "Spirit Sight",
            "Spirit of Monkey",
            "Spirit Strength",
            "Spirit of Cat",
            "Spirit of Ox",
            "Spirit of Cheetah",
            "Spirit Pouch",
            "Spirit of Wolf",
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
            "Spirit of Eagle",
            "Spirit of Bih`Li",
            "Spiritual Purity",
            "Spiritual Strength",
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
            "Spirit of Rellic",
            "Spiritual Dominion",
            "Spirit of Ash",
            "Spirit of the Shrew",
            "Spirit of Rage Discipline",
            "Spirit of Sense",
            "Spirit of Perseverance",
            "Spirit of Fortitude",
            "Spirit Veil",
            "Spirit of Might",
            "Spiritual Serenity",
            "Spiritual Vitality",
            "Spirit of Irionu",
            "Spiritual Ascendance",
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
            "Spiritual Vivacity",
            "Spiritual Vivacity Rk. II",
            "Spiritual Vivacity Rk. III",
            "Spirit of Jeswin",
            "Spirit of Jeswin Rk. II",
            "Spirit of Jeswin Rk. III",
            "Spiritual Epiphany",
            "Spiritual Epiphany Rk. II",
            "Spiritual Epiphany Rk. III",
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
            "Spirit of Lachemit",
            "Spirit of Kolos",
            "Spirit of Averc",
            "Spirit of Hoshkar",
            "Spirit of Silverwing",
            "Spirit of Uluanes",
            "Spirit of Rashara",
            "Spirit of Alladnu",
            "Spirit of Sorsha",
            "Spirit of Arag",
            "Spirit of Khati Sha",
            "Spirit of Khurenz",
            "Spirit of Zehkes",
            "Spirit of Omakin",
            "Spirit of Kashek",
            "Spirit of Yekan",
            "Spirit of Herikol",
            "Spirit of Keshuval",
            "Spirit of Khaliz",
            "Spirit of Sharik",
        },
        ['PetGroupEndRegenProc'] = {
            "Fatiguing Bite Rk. III",
            "Fatiguing Bite Rk. II",
            "Fatiguing Bite",
        },
        ['PetSpellGuard'] = {
        },
        ['PetSlowProc'] = {
            "Deadlock Jaws Rk. III",
            "Deadlock Jaws Rk. II",
            "Deadlock Jaws",
            "Fellgrip Jaws",
            "Lockfang Jaws",
            "Steeltrap Jaws",
        },
        ['PetOffenseBuff'] = {
        },
        ['PetDefenseBuff'] = {
        },
        ['PetHaste'] = {
            "Extraordinary Velocity Rk. III",
            "Extraordinary Velocity Rk. II",
            "Extraordinary Velocity",
            "Exceptional Velocity",
            "Incomparable Velocity",
            "Unrivaled Rapidity",
            "Peerless Penchant",
            "Unparalleled Voracity",
            "Growl of the Beast",
            "Bond of The Wild",
        },
        ['PetGrowl'] = {
            "Growl of the Snow Leopard III",
            "Growl of the Snow Leopard II",
            "Growl of the Snow Leopard Rk. III",
            "Growl of the Snow Leopard Rk. II",
            "Growl of the Snow Leopard",
            "Growl of the Lion",
            "Growl of the Tiger",
            "Growl of the Jaguar",
            "Growl of the Puma",
            "Growl of the Panther",
            "Growl of the Leopard",
        },
        ['PetHealProc'] = {
            "Invigorating Warder Rk. III",
            "Invigorating Warder Rk. II",
            "Invigorating Warder",
            "Empowering Warder",
            "Bolstering Warder",
            "Friendly Pet",
        },
        ['PetDamageProc'] = {
            "Spirit of Nak Rk. III",
            "Spirit of Nak Rk. II",
            "Spirit of Nak",
            "Spirit of Bale",
            "Spirit of Kron",
            "Spirit of Vaxztn",
            "Spirit of Jeswin",
            "Spirit of Lairn",
            "Spirit of Oroshar",
            "Spirit of Irionu",
            "Spirit of Rellic",
            "Spirit of Flame",
            "Spirit of Snow",
            "Spirit of the Storm",
            "Spirit of Wind",
            "Spirit of Vermin",
            "Spirit of the Scorpion",
            "Spirit of Inferno",
            "Spirit of the Blizzard",
            "Spirit of Lightning",
        },
        ['UnityBuff'] = {
            "Spiritual Unity Rk. III",
            "Spiritual Unity Rk. II",
            "Spiritual Unity",
        },
        ['KillShotBuff'] = {
            "Natural Cooperation Rk. III",
            "Natural Cooperation Rk. II",
            "Natural Cooperation",
            "Natural Cooperation",
            "Natural Collaboration",
        },
        ['RunSpeedBuff'] = {
            "Spirit Sight",
            "Spirit of Monkey",
            "Spirit Strength",
            "Spirit of Cat",
            "Spirit of Ox",
            "Spirit of Cheetah",
            "Spirit Pouch",
            "Spirit of Wolf",
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
            "Spirit of Eagle",
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
            "Spirit of the Shrew",
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
            "Spirit of wolf",
        },
        ['ManaRegenBuff'] = {
            "Spiritual Evolution Rk. III",
            "Spiritual Evolution Rk. II",
            "Spiritual Evolution",
            "Spiritual Enrichment",
            "Spiritual Enhancement",
            "Spiritual Enhancement",
            "Spiritual Edification",
            "Spiritual Epiphany",
            "Spiritual Enlightenment",
            "Spiritual Ascendance",
            "Spiritual Dominion",
            "Spiritual Purity",
            "Spiritual Radiance",
            "Spiritual Light",
        },
        ['AllianceDot'] = {
        },
        ['PetBlockSpell'] = {
            "Aegis of Nefori Rk. III",
            "Aegis of Nefori Rk. II",
            "Aegis of Nefori",
            "Beastwood Rampart",
            "Spectral Rampart",
            "Dragonscale Guard",
            "Mammoth-Hide Guard",
            "Feral Guard",
            "Protection of Calliav",
            "Guard of Calliav",
            "Ward of Calliav",
        },
        ['PetBlockAuspice'] = {
            "Auspice of Shadows Rk. III",
            "Auspice of Shadows Rk. II",
            "Auspice of Shadows",
        },
        ['PetHotSpell'] = {
        },
        ['PetPromisedSpell'] = {
            "Promised Amelioration Rk. III",
            "Promised Amelioration Rk. II",
            "Promised Amelioration",
            "Promised Amendment",
            "Promised Wardmending",
            "Promised Rejuvenation",
            "Promised Recovery",
            "Promised Mending",
        },
        ['AvatarSpell'] = {
            "Infusion",
            "Infusion of the Faithful",
            "Infusion of the Faithful Rk. II",
            "Infusion of the Faithful Rk. III",
            "Infusion of the Graceful",
            "Infusion of the Graceful Rk. II",
            "Infusion of the Graceful Rk. III",
            "Infusion of Spirit",
        },
        ['PetCrippleBite'] = {
        },
        ['FocusSpell'] = {
            "Focus of Sanera Rk. III",
            "Focus of Sanera Rk. II",
            "Focus of Sanera",
            "Focus of Klar",
            "Focus of Emiq",
            "Focus of Yemall",
            "Focus of Zott",
            "Focus of Amilan",
            "Focus of Alladnu",
            "Talisman of Kragg",
            "Talisman of Altuna",
            "Talisman of Tnarg",
            "Inner Fire",
        },
        ['AtkHPBuff'] = {
            "Spiritual Vindication Rk. III",
            "Spiritual Vindication Rk. II",
            "Spiritual Vindication",
            "Spiritual Valiance",
            "Spiritual Valor",
            "Spiritual Verve",
            "Spiritual Vivacity",
            "Spiritual Vim",
            "Spiritual Vitality",
            "Spiritual Vigor",
            "Spiritual Vigor",
            "Spiritual Strength",
            "Spiritual Brawn",
        },
        ['AtkBuff'] = {
            "Shared Merciless Ferocity Rk. III",
            "Shared Merciless Ferocity Rk. II",
            "Shared Merciless Ferocity",
            "Shared Brutal Ferocity",
            "Brutal Ferocity",
            "Callous Ferocity",
            "Savage Ferocity",
            "Vicious Ferocity",
            "Ruthless Ferocity",
            "Ferocity of Irionu",
            "Ferocity",
            "Savagery",
        },
        ['EndRegenDisc'] = {
            "Rest Rk. III",
            "Rest Rk. II",
            "Rest",
            "Reprieve",
            "Respite",
        },
        ['Maul'] = {
            "Pummel Rk. III",
            "Pummel Rk. II",
            "Pummel",
            "Barrage",
            "Rush",
            "Foray",
            "Harrow",
            "Rake",
        },
        ['SingleClaws'] = {
            "Focused Clamor of Claws Rk. III",
            "Focused Clamor of Claws Rk. II",
            "Focused Clamor of Claws",
        },
        ['BestialBuffDisc'] = {
            "Bestial Evulsing Rk. III",
            "Bestial Evulsing Rk. II",
            "Bestial Evulsing",
            "Bestial Rending",
            "Bestial Vivisection",
        },
        ['AEClaws'] = {
            "Clamor of Claws Rk. III",
            "Clamor of Claws Rk. II",
            "Clamor of Claws",
            "Tumult of Claws",
            "Flurry of Claws",
        },
        ['FuryDisc'] = {
        },
        ['DmgModDisc'] = {
            "Savage Rage Rk. III",
            "Savage Rage Rk. II",
            "Savage Rage",
            "Savage Fury",
            "Empathic Fury",
            "Bestial Fury Discipline",
        },
        ['EndRegenProcDisc'] = {
            "Reflexive Rending Rk. III",
            "Reflexive Rending Rk. II",
            "Reflexive Rending",
        },
        ['VinDisc'] = {
        },
    },
    ['HealRotationOrder'] = {
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoHeals') end,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['MainHealPoint'] = {
            {
                name = "HealSpell",
                type = "Spell",
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
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
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and Casting.AmIBuffable()
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
            name = 'FocusedParagon',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoParagon') and Casting.CanUseAA("Focused Paragon of Spirits") end,
            targetId = function(self) return { Combat.FindWorstHurtMana(Config:GetSetting('FParaPct')), } end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Config:GetSetting('DowntimeFP') and Casting.OkayToBuff()
                local combat = combat_state == "Combat"
                return (downtime or combat) and not Casting.IHaveBuff(mq.TLO.Me.AltAbility('Paragon of Spirit').Spell) and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSlow') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
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
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
    },
    ['Helpers']           = {
        FlurryActive = function(self)
            local fury = self.ResolvedActionMap['FuryDisc']
            local dicho = self.ResolvedActionMap['DichoSpell']
            return (dicho and dicho() and Casting.IHaveBuff(dicho.Name()))
                or (fury and fury() and Casting.IHaveBuff(fury.Name()))
        end,
        DmgModActive = function(self) --Song active by name will check both Bestial Alignments (Self and Group)
            local disc = self.ResolvedActionMap['DmgModDisc']
            return Casting.IHaveBuff("Bestial Alignment") or (disc and disc() and Casting.IHaveBuff(disc.Name()))
                or Casting.IHaveBuff("Ferociousness")
        end,
    },
    ['Rotations']         = {
        ['Burn'] = {
            {
                name = "Group Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return not self.Helpers.DmgModActive(self)
                end,
            },
            {
                name = "Attack of the Warder",
                type = "AA",
            },
            {
                name = "Frenzy of Spirit",
                type = "AA",
            },
            {
                name = "Bloodlust",
                type = "AA",
            },
            {
                name = "VinDisc",
                type = "Disc",
            },
            {
                name = "Spire of the Savage Lord",
                type = "AA",
            },
            {
                name = "Companion's Fury",
                type = "AA",
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                load_cond = function(self) return Config:GetSetting('DoChestClick') end,
                cond = function(self, itemName, target)
                    if not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Frenzied Swipes",
                type = "AA",
            },
            {
                name = "BloodDot",
                type = "Spell",
                cond = function(self, spell, target)
                    local vinDisc = self.ResolvedActionMap['VinDisc']
                    if not vinDisc then return false end
                    return Casting.IHaveBuff(vinDisc)
                end,
            },
            {
                name = "FuryDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not self.Helpers.FlurryActive(self)
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                load_cond = function(self) return Core.GetResolvedActionMapItem('DichoSpell') end,
                cond = function(self, aaName)
                    local dichoSpell = Core.GetResolvedActionMapItem('DichoSpell')
                    return not self.Helpers.FlurryActive(self) and (mq.TLO.Me.GemTimer(dichoSpell.RankName())() or -1) > 15
                end,
            },
            {
                name = "DmgModDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return not self.Helpers.DmgModActive(self)
                end,
            },
            {
                name = "Ferociousness",
                type = "AA",
                cond = function(self, aaName, target)
                    return not self.Helpers.DmgModActive(self)
                end,
            },
            {
                name = "Bestial Alignment",
                type = "AA",
                cond = function(self, aaName)
                    return not self.Helpers.DmgModActive(self)
                end,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, itemName)
                    return not self.Helpers.DmgModActive(self)
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
        },
        ['Slow'] = {
            {
                name = "Sha's Reprisal",
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Sha's Reprisal") end,
                cond = function(self, aaName, target)
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and (aaSpell.SlowPct() or 0) > (Targeting.GetTargetSlowedPct()) and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Sha's Reprisal") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and (spell.RankName.SlowPct() or 0) > (Targeting.GetTargetSlowedPct()) and not Casting.SlowImmuneTarget(target)
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Falsified Death",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('AggroFeign') then return false end
                    return (mq.TLO.Me.PctHPs() <= 40 and Targeting.IHaveAggro(100)) or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99) and not Core.IsTanking()
                end,
            },
            {
                name = "Armor of Experience",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Warder's Gift",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.Pet.PctHPs() or 0) > 50
                end,
            },
            {
                name = "Protection of the Warder",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Coating",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCoating') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
        ['FocusedParagon'] = {
            {
                name = "Focused Paragon of Spirits",
                type = "AA",
            },
        },
        ['PetHealing'] = {
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
        ['DPS'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
            },
            {
                name = "Paragon of Spirit",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoParagon') end,
                cond = function(self, aaName)
                    return (mq.TLO.Group.LowMana(Config:GetSetting('ParaPct'))() or -1) > 0
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return not self.Helpers.FlurryActive(self)
                end,
            },
            {
                name = "Feralgia",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoFeralgia') end,
                cond = function(self, spell, target)
                    --This checks to see if the Growl portion is up on the pet (or about to expire) before using this, those who prefer the swarm pets can use the actual swarm pet spell in conjunction with this for mana savings.
                    --There are some instances where the Growl isn't needed, but that is a giant TODO and of minor benefit.
                    ---@diagnostic disable-next-line: undefined-field -- total seconds not recognized for buffduration
                    return (mq.TLO.Pet.BuffDuration(spell.RankName.Trigger(2)).TotalSeconds() or 0) < 10
                end,
            },
            {
                name = "BloodDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "ColdDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "EndemicDot",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDot') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "Maelstrom",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "FrozenPoi",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "PoiBite",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Icelance1",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "Icelance2",
                type = "Spell",
                load_cond = function(self) return not Config:GetSetting('DoAERoar') end,
                cond = function(self, spell, target)
                    return Casting.OkayToNuke()
                end,
            },
            {
                name = "AERoar",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoAERoar') end,
                cond = function(self, spell, target)
                    if not Config:GetSetting("DoAEDamage") then return false end
                    return Casting.OkayToNuke() and Combat.AETargetCheck(true)
                end,
            },
            {
                name = "SwarmPet",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSwarmPet') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Round Kick",
                type = "Ability",
                load_cond = function(self) return Casting.CanUseAA("Feral Swipe") end,
            },
            {
                name = "Kick",
                type = "Ability",
                load_cond = function(self) return not Casting.CanUseAA("Feral Swipe") end,
            },
            {
                name = "Tiger Claw",
                type = "Ability",
            },
            {
                name = "Enduring Frenzy",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.GetTargetPctHPs() > 90
                end,
            },
            {
                name = "EndRegenProcDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return mq.TLO.Me.PctEndurance() < Config:GetSetting('ParaPct')
                end,
            },
            {
                name = "Chameleon Strike",
                type = "AA",
            },
            {
                name = "SingleClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return not Config:GetSetting('DoAEDamage')
                end,
            },
            {
                name = "AEClaws",
                type = "Disc",
                cond = function(self, discSpell, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return Combat.AETargetCheck(true)
                end,
            },
            {
                name = "Maul",
                type = "Disc",
            },
            {
                name = "BestialBuffDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() > 90 and mq.TLO.Me.PctMana() < 60)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "RunSpeedBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoRunSpeed') end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoAvatar') end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Make sure this is gemmed due to long refresh, and only use the single target versions on classes that need it.
                    if ((spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target)) or not Casting.CastReady(spell) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "UnityBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    local atkHPBuff = self:GetResolvedActionMapItem('AtkHPBuff')
                    local manaRegenBuff = self:GetResolvedActionMapItem('ManaRegenBuff')
                    local triggerone = atkHPBuff and atkHPBuff.Level() or 999
                    local triggertwo = manaRegenBuff and manaRegenBuff.Level() or 999
                    if (spell.Level() or 0) < (triggerone or triggertwo) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkHPBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "FocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    -- Only use the single target versions on classes that need it
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                cond = function(self, spell)
                    return mq.TLO.Me.Pet.ID() == 0
                end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Consumption of Spirit",
                type = "AA",
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctHPs() > 70 and mq.TLO.Me.PctMana() < 80)
                end,
            },
            {
                name = "Feralist's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "KillShotBuff",
                type = "Spell",
                load_cond = function(self) return not Casting.CanUseAA("Feralist's Unity") end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Pact of The Wurine",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "Epic",
                type = "Item",
                load_cond = function(self) return Config:GetSetting('DoEpic') end,
                cond = function(self, itemName)
                    return not mq.TLO.Me.PetBuff("Savage Wildcaller's Blessing")() and not mq.TLO.Me.PetBuff("Might of the Wild Spirits")()
                end,
            },
            {
                name = "Hobble of Spirits",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('PetProcChoice') == 2 end,
                cond = function(self, aaName, target)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "AvatarSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoAvatar') end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoRunSpeed') end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetOffenseBuff",
                type = "Spell",
                load_cond = function(self) return not Config:GetSetting('DoTankPet') end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetDefenseBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTankPet') end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetSlowProc",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('PetProcChoice') == 1 end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetDamageProc",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHealProc",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetSpellGuard",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSpellGuard') end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetGrowl",
                type = "Spell",
                load_cond = function(self) return not Config:GetSetting('DoFeralgia') end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
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
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "HealSpell",    cond = function(self) return Config:GetSetting('DoHeals') end, },
                { name = "PetHealSpell", cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "Icelance1", },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "PetHealSpell", cond = function(self) return Config:GetSetting('DoPetHealSpell') end, },
                { name = "Icelance1", },
                { name = "AERoar",       cond = function(self) return Config:GetSetting('DoAERoar') end, },
                { name = "Icelance2", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "Icelance1", },
                { name = "AERoar",    cond = function(self) return Config:GetSetting('DoAERoar') end, },
                { name = "Icelance2", },
                { name = "BloodDot", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "AERoar",    cond = function(self) return Config:GetSetting('DoAERoar') end, },
                { name = "Icelance2", },
                { name = "BloodDot", },
                { name = "ColdDot",   cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "BloodDot", },
                { name = "ColdDot",    cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "EndemicDot", cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "AtkBuff", },
                { name = "RunSpeedBuff", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "SlowSpell",  cond = function(self) return Config:GetSetting('DoSlow') and not Casting.CanUseAA("Sha's Reprisal") end, },
                { name = "DichoSpell", },
                { name = "EndemicDot", cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "PetSpell", },
                { name = "Feralgia",   cond = function(self) return Config:GetSetting('DoFeralgia') end, },
                { name = "PetGrowl", },
                { name = "EndemicDot", cond = function(self) return Config:GetSetting('DoDot') end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PoiBite", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Maelstrom", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FrozenPoi", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "ColdDot",     cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "PetHealProc", },

            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealProc", },
                { name = "EndemicDot",  cond = function(self) return Config:GetSetting('DoDot') end, },
                { name = "SwarmPet",    cond = function(self) return Config:GetSetting('DoSwarmPet') end, },
            },
        },
    },
    ['PullAbilities']     = {
        {
            id = 'SlowAA',
            Type = "AA",
            DisplayName = "Sha's Reprisal",
            AbilityName = "Sha's Reprisal",
            AbilityRange = 150,
            cond = function(self)
                return Casting.CanUseAA("Sha's Reprisal")
            end,
        },
        {
            id = 'SlowSpell',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SlowSpell')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SlowSpell')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = { --TODO: Condense pet proc options into a combo box and update entry conditions appropriately
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What is the difference between the modes?",
            Answer = "Beastlords currently only have one Mode.",
        },
        --Other Recovery
        ['DoParagon']      = {
            DisplayName = "Use Paragon",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 101,
            Tooltip = "Use Group or Focused Paragon AAs.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['ParaPct']        = {
            DisplayName = "Paragon %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 102,
            Tooltip = "Minimum mana % before we use Paragon of Spirit.",
            Default = 80,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
        },
        ['FParaPct']       = {
            DisplayName = "F.Paragon %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 103,
            Tooltip = "Minimum mana % before we use Focused Paragon.",
            Default = 90,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
        },
        ['DowntimeFP']     = {
            DisplayName = "Downtime F.Paragon",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 104,
            Tooltip = "Use Focused Paragon outside of Combat.",
            Default = false,
            ConfigType = "Advanced",
        },
        --Pet Buffs
        ['DoTankPet']      = {
            DisplayName = "Do Tank Pet Buffs",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Buffs",
            Index = 101,
            Tooltip = "Use abilities designed for your pet to tank.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['PetProcChoice']  = {
            DisplayName = "Pet Proc Choice:",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Buffs",
            Index = 102,
            Tooltip = "Select your preferred pet proc buff type.",
            Type = "Combo",
            ComboOptions = { 'Slow', 'Snare', },
            Default = 1,
            Min = 1,
            Max = 2,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['DoSpellGuard']   = {
            DisplayName = "Do Spellguard",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Buffs",
            Index = 103,
            Tooltip = "Do Pet Spell Guard. (Warning! Long refresh time.)",
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['DoFeralgia']     = {
            DisplayName = "Do Feralgia",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Buffs",
            Index = 105,
            Tooltip = "Use Feralgia for the Growl Effect on your Pet instead of the Growl Spell.",
            Default = true,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        -- Swarm Pets
        ['DoSwarmPet']     = {
            DisplayName = "Do Swarm Pet",
            Group = "Abilities",
            Header = "Pet",
            Category = "Swarm Pets",
            Index = 101,
            Tooltip = "Use your Swarm Pet spell in addition to Feralgia",
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why am I only using swarm pets every couple of minutes?",
            Answer = "By default, our only source of swarm pet is the Feralgia line. In many situations, using swarm pets outside of this can be a DPS loss.\n" ..
                "For those situations where swarm pet DPS is greatly boosted (BRD SHM and MAG in group comes to mind), you can enable Do Swarm Pet to summon them outside of Feralgia.",
        },
        -- General Healing
        ['DoHeals']        = {
            DisplayName = "Do Heal Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Mem and cast your Mending spell.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DoPetHealSpell'] = {
            DisplayName = "Pet Heal Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 102,
            Tooltip = "Mem and cast your Pet Heal spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        -- Healing Thresholds
        ['PetHealPct']     = {
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

        --Abilities
        ['DoSlow']         = {
            DisplayName = "Do Slow",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 101,
            Tooltip = "Use your slow spell or AA.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DoDot']          = {
            DisplayName = "Cast DOTs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DoRunSpeed']     = {
            DisplayName = "Do Run Speed",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Do Run or Move Speed Spells/AAs",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoAvatar']       = {
            DisplayName = "Do Avatar",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip = "Buff Group/Pet with Infusion of Spirit",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['DoVetAA']        = {
            DisplayName = "Use Vet AA",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Use Veteran AA such as Intensity of the Resolute or Armor of Experience as necessary.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        --Combat
        ['DoAERoar']       = {
            DisplayName = "Use AE Roar",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = "Use your AE Roar (Timer 11) spell line.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['EmergencyStart'] = {
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
        ['AggroFeign']     = {
            DisplayName = "Emergency Feign",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 101,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a mob detected as a 'named' by RGMercs (see Named tab)..",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['DoCoating']      = {
            DisplayName = "Use Coating",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 103,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click your chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['DoEpic']         = {
            DisplayName = "Do Epic",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your Epic Weapon.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['HealPriority']   = {
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
                "  This config should perform well from from start to endgame, but a TLP or emu player may find it to be lacking exact customization for a specific era.\n\n" ..
                "  Additionally, those wishing more fine-tune control for specific encounters or raids should customize this config to their preference. \n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}
