import json
import csv
import re

# Läser Linux-processer från JSON-filen som skapats av linux_check.sh
with open("../data/linux_processes.json", "r", encoding="utf-8") as f:
    linux_data = json.load(f)

linux_processes = [p["name"] for p in linux_data.get("processes", [])]

# Läser Windows-tjänster från CSV-filen som skapats av windows_check.ps1
windows_services = []
with open("../data/windows_services.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        windows_services.append(row["Name"])

# Läser samlade anomalier från tidigare script
with open("../data/anomalies.log", "r", encoding="utf-8") as f:
    anomalies = [line.strip() for line in f]

# Läser auth.log och räknar antal misslyckade inloggningar per IP
ip_fail_count = {}
with open("../data/auth.log", "r", encoding="utf-8") as f:
    for line in f:
        if "failed" in line.lower():
            match = re.search(r"(\d{1,3}(?:\.\d{1,3}){3})", line)
            if match:
                ip = match.group(1)
                ip_fail_count[ip] = ip_fail_count.get(ip, 0) + 1

# Definierar kända riskindikatorer
risk_processes = ["nc", "netcat", "hydra", "john"]
risk_services = ["RemoteRegistry", "Telnet", "Spooler"]

incidents = []

# Identifierar riskabla Linux-processer
for proc in linux_processes:
    if proc in risk_processes:
        incidents.append(f"CRITICAL: Riskprocess upptäckt på Linux – {proc}")

# Identifierar riskabla Windows-tjänster
for svc in windows_services:
    if svc in risk_services:
        incidents.append(f"HIGH: Riskabel Windows-tjänst upptäckt – {svc}")

# Identifierar brute-force och misstänkta IP-adresser
for ip, count in ip_fail_count.items():
    if count >= 5:
        incidents.append(f"CRITICAL: Brute-force-indikator från IP {ip} ({count} misslyckade försök)")
    elif count >= 1:
        incidents.append(f"MEDIUM: Misstänkta inloggningsförsök från IP {ip} ({count} försök)")

# Lägger till anomalier från tidigare kontroller
for anomaly in anomalies:
    incidents.append(f"INFO: {anomaly}")

# Skriver notifieringar till alerts.json
with open("../data/alerts.json", "w", encoding="utf-8") as f:
    json.dump({"alerts": incidents}, f, indent=4)

# Skriver slutlig incidentrapport
with open("../data/incident_report.txt", "w", encoding="utf-8") as f:
    for inc in incidents:
        f.write(inc + "\n")

# Visar sammanfattning i terminalen
print("=== INCIDENT SUMMARY ===")
for inc in incidents:
    print("-", inc)

print("\nIncidentrapport skapad: ../data/incident_report.txt")
print("Notifieringar skapade: ../data/alerts.json")
