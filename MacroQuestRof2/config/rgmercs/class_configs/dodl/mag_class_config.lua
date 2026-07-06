local mq          = require('mq')
local Casting     = require("utils.casting")
local Comms       = require("utils.comms")
local Config      = require('utils.config')
local Core        = require("utils.core")
local DanNet      = require('lib.dannet.helpers')
local Globals     = require("utils.globals")
local ItemManager = require("utils.item_manager")
local Logger      = require("utils.logger")
local Targeting   = require("utils.targeting")

_ClassConfig      = {
    _version              = "DODL CUSTOM",
    _author               = "eldudero",
    ['ModeChecks']        = {
        IsTanking = function() return Core.IsModeActive("PetTank") end,
    },
    ['Modes']             = {
        'DPS',
        'PetTank',
    },
    ['PetPosition']       = {
        SummonAA   = function() return Casting.CanUseAA("Summon Companion") and "Summon Companion" end,
        RelocateAA = function()
            local cdAA = mq.TLO.Me.AltAbility("Companion's Discipline")
            return (cdAA and cdAA.Rank() or 0) >= 4 and "Companion's Discipline"
        end,
    },
    ['OnModeChange']      = function(self, mode)
        if mode == "PetTank" then
            Core.DoCmd("/pet taunt on")
            Core.DoCmd("/pet resume on")
            -- leaving these here to show people what they may need to change when they change modes... you should use a hotbutton.
            -- RGMercs will no longer be changing others settings with abandon.
            -- Config:SetSetting('DoPetCommands', true)
            -- Config:SetSetting('AutoAssistAt', 100)
            -- Config:SetSetting('StayOnTarget', false)
            -- Config:SetSetting('DoAutoEngage', true)
            -- Config:SetSetting('DoAutoTarget', true)
            -- Config:SetSetting('AllowMezBreak', true)
        else
            Core.DoCmd("/pet taunt off")
            -- if Config:GetSetting('AutoAssistAt') == 100 then
            --     Config:SetSetting('AutoAssistAt', 98)
            -- end
        end
    end,
    ['Themes']            = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.60, g = 0.20, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.60, g = 0.20, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.24, g = 0.08, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.60, g = 0.20, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.60, g = 0.20, b = 0.02, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.24, g = 0.08, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.60, g = 0.20, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.60, g = 0.20, b = 0.02, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.60, g = 0.20, b = 0.02, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.40, g = 0.13, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.60, g = 0.20, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.60, g = 0.20, b = 0.02, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.60, g = 0.20, b = 0.02, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.24, g = 0.08, b = 0.01, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.00, g = 0.55, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.00, g = 0.55, b = 0.05, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.60, g = 0.20, b = 0.02, a = 1.0, }, },
        },
        ['PetTank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.05, g = 0.25, b = 0.55, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.05, g = 0.25, b = 0.55, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.02, g = 0.10, b = 0.22, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.05, g = 0.25, b = 0.55, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.05, g = 0.25, b = 0.55, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.02, g = 0.10, b = 0.22, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.05, g = 0.25, b = 0.55, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.05, g = 0.25, b = 0.55, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.05, g = 0.25, b = 0.55, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.03, g = 0.16, b = 0.36, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.05, g = 0.25, b = 0.55, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.05, g = 0.25, b = 0.55, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.05, g = 0.25, b = 0.55, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.02, g = 0.10, b = 0.22, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.20, g = 0.75, b = 1.00, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.20, g = 0.75, b = 1.00, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.05, g = 0.25, b = 0.55, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Focus of Primal Elements",
            "Staff of Elemental Essence",
        },
        ['OoW_Chest'] = {
        },
    },
    ['AbilitySets']       = { --TODO: Look into new TOB item summons (Boiling Orb?)
        --- Nukes
        ['SwarmPet'] = {
            "Remote Relentless Servant Rk. III",
            "Remote Relentless Servant Rk. II",
            "Remote Relentless Servant",
            "Relentless Servant Rk. III",
            "Relentless Servant Rk. II",
            "Relentless Servant",
            "Ruthless Servant",
            "Ruinous Servant",
            "Rumbling Servant",
            "Rancorous Servant",
            "Rampaging Servant",
            "Raging Servant",
            "Rage of Zomm",
        },
        ['SpearNuke'] = {
            "Spear of Blistersteel Rk. III",
            "Spear of Blistersteel Rk. II",
            "Spear of Blistersteel",
            "Spear of Molten Steel",
            "Spear of Magma",
            "Bolt of Molten Slag",
            "Spear of Ro",
        },
        ['ChaoticNuke'] = {
            "Fickle Magma Rk. III",
            "Fickle Magma Rk. II",
            "Fickle Magma",
            "Fickle Flames",
            "Fickle Flare",
            "Fickle Blaze",
            "Fickle Pyroclasm",
            "Fickle Inferno",
            "Fickle Fire",
        },
        -- ['FireNuke'] = {
        --     -- Fire Nuke 1 <= LVL <= 70
        --     "Burning Sands XIV",     -- Level 129
        --     "Cremating Sands",       -- Level 124
        --     "Ravaging Sands",        -- Level 118
        --     "Incinerating Sands",    -- Level 113
        --     "Crash of Sand",         -- Level 111
        --     "Blistering Sands",      -- Level 108
        --     "Searing Sands",         -- Level 103
        --     "Broiling Sands",        -- Level 98
        --     "Blast of Sand",         -- Level 96
        --     "Burning Sands",         -- Level 93
        --     "Burst of Sand",         -- Level 91
        --     "Strike of Sand",        -- Level 86
        --     "Torrid Sands",          -- Level 83
        --     "Scorching Sands",       -- Level 78
        --     "Scalding Sands",        -- Level 73
        --     "Star Strike",           -- Level 70
        --     "Ancient: Nova Strike",  -- Level 70
        --     "Sun Vortex",            -- Level 65
        --     "Burning Sand",          -- Level 62
        --     "Shock of Fiery Blades", -- Level 60
        --     "Char",                  -- Level 52
        --     "Blaze",                 -- Level 31
        --     "Shock of Flame",        -- Level 15
        --     "Burn",                  -- Level 4
        --     "Burst of Flame",        -- Level 1
        -- },
        -- ['FireBoltNuke'] = {
        --     "Bolt of Flame XVIII",        -- Level 126
        --     "Bolt of Molten Dacite",      -- Level 121
        --     "Bolt of Molten Olivine",     -- Level 116
        --     "Bolt of Molten Komatiite",   -- Level 111
        --     "Bolt of Skyfire",            -- Level 106
        --     "Bolt of Molten Shieldstone", -- Level 101
        --     "Bolt of Molten Magma",       -- Level 96
        --     "Bolt of Molten Steel",       -- Level 91
        --     "Bolt of Rhyolite",           -- Level 86
        --     "Bolt of Molten Scoria",      -- Level 81
        --     "Bolt of Molten Dross",       -- Level 76
        --     "Bolt of Molten Slag",        -- Level 71
        --     "Bolt of Jerikor",            -- Level 66
        --     "Firebolt of Tallon",         -- Level 61
        --     "Seeking Flame of Seukor",    -- Level 59
        --     "Scars of Sigil",             -- Level 54
        --     "Lava Bolt",                  -- Level 47
        --     "Cinder Bolt",                -- Level 33
        --     "Bolt of Flame",              -- Level 18
        --     "Flame Bolt",                 -- Level 5
        -- },
        -- ['MagicNuke'] = {
        --     -- Nuke 1 <= LVL <= 69
        --     "Shock of Blades XIX",       -- Level 127
        --     "Shock of Memorial Steel",   -- Level 122
        --     "Shock of Carbide Steel",    -- Level 117
        --     "Shock of Burning Steel",    -- Level 112
        --     "Shock of Arcronite Steel",  -- Level 107
        --     "Shock of Darksteel",        -- Level 102
        --     "Shock of Blistersteel",     -- Level 97
        --     "Shock of Argathian Steel",  -- Level 92
        --     "Shock of Ethereal Steel",   -- Level 87
        --     "Shock of Discordant Steel", -- Level 82
        --     "Shock of Cineral Steel",    -- Level 77
        --     "Shock of Silvered Steel",   -- Level 72
        --     "Blade Strike",              -- Level 68
        --     "Rock of Taelosia",          -- Level 65
        --     "Black Steel",               -- Level 63
        --     "Shock of Steel",            -- Level 57
        --     "Shock of Swords",           -- Level 41
        --     "Shock of Spikes",           -- Level 23
        --     "Shock of Blades",           -- Level 7
        -- },
        -- ['MagicBolt'] = {
        --     -- Magic Bolt Nukes
        --     "Voidstone Bolt", -- Level 123
        --     "Luclinite Bolt", -- Level 118
        --     "Komatiite Bolt", -- Level 113
        --     "Korascian Bolt", -- Level 108
        --     "Meteoric Bolt",  -- Level 103
        --     "Iron Bolt",      -- Level 98
        -- },
        ['FireDD'] = {                 --Mix of Fire Nukes and Bolts appropriate for use at lower levels.
            "Scalding Sands Rk. III",
            "Scalding Sands Rk. II",
            "Scalding Sands",
            "Burning Earth",
            "Burning Sand",
            "Scars of Sigil",
            "Lava Bolt",
            "Cinder Bolt",
            "Bolt of Flame",
            "Shock of Flame",
            "Flame Bolt",
            "Burn",
            "Burst of Flame",
        },
        ['BigFireDD'] = {              -- Longer cast time bolts we can use when mobs are at higher health.
            "Bolt of Flame",
            "Boltran's Animation",
            "Boltran's Agacerie",
            "Bolt of Molten Slag",
            "Bolt of Molten Slag Rk. II",
            "Bolt of Molten Slag Rk. III",
            "Bolt of Molten Dross",
            "Bolt of Molten Dross Rk. II",
            "Bolt of Molten Dross Rk. III",
            "Bolt of Molten Scoria",
            "Bolt of Molten Scoria Rk. II",
            "Bolt of Molten Scoria Rk. III",
            "Bolt of Rhyolite",
            "Bolt of Rhyolite Rk. II",
            "Bolt of Rhyolite Rk. III",
            "Bolt of Molten Steel",
            "Bolt of Molten Steel Rk. II",
            "Bolt of Molten Steel Rk. III",
            "Bolt of Molten Magma",
            "Bolt of Molten Magma Rk. II",
            "Bolt of Molten Magma Rk. III",
            "Bolt of Jerikor",
            "Firebolt of Tallon",
            "Seeking Flame of Seukor",
        },
        ['MagicDD'] = {                -- Magic does not have any faster casts like Fire, we have only these.
            "Bladecoat",
            "Blade of Walnan",
            "Blade of The Kedge",
            "Blade Strike",
            "Rock of Taelosia",
            "Black Steel",
            "Shock of Steel",
            "Shock of Swords",
            "Shock of Spikes",
            "Shock of Blades",
        },
        ['TwinCast'] = {
            "Twincast Rk. III",
            "Twincast Rk. II",
            "Twincast",
        },
        ['BeamNuke'] = {
            "Beam of Brimstone Rk. III",
            "Beam of Brimstone Rk. II",
            "Beam of Brimstone",
            "Beam of Molten Steel",
            "Beam of Rhyolite",
            "Beam of Molten Scoria",
            "Beam of Molten Dross",
            "Beam of Molten Slag",
        },
        ['RainNuke'] = {
            "Rain of Blistersteel Rk. III",
            "Rain of Blistersteel Rk. II",
            "Rain of Blistersteel",
            "Rain of Molten Steel",
            "Rain of Rhyolite",
            "Rain of Molten Scoria",
            "Rain of Molten Dross",
            "Rain of Molten Slag",
            "Rain of Jerikor",
            "Sun Storm",
            "Sirocco",
            "Rain of Lava",
            "Rain of Fire",
        },
        ['MagicRainNuke'] = {
            "Maelstrom of Ro",
            "Maelstrom Blade",
            "Maelstrom Blade Rk. II",
            "Maelstrom Blade Rk. III",
            "Maelstrom of Mana",
            "Maelstrom of Mana Rk. II",
            "Maelstrom of Mana Rk. III",
            "Maelstrom of Power",
            "Maelstrom of Power Rk. II",
            "Maelstrom of Power Rk. III",
            "Maelstrom of Thunder",
            "Maelstrom of Electricity",
            "ManaStorm",
            "Rain Of Swords",
            "Rain of Spikes",
            "Rain of Blades",
        },
        ['VolleyNuke'] = {
            "Salvo of Many Rk. III",
            "Salvo of Many Rk. II",
            "Salvo of Many",
            "Strike of Many",
            "Clash of Many",
            "Jolt of Many",
            "Shock of Many",
        },
        ['SummonedNuke'] = {
            "Exterminate the Unnatural Rk. III",
            "Exterminate the Unnatural Rk. II",
            "Exterminate the Unnatural",
            "Abolish the Divergent",
            "Annihilate the Divergent",
            "Annihilate the Anomalous",
            "Annihilate the Aberrant",
            "Annihilate the Unnatural",
        },
        ['MaloNuke'] = {
            "Blistersteel Malosenia Rk. III",
            "Blistersteel Malosenia Rk. II",
            "Blistersteel Malosenia",
        },
        --- Buffs
        ['SelfShield'] = {
            "Shield of the Dauntless Rk. III",
            "Shield of the Dauntless Rk. II",
            "Shield of the Dauntless",
            "Shield of Bronze",
            "Shield of Dreams",
            "Shield of the Void",
            "Prime Guard",
            "Prime Shielding",
            "Elemental Aura",
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
        ['SkinDS'] = {
            "Infernal Skin Rk. III",
            "Infernal Skin Rk. II",
            "Infernal Skin",
            "Molten Skin",
            "Blazing Skin",
            "Torrid Skin",
            "Brimstoneskin",
            "Searing Skin",
            "Scorching Skin",
            "Scorching Skin",
            "Ancient: Veil of Pyrilonus",
            "Pyrilen Skin",
        },
        ['LongDurDmgShield'] = {
            "Circle of Flameskin Rk. III",
            "Circle of Flameskin Rk. II",
            "Circle of Flameskin",
            "Flameskin",
            "Circle of Embers",
            "Embercoat",
            "Circle of Dreamfire",
            "Dreamfire Coat",
            "Circle of Brimstoneskin",
            "Brimstoneskin",
            "Circle of Lavaskin",
            "Lavaskin",
            "Circle of Magmaskin",
            "Magmaskin",
            "Circle of Fireskin",
            "Fireskin",
            "Maelstrom of Ro",
            "FlameShield of Ro",
            "Aegis of Ro",
            "Cadeau of Flame",
            "Boon of Immolation",
            "Shield of Lava",
            "Barrier of Combustion",
            "Inferno Shield",
            "Shield of Flame",
            "Shield of Fire",
        },
        ['ManaRegenBuff'] = {
            "Phantasmal Guardian Rk. III",
            "Phantasmal Guardian Rk. II",
            "Phantasmal Guardian",
            "Splendrous Guardian",
            "Cognitive Guardian",
            "Empyrean Guardian",
            "Eidolic Guardian",
            "Phantasmal Warden",
            "Phantom Shield",
        },
        ['AllianceBuff'] = {
        },
        ['SurgeDS1'] = {
            "Surge of Shadow Rk. III",
            "Surge of Shadow Rk. II",
            "Surge of Shadow",
            "Surge of Arcanum",
            "Surge of Shadowflares",
            "Surge of Thaumacretion",
        },
        ['SurgeDS2'] = {
            "Surge of Shadow Rk. III",
            "Surge of Shadow Rk. II",
            "Surge of Shadow",
            "Surge of Arcanum",
            "Surge of Shadowflares",
            "Surge of Thaumacretion",
        },
        ['PetAura'] = {
            "Arcane Distillect Rk III",
            "Arcane Distillect Rk II",
            "Arcane Distillect",
        },
        --not used
        --[[ ['SingleDS'] = {
            -- Single target Dmg Shields For Pets
            "Forgefire Coat",
            "Emberweave Coat",
            "Igneous Coat",
            "Inferno Coat",
            "Flameweave Coat",
            "Flameskin",
            "Embercoat",
            "Dreamfire Coat",
            "Brimstoneskin",
            "Lavaskin",
            "Magmaskin",
            "Fireskin",
            "FlameShield of Ro",
            "Cadeau of Flame",
            "Shield of Lava",
            "Barrier of Combustion",
            "Inferno Shield",
            "Shield of Flame",
            "Shield of Fire",
        },]] --
        ['FireShroud'] = {
            "Magmatic Veil Rk. III",
            "Magmatic Veil Rk. II",
            "Magmatic Veil",
            "Molten Veil",
            "Burning Veil",
            "Burning Pyroshroud",
            "Burning Brimbody",
            "Burning Aura",
        },
        ['PetBodyGuard'] = {
            "Groundswell Bodyguard Rk. III",
            "Groundswell Bodyguard Rk. II",
            "Groundswell Bodyguard",
            "Steelbound Bodyguard",
            "Tellurian Bodyguard",
            "Hulking Bodyguard",
        },
        ['GatherMana'] = {
            "Gather Magnitude Rk. III",
            "Gather Magnitude Rk. II",
            "Gather Magnitude",
            "Gather Capacity",
            "Gather Potential",
        },
        -- Pet Spells Pets & Spells Affecting them
        ['MeleeGuard  '] = {
            "Shield of Fate Rk. III",
            "Shield of Fate Rk. II",
            "Shield of Fate",
        },
        ['DichoSpell'] = {
        },
        ['PetHealSpell'] = {
            "Renewal of Hererra Rk. III",
            "Renewal of Hererra Rk. II",
            "Renewal of Hererra",
            "Renewal of Sirqo",
            "Renewal of Volark",
            "Renewal of Cadwin",
            "Revival of Aenro",
            "Renewal of Aenda",
            "Renewal of Jerikor",
            "Planar Renewal",
            "Refresh Summoning",
            "Renew Summoning",
            "Renew Elements",
        },
        ['PetPromisedSpell'] = {
            "Promised Amelioration Rk. III",
            "Promised Amelioration Rk. II",
            "Promised Amelioration",
            "Promised Amendment",
            "Promised Wardmending",
            "Promised Rejuvenation",
            "Promised Recovery",
        },
        ['PetStanceSpell'] = {
            "Groundswell Stance Rk. III",
            "Groundswell Stance Rk. II",
            "Groundswell Stance",
            "Steelstance",
            "Tellurian Stance",
            "Earthen Stance",
            "Grounded Stance",
            "Granite Stance",
        },
        ['PetManaConv'] = {
            "Phantasmal Symbiosis Rk. III",
            "Phantasmal Symbiosis Rk. II",
            "Phantasmal Symbiosis",
            "Arcane Symbiosis",
            "Spectral Symbiosis",
            "Ethereal Symbiosis",
            "Prime Symbiosis",
            "Elemental Symbiosis",
            "Elemental Simulacrum",
            "Elemental Siphon",
            "Elemental Draw",
        },
        ['PetHaste'] = {
            "Burnout XI Rk. III",
            "Burnout XI Rk. II",
            "Burnout XI",
            "Burnout XI",
            "Burnout IX",
            "Burnout VIII",
            "Burnout VII",
            "Burnout VI",
            "Elemental Fury",
            "Burnout V",
            "Burnout IV",
            "Elemental Empathy",
            "Burnout III",
            "Burnout II",
            "Burnout",
        },
        ['PetIceFlame'] = {
            "Iceflame Eminence Rk. III",
            "Iceflame Eminence Rk. II",
            "Iceflame Eminence",
            "Iceflame Armor",
            "Iceflame Ward",
            "Iceflame Efflux",
            "Iceflame Tenement",
            "Iceflame Body",
            "Iceflame Guard",
        },
        ['EarthPetSpell'] = {
            "Shard's Landing Gate",
            "Shard's Landing Portal",
            "Shard of Air",
            "Shard of Water",
            "Shard of Fire",
            "Shard of Earth",
            "Facet of Earth",
            "Construct of Earth",
            "Aspect of Earth",
            "Core of Earth",
            "Essence of Earth",
            "Child of Earth",
            "Greater Vocaration: Earth",
            "Vocarate: Earth",
            "Greater Conjuration: Earth",
            "Conjuration: Earth",
            "Lesser Conjuration: Earth",
            "Minor Conjuration: Earth",
            "Greater Summoning: Earth",
            "Summoning: Earth",
            "Lesser Summoning: Earth",
            "Minor Summoning: Earth",
            "Elemental: Earth",
            "Elementaling: Earth",
            "Elementalkin: Earth",
        },
        ['WaterPetSpell'] = {
            "Shard's Landing Gate",
            "Shard's Landing Portal",
            "Shard of Air",
            "Shard of Fire",
            "Shard of Earth",
            "Shard of Water",
            "Facet of Water",
            "Construct of Water",
            "Aspect of Water",
            "Core of Water",
            "Essence of Water",
            "Child of Water",
            "Servant of Marr",
            "Greater Vocaration: Water",
            "Vocarate: Water",
            "Greater Conjuration: Water",
            "Conjuration: Water",
            "Lesser Conjuration: Water",
            "Minor Conjuration: Water",
            "Greater Summoning: Water",
            "Summoning: Water",
            "Lesser Summoning: Water",
            "Minor Summoning: Water",
            "Elemental: Water",
            "Elementaling: Water",
            "Elementalkin: Water",
        },
        ['AirPetSpell'] = {
            "Shard's Landing Gate",
            "Shard's Landing Portal",
            "Shard of Water",
            "Shard of Fire",
            "Shard of Earth",
            "Shard of Air",
            "Facet of Air",
            "Construct of Air",
            "Aspect of Air",
            "Core of Air",
            "Essence of Air",
            "Child of Wind",
            "Ward of Xegony",
            "Greater Vocaration: Air",
            "Vocarate: Air",
            "Greater Conjuration: Air",
            "Conjuration: Air",
            "Lesser Conjuration: Air",
            "Minor Conjuration: Air",
            "Greater Summoning: Air",
            "Summoning: Air",
            "Lesser Summoning: Air",
            "Minor Summoning: Air",
            "Elemental: Air",
            "Elementaling: Air",
            "Elementalkin: Air",
        },
        ['FirePetSpell'] = {
            "Shard's Landing Gate",
            "Shard's Landing Portal",
            "Shard of Air",
            "Shard of Water",
            "Shard of Earth",
            "Shard of Fire",
            "Facet of Fire",
            "Construct of Fire",
            "Aspect of Fire",
            "Core of Fire",
            "Essence of Fire",
            "Child of Fire",
            "Child of Ro",
            "Greater Vocaration: Fire",
            "Vocarate: Fire",
            "Greater Conjuration: Fire",
            "Conjuration: Fire",
            "Lesser Conjuration: Fire",
            "Minor Conjuration: Fire",
            "Greater Summoning: Fire",
            "Summoning: Fire",
            "Lesser Summoning: Fire",
            "Minor Summoning: Fire",
            "Elemental: Fire",
            "Elementaling: Fire",
            "Elementalkin: Fire",
        },
        ['AegisBuff'] = {
            "Aegis of Nefori Rk. III",
            "Aegis of Nefori Rk. II",
            "Aegis of Nefori",
            "Auspice of Shadows",
            "Aegis of Kildrukaun",
            "Aegis of Calliav",
            "Bulwark of Calliav",
            "Protection of Calliav",
            "Guard of Calliav",
            "Ward of Calliav",
        },
        ['PetManaNuke'] = {
            "Thaumatize Pet Rk. III",
            "Thaumatize Pet Rk. II",
            "Thaumatize Pet",
        },
        -- ['PetArmorSummon'] = {
        --     -- >=LVL71
        --     "Grant Arcane Plate",           -- Level 127
        --     "Grant The Alloy's Plate",      -- Level 121
        --     "Grant the Centien's Plate",    -- Level 116
        --     "Grant Ocoenydd's Plate",       -- Level 111
        --     "Grant Wirn's Plate",           -- Level 106
        --     "Grant Thassis' Plate",         -- Level 101
        --     "Grant Frightforged Plate",     -- Level 96
        --     "Grant Manaforged Plate",       -- Level 91
        --     "Grant Spectral Plate",         -- Level 86
        --     "Summon Plate of the Prime",    -- Level 76
        --     "Summon Plate of the Elements", -- Level 71
        -- },
        -- ['PetWeaponSummon'] = {
        --     "Grant Arcane Armaments",        -- Level 128
        --     "Grant Goliath's Armaments",     -- Level 123
        --     "Grant Shak Dathor's Armaments", -- Level 118
        --     "Grant Yalrek's Armaments",      -- Level 113
        --     "Grant Wirn's Armaments",        -- Level 108
        --     "Grant Thassis' Armaments",      -- Level 103
        --     "Grant Frightforged Armaments",  -- Level 98
        --     "Grant Manaforged Armaments",    -- Level 93
        --     "Grant Spectral Armaments",      -- Level 88
        --     "Summon Ethereal Armaments",     -- Level 83
        --     "Summon Prime Armaments",        -- Level 78
        --     "Summon Elemental Armaments",    -- Level 73
        -- },
        -- ['PetHeirloomSummon'] = {
        --     "Grant Arcane Heirlooms",      -- Level 126
        --     "Grant Ankexfen's Heirlooms",  -- Level 121
        --     "Grant the Diabo's Heirlooms", -- Level 116
        --     "Grant Crystasia's Heirlooms", -- Level 111
        --     "Grant Ioulin's Heirlooms",    -- Level 106
        --     "Grant Calix's Heirlooms",     -- Level 101
        --     "Grant Nint's Heirlooms",      -- Level 96
        --     "Grant Atleris' Heirlooms",    -- Level 91
        --     "Grant Enibik's Heirlooms",    -- Level 86
        --     "Summon Zabella's Heirlooms",  -- Level 81
        --     "Summon Nastel's Heirlooms",   -- Level 76
        -- },
        ['IceOrbSummon'] = {
            "Grant Icebound Paradox Rk. III",
            "Grant Icebound Paradox Rk. II",
            "Grant Icebound Paradox",
            "Grant Frostrift Paradox",
            "Grant Glacial Paradox",
            "Summon Frigid Paradox",
            "Summon Gelid Paradox",
            "Summon Wintry Paradox",
        },
        ['FireOrbSummon'] = {
            "Summon Corpse",
            "Summon Waterstone",
            "Summon Food",
            "Summon Throwing Dagger",
            "Summon Arrows",
            "Summon Coldstone",
            "Summon Ring of Flight",
            "Summon Drink",
            "Summon Dagger",
            "Summon Bandages",
            "Summon Fang",
            "Summon Heatstone",
            "Summon Wisp",
            "Summon Dead",
            "Summoning: Earth",
            "Summoning: Water",
            "Summoning: Fire",
            "Summoning: Air",
            "Summon Companion",
            "Summon Shard of the Core",
            "Summon Orb",
            "Summon Brass Choker",
            "Summon Silver Choker",
            "Summon Golden Choker",
            "Summon Linen Mantle",
            "Summon Leather Mantle",
            "Summon Silken Mantle",
            "Summon Jade Bracelet",
            "Summon Opal Bracelet",
            "Summon Ruby Bracelet",
            "Summon Tiny Ring",
            "Summon Twisted Ring",
            "Summon Studded Ring",
            "Summon Tarnished Bauble",
            "Summon Shiny Bauble",
            "Summon Brilliant Bauble",
            "Summon Elemental Defender",
            "Summon Phantom Leather",
            "Summon Phantom Chain",
            "Summon Phantom Plate",
            "Summon Elemental Blanket",
            "Summon Platinum Choker",
            "Summon Runed Mantle",
            "Summon Sapphire Bracelet",
            "Summon Spiked Ring",
            "Summon Glowing Bauble",
            "Summon Jewelry Bag",
            "Summon Wooden Bracelet",
            "Summon Stone Bracelet",
            "Summon Iron Bracelet",
            "Summon Steel Bracelet",
            "Summon: Orb of Exploration",
            "Summon Calliav's Runed Mantle",
            "Summon Staff of the North Wind",
            "Summon Fireblade",
            "Summon Calliav's Jeweled Bracelet",
            "Summon Calliav's Spiked Ring",
            "Summon Calliav's Glowing Bauble",
            "Summon Calliav's Steel Bracelet",
            "Summon Calliav's Platinum Choker",
            "Summon Dagger of the Deep",
            "Summon Pouch of Jerikor",
            "Summon Sphere of Air",
            "Summon Crystal Belt",
            "Summon Wintry Paradox",
            "Summon Wintry Paradox Rk. II",
            "Summon Wintry Paradox Rk. III",
            "Summon Plate of the Elements",
            "Summon Elemental Armaments",
            "Summon Muzzle of Mowcha",
            "Summon Aenda's Trinkets",
            "Summon Gelid Paradox",
            "Summon Gelid Paradox Rk. II",
            "Summon Gelid Paradox Rk. III",
            "Summon Plate of the Prime",
            "Summon Prime Armaments",
            "Summon Nastel's Heirlooms",
            "Summon Cauldron of Many Things",
            "Summon Frigid Paradox",
            "Summon Frigid Paradox Rk. II",
            "Summon Frigid Paradox Rk. III",
            "Summon Ethereal Armaments",
            "Summon Zabella's Heirlooms",
            "Summon Cauldron of Endless Goods",
            "Summon Elemental Ore",
            "Summon Exigent Servant",
            "Summon Exigent Servant Rk. II",
            "Summon Exigent Servant Rk. III",
            "Summon Servant",
            "Summon Servant II",
            "Summon Servant III",
            "Summon Exigent Minion",
            "Summon Exigent Minion Rk. II",
            "Summon Exigent Minion Rk. III",
            "Summon Minion",
            "Summon Minion II",
            "Summon Minion III",
            "Summon Imperious Servant",
            "Summon Imperious Servant Rk. II",
            "Summon Imperious Servant Rk. III",
            "Summon Imperious Minion",
            "Summon Imperious Minion Rk. II",
            "Summon Imperious Minion Rk. III",
            "Summon Cauldron of Endless Bounty",
            "Summon Cauldron of Endless Bounty Rk. II",
            "Summon Cauldron of Endless Bounty Rk. III",
            "Summon Blazing Orb",
            "Summon: Molten Orb",
            "Summon: Lava Orb",
        },
        ['EarthPetItemSummon'] = {
            "Summon Imperious Servant Rk. III",
            "Summon Imperious Servant Rk. II",
            "Summon Imperious Servant",
            "Summon Exigent Servant",
        },
        ['FirePetItemSummon'] = {
            "Summon Imperious Minion Rk. III",
            "Summon Imperious Minion Rk. II",
            "Summon Imperious Minion",
            "Summon Exigent Minion",
        },
        ['ManaRodSummon'] = {               -- Level 44 - 105
            "Mass Arcane Transvergence Rk. III",
            "Mass Arcane Transvergence Rk. II",
            "Mass Arcane Transvergence",
            "Mass Spectral Transvergence",
            "Mass Ethereal Transvergence",
            "Mass Prime Transvergence",
            "Mass Elemental Transvergence",
            "Mass Mystical Transvergence",
            "Modulating Rod",
        },
        ['SelfManaRodSummon'] = {
            "Wand of Phantasmal Modulation Rk. III",
            "Wand of Phantasmal Modulation Rk. II",
            "Wand of Phantasmal Modulation",
        },
        -- - Debuffs
        ['MaloDebuff'] = {
            "Malosenia Rk. III",
            "Malosenia Rk. II",
            "Malosenia",
            "Maloseneta",
            "Malosene",
            "Malosenea",
            "Malosinatia",
            "Malosinise",
            "Malosinia",
            "Mala",
            "Malosini",
            "Malosi",
            "Malaisement",
            "Malaise",
        },
        ['SingleCotH'] = {
            "Call of Bones",
            "Call of Flame",
            "Call of Sky",
            "Call of Earth",
            "Call of Fire",
            "Call of the Predator",
            "Call of Karana",
            "Call of the Banshee",
            "Call of the Rathe",
            "Call of the Arch Mage",
            "Call of Ice",
            "Call of Darkness",
            "Call of the Muse",
            "Call of Lightning",
            "Call for Blood",
            "Call Skeleton Swarm",
            "Call Skeleton Swarm Rk. II",
            "Call Skeleton Swarm Rk. III",
            "Called Shots",
            "Called Shots Rk. II",
            "Called Shots Rk. III",
            "Call of Dusk",
            "Call of Dusk Rk. II",
            "Call of Dusk Rk. III",
            "Call the Pack",
            "Call the Pack II",
            "Call the Pack III",
            "Call Skeleton Crush",
            "Call Skeleton Crush Rk. II",
            "Call Skeleton Crush Rk. III",
            "Callous Ferocity",
            "Callous Ferocity Rk. II",
            "Callous Ferocity Rk. III",
            "Call of Shadow",
            "Call of Shadow Rk. II",
            "Call of Shadow Rk. III",
            "Call Skeleton Host",
            "Call Skeleton Host Rk. II",
            "Call Skeleton Host Rk. III",
            "Call of Gloomhaze",
            "Call of Gloomhaze Rk. II",
            "Call of Gloomhaze Rk. III",
            "Call Skeleton Throng",
            "Call Skeleton Throng Rk. II",
            "Call Skeleton Throng Rk. III",
            "Call of the Heroes",
            "Call of the Heroes Rk. II",
            "Call of the Heroes Rk. III",
            "Call of the Hero",
        },
        ['GroupCotH'] = {
            "Call of the Heroes Rk. III",
            "Call of the Heroes Rk. II",
            "Call of the Heroes",
        },
        ['EpicPetOrb'] = {
            "Summon Corpse",
            "Summon Waterstone",
            "Summon Food",
            "Summon Throwing Dagger",
            "Summon Arrows",
            "Summon Coldstone",
            "Summon Ring of Flight",
            "Summon Drink",
            "Summon Dagger",
            "Summon Bandages",
            "Summon Fang",
            "Summon Heatstone",
            "Summon Wisp",
            "Summon Dead",
            "Summoning: Earth",
            "Summoning: Water",
            "Summoning: Fire",
            "Summoning: Air",
            "Summon Companion",
            "Summon Shard of the Core",
            "Summon Brass Choker",
            "Summon Silver Choker",
            "Summon Golden Choker",
            "Summon Linen Mantle",
            "Summon Leather Mantle",
            "Summon Silken Mantle",
            "Summon Jade Bracelet",
            "Summon Opal Bracelet",
            "Summon Ruby Bracelet",
            "Summon Tiny Ring",
            "Summon Twisted Ring",
            "Summon Studded Ring",
            "Summon Tarnished Bauble",
            "Summon Shiny Bauble",
            "Summon Brilliant Bauble",
            "Summon Elemental Defender",
            "Summon Phantom Leather",
            "Summon Phantom Chain",
            "Summon Phantom Plate",
            "Summon Elemental Blanket",
            "Summon Platinum Choker",
            "Summon Runed Mantle",
            "Summon Sapphire Bracelet",
            "Summon Spiked Ring",
            "Summon Glowing Bauble",
            "Summon Jewelry Bag",
            "Summon Wooden Bracelet",
            "Summon Stone Bracelet",
            "Summon Iron Bracelet",
            "Summon Steel Bracelet",
            "Summon: Orb of Exploration",
            "Summon Calliav's Runed Mantle",
            "Summon Staff of the North Wind",
            "Summon Fireblade",
            "Summon Calliav's Jeweled Bracelet",
            "Summon Calliav's Spiked Ring",
            "Summon Calliav's Glowing Bauble",
            "Summon Calliav's Steel Bracelet",
            "Summon Calliav's Platinum Choker",
            "Summon Dagger of the Deep",
            "Summon Pouch of Jerikor",
            "Summon Sphere of Air",
            "Summon Crystal Belt",
            "Summon: Molten Orb",
            "Summon: Lava Orb",
            "Summon Wintry Paradox",
            "Summon Wintry Paradox Rk. II",
            "Summon Wintry Paradox Rk. III",
            "Summon Plate of the Elements",
            "Summon Elemental Armaments",
            "Summon Muzzle of Mowcha",
            "Summon Aenda's Trinkets",
            "Summon Gelid Paradox",
            "Summon Gelid Paradox Rk. II",
            "Summon Gelid Paradox Rk. III",
            "Summon Plate of the Prime",
            "Summon Prime Armaments",
            "Summon Nastel's Heirlooms",
            "Summon Cauldron of Many Things",
            "Summon Frigid Paradox",
            "Summon Frigid Paradox Rk. II",
            "Summon Frigid Paradox Rk. III",
            "Summon Ethereal Armaments",
            "Summon Zabella's Heirlooms",
            "Summon Cauldron of Endless Goods",
            "Summon Elemental Ore",
            "Summon Exigent Servant",
            "Summon Exigent Servant Rk. II",
            "Summon Exigent Servant Rk. III",
            "Summon Servant",
            "Summon Servant II",
            "Summon Servant III",
            "Summon Blazing Orb",
            "Summon Exigent Minion",
            "Summon Exigent Minion Rk. II",
            "Summon Exigent Minion Rk. III",
            "Summon Minion",
            "Summon Minion II",
            "Summon Minion III",
            "Summon Imperious Servant",
            "Summon Imperious Servant Rk. II",
            "Summon Imperious Servant Rk. III",
            "Summon Imperious Minion",
            "Summon Imperious Minion Rk. II",
            "Summon Imperious Minion Rk. III",
            "Summon Cauldron of Endless Bounty",
            "Summon Cauldron of Endless Bounty Rk. II",
            "Summon Cauldron of Endless Bounty Rk. III",
            "Summon Orb",
        },
    },
    ['HealRotationOrder'] = {

    },
    ['Charm']             = {
        ['Assist'] = {
            {
                name = "Malaise",
                type = "AA",
                load_cond = function() return Casting.CanUseAA("Malaise") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName, target)
                end,
            },
            {
                name = "MaloDebuff",
                type = "Spell",
                load_cond = function() return not Casting.CanUseAA("Malaise") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell, target)
                end,
            },
        },
    },
    ['RotationOrder']     = {
        {
            name = 'PetSummon',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToPetBuff() and mq.TLO.Me.Pet.ID() == 0 and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.OkayToBuff() and Casting.AmIBuffable()
            end,
        },
        { --Pet Buffs if we have one, timer because we don't need to constantly check this. Timer lowered for mage due to high volume of actions
            name = 'PetBuff',
            timer = 10,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
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
            name = 'PetHealing',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, target) return (mq.TLO.Me.Pet.PctHPs() or 100) < Config:GetSetting('PetHealPct') end,
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
        {
            name = 'Malo',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoMalo') or Config:GetSetting('DoAEMalo') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff()
            end,
        },
        {
            name = 'DPS PET',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsModeActive("PetTank") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'Weaves',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'SkinDS',
            state = 1,
            steps = 1,
            load_cond = function(self) return Config:GetSetting('DoSkinDS') and self:GetResolvedActionMapItem('SkinDS') end,
            targetId = function(self) return { Core.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS(LowLevel)',
            state = 1,
            steps = 1,
            load_cond = function(self) return not self:GetResolvedActionMapItem('ChaoticNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToNuke()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function(self) return self:GetResolvedActionMapItem('ChaoticNuke') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToNuke()
            end,
        },
        {
            name = 'Summon ModRods',
            timer = 120, --this will only be checked once every 2 minutes
            state = 1,
            steps = 2,
            load_cond = function() return Config:GetSetting('SummonModRods') and Core.GetResolvedActionMapItem("ManaRodSummon") end,
            targetId = function(self)
                local groupIds = {}
                if not Core.OnEMU() or mq.TLO.Me.Inventory("MainHand")() then
                    table.insert(groupIds, mq.TLO.Me.ID())
                end
                local count = mq.TLO.Group.Members()
                for i = 1, count do
                    local mainHand = DanNet.query(mq.TLO.Group.Member(i).DisplayName(), "Me.Inventory[MainHand]", 1000)
                    if Core.OnEMU() and (mainHand and mainHand:lower() == "null") then
                        groupIds = {}
                        Logger.log_debug("%s has no weapon equipped, aborting ModRod summon to avoid corpse-looting conflicts.", mq.TLO.Group.Member(i).DisplayName())
                        break
                    else
                        table.insert(groupIds, mq.TLO.Group.Member(i).ID())
                    end
                end
                return groupIds
            end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and Casting.OkayToBuff()
                local pct = Config:GetSetting('GroupManaPct')
                local combat = combat_state == "Combat" and Config:GetSetting('CombatModRod') and (mq.TLO.Group.LowMana(pct)() or -1) >= Config:GetSetting('GroupManaCt')
                return downtime or combat
            end,
        },
    },
    -- Really the meat of this class.
    ['Helpers']           = {
        user_tu_spell = function(self, aaName)
            local shroudSpell = self.ResolvedActionMap['ShroudSpell']
            local aaSpell = Casting.GetAASpell(aaName)
            if not shroudSpell or not shroudSpell() or not aaSpell or not aaSpell() or not Casting.CanUseAA(aaName) then return false end
            -- do we need to lookup the spell basename here? I dont think so but if this doesn't fire right take a look.
            if shroudSpell.Level() > aaSpell.Level() then return false end
            return true
        end,
        DeleteEpicOrb = function(self)
            if mq.TLO.Cursor() and mq.TLO.Cursor.ID() > 0 then
                Core.DoCmd("/autoinventory")
                mq.delay(50, function() return mq.TLO.Cursor() == nil end)
            end
            if not mq.TLO.Cursor() then
                Core.DoCmd("/nomodkey /itemnotify \"Orb of Mastery\" leftmouseup")
                mq.delay(50, function() return mq.TLO.Cursor() ~= nil end)
                if mq.TLO.Cursor() then
                    if mq.TLO.Cursor.ID() == 28034 then
                        Core.DoCmd("/destroy")
                        mq.delay(50, function() return mq.TLO.Cursor() == nil end)
                        if not mq.TLO.FindItem("28034")() then
                            return true
                        end
                    else
                        Logger.log_warning("Warning: We seem to have something else on the cursor! Do you have another item named 'Orb of Mastery'? Aborting delete.")
                    end
                end
            end
            Logger.log_warning("Warning: Mage pet orb not destroyed! An error or conflict has occured.")
            return false
        end,
        HandleItemSummon = function(self, itemSource, scope) --scope: "personal" or "group" summons
            if not itemSource and itemSource() then return false end
            if not scope then return false end

            mq.delay("2s", function() return mq.TLO.Cursor() ~= nil and mq.TLO.Cursor.ID() == mq.TLO.Spell(itemSource).RankName.Base(1)() or false end)

            if not mq.TLO.Cursor() then
                Logger.log_debug("No valid item found on cursor, item handling aborted.")
                return false
            end

            Logger.log_debug("Sending the %s to our bags.", mq.TLO.Cursor())

            local itemId = mq.TLO.Cursor.ID()
            if scope == "group" then
                ItemManager.BroadcastQueueAutoInv(itemId)
            elseif scope == "personal" then
                ItemManager.QueueAutoInv(itemId)
            else
                Logger.log_debug("Invalid scope sent: (%s). Item handling aborted.", scope)
                return false
            end
        end,
    },
    ['Rotations']         = {
        ['PetSummon'] = {
            {
                name = "Orb of Mastery",
                type = "Item",
                load_cond = function(self) return Config:GetSetting("UseEpicPet") and mq.TLO.Me.Book("Summon Orb")() end,
                active_cond = function(self, _) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, itemName, target)
                    local orb = mq.TLO.FindItem("28034")
                    return orb() and (orb.Charges() or 0) > 0
                end,
                post_activate = function(self, itemName, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50)
                        self:SetPetHold()
                        self.Helpers.DeleteEpicOrb(self)
                    end
                end,
            },
            {
                name_func = function(self)
                    return string.format("%sPetSpell", self.ClassConfig.DefaultConfig.PetType.ComboOptions[Config:GetSetting('PetType')])
                end,
                type = "Spell",
                load_cond = function(self)
                    return not Config:GetSetting("UseEpicPet") or not mq.TLO.Me.Book("Summon Orb")()
                end,
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
        ['PetBuff'] = {
            {
                name = "PetIceFlame",
                type = "Spell",
                active_cond = function(self, spell)
                    return mq.TLO.Me.PetBuff(spell.RankName.Name())() ~= nil or mq.TLO.Me.PetBuff(spell.Name())() ~= nil
                end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetHaste",
                type = "Spell",
                active_cond = function(self, spell)
                    return mq.TLO.Me.PetBuff(spell.RankName.Name())() ~= nil or mq.TLO.Me.PetBuff(spell.Name())() ~= nil
                end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "PetManaConv",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName)
                    if mq.TLO.Me.Pet.ID() == 0 then return false end
                    return Casting.PetBuffItemCheck(itemName)
                end,
            },
            {
                name = "Second Wind Ward",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Host in the Shell",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Companion's Aegis",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
            {
                name = "Companion's Intervening Divine Aura",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.PetBuffAACheck(aaName)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "EarthPetItemUse",
                type = "CustomFunc",
                cond = function(self)
                    if not self.ResolvedActionMap['EarthPetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['EarthPetItemSummon'].RankName.Base(1)()
                    return mq.TLO.FindItemCount(baseItem)() >= 1
                end,
                custom_func = function(self)
                    if not self.ResolvedActionMap['EarthPetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['EarthPetItemSummon'].RankName.Base(1)()
                    if mq.TLO.FindItemCount(baseItem)() >= 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return Casting.UseItem(invItem.Name(), Globals.AutoTargetID)
                    end

                    return false
                end,
            },
            {
                name = "FirePetItemUse",
                type = "CustomFunc",
                cond = function(self)
                    if not self.ResolvedActionMap['FirePetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['FirePetItemSummon'].RankName.Base(1)()
                    return mq.TLO.FindItemCount(baseItem)() >= 1
                end,
                custom_func = function(self)
                    if not self.ResolvedActionMap['FirePetItemSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['FirePetItemSummon'].RankName.Base(1)()
                    if mq.TLO.FindItemCount(baseItem)() >= 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return Casting.UseItem(invItem.Name(), Globals.AutoTargetID)
                    end

                    return false
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
                name = "AllianceBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    return Globals.AutoTargetIsNamed and not Casting.TargetHasBuff(spell) and
                        Config:GetSetting('DoAlliance') and Casting.CanAlliance()
                end,
            },
            {
                name = "Companion's Fury",
                type = "AA",
            },
            {
                name = "Host of the Elements",
                type = "AA",
            },
            {
                name = "Spire of Elements",
                type = "AA",
            },
            {
                name = "Heart of Skyfire",
                type = "AA",
            },
            {
                name = "Focus of Arcanum",
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
                name = "TwinCast",
                type = "Spell",
                cond = function(self)
                    return not mq.TLO.Me.Buff("Twincast")()
                end,
            },
            {
                name = "Servant of Ro",
                type = "AA",
            },
        },
        ['DPS PET'] = {
            {
                name = "OoW_Chest",
                type = "Item",
                cond = function(self, spell)
                    return Core.IsModeActive("PetTank")
                end,
            },
            {
                name = "PetStanceSpell",
                type = "Spell",
                cond = function(self, spell)
                    local chestBuff = Casting.GetClickySpell(Core.GetResolvedActionMapItem('OoW_Chest'))
                    return Core.IsModeActive("PetTank") and mq.TLO.Me.Pet.PctHPs() <= 95 and Casting.PetBuffCheck(spell) and not mq.TLO.Me.PetBuff(chestBuff and chestBuff() or "")()
                end,
            },
            {
                name = "SurgeDS1",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "SurgeDS2",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "SkinDS",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
            {
                name = "FireShroud",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
        },
        ['Weaves'] = {
            {
                name = "Force of Elements",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoForce')
                end,
            },
            {
                name = "FireOrbItem",
                type = "CustomFunc",
                custom_func = function(self)
                    if not self.ResolvedActionMap['FireOrbSummon'] then return false end
                    local baseItem = self.ResolvedActionMap['FireOrbSummon'].RankName.Base(1)() or "None"
                    if mq.TLO.FindItemCount(baseItem)() == 1 then
                        local invItem = mq.TLO.FindItem(baseItem)
                        return Casting.UseItem(invItem.Name(), Globals.AutoTargetID)
                    end
                    return false
                end,
            },
        },
        ['DPS'] = {
            {
                name = "SwarmPet",
                type = "Spell",
            },
            {
                name = "VolleyNuke",
                type = "Spell",
            },
            {
                name = "ChaoticNuke",
                type = "Spell",
            },
            {
                name = "Turn Summoned",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsSummoned(target)
                end,
            },
            {
                name = "SummonedNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSummonedNuke') end,
                cond = function(self, spell, target)
                    return Targeting.IsSummoned(target)
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
            },
            {
                name = "FireDD",
                type = "Spell",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('SpearNuke') end,
            },
        },
        ['DPS(LowLevel)'] = {
            {
                name = "SummonedNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoSummonedNuke') end,
                cond = function(self, spell, target)
                    return Targeting.IsSummoned(target)
                end,
            },
            {
                name = "BigFireDD",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('ElementChoice') ~= 1 then return false end
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "FireDD",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.MobHasLowHP(target) or not Core.GetResolvedActionMapItem("BigFireDD")
                end,
            },
            {
                name = "MagicDD",
                type = "Spell",
                cond = function(self, spell, target)
                    return Config:GetSetting('ElementChoice') == 2
                end,
            },
            {
                name = "Turn Summoned",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.IsSummoned(target)
                end,
            },
        },
        ['Malo'] = {
            {
                name = "Malaise",
                type = "AA",
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "MaloDebuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Casting.CanUseAA("Malaise") then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "Wind of Malaise",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoAEMalo') then return false end
                    return Casting.DetAACheck(aaName)
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "LongDurDmgShield",
                type = "Spell",
                active_cond = function(self, spell)
                    return Casting.IHaveBuff(spell)
                end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Elemental Conversion",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= Config:GetSetting('GatherManaPct') and mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctMana() <= Config:GetSetting('GatherManaPct') and not mq.TLO.Me.SpellReady(self.ResolvedActionMap['GatherMana'] or "")() and
                        mq.TLO.Me.Pet.ID() > 0
                end,
            },
            {
                name = "GatherMana",
                type = "Spell",
                cond = function(self, spell)
                    return spell and spell() and mq.TLO.Me.PctMana() <= Config:GetSetting('GatherManaPct') and Casting.CastReady(spell)
                end,
            },
            {
                name = "ManaRegenBuff",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfShield",
                type = "Spell",
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Thaumaturge's Unity",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "EpicPetOrb",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end,
                cond = function(self, spell, target)
                    return not mq.TLO.FindItem("28034")()
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "Delete Used Epic Orb",
                type = "CustomFunc",
                load_cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end,
                cond = function(self)
                    local orb = mq.TLO.FindItem("28034")
                    return orb() and (orb.Charges() or 999) == 0
                end,
                custom_func = function(self) return self.Helpers.DeleteEpicOrb(self) end,
            },
            {
                name = "PetAura",
                type = "Spell",
                active_cond = function(self, spell)
                    return Casting.AuraActiveByName(spell.BaseName()) ~= nil
                end,
                cond = function(self, spell)
                    return not Casting.AuraActiveByName(spell.BaseName())
                end,
            },
            {
                name = "FireOrbSummon",
                type = "Spell",
                cond = function(self, spell)
                    if not spell() then return false end
                    local myId = Casting.GetUseableSpellId(spell) -- Adjust for possible unsubbed accounts
                    local baseItem = mq.TLO.Spell(myId).Base(1)() or 0
                    return baseItem > 0 and mq.TLO.FindItemCount(baseItem)() == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "EarthPetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    if not spell() then return false end
                    local myId = Casting.GetUseableSpellId(spell) -- Adjust for possible unsubbed accounts
                    local baseItem = mq.TLO.Spell(myId).Base(1)() or 0
                    return baseItem > 0 and mq.TLO.FindItemCount(baseItem)() == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "FirePetItemSummon",
                type = "Spell",
                cond = function(self, spell)
                    if not spell() then return false end
                    local myId = Casting.GetUseableSpellId(spell) -- Adjust for possible unsubbed accounts
                    local baseItem = mq.TLO.Spell(myId).Base(1)() or 0
                    return baseItem > 0 and mq.TLO.FindItemCount(baseItem)() == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
            {
                name = "Elemental Form",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName, false, true)
                end,
            },
            {
                name = "Fire Core",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },

        },
        ['Summon ModRods'] = {
            {
                name = "Summon Modulation Shard",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Config:GetSetting('SummonModRods') or not Casting.CanUseAA(aaName) or not Targeting.TargetIsACaster(target) then return false end
                    local modRodItem = mq.TLO.Spell(aaName).RankName.Base(1)()
                    return modRodItem and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", modRodItem), 1000) == "0" and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, aaName, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, aaName, "group")
                    end
                end,
            },
            {
                name = "ManaRodSummon",
                type = "Spell",
                cond = function(self, spell, target)
                    if not spell() then return false end
                    if Casting.CanUseAA("Summon Modulation Shard") or not Config:GetSetting('SummonModRods') or not Targeting.TargetIsACaster(target) then return false end
                    local myId = Casting.GetUseableSpellId(spell) -- Adjust for possible unsubbed accounts
                    local modRodItemId = mq.TLO.Spell(myId).Base(1)() or 0
                    return (mq.TLO.Spell(myId).Base(1)() or 0) > 0 and DanNet.query(target.CleanName(), string.format("FindItemCount[%d]", modRodItemId), 1000) == "0" and
                        (mq.TLO.Cursor.ID() or 0) == 0
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, spell, "group")
                    end
                end,
            },
            {
                name = "SelfManaRodSummon",
                type = "Spell",
                cond = function(self, spell, target, combat_state)
                    if target.ID() ~= mq.TLO.Me.ID() or not spell() then return false end
                    local myId = Casting.GetUseableSpellId(spell) -- Adjust for possible unsubbed accounts
                    local modRodItemId = mq.TLO.Spell(myId).Base(1)() or 0
                    return modRodItemId > 0 and mq.TLO.FindItemCount(modRodItemId)() == 0 and (mq.TLO.Cursor.ID() or 0) == 0 and
                        not (combat_state == "Combat" and mq.TLO.Me.PctMana() > Config:GetSetting('GroupManaPct'))
                end,
                post_activate = function(self, spell, success)
                    if success then
                        Core.SafeCallFunc("Autoinventory", self.Helpers.HandleItemSummon, self, spell, "personal")
                    end
                end,
            },
        },
        ['SkinDS'] = {
            {
                name = "SkinDS",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end
                    return Casting.GroupBuffCheck(spell, target, false, true)
                end,
            },
        },
    },
    ['Spells']            = {
        {
            gem = 1,
            spells = {
                { name = "SpearNuke", },
                { name = "FireDD", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "ChaoticNuke", },
                { name = "BigFireDD", },
            },
        },
        {
            gem = 3,
            spells = {

                { name = "SwarmPet", cond = function(self) return mq.TLO.Me.Level() >= 70 end, },
                { name = "MagicDD", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "VolleyNuke", },
                { name = "EpicPetOrb",   cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end, },
                { name = "PetHealSpell", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "TwinCast", },
                { name = "MaloDebuff",       cond = function(self) return Config:GetSetting('DoMalo') and not Casting.CanUseAA("Malaise") end, },
                { name = "EpicPetOrb",       cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end, },
                { name = "PetHealSpell", },
                { name = "SkinDS",           cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "SummonedNuke",     cond = function(self) return Config:GetSetting('DoSummonedNuke') end, },
                { name = "EpicPetOrb",       cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end, },
                { name = "PetHealSpell", },
                { name = "GroupCotH", },
                { name = "ManaRodSummon", },
                { name = "SkinDS",           cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "FireOrbSummon", },
                { name = "EpicPetOrb",       cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end, },
                { name = "PetHealSpell", },
                { name = "SkinDS",           cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 8,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name_func = function(self) return string.format("%sPetSpell", self.ClassConfig.DefaultConfig.PetType.ComboOptions[Config:GetSetting('PetType')]) end, },
                { name = "PetManaNuke", },
                { name = "EpicPetOrb",       cond = function(self) return Config:GetSetting('UseEpicPet') and mq.TLO.Me.Book("Summon Orb")() end, },
                { name = "PetHealSpell", },
                { name = "SingleCotH",       cond = function() return not Casting.CanUseAA('Call of the Hero') end, },
                { name = "SkinDS",           cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 9,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "GatherMana", },
                { name = "PetHealSpell", },
                { name = "SkinDS",           cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 10,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "EarthPetItemSummon", },
                { name = "PetHealSpell", },
                { name = "SkinDS",             cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "FirePetItemSummon", },
                { name = "PetHealSpell", },
                { name = "SkinDS",            cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SelfManaRodSummon", },
                { name = "PetHealSpell", },
                { name = "SkinDS",            cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "PetHealSpell", },
                { name = "SkinDS",           cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "GroupCotH", },
                { name = "LongDurDmgShield", },
            },
        },
        {
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "SkinDS",       cond = function(self) return Config:GetSetting('DoSkinDS') end, },
                { name = "PetHealSpell", },
                { name = "GroupCotH", },
            },
        },
    },
    ['DefaultConfig']     = {
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What is the difference between the modes?",
            Answer = "Fire Mode will use Fire Nukes and strive for DPS.\n" ..
                "PetTank mode will Focus on keeping the Pet alive as the main tank.",
        },
        ['PetType']        = {
            DisplayName = "Pet Type",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Summoning",
            Index = 101,
            Tooltip = "Choose the elemental to summon when not using the epic pet.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Water', 'Earth', 'Air', },
            Default = 2,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseEpicPet']     = {
            DisplayName = "Summon Epic Pet",
            Group = "Abilities",
            Header = "Pet",
            Category = "Pet Summoning",
            Index = 102,
            Tooltip = "Use your Orb of Mastery to summon the epic pet.",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoPetHealSpell'] = {
            DisplayName = "Pet Heal Spell",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Mem and cast your Pet Heal spell. AA Pet Heals are always used in emergencies.",
            Default = true,
            RequiresLoadoutChange = true,
        },
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
        ['SelfModRod']     = {
            DisplayName = "Self Mod Rod Item",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Tooltip = "Click the modrod clicky you want to use here",
            Type = "ClickyItem",
            Default = "",
        },
        ['SummonModRods']  = {
            DisplayName = "Summon Mod Rods",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 101,
            Tooltip = "Summon Mod Rods",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['GatherManaPct']  = {
            DisplayName = "Gather Mana %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Tooltip = "When to use Gather Mana",
            Default = 70,
            Min = 1,
            Max = 99,
        },
        ['DoForce']        = {
            DisplayName = "Do Force",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 103,
            Tooltip = "Use Force of Elements AA.",
            Default = true,
        },
        ['ElementChoice']  = {
            DisplayName = "Element Choice:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Choose an element to focus on under level 71.",
            Type = "Combo",
            ComboOptions = { 'Fire', 'Magic', },
            Default = 1,
            Min = 1,
            Max = 2,
            RequiresLoadoutChange = true,
        },
        ['DoSummonedNuke'] = {
            DisplayName = "Do Summoned Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = "Memorize and use your anti-summoned mob nuke line ('x the Unnatural').",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Click your chest item",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['DoMalo']         = {
            DisplayName = "Cast Malo",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Tooltip = "Do Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoAEMalo']       = {
            DisplayName = "Cast AE Malo",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Resist",
            Tooltip = "Do AE Malo Spells/AAs",
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['CombatModRod']   = {
            DisplayName = "Combat Mod Rods",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 102,
            Tooltip = "Summon Mod Rods in combat if the criteria below are met.",
            Default = true,
            ConfigType = "Advanced",
        },
        ['GroupManaPct']   = {
            DisplayName = "Combat ModRod %",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 103,
            Tooltip = "Mana% to begin summoning Mod Rods in combat.",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['GroupManaCt']    = {
            DisplayName = "Combat ModRod Count",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 104,
            Tooltip = "The number of party members (including yourself) that need to be under the above mana percentage.",
            Default = 3,
            Min = 1,
            Max = 6,
            ConfigType = "Advanced",
        },
        ['DoSkinDS']       = {
            DisplayName = "Use Skin DS",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Tooltip = "Use your short duration damage shield (Skin line) on the MA during combat.",
            RequiresLoadoutChange = true,
            Default = false,
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
