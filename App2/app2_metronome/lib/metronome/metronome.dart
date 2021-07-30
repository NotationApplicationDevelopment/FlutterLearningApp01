library metronome;

import 'dart:async';
import 'metronome_stub.dart'
    if (dart.library.js) 'metronome_web.dart';
    //if (dart.library.io) 'metronome_io.dart';
    
abstract class Metronome {
  
  Stopwatch _sw = new Stopwatch();
  int _count = 0;
  late double _bpm;
  late int _beat;
  late int _note;
  late Duration _interval;
  Duration _realInterval = Duration.zero;

  factory Metronome(List<String> soundPaths, {double bpm = 120, int beat = 4, int note = 4}) => getMetronome(soundPaths, bpm, beat, note);

  Metronome.abstract(List<String> soundPaths, double bpm, int beat, int note) {
    loadSounds(soundPaths);
    _bpm = bpm;
    _beat = beat;
    _note = note;
    _intervalUpdate();
  }

  bool get isRunning => _sw.isRunning;
  int get count => _count + 1;
  double get bpm => _bpm;
  int get beat => _beat;
  int get note => _note;
  Duration get beatInterval => _interval;
  Duration get barInterval => _interval * _beat;
  Duration get realbeatInterval => _realInterval;
  Duration get timeOnBeat => _sw.elapsed;
  Duration get timeOnBar => _sw.elapsed + (_interval * _count);
  double get positionOnBeat =>
      (timeOnBeat.inMicroseconds / beatInterval.inMicroseconds).clamp(0, 1);
  double get positionOnBar =>
      (timeOnBar.inMicroseconds / barInterval.inMicroseconds).clamp(0, 1);

  set bpm(double value) {
    if (_bpm != value) {
      _bpm = value;
      _intervalUpdate();
    }
  }

  set beat(int value) {
    if (_beat != value) {
      _beat = value;
      _intervalUpdate();
    }
  }

  set note(int value) {
    if (_note != value) {
      _note = value;
      _intervalUpdate();
    }
  }

  void loadSounds(List<String> soundPaths);
  void playSound(int index);
  void dispose();
  
  FutureOr<void> startCounter();
  FutureOr<void> stopCounter();
  FutureOr<void> resetCounter();

  FutureOr<void> start() async {
    if(isRunning) return;
    _sw.start();
    await startCounter();
  }

  FutureOr<void> stop() async {
    if(!isRunning) return;
    _sw.stop();
    await stopCounter();
  }

  FutureOr<void> reset() async {
    stop();
    _sw.reset();
    _count = 0;
    await resetCounter();
  }

  void countUp() {
    playSound(0);
    _count = (_count < _beat) ? (_count + 1) : 0;
    _realInterval = _sw.elapsed;
    _sw.reset();
  }

  void _intervalUpdate() async {
    _interval = Duration(seconds: 1) * (240.0 / (_bpm * _note));
    reset();
  }

  @override
  String toString() {
    return "Metronome($bpm, $beat/$note) $count";
  }
}