import 'package:flutter/material.dart';
import 'package:taxng_advisor/services/user_activity_tracker.dart';

/// Rating Dialog Widget
/// 
/// Allows users to rate the TaxPadi app with a 1-5 star rating.
/// Automatically tracks the rating using UserActivityTracker.
class RatingDialog extends StatefulWidget {
  const RatingDialog({Key? key}) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Track the rating
      await UserActivityTracker.trackRating(_selectedRating);

      // If they provided feedback, track that too
      if (_feedbackController.text.trim().isNotEmpty) {
        await UserActivityTracker.trackFeedback(
          'Rating: $_selectedRating/5 - ${_feedbackController.text}',
        );
      }

      if (mounted) {
        Navigator.pop(context, _selectedRating);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your $_selectedRating⭐ rating!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.star_rate, color: Colors.amber[700], size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Rate TaxPadi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How would you rate your experience?',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Star Rating Selector
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNumber = index + 1;
                  return GestureDetector(
                    onTap: _isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _selectedRating = starNumber;
                            });
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        _selectedRating >= starNumber
                            ? Icons.star
                            : Icons.star_border,
                        color: _selectedRating >= starNumber
                            ? Colors.amber[600]
                            : Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _selectedRating == 0
                    ? 'Tap to rate'
                    : _getRatingText(_selectedRating),
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedRating == 0
                      ? Colors.grey[600]
                      : Colors.amber[800],
                  fontWeight: _selectedRating == 0
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Optional Feedback
            TextField(
              controller: _feedbackController,
              enabled: !_isSubmitting,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: 'Additional Feedback (Optional)',
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.comment),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your rating helps us improve TaxPadi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitRating,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.send, size: 20),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Rating'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
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
        return '';
    }
  }
}

/// Helper function to show the rating dialog
Future<int?> showRatingDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) => const RatingDialog(),
  );
}
