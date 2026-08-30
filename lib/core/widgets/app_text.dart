import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const AppText._({
    super.key,
    required this.text,
    required this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  /// Streetwear Brutalist Header Style (Bebas Neue)
  factory AppText.bebas(
    String text, {
    Key? key,
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    List<Shadow>? shadows,
  }) {
    return AppText._(
      key: key,
      text: text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: GoogleFonts.bebasNeue(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      ),
    );
  }

  /// monospaced detail text style (Space Mono)
  factory AppText.spaceMono(
    String text, {
    Key? key,
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? height,
    FontWeight? fontWeight,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    TextDecoration? decoration,
  }) {
    return AppText._(
      key: key,
      text: text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: GoogleFonts.spaceMono(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontWeight: fontWeight,
        decoration: decoration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
