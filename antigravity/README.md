# EQEmulator Server Admin Utilities & Orchestrator (Antigravity)

Welcome to the EQEmulator Server Admin Utilities workspace. This directory contains Python-based tools, graphical user interfaces, and a web-based Orchestrator to manage a local or remote EQEmulator (EverQuest Emulator) server database (PEQ), and control client sessions dynamically.

## Documentation Index

The following documentation guides are available:
- **[Database Schema Documentation (db_schema.md)](db_schema.md)**: Full table definitions, columns, data types, primary keys, nullability, and row counts of the key database tables used in this project.
- **[Bot Stance Casting Rules (bot_stance_casting_rules.md)](bot_stance_casting_rules.md)**: Detailed mapping of how bot spell casting percentages, class capability matrices, and stances are evaluated by the emulator.
- **[Bot Commands Reference (bot_commands.md)](bot_commands.md)**: Standard reference guide containing all in-game bot commands.

---

## The Orchestrator

- **[orchestrator.py](orchestrator.py)**: A comprehensive Python HTTP Server and Web UI dashboard. The Orchestrator allows you to launch characters or pre-defined groups seamlessly from your browser, while monitoring real-time states (HP, Mana, Endurance).
  - **WinEQ2 Integration**: The Orchestrator intercepts launch commands and dynamically generates WinEQ2 configuration profiles (WinEQ-EQ.ini). It assigns unique copies of eqclient.ini to each session, completely eliminating file-lock contention crashes during multi-boxing.
  - **Crash Detection**: Actively monitors long-running client states and surfaces "Crashed" warnings in the UI if a client process fails to send heartbeats, offering a 1-click relaunch mechanism. (Graceful exits can be dismissed in the UI or flagged via the /offline_session route).
  - **Dynamic Lua Scripting**: The server dynamically injects highly localized orch_poll.lua files into MacroQuest, providing real-time game state relays without manual configuration.

- **[state_monitor.py](state_monitor.py)**: A daemon background thread tied to the Orchestrator. It monitors the status.json heartbeats and performs background logic:
  - **Auto-Grouping & Raid Setup**: Automatically issues /invite commands and executes /invite accepts among group leaders and raid members defined by your profile groups.

---

## Core Application & Utility Scripts

- **[eq_gui_admin.py](eq_gui_admin.py)**: The main desktop GUI application built using customtkinter (tkinter wrapper). It allows admins to search and edit characters/bots, adjust levels, edit inventory/equipment, and create custom hotkey macros.
- **[db_sync.py](db_sync.py)**: Syncs key MySQL database tables from the remote MariaDB server to a local SQLite database (peq_local.db). The GUI uses the local SQLite cache for instantaneous searching.
- **[db_admin.py](db_admin.py)**: Command-line interface tool for database administration (list characters/bots, search items, give platinum, spawn items, adjust levels, and execute custom SQL).
- **[db_bots.py](db_bots.py)**: Utility to verify bot table presence and display quick counts.
- **[check_sqlite.py](check_sqlite.py)**: Mini-check to verify the integrity and tables of the local SQLite cache database.
- **[write_macro.py](write_macro.py)**: script to write macro files based on selected configuration.

---

## Configuration

All database utility scripts look for database connection settings in **[config.json](../config.json)**.
Example format:
\\\json
{
    "host": "192.168.178.163",
    "port": 3306,
    "user": "eqemu",
    "password": "YOUR_PASSWORD_HERE",
    "database": "peq"
}
\\\
If \config.json\ is missing or incomplete, the scripts fall back to their built-in defaults.
