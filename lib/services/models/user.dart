
class User {

  late int id;
  late String userName;

  User(this.id, this.userName);

  String getUserName() {
    return userName;
  }

  @override
  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json['id'] = id;
    json["username"] = userName;
    return json;
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json["username"];
  }

  @override
  String toString() {
    return 'User{id: $id, userName: $userName}';
  }
}
