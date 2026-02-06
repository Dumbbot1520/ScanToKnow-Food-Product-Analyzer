// // lib/features/search/presentation/search_page.dart
//
// import 'dart:async';
// import 'package:flutter/material.dart';
//
// import '../data/search_repository.dart';
// import '../domain/search_item.dart';
// import 'widgets/search_result_tile.dart';
// import 'widgets/search_bar.dart';
// import '../../variants/presentation/variant_detail_page.dart';
//
// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   final _controller = TextEditingController();
//   Timer? _debounce;
//
//   List<ProductSuggestion> _suggestions = [];
//   List<VariantCard> _results = [];
//
//   bool _loadingSuggestions = false;
//   bool _searching = false;
//   String _query = '';
//
//   void _onTextChanged(String q) {
//     _debounce?.cancel();
//
//     if (q.trim().isEmpty) {
//       setState(() {
//         _suggestions = [];
//         _results = [];
//         _query = '';
//       });
//       return;
//     }
//
//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       setState(() => _loadingSuggestions = true);
//       final s = await SearchRepository.autocomplete(q.trim());
//       if (!mounted) return;
//       setState(() {
//         _suggestions = s;
//         _loadingSuggestions = false;
//       });
//     });
//   }
//
//   /// ENTER pressed
//   Future<void> _searchByQuery(String q) async {
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _searching = true;
//       _suggestions = [];
//       _query = q;
//     });
//
//     final res = await SearchRepository.searchByQuery(q);
//     if (!mounted) return;
//
//     setState(() {
//       _results = res;
//       _searching = false;
//     });
//   }
//
//   /// AUTOCOMPLETE TAP
//   Future<void> _searchByProduct(ProductSuggestion s) async {
//     FocusScope.of(context).unfocus();
//     _controller.text = s.label;
//
//     setState(() {
//       _searching = true;
//       _suggestions = [];
//       _query = s.label;
//     });
//
//     final res = await SearchRepository.searchByProductId(s.id);
//     if (!mounted) return;
//
//     setState(() {
//       _results = res;
//       _searching = false;
//     });
//   }
//
//   void _openVariant(VariantCard v) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => VariantDetailPage(variantId: v.id)),
//     );
//   }
//
//   void _clear() {
//     _controller.clear();
//     setState(() {
//       _suggestions = [];
//       _results = [];
//       _query = '';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: SearchBarSmall(
//           controller: _controller,
//           onChanged: _onTextChanged,
//           onSubmitted: _searchByQuery,
//           onClear: _clear,
//         ),
//       ),
//       body: Column(
//         children: [
//           if (_loadingSuggestions) const LinearProgressIndicator(minHeight: 2),
//
//           /// AUTOCOMPLETE
//           if (_suggestions.isNotEmpty)
//             Container(
//               color: Colors.white,
//               constraints: const BoxConstraints(maxHeight: 260),
//               child: ListView.builder(
//                 itemCount: _suggestions.length,
//                 itemBuilder: (_, i) {
//                   final s = _suggestions[i];
//                   return ListTile(
//                     leading: const Icon(Icons.search),
//                     title: Text(s.label),
//                     subtitle: s.brand != null ? Text(s.brand!) : null,
//                     onTap: () => _searchByProduct(s),
//                   );
//                 },
//               ),
//             ),
//
//           /// RESULTS
//           Expanded(
//             child: _searching
//                 ? const Center(child: CircularProgressIndicator())
//                 : _results.isEmpty
//                 ? Center(
//               child: Text(
//                 _query.isEmpty
//                     ? 'Type to search products'
//                     : 'No results for "$_query"',
//               ),
//             )
//                 : ListView.builder(
//               itemCount: _results.length,
//               itemBuilder: (_, i) {
//                 final v = _results[i];
//                 return SearchResultTile(
//                   item: v,
//                   onTap: () => _openVariant(v),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';

import '../data/search_repository.dart';
import '../domain/search_item.dart';
import 'widgets/search_result_tile.dart';
import 'widgets/search_bar.dart';
import 'product_page.dart';
import '../../variants/presentation/variant_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<ProductSuggestion> _suggestions = [];
  List<VariantCard> _results = [];

  bool _loadingSuggestions = false;
  bool _searching = false;
  String _query = '';

  // ---------------- AUTOCOMPLETE ----------------
  void _onTextChanged(String val) {
    _debounce?.cancel();

    final query = val.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _results = [];
        _query = '';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loadingSuggestions = true);
      try {
        final s = await SearchRepository.autocomplete(query);
        if (!mounted) return;
        setState(() {
          _suggestions = s;
          _loadingSuggestions = false;
        });
      } catch (_) {
        if (mounted) setState(() => _loadingSuggestions = false);
      }
    });
  }

  // ---------------- SEARCH (ENTER / FAB) ----------------
  Future<void> _doSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    // UX RULE: if exactly one suggestion → open product page
    if (_suggestions.length == 1) {
      _onSuggestionTap(_suggestions.first);
      return;
    }

    setState(() {
      _searching = true;
      _suggestions = [];
      _query = query;
    });

    final res = await SearchRepository.searchByQuery(query);
    if (!mounted) return;

    setState(() {
      _results = res;
      _searching = false;
    });
  }

  // ---------------- SUGGESTION TAP ----------------
  void _onSuggestionTap(ProductSuggestion s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductPage(
          productId: s.id,
          productLabel: s.label,
        ),
      ),
    );
  }

  // ---------------- VARIANT TAP ----------------
  void _openVariant(VariantCard v) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VariantDetailPage(variantId: v.id),
      ),
    );
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _suggestions = [];
      _results = [];
      _query = '';
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: SearchBarSmall(
          controller: _controller,
          onChanged: _onTextChanged,
          onSubmitted: _doSearch,
          onClear: _clear,
        ),
      ),
      body: Column(
        children: [
          if (_loadingSuggestions)
            const LinearProgressIndicator(minHeight: 2),

          // ---------- AUTOCOMPLETE ----------
          if (_suggestions.isNotEmpty)
            Container(
              color: Colors.white,
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (_, i) {
                  final s = _suggestions[i];
                  return ListTile(
                    leading: const Icon(Icons.search),
                    title: Text(s.label),
                    subtitle: s.brand != null ? Text(s.brand!) : null,
                    onTap: () => _onSuggestionTap(s),
                  );
                },
              ),
            ),

          // ---------- RESULTS ----------
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(
              child: Text(
                _query.isEmpty
                    ? 'Type to search products'
                    : 'No results for "$_query"',
              ),
            )
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final v = _results[i];
                return SearchResultTile(
                  item: v,
                  onTap: () => _openVariant(v),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _controller.text.trim().isNotEmpty
          ? FloatingActionButton(
        onPressed: () => _doSearch(_controller.text),
        child: const Icon(Icons.search),
      )
          : null,
    );
  }
}
