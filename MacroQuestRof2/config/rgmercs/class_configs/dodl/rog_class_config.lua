local mq        = require('mq')
local Casting   = require("utils.casting")
local Combat    = require("utils.combat")
local Config    = require('utils.config')
local Core      = require("utils.core")
local Globals   = require("utils.globals")
local Logger    = require("utils.logger")
local Movement  = require("utils.movement")
local Strings   = require("utils.strings")
local Targeting = require("utils.targeting")

return {
    _version          = "DODL CUSTOM",
    _author           = "eldudero",
    ['Modes']         = {
        'DPS',
    },
    ['Themes']        = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.10, g = 0.10, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.10, g = 0.10, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.04, g = 0.04, b = 0.07, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.10, g = 0.10, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.10, g = 0.10, b = 0.16, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.04, g = 0.04, b = 0.07, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.10, g = 0.10, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.10, g = 0.10, b = 0.16, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.10, g = 0.10, b = 0.16, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.07, g = 0.07, b = 0.11, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.10, g = 0.10, b = 0.16, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.10, g = 0.10, b = 0.16, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.10, g = 0.10, b = 0.16, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.04, g = 0.04, b = 0.07, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 0.15, g = 0.75, b = 0.30, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 0.15, g = 0.75, b = 0.30, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.10, g = 0.10, b = 0.16, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Fatestealer",
            "Nightshade, Blade of Entropy",
        },
        ['Coating'] = {
        },
    },
    ['AbilitySets']   = {
        ['Reflex'] = {
            "Conditioned Reflexes Rk. III",
            "Conditioned Reflexes Rk. II",
            "Conditioned Reflexes",
        },
        ['ThiefBuff'] = {
        },
        ['DaggerThrow'] = {
        },
        ['Slice'] = {                 --Timer 1
            "Gash Rk. III",
            "Gash Rk. II",
            "Gash",
            "Lacerate",
            "Wound",
            "Bleed",
        },
        ['Executioner'] = {
            "Executioner Discipline Rk. III",
            "Executioner Discipline Rk. II",
            "Executioner Discipline",
            "Assassin Discipline",
            "Duelist Discipline",
            "Kinesthetics Discipline",
        },
        ['Twisted'] = {
            "Twisted Chance Discipline",
            "Deadeye Discipline",
        },
        ['ProcBuff'] = {
            "Weapon Covenant Rk. III",
            "Weapon Covenant Rk. II",
            "Weapon Covenant",
            "Weapon Bond",
            "Weapon Affiliation",
        },
        ['Frenzied'] = {
            "Frenzied Spirit",
            "Frenzied Strength",
            "Frenzied Renewal",
            "Frenzied Renewal Rk. II",
            "Frenzied Renewal Rk. III",
            "Frenzied Resolve",
            "Frenzied Resolve Rk. II",
            "Frenzied Resolve Rk. III",
            "Frenzied Stabbing Discipline",
        },
        ['Ambush'] = {
            "Beset Rk. III",
            "Beset Rk. II",
            "Beset",
            "Accost",
            "Assail",
            "Ambush",
            "Waylay",
        },
        ['SneakAttack'] = {
            "Daggerthrust Rk. III",
            "Daggerthrust Rk. II",
            "Daggerthrust",
            "Daggerstrike",
            "Daggerswipe",
            "Daggerlunge",
            "Swiftblade",
            "Razorarc",
            "Daggerfall",
            "Ancient: Chaos Strike",
            "Kyv Strike",
            "Sneak Attack",
        },
        ['PoisonBlade'] = {
            "Asp Blade Rk. III",
            "Asp Blade Rk. II",
            "Asp Blade",
            "Toxic Blade",
        },
        ['FellStrike'] = {
            "Mayhem",
            "Barrage",
            "Incursion",
            "Onslaught",
            "Battery",
            "Assault",
        },
        ['Pinpoint'] = {
            "Pinpoint Deficiencies Rk. III",
            "Pinpoint Deficiencies Rk. II",
            "Pinpoint Deficiencies",
            "Pinpoint Liabilities",
            "Pinpoint Flaws",
            "Pinpoint Vitals",
            "Pinpoint Weaknesses",
            "Pinpoint Vulnerability",
        },
        ['Puncture'] = {
        },
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
        ['CADisc'] = {
            "Counterattack Discipline",
        },
        ['EdgeDisc'] = {
        },
        ['AspDisc'] = {
            "Aspbleeder Discipline Rk. III",
            "Aspbleeder Discipline Rk. II",
            "Aspbleeder Discipline",
        },
        ['AimDisc'] = {
            "Fatal Aim Discipline Rk. III",
            "Fatal Aim Discipline Rk. II",
            "Fatal Aim Discipline",
            "Deadly Aim Discipline",
        },
        ['MarkDisc'] = {
            "Gullible Mark Rk. III",
            "Gullible Mark Rk. II",
            "Gullible Mark",
            "Gullible Mark",
            "Easy Mark",
        },
        ['Jugular'] = {
            "Jugular Lacerate Rk. III",
            "Jugular Lacerate Rk. II",
            "Jugular Lacerate",
            "Jugular Gash",
            "Jugular Sever",
            "Jugular Slice",
            "Jugular Slash",
        },
        ['Phantom'] = {
            "Phantom Assassin Rk. III",
            "Phantom Assassin Rk. II",
            "Phantom Assassin",
        },
        ['SecretBlade'] = {
            "Holdout Blade Rk. III",
            "Holdout Blade Rk. II",
            "Holdout Blade",
        },
        ['Dicho'] = {
        },
        ['Alliance'] = {
        },
        ['Knifeplay'] = {
            "Knifeplay Discipline Rk. III",
            "Knifeplay Discipline Rk. II",
            "Knifeplay Discipline",
        },
        ['HateDebuff'] = {          --Timer 11, Aggro reduction and Aggro modifier for current target
            "Beguile Animals",
            "Beguile Undead",
            "Beguile Plants",
            "Beguiler's Aura",
            "Beguile",
            "Disorientation",
            "Deceit",
            "Delusion",
            "Misdirection",
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
            name = 'Hide & Sneak',
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and Casting.AmIBuffable()
            end,
        },
        {
            name = 'Aggro Management',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctAggro() > (Config:GetSetting('HideAggro') or 90)
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
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck()
            end,
        },
        {
            name = 'CombatBuff',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
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
    ['Rotations']     = {
        ['Burn'] = {
            {
                name = "Frenzied",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "Twisted",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "Executioner",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "EdgeDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return self.Helpers.BurnDiscCheck(self)
                end,
            },
            {
                name = "Rogue's Fury",
                type = "AA",
            },
            {
                name = "Pinpoint",
                type = "Disc",
            },
            {
                name = "MarkDisc",
                type = "Disc",
            },
            {
                name = "Spire of the Rake",
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
                name = "PoisonBlade",
                type = "Disc",
            },
            {
                name = "Dicho",
                type = "Disc",
            },
            {
                name = "Shadow's Flanking",
                type = "AA",
            },
            {
                name = "Rake's Rampage",
                type = "AA",
                cond = function(self, aaName)
                    if not Config:GetSetting("DoAEDamage") then return false end
                    return Combat.AETargetCheck(true)
                end,
            },
            {
                name = "Focused Rake's Rampage",
                type = "AA",
                cond = function(self, aaName)
                    return not Config:GetSetting("DoAEDamage")
                end,
            },
            {
                name = "Phantom",
                type = "Disc",
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
        },
        ['Aggro Management'] = {
            {
                name = "Escape",
                type = "AA",
                cond = function(self, aaName, target)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Targeting.IHaveAggro(100)
                end,
            },
            {
                name = "Hide",
                type = "Ability",
                pre_activate = function(self, abilityName)
                    if Core.OnEMU() then
                        Core.DoCmd("/attack off")
                        mq.delay(100, function() return not mq.TLO.Me.Combat() end)
                    end
                end,
                cond = function(self)
                    return not mq.TLO.Me.Moving() or (mq.TLO.Me.AltAbility("Nimble Evasion").Rank() or 0) == 5
                end,
                post_activate = function(self, abilityName, success)
                    if not mq.TLO.Me.Combat() then
                        Core.DoCmd("/attack on")
                    end
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
                name = "Knifeplay",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "AspDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "ProcBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
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
                name = "Alliance",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoAlliance') then return false end
                    return not Casting.TargetHasBuff(discSpell.Trigger(1))
                end,
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                cond = function(self)
                    return Casting.SelfBuffItemCheck(Config:GetSetting('PoisonName'))
                end,
            },
            {
                name = "Assassin's Premonition",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.BurnCheck()
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Backstab",
                type = "Ability",
                cond = function(self, abilityName, target)
                    return Casting.CanUseAA("Chaotic Stab") or mq.TLO.Stick.Behind()
                end,
            },
            {
                name = "Slice",
                type = "Disc",
            },
            {
                name = "SecretBlade",
                type = "Disc",
            },
            {
                name = "FellStrike",
                type = "Disc",
            },
            {
                name = "Jugular",
                type = "Disc",
            },
            {
                name = "Twisted Shank",
                type = "AA",
            },
            {
                name = "Puncture",
                type = "Disc",
            },
            {
                name = "DaggerThrow",
                type = "Disc",
            },
            { --Check ToT to ensure we are not boosting the hate generation of someone we shouldn't be
                name = "HateDebuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.TargetIsATank(mq.TLO.Me.TargetOfTarget)
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                cond = function(self, abilityName)
                    return Casting.AARank("Intimidation") > 1
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Tumble",
                type = "AA",
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
                name = "CADisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Targeting.IHaveAggro(100)
                end,
            },
        },
        ['Downtime'] = {
            {
                name = "ThiefBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
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
                name = "PoisonClicky",
                type = "ClickyItem",
                active_cond = function(self, _)
                    return (mq.TLO.FindItemCount(Config:GetSetting('PoisonName'))() or 0) >= Config:GetSetting('PoisonItemCount')
                end,
                cond = function(self, _)
                    return (mq.TLO.FindItemCount(Config:GetSetting('PoisonName'))() or 0) < Config:GetSetting('PoisonItemCount') and
                        mq.TLO.Me.ItemReady(Config:GetSetting('PoisonClicky'))()
                end,
            },
            {
                name = "PoisonName",
                type = "ClickyItem",
                active_cond = function(self, _)
                    local poisonItem = mq.TLO.FindItem(Config:GetSetting('PoisonName'))
                    return poisonItem and poisonItem() and Casting.IHaveBuff(poisonItem.Spell.ID() or 0)
                end,
                cond = function(self)
                    return Casting.SelfBuffItemCheck(Config:GetSetting('PoisonName'))
                end,
            },
        },
        ['Hide & Sneak'] = {
            {
                name = "Hide & Sneak",
                type = "CustomFunc",
                active_cond = function(self)
                    return mq.TLO.Me.Invis() and mq.TLO.Me.Sneaking()
                end,
                pre_activate = function(self, abilityName)
                    if Core.OnEMU() and mq.TLO.Me.Combat() then
                        Core.DoCmd("/attack off")
                        mq.delay(100, function() return not mq.TLO.Me.Combat() end)
                    end
                end,
                cond = function(self)
                    return Config:GetSetting('DoHideSneak') and (not mq.TLO.Me.Sneaking() or not mq.TLO.Me.Invis())
                end,
                custom_func = function(self)
                    if not mq.TLO.Me.Sneaking() and mq.TLO.Me.AbilityReady("Sneak")() then
                        Core.DoCmd("/doability sneak")
                        mq.delay(200, function() return mq.TLO.Me.Sneaking() end)
                    end
                    if not mq.TLO.Me.Invis() and mq.TLO.Me.AbilityReady("Hide")() then
                        if not mq.TLO.Me.Moving() or (mq.TLO.Me.AltAbility("Nimble Evasion").Rank() or 0) == 5 then
                            Core.DoCmd("/doability hide")
                            mq.delay(100, function() return (mq.TLO.Me.AbilityTimer("Hide")() or 0) > 0 end)
                            ---@diagnostic disable-next-line: undefined-field
                        elseif mq.TLO.Me.Moving() and mq.TLO.Nav.Active() and not mq.TLO.Nav.Paused() then
                            -- let's get crazy: if we are naving, quickly pause and "sneak" a hide in
                            Movement:DoNav(false, "pause")
                            mq.delay(200, function() return not mq.TLO.Me.Moving() end)
                            mq.delay((2 * mq.TLO.EverQuest.Ping()) or 200) --addl delay to avoid "must be perfectly still..." server desync
                            Core.DoCmd("/doability hide")
                            mq.delay(100, function() return (mq.TLO.Me.AbilityTimer("Hide")() or 0) > 0 end)
                            ---@diagnostic disable-next-line: undefined-field
                            if mq.TLO.Nav.Paused() then Movement:DoNav(false, "pause") end
                        end
                    end
                end,
            },
        },
    },
    ['Helpers']       = {
        PreEngage = function(target)
            if not target or not target() then return end
            local openerAbility = Core.GetResolvedActionMapItem('SneakAttack')

            if not Config:GetSetting("DoOpener") or not openerAbility then return end

            Logger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility or "None")

            if mq.TLO.Me.CombatAbilityReady(openerAbility)() and not mq.TLO.Me.AbilityReady("Hide")() and mq.TLO.Me.AbilityTimer("Hide")() <= math.max(0, mq.TLO.Me.AbilityTimerTotal("Hide")() - 4000) and mq.TLO.Me.Invis() then
                Casting.UseDisc(openerAbility, target.ID())
                Logger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility or "None")
            else
                Logger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %s, Hide Ready = %s, Hide Timer = %d, Invis = %s", openerAbility or "None",
                    Strings.BoolToColorString(Config:GetSetting("DoOpener")), Strings.BoolToColorString(mq.TLO.Me.AbilityReady("Hide")()),
                    mq.TLO.Me.AbilityTimer("Hide")(), Strings.BoolToColorString(mq.TLO.Me.Invis()))
            end
        end,
        BurnDiscCheck = function(self)
            if mq.TLO.Me.ActiveDisc.Name() == "Counterattack Discipline" or mq.TLO.Me.PctHPs() < Config:GetSetting('EmergencyStart') then return false end
            local burnDisc = { "Frenzied", "Twisted", "Executioner", "EdgeDisc", }
            for _, buffName in ipairs(burnDisc) do
                local resolvedDisc = self:GetResolvedActionMapItem(buffName)
                if resolvedDisc and resolvedDisc.RankName() == mq.TLO.Me.ActiveDisc.Name() then return false end
            end
            return true
        end,
        UnwantedAggroCheck = function(self)
            if Targeting.GetXTHaterCount() == 0 or Core.IsTanking() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return Targeting.IHaveAggro(100)
        end,
    },
    ['DefaultConfig'] = {
        ['Mode']            = {
            DisplayName = "Mode",
            Category = "Combat",
            Tooltip = "Select the Combat Mode for this Toon",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes do?",
            Answer = "Currently Rogues only have DPS mode, this may change in the future",
        },
        -- Poison
        ['PoisonName']      = {
            DisplayName = "Poison Item",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click the poison you want to use here",
            Type = "ClickyItem",
            Default = "",
        },
        ['PoisonClicky']    = {
            DisplayName = "Poison Clicky",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click the poison summoner you want to use here",
            Type = "ClickyItem",
            Default = "",
        },
        ['PoisonItemCount'] = {
            DisplayName = "Poison Item Count",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 103,
            Tooltip = "Min number of poison before we start summoning more",
            Default = 3,
            Min = 1,
            Max = 50,
        },
        -- Abilities
        ['DoHideSneak']     = {
            DisplayName = "Do Hide/Sneak Click",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = "Use Hide/Sneak during Downtime",
            Default = false,
        },
        ['DoOpener']        = {
            DisplayName = "Use Openers",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Use Sneak Attack line to start combat (e.g, Daggerslash).",
            Default = true,
        },
        ['EmergencyStart']  = {
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
        ['HideAggro']       = {
            DisplayName = "Hide Aggro%",
            Group = "Abilities",
            Header = "Utility",
            Category = "Hate Reduction",
            Index = 101,
            Tooltip = "Your Aggro % before we will attempt to Hide from our current target.",
            Default = 90,
            Min = 1,
            Max = 100,
        },
        ['DoVetAA']         = {
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
        --Equipment
        ['UseEpic']         = {
            DisplayName = "Epic Use:",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 105,
            Tooltip = "Use Epic 1-Never 2-Burns 3-Always",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoChestClick']    = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 106,
            Tooltip = "Click your chest item during burns.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
        },
        ['DoCoating']       = {
            DisplayName = "Use Coating",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 107,
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
