import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class Country {
  final String name;
  final String flag;
  final String dialCode;
  final int maxDigits;

  const Country({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.maxDigits,
  });
}

/// Bhutan is the only supported country.
const kCountries = [
  Country(name: 'Bhutan', flag: '🇧🇹', dialCode: '+975', maxDigits: 8),
];

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<Country>? onCountryChanged;
  final String? Function(String?)? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.onCountryChanged,
    this.validator,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final Country _selected = kCountries.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Country code display (static — Bhutan only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.darkBorder,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selected.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text(
                  _selected.dialCode,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Number input
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_selected.maxDigits),
              ],
              validator: widget.validator,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextPrimary,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'X' * _selected.maxDigits,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.darkTextSecondary.withValues(alpha: 0.5),
                  letterSpacing: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

