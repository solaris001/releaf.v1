import 'dart:async';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:releaf/providers/stats_provider.dart';
import 'package:releaf/providers/timer_provider.dart';
import 'package:releaf/services/notify_service.dart';
import 'package:releaf/utilities/duration_extension.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  double get remainingPercent =>
      context.read<TimerProvider>().remainingTime.inSeconds /
      context.read<TimerProvider>().initialTime.inSeconds *
      100;
  late double pointerValue;

  late StreamSubscription<TimerEvent> eventStreamSubscription;

  static int maxInitialTimeInMinutes = 120;

  bool timerWasPausedBeforeAppMinimized = false;

  @override
  void initState() {
    super.initState();

    final timer = context.read<TimerProvider>();

    pointerValue = timer.initialTime.inMinutes / maxInitialTimeInMinutes * 100;
    // Timer State is stored in this provider
    // listen for events of the timer
    eventStreamSubscription = timer.eventStream.listen((event) {
      switch (event) {
        // track learned minutes
        case TimerEvent.oneMinutePassed:
          context.read<StatsProvider>().incrementMinutesSpentStudying(1);
        case _:
          break;
      }
    });
    // observer needed for listening to changes of the app lifecycle in [didChangeAppLifecycleState]
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    // Pause the timer when leaving the page
    // don't notify the widget to rebuild since it will no longer be in the widget tree
    // do this in deactivate since here we still can access the [context], in dispose we can not
    context.read<TimerProvider>().pauseTimerNoNotify();
    super.deactivate();
  }

  @override
  void dispose() {
    eventStreamSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // pause the timer when app is minimized
    // prevents the timer from running when the app is not in focus
    // resumes the timer once the app is resumed
    switch (state) {
      //? paused and inactive occur when the app is minimized
      //? when app overview is opened, only inactive is called
      //? we only want to pause the timer and notify when the app is fully minimized
      case AppLifecycleState.paused:
        final timer = context.read<TimerProvider>();
        if (!timer.isPaused) {
          // Send notification when timer is running and app is minimized
          notificationServiceInstance.showNotification(
            title: 'Dein Lernziel ist in Gefahr!',
            body:
                'Lass dich nicht ablenken! Klicke hier um in die App zurückzukommen.',
          );
          timer.pauseTimer();
          timerWasPausedBeforeAppMinimized = false;
        } else {
          timerWasPausedBeforeAppMinimized = true;
        }
      case AppLifecycleState.resumed:
        if (!timerWasPausedBeforeAppMinimized) {
          context.read<TimerProvider>().startOrResumeTimer();
        }
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          timerSettingsButton(context),
          const Spacer(flex: 2),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    IgnorePointer(
                      child: Center(
                        child: SizedBox(
                          child: SvgPicture.asset(
                            'assets/images/readingMascot.svg',
                            width: constraints.maxWidth * .7,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: constraints.maxWidth * .8,
                        child: SfRadialGauge(
                          axes: [
                            RadialAxis(
                              startAngle: 270,
                              endAngle: 270,
                              showLabels: false,
                              showTicks: false,
                              axisLineStyle: AxisLineStyle(
                                color: Theme.of(context).colorScheme.surface,
                                thickness: 40,
                              ),
                              pointers: [
                                RangePointer(
                                  color: Theme.of(context).colorScheme.primary,
                                  value: !timer.isPaused
                                      ? remainingPercent
                                      : pointerValue,
                                  width: 40,
                                  animationDuration: 250,
                                  enableAnimation: true,
                                  // TODO(belaw): drag anywhere
                                ),
                                if (timer.isPaused)
                                  MarkerPointer(
                                    value: !timer.isPaused
                                        ? remainingPercent
                                        : pointerValue,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    markerHeight: 0,
                                    markerWidth: 0,
                                    markerType: MarkerType.circle,
                                    enableDragging: true,
                                    onValueChanged: (value) => setState(
                                      () {
                                        pointerValue = value;
                                        timer.setInitialTime(
                                          Duration(
                                            minutes: (maxInitialTimeInMinutes /
                                                    100 *
                                                    pointerValue)
                                                .round(),
                                          ),
                                        );
                                        timer.resetTimer();
                                      },
                                    ),
                                    animationDuration: 250,
                                    enableAnimation: true,
                                  ),
                              ],
                              annotations: [
                                GaugeAnnotation(
                                  widget: IgnorePointer(
                                    child: Text(
                                      timer.remainingTime.toMMSSString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                  angle: 270,
                                  positionFactor: 0.55,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                // disable button when timer running
                onPressed: timer.isPaused ? timer.startOrResumeTimer : null,
                child: const Text('Start'),
              ),
              TextButton(
                // disable button when timer paused
                onPressed: timer.isPaused ? null : timer.pauseTimer,
                child: const Text('Pause'),
              ),
              TextButton(
                // disable button when timer running to prevent loss of tracked time
                onPressed: timer.isPaused ? timer.resetTimer : null,
                child: const Text('Reset'),
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Align timerSettingsButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (context) {
              return const ChooseReminderTime();
            },
          );
        },
      ),
    );
  }
}

class ChooseReminderTime extends StatefulWidget {
  const ChooseReminderTime({super.key});

  @override
  State<ChooseReminderTime> createState() => _ChooseReminderTimeState();
}

class _ChooseReminderTimeState extends State<ChooseReminderTime> {
  DateTime scheduledNotificationTime =
      DateTime.now().add(const Duration(hours: 1));

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    return SimpleDialog(
      title: const Text('Einstellungen'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: const Text('Kurze Pause:'),
              onPressed: () async {
                final newShortBreakTime = await showDurationPicker(
                  context: context,
                  initialTime: const Duration(minutes: 30),
                  snapToMins: 5,
                );
                if (newShortBreakTime != null) {
                  timer.shortBreakTime = newShortBreakTime;
                }
              },
            ),
            Text(
              timer.shortBreakTime.toMMSSString(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: const Text('Lange Pause:'),
              onPressed: () async {
                final newLongBreakTime = await showDurationPicker(
                  context: context,
                  initialTime: const Duration(minutes: 10),
                  snapToMins: 5,
                );
                if (newLongBreakTime != null) {
                  timer.longBreakTime = newLongBreakTime;
                }
              },
            ),
            Text(
              timer.longBreakTime.toMMSSString(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        const SizedBox(height: 25), // Add space between the rows
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tägliche Erinnerung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                DatePicker.showTimePicker(
                  context,
                  locale: LocaleType.de,
                  showSecondsColumn: false,
                  currentTime: scheduledNotificationTime,
                ).then((result) {
                  if (result != null) {
                    setState(() {
                      scheduledNotificationTime = result;
                    });
                  }
                });
              },
              child: const Text(
                'Wähle Zeit',
              ),
            ),
            Text(
              DateFormat('kk:mm').format(scheduledNotificationTime),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Lernerinnerung setzen'),
        ),
        const SizedBox(height: 10),

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}
