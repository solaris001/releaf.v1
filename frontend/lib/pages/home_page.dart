import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/stats_provider.dart';
import 'package:releaf/utilities/datetime_extension.dart';
import 'package:simple_shadow/simple_shadow.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          interactive: true,
          controller: scrollController,
          child: ListView.builder(
            controller: scrollController,
            // ? use stats.perDayStats instead of stats.dailyStats
            // ? because it contains null values for days without stats
            // ? so we don't have holes in the list
            itemCount: stats.perDayStats.length,
            itemBuilder: (context, index) {
              final MapEntry(key: date, value: stat) =
                  stats.perDayStats.entries.elementAt(index);

              return perDayLeafStone(
                date,
                stat,
                index,
                constraints,
              );
            },
          ),
        );
      },
    );
  }

  Widget perDayLeafStone(
    Date day,
    DailyStats? stat,
    int index,
    BoxConstraints pageConstraints,
  ) {
    final alignment =
        index.isOdd ? Alignment.centerLeft : Alignment.centerRight;

    final leafAsset = switch (stat?.leafCount) {
      null => 'assets/images/Leaves_0_v2.svg',
      0 => 'assets/images/Leaves_0_v2.svg',
      1 => 'assets/images/Leaves_1_v2.svg',
      2 => 'assets/images/Leaves_2_v2.svg',
      3 => 'assets/images/Leaves_3_v2.svg',
      _ => 'assets/images/Leaves_3_v2.svg',
    };

    final isToday = index == 0;
    final isStartOfWeek = day.weekday == DateTime.monday;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => DailyStatsDialog(
                stat: stat,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (index.isEven && index % 5 == 0)
                SvgPicture.asset('assets/images/MascotWithPaws.svg'),
              Expanded(
                child: Align(
                  alignment: alignment,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: pageConstraints.maxWidth / 6,
                      vertical: 4,
                    ),
                    child: isToday
                        ? SimpleShadow(
                            opacity: 1,
                            sigma: 10,
                            color: Theme.of(context).colorScheme.primary,
                            child: SvgPicture.asset(
                              leafAsset,
                              width: pageConstraints.maxWidth / 7 * 2,
                            ),
                          )
                        : SvgPicture.asset(
                            leafAsset,
                            width: pageConstraints.maxWidth / 7 * 2,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isStartOfWeek) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              '${day.year} - Week ${day.calenderWeek} - ${DateFormat('MMMd').formatDate(day)}',
            ),
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
            thickness: 0.3,
            height: 1,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }
}

class DailyStatsDialog extends StatefulWidget {
  const DailyStatsDialog({required this.stat, super.key});
  final DailyStats? stat;

  @override
  State<DailyStatsDialog> createState() => _DailyStatsDialogState();
}

class _DailyStatsDialogState extends State<DailyStatsDialog> {
  @override
  Widget build(BuildContext context) {
    if (widget.stat == null) {
      return const SimpleDialog(
        title: Text('No stats for this day yet'),
        children: [
          Icon(
            Icons.note_outlined,
            size: 100,
          ),
        ],
      );
    }
    final stat = widget.stat!;
    return SimpleDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Progress for\n${DateFormat.yMMMMd().formatDate(widget.stat!.date)}',
            ),
          ),
          // close button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      children: [
        Divider(
          indent: 20,
          endIndent: 20,
          thickness: 0.3,
          height: 1,
          color: Colors.grey.shade800,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Happy Hour',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        happyHourTile(
          'What made you smile today?',
          stat.happyHourStats.entryHappy,
        ),
        happyHourTile(
          'What made you proud today?',
          stat.happyHourStats.entryProud,
        ),
        happyHourTile(
          'What are you thankful for today?',
          stat.happyHourStats.entryThankful,
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: Text(
            '${widget.stat!.feedbacksGiven} / ${DailyStats.feedbackLeafThreshold} feedbacks given',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: Text(
            '${widget.stat!.minutesSpentStudying} / ${widget.stat!.studyGoalMinutes} minutes spent studying',
          ),
        ),
      ],
    );
  }

  Widget happyHourTile(String question, String answer) {
    final done = answer.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(question)),
          SvgPicture.asset(
            done
                ? 'assets/images/circle-check-filled.svg'
                : 'assets/images/circle-check.svg',
          ),
        ],
      ),
    );
  }
}
