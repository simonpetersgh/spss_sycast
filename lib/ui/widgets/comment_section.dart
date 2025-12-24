
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_theme.dart';

class CommentSection extends StatelessWidget {
  const CommentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();
    
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: StreamBuilder(
        // Filter: Recent 1 hour
        stream: Supabase.instance.client
            .from('live_comments')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
           final comments = snapshot.data ?? [];

           if (comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white24, size: 40),
                  SizedBox(height: 8),
                  Text("No comments yet. Be the first!", style: TextStyle(color: Colors.white24)),
                ],
              ),
            ),
          );
        }

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(comments[index]['username'], style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                subtitle: Text(comments[index]['content']),
              );
            },
          );
        },
      ),
    );
  }
}