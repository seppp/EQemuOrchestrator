import os
import time
import sqlite3
import pymysql
import os
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

from db_admin import get_connection

# Default EQGame path matching the user's setup
DEFAULT_EQ_PATH = os.path.join(BASE_DIR, "everquest_rof2", "everquest_rof2", "eqgame.exe")
DEFAULT_LOGIN_DB = os.path.join(BASE_DIR, "MacroQuestRof2", "config", "login.db")

# Starter item definitions
ITEM_BACKPACK = 17005
ITEM_RATION = 13015
ITEM_WATER = 13006

CLASS_WEAPONS = {
    # Priests (Club)
    2: 6001,  # Cleric
    6: 6001,  # Druid
    10: 6001, # Shaman
    # Casters (Dagger)
    11: 7001, # Necromancer
    12: 7001, # Wizard
    13: 7001, # Magician
    14: 7001, # Enchanter
    # Melee/Hybrids (Short Sword)
    1: 5001,  # Warrior
    3: 5001,  # Paladin
    4: 5001,  # Ranger
    5: 5001,  # Shadowknight
    7: 5001,  # Monk
    8: 5001,  # Bard
    9: 5001,  # Rogue
    15: 5001, # Beastlord
    16: 5001  # Berserker
}

DEFAULT_DEITIES = {
    3: 104,  # Paladin -> Mithaniel Marr
    5: 201,  # Shadowknight -> Cazic-Thule
    6: 215,  # Druid -> Tunare
    2: 215,  # Cleric -> Tunare
    4: 215,  # Ranger -> Tunare
}

def create_character(name, race_id, class_id, gender_id, deity_id, zone_id=394):
    """
    Creates a new level 1 character directly in the PEQ MariaDB.
    Also automatically creates a corresponding MariaDB account with same name and password "a".
    Replicates character_data, character_skills, character_bind, and inventory inserts.
    """
    name = name.strip().capitalize()
    if not name.isalpha() or len(name) < 3:
        raise ValueError("Character name must be alphabetic and at least 3 characters long.")
        
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # 1. Check if character name already exists
            cursor.execute("SELECT id FROM character_data WHERE name = %s", (name,))
            if cursor.fetchone():
                raise ValueError(f"Character name '{name}' already exists in the database.")
                
            # 2. Ensure login server account and local accounts exist
            account_name = name.lower()
            
            # 2a. Ensure login_accounts entry exists
            cursor.execute("SELECT id FROM login_accounts WHERE account_name = %s", (account_name,))
            la_row = cursor.fetchone()
            if la_row:
                login_acc_id = la_row['id']
            else:
                cursor.execute("SELECT MAX(id) FROM login_accounts")
                max_id_row = cursor.fetchone()
                login_acc_id = (max_id_row['MAX(id)'] or 0) + 1 if max_id_row else 1
                
                # We use the known scrypt password hash for "a"
                pwd_hash = "$7$C6..../....3/HataIvbJRJFxYusvEFwkB.2cIQ1/MEwzuBfAfrMn7$QWonsrBUFDN/Dg20LkLgj0AzGkAY5AkBZswdAeYQyCC"
                cursor.execute("""
                    INSERT INTO login_accounts (id, account_name, account_password, account_email, source_loginserver, last_ip_address, last_login_date, created_at)
                    VALUES (%s, %s, %s, %s, 'local', '127.0.0.1', NOW(), NOW())
                """, (login_acc_id, account_name, pwd_hash, f"{account_name}@local"))
                print(f"Created login server account: {account_name} (ID: {login_acc_id})")

            # 2b. Ensure eqemu account exists in account table
            cursor.execute("SELECT id FROM account WHERE name = %s AND ls_id = 'eqemu'", (account_name,))
            eqemu_row = cursor.fetchone()
            if not eqemu_row:
                cursor.execute("""
                    INSERT INTO account (name, password, status, charname, auto_login_charname, ls_id, lsaccount_id, time_creation)
                    VALUES (%s, 'a', 0, %s, %s, 'eqemu', NULL, %s)
                """, (account_name, name, name, int(time.time())))
                print(f"Created eqemu account: {account_name}")

            # 2c. Ensure local account exists in account table (this is the one used by World Server for characters)
            cursor.execute("SELECT id FROM account WHERE name = %s AND ls_id = 'local' AND lsaccount_id = %s", (account_name, login_acc_id))
            local_row = cursor.fetchone()
            if local_row:
                account_id = local_row['id']
                print(f"Using existing local account: {account_name} (ID: {account_id})")
            else:
                cursor.execute("""
                    INSERT INTO account (name, password, status, ls_id, lsaccount_id, time_creation)
                    VALUES (%s, '', 0, 'local', %s, %s)
                """, (account_name, login_acc_id, int(time.time())))
                account_id = cursor.lastrowid
                print(f"Created local account: {account_name} (ID: {account_id})")


            # 3. Get safe coordinates for starting zone
            cursor.execute("SELECT safe_x, safe_y, safe_z FROM zone WHERE zoneidnumber = %s", (zone_id,))
            zone_info = cursor.fetchone()
            if zone_info:
                x, y, z = zone_info['safe_x'], zone_info['safe_y'], zone_info['safe_z']
            else:
                x, y, z = 0.0, 0.0, 0.0
                
            # 4. Get starting stats from allocation tables
            cursor.execute("""
                SELECT allocation_id FROM char_create_combinations 
                WHERE race = %s AND class = %s LIMIT 1
            """, (race_id, class_id))
            alloc_res = cursor.fetchone()
            if not alloc_res:
                raise ValueError("Invalid class and race combination.")
            
            stats = {'str': 75, 'sta': 75, 'dex': 75, 'agi': 75, 'int': 75, 'wis': 75, 'cha': 75}
            cursor.execute("""
                SELECT base_str, base_sta, base_dex, base_agi, base_int, base_wis, base_cha,
                       alloc_str, alloc_sta, alloc_dex, alloc_agi, alloc_int, alloc_wis, alloc_cha
                FROM char_create_point_allocations WHERE id = %s
            """, (alloc_res['allocation_id'],))
            alloc = cursor.fetchone()
            if alloc:
                stats['str'] = alloc['base_str'] + alloc['alloc_str']
                stats['sta'] = alloc['base_sta'] + alloc['alloc_sta']
                stats['dex'] = alloc['base_dex'] + alloc['alloc_dex']
                stats['agi'] = alloc['base_agi'] + alloc['alloc_agi']
                stats['int'] = alloc['base_int'] + alloc['alloc_int']
                stats['wis'] = alloc['base_wis'] + alloc['alloc_wis']
                stats['cha'] = alloc['base_cha'] + alloc['alloc_cha']

            # Determine deity if default requested
            if deity_id == 0:
                deity_id = DEFAULT_DEITIES.get(class_id, 396) # 396 is Agnostic

            # Generate unique mailkey
            mailkey = os.urandom(8).hex().upper()
            birthday = int(time.time())

            # 5. Insert into character_data
            sql_insert_char = """
                INSERT INTO character_data (
                    account_id, name, race, class, gender, level, deity, zone_id, x, y, z, heading,
                    cur_hp, mana, endurance, str, sta, dex, agi, `int`, wis, cha, birthday,
                    exp_enabled, mailkey, xtargets, face, hair_color, hair_style, beard, beard_color,
                    eye_color_1, eye_color_2, first_login, last_login, time_played
                ) VALUES (
                    %s, %s, %s, %s, %s, 1, %s, %s, %s, %s, %s, 0,
                    100, 100, 100, %s, %s, %s, %s, %s, %s, %s, %s,
                    1, %s, 5, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0
                )
            """
            cursor.execute(sql_insert_char, (
                account_id, name, race_id, class_id, gender_id, deity_id, zone_id, x, y, z,
                stats['str'], stats['sta'], stats['dex'], stats['agi'], stats['int'], stats['wis'], stats['cha'],
                birthday, mailkey
            ))
            char_id = cursor.lastrowid

            # 6. Insert level 1 skills (unlock with 1 point instead of maxing)
            cursor.execute("SELECT skill_id, cap FROM skill_caps WHERE class_id = %s AND level = 1", (class_id,))
            skills = cursor.fetchall()
            if skills:
                sql_skill = "INSERT INTO character_skills (id, skill_id, value) VALUES (%s, %s, %s)"
                skill_data = []
                for s in skills:
                    val = 1
                    # Give common tongue a solid base value
                    if s['skill_id'] == 40:
                        val = 200
                    skill_data.append((char_id, s['skill_id'], val))
                cursor.executemany(sql_skill, skill_data)

            # 6.5. Scribe Level 1 Spells
            # Warrior(1), Monk(7), Rogue(9), Berserker(16) do not have spells
            if class_id not in (1, 7, 9, 16):
                col = f"classes{class_id}"
                cursor.execute(f"SELECT id FROM spells_new WHERE {col} = 1")
                spells = cursor.fetchall()
                if spells:
                    sql_spell = "INSERT INTO character_spells (id, slot_id, spell_id) VALUES (%s, %s, %s)"
                    spell_data = []
                    for i, sp in enumerate(spells):
                        # i is the slot_id (starts at 0)
                        spell_data.append((char_id, i, sp['id']))
                    cursor.executemany(sql_spell, spell_data)

            # 7. Insert 5 starting bind points
            sql_bind = """
                INSERT INTO character_bind (id, slot, zone_id, instance_id, x, y, z, heading)
                VALUES (%s, %s, %s, 0, %s, %s, %s, 0)
            """
            bind_data = [(char_id, slot, zone_id, x, y, z) for slot in range(5)]
            cursor.executemany(sql_bind, bind_data)

            # 8. Insert starting items (Primary Weapon, Backpack, Food, Drink)
            weapon_id = CLASS_WEAPONS.get(class_id, 7001)
            sql_inv = "INSERT INTO inventory (character_id, slot_id, item_id, charges) VALUES (%s, %s, %s, %s)"
            inv_data = [
                (char_id, 13, weapon_id, 1),      # Weapon in Primary Slot
                (char_id, 22, ITEM_BACKPACK, 1),  # Backpack in Slot 22
                (char_id, 23, ITEM_RATION, 20),   # 20 Rations in Slot 23
                (char_id, 24, ITEM_WATER, 20)     # 20 Water Flasks in Slot 24
            ]
            cursor.executemany(sql_inv, inv_data)
            
            # 9. Insert Leadership Abilities (Grants Delegate Main Assist and others)
            sql_leader = "INSERT INTO character_leadership_abilities (id, slot, rank) VALUES (%s, %s, %s)"
            leader_data = [(char_id, slot, 1) for slot in range(1, 16)]
            cursor.executemany(sql_leader, leader_data)
            
            conn.commit()
            print(f"Created Character: {name} (ID: {char_id}) in PEQ DB.")
            return char_id, name
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()

def add_to_mq_login(char_name, group_name, login_db_path=DEFAULT_LOGIN_DB, eq_path=DEFAULT_EQ_PATH):
    """
    Registers the character in MacroQuest's SQLite login.db under a corresponding account (password 'a') and group.
    Creates both the account and the group in login.db if they don't already exist.
    """
    if not os.path.exists(login_db_path):
        raise FileNotFoundError(f"MacroQuest login.db not found at: {login_db_path}")

    conn = sqlite3.connect(login_db_path)
    try:
        c = conn.cursor()
        
        # 1. Find or create the account in SQLite login.db
        acc_name = char_name.lower()
        c.execute("SELECT id FROM accounts WHERE account = ?", (acc_name,))
        acc_row = c.fetchone()
        if acc_row:
            mq_account_id = acc_row[0]
        else:
            # Encrypt password "a" -> "\x0f" using XOR with master password key "mn"
            enc_pass = bytes([ord('a') ^ ord('n')]).decode('latin-1') # "\x0f"
            c.execute("""
                INSERT INTO accounts (account, password, server_type)
                VALUES (?, ?, 'emu')
            """, (acc_name, enc_pass))
            mq_account_id = c.lastrowid
            print(f"Registered Autologin Account: {acc_name} (ID: {mq_account_id}) in login.db")

        # 2. Find or create the profile group
        c.execute("SELECT id FROM profile_groups WHERE name = ?", (group_name,))
        group_row = c.fetchone()
        if group_row:
            group_id = group_row[0]
        else:
            c.execute("INSERT INTO profile_groups (name, eq_path, sort_order, last_selected) VALUES (?, ?, 0, 0)", (group_name, os.path.dirname(eq_path)))
            group_id = c.lastrowid

        # 3. Check if server 'dodl' is registered in servers table
        c.execute("SELECT id FROM servers WHERE short_name = 'dodl'")
        server_row = c.fetchone()
        if server_row:
            server_name = 'dodl'
        else:
            # Get any server or default to 'dodl'
            c.execute("SELECT short_name FROM servers LIMIT 1")
            srv = c.fetchone()
            server_name = srv[0] if srv else 'dodl'

        # 4. Add character to characters table in login.db if not already there
        char_name_lower = char_name.strip().lower()
        c.execute("SELECT id FROM characters WHERE character = ? AND server = ?", (char_name_lower, server_name))
        char_row = c.fetchone()
        if char_row:
            char_id = char_row[0]
        else:
            c.execute("""
                INSERT INTO characters (character, server, account_id, visible)
                VALUES (?, ?, ?, 1)
            """, (char_name_lower, server_name, mq_account_id))
            char_id = c.lastrowid

        # 5. Check if a profile already exists for this character in this group
        c.execute("SELECT id FROM profiles WHERE character_id = ? AND group_id = ?", (char_id, group_id))
        prof_row = c.fetchone()
        if not prof_row:
            # Query maximum sort order to append
            c.execute("SELECT COALESCE(MAX(sort_order), 0) FROM profiles WHERE group_id = ?", (group_id,))
            max_sort = c.fetchone()[0]
            
            c.execute("""
                INSERT INTO profiles (
                    character_id, group_id, eq_path, hotkey, end_after_select,
                    char_select_delay, custom_client_ini, sort_order, will_load,
                    additional_eqgame_args, sounds
                ) VALUES (?, ?, ?, '', 0, 10, ?, ?, 1, '', 1)
            """, (char_id, group_id, eq_path, f"eqclient_{char_name_lower}.ini", max_sort + 1))
            
            # Also create the MacroQuest auto-exec .cfg file so orch_poll runs automatically
            mq_config_dir = os.path.join(BASE_DIR, "MacroQuestRof2", "config")
            cfg_path = os.path.join(mq_config_dir, f"{server_name}_{char_name.capitalize()}.cfg")
            if not os.path.exists(cfg_path):
                try:
                    os.makedirs(mq_config_dir, exist_ok=True)
                    with open(cfg_path, "w") as f:
                        f.write("/lua run orch_poll\n")
                except Exception as ce:
                    print(f"Warning: Could not create {cfg_path}: {ce}")
            
        conn.commit()
        print(f"Added {char_name} to MQ Autologin under group '{group_name}'.")
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()

def sync_mariadb_to_mq_login(login_db_path=DEFAULT_LOGIN_DB, eq_path=DEFAULT_EQ_PATH):
    """
    Syncs character names and account names from PEQ MariaDB character_data 
    to MacroQuest SQLite login.db to make them immediately auto-launchable.
    """
    if not os.path.exists(login_db_path):
        print(f"[Sync] Warning: SQLite login.db not found at {login_db_path}")
        return
        
    # 1. Fetch characters and accounts from MariaDB
    mariadb_chars = []
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT cd.name, a.name AS account_name 
                FROM character_data cd 
                LEFT JOIN account a ON cd.account_id = a.id
            """)
            for row in cursor.fetchall():
                mariadb_chars.append({
                    'name': row['name'].strip().capitalize(),
                    'account': (row['account_name'] or row['name']).strip().lower()
                })
        conn.close()
    except Exception as e:
        print("[Sync] Error fetching characters from MariaDB:", e)
        return

    if not mariadb_chars:
        return

    # 2. Connect to MacroQuest SQLite login.db and synchronize
    try:
        sqlite_conn = sqlite3.connect(login_db_path)
        c = sqlite_conn.cursor()

        # Get existing characters
        c.execute("SELECT LOWER(character) FROM characters")
        existing_chars = {row[0].lower() for row in c.fetchall()}

        # Get Group1 ID or default to 1
        c.execute("SELECT id FROM profile_groups WHERE name = 'Group1'")
        group_row = c.fetchone()
        group_id = group_row[0] if group_row else 1

        # Get server name
        c.execute("SELECT short_name FROM servers LIMIT 1")
        srv = c.fetchone()
        server_name = srv[0] if srv else 'dodl'

        changes_made = False

        for char in mariadb_chars:
            char_name = char['name']
            char_name_lower = char_name.lower()
            
            if char_name_lower in existing_chars:
                continue

            acc_name = char['account']
            
            # Find or create account in SQLite
            c.execute("SELECT id FROM accounts WHERE account = ?", (acc_name,))
            acc_row = c.fetchone()
            if acc_row:
                mq_account_id = acc_row[0]
            else:
                enc_pass = bytes([ord('a') ^ ord('n')]).decode('latin-1') # "\x0f"
                c.execute("""
                    INSERT INTO accounts (account, password, server_type)
                    VALUES (?, ?, 'emu')
                """, (acc_name, enc_pass))
                mq_account_id = c.lastrowid
                print(f"[Sync] Registered Autologin Account: {acc_name} in login.db")

            # Add character with lowercase name
            char_name_lower = char_name.lower()
            c.execute("""
                INSERT INTO characters (character, server, account_id, visible)
                VALUES (?, ?, ?, 1)
            """, (char_name_lower, server_name, mq_account_id))
            char_id = c.lastrowid
            print(f"[Sync] Added character {char_name_lower} to login.db")

            # Add profile in Group1
            c.execute("SELECT COALESCE(MAX(sort_order), 0) FROM profiles WHERE group_id = ?", (group_id,))
            max_sort = c.fetchone()[0]
            c.execute("""
                INSERT INTO profiles (
                    character_id, group_id, eq_path, hotkey, end_after_select,
                    char_select_delay, custom_client_ini, sort_order, will_load,
                    additional_eqgame_args, sounds
                ) VALUES (?, ?, ?, '', 0, 10, ?, ?, 1, '', 1)
            """, (char_id, group_id, eq_path, f"eqclient_{char_name_lower}.ini", max_sort + 1))
            
            changes_made = True

        if changes_made:
            sqlite_conn.commit()
            print("[Sync] MacroQuest login.db synchronized with PEQ MariaDB.")
        sqlite_conn.close()
    except Exception as e:
        print("[Sync] Error writing SQLite login.db:", e)
