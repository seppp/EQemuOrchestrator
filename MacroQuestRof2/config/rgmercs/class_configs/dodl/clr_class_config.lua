local mq           = require('mq')
local Casting      = require("utils.casting")
local Combat       = require('utils.combat')
local Config       = require('utils.config')
local Core         = require("utils.core")
local Targeting    = require("utils.targeting")

local _ClassConfig = {
    _version              = "DODL CUSTOM",
    _author               = "eldudero",
    ['ModeChecks']        = {
        IsHealing = function() return true end,
        IsCuring = function() return Config:GetSetting('DoCures') end,
        IsRezing = function()
            local rezAction = Casting.CanUseAA("Blessing of Resurrection") or mq.TLO.FindItem("=Water Sprinkler of Nem Ankh")()
            return ((Core.GetResolvedActionMapItem('RezSpell') or rezAction) and Targeting.GetXTHaterCount() == 0) or (Config:GetSetting('DoBattleRez') and rezAction)
        end,
    },
    ['Rez']               = {
        ['Combat'] = {
            { type = "AA",   name = "Blessing of Resurrection", },
            { type = "Item", name = "Water Sprinkler of Nem Ankh", },
        },
        ['Downtime'] = {
            {
                type = "Spell",
                name = "Larger Reviviscence",
                cond = function(self, spell, target)
                    return Casting.DowntimeRezOkay()
                        and mq.TLO.SpawnCount("pccorpse radius 80 zradius 30")() > 2
                end,
            },
            { type = "AA",   name = "Blessing of Resurrection", },
            { type = "Item", name = "Water Sprinkler of Nem Ankh", },
            {
                type = "Spell",
                name = "RezSpell",
                cond = function(self, spell, target)
                    return Casting.DowntimeRezOkay()
                        and not Casting.AAReady('Blessing of Resurrection')
                end,
            },
        },
    },
    ['Modes']             = {
        'Heal',
    },
    ['Cure']              = {
        ['DetDispel'] = {
            { type = "AA", name = "Group Purify Soul", },
            { type = "AA", name = "Radiant Cure", },
            { type = "AA", name = "Purify Soul",       selfOnly = true, },
        },
        ['Poison'] = {
            {
                type = "Spell",
                name = "GroupHealCure",
                load_cond = function(self)
                    return self.Helpers
                        .UseGroupHealCure(self)
                end,
            },
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureAll', 'CurePoison', }) end, },
        },
        ['Disease'] = {
            {
                type = "Spell",
                name = "GroupHealCure",
                load_cond = function(self)
                    return self.Helpers
                        .UseGroupHealCure(self)
                end,
            },
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureAll', 'CureDisease', }) end, },
        },
        ['Curse'] = {
            {
                type = "Spell",
                name = "GroupHealCure",
                load_cond = function(self)
                    return self.Helpers
                        .UseGroupHealCure(self)
                end,
            },
            { type = "Spell", name_func = function(self) return Casting.GetFirstMapItem({ 'CureAll', 'CureCurse', }) end, },
        },
        ['Corruption'] = {
            { type = "Spell", name = "CureCorrupt", },
        },
    },
    ['Themes']            = {
        ['Heal'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.70, g = 0.65, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.70, g = 0.65, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.30, g = 0.28, b = 0.21, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.70, g = 0.65, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.70, g = 0.65, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.30, g = 0.28, b = 0.21, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.70, g = 0.65, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.70, g = 0.65, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.70, g = 0.65, b = 0.50, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.48, g = 0.44, b = 0.34, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.70, g = 0.65, b = 0.50, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.70, g = 0.65, b = 0.50, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.70, g = 0.65, b = 0.50, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.30, g = 0.28, b = 0.21, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.00, g = 0.99, b = 0.90, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.00, g = 0.99, b = 0.90, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.70, g = 0.65, b = 0.50, a = 1.0, }, },
        },
    },
    ['ItemSets']          = {
        ['Epic'] = {
            "Harmony of the Soul",
            "Aegis of Superior Divinity",
        },
    },
    ['AbilitySets']       = {
        ['WardBuff'] = {             -- Level 97+
            "Ward of Certitude Rk. III",
            "Ward of Certitude Rk. II",
            "Ward of Certitude",
        },
        ['HealingLight'] = {
            "Reverent Light Rk. III",
            "Reverent Light Rk. II",
            "Reverent Light",
            "Zealous Light",
            "Earnest Light",
            "Devout Light",
            "Solemn Light",
            "Sacred Light",
            "Ancient: Hallowed Light",
            "Pious Light",
            "Holy Light",
            "Supernal Light",
            "Ethereal Light",
            "Divine Light",
            "Healing Light",
            "Superior Healing",
            "Greater Healing",
            "Healing",
            "Light Healing",
            "Minor Healing",
        },
        ['RemedyHeal'] = {             -- Not great until 96/RoF (Graceful)
            "Graceful Remedy Rk. III",
            "Graceful Remedy Rk. II",
            "Inspired Heal III",
            "Inspired Heal II",
            "Inspired Heal",
            "Graceful Remedy",
            "Faithful Remedy",
            "Earnest Remedy",
            "Devout Remedy",
            "Solemn Remedy",
            "Sacred Remedy",
            "Pious Remedy",
            "Supernal Remedy",
            "Ethereal Remedy",
        },
        ['RemedyHeal2'] = {
            "Graceful Remedy Rk. III",
            "Graceful Remedy Rk. II",
            "Inspired Heal III",
            "Inspired Heal II",
            "Inspired Heal",
            "Graceful Remedy",
        },
        ['Renewal'] = {               -- Level 70 +, large heal, slower cast
            "Fraught Renewal Rk. III",
            "Fraught Renewal Rk. II",
            "Fraught Renewal",
            "Fervent Renewal",
            "Frenzied Renewal",
            "Frenetic Renewal",
            "Frantic Renewal",
            "Desperate Renewal",
        },
        ['Renewal2'] = {              -- Level 70 +, large heal, slower cast
            "Fraught Renewal Rk. III",
            "Fraught Renewal Rk. II",
            "Fraught Renewal",
            "Fervent Renewal",
            "Frenzied Renewal",
            "Frenetic Renewal",
            "Frantic Renewal",
            "Desperate Renewal",
        },
        ['Renewal3'] = {              -- Level 70 +, large heal, slower cast
            "Fraught Renewal Rk. III",
            "Fraught Renewal Rk. II",
            "Fraught Renewal",
            "Fervent Renewal",
            "Frenzied Renewal",
            "Frenetic Renewal",
            "Frantic Renewal",
            "Desperate Renewal",
        },
        ['DichoHeal'] = {
        },
        ['GroupFastHeal'] = {            -- Level 98
            "Syllable of Renewal Rk. III",
            "Syllable of Renewal Rk. II",
            "Syllable of Renewal",
        },
        ['GroupHealCure'] = {
            "Word of Reformation Rk. III",
            "Word of Reformation Rk. II",
            "Word of Reformation",
            "Word of Rehabilitation",
            "Word of Resurgence",
            "Word of Recovery",
            "Word of Vivacity",
            "Word of Vivification",
            "Word of Replenishment",
            "Word of Replenishment",
            "Word of Restoration",
        },
        ['GroupHealNoCure'] = {
            "Word of Renewal Rk. III",
            "Word of Renewal Rk. II",
            "Word of Renewal",
            "Word of Recuperation",
            "Word of Awakening",
            "Word of Recovery",
            "Word of Vivacity",
            "Word of Vivification",
            "Word of Replenishment",
            "Word of Restoration",
            "Word of Vigor",
            "Word of Healing",
            "Word of Health",
        },
        ['HealNuke'] = {
            "Virtuous Intervention Rk. III",
            "Virtuous Intervention Rk. II",
            "Virtuous Intervention",
            "Elysian Intervention",
            "Celestial Intervention",
            "Holy Intervention",
        },
        ['HealNuke2'] = {
            "Virtuous Intervention Rk. III",
            "Virtuous Intervention Rk. II",
            "Virtuous Intervention",
            "Elysian Intervention",
            "Celestial Intervention",
            "Holy Intervention",
        },
        ['HealNuke3'] = {
            "Virtuous Intervention Rk. III",
            "Virtuous Intervention Rk. II",
            "Virtuous Intervention",
            "Elysian Intervention",
            "Celestial Intervention",
            "Holy Intervention",
        },
        ['NukeHeal'] = {
            "Virtuous Contravention Rk. III",
            "Virtuous Contravention Rk. II",
            "Virtuous Contravention",
            "Elysian Contravention",
            "Celestial Contravention",
            "Holy Contravention",
        },
        ['NukeHeal2'] = {
            "Virtuous Contravention Rk. III",
            "Virtuous Contravention Rk. II",
            "Virtuous Contravention",
            "Elysian Contravention",
            "Celestial Contravention",
            "Holy Contravention",
        },
        ['NukeHeal3'] = {
            "Virtuous Contravention Rk. III",
            "Virtuous Contravention Rk. II",
            "Virtuous Contravention",
            "Elysian Contravention",
            "Celestial Contravention",
            "Holy Contravention",
        },
        ['ReverseDS'] = {
        },
        ['SelfHPBuff'] = {
            "Armor of the Reverent Rk. III",
            "Armor of the Reverent Rk. II",
            "Armor of the Reverent",
            "Armor of the Zealous",
            "Armor of the Earnest",
            "Armor of the Devout",
            "Armor of the Solemn",
            "Armor of the Sacred",
            "Armor of the Pious",
            "Armor of the Zealot",
            "Blessed Armor of the Risen",
            "Armor of Protection",
        },
        ['GroupHealProcBuff'] = {
        },
        ['AegoBuff'] = {
            "Hand of Certitude Rk. III",
            "Hand of Certitude Rk. II",
            "Hand of Certitude",
            "Unified Hand of Certitude Rk. III",
            "Unified Hand of Certitude Rk. II",
            "Unified Hand of Certitude",
            "Unified Hand of Credence",
            "Hand of Reliance",
            "Hand of Gallantry",
            "Hand Of Temerity",
            "Hand of Tenacity",
            "Hand of Conviction",
            "Hand of Virtue",
            "Aegolism",
            "Ancient: Gift of Aegolism",
            "Blessing of Aegolism",
            "Blessing of Temperance",
            "Temperance",
            "Valor",
            "Bravery",
            "Daring",
            "Center",
            "Courage",
        },
        ['ACBuff'] = {                       --Sometimes single, sometimes group, used on tank before Aego or until it is rolled into Unified (Symbol)
            "Order of the Earnest Rk. III",
            "Order of the Earnest Rk. II",
            "Order of the Earnest",
            "Ward of the Earnest",
            "Order of the Devout",
            "Ward of the Devout",
            "Order of the Resolute",
            "Ward of the Resolute",
            "Ward of the Dauntless",
            "Ward of Valiance",
            "Ward of Gallantry",
            "Bulwark of Faith",
            "Shield of Words",
            "Armor of Faith",
            "Guard",
            "Spirit Armor",
            "Holy Armor",
        },
        ['ShiningBuff'] = {
            "Shining Bastion Rk. III",
            "Shining Bastion Rk. II",
            "Shining Bastion",
            "Shining Armor",
            "Shining Rampart",
        },
        ['SingleVieBuff'] = {     -- Level 20-73 We don't use this once we have the group version
            "Aegis of Vie Rk. III",
            "Aegis of Vie Rk. II",
            "Aegis of Vie",
            "Panoply of Vie",
            "Bulwark of Vie",
            "Protection of Vie",
            "Guard of Vie",
            "Ward of Vie",
        },
        ['GroupVieBuff'] = {
            "Rallied Bastion of Vie Rk. III",
            "Rallied Bastion of Vie Rk. II",
            "Rallied Bastion of Vie",
            "Rallied Armor of Vie",
            "Rallied Rampart of Vie",
            "Rallied Palladium of Vie",
            "Rallied Shield of Vie",
            "Rallied Aegis of Vie",
        },
        ['GroupSymbolBuff'] = {
            "Unified Hand of Gezat Rk. III",
            "Unified Hand of Gezat Rk. II",
            "Unified Hand of Gezat",
            "Unified Hand of the Triumvirate",
            "Symbol of Marzin",
            "Symbol of Naltron",
            "Symbol of Pinzarn",
            "Symbol of Ryltan",
            "Symbol of Transal",
        },
        ['AbsorbAura'] = {
            "Aura of the Reverent Rk. III",
            "Aura of the Reverent Rk. II",
            "Aura of the Reverent",
            "Aura of the Pious",
            "Aura of the Zealot",
        },
        ['HPAura'] = {
            "Aura of Divinity Rk. III",
            "Aura of Divinity Rk. II",
            "Aura of Divinity",
            "Circle of Divinity",
        },
        ['DivineBuff'] = {
            "Divine Interposition Rk. III",
            "Divine Interposition Rk. II",
            "Divine Interposition",
            "Divine Invocation",
            "Divine Intercession",
            "Divine Intervention",
            "Death Pact",
        },
        ['TwinHealNuke'] = {
            "Glorious Rebuke Rk. III",
            "Glorious Rebuke Rk. II",
            "Glorious Rebuke",
            "Glorious Admonition",
            "Glorious Censure",
            "Glorious Denunciation",
        },
        ['RezSpell'] = {
            "Reviviscence",
            "Resurrection",
            "Restoration",
            "Resuscitate",
            "Renewal",
            "Revive",
            "Reparation",
            "Reconstitution",
            "Reconstitute",
            "Reanimation",
            "Reanimate",
        },
        ['AERezSpell'] = {
            "Superior Healing",
            "Superior Camouflage",
            "Superior Reviviscence",
            "Eminent Reviviscence",
            "Greater Reviviscence",
            "Larger Reviviscence",
        },
        ['ClutchHeal'] = {
            "Fifteenth Emblem Rk. III",
            "Fifteenth Emblem Rk. II",
            "Fifteenth Emblem",
            "Fourteenth Catalyst",
            "Thirteenth Salve",
            "Twelfth Night",
            "Eleventh-Hour",
        },
        ['GroupInfusionBuff'] = {
            "Hand of Graceful Infusion Rk. III",
            "Hand of Graceful Infusion Rk. II",
            "Hand of Graceful Infusion",
            "Hand of Faithful Infusion",
        },
        ['SingleElixir'] = {
            "Earnest Elixir Rk. III",
            "Earnest Elixir Rk. II",
            "Earnest Elixir",
            "Devout Elixir",
            "Solemn Elixir",
            "Sacred Elixir",
            "Pious Elixir",
            "Holy Elixir",
            "Supernal Elixir",
            "Celestial Elixir",
            "Celestial Healing",
            "Celestial Health",
            "Celestial Remedy",
        },
        ['GroupElixir'] = {
            "Elixir of the Acquittal Rk. III",
            "Elixir of the Acquittal Rk. II",
            "Elixir of the Acquittal",
            "Elixir of the Beneficent",
            "Elixir of the Ardent",
            "Elixir of Expiation",
            "Elixir of Atonement",
            "Elixir of Redemption",
            "Elixir of Divinity",
            "Ethereal Elixir",
        },
        ['GroupAcquittal'] = {
            "Cleansing Acquittal Rk. III",
            "Cleansing Acquittal Rk. II",
            "Cleansing Acquittal",
        },
        ['SpellBlessing'] = {
            "Hand of Will Rk. III",
            "Hand of Will Rk. II",
            "Hand of Will",
            "Blessing of Will",
            "Aura of Loyalty",
            "Blessing of Loyalty",
            "Aura of Resolve",
            "Blessing of Resolve",
            "Aura of Purpose",
            "Blessing of Purpose",
            "Aura of Devotion",
            "Blessing of Devotion",
            "Aura of Reverence",
            "Blessing of Reverence",
            "Blessing of Faith",
            "Blessing of Piety",
        },
        ['CureAll'] = {
            "Cleansed Blood Rk. III",
            "Cleansed Blood Rk. II",
            "Cleansed Blood",
            "Perfected Blood",
            "Purged Blood",
            "Purified Blood",
        },
        ['CureCorrupt'] = {
            "Abrogate Corruption Rk. III",
            "Abrogate Corruption Rk. II",
            "Abrogate Corruption",
            "Eradicate Corruption",
            "Dissolve Corruption",
            "Pristine Blood",
            "Abolish Corruption",
            "Vitiate Corruption",
            "Expunge Corruption",
        },
        ['CurePoison'] = {
            "Antidote",
            "Eradicate Poison",
            "Abolish Poison",
            "Counteract Poison",
            "Cure Poison",
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
        ['CureCurse'] = {
            "Eradicate Poison",
            "Eradicate Disease",
            "Eradicate Corruption",
            "Eradicate Corruption Rk. II",
            "Eradicate Corruption Rk. III",
            "Eradicate Curse",
            "Remove Greater Curse",
            "Remove Curse",
            "Remove Lesser Curse",
            "Remove Minor Curse",
        },
        ['YaulpSpell'] = {
            "Yaulp IX Rk. III",
            "Yaulp IX Rk. II",
            "Yaulp IX",
            "Yaulp VIII",
            "Yaulp VII",
            "Yaulp VI",
            "Yaulp V",
        },
        ['StunTimer6'] = {           -- Timer 6 Stun, Fast Cast, Level 63+ (with ToT Heal 88+)
            "Sound of Plangency Rk. III",
            "Sound of Plangency Rk. II",
            "Innerflame Discipline",
            "Sound of Plangency",
            "Sound of Fervor",
            "Sound of Fury",
            "Sound of Reverberance",
            "Sound of Resonance",
            "Sound of Zeal",
            "Sound of Divinity",
            "Sound of Might",
            "Tarnation",
            "Force",
            "Holy Might",
        },
        ['LowLevelStun'] = {         --Adding a second stun at low levels
            "Stun Command",
            "Stun",
        },
        ['UndeadNuke'] = {           -- Level 4+
            "Abrogate the Undead Rk. III",
            "Abrogate the Undead Rk. II",
            "Abrogate the Undead",
            "Abolish the Undead",
            "Annihilate the Undead",
            "Desolate Undead",
            "Destroy Undead",
            "Exile Undead",
            "Banish Undead",
            "Expel Undead",
            "Dismiss Undead",
            "Expulse Undead",
            "Ward Undead",
        },
        ['MagicNuke'] = {
            "Castigation Rk. III",
            "Castigation Rk. II",
            "Castigation",
            "Remonstrance",
            "Rebuke",
            "Reprehend",
            "Reproval",
            "Reproach",
            "Order",
            "Condemnation",
            "Judgment",
            "Retribution",
            "Wrath",
            "Smite",
            "Furor",
            "Strike",
        },
        ['HammerPet'] = {
            "Infallible Hammer of Reverence Rk. III",
            "Infallible Hammer of Reverence Rk. II",
            "Infallible Hammer of Reverence",
            "Infallible Hammer of Zeal",
            "Devout Hammer of Zeal",
            "Unwavering Hammer of Zeal",
            "Indomitable Hammer of Zeal",
            "Unflinching Hammer of Zeal",
            "Unswerving Hammer of Retribution",
            "Unswerving Hammer of Faith",
        },
        ['CompleteHeal'] = {
            "Complete Heal",
        },
    },                       -- end AbilitySets
    ['Helpers']           = {
        UseGroupHealCure = function(self)
            return Config:GetSetting('KeepCureMemmed') == 3
        end,
    },
    -- These are handled differently from normal rotations in that we try to make some intelligent desicions about which spells to use instead
    -- of just slamming through the base ordered list.
    -- These will run in order and exit after the first valid spell to cast
    ['HealRotationOrder'] = {
        { -- Level 1-97
            name = 'GroupHeal(1-97)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 98 end,
            cond = function(self, target) return Targeting.GroupHealsNeeded() end,
        },
        { -- Level 77+
            name = 'BigHeal(77+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 76 end,
            cond = function(self, target)
                return Targeting.BigHealsNeeded(target) and not Targeting.TargetIsType("pet", target)
            end,
        },
        { -- Level 59-76
            name = 'BigHeal(59-76)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 58 and mq.TLO.Me.Level() < 77 end,
            cond = function(self, target)
                return Targeting.BigHealsNeeded(target) and not Targeting.TargetIsType("pet", target)
            end,
        },
        { -- Level 101+
            name = 'MainHeal(101+)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 100 end,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
        { -- Level 80-100
            name = 'MainHeal(80-100)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() > 79 and mq.TLO.Me.Level() < 101 end,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
        { -- Level 1-70
            name = 'MainHeal(1-79)',
            state = 1,
            steps = 1,
            load_cond = function() return mq.TLO.Me.Level() < 80 end,
            cond = function(self, target)
                return Targeting.MainHealsNeeded(target)
            end,
        },
    },
    ['HealRotations']     = {
        ['GroupHeal(98+)'] = {
            {
                name = "DichoHeal",
                type = "Spell",
                cond = function(self, spell)
                    return Targeting.BigGroupHealsNeeded()
                end,
            },
            {
                name = "Beacon of Life",
                type = "AA",
            },
            {
                name = "GroupFastHeal",
                type = "Spell",
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
            },
            {
                name = "GroupHealCure",
                type = "Spell",
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
            },
            {
                name = "GroupElixir",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['GroupHeal(1-97)'] = { --Level 1-97
            {
                name = "GroupHealNoCure",
                type = "Spell",
            },
            {
                name = "GroupElixir",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "Celestial Regeneration",
                type = "AA",
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
            },
        },
        ['BigHeal(77+)'] = {
            {
                name = "ClutchHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.GetTargetPctHPs() < 35
                end,
            },
            {
                name = "Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "DichoHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Burst of Life",
                type = "AA",
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Blessing of Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return target.ID() == (mq.TLO.Target.AggroHolder.ID() or 0) and target.ID() ~= Core.GetMainAssistId()
                end,
            },
            {
                name = "Veturika's Perseverance",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            { --The stuff above is down, lets make mainhealpoint chonkier. Homework: Wondering if we should be using this more/elsewhere.
                name = "Channeling the Divine",
                type = "AA",
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
            },
            { --if we hit this we need spells back ASAP
                name = "Forceful Rejuvenation",
                type = "AA",
            },
        },
        ['BigHeal(59-76)'] = {
            {
                name = "Sanctuary",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target)
                end,
            },
            {
                name = "Divine Arbitration",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Targeting.GroupedWithTarget(target) then return false end
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "Renewal",
                type = "Spell",
            },
            {
                name = "RemedyHeal",
                type = "Spell",
                load_cond = function(self) return not Core.GetResolvedActionMapItem("Renewal") end,
            },
        },
        ['MainHeal(101+)'] = {
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self)
                    return (mq.TLO.Me.CombatState() or ""):lower() == "combat"
                end,
            },
            {
                name = "RemedyHeal",
                type = "Spell",
            },
            {
                name = "RemedyHeal2",
                type = "Spell",
            },
            {
                name = "Apothic Dragon Spine Hammer",
                type = "Item",
            },
        },
        ['MainHeal(80-100)'] = { --Level 80-100
            {
                name = "Focused Celestial Regeneration",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsATank(target)
                end,
            },
            {
                name = "HealNuke",
                type = "Spell",
                cond = function(self)
                    return (mq.TLO.Me.CombatState() or ""):lower() == "combat"
                end,
            },
            {
                name = "HealNuke2",
                type = "Spell",
                cond = function(self)
                    return (mq.TLO.Me.CombatState() or ""):lower() == "combat"
                end,
            },
            {
                name = "HealNuke3",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end,
                cond = function(self)
                    return (mq.TLO.Me.CombatState() or ""):lower() == "combat"
                end,
            },
            {
                name = "RemedyHeal",
                type = "Spell",
            },
            {
                name = "Renewal",
                type = "Spell",
            },
            {
                name = "Renewal2",
                type = "Spell",
            },
            {
                name = "Renewal3",
                type = "Spell",
            },
            {
                name = "SingleElixir",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    return not Targeting.BigHealsNeeded(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "HealingLight",
                type = "Spell",
            },
        },
        ['MainHeal(1-79)'] = { --Level 1-79
            {
                name = "SingleElixir",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealOverTime') end,
                cond = function(self, spell, target)
                    return not Targeting.BigHealsNeeded(target) and Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "CompleteHeal",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoCompleteHeal') end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return (target.PctHPs() or 999) <= Config:GetSetting('CompleteHealPct')
                end,
            },
            {
                name = "HealingLight",
                type = "Spell",
                cond = function(self, spell, target)
                    return not (Config:GetSetting("DoCompleteHeal") and Targeting.TargetIsATank(target))
                end,
            },
        },
    },
    ['Charm']             = {
        ['Assist'] = {
            { name = "LowLevelStun", type = "Spell", cond = function(self, spell, target) return Targeting.TargetNotStunned() end, },
            { name = "StunTimer6",   type = "Spell", cond = function(self, spell, target) return Targeting.TargetNotStunned() end, },
        },
    },
    ['RotationOrder']     = {
        -- Downtime doesn't have state because we run the whole rotation at once.
        {
            name = 'Downtime',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Core.CombatActionsCheck() and Casting.OkayToBuff() and Casting.AmIBuffable()
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
        {
            name = 'Burn',
            state = 1,
            steps = 3,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'ManaRestore',
            timer = 30,
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoManaRestore') and (Casting.CanUseAA("Veturika's Perseverance") or Casting.CanUseAA("Quiet Prayer")) end,
            targetId = function(self) return { Combat.FindWorstHurtMana(Config:GetSetting('ManaRestorePct')), } end,
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
            load_cond = function(self) return self:GetResolvedActionMapItem('ReverseDS') or self:GetResolvedActionMapItem('WardBuff') end,
            targetId = function(self) return { Core.GetMainAssistId(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
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
            name = 'Combat Buffs',
            state = 1,
            steps = 1,
            targetId = function(self) return Casting.GetBuffableIDs() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
    },
    ['Rotations']         = {
        ['ManaRestore'] = {
            {
                name = "Veturika's Perseverance",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetIsMyself(target) and Casting.AmIBuffable()
                end,
            },
            {
                name = "Quiet Prayer",
                type = "AA",
                cond = function(self, aaName, target)
                    if Targeting.TargetIsMyself(target) then return false end
                    local rezSearch = string.format("pccorpse %s radius 100 zradius 50", target.DisplayName())
                    return mq.TLO.SpawnCount(rezSearch)() == 0
                end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "ReverseDS",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "WardBuff",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell, target)
                    if not Casting.CastReady(spell) then return false end --avoid constant group buff checks
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Celestial Hammer",
                type = "AA",
            },
            {
                name = "Flurry of Life",
                type = "AA",
            },
            {
                name = "Healing Frenzy",
                type = "AA",
            },
            {
                name = "Spire of the Vicar",
                type = "AA",
            },
            {
                name = "Divine Avatar",
                type = "AA",
                cond = function(self)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            { --homework: This is a defensive proc, likely need to add elsewhere
                name = "Divine Retribution",
                type = "AA",
                cond = function(self)
                    return Config:GetSetting('DoMelee') and mq.TLO.Me.Combat()
                end,
            },
            {
                name = "Battle Frenzy",
                type = "AA",
            },
            {
                name = "Improved Twincast",
                type = "AA",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
            { --homework: Check if this is necessary (does not exceed 50% spell haste cap)
                name = "Celestial Rapidity",
                type = "AA",
            },
            {
                name = "Exquisite Benediction",
                type = "AA",
            },
        },
        ['Combat Buffs'] = {
            {
                name = "DivineBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDivineBuff') end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "TwinHealNuke",
                type = "Spell",
                retries = 0,
                load_cond = function(self) return Config:GetSetting('DoTwinHeal') end,
                cond = function(self, spell)
                    return not Casting.IHaveBuff("Healing Twincast")
                end,
            },
            {
                name = "StunTimer6",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoHealStun') end,
                cond = function(self, spell)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "NukeHeal",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.LightHealsNeeded(Core.GetMainAssistSpawn()) and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "NukeHeal2",
                type = "Spell",
                cond = function(self, spell, target)
                    return Targeting.LightHealsNeeded(Core.GetMainAssistSpawn()) and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "NukeHeal3",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end,
                cond = function(self, spell, target)
                    return Targeting.LightHealsNeeded(Core.GetMainAssistSpawn()) and Casting.HaveManaToNuke()
                end,
            },
            {
                name = "Yaulp",
                type = "AA",
                allowDead = true,
                cond = function(self, aaName)
                    return not mq.TLO.Me.Mount() and Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "YaulpSpell",
                type = "Spell",
                allowDead = true,
                load_cond = function(self) return not Casting.CanUseAA("Yaulp") end,
                cond = function(self, spell)
                    return not mq.TLO.Me.Mount() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "GroupElixir",
                type = "Spell",
                allowDead = true,
                cond = function(self, spell)
                    if (mq.TLO.Me.Level() < 101 and not Casting.GOMCheck()) then return false end
                    return (mq.TLO.Me.Song(spell).Duration.TotalSeconds() or 0) < 15
                end,
            },
            {
                name = "LowLevelStun",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoLLStun') and mq.TLO.Me.Level() < 59 end,
                cond = function(self, spell, target)
                    local targetLevel = Targeting.GetAutoTargetLevel()
                    if targetLevel == 0 or targetLevel > 55 then return false end
                    return Targeting.TargetNotStunned() and Casting.DetSpellCheck(spell) and Casting.HaveManaToDebuff() and not Casting.StunImmuneTarget(target)
                end,
            },
            {
                name = "Turn Undead",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.TargetBodyIs(target, "Undead")
                end,
            },
            {
                name = "UndeadNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoUndeadNuke') end,
                cond = function(self, aaName, target)
                    if not Targeting.TargetBodyIs(target, "Undead") then return false end
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "MagicNuke",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoMagicNuke') end,
                cond = function(self)
                    return Casting.OkayToNuke(true)
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Config:GetSetting('DoMelee') and Core.ShieldEquipped()
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "Saint's Unity",
                type = "AA",
                cond = function(self, aaName)
                    if Config:GetSetting('AegoSymbol') == 3 then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "SelfHPBuff",
                type = "Spell",
                cond = function(self, spell)
                    if Config:GetSetting('AegoSymbol') == 3 or Casting.CanUseAA("Saint's Unity") then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "GroupHealProcBuff",
                type = "Spell",
                active_cond = function(self, spell)
                    return
                        Casting.IHaveBuff(spell)
                end,
                cond = function(self, spell)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "AbsorbAura",
                type = "Spell",
                pre_activate = function(self, spell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    if not Casting.CanUseAA('Spirit Mastery') and not (Casting.AuraActiveByName("Reverent Aura") or Casting.AuraActiveByName(spell.BaseName())) then
                        ---@diagnostic disable-next-line: undefined-field
                        mq.TLO.Me.Aura(1).Remove()
                    end
                end,
                cond = function(self, spell)
                    return not (Casting.AuraActiveByName("Reverent Aura") or Casting.AuraActiveByName(spell.BaseName())) and
                        (Config:GetSetting('UseAura') == 1 or Casting.CanUseAA('Spirit Mastery'))
                end,
            },
            {
                name = "HPAura",
                type = "Spell",
                pre_activate = function(self, spell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.CanUseAA('Spirit Mastery') and not Casting.AuraActiveByName(spell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, spell)
                    return not Casting.AuraActiveByName(spell.BaseName()) and (Config:GetSetting('UseAura') == 2 or Casting.CanUseAA('Spirit Mastery'))
                end,
            },
        },
        ['GroupBuff'] = {
            {
                name = "Divine Guardian",
                type = "AA",
                cond = function(self, aaName, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffAACheck(aaName, target)
                end,
            },
            {
                name = "AegoBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('AegoSymbol') <= 2 end,
                cond = function(self, spell, target)
                    if Casting.TargetHasBuffList(target, Casting.DruidSkinBuffs) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupSymbolBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if Config:GetSetting('AegoSymbol') == (1 or 4) or ((spell.TargetType() or ""):lower() == "single" and target.ID() ~= Core.GetMainAssistId()) then return false end
                    if Casting.TargetHasBuffList(target, Casting.ClericAegoBuffs) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SpellBlessing",
                type = "Spell",
                load_cond = function(self) return mq.TLO.Me.Level() <= 95 end, -- could check to make sure we know a unified. This is cheaper.
                cond = function(self, spell, target)
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ACBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoACBuff') end,
                cond = function(self, spell, target)
                    if (spell.TargetType() or ""):lower() == "single" and not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "GroupVieBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoVieBuff') and self:GetResolvedActionMapItem('GroupVieBuff') end,
                cond = function(self, spell, target)
                    if Targeting.TargetIsATank(target) and self:GetResolvedActionMapItem('ShiningBuff') then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "SingleVieBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoVieBuff') and not self:GetResolvedActionMapItem('GroupVieBuff') end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "ShiningBuff",
                type = "Spell",
                cond = function(self, spell, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return Casting.GroupBuffCheck(spell, target)
                end,
            },
            {
                name = "DivineBuff",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoDivineBuff') end,
                cond = function(self, spell, target)
                    if not Targeting.TargetIsATank(target) then return false end
                    return Casting.CastReady(spell) and Casting.GroupBuffCheck(spell, target) and Casting.ReagentCheck(spell)
                end,
            },
        },
    },
    ['SpellList']         = {
        {
            name = "Default",
            spells = {
                { name = "RemedyHeal",      cond = function(self) return mq.TLO.Me.Level() >= 96 end, },                                        -- Level 96+
                { name = "RemedyHeal2",     cond = function(self) return mq.TLO.Me.Level() >= 101 end, },                                       -- Level 101+
                { name = "HealingLight",    cond = function(self) return mq.TLO.Me.Level() < 80 end, },
                { name = "Renewal",         cond = function(self) return mq.TLO.Me.Level() >= 70 and mq.TLO.Me.Level() < 101 end, },            -- Level 80-95
                { name = "Renewal2",        cond = function(self) return mq.TLO.Me.Level() >= 80 and mq.TLO.Me.Level() < 101 end, },            -- Level 80+
                { name = "RemedyHeal",      cond = function(self) return mq.TLO.Me.Level() < 70 end, },
                { name = "CompleteHeal",    cond = function(self) return Config:GetSetting('DoCompleteHeal') and mq.TLO.Me.Level() < 80 end, }, -- Level 39
                { name = "ClutchHeal", },                                                                                                       -- Level 77+
                { name = "SingleElixir",    cond = function(self) return Config:GetSetting('DoHealOverTime') and mq.TLO.Me.Level() < 83 end, }, -- Level 19-79
                { name = "GroupElixir",     cond = function(self) return Config:GetSetting('DoHealOverTime') end, },                            -- Level 60+, gets better from 70 on, this may be overwritten before 75
                { name = "GroupFastHeal", },                                                                                                    -- Syllable, 98+
                { name = "GroupHealNoCure", cond = function(self) return not Core.GetResolvedActionMapItem('GroupFastHeal') end, },             -- Level 30-97
                { name = "DichoHeal", },                                                                                                        -- Level 101+ --may be overwritten from 101-104
                { name = "DivineBuff",      cond = function(self) return Config:GetSetting('DoDivineBuff') end, },                              -- Level 51+
                { name = "HealNuke",        cond = function(self) return Config:GetSetting('InterContraChoice') < 3 end, },
                { name = "HealNuke2",       cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal",        cond = function(self) return Config:GetSetting('InterContraChoice') > 1 end, },
                { name = "NukeHeal2",       cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "CureAll",         cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 end, },
                { name = "CurePoison",      cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 and not Core.GetResolvedActionMapItem('CureAll') end, },
                { name = "CureDisease",     cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 and not Core.GetResolvedActionMapItem('CureAll') end, },
                { name = "CureCurse",       cond = function(self) return Config:GetSetting('KeepCureMemmed') == 2 and not Core.GetResolvedActionMapItem('CureAll') end, },
                { name = "GroupHealCure",   cond = function(self) return Config:GetSetting('KeepCureMemmed') == 3 end, },
                { name = "StunTimer6",      cond = function(self) return Config:GetSetting('DoHealStun') end, },                          -- Level 16 - 76 (moved gems after)
                { name = "LowLevelStun",    cond = function(self) return Config:GetSetting('DoLLStun') and mq.TLO.Me.Level() < 59 end, }, -- Level 2-58
                { name = "WardBuff", },                                                                                                   -- Level 97
                { name = "ReverseDS", },                                                                                                  -- Level 85+
                { name = "TwinHealNuke",    cond = function(self) return Config:GetSetting('DoTwinHeal') end, },                          -- 84+
                { name = "YaulpSpell",      cond = function(self) return not Casting.CanUseAA("Yaulp") end, },                            -- Level 56-75
                { name = "MagicNuke",       cond = function(self) return Config:GetSetting('DoMagicNuke') end, },
                { name = "UndeadNuke",      cond = function(self) return Config:GetSetting('DoUndeadNuke') end, },
                --fallback
                { name = "ShiningBuff", },
                { name = "HealNuke", },
                { name = "NukeHeal", },
                { name = "HealNuke2",       cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "NukeHeal2",       cond = function(self) return Config:GetSetting('InterContraChoice') == 2 end, },
                { name = "GroupVieBuff",    cond = function(self) return Config:GetSetting('DoVieBuff') end, },
                { name = "SingleVieBuff",   cond = function(self) return Config:GetSetting('DoVieBuff') and not Core.GetResolvedActionMapItem('GroupVieBuff') end, },
                { name = "HealNuke3",       cond = function(self) return Config:GetSetting('InterContraChoice') == 1 end, },
                { name = "NukeHeal3",       cond = function(self) return Config:GetSetting('InterContraChoice') == 3 end, },
                { name = "Renewal3",        cond = function(self) return mq.TLO.Me.Level() < 101 end, },
                { name = "RezSpell",        cond = function(self) return not Casting.AAReady('Blessing of Resurrection') end, },
            },
        },
    },
    ['DefaultConfig']     = {
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes do for Cleric?",
            Answer = "At this time Clerics only have a Heal mode. You can use the provided options to shape them into more of a hybrid role if needed.",
        },
        --Buffs
        ['AegoSymbol']        = {
            DisplayName = "Aego/Symbol Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip =
            "Choose whether to use the Aegolism or Symbol Line of HP Buffs.\nPlease note using both is supported for party members who block buffs, but these buffs do not stack once we transition from using a HP Type-One buff in place of Aegolism.",
            Type = "Combo",
            ComboOptions = { 'Aegolism', 'Both (See Tooltip!)', 'Symbol', 'None', },
            Default = 1,
            Min = 1,
            Max = 4,
        },
        ['DoACBuff']          = {
            DisplayName = "Use AC Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip =
                "Use your single-slot AC Buff on the Main Assist. USE CASES:\n" ..
                "You have Aegolism selected and are below level 60 (We are still using a HP Type One buff).\n" ..
                "You have Symbol selected and you are below level 95 (We don't have Unified Symbols yet).\n" ..
                "Leaving this on in other cases is not likely to cause issue, but may cause unnecessary buff checking.",
            Default = false,
        },
        ['DoVieBuff']         = {
            DisplayName = "Use Vie Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 103,
            Tooltip = "Use your melee damage absorb (Vie) line.",
            Default = true,
            RequiresLoadoutChange = true,
            FAQ = "Why am I using the Vie and Shining buffs together when the melee guard does not stack?",
            Answer = "We will always use the Shining line on the tank, but if selected, we will also use the Vie Buff on the Group.\n" ..
                "Before we have the Shining Buff, we will use our single-target Vie buff only on the tank.",
        },
        ['UseAura']           = {
            DisplayName = "Aura Spell Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 104,
            Tooltip = "Select the Aura to be used, prior to purchasing the Spirit Mastery AA.",
            Type = "Combo",
            ComboOptions = { 'Absorb', 'HP', 'None', },
            Default = 1,
            Min = 1,
            Max = 3,
        },
        ['DoDivineBuff']      = {
            DisplayName = "Do Divine Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 105,
            Tooltip = "Use your Divine Intervention line (death save) on the MA.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoVetAA']           = {
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
        --Damage
        ['InterContraChoice'] = {
            DisplayName = "Inter/Contra:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Select your preference between the Intervention and Contravention lines.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Prefer Intervention', 'Balanced (usually one of each)', 'Prefer Contravention', },
            Default = 2,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoTwinHeal']        = {
            DisplayName = "Twin Heal Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = "Use Twin Heal Nuke Spells",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoUndeadNuke']      = {
            DisplayName = "Do Undead Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 103,
            Tooltip = "Use the Undead nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoMagicNuke']       = {
            DisplayName = "Do Magic Nuke",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 104,
            Tooltip = "Use the Magic nuke line.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoHealStun']        = {
            DisplayName = "ToT-Heal Stun",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Stun",
            Index = 101,
            Tooltip = "Use the Timer 6 HoT Stun (\"Sound of\" Line).",
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "Which stun spells does the Cleric use?",
            Answer =
                "At low levels, we will use the \"Stun\" spell (until 58, if selected) and either \"Holy Might\", \"Force\", or \"Tarnation\" until level 65.\n" ..
                "After that, we transition to the Timer 6 stuns (\"Sound of\" line), which have a ToT heal from Level 88.\n" ..
                "Please note that the low level spell named \"Stun\" is controlled by the Low Level Stun option.",
        },
        ['DoLLStun']          = {
            DisplayName = "Low Level Stun",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Stun",
            Index = 102,
            Tooltip = "Use the Level 2 \"Stun\" spell, as long as it is level-appropriate (works on targets up to Level 55).",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why is a Cleric stunning? It should be healing!?",
            Answer =
            "At low levels, Cleric stuns are often more efficient than healing the damage an non-stunned mob would cause.",
        },
        --Spells and Abilities
        ['DoManaRestore']     = {
            DisplayName = "Use Mana Restore AAs",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 101,
            Tooltip = "Use Veturika's Prescence (on self) or Quiet Prayer (on others) at critically low mana.",
            RequiresLoadoutChange = true, -- used as a load condition
            Default = true,
            ConfigType = "Advanced",
            FAQ = "What circumstances do we use Veturika's or Quiet Prayer?",
            Answer =
                "If the Mana Restore AA setting is set on the Spells and Abilities tab, we will use either of these once the Mana Restore Pct threshold is crossed.\n" ..
                "We will also use Veturika's as an emergency self-heal if required.",
        },
        ['ManaRestorePct']    = {
            DisplayName = "Mana Restore Pct",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 102,
            Tooltip = "Min Mana to use restore AA.",
            Default = 10,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
        },
        ['DoHealOverTime']    = {
            DisplayName = "Use HoTs",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 101,
            Tooltip = "Use the Elixir Line (Low Level: Single, Mid-Level: Both (situationally), High Level: Group).",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why isn't my Cleric using the Group Elixir HoT?",
            Answer = "Before Level 100, we will only use the Group Elixir if we have a GOM proc or the if the \"Group Injured Count\" is met (See Heal settings in RGMain config).",
        },
        ['DoCompleteHeal']    = {
            DisplayName = "Use Complete Heal",
            Group = "Abilities",
            Header = "Recovery",
            Category = "General Healing",
            Index = 102,
            Tooltip = "Use Complete Heal on a tank class (instead of the healing Light line).",
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
            FAQ = "Why isn't my cleric using Complete Heal?",
            Answer =
            "Complete Heal use can be enabled in the Spells and Abilities tab. Please note that, if enabled, we will not use the healing Light line on the MA.",
        },
        ['CompleteHealPct']   = {
            DisplayName = "Complete Heal Pct",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Healing Thresholds",
            Index = 101,
            Tooltip = "Pct we will use Complete Heal on a tank class.",
            Default = 80,
            Min = 1,
            Max = 99,
            ConfigType = "Advanced",
            Warning = function()
                if Config:GetSetting('CompleteHealPct') > Config:GetSetting('MaxHealPoint') then
                    return true, "Warning: CompleteHealPct exceeds MaxHealPoint - we will not check if heals are needed until health is under MaxHealPoint (Healing Threshold)."
                end
                return false, ""
            end,
        },
        ['KeepCureMemmed']    = {
            DisplayName = "Mem Cure:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 101,
            Tooltip = "Select your preference of a Cure spell to keep loaded (if a gem is availabe). \n" ..
                "Please note that we will still memorize a cure out-of-combat if needed, and AA will always be used if available.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'None (Suggested for most cases)', 'Mem cure spells when possible', 'Mem GroupHealCure (\"Word of\" Line) when possible', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['HealPriority']      = {
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
