import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class CodeChallengeUtil {
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  /// Generates a random string of a random length
  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(
            _rnd.nextInt(_chars.length),
          ),
        ),
      );

  Map<String, String> generateParams() {
    // code is a random string of a random length
    String code = getRandomString(86);

    // convert the code to bytes
    List<int> bytes = utf8.encode(code);

    // code verifier is a Base 64 encoded String
    // * It is important to replace all '=' characters
    String codeVerifier = base64.encode(bytes).replaceAll("=", "");

    // hash the bytes
    Digest hash = sha256.convert(bytes);

    String codeChallenge = base64Url.encode(hash.bytes).replaceAll("=", "");

    // generate a code for state
    String stateCode = getRandomString(18);
    String state = (base64.encode(utf8.encode(stateCode)).replaceAll("=", ""));

    return {
      "codeChallenge": codeChallenge,
      "codeVerifier": codeVerifier,
      "state": state
    };
  }
}
