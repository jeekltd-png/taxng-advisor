/// Content for VAT Calculator help dialogs and information sections
class VatHelpContent {
  // Standard-Rated Sales Info
  static const standardSalesWhatItMeans =
      'Total sales of goods and services subject to 7.5% VAT rate. This is the most common category for business transactions.';
  static const standardSalesExample =
      'If you sold goods worth ₦7,000,000, you should charge customers ₦525,000 VAT (7.5%), making total invoice ₦7,525,000.';
  static const standardSalesHowCalculated =
      'Output VAT = Standard Sales × 7.5%. This is the VAT you collect from customers and must remit to FIRS.';

  // Zero-Rated Sales Info
  static const zeroRatedSalesWhatItMeans =
      'Supplies taxed at 0% VAT rate. Includes exports, goods/services sold in free trade zones, and items used for humanitarian purposes.';
  static const zeroRatedSalesExample =
      'If you exported goods worth ₦3,000,000, you charge 0% VAT but can still recover input VAT on related purchases.';
  static const zeroRatedSalesKeyBenefit =
      'Unlike exempt supplies, zero-rated supplies allow you to recover input VAT, improving cash flow.';

  // Exempt Sales Info
  static const exemptSalesWhatItMeans =
      'Supplies that are not subject to VAT. Includes medical services, educational services, basic food items, pharmaceuticals, and financial services.';
  static const exemptSalesExample =
      'A hospital providing ₦1,500,000 worth of medical services does not charge VAT to patients.';
  static const exemptSalesImportant =
      'Input VAT on purchases related to exempt supplies CANNOT be recovered. You must track and allocate exempt input VAT separately.';

  // Total Input VAT Info
  static const totalInputVatWhatItMeans =
      'Total VAT you paid on purchases, expenses, and imports during the period. This is VAT incurred on business inputs.';
  static const totalInputVatExample =
      'If you purchased ₦11,333,333 worth of goods/services, you paid ₦850,000 VAT (7.5%) that can be offset against output VAT.';
  static const totalInputVatHowUsed =
      'Net VAT Payable = Output VAT - Recoverable Input VAT. Input VAT reduces your tax burden.';

  // Exempt Input VAT Info
  static const exemptInputVatWhatItMeans =
      'VAT paid on purchases specifically used for making exempt supplies. This VAT cannot be recovered.';
  static const exemptInputVatExample =
      'A private school (exempt) buys furniture for ₦1,000,000 + ₦75,000 VAT. The ₦75,000 VAT cannot be claimed back.';
  static const exemptInputVatHowUsed =
      'Recoverable Input VAT = Total Input VAT - Exempt Input VAT. Proper allocation is critical for accurate returns.';

  // VAT Refund Process
  static const refundProcessWhatItMeans =
      'When your input VAT (VAT paid on purchases) exceeds your output VAT (VAT collected from sales), you are entitled to claim a refund from FIRS.';
  static const refundProcessRequirements =
      '1. File VAT return (Form 002) showing refund position\n2. Submit formal refund claim letter to FIRS Chairman\n3. Provide reconciliation report with detailed calculations\n4. Attach supporting documents (purchase invoices, sales records, bank statements)\n5. Keep all records for 6 years for potential audit';
  static const refundProcessTimeline =
      'FIRS typically processes refund claims within 90 days, subject to verification and audit. Ensure all documentation is complete and accurate to avoid delays.';
  static const refundProcessHowToUse =
      '1. Click "Form 002" to generate the VAT return form\n2. Click "Refund Letter" to create the formal claim letter\n3. Click "Reconciliation" to generate the detailed breakdown\n4. Attach supporting documents using the buttons below\n5. Print or save all PDFs\n6. Submit complete package to FIRS within 21 days';

  // Form 002 Info
  static const form002WhatItIs =
      'Form 002 is the official Federal Inland Revenue Service (FIRS) VAT Return form. All VAT-registered businesses must file this monthly.';
  static const form002WhatItContains =
      '• Company details (TIN, name, address)\n• VAT period (month/year)\n• Standard-rated, zero-rated, and exempt sales\n• Total output VAT\n• Input VAT on purchases\n• Net VAT payable or refundable\n• Authorized signatory declaration';
  static const form002WhenToUse =
      'Generate this form when filing your monthly VAT return, especially when claiming a refund. Submit to FIRS within 21 days of the end of the VAT period.';
  static const form002HowToUse =
      '1. Click the "Form 002" button\n2. Enter your business details (TIN, address)\n3. Specify the VAT period (month/year)\n4. Enter contact information\n5. The form will auto-populate with your calculations\n6. Review the generated PDF\n7. Print or save to submit to FIRS';

  // Refund Letter Info
  static const refundLetterWhatItIs =
      'A formal letter addressed to the Executive Chairman of FIRS requesting payment of your VAT refund to your bank account.';
  static const refundLetterWhatItContains =
      '• Company details and TIN\n• VAT period and refund amount\n• Explanation of refund position\n• Bank account details for payment\n• Reference to attached Form 002 and supporting documents\n• Request for prompt processing\n• Contact person and phone number';
  static const refundLetterImportant =
      'This letter must be submitted together with Form 002, reconciliation report, and all supporting documents. Keep a copy for your records.';
  static const refundLetterHowToUse =
      '1. Click the "Refund Letter" button\n2. Enter your business details (TIN, company name, address)\n3. Provide bank account details for refund payment\n4. Specify contact person and phone number\n5. The letter will be auto-generated with refund amount\n6. Review and save the PDF\n7. Submit with Form 002 and supporting documents';

  // Reconciliation Report Info
  static const reconciliationWhatItIs =
      'A detailed breakdown of your VAT calculations showing how you arrived at the refund position. Essential for FIRS audit verification.';
  static const reconciliationWhatItContains =
      '• Summary of sales (standard-rated, zero-rated, exempt)\n• Output VAT calculation\n• Summary of purchases and input VAT\n• Exempt purchases calculation\n• VAT calculation showing refund position\n• Detailed line-by-line breakdown\n• Cross-reference to supporting invoices';
  static const reconciliationWhyItMatters =
      'FIRS requires this report to verify your refund claim is accurate and supported by proper documentation. It demonstrates transparency and compliance with tax regulations.';
  static const reconciliationHowToUse =
      '1. Click the "Reconciliation" button\n2. Enter your business details (TIN, company name)\n3. Specify the VAT period being reconciled\n4. The report will auto-generate with all calculations\n5. Review the detailed breakdown\n6. Save the PDF for FIRS submission\n7. Keep a copy for your audit trail';

  // Document Vault Info
  static const documentVaultWhatItIs =
      'A secure storage system for organizing and attaching invoices, receipts, and bank statements as evidence for your VAT calculations and refund claims.';
  static const documentVaultWhyItMatters =
      'FIRS requires supporting documentation to verify VAT returns and refund claims. You must keep all invoices and records for at least 6 years for potential audit.';
  static const documentVaultWhatToAttach =
      '• Purchase invoices showing input VAT\n• Sales invoices showing output VAT\n• Bank statements proving transactions\n• Import documentation\n• Credit/debit notes\n• Any other relevant receipts';
  static const documentVaultBestPractice =
      'Attach documents immediately after transactions to build a complete audit trail. Organize by VAT period and document type.';
  static const documentVaultHowToUse =
      '1. Click the document type button (Purchase Invoice, Sales Invoice, or Bank Statement)\n2. Select the file from your device\n3. Enter document details (amount, VAT amount, description)\n4. Specify the VAT period (month/year)\n5. Click "Upload" to save the document\n6. Click "View All" to see all attached documents\n7. Documents are organized by period for easy retrieval';
}
