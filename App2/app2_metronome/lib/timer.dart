import 'package:flutter/material.dart';
import 'accurateTimer.dart';

class Clock extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ClockState();
  }
}

class _ClockState extends State<Clock> {
  int _time = 0;
  Stopwatch _sw = Stopwatch();
  int _micTime = 0; 
  @override
  void initState() {
    var tim = AccurateTimer.periodic(
      Duration(milliseconds: 150),
      _onTimer
    );
    tim.start();
    super.initState();
  }

  void _onTimer(AccurateTimer timer) {
    var t = _sw.elapsedMicroseconds;
    _sw.reset();
    _sw.start();
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