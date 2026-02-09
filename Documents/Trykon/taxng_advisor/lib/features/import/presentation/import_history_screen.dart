import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/data_import_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/widgets/common/taxng_app_bar.dart';
import 'package:taxng_advisor/theme/colors.dart';
import 'package:intl/intl.dart';

/// Import History Screen — list all past data imports with details
/// and ability to re-view the imported data.
class ImportHistoryScreen extends StatefulWidget {
  const ImportHistoryScreen({super.key});

  @override
  State<ImportHistoryScreen> createState() => _ImportHistoryScreenState();
}

class _ImportHistoryScreenState extends State<ImportHistoryScreen> {
  List<Map<String, dynamic>> _imports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImports();
  }

  Future<void> _loadImports() async {
    setState(() => _isLoading = true);
    final user = await AuthService.currentUser();
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final imports = await DataImportService.getImports(user.id);
    // Reverse so newest first
    if (mounted) {
      setState(() {
        _imports = imports.reversed.toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteImport(String importId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Import'),
        content:
            const Text('Are you sure you want to delete this import record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: TaxNGColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = await AuthService.currentUser();
      if (user != null) {
        await DataImportService.deleteImport(user.id, importId);
        _loadImports();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import deleted'),
              backgroundColor: TaxNGColors.success,
            ),
          );
        }
      }
    }
  }

  Future<void> _viewImport(Map<String, dynamic> imp) async {
    final importId = imp['id'] as String;
    final data = await DataImportService.getImportData(importId);

    if (data == null || data.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data not available for this import'),
            backgroundColor: TaxNGColors.warning,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImportDetailScreen(
            importRecord: imp,
            data: data,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const TaxNGAppBar(title: 'Import History'),
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imports.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadImports,
                  color: TaxNGColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _imports.length + 1,
                    itemBuilder: (ctx, idx) {
                      if (idx == 0) return _buildHeader(isDark);
                      return _buildImportCard(_imports[idx - 1], isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: TaxNGColors.heroGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Imports',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_imports.length} import${_imports.length == 1 ? '' : 's'} on record',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined,
                size: 64,
                color: isDark ? Colors.white24 : TaxNGColors.textLighter),
            const SizedBox(height: 16),
            Text(
              'No imports yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : TaxNGColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Import a CSV or Excel file to see your history here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : TaxNGColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/import-data'),
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Import Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TaxNGColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard(Map<String, dynamic> imp, bool isDark) {
    final fileName = imp['fileName'] ?? 'Unknown';
    final rowCount = imp['rowCount'] ?? 0;
    final colCount = imp['colCount'] ?? 0;
    final taxType = imp['taxType'] ?? '';
    final importedAt = imp['importedAt'] ?? '';
    final headers = List<String>.from(imp['headers'] ?? []);
    final importId = imp['id'] as String;

    DateTime? dt;
    try {
      dt = DateTime.parse(importedAt);
    } catch (_) {}

    final dateStr =
        dt != null ? DateFormat('MMM d, yyyy · h:mm a').format(dt) : '—';

    IconData taxIcon;
    Color taxColor;
    switch (taxType) {
      case 'VAT':
        taxIcon = Icons.receipt_long_rounded;
        taxColor = TaxNGColors.primary;
        break;
      case 'WHT':
        taxIcon = Icons.payment_rounded;
        taxColor = TaxNGColors.info;
        break;
      case 'PIT':
        taxIcon = Icons.person_rounded;
        taxColor = TaxNGColors.warning;
        break;
      case 'CIT':
        taxIcon = Icons.business_rounded;
        taxColor = TaxNGColors.secondary;
        break;
      default:
        taxIcon = Icons.calculate_rounded;
        taxColor = TaxNGColors.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewImport(imp),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: taxColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(taxIcon, color: taxColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  isDark ? Colors.white : TaxNGColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white54
                                  : TaxNGColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tax type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: taxColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        taxType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: taxColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'view') {
                          _viewImport(imp);
                        } else if (v == 'delete') {
                          _deleteImport(importId);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'view', child: Text('View Data')),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: TextStyle(color: TaxNGColors.error))),
                      ],
                      icon: Icon(Icons.more_vert_rounded,
                          size: 18,
                          color:
                              isDark ? Colors.white54 : TaxNGColors.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    _statBadge(
                        Icons.table_rows_rounded, '$rowCount rows', isDark),
                    const SizedBox(width: 12),
                    _statBadge(
                        Icons.view_column_rounded, '$colCount cols', isDark),
                    if (headers.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          headers.take(3).join(', ') +
                              (headers.length > 3
                                  ? ' +${headers.length - 3}'
                                  : ''),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark ? Colors.white38 : TaxNGColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14, color: isDark ? Colors.white54 : TaxNGColors.textLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : TaxNGColors.textMedium,
          ),
        ),
      ],
    );
  }
}

// ─── Import Detail Screen (re-view saved data) ─────────────────────

class _ImportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> importRecord;
  final List<List<dynamic>> data;

  const _ImportDetailScreen({
    required this.importRecord,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = importRecord['fileName'] ?? 'Import Detail';
    final headers = data.isNotEmpty ? data.first : [];
    final dataRows = data.length > 1 ? data.sublist(1) : <List<dynamic>>[];
    final currencyFormat = NumberFormat('#,##0.00');

    // Detect amount columns for highlighting
    final amountCols = DataImportService.detectAmountColumns(data);

    return Scaffold(
      appBar: TaxNGAppBar(title: fileName),
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      body: data.isEmpty
          ? const Center(child: Text('No data available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: TaxNGColors.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${dataRows.length} rows · ${headers.length} columns · ${importRecord['taxType'] ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        if (amountCols.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: amountCols.map((col) {
                              final stats =
                                  DataImportService.aggregateColumn(data, col);
                              final colName = col < headers.length
                                  ? headers[col].toString()
                                  : 'Col $col';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(colName,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10)),
                                    Text(
                                      '₦${currencyFormat.format(stats['sum'] ?? 0)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data table
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A2A3E)
                            : TaxNGColors.borderLight,
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
                                'Imported Data',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : TaxNGColors.textDark,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${dataRows.length} rows',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : TaxNGColors.textLight,
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
                                  ? TaxNGColors.primaryDark
                                      .withValues(alpha: 0.3)
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
                                          color: amountCols.contains(e.key)
                                              ? TaxNGColors.primary
                                              : (isDark
                                                  ? Colors.white
                                                  : TaxNGColors.textDark),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            rows: dataRows.take(100).map((row) {
                              return DataRow(
                                cells: List.generate(headers.length, (col) {
                                  final value =
                                      col < row.length ? row[col] : '';
                                  final isAmount = amountCols.contains(col);
                                  return DataCell(
                                    Text(
                                      value.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isAmount
                                            ? FontWeight.w600
                                            : FontWeight.w400,
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
                        if (dataRows.length > 100)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Showing first 100 of ${dataRows.length} rows',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white38
                                    : TaxNGColors.textLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
