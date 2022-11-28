

class Settings {
  static final Settings _instance = Settings._internal();

  String accessToken = "";
  String refreshToken = "";

  Settings._internal();

  factory Settings() {
    return _instance;
  }

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
}
