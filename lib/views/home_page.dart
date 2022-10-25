import 'package:flutter/material.dart';

import 'app_bar.dart';


class HomePage extends StatefulWidget {

  static const String route = '/';

  const HomePage({Key? key}) : super(key: key);

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
          child: Text("Home Page")
        ),
      ),
    );
  }
}
