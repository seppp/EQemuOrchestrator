import os
import re
import json
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import pymysql

CONFIG_PATH = '../config.json'
MACROQUEST_LUA_PATH = '../MacroQuestRof2/lua/rgmercs/class_configs/Live'

class RGMercsManager:
    def __init__(self, root):
        self.root = root
        self.root.title("RGMercs Config Manager - RoF2")
        self.root.geometry("900x600")

        self.db = None
        self.configs = {}
        self.current_class = None
        self.current_section = None
        self.current_category = None
        self.max_level = 100

        self.connect_db()
        self.build_ui()
        self.load_configs()

    def connect_db(self):
        try:
            with open(CONFIG_PATH) as f:
                config = json.load(f)
            self.db = pymysql.connect(
                host=config.get('host', '127.0.0.1'),
                user=config.get('user', 'root'),
                password=config.get('password', ''),
                database=config.get('database', 'peq'),
                port=config.get('port', 3306),
                cursorclass=pymysql.cursors.DictCursor
            )
        except Exception as e:
            messagebox.showerror("DB Connection Error", str(e))

    def build_ui(self):
        paned = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Left panel: Classes
        left_frame = ttk.Frame(paned)
        paned.add(left_frame, weight=1)
        ttk.Label(left_frame, text="Classes").pack(anchor=tk.W)
        self.class_list = tk.Listbox(left_frame, exportselection=False)
        self.class_list.pack(fill=tk.BOTH, expand=True)
        self.class_list.bind('<<ListboxSelect>>', self.on_class_select)

        # Middle panel: Categories
        mid_frame = ttk.Frame(paned)
        paned.add(mid_frame, weight=2)
        ttk.Label(mid_frame, text="Categories").pack(anchor=tk.W)
        self.cat_tree = ttk.Treeview(mid_frame, columns=("Section",), show="tree", selectmode="browse")
        self.cat_tree.pack(fill=tk.BOTH, expand=True)
        self.cat_tree.bind('<<TreeviewSelect>>', self.on_cat_select)

        # Right panel: Items
        right_frame = ttk.Frame(paned)
        paned.add(right_frame, weight=3)
        ttk.Label(right_frame, text="Spells/AAs/Items").pack(anchor=tk.W)
        self.item_list = tk.Listbox(right_frame)
        self.item_list.pack(fill=tk.BOTH, expand=True)

        btn_frame = ttk.Frame(right_frame)
        btn_frame.pack(fill=tk.X, pady=5)
        ttk.Button(btn_frame, text="Auto-Clean", command=self.auto_clean).pack(side=tk.LEFT, padx=2)
        ttk.Button(btn_frame, text="Auto-Fill", command=self.auto_fill).pack(side=tk.LEFT, padx=2)
        ttk.Button(btn_frame, text="Manual Add", command=self.manual_add).pack(side=tk.LEFT, padx=2)
        ttk.Button(btn_frame, text="Remove Selected", command=self.remove_selected).pack(side=tk.LEFT, padx=2)
        ttk.Button(btn_frame, text="Save Config", command=self.save_config).pack(side=tk.RIGHT, padx=2)

    def parse_lua(self, filepath):
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

    def load_configs(self):
        if not os.path.exists(MACROQUEST_LUA_PATH):
            messagebox.showerror("Error", f"Path not found: {MACROQUEST_LUA_PATH}")
            return
            
        for file in os.listdir(MACROQUEST_LUA_PATH):
            if file.endswith('_class_config.lua'):
                cls_name = file.split('_')[0]
                data, lines = self.parse_lua(os.path.join(MACROQUEST_LUA_PATH, file))
                if data:
                    self.configs[cls_name] = {"data": data, "lines": lines, "file": file}
                    self.class_list.insert(tk.END, cls_name)

    def on_class_select(self, event):
        sel = self.class_list.curselection()
        if not sel: return
        self.current_class = self.class_list.get(sel[0])
        self.refresh_categories()

    def refresh_categories(self):
        for i in self.cat_tree.get_children():
            self.cat_tree.delete(i)
            
        data = self.configs[self.current_class]["data"]
        
        ab_node = self.cat_tree.insert("", "end", text="AbilitySets", open=True)
        for cat in data["AbilitySets"]:
            self.cat_tree.insert(ab_node, "end", text=cat, tags=("AbilitySets",))
            
        it_node = self.cat_tree.insert("", "end", text="ItemSets", open=True)
        for cat in data["ItemSets"]:
            self.cat_tree.insert(it_node, "end", text=cat, tags=("ItemSets",))
            
        self.item_list.delete(0, tk.END)

    def on_cat_select(self, event):
        sel = self.cat_tree.selection()
        if not sel: return
        item = self.cat_tree.item(sel[0])
        tags = item.get("tags", [])
        if not tags: return
        
        self.current_section = tags[0]
        self.current_category = item["text"]
        self.refresh_items()

    def refresh_items(self):
        self.item_list.delete(0, tk.END)
        if not self.current_category: return
        items = self.configs[self.current_class]["data"][self.current_section][self.current_category]["items"]
        for i in items:
            self.item_list.insert(tk.END, i)

    def auto_clean(self):
        if not self.current_category: return
        items = self.configs[self.current_class]["data"][self.current_section][self.current_category]["items"]
        valid_items = []
        
        with self.db.cursor() as cur:
            for item in items:
                item_esc = self.db.escape_string(item)
                valid = False
                
                if self.current_section == "AbilitySets":
                    # Check spell <= 100
                    cur.execute(f"SELECT id FROM spells_new WHERE name='{item_esc}' AND (classes1 <= 100 OR classes2 <= 100 OR classes3 <= 100 OR classes4 <= 100 OR classes5 <= 100 OR classes6 <= 100 OR classes7 <= 100 OR classes8 <= 100 OR classes9 <= 100 OR classes10 <= 100 OR classes11 <= 100 OR classes12 <= 100 OR classes13 <= 100 OR classes14 <= 100 OR classes15 <= 100 OR classes16 <= 100)")
                    if cur.fetchone():
                        valid = True
                    else:
                        # Check AA
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
                    
        self.configs[self.current_class]["data"][self.current_section][self.current_category]["items"] = valid_items
        self.refresh_items()
        messagebox.showinfo("Auto-Clean", f"Cleaned category. Kept {len(valid_items)} items.")

    def auto_fill(self):
        if not self.current_category or self.current_section != "AbilitySets":
            messagebox.showinfo("Auto-Fill", "Auto-Fill is only supported for AbilitySets.")
            return
            
        items = self.configs[self.current_class]["data"]["AbilitySets"][self.current_category]["items"]
        if not items:
            messagebox.showinfo("Auto-Fill", "Need at least one spell in the list to determine the spell line pattern.")
            return
            
        sample = items[0]
        sample_esc = self.db.escape_string(sample)
        
        new_items = []
        with self.db.cursor() as cur:
            cur.execute(f"SELECT spell_group FROM spells_new WHERE name='{sample_esc}' LIMIT 1")
            res = cur.fetchone()
            if res and res['spell_group'] > 0:
                group_id = res['spell_group']
                # find all spells in this group up to level 100
                q = f"SELECT name FROM spells_new WHERE spell_group={group_id} AND (classes1 <= 100 OR classes2 <= 100 OR classes3 <= 100 OR classes4 <= 100 OR classes5 <= 100 OR classes6 <= 100 OR classes7 <= 100 OR classes8 <= 100 OR classes9 <= 100 OR classes10 <= 100 OR classes11 <= 100 OR classes12 <= 100 OR classes13 <= 100 OR classes14 <= 100 OR classes15 <= 100 OR classes16 <= 100) ORDER BY id DESC"
                cur.execute(q)
                for row in cur.fetchall():
                    if row['name'] not in items and row['name'] not in new_items:
                        new_items.append(row['name'])
            else:
                # Fallback to name pattern matching if spell_group is 0
                prefix = sample.split()[0]
                if len(prefix) > 3:
                    prefix_esc = self.db.escape_string(prefix)
                    q = f"SELECT name FROM spells_new WHERE name LIKE '{prefix_esc}%' AND (classes1 <= 100 OR classes2 <= 100 OR classes3 <= 100 OR classes4 <= 100 OR classes5 <= 100 OR classes6 <= 100 OR classes7 <= 100 OR classes8 <= 100 OR classes9 <= 100 OR classes10 <= 100 OR classes11 <= 100 OR classes12 <= 100 OR classes13 <= 100 OR classes14 <= 100 OR classes15 <= 100 OR classes16 <= 100)"
                    cur.execute(q)
                    for row in cur.fetchall():
                        if row['name'] not in items and row['name'] not in new_items:
                            new_items.append(row['name'])
        
        if new_items:
            # Prepend the newly found items
            self.configs[self.current_class]["data"]["AbilitySets"][self.current_category]["items"] = new_items + items
            self.refresh_items()
            messagebox.showinfo("Auto-Fill", f"Added {len(new_items)} related spells from DB.")
        else:
            messagebox.showinfo("Auto-Fill", "No related spells found.")

    def manual_add(self):
        if not self.current_category: return
        item = simpledialog.askstring("Add Item", "Enter exact Name:")
        if item:
            self.configs[self.current_class]["data"][self.current_section][self.current_category]["items"].insert(0, item)
            self.refresh_items()

    def remove_selected(self):
        sel = self.item_list.curselection()
        if not sel: return
        idx = sel[0]
        del self.configs[self.current_class]["data"][self.current_section][self.current_category]["items"][idx]
        self.refresh_items()

    def save_config(self):
        if not self.current_class: return
        
        cfg = self.configs[self.current_class]
        lines = cfg["lines"]
        data = cfg["data"]
        
        # We need to construct a new list of lines by replacing the chunks
        new_lines = []
        
        # Sort chunks by start_line to process sequentially
        chunks = []
        for sec_name, sec_data in data.items():
            for cat_name, cat_data in sec_data.items():
                chunks.append((cat_data["start_line"], cat_data["end_line"], cat_data["items"]))
                
        chunks.sort(key=lambda x: x[0])
        
        cursor = 0
        for start, end, items in chunks:
            # Add unmodified lines up to start
            new_lines.extend(lines[cursor:start+1])
            # Construct new item lines
            for item in items:
                new_lines.append(f'            "{item}",\n')
            cursor = end
            
        new_lines.extend(lines[cursor:])
        
        filepath = os.path.join(MACROQUEST_LUA_PATH, cfg["file"])
        with open(filepath, 'w') as f:
            f.writelines(new_lines)
            
        # Re-parse to update line numbers in memory
        cfg["data"], cfg["lines"] = self.parse_lua(filepath)
        messagebox.showinfo("Success", f"Saved {cfg['file']}")

if __name__ == "__main__":
    root = tk.Tk()
    app = RGMercsManager(root)
    root.mainloop()
