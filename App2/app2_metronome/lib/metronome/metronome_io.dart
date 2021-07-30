import 'dart:async';
import 'metronome.dart';

getMetronome(List<String> soundPaths, double bpm, int beat, int note) =>
    MetronomeIo(soundPaths, bpm, beat, note);

class MetronomeIo extends Metronome {
  MetronomeIo(List<String> soundPaths, double bpm, int beat, int note)
      : super.abstract(soundPaths, bpm, beat, note){
      print("Io Metronome");
  }

  @override
  void loadSounds(List<String> soundPaths) {
    // TODO: implement loadSounds
  }

  @override
  void playSound(int index) {
    // TODO: implement playSound
  }

  @override
  FutureOr<void> resetCounter() {
    // TODO: implement resetCounter
  }

  @override
  FutureOr<void> startCounter() {
    // TODO: implement startCounter
  }

  @override
  FutureOr<void> stopCounter() {
    // TODO: implement stopCounter
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
