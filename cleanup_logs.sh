#!/bin/bash

LOG_DIR="/home/sebas/linux-monitor/logs"

# Borra logs con más de 7 días
find "$LOG_DIR" -type f -name "report_*.txt" -mtime +7 -delete

