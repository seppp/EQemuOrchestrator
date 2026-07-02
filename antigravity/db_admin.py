import pymysql
import sys
import argparse

connection_config = {
    'host': '192.168.178.163',
    'port': 3306,
    'user': 'eqemu',
    'password': 'I8dGa8W7wdEVApPgR6L5lYUe8ig7FHD',
    'database': 'peq',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

CLASSES = {
    1: "Warrior", 2: "Cleric", 3: "Paladin", 4: "Ranger", 5: "Shadowknight",
    6: "Druid", 7: "Monk", 8: "Bard", 9: "Rogue", 10: "Shaman", 11: "Necromancer",
    12: "Wizard", 13: "Magician", 14: "Enchanter", 15: "Beastlord", 16: "Berserker"
}

RACES = {
    1: "Human", 2: "Barbarian", 3: "Erudite", 4: "Wood Elf", 5: "High Elf",
    6: "Dark Elf", 7: "Half Elf", 8: "Dwarf", 9: "Troll", 10: "Ogre",
    11: "Halfling", 12: "Gnome", 128: "Iksar", 130: "Vah Shir", 330: "Froglok", 522: "Drakkin"
}

def get_connection():
    return pymysql.connect(**connection_config)

def list_characters():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM character_data ORDER BY name")
            chars = cursor.fetchall()
            print("\n" + "="*80)
            print(f"{'ID':4} | {'Name':15} | {'Level':5} | {'Class':15} | {'Race':12} | {'Zone':15} | {'Plat':8}")
            print("="*80)
            for c in chars:
                class_name = CLASSES.get(c.get('class', 1), f"Unknown ({c.get('class')})")
                race_name = RACES.get(c.get('race', 1), f"Unknown ({c.get('race')})")
                
                # Fetch zone name
                zone_id = c.get('zone_id', 0)
                zone_name = "Unknown"
                if zone_id:
                    cursor.execute("SELECT short_name FROM zone WHERE zoneidnumber = %s", (zone_id,))
                    z = cursor.fetchone()
                    if z:
                        zone_name = z['short_name']
                
                print(f"{c.get('id', 0):4} | {c.get('name', 'N/A'):15} | {c.get('level', 1):5} | {class_name:15} | {race_name:12} | {zone_name:15} | {c.get('platinum', 0):8}")
            print("="*80 + "\n")
    finally:
        conn.close()

def list_bots():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM bot_data ORDER BY name")
            bots = cursor.fetchall()
            print("\n" + "="*85)
            print(f"{'Bot ID':6} | {'Bot Name':15} | {'Lvl':3} | {'Class':15} | {'Race':12} | {'Owner ID':8} | {'Owner Character':15}")
            print("="*85)
            for b in bots:
                class_name = CLASSES.get(b.get('class', 1), f"Unknown ({b.get('class')})")
                race_name = RACES.get(b.get('race', 1), f"Unknown ({b.get('race')})")
                
                # Find owner character name
                owner_id = b.get('owner_id', 0)
                owner_name = "Unknown"
                if owner_id:
                    cursor.execute("SELECT name FROM character_data WHERE id = %s", (owner_id,))
                    owner = cursor.fetchone()
                    if owner:
                        owner_name = owner['name']
                        
                print(f"{b.get('bot_id', 0):6} | {b.get('name', 'N/A'):15} | {b.get('level', 1):3} | {class_name:15} | {race_name:12} | {owner_id:8} | {owner_name:15}")
            print("="*85 + "\n")
    finally:
        conn.close()

def search_items(pattern):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # Let's search using LIKE
            sql = "SELECT id, Name, ac, hp, mana, damage, delay, slots FROM items WHERE Name LIKE %s LIMIT 30"
            cursor.execute(sql, (f"%{pattern}%",))
            items = cursor.fetchall()
            if not items:
                print(f"No items found matching '{pattern}'.")
                return
            print("\n" + "="*90)
            print(f"{'Item ID':7} | {'Item Name':30} | {'AC':4} | {'HP':5} | {'Mana':5} | {'Dmg':4} | {'Dly':4} | {'Slots':8}")
            print("="*90)
            for it in items:
                print(f"{it['id']:7} | {it['Name']:30} | {it['ac']:4} | {it['hp']:5} | {it['mana']:5} | {it['damage']:4} | {it['delay']:4} | {it.get('slots', 0):8}")
            print("="*90 + "\n")
    finally:
        conn.close()

def set_level(char_or_bot_name, level):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # Check character first
            cursor.execute("SELECT id FROM character_data WHERE name = %s", (char_or_bot_name,))
            char = cursor.fetchone()
            if char:
                cursor.execute("UPDATE character_data SET level = %s WHERE id = %s", (level, char['id']))
                conn.commit()
                print(f"Success: Set character '{char_or_bot_name}' (ID: {char['id']}) to Level {level}.")
                return
                
            # Check bot
            cursor.execute("SELECT bot_id FROM bot_data WHERE name = %s", (char_or_bot_name,))
            bot = cursor.fetchone()
            if bot:
                cursor.execute("UPDATE bot_data SET level = %s WHERE bot_id = %s", (level, bot['bot_id']))
                conn.commit()
                print(f"Success: Set bot '{char_or_bot_name}' (Bot ID: {bot['bot_id']}) to Level {level}.")
                return
                
            print(f"Error: No character or bot found with name '{char_or_bot_name}'.")
    finally:
        conn.close()

def add_platinum(char_name, amount):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id, name, platinum FROM character_data WHERE name = %s", (char_name,))
            char = cursor.fetchone()
            if not char:
                print(f"Error: Character '{char_name}' not found.")
                return
                
            new_plat = char['platinum'] + amount
            cursor.execute("UPDATE character_data SET platinum = %s WHERE id = %s", (new_plat, char['id']))
            conn.commit()
            print(f"Success: Added {amount} platinum to '{char_name}'. New total: {new_plat} platinum.")
    finally:
        conn.close()

def add_item_to_inventory(char_name, item_id, charges=1):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # Verify character exists
            cursor.execute("SELECT id FROM character_data WHERE name = %s", (char_name,))
            char = cursor.fetchone()
            if not char:
                print(f"Error: Character '{char_name}' not found.")
                return
            char_id = char['id']
            
            # Verify item exists
            cursor.execute("SELECT id, Name FROM items WHERE id = %s", (item_id,))
            item = cursor.fetchone()
            if not item:
                print(f"Error: Item ID {item_id} not found in database.")
                return
                
            # Find an empty slot in inventory (normally 22 to 29 are main bag slots)
            cursor.execute("SELECT slot_id FROM inventory WHERE character_id = %s", (char_id,))
            filled_slots = {row['slot_id'] for row in cursor.fetchall()}
            
            target_slot = None
            for slot in range(22, 30):  # Check primary inventory slots
                if slot not in filled_slots:
                    target_slot = slot
                    break
                    
            if target_slot is None:
                # If 22-29 are full, let's search for any empty slot between 22 and 100
                for slot in range(22, 120):
                    if slot not in filled_slots:
                        target_slot = slot
                        break
                        
            if target_slot is None:
                print(f"Error: No empty inventory slots found for character '{char_name}'.")
                return
                
            # Insert item into inventory
            sql = """
                INSERT INTO inventory (character_id, slot_id, item_id, charges, color, augment_one, augment_two, augment_three, augment_four, augment_five, augment_six, instnodrop, ornament_icon, ornament_idfile, ornament_hero_model)
                VALUES (%s, %s, %s, %s, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            """
            cursor.execute(sql, (char_id, target_slot, item_id, charges))
            conn.commit()
            print(f"Success: Added '{item['Name']}' (ID: {item_id}, x{charges}) to '{char_name}' in inventory slot {target_slot}.")
    finally:
        conn.close()

def set_account_status(account_name, status_level):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id FROM account WHERE name = %s", (account_name,))
            acc = cursor.fetchone()
            if not acc:
                print(f"Error: Account '{account_name}' not found.")
                return
                
            cursor.execute("UPDATE account SET status = %s WHERE id = %s", (status_level, acc['id']))
            conn.commit()
            print(f"Success: Updated account '{account_name}' status to {status_level}.")
    finally:
        conn.close()

def run_custom_sql(sql):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql)
            if sql.strip().upper().startswith("SELECT") or sql.strip().upper().startswith("SHOW") or sql.strip().upper().startswith("DESCRIBE"):
                results = cursor.fetchall()
                if not results:
                    print("No results returned.")
                    return
                # Get column headers
                headers = list(results[0].keys())
                print("\n" + "| ".join(headers))
                print("-" * (len(headers) * 15))
                for row in results[:30]:
                    print("| ".join(str(row[h]) for h in headers))
                if len(results) > 30:
                    print(f"\n... and {len(results)-30} more rows.")
            else:
                conn.commit()
                print(f"Query executed successfully. Affected rows: {cursor.rowcount}")
    except Exception as ex:
        print(f"SQL Error: {ex}", file=sys.stderr)
    finally:
        conn.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="EQEmulator Database Administration CLI")
    subparsers = parser.add_subparsers(dest="command", help="Admin command to run")
    
    # list-chars
    subparsers.add_parser("list-chars", help="List all characters on the server")
    
    # list-bots
    subparsers.add_parser("list-bots", help="List all bots created on the server")
    
    # search-items
    p_search = subparsers.add_parser("search-items", help="Search items by name")
    p_search.add_argument("name", type=str, help="Item name to search for (partial match)")
    
    # set-level
    p_lvl = subparsers.add_parser("set-level", help="Set the level of a character or bot")
    p_lvl.add_argument("name", type=str, help="Character or bot name")
    p_lvl.add_argument("level", type=int, help="Target level (1-70)")
    
    # add-plat
    p_plat = subparsers.add_parser("add-plat", help="Give platinum to a character")
    p_plat.add_argument("name", type=str, help="Character name")
    p_plat.add_argument("amount", type=int, help="Amount of platinum to add")
    
    # add-item
    p_item = subparsers.add_parser("add-item", help="Add an item to a character's inventory")
    p_item.add_argument("name", type=str, help="Character name")
    p_item.add_argument("item_id", type=int, help="Item Database ID")
    p_item.add_argument("--charges", type=int, default=1, help="Item charges/stack size")
    
    # set-status
    p_status = subparsers.add_parser("set-status", help="Set the status/privilege level of an account")
    p_status.add_argument("account", type=str, help="Account name")
    p_status.add_argument("level", type=int, help="Status level (e.g. 250 for Lead GM, 255 for Admin)")
    
    # sql
    p_sql = subparsers.add_parser("sql", help="Run a custom SQL query")
    p_sql.add_argument("query", type=str, help="SQL query to execute")
    
    args = parser.parse_args()
    
    if args.command == "list-chars":
        list_characters()
    elif args.command == "list-bots":
        list_bots()
    elif args.command == "search-items":
        search_items(args.name)
    elif args.command == "set-level":
        set_level(args.name, args.level)
    elif args.command == "add-plat":
        add_platinum(args.name, args.amount)
    elif args.command == "add-item":
        add_item_to_inventory(args.name, args.item_id, args.charges)
    elif args.command == "set-status":
        set_account_status(args.account, args.level)
    elif args.command == "sql":
        run_custom_sql(args.query)
    else:
        parser.print_help()
