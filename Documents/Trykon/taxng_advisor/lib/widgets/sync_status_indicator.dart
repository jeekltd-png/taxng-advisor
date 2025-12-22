import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _isOnline = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  Future<void> _initializeStatus() async {
    final isOnline = await SyncService.isOnline();

    setState(() {
      _isOnline = isOnline;
    });
  }

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);

    try {
      await SyncService.manualSync();

      if (mounted) {
        setState(() {
          _isSyncing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sync completed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SyncService.isOnline(),
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        final syncStatus = SyncService.getSyncStatus();
        final pendingCount = syncStatus['pending'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green[50] : Colors.orange[50],
            border: Border.all(
              color: isOnline ? Colors.green : Colors.orange,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSyncing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOnline ? Colors.green : Colors.orange,
                        ),
                      ),
                    )
                  else
                    Icon(
                      isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: isOnline ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isOnline ? '✅ Online' : '🔴 Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              isOnline ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                      if (pendingCount > 0)
                        Text(
                          '$pendingCount pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: isOnline
                                ? Colors.green[600]
                                : Colors.orange[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (isOnline && pendingCount > 0 && !_isSyncing)
                SizedBox(
                  height: 24,
                  child: ElevatedButton(
                    onPressed: _manualSync,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Sync',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
