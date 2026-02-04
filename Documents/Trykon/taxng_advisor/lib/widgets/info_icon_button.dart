import 'package:flutter/material.dart';

/// A reusable info icon button that shows a dialog with detailed information
class InfoIconButton extends StatelessWidget {
  final String title;
  final Widget content;
  final Color? color;

  const InfoIconButton({
    super.key,
    required this.title,
    required this.content,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: color ?? Colors.blue,
        size: 20,
      ),
      tooltip: 'Learn more',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: content,
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
    );
  }
}
