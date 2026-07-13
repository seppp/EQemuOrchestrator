--- @type Mq
local mq           = require('mq')
local Casting      = require("utils.casting")
local Combat       = require("utils.combat")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require("utils.globals")
local ItemManager  = require('utils.item_manager')
local Logger       = require("utils.logger")
local Targeting    = require("utils.targeting")

local Tooltips     = {
    Epic            = 'Item: Casts Epic Weapon Ability',
    AriaSong        = "Song Line: Spell Damage Focus / Haste v3 Modifier",
    WarMarchSong    = "Song Line: Melee Haste / DS / STR/ATK Increase",
    SufferingSong   = "Song Line: Melee Proc With Damage and Aggro Reduction",
    SpitefulSong    = "Song Line: Increase AC / Aggro Increase Proc",
    SprySonataSong  = "Song Line: Magic Asorb / AC Increase / Mitigate Damage Shield / Resist Spells",
    DotBuffSong     = "Song Line: Fire and Magic DoT Modifier",
    CrescendoSong   = "Song Line: Group v2 Increase Hit Points and Mana",
    ArcaneSong      = "Song Line: Group Melee and Spell Proc",
    InsultSong      = "Song Line: Single Target DD (Group Spell Proc Effect at higher levels)",
    DichoSong       = "Song Line: HP/Mana/End Increase / Melee and Caster Damage Increase",
    BardDPSAura     = "Aura Line: OverHaste / Melee and Caster DPS",
    BardRegenAura   = "Aura Line: HP/Mana Regen",
    AreaRegenSong   = "Song Line: AE HP/Mana Regen",
    GroupRegenSong  = "Song Line: Group HP/Mana Regen",
    FireBuffSong    = "Song Line: Fire DD Spell Damage Increase and Effiency",
    SlowSong        = "Song Line: ST Melee Attack Slow",
    AESlowSong      = "Song Line: PBAE Melee Attack Slow",
    AccelerandoSong = "Song Line: Reduce Beneficial Spell Casttime / Aggro Reduction Modifier",
    RecklessSong    = "Song Line: Increase Crit Heal and Crit HoT Chance",
    ColdBuffSong    = "Song Line: Cold DD Damage Increase and Effiency",
    FireDotSong     = "Song Line: Fire DoT and minor resist debuff",
    DiseaseDotSong  = "Song Line: Disease DoT and minor resist debuff",
    PoisonDotSong   = "Song Line: Poison DoT and minor resist debuff",
    IceDotSong      = "Song Line: Ice DoT and minor resist debuff",
    EndBreathSong   = "Song Line: Enduring Breath",
    CureSong        = "Song Line: Single Target Cure: Poison/Disease/Corruption",
    AllianceSong    = "Song Line: Mob Debuff Increase Insult Damage for other Bards",
    CharmSong       = "Song Line: Charm Mob",
    ReflexStrike    = "Disc Line: Attack 4 times to restore Mana to Group",
    ChordsAE        = "Song Line: PBAE Damage if Target isn't moving",
    AmpSong         = "Song Line: Increase Singing Skill",
    DispelSong      = "Song Line: Dispel a Benefical Effect",
    ResistSong      = "Song Line: Damage Shield / Group Resist Increase",
    MezSong         = "Song Line: Single Target Mez",
    MezAESong       = "Song Line: PBAE Mez",
    Bellow          = "AA: DD + Resist Debuff that leads to a much larger DD upon expiry",
    Spire           = "AA: Lowers Incoming Melee Damage / Increases Melee and Spell Damage",
    FuneralDirge    = "AA: DD / Increases Melee Damage Taken on Target",
    FierceEye       = "AA: Increases Base and Crit Melee Damage / Increase Proc Rate / Increase Spell Crit Chance",
    QuickTime       = "AA: Hundred Hands Effect / Increase Melee Hit / Increase Atk",
    BladedSong      = "AA: Reverse Damage Shield",
    Jonthan         = "Song Line: (Self-only) Haste / Melee Damage Modifier / Melee Min Damage Modifier / Proc Modifier",
}

local _ClassConfig = {
    _version          = "DODL CUSTOM",
    _author           = "eldudero",
    ['Modes']         = {
        'General',
    },
    ['OnModeChange']  = function(self, mode)
        local warMarch = Core.GetResolvedActionMapItem('WarMarchSong')
        if warMarch then
            self.TempSettings.MarchDuration = warMarch.MyDuration.TotalSeconds() or 0
        end
    end,

    ['ModeChecks']    = {
        CanMez    = function() return true end,
        CanCharm  = function() return true end,
        IsMezzing = function() return Config:GetSetting('MezOn') end,
        IsCuring  = function() return Config:GetSetting('UseCure') end,
    },
    ['Cure']          = {
        ['Poison'] = {
            { type = "Song", name = "CureSong", },
        },
        ['Disease'] = {
            { type = "Song", name = "CureSong", },
        },
        ['Corruption'] = {
            { type = "Song", name = "CureSong", },
        },
    },
    ['Themes']        = {
        ['General'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.20, g = 0.03, b = 0.14, a = 0.8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.20, g = 0.03, b = 0.14, a = 0.8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.50, g = 0.08, b = 0.35, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.33, g = 0.05, b = 0.23, a = 0.8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.50, g = 0.08, b = 0.35, a = 0.8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.50, g = 0.08, b = 0.35, a = 0.1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.20, g = 0.03, b = 0.14, a = 0.8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.00, g = 0.80, b = 0.10, a = 0.8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.00, g = 0.80, b = 0.10, a = 0.9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.50, g = 0.08, b = 0.35, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
            "Blade of Vesagran",
            "Prismatic Dragon Blade",
        },
        ['Coating'] = {
        },
    },
    ['AbilitySets']   = {
        ['RunBuffSong'] = {
            "Selo's Song of Travel",
            "Selo's Accelerating Chorus",
            "Selo's Accelerando",
        },
        ['EndBreathSong'] = {
        },
        ['AriaSong'] = {
            "Aria of the Orator Rk. III",
            "Aria of the Orator Rk. II",
            "Aria of the Orator",
            "Aria of the Composer",
            "Aria of the Poet",
            "Aria of the Artist",
            "Ancient: Call of Power",
            "Echo of the Trusik",
            "Call of the Muse",
        },
        ['OverhasteSong'] = {            -- before effects are combined in aria
            "Warsong of Zek",
            "Warsong of the Vah Shir",
            "Battlecry of the Vah Shir",
        },
        ['SpellDmgSong'] = {             -- before effects are combined in aria
        },
        ['SufferingSong'] = {
            "Storm Strength",
            "Storm's Fury",
            "Stormwatch",
            "Storm of Arrows",
            "Storm of Arrows Rk. II",
            "Storm of Arrows Rk. III",
            "Stormwheel Blades",
            "Stormwheel Blades Rk. II",
            "Stormwheel Blades Rk. III",
            "Storm of Blades",
            "Storm of Blades Rk. II",
            "Storm of Blades Rk. III",
            "Storm Blade",
            "Song of the Storm",
        },
        ['SprySonataSong'] = {
            "Dance of the Dragorn Rk.III",
            "Dance of the Dragorn Rk.II",
            "Dance of the Dragorn",
            "Psalm of Mystic Shielding",
        },
        ['CrescendoSong'] = {
        },
        ['ArcaneSong'] = {
            "Arcane Hymn Rk. III",
            "Arcane Hymn Rk. II",
            "Arcane Hymn",
            "Arcane Address",
            "Arcane Chorus",
            "Arcane Arietta",
            "Arcane Anthem",
            "Arcane Aria",
        },
        ['InsultSong'] = {     --alternating timers are necessary to always use the best when the user only opts to use one insult
        },
        ['InsultSong2'] = {
        },
        ['LLInsultSong'] = {    -- use the lowest we have until we have a nopush, then use that
        },
        ['LLInsultSong2'] = {   -- use the lowest we have until we have a nopush, then use that
        },
        ['DichoSong'] = {
        },
        ['BardDPSAura'] = {
            "Aura of the Orator Rk. III",
            "Aura of the Orator Rk. II",
            "Aura of the Orator",
            "Aura of the Composer",
            "Aura of the Poet",
            "Aura of the Artist",
            "Aura of the Muse",
            "Aura of Insight",
        },
        ['BardRegenAura'] = {
            "Aura of Salarra Rk. III",
            "Aura of Salarra Rk. II",
            "Aura of Salarra",
            "Aura of Lunanyn",
            "Aura of Renewal",
            "Aura of Rodcet",
        },
        ['GroupRegenSong'] = (function()
            local songs = {
                "Pulse of Salarra Rk. III",
                "Pulse of Salarra Rk. II",
                "Pulse of Salarra",
                "Pulse of Lunanyn",
                "Pulse of Renewal",
                "Cantata of Rodcet",
                "Cantata of Restoration",
                "Cantata of Life",
                "Wind of Marr",
                "Cantata of Replenishment",
            }
            if mq.TLO.Me.Level() < 34 or mq.TLO.Me.Level() >= 55 then
                table.insert(songs, "Cantata of Soothing")
            end
            table.insert(songs, "Cassindra's Chorus of Clarity")
            table.insert(songs, "Cassindra's Chant of Clarity")
            table.insert(songs, "Hymn of Restoration")
            return songs
        end)(),
        ['AreaRegenSong'] = {
            "Chorus of Salarra Rk. III",
            "Chorus of Salarra Rk. II",
            "Chorus of Salarra",
            "Chorus of Lunanyn",
            "Chorus of Renewal",
            "Chorus of Rodcet",
            "Chorus of Restoration",
            "Chorus of Life",
            "Chorus of Marr",
            "Chorus of Replenishment",
        },
        ['WarMarchSong'] = {
            "War March of Protan Rk. III",
            "War March of Protan Rk. II",
            "War March of Protan",
            "War March of Illdaera",
            "War March of Dagda",
            "War March of Brekt",
            "War March of Meldrath",
            "War March of Muram",
            "War March of the Mastruq",
            "Warsong of Zek",
            "Verses of Victory",
            "Anthem de Arms",
            "Chant of Battle",
        },
        ['FireBuffSong'] = {
        },
        ['SlowSong'] = {
            "Requiem for the Lost",
            "Requiem for the Lost Rk. II",
            "Requiem for the Lost Rk. III",
            "Requiem of Time",
        },
        ['AESlowSong'] = {
            "Melody of Ervaj",
            "Melody of Mischief",
        },
        ['AccelerandoSong'] = {
            "Ameliorating Accelerando Rk. III",
            "Ameliorating Accelerando Rk. II",
            "Ameliorating Accelerando",
            "Assuaging Accelerando",
            "Alleviating Accelerando",
        },
        ['SpitefulSong'] = {
        },
        ['RecklessSong'] = {
        },
        ['ColdBuffSong'] = {
            "Fatesong of Protan Rk. III",
            "Fatesong of Protan Rk. II",
            "Fatesong of Protan",
            "Fatesong of Illdaera",
            "Fatesong of Fergar",
            "Fatesong of the Gelidran",
        },
        ['DotBuffSong'] = {
        },
        ['FireDotSong'] = {
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
            "Ancient: Cry of Chaos",
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
            "Ancient: Chaos Chant",
        },
        ['IceDotSong'] = {
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
            "Ancient: Cry of Chaos",
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
            "Ancient: Chaos Chant",
        },
        ['PoisonDotSong'] = {
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
            "Ancient: Cry of Chaos",
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
            "Ancient: Chaos Chant",
        },
        ['DiseaseDotSong'] = {
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
            "Ancient: Cry of Chaos",
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
            "Ancient: Chaos Chant",
        },
        ['CureSong'] = {
            "Aria of Absolution Rk. III",
            "Aria of Absolution Rk. II",
            "Aria of Absolution",
            "Aria of Impeccability",
            "Aria of Amelioration",
            "Aria of Asceticism",
        },
        ['AllianceSong'] = {
        },
        ['CharmSong'] = {
            "Voice of Motlak Rk. III",
            "Voice of Motlak Rk. II",
            "Voice of Motlak",
            "Voice of Kolain",
            "Voice of Sionachie",
            "Voice of the Mindshear",
            "Yowl of the Bloodmoon",
            "Beckon of the Tuffein",
            "Voice of the Vampire",
            "Call of the Banshee",
        },
        ['ReflexStrike'] = {
            "Reflexive Retort Rk. III",
            "Reflexive Retort Rk. II",
            "Reflexive Retort",
        },
        ['ChordsAE'] = {
            "Chords of Dissonance",
        },
        ['AmpSong'] = {
            "Amplification",
        },
        ['DispelSong'] = {
        },
        ['ResistSong'] = {
            "Psalm of the Forsaken Rk. III",
            "Psalm of the Forsaken Rk. II",
            "Psalm of the Forsaken",
            "Psalm of Veeshan",
            "Psalm of Purity",
            "Psalm of Cooling",
            "Psalm of Vitality",
            "Psalm of Warmth",
        },
        ['MezSong'] = {
            "Slumber of Motlak Rk. III",
            "Slumber of Motlak Rk. II",
            "Slumber of Motlak",
            "Slumber of Kolain",
            "Slumber of Sionachie",
            "Slumber of the Mindshear",
            "Command of Queen Veneneu",
            "Creeping Dreams",
            "Lullaby of Morell",
            "Dreams of Terris",
            "Dreams of Thule",
            "Dreams of Ayonae",
            "Song of Twilight",
        },
        ['MezAESong'] = {
            "Wave of Quietude Rk. III",
            "Wave of Quietude Rk. II",
            "Wave of Quietude",
            "Wave of the Conductor",
            "Wave of Dreams",
            "Wave of Slumber",
        },
        ['Jonthan'] = {
        },
        ['CalmSong'] = {
            "Silence of the Forsaken Rk. III",
            "Silence of the Forsaken Rk. II",
            "Silence of the Forsaken",
            "Silence of the Windsong",
            "Silence of the Dreamer",
            "Silence of the Void",
            "Whispersong of Veshma",
            "Silent Song of Quellious",
        },
        ['ThousandBlades'] = {
            "Thousand Blades",
        },
    },
    ['Helpers']       = {
        SwapInst = function(type)
            if not Config:GetSetting('SwapInstruments') then return end
            Logger.log_verbose("\ayBard SwapInst(): Swapping to Instrument Type: %s", type)
            if type == "Percussion Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('PercInst'))
                return
            elseif type == "Wind Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('WindInst'))
                return
            elseif type == "Brass Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('BrassInst'))
                return
            elseif type == "Stringed Instruments" then
                ItemManager.SwapItemToSlot("offhand", Config:GetSetting('StringedInst'))
                return
            end
            ItemManager.SwapItemToSlot("offhand", Config:GetSetting('Offhand'))
        end,
        CheckSongStateUse = function(self, config) --determine whether a song should be sung by comparing combat state to settings
            local usestate = Config:GetSetting(config)
            local inCombat = Globals.CurrentState == "Combat"
            if usestate == 1 then return false end        -- Never
            if usestate == 3 then return true end         -- Always
            if usestate == 2 then return inCombat end     -- In-Combat Only
            if usestate == 4 then return not inCombat end -- Out-of-Combat Only
            return false
        end,
        GetSongBuffer = function() --seconds of remaining duration at which a buff song is resung
            return Config:GetSetting('SongRefresh')
        end,
        RefreshBuffSong = function(self, songSpell) --true once a buff song's remaining duration drops to the resing buffer (a dropped song reads 0 and resings)
            if not songSpell or not songSpell() then return false end
            local me = mq.TLO.Me
            local remaining = songSpell.DurationWindow() == 1
                and (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0)
                or (me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0)
            if self.TempSettings.upkeepFill then
                local full = Config:GetSetting('SongDuration', true) or songSpell.MyDuration.TotalSeconds()
                return remaining < full - self.Helpers.GetSongBuffer()
            end
            return remaining <= self.Helpers.GetSongBuffer()
        end,
        MarchTimer = function(self) --minimum gap between War March resings
            local interval = (self.TempSettings.MarchDuration or 12) - self.Helpers.GetSongBuffer()
            return (Globals.GetTimeSeconds() - (self.TempSettings.LastMarchCast or 0)) >= interval
        end,
        RefreshExpiringSong = function(self) --idle upkeep: resing the active song closest to expiring
            local melody = self.TempSettings.RotationTable['Melody']
            if not melody then return false end
            local me = mq.TLO.Me
            local pick, pickRemaining = nil, nil
            self.TempSettings.upkeepFill = true
            for _, entry in ipairs(melody) do
                local songSpell = Core.GetResolvedActionMapItem(entry.name)
                if songSpell and songSpell() and entry.cond and Core.SafeCallFunc("upkeep want", entry.cond, self, songSpell, me) then
                    local remaining = songSpell.DurationWindow() == 1
                        and (me.Song(songSpell.Name()).Duration.TotalSeconds() or 0)
                        or (me.Buff(songSpell.Name()).Duration.TotalSeconds() or 0)
                    if remaining > 0 and Casting.SongReady(songSpell) and (not pickRemaining or remaining < pickRemaining) then
                        pick, pickRemaining = songSpell, remaining
                    end
                end
            end
            self.TempSettings.upkeepFill = false
            if pick then return Casting.UseSong(pick.RankName(), me.ID(), false) end
            return false
        end,
        UnwantedAggroCheck = function(self)
            if Targeting.GetXTHaterCount() == 0 or Core.IsTanking() or mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then return false end
            return Targeting.IHaveAggro(100)
        end,
        DotSongCheck = function(songSpell) --Check dot stacking, stop dotting when HP threshold is reached based on mob type, can't use utils function because we try to refresh just as the dot is ending
            if not songSpell or not songSpell() then return false end
            return songSpell.StacksTarget() and Targeting.MobNotLowHP(Targeting.GetAutoTarget())
        end,
        GetDetSongDuration = function(songSpell) -- Checks target for duration remaining on dot songs
            local duration = mq.TLO.Target.FindBuff("name " .. "\"" .. songSpell.Name() .. "\"").Duration.TotalSeconds() or 0
            Logger.log_debug("getDetSongDuration() Current duration for %s : %d", songSpell, duration)
            return duration
        end,

    },
    ['SpellList']     = { -- New style spell list, gemless, priority-based. Will use the first set whose conditions are met.
        {
            name = "Default Mode",
            -- cond = function(self) return true end, --Code kept here for illustration, if there is no condition to check, this line is not required
            spells = {
                --role and critical functions
                { name = "MezAESong",     cond = function(self) return Config:GetSetting('DoAEMez') end, },
                { name = "MezSong",       cond = function(self) return Config:GetSetting('DoSTMez') end, },
                { name = "CharmSong",     cond = function(self) return Config:GetSetting('CharmOn') end, },
                { name = "SlowSong",      cond = function(self) return Config:GetSetting('DoSTSlow') end, },
                { name = "AESlowSong",    cond = function(self) return Config:GetSetting('DoAESlow') end, },
                { name = "DispelSong",    cond = function(self) return Config:GetSetting('DoDispel') end, },
                { name = "CureSong",      cond = function(self) return Config:GetSetting('UseCure') end, },
                { name = "RunBuffSong",   cond = function(self) return (Config:GetSetting('UseRunBuff') > 1 or Config:GetSetting('ChaseOn')) and not Casting.CanUseAA("Selo's Sonata") end, },
                { name = "EndBreathSong", cond = function(self) return Config:GetSetting('UseEndBreath') end, },

                -- main group dps
                { name = "WarMarchSong",  cond = function(self) return Config:GetSetting('UseMarch') > 1 end, },
                { name = "AriaSong",      cond = function(self) return Config:GetSetting('UseAria') > 1 end, },
                {
                    name = "OverhasteSong",
                    cond = function(self)
                        return not Core.GetResolvedActionMapItem('AriaSong') and Config:GetSetting('LLAria') == 2 and Config:GetSetting('UseAria') > 1
                    end,
                },
                {
                    name = "SpellDamageSong",
                    cond = function(self)
                        return not Core.GetResolvedActionMapItem('AriaSong') and Config:GetSetting('LLAria') == 3 and Config:GetSetting('UseAria') > 1
                    end,
                },
                { name = "ArcaneSong",     cond = function(self) return Config:GetSetting('UseArcane') > 1 end, },
                { name = "DichoSong",      cond = function(self) return Config:GetSetting('UseDicho') > 1 end, },
                -- regen songs
                { name = "GroupRegenSong", cond = function(self) return Config:GetSetting('RegenSong') == 2 end, },
                { name = "AreaRegenSong",  cond = function(self) return Config:GetSetting('RegenSong') == 3 end, },
                { name = "CrescendoSong",  cond = function(self) return Config:GetSetting('UseCrescendo') end, },
                { name = "AmpSong",        cond = function(self) return Config:GetSetting('UseAmp') > 1 end, },
                -- self dps songs
                { name = "AllianceSong",   cond = function(self) return Config:GetSetting('UseAlliance') end, },
                {
                    name = "InsultSong",
                    cond = function(self)
                        return Config:GetSetting('UseInsult') > 1 and (not Config:GetSetting('UseLLInsult') or not Core.GetResolvedActionMapItem('LLInsultSong'))
                    end,
                },
                { name = "LLInsultSong",   cond = function(self) return Config:GetSetting('UseInsult') > 1 and Config:GetSetting('UseLLInsult') end, },
                { name = "FireDotSong",    cond = function(self) return Config:GetSetting('UseFireDots') end, },
                { name = "IceDotSong",     cond = function(self) return Config:GetSetting('UseIceDots') end, },
                { name = "PoisonDotSong",  cond = function(self) return Config:GetSetting('UsePoisonDots') end, },
                { name = "DiseaseDotSong", cond = function(self) return Config:GetSetting('UseDiseaseDots') end, },
                { name = "Jonthan",        cond = function(self) return Config:GetSetting('UseJonthan') > 1 end, },
                {
                    name = "InsultSong2",
                    cond = function(self)
                        return Config:GetSetting('UseInsult') == 3 and (not Config:GetSetting('UseLLInsult') or not Core.GetResolvedActionMapItem('LLInsultSong'))
                    end,
                },
                { name = "LLInsultSong2",   cond = function(self) return Config:GetSetting('UseInsult') == 3 and Config:GetSetting('UseLLInsult') end, },
                -- melee dps songs
                { name = "SufferingSong",   cond = function(self) return Config:GetSetting('UseSuffering') > 1 end, },
                -- caster dps songs
                { name = "FireBuffSong",    cond = function(self) return Config:GetSetting('UseFireBuff') > 1 end, },
                { name = "ColdBuffSong",    cond = function(self) return Config:GetSetting('UseColdBuff') > 1 end, },
                { name = "DotBuffSong",     cond = function(self) return Config:GetSetting('UseDotBuff') > 1 end, },
                -- healer songs
                { name = "AccelerandoSong", cond = function(self) return Config:GetSetting('UseAccelerando') > 1 end, },
                { name = "RecklessSong",    cond = function(self) return Config:GetSetting('UseReckless') > 1 end, },
                -- tank songs
                { name = "SpitefulSong",    cond = function(self) return Config:GetSetting('UseSpiteful') > 1 end, },
                { name = "SprySonataSong",  cond = function(self) return Config:GetSetting('UseSpry') > 1 end, },
                { name = "ResistSong",      cond = function(self) return Config:GetSetting('UseResist') > 1 end, },
                -- filler
                { name = "CalmSong",        cond = function(self) return true end, }, -- condition not needed, for uniformity
            },
        },
    },
    ['Mez']           = {
        { type = "AA",   name = "Dirge of the Sleepwalker", cond = function() return Config:GetSetting('DoAAMez') end, },
        { type = "Song", name = "MezSong", },
        { type = "Song", name = "MezAESong", },
    },
    ['Charm']         = {
        ['Abilities'] = {
            { name = "CharmSong", type = "Song", },
        },
    },
    ['RotationOrder'] = {
        {
            name = 'Enduring Breath',
            state = 1,
            steps = 1,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            load_cond = function(self) return Config:GetSetting('UseEndBreath') and Core.GetResolvedActionMapItem('EndBreathSong') end,
            cond = function(self, combat_state)
                return not (combat_state == "Downtime" and mq.TLO.Me.Invis()) and (mq.TLO.Me.FeetWet() or mq.TLO.Zone.ShortName() == 'thegrey')
            end,
        },
        {
            name = 'Downtime',
            state = 1,
            steps = 1,
            midSong = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and not mq.TLO.Me.Invis()
            end,
        },
        {
            name = 'Emergency',
            state = 1,
            steps = 1,
            midSong = true,
            doFullRotation = true,
            targetId = function(self) return { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                return Targeting.GetXTHaterCount() > 0 and (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or self.Helpers.UnwantedAggroCheck(self))
            end,
        },
        {
            name = 'Debuff',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting("DoSTSlow") or Config:GetSetting("DoAESlow") or Config:GetSetting("DoDispel") end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.OkayToDebuff() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Melody',
            state = 1,
            steps = 1,
            timer = 0,
            doFullRotation = true,
            blockMem = true,
            reorderable = true,
            targetId = function(self) return Combat.GetCachedCombatState() == "Combat" and Targeting.CheckForAutoTargetID() or { mq.TLO.Me.ID(), } end,
            cond = function(self, combat_state)
                if Globals.InMedState then return false end
                if combat_state == "Downtime" and mq.TLO.Me.Invis() then return false end
                return Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Burn',
            state = 1,
            steps = 4,
            midSong = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'Combat',
            state = 1,
            steps = 1,
            midSong = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        {
            name = 'InstantRunBuff',
            state = 1,
            steps = 1,
            midSong = true,
            targetId = function(self) return Combat.GetCachedCombatState() == "Combat" and Targeting.CheckForAutoTargetID() or Casting.GetBuffableGroupIDs() end,
            load_cond = function(self) return Casting.CanUseAA("Selo's Sonata") end,
            cond = function(self, combat_state)
                local downtime = combat_state == "Downtime" and not mq.TLO.Me.Invis()
                local combat = combat_state == "Combat" and Core.CombatActionsCheck()
                return downtime or combat
            end,
        },
    },
    ['Rotations']     = {
        ['Burn'] = {
            {
                name = "Quick Time",
                type = "AA",
                midSong = true,
            },
            {
                name = "Funeral Dirge",
                type = "AA",
                midSong = true,
            },
            {
                name = "Spire of the Minstrels",
                type = "AA",
                midSong = true,
            },
            {
                name = "Bladed Song",
                type = "AA",
                midSong = true,
            },
            {
                name = "ThousandBlades",
                type = "Disc",
                midSong = true,
            },
            {
                name = "Song of Stone",
                type = "AA",
                midSong = true,
            },
            {
                name = "Flurry of Notes",
                type = "AA",
                midSong = true,
            },
            {
                name = "Dance of Blades",
                type = "AA",
                midSong = true,
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
                name = "Cacophony",
                type = "AA",
                midSong = true,
            },
            {
                name = "Frenzied Kicks",
                type = "AA",
                midSong = true,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
        },
        ['Debuff'] = {
            {
                name = "AESlowSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('DoAESlow') end,
                cond = function(self, songSpell, target)
                    return Casting.DetSpellCheck(songSpell) and Targeting.GetXTHaterCount() > 2 and not mq.TLO.Target.Slowed() and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "SlowSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('DoSTSlow') end,
                cond = function(self, songSpell, target)
                    return Casting.DetSpellCheck(songSpell) and not mq.TLO.Target.Slowed() and not Casting.SlowImmuneTarget(target)
                end,
            },
            {
                name = "DispelSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('DoDispel') end,
                cond = function(self, songSpell)
                    return mq.TLO.Target.Beneficial() ~= nil
                end,
            },
        },
        ['Combat'] = {
            {
                name = "Epic",
                type = "Item",
                load_cond = function(self) return Config:GetSetting('UseEpic') > 1 end,
                cond = function(self, itemName)
                    return (Config:GetSetting('UseEpic') == 3 or (Config:GetSetting('UseEpic') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "Fierce Eye",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Config:GetSetting('UseFierceEye') > 1 end,
                cond = function(self, aaName)
                    return (Config:GetSetting('UseFierceEye') == 3 or (Config:GetSetting('UseFierceEye') == 2 and Casting.BurnCheck()))
                end,
            },
            {
                name = "ReflexStrike",
                type = "Disc",
                midSong = true,
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    local pct = Config:GetSetting('GroupManaPct')
                    return (mq.TLO.Group.LowMana(pct)() or -1) >= Config:GetSetting('GroupManaCt')
                end,
            },
            {
                name = "Boastful Bellow",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Config:GetSetting('UseBellow') > 1 end,
                cond = function(self, aaName, target)
                    return ((Config:GetSetting('UseBellow') == 3 and mq.TLO.Me.PctEndurance() > Config:GetSetting('SelfEndPct')) or (Config:GetSetting('UseBellow') == 2 and Casting.BurnCheck())) and
                        Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Vainglorious Shout",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Config:GetSetting('UseShout') > 1 end,
                cond = function(self, aaName, target)
                    if not Config:GetSetting('DoAEDamage') then return false end
                    return ((Config:GetSetting('UseShout') == 3 and mq.TLO.Me.PctEndurance() > Config:GetSetting('SelfEndPct')) or (Config:GetSetting('UseShout') == 2 and Casting.BurnCheck())) and
                        Combat.AETargetCheck(true) and Casting.DetAACheck(aaName)
                end,
            },
            {
                name = "Rallying Solo", --Rallying Call theoretically possible but problematic, needs own rotation akin to Focused Paragon, etc
                type = "AA",
                midSong = true,
                load_cond = function(self) return Casting.CanUseAA('Rallying Solo') end,
                cond = function(self, aaName)
                    return (mq.TLO.Me.PctEndurance() < 30 or mq.TLO.Me.PctMana() < 30)
                end,
            },
            {
                name = "Intimidation",
                type = "Ability",
                midSong = true,
                load_cond = function(self) return Casting.AARank("Intimidation") > 1 end,
            },
        },
        ['Enduring Breath'] = {
            {
                name = "EndBreathSong",
                type = "Song",
                cond = function(self, songSpell)
                    return self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
        },
        ['Melody'] = {
            {
                name = "AriaSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('AriaSong') and Config:GetSetting('UseAria') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseAria") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "OverhasteSong",
                type = "Song",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('AriaSong') and Config:GetSetting('LLAria') == 2 and Config:GetSetting('UseAria') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseAria") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "SpellDmgSong",
                type = "Song",
                load_cond = function(self) return not Core.GetResolvedActionMapItem('AriaSong') and Config:GetSetting('LLAria') == 3 and Config:GetSetting('UseAria') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseAria") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "WarMarchSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('WarMarchSong') and Config:GetSetting('UseMarch') > 1 end,
                cond = function(self, songSpell)
                    if not self.Helpers.CheckSongStateUse(self, "UseMarch") then return false end
                    return self.Helpers.MarchTimer(self) and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
                post_activate = function(self, songSpell, success)
                    if success then self.TempSettings.LastMarchCast = Globals.GetTimeSeconds() end
                end,
            },

            {
                name = "Jonthan",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('Jonthan') and Config:GetSetting('UseJonthan') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseJonthan") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "ArcaneSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('ArcaneSong') and Config:GetSetting('UseArcane') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseArcane") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "CrescendoSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('CrescendoSong') and Config:GetSetting('UseCrescendo') end,
                cond = function(self, songSpell)
                    if (mq.TLO.Me.GemTimer(songSpell.RankName())() or -1) > 0 then return false end
                    local pct = Config:GetSetting('GroupManaPct')
                    return (mq.TLO.Group.LowMana(pct)() or -1) >= Config:GetSetting('GroupManaCt')
                end,
            },
            {
                name = "GroupRegenSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('GroupRegenSong') and Config:GetSetting('RegenSong') == 2 end,
                cond = function(self, songSpell)
                    local pct = Config:GetSetting('GroupManaPct')
                    return self.Helpers.RefreshBuffSong(self, songSpell) and
                        ((Config:GetSetting('UseRegen') == 1 and (mq.TLO.Group.LowMana(pct)() or 999) >= Config:GetSetting('GroupManaCt'))
                            or (Config:GetSetting('UseRegen') > 1 and self.Helpers.CheckSongStateUse(self, "UseRegen")))
                end,
            },
            {
                name = "AreaRegenSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('AreaRegenSong') and Config:GetSetting('RegenSong') == 3 end,
                cond = function(self, songSpell)
                    local pct = Config:GetSetting('GroupManaPct')
                    return self.Helpers.RefreshBuffSong(self, songSpell) and
                        ((Config:GetSetting('UseRegen') == 1 and (mq.TLO.Group.LowMana(pct)() or 999) >= Config:GetSetting('GroupManaCt'))
                            or (Config:GetSetting('UseRegen') > 1 and self.Helpers.CheckSongStateUse(self, "UseRegen")))
                end,
            },
            {
                name = "AmpSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('AmpSong') and Config:GetSetting('UseAmp') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseAmp") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "SufferingSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('SufferingSong') and Config:GetSetting('UseSuffering') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseSuffering") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "SpitefulSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('SpitefulSong') and Config:GetSetting('UseSpiteful') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseSpiteful") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "SprySonataSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('SprySonataSong') and Config:GetSetting('UseSpry') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseSpry") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "ResistSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('ResistSong') and Config:GetSetting('UseResist') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseResist") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "RecklessSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('RecklessSong') and Config:GetSetting('UseReckless') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseReckless") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "AccelerandoSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('AccelerandoSong') and Config:GetSetting('UseAccelerando') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseAccelerando") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "FireBuffSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('FireBuffSong') and Config:GetSetting('UseFireBuff') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseFireBuff") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "ColdBuffSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('ColdBuffSong') and Config:GetSetting('UseColdBuff') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseColdBuff") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "DotBuffSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('DotBuffSong') and Config:GetSetting('UseDotBuff') > 1 end,
                cond = function(self, songSpell)
                    return self.Helpers.CheckSongStateUse(self, "UseDotBuff") and self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "DichoSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseDicho') > 1 end,
                cond = function(self, songSpell, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    local qt = Casting.GetAASpell("Quick Time")
                    return (Config:GetSetting('UseDicho') == 3 and (mq.TLO.Me.PctEndurance() > Config:GetSetting('SelfEndPct') or Casting.BurnCheck()))
                        or (Config:GetSetting('UseDicho') == 2 and qt and qt() and mq.TLO.Me.Song(qt.Name())())
                end,
            },
            {
                name = "InsultSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseInsult') > 1 and (not Config:GetSetting('UseLLInsult') or not Core.GetResolvedActionMapItem('LLInsultSong')) end,
                cond = function(self, songSpell, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    return (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck())
                end,
            },
            {
                name = "LLInsultSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseInsult') > 1 and Config:GetSetting('UseLLInsult') and Core.GetResolvedActionMapItem('LLInsultSong') end,
                cond = function(self, songSpell, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    return (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck())
                end,
            },
            {
                name = "FireDotSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseFireDots') end,
                cond = function(self, songSpell, target)
                    return target.ID() ~= mq.TLO.Me.ID() and self.Helpers.DotSongCheck(songSpell) and
                        self.Helpers.GetDetSongDuration(songSpell) <= Config:GetSetting('SongRefresh')
                end,
            },
            {
                name = "IceDotSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseIceDots') end,
                cond = function(self, songSpell, target)
                    return target.ID() ~= mq.TLO.Me.ID() and self.Helpers.DotSongCheck(songSpell) and
                        self.Helpers.GetDetSongDuration(songSpell) <= Config:GetSetting('SongRefresh')
                end,
            },
            {
                name = "PoisonDotSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UsePoisonDots') end,
                cond = function(self, songSpell, target)
                    return target.ID() ~= mq.TLO.Me.ID() and self.Helpers.DotSongCheck(songSpell) and
                        self.Helpers.GetDetSongDuration(songSpell) <= Config:GetSetting('SongRefresh')
                end,
            },
            {
                name = "DiseaseDotSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseDiseaseDots') end,
                cond = function(self, songSpell, target)
                    return target.ID() ~= mq.TLO.Me.ID() and self.Helpers.DotSongCheck(songSpell) and
                        self.Helpers.GetDetSongDuration(songSpell) <= Config:GetSetting('SongRefresh')
                end,
            },
            {
                name = "InsultSong2",
                type = "Song",
                load_cond = function(self)
                    return Config:GetSetting('UseInsult') == 3 and (not Config:GetSetting('UseLLInsult') or not Core.GetResolvedActionMapItem('LLInsultSong'))
                end,
                cond = function(self, songSpell, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    return (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck())
                end,
            },
            {
                name = "LLInsultSong2",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseInsult') == 3 and Config:GetSetting('UseLLInsult') and Core.GetResolvedActionMapItem('LLInsultSong') end,
                cond = function(self, songSpell, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    return (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck())
                end,
            },
            {
                name = "AllianceSong",
                type = "Song",
                load_cond = function(self) return Config:GetSetting('UseAlliance') end,
                cond = function(self, songSpell, target)
                    if target.ID() == mq.TLO.Me.ID() then return false end
                    return (mq.TLO.Me.PctMana() > Config:GetSetting('SelfManaPct') or Casting.BurnCheck()) and Casting.DetSpellCheck(songSpell)
                end,
            },
            {
                name = "RunBuffSong",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('RunBuffSong') and (Config:GetSetting('UseRunBuff') > 1 or Config:GetSetting('ChaseOn')) and not Casting.CanUseAA("Selo's Sonata") end,
                cond = function(self, songSpell)
                    local shouldCheckState = not Config:GetSetting('ChaseOn')
                    if shouldCheckState and not self.Helpers.CheckSongStateUse(self, "UseRunBuff") then
                        return false
                    end
                    return self.Helpers.RefreshBuffSong(self, songSpell)
                end,
            },
            {
                name = "Refresh Expiring Song",
                type = "customfunc",
                custom_func = function(self) return self.Helpers.RefreshExpiringSong(self) end,
            },
        },
        ['Downtime'] = {
            {
                name = "BardDPSAura",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('BardDPSAura') and Config:GetSetting('UseAura') == 1 end,
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    return not Casting.AuraActiveByName(songSpell.BaseName())
                end,
            },
            {
                name = "BardRegenAura",
                type = "Song",
                load_cond = function(self) return Core.GetResolvedActionMapItem('BardRegenAura') and Config:GetSetting('UseAura') == 2 end,
                pre_activate = function(self, songSpell) --remove the old aura if we leveled up (or the other aura if we just changed options), otherwise we will be spammed because of no focus.
                    ---@diagnostic disable-next-line: undefined-field
                    if not Casting.AuraActiveByName(songSpell.BaseName()) then mq.TLO.Me.Aura(1).Remove() end
                end,
                cond = function(self, songSpell)
                    return not Casting.AuraActiveByName(songSpell.BaseName())
                end,
            },
        },
        ['Emergency'] = {
            {
                name = "Armor of Experience",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() < 35
                end,
            },
            {
                name = "Fading Memories",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Config:GetSetting('UseFading') and Casting.CanUseAA('Fading Memories') end,
                cond = function(self, aaName)
                    if Config:GetSetting('CharmOn') and mq.TLO.Me.Pet.ID() > 0 then return false end
                    return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') or Globals.AutoTargetIsNamed) and self.Helpers.UnwantedAggroCheck(self)
                end,
            },
            {
                name = "Hymn of the Last Stand",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Casting.CanUseAA('Hymn of the Last Stand') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Shield of Notes",
                type = "AA",
                midSong = true,
                load_cond = function(self) return Casting.CanUseAA('Shield of Notes') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "Coating",
                type = "Item",
                load_cond = function(self) return Config:GetSetting('DoCoating') end,
                cond = function(self, itemName, target)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') and Casting.SelfBuffItemCheck(itemName)
                end,
            },
        },
        ['InstantRunBuff'] = {
            {
                name = "Selo's Sonata",
                type = "AA",
                midSong = true,
                cond = function(self, aaName, target)
                    -- Selo AA triggers Accelerando or Accelerato depending on rank.
                    local aaBuff = mq.TLO.Me.AltAbility(aaName).Spell.Trigger(1)() or ""
                    local combatState = Combat.GetCachedCombatState()
                    -- if in combat, check self, out of combat, also check others
                    return (combatState == "Combat" and (mq.TLO.Me.Buff(aaBuff).Duration.TotalSeconds() or 0) < 15) or
                        (combatState == "Downtime" and Casting.GroupBuffAACheck(aaName, target))
                end,
            },
        },
    },
    ['PullAbilities'] = {
        {
            id = 'Sonic Disturbance',
            Type = "AA",
            DisplayName = 'Sonic Disturbance',
            AbilityName = 'Sonic Disturbance',
            AbilityRange = 250,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Sonic Disturbance')() ~= nil
            end,
        },
        {
            id = 'Boastful Bellow',
            Type = "AA",
            DisplayName = 'Boastful Bellow',
            AbilityName = 'Boastful Bellow',
            AbilityRange = 250,
            cond = function(self)
                return mq.TLO.Me.AltAbility('Boastful Bellow')() ~= nil
            end,
        },
    },
    ['DefaultConfig'] = {
        ['Mode']            = {
            DisplayName = "Mode",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 1,
            FAQ = "What do the different Modes do?",
            Answer = "Bard currently only has one mode.",
        },

        --Abilities
        ['SelfManaPct']     = {
            DisplayName = "Self Min Mana %",
            Group = "Abilities",
            Header = "Common",
            Category = "Common Rules",
            Index = 101,
            Tooltip = "Minimum Mana% to use Insult and Alliance outside of burns.",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I constantly low on mana?",
            Answer = "Insults take a lot of mana, but we can control that amount with the Self Min Mana %.\n" ..
                "Try adjusting this to the minimum amount of mana you want to keep in reserve. Note that burns will ignore this setting.",
        },
        ['SelfEndPct']      = {
            DisplayName = "Self Min End %",
            Group = "Abilities",
            Header = "Common",
            Category = "Common Rules",
            Index = 102,
            Tooltip = "Minimum End% to use Bellow or Dicho outside of burns.",
            Default = 20,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
            FAQ = "Why am I constantly low on endurance?",
            Answer = "Bellow will quickly eat your endurance, and Dicho can help it along. By default your BRD will keep a reserve.\n" ..
                "You can adjust Self Mind End % to set the amount of endurance you want to keep in reserve. Note that burns will ignore this setting.",
        },

        --Debuffs
        ['DoSTSlow']        = {
            DisplayName = "Use Slow (ST)",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 101,
            Tooltip = Tooltips.SlowSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoAESlow']        = {
            DisplayName = "Use Slow (AE)",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Slow",
            Index = 102,
            Tooltip = Tooltips.AESlowSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['DoDispel']        = {
            DisplayName = "Use Dispel",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Dispel",
            Index = 101,
            Tooltip = Tooltips.DispelSong,
            RequiresLoadoutChange = true,
            Default = false,
        },

        --Other Recovery
        ['RegenSong']       = {
            DisplayName = "Regen Song Choice:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 101,
            Tooltip = "Select the Regen Song to be used, if any.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'None', 'Group', 'Area', },
            Default = 2,
            Min = 1,
            Max = 3,
            FAQ = "Why can't I choose between HP and Mana for my regen songs?",
            Answer = "At low level, the regen songs are spaced broadly, and wallow back and forth before settling on providing both resources.\n" ..
                "Endurance is eventually added as well.",
        },
        ['UseRegen']        = {
            DisplayName = "Regen Song Use:",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 102,
            Tooltip = "When to use the Regen Song selected above.",
            Type = "Combo",
            ComboOptions = { 'Under Group Mana % (Advanced Options Setting)', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
        },
        ['UseCrescendo']    = {
            DisplayName = "Crescendo Delayed Heal",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 103,
            Tooltip = Tooltips.CrescendoSong,
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['GroupManaPct']    = {
            DisplayName = "Group Mana %",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 104,
            Tooltip =
            "Enable the use of Crescendoes, Reflexive Strikes, and Regen songs (if configured) when we have a count (see below) of group members at or below this mana percentage.",
            Default = 80,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['GroupManaCt']     = {
            DisplayName = "Group Mana Count",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Other Recovery",
            Index = 105,
            Tooltip = "The number of party members (including yourself) that need to be under the above mana percentage.",
            Default = 2,
            Min = 1,
            Max = 6,
            ConfigType = "Advanced",
        },
        -- Curing
        ['UseCure']         = {
            DisplayName = "Cure Ailments",
            Group = "Abilities",
            Header = "Recovery",
            Category = "Curing",
            Index = 101,
            Tooltip = Tooltips.CureSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        -- Direct
        ['UseBellow']       = {
            DisplayName = "Use Bellow:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 101,
            Tooltip = "When to use Boastful Bellow.",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
            FAQ = "Why is my Boastful Bellow being recast early? My BRD is using it again before the conclusion nuke!",
            Answer = "Unfortunately, MQ currently reports the buff falling off early; we are examining possible fixes at this time.",
        },
        ['UseInsult']       = {
            DisplayName = "Insults to Use:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 102,
            Tooltip = Tooltips.InsultSong,
            Type = "Combo",
            ComboOptions = { 'None', 'Current Tier', 'Current + Old Tier', },
            Default = 3,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
        },
        ['UseLLInsult']     = {
            DisplayName = "Use Low-Level Insults",
            Group = "Abilities",
            Header = "Damage",
            Category = "Direct",
            Index = 103,
            Tooltip = "Use the lowest level insults possible to trigger Troubador's Synergy. Reduces insult damage, but increases mana savings.",
            RequiresLoadoutChange = true,
            Default = false,
        },
        -- Over Time
        ['UseFireDots']     = {
            DisplayName = "Use Fire Dots",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = Tooltips.FireDotSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['UseIceDots']      = {
            DisplayName = "Use Ice Dots",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 102,
            Tooltip = Tooltips.IceDotSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['UsePoisonDots']   = {
            DisplayName = "Use Poison Dots",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 103,
            Tooltip = Tooltips.PoisonDotSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        ['UseDiseaseDots']  = {
            DisplayName = "Use Disease Dots",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 104,
            Tooltip = Tooltips.DiseaseDotSong,
            RequiresLoadoutChange = true,
            Default = false,
        },
        -- Under the Hood
        ['SongRefresh']     = {
            DisplayName = "Song Refresh Timer",
            Group = "Abilities",
            Header = "Common",
            Category = "Under the Hood",
            Index = 101,
            Tooltip = "Resing a song or effect once its remaining duration is at or below this many seconds.",
            Default = 4,
            Min = 1,
            Max = 13,
            ConfigType = "Advanced",
            FAQ = "Why does my bard refresh songs before the Song Refresh Timer?",
            Answer = "Rather than stand idle, the bard keeps singing, topping off whichever song in the Melody rotation is closest to expiring, " ..
                "so songs refresh before reaching the Song Refresh Timer and uptime stays high.",
        },
        -- Self
        ['UseAmp']          = {
            DisplayName = "Use Amp",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = Tooltips.AmpSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseJonthan']      = {
            DisplayName = "Use Jonthan",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 102,
            Tooltip = Tooltips.Jonthan,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['UseAlliance']     = {
            DisplayName = "Use Alliance",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 103,
            Tooltip = Tooltips.AllianceSong,
            RequiresLoadoutChange = true,
            Default = false,
            ConfigType = "Advanced",
        },
        ['DoVetAA']         = {
            DisplayName = "Use Vet AA",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 104,
            Tooltip = "Use Veteran AA such as Intensity of the Resolute or Armor of Experience as necessary.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        --Group
        ['UseRunBuff']      = {
            DisplayName = "Use RunSpeed Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 101,
            Tooltip = "Song Line: Movement Speed Modifier (Does not control the Selo's AA).",
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseEndBreath']    = {
            DisplayName = "Use Enduring Breath",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 102,
            Tooltip = Tooltips.EndBreathSong,
            Default = false,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        ['UseAura']         = {
            DisplayName = "Use Bard Aura",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 103,
            Tooltip = "Select the Aura to be used, if any.",
            Type = "Combo",
            ComboOptions = { 'DPS Aura', 'Regen', 'None', },
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 3,
            FAQ = "Do bard auras and song stack when effects are similar?",
            Answer = "While certain parts of each will not stack, auras add some buffs not present in the song.\n" ..
                "This makes the auras and songs worth using together, and the answer is nearly always to use the DPS Aura.",
        },
        ['UseFierceEye']    = {
            DisplayName = "Fierce Eye Use:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 104,
            Tooltip = "When to use the Fierce Eye AA.",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },
        ['UseAria']         = {
            DisplayName = "Use Aria",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 105,
            Tooltip = Tooltips.AriaSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['LLAria']          = {
            DisplayName = "Pre-Aria Choice:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 106,
            Tooltip = "Choose your preference of overhaste or spell damage before these songs are combined into the Aria line. After, we will simply use your Aria settings.",
            Type = "Combo",
            ComboOptions = { 'None', 'Overhaste', 'Spell Damage', },
            Default = 2,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
        },
        ['UseMarch']        = {
            DisplayName = "Use War March",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 107,
            Tooltip = Tooltips.WarMarchSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseArcane']       = {
            DisplayName = "Use Arcane Line",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 108,
            Tooltip = Tooltips.ArcaneSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 3,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseSuffering']    = {
            DisplayName = "Use Suffering Line",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 109,
            Tooltip = Tooltips.SufferingSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 4,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseDicho']        = {
            DisplayName = "Psalm (Dicho) Use:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 110,
            Tooltip = Tooltips.DichoSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'During QuickTime', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why is there no option to use Dicho in burns only?",
            Answer =
                "Since QuickTime is set to be used on burns and may last after the burns, aligning Dicho with it allows a smoother song rotation and allows some use even after a Burn was triggered.\n" ..
                "Dicho settings can be adjusted in the DPS - Group tab.",
        },
        ['UseSpiteful']     = {
            DisplayName = "Use Spiteful",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 111,
            Tooltip = Tooltips.SpitefulSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseSpry']         = {
            DisplayName = "Use Spry",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 112,
            Tooltip = Tooltips.SprySonataSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseResist']       = {
            DisplayName = "Use DS/Resist Psalm",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 113,
            Tooltip = Tooltips.ResistSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseReckless']     = {
            DisplayName = "Use Reckless",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 114,
            Tooltip = Tooltips.RecklessSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 4,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
        },
        ['UseAccelerando']  = {
            DisplayName = "Use Accelerando",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 115,
            Tooltip = Tooltips.AccelerandoSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['UseFireBuff']     = {
            DisplayName = "Use Fire Spell Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 116,
            Tooltip = Tooltips.FireBuffSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['UseColdBuff']     = {
            DisplayName = "Use Cold Spell Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 117,
            Tooltip = Tooltips.ColdBuffSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },
        ['UseDotBuff']      = {
            DisplayName = "Use Fire/Magic DoT Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Group",
            Index = 118,
            Tooltip = Tooltips.DotBuffSong,
            Type = "Combo",
            ComboOptions = { 'Never', 'In-Combat Only', 'Always', 'Out-of-Combat Only', },
            Default = 1,
            Min = 1,
            Max = 4,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
        },

        -- Clickies
        ['UseEpic']         = {
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
            RequiresLoadoutChange = true,
        },
        ['DoChestClick']    = {
            DisplayName = "Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click your equipped chest item.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
            ConfigType = "Advanced",
            FAQ = "What is a Chest Click?",
            Answer = "Most Chest slot items after level 75ish have a clickable effect.\n" ..
                "BRD is set to use theirs during burns, so long as the item equipped has a clicky effect.",
        },
        ['DoCoating']       = {
            DisplayName = "Use Coating",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 103,
            Tooltip = "Click your Blood/Spirit Drinker's Coating in an emergency.",
            Default = false,
            RequiresLoadoutChange = true,
            FAQ = "What is a Coating?",
            Answer = "Blood Drinker's Coating is a clickable lifesteal effect added in CotF. Spirit Drinker's Coating is an upgrade added in NoS.",
        },

        --Emergency
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
        ['UseFading']       = {
            DisplayName = "Use Combat Escape",
            Group = "Abilities",
            Header = "Utility",
            Category = "Emergency",
            Index = 102,
            Tooltip = "Use Fading Memories when you have aggro and you aren't the Main Assist.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
        },

        --Instruments--
        ['SwapInstruments'] = {
            DisplayName = "Auto Swap Instruments",
            Index = 101,
            Group = "Items",
            Header = "Instruments",
            Category = "Instruments",
            Tooltip = "Auto swap instruments for songs",
            Default = false,
        },
        ['Offhand']         = {
            DisplayName = "Offhand",
            Index = 102,
            Group = "Items",
            Header = "Instruments",
            Category = "Instruments",
            Tooltip = "Item to swap in when no instrument is available or needed.",
            Type = "ClickyItem",
            Default = "",
        },
        ['BrassInst']       = {
            DisplayName = "Brass Instrument",
            Index = 103,
            Group = "Items",
            Header = "Instruments",
            Category = "Instruments",
            Tooltip = "Brass Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
        },
        ['WindInst']        = {
            DisplayName = "Wind Instrument",
            Index = 104,
            Group = "Items",
            Header = "Instruments",
            Category = "Instruments",
            Tooltip = "Wind Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
        },
        ['PercInst']        = {
            DisplayName = "Percussion Instrument",
            Index = 105,
            Group = "Items",
            Header = "Instruments",
            Category = "Instruments",
            Tooltip = "Percussion Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
        },
        ['StringedInst']    = {
            DisplayName = "Stringed Instrument",
            Index = 106,
            Group = "Items",
            Header = "Instruments",
            Category = "Instruments",
            Tooltip = "Stringed Instrument to Swap in as needed.",
            Type = "ClickyItem",
            Default = "",
        },

        --AE Damage
        ['UseShout']        = {
            DisplayName = "Shout Use:",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            RequiresLoadoutChange = true,
            Tooltip = "When to use Vainglorious Shout.",
            Type = "Combo",
            ComboOptions = { 'Never', 'Burns Only', 'All Combat', },
            Default = 3,
            Min = 1,
            Max = 3,
            FAQ = "Why is my Vainglorious Shout being recast early? My BRD is using it again before the conclusion nuke!",
            Answer = "Unfortunately, MQ currently reports the buff falling off early; we are examining possible fixes at this time.",
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
        {
            Question = "How does Bard meditation function?",
            Answer = "Bards can elect to med using the same settings as other classes. If a bard begins to med, they will stop singing any songs in the Melody rotation.\n\n" ..
                "  Using the default class configs, the combat rotations will still be used. Thus, there is generally little or no support for in-combat meditation for Bard.\n\n" ..
                "  The 'Stand When Done' med setting will ensure that a bard begins to sing again as soon as they reach the med stop threshold.\n\n" ..
                "  Note that the Enduring Breath song, if enabled (and needed), does not respect meditation settings, for the safety of your group.",
            Settings_Used = "",
        },
    },
}
return _ClassConfig
