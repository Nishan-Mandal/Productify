import 'package:flutter/material.dart';
import 'dart:async';

class LiveClock extends StatefulWidget {
  final Color textColor;
  LiveClock({required this.textColor});

  @override
  _LiveClockState createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = _formatTime(now);
    setState(() {
      _currentTime = formattedTime;
    });
  }

  String _formatTime(DateTime time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String period = hour >= 12 ? 'pm' : 'am';
    final int adjustedHour = hour % 12 == 0 ? 12 : hour % 12;
    final String formattedHour = adjustedHour.toString();
    final String formattedMinute = minute < 10 ? '0$minute' : minute.toString();
    return '$formattedHour:$formattedMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: widget.textColor),
    );
  }
}
