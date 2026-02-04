import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/tax_analytics_service.dart';
import 'package:taxng_advisor/services/export_service.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:intl/intl.dart';
import 'package:taxng_advisor/widgets/notes_dialog.dart';
import 'package:taxng_advisor/widgets/batch_processing_dialog.dart';
import 'package:taxng_advisor/services/undo_service.dart';
import 'package:taxng_advisor/widgets/progress_overlay.dart';

/// Calculation History Screen - Shows all calculations across all tax types
class CalculationHistoryScreen extends StatefulWidget {
  const CalculationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CalculationHistoryScreen> createState() =>
      _CalculationHistoryScreenState();
}

class _CalculationHistoryScreenState extends State<CalculationHistoryScreen> {
  String _searchQuery = '';
  String? _selectedTaxType;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  String _sortBy =
      'date_desc'; // date_desc, date_asc, amount_desc, amount_asc, type_asc
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  final List<String> _taxTypes = [
    'All',
    'CIT',
    'PIT',
    'VAT',
    'WHT',
    'PAYE',
    'Stamp Duty'
  ];

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _selectAll(int totalCount) {
    setState(() {
      if (_selectedIndices.length == totalCount) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.clear();
        for (int i = 0; i < totalCount; i++) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _applyDatePreset(String preset) {
    final now = DateTime.now();
    setState(() {
      switch (preset) {
        case 'Today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'This Week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'Last Week':
          final lastWeekStart = now.subtract(Duration(days: now.weekday + 6));
          _startDate = lastWeekStart;
          _endDate = lastWeekStart.add(const Duration(days: 6));
          break;
        case 'This Month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Last Month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case 'This Quarter':
          final quarter = ((now.month - 1) / 3).floor();
          _startDate = DateTime(now.year, quarter * 3 + 1, 1);
          _endDate = now;
          break;
      }
    });
  }

  Future<void> _bulkDelete(List<TaxCalculationItem> calculations) async {
    final selectedCalculations =
        _selectedIndices.map((index) => calculations[index]).toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Calculations'),
        content: Text(
          'Are you sure you want to delete ${selectedCalculations.length} calculation${selectedCalculations.length != 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Record undo operation before deletion
        final operationId = await UndoService.recordBulkDelete(
          calculations: selectedCalculations,
        );

        // Show progress
        if (mounted) {
          ProgressOverlay.show(
            context,
            message:
                'Deleting ${selectedCalculations.length} calculation${selectedCalculations.length != 1 ? 's' : ''}...',
          );
        }

        final analyticsService = TaxAnalyticsService();
        for (final calc in selectedCalculations) {
          await analyticsService.deleteCalculation(calc.id);
        }

        // Hide progress
        if (mounted) {
          ProgressOverlay.hide(context);
        }

        setState(() {
          _selectedIndices.clear();
          _isSelectionMode = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Deleted ${selectedCalculations.length} calculation${selectedCalculations.length != 1 ? 's' : ''}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'UNDO',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    await UndoService.undo(operationId);
                    setState(() {}); // Refresh UI
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calculations restored'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to undo: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      } catch (e) {
        // Hide progress if error
        if (mounted) {
          ProgressOverlay.hide(context);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting calculations: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _bulkExport(List<TaxCalculationItem> calculations) async {
    final selectedCalculations =
        _selectedIndices.map((index) => calculations[index]).toList();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Export ${selectedCalculations.length} Calculation${selectedCalculations.length != 1 ? 's' : ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV'),
              subtitle: const Text('Comma-separated values'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV(selectedCalculations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on, color: Colors.blue),
              title: const Text('Export as Excel'),
              subtitle: const Text('Microsoft Excel format'),
              onTap: () {
                Navigator.pop(context);
                _exportAsExcel(selectedCalculations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              subtitle: const Text('Portable Document Format'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF(selectedCalculations);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBatchProcessing(
      List<TaxCalculationItem> calculations) async {
    final selectedCalculations =
        _selectedIndices.map((index) => calculations[index]).toList();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BatchProcessingDialog(
        selectedCalculations: selectedCalculations,
        onApplied: () {
          setState(() {
            _selectedIndices.clear();
            _isSelectionMode = false;
          });
        },
      ),
    );

    if (result == true) {
      setState(() {
        // Refresh the list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var calculations = TaxAnalyticsService.getRecentCalculations(limit: 1000);

    // Apply filters
    if (_selectedTaxType != null && _selectedTaxType != 'All') {
      calculations =
          calculations.where((c) => c.type == _selectedTaxType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      calculations = calculations
          .where((c) =>
              c.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              c.type.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_startDate != null) {
      calculations =
          calculations.where((c) => c.date.isAfter(_startDate!)).toList();
    }

    if (_endDate != null) {
      calculations = calculations
          .where((c) => c.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    // Amount range filter
    if (_minAmount != null) {
      calculations =
          calculations.where((c) => c.amount >= _minAmount!).toList();
    }

    if (_maxAmount != null) {
      calculations =
          calculations.where((c) => c.amount <= _maxAmount!).toList();
    }

    // Sort calculations
    switch (_sortBy) {
      case 'date_desc':
        calculations.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        calculations.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        calculations.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        calculations.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'type_asc':
        calculations.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    final totalAmount =
        calculations.fold<double>(0, (sum, calc) => sum + calc.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedIndices.length} selected'
            : 'Calculation History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(_selectedIndices.length == calculations.length
                  ? Icons.deselect
                  : Icons.select_all),
              onPressed: () => _selectAll(calculations.length),
              tooltip: _selectedIndices.length == calculations.length
                  ? 'Deselect all'
                  : 'Select all',
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select items',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort by',
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'date_desc',
                  child: Text('Date (Newest first)'),
                ),
                const PopupMenuItem(
                  value: 'date_asc',
                  child: Text('Date (Oldest first)'),
                ),
                const PopupMenuItem(
                  value: 'amount_desc',
                  child: Text('Amount (High to Low)'),
                ),
                const PopupMenuItem(
                  value: 'amount_asc',
                  child: Text('Amount (Low to High)'),
                ),
                const PopupMenuItem(
                  value: 'type_asc',
                  child: Text('Tax Type (A-Z)'),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _showDateRangePicker,
              tooltip: 'Filter by date',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedTaxType = null;
                  _startDate = null;
                  _endDate = null;
                  _minAmount = null;
                  _maxAmount = null;
                  _sortBy = 'date_desc';
                });
              },
              tooltip: 'Clear filters',
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search and Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search calculations...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _taxTypes.map((type) {
                          final isSelected = _selectedTaxType == type ||
                              (_selectedTaxType == null && type == 'All');
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTaxType =
                                      type == 'All' ? null : type;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.green[100],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Date presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Today',
                          'This Week',
                          'Last Week',
                          'This Month',
                          'Last Month',
                          'This Quarter'
                        ].map((preset) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: OutlinedButton(
                              onPressed: () => _applyDatePreset(preset),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              child: Text(preset,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Amount range filter
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Min Amount',
                              prefixText: '₦',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _minAmount = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Max Amount',
                              prefixText: '₦',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _maxAmount = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_startDate != null || _endDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getDateRangeText(),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blue),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Summary Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${calculations.length} Calculation${calculations.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${CurrencyFormatter.formatCurrency(totalAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (calculations.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          _showExportOptions(calculations);
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),

              // Calculations List
              Expanded(
                child: calculations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No calculations found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: calculations.length,
                        itemBuilder: (context, index) {
                          final calc = calculations[index];
                          final isSelected = _selectedIndices.contains(index);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                if (_isSelectionMode) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedIndices.remove(index);
                                    } else {
                                      _selectedIndices.add(index);
                                    }
                                  });
                                } else {
                                  _showCalculationDetails(calc);
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  _toggleSelectionMode();
                                  setState(() {
                                    _selectedIndices.add(index);
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Checkbox in selection mode
                                    if (_isSelectionMode)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedIndices.add(index);
                                              } else {
                                                _selectedIndices.remove(index);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    // Tax Type Badge
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: _getTaxColor(calc.type),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            calc.type,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            calc.description,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('MMM dd, yyyy - hh:mm a')
                                                .format(calc.date),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Amount and Note button
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.formatCurrency(
                                              calc.amount),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (!_isSelectionMode)
                                          NoteIndicatorButton(
                                            calculationId: calc.id,
                                            onPressed: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    NotesDialog(
                                                  calculationId: calc.id,
                                                ),
                                              );
                                              setState(() {});
                                            },
                                          )
                                        else
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.grey[400],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          // Bottom Action Bar
          if (_selectedIndices.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bulkDelete(calculations),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.delete),
                        label: Text('Delete (${_selectedIndices.length})'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _bulkExport(calculations),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.download, size: 18),
                        label: Text('Export (${_selectedIndices.length})',
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showBatchProcessing(calculations),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: Text('Batch (${_selectedIndices.length})',
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _toggleSelectionMode,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child:
                          const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTaxColor(String type) {
    switch (type) {
      case 'CIT':
        return Colors.blue;
      case 'PIT':
        return Colors.green;
      case 'VAT':
        return Colors.orange;
      case 'WHT':
        return Colors.purple;
      case 'PAYE':
        return Colors.teal;
      case 'Stamp Duty':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}';
    } else if (_startDate != null) {
      return 'From ${DateFormat('MMM dd, yyyy').format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Until ${DateFormat('MMM dd, yyyy').format(_endDate!)}';
    }
    return '';
  }

  void _showCalculationDetails(TaxCalculationItem calc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(calc.type),
            const Spacer(),
            Icon(
              Icons.receipt,
              color: _getTaxColor(calc.type),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', calc.description),
            _buildDetailRow(
                'Amount', CurrencyFormatter.formatCurrency(calc.amount)),
            _buildDetailRow('Date',
                DateFormat('MMMM dd, yyyy - hh:mm a').format(calc.date)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _recalculate(calc);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Recalculate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _recalculate(TaxCalculationItem calc) {
    // Navigate to the appropriate calculator with pre-filled data
    String route = '';
    switch (calc.type) {
      case 'CIT':
        route = '/cit';
        break;
      case 'PIT':
        route = '/pit';
        break;
      case 'VAT':
        route = '/vat';
        break;
      case 'WHT':
        route = '/wht';
        break;
      case 'PAYE':
        route = '/payroll';
        break;
      case 'Stamp Duty':
        route = '/stamp-duty';
        break;
    }

    if (route.isNotEmpty) {
      // Note: The calculator will need to handle the route arguments
      // This provides basic navigation - calculators already support this
      Navigator.pushNamed(context, route);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${calc.type} calculator'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showExportOptions(List<TaxCalculationItem> calculations) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV(calculations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_view),
              title: const Text('Export as Excel'),
              subtitle: const Text('Formatted spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _exportAsExcel(calculations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Professional report'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF(calculations);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsCSV(List<TaxCalculationItem> calculations) async {
    try {
      // Show progress with item count
      ProgressOverlay.show(
        context,
        message:
            'Exporting ${calculations.length} calculation${calculations.length != 1 ? 's' : ''} to CSV...',
      );

      final filePath = await ExportService.exportToCSV(
        calculations: calculations,
      );

      ProgressOverlay.hide(context); // Close progress

      // Show success with share option
      _showExportSuccessDialog(filePath, 'CSV');
    } catch (e) {
      ProgressOverlay.hide(context); // Close progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportAsExcel(List<TaxCalculationItem> calculations) async {
    try {
      // Show progress with item count
      ProgressOverlay.show(
        context,
        message:
            'Exporting ${calculations.length} calculation${calculations.length != 1 ? 's' : ''} to Excel...',
      );

      final filePath = await ExportService.exportToExcel(
        calculations: calculations,
      );

      ProgressOverlay.hide(context); // Close progress

      // Show success with share option
      _showExportSuccessDialog(filePath, 'Excel');
    } catch (e) {
      ProgressOverlay.hide(context); // Close progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportAsPDF(List<TaxCalculationItem> calculations) async {
    try {
      // Show progress with item count
      ProgressOverlay.show(
        context,
        message:
            'Exporting ${calculations.length} calculation${calculations.length != 1 ? 's' : ''} to PDF...',
      );

      final filePath = await ExportService.exportToPDF(
        calculations: calculations,
        reportTitle: 'Tax Calculations Report',
      );

      ProgressOverlay.hide(context); // Close progress

      // Show success with share option
      _showExportSuccessDialog(filePath, 'PDF');
    } catch (e) {
      ProgressOverlay.hide(context); // Close progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExportSuccessDialog(String filePath, String format) {
    final fileSize = ExportService.getFileSize(filePath);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$format file exported successfully!'),
            const SizedBox(height: 8),
            Text(
              'Size: $fileSize',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Location: Documents folder',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await ExportService.shareFile(
                filePath,
                'Tax Calculations - $format Export',
              );
            },
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
