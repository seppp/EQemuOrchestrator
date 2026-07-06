import os
import re
import json
import pymysql

CONFIG_PATH = '../config.json'
MACROQUEST_LUA_PATH = '../MacroQuestRof2/lua/rgmercs/class_configs/Live'

def connect_db():
    with open(CONFIG_PATH) as f:
        config = json.load(f)
    return pymysql.connect(
        host=config.get('host', '127.0.0.1'),
        user=config.get('user', 'root'),
        password=config.get('password', ''),
        database=config.get('database', 'peq'),
        port=config.get('port', 3306),
        cursorclass=pymysql.cursors.DictCursor
    )

def parse_lua(filepath):
    data = {"AbilitySets": {}, "ItemSets": {}}
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
    except:
        return None, []

    in_section = None
    current_cat = None
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("--"):
            continue
            
        if not in_section:
            if re.search(r"\[['\"]AbilitySets['\"]\]\s*=\s*\{", stripped):
                in_section = "AbilitySets"
            elif re.search(r"\[['\"]ItemSets['\"]\]\s*=\s*\{", stripped):
                in_section = "ItemSets"
        else:
            if stripped == "}," and current_cat:
                data[in_section][current_cat]["end_line"] = i
                current_cat = None
            elif stripped == "}," and not current_cat:
                in_section = None
            elif not current_cat:
                m = re.search(r"\[['\"](.+?)['\"]\]\s*=\s*\{", stripped)
                if m:
                    current_cat = m.group(1)
                    data[in_section][current_cat] = {"items": [], "start_line": i, "end_line": -1}
            else:
                if not stripped.startswith("--"):
                    m = re.search(r'["\']([^"\']+)["\']', stripped)
                    if m:
                        data[in_section][current_cat]["items"].append(m.group(1))

    return data, lines

def save_config(filepath, data, lines):
    new_lines = []
    chunks = []
    for sec_name, sec_data in data.items():
        for cat_name, cat_data in sec_data.items():
            chunks.append((cat_data["start_line"], cat_data["end_line"], cat_data["items"]))
            
    chunks.sort(key=lambda x: x[0])
    
    cursor = 0
    for start, end, items in chunks:
        new_lines.extend(lines[cursor:start+1])
        for item in items:
            new_lines.append(f'            "{item}",\n')
        cursor = end
        
    new_lines.extend(lines[cursor:])
    with open(filepath, 'w') as f:
        f.writelines(new_lines)

def process_all():
    db = connect_db()
    
    for file in os.listdir(MACROQUEST_LUA_PATH):
        if not file.endswith('_class_config.lua'):
            continue
            
        filepath = os.path.join(MACROQUEST_LUA_PATH, file)
        data, lines = parse_lua(filepath)
        if not data:
            continue
            
        print(f"Processing {file}...")
        
        # Auto-Clean
        for section in ["AbilitySets", "ItemSets"]:
            for cat, cat_data in data[section].items():
                valid_items = []
                with db.cursor() as cur:
                    for item in cat_data["items"]:
                        item_esc = db.escape_string(item)
                        valid = False
                        if section == "AbilitySets":
                            cur.execute(f"SELECT id FROM spells_new WHERE name='{item_esc}' AND (classes1 <= 100 OR classes2 <= 100 OR classes3 <= 100 OR classes4 <= 100 OR classes5 <= 100 OR classes6 <= 100 OR classes7 <= 100 OR classes8 <= 100 OR classes9 <= 100 OR classes10 <= 100 OR classes11 <= 100 OR classes12 <= 100 OR classes13 <= 100 OR classes14 <= 100 OR classes15 <= 100 OR classes16 <= 100)")
                            if cur.fetchone():
                                valid = True
                            else:
                                cur.execute(f"SELECT first_rank_id FROM aa_ability WHERE name='{item_esc}'")
                                res = cur.fetchone()
                                if res:
                                    cur.execute(f"SELECT level_req FROM aa_ranks WHERE id={res['first_rank_id']}")
                                    rank_res = cur.fetchone()
                                    if rank_res and rank_res['level_req'] <= 100:
                                        valid = True
                        else:
                            cur.execute(f"SELECT id FROM items WHERE Name='{item_esc}'")
                            if cur.fetchone():
                                valid = True
                        if valid:
                            valid_items.append(item)
                data[section][cat]["items"] = valid_items

        # Auto-Fill
        for cat, cat_data in data["AbilitySets"].items():
            items = cat_data["items"]
            if not items:
                continue
                
            sample = items[0]
            sample_esc = db.escape_string(sample)
            new_items = []
            
            with db.cursor() as cur:
                cur.execute(f"SELECT spellgroup FROM spells_new WHERE name='{sample_esc}' LIMIT 1")
                res = cur.fetchone()
                if res and res['spellgroup'] > 0:
                    group_id = res['spellgroup']
                    cur.execute(f"SELECT name FROM spells_new WHERE spellgroup={group_id} AND (classes1 <= 100 OR classes2 <= 100 OR classes3 <= 100 OR classes4 <= 100 OR classes5 <= 100 OR classes6 <= 100 OR classes7 <= 100 OR classes8 <= 100 OR classes9 <= 100 OR classes10 <= 100 OR classes11 <= 100 OR classes12 <= 100 OR classes13 <= 100 OR classes14 <= 100 OR classes15 <= 100 OR classes16 <= 100) ORDER BY id DESC")
                    for row in cur.fetchall():
                        if row['name'] not in items and row['name'] not in new_items:
                            new_items.append(row['name'])
                else:
                    prefix = sample.split()[0]
                    if len(prefix) > 3:
                        prefix_esc = db.escape_string(prefix)
                        cur.execute(f"SELECT name FROM spells_new WHERE name LIKE '{prefix_esc}%' AND (classes1 <= 100 OR classes2 <= 100 OR classes3 <= 100 OR classes4 <= 100 OR classes5 <= 100 OR classes6 <= 100 OR classes7 <= 100 OR classes8 <= 100 OR classes9 <= 100 OR classes10 <= 100 OR classes11 <= 100 OR classes12 <= 100 OR classes13 <= 100 OR classes14 <= 100 OR classes15 <= 100 OR classes16 <= 100)")
                        for row in cur.fetchall():
                            if row['name'] not in items and row['name'] not in new_items:
                                new_items.append(row['name'])
            if new_items:
                data["AbilitySets"][cat]["items"] = new_items + items
                
        save_config(filepath, data, lines)
        print(f"  -> Saved {file}.")
        
if __name__ == "__main__":
    process_all()
