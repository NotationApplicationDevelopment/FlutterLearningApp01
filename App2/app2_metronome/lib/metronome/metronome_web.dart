import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'metronome.dart';

getMetronome(List<String> soundPaths, double bpm, int beat, int note) =>
    MetronomeWeb._init(soundPaths, bpm, beat, note);

class MetronomeWeb extends Metronome {
  html.Worker? counter;
  List<AudioPlayer> _players = [];

  MetronomeWeb._init(List<String> soundPaths, double bpm, int beat, int note)
      : super.abstract(soundPaths, bpm, beat, note) {
    print("Web Metronome");
  }

  @override
  void loadSounds(List<String> soundPaths) async {
    _counterInit(soundPaths);
    
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    
    _clearPlayers();
    for (var path in soundPaths) {
      var player = new AudioPlayer();
      player.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      });

      try {
        await player.setAsset(kDebugMode ? path : "assets/$path");
        _players.add(player);
      } catch (e) {
        print("Error loading audio source: $e");
      }
    }
  }

  void _counterInit(List<String> soundPaths) {
    if (counter == null) {
      const String source =
          "importScripts(location.origin + '/metronome.js');// entryPoint();";
      final code = html.Blob([source], 'text/javascript');
      String codeUrl = html.Url.createObjectUrlFromBlob(code);

      counter = new html.Worker(codeUrl);
      if (counter != null) {
        counter!.onError.listen((event) {
          print("on error!!");
        });

        counter!.onMessage.listen((event) async {
          countUp();
        });
      }
    }
  }

  @override
  void playSound(int index) {
    print("playSound");
    _players[index].pause();
    _players[index].seek(Duration.zero);
    _players[index].play();
  }

  @override
  FutureOr<void> resetCounter() {
    counter?.postMessage(_CounterMassage.reset(beatInterval));
  }

  @override
  FutureOr<void> startCounter() {
    counter?.postMessage(_CounterMassage.start(beatInterval));
  }

  @override
  FutureOr<void> stopCounter() {
    counter?.postMessage(_CounterMassage.stop(beatInterval));
  }

  _clearPlayers() {
    for (var player in _players) {
      player.dispose();
    }
    _players.clear();
  }
  
  @override
  void dispose() {
    _clearPlayers();
    counter?.terminate();
  }
}

class _CounterMassage{
  late String command;
  late int intervalMicroseconds;
  
  _CounterMassage.start(Duration interval){
    command = "start";
    intervalMicroseconds = interval.inMicroseconds;
  }
  
  _CounterMassage.stop(Duration interval){
    command = "stop";
    intervalMicroseconds = interval.inMicroseconds;
  }
  
  _CounterMassage.reset(Duration interval){
    command = "reset";
    intervalMicroseconds = interval.inMicroseconds;
  }
}