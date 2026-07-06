local mq        = require('mq')
local Casting   = require("utils.casting")
local Config    = require('utils.config')
local Core      = require("utils.core")
local Globals   = require("utils.globals")
local Logger    = require("utils.logger")
local Strings   = require("utils.strings")
local Targeting = require("utils.targeting")

return {
    _version          = "DODL CUSTOM",
    -- 1.1 added Dicho to rotation -SCVOne
    -- 1.2 added Bfrenzy  timer 11 -SCVOne
    -- 1.3 seperated DPS into 3 sections to increase freq of attacks -SCVOne
    -- 1.4 Added toggle for Disconcering Disc, Fixed errors in burn phase with minor refactors --Algar

    _author           = "eldudero",
    ['Modes']         = {
        'DPS',
    },
    ['Themes']        = {
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.55, g = 0.05, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.55, g = 0.05, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.22, g = 0.02, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.55, g = 0.05, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.55, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.22, g = 0.02, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.55, g = 0.05, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.55, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.55, g = 0.05, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.36, g = 0.03, b = 0.03, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.55, g = 0.05, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.55, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.55, g = 0.05, b = 0.05, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.22, g = 0.02, b = 0.02, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.00, g = 0.35, b = 0.05, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.00, g = 0.35, b = 0.05, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.55, g = 0.05, b = 0.05, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Vengeful Taelosian Blood Axe",
            "Raging Taelosian Alloy Axe",
        },
        ['Coat'] = {
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
        ['BerAura'] = {
            "Bloodlust Aura",
            "Aura of Rage",
        },
        ['Dicho'] = {
        },
        ['Dfrenzy'] = {
            "Vanquishing Frenzy Rk. III",
            "Vanquishing Frenzy Rk. II",
            "Vanquishing Frenzy",
            "Conquering Frenzy",
            "Overwhelming Frenzy",
            "Overpowering Frenzy",
        },
        ['Bfrenzy'] = {
            "Fearless Frenzy Rk. III",
            "Fearless Frenzy Rk. II",
            "Fearless Frenzy",
            "Augmented Frenzy",
            "Steel Frenzy",
            "Fighting Frenzy",
            "Combat Frenzy",
            "Battle Frenzy",
        },
        ['Dvolley'] = {
            "Brutal Volley Rk. III",
            "Brutal Volley Rk. II",
            "Brutal Volley",
            "Sundering Volley",
            "Savage Volley",
            "Rage Volley",
        },
        ['Daxethrow'] = {
            "Brutal Axe Throw Rk. III",
            "Brutal Axe Throw Rk. II",
            "Brutal Axe Throw",
            "Spirited Axe Throw",
            "Energetic Axe Throw",
            "Vigorous Axe Throw",
        },
        ['Daxeof'] = {
            "Axe of Zurel Rk. III",
            "Axe of Zurel Rk. II",
            "Axe of Zurel",
            "Axe of Illdaera",
            "Axe of Graster",
            "Axe of Rallos",
        },
        ['Phantom'] = {
            "Phantom Assailant Rk. III",
            "Phantom Assailant Rk. II",
            "Phantom Assailant",
        },
        ['Alliance'] = {
        },
        ['CheapShot'] = {
            "Punch in the Throat Rk. III",
            "Punch in the Throat Rk. II",
            "Punch in the Throat",
            "Punch in The Throat",
            "Kick in the Teeth",
            "Slap in the Face",
        },
        ['AESlice'] = {
            "Arcblade Rk. III",
            "Arcblade Rk. II",
            "Arcblade",
        },
        ['AEVicious'] = {
            "Vicious Spiral Rk. III",
            "Vicious Spiral Rk. II",
            "Vicious Spiral",
        },
        ['FrenzyBoost'] = {
            "Augmented Frenzy Rk. III",
            "Augmented Frenzy Rk. II",
            "Augmented Frenzy",
        },
        ['RageStrike'] = {
            "Festering Rage Rk. III",
            "Festering Rage Rk. II",
            "Festering Rage",
        },
        ['SharedBuff'] = {
            "Shared Viciousness Rk. III",
            "Shared Viciousness Rk. II",
            "Shared Viciousness",
            "Shared Savagery",
            "Shared Brutality",
            "Shared Bloodlust",
        },
        ['PrimaryBurnDisc'] = {
            "Brutal Discipline Rk. III",
            "Brutal Discipline Rk. II",
            "Brutal Discipline",
            "Sundering Discipline",
            "Berserking Discipline",
        },
        ['CleavingDisc'] = {
            "Cleaving Acrimony Discipline Rk. III",
            "Cleaving Acrimony Discipline Rk. II",
            "Cleaving Acrimony Discipline",
            "Cleaving Anger Discipline",
            "Cleaving Rage Discipline",
        },
        ['FlurryDisc'] = {
            "Avenging Flurry Discipline Rk. III",
            "Avenging Flurry Discipline Rk. II",
            "Avenging Flurry Discipline",
            "Vengeful Flurry Discipline",
        },
        ['DisconDisc'] = {
        },
        ['ResolveDisc'] = {
        },
        ['HHEBuff'] = {
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
            "Ancient: Strike of Chaos",
            "Ancient: Bite of Chaos",
            "Ancient: Chaos Cry",
            "Ancient: Chaos Strike",
            "Ancient: Phantom Chaos",
            "Ancient: Pious Conscience",
            "Ancient: Force of Jeron",
            "Ancient: North Wind",
            "Ancient: Bite of Muram",
            "Ancient: Glacier Frost",
            "Ancient: Call of Power",
            "Ancient: Ancestral Calling",
            "Ancient: Curse of Mori",
            "Ancient: Core Fire",
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
            "Ancient: Cry of Chaos",
            "Battle Cry of the Mastruq",
            "War Cry of Dravel",
            "Battle Cry of Dravel",
            "War Cry",
            "Battle Cry",
        },
        ['CryDmg'] = {
            "Cry Carnage Rk. III",
            "Cry Carnage Rk. II",
            "Cry Carnage",
            "Cry Havoc",
        },
        ['Tendon'] = {
            "Tendon Gash Rk. III",
            "Tendon Gash Rk. II",
            "Tendon Gash",
            "Tendon Slash",
            "Tendon Lacerate",
            "Tendon Shear",
            "Tendon Sever",
            "Tendon Cleave",
            "Tendon Cleave",
        },
        ['SappingStrike'] = {
        },
        ['ReflexDisc'] = {
        },
        ['RestFrenzy'] = {
        },
        ['RetaliationDodge'] = {
            "Advanced Retaliation Rk. III",
            "Advanced Retaliation Rk. II",
            "Advanced Retaliation",
            "Early Retaliation",
        },
        ['TempleStun'] = {
            "Temple Crush Rk. III",
            "Temple Crush Rk. II",
            "Temple Crush",
            "Temple Smash",
            "Temple Chop",
            "Temple Bash",
            "Temple Strike",
            "Temple Blow",
        },
        ['JarringStrike'] = {
            "Jarring Crush Rk. III",
            "Jarring Crush Rk. II",
            "Jarring Crush",
            "Jarring Blow",
            "Jarring Slam",
            "Jarring Clash",
            "Jarring Smash",
            "Jarring Strike",
        },
        ['SnareDisc'] = {
            "Tendon Gash Rk. III",
            "Tendon Gash Rk. II",
            "Tendon Gash",
            "Tendon Slash",
            "Tendon Lacerate",
            "Tendon Shear",
            "Tendon Sever",
            "Tendon Cleave",
            "Crippling Strike",
            "Leg Slice",
            "Leg Cut",
            "Leg Strike",
        },
    },
    ['Charm']         = {
        ['Assist'] = {},
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
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('Timer10Disc') == 2 end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
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
            name = 'DPS',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS2',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        {
            name = 'DPS3',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
    },

    ['Rotations']     = {
        ['Downtime'] = {
            {
                name = "Summon Axes",
                type = "CustomFunc",
                custom_func = function(self)
                    if not Config:GetSetting('SummonAxes') then return false end

                    local AxeSkills = {
                        "Corroded Axe",
                        "Blunt Axe",
                        "Steel Axe",
                        "Bearded Axe",
                        "Mithril Axe",
                        "Balanced War Axe",
                        "Bonesplicer Axe",
                        "Fleshtear Axe",
                        "Cold Steel Cleaving Axe",
                        "Mithril Bloodaxe",
                        "Rage Axe",
                        "Bloodseeker's Axe",
                        "Battlerage Axe",
                        "Deathfury Axe",
                        "Tainted Axe of Hatred",
                        "Axe of The Destroyer",
                        "Axe of The Annihilator",
                        "Axe of The Decimator",
                        "Axe of The Eradicator",
                        "Axe of The Savage",
                        "Axe of the Sunderer",
                        "Axe of The Brute",
                        "Axe of The Demolisher",
                        "Axe of The Mangler",
                        "Axe of The Vindicator",
                        "Axe of the Conqueror",
                        "Axe of the Eviscerator",
                        "Axe of the Obliterator",
                    }

                    if not self.TempSettings.CachedAxeMap then
                        Logger.log_debug("\atCaching Axe Skill to Item Mapping...")
                        self.TempSettings.CachedAxeMap = {}
                        for _, axeSkill in ipairs(AxeSkills) do
                            local itemID = Casting.GetSummonedItemIDFromSpell(mq.TLO.Spell(axeSkill))
                            if itemID > 0 then
                                Logger.log_debug("\ayCached: \at%s\aw summons \am%d", axeSkill, itemID)
                                self.TempSettings.CachedAxeMap[itemID] = axeSkill
                            end
                        end
                    end

                    local abilitiesThatNeedAxes = {
                        { name = 'Dvolley',   count_name = 'AutoAxeCount', },
                        { name = 'Daxethrow', count_name = 'AutoAxeCount', },
                        { name = 'Daxeof',    count_name = 'AutoAxeCount', },
                        { name = 'Dicho',     count_name = 'DichoAxeCount', },
                        { name = 'SnareDisc', count_name = 'AutoAxeCount', },
                    }

                    local summonNeededItem = function(summonSkill, itemId, count)
                        local maxLoops = 10
                        while mq.TLO.FindItemCount(itemId)() < count do
                            Logger.log_debug("\ayWe need more %d because we dont have %d - using %s", itemId, count, summonSkill)
                            self.Helpers.SummonAxe(mq.TLO.Spell(summonSkill))
                            maxLoops = maxLoops - 1
                            if maxLoops <= 0 then return end
                        end
                    end

                    for _, ability in ipairs(abilitiesThatNeedAxes) do
                        local spell = self:GetResolvedActionMapItem(ability.name)
                        if spell and spell() then
                            for i = 1, 4 do
                                local requiredItemID = spell.ReagentID(i)()
                                if requiredItemID > 0 then
                                    local summonSkill = self.TempSettings.CachedAxeMap[requiredItemID]
                                    if summonSkill then
                                        Logger.log_verbose("\ayReagent(%d) for: \at%s\aw needs to use \am%s", i, ability.name, summonSkill)
                                        summonNeededItem(summonSkill, requiredItemID, Config:GetSetting(ability.count_name))
                                    end
                                end
                            end
                            for i = 1, 4 do
                                local requiredItemID = spell.NoExpendReagentID(i)()
                                if requiredItemID > 0 then
                                    local summonSkill = self.TempSettings.CachedAxeMap[requiredItemID]
                                    if summonSkill then
                                        Logger.log_verbose("\ayNoExpendReagent(%d) for: \at%s\aw needs to use \am%s", i, ability.name, summonSkill)
                                        summonNeededItem(summonSkill, requiredItemID, Config:GetSetting(ability.count_name))
                                    end
                                end
                            end
                        end
                    end
                end,
            },
            {
                name = "Communion of Blood",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctEndurance() <= 75
                end,
            },
            {
                name = "EndRegen",
                type = "Disc",
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() <= 21
                end,
            },
            {
                name = "BerAura",
                type = "Disc",
                cond = function(self, discSpell)
                    return not mq.TLO.Me.Aura(1).ID() and mq.TLO.Me.PctEndurance() > 10
                end,
            },
            {
                name = "Emergency Rage Cancel",
                type = "CustomFunc",
                custom_func = function(self)
                    if mq.TLO.Me.PctHPs() < 10 and mq.TLO.Me.Buff("Untamed Rage")() then
                        Core.DoCmd("/removebuff \"Untamed Rage\"")
                    end
                end,
            },
            {
                name = "ReflexDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
        },
        ['Snare'] = {
            {
                name = "SnareDisc",
                type = "Disc",
                cond = function(self, discSpell, target)
                    return Casting.DetSpellCheck(discSpell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
        },
        ['Burn'] = { --This really needs to be refactored with helper functions sometime. Other prioriities atm. Algar 3/2/25
            {
                name = "PrimaryBurnDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local discondisc = self:GetResolvedActionMapItem('DisconDisc')
                    return Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(discondisc).RankName()
                end,
            },
            {
                name = "Savage Spirit",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Juggernaut Surge",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Blood Pact",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Blinding Fury",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Silent Strikes",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Spire of the Juggernaut",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Desperation",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Focused Furious Rampage",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Untamed Rage",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Coat",
                type = "Item",
                cond = function(self, itemName)
                    return not mq.TLO.Me.PetBuff("Primal Fusion")()
                end,
            },
            {
                name = "CleavingDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return Casting.NoDiscActive() and not Casting.DiscReady(burndisc)
                end,
            },
            {
                name = "Reckless Abandon",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "Vehement Rage",
                type = "AA",
                cond = function(self, aaName)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(burndisc).RankName())
                end,
            },
            {
                name = "ResolveDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    local cleavingdisc = self:GetResolvedActionMapItem('CleavingDisc')
                    local discondisc = self:GetResolvedActionMapItem('DisconDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(discondisc).RankName())
                        and not (Casting.DiscReady(burndisc) or Casting.DiscReady(cleavingdisc))
                end,
            },
            {
                name = "FlurryDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    local burndisc = self:GetResolvedActionMapItem('PrimaryBurnDisc')
                    local cleavingdisc = self:GetResolvedActionMapItem('CleavingDisc')
                    local discondisc = self:GetResolvedActionMapItem('DisconDisc')
                    local resolvedisc = self:GetResolvedActionMapItem('ResolveDisc')
                    return (Casting.NoDiscActive() or mq.TLO.Me.ActiveDisc() == mq.TLO.Spell(discondisc).RankName())
                        and not (Casting.DiscReady(burndisc) or Casting.DiscReady(cleavingdisc) or Casting.DiscReady(resolvedisc))
                end,
            },
            {
                name = "Braxi's Howl",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "HHEBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return not Casting.AAReady("Braxi's Howl") and Casting.NoDiscActive() and Casting.SelfBuffCheck(discSpell)
                end,
            },
        },
        ['DPS'] = {
            {
                name = "Epic",
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoEpic') then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Frenzy",
                type = "Ability",
            },
            {
                name = "Dfrenzy",
                type = "Disc",
            },
            {
                name = "Dvolley",
                type = "Disc",
            },
            {
                name = "Daxeof",
                type = "Disc",
            },
            {
                name = "Daxethrow",
                type = "Disc",
                load_cond = function(self) return Config:GetSetting('Timer10Disc') == 1 end,
            },
            {
                name = "SharedBuff",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "RageStrike",
                type = "Disc",
            },
            {
                name = "Phantom",
                type = "Disc",
                cond = function(self, discSpell)
                    return Config:GetSetting('DoPet')
                end,
            },
            {
                name = "SappingStrike",
                type = "Disc",
            },
            {
                name = "Binding Axe",
                type = "AA",
            },
            {
                name = "Intimidation",
                type = "Ability",
                load_cond = function(self) return Casting.AARank("Intimidation") > 1 end,
            },
            {
                name = "AESlice",
                type = "Disc",
                cond = function(self, discSpell)
                    return Config:GetSetting('DoAoe')
                end,
            },
            {
                name = "Alliance",
                type = "Spell",
                cond = function(self, spell)
                    return Config:GetSetting('DoAlliance') and Casting.CanAlliance() and
                        not Casting.TargetHasBuff(spell)
                end,
            },
            {
                name = "BraxiChain",
                type = "CustomFunc",
                custom_func = function(self)
                    if not Casting.AAReady("Braxi's Howl") then return false end
                    local ret = false
                    ret = ret or Casting.UseAA("Braxi's Howl", Globals.AutoTargetID)
                    ret = ret or Casting.UseDisc(self.ResolvedActionMap['Dicho'], Globals.AutoTargetID)

                    return ret
                end,
            },
            {
                name = "DisconDisc",
                type = "Disc",
                cond = function(self, discSpell)
                    if not Config:GetSetting('DoDisconDisc') then return false end
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Bloodfury",
                type = "AA",
                cond = function(self, aaName)
                    return Casting.DiscReady(self.ResolvedActionMap['FrenzyBoost']) and mq.TLO.Me.PctHPs() >= 90
                end,
            },
            {
                name = "FrenzyBoost",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "CryDmg",
                type = "Disc",
                cond = function(self, discSpell)
                    return Casting.SelfBuffCheck(discSpell)
                end,
            },
            {
                name = "Communion of Blood",
                type = "AA",
                cond = function(self, aaName)
                    return mq.TLO.Me.PctEndurance() <= 75
                end,
            },
        },
        ['DPS2'] = {
            {
                name = "Battle Leap",
                type = "AA",
                cond = function(self, aaName)
                    return Config:GetSetting('DoBattleLeap') and not Casting.IHaveBuff("Battle Leap Warcry") and
                        not Casting.IHaveBuff("Group Bestial Alignment")
                        and not mq.TLO.Me.HeadWet() --Stops Leap from launching us above the water's surface
                end,
            },
            {
                name = "Drawn to Blood",
                type = "AA",
                cond = function(self, aaName)
                    return Targeting.GetTargetDistance() > 15
                end,
            },
        },
        ['DPS3'] = {
            {
                name = "Dicho",
                type = "Disc",
            },
            {
                name = "Bfrenzy",
                type = "Disc",
            },
        },
    },
    ['Helpers']       = {
        SummonAxe = function(axeDisc)
            if not axeDisc or not axeDisc() then return false end
            Logger.log_verbose("\aySummonAxe(): Checking if %s is ready.", axeDisc.Name())
            if not Casting.DiscReady(axeDisc) then return false end
            Logger.log_verbose("\aySummonAxe(): Checking AutoAxeAcount")
            if Config:GetSetting('AutoAxeCount') == 0 then return false end
            if mq.TLO.FindItemCount(axeDisc)() > Config:GetSetting('AutoAxeCount') then return false end

            Logger.log_verbose("\aySummonAxe(): Checking For Reagents")
            if mq.TLO.FindItemCount(axeDisc.ReagentID(1)())() == 0 then return false end

            if mq.TLO.Cursor.ID() ~= nil then Core.DoCmd("/autoinv") end
            local ret = Casting.UseDisc(axeDisc, mq.TLO.Me.ID())
            Logger.log_verbose("\aySummonAxe(): Summoning the Axe.")
            mq.delay(500, function() return mq.TLO.Cursor.ID() ~= nil end)
            while mq.TLO.Cursor.ID() ~= nil do Core.DoCmd("/autoinv") end
            return ret
        end,
        PreEngage = function(target)
            if not target or not target() then return end
            local openerAbility = Core.GetResolvedActionMapItem('CheapShot')

            if not openerAbility then return end

            Logger.log_debug("\ayPreEngage(): Testing Opener ability = %s", openerAbility or "None")

            if openerAbility and mq.TLO.Me.CombatAbilityReady(openerAbility)() and mq.TLO.Me.PctEndurance() >= 5 and Config:GetSetting("DoOpener") and Targeting.GetTargetDistance() < 50 then
                Casting.UseDisc(openerAbility, target.ID())
                Logger.log_debug("\agPreEngage(): Using Opener ability = %s", openerAbility or "None")
            else
                Logger.log_debug("\arPreEngage(): NOT using Opener ability = %s, DoOpener = %s, Distance to Target = %d, Endurance = %d", openerAbility or "None",
                    Strings.BoolToColorString(Config:GetSetting("DoOpener")), Targeting.GetTargetDistance(), mq.TLO.Me.PctEndurance() or 0)
            end
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
            FAQ = "What do the different modes do?",
            Answer = "Currently Berserkers Only have DPS mode.",
        },
        ['DoEpic']          = {
            DisplayName = "Do Epic",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Tooltip = "Enable using your epic clicky",
            Default = true,
        },
        ['DoOpener']        = {
            DisplayName = "Use Openers",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Use Opening Arrow Shot Silent Shot Line.",
            Default = true,
        },
        ['DoBattleLeap']    = {
            DisplayName = "Do Battle Leap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Tooltip = "Enable using Battle Leap",
            Default = true,
        },
        ['DoAoe']           = {
            DisplayName = "Do AoE",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Tooltip = "Enable using AoE Abilities",
            Default = true,
        },
        ['SummonAxes']      = {
            DisplayName = "Summon Axes",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 101,
            Tooltip = "Enable Summon Axes",
            Default = true,
        },
        ['AutoAxeCount']    = {
            DisplayName = "Auto Axe Count",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 102,
            Tooltip = "Summon more Primary Axes when you hit [x] left.",
            Default = 100,
            Min = 0,
            Max = 600,
        },
        ['DichoAxeCount']   = {
            DisplayName = "Auto Dicho Axe Count",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 104,
            Tooltip = "Summon more Dicho Axes when you hit [x] left.",
            Default = 100,
            Min = 0,
            Max = 600,
        },
        ['SummonDichoAxes'] = {
            DisplayName = "Summon Dicho Axes",
            Group = "Items",
            Header = "Item Summoning",
            Category = "Item Summoning",
            Index = 103,
            Tooltip = "Enable Summon Dicho Axes",
            Default = true,
        },
        ['DoDisconDisc']    = {
            DisplayName = "Do Discon Disc",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Tooltip = "Enable using Disconcerting Discipline",
            Default = true,
        },
        ['Timer10Disc']     = {
            DisplayName = "Timer 10 Disc Choice",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "Choose between your Axe Throw Disc or Snare Disc (Leg/Tendon line). The timer is shared.",
            Type = "Combo",
            ComboOptions = { 'Throw Disc', 'Snare Disc', },
            Default = 1,
            Min = 1,
            Max = 2,
            RequiresLoadoutChange = true,
        },
        ['SnareCount']      = {
            DisplayName = "Snare Max Mob Count",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 101,
            Tooltip = "Only use snare if there are [x] or fewer mobs on aggro. Helpful for AoE groups.",
            Default = 3,
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
