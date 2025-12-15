
import 'package:flutter/material.dart';

/// Simple immutable model for each category
class CategoryItem {
  final String id;
  final String title;
  final String asset;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.asset,
  });
}

/// TopCategories widget
/// Shows a horizontally scrollable list of category cards with image + label.
/// Tapping a category triggers a callback (or shows a placeholder snackbar).
class TopCategories extends StatelessWidget {
  final void Function(String categoryId, String title)? onCategoryTap;

  const TopCategories({super.key, this.onCategoryTap});

  // The categories shown in the top row
  final List<CategoryItem> _categories = const [
    CategoryItem(
      id: 'drinks',
      title: 'Drinks',
      asset: 'images/home_page_images/drinks.png',
    ),
    CategoryItem(
      id: 'noodles_pasta',
      title: 'Noodles & Pasta',
      asset: 'images/home_page_images/noodles_&_pasta.png',
    ),
    CategoryItem(
      id: 'chips',
      title: 'Chips & Crunch',
      asset: 'images/home_page_images/chips.png',
    ),
    CategoryItem(
      id: 'biscuits',
      title: 'Biscuits',
      asset: 'images/home_page_images/cookies.png',
    ),
    CategoryItem(
      id: 'namkeen',
      title: 'Namkeen',
      asset: 'images/home_page_images/namkeen.png',
    ),
    CategoryItem(
      id: 'chocolates',
      title: 'Chocolates',
      asset: 'images/home_page_images/chocolate.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row: Title + View All
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
                onPressed: () {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text("View All tapped (placeholder)")),
                //   );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: const Text('View All'),
              ),

            ],
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal scroll of categories
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _categories[index];

              return GestureDetector(
                onTap: () {
                  if (onCategoryTap != null) {
                    onCategoryTap!(item.id, item.title);
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.title} tapped (placeholder)')),
                  );
                },
                child: Container(
                  width: 92,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image (kept compact)
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.asset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Make the text flexible so it doesn't overflow vertically
                      Flexible(
                        child: Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
