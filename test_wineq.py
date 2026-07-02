import psutil
import time
import subprocess
print('Waiting for eqgame.exe...')
for _ in range(20):
    for p in psutil.process_iter(['name', 'cmdline']):
        if p.info['name'] and 'eqgame.exe' in p.info['name'].lower():
            print(f'Found eqgame.exe: {p.info['cmdline']}')
            p.kill()
            exit(0)
    time.sleep(1)
print('Not found')
