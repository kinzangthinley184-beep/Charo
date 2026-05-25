import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_colors.dart';
import '../data/bhutan_profile_data.dart';
import '../models/app_user.dart';
import '../services/storage_service.dart';
import '../widgets/verified_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;
  const ProfileScreen({super.key, required this.isPremium, required this.onUpgrade});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser _currentUser = AppUser(
    id: '', name: '', age: 0, gender: '', bio: '',
    profileImage: '', interests: [], location: '', verified: false,
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    if (user != null) _currentUser = user;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              _buildResonance(),
              const SizedBox(height: 16),
              _buildIntentRow(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _showCompleteProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'REFINE IDENTITY',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPhotoGrid(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showSettings,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderThin, width: 0.5),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.white30,
                  size: 18,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Center(
                  child: _buildAvatar()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.08, duration: 500.ms, curve: Curves.easeOut),
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileInfo(),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAvatar() {
    final photoUrl = _currentUser.photos?.isNotEmpty == true
        ? _currentUser.photos!.first
        : (_currentUser.profileImage.isNotEmpty ? _currentUser.profileImage : null);

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(photoUrl, fit: BoxFit.cover,
                headers: const {'User-Agent': 'Mozilla/5.0'},
                errorBuilder: (_, _, _) => _avatarFallback())
            : _avatarFallback(),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Text(
          _currentUser.initial,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentUser.age > 0 ? '${_currentUser.name}, ${_currentUser.age}' : _currentUser.name,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const VerifiedBadge(size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 10, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 3),
            Text(
              _currentUser.location.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResonance() {
    final interests = _currentUser.interests;
    if (interests.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESONANCE',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderThin, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_interestIcon(tag), size: 12, color: AppColors.white30),
                          const SizedBox(width: 6),
                          Text(
                            tag.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white60,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  IconData _interestIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'archery': return Icons.sports;
      case 'hiking': return Icons.terrain;
      case 'tsechu': return Icons.celebration;
      case 'ema datshi': return Icons.restaurant;
      case 'gnh': return Icons.eco;
      default: return Icons.circle;
    }
  }

  Widget _buildIntentRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _IntentCard(value: _currentUser.lookingFor)),
          const SizedBox(width: 12),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildMainPhotoSlot(),
            ),
          ),
          const SizedBox(height: 2),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: 4,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildEmptyPhotoSlot(i + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPhotoSlot() {
    final photoUrl = _currentUser.photos?.isNotEmpty == true
        ? _currentUser.photos!.first
        : (_currentUser.profileImage.isNotEmpty ? _currentUser.profileImage : null);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (photoUrl != null)
          Image.network(photoUrl, fit: BoxFit.cover,
              headers: const {'User-Agent': 'Mozilla/5.0'},
              errorBuilder: (_, _, _) => _photoFallback())
        else
          _photoFallback(),
      ],
    );
  }

  Widget _photoFallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          color: Colors.white.withValues(alpha: 0.2),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildEmptyPhotoSlot(int index) {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          color: Colors.white.withValues(alpha: 0.2),
          size: 24,
        ),
      ),
    );
  }

  void _showCompleteProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: _currentUser,
          onUpdate: (updated) => setState(() {}),
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderThin,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          _settingsTile(
            title: 'Notifications',
            icon: Icons.notifications_none_rounded,
            isDestructive: false,
            onTap: () { Navigator.pop(context); _showComingSoon('Notifications'); },
          ),
          _settingsTile(
            title: 'Privacy',
            icon: Icons.lock_outline_rounded,
            isDestructive: false,
            onTap: () { Navigator.pop(context); _showComingSoon('Privacy'); },
          ),
          _settingsTile(
            title: 'Help & Support',
            icon: Icons.help_outline_rounded,
            isDestructive: false,
            onTap: () { Navigator.pop(context); _showComingSoon('Help & Support'); },
          ),
          Divider(height: 24, color: AppColors.borderThin),
          _settingsTile(
            title: 'Log Out',
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () { Navigator.pop(context); _confirmLogout(); },
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required IconData icon,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
              : AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderThin, width: 0.5),
        ),
        child: Icon(
          icon,
          color: isDestructive ? const Color(0xFFEF4444) : AppColors.white60,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? const Color(0xFFEF4444) : Colors.white,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppColors.white30, size: 20),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderThin, width: 0.5),
        ),
        title: Text(
          feature,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          '$feature is coming soon! We\'re working hard to bring it to you.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderThin, width: 0.5),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to log out?\nYou'll need to sign in again.",
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.white30, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: _doLogout,
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout() async {
    final appState = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    navigator.pop();
    await appState.logout();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Logged out successfully',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.surface2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

// ── Intent card ─────────────────────────────────────────────────────────────

class _IntentCard extends StatelessWidget {
  final String? value;
  const _IntentCard({this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderThin, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_border, color: Color(0x66FFFFFF), size: 22),
          const SizedBox(height: 6),
          Text(
            'INTENT',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0x66FFFFFF),
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value ?? 'Not set yet',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── About me row ────────────────────────────────────────────────────────────

// ── Complete profile sheet ──────────────────────────────────────────────────

class _CompleteProfileSheet extends StatefulWidget {
  final AppUser user;
  final void Function(AppUser) onUpdate;
  const _CompleteProfileSheet({required this.user, required this.onUpdate});

  @override
  State<_CompleteProfileSheet> createState() => _CompleteProfileSheetState();
}

class _CompleteProfileSheetState extends State<_CompleteProfileSheet> {
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  int _score() {
    int s = 0;
    if ((_user.photos ?? []).isNotEmpty) s += 20;
    if (_user.occupation.isNotEmpty) s += 15;
    if (_user.education?.isNotEmpty == true) s += 10;
    if (_user.interests.length >= 3) s += 10;
    if (_user.height?.isNotEmpty == true) s += 5;
    if (_user.zodiacSign?.isNotEmpty == true) s += 5;
    if (_user.religion?.isNotEmpty == true) s += 5;
    if (_user.ethnicity?.isNotEmpty == true) s += 5;
    if (_user.drinkingHabit?.isNotEmpty == true) s += 5;
    if (_user.smokingHabit?.isNotEmpty == true) s += 5;
    if (_user.lookingFor?.isNotEmpty == true) s += 10;
    if (_user.languages?.isNotEmpty == true) s += 5;
    return s;
  }

  void _update(AppUser u) {
    setState(() => _user = u);
    widget.onUpdate(u);
  }

  void _picker(String title, List<String> options, String? current,
      void Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(
          title: title,
          options: options,
          currentValue: current,
          onSelect: onSelect),
    );
  }

  void _textEditor(String title, String hint, String? current,
      void Function(String) onSave) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TextEditorSheet(
          title: title, hint: hint, currentValue: current, onSave: onSave),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderThin, width: 0.5),
        ),
        child: Icon(
          icon,
          color: isDone ? Colors.white : AppColors.white60,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isDone ? AppColors.white60 : AppColors.white30,
        ),
      ),
      trailing: isDone
          ? const Icon(Icons.check_circle_rounded, color: AppColors.onlineGreen, size: 20)
          : const Icon(Icons.add_circle_outline_rounded, color: AppColors.white30, size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = _score();
    final photos = _user.photos ?? [];
    final langs = (_user.languages ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderThin,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete your profile',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score% complete — more info gets 3× more connections',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.white60),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100.0,
                    backgroundColor: AppColors.surface2,
                    color: Colors.white.withValues(alpha: 0.6),
                    minHeight: 6,
                  ),
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                children: [
                  _row(
                    icon: Icons.photo_camera_rounded,
                    title: 'Add photos',
                    subtitle: photos.isEmpty ? 'Add up to 5 photos' : '${photos.length} photos added',
                    isDone: photos.isNotEmpty,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _PhotosEditorSheet(
                        photos: photos,
                        userId: _user.id,
                        onSave: (p) => _update(_user.copyWith(photos: p)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.work_outline_rounded,
                    title: 'Occupation',
                    subtitle: _user.occupation.isNotEmpty ? _user.occupation : 'What do you do?',
                    isDone: _user.occupation.isNotEmpty,
                    onTap: () => _textEditor(
                        'Your occupation',
                        'e.g. Civil Servant, Teacher, Monk...',
                        _user.occupation,
                        (v) => _update(_user.copyWith(occupation: v))),
                  ),
                  _row(
                    icon: Icons.school_outlined,
                    title: 'Education',
                    subtitle: _user.education ?? 'Highest qualification',
                    isDone: _user.education?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Education level', kEducationLevels, _user.education,
                        (v) => _update(_user.copyWith(education: v))),
                  ),
                  _row(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Looking for',
                    subtitle: _user.lookingFor ?? 'What are you here for?',
                    isDone: _user.lookingFor?.isNotEmpty == true,
                    onTap: () => _picker(
                        'I am looking for...', kLookingFor, _user.lookingFor,
                        (v) => _update(_user.copyWith(lookingFor: v))),
                  ),
                  _row(
                    icon: Icons.interests_rounded,
                    title: 'Interests',
                    subtitle: _user.interests.isEmpty
                        ? 'What do you love?'
                        : _user.interests.take(3).join(' · '),
                    isDone: _user.interests.length >= 3,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _InterestsEditorSheet(
                        selected: List.from(_user.interests),
                        onSave: (interests) => _update(_user.copyWith(interests: interests)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.language_rounded,
                    title: 'Languages',
                    subtitle: _user.languages ?? 'Languages you speak',
                    isDone: _user.languages?.isNotEmpty == true,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _MultiPickerSheet(
                        title: 'Languages you speak',
                        options: kLanguages,
                        selectedValues: langs,
                        onSave: (v) => _update(_user.copyWith(languages: v)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Zodiac sign',
                    subtitle: _user.zodiacSign ?? 'Western zodiac',
                    isDone: _user.zodiacSign?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Your zodiac sign', kZodiacSigns, _user.zodiacSign,
                        (v) => _update(_user.copyWith(zodiacSign: v))),
                  ),
                  _row(
                    icon: Icons.pets_rounded,
                    title: 'Bhutanese zodiac',
                    subtitle: _user.bhutaneseZodiac ?? 'Losar birth animal',
                    isDone: _user.bhutaneseZodiac?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Your birth year animal', kBhutaneseZodiacAnimals, _user.bhutaneseZodiac,
                        (v) => _update(_user.copyWith(bhutaneseZodiac: v))),
                  ),
                  _row(
                    icon: Icons.temple_buddhist_rounded,
                    title: 'Religion',
                    subtitle: _user.religion ?? 'Optional',
                    isDone: _user.religion?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Religion', kReligions, _user.religion,
                        (v) => _update(_user.copyWith(religion: v))),
                  ),
                  _row(
                    icon: Icons.people_outline_rounded,
                    title: 'Ethnicity',
                    subtitle: _user.ethnicity ?? 'Optional',
                    isDone: _user.ethnicity?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Ethnicity', kEthnicities, _user.ethnicity,
                        (v) => _update(_user.copyWith(ethnicity: v))),
                  ),
                  _row(
                    icon: Icons.height_rounded,
                    title: 'Height',
                    subtitle: _user.height ?? 'Optional',
                    isDone: _user.height?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Your height', kHeights, _user.height,
                        (v) => _update(_user.copyWith(height: v))),
                  ),
                  _row(
                    icon: Icons.local_bar_outlined,
                    title: 'Drinking',
                    subtitle: _user.drinkingHabit ?? 'Optional',
                    isDone: _user.drinkingHabit?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Drinking habits', kDrinkingHabits, _user.drinkingHabit,
                        (v) => _update(_user.copyWith(drinkingHabit: v))),
                  ),
                  _row(
                    icon: Icons.smoking_rooms_outlined,
                    title: 'Smoking',
                    subtitle: _user.smokingHabit ?? 'Optional',
                    isDone: _user.smokingHabit?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Smoking habits', kSmokingHabits, _user.smokingHabit,
                        (v) => _update(_user.copyWith(smokingHabit: v))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Picker sheet ────────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? currentValue;
  final void Function(String) onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderThin,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((opt) {
              final selected = opt == currentValue;
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
                      color: selected ? Colors.white : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? Colors.white : AppColors.borderThin,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      opt,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? Colors.black : Colors.white,
                      ),
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

// ── Multi-picker sheet ──────────────────────────────────────────────────────

class _MultiPickerSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedValues;
  final void Function(String) onSave;

  const _MultiPickerSheet({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onSave,
  });

  @override
  State<_MultiPickerSheet> createState() => _MultiPickerSheetState();
}

class _MultiPickerSheetState extends State<_MultiPickerSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderThin,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.options.length,
                itemBuilder: (_, i) {
                  final opt = widget.options[i];
                  final selected = _selected.contains(opt);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) => setState(() {
                      if (selected) { _selected.remove(opt); } else { _selected.add(opt); }
                    }),
                    title: Text(
                      opt,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                    ),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: GestureDetector(
                onTap: () {
                  widget.onSave(_selected.join(', '));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
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

// ── Text editor sheet ───────────────────────────────────────────────────────

class _TextEditorSheet extends StatefulWidget {
  final String title;
  final String hint;
  final String? currentValue;
  final void Function(String) onSave;

  const _TextEditorSheet({
    required this.title,
    required this.hint,
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<_TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<_TextEditorSheet> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentValue ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderThin,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderThin, width: 0.5),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                cursorColor: Colors.white,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.white30),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) {
                  final v = _ctrl.text.trim();
                  if (v.isNotEmpty) { widget.onSave(v); Navigator.pop(context); }
                },
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                final v = _ctrl.text.trim();
                if (v.isNotEmpty) { widget.onSave(v); Navigator.pop(context); }
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
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

// ── Interests editor sheet ──────────────────────────────────────────────────

const List<String> _kAllInterests = [
  'Archery', 'Dzongkha poetry', 'Tsechu festival', 'Hiking', 'Butter tea',
  'Ema Datshi', 'Thangka painting', 'Traditional music', 'Farming', 'Meditation',
  'GNH philosophy', 'Football', 'Basketball', 'Cooking', 'Photography',
  'Travel', 'Reading', 'Movies', 'Gaming', 'Fitness', 'Dancing', 'Fashion',
  'Technology', 'Business', 'Art', 'Music', 'Volunteering',
];

class _InterestsEditorSheet extends StatefulWidget {
  final List<String> selected;
  final void Function(List<String>) onSave;

  const _InterestsEditorSheet({required this.selected, required this.onSave});

  @override
  State<_InterestsEditorSheet> createState() => _InterestsEditorSheetState();
}

class _InterestsEditorSheetState extends State<_InterestsEditorSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderThin,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Interests',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick at least 3',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.white60),
                ),
                const SizedBox(height: 16),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kAllInterests.map((interest) {
                      final isSelected = _selected.contains(interest);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) { _selected.remove(interest); } else { _selected.add(interest); }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.surface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.white : AppColors.borderThin,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            interest,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.black : AppColors.white60,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: GestureDetector(
                onTap: () {
                  widget.onSave(_selected);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
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

// ── Photos editor sheet ─────────────────────────────────────────────────────

class _PhotosEditorSheet extends StatefulWidget {
  final List<String> photos;
  final String userId;
  final void Function(List<String>) onSave;

  const _PhotosEditorSheet({
    required this.photos,
    required this.userId,
    required this.onSave,
  });

  @override
  State<_PhotosEditorSheet> createState() => _PhotosEditorSheetState();
}

class _PhotosEditorSheetState extends State<_PhotosEditorSheet> {
  static const int _maxSlots = 5;
  late List<String?> _photos;
  final Map<int, double> _progress = {};
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photos = List<String?>.generate(
      _maxSlots,
      (i) => i < widget.photos.length ? widget.photos[i] : null,
    );
  }

  bool get _isUploading => _progress.isNotEmpty;

  Future<void> _pickAndUpload(int slot) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _progress[slot] = 0.0);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/${widget.userId}/photos/$timestamp.jpg');

      final task = ref.putFile(File(picked.path));
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0 && mounted) {
          setState(() => _progress[slot] = s.bytesTransferred / s.totalBytes);
        }
      });

      final snapshot = await task;
      final url = await snapshot.ref.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _photos[slot] = url;
        _progress.remove(slot);
      });

      final urls = _photos.whereType<String>().toList();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({'photos': urls}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded!')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _progress.remove(slot));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed')),
      );
    }
  }

  Future<void> _deletePhoto(int slot) async {
    final url = _photos[slot];
    if (url == null) return;
    setState(() => _photos[slot] = null);
    StorageService.deletePhoto(url);
  }

  Future<void> _onDone() async {
    if (_isUploading) return;
    final urls = _photos.whereType<String>().toList();
    widget.onSave(urls);
    if (widget.userId.isNotEmpty && mounted) {
      context.read<AppState>().updateUserPhotos(urls);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget _buildSlot(int i) {
    final url = _photos[i];
    final progress = _progress[i];
    final uploading = progress != null;

    return GestureDetector(
      onTap: uploading ? null : () => _pickAndUpload(i),
      child: Container(
        decoration: BoxDecoration(
          color: url != null ? null : AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: url != null
              ? null
              : Border.all(color: AppColors.borderThin, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.cover),
              )
            else if (!uploading)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    color: i == 0 ? AppColors.white60 : AppColors.white30,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  if (i == 0)
                    Text(
                      'Add photo',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            if (uploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            if (url != null && !uploading)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _deletePhoto(i),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderThin,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add photos',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'First photo is your main. Tap to add, × to remove.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.white60),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                controller: ctrl,
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: List.generate(_maxSlots, _buildSlot),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: GestureDetector(
                onTap: _isUploading ? null : _onDone,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _isUploading ? AppColors.borderThin : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Done',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
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
