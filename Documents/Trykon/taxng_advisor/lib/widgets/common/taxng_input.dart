import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// TaxNG Custom Input Field with modern styling
class TaxNGInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final String? errorText;
  final TextCapitalization textCapitalization;

  const TaxNGInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<TaxNGInputField> createState() => _TaxNGInputFieldState();
}

class _TaxNGInputFieldState extends State<TaxNGInputField> {
  late FocusNode _focusNode;
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscured = widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TaxNGTypography.labelLarge.copyWith(
            color: TaxNGColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: _obscured,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          maxLines: _obscured ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
          style: TaxNGTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TaxNGTypography.bodyMedium.copyWith(
              color: TaxNGColors.textLight,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: TaxNGColors.textMedium)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon:
                        Icon(widget.suffixIcon, color: TaxNGColors.textMedium),
                    onPressed: widget.onSuffixIconPressed ??
                        (widget.obscureText
                            ? () {
                                setState(() {
                                  _obscured = !_obscured;
                                });
                              }
                            : null),
                  )
                : null,
            errorText: widget.errorText,
            errorStyle: TaxNGTypography.bodySmall.copyWith(
              color: TaxNGColors.error,
            ),
            filled: true,
            fillColor: widget.enabled
                ? TaxNGColors.bgLight
                : TaxNGColors.bgLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TaxNGColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TaxNGColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: TaxNGColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TaxNGColors.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: TaxNGColors.borderLight),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// Currency Input Field with formatting
class CurrencyInputField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? errorText;
  final bool enabled;
  final String currencySymbol;

  const CurrencyInputField({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.currencySymbol = '₦',
  });

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  @override
  Widget build(BuildContext context) {
    return TaxNGInputField(
      label: widget.label,
      hint: '0.00',
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.attach_money,
      onChanged: widget.onChanged,
      errorText: widget.errorText,
      enabled: widget.enabled,
    );
  }
}
