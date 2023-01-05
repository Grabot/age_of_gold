import 'package:age_of_gold/util/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:age_of_gold/constants/route_paths.dart' as routes;


AppBar appBarAgeOfGold(NavigationService _navigationService) {
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
                  _navigationService.navigateTo(routes.ProfileRoute);
                },
              ),
              const Text("not logged in")
            ],
          )
      ),
    ],
  );
}

