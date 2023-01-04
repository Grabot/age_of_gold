import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';


class UserProfile extends StatefulWidget {

  final AgeOfGold game;

  const UserProfile({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget userProfileWidget() {
    double userProfileWidth = 350;
    if (MediaQuery.of(context).size.width <= 800) {
      // Here we assume that it is a phone and we set the width to the total
      userProfileWidth = MediaQuery.of(context).size.width;
    }
    return Align(
        alignment: FractionalOffset.topLeft,
        child: Container(
        width: userProfileWidth,
        height: 300,
        color: Colors.green,
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return userProfileWidget();
  }
}
