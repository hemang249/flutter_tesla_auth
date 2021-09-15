import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:tesla_auth_by_keemut/screens/home_screen.dart';
import 'package:tesla_auth_by_keemut/services/tesla.service.dart';
import "package:url_launcher/url_launcher.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Authy",
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFFE94560),
        buttonColor: Color(0xFF1a1a2e),
        backgroundColor: Color(0xFF1a1a2e),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE94560),
          ),
        ),
      ),
      home: SafeArea(
          child: MyHomePage(
        key: Key("home_screen"),
      )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _webViewKey = GlobalKey();

  InAppWebViewController _iosWebViewController;
  InAppWebViewGroupOptions _iosWebViewOptions = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );
  String _url;
  TeslaService _teslaService = new TeslaService();

  bool _showWebView = true;

  // This function exchanges the auth code received in the Oauth callback url to get a access token
  // That access token can be used with the tesla owenr api to get the actual token for the owner api
  Future<void> _exchangeAuthCode(String authCode) async {
    try {
      var data = await _teslaService.getOauth2Token(authCode: authCode);

      var tokenData = await _teslaService.getOwnerApiAccessToken(
        oauth2Token: data['access_token'],
      );

      // TODO: Save the tokens in the Key chain for ios or AES for android
      // the tesla api access token, this can be used with the owner api or fleet api to get vehicle data
      String accessToken = tokenData['access_token'];
      // The refresh token that can be used within 45 days to refresh the access token. More info at https://tesla-api.timdorr.com/api-basics/authentication
      String refreshToken = tokenData['refresh_token'];

      print('access token is : $accessToken');
      print('refresh token is : $refreshToken');
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auth"),
      ),
      body: Center(
          child: _showWebView
              ? InAppWebView(
                  key: _webViewKey,
                  // contextMenu: contextMenu,
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(_teslaService.getTeslaAuthorizeUrl()),
                  ),
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialOptions: _iosWebViewOptions,
                  onWebViewCreated: (controller) {
                    _iosWebViewController = controller;
                  },
                  onLoadStart: (controller, uri) {
                    setState(() {
                      _url = uri.toString();
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT,
                    );
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url;

                    if (uri.toString().contains(
                        "https://auth.tesla.com/void/callback?code")) {
                      Map queryParams =
                          Uri.parse(uri.toString()).queryParameters;

                      await _exchangeAuthCode(queryParams['code']);

                      return NavigationActionPolicy.CANCEL;
                    }

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunch(_url)) {
                        // Launch the App
                        await launch(
                          _url,
                        );

                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                )
              : Container(
                  child: Text("Tokens have been generated!!"),
                )),
    );
  }
}
