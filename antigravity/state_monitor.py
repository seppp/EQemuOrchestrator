import os
import glob
import json
import time
import threading
import sqlite3
from db_char_creator import DEFAULT_LOGIN_DB

def start_monitor(commands_dir, write_cmd):
    def global_state_monitor():
        while True:
            try:
                # Load all groups
                if not os.path.exists(DEFAULT_LOGIN_DB):
                    time.sleep(5)
                    continue
                conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                c = conn.cursor()
                c.execute("""
                    SELECT g.name, c.character
                    FROM profiles p
                    JOIN profile_groups g ON p.group_id = g.id
                    JOIN characters c ON p.character_id = c.id
                    ORDER BY g.name, p.sort_order ASC
                """)
                rows = c.fetchall()
                conn.close()
                
                groups = {}
                for gname, cname in rows:
                    if gname.lower() == 'gods': continue
                    if gname not in groups:
                        groups[gname] = []
                    groups[gname].append(cname.capitalize())
                
                # Load online status
                online_status = {}
                files = glob.glob(os.path.join(commands_dir, "*.status.json"))
                for f in files:
                    try:
                        with open(f, 'r') as fh:
                            content = json.load(fh)
                            if time.time() - content.get("timestamp", 0) < 10:
                                c_name = content.get("name", "")
                                if "_" in c_name: c_name = c_name.split("_")[-1]
                                online_status[c_name.capitalize()] = content
                    except: pass
                    
                # Form Groups
                group_leaders = []
                all_groups_formed = True
                
                for gname, members in groups.items():
                    leader = members[0]
                    group_leaders.append(leader)
                    all_online = all(m in online_status for m in members)
                    if all_online:
                        # Check if they need grouping
                        for m in members:
                            st = online_status[m]
                            if st.get("group", 0) < len(members) - 1:
                                all_groups_formed = False
                                # Send invite (DISABLED FOR MACRO)
                                #if m != leader:
                                #    write_cmd(leader, f"/invite {m}")
                                #    write_cmd(m, "/invite accept")
                    else:
                        all_groups_formed = False
                
                # Form Raid
                # Raid leader is Bonko
                if all_groups_formed:
                    raid_leader = "Bonko"
                    if raid_leader in online_status:
                        st = online_status[raid_leader]
                        total_raid_members = sum(len(m) for m in groups.values())
                        if st.get("raid", 0) < total_raid_members - 1:
                            # Invite all group leaders (DISABLED FOR MACRO)
                            for gl in group_leaders:
                                if gl != raid_leader and gl in online_status:
                                    pass
                                    #write_cmd(raid_leader, f"/raidinvite {gl}")
                                    # And auto accept
                                    #write_cmd(gl, "/raidaccept")
                
            except Exception as e:
                pass
            time.sleep(5)

    threading.Thread(target=global_state_monitor, daemon=True).start()
