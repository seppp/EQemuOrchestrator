local mq           = require('mq')
local Set          = require('mq.set')
local Casting      = require("utils.casting")
local Combat       = require("utils.combat")
local Config       = require('utils.config')
local Core         = require("utils.core")
local Globals      = require("utils.globals")
local ItemManager  = require("utils.item_manager")
local Logger       = require("utils.logger")
local Targeting    = require("utils.targeting")
local Ui           = require("utils.ui")

--todo: add a LOT of tooltips or scrap them entirely. Hopefully the former.
local Tooltips     = {
    Mantle              = "Spell Line: Melee Absorb Proc",
    Carapace            = "Spell Line: Melee Absorb Proc",
    CombatEndRegen      = "Discipline Line: Endurance Regen (In-Combat Useable)",
    EndRegen            = "Discipline Line: Endurance Regen (Out of Combat)",
    Blade               = "Ability Line: Double 2HS Attack w/ Accuracy Mod",
    Crimson             = "Disicpline Line: Triple Attack w/ Accuracy Mod",
    MeleeMit            = "Discipline Line: Absorb Incoming Dmg",
    Deflection          = "Discipline: Shield Block Chance 100%",
    LeechCurse          = "Discipline: Melee LifeTap w/ Increase Hit Chance",
    UnholyAura          = "Discipline: Increase LifeTap Spell Damage",
    Guardian            = "Discipline: Melee Mitigation w/ Defensive LifeTap & Lowered Melee DMG Output",
    PetSpell            = "Spell Line: Summons SK Pet",
    PetHaste            = "Spell Line: Haste Buff for SK Pet",
    Shroud              = "Spell Line: Add Melee LifeTap Proc",
    Horror              = "Spell Line: Proc HP Return",
    Mental              = "Spell Line: Proc Mana Return",
    Skin                = "Spell Line: Melee Absorb Proc",
    SelfDS              = "Spell Line: Self Damage Shield",
    Demeanor            = "Spell Line: Add LifeTap Proc Buff on Killshot",
    HealBurn            = "Spell Line: Add Hate Proc on Incoming Spell Damage",
    CloakHP             = "Spell Line: Increase HP and Stacking DS",
    Covenant            = "Spell Line: Increase Mana Regen + Ultravision / Decrease HP Per Tick",
    CallAtk             = "Spell Line: Increase Attack / Decrease HP Per Tick",
    AETaunt             = "Spell Line: PBAE Hate Increase + Taunt",
    PoisonDot           = "Spell Line: Poison Dot",
    SpearNuke           = "Spell Line: Instacast Disease Nuke",
    BondTap             = "Spell Line: LifeTap DOT",
    DireTap             = "Spell Line: LifeTap",
    LifeTap             = "Spell Line: LifeTap",
    MaxHPTap            = "Spell Line: Dmg + Max HP Buff + Hate Increase",
    BiteTap             = "Spell Line: LifeTap + ManaTap",
    ForPower            = "Spell Line: Hate Increase + Hate Increase DOT + AC Buff 'BY THE POWER OF GRAYSKULL, I HAVE THE POWER -- HE-MAN'",
    Terror              = "Spell Line: Hate Increase + Taunt",
    TempHP              = "Spell Line: Temporary Hitpoints (Decrease per Tick)",
    Dicho               = "Spell Line: Hate Increase + LifeTap",
    PowerTapAC          = "Spell Line: AC Tap",
    PowerTapAtk         = "Spell Line: Attack Tap",
    SnareDot            = "Spell Line: Snare + HP DOT",
    Acrimony            = "Spell Increase: Aggrolock + LifeTap DOT + Hate Generation",
    SpiteStrike         = "Spell Line: LifeTap + Caster 1H Blunt Increase + Target Armor Decrease",
    ReflexStrike        = "Ability: Triple 2HS Attack + HP Increase",
    DireDot             = "Spell Line: DOT + AC Decrease + Strength Decrease",
    AllianceNuke        = "Spell Line: Alliance (Requires Multiple of Same Class) - Increase Spell Damage Taken by Target + Large LifeTap",
    InfluenceDisc       = "Ability Line: Increase AC + Absorb Damage + Melee Proc (LifeTap + Max HP Increase)",
    DLUA                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Horror, Drape, Demeanor, Skin, Covenant, CallATK)",
    DLUB                = "AA: Cast Highest Level of Scribed Buffs (Shroud, Mental, Drape, Demeanor, Skin, Covenant, CallATK)",
    HarmTouch           = "AA: Harms Target HP",
    ThoughtLeech        = "AA: Harms Target HP + Harms Target Mana",
    VisageOfDeath       = "Spell: Increases Melee Hit Dmg + Illusion",
    LeechTouch          = "AA: LifeTap Touch",
    Tvyls               = "Spell: Triple 2HS Attack + % Melee Damage Increase on Target",
    ActivateShield      = "Activate 'Shield' if set in Bandolier",
    Activate2HS         = "Activate '2HS' if set in Bandolier",
    ExplosionOfHatred   = "Spell: Targeted AE Hatred Increase",
    ExplosionOfSpite    = "Spell: Targeted PBAE Hatred Increase",
    Taunt               = "Ability: Increases Hatred to 100% + 1",
    EncroachingDarkness = "Ability: Snare + HP DOT",
    Epic                = 'Item: Casts Epic Weapon Ability',
    ViciousBiteOfChaos  = "Spell: Duration LifeTap + Mana Return",
    Bash                = "Use Bash Ability",
    Slam                = "Use Slam Ability",
    HateBuff            = "Spell/AA: Increase Hate Generation",
}

local _ClassConfig = {
    _version          = "DODL CUSTOM",
    _author           = "eldudero",
    ['ModeChecks']    = {
        IsTanking = function() return Core.IsModeActive("Tank") end,
        IsCuring = function() return Config:GetSetting('DoCures') end,
    },
    ['Cure']          = {
        ['DetDispel'] = {
            { type = "AA", name = "Purity of Death", selfOnly = true, },
        },
    },
    ['Modes']         = {
        'Tank',
        'DPS',
    },
    ['PetPosition']   = {
        SummonAA   = function() return Casting.CanUseAA("Summon Companion") and "Summon Companion" end,
        RelocateAA = function()
            local cdAA = mq.TLO.Me.AltAbility("Companion's Discipline")
            return (cdAA and cdAA.Rank() or 0) >= 4 and "Companion's Discipline"
        end,
    },
    ['Themes']        = {
        ['Tank'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.5, g = 0.05, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.3, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.2, g = 0.05, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.0, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.0, g = 0.05, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
        },
        ['DPS'] = {
            { element = ImGuiCol.TitleBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TableHeaderBg,    color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.Tab,              color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabSelected,      color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.TabHovered,       color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.Header,           color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.HeaderHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.FrameBgHovered,   color = { r = 0.5, g = 0.05, b = 0.05, a = 0.7, }, },
            { element = ImGuiCol.Button,           color = { r = 0.3, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonActive,     color = { r = 0.5, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.ButtonHovered,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
            { element = ImGuiCol.TextSelectedBg,   color = { r = 0.2, g = 0.05, b = 0.05, a = .1, }, },
            { element = ImGuiCol.FrameBg,          color = { r = 0.2, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrab,       color = { r = 1.0, g = 0.05, b = 0.05, a = .8, }, },
            { element = ImGuiCol.SliderGrabActive, color = { r = 1.0, g = 0.05, b = 0.05, a = .9, }, },
            { element = ImGuiCol.FrameBgActive,    color = { r = 0.5, g = 0.05, b = 0.05, a = 1.0, }, },
        },
    },
    ['ItemSets']      = {
        ['Epic'] = {
        },
        ['OoW_Chest'] = {
        },
        ['Coating'] = {
        },
    },
    ['AbilitySets']   = {
        ['Mantle'] = {
            "Bonebrood Mantle Rk. III",
            "Bonebrood Mantle Rk. II",
            "Bonebrood Mantle",
            "Recondite Mantle",
            "Gorgon Mantle",
            "Malarian Mantle",
            "Umbral Carapace",
            "Soul Carapace",
            "Soul Shield",
            "Soul Guard",
            "Ichor Guard",
        },
        ['Carapace'] = {
            "Sholothian Carapace Rk. III",
            "Sholothian Carapace Rk. II",
            "Sholothian Carapace",
            "Gorgon Carapace",
        },
        ['EndRegen'] = {
            "Rest Rk. III",
            "Rest Rk. II",
            "Rest",
            "Reprieve",
            "Respite",
        },
        ['CombatEndRegen'] = {
        },
        ['Blade'] = {
            "Gashing Blade Rk. III",
            "Gashing Blade Rk. II",
            "Gashing Blade",
            "Gouging Blade",
        },
        ['Crimson'] = {
            "Scarlet Blade Rk. III",
            "Scarlet Blade Rk. II",
            "Scarlet Blade",
            "Crimson Blade",
        },
        ['MeleeMit'] = {
            "Reprove Rk. III",
            "Reprove Rk. II",
            "Reprove",
            "Renounce",
            "Defy",
        },
        ['Deflection'] = { 'Deflection Discipline', },
        ['Guardian'] = {
            "Guardian Spirit",
            "Guardian Rhythms",
            "Guardian",
            "Unholy Guardian Discipline",
        },
        ['PetSpell'] = {
            "Minion of Grelleth Rk. III",
            "Minion of Grelleth Rk. II",
            "Minion of Grelleth",
            "Minion of Sholoth",
            "Minion of Fear",
            "Minion of Sebilis",
            "Maladroit Minion",
            "Son of Decay",
            "Invoke Death",
            "Cackling Bones",
            "Malignant Dead",
            "Summon Dead",
            "Animate Dead",
            "Restless Bones",
            "Convoke Shadow",
            "Bone Walk",
            "Leering Corpse",
        },
        ['PetHaste'] = {
            "Gift of Urash Rk. III",
            "Gift of Urash Rk. II",
            "Gift of Urash",
            "Gift of Dyalgem",
            "Expatiate Death",
            "Amplify Death",
            "Rune of Decay",
            "Augmentation of Death",
            "Augment Death",
            "Strengthen Death",
        },
        ['Shroud'] = {                   --Some Shrouds listed under the Horror Line as ProcChoice=HP buff slot 1 at lower levels.
            "Shroud of the Darksworn Rk. III",
            "Shroud of the Darksworn Rk. II",
            "Shroud of the Darksworn",
            "Shroud of the Shadeborne",
            "Shroud of the Plagueborne",
            "Shroud of the Blightborn",
            "Shroud of the Gloomborn",
            "Shroud of the Nightborn",
        },
        ['Horror'] = {                   -- HP Tap Proc
            "Sholothian Horror Rk. III",
            "Sholothian Horror Rk. II",
            "Sholothian Horror",
            "Amygdalan Horror",
            "Mindshear Horror",
            "Soulthirst Horror",
            "Marrowthirst Horror",
            "Shroud of Discord",
            "Black Shroud",
            "Shroud of Chaos",
            "Shroud of Death",
        },
        ['Mental'] = {                   -- Mana Tap Proc
            "Mental Terror Rk. III",
            "Mental Terror Rk. II",
            "Mental Terror",
        },
        ['Skin'] = {
            "Sholothian Skin Rk. III",
            "Sholothian Skin Rk. II",
            "Sholothian Skin",
            "Gorgon Skin",
            "Malarian Skin",
            "Umbral Skin",
            "Decrepit Skin",
        },
        ['SelfDS'] = {
            "Zombie Skin Rk. III",
            "Zombie Skin Rk. II",
            "Zombie Skin",
            "Ghoul Skin",
            "Banshee Skin",
            "Banshee Aura",
        },
        ['Demeanor'] = {
            "Remorseless Demeanor Rk. III",
            "Remorseless Demeanor Rk. II",
            "Remorseless Demeanor",
        },
        ['HealBurn'] = {
        },
        ['CloakHP'] = {
            "Drape of the Fallen Rk. III",
            "Drape of the Fallen Rk. II",
            "Drape of the Fallen",
            "Drape of the Sepulcher",
            "Drape of Fear",
            "Drape of Korafax",
            "Drape of Corruption",
            "Cloak of Corruption",
            "Cloak of Discord",
            "Cloak of Luclin",
            "Cloak of the Akheva",
        },
        ['Covenant'] = {
            "Grim Covenant Rk. III",
            "Grim Covenant Rk. II",
            "Grim Covenant",
        },
        ['CallAtk'] = {
            "Call of Gloomhaze Rk. III",
            "Call of Gloomhaze Rk. II",
            "Call of Gloomhaze",
            "Call of Shadow",
            "Call of Dusk",
            "Call of Darkness",
        },
        ['AETaunt'] = {
            "Abhorrence Rk. III",
            "Abhorrence Rk. II",
            "Abhorrence",
            "Loathing",
            "Burst of Spite",
            "Revile",
            "Vilify",
            "Dread Gaze",
        },
        ['PoisonDot'] = {
            "Blood of Ralstok Rk. III",
            "Blood of Ralstok Rk. II",
            "Blood of Ralstok",
            "Blood of Korum",
            "Blood of Malthiasiss",
            "Blood of Laarthik",
            "Blood of the Blackwater",
            "Blood of the Blacktalon",
            "Blood of Inruku",
            "Blood of Discord",
            "Blood of Hate",
            "Blood of Pain",
        },
        ['CorruptionDot'] = {
            "Surreptitious Blight Rk. III",
            "Surreptitious Blight Rk. II",
            "Surreptitious Blight",
            "Perfidious Blight",
            "Insidious Blight",
        },
        ['SpearNuke'] = {
            "Spear of Grelleth Rk. III",
            "Spear of Grelleth Rk. II",
            "Spear of Grelleth",
            "Spear of Sholoth",
            "Gorgon Spear",
            "Malarian Spear",
            "Rotmarrow Spear",
            "Rotroot Spear",
            "Spear of Muram",
            "Miasmic Spear",
            "Spear of Decay",
            "Spear of Plague",
            "Spear of Pain",
            "Spear of Disease",
            "Spike of Disease",
        },
        ['BondTap'] = {
            "Bond of Ralstok Rk. III",
            "Bond of Ralstok Rk. II",
            "Bond of Ralstok",
            "Bond of Korum",
            "Bond of Malthiasiss",
            "Bond of Laarthik",
            "Bond of the Blackwater",
            "Bond of the Blacktalon",
            "Bond of Inruku",
            "Bond of Death",
            "Vampiric Curse",
        },
        ['DireTap'] = {
            "Dire Insinuation Rk. III",
            "Dire Insinuation Rk. II",
            "Dire Insinuation",
            "Dire Allegation",
            "Dire Accusation",
            "Dire Implication",
        },
        ['LifeTap'] = {
            "Touch of Falsin Rk. III",
            "Touch of Falsin Rk. II",
            "Touch of Falsin",
            "Touch of Falsin",
            "Touch of Urash",
            "Touch of Dyalgem",
            "Touch of Tharoff",
            "Touch of Kildrukaun",
            "Touch of Severan",
            "Touch of the Devourer",
            "Touch of Inruku",
            "Touch of Innoruuk",
            "Touch of Volatis",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike",
            "Lifetap",
        },
        ['LifeTap2'] = {
            "Touch of Falsin Rk. III",
            "Touch of Falsin Rk. II",
            "Touch of Falsin",
            "Touch of Falsin",
            "Touch of Urash",
            "Touch of Dyalgem",
            "Touch of Tharoff",
            "Touch of Kildrukaun",
            "Touch of Severan",
            "Touch of the Devourer",
            "Touch of Inruku",
            "Touch of Innoruuk",
            "Touch of Volatis",
            "Drain Soul",
            "Drain Spirit",
            "Spirit Tap",
            "Siphon Life",
            "Life Leech",
            "Lifedraw",
            "Lifespike",
            "Lifetap",
        },
        ['AELifeTap'] = {               --Lifetap/Hate up to 30 targets, level 98+
            "Insidious Deflection Rk. III",
            "Insidious Deflection Rk. II",
            "Insidious Deflection",
        },
        ['MaxHPTap'] = {
            "Touch of Klonda Rk. III",
            "Touch of Klonda Rk. II",
            "Touch of Klonda",
            "Touch of Piqiorn",
            "Touch of Iglum",
            "Touch of Lanys",
            "Touch of the Soulbleeder",
            "Touch of the Wailing Three",
            "Touch of Draygun",
        },
        ['BiteTap'] = {
            "Blackwater Bite Rk. III",
            "Blackwater Bite Rk. II",
            "Blackwater Bite",
            "Blacktalon Bite",
            "Ancient: Bite of Muram",
        },
        ['ForPower'] = {
            "Demand for Power Rk. III",
            "Demand for Power Rk. II",
            "Demand for Power",
            "Provocation for Power",
            "Confrontation for Power",
            "Charge for Power",
            "Trial for Power",
            "Challenge for Power",
        },
        ['Terror'] = {
            "Terror of Poira Rk. III",
            "Terror of Poira Rk. II",
            "Terror of Poira",
            "Terror of Desalin",
            "Terror of Rerekalen",
            "Terror of Jelvalak",
            "Terror of the Soulbleeder",
            "Terror of Vergalid",
            "Terror of Discord",
            "Terror of Thule",
            "Terror of Terris",
            "Terror of Death",
            "Terror of Shadows",
            "Terror of Darkness",
        },
        ['Terror2'] = {
            "Terror of Poira Rk. III",
            "Terror of Poira Rk. II",
            "Terror of Poira",
            "Terror of Desalin",
            "Terror of Rerekalen",
            "Terror of Jelvalak",
            "Terror of the Soulbleeder",
            "Terror of Vergalid",
            "Terror of Discord",
            "Terror of Thule",
            "Terror of Terris",
            "Terror of Death",
            "Terror of Shadows",
            "Terror of Darkness",
        },
        ['TempHP'] = {
            "Steadfast Stance Rk. III",
            "Steadfast Stance Rk. II",
            "Steadfast Stance",
            "Stoic Stance",
            "Stubborn Stance",
            "Steely Stance",
        },
        ['Dicho'] = {
        },
        ['PowerTapAC'] = {
            "Torrent of Poison",
            "Torrent of Hate",
            "Torrent of Fatigue",
            "Torrential Hail",
            "Torrential Hail Rk. II",
            "Torrential Hail Rk. III",
            "Torrent of Thunderbolts",
            "Torrent of Thunderbolts Rk. II",
            "Torrent of Thunderbolts Rk. III",
            "Torrent of Agony Rk. II",
            "Torrent of Agony Rk. III",
            "Torrent of Agony",
            "Theft of Agony",
            "Theft of Pain",
            "Aura of Pain",
            "Torrent of Pain",
            "Shroud of Pain",
            "Scream of Pain",
        },
        ['PowerTapAtk'] = {
            "Theft of Thought",
            "Theft of Pain",
            "Theft of Agony",
            "Theft of Hate",
            "Aura of Hate",
            "Torrent of Hate",
            "Shroud of Hate",
            "Scream of Hate",
        },
        ['SnareDot'] = {
            "Smoldering Darkness Rk. III",
            "Smoldering Darkness Rk. II",
            "Smoldering Darkness",
            "Suppurating Darkness",
            "Despairing Darkness",
            "Festering Darkness",
            "Cascading Darkness",
            "Dooming Darkness",
            "Engulfing Darkness",
            "Clinging Darkness",
        },
        ['Acrimony'] = {
            "Unbroken Acrimony Rk. III",
            "Unbroken Acrimony Rk. II",
            "Unbroken Acrimony",
            "Undivided Acrimony",
        },
        ['SpiteStrike'] = {
            "Spite of Ronak Rk. III",
            "Spite of Ronak Rk. II",
            "Spite of Ronak",
        },
        ['ReflexStrike'] = {
            "Reflexive Rancor Rk. III",
            "Reflexive Rancor Rk. II",
            "Reflexive Rancor",
        },
        ['DireDot'] = {
            "Dire Stricture Rk. III",
            "Dire Stricture Rk. II",
            "Dire Stricture",
            "Dire Stenosis",
            "Dire Restriction",
            "Dire Constriction",
            "Dark Constriction",
            "Asystole",
            "Heart Flutter",
            "Disease Cloud",
        },
        ['AllianceNuke'] = {
        },
        ['InfluenceDisc'] = {
            "Insolent Agitation III",
            "Insolent Agitation II",
            "Insolent Agitation",
            "Insolent Reward III",
            "Insolent Reward II",
            "Insolent Reward",
            "Insolent Influence Rk. III",
            "Insolent Influence Rk. II",
            "Insolent Influence",
        },
        ['HateBuff'] = {             --9 minute reuse makes these somewhat ridiculous to gem on the fly.
            "Voice Graft",
            "Voice of the Berserker",
            "Voice of Quellious",
            "Voice of the Vampire",
            "Voice of Clairvoyance",
            "Voice of Intuition",
            "Voice of Intuition Rk. II",
            "Voice of Intuition Rk. III",
            "Voice of Cognizance",
            "Voice of Cognizance Rk. II",
            "Voice of Cognizance Rk. III",
            "Voice of the Mindshear",
            "Voice of the Mindshear Rk.II",
            "Voice of the Mindshear Rk.III",
            "Voice of Prescience",
            "Voice of Prescience Rk. II",
            "Voice of Prescience Rk. III",
            "Voice of Sionachie",
            "Voice of Sionachie Rk. II",
            "Voice of Sionachie Rk. III",
            "Voice of Forethought",
            "Voice of Forethought Rk. II",
            "Voice of Forethought Rk. III",
            "Voice of Kolain",
            "Voice of Kolain Rk. II",
            "Voice of Kolain Rk. III",
            "Voice of Premeditation",
            "Voice of Premeditation Rk. II",
            "Voice of Premeditation Rk. III",
            "Voice of Motlak",
            "Voice of Motlak Rk. II",
            "Voice of Motlak Rk. III",
            "Voice of Foresight",
            "Voice of Foresight Rk. II",
            "Voice of Foresight Rk. III",
            "Voice of Thule",
            "Voice of Terris",
            "Voice of Death",
            "Voice of Shadows",
            "Voice of Darkness",
        },
    },
    ['Helpers']       = {
        --determine whether we should overwrite DLU buffs with better single buffs
        SingleBuffCheck = function(self)
            if Casting.CanUseAA("Dark Lord's Unity (Azia)") and not Config:GetSetting('OverwriteDLUBuffs') then return false end
            return true
        end,
        --function to determine if we have enough mobs in range to use a defensive disc
        DefensiveDiscCheck = function(printDebug)
            local xtCount = mq.TLO.Me.XTarget() or 0
            if xtCount < Config:GetSetting('DiscCount') then return false end
            local haters = Set.new({})
            for i = 1, xtCount do
                local xtarg = mq.TLO.Me.XTarget(i)
                if xtarg and xtarg.ID() > 0 and ((xtarg.Aggressive() or (xtarg.TargetType() or ""):lower() == "auto hater")) and (xtarg.Distance() or 999) <= 30 then
                    if printDebug then
                        Logger.log_verbose("DefensiveDiscCheck(): XT(%d) Counting %s(%d) as a hater in range.", i, xtarg.CleanName() or "None", xtarg.ID())
                    end
                    haters:add(xtarg.ID())
                end
                if #haters:toList() >= Config:GetSetting('DiscCount') then return true end -- no need to keep counting once this threshold has been reached
            end
            return false
        end,
        --function to space out Epic and Omens Chest with Mortal Coil old-school swarm style. Epic has an override condition to fire anyway on named.
        LeechCheck = function(self)
            local LeechEffects = { "Leechcurse Discipline", "Mortal Coil", "Lich Sting Recourse", "Leeching Embrace", "Reaper Strike Recourse", "Leeching Touch", }
            for _, buffName in ipairs(LeechEffects) do
                if mq.TLO.Me.Buff(buffName)() or mq.TLO.Me.Song(buffName)() then return false end
            end
            return true
        end,
        shieldNeeded = function()
            -- check for exactly 100% to help ensure the mob is targeting us, over 100% can indicate another is still targeted
            return (mq.TLO.Me.PctHPs() <= Config:GetSetting('EquipShield')) or mq.TLO.Me.ActiveDisc.Name() == "Deflection Discipline" or
                (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) >= 234000 or
                (Config:GetSetting('NamedShieldLock') and ((Globals.AutoTargetIsNamed and Targeting.GetAutoTargetAggroPct() == 100) or Targeting.TankingXTNamed()))
        end,
    },
    ['Charm']         = {
        ['Assist'] = {
            { name = "Taunt",            type = "Ability", },
            {
                name = "Terror",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTerror') == 3 or (Config:GetSetting('DoTerror') == 2 and not Core.GetResolvedActionMapItem('ForPower')) end,
            },
            {
                name = "Terror2",
                type = "Spell",
                load_cond = function(self) return Config:GetSetting('DoTerror') == 3 or (Config:GetSetting('DoTerror') == 2 and not Core.GetResolvedActionMapItem('ForPower')) end,
            },
            { name = "Acrimony",         type = "Disc", },
            { name = "Veil of Darkness", type = "AA", },
        },
    },
    ['RotationOrder'] = {
        { --Self Buffs
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
        { --Pet Buffs if we have one, timer because we don't need to constantly check this
            name = 'PetBuff',
            timer = 10,
            targetId = function(self) return mq.TLO.Me.Pet.ID() > 0 and { mq.TLO.Me.Pet.ID(), } or {} end,
            cond = function(self, combat_state)
                return combat_state == "Downtime" and mq.TLO.Me.Pet.ID() > 0 and Casting.OkayToPetBuff()
            end,
        },
        { --Actions to lock down xtarg haters
            name = 'HateTools(AggroTarget)',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() and Config:GetSetting('TankAggroScan') end,
            targetId = function(self) return Targeting.CheckForAggroTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat"
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'HateTools(AutoTarget)',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and (mq.TLO.Me.PctAggro() < 100 or (mq.TLO.Target.SecondaryPctAggro() or 0) > 60 or Globals.AutoTargetIsNamed)
            end,
        },
        { --Actions that establish or maintain hatred
            name = 'AEHateTools',
            state = 1,
            steps = 1,
            doFullRotation = true,
            load_cond = function()
                return Core.IsTanking() and
                    ((Config:GetSetting('AETauntSpell') > 1 and Core.GetResolvedActionMapItem('AETaunt')) or (Config:GetSetting('AETauntAA') and (Casting.CanUseAA("Explosion of Spite") or Casting.CanUseAA("Explosion of Hatred"))))
            end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and Combat.AETauntCheck(true)
            end,
        },
        { --Dynamic weapon swapping if UseBandolier is toggled
            name = 'Weapon Management',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('UseBandolier') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions triggered by low HP
            name = 'Emergency',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
            end,
        },
        { --Prioritized in their own rotation to help keep HP topped to the desired level, includes emergency abilities
            name = 'LifeTaps',
            state = 1,
            steps = 1,
            doFullRotation = true,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat"
            end,
        },
        { --Defensive actions used proactively to prevent emergencies
            name = 'DefensiveDiscs',
            state = 1,
            steps = 1,
            load_cond = function() return Core.IsTanking() end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                return combat_state == "Combat" and (mq.TLO.Me.PctHPs() <= Config:GetSetting('DefenseStart') or Targeting.TankingXTNamed() or
                    self.Helpers.DefensiveDiscCheck(true))
            end,
        },
        { -- Leech Effect (Epic, OoW BP, Coating) maintenance
            name = 'LeechEffects',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') then return false end
                return combat_state == "Combat" and self.Helpers.LeechCheck(self)
            end,
        },
        { --Keep things from running
            name = 'Snare',
            state = 1,
            steps = 1,
            load_cond = function() return Config:GetSetting('DoSnare') end,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and not Globals.AutoTargetIsNamed and Targeting.GetXTHaterCount() <= Config:GetSetting('SnareCount')
            end,
        },
        { --Offensive actions to temporarily boost damage dealt
            name = 'Burn',
            state = 1,
            steps = 4,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Casting.BurnCheck() and Core.CombatActionsCheck()
            end,
        },
        { --Non-spell actions that can be used during/between casts
            name = 'CombatWeave',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
        { --DPS Spells, includes recourse/gift maintenance
            name = 'Combat',
            state = 1,
            steps = 1,
            targetId = function(self) return Targeting.CheckForAutoTargetID() end,
            cond = function(self, combat_state)
                if mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                return combat_state == "Combat" and Core.CombatActionsCheck()
            end,
        },
    },
    ['Rotations']     = {
        ['Downtime'] = {
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
                name = "Dark Lord's Unity (Azia)",
                type = "AA",
                tooltip = Tooltips.DLUA,
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(2).ID() or 0) end,
                cond = function(self, aaName, target)
                    if Config:GetSetting('ProcChoice') ~= 1 then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Dark Lord's Unity (Beza)",
                type = "AA",
                tooltip = Tooltips.DLUB,
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.Trigger(2).ID() or 0) end,
                cond = function(self, aaName, target)
                    if Config:GetSetting('ProcChoice') ~= 2 then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "Shroud",
                type = "Spell",
                tooltip = Tooltips.Shroud,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Horror",
                type = "Spell",
                tooltip = Tooltips.Horror,
                load_cond = function(self) return Config:GetSetting('ProcChoice') == 1 end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Mental",
                type = "Spell",
                tooltip = Tooltips.Mental,
                load_cond = function(self) return Config:GetSetting('ProcChoice') == 2 end,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "Demeanor",
                type = "Spell",
                tooltip = Tooltips.Demeanor,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CloakHP",
                type = "Spell",
                tooltip = Tooltips.CloakHP,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "SelfDS",
                type = "Spell",
                tooltip = Tooltips.SelfDS,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell) and Casting.ReagentCheck(spell)
                end,
            },
            {
                name = "Covenant",
                type = "Spell",
                tooltip = Tooltips.Covenant,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "CallAtk",
                type = "Spell",
                tooltip = Tooltips.CallAtk,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return self.Helpers.SingleBuffCheck() and Casting.SelfBuffCheck(spell)
                end,
            },
            --You'll notice my use of TotalSeconds, this is to keep as close to 100% uptime as possible on these buffs, rebuffing early to decrease the chance of them falling off in combat
            --I considered creating a function (helper or utils) to govern this as I use it on multiple classes but the difference between buff window/song window/aa/spell etc makes it unwieldy
            -- if using duration checks, dont use SelfBuffCheck() (as it could return false when the effect is still on)
            {
                name = "Skin",
                type = "Spell",
                tooltip = Tooltips.Skin,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 60
                end,
            },
            {
                name = "TempHP",
                type = "Spell",
                tooltip = Tooltips.TempHP,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoTempHP') or not Casting.CastReady(spell) then return false end
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 45
                end,
            },
            {
                name = "HealBurn",
                type = "Spell",
                tooltip = Tooltips.HealBurn,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    return spell.RankName.Stacks() and (mq.TLO.Me.Buff(spell).Duration.TotalSeconds() or 0) < 30
                end,
            },
            {
                name = "Voice of Thule",
                type = "AA",
                tooltip = Tooltips.HateBuff,
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not Config:GetSetting('DoHateBuff') then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
            {
                name = "HateBuff",
                type = "Spell",
                tooltip = Tooltips.HateBuff,
                active_cond = function(self, spell) return Casting.IHaveBuff(spell) end,
                cond = function(self, spell)
                    if not Config:GetSetting('DoHateBuff') or Casting.CanUseAA('Voice of Thule') or not Casting.CastReady(spell) then return false end
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            { --Charm Click, name function stops errors in rotation window when slot is empty
                name_func = function() return mq.TLO.Me.Inventory("Charm").Name() or "CharmClick(Missing)" end,
                type = "Item",
                cond = function(self, itemName, target)
                    if not Config:GetSetting('DoCharmClick') or not Casting.ItemHasClicky(itemName) then return false end
                    return Casting.SelfBuffItemCheck(itemName)
                end,
            },
            {
                name = "Scourge Skin",
                type = "AA",
                --tooltip = Tooltips.ScourgeSkin,
                active_cond = function(self, aaName) return Casting.IHaveBuff(mq.TLO.Me.AltAbility(aaName).Spell.ID()) end,
                cond = function(self, aaName)
                    if not Core.IsTanking() then return false end
                    return Casting.SelfBuffAACheck(aaName)
                end,
            },
        },
        ['PetSummon'] = {
            {
                name = "PetSpell",
                type = "Spell",
                tooltip = Tooltips.PetSpell,
                active_cond = function(self, spell) return mq.TLO.Me.Pet.ID() > 0 end,
                cond = function(self, spell)
                    if mq.TLO.Me.Pet.ID() ~= 0 or not Config:GetSetting('DoPet') then return false end
                    return Casting.ReagentCheck(spell)
                end,
                post_activate = function(self, spell, success)
                    if success and mq.TLO.Me.Pet.ID() > 0 then
                        mq.delay(50) -- slight delay to prevent chat bug with command issue
                        self:SetPetHold()
                    end
                end,
            },
        },
        ['PetBuff'] = {
            {
                name = "PetHaste",
                type = "Spell",
                tooltip = Tooltips.PetHaste,
                active_cond = function(self, spell) return mq.TLO.Me.PetBuff(spell.RankName())() ~= nil end,
                cond = function(self, spell)
                    return Casting.PetBuffCheck(spell)
                end,
            },
        },
        ['Emergency'] = {
            --Note that in Tank Mode, defensive discs are preemptively cycled on named in the (non-emergency) Defenses rotation
            --Abilities should be placed in order of lowest to highest triggered HP thresholds
            --Side Note: I reserve Bargain for manual use while driving, the omission is intentional. I haven't quite thought about how I would automate it.
            { --Note that on named we may already have a mantle/carapace running already, could make this remove other discs, but meh, Shield Flash still a thing.
                name = "Deflection",
                type = "Disc",
                tooltip = Tooltips.Deflection,
                pre_activate = function(self)
                    if not Core.ShieldEquipped() and Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical') and Casting.NoDiscActive() and
                        (mq.TLO.Me.AltAbilityTimer("Shield Flash")() or 0) < 234000
                end,
            },
            {
                name = "LeechCurse",
                type = "Disc",
                tooltip = Tooltips.LeechCurse,
                cond = function(self)
                    return Casting.NoDiscActive() and mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical')
                end,
            },
            {
                name = "Shield Flash",
                type = "AA",
                tooltip = Tooltips.ShieldFlash,
                pre_activate = function(self)
                    if not Core.ShieldEquipped() and Config:GetSetting('UseBandolier') then
                        Core.SafeCallFunc("Equip Shield", ItemManager.BandolierSwap, "Shield")
                    end
                end,
                cond = function(self, aaName)
                    return mq.TLO.Me.ActiveDisc.Name() ~= "Deflection Discipline"
                end,
            },
            {
                name = "Armor of Experience",
                type = "AA",
                tooltip = Tooltips.ArmorofExperience,
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
                cond = function(self, aaName)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical')
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
            --if we made it this far let's reset our dicho/dire and hope for the best!
            {
                name = "Forceful Rejuvenation",
                type = "AA",
                tooltip = Tooltips.ForcefulRejuv,
            },
        },
        ['HateTools(AggroTarget)'] = {
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                load_cond = function(self) return Config:GetSetting('DoTerror') == 3 or (Config:GetSetting('DoTerror') == 2 and not Core.GetResolvedActionMapItem('ForPower')) end,
            },
            {
                name = "Terror2",
                type = "Spell",
                tooltip = Tooltips.Terror,
                load_cond = function(self) return Config:GetSetting('DoTerror') == 3 or (Config:GetSetting('DoTerror') == 2 and not Core.GetResolvedActionMapItem('ForPower')) end,
            },
            {
                name = "Acrimony",
                type = "Disc",
                tooltip = Tooltips.Acrimony,
            },
            {
                name = "Veil of Darkness",
                type = "AA",
                tooltip = Tooltips.VeilofDarkness,
            },
            {
                name = "ForPower",
                type = "Spell",
                tooltip = Tooltips.ForPower,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoForPower') then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
        },
        ['HateTools(AutoTarget)'] = {
            --used when we've lost hatred after it is initially established
            {
                name = "Ageless Enmity",
                type = "AA",
                tooltip = Tooltips.AgelessEnmity,
                cond = function(self, aaName, target)
                    return Targeting.GetAutoTargetPctHPs() < 90 and mq.TLO.Me.PctAggro() < 100
                end,
            },
            --used to jumpstart hatred on named from the outset and prevent early rips from burns
            {
                name = "Acrimony",
                type = "Disc",
                tooltip = Tooltips.Acrimony,
                cond = function(self, discSpell, target)
                    return Globals.AutoTargetIsNamed
                end,
            },
            --used to reinforce hatred on named
            {
                name = "Veil of Darkness",
                type = "AA",
                tooltip = Tooltips.VeilofDarkness,
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and (mq.TLO.Target.SecondaryPctAggro() or 0) > 70
                end,
            },
            {
                name = "Projection of Doom",
                type = "AA",
                tooltip = Tooltips.ProjectionofDoom,
                cond = function(self, aaName, target)
                    return Globals.AutoTargetIsNamed and (mq.TLO.Target.SecondaryPctAggro() or 0) > 80
                end,
            },
            {
                name = "Taunt",
                type = "Ability",
                tooltip = Tooltips.Taunt,
                cond = function(self, abilityName, target)
                    return Targeting.LostAutoTargetAggro()
                end,
            },
            {
                name = "Terror",
                type = "Spell",
                tooltip = Tooltips.Terror,
                load_cond = function(self) return Config:GetSetting('DoTerror') == 3 or (Config:GetSetting('DoTerror') == 2 and not Core.GetResolvedActionMapItem('ForPower')) end,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoTerror') == 1 or mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                    return (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
            {
                name = "Terror2",
                type = "Spell",
                tooltip = Tooltips.Terror,
                load_cond = function(self) return Config:GetSetting('DoTerror') == 3 or (Config:GetSetting('DoTerror') == 2 and not Core.GetResolvedActionMapItem('ForPower')) end,
                cond = function(self, spell, target)
                    if Config:GetSetting('DoTerror') == 1 or mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                    return (mq.TLO.Target.SecondaryPctAggro() or 0) > 60
                end,
            },
        },
        ['AEHateTools'] = {
            {
                name = "Explosion of Hatred",
                type = "AA",
                tooltip = Tooltips.ExplosionOfHatred,
            },
            {
                name = "Explosion of Spite",
                type = "AA",
                tooltip = Tooltips.ExplosionOfSpite,
            },
            {
                name = "AETaunt",
                type = "Spell",
                tooltip = Tooltips.AETaunt,
                cond = function(self, spell, target)
                    return mq.TLO.Me.PctHPs() > Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "AELifeTap",
                type = "Spell",
                cond = function(self, spell)
                    if not (Config:GetSetting('DoAELifeTap') and Config:GetSetting('DoAEDamage')) or mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart') then return false end
                    return Combat.AETargetCheck(true)
                end,
            },
        },
        ['Burn'] = {
            {
                name = "Visage of Death",
                type = "AA",
            },
            {
                name = "Crimson",
                type = "Disc",
                tooltip = Tooltips.Crimson,
            },
            {
                name = "Intensity of the Resolute",
                type = "AA",
                load_cond = function(self) return Config:GetSetting('DoVetAA') end,
            },
            {
                name = "Harm Touch",
                type = "AA",
            },
            {
                name = "Thought Leech",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoThoughtLeech') ~= 1
                end,
            },
            {
                name = "Leech Touch",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    return Config:GetSetting('DoLeechTouch') ~= 1
                end,
            },
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
                cond = function(self, itemName, target)
                    return Globals.AutoTargetIsNamed
                end,
            },
            {
                name = "Spire of the Reavers",
                type = "AA",
                tooltip = Tooltips.SpireoftheReavers,
            },
            {
                name = "Chattering Bones",
                type = "AA",
                tooltip = Tooltips.ChatteringBones,
            },
            {
                name = "T`Vyl's Resolve",
                type = "AA",
                tooltip = Tooltips.Tvyls,
            },
            {
                name = "SpiteStrike",
                type = "Disc",
                tooltip = Tooltips.SpikeStrike,
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "InfluenceDisc",
                type = "Disc",
                tooltip = Tooltips.InfluenceDisc,
                load_cond = function(self) return not Core.IsTanking() end,
                cond = function(self, discSpell)
                    return Casting.NoDiscActive()
                end,
            },
        },
        ['Snare'] = {
            {
                name = "Encroaching Darkness",
                tooltip = Tooltips.EncroachingDarkness,
                type = "AA",
                load_cond = function(self) return Casting.CanUseAA("Encroaching Darkness") end,
                cond = function(self, aaName, target)
                    return Casting.DetAACheck(aaName) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
            {
                name = "SnareDot",
                type = "Spell",
                tooltip = Tooltips.SnareDot,
                load_cond = function(self) return not Casting.CanUseAA("Encroaching Darkness") end,
                cond = function(self, spell, target)
                    return Casting.DetSpellCheck(spell) and Targeting.MobHasLowHP(target) and not Casting.SnareImmuneTarget(target)
                end,
            },
        },
        ['DefensiveDiscs'] = {
            {
                name = "Carapace",
                type = "Disc",
                tooltip = Tooltips.Carapace,
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Mantle",
                type = "Disc",
                tooltip = Tooltips.Mantle,
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "Guardian",
                type = "Disc",
                tooltip = Tooltips.Guardian,
                cond = function(self, discSpell, target)
                    if not Core.IsTanking() then return false end
                    return Casting.NoDiscActive()
                end,
            },
            {
                name = "UnholyAura",
                type = "Disc",
                tooltip = Tooltips.UnholyAura,
                cond = function(self, discSpell, target)
                    return Casting.NoDiscActive()
                end,
            },
        },
        ['LeechEffects'] = {
            {
                name = "Epic",
                type = "Item",
                tooltip = Tooltips.Epic,
            },
            {
                name = "OoW_Chest",
                type = "Item",
                tooltip = Tooltips.OoW_BP,
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
        ['LifeTaps'] = {
            --Full rotation to make sure we use these in priority for emergencies
            {
                name = "Leech Touch",
                type = "AA",
                tooltip = Tooltips.LeechTouch,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoLeechTouch') == 2 then return false end
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('HPCritical')
                end,
            },
            --the trick with the next two is to find a sweet spot between using discs and long term CD abilities (we want these to trigger so those don't need to) and using them needlessly (which isn't much of a damage increase). Trying to get it dialed in for a good default value.
            {
                name = "Dicho",
                type = "Spell",
                tooltip = Tooltips.Dicho,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDicho') then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return (myHP <= Config:GetSetting('EmergencyStart') or (Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartDicho')))
                end,
            },
            {
                name = "DireTap",
                type = "Spell",
                tooltip = Tooltips.DireTap,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoDireTap') then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return (myHP <= Config:GetSetting('EmergencyStart') or (Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartDireTap')))
                end,
            },
            {
                name = "LifeTap",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell, target)
                    local myHP = mq.TLO.Me.PctHPs()
                    return (myHP <= Config:GetSetting('EmergencyStart') or (Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartLifeTap')))
                end,
            },
            {
                name = "AELifeTap",
                type = "Spell",
                cond = function(self, spell, target)
                    if not (Config:GetSetting('DoAELifeTap') and Config:GetSetting('DoAEDamage')) then return false end
                    local myHP = mq.TLO.Me.PctHPs()
                    return (myHP <= Config:GetSetting('EmergencyStart') or (Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartLifeTap'))) and Combat.AETargetCheck(true)
                end,
            },
            { --This entry solely for emergencies on SK as a fallback, group has a different entry.
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('EmergencyStart')
                end,
            },
            {
                name = "LifeTap2",
                type = "Spell",
                tooltip = Tooltips.LifeTap,
                cond = function(self, spell, target)
                    local myHP = mq.TLO.Me.PctHPs()
                    return (myHP <= Config:GetSetting('EmergencyStart') or (Casting.HaveManaToNuke() and myHP <= Config:GetSetting('StartLifeTap')))
                end,
            },
        },
        ['CombatWeave'] = {
            {
                name = "CombatEndRegen",
                type = "Disc",
                tooltip = Tooltips.CombatEndRegen,
                cond = function(self, discSpell)
                    return mq.TLO.Me.PctEndurance() < 15
                end,
            },
            {
                name = "MeleeMit",
                type = "Disc",
                tooltip = Tooltips.MeleeMit,
                cond = function(self, discSpell)
                    if not Core.IsTanking() then return false end
                    return not ((discSpell.Level() or 0) < 108 and mq.TLO.Me.ActiveDisc.ID())
                end,
            },
            { --Used if the group could benefit from the heal
                name = "ReflexStrike",
                type = "Disc",
                tooltip = Tooltips.ReflexStrike,
                cond = function(self, discSpell)
                    return Targeting.GroupHealsNeeded()
                end,
            },
            {
                name = "Vicious Bite of Chaos",
                type = "AA",
                tooltip = Tooltips.ViciousBiteOfChaos,
            },
            {
                name = "Blade",
                type = "Disc",
                tooltip = Tooltips.Blade,
            },
            {
                name = "Gift of the Quick Spear",
                type = "AA",
            },
            {
                name = "Thought Leech",
                type = "AA",
                tooltip = Tooltips.ThoughtLeech,
                cond = function(self, aaName, target)
                    if Config:GetSetting('DoThoughtLeech') == 2 then return false end
                    return mq.TLO.Me.PctMana() < 10
                end,
            },
            {
                name = "Bash",
                type = "Ability",
                -- tooltip = Tooltips.Bash,
                cond = function(self, abilityName, target)
                    return (Core.ShieldEquipped() or Casting.CanUseAA("Improved Bash"))
                end,
            },
            {
                name = "Slam",
                type = "Ability",
                tooltip = Tooltips.Slam,
            },
        },
        ['Combat'] = {
            {
                name = "ForPower",
                type = "Spell",
                tooltip = Tooltips.ForPower,
                cond = function(self, spell, target)
                    if not Config:GetSetting('DoForPower') then return false end
                    return Casting.DetSpellCheck(spell)
                end,
            },
            {
                name = "BondTap",
                type = "Spell",
                tooltip = Tooltips.BondTap,
                load_cond = function(self) return Config:GetSetting('DoBondTap') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "SpearNuke",
                type = "Spell",
                tooltip = Tooltips.SpearNuke,
                cond = function(self, spell, target)
                    return Casting.HaveManaToNuke()
                end,
            },
            {
                name = "PoisonDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                load_cond = function(self) return Config:GetSetting('DoPoisonDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "CorruptionDot",
                type = "Spell",
                tooltip = Tooltips.PoisonDot,
                load_cond = function(self) return Config:GetSetting('DoCorruptionDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "DireDot",
                type = "Spell",
                tooltip = Tooltips.DireDot,
                load_cond = function(self) return Config:GetSetting('DoDireDot') end,
                cond = function(self, spell, target)
                    return Casting.HaveManaToDot() and Casting.DotSpellCheck(spell)
                end,
            },
            {
                name = "BiteTap",
                type = "Spell",
                tooltip = Tooltips.BiteTap,
                cond = function(self, spell, target) --no mana check here because this returns half the mana cost to the entire group. can adjust later as needed.
                    return mq.TLO.Me.PctHPs() <= Config:GetSetting('StartLifeTap')
                end,
            },
            {
                name = "PowerTapAC",
                type = "Spell",
                tooltip = Tooltips.PowerTapAC,
                load_cond = function(self) return Config:GetSetting('DoACTap') end,
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "PowerTapAtk",
                type = "Spell",
                tooltip = Tooltips.PowerTapAtk,
                load_cond = function(self) return Config:GetSetting('DoAtkTap') end,
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
            {
                name = "MaxHPTap",
                type = "Spell",
                tooltip = Tooltips.MaxHPTap,
                load_cond = function(self) return Config:GetSetting('DoMaxHPTap') end,
                cond = function(self, spell, target)
                    return Casting.SelfBuffCheck(spell)
                end,
            },
        },
        ['Weapon Management'] = {
            {
                name = "Equip Shield",
                type = "CustomFunc",
                cond = function(self)
                    if mq.TLO.Me.Bandolier("Shield").Active() then return false end
                    return self.Helpers.shieldNeeded()
                end,
                custom_func = function(self)
                    ItemManager.BandolierSwap("Shield")
                    return true
                end,
            },
            {
                name = "Equip 2Hand",
                type = "CustomFunc",
                cond = function(self)
                    if mq.TLO.Me.Bandolier("2Hand").Active() then return false end
                    return mq.TLO.Me.PctHPs() >= Config:GetSetting('Equip2Hand') and not self.Helpers.shieldNeeded()
                end,
                custom_func = function(self)
                    ItemManager.BandolierSwap("2Hand")
                    return true
                end,
            },
        },
    },
    ['Spells']        = { --I am not trying to find a combination that works when we have 20 options that change based on level, so I've just made a repeating priority list. May adjust this later.
        {
            gem = 1,
            spells = {
                { name = "SpearNuke", },
            },
        },
        {
            gem = 2,
            spells = {
                { name = "LifeTap", },
            },
        },
        {
            gem = 3,
            spells = {
                { name = "SnareDot", cond = function(self) return Config:GetSetting('DoSnare') and not Casting.CanUseAA("Encroaching Darkness") end, },
                { name = "DireTap",  cond = function(self) return Config:GetSetting('DoDireTap') end, },
                { name = "Dicho",    cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
            },
        },
        {
            gem = 4,
            spells = {
                { name = "DireTap",  cond = function(self) return Config:GetSetting('DoDireTap') end, },
                { name = "Dicho",    cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AELifeTap",   cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "LifeTap2", },
            },
        },
        {
            gem = 5,
            spells = {
                { name = "Dicho",    cond = function(self) return Config:GetSetting('DoDicho') end, },
                { name = "ForPower", cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AELifeTap",   cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 6,
            spells = {
                { name = "ForPower",      cond = function(self) return Config:GetSetting('DoForPower') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "AELifeTap",   cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 7,
            spells = {
                { name = "PetSpell", cond = function(self) return Config:GetSetting('DoPet') end, },
                {
                    name = "Terror",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        {
            gem = 8,
            cond = function(self) return mq.TLO.Me.NumGems() >= 9 end,
            spells = {
                {
                    name = "AETaunt",
                    cond = function(self)
                        local setting = Config:GetSetting('AETauntSpell')
                        return setting == 3 or (setting == 2 and not Casting.CanUseAA("Explosion of Hatred"))
                    end,
                },
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },

            },
        },
        { -- Level 55
            gem = 9,
            cond = function(self) return mq.TLO.Me.NumGems() >= 10 end,
            spells = {
                { name = "BiteTap", },
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 75
            gem = 10,
            cond = function(self) return mq.TLO.Me.NumGems() >= 11 end,
            spells = {
                { name = "TempHP",        cond = function(self) return Config:GetSetting('DoTempHP') and mq.TLO.Me.NumGems() < 13 end, }, --level 84, this spell starts in a long recast so I prefer to keep it on the bar.
                { name = "BondTap",       cond = function(self) return Config:GetSetting('DoBondTap') end, },
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "PowerTapAtk", cond = function(self) return Config:GetSetting('DoAtkTap') and mq.TLO.Me.Level() < 76 end, },
                { name = "MaxHPTap",    cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "Skin",        cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 80
            gem = 11,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHP",        cond = function(self) return Config:GetSetting('DoTempHP') and mq.TLO.Me.NumGems() < 14 end, }, --level 84, this spell starts in a long recast so I prefer to keep it on the bar.
                { name = "Skin",          cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },              -- level 70, while not as bad as the TempHP line, also starts in a recast. Placed higher before level 106.
                { name = "PoisonDot",     cond = function(self) return Config:GetSetting('DoPoisonDot') end, },
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "MaxHPTap", cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 80
            gem = 12,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "TempHP",        cond = function(self) return Config:GetSetting('DoTempHP') and mq.TLO.Me.NumGems() == 14 end, }, --level 84, this spell starts in a long recast so I prefer to keep it on the bar.
                { name = "Skin",          cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 14 end, },               -- level 70, while not as bad as the TempHP line, also starts in a recast. Placed higher before level 106.
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "MaxHPTap", cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "HealBurn", cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 13 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 106
            gem = 13,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "Skin",          cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() == 14 end, }, -- level 70, while not as bad as the TempHP line, also starts in a recast. Placed higher before level 106.
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "MaxHPTap", cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "HealBurn", cond = function(self) return Core.IsTanking() and mq.TLO.Me.NumGems() < 14 end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
        { -- Level 125
            gem = 14,
            cond = function(self, gem) return mq.TLO.Me.NumGems() >= gem end,
            spells = {
                { name = "CorruptionDot", cond = function(self) return Config:GetSetting('DoCorruptionDot') end, },
                { name = "AELifeTap",     cond = function(self) return Config:GetSetting('DoAELifeTap') end, },
                { name = "DireDot",       cond = function(self) return Config:GetSetting('DoDireDot') end, },
                {
                    name = "PowerTapAC",
                    cond = function(self)
                        local level = mq.TLO.Me.Level()
                        return Config:GetSetting('DoACTap') and (level <= 75 or level >= 100)
                    end,
                },
                { name = "MaxHPTap", cond = function(self) return Config:GetSetting('DoMaxHPTap') end, },
                { name = "HealBurn", cond = function(self) return Core.IsTanking() end, },
                { name = "LifeTap2", },
                {
                    name = "Terror2",
                    cond = function(self)
                        local setting = Config:GetSetting('DoTerror')
                        return setting == 3 or (setting == 2 and mq.TLO.Me.Level() < 72)
                    end,
                },
            },
        },
    },
    ['PullAbilities'] = {
        {
            id = 'SpearNuke',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('SpearNuke').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('SpearNuke')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Terror',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Terror').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Terror')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'Terror2',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('Terror2').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('Terror2').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('Terror2')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'ForPower',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('ForPower').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('ForPower')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'LifeTap',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('LifeTap').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('LifeTap').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('LifeTap')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
        {
            id = 'LifeTap2',
            Type = "Spell",
            DisplayName = function() return Core.GetResolvedActionMapItem('LifeTap2').RankName.Name() or "" end,
            AbilityName = function() return Core.GetResolvedActionMapItem('LifeTap2').RankName.Name() or "" end,
            AbilityRange = 200,
            cond = function(self)
                local resolvedSpell = Core.GetResolvedActionMapItem('LifeTap2')
                if not resolvedSpell then return false end
                return mq.TLO.Me.Gem(resolvedSpell.RankName.Name() or "")() ~= nil
            end,
        },
    },
    ['DefaultConfig'] = {
        --Mode
        ['Mode']              = {
            DisplayName = "Mode",
            Category = "Mode",
            Tooltip = "Select the active Combat Mode for this PC.",
            Type = "Custom",
            RequiresLoadoutChange = true,
            Default = 1,
            Min = 1,
            Max = 2,
            FAQ = "What do the different Modes do?",
            Answer = "Tank Mode will focus on tanking and aggro, while DPS mode will focus on DPS.",
        },
        --Buffs and Debuffs
        ['DoSnare']           = {
            DisplayName = "Use Snares",
            Group = "Abilities",
            Header = "Debuffs",
            Category = "Snare",
            Index = 101,
            Tooltip = "Use Snare(Snare Dot used until AA is available).",
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['SnareCount']        = {
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
        ['DoTempHP']          = {
            DisplayName = "Use HP Buff",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 101,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("TempHP") end,
            Default = true,
            RequiresLoadoutChange = true,
        },
        ['ProcChoice']        = {
            DisplayName = "HP/Mana Proc:",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 102,
            Tooltip = "Prefer HP Proc and DLU(Azia) or Mana Proc and DLU(Beza)",
            Type = "Combo",
            ComboOptions = { 'HP Proc: Horror Line, DLU(Azia)', 'Mana Proc: Mental Line, DLU(Beza)', 'Disabled', },
            Default = 1,
            Min = 1,
            Max = 3,
            RequiresLoadoutChange = true,
        },
        ['OverwriteDLUBuffs'] = {
            DisplayName = "Overwrite DLU Buffs",
            Group = "Abilities",
            Header = "Buffs",
            Category = "Self",
            Index = 103,
            Tooltip = "Overwrite DLU with single buffs when they are better than the DLU effect.",
            Default = false,
            ConfigType = "Advanced",
        },
        ['DoVetAA']           = {
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

        --Taps
        ['StartLifeTap']      = {
            DisplayName = "HP % for LifeTaps",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 101,
            Tooltip = "Your HP % before we use Life Taps.",
            Default = 99,
            Min = 1,
            Max = 100,
        },
        ['DoDireTap']         = {
            DisplayName = "Cast Dire Taps",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 102,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("DireTap") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['StartDireTap']      = {
            DisplayName = "HP % for Dire",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 103,
            Tooltip = "Your HP % before we use Dire taps.",
            Default = 85,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['DoDicho']           = {
            DisplayName = "Cast Dicho Taps",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 104,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("Dicho") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['StartDicho']        = {
            DisplayName = "HP % for Dicho",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 105,
            Tooltip = "Your HP % before we use Dicho taps.",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['DoACTap']           = {
            DisplayName = "Use AC Tap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 106,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("PowerTapAC") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoAtkTap']          = {
            DisplayName = "Use Attack Tap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 107,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("PowerTapAtk") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['DoMaxHPTap']        = {
            DisplayName = "Use Max HP Tap",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 108,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("MaxHPTap") end,
            Default = false,
            RequiresLoadoutChange = true,
            ConfigType = "Advanced",
            FAQ = "Why am I not using the Max HP Buff Tap?",
            Answer = "The description can be misleading, these spells are not Life Taps. At some level ranges, the HP Buff is negligible.\n" ..
                "You can enable the Max HP tap buff on the Taps tab.",
        },
        ['DoLeechTouch']      = {
            DisplayName = "Leech Touch Use:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 109,
            Tooltip = "When to use Leech Touch",
            Type = "Combo",
            ComboOptions = { 'On critically low HP', 'As DD during burns', 'For HP or DD', },
            Default = 1,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },
        ['DoThoughtLeech']    = {
            DisplayName = "Thought Leech Use:",
            Group = "Abilities",
            Header = "Damage",
            Category = "Taps",
            Index = 110,
            Tooltip = "When to use Thought Leech",
            Type = "Combo",
            ComboOptions = { 'On critically low mana', 'As DD during burns', 'For Mana or DD', },
            Default = 3,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },

        --DoT Spells
        ['DoBondTap']         = {
            DisplayName = "Use Bond Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 101,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("BondTap") end,
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoPoisonDot']       = {
            DisplayName = "Use Poison Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 102,
            ToolTip = function() return Ui.GetDynamicTooltipForSpell("PoisonDot") end,
            RequiresLoadoutChange = true,
            Default = true,
        },
        ['DoCorruptionDot']   = {
            DisplayName = "Use Corrupt Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 103,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("CorruptDot") end,
            RequiresLoadoutChange = true,
            Default = true,
            FAQ = "I heard SHD dots suck, why are we using them?",
            Answer = "On live, SHD dot damage has been buffed more than once in the last few years, and is likely worthwhile. For other servers or eras, consult your class experts!",
        },
        ['DoDireDot']         = {
            DisplayName = "Use Dire Dot",
            Group = "Abilities",
            Header = "Damage",
            Category = "Over Time",
            Index = 104,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("DireDot") end,
            RequiresLoadoutChange = true,
            Default = false,
        },

        -- AE Damage
        ['DoAELifeTap']       = {
            DisplayName = "Use AE Hate/LifeTap",
            Group = "Abilities",
            Header = "Damage",
            Category = "AE",
            Index = 101,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("AELifeTap") end,
            RequiresLoadoutChange = true,
            Default = false,
        },

        --Hate Tools
        ['DoHateBuff']        = {
            DisplayName = "Use Hate Buff",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 101,
            Tooltip = "Use your Visage buff (Voice of ... line). If the AA is not available, we will use/memorize the spell if we have enough open slots.",
            Default = true,
            ConfigType = "Advanced",
            RequiresLoadoutChange = true,
            FAQ = "Why am I not using my Visage Buff, Voice of ...?",
            Answer = "Even if the Use Hate Buff option is selected, you may not have enough spell gems to keep the spell on your bar with other options.\n" ..
                "Do to the incredibly long recast time (around 9 minutes), we will not memorize these to use them on the fly.",
        },
        ['DoTerror']          = {
            DisplayName = "Terror Taunts:",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 102,
            Tooltip = "Choose the level range (if any) to memorize Terror Spells.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'Until "For Power" spells are available', 'Always', },
            Default = 2,
            Min = 1,
            Max = 3,
        },
        ['DoForPower']        = {
            DisplayName = "Use \"For Power\"",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 103,
            Tooltip = function() return Ui.GetDynamicTooltipForSpell("ForPower") end,
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
        },
        ['AETauntAA']         = {
            DisplayName = "Use AE Taunt AA",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 104,
            Tooltip = "Use Explosions of Hatred and Spite.",
            RequiresLoadoutChange = true,
            Default = true,
            ConfigType = "Advanced",
            FAQ = "Why do we treat the Explosions the same? One is targeted, one is PBAE",
            Answer = "There are currently no scripted conditions where Hatred would be used at long range, thus, for ease of use, we can treat them similarly.",
        },
        ['AETauntSpell']      = {
            DisplayName = "AE Taunt Spell Choice:",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Hate Tools",
            Index = 105,
            Tooltip = "Choose the level range (if any) to memorize AE Taunt Spells.",
            RequiresLoadoutChange = true,
            Type = "Combo",
            ComboOptions = { 'Never', 'Until Explosions (AA Taunts) are available', 'Always', },
            Default = 2,
            Min = 1,
            Max = 3,
            ConfigType = "Advanced",
        },

        --Defenses
        ['DiscCount']         = {
            DisplayName = "Def. Disc. Count",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 101,
            Tooltip = "Number of mobs around you before you use preemptively use Defensive Discs.",
            Default = 4,
            Min = 1,
            Max = 10,
            ConfigType = "Advanced",
        },
        ['DefenseStart']      = {
            DisplayName = "Defense Start",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 102,
            Tooltip = "The HP % where we will use defensive discs and the like.\nNote that fighting a named will also trigger these actions.",
            Default = 70,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['EmergencyStart']    = {
            DisplayName = "Emergency Start",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 103,
            Tooltip = "The HP % before heavy defensive abilities like Shield Flash are triggered.\n Some non-essential rotations are skipped to help us focus on survival (See FAQ).",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['HPCritical']        = {
            DisplayName = "HP Critical",
            Group = "Abilities",
            Header = "Tanking",
            Category = "Defenses",
            Index = 104,
            Tooltip =
            "The HP % that we will use disciplines like Deflection, Leechcurse, and Leech Touch.\nMost other rotations are cut to give our full focus to survival (See FAQ).",
            Default = 30,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },

        --Equipment
        ['DoChestClick']      = {
            DisplayName = "Do Chest Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 101,
            Tooltip = "Click your equipped chest.",
            Default = mq.TLO.MacroQuest.BuildName() ~= "Emu",
        },
        ['DoCharmClick']      = {
            DisplayName = "Do Charm Click",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 102,
            Tooltip = "Click your charm for Geomantra.",
            Default = false,
        },
        ['DoCoating']         = {
            DisplayName = "Use Coating",
            Group = "Items",
            Header = "Clickies",
            Category = "Class Config Clickies",
            Index = 103,
            Tooltip = "Click your Blood/Spirit Drinker's Coating when defenses are triggered.",
            Default = false,
        },
        ['UseBandolier']      = {
            DisplayName = "Dynamic Weapon Swap",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 101,
            Tooltip = "Enable 1H+S/2H swapping based off of current health. ***YOU MUST HAVE BANDOLIER ENTRIES NAMED \"Shield\" and \"2Hand\" TO USE THIS FUNCTION.***",
            Default = false,
            RequiresLoadoutChange = true,
        },
        ['EquipShield']       = {
            DisplayName = "Equip Shield",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 102,
            Tooltip = "Under this HP%, you will swap to your \"Shield\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 50,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['Equip2Hand']        = {
            DisplayName = "Equip 2Hand",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 103,
            Tooltip = "Over this HP%, you will swap to your \"2Hand\" bandolier entry. (Dynamic Bandolier Enabled Only)",
            Default = 75,
            Min = 1,
            Max = 100,
            ConfigType = "Advanced",
        },
        ['NamedShieldLock']   = {
            DisplayName = "Shield on Named",
            Group = "Items",
            Header = "Bandolier",
            Category = "Bandolier",
            Index = 104,
            Tooltip = "Keep Shield equipped while tanking a named.",
            Default = true,
            FAQ = "Why does my SHD switch to a Shield on puny gray named?",
            Answer = "The Shield on Named option doesn't check levels, so feel free to disable this setting (or Bandolier swapping entirely) if you are farming fodder.",
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
