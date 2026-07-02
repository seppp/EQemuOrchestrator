return {
	['version'] = '2.1.4-Shattering of Ro-Combat,Targeting,Core,Casting,Movement,Comms,Config,ItemManager,Math,Rotation,Strings,Tables,Ui',
	['signatures'] = {
		['Casting.UseSpell'] = {
			['ret'] = 'boolean|nil',
			['desc'] = 'Casts a spell on a target. Bards are routed to UseSong.',
			['params'] = {
				[1] = {
					['name'] = 'spellName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'targetId?',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'bAllowMem',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'bAllowDead',
					['type'] = 'boolean?',
				},
				[5] = {
					['name'] = 'retryCount',
					['type'] = 'number?',
				},
			},
		},
		['Core.GetRaidMainAssistName'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the clean name of the Nth raid main assist (1-indexed).',
			['params'] = {
				[1] = {
					['name'] = 'assistNumber',
					['type'] = 'number',
				},
			},
		},
		['Combat.FindWorstHurtManaXT'] = {
			['ret'] = 'number',
			['desc'] = 'Finds the entity with the worst hurt mana exceeding a minimum threshold.',
			['params'] = {
				[1] = {
					['name'] = 'minMana',
					['type'] = 'number',
				},
			},
		},
		['Casting.GetBuffableInZoneIDs'] = {
			['ret'] = 'table',
			['desc'] = 'Builds a deduplicated buff-eligible ID list from all in-zone sources: player, group members, actor peers and their pets (DoActorPetBuffs), and assist list. Aborts on nearby corpse.',
			['params'] = {},
		},
		['Comms.PopUp'] = {
			['desc'] = 'Shows a /popupecho message with default color 15 for 5 seconds.',
			['params'] = {
				[1] = {
					['name'] = 'msg',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Ui.GetPercentageColor'] = {
			['ret'] = 'ImVec4',
			['desc'] = 'Interpolates across a color scale based on pct (100 = scale[1], 0 = scale[n]).',
			['params'] = {
				[1] = {
					['name'] = 'pct',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'scale',
					['type'] = 'ImVec4[]',
				},
			},
		},
		['Core.HaveExpansion'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the character owns the named expansion.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Casting.GetLastUsedSpell'] = {
			['ret'] = 'string',
			['desc'] = 'Retrieves the last used spell.',
			['params'] = {},
		},
		['Casting.LevelCheckPass'] = {
			['ret'] = 'boolean',
			['desc'] = 'Applies EQ\'s buff level restriction table (Fanra\'s wiki) to determine whether a spell of spellLevel can land on targetLevel.',
			['params'] = {
				[1] = {
					['name'] = 'targetLevel',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'spellLevel',
					['type'] = 'number',
				},
			},
		},
		['Comms.PopUpColor'] = {
			['desc'] = 'Shows a /popupecho message with configurable color and duration.',
			['params'] = {
				[1] = {
					['name'] = 'color',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'time',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'msg',
					['type'] = 'string',
				},
				[4] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Core.AAUsedInRotation'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if aaName appears in the class module\'s rotation AA set.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Comms.SendMessage'] = {
			['desc'] = 'Sends a directed actor message to a single peer by looking up their server and character name from PeersToServerNameMap.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'module',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'event',
					['type'] = 'string',
				},
				[4] = {
					['name'] = 'data',
					['type'] = 'table?',
				},
			},
		},
		['Core.MyClassIs'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the player\'s class short name matches class (case-insensitive).',
			['params'] = {
				[1] = {
					['name'] = 'class',
					['type'] = 'string',
				},
			},
		},
		['Core.GetLastCombatModeChangeTime'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the timestamp of the last combat mode change from the class module.',
			['params'] = {},
		},
		['Casting.CanUseAA'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the player owns the AA (not nil), meets the minimum level requirement (or is on the Might server), and has at least rank 1 purchased. All three gates must pass.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Core.IAmMA'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if this character\'s ID matches the configured main assist.',
			['params'] = {},
		},
		['Ui.SearchableCombo'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders a combo box with an inline search/filter input.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'curIdx',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'options',
					['type'] = 'string[]',
				},
				[4] = {
					['name'] = 'hideText',
					['type'] = 'string?',
				},
			},
		},
		['Comms.SendPeerDoCmd'] = {
			['desc'] = 'Sends a /cmd to a single peer via SendMessage. If the peer is self, executes the command locally instead.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'cmd',
					['type'] = 'string',
				},
				[3] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Combat.FindWorstHurtHealList'] = {
			['ret'] = 'number',
			['desc'] = 'Finds the entity with the worst health condition that meets the minimum HP requirement.',
			['params'] = {
				[1] = {
					['name'] = 'minHPs',
					['type'] = 'number',
				},
			},
		},
		['Casting.AARank'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the purchased rank of an AA (via Me.AltAbility.Rank) if CanUseAA passes all ownership/level/rank checks, or 0 if the AA is unavailable or not yet purchased.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Core.IsTanking'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is in tank mode.',
			['params'] = {},
		},
		['Ui.GetDeltaTime'] = {
			['ret'] = 'number',
			['desc'] = 'Returns a clamped per-frame delta time from ImGui (0.001–0.1 seconds).',
			['params'] = {},
		},
		['Combat.CombatNavActive'] = {
			['ret'] = 'boolean',
			['params'] = {},
		},
		['Core.IsHealing'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is in heal mode.',
			['params'] = {},
		},
		['Core.ValidCombatTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if targetId refers to a targetable, living spawn.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Comms.SendAllPeersDoCmd'] = {
			['desc'] = 'Broadcasts a /cmd to all known peers. Optionally restricted to peers in the current zone, and optionally including self.',
			['params'] = {
				[1] = {
					['name'] = 'inZoneOnly',
					['type'] = 'boolean',
				},
				[2] = {
					['name'] = 'includeSelf',
					['type'] = 'boolean',
				},
				[3] = {
					['name'] = 'cmd',
					['type'] = 'string',
				},
				[4] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Config.HandleTempSet'] = {
			['ret'] = 'boolean',
			['params'] = {
				[1] = {
					['name'] = 'config',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'value',
					['type'] = 'any',
				},
			},
		},
		['Core.IsCuring'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is in cure mode.',
			['params'] = {},
		},
		['Combat.FindWorstHurtManaHealList'] = {
			['ret'] = 'number',
			['desc'] = 'Finds the entity with the worst mana condition that meets the minimum Mana requirement.',
			['params'] = {
				[1] = {
					['name'] = 'minMana',
					['type'] = 'number',
				},
			},
		},
		['Combat.OkToEngagePreValidateId'] = {
			['ret'] = 'boolean',
			['desc'] = 'Validates if it is acceptable to engage with a target based on its ID. This function performs pre-validation checks to determine if engagement is permissible.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Movement.DoStick'] = {
			['desc'] = 'Sticks the player to targetId using config-driven stick settings, rate-limited to once per second to avoid spamming.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Comms.FormatChatEvent'] = {
			['ret'] = 'string',
			['desc'] = 'Formats a structured chat event string used by HandleAnnounce and similar callers to produce consistent log/announce messages.',
			['params'] = {
				[1] = {
					['name'] = 'event',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'string|nil',
				},
				[3] = {
					['name'] = 'source',
					['type'] = 'string|nil',
				},
			},
		},
		['Casting.RunCastLoop'] = {
			['desc'] = '  - cmd        (string)   The EQ command that triggers the action.   - readyCheck (function) () -> boolean: true while the action is still ready to fire.   - actionName (string)   Human-readable action name used in log lines.   - targetId   (number?)  The spawn ID of the target   - bAllowDead (boolean?) allow this action to continue if the target is found to be dead.   - spellRange (number?)  Effective spell range.   - castTime   (number?)  Reported cast time in ms (0 for instants).   - retryCount (number?)  Additional attempts allowed on retriable failures.',
			['params'] = {
				[1] = {
					['name'] = 'opts',
					['type'] = 'table',
				},
			},
		},
		['Core.IsMezzing'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is in mez mode.',
			['params'] = {},
		},
		['Casting.IsActiveDisc'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the spell is a self-targeted skill with a positive duration that does not stack with other discs — indicating it occupies the active disc window rather than the buff window.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Ui.GetConHighlightBySpawn'] = {
			['ret'] = 'number,',
			['desc'] = 'Returns the row-highlight RGBA components for spawn based on its con color.',
			['params'] = {
				[1] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Config.ShouldMount'] = {
			['ret'] = 'boolean',
			['desc'] = 'Determines if the character should mount.',
			['params'] = {},
		},
		['Targeting.AddXTByName'] = {
			['desc'] = 'Sets XTarget slot to the spawn named name if the slot doesn\'t already hold it.',
			['params'] = {
				[1] = {
					['name'] = 'slot',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Core.IsCharming'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is in charm mode.',
			['params'] = {},
		},
		['Ui.OpenModal'] = {
			['desc'] = 'Opens the modal text-input popup and registers a callback for the result.',
			['params'] = {
				[1] = {
					['name'] = 'title',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'prompt',
					['type'] = 'string?',
				},
				[3] = {
					['name'] = 'initText',
					['type'] = 'string?',
				},
				[4] = {
					['name'] = 'callbackFn',
					['type'] = 'function?',
				},
			},
		},
		['Comms.SendHeartbeat'] = {
			['desc'] = 'Broadcasts the player\'s full state (HP, mana, target, buffs, position, etc.) to all peers at most once per second, then updates own entry in PeersHeartbeats. forceSend bypasses the throttle.',
			['params'] = {
				[1] = {
					['name'] = 'forceSend',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Casting.GetBestAA'] = {
			['ret'] = 'string',
			['desc'] = 'Deprecated alias for GetFirstAA. Iterates the list and returns the first AA name that passes CanUseAA.',
			['params'] = {
				[1] = {
					['name'] = 'aaList',
					['type'] = 'table',
				},
			},
		},
		['Core.CanMez'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is capable of mezzing.',
			['params'] = {},
		},
		['Targeting.AddXTByID'] = {
			['desc'] = 'Sets XTarget slot to the spawn with the given ID if not already set.',
			['params'] = {
				[1] = {
					['name'] = 'slot',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'id',
					['type'] = 'number',
				},
			},
		},
		['Rotation.SetSpellLoadOutByGem'] = {
			['ret'] = 'table',
			['desc'] = 'Assigns spells to specific gem slots per spellGemList, respecting each gem\'s cond and supporting CollapseGems to pack spells into sequential slots.',
			['params'] = {
				[1] = {
					['name'] = 'caller',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'spellGemList',
					['type'] = 'table',
				},
			},
		},
		['Core.CanCharm'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the class module reports the character is capable of charming.',
			['params'] = {},
		},
		['Casting.GetFirstAA'] = {
			['ret'] = 'string',
			['desc'] = 'Retrieves the first available purchased AA in a list.',
			['params'] = {
				[1] = {
					['name'] = 'aaList',
					['type'] = 'table',
				},
			},
		},
		['Combat.AETauntCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if AE taunt conditions are met (enough haters in range, optionally safe to taunt).',
			['params'] = {
				[1] = {
					['name'] = 'printDebug',
					['type'] = 'boolean',
				},
			},
		},
		['Movement.DoStickCmd'] = {
			['desc'] = 'Issues a /stick command with formatted params if DoAutoStick is enabled.',
			['params'] = {
				[1] = {
					['name'] = 'params',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Casting.GetBuffableGroupIDs'] = {
			['ret'] = 'table',
			['desc'] = 'Builds a deduplicated buff-eligible ID list from group sources: player, group members and their actor-peer pets (DoActorPetBuffs), own pet, and non-group assist list. Aborts on nearby corpse.',
			['params'] = {},
		},
		['Targeting.ResetXTSlot'] = {
			['desc'] = 'Clears XTarget slot by setting it to Empty Target then back to autohater.',
			['params'] = {
				[1] = {
					['name'] = 'slot',
					['type'] = 'number',
				},
			},
		},
		['Core.ShieldEquipped'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if a shield is equipped in the offhand slot.',
			['params'] = {},
		},
		['Casting.UseSong'] = {
			['ret'] = 'boolean',
			['desc'] = 'Plays a bard song on a target.',
			['params'] = {
				[1] = {
					['name'] = 'songName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'targetId?',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'bAllowMem',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'retryCount',
					['type'] = 'number?',
				},
			},
		},
		['Config.ShouldPriorityFollow'] = {
			['ret'] = 'boolean',
			['desc'] = 'Determines if the priority follow condition is met.',
			['params'] = {},
		},
		['Combat.OkToEngage'] = {
			['ret'] = 'boolean',
			['desc'] = 'Determines if it is acceptable to engage a target.',
			['params'] = {
				[1] = {
					['name'] = 'autoTargetId',
					['type'] = 'number',
				},
			},
		},
		['Casting.DiscOnCoolDown'] = {
			['ret'] = 'boolean',
			['desc'] = 'Resolves the action map entry to a disc via GetResolvedActionMapItem and returns true if it is unavailable or CombatAbilityReady is false.',
			['params'] = {
				[1] = {
					['name'] = 'actionMapName',
					['type'] = 'string',
				},
			},
		},
		['Casting.GetFirstMapItem'] = {
			['ret'] = 'string',
			['desc'] = 'Retrieves the first available resolved map item in a list.',
			['params'] = {
				[1] = {
					['name'] = 'mapList',
					['type'] = 'table',
				},
			},
		},
		['Core.OkayToNotHeal'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the character can safely skip healing for this frame — i.e., not in heal mode, no queued cure, and no injured group members.',
			['params'] = {},
		},
		['Movement.DoNav'] = {
			['desc'] = 'Issues a /nav command, skipping duplicates that are already active.',
			['params'] = {
				[1] = {
					['name'] = 'squelch',
					['type'] = 'boolean',
				},
				[2] = {
					['name'] = 'params',
					['type'] = 'string',
				},
				[3] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Ui.Tooltip'] = {
			['desc'] = 'Shows a tooltip when the previous item is hovered; supports animated mode.',
			['params'] = {
				[1] = {
					['name'] = 'desc',
					['type'] = 'string|function',
				},
				[2] = {
					['name'] = 'idoverride',
					['type'] = 'string?',
				},
			},
		},
		['Casting.ItemHasClicky'] = {
			['ret'] = 'boolean',
			['desc'] = 'Exact-name FindItem lookup; returns true if the item exists and has a Clicky effect.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
			},
		},
		['Casting.UseAA'] = {
			['ret'] = 'boolean|nil',
			['desc'] = 'Activates an AA ability on a target.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'targetId?',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'bAllowDead',
					['type'] = 'boolean?',
				},
				[4] = {
					['name'] = 'retryCount',
					['type'] = 'number?',
				},
			},
		},
		['Casting.IAmFeigning'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks if the character is currently feigning death.',
			['params'] = {},
		},
		['Math.GetDistance'] = {
			['ret'] = 'number',
			['desc'] = 'Calculates the distance between two points (x1, y1) and (x2, y2).',
			['params'] = {
				[1] = {
					['name'] = 'x1',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'y1',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'x2',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'y2',
					['type'] = 'number',
				},
			},
		},
		['Rotation.LoadSpellLoadOut'] = {
			['desc'] = 'Memorizes each spell in spellLoadOut into its assigned gem slot if the slot doesn\'t already hold the correct spell.',
			['params'] = {
				[1] = {
					['name'] = 'spellLoadOut',
					['type'] = 'table',
				},
			},
		},
		['Tables.AreTablesEqual'] = {
			['ret'] = 'boolean',
			['desc'] = 'Deep equality check for two tables, handling cycles.',
			['params'] = {
				[1] = {
					['name'] = 't1',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 't2',
					['type'] = 'any',
				},
			},
		},
		['Core.OkayToNotMez'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the character can safely skip mezzing this frame for a rotation restricted at the given Mez Priority level. True when not in mez mode, Mez Priority is below that level, or no mob still needs locking.',
			['params'] = {
				[1] = {
					['name'] = 'restrictAtLevel',
					['type'] = 'number?',
				},
			},
		},
		['Movement.GetLastNavCmd'] = {
			['ret'] = 'string,',
			['desc'] = 'Returns the last /nav command string that was issued.',
			['params'] = {},
		},
		['Casting.GetClickySpell'] = {
			['ret'] = 'MQSpell|nil',
			['desc'] = 'Exact-name FindItem lookup; returns the MQSpell of the item\'s Clicky effect, or nil if not found or no clicky is present.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
			},
		},
		['Math.GetDistanceSquared'] = {
			['ret'] = 'number',
			['desc'] = 'Calculates the squared distance between two points (x1, y1) and (x2, y2). This is useful for distance comparisons without the computational cost of a square root.',
			['params'] = {
				[1] = {
					['name'] = 'x1',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'y1',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'x2',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'y2',
					['type'] = 'number',
				},
			},
		},
		['Movement.GetLastStickCmd'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the last /stick command string that was issued.',
			['params'] = {},
		},
		['Core.GetResolvedActionMapItem'] = {
			['ret'] = 'any',
			['desc'] = 'Returns the resolved (ranked) spell/item/AA for action from the class module.',
			['params'] = {
				[1] = {
					['name'] = 'action',
					['type'] = 'string',
				},
			},
		},
		['Combat.PetAttack'] = {
			['desc'] = 'Sends your pet in to attack.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'sendSwarm',
					['type'] = 'boolean',
				},
			},
		},
		['Casting.GetSummonedItemIDFromSpell'] = {
			['ret'] = 'number',
			['desc'] = 'Scans the spell\'s effect list for SPA 32 (SPA_CREATE_ITEM) and returns the Base value of the first matching effect, which is the item ID that the spell summons. Returns 0 if the spell is nil or no create-item effect is found.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Tables.TableToString'] = {
			['ret'] = 'string:',
			['desc'] = 'Converts a table value to its string representation.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table:',
				},
				[2] = {
					['name'] = 'maxLen',
					['type'] = 'number?:',
				},
			},
		},
		['Core.GetHelpers'] = {
			['ret'] = 'table<string,',
			['desc'] = 'Returns the class module\'s helpers table (named callbacks keyed by name).',
			['params'] = {},
		},
		['Movement.GetLastStickTimer'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the timestamp (seconds) when the last stick command was sent.',
			['params'] = {},
		},
		['Math.Rotate'] = {
			['ret'] = 'number',
			['desc'] = 'Rotates point (x, y) by angle (radians) around the origin.',
			['params'] = {
				[1] = {
					['name'] = 'angle',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'x',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'y',
					['type'] = 'number',
				},
			},
		},
		['Config.ListMoveUp'] = {
			['desc'] = 'Moves the PC at the given index up.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string:',
				},
			},
		},
		['Movement.SetLastStickTimer'] = {
			['desc'] = 'Records t as the timestamp of the most recent stick command.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'number',
				},
			},
		},
		['Casting.UseAbility'] = {
			['ret'] = 'boolean',
			['desc'] = 'Fires a combat ability (e.g., Taunt, Kick) via /doability.',
			['params'] = {
				[1] = {
					['name'] = 'abilityName',
					['type'] = 'string',
				},
			},
		},
		['Casting.HaveManaToNuke'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if mana percent is at or above the ManaToNuke threshold, or if burn is active (BurnCheck) and bRestrictBurns is not set — allowing nukes to continue during burn regardless of mana.',
			['params'] = {
				[1] = {
					['name'] = 'bRestrictBurns',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Combat.ValidCombatTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the spawn with the given id is a valid, living combat target.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Core.SafeCallClassHelper'] = {
			['ret'] = 'any',
			['desc'] = 'Safely invokes class helper name via SafeCallFunc; no-op if not defined.',
			['params'] = {
				[1] = {
					['name'] = 'logInfo',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'name',
					['type'] = 'string',
				},
				[3] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Comms.GetAllPeerHeartbeats'] = {
			['ret'] = 'table',
			['desc'] = 'Returns all cached peer heartbeat data. When includeSelf is false, the local peer\'s own entry is excluded.',
			['params'] = {
				[1] = {
					['name'] = 'includeSelf',
					['type'] = 'boolean?',
				},
			},
		},
		['Combat.AETargetCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if AE damage conditions are met (enough haters in range, optionally all mobs are haters).',
			['params'] = {
				[1] = {
					['name'] = 'printDebug',
					['type'] = 'boolean?',
				},
				[2] = {
					['name'] = 'minCount',
					['type'] = 'number?',
				},
			},
		},
		['Casting.HaveManaToDot'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if mana percent is at or above the ManaToDot threshold, or if burn is active (BurnCheck) and bRestrictBurns is not set — allowing DoTs to be applied during burn regardless of mana.',
			['params'] = {
				[1] = {
					['name'] = 'bRestrictBurns',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Movement.GetTimeSinceLastStick'] = {
			['ret'] = 'string',
			['desc'] = 'Returns elapsed seconds since the last stick command as a string, or "N/A" if no stick has been issued yet.',
			['params'] = {},
		},
		['Config.SetSetting'] = {
			['desc'] = 'Sets a setting from either in global or a module setting table.',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'value',
					['type'] = 'any:',
				},
				[3] = {
					['name'] = 'tempOnly',
					['type'] = 'boolean?:',
				},
				[4] = {
					['name'] = 'noCallback',
					['type'] = 'boolean?:',
				},
			},
		},
		['Config.AssistMoveDown'] = {
			['desc'] = 'Moves the PC at the given index down.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string:',
				},
			},
		},
		['Casting.HaveManaToDebuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if mana percent is at or above the ManaToDebuff threshold, or if burn is active (BurnCheck) and bRestrictBurns is not set — allowing debuffs to be applied during burn regardless of mana.',
			['params'] = {
				[1] = {
					['name'] = 'bRestrictBurns',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Math.Lerp'] = {
			['ret'] = 'number',
			['desc'] = 'Linearly interpolates between a and b by factor t (0=a, 1=b).',
			['params'] = {
				[1] = {
					['name'] = 'a',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'b',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 't',
					['type'] = 'number',
				},
			},
		},
		['Movement.GetTimeSinceLastNav'] = {
			['ret'] = 'string',
			['desc'] = 'Returns elapsed seconds since the last nav command as a string, or "N/A" if no nav has been issued yet.',
			['params'] = {},
		},
		['Ui.AnimatedButton'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an animated button that scales and color-tweens on hover/press.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'size',
					['type'] = 'ImVec2',
				},
				[4] = {
					['name'] = 'callbackFn',
					['type'] = 'function?',
				},
			},
		},
		['Casting.UseItem'] = {
			['ret'] = 'boolean|nil',
			['desc'] = 'Uses a clicky item on a target.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'targetId',
					['type'] = 'number|nil',
				},
				[3] = {
					['name'] = 'bAllowDead',
					['type'] = 'boolean?',
				},
				[4] = {
					['name'] = 'retryCount',
					['type'] = 'number?',
				},
			},
		},
		['Ui.RenderLoadoutTable'] = {
			['desc'] = 'Renders the spell loadout table (gem, icon, var name, level, rank name).',
			['params'] = {
				[1] = {
					['name'] = 'loadoutTable',
					['type'] = 'table',
				},
			},
		},
		['Core.GetChaseTarget'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the name of the current chase target from the movement module.',
			['params'] = {},
		},
		['Rotation.FindAllMissingSpells'] = {
			['ret'] = 'table',
			['desc'] = 'Iterates all sets in abilitySets and collects missing spells by calling FindMissingSpells for each one.',
			['params'] = {
				[1] = {
					['name'] = 'abilitySets',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'highestOnly',
					['type'] = 'boolean',
				},
			},
		},
		['Movement.GetSecondsSinceLastNav'] = {
			['ret'] = 'number',
			['desc'] = 'Returns elapsed seconds since the last nav command as a number, or 0 if no nav has been issued.',
			['params'] = {},
		},
		['Math.ColorLerp'] = {
			['ret'] = 'ImVec4',
			['desc'] = 'Linearly interpolates between two ImVec4 colors by factor t.',
			['params'] = {
				[1] = {
					['name'] = 'c1',
					['type'] = 'ImVec4',
				},
				[2] = {
					['name'] = 'c2',
					['type'] = 'ImVec4',
				},
				[3] = {
					['name'] = 't',
					['type'] = 'number',
				},
			},
		},
		['Config.ResolveListIndex'] = {
			['ret'] = 'number|nil',
			['desc'] = 'Resolve a name-or-index argument to a 1-based index in `list`. Returns nil if invalid/not found.',
			['params'] = {
				[1] = {
					['name'] = 'arg1',
					['type'] = 'string|number',
				},
				[2] = {
					['name'] = 'list',
					['type'] = 'table',
				},
			},
		},
		['Casting.DetSpellCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Resolves spell rank, then delegates to TargetBuffCheck to confirm the det effect is not already on the target. No HP check — use DotSpellCheck for DoTs.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Casting.ActorPetBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Complex buff check that will check for presence and stacking of the buff (and any triggers) on an actor peer.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn|MQCharacter?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean|nil',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Strings.GetTimeAsTable'] = {
			['ret'] = 'table',
			['desc'] = 'Returns the current time as a table.',
			['params'] = {
				[1] = {
					['name'] = 'time',
					['type'] = 'number',
				},
			},
		},
		['Targeting.GetTargetSlowedPct'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the slow percentage on the current in-game target, or 0 if not slowed.',
			['params'] = {},
		},
		['Config.SetTempSetting'] = {
			['desc'] = 'Temporarily sets a setting',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'value',
					['type'] = 'any:',
				},
			},
		},
		['Casting.DetAACheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gates on CanUseAA, then delegates to TargetBuffCheck using the AA\'s spell ID to confirm the det effect is not already on target.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Movement.NavInCombat'] = {
			['desc'] = 'Navigates to the combat target then sticks; bNoWait issues the nav and returns immediately instead of waiting for arrival.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'distance',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'bDontStick',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'bCalledFromInsideEvent',
					['type'] = 'boolean?',
				},
				[5] = {
					['name'] = 'bNoWait',
					['type'] = 'boolean?',
				},
			},
		},
		['Config.ClearTempSetting'] = {
			['desc'] = 'Clears a Temporarily sets a setting',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string:',
				},
			},
		},
		['Targeting.FacingTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the player\'s heading is within 20 degrees of the target.',
			['params'] = {},
		},
		['Casting.DetItemCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gets the clicky spell via GetClickySpell, then delegates to TargetBuffCheck to confirm the det effect is not already on target.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Config.PeerGetSetting'] = {
			['ret'] = 'any',
			['desc'] = 'Retrieves a specified setting.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'setting',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'failOk',
					['type'] = 'boolean?',
				},
			},
		},
		['Targeting.SetTarget'] = {
			['desc'] = 'Thin wrapper around Core.SetTarget; exists to avoid a breaking API change.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'ignoreBuffPopulation',
					['type'] = 'boolean?',
				},
			},
		},
		['Rotation.GetBestItem'] = {
			['ret'] = 'string|nil',
			['desc'] = 'Returns the first item name from t whose item is in the player\'s inventory, or nil if none are found.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table',
				},
			},
		},
		['Strings.BoolToString'] = {
			['ret'] = 'string:',
			['desc'] = 'Converts a boolean value to its string representation.',
			['params'] = {
				[1] = {
					['name'] = 'b',
					['type'] = 'boolean:',
				},
			},
		},
		['Targeting.GetHighestAggroPct'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the highest aggro percentage the player has across the current target and all aggressive or force-targeted XTarget entries.',
			['params'] = {},
		},
		['Strings.gsplit'] = {
			['ret'] = 'function',
			['desc'] = 'Returns a stateful iterator that yields each substring of text separated by pattern, similar to Python\'s str.split.',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'pattern',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'plain',
					['type'] = 'boolean?',
				},
			},
		},
		['Casting.AuraActiveByName'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks if an aura is active by its name.',
			['params'] = {
				[1] = {
					['name'] = 'auraName',
					['type'] = 'string',
				},
			},
		},
		['Config.ZoneListDelete'] = {
			['desc'] = 'Deletes a name (or index) from a zone-keyed list for the current (or specified) zone.',
			['params'] = {
				[1] = {
					['name'] = 'arg1',
					['type'] = 'string|number',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'zoneKey',
					['type'] = 'string?',
				},
			},
		},
		['Ui.InvisibleWithButtonText'] = {
			['desc'] = 'Renders an invisible button then overlays text at the same cursor position.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'size',
					['type'] = 'ImVec2?',
				},
				[4] = {
					['name'] = 'callbackFn',
					['type'] = 'function?',
				},
			},
		},
		['Targeting.GetAggroTarget'] = {
			['ret'] = 'MQSpawn',
			['desc'] = 'Returns the spawn object for the current aggro target ID.',
			['params'] = {},
		},
		['Strings.BoolToColorString'] = {
			['ret'] = 'string:',
			['desc'] = 'Converts a boolean value to a color string. If the boolean is true, it returns "green", otherwise "red".',
			['params'] = {
				[1] = {
					['name'] = 'b',
					['type'] = 'boolean:',
				},
			},
		},
		['Ui.RenderRotationTable'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders the rotation table for the named rotation section.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'rotationTable',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'resolvedActionMap',
					['type'] = 'table',
				},
				[4] = {
					['name'] = 'rotationState',
					['type'] = 'number?',
				},
				[5] = {
					['name'] = 'showFailed',
					['type'] = 'boolean',
				},
				[6] = {
					['name'] = 'enabledRotationEntries',
					['type'] = 'table',
				},
			},
		},
		['Movement.NavAroundCircle'] = {
			['ret'] = 'boolean',
			['desc'] = 'Finds a navigable, line-of-sight point radius units from target and navigates there, used for circling mobs that block direct approach.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
				[2] = {
					['name'] = 'radius',
					['type'] = 'number',
				},
			},
		},
		['Config.MakeValidSetting'] = {
			['ret'] = 'boolean|string|number|nil:',
			['desc'] = 'Validates and sets a configuration setting for a specified module.',
			['params'] = {
				[1] = {
					['name'] = 'module',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'setting',
					['type'] = 'string:',
				},
				[3] = {
					['name'] = 'value',
					['type'] = 'any:',
				},
			},
		},
		['Config.GetSetting'] = {
			['ret'] = 'any',
			['desc'] = 'Retrieves a specified setting.',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'failOk',
					['type'] = 'boolean?',
				},
			},
		},
		['Casting.ReagentCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Verifies the player has the spell\'s expended reagent (ReagentID slot 1) and, on live servers, the non-expended reagent (NoExpendReagentID slot 1) in inventory. Announces a chat message to the group/raid if either is missing. Returns false if any required reagent is absent.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Targeting.IHaveAggro'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if any aggressive XTarget (or the current target) shows the player at or above pct aggro.',
			['params'] = {
				[1] = {
					['name'] = 'pct',
					['type'] = 'number',
				},
			},
		},
		['Strings.TrimSpaces'] = {
			['ret'] = 'string',
			['desc'] = 'Trims leading and trailing whitespace from a string.',
			['params'] = {
				[1] = {
					['name'] = 's',
					['type'] = 'string',
				},
			},
		},
		['Ui.GetBGForSpell'] = {
			['ret'] = 'any',
			['desc'] = 'Returns the texture animation to use as background for spell icon.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell?',
				},
			},
		},
		['Ui.RenderToastNotifications'] = {
			['desc'] = 'Renders active toast notifications as floating cards; auto-dismisses stale ones.',
			['params'] = {
				[1] = {
					['name'] = 'states',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'lingerTime',
					['type'] = 'number?',
				},
			},
		},
		['Config.GetSettingDefaults'] = {
			['ret'] = 'any',
			['desc'] = 'Retrieves a specified setting default info.',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string',
				},
			},
		},
		['Config.PruneRegistryEntryIfEmpty'] = {
			['desc'] = 'Removes a zone registry entry if it has no remaining flags set.',
			['params'] = {
				[1] = {
					['name'] = 'zoneTbl',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Ui.ChangeColorAlpoha'] = {
			['ret'] = 'ImVec4',
			['desc'] = 'Returns a copy of color with the alpha channel replaced by newAlpha.',
			['params'] = {
				[1] = {
					['name'] = 'color',
					['type'] = 'ImVec4',
				},
				[2] = {
					['name'] = 'newAlpha',
					['type'] = 'number',
				},
			},
		},
		['Ui.ImVec4ToColor'] = {
			['ret'] = 'number',
			['desc'] = 'Converts an ImVec4 (0–1 float components) to an IM_COL32 packed color.',
			['params'] = {
				[1] = {
					['name'] = 'vec',
					['type'] = 'ImVec4',
				},
			},
		},
		['Ui.GetWindowTitle'] = {
			['ret'] = 'string',
			['desc'] = 'Returns an ImGui window title string with a per-character ID suffix if needed.',
			['params'] = {
				[1] = {
					['name'] = 'title',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'idOverride',
					['type'] = 'string?',
				},
			},
		},
		['Ui.RenderModulesPopped'] = {
			['desc'] = 'Iterates all modules and renders any that are popped out into their own windows.',
			['params'] = {
				[1] = {
					['name'] = 'flags',
					['type'] = 'number',
				},
			},
		},
		['Config.PeerGetSettingDefaults'] = {
			['ret'] = 'any',
			['desc'] = 'Retrieves a specified setting default info for a peer.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'setting',
					['type'] = 'string',
				},
			},
		},
		['Ui.StrikeThroughText'] = {
			['desc'] = 'Renders text as strikethrough',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string',
				},
			},
		},
		['Ui.NonCollapsingHeader'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders a non-collapsible TreeNode styled as a CollapsingHeader.',
			['params'] = {
				[1] = {
					['name'] = 'label',
					['type'] = 'string',
				},
			},
		},
		['Ui.MultiColorSmallButton'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders a button composed of multiple colored text segments side-by-side.',
			['params'] = {
				[1] = {
					['name'] = 'lines',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'addSpaces',
					['type'] = 'boolean?',
				},
			},
		},
		['Combat.GetGroupOrRaidAssistTargetId'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the current target ID of the group or raid main assist.',
			['params'] = {},
		},
		['Ui.MultilineTooltipWithColors'] = {
			['desc'] = 'Shows a tooltip with multiple colored text segments when the item is hovered.',
			['params'] = {
				[1] = {
					['name'] = 'lines',
					['type'] = 'table',
				},
			},
		},
		['Casting.ShouldShrink'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true when DoShrink is enabled, a ShrinkItem is configured, the player\'s height is 2.3 or greater (i.e., not already shrunk), and OkayToBuff passes (visible, safe, stationary, not low-mana).',
			['params'] = {},
		},
		['Targeting.GetTargetID'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the spawn ID of target, or the current in-game target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget?',
				},
			},
		},
		['Ui.AnimatedTooltip'] = {
			['desc'] = 'Renders an animated tooltip with fade-in and line-wrap, anchored to the item.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string|number',
				},
				[2] = {
					['name'] = 'desc',
					['type'] = 'string|table',
				},
			},
		},
		['Ui.NavEnabledLoc'] = {
			['desc'] = 'Checks if navigation is enabled for a given location.',
			['params'] = {
				[1] = {
					['name'] = 'loc',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'navLocOverride',
					['type'] = 'string?',
				},
			},
		},
		['Ui.GetConHighlight'] = {
			['ret'] = 'number,',
			['desc'] = 'Get the con color based on the provided color value.',
			['params'] = {
				[1] = {
					['name'] = 'color',
					['type'] = 'string',
				},
			},
		},
		['Config.ZoneRegistrySetFlag'] = {
			['desc'] = 'Sets a top-level flag on a zone registry entry (currently just \'named\').',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'group',
					['type'] = 'string',
				},
				[4] = {
					['name'] = 'value',
					['type'] = 'boolean',
				},
				[5] = {
					['name'] = 'zoneKey',
					['type'] = 'string?',
				},
			},
		},
		['Ui.GetConColorBySpawn'] = {
			['ret'] = 'number,',
			['desc'] = 'Returns the EQ con color RGBA components for spawn, or "Dead" color if gone.',
			['params'] = {
				[1] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Casting.ResolveBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Helper that will perform complex checks for presence and stacking of buffs (and any triggers) using the best (determined) method available.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn|MQCharacter?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean|nil',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Casting.ShouldShrinkPet'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true when DoShrinkPet is enabled, a ShrinkPetItem is configured, a pet exists, the pet\'s height is 1.9 or greater (i.e., not already shrunk), and OkayToPetBuff passes (DoPet enabled plus the same safe/stationary/visible/mana gates as OkayToBuff).',
			['params'] = {},
		},
		['Strings.StartsWith'] = {
			['ret'] = 'boolean',
			['desc'] = 'Case-insensitive check whether str begins with the prefix start.',
			['params'] = {
				[1] = {
					['name'] = 'str',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'start',
					['type'] = 'string',
				},
			},
		},
		['Config.MakeValidSettingName'] = {
			['ret'] = 'string,',
			['desc'] = 'Converts a given setting name into a valid format and module name This function ensures that the setting name adheres to the required format for further processing.',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string',
				},
			},
		},
		['Combat.GetMainAssistTargetID'] = {
			['ret'] = 'boolean',
			['desc'] = 'Resolves the MA\'s current target via actors heartbeat, DanNet, group/raid TLO, or target-of-target fallback; also updates ForceCombatID/AutoTargetIsNamed.',
			['params'] = {},
		},
		['Targeting.GetXTHaterIDsSet'] = {
			['ret'] = 'table',
			['desc'] = 'Returns a Set of spawn IDs currently hating the player on XTarget.',
			['params'] = {
				[1] = {
					['name'] = 'printDebug',
					['type'] = 'boolean?',
				},
			},
		},
		['Targeting.TargetBodyIs'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the target\'s body type name matches type (case-insensitive).',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn',
				},
				[2] = {
					['name'] = 'type',
					['type'] = 'string',
				},
			},
		},
		['Strings.TableToString'] = {
			['ret'] = 'string:',
			['desc'] = 'Converts a table value to its string representation.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table:',
				},
				[2] = {
					['name'] = 'maxLen',
					['type'] = 'number?:',
				},
			},
		},
		['Ui.GetConColor'] = {
			['ret'] = 'number,',
			['desc'] = 'Get the con color based on the provided color value.',
			['params'] = {
				[1] = {
					['name'] = 'color',
					['type'] = 'string',
				},
			},
		},
		['Casting.BurnCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Evaluates three burn triggers: autoBurn (BurnAuto enabled and XT hater count exceeds BurnMobCount, or the auto-target is a named mob with BurnNamed enabled), alwaysBurn (BurnAuto and BurnAlways both set), and forcedBurn (ForceBurnTargetID matches the current target). Caches the result in Globals.LastBurnCheck and announces state changes to the group/raid.',
			['params'] = {},
		},
		['Ui.GetDynamicTooltipForAA'] = {
			['ret'] = 'string',
			['desc'] = 'Generates a dynamic tooltip for a given action.',
			['params'] = {
				[1] = {
					['name'] = 'action',
					['type'] = 'string',
				},
			},
		},
		['Ui.GetDynamicTooltipForSpell'] = {
			['ret'] = 'string',
			['desc'] = 'Generates a dynamic tooltip for a given spell action.',
			['params'] = {
				[1] = {
					['name'] = 'action',
					['type'] = 'string',
				},
			},
		},
		['Ui.RenderHyperText'] = {
			['desc'] = 'Renders clickable hyperlink-style text that changes color on hover.',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'normalColor',
					['type'] = 'ImVec4|ImU32',
				},
				[3] = {
					['name'] = 'highlightColor',
					['type'] = 'ImVec4|ImU32',
				},
				[4] = {
					['name'] = 'callback',
					['type'] = 'function?',
				},
			},
		},
		['Strings.FormatTime'] = {
			['ret'] = 'string',
			['desc'] = 'Formats a given time',
			['params'] = {
				[1] = {
					['name'] = 'time',
					['type'] = 'number',
				},
			},
		},
		['Ui.RenderThemeConfigElement'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders a single theme config row (color var + color picker or style var + value).',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'themeElement',
					['type'] = 'table',
				},
			},
		},
		['Ui.RenderText'] = {
			['desc'] = 'Renders formatted text via ImGui.Text, reversing it in April Fools mode.',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Ui.RenderLogo'] = {
			['desc'] = 'Renders the RGMercs logo quad, with a wobble/track animation when hovered.',
			['params'] = {
				[1] = {
					['name'] = 'textureId',
					['type'] = 'any',
				},
			},
		},
		['Targeting.GetXTHaterIDs'] = {
			['ret'] = 'number[]',
			['desc'] = 'Returns an array of spawn IDs currently hating the player on XTarget.',
			['params'] = {
				[1] = {
					['name'] = 'printDebug',
					['type'] = 'boolean?',
				},
			},
		},
		['Ui.ThemeConfigMatchesFilter'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if searchFilter is empty or matches the "theme" category.',
			['params'] = {
				[1] = {
					['name'] = 'searchFilter',
					['type'] = 'string?',
				},
			},
		},
		['Config.PeerSetSetting'] = {
			['desc'] = 'Sets a setting from either in global or a module setting table.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'setting',
					['type'] = 'string:',
				},
				[3] = {
					['name'] = 'value',
					['type'] = 'any:',
				},
				[4] = {
					['name'] = 'tempOnly',
					['type'] = 'boolean?:',
				},
			},
		},
		['Ui.RenderThemeConfig'] = {
			['desc'] = 'Renders the full Theme Config panel (importers + per-element color/style rows).',
			['params'] = {
				[1] = {
					['name'] = 'searchFilter',
					['type'] = 'string?',
				},
			},
		},
		['Ui.RenderColoredText'] = {
			['desc'] = 'Renders formatted colored text via ImGui.TextColored.',
			['params'] = {
				[1] = {
					['name'] = 'color',
					['type'] = 'ImVec4|number',
				},
				[2] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[3] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Casting.GetAASpell'] = {
			['ret'] = 'MQSpell',
			['desc'] = 'Returns the MQSpell for an AA\'s activated effect without going through CanUseAA. Use when spell data is needed without the ownership/level/rank gate.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Combat.ValidMAXTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the spawn is a valid candidate for MA targeting.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'xtarget',
				},
			},
		},
		['Targeting.GetTargetLevel'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the level of target, or the current in-game target level if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget?',
				},
			},
		},
		['Movement.GetTimeSinceLastMove'] = {
			['ret'] = 'number',
			['desc'] = 'Returns seconds since the last "move" event, treating combat state as movement so buff checks only fire in true downtime.',
			['params'] = {},
		},
		['Targeting.GetXTHaterCount'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the number of spawns currently hating the player on XTarget.',
			['params'] = {
				[1] = {
					['name'] = 'printDebug',
					['type'] = 'boolean?',
				},
			},
		},
		['Casting.GOMCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the player currently has the "Gift of Mana" proc buff active in their buff or song window, indicating the next spell of appropriate type will cost no mana.',
			['params'] = {},
		},
		['Ui.MarqueeButton'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an invisible button with horizontally scrolling marquee text.',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'height',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'width',
					['type'] = 'number',
				},
			},
		},
		['Ui.RenderOptionNumber'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders a numerical option with a specified range and step.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'text',
					['type'] = 'string:',
				},
				[3] = {
					['name'] = 'cur',
					['type'] = 'number:',
				},
				[4] = {
					['name'] = 'min',
					['type'] = 'number:',
				},
				[5] = {
					['name'] = 'max',
					['type'] = 'number:',
				},
				[6] = {
					['name'] = 'step',
					['type'] = 'number?:',
				},
			},
		},
		['Ui.RenderFancyProgressBar'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an animated progress bar with orange→green gradient and a label.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'pctComplete',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'height',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'label',
					['type'] = 'string?',
				},
			},
		},
		['Ui.RenderFancyManaBar'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an animated mana bar using the global mana low/high colors.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'hpPct',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'height',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'borderThickness',
					['type'] = 'number?',
				},
				[5] = {
					['name'] = 'milestoneTicks',
					['type'] = 'number?',
				},
			},
		},
		['Ui.RenderFancyHPBar'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an animated HP bar; adds a pulsing red glow when burning is true.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'hpPct',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'height',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'burning',
					['type'] = 'boolean?',
				},
				[5] = {
					['name'] = 'borderThickness',
					['type'] = 'number?',
				},
				[6] = {
					['name'] = 'milestoneTicks',
					['type'] = 'number?',
				},
				[7] = {
					['name'] = 'hpLowOverride',
					['type'] = 'ImVec4?',
				},
				[8] = {
					['name'] = 'hpHighOverride',
					['type'] = 'ImVec4?',
				},
			},
		},
		['Config.ToggleSetting'] = {
			['desc'] = 'Toggles a boolean setting.',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'tempOnly',
					['type'] = 'boolean?:',
				},
				[3] = {
					['name'] = 'noCallback',
					['type'] = 'boolean?:',
				},
			},
		},
		['Casting.IHaveBuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Simple (no trigger or stacking checks) check to see if the player has a buff. Can pass a spell(userdata), ID, or effect name(string).',
			['params'] = {
				[1] = {
					['name'] = 'effect',
					['type'] = 'MQSpell|string|integer|nil',
				},
			},
		},
		['Ui.RenderAnimatedPercentage'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an animated fill bar that smoothly tweens toward barPct.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'barPct',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'height',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'width',
					['type'] = 'number',
				},
				[5] = {
					['name'] = 'colLow',
					['type'] = 'ImVec4',
				},
				[6] = {
					['name'] = 'colHigh',
					['type'] = 'ImVec4',
				},
				[7] = {
					['name'] = 'label',
					['type'] = 'string?',
				},
				[8] = {
					['name'] = 'borderThickness',
					['type'] = 'number?',
				},
				[9] = {
					['name'] = 'milestoneTicks',
					['type'] = 'number?',
				},
			},
		},
		['Ui.RenderProgressBar'] = {
			['desc'] = 'Renders a progress bar.',
			['params'] = {
				[1] = {
					['name'] = 'pct',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'width',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'height',
					['type'] = 'number',
				},
			},
		},
		['Movement.GetTimeSinceLastPositionChange'] = {
			['ret'] = 'number',
			['desc'] = 'Returns seconds since the last actual position change, ignoring combat state - useful for detecting true standing still.',
			['params'] = {},
		},
		['Ui.ReduceAlpha'] = {
			['ret'] = 'number',
			['desc'] = 'Multiplies the alpha channel of an IM_COL32 packed color by factor.',
			['params'] = {
				[1] = {
					['name'] = 'col',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'factor',
					['type'] = 'number',
				},
			},
		},
		['Casting.WaitCastFinish'] = {
			['desc'] = 'Polls Me.Casting every 20 ms until it clears, up to a timeout derived from cast time plus 20x ping plus 1 second. While waiting, StopCasts the spell if the target dies or leaves range (beyond 110% of spellRange); every 200 ms prods the pet to attack if combat is active and HP is below PetEngagePct; every 500 ms runs MA auto-target and tank aggro scans; prints a group message and force-stops if the timeout expires.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number|nil',
				},
				[2] = {
					['name'] = 'bAllowDead',
					['type'] = 'boolean',
				},
				[3] = {
					['name'] = 'spellRange',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'castTime',
					['type'] = 'number|nil',
				},
			},
		},
		['Ui.RenderFancyToggleOld'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders the legacy (non-animated) fancy toggle switch.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'label',
					['type'] = 'string?',
				},
				[3] = {
					['name'] = 'value',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'size',
					['type'] = 'ImVec2|number?',
				},
				[5] = {
					['name'] = 'on_color',
					['type'] = 'ImVec4?',
				},
				[6] = {
					['name'] = 'off_color',
					['type'] = 'ImVec4?',
				},
				[7] = {
					['name'] = 'knob_color',
					['type'] = 'ImVec4?',
				},
				[8] = {
					['name'] = 'right_label',
					['type'] = 'boolean?',
				},
				[9] = {
					['name'] = 'pulse_on_hover',
					['type'] = 'boolean?',
				},
				[10] = {
					['name'] = 'knob_border',
					['type'] = 'boolean?',
				},
				[11] = {
					['name'] = 'center_vertically',
					['type'] = 'boolean?',
				},
			},
		},
		['Ui.RenderFancyToggle'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders an animated fancy toggle switch with optional label and color options.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'label',
					['type'] = 'string?',
				},
				[3] = {
					['name'] = 'value',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'size',
					['type'] = 'ImVec2|number?',
				},
				[5] = {
					['name'] = 'on_color',
					['type'] = 'ImVec4?',
				},
				[6] = {
					['name'] = 'off_color',
					['type'] = 'ImVec4?',
				},
				[7] = {
					['name'] = 'knob_color',
					['type'] = 'ImVec4?',
				},
				[8] = {
					['name'] = 'right_label',
					['type'] = 'boolean?',
				},
				[9] = {
					['name'] = 'pulse_on_hover',
					['type'] = 'boolean?',
				},
				[10] = {
					['name'] = 'knob_border',
					['type'] = 'boolean?',
				},
				[11] = {
					['name'] = 'center_vertically',
					['type'] = 'boolean?',
				},
			},
		},
		['Core.GetGroupOrRaidAssistTargetId'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the target ID of the group or raid main assist via TLO, preferring raid assist when in a raid.',
			['params'] = {},
		},
		['Casting.CanAlliance'] = {
			['ret'] = 'boolean',
			['desc'] = 'Stub seemingly intended for alliance spell use',
			['params'] = {},
		},
		['Ui.DrawInspectableSpellIcon'] = {
			['desc'] = 'Draws an inspectable spell icon that opens the spell inspector on click.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'iconSize',
					['type'] = 'number?',
				},
				[3] = {
					['name'] = 'doBlink',
					['type'] = 'boolean?',
				},
				[4] = {
					['name'] = 'borderCol',
					['type'] = 'number?',
				},
			},
		},
		['Ui.RenderTableData'] = {
			['desc'] = 'Generic sortable table helper: sets up columns, calls sortFn with sort specs, then calls rowFn to emit rows.',
			['params'] = {
				[1] = {
					['name'] = 'tableName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'tableColumns',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'tableFlags',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'sortFn',
					['type'] = 'function',
				},
				[5] = {
					['name'] = 'rowFn',
					['type'] = 'function',
				},
			},
		},
		['Rotation.ExecEntry'] = {
			['ret'] = 'boolean|nil',
			['desc'] = 'Executes a single rotation entry (spell/song/disc/AA/item/etc.) on targetId, skipping mezzed targets when AllowMezBreak is off.',
			['params'] = {
				[1] = {
					['name'] = 'caller',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'entry',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'resolvedActionMap',
					['type'] = 'table',
				},
				[5] = {
					['name'] = 'bAllowMem',
					['type'] = 'boolean',
				},
			},
		},
		['Ui.RenderForceTargetList'] = {
			['desc'] = 'Renders the Force Target / Ignored Target list panel.',
			['params'] = {
				[1] = {
					['name'] = 'showPopout',
					['type'] = 'boolean?',
				},
			},
		},
		['Ui.RenderMercsStatus'] = {
			['desc'] = 'Renders the Mercs Status panel with HP/mana/state columns for each peer.',
			['params'] = {
				[1] = {
					['name'] = 'showPopout',
					['type'] = 'boolean?',
				},
			},
		},
		['Targeting.CrossDiffXTHaterIDs'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if either list has an ID the other doesn\'t (any hater gained or lost).',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'number[]',
				},
				[2] = {
					['name'] = 'printDebug',
					['type'] = 'boolean?',
				},
			},
		},
		['Ui.GetGroupstatusText'] = {
			['ret'] = 'string',
			['desc'] = 'Returns a short string indicating the group/raid slot of peerName. Returns "F1"–"F6" for group, "Gn" for raid, "X" for ungrouped.',
			['params'] = {
				[1] = {
					['name'] = 'peerName',
					['type'] = 'string',
				},
			},
		},
		['Targeting.IsSpawnXTHater'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if spawnId is in the XTarget list. When autoHater is true, only counts entries whose TargetType is "auto hater".',
			['params'] = {
				[1] = {
					['name'] = 'spawnId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'autoHater',
					['type'] = 'boolean?',
				},
			},
		},
		['Config.HandleBind'] = {
			['ret'] = 'boolean',
			['params'] = {
				[1] = {
					['name'] = 'config',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'value',
					['type'] = 'any',
				},
			},
		},
		['Combat.UpdateBucket'] = {
			['desc'] = 'Updates a HP-priority bucket if the spawn is a better candidate than what\'s currently stored.',
			['params'] = {
				[1] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
				[2] = {
					['name'] = 'bucket',
					['type'] = '{hp:number,id:number}',
				},
				[3] = {
					['name'] = 'prefLow',
					['type'] = 'boolean',
				},
			},
		},
		['Casting.AddedBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Calls ResolveBuffCheck with block and trigger checks both skipped. Used for manual stacking overrides where only presence matters.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Ui.GetClassConfigIDFromName'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the 1-based index of name in Globals.ClassConfigDirs, or 1 if absent.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Ui.RenderList'] = {
			['desc'] = 'Renders the indicated list.',
			['params'] = {
				[1] = {
					['name'] = 'listName',
					['type'] = 'string',
				},
			},
		},
		['Targeting.GetTargetMaxRangeTo'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the maximum range from the player to target, or current target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Casting.TargetHasBuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Simple (no trigger or stacking checks) check to see if the target has a buff. Can pass a spell(userdata), ID, or effect name(string).',
			['params'] = {
				[1] = {
					['name'] = 'effect',
					['type'] = 'MQSpell|string|integer',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn|MQCharacter?',
				},
				[3] = {
					['name'] = 'bAllowTargetChange',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Ui.GetImGuiStyleId'] = {
			['ret'] = 'number',
			['desc'] = 'Resolves an ImGui style variable ID from a name string or numeric value.',
			['params'] = {
				[1] = {
					['name'] = 'e',
					['type'] = 'string|number',
				},
			},
		},
		['Ui.GetImGuiColorId'] = {
			['ret'] = 'number',
			['desc'] = 'Resolves an ImGui color ID from a name string or numeric value.',
			['params'] = {
				[1] = {
					['name'] = 'e',
					['type'] = 'string|number',
				},
			},
		},
		['Ui.ConvertToThemez'] = {
			['ret'] = 'table',
			['desc'] = 'Converts an RGMercs userTheme table to a Themez-compatible export table.',
			['params'] = {
				[1] = {
					['name'] = 'userTheme',
					['type'] = 'table',
				},
			},
		},
		['Movement.SetNavPaused'] = {
			['desc'] = 'Deterministically pauses or resumes navigation, no-op if already in the desired state. /nav pause is a toggle, so we check state first to avoid flipping the wrong way.',
			['params'] = {
				[1] = {
					['name'] = 'shouldPause',
					['type'] = 'boolean',
				},
			},
		},
		['Ui.ConvertFromThemez'] = {
			['ret'] = 'table',
			['desc'] = 'Converts a Themez theme (by index) to an RGMercs userTheme table.',
			['params'] = {
				[1] = {
					['name'] = 'themeName',
					['type'] = 'number',
				},
			},
		},
		['Tables.PrintTableDiff'] = {
			['desc'] = 'Prints a colored unified-style diff between tables a and b, showing 2 lines of context around each change.',
			['params'] = {
				[1] = {
					['name'] = 'a',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'b',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'label',
					['type'] = 'string?',
				},
			},
		},
		['Targeting.TargetIsMA'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s ID matches the configured main assist.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Targeting.GetTargetPctHPs'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the HP percentage of target, or the current in-game target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn?',
				},
			},
		},
		['Casting.DotItemCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns false early if target HP is low. Gets clicky spell via GetClickySpell, then delegates to TargetBuffCheck with target-change and duplicate-from-self checks enabled.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Tables.GetTableSize'] = {
			['ret'] = 'number',
			['desc'] = 'Gets the size of a table.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table',
				},
			},
		},
		['Tables.PrintTable'] = {
			['desc'] = 'Converts a table value to its string representation.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table:',
				},
			},
		},
		['Tables._compareTables'] = {
			['ret'] = 'boolean',
			['desc'] = 'Recursively compares tables a and b, tracking visited pairs to handle cycles. Calls PrintTableDiff on the first mismatch found.',
			['params'] = {
				[1] = {
					['name'] = 'a',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'b',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'visited',
					['type'] = 'table',
				},
			},
		},
		['Combat.PickBestSpawn'] = {
			['desc'] = 'Selects the spawn into the bucket according to hpPref, or unconditionally if no HP preference is set.',
			['params'] = {
				[1] = {
					['name'] = 'hpPref',
					['type'] = '{prefLow:boolean,prefHigh:boolean}',
				},
				[2] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
				[3] = {
					['name'] = 'bucket',
					['type'] = '{hp:number,id:number}',
				},
			},
		},
		['Core.SetTarget'] = {
			['desc'] = 'Targets targetId and waits up to 2×ping+500 ms for buffs to populate, then fires OnTargetChange on all modules.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'ignoreBuffPopulation',
					['type'] = 'boolean?',
				},
			},
		},
		['Casting.GroupBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Resolves spell rank via GetUseableSpellId, then delegates to ResolveBuffCheck which picks the best method (local, pet, actor heartbeat, DanNet peer, or target-change) based on the target.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean?',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean?',
				},
			},
		},
		['Tables.DeepCopy'] = {
			['ret'] = 'any',
			['desc'] = 'Returns a deep copy of orig, handling cyclic references via copies.',
			['params'] = {
				[1] = {
					['name'] = 'orig',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'copies',
					['type'] = 'table?',
				},
			},
		},
		['Targeting.TargetIsACaster'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s class short name is in the RGCasters set.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Targeting.GetTargetHeight'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the model height of target, or the current in-game target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn?',
				},
			},
		},
		['Casting.SpellReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Verifies the player is not silenced, has the spell in their spellbook, and the gem timer has cleared (unless skipGemTimer is true — used to allow memorization mid-cooldown), then runs CastCheck for mana/endurance/movement/control conditions.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'skipGemTimer',
					['type'] = 'boolean?',
				},
			},
		},
		['Ui.RenderColorWaveText'] = {
			['desc'] = 'Renders text with an animated color-wave gradient; falls back to a colored Selectable if the coverage-mask draw API is unavailable.',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'conColor',
					['type'] = 'ImVec4',
				},
				[3] = {
					['name'] = 'clickedAction',
					['type'] = 'function?',
				},
				[4] = {
					['name'] = 'dontUseWave',
					['type'] = 'boolean?',
				},
			},
		},
		['Targeting.IsSpawnFightingStranger'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if any PC/pet/merc within radius is assisting spawn but is not in our group, raid, guild, or DanNet — meaning attacking them would grief another player.',
			['params'] = {
				[1] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
				[2] = {
					['name'] = 'radius',
					['type'] = 'number',
				},
			},
		},
		['Casting.LocalBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Complex buff check that will check for presence and stacking of the buff (and any triggers) on the PC or the PC\'s pet.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean|nil',
				},
				[3] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Tables.TableContains'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks if a table contains a specific value.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'value',
					['type'] = 'any',
				},
			},
		},
		['Targeting.TargetIsAMelee'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s class short name is in the RGMelee set.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Targeting.GetAutoTargetPctHPs'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the HP percentage of the current auto target, or 0 if no auto target.',
			['params'] = {},
		},
		['Tables.TableToImVec2'] = {
			['ret'] = 'ImVec2',
			['desc'] = 'Converts a table to an ImVec2.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table',
				},
			},
		},
		['Tables.ImVec2ToTable'] = {
			['ret'] = 'table|nil',
			['desc'] = 'Converts an ImVec2 to a table.',
			['params'] = {
				[1] = {
					['name'] = 'vec',
					['type'] = 'ImVec2',
				},
			},
		},
		['Combat.IsPreferredType'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if spawn matches the named/trash preference (no preference matches anything).',
			['params'] = {
				[1] = {
					['name'] = 'spawnIsNamed',
					['type'] = 'boolean',
				},
				[2] = {
					['name'] = 'namedPref',
					['type'] = '{prefNamed:boolean,prefTrash:boolean}',
				},
			},
		},
		['Casting.OkayToBuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns false immediately if the DoBuffs setting is off, otherwise delegates to CheckOkayToBuff which verifies the player is visible, not in combat, stationary long enough, and not critically low on mana.',
			['params'] = {},
		},
		['Tables.TableToImVec4'] = {
			['ret'] = 'ImVec4|nil',
			['desc'] = 'Converts a table to an ImVec4.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table',
				},
			},
		},
		['Targeting.TargetIsATank'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s class short name is in the RGTank set.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Tables.TableRGBAToXYZW'] = {
			['ret'] = 'table|nil',
			['desc'] = 'Converts an ImVec4 to a table.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'table',
				},
			},
		},
		['Tables.ImVec4ToTable'] = {
			['ret'] = 'table|nil',
			['desc'] = 'Converts an ImVec4 to a table.',
			['params'] = {
				[1] = {
					['name'] = 'vec',
					['type'] = 'ImVec4',
				},
			},
		},
		['Targeting.GetAutoTargetLevel'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the level of the current auto target, or 0 if no auto target.',
			['params'] = {},
		},
		['Casting.SongReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks if a given song is ready to be sung: verifies the player is not silenced, has the song in their spellbook, and that the gem timer has expired (unless skipGemTimer is true), then runs CastCheck for mana/endurance/control/movement conditions.',
			['params'] = {
				[1] = {
					['name'] = 'songSpell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'skipGemTimer',
					['type'] = 'boolean?',
				},
			},
		},
		['Config.ShouldDismount'] = {
			['ret'] = 'boolean',
			['desc'] = 'Determines whether the character should dismount. This function checks certain conditions to decide if the character should dismount.',
			['params'] = {},
		},
		['Rotation.ResolveActions'] = {
			['ret'] = 'table',
			['desc'] = 'Builds and returns a resolvedActionMap by calling GetBestItem, GetBestSpell, and GetBestAA for each entry in itemSets, abilitySets, and aaSets.',
			['params'] = {
				[1] = {
					['name'] = 'itemSets',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'abilitySets',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'aaSets',
					['type'] = 'table|nil',
				},
			},
		},
		['Strings.FormatTimeMS'] = {
			['ret'] = 'string',
			['desc'] = 'Formats a given time according to the specified format string.',
			['params'] = {
				[1] = {
					['name'] = 'time',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'formatString',
					['type'] = 'string?',
				},
			},
		},
		['Strings.split'] = {
			['ret'] = 'table:',
			['desc'] = 'Splits a given text into a table of substrings based on a specified pattern.',
			['params'] = {
				[1] = {
					['name'] = 'text',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'pattern',
					['type'] = 'string:',
				},
				[3] = {
					['name'] = 'plain',
					['type'] = 'boolean?:',
				},
			},
		},
		['Targeting.TargetIsMyself'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s ID matches the player\'s own spawn ID.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Casting.GroupBuffItemCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gets clicky spell via GetClickySpell, then delegates to ResolveBuffCheck. ResolveBuffCheck picks the best method based on the target (local, pet, actor heartbeat, DanNet, target-change).',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean?',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean?',
				},
			},
		},
		['Rotation.RunPreActivate'] = {
			['desc'] = 'Calls entry.pre_activate(caller, condArg) if the entry defines it, allowing the class to prepare state before an action fires.',
			['params'] = {
				[1] = {
					['name'] = 'caller',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'resolvedActionMap',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'entry',
					['type'] = 'table',
				},
			},
		},
		['Targeting.GetTargetDead'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target is dead or does not exist.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget',
				},
			},
		},
		['Rotation.FindMissingSpells'] = {
			['ret'] = 'table',
			['desc'] = 'Appends entries for spells in spellList that are not in the spellbook to alreadyMissingSpells. When highestOnly is true, only the highest-level spell in the list is checked.',
			['params'] = {
				[1] = {
					['name'] = 'varName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'spellList',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'alreadyMissingSpells',
					['type'] = 'table',
				},
				[4] = {
					['name'] = 'highestOnly',
					['type'] = 'boolean',
				},
			},
		},
		['Rotation.SetSpellLoadOutByPriority'] = {
			['ret'] = 'string',
			['desc'] = 'Evaluates each list in spellList in order, selects the first whose condition passes, and assigns spells to gems by priority within that list.',
			['params'] = {
				[1] = {
					['name'] = 'caller',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'spellList',
					['type'] = 'table',
				},
			},
		},
		['Strings.TableFromString'] = {
			['ret'] = 'table|nil',
			['desc'] = 'Parses a string produced by Strings.TableToString back into a table. Numbers and booleans are coerced; all other unquoted values become strings. Truncated tables (`...}`) parse as much as possible and stop. Returns nil + error message on malformed input.',
			['params'] = {
				[1] = {
					['name'] = 's',
					['type'] = 'string:',
				},
			},
		},
		['Casting.CanActMidSong'] = {
			['ret'] = 'boolean',
			['desc'] = 'A bard may fire an instant action while a song\'s cast window is open.',
			['params'] = {
				[1] = {
					['name'] = 'castTimeMs',
					['type'] = 'number?',
				},
			},
		},
		['Rotation.Run'] = {
			['ret'] = 'boolean',
			['desc'] = 'Iterates rotationTable from start_step, testing conditions and executing entries against targetTable until steps successful casts or end of table. Restores the UseGem spell after combat if LastGemRemem is configured.',
			['params'] = {
				[1] = {
					['name'] = 'caller',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'rotationTable',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'targetTable',
					['type'] = 'table',
				},
				[4] = {
					['name'] = 'resolvedActionMap',
					['type'] = 'table',
				},
				[5] = {
					['name'] = 'steps',
					['type'] = 'number',
				},
				[6] = {
					['name'] = 'start_step',
					['type'] = 'number',
				},
				[7] = {
					['name'] = 'bAllowMem',
					['type'] = 'boolean',
				},
				[8] = {
					['name'] = 'bDoFullRotation',
					['type'] = 'boolean?',
				},
				[9] = {
					['name'] = 'fnRotationCond',
					['type'] = 'function?',
				},
				[10] = {
					['name'] = 'enabledRotationEntries',
					['type'] = 'table',
				},
			},
		},
		['Casting.TargetBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Complex buff check that will check for presence and stacking of the buff (and any triggers) on a target.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn|MQCharacter?',
				},
				[3] = {
					['name'] = 'bAllowTargetChange',
					['type'] = 'boolean|nil',
				},
				[4] = {
					['name'] = 'bAllowDuplicates',
					['type'] = 'boolean|nil',
				},
				[5] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Casting.MoveBlocksCast'] = {
			['ret'] = 'boolean',
			['params'] = {
				[1] = {
					['name'] = 'castTimeMs',
					['type'] = 'number?',
				},
			},
		},
		['Targeting.GetTargetLOS'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the target is in line of sight.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget',
				},
			},
		},
		['Rotation.TestConditionForEntry'] = {
			['ret'] = 'boolean',
			['desc'] = 'Evaluates entry.cond and entry.active_cond for the given target, returning separate pass and active booleans.',
			['params'] = {
				[1] = {
					['name'] = 'caller',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'resolvedActionMap',
					['type'] = 'table',
				},
				[3] = {
					['name'] = 'entry',
					['type'] = 'table',
				},
				[4] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Targeting.MobNotLowHP'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s HP% is at or above the low-HP threshold (uses NamedLowHP for named mobs, MobLowHP otherwise).',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|MQTarget?',
				},
			},
		},
		['ItemManager.QueueAutoInv'] = {
			['desc'] = 'Arms a 15s window to stow the summoned item id once it lands on the cursor and we\'re not casting.',
			['params'] = {
				[1] = {
					['name'] = 'itemId',
					['type'] = 'number',
				},
			},
		},
		['Rotation.GetBestSpell'] = {
			['ret'] = 'MQSpell|nil',
			['desc'] = 'Returns the highest-level known spell from spellList that is in the spellbook or combat ability list and has not already been resolved.',
			['params'] = {
				[1] = {
					['name'] = 'spellList',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'alreadyResolvedMap',
					['type'] = 'table',
				},
			},
		},
		['Rotation.GetBestAA'] = {
			['ret'] = 'string|nil',
			['desc'] = 'Returns the first AA name in aaList that the character has purchased, or nil if none are available.',
			['params'] = {
				[1] = {
					['name'] = 'aaList',
					['type'] = 'table',
				},
			},
		},
		['Targeting.IsSafeName'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if name is a "safe" player: DanNet peer, group, raid, guild, or on the AssistList config. Prevents accidentally engaging friendly players.',
			['params'] = {
				[1] = {
					['name'] = 'spawnType',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Math.Clamp'] = {
			['ret'] = 'number',
			['desc'] = 'Clamps value to the inclusive range [low, high].',
			['params'] = {
				[1] = {
					['name'] = 'value',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'low',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'high',
					['type'] = 'number',
				},
			},
		},
		['ItemManager.BroadcastQueueAutoInv'] = {
			['desc'] = 'Arms our own copy and tells same server+zone+instance peers to stow theirs by id over actors.',
			['params'] = {
				[1] = {
					['name'] = 'itemId',
					['type'] = 'number',
				},
			},
		},
		['Rotation.GetEntryConditionArg'] = {
			['ret'] = 'any',
			['desc'] = 'Resolves the condition argument for entry from resolvedActionMap — returns a spell for spell/song/disc types, an item/AA name otherwise.',
			['params'] = {
				[1] = {
					['name'] = 'map',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'entry',
					['type'] = 'table',
				},
			},
		},
		['Casting.DiscReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks CombatAbilityReady for the disc\'s ranked name, then runs CastCheck allowing movement and, for bards with an instant-cast disc (0 cast time), allowing an open casting window.',
			['params'] = {
				[1] = {
					['name'] = 'discSpell',
					['type'] = 'MQSpell',
				},
			},
		},
		['ItemManager.SwapItemToSlot'] = {
			['desc'] = 'Swaps the specified item to the given slot.',
			['params'] = {
				[1] = {
					['name'] = 'slot',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'item',
					['type'] = 'string',
				},
			},
		},
		['Targeting.MobHasLowHP'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s HP% is below the low-HP threshold (uses NamedLowHP for named mobs, MobLowHP otherwise).',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|MQTarget?',
				},
			},
		},
		['Ui.HandleStatusClickAction'] = {
			['desc'] = 'Dispatches a left/right-click action on a peer in the Mercs Status panel.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'action',
					['type'] = 'number',
				},
			},
		},
		['Core.SafeCallFunc'] = {
			['ret'] = 'any',
			['desc'] = 'Calls fn via pcall, logging an error with logInfo context on failure. Returns true (pass) when fn is nil, treating a missing condition as success.',
			['params'] = {
				[1] = {
					['name'] = 'logInfo',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'fn',
					['type'] = 'function?',
				},
				[3] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['ItemManager.GiveTo'] = {
			['desc'] = 'Gives a specified item to a target.',
			['params'] = {
				[1] = {
					['name'] = 'toId',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'count',
					['type'] = 'number',
				},
			},
		},
		['Targeting.GetMaxMeleeRange'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the max melee range to target. When target is invalid, returns 999 if failHigh is true, otherwise 0.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget',
				},
				[2] = {
					['name'] = 'failHigh',
					['type'] = 'boolean',
				},
			},
		},
		['Comms.GetPeerHeartbeat'] = {
			['ret'] = 'table',
			['desc'] = 'Returns the cached heartbeat for the given peer key, or {} if the peer has no recorded heartbeat.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
			},
		},
		['Combat.FallbackScan'] = {
			['desc'] = 'Scans nearby spawns matching search and updates the primaryTarget bucket as a fallback when XTargets yield nothing.',
			['params'] = {
				[1] = {
					['name'] = 'search',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'checkNamed',
					['type'] = 'boolean',
				},
				[3] = {
					['name'] = 'radius',
					['type'] = 'number',
				},
				[4] = {
					['name'] = 'namedPref',
					['type'] = '{prefNamed:boolean,prefTrash:boolean}',
				},
				[5] = {
					['name'] = 'hpPref',
					['type'] = '{prefLow:boolean,prefHigh:boolean}',
				},
				[6] = {
					['name'] = 'primaryTarget',
					['type'] = '{hp:number,id:number,found:boolean}',
				},
				[7] = {
					['name'] = 'fallbackTarget',
					['type'] = '{hp:number,id:number,name:string}',
				},
			},
		},
		['Strings.PadString'] = {
			['ret'] = 'string',
			['desc'] = 'Pads a string to a specified length with a given character.',
			['params'] = {
				[1] = {
					['name'] = 'string',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'len',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'padFront',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'padChar',
					['type'] = 'string?',
				},
			},
		},
		['Casting.SelfBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Delegates to LocalBuffCheck after resolving the spell rank via GetUseableSpellId. Checks blocked list, buff/song window presence, and stacking including trigger spells.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Casting.AAReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Verifies AltAbilityReady is true for the named AA and then runs CastCheck against the AA\'s associated spell to confirm mana/endurance/movement/control conditions are met.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Targeting.BigHealsNeeded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s HP% is below the BigHealPoint config threshold.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|groupmember',
				},
			},
		},
		['Casting.PeerBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Complex buff check that will check for presence and stacking of the buff (and any triggers) on a DanNet peer.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn|MQCharacter?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean|nil',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Config.GetMainOpacity'] = {
			['ret'] = 'number',
			['params'] = {},
		},
		['Combat.ShouldDoCamp'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if camp return logic should run this frame.',
			['params'] = {},
		},
		['Core.OnEMU'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if running on an EMU (emulator) MacroQuest build.',
			['params'] = {},
		},
		['Targeting.GetTargetName'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the raw name of target, or current target\'s name if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget?',
				},
			},
		},
		['Tables.ConcatTables'] = {
			['ret'] = 'table',
			['desc'] = 'Merges one or more sequential tables into a new flat array.',
			['params'] = {
				[1] = {
					['name'] = '...',
					['type'] = 'table',
				},
			},
		},
		['Targeting.MainHealsNeeded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s HP% is below the MainHealPoint config threshold.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|groupmember',
				},
			},
		},
		['Targeting.TargetIsType'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s type matches type (case-insensitive).',
			['params'] = {
				[1] = {
					['name'] = 'type',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|groupmember|MQTarget?',
				},
			},
		},
		['Config.ZoneRegistrySetSubFlag'] = {
			['desc'] = 'Sets a sub-flag inside a group (\'resists\' or \'immunities\') on a zone registry entry.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'group',
					['type'] = 'string',
				},
				[4] = {
					['name'] = 'key',
					['type'] = 'string',
				},
				[5] = {
					['name'] = 'value',
					['type'] = 'boolean',
				},
				[6] = {
					['name'] = 'zoneKey',
					['type'] = 'string?',
				},
			},
		},
		['Config.ZoneListAdd'] = {
			['desc'] = 'Adds the given name to a zone-keyed list for the current (or specified) zone. Storage shape: list[zoneShort] = { "Name 1", ... }. Silent on duplicates.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'zoneKey',
					['type'] = 'string?',
				},
			},
		},
		['Core.OnLaz'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the current server is Project Lazarus.',
			['params'] = {},
		},
		['Targeting.GetTargetCleanName'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the clean (surname-stripped) name of target, or current target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn?',
				},
			},
		},
		['Config.ListAdd'] = {
			['desc'] = 'Adds the given name to the Assist List.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string:',
				},
			},
		},
		['Targeting.LightHealsNeeded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s HP% is below the LightHealPoint config threshold.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|groupmember',
				},
			},
		},
		['Config.ResolveDefaults'] = {
			['ret'] = 'table,',
			['desc'] = 'Resolves the default values for a given settings table. This function takes a table of default values and a table of settings, and ensures that any missing settings are filled in with the default values.',
			['params'] = {
				[1] = {
					['name'] = 'defaults',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'settings',
					['type'] = 'table',
				},
			},
		},
		['Casting.AbilityReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Verifies Me.AbilityReady is true for the named combat ability, then confirms the target is within maximum melee range.',
			['params'] = {
				[1] = {
					['name'] = 'abilityName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|nil',
				},
			},
		},
		['Targeting.GroupedWithTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target is a member of the player\'s current group.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Combat.MercEngage'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the mercenary should engage the current auto target.',
			['params'] = {},
		},
		['Targeting.GetTargetAggroPct'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the aggro percentage the player has on the current in-game target.',
			['params'] = {},
		},
		['Config.HaveSetting'] = {
			['ret'] = 'boolean',
			['desc'] = 'Retrieves if a specified setting exists.',
			['params'] = {
				[1] = {
					['name'] = 'setting',
					['type'] = 'string',
				},
			},
		},
		['Targeting.GroupHealsNeeded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if at least GroupInjureCnt members are below GroupHealPoint.',
			['params'] = {},
		},
		['Config.GetModuleSettings'] = {
			['ret'] = 'table',
			['desc'] = 'Returns the full effective settings table for a module (db values + temp overrides).',
			['params'] = {
				[1] = {
					['name'] = 'module',
					['type'] = 'string',
				},
			},
		},
		['Config.GetUsageText'] = {
			['ret'] = 'string',
			['params'] = {
				[1] = {
					['name'] = 'config',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'showUsageText',
					['type'] = 'boolean',
				},
				[3] = {
					['name'] = 'defaults',
					['type'] = 'table',
				},
			},
		},
		['Casting.SelfBuffItemCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gets the clicky spell via GetClickySpell, then delegates to LocalBuffCheck to confirm not blocked, not present, and stacks.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
			},
		},
		['Core.IsWarden'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if a Ward of Might buff is active.',
			['params'] = {},
		},
		['Comms.HandleAnnounce'] = {
			['desc'] = 'Sends an announcement via /gsay or /rsay (when in a raid and AnnounceToRaidIfInRaid is set) and/or DanNet group channel, then logs it at debug level. Color codes are stripped for chat.',
			['params'] = {
				[1] = {
					['name'] = 'msg',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'sendGroup',
					['type'] = 'boolean',
				},
				[3] = {
					['name'] = 'sendDan',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'AnnounceToRaidIfInRaid',
					['type'] = 'boolean',
				},
			},
		},
		['Comms.PrintGroupMessage'] = {
			['desc'] = 'Sends msg to the group\'s DanNet channel via /dgt, scoped to the current server and group leader to avoid cross-group bleed.',
			['params'] = {
				[1] = {
					['name'] = 'msg',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Combat.ProcessXTarget'] = {
			['ret'] = 'number|nil',
			['desc'] = 'Evaluates a single XTarget candidate and updates primaryTarget/fallbackTarget buckets.',
			['params'] = {
				[1] = {
					['name'] = 'xtSpawn',
					['type'] = 'xtarget',
				},
				[2] = {
					['name'] = 'radius',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'namedPref',
					['type'] = '{prefNamed:boolean,prefTrash:boolean}',
				},
				[4] = {
					['name'] = 'hpPref',
					['type'] = '{prefLow:boolean,prefHigh:boolean}',
				},
				[5] = {
					['name'] = 'immediate',
					['type'] = 'boolean',
				},
				[6] = {
					['name'] = 'primaryTarget',
					['type'] = '{hp:number,id:number,found:boolean}',
				},
				[7] = {
					['name'] = 'fallbackTarget',
					['type'] = '{hp:number,id:number,name:string}',
				},
				[8] = {
					['name'] = 'aggroScan',
					['type'] = 'boolean',
				},
				[9] = {
					['name'] = 'myLevel',
					['type'] = 'number',
				},
			},
		},
		['Casting.LocalPetBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Complex buff check that will check for presence and stacking of the buff (and any triggers) on the PC or the PC\'s pet.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean|nil',
				},
				[3] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Comms.ValidatePeers'] = {
			['desc'] = 'Removes peers whose last heartbeat is older than timeout seconds from the Peers set, PeersHeartbeats, and PeersToServerNameMap.',
			['params'] = {
				[1] = {
					['name'] = 'timeout',
					['type'] = 'number',
				},
			},
		},
		['Ui.RenderOption'] = {
			['ret'] = 'boolean',
			['desc'] = 'Renders a typed config option widget (Combo, Toggle, Color, number, etc.).   "ClickyItem", "ClickyItemWithConditions", "Custom", "SpellSlot", "ImVec2".',
			['params'] = {
				[1] = {
					['name'] = 'type',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'setting',
					['type'] = 'any',
				},
				[3] = {
					['name'] = 'id',
					['type'] = 'string',
				},
				[4] = {
					['name'] = 'requiresLoadoutChange',
					['type'] = 'boolean?',
				},
				[5] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Comms.GetPeers'] = {
			['ret'] = 'table',
			['desc'] = 'Returns the list of active peer keys. When includeSelf is false, the local peer\'s own key is excluded from the result.',
			['params'] = {
				[1] = {
					['name'] = 'includeSelf',
					['type'] = 'boolean',
				},
			},
		},
		['Casting.ItemReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks ItemHasClicky, Me.ItemReady (off cooldown), required level, movement (exempt for bards or 0-cast-time clickies), and control state (stunned/feared/charmed/mezzed).',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
			},
		},
		['Core.DoCmd'] = {
			['desc'] = 'Formats and executes an MQ command, logging it at debug level.',
			['params'] = {
				[1] = {
					['name'] = 'cmd',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Comms.IsValidPeer'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the peer key exists in the active Peers set.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
			},
		},
		['Comms.GetPeerHeartbeatByName'] = {
			['ret'] = 'table',
			['desc'] = 'Looks up a heartbeat by character name by constructing the peer key via GetPeerName, then returns the cached heartbeat or {}.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Comms.UpdatePeerHeartbeat'] = {
			['desc'] = 'Registers or refreshes a peer: adds the key to the Peers set, updates PeersToServerNameMap, normalises nil buff/song/blocked tables to {}, stores the heartbeat with a timestamp, and processes any incoming toasts from the peer.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'data',
					['type'] = 'table',
				},
			},
		},
		['Casting.OkayToPetBuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns false immediately if the DoPet setting is off, otherwise delegates to CheckOkayToBuff which verifies the player is visible, not in combat, stationary long enough, and not critically low on mana.',
			['params'] = {},
		},
		['Targeting.DiffXTHaterIDs'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if any current XTarget hater ID is not in t (new hater appeared).',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'number[]',
				},
				[2] = {
					['name'] = 'printDebug',
					['type'] = 'boolean?',
				},
			},
		},
		['Core.GetMainAssistPctMana'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the main assist\'s current mana percentage, checking group, raid, actors heartbeat, DanNet, and spawn TLO in order.',
			['params'] = {},
		},
		['Tables._compareValues'] = {
			['ret'] = 'boolean',
			['desc'] = 'Compares two scalar or table values, printing a diff on mismatch.',
			['params'] = {
				[1] = {
					['name'] = 'v1',
					['type'] = 'any',
				},
				[2] = {
					['name'] = 'v2',
					['type'] = 'any',
				},
			},
		},
		['Core.DoGroupCmd'] = {
			['desc'] = 'Broadcasts cmd to all group members in the same zone via /dga.',
			['params'] = {
				[1] = {
					['name'] = 'cmd',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Targeting.CheckForAggroTargetID'] = {
			['ret'] = 'number[]',
			['desc'] = 'Returns {AggroTargetID} if AggroTargetID is non-zero, else {}.',
			['params'] = {},
		},
		['Casting.GroupLowManaCount'] = {
			['ret'] = 'number',
			['desc'] = 'Tallies group members below the mana threshold. Adds the player on EMU servers where Group.LowMana excludes the local PC.',
			['params'] = {
				[1] = {
					['name'] = 'percent',
					['type'] = 'number?',
				},
			},
		},
		['Targeting.GetTargetType'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the spawn type string of target (e.g. "PC", "NPC"), or "" if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|MQTarget|groupmember?',
				},
			},
		},
		['Core.GetMainAssistSpawn'] = {
			['ret'] = 'MQSpawn',
			['desc'] = 'Returns the spawn object for the configured main assist character.',
			['params'] = {},
		},
		['Casting.WaitGlobalCoolDown'] = {
			['desc'] = 'Polls Me.SpellInCooldown every 100 ms until the global spell cooldown (the "gem lockout" between casts) has cleared, processing events each iteration to keep the system responsive.',
			['params'] = {
				[1] = {
					['name'] = 'logPrefix',
					['type'] = 'string|nil:',
				},
			},
		},
		['Casting.WaitCastReady'] = {
			['desc'] = 'Polls Me.SpellReady every 1 ms until the spell\'s gem timer has cleared or maxWait (ms) expires; aborts early if combat begins (unless ignoreCombat is true) or if the spell leaves the player\'s book due to a persona change. Adds a ping-scaled delay after the spell becomes ready to account for server lag.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'maxWait',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'ignoreCombat?',
					['type'] = 'boolean',
				},
			},
		},
		['ItemManager.BandolierSwap'] = {
			['desc'] = 'Swaps the current bandolier set to the one specified by the index name.',
			['params'] = {
				[1] = {
					['name'] = 'indexName',
					['type'] = 'string',
				},
			},
		},
		['Casting.NoDiscActive'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks whether the disc window is idle (Me.ActiveDisc has no ID).',
			['params'] = {},
		},
		['Casting.CheckOkayToBuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Core gate for OkayToBuff/OkayToPetBuff: checks visibility, no XT haters or auto-target, stationary long enough (BuffWaitMoveTimer), and casters above 10% mana.',
			['params'] = {},
		},
		['Core.DoGroupOrRaidCmd'] = {
			['desc'] = 'Broadcasts cmd to raid or group members in the same zone via /dga. Uses raid leader if in a raid, group leader otherwise.',
			['params'] = {
				[1] = {
					['name'] = 'cmd',
					['type'] = 'string',
				},
				[2] = {
					['name'] = '...',
					['type'] = 'any',
				},
			},
		},
		['Targeting.BigGroupHealsNeeded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if at least GroupInjureCnt members are below BigHealPoint.',
			['params'] = {},
		},
		['Targeting.IsTempPet'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if spawn\'s surname contains "\'s Pet", "`s Pet", or "Doppelganger", indicating it is a temporary summoned pet rather than a proper mob.',
			['params'] = {
				[1] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Combat.CombatCampCheck'] = {
			['desc'] = 'Navigates back to camp during combat if ReturnToCamp is enabled and we are outside the camp radius.',
			['params'] = {
				[1] = {
					['name'] = 'tempConfig',
					['type'] = 'table',
				},
			},
		},
		['Casting.SlowImmuneTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Delegates to the Class module\'s TargetIsImmune check for "Slow".',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Combat.DoCombatActions'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if combat actions should be performed this frame.',
			['params'] = {},
		},
		['Targeting.GetAutoTargetAggroPct'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the aggro percentage the player has on AutoTargetID, checking the current target and all XTargets to find it.',
			['params'] = {},
		},
		['Casting.PetBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Delegates to LocalPetBuffCheck after resolving the spell rank via GetUseableSpellId. Checks pet blocked list, pet buff window, and stacking including trigger spells.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Casting.CastCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Shared pre-cast gate used by SpellReady, SongReady, DiscReady, and AAReady. Checks casting window, movement, mana/endurance (adjusted for med regen ticks), and control state.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'bAllowMove',
					['type'] = 'boolean?',
				},
			},
		},
		['Core.GetGroupMainAssistID'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the spawn ID of the group\'s designated main assist.',
			['params'] = {},
		},
		['Targeting.SetForceBurn'] = {
			['desc'] = 'Marks targetId (or current target if 0) as the force-burn target and announces it to group/raid per config settings.',
			['params'] = {
				[1] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Combat.FindBestAutoTarget'] = {
			['desc'] = 'Finds the best auto target and sets Globals.AutoTargetID, then targets it if DoAutoTarget is enabled.',
			['params'] = {
				[1] = {
					['name'] = 'validateFn',
					['type'] = 'function?',
				},
			},
		},
		['Casting.SnareImmuneTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Delegates to the Class module\'s TargetIsImmune check for "Snare".',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Targeting.GetTargetDistance'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the 3D distance to target, or current target distance if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|MQTarget|string|nil?',
				},
			},
		},
		['Comms.GetPeerName'] = {
			['ret'] = 'string',
			['desc'] = 'Returns "Name (Server)" for use as the actor peer key. Uppercases the first letter of the server name for Live compatibility.',
			['params'] = {
				[1] = {
					['name'] = 'peerName',
					['type'] = 'string?',
				},
				[2] = {
					['name'] = 'peerServer',
					['type'] = 'string?',
				},
			},
		},
		['Core.CheckPlugins'] = {
			['desc'] = 'Loads any plugins in t that are not currently loaded. When reloadingUnloaded is true, logs that the plugin is being reloaded.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'string[]',
				},
				[2] = {
					['name'] = 'reloadingUnloaded',
					['type'] = 'boolean?',
				},
			},
		},
		['Casting.OkayToDebuff'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gates debuffing on aggro threshold, ManaToDebuff, and the debuff policy (NamedDebuff or MobDebuff) vs. target con color.',
			['params'] = {
				[1] = {
					['name'] = 'bIgnoreAggro',
					['type'] = 'boolean?',
				},
			},
		},
		['Combat.FindWorstHurtManaGroupMember'] = {
			['ret'] = 'number',
			['desc'] = 'Finds the group member with the lowest mana percentage.',
			['params'] = {
				[1] = {
					['name'] = 'minMana',
					['type'] = 'number',
				},
			},
		},
		['Casting.GetBuffableRaidIDs'] = {
			['ret'] = 'table',
			['desc'] = 'Builds a deduplicated buff-eligible ID list from raid sources: player, group members, actor peers who are raid members and their pets (DoActorPetBuffs), and assist list. Aborts on nearby corpse.',
			['params'] = {},
		},
		['Casting.StunImmuneTarget'] = {
			['ret'] = 'boolean',
			['desc'] = 'Delegates to the Class module\'s TargetIsImmune check for "Stun".',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Combat.MATargetScan'] = {
			['ret'] = 'number',
			['desc'] = 'Scans XTargets and nearby spawns to select the best auto target based on current preferences.',
			['params'] = {
				[1] = {
					['name'] = 'radius',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'zradius',
					['type'] = 'number',
				},
			},
		},
		['Combat.EngageTarget'] = {
			['desc'] = 'Engages the target specified by the given autoTargetId.',
			['params'] = {
				[1] = {
					['name'] = 'autoTargetId',
					['type'] = 'number',
				},
			},
		},
		['Targeting.HateToolsNeeded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if hate tools should fire: aggro below 100%, secondary aggro above 60%, or the auto target is a named mob.',
			['params'] = {},
		},
		['Targeting.GetTargetDistanceZ'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the vertical (Z-axis) distance to target, or current target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn?',
				},
			},
		},
		['Casting.GambitCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Resolves the \'GambitSpell\' action map entry and checks whether that spell\'s buff is currently active in the player\'s buff or song window — used by Wizard to gate gambit-dependent nukes.',
			['params'] = {},
		},
		['Casting.PetBuffItemCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gets the clicky spell via GetClickySpell, then delegates to LocalPetBuffCheck to confirm not blocked on pet, not present, stacks.',
			['params'] = {
				[1] = {
					['name'] = 'itemName',
					['type'] = 'string',
				},
			},
		},
		['Targeting.IsNamed'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if spawn qualifies as a named mob per the Named module, ignoring spawns below the NamedMinLevel config setting.',
			['params'] = {
				[1] = {
					['name'] = 'spawn',
					['type'] = 'MQSpawn',
				},
			},
		},
		['Targeting.TargetNotStunned'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the auto target exists and is not currently stunned.',
			['params'] = {},
		},
		['Core.OnMight'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the current server is EQ Might or Project Might.',
			['params'] = {},
		},
		['Casting.GroupBuffAACheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gates on CanUseAA, then delegates to ResolveBuffCheck using the AA\'s spell ID. ResolveBuffCheck picks the best method based on the target (local, pet, actor heartbeat, DanNet, target-change).',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean?',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean?',
				},
			},
		},
		['Comms.IsLocalCurrent'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the given char/server/class identifies the local current character.',
			['params'] = {
				[1] = {
					['name'] = 'charName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'server',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'class',
					['type'] = 'string',
				},
			},
		},
		['Core.GetMainAssistId'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the spawn ID of the configured main assist character.',
			['params'] = {},
		},
		['Core.UnCheckPlugins'] = {
			['ret'] = 'string[]',
			['desc'] = 'Unloads any plugins in t that are currently loaded (conflict removal). Returns the list of plugins that were actually unloaded.',
			['params'] = {
				[1] = {
					['name'] = 't',
					['type'] = 'string[]',
				},
			},
		},
		['Targeting.LostAutoTargetAggro'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if there is an auto target on the current in-game target and the player\'s aggro percentage is below 100.',
			['params'] = {},
		},
		['Casting.OkayToNuke'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gates nuking on aggro threshold (AggroCheckOkay) and mana above ManaToNuke. Burn state bypasses the mana gate unless restricted.',
			['params'] = {
				[1] = {
					['name'] = 'bRestrictBurns',
					['type'] = 'boolean?',
				},
			},
		},
		['Casting.SelfBuffAACheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gates on CanUseAA, then delegates to LocalBuffCheck using the AA\'s spell ID to confirm not blocked, not present, and stacks.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Targeting.GetAutoTarget'] = {
			['ret'] = 'MQSpawn',
			['desc'] = 'Returns the spawn object for the current auto target ID.',
			['params'] = {},
		},
		['Casting.PetBuffAACheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Gates on CanUseAA, then delegates to LocalPetBuffCheck using the AA\'s spell ID to confirm not blocked on pet, not present, stacks.',
			['params'] = {
				[1] = {
					['name'] = 'aaName',
					['type'] = 'string',
				},
			},
		},
		['Comms.IsCharRunning'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the given char/server/class is the local current character or a networked peer currently running RGMercs on that class.',
			['params'] = {
				[1] = {
					['name'] = 'charName',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'server',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'class',
					['type'] = 'string',
				},
			},
		},
		['Casting.ShouldSkipElement'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if a spell of the given element should be skipped against this spawn. Only fires when targetId matches the current auto-target. Combines the global Skip<Element>Spells toggle with the per-mob elemental immunity flag from the Named List. Buffs, heals, and group abilities against non-auto-target spawns are never affected.',
			['params'] = {
				[1] = {
					['name'] = 'element',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'targetId',
					['type'] = 'number',
				},
			},
		},
		['Casting.SpellLoaded'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the spell\'s ranked name is currently memorized in any gem slot on the spellbar (Me.Gem returns non-nil for that name).',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Casting.ActorBuffCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Complex buff check that will check for presence and stacking of the buff (and any triggers) on an actor peer.',
			['params'] = {
				[1] = {
					['name'] = 'spellId',
					['type'] = 'integer',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget|MQSpawn|MQCharacter?',
				},
				[3] = {
					['name'] = 'skipBlockCheck',
					['type'] = 'boolean|nil',
				},
				[4] = {
					['name'] = 'skipTriggerCheck',
					['type'] = 'boolean|nil',
				},
			},
		},
		['Targeting.AggroCheckOkay'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if it is safe to perform actions from an aggro standpoint — either aggro throttling is off, the player is the tank, or aggro is below MobMaxAggro.',
			['params'] = {},
		},
		['Casting.AmIBuffable'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns false if the player has a nearby corpse (within 100/50 units) and BuffRezables is not set — used to abort buff rotations when the player is waiting for a rez, since buffs applied to a corpse state are wasted.',
			['params'] = {},
		},
		['Combat.FindWorstHurtGroupMember'] = {
			['ret'] = 'number',
			['desc'] = 'Finds the group member with the lowest health percentage (including ourselves or group pets)',
			['params'] = {
				[1] = {
					['name'] = 'minHPs',
					['type'] = 'number',
				},
			},
		},
		['Casting.OkayToRez'] = {
			['ret'] = 'boolean',
			['desc'] = 'Targets and /consider\'s the corpse (EMU only, ConCorpseForRez) to check for prior rez, waits up to 1s for con event. Summons corpse via /corpse if beyond 25 units.',
			['params'] = {
				[1] = {
					['name'] = 'corpseId',
					['type'] = 'number',
				},
			},
		},
		['Casting.WaitForReady'] = {
			['desc'] = 'Generic blocking wait: polls pollFn every ~20 ms (pumping events to stay responsive) until it returns true, abortFn returns true, or maxWaitMs elapses; ability-agnostic sibling to WaitCastReady for callers needing a custom ready/abort condition.',
			['params'] = {
				[1] = {
					['name'] = 'pollFn',
					['type'] = 'fun():boolean',
				},
				[2] = {
					['name'] = 'maxWaitMs',
					['type'] = 'number',
				},
				[3] = {
					['name'] = 'abortFn',
					['type'] = 'fun():boolean|nil',
				},
			},
		},
		['Targeting.InSpellRange'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target is within the spell\'s effective range (MyRange, AERange, or 250 as fallback).',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn|MQTarget|string|nil?',
				},
			},
		},
		['Ui.RenderSettingsButton'] = {
			['desc'] = 'Renders a small settings gear button that opens the options UI for moduleName.',
			['params'] = {
				[1] = {
					['name'] = 'moduleName',
					['type'] = 'string',
				},
			},
		},
		['Casting.CastReady'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks if the spell is ready to cast (not in refresh, no gem timer).',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Targeting.GetTargetAggressive'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns the aggressive flag of target, or the current in-game target if nil.',
			['params'] = {
				[1] = {
					['name'] = 'target',
					['type'] = 'MQTarget?',
				},
			},
		},
		['Casting.IsGroupSpell'] = {
			['ret'] = 'boolean',
			['desc'] = 'Checks if a spell target type is a group-affecting type (group buffs, AE PC buffs, etc.)',
			['params'] = {
				[1] = {
					['name'] = 'targetType',
					['type'] = 'string|nil',
				},
			},
		},
		['Casting.NoLevZone'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if TempSettings flags the current zone as no-lev, used to gate levitation buff casting.',
			['params'] = {},
		},
		['Config.ZoneRegistryClearFlag'] = {
			['desc'] = 'Clears a flag on a zone registry entry. Early-returns (no SetSetting) when the entry doesn\'t exist, avoiding redundant OnChange/broadcast cycles on no-op clears. For group=\'named\', the named flag is cleared. For other groups, subKey must be provided.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'listName',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'group',
					['type'] = 'string',
				},
				[4] = {
					['name'] = 'subKey',
					['type'] = 'string?',
				},
				[5] = {
					['name'] = 'zoneKey',
					['type'] = 'string?',
				},
			},
		},
		['Comms.GetNameAndServerFromPeer'] = {
			['ret'] = 'string|nil',
			['desc'] = 'Looks up a peer key in PeersToServerNameMap and returns its character name and server name as separate values.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
			},
		},
		['Targeting.TargetClassIs'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if target\'s class short name is in classTable (string or array).',
			['params'] = {
				[1] = {
					['name'] = 'classTable',
					['type'] = 'string|table',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQTarget',
				},
			},
		},
		['Casting.GetBuffableIDs'] = {
			['ret'] = 'table',
			['desc'] = 'Dispatches to GetBuffableInZoneIDs, GetBuffableRaidIDs, or GetBuffableGroupIDs based on the ActorBuffScope setting.',
			['params'] = {},
		},
		['Casting.HasNearbyCorpse'] = {
			['ret'] = 'boolean',
			['desc'] = 'SpawnCount search for a PC corpse within 100 horizontal and 50 vertical units of the player.',
			['params'] = {
				[1] = {
					['name'] = 'name',
					['type'] = 'string',
				},
			},
		},
		['Targeting.CheckForAutoTargetID'] = {
			['ret'] = 'number[]',
			['desc'] = 'Returns {AutoTargetID} if AutoTargetID matches the in-game target, else {}. Used by rotation conditions that require being on the right target.',
			['params'] = {},
		},
		['Ui.RenderPopAndSettings'] = {
			['ret'] = 'number',
			['desc'] = 'Renders aligned pop-out and settings buttons in the top-right of the window.',
			['params'] = {
				[1] = {
					['name'] = 'moduleName',
					['type'] = 'string',
				},
			},
		},
		['Core.GetMainAssistPctHPs'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the main assist\'s current HP percentage, checking group, raid, actors heartbeat, DanNet, and spawn TLO in order.',
			['params'] = {},
		},
		['Casting.GetUseableSpellId'] = {
			['ret'] = 'number',
			['desc'] = 'Return the proper spell ID based on subscription level and "Spell Unlocker" purchase',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
			},
		},
		['Combat.AutoCampCheck'] = {
			['desc'] = 'Navigates back to camp if ReturnToCamp is enabled and we are outside the camp radius.',
			['params'] = {
				[1] = {
					['name'] = 'tempConfig',
					['type'] = 'table',
				},
				[2] = {
					['name'] = 'bCalledFromInsideEvent?',
					['type'] = 'boolean',
				},
			},
		},
		['Casting.DotSpellCheck'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns false early if target HP is low (MobHasLowHP). Otherwise resolves spell rank and delegates to TargetBuffCheck with target-change and duplicate-from-self checks enabled.',
			['params'] = {
				[1] = {
					['name'] = 'spell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'target',
					['type'] = 'MQSpawn?',
				},
			},
		},
		['Core.GetGroupMainAssistName'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the clean name of the group\'s designated main assist.',
			['params'] = {},
		},
		['Casting.UseDisc'] = {
			['ret'] = 'boolean|nil',
			['desc'] = 'Activates a discipline on a target.',
			['params'] = {
				[1] = {
					['name'] = 'discSpell',
					['type'] = 'MQSpell',
				},
				[2] = {
					['name'] = 'targetId?',
					['type'] = 'number',
				},
			},
		},
		['Casting.MemorizeSpell'] = {
			['ret'] = 'boolean|nil',
			['desc'] = 'Issues /memspell for the given gem slot and polls until the slot shows the spell (and the gem is ready if waitSpellReady is true) or maxWait (ms) expires. Aborts early if aggro is gained, the player starts moving or casting, or the spell leaves the book due to a persona change. If AggressivelyMemorizeSpells is set and the gem stays empty past the configured timer, resends the /memspell command.',
			['params'] = {
				[1] = {
					['name'] = 'gem',
					['type'] = 'number',
				},
				[2] = {
					['name'] = 'spell',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'waitSpellReady',
					['type'] = 'boolean',
				},
				[4] = {
					['name'] = 'maxWait',
					['type'] = 'number',
				},
			},
		},
		['Comms.GetNameFromPeer'] = {
			['ret'] = 'string|nil',
			['desc'] = 'Looks up a peer key in PeersToServerNameMap and returns only the character name portion.',
			['params'] = {
				[1] = {
					['name'] = 'peer',
					['type'] = 'string',
				},
			},
		},
		['Ui.RenderOptionToggle'] = {
			['ret'] = 'boolean:',
			['desc'] = 'Renders a toggle option in the UI.',
			['params'] = {
				[1] = {
					['name'] = 'id',
					['type'] = 'string:',
				},
				[2] = {
					['name'] = 'text',
					['type'] = 'string:',
				},
				[3] = {
					['name'] = 'on',
					['type'] = 'boolean:',
				},
				[4] = {
					['name'] = 'center_vertically',
					['type'] = 'boolean?:',
				},
			},
		},
		['Casting.GetLastCastResultName'] = {
			['ret'] = 'string',
			['desc'] = 'Retrieves the name of the last cast result.',
			['params'] = {},
		},
		['Combat.GetCombatState'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the current live combat state based on XTarget hater count.',
			['params'] = {},
		},
		['Combat.FindWorstHurtXT'] = {
			['ret'] = 'number',
			['desc'] = 'Finds the entity with the worst health condition that meets the minimum HP requirement.',
			['params'] = {
				[1] = {
					['name'] = 'minHPs',
					['type'] = 'number',
				},
			},
		},
		['Casting.SetLastCastResult'] = {
			['desc'] = 'Sets the result of the last cast operation.',
			['params'] = {
				[1] = {
					['name'] = 'result',
					['type'] = 'number',
				},
			},
		},
		['Combat.FindWorstHurtMana'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the spawn id of the group member or heal list target with the lowest mana below minMana.',
			['params'] = {
				[1] = {
					['name'] = 'minMana',
					['type'] = 'number',
				},
			},
		},
		['Core.GetRaidMainAssistID'] = {
			['ret'] = 'number',
			['desc'] = 'Returns the spawn ID of the Nth raid main assist (1-indexed).',
			['params'] = {
				[1] = {
					['name'] = 'assistNumber',
					['type'] = 'number',
				},
			},
		},
		['Core.IsModeActive'] = {
			['ret'] = 'boolean',
			['desc'] = 'Returns true if the named class-module mode is currently active.',
			['params'] = {
				[1] = {
					['name'] = 'mode',
					['type'] = 'string',
				},
			},
		},
		['Casting.GetLastCastResultId'] = {
			['ret'] = 'number',
			['desc'] = 'Retrieves the ID of the last cast result.',
			['params'] = {},
		},
		['Combat.GetCachedCombatState'] = {
			['ret'] = 'string',
			['desc'] = 'Returns the cached combat state from the last main loop frame.',
			['params'] = {},
		},
		['Comms.BroadcastMessage'] = {
			['desc'] = 'Sends an actor broadcast to all MQ instances on the network.',
			['params'] = {
				[1] = {
					['name'] = 'module',
					['type'] = 'string',
				},
				[2] = {
					['name'] = 'event',
					['type'] = 'string',
				},
				[3] = {
					['name'] = 'data',
					['type'] = 'table?',
				},
			},
		},
	},
}