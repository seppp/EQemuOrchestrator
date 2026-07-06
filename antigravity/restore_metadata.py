import os
import re

d = '../MacroQuestRof2/lua/rgmercs/class_configs/Live'
for f in os.listdir(d):
    if f.endswith('.lua'):
        path = os.path.join(d, f)
        with open(path, 'r') as file:
            content = file.read()
        
        content = re.sub(r'(_version\s*=\s*").*?(")', r'\g<1>DODL CUSTOM\2', content)
        content = re.sub(r'(_author\s*=\s*").*?(")', r'\g<1>eldudero\2', content)
        
        with open(path, 'w') as file:
            file.write(content)
