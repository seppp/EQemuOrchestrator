import subprocess, time
print('Starting wineq2')
subprocess.Popen([r"C:\Users\sigha\OneDrive\Documents\eqemus\WinEQ2\WinEQ2.exe", "/plugin:WinEQ2-EQ.dll", "TestProfile"])
time.sleep(6)
out = subprocess.check_output('wmic process where "name=''eqgame.exe''" get commandline', shell=True).decode()
print(out)
subprocess.call('taskkill /f /im eqgame.exe', shell=True)
