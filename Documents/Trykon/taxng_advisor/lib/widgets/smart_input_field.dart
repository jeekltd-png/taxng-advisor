import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/draft_service.dart';

/// Widget for displaying recent values and copy from last functionality
class SmartInputField extends StatefulWidget {
  final String calculatorKey;
  final String fieldName;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? prefixText;
  final String? suffixText;
  final int? maxLines;

  const SmartInputField({
    super.key,
    required this.calculatorKey,
    required this.fieldName,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.prefixText,
    this.suffixText,
    this.maxLines,
  });

  @override
  State<SmartInputField> createState() => _SmartInputFieldState();
}

class _SmartInputFieldState extends State<SmartInputField> {
  List<String> _recentValues = [];
  bool _showRecentValues = false;

  @override
  void initState() {
    super.initState();
    _loadRecentValues();
  }

  Future<void> _loadRecentValues() async {
    final values = await RecentValuesService.getRecentValues(
      calculatorKey: widget.calculatorKey,
      fieldName: widget.fieldName,
    );
    setState(() {
      _recentValues = values;
    });
  }

  Future<void> _saveCurrentValue() async {
    if (widget.controller.text.isNotEmpty) {
      await RecentValuesService.saveRecentValue(
        calculatorKey: widget.calculatorKey,
        fieldName: widget.fieldName,
        value: widget.controller.text,
      );
      _loadRecentValues();
    }
  }

  void _selectRecentValue(String value) {
    widget.controller.text = value;
    setState(() {
      _showRecentValues = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                  prefixText: widget.prefixText,
                  suffixText: widget.suffixText,
                ),
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                maxLines: widget.maxLines ?? 1,
                onChanged: (value) {
                  _saveCurrentValue();
                },
              ),
            ),
            if (_recentValues.isNotEmpty)
              IconButton(
                icon: Icon(
                  _showRecentValues ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _showRecentValues = !_showRecentValues;
                  });
                },
                tooltip: 'Show recent values',
              ),
          ],
        ),
        if (_showRecentValues && _recentValues.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Values',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await RecentValuesService.clearRecentValues(
                          calculatorKey: widget.calculatorKey,
                          fieldName: widget.fieldName,
                        );
                        _loadRecentValues();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _recentValues.map((value) {
                    return InkWell(
                      onTap: () => _selectRecentValue(value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              value,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Widget for "Copy from Last" functionality
class CopyFromLastButton extends StatelessWidget {
  final String calculatorType;
  final Function(Map<String, dynamic>) onCopy;

  const CopyFromLastButton({
    super.key,
    required this.calculatorType,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: RecentValuesService.getLastCalculation(calculatorType),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return OutlinedButton.icon(
            onPressed: () {
              onCopy(snapshot.data!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied values from last calculation'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.content_copy, size: 16),
            label: const Text('Copy from Last'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
