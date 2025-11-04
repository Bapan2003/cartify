import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

class SearchHistoryProvider extends ChangeNotifier {
  static const String _boxName = 'search_history';
  late Box<String> _box;

  List<String> _recentSearches = [];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  Future<void> init() async {
    _box = Hive.box<String>(_boxName);
    _recentSearches = _box.values.toList().reversed.toList();
    notifyListeners();
  }

  void addSearch(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);

    // keep only last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    // Clear and rewrite to Hive
    _box.clear();
    for (var item in _recentSearches.reversed) {
      _box.add(item);
    }

    notifyListeners();
  }

  void removeSearch(String term) {
    _recentSearches.remove(term);
    _box.clear();
    for (var item in _recentSearches.reversed) {
      _box.add(item);
    }
    notifyListeners();
  }

  void clearAll() {
    _recentSearches.clear();
    _box.clear();
    notifyListeners();
  }
}
