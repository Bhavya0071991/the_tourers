import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    showWithMessenger(ScaffoldMessenger.of(context), message, isError: isError);
  }

  static void showWithMessenger(ScaffoldMessengerState messenger, String message, {bool isError = false}) {
    
    final bgColor = isError ? Colors.redAccent : AppTheme.neonAccent;
    final textColor = AppTheme.pureBlack;
    final borderColor = AppTheme.pureBlack;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.2),
                offset: const Offset(6, 6),
                blurRadius: 0,
              )
            ]
          ),
          child: Text(
            message.toUpperCase(),
            style: GoogleFonts.spaceMono(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(24.0),
      ),
    );
  }
}
