import 'package:age_of_gold/services/models/user.dart';

class Friend {

  late bool accepted;
  late User friend;

  Friend(this.accepted);

  Friend.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("friend")) {
      friend = User.fromJson(json['friend']);
    }
    if (json.containsKey("accepted")) {
      accepted = json["accepted"];
    }
  }

  @override
  String toString() {
    return 'Friend{accepted: $accepted, friend: $friend}';
  }
}
