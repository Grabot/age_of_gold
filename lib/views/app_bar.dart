

import 'package:flutter/material.dart';

AppBar appBarAgeOfGold() {
  return AppBar(
    toolbarHeight: 80,
    title: const Text('Age of gold'),
    elevation: 0,
    backgroundColor: Colors.orange,
    flexibleSpace: Container(
      color: Colors.orange,
    ),
    actions: <Widget>[
      Container(
          width: 100,
          child: Column(
            children: [
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.account_circle_rounded),
                onPressed: () {
                  print("pressed this");
                },
              ),
              const Text("not logged in")
            ],
          )
      ),
    ],
  );
}

