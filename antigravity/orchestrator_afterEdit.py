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

def get_native_launch_cmd(char_name, eq_path, args, server):
    cmd_str = f'start "" "{eq_path}" patchme'
    if char_name and char_name.lower() != 'mobsterer':
        cmd_str += " nosound"
    if args:
        cmd_str += f" {args}"
    if char_name:
        srv = server if server else "dodl"
        cmd_str += f" /login:{srv}:{char_name}"
        
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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
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

    <script>
        let chars = {};
        
        function switchMainTab(tabId) {
            document.querySelectorAll('.main-tab-content').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.tab-bar > .tab-btn').forEach(b => b.classList.remove('active'));
            
            document.getElementById(tabId).classList.add('active');
            
            const btnMap = {
                'tab-char-admin': 0,
                'tab-bot-manager': 1,
                'tab-macros-configs': 2
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
                await sendCommand(`/say #summon ${char}`);
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
        async function gmGoto() {
            const char = await showPrompt("Select character for Mobsterer to TP to:", true);
            if(char) {
                const oldTarget = document.getElementById('target-char').value;
                document.getElementById('target-char').value = 'Mobsterer';
                await sendCommand(`/say #goto ${char}`);
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
                    await sendCommand(`/say #castspell 994`);
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
                    const r = await fetch('/status');
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

        let currentCrashed = [];
        function checkCrashes() {
            fetch('/crashed_clients', {method: 'POST'})
                .then(r => r.json())
                .then(d => {
                    if(d.crashed && d.crashed.length > 0) {
                        currentCrashed = d.crashed;
                        document.getElementById("crash-text").innerText = d.crashed.length + " Characters Crashed (" + d.crashed.join(", ") + ")";
                        document.getElementById("crash-banner").style.display = "block";
                    } else {
                        document.getElementById("crash-banner").style.display = "none";
                    }
                });
        }
        function relaunchCrashed() {
            fetch('/relaunch_crashed', {
                method: 'POST',
                body: JSON.stringify({characters: currentCrashed})
            }).then(() => checkCrashes());
        }
        function dismissCrash() {
            fetch('/dismiss_crash', {
                method: 'POST',
                body: JSON.stringify({characters: currentCrashed})
            }).then(() => checkCrashes());
        }
        setInterval(checkCrashes, 3000);
        
        fetchLaunchableCharacters();
        fetchGroupManagerDetails();
        setInterval(fetchStatus, 1000);
        fetchStatus();
    </script>
</body>
</html>
"""

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
            self.sock.close()
            
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
                self.sock.close()
            if self.running:
                time.sleep(5)
                
    def send_command(self, cmd):
        if self.sock:
            try:
                self.sock.sendall(f"{cmd}\n".encode('utf-8'))
            except:
                pass

EQBC_CLIENT = EQBCClient()

def write_cmd_global(char, cmd):
    """Broadcasts a command to all characters via EQBCS."""
    if not cmd.startswith('/'):
        cmd = '/' + cmd
    EQBC_CLIENT.send_command(f"bca {cmd}")

def write_cmd(char, cmd):
    """Sends a command to a specific character via EQBCS."""
    if not cmd.startswith('/'):
        cmd = '/' + cmd
    EQBC_CLIENT.send_command(f"bct {char} {cmd}")

def start_eqbcs():
    """Starts the EQBCS server natively."""
    eqbcs_path = r"C:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\EQBCS.exe"
    if os.path.exists(eqbcs_path):
        try:
            import psutil
            for p in psutil.process_iter(['name']):
                if p.info['name'] and p.info['name'].lower() == 'eqbcs.exe':
                    print("EQBCS is already running.")
                    return
            print("Starting EQBCS.exe...")
            subprocess.Popen([eqbcs_path], cwd=os.path.dirname(eqbcs_path))
        except Exception as e:
            print(f"Failed to start EQBCS: {e}")

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
    Trains all skills to their maximum cap for the character's class and level
    using skill_caps. Upserts existing values so no skill is lowered below current.
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

            return True, f"Trained {len(batch)} skills to cap for {char_name}."
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


if __name__ == "__main__":
    if not os.path.exists(COMMANDS_DIR):
        os.makedirs(COMMANDS_DIR)
        
    EQBC_CLIENT.start()
    start_eqbcs()
        
    try:
        import state_monitor
        state_monitor.start_monitor(COMMANDS_DIR, write_cmd_global)
    except Exception as e:
        print(f"Error starting state monitor: {e}")
        
    def ensure_mq_running():
        try:
            output = subprocess.check_output('tasklist', shell=True).decode('utf-8', errors='ignore')
            if 'MacroQuest.exe' not in output:
                print("MacroQuest is not running. Attempting to start it...")
                mq_path = os.path.join(BASE_DIR, "MacroQuestRof2", "MacroQuest.exe")
                if os.path.exists(mq_path):
                    # Start without blocking
                    subprocess.Popen([mq_path], cwd=os.path.dirname(mq_path))
                    print("MacroQuest started.")
                else:
                    print(f"Could not find MacroQuest.exe at {mq_path}")
            else:
                print("MacroQuest is already running.")
        except Exception as e:
            print(f"Error checking/starting MacroQuest: {e}")
            
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
    ensure_wineq_running()
        
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
        
    start_eqbcs()
    EQBC_CLIENT.start()
    
    _server_instance = ReusableHTTPServer(('0.0.0.0', 8099), RequestHandler)
    print("Starting Remote Console on http://localhost:8099 ...")
    try:
        _server_instance.serve_forever()
    except KeyboardInterrupt:
        pass
    _server_instance.server_close()
