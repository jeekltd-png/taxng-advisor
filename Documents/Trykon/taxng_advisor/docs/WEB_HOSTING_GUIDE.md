# TaxPadi Web Hosting Guide

Complete guide for deploying TaxPadi web application to production servers.

---

## 📋 Table of Contents

1. [Requirements](#requirements)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Hosting Options](#hosting-options)
4. [Deployment Steps](#deployment-steps)
5. [Configuration](#configuration)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)
8. [Maintenance](#maintenance)

---

## 🔧 Requirements

### Server Requirements

**Minimum Specifications:**
- **Web Server:** Apache 2.4+, Nginx 1.18+, or any static file server
- **Storage:** 100 MB minimum (for app files)
- **Bandwidth:** Recommended 10 GB/month minimum
- **RAM:** 512 MB (for server operation)
- **Operating System:** Linux (Ubuntu 20.04+, CentOS 8+), Windows Server, or any OS supporting web servers

### Domain & SSL

**Domain:**
- Registered domain name (e.g., taxpadi.com, app.taxpadi.com)
- DNS access for configuration
- Optional: Subdomain for staging environment

**SSL Certificate:**
- **Required** - HTTPS is mandatory for Flutter web apps
- Options:
  - Let's Encrypt (Free)
  - Commercial SSL certificate
  - Cloudflare SSL (Free with Cloudflare CDN)

### Browser Support

TaxPadi web app supports:
- Chrome 90+ (Recommended)
- Firefox 88+
- Safari 14+
- Edge 90+
- Opera 76+

**Note:** Modern browsers with JavaScript and WebAssembly support required.

---

## ✅ Pre-Deployment Checklist

Before deploying, ensure:

- [ ] Build files generated (`build/web` folder exists)
- [ ] Version number updated in `pubspec.yaml` (currently 2.4.0+32)
- [ ] Domain name registered and DNS configured
- [ ] SSL certificate obtained and installed
- [ ] Web server installed and configured
- [ ] Firewall rules configured (ports 80 and 443 open)
- [ ] Database backup created (if using remote database)
- [ ] Environment variables configured (if needed)

---

## 🌐 Hosting Options

### Option 1: Traditional Web Hosting (Shared/VPS)

**Providers:**
- Hostinger, Bluehost, SiteGround (Shared)
- DigitalOcean, Linode, Vultr (VPS)
- AWS Lightsail, Google Cloud Compute Engine

**Best For:** Full control, custom domain, professional deployment

**Cost:** $5-50/month depending on specifications

### Option 2: Cloud Platforms (PaaS)

**Providers:**
- **Firebase Hosting** (Recommended for Flutter)
- **Vercel**
- **Netlify**
- **GitHub Pages**
- **AWS Amplify**

**Best For:** Easy deployment, auto-scaling, CDN included

**Cost:** Free tier available, then pay-as-you-go

### Option 3: Cloud Storage + CDN

**Providers:**
- AWS S3 + CloudFront
- Google Cloud Storage + Cloud CDN
- Azure Blob Storage + Azure CDN

**Best For:** High availability, global distribution

**Cost:** $1-20/month for small/medium traffic

---

## 🚀 Deployment Steps

### Method 1: Firebase Hosting (Recommended)

Firebase provides excellent support for Flutter web apps with automatic SSL and CDN.

#### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

#### Step 2: Login to Firebase

```bash
firebase login
```

#### Step 3: Initialize Firebase in Project

```bash
cd C:\Users\aipri\Documents\Trykon\taxng_advisor
firebase init hosting
```

**Configuration:**
- Select: "Use an existing project" or "Create a new project"
- Public directory: `build/web`
- Configure as single-page app: `Yes`
- Set up automatic builds: `No`
- Overwrite index.html: `No`

#### Step 4: Deploy

```bash
firebase deploy --only hosting
```

#### Step 5: Custom Domain (Optional)

```bash
firebase hosting:channel:deploy production
```

Then configure custom domain in Firebase Console:
1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Enter your domain (e.g., app.taxpadi.com)
4. Follow DNS configuration instructions
5. Wait for SSL certificate provisioning (5-10 minutes)

**Result:** Your app will be available at `https://your-project.web.app` or your custom domain.

---

### Method 2: Traditional Web Server (Apache/Nginx)

#### For Apache Server

**Step 1: Upload Files**

Upload contents of `build/web` folder to your server's web root:
```bash
# Using SCP
scp -r build/web/* user@your-server:/var/www/html/taxpadi/

# Or using FTP client (FileZilla, WinSCP)
# Upload all files from build/web to /var/www/html/taxpadi/
```

**Step 2: Configure Apache**

Create virtual host configuration:

```apache
<VirtualHost *:80>
    ServerName taxpadi.com
    ServerAlias www.taxpadi.com
    DocumentRoot /var/www/html/taxpadi

    <Directory /var/www/html/taxpadi>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Enable CORS if needed
        Header set Access-Control-Allow-Origin "*"
        
        # Handle Flutter routing
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.html [L]
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/taxpadi_error.log
    CustomLog ${APACHE_LOG_DIR}/taxpadi_access.log combined
</VirtualHost>

# HTTPS (443) configuration
<VirtualHost *:443>
    ServerName taxpadi.com
    ServerAlias www.taxpadi.com
    DocumentRoot /var/www/html/taxpadi

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/taxpadi.crt
    SSLCertificateKeyFile /etc/ssl/private/taxpadi.key
    SSLCertificateChainFile /etc/ssl/certs/taxpadi-chain.crt

    <Directory /var/www/html/taxpadi>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.html [L]
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/taxpadi_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/taxpadi_ssl_access.log combined
</VirtualHost>
```

**Step 3: Enable Site and Restart**

```bash
sudo a2ensite taxpadi.conf
sudo a2enmod rewrite ssl headers
sudo systemctl restart apache2
```

---

#### For Nginx Server

**Step 1: Upload Files**

Upload contents of `build/web` folder:
```bash
scp -r build/web/* user@your-server:/var/www/taxpadi/
```

**Step 2: Configure Nginx**

Create configuration file: `/etc/nginx/sites-available/taxpadi`

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name taxpadi.com www.taxpadi.com;
    
    return 301 https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name taxpadi.com www.taxpadi.com;

    root /var/www/taxpadi;
    index index.html;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/taxpadi.crt;
    ssl_certificate_key /etc/ssl/private/taxpadi.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/javascript application/json;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' https: data: 'unsafe-inline' 'unsafe-eval';" always;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Handle Flutter routing (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
```

**Step 3: Enable Site and Restart**

```bash
sudo ln -s /etc/nginx/sites-available/taxpadi /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

### Method 3: Using Cloudflare Pages

**Step 1: Setup Git Repository**

Ensure your project is in a Git repository (GitHub, GitLab, Bitbucket).

**Step 2: Connect to Cloudflare Pages**

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select "Pages" from sidebar
3. Click "Create a project"
4. Connect your Git repository
5. Configure build settings:
   - **Build command:** `flutter build web --release`
   - **Build output directory:** `build/web`
   - **Root directory:** `/`

**Step 3: Deploy**

Cloudflare will automatically build and deploy on every Git push.

**Step 4: Custom Domain**

1. Add custom domain in Pages settings
2. Update DNS records as instructed
3. SSL is automatically provisioned

---

## ⚙️ Configuration

### Environment-Specific Settings

If you need different configurations for production vs development:

**Option 1: Build-time configuration**

Build with different flavors:
```bash
flutter build web --release --dart-define=ENV=production
```

**Option 2: Runtime configuration**

Create a `config.js` file in `web/` folder:

```javascript
// config.js
window.appConfig = {
  apiUrl: 'https://api.taxpadi.com',
  environment: 'production',
  enableAnalytics: true,
  supportEmail: 'support@taxpadi.com'
};
```

Load in `web/index.html`:
```html
<script src="config.js"></script>
```

### Base HREF Configuration

If hosting in a subdirectory (e.g., `https://example.com/taxpadi/`):

```bash
flutter build web --release --base-href="/taxpadi/"
```

---

## 🧪 Testing

### Pre-Launch Testing Checklist

Test the following after deployment:

**Functionality Tests:**
- [ ] Login/Register works correctly
- [ ] Tax calculators produce accurate results
- [ ] PDF generation (VAT Form 002) works
- [ ] Document upload/download functions
- [ ] Payment integration works (if enabled)
- [ ] Help documentation loads properly
- [ ] Navigation between all screens works

**Performance Tests:**
- [ ] Initial load time < 5 seconds
- [ ] Responsive on mobile devices
- [ ] No console errors in browser
- [ ] Assets load correctly (icons, images)

**Security Tests:**
- [ ] HTTPS connection is secure (green padlock)
- [ ] SSL certificate is valid
- [ ] No mixed content warnings
- [ ] Secure cookies (if using authentication)

**Browser Compatibility:**
- [ ] Test on Chrome (latest)
- [ ] Test on Firefox (latest)
- [ ] Test on Safari (if Mac available)
- [ ] Test on mobile browsers (iOS Safari, Chrome Mobile)

### Testing Tools

**Performance:**
- Google Lighthouse (built into Chrome DevTools)
- GTmetrix: https://gtmetrix.com
- WebPageTest: https://www.webpagetest.org

**SSL/Security:**
- SSL Labs: https://www.ssllabs.com/ssltest/
- SecurityHeaders.com: https://securityheaders.com

**Mobile Testing:**
- Chrome DevTools Device Mode
- BrowserStack: https://www.browserstack.com (paid)

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Issue 1: White Screen / Blank Page

**Symptoms:** App loads but shows blank white screen

**Solutions:**
1. Check browser console for errors (F12)
2. Verify all files uploaded correctly
3. Check `base-href` configuration
4. Clear browser cache and reload
5. Verify `index.html` is in the root directory

**Fix:**
```bash
# Rebuild with correct base-href
flutter build web --release --base-href="/"
```

---

#### Issue 2: 404 Errors on Page Refresh

**Symptoms:** Direct URLs or page refresh shows 404 error

**Solutions:**

**For Apache:** Ensure `.htaccess` exists with:
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

**For Nginx:** Ensure `try_files` directive is set:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

#### Issue 3: Assets Not Loading (404 for icons/fonts)

**Symptoms:** Icons appear as boxes, fonts don't load

**Solutions:**
1. Verify asset files uploaded to `assets/` folder
2. Check MIME types configured correctly
3. Verify paths in `index.html`
4. Check CORS headers if using CDN

**Fix for Apache:**
```apache
AddType font/woff2 .woff2
AddType font/woff .woff
AddType application/font-ttf .ttf
```

---

#### Issue 4: Slow Initial Load

**Symptoms:** App takes > 10 seconds to load

**Solutions:**
1. Enable Gzip/Brotli compression
2. Configure caching headers
3. Use CDN for static assets
4. Optimize images (use WebP format)
5. Enable HTTP/2

**For Nginx - Enable Brotli:**
```nginx
brotli on;
brotli_comp_level 6;
brotli_types text/plain text/css application/javascript application/json;
```

---

#### Issue 5: SSL Certificate Errors

**Symptoms:** "Your connection is not private" warning

**Solutions:**
1. Verify certificate is valid and not expired
2. Check certificate chain is complete
3. Ensure certificate matches domain name
4. Test with SSL Labs

**Free SSL with Let's Encrypt:**
```bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d taxpadi.com -d www.taxpadi.com
```

---

#### Issue 6: CORS Errors in Console

**Symptoms:** API calls fail with CORS policy error

**Solutions:**

**For Apache:**
```apache
Header set Access-Control-Allow-Origin "https://taxpadi.com"
Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
Header set Access-Control-Allow-Headers "Content-Type, Authorization"
```

**For Nginx:**
```nginx
add_header Access-Control-Allow-Origin "https://taxpadi.com" always;
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
```

---

## 🔄 Maintenance

### Regular Updates

**1. Deploying New Versions:**

```bash
# Build new version
flutter build web --release

# Upload to server (replace files)
scp -r build/web/* user@server:/var/www/taxpadi/

# Or redeploy to Firebase
firebase deploy --only hosting
```

**2. Version Management:**

Update version in `pubspec.yaml` before building:
```yaml
version: 2.4.0+32  # Increment for each release
```

**3. Cache Busting:**

Users may see old version due to browser caching. Solutions:
- Firebase Hosting: Handles automatically
- Manual: Add version query string to assets
- Use service worker for cache control

### Monitoring

**Tools to Monitor:**
- **Uptime:** UptimeRobot, Pingdom
- **Analytics:** Google Analytics, Mixpanel
- **Errors:** Sentry, LogRocket
- **Performance:** Google Search Console, Lighthouse CI

### Backup Strategy

**What to Backup:**
1. Application files (entire `build/web` folder)
2. Server configuration files
3. SSL certificates
4. User data (if stored server-side)
5. Database (if applicable)

**Frequency:**
- Before each deployment
- Daily automated backups of data
- Weekly full system backups

### Security Updates

**Regular Security Tasks:**
- Update SSL certificates (Let's Encrypt renews every 90 days)
- Update server software packages
- Review access logs for suspicious activity
- Update Flutter SDK and rebuild app periodically
- Monitor for dependency vulnerabilities

---

## 📞 Support Resources

### Documentation
- Flutter Web: https://docs.flutter.dev/platform-integration/web
- Firebase Hosting: https://firebase.google.com/docs/hosting
- Nginx Documentation: https://nginx.org/en/docs/

### Community
- Flutter Community: https://flutter.dev/community
- Stack Overflow: Use tags `flutter-web`, `flutter`
- GitHub Issues: Report bugs in Flutter repository

### Professional Services
- Web hosting providers' support teams
- Cloudflare support (for Pages/CDN issues)
- Flutter consulting services

---

## 📝 Quick Reference

### Essential Commands

```bash
# Build for web
flutter build web --release

# Build with custom base href
flutter build web --release --base-href="/app/"

# Test locally
flutter run -d chrome

# Check Flutter web support
flutter doctor
```

### Important File Locations

```
build/web/               # Built files (upload this to server)
web/index.html           # Entry point HTML
web/manifest.json        # PWA manifest
web/icons/               # App icons
pubspec.yaml             # Version number
```

### Port Configuration

- **HTTP:** Port 80
- **HTTPS:** Port 443
- **Test Server:** Port 8080 (optional)

---

## ✅ Deployment Checklist

Final checklist before going live:

- [ ] Domain DNS configured and propagated
- [ ] SSL certificate installed and valid
- [ ] All files uploaded to correct directory
- [ ] Web server configured (Apache/Nginx)
- [ ] Rewrite rules configured for SPA routing
- [ ] Gzip/Brotli compression enabled
- [ ] Cache headers configured
- [ ] Security headers added
- [ ] Firewall rules configured
- [ ] Tested on multiple browsers
- [ ] Tested on mobile devices
- [ ] Performance score > 90 (Lighthouse)
- [ ] No console errors
- [ ] Analytics configured (optional)
- [ ] Backup created
- [ ] Monitoring tools set up
- [ ] Documentation updated with live URL

---

## 🎉 Success!

Your TaxPadi web application is now live and accessible to users worldwide!

**Current Version:** 2.4.0+32

**Need Help?** 
- Review troubleshooting section above
- Check Flutter web documentation
- Contact hosting provider support

---

*Last Updated: January 15, 2026*
*TaxPadi - Your Padi for Nigerian Tax Matters*
