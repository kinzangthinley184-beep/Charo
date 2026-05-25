import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';

const Map<String, int> _kDistances = {
  'u1': 65,
  'u2': 77,
  'u4': 145,
  'u6': 180,
  'u3': 198,
  'u7': 220,
  'u5': 550,
};


const List<String> _kFilters = ['All', '5 km', '10 km', '25 km', '50 km', '100 km+'];
// max distance per filter index; 0 and 5 mean "no limit"
const List<int> _kFilterMax = [0, 5, 10, 25, 50, 0];

class PeopleScreen extends StatefulWidget {
  final List<AppUser> matches;
  final Map<String, List<ChatMessage>> conversations;
  final void Function(String userId, String text) onSendMessage;
  final void Function(String userId, String text) onReceiveMessage;

  const PeopleScreen({
    super.key,
    required this.matches,
    required this.conversations,
    required this.onSendMessage,
    required this.onReceiveMessage,
  });

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  int _selectedFilter = 0;

  List<AppUser> get _sortedUsers {
    final users = context.read<AppState>().allUsers;
    return [...users]
      ..sort((a, b) =>
          (_kDistances[a.id] ?? 0).compareTo(_kDistances[b.id] ?? 0));
  }

  List<AppUser> get _filteredUsers {
    final max = _kFilterMax[_selectedFilter];
    final sorted = _sortedUsers;
    if (max == 0) return sorted;
    return sorted.where((u) => (_kDistances[u.id] ?? 0) <= max).toList();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 16),
            _buildSectionHeader(users.length),
            const SizedBox(height: 8),
            Expanded(
              child: users.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (_, i) => _NearbyCard(user: users[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Around me',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary),
              ),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_pin,
                    size: 13, color: AppColors.darkTextSecondary),
                const SizedBox(width: 2),
                Text(
                  'Thimphu, Bhutan',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.darkTextSecondary),
                ),
              ]),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.saffron, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _kFilters.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.saffron
                    : AppColors.darkElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _kFilters[i],
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? Colors.white
                        : AppColors.darkTextSecondary),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Text(
          'PEOPLE NEAR YOU',
          style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextSecondary,
              letterSpacing: 0.8),
        ),
        const Spacer(),
        Text(
          '$count people found',
          style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.saffron),
        ),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_rounded,
              color: AppColors.darkTextSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            'No one nearby',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Try expanding your distance filter',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Nearby person card ─────────────────────────────────────────────────────

class _NearbyCard extends StatelessWidget {
  final AppUser user;
  const _NearbyCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final dist = _kDistances[user.id] ?? 0;
    return Container(
      height: 88,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        border: Border.all(color: AppColors.darkBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildInfo(dist)),
          const SizedBox(width: 8),
          _buildRight(dist),
        ]),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: user.gradient),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.initial,
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
        if (user.isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.saffron,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkElevated, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.check_rounded,
                    size: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(int dist) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user.name}, ${user.age}',
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          user.occupation,
          style: GoogleFonts.poppins(
              fontSize: 13, color: AppColors.darkTextSecondary),
        ),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.location_pin,
              size: 11, color: AppColors.darkTextMuted),
          const SizedBox(width: 2),
          Text(
            user.location,
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.darkTextMuted),
          ),
          const SizedBox(width: 4),
          Text(
            '·',
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.darkTextMuted),
          ),
          const SizedBox(width: 4),
          Text(
            '$dist km',
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.saffron),
          ),
        ]),
      ],
    );
  }

  Widget _buildRight(int dist) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.saffron,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$dist km',
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        const Icon(Icons.favorite_border_rounded,
            size: 20, color: AppColors.darkTextSecondary),
      ],
    );
  }
}
