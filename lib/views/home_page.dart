import 'package:flutter/material.dart';

import '../age_of_gold.dart';
import '../user_interface/login_screen.dart';
import 'app_bar.dart';


class HomePage extends StatefulWidget {

  static const String route = '/';
  final AgeOfGold game;

  const HomePage({
    Key? key,
    required this.game
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarAgeOfGold(),
      body: Center(
        child: Container(
          child: LoginScreen(key: UniqueKey(), game: widget.game)
        ),
      ),
    );
  }
}
