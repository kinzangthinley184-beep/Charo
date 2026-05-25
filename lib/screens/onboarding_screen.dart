import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.raleway(color: Colors.white, fontSize: 13)),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 1.5,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                color: i <= _page ? Colors.white : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Row(
        children: [
          if (_page > 0)
            GestureDetector(
              onTap: () => _pageCtrl.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF222222), width: 0.5),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF555555), size: 18),
              ),
            ),
          const Spacer(),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: _saving ? null : _next,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 1.5),
                    )
                  : Text(
                      _page == 2 ? 'START EXPLORING' : 'CONTINUE',
                      style: GoogleFonts.raleway(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Colors.black),
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
          Text('STEP 1 OF 3',
              style: GoogleFonts.raleway(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: const Color(0xFF333333))),
          const SizedBox(height: 14),
          Text('Tell us about\nyourself.',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.25)),
          const SizedBox(height: 8),
          Text('This is how you\'ll appear to others.',
              style: GoogleFonts.raleway(
                  fontSize: 12, color: const Color(0xFF444444))),
          const SizedBox(height: 36),
          _label('YOUR NAME'),
          const SizedBox(height: 8),
          _field(
            controller: nameCtrl,
            hint: 'e.g. Pema Dorji',
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          _label('AGE'),
          const SizedBox(height: 8),
          _field(
            controller: ageCtrl,
            hint: 'e.g. 25',
            inputType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          _label('GENDER'),
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
                          ? const Color(0xFF141414)
                          : const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel ? Colors.white : const Color(0xFF2A2A2A),
                          width: 0.5),
                    ),
                    child: Center(
                      child: Text(g,
                          style: GoogleFonts.raleway(
                              fontSize: 12,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                              color: sel
                                  ? Colors.white
                                  : const Color(0xFF444444))),
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
      style: GoogleFonts.raleway(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
          color: const Color(0xFF444444)));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      style: GoogleFonts.raleway(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.raleway(
            fontSize: 14, color: const Color(0xFF333333)),
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 0.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Text('STEP 2 OF 3',
              style: GoogleFonts.raleway(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: const Color(0xFF333333))),
          const SizedBox(height: 14),
          Text('Write a\nshort bio.',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.25)),
          const SizedBox(height: 8),
          Text('Let people know what makes you unique.',
              style: GoogleFonts.raleway(
                  fontSize: 12, color: const Color(0xFF444444))),
          const SizedBox(height: 36),
          TextField(
            controller: bioCtrl,
            maxLines: 6,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.raleway(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  'e.g. I love hiking the trails around Thimphu and exploring Bhutan\'s hidden monasteries...',
              hintStyle: GoogleFonts.raleway(
                  fontSize: 13,
                  color: const Color(0xFF333333),
                  height: 1.6),
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 0.5),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterStyle: GoogleFonts.raleway(
                  fontSize: 11, color: const Color(0xFF333333)),
            ),
          ),
          const SizedBox(height: 12),
          Text('You can skip this and add it later from your profile.',
              style: GoogleFonts.raleway(
                  fontSize: 11, color: const Color(0xFF2A2A2A))),
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
          Text('STEP 3 OF 3',
              style: GoogleFonts.raleway(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: const Color(0xFF333333))),
          const SizedBox(height: 14),
          Text('Your\ninterests.',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.25)),
          const SizedBox(height: 8),
          Text('Pick up to 5 things you enjoy.',
              style: GoogleFonts.raleway(
                  fontSize: 12, color: const Color(0xFF444444))),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                        ? const Color(0xFF141414)
                        : const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? Colors.white : const Color(0xFF2A2A2A),
                        width: 0.5),
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.raleway(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel
                            ? Colors.white
                            : (canAdd
                                ? const Color(0xFF444444)
                                : const Color(0xFF444444))),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('${selected.length}/5 selected',
              style: GoogleFonts.raleway(
                  fontSize: 11, color: const Color(0xFF333333))),
        ],
      ),
    );
  }
}
