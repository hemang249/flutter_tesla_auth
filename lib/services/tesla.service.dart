import 'dart:convert';

import "../utils/code-challenge.dart";
import "package:http/http.dart" as http;

class TeslaService {
  String _clientId = "ownerapi";
  String _ownerapiClientId =
      "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384";
  String _codeChallenge;
  String _state;

  String _audience = "";
  String _codeChallengeMethod = "S256";
  String _locale = "en";
  String _prompt = "login";
  String _redirectUri = "https://auth.tesla.com/void/callback";
  String _responseType = "code";
  String _scope = "openid email offline_access";
  String _codeVerifier;

  String getTeslaAuthorizeUrl() {
    try {
      CodeChallengeUtil codeChallengeUtil = new CodeChallengeUtil();

      Map<String, String> params = codeChallengeUtil.generateParams();

      _codeChallenge = params["codeChallenge"];
      _state = params["state"];
      _codeVerifier = params["codeVerifier"];

      return 'https://auth.tesla.com/oauth2/v3/authorize?client_id=$_clientId&code_challenge=$_codeChallenge&code_challenge_method=$_codeChallengeMethod&redirect_uri=$_redirectUri&response_type=$_responseType&scope=$_scope&state=$_state';
    } catch (err) {
      print("Unable to generate the Tesla Authorize URL");
    }
  }

  dynamic getOauth2Token({String authCode}) async {
    try {
      Map<String, String> payload = {
        "grant_type": "authorization_code",
        "client_id": "ownerapi",
        "code_verifier": _codeVerifier,
        "code": authCode,
        "redirect_uri": _redirectUri,
      };

      var response = await http.post(
        Uri.parse("https://auth.tesla.com/oauth2/v3/token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      return jsonDecode(response.body);
    } catch (err) {
      print("Unable to exchange Auth Code for Oauth2 Token.");
    }
  }

  dynamic getOwnerApiAccessToken({String oauth2Token}) async {
    try {
      Map<String, String> payload = {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "client_id": _ownerapiClientId,
      };

      var tokenResponse = await http.post(
        Uri.parse("https://owner-api.teslamotors.com/oauth/token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $oauth2Token"
        },
        body: jsonEncode(payload),
      );

      return jsonDecode(tokenResponse.body);
    } catch (err) {
      print("Unable to obtain Owner API Access Token");
    }
  }
}
