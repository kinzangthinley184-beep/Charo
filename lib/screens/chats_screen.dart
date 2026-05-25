import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/app_user.dart';
import '../state/app_state.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatelessWidget {
  final List<AppUser> matches;
  final Map<String, List<ChatMessage>> conversations;
  final void Function(String userId, String text) onSendMessage;
  final void Function(String userId, String text) onReceiveMessage;

  const ChatsScreen({
    super.key,
    required this.matches,
    required this.conversations,
    required this.onSendMessage,
    required this.onReceiveMessage,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUserId = appState.userId ?? '';
    final sorted = [...matches]..sort((a, b) {
        final aLast = (conversations[a.id] ?? []).lastOrNull?.timestamp ?? DateTime(2000);
        final bLast = (conversations[b.id] ?? []).lastOrNull?.timestamp ?? DateTime(2000);
        return bLast.compareTo(aLast);
      });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            if (matches.isNotEmpty) ...[
              _SectionLabel(label: 'NEW MATCHES'),
              _MatchBubbleRow(
                matches: matches,
                onTap: (user) => _openChat(context, user),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1, thickness: 0.5, color: AppColors.borderThin),
            ],
            if (sorted.isEmpty)
              Expanded(child: _EmptyChats())
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 80,
                    color: AppColors.borderThin,
                  ),
                  itemBuilder: (_, i) {
                    final user = sorted[i];
                    final msgs = conversations[user.id] ?? [];
                    final last = msgs.lastOrNull;
                    final unread = msgs
                        .where((m) => m.senderId != currentUserId && !m.isRead)
                        .length;
                    return _ChatTile(
                      user: user,
                      lastMessage: last?.text ?? 'Say hi',
                      time: last?.timestamp,
                      unread: unread,
                      onTap: () => _openChat(context, user),
                    )
                        .animate(delay: (i * 40).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.06, end: 0, duration: 300.ms, curve: Curves.easeOut);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, AppUser user) {
    final appState = context.read<AppState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          user: user,
          currentUser: appState.currentUser,
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 20, 14),
          decoration: const BoxDecoration(
            color: Color(0xB3111111),
            border: Border(
              bottom: BorderSide(color: AppColors.borderThin, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Text(
                'MESSAGES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white30,
                  letterSpacing: 4.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderThin, width: 0.5),
                  ),
                  child: const Icon(Icons.search_rounded, color: AppColors.white60, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.white30,
          letterSpacing: 3.5,
        ),
      ),
    );
  }
}

// ── Match bubble row ─────────────────────────────────────────────────────────

class _MatchBubbleRow extends StatelessWidget {
  final List<AppUser> matches;
  final void Function(AppUser) onTap;

  const _MatchBubbleRow({required this.matches, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: matches.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _MatchBubble(user: matches[i], onTap: () => onTap(matches[i])),
      ),
    );
  }
}

class _MatchBubble extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;

  const _MatchBubble({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderThin, width: 0.5),
            ),
            child: ClipOval(
              child: user.profileImage.isNotEmpty
                  ? Image.network(
                      user.profileImage,
                      fit: BoxFit.cover,
                      headers: const {'User-Agent': 'Mozilla/5.0'},
                      errorBuilder: (_, _, _) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.name,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.white60,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF111111),
      child: Center(
        child: Text(
          user.initial,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Chat tile ────────────────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final AppUser user;
  final String lastMessage;
  final DateTime? time;
  final int unread;
  final VoidCallback onTap;

  const _ChatTile({
    required this.user,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = time == null ? '' : _formatTime(time!);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderThin, width: 0.5),
              ),
              child: ClipOval(
                child: user.profileImage.isNotEmpty
                    ? Image.network(
                        user.profileImage,
                        fit: BoxFit.cover,
                        headers: const {'User-Agent': 'Mozilla/5.0'},
                        errorBuilder: (_, _, _) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${user.name}, ${user.age}',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: unread > 0 ? AppColors.white60 : AppColors.white30,
                      fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.white30),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
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
          user.initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inMinutes < 60) return '${now.difference(t).inMinutes}m';
    if (t.day == now.day) return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    return '${t.day}/${t.month}';
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.white30),
            const SizedBox(height: 20),
            Text(
              'No messages yet',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Match with someone to start chatting.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.white30,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
