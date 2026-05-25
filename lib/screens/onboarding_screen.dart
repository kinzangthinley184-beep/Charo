import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../state/app_state.dart';

const _kInterests = [
  'Hiking', 'Photography', 'Archery', 'Cooking', 'Travel', 'Music',
  'Art', 'Reading', 'Yoga', 'Dancing', 'Gaming', 'Movies', 'Sports',
  'Meditation', 'Thangka', 'Dzong visits', 'Tsechu', 'Farming',
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Step 1 — basic info
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = '';

  // Step 2 — bio
  final _bioCtrl = TextEditingController();

  // Step 3 — interests
  final Set<String> _selected = {};

  bool _saving = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        _snack('Please enter your name');
        return;
      }
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
      if (age < 18 || age > 99) {
        _snack('Please enter a valid age (18–99)');
        return;
      }
      if (_gender.isEmpty) {
        _snack('Please select a gender');
        return;
      }
    }
    if (_page < 2) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _save();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AppState>().updateUserProfile(
            name: _nameCtrl.text.trim(),
            age: int.parse(_ageCtrl.text.trim()),
            gender: _gender,
            bio: _bioCtrl.text.trim(),
            interests: _selected.toList(),
          );
    } catch (e) {
      if (mounted) _snack('Something went wrong. Try again.');
      setState(() => _saving = false);
    }
    // AppState.needsOnboarding becomes false → main.dart shows HomeScreen
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.matchPink));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _StepBasicInfo(
                    nameCtrl: _nameCtrl,
                    ageCtrl: _ageCtrl,
                    gender: _gender,
                    onGender: (g) => setState(() => _gender = g),
                  ),
                  _StepBio(bioCtrl: _bioCtrl),
                  _StepInterests(
                    selected: _selected,
                    onToggle: (i) => setState(() =>
                        _selected.contains(i) ? _selected.remove(i) : _selected.add(i)),
                  ),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                color: i <= _page ? AppColors.saffron : AppColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        children: [
          if (_page > 0)
            GestureDetector(
              onTap: () => _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.darkElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.darkTextPrimary),
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: _saving ? null : _next,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _page == 2 ? 'Start Exploring' : 'Continue',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Basic info ────────────────────────────────────────────────────────

class _StepBasicInfo extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  final String gender;
  final void Function(String) onGender;

  const _StepBasicInfo({
    required this.nameCtrl,
    required this.ageCtrl,
    required this.gender,
    required this.onGender,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about yourself',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 8),
          Text('This is how you\'ll appear to others.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.darkTextSecondary)),
          const SizedBox(height: 32),
          _label('Your name'),
          const SizedBox(height: 8),
          _field(
            controller: nameCtrl,
            hint: 'e.g. Pema Dorji',
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          _label('Age'),
          const SizedBox(height: 8),
          _field(
            controller: ageCtrl,
            hint: 'e.g. 25',
            inputType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          _label('Gender'),
          const SizedBox(height: 8),
          Row(
            children: ['Man', 'Woman', 'Non-binary'].map((g) {
              final sel = gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onGender(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.saffron.withValues(alpha: 0.15)
                          : AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? AppColors.saffron : AppColors.darkBorder,
                          width: sel ? 1.5 : 1),
                    ),
                    child: Center(
                      child: Text(g,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel
                                  ? AppColors.saffron
                                  : AppColors.darkTextSecondary)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextSecondary));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        textCapitalization: capitalization,
        inputFormatters: formatters,
        style: GoogleFonts.poppins(
            fontSize: 15, color: AppColors.darkTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              fontSize: 15, color: AppColors.darkTextSecondary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Step 2: Bio ───────────────────────────────────────────────────────────────

class _StepBio extends StatelessWidget {
  final TextEditingController bioCtrl;
  const _StepBio({required this.bioCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Write a short bio',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 8),
          Text('Let people know what makes you unique.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.darkTextSecondary)),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: TextField(
              controller: bioCtrl,
              maxLines: 6,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.poppins(
                  fontSize: 15, color: AppColors.darkTextPrimary),
              decoration: InputDecoration(
                hintText:
                    'e.g. I love hiking the trails around Thimphu and exploring Bhutan\'s hidden monasteries...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.darkTextSecondary,
                    height: 1.5),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.darkTextSecondary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('You can skip this and add it later from your profile.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }
}

// ── Step 3: Interests ─────────────────────────────────────────────────────────

class _StepInterests extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onToggle;

  const _StepInterests({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your interests',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 8),
          Text('Pick up to 5 things you enjoy.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.darkTextSecondary)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _kInterests.map((interest) {
              final sel = selected.contains(interest);
              final canAdd = selected.length < 5;
              return GestureDetector(
                onTap: () {
                  if (sel || canAdd) onToggle(interest);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.saffron.withValues(alpha: 0.15)
                        : AppColors.darkElevated,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: sel ? AppColors.saffron : AppColors.darkBorder,
                        width: sel ? 1.5 : 1),
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel
                            ? AppColors.saffron
                            : (canAdd || sel
                                ? AppColors.darkTextPrimary
                                : AppColors.darkTextSecondary)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('${selected.length}/5 selected',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }
}
