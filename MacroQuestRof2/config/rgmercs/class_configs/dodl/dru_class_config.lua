local mq           = require('mq')
local Casting      = require("utils.casting")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")
local Comms        = require("utils.comms")


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
        CanCharm  = function() return true end,
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
        'Mana',
    },
    ['Cure']              = {
        ['DetDispel'] = {
            { type = "AA", name = "Radiant Cure", },
        },
        ['Poison'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'GroupCure', 'SingleTgtCure', }) end, },
        },
        ['Disease'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'GroupCure', 'SingleTgtCure', }) end, },
        },
        ['Curse'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'GroupCure', 'SingleTgtCure', }) end, },
        },
        ['Corruption'] = {
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureCorrupt', 'SingleTgtCure', }) end, },
        },
    },
    ['Themes']            = {
        ['Heal'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.08, g = 0.40, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.08, g = 0.40, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.03, g = 0.16, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.08, g = 0.40, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.08, g = 0.40, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.03, g = 0.16, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.08, g = 0.40, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.08, g = 0.40, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.08, g = 0.40, b = 0.08, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.05, g = 0.26, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.08, g = 0.40, b = 0.08, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.08, g = 0.40, b = 0.08, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.08, g = 0.40, b = 0.08, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.03, g = 0.16, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.40, g = 0.90, b = 0.20, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.40, g = 0.90, b = 0.20, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.08, g = 0.40, b = 0.08, a = 1.0, }, },
        },
        ['Mana'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.20, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.20, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.08, g = 0.14, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.20, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.20, g = 0.35, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.08, g = 0.14, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.20, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.20, g = 0.35, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.20, g = 0.35, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.13, g = 0.22, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.20, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.20, g = 0.35, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.20, g = 0.35, b = 0.05, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.08, g = 0.14, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.55, g = 0.80, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.55, g = 0.80, b = 0.15, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.20, g = 0.35, b = 0.05, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Staff of Living Brambles",
            "Staff of Everliving Brambles",
        },
    },
    ['AbilitySets']       = {
        ['Alliance'] = {
        },
        ['FireAura'] = {
            "Wildspark Aura Rk. III",
            "Wildspark Aura Rk. II",
            "Wildspark Aura",
            "Wildblaze Aura",
            "Wildfire Aura",
        },
        ['IceAura'] = {
            "Frostone Aura Rk. III",
            "Frostone Aura Rk. II",
            "Frostone Aura",
            "Frostcloak Aura",
            "Frostfell Aura",
        },
        ['HealingAura'] = {
            "Aura of the Crusader",
            "Aura of Pain",
            "Aura of Darkness",
            "Aura of Hate",
            "Aura of Reverence",
            "Aura of Devotion",
            "Aura of Runes Discipline",
            "Aura of the Muse",
            "Aura of the Pious",
            "Aura of Rage",
            "Aura of Insight",
            "Aura of the Zealot",
            "Aura of Purpose",
            "Aura of Purpose Rk. II",
            "Aura of Purpose Rk. III",
            "Aura of Draconic Runes",
            "Aura of Draconic Runes Rk. II",
            "Aura of Draconic Runes Rk. III",
            "Aura of the Artist",
            "Aura of the Artist Rk. II",
            "Aura of the Artist Rk. III",
            "Aura of Resolve",
            "Aura of Resolve Rk. II",
            "Aura of Resolve Rk. III",
            "Aura of Endless Glamour",
            "Aura of Endless Glamour Rk. II",
            "Aura of Endless Glamour Rk. III",
            "Aura of Horror",
            "Aura of Horror Rk. II",
            "Aura of Horror Rk. III",
            "Aura of the Poet",
            "Aura of the Poet Rk.II",
            "Aura of the Poet Rk.III",
            "Aura of Rodcet",
            "Aura of Rodcet Rk. II",
            "Aura of Rodcet Rk. III",
            "Aura of Loyalty",
            "Aura of Loyalty Rk. II",
            "Aura of Loyalty Rk. III",
            "Aura of Abstract Acumen",
            "Aura of Abstract Acumen Rk. II",
            "Aura of Abstract Acumen Rk. III",
            "Aura of Renewal",
            "Aura of Renewal Rk. II",
            "Aura of Renewal Rk. III",
            "Aura of the Composer",
            "Aura of the Composer Rk. II",
            "Aura of the Composer Rk. III",
            "Aura of Lunanyn",
            "Aura of Lunanyn Rk. II",
            "Aura of Lunanyn Rk. III",
            "Aura of the Orator",
            "Aura of the Orator Rk. II",
            "Aura of the Orator Rk. III",
            "Aura of the Reverent",
            "Aura of the Reverent Rk. II",
            "Aura of the Reverent Rk. III",
            "Aura of Salarra",
            "Aura of Salarra Rk. II",
            "Aura of Salarra Rk. III",
            "Aura of Va'Ker",
            "Aura of Va'Ker Rk. II",
            "Aura of Va'Ker Rk. III",
            "Aura of Divinity",
            "Aura of Divinity Rk. II",
            "Aura of Divinity Rk. III",
            "Aura of Life",
            "Aura of the Grove",
        },
        ['SingleTgtCure'] = {
            "Cleansed Blood Rk. III",
            "Cleansed Blood Rk. II",
            "Cleansed Blood",
            "Perfected Blood",
            "Purged Blood",
            "Purified Blood",
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
        ['GroupCure'] = {
        },
        ['CharmSpell'] = {
            "Command of Druzzil",
            "Commanding Voice",
            "Command of Queen Veneneu",
            "Command of Queen Veneneu Rk. II",
            "Command of Queen Veneneu Rk. III",
            "Command of Tunare",
            "Call of Karana",
            "Allure of the Wild",
            "Beguile Animals",
            "Charm Animals",
            "Befriend Animal",
        },
        ['QuickHealSurge'] = {
            "Adrenaline Rush Rk. III",
            "Adrenaline Rush Rk. II",
            "Adrenaline Rush",
            "Adrenaline Flood",
            "Adrenaline Blast",
            "Adrenaline Burst",
            "Adrenaline Swell",
            "Adrenaline Surge",
        },
        ['QuickHeal'] = {
            "Vivification Rk. III",
            "Vivification Rk. II",
            "Vivification",
            "Invigoration",
            "Rejuvilation",
        },
        ['LongHeal'] = {
            "Sterivida Rk. III",
            "Sterivida Rk. II",
            "Sterivida",
            "Sanavida",
            "Benevida",
            "Granvida",
            "Puravida",
            "Pure Life",
            "Chlorotrope",
            "Sylvan Infusion",
            "Chloroblast",
            "Superior Healing",
            "Healing Water",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['QuickGroupHeal'] = {
            "Survival of the Fortuitous Rk. III",
            "Survival of the Fortuitous Rk. II",
            "Survival of the Fortuitous",
            "Survival of the Prosperous",
            "Survival of the Propitious",
            "Survival of the Felicitous",
            "Survival of the Fittest",
        },
        ['LongGroupHeal'] = {
            "Lunassuage Rk. III",
            "Lunassuage Rk. II",
            "Lunassuage",
            "Lunalleviation",
            "Lunamelioration",
            "Lunulation",
            "Crescentbloom",
            "Lunarlight",
            "Moonshadow",
        },
        ['PromHeal'] = {
            "Promised Recovery Rk. III",
            "Promised Recovery Rk. II",
            "Promised Recovery",
            "Promised Revitalization",
            "Promised Replenishment",
            "Promised Reknit",
        },
        ['FrostDebuff'] = {
            "Lustrous Frost Rk. III",
            "Lustrous Frost Rk. II",
            "Lustrous Frost",
            "Silver Frost",
            "Argent Frost",
            "Blanched Frost",
            "Gelid Frost",
            "Hoar Frost",
        },
        ['RoDebuff'] = {
            "Clutch of Ro Rk. III",
            "Clutch of Ro Rk. II",
            "Clutch of Ro",
            "Grip of Ro",
            "Grasp of Ro",
            "Fixation of Ro",
        },
        ['RoDebuffAE'] = {
            "Pillar of Ro Rk. III",
            "Pillar of Ro Rk. II",
            "Pillar of Ro",
        },
        ['IceBreathDebuff'] = {
            "Frosthowl Breath Rk. III",
            "Frosthowl Breath Rk. II",
            "Frosthowl Breath",
            "Encompassing Breath",
            "Bracing Breath",
            "Coldwhisper Breath",
            "Chillvapor Breath",
            "Icefall Breath",
            "Glacier Breath",
        },
        ['SkinDebuff'] = {
            "Skin to Seedlings Rk. III",
            "Skin to Seedlings Rk. II",
            "Skin to Seedlings",
            "Skin to Foliage",
            "Skin to Leaves",
            "Skin to Flora",
            "Skin to Mulch",
            "Skin to Vines",
        },
        ['ReptileCombatInnate'] = {
            "Husk of the Reptile Rk. III",
            "Husk of the Reptile Rk. II",
            "Husk of the Reptile",
            "Hide of the Reptile",
            "Shell of the Reptile",
            "Carapace of the Reptile",
            "Scales of the Reptile",
            "Skin of the Reptile",
        },
        ['NaturesWrathDot'] = {
        },
        ['HordeDot'] = {
            "Horde of Mutillids Rk. III",
            "Horde of Mutillids Rk. II",
            "Horde of Mutillids",
            "Horde of Vespids",
            "Horde of Scoriae",
            "Horde of the Hive",
            "Horde of Fireants",
            "Swarm of Fireants",
            "Wasp Swarm",
            "Swarming Death",
            "Winged Death",
            "Drifting Death",
            "Drones of Doom",
            "Creeping Crud",
            "Stinging Swarm",
        },
        ['SunDot'] = {
            "Sunblaze Rk. III",
            "Sunblaze Rk. II",
            "Sunblaze",
            "Sunbrand",
            "Sunsinge",
            "Sunsear",
            "Sunscorch",
            "Sunscorch",
            "Vengeance of the Sun",
            "Vengeance of Tunare",
            "Vengeance of Nature",
            "Vengeance of the Wild",
        },
        ['MoonbeamDot'] = {
            "Frigid Moonbeam Rk. III",
            "Frigid Moonbeam Rk. II",
            "Frigid Moonbeam",
            "Algid Moonbeam",
            "Gelid Moonbeam",
        },
        ['SunrayDot'] = {
            "Incinerating Sunray Rk. III",
            "Incinerating Sunray Rk. II",
            "Incinerating Sunray",
            "Blazing Sunray",
            "Scorching Sunray",
            "Withering Sunray",
            "Torrid Sunray",
            "Blistering Sunray",
            "Immolation of the Sun",
            "Sylvan Embers",
            "Immolation of Ro",
            "Breath of Ro",
            "Immolate",
            "Flame Lick",
        },
        ['RemoteMoonDD'] = {
            "Remote Moonfire Rk. III",
            "Remote Moonfire Rk. II",
            "Remote Moonfire",
        },
        ['RemoteSunDD'] = {
            "Remote Sunfire Rk. III",
            "Remote Sunfire Rk. II",
            "Remote Sunfire",
            "Remote Sunburst",
            "Remote Sunflare",
            "Remote Manaflux",
        },
        ['RoarDD'] = {
            "Katabatic Roar Rk. III",
            "Katabatic Roar Rk. II",
            "Katabatic Roar",
            "Roar of Kolos",
        },
        ['QuickRoarDD'] = {
            "Whirlwind of the Stormborn Rk. III",
            "Whirlwind of the Stormborn Rk. II",
            "Whirlwind of the Stormborn",
            "Cyclone of the Stormborn",
            "Shear of the Stormborn",
            "Squall of the Stormborn",
            "Tempest of the Stormborn",
            "Gale of the Stormborn",
            "Stormwatch",
            "Dustdevil",
            "Fury of Air",
        },
        ['DichoSpell'] = {
        },
        ['WinterFireDD'] = {
            "Solstice Strike",
            "Sylvan Fire",
            "Wildfire",
            "Scoriae",
            "Starfire",
            "Firestrike",
            "Combust",
            "Ignite",
            "Burst of Fire",
            "Burst of Flame",
        },
        ['ChillDot'] = {
            "Frost of the Visionary III",
            "Frost of the Visionary II",
            "Frost of the Visionary",
            "Chill of the Visionary Rk. III",
            "Chill of the Visionary Rk. II",
            "Chill of the Visionary",
            "Chill of the Natureward",
        },
        ['RootSpells'] = {
            "Vinelash Assault Rk. III",
            "Vinelash Assault Rk. II",
            "Vinelash Assault",
            "Vinelash Cascade",
            "Spore Spiral",
            "Savage Roots",
            "Earthen Roots",
            "Entrapping Roots",
            "Engorging Roots",
            "Engulfing Roots",
            "Enveloping Roots",
            "Ensnaring Roots",
            "Grasping Roots",
        },
        ['SnareSpell'] = {
            "Thornmaw Vines Rk. III",
            "Thornmaw Vines Rk. II",
            "Thornmaw Vines",
            "Serpent Vines",
            "Entangle",
            "Mire Thorns",
            "Bonds of Tunare",
            "Ensnare",
            "Snare",
            "Tangling Weeds",
        },
        ['TwinHealNuke'] = {
            "Sunbeam Blessing Rk. III",
            "Sunbeam Blessing Rk. II",
            "Sunbeam Blessing",
            "Sunbreeze Blessing",
            "Sunrise Blessing",
            "Sundew Blessing",
        },
        ['IceNuke'] = {
            "Gelid Crystals Rk. III",
            "Gelid Crystals Rk. II",
            "Gelid Crystals",
            "Sterlingfrost Crystals",
            "Argent Crystals",
            "Glaciating Crystals",
            "Hoar Crystals",
            "Rime Crystals",
            "Glitterfrost",
            "Moonfire",
            "Frost",
            "Ice",
        },
        ['IceRainNuke'] = {
            "Hailstorm Rk. III",
            "Hailstorm Rk. II",
            "Hailstorm",
            "Crashing Hail",
            "Cyclonic Hail",
            "Cascading Hail",
            "Torrential Hail",
            "Cloudburst Hail",
            "Tempest Wind",
            "Blizzard",
            "Avalanche",
            "Pogonip",
            "Cascade of Hail",
        },
        ['ShroomPet'] = {
            "Sporali Assault Rk. III",
            "Sporali Assault Rk. II",
            "Sporali Assault",
            "Myconid Assault",
            "Polyporous Assault",
            "Blast of Hypergrowth",
        },
        ['IceDD'] = {
            "Moonfire Enervation",
            "Moonfire Enervation II",
            "Moonfire Enervation III",
            "Moonfire",
            "Frost",
        },
        ['SelfShield'] = {
            "Spikethistle Coat Rk. III",
            "Spikethistle Coat Rk. II",
            "Spikethistle Coat",
            "Spineburr Coat",
            "Bonebriar Coat",
            "Brierbloom Coat",
            "Viridithorn Coat",
            "Viridicoat",
            "Nettlecoat",
            "Brackencoat",
            "Bladecoat",
            "Thorncoat",
            "Spikecoat",
            "Bramblecoat",
            "Barbcoat",
            "Thistlecoat",
        },
        ['SelfManaRegen'] = {
            "Mask of the Bosquetender Rk. III",
            "Mask of the Bosquetender Rk. II",
            "Mask of the Bosquetender",
            "Mask of the Thicket Dweller",
            "Mask of the Arboreal",
            "Mask of the Raptor",
            "Mask of the Shadowcat",
            "Mask of the Wild",
            "Mask of the Forest",
            "Mask of the Stalker",
            "Mask of the Hunter",
        },
        ['HPTypeOne'] = {
            "Granitebark Blessing Rk. III",
            "Granitebark Blessing Rk. II",
            "Granitebark Blessing",
            "Stonebark Blessing",
            "Blessing of the Timbercore",
            "Blessing of the Heartwood",
            "Blessing of the Ironwood",
            "Blessing of the Direwild",
            "Blessing of Steeloak",
            "Blessing of the Nine",
            "Protection of the Glades",
            "Natureskin",
            "Protection of Nature",
            "Skin like Nature",
            "Protection of Diamond",
            "Skin like Diamond",
            "Protection of Steel",
            "Skin like Steel",
            "Protection of Rock",
            "Skin like Rock",
            "Protection of Wood",
            "Skin like Wood",
        },
        ['TempHPBuff'] = {
            "Rampant Growth Rk. III",
            "Rampant Growth Rk. II",
            "Rampant Growth",
            "Unfettered Growth",
            "Untamed Growth",
            "Wild Growth",
        },
        ['GroupRegenBuff'] = {
            "Talisman of the Steadfast Rk. III",
            "Talisman of the Steadfast Rk. II",
            "Talisman of the Steadfast",
            "Talisman of the Indomitable",
            "Talisman of the Relentless",
            "Talisman of the Resolute",
            "Talisman of the Stalwart",
            "Blessing of Oak",
            "Blessing of Replenishment",
            "Regrowth of the Grove",
            "Pack Chloroplast",
            "Pack Regeneration",
        },
        ['AtkBuff'] = {
            "Girdle of Magi`Kot",
            "Girdle of Karana",
            "Storm Strength",
            "Strength of Stone",
            "Strength of Earth",
        },
        ['GroupDmgShield'] = {
            "Legacy of Spikethistles Rk. III",
            "Legacy of Spikethistles Rk. II",
            "Legacy of Spikethistles",
            "Legacy of Spineburrs",
            "Legacy of Bonebriar",
            "Legacy of Brierbloom",
            "Legacy of Viridithorns",
            "Legacy of Viridiflora",
            "Legacy of Nettles",
            "Legacy of Bracken",
            "Legacy of Thorn",
            "Legacy of Spike",
        },
        ['MoveSpells'] = {
            "Flight of Eagles",
            "Spirit of Eagle",
            "Pack Spirit",
            "Spirit of Wolf",
        },
        ['ManaBear'] = {
            "Nurturing Growth Rk. III",
            "Nurturing Growth Rk. II",
            "Nurturing Growth",
        },
        ['PetSpell'] = {
        },
        ['RezSpell'] = {
            "Incarnate Anew",
        },
        -- ['SingleDS'] = {
        --     -- Updated to 125
        --     --Single Target Damage Shield
        --     "Bramblespike Bulwark", -- Level 122
        --     "Nightspire Bulwark",   -- Level 117
        --     "Icebriar Bulwark",     -- Level 112
        --     "Daggerspike Bulwark",  -- Level 107
        --     "Daggerspur Bulwark",   -- Level 102
        --     "Spikethistle Bulwark", -- Level 97
        --     "Spineburr Bulwark",    -- Level 92
        --     "Bonebriar Bulwark",    -- Level 87
        --     "Brierbloom Bulwark",   -- Level 82
        --     "Viridifloral Bulwark", -- Level 77
        --     "Viridifloral Shield",  -- Level 72
        --     "Nettle Shield",        -- Level 67
        --     "Shield of Bracken",    -- Level 63
        --     "Shield of Blades",     -- Level 58
        --     "Shield of Thorns",     -- Level 47
        --     "Shield of Spikes",     -- Level 37
        --     "Shield of Brambles",   -- Level 27
        --     "Shield of Barbs",      -- Level 17
        --     "Shield of Thistles",   -- Level 7
        -- },
    },
    ['HealRotationOrder'] = {
        {
            name  = 'BigHealPoint',
            state = 1,
            steps = 1,
            cond  = function(self, target) return Targeting.BigHealsNeeded(target) and not Targeting.TargetIsType("pet", target) end,
        },
        {
            name = 'GroupHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        {
            name = 'MainHealPoint',
            state = 1,
            steps = 1,
            cond = function(self, target) return Targeting.MainHealsNeeded(target) end,
        },
    },
    ['HealRotations']     = {
        ['BigHealPoint'] = {
            {
                name = "QuickHealSurge",
                type = "Spell",
            },
            {
                name = "QuickGroupHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Swarm of Fireflies",
                type = "AA",
            },
            {
                name = "Convergence of Spirits",
                type = "AA",
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['GroupHealPoint'] = {
            {
                name = "Blessing of Tunare",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "QuickGroupHeal",
                type = "Spell",
            },
            {
                name = "Wildtender's Survival",
                type = "AA",
            },
            {
                name = "LongGroupHeal",
                type = "Spell",
            },

        },
        ['MainHealPoint'] = {
            {
                name = "QuickHeal",
                type = "Spell",
            },
            {
                name = "LongHeal",
                type = "Spell",
            },
        },
    },
    ['Charm']             = {
        ['Abilities'] = {
            { name = "Dire Charm", type = "AA", },
            { name = "CharmSpell", type = "Spell", },
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
            load_cond = function(self) return Core.OnEMU() end,
            cond = function(self, combat_state)
                if not Config:GetSetting('DoPet') or mq.TLO.Me.Pet.ID() ~= 0 then return false end
                return combat_state == "Downtime" and Core.CombatActionsCheck() and Casting.OkayToPetBuff() and Casting.AmIBuffable()
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
            name = 'Debuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'TwinHeal',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoTwinHeal') and self:GetResolvedActionMapItem('TwinHealNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Config:GetSetting('DoTwinHeal') and Core.IsHealing() and
                    Targeting.GetTargetPctHPs() <= Config:GetSetting('AutoAssistAt')
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },

    },
    ['Rotations']         = {
        ['DPS'] = {
            {
                name = "SunrayDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Heal") and Config:GetSetting('DoFire') and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot') and
                        Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "ChillDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Heal") and not Config:GetSetting('DoFire') and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "Silent Casting",
                type = "AA",
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Mana") and Casting.DetAACheck(aaName) and Targeting.GetTargetPctHPs() > 75
                end,
            },
            {
                name = "SunDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") or
                        (Core.IsModeActive("Heal") and Config:GetSetting('DoFire')) and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "HordeDot",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "DichoSpell",
                type = "Spell",
                cond = function(self, spell)
                    return (Core.IsModeActive("Mana") or Config:GetSetting('DoNuke')) and Casting.DetSpellCheck(spell) and Targeting.GetTargetPctHPs() > 60 and
                        mq.TLO.Me.PctMana() > 50
                end,
            },
            {
                name = "RemoteSunDD",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Config:GetSetting('DoNuke') and
                        Targeting.GetTargetPctHPs() < Config:GetSetting('NukePct')
                end,
            },
            {
                name = "RemoteMoonDD",
                type = "Spell",
                cond = function(self, spell)
                    return not Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Config:GetSetting('DoNuke') and
                        Targeting.GetTargetPctHPs() < Config:GetSetting('NukePct')
                end,
            },
            {
                name = "MoonbeamDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot') and
                        Targeting.GetTargetLevel() >= mq.TLO.Me.Level()
                end,
            },
            {
                name = "NaturesWrathDot",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DotSpellCheck(spell) and Config:GetSetting('DoDot')
                end,
            },
            {
                name = "ShroomPet",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana")
                        and Casting.DetSpellCheck(spell) and mq.TLO.Me.PctMana() < 60
                end,
            },
            {
                name = "WinterFireDD",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.DetSpellCheck(spell) and Config:GetSetting('DoFire') and Casting.OkayToNuke()
                end,
            },
            {
                name = "IceRainNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DetSpellCheck(spell) and not Config:GetSetting('DoFire') and Config:GetSetting('DoRain') and
                        Casting.OkayToNuke()
                end,
            },
            {
                name = "IceNuke",
                type = "Spell",
                cond = function(self, spell)
                    return Core.IsModeActive("Mana") and Casting.DetSpellCheck(spell) and not Config:GetSetting('DoFire') and
                        Casting.OkayToNuke()
                end,
            },
            {
                name = "Nature's Frost",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Mana") and mq.TLO.Me.PctMana() > 50 and
                        (not Core.IsModeActive("Heal") or (Core.IsModeActive("Heal") and not Config:GetSetting('DoFire') and Casting.OkayToNuke()))
                end,
            },
            {
                name = "Nature's Fire",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() > 50 and Config:GetSetting('DoNuke') and
                        (not Core.IsModeActive("Heal") or (Core.IsModeActive("Heal") and Config:GetSetting('DoFire') and Casting.OkayToNuke()))
                end,
            },
            {
                name = "Nature's Bolt",
                type = "AA",
                cond = function(self, aaName)
                    return Core.IsModeActive("Mana") and mq.TLO.Me.PctMana() > 50
                end,
            },
        },
        ['Burn'] = {
            { --Chest Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Chest").Name() or "ChestClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoChestClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Nature's Boon",
                type = "AA",
            },
            {
                name = "Spirit of the Wood",
                type = "AA",
            },
            {
                name = "Swarm of the Fireflies",
                type = "AA",
            },
            {
                name = "Distant Conflagration",
                type = "AA",
            },
            {
                name = "Nature's Guardian",
                type = "AA",
            },
            {
                name = "Spirits of Nature",
                type = "AA",
            },
            {
                name = "Destructive Vortex",
                type = "AA",
            },
            {
                name = "Nature's Fury",
                type = "AA",
            },
            {
                name = "Spire of Nature",
                type = "AA",
            },
        },
        ['TwinHeal'] = {
            {
                name = "TwinHealNuke",
                type = "CustomFunc",
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
        },
        ['Debuff'] = {
            {
                name = "RoDebuff",
                type = "Spell",
                cond = function(self, spell) return Casting.DetSpellCheck(spell) end,
            },
            {
                name = "Blessing of Ro",
                type = "AA",
                cond = function(self, aaName, target)
                    local aaSpell = Casting.GetAASpell(aaName)
                    return Casting.DetAACheck(aaName) and Casting.ReagentCheck(aaSpell and aaSpell.Trigger(1) or aaName)
                end,
            },
            {
                name = "SkinDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and not Targeting.TargetBodyIs(target, "Undead") and
                        not Targeting.IsSummoned(target)
                end,
            },
            {
                name = "IceBreathDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Targeting.GetAutoTargetPctHPs() < Config:GetSetting('NukePct') and
                        Config:GetSetting('DoNuke')
                end,
            },
            {
                name = "FrostDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return not Config:GetSetting('DoFire') and Casting.DetSpellCheck(spell) and Targeting.GetAutoTargetPctHPs() < Config:GetSetting('NukePct') and
                        Config:GetSetting('DoNuke')
                end,
            },
            {
                name = "Entrap",
                type = "AA",
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoSnare') and Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareSpell",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Entrap") then return false end
                    return Config:GetSetting('DoSnare') and Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "Season's Wrath",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Swarm of Fireflies",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsATank(target) and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "GroupDmgShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Spirit of Eagles",
                type = "AA",
                active_cond = function(self, aaName)
                    return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1).ID())
                end,
                cond = function(self, aaName, target)
                    local bookSpell = self:GetResolvedActionMapItem('MoveSpells')
                    local aaSpell = Casting.GetAASpell(aaName)
                    if not Config:GetSetting('DoRunSpeed') or (bookSpell and bookSpell.Level() or 999) > (aaSpell.Level() or 0) then return false end

                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "MoveSpells",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    local aaSpellLvl = mq.TLO.Me.AltAbility("Spirit of Eagles").Spell.Trigger(1).Level() or 0
                    if not Config:GetSetting("DoRunSpeed") or aaSpellLvl >= (spell.Level() or 0) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "AtkBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    return Targeting.TargetIsAMelee(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "TempHPBuff",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoTempHP') then return false end
                    return Targeting.TargetClassIs("WAR", target) and Casting.GroupBuffCheck(spell, target) --PAL/SHD have their own temp hp buff
                end,
            },
            {
                name = "HPTypeOne",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoHPBuff') then return false end
                    if Casting.TargetHasBuffList(target, Casting.ClericAegoBuffs) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ReptileCombatInnate",
                type = "Spell",
                active_cond = function(self, spell) return true end,
                cond = function(self, spell, target)
                    return Targeting.TargetClassIs({ "WAR", "SHD", }, target) and Casting.GroupBuffCheck(spell, target) --does not stack with PAL innate buff
                end,
            },
            {
                name = "GroupRegenBuff",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoGroupRegen') then return false end
                    if Casting.TargetHasBuffList(target, Casting.ShamanRegenBuffs) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Wrath of the Wild",
                type = "AA",
                active_cond = function(self, aaName) return true end,
                cond = function(self, aaName, target)
                    return Targeting.TargetIsATank(target) and Casting.GroupBuffAACheck(aaName, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "SelfShield",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) end,
            },
            {
                name = "SelfManaRegen",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return Casting.SelfBuffCheck(spell) and not (spell.Name() == "Mask of the Hunter" and mq.TLO.Zone.Indoor()) end,
            },
            {
                name = "IceAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell) return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName())) end,
            },
            {
                name = "HealingAura",
                type = "Spell",
                active_cond = function(self, spell) return Casting.AuraActiveByName(spell.BaseName()) end,
                cond = function(self, spell)
                    if self:GetResolvedActionMapItem('IceAura') then return false end
                    return (spell and spell() and not Casting.AuraActiveByName(spell.BaseName()))
                end,
            },
            {
                name = "ManaBear",
                type = "Spell",
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell) return (spell and spell() and spell.MyCastTime() or 999999) < 30000 end,
            },
            {
                name = "Group Spirit of the Great Wolf",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Spirit of the Great Wolf",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Preincarnation",
                type = "AA",
                active_cond = function(self, aaName) return Casting.IHaveBuff(aaName) end,
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                active_cond = function() return mq.TLO.Me.Pet.ID() ~= 0 end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                {
                    name = "DichoSpell",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 101 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "LongHeal", },
            },
        },
        {
            gem = 2,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "QuickHeal",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 75 and
                            Core.IsModeActive("Mana")
                    end,
                },
                {
                    name = "SnareSpell",
                    cond = function(self)
                        return Config:GetSetting('DoSnare')
                            and Core.IsModeActive("Mana")
                    end,
                },
                -- [ HEAL MODE ] --
                { name = "QuickHealSurge", cond = function(self) return mq.TLO.Me.Level() >= 75 end, },
                { name = "LongHeal",       cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "WinterFireDD",   cond = function(self) return Config:GetSetting("DoFire") end, },
                { name = "IceNuke",        cond = function(self) return true end, },

            },
        },
        {
            gem = 3,
            spells = {
                -- [ MANA MODE ] --
                { name = "WinterFireDD",   cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "QuickGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 90 end, },
                { name = "CharmSpell",     cond = function(self, spell) return Config:GetSetting('CharmOn') and Core.IsSelectedCharmSpell(spell) end, },
                { name = "QuickRoarDD",    cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "IceRainNuke",    cond = function(self) return true end, },
            },
        },
        {
            gem = 4,
            spells = {
                -- [ BOTH MODES ] --
                { name = "QuickHeal",       cond = function(self) return mq.TLO.Me.Level() >= 90 end, },
                -- [ MANA MODE ] --
                { name = "QuickRoarDD",     cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "HordeDot",        cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "RoDebuff",        cond = function(self) return Config:GetSetting("DoFire") end, },
                { name = "IceBreathDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 5,
            spells = {
                -- [ MANA MODE ] --
                { name = "HordeDot",      cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "LongGroupHeal", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "SunDot",        cond = function(self) return true end, },
                { name = "SunrayDot",     cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "SunrayDot",     cond = function(self) return true end, },
            },
        },
        {
            gem = 6,
            spells = {
                -- [ BOTH MODES ] --
                {
                    name = "RemoteSunDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 and Config:GetSetting('DoFire')
                    end,
                },
                {
                    name = "RemoteMoonDD",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 83 and not Config:GetSetting('DoFire')
                    end,
                },
                -- [ MANA MODE ] --
                { name = "RoDebuff",            cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "SunrayDot",           cond = function(self) return mq.TLO.Me.Level() >= 73 end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
                { name = "SnareSpell",          cond = function(self) return Config:GetSetting('DoSnare') end, },
                -- [ Fall Back ]--
                { name = "HordeDot",            cond = function(self) return true end, },
            },
        },
        {
            gem = 7,
            spells = {
                -- [ MANA MODE ] --
                { name = "MoonbeamDot",         cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "FrostDebuff",         cond = function(self) return mq.TLO.Me.Level() >= 74 and not Config:GetSetting('DoFire') end, },
                { name = "ReptileCombatInnate", cond = function(self) return Casting.CanUseAA("Blessing of Ro") end, },
                { name = "RoDebuff",            cond = function(self) return true end, },
                -- [ Fall Back ]--
                { name = "HordeDot",            cond = function(self) return true end, },
                { name = "SnareSpell",          cond = function(self) return Config:GetSetting('DoSnare') end, },
            },
        },
        {
            gem = 8,
            spells = {
                { name = "PetSpell", cond = function(self) return Config:GetSetting('DoPet') end, },
                -- [ MANA MODE ] --
                {
                    name = "SunDot",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 49 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "RootSpells",   cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "TwinHealNuke", cond = function(self) return Config:GetSetting("DoTwinHeal") end, },
                { name = "GroupCure",    cond = function(self) return true end, },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "IceBreathDebuff",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 63 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "IceDD",           cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "SunDot",          cond = function(self) return Config:GetSetting("DoFire") end, },
                { name = "IceBreathDebuff", cond = function(self) return true end, },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                { name = "NaturesWrathDot", cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "TempHPBuff",      cond = function(self) return true end, },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                { name = "TempHPBuff",          cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "DichoSpell",          cond = function(self) return mq.TLO.Me.Level() >= 101 end, },
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                -- [ MANA MODE ] --
                {
                    name = "LongHeal",
                    cond = function(self)
                        return mq.TLO.Me.Level() >= 99 and
                            Core.IsModeActive("Mana")
                    end,
                },
                { name = "ChillDot",            cond = function(self) return Core.IsModeActive("Mana") end, },
                -- [ HEAL MODE ] --
                { name = "GroupCure",           cond = function(self) return true end, },
                { name = "ReptileCombatInnate", cond = function(self) return true end, },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Alliance", cond = function(self) return Config:GetSetting("DoAlliance") end, },
            },
        },
    },
    ['Helpers']           = {
    },
    --TODO: These are nearly all in need of Display and Tooltip updates.
    ['DefaultConfig']     = {
        ['Mode']         = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "What do the different Modes Do?",
            Answer = "Heal Mode will focus on healing and buffing.\nMana Mode will focus on DPS and Mana Management.",
        },
        --TODO: This is confusing because it is actually a choice between fire and ice and should be rewritten (need time to update conditions above)
        ['DoFire']       = {
            DisplayName = "Cast Fire Spells",
            Group = "Abilities",
            Header = "Common",
            Category = "Common Rules",
            Tooltip = "if Enabled Use Fire Spells, Disabled Use Ice Spells",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoRain']       = {
            DisplayName = "Cast Rain Spells",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Tooltip = "Use Rain Spells",
            Default = true,
        },
        ['DoRunSpeed']   = {
            DisplayName = "Use Movement Buffs",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use Run/Lev buffs.",
            Default = true,
            FAQ = "Sometimes I group with a bard and don't need to worry about Run Speed, can I disable it?",
            Answer = "Yes, you can disable [DoRunSpeed] to prevent casting Run Speed spells.",
        },
        ['DoNuke']       = {
            DisplayName = "Cast Spells",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Spells",
            Default = true,
        },
        ['NukePct']      = {
            DisplayName = "Nuke Pct",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Spells",
            Default = 90,
            Min = 1,
            Max = 100,
        },
        ['DoSnare']      = {
            DisplayName = "Cast Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Tooltip = "Enable casting Snare spells.",
            Default = true,
        },
        ['DoChestClick'] = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['DoDot']        = {
            DisplayName = "Cast DOTs",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Tooltip = "Enable casting Damage Over Time spells.",
            Default = true,
        },
        ['DoTwinHeal']   = {
            DisplayName = "Cast Twin Heal Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoHPBuff']     = {
            DisplayName = "Group HP Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use your group HP Buff. Disable as desired to prevent conflicts with CLR or PAL buffs.",
            Default = true,
            FAQ = "Why am I in a buff war with my Paladin or Druid? We are constantly overwriting each other's buffs.",
            Answer = "Disable [DoHPBuff] to prevent issues with Aego/Symbol lines overwriting. Alternatively, you can adjust the settings for the other class instead.",
        },
        ['DoTempHP']     = {
            DisplayName = "Temp HP Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use Temp HP Buff (Only for WAR, other tanks have their own)",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Why isn't my Temp HP Buff being used?",
            Answer = "You either have the Temp HP Buff disabled, or you don't have a Warrior in your group (Other tanks have their own Temp HP Buff).",
        },
        ['DoGroupRegen'] = {
            DisplayName = "Group Regen Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use your Group Regen buff.",
            Default = true,
            FAQ = "Why am I spamming my Group Regen buff?",
            Answer = "Certain Shaman and Druid group regen buffs report cross-stacking. You should deselect the option on one of the PCs if they are grouped together.",
        },
        ['HealPriority'] = {
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
                "  This config is largely a port from older code, and has seen only minor adjustments. It has been flagged for revamp when we have the chance!\n\n" ..
                "  Community effort and feedback are required for robust, resilient class configs, and PRs are highly encouraged!",
            Settings_Used = "",
        },
    },
}

return _ClassConfig
