import 'package:flutter/material.dart';
import '../age_of_gold.dart';
import 'login_screen.dart';


class HomePage extends StatefulWidget {

  final AgeOfGold game;
  final LoginScreen loginScreen;

  const HomePage({
    Key? key,
    required this.game,
    required this.loginScreen
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBarAgeOfGold(),
      body: Center(
        child: Container(
          child: widget.loginScreen
        ),
      ),
    );
  }
}
