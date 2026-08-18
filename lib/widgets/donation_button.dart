import 'package:flutter/material.dart';

class DonationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DonationButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'تبرع الآن',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
