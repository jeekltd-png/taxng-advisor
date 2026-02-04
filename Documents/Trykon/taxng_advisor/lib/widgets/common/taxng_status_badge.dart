import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// TaxNG Status Badge - Shows status with color coding
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType status;
  final double? size;

  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final bgColor = _getStatusBgColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TaxNGTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case StatusType.success:
        return TaxNGColors.success;
      case StatusType.warning:
        return TaxNGColors.warning;
      case StatusType.error:
        return TaxNGColors.error;
      case StatusType.info:
        return TaxNGColors.info;
      case StatusType.pending:
        return TaxNGColors.textMedium;
    }
  }

  Color _getStatusBgColor() {
    switch (status) {
      case StatusType.success:
        return TaxNGColors.success.withOpacity(0.1);
      case StatusType.warning:
        return TaxNGColors.warning.withOpacity(0.1);
      case StatusType.error:
        return TaxNGColors.error.withOpacity(0.1);
      case StatusType.info:
        return TaxNGColors.info.withOpacity(0.1);
      case StatusType.pending:
        return TaxNGColors.textMedium.withOpacity(0.1);
    }
  }
}

enum StatusType { success, warning, error, info, pending }

/// TaxNG Info Banner - Display informational messages
class InfoBanner extends StatelessWidget {
  final String message;
  final BannerType bannerType;
  final VoidCallback? onClose;
  final IconData? icon;

  const InfoBanner({
    super.key,
    required this.message,
    this.bannerType = BannerType.info,
    this.onClose,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgColor,
        border: Border.all(color: colors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon ?? _getIcon(), color: colors.iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TaxNGTypography.bodySmall.copyWith(
                color: colors.textColor,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: Icon(Icons.close, color: colors.iconColor, size: 18),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (bannerType) {
      case BannerType.success:
        return Icons.check_circle;
      case BannerType.warning:
        return Icons.warning;
      case BannerType.error:
        return Icons.error;
      case BannerType.info:
        return Icons.info;
    }
  }

  _BannerColors _getColors() {
    switch (bannerType) {
      case BannerType.success:
        return _BannerColors(
          bgColor: TaxNGColors.success.withOpacity(0.1),
          borderColor: TaxNGColors.success.withOpacity(0.3),
          textColor: TaxNGColors.success,
          iconColor: TaxNGColors.success,
        );
      case BannerType.warning:
        return _BannerColors(
          bgColor: TaxNGColors.warning.withOpacity(0.1),
          borderColor: TaxNGColors.warning.withOpacity(0.3),
          textColor: TaxNGColors.warning,
          iconColor: TaxNGColors.warning,
        );
      case BannerType.error:
        return _BannerColors(
          bgColor: TaxNGColors.error.withOpacity(0.1),
          borderColor: TaxNGColors.error.withOpacity(0.3),
          textColor: TaxNGColors.error,
          iconColor: TaxNGColors.error,
        );
      case BannerType.info:
        return _BannerColors(
          bgColor: TaxNGColors.info.withOpacity(0.1),
          borderColor: TaxNGColors.info.withOpacity(0.3),
          textColor: TaxNGColors.info,
          iconColor: TaxNGColors.info,
        );
    }
  }
}

class _BannerColors {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  _BannerColors({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });
}

enum BannerType { success, warning, error, info }
