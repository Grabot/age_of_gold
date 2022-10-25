import 'package:flutter/material.dart';

import 'app_bar.dart';


class PageTwo extends StatefulWidget {

  static const String route = '/two';

  const PageTwo({Key? key}) : super(key: key);

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarAgeOfGold(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Page Two',
            ),
          ],
        ),
      ),
    );
  }
}