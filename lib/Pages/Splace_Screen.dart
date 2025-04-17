import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Log In.dart';

class Splace_screen extends StatefulWidget {
  Splace_screen({super.key});

  @override
  State<Splace_screen> createState() => _Splace_screenState();
}

class _Splace_screenState extends State<Splace_screen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Log_In()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1B0B25),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Image(
                image: AssetImage('assets/image/Logo.png'),
                height: 114.06,
                width: 112.33,
              ),
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFFF2E9D8),
                    Color(0xFFD0A197),
                    Color(0xFFC2797A),
                  ],
                  stops: [0.75, 0.85, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                'Fig AI',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 35,
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Fig AI Content and Prompt Generator ',
              style: GoogleFonts.inter(
                color: Color(0xffCFBABA),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}