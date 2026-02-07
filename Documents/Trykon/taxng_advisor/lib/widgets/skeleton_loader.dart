import 'package:flutter/material.dart';
import 'package:taxng_advisor/theme/colors.dart';

/// Skeleton loading widget that shows a shimmering placeholder
/// while content is loading. Gives a modern perceived-performance boost.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      TaxNGColors.bgDarkSecondary
                          .withOpacity(_animation.value * 0.5),
                      TaxNGColors.bgDarkSecondary
                          .withOpacity(_animation.value * 0.8),
                      TaxNGColors.bgDarkSecondary
                          .withOpacity(_animation.value * 0.5),
                    ]
                  : [
                      TaxNGColors.borderLight
                          .withOpacity(_animation.value * 0.4),
                      TaxNGColors.borderLight
                          .withOpacity(_animation.value * 0.7),
                      TaxNGColors.borderLight
                          .withOpacity(_animation.value * 0.4),
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}

/// A full dashboard skeleton screen shown while data is loading
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card skeleton
          const SkeletonLoader(height: 100, borderRadius: 20),
          const SizedBox(height: 24),
          // Title skeleton
          const SkeletonLoader(height: 20, width: 150),
          const SizedBox(height: 14),
          // Grid skeleton
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: List.generate(
                6, (_) => const SkeletonLoader(height: 100, borderRadius: 16)),
          ),
          const SizedBox(height: 24),
          // Quick actions skeleton
          const SkeletonLoader(height: 20, width: 120),
          const SizedBox(height: 14),
          const SkeletonLoader(height: 60, borderRadius: 14),
          const SizedBox(height: 10),
          const SkeletonLoader(height: 60, borderRadius: 14),
        ],
      ),
    );
  }
}
