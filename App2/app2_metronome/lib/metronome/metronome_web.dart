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

  @override
  void playSound(int index) async {
    print("playSound");
    var player = _players[index];
    await player.pause();
    await player.seek(null);
    player.play();
  }

  @override
  FutureOr<void> resetCounter() {
    var mes = CounterMassage.reset(beatInterval).asMap;
    counter?.postMessage(mes);
  }

  @override
  FutureOr<void> startCounter() {
    var mes = CounterMassage.start(beatInterval).asMap;
    counter?.postMessage(mes);
  }

  @override
  FutureOr<void> stopCounter() {
    var mes = CounterMassage.stop(beatInterval).asMap;
    counter?.postMessage(mes);
  }
  
  @override
  void dispose() {
    _clearPlayers();
    counter?.terminate();
  }
  

  _clearPlayers() {
    for (var player in _players) {
      player.dispose();
    }
    _players.clear();
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
          print("${event.data as String}");
          countUp();
        });
      }
    }
  }
}

class CounterMassage{
  late final String _command;
  late final int _intervalMicroseconds;
  
  String get command => _command;
  int get intervalMicroseconds => _intervalMicroseconds;
  Map<String, String> get asMap => {"command":_command, "intervalMicroseconds": _intervalMicroseconds.toString()};
  CounterMassage.start(Duration interval){
    _command = "start";
    _intervalMicroseconds = interval.inMicroseconds;
  }
  
  CounterMassage.stop(Duration interval){
    _command = "stop";
    _intervalMicroseconds = interval.inMicroseconds;
  }
  
  CounterMassage.reset(Duration interval){
    _command = "reset";
    _intervalMicroseconds = interval.inMicroseconds;
  }
}