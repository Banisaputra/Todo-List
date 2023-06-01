import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'home.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'To Do List',
    home: SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TodoListScreen()));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 20),
              Lottie.asset('assets/water-splash.json'),
              const Text('powered by BNS Corporation', style: TextStyle(
                fontSize: 14, color: Colors.grey
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
