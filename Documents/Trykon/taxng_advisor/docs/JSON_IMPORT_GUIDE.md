# Sample JSON Data for TaxNG Advisor

This document provides example JSON data that you can copy and paste into the Profile screen to test the calculator import functionality.

## How to Import

1. Open the app and go to **Profile**
2. Scroll to "Import JSON data (paste or choose file)"
3. Copy one of the sample JSONs below
4. Paste into the text field
5. Click **Import**

---

## CIT (Corporate Income Tax) Sample

Use this for business tax calculations.

```json
{
  "type": "CIT",
  "year": 2024,
  "data": {
    "turnover": 50000000,
    "expenses": 15000000,
    "profit": 35000000,
    "businessName": "Acme LLC",
    "tin": "12345678901"
  }
}
```

**Fields:**
- `turnover`: Total business income (NGN)
- `expenses`: Total business expenses (NGN)
- `profit`: Net profit (turnover - expenses)
- `businessName`: Name of the business
- `tin`: Tax Identification Number

---

## VAT (Value Added Tax) Sample

Use this for quarterly or monthly VAT returns.

```json
{
  "type": "VAT",
  "year": 2024,
  "period": "Q4",
  "data": {
    "totalSales": 5000000,
    "taxableSales": 4500000,
    "exemptSales": 500000,
    "inputTax": 675000,
    "outputTax": 675000,
    "vat": 0
  }
}
```

**Fields:**
- `totalSales`: Total sales in the period
- `taxableSales`: Portion subject to VAT (7.5%)
- `exemptSales`: Portion exempt from VAT
- `inputTax`: VAT paid on purchases
- `outputTax`: VAT collected from customers
- `vat`: Net VAT payable (outputTax - inputTax)

---

## PIT (Personal Income Tax) Sample

Use this for individual tax calculations.

```json
{
  "type": "PIT",
  "year": 2024,
  "data": {
    "employeeId": "EMP001",
    "employeeName": "John Doe",
    "grossIncome": 3600000,
    "taxableIncome": 3000000,
    "personalRelief": 200000,
    "standardRelief": 300000,
    "pit": 600000
  }
}
```

**Fields:**
- `employeeId`: Unique employee identifier
- `employeeName`: Employee full name
- `grossIncome`: Total annual income (NGN)
- `taxableIncome`: Income after allowances
- `personalRelief`: Standard personal relief amount
- `standardRelief`: Additional standard relief
- `pit`: Calculated personal income tax

---

## WHT (Withholding Tax) Sample

Use this for contractor/vendor withholding tax.

```json
{
  "type": "WHT",
  "year": 2024,
  "data": {
    "paymentDescription": "Service provision",
    "grossAmount": 1000000,
    "whtRate": 0.05,
    "whtAmount": 50000,
    "beneficiary": "John Services Ltd",
    "tin": "87654321098"
  }
}
```

**Fields:**
- `paymentDescription`: Type of payment (e.g., consulting, services)
- `grossAmount`: Total payment before withholding (NGN)
- `whtRate`: Withholding tax rate (e.g., 0.05 = 5%)
- `whtAmount`: Calculated WHT amount
- `beneficiary`: Payee name or business
- `tin`: Tax ID of beneficiary

**Common WHT Rates:**
- Services: 5%
- Rent: 10%
- Contractor: 5%
- Dividends: 10%

---

## Payroll Sample

Use this for monthly or annual payroll tax calculations.

```json
{
  "type": "Payroll",
  "year": 2024,
  "month": "December",
  "data": {
    "employeeCount": 25,
    "totalGrossSalary": 10000000,
    "totalDeductions": 2500000,
    "totalPIT": 1500000,
    "totalNHF": 250000,
    "totalPENSION": 750000,
    "netPayroll": 7500000
  }
}
```

**Fields:**
- `employeeCount`: Number of employees
- `totalGrossSalary`: Total payroll before deductions
- `totalDeductions`: Sum of all employee deductions
- `totalPIT`: Personal income tax withheld
- `totalNHF`: National Housing Fund deductions
- `totalPENSION`: Pension contributions
- `netPayroll`: Amount paid to employees

---

## Stamp Duty Sample

Use this for property or transaction stamp duty.

```json
{
  "type": "StampDuty",
  "year": 2024,
  "data": {
    "transactionType": "Property Sale",
    "propertyAddress": "123 Lekki Lane, Lagos",
    "transactionValue": 50000000,
    "stampDutyRate": 0.015,
    "stampDutyAmount": 750000,
    "buyer": "Jane Smith",
    "seller": "Property Holdings Ltd"
  }
}
```

**Fields:**
- `transactionType`: Type of transaction (e.g., Property Sale, Deed)
- `propertyAddress`: Property location
- `transactionValue`: Transaction amount (NGN)
- `stampDutyRate`: Duty rate (e.g., 0.015 = 1.5%)
- `stampDutyAmount`: Calculated stamp duty
- `buyer`: Buyer name
- `seller`: Seller name/company

**Common Stamp Duty Rates:**
- Property sales: 1.5%
- Deeds: 0.5%
- Agreements: 0.1%

---

## Customizing Your Data

To use your own data:
1. Copy one of the samples above
2. Replace the field values with your actual figures
3. Keep the `type` field matching the calculator name
4. Paste into the Profile import field
5. Click Import

The calculator will prefill with your data and automatically compute the tax liability.

---

## Bulk Import Example

If you want to import multiple records, you can create a JSON array:

```json
[
  {
    "type": "CIT",
    "year": 2024,
    "data": { ... }
  },
  {
    "type": "VAT",
    "year": 2024,
    "data": { ... }
  }
]
```

(Bulk import is currently a single-record feature; multiple records will be processed sequentially.)
