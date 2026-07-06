# Automating the AE Bootstrapper in RGMercs

RGMercs is incredibly powerful out of the box for standard groups (tank, heal, single-target DPS), but massive PBAoE farming requires some specific logic tweaks. If you just run 18 bots on default settings, they will try to cast single-target nukes and single-target crowd control, which will result in an immediate wipe against 60 mobs.

Here is exactly what needs to be configured in RGMercs and your EQBC macros to make this automated.

---

## 1. The Puller (Manual Driving vs. Automated)

**The Reality of Massive Pulls:** For 60+ mob trains, the puller (Shadowknight) is almost always **driven manually by you**. 
Pathing 17 bots through a dungeon is hard; pathing a puller to perfectly gather 60 mobs without getting stuck is nearly impossible for an AI.
*   **The Massive Train Setup:** You manually drive the SK out, gather the zone, and run back. The remaining 17 characters sit perfectly still in the camp, completely automated by RGMercs, waiting for the SK to return.

### Alternative: Fully Automated "Safe" Pulling
If you prefer to be 100% AFK and don't want to manually drive 60-mob trains, you can configure RGMercs to fully automate smaller, safer pulls (3-5 mobs at a time).
*   **How to configure:** In RGMercs, set the SK's role to `Puller`.
*   **PullRadius:** Set this to a modest range (e.g., `100` to `150`). 
*   **PullZRadius:** Set this to `50` (to prevent pulling mobs from floors above/below you).
*   **The Result:** The SK will rely on MQ2Nav to automatically run out, tag 1-3 mobs with *Disease Cloud*, and run them back to camp. The Wizards' AE threshold (`SpawnCount > 3`) might not trigger, but 17 characters single-target nuking 3 mobs will instantly vaporize them anyway. This is significantly slower XP than a 60-mob AE pull, but it is 100% automated and safe.

## 2. Wizards & Mages (Forcing PBAoE)

By default, RGMercs Wizards and Mages will prioritize their biggest single-target nukes. You must force them to use PBAoE spells.
*   **The Configuration:** In the RGMercs UI (or by editing `rgmercs/class_configs/wiz.lua`), you need to modify the spell rotation priority list.
*   **The Logic:** Add your highest level PBAoE spell (e.g., *Supernova*) to the absolute top of the DPS spell list.
*   **The Condition:** Set the condition for this spell to trigger only when **`SpawnCount > 3`**. 
*   **Result:** When the SK runs into camp with 1 mob, the Wizards cast normal nukes. When the SK runs into camp with 60 mobs, the Wizards instantly spam *Supernova* until everything is dead.

## 3. The Enchanters (The Stun Stagger)

This is the trickiest part. If you just tell 3 Enchanters to cast PBAoE stuns, they will all see the mobs arrive and cast their stuns at the exact same millisecond. The mobs will be stunned for 4 seconds, and then wake up and kill everyone while all 3 Enchanters are on cooldown. You must stagger them.

### Method A: The "Lazy" RGMercs Stagger
Instead of trying to script perfect delays, you assign a different, single PBAoE stun to each Enchanter in their RGMercs spell configuration.
*   **Enchanter 1:** Only allowed to cast *Color Skew*.
*   **Enchanter 2:** Only allowed to cast *Color Shift*.
*   **Enchanter 3:** Only allowed to cast *Color Flux*.
*   *Why this works:* Because the spells have slightly different cast times and refresh timers, after the initial cast, they will naturally desynchronize into a chaotic but effective stun-lock.

### Method B: The "Perfect" EQBC Macro (Recommended)
You bypass RGMercs for the stuns and use a simple EQBC macro triggered by your SK.
1. Turn off PBAoE stuns in RGMercs entirely.
2. Create a hotkey on your SK: `/bca //mac aechain`
3. On the Enchanters, you write a tiny 3-line macro:
   *   **Enchanter 1 Macro:** `/cast "Color Skew"`
   *   **Enchanter 2 Macro:** `/delay 3s` -> `/cast "Color Skew"`
   *   **Enchanter 3 Macro:** `/delay 6s` -> `/cast "Color Skew"`
*   *Result:* When the SK runs into camp, you hit the hotkey. The Enchanters perfectly stagger their stuns 3 seconds apart, guaranteeing a flawless lock.

## 4. The Cleric (The Clutch Complete Heal)

When you are pulling 60 mobs, the SK is taking massive damage hitting their back. When they stop moving in the camp, all 60 mobs will hit them at once before the first stun lands. 
*   **The Problem:** RGMercs heals are reactive. It will wait for the SK to drop to 40% HP, start casting Complete Heal (which takes 10 seconds), and the SK will die before it lands.
*   **The Solution:** You need a proactive heal. Create a hotkey on your SK that commands the Cleric via EQBC.
*   **The SK Hotkey:** `/bct ClericName //casting "Complete Heal" -targetId|${Me.ID}`
*   *Result:* When you are manually running the SK back to camp and you are about 8 seconds away, you hit the hotkey. The Cleric starts casting Complete Heal *before* you arrive. You stop in camp, the mobs surround you, and the Complete Heal lands instantly, healing you to full right as the stuns take over.

## 5. Bards & Support

*   **Bards:** RGMercs handles Bards flawlessly. Just set their role to twist your chosen melody (AC/Resist for Group 1, Mana/Resist for the casters). 
*   **4th Enchanter:** Set them to normal RGMercs debuff/CC mode. Ensure *Tashanian* is at the top of their debuff priority list so they blanket the train in magic debuffs.
*   **Necromancer:** RGMercs can be configured to use *Twitch* (Sedulous Subversion) on a specific target (usually the Cleric) if the target's mana drops below a certain threshold.
