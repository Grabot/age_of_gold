import 'package:age_of_gold/locator.dart';
import 'package:age_of_gold/util/navigation_service.dart';
import 'package:flutter/material.dart';
import '../age_of_gold.dart';


class ProfilePage extends StatefulWidget {

  final AgeOfGold game;

  const ProfilePage({
    Key? key,
    required this.game
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final NavigationService _navigationService = locator<NavigationService>();

  bool showLogin = false;

  @override
  void initState() {
    print("profile page");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Profile Page"),
        ),
      ),
    );
  }
}
