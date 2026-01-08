import json      # används för att läsa Linux-processer i JSON-format
import csv       # används för att läsa Windows-tjänster i CSV-format

# Läser in Linux-processer från tidigare Bash-script
with open("../data/linux_processes.json", "r", encoding="utf-8") as f:
    linux_data = json.load(f)["processes"]

# Skapar en lista med endast processnamn från Linux
linux_processes = [p["name"] for p in linux_data]

# Läser in Windows-tjänster från PowerShell-script
windows_services = []
with open("../data/windows_services.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        windows_services.append(row["Name"])

# Läser in alla rader från anomalies.log
with open("../data/anomalies.log", "r", encoding="utf-8") as f:
    anomalies = [line.strip() for line in f]

# Lista som kommer innehålla hela säkerhetsrapporten
report = []

# Definierar riskklassade Linux-processer
linux_risk_processes = ["nc", "netcat", "hydra"]

# Kontrollerar om riskprocesser finns på Linux
for proc in linux_processes:
    if proc in linux_risk_processes:
        report.append(f"CRITICAL: Linux riskprocess upptäckt – {proc}")

# Definierar riskklassade Windows-tjänster
risk_services = ["Telnet", "RemoteRegistry", "Spooler"]

# Kontrollerar om riskabla Windows-tjänster körs
for svc in windows_services:
    if svc in risk_services:
        report.append(f"WARNING: Riskabel Windows-tjänst – {svc}")

# Lägger till loggar från anomalies.log i rapporten
report.append("= ANOMALI-LOGG =")
for line in anomalies:
    report.append(line)

# Skriver slutlig säkerhetsrapport till fil
with open("../data/final_security_report.txt", "w", encoding="utf-8") as f:
    for line in report:
        f.write(line + "\n")

# Bekräftar i terminalen att rapporten skapats
print("Slutrapport skapad: final_security_report.txt")
