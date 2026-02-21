# 🖥️ linux-monitor

A lightweight Bash-based system health monitor for Linux and WSL environments.
Tracks disk usage, triggers alerts when thresholds are exceeded, and automatically cleans up old logs.

---

## Project Structure

```
linux-monitor/
├── system_health.sh   # Main monitoring script
├── cleanup.sh         # Log rotation script
├── logs/              # Auto-generated reports
│   └── report_YYYY-MM-DD_HH-MM.txt
└── .disk_alert_state  # Persistent alert state (auto-generated)
```

---

## ⚙️ Configuration

Both scripts are fully portable. No hardcoded paths. All settings can be overridden via environment variables before running.

### system_health.sh

| Variable          | Default                    | Description                        |
|-------------------|----------------------------|------------------------------------|
| `MONITOR_DIR`     | Script's own directory     | Working directory                  |
| `DISK_TARGET`     | `/`                        | Partition to monitor               |
| `ALERT_THRESHOLD` | `80`                       | Usage % that triggers an alert     |
| `ALERT_SCRIPT`    | *(empty)*                  | Path to custom alert script (.ps1 or .sh) |

### cleanup.sh

| Variable          | Default                    | Description                        |
|-------------------|----------------------------|------------------------------------|
| `LOG_DIR`         | `$SCRIPT_DIR/logs`         | Directory containing log files     |
| `RETENTION_DAYS`  | `7`                        | Days before a log file is deleted  |

---

## Usage

### Run the health monitor

```bash
./system_health.sh
```

With custom settings:

```bash
DISK_TARGET=/home ALERT_THRESHOLD=90 ALERT_SCRIPT=/path/to/alert.sh ./system_health.sh
```

### Run log cleanup

```bash
./cleanup.sh
```

With custom settings:

```bash
LOG_DIR=/var/logs RETENTION_DAYS=14 ./cleanup.sh
```

---

## Alerts

The alert system is **state-aware** — it only triggers once when disk usage crosses the threshold, and resets when usage returns to normal. This prevents repeated notifications.

- **OK → ALERT**: fires when usage reaches `ALERT_THRESHOLD`
- **ALERT → OK**: logs recovery when usage drops back below the threshold

If running inside **WSL**, the alert script can be a PowerShell `.ps1` file. The script detects the WSL environment automatically and invokes `powershell.exe` accordingly.

---

## Automating with Cron

To run the monitor every 30 minutes and clean up logs daily:

```bash
crontab -e
```

```
*/30 * * * * /path/to/linux-monitor/system_health.sh
0 2  * * * /path/to/linux-monitor/cleanup.sh
```

---

## Sample Report

```
===== SYSTEM HEALTH REPORT =====
Date: Fri Feb 20 18:30:00 2026
Host: my-machine
Disk target: /

Disk Usage: 74%

Disk usage back to normal (74%)
```

---

## Requirements

- Bash 4+
- `df` with `--output` support (util-linux)
- `find`, `realpath` (standard on most Linux distros)
- PowerShell (only if using `.ps1` alert scripts on WSL)

---

