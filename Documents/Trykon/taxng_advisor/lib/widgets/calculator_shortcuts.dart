import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that adds keyboard shortcuts to calculators
class CalculatorShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onCalculate;
  final VoidCallback? onClear;
  final VoidCallback? onExport;
  final VoidCallback? onTemplate;

  const CalculatorShortcuts({
    Key? key,
    required this.child,
    this.onSave,
    this.onCalculate,
    this.onClear,
    this.onExport,
    this.onTemplate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Ctrl+S - Save/Calculate
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const CalculateIntent(),
        // Ctrl+Enter - Calculate
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): const CalculateIntent(),
        // Ctrl+R - Clear/Reset
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): const ClearIntent(),
        // Ctrl+E - Export
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE): const ExportIntent(),
        // Ctrl+T - Template
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT): const TemplateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CalculateIntent: CallbackAction<CalculateIntent>(
            onInvoke: (_) {
              onCalculate?.call();
              return null;
            },
          ),
          ClearIntent: CallbackAction<ClearIntent>(
            onInvoke: (_) {
              onClear?.call();
              return null;
            },
          ),
          ExportIntent: CallbackAction<ExportIntent>(
            onInvoke: (_) {
              onExport?.call();
              return null;
            },
          ),
          TemplateIntent: CallbackAction<TemplateIntent>(
            onInvoke: (_) {
              onTemplate?.call();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

// Intent classes
class CalculateIntent extends Intent {
  const CalculateIntent();
}

class ClearIntent extends Intent {
  const ClearIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}

class TemplateIntent extends Intent {
  const TemplateIntent();
}

/// Quick action buttons for common calculator operations
class QuickActionBar extends StatelessWidget {
  final VoidCallback? onCalculate;
  final VoidCallback? onClear;
  final VoidCallback? onSaveTemplate;
  final VoidCallback? onLoadTemplate;
  final VoidCallback? onExport;
  final VoidCallback? onCopyLast;
  final bool showShortcuts;

  const QuickActionBar({
    Key? key,
    this.onCalculate,
    this.onClear,
    this.onSaveTemplate,
    this.onLoadTemplate,
    this.onExport,
    this.onCopyLast,
    this.showShortcuts = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showShortcuts) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showShortcutsDialog(context),
                    icon: const Icon(Icons.keyboard, size: 16),
                    label: const Text('Shortcuts', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onCalculate != null)
                  _QuickActionButton(
                    icon: Icons.calculate,
                    label: 'Calculate',
                    color: Colors.green,
                    onPressed: onCalculate!,
                    shortcut: 'Ctrl+S',
                  ),
                if (onClear != null)
                  _QuickActionButton(
                    icon: Icons.refresh,
                    label: 'Clear',
                    color: Colors.orange,
                    onPressed: onClear!,
                    shortcut: 'Ctrl+R',
                  ),
                if (onSaveTemplate != null)
                  _QuickActionButton(
                    icon: Icons.save,
                    label: 'Save Template',
                    color: Colors.blue,
                    onPressed: onSaveTemplate!,
                    shortcut: 'Ctrl+T',
                  ),
                if (onLoadTemplate != null)
                  _QuickActionButton(
                    icon: Icons.folder_open,
                    label: 'Load Template',
                    color: Colors.purple,
                    onPressed: onLoadTemplate!,
                  ),
                if (onExport != null)
                  _QuickActionButton(
                    icon: Icons.download,
                    label: 'Export',
                    color: Colors.teal,
                    onPressed: onExport!,
                    shortcut: 'Ctrl+E',
                  ),
                if (onCopyLast != null)
                  _QuickActionButton(
                    icon: Icons.content_copy,
                    label: 'Copy Last',
                    color: Colors.indigo,
                    onPressed: onCopyLast!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.keyboard, color: Colors.blue),
            SizedBox(width: 12),
            Text('Keyboard Shortcuts'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShortcutItem('Ctrl + S', 'Calculate / Save'),
            _ShortcutItem('Ctrl + Enter', 'Calculate'),
            _ShortcutItem('Ctrl + R', 'Clear / Reset'),
            _ShortcutItem('Ctrl + E', 'Export Results'),
            _ShortcutItem('Ctrl + T', 'Open Templates'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final String? shortcut;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          if (shortcut != null)
            Text(
              shortcut!,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final String shortcut;
  final String description;

  const _ShortcutItem(this.shortcut, this.description);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
