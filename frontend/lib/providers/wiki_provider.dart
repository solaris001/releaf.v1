import 'package:flutter/material.dart';
import 'package:releaf/services/wiki_parser.dart';

/// Manages the global state of the Wiki
///
/// when [notifyListeners()] is called,
/// all parts of the UI that depend on it automatically update
class WikiProvider with ChangeNotifier {
  WikiProvider() {
    // Read all entries from assets/data/wiki/*.json
    Wiki.fromAssets().then((wiki) {
      _wiki = wiki;

      // set all keywords to disabled (none is filtered, all are displayed)
      for (final element in wiki.keywords) {
        _keywordFilter.addAll({element: false});
      }

      // add all entries to the visible entries
      for (final element in wiki.entries) {
        filteredEntries.add(element);
      }
      // notify the UI to update
      notifyListeners();
    });
  }

  /// Holds all the static wiki entries
  Wiki? _wiki;

  /// the getter for the static wiki entries
  Wiki? get wiki => _wiki;

  /// whether entries with a certain keyword should be displayed [true] or not [false]
  /// can be updated by calling `updateKeywordFilter(String keyword, bool enabled)`
  final Map<String, bool> _keywordFilter = {};

  /// whether entries with a certain keyword should be displayed [true] or not [false]
  /// can be updated by calling `updateKeywordFilter(String keyword, bool enabled)`
  Map<String, bool> get keywordFilter => _keywordFilter;

  /// contains all currently visible wiki entries
  /// the list is updated via `updateKeywordFilter(String keyword, bool enabled)`
  List<WikiEntry> _filteredEntries = [];

  /// contains all currently visible wiki entries
  /// the list is updated via `updateKeywordFilter(String keyword, bool enabled)`
  List<WikiEntry> get filteredEntries => _filteredEntries;

  /// converts the map of keyword:enabled
  /// to a set of keywords only containing enabled keywords
  Set<String> get _filteredKeywords => Set.from(
        _keywordFilter.keys.where((element) => _keywordFilter[element]!),
      );

  /// refills the list of visible entries using the set of enabled keywords
  void _updateFilteredEntries() {
    _filteredEntries = [];
    if (wiki == null) return;

    // check if entry has enabled keywords
    for (final entry in wiki!.entries) {
      if (entry.keywords
              .any((keyword) => _filteredKeywords.contains(keyword)) ||
          _filteredKeywords.isEmpty) {
        _filteredEntries.add(entry);
      }
    }
  }

  /// set entries with a certain [keyword] to be visible [enabled = true] or not [enabled = false]
  ///
  /// Widgets that watch for changes of this provider are automatically notified
  void updateKeywordFilter(String keyword, bool enabled) {
    _keywordFilter[keyword] = enabled;
    _updateFilteredEntries();
    notifyListeners();
  }
}
