import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../data/bhutan_profile_data.dart';
import '../models/app_user.dart';
import '../services/storage_service.dart';
import '../state/app_state.dart';

const List<String> _kAllInterests = [
  'Archery', 'Dzongkha poetry', 'Tsechu festival', 'Hiking', 'Butter tea',
  'Ema Datshi', 'Thangka painting', 'Traditional music', 'Farming', 'Meditation',
  'GNH philosophy', 'Football', 'Basketball', 'Cooking', 'Photography',
  'Travel', 'Reading', 'Movies', 'Gaming', 'Fitness', 'Dancing', 'Fashion',
  'Technology', 'Business', 'Art', 'Music', 'Volunteering',
];

const List<String> _kHeightsShort = [
  "Under 5'", "5'0\"", "5'5\"", "5'10\"", "6'0\"", "Over 6'",
];

class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  final void Function(AppUser) onUpdate;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.onUpdate,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _bioCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _hometownCtrl;
  late final TextEditingController _nicknameCtrl;

  late List<String?> _photos;
  final Map<int, double> _uploadProgress = {};
  final _imagePicker = ImagePicker();

  late List<String> _selectedInterests;

  int _age = 18;
  String _gender = '';
  String? _education;

  String? _height;
  String? _drinking;
  String? _smoking;
  String? _lookingFor;
  String? _zodiac;
  String? _bhutaneseZodiac;
  String? _religion;
  String? _ethnicity;
  List<String> _languages = [];

  bool _shareLocation = false;
  bool _basicsOpen = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _bioCtrl = TextEditingController(text: u.bio);
    _nameCtrl = TextEditingController(text: u.name == 'User' ? '' : u.name);
    _occupationCtrl = TextEditingController(text: u.occupation);
    _hometownCtrl = TextEditingController(text: u.hometown ?? '');
    _nicknameCtrl = TextEditingController(text: u.nickname ?? '');

    _selectedInterests = List.from(u.interests);

    final existing = u.photos ?? [];
    _photos = List<String?>.generate(5, (i) {
      if (i < existing.length) return existing[i];
      if (i == 0 && u.profileImage.isNotEmpty) return u.profileImage;
      return null;
    });

    _age = u.age > 0 ? u.age : 18;
    _gender = u.gender;
    _education = u.education;
    _height = u.height;
    _drinking = u.drinkingHabit;
    _smoking = u.smokingHabit;
    _lookingFor = u.lookingFor;
    _zodiac = u.zodiacSign;
    _bhutaneseZodiac = u.bhutaneseZodiac;
    _religion = u.religion;
    _ethnicity = u.ethnicity;
    _languages = (u.languages ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    _shareLocation = context.read<AppState>().shareLocation;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _nameCtrl.dispose();
    _occupationCtrl.dispose();
    _hometownCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  bool get _isUploading => _uploadProgress.isNotEmpty;

  Future<void> _pickPhoto(int slot) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source == null || !mounted) return;

    final picked = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;

    final uid = context.read<AppState>().userId ?? '';
    setState(() => _uploadProgress[slot] = 0.0);

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/$uid/photos/$ts.jpg');
      final task = ref.putFile(File(picked.path));
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0 && mounted) {
          setState(() => _uploadProgress[slot] = s.bytesTransferred / s.totalBytes);
        }
      });
      final snap = await task;
      final url = await snap.ref.getDownloadURL();
      if (!mounted) return;
      setState(() {
        _photos[slot] = url;
        _uploadProgress.remove(slot);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadProgress.remove(slot));
    }
  }

  void _removePhoto(int slot) {
    final url = _photos[slot];
    if (url != null) StorageService.deletePhoto(url);
    setState(() => _photos[slot] = null);
  }

  Future<void> _save() async {
    if (_isSaving || _isUploading) return;
    setState(() => _isSaving = true);
    final appState = context.read<AppState>();
    final uid = appState.userId;
    if (uid == null) {
      setState(() => _isSaving = false);
      return;
    }

    final photos = _photos.whereType<String>().toList();
    final langStr = _languages.join(', ');

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'age': _age,
      'gender': _gender,
      'bio': _bioCtrl.text.trim(),
      'interests': _selectedInterests,
      'occupation': _occupationCtrl.text.trim(),
      'hometown': _hometownCtrl.text.trim(),
      'nickname': _nicknameCtrl.text.trim(),
      'education': _education,
      'lookingFor': _lookingFor,
      'zodiacSign': _zodiac,
      'bhutaneseZodiac': _bhutaneseZodiac,
      'religion': _religion,
      'ethnicity': _ethnicity,
      'height': _height,
      'drinkingHabit': _drinking,
      'smokingHabit': _smoking,
      'languages': langStr,
      'photos': photos,
      if (photos.isNotEmpty) 'profileImage': photos.first,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      final updated = widget.user.copyWith(
        name: _nameCtrl.text.trim(),
        age: _age,
        gender: _gender,
        bio: _bioCtrl.text.trim(),
        interests: _selectedInterests,
        occupation: _occupationCtrl.text.trim(),
        hometown: _hometownCtrl.text.trim(),
        nickname: _nicknameCtrl.text.trim(),
        education: _education,
        lookingFor: _lookingFor,
        zodiacSign: _zodiac,
        bhutaneseZodiac: _bhutaneseZodiac,
        religion: _religion,
        ethnicity: _ethnicity,
        height: _height,
        drinkingHabit: _drinking,
        smokingHabit: _smoking,
        languages: langStr,
        photos: photos,
        profileImage: photos.isNotEmpty ? photos.first : widget.user.profileImage,
      );
      widget.onUpdate(updated);
      appState.shareLocation = _shareLocation;
      await appState.fetchCurrentUser();
    } catch (e) {
      debugPrint('Save profile error: $e');
    }

    if (mounted) Navigator.pop(context);
  }

  void _openTextSheet(String title, String hint, TextEditingController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TextSheet(title: title, hint: hint, ctrl: ctrl),
    ).then((_) { if (mounted) setState(() {}); });
  }

  void _openOptionSheet(String title, List<String> opts, String? current,
      void Function(String?) onSel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OptionSheet(
        title: title,
        options: opts,
        current: current,
        onSelect: onSel,
      ),
    );
  }

  void _openAgePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AgeSheet(
        current: _age,
        onSelect: (v) => setState(() => _age = v),
      ),
    );
  }

  void _openLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MultiSheet(
        title: 'Languages',
        options: kLanguages,
        selected: List.from(_languages),
        onSave: (v) => setState(() => _languages = v),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _photoSection(),
                    _sectionWrap('ABOUT ME', _bioField()),
                    _sectionWrap('INTERESTS', _interestsField()),
                    _basicsSection(),
                    _sectionWrap('MORE ABOUT ME', _moreAboutMe()),
                    _togglesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: AppColors.borderThin, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.white60),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'EDIT PROFILE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 3.5,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Photo section ──────────────────────────────────────────────────────────

  Widget _photoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickPhoto(0),
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF111111),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: _photos[0] != null
                        ? Image.network(
                            _photos[0]!,
                            fit: BoxFit.cover,
                            headers: const {
                              'User-Agent': 'Mozilla/5.0',
                              'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                            },
                            errorBuilder: (_, _, _) => _avatarFallback(),
                          )
                        : _avatarFallback(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: 5,
            itemBuilder: (_, i) => _photoSlot(i),
          ),
        ],
      ),
    );
  }

  Widget _photoSlot(int i) {
    final url = _photos[i];
    final progress = _uploadProgress[i];
    return GestureDetector(
      onTap: progress != null ? null : () => _pickPhoto(i),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderThin, width: 0.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  headers: const {'User-Agent': 'Mozilla/5.0'},
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              )
            else if (progress == null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: i == 0 ? AppColors.white60 : AppColors.white30,
                    size: 24,
                  ),
                  if (i == 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'BEST',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white30,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            if (progress != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            if (url != null && progress == null)
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _removePhoto(i),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                  ),
                ),
              ),
            if (url != null && i == 0 && progress == null)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BEST',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Text(
          widget.user.initial,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  // ── Section wrapper ────────────────────────────────────────────────────────

  Widget _sectionWrap(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.white30,
              letterSpacing: 3.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  // ── Bio ────────────────────────────────────────────────────────────────────

  Widget _bioField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          TextField(
            controller: _bioCtrl,
            maxLength: 500,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white, height: 1.5),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Tell people about yourself...',
              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.white30),
              filled: true,
              fillColor: const Color(0xFF111111),
              contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderThin, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white38, width: 1),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Positioned(
            bottom: 10,
            right: 14,
            child: Text(
              '${_bioCtrl.text.length}/500',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.white30),
            ),
          ),
        ],
      ),
    );
  }

  // ── Interests ──────────────────────────────────────────────────────────────

  Widget _interestsField() {
    final suggested = _kAllInterests
        .where((i) => !_selectedInterests.contains(i))
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedInterests.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedInterests.map((interest) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        interest,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _selectedInterests.remove(interest)),
                        child: const Icon(Icons.close_rounded, size: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'SUGGESTED',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.white30,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggested.take(24).map((interest) {
              return GestureDetector(
                onTap: () => setState(() => _selectedInterests.add(interest)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderThin, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        interest,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.white60),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.add_rounded, size: 14, color: AppColors.white30),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── My Basics ──────────────────────────────────────────────────────────────

  Widget _basicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => setState(() => _basicsOpen = !_basicsOpen),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'MY BASICS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white30,
                    letterSpacing: 3.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  _basicsOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.white30,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: _basicsRows(),
          crossFadeState: _basicsOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }

  Widget _basicsRows() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderThin, width: 0.5),
      ),
      child: Column(
        children: [
          _basicRow(
            'Full Name',
            _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Add name',
            () => _openTextSheet('Full Name', 'e.g. Pema Dorji', _nameCtrl),
          ),
          _divider(),
          _basicRow('Age', '$_age', _openAgePicker),
          _divider(),
          _basicRow(
            'Gender',
            _gender.isNotEmpty ? _gender : 'Select',
            () => _openOptionSheet(
              'Gender',
              ['Man', 'Woman', 'Non-binary', 'Prefer not to say'],
              _gender.isNotEmpty ? _gender : null,
              (v) => setState(() => _gender = v ?? ''),
            ),
          ),
          _divider(),
          _basicRow(
            'Occupation',
            _occupationCtrl.text.isNotEmpty ? _occupationCtrl.text : 'Add occupation',
            () => _openTextSheet('Occupation', 'e.g. Civil Servant, Teacher...', _occupationCtrl),
          ),
          _divider(),
          _basicRow(
            'Education',
            _education ?? 'Add education',
            () => _openOptionSheet(
              'Education',
              kEducationLevels,
              _education,
              (v) => setState(() => _education = v),
            ),
          ),
          _divider(),
          _basicRow(
            'Hometown',
            _hometownCtrl.text.isNotEmpty ? _hometownCtrl.text : 'Add hometown',
            () => _openTextSheet('Hometown', 'e.g. Thimphu, Paro...', _hometownCtrl),
          ),
          _divider(),
          _basicRow(
            'Nickname',
            _nicknameCtrl.text.isNotEmpty ? _nicknameCtrl.text : 'Add nickname',
            () => _openTextSheet('Nickname', 'e.g. Karma, Dema...', _nicknameCtrl),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _basicRow(String label, String value, VoidCallback onTap, {bool isLast = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.white30),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.white30, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.borderThin,
      indent: 16,
    );
  }

  // ── More About Me ──────────────────────────────────────────────────────────

  Widget _moreAboutMe() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip(
            label: 'Height',
            value: _height,
            options: _kHeightsShort,
            onSel: (v) => setState(() => _height = v),
          ),
          _chip(
            label: 'Drinking',
            value: _drinking,
            options: kDrinkingHabits,
            onSel: (v) => setState(() => _drinking = v),
          ),
          _chip(
            label: 'Smoking',
            value: _smoking,
            options: kSmokingHabits,
            onSel: (v) => setState(() => _smoking = v),
          ),
          _chip(
            label: 'Looking For',
            value: _lookingFor,
            options: kLookingFor,
            onSel: (v) => setState(() => _lookingFor = v),
          ),
          _chip(
            label: 'Zodiac',
            value: _zodiac,
            options: kZodiacSigns,
            onSel: (v) => setState(() => _zodiac = v),
          ),
          _chip(
            label: 'Bhutanese Zodiac',
            value: _bhutaneseZodiac,
            options: kBhutaneseZodiacAnimals,
            onSel: (v) => setState(() => _bhutaneseZodiac = v),
          ),
          _chip(
            label: 'Religion',
            value: _religion,
            options: kReligions,
            onSel: (v) => setState(() => _religion = v),
          ),
          _chip(
            label: 'Ethnicity',
            value: _ethnicity,
            options: kEthnicities,
            onSel: (v) => setState(() => _ethnicity = v),
          ),
          _languageChip(),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required String? value,
    required List<String> options,
    required void Function(String?) onSel,
  }) {
    final hasVal = value != null && value.isNotEmpty;
    return GestureDetector(
      onTap: () => _openOptionSheet(label, options, value, onSel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: hasVal ? Colors.white : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasVal ? Colors.transparent : AppColors.borderThin,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasVal ? value : label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: hasVal ? FontWeight.w600 : FontWeight.normal,
                color: hasVal ? Colors.black : AppColors.white60,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: hasVal ? Colors.black54 : AppColors.white30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageChip() {
    final hasVal = _languages.isNotEmpty;
    final label = hasVal ? _languages.join(', ') : 'Languages';
    return GestureDetector(
      onTap: _openLanguagePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: hasVal ? Colors.white : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasVal ? Colors.transparent : AppColors.borderThin,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: hasVal ? FontWeight.w600 : FontWeight.normal,
                  color: hasVal ? Colors.black : AppColors.white60,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: hasVal ? Colors.black54 : AppColors.white30,
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggles ────────────────────────────────────────────────────────────────

  Widget _togglesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderThin, width: 0.5),
        ),
        child: Column(
          children: [
            _toggleRow(
              icon: Icons.location_on_outlined,
              label: 'Live Location',
              subtitle: 'Share your location for better matches',
              value: _shareLocation,
              readOnly: false,
              onChanged: (v) => setState(() => _shareLocation = v),
            ),
            const Divider(height: 1, thickness: 0.5, color: AppColors.borderThin, indent: 16),
            _toggleRow(
              icon: Icons.verified_outlined,
              label: 'Verified Profile',
              subtitle: widget.user.verified
                  ? 'Your profile is verified'
                  : 'Verification pending',
              value: widget.user.verified,
              readOnly: true,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required bool readOnly,
    required void Function(bool)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderThin, width: 0.5),
            ),
            child: Icon(icon, color: AppColors.white60, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.white30),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: readOnly ? null : onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.25),
            inactiveThumbColor: AppColors.white30,
            inactiveTrackColor: AppColors.surface2,
          ),
        ],
      ),
    );
  }
}

// ── Helper sheets ──────────────────────────────────────────────────────────────

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderThin,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _option(context, Icons.photo_library_rounded, 'Choose from Gallery', ImageSource.gallery),
          const SizedBox(height: 10),
          _option(context, Icons.camera_alt_rounded, 'Take a Photo', ImageSource.camera),
        ],
      ),
    );
  }

  Widget _option(BuildContext ctx, IconData icon, String label, ImageSource src) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, src),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderThin, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white60, size: 20),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.inter(fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _TextSheet extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController ctrl;

  const _TextSheet({required this.title, required this.hint, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderThin,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderThin, width: 0.5),
              ),
              child: TextField(
                controller: ctrl,
                autofocus: true,
                cursorColor: Colors.white,
                style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.white30),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('Done',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? current;
  final void Function(String?) onSelect;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderThin,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 16),
            ...options.map((opt) {
              final sel = opt == current;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    onSelect(opt);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? Colors.white : AppColors.borderThin,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                  color: sel ? Colors.black : Colors.white)),
                        ),
                        if (sel) const Icon(Icons.check_rounded, color: Colors.black, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AgeSheet extends StatefulWidget {
  final int current;
  final void Function(int) onSelect;

  const _AgeSheet({required this.current, required this.onSelect});

  @override
  State<_AgeSheet> createState() => _AgeSheetState();
}

class _AgeSheetState extends State<_AgeSheet> {
  late int _selected;
  late final FixedExtentScrollController _ctrl;

  @override
  void initState() {
    super.initState();
    _selected = widget.current.clamp(18, 60);
    _ctrl = FixedExtentScrollController(initialItem: _selected - 18);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderThin, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Age',
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _ctrl,
              itemExtent: 44,
              perspective: 0.003,
              diameterRatio: 2.2,
              onSelectedItemChanged: (i) => setState(() => _selected = i + 18),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 43,
                builder: (_, i) {
                  final age = i + 18;
                  final sel = age == _selected;
                  return Center(
                    child: Text(
                      '$age',
                      style: GoogleFonts.outfit(
                        fontSize: sel ? 22 : 16,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                        color: sel ? Colors.white : AppColors.white30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 40),
            child: GestureDetector(
              onTap: () {
                widget.onSelect(_selected);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('Done',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selected;
  final void Function(List<String>) onSave;

  const _MultiSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSave,
  });

  @override
  State<_MultiSheet> createState() => _MultiSheetState();
}

class _MultiSheetState extends State<_MultiSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderThin,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.title,
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: widget.options.length,
                itemBuilder: (_, i) {
                  final opt = widget.options[i];
                  final sel = _selected.contains(opt);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        sel ? _selected.remove(opt) : _selected.add(opt);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: sel ? Colors.white : AppColors.surface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? Colors.white : AppColors.borderThin,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(opt,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                      color: sel ? Colors.black : Colors.white)),
                            ),
                            if (sel)
                              const Icon(Icons.check_rounded, color: Colors.black, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: GestureDetector(
                onTap: () {
                  widget.onSave(_selected);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text('Done',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
