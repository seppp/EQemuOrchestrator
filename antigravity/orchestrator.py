import os
import sys
import json
import glob
import time
import sqlite3
import subprocess
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import pymysql

_server_instance = None  # global reference so handlers can shut down the server
import configparser
import shutil

# Import database configurations and creator logic
import os
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

from db_admin import get_connection, connection_config, add_item_to_inventory
from db_char_creator import create_character, add_to_mq_login, DEFAULT_EQ_PATH, DEFAULT_LOGIN_DB, sync_mariadb_to_mq_login

COMMANDS_DIR = os.path.join(BASE_DIR, "commands")

ACTIVE_SESSIONS = {}
CRASHED_SESSIONS = set()
CPU_CORE_INDEX = 2
MAX_CORES = 32

def ensure_mq_running(silent=False):
    try:
        mq_dir = os.path.join(BASE_DIR, "MacroQuestRof2")
        mq_path = os.path.join(mq_dir, "MacroQuest.exe")
        
        if not os.path.exists(mq_path):
            print(f"Could not find MacroQuest.exe at {mq_path}")
            return
            
        target_size = os.path.getsize(mq_path)
        # Find all executables with the exact same size as MacroQuest.exe (to catch randomized names)
        exes = [os.path.basename(f) for f in glob.glob(os.path.join(mq_dir, "*.exe")) if os.path.getsize(f) == target_size]
        
        output = subprocess.check_output('tasklist', shell=True).decode('utf-8', errors='ignore')
        
        is_running = any(exe in output for exe in exes)
        
        if not is_running:
            print("MacroQuest is not running. Attempting to start it...")
            subprocess.Popen([mq_path], cwd=mq_dir)
            print("MacroQuest started.")
        else:
            if not silent:
                print("MacroQuest is already running.")
    except Exception as e:
        print(f"Error checking/starting MacroQuest: {e}")

def generate_auto_raid_lua(g1, g2, g3):
    def lua_array(lst):
        return "{" + ", ".join(f'"{x}"' for x in lst) + "}"
    
    groups_str = f'    ["{g1[0]}"] = {lua_array(g1[1:])},\n    ["{g2[0]}"] = {lua_array(g2[1:])},\n    ["{g3[0]}"] = {lua_array(g3[1:])}'
    
    return f"""local mq = require('mq')
local me = mq.TLO.Me.CleanName()

local raid_leader = "{g1[0]}"
local g1_leader = "{g1[0]}"
local g2_leader = "{g2[0]}"
local g3_leader = "{g3[0]}"

local groups = {{
{groups_str}
}}

local function log_msg(msg)
    print("\\ay[Auto-Raid]\\aw " .. msg)
    local f = io.open("auto_raid.log", "a")
    if f then
        f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. msg .. "\\n")
        f:close()
    end
end

if me ~= raid_leader then
    log_msg("This script must be run by the raid leader (" .. raid_leader .. "). Exiting.")
    return
end

log_msg("Step 1: Disbanding everyone...")
mq.cmd("/bcaa //disband")
mq.cmd("/bcaa //raiddisband")
mq.delay(2000)

log_msg("Step 2: Forming groups...")
for leader, members in pairs(groups) do
    for _, member in ipairs(members) do
        if leader == raid_leader then
            log_msg("Inviting " .. member .. " to Group 1")
            mq.cmdf("/invite %s", member)
        else
            log_msg("Commanding " .. leader .. " to invite " .. member .. " to their group")
            mq.cmdf("/bct %s //invite %s", leader, member)
        end
        mq.delay(500)
        mq.cmdf("/bct %s //invite", member)
        mq.delay(200)
    end
end

mq.delay(1000)

log_msg("Step 3: Forming Raid...")
local function raid_full()
    return (mq.TLO.Raid.Members() or 0) >= 18
end

local attempts = 0
while not raid_full() and attempts < 10 do
    log_msg("Inviting group leaders to raid (Attempt " .. (attempts+1) .. ")...")
    mq.cmdf("/raidinvite %s", g2_leader)
    mq.cmdf("/raidinvite %s", g3_leader)
    mq.delay(1000)
    
    log_msg("Commanding group leaders to accept raid invite...")
    mq.cmdf("/bct %s //raidaccept", g2_leader)
    mq.cmdf("/bct %s //raidaccept", g3_leader)
    mq.cmd("/bcaa //yes")
    mq.delay(2000)
    
    attempts = attempts + 1
end

if raid_full() then
    log_msg("Success! Full raid assembled.")
else
    log_msg("Warning! Raid formation may have failed. Only " .. (mq.TLO.Raid.Members() or 0) .. " members in raid.")
end
"""

def get_online_characters(max_age=15):
    """Returns a lowercase set of character names that have recently reported status."""
    online_chars = set()
    files = glob.glob(os.path.join(COMMANDS_DIR, "*.status.json"))
    for f in files:
        try:
            with open(f, 'r') as fh:
                content = json.load(fh)
                c_name = content.get("name", "")
                if c_name and time.time() - content.get("timestamp", 0) < max_age:
                    if "_" in c_name:
                        c_name = c_name.split("_")[-1]
                    online_chars.add(c_name.lower())
        except:
            pass
    return online_chars

def watchdog_thread():
    """Background thread that relaunches missing characters in ACTIVE_SESSIONS."""
    print("Watchdog thread started.")
    while True:
        time.sleep(15)
        
        # Check if MacroQuest is running, restart if crashed
        ensure_mq_running(silent=True)
        
        if not ACTIVE_SESSIONS or not os.path.exists(DEFAULT_LOGIN_DB):
            continue
            
        online_chars = get_online_characters(max_age=15)
        now = time.time()
        
        for char_name, launch_time in list(ACTIVE_SESSIONS.items()):
            # Only check characters launched more than 60 seconds ago
            if now - launch_time < 60:
                continue
                
            if char_name.lower() not in online_chars:
                print(f"[Watchdog] {char_name} is offline (logged out or crashed). Removing from active sessions.")
                CRASHED_SESSIONS.add(char_name.lower())
                del ACTIVE_SESSIONS[char_name.lower()]


MAX_CORES = 16
CPU_CORE_INDEX = 0

def get_native_launch_cmd(char_name, eq_path, args, server):
    global CPU_CORE_INDEX
    affinity_mask = hex(1 << CPU_CORE_INDEX)[2:]
    core_str = str(CPU_CORE_INDEX)
    working_dir = os.path.dirname(eq_path)
    ini_path = os.path.join(working_dir, "eqclient.ini")

    if os.path.exists(ini_path):
        import re
        try:
            with open(ini_path, 'r') as f:
                content = f.read()
                
            new_content = content
            if re.search(r'(?i)CPUAffinity\d+=', new_content):
                new_content = re.sub(r'(?i)CPUAffinity\d+=[^\r\n]+', lambda m: m.group(0).split('=')[0] + '=' + core_str, new_content)
            else:
                # Add CPUAffinity settings under [Defaults]
                affinity_lines = "\n" + "\n".join([f"CPUAffinity{i}={core_str}" for i in range(15)]) + "\n"
                if "[Defaults]" in new_content:
                    new_content = new_content.replace("[Defaults]", "[Defaults]" + affinity_lines)
                else:
                    new_content += "\n[Defaults]" + affinity_lines
                    
            if new_content != content:
                with open(ini_path, 'w') as f:
                    f.write(new_content)
        except Exception as e:
            print(f"Warning: Could not modify affinity in {ini_path}: {e}")

    cmd_str = f'start "" /affinity {affinity_mask} "{eq_path}" patchme'
    
    if char_name and char_name.lower() != 'mobsterer':
        cmd_str += " nosound"
    if char_name:
        srv = server if server else "dodl"
        cmd_str += f" /login:{srv}:{char_name}"
        
    CPU_CORE_INDEX = (CPU_CORE_INDEX + 1) % MAX_CORES
    return cmd_str



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

ZONES = {
    394: "Crescent Reach",
    189: "Mines of Gloomingdeep (Tutorial)"
}

DEITIES = {
    396: "Agnostic",
    215: "Tunare",
    104: "Mithaniel Marr",
    201: "Cazic-Thule",
    205: "Innoruuk",
    105: "Karana"
}

EQUIP_SLOTS = {
    0: "Charm", 1: "Ear 1", 2: "Head", 3: "Face", 4: "Ear 2", 5: "Neck",
    6: "Shoulders", 7: "Back", 8: "Chest", 9: "Wrist 1", 10: "Wrist 2",
    11: "Hands", 12: "Finger 1", 13: "Finger 2", 14: "Secondary", 15: "Legs",
    16: "Feet", 17: "Waist", 18: "Arms", 19: "Primary", 20: "Ammo",
    21: "Ranged", 22: "Bag 1", 23: "Bag 2", 24: "Bag 3", 25: "Bag 4",
    26: "Bag 5", 27: "Bag 6", 28: "Bag 7", 29: "Bag 8"
}

HTML_CONTENT = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>EQ Multi-Group Orchestrator</title>
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
        :root {
            --bg-main: #0b0c10;
            --bg-panel: rgba(31, 40, 51, 0.45);
            --border-panel: rgba(255, 255, 255, 0.08);
            --accent-blue: #66fcf1;
            --accent-glow: rgba(102, 252, 241, 0.2);
            --text-primary: #e5e9f0;
            --text-secondary: #c5a3c3;
            --text-muted: #8f9aa8;
            --color-hp: #ff5e62;
            --color-mana: #00f2fe;
            --color-end: #ffb347;
            --color-success: #2ecc71;
            --color-danger: #e74c3c;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-main);
            color: var(--text-primary);
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            height: 100vh;
            box-sizing: border-box;
            overflow: hidden;
            background-image: radial-gradient(circle at 50% 20%, #1f2833 0%, #0b0c10 80%);
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-panel);
        }

        .title-container {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .title {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: -0.5px;
            color: #fff;
            text-shadow: 0 0 10px var(--accent-glow);
        }

        .title span {
            color: var(--accent-blue);
        }

        /* Top-level Tabs Navigation */
        .tab-bar {
            display: flex;
            gap: 5px;
            background: rgba(0, 0, 0, 0.3);
            padding: 4px;
            border-radius: 8px;
            border: 1px solid var(--border-panel);
        }
        .tab-btn {
            background: transparent;
            color: var(--text-muted);
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .tab-btn:hover {
            color: #fff;
            background: rgba(255, 255, 255, 0.05);
        }

        .tab-btn.active {
            color: var(--bg-main);
            background: var(--accent-blue);
            font-weight: 600;
            box-shadow: 0 0 10px var(--accent-glow);
        }

        /* Sub-tab Navigation inside top tabs */
        .sub-tab-bar {
            display: flex;
            gap: 5px;
            background: rgba(0, 0, 0, 0.2);
            padding: 3px;
            border-radius: 6px;
            border: 1px solid var(--border-panel);
            margin-bottom: 12px;
            width: fit-content;
        }

        .sub-tab-btn {
            background: transparent;
            color: var(--text-muted);
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .sub-tab-btn:hover {
            color: #fff;
            background: rgba(255, 255, 255, 0.05);
        }

        .sub-tab-btn.active {
            color: #fff;
            background: rgba(102, 252, 241, 0.15);
            border: 1px solid rgba(102, 252, 241, 0.3);
            font-weight: 600;
        }

        /* Tab Layouts */
        .main-tab-content {
            display: none;
            flex-grow: 1;
            overflow: hidden;
            flex-direction: column;
        }

        .main-tab-content.active {
            display: flex;
        }

        .sub-tab-content {
            display: none;
            flex-grow: 1;
            overflow: hidden;
            flex-direction: column;
        }

        .sub-tab-content.active {
            display: flex;
        }

        .panel {
            background: var(--bg-panel);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border-panel);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 12px;
        }

        .panel-header {
            margin-top: 0;
            border-bottom: 1px solid var(--border-panel);
            padding-bottom: 8px;
            margin-bottom: 12px;
            color: #fff;
        }

        /* Grid layouts */
        .grid-two-col {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 15px;
            flex-grow: 1;
            overflow: hidden;
        }

        .grid-split-equal {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            flex-grow: 1;
            overflow: hidden;
        }

        /* Forms styling */
        .form-row {
            margin-bottom: 10px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .form-row-inline {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        label {
            font-size: 11px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        select, input[type="text"], input[type="number"], input[type="password"] {
            background: rgba(11, 12, 16, 0.6);
            color: #fff;
            border: 1px solid var(--border-panel);
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }

        select:focus, input[type="text"]:focus, input[type="number"]:focus, input[type="password"]:focus {
            border-color: var(--accent-blue);
            box-shadow: 0 0 5px var(--accent-glow);
        }

        button {
            background: var(--accent-blue);
            color: var(--bg-main);
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.2s ease;
        }

        button:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        button.btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.05);
        }

        button.btn-secondary:hover {
            background: rgba(255, 255, 255, 0.15);
        }

        button.btn-danger {
            background: var(--color-danger);
            color: #fff;
        }

        /* Modal Overlay */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            opacity: 0;
            transition: opacity 0.2s ease;
        }

        .modal-overlay.active {
            display: flex;
            opacity: 1;
        }

        .modal-card {
            background: #151a22;
            border: 1px solid var(--border-panel);
            border-radius: 12px;
            padding: 24px;
            width: 90%;
            max-width: 400px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5), 0 0 20px rgba(102, 252, 241, 0.1);
            transform: scale(0.9);
            transition: transform 0.2s ease;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .modal-overlay.active .modal-card {
            transform: scale(1);
        }

        .modal-header {
            font-size: 18px;
            font-weight: 700;
            color: #fff;
            border-bottom: 1px solid var(--border-panel);
            padding-bottom: 10px;
        }

        .modal-body {
            font-size: 14px;
            color: var(--text-primary);
            line-height: 1.5;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 10px;
        }

        /* Characters Dashboard Grid */
        .chars-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            overflow-y: auto;
            max-height: 200px;
            padding-bottom: 10px;
        }

        .char-card {
            background: rgba(11, 12, 16, 0.5);
            border: 1px solid var(--border-panel);
            border-radius: 8px;
            padding: 10px;
            width: 250px;
            position: relative;
            transition: all 0.2s;
        }

        .char-card:hover {
            border-color: var(--accent-blue);
        }

        .char-name {
            font-weight: 700;
            font-size: 14px;
            color: #fff;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .char-info {
            font-size: 11px;
            color: var(--text-muted);
            margin: 4px 0 8px 0;
        }

        .bar-container {
            background: rgba(0, 0, 0, 0.5);
            height: 12px;
            border-radius: 6px;
            margin-bottom: 4px;
            overflow: hidden;
            position: relative;
            border: 1px solid rgba(255,255,255,0.03);
        }

        .bar {
            height: 100%;
            border-radius: 6px;
            transition: width 0.3s ease;
        }

        .hp-bar { background: linear-gradient(90deg, #ff5e62, #ff9966); }
        .mana-bar { background: linear-gradient(90deg, #00f2fe, #4facfe); }
        .end-bar { background: linear-gradient(90deg, #ffb347, #ffcc33); }
        
        .bar-text {
            position: absolute;
            width: 100%;
            text-align: center;
            font-size: 9px;
            line-height: 12px;
            color: #fff;
            font-weight: 700;
            text-shadow: 1px 1px 1px #000;
        }

        /* Console view */
        .console-container {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            overflow: hidden;
        }

        .history {
            background: rgba(5, 5, 5, 0.8);
            border: 1px solid var(--border-panel);
            flex-grow: 1;
            margin-bottom: 8px;
            padding: 10px 15px;
            overflow-y: auto;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            border-radius: 8px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.8);
            max-height: 180px;
        }

        .history-entry {
            margin-bottom: 3px;
            line-height: 1.4;
        }

        .time { color: var(--text-muted); }
        .char { color: var(--accent-blue); font-weight: 600; }
        .cmd { color: #f8c291; }

        .input-row {
            display: flex;
            gap: 10px;
        }

        .input-row input[type="text"] {
            flex-grow: 1;
            font-family: 'JetBrains Mono', monospace;
        }

        .quick-buttons {
            display: flex;
            gap: 5px;
            margin-top: 8px;
            flex-wrap: wrap;
        }

        .btn-quick {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-primary);
            border: 1px solid var(--border-panel);
            padding: 5px 10px;
            font-size: 11px;
            border-radius: 4px;
        }

        .btn-quick:hover {
            background: var(--accent-blue);
            color: var(--bg-main);
            border-color: var(--accent-blue);
        }

        /* Tables and grids for Gearing/Armory */
        .gearing-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            flex-grow: 1;
            overflow: hidden;
            height: 100%;
        }

        .scroll-panel {
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            flex-grow: 1;
            background: rgba(0,0,0,0.2);
            border: 1px solid var(--border-panel);
            border-radius: 8px;
            padding: 10px;
        }

        .gearing-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .gearing-table th {
            text-align: left;
            padding: 8px;
            border-bottom: 2px solid var(--border-panel);
            color: var(--text-muted);
            font-size: 11px;
            text-transform: uppercase;
        }

        .gearing-table td {
            padding: 8px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .gearing-table tr:hover {
            background: rgba(255, 255, 255, 0.02);
        }

        .gearing-table tr.selected {
            background: rgba(102, 252, 241, 0.1);
            border-left: 2px solid var(--accent-blue);
        }

        .results-box {
            background: rgba(0,0,0,0.4);
            border: 1px solid var(--border-panel);
            border-radius: 8px;
            flex-grow: 1;
            overflow-y: auto;
            padding: 8px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            max-height: 250px;
        }

        .item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 8px;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            transition: background 0.2s;
        }

        .item-row:hover {
            background: rgba(255,255,255,0.03);
        }

        .item-details {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .item-name {
            font-weight: 600;
            color: #fff;
        }

        .item-stats {
            font-size: 10px;
            color: var(--text-muted);
        }

        .status-msg {
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 12px;
            font-size: 13px;
            display: none;
        }
        
        .status-msg.success { background: rgba(46, 204, 113, 0.2); border: 1px solid var(--color-success); color: #2ecc71; display: block; }
        .status-msg.error { background: rgba(231, 76, 60, 0.2); border: 1px solid var(--color-danger); color: #e74c3c; display: block; }

        .loader {
            display: inline-block;
            width: 14px;
            height: 14px;
            border: 2px solid rgba(255,255,255,0.2);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
            margin-left: 8px;
            vertical-align: middle;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Raid Control Center CSS */
        .raid-control-center {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            margin-top: 12px;
            flex-shrink: 0;
        }

        .control-group {
            background: rgba(0, 0, 0, 0.25);
            border: 1px solid var(--border-panel);
            border-radius: 8px;
            padding: 10px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .group-title {
            font-size: 11px;
            font-weight: 700;
            color: var(--accent-blue);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 4px;
            margin-bottom: 2px;
        }

        .buttons-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 6px;
        }

        .btn-ctrl {
            background: rgba(255, 255, 255, 0.03);
            color: var(--text-primary);
            border: 1px solid var(--border-panel);
            padding: 8px 6px;
            font-size: 11px;
            font-weight: 600;
            border-radius: 5px;
            cursor: pointer;
            width: 100%;
            height: 100%;
            transition: all 0.2s ease;
            box-sizing: border-box;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        .btn-ctrl:hover {
            background: rgba(102, 252, 241, 0.08);
            border-color: var(--accent-blue);
            color: #fff;
            transform: translateY(-1px);
            box-shadow: 0 0 8px rgba(102, 252, 241, 0.2);
        }

        .btn-ctrl.btn-pause {
            border-color: rgba(255, 94, 98, 0.4);
            color: #ff5e62;
        }
        .btn-ctrl.btn-pause:hover {
            background: rgba(255, 94, 98, 0.1);
            border-color: #ff5e62;
            box-shadow: 0 0 8px rgba(255, 94, 98, 0.25);
        }

        .btn-ctrl.btn-resume {
            border-color: rgba(46, 204, 113, 0.4);
            color: #2ecc71;
        }
        .btn-ctrl.btn-resume:hover {
            background: rgba(46, 204, 113, 0.1);
            border-color: #2ecc71;
            box-shadow: 0 0 8px rgba(46, 204, 113, 0.25);
        }

        .btn-ctrl.btn-danger-glow {
            border-color: rgba(231, 76, 60, 0.4);
            color: #e74c3c;
        }
        .btn-ctrl.btn-danger-glow:hover {
            background: rgba(231, 76, 60, 0.1);
            border-color: #e74c3c;
            box-shadow: 0 0 8px rgba(231, 76, 60, 0.25);
        }

        /* Tooltip container */
        .tooltip {
            position: relative;
            display: block;
            width: 100%;
        }

        /* Tooltip text */
        .tooltip .tooltiptext {
            visibility: hidden;
            width: 220px;
            background-color: rgba(21, 26, 35, 0.95);
            color: var(--text-primary);
            text-align: center;
            border: 1px solid var(--border-panel);
            border-radius: 6px;
            padding: 8px 12px;
            font-size: 12px;
            font-family: 'Inter', sans-serif;
            font-weight: normal;
            text-transform: none;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
            
            /* Position the tooltip */
            position: absolute;
            z-index: 100;
            bottom: 125%; /* Position above the button */
            left: 50%;
            margin-left: -110px;
            
            /* Fade in tooltip */
            opacity: 0;
            transition: opacity 0.2s ease, transform 0.2s ease;
            transform: translateY(5px);
            pointer-events: none;
        }

        /* Tooltip arrow */
        .tooltip .tooltiptext::after {
            content: "";
            position: absolute;
            top: 100%;
            left: 50%;
            margin-left: -5px;
            border-width: 5px;
            border-style: solid;
            border-color: rgba(21, 26, 35, 0.95) transparent transparent transparent;
        }

        /* Show the tooltip text when hovering */
        .tooltip:hover .tooltiptext {
            visibility: visible;
            opacity: 1;
            transform: translateY(0);
        }
    </style>
</head>
<body>
    <div id="crash-banner" style="display:none; background-color:#ff4444; color:white; text-align:center; padding:15px; font-size:18px; font-weight:bold; position:sticky; top:0; z-index:9999; box-shadow: 0 4px 6px rgba(0,0,0,0.3);">
        ⚠️ <span id="crash-text"></span>
        <button onclick="relaunchCrashed()" style="margin-left:20px; background:#fff; color:#ff4444; border:none; padding:8px 16px; font-weight:bold; border-radius:4px; cursor:pointer;">Restart Crashed Clients</button>
        <button onclick="dismissCrash()" style="margin-left:10px; background:transparent; color:#fff; border:1px solid #fff; padding:8px 16px; border-radius:4px; cursor:pointer;">Dismiss</button>
    </div>
    <div class="header">
        <div class="title-container">
            <div class="title">EQ <span>Orchestrator</span></div>
            <div class="tab-bar">
                <button class="tab-btn active" onclick="switchMainTab('tab-char-admin')">Character Admin</button>
                <button class="tab-btn" onclick="switchMainTab('tab-bot-manager')">Bot Manager</button>
                <button class="tab-btn" onclick="switchMainTab('tab-macros-configs')">Macros & Configs</button>
                <button class="tab-btn" onclick="switchMainTab('tab-guides')">Guides</button>
            </div>
        </div>
        <div style="display:flex; align-items:center; gap:8px;">
            <span id="orchestrator-status-label" style="font-size:11px; color:var(--text-muted);"></span>
            <button id="btn-restart-orchestrator" onclick="restartOrchestrator()" title="Restart the orchestrator process" style="background:rgba(255,179,71,0.12); border:1px solid rgba(255,179,71,0.4); color:#ffb347; padding:5px 12px; border-radius:6px; font-size:12px; font-weight:600; cursor:pointer; transition:all 0.2s;">&#x21BA; Restart</button>
            <button id="btn-stop-orchestrator" onclick="stopOrchestrator()" title="Stop the orchestrator process" style="background:rgba(231,76,60,0.12); border:1px solid rgba(231,76,60,0.4); color:#e74c3c; padding:5px 12px; border-radius:6px; font-size:12px; font-weight:600; cursor:pointer; transition:all 0.2s;">&#x25A0; Stop</button>
        </div>
    </div>

    <!-- ==================== TAB 1: CHARACTER ADMIN ==================== -->
    <div id="tab-char-admin" class="main-tab-content active">
        <div class="sub-tab-bar">
            <button class="sub-tab-btn active" onclick="switchSubTab('char-dashboard')">Dashboard & Groups</button>
            <button class="sub-tab-btn" onclick="switchSubTab('char-gearing')">Gearing & Armory</button>
            <button class="sub-tab-btn" onclick="switchSubTab('char-stats')">Stats Editor</button>
            <button class="sub-tab-btn" onclick="switchSubTab('char-scribe')">Scribe & Train</button>
            <button class="sub-tab-btn" onclick="switchSubTab('char-creator')">Character Creator</button>
            <button class="sub-tab-btn" onclick="switchSubTab('char-teleport')">Teleport & Location</button>
        </div>

        <!-- SUB-TAB: DASHBOARD -->
        <div id="char-dashboard" class="sub-tab-content active">
            <div class="panel" style="padding: 10px 15px; margin-bottom: 10px;">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <div style="display:flex; gap:20px; align-items:center; flex-wrap:wrap;">
                        <div style="display:flex; gap:10px; align-items:center;">
                            <span style="font-weight:600; font-size:13px; color:var(--text-muted);">Launch Groups:</span>
                            <div id="group-checkboxes" style="display:flex; gap:10px; flex-wrap:wrap; align-items:center; max-height: 60px; overflow-y: auto;">
                                <span style="font-size:12px; color:var(--text-muted);">Loading...</span>
                            </div>
                            <button onclick="launchSelectedGroups()">Launch Selected</button>
                        </div>
                        <div style="display:flex; gap:10px; align-items:center; border-left: 1px solid var(--border-panel); padding-left:20px;">
                            <span style="font-weight:600; font-size:13px; color:var(--text-muted);">Launch Character:</span>
                            <select id="char-launch-select"><option value="">Loading...</option></select>
                            <button onclick="launchSingleChar()">Launch Character</button>
                        </div>
                    </div>
                    <span id="launch-status" style="color:var(--accent-blue); font-size:13px; font-weight:600;"></span>
                </div>
            </div>

            <div class="grid-two-col">
                <!-- Left panel: Status Cards & Console Console -->
                <div style="display:flex; flex-direction:column; overflow:hidden;">
                    <div class="panel" style="margin-bottom: 10px; flex-shrink:0;">
                        <div class="chars-grid" id="chars-grid">
                            <!-- Character Status Cards -->
                        </div>
                    </div>
                    
                    <div class="console-container">
                        <div class="history" id="history"></div>
                        <div class="input-row">
                            <select id="target-char" style="width:200px;"><option value="all">-- Broadcast to All --</option></select>
                            <input type="text" id="cmd-input" placeholder="Type command (e.g. /say hello) and press Enter..." onkeydown="if(event.key==='Enter') sendCommand()">
                            <button onclick="sendCommand()">Send Command</button>
                        </div>
                        
                        <div class="raid-control-center">
                            <div class="control-group">
                                <div class="group-title">MQ & RGMercs (Lua)</div>
                                <div class="buttons-grid">
                                    <div class="tooltip">
                                        <button class="btn-ctrl btn-pause" onclick="sendQuick('/rglua pause')">Pause Auto</button>
                                        <span class="tooltiptext">Pauses RGMercs combat and casting automation on all box characters. (/rglua pause)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl btn-resume" onclick="sendQuick('/rglua resume')">Resume Auto</button>
                                        <span class="tooltiptext">Resumes RGMercs combat and casting automation on all box characters. (/rglua resume)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="chaseChar()">Chase Char...</button>
                                        <span class="tooltiptext">Forces all characters to chase a specific target. (/chase [name])</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/rglua buff')">Buff Up</button>
                                        <span class="tooltiptext">Forces all characters to trigger their out-of-combat buffing sequences. (/rglua buff)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/invite accept')">Accept Invites</button>
                                        <span class="tooltiptext">Forces all box characters to accept pending group invites. (/invite accept)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="restartRGMercs()">Restart RGMercs</button>
                                        <span class="tooltiptext">Restarts the RGMercs Lua script on all characters. Useful if a client crashes or the script gets stuck.</span>
                                    </div>
                                </div>
                            </div>

                            <div class="control-group">
                                <div class="group-title">Built-in Server Bots</div>
                                <div class="buttons-grid">
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('^guard')">Make Camp (Guard)</button>
                                        <span class="tooltiptext">Anchors bots to their current location (they stand guard and won't follow). (^guard)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('^hold')">Hold Combat</button>
                                        <span class="tooltiptext">Prevents bots from attacking, locking them in passive guard mode. (^hold)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('^release')">Release Hold</button>
                                        <span class="tooltiptext">Releases the combat hold, letting standard bot combat AI resume. (^release)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('^pull')">Pull Target</button>
                                        <span class="tooltiptext">Orders the designated puller bot to run out and pull your current target. (^pull)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('^summon')">Summon Bots</button>
                                        <span class="tooltiptext">Summons all of your spawned bots directly to your coordinates. (^summon)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('^botreport')">Readiness Report</button>
                                        <span class="tooltiptext">Triggers a readiness and inventory check report from spawned bots. (^botreport)</span>
                                    </div>
                                </div>
                            </div>

                            <div class="control-group">
                                <div class="group-title">Raid & Position Actions</div>
                                <div class="buttons-grid">
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/follow')">Follow Me</button>
                                        <span class="tooltiptext">Tells group/raid to follow your current target. (/follow)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/assist')">Assist Me</button>
                                        <span class="tooltiptext">Tells group/raid to assist and target what you are targeting. (/assist)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/sit')">Sit / Rest</button>
                                        <span class="tooltiptext">Forces all characters to sit down. (/sit)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/stand')">Stand</button>
                                        <span class="tooltiptext">Forces all characters to stand up. (/stand)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/attack on')">Attack On</button>
                                        <span class="tooltiptext">Forces all characters to turn auto-attack on. (/attack on)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl btn-danger-glow" onclick="sendQuick('/camp')">Camp (Logout)</button>
                                        <span class="tooltiptext">Logs all characters out to character select. (/camp)</span>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="group-title">Scenarios (MQ)</div>
                                <div class="buttons-grid">
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/camphere')">Make Camp Here</button>
                                        <span class="tooltiptext">Sets group camp anchor at current location. Buffs and rests.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendQuick('/campoff')">Clear Camp</button>
                                        <span class="tooltiptext">Removes camp anchor so group will follow you again.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="assignRole('Tank')">Assign Tank...</button>
                                        <span class="tooltiptext">Assign a character as the main tank.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="assignRole('Main Assist')">Assign Main Assist...</button>
                                        <span class="tooltiptext">Assign a character as the main assist.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="assignRole('Puller')">Assign Puller...</button>
                                        <span class="tooltiptext">Assign a character as the active puller.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl btn-pause" onclick="sendQuick('/rglua puller off')">Stop Pulling</button>
                                        <span class="tooltiptext">Force all bots to stop pulling.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" style="background-color: #3b2a1a;" onclick="saveCamp()">Save Camp WP...</button>
                                        <span class="tooltiptext">Saves current location as an MQ2Nav waypoint.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" style="background-color: #3b2a1a;" onclick="goToCamp()">Go To Camp...</button>
                                        <span class="tooltiptext">Navigates all bots to a saved MQ2Nav waypoint.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" style="background-color: #8B0000; color: white;" onclick="sendQuick('/alt activate 43')">Evacuate (SHTF)</button>
                                        <span class="tooltiptext">Triggers Exodus AA on all characters to evac.</span>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="group-title">GM Operations (Mobsterer)</div>
                                <div class="buttons-grid">
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="gmSummonAll()">Summon All</button>
                                        <span class="tooltiptext">Summons all online characters to Mobsterer.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="gmChase()">Chase Mobsterer</button>
                                        <span class="tooltiptext">Forces all characters to follow Mobsterer.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="gmSummon()">Summon Char...</button>
                                        <span class="tooltiptext">Summons a character to Mobsterer. (#summon)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="gmGoto()">TP To Char...</button>
                                        <span class="tooltiptext">Teleports Mobsterer to a character. (#goto)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="sendAsMobsterer('/lua run summcrp')">Summon Corpses</button>
                                        <span class="tooltiptext">Summons all corpses (/lua run summcrp)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="gmResurrect()">GM Resurrect</button>
                                        <span class="tooltiptext">GM Resurrect target (#resurrect)</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="pushMacrosToAll()">Push Macros to All</button>
                                        <span class="tooltiptext">Generates social macros for all these buttons onto all characters' hotbars.</span>
                                    </div>
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="group-title">AE Farm Control</div>
                                <div class="buttons-grid">
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="launchAECohort()">Launch AE PL Cohort</button>
                                        <span class="tooltiptext">Launches the 18 AE characters automatically.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="formAERaid()">Form AE Raid</button>
                                        <span class="tooltiptext">Groups all 18 AE characters into a single raid and sets Main Assist.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" onclick="aeToggleMode(true)">Enable AE Mode</button>
                                        <span class="tooltiptext">Switches Wizards to AE mode, Bards to twist, and configures Enchanters.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl btn-danger" onclick="aeToggleMode(false)">Disable AE Mode</button>
                                        <span class="tooltiptext">Reverts to default group modes.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl" style="background-color: var(--color-success); color: var(--bg-main);" onclick="aeStartPulling()">Start AFK Pulling</button>
                                        <span class="tooltiptext">Tells the SK to wait for buffs, pull, and activates monitors.</span>
                                    </div>
                                    <div class="tooltip">
                                        <button class="btn-ctrl btn-danger" onclick="aeStopAll()">Stop All</button>
                                        <span class="tooltiptext">Emergency abort: stops pulling and pauses automation.</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right panel: Group Manager -->
                <div class="panel" style="display:flex; flex-direction:column; gap:10px; overflow:hidden;">
                    <h3 class="panel-header" style="margin-bottom: 5px;">Orchestrator Groups</h3>
                    <div id="group-manager-status" class="status-msg"></div>

                    <div style="display:grid; grid-template-columns: 1fr auto auto auto; gap: 8px; align-items: center;">
                        <select id="group-manager-select" onchange="onGroupChanged()"></select>
                        <button class="btn-secondary" onclick="launchManagerGroup()">Launch</button>
                        <button class="btn-secondary" style="border-color:var(--color-success); color:var(--color-success);" onclick="syncIngameGroup()">Form In-Game</button>
                        <button class="btn-secondary" style="border-color:var(--color-danger); color:var(--color-danger);" onclick="deleteSelectedGroup()">Delete</button>
                    </div>

                    <div class="scroll-panel" id="group-members-list" style="margin: 5px 0;">
                        <!-- Members list -->
                    </div>

                    <div style="border-top:1px solid var(--border-panel); padding-top:8px;">
                        <label>Add Character to Group</label>
                        <div style="display:flex; gap:8px; margin-top:4px;">
                            <select id="add-to-group-char" style="flex-grow:1;"></select>
                            <button onclick="addCharacterToGroup()">Add Member</button>
                        </div>
                    </div>

                    <div style="border-top:1px solid var(--border-panel); padding-top:8px; display:flex; gap:8px; align-items:center;">
                        <input type="text" id="new-group-name" placeholder="New Group Name (e.g. Group2)" style="flex-grow:1; padding:6px 10px;">
                        <button onclick="createNewGroup()">Create Group</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- SUB-TAB: GEARING & ARMORY -->
        <div id="char-gearing" class="sub-tab-content">
            <div class="gearing-layout">
                <!-- Equipped items -->
                <div class="panel" style="display:flex; flex-direction:column; overflow:hidden;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; border-bottom:1px solid var(--border-panel); padding-bottom:8px;">
                        <h3 style="margin:0; color:#fff;">Equipped Inventory</h3>
                        <div style="display:flex; gap:10px; align-items:center;">
                            <label>Character:</label>
                            <select id="armory-char-select" onchange="loadCharacterInventory()" style="padding:4px 8px;"></select>
                        </div>
                    </div>
                    
                    <div id="armory-status" class="status-msg"></div>

                    <div style="margin-bottom:8px; font-size:12px; color:var(--text-muted);">
                        Selected Slot: <strong id="selected-slot-label" style="color:var(--accent-blue);">None</strong>
                    </div>

                    <div class="scroll-panel">
                        <table class="gearing-table">
                            <thead>
                                <tr>
                                    <th style="width:50px;">Slot</th>
                                    <th style="width:130px;">Name</th>
                                    <th>Item</th>
                                    <th style="width:80px; text-align:right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="slots-table-body">
                                <tr><td colspan="4" style="text-align:center;">Select a character above</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Item database search & pre-defined kits -->
                <div style="display:flex; flex-direction:column; gap:12px; overflow:hidden;">
                    <div class="panel" style="display:flex; flex-direction:column; margin-bottom:0;">
                        <h3 class="panel-header">Pre-defined Gearing Kits</h3>
                        <p style="font-size:11px; color:var(--text-muted); margin-top:0;">Equips characters with predefined gear presets.</p>
                        <div style="display:flex; flex-wrap:wrap; gap:8px;">
                            <button onclick="applyKit('starter')">Starter Kit</button>
                            <button class="btn-secondary" onclick="applyKit('speed')">Speed & Regen</button>
                            <button class="btn-secondary" style="border-color:#ffcc33; color:#ffcc33;" onclick="applyKit('tank')">Tank Kit</button>
                            <button class="btn-secondary" style="border-color:#00f2fe; color:#00f2fe;" onclick="applyKit('healer')">Healer Kit</button>
                            <button class="btn-secondary" style="border-color:#ff5e62; color:#ff5e62;" onclick="applyKit('caster')">Caster Kit</button>
                        </div>
                    </div>
                    
                    <div class="panel">
                        <h3 class="panel-header">EQBCS Live Chat</h3>
                        <div id="eqbcChat" style="height: 150px; overflow-y: auto; background: var(--bg-darker); border: 1px solid var(--border-color); padding: 5px; font-family: monospace; font-size: 12px; margin-bottom: 15px;">
                            <!-- Chat lines go here -->
                        </div>
                    </div>

                    <div class="panel" style="display:flex; flex-direction:column; flex-grow:1; overflow:hidden; margin-bottom:0;">
                        <h3 class="panel-header">Item Database Search</h3>
                        <div class="input-row" style="margin-bottom:8px;">
                            <input type="text" id="item-search-query" placeholder="Search items by name..." onkeydown="if(event.key==='Enter') searchItems()">
                            <button onclick="searchItems()">Search</button>
                        </div>

                        <div style="display:flex; gap:8px; align-items:center; margin-bottom:8px; background:rgba(0,0,0,0.15); padding:6px; border-radius:6px; border:1px solid var(--border-panel);">
                            <span style="font-size:11px; font-weight:600; color:var(--text-muted); text-transform:uppercase;">Stack Qty/Charges:</span>
                            <input type="number" id="direct-item-charges" value="1" min="1" max="1000" style="width:60px; padding:4px;">
                        </div>

                        <div class="results-box" id="item-search-results" style="flex-grow:1;">
                            <div style="text-align:center; color:var(--text-muted); margin-top:40px;">Search results will appear here. Select a slot on the left and click 'Equip'.</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- SUB-TAB: STATS EDITOR -->
        <div id="char-stats" class="sub-tab-content">
            <div class="panel" style="max-width: 500px; margin: 0 auto; width: 100%;">
                <h3 class="panel-header">Edit Character Level & Stats</h3>
                <div id="stats-status" class="status-msg"></div>

                <div class="form-row">
                    <label>Select Character</label>
                    <select id="stats-char-select" onchange="loadCharacterStats()"></select>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-top:10px;">
                    <div class="form-row">
                        <label>Level (1-70)</label>
                        <input type="number" id="stats-level" value="1" min="1" max="70">
                    </div>
                    <div class="form-row">
                        <label>AA Points</label>
                        <input type="number" id="stats-aa" value="0" min="0">
                    </div>
                </div>

                <div class="form-row" style="margin-top:10px;">
                    <label>Platinum</label>
                    <input type="number" id="stats-plat" value="0" min="0">
                </div>

                <button onclick="saveCharacterStats()" style="width:100%; margin-top:20px; font-size:15px;">Save Stats & Platinum</button>
            </div>
        </div>

        <!-- SUB-TAB: SCRIBE & TRAIN -->
        <div id="char-scribe" class="sub-tab-content">
            <div class="panel" style="max-width: 600px; margin: 0 auto; width: 100%;">
                <h3 class="panel-header">Spellbook & Abilities Trainer</h3>
                <p style="font-size:12px; color:var(--text-muted); margin-top:0;">Scribes buyable spells, disciplines, and trains skills based on character class and level.</p>
                
                <div id="spell-status" class="status-msg"></div>

                <div class="form-row">
                    <label>Select Character</label>
                    <select id="spell-char-select" style="font-size:15px; padding:10px;"></select>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:10px; margin-top:15px;">
                    <button onclick="scribeSpells()">&#x1F4DC; Scribe Spells</button>
                    <button onclick="learnDiscs()" style="background:rgba(102,252,241,0.08); border:1px solid rgba(102,252,241,0.3); color:#66fcf1;">&#x2694;&#xFE0F; Learn Disciplines</button>
                    <button onclick="trainSkills()" style="background:rgba(46,204,113,0.08); border:1px solid rgba(46,204,113,0.3); color:#2ecc71;">&#x1F4AA; Train Skills</button>
                </div>

                <button onclick="scribeAll()" style="width:100%; margin-top:12px; padding:10px; background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.15); color:var(--text-muted);">&#x26A1; Scribe & Train (Selected Character)</button>
                <button onclick="trainAllCharacters()" style="width:100%; margin-top:8px; padding:10px; background:rgba(255,179,71,0.08); border:1px solid rgba(255,179,71,0.35); color:#ffb347;">&#x1F504; Scribe & Train &mdash; ALL Characters</button>
            </div>
        </div>

        <!-- SUB-TAB: CHARACTER CREATOR -->
        <div id="char-creator" class="sub-tab-content">
            <div class="panel" style="max-width: 600px; margin: 0 auto; width: 100%;">
                <h3 class="panel-header">Create New Level 1 Character</h3>
                <p style="font-size:12px; color:var(--text-muted); margin-top:0;">Registers character and a database account automatically.</p>
                
                <div id="creator-status" class="status-msg"></div>
                
                <div class="form-row">
                    <label>Name (Unique Character Name)</label>
                    <input type="text" id="create-name" placeholder="Enter name..." required>
                </div>
                
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-row">
                        <label>Class</label>
                        <select id="create-class"></select>
                    </div>
                    <div class="form-row">
                        <label>Race</label>
                        <select id="create-race"></select>
                    </div>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-row">
                        <label>Gender</label>
                        <select id="create-gender">
                            <option value="0">Male</option>
                            <option value="1">Female</option>
                        </select>
                    </div>
                    <div class="form-row">
                        <label>Deity</label>
                        <select id="create-deity"></select>
                    </div>
                </div>
                
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:15px;">
                    <div class="form-row">
                        <label>MQ AutoLogin Group</label>
                        <select id="create-mq-group"><option value="Group1">Group1</option></select>
                    </div>
                    <div class="form-row">
                        <label>Starting Zone</label>
                        <select id="create-zone"></select>
                    </div>
                </div>
                
                <button onclick="createCharacter()" style="width:100%; margin-top:20px; font-size:15px;">Create Character & Account</button>
            </div>
        </div>

        <!-- SUB-TAB: TELEPORT / LOCATION -->
        <div id="char-teleport" class="sub-tab-content">
            <div class="panel" style="max-width: 600px; margin: 0 auto; width: 100%;">
                <h3 class="panel-header">Location & Porting Control</h3>
                <p style="font-size:12px; color:var(--text-muted); margin-top:0;">Teleports characters. Offline characters are updated directly in DB. Online characters receive warp commands.</p>
                
                <div id="location-status" class="status-msg"></div>

                <div class="form-row">
                    <label>Select Character to Move</label>
                    <select id="location-char-select" style="font-size:15px; padding:8px;">
                        <option value="all">-- Move All Characters --</option>
                    </select>
                </div>

                <div class="form-row">
                    <label>Destination Zone</label>
                    <select id="location-zone-select" onchange="toggleCustomLoc()">
                        <option value="crescent">Crescent Reach (Safe Area)</option>
                        <option value="tutorialb">Gloomingdeep Mines (Tutorial)</option>
                        <option value="poknowledge">Plane of Knowledge (Safe Point)</option>
                        <option value="rivervale">Rivervale</option>
                        <option value="nexus">The Nexus</option>
                        <option value="bazaar">The Bazaar</option>
                        <option value="custom">-- Custom Zone / Coordinates --</option>
                    </select>
                </div>

                <div id="custom-loc-fields" style="display:none; border: 1px solid rgba(255,255,255,0.05); padding:10px; border-radius:6px; background:rgba(0,0,0,0.1); margin-bottom:10px;">
                    <div class="form-row">
                        <label>Custom Zone Shortname</label>
                        <input type="text" id="loc-custom-zone" placeholder="e.g. poknowledge">
                    </div>
                    
                    <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px;">
                        <div class="form-row">
                            <label>X Coord</label>
                            <input type="number" step="any" id="loc-x" placeholder="0.0">
                        </div>
                        <div class="form-row">
                            <label>Y Coord</label>
                            <input type="number" step="any" id="loc-y" placeholder="0.0">
                        </div>
                        <div class="form-row">
                            <label>Z Coord</label>
                            <input type="number" step="any" id="loc-z" placeholder="0.0">
                        </div>
                    </div>
                </div>

                <div style="margin:10px 0 15px 0; display:flex; flex-direction:column; gap:6px;">
                    <label style="display:flex; align-items:center; gap:8px; cursor:pointer; text-transform:none; font-size:13px; font-weight:normal;">
                        <input type="checkbox" id="loc-use-coords"> Specify custom coordinates
                    </label>
                    <label style="display:flex; align-items:center; gap:8px; cursor:pointer; text-transform:none; font-size:13px; font-weight:normal;">
                        <input type="checkbox" id="loc-use-gm"> Use GM Summon command (Requires GM admin online)
                    </label>
                </div>

                <button onclick="moveCharacters()" style="width:100%; font-size:15px; padding:10px;">Move Characters</button>
            </div>
        </div>
    </div>

    <!-- ==================== TAB 2: BOT MANAGER ==================== -->
    <div id="tab-bot-manager" class="main-tab-content">
        <div class="grid-two-col">
            <!-- Left panel: Bot list & Bot creator -->
            <div style="display:flex; flex-direction:column; gap:12px; overflow:hidden;">
                <!-- Bot list table -->
                <div class="panel" style="display:flex; flex-direction:column; flex-grow:1; overflow:hidden; margin-bottom:0;">
                    <h3 class="panel-header">Bots List</h3>
                    <div class="scroll-panel">
                        <table class="gearing-table">
                            <thead>
                                <tr>
                                    <th style="width:40px;">ID</th>
                                    <th>Bot Name</th>
                                    <th style="width:40px;">Lvl</th>
                                    <th>Class</th>
                                    <th>Race</th>
                                    <th>Owner</th>
                                </tr>
                            </thead>
                            <tbody id="bot-list-body">
                                <tr><td colspan="6" style="text-align:center;">Loading bots...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Bot Creator form -->
                <div class="panel" style="flex-shrink:0; margin-bottom:0;">
                    <h3 class="panel-header" style="margin-bottom:6px;">Create Bot</h3>
                    <div id="bot-creator-status" class="status-msg"></div>
                    
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:6px;">
                        <div class="form-row">
                            <label>Bot Name</label>
                            <input type="text" id="new-bot-name" placeholder="Name..." style="padding:6px 10px;">
                        </div>
                        <div class="form-row">
                            <label>Owner Character</label>
                            <select id="new-bot-owner" style="padding:6px 10px;"></select>
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:10px;">
                        <div class="form-row">
                            <label>Class</label>
                            <select id="new-bot-class" style="padding:6px 10px;"></select>
                        </div>
                        <div class="form-row">
                            <label>Race</label>
                            <select id="new-bot-race" style="padding:6px 10px;"></select>
                        </div>
                    </div>

                    <button onclick="createBot()" style="width:100%; padding:8px;">Spawn Bot in DB</button>
                </div>
            </div>

            <!-- Right panel: Bot Editor (Stats + Gearing) -->
            <div style="display:flex; flex-direction:column; gap:12px; overflow:hidden;">
                <!-- Bot Stats Level Editor -->
                <div class="panel" style="flex-shrink:0; margin-bottom:0;">
                    <h3 class="panel-header" style="margin-bottom:4px;">Bot Editor</h3>
                    <div id="bot-editor-summary" style="font-size:12px; font-style:italic; color:var(--text-muted); margin-bottom:8px;">Select a bot on the left to edit.</div>
                    <div id="bot-editor-status" class="status-msg"></div>

                    <div style="display:flex; gap:10px; align-items:center;">
                        <label>Level (1-70):</label>
                        <input type="number" id="bot-stats-level" min="1" max="70" style="width:80px; padding:6px 10px;">
                        <button onclick="saveBotLevel()">Save Level</button>
                    </div>
                </div>

                <!-- Bot Gearing Slots Table -->
                <div class="panel" style="display:flex; flex-direction:column; flex-grow:1; overflow:hidden; margin-bottom:0;">
                    <h3 class="panel-header" style="margin-bottom:6px;">Bot Inventory Slots</h3>
                    
                    <div style="margin-bottom:6px; font-size:12px; color:var(--text-muted);">
                        Selected Slot: <strong id="selected-bot-slot-label" style="color:var(--accent-blue);">None</strong>
                    </div>

                    <div class="gearing-layout">
                        <!-- Slots list -->
                        <div class="scroll-panel">
                            <table class="gearing-table">
                                <thead>
                                    <tr>
                                        <th style="width:40px;">Slot</th>
                                        <th>Slot Name</th>
                                        <th>Equipped Item</th>
                                        <th style="width:70px; text-align:right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="bot-slots-table-body">
                                    <tr><td colspan="4" style="text-align:center; color:var(--text-muted);">Select a bot on the left</td></tr>
                                </tbody>
                            </table>
                        </div>

                        <!-- Bot Item Database Search -->
                        <div style="display:flex; flex-direction:column; gap:8px; overflow:hidden;">
                            <div class="input-row" style="margin-bottom:0;">
                                <input type="text" id="bot-item-search-query" placeholder="Search item..." onkeydown="if(event.key==='Enter') searchBotItems()" style="padding:6px; font-size:12px;">
                                <button onclick="searchBotItems()" style="padding:6px 12px; font-size:12px;">Search</button>
                            </div>

                            <div style="display:flex; gap:5px; align-items:center; background:rgba(0,0,0,0.15); padding:4px; border-radius:4px; border:1px solid var(--border-panel);">
                                <span style="font-size:10px; font-weight:600; color:var(--text-muted); text-transform:uppercase;">Qty/Charges:</span>
                                <input type="number" id="bot-item-charges" value="1" min="1" max="1000" style="width:50px; padding:3px; font-size:11px;">
                            </div>

                            <div class="results-box" id="bot-item-search-results" style="flex-grow:1;">
                                <div style="text-align:center; color:var(--text-muted); margin-top:20px;">Search results. Select slot and equip.</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ==================== TAB 3: MACROS & CONFIGS ==================== -->
    <div id="tab-macros-configs" class="main-tab-content">
        <div class="sub-tab-bar">
            <button class="sub-tab-btn active" onclick="switchSubTab('macro-creator')">Macro Creator</button>
            <button class="sub-tab-btn" onclick="switchSubTab('db-settings')">Database Settings</button>
        </div>

        <!-- SUB-TAB: MACRO CREATOR -->
        <div id="macro-creator" class="sub-tab-content active">
            <div class="grid-two-col">
                <!-- Left panel: Configuration -->
                <div class="panel" style="display:flex; flex-direction:column; gap:12px; overflow:hidden;">
                    <h3 class="panel-header">Macro Parameters</h3>
                    
                    <div id="macro-status" class="status-msg"></div>

                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                        <div class="form-row">
                            <label>Owner Character</label>
                            <select id="macro-owner-select" onchange="onMacroOwnerChanged()"></select>
                        </div>
                        <div class="form-row">
                            <label>Macro Engine</label>
                            <select id="macro-engine">
                                <option value="Standard EQ">Standard EQ (5 Lines Max)</option>
                                <option value="MacroQuest2 (MQ2)">MacroQuest2 (Compressed /multiline)</option>
                            </select>
                        </div>
                    </div>

                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                        <div class="form-row">
                            <label>Command Prefix</label>
                            <select id="macro-prefix">
                                <option value="^">^ (Prefix only)</option>
                                <option value="#bot ">#bot (Command style)</option>
                                <option value="/say ^">/say ^ (Broadcast style)</option>
                            </select>
                        </div>
                        <div class="form-row">
                            <label>Default Stance</label>
                            <select id="macro-stance">
                                <option value="Balanced">Balanced</option>
                                <option value="Passive">Passive</option>
                                <option value="Efficient">Efficient</option>
                                <option value="Reactive">Reactive</option>
                                <option value="Aggressive">Aggressive</option>
                                <option value="Burn">Burn</option>
                                <option value="BurnAE">BurnAE</option>
                            </select>
                        </div>
                    </div>

                    <div style="display:flex; flex-direction:column; flex-grow:1; overflow:hidden;">
                        <label style="margin-bottom:4px; display:block;">Select Bots to Include</label>
                        <div class="scroll-panel" id="macro-bot-checkboxes" style="background:rgba(0,0,0,0.3); padding:10px; border-radius:6px; flex-grow:1; overflow-y:auto;">
                            <!-- Bot checkboxes -->
                        </div>
                    </div>

                    <button onclick="generateMacro()" style="width:100%; font-size:15px; padding:10px;">Generate Macro Commands</button>
                </div>

                <!-- Right panel: Text Output -->
                <div class="panel" style="display:flex; flex-direction:column; gap:10px;">
                    <h3 class="panel-header">Generated Client Macro Commands</h3>
                    <p style="font-size:11px; color:var(--text-muted); margin-top:0;">You can copy this text to write a manual social button, or click 'Write to Character .ini' to inject it directly into the client socials page.</p>

                    <textarea id="macro-output-text" readonly style="flex-grow:1; background:#1b1b1b; color:#2ecc71; border:1px solid var(--border-panel); border-radius:8px; padding:15px; font-family:'JetBrains Mono', monospace; font-size:13px; outline:none; resize:none;"></textarea>

                    <div style="display:flex; gap:10px;">
                        <button onclick="copyMacroToClipboard()" style="flex-grow:1;">Copy to Clipboard</button>
                        <button onclick="writeMacroToIni()" style="flex-grow:1; background:var(--color-success); color:#fff;">Write to Character .ini</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- SUB-TAB: DB SETTINGS -->
        <div id="db-settings" class="sub-tab-content">
            <div class="panel" style="max-width: 500px; margin: 0 auto; width: 100%;">
                <h3 class="panel-header">Database Connection Settings</h3>
                <p style="font-size:11px; color:var(--text-muted); margin-top:0;">Edits credentials in config.json and updates the active server database connections dynamically.</p>
                <div id="db-settings-status" class="status-msg"></div>

                <div class="form-row">
                    <label>MariaDB Host</label>
                    <input type="text" id="db-host" placeholder="127.0.0.1">
                </div>

                <div class="form-row">
                    <label>Port</label>
                    <input type="number" id="db-port" placeholder="3306">
                </div>

                <div class="form-row">
                    <label>Database User</label>
                    <input type="text" id="db-user" placeholder="eqemu">
                </div>

                <div class="form-row">
                    <label>Password</label>
                    <input type="password" id="db-password" placeholder="Password">
                </div>

                <div class="form-row">
                    <label>Database Name</label>
                    <input type="text" id="db-database" placeholder="peq">
                </div>

                <button onclick="saveDBSettings()" style="width:100%; margin-top:20px; font-size:15px;">Save Settings & Reload Connection</button>
            </div>
        </div>
    </div>

    <!-- Custom Confirmation Modal -->
    <div id="confirm-modal" class="modal-overlay">
        <div class="modal-card">
            <div class="modal-header" id="confirm-modal-title">Confirm Action</div>
            <div class="modal-body" id="confirm-modal-body">Are you sure?</div>
            <div class="modal-footer">
                <button class="btn-secondary" id="confirm-modal-cancel" style="background:rgba(255,255,255,0.08); color:#fff; border:1px solid rgba(255,255,255,0.15);">Cancel</button>
                <button id="confirm-modal-confirm" style="background:var(--color-danger); color:#fff;">Delete</button>
            </div>
        </div>
    </div>

    <div id="prompt-modal" class="modal-overlay">
        <div class="modal-card">
            <div class="modal-header" id="prompt-modal-title">Input Required</div>
            <div class="modal-body">
                <input type="text" id="prompt-modal-input" class="form-control" style="width:100%; display:none;">
                <select id="prompt-modal-select" class="form-control" style="width:100%; display:none;"></select>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" id="prompt-modal-cancel" style="background:rgba(255,255,255,0.08); color:#fff; border:1px solid rgba(255,255,255,0.15);">Cancel</button>
                <button class="btn-primary" id="prompt-modal-confirm">OK</button>
            </div>
        </div>
    </div>

    <!-- ==================== TAB 4: GUIDES ==================== -->
    <div id="tab-guides" class="main-tab-content">
        <div class="grid-two-col">
            <div class="panel">
                <h3 class="panel-header">Available Guides</h3>
                <div class="scroll-panel" style="max-height: calc(100vh - 200px);">
                    <table class="gearing-table" id="guides-table">
                        <thead>
                            <tr>
                                <th>Guide Name</th>
                            </tr>
                        </thead>
                        <tbody id="guides-list">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="panel" style="overflow-y: auto; max-height: calc(100vh - 120px);">
                <h3 class="panel-header" id="guide-viewer-title">Guide Viewer</h3>
                <div id="guide-viewer-content" style="line-height: 1.6;">Select a guide to view.</div>
            </div>
        </div>
    </div>

    <script>
        let chars = {};
        
        function switchMainTab(tabId) {
            document.querySelectorAll('.main-tab-content').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.tab-bar > .tab-btn').forEach(b => b.classList.remove('active'));
            
            document.getElementById(tabId).classList.add('active');
            
            const btnMap = {
                'tab-char-admin': 0,
                'tab-bot-manager': 1,
                'tab-macros-configs': 2,
                'tab-guides': 3
            };
            document.querySelectorAll('.tab-bar > .tab-btn')[btnMap[tabId]].classList.add('active');
            
            // Trigger load functions or sub-tabs logic
            if (tabId === 'tab-char-admin') {
                const activeSubBtn = document.querySelector('#tab-char-admin .sub-tab-btn.active');
                if (activeSubBtn) {
                    const onclickStr = activeSubBtn.getAttribute('onclick');
                    const subTabId = onclickStr.match(/'([^']+)'/)[1];
                    switchSubTab(subTabId);
                }
            } else if (tabId === 'tab-bot-manager') {
                loadBotsList();
            } else if (tabId === 'tab-macros-configs') {
                const activeSubBtn = document.querySelector('#tab-macros-configs .sub-tab-btn.active');
                if (activeSubBtn) {
                    const onclickStr = activeSubBtn.getAttribute('onclick');
                    const subTabId = onclickStr.match(/'([^']+)'/)[1];
                    switchSubTab(subTabId);
                }
            } else if (tabId === 'tab-guides') {
                loadGuides();
            }
        }

        function switchSubTab(subTabId) {
            // Determine parent main tab content container
            const container = document.getElementById(subTabId).closest('.main-tab-content');
            
            container.querySelectorAll('.sub-tab-content').forEach(c => c.classList.remove('active'));
            container.querySelectorAll('.sub-tab-btn').forEach(b => b.classList.remove('active'));
            
            document.getElementById(subTabId).classList.add('active');
            
            const btn = Array.from(container.querySelectorAll('.sub-tab-btn')).find(b => b.getAttribute('onclick').includes(subTabId));
            if (btn) btn.classList.add('active');
            
            // Sub-tab loading logic
            if (subTabId === 'char-gearing') {
                loadCharacterInventory();
            } else if (subTabId === 'char-stats') {
                loadCharacterStats();
            } else if (subTabId === 'macro-creator') {
                loadMacroBotList();
            } else if (subTabId === 'db-settings') {
                fetchDBSettings();
            }
        }

        function toggleCustomLoc() {
            const val = document.getElementById('location-zone-select').value;
            const customFields = document.getElementById('custom-loc-fields');
            if (val === 'custom') {
                customFields.style.display = 'block';
                document.getElementById('loc-use-coords').checked = true;
            } else {
                customFields.style.display = 'none';
                document.getElementById('loc-use-coords').checked = false;
            }
        }

        function updateHistory(char, cmd) {
            const h = document.getElementById('history');
            const d = new Date();
            const time = d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0') + ':' + d.getSeconds().toString().padStart(2, '0');
            h.innerHTML += `<div class="history-entry"><span class="time">[${time}]</span> <span class="char">${char}</span>: <span class="cmd">${cmd}</span></div>`;
            h.scrollTop = h.scrollHeight;
        }

        async function assignRole(roleName) {
            const char = await showPrompt(`Select character for ${roleName}:`, true);
            if(char) {
                if(roleName === 'Tank') {
                    sendCommand(`/grouproles set ${char} 1`);
                } else if(roleName === 'Main Assist') {
                    sendCommand(`/grouproles set ${char} 2`);
                } else if(roleName === 'Puller') {
                    sendCommand(`/rglua puller on`);
                    sendCommand(`/grouproles set ${char} 3`);
                }
            }
        }
        async function saveCampWP() {
            const wpName = await showPrompt("Enter a name for this camp waypoint:", false);
            if(wpName) sendCommand(`/nav wp add ${wpName}`);
        }
        async function goToCampWP() {
            const wpName = await showPrompt("Enter the name of the camp waypoint to go to:", false);
            if(wpName) sendCommand(`/nav wp ${wpName}`);
        }
        async function gmSummon() {
            const char = await showPrompt("Select character to summon to Mobsterer:", true);
            if(char) {
                const oldTarget = document.getElementById('target-char').value;
                document.getElementById('target-char').value = 'Mobsterer';
                await sendCommand(`/lua exec mq.cmd('/say #summon ${char}')`);
                document.getElementById('target-char').value = oldTarget;
            }
        }
        async function gmSummonAll() {
            if(!confirm("Are you sure you want to summon ALL online characters to Mobsterer?")) return;
            updateHistory('Mobsterer', 'Summon All');
            try {
                await fetch('/cmd/summon_all', { method: 'POST' });
            } catch(e) { console.error(e); }
        }
        async function aeToggleMode(enable) {
            updateHistory('System', 'Toggle AE Mode: ' + (enable ? 'ON' : 'OFF'));
            try { await fetch('/cmd/ae_toggle', { method: 'POST', body: JSON.stringify({ state: enable }) }); } catch(e) { console.error(e); }
        }
        async function aeStartPulling() {
            updateHistory('System', 'Start AFK Pulling');
            try { await fetch('/cmd/ae_start', { method: 'POST' }); } catch(e) { console.error(e); }
        }
        async function aeStopAll() {
            updateHistory('System', 'Stop AE Automation');
            try { await fetch('/cmd/ae_stop', { method: 'POST' }); } catch(e) { console.error(e); }
        }
        async function gmGoto() {
            const char = await showPrompt("Select character for Mobsterer to TP to:", true);
            if(char) {
                const oldTarget = document.getElementById('target-char').value;
                document.getElementById('target-char').value = 'Mobsterer';
                await sendCommand(`/lua exec mq.cmd('/say #goto ${char}')`);
                document.getElementById('target-char').value = oldTarget;
            }
        }
        async function chaseChar() {
            const char = await showPrompt("Select character to chase:", true);
            if(char) {
                const oldTarget = document.getElementById('target-char').value;
                document.getElementById('target-char').value = 'all';
                await sendCommand(`/chase ${char}`);
                document.getElementById('target-char').value = oldTarget;
            }
        }
        async function gmChase() {
            const oldTarget = document.getElementById('target-char').value;
            document.getElementById('target-char').value = 'all';
            await sendCommand(`/rglua chaseon Mobsterer`);
            document.getElementById('target-char').value = oldTarget;
        }
        async function gmResurrect() {
            const char = await showPrompt("Select character's corpse to resurrect:", true);
            if(char) {
                const oldTarget = document.getElementById('target-char').value;
                
                // Send lua run autores to all characters directly via orchestrator
                document.getElementById('target-char').value = 'all';
                await sendCommand(`/lua run autores`);
                
                // Switch to Mobsterer to cast the spell
                document.getElementById('target-char').value = 'Mobsterer';
                await sendCommand(`/target ${char}'s corpse`);
                
                // Wait 1 second before casting the spell
                setTimeout(async () => {
                    await sendCommand(`/lua exec mq.cmd('/say #castspell 994')`);
                    document.getElementById('target-char').value = oldTarget;
                }, 1000);
            }
        }
        async function pushMacrosToAll() {
            if(!confirm("Are you sure you want to push all Raid Control macros to all characters? You must reload the UI in game after this (/loadskin default).")) return;
            try {
                const res = await fetch('/push_macros_to_all', { method: 'POST' });
                const data = await res.json();
                if(data.success) {
                    alert("Macros successfully pushed to all characters!");
                } else {
                    alert("Error: " + data.error);
                }
            } catch(e) {
                alert("Request failed: " + e);
            }
        }


        async function sendCommand(cmdStr) {
            const cmd = cmdStr || document.getElementById('cmd-input').value;
            if (!cmd) return;
            if (!cmdStr) document.getElementById('cmd-input').value = '';
            
            const target = document.getElementById('target-char').value;
            
            try {
                if (target === 'all') {
                    updateHistory('ALL', cmd);
                    await fetch('/cmd/all', {
                        method: 'POST',
                        body: JSON.stringify({command: cmd})
                    });
                } else {
                    updateHistory(target, cmd);
                    await fetch('/cmd', {
                        method: 'POST',
                        body: JSON.stringify({character: target, command: cmd})
                    });
                }
            } catch (e) {
                console.error(e);
            }
        }
        
        function sendQuick(cmd) { sendCommand(cmd); }
        async function sendAsMobsterer(cmd) {
            updateHistory('Mobsterer', cmd);
            try {
                await fetch('/cmd', {
                    method: 'POST',
                    body: JSON.stringify({character: 'mobsterer', command: cmd})
                });
            } catch(e) {
                console.error("Failed to send command to Mobsterer", e);
            }
        }


        async function restartRGMercs() {
            if (!confirm('Are you sure you want to restart RGMercs on all characters?')) return;
            sendCommand('/lua stop rgmercs');
            await new Promise(r => setTimeout(r, 1000));
            sendCommand('/lua run rgmercs');
        }

        async function launchSelectedGroups() {
            const checkboxes = document.querySelectorAll('input[name="launch_group_cb"]:checked');
            if (checkboxes.length === 0) return;
            const status = document.getElementById('launch-status');
            status.innerText = "Launching...";
            let totalLaunched = 0;
            try {
                for(let cb of checkboxes) {
                    const gid = cb.value;
                    const res = await fetch('/launch_group', {
                        method: 'POST',
                        body: JSON.stringify({group_id: gid})
                    });
                    const data = await res.json();
                    if(data.launched) totalLaunched += data.launched;
                }
                status.innerText = `Launched ${totalLaunched} characters.`;
                setTimeout(() => { status.innerText = ''; }, 5000);
            } catch (e) {
                status.innerText = "Error launching groups.";
            }
        }

        async function stopOrchestrator() {
            if (!confirm('Stop the orchestrator server? The page will stop responding.')) return;
            const label = document.getElementById('orchestrator-status-label');
            label.style.color = 'var(--color-danger)';
            label.innerText = 'Stopping...';
            document.getElementById('btn-stop-orchestrator').disabled = true;
            document.getElementById('btn-restart-orchestrator').disabled = true;
            try {
                await fetch('/shutdown', { method: 'POST' });
            } catch(e) {}
            label.innerText = 'Orchestrator stopped.';
        }

        async function restartOrchestrator() {
            if (!confirm('Restart the orchestrator? The page will reload automatically when it comes back.')) return;
            const label = document.getElementById('orchestrator-status-label');
            const restartBtn = document.getElementById('btn-restart-orchestrator');
            const stopBtn = document.getElementById('btn-stop-orchestrator');
            label.style.color = '#ffb347';
            label.innerText = 'Restarting...';
            restartBtn.disabled = true;
            stopBtn.disabled = true;
            try {
                await fetch('/restart', { method: 'POST' });
            } catch(e) {}
            // Poll until the new instance is up, then reload
            let attempts = 0;
            setTimeout(() => {
                const poll = setInterval(async () => {
                attempts++;
                label.innerText = `Waiting for restart... (${attempts}s)`;
                try {
                    const r = await fetch('/');
                    if (r.ok) {
                        clearInterval(poll);
                        label.innerText = 'Back online — reloading...';
                        setTimeout(() => location.reload(), 500);
                    }
                } catch(e) { /* still down */ }
                if (attempts > 30) {
                    clearInterval(poll);
                    label.style.color = 'var(--color-danger)';
                    label.innerText = 'Restart timed out. Reload manually.';
                    restartBtn.disabled = false;
                    stopBtn.disabled = false;
                }
            }, 1000);
            }, 2000);
        }

        async function fetchGroups() {
            try {
                const res = await fetch('/groups');
                const data = await res.json();
                
                const sel = document.getElementById('group-checkboxes');
                if (sel) sel.innerHTML = '';
                
                const creatorSel = document.getElementById('create-mq-group');
                const currentCreatorVal = creatorSel ? creatorSel.value : '';
                if (creatorSel) creatorSel.innerHTML = '';

                if (data.groups && data.groups.length > 0) {
                    for (let g of data.groups) {
                        if (sel) {
                            sel.innerHTML += `<label style="display:flex; align-items:center; gap:3px;"><input type="checkbox" name="launch_group_cb" value="${g.id}"> ${g.name}</label>`;
                        }
                        if (creatorSel) {
                            creatorSel.innerHTML += `<option value="${g.name}">${g.name}</option>`;
                        }
                    }
                    if (creatorSel && currentCreatorVal) {
                        if (Array.from(creatorSel.options).some(opt => opt.value === currentCreatorVal)) {
                            creatorSel.value = currentCreatorVal;
                        } else {
                            creatorSel.value = data.groups[0].name;
                        }
                    }
                } else {
                    sel.innerHTML = '<option value="">No groups found in login.db</option>';
                    if (creatorSel) {
                        creatorSel.innerHTML = '<option value="">No groups found</option>';
                    }
                }
            } catch(e) {}
        }

        async function fetchStatus() {
            try {
                const res = await fetch('/status');
                const data = await res.json();
                chars = data;
                renderChars();
            } catch(e) {}
        }
        
        function renderChars() {
            const grid = document.getElementById('chars-grid');
            const targetSel = document.getElementById('target-char');
            const currentTarget = targetSel.value;
            
            let html = '';
            
            for (let [name, c] of Object.entries(chars)) {
                const isStale = (Date.now()/1000 - c.timestamp) > 5;
                const opacity = isStale ? 0.4 : 1.0;
                const stateText = isStale ? ' (OFFLINE)' : '';
                
                html += `
                <div class="char-card" style="opacity: ${opacity}">
                    <div class="char-name">${name} <span style="font-size: 10px; color: var(--text-muted);">${stateText}</span></div>
                    <div class="char-info">Lvl ${c.level} ${c.class} - ${c.zone} - ${c.combat_state}</div>
                    
                    <div class="bar-container"><div class="bar hp-bar" style="width: ${c.hp}%"></div><div class="bar-text">${c.hp}% HP</div></div>
                    <div class="bar-container"><div class="bar mana-bar" style="width: ${c.mana}%"></div><div class="bar-text">${c.mana}% MP</div></div>
                    <div class="bar-container"><div class="bar end-bar" style="width: ${c.endurance}%"></div><div class="bar-text">${c.endurance}% END</div></div>
                `;
                
                if (c.target_id > 0) {
                    html += `<div class="bar-container" style="background:#222; margin-top:8px;"><div class="bar hp-bar" style="width: ${c.target_hp}%"></div><div class="bar-text" style="font-size:8px;">TGT: ${c.target_name} (${c.target_hp}%)</div></div>`;
                }
                
                html += `</div>`;
                
            }
            
            grid.innerHTML = html;
        }

        const FALLBACK_COMBINATIONS = [
            {race: 1, class: 1}, {race: 1, class: 2}, {race: 1, class: 3}, {race: 1, class: 4}, {race: 1, class: 5}, {race: 1, class: 6}, {race: 1, class: 7}, {race: 1, class: 8}, {race: 1, class: 9}, {race: 1, class: 11}, {race: 1, class: 12}, {race: 1, class: 13}, {race: 1, class: 14},
            {race: 2, class: 1}, {race: 2, class: 9}, {race: 2, class: 10}, {race: 2, class: 15}, {race: 2, class: 16},
            {race: 3, class: 2}, {race: 3, class: 3}, {race: 3, class: 5}, {race: 3, class: 11}, {race: 3, class: 12}, {race: 3, class: 13}, {race: 3, class: 14},
            {race: 4, class: 1}, {race: 4, class: 4}, {race: 4, class: 6}, {race: 4, class: 8}, {race: 4, class: 9},
            {race: 5, class: 2}, {race: 5, class: 3}, {race: 5, class: 12}, {race: 5, class: 13}, {race: 5, class: 14},
            {race: 6, class: 1}, {race: 6, class: 2}, {race: 6, class: 5}, {race: 6, class: 9}, {race: 6, class: 11}, {race: 6, class: 12}, {race: 6, class: 13}, {race: 6, class: 14},
            {race: 7, class: 1}, {race: 7, class: 3}, {race: 7, class: 4}, {race: 7, class: 6}, {race: 7, class: 8}, {race: 7, class: 9},
            {race: 8, class: 1}, {race: 8, class: 2}, {race: 8, class: 3}, {race: 8, class: 9}, {race: 8, class: 16},
            {race: 9, class: 1}, {race: 9, class: 5}, {race: 9, class: 10}, {race: 9, class: 15}, {race: 9, class: 16},
            {race: 10, class: 1}, {race: 10, class: 5}, {race: 10, class: 10}, {race: 10, class: 15}, {race: 10, class: 16},
            {race: 11, class: 1}, {race: 11, class: 2}, {race: 11, class: 3}, {race: 11, class: 4}, {race: 11, class: 6}, {race: 11, class: 9},
            {race: 12, class: 1}, {race: 12, class: 2}, {race: 12, class: 3}, {race: 12, class: 5}, {race: 12, class: 9}, {race: 12, class: 11}, {race: 12, class: 12}, {race: 12, class: 13}, {race: 12, class: 14},
            {race: 128, class: 1}, {race: 128, class: 5}, {race: 128, class: 7}, {race: 128, class: 10}, {race: 128, class: 11}, {race: 128, class: 15},
            {race: 130, class: 1}, {race: 130, class: 8}, {race: 130, class: 9}, {race: 130, class: 10}, {race: 130, class: 15}, {race: 130, class: 16},
            {race: 330, class: 1}, {race: 330, class: 2}, {race: 330, class: 3}, {race: 330, class: 5}, {race: 330, class: 9}, {race: 330, class: 10}, {race: 330, class: 11}, {race: 330, class: 12},
            {race: 522, class: 1}, {race: 522, class: 2}, {race: 522, class: 3}, {race: 522, class: 4}, {race: 522, class: 5}, {race: 522, class: 6}, {race: 522, class: 7}, {race: 522, class: 8}, {race: 522, class: 9}, {race: 522, class: 11}, {race: 522, class: 12}, {race: 522, class: 13}, {race: 522, class: 14}
        ];

        let creatorCombinations = [];
        let creatorClasses = {};

        function filterClassesForRace() {
            const raceId = parseInt(document.getElementById('create-race').value);
            const classSel = document.getElementById('create-class');
            const previouslySelectedClassId = classSel.value;

            // Find all class IDs allowed for this race
            const allowedClassIds = new Set(
                creatorCombinations
                    .filter(c => c.race === raceId)
                    .map(c => c.class)
            );

            classSel.innerHTML = '';
            for (let [id, name] of Object.entries(creatorClasses)) {
                if (allowedClassIds.has(parseInt(id))) {
                    classSel.innerHTML += `<option value="${id}">${name}</option>`;
                }
            }

            // Restore selection if still valid, otherwise select first option
            if (previouslySelectedClassId && allowedClassIds.has(parseInt(previouslySelectedClassId))) {
                classSel.value = previouslySelectedClassId;
            }
        }

        // Fetch creator meta-data
        async function fetchCreatorMetadata() {
            try {
                const res = await fetch('/classes_races');
                const data = await res.json();
                
                creatorCombinations = data.combinations && data.combinations.length > 0 ? data.combinations : FALLBACK_COMBINATIONS;
                creatorClasses = data.classes;
                
                // Populate race select
                const raceSel = document.getElementById('create-race');
                raceSel.innerHTML = '';
                for (let [id, name] of Object.entries(data.races)) {
                    raceSel.innerHTML += `<option value="${id}">${name}</option>`;
                }
                
                // Remove old event listener and add new one
                raceSel.removeEventListener('change', filterClassesForRace);
                raceSel.addEventListener('change', filterClassesForRace);
                
                // Filter classes
                filterClassesForRace();
                
                // Populate deity select
                const deitySel = document.getElementById('create-deity');
                deitySel.innerHTML = '';
                deitySel.innerHTML += `<option value="0">Default (Class-Specific)</option>`;
                for (let [id, name] of Object.entries(data.deities)) {
                    deitySel.innerHTML += `<option value="${id}">${name}</option>`;
                }
                
                // Populate starting zones
                const zoneSel = document.getElementById('create-zone');
                zoneSel.innerHTML = '';
                for (let [id, name] of Object.entries(data.zones)) {
                    zoneSel.innerHTML += `<option value="${id}">${name}</option>`;
                }
            } catch (e) {
                console.error("Error loading creator metadata:", e);
            }
        }

        const EQUIP_SLOTS = {
            0: "Charm", 1: "Ear 1", 2: "Head", 3: "Face", 4: "Ear 2", 5: "Neck",
            6: "Shoulders", 7: "Back", 8: "Chest", 9: "Wrist 1", 10: "Wrist 2",
            11: "Hands", 12: "Finger 1", 13: "Finger 2", 14: "Secondary", 15: "Legs",
            16: "Feet", 17: "Waist", 18: "Arms", 19: "Primary", 20: "Ammo",
            21: "Ranged", 22: "Bag 1", 23: "Bag 2", 24: "Bag 3", 25: "Bag 4",
            26: "Bag 5", 27: "Bag 6", 28: "Bag 7", 29: "Bag 8"
        };

        // Fetch character list for armory, spellbook, stats, location, and macros tabs
        async function fetchCharactersList() {
            try {
                const res = await fetch('/characters');
                const data = await res.json();
                
                const armorySel = document.getElementById('armory-char-select');
                const spellSel = document.getElementById('spell-char-select');
                const locSel = document.getElementById('location-char-select');
                const statsSel = document.getElementById('stats-char-select');
                const macroSel = document.getElementById('macro-owner-select');
                const targetSel = document.getElementById('target-char');
                
                if (armorySel) armorySel.innerHTML = '';
                if (spellSel) spellSel.innerHTML = '';
                if (locSel) locSel.innerHTML = '<option value="all">-- Move All Characters --</option>';
                if (statsSel) statsSel.innerHTML = '';
                if (macroSel) macroSel.innerHTML = '';
                if (targetSel) {
                    const currentTarget = targetSel.value;
                    targetSel.dataset.currentTarget = currentTarget;
                    targetSel.innerHTML = '<option value="all">-- Broadcast to All --</option>';
                }
                
                for (let char of data.characters) {
                    const optionHtml = `<option value="${char.name}" data-id="${char.id}">${char.name} (Lvl ${char.level} ${char.class_name})</option>`;
                    if (armorySel) armorySel.innerHTML += optionHtml;
                    if (spellSel) spellSel.innerHTML += optionHtml;
                    if (locSel) locSel.innerHTML += optionHtml;
                    if (statsSel) statsSel.innerHTML += optionHtml;
                    if (macroSel) macroSel.innerHTML += `<option value="${char.name}">${char.name}</option>`;
                    if (targetSel) targetSel.innerHTML += `<option value="${char.name}">${char.name}</option>`;
                }
                
                if (targetSel && targetSel.dataset.currentTarget) {
                    if (Array.from(targetSel.options).some(opt => opt.value === targetSel.dataset.currentTarget)) {
                        targetSel.value = targetSel.dataset.currentTarget;
                    }
                }
                
                if (statsSel && statsSel.value) loadCharacterStats();
                if (macroSel && macroSel.value) onMacroOwnerChanged();
            } catch (e) {
                console.error(e);
            }
        }

        async function createCharacter() {
            const status = document.getElementById('creator-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const name = document.getElementById('create-name').value.trim();
            const class_id = parseInt(document.getElementById('create-class').value);
            const race_id = parseInt(document.getElementById('create-race').value);
            const gender_id = parseInt(document.getElementById('create-gender').value);
            const deity_id = parseInt(document.getElementById('create-deity').value);
            const group_name = document.getElementById('create-mq-group').value.trim();
            const zone_id = parseInt(document.getElementById('create-zone').value);

            if (!name) {
                status.innerText = "Error: Please enter a character name.";
                status.classList.add('error');
                return;
            }

            try {
                const res = await fetch('/create_character', {
                    method: 'POST',
                    body: JSON.stringify({
                        name, class_id, race_id, gender_id, deity_id, group_name, zone_id
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.classList.add('error');
                } else {
                    status.innerText = `Successfully created character ${data.name} and registered in AutoLogin!`;
                    status.classList.add('success');
                    document.getElementById('create-name').value = '';
                    fetchCharactersList();
                    fetchGroups();
                    fetchLaunchableCharacters();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.classList.add('error');
            }
        }

        // Armory Search
        async function searchItems() {
            const query = document.getElementById('item-search-query').value.trim();
            if (!query) return;

            const resultsBox = document.getElementById('item-search-results');
            resultsBox.innerHTML = '<div style="text-align:center; margin-top:40px;"><div class="loader"></div> Searching...</div>';

            try {
                const res = await fetch('/search_items?q=' + encodeURIComponent(query));
                const data = await res.json();
                resultsBox.innerHTML = '';
                
                if (data.items && data.items.length > 0) {
                    for (let it of data.items) {
                        resultsBox.innerHTML += `
                            <div class="item-row">
                                <div class="item-details">
                                    <div class="item-name">${it.Name} (ID: ${it.id})</div>
                                    <div class="item-stats">HP: ${it.hp} | Mana: ${it.mana} | AC: ${it.ac} | Dmg: ${it.damage} | Dly: ${it.delay}</div>
                                </div>
                                <div style="display:flex; gap:5px;">
                                    <button class="btn-quick" onclick="equipCharacterItem('${it.id}')">Equip</button>
                                    <button class="btn-quick" style="border-color:var(--text-muted); color:var(--text-muted);" onclick="grantSearchedItem('${it.id}', '${escapeHtml(it.Name)}')">Grant</button>
                                </div>
                            </div>
                        `;
                    }
                } else {
                    resultsBox.innerHTML = '<div style="text-align:center; color:var(--text-muted); margin-top:40px;">No items found.</div>';
                }
            } catch (e) {
                resultsBox.innerHTML = '<div style="text-align:center; color:var(--color-danger); margin-top:40px;">Error searching items.</div>';
            }
        }

        function escapeHtml(str) {
            return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        async function grantSearchedItem(itemId, itemName) {
            const status = document.getElementById('armory-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const charName = document.getElementById('armory-char-select').value;
            const chargesInput = document.getElementById('direct-item-charges');
            const charges = parseInt(chargesInput ? chargesInput.value : 1) || 1;

            if (!charName || !itemId) {
                status.innerText = "Error: Please select a character and item ID.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }

            try {
                const res = await fetch('/grant_item', {
                    method: 'POST',
                    body: JSON.stringify({ character_name: charName, item_id: parseInt(itemId), charges: charges })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Granted ${itemName} (ID: ${itemId}) to ${charName}!`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    loadCharacterInventory();
                }
            } catch (e) {
                status.innerText = "Error granting item.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function applyKit(kitType) {
            const status = document.getElementById('armory-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const charName = document.getElementById('armory-char-select').value;
            if (!charName) {
                status.innerText = "Error: Please select a character.";
                status.classList.add('error');
                return;
            }

            try {
                const res = await fetch('/apply_kit', {
                    method: 'POST',
                    body: JSON.stringify({ character_name: charName, kit_type: kitType })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.classList.add('error');
                } else {
                    status.innerText = data.message;
                    status.classList.add('success');
                }
            } catch (e) {
                status.innerText = "Error applying kit.";
                status.classList.add('error');
            }
        }

        async function scribeSpells() {
            const status = document.getElementById('spell-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const select = document.getElementById('spell-char-select');
            const charName = select.value;
            const option = select.options[select.selectedIndex];
            const charId = option ? option.getAttribute('data-id') : null;

            if (!charId) {
                status.innerText = "Error: Please select a character.";
                status.classList.add('error');
                return;
            }

            status.innerText = "Scribing spells...";
            status.classList.add('success');
            status.style.display = 'block';
            try {
                const res = await fetch('/scribe_spells', {
                    method: 'POST',
                    body: JSON.stringify({ character_id: parseInt(charId) })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                } else {
                    status.innerText = data.message;
                    status.className = 'status-msg success';
                }
            } catch (e) {
                status.innerText = "Error scribing spells.";
                status.className = 'status-msg error';
            }
            status.style.display = 'block';
        }

        async function learnDiscs() {
            const status = document.getElementById('spell-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const select = document.getElementById('spell-char-select');
            const option = select.options[select.selectedIndex];
            const charId = option ? option.getAttribute('data-id') : null;

            if (!charId) {
                status.innerText = "Error: Please select a character.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }

            status.innerText = "Learning disciplines...";
            status.className = 'status-msg success';
            status.style.display = 'block';
            try {
                const res = await fetch('/learn_disciplines', {
                    method: 'POST',
                    body: JSON.stringify({ character_id: parseInt(charId) })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                } else {
                    status.innerText = data.message;
                    status.className = 'status-msg success';
                }
            } catch (e) {
                status.innerText = "Error learning disciplines.";
                status.className = 'status-msg error';
            }
            status.style.display = 'block';
        }

        async function trainSkills() {
            const status = document.getElementById('spell-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const select = document.getElementById('spell-char-select');
            const option = select.options[select.selectedIndex];
            const charId = option ? option.getAttribute('data-id') : null;

            if (!charId) {
                status.innerText = "Error: Please select a character.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }

            status.innerText = "Training skills...";
            status.className = 'status-msg success';
            status.style.display = 'block';
            try {
                const res = await fetch('/train_skills', {
                    method: 'POST',
                    body: JSON.stringify({ character_id: parseInt(charId) })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                } else {
                    status.innerText = data.message;
                    status.className = 'status-msg success';
                }
            } catch (e) {
                status.innerText = "Error training skills.";
                status.className = 'status-msg error';
            }
            status.style.display = 'block';
        }

        async function scribeAll() {
            const status = document.getElementById('spell-status');
            status.className = 'status-msg success';
            status.style.display = 'block';

            const select = document.getElementById('spell-char-select');
            const option = select.options[select.selectedIndex];
            const charId = option ? option.getAttribute('data-id') : null;

            if (!charId) {
                status.innerText = "Error: Please select a character.";
                status.className = 'status-msg error';
                return;
            }

            const id = parseInt(charId);
            const msgs = [];

            const endpoints = [
                ['/scribe_spells', 'Scribing spells...'],
                ['/learn_disciplines', 'Learning disciplines...'],
                ['/train_skills', 'Training skills...']
            ];

            for (let [url, label] of endpoints) {
                status.innerText = label;
                try {
                    const res = await fetch(url, { method: 'POST', body: JSON.stringify({ character_id: id }) });
                    const data = await res.json();
                    msgs.push(data.message || data.error || 'Done');
                } catch(e) {
                    msgs.push(`${url} failed`);
                }
            }

            status.innerText = msgs.join(' | ');
        }

        async function trainAllCharacters() {
            const status = document.getElementById('spell-status');
            status.className = 'status-msg success';
            status.style.display = 'block';
            status.innerText = 'Training all characters... (this may take a moment)';

            const btn = document.querySelector('button[onclick="trainAllCharacters()"]');
            if (btn) btn.disabled = true;

            try {
                const res = await fetch('/train_all', { method: 'POST', body: JSON.stringify({}) });
                const data = await res.json();

                if (data.error) {
                    status.innerText = 'Error: ' + data.error;
                    status.className = 'status-msg error';
                } else {
                    // Show a summary breakdown
                    let html = `<strong style="color:#66fcf1;">Done &mdash; ${data.count} character(s) updated</strong><div style="margin-top:10px; max-height:300px; overflow-y:auto; font-size:11px; line-height:1.8;">`;
                    for (let r of data.results) {
                        html += `<div style="border-bottom:1px solid rgba(255,255,255,0.05); padding:3px 0;"><span style="color:#fff; font-weight:600;">${r.name}</span> &mdash; <span style="color:var(--text-muted);">${r.result}</span></div>`;
                    }
                    html += '</div>';
                    status.innerHTML = html;
                    status.className = 'status-msg success';
                }
            } catch(e) {
                status.innerText = 'Error connecting to server.';
                status.className = 'status-msg error';
            }

            if (btn) btn.disabled = false;
        }

        // Location Movement API
        async function moveCharacters() {
            const status = document.getElementById('location-status');
            status.className = 'status-msg';
            status.style.display = 'none';

            const charName = document.getElementById('location-char-select').value;
            const zoneSelect = document.getElementById('location-zone-select').value;
            
            let zoneName = zoneSelect;
            if (zoneSelect === 'custom') {
                zoneName = document.getElementById('loc-custom-zone').value.trim();
            }

            if (!zoneName) {
                status.innerText = "Error: Please specify a destination zone.";
                status.classList.add('error');
                return;
            }

            const useCoords = document.getElementById('loc-use-coords').checked;
            const useGm = document.getElementById('loc-use-gm').checked;
            
            let x = 0.0, y = 0.0, z = 0.0;
            if (useCoords) {
                x = parseFloat(document.getElementById('loc-x').value) || 0.0;
                y = parseFloat(document.getElementById('loc-y').value) || 0.0;
                z = parseFloat(document.getElementById('loc-z').value) || 0.0;
            }

            try {
                const res = await fetch('/move_character', {
                    method: 'POST',
                    body: JSON.stringify({
                        character_name: charName,
                        zone_name: zoneName,
                        use_coords: useCoords,
                        x: x,
                        y: y,
                        z: z,
                        use_gm: useGm
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.classList.add('error');
                } else {
                    status.innerText = data.message;
                    status.classList.add('success');
                }
            } catch(e) {
                status.innerText = "Error moving characters.";
                status.classList.add('error');
            }
        }

        async function fetchLaunchableCharacters() {
            try {
                const res = await fetch('/launchable_characters');
                const data = await res.json();
                const sel = document.getElementById('char-launch-select');
                sel.innerHTML = '';
                if (data.characters && data.characters.length > 0) {
                    for (let c of data.characters) {
                        sel.innerHTML += `<option value="${c}">${c}</option>`;
                    }
                } else {
                    sel.innerHTML = '<option value="">No characters in login.db</option>';
                }
            } catch(e) {}
        }

        async function launchSingleChar() {
            const charName = document.getElementById('char-launch-select').value;
            if (!charName) return;
            const status = document.getElementById('launch-status');
            status.innerText = "Launching...";
            try {
                const res = await fetch('/launch_character', {
                    method: 'POST',
                    body: JSON.stringify({character_name: charName})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                } else {
                    status.innerText = data.launched ? `Launched ${charName}!` : `Failed to launch.`;
                    setTimeout(() => { status.innerText = ''; }, 5000);
                }
            } catch (e) {
                status.innerText = "Error launching character.";
            }
        }

        async function fetchGroupManagerDetails() {
            try {
                const res = await fetch('/group_details');
                const data = await res.json();
                
                const managerSel = document.getElementById('group-manager-select');
                const currentVal = managerSel.value;
                
                managerSel.innerHTML = '';
                
                if (data.groups && data.groups.length > 0) {
                    for (let g of data.groups) {
                        managerSel.innerHTML += `<option value="${g.id}">${g.name}</option>`;
                    }
                    if (currentVal && Array.from(managerSel.options).some(opt => opt.value === currentVal)) {
                        managerSel.value = currentVal;
                    } else {
                        managerSel.value = data.groups[0].id;
                    }
                } else {
                    managerSel.innerHTML = '<option value="">No groups found</option>';
                }
                
                window.orchestratorGroups = data.groups;
                window.allCharacters = data.all_characters;
                
                onGroupChanged();
            } catch(e) {
                console.error("Error loading group manager details:", e);
            }
        }

        function onGroupChanged() {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            const listContainer = document.getElementById('group-members-list');
            const addCharSel = document.getElementById('add-to-group-char');
            
            listContainer.innerHTML = '';
            addCharSel.innerHTML = '';
            
            if (!gid || !window.orchestratorGroups) {
                listContainer.innerHTML = '<div style="color:var(--text-muted); text-align:center; margin-top:20px;">Select or create a group.</div>';
                return;
            }
            
            const group = window.orchestratorGroups.find(g => g.id === gid);
            if (!group) return;
            
            if (group.members && group.members.length > 0) {
                for (let i = 0; i < group.members.length; i++) {
                    let m = group.members[i];
                    let upBtn = i > 0 ? `<button class="btn-quick" style="padding:2px 6px; font-size:10px; margin-right:2px;" onclick="reorderMember(${m.character_id}, 'up')">▲</button>` : '';
                    let downBtn = i < group.members.length - 1 ? `<button class="btn-quick" style="padding:2px 6px; font-size:10px; margin-right:5px;" onclick="reorderMember(${m.character_id}, 'down')">▼</button>` : '';
                    const classBadge = m.class_name ? `<span style="font-size:10px; font-weight:600; color:var(--accent-blue); background:rgba(102,252,241,0.08); border:1px solid rgba(102,252,241,0.2); border-radius:4px; padding:1px 6px; margin-left:6px; letter-spacing:0.5px;">${m.class_name}</span>` : '';
                    
                    listContainer.innerHTML += `
                        <div style="background:rgba(255,255,255,0.02); padding:10px 12px; border-radius:6px; border: 1px solid rgba(255,255,255,0.03); margin-bottom:8px; display:flex; flex-direction:column; gap:8px;">
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <span style="font-weight:600; color:#fff;">${m.character_name}${classBadge} <span style="font-size:11px; color:var(--text-muted);">(${m.server})</span></span>
                                <div style="display:flex; gap:5px; align-items:center;">
                                    ${upBtn}
                                    ${downBtn}
                                    <button class="btn-quick" style="border-color:var(--accent-blue); color:var(--accent-blue); padding:4px 8px; font-size:11px;" onclick="toggleEditMember(${m.character_id})">Edit</button>
                                    <button class="btn-quick" style="border-color:var(--color-danger); color:var(--color-danger); padding:4px 8px; font-size:11px;" onclick="removeCharacterFromGroup(${m.character_id})">Remove</button>
                                </div>
                            </div>
                            <div id="edit-member-${m.character_id}" style="display:none; background:rgba(0,0,0,0.2); padding:8px; border-radius:4px; border:1px solid rgba(255,255,255,0.05); font-size:12px;">
                                <div style="display:flex; flex-direction:column; gap:5px; margin-bottom:8px;">
                                    <div>
                                        <label style="display:block; margin-bottom:2px; color:var(--text-muted); font-size:10px;">Launch Executable Path:</label>
                                        <input type="text" id="edit-path-${m.character_id}" value="${m.eq_path || ''}" style="width:100%; box-sizing:border-box; font-size:11px; padding:4px; background:rgba(0,0,0,0.5); border:1px solid var(--border-panel); color:#fff; border-radius:3px;">
                                    </div>
                                    <div>
                                        <label style="display:block; margin-bottom:2px; color:var(--text-muted); font-size:10px;">Additional Launch Args:</label>
                                        <input type="text" id="edit-args-${m.character_id}" value="${m.additional_eqgame_args || ''}" style="width:100%; box-sizing:border-box; font-size:11px; padding:4px; background:rgba(0,0,0,0.5); border:1px solid var(--border-panel); color:#fff; border-radius:3px;" placeholder="e.g. /nocygwin">
                                    </div>
                                </div>
                                <button class="btn-quick" style="border-color:var(--color-success); color:var(--color-success); padding:4px 10px; font-size:11px;" onclick="saveMemberSettings(${m.character_id})">Save Settings</button>
                            </div>
                        </div>
                    `;
                }
            } else {
                listContainer.innerHTML = '<div style="color:var(--text-muted); text-align:center; margin-top:20px;">No members in this group.</div>';
            }
            
            const memberIds = new Set(group.members.map(m => m.character_id));
            let hasOptions = false;
            for (let c of window.allCharacters) {
                if (!memberIds.has(c.id)) {
                    const classLabel = c.class_name ? ` — ${c.class_name}` : '';
                    addCharSel.innerHTML += `<option value="${c.id}">${c.name}${classLabel}</option>`;
                    hasOptions = true;
                }
            }
            if (!hasOptions) {
                addCharSel.innerHTML = '<option value="">All characters already in group</option>';
            }
        }

        function toggleEditMember(cid) {
            const form = document.getElementById(`edit-member-${cid}`);
            if (form.style.display === 'none') {
                form.style.display = 'block';
            } else {
                form.style.display = 'none';
            }
        }

        async function saveMemberSettings(cid) {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            if (!gid) return;
            const eq_path = document.getElementById(`edit-path-${cid}`).value.trim();
            const additional_args = document.getElementById(`edit-args-${cid}`).value.trim();
            const status = document.getElementById('group-manager-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            try {
                const res = await fetch('/update_group_member', {
                    method: 'POST',
                    body: JSON.stringify({
                        group_id: gid,
                        character_id: cid,
                        eq_path: eq_path,
                        additional_eqgame_args: additional_args
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Settings updated successfully.`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    await fetchGroupManagerDetails();
                }
            } catch(e) {
                console.error(e);
            }
        }

        async function reorderMember(cid, dir) {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            if (!gid) return;
            const status = document.getElementById('group-manager-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            try {
                const res = await fetch('/reorder_group_member', {
                    method: 'POST',
                    body: JSON.stringify({
                        group_id: gid,
                        character_id: cid,
                        direction: dir
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    await fetchGroupManagerDetails();
                }
            } catch(e) {
                console.error(e);
            }
        }

        function showCustomConfirm(title, message, confirmText = "Delete", confirmColor = "var(--color-danger)") {
            return new Promise((resolve) => {
                const modal = document.getElementById('confirm-modal');
                const titleEl = document.getElementById('confirm-modal-title');
                const bodyEl = document.getElementById('confirm-modal-body');
                const cancelBtn = document.getElementById('confirm-modal-cancel');
                const confirmBtn = document.getElementById('confirm-modal-confirm');

                titleEl.innerText = title;
                bodyEl.innerText = message;
                confirmBtn.innerText = confirmText;
                confirmBtn.style.background = confirmColor;

                const cleanUp = () => {
                    modal.classList.remove('active');
                    setTimeout(() => {
                        modal.style.display = 'none';
                    }, 200);
                };

                cancelBtn.onclick = () => {
                    cleanUp();
                    resolve(false);
                };

                confirmBtn.onclick = () => {
                    cleanUp();
                    resolve(true);
                };

                modal.style.display = 'flex';
                // force reflow
                modal.offsetHeight;
                modal.classList.add('active');
            });
        }

        function showPrompt(title, isCharSelect = false) {
            return new Promise((resolve) => {
                const modal = document.getElementById('prompt-modal');
                const titleEl = document.getElementById('prompt-modal-title');
                const inputEl = document.getElementById('prompt-modal-input');
                const selectEl = document.getElementById('prompt-modal-select');
                const cancelBtn = document.getElementById('prompt-modal-cancel');
                const confirmBtn = document.getElementById('prompt-modal-confirm');

                titleEl.innerText = title;
                
                if (isCharSelect) {
                    inputEl.style.display = 'none';
                    selectEl.style.display = 'block';
                    selectEl.innerHTML = document.getElementById('target-char').innerHTML;
                    if (selectEl.options.length > 0 && selectEl.options[0].value === 'all') {
                        selectEl.remove(0);
                    }
                    selectEl.value = selectEl.options.length > 0 ? selectEl.options[0].value : '';
                } else {
                    inputEl.style.display = 'block';
                    selectEl.style.display = 'none';
                    inputEl.value = '';
                }

                const cleanUp = () => {
                    modal.classList.remove('active');
                    setTimeout(() => {
                        modal.style.display = 'none';
                    }, 200);
                };

                cancelBtn.onclick = () => {
                    cleanUp();
                    resolve(null);
                };

                confirmBtn.onclick = () => {
                    cleanUp();
                    const val = isCharSelect ? selectEl.value : inputEl.value;
                    resolve(val);
                };

                modal.style.display = 'flex';
                // trigger reflow
                void modal.offsetWidth;
                modal.classList.add('active');
                
                if (!isCharSelect) {
                    inputEl.focus();
                }
            });
        }

        async function createNewGroup() {
            const name = document.getElementById('new-group-name').value.trim();
            if (!name) return;
            const status = document.getElementById('group-manager-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            try {
                const res = await fetch('/create_group', {
                    method: 'POST',
                    body: JSON.stringify({name})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Group ${name} created successfully.`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    document.getElementById('new-group-name').value = '';
                    await fetchGroupManagerDetails();
                    await fetchGroups();
                }
            } catch(e) {
                status.innerText = "Error: Connection refused or server error.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function deleteSelectedGroup() {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            if (!gid) return;
            const confirmed = await showCustomConfirm(
                "Delete Group",
                "Are you sure you want to delete this group and remove its launch mappings?"
            );
            if (!confirmed) return;
            const status = document.getElementById('group-manager-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            try {
                const res = await fetch('/delete_group', {
                    method: 'POST',
                    body: JSON.stringify({group_id: gid})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Group deleted successfully.`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    await fetchGroupManagerDetails();
                    await fetchGroups();
                }
            } catch(e) {
                status.innerText = "Error: Connection refused or server error.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function addCharacterToGroup() {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            const cid = parseInt(document.getElementById('add-to-group-char').value);
            if (!gid || !cid) return;
            const status = document.getElementById('group-manager-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            try {
                const res = await fetch('/add_to_group', {
                    method: 'POST',
                    body: JSON.stringify({group_id: gid, character_id: cid})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Character added to group.`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    await fetchGroupManagerDetails();
                }
            } catch(e) {
                status.innerText = "Error: Connection refused or server error.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function removeCharacterFromGroup(cid) {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            if (!gid || !cid) return;
            const confirmed = await showCustomConfirm(
                "Remove Member",
                "Are you sure you want to remove this character from the group?"
            );
            if (!confirmed) return;
            const status = document.getElementById('group-manager-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            try {
                const res = await fetch('/remove_from_group', {
                    method: 'POST',
                    body: JSON.stringify({group_id: gid, character_id: cid})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Character removed from group.`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    await fetchGroupManagerDetails();
                }
            } catch(e) {
                status.innerText = "Error: Connection refused or server error.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function launchManagerGroup() {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            if (!gid) return;
            const status = document.getElementById('group-manager-status');
            status.innerText = "Launching group characters...";
            status.className = 'status-msg success';
            try {
                const res = await fetch('/launch_group', {
                    method: 'POST',
                    body: JSON.stringify({group_id: gid})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                } else {
                    status.innerText = `Launched ${data.launched} characters.`;
                    setTimeout(() => { status.style.display = 'none'; }, 5000);
                }
            } catch(e) {
                status.innerText = "Error launching group.";
                status.className = 'status-msg error';
            }
        }

        async function syncIngameGroup() {
            const gid = parseInt(document.getElementById('group-manager-select').value);
            if (!gid) return;
            const status = document.getElementById('group-manager-status');
            status.innerText = "Broadcasting in-game group formation invites...";
            status.className = 'status-msg success';
            try {
                const res = await fetch('/sync_ingame_group', {
                    method: 'POST',
                    body: JSON.stringify({group_id: gid})
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                } else {
                    status.innerText = `Group invites broadcasted! Leader is inviting members and members are accepting.`;
                    setTimeout(() => { status.style.display = 'none'; }, 5000);
                }
            } catch(e) {
                status.innerText = "Error forming group.";
                status.className = 'status-msg error';
            }
        }

        // ------------------ Gearing, Stats, Bot, and Macro Implementations ------------------
        let selectedSlotId = null;
        let selectedCharId = null;

        async function loadCharacterInventory() {
            const status = document.getElementById('armory-status');
            status.style.display = 'none';
            
            const select = document.getElementById('armory-char-select');
            const option = select ? select.options[select.selectedIndex] : null;
            if (!option) {
                document.getElementById('slots-table-body').innerHTML = '<tr><td colspan="4" style="text-align:center;">Select a character above</td></tr>';
                return;
            }
            const charId = option.getAttribute('data-id');
            selectedCharId = charId;
            selectedSlotId = null;
            document.getElementById('selected-slot-label').innerText = 'None';
            
            try {
                const res = await fetch(`/get_character_inventory?character_id=${charId}`);
                const data = await res.json();
                
                const slotsTableBody = document.getElementById('slots-table-body');
                slotsTableBody.innerHTML = '';
                
                const equipped = {};
                if (data.inventory) {
                    for (let item of data.inventory) {
                        equipped[item.slot_id] = item;
                    }
                }
                
                for (let slotId = 0; slotId <= 29; slotId++) {
                    const slotName = EQUIP_SLOTS[slotId] || `Slot ${slotId}`;
                    const eqItem = equipped[slotId];
                    
                    let itemNameHtml = '<span style="color:var(--text-muted); font-style:italic;">Empty</span>';
                    let actionsHtml = '';
                    
                    if (eqItem) {
                        itemNameHtml = `<span style="color:#fff; font-weight:600;">${eqItem.item_name}</span> <span style="font-size:10px; color:var(--text-muted);">(ID: ${eqItem.item_id})</span>`;
                        actionsHtml = `<button class="btn-quick" style="border-color:var(--color-danger); color:var(--color-danger); padding:2px 6px;" onclick="event.stopPropagation(); unequipCharacterItem(${slotId})">Remove</button>`;
                    }
                    
                    const tr = document.createElement('tr');
                    tr.setAttribute('data-slot-id', slotId);
                    tr.style.cursor = 'pointer';
                    tr.onclick = function() {
                        selectSlot(slotId, slotName, tr);
                    };
                    
                    tr.innerHTML = `
                        <td>${slotId}</td>
                        <td style="color:var(--accent-blue); font-weight:500;">${slotName}</td>
                        <td>${itemNameHtml}</td>
                        <td style="text-align:right;">${actionsHtml}</td>
                    `;
                    slotsTableBody.appendChild(tr);
                }
            } catch (e) {
                console.error(e);
                status.innerText = "Error loading character inventory.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        function selectSlot(slotId, slotName, rowEl) {
            selectedSlotId = slotId;
            document.getElementById('selected-slot-label').innerText = `${slotId}: ${slotName}`;
            
            // Highlight selected row
            document.querySelectorAll('#slots-table-body tr').forEach(r => r.classList.remove('selected'));
            if (rowEl) rowEl.classList.add('selected');
        }

        async function unequipCharacterItem(slotId) {
            if (!selectedCharId) return;
            const confirmed = await showCustomConfirm(
                "Remove Item",
                `Are you sure you want to unequip the item from slot ${slotId}?`
            );
            if (!confirmed) return;
            
            const status = document.getElementById('armory-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/delete_character_item', {
                    method: 'POST',
                    body: JSON.stringify({ character_id: parseInt(selectedCharId), slot_id: parseInt(slotId) })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Item removed successfully.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    loadCharacterInventory();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function equipCharacterItem(itemId) {
            if (!selectedCharId) {
                alert("Please select a character first.");
                return;
            }
            if (selectedSlotId === null || selectedSlotId === undefined) {
                alert("Please select a target slot on the left first.");
                return;
            }
            
            const chargesInput = document.getElementById('direct-item-charges');
            const charges = parseInt(chargesInput ? chargesInput.value : 1) || 1;
            
            const status = document.getElementById('armory-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/equip_character_item', {
                    method: 'POST',
                    body: JSON.stringify({
                        character_id: parseInt(selectedCharId),
                        slot_id: parseInt(selectedSlotId),
                        item_id: parseInt(itemId),
                        charges: charges
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Item equipped successfully.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    loadCharacterInventory();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function loadCharacterStats() {
            const select = document.getElementById('stats-char-select');
            const option = select ? select.options[select.selectedIndex] : null;
            if (!option) return;
            const charId = option.getAttribute('data-id');
            
            const status = document.getElementById('stats-status');
            if (status) status.style.display = 'none';
            
            try {
                const res = await fetch(`/get_character_inventory?character_id=${charId}`);
                const data = await res.json();
                if (data.character) {
                    document.getElementById('stats-level').value = data.character.level || 1;
                    document.getElementById('stats-aa').value = data.character.aa_points || 0;
                    document.getElementById('stats-plat').value = data.character.platinum || 0;
                }
            } catch (e) {
                console.error(e);
            }
        }

        async function saveCharacterStats() {
            const select = document.getElementById('stats-char-select');
            const option = select ? select.options[select.selectedIndex] : null;
            if (!option) {
                alert("Please select a character first.");
                return;
            }
            const charId = option.getAttribute('data-id');
            const level = parseInt(document.getElementById('stats-level').value) || 1;
            const aa_points = parseInt(document.getElementById('stats-aa').value) || 0;
            const platinum = parseInt(document.getElementById('stats-plat').value) || 0;
            
            const status = document.getElementById('stats-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/save_character_stats', {
                    method: 'POST',
                    body: JSON.stringify({
                        character_id: parseInt(charId),
                        level: level,
                        aa_points: aa_points,
                        platinum: platinum
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Stats saved successfully.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    fetchCharactersList();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        let selectedBotId = null;
        let selectedBotSlotId = null;

        async function loadBotsList() {
            try {
                const res = await fetch('/list_bots');
                const data = await res.json();
                
                const body = document.getElementById('bot-list-body');
                body.innerHTML = '';
                
                const ownerSel = document.getElementById('new-bot-owner');
                const currentOwnerVal = ownerSel.value;
                ownerSel.innerHTML = '';
                
                const charsRes = await fetch('/characters');
                const charsData = await charsRes.json();
                for (let char of charsData.characters) {
                    ownerSel.innerHTML += `<option value="${char.name}">${char.name} (Lvl ${char.level})</option>`;
                }
                if (currentOwnerVal && Array.from(ownerSel.options).some(opt => opt.value === currentOwnerVal)) {
                    ownerSel.value = currentOwnerVal;
                }
                
                const classSel = document.getElementById('new-bot-class');
                const raceSel = document.getElementById('new-bot-race');
                if (classSel.innerHTML === '') {
                    const metaRes = await fetch('/classes_races');
                    const metaData = await metaRes.json();
                    for (let [id, name] of Object.entries(metaData.classes)) {
                        classSel.innerHTML += `<option value="${name}">${name}</option>`;
                    }
                    for (let [id, name] of Object.entries(metaData.races)) {
                        raceSel.innerHTML += `<option value="${name}">${name}</option>`;
                    }
                }
                
                if (data.bots && data.bots.length > 0) {
                    for (let bot of data.bots) {
                        const tr = document.createElement('tr');
                        tr.style.cursor = 'pointer';
                        tr.onclick = () => selectBot(bot.bot_id, bot.name, tr);
                        
                        tr.innerHTML = `
                            <td>${bot.bot_id}</td>
                            <td style="font-weight:600; color:#fff;">${bot.name}</td>
                            <td>${bot.level}</td>
                            <td>${bot.class_name}</td>
                            <td>${bot.race_name}</td>
                            <td>${bot.owner_name || `ID ${bot.owner_id}`}</td>
                        `;
                        body.appendChild(tr);
                    }
                } else {
                    body.innerHTML = '<tr><td colspan="6" style="text-align:center;">No bots found. Use the form below to create one.</td></tr>';
                }
            } catch (e) {
                console.error(e);
            }
        }

        async function selectBot(botId, botName, rowEl) {
            selectedBotId = botId;
            selectedBotSlotId = null;
            document.getElementById('selected-bot-slot-label').innerText = 'None';
            
            document.querySelectorAll('#bot-list-body tr').forEach(r => r.classList.remove('selected'));
            if (rowEl) rowEl.classList.add('selected');
            
            document.getElementById('bot-editor-summary').innerText = `Editing Bot: ${botName} (ID: ${botId})`;
            
            await loadBotDetails();
        }

        async function loadBotDetails() {
            if (!selectedBotId) return;
            const status = document.getElementById('bot-editor-status');
            status.style.display = 'none';
            
            try {
                const res = await fetch(`/get_bot_details?bot_id=${selectedBotId}`);
                const data = await res.json();
                
                if (data.bot) {
                    document.getElementById('bot-stats-level').value = data.bot.level || 1;
                }
                
                const tableBody = document.getElementById('bot-slots-table-body');
                tableBody.innerHTML = '';
                
                const equipped = {};
                if (data.inventory) {
                    for (let item of data.inventory) {
                        equipped[item.slot_id] = item;
                    }
                }
                
                for (let slotId = 0; slotId <= 29; slotId++) {
                    const slotName = EQUIP_SLOTS[slotId] || `Slot ${slotId}`;
                    const eqItem = equipped[slotId];
                    
                    let itemNameHtml = '<span style="color:var(--text-muted); font-style:italic;">Empty</span>';
                    let actionsHtml = '';
                    
                    if (eqItem) {
                        itemNameHtml = `<span style="color:#fff; font-weight:600;">${eqItem.item_name}</span> <span style="font-size:10px; color:var(--text-muted);">(ID: ${eqItem.item_id})</span>`;
                        actionsHtml = `<button class="btn-quick" style="border-color:var(--color-danger); color:var(--color-danger); padding:2px 6px;" onclick="event.stopPropagation(); unequipBotItem(${slotId})">Remove</button>`;
                    }
                    
                    const tr = document.createElement('tr');
                    tr.setAttribute('data-slot-id', slotId);
                    tr.style.cursor = 'pointer';
                    tr.onclick = function() {
                        selectBotSlot(slotId, slotName, tr);
                    };
                    
                    tr.innerHTML = `
                        <td>${slotId}</td>
                        <td style="color:var(--accent-blue); font-weight:500;">${slotName}</td>
                        <td>${itemNameHtml}</td>
                        <td style="text-align:right;">${actionsHtml}</td>
                    `;
                    tableBody.appendChild(tr);
                }
            } catch (e) {
                console.error(e);
            }
        }

        function selectBotSlot(slotId, slotName, rowEl) {
            selectedBotSlotId = slotId;
            document.getElementById('selected-bot-slot-label').innerText = `${slotId}: ${slotName}`;
            
            document.querySelectorAll('#bot-slots-table-body tr').forEach(r => r.classList.remove('selected'));
            if (rowEl) rowEl.classList.add('selected');
        }

        async function createBot() {
            const status = document.getElementById('bot-creator-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            const name = document.getElementById('new-bot-name').value.trim();
            const owner = document.getElementById('new-bot-owner').value;
            const cls = document.getElementById('new-bot-class').value;
            const rc = document.getElementById('new-bot-race').value;
            
            if (!name || !owner) {
                status.innerText = "Error: Please enter a name and select an owner.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }
            
            try {
                const res = await fetch('/create_bot', {
                    method: 'POST',
                    body: JSON.stringify({
                        name: name,
                        owner_name: owner,
                        class_name: cls,
                        race_name: rc
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = `Bot ${name} created successfully!`;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    document.getElementById('new-bot-name').value = '';
                    loadBotsList();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function saveBotLevel() {
            if (!selectedBotId) {
                alert("Please select a bot first.");
                return;
            }
            const lvl = parseInt(document.getElementById('bot-stats-level').value) || 1;
            const status = document.getElementById('bot-editor-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/save_bot_level', {
                    method: 'POST',
                    body: JSON.stringify({ bot_id: parseInt(selectedBotId), level: lvl })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Bot level saved successfully.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    loadBotsList();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function searchBotItems() {
            const query = document.getElementById('bot-item-search-query').value.trim();
            if (!query) return;

            const resultsBox = document.getElementById('bot-item-search-results');
            resultsBox.innerHTML = '<div style="text-align:center;"><div class="loader"></div> Searching...</div>';

            try {
                const res = await fetch('/search_items?q=' + encodeURIComponent(query));
                const data = await res.json();
                resultsBox.innerHTML = '';
                
                if (data.items && data.items.length > 0) {
                    for (let it of data.items) {
                        resultsBox.innerHTML += `
                            <div class="item-row" style="padding:4px; font-size:11px;">
                                <div class="item-details">
                                    <div class="item-name">${it.Name} (ID: ${it.id})</div>
                                </div>
                                <button class="btn-quick" style="padding:2px 6px; font-size:10px;" onclick="equipBotItem('${it.id}')">Equip</button>
                            </div>
                        `;
                    }
                } else {
                    resultsBox.innerHTML = '<div style="text-align:center; color:var(--text-muted);">No items.</div>';
                }
            } catch (e) {
                resultsBox.innerHTML = '<div style="text-align:center; color:var(--color-danger);">Error.</div>';
            }
        }

        async function equipBotItem(itemId) {
            if (!selectedBotId) {
                alert("Please select a bot first.");
                return;
            }
            if (selectedBotSlotId === null || selectedBotSlotId === undefined) {
                alert("Please select a target slot first.");
                return;
            }
            
            const chargesInput = document.getElementById('bot-item-charges');
            const charges = parseInt(chargesInput ? chargesInput.value : 1) || 1;
            
            const status = document.getElementById('bot-editor-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/equip_bot_item', {
                    method: 'POST',
                    body: JSON.stringify({
                        bot_id: parseInt(selectedBotId),
                        slot_id: parseInt(selectedBotSlotId),
                        item_id: parseInt(itemId),
                        charges: charges
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Item equipped to bot.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    loadBotDetails();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function unequipBotItem(slotId) {
            if (!selectedBotId) return;
            const confirmed = await showCustomConfirm(
                "Remove Bot Item",
                `Are you sure you want to unequip the item from bot slot ${slotId}?`
            );
            if (!confirmed) return;
            
            const status = document.getElementById('bot-editor-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/delete_bot_item', {
                    method: 'POST',
                    body: JSON.stringify({ bot_id: parseInt(selectedBotId), slot_id: parseInt(slotId) })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Item removed from bot.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    loadBotDetails();
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function loadMacroBotList() {
            try {
                const res = await fetch('/list_bots');
                const data = await res.json();
                
                const container = document.getElementById('macro-bot-checkboxes');
                container.innerHTML = '';
                
                const armorySel = document.getElementById('armory-char-select');
                const macroSel = document.getElementById('macro-owner-select');
                const currentMacroOwner = macroSel.value;
                macroSel.innerHTML = armorySel.innerHTML;
                if (currentMacroOwner && Array.from(macroSel.options).some(opt => opt.value === currentMacroOwner)) {
                    macroSel.value = currentMacroOwner;
                }
                
                if (data.bots && data.bots.length > 0) {
                    for (let bot of data.bots) {
                        container.innerHTML += `
                            <label style="display:flex; align-items:center; gap:8px; margin-bottom:6px; cursor:pointer; text-transform:none; font-size:13px; font-weight:normal;">
                                <input type="checkbox" name="macro-bot-choice" value="${bot.name}" data-owner-name="${bot.owner_name || ''}">
                                <span style="font-weight:600; color:#fff;">${bot.name}</span>
                                <span style="color:var(--text-muted); font-size:11px;">(Lvl ${bot.level} ${bot.class_name} — Owner: ${bot.owner_name || `ID ${bot.owner_id}`})</span>
                            </label>
                        `;
                    }
                } else {
                    container.innerHTML = '<div style="color:var(--text-muted); text-align:center; padding-top:20px;">No bots found.</div>';
                }
                onMacroOwnerChanged();
            } catch (e) {
                console.error(e);
            }
        }

        function onMacroOwnerChanged() {
            const owner = document.getElementById('macro-owner-select').value;
            document.querySelectorAll('input[name="macro-bot-choice"]').forEach(cb => {
                const ownerAttr = cb.getAttribute('data-owner-name');
                if (owner && ownerAttr && ownerAttr.toLowerCase() === owner.toLowerCase()) {
                    cb.checked = true;
                } else {
                    cb.checked = false;
                }
            });
        }

        async function generateMacro() {
            const owner = document.getElementById('macro-owner-select').value;
            const engine = document.getElementById('macro-engine').value;
            const prefix = document.getElementById('macro-prefix').value;
            const stance = document.getElementById('macro-stance').value;
            
            const selectedBots = [];
            document.querySelectorAll('input[name="macro-bot-choice"]:checked').forEach(cb => {
                selectedBots.push(cb.value);
            });
            
            const status = document.getElementById('macro-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            if (!owner) {
                status.innerText = "Error: Please select an owner character.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }
            if (selectedBots.length === 0) {
                status.innerText = "Error: Please select at least one bot.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }
            
            try {
                const res = await fetch('/generate_macro', {
                    method: 'POST',
                    body: JSON.stringify({
                        owner_name: owner,
                        engine: engine,
                        prefix: prefix,
                        stance: stance,
                        bots: selectedBots
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    document.getElementById('macro-output-text').value = data.macro_lines.join('\\n');
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function writeMacroToIni() {
            const owner = document.getElementById('macro-owner-select').value;
            const engine = document.getElementById('macro-engine').value;
            const prefix = document.getElementById('macro-prefix').value;
            const stance = document.getElementById('macro-stance').value;
            
            const selectedBots = [];
            document.querySelectorAll('input[name="macro-bot-choice"]:checked').forEach(cb => {
                selectedBots.push(cb.value);
            });
            
            const status = document.getElementById('macro-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            if (!owner) {
                status.innerText = "Error: Please select an owner character.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }
            if (selectedBots.length === 0) {
                status.innerText = "Error: Please select at least one bot.";
                status.className = 'status-msg error';
                status.style.display = 'block';
                return;
            }
            
            try {
                const res = await fetch('/write_character_macro', {
                    method: 'POST',
                    body: JSON.stringify({
                        owner_name: owner,
                        engine: engine,
                        prefix: prefix,
                        stance: stance,
                        bots: selectedBots
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = data.message;
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                    document.getElementById('macro-output-text').value = data.macro_lines.join('\\n');
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        function copyMacroToClipboard() {
            const ta = document.getElementById('macro-output-text');
            ta.select();
            document.execCommand('copy');
            alert("Macro commands copied to clipboard!");
        }

        async function fetchDBSettings() {
            try {
                const res = await fetch('/get_orchestrator_config');
                const data = await res.json();
                
                document.getElementById('db-host').value = data.host || '';
                document.getElementById('db-port').value = data.port || 3306;
                document.getElementById('db-user').value = data.user || '';
                document.getElementById('db-password').value = data.password || '';
                document.getElementById('db-database').value = data.database || '';
            } catch (e) {
                console.error("Error fetching db settings:", e);
            }
        }

        async function saveDBSettings() {
            const host = document.getElementById('db-host').value.trim();
            const port = document.getElementById('db-port').value.trim();
            const user = document.getElementById('db-user').value.trim();
            const password = document.getElementById('db-password').value.trim();
            const database = document.getElementById('db-database').value.trim();
            
            const status = document.getElementById('db-settings-status');
            status.className = 'status-msg';
            status.style.display = 'none';
            
            try {
                const res = await fetch('/save_orchestrator_config', {
                    method: 'POST',
                    body: JSON.stringify({
                        host: host,
                        port: port,
                        user: user,
                        password: password,
                        database: database
                    })
                });
                const data = await res.json();
                if (data.error) {
                    status.innerText = "Error: " + data.error;
                    status.className = 'status-msg error';
                    status.style.display = 'block';
                } else {
                    status.innerText = "Settings saved successfully! Connection reloaded.";
                    status.className = 'status-msg success';
                    status.style.display = 'block';
                }
            } catch (e) {
                status.innerText = "Error contacting server.";
                status.className = 'status-msg error';
                status.style.display = 'block';
            }
        }

        async function checkCrashes() {
            try {
                const res = await fetch('/crashes');
                const data = await res.json();
                const banner = document.getElementById('crash-banner');
                const text = document.getElementById('crash-text');
                if (data.crashes && data.crashes.length > 0) {
                    text.innerText = data.crashes.length + " character(s) crashed: " + data.crashes.join(", ");
                    banner.style.display = 'block';
                } else {
                    banner.style.display = 'none';
                }
            } catch(e) {}
        }
        setInterval(checkCrashes, 5000);
        checkCrashes();

        async function dismissCrash() {
            await fetch('/dismiss_crashes', {method: 'POST'});
            checkCrashes();
        }

        async function relaunchCrashed() {
            document.getElementById('crash-text').innerText = "Relaunching...";
            await fetch('/relaunch_crashes', {method: 'POST'});
            setTimeout(checkCrashes, 2000);
        }

        // Initialize metadata and polls
        fetchGroups();
        fetchCreatorMetadata();
        fetchCharactersList();
        
        async function updateEqbcChat() {
            try {
                const res = await fetch('/eqbc_chat');
                const data = await res.json();
                const chatBox = document.getElementById('eqbcChat');
                if (data.chat) {
                    chatBox.innerHTML = data.chat.join('<br>');
                    chatBox.scrollTop = chatBox.scrollHeight;
                }
            } catch (e) {}
        }
        setInterval(updateEqbcChat, 2000);


        
        fetchLaunchableCharacters();
        fetchGroupManagerDetails();

        function launchAECohort() {
            fetch('/cmd/launch_ae_cohort', {method: 'POST'})
            .then(r => r.json())
            .then(d => {
                addLog("Launching AE PL Cohort... this may take a moment.");
            }).catch(e => {
                addLog("Launching AE PL Cohort...");
            });
        }
        
        function formAERaid() {
            fetch('/cmd/ae_form_raid', {method: 'POST'});
        }

        function aeToggleMode(state) {
            fetch('/cmd/ae_toggle', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({state: state})
            });
        }

        function loadGuides() {
            fetch('/api/guides')
                .then(r => r.json())
                .then(data => {
                    const list = document.getElementById('guides-list');
                    list.innerHTML = '';
                    if (data.guides) {
                        data.guides.forEach(guide => {
                            const tr = document.createElement('tr');
                            tr.style.cursor = 'pointer';
                            tr.innerHTML = `<td>${guide}</td>`;
                            tr.onclick = () => {
                                document.querySelectorAll('#guides-list tr').forEach(row => row.classList.remove('selected'));
                                tr.classList.add('selected');
                                loadGuideContent(guide);
                            };
                            list.appendChild(tr);
                        });
                    }
                });
        }
        
        function loadGuideContent(name) {
            document.getElementById('guide-viewer-title').innerText = name;
            document.getElementById('guide-viewer-content').innerHTML = '<span class="loader"></span> Loading...';
            fetch('/api/guide_content?name=' + encodeURIComponent(name))
                .then(r => r.text())
                .then(md => {
                    if (typeof marked !== 'undefined') {
                        document.getElementById('guide-viewer-content').innerHTML = marked.parse(md);
                    } else {
                        document.getElementById('guide-viewer-content').innerText = md;
                    }
                })
                .catch(err => {
                    document.getElementById('guide-viewer-content').innerText = 'Error loading guide: ' + err;
                });
        }
    </script>
</body>
</html>
"""

def scribe_all_spells(char_id):

    """
    Scribes all level-appropriate spells for the character in character_spells.
    Only includes spells that have a vendor-purchasable scroll (nodrop=0 item with scrolleffect = spell id).
    Handles pure melee classes (which have no spells) gracefully.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # Get character class and level
            cursor.execute("SELECT name, class, level FROM character_data WHERE id = %s", (char_id,))
            char = cursor.fetchone()
            if not char:
                return False, "Character not found."
            
            char_name = char['name']
            class_id = char['class']
            level = char['level']
            
            # Pure melee check
            if class_id in [1, 7, 9, 16]:  # Warrior, Monk, Rogue, Berserker
                return True, f"{char_name} ({CLASSES.get(class_id, 'Melee')}) is a pure melee class and has no spells to scribe."
                
            # Query all spells this character can scribe at their level
            # that also have a buyable (nodrop=0) scroll item, excluding discipline Tomes
            class_col = f"classes{class_id}"
            sql_spells = f"""
                SELECT DISTINCT sn.id, sn.name, sn.{class_col} as lvl 
                FROM spells_new sn
                INNER JOIN items i ON i.scrolleffect = sn.id
                WHERE sn.{class_col} >= 1 AND sn.{class_col} <= %s 
                  AND i.nodrop = 0
                  AND i.Name NOT LIKE 'Tome of%%'
                ORDER BY sn.{class_col}, sn.id
            """
            cursor.execute(sql_spells, (level,))
            available_spells = cursor.fetchall()
            
            if not available_spells:
                return True, f"No buyable spells found for {char_name} (Level {level})."
                
            # Get already scribed spells
            cursor.execute("SELECT slot_id, spell_id FROM character_spells WHERE id = %s", (char_id,))
            scribed = cursor.fetchall()
            scribed_spell_ids = {row['spell_id'] for row in scribed}
            filled_slots = {row['slot_id'] for row in scribed}
            
            new_spells = [s for s in available_spells if s['id'] not in scribed_spell_ids]
            if not new_spells:
                return True, f"All buyable spells are already scribed for {char_name}."
                
            # Insert new spells into available slots
            slot_id = 0
            inserted = 0
            sql_insert = "INSERT INTO character_spells (id, slot_id, spell_id) VALUES (%s, %s, %s)"
            insert_batch = []
            
            for spell in new_spells:
                # Find next free slot
                while slot_id in filled_slots:
                    slot_id += 1
                insert_batch.append((char_id, slot_id, spell['id']))
                filled_slots.add(slot_id)
                inserted += 1
                
            if insert_batch:
                cursor.executemany(sql_insert, insert_batch)
                conn.commit()
                
            return True, f"Scribed {inserted} new spells for {char_name}."
    except Exception as e:
        return False, str(e)
    finally:
        conn.close()


def learn_disciplines(char_id):
    """
    Grants all buyable discipline tomes (Tome of X, nodrop=0) appropriate for the
    character's class and level into character_disciplines.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT name, class, level FROM character_data WHERE id = %s", (char_id,))
            char = cursor.fetchone()
            if not char:
                return False, "Character not found."

            char_name = char['name']
            class_id = char['class']
            level = char['level']
            class_col = f"classes{class_id}"

            # Find all buyable discipline tomes for this class/level
            sql_discs = f"""
                SELECT DISTINCT sn.id
                FROM spells_new sn
                INNER JOIN items i ON i.scrolleffect = sn.id
                WHERE sn.{class_col} >= 1 AND sn.{class_col} <= %s
                  AND i.nodrop = 0
                  AND i.Name LIKE 'Tome of%%'
                ORDER BY sn.{class_col}, sn.id
            """
            cursor.execute(sql_discs, (level,))
            available_discs = [row['id'] for row in cursor.fetchall()]

            if not available_discs:
                return True, f"No buyable discipline tomes found for {char_name} (Level {level})."

            # Get already known disciplines
            cursor.execute("SELECT slot_id, disc_id FROM character_disciplines WHERE id = %s", (char_id,))
            known = cursor.fetchall()
            known_disc_ids = {row['disc_id'] for row in known}
            filled_slots = {row['slot_id'] for row in known}

            new_discs = [d for d in available_discs if d not in known_disc_ids]
            if not new_discs:
                return True, f"All buyable disciplines are already known for {char_name}."

            slot_id = 0
            insert_batch = []
            for disc_id in new_discs:
                while slot_id in filled_slots:
                    slot_id += 1
                insert_batch.append((char_id, slot_id, disc_id))
                filled_slots.add(slot_id)

            if insert_batch:
                cursor.executemany(
                    "INSERT INTO character_disciplines (id, slot_id, disc_id) VALUES (%s, %s, %s)",
                    insert_batch
                )
                conn.commit()

            return True, f"Learned {len(insert_batch)} new disciplines for {char_name}."
    except Exception as e:
        return False, str(e)
    finally:
        conn.close()


def train_skills(char_id):
    """
    Initializes new skills available to the character's class and level to a value of 1,
    simulating a purchase from a guild trainer. 
    Upserts existing values so no skill is lowered below current.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT name, class, level FROM character_data WHERE id = %s", (char_id,))
            char = cursor.fetchone()
            if not char:
                return False, "Character not found."

            char_name = char['name']
            class_id = char['class']
            level = char['level']

            # Get max cap per skill for this class up to current level
            cursor.execute("""
                SELECT skill_id, MAX(cap) as max_cap
                FROM skill_caps
                WHERE class_id = %s AND level <= %s
                GROUP BY skill_id
                HAVING max_cap > 0
            """, (class_id, level))
            skill_caps_data = cursor.fetchall()

            if not skill_caps_data:
                return True, f"No skill caps found for {char_name}."

            # Upsert: insert or update, never lower existing value
            sql_upsert = """
                INSERT INTO character_skills (id, skill_id, value)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE value = GREATEST(value, VALUES(value))
            """
            batch = [(char_id, row['skill_id'], 1) for row in skill_caps_data]
            cursor.executemany(sql_upsert, batch)
            conn.commit()

            return True, f"Initialized {len(batch)} skills to 1 for {char_name}."
    except Exception as e:
        return False, str(e)
    finally:
        conn.close()


def apply_gearing_kit(char_name, kit_type):
    """
    Applies a defined package of items to the character's inventory slots.
    """
    ITEM_BACKPACK = 17005
    ITEM_RATION = 13015
    ITEM_WATER = 13006

    def db_equip_item(char_id, slot_id, item_id, charges=1):
        conn = get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("DELETE FROM inventory WHERE character_id = %s AND slot_id = %s", (char_id, slot_id))
                cursor.execute("""
                    INSERT INTO inventory (character_id, slot_id, item_id, charges, color, augment_one, augment_two, augment_three, augment_four, augment_five, augment_six, instnodrop, ornament_icon, ornament_idfile, ornament_hero_model)
                    VALUES (%s, %s, %s, %s, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                """, (char_id, slot_id, item_id, charges))
                conn.commit()
        finally:
            conn.close()

    try:
        # Fetch character id, class_id, and level
        conn = get_connection()
        char_id = None
        class_id = 1
        level = 1
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT id, class, level FROM character_data WHERE name = %s", (char_name,))
                row = cursor.fetchone()
                if row:
                    char_id = row['id']
                    class_id = row['class']
                    level = row['level']
        finally:
            conn.close()

        if not char_id:
            return False, f"Character '{char_name}' not found."

        if kit_type == "starter":
            db_equip_item(char_id, 22, ITEM_BACKPACK, 1)
            db_equip_item(char_id, 23, ITEM_RATION, 20)
            db_equip_item(char_id, 24, ITEM_WATER, 20)
            return True, f"Successfully equipped Starter Kit directly in {char_name}'s slots 22-24 (Backpack, Ration, Water Flask)."
        
        elif kit_type == "speed":
            db_equip_item(char_id, 16, 2300, 1)   # Journeyman's Boots
            db_equip_item(char_id, 8, 82712, 1)  # Fabled Fungi Tunic
            return True, f"Successfully equipped Speed & Regen Kit directly in {char_name}'s slots (JBoots on Feet, Fungi Tunic on Chest)."

        elif kit_type in ("tank", "healer", "caster"):
            # Map class to armor type: 1=Plate, 2=Chain, 3=Leather, 4=Cloth
            class_armor_map = {
                1: 1, 2: 1, 3: 1, 5: 1, 8: 1,      # Plate
                4: 2, 9: 2, 10: 2, 16: 2,          # Chain
                6: 3, 7: 3, 15: 3,                 # Leather
                11: 4, 12: 4, 13: 4, 14: 4         # Cloth
            }
            armor_type = class_armor_map.get(class_id, 1)

            chest_id = None
            head_id = None
            feet_id = None

            if level < 20:
                # Level 1-19: Banded or Leather or Cloth (standard, tradeable, not rare)
                if armor_type in (1, 2):  # Plate / Chain -> Banded Mail
                    chest_id = 3056       # Banded Mail
                    head_id = 3053        # Banded Helm
                    feet_id = 3064        # Banded Boots
                elif armor_type == 3:     # Leather
                    chest_id = 2004       # Leather Tunic
                    head_id = 1001        # Cloth Cap (basic leather cap placeholder)
                    feet_id = 2012        # Leather Boots
                else:                     # Cloth
                    chest_id = 1004       # Cloth Shirt
                    head_id = 1001        # Cloth Cap
                    feet_id = 1012        # Cloth Sandals

            elif level < 50:
                # Level 20-49: Bronze or Simple Defiant or Robe of the Oracle (tradeable, level-appropriate)
                if armor_type in (1, 2):  # Plate / Chain -> Bronze
                    chest_id = 4204       # Bronze Breastplate
                    head_id = 4201        # Bronze Helm
                    feet_id = 4212        # Bronze Boots
                elif armor_type == 3:     # Leather -> Simple Defiant Leather
                    chest_id = 50053      # Simple Defiant Leather Tunic
                    head_id = 50050       # Simple Defiant Leather Cap
                    feet_id = 2012        # Leather Boots
                else:                     # Cloth -> Robe of the Oracle
                    chest_id = 1354       # Robe of the Oracle
                    head_id = 1001        # Cloth Cap
                    feet_id = 1012        # Cloth Sandals

            else:
                # Level 50+: Elegant Defiant (level 65 requirement but standard tradeable level-appropriate scaling)
                if armor_type == 1:       # Elegant Defiant Plate
                    chest_id = 50221
                    head_id = 50218
                    feet_id = 50217
                elif armor_type == 2:     # Elegant Defiant Chain
                    chest_id = 50229
                    head_id = 50226
                    feet_id = 50225
                elif armor_type == 3:     # Elegant Defiant Leather
                    chest_id = 50237
                    head_id = 50234
                    feet_id = 50233
                else:                     # Elegant Defiant Silk/Cloth
                    chest_id = 50246
                    head_id = 50243
                    feet_id = 50242

            # Select level/class appropriate weapons
            primary_id = None
            secondary_id = None

            if level < 20:
                # Level 1-19 basic rusty/starter weapons
                if class_id in (1, 3, 5, 4, 8):  # Melee classes -> Short Sword
                    primary_id = 5001
                elif class_id in (2, 6, 10, 7):   # Priests/Monk -> Club
                    primary_id = 6001
                elif class_id in (11, 12, 13, 14, 9, 15): # Casters/Rogue/Beastlord -> Dagger
                    primary_id = 7001
                elif class_id == 16:              # Berserker -> Rusty Axe
                    primary_id = 5014
                
                # Secondary
                if class_id in (1, 4):            # Warrior, Ranger dual wield
                    secondary_id = 5001
                elif class_id == 9:               # Rogue dual wield
                    secondary_id = 7001
                elif class_id in (2, 3, 5, 6, 8, 10) or class_id in (11, 12, 13, 14): # Shield classes
                    secondary_id = 9006           # Wooden Shield

            elif level < 50:
                # Level 20-49 Fine Steel weapons
                if class_id in (1, 3, 5, 4, 8):  # Melee
                    primary_id = 5352             # Fine Steel Short Sword
                elif class_id in (2, 6, 10, 7):   # Priests/Monk
                    primary_id = 6351             # Fine Steel Morning Star
                elif class_id in (11, 12, 13, 14, 9, 15): # Casters/Rogue/Beastlord
                    primary_id = 7350             # Fine Steel Dagger
                elif class_id == 16:
                    primary_id = 5352             # Fine Steel Sword (placeholder)

                # Secondary
                if class_id in (1, 4):            # Warrior, Ranger dual wield
                    secondary_id = 5352
                elif class_id == 9:               # Rogue dual wield
                    secondary_id = 7350
                elif class_id in (2, 3, 5, 6, 8, 10) or class_id in (11, 12, 13, 14): # Shield classes
                    secondary_id = 11551          # Shield of the Immaculate

            else:
                # Level 50+ Elegant Defiant weapons
                primary_id = 50621                # Elegant Defiant Shortsword
                
                # Secondary
                if class_id in (1, 4, 9):         # Dual wield
                    secondary_id = 50621
                elif class_id in (2, 3, 5, 6, 8, 10) or class_id in (11, 12, 13, 14):
                    secondary_id = 50630          # Elegant Defiant Round Shield

            # Equip armor
            if chest_id:
                db_equip_item(char_id, 8, chest_id, 1)    # Chest slot
            if head_id:
                db_equip_item(char_id, 2, head_id, 1)     # Head slot
            if feet_id:
                db_equip_item(char_id, 16, feet_id, 1)    # Feet slot
            
            # Equip weapons
            if primary_id:
                db_equip_item(char_id, 19, primary_id, 1) # Primary slot
            if secondary_id:
                db_equip_item(char_id, 14, secondary_id, 1) # Secondary slot
            elif class_id not in (1, 4, 9) and class_id not in (2, 3, 5, 6, 8, 10, 11, 12, 13, 14):
                # Clear secondary for 2H or Monk
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("DELETE FROM inventory WHERE character_id = %s AND slot_id = 14", (char_id,))
                        conn.commit()
                finally:
                    conn.close()

            return True, f"Successfully equipped {kit_type.capitalize()} Kit directly onto {char_name} (Level {level} {CLASSES.get(class_id, 'Class')})."

        else:
            return False, f"Unknown kit type: {kit_type}"
    except Exception as e:
        return False, str(e)



import socket
import select
from collections import deque

class EQBCClient:
    def __init__(self, host='127.0.0.1', port=2112, name='Orchestrator'):
        self.host = host
        self.port = port
        self.name = name
        self.sock = None
        self.running = False
        self.chat_history = deque(maxlen=100)
        
    def start(self):
        self.running = True
        threading.Thread(target=self._run, daemon=True).start()
        
    def stop(self):
        self.running = False
        if self.sock:
            try:
                self.sock.close()
            except:
                pass
            
    def _run(self):
        while self.running:
            try:
                self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.sock.connect((self.host, self.port))
                self.sock.sendall(f"login={self.name};\n".encode('utf-8'))
                self.chat_history.append(f"[System] Connected to EQBCS at {self.host}:{self.port}")
                
                while self.running:
                    ready = select.select([self.sock], [], [], 1.0)
                    if ready[0]:
                        data = self.sock.recv(4096)
                        if not data:
                            break
                        msgs = data.decode('utf-8', errors='ignore').split('\n')
                        for msg in msgs:
                            if msg.strip() and not msg.startswith('\tPING'):
                                self.chat_history.append(msg.strip())
            except Exception as e:
                self.chat_history.append(f"[System] Disconnected from EQBCS: {e}. Retrying in 5s...")
            
            if self.sock:
                try:
                    self.sock.close()
                except:
                    pass
            if self.running:
                time.sleep(5)
                
    def send_command(self, cmd):
        if self.sock and self.running:
            try:
                self.sock.sendall(f"{cmd}\n".encode('utf-8'))
                return True
            except Exception as e:
                print(f"EQBC send failed: {e}. Dropping connection to force reconnect.")
                try:
                    self.sock.close()
                except:
                    pass
                self.sock = None
        return False

EQBC_CLIENT = EQBCClient()

def start_eqbcs():
    """Starts the EQBCS server natively."""
    import socket
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            if s.connect_ex(('127.0.0.1', 2112)) == 0:
                print("EQBCS (or equivalent) is already listening on port 2112.")
                return
    except: pass

    eqbcs_path = r"C:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\EQBCS.exe"
    if os.path.exists(eqbcs_path):
        try:
            print("Starting EQBCS.exe...")
            subprocess.Popen([eqbcs_path], cwd=os.path.dirname(eqbcs_path))
        except Exception as e:
            print(f"Failed to start EQBCS: {e}")

def write_cmd_global(char, cmd):
    """Broadcasts a command to all characters via EQBC."""
        
    try:
        for line in cmd.split('\n'):
            line = line.strip()
            if not line: continue
            if line.startswith('/'): line = line[1:]
            EQBC_CLIENT.send_command(f"bcaa //{line}")
    except Exception as e:
        print(f"Error sending global cmd to EQBC: {e}")

def write_cmd(char, cmd):
    """Sends a command to a specific character via EQBC."""
    if char.lower() == "all":
        return write_cmd_global(char, cmd)
        
    try:
        with open(os.path.join(COMMANDS_DIR, "orchestrator_debug.log"), "a") as lf:
            lf.write(f"[{time.strftime('%H:%M:%S')}] DEBUG: Cmd to {char}: {cmd}\n")
    except: pass
        
    try:
        with open(os.path.join(COMMANDS_DIR, "orchestrator_debug.log"), "a") as lf:
            lf.write(f"[{time.strftime('%H:%M:%S')}] DEBUG: Cmd to {char}: {cmd}\n")
    except: pass
    
    try:
        for line in cmd.split('\n'):
            line = line.strip()
            if not line: continue
            if line.startswith('/'): line = line[1:]
            EQBC_CLIENT.send_command(f"bct {char} //{line}")
    except Exception as e:
        print(f"Error sending cmd to {char} via EQBC: {e}")


def auto_group_formation_thread(group_id):
    """
    Monitors online status of all members of the group.
    Once all members are online, triggers in-game invitations automatically.
    """
    print(f"[AutoGroup] Monitoring thread started for group {group_id}")
    start_time = time.time()
    expected_members = []
    
    if not os.path.exists(DEFAULT_LOGIN_DB):
        return
        
    try:
        conn = sqlite3.connect(DEFAULT_LOGIN_DB)
        c = conn.cursor()
        c.execute("""
            SELECT c.character 
            FROM profiles p 
            JOIN characters c ON p.character_id = c.id 
            WHERE p.group_id = ? 
            ORDER BY pg.name, p.sort_order
        """, (group_id,))
        expected_members = [row[0].capitalize() for row in c.fetchall()]
        conn.close()
    except Exception as e:
        print(f"[AutoGroup] Error reading group members: {e}")
        return
        
    if len(expected_members) < 2:
        print(f"[AutoGroup] Group {group_id} has less than 2 members. Skipping auto-grouping.")
        return

    print(f"[AutoGroup] Expected members: {expected_members}")
    
    # Wait for all characters to be online
    while time.time() - start_time < 300:
        online_chars = set()
        files = glob.glob(os.path.join(COMMANDS_DIR, "*.status.json"))
        for f in files:
            try:
                with open(f, 'r') as fh:
                    content = json.load(fh)
                    c_name = content.get("name")
                    if c_name and time.time() - content.get("timestamp", 0) < 6:
                        online_chars.add(c_name.lower())
            except:
                pass
                
        # Check if all expected characters are online
        all_online = True
        for m in expected_members:
            if m.lower() not in online_chars:
                all_online = False
                break
                
        if all_online:
            print(f"[AutoGroup] All members of group {group_id} are online. Delaying 8s to allow UI/MQ loading...")
            time.sleep(8)
            leader = expected_members[0]
            other_members = expected_members[1:]
            
            print(f"[AutoGroup] Issuing in-game group/raid invites with leader {leader} inviting {other_members}")
            
            # Send all invites simultaneously
            for i, m in enumerate(other_members):
                if i < 5:
                    write_cmd(leader, f"/invite {m}")
                else:
                    write_cmd(leader, f"/raidinvite {m}")
            
            # Brief pause for EQ to process the incoming invite requests
            time.sleep(2.0)
            
            # Have all members accept simultaneously
            for m in other_members:
                write_cmd(m, "/invite")
                # Also accept raid invites if applicable
                write_cmd(m, "/yes")
                
            print("[AutoGroup] Group/Raid formation sequence complete.")
            return
            
        time.sleep(3)
    
    try:
        with open(os.path.join(COMMANDS_DIR, "orchestrator_debug.log"), "a") as lf:
            lf.write(f"[{time.strftime('%H:%M:%S')}] [AutoGroup] TIMEOUT: Failed to see all {expected_members} online within 300 seconds.\n")
    except: pass
        
    print(f"[AutoGroup] Timeout: Not all members of group {group_id} came online within 120s. Giving up.")


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == "/":
            body = HTML_CONTENT.encode()
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
            self.end_headers()
            self.wfile.write(body)
            
        elif parsed_path.path == "/favicon.ico":
            ico_path = os.path.join(os.path.dirname(DEFAULT_EQ_PATH), "Everquest.ico")
            if os.path.exists(ico_path):
                try:
                    with open(ico_path, "rb") as f:
                        ico_data = f.read()
                    self.send_response(200)
                    self.send_header("Content-type", "image/x-icon")
                    self.send_header("Content-length", str(len(ico_data)))
                    self.send_header("Cache-Control", "public, max-age=86400")
                    self.end_headers()
                    self.wfile.write(ico_data)
                except Exception as e:
                    print("Error serving favicon:", e)
                    self.send_response(500)
                    self.end_headers()
            else:
                self.send_response(404)
                self.end_headers()
                
        elif parsed_path.path == "/api/guides":
            guides_dir = os.path.join(BASE_DIR, "antigravity", "guides")
            guides = []
            if os.path.exists(guides_dir):
                for f in os.listdir(guides_dir):
                    if f.endswith(".md"):
                        guides.append(f)
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"guides": sorted(guides)}).encode())
            
        elif parsed_path.path == "/api/guide_content":
            query = parse_qs(parsed_path.query)
            guide_name = query.get("name", [""])[0]
            guides_dir = os.path.join(BASE_DIR, "antigravity", "guides")
            safe_path = os.path.abspath(os.path.join(guides_dir, guide_name))
            if safe_path.startswith(os.path.abspath(guides_dir)) and os.path.exists(safe_path):
                with open(safe_path, "r", encoding="utf-8") as f:
                    content = f.read()
                self.send_response(200)
                self.send_header("Content-type", "text/plain; charset=utf-8")
                self.end_headers()
                self.wfile.write(content.encode("utf-8"))
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b"Guide not found")

        elif parsed_path.path == "/status":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif parsed_path.path == "/crashes":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"crashes": list(CRASHED_SESSIONS)}).encode())
            
        elif parsed_path.path == "/eqbc_chat":
            data = {"chat": list(EQBC_CLIENT.chat_history)}
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(data).encode())
            
        elif parsed_path.path == "/groups":
            groups = []
            if os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("SELECT id, name FROM profile_groups ORDER BY sort_order")
                    for row in c.fetchall():
                        groups.append({"id": row[0], "name": row[1]})
                    conn.close()
                except Exception as e:
                    print("DB error:", e)
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"groups": groups}).encode())

        elif parsed_path.path == "/group_details":
            try:
                sync_mariadb_to_mq_login()
            except Exception as e:
                print("Auto-sync error during details:", e)
                
            groups = []
            all_chars = []
            if os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    
                    # 1. Get all characters
                    c.execute("SELECT id, character FROM characters ORDER BY character")
                    for row in c.fetchall():
                        all_chars.append({"id": row[0], "name": row[1].capitalize()})
                        
                    # 2. Get all groups
                    c.execute("SELECT id, name FROM profile_groups ORDER BY sort_order")
                    group_rows = c.fetchall()
                    for g_row in group_rows:
                        g_id, g_name = g_row
                        members = []
                        c.execute("""
                            SELECT c.id, c.character, c.server, p.sort_order, p.eq_path, p.additional_eqgame_args 
                            FROM profiles p 
                            JOIN characters c ON p.character_id = c.id 
                            WHERE p.group_id = ? 
                            ORDER BY pg.name, p.sort_order
                        """, (g_id,))
                        for m_row in c.fetchall():
                            members.append({
                                "character_id": m_row[0],
                                "character_name": m_row[1].capitalize(),
                                "server": m_row[2],
                                "sort_order": m_row[3],
                                "eq_path": m_row[4],
                                "additional_eqgame_args": m_row[5],
                                "class_id": 0,
                                "class_name": ""
                            })
                        groups.append({
                            "id": g_id,
                            "name": g_name,
                            "members": members
                        })
                    conn.close()
                except Exception as e:
                    print("DB details error:", e)

            # Enrich with class info from MariaDB
            try:
                mdb = get_connection()
                with mdb.cursor() as cur:
                    cur.execute("SELECT name, class FROM character_data")
                    class_map = {row['name'].strip().capitalize(): row['class'] for row in cur.fetchall()}
                mdb.close()

                for ac in all_chars:
                    cid = class_map.get(ac['name'], 0)
                    ac['class_id'] = cid
                    ac['class_name'] = CLASSES.get(cid, '')

                for g in groups:
                    for m in g['members']:
                        cid = class_map.get(m['character_name'], 0)
                        m['class_id'] = cid
                        m['class_name'] = CLASSES.get(cid, '')
            except Exception as e:
                print("MariaDB class lookup error:", e)

            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"groups": groups, "all_characters": all_chars}).encode())

        elif parsed_path.path == "/classes_races":
            combinations = []
            conn = get_connection()
            try:
                with conn.cursor() as cursor:
                    cursor.execute("SELECT DISTINCT race, class FROM char_create_combinations")
                    for row in cursor.fetchall():
                        combinations.append({"race": row["race"], "class": row["class"]})
            except Exception as e:
                print("Error loading race/class combinations:", e)
            finally:
                conn.close()

            response_data = {
                "classes": CLASSES,
                "races": RACES,
                "zones": ZONES,
                "deities": DEITIES,
                "combinations": combinations
            }
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode())

        elif parsed_path.path == "/characters":
            characters = []
            try:
                conn = get_connection()
                with conn.cursor() as cursor:
                    cursor.execute("""
                        SELECT cd.id, cd.name, cd.level, cd.class, cd.race, a.name as account_name
                        FROM character_data cd
                        LEFT JOIN account a ON cd.account_id = a.id
                        ORDER BY cd.name
                    """)
                    for row in cursor.fetchall():
                        row['class_name'] = CLASSES.get(row['class'], 'Unknown')
                        row['race_name'] = RACES.get(row['race'], 'Unknown')
                        characters.append(row)
                conn.close()
            except Exception as e:
                print("Error loading characters from MariaDB, falling back to login.db:", e)
                if os.path.exists(DEFAULT_LOGIN_DB):
                    try:
                        conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                        c = conn.cursor()
                        c.execute("SELECT character FROM characters ORDER BY character")
                        for row in c.fetchall():
                            characters.append({
                                'name': row[0].capitalize(),
                                'id': 0, 'level': 0, 'class_name': 'Unknown', 'race_name': 'Unknown'
                            })
                        conn.close()
                    except Exception as fallback_e:
                        print("Fallback DB error:", fallback_e)
                
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"characters": characters}).encode())

        elif parsed_path.path == "/search_items":
            params = parse_qs(parsed_path.query)
            q = params.get('q', [''])[0]
            items = []
            if q:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("""
                            SELECT id, Name, hp, mana, ac, damage, delay 
                            FROM items 
                            WHERE Name LIKE %s LIMIT 50
                        """, (f"%{q}%",))
                        items = cursor.fetchall()
                except Exception as e:
                    print("Error searching items:", e)
                finally:
                    conn.close()
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"items": items}).encode())

        elif parsed_path.path == "/launchable_characters":
            try:
                sync_mariadb_to_mq_login()
            except Exception as e:
                print("[Sync] Auto-sync error during fetch:", e)
                
            characters = []
            if os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        SELECT DISTINCT character 
                        FROM characters 
                        ORDER BY character
                    """)
                    for row in c.fetchall():
                        characters.append(row[0].capitalize())
                    conn.close()
                except Exception as e:
                    print("DB error:", e)
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"characters": characters}).encode())
            
        elif parsed_path.path == "/get_character_inventory":
            params = parse_qs(parsed_path.query)
            char_id_str = params.get('character_id', [''])[0]
            inventory = []
            char_info = {}
            if char_id_str:
                try:
                    char_id = int(char_id_str)
                    conn = get_connection()
                    try:
                        with conn.cursor() as cursor:
                            cursor.execute("""
                                SELECT c.id, c.name, c.level, c.aa_points, COALESCE(cc.platinum, 0) as platinum, c.race, c.class 
                                FROM character_data c
                                LEFT JOIN character_currency cc ON c.id = cc.id
                                WHERE c.id = %s
                            """, (char_id,))
                            char_info = cursor.fetchone()
                            if char_info:
                                char_info['class_name'] = CLASSES.get(char_info['class'], 'Unknown')
                                char_info['race_name'] = RACES.get(char_info['race'], 'Unknown')
                                import decimal
                                for k, v in char_info.items():
                                    if isinstance(v, decimal.Decimal):
                                        char_info[k] = int(v)
                            
                            cursor.execute("""
                                SELECT i.slot_id, i.item_id, it.Name, i.charges 
                                FROM inventory i
                                JOIN items it ON i.item_id = it.id
                                WHERE i.character_id = %s
                                ORDER BY i.slot_id
                            """, (char_id,))
                            for row in cursor.fetchall():
                                slot_name = EQUIP_SLOTS.get(row['slot_id'], f"Slot {row['slot_id']}")
                                inventory.append({
                                    "slot_id": row['slot_id'],
                                    "slot_name": slot_name,
                                    "item_id": row['item_id'],
                                    "item_name": row['Name'],
                                    "charges": row['charges']
                                })
                    except Exception as e:
                        print("Error fetching inventory:", e)
                    finally:
                        conn.close()
                except ValueError:
                    pass
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"inventory": inventory, "character": char_info}).encode())

        elif parsed_path.path == "/list_bots":
            bots = []
            conn = get_connection()
            try:
                with conn.cursor() as cursor:
                    cursor.execute("""
                        SELECT b.bot_id, b.name, b.level, b.class, b.race, b.owner_id, c.name as owner_name 
                        FROM bot_data b 
                        LEFT JOIN character_data c ON b.owner_id = c.id 
                        ORDER BY b.name
                    """)
                    for row in cursor.fetchall():
                        row['class_name'] = CLASSES.get(row['class'], 'Unknown')
                        row['race_name'] = RACES.get(row['race'], 'Unknown')
                        bots.append(row)
            except Exception as e:
                print("Error listing bots:", e)
            finally:
                conn.close()
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"bots": bots}).encode())

        elif parsed_path.path == "/get_bot_details":
            params = parse_qs(parsed_path.query)
            bot_id_str = params.get('bot_id', [''])[0]
            inventory = []
            bot_info = {}
            if bot_id_str:
                try:
                    bot_id = int(bot_id_str)
                    conn = get_connection()
                    try:
                        with conn.cursor() as cursor:
                            cursor.execute("""
                                SELECT b.bot_id, b.name, b.level, b.class, b.race, b.owner_id, c.name as owner_name 
                                FROM bot_data b
                                LEFT JOIN character_data c ON b.owner_id = c.id
                                WHERE b.bot_id = %s
                            """, (bot_id,))
                            bot_info = cursor.fetchone()
                            if bot_info:
                                bot_info['class_name'] = CLASSES.get(bot_info['class'], 'Unknown')
                                bot_info['race_name'] = RACES.get(bot_info['race'], 'Unknown')
                            
                            cursor.execute("""
                                SELECT bi.slot_id, bi.item_id, it.Name, bi.inst_charges 
                                FROM bot_inventories bi
                                JOIN items it ON bi.item_id = it.id
                                WHERE bi.bot_id = %s
                                ORDER BY bi.slot_id
                            """, (bot_id,))
                            for row in cursor.fetchall():
                                slot_name = EQUIP_SLOTS.get(row['slot_id'], f"Slot {row['slot_id']}")
                                inventory.append({
                                    "slot_id": row['slot_id'],
                                    "slot_name": slot_name,
                                    "item_id": row['item_id'],
                                    "item_name": row['Name'],
                                    "charges": row['inst_charges']
                                })
                    except Exception as e:
                        print("Error fetching bot details:", e)
                    finally:
                        conn.close()
                except ValueError:
                    pass
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"inventory": inventory, "bot": bot_info}).encode())

        elif parsed_path.path == "/get_orchestrator_config":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(connection_config).encode())
            
        else:
            self.send_error(404)

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0))
        if length > 0:
            body = self.rfile.read(length)
            try:
                data = json.loads(body)
            except:
                data = {}
        else:
            data = {}

        if self.path == "/dismiss_crashes":
            CRASHED_SESSIONS.clear()
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/relaunch_crashes":
            crashes = list(CRASHED_SESSIONS)
            CRASHED_SESSIONS.clear()
            
            if os.path.exists(DEFAULT_LOGIN_DB):
                conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                c = conn.cursor()
                for char_name in crashes:
                    c.execute("""
                        SELECT c.character, c.server, p.eq_path, p.additional_eqgame_args 
                        FROM characters c 
                        LEFT JOIN profiles p ON c.id = p.character_id
                        WHERE LOWER(c.character) = ? LIMIT 1
                    """, (char_name.lower(),))
                    row = c.fetchone()
                    if row:
                        name, server, eq_path, args = row
                        if not eq_path or not os.path.exists(eq_path):
                            eq_path = DEFAULT_EQ_PATH
                        cmd_str = get_native_launch_cmd(name, eq_path, args, server)
                        ACTIVE_SESSIONS[name.lower()] = time.time()
                        working_dir = os.path.dirname(eq_path)
                        subprocess.Popen(cmd_str, cwd=working_dir, shell=True)
                conn.close()
                
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/shutdown":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            def _do_shutdown():
                time.sleep(0.3)
                if _server_instance:
                    _server_instance.shutdown()
            threading.Thread(target=_do_shutdown, daemon=True).start()
            return

        elif self.path == "/restart":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Content-Length", "2")
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(b"{}")
            
            try:
                self.wfile.flush()
            except:
                pass

            def _do_restart():
                try:
                    time.sleep(0.3)
                    if _server_instance:
                        _server_instance.shutdown()
                    time.sleep(1.0)
                    script = os.path.abspath(sys.argv[0])
                    CREATE_NEW_CONSOLE = 0x00000010
                    subprocess.Popen(
                        ['cmd', '/k', sys.executable, script],
                        cwd=os.path.dirname(script),
                        creationflags=CREATE_NEW_CONSOLE,
                        close_fds=True
                    )
                except Exception as e:
                    import traceback; traceback.print_exc()
            threading.Thread(target=_do_restart, daemon=False).start()
            return

        elif self.path == "/cmd":
            char = data.get("character")
            cmd = data.get("command")
            if char and cmd:
                self.write_cmd(char, cmd)
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/cmd/all":
            cmd = data.get("command")
            if cmd:
                self.write_cmd("all", cmd)
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/cmd/ae_toggle":
            state = data.get("state", True)
            if state:
                # Enable AE Mode
                cmds = [
                    "/bcaa //rglua aemode on",
                    "/bct Bardia //rglua melody aemana",
                    "/bct Bardib //rglua melody aemana",
                    "/bct Bardic //rglua melody aemana"
                ]
            else:
                # Disable AE Mode
                cmds = [
                    "/bcaa //rglua aemode off",
                    "/bct Bardia //rglua melody stop",
                    "/bct Bardib //rglua melody stop",
                    "/bct Bardic //rglua melody stop"
                ]
            self.write_cmd("Mobsterer", "\n".join(cmds))
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")

        elif self.path == "/cmd/ae_start":
            self.write_cmd("Mobsterer", "/bcaa //lua run aeheals\n/bcaa //lua run aestun\n/lua run aefarm")
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")

        elif self.path == "/cmd/ae_stop":
            self.write_cmd("Mobsterer", "/bcaa //lua stop aeheals\n/bcaa //lua stop aestun\n/lua stop aefarm\n/bcaa //rglua pause")
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/cmd/summon_all":
            self.write_cmd("Mobsterer", "/lua run summall")
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/cmd/launch_ae_cohort":
            # Spin up a thread so we don't block the UI while 18 clients launch
            def _launch_ae():
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        SELECT c.character, p.custom_client_ini, c.server, p.sort_order 
                        FROM profiles p 
                        JOIN characters c ON p.character_id = c.id 
                        JOIN profile_groups pg ON p.group_id = pg.id
                        WHERE pg.name IN ('AE_Cohort_G1', 'AE_Cohort_G2', 'AE_Cohort_G3')
                        ORDER BY pg.name, p.sort_order
                    """)
                    profiles = c.fetchall()
                    conn.close()
                    
                    eq_path = DEFAULT_EQ_PATH
                    working_dir = os.path.dirname(eq_path)
                    
                    if not profiles:
                        print("No profiles found for AE Cohort groups!")
                        return
                        
                    online_chars = get_online_characters(max_age=15)
                        
                    print(f"Launching AE Cohort ({len(profiles)} characters)...")
                    for idx, p in enumerate(profiles):
                        char_name = p[0]
                        custom_client_ini = p[1]
                        server = p[2]
                        
                        if char_name:
                            if char_name.lower() in online_chars:
                                print(f"[{char_name}] already online, skipping launch.")
                                ACTIVE_SESSIONS[char_name.lower()] = time.time()
                                continue
                                
                            ACTIVE_SESSIONS[char_name.lower()] = time.time()
                            cmd_str = get_native_launch_cmd(char_name, eq_path, custom_client_ini, server)
                            print(f"Launching {char_name}: {cmd_str}")
                            
                            working_dir = os.path.dirname(eq_path)
                            subprocess.Popen(cmd_str, shell=True, cwd=working_dir)
                            if idx < len(profiles) - 1:
                                time.sleep(8)
                                
                    # Once all launch processes are spawned, start a monitor to form the raid
                    def _auto_form_ae_raid(expected):
                        print("[AutoRaid] Monitoring AE Cohort to come online...")
                        start_time = time.time()
                        while time.time() - start_time < 300:
                            online_chars = set()
                            files = glob.glob(os.path.join(COMMANDS_DIR, "*.status.json"))
                            for f in files:
                                try:
                                    with open(f, 'r') as fh:
                                        content = json.load(fh)
                                        c_name = content.get("name")
                                        if c_name and time.time() - content.get("timestamp", 0) < 6:
                                            online_chars.add(c_name.lower())
                                except: pass
                            
                            if all(m.lower() in online_chars for m in expected):
                                print("[AutoRaid] All AE members online! Delaying 8s...")
                                time.sleep(8)
                                g1 = expected[0:6]
                                g2 = expected[6:12]
                                g3 = expected[12:18]
                                
                                # Generate and write the autonomous Lua script
                                lua_script = generate_auto_raid_lua(g1, g2, g3)
                                lua_path = r"c:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\lua\auto_raid.lua"
                                try:
                                    with open(lua_path, "w") as f:
                                        f.write(lua_script)
                                except Exception as e:
                                    print(f"Failed to write lua script: {e}")
                                
                                # Trigger only the master raid leader to execute the orchestration script
                                write_cmd(g1[0].lower(), "/lua run auto_raid")
                                
                                # Wait for raid assembly to complete before setting MA
                                def delayed_ma_set():
                                    time.sleep(20)
                                    write_cmd_global("all", f"/rglua mainassist {g1[0]}")
                                    print("[AutoRaid] Raid formation complete.")
                                    
                                threading.Thread(target=delayed_ma_set, daemon=True).start()
                                return
                                return
                            time.sleep(3)
                    
                    threading.Thread(target=_auto_form_ae_raid, args=([p[0].capitalize() for p in profiles],), daemon=True).start()
                                
                except Exception as e:
                    print(f"Error launching AE cohort: {e}")
            threading.Thread(target=_launch_ae, daemon=True).start()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"{}")
            
        elif self.path == "/cmd/ae_form_raid":
            def _form_raid():
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        SELECT c.character 
                        FROM profiles p 
                        JOIN characters c ON p.character_id = c.id 
                        JOIN profile_groups pg ON p.group_id = pg.id
                        WHERE pg.name IN ('AE_Cohort_G1', 'AE_Cohort_G2', 'AE_Cohort_G3')
                        ORDER BY pg.name, p.sort_order
                    """)
                    cohort = [row[0].capitalize() for row in c.fetchall()]
                    conn.close()
                    if not cohort:
                        return
                        
                    g1 = cohort[0:6]
                    g2 = cohort[6:12]
                    g3 = cohort[12:18]
                    
                    # Generate and write the autonomous Lua script
                    lua_script = generate_auto_raid_lua(g1, g2, g3)
                    lua_path = r"c:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\lua\auto_raid.lua"
                    try:
                        with open(lua_path, "w") as f:
                            f.write(lua_script)
                    except Exception as e:
                        print(f"Failed to write lua script: {e}")
                    
                    # Trigger only the master raid leader to execute the orchestration script
                    write_cmd(g1[0].lower(), "/lua run auto_raid")
                    
                    # Wait for raid assembly to complete before setting MA
                    def delayed_ma_set():
                        time.sleep(20)
                        write_cmd_global("all", f"/rglua mainassist {g1[0]}")
                        print("[AutoRaid] Raid formation complete.")
                        
                    threading.Thread(target=delayed_ma_set, daemon=True).start()
                    
                except Exception as e:
                    print(f"Error forming AE raid: {e}")
            threading.Thread(target=_form_raid, daemon=True).start()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'{"status": "ok"}')

        elif self.path == "/launch_group":
            group_id = data.get("group_id")
            launched = 0
            if group_id and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    
                    c.execute("""
                        SELECT c.character, p.custom_client_ini, c.server 
                        FROM profiles p 
                        LEFT JOIN characters c ON p.character_id = c.id
                        WHERE p.group_id = ? ORDER BY pg.name, p.sort_order
                    """, (group_id,))
                    profiles = c.fetchall()
                    conn.close()
                    
                    eq_path = DEFAULT_EQ_PATH
                    working_dir = os.path.dirname(eq_path)
                    
                    online_chars = get_online_characters(max_age=15)
                    
                    for idx, p in enumerate(profiles):
                        char_name = p[0]
                        custom_client_ini = p[1]
                        server = p[2]
                        if char_name:
                            if char_name.lower() in online_chars:
                                print(f"[{char_name}] already online, skipping launch.")
                                ACTIVE_SESSIONS[char_name.lower()] = time.time()
                                continue
                                
                            ACTIVE_SESSIONS[char_name.lower()] = time.time()
                            cmd_str = get_native_launch_cmd(char_name, eq_path, custom_client_ini, server)
                            print(f"Launching {char_name}: {cmd_str}")
                            subprocess.Popen(cmd_str, shell=True, cwd=working_dir)
                            launched += 1
                            if idx < len(profiles) - 1:
                                time.sleep(8)
                    
                    threading.Thread(target=auto_group_formation_thread, args=(group_id,), daemon=True).start()
                except Exception as e:
                    print("Launch error:", e)
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return
            
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"launched": launched}).encode())

        elif self.path == "/launch_character":
            char_name = data.get("character_name")
            launched = 0
            if char_name and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    online_chars = get_online_characters(max_age=15)

                    if char_name.lower() in online_chars:
                        self.send_response(200)
                        self.send_header("Content-type", "application/json")
                        self.end_headers()
                        self.wfile.write(json.dumps({"error": f"{char_name} is already online."}).encode())
                        return

                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        SELECT c.character, c.server, p.eq_path, p.additional_eqgame_args 
                        FROM characters c 
                        LEFT JOIN profiles p ON c.id = p.character_id
                        WHERE LOWER(c.character) = ? LIMIT 1
                    """, (char_name.lower(),))
                    row = c.fetchone()
                    conn.close()
                    
                    if row:
                        name, server, eq_path, args = row
                        if not eq_path or not os.path.exists(eq_path):
                            eq_path = DEFAULT_EQ_PATH
                        cmd_str = get_native_launch_cmd(name, eq_path, args, server)
                        ACTIVE_SESSIONS[name.lower()] = time.time()
                        
                        print(f"Launching single character: {cmd_str}")
                        working_dir = os.path.dirname(eq_path)
                        subprocess.Popen(
                            cmd_str, 
                            cwd=working_dir,
                            shell=True
                        )
                        launched = 1
                    else:
                        self.send_response(400)
                        self.send_header("Content-type", "application/json")
                        self.end_headers()
                        self.wfile.write(json.dumps({"error": f"Character {char_name} not found in login.db"}).encode())
                        return
                except Exception as e:
                    print("Launch single error:", e)
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return
            
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"launched": launched}).encode())

        elif self.path == "/create_character":
            name = data.get("name")
            race_id = data.get("race_id")
            class_id = data.get("class_id")
            gender_id = data.get("gender_id")
            deity_id = data.get("deity_id")
            group_name = data.get("group_name", "Group1")
            zone_id = data.get("zone_id", 394)

            try:
                char_id, cap_name = create_character(name, race_id, class_id, gender_id, deity_id, zone_id)
                add_to_mq_login(cap_name, group_name)
                
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "name": cap_name, "char_id": char_id}).encode())
            except Exception as e:
                print("Character creation error:", e)
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())

        elif self.path == "/grant_item":
            char_name = data.get("character_name")
            item_id = data.get("item_id")
            charges = data.get("charges", 1)

            try:
                add_item_to_inventory(char_name, item_id, charges)
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True}).encode())
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())

        elif self.path == "/apply_kit":
            char_name = data.get("character_name")
            kit_type = data.get("kit_type")

            success, message = apply_gearing_kit(char_name, kit_type)
            if success:
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "message": message}).encode())
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": message}).encode())

        elif self.path == "/scribe_spells":
            char_id = data.get("character_id")

            success, message = scribe_all_spells(char_id)
            if success:
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "message": message}).encode())
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": message}).encode())

        elif self.path == "/learn_disciplines":
            char_id = data.get("character_id")

            success, message = learn_disciplines(char_id)
            if success:
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "message": message}).encode())
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": message}).encode())

        elif self.path == "/train_skills":
            char_id = data.get("character_id")

            success, message = train_skills(char_id)
            if success:
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "message": message}).encode())
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": message}).encode())

        elif self.path == "/train_all":
            results = []
            try:
                conn = get_connection()
                with conn.cursor() as cursor:
                    cursor.execute("SELECT id, name FROM character_data ORDER BY name")
                    chars = cursor.fetchall()
                conn.close()

                for ch in chars:
                    cid = ch['id']
                    cname = ch['name']
                    msgs = []
                    for fn in [scribe_all_spells, learn_disciplines, train_skills]:
                        try:
                            _, msg = fn(cid)
                            msgs.append(msg)
                        except Exception as e:
                            msgs.append(f"Error: {e}")
                    results.append({"name": cname, "result": " | ".join(msgs)})

                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "results": results, "count": len(results)}).encode())
            except Exception as e:
                self.send_response(500)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())

        elif self.path == "/move_character":
            char_name = data.get("character_name")
            zone_name = data.get("zone_name")
            use_coords = data.get("use_coords", False)
            x = data.get("x", 0.0)
            y = data.get("y", 0.0)
            z = data.get("z", 0.0)
            use_gm = data.get("use_gm", False)

            success, message = self.move_character_logic(char_name, zone_name, use_coords, x, y, z, use_gm)
            if success:
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "message": message}).encode())
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": message}).encode())
            
        elif self.path == "/create_group":
            name = data.get("name")
            if name and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("SELECT id FROM profile_groups WHERE LOWER(name) = ?", (name.lower(),))
                    if c.fetchone():
                        self.send_response(400)
                        self.send_header("Content-type", "application/json")
                        self.end_headers()
                        self.wfile.write(json.dumps({"error": f"Group '{name}' already exists."}).encode())
                        conn.close()
                        return
                    
                    c.execute("SELECT COALESCE(MAX(sort_order), 0) FROM profile_groups")
                    max_sort = c.fetchone()[0]
                    
                    c.execute("""
                        INSERT INTO profile_groups (name, eq_path, sort_order, last_selected) 
                        VALUES (?, ?, ?, 0)
                    """, (name, os.path.dirname(DEFAULT_EQ_PATH), max_sort + 1))
                    conn.commit()
                    conn.close()
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(b"{}")
                    return
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return

        elif self.path == "/delete_group":
            group_id = data.get("group_id")
            print(f"[DeleteGroup] Received delete request. group_id={group_id}, db_exists={os.path.exists(DEFAULT_LOGIN_DB)}")
            if group_id and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("DELETE FROM profiles WHERE group_id = ?", (group_id,))
                    c.execute("DELETE FROM profile_groups WHERE id = ?", (group_id,))
                    conn.commit()
                    conn.close()
                    print(f"[DeleteGroup] Successfully deleted group {group_id} from login.db")
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(b"{}")
                    return
                except Exception as e:
                    print(f"[DeleteGroup] Error deleting group {group_id}: {e}")
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return
            else:
                print(f"[DeleteGroup] Validation failed: group_id={group_id}")
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing required fields or database path"}).encode())
                return

        elif self.path == "/add_to_group":
            group_id = data.get("group_id")
            character_id = data.get("character_id")
            if group_id and character_id and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    
                    c.execute("SELECT id FROM profiles WHERE character_id = ? AND group_id = ?", (character_id, group_id))
                    if c.fetchone():
                        conn.close()
                        
                        self.send_response(200)
                        self.send_header("Content-type", "application/json")
                        self.end_headers()
                        self.wfile.write(b"{}")
                        return
                    
                    c.execute("SELECT COALESCE(MAX(sort_order), 0) FROM profiles WHERE group_id = ?", (group_id,))
                    max_sort = c.fetchone()[0]
                    
                    c.execute("""
                        INSERT INTO profiles (
                            character_id, group_id, eq_path, hotkey, end_after_select,
                            char_select_delay, custom_client_ini, sort_order, will_load,
                            additional_eqgame_args, sounds
                        ) VALUES (?, ?, ?, '', 0, 10, '', ?, 1, '', 1)
                    """, (character_id, group_id, DEFAULT_EQ_PATH, max_sort + 1))
                    
                    conn.commit()
                    conn.close()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(b"{}")
                    return
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return

        elif self.path == "/remove_from_group":
            group_id = data.get("group_id")
            character_id = data.get("character_id")
            if group_id and character_id and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("DELETE FROM profiles WHERE character_id = ? AND group_id = ?", (character_id, group_id))
                    conn.commit()
                    conn.close()
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(b"{}")
                    return
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return

        elif self.path == "/sync_ingame_group":
            group_id = data.get("group_id")
            if group_id and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        SELECT c.character 
                        FROM profiles p 
                        JOIN characters c ON p.character_id = c.id 
                        WHERE p.group_id = ? 
                        ORDER BY pg.name, p.sort_order
                    """, (group_id,))
                    members = [row[0].capitalize() for row in c.fetchall()]
                    conn.close()
                    
                    if len(members) < 2:
                        self.send_response(400)
                        self.send_header("Content-type", "application/json")
                        self.end_headers()
                        self.wfile.write(json.dumps({"error": "A group must have at least 2 members."}).encode())
                        return
                        
                    leader = members[0]
                    other_members = members[1:]
                    
                    def invite_sequence():
                        # Disband the leader and all members to break up any old raids
                        write_cmd(leader, "/disband")
                        for m in other_members:
                            write_cmd(m, "/disband")
                        
                        time.sleep(2.0)
                        
                        for i, m in enumerate(other_members):
                            if i < 5:
                                write_cmd(leader, f"/invite {m}")
                            else:
                                write_cmd(leader, f"/raidinvite {m}")
                        
                        time.sleep(2.0)
                        
                        for m in other_members:
                            write_cmd(m, "/invite")
                            write_cmd(m, "/yes")
                            
                    threading.Thread(target=invite_sequence).start()
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"message": "Invites queued."}).encode())
                    return
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return

        elif self.path == "/update_group_member":
            group_id = data.get("group_id")
            character_id = data.get("character_id")
            eq_path = data.get("eq_path")
            additional_args = data.get("additional_eqgame_args")
            
            if group_id and character_id and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        UPDATE profiles 
                        SET eq_path = ?, additional_eqgame_args = ? 
                        WHERE character_id = ? AND group_id = ?
                    """, (eq_path, additional_args, character_id, group_id))
                    conn.commit()
                    conn.close()
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(b"{}")
                    return
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing required parameters (group_id, character_id) or login.db path."}).encode())
                return

        elif self.path == "/reorder_group_member":
            group_id = data.get("group_id")
            character_id = data.get("character_id")
            direction = data.get("direction")
            if group_id and character_id and direction and os.path.exists(DEFAULT_LOGIN_DB):
                try:
                    conn = sqlite3.connect(DEFAULT_LOGIN_DB)
                    c = conn.cursor()
                    c.execute("""
                        SELECT character_id, sort_order 
                        FROM profiles 
                        WHERE group_id = ? 
                        ORDER BY sort_order
                    """, (group_id,))
                    rows = c.fetchall()
                    target_idx = -1
                    for idx, r in enumerate(rows):
                        if r[0] == character_id:
                            target_idx = idx
                            break
                    if target_idx != -1:
                        if direction == "up" and target_idx > 0:
                            prev_char_id, prev_sort = rows[target_idx - 1]
                            curr_char_id, curr_sort = rows[target_idx]
                            c.execute("UPDATE profiles SET sort_order = ? WHERE character_id = ? AND group_id = ?", (prev_sort, curr_char_id, group_id))
                            c.execute("UPDATE profiles SET sort_order = ? WHERE character_id = ? AND group_id = ?", (curr_sort, prev_char_id, group_id))
                        elif direction == "down" and target_idx < len(rows) - 1:
                            next_char_id, next_sort = rows[target_idx + 1]
                            curr_char_id, curr_sort = rows[target_idx]
                            c.execute("UPDATE profiles SET sort_order = ? WHERE character_id = ? AND group_id = ?", (next_sort, curr_char_id, group_id))
                            c.execute("UPDATE profiles SET sort_order = ? WHERE character_id = ? AND group_id = ?", (curr_sort, next_char_id, group_id))
                        conn.commit()
                    conn.close()
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(b"{}")
                    return
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                    return
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing required fields"}).encode())
                return

        elif self.path == "/equip_character_item":
            character_id = data.get("character_id")
            slot_id = data.get("slot_id")
            item_id = data.get("item_id")
            charges = data.get("charges", 1)
            
            if character_id is not None and slot_id is not None and item_id is not None:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("SELECT id FROM items WHERE id = %s", (item_id,))
                        if not cursor.fetchone():
                            self.send_response(400)
                            self.send_header("Content-type", "application/json")
                            self.end_headers()
                            self.wfile.write(json.dumps({"error": f"Item ID {item_id} does not exist."}).encode())
                            return
                        cursor.execute("DELETE FROM inventory WHERE character_id = %s AND slot_id = %s", (character_id, slot_id))
                        cursor.execute("""
                            INSERT INTO inventory (character_id, slot_id, item_id, charges, color, augment_one, augment_two, augment_three, augment_four, augment_five, augment_six, instnodrop, ornament_icon, ornament_idfile, ornament_hero_model)
                            VALUES (%s, %s, %s, %s, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                        """, (character_id, slot_id, item_id, charges))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing character_id, slot_id or item_id"}).encode())

        elif self.path == "/delete_character_item":
            character_id = data.get("character_id")
            slot_id = data.get("slot_id")
            
            if character_id is not None and slot_id is not None:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("DELETE FROM inventory WHERE character_id = %s AND slot_id = %s", (character_id, slot_id))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing character_id or slot_id"}).encode())

        elif self.path == "/save_character_stats":
            character_id = data.get("character_id")
            level = data.get("level")
            aa_points = data.get("aa_points")
            platinum = data.get("platinum")
            
            if character_id is not None:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        if level is not None and aa_points is not None:
                            cursor.execute("UPDATE character_data SET level = %s, aa_points = %s WHERE id = %s", (level, aa_points, character_id))
                        if platinum is not None:
                            cursor.execute("""
                                INSERT INTO character_currency (id, platinum) 
                                VALUES (%s, %s) 
                                ON DUPLICATE KEY UPDATE platinum = VALUES(platinum)
                            """, (character_id, platinum))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing character_id"}).encode())

        elif self.path == "/create_bot":
            name = data.get("name")
            owner_name = data.get("owner_name")
            class_name = data.get("class_name")
            race_name = data.get("race_name")
            
            if name and owner_name and class_name and race_name:
                CLASS_REV = {v: k for k, v in CLASSES.items()}
                RACE_REV = {v: k for k, v in RACES.items()}
                class_id = CLASS_REV.get(class_name, 1)
                race_id = RACE_REV.get(race_name, 1)
                spells_id = 3000 + class_id
                
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("SELECT id FROM character_data WHERE name = %s", (owner_name,))
                        owner = cursor.fetchone()
                        if not owner:
                            self.send_response(400)
                            self.send_header("Content-type", "application/json")
                            self.end_headers()
                            self.wfile.write(json.dumps({"error": f"Owner '{owner_name}' not found."}).encode())
                            return
                        owner_id = owner['id']
                        
                        cursor.execute("SELECT COALESCE(MAX(bot_id), 0) + 1 as next_id FROM bot_data")
                        bot_id = cursor.fetchone()['next_id']
                        
                        cursor.execute("""
                            INSERT INTO bot_data (bot_id, owner_id, spells_id, name, last_name, title, suffix, zone_id, gender, race, class, level, deity, creation_day, last_spawn, time_spawned, size, face, hair_color, hair_style, beard, beard_color, eye_color_1, eye_color_2, drakkin_heritage, drakkin_tattoo, drakkin_details, ac, atk, hp, mana, str, sta, cha, dex, int, agi, wis, extra_haste, fire, cold, magic, poison, disease, corruption)
                            VALUES (%s, %s, %s, %s, '', '', '', 0, 0, %s, %s, 1, 0, 0, 0, 0, 5.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 50, 100, 0, 75, 75, 75, 75, 75, 75, 75, 0, 10, 10, 10, 10, 10, 10)
                        """, (bot_id, owner_id, spells_id, name, race_id, class_id))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True, "bot_id": bot_id}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing name, owner_name, class_name, or race_name"}).encode())

        elif self.path == "/save_bot_level":
            bot_id = data.get("bot_id")
            level = data.get("level")
            
            if bot_id is not None and level is not None:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("UPDATE bot_data SET level = %s WHERE bot_id = %s", (level, bot_id))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing bot_id or level"}).encode())

        elif self.path == "/equip_bot_item":
            bot_id = data.get("bot_id")
            slot_id = data.get("slot_id")
            item_id = data.get("item_id")
            charges = data.get("charges", 1)
            
            if bot_id is not None and slot_id is not None and item_id is not None:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("SELECT id FROM items WHERE id = %s", (item_id,))
                        if not cursor.fetchone():
                            self.send_response(400)
                            self.send_header("Content-type", "application/json")
                            self.end_headers()
                            self.wfile.write(json.dumps({"error": f"Item ID {item_id} does not exist."}).encode())
                            return
                        cursor.execute("DELETE FROM bot_inventories WHERE bot_id = %s AND slot_id = %s", (bot_id, slot_id))
                        cursor.execute("""
                            INSERT INTO bot_inventories (bot_id, slot_id, item_id, inst_charges, inst_color, inst_no_drop, inst_custom_data, ornament_icon, ornament_id_file, ornament_hero_model, augment_1, augment_2, augment_3, augment_4, augment_5, augment_6)
                            VALUES (%s, %s, %s, %s, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0)
                        """, (bot_id, slot_id, item_id, charges))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing bot_id, slot_id or item_id"}).encode())

        elif self.path == "/delete_bot_item":
            bot_id = data.get("bot_id")
            slot_id = data.get("slot_id")
            
            if bot_id is not None and slot_id is not None:
                conn = get_connection()
                try:
                    with conn.cursor() as cursor:
                        cursor.execute("DELETE FROM bot_inventories WHERE bot_id = %s AND slot_id = %s", (bot_id, slot_id))
                        conn.commit()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
                finally:
                    conn.close()
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing bot_id or slot_id"}).encode())

        elif self.path == "/offline_session":
            content_length = int(self.headers['Content-Length']) if 'Content-Length' in self.headers else 0
            if content_length > 0:
                post_data = self.rfile.read(content_length)
                try:
                    data = json.loads(post_data.decode('utf-8'))
                    char_name = data.get("character", "")
                    if char_name:
                        ACTIVE_SESSIONS.pop(char_name.lower(), None)
                except Exception as e:
                    import traceback; traceback.print_exc()
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode())

        elif self.path == "/crashed_clients":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            crashed = []
            if ACTIVE_SESSIONS:
                files = glob.glob(os.path.join(COMMANDS_DIR, "*.status.json"))
                online_chars = set()
                for f in files:
                    try:
                        with open(f, 'r') as fh:
                            content = json.load(fh)
                            if time.time() - content.get("timestamp", 0) < 15:
                                c_name = content.get("name", "")
                                if "_" in c_name: c_name = c_name.split("_")[-1]
                                online_chars.add(c_name.lower())
                    except: pass
                for s, launch_time in ACTIVE_SESSIONS.items():
                    if time.time() - launch_time < 60:
                        continue
                    if s.lower() not in online_chars:
                        crashed.append(s.capitalize())
            self.wfile.write(json.dumps({"crashed": crashed}).encode())
            
        elif self.path == "/dismiss_crash":
            content_length = int(self.headers['Content-Length']) if 'Content-Length' in self.headers else 0
            if content_length > 0:
                post_data = self.rfile.read(content_length)
                try:
                    data = json.loads(post_data.decode('utf-8'))
                    chars = data.get("characters", [])
                    for c in chars:
                        ACTIVE_SESSIONS.pop(c.lower(), None)
                except Exception as e:
                    import traceback; traceback.print_exc()
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode())
            
        elif self.path == "/relaunch_crashed":
            content_length = int(self.headers['Content-Length']) if 'Content-Length' in self.headers else 0
            if content_length > 0:
                post_data = self.rfile.read(content_length)
                try:
                    data = json.loads(post_data.decode('utf-8'))
                    chars = data.get("characters", [])
                    eq_path = DEFAULT_EQ_PATH
                    working_dir = os.path.dirname(eq_path)
                    for name in chars:
                        if name.lower() not in ACTIVE_SESSIONS: continue
                        ACTIVE_SESSIONS[name.lower()] = time.time()
                        cmd_str = get_native_launch_cmd(name, eq_path, "", "dodl")
                        working_dir = os.path.dirname(eq_path)
                        print(f"Relaunching crashed character: {cmd_str}")
                        subprocess.Popen(cmd_str, shell=True, cwd=working_dir)
                        time.sleep(4)
                except Exception as e:
                    print(f"Failed to relaunch crashed clients: {e}")
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode())

        elif self.path == "/push_macros_to_all":
            client_dir = os.path.join(BASE_DIR, "everquest_rof2", "everquest_rof2")
            if not os.path.exists(client_dir):
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": f"Client directory not found at {client_dir}"}).encode())
                return
                
            ini_files = [f for f in os.listdir(client_dir) if f.lower().endswith(".ini") and not f.lower().startswith("ui_") and "_" in f]
            
            MACROS = [
                {"name": "MakeCamp", "color": "0", "lines": ["/camphere"]},
                {"name": "ClearCamp", "color": "0", "lines": ["/campoff"]},
                {"name": "Evac", "color": "0", "lines": ["/alt activate 43"]},
                {"name": "StopPull", "color": "0", "lines": ["/rglua puller off"]},
                {"name": "PullTarget", "color": "0", "lines": ["/rglua puller on"]},
                {"name": "SaveCampWP", "color": "0", "lines": ["/nav wp add ${Target.CleanName}"]},
                {"name": "GoToCampWP", "color": "0", "lines": ["/nav wp ${Target.CleanName}"]},
            ]
            
            GM_MACROS = [
                {"name": "GM-Summ", "color": "0", "lines": ["/say #summon ${Target.CleanName}"]},
                {"name": "GM-Goto", "color": "0", "lines": ["/say #goto ${Target.CleanName}"]},
                {"name": "GM-SumCrp", "color": "0", "lines": ["/lua run summcrp"]},
                {"name": "GM-Res", "color": "0", "lines": ["/lua run bcast /lua run autores", "/say #castspell 994"]}
            ]

            
            try:
                pass
            except Exception as e:
                pass
            try:
                for ini_filename in ini_files:
                    ini_path = os.path.join(client_dir, ini_filename)
                    char_name = ini_filename.split("_")[0].lower()
                    
                    with open(ini_path, "r", encoding="utf-8", errors="ignore") as f:
                        lines = f.readlines()
                        
                    socials_sec_idx = -1
                    for idx, line in enumerate(lines):
                        if line.strip().lower() == "[socials]":
                            socials_sec_idx = idx
                            break
                            
                    if socials_sec_idx == -1:
                        lines.append("\n[Socials]\n")
                        socials_sec_idx = len(lines) - 1
                        
                    social_keys = {}
                    for idx in range(socials_sec_idx + 1, len(lines)):
                        line = lines[idx].strip()
                        if line.startswith("[") and line.endswith("]"):
                            break
                        if "=" in line:
                            parts = line.split("=", 1)
                            social_keys[parts[0].strip().lower()] = parts[1].strip()
                            
                    macros_to_add = list(MACROS)
                    if char_name == "mobsterer":
                        macros_to_add.extend(GM_MACROS)
                        
                    macro_names = [m["name"].lower() for m in macros_to_add]
                    
                    # Find existing prefixes for these macros
                    prefixes_to_remove = set()
                    for key, val in social_keys.items():
                        if key.endswith("name") and val.lower() in macro_names:
                            # key is like 'page2button5name'
                            prefix = key[:-4] # 'page2button5'
                            prefixes_to_remove.add(prefix)
                            
                    # Remove all lines that start with these prefixes
                    filtered_lines = []
                    for line in lines:
                        skip = False
                        for p in prefixes_to_remove:
                            if line.lower().strip().startswith(p):
                                skip = True
                                break
                        if not skip:
                            filtered_lines.append(line)
                            
                    lines = filtered_lines
                    
                    new_lines_to_add = []
                    
                    # Also remove the removed keys from social_keys so we can reuse slots if needed
                    keys_to_delete = [k for k in social_keys.keys() if any(k.startswith(p) for p in prefixes_to_remove)]
                    for k in keys_to_delete:
                        del social_keys[k]
                    
                    for macro in macros_to_add:
                        # Find an empty slot
                        target_page = None
                        target_button = None
                        for page in range(2, 11):
                            for btn in range(1, 11):
                                name_key = f"page{page}button{btn}name"
                                line1_key = f"page{page}button{btn}line1"
                                
                                if name_key not in social_keys and line1_key not in social_keys:
                                    target_page = page
                                    target_button = btn
                                    social_keys[name_key] = macro["name"] # reserve it
                                    break
                            if target_page is not None:
                                break
                                
                        if target_page is not None:
                            new_lines_to_add.append(f"Page{target_page}Button{target_button}Name={macro['name']}\n")
                            new_lines_to_add.append(f"Page{target_page}Button{target_button}Color={macro['color']}\n")
                            for idx, m_line in enumerate(macro["lines"]):
                                new_lines_to_add.append(f"Page{target_page}Button{target_button}Line{idx+1}={m_line}\n")
                                
                    if new_lines_to_add:
                        # Find socials_sec_idx again after filtering
                        socials_sec_idx = -1
                        for idx, line in enumerate(lines):
                            if line.strip().lower() == "[socials]":
                                socials_sec_idx = idx
                                break
                        lines.insert(socials_sec_idx + 1, "".join(new_lines_to_add))
                        with open(ini_path, "w", encoding="utf-8") as f:
                            f.writelines(lines)
                            
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True}).encode())
                
            except Exception as e:
                self.send_response(500)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())
                
        elif self.path == "/write_character_macro":
            owner_name = data.get("owner_name")
            engine = data.get("engine", "Standard EQ")
            prefix = data.get("prefix", "^")
            default_stance = data.get("stance", "Balanced")
            selected_bots = data.get("bots", [])
            
            if not owner_name or not selected_bots:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing owner_name or bots list"}).encode())
                return
                
            client_dir = os.path.join(BASE_DIR, "everquest_rof2", "everquest_rof2")
            if not os.path.exists(client_dir):
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": f"Client directory not found at {client_dir}"}).encode())
                return
                
            ini_files = [f for f in os.listdir(client_dir) if f.lower().startswith(f"{owner_name.lower()}_") and f.lower().endswith(".ini") and not f.lower().startswith("ui_")]
            if not ini_files:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": f"No configuration .ini file found for character '{owner_name}'"}).encode())
                return
                
            ini_path = os.path.join(client_dir, ini_files[0])
            
            def format_cmd(pref, action, target, extra=""):
                p = pref.strip()
                if p.startswith("/") or p.startswith("#"):
                    if extra:
                        return f"{p} {action} {target} {extra}"
                    return f"{p} {action} {target}"
                else:
                    if extra:
                        return f"/say {p}{action} {target} {extra}"
                    return f"/say {p}{action} {target}"

            spawns = [format_cmd(prefix, "spawn", b) for b in selected_bots]
            invites = [f"/invite {b}" for b in selected_bots[:5]] + [f"/raidinvite {b}" for b in selected_bots[5:]]
            
            STANCE_MAP = {
                "Passive": "0", "Balanced": "1", "Efficient": "2",
                "Reactive": "3", "Aggressive": "4", "Burn": "5", "BurnAE": "6"
            }
            
            stances = []
            conn = get_connection()
            try:
                with conn.cursor() as cursor:
                    for b in selected_bots:
                        bot_stance = STANCE_MAP.get(default_stance, "1")
                        cursor.execute("SELECT class FROM bot_data WHERE name = %s", (b,))
                        res = cursor.fetchone()
                        if res:
                            class_id = res['class']
                            if class_id in [1, 3, 5]:
                                bot_stance = "1"
                            elif class_id in [2, 6, 10]:
                                bot_stance = "2"
                            else:
                                bot_stance = "5"
                        stances.append(format_cmd(prefix, "stance", b, bot_stance))
            except Exception as e:
                print("Error stance lookup:", e)
            finally:
                conn.close()

            macro_lines = []
            if engine == "Standard EQ":
                for spawn_cmd in spawns:
                    macro_lines.append(f"/pause 10, {spawn_cmd}")
                for invite_cmd in invites:
                    macro_lines.append(invite_cmd)
                for stance_cmd in stances:
                    macro_lines.append(stance_cmd)
                macro_lines = macro_lines[:5]
            else:
                if len(spawns) > 1:
                    macro_lines.append("/multiline " + "; ".join(spawns))
                elif spawns:
                    macro_lines.append(spawns[0])
                macro_lines.append("/delay 10")
                if len(invites) > 1:
                    macro_lines.append("/multiline " + "; ".join(invites))
                elif invites:
                    macro_lines.append(invites[0])
                if len(stances) > 1:
                    macro_lines.append("/multiline " + "; ".join(stances))
                elif stances:
                    macro_lines.append(stances[0])
            
            try:
                with open(ini_path, "r", encoding="utf-8", errors="ignore") as f:
                    lines = f.readlines()
            except Exception as ex:
                self.send_response(500)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": f"Failed to read ini: {ex}"}).encode())
                return
                
            socials_sec_idx = -1
            for idx, line in enumerate(lines):
                if line.strip().lower() == "[socials]":
                    socials_sec_idx = idx
                    break
                    
            social_keys = {}
            if socials_sec_idx != -1:
                for idx in range(socials_sec_idx + 1, len(lines)):
                    line = lines[idx].strip()
                    if line.startswith("[") and line.endswith("]"):
                        break
                    if "=" in line:
                        parts = line.split("=", 1)
                        key = parts[0].strip().lower()
                        val = parts[1].strip()
                        social_keys[key] = val
                        
            target_page = None
            target_button = None
            for page in range(2, 11):
                for btn in range(1, 11):
                    name_key = f"page{page}button{btn}name"
                    line1_key = f"page{page}button{btn}line1"
                    
                    has_name = name_key in social_keys and social_keys[name_key]
                    has_line1 = line1_key in social_keys and social_keys[line1_key]
                    
                    if not has_name and not has_line1:
                        target_page = page
                        target_button = btn
                        break
                if target_page is not None:
                    break
                    
            if target_page is None:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "No empty social slots found on pages 2-10."}).encode())
                return
                
            new_lines_to_add = [
                f"Page{target_page}Button{target_button}Name=Spawn {selected_bots[0][:5]}...\n",
                f"Page{target_page}Button{target_button}Color=0\n"
            ]
            for idx, m_line in enumerate(macro_lines[:5]):
                new_lines_to_add.append(f"Page{target_page}Button{target_button}Line{idx+1}={m_line}\n")
                
            if socials_sec_idx == -1:
                lines.append("\n[Socials]\n")
                lines.extend(new_lines_to_add)
            else:
                for newline in reversed(new_lines_to_add):
                    lines.insert(socials_sec_idx + 1, newline)
                    
            try:
                with open(ini_path, "w", encoding="utf-8") as f:
                    f.writelines(lines)
                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({
                    "success": True,
                    "message": f"Macro successfully written to Page {target_page}, Button {target_button}.",
                    "page": target_page,
                    "button": target_button,
                    "macro_lines": macro_lines
                }).encode())
            except Exception as ex:
                self.send_response(500)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": f"Failed to write to ini: {ex}"}).encode())

        elif self.path == "/generate_macro":
            owner_name = data.get("owner_name")
            engine = data.get("engine", "Standard EQ")
            prefix = data.get("prefix", "^")
            default_stance = data.get("stance", "Balanced")
            selected_bots = data.get("bots", [])
            
            if not selected_bots:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "No bots selected"}).encode())
                return
                
            def format_cmd(pref, action, target, extra=""):
                p = pref.strip()
                if p.startswith("/") or p.startswith("#"):
                    if extra:
                        return f"{p} {action} {target} {extra}"
                    return f"{p} {action} {target}"
                else:
                    if extra:
                        return f"/say {p}{action} {target} {extra}"
                    return f"/say {p}{action} {target}"

            spawns = [format_cmd(prefix, "spawn", b) for b in selected_bots]
            invites = [f"/invite {b}" for b in selected_bots[:5]] + [f"/raidinvite {b}" for b in selected_bots[5:]]
            
            STANCE_MAP = {
                "Passive": "0", "Balanced": "1", "Efficient": "2",
                "Reactive": "3", "Aggressive": "4", "Burn": "5", "BurnAE": "6"
            }
            
            stances = []
            conn = get_connection()
            try:
                with conn.cursor() as cursor:
                    for b in selected_bots:
                        bot_stance = STANCE_MAP.get(default_stance, "1")
                        cursor.execute("SELECT class FROM bot_data WHERE name = %s", (b,))
                        res = cursor.fetchone()
                        if res:
                            class_id = res['class']
                            if class_id in [1, 3, 5]:
                                bot_stance = "1"
                            elif class_id in [2, 6, 10]:
                                bot_stance = "2"
                            else:
                                bot_stance = "5"
                        stances.append(format_cmd(prefix, "stance", b, bot_stance))
            except Exception as e:
                print("Stance lookup error:", e)
            finally:
                conn.close()

            macro_lines = []
            if engine == "Standard EQ":
                for spawn_cmd in spawns:
                    macro_lines.append(f"/pause 10, {spawn_cmd}")
                for invite_cmd in invites:
                    macro_lines.append(invite_cmd)
                for stance_cmd in stances:
                    macro_lines.append(stance_cmd)
                macro_lines = macro_lines[:5]
            else:
                if len(spawns) > 1:
                    macro_lines.append("/multiline " + "; ".join(spawns))
                elif spawns:
                    macro_lines.append(spawns[0])
                macro_lines.append("/delay 10")
                if len(invites) > 1:
                    macro_lines.append("/multiline " + "; ".join(invites))
                elif invites:
                    macro_lines.append(invites[0])
                if len(stances) > 1:
                    macro_lines.append("/multiline " + "; ".join(stances))
                elif stances:
                    macro_lines.append(stances[0])
                    
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"success": True, "macro_lines": macro_lines}).encode())

        elif self.path == "/save_orchestrator_config":
            host = data.get("host")
            port = data.get("port")
            user = data.get("user")
            password = data.get("password")
            database = data.get("database")
            
            if host and port and user and password and database:
                config_data = {
                    "host": host,
                    "port": int(port),
                    "user": user,
                    "password": password,
                    "database": database
                }
                try:
                    config_paths = [
                        os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json"),
                        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "config.json")
                    ]
                    for path in config_paths:
                        try:
                            with open(path, "w") as f:
                                json.dump(config_data, f, indent=4)
                        except:
                            pass
                        
                    connection_config.update(config_data)
                    
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"success": True}).encode())
                except Exception as e:
                    self.send_response(500)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode())
            else:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Missing database parameters"}).encode())
                
        else:
            self.send_error(404)

    def move_character_logic(self, char_name, zone_name, use_coords, x, y, z, use_gm):
        conn = get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT zoneidnumber, safe_x, safe_y, safe_z 
                    FROM zone 
                    WHERE short_name = %s LIMIT 1
                """, (zone_name,))
                zone_row = cursor.fetchone()
                
                if not zone_row:
                    try:
                        zone_id = int(zone_name)
                        cursor.execute("SELECT safe_x, safe_y, safe_z FROM zone WHERE zoneidnumber = %s", (zone_id,))
                        zi = cursor.fetchone()
                        safe_x, safe_y, safe_z = (zi['safe_x'], zi['safe_y'], zi['safe_z']) if zi else (0.0, 0.0, 0.0)
                    except:
                        return False, f"Destination zone '{zone_name}' could not be resolved."
                else:
                    zone_id = zone_row['zoneidnumber']
                    safe_x, safe_y, safe_z = zone_row['safe_x'], zone_row['safe_y'], zone_row['safe_z']

                target_x = x if use_coords else safe_x
                target_y = y if use_coords else safe_y
                target_z = z if use_coords else safe_z

                if char_name.lower() == "all":
                    cursor.execute("SELECT name FROM character_data")
                    target_names = [row['name'] for row in cursor.fetchall()]
                else:
                    target_names = [char_name]

                online_chars = {}
                files = glob.glob(os.path.join(COMMANDS_DIR, "*.status.json"))
                for f in files:
                    try:
                        with open(f, 'r') as fh:
                            content = json.load(fh)
                            c_name = content.get("name")
                            if c_name and time.time() - content.get("timestamp", 0) < 5:
                                if "_" in c_name:
                                    c_name = c_name.split("_")[-1]
                                content["name"] = c_name.capitalize()
                                online_chars[c_name.capitalize()] = content
                    except:
                        pass

                moved_online = []
                moved_offline = []
                failed = []

                gm_char = None
                if use_gm:
                    for oc_name in online_chars.keys():
                        cursor.execute("""
                            SELECT a.status FROM character_data cd 
                            JOIN account a ON cd.account_id = a.id 
                            WHERE cd.name = %s LIMIT 1
                        """, (oc_name,))
                        acc_status = cursor.fetchone()
                        if acc_status and acc_status['status'] == 255:
                            gm_char = oc_name
                            break

                for name in target_names:
                    name = name.capitalize()
                    
                    if name in online_chars:
                        if use_gm and gm_char:
                            gm_cmd = f"/lua exec mq.cmd('/say #movechar {name} {zone_name} {target_x} {target_y} {target_z}')"
                            self.write_cmd(gm_char, gm_cmd)
                            moved_online.append(f"{name} (via GM {gm_char})")
                        else:
                            self.write_cmd(name, f"/zone {zone_name}")
                            if use_coords:
                                self.write_cmd(name, f"/warp loc {target_y} {target_x} {target_z}")
                            moved_online.append(name)
                    else:
                        try:
                            cursor.execute("""
                                UPDATE character_data 
                                SET zone_id = %s, x = %s, y = %s, z = %s, zone_instance = 0 
                                WHERE name = %s
                            """, (zone_id, target_x, target_y, target_z, name))
                            
                            cursor.execute("""
                                UPDATE character_bind 
                                SET zone_id = %s, x = %s, y = %s, z = %s 
                                WHERE id = (SELECT id FROM character_data WHERE name = %s)
                            """, (zone_id, target_x, target_y, target_z, name))
                            
                            conn.commit()
                            moved_offline.append(name)
                        except Exception as e:
                            print(f"Error moving {name} offline:", e)
                            failed.append(name)

                summary = []
                if moved_offline:
                    summary.append(f"Moved offline (DB update): {', '.join(moved_offline)}")
                if moved_online:
                    summary.append(f"Queued online commands: {', '.join(moved_online)}")
                if failed:
                    summary.append(f"Failed: {', '.join(failed)}")

                return True, " | ".join(summary)
        finally:
            conn.close()
            
    def write_cmd(self, char, cmd):
        write_cmd(char, cmd)

if __name__ == "__main__":
    start_eqbcs()
    EQBC_CLIENT.start()
    if not os.path.exists(COMMANDS_DIR):
        os.makedirs(COMMANDS_DIR)
    try:
        import state_monitor
        # Pass the targeted native write_cmd instead of the global broadcaster
        state_monitor.start_monitor(COMMANDS_DIR, write_cmd)
    except Exception as e:
        print(f"Error starting state monitor: {e}")
        
    def ensure_wineq_running():
        try:
            output = subprocess.check_output('tasklist', shell=True).decode('utf-8', errors='ignore')
            if 'WinEQ2.exe' not in output:
                print("WinEQ2 is not running. Attempting to start it...")
                wineq_path = os.path.join(BASE_DIR, "WinEQ2", "WinEQ2.exe")
                if os.path.exists(wineq_path):
                    subprocess.Popen([wineq_path], cwd=os.path.dirname(wineq_path), shell=False)
                    print("WinEQ2 started. Waiting 5 seconds for initialization...")
                    time.sleep(5)
                else:
                    print(f"Could not find WinEQ2.exe at {wineq_path}")
            else:
                print("WinEQ2 is already running.")
        except Exception as e:
            print(f"Error checking/starting WinEQ2: {e}")
            
    ensure_mq_running()
    # ensure_wineq_running()
        
    # Load configuration from config.json at startup to overwrite default connection_config
    for cfg_path in ["config.json", os.path.join(os.path.dirname(os.path.abspath(__file__)), "config.json")]:
        if os.path.exists(cfg_path):
            try:
                with open(cfg_path, 'r') as f:
                    cfg = json.load(f)
                    for k in ['host', 'port', 'user', 'password', 'database']:
                        if k in cfg:
                            if k == 'port':
                                connection_config[k] = int(cfg[k])
                            else:
                                connection_config[k] = str(cfg[k])
                    print("Startup: Loaded database settings from", cfg_path)
                    break
            except Exception as e:
                print("Error loading config on startup:", e)
    
    class ReusableHTTPServer(HTTPServer):
        allow_reuse_address = True
        
    
    _server_instance = ReusableHTTPServer(('0.0.0.0', 8099), RequestHandler)
    print("Starting Remote Console on http://localhost:8099 ...")
    
    # Start the watchdog to automatically restart crashed characters
    threading.Thread(target=watchdog_thread, daemon=True).start()
    
    try:
        _server_instance.serve_forever()
    except KeyboardInterrupt:
        pass
    _server_instance.server_close()
