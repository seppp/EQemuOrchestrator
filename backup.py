import os
import zipfile
import subprocess
import datetime

def backup():
    date_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_sql = f"peq_backup_{date_str}.sql"
    zip_name = f"eqemu_backup_{date_str}.zip"
    
    print("Dumping database...")
    # Dump DB using mysqldump
    try:
        subprocess.run(
            [r"C:\Program Files\MariaDB 12.3\bin\mysqldump.exe", "--skip-ssl", "-h", "192.168.178.163", "-P", "3306", "-u", "eqemu", "-pI8dGa8W7wdEVApPgR6L5lYUe8ig7FHD", "peq"],
            stdout=open(backup_sql, 'w', encoding='utf-8'),
            stderr=subprocess.PIPE,
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"mysqldump failed: {e.stderr.decode('utf-8', errors='ignore')}")
        return
        
    print(f"Creating zip {zip_name}...")
    
    # Paths to include
    paths_to_zip = [
        (backup_sql, backup_sql),
        ("config.json", "config.json"),
        (r"MacroQuestRof2\config", "config"),
        (r"antigravity", "antigravity")
    ]
    
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
        for src, dest in paths_to_zip:
            if os.path.isfile(src):
                zf.write(src, dest)
            elif os.path.isdir(src):
                for root, _, files in os.walk(src):
                    for file in files:
                        file_path = os.path.join(root, file)
                        # Relative path in zip
                        rel_path = os.path.relpath(file_path, src)
                        zip_dest = os.path.join(dest, rel_path)
                        try:
                            zf.write(file_path, zip_dest)
                        except Exception as e:
                            print(f"Skipping {file_path} due to error: {e}")
                            
    print("Cleaning up...")
    if os.path.exists(backup_sql):
        os.remove(backup_sql)
        
    print(f"Done! Backup created successfully at {zip_name}")

if __name__ == "__main__":
    backup()
