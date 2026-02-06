import 'package:flutter/material.dart';
import '../data/search_repository.dart';
import '../domain/search_item.dart';
import '../../variants/presentation/variant_detail_page.dart';
import 'widgets/search_result_tile.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  final String productLabel;

  const ProductPage({
    super.key,
    required this.productId,
    required this.productLabel,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<VariantCard>> _futureVariants;

  @override
  void initState() {
    super.initState();
    _futureVariants =
        SearchRepository.searchByProductId(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productLabel),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<VariantCard>>(
        future: _futureVariants,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text('Failed to load variants'));
          }

          final variants = snap.data ?? [];

          if (variants.isEmpty) {
            return const Center(child: Text('No variants found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: variants.length,
            itemBuilder: (_, i) {
              final v = variants[i];
              return SearchResultTile(
                item: v,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VariantDetailPage(variantId: v.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
