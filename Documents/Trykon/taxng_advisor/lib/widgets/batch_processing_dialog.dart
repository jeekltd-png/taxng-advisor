import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/batch_processing_service.dart';
import 'package:taxng_advisor/services/tax_analytics_service.dart';
import 'package:taxng_advisor/utils/tax_helpers.dart';
import 'package:taxng_advisor/widgets/progress_overlay.dart';

/// Dialog for batch processing selected calculations
class BatchProcessingDialog extends StatefulWidget {
  final List<TaxCalculationItem> selectedCalculations;
  final VoidCallback onApplied;

  const BatchProcessingDialog({
    Key? key,
    required this.selectedCalculations,
    required this.onApplied,
  }) : super(key: key);

  @override
  State<BatchProcessingDialog> createState() => _BatchProcessingDialogState();
}

class _BatchProcessingDialogState extends State<BatchProcessingDialog> {
  BatchRule? _selectedRule;
  final _customValueController = TextEditingController();
  bool _isCustom = false;
  bool _isLoading = false;
  List<Map<String, dynamic>>? _previewResults;

  @override
  void dispose() {
    _customValueController.dispose();
    super.dispose();
  }

  Future<void> _previewOperation() async {
    if (_selectedRule == null && !_isCustom) return;

    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> results;

      if (_isCustom) {
        final value = double.tryParse(_customValueController.text);
        if (value == null) {
          throw Exception('Invalid value');
        }

        // Create custom rule based on selected operation type
        results = await _applyCustomOperation(value);
      } else {
        results = await BatchProcessingService.applyBatchRule(
          calculations: widget.selectedCalculations,
          rule: _selectedRule!,
          preview: true,
        );
      }

      setState(() {
        _previewResults = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _applyCustomOperation(double value) async {
    // Default to discount operation
    return BatchProcessingService.applyDiscount(
      calculations: widget.selectedCalculations,
      discountPercent: value,
      preview: true,
    );
  }

  Future<void> _applyOperation() async {
    if (_previewResults == null) return;

    // Show progress overlay
    ProgressOverlay.show(
      context,
      message:
          'Applying batch operation to ${widget.selectedCalculations.length} items...',
    );

    setState(() => _isLoading = true);

    try {
      if (_isCustom) {
        final value = double.tryParse(_customValueController.text);
        if (value == null) {
          throw Exception('Invalid value');
        }

        await _applyCustomOperation(value);
      } else if (_selectedRule != null) {
        await BatchProcessingService.applyBatchRule(
          calculations: widget.selectedCalculations,
          rule: _selectedRule!,
          preview: false,
        );
      }

      if (mounted) {
        ProgressOverlay.hide(context); // Close progress overlay
        widget.onApplied();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch operation applied successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ProgressOverlay.hide(context); // Close progress overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying operation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final impact = _previewResults != null
        ? BatchProcessingService.calculateBatchImpact(_previewResults!)
        : null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Batch Processing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.selectedCalculations.length} calculations selected',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Predefined rules
                    const Text(
                      'Quick Operations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BatchProcessingService.getPredefinedRules()
                          .map((rule) {
                        final isSelected = _selectedRule?.id == rule.id;
                        return FilterChip(
                          label: Text(rule.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRule = selected ? rule : null;
                              _isCustom = false;
                              _previewResults = null;
                            });
                          },
                          selectedColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Custom operation
                    const Text(
                      'Custom Operation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customValueController,
                            decoration: const InputDecoration(
                              labelText: 'Value',
                              hintText: 'e.g., 15 for 15%',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              setState(() {
                                _isCustom = true;
                                _selectedRule = null;
                                _previewResults = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: (_selectedRule != null || _isCustom) &&
                                  !_isLoading
                              ? _previewOperation
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Preview'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Preview results
                    if (_previewResults != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.visibility,
                                    color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildImpactItem(
                                  'Original Total',
                                  CurrencyFormatter.formatCurrency(
                                      impact!['totalOriginal']),
                                  Colors.grey[700]!,
                                ),
                                _buildImpactItem(
                                  'New Total',
                                  CurrencyFormatter.formatCurrency(
                                      impact['totalNew']),
                                  Colors.blue[700]!,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildImpactItem(
                                  'Difference',
                                  CurrencyFormatter.formatCurrency(
                                      impact['totalDifference']),
                                  impact['totalDifference'] >= 0
                                      ? Colors.green[700]!
                                      : Colors.red[700]!,
                                ),
                                _buildImpactItem(
                                  'Change',
                                  '${impact['percentageChange'].toStringAsFixed(1)}%',
                                  impact['totalDifference'] >= 0
                                      ? Colors.green[700]!
                                      : Colors.red[700]!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Individual results
                      const Text(
                        'Affected Calculations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _previewResults!.length,
                          itemBuilder: (context, index) {
                            final result = _previewResults![index];
                            final calc =
                                result['original'] as TaxCalculationItem;
                            final newAmount = result['newAmount'] as double;
                            final difference = result['difference'] as double;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  calc.type,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${CurrencyFormatter.formatCurrency(calc.amount)} → ${CurrencyFormatter.formatCurrency(newAmount)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  difference >= 0
                                      ? '+${CurrencyFormatter.formatCurrency(difference)}'
                                      : CurrencyFormatter.formatCurrency(
                                          difference),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: difference >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _previewResults != null && !_isLoading
                        ? _applyOperation
                        : null,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Applying...' : 'Apply Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  Widget _buildImpactItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
