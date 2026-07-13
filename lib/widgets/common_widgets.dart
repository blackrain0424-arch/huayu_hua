import 'package:flutter/material.dart';

const Color appGreen = Color(0xFF2E7D32);
const Color appPink = Color(0xFFC2185B);
const Color appLightPink = Color(0xFFFFEEF4);
const Color appWarmBg = Color(0xFFFFFBF6);
const Color appBorder = Color(0xFFF1E8DD);

Widget buildSectionCard({
  required IconData icon,
  required String title,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: appBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.045),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: appLightPink,
              child: Icon(icon, size: 19, color: appPink),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
