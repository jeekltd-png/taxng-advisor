# Production Deployment Configuration

## Database Configuration

### SQLite (Development/Small Scale)
```
DB_TYPE=sqlite
DB_PATH=./src/db.sqlite
```

### PostgreSQL (Production Recommended)
```
DB_TYPE=postgresql
DATABASE_URL=postgresql://username:password@hostname:5432/databasename
# OR individual components:
DB_HOST=localhost
DB_PORT=5432
DB_NAME=osusu
DB_USER=postgres
DB_PASSWORD=secure_password_here
```

## SSL/TLS Configuration

### Self-Signed Certificate (Testing)
```
SSL_CERT_PATH=./config/certs/cert.pem
SSL_KEY_PATH=./config/certs/key.pem
FORCE_HTTPS=false
```

### Let's Encrypt (Production)
```
SSL_CERT_PATH=/etc/letsencrypt/live/yourdomain.com/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/yourdomain.com/privkey.pem
FORCE_HTTPS=true
```

### HTTP (Behind reverse proxy)
```
FORCE_HTTPS=false  # Proxy handles HTTPS
```

## Email Service Configuration

### SendGrid
```
EMAIL_SERVICE=sendgrid
EMAIL_FROM=noreply@yourdomain.com
EMAIL_API_KEY=SG.your_sendgrid_api_key_here
```

### Mailgun
```
EMAIL_SERVICE=mailgun
MAILGUN_DOMAIN=yourdomain.mailgun.org
EMAIL_API_KEY=your_mailgun_api_key_here
```

### SMTP
```
EMAIL_SERVICE=smtp
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USER=your_email@gmail.com
EMAIL_SMTP_PASSWORD=your_app_password
```

## Backup Configuration

### AWS S3 (Cloud Storage)
```
AWS_S3_BUCKET=osusu-backups
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
```

### Local Backup
```
BACKUP_RETENTION_DAYS=30
BACKUP_PATH=./backups
```

## Monitoring & Logging

### Sentry (Error Tracking)
```
SENTRY_DSN=https://your-key@sentry.io/project-id
SENTRY_ENVIRONMENT=production
```

### New Relic (APM)
```
NEW_RELIC_LICENSE_KEY=your_license_key
NEW_RELIC_APP_NAME=osusu
```

### Datadog (Metrics)
```
DATADOG_API_KEY=your_api_key
DATADOG_APP_KEY=your_app_key
DATADOG_SITE=datadoghq.com
```

## Security Configuration

```
JWT_SECRET=very_long_random_string_minimum_32_characters
JWT_REFRESH_SECRET=another_very_long_random_string
CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100
```

## Application Configuration

```
NODE_ENV=production
PORT=5000
APP_URL=https://yourdomain.com
LOG_LEVEL=info
```

## Deployment Checklist

- [ ] Database provisioned and tested
- [ ] Backups configured and tested
- [ ] SSL/TLS certificates obtained
- [ ] Email service configured
- [ ] Environment variables set securely
- [ ] Security audit completed
- [ ] Load testing completed
- [ ] Monitoring/alerting configured
- [ ] Incident response plan documented
- [ ] Rollback procedure tested
