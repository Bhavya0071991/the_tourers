import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFieldLabeled extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final bool autofocus;

  const AppFieldLabeled({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: hasError ? Colors.redAccent : textColor.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border.all(
              color: hasError ? Colors.redAccent : textColor,
              width: hasError ? 2.5 : 2.0,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            validator: validator,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            autofocus: autofocus,
            style: GoogleFonts.spaceMono(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.spaceMono(
                color: textColor.withValues(alpha: 0.3),
                fontSize: 13,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: IconTheme(
                        data: IconThemeData(
                          color: textColor.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        child: prefixIcon!,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
            ),
          ),
        ),

        // Error text
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }
}
