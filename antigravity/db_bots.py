import pymysql
import sys

connection_config = {
    'host': '192.168.178.163',
    'port': 3306,
    'user': 'eqemu',
    'password': 'I8dGa8W7wdEVApPgR6L5lYUe8ig7FHD',
    'database': 'peq',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

def check_bots():
    try:
        connection = pymysql.connect(**connection_config)
    except Exception as e:
        print(f"Error connecting: {e}", file=sys.stderr)
        sys.exit(1)
        
    try:
        with connection.cursor() as cursor:
            cursor.execute("SHOW TABLES")
            tables = [list(row.values())[0] for row in cursor.fetchall()]
            
            bot_tables = [t for t in tables if 'bot' in t.lower()]
            
            if not bot_tables:
                print("No bot-related tables found in the database.")
                return
                
            print(f"Found {len(bot_tables)} bot-related tables:")
            print("-" * 50)
            for t in sorted(bot_tables):
                try:
                    cursor.execute(f"SELECT COUNT(*) as count FROM {t}")
                    count = cursor.fetchone()['count']
                    print(f"Table: {t:30} | Rows: {count}")
                except Exception as ex:
                    print(f"Table: {t:30} | Error querying: {ex}")
            
            # If bot_characters exists, let's list some bots!
            bot_char_table = next((t for t in bot_tables if t.lower() == 'bot_characters' or t.lower() == 'bots'), None)
            if bot_char_table:
                print(f"\n--- BOTS IN {bot_char_table.upper()} ---")
                try:
                    cursor.execute(f"SELECT * FROM {bot_char_table} LIMIT 20")
                    bots = cursor.fetchall()
                    if not bots:
                        print("No bots found in the table.")
                    for b in bots:
                        b_name = b.get('name') or b.get('charname') or 'N/A'
                        b_level = b.get('level') or b.get('bot_level') or 'N/A'
                        b_class = b.get('class') or b.get('bot_class') or 'N/A'
                        print(f"Name: {b_name:15} | Level: {b_level:2} | Class ID: {b_class}")
                except Exception as ex:
                    print(f"Error querying bot characters: {ex}")

    finally:
        connection.close()

if __name__ == '__main__':
    check_bots()
