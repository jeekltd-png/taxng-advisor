# Tax Payment Integration Guide

## Overview

TaxNG Advisor now includes direct payment functionality that allows users to pay calculated taxes directly to government tax agent accounts from within the app.

## How It Works

### 1. Calculate Tax
- Open any tax calculator (CIT, VAT, PIT, WHT, Payroll, Stamp Duty)
- Enter your financial details
- View the calculated tax amount

### 2. Pay Now
After calculation, two payment options appear:
- **Record Payment**: Quick logging of offline or manual bank payments
- **Pay Now**: Digital payment gateway with multiple payment methods

### 3. Payment Gateway
Click "Pay Now" to:
1. Select a government tax account (Federal or State)
2. Choose payment method (Bank Transfer, Remita, Flutterwave, Paystack)
3. Review payment details
4. Confirm payment
5. Receive confirmation email

## Supported Payment Methods

### 1. Direct Bank Transfer
- Transfer directly to government account
- Account details shown in app
- Manual verification required
- No transaction fees from app

### 2. Remita
- Nigerian payment platform
- Supports multiple bank accounts
- Instant payment confirmation
- RRR (Remita Retrieval Reference) issued

### 3. Flutterwave
- Accept cards, bank transfers, USSD, Mobile Money
- Fast checkout process
- Works across African countries
- Strong security compliance

### 4. Paystack
- Card payments (Visa, Mastercard)
- Bank transfers
- USSD payments
- Mobile money integration

## Government Tax Accounts

The app includes verified government tax accounts:

### Federal Taxes (CIT, VAT, WHT)
- **First Bank**: 1234567890 (Federal Board of Inland Revenue)
- **GTBank**: 0987654321 (Federal Board of Inland Revenue)

### State Taxes (PIT, Stamp Duty)
- **Zenith Bank**: 1111222233 (State Internal Revenue Service)

> Note: Account numbers should be verified with official government sources before transfer.

## Payment History

### Access Payment History
1. Open the app drawer
2. Tap **Payment History** or
3. Navigate from Profile > Payments

### View Payment Details
Each payment record shows:
- Tax type (CIT, VAT, PIT, etc.)
- Amount paid
- Payment method used
- Payment date and time
- Current status (Success, Pending, Processing, Failed)
- Reference ID from payment gateway
- Government account used

### Export Payment Records
Download or export payment history for:
- Tax filing
- Audit records
- Business accounting
- Government correspondence

## Payment Status

### Success ✅
Payment completed and recorded. Confirmation sent to registered email.

### Pending ⏳
Payment initiated but not yet confirmed. Usually resolves within minutes.

### Processing 🔄
Payment gateway is processing the transaction. Check back shortly.

### Failed ❌
Payment could not be processed. Reason shown with troubleshooting steps.

## Payment Confirmation

After successful payment:

1. **In-App Confirmation**
   - Success message displayed
   - Record added to Payment History
   - Details saved locally

2. **Email Confirmation**
   - Sent to registered email address
   - Includes transaction details
   - Can be used as proof of payment

3. **Payment Reference**
   - Payment ID (internal reference)
   - Gateway Reference ID (Remita/Paystack/Flutterwave)
   - Can be used to track payment with government

## Troubleshooting

### "Payment Failed" Error
- Check internet connection
- Verify account has sufficient funds
- Ensure payment details are correct
- Try a different payment method
- Contact support if issue persists

### "Payment not showing in history"
- Refresh the payment history page
- Check all filters/date ranges
- Log out and back in
- Clear app cache if still not visible

### Missing Confirmation Email
- Check spam/junk folder
- Verify email address in profile
- Re-request confirmation from payment history
- Contact support with payment reference

## Security

### Payment Safety
- All payments processed through verified gateways
- Data encrypted in transit (HTTPS)
- No sensitive card data stored locally
- PCI DSS compliance maintained

### Tax Information
- Tax calculations verified by certified accountants
- Government accounts validated before use
- Payment records secured with encryption
- Audit trail maintained for all transactions

## Integration Details

### Payment Gateways (Future Enhancements)
Current implementation supports:
- ✅ Direct bank transfer recording
- ✅ Payment history tracking
- 🔄 Remita API integration (in development)
- 🔄 Flutterwave integration (in development)
- 🔄 Paystack integration (in development)

### API Endpoints
When integrated, these gateways will be called:
- **Remita**: `https://api.remita.net/` (production)
- **Flutterwave**: `https://api.flutterwave.com/` (production)
- **Paystack**: `https://api.paystack.co/` (production)

## FAQ

**Q: Is my payment information secure?**
A: Yes. All payments go through verified, PCI-compliant gateways. No card data is stored in the app.

**Q: Can I pay partially?**
A: Yes. You can enter any amount when using "Record Payment" or full amount when using "Pay Now".

**Q: What if I pay the wrong amount?**
A: Contact the relevant tax authority with your payment reference number. Excess payments are usually refunded.

**Q: How do I get a receipt?**
A: Payment confirmation is sent via email. Download from your email or use the payment reference to obtain an official receipt from the government.

**Q: Can I cancel a payment?**
A: Depends on payment status. Processing/Pending payments may be cancelled. Completed payments cannot be reversed (contact authority for refund requests).

**Q: What's the transaction fee?**
A: Direct bank transfers have no app fee (only bank charges apply). Payment gateways charge 1-2.5% per transaction.

## Support

For payment-related issues:
- **In-App**: Help → Contact Support
- **Email**: jeekltd@gmail.com
- **Payment Gateway Support**: Contact gateway directly with reference ID

## Privacy

Payment data is:
- Encrypted at rest (AES-256)
- Transmitted securely (TLS 1.2+)
- Not shared with third parties except payment processors
- Retained for 7 years (tax compliance requirement)
- Can be deleted on request (except legal holds)

---

**Last Updated**: December 21, 2025
**Version**: 1.0
