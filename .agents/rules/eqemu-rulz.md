---
trigger: always_on
---

# Agent Instructions

- Do not run verifications automatically.
- Always ask the user first if they want to perform verifications manually, and let them decide between automated or manual verification.

## Project Context & Architecture

### 1. Databases
- **Remote MariaDB**: Main server database is `peq` on host `192.168.178.163`. Connection settings are in [config.json](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/config.json).
- **Local SQLite Cache**: [peq_local.db](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/peq_local.db) cache is synchronized using [db_sync.py](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/db_sync.py) (primarily legacy but kept for syncing reference).
- **Project Schema Files**:
  - MySQL/MariaDB schema dump: [schema.sql](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/schema.sql)
  - Detailed schema documentation: [db_schema.md](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/db_schema.md)

### 2. AutoLogin & Account Architecture
- **Login Server Accounts**: Stored in the `login_accounts` table. Default password is `"a"`, stored using scrypt hashing (e.g. `$7$C6....`).
- **World Server Account Mapping**: Active characters in `character_data` must map to `local` accounts in the `account` table (`ls_id = 'local'` and `lsaccount_id = <login_server_id>`). Mismatches will cause characters to not show up on the select screen.
- **MacroQuest AutoLogin**: Group, profile, and character structures are synchronized from/to MQ's `login.db` (path: `c:\Users\sigha\OneDrive\Documents\eqemus\MacroQuestRof2\config\login.db`).

### 3. Key Source Files
- **Orchestrator Backend Server**: [orchestrator.py](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/orchestrator.py) (runs on port `8099`, houses all admin and group launcher web interface).
- **Character Creator Backend**: [db_char_creator.py](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/db_char_creator.py).
- **Database CLI Admin**: [db_admin.py](file:///c:/Users/sigha/OneDrive/Documents/eqemus/antigravity/db_admin.py).

### 4. Client IPC / Broadcasting & EQBC vs. DanNet
- **DanNet (In-Game P2P)**: MQ2DanNet is used internally by bots and Lua scripts (like RGMercs) for peer-to-peer communication and sharing memory/states. It is excellent for in-game macros but difficult to interface with from outside the game.
- **EQBC (External Bridge)**: The user explicitly prefers **EQBC** for external orchestration. Because EQBC relies on a standalone TCP server (`EQBCS.exe`), the Python Orchestrator can natively connect to it via socket (`EQBCClient`). This allows the web UI to instantly inject commands (`bcaa //command`, `bct //command`) directly into the game clients without needing clunky file-polling workarounds. **Always use EQBC for external-to-game communication.**
- **Legacy Relay**: A legacy `antigravity.lua` polling script exists as a fallback, but the direct EQBC socket connection is the primary and preferred method for the Orchestrator to control bots.

### 5. Automation & Combat Scripts
- **RGMercs**: We use RGMercs (`rgmercs.lua`) for combat and casting automation instead of the legacy `box_assist.lua`. All bot combat and casting behaviors should be controlled via `/rglua` commands (e.g. `/rglua pause`, `/rglua resume`, `/rglua buff`) or `/lua run rgmercs`. `box_assist.lua` has been completely deprecated.

### 6. MacroQuest Philosophy
- Use of existing MacroQuest plugins (e.g., MQ2DanNet, MQ2AutoLogin, MQ2Nav, MQ2Melee) is preferable to reinventing the wheel wherever possible. Always check if a plugin natively supports the required functionality before writing custom Lua scripts or Python orchestration logic.

### 7. EQEmu GM Commands via MQ/EQBC
- When sending GM commands (e.g., `#summon`) to MacroQuest via EQBC or Antigravity, **prefix them with `/say`** (e.g., `/say #summon`). The user explicitly prefers this method because sending them directly as `/#summon` can cause issues with how the EQ client intercepts commands versus how MQ handles them.

### 8. EverQuest Mechanics & RGMercs
- **Main Assist**: RGMercs absolutely requires a Main Assist (MA) to function. Without an MA, bots will remain idle.
- **Roles and AAs**: The Group MA role can be assigned natively without AAs (`/grouproles set Name 2`). The native Raid MA role requires the "Delegate Main Assist" Raid Leadership AA (costs 3 points, accessed via `L` window, requires Leadership Exp to be enabled).
- **RGMercs Fallback**: If Leadership AAs are missing in a raid, manually set the assist target via command: `/rglua mainassist [CharacterName]`.
- **Granting Leadership AAs**: Leadership AAs are not stored in the regular AA tables. They are stored in the `character_leadership_abilities` table (slots 1-15).
