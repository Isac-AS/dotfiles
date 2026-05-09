#!/usr/bin/env python3
import json
import sys
from datetime import datetime

def get_routine():
    json_path = "/home/isac/.config/eww/routines.json"
    
    try:
        with open(json_path) as f:
            routines = json.load(f)
    except Exception:
        print('Something went wrong')
        return

    today = datetime.now().isoweekday()   # 1 = Monday, 7 = Sunday

    # Find first routine that matches today's day
    for routine in routines:
        default_days = routine.get("DEFAULT-DAY-OF-WEEK", [])
        days = json.loads(default_days) # Convert string "[1, 2]" to array [1, 2]
        if default_days and today in days:
            print(json.dumps(routine))
            return

    # Fallback: return first routine
    print(json.dumps(routines[0] if routines else {}))

if __name__ == "__main__":
    get_routine()
