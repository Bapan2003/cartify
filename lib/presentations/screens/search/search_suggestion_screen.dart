import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/widgets/gradient_bar.dart';

import '../../../providers/search_history_provider.dart';
import '../../../providers/search_providers.dart';



class SearchSuggestionPage extends StatelessWidget {
  const SearchSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final historyProvider = context.watch<SearchHistoryProvider>();
    final query = searchProvider.query;

    // get all product names from Firestore
    final allNames = searchProvider.filteredProducts
        .map((doc) => (doc.data() as Map<String, dynamic>)['product_name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    // show either history or matching suggestions
    final suggestions = query.isEmpty
        ? historyProvider.recentSearches
        : allNames.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();

    final showFallback = query.isNotEmpty && suggestions.isEmpty;

    // ✅ Add responsive wrapper for web
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: const GradientBar(),
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            height: 45,
            margin: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Search products...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: searchProvider.updateQuery,
              onSubmitted: (value) {
                historyProvider.addSearch(value);
                Navigator.pop(context, value);
              },
            ),
          ),
        ),
        centerTitle: isWeb, // Center title only on web
      ),

      // ✅ Responsive body container
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 600 : double.infinity, // Limit width on web
          ),
          child: searchProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 16 : 0, // Add padding on web
            ),
            itemCount: showFallback ? 1 : suggestions.length,
            itemBuilder: (context, index) {
              final text = showFallback
                  ? "Search for '$query'"
                  : suggestions[index];
              final isRecent = query.isEmpty;

              return ListTile(
                leading: Icon(
                  isRecent ? Icons.history : Icons.search,
                  color: Colors.black54,
                ),
                title: Text(text),
                trailing: isRecent
                    ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => historyProvider.removeSearch(text),
                )
                    : null,
                onTap: () {
                  final selected = showFallback ? query : text;
                  historyProvider.addSearch(selected);
                  Navigator.pop(context, selected);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

