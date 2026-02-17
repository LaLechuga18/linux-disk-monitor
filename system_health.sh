#!/bin/bash
cd /home/sebas/linux-monitor
mkdir -p logs

OUTPUT="logs/report_$(date +%F_%H-%M).txt"
STATE_FILE=".disk_alert_state"

USAGE=$(df /mnt/c --output=pcent | tail -1 | tr -dc '0-9')

# Si no existe el estado, asumimos OK
if [ ! -f "$STATE_FILE" ]; then
    echo "OK" > "$STATE_FILE"
fi

PREV_STATE=$(cat "$STATE_FILE")

{
echo "===== SYSTEM HEALTH REPORT ====="
echo "Date: $(date)"
echo ""
echo "Disk Usage: $USAGE%"
echo ""
} >> "$OUTPUT"

# ---- LÓGICA DE ALERTA ----

# Caso 1: entra en estado crítico
if [ "$USAGE" -ge 80 ] && [ "$PREV_STATE" = "OK" ]; then
    echo "WARNING: Disk usage is above 80% ($USAGE%)" >> "$OUTPUT"

    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass \
    -Command "& 'C:\\Users\\Sebas\\alerta.ps1'"

    echo "ALERT" > "$STATE_FILE"
fi

# Caso 2: vuelve a estado normal
if [ "$USAGE" -lt 80 ] && [ "$PREV_STATE" = "ALERT" ]; then
    echo "Disk usage back to normal ($USAGE%)" >> "$OUTPUT"
    echo "OK" > "$STATE_FILE"
fi

