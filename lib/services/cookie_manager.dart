import 'package:dio/dio.dart';

class CookieManager extends Interceptor {
  static final CookieManager _instance = CookieManager._internal();

  static CookieManager get instance => _instance;

  CookieManager._internal();

  String? cookie;

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    if (response.statusCode == 200) {
      if (response.headers.map['set-cookie'] != null) {
        _saveCookie(response.headers.map['set-cookie']![0]);
      } else if (response.statusCode == 401) {
        _clearCookie();
      }
      super.onResponse(response, handler);
    }
  }

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler
    ) {
    print("current cookie $cookie");
    options.headers["Cookie"] = cookie;
    return super.onRequest(options, handler);
  }

  Future<void> initCookie() async {
    // TODO:
    // set to prefs? For android/ios only?
    // SharedPreferences porefs = await SharedPrefernces.getInstance();
    // _cookie = prefs.getString("cookie");
  }

  void _saveCookie(String newCookie) async {
    if (cookie != newCookie) {
      cookie = newCookie;
      // TODO:
      // set to prefs? For android/ios only?
    }
  }

  void _clearCookie() async {
    cookie = null;
    // TODO:
    // remove from prefs? For android/ios only?
  }
}