import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../services/auth_service_login.dart';
import '../loading_box/loading_box_change_notifier.dart';
import '../login_view/login_window_change_notifier.dart';
import 'web_view_box_change_notifier.dart';

class WebViewBox extends StatefulWidget {

  final AgeOfGold game;

  const WebViewBox({
    required Key key,
    required this.game
  }) : super(key: key);

  @override
  WebViewBoxState createState() => WebViewBoxState();
}

class WebViewBoxState extends State<WebViewBox> {

  bool showWebViewWindow = false;
  bool pageLoaded = false;

  late WebViewController webViewController;
  late WebViewBoxChangeNotifier webViewBoxChangeNotifier;

  @override
  void initState() {
    webViewBoxChangeNotifier = WebViewBoxChangeNotifier();
    webViewBoxChangeNotifier.addListener(webViewBoxChangeListener);
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
          },
          onPageStarted: (String url) {
          },
          onPageFinished: (String url) {
            LoadingBoxChangeNotifier().setLoadingBoxVisible(false);
          },
          onHttpError: (HttpResponseError error) {
          },
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://ageof.gold/worldaccess?') || request.url.startsWith('https://www.ageof.gold/worldaccess?')) {
              LoadingBoxChangeNotifier loadingBoxChangeNotifier = LoadingBoxChangeNotifier();
              loadingBoxChangeNotifier.setWithBlackout(false);
              loadingBoxChangeNotifier.setLoadingBoxVisible(true);
              // When we detect the redirect to the worldaccess page
              // We use the worldaccess paramters to log in.
              // and then close the webview.
              webViewController.loadRequest(Uri.parse('about:blank'));
              Uri worldAccessUri = Uri.parse(request.url);
              String? accessToken = worldAccessUri.queryParameters["access_token"];
              String? refreshToken = worldAccessUri.queryParameters["refresh_token"];
              // Use the tokens to immediately refresh the access token
              if (accessToken != null && refreshToken != null) {
                AuthServiceLogin authService = AuthServiceLogin();
                authService.getRefresh(accessToken, refreshToken).then((loginResponse) {
                  if (loginResponse.getResult()) {
                    setState(() {
                      LoginWindowChangeNotifier().setLoginWindowVisible(false);
                      WebViewBoxChangeNotifier().setWebViewBoxVisible(false);
                    });
                  } else {
                    showToast("Failed to log in.");
                  }
                });
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    super.initState();
  }

  webViewBoxChangeListener() {
    if (mounted) {
      if (!showWebViewWindow && webViewBoxChangeNotifier.getWebViewBoxVisible()) {
        setState(() {
          webViewController.loadRequest(webViewBoxChangeNotifier.getWebViewBoxUrl());
          showWebViewWindow = true;
        });
      }
      if (showWebViewWindow && !webViewBoxChangeNotifier.getWebViewBoxVisible()) {
        setState(() {
          showWebViewWindow = false;
        });
      }
    }
  }

  goBack() {
    webViewController.loadRequest(Uri.parse('about:blank'));
    setState(() {
      WebViewBoxChangeNotifier().setWebViewBoxVisible(false);
    });
  }

  Widget webViewBoxHeader(double headerHeight) {
    return Container(
      color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Login oauth"),
            IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    goBack();
                  });
                }
            ),
          ]
      ),
    );
  }

  Widget webViewContainer(double webViewWidth, double webViewHeight, double loginBoxSize) {
    return SizedBox(
      child: Column(
        children: [
          webViewBoxHeader(20),
          Expanded(
            child: WebViewWidget(controller: webViewController),
          ),
        ],
      ),
    );
  }

  Widget webViewBox() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double webViewBoxSize = 100;
    double webViewWidth = 800;
    double webViewHeight = (screenHeight / 10) * 6;
    // When the width is smaller than this we assume it's mobile.
    if (screenWidth <= 800 || screenHeight - 200 > screenWidth) {
      webViewWidth = screenWidth - 50;
      webViewBoxSize = 50;
      webViewHeight = (screenHeight / 10) * 7;
    }

    return Align(
      alignment: FractionalOffset.center,
      child: SizedBox(
          width: webViewWidth,
          height: webViewHeight,
          child: webViewContainer(webViewWidth, webViewHeight, webViewBoxSize),
      ),
    );
  }

  Widget webViewScreen(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withValues(alpha: 0), // No black transparent background because this is already present via the loginscreen.
        child: Center(
            child: TapRegion(
                onTapOutside: (tap) {
                  goBack();
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(),
                      webViewBox(),
                    ]
                )
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: FractionalOffset.center,
        child: showWebViewWindow ? webViewScreen(context) : Container()
    );
  }
}