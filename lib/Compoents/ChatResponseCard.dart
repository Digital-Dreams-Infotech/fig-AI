import 'package:flutter/material.dart';

class ChatResponseCard extends StatelessWidget {
  final String explanation;
  final String code;
  final String language;

  const ChatResponseCard({
    required this.explanation,
    required this.code,
    this.language = 'Java',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🤖 AI Response",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            language.toUpperCase(),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.greenAccent,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
