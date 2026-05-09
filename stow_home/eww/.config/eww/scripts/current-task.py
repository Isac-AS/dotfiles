#!/usr/bin/env python3
import json
import sys
import subprocess
from datetime import datetime

def get_eww_var(var_name):
    """Get variable from eww daemon."""
    try:
        result = subprocess.run(
            ["/home/isac/repos/eww/eww/target/release/eww", "get", var_name],
            capture_output = True,
            text = True,
            timeout = 2)
        return result.stdout.strip()
    except:
        return "{}" if var_name == "current-routine" else "00:00"

def get_current_task(routine_json_str, current_time_str):
    try:
        routine = json.loads(routine_json_str)
    except:
        print(json.dumps({"action": "Error: something went wrong parsing routine."}))
        return

    time_table = routine.get("table", [])
    if not time_table:
        print(json.dumps({"action": "Error: no tasks found."}))
        return

    try:
        now = datetime.strptime(current_time_str, "%H:%M")
        now_minutes = normalize_to_minutes(now)
    except:
        now_minutes = 0

    best_task = None
    best_diff = float('inf')
    for row in time_table:
        try:
            start = datetime.strptime(row["Start"], "%H:%M")
            end = datetime.strptime(row["End"], "%H:%M")
            normalized_start = normalize_to_minutes(start)
            normallized_end = normalize_to_minutes(end)

            if normalized_start <= now_minutes <= normallized_end:
                print(json.dumps(row))
                return

            diff = abs(now_minutes - normalized_start)
            if diff < best_diff:
                best_diff = diff
                best_task = row
        except:
            continue
    print(best_task)

def normalize_to_minutes(time):
    return time.hour * 60 + time.minute

if __name__ == "__main__":
    routine_json = get_eww_var("current-routine")
    current_time = get_eww_var("current-time")
    get_current_task(routine_json, current_time)
