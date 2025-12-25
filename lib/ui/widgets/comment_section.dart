import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/app_provider.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  void _handleSend() {
    // Access the provider directly using context
    final prov = context.read<AppProvider>();
    final commentText = _commentController.text.trim();

    if (commentText.isNotEmpty) {
      prov.sendComment(
        commentText,
        "Anonymous User", // You can later replace this with a real username
      );
      _commentController.clear();
      FocusScope.of(context).unfocus(); // Close keyboard after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryMint = theme.colorScheme.primary; // #1eddaa
    final accentPurple = theme.colorScheme.secondary; // #9549fe

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          // height: 450, // Slightly taller to accommodate input
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(
              0.7,
            ), // Glassy background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // 1. HEADER
              _buildHeader(primaryMint),

              // 2. CHAT MESSAGES
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: Supabase.instance.client
                      .from('live_comments')
                      .stream(primaryKey: ['id'])
                      .order('created_at', ascending: false)
                      .limit(50),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) return const _EmptyChatPlaceholder();

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _CommentBubble(
                          username: comment['username'] ?? 'Anonymous',
                          content: comment['content'] ?? '',
                          usernameColor:
                              index % 2 == 0 ? primaryMint : accentPurple,
                        );
                      },
                    );
                  },
                ),
              ),

              // 3. INTEGRATED INPUT FIELD
              _buildInputField(theme, primaryMint),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryMint) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryMint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: primaryMint),
                const SizedBox(width: 6),
                Text(
                  "Live Chat",
                  style: TextStyle(
                    color: primaryMint,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.people_alt_outlined,
            size: 14,
            color: Colors.white54,
          ),
          const SizedBox(width: 4),
          const Text(
            "1.2k",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(ThemeData theme, Color primaryMint) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2), // Darker well for the input
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _commentController,
                cursorColor: primaryMint,
                // maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Say something...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            // Send Button
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryMint, // Your #1EDDAA
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryMint.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Color(0xFF181C27),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-widgets for cleaner code
class _CommentBubble extends StatelessWidget {
  final String username;
  final String content;
  final Color usernameColor;

  const _CommentBubble({
    required this.username,
    required this.content,
    required this.usernameColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$username ',
              style: TextStyle(
                color: usernameColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Welcome to the stream! Start the conversation...",
        style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
      ),
    );
  }
}
