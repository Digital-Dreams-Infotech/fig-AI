import 'package:fig_ai/Pages/onboarding4.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class onboarding3 extends StatefulWidget {
  const onboarding3({super.key});

  @override
  State<onboarding3> createState() => _onboarding3State();
}

class _onboarding3State extends State<onboarding3> {
  final List<String> items = [
    'Speed responses',
    'As an agency',
    'Balanced for both'
  ];

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    final mediaWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff1B0B25),
      appBar: AppBar(
        backgroundColor: const Color(0xff1B0B25),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaWidth * 0.3),
            child: LinearProgressIndicator(
              value: 3 / 4,
              backgroundColor: Colors.grey[300],
              color: const Color(0xffCF9F95),
            ),
          ),
          SizedBox(height: mediaHeight * 0.05),
          Text(
            'Which do you value more?',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xffFFFFFF),
              fontSize: mediaWidth * 0.085,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mediaHeight * 0.05),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaWidth * 0.075),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: mediaWidth * 0.025,
              mainAxisSpacing: mediaHeight * 0.015,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: items
                  .sublist(0, 2)
                  .map((text) => _buildCard(text, mediaWidth, mediaHeight))
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: mediaHeight * 0.01),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: mediaWidth * 0.45,
                child: _buildCard(items[2], mediaWidth, mediaHeight),
              ),
            ),
          ),
          SizedBox(height: mediaHeight * 0.25),
          SizedBox(
            height: mediaWidth * 0.15,
            width: mediaWidth * 0.15,
            child: ElevatedButton(
              onPressed: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (_) => const onboarding4()),
                // );
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        onboarding4(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 0),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(mediaWidth * 0.02),
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
                  borderRadius: BorderRadius.circular(mediaWidth * 0.02),
                ),
                child: Padding(
                  padding: EdgeInsets.all(mediaWidth * 0.025),
                  child: const Image(
                    image: AssetImage('assets/image/Vector 17.png'),
                    color: Colors.white,
                    height: 8,
                    width: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, double mediaWidth, double mediaHeight) {
    return Card(
      color: const Color(0xff37353F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(mediaWidth * 0.03),
      ),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(mediaWidth * 0.04),
        height: mediaHeight * 0.12,
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.urbanist(
            color: const Color(0xffF9FBFC),
            fontSize: mediaWidth * 0.045,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
