import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../data/mock_data.dart';
import 'chat_detail_screen.dart';

class PeopleScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('People',
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary)),
            ),
            const SizedBox(height: 16),
            if (matches.isEmpty)
              Expanded(child: _EmptyMatches())
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Your Connections (${matches.length})',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextSecondary)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: matches.length,
                  itemBuilder: (_, i) {
                    final user = matches[i];
                    return _MatchCard(
                      user: user,
                      unread: (conversations[user.id] ?? [])
                          .where((m) =>
                              m.senderId != kCurrentUserId && !m.isRead)
                          .length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            user: user,
                            messages: conversations[user.id] ?? [],
                            onSendMessage: (text) =>
                                onSendMessage(user.id, text),
                            onReceiveMessage: onReceiveMessage,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final AppUser user;
  final int unread;
  final VoidCallback onTap;

  const _MatchCard(
      {required this.user, required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: user.gradient,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: user.gradient.last.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(user.initial,
                  style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.15))),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(18)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user.name}, ${user.age}',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(user.location,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: AppColors.matchPink, shape: BoxShape.circle),
                  child: Text('$unread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💫', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('No connections yet',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          const SizedBox(height: 8),
          Text('Start swiping to find your match in Bhutan!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }
}
