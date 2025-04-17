import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const FeatureCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1125,
      margin:
      EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(imagePath,
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.height * 0.1,
              fit: BoxFit.contain),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Center(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}