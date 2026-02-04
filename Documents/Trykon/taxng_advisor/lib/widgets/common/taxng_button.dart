import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// TaxNG Custom Button - Primary action button with modern styling
class TaxNGButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isSecondary;

  const TaxNGButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 48,
    this.icon,
    this.isSecondary = false,
  });

  @override
  State<TaxNGButton> createState() => _TaxNGButtonState();
}

class _TaxNGButtonState extends State<TaxNGButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSecondary) {
      return OutlinedButton(
        onPressed: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(widget.width ?? double.infinity, widget.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _buildButtonContent(),
      );
    }

    return ElevatedButton(
      onPressed: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(widget.width ?? double.infinity, widget.height),
        backgroundColor: widget.isEnabled
            ? TaxNGColors.primary
            : TaxNGColors.textLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
          Text(widget.label, style: TaxNGTypography.labelLarge),
        ],
      );
    }

    return Text(widget.label, style: TaxNGTypography.labelLarge);
  }
}
