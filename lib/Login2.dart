import 'dart:convert';

import 'package:fig_ai/API/API.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding1.dart';

class Log_In extends StatefulWidget {
  const Log_In({Key? key}) : super(key: key);

  @override
  State<Log_In> createState() => _Log_InState();
}

class _Log_InState extends State<Log_In> {
  final googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
    clientId:
    "302333078639-drakidbm8k3ig6282j3b23hln1em3be1.apps.googleusercontent.com",
  );

  GoogleSignInAccount? _user;
  final authservice = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const onboarding1()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      final account = await googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        final idToken = auth.idToken;

        if (idToken == null) {
          showError("Google Sign-In failed. No ID token.");
          return;
        }

        final res = await authservice.loginWithGoogle(idToken);
        final responseData = jsonDecode(res.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', responseData["tokens"]["access"]);
        await prefs.setString('userId', responseData["id"].toString());
        await prefs.setString('user_name', account.displayName ?? "");
        await prefs.setString('user_photo', account.photoUrl ?? "");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const onboarding1()),
        );
      }
    } catch (e) {
      print("Login error: $e");
      showError("Login failed. Please try again.");
    }
  }

  // Future<void> handleAppleSignIn() async {
  //   try {
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );
  //
  //     final idToken = credential.identityToken;
  //
  //     if (idToken == null) {
  //       showError("Apple Sign-In failed. No ID token.");
  //       return;
  //     }
  //
  //     final res = await authservice.loginWithApple(idToken);
  //     final responseData = jsonDecode(res.body);
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('access_token', responseData["tokens"]["access"]);
  //     await prefs.setString('userId', responseData["id"].toString());
  //     await prefs.setString(
  //         'user_name',
  //         "${credential.givenName ?? ''} ${credential.familyName ?? ''}"
  //             .trim());
  //     await prefs.setString('user_photo', ""); // Apple doesn't provide photo
  //
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const DashboardScreen()),
  //     );
  //   } catch (e) {
  //     print("Apple login error: $e");
  //     showError("Login failed. Please try again.");
  //   }
  // }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1B0B25),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/image/Logo.png'),
                  height: 114,
                  width: 112,
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFF2E9D8),
                      Color(0xFFD0A197),
                      Color(0xFFC2797A),
                    ],
                    stops: [0.75, 0.85, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Fig AI',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Ready to assist you with anything you need,\nfrom answering questions to providing recommendations.',
                  style: GoogleFonts.inter(
                    color: const Color(0xffCFBABA),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Let’s get started with',
                  style: GoogleFonts.inter(
                    color: const Color(0xffF9FBFC),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 56,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF2E9D8),
                            Color(0xFFD0A197),
                            Color(0xFFC2797A),
                          ],
                          stops: [0.1, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              image:
                              AssetImage('assets/image/Vector.png'),
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Login with Google',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 56,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF2E9D8),
                            Color(0xFFD0A197),
                            Color(0xFFC2797A),
                          ],
                          stops: [0.1, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage('assets/image/apple.png'),
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Login with Apple',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 720,
            left: 85,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'www.figpromptfinder.com',
                style: GoogleFonts.inter(
                  color: const Color(0xFFF9FBF2CF),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          Positioned(
            top: 760,
            left: 101,
            child: Text(
              'Privacy Policy    •    Terms & Condition',
              style: GoogleFonts.inter(
                color: const Color(0xFFCFBABA),
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}