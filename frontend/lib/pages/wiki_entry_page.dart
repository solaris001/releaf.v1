import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:releaf/providers/wiki_provider.dart';
import 'package:releaf/services/wiki_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class WikiEntryPage extends StatefulWidget {
  const WikiEntryPage({required this.entryUUID, super.key});
  final String entryUUID;

  @override
  State<WikiEntryPage> createState() => _WikiEntryPageState();
}

class _WikiEntryPageState extends State<WikiEntryPage> {
  WikiEntry? entry;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // obtain the wiki data through the provider
    final wiki = context.read<WikiProvider>().wiki;

    // test if wiki loaded and entry with provided uuid exists
    if (wiki == null ||
        !wiki.entries.any((element) => element.uuid == widget.entryUUID)) {
      // leave the page in case the wiki hasn't loaded yet
      Navigator.pop(context);
      return;
    }
    // find the current wiki entry by uuid
    entry =
        wiki.entries.firstWhere((element) => element.uuid == widget.entryUUID);
  }

  @override
  Widget build(BuildContext context) {
    //  obtain the wiki data through the provider and listen for changes, rebuilds automatically
    final wiki = context.watch<WikiProvider>().wiki;
    return Scaffold(
      appBar: AppBar(
        title: Text(entry?.title ?? 'Unknown Entry'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: entry?.podcastURL != null
                ? () {
                    player.play(UrlSource(entry!.podcastURL!));
                  }
                : null,
            child: const Text('Play Audio'),
          ),
          Expanded(
            child: Markdown(
              data: entry?.markdownContent ??
                  "Couldn't find the wiki page you are looking for!",
              selectable: true,
              extensionSet: md.ExtensionSet.gitHubFlavored,
              styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
              // override text styles
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: Theme.of(context).textTheme.bodyLarge,
                h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                a: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
              ),
              onTapLink: (text, href, title) {
                if (href == null) return;
                // * Test if URL href is equal to a wiki entry uuid and then open that entry.
                if (wiki!.entries.any((element) => element.uuid == href)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => WikiEntryPage(entryUUID: href),
                    ),
                  );
                }
                // Launch other urls normally
                else {
                  final uri = Uri.tryParse(href);
                  if (uri != null) launchUrl(uri);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
