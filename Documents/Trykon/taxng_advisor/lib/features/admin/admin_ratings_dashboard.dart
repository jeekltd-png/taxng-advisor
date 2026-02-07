import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxng_advisor/services/user_activity_tracker.dart';
import 'package:taxng_advisor/services/auth_service.dart';
import 'package:taxng_advisor/models/user.dart';
import 'package:taxng_advisor/models/user_activity.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Admin Ratings Dashboard — Dedicated screen for viewing all app ratings
///
/// Shows:
/// - Average rating with visual breakdown
/// - Individual rating entries with user, comment, date
/// - Filter by star level and date range
/// - Feedback comments associated with ratings
class AdminRatingsDashboard extends StatefulWidget {
  const AdminRatingsDashboard({super.key});

  @override
  State<AdminRatingsDashboard> createState() => _AdminRatingsDashboardState();
}

class _AdminRatingsDashboardState extends State<AdminRatingsDashboard> {
  bool _isLoading = true;
  User? _currentUser;
  List<UserActivity> _allRatings = [];
  List<UserActivity> _filteredRatings = [];
  int? _filterStar;
  String _sortOrder = 'newest';

  @override
  void initState() {
    super.initState();
    _checkAccessAndLoad();
  }

  Future<void> _checkAccessAndLoad() async {
    final user = await AuthService.currentUser();
    if (user == null || !user.isAdmin) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin privileges required.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    _currentUser = user;
    await _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() => _isLoading = true);
    final ratings =
        await UserActivityTracker.getAllActivities(activityType: 'rating');
    setState(() {
      _allRatings = ratings;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    var list = List<UserActivity>.from(_allRatings);
    if (_filterStar != null) {
      list = list.where((r) => r.rating == _filterStar).toList();
    }
    if (_sortOrder == 'newest') {
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_sortOrder == 'oldest') {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else if (_sortOrder == 'highest') {
      list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    } else {
      list.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
    }
    _filteredRatings = list;
  }

  double get _averageRating {
    if (_allRatings.isEmpty) return 0;
    final sum = _allRatings.fold<int>(0, (s, r) => s + (r.rating ?? 0));
    return sum / _allRatings.length;
  }

  Map<int, int> get _ratingDistribution {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in _allRatings) {
      if (r.rating != null && r.rating! >= 1 && r.rating! <= 5) {
        dist[r.rating!] = (dist[r.rating!] ?? 0) + 1;
      }
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
      appBar: AppBar(
        title: const Text('App Ratings'),
        backgroundColor: TaxNGColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRatings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRatings,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(isDark),
                    const SizedBox(height: 16),
                    _buildDistributionCard(isDark),
                    const SizedBox(height: 16),
                    _buildFilterBar(isDark),
                    const SizedBox(height: 12),
                    _buildRatingsList(isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    final avg = _averageRating;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: TaxNGColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Overall Rating',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            avg.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Icon(
                i < avg.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.amber[300],
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${_allRatings.length} total ratings',
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(bool isDark) {
    final dist = _ratingDistribution;
    final total = _allRatings.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : TaxNGColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 5; i >= 1; i--)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white70 : TaxNGColors.textDark,
                      ),
                    ),
                  ),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? (dist[i] ?? 0) / total : 0,
                        backgroundColor:
                            isDark ? Colors.white10 : TaxNGColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStarColor(i),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${dist[i] ?? 0}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white54 : TaxNGColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Row(
      children: [
        // Star filter chips
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('All', _filterStar == null, isDark, () {
                  setState(() {
                    _filterStar = null;
                    _applyFilter();
                  });
                }),
                for (int i = 5; i >= 1; i--)
                  _buildChip('$i ⭐', _filterStar == i, isDark, () {
                    setState(() {
                      _filterStar = i;
                      _applyFilter();
                    });
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Sort dropdown
        PopupMenuButton<String>(
          icon: Icon(Icons.sort_rounded,
              color: isDark ? Colors.white60 : TaxNGColors.textMedium),
          onSelected: (v) {
            setState(() {
              _sortOrder = v;
              _applyFilter();
            });
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'newest', child: Text('Newest First')),
            const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
            const PopupMenuItem(
                value: 'highest', child: Text('Highest Rating')),
            const PopupMenuItem(value: 'lowest', child: Text('Lowest Rating')),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
      String label, bool selected, bool isDark, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? TaxNGColors.primary
                : (isDark ? Colors.white10 : TaxNGColors.bgLight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? TaxNGColors.primary
                  : (isDark
                      ? Colors.white.withOpacity(0.2)
                      : TaxNGColors.borderLight),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white60 : TaxNGColors.textMedium),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingsList(bool isDark) {
    if (_filteredRatings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.star_outline_rounded,
                  size: 48,
                  color: isDark ? Colors.white24 : TaxNGColors.textLighter),
              const SizedBox(height: 12),
              Text(
                'No ratings found',
                style: TextStyle(
                  color: isDark ? Colors.white38 : TaxNGColors.textLight,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredRatings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final rating = _filteredRatings[index];
        return _buildRatingCard(rating, isDark);
      },
    );
  }

  Widget _buildRatingCard(UserActivity rating, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TaxNGColors.bgDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A3E) : TaxNGColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    _getStarColor(rating.rating ?? 0).withOpacity(0.15),
                child: Text(
                  rating.username.isNotEmpty
                      ? rating.username[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _getStarColor(rating.rating ?? 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : TaxNGColors.textDark,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a')
                          .format(rating.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : TaxNGColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < (rating.rating ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                    color: i < (rating.rating ?? 0)
                        ? Colors.amber
                        : (isDark
                            ? Colors.white.withOpacity(0.2)
                            : TaxNGColors.borderLight),
                  );
                }),
              ),
            ],
          ),
          // Show comment if any
          if (rating.details != null && rating.details!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? TaxNGColors.bgDark : TaxNGColors.bgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rating.details!,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : TaxNGColors.textMedium,
                  height: 1.4,
                ),
              ),
            ),
          ],
          // Device info
          if (rating.deviceInfo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.devices_rounded,
                  size: 12,
                  color: isDark ? Colors.white24 : TaxNGColors.textLighter,
                ),
                const SizedBox(width: 4),
                Text(
                  '${rating.deviceInfo} • v${rating.appVersion ?? "?"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white24 : TaxNGColors.textLighter,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStarColor(int rating) {
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
}
