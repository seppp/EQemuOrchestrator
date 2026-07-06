# RGMercs Command Reference (`/rgl`)

Here is a comprehensive list of all available `/rgl` (or `/rglua`) commands across the core script and its modules, along with their descriptions.

## Core Operation & States
- `/rgl backoff <on|off>` - Toggles or sets backoff flag, which temporarily stops the PC from assisting or engaging.
- `/rgl pause` - Pauses your RGMercs Main Loop.
- `/rgl pauseall` - Pauses the RGMercs Main Loop for every client running RGMercs.
- `/rgl togglepause` - Toggle the pause state of your RGMercs Main Loop.
- `/rgl unpause` - Unpauses your RGMercs Main Loop.
- `/rgl unpauseall` - Unpauses the RGMercs Main Loop for every client running RGMercs.

## Settings & Configuration
- `/rgl cleartempall` - Clears all temporarily set RGMercs setting back to their saved values.
- `/rgl cleartempset <setting>` - Clears a specific temporarily set RGMercs setting back to the saved value.
- `/rgl copy <config|guide>` - Copies your current loadout config or wiki guide to the clipboard.
- `/rgl dbcheck` - Checks the integrity of your config DB. Only needed for versions prior to 2.1.0.
- `/rgl dbconvert` - Converts your config to the new DB format. Only needed for versions prior to 2.1.0.
- `/rgl export_config <module>` - Exports your current RGMercs configuration to chat
- `/rgl reset_config_position` - Resets the Options Window position to the center of the screen.
- `/rgl set [show | <setting> <value>]` - Show all settings or set a specific RGMercs setting.
- `/rgl set_all <setting> <value>` - Sets a specific setting for this character and all RGMercs peers.
- `/rgl set_peer <peer> <setting> <value>` - Sets a specific setting for an RGMercs peer.
- `/rgl setmode <mode>` - Change the active class mode to <mode>.
- `/rgl tempset <setting> <value>` - Temporarily sets a specific RGMercs setting until you restart the script or clear the temp setting.

## Targeting & Assist
- `/rgl assistadd <Name>` - Adds <Name> to the Assist List. If no name is entered, your target's name is used.
- `/rgl assistclear` - Completely clears the Assist List.
- `/rgl assistdelete (<Name> or <List#>)` - Deletes (<Name> or <List#>) from the Assist List. If no name is entered, your target's name is used.
- `/rgl assistdown (<Name> or <List#>)` - Moves (<Name> or <List#>) one position down on the Assist List. If no name is entered, your target's name is used.
- `/rgl assisttop (<Name> or <List#>)` - Moves (<Name> or <List#>) to the top of the Assist List. If no name is entered, your target's name is used.
- `/rgl assistup (<Name> or <List#>)` - Moves (<Name> or <List#>) one position up on the Assist List. If no name is entered, your target's name is used.
- `/rgl burnnow <id?>` - Will force the target <id> or your current target to trigger all burn checks - resets when combat ends.
- `/rgl forcetarget <id?>` - Will force the current target or <id> to be your autotarget no matter what until it is no longer valid. Can force combat on non-hostiles like objects, a special NPC, or a target dummy. If no ID is supplied, uses the current target's ID.
- `/rgl forcetargetclear` - Will clear the current forced target.
- `/rgl heallistadd <Name>` - Adds <Name> to the Heal List. If no name is entered, your target's name is used.
- `/rgl heallistclear` - Completely clears the Heal List.
- `/rgl heallistdelete (<Name> or <List#>)` - Deletes (<Name> or <List#>) from the Heal List. If no name is entered, your target's name is used.
- `/rgl ignoretarget <id?>` - Will force target to be ignored when picking your assist target as the MA.
- `/rgl ignoretargetclear` - Will clear all ignored targets.

## Movement, Camps & Pulling
- `/rgl campoff` - Clear your current camp.
- `/rgl campon` - Set a camp here. Disables Chase.
- `/rgl chaseoff` - Stop chasing your current chase target.
- `/rgl chaseon <name?>` - Chase <name>. If no name is supplied, it will fall back in order: (Last Used Chase Target > Main Assist). Clears your camp.
- `/rgl circle <radius>` - All groupmembers running RGMercss will form a circle around you using the entered radius.
- `/rgl pullallow \` - Adds <name> to the Pull Allow List. If no name is entered, your target's name is used. Ensure quotes are used on multi-word mob names!
- `/rgl pullallowrm \` - Removes <name> or <List#> from the Pull Allow List. If no name is entered, your target's name is used. Ensure quotes are used on multi-word mob names!
- `/rgl pulldeny \` - Adds <name> to the Pull Deny List. If no name is entered, your target's name is used. Ensure quotes are used on multi-word mob names!
- `/rgl pulldenyrm \` - Removes <name> or <List#> from the Pull Deny List. If no name is entered, your target's name is used. Ensure quotes are used on multi-word mob names!
- `/rgl pullignoreclear` - Clears the Pull Ignore List.
- `/rgl pullstart` - Enables pulling in the currently selected Pull Mode.
- `/rgl pullstop` - Disables the active Pull Mode.
- `/rgl pulltarget` - Pulls your current target using the currently selected Pull Ability.
- `/rgl setwpid <id>` - Set the current waypoint to <id>.

## Spells, Abilities & Rotations
- `/rgl cast \` - Queus a spell for use (memorizes if necessary), falls back to AA if the spell is invalid. If no targetId is entered, your target is used.
- `/rgl castaa \` - Queues an AA for use. If no targetId is entered, your target is used.
- `/rgl cureallow \` - Adds <effect name> to the Cure Allow List.
- `/rgl cureallowrm \` - Removes <effect name> or <List#> from the Cure Allow List.
- `/rgl curedeny \` - Adds <effect name> to the Cure Deny List.
- `/rgl curedenyrm \` - Removes <effect name> or <List#> from the Cure Deny List.
- `/rgl disableclicky <clicky name|idx>` - Disables the clicky item with the specified name or index.
- `/rgl disablecureentry \` - Disables a cure ability entry by name.
- `/rgl disablerezentry \` - Disables a rez ability entry by name.
- `/rgl disablerotation \` - Disables <Name> Rotation
- `/rgl disablerotationentry \` - Disables <Name> Rotation Entry
- `/rgl enableclicky <clicky name|idx>` - Enables the clicky item with the specified name or index.
- `/rgl enablecureentry \` - Enables a cure ability entry by name.
- `/rgl enablerezentry \` - Enables a rez ability entry by name.
- `/rgl enablerotation \` - Enables <Name> Rotation
- `/rgl enablerotationentry \` - Enables <Name> Rotation Entry
- `/rgl rebuff` - Forces buff checks to re-run on the next rotation. Does not cast any buff.
- `/rgl reordergems` - Repack your spell bar into priority order, ignoring current placement.
- `/rgl rescanloadout` - Rescans your current loadout for changes.
- `/rgl spellreload` - Updates your class rotations and entries based on current settings. Rescans and (if necessary) reloads your default spell gems.
- `/rgl stopcast` - Interrupts the current cast.
- `/rgl useitem \` - Queues an item for use. If no targetId is entered, your target is used.
- `/rgl usemap \` - Queues a map ability for use. If no targetId is entered, your target is used.

## Pets, Charm & Mez
- `/rgl charmallow \` - Adds <name> (or your target) to the Charm Allow List.
- `/rgl charmallowrm \` - Removes <name> or <List#> (or your target) from the Charm Allow List.
- `/rgl charmclear` - Clears the current-zone Charm Allow and Deny list entries.
- `/rgl charmdeny \` - Adds <name> (or your target) to the Charm Deny List.
- `/rgl charmdenyrm \` - Removes <name> or <List#> (or your target) from the Charm Deny List.
- `/rgl disablecharmentry \` - Disables a charm entry (charm spell, pre-charm step, or assist) by name, in every list it appears in.
- `/rgl disablemezentry \` - Disables a mez ability entry by name.
- `/rgl enablecharmentry \` - Enables a charm entry (charm spell, pre-charm step, or assist) by name, in every list it appears in.
- `/rgl enablemezentry \` - Enables a mez ability entry by name.
- `/rgl forcecharm <id?>` - Force-charm your target or <id>; held until in range. /rgl forcecharmclear to cancel.
- `/rgl forcecharmclear` - Clears the current force-charm directive.

## Named & Immunities
- `/rgl forcenamed` - Will force the current target to be considered a Named (this flag does not persist and is for testing purposes).
- `/rgl immuneadd <Fire|Cold|Magic|Poison|Disease|Slow|Snare|Stun> [Name]` - Flag a mob as immune to an element (Fire/Cold/Magic/Poison/Disease) or status effect (Slow/Snare/Stun) in the current zone. If no name is entered, your target's name is used.
- `/rgl immunedelete <Fire|Cold|Magic|Poison|Disease|Slow|Snare|Stun> [Name]` - Clear an elemental or status immunity flag from a mob in the current zone. If no name is entered, your target's name is used.
- `/rgl namedadd <Name>` - Adds <Name> to the User Named List for the current zone. If no name is entered, your target's name is used.
- `/rgl nameddelete [Name]` - Clears the Named flag for a mob in the current zone. If no name is entered, your target's name is used.
- `/rgl nameddeny [Name]` - Marks a mob as NOT named in the current zone, suppressing the built-in default and any overlay. If no name is entered, your target's name is used.

## Communication & UI
- `/rgl faq \` - Search the FAQ and display the results in the mq2 console. Please see the FAQ tab for a friendlier experience!
- `/rgl mini` - Toggle minimizing of the RGMercs window to a small icon.
- `/rgl pop <modulename>` - Toggles between popped and docked states for <modulename>.
- `/rgl qsay <text>` - All groupmembers running RGMercs will target your target and say the <text> with a random delay.
- `/rgl rsay <text>` - All raidmembers running RGMercs will target your target and say the <text> after a very short delay.
- `/rgl say <text>` - All groupmembers running RGMercs will target your target and say the <text> after a very short delay.
- `/rgl yes` - All groupmembers running RGMercs will click on every possible 'Yes' Dialogue they have up.

## Logging & Development
- `/rgl clearlogfilter` - Clear log regex filter.
- `/rgl exportwiki` - Export the FAQ to Wiki Files by Module.
- `/rgl iamnofun` - Let the RGMercs devs know you don't like pranks or funny business.
- `/rgl setlogfilter <filter|filter|filter|...>` - Set a Lua regex filter to match log lines against before printing (does not effect file logging).

## Class Specific (e.g. Necromancer/Mage/Ranger)
- `/rgl makeammo ##` - Make ## number of Class 3 Wood Silver Tip Arrows. Minimum of 5
- `/rgl startlich` - Start your Lich Spell [Note: This will enabled DoLich if it is not already].
- `/rgl stoplich` - Stop your Lich Spell [Note: This will NOT disable DoLich].

## Config Settings (`/rgl set`)

You can use `/rgl set <SettingName> <Value>` to modify these configuration options.

### Abilities
- `AETargetCnt` - Minimum number of valid targets before using AE Disciplines or AA. *(Default: 2)*
- `AETauntCnt` - Minimum number of haters before using AE Taunt Spells or AA when we have less than 100% aggro on one or more of them in range. *(Default: 2)*
- `ActorBuffScope` - Choose who to use group buffs on. Targets other than your group must be RGMercs Peers (refer to the Peers FAQ). *(Default: 2)*
- `ActorCureScope` - Choose whose detrimental effects to cure. Targets other than yourself must be RGMercs Peers (refer to the Peers FAQ). *(Default: 2)*
- `AggressivelyMemorizeSpells` - If you have a very latent connection, and spell memorization gets stuck, this will attempt to fix it by resending the memspell command every x seconds. *(Default: false)*
- `AggressivelyMemorizeTimer` - How many seconds to wait before resending memspell commands when Aggressively Memorize Spells is enabled. *(Default: 1)*
- `AggroThrottling` - (Non-Tank Modes): Don't use nukes and similar spells when your aggro percent is above the Aggro To Cast value below. *(Default: true)*
- `BigHealPoint` - Minimum PctHPs to use the Big Heal Rotation or actions that check whether BigHeals are needed. *(Default: 50)*
- `BreakInvisForHealing` - Break invis to heal, cure and rez when out of combat (Does not affect combat actions). *(Default: false)*
- `BreakInvisForSay` - Break Invis as part of /rgl say, qsay or rsay commands. *(Default: false)*
- `BuffAssistList` - Process group buff rotations on members of the Assist List. *(Default: true)*
- `BuffRezables` - Buff Rezables *(Default: Globals.ServerEnv:lower() ~= "live")*
- `BuffTargetingInterval` - Buff Targeting Interval *(Default: 30)*
- `BuffWaitMoveTimer` - Seconds to wait after stopping movement before doing buffs. *(Default: 3)*
- `CastReadyDelayFact` - Wait Ping * [n] ms before saying we are ready to cast. *(Default: 0)*
- `CastRetryCount` - The amount of times to try to recast a spell, song, AA, or item due to a fizzle, interrupt, or similar. Note that queued actions already have a retry built-in. *(Default: Globals.CurLoadedClass == "BRD" and 1 or 0)*
- `ConCorpseForRez` - If this setting is enabled, we will attempt to con a corpse and rez only if that corpse has not yet taken one. *(Default: Globals.ServerEnv:lower() ~= "live")*
- `CureInterval` - The delay in seconds between making cure checks during downtime (to prevent unnecessary queries). *(Default: 5)*
- `DebuffMinCon` - Min Con to use debuffs on when con-color debuffing is enabled for enemies. *(Default: 4)*
- `DoAEDamage` - "**WILL BREAK MEZ** Use AE damage Spells and AA. **WILL BREAK MEZ**\n" .. *(Default: false)*
- `DoActorPetBuffs` - Buff Pets as PCs *(Default: false)*
- `DoAlliance` - Enable the use of Alliance spells (for supporting class configs, not every class config uses this). *(Default: false)*
- `DoBattleRez` - Enable rezzing while in combat *(Default: true)*
- `DoBuffs` - Process Downtime and Group Buff Rotations (see your rotations on the class tab). *(Default: true)*
- `DoCures` - Clear curable detrimental effects from yourself and your peers. *(Default: true)*
- `DoPet` - Enable the summoning and buffing of pets. *(Default: true)*
- `DoPetHeals` - "Allow pets of your groupmates to be targeted in PC healing rotations.\n" .. *(Default: true)*
- `DoRez` - Use Rezes. If disabled, no rez spells will be used at any time. *(Default: true)*
- `DoShrinkPet` - Use a Shrink Clicky on your pet. *(Default: false)*
- `DowntimeDetDispel` - Downtime Det Dispel *(Default: 2)*
- `GroupHealPoint` - Minimum PctHPs to use the Group Heal Rotation or actions that check whether Group Heals are needed. *(Default: 80)*
- `GroupInjureCnt` - Number of group members that must be under the Group Heal Point percentage threshold. *(Default: 3)*
- `IgnoreLevelCheck` - Ignore checks for minimum level on spells. Used on servers that allow heals, buffs and other spells to land on PCs regardless of level. *(Default: Globals.ServerEnv:lower() ~= "live", -- more emu servers ignore level checks than not, and all the ones we support currently do. lesser of two evils.)*
- `LightHealPoint` - Minimum PctHPs to use the Light Heal Rotation or actions that check whether Light Heals are needed. *(Default: mq.TLO.Me.Class.ShortName() == "CLR" and 95 or 90)*
- `MainHealPoint` - Minimum PctHPs to use the Main Heal Rotation or actions that check whether Main Heals are needed. *(Default: 80)*
- `ManaToDebuff` - Minimum % Mana in order to continue to cast debuffs. *(Default: 10)*
- `ManaToDot` - Mana to Dot *(Default: 30)*
- `ManaToNuke` - Mana to Nuke *(Default: 30)*
- `MaxAETargetCnt` - Max AE Targets *(Default: 5)*
- `MaxHealPoint` - Minimum PctHPs of any valid target to process healing rotations. *(Default: 90)*
- `MobDebuff` - The circumstances in which we will debuff a (non-named) mob. *(Default: 2)*
- `MobLowHP` - A mob is considered to be low HP (for the sake of snares, dots and other abilities) under x HP%. *(Default: 50)*
- `MobMaxAggro` - (Non-Tank Modes) Maximum % Aggro for most offensive actions if Aggro Throttling is enabled. *(Default: 90)*
- `NamedDebuff` - The circumstances in which we will debuff a (named) mob. *(Default: 2)*
- `NamedLowHP` - A named mob is considered to be low HP (for the sake of snares, dots and other abilities) under x HP%. *(Default: 25)*
- `PetHealPoint` - Minimum PctHPs to process standard PC Healing Rotations on pets (if enabled). See 'Heal Pets as PCs' setting. *(Default: 50)*
- `RetryRezDelay` - Delay in seconds between rez attempts. *(Default: 6)*
- `RezInZonePC` - Rez corpses of live PCs in the zone (If disabled, we will only rez corpses of PCs not in our current zone).Note that we will not rez in-zone PCs during combat. *(Default: Globals.ServerEnv:lower() == "live")*
- `RezOutside` - Rez dannet peers, raid/guildmates, and anyone in the Assist List (and not simply your own group). *(Default: true)*
- `RezRolePriority` - Rez the selected roles (healers and/or tanks) before other corpses; distance breaks ties. None uses plain nearest-first order. *(Default: 4)*
- `SafeAEDamage` - Check to ensure there aren't neutral mobs in range we could aggro if AE damage is used. May result in non-use due to false positives. *(Default: false)*
- `SafeAETaunt` - Check to ensure there aren't neutral mobs in range we could aggro if AE taunts are used. May result in non-use due to false positives. *(Default: false)*
- `ShrinkPetItem` - Item to use to shrink your pet. *(Default: )*
- `SkipColdSpells` - "Don't use spells with a cold resist type (as long as they aren't flagged in the config to ignore this check).\n" .. *(Default: false)*
- `SkipDiseaseSpells` - "Don't use spells with a disease resist type (as long as they aren't flagged in the config to ignore this check).\n" .. *(Default: false)*
- `SkipFireSpells` - "Don't use spells with a fire resist type (as long as they aren't flagged in the config to ignore this check).\n" .. *(Default: false)*
- `SkipMagicSpells` - "Don't use spells with a magic resist type (as long as they aren't flagged in the config to ignore this check).\n" .. *(Default: false)*
- `SkipPoisonSpells` - "Don't use spells with a poison resist type (as long as they aren't flagged in the config to ignore this check).\n" .. *(Default: false)*
- `SongClipDelayFact` - Song Clip Delay Factor *(Default: 2)*
- `StaggerGroupAACures` - Stagger Group AA Cures *(Default: true)*
- `StandFailedFD` - Stand up if a failed feign is detected ('fall to the ground'). *(Default: true)*
- `UseCounterActions` - "Use Aureate's Bane", --this can be freely changed later if another system is added. Avoiding confusion for now. *(Default: Globals.ServerEnv:lower() == "live")*
- `UseHealList` - Heal members of the Heal List instead of using xtarget healing (see FAQs). *(Default: false)*
- `UseImmuneData` - "Use immunity data shipped with RGMercs (if available) to automatically determine whether to skip a spell.\n" .. *(Default: true)*

### Advanced / Other
- `AssistList` - List of User-Defined Assists *(Default: {})*
- `ClassConfigDir` - Class Config Dir *(Default: function())*
- `CureAllowList` - Cure Allow List *(Default: {})*
- `CureAllowListShared` - Shared Cure Allow List *(Default: {})*
- `CureDenyList` - Cure Deny List *(Default: {})*
- `CureDenyListShared` - Shared Cure Deny List *(Default: {})*
- `DoCureAA` - Do Cure AA *(Default: true)*
- `DoCureSpells` - Do Cure Spells *(Default: true)*
- `DrawTooltipDebugBox` - Draw a box around the tooltip to help identify its boundaries for debugging purposes. *(Default: false)*
- `EnableDebugging` - Enable the Debug Panel *(Default: false)*
- `EnableLogTracer` - Enables the debug tracer to show file/function/line information for each log entry *(Default: true)*
- `HealList` - List of User-Defined Heal Targets *(Default: {})*
- `LogFilter` - Log Filter *(Default: )*
- `LogLevel` - Log Level *(Default: 3)*
- `LogTimeStampsToConsole` - Log Timestamps To RGMercs Console *(Default: false)*
- `LogToFile` - Log To File *(Default: false)*
- `MainWindowLocked` - Main Window Locked *(Default: false)*
- `PeerToastLevel` - Show toasts generated by your RGMercs Peers (see the Peers FAQ). *(Default: 3)*
- `PopOutConsole` - Pop Out Console *(Default: false)*
- `PopOutForceTarget` - Pop Out Force Target *(Default: false)*
- `PopOutMercsStatus` - Pop Out Mercs Status *(Default: false)*
- `RunSelfTestsOnStartup` - Run a series of self-tests to check the functionality of various components of the script when it starts up. This may increase startup time. *(Default: false)*
- `ShowAdvancedOpts` - Show Advanced Options *(Default: false)*
- `ToastLevel` - Toast Level *(Default: 3)*
- `UseSharedCureLists` - Use Shared Cure Lists *(Default: false)*

### Combat
- `AggroScanRespectFT` - If the Tank Aggro Scan is enabled and the current Auto Target is forced, stay on that target without switching to an Aggro Target. *(Default: true)*
- `AllowMezBreak` - Allow combat actions if the target is mezzed. *(Default: (Globals.Constants.RGTank:contains(mq.TLO.Me.Class.ShortName())))*
- `AreaScanFallback` - Scan for targets via spawnsearch in the abscence of XTargets. Use with caution, can aggro mobs unintentionally. *(Default: false)*
- `AssistRange` - Engage the combat target when it is within this distance. *(Default: 100)*
- `AutoAssistAt` - Begin combat actions against the auto target when its reaches this health percentage. *(Default: 98)*
- `AutoAttackSafetyCheck` - Turn off auto-attack if we are not in combat and not cleared to engage the current target. *(Default: false)*
- `AutoStandFD` - Stand up if feigning at the start of combat. *(Default: true)*
- `BellyCastStick` - If Melee Combat is disabled, pin at 40 units on named with a dragon bodytype in case of possible bellycaster. *(Default: false)*
- `BurnAlways` - Automatically use Burn rotations on any/every target. *(Default: false)*
- `BurnAuto` - Use Burn rotations when the conditions below are met. *(Default: true)*
- `BurnMobCount` - Automatically use Burn rotations when we are fighting x number of haters. *(Default: 3)*
- `BurnNamed` - Automatically use Burn rotations when we are fighting a named mob(must be present in RGMerc Named List or detected with SpawnMaster or Alert Master). *(Default: true)*
- `CheckAMForNamed` - Treat your target as 'named' if present on your Alert Master list (uses the Alert Master TLO). *(Default: true)*
- `CheckSMForNamed` - Treat your target as 'named' if present on your MQ2SpawnMaster list (uses the SpawnMaster TLO). *(Default: true)*
- `ClearStuckXTargets` - Clear Stuck XTargets *(Default: (Globals.BuildType:lower() == "emu"))*
- `DoAutoEngage` - Automatically engage targets for combat actions. *(Default: true)*
- `DoAutoNav` - Enables RGMercs to issue Navigation Commands in Combat. Disable if you wish to manually control movement. *(Default: true)*
- `DoAutoStick` - Enables RGMercs to issue Stick Commands in Combat. Disable if you wish to manually control movement. *(Default: true)*
- `DoAutoTarget` - Auto Target *(Default: true)*
- `DoMelee` - Auto attack the combat target. (Ranger Only: Disable to use ranged combat.) *(Default: Globals.Constants.RGMelee:contains(Globals.CurLoadedClass))*
- `DoMercenary` - Allow RGMercs to issue mercenary commands. We plan to add selectable stances in a future update. *(Default: (Globals.BuildType:lower() ~= "emu"))*
- `DoPetCommands` - Allow RGMercs to issue pet commands. *(Default: true)*
- `FaceTarget` - Periodically /face your target while in combat. *(Default: true)*
- `FollowMarkTarget` - Prioritize the Marked target as the combat target. *(Default: false)*
- `HandleCantSeeTarget` - Attempt to adjust positioning if you receive a 'cannot see your target' message. *(Default: true)*
- `HandleTooClose` - Attempt to adjust positioning if you receive a 'too close to use a ranged weapon' message. *(Default: true)*
- `HandleTooFar` - Attempt to adjust positioning if you receive a 'too far away' or 'cant hit them from here' message. *(Default: true)*
- `KeepMobsInFront` - While tanking, reposition to keep haters in your front arc. *(Default: true)*
- `MAAggroScan` - MA Aggro Scan *(Default: false)*
- `MAScanZRange` - Allowable height difference between mobs and the MA when scanning for targets. *(Default: 45)*
- `ManualMode` - Manual Mode *(Default: false)*
- `MercStance` - Merc Stance *(Default: 2)*
- `MovebackWhenTank` - Adds 'moveback' to the default stick command when tanking. Helpful to keep mobs from getting behind you. *(Default: false)*
- `NamedMinHPPct` - The minimum HP% a named has to drop to before we'll burn it. *(Default: 100)*
- `NamedMinLevel` - The minimum level we will treat a Named as a threat (if below this level, we will treat them as trash mobs). *(Default: 1)*
- `PetEngagePct` - Send pets to attack the combat target when it reaches this health percentage. *(Default: 96)*
- `RaidAssistTarget` - Which Raid Assist target to follow. Please note that we will not fallback if this is not set properly. *(Default: 1)*
- `RepositionPet` - Use summon and move AA to reposition your pet to avoid ripostes. (We will always summon a far out-of-range pet during combat if able). *(Default: false)*
- `SafeTargeting` - Do not target mobs that are fighting others (except if those others pass safety checks, such as if they are DanNet peers.). *(Default: true)*
- `ScanHPPriority` - "Choose whether this PC will prioritize low or high HP% mobs if set as MA.\n" .. *(Default: 1)*
- `ScanNamedPriority` - Choose whether this PC will prioritize Named or Non-Named mobs if set as MA. *(Default: 1)*
- `SelfAssistFallback` - If no other valid MA is found, fallback to ourselves.\nPlease note that when solo (and not using the Assist List), we are always our own MA. *(Default: 4)*
- `StayOnTarget` - Once an autotarget is assigned, do not change that target.\n(Note: This will greatly interfere with MA Target Scan capability.) *(Default: false)*
- `StickHow` - Custom arguments for /stick command, used in melee or ranged combat. Leave blank for default (varies on class). *(Default: )*
- `StopAttackForPCs` - Ensure that auto attack is turned off before targeting a PC to use a spell, song, AA, or item. May be required if PvP is enabled by flag, zone, or server. *(Default: false)*
- `TankAggroScan` - Tank Aggro Scan *(Default: true)*
- `TargetNonAggressives` - Target Non-Aggressives *(Default: false)*
- `UseAssistList` - Use names from the Assist List to choose a Main Assist instead of assisting the EQ group or raid assist (see FAQs). *(Default: false)*

### General
- `123EyesOnMe` - Derple Dog Watches You While You Sleep *(Default: false)*
- `ActorPeerTimeout` - Time in seconds to wait before considering a peer disconnected. *(Default: 45)*
- `AlwaysShowMiniButton` - Always show the RGMercs Mini Mode button, even when the main window is displayed. *(Default: false)*
- `AnnounceTarget` - Announces the current combat target. Uses KissAssist format. *(Default: false)*
- `AnnounceTargetGroup` - Announces Target over /gsay. *(Default: false)*
- `AnnounceToRaidIfInRaid` - If in a raid, announcements will go to raid instead of group. *(Default: false)*
- `AssistSpawnFarColor` - Color used to display an assist spawn that is far from us. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.AssistSpawnFarColor))*
- `BgOpacity` - Opacity for the RGMercs UI *(Default: 100)*
- `BurnAnnounce` - Announce burn-related messages. *(Default: false)*
- `BurnAnnounceGroup` - Announce burn-related messages in /gsay. (Warning: Often spammy.) *(Default: false)*
- `BurnFlashColorOne` - First of two colors to use when flashing burn status message. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.BurnFlashColorOne))*
- `BurnFlashColorTwo` - Second of two colors to use when flashing burn status message. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.BurnFlashColorTwo))*
- `CharacterFlagAnnounce` - Announces when a character flag is received. *(Default: false)*
- `CharacterFlagAnnounceGroup` - Announces when a character flag is received. *(Default: false)*
- `CharmAnnounce` - Announces charm use. *(Default: false)*
- `CharmAnnounceGroup` - Announces charm use to /gsay. *(Default: false)*
- `CharmReasonColor` - Color used to display the reason we cannot charm a target. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.CharmReasonColor))*
- `ConditionDisabledColor` - Color used to display a disabled condition *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.ConditionDisabledColor))*
- `ConditionFailColor` - Color used to display a failing condition *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.ConditionFailColor))*
- `ConditionMidColor` - Color used to display an unevaluated condition *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.ConditionMidColor))*
- `ConditionPassColor` - Color used to display a passing condition *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.ConditionPassColor))*
- `CureAnnounce` - Announces cure use. *(Default: false)*
- `CureAnnounceGroup` - Announces cure use to /gsay. *(Default: false)*
- `DisableClassTheme` - Disable class themes and use the default ImGui style. *(Default: false)*
- `DisableToggleButtonPulse` - Disable the pulsing effect toggle buttons. *(Default: false)*
- `DisplayManualTarget` - If you have no auto target, enabling this will show information about your current manual target in the UI. *(Default: false)*
- `EnableAAOverlay` - Show an overlay on the AA window that tells you which AAs are used by RGMercs rotations. *(Default: true)*
- `EnableAFUI` - ??? *(Default: false)*
- `EnableAnimatedTooltips` - Enable animated tooltips (fade in/out). Disabling this will make tooltips appear/disappear instantly. *(Default: true)*
- `EnableOptionsUI` - Show the experimental Options UI window *(Default: false)*
- `EscapeMinimizes` - In always-show mini button mode, closes the main window with escape if enabled. *(Default: false)*
- `FAQCmdQuestionColor` - Color used to display commands in the FAQ section of the Help Window. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.FAQCmdQuestionColor))*
- `FAQDescColor` - Color used to display description text in the FAQ section of the Help Window. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.FAQDescColor))*
- `FAQLinkColor` - Color used to display link text in the FAQ section of the Help Window. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.FAQLinkColor))*
- `FAQUsageAnswerColor` - Color used to display usage and answer text in the FAQ section of the Help Window. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.FAQUsageAnswerColor))*
- `FTHPOverlay` - Show a HP bar overlay on your forced target (if enabled) *(Default: false)*
- `FTHPOverlayAlpha` - Opacity for the HP bar overlay on your forced target (if enabled) for non-targeted mobs *(Default: 30)*
- `FTHighlight` - Force Target Highlight border in the Force Target Window. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.FTHighlight))*
- `FTRollTargetName` - Roll colors for target names in the Force Target Window based on Con. *(Default: true)*
- `FTUseBars` - Use bars to display HP and other info in the Force Target Window instead of text. *(Default: false)*
- `FontScale` - Scale for all fonts used in the UI. *(Default: 0)*
- `ForceAFUIOff` - ??? *(Default: false)*
- `FrameEdgeRounding` - Frame Edge Rounding for the RGMercs UI *(Default: 6)*
- `FullUI` - Toggle between Full UI and a Simple UI [Experimental] *(Default: true)*
- `HPBarStyle` - The method for coloring the HP display of your manual target (if enabled). *(Default: 2)*
- `HPHighColor` - Color used to display high HP values. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.HPHighColor))*
- `HPLowColor` - Color used to display low HP values. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.HPLowColor))*
- `HealAnnounce` - Announces heal spell use. *(Default: false)*
- `HealAnnounceGroup` - Announces heal spell use to /gsay. *(Default: false)*
- `HeartbeatAnnounceGroup` - Announces received heartbeats in /gsay. (Warning: spammy.) *(Default: false)*
- `InstantRelease` - Instantly release to spawn point when you die. *(Default: false)*
- `LockTargetWindow` - Lock the position of the target window. *(Default: false)*
- `LootModuleType` - Choose which loot module to use. *(Default: 1)*
- `MainButtonPausedColor` - Color used for the main button when RGMercs is paused. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.MainButtonPausedColor))*
- `MainButtonUnpausedColor` - Color used for the main button when RGMercs is unpaused. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.MainButtonUnpausedColor))*
- `MainCombatColor` - Color used for the UI elements when in combat. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.MainCombatColor))*
- `MainDowntimeColor` - Color used for the main window border when out of combat. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.MainDowntimeColor))*
- `ManaHighColor` - Color used to display high Mana values. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.ManaHighColor))*
- `ManaLowColor` - Color used to display low Mana values. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.ManaLowColor))*
- `MezAnnounce` - Announces mez use. *(Default: false)*
- `MezAnnounceGroup` - Announces mez use to /gsay. *(Default: false)*
- `OverrideHP` - If you have no auto target, enabling this will show information about your current manual target in the UI. *(Default: 0)*
- `PopoutWindowsLockWithMain` - Popout windows will lock/unlock when the main window is locked/unlocked. *(Default: true)*
- `PullAnnounce` - Announce pull-related messages. *(Default: false)*
- `PullAnnounceGroup` - Announce pull-related messages in /gsay. (Warning: Often spammy.) *(Default: false)*
- `ReagentAnnounce` - Announces an aborted cast due to missing spell reagent. *(Default: false)*
- `ReagentAnnounceGroup` - Announces an aborted cast due to missing spell reagent to /gsay. (Warning: Often spammy.) *(Default: false)*
- `SavePositionPerCharacter` - Save window positions separately for each character. *(Default: false)*
- `ScrollBarRounding` - Frame Edge Rounding for the RGMercs UI *(Default: 10)*
- `SearchHighlightColor` - Color used to highlight search terms in various windows. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.SearchHighlightColor))*
- `ShowDebugTiming` - Enable displaying the timing of each rotation step. *(Default: false)*
- `ShowFTControls` - Show ForceTarget controls to clear/set forced targets. *(Default: true, -- defaulted to false just to annoy Algar -- returned to true by Algar only out of spite)*
- `ShowTargetBuffs` - Display buffs on the target. *(Default: true)*
- `ShowTargetOfTarget` - Display the target's current target. *(Default: true)*
- `ShowTargetSecondaryAggro` - Display the secondary aggro player and percentage. *(Default: true)*
- `ShowTargetWindow` - Display an RGMercs-style fancy target window with information about your current target. *(Default: false)*
- `StatusLeftClickAction` - Action to perform when left-clicking a name in the Mercs Status Window *(Default: 1)*
- `StatusLeftClickCursorClickAction` - Action to perform when left-clicking a name in the Mercs Status Window while having an item on your cursor. *(Default: 1)*
- `StatusRightClickAction` - Action to perform when right-clicking a name in the Mercs Status Window *(Default: 2)*
- `StatusUseBars` - Use bars to display HP and other info in the Mercs Status Window instead of text. *(Default: false)*
- `TargetBuffBlinkAtTime` - Seconds remaining on buff before we blink the icon. *(Default: 15)*
- `TargetBuffCasterTooltip` - Display tooltips with the casters of buffs on your target. *(Default: true)*
- `TargetBuffDescriptionTooltip` - Display tooltips with the descriptions of buffs on your target. *(Default: true)*
- `TargetBuffIconSize` - Size of the buff icons on the target window. *(Default: 24)*
- `TargetBuffNameTooltip` - Display tooltips with the names of buffs on your target. *(Default: true)*
- `TogglePulseColor` - Color used for the pulsing effect on toggle buttons (if enabled). *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.TogglePulseColor))*
- `TooltipTextColor` - Color used for text in tooltips. *(Default: Tables.ImVec4ToTable(Globals.Constants.DefaultColors.TooltipTextColor))*
- `UserTheme` - Override any ImGui style settings with a custom theme. *(Default: {})*
- `UserThemeOverrideClassTheme` - User the user theme even if a class theme is defined. *(Default: true)*
- `WarnCombatPaused` - If we gain aggro while paused, display a warning in the chat window. *(Default: true)*

### Items
- `DoMount` - Choose how/when to use mounts. A character with melee combat enabled will only use a mount if set to use as a buff. *(Default: 2)*
- `DoShrink` - Use Shrink items. *(Default: false)*
- `ModRodManaPct` - Use the first available Mod Rod when at or under this mana percentage, as long as it won't kill us. *(Default: 60)*
- `ModRodUse` - Use available Mod Rods or Azure Crystals when we have less that the Mod Rod Mana % setting. *(Default: 2)*
- `MountItem` - Mount Clicky item to use. *(Default: )*
- `ShrinkItem` - Item to use to Shrink yourself. *(Default: )*

### Movement
- `AfterCombatMedDelay` - How may seconds to delay after combat before sitting to meditate. *(Default: 3)*
- `DoMed` - Choose if/when to meditate.\nMay interfere with bard songs (refer to FAQ for 'Bard Meditation'). *(Default: Globals.CurLoadedClass == "BRD" and 1 or 2)*
- `EndMedPct` - Attempt to meditate when at or under this Endurance percentage. *(Default: 60)*
- `EndMedPctStop` - When meditating, allow meditation to end when at or over this Endurance percentage. *(Default: 90)*
- `HPMedPct` - Attempt to meditate when at or under this HP percentage. *(Default: 60)*
- `HPMedPctStop` - When meditating, allow meditation to end when at or over this HP percentage. *(Default: 90)*
- `ManaMedPct` - Attempt to meditate when at or under this Mana percentage. *(Default: 60)*
- `ManaMedPctStop` - When meditating, allow meditation to end when at or over this Mana percentage. *(Default: 90)*
- `MedAggroCheck` - Force a stand when we have aggro higher than the Med Aggro Percent setting from an xtarget. *(Default: true)*
- `MedAggroPct` - Aggro percent value for the Med Aggro Check. *(Default: 65)*
- `StandWhenDone` - Force a stand to end meditation when thresholds are reached. *(Default: Globals.CurLoadedClass == "BRD")*

