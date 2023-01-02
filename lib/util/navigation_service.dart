import 'package:age_of_gold/locator.dart';
import 'package:flutter/cupertino.dart';


class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  void setupLocator() {
    locator.registerLazySingleton(() => NavigationService());
  }
}
