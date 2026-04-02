#!/bin/bash

# Automated Backup Cron Configuration
# Sets up daily automated backups for Osusu

echo "⏰ Setting up automated backups via cron..."
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-database.sh"
DB_TYPE="${1:-sqlite}"
CRON_TIME="${2:-2 0 * * *}"  # Default: 2 AM daily

echo "Script path: $BACKUP_SCRIPT"
echo "Database type: $DB_TYPE"
echo "Cron schedule: $CRON_TIME (use crontab format)"
echo ""

# Create cron job
CRON_JOB="$CRON_TIME cd $SCRIPT_DIR && bash backup-database.sh $DB_TYPE daily >> /var/log/osusu-backup.log 2>&1"

echo "📝 Cron job to add:"
echo "$CRON_JOB"
echo ""

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    CRON_FILE="/Library/LaunchDaemons/com.osusu.backup.plist"
    echo "📱 macOS detected - using LaunchDaemon"
    echo "To install:"
    echo "  sudo cp $BACKUP_SCRIPT /usr/local/bin/"
    echo "  sudo chmod +x /usr/local/bin/backup-database.sh"
else
    CRON_FILE="/etc/cron.d/osusu-backup"
    echo "🐧 Linux detected - using cron"
fi

echo ""
echo "To set up automatically:"
echo "  (crontab -l; echo \"$CRON_JOB\") | crontab -"
echo ""
echo "To verify:"
echo "  crontab -l | grep osusu"
echo ""
echo "To remove:"
echo "  crontab -e  # and delete the osusu backup line"
echo ""

# Log location hints
echo "📋 Log locations:"
echo "  Linux: /var/log/osusu-backup.log"
echo "  macOS: /var/log/osusu-backup.log"
echo "  Custom: Set LOG_FILE environment variable"
