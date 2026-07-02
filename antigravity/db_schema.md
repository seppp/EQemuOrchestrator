# Database Schema Documentation
This document provides the database schema (table structures) for the key tables used in this EQEmulator administration and bot scripting project.

## Table of Contents
- [account](#account)
- [bot_data](#bot_data)
- [bot_inventories](#bot_inventories)
- [bot_spell_casting_chances](#bot_spell_casting_chances)
- [bot_spells_entries](#bot_spells_entries)
- [character_alternate_abilities](#character_alternate_abilities)
- [character_currency](#character_currency)
- [character_data](#character_data)
- [inventory](#inventory)
- [items](#items)
- [rule_values](#rule_values)
- [spells_new](#spells_new)
- [zone](#zone)

## account
Structure of the `account` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) | NO | PRI | NULL | auto_increment |
| **name** | varchar(30) | NO | MUL |  |  |
| **charname** | varchar(64) | NO |  |  |  |
| **auto_login_charname** | varchar(64) | NO |  |  |  |
| **sharedplat** | int(11) unsigned | NO |  | 0 |  |
| **password** | varchar(50) | NO |  |  |  |
| **status** | int(5) | NO |  | 0 |  |
| **ls_id** | varchar(64) | YES | MUL | eqemu |  |
| **lsaccount_id** | int(11) unsigned | YES |  | NULL |  |
| **gmspeed** | tinyint(3) unsigned | NO |  | 0 |  |
| **invulnerable** | tinyint(4) | YES |  | 0 |  |
| **flymode** | tinyint(4) | YES |  | 0 |  |
| **ignore_tells** | tinyint(4) | YES |  | 0 |  |
| **revoked** | tinyint(3) unsigned | NO |  | 0 |  |
| **karma** | int(5) unsigned | NO |  | 0 |  |
| **minilogin_ip** | varchar(32) | NO |  |  |  |
| **hideme** | tinyint(4) | NO |  | 0 |  |
| **rulesflag** | tinyint(1) unsigned | NO |  | 0 |  |
| **suspendeduntil** | datetime | YES |  | NULL |  |
| **time_creation** | int(10) unsigned | NO |  | 0 |  |
| **ban_reason** | text | YES |  | NULL |  |
| **suspend_reason** | text | YES |  | NULL |  |
| **crc_eqgame** | text | YES |  | NULL |  |
| **crc_skillcaps** | text | YES |  | NULL |  |
| **crc_basedata** | text | YES |  | NULL |  |

**Approximate Row Count:** 13

---

## bot_data
Structure of the `bot_data` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **bot_id** | int(11) unsigned | NO | PRI | NULL | auto_increment |
| **owner_id** | int(11) unsigned | NO |  | NULL |  |
| **spells_id** | int(11) unsigned | NO |  | 0 |  |
| **name** | varchar(64) | NO |  |  |  |
| **last_name** | varchar(64) | NO |  |  |  |
| **title** | varchar(32) | NO |  |  |  |
| **suffix** | varchar(32) | NO |  |  |  |
| **zone_id** | smallint(6) | NO |  | 0 |  |
| **gender** | tinyint(2) | NO |  | 0 |  |
| **race** | smallint(5) | NO |  | 0 |  |
| **class** | tinyint(2) | NO |  | 0 |  |
| **level** | tinyint(2) unsigned | NO |  | 0 |  |
| **deity** | int(11) unsigned | NO |  | 0 |  |
| **creation_day** | int(11) unsigned | NO |  | 0 |  |
| **last_spawn** | int(11) unsigned | NO |  | 0 |  |
| **time_spawned** | int(11) unsigned | NO |  | 0 |  |
| **size** | float | NO |  | 0 |  |
| **face** | int(10) | NO |  | 1 |  |
| **hair_color** | int(10) | NO |  | 1 |  |
| **hair_style** | int(10) | NO |  | 1 |  |
| **beard** | int(10) | NO |  | 0 |  |
| **beard_color** | int(10) | NO |  | 1 |  |
| **eye_color_1** | int(10) | NO |  | 1 |  |
| **eye_color_2** | int(10) | NO |  | 1 |  |
| **drakkin_heritage** | int(10) | NO |  | 0 |  |
| **drakkin_tattoo** | int(10) | NO |  | 0 |  |
| **drakkin_details** | int(10) | NO |  | 0 |  |
| **ac** | smallint(5) | NO |  | 0 |  |
| **atk** | mediumint(9) | NO |  | 0 |  |
| **hp** | int(11) | NO |  | 0 |  |
| **mana** | int(11) | NO |  | 0 |  |
| **str** | mediumint(8) | NO |  | 75 |  |
| **sta** | mediumint(8) | NO |  | 75 |  |
| **cha** | mediumint(8) | NO |  | 75 |  |
| **dex** | mediumint(8) | NO |  | 75 |  |
| **int** | mediumint(8) | NO |  | 75 |  |
| **agi** | mediumint(8) | NO |  | 75 |  |
| **wis** | mediumint(8) | NO |  | 75 |  |
| **extra_haste** | mediumint(8) | NO |  | 0 |  |
| **fire** | smallint(5) | NO |  | 0 |  |
| **cold** | smallint(5) | NO |  | 0 |  |
| **magic** | smallint(5) | NO |  | 0 |  |
| **poison** | smallint(5) | NO |  | 0 |  |
| **disease** | smallint(5) | NO |  | 0 |  |
| **corruption** | smallint(5) | NO |  | 0 |  |

**Approximate Row Count:** 5

---

## bot_inventories
Structure of the `bot_inventories` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **inventories_index** | int(10) unsigned | NO | PRI | NULL | auto_increment |
| **bot_id** | int(11) unsigned | NO | MUL | 0 |  |
| **slot_id** | mediumint(7) unsigned | NO |  | 0 |  |
| **item_id** | int(11) unsigned | YES |  | 0 |  |
| **inst_charges** | smallint(3) unsigned | YES |  | 0 |  |
| **inst_color** | int(11) unsigned | NO |  | 0 |  |
| **inst_no_drop** | tinyint(1) unsigned | NO |  | 0 |  |
| **inst_custom_data** | text | YES |  | NULL |  |
| **ornament_icon** | int(11) unsigned | NO |  | 0 |  |
| **ornament_id_file** | int(11) unsigned | NO |  | 0 |  |
| **ornament_hero_model** | int(11) | NO |  | 0 |  |
| **augment_1** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_2** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_3** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_4** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_5** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_6** | mediumint(7) unsigned | NO |  | 0 |  |

**Approximate Row Count:** 29

---

## bot_spell_casting_chances
Structure of the `bot_spell_casting_chances` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) | NO | PRI | NULL | auto_increment |
| **spell_type_index** | tinyint(3) unsigned | NO | MUL | 0 |  |
| **class_id** | tinyint(3) unsigned | NO |  | 0 |  |
| **stance_index** | tinyint(3) unsigned | NO |  | 0 |  |
| **nHSND_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pH_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pS_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHS_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pN_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHN_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pSN_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHSN_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pD_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHD_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pSD_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHSD_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pND_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHND_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pSND_value** | tinyint(3) unsigned | NO |  | 0 |  |
| **pHSND_value** | tinyint(3) unsigned | NO |  | 0 |  |

**Approximate Row Count:** 2465

---

## bot_spells_entries
Structure of the `bot_spells_entries` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) unsigned | NO | PRI | NULL | auto_increment |
| **npc_spells_id** | int(11) | NO |  | 0 |  |
| **spell_id** | smallint(5) unsigned | NO |  | 0 |  |
| **type** | int(10) unsigned | NO |  | 0 |  |
| **minlevel** | tinyint(3) unsigned | NO |  | 0 |  |
| **maxlevel** | tinyint(3) unsigned | NO |  | 255 |  |
| **manacost** | smallint(5) | NO |  | -1 |  |
| **recast_delay** | int(11) | NO |  | -1 |  |
| **priority** | smallint(5) | NO |  | 0 |  |
| **resist_adjust** | int(11) | NO |  | 0 |  |
| **min_hp** | smallint(5) | NO |  | 0 |  |
| **max_hp** | smallint(5) | NO |  | 0 |  |
| **bucket_name** | varchar(100) | NO |  |  |  |
| **bucket_value** | varchar(100) | NO |  |  |  |
| **bucket_comparison** | tinyint(3) unsigned | NO |  | 0 |  |

**Approximate Row Count:** 2840

---

## character_alternate_abilities
Structure of the `character_alternate_abilities` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) unsigned | NO | PRI | 0 |  |
| **aa_id** | smallint(11) unsigned | NO | PRI | 0 |  |
| **aa_value** | smallint(11) unsigned | NO |  | 0 |  |
| **charges** | smallint(11) unsigned | NO |  | 0 |  |

**Approximate Row Count:** 43

---

## character_currency
Structure of the `character_currency` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) unsigned | NO | PRI | 0 |  |
| **platinum** | int(11) unsigned | NO |  | 0 |  |
| **gold** | int(11) unsigned | NO |  | 0 |  |
| **silver** | int(11) unsigned | NO |  | 0 |  |
| **copper** | int(11) unsigned | NO |  | 0 |  |
| **platinum_bank** | int(11) unsigned | NO |  | 0 |  |
| **gold_bank** | int(11) unsigned | NO |  | 0 |  |
| **silver_bank** | int(11) unsigned | NO |  | 0 |  |
| **copper_bank** | int(11) unsigned | NO |  | 0 |  |
| **platinum_cursor** | int(11) unsigned | NO |  | 0 |  |
| **gold_cursor** | int(11) unsigned | NO |  | 0 |  |
| **silver_cursor** | int(11) unsigned | NO |  | 0 |  |
| **copper_cursor** | int(11) unsigned | NO |  | 0 |  |
| **radiant_crystals** | int(11) unsigned | NO |  | 0 |  |
| **career_radiant_crystals** | int(11) unsigned | NO |  | 0 |  |
| **ebon_crystals** | int(11) unsigned | NO |  | 0 |  |
| **career_ebon_crystals** | int(11) unsigned | NO |  | 0 |  |

**Approximate Row Count:** 3

---

## character_data
Structure of the `character_data` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) unsigned | NO | PRI | NULL | auto_increment |
| **account_id** | int(11) | NO | MUL | 0 |  |
| **name** | varchar(64) | NO | UNI |  |  |
| **last_name** | varchar(64) | NO |  |  |  |
| **title** | varchar(32) | NO |  |  |  |
| **suffix** | varchar(32) | NO |  |  |  |
| **zone_id** | int(11) unsigned | NO |  | 0 |  |
| **zone_instance** | int(11) unsigned | NO |  | 0 |  |
| **y** | float | NO |  | 0 |  |
| **x** | float | NO |  | 0 |  |
| **z** | float | NO |  | 0 |  |
| **heading** | float | NO |  | 0 |  |
| **gender** | tinyint(11) unsigned | NO |  | 0 |  |
| **race** | smallint(11) unsigned | NO |  | 0 |  |
| **class** | tinyint(11) unsigned | NO |  | 0 |  |
| **level** | int(11) unsigned | NO |  | 0 |  |
| **deity** | int(11) unsigned | NO |  | 0 |  |
| **birthday** | int(11) unsigned | NO |  | 0 |  |
| **last_login** | int(11) unsigned | NO |  | 0 |  |
| **time_played** | int(11) unsigned | NO |  | 0 |  |
| **level2** | tinyint(11) unsigned | NO |  | 0 |  |
| **anon** | tinyint(11) unsigned | NO |  | 0 |  |
| **gm** | tinyint(11) unsigned | NO |  | 0 |  |
| **face** | int(11) unsigned | NO |  | 0 |  |
| **hair_color** | tinyint(11) unsigned | NO |  | 0 |  |
| **hair_style** | tinyint(11) unsigned | NO |  | 0 |  |
| **beard** | tinyint(11) unsigned | NO |  | 0 |  |
| **beard_color** | tinyint(11) unsigned | NO |  | 0 |  |
| **eye_color_1** | tinyint(11) unsigned | NO |  | 0 |  |
| **eye_color_2** | tinyint(11) unsigned | NO |  | 0 |  |
| **drakkin_heritage** | int(11) unsigned | NO |  | 0 |  |
| **drakkin_tattoo** | int(11) unsigned | NO |  | 0 |  |
| **drakkin_details** | int(11) unsigned | NO |  | 0 |  |
| **ability_time_seconds** | tinyint(11) unsigned | NO |  | 0 |  |
| **ability_number** | tinyint(11) unsigned | NO |  | 0 |  |
| **ability_time_minutes** | tinyint(11) unsigned | NO |  | 0 |  |
| **ability_time_hours** | tinyint(11) unsigned | NO |  | 0 |  |
| **exp** | int(11) unsigned | NO |  | 0 |  |
| **exp_enabled** | tinyint(1) unsigned | NO |  | 1 |  |
| **aa_points_spent** | int(11) unsigned | NO |  | 0 |  |
| **aa_exp** | int(11) unsigned | NO |  | 0 |  |
| **aa_points** | int(11) unsigned | NO |  | 0 |  |
| **group_leadership_exp** | int(11) unsigned | NO |  | 0 |  |
| **raid_leadership_exp** | int(11) unsigned | NO |  | 0 |  |
| **group_leadership_points** | int(11) unsigned | NO |  | 0 |  |
| **raid_leadership_points** | int(11) unsigned | NO |  | 0 |  |
| **points** | int(11) unsigned | NO |  | 0 |  |
| **cur_hp** | int(11) unsigned | NO |  | 0 |  |
| **mana** | int(11) unsigned | NO |  | 0 |  |
| **endurance** | int(11) unsigned | NO |  | 0 |  |
| **intoxication** | int(11) unsigned | NO |  | 0 |  |
| **str** | int(11) unsigned | NO |  | 0 |  |
| **sta** | int(11) unsigned | NO |  | 0 |  |
| **cha** | int(11) unsigned | NO |  | 0 |  |
| **dex** | int(11) unsigned | NO |  | 0 |  |
| **int** | int(11) unsigned | NO |  | 0 |  |
| **agi** | int(11) unsigned | NO |  | 0 |  |
| **wis** | int(11) unsigned | NO |  | 0 |  |
| **extra_haste** | int(11) | NO |  | 0 |  |
| **zone_change_count** | int(11) unsigned | NO |  | 0 |  |
| **toxicity** | int(11) unsigned | NO |  | 0 |  |
| **hunger_level** | int(11) unsigned | NO |  | 0 |  |
| **thirst_level** | int(11) unsigned | NO |  | 0 |  |
| **ability_up** | int(11) unsigned | NO |  | 0 |  |
| **ldon_points_guk** | int(11) unsigned | NO |  | 0 |  |
| **ldon_points_mir** | int(11) unsigned | NO |  | 0 |  |
| **ldon_points_mmc** | int(11) unsigned | NO |  | 0 |  |
| **ldon_points_ruj** | int(11) unsigned | NO |  | 0 |  |
| **ldon_points_tak** | int(11) unsigned | NO |  | 0 |  |
| **ldon_points_available** | int(11) unsigned | NO |  | 0 |  |
| **tribute_time_remaining** | int(11) unsigned | NO |  | 0 |  |
| **career_tribute_points** | int(11) unsigned | NO |  | 0 |  |
| **tribute_points** | int(11) unsigned | NO |  | 0 |  |
| **tribute_active** | int(11) unsigned | NO |  | 0 |  |
| **pvp_status** | tinyint(11) unsigned | NO |  | 0 |  |
| **pvp_kills** | int(11) unsigned | NO |  | 0 |  |
| **pvp_deaths** | int(11) unsigned | NO |  | 0 |  |
| **pvp_current_points** | int(11) unsigned | NO |  | 0 |  |
| **pvp_career_points** | int(11) unsigned | NO |  | 0 |  |
| **pvp_best_kill_streak** | int(11) unsigned | NO |  | 0 |  |
| **pvp_worst_death_streak** | int(11) unsigned | NO |  | 0 |  |
| **pvp_current_kill_streak** | int(11) unsigned | NO |  | 0 |  |
| **pvp2** | int(11) unsigned | NO |  | 0 |  |
| **pvp_type** | int(11) unsigned | NO |  | 0 |  |
| **show_helm** | int(11) unsigned | NO |  | 0 |  |
| **group_auto_consent** | tinyint(11) unsigned | NO |  | 0 |  |
| **raid_auto_consent** | tinyint(11) unsigned | NO |  | 0 |  |
| **guild_auto_consent** | tinyint(11) unsigned | NO |  | 0 |  |
| **leadership_exp_on** | tinyint(11) unsigned | NO |  | 0 |  |
| **RestTimer** | int(11) unsigned | NO |  | 0 |  |
| **air_remaining** | int(11) unsigned | NO |  | 0 |  |
| **autosplit_enabled** | int(11) unsigned | NO |  | 0 |  |
| **lfp** | tinyint(1) unsigned | NO |  | 0 |  |
| **lfg** | tinyint(1) unsigned | NO |  | 0 |  |
| **mailkey** | char(16) | NO |  |  |  |
| **xtargets** | tinyint(3) unsigned | NO |  | 5 |  |
| **first_login** | int(11) unsigned | NO |  | 0 |  |
| **ingame** | tinyint(1) unsigned | NO |  | 0 |  |
| **e_aa_effects** | int(11) unsigned | NO |  | 0 |  |
| **e_percent_to_aa** | int(11) unsigned | NO |  | 0 |  |
| **e_expended_aa_spent** | int(11) unsigned | NO |  | 0 |  |
| **aa_points_spent_old** | int(11) unsigned | NO |  | 0 |  |
| **aa_points_old** | int(11) unsigned | NO |  | 0 |  |
| **e_last_invsnapshot** | int(11) unsigned | NO |  | 0 |  |
| **deleted_at** | datetime | YES |  | NULL |  |
| **illusion_block** | tinyint(11) unsigned | NO |  | 0 |  |

**Approximate Row Count:** 3

---

## inventory
Structure of the `inventory` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **character_id** | int(11) unsigned | NO | PRI | 0 |  |
| **slot_id** | mediumint(7) unsigned | NO | PRI | 0 |  |
| **item_id** | int(11) unsigned | YES |  | 0 |  |
| **charges** | smallint(3) unsigned | YES |  | 0 |  |
| **color** | int(11) unsigned | NO |  | 0 |  |
| **augment_one** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_two** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_three** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_four** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_five** | mediumint(7) unsigned | NO |  | 0 |  |
| **augment_six** | mediumint(7) unsigned | NO |  | 0 |  |
| **instnodrop** | tinyint(1) unsigned | NO |  | 0 |  |
| **custom_data** | text | YES |  | NULL |  |
| **ornament_icon** | int(11) unsigned | NO |  | 0 |  |
| **ornament_idfile** | int(11) unsigned | NO |  | 0 |  |
| **ornament_hero_model** | int(11) | NO |  | 0 |  |
| **guid** | bigint(20) unsigned | YES |  | 0 |  |

**Approximate Row Count:** 25

---

## items
Structure of the `items` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) | NO | PRI | 0 |  |
| **minstatus** | smallint(5) | NO | MUL | 0 |  |
| **Name** | varchar(64) | NO | MUL |  |  |
| **aagi** | int(11) | NO |  | 0 |  |
| **ac** | int(11) | NO | MUL | 0 |  |
| **accuracy** | int(11) | NO |  | 0 |  |
| **acha** | int(11) | NO |  | 0 |  |
| **adex** | int(11) | NO |  | 0 |  |
| **aint** | int(11) | NO |  | 0 |  |
| **artifactflag** | tinyint(3) unsigned | NO |  | 0 |  |
| **asta** | int(11) | NO |  | 0 |  |
| **astr** | int(11) | NO |  | 0 |  |
| **attack** | int(11) | NO |  | 0 |  |
| **augrestrict** | int(11) | NO |  | 0 |  |
| **augslot1type** | tinyint(3) | NO | MUL | 0 |  |
| **augslot1visible** | tinyint(3) | NO |  | 0 |  |
| **augslot2type** | tinyint(3) | NO |  | 0 |  |
| **augslot2visible** | tinyint(3) | NO |  | 0 |  |
| **augslot3type** | tinyint(3) | NO |  | 0 |  |
| **augslot3visible** | tinyint(3) | NO |  | 0 |  |
| **augslot4type** | tinyint(3) | NO |  | 0 |  |
| **augslot4visible** | tinyint(3) | NO |  | 0 |  |
| **augslot5type** | tinyint(3) | NO |  | 0 |  |
| **augslot5visible** | tinyint(3) | NO |  | 0 |  |
| **augslot6type** | tinyint(3) | NO |  | 0 |  |
| **augslot6visible** | tinyint(3) | NO |  | 0 |  |
| **augtype** | int(11) | NO |  | 0 |  |
| **avoidance** | int(11) | NO |  | 0 |  |
| **awis** | int(11) | NO |  | 0 |  |
| **bagsize** | int(11) | NO |  | 0 |  |
| **bagslots** | int(11) | NO |  | 0 |  |
| **bagtype** | int(11) | NO |  | 0 |  |
| **bagwr** | int(11) | NO |  | 0 |  |
| **banedmgamt** | int(11) | NO |  | 0 |  |
| **banedmgraceamt** | int(11) | NO |  | 0 |  |
| **banedmgbody** | int(11) | NO |  | 0 |  |
| **banedmgrace** | int(11) | NO |  | 0 |  |
| **bardtype** | int(11) | NO |  | 0 |  |
| **bardvalue** | int(11) | NO |  | 0 |  |
| **book** | int(11) | NO |  | 0 |  |
| **casttime** | int(11) | NO |  | 0 |  |
| **casttime_** | int(11) | NO |  | 0 |  |
| **charmfile** | varchar(32) | NO |  |  |  |
| **charmfileid** | varchar(32) | NO |  |  |  |
| **classes** | int(11) | NO |  | 0 |  |
| **color** | int(10) unsigned | NO |  | 0 |  |
| **combateffects** | varchar(10) | NO |  |  |  |
| **extradmgskill** | int(11) | NO |  | 0 |  |
| **extradmgamt** | int(11) | NO |  | 0 |  |
| **price** | int(11) | NO |  | 0 |  |
| **cr** | int(11) | NO |  | 0 |  |
| **damage** | int(11) | NO |  | 0 |  |
| **damageshield** | int(11) | NO |  | 0 |  |
| **deity** | int(11) | NO |  | 0 |  |
| **delay** | int(11) | NO |  | 0 |  |
| **augdistiller** | int(11) unsigned | NO |  | 0 |  |
| **dotshielding** | int(11) | NO |  | 0 |  |
| **dr** | int(11) | NO |  | 0 |  |
| **clicktype** | int(11) | NO |  | 0 |  |
| **clicklevel2** | int(11) | NO |  | 0 |  |
| **elemdmgtype** | int(11) | NO |  | 0 |  |
| **elemdmgamt** | int(11) | NO |  | 0 |  |
| **endur** | int(11) | NO |  | 0 |  |
| **factionamt1** | int(11) | NO |  | 0 |  |
| **factionamt2** | int(11) | NO |  | 0 |  |
| **factionamt3** | int(11) | NO |  | 0 |  |
| **factionamt4** | int(11) | NO |  | 0 |  |
| **factionmod1** | int(11) | NO |  | 0 |  |
| **factionmod2** | int(11) | NO |  | 0 |  |
| **factionmod3** | int(11) | NO |  | 0 |  |
| **factionmod4** | int(11) | NO |  | 0 |  |
| **filename** | varchar(32) | NO |  |  |  |
| **focuseffect** | int(11) | NO |  | 0 |  |
| **fr** | int(11) | NO |  | 0 |  |
| **fvnodrop** | int(11) | NO |  | 0 |  |
| **haste** | int(11) | NO |  | 0 |  |
| **clicklevel** | int(11) | NO |  | 0 |  |
| **hp** | int(11) | NO | MUL | 0 |  |
| **regen** | int(11) | NO |  | 0 |  |
| **icon** | int(11) | NO |  | 0 |  |
| **idfile** | varchar(30) | NO |  |  |  |
| **itemclass** | int(11) | NO | MUL | 0 |  |
| **itemtype** | int(11) | NO | MUL | 0 |  |
| **ldonprice** | int(11) | NO |  | 0 |  |
| **ldontheme** | int(11) | NO |  | 0 |  |
| **ldonsold** | int(11) | NO |  | 0 |  |
| **light** | int(11) | NO |  | 0 |  |
| **lore** | varchar(80) | NO | MUL |  |  |
| **loregroup** | int(11) | NO |  | 0 |  |
| **magic** | int(11) | NO |  | 0 |  |
| **mana** | int(11) | NO | MUL | 0 |  |
| **manaregen** | int(11) | NO |  | 0 |  |
| **enduranceregen** | int(11) | NO |  | 0 |  |
| **material** | int(11) | NO |  | 0 |  |
| **herosforgemodel** | int(11) | NO |  | 0 |  |
| **maxcharges** | int(11) | NO |  | 0 |  |
| **mr** | int(11) | NO |  | 0 |  |
| **nodrop** | int(11) | NO |  | 0 |  |
| **norent** | int(11) | NO |  | 0 |  |
| **pendingloreflag** | tinyint(3) unsigned | NO |  | 0 |  |
| **pr** | int(11) | NO |  | 0 |  |
| **procrate** | int(11) | NO |  | 0 |  |
| **races** | int(11) | NO | MUL | 0 |  |
| **range** | int(11) | NO |  | 0 |  |
| **reclevel** | int(11) | NO | MUL | 0 |  |
| **recskill** | int(11) | NO |  | 0 |  |
| **reqlevel** | int(11) | NO |  | 0 |  |
| **sellrate** | float | NO |  | 0 |  |
| **shielding** | int(11) | NO |  | 0 |  |
| **size** | int(11) | NO |  | 0 |  |
| **skillmodtype** | int(11) | NO |  | 0 |  |
| **skillmodvalue** | int(11) | NO |  | 0 |  |
| **slots** | int(11) | NO | MUL | 0 |  |
| **clickeffect** | int(11) | NO |  | 0 |  |
| **spellshield** | int(11) | NO |  | 0 |  |
| **strikethrough** | int(11) | NO |  | 0 |  |
| **stunresist** | int(11) | NO |  | 0 |  |
| **summonedflag** | tinyint(3) unsigned | NO |  | 0 |  |
| **tradeskills** | int(11) | NO |  | 0 |  |
| **favor** | int(11) | NO |  | 0 |  |
| **weight** | int(11) | NO |  | 0 |  |
| **UNK012** | int(11) | NO |  | 0 |  |
| **UNK013** | int(11) | NO |  | 0 |  |
| **benefitflag** | int(11) | NO |  | 0 |  |
| **UNK054** | int(11) | NO |  | 0 |  |
| **UNK059** | int(11) | NO |  | 0 |  |
| **booktype** | int(11) | NO |  | 0 |  |
| **recastdelay** | int(11) | NO |  | 0 |  |
| **recasttype** | int(11) | NO |  | 0 |  |
| **guildfavor** | int(11) | NO |  | 0 |  |
| **UNK123** | int(11) | NO |  | 0 |  |
| **UNK124** | int(11) | NO |  | 0 |  |
| **attuneable** | int(11) | NO |  | 0 |  |
| **nopet** | int(11) | NO |  | 0 |  |
| **updated** | datetime | YES |  | NULL |  |
| **comment** | varchar(255) | NO |  |  |  |
| **UNK127** | int(11) | NO |  | 0 |  |
| **pointtype** | int(11) | NO |  | 0 |  |
| **potionbelt** | int(11) | NO |  | 0 |  |
| **potionbeltslots** | int(11) | NO |  | 0 |  |
| **stacksize** | int(11) | NO |  | 0 |  |
| **notransfer** | int(11) | NO |  | 0 |  |
| **stackable** | int(11) | NO |  | 0 |  |
| **UNK134** | varchar(255) | NO |  |  |  |
| **UNK137** | int(11) | NO |  | 0 |  |
| **proceffect** | int(11) | NO |  | 0 |  |
| **proctype** | int(11) | NO |  | 0 |  |
| **proclevel2** | int(11) | NO |  | 0 |  |
| **proclevel** | int(11) | NO |  | 0 |  |
| **UNK142** | int(11) | NO |  | 0 |  |
| **worneffect** | int(11) | NO |  | 0 |  |
| **worntype** | int(11) | NO |  | 0 |  |
| **wornlevel2** | int(11) | NO |  | 0 |  |
| **wornlevel** | int(11) | NO |  | 0 |  |
| **UNK147** | int(11) | NO |  | 0 |  |
| **focustype** | int(11) | NO |  | 0 |  |
| **focuslevel2** | int(11) | NO |  | 0 |  |
| **focuslevel** | int(11) | NO |  | 0 |  |
| **UNK152** | int(11) | NO |  | 0 |  |
| **scrolleffect** | int(11) | NO |  | 0 |  |
| **scrolltype** | int(11) | NO |  | 0 |  |
| **scrolllevel2** | int(11) | NO |  | 0 |  |
| **scrolllevel** | int(11) | NO |  | 0 |  |
| **UNK157** | int(11) | NO |  | 0 |  |
| **serialized** | datetime | YES |  | NULL |  |
| **verified** | datetime | YES |  | NULL |  |
| **serialization** | text | YES |  | NULL |  |
| **source** | varchar(20) | NO |  |  |  |
| **UNK033** | int(11) | NO |  | 0 |  |
| **lorefile** | varchar(32) | NO |  |  |  |
| **UNK014** | int(11) | NO |  | 0 |  |
| **svcorruption** | int(11) | NO |  | 0 |  |
| **skillmodmax** | int(11) | NO |  | 0 |  |
| **UNK060** | int(11) | NO |  | 0 |  |
| **augslot1unk2** | int(11) | NO |  | 0 |  |
| **augslot2unk2** | int(11) | NO |  | 0 |  |
| **augslot3unk2** | int(11) | NO |  | 0 |  |
| **augslot4unk2** | int(11) | NO |  | 0 |  |
| **augslot5unk2** | int(11) | NO |  | 0 |  |
| **augslot6unk2** | int(11) | NO |  | 0 |  |
| **UNK120** | int(11) | NO |  | 0 |  |
| **UNK121** | int(11) | NO |  | 0 |  |
| **questitemflag** | int(11) | NO |  | 0 |  |
| **UNK132** | text | YES |  | NULL |  |
| **clickunk5** | int(11) | NO |  | 0 |  |
| **clickunk6** | varchar(32) | NO |  |  |  |
| **clickunk7** | int(11) | NO |  | 0 |  |
| **procunk1** | int(11) | NO |  | 0 |  |
| **procunk2** | int(11) | NO |  | 0 |  |
| **procunk3** | int(11) | NO |  | 0 |  |
| **procunk4** | int(11) | NO |  | 0 |  |
| **procunk6** | varchar(32) | NO |  |  |  |
| **procunk7** | int(11) | NO |  | 0 |  |
| **wornunk1** | int(11) | NO |  | 0 |  |
| **wornunk2** | int(11) | NO |  | 0 |  |
| **wornunk3** | int(11) | NO |  | 0 |  |
| **wornunk4** | int(11) | NO |  | 0 |  |
| **wornunk5** | int(11) | NO |  | 0 |  |
| **wornunk6** | varchar(32) | NO |  |  |  |
| **wornunk7** | int(11) | NO |  | 0 |  |
| **focusunk1** | int(11) | NO |  | 0 |  |
| **focusunk2** | int(11) | NO |  | 0 |  |
| **focusunk3** | int(11) | NO |  | 0 |  |
| **focusunk4** | int(11) | NO |  | 0 |  |
| **focusunk5** | int(11) | NO |  | 0 |  |
| **focusunk6** | varchar(32) | NO |  |  |  |
| **focusunk7** | int(11) | NO |  | 0 |  |
| **scrollunk1** | int(11) unsigned | NO |  | 0 |  |
| **scrollunk2** | int(11) | NO |  | 0 |  |
| **scrollunk3** | int(11) | NO |  | 0 |  |
| **scrollunk4** | int(11) | NO |  | 0 |  |
| **scrollunk5** | int(11) | NO |  | 0 |  |
| **scrollunk6** | varchar(32) | NO |  |  |  |
| **scrollunk7** | int(11) | NO |  | 0 |  |
| **UNK193** | int(11) | NO |  | 0 |  |
| **purity** | int(11) | NO |  | 0 |  |
| **evoitem** | int(11) | NO |  | 0 |  |
| **evoid** | int(11) | NO |  | 0 |  |
| **evolvinglevel** | int(11) | NO |  | 0 |  |
| **evomax** | int(11) | NO |  | 0 |  |
| **clickname** | varchar(64) | NO |  |  |  |
| **procname** | varchar(64) | NO |  |  |  |
| **wornname** | varchar(64) | NO |  |  |  |
| **focusname** | varchar(64) | NO |  |  |  |
| **scrollname** | varchar(64) | NO |  |  |  |
| **dsmitigation** | smallint(6) | NO |  | 0 |  |
| **heroic_str** | smallint(6) | NO |  | 0 |  |
| **heroic_int** | smallint(6) | NO |  | 0 |  |
| **heroic_wis** | smallint(6) | NO |  | 0 |  |
| **heroic_agi** | smallint(6) | NO |  | 0 |  |
| **heroic_dex** | smallint(6) | NO |  | 0 |  |
| **heroic_sta** | smallint(6) | NO |  | 0 |  |
| **heroic_cha** | smallint(6) | NO |  | 0 |  |
| **heroic_pr** | smallint(6) | NO |  | 0 |  |
| **heroic_dr** | smallint(6) | NO |  | 0 |  |
| **heroic_fr** | smallint(6) | NO |  | 0 |  |
| **heroic_cr** | smallint(6) | NO |  | 0 |  |
| **heroic_mr** | smallint(6) | NO |  | 0 |  |
| **heroic_svcorrup** | smallint(6) | NO |  | 0 |  |
| **healamt** | smallint(6) | NO |  | 0 |  |
| **spelldmg** | smallint(6) | NO |  | 0 |  |
| **clairvoyance** | smallint(6) | NO |  | 0 |  |
| **backstabdmg** | smallint(6) | NO |  | 0 |  |
| **created** | varchar(64) | NO |  |  |  |
| **elitematerial** | smallint(6) | NO |  | 0 |  |
| **ldonsellbackrate** | smallint(6) | NO |  | 0 |  |
| **scriptfileid** | mediumint(6) | NO |  | 0 |  |
| **expendablearrow** | smallint(6) | NO |  | 0 |  |
| **powersourcecapacity** | mediumint(7) | NO |  | 0 |  |
| **bardeffect** | mediumint(6) | NO |  | 0 |  |
| **bardeffecttype** | smallint(6) | NO |  | 0 |  |
| **bardlevel2** | smallint(6) | NO |  | 0 |  |
| **bardlevel** | smallint(6) | NO |  | 0 |  |
| **bardunk1** | smallint(6) | NO |  | 0 |  |
| **bardunk2** | smallint(6) | NO |  | 0 |  |
| **bardunk3** | smallint(6) | NO |  | 0 |  |
| **bardunk4** | smallint(6) | NO |  | 0 |  |
| **bardunk5** | smallint(6) | NO |  | 0 |  |
| **bardname** | varchar(64) | NO |  |  |  |
| **bardunk7** | smallint(6) | NO |  | 0 |  |
| **UNK214** | smallint(6) | NO |  | 0 |  |
| **subtype** | int(11) | NO |  | 0 |  |
| **UNK220** | int(11) | NO |  | 0 |  |
| **UNK221** | int(11) | NO |  | 0 |  |
| **heirloom** | int(11) | NO |  | 0 |  |
| **UNK223** | int(11) | NO |  | 0 |  |
| **UNK224** | int(11) | NO |  | 0 |  |
| **UNK225** | int(11) | NO |  | 0 |  |
| **UNK226** | int(11) | NO |  | 0 |  |
| **UNK227** | int(11) | NO |  | 0 |  |
| **UNK228** | int(11) | NO |  | 0 |  |
| **UNK229** | int(11) | NO |  | 0 |  |
| **UNK230** | int(11) | NO |  | 0 |  |
| **UNK231** | int(11) | NO |  | 0 |  |
| **UNK232** | int(11) | NO |  | 0 |  |
| **UNK233** | int(11) | NO |  | 0 |  |
| **UNK234** | int(11) | NO |  | 0 |  |
| **placeable** | int(11) | NO |  | 0 |  |
| **UNK236** | int(11) | NO |  | 0 |  |
| **UNK237** | int(11) | NO |  | 0 |  |
| **UNK238** | int(11) | NO |  | 0 |  |
| **UNK239** | int(11) | NO |  | 0 |  |
| **UNK240** | int(11) | NO |  | 0 |  |
| **UNK241** | int(11) | NO |  | 0 |  |
| **epicitem** | int(11) | NO |  | 0 |  |

**Approximate Row Count:** 117944

---

## rule_values
Structure of the `rule_values` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ruleset_id** | tinyint(3) unsigned | NO | PRI | 0 |  |
| **rule_name** | varchar(64) | NO | PRI |  |  |
| **rule_value** | text | NO |  | '' |  |
| **notes** | text | YES |  | NULL |  |

**Approximate Row Count:** 1065

---

## spells_new
Structure of the `spells_new` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(11) | NO | PRI | 0 |  |
| **name** | varchar(64) | YES |  | NULL |  |
| **player_1** | varchar(64) | YES |  | BLUE_TRAIL |  |
| **teleport_zone** | varchar(64) | YES |  | NULL |  |
| **you_cast** | varchar(120) | YES |  | NULL |  |
| **other_casts** | varchar(120) | YES |  | NULL |  |
| **cast_on_you** | varchar(120) | YES |  | NULL |  |
| **cast_on_other** | varchar(120) | YES |  | NULL |  |
| **spell_fades** | varchar(120) | YES |  | NULL |  |
| **range** | int(11) | NO |  | 100 |  |
| **aoerange** | int(11) | NO |  | 0 |  |
| **pushback** | int(11) | NO |  | 0 |  |
| **pushup** | int(11) | NO |  | 0 |  |
| **cast_time** | int(11) | NO |  | 0 |  |
| **recovery_time** | int(11) | NO |  | 0 |  |
| **recast_time** | int(11) | NO |  | 0 |  |
| **buffdurationformula** | int(11) | NO |  | 7 |  |
| **buffduration** | int(11) | NO |  | 65 |  |
| **AEDuration** | int(11) | NO |  | 0 |  |
| **mana** | int(11) | NO |  | 0 |  |
| **effect_base_value1** | int(11) | NO |  | 100 |  |
| **effect_base_value2** | int(11) | NO |  | 0 |  |
| **effect_base_value3** | int(11) | NO |  | 0 |  |
| **effect_base_value4** | int(11) | NO |  | 0 |  |
| **effect_base_value5** | int(11) | NO |  | 0 |  |
| **effect_base_value6** | int(11) | NO |  | 0 |  |
| **effect_base_value7** | int(11) | NO |  | 0 |  |
| **effect_base_value8** | int(11) | NO |  | 0 |  |
| **effect_base_value9** | int(11) | NO |  | 0 |  |
| **effect_base_value10** | int(11) | NO |  | 0 |  |
| **effect_base_value11** | int(11) | NO |  | 0 |  |
| **effect_base_value12** | int(11) | NO |  | 0 |  |
| **effect_limit_value1** | int(11) | NO |  | 0 |  |
| **effect_limit_value2** | int(11) | NO |  | 0 |  |
| **effect_limit_value3** | int(11) | NO |  | 0 |  |
| **effect_limit_value4** | int(11) | NO |  | 0 |  |
| **effect_limit_value5** | int(11) | NO |  | 0 |  |
| **effect_limit_value6** | int(11) | NO |  | 0 |  |
| **effect_limit_value7** | int(11) | NO |  | 0 |  |
| **effect_limit_value8** | int(11) | NO |  | 0 |  |
| **effect_limit_value9** | int(11) | NO |  | 0 |  |
| **effect_limit_value10** | int(11) | NO |  | 0 |  |
| **effect_limit_value11** | int(11) | NO |  | 0 |  |
| **effect_limit_value12** | int(11) | NO |  | 0 |  |
| **max1** | int(11) | NO |  | 0 |  |
| **max2** | int(11) | NO |  | 0 |  |
| **max3** | int(11) | NO |  | 0 |  |
| **max4** | int(11) | NO |  | 0 |  |
| **max5** | int(11) | NO |  | 0 |  |
| **max6** | int(11) | NO |  | 0 |  |
| **max7** | int(11) | NO |  | 0 |  |
| **max8** | int(11) | NO |  | 0 |  |
| **max9** | int(11) | NO |  | 0 |  |
| **max10** | int(11) | NO |  | 0 |  |
| **max11** | int(11) | NO |  | 0 |  |
| **max12** | int(11) | NO |  | 0 |  |
| **icon** | int(11) | NO |  | 0 |  |
| **memicon** | int(11) | NO |  | 0 |  |
| **components1** | int(11) | NO |  | -1 |  |
| **components2** | int(11) | NO |  | -1 |  |
| **components3** | int(11) | NO |  | -1 |  |
| **components4** | int(11) | NO |  | -1 |  |
| **component_counts1** | int(11) | NO |  | 1 |  |
| **component_counts2** | int(11) | NO |  | 1 |  |
| **component_counts3** | int(11) | NO |  | 1 |  |
| **component_counts4** | int(11) | NO |  | 1 |  |
| **NoexpendReagent1** | int(11) | NO |  | -1 |  |
| **NoexpendReagent2** | int(11) | NO |  | -1 |  |
| **NoexpendReagent3** | int(11) | NO |  | -1 |  |
| **NoexpendReagent4** | int(11) | NO |  | -1 |  |
| **formula1** | int(11) | NO |  | 100 |  |
| **formula2** | int(11) | NO |  | 100 |  |
| **formula3** | int(11) | NO |  | 100 |  |
| **formula4** | int(11) | NO |  | 100 |  |
| **formula5** | int(11) | NO |  | 100 |  |
| **formula6** | int(11) | NO |  | 100 |  |
| **formula7** | int(11) | NO |  | 100 |  |
| **formula8** | int(11) | NO |  | 100 |  |
| **formula9** | int(11) | NO |  | 100 |  |
| **formula10** | int(11) | NO |  | 100 |  |
| **formula11** | int(11) | NO |  | 100 |  |
| **formula12** | int(11) | NO |  | 100 |  |
| **LightType** | int(11) | NO |  | 0 |  |
| **goodEffect** | int(11) | NO |  | 0 |  |
| **Activated** | int(11) | NO |  | 0 |  |
| **resisttype** | int(11) | NO |  | 0 |  |
| **effectid1** | int(11) | NO |  | 254 |  |
| **effectid2** | int(11) | NO |  | 254 |  |
| **effectid3** | int(11) | NO |  | 254 |  |
| **effectid4** | int(11) | NO |  | 254 |  |
| **effectid5** | int(11) | NO |  | 254 |  |
| **effectid6** | int(11) | NO |  | 254 |  |
| **effectid7** | int(11) | NO |  | 254 |  |
| **effectid8** | int(11) | NO |  | 254 |  |
| **effectid9** | int(11) | NO |  | 254 |  |
| **effectid10** | int(11) | NO |  | 254 |  |
| **effectid11** | int(11) | NO |  | 254 |  |
| **effectid12** | int(11) | NO |  | 254 |  |
| **targettype** | int(11) | NO |  | 2 |  |
| **basediff** | int(11) | NO |  | 0 |  |
| **skill** | int(11) | NO |  | 98 |  |
| **zonetype** | int(11) | NO |  | -1 |  |
| **EnvironmentType** | int(11) | NO |  | 0 |  |
| **TimeOfDay** | int(11) | NO |  | 0 |  |
| **classes1** | int(11) | NO |  | 255 |  |
| **classes2** | int(11) | NO |  | 255 |  |
| **classes3** | int(11) | NO |  | 255 |  |
| **classes4** | int(11) | NO |  | 255 |  |
| **classes5** | int(11) | NO |  | 255 |  |
| **classes6** | int(11) | NO |  | 255 |  |
| **classes7** | int(11) | NO |  | 255 |  |
| **classes8** | int(11) | NO |  | 255 |  |
| **classes9** | int(11) | NO |  | 255 |  |
| **classes10** | int(11) | NO |  | 255 |  |
| **classes11** | int(11) | NO |  | 255 |  |
| **classes12** | int(11) | NO |  | 255 |  |
| **classes13** | int(11) | NO |  | 255 |  |
| **classes14** | int(11) | NO |  | 255 |  |
| **classes15** | int(11) | NO |  | 255 |  |
| **classes16** | int(11) | NO |  | 255 |  |
| **CastingAnim** | int(11) | NO |  | 44 |  |
| **TargetAnim** | int(11) | NO |  | 13 |  |
| **TravelType** | int(11) | NO |  | 0 |  |
| **SpellAffectIndex** | int(11) | NO |  | -1 |  |
| **disallow_sit** | int(11) | NO |  | 0 |  |
| **deities0** | int(11) | NO |  | 0 |  |
| **deities1** | int(11) | NO |  | 0 |  |
| **deities2** | int(11) | NO |  | 0 |  |
| **deities3** | int(11) | NO |  | 0 |  |
| **deities4** | int(11) | NO |  | 0 |  |
| **deities5** | int(11) | NO |  | 0 |  |
| **deities6** | int(11) | NO |  | 0 |  |
| **deities7** | int(11) | NO |  | 0 |  |
| **deities8** | int(11) | NO |  | 0 |  |
| **deities9** | int(11) | NO |  | 0 |  |
| **deities10** | int(11) | NO |  | 0 |  |
| **deities11** | int(11) | NO |  | 0 |  |
| **deities12** | int(12) | NO |  | 0 |  |
| **deities13** | int(11) | NO |  | 0 |  |
| **deities14** | int(11) | NO |  | 0 |  |
| **deities15** | int(11) | NO |  | 0 |  |
| **deities16** | int(11) | NO |  | 0 |  |
| **field142** | int(11) | NO |  | 100 |  |
| **field143** | int(11) | NO |  | 0 |  |
| **new_icon** | int(11) | NO |  | 161 |  |
| **spellanim** | int(11) | NO |  | 0 |  |
| **uninterruptable** | int(11) | NO |  | 0 |  |
| **ResistDiff** | int(11) | NO |  | -150 |  |
| **dot_stacking_exempt** | int(11) | NO |  | 0 |  |
| **deleteable** | int(11) | NO |  | 0 |  |
| **RecourseLink** | int(11) | NO |  | 0 |  |
| **no_partial_resist** | int(11) | NO |  | 0 |  |
| **field152** | int(11) | NO |  | 0 |  |
| **field153** | int(11) | NO |  | 0 |  |
| **short_buff_box** | int(11) | NO |  | -1 |  |
| **descnum** | int(11) | NO |  | 0 |  |
| **typedescnum** | int(11) | YES |  | NULL |  |
| **effectdescnum** | int(11) | YES |  | NULL |  |
| **effectdescnum2** | int(11) | NO |  | 0 |  |
| **npc_no_los** | int(11) | NO |  | 0 |  |
| **field160** | int(11) | NO |  | 0 |  |
| **reflectable** | int(11) | NO |  | 0 |  |
| **bonushate** | int(11) | NO |  | 0 |  |
| **field163** | int(11) | NO |  | 100 |  |
| **field164** | int(11) | NO |  | -150 |  |
| **ldon_trap** | int(11) | NO |  | 0 |  |
| **EndurCost** | int(11) | NO |  | 0 |  |
| **EndurTimerIndex** | int(11) | NO |  | 0 |  |
| **IsDiscipline** | int(11) | NO |  | 0 |  |
| **field169** | int(11) | NO |  | 0 |  |
| **field170** | int(11) | NO |  | 0 |  |
| **field171** | int(11) | NO |  | 0 |  |
| **field172** | int(11) | NO |  | 0 |  |
| **HateAdded** | int(11) | NO |  | 0 |  |
| **EndurUpkeep** | int(11) | NO |  | 0 |  |
| **numhitstype** | int(11) | NO |  | 0 |  |
| **numhits** | int(11) | NO |  | 0 |  |
| **pvpresistbase** | int(11) | NO |  | -150 |  |
| **pvpresistcalc** | int(11) | NO |  | 100 |  |
| **pvpresistcap** | int(11) | NO |  | -150 |  |
| **spell_category** | int(11) | NO |  | -99 |  |
| **pvp_duration** | int(11) | NO |  | 0 |  |
| **pvp_duration_cap** | int(11) | NO |  | 0 |  |
| **pcnpc_only_flag** | int(11) | YES |  | 0 |  |
| **cast_not_standing** | int(11) | YES |  | 0 |  |
| **can_mgb** | int(11) | NO |  | 0 |  |
| **nodispell** | int(11) | NO |  | -1 |  |
| **npc_category** | int(11) | NO |  | 0 |  |
| **npc_usefulness** | int(11) | NO |  | 0 |  |
| **MinResist** | int(11) | NO |  | 0 |  |
| **MaxResist** | int(11) | NO |  | 0 |  |
| **viral_targets** | int(11) | NO |  | 0 |  |
| **viral_timer** | int(11) | NO |  | 0 |  |
| **nimbuseffect** | int(11) | YES |  | 0 |  |
| **ConeStartAngle** | int(11) | NO |  | 0 |  |
| **ConeStopAngle** | int(11) | NO |  | 0 |  |
| **sneaking** | int(11) | NO |  | 0 |  |
| **not_extendable** | int(11) | NO |  | 0 |  |
| **field198** | int(11) | NO |  | 0 |  |
| **field199** | int(11) | NO |  | 1 |  |
| **suspendable** | int(11) | YES |  | 0 |  |
| **viral_range** | int(11) | NO |  | 0 |  |
| **songcap** | int(11) | YES |  | 0 |  |
| **field203** | int(11) | YES |  | 0 |  |
| **field204** | int(11) | YES |  | 0 |  |
| **no_block** | int(11) | NO |  | 0 |  |
| **field206** | int(11) | YES |  | -1 |  |
| **spellgroup** | int(11) | YES |  | 0 |  |
| **rank** | int(11) | NO |  | 0 |  |
| **field209** | int(11) | YES |  | 0 |  |
| **field210** | int(11) | YES |  | 1 |  |
| **CastRestriction** | int(11) | NO |  | 0 |  |
| **allowrest** | int(11) | YES |  | 0 |  |
| **InCombat** | int(11) | NO |  | 0 |  |
| **OutofCombat** | int(11) | NO |  | 0 |  |
| **field215** | int(11) | YES |  | 0 |  |
| **field216** | int(11) | YES |  | 0 |  |
| **field217** | int(11) | YES |  | 0 |  |
| **aemaxtargets** | int(11) | NO |  | 0 |  |
| **maxtargets** | int(11) | YES |  | 0 |  |
| **field220** | int(11) | YES |  | 0 |  |
| **field221** | int(11) | YES |  | 0 |  |
| **field222** | int(11) | YES |  | 0 |  |
| **field223** | int(11) | YES |  | 0 |  |
| **persistdeath** | int(11) | YES |  | 0 |  |
| **field225** | int(11) | NO |  | 0 |  |
| **field226** | int(11) | NO |  | 0 |  |
| **min_dist** | float | NO |  | 0 |  |
| **min_dist_mod** | float | NO |  | 0 |  |
| **max_dist** | float | NO |  | 0 |  |
| **max_dist_mod** | float | NO |  | 0 |  |
| **min_range** | int(11) | NO |  | 0 |  |
| **field232** | int(11) | NO |  | 0 |  |
| **field233** | int(11) | NO |  | 0 |  |
| **field234** | int(11) | NO |  | 0 |  |
| **field235** | int(11) | NO |  | 0 |  |
| **field236** | int(11) | NO |  | 0 |  |

**Approximate Row Count:** 40722

---

## zone
Structure of the `zone` table:

| Field | Type | Null | Key | Default | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **id** | int(10) | NO | PRI | NULL | auto_increment |
| **zoneidnumber** | int(4) | NO | MUL | 0 |  |
| **version** | tinyint(3) unsigned | NO |  | 0 |  |
| **short_name** | varchar(32) | YES | MUL | NULL |  |
| **long_name** | text | NO |  | NULL |  |
| **min_status** | tinyint(3) unsigned | NO |  | 0 |  |
| **map_file_name** | varchar(100) | YES |  | NULL |  |
| **note** | varchar(200) | YES |  | NULL |  |
| **min_expansion** | tinyint(4) | NO |  | -1 |  |
| **max_expansion** | tinyint(4) | NO |  | -1 |  |
| **content_flags** | varchar(100) | YES |  | NULL |  |
| **content_flags_disabled** | varchar(100) | YES |  | NULL |  |
| **expansion** | tinyint(3) | NO |  | 0 |  |
| **file_name** | varchar(16) | YES |  | NULL |  |
| **safe_x** | float | NO |  | 0 |  |
| **safe_y** | float | NO |  | 0 |  |
| **safe_z** | float | NO |  | 0 |  |
| **safe_heading** | float | NO |  | 0 |  |
| **graveyard_id** | float | NO |  | 0 |  |
| **min_level** | tinyint(3) unsigned | NO |  | 0 |  |
| **max_level** | tinyint(3) unsigned | NO |  | 255 |  |
| **timezone** | int(5) | NO |  | 0 |  |
| **maxclients** | int(5) | NO |  | 0 |  |
| **ruleset** | int(10) unsigned | NO |  | 0 |  |
| **underworld** | float | NO |  | 0 |  |
| **minclip** | float | NO |  | 450 |  |
| **maxclip** | float | NO |  | 450 |  |
| **fog_minclip** | float | NO |  | 450 |  |
| **fog_maxclip** | float | NO |  | 450 |  |
| **fog_blue** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_red** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_green** | tinyint(3) unsigned | NO |  | 0 |  |
| **sky** | tinyint(3) unsigned | NO |  | 1 |  |
| **ztype** | tinyint(3) unsigned | NO |  | 1 |  |
| **zone_exp_multiplier** | decimal(6,2) | NO |  | 0.00 |  |
| **walkspeed** | float | NO |  | 0.4 |  |
| **time_type** | tinyint(3) unsigned | NO |  | 2 |  |
| **fog_red1** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_green1** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_blue1** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_minclip1** | float | NO |  | 450 |  |
| **fog_maxclip1** | float | NO |  | 450 |  |
| **fog_red2** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_green2** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_blue2** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_minclip2** | float | NO |  | 450 |  |
| **fog_maxclip2** | float | NO |  | 450 |  |
| **fog_red3** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_green3** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_blue3** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_minclip3** | float | NO |  | 450 |  |
| **fog_maxclip3** | float | NO |  | 450 |  |
| **fog_red4** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_green4** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_blue4** | tinyint(3) unsigned | NO |  | 0 |  |
| **fog_minclip4** | float | NO |  | 450 |  |
| **fog_maxclip4** | float | NO |  | 450 |  |
| **fog_density** | float | NO |  | 0 |  |
| **flag_needed** | varchar(128) | NO |  |  |  |
| **canbind** | tinyint(4) | NO |  | 1 |  |
| **cancombat** | tinyint(4) | NO |  | 1 |  |
| **canlevitate** | tinyint(4) | NO |  | 1 |  |
| **castoutdoor** | tinyint(4) | NO |  | 1 |  |
| **hotzone** | tinyint(3) unsigned | NO |  | 0 |  |
| **insttype** | tinyint(1) unsigned zerofill | NO |  | 0 |  |
| **shutdowndelay** | bigint(16) unsigned | NO |  | 5000 |  |
| **peqzone** | tinyint(4) | NO |  | 1 |  |
| **bypass_expansion_check** | tinyint(3) | NO |  | 0 |  |
| **suspendbuffs** | tinyint(1) unsigned | NO |  | 0 |  |
| **rain_chance1** | int(4) | NO |  | 0 |  |
| **rain_chance2** | int(4) | NO |  | 0 |  |
| **rain_chance3** | int(4) | NO |  | 0 |  |
| **rain_chance4** | int(4) | NO |  | 0 |  |
| **rain_duration1** | int(4) | NO |  | 0 |  |
| **rain_duration2** | int(4) | NO |  | 0 |  |
| **rain_duration3** | int(4) | NO |  | 0 |  |
| **rain_duration4** | int(4) | NO |  | 0 |  |
| **snow_chance1** | int(4) | NO |  | 0 |  |
| **snow_chance2** | int(4) | NO |  | 0 |  |
| **snow_chance3** | int(4) | NO |  | 0 |  |
| **snow_chance4** | int(4) | NO |  | 0 |  |
| **snow_duration1** | int(4) | NO |  | 0 |  |
| **snow_duration2** | int(4) | NO |  | 0 |  |
| **snow_duration3** | int(4) | NO |  | 0 |  |
| **snow_duration4** | int(4) | NO |  | 0 |  |
| **gravity** | float | NO |  | 0.4 |  |
| **type** | int(3) | NO |  | 0 |  |
| **skylock** | tinyint(4) | NO |  | 0 |  |
| **fast_regen_hp** | int(11) | NO |  | 180 |  |
| **fast_regen_mana** | int(11) | NO |  | 180 |  |
| **fast_regen_endurance** | int(11) | NO |  | 180 |  |
| **npc_max_aggro_dist** | int(11) | NO |  | 600 |  |
| **client_update_range** | int(11) | NO |  | 600 |  |
| **underworld_teleport_index** | int(4) | NO |  | 0 |  |
| **lava_damage** | int(11) | YES |  | 50 |  |
| **min_lava_damage** | int(11) | NO |  | 10 |  |
| **idle_when_empty** | tinyint(1) unsigned | NO |  | 1 |  |
| **seconds_before_idle** | int(11) unsigned | NO |  | 60 |  |
| **shard_at_player_count** | int(11) | YES |  | 0 |  |

**Approximate Row Count:** 618

---