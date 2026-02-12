import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:taxng_advisor/services/data_import_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/services/user_activity_tracker.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';
import 'package:taxng_advisor/theme/colors.dart';
import 'package:intl/intl.dart';

/// Import Data Screen — parse CSV / Excel bank-statement data,
/// display in rows & columns, and show aggregated tax-relevant totals.
class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen>
    with SingleTickerProviderStateMixin {
  final _pasteController = TextEditingController();
  List<List<dynamic>> _parsedData = [];
  List<int> _amountColumns = [];
  int? _selectedAmountCol;
  String _selectedTaxType = 'VAT';
  bool _isLoading = false;
  String? _fileName;
  Map<String, dynamic> _aggregation = {};
  Map<String, double> _taxTotals = {};

  // Column mapping state
  Map<int, String> _columnMappings = {};
  bool _showMappingWizard = false;

  late TabController _tabController;

  final _currencyFormat = NumberFormat('#,##0.00');

  final _taxTypes = ['VAT', 'WHT', 'PIT', 'CIT', 'Payroll', 'Stamp Duty'];

  static const _mappingRoles = [
    'Auto',
    'Date',
    'Description',
    'Debit',
    'Credit',
    'Balance',
    'VAT Amount',
    'Amount',
    'Tax Status',
    'Ignore',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pasteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── File picker (CSV + Excel) ────────────────────────────────────

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'xlsx', 'xls', 'pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isLoading = true);

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        _showError('Could not read file data');
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';

      if (ext == 'xlsx' || ext == 'xls') {
        _processExcel(Uint8List.fromList(bytes), file.name);
      } else if (ext == 'pdf') {
        _processPdf(Uint8List.fromList(bytes), file.name);
      } else {
        final csvText = utf8.decode(bytes);
        _processData(csvText, file.name);
      }
    } catch (e) {
      _showError('Could not read file. Please check the format and try again.');
    }
  }

  // ─── Excel processing ─────────────────────────────────────────────

  void _processExcel(Uint8List bytes, String fileName) {
    try {
      final sheetNames = DataImportService.getExcelSheetNames(bytes);

      if (sheetNames.isEmpty) {
        _showError('No sheets found in the Excel file.');
        return;
      }

      if (sheetNames.length == 1) {
        final rows = DataImportService.parseExcel(bytes);
        _finishParsing(rows, fileName);
      } else {
        setState(() => _isLoading = false);
        _showSheetPicker(bytes, sheetNames, fileName);
      }
    } catch (e) {
      _showError(
          'Could not parse Excel file. Please ensure it is a valid .xlsx or .xls file.');
    }
  }

  void _showSheetPicker(Uint8List bytes, List<String> sheets, String fileName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Sheet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'This Excel file has ${sheets.length} sheets. Choose one to import.',
                style: const TextStyle(
                    fontSize: 13, color: TaxNGColors.textMedium),
              ),
              const SizedBox(height: 16),
              ...sheets.map((s) => ListTile(
                    leading: const Icon(Icons.table_chart_rounded,
                        color: TaxNGColors.primary),
                    title: Text(s),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _isLoading = true);
                      final rows =
                          DataImportService.parseExcel(bytes, sheetName: s);
                      _finishParsing(rows, '$fileName ($s)');
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ─── PDF processing ────────────────────────────────────────────────

  void _processPdf(Uint8List bytes, String fileName) {
    try {
      if (!DataImportService.isPdfTextBased(bytes)) {
        _showError(
          'This PDF appears to be scanned/image-based. '
          'Only text-based PDFs (digital bank statements) are supported.',
        );
        return;
      }

      final rows = DataImportService.parsePdf(bytes);
      if (rows.isEmpty) {
        _showError('Could not extract tabular data from this PDF.');
        return;
      }
      _finishParsing(rows, fileName);
    } catch (e) {
      _showError(
          'Could not process the PDF. It may be encrypted or unsupported.');
    }
  }

  // ─── Paste handler ────────────────────────────────────────────────

  void _handlePaste() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      _showError('Please paste CSV data first');
      return;
    }
    _processData(text, 'Pasted Data');
  }

  // ─── Load sample data ─────────────────────────────────────────────

  // ─── Core processing (CSV) ────────────────────────────────────────

  void _processData(String csvText, String fileName) {
    setState(() => _isLoading = true);

    try {
      final rows = DataImportService.parseCsv(csvText);
      _finishParsing(rows, fileName);
    } catch (e) {
      _showError(
          'Could not parse the data. Please check the format and try again.');
    }
  }

  /// Common finish for both CSV and Excel
  void _finishParsing(List<List<dynamic>> rows, String fileName) {
    if (rows.isEmpty || rows.length < 2) {
      _showError('No data rows found. Ensure the file has headers and data.');
      return;
    }

    final amountCols = DataImportService.detectAmountColumns(rows);

    // Initialize column mappings with "Auto"
    final mappings = <int, String>{};
    for (var i = 0; i < rows.first.length; i++) {
      mappings[i] = 'Auto';
    }

    setState(() {
      _parsedData = rows;
      _amountColumns = amountCols;
      _selectedAmountCol = amountCols.isNotEmpty ? amountCols.first : null;
      _fileName = fileName;
      _columnMappings = mappings;
      _showMappingWizard = false;
      _isLoading = false;
    });

    _recalculate();
  }

  void _recalculate() {
    if (_parsedData.isEmpty || _selectedAmountCol == null) return;

    int amountCol = _selectedAmountCol!;

    // Check if user manually mapped an "Amount" or "Debit" column
    _columnMappings.forEach((col, role) {
      if (role == 'Amount' || role == 'Debit') {
        amountCol = col;
      }
    });

    final agg = DataImportService.aggregateColumn(_parsedData, amountCol);

    // Find Tax Status column if user mapped one
    int? statusCol;
    _columnMappings.forEach((col, role) {
      if (role == 'Tax Status') statusCol = col;
    });
    // Also try auto-detecting from headers
    statusCol ??= DataImportService.detectTaxStatusColumn(_parsedData);

    Map<String, double> taxTotals;
    if (_selectedTaxType == 'VAT') {
      taxTotals = DataImportService.calculateVatTotals(_parsedData, amountCol);
    } else if (_selectedTaxType == 'WHT') {
      taxTotals = DataImportService.calculateWhtTotals(_parsedData, amountCol);
    } else if (_selectedTaxType == 'PIT' || _selectedTaxType == 'CIT') {
      // Use deduction-aware classification
      final deductions = DataImportService.calculateDeductionTotals(
        _parsedData,
        amountCol,
        statusCol: statusCol,
      );
      taxTotals = deductions;
    } else {
      final total = agg['sum'] as double;
      taxTotals = {'totalAmount': total};
    }

    setState(() {
      _aggregation = agg;
      _taxTotals = taxTotals;
    });

    _saveImportRecord();
  }

  Future<void> _saveImportRecord() async {
    final user = await AuthService.currentUser();
    if (user == null) return;
    await DataImportService.saveImport(
      userId: user.id,
      fileName: _fileName ?? 'Unknown',
      data: _parsedData,
      taxType: _selectedTaxType,
      columnMappings: _columnMappings,
      taxTotals: _taxTotals,
      aggregation: _aggregation,
    );

    // Track data import for admin analytics
    UserActivityTracker.trackDataImport(
      _fileName ?? 'Unknown',
      taxType: _selectedTaxType,
    );
  }

  void _showError(String msg) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: TaxNGColors.error),
      );
    }
  }

  // ─── Navigate to tax calculator ───────────────────────────────────

  void _navigateToCalculator(String taxType) {
    final routeMap = {
      'VAT': '/vat',
      'WHT': '/wht',
      'PIT': '/pit',
      'CIT': '/cit',
      'Payroll': '/payroll',
      'Stamp Duty': '/stamp_duty',
    };

    final route = routeMap[taxType];
    if (route == null || !mounted) return;

    // Build calculator-specific arguments from parsed totals
    final args = _buildCalculatorArgs(taxType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Applying imported data to the $taxType calculator…',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: TaxNGColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushNamed(context, route, arguments: args);
      }
    });
  }

  /// Maps parsed tax totals to calculator field names.
  Map<String, dynamic> _buildCalculatorArgs(String taxType) {
    switch (taxType) {
      case 'VAT':
        return {
          'standardSales':
              _taxTotals['standardRated'] ?? _taxTotals['totalAmount'] ?? 0,
          'zeroRatedSales': _taxTotals['zeroRated'] ?? 0,
          'exemptSales': _taxTotals['exempt'] ?? 0,
          'totalInputVat': _taxTotals['inputVat'] ?? 0,
          'exemptInputVat': _taxTotals['exemptInputVat'] ?? 0,
        };
      case 'PIT':
        return {
          'grossIncome':
              _taxTotals['totalIncome'] ?? _taxTotals['totalAmount'] ?? 0,
          'otherDeductions':
              _taxTotals['totalDeductions'] ?? _taxTotals['deductible'] ?? 0,
          'annualRentPaid': 0,
        };
      case 'CIT':
        return {
          'turnover':
              _taxTotals['totalIncome'] ?? _taxTotals['totalAmount'] ?? 0,
          'profit': (_taxTotals['totalIncome'] ??
                  _taxTotals['totalAmount'] ??
                  0) -
              (_taxTotals['totalDeductions'] ?? _taxTotals['deductible'] ?? 0),
        };
      case 'WHT':
        return {
          'amount': _taxTotals['totalAmount'] ?? 0,
        };
      case 'Payroll':
        return {
          'monthlyGross': (_taxTotals['totalAmount'] ?? 0) / 12,
        };
      case 'Stamp Duty':
        return {
          'amount': _taxTotals['totalAmount'] ?? 0,
        };
      default:
        return {};
    }
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const TaxNGAppBar(title: 'Import Data'),
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputSection(isDark),
                  const SizedBox(height: 16),
                  if (_parsedData.isNotEmpty) ...[
                    _buildTabBar(isDark),
                    const SizedBox(height: 16),

                    // Column Mapping Wizard toggle
                    _buildMappingToggle(isDark),
                    if (_showMappingWizard) ...[
                      const SizedBox(height: 12),
                      _buildMappingWizard(isDark),
                    ],
                    const SizedBox(height: 16),

                    // Tab content
                    SizedBox(
                      height: _getTabContentHeight(),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSummaryTab(isDark),
                          _buildDataTab(isDark),
                          _buildChartsTab(isDark),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  double _getTabContentHeight() {
    if (_parsedData.isEmpty) return 200;
    final dataRowCount = _parsedData.length - 1;
    return (dataRowCount * 42.0 + 200).clamp(400, 1200);
  }

  // ─── Input Section ────────────────────────────────────────────────

  Widget _buildInputSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TaxNGColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.upload_file_rounded,
                    color: TaxNGColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : TaxNGColors.textDark,
                      ),
                    ),
                    Text(
                      'CSV, Excel, PDF • Bank statements, invoices, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : TaxNGColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pasteController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Paste CSV or JSON data here…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.white24 : TaxNGColors.borderMedium),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.white24 : TaxNGColors.borderLight),
              ),
              filled: true,
              fillColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
            ),
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : TaxNGColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const _SampleDataScreen()),
                  ),
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('View Data Format'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaxNGColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: const Text('Choose File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaxNGColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handlePaste,
                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: const Text('Import'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaxNGColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle,
                    color: TaxNGColors.success, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$_fileName — ${_parsedData.length - 1} rows, ${_parsedData.isNotEmpty ? _parsedData.first.length : 0} columns',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : TaxNGColors.textMedium,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/import-history'),
                  icon: const Icon(Icons.history_rounded, size: 20),
                  tooltip: 'Import History',
                  color: TaxNGColors.primary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: TaxNGColors.primary,
        indicatorWeight: 3,
        labelColor: TaxNGColors.primary,
        unselectedLabelColor: isDark ? Colors.white54 : TaxNGColors.textMedium,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(icon: Icon(Icons.analytics_rounded, size: 18), text: 'Summary'),
          Tab(icon: Icon(Icons.table_chart_rounded, size: 18), text: 'Data'),
          Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Charts'),
        ],
      ),
    );
  }

  // ─── Column Mapping Wizard Toggle ─────────────────────────────────

  Widget _buildMappingToggle(bool isDark) {
    return InkWell(
      onTap: () => setState(() => _showMappingWizard = !_showMappingWizard),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? TaxNGColors.bgDarkSecondary
              : TaxNGColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TaxNGColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.settings_input_component_rounded,
                color: TaxNGColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Column Mapping Wizard',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : TaxNGColors.textDark,
                    ),
                  ),
                  Text(
                    'Map columns to tax fields for accurate calculations',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : TaxNGColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _showMappingWizard
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: TaxNGColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Column Mapping Wizard ────────────────────────────────────────

  Widget _buildMappingWizard(bool isDark) {
    if (_parsedData.isEmpty) return const SizedBox();
    final headers = _parsedData.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded,
                  color: TaxNGColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Map Each Column',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final m = <int, String>{};
                  for (var i = 0; i < headers.length; i++) {
                    m[i] = 'Auto';
                  }
                  setState(() => _columnMappings = m);
                  _recalculate();
                },
                child: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            headers.length,
            (col) {
              final headerName = headers[col].toString();
              final sampleValue =
                  _parsedData.length > 1 && col < _parsedData[1].length
                      ? _parsedData[1][col].toString()
                      : '—';
              final currentRole = _columnMappings[col] ?? 'Auto';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : TaxNGColors.bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headerName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : TaxNGColors.textDark,
                            ),
                          ),
                          Text(
                            'e.g. $sampleValue',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : TaxNGColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: TaxNGColors.textLight),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: currentRole != 'Auto'
                                ? TaxNGColors.primary
                                : (isDark
                                    ? Colors.white24
                                    : TaxNGColors.borderMedium),
                          ),
                          color: currentRole != 'Auto'
                              ? TaxNGColors.primary.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: DropdownButton<String>(
                          value: currentRole,
                          isExpanded: true,
                          underline: const SizedBox(),
                          isDense: true,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : TaxNGColors.textDark,
                          ),
                          items: _mappingRoles
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _columnMappings[col] = v);
                              if (v == 'Amount' ||
                                  v == 'Debit' ||
                                  v == 'Credit') {
                                setState(() => _selectedAmountCol = col);
                              }
                              _recalculate();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _recalculate();
                setState(() => _showMappingWizard = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Column mappings applied!'),
                      backgroundColor: TaxNGColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Apply Mappings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TaxNGColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Summary Tab ──────────────────────────────────────────────────

  Widget _buildSummaryTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTaxSummaryCards(isDark),
          const SizedBox(height: 16),
          _buildColumnSelector(isDark),
          const SizedBox(height: 16),
          _buildAggregationCard(isDark),
        ],
      ),
    );
  }

  // ─── Data Tab ─────────────────────────────────────────────────────

  Widget _buildDataTab(bool isDark) {
    return SingleChildScrollView(child: _buildDataTable(isDark));
  }

  // ─── Charts Tab ───────────────────────────────────────────────────

  Widget _buildChartsTab(bool isDark) {
    if (_parsedData.isEmpty || _selectedAmountCol == null) {
      return Center(
        child: Text(
          'Import data to see charts',
          style: TextStyle(
            color: isDark ? Colors.white54 : TaxNGColors.textLight,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAmountBarChart(isDark),
          const SizedBox(height: 20),
          _buildCategoryPieChart(isDark),
          const SizedBox(height: 20),
          _buildTaxBreakdownChart(isDark),
        ],
      ),
    );
  }

  // ─── Bar Chart: Amount per row ────────────────────────────────────

  Widget _buildAmountBarChart(bool isDark) {
    final dataRows = _parsedData.sublist(1);
    final descCol = DataImportService.detectDescriptionColumn(_parsedData);
    final amountCol = _selectedAmountCol!;

    final displayRows = dataRows.take(10).toList();

    final barGroups = <BarChartGroupData>[];
    double maxVal = 0;

    for (var i = 0; i < displayRows.length; i++) {
      final row = displayRows[i];
      final val = _parseNumeric(amountCol < row.length ? row[amountCol] : 0);
      if (val.abs() > maxVal) maxVal = val.abs();
      barGroups.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: val.abs(),
            width: 16,
            color: TaxNGColors.chartColors[i % TaxNGColors.chartColors.length],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: TaxNGColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Amount Distribution',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIdx, rod, rodIdx) {
                      final row = displayRows[group.x];
                      final label = descCol != null && descCol < row.length
                          ? row[descCol].toString()
                          : 'Row ${group.x + 1}';
                      return BarTooltipItem(
                        '$label\n₦${_currencyFormat.format(rod.toY)}',
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= displayRows.length) {
                          return const SizedBox();
                        }
                        final row = displayRows[idx];
                        String label;
                        if (descCol != null && descCol < row.length) {
                          label = row[descCol].toString();
                          if (label.length > 8) {
                            label = '${label.substring(0, 8)}…';
                          }
                        } else {
                          label = '${idx + 1}';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: isDark
                                      ? Colors.white54
                                      : TaxNGColors.textLight)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _shortNumber(value),
                          style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white38
                                  : TaxNGColors.textLight),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white12 : TaxNGColors.borderLight,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          if (dataRows.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Showing first 10 of ${dataRows.length} entries',
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : TaxNGColors.textLight),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Pie Chart: Category breakdown ────────────────────────────────

  Widget _buildCategoryPieChart(bool isDark) {
    final descCol = DataImportService.detectDescriptionColumn(_parsedData);
    if (descCol == null || _selectedAmountCol == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No description column detected for category breakdown',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : TaxNGColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final grouped = DataImportService.groupByAndSum(
        _parsedData, descCol, _selectedAmountCol!);
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final topEntries = sortedEntries.take(6).toList();
    double otherTotal = 0;
    for (var i = 6; i < sortedEntries.length; i++) {
      otherTotal += sortedEntries[i].value.abs();
    }

    final sections = <PieChartSectionData>[];
    final legendItems = <_LegendItem>[];

    final total =
        topEntries.fold<double>(0, (s, e) => s + e.value.abs()) + otherTotal;

    for (var i = 0; i < topEntries.length; i++) {
      final entry = topEntries[i];
      final pct = total > 0 ? (entry.value.abs() / total * 100) : 0.0;
      final color = TaxNGColors.chartColors[i % TaxNGColors.chartColors.length];
      sections.add(PieChartSectionData(
        value: entry.value.abs(),
        color: color,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
        radius: 50,
      ));
      legendItems.add(_LegendItem(
          entry.key, color, '₦${_currencyFormat.format(entry.value.abs())}'));
    }

    if (otherTotal > 0) {
      final pct = total > 0 ? (otherTotal / total * 100) : 0.0;
      sections.add(PieChartSectionData(
        value: otherTotal,
        color: TaxNGColors.textLight,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
        radius: 50,
      ));
      legendItems.add(_LegendItem('Other', TaxNGColors.textLight,
          '₦${_currencyFormat.format(otherTotal)}'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded,
                  color: TaxNGColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: item.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.label.length > 18
                                          ? '${item.label.substring(0, 18)}…'
                                          : item.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white70
                                            : TaxNGColors.textMedium,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.value,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : TaxNGColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tax Breakdown Chart ──────────────────────────────────────────

  Widget _buildTaxBreakdownChart(bool isDark) {
    if (_taxTotals.isEmpty) return const SizedBox();

    final entries = _taxTotals.entries.toList();
    final maxVal = entries.fold<double>(
        0, (m, e) => e.value.abs() > m ? e.value.abs() : m);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded,
                  color: TaxNGColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '$_selectedTaxType Tax Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            final pct = maxVal > 0 ? entry.value.abs() / maxVal : 0.0;
            final color =
                TaxNGColors.chartColors[idx % TaxNGColors.chartColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatLabel(entry.key),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white70 : TaxNGColors.textMedium,
                        ),
                      ),
                      Text(
                        '₦${_currencyFormat.format(entry.value)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : TaxNGColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor:
                          isDark ? Colors.white12 : TaxNGColors.borderLight,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Tax Summary Cards ────────────────────────────────────────────

  Widget _buildTaxSummaryCards(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: TaxNGColors.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tax Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedTaxType,
                  dropdownColor: TaxNGColors.primaryDark,
                  underline: const SizedBox(),
                  isDense: true,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: _taxTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedTaxType = v);
                      _recalculate();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Assessed values — shows what each value maps to in the calculator
          _buildAssessedValues(),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToCalculator(_selectedTaxType),
              icon: const Icon(Icons.send, size: 18),
              label: Text('Apply to $_selectedTaxType Calculator'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TaxNGColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Assessed Values Display ──────────────────────────────────────

  /// Build the assessed-values display that shows which values
  /// from the imported data will map to which calculator field,
  /// displayed above the "Apply to Calculator" button.
  Widget _buildAssessedValues() {
    final args = _buildCalculatorArgs(_selectedTaxType);
    if (args.isEmpty) return const SizedBox();

    // Build descriptive field labels per tax type
    final fieldDescriptions = _getFieldDescriptions(_selectedTaxType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[300], size: 16),
              const SizedBox(width: 6),
              const Text(
                'Assessed Values for Calculator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...args.entries.map((entry) {
            final fieldName = entry.key;
            final value =
                (entry.value is num) ? (entry.value as num).toDouble() : 0.0;
            final description =
                fieldDescriptions[fieldName] ?? _formatLabel(fieldName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    _getFieldIcon(fieldName),
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '₦${_currencyFormat.format(value)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Colors.white24, height: 16),
          // Evidence note
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  color: Colors.greenAccent[200], size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Import saved as evidence  •  ${_parsedData.length - 1} rows analysed from ${_fileName ?? "file"}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/import-history'),
                child: Text(
                  'View History',
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.amber[300],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns human-readable descriptions for each calculator field per tax type.
  Map<String, String> _getFieldDescriptions(String taxType) {
    switch (taxType) {
      case 'VAT':
        return {
          'standardSales': 'Standard-Rated Sales (7.5%)',
          'zeroRatedSales': 'Zero-Rated Sales (0%)',
          'exemptSales': 'VAT Exempt Sales',
          'totalInputVat': 'Input VAT (Purchases)',
          'exemptInputVat': 'Exempt Input VAT',
        };
      case 'PIT':
        return {
          'grossIncome': 'Gross Annual Income',
          'otherDeductions': 'Allowable Deductions',
          'annualRentPaid': 'Annual Rent Paid',
        };
      case 'CIT':
        return {
          'turnover': 'Business Turnover (Revenue)',
          'profit': 'Assessable Profit (Income − Deductions)',
        };
      case 'WHT':
        return {
          'amount': 'Transaction Amount (WHT Base)',
        };
      case 'Payroll':
        return {
          'monthlyGross': 'Monthly Gross Salary (Annual ÷ 12)',
        };
      case 'Stamp Duty':
        return {
          'amount': 'Instrument Value (Stamp Duty Base)',
        };
      default:
        return {};
    }
  }

  /// Returns an appropriate icon for each calculator field.
  IconData _getFieldIcon(String fieldName) {
    switch (fieldName) {
      case 'standardSales':
      case 'turnover':
      case 'grossIncome':
        return Icons.trending_up;
      case 'zeroRatedSales':
        return Icons.money_off;
      case 'exemptSales':
      case 'exemptInputVat':
        return Icons.block;
      case 'totalInputVat':
        return Icons.shopping_cart;
      case 'otherDeductions':
      case 'profit':
        return Icons.remove_circle_outline;
      case 'annualRentPaid':
        return Icons.home;
      case 'amount':
        return Icons.attach_money;
      case 'monthlyGross':
        return Icons.payments;
      default:
        return Icons.label_outline;
    }
  }

  String _formatLabel(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim()
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  // ─── Column Selector ──────────────────────────────────────────────

  Widget _buildColumnSelector(bool isDark) {
    if (_amountColumns.isEmpty || _parsedData.isEmpty) {
      return const SizedBox();
    }
    final headers = _parsedData.first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.view_column_rounded,
              color: TaxNGColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            'Amount Column:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : TaxNGColors.textDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: _amountColumns.map((col) {
                final name =
                    col < headers.length ? headers[col].toString() : 'Col $col';
                final isSelected = col == _selectedAmountCol;
                return ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  selectedColor: TaxNGColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : TaxNGColors.textDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedAmountCol = col);
                    _recalculate();
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Aggregation Card ─────────────────────────────────────────────

  Widget _buildAggregationCard(bool isDark) {
    if (_aggregation.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_rounded,
                  color: TaxNGColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Column Statistics',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statRow('Sum',
              '₦${_currencyFormat.format(_aggregation['sum'] ?? 0)}', isDark),
          _statRow('Count', '${_aggregation['count'] ?? 0} items', isDark),
          _statRow('Average',
              '₦${_currencyFormat.format(_aggregation['avg'] ?? 0)}', isDark),
          _statRow('Min',
              '₦${_currencyFormat.format(_aggregation['min'] ?? 0)}', isDark),
          _statRow('Max',
              '₦${_currencyFormat.format(_aggregation['max'] ?? 0)}', isDark),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : TaxNGColors.textMedium)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : TaxNGColors.textDark)),
        ],
      ),
    );
  }

  // ─── Data Table ───────────────────────────────────────────────────

  Widget _buildDataTable(bool isDark) {
    if (_parsedData.isEmpty) return const SizedBox();
    final headers = _parsedData.first;
    final dataRows = _parsedData.sublist(1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded,
                    color: TaxNGColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Data Preview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : TaxNGColors.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${dataRows.length} rows',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : TaxNGColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                isDark
                    ? TaxNGColors.primaryDark.withValues(alpha: 0.3)
                    : TaxNGColors.primary.withValues(alpha: 0.08),
              ),
              columnSpacing: 20,
              horizontalMargin: 16,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 42,
              headingRowHeight: 44,
              columns: headers
                  .asMap()
                  .entries
                  .map((e) => DataColumn(
                        label: Text(
                          e.value.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _amountColumns.contains(e.key)
                                ? TaxNGColors.primary
                                : (isDark
                                    ? Colors.white
                                    : TaxNGColors.textDark),
                          ),
                        ),
                      ))
                  .toList(),
              rows: dataRows.take(50).map((row) {
                return DataRow(
                  cells: List.generate(headers.length, (col) {
                    final value = col < row.length ? row[col] : '';
                    final isAmount = _amountColumns.contains(col);
                    return DataCell(
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isAmount ? FontWeight.w600 : FontWeight.w400,
                          color: isAmount
                              ? TaxNGColors.primary
                              : (isDark
                                  ? Colors.white70
                                  : TaxNGColors.textDark),
                        ),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
          if (dataRows.length > 50)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Showing first 50 of ${dataRows.length} rows',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : TaxNGColors.textLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  double _parseNumeric(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').replaceAll(' ', '').trim();
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  String _shortNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}

/// Legend item for pie chart
class _LegendItem {
  final String label;
  final Color color;
  final String value;

  _LegendItem(this.label, this.color, this.value);
}

// ─── Sample Data Screen ─────────────────────────────────────────────

class _SampleDataScreen extends StatelessWidget {
  const _SampleDataScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const TaxNGAppBar(title: 'Sample Data Formats'),
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: TaxNGColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.data_object, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Sample Import Formats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Copy any of the sample data below and paste it into the Import Data screen to test the import feature.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CSV Sample
            _buildSampleCard(
              context,
              isDark: isDark,
              title: 'CSV Format — Bank Statement',
              icon: Icons.table_chart,
              iconColor: TaxNGColors.primary,
              description:
                  'Standard bank statement format with Date, Description, Debit, Credit, and Balance columns.',
              sampleData: '''Date,Description,Debit,Credit,Balance
2026-01-05,Transfer from ABC Ltd,0,250000,1250000
2026-01-08,Payment to Vendor X,85000,0,1165000
2026-01-10,VAT Refund,0,12500,1177500
2026-01-12,Office Rent Payment,350000,0,827500
2026-01-15,Invoice Payment - Client Y,0,1500000,2327500
2026-01-18,Utility Bills,45000,0,2282500
2026-01-20,Staff Salary - January,800000,0,1482500
2026-01-22,Consulting Fee Received,0,600000,2082500
2026-01-25,Equipment Purchase,175000,0,1907500
2026-01-28,Monthly Service Charge,2500,0,1905000''',
            ),
            const SizedBox(height: 16),

            // JSON Sample
            _buildSampleCard(
              context,
              isDark: isDark,
              title: 'JSON Format — Invoices',
              icon: Icons.data_object,
              iconColor: Colors.orange[700]!,
              description:
                  'JSON array format suitable for invoice or transaction data.',
              sampleData: '''[
  {"date": "2026-01-05", "description": "Invoice #001 - Web Design", "amount": 450000, "vat": 33750},
  {"date": "2026-01-10", "description": "Invoice #002 - Consulting", "amount": 280000, "vat": 21000},
  {"date": "2026-01-15", "description": "Invoice #003 - Development", "amount": 750000, "vat": 56250},
  {"date": "2026-01-20", "description": "Invoice #004 - Maintenance", "amount": 120000, "vat": 9000},
  {"date": "2026-01-25", "description": "Invoice #005 - Training", "amount": 350000, "vat": 26250}
]''',
            ),
            const SizedBox(height: 16),

            // CSV Sales Sample
            _buildSampleCard(
              context,
              isDark: isDark,
              title: 'CSV Format — Sales Records',
              icon: Icons.receipt_long,
              iconColor: Colors.blue[700]!,
              description:
                  'Sales data format with Item, Quantity, Unit Price, Total, and VAT columns.',
              sampleData: '''Item,Quantity,Unit Price,Total,VAT
Laptop HP EliteBook,5,450000,2250000,168750
Printer Canon LBP,10,85000,850000,63750
Office Chair Ergonomic,20,65000,1300000,97500
Desktop Dell OptiPlex,3,350000,1050000,78750
Monitor Samsung 27inch,8,120000,960000,72000
Keyboard & Mouse Set,50,15000,750000,56250
UPS APC 1500VA,15,45000,675000,50625''',
            ),
            const SizedBox(height: 16),

            // Payroll Sample
            _buildSampleCard(
              context,
              isDark: isDark,
              title: 'CSV Format — Payroll',
              icon: Icons.people,
              iconColor: Colors.purple[700]!,
              description:
                  'Payroll data format with employee details, gross pay, tax, and net pay.',
              sampleData:
                  '''Employee,Grade,Gross Pay,Tax (PAYE),Pension,NHF,Net Pay
Adebayo Okafor,Manager,850000,127500,68000,21250,633250
Chioma Nwosu,Senior Dev,650000,97500,52000,16250,484250
Emeka Abiodun,Accountant,500000,75000,40000,12500,372500
Fatima Ibrahim,HR Lead,550000,82500,44000,13750,409750
Gabriel Eze,Designer,450000,67500,36000,11250,335250''',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required String sampleData,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : TaxNGColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : TaxNGColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? TaxNGColors.bgDark : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE5E7EB),
              ),
            ),
            child: SelectableText(
              sampleData,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.5,
                color: isDark ? Colors.white70 : TaxNGColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Copy to clipboard
                    final data = ClipboardData(text: sampleData);
                    Clipboard.setData(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sample data copied to clipboard!'),
                        backgroundColor: TaxNGColors.primary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TaxNGColors.primary,
                    side: const BorderSide(color: TaxNGColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Pop back and the user can paste
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back to Import'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaxNGColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
