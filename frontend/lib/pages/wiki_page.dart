import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:releaf/models/app_colors.dart';
import 'package:releaf/pages/pages.dart';
import 'package:releaf/pages/wiki_entry_page.dart';
import 'package:releaf/providers/wiki_provider.dart';
import 'package:releaf/services/wiki_parser.dart';

// Note! The wiki content is created using generative AI.
// The App that will be deployed for a wider audience,
// will use content created and validated by psychologists. 

class WikiPage extends StatelessWidget {
  const WikiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wikiProv = context.watch<WikiProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Today's topics"),
            // * Learn type test button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const QuizPage(),
                  ),
                );
              },
              child: const Text('Test yourself!'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // * Keyword filter
            if (wikiProv.wiki != null) keywordFilter(wikiProv, context),
            // * Article List
            Expanded(
              child: wikiProv.wiki != null
                  ? ListView.builder(
                      itemCount: wikiProv.filteredEntries.length,
                      itemBuilder: (context, entryIndex) {
                        final entry = wikiProv.filteredEntries[entryIndex];
                        return entryCard(context, entry);
                      },
                    )
                  : // * indicate loading in case the wiki hasn't loaded yet
                  const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget entryCard(BuildContext context, WikiEntry entry) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // * Open That entry.
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => WikiEntryPage(entryUUID: entry.uuid),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                entryTitle(entry, context),
                entryDescription(entry, context),
                entryKeywords(entry, context),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      entryAuthor(entry, context),
                      entryReadingTimeIndicator(entry, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget keywordFilter(WikiProvider wikiProv, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(wikiProv.keywordFilter.length, (index) {
          final keyword = wikiProv.keywordFilter.keys.elementAt(index);
          final enabled = wikiProv.keywordFilter.values.elementAt(index);

          return GestureDetector(
            onTap: () {
              wikiProv.updateKeywordFilter(keyword, !enabled);
            },
            child: keywordChip(enabled, keyword, context),
          );
        }),
      ),
    );
  }

  Widget entryTitle(WikiEntry entry, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        entry.title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget entryDescription(WikiEntry entry, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        entry.description,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget entryKeywords(WikiEntry entry, BuildContext context) {
    return Wrap(
      children: List<Widget>.generate(
        entry.keywords.length,
        (keywordIndex) => Padding(
          padding: const EdgeInsets.all(2),
          child: keywordChip(
            false,
            entry.keywords[keywordIndex],
            context,
          ),
        ),
      ),
    );
  }

  Widget keywordChip(bool enabled, String keyword, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Chip(
        backgroundColor: enabled
            ? getKeywordChipColor(keyword).withOpacity(.5)
            : getKeywordChipColor(keyword),
        label: Text(
          keyword,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Color getKeywordChipColor(String keyword) {
    // hash the keyword to get a color from the list
    final hash = keyword.hashCode;
    final index = hash % AppColors.wikiKeywordChipColors.length;
    return AppColors.wikiKeywordChipColors[index];
  }

  Widget entryReadingTimeIndicator(WikiEntry entry, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SvgPicture.asset(
            'assets/images/time.svg',
            height: 35,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '${entry.minutesRead} min',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondary.withOpacity(.5),
                ),
          ),
        ),
      ],
    );
  }

  Widget entryAuthor(WikiEntry entry, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SvgPicture.asset(
            'assets/images/ballpen.svg',
            height: 35,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            entry.author ?? 'Unknown Author',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondary.withOpacity(.5),
                ),
          ),
        ),
      ],
    );
  }
}
