#!/bin/bash

# Database Backup Script
# Supports SQLite and PostgreSQL
# Usage: ./scripts/backup-database.sh [sqlite|postgres] [daily|manual]

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_TYPE="${1:-sqlite}"
BACKUP_TYPE="${2:-manual}"
RETENTION_DAYS=30

mkdir -p "$BACKUP_DIR"

echo "🔄 Starting $DB_TYPE backup..."
echo "Backup type: $BACKUP_TYPE"
echo "Timestamp: $TIMESTAMP"
echo ""

# ==================== SQLite Backup ====================
backup_sqlite() {
    DB_PATH="${DB_PATH:-./src/db.sqlite}"
    BACKUP_FILE="$BACKUP_DIR/osusu-sqlite-$TIMESTAMP.db"
    
    if [ ! -f "$DB_PATH" ]; then
        echo "❌ Database file not found: $DB_PATH"
        exit 1
    fi
    
    echo "📝 Backing up SQLite database..."
    cp "$DB_PATH" "$BACKUP_FILE"
    echo "✅ Database backed up to: $BACKUP_FILE"
    
    # Verify backup
    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "📊 Backup size: $SIZE"
        
        # Compress backup
        gzip "$BACKUP_FILE"
        echo "📦 Compressed to: $BACKUP_FILE.gz"
    else
        echo "❌ Backup verification failed"
        exit 1
    fi
}

# ==================== PostgreSQL Backup ====================
backup_postgres() {
    DB_HOST="${DB_HOST:-localhost}"
    DB_PORT="${DB_PORT:-5432}"
    DB_NAME="${DB_NAME:-osusu}"
    DB_USER="${DB_USER:-postgres}"
    BACKUP_FILE="$BACKUP_DIR/osusu-postgres-$TIMESTAMP.sql"
    
    echo "📝 Backing up PostgreSQL database..."
    
    if ! command -v pg_dump &> /dev/null; then
        echo "❌ pg_dump not found. Install PostgreSQL client tools."
        exit 1
    fi
    
    PGPASSWORD="$DB_PASSWORD" pg_dump \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        --create \
        --verbose \
        > "$BACKUP_FILE"
    
    echo "✅ Database backed up to: $BACKUP_FILE"
    
    if [ -f "$BACKUP_FILE" ]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "📊 Backup size: $SIZE"
        
        # Compress backup
        gzip "$BACKUP_FILE"
        echo "📦 Compressed to: $BACKUP_FILE.gz"
    else
        echo "❌ Backup verification failed"
        exit 1
    fi
}

# ==================== S3 Upload ====================
upload_to_s3() {
    BACKUP_FILE="$1"
    AWS_BUCKET="${AWS_S3_BUCKET:-osusu-backups}"
    AWS_REGION="${AWS_REGION:-us-east-1}"
    
    if ! command -v aws &> /dev/null; then
        echo "ℹ️  AWS CLI not installed. Backup stored locally only."
        return
    fi
    
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "ℹ️  AWS credentials not configured. Backup stored locally only."
        return
    fi
    
    echo "☁️  Uploading backup to S3..."
    aws s3 cp "$BACKUP_FILE.gz" "s3://$AWS_BUCKET/$(basename $BACKUP_FILE).gz" \
        --region "$AWS_REGION"
    
    echo "✅ Backup uploaded to: s3://$AWS_BUCKET/"
}

# ==================== Cleanup Old Backups ====================
cleanup_old_backups() {
    echo "🧹 Cleaning up backups older than $RETENTION_DAYS days..."
    
    find "$BACKUP_DIR" -name "osusu-*" -type f -mtime +$RETENTION_DAYS -delete
    
    echo "✅ Cleanup complete"
}

# ==================== Main ====================
case "$DB_TYPE" in
    sqlite)
        backup_sqlite
        ;;
    postgres)
        backup_postgres
        ;;
    *)
        echo "❌ Unknown database type: $DB_TYPE"
        echo "Usage: backup-database.sh [sqlite|postgres] [daily|manual]"
        exit 1
        ;;
esac

# Optional: Upload to S3
if [ "$BACKUP_TYPE" = "daily" ]; then
    upload_to_s3 "$(ls -t $BACKUP_DIR/osusu-* | head -1)"
fi

# Cleanup old backups
if [ "$BACKUP_TYPE" = "daily" ]; then
    cleanup_old_backups
fi

echo ""
echo "✨ Backup process complete!"
echo ""
echo "Backups stored in: $BACKUP_DIR"
echo "Retention: $RETENTION_DAYS days"
