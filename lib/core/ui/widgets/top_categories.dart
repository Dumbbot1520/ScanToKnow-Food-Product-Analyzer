// lib/core/ui/widgets/top_categories.dart
// updated TopCategories widget: uses backend imageUrl if present;
// otherwise uses front-end resolver `assetForCategorySlug(slug)`
// (keeps same public API: pass List<CategoryItem>)

import 'package:flutter/material.dart';
import '../category_image_resolver.dart'; // relative to widgets folder

/// Simple category model used by this widget.
/// Prefer to map your backend DTO into this shape before passing it in.
class CategoryItem {
  final String id;
  final String slug;
  final String title;
  final String? imageUrl;
  final int? productCount;

  const CategoryItem({
    required this.id,
    required this.slug,
    required this.title,
    this.imageUrl,
    this.productCount,
  });
}

/// TopCategories widget
/// - Accepts a list of categories (level-1). If the list is longer than
///   [visibleCount], only the first [visibleCount] are rendered.
/// - If the list has fewer items than [visibleCount], placeholders are shown.
class TopCategories extends StatelessWidget {
  final List<CategoryItem>? categories;
  final int visibleCount;
  final void Function(CategoryItem category)? onCategoryTap;
  final VoidCallback? onViewAll;

  const TopCategories({
    super.key,
    this.categories,
    this.visibleCount = 6,
    this.onCategoryTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final items = categories ?? const [];

    return Column(
      children: [
        // Title + View All
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Top Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal scroll
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: visibleCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index < items.length) {
                final item = items[index];
                return _CategoryCard(
                  title: item.title,
                  slug: item.slug,
                  imageUrl: item.imageUrl,
                  badgeCount: item.productCount,
                  onTap: () => onCategoryTap?.call(item),
                );
              } else {
                // Placeholder / Coming soon card
                return const _PlaceholderCategoryCard();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String slug;
  final String? imageUrl;
  final int? badgeCount;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.title,
    required this.slug,
    this.imageUrl,
    this.badgeCount,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // decide image source: backend imageUrl > local asset resolver
    final String? localAsset = assetForCategorySlug(slug);
    final bool useNetwork = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: useNetwork
                    ? Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, _, __) =>
                      Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade400)),
                )
                    : (localAsset != null
                    ? Image.asset(
                  localAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, _, __) =>
                      Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade400)),
                )
                    : Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade400))),
              ),
            ),

            const SizedBox(height: 6),

            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (badgeCount != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCategoryCard extends StatelessWidget {
  const _PlaceholderCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 52, height: 52, color: Colors.grey.shade100),
          const SizedBox(height: 6),
          const Text('Coming soon', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
