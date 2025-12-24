import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Sign in anonymously so they can comment
  Future<void> ensureAuth() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }

  // Get stream of recent comments (Last 1 hour)
  Stream<List<Map<String, dynamic>>> getCommentsStream() {
    return _client
        .from('live_comments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Post a new comment
  Future<void> postComment(String content, String username) async {
    await _client.from('live_comments').insert({
      'content': content,
      'username': username,
      'is_anonymous': _client.auth.currentUser?.isAnonymous ?? true,
    });
  }
}