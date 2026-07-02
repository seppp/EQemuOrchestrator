# Bot Class Stance & Spell Casting Reference Guide
This document provides a comprehensive reference on bot behavior, spell-casting probabilities, stance-based changes, and methods to adjust casting likelihoods.

## Table of Contents
1. [How Bot Spell Casting Chances Work](#1-how-bot-spell-casting-chances-work)
2. [Spell Type Index Mappings](#2-spell-type-index-mappings)
3. [Global Rules to Adjust Casting Likelihood](#3-global-rules-to-adjust-casting-likelihood)
4. [Stance-Based Casting Probability Tables by Class](#4-stance-based-casting-probability-tables-by-class)
5. [Command-Based Fine-Tuning](#5-command-based-fine-tuning)

## 1. How Bot Spell Casting Chances Work
In EQEmulator, bot spell casting logic is governed by the `bot_spell_casting_chances` database table. Instead of using a simple flat percentage, the AI evaluates the bot's current active combat roles using a boolean mask system. The columns are named based on whether the bot is **Positive (p)** or **Negative (n)** for the following four roles:
- **H**: Healer
- **S**: Slower
- **N**: Nuker
- **D**: Doter

For example:
- `nHSND_value` represents the probability of casting a spell type when the bot is **not** currently acting as Healer, Slower, Nuker, or Doter (essentially a base value).
- `pH_value` is used if the bot is currently acting as a Healer (and not Slower/Nuker/Doter).
- `pS_value` is used if the bot is currently acting as a Slower.
- `pHS_value` is used if the bot is acting as both a Healer and a Slower.
- `pHSND_value` is used if the bot is active in all four roles.

These values range from **0 to 100** (representing percentage chances). When the bot's AI ticks, it checks these percentages to determine if it should attempt to cast a spell from the corresponding spell type category.

## 2. Spell Type Index Mappings
Spells in a bot's spellbook are categorized by a `type` index within the `bot_spells_entries` database table. The standard mappings are:
| Index | Spell Type | Example Spells |
| :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | *Acikin, Agnarr's Thunder, Anarchy, Ancient: Burning Chaos, Ancient: Chaos Censure, Ancient: Chaos...* |
| **1** | Heal (Single Target) | *Aid of Khurenz, Ancient: Chlorobon, Ancient: Hallowed Light, Ancient: Wilslik's Mending, Celestia...* |
| **2** | Root | *Fetter, Greater Fetter, Immobilize, Instill, Paralyzing Earth, Root* |
| **3** | Buff | *Aanya's Quickening, Aegis of Ro, Affirmation, Agility, Agility of the Wrulan, Alacrity, Allure of...* |
| **4** | Aggro Redux (Concussion) | *Ancient: Greater Concussion, Boggle, Cinder Jolt, Concussion, Divine Aura, Divine Barrier, Harmsh...* |
| **5** | Pet Summoning / Animation | *Aanya's Animation, Aeldorb's Animation, Animate Dead, Boltran's Animation, Bone Walk, Cackling Bo...* |
| **6** | Lifetap | *Ancient: Touch of Orshilak, Deflux, Drain Soul, Drain Spirit, Gangrenous Touch of Zum`uul, Life L...* |
| **7** | Snare | *Atol's Spectral Shackles, Cascading Darkness, Clinging Darkness, Desecrating Darkness, Devouring ...* |
| **8** | DoT (Damage over Time) | *Affliction, Ancient: Curse of Mori, Ancient: Scourge of Nife, Asystole, Auspice, Bane of Nife, Bl...* |
| **9** | Dispel | *Annul Magic, Cancel Magic, Nullify Magic, Pillage Enchantment, Recant Magic, Strip Enchantment* |
| **10** | Group Heal / Specialty Heal | *Ancient: Ancestral Calling, Ancient: Chaotic Pain, Breath of Trushar, Cannibalize II, Cannibalize...* |
| **11** | Mez / Crowd Control | *Ancient: Eternal Rapture, Apathy, Bliss, Dazzle, Echoing Madness, Enthrall, Entrance, Euphoria, F...* |
| **13** | Slow | *Angstlich's Assonance, Largo's Assonant Binding, Requiem of Time, Selo's Consonant Chain* |
| **14** | In-Combat Buff / Shield | *Abduction of Strength, Adrenaline Swell Rk. II, Adrenaline Swell Rk. III, Aura of Darkness, Bark ...* |
| **15** | Cure (Poison/Disease/Curse) | *Abolish Corruption, Abolish Corruption Rk. II, Abolish Corruption Rk. III, Abolish Disease, Aboli...* |
| **17** | Bard Song (Special/Utility) | *Fermata of Preservation Rk. III, Song of Dawn* |
| **18** | Bard Song (Offensive/Stat) | *Amplification, Anthem de Arms, Aria of the Artist Rk. III, Aria of the Composer Rk. III, Aria of ...* |
| **19** | Bard Song (Heal/Regen) | *Amplification, Cantata of Life, Cantata of Replenishment, Cantata of Restoration Rk. III, Cantata...* |
| **22** | Fear | *Fear, Invoke Fear, Shadow Bellow, Shadow Howl, Shadow Voice, Trepidation, Unholy Bellow, Unholy H...* |
| **24** | Hate / Taunt Spells | *Abhorrence, Abhorrence Rk. II, Abhorrence Rk. III, Burst of Spite, Burst of Spite Rk. II, Burst o...* |
| **100** | Teleport / Portals | *Alra Portal, Alter Plane: Hate, Alter Plane: Hate II, Alter Plane: Sky, Arcstone Portal, Barindu ...* |
| **101** | Appease / Lull | *Appease, Appease Rk. II, Appease Rk. III, Assuage, Assuage Rk. II, Assuage Rk. III, Bucolic Mind,...* |
| **102** | Evacuate / Succor | *Decession, Evacuate, Greater Decession, Lesser Evacuate, Lesser Succor, Succor* |
| **103** | Bind Affinity | *Bind Affinity* |
| **104** | Identify | *Identify, Lyssa's Cataloging Libretto* |
| **105** | Levitation | *Agilmente's Aria of Eagles, Dead Man Floating, Dead Men Floating, Flight of Eagles, Levitate, Lev...* |
| **106** | Special / Other Utility | *Aviak's Wondrous Warble, Aviak's Wondrous Warble Rk. II, Aviak's Wondrous Warble Rk. III, Bedlam,...* |
| **107** | Water Breathing | *Dead Man Floating, Dead Men Floating, Enduring Breath, Everlasting Breath, Leviathan Eyes, Tarew'...* |
| **108** | Grow / Shrink | *Grow, Shrink* |
| **109** | Invisibility | *Acumen, Acumen of Dar Khura, Camouflage, Cloak of Nature, Dead Man Floating, Dead Men Floating, D...* |
| **110** | Movement Speed / SoW | *Feral Pack, Flight of Eagles, Pack Shrew, Pack Spirit, Scale of Wolf, Selo's Accelerando, Selo's ...* |
| **111** | Translocate | *Translocate, Translocate: Group* |
| **112** | Corpse Summoning | *Conjure Corpse, Exhumer's Call, Lesser Summon Corpse, Procure Corpse, Reaper's Beckon, Reaper's C...* |
| **200** | Combat Discipline (Offensive) | *Aggressive Discipline, Agitating Scream, Agitating Scream Rk. II, Agitating Scream Rk. III, Aimsh...* |
| **201** | Combat Discipline (Defensive) | *Aggressive Discipline, Agitating Scream, Agitating Scream Rk. II, Agitating Scream Rk. III, Aimsh...* |
| **202** | Combat Discipline (Buff/Utility) | *Armor of Decorum, Armor of Decorum Rk. II, Armor of Decorum Rk. III, Armor of Endless Honor, Armo...* |

## 3. Global Rules to Adjust Casting Likelihood
You can adjust the global base chances for bots to cast specific spell types by modifying rules in the `rule_values` table. These values represent global percentages applied to the bot casting AI checks:
| Rule Name | Current Value | Description |
| :--- | :--- | :--- |
| **Bots:PercentChanceToCastAEMez** | 40% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastAEs** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastBuff** | 90% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastCure** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastDebuff** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastDispel** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastDOT** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastEscape** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastFear** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastGroupCure** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastGroupHeal** | 90% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastHateLine** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastHateRedux** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastHeal** | 90% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastInCombatBuff** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastLifetap** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastMez** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastNuke** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastOtherType** | 90% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastRoot** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastSlow** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |
| **Bots:PercentChanceToCastSnare** | 75% | Global percent chance for a bot to attempt casting this spell category during combat. |

## 4. Stance-Based Casting Probability Tables by Class
Below are the detailed stance-based probability tables for each spell-casting bot class, compiled directly from the live `bot_spell_casting_chances` database.

### Class Capability Matrix
The table below shows which bot classes are capable of acting in each combat role (**Healer (H)**, **Slower (S)**, **Nuker (N)**, and **Doter (D)**) based on the spells available to them in their spellbook. Non-spell-casting classes (Warrior, Monk, Rogue, Berserker) are excluded.
| Class | Healer (H) | Slower (S) | Nuker (N) | Doter (D) |
| :--- | :---: | :---: | :---: | :---: |
| **Cleric** | Yes | No | Yes | No |
| **Paladin** | Yes | No | Yes | No |
| **Ranger** | Yes | No | Yes | Yes |
| **Shadowknight** | Yes | No | Yes | Yes |
| **Druid** | Yes | No | Yes | Yes |
| **Bard** | Yes | Yes | Yes | Yes |
| **Shaman** | Yes | Yes | Yes | Yes |
| **Necromancer** | Yes | No | Yes | Yes |
| **Wizard** | No | No | Yes | No |
| **Magician** | Yes | No | Yes | No |
| **Enchanter** | No | Yes | Yes | Yes |
| **Beastlord** | Yes | Yes | Yes | Yes |

### Cleric (Class ID: 2)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 0% | 15% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 15% | 50% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 25% | 50% | 25% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

### Paladin (Class ID: 3)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 0% | 15% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 75% | 15% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 15% | 50% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 75% | 15% | 75% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 25% | 50% | 25% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 0% | 50% | 0% | 50% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |

### Ranger (Class ID: 4)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 10% | 10% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 5% | 5% | 5% | 5% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 75% | 15% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 10% | 10% | 0% | 0% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 10% | 10% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 75% | 15% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 0% | 50% | 0% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |

### Shadowknight (Class ID: 5)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 10% | 10% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 5% | 5% | 5% | 5% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 10% | 10% | 0% | 0% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 10% | 10% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |

### Druid (Class ID: 6)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 15% | 50% | 15% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 0% | 15% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 100% | 15% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 25% | 10% | 25% | 10% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 15% | 50% | 15% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 15% | 50% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 75% | 25% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 25% | 50% | 25% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 25% | 50% | 25% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 10% | 50% | 10% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 25% | 50% | 25% | 0% | 0% | 0% | 0% |

### Bard (Class ID: 8)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **13** | Slow | 25% | 25% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **15** | Cure (Poison/Disease/Curse) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **18** | Bard Song (Offensive/Stat) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **19** | Bard Song (Heal/Regen) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **20** | Special Type 20 | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **21** | Special Type 21 | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 25% | 25% | 15% | 15% | 0% | 0% | 0% | 0% |
| **13** | Slow | 15% | 15% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **15** | Cure (Poison/Disease/Curse) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **18** | Bard Song (Offensive/Stat) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **19** | Bard Song (Heal/Regen) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **20** | Special Type 20 | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **21** | Special Type 21 | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **13** | Slow | 25% | 25% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **15** | Cure (Poison/Disease/Curse) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **18** | Bard Song (Offensive/Stat) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **19** | Bard Song (Heal/Regen) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **20** | Special Type 20 | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **21** | Special Type 21 | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 100% | 100% | 50% | 50% | 0% | 0% | 0% | 0% |
| **13** | Slow | 0% | 0% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **15** | Cure (Poison/Disease/Curse) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **18** | Bard Song (Offensive/Stat) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **19** | Bard Song (Heal/Regen) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **20** | Special Type 20 | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **21** | Special Type 21 | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 100% | 100% | 50% | 50% | 0% | 0% | 0% | 0% |
| **13** | Slow | 0% | 0% | 50% | 50% | 0% | 0% | 0% | 0% |
| **15** | Cure (Poison/Disease/Curse) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **18** | Bard Song (Offensive/Stat) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **19** | Bard Song (Heal/Regen) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **20** | Special Type 20 | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **21** | Special Type 21 | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |

### Shaman (Class ID: 10)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 10% | 5% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 25% | 15% | 15% | 0% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 50% | 75% | 50% | 75% | 0% | 0% | 0% | 0% |
| **13** | Slow | 50% | 50% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 10% | 5% | 0% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 100% | 15% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 10% | 10% | 0% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 25% | 50% | 25% | 50% | 0% | 0% | 0% | 0% |
| **13** | Slow | 25% | 25% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 10% | 5% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 25% | 15% | 15% | 0% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 50% | 75% | 50% | 75% | 0% | 0% | 0% | 0% |
| **13** | Slow | 50% | 50% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 15% | 5% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 75% | 25% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 25% | 50% | 15% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 75% | 100% | 75% | 100% | 0% | 0% | 0% | 0% |
| **13** | Slow | 15% | 15% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 25% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 10% | 50% | 10% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 25% | 50% | 15% | 0% | 0% | 0% | 0% |
| **10** | Group Heal / Specialty Heal | 75% | 100% | 75% | 100% | 0% | 0% | 0% | 0% |
| **13** | Slow | 15% | 15% | 50% | 50% | 0% | 0% | 0% | 0% |

### Necromancer (Class ID: 11)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 5% | 5% | 5% | 5% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **6** | Lifetap | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |

### Wizard (Class ID: 12)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

### Magician (Class ID: 13)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 75% | 75% | 75% | 75% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

### Enchanter (Class ID: 14)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 25% | 15% | 15% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 15% | 15% | 0% | 0% | 0% | 0% |
| **13** | Slow | 50% | 50% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 15% | 0% | 0% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 25% | 25% | 10% | 10% | 0% | 0% | 0% | 0% |
| **13** | Slow | 25% | 25% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 25% | 15% | 15% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 15% | 15% | 0% | 0% | 0% | 0% |
| **13** | Slow | 50% | 50% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 15% | 15% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 25% | 25% | 0% | 0% | 0% | 0% |
| **13** | Slow | 15% | 15% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **4** | Aggro Redux (Concussion) | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 25% | 25% | 0% | 0% | 0% | 0% |
| **13** | Slow | 15% | 15% | 50% | 50% | 0% | 0% | 0% | 0% |

### Beastlord (Class ID: 15)

#### Stance: Balanced (Stance ID: 1)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 10% | 5% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 10% | 10% | 0% | 0% | 0% | 0% |
| **13** | Slow | 25% | 25% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Efficient (Stance ID: 2)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 10% | 5% | 0% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 75% | 15% | 75% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 10% | 10% | 0% | 0% | 0% | 0% | 0% | 0% |
| **13** | Slow | 15% | 15% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |

#### Stance: Reactive (Stance ID: 3)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 15% | 10% | 5% | 0% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 25% | 100% | 25% | 100% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 100% | 100% | 100% | 100% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 15% | 15% | 10% | 10% | 0% | 0% | 0% | 0% |
| **13** | Slow | 25% | 25% | 100% | 100% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 15% | 15% | 15% | 15% | 0% | 0% | 0% | 0% |

#### Stance: Aggressive (Stance ID: 4)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 25% | 15% | 15% | 5% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 15% | 75% | 15% | 75% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 50% | 50% | 50% | 50% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **13** | Slow | 0% | 0% | 50% | 50% | 0% | 0% | 0% | 0% |
| **14** | In-Combat Buff / Shield | 10% | 10% | 10% | 10% | 0% | 0% | 0% | 0% |

#### Stance: BurnAE (Stance ID: 6)
| Spell Type Index | Spell Type Description | nHSND | pH | pS | pHS | pN | pD | pND | pHSND |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **0** | Nuke (Direct Damage) | 50% | 25% | 25% | 15% | 0% | 0% | 0% | 0% |
| **1** | Heal (Single Target) | 0% | 50% | 0% | 50% | 0% | 0% | 0% | 0% |
| **5** | Pet Summoning / Animation | 25% | 25% | 25% | 25% | 0% | 0% | 0% | 0% |
| **8** | DoT (Damage over Time) | 50% | 50% | 25% | 25% | 0% | 0% | 0% | 0% |
| **13** | Slow | 0% | 0% | 50% | 50% | 0% | 0% | 0% | 0% |

## 5. Command-Based Fine-Tuning
In addition to database rules and stances, players can command bots to behave in specific ways or override their defaults using in-game commands:
1. **Hold casting (`^spellholds`)**:
   - Command: `^spellholds [botname] [spelltype] [true|false]`
   - Action: Prevents the bot from ever casting spells of the specified type index.
2. **Adjust casting delays (`^spelldelays`)**:
   - Command: `^spelldelays [botname] [spelltype] [delay_in_ms]`
   - Action: Imposes a cool-down delay between casts of this spell type.
3. **HP / Mana thresholds (`^spellminhppct`, `^spellminmanapct`)**:
   - Command: `^spellminhppct [botname] [spelltype] [percentage]`
   - Action: Dictates the minimum HP or Mana the target or bot must have before casting this spell type.
4. **Spell Settings Enforcement (`^enforcespellsettings`)**:
   - Command: `^enforcespellsettings [botname] [true|false]`
   - Action: Forces the bot to ONLY cast spells that have been manually added/enabled in their spell settings, ignoring the auto-selected spell list.