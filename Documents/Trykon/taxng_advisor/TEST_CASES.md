# TAXNG Advisor - Comprehensive Test Cases

## Test Documentation Overview
**App:** TAXNG Advisor - Nigeria Tax Act 2025 Compliance App  
**Version:** 1.0.0+1  
**Platform:** Android (Play Store Release)  
**Test Date:** December 30, 2025

---

## 1. FUNCTIONAL TEST CASES

### 1.1 Corporate Income Tax (CIT) Calculator

#### TC-CIT-001: Standard CIT Calculation
**Priority:** High  
**Pre-condition:** User is on CIT calculator screen  
**Test Steps:**
1. Enter Turnover: ₦100,000,000
2. Enter Assessable Profit: ₦20,000,000
3. Click "Calculate"

**Expected Result:**
- CIT Payable: ₦6,000,000 (30% of ₦20M)
- Effective Rate: 6%
- Display breakdown correctly
- Values formatted with currency symbol

**Test Data:**
- Valid turnover: ₦100,000,000
- Valid profit: ₦20,000,000
- Expected CIT: ₦6,000,000

---

#### TC-CIT-002: Small Company Education Tax Calculation
**Priority:** High  
**Test Steps:**
1. Enter Turnover: ₦100,000,000
2. Enter Assessable Profit: ₦20,000,000
3. Enable "Include Education Tax" checkbox
4. Click "Calculate"

**Expected Result:**
- CIT Payable: ₦6,000,000
- Education Tax: ₦600,000 (2% of ₦30M or 3% of ₦20M - verify rate)
- Total Tax: ₦6,600,000
- Breakdown shows both components

---

#### TC-CIT-003: Input Validation - Negative Values
**Priority:** High  
**Test Steps:**
1. Enter Turnover: -₦100,000
2. Attempt to calculate

**Expected Result:**
- Error message: "Turnover must be a positive value"
- Calculate button disabled or shows error
- No calculation performed

---

#### TC-CIT-004: Input Validation - Profit > Turnover
**Priority:** High  
**Test Steps:**
1. Enter Turnover: ₦10,000,000
2. Enter Profit: ₦20,000,000
3. Click "Calculate"

**Expected Result:**
- Error message: "Profit cannot exceed turnover"
- Calculation blocked
- User prompted to correct input

---

#### TC-CIT-005: Zero/Null Input Handling
**Priority:** Medium  
**Test Steps:**
1. Leave Turnover empty or enter 0
2. Enter Profit: ₦1,000,000
3. Click "Calculate"

**Expected Result:**
- Error message: "Please enter valid turnover"
- Calculation prevented
- Form highlights invalid field

---

### 1.2 Personal Income Tax (PIT) Calculator

#### TC-PIT-001: Basic PIT Calculation with Progressive Bands
**Priority:** High  
**Test Steps:**
1. Enter Gross Income: ₦5,000,000
2. Enter Other Deductions: ₦200,000
3. Click "Calculate"

**Expected Result:**
- Chargeable Income calculated correctly (₦5M - ₦200K - CRA)
- Tax calculated using progressive bands:
  - First ₦300K: 7%
  - Next ₦300K: 11%
  - Next ₦500K: 15%
  - Next ₦500K: 19%
  - Next ₦1.6M: 21%
  - Above ₦3.2M: 24%
- Total PIT displayed
- Breakdown by tax band shown
- Effective rate calculated

---

#### TC-PIT-002: Rent Relief Application
**Priority:** High  
**Test Steps:**
1. Enter Gross Income: ₦10,000,000
2. Enter Annual Rent Paid: ₦3,000,000
3. Click "Calculate"

**Expected Result:**
- Rent Relief: ₦500,000 (max 20% of ₦3M or max ₦500K cap)
- Chargeable income reduced by rent relief
- Relief amount clearly shown in breakdown
- Total PIT recalculated with relief

---

#### TC-PIT-003: Multiple Deductions
**Priority:** Medium  
**Test Steps:**
1. Enter Gross Income: ₦8,000,000
2. Enter Pension: ₦640,000
3. Enter NHF: ₦160,000
4. Enter Other Deductions: ₦300,000
5. Click "Calculate"

**Expected Result:**
- All deductions applied correctly
- Total deductions: ₦1,100,000
- Chargeable income = Gross - Deductions - CRA
- Tax calculated on reduced amount

---

#### TC-PIT-004: Edge Case - Low Income Below Tax Threshold
**Priority:** Medium  
**Test Steps:**
1. Enter Gross Income: ₦200,000 annually
2. Click "Calculate"

**Expected Result:**
- Tax payable: ₦0 or minimal amount
- CRA deduction may exceed taxable income
- Clear message if no tax due

---

### 1.3 Value Added Tax (VAT) Calculator

#### TC-VAT-001: Standard VAT Calculation
**Priority:** High  
**Test Steps:**
1. Add supply: Amount ₦10,000,000, Type: Standard (7.5%)
2. Enter Total Input VAT: ₦500,000
3. Click "Calculate"

**Expected Result:**
- Output VAT: ₦750,000 (7.5% of ₦10M)
- Recoverable Input VAT: ₦500,000
- Net VAT Payable: ₦250,000
- Breakdown clearly displayed

---

#### TC-VAT-002: Zero-Rated Supplies
**Priority:** High  
**Test Steps:**
1. Add supply: Amount ₦5,000,000, Type: Zero-Rated (0%)
2. Add supply: Amount ₦5,000,000, Type: Standard (7.5%)
3. Enter Input VAT: ₦600,000
4. Click "Calculate"

**Expected Result:**
- Output VAT: ₦375,000 (only on standard supplies)
- All input VAT recoverable: ₦600,000
- VAT Refundable: ₦225,000
- Correct classification of supplies

---

#### TC-VAT-003: Exempt Supplies Impact
**Priority:** Medium  
**Test Steps:**
1. Add supply: Amount ₦10,000,000, Type: Exempt
2. Enter Total Input VAT: ₦800,000
3. Enter Exempt Input VAT: ₦300,000
4. Click "Calculate"

**Expected Result:**
- Output VAT: ₦0 (exempt supplies)
- Recoverable Input: ₦500,000 (₦800K - ₦300K exempt)
- Exempt input VAT not recoverable
- Clear explanation shown

---

#### TC-VAT-004: Multiple Supplies Mixed Types
**Priority:** High  
**Test Steps:**
1. Add 3 supplies: Standard ₦10M, Zero-rated ₦5M, Exempt ₦2M
2. Enter Input VAT details
3. Calculate

**Expected Result:**
- Correct output VAT calculated per type
- Total sales: ₦17M
- Input VAT apportioned correctly
- Accurate net position (payable/refundable)

---

### 1.4 Withholding Tax (WHT) Calculator

#### TC-WHT-001: Dividend WHT Calculation
**Priority:** High  
**Test Steps:**
1. Select Type: Dividends
2. Enter Amount: ₦1,000,000
3. Click "Calculate"

**Expected Result:**
- WHT Rate: 10%
- WHT Amount: ₦100,000
- Net to Recipient: ₦900,000
- Rate automatically applied

---

#### TC-WHT-002: Professional Fees WHT
**Priority:** High  
**Test Steps:**
1. Select Type: Professional Fees
2. Enter Amount: ₦5,000,000
3. Calculate

**Expected Result:**
- WHT Rate: 10%
- WHT Amount: ₦500,000
- Net Payment: ₦4,500,000
- Description shows "Professional service fees"

---

#### TC-WHT-003: Construction Contracts (Reduced Rate)
**Priority:** Medium  
**Test Steps:**
1. Select Type: Construction
2. Enter Amount: ₦20,000,000
3. Calculate

**Expected Result:**
- WHT Rate: 5% (reduced rate)
- WHT Amount: ₦1,000,000
- Net Payment: ₦19,000,000
- Note about reduced rate displayed

---

#### TC-WHT-004: All WHT Types Coverage
**Priority:** Medium  
**Test Steps:**
Test each WHT type:
- Dividends (10%)
- Interest (10%)
- Rent (10%)
- Royalties (10%)
- Directors Fees (10%)
- Professional Fees (10%)
- Construction (5%)
- Contracts (5%)
- Other (10%)

**Expected Result:**
- Each type applies correct rate
- Description accurate for each type
- Calculations consistent

---

### 1.5 Stamp Duty Calculator

#### TC-SD-001: Property Transfer Stamp Duty
**Priority:** High  
**Test Steps:**
1. Select Type: Property Transfer
2. Enter Amount: ₦50,000,000
3. Calculate

**Expected Result:**
- Stamp Duty Rate applied correctly
- Duty amount calculated
- Transaction value shown
- Type-specific notes displayed

---

#### TC-SD-002: Multiple Transaction Types
**Priority:** Medium  
**Test Steps:**
Test all stamp duty types:
- Property Transfer
- Lease Agreements
- Share Transfers
- Loan Agreements
- Bills of Exchange
- Promissory Notes
- Powers of Attorney
- Contracts
- Other Instruments

**Expected Result:**
- Each type calculates correct duty
- Rates match regulations
- Clear descriptions provided

---

### 1.6 Payroll (PAYE) Calculator

#### TC-PAYROLL-001: Basic Monthly PAYE Calculation
**Priority:** High  
**Test Steps:**
1. Enter Monthly Gross: ₦500,000
2. Enter Pension Rate: 8%
3. Enter NHF Rate: 2%
4. Calculate

**Expected Result:**
- Monthly Pension: ₦40,000
- Monthly NHF: ₦10,000
- Monthly PAYE calculated using annual PIT rates
- Monthly Net Salary: Gross - PAYE - Deductions
- Annual projections shown

---

#### TC-PAYROLL-002: Custom Deductions
**Priority:** Medium  
**Test Steps:**
1. Enter Monthly Gross: ₦800,000
2. Add Other Deductions: ₦50,000
3. Set custom pension rate: 10%
4. Calculate

**Expected Result:**
- All deductions applied
- PAYE based on taxable income
- Net salary accurate
- Annual totals calculated correctly

---

#### TC-PAYROLL-003: High Earner Tax Band Test
**Priority:** Medium  
**Test Steps:**
1. Enter Monthly Gross: ₦5,000,000
2. Calculate with standard deductions

**Expected Result:**
- Annualized correctly (₦60M per year)
- Progressive tax bands applied
- Top marginal rate (24%) applied correctly
- Monthly PAYE = Annual PIT / 12

---

## 2. DATA PERSISTENCE TEST CASES

### TC-DATA-001: Save Calculation History
**Priority:** High  
**Test Steps:**
1. Perform CIT calculation
2. Navigate away from screen
3. Return to calculations history

**Expected Result:**
- Calculation saved to Hive database
- Historical record visible in history
- All calculation details preserved
- Timestamp recorded

---

### TC-DATA-002: Retrieve Recent Calculations
**Priority:** High  
**Test Steps:**
1. Perform multiple calculations (CIT, PIT, VAT)
2. Go to Dashboard
3. View recent calculations

**Expected Result:**
- All recent calculations listed
- Correct tax type labels
- Accurate amounts displayed
- Chronological order (newest first)

---

### TC-DATA-003: Delete Calculation Record
**Priority:** Medium  
**Test Steps:**
1. View calculation history
2. Select a record
3. Delete the record
4. Confirm deletion

**Expected Result:**
- Record removed from history
- Database updated
- UI refreshes without deleted item
- No errors or crashes

---

## 3. REMINDERS & NOTIFICATIONS

### TC-REM-001: Set Tax Deadline Reminder
**Priority:** High  
**Test Steps:**
1. Go to Reminders screen
2. Create new reminder: "CIT Filing Due" for Feb 1, 2026
3. Save reminder

**Expected Result:**
- Reminder created successfully
- Stored in Hive database
- Appears in reminders list
- Notification scheduled with OS

---

### TC-REM-002: Receive Notification at Due Date
**Priority:** High  
**Test Steps:**
1. Set reminder for near-future time (5 minutes ahead)
2. Wait for notification

**Expected Result:**
- Push notification received at scheduled time
- Notification shows reminder title
- Tapping opens app to reminders screen
- Sound/vibration as per device settings

---

### TC-REM-003: Edit Existing Reminder
**Priority:** Medium  
**Test Steps:**
1. Select existing reminder
2. Change date/description
3. Save changes

**Expected Result:**
- Reminder updated in database
- Old notification cancelled
- New notification scheduled
- UI reflects changes immediately

---

### TC-REM-004: Delete Reminder
**Priority:** Medium  
**Test Steps:**
1. Select reminder
2. Delete reminder
3. Confirm deletion

**Expected Result:**
- Reminder removed from list
- Notification cancelled in OS
- Database updated
- No orphaned notifications

---

## 4. PAYMENT GATEWAY TEST CASES

### TC-PAY-001: Navigate to Payment Screen
**Priority:** High  
**Test Steps:**
1. Complete a tax calculation (e.g., CIT)
2. Click "Pay Tax" button

**Expected Result:**
- Payment gateway screen opens
- Tax amount pre-filled
- Tax type displayed correctly
- Payment options shown

---

### TC-PAY-002: Select Payment Method - Bank Transfer
**Priority:** High  
**Test Steps:**
1. On payment screen, select Bank Transfer
2. View payment instructions

**Expected Result:**
- Correct government tax account displayed
- Account number, bank name shown
- Reference number generated
- Instructions clear and complete

---

### TC-PAY-003: Record Bank Transfer Payment
**Priority:** High  
**Test Steps:**
1. Select Bank Transfer
2. Enter bank details and reference
3. Mark as paid
4. Submit

**Expected Result:**
- Payment record saved
- Status: "Success" (or "Pending")
- Receipt/confirmation shown
- Record added to payment history

---

### TC-PAY-004: View Payment History
**Priority:** Medium  
**Test Steps:**
1. Go to Payment History
2. View list of past payments

**Expected Result:**
- All payments listed
- Tax type, amount, date shown
- Payment status visible
- Filter/search options work

---

### TC-PAY-005: Generate Payment Receipt
**Priority:** Medium  
**Test Steps:**
1. Select a completed payment
2. Click "Generate Receipt"

**Expected Result:**
- PDF receipt generated
- Contains payment details, date, reference
- Option to share/save/print
- Receipt properly formatted

---

### 4.6 Oil & Gas Sector - USD Currency Conversion

#### TC-PAY-OG-001: Oil & Gas Business Registration
**Priority:** High  
**Test Steps:**
1. Go to Login/Register screen
2. Enable "Register as business"
3. Enter business name
4. Select Industry Sector: "Oil and Gas / Petroleum (USD payments)"
5. Complete registration

**Expected Result:**
- Industry sector saved as 'oil_and_gas'
- User profile created with sector information
- Dashboard accessible
- Helper text shows "Oil & Gas sector payments will be in USD"

---

#### TC-PAY-OG-002: NGN to USD Conversion for Oil & Gas Payment
**Priority:** High  
**Pre-condition:** User is registered as Oil & Gas business  
**Test Steps:**
1. Complete CIT calculation with result: ₦1,000,000
2. Click "Record Payment"
3. Confirm payment amount
4. Submit payment

**Expected Result:**
- Original amount: ₦1,000,000 (NGN)
- Converted amount: $650.00 (USD) using rate 0.00065
- Payment record saved with USD as currency
- Both amounts stored in database
- Email confirmation shows conversion:
  ```
  Original Amount: ₦1,000,000.00 (NGN)
  Converted to:    $650.00 (USD)
  Conversion Note: Oil & Gas sector payments are processed in USD
  ```

**Test Data:**
- NGN to USD rate: 0.00065
- Expected: ₦1,000,000 × 0.00065 = $650.00

---

#### TC-PAY-OG-003: GBP to USD Conversion for Oil & Gas Payment
**Priority:** Medium  
**Pre-condition:** User is registered as Oil & Gas business  
**Test Steps:**
1. Calculate tax in GBP (if currency option available)
2. Amount: £1,000
3. Process payment

**Expected Result:**
- Original amount: £1,000.00 (GBP)
- Converted amount: $1,270.00 (USD) using rate 1.27
- Payment currency: USD
- Conversion details in confirmation email
- Database stores both original and converted amounts

**Test Data:**
- GBP to USD rate: 1.27
- Expected: £1,000 × 1.27 = $1,270.00

---

#### TC-PAY-OG-004: Regular Business Stays in NGN
**Priority:** High  
**Test Steps:**
1. Register as business without selecting oil & gas sector
2. Or select different sector (Manufacturing, Technology, etc.)
3. Complete any tax calculation: ₦1,000,000
4. Process payment

**Expected Result:**
- Payment amount: ₦1,000,000 (NGN)
- No currency conversion applied
- Payment currency: NGN
- Email shows only NGN amount
- No conversion note in confirmation

---

#### TC-PAY-OG-005: Multiple Payments - Mixed Currency History
**Priority:** Medium  
**Pre-condition:** Oil & Gas business with multiple payments  
**Test Steps:**
1. Make 3 payments for different tax types
2. View Payment History
3. Review all payment records

**Expected Result:**
- All payments show USD amounts
- Original NGN amounts visible in details
- Payment history filterable
- Currency clearly labeled (USD)
- Total paid calculated in USD

---

#### TC-PAY-OG-006: Verify All Tax Types Use USD Conversion
**Priority:** High  
**Pre-condition:** Registered as Oil & Gas business  
**Test Steps:**
Test payment for each tax type:
1. CIT: ₦10,000,000 → $6,500
2. VAT: ₦2,000,000 → $1,300
3. PIT: ₦500,000 → $325
4. WHT: ₦1,000,000 → $650
5. Payroll: ₦3,000,000 → $1,950
6. Stamp Duty: ₦5,000,000 → $3,250

**Expected Result:**
- Each payment automatically converted to USD
- Conversion rate consistent (0.00065)
- All calculators handle conversion
- Email confirmations show conversion for all types
- Payment history shows all in USD

---

#### TC-PAY-OG-007: Large Amount Conversion Accuracy
**Priority:** Medium  
**Test Steps:**
1. Oil & Gas business calculates CIT: ₦500,000,000
2. Process payment

**Expected Result:**
- Original: ₦500,000,000.00
- Converted: $325,000.00 (500M × 0.00065)
- No rounding errors
- Decimal precision maintained (2 places)
- Email formatting handles large numbers

---

#### TC-PAY-OG-008: Currency Symbol Display
**Priority:** Low  
**Test Steps:**
1. As Oil & Gas business, view payment confirmation
2. Check email and payment history

**Expected Result:**
- USD amounts show $ symbol
- NGN amounts show ₦ symbol
- Symbols positioned correctly (prefix)
- Email shows: "Currency: US Dollars (USD)"
- Consistent formatting throughout

---

## 5. USER AUTHENTICATION & PROFILE

### TC-AUTH-001: First Time App Launch
**Priority:** High  
**Test Steps:**
1. Fresh install app
2. Launch app

**Expected Result:**
- Welcome screen or onboarding shown
- Option to create profile
- Privacy policy acceptance
- Smooth navigation to main app

---

### TC-AUTH-002: Create User Profile
**Priority:** Medium  
**Test Steps:**
1. Go to Profile screen
2. Enter user details (name, email, TIN)
3. Save profile

**Expected Result:**
- Profile saved to secure storage
- Details displayed in profile screen
- TIN validated if applicable
- Success confirmation shown

---

#### TC-AUTH-004: Business Profile with Industry Sector
**Priority:** High  
**Test Steps:**
1. Create business account during registration
2. Select industry sector from dropdown
3. View available sectors:
   - Oil and Gas / Petroleum (USD payments)
   - Manufacturing
   - Technology
   - Finance / Banking
   - Retail / Trading
   - Professional Services
   - Other
4. Complete profile

**Expected Result:**
- Industry sector saved with profile
- Oil & Gas selection triggers USD payment mode
- Other sectors use default NGN
- Sector visible in profile view
- Can be used for reporting/filtering

---

### TC-AUTH-003: Edit User Profile
**Priority:** Low  
**Test Steps:**
1. View profile
2. Edit details
3. Save changes

**Expected Result:**
- Changes saved successfully
- Updated details displayed
- Secure storage updated
- No data loss

---

## 6. HELP & DOCUMENTATION

### TC-HELP-001: Access FAQ Section
**Priority:** Medium  
**Test Steps:**
1. Navigate to Help screen
2. Select FAQ

**Expected Result:**
- FAQ list loads from assets/help/faq.json
- Questions clearly organized
- Answers displayed when tapped
- Search functionality works (if available)

---

### TC-HELP-002: View Import Guides
**Priority:** Medium  
**Test Steps:**
1. Go to Help → Import Guides
2. Select CIT Import Guide

**Expected Result:**
- Guide loads correctly
- CSV/JSON sample files accessible
- Clear instructions provided
- Sample data downloadable

---

### TC-HELP-003: Currency Conversion Settings
**Priority:** Low  
**Test Steps:**
1. Go to Help → Currency Conversion Admin
2. View/update exchange rates

**Expected Result:**
- Current rates displayed (USD, GBP, EUR)
- Admin can update rates
- Changes apply app-wide
- Currency converter uses new rates

---

## 7. DATA IMPORT/EXPORT

### TC-IMPORT-001: Import CIT Data from CSV
**Priority:** Medium  
**Test Steps:**
1. Go to CIT screen
2. Select "Import" option
3. Choose sample_cit_import.csv
4. Import

**Expected Result:**
- CSV parsed correctly
- Data populated in calculator fields
- Validation performed
- Calculation auto-triggered or ready

---

### TC-IMPORT-002: Import from JSON
**Priority:** Medium  
**Test Steps:**
1. Select tax type (PIT, VAT, WHT, etc.)
2. Import corresponding JSON file
3. Verify import

**Expected Result:**
- JSON structure validated
- Fields mapped correctly
- Data loaded successfully
- Error handling for invalid JSON

---

### TC-EXPORT-001: Export Calculation to PDF
**Priority:** High  
**Test Steps:**
1. Complete a calculation
2. Click "Export to PDF"

**Expected Result:**
- PDF generated with calculation details
- Includes breakdown, totals, timestamp
- Properly formatted with app branding
- Option to save/share

---

### TC-EXPORT-002: Export History to Excel/CSV
**Priority:** Medium  
**Test Steps:**
1. Go to History
2. Select "Export All"
3. Choose format (CSV)

**Expected Result:**
- All calculations exported
- CSV properly formatted
- Headers included
- File saved successfully

---

## 8. UI/UX TEST CASES

### TC-UI-001: Navigation Between Screens
**Priority:** High  
**Test Steps:**
1. Navigate through all main screens:
   - Dashboard
   - CIT, PIT, VAT, WHT, Payroll, Stamp Duty
   - Payment
   - Reminders
   - Profile
   - Help

**Expected Result:**
- Smooth transitions
- Back button works correctly
- No screen freezes
- Consistent navigation patterns

---

### TC-UI-002: Responsive Layout - Portrait/Landscape
**Priority:** Medium  
**Test Steps:**
1. Rotate device between portrait and landscape
2. Test on different screens

**Expected Result:**
- Layout adapts properly
- No UI elements cut off
- Text readable in both orientations
- Form fields accessible

---

### TC-UI-003: Dark Mode Support (if implemented)
**Priority:** Low  
**Test Steps:**
1. Enable dark mode in device settings
2. Launch app

**Expected Result:**
- App respects system theme
- Colors adjusted for dark mode
- Text remains readable
- Consistent design

---

### TC-UI-004: Accessibility - Screen Reader
**Priority:** Medium  
**Test Steps:**
1. Enable TalkBack/Screen Reader
2. Navigate app

**Expected Result:**
- All buttons/fields have labels
- Navigation announced clearly
- Forms accessible
- Calculation results readable

---

### TC-UI-005: Form Input Validation UI Feedback
**Priority:** High  
**Test Steps:**
1. On any calculator, enter invalid data
2. Observe UI feedback

**Expected Result:**
- Real-time validation
- Error messages clear and helpful
- Invalid fields highlighted (red border)
- Correct fields marked (green checkmark)

---

## 9. PERFORMANCE TEST CASES

### TC-PERF-001: App Launch Time
**Priority:** Medium  
**Test Steps:**
1. Close app completely
2. Launch app and time until fully loaded

**Expected Result:**
- App launches within 3 seconds (cold start)
- Splash screen shows briefly
- Main screen loads smoothly
- No ANR (Application Not Responding)

---

### TC-PERF-002: Calculation Speed
**Priority:** High  
**Test Steps:**
1. Enter complex calculation (e.g., VAT with 20 supplies)
2. Click Calculate
3. Measure response time

**Expected Result:**
- Calculation completes within 500ms
- UI remains responsive
- Results display immediately
- No lag or freeze

---

### TC-PERF-003: Large Dataset Handling
**Priority:** Medium  
**Test Steps:**
1. Load 100+ calculation records in history
2. Scroll through list

**Expected Result:**
- Smooth scrolling
- No memory issues
- Lazy loading if implemented
- App remains stable

---

### TC-PERF-004: Database Query Performance
**Priority:** Medium  
**Test Steps:**
1. Store 500+ calculations
2. Query recent calculations
3. Search/filter history

**Expected Result:**
- Queries complete quickly (<1 second)
- No UI blocking
- Efficient Hive database operations
- Pagination if needed

---

## 10. ERROR HANDLING & EDGE CASES

### TC-ERROR-001: Network Unavailable (if app uses internet)
**Priority:** Medium  
**Test Steps:**
1. Disable internet connection
2. Attempt online feature (if any)

**Expected Result:**
- Graceful error message
- Offline mode notification
- Core features still work
- No app crash

---

### TC-ERROR-002: Database Corruption Recovery
**Priority:** Low  
**Test Steps:**
1. Simulate corrupted Hive database
2. Launch app

**Expected Result:**
- App detects corruption
- Attempts recovery or reset
- User notified appropriately
- No data loss of critical info (if backed up)

---

### TC-ERROR-003: Invalid Date Input
**Priority:** Medium  
**Test Steps:**
1. In reminder, enter date in past
2. Attempt to save

**Expected Result:**
- Validation error shown
- Message: "Date must be in the future"
- Reminder not created
- User prompted to correct

---

### TC-ERROR-004: Memory Pressure - Large PDF Generation
**Priority:** Low  
**Test Steps:**
1. Generate very large report/PDF
2. Monitor memory usage

**Expected Result:**
- App handles memory efficiently
- PDF generated successfully
- No out-of-memory errors
- Graceful degradation if file too large

---

### TC-ERROR-005: Concurrent Calculations
**Priority:** Low  
**Test Steps:**
1. Rapidly switch between calculators
2. Start calculations without completing previous

**Expected Result:**
- Each calculator maintains state
- No data mixing between types
- Results accurate for each
- No race conditions

---

## 11. SECURITY TEST CASES

### TC-SEC-001: Secure Storage of Sensitive Data
**Priority:** High  
**Test Steps:**
1. Save user profile with TIN
2. Check device storage

**Expected Result:**
- TIN stored in flutter_secure_storage
- Encrypted at rest
- Not accessible via file browser
- Proper key management

---

### TC-SEC-002: Data Privacy - No Unauthorized Access
**Priority:** High  
**Test Steps:**
1. Store tax calculations
2. Attempt to access via external tools

**Expected Result:**
- Hive database encrypted/protected
- Data not readable externally
- No plain text sensitive info
- App sandbox respected

---

### TC-SEC-003: Input Sanitization
**Priority:** Medium  
**Test Steps:**
1. Enter special characters in text fields
2. Attempt SQL injection-like inputs (if any DB queries)

**Expected Result:**
- Invalid characters rejected or escaped
- No code execution
- Safe error handling
- Input validation prevents attacks

---

## 12. COMPATIBILITY TEST CASES

### TC-COMPAT-001: Android Version Compatibility
**Priority:** High  
**Test Steps:**
1. Test on Android 10, 11, 12, 13, 14
2. Verify all features work

**Expected Result:**
- App installs on all supported versions
- Features work consistently
- UI renders correctly
- No version-specific bugs

---

### TC-COMPAT-002: Device Screen Size Compatibility
**Priority:** High  
**Test Steps:**
1. Test on phones: 5", 6", 6.5"
2. Test on tablets: 7", 10"
3. Test foldable devices (if available)

**Expected Result:**
- UI scales appropriately
- Touch targets adequate size
- Text readable on all sizes
- No overflow or clipping

---

### TC-COMPAT-003: Device Manufacturer Testing
**Priority:** Medium  
**Test Steps:**
Test on devices from:
- Samsung
- Xiaomi
- Tecno/Infinix (popular in Nigeria)
- Google Pixel

**Expected Result:**
- Consistent behavior across brands
- No manufacturer-specific bugs
- UI renders as expected
- Notifications work uniformly

---

## 13. REGRESSION TEST CASES

### TC-REG-001: Core Calculations After Update
**Priority:** High  
**Test Steps:**
After any app update:
1. Re-run TC-CIT-001, TC-PIT-001, TC-VAT-001, TC-WHT-001
2. Verify results unchanged

**Expected Result:**
- All calculations produce same results
- No regression in core features
- Formulas intact
- Data integrity maintained

---

### TC-REG-002: Data Migration After Update
**Priority:** High  
**Test Steps:**
1. Have existing data in v1.0.0
2. Update to v1.0.1 (or newer)
3. Verify data accessible

**Expected Result:**
- Old calculations still accessible
- Database schema migrated if needed
- No data loss
- App functions normally

---

## 14. LOCALIZATION TEST CASES (Future)

### TC-LOC-001: Currency Display
**Priority:** Medium  
**Test Steps:**
1. Check all currency displays use ₦ symbol
2. Verify Nigerian Naira formatting

**Expected Result:**
- Consistent use of ₦
- Proper thousand separators (commas)
- Decimal places (2 for currency)
- K/M notation for large amounts

---

### TC-LOC-002: Date Format
**Priority:** Low  
**Test Steps:**
1. Check date displays across app

**Expected Result:**
- Consistent date format (DD/MM/YYYY or as per locale)
- Readable format in reminders
- Proper timezone handling

---

## 15. ACCEPTANCE TEST CASES

### TC-ACC-001: End-to-End User Journey - CIT Filing
**Priority:** High  
**Test Steps:**
1. User opens app
2. Navigates to CIT calculator
3. Enters company financial data
4. Calculates CIT
5. Reviews breakdown
6. Proceeds to payment
7. Completes payment
8. Sets reminder for next filing
9. Views payment receipt

**Expected Result:**
- Complete journey smooth and intuitive
- All features work together
- Data flows correctly between screens
- User achieves goal (tax calculation & payment)

---

### TC-ACC-002: Multi-Tax Scenario
**Priority:** Medium  
**Test Steps:**
1. User calculates CIT for company
2. Calculates PIT for director salary
3. Calculates WHT on dividends
4. Reviews all in dashboard
5. Exports summary report

**Expected Result:**
- User can manage multiple tax types
- Dashboard shows all calculations
- Export includes all data
- Intuitive workflow

---

## 16. PLAY STORE SPECIFIC TEST CASES

### TC-PS-001: Install from Play Store (Internal Testing)
**Priority:** High  
**Test Steps:**
1. Access internal testing link
2. Install app from Play Store
3. Launch app

**Expected Result:**
- Download completes successfully
- Installation smooth
- App launches without errors
- Version matches uploaded AAB

---

### TC-PS-002: App Update Process
**Priority:** Medium  
**Test Steps:**
1. Have v1.0.0 installed
2. Upload v1.0.1 to Play Store
3. Update app

**Expected Result:**
- Update notification received
- Update installs successfully
- Data preserved after update
- App works normally

---

### TC-PS-003: In-App Review Prompt (if implemented)
**Priority:** Low  
**Test Steps:**
1. Use app for specified trigger condition
2. Check for review prompt

**Expected Result:**
- Prompt appears at appropriate time
- Not intrusive
- User can rate or dismiss
- Follows Play Store guidelines

---

## 17. DEFECT CATEGORIES

### Priority Levels:
- **Critical:** App crash, data loss, security breach
- **High:** Core feature broken, incorrect calculations
- **Medium:** Minor feature issues, UI glitches
- **Low:** Cosmetic issues, minor text errors

### Severity Levels:
- **Blocker:** Prevents testing, release
- **Major:** Significantly impacts user experience
- **Minor:** Small inconvenience
- **Trivial:** No real impact

---

## 18. TEST EXECUTION CHECKLIST

### Pre-Testing Setup:
- [ ] Install latest AAB build
- [ ] Clear app data for fresh start tests
- [ ] Prepare test devices (Android 10-14)
- [ ] Prepare test data (CSV, JSON samples)
- [ ] Setup test user profiles

### Testing Environment:
- [ ] Test on Wi-Fi and mobile data
- [ ] Test in various network conditions
- [ ] Test with different device battery levels
- [ ] Test with storage nearly full

### Post-Testing:
- [ ] Document all defects found
- [ ] Create bug reports with screenshots
- [ ] Verify fixes in next build
- [ ] Update test cases based on findings

---

## 19. AUTOMATED TESTING NOTES

### Unit Tests Required:
- Tax calculators (CIT, PIT, VAT, WHT, Payroll, Stamp Duty)
- Validators (TaxValidator methods)
- Currency formatters
- Date utilities

### Integration Tests Required:
- Calculator + Storage service
- Reminder service + Notifications
- Payment flow end-to-end
- Import/Export functionality

### Widget Tests Required:
- Calculator screens
- Form validation
- Button interactions
- Navigation flows

---

## 20. TEST REPORTING TEMPLATE

### Bug Report Format:
```
Bug ID: BUG-XXX
Title: [Brief description]
Priority: [Critical/High/Medium/Low]
Severity: [Blocker/Major/Minor/Trivial]
Module: [CIT/PIT/VAT/WHT/Payroll/StampDuty/Payment/Other]

Steps to Reproduce:
1. 
2. 
3. 

Expected Result:
[What should happen]

Actual Result:
[What actually happened]

Environment:
- Device: [Model]
- Android Version: [X.X]
- App Version: [1.0.0]
- Build: [release/debug]

Screenshots/Videos:
[Attach evidence]

Additional Notes:
[Any other relevant info]
```

---

## TEST COVERAGE SUMMARY

### Modules Covered:
- ✅ CIT Calculator (5 test cases)
- ✅ PIT Calculator (4 test cases)
- ✅ VAT Calculator (4 test cases)
- ✅ WHT Calculator (4 test cases)
- ✅ Stamp Duty Calculator (2 test cases)
- ✅ Payroll Calculator (3 test cases)
- ✅ Data Persistence (3 test cases)
- ✅ Reminders & Notifications (4 test cases)
- ✅ Payment Gateway (5 test cases)
- ✅ Oil & Gas USD Conversion (8 test cases)
- ✅ User Authentication (4 test cases)
- ✅ Help & Documentation (3 test cases)
- ✅ Data Import/Export (3 test cases)
- ✅ UI/UX (5 test cases)
- ✅ Performance (4 test cases)
- ✅ Error Handling (5 test cases)
- ✅ Security (3 test cases)
- ✅ Compatibility (3 test cases)
- ✅ Regression (2 test cases)
- ✅ Acceptance (2 test cases)
- ✅ Play Store (3 test cases)

**Total Test Cases: 79+**

---

## CONCLUSION

This comprehensive test plan covers all critical aspects of the TAXNG Advisor app. Execute these tests in phases:

1. **Phase 1 - Critical:** All High priority functional tests
2. **Phase 2 - Core:** Medium priority tests + End-to-end flows
3. **Phase 3 - Polish:** Low priority tests + Edge cases
4. **Phase 4 - Pre-Launch:** Play Store specific tests + Final regression

**Recommendation:** Execute at minimum all HIGH priority tests before public release. Medium priority tests should be completed for internal testing phase.

---

**Last Updated:** January 2, 2026  
**Test Plan Version:** 1.1  
**App Version:** 1.0.16+17  
**New Features:** Oil & Gas sector USD payment conversion
