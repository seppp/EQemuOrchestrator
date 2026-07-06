import os
import shutil
import sqlite3
import time

SRC_DIR = r"c:\Users\sigha\OneDrive\Documents\eqemus\everquest_rof2\everquest_rof2"
BASE_DEST_DIR = r"C:\EQ_AE_Fleet"
DB_PATH = r"c:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\config\login.db"

def create_shadow_copy(src, dst):
    os.makedirs(dst, exist_ok=True)
    for root, dirs, files in os.walk(src):
        # Skip if we somehow hit a recursive path
        rel_path = os.path.relpath(root, src)
        dest_dir = dst if rel_path == '.' else os.path.join(dst, rel_path)
        os.makedirs(dest_dir, exist_ok=True)
        
        for f in files:
            # Skip the broken eqgame_{charname}.exe files from the old agent
            if f.lower().startswith('eqgame_') and f.lower().endswith('.exe'):
                continue
                
            src_file = os.path.join(root, f)
            dest_file = os.path.join(dest_dir, f)
            
            if not os.path.exists(dest_file):
                if f.lower() == 'eqclient.ini':
                    shutil.copy2(src_file, dest_file)
                else:
                    try:
                        os.link(src_file, dest_file)
                    except Exception as e:
                        pass # Ignore files in use or permission errors for unimportant files

def main():
    print("Connecting to DB...")
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT id FROM profile_groups WHERE name IN ('AE_Cohort_G1', 'AE_Cohort_G2', 'AE_Cohort_G3')")
    group_ids = [row[0] for row in c.fetchall()]
    
    chars = []
    for gid in group_ids:
        c.execute("""
            SELECT c.character, p.id
            FROM profiles p 
            JOIN characters c ON p.character_id = c.id
            WHERE p.group_id = ?
        """, (gid,))
        chars.extend(c.fetchall())
        
    print(f"Found {len(chars)} characters. Generating shadow fleet...")
    
    for char_name, profile_id in chars:
        char_name = char_name.capitalize()
        char_dest = os.path.join(BASE_DEST_DIR, char_name)
        print(f"Creating shadow folder for {char_name}...")
        create_shadow_copy(SRC_DIR, char_dest)
        
        # Update login.db
        new_eq_path = os.path.join(char_dest, "eqgame.exe")
        c.execute("UPDATE profiles SET eq_path = ? WHERE id = ?", (new_eq_path, profile_id))
        
    conn.commit()
    conn.close()
    print("Done!")

if __name__ == '__main__':
    main()
