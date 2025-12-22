# TaxNG Advisor - User Testing Guide

This guide provides instructions for testers to access and test the TaxNG Advisor application across different platforms.

## Test Credentials

### Admin Account
- **Username:** `admin`
- **Password:** `Admin@123`
- **Access:** Full admin features, admin documentation, pricing editor, deployment guides

### Regular User Account
- **Username:** `testuser`
- **Password:** `Test@1234`
- **Access:** Standard user features, all calculators, import/export functions

---

## Option 1: Android APK (Direct Download)

This is the fastest way for Android testers to get started.

### Steps

1. **Receive APK File**
   - Admin sends `app-release.apk` via WhatsApp, Email, or Google Drive
   - File size: ~50-80 MB (depending on build)

2. **Enable Unknown Sources**
   - Go to Settings → Security
   - Enable "Unknown Sources" or "Install Unknown Apps"

3. **Install APK**
   - Open Files app and navigate to Downloads
   - Tap the APK file
   - Tap "Install"
   - Wait for installation to complete

4. **Launch App**
   - Open TaxNG Advisor from app drawer
   - Login with test credentials above

### Troubleshooting

**"Cannot install app"**
- Ensure device has at least 100 MB free storage
- Try clearing cache: Settings → Apps → App Manager → Storage → Clear Cache
- Update Google Play Services: Play Store → My apps & games → Updates

**"App crashes on startup"**
- Ensure Android 8.0+ (check Settings → About Device)
- Clear app data: Settings → Apps → TaxNG Advisor → Storage → Clear Data
- Reinstall APK

---

## Option 2: Web Browser (No Installation)

Perfect for quick testing without installation or for desktop/laptop.

### Steps

1. **Access Web Version**
   - Open browser: Chrome, Safari, Firefox, or Edge
   - Visit: `https://taxng-advisor.web.app` (or provided test URL)

2. **No Installation Needed**
   - Loads directly in browser
   - Works on Android, iOS, Windows, Mac, Linux

3. **Login**
   - Use test credentials above
   - Can test simultaneously across multiple devices

### Browser Requirements

- Chrome 90+, Safari 14+, Firefox 88+, Edge 90+
- JavaScript enabled
- Cookies enabled (for session management)

### Troubleshooting

**"Page not loading"**
- Check internet connection
- Clear browser cache: Settings → Privacy → Clear browsing data
- Try incognito/private mode
- Try different browser

**"Slow performance"**
- Close other browser tabs
- Check internet connection (use speedtest.net)
- Reload page (Ctrl+R or Cmd+R)

---

## Option 3: Google Play Internal Testing (Coming Soon)

Once app is approved:

### Steps

1. **Get Testing Link**
   - Admin shares Google Play internal testing link
   - Link format: `https://play.google.com/apps/internaltest/...`

2. **Join Testing**
   - Open link in Chrome on Android device
   - Tap "Become a tester"
   - Accept permissions

3. **Install from Play Store**
   - Open Google Play Store
   - Search "TaxNG Advisor"
   - Tap "Install" (appears as beta/testing version)

### Advantages

- Automatic updates when new builds are released
- Crash reporting and feedback tools
- Performance monitoring

---

## What to Test

### Core Features

- **All Calculators**
  - CIT (Corporate Income Tax)
  - VAT (Value Added Tax)
  - PIT (Personal Income Tax)
  - WHT (Withholding Tax)
  - Payroll Tax
  - Stamp Duty

- **Data Import**
  - CSV file import
  - JSON file import
  - Paste data directly
  - Sample data loading

- **Currency Conversion**
  - Naira to USD conversion
  - GBP to USD conversion
  - Conversion rates display

- **Admin Features** (when logged in as admin)
  - View admin documentation
  - Access pricing editor
  - View deployment guides
  - Currency conversion admin dashboard

### User Features

- **Profile Management**
  - Update profile information
  - Change password
  - Export data

- **Data Management**
  - Save calculations
  - Load saved data
  - Delete records
  - Sync to cloud (if configured)

- **Help & Support**
  - Read FAQ articles
  - Access help documentation
  - View pricing plans
  - Contact support

### Mobile-Specific Tests

- Landscape/portrait orientation
- Screen size compatibility (small phones, tablets)
- Offline functionality
- App background/foreground behavior

---

## Reporting Issues

### Issue Template

Use this format when reporting bugs:

```
Feature: [Tax Calculator / Import / etc]

Problem: [Brief description of issue]

Steps to Reproduce:
1. [First step]
2. [Second step]
3. [Action that causes issue]

Expected Result:
[What should happen]

Actual Result:
[What actually happened]

Device: [Phone model, e.g., Samsung A12]
OS: [Android/iOS version]
App Version: [Version number from About screen]
```

### Example Issue Report

```
Feature: CIT Calculator

Problem: Total tax is displayed incorrectly

Steps to Reproduce:
1. Go to CIT Calculator
2. Enter turnover: 50,000,000
3. Enter expenses: 15,000,000
4. Tap Calculate

Expected Result:
Tax should be ₦8,225,000 (based on 2024 rates)

Actual Result:
Tax shows ₦7,000,000

Device: iPhone 13
OS: iOS 16.4
App Version: 1.0.0
```

### Reporting Channels

- **Email:** jeekltd@gmail.com
- **WhatsApp:** [Provided contact]
- **Feedback Form:** Help → Contact Support (in-app)

---

## Test Checklist

### Before Starting

- [ ] Device has stable internet connection
- [ ] Device storage has at least 100 MB free
- [ ] Test credentials are available
- [ ] Testing tool (APK/Web link) is accessible

### During Testing

- [ ] Login with both admin and regular user accounts
- [ ] Test at least 3 different calculators
- [ ] Test CSV/JSON import with sample files
- [ ] Check currency conversion displays correctly
- [ ] Test on multiple screen sizes (if possible)
- [ ] Try offline if applicable
- [ ] Rotate device between portrait/landscape

### Admin-Specific Tests (if logged in as admin)

- [ ] Access admin documentation screens
- [ ] View pricing plans
- [ ] Try editing pricing (admin only)
- [ ] Check deployment guides
- [ ] Verify admin-only features are hidden from regular users

### Reporting

- [ ] Document any crashes or errors
- [ ] Note UI/UX issues (misaligned text, buttons, etc.)
- [ ] Report confusing workflows
- [ ] Provide feedback on features

---

## FAQ

**Q: Can I test on both Android and iOS?**
A: Yes. APK works on Android; web version works on all platforms including iOS.

**Q: Will my test data be saved?**
A: Yes, calculations are saved locally. Use "Sync" or "Export" to back up data.

**Q: Can multiple people test simultaneously?**
A: Yes, but you should use different accounts (different email/username).

**Q: What if I find a bug?**
A: Report it using the template above with as much detail as possible.

**Q: How do I uninstall the app?**
A: Settings → Apps → TaxNG Advisor → Uninstall (for APK) or just close browser tab (for web).

**Q: Is my data secure during testing?**
A: Yes. The app uses encryption for sensitive data. However, test environment should not be used for real tax data.

---

## Support

For testing-related questions or issues:

- **Email:** jeekltd@gmail.com
- **Help in App:** Help → Contact Support
- **Documentation:** Help → Admin: User Testing Guide (this page)

Thank you for testing TaxNG Advisor!
