
class User {

  late String userName;

  User(this.userName);

  String getUserName() {
    return userName;
  }

  @override
  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json["username"] = userName;
    return json;
  }

  User.fromJson(Map<String, dynamic> json) {
    userName = json["username"];
  }
}
