import sqlite3
import json

import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
conn = sqlite3.connect(os.path.join(BASE_DIR, 'MacroQuestRof2', 'config', 'login.db'))
c = conn.cursor()

c.execute("SELECT id, name FROM profile_groups WHERE name IN ('AE_Cohort_G1', 'AE_Cohort_G2', 'AE_Cohort_G3') ORDER BY name")
groups = c.fetchall()

result = {}
for gid, gname in groups:
    c.execute('''
        SELECT c.character 
        FROM profiles p 
        JOIN characters c ON p.character_id = c.id 
        WHERE p.group_id = ? 
        ORDER BY p.sort_order
    ''', (gid,))
    result[gname] = [row[0].capitalize() for row in c.fetchall()]

conn.close()
print(json.dumps(result, indent=2))
