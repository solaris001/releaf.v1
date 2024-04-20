import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:markdown/markdown.dart' as md;

/// Holds the static Wiki entries loaded from the bundled assets
class Wiki {
  Wiki._(this.entries, this.keywords);

  /// A unordered list containing all the parsed wiki entries
  List<WikiEntry> entries;

  /// A set of all keywords of all entries with no duplicates (case-sensitive)
  Set<String> keywords;

  /// loads the Wiki from `assets/data/wiki/*.json`
  static Future<Wiki> fromAssets() async {
    final entries = <WikiEntry>[];

    // read List of available files in bundled assets
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;

    final wikiJSON = <String>[];

    // only try to parse files in "assets/data/wiki" that are JSON
    for (final key in manifest.keys) {
      if (key.startsWith('assets/data/wiki/converted/') &&
          key.endsWith('.json')) {
        wikiJSON.add(await rootBundle.loadString(key));
      }
    }

    final keywords = <String>{};

    // try to parse available JSON files, ignore them in case parsing fails
    for (final jsonString in wikiJSON) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      WikiEntry? entry;
      try {
        entry = WikiEntry.fromJSON(json);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      if (entry == null) continue;
      //! TEMPORARY
      // TODO(MindStudioOfficial): only use English articles
      if (entry.language != WikiLanguage.en) continue;

      entries.add(entry);
      keywords.addAll(entry.keywords);
    }

    return Wiki._(entries, keywords);
  }
}

/// Holds a wiki entry
///
/// uniquely identified (and linked to) using the [uuid]
///
/// [title] is the title of the article
///
/// [keywords] is a list of strings used to categorize and filter entries
///
/// [markdownContent] is the article content itself in Markdown (.md) format,
/// can contain markdown links to other wiki articles using
/// `[Link Text](other-uuid)`
///
/// [relatedWikiUUIDs] is intended as a way of linking to other articles but is
/// currently not used since linking works by adding a markdown link with the
/// other uuid as URL
///
/// [onlineResources] is intended as a way to refer to sources used to write
/// the article, currently not used
class WikiEntry {
  WikiEntry({
    required this.uuid,
    required this.title,
    required this.markdownContent,
    required this.language,
    this.author,
    this.keywords = const [],
    this.onlineResources = const [],
    this.relatedWikiUUIDs = const [],
    this.podcastURL,
  }) {
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );

    final lines = const LineSplitter().convert(markdownContent);

    final nodes = document.parseLines(lines);
    var wordCount = 0;

    for (final node in nodes) {
      if (node is md.Element) {
        final contentTags = <String>{
          'p',
          'ol',
          'ul',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
        };

        if (contentTags.contains(node.tag) && node.textContent.isNotEmpty) {
          // only set description if it's not already set
          _description ??= node.textContent;

          wordCount += node.textContent.split(' ').length;
        }
      }
    }

    _minutesRead = (wordCount / 238).ceil();
  }

  factory WikiEntry.fromJSON(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String uuid,
          'title': final String title,
          'markdown_content': final String markdownContent,
        }) {
      final keywords = <String>[];

      // if key "keywords" exists and is of type List, assign list to variable wikiKeywords
      if (json case {'keywords': final List<dynamic> wikiKeywords}) {
        for (final dynamic word in wikiKeywords) {
          if (word is String) keywords.add(word);
        }
      }

      final relatedEntries = <String>[];

      if (json case {'related_wikis': final List<dynamic> related}) {
        for (final dynamic rel in related) {
          if (rel is String) relatedEntries.add(rel);
        }
      }

      final onlineResources = <String>[];

      if (json case {'online_resources': final List<dynamic> resources}) {
        for (final dynamic resource in resources) {
          if (resource is String) onlineResources.add(resource);
        }
      }

      String? podcastURL;

      if (json case {'podcast_url': final String url}) {
        podcastURL = url;
      }

      String? author;

      if (json case {'author': final String authorName}) {
        author = authorName;
      }

      var language = WikiLanguage.de;

      if (json case {'language': final String lang}) {
        language = WikiEntry.languageMap[lang] ?? WikiLanguage.de;
      }

      return WikiEntry(
        uuid: uuid,
        title: title,
        markdownContent: markdownContent,
        author: author,
        keywords: keywords,
        onlineResources: onlineResources,
        relatedWikiUUIDs: relatedEntries,
        podcastURL: podcastURL,
        language: language,
      );
    }

    // later catched in Wiki parsing causing this article to be ignored
    throw Exception('Unable to parse Wiki entry:\n $json');
  }

  final String uuid;
  final String title;
  final String? author;
  final List<String> keywords;
  final String markdownContent;
  final List<String> relatedWikiUUIDs;
  final List<String> onlineResources;
  final String? podcastURL;

  String? _description;
  String get description => _description ?? 'No Content Available';

  final WikiLanguage language;

  int _minutesRead = 0;
  int get minutesRead => _minutesRead;

  @override
  String toString() {
    return '[$uuid]: $keywords $title';
  }

  static const Map<String, WikiLanguage> languageMap = {
    'de': WikiLanguage.de,
    'en': WikiLanguage.en,
  };
}

enum WikiLanguage { de, en }
