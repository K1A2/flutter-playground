import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

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
                      print('Google: ${googleAuthentication.accessToken}');
                      final response = await http.get(Uri.parse('http://192.168.0.7:8000/api/v1/oauth/verify/google'), headers: {
                        'Authorization': 'Bearer ${googleAuthentication.accessToken}'
                      });
                      print('Google: ${response.statusCode}');
                    }
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.yellowAccent
                  ),
                  child: const Text('Kakao'),
                  onPressed: () async {
                    OAuthToken? token;
                    if (await isKakaoTalkInstalled()) {
                      try {
                        token = await UserApi.instance.loginWithKakaoTalk();
                        print('카카오톡으로 로그인 성공');
                      } catch (error) {
                        print('카카오톡으로 로그인 실패 $error');

                        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
                        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
                        if (error is PlatformException && error.code == 'CANCELED') {
                          return;
                        }
                        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
                        try {
                          token = await UserApi.instance.loginWithKakaoAccount();
                          print('카카오계정으로 로그인 성공');
                        } catch (error) {
                          print('카카오계정으로 로그인 실패 $error');
                        }
                      }
                    } else {
                      try {
                        token = await UserApi.instance.loginWithKakaoAccount();
                        print('카카오계정으로 로그인 성공');
                      } catch (error) {
                        print('카카오계정으로 로그인 실패 $error');
                      }
                    }
                    if (token != null) {
                      print('Kakao: ${token.accessToken}');
                      final response = await http.get(Uri.parse('http://192.168.0.7:8000/api/v1/oauth/verify/kakao'), headers: {
                        'Authorization': 'Bearer ${token.accessToken}'
                      });
                      print('Kakao: ${response.statusCode}');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
