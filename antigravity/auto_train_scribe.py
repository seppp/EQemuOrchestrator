import json
import pymysql

def process_characters():
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
    
    try:
        with db.cursor() as cursor:
            # Get all characters
            cursor.execute("SELECT id, name, class, level FROM character_data")
            chars = cursor.fetchall()
            
            # Get all vendor available spells
            cursor.execute("SELECT DISTINCT i.scrolleffect FROM items i JOIN merchantlist m ON i.id = m.item WHERE i.scrolleffect > 0")
            vendor_spells = {row['scrolleffect'] for row in cursor.fetchall()}
            
            for char in chars:
                char_id = char['id']
                char_class = char['class']
                char_level = char['level']
                char_name = char['name']
                
                print(f"Processing {char_name} (Level {char_level} Class {char_class})...")
                
                # 1. Update Skills
                cursor.execute("""
                    SELECT skill_id, MAX(cap) as max_cap 
                    FROM skill_caps 
                    WHERE class_id = %s AND level <= %s AND cap > 0
                    GROUP BY skill_id
                """, (char_class, char_level))
                skill_caps = cursor.fetchall()
                
                new_skills_count = 0
                for sc in skill_caps:
                    skill_id = sc['skill_id']
                    
                    # Check if they have the skill
                    cursor.execute("SELECT value FROM character_skills WHERE id = %s AND skill_id = %s", (char_id, skill_id))
                    existing = cursor.fetchone()
                    
                    if existing:
                        if existing['value'] == 0:
                            cursor.execute("UPDATE character_skills SET value = 1 WHERE id = %s AND skill_id = %s", (char_id, skill_id))
                            new_skills_count += 1
                    else:
                        cursor.execute("INSERT INTO character_skills (id, skill_id, value) VALUES (%s, %s, 1)", (char_id, skill_id))
                        new_skills_count += 1
                
                # 2. Update Spells
                # classesX is the column for the class (1 to 16)
                class_col = f"classes{char_class}"
                cursor.execute(f"SELECT id FROM spells_new WHERE {class_col} <= %s AND {class_col} < 255", (char_level,))
                available_spells = [row['id'] for row in cursor.fetchall() if row['id'] in vendor_spells]
                
                # Get existing spells
                cursor.execute("SELECT spell_id, slot_id FROM character_spells WHERE id = %s", (char_id,))
                existing_spells = {row['spell_id']: row['slot_id'] for row in cursor.fetchall()}
                
                # Find available slots
                used_slots = set(existing_spells.values())
                available_slots = [s for s in range(1000) if s not in used_slots]
                
                spells_to_add = [sp for sp in available_spells if sp not in existing_spells]
                
                for spell_id in spells_to_add:
                    if not available_slots:
                        print(f"  Warning: No more spellbook slots for {char_name}!")
                        break
                    slot = available_slots.pop(0)
                    cursor.execute("INSERT INTO character_spells (id, slot_id, spell_id) VALUES (%s, %s, %s)", (char_id, slot, spell_id))
                
                print(f"  Trained {new_skills_count} new skills (to 1) and scribed {len(spells_to_add)} new spells.")
                
        db.commit()
        print("Done updating all characters.")
    except Exception as e:
        print("Error:", e)
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    process_characters()
