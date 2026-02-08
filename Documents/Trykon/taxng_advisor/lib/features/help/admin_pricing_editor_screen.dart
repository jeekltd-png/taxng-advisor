import 'package:flutter/material.dart';
import 'package:taxng_advisor/models/pricing_tier.dart';
import 'package:taxng_advisor/services/pricing_service.dart';
import 'package:taxng_advisor/services/auth_service.dart';

/// Admin screen for editing pricing tiers
class AdminPricingEditorScreen extends StatefulWidget {
  const AdminPricingEditorScreen({super.key});

  @override
  State<AdminPricingEditorScreen> createState() =>
      _AdminPricingEditorScreenState();
}

class _AdminPricingEditorScreenState extends State<AdminPricingEditorScreen> {
  List<PricingTier> _tiers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadData();
  }

  Future<void> _checkAdminAndLoadData() async {
    final currentUser = await AuthService.currentUser();
    if (currentUser == null || !currentUser.isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin access required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _loadPricing();
  }

  void _loadPricing() {
    setState(() {
      _tiers = PricingService.getTiers();
      _isLoading = false;
    });
  }

  Future<void> _savePricing() async {
    try {
      await PricingService.saveTiers(_tiers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pricing updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving pricing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'Are you sure you want to reset all pricing to default values? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PricingService.resetToDefaults();
      _loadPricing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pricing reset to defaults'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _editTier(int index) async {
    final tier = _tiers[index];
    final result = await Navigator.push<PricingTier>(
      context,
      MaterialPageRoute(
        builder: (context) => _PricingTierEditorScreen(tier: tier),
      ),
    );

    if (result != null) {
      setState(() {
        _tiers[index] = result;
      });
      await _savePricing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Edit Pricing'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _tiers.length,
              itemBuilder: (context, index) {
                final tier = _tiers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text(
                      tier.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${tier.price}${tier.period}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tier.features.length} features',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (tier.isPopular)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editTier(index),
                  ),
                );
              },
            ),
    );
  }
}

/// Screen for editing a single pricing tier
class _PricingTierEditorScreen extends StatefulWidget {
  final PricingTier tier;

  const _PricingTierEditorScreen({required this.tier});

  @override
  State<_PricingTierEditorScreen> createState() =>
      _PricingTierEditorScreenState();
}

class _PricingTierEditorScreenState extends State<_PricingTierEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _periodController;
  late List<TextEditingController> _featureControllers;
  late bool _isPopular;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tier.name);
    _priceController = TextEditingController(text: widget.tier.price);
    _periodController = TextEditingController(text: widget.tier.period);
    _isPopular = widget.tier.isPopular;
    _featureControllers = widget.tier.features
        .map((f) => TextEditingController(text: f))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _periodController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFeature() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  void _save() {
    final updatedTier = PricingTier(
      name: _nameController.text,
      price: _priceController.text,
      period: _periodController.text,
      features: _featureControllers.map((c) => c.text).toList(),
      isPopular: _isPopular,
    );
    Navigator.pop(context, updatedTier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.tier.name}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tier Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: '₦2,000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _periodController,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      hintText: '/month',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mark as Popular'),
              value: _isPopular,
              onChanged: (value) {
                setState(() {
                  _isPopular = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Colors.green,
                  onPressed: _addFeature,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._featureControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Feature ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      color: Colors.red,
                      onPressed: () => _removeFeature(index),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: const Text('Save Changes'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
