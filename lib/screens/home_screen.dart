import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "AUTHY",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              Text(
                "Tesla Authenticator",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "Generate your Tesla Access Token",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "The tokens generated are stored within the App in an encrypted storage using AES for Android and Keychain for iOS.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("Login With Tesla"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
