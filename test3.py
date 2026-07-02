import configparser
import os
wineq_ini = r'c:\Users\sigha\OneDrive\Documents\eqemus\WinEQ2\WinEQ-EQ.ini'
config = configparser.ConfigParser()
config.optionxform = str
config.read(wineq_ini)
profile_name = 'Bonko'
profile_key = f'Profile_{profile_name}'
if profile_key not in config:
    config[profile_key] = {}
config[profile_key]['Name'] = profile_name
config[profile_key]['EQPath'] = r'c:\Users\sigha\OneDrive\Documents\eqemus\everquest_rof2\everquest_rof2'
config[profile_key]['EQClientINI'] = f'.\eqclient_{profile_name.lower()}.ini'
config[profile_key]['Preset'] = '0'
config[profile_key]['Arguments'] = f'patchme /login:dodl:{profile_name}'
with open(wineq_ini, 'w') as configfile:
    config.write(configfile)
