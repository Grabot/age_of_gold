
class RegisterRequest {
  late String email;
  late String userName;
  late String password;

  RegisterRequest(this.email, this.userName, this.password);

  setEmail(String email) {
    this.email = email;
  }

  String getEmail() {
    return email;
  }

  setUserName(String userName) {
    this.userName = userName;
  }

  String getUserName() {
    return userName;
  }

  setPassword(String password) {
    this.password = password;
  }

  String getPassword() {
    return password;
  }

  @override
  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    json['email'] = email;
    json['user_name'] = userName;
    json['password'] = password;

    return json;
  }
}
