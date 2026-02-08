import 'package:flutter/material.dart';

/// Widget that displays a calculation item with tap-to-learn functionality
class CalculationInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final String explanation;
  final String howCalculated;
  final String why;
  final Color? color;
  final bool isHighlight;
  final IconData? icon;

  const CalculationInfoItem({
    super.key,
    required this.label,
    required this.value,
    required this.explanation,
    required this.howCalculated,
    required this.why,
    this.color,
    this.isHighlight = false,
    this.icon,
  });

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              icon ?? Icons.info_outline,
              color: color ?? Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // What is it?
              _buildSection(
                icon: Icons.help_outline,
                title: 'What is this?',
                content: explanation,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // How is it calculated?
              _buildSection(
                icon: Icons.calculate,
                title: 'How is it calculated?',
                content: howCalculated,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Why is it important?
              _buildSection(
                icon: Icons.lightbulb_outline,
                title: 'Why is this important?',
                content: why,
                color: Colors.orange,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isHighlight ? Colors.green.shade50 : null,
      elevation: isHighlight ? 4 : 2,
      child: InkWell(
        onTap: () => _showInfoDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Info icon indicator
              Icon(
                Icons.info_outline,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: isHighlight ? 20 : 18,
                        fontWeight:
                            isHighlight ? FontWeight.bold : FontWeight.w600,
                        color: color ?? Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Tap hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, size: 14, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Tap',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
