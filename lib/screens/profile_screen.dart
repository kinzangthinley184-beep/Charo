import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../data/bhutan_profile_data.dart';
import '../data/mock_data.dart';
import '../models/app_user.dart';
import '../widgets/verified_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onUpgrade;
  const ProfileScreen({super.key, required this.isPremium, required this.onUpgrade});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _activeTab = 0;
  late AppUser _currentUser;

  static const String _mockName = 'Kinzang, 24';
  static const String _mockOccupation = 'Software Developer';
  static const String _mockLocation = 'Thimphu, Bhutan';
  static const String _mockBio =
      "Tiger's Nest hiker 🏔 | Tech enthusiast | Looking for genuine connections in Bhutan 🇧🇹";
  static const List<String> _mockInterests = ['Archery', 'Ema Datshi', 'Tsechu', 'Hiking', 'GNH'];
  static const double _mockProfileStrength = 0.35;

  @override
  void initState() {
    super.initState();
    _currentUser = kCurrentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildInstagramHeader()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.1, duration: 600.ms, curve: Curves.easeOut),
              const SizedBox(height: 12),
              _buildProfileInfo(),
              const SizedBox(height: 12),
              _buildCompleteProfileBanner(),
              const SizedBox(height: 16),
              _buildTabBar(),
              if (_activeTab == 0) _buildPhotoGrid() else _buildAboutMe(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
      child: Row(
        children: [
          Text(
            'Profile',
            style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline_rounded,
                color: AppColors.darkTextSecondary),
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.saffron, width: 2.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _currentUser.gradient),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _currentUser.initial,
                  style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${(_mockProfileStrength * 100).toInt()}%',
              style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              _mockName,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary),
            ),
            const SizedBox(width: 6),
            const VerifiedBadge(size: 16),
          ]),
          const SizedBox(height: 2),
          Text(
            _mockOccupation,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.location_pin,
                size: 13, color: AppColors.darkTextMuted),
            const SizedBox(width: 2),
            Text(
              _mockLocation,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.darkTextMuted),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            _mockBio,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.darkTextSecondary,
                height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _mockInterests
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.saffron, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.saffron,
                            fontWeight: FontWeight.w500),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _mockProfileStrength,
                  backgroundColor: AppColors.darkElevated,
                  color: AppColors.saffron,
                  minHeight: 3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(_mockProfileStrength * 100).toInt()}%',
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.saffron,
                  fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _showCompleteProfile,
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkBorder, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Edit profile',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextPrimary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkBorder, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.share_outlined,
                  size: 18, color: AppColors.darkTextPrimary),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _showCompleteProfile,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.darkElevated,
            border: Border.all(color: AppColors.darkBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded,
                color: AppColors.saffron, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary),
                  ),
                  Text(
                    'Get 3x more connections',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.saffron, size: 22),
          ]),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _activeTab == 0
                          ? AppColors.saffron
                          : AppColors.darkBorder,
                      width: _activeTab == 0 ? 2 : 0.5,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 22,
                    color: _activeTab == 0
                        ? AppColors.saffron
                        : AppColors.darkTextSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _activeTab == 1
                          ? AppColors.saffron
                          : AppColors.darkBorder,
                      width: _activeTab == 1 ? 2 : 0.5,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 22,
                    color: _activeTab == 1
                        ? AppColors.saffron
                        : AppColors.darkTextSecondary,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: 6,
        itemBuilder: (_, i) =>
            i == 0 ? _buildMainPhotoSlot() : _buildEmptyPhotoSlot(i),
      ),
    );
  }

  Widget _buildMainPhotoSlot() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _currentUser.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              _currentUser.initial,
              style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'MAIN',
              style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhotoSlot(int index) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        color: AppColors.darkElevated,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: AppColors.darkTextSecondary, size: 24),
            if (index == 1) ...[
              const SizedBox(height: 2),
              Text(
                'Add photo',
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.darkTextSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutMe() {
    final List<(IconData, String, String?, bool)> rows = [
      (Icons.location_city_rounded, 'Dzongkhag', 'Thimphu', true),
      (Icons.temple_buddhist_rounded, 'Religion', 'Buddhist', true),
      (Icons.auto_awesome_rounded, 'Zodiac', null, false),
      (Icons.favorite_outline_rounded, 'Looking for', null, false),
      (Icons.language_rounded, 'Languages', 'Dzongkha, English', true),
      (Icons.height_rounded, 'Height', null, false),
      (Icons.local_bar_outlined, 'Drinking', null, false),
      (Icons.smoking_rooms_outlined, 'Smoking', null, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Text(
              'ABOUT ME',
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextSecondary,
                  letterSpacing: 1.2),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showCompleteProfile,
              child: Text(
                'Edit',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < rows.length; i++) ...[
          _AboutRow(
            icon: rows[i].$1,
            label: rows[i].$2,
            value: rows[i].$3,
            hasValue: rows[i].$4,
          ),
          if (i < rows.length - 1)
            const Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.darkBorder,
              indent: 68,
            ),
        ],
      ],
    );
  }

  void _showCompleteProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CompleteProfileSheet(
        user: _currentUser,
        onUpdate: (updated) => setState(() => _currentUser = updated),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Settings',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 16),
          ...['Edit Profile', 'Notifications', 'Privacy', 'Help & Support', 'Log Out']
              .map((item) => ListTile(
                    title: Text(item,
                        style: GoogleFonts.poppins(
                            color: item == 'Log Out'
                                ? AppColors.matchPink
                                : AppColors.darkTextPrimary)),
                    trailing: item == 'Log Out'
                        ? null
                        : const Icon(Icons.chevron_right_rounded,
                            color: AppColors.darkTextSecondary),
                    onTap: () => Navigator.pop(context),
                  )),
        ]),
      ),
    );
  }
}

// ── About me row ──────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool hasValue;
  const _AboutRow(
      {required this.icon,
      required this.label,
      this.value,
      required this.hasValue});

  String _placeholder() {
    switch (label) {
      case 'Zodiac':
        return 'Add your zodiac sign';
      case 'Looking for':
        return "Add what you're looking for";
      case 'Height':
        return 'Add your height';
      case 'Drinking':
        return 'Optional';
      case 'Smoking':
        return 'Optional';
      default:
        return 'Add $label';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.saffron, size: 16),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 1),
            Text(
              hasValue ? value! : _placeholder(),
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.normal,
                  color: hasValue
                      ? AppColors.darkTextPrimary
                      : AppColors.darkTextMuted),
            ),
          ],
        ),
      ]),
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.darkBorder
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _dash(canvas, paint, Offset.zero, Offset(size.width, 0));
    _dash(canvas, paint, Offset(size.width, 0), Offset(size.width, size.height));
    _dash(canvas, paint, Offset(size.width, size.height), Offset(0, size.height));
    _dash(canvas, paint, Offset(0, size.height), Offset.zero);
  }

  void _dash(Canvas canvas, Paint paint, Offset a, Offset b) {
    const dw = 5.0;
    const gap = 4.0;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final ux = dx / len;
    final uy = dy / len;
    var d = 0.0;
    while (d < len) {
      final end = math.min(d + dw, len);
      canvas.drawLine(
        Offset(a.dx + ux * d, a.dy + uy * d),
        Offset(a.dx + ux * end, a.dy + uy * end),
        paint,
      );
      d += dw + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}

// ── Complete profile sheet ────────────────────────────────────────────────

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
          color: isDone
              ? AppColors.likeGreen.withValues(alpha: 0.15)
              : AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: isDone ? AppColors.likeGreen : AppColors.gold, size: 22),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.darkTextPrimary)),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(
              fontSize: 12,
              color:
                  isDone ? AppColors.saffron : AppColors.darkTextSecondary)),
      trailing: isDone
          ? const Icon(Icons.check_circle_rounded, color: AppColors.likeGreen)
          : const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.darkTextSecondary),
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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.darkBorder,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Complete your profile',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary)),
                const SizedBox(height: 4),
                Text(
                    '$score% complete — profiles with more info get 3x more connections!',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.darkTextSecondary)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100.0,
                    backgroundColor: AppColors.darkElevated,
                    color: AppColors.saffron,
                    minHeight: 8,
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
                    subtitle: photos.isEmpty
                        ? 'Add up to 6 photos'
                        : '${photos.length} photos added',
                    isDone: photos.isNotEmpty,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _PhotosEditorSheet(
                        photos: photos,
                        onSave: (p) => _update(_user.copyWith(photos: p)),
                      ),
                    ),
                  ),
                  _row(
                    icon: Icons.work_outline_rounded,
                    title: 'Occupation',
                    subtitle: _user.occupation.isNotEmpty
                        ? _user.occupation
                        : 'What do you do?',
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
                        'Education level',
                        kEducationLevels,
                        _user.education,
                        (v) => _update(_user.copyWith(education: v))),
                  ),
                  _row(
                    icon: Icons.favorite_outline_rounded,
                    title: 'Looking for',
                    subtitle: _user.lookingFor ?? 'What are you here for?',
                    isDone: _user.lookingFor?.isNotEmpty == true,
                    onTap: () => _picker(
                        'I am looking for...',
                        kLookingFor,
                        _user.lookingFor,
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
                        onSave: (interests) =>
                            _update(_user.copyWith(interests: interests)),
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
                        'Your zodiac sign',
                        kZodiacSigns,
                        _user.zodiacSign,
                        (v) => _update(_user.copyWith(zodiacSign: v))),
                  ),
                  _row(
                    icon: Icons.pets_rounded,
                    title: 'Bhutanese zodiac',
                    subtitle: _user.bhutaneseZodiac ?? 'Losar birth animal',
                    isDone: _user.bhutaneseZodiac?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Your birth year animal',
                        kBhutaneseZodiacAnimals,
                        _user.bhutaneseZodiac,
                        (v) => _update(_user.copyWith(bhutaneseZodiac: v))),
                  ),
                  _row(
                    icon: Icons.temple_buddhist_rounded,
                    title: 'Religion',
                    subtitle: _user.religion ?? 'Optional',
                    isDone: _user.religion?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Religion',
                        kReligions,
                        _user.religion,
                        (v) => _update(_user.copyWith(religion: v))),
                  ),
                  _row(
                    icon: Icons.people_outline_rounded,
                    title: 'Ethnicity',
                    subtitle: _user.ethnicity ?? 'Optional',
                    isDone: _user.ethnicity?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Ethnicity',
                        kEthnicities,
                        _user.ethnicity,
                        (v) => _update(_user.copyWith(ethnicity: v))),
                  ),
                  _row(
                    icon: Icons.height_rounded,
                    title: 'Height',
                    subtitle: _user.height ?? 'Optional',
                    isDone: _user.height?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Your height',
                        kHeights,
                        _user.height,
                        (v) => _update(_user.copyWith(height: v))),
                  ),
                  _row(
                    icon: Icons.local_bar_outlined,
                    title: 'Drinking',
                    subtitle: _user.drinkingHabit ?? 'Optional',
                    isDone: _user.drinkingHabit?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Drinking habits',
                        kDrinkingHabits,
                        _user.drinkingHabit,
                        (v) => _update(_user.copyWith(drinkingHabit: v))),
                  ),
                  _row(
                    icon: Icons.smoking_rooms_outlined,
                    title: 'Smoking',
                    subtitle: _user.smokingHabit ?? 'Optional',
                    isDone: _user.smokingHabit?.isNotEmpty == true,
                    onTap: () => _picker(
                        'Smoking habits',
                        kSmokingHabits,
                        _user.smokingHabit,
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

// ── Picker sheet ──────────────────────────────────────────────────────────

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
          color: AppColors.darkSurface,
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
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.saffron
                          : AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(opt,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected
                              ? Colors.white
                              : AppColors.darkTextPrimary,
                        )),
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

// ── Multi-picker sheet ────────────────────────────────────────────────────

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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: AppColors.darkBorder,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    Text(widget.title,
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary)),
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
                      if (selected) {
                        _selected.remove(opt);
                      } else {
                        _selected.add(opt);
                      }
                    }),
                    title: Text(opt,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppColors.darkTextPrimary)),
                    activeColor: AppColors.saffron,
                    checkColor: Colors.white,
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
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text('Save',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Text editor sheet ─────────────────────────────────────────────────────

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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
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
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(widget.title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                cursorColor: AppColors.saffron,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.darkTextSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) {
                  final v = _ctrl.text.trim();
                  if (v.isNotEmpty) {
                    widget.onSave(v);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                final v = _ctrl.text.trim();
                if (v.isNotEmpty) {
                  widget.onSave(v);
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Text('Save',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Interests editor sheet ────────────────────────────────────────────────

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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: AppColors.darkBorder,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    Text('Interests',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 4),
                    Text('Pick at least 3',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.darkTextSecondary)),
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
                          if (isSelected) {
                            _selected.remove(interest);
                          } else {
                            _selected.add(interest);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.saffron
                                : AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.saffron
                                    : AppColors.darkBorder),
                          ),
                          child: Text(interest,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.darkTextSecondary,
                              )),
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
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text('Save',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photos editor sheet ───────────────────────────────────────────────────

class _PhotosEditorSheet extends StatefulWidget {
  final List<String> photos;
  final void Function(List<String>) onSave;

  const _PhotosEditorSheet({required this.photos, required this.onSave});

  @override
  State<_PhotosEditorSheet> createState() => _PhotosEditorSheetState();
}

class _PhotosEditorSheetState extends State<_PhotosEditorSheet> {
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.photos);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
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
                                color: AppColors.darkBorder,
                                borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    Text('Add photos',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary)),
                    const SizedBox(height: 4),
                    Text('Your first photo is your main profile photo',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.darkTextSecondary)),
                  ]),
            ),
            Expanded(
              child: GridView.count(
                controller: ctrl,
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: List.generate(6, (i) {
                  final hasPhoto = i < _photos.length;
                  return GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Photo upload coming soon!')),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: hasPhoto ? null : AppColors.darkElevated,
                        gradient: hasPhoto ? AppColors.headerGradient : null,
                        borderRadius: BorderRadius.circular(12),
                        border: hasPhoto
                            ? null
                            : Border.all(
                                color: AppColors.darkBorder, width: 1.5),
                      ),
                      child: hasPhoto
                          ? Center(
                              child: Text(_photos[i][0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded,
                                    color: i == 0
                                        ? AppColors.saffron
                                        : AppColors.darkTextSecondary,
                                    size: 28),
                                const SizedBox(height: 4),
                                if (i == 0)
                                  Text('Add photo',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppColors.saffron,
                                          fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: GestureDetector(
                onTap: () {
                  widget.onSave(_photos);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text('Done',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
