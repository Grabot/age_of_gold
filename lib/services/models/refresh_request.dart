
class RefreshRequest {
  late String accessToken;
  late String refreshToken;

  RefreshRequest(this.accessToken, this.refreshToken);

  setAccessToken(String accessToken) {
    this.accessToken = accessToken;
  }

  String getAccessToken() {
    return accessToken;
  }

  setRefreshToken(String refreshToken) {
    this.refreshToken = refreshToken;
  }

  String getRefreshToken() {
    return refreshToken;
  }

  @override
  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    json['access_token'] = accessToken;
    json['refresh_token'] = refreshToken;

    return json;
  }
}
