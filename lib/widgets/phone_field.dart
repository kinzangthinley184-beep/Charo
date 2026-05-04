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

/// Supported countries — Bhutan (+975) is index 0 and the default.
const kCountries = [
  Country(name: 'Bhutan',         flag: '🇧🇹', dialCode: '+975', maxDigits: 8),
  Country(name: 'India',          flag: '🇮🇳', dialCode: '+91',  maxDigits: 10),
  Country(name: 'Nepal',          flag: '🇳🇵', dialCode: '+977', maxDigits: 10),
  Country(name: 'Bangladesh',     flag: '🇧🇩', dialCode: '+880', maxDigits: 11),
  Country(name: 'Sri Lanka',      flag: '🇱🇰', dialCode: '+94',  maxDigits: 9),
  Country(name: 'China',          flag: '🇨🇳', dialCode: '+86',  maxDigits: 11),
  Country(name: 'United States',  flag: '🇺🇸', dialCode: '+1',   maxDigits: 10),
  Country(name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44',  maxDigits: 10),
  Country(name: 'Australia',      flag: '🇦🇺', dialCode: '+61',  maxDigits: 9),
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
  Country _selected = kCountries.first;

  void _openCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CountryPickerSheet(
        selected: _selected,
        onSelect: (c) {
          setState(() => _selected = c);
          widget.onCountryChanged?.call(c);
          Navigator.pop(context);
        },
      ),
    );
  }

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
          // Country code selector
          GestureDetector(
            onTap: _openCountryPicker,
            child: Container(
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
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.darkTextSecondary),
                ],
              ),
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

class _CountryPickerSheet extends StatelessWidget {
  final Country selected;
  final ValueChanged<Country> onSelect;

  const _CountryPickerSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Select Country',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.darkDivider),
          // NeverScrollableScrollPhysics because sheet itself handles scrolling
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kCountries.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.darkDivider),
            itemBuilder: (_, i) {
              final c = kCountries[i];
              final isSelected = c.dialCode == selected.dialCode;
              return ListTile(
                leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                title: Text(
                  c.name,
                  style: GoogleFonts.poppins(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                trailing: Text(
                  c.dialCode,
                  style: GoogleFonts.poppins(
                    color: AppColors.saffron,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => onSelect(c),
                tileColor: isSelected
                    ? AppColors.saffron.withValues(alpha: 0.08)
                    : null,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
