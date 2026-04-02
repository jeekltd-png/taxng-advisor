/**
 * Database Configuration Module
 * Supports both SQLite (development) and PostgreSQL (production)
 * Automatically selects based on NODE_ENV and DB_TYPE
 */

const sqlite3 = require('sqlite3').verbose();
const { Pool } = require('pg');
const path = require('path');
const util = require('util');
const fs = require('fs');
const logger = require('./logger');

// Database type detection
const DB_TYPE = process.env.DB_TYPE || (process.env.NODE_ENV === 'production' ? 'postgresql' : 'sqlite');
const USE_POSTGRESQL = DB_TYPE === 'postgresql' || process.env.DATABASE_URL;

let db = null;
let pool = null;
const run = null;
const get = null;
const all = null;

// ==================== SQLITE CONFIG ====================
const initSQLite = async () => {
  return new Promise((resolve, reject) => {
    const dbPath = process.env.DB_PATH || path.join(__dirname, 'db.sqlite');
    const ensureDir = path.dirname(dbPath);
    if (!fs.existsSync(ensureDir)) fs.mkdirSync(ensureDir, { recursive: true });

    db = new sqlite3.Database(dbPath, (err) => {
      if (err) reject(err);
      else {
        logger.info(`Connected to SQLite database at ${dbPath}`);
        resolve();
      }
    });
  });
};

// ==================== POSTGRESQL CONFIG ====================
const initPostgreSQL = async () => {
  try {
    const connectionString = process.env.DATABASE_URL || 
      `postgresql://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`;
    
    pool = new Pool({
      connectionString,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
    });

    // Test connection
    const client = await pool.connect();
    logger.info('Connected to PostgreSQL database');
    client.release();
  } catch (err) {
    logger.error('Failed to connect to PostgreSQL', { error: err.message });
    throw err;
  }
};

// ==================== QUERY WRAPPERS ====================
const runQuery = async (query, params = []) => {
  if (USE_POSTGRESQL) {
    const result = await pool.query(query, params);
    return result;
  } else {
    return new Promise((resolve, reject) => {
      db.run(query, params, function(err) {
        if (err) reject(err);
        else resolve({ lastID: this.lastID, changes: this.changes });
      });
    });
  }
};

const getQuery = async (query, params = []) => {
  if (USE_POSTGRESQL) {
    const result = await pool.query(query, params);
    return result.rows[0];
  } else {
    return new Promise((resolve, reject) => {
      db.get(query, params, (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  }
};

const allQuery = async (query, params = []) => {
  if (USE_POSTGRESQL) {
    const result = await pool.query(query, params);
    return result.rows;
  } else {
    return new Promise((resolve, reject) => {
      db.all(query, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      });
    });
  }
};

// ==================== SCHEMA INITIALIZATION ====================
const initSchema = async () => {
  if (USE_POSTGRESQL) {
    await initPostgreSQLSchema();
  } else {
    await initSQLiteSchema();
  }
};

const initSQLiteSchema = async () => {
  await runQuery('PRAGMA foreign_keys = ON');

  const tables = [
    `CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      passwordHash TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'user',
      createdAt TEXT NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS groups (
      id TEXT PRIMARY KEY,
      name TEXT UNIQUE NOT NULL,
      creatorId TEXT NOT NULL,
      currency TEXT NOT NULL DEFAULT 'GBP',
      locale TEXT NOT NULL DEFAULT 'en-GB',
      country TEXT NOT NULL DEFAULT 'UK',
      contributionAmount REAL NOT NULL DEFAULT 100,
      cycleType TEXT NOT NULL DEFAULT 'weekly',
      feePercent REAL NOT NULL DEFAULT 1,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (creatorId) REFERENCES users(id) ON DELETE CASCADE
    )`,
    `CREATE TABLE IF NOT EXISTS group_members (
      id TEXT PRIMARY KEY,
      groupId TEXT NOT NULL,
      name TEXT NOT NULL,
      balance REAL NOT NULL DEFAULT 0,
      joinedAt TEXT NOT NULL,
      FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE,
      UNIQUE(groupId, name)
    )`,
    `CREATE TABLE IF NOT EXISTS contributions (
      id TEXT PRIMARY KEY,
      groupMemberId TEXT NOT NULL,
      groupId TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      FOREIGN KEY (groupMemberId) REFERENCES group_members(id) ON DELETE CASCADE,
      FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE
    )`,
    `CREATE TABLE IF NOT EXISTS cycles (
      id TEXT PRIMARY KEY,
      groupId TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      paymentDate TEXT NOT NULL,
      status TEXT NOT NULL,
      grossPot REAL NOT NULL,
      feePercent REAL NOT NULL,
      feeAmount REAL NOT NULL,
      netPot REAL NOT NULL,
      recipientGroupMemberId TEXT,
      paidAt TEXT,
      FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE,
      FOREIGN KEY (recipientGroupMemberId) REFERENCES group_members(id) ON DELETE SET NULL
    )`,
    `CREATE TABLE IF NOT EXISTS audit_logs (
      id TEXT PRIMARY KEY,
      userId TEXT NOT NULL,
      action TEXT NOT NULL,
      resource TEXT NOT NULL,
      resourceId TEXT,
      changes TEXT,
      ip TEXT,
      userAgent TEXT,
      status TEXT DEFAULT 'success',
      details TEXT,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    )`
  ];

  for (const table of tables) {
    await runQuery(table);
  }
};

const initPostgreSQLSchema = async () => {
  const tables = [
    `CREATE TABLE IF NOT EXISTS users (
      id VARCHAR(255) PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      passwordHash VARCHAR(255) NOT NULL,
      role VARCHAR(50) NOT NULL DEFAULT 'user',
      createdAt TIMESTAMP NOT NULL,
      CONSTRAINT users_email_unique UNIQUE (email)
    )`,
    `CREATE TABLE IF NOT EXISTS groups (
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
    )`,
    `CREATE TABLE IF NOT EXISTS group_members (
      id VARCHAR(255) PRIMARY KEY,
      groupId VARCHAR(255) NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
      name VARCHAR(255) NOT NULL,
      balance DECIMAL(15,2) NOT NULL DEFAULT 0,
      joinedAt TIMESTAMP NOT NULL,
      UNIQUE(groupId, name)
    )`,
    `CREATE TABLE IF NOT EXISTS contributions (
      id VARCHAR(255) PRIMARY KEY,
      groupMemberId VARCHAR(255) NOT NULL REFERENCES group_members(id) ON DELETE CASCADE,
      groupId VARCHAR(255) NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
      amount DECIMAL(10,2) NOT NULL,
      date TIMESTAMP NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS cycles (
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
    )`,
    `CREATE TABLE IF NOT EXISTS audit_logs (
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
    )`,
    `CREATE INDEX IF NOT EXISTS idx_audit_logs_userId ON audit_logs(userId)`,
    `CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action)`,
    `CREATE INDEX IF NOT EXISTS idx_audit_logs_createdAt ON audit_logs(createdAt DESC)`,
    `CREATE INDEX IF NOT EXISTS idx_cycles_groupId ON cycles(groupId)`,
    `CREATE INDEX IF NOT EXISTS idx_groups_creatorId ON groups(creatorId)`,
    `CREATE INDEX IF NOT EXISTS idx_group_members_groupId ON group_members(groupId)`
  ];

  for (const table of tables) {
    try {
      await pool.query(table);
    } catch (err) {
      if (!err.message.includes('already exists')) {
        logger.error('Schema creation error', { error: err.message });
      }
    }
  }
};

// ==================== EXPORTS ====================
const initialize = async () => {
  try {
    if (USE_POSTGRESQL) {
      await initPostgreSQL();
    } else {
      await initSQLite();
    }
    await initSchema();
    logger.info(`Database initialized (${USE_POSTGRESQL ? 'PostgreSQL' : 'SQLite'})`);
  } catch (err) {
    logger.error('Database initialization failed', { error: err.message });
    throw err;
  }
};

const close = async () => {
  try {
    if (USE_POSTGRESQL && pool) {
      await pool.end();
      logger.info('PostgreSQL connection pool closed');
    } else if (db) {
      return new Promise((resolve, reject) => {
        db.close((err) => {
          if (err) reject(err);
          else {
            logger.info('SQLite connection closed');
            resolve();
          }
        });
      });
    }
  } catch (err) {
    logger.error('Error closing database connection', { error: err.message });
  }
};

module.exports = {
  initialize,
  close,
  query: runQuery,
  get: getQuery,
  all: allQuery,
  pool,
  db,
  USE_POSTGRESQL
};
