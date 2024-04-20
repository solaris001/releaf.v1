import 'dart:async';

import 'package:flutter/material.dart';

/// This provider keeps track of the state of the timer itself
///
/// We are using a provider for this so that the state is persisted
/// when the timer page is not open
///
/// start the timer using [startOrResumeTimer]
///
/// pause the timer using [pauseTimer]
///
/// reset the timer to its initialTime with [resetTimer]
///
/// access it's running state from [isPaused]
///
/// update the [initialTime] with [setInitialTime]
///
/// the time left can be accessed through [remainingTime]
///
/// listen for events like [TimerEvent.oneMinutePassed] by listening to [eventStream]
class TimerProvider with ChangeNotifier {
  TimerProvider() {
    _remainingTime = _initialTime;

    _streamController = StreamController.broadcast();
  }
  Duration _initialTime = const Duration(minutes: 60);
  late Duration _remainingTime;
  bool _isPaused = true;

  /// Custom learning times
  Duration _shortBreakTime = const Duration(minutes: 5);
  Duration _longBreakTime = const Duration(minutes: 15);

  Duration get shortBreakTime => _shortBreakTime;
  Duration get longBreakTime => _longBreakTime;

  set shortBreakTime(Duration value) {
    _shortBreakTime = value;
    notifyListeners();
  }

  set longBreakTime(Duration value) {
    _longBreakTime = value;
    notifyListeners();
  }

  late StreamController<TimerEvent> _streamController;

  /// listen to this stream to receive [TimerEvent]
  ///
  /// for example when keeping track of the learned time listen for [TimerEvent.oneMinutePassed]
  Stream<TimerEvent> get eventStream => _streamController.stream;

  /// The time the timer will start with and will be reset to when calling [resetTimer]
  Duration get initialTime => _initialTime;

  /// The time left on the timer
  ///
  /// Will be automatically updated once a second after the timer has started
  Duration get remainingTime => _remainingTime;

  /// whether the timer is currently paused or not
  bool get isPaused => _isPaused;

  Timer? _timer;

  void startOrResumeTimer() {
    if (_timer != null && _timer!.isActive) _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _decrementTimer();
    });
    _isPaused = false;
    _streamController.add(TimerEvent.startOrResume);
    notifyListeners();
  }

  void _decrementTimer() {
    _remainingTime -= const Duration(seconds: 1);

    if (_remainingTime.isNegative) {
      pauseTimer();
      _remainingTime = Duration.zero;
    }

    // broadcast that one minute has passed
    if (_initialTime != _remainingTime &&
        (_initialTime - _remainingTime).inSeconds % 60 == 0) {
      _streamController.add(TimerEvent.oneMinutePassed);
    }

    notifyListeners();
  }

  /// will halt the timer and not reset the remaining time
  void pauseTimer() {
    pauseTimerNoNotify();
    notifyListeners();
  }

  /// will halt the timer and not reset the remaining time but doesn't notify
  /// listeners of the changeNotifierProvider
  ///
  /// used when pausing the timer from a deactivating widget that shouldn't rebuild afterwards
  void pauseTimerNoNotify() {
    _timer?.cancel();
    _isPaused = true;
    _streamController.add(TimerEvent.pause);
  }

  /// will halt the timer and reset the remaining time to the initial time
  void resetTimer() {
    pauseTimer();
    _remainingTime = _initialTime;
    _streamController.add(TimerEvent.reset);
    notifyListeners();
  }

  /// update the initialTime to a new value
  void setInitialTime(Duration initialTime) {
    _initialTime = initialTime;
    notifyListeners();
  }

  void startBreak() {
    _remainingTime = _shortBreakTime;
    startOrResumeTimer();
  }
}

/// used with the [eventStream] of the [TimerProvider] while listening to its events
enum TimerEvent {
  startOrResume,
  pause,
  reset,
  oneMinutePassed,
}
