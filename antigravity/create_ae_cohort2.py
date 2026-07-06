import sys
import os
import sqlite3
import pymysql

sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from db_char_creator import create_character, add_to_mq_login

connection_config = {
    'host': '192.168.178.163',
    'port': 3306,
    'user': 'eqemu',
    'password': 'I8dGa8W7wdEVApPgR6L5lYUe8ig7FHD',
    'database': 'peq',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

# 1. Clean up old 'Ae%' characters from MariaDB
print("Cleaning up old 'Ae' characters from MariaDB...")
conn = pymysql.connect(**connection_config)
with conn.cursor() as cursor:
    cursor.execute("SELECT id, name, account_id FROM character_data WHERE name LIKE 'Ae%'")
    chars = cursor.fetchall()
    for c in chars:
        char_id = c['id']
        acc_id = c['account_id']
        cursor.execute("DELETE FROM character_data WHERE id = %s", (char_id,))
        cursor.execute("DELETE FROM character_skills WHERE id = %s", (char_id,))
        cursor.execute("DELETE FROM character_bind WHERE id = %s", (char_id,))
        cursor.execute("DELETE FROM inventory WHERE character_id = %s", (char_id,))
        cursor.execute("DELETE FROM character_leadership_abilities WHERE id = %s", (char_id,))
        cursor.execute("DELETE FROM character_spells WHERE id = %s", (char_id,))
        
        # also delete from account
        cursor.execute("SELECT lsaccount_id, name FROM account WHERE id = %s", (acc_id,))
        acc_row = cursor.fetchone()
        if acc_row:
            login_acc_id = acc_row['lsaccount_id']
            acc_name = acc_row['name']
            cursor.execute("DELETE FROM account WHERE id = %s", (acc_id,))
            cursor.execute("DELETE FROM account WHERE name = %s AND ls_id = 'eqemu'", (acc_name,))
            if login_acc_id:
                cursor.execute("DELETE FROM login_accounts WHERE id = %s", (login_acc_id,))
conn.commit()
conn.close()

# 2. Clean up from SQLite login.db
print("Cleaning up old 'ae' characters from login.db...")
login_db = r'c:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\config\login.db'
if os.path.exists(login_db):
    try:
        sl = sqlite3.connect(login_db)
        c = sl.cursor()
        c.execute("SELECT id, account_id FROM characters WHERE character LIKE 'ae%'")
        rows = c.fetchall()
        for r in rows:
            c_id, a_id = r
            c.execute("DELETE FROM profiles WHERE character_id = ?", (c_id,))
            c.execute("DELETE FROM characters WHERE id = ?", (c_id,))
            c.execute("DELETE FROM accounts WHERE id = ?", (a_id,))
        sl.commit()
        sl.close()
    except Exception as e:
        print("Error cleaning login.db:", e)

# 3. Create new characters
characters = [
    {"name": "Skadow", "class_id": 5, "group": "AE_Cohort_G1"},
    {"name": "Clerica", "class_id": 2, "group": "AE_Cohort_G1"},
    {"name": "Encaleica", "class_id": 14, "group": "AE_Cohort_G1"},
    {"name": "Encaleicb", "class_id": 14, "group": "AE_Cohort_G1"},
    {"name": "Encaleicc", "class_id": 14, "group": "AE_Cohort_G1"},
    {"name": "Bardia", "class_id": 8, "group": "AE_Cohort_G1"},

    {"name": "Wizman", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "Wizmo", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "Wizmia", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "Wizmer", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "Magica", "class_id": 13, "group": "AE_Cohort_G2"},
    {"name": "Bardib", "class_id": 8, "group": "AE_Cohort_G2"},

    {"name": "Encaleicd", "class_id": 14, "group": "AE_Cohort_G3"},
    {"name": "Clericb", "class_id": 2, "group": "AE_Cohort_G3"},
    {"name": "Druidia", "class_id": 6, "group": "AE_Cohort_G3"},
    {"name": "Shamano", "class_id": 10, "group": "AE_Cohort_G3"},
    {"name": "Necromaniac", "class_id": 11, "group": "AE_Cohort_G3"},
    {"name": "Bardic", "class_id": 8, "group": "AE_Cohort_G3"},
]

for char in characters:
    try:
        race_id = 5 
        if char['class_id'] == 5: race_id = 9
        elif char['class_id'] == 8: race_id = 4
        elif char['class_id'] == 6: race_id = 4
        elif char['class_id'] == 10: race_id = 2
        elif char['class_id'] == 11: race_id = 6
        
        create_character(char['name'], race_id=race_id, class_id=char['class_id'], gender_id=0, deity_id=0)
        add_to_mq_login(char['name'], char['group'])
    except Exception as e:
        print(f"Error creating {char['name']}: {e}")

print("All done!")
