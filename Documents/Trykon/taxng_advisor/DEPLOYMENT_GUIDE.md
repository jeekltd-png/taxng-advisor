# TaxNG Advisor - Deployment Guide

## Build Status ✓
- **Web**: Ready at `build/web`
- **Android APK**: Ready at `dist/app-release.apk` (54 MB)
- **Android AAB**: Ready at `dist/app-release.aab` (44 MB, signed)
- **Keystore**: Generated and backed up

---

## Pre-Deployment Checklist

### 1. Credentials Backup ✓
- [x] Keystore backed up to `C:\Users\aipri\Documents\Trykon\keystore\BACKUP\`
- [x] Credentials documented in `CREDENTIALS_README.txt`
- [ ] Copy backup to external USB drive
- [ ] Upload encrypted backup to secure cloud storage
- [ ] Store credentials document in password manager

### 2. Code Quality ✓
- [x] `flutter analyze` completed (26 deprecation warnings - non-blocking)
- [x] App runs successfully on Chrome
- [x] Core library desugaring enabled for Android
- [ ] Optional: Update deprecated `withOpacity` calls
- [ ] Optional: Migrate Radio widget to RadioGroup

### 3. App Configuration
- [ ] Review app name in `pubspec.yaml` (currently: "taxng_advisor")
- [ ] Verify version number (currently: 1.0.0+1)
- [ ] Check package name (currently: "com.example.taxng_advisor")
  - **Action Required**: Change from "com.example.*" to your domain
  - Update in: `android/app/build.gradle.kts` line 23 (applicationId)

---

## Web Deployment

### Option 1: Static Hosting (Firebase, Netlify, Vercel)
1. Upload contents of `build/web/` to hosting provider
2. Configure hosting for single-page app (SPA):
   - All routes should serve `index.html`
3. Set up custom domain (optional)
4. Enable HTTPS

### Option 2: Self-Hosted
1. Copy `build/web/` to your web server
2. Configure web server (nginx/Apache) for SPA routing
3. Example nginx config:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

### Testing Web Build
Local server is running at: http://localhost:8000

---

## Android Deployment

### Direct APK Distribution (Beta Testing)
1. Share `dist/app-release.apk` with testers via:
   - Email attachment
   - Cloud storage link (Google Drive, Dropbox)
   - Direct file transfer

2. Tester Instructions:
   - On Android device: Settings → Security → Enable "Install unknown apps" for your file manager/browser
   - Download and open APK file
   - Tap "Install"
   - Launch "TaxNG Advisor"

3. Collect Feedback:
   - Device models and Android versions
   - Feature testing (calculators, payments, data import)
   - Bug reports with screenshots

### Google Play Console Deployment

#### First-Time Setup

1. **Create Developer Account**
   - Go to: https://play.google.com/console
   - Pay one-time $25 registration fee
   - Complete account verification

2. **Create App**
   - Click "Create app"
   - App name: TaxNG Advisor
   - Default language: English
   - App type: Application
   - Free or Paid: Free (or Paid if charging)

3. **App Signing (CRITICAL)**
   - Google Play will manage app signing
   - Upload AAB signed with your upload key (already done)
   - Google creates separate app signing key
   - Download and backup the certificate

4. **Store Listing**
   Required information:
   - App name: TaxNG Advisor
   - Short description (80 chars): "Nigeria Tax Act 2025 compliance calculator"
   - Full description: Explain features, tax types, payment gateway
   - Screenshots: Minimum 2, recommend 4-8
     - Capture VAT, CIT, PIT, Payroll calculators
     - Show payment gateway
     - Demonstrate data import
   - Feature graphic: 1024x500 px
   - App icon: 512x512 px (already have in `assets/icon.png`)
   - App category: Business or Finance
   - Contact email: [Your support email]
   - Privacy policy URL: **Required**

5. **Content Rating**
   - Complete questionnaire
   - Select "Business/Finance" category
   - Answer questions about content
   - Receive rating (likely "Everyone")

6. **Target Audience**
   - Age range: 18+
   - Appeal to children: No

7. **Privacy Policy**
   - **Required for apps handling user data**
   - Must include:
     - What data you collect
     - How you use it
     - Whether you share with third parties
     - How users can delete data
   - Host on your website or use a service
   - Add URL in Store Listing

8. **App Content**
   - Ads: Yes/No (declare if using ads)
   - In-app purchases: Yes/No (if selling subscriptions)
   - Content guidelines compliance

#### Upload AAB for Internal Testing

1. **Navigate to Internal Testing**
   - Left sidebar → Testing → Internal testing
   - Click "Create new release"

2. **Upload App Bundle**
   - Click "Upload"
   - Select: `dist/app-release.aab`
   - Wait for upload and processing
   - Google will analyze and show warnings/errors

3. **Release Notes**
   ```
   Version 1.0.0 - Initial Release
   - VAT, CIT, PIT, Payroll, WHT, Stamp Duty calculators
   - Payment gateway integration
   - Data import (JSON, CSV, Excel)
   - Currency conversion
   - Export to PDF
   ```

4. **Add Testers**
   - Create email list
   - Add tester emails (up to 100 for internal testing)
   - Testers receive invite email
   - They click link to opt-in and install

5. **Review and Rollout**
   - Review release details
   - Click "Start rollout to Internal testing"
   - Share opt-in URL with testers

#### Testing Period

- Internal testing: Unlimited time, up to 100 testers
- Closed testing: Unlimited testers, up to 90 days
- Open testing: Public, optional
- Collect feedback via:
  - Play Console feedback
  - Direct communication
  - Analytics

#### Production Release

1. **Complete All Required Sections**
   - Store listing ✓
   - Content rating ✓
   - Target audience ✓
   - Privacy policy ✓
   - Data safety ✓
   - App content ✓

2. **Review Release**
   - Check for policy violations
   - Verify screenshots and descriptions
   - Test on multiple devices

3. **Submit for Review**
   - Navigate to: Production → Releases
   - Create new release
   - Upload same AAB (or new version)
   - Add release notes
   - Submit for review

4. **Review Process**
   - Takes 1-7 days typically
   - Google reviews for policy compliance
   - May request changes
   - Approve or reject

5. **Go Live**
   - Once approved, choose rollout percentage:
     - Staged rollout: 1%, 5%, 10%, 20%, 50%, 100%
     - Full rollout: 100% immediately
   - App appears on Play Store within hours

---

## Post-Deployment

### Monitoring
- Google Play Console → Statistics
- Track:
  - Installs
  - Ratings and reviews
  - Crashes (check Play Console → Quality)
  - ANRs (App Not Responding)

### Updates
1. Increment version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```
2. Make code changes
3. Rebuild:
   ```bash
   flutter build appbundle --release
   ```
4. Upload new AAB to Play Console
5. Submit for review

### User Support
- Respond to reviews within 7 days
- Monitor crash reports
- Update privacy policy if data handling changes
- Keep compliance with Nigeria Data Protection laws

---

## Common Issues and Fixes

### Issue: "Keystore not found"
- Ensure `android/key.properties` exists
- Check paths are absolute (forward slashes)
- Verify keystore file exists at specified path

### Issue: Play Console rejects AAB
- Check package name isn't "com.example.*"
- Ensure version code increments with each upload
- Verify minimum SDK version compatibility

### Issue: App crashes on older Android versions
- Check `minSdk` in `android/app/build.gradle.kts`
- Test on Android 7.0+ devices
- Review desugaring configuration

### Issue: Web build doesn't load
- Check browser console for errors
- Verify hosting serves index.html for all routes
- Enable HTTPS if using secure features

---

## Support Contacts

- Flutter Issues: https://github.com/flutter/flutter/issues
- Play Console Help: https://support.google.com/googleplay/android-developer
- Firebase Support: https://firebase.google.com/support

---

## Next Steps

1. [ ] Back up keystore to external drive/cloud
2. [ ] Update package name from "com.example.*"
3. [ ] Create privacy policy
4. [ ] Prepare screenshots (4-8 images)
5. [ ] Write full app description
6. [ ] Set up Play Console account ($25)
7. [ ] Upload AAB to internal testing
8. [ ] Add 5-10 beta testers
9. [ ] Collect feedback for 1-2 weeks
10. [ ] Submit for production review

---

**Good luck with your deployment! 🚀**
