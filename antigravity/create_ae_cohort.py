import sys
import os

sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from db_char_creator import create_character, add_to_mq_login

characters = [
    {"name": "Aesk", "class_id": 5, "group": "AE_Cohort_G1"},
    {"name": "AeclericA", "class_id": 2, "group": "AE_Cohort_G1"},
    {"name": "AeencA", "class_id": 14, "group": "AE_Cohort_G1"},
    {"name": "AeencB", "class_id": 14, "group": "AE_Cohort_G1"},
    {"name": "AeencC", "class_id": 14, "group": "AE_Cohort_G1"},
    {"name": "AebardA", "class_id": 8, "group": "AE_Cohort_G1"},

    {"name": "AewizA", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "AewizB", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "AewizC", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "AewizD", "class_id": 12, "group": "AE_Cohort_G2"},
    {"name": "Aemage", "class_id": 13, "group": "AE_Cohort_G2"},
    {"name": "AebardB", "class_id": 8, "group": "AE_Cohort_G2"},

    {"name": "AeencD", "class_id": 14, "group": "AE_Cohort_G3"},
    {"name": "AeclericB", "class_id": 2, "group": "AE_Cohort_G3"},
    {"name": "Aedruid", "class_id": 6, "group": "AE_Cohort_G3"},
    {"name": "Aeshaman", "class_id": 10, "group": "AE_Cohort_G3"},
    {"name": "Aenecro", "class_id": 11, "group": "AE_Cohort_G3"},
    {"name": "AebardC", "class_id": 8, "group": "AE_Cohort_G3"},
]

for char in characters:
    try:
        race_id = 5 
        if char['class_id'] == 5: race_id = 9
        elif char['class_id'] == 8: race_id = 4
        elif char['class_id'] == 6: race_id = 4
        elif char['class_id'] == 10: race_id = 2
        elif char['class_id'] == 11: race_id = 9
        
        create_character(char['name'], race_id=race_id, class_id=char['class_id'], gender_id=0, deity_id=0)
        add_to_mq_login(char['name'], char['group'])
    except Exception as e:
        print(f"Error creating {char['name']}: {e}")
