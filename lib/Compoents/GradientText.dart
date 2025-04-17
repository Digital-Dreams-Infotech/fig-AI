import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const GradientText(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.blue, Colors.purple],
      ).createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white), // Ensures gradient is visible
      ),
    );
  }
}