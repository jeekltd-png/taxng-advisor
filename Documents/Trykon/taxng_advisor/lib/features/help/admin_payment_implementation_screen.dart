import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Admin-only screen for payment implementation details
class AdminPaymentImplementationScreen extends StatefulWidget {
  const AdminPaymentImplementationScreen({Key? key}) : super(key: key);

  @override
  State<AdminPaymentImplementationScreen> createState() =>
      _AdminPaymentImplementationScreenState();
}

class _AdminPaymentImplementationScreenState
    extends State<AdminPaymentImplementationScreen> {
  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final currentUser = await AuthService.currentUser();
    if (currentUser == null || !currentUser.isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin access required'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Implementation Guide'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('💳 Bank Transfer Implementation'),
            const SizedBox(height: 12),
            _buildSubHeader('How Bank Transfer Works'),
            const SizedBox(height: 8),
            _buildInfoCard(
              'Virtual Account System',
              'Paystack automatically generates a unique virtual bank account '
                  'number for each transaction. The customer transfers money to this '
                  'account, and Paystack notifies your app when payment is received.',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Payment Flow'),
            const SizedBox(height: 8),
            _buildNumberedList([
              'User clicks "Upgrade to Individual Plan (₦3,000/month)"',
              'App calls Paystack API to initialize transaction',
              'Paystack generates unique virtual account number valid for 24 hours',
              'User sees account details:\n  - Bank: Wema Bank, Providus Bank, or GTBank\n  - Account Number: 1234567890 (unique per transaction)\n  - Account Name: TaxPadi - [User Name]\n  - Amount: ₦3,000\n  - Valid Until: Jan 15, 2026 11:59 PM',
              'User opens their banking app or visits bank branch',
              'User transfers ₦3,000 to the virtual account number',
              'Paystack receives payment and verifies amount',
              'Paystack sends webhook notification to your server',
              'Your app receives webhook and updates user subscription',
              'User account immediately upgraded to Individual tier',
              'Confirmation email sent with receipt',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('🔧 Technical Implementation'),
            const SizedBox(height: 12),
            _buildSubHeader('Step 1: Setup Paystack Account'),
            const SizedBox(height: 8),
            _buildNumberedList([
              'Sign up at https://paystack.com',
              'Complete business verification (CAC documents)',
              'Get API keys from Settings → API Keys & Webhooks',
              'Copy Public Key and Secret Key',
              'Set webhook URL: https://your-domain.com/api/paystack/webhook',
            ]),
            const SizedBox(height: 12),
            _buildInfoCard(
              'API Keys',
              'Test Mode:\n'
                  '  • Public: pk_test_xxxxx\n'
                  '  • Secret: sk_test_xxxxx\n\n'
                  'Live Mode:\n'
                  '  • Public: pk_live_xxxxx\n'
                  '  • Secret: sk_live_xxxxx\n\n'
                  '⚠️ Never expose secret key in frontend code!',
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Step 2: Initialize Bank Transfer Payment'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// 1. User clicks "Pay via Bank Transfer"\n'
              '// 2. Call your backend API\n\n'
              'POST https://your-server.com/api/payment/initialize\n'
              '{\n'
              '  "email": "user@example.com",\n'
              '  "amount": 300000,  // Amount in kobo (₦3,000 * 100)\n'
              '  "plan": "individual",\n'
              '  "userId": "user123",\n'
              '  "channels": ["bank_transfer"]  // Force bank transfer only\n'
              '}\n\n'
              '// 3. Backend calls Paystack API\n'
              'curl https://api.paystack.co/transaction/initialize \\\n'
              '  -H "Authorization: Bearer sk_live_xxxxx" \\\n'
              '  -H "Content-Type: application/json" \\\n'
              '  -d \'{\n'
              '    "email": "user@example.com",\n'
              '    "amount": "300000",\n'
              '    "channels": ["bank_transfer"],\n'
              '    "metadata": {\n'
              '      "userId": "user123",\n'
              '      "plan": "individual",\n'
              '      "custom_fields": [\n'
              '        {\n'
              '          "display_name": "Subscription Plan",\n'
              '          "variable_name": "plan",\n'
              '          "value": "Individual Monthly"\n'
              '        }\n'
              '      ]\n'
              '    }\n'
              '  }\'',
            ),
            const SizedBox(height: 12),
            _buildSubHeader('Step 3: Paystack Response'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// Paystack returns virtual account details\n'
              '{\n'
              '  "status": true,\n'
              '  "message": "Authorization URL created",\n'
              '  "data": {\n'
              '    "authorization_url": "https://checkout.paystack.com/xxxxx",\n'
              '    "access_code": "xxxxx",\n'
              '    "reference": "T123456789",\n'
              '    "pay_with_bank": {\n'
              '      "account_number": "1234567890",\n'
              '      "bank_name": "Wema Bank",\n'
              '      "account_name": "PAYSTACK/TaxPadi-John Doe",\n'
              '      "amount": 300000,\n'
              '      "expires_at": "2026-01-15T23:59:59"\n'
              '    }\n'
              '  }\n'
              '}',
            ),
            const SizedBox(height: 12),
            _buildSubHeader('Step 4: Display Payment Details to User'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// In your Flutter app UI\n'
              'Widget _buildBankTransferDetails(PaymentData data) {\n'
              '  return Card(\n'
              '    child: Padding(\n'
              '      padding: EdgeInsets.all(16),\n'
              '      child: Column(\n'
              '        children: [\n'
              '          Text("Transfer to this account",\n'
              '              style: TextStyle(fontSize: 20, fontWeight: bold)),\n'
              '          SizedBox(height: 16),\n'
              '          _buildDetailRow("Bank Name", paymentData.bankName),\n'
              '          _buildDetailRow("Account Number", paymentData.accountNumber),\n'
              '          _buildDetailRow("Account Name", paymentData.accountName),\n'
              '          _buildDetailRow("Amount", "₦\${paymentData.amount / 100}"),\n'
              '          _buildDetailRow("Valid Until", paymentData.expiresAt),\n'
              '          SizedBox(height: 16),\n'
              '          ElevatedButton.icon(\n'
              '            icon: Icon(Icons.copy),\n'
              '            label: Text("Copy Account Number"),\n'
              '            onPressed: () => _copyToClipboard(data.accountNumber),\n'
              '          ),\n'
              '          SizedBox(height: 8),\n'
              '          Text("Payment auto-verifies within 5 minutes",\n'
              '              style: TextStyle(color: Colors.grey)),\n'
              '        ],\n'
              '      ),\n'
              '    ),\n'
              '  );\n'
              '}',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('🔔 Webhook Implementation'),
            const SizedBox(height: 12),
            _buildSubHeader('Step 5: Setup Webhook Endpoint'),
            const SizedBox(height: 8),
            _buildText(
              'Paystack sends HTTP POST requests to your webhook URL when payment status changes.',
              isBold: true,
            ),
            const SizedBox(height: 12),
            _buildCodeBlock(
              '// Backend webhook endpoint (Node.js example)\n'
              'const crypto = require("crypto");\n'
              'const express = require("express");\n'
              'const app = express();\n\n'
              'app.post("/api/paystack/webhook", express.json(), async (req, res) => {\n'
              '  // 1. Verify webhook signature\n'
              '  const hash = crypto\n'
              '    .createHmac("sha512", process.env.PAYSTACK_SECRET_KEY)\n'
              '    .update(JSON.stringify(req.body))\n'
              '    .digest("hex");\n\n'
              '  if (hash !== req.headers["x-paystack-signature"]) {\n'
              '    return res.status(401).send("Invalid signature");\n'
              '  }\n\n'
              '  // 2. Process webhook event\n'
              '  const event = req.body;\n\n'
              '  if (event.event === "charge.success") {\n'
              '    const { reference, amount, customer, metadata } = event.data;\n\n'
              '    // 3. Verify payment with Paystack API\n'
              '    const verification = await verifyPayment(reference);\n\n'
              '    if (verification.status === "success") {\n'
              '      // 4. Update user subscription in database\n'
              '      await upgradeUserSubscription({\n'
              '        userId: metadata.userId,\n'
              '        plan: metadata.plan,\n'
              '        amount: amount / 100,\n'
              '        reference: reference,\n'
              '        paymentMethod: "bank_transfer",\n'
              '        startDate: new Date(),\n'
              '        expiryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),\n'
              '      });\n\n'
              '      // 5. Send confirmation email\n'
              '      await sendConfirmationEmail(customer.email, {\n'
              '        plan: metadata.plan,\n'
              '        amount: amount / 100,\n'
              '        reference: reference,\n'
              '      });\n\n'
              '      // 6. Send push notification to user (if app is open)\n'
              '      await sendPushNotification(metadata.userId,\n'
              '        "Payment received! Your account has been upgraded.");\n'
              '    }\n'
              '  }\n\n'
              '  res.status(200).send("Webhook received");\n'
              '});',
            ),
            const SizedBox(height: 12),
            _buildSubHeader('Step 6: Verify Payment Function'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              'async function verifyPayment(ref) {\n'
              '  const response = await fetch(\n'
              '    `https://api.paystack.co/transaction/verify/\${ref}`,\n'
              '    {\n'
              '      headers: {\n'
              '        Authorization: `Bearer \${process.env.PAYSTACK_SECRET_KEY}`,\n'
              '      },\n'
              '    }\n'
              '  );\n\n'
              '  const data = await response.json();\n'
              '  return data.data;\n'
              '}',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('📱 User Experience Flow'),
            const SizedBox(height: 12),
            _buildBulletList([
              'User sees "Pending Payment" screen with bank details',
              'User can copy account number with one tap',
              'User transfers money via their bank app',
              'App shows "Waiting for payment confirmation..." with spinner',
              'App polls backend every 30 seconds to check payment status',
              'When payment received, show success animation',
              'Redirect to dashboard with "Welcome to Individual Plan!" message',
              'Premium features immediately unlocked',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('⏰ Payment Monitoring'),
            const SizedBox(height: 12),
            _buildSubHeader('Real-time Payment Status Check'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// In Flutter app - poll for payment status\n'
              'Timer _paymentCheckTimer;\n\n'
              'void _startPaymentMonitoring(String reference) {\n'
              '  _paymentCheckTimer = Timer.periodic(\n'
              '    Duration(seconds: 30),\n'
              '    (timer) async {\n'
              '      final status = await _checkPaymentStatus(reference);\n'
              '      \n'
              '      if (status == "success") {\n'
              '        timer.cancel();\n'
              '        _showSuccessDialog();\n'
              '        Navigator.pushReplacementNamed(context, "/dashboard");\n'
              '      } else if (status == "expired") {\n'
              '        timer.cancel();\n'
              '        _showExpiredDialog();\n'
              '      }\n'
              '    },\n'
              '  );\n\n'
              '  // Auto-cancel after 24 hours\n'
              '  Future.delayed(Duration(hours: 24), () {\n'
              '    _paymentCheckTimer?.cancel();\n'
              '  });\n'
              '}\n\n'
              'Future<String> _checkPaymentStatus(String ref) async {\n'
              '  final response = await http.get(\n'
              '    Uri.parse("https://your-server.com/api/payment/status/\$ref"),\n'
              '  );\n'
              '  final data = json.decode(response.body);\n'
              '  return data["status"];\n'
              '}',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('💰 Pricing & Fees'),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Paystack Bank Transfer Fees',
              'Domestic Transfer:\n'
                  '  • ₦50 flat fee for amounts ≤ ₦2,500\n'
                  '  • 2% capped at ₦50 for amounts > ₦2,500\n\n'
                  'Example for ₦3,000 subscription:\n'
                  '  • Customer pays: ₦3,000\n'
                  '  • Paystack fee: ₦50\n'
                  '  • You receive: ₦2,950\n\n'
                  'Settlement: Next business day',
              Colors.green,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('🔒 Security Considerations'),
            const SizedBox(height: 12),
            _buildBulletList([
              'Always verify webhook signature to prevent fake requests',
              'Validate payment amount matches expected subscription price',
              'Check payment status via Paystack API (don\'t trust webhook alone)',
              'Store payment reference in database for audit trail',
              'Use HTTPS for all API endpoints',
              'Never expose Paystack secret key in frontend',
              'Log all payment events for debugging',
              'Implement rate limiting on webhook endpoint',
              'Set up monitoring alerts for failed payments',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('❌ Failed Payment Handling'),
            const SizedBox(height: 12),
            _buildNumberedList([
              'If payment not received within 24 hours, virtual account expires',
              'User receives email: "Payment not received - account number expired"',
              'User can re-initiate payment to get new account number',
              'If wrong amount transferred, refund automatically processed',
              'Customer support can manually verify payments if needed',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader(
                '🏦 Manual Bank Transfer (Direct to Company Account)'),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Alternative Payment Method',
              'Unlike automated virtual accounts, users can transfer directly to your '
                  'company bank account. This requires manual verification but gives users '
                  'more payment flexibility.',
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildSubHeader('How Manual Bank Transfer Works'),
            const SizedBox(height: 8),
            _buildNumberedList([
              'User clicks "Upgrade to Individual Plan"',
              'User selects "Manual Bank Transfer" option',
              'App displays YOUR company bank account details:\n  - Bank: GTBank\n  - Account Number: 0123456789\n  - Account Name: TaxPadi Limited\n  - Amount: ₦3,000',
              'App generates unique payment reference: TXP-20260115-001',
              'User copies account details and payment reference',
              'User opens their banking app (or visits bank branch)',
              'User transfers ₦3,000 to your account',
              'IMPORTANT: User must include payment reference in narration/description',
              'User returns to app and clicks "I have made payment"',
              'User uploads payment receipt/screenshot (optional but recommended)',
              'Payment goes to "Pending Verification" status',
              'Admin receives notification of pending payment',
              'Admin logs into bank portal to check transactions',
              'Admin finds transfer with matching reference code',
              'Admin verifies amount (₦3,000) and date match',
              'Admin clicks "Approve Payment" in admin dashboard',
              'User account immediately upgraded',
              'User receives confirmation email and notification',
            ]),
            const SizedBox(height: 16),
            _buildSubHeader('User Flow in App'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// 1. User selects manual bank transfer\n'
              'Widget _buildManualBankTransferOption() {\n'
              '  return Card(\n'
              '    child: ListTile(\n'
              '      leading: Icon(Icons.account_balance, color: Colors.green),\n'
              '      title: Text("Manual Bank Transfer"),\n'
              '      subtitle: Text("Transfer from your bank app or branch"),\n'
              '      trailing: Icon(Icons.arrow_forward),\n'
              '      onTap: () => _showBankDetails(),\n'
              '    ),\n'
              '  );\n'
              '}\n\n'
              '// 2. Show bank account details\n'
              'void _showBankDetails() {\n'
              '  // Generate unique reference\n'
              '  final reference = "TXP-${DateTime.now().toString().substring(0, 10)}";\n'
              '  \n'
              '  showDialog(\n'
              '    context: context,\n'
              '    builder: (context) => AlertDialog(\n'
              '      title: Text("Transfer to This Account"),\n'
              '      content: Column(\n'
              '        mainAxisSize: MainAxisSize.min,\n'
              '        children: [\n'
              '          _buildInfoRow("Bank Name", "GTBank"),\n'
              '          _buildInfoRow("Account Number", "0123456789"),\n'
              '          _buildInfoRow("Account Name", "TaxPadi Limited"),\n'
              '          _buildInfoRow("Amount", "₦3,000.00"),\n'
              '          Divider(),\n'
              '          _buildInfoRow("Payment Reference", reference,\n'
              '              isBold: true, color: Colors.red),\n'
              '          SizedBox(height: 8),\n'
              '          Container(\n'
              '            padding: EdgeInsets.all(12),\n'
              '            color: Colors.red[50],\n'
              '            child: Text(\n'
              '              "⚠️ IMPORTANT: Include this reference in "\n'
              '              "your transfer description",\n'
              '              style: TextStyle(fontWeight: FontWeight.bold),\n'
              '            ),\n'
              '          ),\n'
              '          SizedBox(height: 12),\n'
              '          ElevatedButton.icon(\n'
              '            icon: Icon(Icons.copy),\n'
              '            label: Text("Copy Details"),\n'
              '            onPressed: () => _copyBankDetails(reference),\n'
              '          ),\n'
              '        ],\n'
              '      ),\n'
              '      actions: [\n'
              '        TextButton(\n'
              '          onPressed: () => Navigator.pop(context),\n'
              '          child: Text("I\'ll Pay Later"),\n'
              '        ),\n'
              '        ElevatedButton(\n'
              '          onPressed: () => _markPaymentMade(reference),\n'
              '          child: Text("I Have Paid"),\n'
              '        ),\n'
              '      ],\n'
              '    ),\n'
              '  );\n'
              '}\n\n'
              '// 3. User confirms payment made\n'
              'void _markPaymentMade(String reference) async {\n'
              '  // Save pending payment to database\n'
              '  await _savePendingPayment({\n'
              '    "reference": reference,\n'
              '    "userId": currentUser.id,\n'
              '    "amount": 3000,\n'
              '    "plan": "individual",\n'
              '    "status": "pending_verification",\n'
              '    "timestamp": DateTime.now(),\n'
              '    "receiptUrl": null,  // User can upload later\n'
              '  });\n'
              '  \n'
              '  // Navigate to pending payment screen\n'
              '  Navigator.push(\n'
              '    context,\n'
              '    MaterialPageRoute(\n'
              '      builder: (context) => PendingPaymentScreen(\n'
              '        reference: reference,\n'
              '      ),\n'
              '    ),\n'
              '  );\n'
              '}',
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Admin Verification Dashboard'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// Admin screen to view pending payments\n'
              'class ManualPaymentVerificationScreen extends StatefulWidget {\n'
              '  // Load pending payments from database\n'
              '  List<PendingPayment> pendingPayments = [];\n'
              '  \n'
              '  Widget build(BuildContext context) {\n'
              '    return Scaffold(\n'
              '      appBar: AppBar(\n'
              '        title: Text("Manual Payment Verification"),\n'
              '        backgroundColor: Colors.green[700],\n'
              '      ),\n'
              '      body: ListView.builder(\n'
              '        itemCount: pendingPayments.length,\n'
              '        itemBuilder: (context, index) {\n'
              '          final payment = pendingPayments[index];\n'
              '          return Card(\n'
              '            margin: EdgeInsets.all(8),\n'
              '            child: ListTile(\n'
              '              leading: CircleAvatar(\n'
              '                child: Icon(Icons.pending),\n'
              '                backgroundColor: Colors.orange,\n'
              '              ),\n'
              '              title: Text(pmt.userName),\n'
              '              subtitle: Column(\n'
              '                crossAxisAlignment: CrossAxisAlignment.start,\n'
              '                children: [\n'
              '                  Text("Ref: \${pmt.reference}"),\n'
              '                  Text("Amount: ₦\${pmt.amount}"),\n'
              '                  Text("Plan: \${pmt.plan}"),\n'
              '                  Text("Date: \${pmt.timestamp}"),\n'
              '                  if (pmt.receiptUrl != null)\n'
              '                    TextButton(\n'
              '                      child: Text("View Receipt"),\n'
              '                      onPressed: () => _viewReceipt(pmt),\n'
              '                    ),\n'
              '                ],\n'
              '              ),\n'
              '              trailing: Row(\n'
              '                mainAxisSize: MainAxisSize.min,\n'
              '                children: [\n'
              '                  IconButton(\n'
              '                    icon: Icon(Icons.check, color: Colors.green),\n'
              '                    onPressed: () => _approvePayment(payment),\n'
              '                  ),\n'
              '                  IconButton(\n'
              '                    icon: Icon(Icons.close, color: Colors.red),\n'
              '                    onPressed: () => _rejectPayment(payment),\n'
              '                  ),\n'
              '                ],\n'
              '              ),\n'
              '            ),\n'
              '          );\n'
              '        },\n'
              '      ),\n'
              '    );\n'
              '  }\n'
              '  \n'
              '  // Approve payment\n'
              '  void _approvePayment(PendingPayment payment) async {\n'
              '    // 1. Update user subscription\n'
              '    await upgradeUserSubscription(\n'
              '      userId: payment.userId,\n'
              '      plan: payment.plan,\n'
              '      reference: payment.reference,\n'
              '    );\n'
              '    \n'
              '    // 2. Mark payment as verified\n'
              '    await updatePaymentStatus(payment.id, "verified");\n'
              '    \n'
              '    // 3. Send confirmation email\n'
              '    await sendConfirmationEmail(payment.userEmail);\n'
              '    \n'
              '    // 4. Send push notification\n'
              '    await sendPushNotification(\n'
              '      payment.userId,\n'
              '      "Payment verified! Your account has been upgraded."\n'
              '    );\n'
              '    \n'
              '    // 5. Refresh list\n'
              '    setState(() {\n'
              '      pendingPayments.removeWhere((p) => p.id == payment.id);\n'
              '    });\n'
              '  }\n'
              '  \n'
              '  // Reject payment\n'
              '  void _rejectPayment(PendingPayment payment) async {\n'
              '    final reason = await _showRejectReasonDialog();\n'
              '    \n'
              '    await updatePaymentStatus(payment.id, "rejected");\n'
              '    await sendRejectionEmail(payment.userEmail, reason);\n'
              '    \n'
              '    setState(() {\n'
              '      pendingPayments.removeWhere((p) => p.id == payment.id);\n'
              '    });\n'
              '  }\n'
              '}',
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Admin Verification Steps (Manual Process)'),
            const SizedBox(height: 8),
            _buildNumberedList([
              'Admin opens "Manual Payment Verification" in admin dashboard',
              'Admin sees list of pending payments with reference codes',
              'Admin opens their GTBank mobile app or internet banking',
              'Admin checks transaction history for today',
              'Admin searches for transfer with matching reference code',
              'Admin verifies:\n  ✓ Amount matches (₦3,000)\n  ✓ Reference code matches (TXP-20260115-001)\n  ✓ Date is recent (within 24 hours)\n  ✓ Transaction successful',
              'If everything matches, admin clicks "Approve"',
              'If something wrong, admin clicks "Reject" and adds reason',
              'User receives instant notification of approval/rejection',
            ]),
            const SizedBox(height: 16),
            _buildSubHeader('Receipt Upload Feature (Optional)'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// Let users upload payment receipt for faster verification\n'
              'void _uploadReceipt(String paymentId) async {\n'
              '  final ImagePicker picker = ImagePicker();\n'
              '  final XFile? image = await picker.pickImage(\n'
              '    source: ImageSource.gallery,\n'
              '    maxWidth: 1080,\n'
              '    imageQuality: 85,\n'
              '  );\n'
              '  \n'
              '  if (image != null) {\n'
              '    // Upload to Firebase Storage or your server\n'
              '    final url = await uploadToStorage(image.path);\n'
              '    \n'
              '    // Update payment record with receipt URL\n'
              '    await updatePaymentReceipt(paymentId, url);\n'
              '    \n'
              '    showSnackBar("Receipt uploaded successfully");\n'
              '  }\n'
              '}',
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Advantages of Manual Bank Transfer'),
            const SizedBox(height: 8),
            _buildBulletList([
              'No payment gateway fees (100% of ₦3,000 goes to you)',
              'Works with any Nigerian bank account',
              'Users familiar with bank transfers',
              'No technical integration required',
              'Users can pay at bank branch if no internet',
              'Good for users who don\'t trust online payments',
              'No card required',
            ]),
            const SizedBox(height: 12),
            _buildSubHeader('Disadvantages of Manual Bank Transfer'),
            const SizedBox(height: 8),
            _buildBulletList([
              'Manual verification takes time (hours vs seconds)',
              'Admin must check bank portal regularly',
              'Risk of user error (wrong reference, wrong amount)',
              'Not instant - users must wait for approval',
              'More customer support tickets',
              'Can\'t automate recurring payments',
              'Difficult to scale with many users',
            ]),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Best Practice Recommendation',
              'Offer BOTH methods:\n'
                  '1. Automated (Paystack virtual account) - Default, instant\n'
                  '2. Manual (Direct bank transfer) - Backup option\n\n'
                  'Most users will choose automated for convenience. Manual is good '
                  'for users with payment gateway issues or those who prefer traditional banking.',
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Database Schema for Manual Payments'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// Hive/Database model for pending payments\n'
              'class ManualPayment {\n'
              '  final String id;\n'
              '  final String userId;\n'
              '  final String userName;\n'
              '  final String userEmail;\n'
              '  final String reference;  // TXP-20260115-001\n'
              '  final double amount;     // 3000\n'
              '  final String plan;       // "individual"\n'
              '  final String status;     // "pending_verification", "verified", "rejected"\n'
              '  final DateTime timestamp;\n'
              '  final String? receiptUrl;\n'
              '  final String? rejectionReason;\n'
              '  final DateTime? verifiedAt;\n'
              '  final String? verifiedBy; // Admin username\n'
              '  \n'
              '  ManualPayment({\n'
              '    required this.id,\n'
              '    required this.userId,\n'
              '    required this.userName,\n'
              '    required this.userEmail,\n'
              '    required this.reference,\n'
              '    required this.amount,\n'
              '    required this.plan,\n'
              '    required this.status,\n'
              '    required this.timestamp,\n'
              '    this.receiptUrl,\n'
              '    this.rejectionReason,\n'
              '    this.verifiedAt,\n'
              '    this.verifiedBy,\n'
              '  });\n'
              '}',
            ),
            const SizedBox(height: 16),
            _buildSubHeader('Automatic Expiry for Pending Payments'),
            const SizedBox(height: 8),
            _buildCodeBlock(
              '// Auto-reject payments older than 48 hours\n'
              'Future<void> expirePendingPayments() async {\n'
              '  final cutoffTime = DateTime.now().subtract(Duration(hours: 48));\n'
              '  \n'
              '  final oldPayments = await getPayments(\n'
              '    status: "pending_verification",\n'
              '    olderThan: cutoffTime,\n'
              '  );\n'
              '  \n'
              '  for (var payment in oldPayments) {\n'
              '    await updatePaymentStatus(\n'
              '      payment.id,\n'
              '      "expired",\n'
              '      reason: "No verification within 48 hours",\n'
              '    );\n'
              '    \n'
              '    await sendEmail(\n'
              '      payment.userEmail,\n'
              '      "Payment Expired",\n'
              '      "Your payment was not verified within 48 hours. "\n'
              '      "Please try again or contact support.",\n'
              '    );\n'
              '  }\n'
              '}\n\n'
              '// Run this as a daily scheduled task',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('📊 Admin Dashboard Integration'),
            const SizedBox(height: 12),
            _buildBulletList([
              'View all pending manual payments requiring verification',
              'View all automated Paystack payments (real-time)',
              'See payment history with filter options',
              'Track failed/expired payments',
              'Generate payment reports (daily/monthly revenue)',
              'Manual payment verification interface',
              'Refund processing interface',
              'Export payment data to Excel/CSV',
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('🧪 Testing Bank Transfers'),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Test Mode Instructions',
              '1. Use Paystack test API keys (pk_test_xxx)\n'
                  '2. Paystack provides test bank accounts\n'
                  '3. Use test account numbers to simulate transfers\n'
                  '4. Test accounts auto-complete after 10 seconds\n'
                  '5. Test webhook events with Paystack dashboard\n'
                  '6. No real money involved in test mode',
              Colors.blue,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('📞 Customer Support Integration'),
            const SizedBox(height: 12),
            _buildCodeBlock(
              '// Support ticket system for payment issues\n'
              'Common Issues:\n'
              '1. "I transferred but not upgraded"\n'
              '   → Check payment reference\n'
              '   → Verify webhook received\n'
              '   → Manual verification if needed\n\n'
              '2. "Account number expired"\n'
              '   → Generate new payment link\n'
              '   → Extend expiry if near deadline\n\n'
              '3. "Wrong amount transferred"\n'
              '   → Initiate refund via Paystack\n'
              '   → Guide user to pay correct amount\n\n'
              '4. "Payment pending for hours"\n'
              '   → Check bank processing time\n'
              '   → Verify with Paystack support\n'
              '   → Manual upgrade if verified',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('🚀 Go-Live Checklist'),
            const SizedBox(height: 12),
            _buildChecklistItem(
                'Paystack account fully verified (CAC, bank details)'),
            _buildChecklistItem('Live API keys configured in production'),
            _buildChecklistItem(
                'Webhook URL publicly accessible (not localhost)'),
            _buildChecklistItem('SSL certificate active on webhook endpoint'),
            _buildChecklistItem(
                'Database schema ready for subscription tracking'),
            _buildChecklistItem('Email templates configured for confirmations'),
            _buildChecklistItem('Admin dashboard can view payments'),
            _buildChecklistItem('Test payments completed successfully'),
            _buildChecklistItem('Webhook signature verification working'),
            _buildChecklistItem('Refund process tested'),
            _buildChecklistItem('Customer support trained on payment issues'),
            _buildChecklistItem('Monitoring alerts configured'),
            const SizedBox(height: 24),
            _buildSuccessCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.purple[50],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.purple[700]!, width: 2),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.admin_panel_settings,
                color: Colors.purple[700], size: 48),
            const SizedBox(height: 12),
            const Text(
              'Bank Transfer Payment Implementation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete technical guide for implementing bank transfer payments via Paystack. '
              'This document is for admin and developer use only.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      color: Colors.green[50],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[700]!, width: 2),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 48),
            const SizedBox(height: 12),
            const Text(
              'Implementation Ready!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Follow the steps above to implement secure bank transfer payments. '
              'Test thoroughly before going live. Contact Paystack support if you need help.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_box_outline_blank,
              color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildText(String text, {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(item, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(items[index], style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
