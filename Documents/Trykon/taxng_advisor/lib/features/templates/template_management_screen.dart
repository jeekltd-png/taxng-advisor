import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/calculation_template.dart';
import 'package:taxng_advisor/services/template_service.dart';
import 'package:intl/intl.dart';

/// Template Management Screen - View, edit, and delete calculation templates
class TemplateManagementScreen extends StatefulWidget {
  const TemplateManagementScreen({Key? key}) : super(key: key);

  @override
  State<TemplateManagementScreen> createState() =>
      _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  String _selectedTaxType = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _taxTypes = [
    'All',
    'CIT',
    'PIT',
    'VAT',
    'WHT',
    'PAYE',
    'Stamp Duty'
  ];

  final List<String> _categories = [
    'All',
    'Monthly',
    'Quarterly',
    'Annual',
    'Custom'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation Templates'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(),

          // Templates list
          Expanded(
            child: FutureBuilder<List<CalculationTemplate>>(
              future: _loadFilteredTemplates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final templates = snapshot.data ?? [];

                if (templates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No templates match your search'
                              : 'No templates yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save templates from any calculator',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    return _buildTemplateCard(templates[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search templates...',
              helperText:
                  'Try: "Monthly", "Q1 2025", "Large Company", or template name',
              helperMaxLines: 2,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.help_outline,
                              size: 20, color: Colors.blue),
                          tooltip: 'Search help',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Search Templates'),
                                content: const SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You can search templates by:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                          '• Template name (e.g., "Monthly CIT")'),
                                      Text(
                                          '• Description keywords (e.g., "manufacturing")'),
                                      Text('• Category (e.g., "Quarterly")'),
                                      Text(
                                          '• Time period (e.g., "Q1 2025", "January")'),
                                      Text(
                                          '• Company type (e.g., "SME", "Large Company")'),
                                      SizedBox(height: 16),
                                      Text(
                                        'Examples:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                          '• "Monthly" - Find all monthly templates'),
                                      Text('• "Q1" - Find quarterly templates'),
                                      Text(
                                          '• "2025" - Find templates from 2025'),
                                      Text(
                                          '• "SME" - Find small business templates'),
                                      Text(
                                          '• "manufacturing" - Find industry-specific templates'),
                                    ],
                                  ),
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
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.help_outline,
                          size: 20, color: Colors.blue),
                      tooltip: 'Search help',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Search Templates'),
                            content: const SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You can search templates by:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 12),
                                  Text('• Template name (e.g., "Monthly CIT")'),
                                  Text(
                                      '• Description keywords (e.g., "manufacturing")'),
                                  Text('• Category (e.g., "Quarterly")'),
                                  Text(
                                      '• Time period (e.g., "Q1 2025", "January")'),
                                  Text(
                                      '• Company type (e.g., "SME", "Large Company")'),
                                  SizedBox(height: 16),
                                  Text(
                                    'Examples:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                      '• "Monthly" - Find all monthly templates'),
                                  Text('• "Q1" - Find quarterly templates'),
                                  Text('• "2025" - Find templates from 2025'),
                                  Text(
                                      '• "SME" - Find small business templates'),
                                  Text(
                                      '• "manufacturing" - Find industry-specific templates'),
                                ],
                              ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Tax type filter
          Row(
            children: [
              const Text('Tax Type: ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _taxTypes.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: _selectedTaxType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTaxType = type;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Category filter
          Row(
            children: [
              const Text('Category: ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(CalculationTemplate template) {
    final color = _getTaxTypeColor(template.taxType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showTemplateDetails(template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Tax type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      template.taxType,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      template.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // More options
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editTemplate(template);
                      } else if (value == 'delete') {
                        _deleteTemplate(template);
                      } else if (value == 'duplicate') {
                        _duplicateTemplate(template);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Template name
              Text(
                template.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (template.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  template.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Usage info
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(template.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.repeat, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Used ${template.usageCount}x',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<CalculationTemplate>> _loadFilteredTemplates() async {
    await TemplateService.init();

    List<CalculationTemplate> templates;

    if (_searchQuery.isNotEmpty) {
      templates = TemplateService.searchTemplates(_searchQuery);
    } else {
      templates = TemplateService.getAllTemplates();
    }

    // Filter by tax type
    if (_selectedTaxType != 'All') {
      templates =
          templates.where((t) => t.taxType == _selectedTaxType).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      templates =
          templates.where((t) => t.category == _selectedCategory).toList();
    }

    // Sort by usage count (most used first)
    templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));

    return templates;
  }

  Color _getTaxTypeColor(String taxType) {
    switch (taxType) {
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

  void _showTemplateDetails(CalculationTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tax Type', template.taxType),
              _buildDetailRow('Category', template.category),
              if (template.description != null)
                _buildDetailRow('Description', template.description!),
              _buildDetailRow('Created',
                  DateFormat('MMMM dd, yyyy').format(template.createdAt)),
              if (template.lastUsedAt != null)
                _buildDetailRow('Last Used',
                    DateFormat('MMMM dd, yyyy').format(template.lastUsedAt!)),
              _buildDetailRow('Usage Count', template.usageCount.toString()),
              const Divider(),
              const Text(
                'Template Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...template.templateData.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyTemplate(template);
            },
            child: const Text('Apply Template'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _applyTemplate(CalculationTemplate template) async {
    await TemplateService.recordUsage(template.id);

    // Navigate to appropriate calculator with template data
    String route = '';
    switch (template.taxType) {
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
      Navigator.pushNamed(context, route, arguments: template.templateData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied template: ${template.name}')),
      );
    }
  }

  void _editTemplate(CalculationTemplate template) {
    final nameController = TextEditingController(text: template.name);
    final descController = TextEditingController(text: template.description);
    String selectedCategory = template.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                final updated = template.copyWith(
                  name: nameController.text,
                  description:
                      descController.text.isEmpty ? null : descController.text,
                  category: selectedCategory,
                );
                await TemplateService.updateTemplate(updated);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTemplate(CalculationTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text(
            'Are you sure you want to delete "${template.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await TemplateService.deleteTemplate(template.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${template.name}"')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateTemplate(CalculationTemplate template) async {
    final duplicate = CalculationTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${template.name} (Copy)',
      taxType: template.taxType,
      templateData: Map.from(template.templateData),
      category: template.category,
      description: template.description,
      createdAt: DateTime.now(),
      usageCount: 0,
    );

    await TemplateService.saveTemplate(duplicate);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Template duplicated')),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Templates'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Templates help you save frequently used calculations.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('How to use:'),
              SizedBox(height: 8),
              Text('1. Calculate any tax in a calculator'),
              Text('2. Tap "Save as Template"'),
              Text('3. Give it a name and category'),
              Text('4. Load template anytime to reuse values'),
              SizedBox(height: 12),
              Text(
                'Categories:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Monthly - For recurring monthly calculations'),
              Text('• Quarterly - For quarterly tax filings'),
              Text('• Annual - For annual tax returns'),
              Text('• Custom - For one-time or special cases'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
