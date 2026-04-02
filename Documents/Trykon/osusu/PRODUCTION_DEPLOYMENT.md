# Production Deployment Guide

## 📋 Overview
Complete guide for deploying Osusu to production with all enterprise-grade features.

---

## 1. Database Setup

### PostgreSQL Installation & Setup

#### Ubuntu/Debian
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database
sudo -u postgres psql << EOF
CREATE ROLE osusu WITH LOGIN PASSWORD 'secure_password';
CREATE DATABASE osusu OWNER osusu;
GRANT ALL PRIVILEGES ON DATABASE osusu TO osusu;
EOF

# Test connection
psql -h localhost -U osusu -d osusu -c "\dt"
```

#### macOS
```bash
# Install via Homebrew
brew install postgresql

# Start service
brew services start postgresql

# Create database
createuser -P osusu
createdb -O osusu osusu

# Test connection
psql -h localhost -U osusu -d osusu -c "\dt"
```

### Data Migration
```bash
# From SQLite to PostgreSQL
./scripts/migrate-sqlite-to-postgres.sh

# Verify
psql -h localhost -U osusu -d osusu -c "SELECT COUNT(*) FROM users;"
```

---

## 2. SSL/TLS Setup

### Option A: Let's Encrypt (RECOMMENDED)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Generate certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Update .env
export SSL_CERT_PATH=/etc/letsencrypt/live/yourdomain.com/fullchain.pem
export SSL_KEY_PATH=/etc/letsencrypt/live/yourdomain.com/privkey.pem
export FORCE_HTTPS=true

# Auto-renewal
sudo certbot renew --dry-run
sudo systemctl enable certbot.timer
```

### Option B: Self-Signed (Development)

```bash
# Generate certificate
./scripts/setup-ssl.sh

# Results in: config/certs/cert.pem and config/certs/key.pem

# Update .env
export SSL_CERT_PATH=./config/certs/cert.pem
export SSL_KEY_PATH=./config/certs/key.pem
export FORCE_HTTPS=false  # Test without enforcement first
```

---

## 3. Email Service Setup

### SendGrid (Recommended - Free tier available)

```bash
# Sign up at https://sendgrid.com
# Create API key in Settings → API Keys → Create API Key

# Update .env
export EMAIL_SERVICE=sendgrid
export EMAIL_FROM=noreply@yourdomain.com
export EMAIL_API_KEY=SG.your_actual_key_here

# Test
curl -X POST "https://api.sendgrid.com/v3/mail/send" \
  -H "Authorization: Bearer $EMAIL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"personalizations": [{"to": [{"email": "test@example.com"}]}], "from": {"email": "'$EMAIL_FROM'"}, "subject": "Test", "content": [{"type": "text/plain", "value": "Test"}]}'
```

---

## 4. Automated Backups

### Setup Daily Backups

```bash
# Make scripts executable
chmod +x scripts/backup-database.sh
chmod +x scripts/setup-cron-backup.sh

# Configure cron
./scripts/setup-cron-backup.sh postgres daily

# Or manually add to crontab
# 0 2 * * * cd /path/to/osusu && ./scripts/backup-database.sh postgres daily >> /var/log/osusu-backup.log 2>&1

# Verify
crontab -l | grep osusu
```

### AWS S3 Upload (Optional)

```bash
# Install AWS CLI
pip install awscli

# Configure credentials
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Region

# Update .env
export AWS_S3_BUCKET=osusu-backups
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret

# Test backup with S3
./scripts/backup-database.sh postgres daily
```

---

## 5. Load Testing

### Prerequisites
```bash
# Install Artillery
npm install -g artillery

# Or use npm version
npm install --save-dev artillery
```

### Run Load Test
```bash
# Start application in production mode
npm run dev

# In another terminal, run load test
artillery run load-test.yml

# With custom target
TARGET_URL=https://yourdomain.com artillery run load-test.yml

# View detailed report
artillery run load-test.yml -t /path/to/target
```

### Interpret Results
- **RPS (Requests Per Second)**: Throughput achieved
- **Latency (p99)**: 99th percentile response time
- **Error rate**: % of failed requests
- **Ramp up**: How fast load increases
- **Stress test phase**: Where system becomes unstable

---

## 6. Security Audit

### Run Audit Script
```bash
# Make executable
chmod +x scripts/security-audit.sh

# Run audit
./scripts/security-audit.sh

# Review findings in security-findings/ directory
```

### Manual Security Checks

```bash
# Check for vulnerabilities
npm audit

# Run OWASP ZAP (if installed)
zaproxy -cmd -quickurl https://yourdomain.com -quickout /tmp/zap-report.html

# Check SSL configuration
nmap --script ssl-enum-ciphers -p 443 yourdomain.com

# Test HTTPS headers
curl -I https://yourdomain.com | grep -i "Strict-Transport-Security"
```

---

## 7. Monitoring & Alerting

### Option A: Sentry (Error Tracking)

```bash
# Sign up at https://sentry.io

# Install
npm install @sentry/node

# Update server.js
const Sentry = require('@sentry/node');
Sentry.init({ dsn: process.env.SENTRY_DSN });
app.use(Sentry.Handlers.errorHandler());

# Update .env
export SENTRY_DSN=https://key@sentry.io/project-id
```

### Option B: Datadog (APM)

```bash
# Sign up at https://datadog.com

# Install
npm install dd-trace

# Update server.js
require('dd-trace').init()

# Update .env
export DD_API_KEY=your_api_key
export DD_APP_KEY=your_app_key
export DD_SERVICE=osusu
```

### Option C: Health Checks

```bash
# Use /health endpoint
curl https://yourdomain.com/health

# Set up monitoring
# Every 30 seconds, expect:
# - status: "ok"
# - database.healthy: true
# - memory usage < threshold
```

---

## 8. Deployment Architecture

### Recommended Setup

```
┌─────────────────────────────────────┐
│         CDN (CloudFlare)            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Load Balancer (nginx/HAProxy)    │
│    - SSL/TLS Termination            │
│    - Rate Limiting                  │
└──────────────┬──────────────────────┘
               │
        ┌──────┴──────────┬──────┐
        │                 │      │
┌───────▼────────┐ ┌─────▼─────┐ ┌──────────┐
│  Application   │ │ Application│ │ Application
│  Server 1      │ │ Server 2   │ │ Server 3
│  (Node.js)     │ │ (Node.js)  │ │ (Node.js)
└───────┬────────┘ └─────┬─────┘ └──────┬───┘
        │                │              │
        └────────┬───────┴──────┬──────┘
                 │              │
        ┌────────▼────────┐ ┌──▼────────────┐
        │   PostgreSQL    │ │ Redis Cache   │
        │   (Primary)     │ └───────────────┘
        └────────────────┘
                 │
        ┌────────▼────────┐
        │  S3 for Backups │
        └─────────────────┘
```

---

## 9. Docker Deployment

### Docker Production Build

```bash
# Build production image
docker build -t osusu:production \
  --build-arg NODE_ENV=production \
  -f Dockerfile .

# Push to registry
docker tag osusu:production myregistry.azurecr.io/osusu:latest
docker push myregistry.azurecr.io/osusu:latest

# Run container
docker run -d \
  --name osusu-prod \
  -p 5000:5000 \
  -e NODE_ENV=production \
  -e DATABASE_URL=postgresql://... \
  -e JWT_SECRET=... \
  -e EMAIL_API_KEY=... \
  -v /var/lib/osusu/backups:/app/backups \
  osusu:production
```

### Docker Compose Production

```bash
# Deploy
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Scale application
docker-compose -f docker-compose.prod.yml up -d --scale app=3
```

---

## 10. Deployment Checklist

### Pre-Deployment
- [ ] Database provisioned and migrated
- [ ] Backups tested with restoration
- [ ] SSL/TLS certificates installed
- [ ] Email service configured and tested
- [ ] Security audit completed
- [ ] Load testing completed (target: 100+ req/s)
- [ ] Monitoring/alerting configured
- [ ] Incident response plan created
- [ ] Rollback procedure documented

### Deployment
- [ ] Environment variables set securely
- [ ] Database migrations run
- [ ] Application starts without errors
- [ ] Health endpoint returns 200
- [ ] Database connectivity verified
- [ ] Email service sends test email
- [ ] Admin users created
- [ ] Initial data loaded

### Post-Deployment
- [ ] Application accessible via HTTPS
- [ ] SSL certificate valid
- [ ] All endpoints responding
- [ ] Backups running on schedule
- [ ] Monitoring showing healthy metrics
- [ ] Error tracking receiving events
- [ ] User support notified
- [ ] Documentation updated

---

## 11. Emergency Procedures

### Database Recovery

```bash
# From backup
./scripts/backup-database.sh postgres restore

# Or manually
gunzip osusu-postgres-backup.sql.gz
psql -U postgres -d osusu < osusu-postgres-backup.sql
```

### Application Rollback

```bash
# Stop current version
pm2 stop osusu

# Restore previous code
cd /app
git checkout v1.0.0

# Reinstall dependencies
npm install

# Start previous version
pm2 start osusu
```

### SSL Certificate Emergency

```bash
# Temporarily disable HTTPS
FORCE_HTTPS=false npm run start

# Then fix and redeploy
certbot certonly --force-renewal -d yourdomain.com
systemctl restart osusu
```

---

## 12. Performance Optimization

### Caching Strategy
```javascript
// Redis caching
const redis = require('redis');
const client = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
});
```

### Database Optimization
```sql
-- Add indexes for common queries
CREATE INDEX idx_groups_country ON groups(country);
CREATE INDEX idx_contributions_date ON contributions(date DESC);
```

### Compression
```javascript
// Enable gzip compression
const compression = require('compression');
app.use(compression());
```

---

## 13. Scaling Guide

### Horizontal Scaling
1. Deploy multiple application instances
2. Use load balancer to distribute traffic
3. Use PostgreSQL with Read Replicas
4. Cache frequently accessed data in Redis

### Vertical Scaling
1. Increase server RAM
2. Use faster CPU
3. Optimize database queries
4. Enable caching

---

## Support & Troubleshooting

### Common Issues

**Port 443 already in use:**
```bash
lsof -i :443
kill -9 <PID>
```

**SSL Certificate expired:**
```bash
certbot renew --force
systemctl restart osusu
```

**Database connection timeout:**
```bash
# Check PostgreSQL running
sudo systemctl status postgresql

# Test connection
psql -h localhost -U osusu -d osusu -c "SELECT 1;"
```

**Low disk space:**
```bash
# Clean old backups
find ./backups -mtime +30 -delete

# Check disk usage
du -sh ./backups/*
```

---

## Resources

- [Node.js Best Practices](https://nodejs.org/en/docs/guides/nodejs-web-app-security/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [SSL/TLS Setup](https://certbot.eff.org/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [OWASP Security](https://owasp.org/)

