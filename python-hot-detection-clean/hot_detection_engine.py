import json
import csv
import re

# 1. Läs CSV (användare)
users = {}
with open("users.csv", "r", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        users[row["username"]] = {
            "status": row["status"],
            "fails": 0
        }

# 2. Läs JSON (händelser)
with open("events.json", "r", encoding="utf-8") as f:
    events = json.load(f)["events"]

for e in events:
    if e["event"] == "failed_login":
        user = e["user"]
        if user in users:
            users[user]["fails"] += 1

# 3. Läs textlogg (IP-analys)
ip_fail_count = {}
with open("auth.log", "r", encoding="utf-8") as f:
    for line in f:
        if re.search(r"failed", line, re.IGNORECASE):
            match = re.search(r"(\\d{1,3}(\\.\\d{1,3}){3})", line)
            if match:
                ip = match.group(1)
                ip_fail_count[ip] = ip_fail_count.get(ip, 0) + 1

# 4. Riskklassificering
def classify_user(info):
    if info["status"] == "disabled" and info["fails"] > 0:
        return "CRITICAL"
    if info["fails"] >= 3:
        return "HIGH RISK"
    if info["fails"] >= 1:
        return "MEDIUM RISK"
    return "LOW RISK"

def classify_ip(fails):
    if fails >= 5:
        return "BRUTE FORCE SUSPECT"
    if fails >= 1:
        return "SUSPICIOUS"
    return "LOW"

# 5. Rapport
with open("final_report.txt", "w", encoding="utf-8") as r:
    r.write("=== USER RISK REPORT ===\n")
    for user, info in users.items():
        r.write(f"{user}: {classify_user(info)} "
                f"(fails={info['fails']}, status={info['status']})\n")

    r.write("\n=== IP RISK REPORT ===\n")
    for ip, count in ip_fail_count.items():
        r.write(f"{ip}: {classify_ip(count)} (fails={count})\n")

print("Analys klar. Se final_report.txt.")