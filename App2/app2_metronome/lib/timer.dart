import 'package:flutter/material.dart';
import 'accurateTimer.dart';
import 'package:audioplayers/audioplayers.dart';

class Clock extends StatefulWidget {
  static bool isPlay = false;
  @override
  State<StatefulWidget> createState() {
    return _ClockState();
  }
}

class _ClockState extends State<Clock> {
  int _time = 0;
  Stopwatch _sw = Stopwatch();
  int _micTime = 0; 
  late AudioCache audioCache;
  late AudioCache audioCache2;
  @override
  void initState() {
    audioCache = new AudioCache(fixedPlayer: new AudioPlayer());
    audioCache2 = new AudioCache(fixedPlayer: new AudioPlayer());
    audioCache.load('sounds/se2a.wav');
    audioCache2.load('sounds/se2b.wav');
    var tim = AccurateTimer.periodic(
      Duration(milliseconds: 125),
      _onTimer
    );
    tim.start();
    super.initState();
  }

  void playSound(){
    Clock.isPlay = true;
  }

  void _onTimer(AccurateTimer timer) {
    var t = _sw.elapsedMilliseconds;
    _sw.reset();
    _sw.start();
    if(Clock.isPlay){
      if(timer.count % 4 == 0){
        Future(() async => {
          await audioCache.fixedPlayer?.stop(),
          //await audioCache.fixedPlayer?.seek(Duration.zero),
          await audioCache.play('sounds/se2a.wav')
        });
      }else{
        Future(() async => {
          await audioCache2.fixedPlayer?.stop(),
          //await audioCache2.fixedPlayer?.seek(Duration.zero),
          await audioCache2.play('sounds/se2b.wav')
        });
      }
    }
    setState(() {
      _time++;
      _micTime = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "$_micTime : $_time",
      style: TextStyle(
        fontSize: 60.0,
        fontFamily: 'IBMPlexMono',
      ),
    );
  }
}