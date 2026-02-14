import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Intelligent Form Guide System
///
/// Provides contextual, step-by-step guidance for users filling out
/// tax calculator forms. Shows tips, examples, and "what does this mean"
/// explanations inline with the form fields.
///
/// Usage:
/// ```dart
/// FormFieldGuide(
///   fieldName: 'grossIncome',
///   calculatorType: 'PIT',
///   child: ValidatedTextField(...),
/// )
/// ```

/// Registry of field guidance data for each calculator
class FormGuidanceData {
  static const Map<String, Map<String, FieldGuidance>> _guidance = {
    'PIT': {
      'grossIncome': FieldGuidance(
        label: 'Gross Annual Income',
        whatIsThis: 'Your total annual earnings before any deductions — '
            'includes salary, bonuses, allowances, benefits-in-kind, and any other '
            'compensation from your employer or business.',
        howToFind:
            '• Check your employment letter or contract for your annual package\n'
            '• Look at your December payslip → "Year-to-Date Gross"\n'
            '• Sum all 12 monthly gross pay slips\n'
            '• If self-employed, use your total business revenue',
        example: 'If your monthly gross salary is ₦416,667, your annual '
            'gross income is ₦5,000,000.',
        tips: [
          'Include all income sources — salary, bonuses, and allowances',
          'Do NOT deduct pension, NHF, or NHIS before entering',
          'If you receive benefits like housing or car, include their taxable value',
        ],
        nigerianContext:
            'Under the Nigeria Tax Act 2025, "gross emoluments" includes all forms of '
            'compensation. The first ₦800,000 is consolidated relief.',
      ),
      'otherDeductions': FieldGuidance(
        label: 'Other Deductions (Reliefs)',
        whatIsThis:
            'Allowable tax reliefs beyond the standard consolidated relief. '
            'These are amounts you can legally deduct to reduce your taxable income.',
        howToFind:
            '• Life insurance premiums — check your insurance policy documents\n'
            '• NHIS contributions — check your payslip or NHIS statement\n'
            '• Mortgage interest — ask your bank for the annual statement\n'
            '• Gratuity contributions — check with HR',
        example: 'If you pay ₦200,000/year in life insurance and ₦150,000 in '
            'additional NHIS, enter ₦350,000.',
        tips: [
          'Pension (8%) and NHF (2.5%) are automatically deducted — don\'t include them here',
          'Only include expenses you have receipts/documentation for',
          'If unsure, enter ₦0 — the calculator still handles standard CRA',
        ],
        nigerianContext:
            'Consolidated Relief Allowance (CRA) = ₦200,000 + 20% of Gross Income '
            'is automatically applied. This field is for ADDITIONAL reliefs only.',
      ),
      'annualRentPaid': FieldGuidance(
        label: 'Annual Rent Paid',
        whatIsThis:
            'The total rent you paid during the tax year for your primary '
            'residence. This may qualify for additional tax relief.',
        howToFind: '• Check your tenancy agreement for the annual rent\n'
            '• If you pay monthly rent, multiply by 12\n'
            '• Include only rent for your primary home, not investment properties',
        example:
            'If you pay ₦150,000/month in rent, enter ₦1,800,000 as annual rent.',
        tips: [
          'Keep your tenancy agreement as proof for FIRS audits',
          'Landlord\'s receipt or bank transfer records serve as evidence',
          'If you own your home, enter ₦0',
        ],
        nigerianContext:
            'Under Section 33 of PITA, rent paid may qualify for relief. '
            'Ensure you have verifiable receipts.',
      ),
    },
    'CIT': {
      'turnover': FieldGuidance(
        label: 'Annual Business Turnover',
        whatIsThis:
            'Your company\'s total gross revenue (sales) for the financial year, '
            'before deducting any expenses or costs.',
        howToFind:
            '• Check your company\'s Profit & Loss statement → "Revenue" or "Turnover"\n'
            '• Audited financial statements → top line figure\n'
            '• Sales register or accounting software (QuickBooks, Sage, etc.)\n'
            '• CAC annual returns filing',
        example: 'If your company sold ₦50M in products and ₦10M in services, '
            'your turnover is ₦60,000,000.',
        tips: [
          'This determines your CIT tier: Small (<₦25M), Medium (₦25M-₦100M), or Large (>₦100M)',
          'Include ALL revenue — product sales, service fees, commissions',
          'Use the figure from your audited accounts for accuracy',
          'Small companies (<₦25M) pay 0% CIT — a significant benefit!',
        ],
        nigerianContext:
            'The Nigeria Tax Act 2025 uses turnover to classify companies into '
            '3 tiers with different CIT rates: 0% (Small), 20% (Medium), 30% (Large).',
      ),
      'profit': FieldGuidance(
        label: 'Chargeable Profit',
        whatIsThis:
            'Your company\'s taxable profit after deducting all allowable '
            'business expenses from turnover. This is the amount CIT is calculated on.',
        howToFind: '• Profit & Loss statement → "Profit Before Tax"\n'
            '• Turnover minus cost of sales, operating expenses, and allowable deductions\n'
            '• Your accountant or tax advisor can compute this\n'
            '• Audited financial statements → "Profit Before Taxation"',
        example: 'If turnover is ₦60M and total allowable expenses are ₦45M, '
            'chargeable profit is ₦15,000,000.',
        tips: [
          'Profit cannot exceed turnover — if it does, double-check your figures',
          'Allowable deductions include: salaries, rent, utilities, depreciation',
          'Non-allowable deductions: fines, penalties, owner\'s personal expenses',
          'Minimum tax may apply if profit is very low relative to turnover',
        ],
        nigerianContext:
            'FIRS requires that chargeable profits be computed in accordance with '
            'the CITA. Capital allowances can reduce chargeable profit.',
      ),
    },
    'VAT': {
      'standardSales': FieldGuidance(
        label: 'Standard-Rated Sales (7.5%)',
        whatIsThis:
            'The total value of all goods and services you sold that are subject '
            'to the standard 7.5% VAT rate.',
        howToFind: '• Sales register/invoices — sum all VAT-inclusive sales\n'
            '• Accounting software → VAT report → Standard-rated output\n'
            '• Point-of-sale records for the period\n'
            '• Exclude zero-rated and exempt sales from this figure',
        example: 'If you sold ₦10M worth of electronics (standard-rated), '
            'enter ₦10,000,000. The VAT of ₦750,000 is calculated automatically.',
        tips: [
          'Enter the NET sales value (before adding VAT), not the gross (VAT-inclusive) amount',
          'Most goods and services in Nigeria are standard-rated at 7.5%',
          'Keep VAT invoices for all sales as FIRS audit evidence',
          'File your VAT returns monthly by the 21st of the following month',
        ],
        nigerianContext:
            'Nigeria\'s VAT rate is 7.5% (effective Feb 2020). Most goods and '
            'services fall under this rate unless specifically zero-rated or exempt.',
      ),
      'zeroRatedSales': FieldGuidance(
        label: 'Zero-Rated Sales (0%)',
        whatIsThis: 'Sales of goods/services that are taxable but at 0% rate. '
            'You charge no VAT but can still claim input VAT on related purchases.',
        howToFind: '• Identify export sales — goods shipped outside Nigeria\n'
            '• Humanitarian/diplomatic sales with zero-rating certificates\n'
            '• Check your invoices for any marked as zero-rated',
        example:
            'If you exported ₦5M of agricultural products, enter ₦5,000,000.',
        tips: [
          'Exports are the most common zero-rated supply in Nigeria',
          'You CAN claim input VAT on purchases related to zero-rated sales',
          'Keep shipping documents and export certificates as proof',
          'If you have no zero-rated sales, enter ₦0',
        ],
        nigerianContext:
            'Zero-rated supplies under VATA include goods exported from Nigeria '
            'and services rendered outside Nigeria.',
      ),
      'exemptSales': FieldGuidance(
        label: 'Exempt Sales',
        whatIsThis:
            'Sales of goods/services that are completely exempt from VAT. '
            'No VAT is charged and no input VAT can be claimed on related purchases.',
        howToFind: '• Check the First Schedule of VATA for exempt items\n'
            '• Medical/pharmaceutical products, basic food items, educational materials\n'
            '• Baby products, agricultural equipment, fertilizers',
        example:
            'If you sold ₦3M of basic food items (exempt), enter ₦3,000,000.',
        tips: [
          'Common exempt items: basic food, medical, educational, baby products',
          'You CANNOT claim input VAT on purchases used for exempt sales',
          'If your business has both exempt and taxable sales, apportion input VAT',
          'If you have no exempt sales, enter ₦0',
        ],
        nigerianContext:
            'The First Schedule of VATA lists all exempt goods and services. '
            'Companies making only exempt supplies need not register for VAT.',
      ),
      'totalInputVat': FieldGuidance(
        label: 'Total Input VAT',
        whatIsThis:
            'The total VAT you paid on business purchases and expenses during '
            'the period. This is deducted from your output VAT.',
        howToFind: '• Sum all VAT amounts from your purchase invoices\n'
            '• Accounting software → VAT report → Input VAT\n'
            '• Bank statements showing VAT-inclusive payments to suppliers\n'
            '• Only include purchases with valid VAT invoices',
        example:
            'If you purchased ₦8M of raw materials at 7.5% VAT, your input '
            'VAT is ₦600,000.',
        tips: [
          'Only claim input VAT if you have a valid VAT invoice from the supplier',
          'The supplier must be VAT-registered for you to claim their VAT',
          'If input VAT exceeds output VAT, you have a refund position',
          'File Form 002 with FIRS for VAT refund claims',
        ],
        nigerianContext:
            'Input VAT credit is allowed under Section 16 of VATA. '
            'Keep all purchase invoices for a minimum of 6 years.',
      ),
      'exemptInputVat': FieldGuidance(
        label: 'Exempt Input VAT',
        whatIsThis:
            'The portion of input VAT that relates to purchases used for '
            'making exempt supplies. This cannot be claimed as a credit.',
        howToFind:
            '• Apportion your total input VAT between taxable and exempt activities\n'
            '• Use the ratio of exempt sales to total sales to estimate\n'
            '• Your accountant can help with the apportionment calculation',
        example:
            'If 30% of your sales are exempt and total input VAT is ₦600,000, '
            'exempt input VAT is approximately ₦180,000.',
        tips: [
          'This amount is NOT deductible from your output VAT',
          'It becomes part of your business cost/expense',
          'Cannot exceed your total input VAT',
          'If all your sales are standard-rated, enter ₦0',
        ],
        nigerianContext:
            'Apportionment of input VAT is required under VATA when a business '
            'makes both taxable and exempt supplies.',
      ),
    },
    'WHT': {
      'amount': FieldGuidance(
        label: 'Gross Payment Amount',
        whatIsThis:
            'The total payment amount before deducting withholding tax. '
            'This is the full contract or invoice value.',
        howToFind:
            '• Check the contract, invoice, or agreement for the payment amount\n'
            '• For recurring payments, use the value for a single payment period\n'
            '• Include the full value before any deductions',
        example: 'If you\'re paying a contractor ₦2,000,000 for consultancy, '
            'enter ₦2,000,000.',
        tips: [
          'Enter the GROSS amount, not the net (after-tax) amount',
          'WHT must be remitted to FIRS within 21 days of deduction',
          'Obtain a WHT credit note for the payee — they need it for tax credits',
          'Different payment types have different WHT rates (5%-10%)',
        ],
        nigerianContext: 'WHT is an advance payment of tax, not a final tax. '
            'The recipient can use the WHT credit note to offset their income tax.',
      ),
    },
    'PAYROLL': {
      'monthlyGross': FieldGuidance(
        label: 'Monthly Gross Salary',
        whatIsThis:
            'The employee\'s total monthly earnings before any deductions '
            '— includes basic salary, housing allowance, transport allowance, '
            'and all other regular allowances.',
        howToFind: '• Check the employee\'s employment letter or contract\n'
            '• Look at the payroll register → "Total Gross" column\n'
            '• HR/payroll department can confirm the figure\n'
            '• Include all regular monthly allowances',
        example:
            'If basic salary is ₦300,000, housing ₦100,000, transport ₦50,000, '
            'monthly gross = ₦450,000.',
        tips: [
          'Include ALL regular allowances (basic, housing, transport, meal, etc.)',
          'Do NOT include one-time bonuses — those are calculated separately',
          'The current national minimum wage is ₦70,000/month',
          'If employee earns below minimum wage, a warning will appear',
        ],
        nigerianContext:
            'PAYE (Pay As You Earn) is the income tax deducted from salaries. '
            'Employers must remit PAYE by the 10th of the following month.',
      ),
      'pensionRate': FieldGuidance(
        label: 'Pension Rate (%)',
        whatIsThis:
            'The employee\'s pension contribution rate as a percentage of '
            'monthly gross salary. This is a pre-tax deduction.',
        howToFind: '• Standard employee contribution: 8%\n'
            '• Some employers offer voluntary additional contributions up to 20%\n'
            '• Check the company pension policy or PFA agreement',
        example: 'If the standard 8% applies and monthly gross is ₦450,000, '
            'pension deduction = ₦36,000.',
        tips: [
          'Default is 8% (minimum employee contribution under PRA 2014)',
          'Employer also contributes a minimum of 10%',
          'Voluntary contributions above 8% are still tax-deductible',
          'Only change this if the employee contributes more than 8%',
        ],
        nigerianContext:
            'The Pension Reform Act 2014 mandates a minimum 18% total contribution '
            '(8% employee + 10% employer) for organizations with 3+ employees.',
      ),
      'nhfRate': FieldGuidance(
        label: 'NHF Rate (%)',
        whatIsThis: 'National Housing Fund contribution rate. A mandatory '
            'deduction for employees earning above the national minimum wage.',
        howToFind: '• Standard NHF rate: 2.5%\n'
            '• Check your NHF registration or payslip for confirmation\n'
            '• This is a fixed rate — rarely changes',
        example: 'If monthly gross is ₦450,000 at 2.5%, NHF = ₦11,250.',
        tips: [
          'Default rate is 2.5% — most employers use this',
          'NHF is a pre-tax deduction (reduces taxable income)',
          'Contributions can be used for housing loans from FMBN',
          'Only change this if a different rate applies',
        ],
        nigerianContext:
            'The National Housing Fund Act requires employees earning above '
            'minimum wage to contribute 2.5% towards the housing fund.',
      ),
      'otherDeductions': FieldGuidance(
        label: 'Other Deductions',
        whatIsThis:
            'Any additional monthly deductions from the employee\'s salary '
            'that are made after tax calculation — e.g., loan repayments, '
            'cooperative contributions, union dues.',
        howToFind: '• Check the employee\'s payslip for recurring deductions\n'
            '• HR records for loan repayments\n'
            '• Cooperative membership fees\n'
            '• Union dues documents',
        example:
            'If the employee has a ₦20,000 loan repayment and ₦5,000 cooperative '
            'fee, enter ₦25,000.',
        tips: [
          'These are POST-TAX deductions — they don\'t reduce taxable income',
          'If there are no other deductions, enter ₦0',
          'Pension and NHF are already handled separately above',
          'Include only monthly (not one-time) deductions',
        ],
        nigerianContext:
            'Post-tax deductions are statutory or voluntary deductions made after '
            'PAYE has been calculated. They affect net pay but not tax amount.',
      ),
    },
    'STAMP_DUTY': {
      'amount': FieldGuidance(
        label: 'Transaction Amount',
        whatIsThis:
            'The value of the document or transaction subject to stamp duty. '
            'This could be a property sale, tenancy agreement, or bank transfer.',
        howToFind:
            '• Property purchase → check the sale agreement for the purchase price\n'
            '• Tenancy → annual rent from the tenancy agreement\n'
            '• Bank transfer → the transfer amount from your bank statement\n'
            '• Insurance → the premium from your insurance policy',
        example: 'For a property purchase of ₦50,000,000, enter ₦50,000,000. '
            'For a bank transfer of ₦15,000, enter ₦15,000.',
        tips: [
          'Electronic transfers over ₦10,000 attract a flat ₦50 stamp duty',
          'Property transfers use ad valorem rates (% of value)',
          'Stamp duty on receipts is typically a flat ₦500 for amounts over ₦40,000',
          'Keep stamped documents as proof of payment',
        ],
        nigerianContext:
            'The Stamp Duties Act (amended) imposes duty on various instruments. '
            'Electronic transfers were added in the 2020 Finance Act.',
      ),
    },
  };

  /// Get guidance for a specific field
  static FieldGuidance? getGuidance(String calculatorType, String fieldName) {
    return _guidance[calculatorType]?[fieldName];
  }

  /// Get all field guidance for a calculator
  static Map<String, FieldGuidance> getCalculatorGuidance(
      String calculatorType) {
    return _guidance[calculatorType] ?? {};
  }

  /// Get step-by-step guide for a calculator
  static List<FormStep> getCalculatorSteps(String calculatorType) {
    switch (calculatorType) {
      case 'PIT':
        return [
          FormStep(
              step: 1,
              title: 'Enter Gross Income',
              description: 'Enter your total annual earnings before deductions',
              fieldName: 'grossIncome'),
          FormStep(
              step: 2,
              title: 'Add Other Reliefs (Optional)',
              description:
                  'Enter additional tax reliefs beyond the standard CRA',
              fieldName: 'otherDeductions'),
          FormStep(
              step: 3,
              title: 'Enter Rent Paid (Optional)',
              description: 'Enter annual rent if applicable',
              fieldName: 'annualRentPaid'),
          FormStep(
              step: 4,
              title: 'Calculate',
              description:
                  'Press Calculate to see your tax breakdown with progressive bands',
              fieldName: null),
        ];
      case 'CIT':
        return [
          FormStep(
              step: 1,
              title: 'Enter Business Turnover',
              description: 'Enter your company\'s total annual revenue/sales',
              fieldName: 'turnover'),
          FormStep(
              step: 2,
              title: 'Enter Chargeable Profit',
              description: 'Enter taxable profit after allowable deductions',
              fieldName: 'profit'),
          FormStep(
              step: 3,
              title: 'Calculate',
              description:
                  'See your CIT based on company size tier (Small/Medium/Large)',
              fieldName: null),
        ];
      case 'VAT':
        return [
          FormStep(
              step: 1,
              title: 'Enter Standard Sales',
              description: 'Total sales at 7.5% VAT rate',
              fieldName: 'standardSales'),
          FormStep(
              step: 2,
              title: 'Enter Zero-Rated Sales',
              description: 'Export sales and other 0% rated supplies',
              fieldName: 'zeroRatedSales'),
          FormStep(
              step: 3,
              title: 'Enter Exempt Sales',
              description: 'Sales of VAT-exempt goods/services',
              fieldName: 'exemptSales'),
          FormStep(
              step: 4,
              title: 'Enter Input VAT',
              description: 'VAT paid on business purchases',
              fieldName: 'totalInputVat'),
          FormStep(
              step: 5,
              title: 'Calculate',
              description: 'See net VAT payable or refundable',
              fieldName: null),
        ];
      case 'WHT':
        return [
          FormStep(
              step: 1,
              title: 'Select Payment Type',
              description:
                  'Choose the type of payment (consultancy, rent, etc.)',
              fieldName: 'type'),
          FormStep(
              step: 2,
              title: 'Enter Payment Amount',
              description: 'Enter the gross payment before WHT deduction',
              fieldName: 'amount'),
          FormStep(
              step: 3,
              title: 'Calculate',
              description: 'See WHT amount and net payment',
              fieldName: null),
        ];
      case 'PAYROLL':
        return [
          FormStep(
              step: 1,
              title: 'Enter Monthly Gross',
              description: 'Employee\'s total monthly earnings',
              fieldName: 'monthlyGross'),
          FormStep(
              step: 2,
              title: 'Verify Pension Rate',
              description: 'Confirm pension contribution % (default: 8%)',
              fieldName: 'pensionRate'),
          FormStep(
              step: 3,
              title: 'Verify NHF Rate',
              description: 'Confirm NHF contribution % (default: 2.5%)',
              fieldName: 'nhfRate'),
          FormStep(
              step: 4,
              title: 'Calculate',
              description: 'See monthly and annual PAYE breakdown',
              fieldName: null),
        ];
      case 'STAMP_DUTY':
        return [
          FormStep(
              step: 1,
              title: 'Select Transaction Type',
              description: 'Choose the type of instrument/transaction',
              fieldName: 'type'),
          FormStep(
              step: 2,
              title: 'Enter Transaction Amount',
              description: 'Enter the document or transaction value',
              fieldName: 'amount'),
          FormStep(
              step: 3,
              title: 'Calculate',
              description: 'See stamp duty payable based on rates',
              fieldName: null),
        ];
      default:
        return [];
    }
  }
}

/// Data class for field-level guidance
class FieldGuidance {
  final String label;
  final String whatIsThis;
  final String howToFind;
  final String example;
  final List<String> tips;
  final String nigerianContext;

  const FieldGuidance({
    required this.label,
    required this.whatIsThis,
    required this.howToFind,
    required this.example,
    required this.tips,
    required this.nigerianContext,
  });
}

/// Data class for step-by-step form guide
class FormStep {
  final int step;
  final String title;
  final String description;
  final String? fieldName;

  const FormStep({
    required this.step,
    required this.title,
    required this.description,
    this.fieldName,
  });
}

// ─── WIDGETS ──────────────────────────────────────────────────────────

/// Wraps a form field with intelligent contextual guidance.
/// Shows a guide button that reveals detailed help, examples, and tips.
class FormFieldGuide extends StatefulWidget {
  final String calculatorType;
  final String fieldName;
  final Widget child;
  final bool showGuideByDefault;

  const FormFieldGuide({
    super.key,
    required this.calculatorType,
    required this.fieldName,
    required this.child,
    this.showGuideByDefault = false,
  });

  @override
  State<FormFieldGuide> createState() => _FormFieldGuideState();
}

class _FormFieldGuideState extends State<FormFieldGuide>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showGuideByDefault;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleGuide() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final guidance =
        FormGuidanceData.getGuidance(widget.calculatorType, widget.fieldName);
    if (guidance == null) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The form field with guide button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: widget.child),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: _toggleGuide,
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isExpanded
                        ? TaxNGColors.primary.withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : TaxNGColors.primary.withValues(alpha: 0.05)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isExpanded
                        ? Icons.lightbulb_rounded
                        : Icons.lightbulb_outline_rounded,
                    size: 20,
                    color: _isExpanded
                        ? TaxNGColors.primary
                        : (isDark ? Colors.white54 : TaxNGColors.textLight),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Expandable guidance card
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: _buildGuidanceCard(guidance, isDark),
        ),
      ],
    );
  }

  Widget _buildGuidanceCard(FieldGuidance guidance, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? TaxNGColors.primary.withValues(alpha: 0.08)
            : TaxNGColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TaxNGColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What is this?
          _GuidanceSection(
            icon: Icons.help_outline_rounded,
            title: 'What is this?',
            content: guidance.whatIsThis,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // How to find this value
          _GuidanceSection(
            icon: Icons.search_rounded,
            title: 'Where to find this',
            content: guidance.howToFind,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Example
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? TaxNGColors.info.withValues(alpha: 0.1)
                  : TaxNGColors.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded,
                    size: 16, color: TaxNGColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guidance.example,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : TaxNGColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tips
          ...guidance.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: TaxNGColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(tip,
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white60
                                  : TaxNGColors.textMedium)),
                    ),
                  ],
                ),
              )),

          // Nigerian context
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? TaxNGColors.primaryDark.withValues(alpha: 0.2)
                  : TaxNGColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TaxNGColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🇳🇬', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guidance.nigerianContext,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : TaxNGColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isDark;

  const _GuidanceSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: TaxNGColors.primary),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : TaxNGColors.textDark)),
          ],
        ),
        const SizedBox(height: 4),
        Text(content,
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : TaxNGColors.textMedium,
                height: 1.4)),
      ],
    );
  }
}

/// Interactive step-by-step progress guide shown at the top of a calculator form.
/// Highlights the current step and shows completion status.
class FormStepGuide extends StatelessWidget {
  final String calculatorType;
  final int currentStep;
  final int totalSteps;

  const FormStepGuide({
    super.key,
    required this.calculatorType,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = FormGuidanceData.getCalculatorSteps(calculatorType);

    if (steps.isEmpty) return const SizedBox.shrink();

    final clampedStep = currentStep.clamp(0, steps.length - 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? TaxNGColors.bgDarkSecondary
            : TaxNGColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A3E)
              : TaxNGColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, size: 18, color: TaxNGColors.primary),
              const SizedBox(width: 8),
              Text(
                'Step ${clampedStep + 1} of ${steps.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
              const Spacer(),
              // Progress indicator
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (clampedStep + 1) / steps.length,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? Colors.white12 : TaxNGColors.borderLight,
                    valueColor:
                        const AlwaysStoppedAnimation(TaxNGColors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Step indicators
          Row(
            children: List.generate(steps.length, (i) {
              final isCompleted = i < clampedStep;
              final isCurrent = i == clampedStep;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? TaxNGColors.success
                            : isCurrent
                                ? TaxNGColors.primary
                                : (isDark
                                    ? Colors.white12
                                    : TaxNGColors.borderLight),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white38
                                          : TaxNGColors.textLight),
                                ),
                              ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? TaxNGColors.success
                              : (isDark
                                  ? Colors.white12
                                  : TaxNGColors.borderLight),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Current step description
          Text(
            steps[clampedStep].title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TaxNGColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            steps[clampedStep].description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : TaxNGColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick-help tooltip button that shows field guidance in a bottom sheet.
/// More lightweight than FormFieldGuide — use for smaller spaces.
class QuickFieldHelp extends StatelessWidget {
  final String calculatorType;
  final String fieldName;
  final double? size;

  const QuickFieldHelp({
    super.key,
    required this.calculatorType,
    required this.fieldName,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final guidance = FormGuidanceData.getGuidance(calculatorType, fieldName);
    if (guidance == null) return const SizedBox.shrink();

    return IconButton(
      icon: Icon(Icons.info_outline_rounded, size: size ?? 20),
      color: TaxNGColors.primary,
      tooltip: 'Help: ${guidance.label}',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => _showGuidanceSheet(context, guidance),
    );
  }

  void _showGuidanceSheet(BuildContext context, FieldGuidance guidance) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.white24 : TaxNGColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: TaxNGColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(guidance.label,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : TaxNGColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // What is this
                  _SheetSection(
                      title: '📌 What is this?',
                      content: guidance.whatIsThis,
                      isDark: isDark),
                  _SheetSection(
                      title: '🔍 Where to find this',
                      content: guidance.howToFind,
                      isDark: isDark),
                  _SheetSection(
                      title: '💡 Example',
                      content: guidance.example,
                      isDark: isDark),

                  // Tips
                  Text('✅ Quick Tips',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : TaxNGColors.textDark)),
                  const SizedBox(height: 8),
                  ...guidance.tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(tip,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : TaxNGColors.textMedium)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),

                  // Nigerian context
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TaxNGColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: TaxNGColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🇳🇬', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nigerian Tax Context',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : TaxNGColors.textDark)),
                              const SizedBox(height: 4),
                              Text(guidance.nigerianContext,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white60
                                          : TaxNGColors.textMedium)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _SheetSection({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark)),
          const SizedBox(height: 4),
          Text(content,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : TaxNGColors.textMedium,
                  height: 1.5)),
        ],
      ),
    );
  }
}
