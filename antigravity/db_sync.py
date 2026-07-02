import pymysql
import sqlite3
import sys
import os
import time

import json

# Remote MariaDB database configuration
remote_config = {
    'host': '192.168.178.163',
    'port': 3306,
    'user': 'eqemu',
    'password': 'I8dGa8W7wdEVApPgR6L5lYUe8ig7FHD',
    'database': 'peq',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

# Override from config.json if it exists
if os.path.exists('config.json'):
    try:
        with open('config.json', 'r') as f:
            cfg = json.load(f)
            for k in ['host', 'port', 'user', 'password', 'database']:
                if k in cfg:
                    if k == 'port':
                        remote_config[k] = int(cfg[k])
                    else:
                        remote_config[k] = cfg[k]
    except Exception as ex:
        print(f"Warning: Failed to load config.json: {ex}")

# Local SQLite file
SQLITE_DB = 'peq_local.db'

# Key tables to sync
TABLES_TO_SYNC = [
    'account',
    'character_data',
    'bot_data',
    'inventory',
    'bot_inventories',
    'items',
    'zone',
    'character_alternate_abilities',
    'character_currency'
]

import decimal
import datetime

def clean_val(val):
    """Convert types that SQLite doesn't natively support."""
    if isinstance(val, decimal.Decimal):
        return float(val)
    elif isinstance(val, (datetime.datetime, datetime.date)):
        return str(val)
    return val

def mysql_to_sqlite_type(mysql_type):
    """Translate MySQL column types to SQLite data types."""
    m_type = mysql_type.lower()
    if any(x in m_type for x in ['int', 'bit']):
        return 'INTEGER'
    elif any(x in m_type for x in ['char', 'text', 'varchar', 'enum', 'set']):
        return 'TEXT'
    elif any(x in m_type for x in ['float', 'double', 'decimal', 'real']):
        return 'REAL'
    elif 'blob' in m_type or 'binary' in m_type:
        return 'BLOB'
    return 'TEXT'

def sync_database():
    start_time = time.time()
    print("Connecting to remote MariaDB database at 192.168.178.163...")
    try:
        mysql_conn = pymysql.connect(**remote_config)
    except Exception as e:
        print(f"Failed to connect to remote database: {e}", file=sys.stderr)
        sys.exit(1)
        
    print(f"Connecting to local SQLite database at {SQLITE_DB}...")
    try:
        sqlite_conn = sqlite3.connect(SQLITE_DB)
        sqlite_cursor = sqlite_conn.cursor()
    except Exception as e:
        print(f"Failed to connect to local SQLite database: {e}", file=sys.stderr)
        mysql_conn.close()
        sys.exit(1)
        
    try:
        with mysql_conn.cursor() as mysql_cursor:
            # First, check which of our target tables actually exist in the remote DB
            mysql_cursor.execute("SHOW TABLES")
            existing_tables = {list(row.values())[0].lower() for row in mysql_cursor.fetchall()}
            
            tables_to_sync = [t for t in TABLES_TO_SYNC if t.lower() in existing_tables]
            print(f"Found {len(tables_to_sync)} tables of interest in remote DB: {', '.join(tables_to_sync)}")
            
            for table in tables_to_sync:
                print(f"\n--- Syncing Table: {table} ---")
                
                # Fetch schema from MySQL
                mysql_cursor.execute(f"DESCRIBE {table}")
                columns = mysql_cursor.fetchall()
                
                col_defs = []
                col_names = []
                pks = []
                for col in columns:
                    name = col['Field']
                    sql_type = mysql_to_sqlite_type(col['Type'])
                    col_names.append(name)
                    
                    if col['Key'] == 'PRI':
                        pks.append(f"`{name}`")
                        
                    col_defs.append(f"`{name}` {sql_type}")
                
                if pks:
                    col_defs.append(f"PRIMARY KEY ({', '.join(pks)})")
                
                # Drop existing table in SQLite
                sqlite_cursor.execute(f"DROP TABLE IF EXISTS `{table}`")
                
                # Create table in SQLite
                create_sql = f"CREATE TABLE `{table}` ({', '.join(col_defs)})"
                sqlite_cursor.execute(create_sql)
                
                # Fetch all rows from MySQL
                print(f"Fetching data from remote `{table}`...")
                mysql_cursor.execute(f"SELECT * FROM `{table}`")
                
                # Insert in batches into SQLite
                insert_placeholders = ", ".join(["?"] * len(col_names))
                insert_sql = f"INSERT OR REPLACE INTO `{table}` ({', '.join(f'`{c}`' for c in col_names)}) VALUES ({insert_placeholders})"
                
                rows_written = 0
                batch_size = 5000
                batch = []
                
                # Start transaction for speed
                sqlite_cursor.execute("BEGIN TRANSACTION")
                
                while True:
                    row = mysql_cursor.fetchone()
                    if row is None:
                        # Write remaining
                        if batch:
                            sqlite_cursor.executemany(insert_sql, batch)
                            rows_written += len(batch)
                        break
                    
                    # Convert dict row to ordered tuple based on col_names
                    val_tuple = tuple(clean_val(row[col]) for col in col_names)
                    batch.append(val_tuple)
                    
                    if len(batch) >= batch_size:
                        sqlite_cursor.executemany(insert_sql, batch)
                        rows_written += len(batch)
                        batch = []
                        print(f"  Written {rows_written} rows...")
                
                sqlite_conn.commit()
                print(f"Completed! Table `{table}` has {rows_written} rows in local SQLite.")
                
            # Create indexes on key search columns to make the GUI search instant
            print("\nCreating indexes...")
            sqlite_cursor.execute("CREATE INDEX IF NOT EXISTS idx_items_name ON items(Name)")
            sqlite_cursor.execute("CREATE INDEX IF NOT EXISTS idx_inventory_char ON inventory(character_id)")
            sqlite_cursor.execute("CREATE INDEX IF NOT EXISTS idx_bot_inv_bot ON bot_inventories(bot_id)")
            sqlite_conn.commit()
            print("Indexes created.")
            
    except Exception as e:
        print(f"An error occurred during synchronization: {e}", file=sys.stderr)
        sqlite_conn.rollback()
    finally:
        mysql_conn.close()
        sqlite_conn.close()
        print(f"\nDatabase sync completed in {time.time() - start_time:.2f} seconds.")

if __name__ == '__main__':
    sync_database()
