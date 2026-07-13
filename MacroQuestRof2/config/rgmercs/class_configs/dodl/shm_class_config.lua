local mq           = require('mq')
local Casting      = require("utils.casting")
local Comms        = require("utils.comms")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require("utils.globals")
local Targeting    = require("utils.targeting")

local _ClassConfig = {
    _version              = "DODL CUSTOM",
    _author               = "eldudero",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring  = function() return Config:GetSetting('DoCures') end,
        IsRezing  = function()
            return (Core.GetResolvedActionMapItem('RezSpell') and Targeting.GetXTHaterCount() == 0) or
                (Casting.CanUseAA("Call of the Wild") and Config:GetSetting('DoBattleRez'))
        end,
    },
    ['Rez']               = {
        ['Combat'] = {
            { type = "Item", name = "Staff of Forbidden Rites", },
            {
                type = "AA",
                name = "Call of the Wild",
                cond = function(self, spell, target, ownerName)
                    return not mq.TLO.Spawn(string.format("PC =%s", ownerName or ""))()
                end,
            },
        },
        ['Downtime'] = {
            { type = "AA", name = "Rejuvenation of Spirit", },
            {
                type = "Spell",
                name = "RezSpell",
                cond = function(self, spell, target)
                    return Casting.DowntimeRezOkay()
                end,
            },
        },
    },
    ['Modes']             = {
        'Heal',
        'Hybrid',
    },
    ['PetPosition']       = {
        SummonAA   = function() return Casting.CanUseAA("Summon Companion") and "Summon Companion" end,
        RelocateAA = function()
            local cdAA = mq.TLO.Me.AltAbility("Companion's Discipline")
            return (cdAA and cdAA.Rank() or 0) >= 4 and "Companion's Discipline"
        end,
    },
    ['Cure']              = {
        ['DetDispel'] = {
            { type = "AA", name = "Radiant Cure", },
        },
        ['Poison'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureSpell', 'CurePoison', }) end, },
        },
        ['Disease'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureSpell', 'CureDisease', }) end, },
        },
        ['Curse'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureSpell', 'CureCurse', }) end, },
        },
        ['Corruption'] = {
            { type = "Spell", name = "CureCorrupt", },
        },
    },
    ['Themes']            = {
        ['Heal'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.55, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.55, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.22, g = 0.14, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.55, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.55, g = 0.35, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.22, g = 0.14, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.55, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.55, g = 0.35, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.55, g = 0.35, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.36, g = 0.23, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.55, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.55, g = 0.35, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.55, g = 0.35, b = 0.05, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.22, g = 0.14, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.95, g = 0.70, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.95, g = 0.70, b = 0.15, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.55, g = 0.35, b = 0.05, a = 1.0, }, },
        },
        ['Hybrid'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.25, g = 0.38, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.25, g = 0.38, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.10, g = 0.15, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.25, g = 0.38, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.25, g = 0.38, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.10, g = 0.15, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.25, g = 0.38, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.25, g = 0.38, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.25, g = 0.38, b = 0.08, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.16, g = 0.25, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.25, g = 0.38, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.25, g = 0.38, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.25, g = 0.38, b = 0.08, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.10, g = 0.15, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.55, g = 0.80, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.55, g = 0.80, b = 0.20, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.25, g = 0.38, b = 0.08, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Crafted Talisman of Fates",
            "Blessed Spiritstaff of the Heyokah",
        },
    },
    ['AbilitySets']       = {
        ['GroupFocusSpell'] = {
            "Talisman of the Courageous Rk. III",
            "Talisman of the Courageous Rk. II",
            "Talisman of the Courageous",
            "Talisman of Unity",
            "Talisman of the Bloodworg",
            "Talisman of the Dire",
            "Talisman of Wunshi",
            "Focus of the Seventh",
            "Focus of Spirit",
            "Infusion of Spirit",
        },
        ['RunSpeedBuff'] = {
            "Talisman of Tala'tak",
            "Pack Shrew",
            "Spirit of Wolf",
        },
        ['HasteBuff'] = {
            "Talisman of Celerity",
            "Swift Like the Wind",
            "Celerity",
            "Alacrity",
            "Quickness",
        },
        ['TempHPBuff'] = {
            "Rampant Growth Rk. III",
            "Rampant Growth Rk. II",
            "Rampant Growth",
            "Unfettered Growth",
            "Untamed Growth",
            "Wild Growth",
        },
        ['LowLvlStaBuff'] = {
            "Talisman of Vehemence",
            "Spirit of Vehemence",
            "Talisman of Persistence",
            "Talisman of Fortitude",
            "Spirit of Fortitude",
            "Talisman of the Boar",
            "Endurance of the Boar",
            "Talisman of the Brute",
            "Riotous Health",
            "Stamina",
            "Health",
            "Spirit of Ox",
            "Spirit of Bear",
        },
        ['LowLvlAtkBuff'] = {
            "Champion",
            "Ferine Avatar",
            "Ancient: Feral Avatar",
            "Primal Avatar",
            "Harnessing of Spirit",
        },
        ['LowLvlHPBuff'] = {
            "Talisman of Kragg",
            "Talisman of Altuna",
            "Talisman of Tnarg",
            "Inner Fire",
        },
        ['LowLvlStrBuff'] = {
            "Talisman of Might",
            "Spirit of Might",
            "Talisman of the Diaku",
            "Talisman of the Rhino",
            "Maniacal Strength",
            "Strength",
            "Tumultuous Strength",
            "Raging Strength",
            "Spirit Strength",
        },
        ['LowLvlDexBuff'] = {
            "Talisman of the Raptor",
            "Mortal Deftness",
            "Dexterity",
            "Deftness",
            "Rising Dexterity",
            "Spirit of Monkey",
            "Dexterous Aura",
        },
        ['LowLvlAgiBuff'] = {
            "Talisman of Sense",
            "Spirit of Sense",
            "Talisman of the Wrulan",
            "Agility of the Wrulan",
            "Talisman of the Cat",
            "Deliriously Nimble",
            "Agility",
            "Nimble",
            "Spirit of Cat",
            "Feet like Cat",
        },
        ['AEMaloSpell'] = {
            "Wind of Malisene Rk. III",
            "Wind of Malisene Rk. II",
            "Wind of Malisene",
            "Wind of Malis",
        },
        ['MaloSpell'] = {
            "Malosinise Rk. III",
            "Malosinise Rk. II",
            "Malosinise",
            "Malos",
            "Malosinia",
            "Malo",
            "Malosini",
            "Malosi",
            "Malaisement",
            "Malaise",
        },
        ['AESlowSpell'] = {    --Often considered a waste of mana in group situations, user option.
        },
        ['SlowSpell'] = {
            "Balanced War Axe",
            "Balance of Discord",
            "Balance of the Nihil",
	    "Walking Sleep",
        },
        ['DiseaseSlow'] = {
            "Cloud",
            "Cloudburst Hail",
            "Cloudburst Hail Rk. II",
            "Cloudburst Hail Rk. III",
            "Cloud of Wasps",
            "Cloud of Wasps Rk. II",
            "Cloud of Wasps Rk. III",
            "Cloudburst Strike",
            "Cloudburst Strike Rk. II",
            "Cloudburst Strike Rk. III",
            "Cloudburst Bolts",
            "Cloudburst Bolts Rk. II",
            "Cloudburst Bolts Rk. III",
            "Cloudburst Levin",
            "Cloudburst Levin Rk. II",
            "Cloudburst Levin Rk. III",
            "Cloud of Protective Bees",
            "Cloud of Protective Bees Rk. II",
            "Cloud of Protective Bees Rk. III",
            "Cloud of Guardian Hornets",
            "Cloud of Guardian Hornets II",
            "Cloud of Guardian Hornets III",
            "Cloud of Fists",
            "Cloud of Fists Rk. II",
            "Cloud of Fists Rk. III",
            "Cloudburst Storm",
            "Cloudburst Storm Rk. II",
            "Cloudburst Storm Rk. III",
            "Cloud of Guardian Sand Wasps",
            "Cloud of Guardian Sand Wasps II",
            "Cloud of Guardian Sand Wasps III",
            "Cloudburst Tempest",
            "Cloudburst Tempest Rk. II",
            "Cloudburst Tempest Rk. III",
            "Cloudburst",
            "Cloudburst Rk. II",
            "Cloudburst Rk. III",
            "Cloud of Guardian Vespines",
            "Cloud of Guardian Vespines II",
            "Cloud of Guardian Vespines III",
            "Cloudburst Thunderbolt",
            "Cloudburst Thunderbolt Rk. II",
            "Cloudburst Thunderbolt Rk. III",
            "Cloud of Grummus",
            "Plague of Insects",
        },
        ['CrippleSpell'] = {     --not currently utilized for groups, gem slots are precious
            "Crippling Claudication",
            "Crippling Strike",
            "Crippling Incapacity",
            "Crippling Incapacity Rk. II",
            "Crippling Incapacity Rk. III",
            "Crippling Counterbias",
            "Crippling Counterbias Rk. II",
            "Crippling Counterbias Rk. III",
            "Crippling Spasm",
            "Cripple",
            "Incapacitate",
            "Listless Power",
        },
        ['GroupHealProcBuff'] = {
        },
        ['WardBuff'] = {
            "Ward of Rejuvenation Rk. III",
            "Ward of Rejuvenation Rk. II",
            "Ward of Rejuvenation",
            "Ward of Reconstruction",
            "Ward of Recovery",
            "Ward of Restoration",
            "Ward of Resurgence",
        },
        ['DichoSpell'] = {
        },
        ['MeleeProcBuff'] = {
            "Talisman of the Snow Leopard Rk. III",
            "Talisman of the Snow Leopard Rk. II",
            "Talisman of the Snow Leopard",
            "Talisman of the Lion",
            "Talisman of the Tiger",
            "Talisman of the Lynx",
            "Talisman of the Cougar",
            "Talisman of the Panther",
            "Spirit of the Panther",
            "Spirit of the Leopard",
            "Spirit of the Jaguar",
            "Spirit of the Puma",
        },
        ['SlowProcBuff'] = {
            "Fatigue Rk. III",
            "Fatigue Rk. II",
            "Fatigue",
            "Apathy",
            "Lethargy",
            "Listlessness",
            "Languor",
            "Lassitude",
            "Lingering Sloth",
        },
        ['PackSelfBuff'] = {
            "Pack of Kriegas Rk. III",
            "Pack of Kriegas Rk. II",
            "Pack of Kriegas",
            "Pack of Hilnaah",
            "Pack of Wurt",
        },
        ['AllianceBuff'] = {
        },
        ['RezSpell'] = {
            "Incarnate Anew",
        },
        ['RecklessHeal1'] = {
            "Reckless Restoration Rk. III",
            "Reckless Restoration Rk. II",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
            "Chloroblast",
            "Superior Healing",
            "Spirit Salve",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['RecklessHeal2'] = {
            "Reckless Restoration Rk. III",
            "Reckless Restoration Rk. II",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
        },
        ['RecklessHeal3'] = {
            "Reckless Restoration Rk. III",
            "Reckless Restoration Rk. II",
            "Reckless Restoration",
            "Reckless Remedy",
            "Reckless Mending",
        },
        ['AESpiritualHeal'] = {
            "Spiritual Surge Rk. III",
            "Spiritual Surge Rk. II",
            "Spiritual Surge",
        },
        ['RecourseHeal'] = {
        },
        ['InterventionHeal'] = {
            "Ancestral Intervention Rk. III",
            "Ancestral Intervention Rk. II",
            "Ancestral Intervention",
        },
        ['GroupRenewalHoT'] = {
            "Wisp of Renewal Rk. III",
            "Wisp of Renewal Rk. II",
            "Wisp of Renewal",
            "Phantom of Renewal",
            "Penumbra of Renewal",
            "Shadow of Renewal",
            "Shade of Renewal",
            "Specter of Renewal",
            "Ghost of Renewal",
            "Spiritual Serenity",
            "Breath of Trushar",
            "Quiescence",
            "Torpor",
            "Stoicism",
        },
        ['CanniSpell'] = {
            "Ancestral Pact Rk. III",
            "Ancestral Pact Rk. II",
            "Ancestral Pact",
            "Ancestral Arrangement",
            "Ancestral Covenant",
            "Ancestral Obligation",
            "Ancestral Hearkening",
            "Ancestral Bargain",
            "Ancient: Ancestral Calling",
            "Pained Memory",
            "Ancient: Chaotic Pain",
            "Cannibalize IV",
            "Cannibalize III",
            "Cannibalize II",
            "Cannibalize",
        },
        ['CureSpell'] = {
            "Blood of Sanera Rk. III",
            "Blood of Sanera Rk. II",
            "Blood of Sanera",
            "Blood of Klar",
            "Blood of Corbeth",
            "Blood of Avoling",
            "Blood of Nadox",
        },
        ['CureCorrupt'] = {
            "Chant of Jaerol Rk. III",
            "Chant of Jaerol Rk. II",
            "Chant of Jaerol",
            "Chant of the Izon",
            "Chant of the Tae Ew",
            "Chant of the Burynai",
            "Chant of the Darkvine",
            "Chant of the Napaea",
            "Cure Corruption",
        },
        ['TwinHealNuke'] = {
            "Frigid Gift Rk. III",
            "Frigid Gift Rk. II",
            "Frigid Gift",
            "Freezing Gift",
            "Frozen Gift",
            "Frost Gift",
        },
        ['PoisonNuke'] = {
            "Spear of Warding",
            "Spear of Decay",
            "Spear of Pain",
            "Spear of Disease",
            "Spear of Plague",
            "Spear of Muram",
            "Spear of Ro",
            "Spear of Magma",
            "Spear of Magma Rk. II",
            "Spear of Magma Rk. III",
            "Spear of Sholoth",
            "Spear of Sholoth Rk. II",
            "Spear of Sholoth Rk. III",
            "Spear of Molten Steel",
            "Spear of Molten Steel Rk. II",
            "Spear of Molten Steel Rk. III",
            "Spear of Grelleth",
            "Spear of Grelleth Rk. II",
            "Spear of Grelleth Rk. III",
            "Spear of Blistersteel",
            "Spear of Blistersteel Rk. II",
            "Spear of Blistersteel Rk. III",
            "Spear of Torment",
            "Blast of Venom",
            "Shock of Venom",
            "Blast of Poison",
            "Shock of the Tainted",
        },
        ['FastPoisonNuke'] = {
            "Bite of the Grendlaen Rk. III",
            "Bite of the Grendlaen Rk. II",
            "Bite of the Grendlaen",
            "Bite of the Blightwolf",
            "Bite of the Ukun",
            "Bite of the Brownie",
            "Sting of the Queen",
        },
        ['IceNuke'] = {
            "Ice Burst Rk. III",
            "Ice Burst Rk. II",
            "Ice Burst",
            "Ice Mass",
            "Ice Floe",
            "Ice Sheet",
            "Tundra Crumble",
            "Glacial Avalanche",
            "Ice Age",
            "Velium Strike",
            "Ice Strike",
            "Blizzard Blast",
            "Frost Strike",
            "Spirit Strike",
            "Frost Rift",
        },
        ['ChaoticDot'] = {
        },
        ['PandemicDot'] = {
        },
        ['MaloDot'] = {
        },
        ['CurseDot1'] = {
            "Naganaga Rk. III",
            "Naganaga Rk. II",
            "Naganaga",
            "Hoodoo",
            "Hex",
            "Mojo",
            "Pocus",
            "Juju",
            "Curse of Sisslak",
            "Bane",
            "Anathema",
            "Odium",
            "Curse",
        },
        ['CurseDot2'] = {
        },
        ['SaryrnDot'] = {
            "Phase Spider Blood Rk. III",
            "Phase Spider Blood Rk. II",
            "Phase Spider Blood",
            "Naeya Blood",
            "Spinechiller Blood",
            "Blood of Kerafyrm",
            "Vengeance of Ahnkaul",
            "Blood of Yoppa",
            "Blood of Saryrn",
            "Ancient: Scourge of Nife",
            "Bane of Nife",
            "Envenomed Bolt",
            "Venom of the Snake",
            "Envenomed Breath",
            "Tainted Breath",
        },
        ['UltorDot'] = {
            "Breath of Natigo Rk. III",
            "Breath of Natigo Rk. II",
            "Breath of Natigo",
            "Breath of Silbar",
            "Breath of the Shiverback",
            "Breath of Queen Malarian",
            "Breath of Big Bynn",
            "Breath of Ternsmochin",
            "Breath of Wunshi",
            "Breath of Ultor",
            "Pox of Bertoxxulous",
            "Plague",
            "Scourge",
            "Affliction",
            "Sicken",
        },
        ['AfflictionDot'] = {
        },
        ['NectarDot'] = {               --almost never worth casting in a group, not currently gemmed.
            "Vengeance of Anguish III",
            "Vengeance of Anguish II",
            "Vengeance of Anguish",
            "Nectar of Anguish Rk. III",
            "Nectar of Anguish Rk. II",
            "Nectar of Anguish",
            "Nectar of Sholoth",
            "Nectar of Torment",
            "Nectar of the Slitheren",
            "Nectar of Rancor",
            "Nectar of Agony",
            "Nectar of Pain",
        },
        ['PetSpell'] = {
            "True Spirit",
            "Spirit of the Howler",
            "Frenzied Spirit",
            "Guardian spirit",
            "Vigilant Spirit",
            "Companion Spirit",
        },
        ['PetBuffSpell'] = {
            "Spirit Bolstering Rk. III",
            "Spirit Bolstering Rk. II",
            "Spirit Bolstering",
            "Spirit Quickening",
        },
        ['CureDisease'] = {
            "Eradicate Poison",
            "Eradicate Curse",
            "Eradicate Corruption",
            "Eradicate Corruption Rk. II",
            "Eradicate Corruption Rk. III",
            "Eradicate Disease",
            "Counteract Disease",
            "Cure Disease",
        },
        ['CurePoison'] = {
            "Eradicate Disease",
            "Eradicate Curse",
            "Eradicate Corruption",
            "Eradicate Corruption Rk. II",
            "Eradicate Corruption Rk. III",
            "Eradicate Poison",
            "Counteract Poison",
        },
        ['CureCurse'] = {
            "Remove Greater Curse",
            "Remove Curse",
            "Remove Lesser Curse",
            "Remove Minor Curse",
        },
        ['GroupRegenBuff'] = {               --Does not stack with Dicho Regen
            "Talisman of the Steadfast Rk. III",
            "Talisman of the Steadfast Rk. II",
            "Talisman of the Steadfast",
            "Talisman of the Indomitable",
            "Talisman of the Relentless",
            "Talisman of the Resolute",
            "Talisman of the Stalwart",
            "Talisman of the Stoic One",
            "Talisman of Perseverance",
            "Regrowth of Dar Khura",
        },
        ['SingleRegenBuff'] = {
            "Regrowth of the Grove",
            "Regrowth of Dar Khura",
            "Regrowth",
            "Chloroplast",
            "Regeneration",
        },
        ['ShrinkSpell'] = {
            "Shrink",
        },
    },
    ['Helpers']           = {
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        {
            name = 'LowLevelHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 65 end,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 64 end,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'BigHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 64 end,
            cond = function(self, target) return Targeting.BigHealsNeeded(target) and not Targeting.TargetIsType("pet", target) end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 64 end,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['LowLevelHealPoint'] = {
            {
                name = "Call of the Ancients",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigHealsNeeded(target)
                end,
            },
            {
                name = "RecklessHeal1",
                type = "Spell",
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    if not Targeting.GroupedWithTarget(target) or not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['GroupHealPoint'] = {
            {
                name = "InterventionHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.BigHealsNeeded(target) -- if multiples hurt with at least one in big heal range
                end,
            },
            {
                name = "Soothsayer's Intervention",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigGroupHealsNeeded() -- if multiples hurt with multiples in big heal range
                end,
            },
            {
                name = "RecourseHeal",
                type = "Spell",
            },
            {
                name = "AESpiritualHeal",
                type = "Spell",
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
                name = "Call of the Ancients",
                type = "AA",
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    if not Targeting.GroupedWithTarget(target) or not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['BigHealPoint'] = {
            {
                name = "Ancestral Guard",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "InterventionHeal",
                type = "Spell",
            },
            {
                name = "Soothsayer's Intervention",
                type = "AA",
            },
            {
                name = "Union of Spirits",
                type = "AA",
            },
            { --The stuff above is down, lets make mainhealpoint chonkier.
                name = "Spiritual Blessing",
                type = "AA",
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
            },
            { --if we hit this we need intervention back ASAP
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['MainHealPoint'] = {
            {
                name = "RecourseHeal",
                type = "Spell",
            },
            {
                name = "AESpiritualHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "RecklessHeal1",
                type = "Spell",
            },
            {
                name = "RecklessHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
            {
                name = "RecklessHeal3",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.SpellLoaded(spell)
                end,
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
            },
        },
    },
    ['Charm']             = {
        ['Assist'] = {
            {
                name = "Malaise",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoSTMalo') and Casting.CanUseAA("Malaise") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName, target)
                end,
            },
            {
                name = "MaloSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSTMalo') and not Casting.CanUseAA("Malaise") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell, target)
                end,
            },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.CombatActionsCheck() and Casting.OkayToBuff() and
                    Casting.AmIBuffable()
            end,
        },
        {
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.CombatActionsCheck() and mq.TLO.Me.Pet.ID() == 0 and Casting.OkayToPetBuff() and
                    Casting.AmIBuffable()
            end,
        },
        { --Downtime buffs that don't need constant checks
            name = 'SlowDowntime',
            timer = 30,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and
                    Core.CombatActionsCheck() and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Spells that should be checked on group members
            name = 'GroupBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Casting.GetBuffableIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.CombatActionsCheck() and Casting.OkayToBuff()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 10,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.CombatActionsCheck() and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        {
            name = 'Malo',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSTMalo') or Config:GetSetting('DoAEMalo') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Slow',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSTSlow') or Config:GetSetting('DoAESlow') end,
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
                return combat_state == "Combat" and Casting.BurnCheck() and
                    Core.CombatActionsCheck()
            end,
        },
        {
            name = 'ProcBuff',
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('MeleeProcBuff') end,
            targetId = function(self) return Casting.GetBuffableIDs() end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Casting.OkayToBuff()
                local combat = combat_state == "Combat"
                return (downtime or combat) and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'CombatBuff',
            timer = 10,
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and ((not Core.IsModeActive('Heal') or Config:GetSetting('DoHealDPS')) and Core.CombatActionsCheck())
            end,
        },
    },
    ['Rotations']         = {
        ['ProcBuff'] = {
            {
                name = "DichoSpell",
                type = "Spell",
                load_cond = function(self) return Core.GetResolvedActionMapItem('DichoSpell') end,
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "MeleeProcBuff",
                type = "Spell",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('DichoSpell') end,
                cond = function(self, spell, target)
                    if (spell.TargetType() or ""):lower() ~= "group v2" and not Targeting.TargetIsAMelee(target) then return false end
                    if not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Fleeting Spirit",
                type = "AA",
            },
            {
                name = "Ancestral Aid",
                type = "AA",
            },
            {
                name = "Spire of Ancestors",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed
                end,
            },
            {
                name = "Spirit Call",
                type = "AA",
            },
            {
                name = "Rabid Bear",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
        },
        ['Malo'] = {
            {
                name = "Wind of Malaise",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoAEMalo') and Casting.CanUseAA("Wind of Malaise") end,
                cond = function(self, aaName, target)
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AEMaloCount') and Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "AEMaloSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoAEMalo') and not Casting.CanUseAA("Wind of Malaise") end,
                cond = function(self, spell, target)
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AEMaloCount') and Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Malaise",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoSTMalo') and Casting.CanUseAA("Malaise") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "MaloSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSTMalo') and not Casting.CanUseAA("Malaise") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['Slow'] = {
            {
                name = "Turgur's Virulent Swarm",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoAESlow') and Casting.CanUseAA("Turgur's Virulent Swarm") end,
                cond = function(self, aaName, target)
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AESlowCount') and Casting.DetAACheck(aaName) and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "AESlowSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoAESlow') and not Casting.CanUseAA("Turgur's Virulent Swarm") end,
                cond = function(self, spell, target)
                    return Targeting.GetXTHaterCount() >= Config:GetSetting('AESlowCount') and Casting.DetSpellCheck(spell) and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "Turgur's Swarm",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoSTSlow') and Casting.CanUseAA("Turgur's Swarm") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "SlowSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSTSlow') and not Casting.CanUseAA("Turgur's Swarm") end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoSTSlow') or Casting.CanUseAA("Turgur's Swarm") then return false end
                    return Casting.DetSpellCheck(spell) and (spell and spell.RankName.SlowPct() or 0) > Targeting.GetTargetSlowedPct() and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "DiseaseSlow",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDiseaseSlow') end,
                waitReadyTime = function() return Config:GetSetting('DiseaseSlowWaitTime') end,
                cond = function(self, spell, target)
                    return not mq.TLO.Target.Slowed() and Casting.DetSpellCheck(spell) and not Casting.SlowImmuneTarget(target)
                end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if Config:GetSetting('UseEpic') == 1 then return false end
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "Cannibalization",
                type = "AA",
                allowDead = true,
                load_cond = function(self) return Config:GetSetting('DoAACanni') and Config:GetSetting('DoCombatCanni') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('AACanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                allowDead = true,
                load_cond = function(self) return Config:GetSetting('DoSpellCanni') and Config:GetSetting('DoCombatCanni') end,
                cond = function(self, spell)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('SpellCanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                allowDead = true,
                load_cond = function(self) return Casting.CanUseAA("Luminary's Synergy") and Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end
                    return Targeting.MobHasLowHP() and spell.RankName.Stacks() and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
        },
        ['DPS'] = {
            {
                name = "TwinHealNuke",
                type = "CustomFunc",
                load_cond = function(self) return Config:GetSetting('DoTwinHealNuke') and self:GetResolvedActionMapItem('TwinHealNuke') end,
                cond = function(self, spell, target)
                    if Casting.IHaveBuff("Healing Twincast") then return false end
                    local twinHeal = Core.GetResolvedActionMapItem("TwinHealNuke")
                    return Casting.CastReady(twinHeal)
                end,
                custom_func = function(self)
                    local twinHeal = Core.GetResolvedActionMapItem("TwinHealNuke")
                    Casting.UseSpell(twinHeal.RankName(), Core.GetMainAssistId(), false, false, 0)
                end,
            },
            { -- Calling "GetFirstMapItem" in a function so we don't need an entry for each of the below items... it simply chooses the "best"
                name_func = function(self)
                    return Casting.GetFirstMapItem({ "ChaoticDot", "SaryrnDot", })
                end,
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoPoisonDot') end,
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            { -- Calling "GetFirstMapItem" in a function so we don't need an entry for each of the below items... it simply chooses the "best"
                name_func = function(self)
                    return Casting.GetFirstMapItem({ "CurseDot2", "CurseDot1", })
                end,
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoCurseDot') end,
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            {
                name = "PandemicDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDiseaseDot') end,
                cond = function(self, spell, target)
                    if Core.IsModeActive("Heal") and not Config:GetSetting('DoHealDPS') then return false end
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            { -- for hybrid mode, which will use both curses if we have them
                name = "CurseDot1",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoCurseDot') and Core.IsModeActive("Hybrid") and Core.GetResolvedActionMapItem('CurseDot2') end,
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            { -- for hybrid mode, which loads this even after we get chaotic as a dot to use when chaotic is down
                name = "SaryrnDot",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoPoisonDot') and Core.IsModeActive("Hybrid") and Core.GetResolvedActionMapItem('ChaoticDot') end,
                cond = function(self, spell, target)
                    return Casting.DotSpellCheck(spell) and Casting.HaveManaToDot()
                end,
            },
            { -- Calling "GetFirstMapItem" in a function so we don't need an entry for each of the below items... it simply chooses the "best"
                name_func = function(self)
                    return Casting.GetFirstMapItem({ "AfflictionDot", "UltorDot", })
                end,
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDiseaseDot') end,
                cond = function(self, spell, target)
                    return Globals.AutoTargetIsNamed and Casting.DotSpellCheck(spell)
                end,
            },
            { -- Calling "GetFirstMapItem" in a function so we don't need an entry for each of the below items... it simply chooses the "best"
                name_func = function(self)
                    return Casting.GetFirstMapItem({ "FastPoisonNuke", "PoisonNuke", "IceNuke", })
                end,
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.OkayToNuke(true)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() ~= 0 end,
                cond = function(self, _) return Config:GetSetting('DoPet') and mq.TLO.Me.Pet.ID() == 0 end,
                post_activate = function(self, spell)
                    local pet = mq.TLO.Me.Pet
                    if pet.ID() > 0 then
                        Comms.PrintGroupMessage("Summoned a new %d %s pet named %s using '%s'!", pet.Level(),
                            pet.Class.Name(), pet.CleanName(), spell.RankName())
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Cannibalization",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoAACanni') and Casting.CanUseAA('Cannibalization') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() < Config:GetSetting('AACanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('AACanniMinHP')
                end,
            },
            {
                name = "CanniSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSpellCanni') end,
                cond = function(self, spell)
                    if not Casting.CastReady(spell) then return false end
                    return mq.TLO.Me.PctMana() < Config:GetSetting('SpellCanniManaPct') and mq.TLO.Me.PctHPs() >= Config:GetSetting('SpellCanniMinHP')
                end,
            },
            {
                name = "GroupHealProcBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "GroupRenewalHoT",
                type = "Spell",
                cond = function(self, spell)
                    if not Casting.CanUseAA("Luminary's Synergy") or not Config:GetSetting('DoHealOverTime') or not Casting.CastReady(spell) then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Preincarnation",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName)
                        .Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetBuffSpell",
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
        ['SlowDowntime'] = {
            {
                name = "Pact of the Wolf",
                type = "AA",
                active_cond = function(self, aaName) return mq.TLO.Me.Aura(aaName)() ~= nil end,
                cond = function(self, aaName)
                    return Config:GetSetting('DoAura') and not Casting.IHaveBuff(aaName) and
                        mq.TLO.Me.Aura(aaName)() == nil
                end,
            },
            {
                name = "Visionary's Unity",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName)
                        .Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName) --Check ranks because we don't want the first pack buff (drains mana)
                    if (mq.TLO.Me.AltAbility(aaName).Rank() or 999) < 2 then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "PackSelfBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if (mq.TLO.Me.AltAbility("Visionary's Unity").Rank() or 999) > 1 then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "WardBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoSelfWard') then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Spirit Guardian",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "TempHPBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTempHP') end,
                cond = function(self, spell, target)
                    return Targeting.TargetClassIs("WAR", target) and Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SlowProcBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --Used on the entire group
                name = "GroupFocusSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            { --Only cast below 86 because past that our focus spells take over. Could check which unity we have, but expensive.
                name = "LowLvlAtkBuff",
                type = "Spell",
                load_cond = function(self) return mq.TLO.Me.Level() < 86 end,
                cond = function(self, spell, target)
                    return Targeting.TargetIsAMelee(target) and Casting.CastReady(spell) and
                        Casting.GroupBuffCheck(spell, target)
                end,
            },
            { -- Only cast below 111 because past that our focus spells take over. Could check which unity we have, but expensive.
                name = "Talisman of Celerity",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoHaste') and Casting.CanUseAA("Talisman of Celerity") and mq.TLO.Me.Level() < 111 end,
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, aaName, target)
                    if Casting.TargetHasBuffList(target, Casting.EnchanterHasteBuffs) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "HasteBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHaste') and not Casting.CanUseAA("Talisman of Celerity") end,
                active_cond = function(self, aaName) return mq.TLO.Me.Haste() end,
                cond = function(self, spell, target)
                    if Casting.TargetHasBuffList(target, Casting.EnchanterHasteBuffs) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleRegenBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoRegenBuff') and not Core.GetResolvedActionMapItem('GroupRegenBuff') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return (Targeting.TargetIsATank(target) or Targeting.TargetIsMyself(target)) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoRegenBuff') and not Core.GetResolvedActionMapItem('DichoSpell') end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Lupine Spirit",
                type = "AA",
                -- We get Tala'tak at 74, but this doesn't use it until 90. Check Ranks.
                load_cond = function(self) return Config:GetSetting('DoRunSpeed') and (mq.TLO.Me.AltAbility("Lupine Spirit").Rank() or -1) > 3 end,
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName, target)
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "RunSpeedBuff",
                type = "Spell",
                -- We get Tala'tak at 74, but Lupine Spirit doesn't use it until 90. Check Ranks.
                load_cond = function(self) return Config:GetSetting('DoRunSpeed') and (mq.TLO.Me.AltAbility("Lupine Spirit").Rank() or -1) < 4 end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Group Shrink",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoGroupShrink') and Casting.CanUseAA("Group Shrink") end,
                active_cond = function(self) return mq.TLO.Me.Height() < 2 end,
                cond = function(self, aaName, target)
                    return Targeting.GetTargetHeight(target) > 2.2
                end,
            },
            {
                name = "ShrinkSpell",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoGroupShrink') and not Casting.CanUseAA("Group Shrink") end,
                active_cond = function(self) return mq.TLO.Me.Height() < 2 end,
                cond = function(self, spell, target)
                    return Targeting.GetTargetHeight(target) > 2.2
                end,
            },
            {
                name = "LowLvlHPBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLLHPBuff') end,
                cond = function(self, spell, target)
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlAgiBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLLAgiBuff') end,
                cond = function(self, spell, target)
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlStaBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLLStaBuff') end,
                cond = function(self, spell, target)
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsATank(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "LowLvlStrBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLLStrBuff') end,
                cond = function(self, spell, target)
                    return mq.TLO.Me.Level() < 71 and Targeting.TargetIsAMelee(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
    },
    -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
    -- Conditions are not limited to modes. Virtually any helper function or TLO can be used. Example: Level-based lists.
    -- The first list whose conditions returns true will be loaded, all subsequent lists will be ignored.
    -- Loadout checks (such as scribing a spell or using the "Rescan Loadout" or "Reload Spells" buttons) will re-check these lists and may load a different set if things have changed.
    ['SpellList']         = {
        {
            name = "Heal Mode", --This name is abitrary, it is simply what shows up in the UI when this spell list is loaded.
            cond = function(self) return Core.IsModeActive("Heal") end,
            spells = {          -- Spells will be loaded in order (if the conditions are met), until all gem slots are full.
                -- Role-Critical
                { name = "RecklessHeal1", },
                { name = "RecourseHeal", },
                { name = "InterventionHeal", },
                { name = "AESpiritualHeal", },
                { name = "RecklessHeal2", },
                { name = "SlowSpell",         cond = function(self) return not Casting.CanUseAA("Turgur's Swarm") and Config:GetSetting('DoSTSlow') end, },          -- 27-77
                { name = "DiseaseSlow",       cond = function(self) return Config:GetSetting('DoDiseaseSlow') end, },
                { name = "AESlowSpell",       cond = function(self) return not Casting.CanUseAA("Turgur's Virulent Swarm") and Config:GetSetting('DoAESlow') end, }, -- 58-79
                { name = "MaloSpell",         cond = function(self) return not Casting.CanUseAA("Malaise") and Config:GetSetting('DoSTMalo') end, },                 -- 47-74
                { name = "AEMaloSpell",       cond = function(self) return not Casting.CanUseAA("Wind of Malaise") and Config:GetSetting('DoAEMalo') end, },         -- 84-94
                { name = "DichoSpell", },
                { name = "MeleeProcBuff",     cond = function(self) return not Core.GetResolvedActionMapItem('DichoSpell') end, },
                { name = "LowLvlAtkBuff",     cond = function(self) return mq.TLO.Me.Level() < 86 end, }, -- 60-85
                { name = "PetSpell",          cond = function(self) return Config:GetSetting('DoPet') end, },

                -- Utility
                { name = "CanniSpell",        cond = function(self) return Config:GetSetting('DoSpellCanni') end, },   -- 23 - ???
                { name = "GroupRenewalHoT",   cond = function(self) return Config:GetSetting('DoHealOverTime') end, }, -- 44-125 Heal
                { name = "SingleRegenBuff",   cond = function(self) return Config:GetSetting('DoRegenBuff') and not Core.GetResolvedActionMapItem('GroupRegenBuff') end, },
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },       -- 81-125
                { name = "CureSpell",         cond = function(self) return Config:GetSetting('MemCureSpell') end, },

                -- DPS
                { name = "ChaoticDot",        cond = function(self) return Config:GetSetting('DoPoisonDot') end, },                                                     -- 104-125
                { name = "SaryrnDot",         cond = function(self) return not Core.GetResolvedActionMapItem('ChaoticDot') and Config:GetSetting('DoPoisonDot') end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "PandemicDot",       cond = function(self) return Config:GetSetting('DoDiseaseDot') end, },                                                    -- 103-125
                { name = "TwinHealNuke",      cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },                                                  -- 85-125
                { name = "FastPoisonNuke",    cond = function(self) return Config:GetSetting('DoNuke') end, },
                { name = "PoisonNuke",        cond = function(self) return Config:GetSetting('DoNuke') and not Core.GetResolvedActionMapItem('FastPoisonNuke') end, },
                { name = "IceNuke",           cond = function(self) return Config:GetSetting('DoNuke') and not Core.GetResolvedActionMapItem('PoisonNuke') end, },
                { name = "CurseDot2",         cond = function(self) return Config:GetSetting('DoCurseDot') end, },                                                          -- 100-125
                { name = "CurseDot1",         cond = function(self) return Config:GetSetting('DoCurseDot') and not Core.GetResolvedActionMapItem('CurseDot2') end, },       -- 34-??? Heal, 34-125 Hybrid
                { name = "AfflictionDot",     cond = function(self) return not Core.GetResolvedActionMapItem('PandemicDot') and Config:GetSetting('DoDiseaseDot') end, },   -- 92-125 (Boss Only)
                { name = "UltorDot",          cond = function(self) return not Core.GetResolvedActionMapItem('AfflictionDot') and Config:GetSetting('DoDiseaseDot') end, }, -- 4-91 (Boss Only)

                -- Filler
                { name = "CurePoison",        cond = function(self) return not Core.GetResolvedActionMapItem('CureSpell') and Config:GetSetting('MemCureSpell') end, },
                { name = "CureDisease",       cond = function(self) return not Core.GetResolvedActionMapItem('CureSpell') and Config:GetSetting('MemCureSpell') end, },
                { name = "CureCurse",         cond = function(self) return not Core.GetResolvedActionMapItem('CureSpell') and Config:GetSetting('MemCureSpell') end, },
                { name = "GroupHealProcBuff", }, -- 101-125,
                { name = "RecklessHeal3", },
                { name = "SlowProcBuff", },
            },
        },
        {
            name = "Hybrid Mode",
            cond = function(self) return Core.IsModeActive("Hybrid") end,
            spells = {
                -- Role-Critical
                { name = "RecklessHeal1", },
                { name = "RecourseHeal", },
                { name = "InterventionHeal", },
                { name = "AESpiritualHeal", },
                { name = "SlowSpell",         cond = function(self) return not Casting.CanUseAA("Turgur's Swarm") and Config:GetSetting('DoSTSlow') end, },          -- 27-77
                { name = "DiseaseSlow",       cond = function(self) return Config:GetSetting('DoDiseaseSlow') end, },
                { name = "AESlowSpell",       cond = function(self) return not Casting.CanUseAA("Turgur's Virulent Swarm") and Config:GetSetting('DoAESlow') end, }, -- 58-79
                { name = "MaloSpell",         cond = function(self) return not Casting.CanUseAA("Malaise") and Config:GetSetting('DoSTMalo') end, },                 -- 47-74
                { name = "AEMaloSpell",       cond = function(self) return not Casting.CanUseAA("Wind of Malaise") and Config:GetSetting('DoAEMalo') end, },         -- 84-94
                { name = "DichoSpell", },
                { name = "MeleeProcBuff",     cond = function(self) return not Core.GetResolvedActionMapItem('DichoSpell') end, },
                { name = "LowLvlAtkBuff",     cond = function(self) return mq.TLO.Me.Level() < 86 end, },
                { name = "PetSpell",          cond = function(self) return Config:GetSetting('DoPet') end, },

                -- DPS
                { name = "ChaoticDot",        cond = function(self) return Config:GetSetting('DoPoisonDot') end, },                                                     -- 104-125
                { name = "SaryrnDot",         cond = function(self) return not Core.GetResolvedActionMapItem('ChaoticDot') and Config:GetSetting('DoPoisonDot') end, }, -- 8-?? Heal, 8-125 Hybrid
                { name = "PandemicDot",       cond = function(self) return Config:GetSetting('DoDiseaseDot') end, },                                                    -- 103-125
                { name = "FastPoisonNuke",    cond = function(self) return Config:GetSetting('DoNuke') end, },
                { name = "PoisonNuke",        cond = function(self) return Config:GetSetting('DoNuke') and not Core.GetResolvedActionMapItem('FastPoisonNuke') end, },
                { name = "IceNuke",           cond = function(self) return Config:GetSetting('DoNuke') and not Core.GetResolvedActionMapItem('PoisonNuke') end, },
                { name = "CurseDot2",         cond = function(self) return Config:GetSetting('DoCurseDot') end, },                                                          -- 100-125
                { name = "CurseDot1",         cond = function(self) return Config:GetSetting('DoCurseDot') end, },                                                          -- 34-??? Heal, 34-125 Hybrid
                { name = "SaryrnDot",         cond = function(self) return Config:GetSetting('DoPoisonDot') end, },                                                         -- backup for if Chaotic is Down
                { name = "AfflictionDot",     cond = function(self) return Config:GetSetting('DoDiseaseDot') end, },                                                        -- 92-125 (Boss Only)
                { name = "UltorDot",          cond = function(self) return not Core.GetResolvedActionMapItem('AfflictionDot') and Config:GetSetting('DoDiseaseDot') end, }, -- 4-91 (Boss Only)
                { name = "PoisonNuke",        cond = function(self) return Config:GetSetting('DoNuke') end, },
                { name = "TwinHealNuke",      cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, },                                                      -- 85-125

                -- Utility, Filler
                { name = "CanniSpell",        cond = function(self) return Config:GetSetting('DoSpellCanni') end, },   -- 23 - ???
                { name = "GroupRenewalHoT",   cond = function(self) return Config:GetSetting('DoHealOverTime') end, }, -- 44-125 Heal
                { name = "SingleRegenBuff",   cond = function(self) return Config:GetSetting('DoRegenBuff') and not Core.GetResolvedActionMapItem('GroupRegenBuff') end, },
                { name = "TempHPBuff",        cond = function(self) return Config:GetSetting('DoTempHP') end, },       -- 81-125
                { name = "TwinHealNuke",      cond = function(self) return Config:GetSetting('DoTwinHealNuke') end, }, -- 85-125
                { name = "CureSpell",         cond = function(self) return Config:GetSetting('MemCureSpell') end, },
                { name = "CurePoison",        cond = function(self) return not Core.GetResolvedActionMapItem('CureSpell') and Config:GetSetting('MemCureSpell') end, },
                { name = "CureDisease",       cond = function(self) return not Core.GetResolvedActionMapItem('CureSpell') and Config:GetSetting('MemCureSpell') end, },
                { name = "CureCurse",         cond = function(self) return not Core.GetResolvedActionMapItem('CureSpell') and Config:GetSetting('MemCureSpell') end, },
                { name = "RecklessHeal2", },
                { name = "GroupHealProcBuff", }, -- 101-125,
                { name = "SlowProcBuff", },
            },
        },
    },
    ['PullAbilities']     = {
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
        {
            id = 'SaryrnDot',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SaryrnDot')() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SaryrnDot')() or "" end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SaryrnDot')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'NukeSpell',
            Type = "Spell",
            DisplayName = function()
                local resolved = Core.GetResolvedActionMapItem(Casting.GetFirstMapItem({ "FastPoisonNuke", "PoisonNuke", "IceNuke", }))
                return resolved and resolved() or ""
            end,
            AbilityName = function()
                local resolved = Core.GetResolvedActionMapItem(Casting.GetFirstMapItem({ "FastPoisonNuke", "PoisonNuke", "IceNuke", }))
                return resolved and resolved() or ""
            end,
            AbilityRange = 150,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem(Casting.GetFirstMapItem({ "FastPoisonNuke", "PoisonNuke", "IceNuke", }))
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig']     = {
        ['Mode']                = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes do?",
            Answer =
            "Heal Mode: Primarily focuses on healing, cures, and maintaining HoTs. Secondary DPS focus with remaining spell gems. Hybrid: Prioritizes slightly more DPS at the expense of keeping a HoT, Cure Spell and second Reckless heal memorized.",
        },

        --DPS
        ['DoHealDPS']           = {
            DisplayName = "Heal Mode DPS",
            Group = "Abilities",
            Header = "Common",
            Category = "Common Rules",
            Index = 101,
            Tooltip = "This is a top-level setting that governs any DPS spells in heal mode, and can be used as a quick-toggle to enable/disable abilities without reloading spells.",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I feel that my Shaman is too concerned with DPS, dots and nukes, what can be done?",
            Answer = "Disabling Use HealDPS will stop the use of these spells. You can control which individual spells you mem with their respective settings.",
        },
        ['DoNuke']              = {
            DisplayName = "Use Nukes",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Use a level-appropriate single-target nuke.\n" ..
                "Heal Mode: We will choose one avaiable nuke: Fast Poison (Bite) > Poison (Venom) > Ice.\n" ..
                "Hybrid Mode: Uses Fast Poison (Bite) and Poison (Venom), and Ice Nuke before they are available.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoTwinHealNuke']      = {
            DisplayName = "Twin Heal Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why am I using the Twin Heal Nuke?",
            Answer =
            "Due to the nature of automation, we are likely to have the time to do so, and it helps hedge our bets against spike damage. Drivers that manually target switch may wish to disable this setting to allow for more cross-dotting. ",
        },
        ['DoPoisonDot']         = {
            DisplayName = "Use Poison DoTs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = "Use one or more mode- and level-appropriate poison dots.\n" ..
                "Heal Mode: Saryrn line is used until Chaotic line is available.\n" ..
                "Hybrid Mode: Both Curse lines are used.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoDiseaseDot']        = {
            DisplayName = "Use Disease DoTs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 102,
            Tooltip = "Use one or more mode- and level-appropriate poison dots.\n" ..
                "Heal Mode: Uses the best of Pandemic > Afflicition > Ultor on named.\n" ..
                "Hybrid Mode: Uses Pandemic and Affliction on named, and Ultor before they are available.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoCurseDot']          = {
            DisplayName = "Use Curse DoTs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 103,
            Tooltip = "Use one or more mode- and level-appropriate curse dots.\n" ..
                "Heal Mode: Curse line is used until X's Curse line is available.\n" ..
                "Hybrid Mode: Both Curse lines are used.",
            RequiresLoadoutChange = true,
            Default = true,
        },

        -- Healing
        ['DoHealOverTime']      = {
            DisplayName = "Use HoTs",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Heal Mode: Use Heal Over Time Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why does my Shaman randomly use HoTs in downtime?",
            Answer = "Maintaining HoTs prevents emergencies and hopefully allows for better DPS. It also grants Synergy Procs at high level.",
        },
        ['MemCureSpell']        = {
            DisplayName = "Mem Cure Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 101,
            Tooltip = "Mem your cure spells:\n" ..
                "Heal Mode: Prioritizes the combined cure spell. Memorizes others if able, if the combined spell isn't available.\n" ..
                "Hybrid Mode: Will memorize cure spells, if able, after other selected DPS spells have been prioritized.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoChestClick']        = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            FAQ = "What the heck is a chest click?",
            Answer = "Most classes have useful abilities on their equipped chest after level 75 or so. The SHM's is generally a healing tool (emergency group heal).",
        },
        --Canni
        ['DoAACanni']           = {
            DisplayName = "Use AA Canni",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 104,
            Tooltip = "Use Canni AA",
            Default = true,
            ConfigType = "Advanced",
        },
        ['AACanniManaPct']      = {
            DisplayName = "AA Canni Mana %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 105,
            Tooltip = "Use Canni AA Under [X]% mana",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['AACanniMinHP']        = {
            DisplayName = "AA Canni HP %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 106,
            Tooltip = "Dont Use Canni AA Under [X]% HP",
            Default = 90,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['DoSpellCanni']        = {
            DisplayName = "Use Spell Canni",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 101,
            Tooltip = "Mem and use Canni Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['SpellCanniManaPct']   = {
            DisplayName = "Spell Canni Mana %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 102,
            Tooltip = "Use Canni Spell Under [X]% mana",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['SpellCanniMinHP']     = {
            DisplayName = "Spell Canni HP %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 103,
            Tooltip = "Dont Use Canni Spell Under [X]% HP",
            Default = 85,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['DoCombatCanni']       = {
            DisplayName = "Canni in Combat",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 107,
            Tooltip = "Use Canni AA and Spells in combat",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        --Buffs
        ['UseEpic']             = {
            DisplayName = "Epic Use:",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoRunSpeed']          = {
            DisplayName = "Do Run Speed",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Do Run Speed Spells/AAs",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why are my buffers in a run speed buff war?",
            Answer = "Many run speed spells freely stack and overwrite each other, you will need to disable Run Speed Buffs on some of the buffers.",
        },
        ['DoGroupShrink']       = {
            DisplayName = "Group Shrink",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            RequiresLoadoutChange = true,
            Tooltip = "Use Group Shrink Buff",
            Default = true,
            FAQ = "Group Shrink is enabled, why are my dudes still big?",
            Answer =
            "For simplicity, the check to use it is keyed to the Shaman's height, rather than checking each group member. Also, the AA isn't available until level 80 (on official servers).",
        },
        ['DoTempHP']            = {
            DisplayName = "Temp HP Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 103,
            Tooltip = "Use Temp HP Buff on Warriors in the group.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoAura']              = {
            DisplayName = "Use Aura",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 104,
            Tooltip = "Use Aura (Pact of Wolf)",
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoRegenBuff']         = {
            DisplayName = "Regen Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 105,
            Tooltip = "Use your Regen buff (best of single or group versions).",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why am I spamming my Group Regen buff?",
            Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        },
        ['DoHaste']             = {
            DisplayName = "Use Haste",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 106,
            Tooltip = "Do Haste Spells/AAs",
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why aren't I casting Talisman of Celerity or other haste buffs?",
            Answer = "Even with Use Haste enabled, these buffs are part of your Focus spell (Unity) at very high levels, so they may not be needed.",
        },
        ['DoSelfWard']          = {
            DisplayName = "Do Self Ward",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Use your Ward of... self-heal ward buff line.",
            Default = true,
        },
        ['DoVetAA']             = {
            DisplayName = "Use Vet AA",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 102,
            Tooltip = "Use Veteran AA such as Intensity of the Resolute or Armor of Experience as necessary.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        --Debuffs
        ['DoSTMalo']            = {
            DisplayName = "Do ST Malo",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 101,
            Tooltip = "Do ST Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoAEMalo']            = {
            DisplayName = "Do AE Malo",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 102,
            Tooltip = "Do AE Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoSTSlow']            = {
            DisplayName = "Do ST Slow",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 101,
            Tooltip = "Do ST Slow Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoAESlow']            = {
            DisplayName = "Do AE Slow",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 102,
            Tooltip = "Do AE Slow Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['AESlowCount']         = {
            DisplayName = "AE Slow Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 103,
            Tooltip = "Number of XT Haters before we use AE Slow.",
            Min = 1,
            Default = 2,
            Max = 10,
            ConfigType = "Advanced",
        },
        ['AEMaloCount']         = {
            DisplayName = "AE Malo Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Index = 103,
            Tooltip = "Number of XT Haters before we use AE Malo.",
            Min = 1,
            Default = 2,
            Max = 10,
            ConfigType = "Advanced",
        },
        ['DoDiseaseSlow']       = {
            DisplayName = "Disease Slow",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 104,
            Tooltip = "Use Disease Slow instead of normal ST Slow",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
        },
        ['DiseaseSlowWaitTime'] = {
            DisplayName = "Disease Slow Wait",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 105,
            Tooltip = "Maximum amount of time (in miliseconds) to wait for Disease Slow to be ready before giving up.",
            Default = 100,
            Min = 0,
            Max = 10000,
            ConfigType = "Advanced",
        },
        ['DoLLHPBuff']          = {
            DisplayName = "HP Buff (LowLvl)",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 107,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
        },
        ['DoLLAgiBuff']         = {
            DisplayName = "Agility Buff (LowLvl)",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 108,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
        },
        ['DoLLStaBuff']         = {
            DisplayName = "Stamina Buff (LowLvl)",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 109,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
        },
        ['DoLLStrBuff']         = {
            DisplayName = "Strength Buff (LowLvl)",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 110,
            Tooltip = "Use Low Level (<= 70) HP Buffs",
            Default = false,
            ConfigType = "Advanced",
        },
        ['HealPriority']        = {
            DisplayName = "Healing Priority",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Index = 101,
            Type = "Combo",
            ComboOptions = { 'Ignore', 'Big Heal Point', 'Main Heal Point', },
            Default = 3,
            Min = 1,
            Max = 3,
            Tooltip = "When to yield offensive rotations for healing:\n1 - Ignore (never)\n2 - Big Heal Point\n3 - Main Heal Point",
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

return _ClassConfig
