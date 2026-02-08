import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/calculation_template.dart';
import 'package:taxng_advisor/services/template_service.dart';

/// Template Action Buttons - Reusable widget for save/load templates
class TemplateActionButtons extends StatelessWidget {
  final String taxType;
  final Map<String, dynamic> currentData;
  final Function(Map<String, dynamic>) onTemplateLoaded;

  const TemplateActionButtons({
    super.key,
    required this.taxType,
    required this.currentData,
    required this.onTemplateLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _loadTemplate(context),
            icon: const Icon(Icons.folder_open, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Load'),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.help_outline,
                      size: 16, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Load Template'),
                        content: const Text(
                          'Load a previously saved calculation template.\n\n'
                          'Templates allow you to quickly reuse common calculations without re-entering values. '
                          'When you load a template, all saved values (turnover, profit, etc.) will be automatically filled in.\n\n'
                          'Usage:\n'
                          '1. Click Load to see all your saved templates\n'
                          '2. Select a template from the list\n'
                          '3. The calculator will auto-populate with saved values\n'
                          '4. The calculation runs automatically',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _saveAsTemplate(context),
            icon: const Icon(Icons.save, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Save'),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.help_outline,
                      size: 16, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Save as Template'),
                        content: const Text(
                          'Save current values as a reusable template.\n\n'
                          'Templates help you:\n'
                          '• Quickly reuse common calculations\n'
                          '• Save time by avoiding repetitive data entry\n'
                          '• Organize calculations by category\n'
                          '• Track frequently used scenarios\n\n'
                          'Usage:\n'
                          '1. Enter your calculation values\n'
                          '2. Click Save\n'
                          '3. Give the template a descriptive name\n'
                          '4. Add optional description and category\n'
                          '5. Access it anytime via Load button',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _loadTemplate(BuildContext context) async {
    await TemplateService.init();
    final templates = TemplateService.getTemplatesByTaxType(taxType);

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No templates found for this tax type'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Template'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(template.name),
                subtitle: Text(template.category),
                trailing: Text(
                  'Used ${template.usageCount}x',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () async {
                  await TemplateService.recordUsage(template.id);
                  Navigator.pop(context);
                  onTemplateLoaded(template.templateData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Loaded template: ${template.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveAsTemplate(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Custom';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Save as Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name *',
                    hintText: 'e.g., Monthly VAT Return',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Monthly', 'Quarterly', 'Annual', 'Custom']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a template name'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  return;
                }

                await TemplateService.init();

                final template = CalculationTemplate(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  taxType: taxType,
                  templateData: currentData,
                  category: selectedCategory,
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  createdAt: DateTime.now(),
                  usageCount: 0,
                );

                await TemplateService.saveTemplate(template);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Template "${template.name}" saved!'),
                    backgroundColor: Colors.green,
                    action: SnackBarAction(
                      label: 'View',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, '/templates');
                      },
                    ),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
