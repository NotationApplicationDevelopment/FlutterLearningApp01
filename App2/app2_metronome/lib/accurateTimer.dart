import "dart:isolate";

class _TimerState {
  bool _canseled = false;
  Stopwatch _sw = Stopwatch();
  late Duration _nextTick;
  int _count = 0;
  int loopCount = 16;
  _TimerState.periodic(AccurateTimer accurateTimer, Duration delay,
      Duration duration, void Function(AccurateTimer) callback) {
    var hwt = accurateTimer.heavyWaitingTime;
    var ct = accurateTimer.clockTick;

    Future<void> callbacker() async {
      if (!_canseled) {
        callback(accurateTimer);
        _count++;
        if(_count == loopCount - 1){
          _count = 0;
          _nextTick = Duration.zero;
          _sw.reset();
          _sw.start();
        }else{
          _count++;
        }
      }
    }

    Future<void> timerTicks() async {
      _nextTick = duration + delay;
      callback(accurateTimer);
      _sw.start();
      while (!_canseled) {
        await Future.delayed(duration - hwt);
        while (!_canseled && (_sw.elapsed - _nextTick).isNegative) {
          await Future.delayed(ct);
        }
        callbacker();
        _nextTick += duration;
      }
      _sw.stop();
    }

    timerTicks();
  }

  int get count => _count;
  

  Duration cancel() {
    _canseled = true;
    return _nextTick - _sw.elapsed;
  }
}

class AccurateTimer {
  late _TimerState _state;
  Duration _nextDelay = Duration.zero;
  bool _isRunning = false;
  Duration _heavyWaitingTime = Duration(milliseconds: 30);
  Duration _clockTick = Duration(microseconds: 500);
  void Function(AccurateTimer) _callback;
  Duration _duration;

  AccurateTimer.periodic(this._duration, this._callback);

  bool get isRunning => _isRunning;
  Duration get heavyWaitingTime => _heavyWaitingTime;
  Duration get clockTick => _clockTick;
  Duration get duration => _duration;
  int get count => _state.count;

  set heavyWaitingTime(Duration value) {
    _heavyWaitingTime = value.abs();
  }

  set clockTick(Duration value) {
    _clockTick = value.abs();
  }

  set duration(Duration value) {
    if (value.compareTo(_duration) == 0) return;
    _duration = value;
    if (_isRunning) {
      pause();
      start();
    }
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _state = _TimerState.periodic(this, _nextDelay, _duration, _callback);
  }

  void pause() {
    if (!_isRunning) return;
    _nextDelay = _state.cancel();
    _isRunning = false;
  }

  void reset() {
    if (_isRunning) {
      _state.cancel();
      _isRunning = false;
    }
    _nextDelay = Duration.zero;
  }
}
