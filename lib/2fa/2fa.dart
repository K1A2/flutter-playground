import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue
                  ),
                  child: const Text('Google'),
                  onPressed: () async {
                    final GoogleSignIn googleSign = GoogleSignIn();
                    GoogleSignInAccount? googleAccount = await googleSign.signIn();
                    if (googleAccount != null) {
                      GoogleSignInAuthentication googleAuthentication = await googleAccount!.authentication;
                      print(googleAuthentication.accessToken);
                      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/v1/oauth/verify/google'), headers: {
                        'Authorization': 'Bearer ${googleAuthentication.accessToken}'
                      });
                      print(response.statusCode);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
