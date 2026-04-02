#!/bin/bash

# SQLite to PostgreSQL Migration Script
# Safely migrates data from SQLite to PostgreSQL

set -e

echo "🚀 SQLite to PostgreSQL Migration"
echo "=================================="
echo ""

# Configuration
SQLITE_PATH="${1:-./src/db.sqlite}"
PG_HOST="${DB_HOST:-localhost}"
PG_PORT="${DB_PORT:-5432}"
PG_DB="${DB_NAME:-osusu}"
PG_USER="${DB_USER:-postgres}"
BACKUP_DIR="./migration-backup"

# Validation
if [ ! -f "$SQLITE_PATH" ]; then
    echo "❌ SQLite database not found: $SQLITE_PATH"
    exit 1
fi

echo "📋 Pre-migration checklist:"
echo "  ✓ Source: $SQLITE_PATH"
echo "  ✓ Target: postgresql://$PG_USER@$PG_HOST:$PG_PORT/$PG_DB"
echo "  ✓ Backup dir: $BACKUP_DIR"
echo ""

# Create backup
echo "📦 Creating backup of SQLite database..."
mkdir -p "$BACKUP_DIR"
cp "$SQLITE_PATH" "$BACKUP_DIR/osusu-sqlite-backup-$(date +%s).db"
echo "✅ Backup created"
echo ""

# Export from SQLite to CSV
echo "📤 Exporting data from SQLite..."

mkdir -p "$BACKUP_DIR/export"

sqlite3 "$SQLITE_PATH" << 'SQLITE_EXPORT'
.mode csv
.output backup-dir/export/users.csv
SELECT * FROM users;
.output backup-dir/export/groups.csv
SELECT * FROM groups;
.output backup-dir/export/group_members.csv
SELECT * FROM group_members;
.output backup-dir/export/contributions.csv
SELECT * FROM contributions;
.output backup-dir/export/cycles.csv
SELECT * FROM cycles;
.output backup-dir/export/audit_logs.csv
SELECT * FROM audit_logs;
SQLITE_EXPORT

echo "✅ Data exported to CSV files"
echo ""

# Create schema in PostgreSQL
echo "🏗️  Creating schema in PostgreSQL..."
PGPASSWORD="$DB_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" << 'POSTGRES_SCHEMA'
CREATE DATABASE IF NOT EXISTS osusu;
\c osusu

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(255) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  passwordHash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  createdAt TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS groups (
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  creatorId VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  currency VARCHAR(3) NOT NULL DEFAULT 'GBP',
  locale VARCHAR(10) NOT NULL DEFAULT 'en-GB',
  country VARCHAR(100) NOT NULL DEFAULT 'UK',
  contributionAmount DECIMAL(10,2) NOT NULL DEFAULT 100,
  cycleType VARCHAR(50) NOT NULL DEFAULT 'weekly',
  feePercent DECIMAL(5,2) NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS group_members (
  id VARCHAR(255) PRIMARY KEY,
  groupId VARCHAR(255) NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  balance DECIMAL(15,2) NOT NULL DEFAULT 0,
  joinedAt TIMESTAMP NOT NULL,
  UNIQUE(groupId, name)
);

CREATE TABLE IF NOT EXISTS contributions (
  id VARCHAR(255) PRIMARY KEY,
  groupMemberId VARCHAR(255) NOT NULL REFERENCES group_members(id) ON DELETE CASCADE,
  groupId VARCHAR(255) NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  date TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS cycles (
  id VARCHAR(255) PRIMARY KEY,
  groupId VARCHAR(255) NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  createdAt TIMESTAMP NOT NULL,
  paymentDate TIMESTAMP NOT NULL,
  status VARCHAR(50) NOT NULL,
  grossPot DECIMAL(15,2) NOT NULL,
  feePercent DECIMAL(5,2) NOT NULL,
  feeAmount DECIMAL(10,2) NOT NULL,
  netPot DECIMAL(15,2) NOT NULL,
  recipientGroupMemberId VARCHAR(255) REFERENCES group_members(id) ON DELETE SET NULL,
  paidAt TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id VARCHAR(255) PRIMARY KEY,
  userId VARCHAR(255) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(50) NOT NULL,
  resource VARCHAR(50) NOT NULL,
  resourceId VARCHAR(255),
  changes JSONB,
  ip VARCHAR(45),
  userAgent TEXT,
  status VARCHAR(20) DEFAULT 'success',
  details TEXT,
  createdAt TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_userId ON audit_logs(userId);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_createdAt ON audit_logs(createdAt DESC);
POSTGRES_SCHEMA

echo "✅ PostgreSQL schema created"
echo ""

# Import from CSV to PostgreSQL
echo "📥 Importing data into PostgreSQL..."

PGPASSWORD="$DB_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" << 'POSTGRES_IMPORT'
\COPY users FROM 'backup-dir/export/users.csv' WITH (FORMAT csv, HEADER);
\COPY groups FROM 'backup-dir/export/groups.csv' WITH (FORMAT csv, HEADER);
\COPY group_members FROM 'backup-dir/export/group_members.csv' WITH (FORMAT csv, HEADER);
\COPY contributions FROM 'backup-dir/export/contributions.csv' WITH (FORMAT csv, HEADER);
\COPY cycles FROM 'backup-dir/export/cycles.csv' WITH (FORMAT csv, HEADER);
\COPY audit_logs FROM 'backup-dir/export/audit_logs.csv' WITH (FORMAT csv, HEADER);
POSTGRES_IMPORT

echo "✅ Data imported successfully"
echo ""

# Verify migration
echo "✅ Verifying migration..."

USER_COUNT=$(PGPASSWORD="$DB_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" -t -c "SELECT COUNT(*) FROM users;")
GROUP_COUNT=$(PGPASSWORD="$DB_PASSWORD" psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DB" -t -c "SELECT COUNT(*) FROM groups;")

echo "📊 Migration Summary:"
echo "  Users migrated: $USER_COUNT"
echo "  Groups migrated: $GROUP_COUNT"
echo ""

if [ "$USER_COUNT" -gt 0 ]; then
    echo "✅ Migration successful!"
else
    echo "⚠️  No users found in PostgreSQL - check backup CSV files"
fi

echo ""
echo "📝 Next steps:"
echo "  1. Verify data in PostgreSQL:"
echo "     psql -h $PG_HOST -U $PG_USER -d $PG_DB"
echo ""
echo "  2. Update .env with PostgreSQL connection:"
echo "     DB_TYPE=postgresql"
echo "     DATABASE_URL=postgresql://$PG_USER@$PG_HOST:$PG_PORT/$PG_DB"
echo ""
echo "  3. Update src/sqlite.js or use new src/database.js"
echo ""
echo "  4. Restart application:"
echo "     npm run dev"
echo ""
echo "  5. Run backup of old SQLite file:"
echo "     ./scripts/backup-database.sh sqlite manual"
echo ""
echo "🔒 Migration backup stored in: $BACKUP_DIR"
