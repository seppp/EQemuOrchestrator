import json
import pymysql
import sys

# Import create_character from db_char_creator
from db_char_creator import create_character, sync_mariadb_to_mq_login

def delete_char(cursor, char_id, name):
    print(f"Deleting character {name} (ID: {char_id})...")
    cursor.execute("DELETE FROM character_data WHERE id = %s", (char_id,))
    cursor.execute("DELETE FROM inventory WHERE character_id = %s", (char_id,))
    cursor.execute("DELETE FROM character_skills WHERE id = %s", (char_id,))
    cursor.execute("DELETE FROM character_bind WHERE id = %s", (char_id,))
    cursor.execute("DELETE FROM character_leadership_abilities WHERE id = %s", (char_id,))
    
    # Try to delete from faction_values if it exists
    try:
        cursor.execute("DELETE FROM faction_values WHERE char_id = %s", (char_id,))
    except Exception as e:
        pass

def recreate_characters():
    with open(r"c:\Users\sigha\OneDrive\Documents\eqemus\config.json", "r") as f:
        config = json.load(f)
        
    db = pymysql.connect(
        host=config["host"],
        port=config["port"],
        user=config["user"],
        password=config["password"],
        database=config["database"],
        cursorclass=pymysql.cursors.DictCursor
    )
    
    chars_to_recreate = [
        {"id": 6, "name": "Bose", "race_id": 12, "class_id": 11, "gender_id": 0, "deity_id": 396}, # Gnome Necro
        {"id": 7, "name": "Wantsit", "race_id": 1, "class_id": 5, "gender_id": 0, "deity_id": 201}, # Human SK
        {"id": 11, "name": "Sleepy", "race_id": 1, "class_id": 7, "gender_id": 0, "deity_id": 396}, # Human Monk
        {"id": 14, "name": "Bracer", "race_id": 2, "class_id": 10, "gender_id": 0, "deity_id": 211} # Barbarian Shaman (The Tribunal)
    ]
    
    try:
        with db.cursor() as cursor:
            for char in chars_to_recreate:
                delete_char(cursor, char["id"], char["name"])
        db.commit()
    except Exception as e:
        print("Error during deletion:", e)
        db.rollback()
        return

    # Now recreate them
    for char in chars_to_recreate:
        try:
            print(f"Recreating {char['name']}...")
            create_character(
                name=char['name'],
                race_id=char['race_id'],
                class_id=char['class_id'],
                gender_id=char['gender_id'],
                deity_id=char['deity_id']
            )
        except Exception as e:
            print(f"Failed to recreate {char['name']}:", e)
            
    # Finally sync Macroquest login
    print("Syncing MQ Login DB...")
    sync_mariadb_to_mq_login()
    print("Done!")

if __name__ == "__main__":
    recreate_characters()
