local mq           = require('mq')
local Casting      = require("utils.casting")
local Combat       = require("utils.combat")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require("utils.globals")
local Logger       = require("utils.logger")
local Targeting    = require("utils.targeting")

local _ClassConfig = {
    _version          = "DODL CUSTOM",
    _author           = "eldudero",
    ['Modes']         = {
        'DPS',
    },
    ['Themes']        = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.35, g = 0.25, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.35, g = 0.25, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.14, g = 0.10, b = 0.06, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.35, g = 0.25, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.35, g = 0.25, b = 0.15, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.14, g = 0.10, b = 0.06, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.35, g = 0.25, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.35, g = 0.25, b = 0.15, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.35, g = 0.25, b = 0.15, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.23, g = 0.16, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.35, g = 0.25, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.35, g = 0.25, b = 0.15, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.35, g = 0.25, b = 0.15, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.14, g = 0.10, b = 0.06, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.85, g = 0.55, b = 0.15, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.85, g = 0.55, b = 0.15, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.35, g = 0.25, b = 0.15, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Transcended Fistwraps of Immortality",
            "Fistwraps of Celestial Discipline",
        },
        ['Coating'] = {
        },
    },
    ['AbilitySets']   = {
        ['EndRegen'] = {
            "Rest Rk. III",
            "Rest Rk. II",
            "Rest",
            "Reprieve",
            "Respite",
            "Fourth Wind",
            "Third Wind",
            "Second Wind",
        },
        ['CombatEndRegen'] = {
        },
        ['MonkAura'] = {
        },
        ['Dicho'] = {
        },
        ['Drunken'] = {
            "Drunken Monkey Style Rk. III",
            "Drunken Monkey Style Rk. II",
            "Drunken Monkey Style",
        },
        ['Curse'] = {
        },
        ['Fang'] = {
            "Dragonscale Guard",
            "Dragonscale Guard Rk. II",
            "Dragonscale Guard Rk. III",
            "Dragonscale Aquifer",
            "Dragonscale Aquifer Rk. II",
            "Dragonscale Aquifer Rk. III",
            "Dragonscale Hills Portal",
            "Dragonscale Hills Gate",
            "Dragon Fang",
        },
        ['Fists'] = {
            "Whorl of Fists Rk. III",
            "Whorl of Fists Rk. II",
            "Whorl of Fists",
            "Wheel of Fists",
        },
        ['Precision1'] = {
        },
        ['Precision2'] = {
        },
        ['Precision3'] = {
        },
        ['Precision4'] = {
        },
        ['Precision5'] = {
        },
        ['Shuriken'] = {
            "Vigorous Shuriken Rk. III",
            "Vigorous Shuriken Rk. II",
            "Vigorous Shuriken",
        },
        ['CraneStance'] = {
            "Crane Stance Rk. III",
            "Crane Stance Rk. II",
            "Crane Stance",
        },
        ['Synergy'] = {
        },
        ['Alliance'] = {
        },
        ['Storm'] = {
            "Eye of the Storm Rk. III",
            "Eye of the Storm Rk. II",
            "Eye of the Storm",
        },
        ['Breaths'] = {
            "Seven Breaths Rk. III",
            "Seven Breaths Rk. II",
            "Seven Breaths",
            "Six Breaths",
            "Five Breaths",
        },
        ['FistsOfWu'] = {
            "Fists of Wu",
            "Fists Of Wu",
        },
        ['EarthDisc'] = {
            "Earthforce Discipline Rk. III",
            "Earthforce Discipline Rk. II",
            "Earthforce Discipline",
            "Earthwalk Discipline",
        },
        ['ShadedStep'] = {
            "Shaded Step Rk. III",
            "Shaded Step Rk. II",
            "Shaded Step",
            "Void Step",
        },
        ['RejectDeath'] = {
            "Forestall Death Rk. III",
            "Forestall Death Rk. II",
            "Forestall Death",
            "Decry Death",
            "Deny Death",
            "Defer Death",
            "Delay Death",
        },
        ['DodgeBody'] = {
            "Veiled Body Rk. III",
            "Veiled Body Rk. II",
            "Veiled Body",
            "Void Body",
        },
        ['MezSpell'] = {
        },
        ['FistDisc'] = {
            "Ironfist Discipline Rk. III",
            "Ironfist Discipline Rk. II",
            "Ironfist Discipline",
            "Scaledfist Discipline",
            "Ashenhand Discipline",
        },
        ['Heel'] = {
            "Heel of Zagali Rk. III",
            "Heel of Zagali Rk. II",
            "Heel of Zagali",
            "Heel of Kojai",
            "Heel of Kai",
            "Rapid Kick Discipline",
            "Heel of Kanji",
        },
        ['Speed'] = {
            "Speed of the Brood",
            "Speed of Vallon",
            "Speed of Salik",
            "Speed of Ellowind",
            "Speed of Ellowind Rk. II",
            "Speed of Ellowind Rk. III",
            "Speed of Erradien",
            "Speed of Erradien Rk. II",
            "Speed of Erradien Rk. III",
            "Speed of Novak",
            "Speed of Novak Rk. II",
            "Speed of Novak Rk. III",
            "Speed of Aransir",
            "Speed of Aransir Rk. II",
            "Speed of Aransir Rk. III",
            "Speed of Sviir",
            "Speed of Sviir Rk. II",
            "Speed of Sviir Rk. III",
            "Speed Focus Discipline",
            "Hundred Fists Discipline",
        },
        ['Palm'] = {
            "Terrorpalm Discipline Rk. III",
            "Terrorpalm Discipline Rk. II",
            "Terrorpalm Discipline",
            "Diamondpalm Discipline",
            "Crystalpalm Discipline",
            "Innerflame Discipline",
        },
        ['Poise'] = {
        },
    },
    ['Helpers']       = {
        BurnDiscCheck = function(self)
            if mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') then return false end
            local burnDisc = { "Heel", "Speed", "FistDisc", "Palm", }
            for _, buffName in ipairs(burnDisc) do
                local resolvedDisc = self:GetResolvedActionMapItem(buffName)
                if resolvedDisc and resolvedDisc.RankName() == mq.TLO.Me.ActiveDisc.Name() then return false end
            end
            return true
        end,
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
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and not Casting.IAmFeigning() and
                    (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99))
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
        {
            name = 'Precision',
            state = 1,
            steps = 1,
            load_cond = function(self) return self:GetResolvedActionMapItem('Precision1') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and not Casting.IAmFeigning()
            end,
        },
    },
    ['Rotations']     = {
        ['Downtime'] = {
            {
                name = "MonkAura",
                type = "Disc",
                active_cond = function(self, discSpell)
                    return Casting.AuraActiveByName(discSpell.RankName.Name())
                end,
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID()
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    if self:GetResolvedActionMapItem("CombatEndRegen") then return false end
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
                name = "Breaths",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Mend",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.PctHPs() < 50
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Imitate Death",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('AggroFeign') end,
                cond = function(self, aaName, target)
                    if Core.IsTanking() then return false end
                    local hasAggro = Targeting.IHaveAggro(80) or (Globals.AutoTargetIsNamed and mq.TLO.Me.PctAggro() > 99)
                    return hasAggro and (mq.TLO.Me.PctHPs() <= 30 or not mq.TLO.Me.AbilityReady("Feign Death")())
                end,
            },
            {
                name = "Feign Death",
                type = "Ability",
                load_cond = function(self) return Config:GetSetting('AggroFeign') end,
                cond = function(self, abilityName)
                    return Targeting.IHaveAggro(80) and not Core.IsTanking()
                end,
            },
            {
                name = "Defy Death",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() < 25
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
                name = "Mend",
                type = "Ability",
                cond = function(self, abilityName)
                    return mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart')
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
            {
                name = "Epic",
                type = "Item",
            },
        },
        ['Burn'] = {
            { -- 5m reuse
                name = "Dicho",
                type = "Disc",
            },
            { -- 5m reuse
                name = "Ton Po's Stance",
                type = "AA",
            },
            {
                name = "Heel",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "Speed",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "FistDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "Palm",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "Spire of the Sensei",
                type = "AA",
            },
            {
                name = "Infusion of Thunder",
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
            { --10m reuse
                name = "CraneStance",
                type = "Disc",
            },
            { --20m reuse, using NOT burndisccheck means we will only use this with a burn disc active
                name = "Poise",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            { --pairs with Speed Focus Disc, AE, T2
                name = "Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    local speedDisc = self:GetResolvedActionMapItem("Speed")
                    if not Config:GetSetting("DoAEDamage") or not speedDisc then return false end
                    return mq.TLO.Me.ActiveDisc.Name() == speedDisc.RankName() and Combat.AETargetCheck()
                end,
            },
            { --pairs with Speed Focus Disc, single target, T2
                name = "Focused Destructive Force",
                type = "AA",
                cond = function(self, aaName)
                    local speedDisc = self:GetResolvedActionMapItem("Speed")
                    if Config:GetSetting("DoAEDamage") or not speedDisc then return false end
                    return mq.TLO.Me.ActiveDisc.Name() == speedDisc.RankName()
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and (mq.TLO.Me.PctAggro() or 0) > 60
                end,
            },
            {
                name = "Swift Tails' Chant",
                type = "AA",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
        },
        ['CombatBuff'] = {
            {
                name = "CombatEndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "Drunken",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Zan Fi's Whistle",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "FistsOfWu",
                type = "Disc",
                cond = function(self, discSpell)
                    if mq.TLO.Me.Level() >= 100 then return false end
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Alliance",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAlliance') then return false end
                    return not Casting.TargetHasBuff(discSpell.Trigger(1))
                end,
            },
            {
                name = "Storm",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "EarthDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Synergy",
                type = "Disc",
            },
            {
                name = "Curse",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "Two-Finger Wasp Touch",
                type = "AA",
                cond = function(self, aaName, target)
                    return Targeting.MobNotLowHP(target)
                end,
            },
            {
                name = "Fists",
                type = "Disc",
            },
            {
                name = "Fang",
                type = "Disc",
            },
            {
                name = "Shuriken",
                type = "Disc",
            },
            {
                name = "Five Point Palm",
                type = "AA",
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return Casting.AARank("Intimidation") > 1
                end,
            },
            {
                name = "Flying Kick",
                type = "Ability",
            },
            {
                name = "Eagle Strike",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return mq.TLO.Me.PctEndurance() < 25
                end,
            },
            {
                name = "Tiger Claw",
                type = "Ability",
            },
        },
        ['Precision'] = {
            {
                name = "Precision5",
                type = "Disc",
            },
            {
                name = "Precision4",
                type = "Disc",
            },
            {
                name = "Precision3",
                type = "Disc",
            },
            {
                name = "Precision2",
                type = "Disc",
            },
            {
                name = "Precision1",
                type = "Disc",
            },
        },
    },
    ['PullAbilities'] = {
        {
            id = 'Distant Strike',
            Type = "AA",
            DisplayName = 'Distant Strike',
            AbilityName = 'Distant Strike',
            AbilityRange = 300,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Distant Strike')
            end,
        },
    },
    ['DefaultConfig'] = {
        ['Mode']           = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes Do?",
            Answer = "Currently there is only DPS mode for Monks, more modes may be added in the future.",
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
        ['AggroFeign']     = {
            DisplayName = "Emergency Feign",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 102,
            Tooltip = "Use your Feign AA when you have aggro at low health or aggro on a mob detected as a 'named' by RGMercs (see Named tab)..",
            Default = true,
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
        ['DoChestClick']   = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
        },
        ['DoCoating']      = {
            DisplayName = "Use Coating",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
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
