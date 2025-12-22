# CSV & Excel Import Guide

This guide shows how to prepare CSV and Excel files for importing tax data into TaxNG Advisor.

## CSV Format

CSV (Comma-Separated Values) is the easiest format to work with. You can create CSV files using:
- Microsoft Excel
- Google Sheets
- LibreOffice Calc
- Any text editor

### Import Steps

1. Open the app and go to **Profile**
2. Click **"Choose file"** and select a CSV file, OR
3. Paste CSV data directly into the import field
4. Click **"Import"**

The first row must contain column headers matching the field names below.

---

## CSV Formats by Tax Type

### CIT (Corporate Income Tax)

**Columns:** `type`, `year`, `turnover`, `expenses`, `profit`, `businessName`, `tin`

```csv
type,year,turnover,expenses,profit,businessName,tin
CIT,2024,50000000,15000000,35000000,Acme LLC,12345678901
CIT,2024,75000000,22000000,53000000,TechCorp Nigeria,98765432101
```

**Download:** [sample_cit_import.csv](../assets/help/sample_cit_import.csv)

---

### VAT (Value Added Tax)

**Columns:** `type`, `year`, `period`, `totalSales`, `taxableSales`, `exemptSales`, `inputTax`, `outputTax`, `vat`

```csv
type,year,period,totalSales,taxableSales,exemptSales,inputTax,outputTax,vat
VAT,2024,Q4,5000000,4500000,500000,675000,675000,0
VAT,2024,Q3,4200000,3800000,400000,570000,570000,0
```

**Download:** [sample_vat_import.csv](../assets/help/sample_vat_import.csv)

---

### PIT (Personal Income Tax)

**Columns:** `type`, `year`, `employeeId`, `employeeName`, `grossIncome`, `taxableIncome`, `personalRelief`, `standardRelief`, `pit`

```csv
type,year,employeeId,employeeName,grossIncome,taxableIncome,personalRelief,standardRelief,pit
PIT,2024,EMP001,John Doe,3600000,3000000,200000,300000,600000
PIT,2024,EMP002,Jane Smith,4200000,3500000,200000,300000,700000
```

**Download:** [sample_pit_import.csv](../assets/help/sample_pit_import.csv)

---

### WHT (Withholding Tax)

**Columns:** `type`, `year`, `paymentDescription`, `grossAmount`, `whtRate`, `whtAmount`, `beneficiary`, `tin`

```csv
type,year,paymentDescription,grossAmount,whtRate,whtAmount,beneficiary,tin
WHT,2024,Service provision,1000000,0.05,50000,John Services Ltd,87654321098
WHT,2024,Consulting fees,2500000,0.05,125000,Expert Consultants,11111111111
```

**Download:** [sample_wht_import.csv](../assets/help/sample_wht_import.csv)

---

### Payroll

**Columns:** `type`, `year`, `month`, `employeeCount`, `totalGrossSalary`, `totalDeductions`, `totalPIT`, `totalNHF`, `totalPENSION`, `netPayroll`

```csv
type,year,month,employeeCount,totalGrossSalary,totalDeductions,totalPIT,totalNHF,totalPENSION,netPayroll
Payroll,2024,December,25,10000000,2500000,1500000,250000,750000,7500000
Payroll,2024,November,25,10000000,2500000,1500000,250000,750000,7500000
```

**Download:** [sample_payroll_import.csv](../assets/help/sample_payroll_import.csv)

---

### Stamp Duty

**Columns:** `type`, `year`, `transactionType`, `propertyAddress`, `transactionValue`, `stampDutyRate`, `stampDutyAmount`, `buyer`, `seller`

```csv
type,year,transactionType,propertyAddress,transactionValue,stampDutyRate,stampDutyAmount,buyer,seller
StampDuty,2024,Property Sale,123 Lekki Lane Lagos,50000000,0.015,750000,Jane Smith,Property Holdings Ltd
StampDuty,2024,Deed Registration,789 Ikoyi Drive Lagos,35000000,0.015,525000,John Investor,Asset Management Ltd
```

**Download:** [sample_stamp_duty_import.csv](../assets/help/sample_stamp_duty_import.csv)

---

## Excel Format

### Using Excel to Import

1. **Create in Excel:** Use the CSV samples above as a template
2. **Save as:** File → Save As → Format: **CSV (Comma Delimited)**
3. **Import to app:** Choose the CSV file in Profile → Choose file

### Excel Sheets Setup

If your data is in Excel format, create worksheets with headers matching the CSV columns:

| Column 1 | Column 2 | Column 3 | ... |
|----------|----------|----------|-----|
| type | year | turnover | ... |
| CIT | 2024 | 50000000 | ... |

Then export as CSV and import into the app.

---

## Best Practices

✅ **Do:**
- Include header row with exact column names
- Use comma separators (not semicolons)
- Keep numbers without currency symbols (e.g., `50000000` not `₦50,000,000`)
- One record per row
- Use YYYY format for years (e.g., `2024`)
- Match exact column names from examples above

❌ **Don't:**
- Leave blank rows between data
- Use merged cells
- Change column order
- Use special characters in names
- Leave required fields empty

---

## Troubleshooting

**"Invalid JSON" error:**
- Verify all required columns are present
- Check for extra spaces in column headers
- Ensure numbers are not quoted

**Data not importing:**
- Verify the `type` field matches: CIT, VAT, PIT, WHT, Payroll, StampDuty
- Check for typos in column names
- Download a sample CSV and compare format

**Need help?**
- Go to Help → Contact Support
- Or check Sample Data screen for working examples

---

## Currency Conversion: Naira to USD & Pounds to USD

TaxNG Advisor automatically converts calculated tax amounts to USD for international reference. This feature is useful for:
- Comparing tax liabilities across countries
- International business reporting
- Multi-currency financial statements
- Cross-border compliance tracking

### How Currency Conversion Works

Each tax calculator displays your tax amount in three currencies:

1. **Nigerian Naira (₦)** - Original calculation amount
2. **USD from Naira** - Direct conversion from NGN to USD
3. **USD from Pounds (GBP)** - Alternative conversion reference

### Exchange Rates Used

The app uses these exchange rates (updated periodically):

| From | To | Rate |
|------|-----|------|
| Naira (₦) | USD (\$) | 0.00065 |
| Pounds (£) | USD (\$) | 1.27 |

**Note:** Exchange rates fluctuate. For critical financial decisions, verify rates with your bank or financial institution.

### Example Conversions

#### CIT Tax Conversion
```
Naira Amount:     ₦3,000,000
USD Equivalent:   $1,950 (from NGN)
GBP Equivalent:   £2,370,000 (if in Pounds)
USD from GBP:     $3,009.90
```

#### VAT Tax Conversion
```
Naira Amount:     ₦500,000
USD Equivalent:   $325 (from NGN)
GBP Equivalent:   £395,000 (if in Pounds)
USD from GBP:     $501.65
```

### Viewing Currency Conversions

In any tax calculator screen:

1. Calculate your tax normally (all amounts in NGN by default)
2. Look for the **"Show Conversion"** button on the tax payable card
3. Click to expand and see USD equivalents
4. Exchange rates and conversion dates are displayed

**Example Tax Result Screen:**
```
┌─────────────────────────────┐
│ CIT Payable: ₦3,000,000     │
│                             │
│ [Show Conversion] ▼         │
│                             │
│ Currency Conversion:        │
│ Equivalent in USD: $1,950   │
│ GBP Reference: £2,370,000   │
│ USD from GBP: $3,009.90     │
│                             │
│ Exchange Rates: 1 NGN = ... │
└─────────────────────────────┘
```

### Currency Conversion Cards

Some screens display a permanent conversion card showing all three currencies side-by-side:

**Example:**
```
Tax Amount Conversion
────────────────────
Amount (NGN):        ₦500,000
USD Equivalent:      $325
GBP Equivalent:      £395,000
USD (from GBP):      $501.65
────────────────────
📌 Exchange Rates: 1 NGN = $0.00065 | 1 GBP = $1.27
```

### Using Conversions for Reporting

#### For Annual Reports
Copy the USD equivalents from the conversion section and include in:
- Consolidated financial statements
- International audit reports
- Multi-currency tax filings

#### For Payment Planning
Use USD conversions to:
- Budget international tax obligations
- Plan foreign currency purchases
- Align payment schedules with exchange rate favorable periods

#### For Loan Applications
Banks often require USD equivalents:
1. Calculate tax in NGN
2. View USD equivalent from conversion
3. Include both in financial statements
4. Attach exchange rate proof for credibility

### Updating Exchange Rates

To adjust exchange rates based on current market conditions:

1. Go to **Settings** (when available in future updates)
2. Look for **Currency Settings**
3. Update exchange rates
4. Rates will automatically apply to future calculations

**For now:** Contact Support to request rate updates if rates have changed significantly.

### Important Notes

⚠️ **Exchange Rate Disclaimers:**
- Rates are provided for reference only
- Actual rates vary by bank and day
- Not suitable for real-time trading
- Always verify with your financial institution
- Different banks may offer different rates

✓ **Best Practices:**
- Update rates at least quarterly
- Document exchange rates used for compliance
- Keep conversion screenshots for audit trails
- Compare with your bank's rates regularly
- Use official CBN (Central Bank of Nigeria) rates for formal filings

---

## Batch Import

To import multiple records at once:
1. Create one CSV file with multiple rows
2. Paste all rows into the import field
3. Click Import
4. Each record will be processed and the calculator will open for the first one

Example (CIT batch):
```csv
type,year,turnover,expenses,profit,businessName,tin
CIT,2024,50000000,15000000,35000000,Company A,11111111111
CIT,2024,75000000,20000000,55000000,Company B,22222222222
CIT,2024,100000000,25000000,75000000,Company C,33333333333
```

**Download sample files from:** [assets/help/](../assets/help/)

---

## Troubleshooting

### Common Issues

**"Invalid CSV format"**
- ✓ Check that first row contains headers
- ✓ Ensure column names match exactly (case-sensitive)
- ✓ Verify no extra spaces in headers

**"Numbers not importing correctly"**
- ✓ Remove currency symbols (₦, $, £)
- ✓ Remove thousand separators (commas in numbers)
- ✓ Use whole numbers, not decimals for large amounts

**"Can't find the file"**
- ✓ File must be .csv or .json format
- ✓ Download sample file to verify format
- ✓ Check file is in Downloads folder

**"App crashes when importing"**
- ✓ Reduce number of rows (try 1-2 at first)
- ✓ Ensure all required columns are present
- ✓ Check for special characters in text fields

### File Format Tips

**Excel to CSV conversion:**
1. Open Excel file
2. File → Save As
3. Format: "CSV (Comma Delimited)"
4. Click Save
5. Click "Yes" when asked about losing formatting

**Google Sheets to CSV:**
1. File → Download → CSV
2. Open downloaded file in text editor to verify
3. Import into TaxNG Advisor

**Notepad CSV creation:**
1. Open Notepad
2. Type headers and data (comma-separated)
3. Save As "filename.csv" (not .txt)
4. Ensure "All Files" type is selected

---

## Need Help?

- **Sample Data:** Go to Help → Sample Data to see working examples
- **CSV Format Questions:** Check Help → Help Articles
- **Technical Issues:** Help → Contact Support
- **Download Samples:** [assets/help/ directory](../assets/help/)

**Download:** [sample_cit_import.csv](../assets/help/sample_cit_import.csv) | [sample_vat_import.csv](../assets/help/sample_vat_import.csv) | [sample_pit_import.csv](../assets/help/sample_pit_import.csv) | [sample_wht_import.csv](../assets/help/sample_wht_import.csv)
