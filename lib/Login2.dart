import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Demo',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _user;

  Future<void> handleGoogleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account != null) {
        setState(() {
          _user = account;
        });
      }
    } catch (error) {
      print("Login error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _user == null
            ? ElevatedButton(
          onPressed: handleGoogleSignIn,
          child: Text("Login with Google"),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_user!.photoUrl ?? ''),
              radius: 40,
            ),
            SizedBox(height: 10),
            Text('Name: ${_user!.displayName}'),
            Text('Email: ${_user!.email}'),
          ],
        ),
      ),
    );
  }
}
