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
  // Get stream of comments (filtered in UI for 1-hour)
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

  // Fetch the main app stream config (URL, Stream Name)
  Future<Map<String, dynamic>> fetchStreamConfig() async {
    return await _client.from('stream_config').select().eq('id', 1).single();
  }

  // Fetch all APK releases for the download archive
  Future<List<Map<String, dynamic>>> fetchApkReleaseHistory() async {
    final data = await _client
        .from('apk_releases')
        .select()
        .order('version_code', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

}
