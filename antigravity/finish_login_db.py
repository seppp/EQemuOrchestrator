import sys
import os

sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from db_char_creator import add_to_mq_login

retry_chars = [
    {"name": "AebardA", "group": "AE_Cohort_G1"},
    {"name": "AewizA", "group": "AE_Cohort_G2"},
    {"name": "AewizB", "group": "AE_Cohort_G2"},
    {"name": "AewizC", "group": "AE_Cohort_G2"},
    {"name": "AewizD", "group": "AE_Cohort_G2"},
    {"name": "Aemage", "group": "AE_Cohort_G2"},
    {"name": "AebardB", "group": "AE_Cohort_G2"},
    {"name": "AeencD", "group": "AE_Cohort_G3"},
    {"name": "AeclericB", "group": "AE_Cohort_G3"},
    {"name": "Aedruid", "group": "AE_Cohort_G3"},
    {"name": "Aeshaman", "group": "AE_Cohort_G3"},
    {"name": "AebardC", "group": "AE_Cohort_G3"},
    {"name": "Aenecro", "group": "AE_Cohort_G3"}
]

for char in retry_chars:
    try:
        add_to_mq_login(char['name'], char['group'])
    except Exception as e:
        print(f"Error {char['name']}: {e}")
print("Done.")
