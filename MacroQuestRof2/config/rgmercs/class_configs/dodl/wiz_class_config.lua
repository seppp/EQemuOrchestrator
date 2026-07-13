-- [ README: Customization ] --
-- If you want to make customizations to this file, please put it
-- into your: MacroQuest/configs/rgmercs/class_configs/ directory
-- so it is not patched over.

local mq        = require('mq')
local Casting   = require("utils.casting")
local Combat    = require("utils.combat")
local Config    = require('utils.config')
local Core      = require("utils.core")
local Globals   = require("utils.globals")
local Logger    = require("utils.logger")
local Modules   = require("utils.modules")
local Targeting = require("utils.targeting")

return {
    _version          = "DODL CUSTOM",
    _author           = "eldudero",
    ['Modes']         = {
        'DPS',
        'PBAE(LowLevel)',
    },
    ['OnModeChange']  = function(self, mode)
    end,
    ['Themes']        = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.05, g = 0.30, b = 0.60, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.05, g = 0.30, b = 0.60, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.02, g = 0.12, b = 0.24, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.05, g = 0.30, b = 0.60, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.05, g = 0.30, b = 0.60, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.02, g = 0.12, b = 0.24, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.05, g = 0.30, b = 0.60, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.05, g = 0.30, b = 0.60, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.05, g = 0.30, b = 0.60, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.03, g = 0.19, b = 0.40, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.05, g = 0.30, b = 0.60, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.05, g = 0.30, b = 0.60, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.05, g = 0.30, b = 0.60, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.02, g = 0.12, b = 0.24, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.65, g = 0.92, b = 1.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.65, g = 0.92, b = 1.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.05, g = 0.30, b = 0.60, a = 1.0, }, },
        },
        ['PBAE(LowLevel)'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.58, g = 0.15, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.58, g = 0.15, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.23, g = 0.06, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.58, g = 0.15, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.58, g = 0.15, b = 0.00, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.23, g = 0.06, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.58, g = 0.15, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.58, g = 0.15, b = 0.00, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.58, g = 0.15, b = 0.00, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.38, g = 0.10, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.58, g = 0.15, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.58, g = 0.15, b = 0.00, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.58, g = 0.15, b = 0.00, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.23, g = 0.06, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.00, g = 0.45, b = 0.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.00, g = 0.45, b = 0.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.58, g = 0.15, b = 0.00, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Staff of Phenomenal Power",
            "Staff of Prismatic Power",
        },
    },
    ['AbilitySets']   = {
        ['AllianceSpell'] = {
        },
        -- ['DichoSpell'] = {
        --     "Reciprocal Fire", -- Level 121
        --     "Ecliptic Fire",   -- Level 116
        --     "Composite Fire",  -- Level 111
        --     "Dissident Fire",  -- Level 106
        --     "Dichotomic Fire", -- Level 101
        -- },
        ['IceClaw'] = {
            "Claw of the Icewing Rk. III",
            "Claw of the Icewing Rk. II",
            "Claw of the Icewing",
            "Claw of the Abyss",
            "Glacial Claw",
            "Claw of Selig",
            "Claw of Selay",
            "Claw of Vox",
            "Claw of Frost",
        },
        ['FireClaw'] = {
            "Claw of the Flamewing Rk. III",
            "Claw of the Flamewing Rk. II",
            "Claw of the Flamewing",
            "Villification of Havoc",
            "Denunciation of Havoc",
            "Malediction of Havoc",
        },
        ['MagicClaw'] = {
            "Claw of the Ashwing Rk. III",
            "Claw of the Ashwing Rk. II",
            "Claw of the Ashwing",
        },
        ['CloudburstNuke'] = {
            "Cloudburst Thunderbolt Rk. III",
            "Cloudburst Thunderbolt Rk. II",
            "Cloudburst Thunderbolt",
            "Cloudburst Thunderbolt",
            "Cloudburst Tempest",
            "Cloudburst Storm",
            "Cloudburst Levin",
            "Cloudburst Bolts",
            "Cloudburst Strike",
        },
        ['FuseNuke'] = {
            "Ethereal Weave Rk. III",
            "Ethereal Weave Rk. II",
            "Ethereal Weave",
        },
        ['FireEtherealNuke'] = {
            "Ethereal Incandescence Rk. III",
            "Ethereal Incandescence Rk. II",
            "Ethereal Incandescence",
            "Ethereal Blaze",
            "Ethereal Inferno",
            "Ethereal Combustion",
            "Ethereal Incineration",
            "Ethereal Conflagration",
            "Ether Flame",
        },
        ['IceEtherealNuke'] = {
            "Ethereal Hoarfrost Rk. III",
            "Ethereal Hoarfrost Rk. II",
            "Ethereal Hoarfrost",
            "Ethereal Frost",
            "Ethereal Glaciation",
            "Ethereal Iceblight",
            "Ethereal Rime",
        },
        ['MagicEtherealNuke'] = {
            "Ethereal Salvo Rk. III",
            "Ethereal Salvo Rk. II",
            "Ethereal Salvo",
            "Ethereal Barrage",
        },
        ['ChaosNuke'] = {
            "Chaos Incandescence Rk. III",
            "Chaos Incandescence Rk. II",
            "Chaos Incandescence",
            "Chaos Blaze",
            "Chaos Char",
            "Chaos Combustion",
            "Chaos Conflagration",
            "Chaos Immolation",
            "Chaos Flame",
        },
        ['VortexNuke'] = {
            "Hoarfrost Vortex Rk. III",
            "Hoarfrost Vortex Rk. II",
            "Hoarfrost Vortex",
            "Ether Vortex",
            "Incandescent Vortex",
            "Frost Vortex",
            "Power Vortex",
            "Flame Vortex",
            "Ice Vortex",
            "Mana Vortex",
            "Fire Vortex",
        },
        ['WildNuke'] = {
            "Wildether Barrage Rk. III",
            "Wildether Barrage Rk. II",
            "Wildether Barrage",
            "Wildspark Barrage",
            "Wildmana Barrage",
            "Wildmagic Blast",
            "Wildmagic Burst",
            "Wildmagic Strike",
        },
        ['WildNuke2'] = {
            "Wildether Barrage Rk. III",
            "Wildether Barrage Rk. II",
            "Wildether Barrage",
            "Wildspark Barrage",
            "Wildmana Barrage",
            "Wildmagic Blast",
            "Wildmagic Burst",
            "Wildmagic Strike",
        },
        ['FireNuke'] = {
            "Spark of Thunder",
            "Spark of Lightning",
            "Spark of Ice",
            "Spark of Fire",
            "Draught of Ro",
            "Draught of Fire",
            "Conflagration",
            "Inferno Shock",
            "Flame Shock",
            "Fire Bolt",
            "Shock of Fire",
        },
        ['BigFireNuke'] = {                  -- Level 51-70, Long Cast, Heavy Damage
            "Ancient: Lcea's Lament",
            "Ancient: Lullaby of Shadow",
            "Ancient: High Priest's Bulwark",
            "Ancient: Feral Avatar",
            "Ancient: Scourge of Nife",
            "Ancient: Master of Death",
            "Ancient: Lifebane",
            "Ancient: Destruction of Ice",
            "Ancient: Greater Concussion",
            "Ancient: Shock of Sun",
            "Ancient: Burnout Blaze",
            "Ancient: Eternal Rapture",
            "Ancient: Chaotic Visions",
            "Ancient: Gift of Aegolism",
            "Ancient: Legacy of Blades",
            "Ancient: Starfire of Ro",
            "Ancient: Chaos Chant",
            "Ancient: Frozen Chaos",
            "Ancient: Chaos Censure",
            "Ancient: Chaos Frost",
            "Ancient: Chaos Madness",
            "Ancient: Chaos Vortex",
            "Ancient: Force of Chaos",
            "Ancient: Seduction of Chaos",
            "Ancient: Chaotic Pain",
            "Ancient: Burning Chaos",
            "Ancient: Bite of Chaos",
            "Ancient: Chaos Cry",
            "Ancient: Chaos Strike",
            "Ancient: Phantom Chaos",
            "Ancient: Cry of Chaos",
            "Ancient: Pious Conscience",
            "Ancient: Force of Jeron",
            "Ancient: North Wind",
            "Ancient: Bite of Muram",
            "Ancient: Glacier Frost",
            "Ancient: Call of Power",
            "Ancient: Ancestral Calling",
            "Ancient: Curse of Mori",
            "Ancient: Nova Strike",
            "Ancient: Neurosis",
            "Ancient: Savage Ice",
            "Ancient: Hallowed Light",
            "Ancient: Chlorobon",
            "Ancient: Wilslik's Mending",
            "Ancient: Touch of Orshilak",
            "Ancient: Voice of Muram",
            "Ancient: Veil of Pyrilonus",
            "Ancient: Spear of Gelaqua",
            "Ancient: Core Fire",
            "Corona Flare",
            "Ancient: Strike of Chaos",
            "White Fire",
            "Strike of Solusek",
            "Sunstrike",
        },
        ['IceNuke'] = {
            "Hoarfrost Cascade Rk. III",
            "Hoarfrost Cascade Rk. II",
            "Hoarfrost Cascade",
            "Rime Cascade",
            "Glacial Cascade",
            "Icesheet Cascade",
            "Glacial Collapse",
            "Icefall Avalanche",
            "Spark of Ice",
            "Black Ice",
            "Draught of E`ci",
            "Draught of Ice",
            "Ice Comet",
            "Ice Shock",
            "Frost Shock",
            "Shock of Ice",
            "Numbing Cold",
            "Blast of Cold",
        },
        ['BigIceNuke'] = {                 -- Level 60-70, Timed with great Ratio or High Cast Time/Damage
            "Gelidin Comet",
            "Ice Meteor",
            "Ancient: Destruction of Ice",
            "Ice Spear of Solist",
        },
        ['MagicNuke'] = {
            "Lightning Squall Rk. III",
            "Lightning Squall Rk. II",
            "Lightning Squall",
            "Lightning Swarm",
            "Lightning Helix",
            "Ribbon Lightning",
            "Rolling Lightning",
            "Ball Lightning",
            "Spark of Lightning",
            "Draught of Lightning",
            "Voltaic Draught",
            "Rend",
            "Lightning Shock",
            "Lightning Storm",
            "Shock of Lightning",
        },
        ['BigMagicNuke'] = {                 -- Level 60-68, High Cast Time/Damage
            "Thundaka",
            "Shock of Magic",
        },
        ['StunSpell'] = {
            "Telanaga Rk. III",
            "Telanaga Rk. II",
            "Telanaga",
            "Telanama",
            "Telakama",
            "Telajara",
            "Telajasz",
            "Telakisz",
            "Telekara",
            "Telaka",
            "Telekin",
        },
        ['SelfHPBuff'] = {
            "Shield of the Dauntless Rk. III",
            "Shield of the Dauntless Rk. II",
            "Shield of the Dauntless",
            "Shield of Bronze",
            "Shield of Dreams",
            "Shield of the Void",
            "Bulwark of the Crystalwing",
            "Shield of the Crystalwing",
            "Ether Shield",
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
        ['SelfSpellShield1'] = {
            "Shield of Fate Rk. III",
            "Shield of Fate Rk. II",
            "Shield of Fate",
        },
        ['FamiliarBuff'] = {
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
            "Greater Fetter",
            "Greater Immobilize",
            "Greater Decession",
            "Greater Healing Light",
            "Greater Mass Enchant Electrum",
            "Greater Mass Enchant Gold",
            "Greater Mass Enchant Platinum",
            "Greater Mass Enchant Silver",
            "Greater Mass Enchant Velium",
            "Greater Familiar",
            "Familiar",
            "Lesser Familiar",
            "Minor Familiar",
        },
        ['SelfRune1'] = {
            "Armor of the Stonescale Rk. III",
            "Armor of the Stonescale Rk. II",
            "Armor of the Stonescale",
            "Armor of the Crystalwing",
            "Dermis of the Crystalwing",
            "Squamae of the Crystalwing",
            "Laminae of the Crystalwing",
            "Scales of the Crystalwing",
            "Ether Skin",
            "Force Shield",
        },
        ['Dispel'] = {
            "Annul Magic",
            "Nullify Magic",
            "Cancel Magic",
        },
        ['TwincastSpell'] = {
            "Twincast Rk. III",
            "Twincast Rk. II",
            "Twincast",
        },
        ['GambitSpell'] = {
            "Bucolic Gambit Rk. III",
            "Bucolic Gambit Rk. II",
            "Bucolic Gambit",
        },
        ['PetSpell'] = {
            "Flaming Arrow",
            "Flaming Sword of Xuzl",
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
        ['SnareSpell'] = {
            "Bonds of Tunare",
            "Bonds of Force",
        },
        ['EvacSpell'] = {
            "Evacuate: North",
            "Evacuate: Fay",
            "Evacuate: Ro",
            "Evacuate: Nek",
            "Evacuate: West",
            "Evacuate",
            "Lesser Evacuate",
        },
        ['HarvestSpell'] = {
            "Bucolic Harvest Rk. III",
            "Bucolic Harvest Rk. II",
            "Bucolic Harvest",
            "Placid Harvest",
            "Soothing Harvest",
            "Serene Harvest",
            "Tranquil Harvest",
            "Patient Harvest",
            "Harvest",
        },
        ['JoltSpell'] = {
            "Skullfreeze Rk. III",
            "Skullfreeze Rk. II",
            "Skullfreeze",
            "Thoughtfreeze",
            "Brainfreeze",
            "Mindfreeze",
            "Concussive Flash",
            "Concussive Burst",
            "Concussive Blast",
            "Ancient: Greater Concussion",
            "Concussion",
        },
        -- Lure Spells
        ['IceLureNuke'] = {
            "Lure of the Wastes Rk. III",
            "Lure of the Wastes Rk. II",
            "Lure of the Wastes",
            "Frigid Lure",
            "Glacial Lure",
            "Voidfrost Lure",
            "Lure of Isaz",
            "Rimelure",
            "Icebane",
            "Lure of Ice",
            "Lure of Frost",
        },
        ['FireLureNuke'] = {
            "Magmalure Rk. III",
            "Magmalure Rk. II",
            "Magmalure",
            "MagmaLure",
            "Blazelure",
            "Flamelure",
            "Flarelure",
            "Pyrolure",
            "Lavalure",
            "Firebane",
            "Lure of Ro",
            "Lure of Flame",
            "Enticement of Flame",
        },
        ['MagicLureNuke'] = {
            "Permeating Ether Rk. III",
            "Permeating Ether Rk. II",
            "Permeating Ether",
            "Lightningbane",
            "Lure of Thunder",
            "Lure of Lightning",
        },
        ['StunMagicNuke'] = {
            "Leap of Static Sparks Rk. III",
            "Leap of Static Sparks Rk. II",
            "Leap of Static Sparks",
            "Leap of Plasma",
            "Leap of Corposantum",
            "Leap of Static Jolts",
            "Leap of Static Bolts",
            "Leap of Shocking Bolts",
            "Leap of Sparks",
            "Spark of Thunder",
            "Draught of Thunder",
            "Draught of Jiva",
            "Force Strike",
            "Thunder Strike",
            "Force Snap",
            "Lightning Bolt",
        },
        -- Rain Spells Listed here are used Primarily for TLP Mode.
        -- Magic Rain - Only have 3 of them so Not Sustainable.
        ['IceRain'] = {
            "Tamagrist Torrent Rk. III",
            "Tamagrist Torrent Rk. II",
            "Tamagrist Torrent",
            "Frost Torrent",
            "Hail Torrent",
            "Icicle Torrent",
            "Icicle Storm",
            "Icicle Deluge",
            "Gelid Rains",
            "Tears of Marr",
            "Tears of Prexus",
            "Frost Storm",
            "Icestrike",
        },
        ['FireRain'] = {
            "Tears of Gosik Rk. III",
            "Tears of Gosik Rk. II",
            "Tears of Gosik",
            "Tears of Daevan",
            "Tears of Flame",
            "Tears of the Pyrilen",
            "Tears of the Forsaken",
            "Tears of the Betrayed",
            "Tears of the Sun",
            "Tears of Ro",
            "Tears of Solusek",
            "Lava Storm",
            "Firestorm",
        },
        ['FireLureRain'] = {
            "Magmatic Vent Rk. III",
            "Magmatic Vent Rk. II",
            "Magmatic Vent",
            "Magmatic Outburst",
            "Magmatic Downpour",
            "Magmatic Eruption",
            "Pyroclastic Eruption",
            "Volcanic Eruption",
            "Meteor Storm",
            "Tears of Arlyxir",
        },
        ['SnapNuke'] = {             -- T2 Ice ~8.5s recast (shared with Cloudburst)
            "Flashfreeze Rk. III",
            "Flashfreeze Rk. II",
            "Flashfreeze",
            "Frost Snap",
            "Freezing Snap",
            "Gelid Snap",
            "Rime Snap",
            "Cold Snap",
        },
        ['AEBeam'] = {               -- T2 Frontal Fire AE
            "Incinerating Beam Rk. III",
            "Incinerating Beam Rk. II",
            "Incinerating Beam",
            "Blazing Beam",
            "Corona Beam",
            "Beam of Solteris",
        },
        ['PBFlame'] = {              -- T4 PB Fire AE
            "Circle of Flame Rk. III",
            "Circle of Flame Rk. II",
            "Circle of Flame",
            "Ring of Flame",
            "Ring of Fire",
        },
        ['PBTimer4'] = {
            "Circle of Force",
            "Circle of Karana",
            "Circle of Commons",
            "Circle of Toxxulia",
            "Circle of Butcher",
            "Circle of Lavastorm",
            "Circle of Ro",
            "Circle of Feerrott",
            "Circle of Steamfont",
            "Circle of Misty",
            "Circle of Wakening Lands",
            "Circle of Iceclad",
            "Circle of Great Divide",
            "Circle of Cobalt Scar",
            "Circle of the Combines",
            "Circle of Winter",
            "Circle of Summer",
            "Circle of Surefall Glade",
            "Circle of Grimling",
            "Circle of Twilight",
            "Circle of Dawnshroud",
            "Circle of the Nexus",
            "Circle of Seasons",
            "Circle of Knowledge",
            "Circle of Stonebrunt",
            "Circle of Natimbi",
            "Circle of Fireskin",
            "Circle of Alendar",
            "Circle of Barindu",
            "Circle of Slaughter",
            "Circle of Bloodfields",
            "Circle of Dreams",
            "Circle of Undershore",
            "Circle of Arcstone",
            "Circle of Direwind",
            "Circle of The Steppes",
            "Circle of Blightfire Moors",
            "Circle of Magmaskin",
            "Circle of Magmaskin Rk. II",
            "Circle of Magmaskin Rk. III",
            "Circle of Buried Sea",
            "Circle of Divinity",
            "Circle of Divinity Rk. II",
            "Circle of Divinity Rk. III",
            "Circle of Lavaskin",
            "Circle of Lavaskin Rk. II",
            "Circle of Lavaskin Rk. III",
            "Circle of Loping Plains",
            "Circle of the Grounds",
            "Circle of Brimstoneskin",
            "Circle of Brimstoneskin Rk. II",
            "Circle of Brimstoneskin Rk. III",
            "Circle of Plane of Time",
            "Circle of Brell's Rest",
            "Circle of Dreamfire",
            "Circle of Dreamfire Rk. II",
            "Circle of Dreamfire Rk. III",
            "Circle of the Domain",
            "Circle of Alra",
            "Circle of Embers",
            "Circle of Embers Rk. II",
            "Circle of Embers Rk. III",
            "Circle of the Landing",
            "Circle of Flame",
            "Circle of Flame Rk. II",
            "Circle of Flame Rk. III",
            "Circle of Flameskin",
            "Circle of Flameskin Rk. II",
            "Circle of Flameskin Rk. III",
            "Circle of West Karana",
            "Circle of Thunder",
            "Circle of Fire",
            "Winds of Gelid",
            "Supernova",
            "Thunderclap",
        },
        ['FireJyll'] = {
        },
        ['IceJyll'] = {
        },
        ['MagicJyll'] = {
        },
    },
    ['Helpers']       = {

        RainCheck = function(target) -- I made a funny
            if not (Config:GetSetting('DoRain') and Config:GetSetting('DoAEDamage')) then return false end
            return Targeting.GetTargetDistance() >= Config:GetSetting('RainDistance') and Targeting.MobNotLowHP(target)
        end,

        GetResolvedElement = function()
            local choice = Config:GetSetting('ElementChoice')
            if choice == 1 then -- Auto
                -- 1. Check active Mastery AA buffs
                if mq.TLO.Me.Buff("Pyromancy")() or mq.TLO.Me.Buff("Pyromancy Rk. II")() or mq.TLO.Me.Buff("Pyromancy Rk. III")() then
                    return 1 -- Fire
                elseif mq.TLO.Me.Buff("Cryomancy")() or mq.TLO.Me.Buff("Cryomancy Rk. II")() or mq.TLO.Me.Buff("Cryomancy Rk. III")() then
                    return 2 -- Ice
                elseif mq.TLO.Me.Buff("Arcanomancy")() or mq.TLO.Me.Buff("Arcanomancy Rk. II")() or mq.TLO.Me.Buff("Arcanomancy Rk. III")() or mq.TLO.Me.Buff("Acromancy")() then
                    return 3 -- Magic
                end

                -- 2. Check active Familiar buffs
                if mq.TLO.Me.Buff("Ro's Familiar")() or mq.TLO.Me.Buff("Greater Ro's Familiar")() or mq.TLO.Me.Buff("Ro's Familiar Rk. II")() or mq.TLO.Me.Buff("Ro's Familiar Rk. III")() then
                    return 1 -- Fire
                elseif mq.TLO.Me.Buff("E'ci's Familiar")() or mq.TLO.Me.Buff("Greater E'ci's Familiar")() or mq.TLO.Me.Buff("E'ci's Familiar Rk. II")() or mq.TLO.Me.Buff("E'ci's Familiar Rk. III")() then
                    return 2 -- Ice
                elseif mq.TLO.Me.Buff("Druzzil's Familiar")() or mq.TLO.Me.Buff("Greater Druzzil's Familiar")() or mq.TLO.Me.Buff("Druzzil's Familiar Rk. II")() or mq.TLO.Me.Buff("Druzzil's Familiar Rk. III")() then
                    return 3 -- Magic
                end

                -- 3. Check level-appropriate spells available in spell book.
                local fireSpell = Core.GetResolvedActionMapItem('FireNuke')
                local iceSpell = Core.GetResolvedActionMapItem('IceNuke')
                local magicSpell = Core.GetResolvedActionMapItem('MagicNuke')

                local fireLevel = fireSpell and fireSpell.Level() or 0
                local iceLevel = iceSpell and iceSpell.Level() or 0
                local magicLevel = magicSpell and magicSpell.Level() or 0

                local bigFireSpell = Core.GetResolvedActionMapItem('BigFireNuke')
                local bigIceSpell = Core.GetResolvedActionMapItem('BigIceNuke')
                local bigMagicSpell = Core.GetResolvedActionMapItem('BigMagicNuke')

                local bigFireLevel = bigFireSpell and bigFireSpell.Level() or 0
                local bigIceLevel = bigIceSpell and bigIceSpell.Level() or 0
                local bigMagicLevel = bigMagicSpell and bigMagicSpell.Level() or 0

                local maxFire = math.max(fireLevel, bigFireLevel)
                local maxIce = math.max(iceLevel, bigIceLevel)
                local maxMagic = math.max(magicLevel, bigMagicLevel)

                if maxFire == 0 and maxIce == 0 and maxMagic == 0 then
                    -- Fallback if no spells resolved yet
                    return 1 -- Fire
                end

                -- Pick the element with the highest level spell
                if maxFire >= maxIce and maxFire >= maxMagic then
                    return 1 -- Fire
                elseif maxIce >= maxFire and maxIce >= maxMagic then
                    return 2 -- Ice
                else
                    return 3 -- Magic
                end
            else
                -- Map 2 -> 1 (Fire), 3 -> 2 (Ice), 4 -> 3 (Magic)
                return choice - 1
            end
        end,
    },
    ['Charm']         = {
        ['Assist'] = {
            { name = "StunSpell", type = "Spell", cond = function(self, spell, target) return Targeting.TargetNotStunned() and not Casting.StunImmuneTarget(target) end, },
        },
    },
    ['RotationOrder'] = {
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
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctAggro() > (Config:GetSetting('JoltAggro') or 90)
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Globals.AutoTargetIsNamed and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        { --Keep things from doing
            name = 'Stun',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoStun') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(100+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 99 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay()
            end,
        },
        {
            name = 'DPS(71-99)',
            state = 1,
            steps = 1,
            load_cond = function()
                return mq.TLO.Me.Level() < 100 and mq.TLO.Me.Level() > 70 and
                    (Core.GetResolvedActionMapItem('ChaosNuke') or Core.GetResolvedActionMapItem('WildNuke'))
            end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay()
            end,
        },
        {
            name = 'FireDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function(self)
                return self.Helpers.GetResolvedElement() == 1 and
                    (mq.TLO.Me.Level() < 71 or (not Core.GetResolvedActionMapItem('ChaosNuke') and not Core.GetResolvedActionMapItem('WildNuke')))
            end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay() and
                    not (Core.IsModeActive('PBAE(LowLevel)') and Combat.AETargetCheck(true))
            end,
        },
        {
            name = 'IceDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function(self)
                return self.Helpers.GetResolvedElement() == 2 and
                    (mq.TLO.Me.Level() < 71 or (not Core.GetResolvedActionMapItem('ChaosNuke') and not Core.GetResolvedActionMapItem('WildNuke')))
            end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay() and
                    not (Core.IsModeActive('PBAE(LowLevel)') and Combat.AETargetCheck(true))
            end,
        },
        {
            name = 'MagicDPS(1-70)',
            state = 1,
            steps = 1,
            load_cond = function(self)
                return self.Helpers.GetResolvedElement() == 3 and
                    (mq.TLO.Me.Level() < 71 or (not Core.GetResolvedActionMapItem('ChaosNuke') and not Core.GetResolvedActionMapItem('WildNuke')))
            end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay() and
                    not (Core.IsModeActive('PBAE(LowLevel)') and Combat.AETargetCheck(true))
            end,
        },
        {
            name = 'DPS(PBAELowLevel)',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 76 end,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay() and Combat.AETargetCheck(true)
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.AggroCheckOkay()
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            timer = 10,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },
    ['Rotations']     = {
        ['Burn'] = {
            {
                name = "Focus of Arcanum",
                type = "AA",
            },
            {
                name = "Arcane Fury",
                type = "AA",
            },
            {
                name = "Fury of the Gods",
                type = "AA",
            },
            {
                name = "Spire of Arcanum",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
                cond = function(self)
                    return not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            {
                name = "Arcane Destruction",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Spire of Arcanum")
                end,
            },
            {
                name = "Frenzied Devastation",
                type = "AA",
                cond = function(self)
                    return not Casting.IHaveBuff("Spire of Arcanum")
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
            },
            {
                name = "Mana Burn",
                type = "AA",
                cond = function(self)
                    if not Config:GetSetting('DoManaBurn') then return false end
                    return not Casting.TargetHasBuff("Mana Burn") and Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Call of Xuzl",
                type = "AA",
            },
            { -- do not use on emu, can lead to serious xtarg issues
                name = "Ward of Destruction",
                type = "AA",
                load_cond = function() return not Core.OnEMU() end,
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoAEDamage')
                end,
            },
        },
        ['Aggro Management'] =
        {
            {
                name = "Mind Crash",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "Arcane Whisper",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 90
                end,
            },
            {
                name = "A Hole in Space",
                type = "AA",
                cond = function(self)
                    return Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Concussion",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
            {
                name = "JoltSpell",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.PctAggro() > Config:GetSetting('JoltAggro')
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Atol's Shackles",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
        },
        ['Stun'] = {
            {
                name = "StunSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.HaveManaToDebuff() and Targeting.TargetNotStunned() and not Globals.AutoTargetIsNamed and not Casting.StunImmuneTarget(target)
                end,
            },
        },
        ['CombatBuff'] =
        {
            {
                name = "TwincastSpell",
                type = "Spell",
                cond = function(self)
                    return not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            {
                name = "GambitSpell",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('GambitManaPct')
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                allowDead = true,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                allowDead = true,
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('CombatHarvestManaPct')
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Lower Element",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Force of Ice",
                type = "AA",
            },
            {
                name = "Force of Will",
                type = "AA",
            },
            {
                name = "Force of Flame",
                type = "AA",
            },
        },
        ['DPS(100+)'] = {
            {
                name = "VortexNuke",
                type = "Spell",
                cond = function(self, spell) --using DotSpellCheck to leverage MobLowHP settings to ensure we aren't casting just before trash dies (default: stop at 25% on named, 50% on trash)
                    return Casting.GambitCheck() or Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "CloudburstNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GambitCheck() or Casting.IHaveBuff("Evoker's Synergy")
                end,
            },
            {
                name = "FuseNuke",
                type = "Spell",
            },
            {
                name = "AEBeam",
                type = "Spell",
                allowDead = true,
                load_cond = function(self) return Config:GetSetting('DoAEBeam') end,
                cond = function(self)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return Combat.AETargetCheck(true, Config:GetSetting('BeamTargetCnt'))
                end,
            },
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 1 and not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "IceClaw",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 2 and not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "MagicClaw",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 3 and not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "PBFlame",
                type = "Spell",
                allowDead = true,
                load_cond = function(self) return Config:GetSetting('DoPBAE') end,
                cond = function(self)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return Combat.AETargetCheck(true)
                end,
            },
            {
                name = "FireEtherealNuke",
                type = "Spell",
            },
            {
                name = "WildNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GambitCheck()
                end,
            },
            {
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self)
                    return mq.TLO.Me.Level() > 110 or Casting.IHaveBuff("Improved Twincast")
                end,
            },
        },
        ['DPS(71-99)'] = {
            {
                name = "FireClaw",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 1 and not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "IceClaw",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 2 and not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "MagicClaw",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 3 and not Casting.IHaveBuff("Improved Twincast")
                end,
            },
            {
                name = "SnapNuke",
                type = "Spell",
            },
            { --use if GOM procs or if we have extra mana while burning
                name = "FireEtherealNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GOMCheck() or (Casting.BurnCheck() and Casting.HaveManaToNuke())
                end,
            },
            { --use if GOM procs or if we have extra mana while burning
                name = "IceEtherealNuke",
                type = "Spell",
                cond = function(self)
                    return Casting.GOMCheck() or (Casting.BurnCheck() and Casting.HaveManaToNuke())
                end,
            },
            {
                name = "WildNuke",
                type = "Spell",
            },
            {
                name = "WildNuke2",
                type = "Spell",
            },
            {
                name = "ChaosNuke",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 1 and not Core.GetResolvedActionMapItem("WildNuke2")
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 2 and not Core.GetResolvedActionMapItem("WildNuke2")
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                cond = function(self)
                    return self.Helpers.GetResolvedElement() == 3 and not Core.GetResolvedActionMapItem("WildNuke2")
                end,
            },
        },
        ['FireDPS(1-70)'] = {
            {
                name = "FireRain",
                type = "Spell",
                cond = function(self, spell, target)
                    return self.Helpers.RainCheck(target)
                end,
            },
            {
                name = "BigFireNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "FireNuke",
                type = "Spell",
            },
        },
        ['IceDPS(1-70)'] = {
            {
                name = "IceRain",
                type = "Spell",
                cond = function(self, spell, target)
                    return self.Helpers.RainCheck(target)
                end,
            },
            {
                name = "BigIceNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
            },
        },
        ['MagicDPS(1-70)'] = {
            {
                name = "BigMagicNuke",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
            },
        },
        ['DPS(PBAELowLevel)'] = {
            {
                name = "PBTimer4",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "FireJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "IceJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.InSpellRange(spell, target)
                end,
            },
            {
                name = "MagicJyll",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    return Targeting.InSpellRange(spell, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Etherealist's Unity",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID()) end,
                cond = function(self, aaName)
                    local selfHPBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "SelfHPBuff")
                    local selfHPBuffLevel = selfHPBuff and selfHPBuff() and selfHPBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility("Etherealist's Unity").Spell.Trigger(1).Level() or 0) >= selfHPBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfSpellShield1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfRune1",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "FamiliarBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return (spell.Level() or 0) > (mq.TLO.Me.AltAbility("Improved Familiar").Spell.Level() or 0) and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Improved Familiar",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    local familiarBuff = Modules:ExecModule("Class", "GetResolvedActionMapItem", "FamiliarBuff")
                    local familiarBuffLevel = familiarBuff and familiarBuff() and familiarBuff.Level() or 0
                    return (mq.TLO.Me.AltAbility(aaName).Spell.Level() or 0) >= familiarBuffLevel and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Harvest of Druzzil",
                type = "AA",
                cond = function(self)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct')
                end,
            },
            {
                name = "HarvestSpell",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.CastReady(spell) and mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct')
                end,
            },
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('HarvestManaPct') and Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
    },
    ['Spells']        = {
        {
            gem = 1,
            spells = {
                { name = "VortexNuke", cond = function() return mq.TLO.Me.Level() > 102 end, },
                { name = "SnapNuke",   cond = function() return Core.GetResolvedActionMapItem('ChaosNuke') or Core.GetResolvedActionMapItem('WildNuke') end, },
                --1-70
                { name = "FireNuke",   cond = function(self) return self.Helpers.GetResolvedElement() == 1 end, },
                { name = "IceNuke",    cond = function(self) return self.Helpers.GetResolvedElement() == 2 end, },
                { name = "MagicNuke",  cond = function(self) return self.Helpers.GetResolvedElement() == 3 end, },

            },
        },
        {
            gem = 2,
            spells = {
                { name = "FireEtherealNuke", cond = function() return Core.GetResolvedActionMapItem('ChaosNuke') or Core.GetResolvedActionMapItem('WildNuke') end, },
                --1-70
                { name = "BigFireNuke",      cond = function(self) return self.Helpers.GetResolvedElement() == 1 end, },
                { name = "BigIceNuke",       cond = function(self) return self.Helpers.GetResolvedElement() == 2 end, },
                { name = "BigMagicNuke",     cond = function(self) return self.Helpers.GetResolvedElement() == 3 end, },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "IceEtherealNuke", },
                -- 1-70
                { name = "PBTimer4",        cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "StunSpell",       cond = function() return Config:GetSetting('DoStun') end, },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "FuseNuke", },
                -- 1
                { name = "FireJyll",  cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "FireRain",  cond = function(self) return Config:GetSetting('DoRain') and self.Helpers.GetResolvedElement() == 1 end, },
                { name = "IceRain",   cond = function(self) return Config:GetSetting('DoRain') and self.Helpers.GetResolvedElement() == 2 end, },
                { name = "EvacSpell", },

            },
        },
        {
            gem = 5,
            spells = {
                { name = "FireClaw", },
                -- 1-70
                { name = "IceJyll",   cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "JoltSpell", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "WildNuke", },
                -- 1-70
                { name = "MagicJyll",  cond = function() return Core.IsModeActive('PBAE(LowLevel)') and mq.TLO.Me.Level() < 71 end, },
                { name = "SnareSpell", cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "CloudburstNuke", cond = function() return mq.TLO.Me.Level() > 99 end, },
                { name = "WildNuke2", },
                { name = "ChaosNuke", },
                -- 1-70
                { name = "HarvestSpell", },

            },
        },
        {
            gem = 8,
            spells = {
                { name = "GambitSpell", },
                { name = "HarvestSpell", },
                { name = "SelfHPBuff", },

            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TwincastSpell", },
                { name = "SnareSpell",    cond = function() return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Atol's Shackles") end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "AEBeam",           cond = function() return Config:GetSetting('DoAEBeam') end, },
                { name = "PBFlame",          cond = function() return Config:GetSetting('DoPBAE') end, },
                { name = "SelfRune1", },
                { name = "SelfSpellShield1", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PBFlame",          cond = function() return Config:GetSetting('DoPBAE') end, },
                { name = "SelfRune1", },
                { name = "SelfSpellShield1", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfRune1", },
                { name = "SelfSpellShield1", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfSpellShield1", },
            },
        },
    },
    ['DefaultConfig'] = {
        ['Mode']                 = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes Do?",
            Answer = "Wizard only has a single DPS Mode, but spells or spell elements will change based on level.",
        },

        -- Low Level
        ['ElementChoice']        = {
            DisplayName = "Element Choice:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Choose an element to focus on under level 71 (Auto will dynamically detect element).",
            Type = "Combo",
            ComboOptions = { 'Auto', 'Fire', 'Ice', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['DoRain']               = {
            DisplayName = "Do Rain",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            Tooltip = "**WILL BREAK MEZ** Use your selected element's Rain Spell as a single-target nuke. **WILL BREAK MEZ***",
            Default = false,
            FAQ = "Why is Rain being used a single target nuke?",
            Answer = "In some situations, using a Rain can be an efficient single target nuke at low levels.\n" ..
                "Note that PBAE spells tend to be superior for AE dps at those levels.",
        },
        ['RainDistance']         = {
            DisplayName = "Min Rain Distance",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 103,
            ConfigType = "Advanced",
            Tooltip = "The minimum distance a target must be to use a Rain (Rain AE Range: 25').",
            Default = 30,
            Min = 0,
            Max = 100,
            FAQ = "Why does minimum rain distance matter?",
            Answer = "Rain spells, if cast close enough, can damage the caster. The AE range of a Rain is 25'.",
        },
        ['DoStun']               = {
            DisplayName = "Do Stun",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Stun",
            Index = 101,
            Tooltip = "Use your Stun Nukes (Stun with DD, not mana efficient).",
            RequiresLoadoutChange = true,
            Default = false,
        },

        --AE Damage
        ['DoAEBeam']             = {
            DisplayName = "Use Beam Spells",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 102,
            RequiresLoadoutChange = true,
            Tooltip = "**WILL BREAK MEZ** Use your Frontal AE Spells (Beam Line). **WILL BREAK MEZ**",
            Default = false,
        },
        ['BeamTargetCnt']        = {
            DisplayName = "Beam Tgt Cnt",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 103,
            Tooltip = "Minimum number of valid targets before using AE Spells like Beams.",
            Default = 2,
            Min = 1,
            Max = 10,
            FAQ = "Why am I using AE abilities on only a couple of targets?",
            Answer =
            "You can adjust the AE Target Count to control when you will use actions with AE damage attached.",
        },
        ['DoPBAE']               = {
            DisplayName = "Use PBAE Spells",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 104,
            RequiresLoadoutChange = true,
            Tooltip =
            "**WILL BREAK MEZ** Use your PB AE Spells (of Flame Line). **WILL BREAK MEZ**\nPlease note, that by necessity, the PBAELowLevel mode will NOT respect this setting.",
            Default = false,
            FAQ = "Why am I using AE damage when there are mezzed mobs around?",
            Answer = "It is not currently possible to properly determine Mez status without direct Targeting. If you are mezzing, consider turning this option off.",
        },

        -- Spells and Abilities
        ['JoltAggro']            = {
            DisplayName = "Jolt Aggro %",
            Group = "Abilities",
            Header = "Utility",
            Category = "Hate Reduction",
            Index = 101,
            Tooltip = "Aggro at which to use Jolt",
            Default = 90,
            Min = 1,
            Max = 100,
        },
        ['DoManaBurn']           = {
            DisplayName = "Use Mana Burn AA",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 104,
            Tooltip = "Enable usage of Mana Burn",
            Default = true,
        },
        ['DoSnare']              = {
            DisplayName = "Use Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 101,
            Tooltip = "Use Snare Spells.",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['SnareCount']           = {
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
        ['DoChestClick']         = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['GambitManaPct']        = {
            DisplayName = "Gambit Mana %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 101,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using your Gambit line.",
            Default = 80,
            Min = 1,
            Max = 99,
        },
        ['HarvestManaPct']       = {
            DisplayName = "Harvest Mana %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 102,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa.",
            Default = 85,
            Min = 1,
            Max = 99,
        },
        ['CombatHarvestManaPct'] = {
            DisplayName = "Combat Harvest %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 103,
            ConfigType = "Advanced",
            Tooltip = "What Mana % to hit before using a harvest spell or aa in Combat.",
            Default = 60,
            Min = 1,
            Max = 99,
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
