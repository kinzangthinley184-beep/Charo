import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1.5),
      ),
      child: Row(
        children: [
          // Country code display (static — Bhutan only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
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
                    color: const Color(0xFFF2F2F2),
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
                color: const Color(0xFFF2F2F2),
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'X' * _selected.maxDigits,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF888888),
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

