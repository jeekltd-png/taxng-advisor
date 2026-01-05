# User Roles and Permissions

## Account Types

### 1. Regular User (Personal Account)
**Created via:** Registration with `isBusiness = false`

**Can access:**
- ✅ All Tax Calculators (VAT, PIT, CIT, WHT, Payroll, Stamp Duty)
- ✅ Calculate taxes for personal use
- ✅ Save calculation history
- ✅ View own payment history
- ✅ Set tax reminders
- ✅ Import/Export data (JSON, CSV, Excel)
- ✅ Profile management
- ✅ Help & FAQ
- ✅ Contact Support
- ✅ Sample data and guides

**Cannot access:**
- ❌ Admin documentation
- ❌ Pricing editor
- ❌ Test cases
- ❌ User management
- ❌ Other users' data

**Example use case:** 
- Individual taxpayer calculating personal income tax (PIT)
- Employee doing payroll calculations

---

### 2. Business Account
**Created via:** Registration with `isBusiness = true` + Business Name

**Can access:** Everything Regular User has, PLUS:
- ✅ All Tax Calculators (VAT, PIT, CIT, WHT, Payroll, Stamp Duty)
- ✅ Business-specific calculations (CIT for company income tax)
- ✅ Multiple employee payroll calculations
- ✅ Save business name and TIN
- ✅ Business tax history and records
- ✅ Bulk import for multiple employees/transactions
- ✅ Professional reports and receipts
- ✅ Payment tracking for business taxes

**Cannot access:**
- ❌ Admin documentation
- ❌ Pricing editor
- ❌ Test cases
- ❌ User management
- ❌ Other users' data

**Example use case:**
- Small business owner calculating CIT (Company Income Tax)
- HR manager doing payroll for 10+ employees
- Business accountant managing VAT returns

---

### 3. Admin Account
**Created via:** Seed data or manual database flag `isAdmin = true`

**Can access:** Everything, including:
- ✅ All features of Regular and Business accounts
- ✅ Admin documentation (Deployment Guide, User Testing, CSV/Excel Import)
- ✅ Pricing editor (modify subscription prices)
- ✅ Test cases and QA documentation
- ✅ Currency conversion settings
- ✅ Payment integration guide
- ✅ Debug users screen (in development mode)
- ✅ System-wide settings

**Default Admin Credentials:**
```
Username: admin
Password: Admin@123
Email: admin@example.com
```

**Example use case:**
- Developer managing the app
- System administrator
- Support team member

---

## Key Differences

| Feature | Regular User | Business Account | Admin |
|---------|-------------|------------------|-------|
| Tax Calculators | ✅ | ✅ | ✅ |
| Personal Use | ✅ | ✅ | ✅ |
| Business Name | ❌ | ✅ | ✅ |
| Business TIN | ❌ | ✅ | ✅ |
| Admin Docs | ❌ | ❌ | ✅ |
| Pricing Editor | ❌ | ❌ | ✅ |
| Test Cases | ❌ | ❌ | ✅ |
| User Management | ❌ | ❌ | ✅ |

---

## Production vs Development

### Production Build (Release)
- ❌ Debug button **HIDDEN** on login screen
- ❌ Cannot access `/debug/users` route
- ✅ Only legitimate login through username/password
- ✅ Clean user interface without developer tools

### Development Build (Debug)
- ✅ Debug button **VISIBLE** on login screen
- ✅ Can quickly seed test users
- ✅ Can view all registered users
- ✅ Quick login for testing

**How to check:**
The app uses `dart.vm.product` flag:
- In release builds (production): `dart.vm.product = true` → Debug button hidden
- In debug builds (development): `dart.vm.product = false` → Debug button visible

---

## Business Account Specific Features

When a user creates a Business Account, they can:

1. **Enter Business Details:**
   - Business Name (e.g., "Acme Ltd")
   - Tax Identification Number (TIN)
   - Business email

2. **Calculate Business Taxes:**
   - **CIT (Company Income Tax):** Calculate tax on company profits
   - **VAT:** Track input/output VAT for business transactions
   - **WHT (Withholding Tax):** Calculate tax to withhold from contractors
   - **Payroll:** Calculate PAYE for multiple employees
   - **Stamp Duty:** Calculate duty for business agreements

3. **Manage Multiple Records:**
   - Save calculations for different tax periods
   - Track payment history for the business
   - Generate reports for accountant/auditor

4. **Bulk Operations:**
   - Import employee data via CSV/Excel for payroll
   - Import multiple transactions for VAT
   - Export business tax records

5. **Professional Features:**
   - Business letterhead on reports (future feature)
   - Multi-year tax history
   - Tax reminders for filing deadlines

---

## Security Notes

- All users' data is isolated (users cannot see other users' calculations)
- Passwords are hashed using SHA-256
- Only Admin can access system-wide settings
- Email is used for password reset and payment confirmations
- Business accounts store additional data (business name, TIN) but have same privacy

---

## Future Enhancements

Possible additions for Business Accounts:
- Multi-user access (owner + accountant + HR)
- Role-based permissions within a business
- Tax consultant collaboration features
- Audit trail for all changes
- Integration with accounting software
