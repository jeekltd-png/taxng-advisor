# Paystack Payment Integration Setup Guide

**Version:** 1.0.18+19  
**Date:** January 3, 2026

## Overview

The app now includes **Paystack integration** for processing subscription payments directly in-app. Users can upgrade their subscription tier and pay instantly via card, bank transfer, or USSD.

---

## 🚀 Quick Start

### 1. Get Your Paystack API Keys

1. **Sign up** at [https://paystack.com](https://paystack.com)
2. **Complete business verification** (required for live payments)
3. **Get API keys** from Settings → API Keys & Webhooks:
   - **Test Public Key:** `pk_test_xxxxxxxxxxxxxxxxxx` (for testing)
   - **Live Public Key:** `pk_live_xxxxxxxxxxxxxxxxxx` (for production)

### 2. Update API Key in Code

**File:** `lib/services/paystack_service.dart`

```dart
// Line 7: Replace with your actual Paystack public key
static const String _publicKey = 'pk_live_YOUR_ACTUAL_KEY_HERE';
```

**⚠️ IMPORTANT:**
- Use **TEST key** (`pk_test_...`) during development
- Use **LIVE key** (`pk_live_...`) for production builds
- **NEVER** commit live keys to git (add to .gitignore if needed)

### 3. Test the Integration

**Test Mode:**
1. Use test public key
2. Use Paystack test cards:
   - **Success:** `4084084084084081` (any CVV, any future expiry)
   - **Decline:** `5060666666666666` 
3. No actual money is charged

**Live Mode:**
1. Switch to live public key
2. Complete Paystack business verification
3. Real cards will be charged

---

## 📱 How It Works

### User Flow

1. **User views Pricing screen**
   - Sees Free, Basic (₦500), Pro (₦2K), Business (₦8K+)
   - Clicks "Upgrade Now"

2. **User selects tier**
   - Upgrade Request Screen shows available tiers
   - User selects desired tier
   - Sees price in button: "Pay ₦500 & Upgrade"

3. **Payment confirmation**
   - Dialog confirms price
   - User clicks "Pay Now"

4. **Paystack payment screen**
   - Native Paystack checkout opens
   - User enters card details OR selects bank transfer/USSD
   - Paystack processes payment securely

5. **Instant activation**
   - Payment verified automatically
   - User tier upgraded immediately
   - Success message shown
   - User can now access tier features

### Payment Methods Supported

- ✅ **Debit/Credit Cards** (Visa, Mastercard, Verve)
- ✅ **Bank Transfer** (instant confirmation)
- ✅ **USSD** (dial code to pay)
- ✅ **Mobile Money**
- ✅ **QR Code** (scan to pay)

---

## 💰 Pricing Configuration

### Current Tier Prices

Defined in `lib/services/paystack_service.dart`:

```dart
static double getTierPrice(String tierName) {
  switch (tierName.toLowerCase()) {
    case 'basic':
      return 500.0;    // ₦500/month
    case 'pro':
      return 2000.0;   // ₦2,000/month
    case 'business':
      return 8000.0;   // ₦8,000/month
    default:
      return 0.0;
  }
}
```

**To change prices:**
1. Update the values above
2. Also update `lib/services/pricing_service.dart` for UI consistency
3. Or use **Admin Pricing Editor** (Help → Admin: Pricing)

### Annual Plans (Optional)

Discount feature available:

```dart
// 20% discount for annual payment
static double calculateMonthlyPrice(String tierName, {bool isAnnual = false}) {
  final basePrice = getTierPrice(tierName);
  if (isAnnual) {
    return (basePrice * 12 * 0.8);  // Annual = 12 months - 20%
  }
  return basePrice;
}
```

---

## 🔒 Security

### Payment Processing

- **All payments processed by Paystack** (PCI-DSS compliant)
- **No card details stored** in app
- **SSL/TLS encrypted** communication
- **3D Secure authentication** for cards

### Payment Reference Format

```
TAXNG_{userId}_{timestamp}
Example: TAXNG_user123_1735934400000
```

This ensures:
- Unique per transaction
- Traceable to user
- No duplicates

### Payment Verification

**Current Implementation:**
```dart
// Auto-approves with valid payment reference
// TODO: Add backend verification for production
```

**⚠️ Production Requirement:**

You MUST implement backend verification:

```dart
// Your backend API call
final response = await http.get(
  Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
  headers: {'Authorization': 'Bearer YOUR_SECRET_KEY'},
);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  return data['data']['status'] == 'success';
}
```

**Why backend verification is critical:**
- Prevents payment fraud
- Validates amount matches tier price
- Confirms Paystack actually received payment
- Required for PCI compliance

---

## 🛠️ Technical Implementation

### Files Modified

1. **pubspec.yaml**
   - Added: `flutter_paystack: ^1.0.7`

2. **lib/services/paystack_service.dart** (NEW - 115 lines)
   - `initialize()` - Setup Paystack plugin
   - `processSubscriptionPayment()` - Handle payment flow
   - `verifyTransaction()` - Verify payment (needs backend)
   - `getTierPrice()` - Tier pricing

3. **lib/services/subscription_service.dart** (MODIFIED)
   - Added `paymentReference` parameter
   - Auto-approves if payment reference provided
   - Instantly upgrades tier after payment

4. **lib/features/subscription/upgrade_request_screen.dart** (MODIFIED)
   - Added payment confirmation dialog
   - Calls Paystack payment
   - Verifies transaction
   - Auto-upgrades on success

5. **lib/main.dart** (MODIFIED)
   - Added `PaystackService.initialize()` in startup

### Database Schema Update

**upgradeRequestsBox** now includes:
```dart
{
  'paymentReference': 'TAXNG_user123_1735934400000',
  'status': 'approved',  // Auto-approved for paid upgrades
  'processedBy': 'auto_payment',
}
```

---

## 🧪 Testing Guide

### Test Payment Flow

**Setup:**
1. Use test public key: `pk_test_...`
2. Build debug app: `flutter run`
3. Login as test user

**Test Cases:**

✅ **Successful Payment**
1. Go to Pricing → Upgrade Now
2. Select Pro tier
3. Click "Pay ₦2000 & Upgrade"
4. Confirm payment dialog
5. Use test card: `4084084084084081`
6. CVV: `408`, Expiry: any future date, PIN: `0000`
7. Verify: Success message shown
8. Check: User tier upgraded to Pro

✅ **Cancelled Payment**
1. Start upgrade flow
2. In Paystack screen, click Cancel
3. Verify: "Payment cancelled" message
4. Check: User tier unchanged

✅ **Failed Payment**
1. Use test card: `5060666666666666`
2. Verify: "Payment failed" message
3. Check: User tier unchanged

### Admin Testing

✅ **View Paid Upgrades**
1. Login as admin
2. Go to Help → Admin: Subscriptions
3. Check History tab
4. Verify: Paid upgrades show `processedBy: auto_payment`
5. Verify: Payment reference visible

---

## 📊 Payment Dashboard

### Paystack Dashboard Features

Access at [https://dashboard.paystack.com](https://dashboard.paystack.com)

**Transactions Tab:**
- View all payments
- Filter by status (success/failed)
- Export transaction reports
- Refund transactions

**Customers Tab:**
- See user payment history
- Track subscription payments
- View customer emails

**Reports:**
- Daily/monthly revenue
- Payment success rate
- Popular payment methods

**Webhooks:**
- Get real-time payment notifications
- Validate payments on your backend

---

## 🔄 Webhooks Setup (Recommended)

### Why Use Webhooks?

- **Real-time updates:** Know instantly when payment succeeds/fails
- **Better reliability:** Don't rely on app-side verification alone
- **Automatic reconciliation:** Match payments to users automatically

### Setup Steps

1. **Create webhook endpoint** on your backend:
   ```
   POST https://yourbackend.com/webhooks/paystack
   ```

2. **Add webhook URL** in Paystack Dashboard:
   - Settings → Webhooks
   - Enter your webhook URL
   - Enable events: `charge.success`, `charge.failed`

3. **Verify webhook signature:**
   ```dart
   final signature = request.headers['x-paystack-signature'];
   final hash = crypto.Hmac(crypto.sha512, utf8.encode(secretKey))
     .convert(utf8.encode(request.body)).toString();
   
   if (signature == hash) {
     // Valid webhook
   }
   ```

4. **Handle webhook events:**
   ```dart
   if (event == 'charge.success') {
     // Auto-approve subscription
     // Send confirmation email
   }
   ```

---

## 💸 Paystack Fees

**Transaction Fees:**
- Nigerian cards: **1.5% + ₦100** (capped at ₦2,000)
- International cards: **3.9% + ₦100**
- Bank transfers: **₦50 flat fee**

**Examples:**
- Basic (₦500): You receive **₦392.50** (₦107.50 fee)
- Pro (₦2,000): You receive **₦1,870** (₦130 fee)
- Business (₦8,000): You receive **₦5,880** (₦2,120 fee - capped)

**Settlement:**
- **T+1 settlement** (next business day)
- Funds sent to your bank account
- Settlement reports available in dashboard

---

## 🚨 Troubleshooting

### "Payment failed" error

**Causes:**
- User cancelled payment
- Card declined by bank
- Insufficient funds
- Test card in live mode (or vice versa)

**Fix:**
- Check Paystack dashboard for error details
- Verify using correct API key (test vs live)
- Try different payment method

### "Payment verification failed"

**Causes:**
- Backend verification not implemented
- Network timeout
- Invalid payment reference

**Fix:**
- Implement backend verification endpoint
- Check Paystack dashboard manually
- Contact Paystack support if persistent

### Payments not appearing in dashboard

**Causes:**
- Using test key (check Test mode toggle)
- Wrong Paystack account
- Webhook not configured

**Fix:**
- Toggle Test/Live mode in dashboard
- Verify API key matches account
- Check spam for Paystack emails

### User charged but tier not upgraded

**Causes:**
- App closed before verification
- Database write failed
- Network issue

**Fix:**
- Check upgradeRequestsBox in Hive
- Manually upgrade user tier in admin panel
- Refund if necessary via Paystack dashboard

---

## 📝 Production Checklist

Before going live:

### Required
- [ ] Switch to **live public key** in PaystackService
- [ ] Complete Paystack business verification
- [ ] Implement **backend payment verification**
- [ ] Setup webhook endpoint
- [ ] Test live payment with real card (small amount)
- [ ] Configure refund policy
- [ ] Update privacy policy (payment data handling)
- [ ] Add customer support email for payment issues

### Recommended
- [ ] Setup payment notifications/emails
- [ ] Create refund process documentation
- [ ] Monitor failed payments daily
- [ ] Setup revenue tracking
- [ ] A/B test pricing if needed
- [ ] Add payment receipt/invoice generation
- [ ] Implement subscription renewal reminders

### Legal
- [ ] Terms of Service (subscription terms)
- [ ] Refund policy
- [ ] Auto-renewal disclosure
- [ ] Data protection compliance

---

## 🆘 Support

### Paystack Support
- **Email:** support@paystack.com
- **Docs:** https://paystack.com/docs
- **Status:** https://status.paystack.com

### Common Issues

**"Invalid public key"**
- Check key format: `pk_test_` or `pk_live_`
- Verify copied correctly (no spaces)

**"Business not verified"**
- Complete KYC in Paystack dashboard
- Upload business documents
- Wait 24-48 hours for approval

**"Settlement delayed"**
- Check bank details in dashboard
- Verify account name matches business
- Contact Paystack support

---

## 📈 Next Steps

### Enhancements

1. **Subscription Management:**
   - Auto-renewal system
   - Downgrade option
   - Pause subscription

2. **Payment Features:**
   - Save card for future use
   - Multiple payment methods in one flow
   - Split payments for teams

3. **Analytics:**
   - Track conversion rate
   - Monitor failed payments
   - Revenue dashboards

4. **User Experience:**
   - Payment receipt via email
   - Invoice generation
   - Payment history screen

---

## 🔐 Security Best Practices

1. **Never expose secret key in app**
   - Keep on backend only
   - Use environment variables
   - Rotate keys regularly

2. **Always verify on backend**
   - Don't trust client-side verification
   - Validate amount matches tier
   - Check payment status directly with Paystack

3. **Handle failed payments gracefully**
   - Don't upgrade tier without payment
   - Log all payment attempts
   - Provide clear error messages

4. **Monitor for fraud**
   - Track unusual payment patterns
   - Limit payment retry attempts
   - Flag suspicious accounts

---

## 📞 Contact

For payment integration support or questions:
- Check Paystack documentation
- Review transaction logs in dashboard
- Contact Paystack merchant support

**Implementation Status:** ✅ Complete  
**Production Ready:** ⚠️ After backend verification added  
**Test Mode:** ✅ Ready to test now
