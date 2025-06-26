import 'dart:async';

import 'package:flutter/material.dart';

class SampleDialog extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const SampleDialog({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showSampleDialog(BuildContext context,
    {required String message,
    IconData icon = Icons.check_circle_outline,
    Color color = Colors.green}) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'sample',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    useRootNavigator: true,
    pageBuilder: (context, anim1, anim2) {
      return Material(
        type: MaterialType.transparency,
        child: SampleDialog(icon: icon, message: message, color: color),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );

  await Future.delayed(const Duration(seconds: 3));
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}
