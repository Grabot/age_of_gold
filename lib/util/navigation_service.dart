import 'package:age_of_gold/locator.dart';
import 'package:flutter/cupertino.dart';


class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToPush(String routeName, {dynamic arguments}) {
    // This allows the `back` button to work to go to previous page
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  void setupLocator() {
    locator.registerLazySingleton(() => NavigationService());
  }
}
