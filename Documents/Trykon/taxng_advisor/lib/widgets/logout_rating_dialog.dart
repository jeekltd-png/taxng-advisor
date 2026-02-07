import 'package:flutter/material.dart';
import 'package:taxng_advisor/theme/colors.dart';
import 'package:taxng_advisor/services/user_activity_tracker.dart';

/// A modern, Gen Z-friendly rating dialog shown at logout.
///
/// Features animated star selection, emoji reactions, and optional feedback.
/// The rating is tracked via [UserActivityTracker] so admins can view it.
class LogoutRatingDialog extends StatefulWidget {
  const LogoutRatingDialog({super.key});

  @override
  State<LogoutRatingDialog> createState() => _LogoutRatingDialogState();
}

class _LogoutRatingDialogState extends State<LogoutRatingDialog>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  final _feedbackController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _getEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '🤔';
    }
  }

  String _getLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap a star to rate';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return TaxNGColors.error;
      case 2:
        return const Color(0xFFEF8C44);
      case 3:
        return TaxNGColors.warning;
      case 4:
        return TaxNGColors.secondary;
      case 5:
        return TaxNGColors.primary;
      default:
        return TaxNGColors.textLight;
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      // Allow skip without rating
      Navigator.pop(context, 0);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await UserActivityTracker.trackRating(
        _selectedRating,
        comment: _feedbackController.text.trim().isNotEmpty
            ? _feedbackController.text.trim()
            : null,
      );

      if (_feedbackController.text.trim().isNotEmpty) {
        await UserActivityTracker.trackFeedback(
          'Logout Rating: $_selectedRating/5 - ${_feedbackController.text.trim()}',
          category: 'logout_rating',
        );
      }

      if (mounted) {
        Navigator.pop(context, _selectedRating);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, _selectedRating);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  _getEmoji(_selectedRating),
                  key: ValueKey(_selectedRating),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'How was your experience?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : TaxNGColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'We\'d love to hear from you before you go',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : TaxNGColors.textMedium,
                ),
              ),
              const SizedBox(height: 20),

              // Star row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  final isSelected = _selectedRating >= star;
                  return GestureDetector(
                    onTap: _isSubmitting
                        ? null
                        : () => setState(() => _selectedRating = star),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getRatingColor(_selectedRating).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isSelected
                            ? _getRatingColor(_selectedRating)
                            : (isDark
                                ? Colors.white30
                                : TaxNGColors.borderMedium),
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Rating label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  _getLabel(_selectedRating),
                  key: ValueKey(_selectedRating),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedRating > 0
                        ? _getRatingColor(_selectedRating)
                        : (isDark ? Colors.white38 : TaxNGColors.textLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Feedback field (compact)
              if (_selectedRating > 0) ...[
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: TextField(
                    controller: _feedbackController,
                    enabled: !_isSubmitting,
                    maxLines: 2,
                    maxLength: 150,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : TaxNGColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Any suggestions? (optional)',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? Colors.white38 : TaxNGColors.textLighter,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      counterStyle: TextStyle(
                        fontSize: 10,
                        color:
                            isDark ? Colors.white30 : TaxNGColors.textLighter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, 0),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white54 : TaxNGColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRating > 0
                            ? TaxNGColors.primary
                            : TaxNGColors.textLighter,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selectedRating > 0 ? 'Submit Rating' : 'Logout',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show the logout rating dialog and return the selected rating (0 = skipped)
Future<int?> showLogoutRatingDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const LogoutRatingDialog(),
  );
}
