import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingShimmer({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ArticleCardShimmer extends StatelessWidget {
  const ArticleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            const LoadingShimmer(
              height: 200,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),

            const SizedBox(height: 12),

            // Title placeholder
            const LoadingShimmer(height: 20, width: double.infinity),

            const SizedBox(height: 8),

            const LoadingShimmer(height: 20, width: 250),

            const SizedBox(height: 12),

            // Description placeholder
            const LoadingShimmer(height: 16, width: double.infinity),

            const SizedBox(height: 4),

            const LoadingShimmer(height: 16, width: double.infinity),

            const SizedBox(height: 4),

            const LoadingShimmer(height: 16, width: 200),

            const SizedBox(height: 12),

            // Meta info placeholder
            Row(
              children: [
                const LoadingShimmer(
                  height: 24,
                  width: 80,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 8),
                const LoadingShimmer(
                  height: 24,
                  width: 60,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const Spacer(),
                LoadingShimmer(
                  height: 32,
                  width: 32,
                  borderRadius: BorderRadius.circular(16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChipShimmer extends StatelessWidget {
  const CategoryChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: const LoadingShimmer(
        height: 34,
        width: 100,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}

class NewsListShimmer extends StatelessWidget {
  final int itemCount;

  const NewsListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ArticleCardShimmer(),
    );
  }
}

class CategoryListShimmer extends StatelessWidget {
  const CategoryListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) => const CategoryChipShimmer(),
      ),
    );
  }
}

class ArticleDetailShimmer extends StatelessWidget {
  const ArticleDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image placeholder
          const LoadingShimmer(
            height: 250,
            width: double.infinity,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),

          const SizedBox(height: 20),

          // Title placeholder
          const LoadingShimmer(height: 28, width: double.infinity),

          const SizedBox(height: 8),

          const LoadingShimmer(height: 28, width: 250),

          const SizedBox(height: 16),

          // Meta info placeholder
          Row(
            children: [
              LoadingShimmer(
                height: 40,
                width: 40,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer(height: 16, width: 120),
                    SizedBox(height: 4),
                    LoadingShimmer(height: 14, width: 80),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Content placeholders
          ...List.generate(
            8,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LoadingShimmer(
                height: 16,
                width: index.isEven ? double.infinity : 280,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
