import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class test extends StatefulWidget {
  const test({super.key});

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width:50,
      child: Lottie.asset('assets/images/weatherRain.json', fit: BoxFit.fill),
    );
  }
}