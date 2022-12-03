import 'package:shared_preferences/shared_preferences.dart';


class WebStorage {
  static String accessTokenKey = "accessToken";

  static Future<bool> setAccessToken(String accessToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(accessTokenKey, accessToken);
  }

  static Future<String?> getAccessToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(accessTokenKey);
  }

}
